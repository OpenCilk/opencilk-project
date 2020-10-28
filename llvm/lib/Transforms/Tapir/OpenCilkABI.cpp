//===- OpenCilkABI.cpp - Interface to the OpenCilk runtime system------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the OpenCilk ABI to converts Tapir instructions to calls
// into the OpenCilk runtime system.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Tapir/OpenCilkABI.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Linker/Linker.h"
#include "llvm/Transforms/Tapir/CilkRTSCilkFor.h"
#include "llvm/Transforms/Tapir/Outline.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/EscapeEnumerator.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

#include "llvm/Transforms/IPO/Internalize.h"

#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/Triple.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Mangler.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Linker/Linker.h"
#include "llvm/Object/ObjectFile.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Transforms/IPO/Internalize.h"
#include <stddef.h>
#include <string.h>
#include <map>
#include <mutex>  // NOLINT(build/c++11): only using std::call_once, not mutex.
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

using namespace llvm;

#define DEBUG_TYPE "opencilk"

extern cl::opt<bool> DebugABICalls;
extern cl::opt<bool> UseExternalABIFunctions;

static cl::opt<bool> UseOpenCilkRuntimeBC("use-opencilk-runtime-bc", cl::init(false),
    cl::desc("Use the bitcode file for opencilk runtime."), cl::Hidden);
static cl::opt<std::string> OpenCilkRuntimeBCPath("opencilk-runtime-bc-path", cl::init(""),
    cl::desc("Path to the bitcode file for the opencilk runtime"), cl::Hidden);

enum {
  __CILKRTS_ABI_VERSION_OPENCILK = 3
};

enum {
  CILK_FRAME_STOLEN            =    0x01,
  CILK_FRAME_UNSYNCHED         =    0x02,
  CILK_FRAME_DETACHED          =    0x04,
  CILK_FRAME_EXCEPTION_PENDING =    0x08,
  CILK_FRAME_EXCEPTING         =    0x10,
  CILK_FRAME_LAST              =    0x80,
  CILK_FRAME_EXITING           =  0x0100,
  CILK_FRAME_SUSPENDED         =  0x8000,
  CILK_FRAME_UNWINDING         = 0x10000
};

#define CILK_FRAME_VERSION_MASK  0xFF000000
#define CILK_FRAME_FLAGS_MASK    0x00FFFFFF
#define CILK_FRAME_MBZ  (~ (CILK_FRAME_STOLEN            |       \
                            CILK_FRAME_UNSYNCHED         |       \
                            CILK_FRAME_DETACHED          |       \
                            CILK_FRAME_EXCEPTION_PENDING |       \
                            CILK_FRAME_EXCEPTING         |       \
                            CILK_FRAME_LAST              |       \
                            CILK_FRAME_EXITING           |       \
                            CILK_FRAME_SUSPENDED         |       \
                            CILK_FRAME_UNWINDING         |       \
                            CILK_FRAME_VERSION_MASK))

#define CILKRTS_FUNC(name) Get__cilkrts_##name()

OpenCilkABI::OpenCilkABI(Module &M)
  : TapirTarget(M)
{
  LLVMContext &C = M.getContext();
  Type *VoidPtrTy = Type::getInt8PtrTy(C);
  Type *Int32Ty = Type::getInt32Ty(C);

  // NOTE(TFK): Removing the check for struct.__cilkrts_stack_frame in the conditional below 
  //            can cause an infinite loop. I am unsure exactly why this infinite loop occurs.
  //            However, I think it makes sense, independent of this "bug", to only link to 
  //            the opencilk runtime bitcode once-per-module. Ideally, there is a more elegant
  //            way to perform this check other than looking for a specific structure definition. 
  if(UseOpenCilkRuntimeBC.getValue() && (M.getTypeByName("struct.__cilkrts_stack_frame") == nullptr ||
     M.getTypeByName("struct.__cilkrts_stack_frame")->isOpaque())) {
    llvm::errs() << "Using custom BC path \n"; 
    llvm::SMDiagnostic smd;

    // NOTE(TFK): The behavior I observe is that the invocation of llvm::parseIRFile 
    //            imports global values like structure definitions into the current module
    //            because it is using the current module's context "C".
    //            llvm::parseIRFile, however, does not import function definitions (and
    //            perhaps not even declarations?) into the module. Therefore, we need to
    //            additionally run linkModules.
    auto external_module = llvm::parseIRFile(OpenCilkRuntimeBCPath.getValue(), smd, C);

    // NOTE(TFK): This links the functions in external_module (the source) into the current module
    //            M (the destination). Because the needed functions, such as cilkrts_enter_frame,
    //            are not yet declared when OpenCilkABI is called we use llvm::Linker::Flags::None
    //            so that all functions in external_module are imported.
    //            Using llvm::Linker::Flags::LinkOnlyNeeded will not import the needed functions unless
    //            we declare those functions in this module in advance of linking.
    bool result = llvm::Linker::linkModules(M, std::move(external_module), llvm::Linker::Flags::None,
    [](llvm::Module& M, const llvm::StringSet<>& GVS) {
      llvm::errs() << "Linking with bitcode file at " << OpenCilkRuntimeBCPath << "\n";
      llvm::internalizeModule(M, 
          [&GVS](const llvm::GlobalValue& GV) {
            return !GV.hasName() || GVS.count(GV.getName()) == 0;
          });
      // NOTE(TFK): This prints the functions that are imported into the current module.
      for (auto x = GVS.keys().begin(); x != GVS.keys().end(); ++x) {
        llvm::errs() << *x << "\n";
      }
    });
    assert(!result && "An error occurred when linking to the opencilk runtime bitcode module.\n");
    llvm::errs() << "After link  modules \n"; 
  }

  // Get or create local definitions of Cilk RTS structure types.
  const char *StackFrameName = "struct.__cilkrts_stack_frame";
  StackFrameTy = StructType::lookupOrCreate(C, StackFrameName);
  WorkerTy = StructType::lookupOrCreate(C, "struct.__cilkrts_worker");

  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  PointerType *WorkerPtrTy = PointerType::getUnqual(WorkerTy);
  ArrayType *ContextTy = ArrayType::get(VoidPtrTy, 5);

  Triple T(M.getTargetTriple());
  bool HasSSE = T.getArch() == Triple::x86 || T.getArch() == Triple::x86_64;
  if (HasSSE) {
    if (StackFrameTy->isOpaque())
      StackFrameTy->setBody(Int32Ty, // flags
                            Int32Ty, // magic
                            StackFramePtrTy, // call_parent
                            WorkerPtrTy, // worker
                            // VoidPtrTy, // except_data
                            ContextTy, // ctx
                            Int32Ty // mxcsr
                            );
  }
  else {
    if (StackFrameTy->isOpaque())
      StackFrameTy->setBody(Int32Ty, // flags
                            Int32Ty, // magic
                            StackFramePtrTy, // call_parent
                            WorkerPtrTy, // worker
                            // VoidPtrTy, // except_data
                            ContextTy // ctx
                            );
  }

  unsigned StackFields = StackFrameTy->getNumElements();
  if (StackFields > 127)
    StackFields = 127;
  for (unsigned i = 0; i < StackFields; ++i) {
    Type *E = StackFrameTy->getElementType(i);
    if (E == Int32Ty) {
      if (StackFrameFieldFlags < 0)
	StackFrameFieldFlags = i;
      else if (StackFrameFieldMagic < 0)
	StackFrameFieldMagic = i;
      else if (HasSSE && StackFrameFieldMXCSR < 0)
	StackFrameFieldMXCSR = i;
      continue;
    }
    if (E == StackFramePtrTy) {
      if (StackFrameFieldParent < 0)
	StackFrameFieldParent = i;
      continue;
    }
    if (E == WorkerPtrTy) {
      if (StackFrameFieldWorker < 0) {
	StackFrameFieldWorker = i;
      }
      continue;
    }
    if (E == ContextTy) {
      if (StackFrameFieldContext < 0)
	StackFrameFieldContext = i;
      continue;
    }
  }

  /* These four fields are mandatory. TODO: Proper error message. */
  assert(StackFrameFieldContext >= 0 && "__cilkrts_stack_frame lacks context");
  assert(StackFrameFieldFlags >= 0 && "__cilkrts_stack_frame lacks flags");
  assert(StackFrameFieldParent >= 0 && "__cilkrts_stack_frame lacks parent");
  assert(StackFrameFieldWorker >= 0 && "__cilkrts_stack_frame lacks worker");

  if (StackFrameFieldMagic >= 0) {
    const StructLayout *StackLayout =
      M.getDataLayout().getStructLayout(StackFrameTy);
    /* This must match the runtime. */
    uint32_t StackFieldHash = __CILKRTS_ABI_VERSION_OPENCILK;
    StackFieldHash *= 13;
    StackFieldHash += StackLayout->getElementOffset(StackFrameFieldWorker);
    StackFieldHash *= 13;
    StackFieldHash += StackLayout->getElementOffset(StackFrameFieldContext);
    StackFieldHash *= 13;
    StackFieldHash += StackLayout->getElementOffset(StackFrameFieldMagic);
    StackFieldHash *= 13;
    StackFieldHash += StackLayout->getElementOffset(StackFrameFieldFlags);
    StackFieldHash *= 13;
    StackFieldHash += StackLayout->getElementOffset(StackFrameFieldParent);
    if (StackFrameFieldMXCSR >= 0) {
      StackFieldHash *= 13;
      StackFieldHash += StackLayout->getElementOffset(StackFrameFieldMXCSR);
    }
    FrameMagic = StackFieldHash;
  }

  PointerType *StackFramePtrPtrTy = PointerType::getUnqual(StackFramePtrTy);
  if (WorkerTy->isOpaque())
    WorkerTy->setBody(StackFramePtrPtrTy, // tail
                      StackFramePtrPtrTy, // head
                      StackFramePtrPtrTy, // exc
                      StackFramePtrPtrTy, // ltq_limit
                      Int32Ty, // self
                      VoidPtrTy, // g
                      VoidPtrTy, // l
                      StackFramePtrTy, // current_stack_frame
                      VoidPtrTy // reducer_map
                      );

  /* TODO: If worker comes from program, verify that fields
     have correct types. */
}

