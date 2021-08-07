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
#include "llvm/IR/DebugInfo.h"
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

using namespace llvm;

#define DEBUG_TYPE "opencilk"

extern cl::opt<bool> DebugABICalls;

static cl::opt<bool> UseOpenCilkRuntimeBC(
    "use-opencilk-runtime-bc", cl::init(true),
    cl::desc("Use a bitcode file for the OpenCilk runtime ABI"), cl::Hidden);
static cl::opt<std::string> OpenCilkRuntimeBCPath(
    "opencilk-runtime-bc-path", cl::init(""),
    cl::desc("Path to the bitcode file for the OpenCilk runtime ABI"),
    cl::Hidden);

#define CILKRTS_FUNC(name) Get__cilkrts_##name()

static const StringRef StackFrameName = "__cilkrts_sf";

OpenCilkABI::OpenCilkABI(Module &M) : TapirTarget(M) {}

// Helper function to fix the implementation of __cilk_sync.  In particular,
// this fixup ensures that __cilk_sync, and specific __cilkrts method calls
// therein, appear that they may throw an exception.  Since the bitcode-ABI file
// is built from C code, it won't necessarily be marked appropriately for
// exception handling.
static void fixCilkSyncFn(Module &M, Function *Fn) {
  Fn->removeFnAttr(Attribute::NoUnwind);
  Function *ExceptionRaiseFn = M.getFunction("__cilkrts_check_exception_raise");
  Function *ExceptionResumeFn = M.getFunction("__cilkrts_check_exception_resume");
  for (Instruction &I : instructions(Fn))
    if (CallBase *CB = dyn_cast<CallBase>(&I))
      if (CB->getCalledFunction() == ExceptionRaiseFn ||
          CB->getCalledFunction() == ExceptionResumeFn)
        CB->removeAttribute(AttributeList::FunctionIndex, Attribute::NoUnwind);
}

// Structure recording information about Cilk ABI functions.
struct CilkRTSFnDesc {
  StringRef FnName;
  FunctionType *FnType;
  FunctionCallee &FnCallee;
};

