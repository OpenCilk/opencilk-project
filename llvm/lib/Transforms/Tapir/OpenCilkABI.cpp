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
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/DiagnosticPrinter.h"
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
static cl::opt<std::string> ClOpenCilkRuntimeBCPath(
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
        CB->removeFnAttr(Attribute::NoUnwind);
}

namespace {

// Custom DiagnosticInfo for linking the OpenCilk ABI bitcode file.
class OpenCilkABILinkDiagnosticInfo : public DiagnosticInfo {
  const Module *SrcM;
  const Twine &Msg;

public:
  OpenCilkABILinkDiagnosticInfo(DiagnosticSeverity Severity, const Module *SrcM,
                                const Twine &Msg)
      : DiagnosticInfo(DK_Lowering, Severity), SrcM(SrcM), Msg(Msg) {}
  void print(DiagnosticPrinter &DP) const override {
    DP << "linking module '" << SrcM->getModuleIdentifier() << "': " << Msg;
  }
};

// Custom DiagnosticHandler to handle diagnostics arising when linking the
// OpenCilk ABI bitcode file.
class OpenCilkABIDiagnosticHandler final : public DiagnosticHandler {
  const Module *SrcM;
  DiagnosticHandler *OrigHandler;

public:
  OpenCilkABIDiagnosticHandler(const Module *SrcM,
                               DiagnosticHandler *OrigHandler)
      : SrcM(SrcM), OrigHandler(OrigHandler) {}

  bool handleDiagnostics(const DiagnosticInfo &DI) override {
    if (DI.getKind() != DK_Linker)
      return OrigHandler->handleDiagnostics(DI);

    std::string MsgStorage;
    {
      raw_string_ostream Stream(MsgStorage);
      DiagnosticPrinterRawOStream DP(Stream);
      DI.print(DP);
    }
    return OrigHandler->handleDiagnostics(
        OpenCilkABILinkDiagnosticInfo(DI.getSeverity(), SrcM, MsgStorage));
  }
};

// Structure recording information about Cilk ABI functions.
struct CilkRTSFnDesc {
  StringRef FnName;
  FunctionType *FnType;
  FunctionCallee &FnCallee;
};

} // namespace

void OpenCilkABI::setOptions(const TapirTargetOptions &Options) {
  if (!isa<OpenCilkABIOptions>(Options))
    return;

  const OpenCilkABIOptions &OptionsCast = cast<OpenCilkABIOptions>(Options);

  // Get the path to the runtime bitcode file.
  RuntimeBCPath = OptionsCast.getRuntimeBCPath();
}