// Accessors for opaque Cilk RTS functions

FunctionCallee OpenCilkABI::Get__cilkrts_get_nworkers() {
  if (CilkRTSGetNworkers)
    return CilkRTSGetNworkers;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::ReadNone);
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  FunctionType *FTy = FunctionType::get(Type::getInt32Ty(C), {}, false);
  CilkRTSGetNworkers = M.getOrInsertFunction("__cilkrts_get_nworkers", FTy, AL);
  return CilkRTSGetNworkers;
}

FunctionCallee OpenCilkABI::Get__cilkrts_leave_frame() {
  if (CilkRTSLeaveFrame)
    return CilkRTSLeaveFrame;

  const char *name = "__cilkrts_leave_frame";

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkRTSLeaveFrame = M.getOrInsertFunction(name, AL, VoidTy, StackFramePtrTy);

  return CilkRTSLeaveFrame;
}

FunctionCallee OpenCilkABI::Get__cilkrts_pause_frame() {
  if (CilkRTSPauseFrame)
    return CilkRTSPauseFrame;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  PointerType *ExnPtrTy = Type::getInt8PtrTy(C);
  CilkRTSPauseFrame = M.getOrInsertFunction("__cilkrts_pause_frame", AL, VoidTy,
                                            StackFramePtrTy, ExnPtrTy);

  return CilkRTSPauseFrame;
}

FunctionCallee OpenCilkABI::Get__cilkrts_check_exception_resume() {
  if (CilkRTSCheckExceptionResume)
    return CilkRTSCheckExceptionResume;

  LLVMContext &C = M.getContext();
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkRTSCheckExceptionResume = M.getOrInsertFunction(
                                            "__cilkrts_check_exception_resume",
                                            VoidTy, StackFramePtrTy);

  return CilkRTSCheckExceptionResume;
}
FunctionCallee OpenCilkABI::Get__cilkrts_check_exception_raise() {
  if (CilkRTSCheckExceptionRaise)
    return CilkRTSCheckExceptionRaise;

  LLVMContext &C = M.getContext();
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkRTSCheckExceptionRaise = M.getOrInsertFunction(
                                            "__cilkrts_check_exception_raise",
                               VoidTy, StackFramePtrTy);

  return CilkRTSCheckExceptionRaise;
}

FunctionCallee OpenCilkABI::Get__cilkrts_cleanup_fiber() {
  if (CilkRTSCleanupFiber)
    return CilkRTSCleanupFiber;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Type *Int32Ty = Type::getInt32Ty(C);
  CilkRTSCleanupFiber = M.getOrInsertFunction(
                                            "__cilkrts_cleanup_fiber",
                        VoidTy, StackFramePtrTy, Int32Ty);

  return CilkRTSCleanupFiber;
}

FunctionCallee OpenCilkABI::Get__cilkrts_sync() {
  if (CilkRTSSync)
    return CilkRTSSync;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkRTSSync = M.getOrInsertFunction("__cilkrts_sync", AL, VoidTy,
                                      StackFramePtrTy);

  return CilkRTSSync;
}

FunctionCallee OpenCilkABI::Get__cilkrts_get_tls_worker() {
  if (CilkRTSGetTLSWorker)
    return CilkRTSGetTLSWorker;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  PointerType *WorkerPtrTy = PointerType::getUnqual(WorkerTy);
  CilkRTSGetTLSWorker = M.getOrInsertFunction("__cilkrts_get_tls_worker", AL,
                                              WorkerPtrTy);

  return CilkRTSGetTLSWorker;
}

void OpenCilkABI::addHelperAttributes(Function &Helper) {
  // Use a fast calling convention for the helper.
  Helper.setCallingConv(CallingConv::Fast);
  // Inlining the helper function is not legal.
  Helper.removeFnAttr(Attribute::AlwaysInline);
  Helper.addFnAttr(Attribute::NoInline);
  // If the helper uses an argument structure, then it is not a write-only
  // function.
  if (getArgStructMode() != ArgStructMode::None) {
    Helper.removeFnAttr(Attribute::WriteOnly);
    Helper.removeFnAttr(Attribute::ArgMemOnly);
    Helper.removeFnAttr(Attribute::InaccessibleMemOrArgMemOnly);
  }
  // Note that the address of the helper is unimportant.
  Helper.setUnnamedAddr(GlobalValue::UnnamedAddr::Global);
  // The helper is private to this module.
  Helper.setLinkage(GlobalValue::PrivateLinkage);
}

/// Helper methods for storing to and loading from struct fields.
static Value *GEP(IRBuilder<> &B, Value *Base, int field) {
  // return B.CreateStructGEP(cast<PointerType>(Base->getType()),
  //                          Base, field);
  return B.CreateConstInBoundsGEP2_32(nullptr, Base, 0, field);
}

static unsigned GetAlignment(const DataLayout &DL, StructType *STy, int field) {
  return DL.getPrefTypeAlignment(STy->getElementType(field));
}

static void StoreSTyField(IRBuilder<> &B, const DataLayout &DL, StructType *STy,
                          Value *Val, Value *Dst, int field,
                          bool isVolatile = false,
                          AtomicOrdering Ordering = AtomicOrdering::NotAtomic) {
  StoreInst *S = B.CreateAlignedStore(Val, GEP(B, Dst, field),
                                      GetAlignment(DL, STy, field), isVolatile);
  S->setOrdering(Ordering);
}

static Value *LoadSTyField(
    IRBuilder<> &B, const DataLayout &DL, StructType *STy, Value *Src,
    int field, bool isVolatile = false,
    AtomicOrdering Ordering = AtomicOrdering::NotAtomic) {
  LoadInst *L =  B.CreateAlignedLoad(GEP(B, Src, field),
                                     GetAlignment(DL, STy, field), isVolatile);
  L->setOrdering(Ordering);
  return L;
}