void OpenCilkABI::prepareModule() {
  LLVMContext &C = M.getContext();
  Type *Int8Ty = Type::getInt8Ty(C);
  Type *Int16Ty = Type::getInt16Ty(C);
  Type *Int32Ty = Type::getInt32Ty(C);
  Type *Int64Ty = Type::getInt64Ty(C);

  if (UseOpenCilkRuntimeBC) {
    if ("" == OpenCilkRuntimeBCPath)
      C.emitError("OpenCilkABI: No OpenCilk bitcode ABI file given.");

    LLVM_DEBUG(dbgs() << "Using external bitcode file for OpenCilk ABI: "
                      << OpenCilkRuntimeBCPath << "\n");
    SMDiagnostic SMD;

    // Parse the bitcode file.  This call imports structure definitions, but not
    // function definitions.
    std::unique_ptr<Module> ExternalModule =
        parseIRFile(OpenCilkRuntimeBCPath.getValue(), SMD, C);

    if (!ExternalModule)
      C.emitError("OpenCilkABI: Failed to parse bitcode ABI file: " +
                  Twine(OpenCilkRuntimeBCPath));

    // Strip any debug info from the external module.  For convenience, this
    // Tapir target synthesizes some helper functions, like
    // __cilk_parent_epilogue, that contain calls to these functions, but don't
    // necessarily have debug info.  As a result, debug info in the external
    // module causes failures during subsequent inlining.
    StripDebugInfo(*ExternalModule);

    // Link the external module into the current module, copying over global
    // values.
    //
    // TODO: Consider restructuring the import process to use
    // Linker::Flags::LinkOnlyNeeded to copy over only the necessary contents
    // from the external module.
    bool Fail =
        Linker::linkModules(M, std::move(ExternalModule), Linker::Flags::None,
                            [](Module &M, const StringSet<> &GVS) {
                              LLVM_DEBUG({
                                for (StringRef GVName : GVS.keys())
                                  dbgs() << "Linking global value " << GVName
                                         << "\n";
                              });
                            });
    if (Fail)
      C.emitError("OpenCilkABI: Failed to link bitcode ABI file: " +
                  Twine(OpenCilkRuntimeBCPath));
  }

  // Get or create local definitions of Cilk RTS structure types.
  const char *StackFrameName = "struct.__cilkrts_stack_frame";
  StackFrameTy = StructType::lookupOrCreate(C, StackFrameName);
  WorkerTy = StructType::lookupOrCreate(C, "struct.__cilkrts_worker");

  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  if (UseOpenCilkRuntimeBC) {
    Type *VoidTy = Type::getVoidTy(C);
    FunctionType *CilkRTSFnTy =
        FunctionType::get(VoidTy, {StackFramePtrTy}, false);
    FunctionType *CilkPrepareSpawnFnTy =
        FunctionType::get(Int32Ty, {StackFramePtrTy}, false);
    FunctionType *CilkRTSEnterLandingpadFnTy =
        FunctionType::get(VoidTy, {StackFramePtrTy, Int32Ty}, false);
    FunctionType *CilkRTSPauseFrameFnTy = FunctionType::get(
        VoidTy, {StackFramePtrTy, PointerType::getInt8PtrTy(C)}, false);
    FunctionType *Grainsize8FnTy =
        FunctionType::get(Int8Ty, {Int8Ty}, false);
    FunctionType *Grainsize16FnTy =
        FunctionType::get(Int16Ty, {Int16Ty}, false);
    FunctionType *Grainsize32FnTy =
        FunctionType::get(Int32Ty, {Int32Ty}, false);
    FunctionType *Grainsize64FnTy =
        FunctionType::get(Int64Ty, {Int64Ty}, false);

    SmallVector<CilkRTSFnDesc, 17> CilkRTSFunctions({
        {"__cilkrts_enter_frame", CilkRTSFnTy, CilkRTSEnterFrame},
        {"__cilkrts_enter_frame_helper", CilkRTSFnTy, CilkRTSEnterFrameHelper},
        {"__cilkrts_detach", CilkRTSFnTy, CilkRTSDetach},
        {"__cilkrts_leave_frame", CilkRTSFnTy, CilkRTSLeaveFrame},
        {"__cilkrts_leave_frame_helper", CilkRTSFnTy, CilkRTSLeaveFrameHelper},
        {"__cilk_prepare_spawn", CilkPrepareSpawnFnTy, CilkPrepareSpawn},
        {"__cilk_sync", CilkRTSFnTy, CilkSync},
        {"__cilk_sync_nothrow", CilkRTSFnTy, CilkSyncNoThrow},
        {"__cilk_parent_epilogue", CilkRTSFnTy, CilkParentEpilogue},
        {"__cilk_helper_epilogue", CilkRTSFnTy, CilkHelperEpilogue},
        {"__cilkrts_enter_landingpad", CilkRTSEnterLandingpadFnTy,
         CilkRTSEnterLandingpad},
        {"__cilkrts_pause_frame", CilkRTSPauseFrameFnTy, CilkRTSPauseFrame},
        {"__cilk_helper_epilogue_exn", CilkRTSPauseFrameFnTy,
         CilkHelperEpilogueExn},
        {"__cilkrts_cilk_for_grainsize_8", Grainsize8FnTy,
         CilkRTSCilkForGrainsize8},
        {"__cilkrts_cilk_for_grainsize_16", Grainsize16FnTy,
         CilkRTSCilkForGrainsize16},
        {"__cilkrts_cilk_for_grainsize_32", Grainsize32FnTy,
         CilkRTSCilkForGrainsize32},
        {"__cilkrts_cilk_for_grainsize_64", Grainsize64FnTy,
         CilkRTSCilkForGrainsize64},
    });

    // Add attributes to internalized functions.
    for (CilkRTSFnDesc FnDesc : CilkRTSFunctions) {
      assert(!FnDesc.FnCallee && "Redefining Cilk function");
      FnDesc.FnCallee = M.getOrInsertFunction(FnDesc.FnName, FnDesc.FnType);
      assert(isa<Function>(FnDesc.FnCallee.getCallee()) &&
             "Cilk function is not a function");
      Function *Fn = cast<Function>(FnDesc.FnCallee.getCallee());
      if (!Fn->isDeclaration())
        Fn->setLinkage(Function::AvailableExternallyLinkage);
      // Because __cilk_sync is a C function that can throw an exception,
      // update its attributes specially.
      if ("__cilk_sync" == FnDesc.FnName)
        fixCilkSyncFn(M, Fn);
      else
        Fn->setDoesNotThrow();
      // Unless we're debugging, mark the function as always_inline.  This
      // attribute is required for some functions, but is helpful for all
      // functions.
      if (!DebugABICalls)
        Fn->addFnAttr(Attribute::AlwaysInline);
      else
        Fn->removeFnAttr(Attribute::AlwaysInline);
    }
  } else if (DebugABICalls) {
    if (StackFrameTy->isOpaque()) {
      // Create a dummy __cilkrts_stack_frame structure, for debugging purposes
      // only.
      StackFrameTy->setBody(Int64Ty);
    }
  } else {
    // The OpenCilkABI target requires the use of a bitcode ABI file to generate
    // correct code.
    C.emitError(
        "OpenCilkABI: Bitcode ABI file required for correct code generation.");
  }
}