void OpenCilkABI::prepareModule() {
  LLVMContext &C = M.getContext();
  Type *Int8Ty = Type::getInt8Ty(C);
  Type *Int16Ty = Type::getInt16Ty(C);
  Type *Int32Ty = Type::getInt32Ty(C);
  Type *Int64Ty = Type::getInt64Ty(C);

  if (UseOpenCilkRuntimeBC) {
    // If a runtime bitcode path is given via the command line, use it.
    if ("" != ClOpenCilkRuntimeBCPath)
      RuntimeBCPath = ClOpenCilkRuntimeBCPath;

    if ("" == RuntimeBCPath)
      C.emitError("OpenCilkABI: No OpenCilk bitcode ABI file given.");

    LLVM_DEBUG(dbgs() << "Using external bitcode file for OpenCilk ABI: "
                      << RuntimeBCPath << "\n");
    SMDiagnostic SMD;

    // Parse the bitcode file.  This call imports structure definitions, but not
    // function definitions.
    std::unique_ptr<Module> ExternalModule = parseIRFile(RuntimeBCPath, SMD, C);

    if (!ExternalModule)
      C.emitError("OpenCilkABI: Failed to parse bitcode ABI file: " +
                  Twine(RuntimeBCPath));

    // Get the original DiagnosticHandler for this context.
    std::unique_ptr<DiagnosticHandler> OrigDiagHandler =
        C.getDiagnosticHandler();

    // Setup an OpenCilkABIDiagnosticHandler for this context, to handle
    // diagnostics that arise from linking ExternalModule.
    C.setDiagnosticHandler(std::make_unique<OpenCilkABIDiagnosticHandler>(
        ExternalModule.get(), OrigDiagHandler.get()));

    // Link the external module into the current module, copying over global
    // values.
    //
    // TODO: Consider restructuring the import process to use
    // Linker::Flags::LinkOnlyNeeded to copy over only the necessary contents
    // from the external module.
    bool Fail = Linker::linkModules(
        M, std::move(ExternalModule), Linker::Flags::None,
        [](Module &M, const StringSet<> &GVS) {
          for (StringRef GVName : GVS.keys()) {
            LLVM_DEBUG(dbgs() << "Linking global value " << GVName << "\n");
            if (Function *Fn = M.getFunction(GVName)) {
              if (!Fn->isDeclaration())
                // We set the function's linkage as available_externally, so
                // that subsequent optimizations can remove these definitions
                // from the module.  We don't want this module redefining any of
                // these symbols, even if they aren't inlined, because the
                // OpenCilk runtime library will provide those definitions
                // later.
                Fn->setLinkage(Function::AvailableExternallyLinkage);
            } else if (GlobalVariable *G = M.getGlobalVariable(GVName)) {
              if (!G->isDeclaration())
                G->setLinkage(GlobalValue::AvailableExternallyLinkage);
            }
          }
        });
    if (Fail)
      C.emitError("OpenCilkABI: Failed to link bitcode ABI file: " +
                  Twine(RuntimeBCPath));

    // Restore the original DiagnosticHandler for this context.
    C.setDiagnosticHandler(std::move(OrigDiagHandler));
  }

  // Get or create local definitions of Cilk RTS structure types.
  const char *StackFrameName = "struct.__cilkrts_stack_frame";
  StackFrameTy = StructType::lookupOrCreate(C, StackFrameName);
  WorkerTy = StructType::lookupOrCreate(C, "struct.__cilkrts_worker");

  PointerType *StackFramePtrTy = PointerType::getUnqual(StackFrameTy);
  Type *VoidTy = Type::getVoidTy(C);

  // Define the types of the CilkRTS functions.
  FunctionType *CilkRTSFnTy =
      FunctionType::get(VoidTy, {StackFramePtrTy}, false);
  FunctionType *CilkPrepareSpawnFnTy =
      FunctionType::get(Int32Ty, {StackFramePtrTy}, false);
  FunctionType *CilkRTSEnterLandingpadFnTy =
      FunctionType::get(VoidTy, {StackFramePtrTy, Int32Ty}, false);
  FunctionType *CilkRTSPauseFrameFnTy = FunctionType::get(
      VoidTy, {StackFramePtrTy, PointerType::getInt8PtrTy(C)}, false);
  FunctionType *Grainsize8FnTy = FunctionType::get(Int8Ty, {Int8Ty}, false);
  FunctionType *Grainsize16FnTy = FunctionType::get(Int16Ty, {Int16Ty}, false);
  FunctionType *Grainsize32FnTy = FunctionType::get(Int32Ty, {Int32Ty}, false);
  FunctionType *Grainsize64FnTy = FunctionType::get(Int64Ty, {Int64Ty}, false);

  // Create an array of CilkRTS functions, with their associated types and
  // FunctionCallee member variables in the OpenCilkABI class.
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

  if (UseOpenCilkRuntimeBC) {
    // Add attributes to internalized functions.
    for (CilkRTSFnDesc FnDesc : CilkRTSFunctions) {
      assert(!FnDesc.FnCallee && "Redefining Cilk function");
      FnDesc.FnCallee = M.getOrInsertFunction(FnDesc.FnName, FnDesc.FnType);
      assert(isa<Function>(FnDesc.FnCallee.getCallee()) &&
             "Cilk function is not a function");
      Function *Fn = cast<Function>(FnDesc.FnCallee.getCallee());

      // Because __cilk_sync is a C function that can throw an exception, update
      // its attributes specially.  No other CilkRTS functions can throw an
      // exception.
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
    if (GlobalVariable *AlignVar =
        M.getGlobalVariable("__cilkrts_stack_frame_align", true)) {
      if (auto Align = AlignVar->getAlign())
        StackFrameAlign = Align.getValue();
      // Mark this variable with private linkage, to avoid linker failures when
      // compiling with no optimizations.
      AlignVar->setLinkage(GlobalValue::PrivateLinkage);
    }
  } else if (DebugABICalls) {
    if (StackFrameTy->isOpaque()) {
      // Create a dummy __cilkrts_stack_frame structure, for debugging purposes
      // only.
      StackFrameTy->setBody(Int64Ty);
    }
    // Create declarations of all CilkRTS functions, and add basic attributes to
    // those declarations.
    for (CilkRTSFnDesc FnDesc : CilkRTSFunctions) {
      assert(!FnDesc.FnCallee && "Redefining Cilk function");
      FnDesc.FnCallee = M.getOrInsertFunction(FnDesc.FnName, FnDesc.FnType);
      assert(isa<Function>(FnDesc.FnCallee.getCallee()) &&
             "Cilk function is not a function");
      Function *Fn = cast<Function>(FnDesc.FnCallee.getCallee());

      // Mark all CilkRTS functions nounwind, except for __cilk_sync.
      if ("__cilk_sync" == FnDesc.FnName)
        Fn->removeFnAttr(Attribute::NoUnwind);
      else
        Fn->setDoesNotThrow();
    }
  } else {
    // The OpenCilkABI target requires the use of a bitcode ABI file to generate
    // correct code.
    C.emitError(
        "OpenCilkABI: Bitcode ABI file required for correct code generation.");
  }
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
  if (TapirRTCalls[TFEntry].empty())
    return;

  // Update the set of tapir.runtime.{start,end} intrinsics in the taskframe
  // rooted at TFEntry to process.
  SmallVector<IntrinsicInst *, 4> OldTapirRTCalls(TapirRTCalls[TFEntry]);
  TapirRTCalls[TFEntry].clear();
  for (IntrinsicInst *II : OldTapirRTCalls)
    TapirRTCalls[TFEntry].push_back(cast<IntrinsicInst>(VMap[II]));
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
  SF->setAlignment(StackFrameAlign);

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
  if (!B.getCurrentDebugLocation()) {
    // Try to find debug information later in this block for the ABI call.
    BasicBlock::iterator BI = B.GetInsertPoint();
    BasicBlock::const_iterator BE(B.GetInsertBlock()->end());
    while (BI != BE) {
      if (DebugLoc Loc = BI->getDebugLoc()) {
        B.SetCurrentDebugLocation(Loc);
        break;
      }
      ++BI;
    }
  }

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
  EscapeEnumerator EE(F, "cilkrts_cleanup", PromoteCallsToInvokes);
  while (IRBuilder<> *Builder = EE.Next()) {
    if (ResumeInst *RI = dyn_cast<ResumeInst>(Builder->GetInsertPoint())) {
      if (!RI->getDebugLoc())
        // Attempt to set the debug location of this resume to match one of the
        // preceeding terminators.
        for (const BasicBlock *Pred : predecessors(RI->getParent()))
          if (const DebugLoc &Loc = Pred->getTerminator()->getDebugLoc()) {
            RI->setDebugLoc(Loc);
            break;
          }
      Resumes.insert(RI);
    }
    else if (ReturnInst *RI = dyn_cast<ReturnInst>(Builder->GetInsertPoint()))
      Returns.insert(RI);
  }

  for (ReturnInst *RI : Returns) {
    if (Helper) {
      CallInst::Create(GetCilkHelperEpilogueFn(), {SF}, "", RI)
          ->setDebugLoc(RI->getDebugLoc());
    } else {
      CallInst::Create(GetCilkParentEpilogueFn(), {SF}, "", RI)
          ->setDebugLoc(RI->getDebugLoc());
    }
  }
  for (ResumeInst *RI : Resumes) {
    if (InsertPauseFrame) {
      Value *Exn = ExtractValueInst::Create(RI->getValue(), {0}, "", RI);
      // If throwing an exception, pass the exception object to the epilogue
      // function.
      CallInst::Create(GetCilkHelperEpilogueExnFn(), {SF, Exn}, "", RI)
          ->setDebugLoc(RI->getDebugLoc());
    }
  }
}

// Lower any calls to tapir.runtime.{start,end} that need to be processed.
void OpenCilkABI::LowerTapirRTCalls(Function &F, BasicBlock *TFEntry) {
  Instruction *SF = cast<Instruction>(GetOrCreateCilkStackFrame(F));
  for (IntrinsicInst *II : TapirRTCalls[TFEntry]) {
    IRBuilder<> Builder(II);
    if (Intrinsic::tapir_runtime_start == II->getIntrinsicID()) {
      // Lower calls to tapir.runtime.start to __cilkrts_enter_frame.
      Builder.CreateCall(CILKRTS_FUNC(enter_frame), {SF});

      // Find all tapir.runtime.ends that use this tapir.runtime.start, and
      // lower them to calls to __cilk_parent_epilogue.
      for (Use &U : II->uses())
        if (IntrinsicInst *UII = dyn_cast<IntrinsicInst>(U.getUser()))
          if (Intrinsic::tapir_runtime_end == UII->getIntrinsicID()) {
            Builder.SetInsertPoint(UII);
            Builder.CreateCall(GetCilkParentEpilogueFn(), {SF});
          }
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
  F.removeFnAttr(Attribute::ArgMemOnly);
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
  if (TapirRTCalls[TFEntry].empty()) {
    InsertStackFramePush(F);
  } else {
    LowerTapirRTCalls(F, TFEntry);
  }
  Value *SF = DetachCtxToStackFrame[&F];
  for (BasicBlock &BB : F) {
    if (BB.isLandingPad()) {
      LandingPadInst *LPad = BB.getLandingPadInst();
      Instruction *InsertPt = &*BB.getFirstInsertionPt();
      IRBuilder<> Builder(InsertPt);
      // Try to find debug information for the ABI call.  First check the
      // landing pad.
      if (!Builder.getCurrentDebugLocation())
        Builder.SetCurrentDebugLocation(LPad->getDebugLoc());
      // Next, check later in the block
      if (!Builder.getCurrentDebugLocation()) {
        BasicBlock::iterator BI = Builder.GetInsertPoint();
        BasicBlock::const_iterator BE(Builder.GetInsertBlock()->end());
        while (BI != BE) {
          if (DebugLoc Loc = BI->getDebugLoc()) {
            Builder.SetCurrentDebugLocation(Loc);
            break;
          }
          ++BI;
        }
      }

      Value *Sel = Builder.CreateExtractValue(LPad, 1, "sel");
      Builder.CreateCall(CILKRTS_FUNC(enter_landingpad), {SF, Sel});
    }
  }
}

void OpenCilkABI::postProcessRootSpawner(Function &F, BasicBlock *TFEntry) {
  // F is a root spawner, not itself a spawned task.  We don't need to promote
  // calls to invokes, since the Cilk personality function will take care of
  // popping the frame if no landingpad exists for a given call.
  if (TapirRTCalls[TFEntry].empty())
    InsertStackFramePop(F, /*PromoteCallsToInvokes*/ false,
                        /*InsertPauseFrame*/ false, /*Helper*/ false);
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

// For the taskframe at \p TFEntry containing blocks \p TFBlocks, find all
// outermost tapir.runtime.{start,end} intrinsics, which are not enclosed
// between other tapir.runtime.{start,end} intrinsics in this traksframe.
// Furthermore, record and successor taskframes in \p SuccessorTFs that are not
// enclosed between tapir.runtime.{start,end} intrinsics.
static bool findOutermostTapirRTCallsForTaskFrame(
    SmallVectorImpl<IntrinsicInst *> &TapirRTCalls, BasicBlock *TFEntry,
    SmallPtrSetImpl<BasicBlock *> &TFBlocks,
    SmallPtrSetImpl<Spindle *> &SuccessorTFs, TaskInfo &TI) {
  SmallVector<BasicBlock::iterator, 8> Worklist;
  SmallPtrSet<BasicBlock *, 8> Visited;
  Worklist.push_back(TFEntry->begin());

  while (!Worklist.empty()) {
    BasicBlock::iterator Iter = Worklist.pop_back_val();
    BasicBlock *BB = Iter->getParent();

    bool FoundTapirRTStart = false;
    bool FoundTapirRTEnd = false;
    SmallVector<BasicBlock::iterator, 4> EndIters;
    // Scan the BB for tapir_runtime calls.
    for (BasicBlock::iterator It = Iter, E = BB->end(); It != E; ++It) {
      Instruction *I = &*It;
      if (isTapirIntrinsic(Intrinsic::tapir_runtime_start, I)) {
        FoundTapirRTStart = true;
        TapirRTCalls.push_back(cast<IntrinsicInst>(I));
        // Examine corresponding tapir_runtime_end intrinsics to find blocks
        // from which to continue search.
        for (Use &U : I->uses()) {
          if (Instruction *UI = dyn_cast<Instruction>(U.getUser())) {
            FoundTapirRTEnd = true;
            BasicBlock *EndBB = UI->getParent();
            assert(TFBlocks.count(EndBB) && "tapir_runtime_end not in same "
                                            "taskframe as tapir_runtime_begin");
            EndIters.push_back(++UI->getIterator());
          }
        }

        if (FoundTapirRTEnd)
          // We found a tapir_runtime_begin in this block, so stop searching.
          break;
      }
    }

    // If we didn't find a tapir_runtime_start in this block, treat this block
    // as an end block, so we examine its direct successors.
    if (!FoundTapirRTStart)
      EndIters.push_back(BB->getTerminator()->getIterator());

    // Examine all end blocks to 1) check if a spawn occurs, and 2) add
    // successors within the taskframe for further search.
    for (BasicBlock::iterator Iter : EndIters) {
      if (isa<DetachInst>(*Iter)) {
        // We found a spawn terminating a block in this taskframe.  This spawn
        // is not contained between outermost tapir_runtime_{start,end} calls in
        // the taskframe.  Therefore, we should fall back to default behavior
        // for inserting enter_frame and leave_frame calls for this taskframe.
        TapirRTCalls.clear();
        return true;
      }

      BasicBlock *EndBB = Iter->getParent();
      if (EndBB->getTerminator() != &*Iter) {
        Worklist.push_back(Iter);
        continue;
      }

      // Add the successors of this block for further search.
      for (BasicBlock *Succ : successors(EndBB)) {
        if (TFBlocks.count(Succ) && Visited.insert(Succ).second)
          // For successors within the taskframe, add them to the search.
          Worklist.push_back(Succ->begin());
        else {
          // For successors in other taskframes, add the subtaskframe for
          // processing.
          Spindle *SuccSpindle = TI.getSpindleFor(Succ);
          if (SuccSpindle->getTaskFrameCreate())
            SuccessorTFs.insert(SuccSpindle);
        }
      }
    }
  }

  return false;
}

// Find all tapir.runtime.{start,end} intrinsics to process for the taskframe
// rooted at spindle \p TaskFrame and any subtaskframes thereof.
void OpenCilkABI::GetTapirRTCalls(Spindle *TaskFrame, bool IsRootTask,
                                  TaskInfo &TI) {
  BasicBlock *TFEntry = TaskFrame->getEntry();
  SmallPtrSet<BasicBlock *, 8> TFBlocks;
  SmallVector<Spindle *, 4> SubTFs;
  if (IsRootTask) {
    // We have to compute the effective taskframe blocks for the root task,
    // since these blocks are not automatically identified by TapirTaskInfo.
    //
    // Note: We could generalize TapirTaskInfo to compute these taskframe blocks
    // directly, but this computation seems to be the only place that set of
    // blocks is needed.
    SmallPtrSet<Spindle *, 4> ExcludedSpindles;
    // Exclude all spindles in unassociated taskframes under the root task.
    for (Spindle *TFRoot : TI.getRootTask()->taskframe_roots()) {
      if (!TFRoot->getTaskFromTaskFrame())
        SubTFs.push_back(TFRoot);
      for (Spindle *TFSpindle : depth_first<TaskFrames<Spindle *>>(TFRoot)) {
        if (TFSpindle->getTaskFromTaskFrame())
          continue;

        for (Spindle *S : TFSpindle->taskframe_spindles())
          ExcludedSpindles.insert(S);
      }
    }

    // Iterate over the spindles in the root task, and add all spindle blocks to
    // TFBlocks as long as those blocks don't belong to a nested taskframe.
    for (Spindle *S :
         depth_first<InTask<Spindle *>>(TI.getRootTask()->getEntrySpindle())) {
      if (ExcludedSpindles.count(S))
        continue;

      TFBlocks.insert(S->block_begin(), S->block_end());
    }
  } else {
    // Add all blocks in all spindles associated with this taskframe.
    for (Spindle *S : TaskFrame->taskframe_spindles())
      TFBlocks.insert(S->block_begin(), S->block_end());

    for (Spindle *SubTF : TaskFrame->subtaskframes())
      if (!SubTF->getTaskFromTaskFrame())
        SubTFs.push_back(SubTF);
  }

  // Find the outermost tapir_runtime_{start,end} calls in this taskframe.
  // Record in SuccessorTFs any subtaskframes that are not enclosed in
  // tapir.runtime.{start,end} intrinsics.
  SmallPtrSet<Spindle *, 4> SuccessorTFs;
  bool TaskFrameSpawns = findOutermostTapirRTCallsForTaskFrame(
      TapirRTCalls[TFEntry], TFEntry, TFBlocks, SuccessorTFs, TI);

  // If this taskframe spawns outside of tapir_runtime_{start,end} pairs, then
  // the taskframe will start/end the runtime when executed.  Hence there's no
  // need to evaluate subtaskframes.
  if (TaskFrameSpawns)
    return;

  // Process subtaskframes recursively.
  for (Spindle *SubTF : SubTFs) {
    // Skip any subtaskframes that are already enclosed in
    // tapir.runtime.{start,end} intrinsics.
    if (!SuccessorTFs.count(SubTF))
      continue;

    // Skip any taskframes that are associated with subtasks.
    assert(!SubTF->getTaskFromTaskFrame() &&
           "Should not be processing spawned taskframes.");

    GetTapirRTCalls(SubTF, false, TI);
  }
}

void OpenCilkABI::preProcessFunction(Function &F, TaskInfo &TI,
                                     bool ProcessingTapirLoops) {
  if (ProcessingTapirLoops)
    // Don't do any preprocessing when outlining Tapir loops.
    return;

  // Find all Tapir-runtime calls in this function that may be translated to
  // enter_frame/leave_frame calls.
  GetTapirRTCalls(TI.getRootTask()->getEntrySpindle(), true, TI);

  if (!TI.isSerial() || TapirRTCalls[&F.getEntryBlock()].empty())
    return;

  MarkSpawner(F);
  LowerTapirRTCalls(F, &F.getEntryBlock());
}

void OpenCilkABI::postProcessFunction(Function &F, bool ProcessingTapirLoops) {
  if (ProcessingTapirLoops)
    // Don't do any postprocessing when outlining Tapir loops.
    return;

  if (!DebugABICalls)
    inlineCilkFunctions(F, CallsToInline);
}

/// Process the Tapir instructions in an ordinary (non-spawning and not spawned)
/// function \p F directly.
bool OpenCilkABI::processOrdinaryFunction(Function &F, BasicBlock *TFEntry) {
  // Get the simple Tapir instructions to process, including syncs and
  // loop-grainsize calls.
  SmallVector<CallInst *, 8> GrainsizeCalls;
  SmallVector<CallInst *, 8> TaskFrameAddrCalls;
  for (BasicBlock &BB : F) {
    for (Instruction &I : BB) {
      // Record calls to get Tapir-loop grainsizes.
      if (IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I))
        if (Intrinsic::tapir_loop_grainsize == II->getIntrinsicID())
          GrainsizeCalls.push_back(II);

      // Record calls to task_frameaddr intrinsics.
      if (IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I))
        if (Intrinsic::task_frameaddress == II->getIntrinsicID())
          TaskFrameAddrCalls.push_back(II);
    }
  }

  // Lower simple Tapir instructions in this function.  Collect the set of
  // helper functions generated by this process.
  bool Changed = false;

  // Lower calls to get Tapir-loop grainsizes.
  while (!GrainsizeCalls.empty()) {
    CallInst *GrainsizeCall = GrainsizeCalls.pop_back_val();
    LLVM_DEBUG(dbgs() << "Lowering grainsize call " << *GrainsizeCall << "\n");
    lowerGrainsizeCall(GrainsizeCall);
    Changed = true;
  }

  // Lower calls to task_frameaddr intrinsics.
  while (!TaskFrameAddrCalls.empty()) {
    CallInst *TaskFrameAddrCall = TaskFrameAddrCalls.pop_back_val();
    LLVM_DEBUG(dbgs() << "Lowering task_frameaddr call " << *TaskFrameAddrCall
                      << "\n");
    lowerTaskFrameAddrCall(TaskFrameAddrCall);
    Changed = true;
  }

  // If any calls to tapir.runtime.{start,end} were found in this taskframe that
  // need processing, lower them now.
  if (!TapirRTCalls[TFEntry].empty()) {
    LowerTapirRTCalls(F, TFEntry);
    Changed = true;
  }

  return Changed;
}

void OpenCilkABI::postProcessHelper(Function &F) {}

LoopOutlineProcessor *OpenCilkABI::getLoopOutlineProcessor(
    const TapirLoopInfo *TL) const {
  if (UseRuntimeCilkFor)
    return new RuntimeCilkFor(M);
  return nullptr;
}