/// Emit inline assembly code to save the floating point state, for x86 Only.
void OpenCilkABI::EmitSaveFloatingPointState(IRBuilder<> &B, Value *SF) {
  LLVMContext &C = B.getContext();
  if (StackFrameFieldMXCSR >= 0) {
    FunctionType *FTy =
      FunctionType::get(Type::getVoidTy(C),
			{PointerType::getUnqual(Type::getInt32Ty(C))},
			false);
    Value *Asm = InlineAsm::get(FTy, "stmxcsr $0", "*m", /*sideeffects*/ true);
    Value *Args[1] = {
      GEP(B, SF, StackFrameFieldMXCSR),
    };
    B.CreateCall(Asm, Args);
  }
}

/// Helper to find a function with the given name, creating it if it doesn't
/// already exist. Returns false if the function was inserted, indicating that
/// the body of the function has yet to be defined.
static bool GetOrCreateFunction(Module &M, const StringRef FnName,
                                FunctionType *FTy, Function *&Fn) {
  // If the function already exists then let the caller know.
  if ((Fn = M.getFunction(FnName)))
    return true;

  // Otherwise we have to create it.
  Fn = cast<Function>(M.getOrInsertFunction(FnName, FTy).getCallee());

  // Let the caller know that the function is incomplete and the body still
  // needs to be added.
  return false;
}

/// Emit a call to the CILK_SETJMP function.
CallInst *OpenCilkABI::EmitCilkSetJmp(IRBuilder<> &B, Value *SF) {
  LLVMContext &Ctx = M.getContext();

  // We always want to save the floating point state too
  Triple T(M.getTargetTriple());
  if (T.getArch() == Triple::x86 || T.getArch() == Triple::x86_64)
    EmitSaveFloatingPointState(B, SF);

  Type *Int32Ty = Type::getInt32Ty(Ctx);
  Type *Int8PtrTy = Type::getInt8PtrTy(Ctx);

  // Get the buffer to store program state
  // Buffer is a void**.
  Value *Buf = GEP(B, SF, StackFrameFieldContext);

  // Store the frame pointer in the 0th slot
  Value *FrameAddr = B.CreateCall(
      Intrinsic::getDeclaration(&M, Intrinsic::frameaddress, Int8PtrTy),
      ConstantInt::get(Int32Ty, 0));

  Value *FrameSaveSlot = GEP(B, Buf, 0);
  B.CreateStore(FrameAddr, FrameSaveSlot, /*isVolatile=*/true);

  // Store stack pointer in the 2nd slot
  Value *StackAddr = B.CreateCall(
      Intrinsic::getDeclaration(&M, Intrinsic::stacksave));

  Value *StackSaveSlot = GEP(B, Buf, 2);
  B.CreateStore(StackAddr, StackSaveSlot, /*isVolatile=*/true);

  Buf = B.CreateBitCast(Buf, Int8PtrTy);

  // Call LLVM's EH setjmp, which is lightweight.
  Value* F = Intrinsic::getDeclaration(&M, Intrinsic::eh_sjlj_setjmp);

  CallInst *SetjmpCall = B.CreateCall(F, Buf);
  SetjmpCall->setCanReturnTwice();

  return SetjmpCall;
}

/// Get or create a LLVM function for __cilkrts_pop_frame.  It is equivalent to
/// the following C code:
///
/// __cilkrts_pop_frame(__cilkrts_stack_frame *sf) {
///   sf->worker->current_stack_frame = sf->call_parent;
///   sf->call_parent = nullptr;
/// }
Function *OpenCilkABI::Get__cilkrts_pop_frame() {
  // Get or create the __cilkrts_pop_frame function.
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy = Type::getVoidTy(Ctx);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Function *Fn = nullptr;
  if (GetOrCreateFunction(M, "__cilkrts_pop_frame",
                          FunctionType::get(VoidTy, {StackFramePtrTy}, false),
                          Fn)) {
    Fn->setLinkage(Function::AvailableExternallyLinkage);
    Fn->setDoesNotThrow();
    if (!DebugABICalls && !UseExternalABIFunctions)
      Fn->addFnAttr(Attribute::AlwaysInline);
    return Fn;
  }

  // Create the body of __cilkrts_pop_frame.
  const DataLayout &DL = M.getDataLayout();

  Function::arg_iterator Args = Fn->arg_begin();
  Value *SF = &*Args;

  BasicBlock *Entry = BasicBlock::Create(Ctx, "entry", Fn);
  IRBuilder<> B(Entry);

  // TODO(jfc): Relaxed memory order is probably allowed for all
  // operations here.  All communication with other threads is
  // gated by the Dekker protocol which has a store-load memory barrier.
  // The compiler does need to be aware that values of the apparently
  // local stack frame can not be saved in registers across calls that
  // might cause the frame to be stolen.
  // sf->worker->current_stack_frame = sf->call_parent;
  StoreSTyField(B, DL, WorkerTy,
                LoadSTyField(B, DL, StackFrameTy, SF,
                             StackFrameFieldParent,
                             /*isVolatile=*/false,
                             AtomicOrdering::Unordered),
                LoadSTyField(B, DL, StackFrameTy, SF,
                             StackFrameFieldWorker,
                             /*isVolatile=*/false,
                             AtomicOrdering::Unordered),
                WorkerFieldFrame,
                /*isVolatile=*/false,
                AtomicOrdering::Unordered);

  // sf->call_parent = nullptr;
  StoreSTyField(B, DL, StackFrameTy,
                Constant::getNullValue(PointerType::getUnqual(StackFrameTy)),
                SF, StackFrameFieldParent, /*isVolatile=*/false,
                AtomicOrdering::Release);

  B.CreateRetVoid();

  Fn->setLinkage(Function::AvailableExternallyLinkage);
  Fn->setDoesNotThrow();
  if (!DebugABICalls && !UseExternalABIFunctions)
    Fn->addFnAttr(Attribute::AlwaysInline);

  return Fn;
}

/// Get or create a LLVM function for __cilkrts_detach.  It is equivalent to the
/// following C code:
///
/// void __cilkrts_detach(struct __cilkrts_stack_frame *sf) {
///   struct __cilkrts_worker *w = sf->worker;
///   struct __cilkrts_stack_frame *parent = sf->call_parent;
///   struct __cilkrts_stack_frame *volatile *tail = w->tail;
///
///   StoreStore_fence();
///
///   *tail++ = parent;
///   w->tail = tail;
///
///   sf->flags |= CILK_FRAME_DETACHED;
/// }
Function *OpenCilkABI::Get__cilkrts_detach() {
  // Get or create the __cilkrts_detach function.
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy = Type::getVoidTy(Ctx);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Function *Fn = nullptr;
  if (GetOrCreateFunction(M, "__cilkrts_detach",
                          FunctionType::get(VoidTy, {StackFramePtrTy}, false),
                          Fn)) {
    Fn->setLinkage(Function::AvailableExternallyLinkage);
    Fn->setDoesNotThrow();
    if (!DebugABICalls && !UseExternalABIFunctions)
      Fn->addFnAttr(Attribute::AlwaysInline);
  }

  // Create the body of __cilkrts_detach.
  const DataLayout &DL = M.getDataLayout();

  Function::arg_iterator Args = Fn->arg_begin();
  Value *SF = &*Args;

  BasicBlock *Entry = BasicBlock::Create(Ctx, "entry", Fn);
  IRBuilder<> B(Entry);

  // struct __cilkrts_worker *w = sf->worker;
  Value *W = LoadSTyField(B, DL, StackFrameTy, SF,
                          StackFrameFieldWorker, /*isVolatile=*/false,
                          AtomicOrdering::Unordered);

  // __cilkrts_stack_frame *parent = sf->call_parent;
  Value *Parent = LoadSTyField(B, DL, StackFrameTy, SF,
                               StackFrameFieldParent,
                               /*isVolatile=*/false,
                               AtomicOrdering::Unordered);

  // sf->flags |= CILK_FRAME_DETACHED;
  {
    // This change is not visible until the store-with-release of tail.
    // It may not even need to be volatile.
    Value *F = LoadSTyField(B, DL, StackFrameTy, SF,
                            StackFrameFieldFlags, /*isVolatile=*/false,
                            AtomicOrdering::Unordered);
    F = B.CreateOr(F, ConstantInt::get(F->getType(), CILK_FRAME_DETACHED));
    StoreSTyField(B, DL, StackFrameTy, F, SF,
                  StackFrameFieldFlags, /*isVolatile=*/true,
                  AtomicOrdering::Unordered);
  }

  // __cilkrts_stack_frame *volatile *tail = w->tail;
  Value *Tail = LoadSTyField(B, DL, WorkerTy, W,
                             WorkerFieldTail, /*isVolatile=*/false,
                             AtomicOrdering::Unordered);

  // *tail++ = parent;
  B.CreateStore(Parent, Tail, /*isVolatile=*/false);
  Tail = B.CreateConstGEP1_32(Tail, 1);

  // This store has release ordering to ensure the store above
  // completes before it is published by incrementing tail.
  // w->tail = tail;
  StoreSTyField(B, DL, WorkerTy, Tail, W, WorkerFieldTail,
                /*isVolatile=*/false, AtomicOrdering::Release);

  B.CreateRetVoid();

  Fn->setLinkage(Function::AvailableExternallyLinkage);
  Fn->setDoesNotThrow();
  if (!DebugABICalls && !UseExternalABIFunctions)
    Fn->addFnAttr(Attribute::AlwaysInline);

  return Fn;
}

