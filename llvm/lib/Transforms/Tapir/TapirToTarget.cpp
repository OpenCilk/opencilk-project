//===- TapirToTarget.cpp - Convert Tapir into parallel-runtime calls ------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass converts functions that use Tapir instructions to call out to a
// target parallel runtime system.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Tapir/TapirToTarget.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/Timer.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Tapir.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

#define DEBUG_TYPE "tapir2target"

using namespace llvm;

static const char TimerGroupName[] = DEBUG_TYPE;
static const char TimerGroupDescription[] = "Tapir to Target";

class TapirToTargetImpl {
public:
  TapirToTargetImpl(Module &M,
                    function_ref<DominatorTree &(Function &)> GetDT,
                    function_ref<TaskInfo &(Function &)> GetTI,
                    function_ref<AssumptionCache &(Function &)> GetAC,
                    TapirTarget *Target)
      : Target(Target), M(M), GetDT(GetDT), GetTI(GetTI), GetAC(GetAC) {
    assert(this->Target);
  }
  ~TapirToTargetImpl() {
    if (Target)
      delete Target;
  }

  bool run();

private:
  bool unifyReturns(Function &F);
  void processFunction(Function &F, SmallVectorImpl<Function *> &NewHelpers);
  TaskOutlineMapTy outlineAllTasks(Function &F, DominatorTree &DT,
                                   AssumptionCache &AC, TaskInfo &TI);
  bool processSimpleABI(Function &F);
  bool processRootTask(Function &F, TaskOutlineMapTy &TaskToOutline,
                       DominatorTree &DT, AssumptionCache &AC, TaskInfo &TI);
  bool processOutlinedTask(
      Task *T, TaskOutlineMapTy &TaskToOutline, DominatorTree &DT,
      AssumptionCache &AC, TaskInfo &TI);

private:
  TapirTarget *Target = nullptr;

  Module &M;

  function_ref<DominatorTree &(Function &)> GetDT;
  function_ref<TaskInfo &(Function &)> GetTI;
  function_ref<AssumptionCache &(Function &)> GetAC;
};

bool TapirToTargetImpl::unifyReturns(Function &F) {
  NamedRegionTimer NRT("unifyReturns", "Unify returns", TimerGroupName,
                       TimerGroupDescription, TimePassesIsEnabled);
  SmallVector<BasicBlock *, 4> ReturningBlocks;
  for (BasicBlock &BB : F)
    if (isa<ReturnInst>(BB.getTerminator()))
      ReturningBlocks.push_back(&BB);

  // If this function already has no returns or a single return, then terminate
  // early.
  if (ReturningBlocks.size() <= 1)
    return false;

  BasicBlock *NewRetBlock = BasicBlock::Create(F.getContext(),
                                               "UnifiedReturnBlock", &F);
  PHINode *PN = nullptr;
  if (F.getReturnType()->isVoidTy()) {
    ReturnInst::Create(F.getContext(), nullptr, NewRetBlock);
  } else {
    // If the function doesn't return void... add a PHI node to the block...
    PN = PHINode::Create(F.getReturnType(), ReturningBlocks.size(),
                         "UnifiedRetVal");
    NewRetBlock->getInstList().push_back(PN);
    ReturnInst::Create(F.getContext(), PN, NewRetBlock);
  }

  // Loop over all of the blocks, replacing the return instruction with an
  // unconditional branch.
  //
  for (BasicBlock *BB : ReturningBlocks) {
    // Add an incoming element to the PHI node for every return instruction that
    // is merging into this new block...
    if (PN)
      PN->addIncoming(BB->getTerminator()->getOperand(0), BB);

    BB->getInstList().pop_back();  // Remove the return insn
    BranchInst::Create(NewRetBlock, BB);
  }
  return true;
}