// Accessors for CilkRTS ABI functions.  When a bitcode file is loaded, these
// functions should return the function defined in the bitcode file.  Otherwise,
// these functions will return FunctionCallees for placeholder declarations of
// these functions.  The latter case is intended for debugging ABI-call
// insertion.

FunctionCallee OpenCilkABI::Get__cilkrts_cilk_for_grainsize_8() {
  if (CilkRTSCilkForGrainsize8)
    return CilkRTSCilkForGrainsize8;

  LLVMContext &C = M.getContext();
  Type *CountTy = Type::getInt8Ty(C);
  FunctionType *FTy = FunctionType::get(CountTy, {CountTy}, false);
  CilkRTSCilkForGrainsize8 =
      M.getOrInsertFunction("__cilkrts_cilk_for_grainsize_8", FTy);

  return CilkRTSCilkForGrainsize8;
}

FunctionCallee OpenCilkABI::Get__cilkrts_cilk_for_grainsize_16() {
  if (CilkRTSCilkForGrainsize16)
    return CilkRTSCilkForGrainsize16;

  LLVMContext &C = M.getContext();
  Type *CountTy = Type::getInt16Ty(C);
  FunctionType *FTy = FunctionType::get(CountTy, {CountTy}, false);
  CilkRTSCilkForGrainsize16 =
      M.getOrInsertFunction("__cilkrts_cilk_for_grainsize_16", FTy);

  return CilkRTSCilkForGrainsize16;
}

FunctionCallee OpenCilkABI::Get__cilkrts_cilk_for_grainsize_32() {
  if (CilkRTSCilkForGrainsize32)
    return CilkRTSCilkForGrainsize32;

  LLVMContext &C = M.getContext();
  Type *CountTy = Type::getInt32Ty(C);
  FunctionType *FTy = FunctionType::get(CountTy, {CountTy}, false);
  CilkRTSCilkForGrainsize32 =
      M.getOrInsertFunction("__cilkrts_cilk_for_grainsize_32", FTy);

  return CilkRTSCilkForGrainsize32;
}

FunctionCallee OpenCilkABI::Get__cilkrts_cilk_for_grainsize_64() {
  if (CilkRTSCilkForGrainsize64)
    return CilkRTSCilkForGrainsize64;

  LLVMContext &C = M.getContext();
  Type *CountTy = Type::getInt64Ty(C);
  FunctionType *FTy = FunctionType::get(CountTy, {CountTy}, false);
  CilkRTSCilkForGrainsize64 =
      M.getOrInsertFunction("__cilkrts_cilk_for_grainsize_64", FTy);

  return CilkRTSCilkForGrainsize64;
}

FunctionCallee OpenCilkABI::Get__cilkrts_enter_frame() {
  if (CilkRTSEnterFrame)
    return CilkRTSEnterFrame;

  const char *name = "__cilkrts_enter_frame";

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkRTSEnterFrame = M.getOrInsertFunction(name, AL, VoidTy, StackFramePtrTy);

  return CilkRTSEnterFrame;
}

FunctionCallee OpenCilkABI::Get__cilkrts_enter_frame_helper() {
  if (CilkRTSEnterFrameHelper)
    return CilkRTSEnterFrameHelper;

  const char *name = "__cilkrts_enter_frame_helper";

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkRTSEnterFrameHelper =
      M.getOrInsertFunction(name, AL, VoidTy, StackFramePtrTy);

  return CilkRTSEnterFrameHelper;
}