/// Get or create a LLVM function for __cilk_sync.  Calls to this function are
/// always inlined, as it saves the current stack/frame pointer values. This
/// function must be marked as returns_twice to allow it to be inlined, since
/// the call to setjmp is marked returns_twice.
///
/// It is equivalent to the following C code:
///
/// void __cilk_sync(struct __cilkrts_stack_frame *sf) {
///   if (sf->flags & CILK_FRAME_UNSYNCHED) {
///     SAVE_FLOAT_STATE(*sf);
///     if (!CILK_SETJMP(sf->ctx))
///       __cilkrts_sync(sf);
///     else if (sf->flags & CILK_FRAME_EXCEPTION_PENDING)
///       __cilkrts_check_exception_raise(sf);
///   }
/// }
///
/// With exceptions disabled in the compiler, the function
/// does not call __cilkrts_rethrow()
Function *OpenCilkABI::GetCilkSyncFn() {
  // Get or create the __cilk_sync function.
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy = Type::getVoidTy(Ctx);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Function *Fn = nullptr;
  if (GetOrCreateFunction(M, "__cilk_sync",
                          FunctionType::get(VoidTy, {StackFramePtrTy}, false),
                          Fn))
    return Fn;

  // Create the body of __cilk_sync.
  const DataLayout &DL = M.getDataLayout();

  Function::arg_iterator Args = Fn->arg_begin();
  Value *SF = &*Args;

  BasicBlock *Entry = BasicBlock::Create(Ctx, "cilk.sync.test", Fn);
  BasicBlock *SaveState = BasicBlock::Create(Ctx, "cilk.sync.savestate", Fn);
  BasicBlock *SyncCall = BasicBlock::Create(Ctx, "cilk.sync.runtimecall", Fn);
  BasicBlock *ExnCheck = BasicBlock::Create(Ctx, "cilk.sync.exn.check", Fn);
  BasicBlock *Rethrow = BasicBlock::Create(Ctx, "cilk.sync.rethrow", Fn);
  BasicBlock *Exit = BasicBlock::Create(Ctx, "cilk.sync.end", Fn);

  // Entry
  {
    IRBuilder<> B(Entry);

    // JFC: I removed Acquire here.  The runtime has a fence in any path
    // between setting and reading the bit.  The compiler should know that
    // memory changes at the setjmp that precedes this test.
    // if (sf->flags & CILK_FRAME_UNSYNCHED)
    Value *Flags = LoadSTyField(B, DL, StackFrameTy, SF,
                                StackFrameFieldFlags, /*isVolatile=*/false,
                                AtomicOrdering::Unordered);
    Flags = B.CreateAnd(Flags,
                        ConstantInt::get(Flags->getType(),
                                         CILK_FRAME_UNSYNCHED));
    Value *Zero = ConstantInt::get(Flags->getType(), 0);
    Value *Unsynced = B.CreateICmpEQ(Flags, Zero);
    B.CreateCondBr(Unsynced, Exit, SaveState);
  }

  // SaveState
  {
    IRBuilder<> B(SaveState);

    // if (!CILK_SETJMP(sf.ctx))
    Value *C = EmitCilkSetJmp(B, SF);
    C = B.CreateICmpEQ(C, ConstantInt::get(C->getType(), 0));
    // B.CreateCondBr(C, SyncCall, Exit);
    B.CreateCondBr(C, SyncCall, ExnCheck);
  }

  // SyncCall
  {
    IRBuilder<> B(SyncCall);

    // __cilkrts_sync(&sf);
    B.CreateCall(CILKRTS_FUNC(sync), SF);
    // B.CreateBr(Exit);
    B.CreateBr(ExnCheck);
  }

  // Excepting
  {
    IRBuilder<> B(ExnCheck);
    Value *Flags = LoadSTyField(B, DL, StackFrameTy, SF,
                                StackFrameFieldFlags,
                                /*isVolatile=*/false,
                                AtomicOrdering::Unordered);
    Flags = B.CreateAnd(Flags,
                        ConstantInt::get(Flags->getType(),
                                         CILK_FRAME_EXCEPTION_PENDING));
    Value *Zero = ConstantInt::get(Flags->getType(), 0);
    Value *HasNoException = B.CreateICmpEQ(Flags, Zero);
    B.CreateCondBr(HasNoException, Exit, Rethrow);
  }

  // Rethrow
  {
    IRBuilder<> B(Rethrow);
    // __cilkrts_check_exception_raise(sf);
    B.CreateCall(CILKRTS_FUNC(check_exception_raise), {SF});
    // B.CreateUnreachable();
    B.CreateBr(Exit);
  }

  // Exit
  {
    IRBuilder<> B(Exit);
    B.CreateRetVoid();
  }

  Fn->setLinkage(Function::AvailableExternallyLinkage);
  Fn->addFnAttr(Attribute::ReturnsTwice);
  if (!DebugABICalls)
    Fn->addFnAttr(Attribute::AlwaysInline);

  return Fn;
}