/// Outline all tasks in this function in post order.
TaskOutlineMapTy
TapirToTargetImpl::outlineAllTasks(Function &F, DominatorTree &DT,
                                   AssumptionCache &AC, TaskInfo &TI) {
  NamedRegionTimer NRT("outlineAllTasks", "Outline all tasks", TimerGroupName,
                       TimerGroupDescription, TimePassesIsEnabled);
  TaskOutlineMapTy TaskToOutline;

  // Determine the inputs for all tasks.
  TaskValueSetMap TFInputs, TFOutputs;
  findAllTaskFrameInputs(TFInputs, TFOutputs, F, DT, TI);

  DenseMap<Task *, SmallVector<Value *, 8>> HelperInputs;
  // Traverse the tasks in this function in post order.
  // TODO: Make sure to traverse subtasks first.
  for (Task *T : post_order(TI.getRootTask())) {
    // At this point, all subtasks of T must have been processed.  Replace their
    // detaches with calls.
    for (Task *SubT : T->subtasks())
      // TODO: Rename replaceDetachWithCallToOutline.
      TaskToOutline[SubT].replaceReplCall(
          replaceDetachWithCallToOutline(SubT, TaskToOutline[SubT],
                                         HelperInputs[SubT]));

    // Outline the task, if necessary, and add the outlined function to the
    // mapping.

    // If this is the root task, then no outlining is necessary.
    if (T->isRootTask())
      break;

    // If task T tracks any exception-handling spindles for its subtasks, remove
    // any dependencies from those shared-EH spindles to T.
    for (Spindle *SharedEH : T->shared_eh_spindles()) {
      // Remove blocks in shared-EH spindles from PHI's in T.
      for (Spindle::SpindleEdge &SuccEdge : SharedEH->out_edges()) {
        Spindle *Succ = SuccEdge.first;
        BasicBlock *Exit = SuccEdge.second;
        if (Succ->getParentTask() != T || T->containsSharedEH(Succ))
          continue;
        Succ->getEntry()->removePredecessor(Exit);
      }
    }

    ValueToValueMapTy VMap;
    ValueToValueMapTy InputMap;
    TaskToOutline[T] = outlineTask(T, TFInputs[T], HelperInputs[T],
                                   &Target->getDestinationModule(), VMap,
                                   Target->getArgStructMode(),
                                   Target->getReturnType(), InputMap, &AC, &DT);
    // If the detach for task T does not catch an exception from the task, then
    // the outlined function cannot throw.
    if (F.doesNotThrow() && !T->getDetach()->hasUnwindDest())
      TaskToOutline[T].Outline->setDoesNotThrow();
    Target->addHelperAttributes(*TaskToOutline[T].Outline);

    // Update subtask outline info to reflect the fact that their spawner was
    // outlined.
    for (Task *SubT : T->subtasks())
      TaskToOutline[SubT].remapOutlineInfo(VMap, InputMap);
  }

  return TaskToOutline;
}

/// Process the Tapir instructions in function \p F directly.
bool TapirToTargetImpl::processSimpleABI(Function &F) {
  NamedRegionTimer NRT("processSimpleABI", "Process simple ABI", TimerGroupName,
                       TimerGroupDescription, TimePassesIsEnabled);

  // Get the simple Tapir instructions to process, including syncs and
  // loop-grainsize calls.
  SmallVector<SyncInst *, 8> Syncs;
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

      // Record sync instructions in this function.
      if (SyncInst *SI = dyn_cast<SyncInst>(&I))
        Syncs.push_back(SI);
    }
  }

  // Lower simple Tapir instructions in this function.  Collect the set of
  // helper functions generated by this process.
  bool Changed = false;

  // Lower calls to get Tapir-loop grainsizes.
  while (!GrainsizeCalls.empty()) {
    CallInst *GrainsizeCall = GrainsizeCalls.pop_back_val();
    LLVM_DEBUG(dbgs() << "Lowering grainsize call " << *GrainsizeCall << "\n");
    Target->lowerGrainsizeCall(GrainsizeCall);
    Changed = true;
  }

  // Lower calls to task_frameaddr intrinsics.
  while (!TaskFrameAddrCalls.empty()) {
    CallInst *TaskFrameAddrCall = TaskFrameAddrCalls.pop_back_val();
    LLVM_DEBUG(dbgs() << "Lowering task_frameaddr call " << *TaskFrameAddrCall
               << "\n");
    Target->lowerTaskFrameAddrCall(TaskFrameAddrCall);
    Changed = true;
  }

  // Process the set of syncs.
  while (!Syncs.empty()) {
    SyncInst *SI = Syncs.pop_back_val();
    Target->lowerSync(*SI);
    Changed = true;
  }

  return Changed;
}