FunctionCallee OpenCilkABI::Get__cilkrts_detach() {
  if (CilkRTSDetach)
    return CilkRTSDetach;

  const char *name = "__cilkrts_detach";

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkRTSDetach = M.getOrInsertFunction(name, AL, VoidTy, StackFramePtrTy);

  return CilkRTSDetach;
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

FunctionCallee OpenCilkABI::Get__cilkrts_leave_frame_helper() {
  if (CilkRTSLeaveFrameHelper)
    return CilkRTSLeaveFrameHelper;

  const char *name = "__cilkrts_leave_frame_helper";

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkRTSLeaveFrameHelper =
      M.getOrInsertFunction(name, AL, VoidTy, StackFramePtrTy);

  return CilkRTSLeaveFrameHelper;
}

FunctionCallee OpenCilkABI::Get__cilkrts_enter_landingpad() {
  if (CilkRTSEnterLandingpad)
    return CilkRTSEnterLandingpad;

  const char *name = "__cilkrts_enter_landingpad";

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Type *SelTy = Type::getInt32Ty(C);
  CilkRTSEnterLandingpad =
      M.getOrInsertFunction(name, AL, VoidTy, StackFramePtrTy, SelTy);

  return CilkRTSEnterLandingpad;
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

FunctionCallee OpenCilkABI::GetCilkPrepareSpawnFn() {
  if (CilkPrepareSpawn)
    return CilkPrepareSpawn;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *Int32Ty = Type::getInt32Ty(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkPrepareSpawn = M.getOrInsertFunction("__cilk_prepare_spawn", AL, Int32Ty,
                                           StackFramePtrTy);

  return CilkPrepareSpawn;
}

FunctionCallee OpenCilkABI::GetCilkSyncFn() {
  if (CilkSync)
    return CilkSync;

  LLVMContext &C = M.getContext();
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkSync =
      M.getOrInsertFunction("__cilk_sync", VoidTy, StackFramePtrTy);

  return CilkSync;
}

FunctionCallee OpenCilkABI::GetCilkSyncNoThrowFn() {
  if (CilkSyncNoThrow)
    return CilkSyncNoThrow;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkSyncNoThrow =
      M.getOrInsertFunction("__cilk_sync_nothrow", AL, VoidTy, StackFramePtrTy);

  return CilkSyncNoThrow;
}

FunctionCallee OpenCilkABI::GetCilkParentEpilogueFn() {
  if (CilkParentEpilogue)
    return CilkParentEpilogue;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkParentEpilogue = M.getOrInsertFunction("__cilk_parent_epilogue", AL,
                                             VoidTy, StackFramePtrTy);

  return CilkParentEpilogue;
}

FunctionCallee OpenCilkABI::GetCilkHelperEpilogueFn() {
  if (CilkHelperEpilogue)
    return CilkHelperEpilogue;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex,
                       Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  CilkHelperEpilogue = M.getOrInsertFunction("__cilk_helper_epilogue", AL,
                                             VoidTy, StackFramePtrTy);

  return CilkHelperEpilogue;
}

FunctionCallee OpenCilkABI::GetCilkHelperEpilogueExnFn() {
  if (CilkHelperEpilogueExn)
    return CilkHelperEpilogueExn;

  LLVMContext &C = M.getContext();
  AttributeList AL;
  AL = AL.addAttribute(C, AttributeList::FunctionIndex, Attribute::NoUnwind);
  Type *VoidTy = Type::getVoidTy(C);
  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  PointerType *ExnPtrTy = Type::getInt8PtrTy(C);
  CilkHelperEpilogueExn = M.getOrInsertFunction(
      "__cilk_helper_epilogue_exn", AL, VoidTy, StackFramePtrTy, ExnPtrTy);

  return CilkHelperEpilogueExn;
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

  // The helper is internal to this module.  We use internal linkage, rather
  // than private linkage, so that tools can still reference the helper
  // function.
  Helper.setLinkage(GlobalValue::InternalLinkage);
}

void OpenCilkABI::remapAfterOutlining(BasicBlock *TFEntry,
                                      ValueToValueMapTy &VMap) {

}

// Check whether the allocation of a __cilkrts_stack_frame can be inserted after
// instruction \p I.
static bool skipInstruction(const Instruction &I) {
  if (isa<AllocaInst>(I))
    return true;

  if (isa<DbgInfoIntrinsic>(I))
    return true;

  if (const IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I)) {
    // Skip simple intrinsics
    switch(II->getIntrinsicID()) {
    case Intrinsic::annotation:
    case Intrinsic::assume:
    case Intrinsic::sideeffect:
    case Intrinsic::invariant_start:
    case Intrinsic::invariant_end:
    case Intrinsic::launder_invariant_group:
    case Intrinsic::strip_invariant_group:
    case Intrinsic::is_constant:
    case Intrinsic::lifetime_start:
    case Intrinsic::lifetime_end:
    case Intrinsic::objectsize:
    case Intrinsic::ptr_annotation:
    case Intrinsic::var_annotation:
    case Intrinsic::experimental_gc_result:
    case Intrinsic::experimental_gc_relocate:
    case Intrinsic::experimental_noalias_scope_decl:
    case Intrinsic::syncregion_start:
    case Intrinsic::taskframe_create:
      return true;
    default:
      return false;
    }
  }

  return false;
}

// Scan the basic block \p B to find a point to insert the allocation of a
// __cilkrts_stack_frame.
static Instruction *getStackFrameInsertPt(BasicBlock &B) {
  BasicBlock::iterator BI(B.getFirstInsertionPt());
  BasicBlock::const_iterator BE(B.end());

  // Scan the basic block for the first instruction we should not skip.
  while (BI != BE) {
    if (!skipInstruction(*BI)) {
      return &*BI;
    }
    ++BI;
  }

  // We reached the end of the basic block; return the terminator.
  return B.getTerminator();
}

/// Create the __cilkrts_stack_frame for the spawning function.
Value *OpenCilkABI::CreateStackFrame(Function &F) {
  const DataLayout &DL = F.getParent()->getDataLayout();
  Type *SFTy = StackFrameTy;

  IRBuilder<> B(getStackFrameInsertPt(F.getEntryBlock()));
  AllocaInst *SF = B.CreateAlloca(SFTy, DL.getAllocaAddrSpace(),
                                  /*ArraySize*/ nullptr,
                                  /*Name*/ StackFrameName);
  SF->setAlignment(Align(8));

  return SF;
}

Value* OpenCilkABI::GetOrCreateCilkStackFrame(Function &F) {
  if (DetachCtxToStackFrame.count(&F))
    return DetachCtxToStackFrame[&F];

  Value *SF = CreateStackFrame(F);
  DetachCtxToStackFrame[&F] = SF;

  return SF;
}

// Insert a call in Function F to __cilkrts_detach at DetachPt, which must be
// after the allocation of the __cilkrts_stack_frame in F.
void OpenCilkABI::InsertDetach(Function &F, Instruction *DetachPt) {
  Instruction *SF = cast<Instruction>(GetOrCreateCilkStackFrame(F));
  assert(SF && "No Cilk stack frame for Cilk function.");
  Value *Args[1] = {SF};

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

// Insert a call in Function F to __cilkrts_enter_frame{_helper} to initialize
// the __cilkrts_stack_frame in F.  If TaskFrameCreate is nonnull, the call to
// __cilkrts_enter_frame{_helper} is inserted at TaskFramecreate.
CallInst *OpenCilkABI::InsertStackFramePush(Function &F,
                                            Instruction *TaskFrameCreate,
                                            bool Helper) {
  Instruction *SF = cast<Instruction>(GetOrCreateCilkStackFrame(F));

  BasicBlock::iterator InsertPt = ++SF->getIterator();
  IRBuilder<> B(&(F.getEntryBlock()), InsertPt);
  if (TaskFrameCreate)
    B.SetInsertPoint(TaskFrameCreate);

  Value *Args[1] = {SF};
  if (Helper)
    return B.CreateCall(CILKRTS_FUNC(enter_frame_helper), Args);
  else
    return B.CreateCall(CILKRTS_FUNC(enter_frame), Args);
}

// Insert a call in Function F to the appropriate epilogue function.
//
//   - A call to __cilk_parent_epilogue() is inserted at a return from a
//   spawning function.
//
//   - A call to __cilk_helper_epilogue() is inserted at a return from a
//   spawn-helper function.
//
//   - A call to __cilk_helper_epiluge_exn() is inserted at a resume from a
//   spawn-helper function.
//
// PromoteCallsToInvokes dictates whether call instructions that can throw are
// promoted to invoke instructions prior to inserting the epilogue-function
// calls.
void OpenCilkABI::InsertStackFramePop(Function &F, bool PromoteCallsToInvokes,
                                      bool InsertPauseFrame, bool Helper) {
  Value *SF = GetOrCreateCilkStackFrame(F);
  SmallPtrSet<ReturnInst *, 8> Returns;
  SmallPtrSet<ResumeInst *, 8> Resumes;

  // Add eh cleanup that returns control to the runtime
  EscapeEnumerator EE(F, "cilkrabi_cleanup", PromoteCallsToInvokes);
  while (IRBuilder<> *Builder = EE.Next()) {
    if (ResumeInst *RI = dyn_cast<ResumeInst>(Builder->GetInsertPoint()))
      Resumes.insert(RI);
    else if (ReturnInst *RI = dyn_cast<ReturnInst>(Builder->GetInsertPoint()))
      Returns.insert(RI);
  }

  for (ReturnInst *RI : Returns) {
    if (Helper) {
      CallInst::Create(GetCilkHelperEpilogueFn(), {SF}, "", RI);
    } else {
      CallInst::Create(GetCilkParentEpilogueFn(), {SF}, "", RI);
    }
  }
  for (ResumeInst *RI : Resumes) {
    if (InsertPauseFrame) {
      Value *Exn = ExtractValueInst::Create(RI->getValue(), {0}, "", RI);
      // If throwing an exception, pass the exception object to the epilogue
      // function.
      CallInst::Create(GetCilkHelperEpilogueExnFn(), {SF, Exn}, "", RI);
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

/// Lower a call to get the grainsize of a Tapir loop.
Value *OpenCilkABI::lowerGrainsizeCall(CallInst *GrainsizeCall) {
  Value *Limit = GrainsizeCall->getArgOperand(0);
  IRBuilder<> Builder(GrainsizeCall);

  // Select the appropriate __cilkrts_grainsize function, based on the type.
  FunctionCallee CilkRTSGrainsizeCall;
  if (GrainsizeCall->getType()->isIntegerTy(8))
    CilkRTSGrainsizeCall = CILKRTS_FUNC(cilk_for_grainsize_8);
  else if (GrainsizeCall->getType()->isIntegerTy(16))
    CilkRTSGrainsizeCall = CILKRTS_FUNC(cilk_for_grainsize_16);
  else if (GrainsizeCall->getType()->isIntegerTy(32))
    CilkRTSGrainsizeCall = CILKRTS_FUNC(cilk_for_grainsize_32);
  else if (GrainsizeCall->getType()->isIntegerTy(64))
    CilkRTSGrainsizeCall = CILKRTS_FUNC(cilk_for_grainsize_64);
  else
    llvm_unreachable("No CilkRTSGrainsize call matches type for Tapir loop.");

  Value *Grainsize = Builder.CreateCall(CilkRTSGrainsizeCall, Limit);

  // Replace uses of grainsize intrinsic call with this grainsize value.
  GrainsizeCall->replaceAllUsesWith(Grainsize);
  return Grainsize;
}

// Lower a sync instruction SI.
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
  // Determine whether a sync.unwind immediately follows SI.
  if (InvokeInst *II =
          dyn_cast<InvokeInst>(SyncCont->getFirstNonPHIOrDbgOrLifetime())) {
    if (isSyncUnwind(II)) {
      SyncUnwind = II;
      SyncCont = II->getNormalDest();
      SyncUnwindDest = II->getUnwindDest();
    }
  }

  CallBase *CB;
  if (!SyncUnwindDest) {
    if (Fn.doesNotThrow())
      CB = CallInst::Create(GetCilkSyncNoThrowFn(), Args, "",
                            /*insert before*/ &SI);
    else
      CB = CallInst::Create(GetCilkSyncFn(), Args, "", /*insert before*/ &SI);

    BranchInst::Create(SyncCont, CB->getParent());
  } else {
    CB = InvokeInst::Create(GetCilkSyncFn(), SyncCont, SyncUnwindDest, Args, "",
                            /*insert before*/ &SI);
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
                                         bool IsSpawner, BasicBlock *TFEntry) {
  // If the outlined task F itself performs spawns, set up F to support stealing
  // continuations.
  if (IsSpawner)
    MarkSpawner(F);

  CallInst *EnterFrame =
      InsertStackFramePush(F, TaskFrameCreate, /*Helper*/ true);
  InsertDetach(F, (DetachPt ? DetachPt : &*(++EnterFrame->getIterator())));
}

void OpenCilkABI::postProcessOutlinedTask(Function &F, Instruction *DetachPt,
                                          Instruction *TaskFrameCreate,
                                          bool IsSpawner, BasicBlock *TFEntry) {
  // Because F is a spawned task, we want to insert landingpads for all calls
  // that can throw, so we can pop the stackframe correctly if they do throw.
  // In particular, popping the stackframe of a spawned task may discover that
  // the parent was stolen, in which case we want to save the exception for
  // later reduction.
  InsertStackFramePop(F, /*PromoteCallsToInvokes*/ true,
                      /*InsertPauseFrame*/ true, /*Helper*/ true);

  // TODO: If F is itself a spawner, see if we need to ensure that the Cilk
  // personality function does not pop an already-popped frame.  We might be
  // able to do this by checking if sf->call_parent == NULL before performing a
  // pop in the personality function.
}

void OpenCilkABI::preProcessRootSpawner(Function &F, BasicBlock *TFEntry) {
  MarkSpawner(F);
  InsertStackFramePush(F);
  Value *SF = DetachCtxToStackFrame[&F];
  for (BasicBlock &BB : F) {
    if (BB.isLandingPad()) {
      LandingPadInst *LPad = BB.getLandingPadInst();
      Instruction *InsertPt = &*BB.getFirstInsertionPt();
      IRBuilder<> Builder(InsertPt);

      Value *Sel = Builder.CreateExtractValue(LPad, 1, "sel");
      Builder.CreateCall(CILKRTS_FUNC(enter_landingpad), {SF, Sel});
    }
  }
}

void OpenCilkABI::postProcessRootSpawner(Function &F, BasicBlock *TFEntry) {
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

  // Emit a __cilk_spawn_prepare at the end of the block preceding the split-off
  // detach replacement.
  Instruction *SpawnPt = DetBlock->getTerminator();
  IRBuilder<> B(SpawnPt);
  CallBase *SpawnPrepCall = B.CreateCall(GetCilkPrepareSpawnFn(), {SF});

  // Remember to inline this call later.
  CallsToInline.insert(SpawnPrepCall);

  // Get the ordinary continuation of the detach.
  BasicBlock *CallCont;
  if (InvokeInst *II = dyn_cast<InvokeInst>(ReplCall))
    CallCont = II->getNormalDest();
  else // isa<CallInst>(CallSite)
    CallCont = CallBlock->getSingleSuccessor();

  // Insert a conditional branch, based on the result of the
  // __cilk_spawn_prepare, to either the detach replacement or the continuation.
  Value *SpawnPrepRes = B.CreateICmpEQ(
      SpawnPrepCall, ConstantInt::get(SpawnPrepCall->getType(), 0));
  B.CreateCondBr(SpawnPrepRes, CallBlock, CallCont);
  for (PHINode &PN : CallCont->phis())
    PN.addIncoming(PN.getIncomingValueForBlock(CallBlock), DetBlock);

  SpawnPt->eraseFromParent();
}

// Helper function to inline calls to compiler-generated Cilk Plus runtime
// functions when possible.  This inlining is necessary to properly implement
// some Cilk runtime "calls," such as __cilk_sync().
static inline void inlineCilkFunctions(
    Function &F, SmallPtrSetImpl<CallBase *> &CallsToInline) {
  for (CallBase *CB : CallsToInline) {
    InlineFunctionInfo IFI;
    InlineFunction(*CB, IFI);
  }
  CallsToInline.clear();
}

void OpenCilkABI::preProcessFunction(Function &F, TaskInfo &TI,
                                     bool ProcessingTapirLoops) {
  if (ProcessingTapirLoops)
    // Don't do any preprocessing when outlining Tapir loops.
    return;
}

void OpenCilkABI::postProcessFunction(Function &F, bool ProcessingTapirLoops) {
  if (ProcessingTapirLoops)
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