/// Get or create a LLVM function for __cilk_sync_nothrow.  Calls to this
/// function are always inlined, as it saves the current stack/frame pointer
/// values. This function must be marked as returns_twice to allow it to be
/// inlined, since the call to setjmp is marked returns_twice.
///
/// It is equivalent to the following C code:
///
/// void __cilk_sync_nothrow(struct __cilkrts_stack_frame *sf) {
///   if (sf->flags & CILK_FRAME_UNSYNCHED) {
///     SAVE_FLOAT_STATE(*sf);
///     if (!CILK_SETJMP(sf->ctx))
///       __cilkrts_sync(sf);
///   }
/// }
///
/// With exceptions disabled in the compiler, the function
/// does not call __cilkrts_rethrow()
Function *OpenCilkABI::GetCilkSyncNoThrowFn() {
  // Get or create the __cilk_sync_nothrow function.
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy = Type::getVoidTy(Ctx);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Function *Fn = nullptr;
  if (GetOrCreateFunction(M, "__cilk_sync_nothrow",
                          FunctionType::get(VoidTy, {StackFramePtrTy}, false),
                          Fn))
    return Fn;

  // Create the body of __cilk_sync.
  const DataLayout &DL = M.getDataLayout();

  Function::arg_iterator Args = Fn->arg_begin();
  Value *SF = &*Args;

  BasicBlock *Entry = BasicBlock::Create(Ctx, "cilk.sync.test", Fn);
  BasicBlock *SaveState = BasicBlock::Create(Ctx, "cilk.sync.savestate", Fn);
  BasicBlock *SyncCall = BasicBlock::Create(Ctx, "cilk.sync.runtimecall", Fn);
  BasicBlock *Exit = BasicBlock::Create(Ctx, "cilk.sync.end", Fn);

  // Entry
  {
    IRBuilder<> B(Entry);

    // JFC: I removed Acquire here.  The runtime has a fence in any path
    // between setting and reading the bit.  The compiler should know that
    // memory changes at the setjmp that precedes this test.
    // if (sf->flags & CILK_FRAME_UNSYNCHED)
    Value *Flags = LoadSTyField(B, DL, StackFrameTy, SF,
                                StackFrameFieldFlags, /*isVolatile=*/false,
                                AtomicOrdering::Unordered);
    Flags = B.CreateAnd(Flags,
                        ConstantInt::get(Flags->getType(),
                                         CILK_FRAME_UNSYNCHED));
    Value *Zero = ConstantInt::get(Flags->getType(), 0);
    Value *Unsynced = B.CreateICmpEQ(Flags, Zero);
    B.CreateCondBr(Unsynced, Exit, SaveState);
  }

  // SaveState
  {
    IRBuilder<> B(SaveState);

    // if (!CILK_SETJMP(sf.ctx))
    Value *C = EmitCilkSetJmp(B, SF);
    C = B.CreateICmpEQ(C, ConstantInt::get(C->getType(), 0));
    B.CreateCondBr(C, SyncCall, Exit);
  }

  // SyncCall
  {
    IRBuilder<> B(SyncCall);

    // __cilkrts_sync(&sf);
    B.CreateCall(CILKRTS_FUNC(sync), SF);
    B.CreateBr(Exit);
  }

  // Exit
  {
    IRBuilder<> B(Exit);
    B.CreateRetVoid();
  }

  Fn->setLinkage(Function::AvailableExternallyLinkage);
  Fn->addFnAttr(Attribute::ReturnsTwice);
  if (!DebugABICalls)
    Fn->addFnAttr(Attribute::AlwaysInline);

  return Fn;
}

/// Get or create a LLVM function for __cilk_pause_frame. Calls to this function
/// uRways inlined, as it saves the current stack/frame pointer values. This
/// function must be marked as returns_twice to allow it to be inlined, since
/// the call to setjmp is marked returns_twice.
///
/// It is equivalent to the following C code:
///
/// void __cilk_pause_frame(struct __cilkrts_stack_frame *sf) {
///   if (!CILK_SETJMP(sf->ctx))
///     __cilkrts_pause_frame(sf);
///   __cilkrts_check_exception_resume(sf);
/// }
///
/// With exceptions disabled in the compiler, the function
/// does not call __cilkrts_rethrow()
Function *OpenCilkABI::GetCilkPauseFrameFn() {
  // Get or create the __cilk_sync function.
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy = Type::getVoidTy(Ctx);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  PointerType *ExnPtrTy = Type::getInt8PtrTy(Ctx);
  Function *Fn = nullptr;
  if (GetOrCreateFunction(M, "__cilk_pause_frame",
                          FunctionType::get(VoidTy, {StackFramePtrTy, ExnPtrTy}, false),
                          Fn))
    return Fn;

  // Create the body of __cilk_pause_frame.
  Function::arg_iterator Args = Fn->arg_begin();
  Value *SF = &*Args;
  ++Args;
  Value *Exn = &*Args;

  BasicBlock *Entry = BasicBlock::Create(Ctx, "cilk.pause.frame.test", Fn);
  BasicBlock *PauseFrameCall = BasicBlock::Create(Ctx, "cilk.pause.frame.runtimecall", Fn);
  BasicBlock *Exit = BasicBlock::Create(Ctx, "cilk.pause.frame.end", Fn);

  // Entry
  {
    IRBuilder<> B(Entry);

    // if (!CILK_SETJMP(sf.ctx))
    Value *C = EmitCilkSetJmp(B, SF);
    C = B.CreateICmpEQ(C, ConstantInt::get(C->getType(), 0));
    B.CreateCondBr(C, PauseFrameCall, Exit);
  }

  // PauseFrameCall
  {
    IRBuilder<> B(PauseFrameCall);

    // __cilkrts_pause_frame(&sf, &exn);
    B.CreateCall(CILKRTS_FUNC(pause_frame), {SF, Exn});
    B.CreateBr(Exit);
  }

  // Exit
  {
    IRBuilder<> B(Exit);

    //B.CreateCall(CILKRTS_FUNC(check_exception_resume), {SF});
    B.CreateRetVoid();
  }

  Fn->setLinkage(Function::InternalLinkage);
  Fn->addFnAttr(Attribute::AlwaysInline);
  Fn->addFnAttr(Attribute::ReturnsTwice);

  return Fn;
}


/// Get or create a LLVM function for __cilkrts_enter_frame.  It is equivalent
/// to the following C code:
///
/// void __cilkrts_enter_frame(struct __cilkrts_stack_frame *sf)
/// {
///     struct __cilkrts_worker *w = __cilkrts_get_tls_worker();
///     // if (w == 0) { /* slow path, rare */
///     //     w = __cilkrts_bind_thread_1();
///     //     sf->flags = CILK_FRAME_LAST | CILK_FRAME_VERSION;
///     // } else {
///         sf->flags = CILK_FRAME_VERSION;
///     // }
///     sf->call_parent = w->current_stack_frame;
///     sf->worker = w;
///     /* sf->except_data is only valid when CILK_FRAME_EXCEPTING is set */
///     w->current_stack_frame = sf;
/// }
Function *OpenCilkABI::Get__cilkrts_enter_frame() {
  // Get or create the __cilkrts_enter_frame function.
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy = Type::getVoidTy(Ctx);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Function *Fn = nullptr;
  // NOTE(TFK): If the function was imported from the opencilk bitcode file
  //            then it will not have the requisite attributes. It is perhaps
  //            better to set these attributes when creating the opencilk bitcode
  //            file... for now I set them here.
  if (GetOrCreateFunction(M, "__cilkrts_enter_frame",
                          FunctionType::get(VoidTy, {StackFramePtrTy}, false),
                          Fn)) {
    Fn->setLinkage(Function::AvailableExternallyLinkage);
    Fn->setDoesNotThrow();
    if (!DebugABICalls && !UseExternalABIFunctions)
      Fn->addFnAttr(Attribute::AlwaysInline);
    return Fn;
  }
  //assert(false && "We should've used the existing enter_frame function here...\n");
  // Create the body of __cilkrts_enter_frame.
  const DataLayout &DL = M.getDataLayout();

  Function::arg_iterator Args = Fn->arg_begin();
  Value *SF = &*Args;

  BasicBlock *Entry = BasicBlock::Create(Ctx, "entry", Fn);
  // BasicBlock *SlowPath = BasicBlock::Create(Ctx, "slowpath", Fn);
  BasicBlock *FastPath = BasicBlock::Create(Ctx, "fastpath", Fn);
  BasicBlock *Cont = BasicBlock::Create(Ctx, "cont", Fn);

  PointerType *WorkerPtrTy = PointerType::getUnqual(WorkerTy);
  StructType *SFTy = StackFrameTy;

  // Block  (Entry)
  CallInst *W = nullptr;
  {
    IRBuilder<> B(Entry);
    // struct __cilkrts_worker *w = __cilkrts_get_tls_worker();
    W = B.CreateCall(CILKRTS_FUNC(get_tls_worker));

    // // if (w == 0)
    // Value *Cond = B.CreateICmpEQ(W, ConstantPointerNull::get(WorkerPtrTy));
    // B.CreateCondBr(Cond, SlowPath, FastPath);
    B.CreateBr(FastPath);
  }
  // // Block  (SlowPath)
  // CallInst *Wslow = nullptr;
  // {
  //   IRBuilder<> B(SlowPath);
  //   // w = __cilkrts_bind_thread_1();
  //   Wslow = B.CreateCall(CILKRTS_FUNC(bind_thread_1));
  //   // sf->flags = CILK_FRAME_LAST | CILK_FRAME_VERSION;
  //   Type *Ty = SFTy->getElementType(StackFrameFieldFlags);
  //   StoreSTyField(B, DL, StackFrameTy,
  //                 ConstantInt::get(Ty, CILK_FRAME_LAST | CILK_FRAME_VERSION),
  //                 SF, StackFrameFieldFlags, /*isVolatile=*/false,
  //                 AtomicOrdering::Release);
  //   B.CreateBr(Cont);
  // }
  // Block  (FastPath)
  {
    IRBuilder<> B(FastPath);
    // sf->flags = 0
    // sf->magic = (magic)
    Type *Ty = SFTy->getElementType(StackFrameFieldFlags);
    StoreSTyField(B, DL, StackFrameTy,
                  ConstantInt::get(Ty, 0),
                  SF, StackFrameFieldFlags, /*isVolatile=*/false,
                  AtomicOrdering::Unordered);
    if (StackFrameFieldMagic >= 0) {
      StoreSTyField(B, DL, StackFrameTy,
		    ConstantInt::get(Ty, FrameMagic),
		    SF, StackFrameFieldMagic, /*isVolatile=*/false,
		    AtomicOrdering::Unordered);
    }
    B.CreateBr(Cont);
  }
  // Block  (Cont)
  {
    IRBuilder<> B(Cont);
    // Value *Wfast = W;
    // PHINode *W  = B.CreatePHI(WorkerPtrTy, 2);
    // W->addIncoming(Wslow, SlowPath);
    // W->addIncoming(Wfast, FastPath);
    Value *Wkr = B.CreatePointerCast(W, WorkerPtrTy);
    // sf->call_parent = w->current_stack_frame;
    StoreSTyField(B, DL, StackFrameTy,
                  LoadSTyField(B, DL, WorkerTy, Wkr,
                               WorkerFieldFrame,
                               /*isVolatile=*/false,
                               AtomicOrdering::Unordered),
                  SF, StackFrameFieldParent, /*isVolatile=*/false,
                  AtomicOrdering::Unordered);
    // sf->worker = w;
    StoreSTyField(B, DL, StackFrameTy, Wkr, SF,
                  StackFrameFieldWorker, /*isVolatile=*/false,
                  AtomicOrdering::Unordered);
    // w->current_stack_frame = sf;
    StoreSTyField(B, DL, WorkerTy, SF, Wkr,
                  WorkerFieldFrame, /*isVolatile=*/false,
                  AtomicOrdering::Release);

    B.CreateRetVoid();
  }

  Fn->setLinkage(Function::AvailableExternallyLinkage);
  Fn->setDoesNotThrow();
  if (!DebugABICalls && !UseExternalABIFunctions)
    Fn->addFnAttr(Attribute::AlwaysInline);

  return Fn;
}