bool TapirToTargetImpl::processRootTask(
    Function &F, TaskOutlineMapTy &TaskToOutline, DominatorTree &DT,
    AssumptionCache &AC, TaskInfo &TI) {
  NamedRegionTimer NRT("processRootTask", "Process root task",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  bool Changed = false;
  if (!TI.isSerial()) {
    Changed = true;
    // Process root-task function F as a spawner.
    Target->processSpawner(F);

    // Process each call to a subtask.
    for (Task *SubT : TI.getRootTask()->subtasks())
      Target->processSubTaskCall(TaskToOutline[SubT], DT);
  }
  // Process the Tapir instructions in F directly.
  Changed |= processSimpleABI(F);
  return Changed;
}

bool TapirToTargetImpl::processOutlinedTask(
    Task *T, TaskOutlineMapTy &TaskToOutline, DominatorTree &DT,
    AssumptionCache &AC, TaskInfo &TI) {
  NamedRegionTimer NRT("processOutlinedTask", "Process outlined task",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Function &F = *TaskToOutline[T].Outline;
  Instruction *DetachPt = TaskToOutline[T].DetachPt;
  Instruction *TaskFrameCreate = TaskToOutline[T].TaskFrameCreate;
  Target->processOutlinedTask(F, DetachPt, TaskFrameCreate);
  if (!T->isSerial()) {
    // Process outlined function F for a task as a spawner.
    Target->processSpawner(F);

    // Process each call to a subtask.
    for (Task *SubT : T->subtasks())
      Target->processSubTaskCall(TaskToOutline[SubT], DT);
  }
  // Process the Tapir instructions in F directly.
  processSimpleABI(F);
  return true;
}

void TapirToTargetImpl::processFunction(
    Function &F, SmallVectorImpl<Function *> &NewHelpers) {
  LLVM_DEBUG(dbgs() << "Tapir: Processing function " << F.getName() << "\n");

  // Get the necessary analysis results.
  DominatorTree &DT = GetDT(F);
  TaskInfo &TI = GetTI(F);
  splitTaskFrameCreateBlocks(F, &DT, &TI);
  TI.findTaskFrameSubtasks();
  AssumptionCache &AC = GetAC(F);

  {
  NamedRegionTimer NRT("TargetPreProcess", "Target preprocessing",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Target->preProcessFunction(F, TI);
  } // end timed region

  // If we don't need to do outlining, then just handle the simple ABI.
  if (!Target->shouldDoOutlining(F)) {
    // Process the Tapir instructions in F directly.
    processSimpleABI(F);
    return;
  }

  for (Task *T : post_order(TI.getRootTask()))
    fixupTaskFrameExternalUses(T, DT);

  // Outline all tasks in a target-oblivious manner.
  TaskOutlineMapTy TaskToOutline = outlineAllTasks(F, DT, AC, TI);

  // Perform target-specific processing of this function and all newly created
  // helpers.
  for (Task *T : post_order(TI.getRootTask())) {
    if (T->isRootTask())
      processRootTask(F, TaskToOutline, DT, AC, TI);
    else {
      processOutlinedTask(T, TaskToOutline, DT, AC, TI);
      NewHelpers.push_back(TaskToOutline[T].Outline);
    }
  }
  {
  NamedRegionTimer NRT("TargetPostProcess", "Target postprocessing",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Target->postProcessFunction(F);
  for (Function *H : NewHelpers)
    Target->postProcessHelper(*H);
  } // end timed region
#ifndef NDEBUG
  if (verifyModule(M, &errs())) {
    LLVM_DEBUG(dbgs() << "Module after lowering:" << M);
    llvm_unreachable("Tapir lowering produced bad IR!");
  }
#endif

  return;
}

bool TapirToTargetImpl::run() {
  // Add functions that detach to the work list.
  SmallVector<Function *, 4> WorkList;
  for (Function &F : M)
    if (Target->shouldProcessFunction(F))
      WorkList.push_back(&F);

  if (WorkList.empty())
    return false;

  bool Changed = false;
  while (!WorkList.empty()) {
    // Process the next function.
    Function *F = WorkList.pop_back_val();
    SmallVector<Function *, 4> NewHelpers;

    processFunction(*F, NewHelpers);
    Changed |= !NewHelpers.empty();

    // Check the generated helper functions to see if any need to be processed,
    // that is, to see if any of them themselves detach a subtask.
    for (Function *Helper : NewHelpers)
      if (Target->shouldProcessFunction(*Helper))
        WorkList.push_back(Helper);
  }
  return Changed;
}

PreservedAnalyses TapirToTargetPass::run(Module &M, ModuleAnalysisManager &AM) {
  auto &TLI = AM.getResult<TargetLibraryAnalysis>(M);
  auto &FAM =
    AM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  auto GetDT =
    [&FAM](Function &F) -> DominatorTree & {
      return FAM.getResult<DominatorTreeAnalysis>(F);
    };
  auto GetTI =
    [&FAM](Function &F) -> TaskInfo & {
      return FAM.getResult<TaskAnalysis>(F);
    };
  auto GetAC =
    [&FAM](Function &F) -> AssumptionCache & {
      return FAM.getResult<AssumptionAnalysis>(F);
    };

  bool Changed = false;
  TapirTargetID TargetID = TLI.getTapirTarget();
  Changed |= TapirToTargetImpl(M, GetDT, GetTI, GetAC,
                               getTapirTargetFromID(M, TargetID)).run();

  if (Changed)
    return PreservedAnalyses::none();
  return PreservedAnalyses::all();
}

namespace {
struct LowerTapirToTarget : public ModulePass {
  static char ID; // Pass identification, replacement for typeid
  explicit LowerTapirToTarget()
      : ModulePass(ID) {
    initializeLowerTapirToTargetPass(*PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override {
    return "Lower Tapir to target";
  }

  bool runOnModule(Module &M) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AssumptionCacheTracker>();
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<TargetLibraryInfoWrapperPass>();
    AU.addRequired<TaskInfoWrapperPass>();
  }
};
}  // End of anonymous namespace

char LowerTapirToTarget::ID = 0;
INITIALIZE_PASS_BEGIN(LowerTapirToTarget, "tapir2target",
                      "Lower Tapir to Target ABI", false, false)
INITIALIZE_PASS_DEPENDENCY(AssumptionCacheTracker)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetLibraryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TaskInfoWrapperPass)
INITIALIZE_PASS_END(LowerTapirToTarget, "tapir2target",
                    "Lower Tapir to Target ABI", false, false)

bool LowerTapirToTarget::runOnModule(Module &M) {
  if (skipModule(M))
    return false;
  auto &TLI = getAnalysis<TargetLibraryInfoWrapperPass>().getTLI();
  TapirTargetID TargetID = TLI.getTapirTarget();

  auto GetDT =
    [this](Function &F) -> DominatorTree & {
      return this->getAnalysis<DominatorTreeWrapperPass>(F).getDomTree();
    };
  auto GetTI =
    [this](Function &F) -> TaskInfo & {
      return this->getAnalysis<TaskInfoWrapperPass>(F).getTaskInfo();
    };
  AssumptionCacheTracker *ACT = &getAnalysis<AssumptionCacheTracker>();
  auto GetAC =
    [&ACT](Function &F) -> AssumptionCache & {
      return ACT->getAssumptionCache(F);
    };

  bool Changed = false;
  Changed |= TapirToTargetImpl(M, GetDT, GetTI, GetAC,
                               getTapirTargetFromID(M, TargetID)).run();
  return Changed;
}

// createLowerTapirToTargetPass - Provide an entry point to create this pass.
//
namespace llvm {
ModulePass *createLowerTapirToTargetPass() {
  return new LowerTapirToTarget();
}
}