/// Get or create a LLVM function for __cilkrts_enter_frame_fast.  It is
/// equivalent to the following C code:
///
/// void __cilkrts_enter_frame_fast(struct __cilkrts_stack_frame *sf)
/// {
///     struct __cilkrts_worker *w = __cilkrts_get_tls_worker();
///     sf->flags = CILK_FRAME_VERSION;
///     sf->call_parent = w->current_stack_frame;
///     sf->worker = w;
///     /* sf->except_data is only valid when CILK_FRAME_EXCEPTING is set */
///     w->current_stack_frame = sf;
/// }
Function *OpenCilkABI::Get__cilkrts_enter_frame_fast() {
  // Get or create the __cilkrts_enter_frame_fast function.
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy = Type::getVoidTy(Ctx);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Function *Fn = nullptr;
  // NOTE(TFK): If the function was imported from the opencilk bitcode file
  //            then it will not have the requisite attributes. It is perhaps
  //            better to set these attributes when creating the opencilk bitcode
  //            file... for now I set them here.
  if (GetOrCreateFunction(M, "__cilkrts_enter_frame_fast",
                          FunctionType::get(VoidTy, {StackFramePtrTy}, false),
                          Fn)) {
    Fn->setLinkage(Function::AvailableExternallyLinkage);
    Fn->setDoesNotThrow();
    if (!DebugABICalls && !UseExternalABIFunctions)
      Fn->addFnAttr(Attribute::AlwaysInline);
    return Fn;
  }

  // Create the body of __cilkrts_enter_frame_fast.
  const DataLayout &DL = M.getDataLayout();

  Function::arg_iterator Args = Fn->arg_begin();
  Value *SF = &*Args;

  BasicBlock *Entry = BasicBlock::Create(Ctx, "entry", Fn);

  IRBuilder<> B(Entry);
  Value *W;

  // struct __cilkrts_worker *w = __cilkrts_get_tls_worker();
  // if (fastCilk)
  //   W = B.CreateCall(CILKRTS_FUNC(get_tls_worker_fast));
  // else
    W = B.CreateCall(CILKRTS_FUNC(get_tls_worker));

  StructType *SFTy = StackFrameTy;
  Type *Ty = SFTy->getElementType(StackFrameFieldFlags);

  // sf->flags = 0
  StoreSTyField(B, DL, StackFrameTy,
                ConstantInt::get(Ty, 0),
                SF, StackFrameFieldFlags, /*isVolatile=*/false,
                AtomicOrdering::Unordered);
  // sf->magic = (magic)
    StoreSTyField(B, DL, StackFrameTy,
                ConstantInt::get(Ty, FrameMagic),
                SF, StackFrameFieldMagic, /*isVolatile=*/false,
                AtomicOrdering::Unordered);
  // sf->call_parent = w->current_stack_frame;
  StoreSTyField(B, DL, StackFrameTy,
                LoadSTyField(B, DL, WorkerTy, W,
                             WorkerFieldFrame,
                             /*isVolatile=*/false,
                             AtomicOrdering::Unordered),
                SF, StackFrameFieldParent, /*isVolatile=*/false,
                AtomicOrdering::Unordered);
  // sf->worker = w;
  StoreSTyField(B, DL, StackFrameTy, W, SF, StackFrameFieldWorker,
                /*isVolatile=*/false, AtomicOrdering::Unordered);
  // w->current_stack_frame = sf;
  StoreSTyField(B, DL, WorkerTy, SF, W, WorkerFieldFrame, /*isVolatile=*/false,
                AtomicOrdering::Release);

  B.CreateRetVoid();

  Fn->setLinkage(Function::AvailableExternallyLinkage);
  Fn->setDoesNotThrow();
  if (!DebugABICalls && !UseExternalABIFunctions)
    Fn->addFnAttr(Attribute::AlwaysInline);

  return Fn;
}

/// Get or create a LLVM function for __cilk_parent_epilogue.  It is equivalent
/// to the following C code:
///
/// void __cilk_parent_epilogue(__cilkrts_stack_frame *sf) {
///   __cilkrts_pop_frame(sf);
///   if (sf->flags != CILK_FRAME_VERSION)
///     __cilkrts_leave_frame(sf);
/// }
Function *OpenCilkABI::GetCilkParentEpilogueFn() {
  // Get or create the __cilk_parent_epilogue function.
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy = Type::getVoidTy(Ctx);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Function *Fn = nullptr;
  if (GetOrCreateFunction(M, "__cilk_parent_epilogue",
                          FunctionType::get(VoidTy, {StackFramePtrTy}, false),
                          Fn))
    return Fn;

  // Create the body of __cilk_parent_epilogue.
  const DataLayout &DL = M.getDataLayout();

  Function::arg_iterator Args = Fn->arg_begin();
  Value *SF = &*Args;

  BasicBlock *Entry = BasicBlock::Create(Ctx, "entry", Fn),
    *B1 = BasicBlock::Create(Ctx, "body", Fn),
    *Exit  = BasicBlock::Create(Ctx, "exit", Fn);
  CallInst *PopFrame;

  // Entry
  {
    IRBuilder<> B(Entry);

    // __cilkrts_pop_frame(sf)
    PopFrame = B.CreateCall(CILKRTS_FUNC(pop_frame), SF);

    // JFC: I removed AtomicOrdering::Acquire here.  If flags have been
    // changed at least one change was in this function.
    // if (sf->flags != CILK_FRAME_VERSION)
    Value *Flags = LoadSTyField(B, DL, StackFrameTy, SF,
                                StackFrameFieldFlags, /*isVolatile=*/false,
                                AtomicOrdering::Unordered);
    Value *Cond = B.CreateICmpNE(Flags, ConstantInt::get(Flags->getType(), 0));
    B.CreateCondBr(Cond, B1, Exit);
  }

  // B1
  {
    IRBuilder<> B(B1);

    // __cilkrts_leave_frame(sf);
    B.CreateCall(CILKRTS_FUNC(leave_frame), SF);
    B.CreateBr(Exit);
  }

  // Exit
  {
    IRBuilder<> B(Exit);
    B.CreateRetVoid();
  }

  // Inline the pop_frame call.
  if (!DebugABICalls && !UseExternalABIFunctions)
    CallsToInline.insert(PopFrame);

  Fn->setLinkage(Function::AvailableExternallyLinkage);
  Fn->setDoesNotThrow();
  if (!DebugABICalls)
    Fn->addFnAttr(Attribute::AlwaysInline);

  return Fn;
}

static const StringRef stack_frame_name = "__cilkrts_sf";

/// Create the __cilkrts_stack_frame for the spawning function.
AllocaInst *OpenCilkABI::CreateStackFrame(Function &F) {
  const DataLayout &DL = F.getParent()->getDataLayout();
  Type *SFTy = StackFrameTy;

  IRBuilder<> B(&*F.getEntryBlock().getFirstInsertionPt());
  AllocaInst *SF = B.CreateAlloca(SFTy, DL.getAllocaAddrSpace(),
                                  /*ArraySize*/nullptr,
                                  /*Name*/stack_frame_name);
  SF->setAlignment(Align(8));

  return SF;
}

Value* OpenCilkABI::GetOrCreateCilkStackFrame(Function &F) {
  if (DetachCtxToStackFrame.count(&F))
    return DetachCtxToStackFrame[&F];

  AllocaInst *SF = CreateStackFrame(F);
  DetachCtxToStackFrame[&F] = SF;

  return SF;
}

void OpenCilkABI::InsertDetach(Function &F, Instruction *DetachPt) {
  /*
    __cilkrts_stack_frame sf;
    ...
    __cilkrts_detach(sf);
    *x = f(y);
  */

  AllocaInst *SF = cast<AllocaInst>(GetOrCreateCilkStackFrame(F));
  assert(SF && "No Cilk stack frame for Cilk function.");
  Value *Args[1] = { SF };

  // Scan function to see if it detaches.
  LLVM_DEBUG({
      bool SimpleHelper = !canDetach(&F);
      if (!SimpleHelper)
        dbgs() << "NOTE: Detachable helper function itself detaches.\n";
    });

  // Call __cilkrts_detach
  IRBuilder<> IRB(DetachPt);
  IRB.CreateCall(CILKRTS_FUNC(detach), Args);
}

CallInst *OpenCilkABI::InsertStackFramePush(Function &F,
                                         Instruction *TaskFrameCreate,
                                         bool Helper) {
  AllocaInst *SF = cast<AllocaInst>(GetOrCreateCilkStackFrame(F));

  BasicBlock::iterator InsertPt = ++SF->getIterator();
  IRBuilder<> IRB(&(F.getEntryBlock()), InsertPt);
  if (TaskFrameCreate)
    IRB.SetInsertPoint(TaskFrameCreate);

  Value *Args[1] = { SF };
  if (Helper)
    return IRB.CreateCall(CILKRTS_FUNC(enter_frame_fast), Args);
  else
    return IRB.CreateCall(CILKRTS_FUNC(enter_frame), Args);
}

void OpenCilkABI::InsertStackFramePop(Function &F, bool PromoteCallsToInvokes,
                                   bool InsertPauseFrame, bool Helper) {
  Value *SF = GetOrCreateCilkStackFrame(F);
  SmallPtrSet<ReturnInst*, 8> Returns;
  SmallPtrSet<ResumeInst*, 8> Resumes;

  // Add eh cleanup that returns control to the runtime
  EscapeEnumerator EE(F, "cilkrabi_cleanup", PromoteCallsToInvokes);
  while (IRBuilder<> *Builder = EE.Next()) {
    if (ResumeInst *RI = dyn_cast<ResumeInst>(Builder->GetInsertPoint())) {
      Resumes.insert(RI);
    } else if (ReturnInst *RI = dyn_cast<ReturnInst>(Builder->GetInsertPoint())) {
      Returns.insert(RI);
    }
  }

  for (ReturnInst *RI : Returns) {
    if (Helper) {
      CallInst::Create(CILKRTS_FUNC(pop_frame), {SF}, "", RI);
      CallInst::Create(CILKRTS_FUNC(leave_frame), {SF}, "", RI);
    } else {
      CallInst::Create(GetCilkParentEpilogueFn(), {SF}, "", RI);
    }
  }
  for (ResumeInst *RI : Resumes) {
    if (InsertPauseFrame) {
      Value *Exn = ExtractValueInst::Create(RI->getValue(), { 0 }, "", RI);
      CallInst::Create(CILKRTS_FUNC(pop_frame), {SF}, "", RI);
      // If throwing an exception, store the exception object and selector value
      // in the closure, call setjmp, and call pause_frame.
      CallInst::Create(GetCilkPauseFrameFn(), {SF, Exn}, "", RI);
      // CallInst::Create(CILKRTS_FUNC(leave_frame), {SF}, "", RI);
    // } else {
    //   CallInst::Create(CILKRTS_FUNC(pop_frame), {SF}, "", RI);
    //   CallInst::Create(CILKRTS_FUNC(leave_frame), {SF}, "", RI);
    }
  }
}

void OpenCilkABI::MarkSpawner(Function &F) {
  // If the spawner F might throw, then we mark F with the Cilk personality
  // function, which ensures that the Cilk stack frame of F is properly unwound.
  if (!F.doesNotThrow()) {
    LLVMContext &C = M.getContext();
    // Get the type of the Cilk personality function the same way that clang and
    // EscapeEnumerator get the type of a personality function.
    Function *Personality = cast<Function>(
        M.getOrInsertFunction("__cilk_personality_v0",
                              FunctionType::get(Type::getInt32Ty(C), true))
        .getCallee());
    F.setPersonalityFn(Personality);
  }

  // Mark this function as stealable.
  F.addFnAttr(Attribute::Stealable);
}

/// Lower a call to get the grainsize of this Tapir loop.
///
/// The grainsize is computed by the following equation:
///
///     Grainsize = min(2048, ceil(Limit / (8 * workers)))
///
/// This computation is inserted into the preheader of the loop.
Value *OpenCilkABI::lowerGrainsizeCall(CallInst *GrainsizeCall) {
  Value *Limit = GrainsizeCall->getArgOperand(0);
  IRBuilder<> Builder(GrainsizeCall);

  // Get 8 * workers
  Value *Workers = Builder.CreateCall(CILKRTS_FUNC(get_nworkers));
  Value *WorkersX8 = Builder.CreateIntCast(
      Builder.CreateMul(Workers, ConstantInt::get(Workers->getType(), 8)),
      Limit->getType(), false);
  // Compute ceil(limit / 8 * workers) =
  //           (limit + 8 * workers - 1) / (8 * workers)
  Value *SmallLoopVal =
    Builder.CreateUDiv(Builder.CreateSub(Builder.CreateAdd(Limit, WorkersX8),
                                         ConstantInt::get(Limit->getType(), 1)),
                       WorkersX8);
  // Compute min
  Value *LargeLoopVal = ConstantInt::get(Limit->getType(), 2048);
  Value *Cmp = Builder.CreateICmpULT(LargeLoopVal, SmallLoopVal);
  Value *Grainsize = Builder.CreateSelect(Cmp, LargeLoopVal, SmallLoopVal);

  // Replace uses of grainsize intrinsic call with this grainsize value.
  GrainsizeCall->replaceAllUsesWith(Grainsize);
  return Grainsize;
}

void OpenCilkABI::lowerSync(SyncInst &SI) {
  Function &Fn = *SI.getFunction();
  if (!DetachCtxToStackFrame[&Fn])
    // If we have not created a stackframe for this function, then we don't need
    // to handle the sync.
    return;

  Value *SF = GetOrCreateCilkStackFrame(Fn);
  Value *Args[] = { SF };
  assert(Args[0] && "sync used in function without frame!");

  Instruction *SyncUnwind = nullptr;
  BasicBlock *SyncCont = SI.getSuccessor(0);
  BasicBlock *SyncUnwindDest = nullptr;
  if (InvokeInst *II =
      dyn_cast<InvokeInst>(SyncCont->getFirstNonPHIOrDbgOrLifetime())) {
    if (const Function *Called = II->getCalledFunction()) {
      if (Intrinsic::sync_unwind == Called->getIntrinsicID()) {
        SyncUnwind = II;
        SyncCont = II->getNormalDest();
        SyncUnwindDest = II->getUnwindDest();
      }
    }
  }

  CallBase *CB;
  if (!SyncUnwindDest) {
    if (Fn.doesNotThrow())
      CB = CallInst::Create(GetCilkSyncNoThrowFn(), Args, "",
                            /*insert before*/&SI);
    else
      CB = CallInst::Create(GetCilkSyncFn(), Args, "", /*insert before*/&SI);

    BranchInst::Create(SyncCont, CB->getParent());
  } else {
    CB = InvokeInst::Create(GetCilkSyncFn(), SyncCont, SyncUnwindDest, Args, "",
                            /*insert before*/&SI);
    for (PHINode &PN : SyncCont->phis())
      PN.addIncoming(PN.getIncomingValueForBlock(SyncUnwind->getParent()),
                     SI.getParent());
    for (PHINode &PN : SyncUnwindDest->phis())
      PN.addIncoming(PN.getIncomingValueForBlock(SyncUnwind->getParent()),
                     SI.getParent());
  }
  CB->setDebugLoc(SI.getDebugLoc());
  SI.eraseFromParent();

  // Remember to inline this call later.
  CallsToInline.insert(CB);

  // Mark this function as stealable.
  Fn.addFnAttr(Attribute::Stealable);
}

void OpenCilkABI::preProcessOutlinedTask(Function &F, Instruction *DetachPt,
                                      Instruction *TaskFrameCreate,
                                      bool IsSpawner) {
  // If the outlined task F itself performs spawns, set up F to support stealing
  // continuations.
  if (IsSpawner)
    MarkSpawner(F);

  CallInst *EnterFrame =
      InsertStackFramePush(F, TaskFrameCreate, /*Helper*/false);
  InsertDetach(F, (DetachPt ? DetachPt : &*(++EnterFrame->getIterator())));
}

void OpenCilkABI::postProcessOutlinedTask(Function &F, Instruction *DetachPt,
                                       Instruction *TaskFrameCreate,
                                       bool IsSpawner) {
  // Because F is a spawned task, we want to insert landingpads for all calls
  // that can throw, so we can pop the stackframe correctly if they do throw.
  // In particular, popping the stackframe of a spawned task may discover that
  // the parent was stolen, in which case we want to save the exception for
  // later reduction.
  InsertStackFramePop(F, /*PromoteCallsToInvokes*/true,
                      /*InsertPauseFrame*/true, /*Helper*/true);

  // TODO: If F is itself a spawner, see if we need to ensure that the Cilk
  // personality function does not pop an already-popped frame.  We might be
  // able to do this by checking if sf->call_parent == NULL before performing a
  // pop in the personality function.
}

void OpenCilkABI::preProcessRootSpawner(Function &F) {
  MarkSpawner(F);
  InsertStackFramePush(F);
  Value *SF = DetachCtxToStackFrame[&F];
  for (BasicBlock &BB : F) {
    if (BB.isLandingPad()) {
      LandingPadInst *LPad = BB.getLandingPadInst();
      Instruction *InsertPt = &*BB.getFirstInsertionPt();
      IRBuilder<> Builder(InsertPt);

      Value *Sel = Builder.CreateExtractValue(LPad, 1, "sel");
      CallInst *SetjmpCall = EmitCilkSetJmp(Builder, SF);

      Value *Cond = Builder.CreateICmpEQ(
          SetjmpCall, ConstantInt::get(SetjmpCall->getType(), 0));
      Instruction *ThenTerm = SplitBlockAndInsertIfThen(Cond, InsertPt, false);
      Builder.SetInsertPoint(ThenTerm);
      Builder.CreateCall(CILKRTS_FUNC(cleanup_fiber), {SF, Sel});
    }
  }
}

void OpenCilkABI::postProcessRootSpawner(Function &F) {
  // F is a root spawner, not itself a spawned task.  We don't need to promote
  // calls to invokes, since the Cilk personality function will take care of
  // popping the frame if no landingpad exists for a given call.
  InsertStackFramePop(F, /*PromoteCallsToInvokes*/false,
                      /*InsertPauseFrame*/false, /*Helper*/false);
}

void OpenCilkABI::processSubTaskCall(TaskOutlineInfo &TOI, DominatorTree &DT) {
  Instruction *ReplStart = TOI.ReplStart;
  Instruction *ReplCall = TOI.ReplCall;

  Function &F = *ReplCall->getFunction();
  Value *SF = DetachCtxToStackFrame[&F];
  assert(SF && "No frame found for spawning task");

  // Split the basic block containing the detach replacement just before the
  // start of the detach-replacement instructions.
  BasicBlock *DetBlock = ReplStart->getParent();
  BasicBlock *CallBlock = SplitBlock(DetBlock, ReplStart, &DT);

  // Emit a Cilk setjmp at the end of the block preceding the split-off detach
  // replacement.
  Instruction *SetJmpPt = DetBlock->getTerminator();
  IRBuilder<> B(SetJmpPt);
  Value *SetJmpRes = EmitCilkSetJmp(B, SF);

  // Get the ordinary continuation of the detach.
  BasicBlock *CallCont;
  if (InvokeInst *II = dyn_cast<InvokeInst>(ReplCall))
    CallCont = II->getNormalDest();
  else // isa<CallInst>(CallSite)
    CallCont = CallBlock->getSingleSuccessor();

  // Insert a conditional branch, based on the result of the setjmp, to either
  // the detach replacement or the continuation.
  SetJmpRes = B.CreateICmpEQ(SetJmpRes,
                             ConstantInt::get(SetJmpRes->getType(), 0));
  B.CreateCondBr(SetJmpRes, CallBlock, CallCont);
  for (PHINode &PN : CallCont->phis())
    PN.addIncoming(PN.getIncomingValueForBlock(CallBlock), DetBlock);

  SetJmpPt->eraseFromParent();
}

// Helper function to inline calls to compiler-generated Cilk Plus runtime
// functions when possible.  This inlining is necessary to properly implement
// some Cilk runtime "calls," such as __cilk_sync().
static inline void inlineCilkFunctions(
    Function &F, SmallPtrSetImpl<CallBase *> &CallsToInline) {
  for (CallBase *CB : CallsToInline) {
    InlineFunctionInfo IFI;
    InlineFunction(CB, IFI);
  }
  CallsToInline.clear();
}

void OpenCilkABI::preProcessFunction(Function &F, TaskInfo &TI,
                                  bool OutliningTapirLoops) {
  if (OutliningTapirLoops)
    // Don't do any preprocessing when outlining Tapir loops.
    return;

  if (F.getName() == "main")
    F.setName("cilk_main");
}

void OpenCilkABI::postProcessFunction(Function &F, bool OutliningTapirLoops) {
  if (OutliningTapirLoops)
    // Don't do any postprocessing when outlining Tapir loops.
    return;

  if (!DebugABICalls)
    inlineCilkFunctions(F, CallsToInline);
}

void OpenCilkABI::postProcessHelper(Function &F) {}

LoopOutlineProcessor *OpenCilkABI::getLoopOutlineProcessor(
    const TapirLoopInfo *TL) const {
  if (UseRuntimeCilkFor)
    return new RuntimeCilkFor(M);
  return nullptr;
}
