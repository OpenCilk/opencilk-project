//===- TaskSimplify.cpp - Tapir task simplification pass ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass performs several transformations to simplify Tapir tasks.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/TaskSimplify.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/PassManager.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "task-simplify"

// Statistics
STATISTIC(NumUniqueSyncRegs, "Number of unique sync regions found.");
STATISTIC(NumDiscriminatingSyncs, "Number of discriminating syncs found.");
STATISTIC(NumTaskFramesErased, "Number of taskframes erased");
STATISTIC(NumSimpl, "Number of blocks simplified");

static cl::opt<bool> SimplifyTaskFrames(
    "simplify-taskframes", cl::init(true), cl::Hidden,
    cl::desc("Enable simplification of taskframes."));

static cl::opt<bool> PostCleanupCFG(
    "post-cleanup-cfg", cl::init(true), cl::Hidden,
    cl::desc("Cleanup the CFG after task simplification."));

static bool syncMatchesReachingTask(const Value *SyncSR,
                                    SmallPtrSetImpl<const Task *> &MPTasks) {
  if (MPTasks.empty())
    return false;
  for (const Task *MPTask : MPTasks)
    if (SyncSR == MPTask->getDetach()->getSyncRegion())
      return true;
  return false;
}

static bool removeRedundantSyncs(MaybeParallelTasks &MPTasks, Task *T) {
  // Skip tasks with no subtasks.
  if (T->isSerial())
    return false;

  bool Changed = false;
  SmallPtrSet<SyncInst *, 1> RedundantSyncs;
  for (Spindle *S : T->spindles())
    // Iterate over outgoing edges of S to find redundant syncs.
    for (Spindle::SpindleEdge &Edge : S->out_edges())
      if (SyncInst *Y = dyn_cast<SyncInst>(Edge.second->getTerminator()))
        if (!syncMatchesReachingTask(Y->getSyncRegion(), MPTasks.TaskList[S])) {
          LLVM_DEBUG(dbgs() << "Found redundant sync in spindle " << *S <<
                     "\n");
          RedundantSyncs.insert(Y);
        }

  // Replace all unnecesary syncs with unconditional branches.
  SmallPtrSet<CallBase *, 1> MaybeDeadSyncUnwinds;
  for (SyncInst *Y : RedundantSyncs) {
    // Check for any sync.unwinds that might now be dead.
    Instruction *MaybeSyncUnwind =
        Y->getSuccessor(0)->getFirstNonPHIOrDbgOrLifetime();
    if (isSyncUnwind(MaybeSyncUnwind, Y->getSyncRegion()))
      MaybeDeadSyncUnwinds.insert(cast<CallBase>(MaybeSyncUnwind));

    LLVM_DEBUG(dbgs() << "Removing redundant sync " << *Y << "\n");
    ReplaceInstWithInst(Y, BranchInst::Create(Y->getSuccessor(0)));
  }
  // Remove any dead sync.unwinds.
  for (CallBase *CB : MaybeDeadSyncUnwinds) {
    LLVM_DEBUG(dbgs() << "Remove dead sync unwind " << *CB << "?  ");
    if (removeDeadSyncUnwind(CB))
      LLVM_DEBUG(dbgs() << "Yes.\n");
    else
      LLVM_DEBUG(dbgs() << "No.\n");
  }

  Changed |= !RedundantSyncs.empty();

  return Changed;
}

static bool syncIsDiscriminating(const Value *SyncSR,
                                 SmallPtrSetImpl<const Task *> &MPTasks) {
  for (const Task *MPTask : MPTasks)
    if (SyncSR != MPTask->getDetach()->getSyncRegion())
      return true;
  return false;
}

static bool removeRedundantSyncRegions(MaybeParallelTasks &MPTasks, Task *T) {
  if (T->isSerial())
    return false;

  // Create filter for MPTasks of tasks from parent of T.
  SmallPtrSet<const Task *, 4> EntryTaskList;
  for (const Task *MPTask : MPTasks.TaskList[T->getEntrySpindle()])
    EntryTaskList.insert(MPTask);

  // Find the unique sync regions in this task.
  SmallPtrSet<Value *, 1> UniqueSyncRegs;
  Instruction *FirstSyncRegion = nullptr;
  for (Task *SubT : T->subtasks()) {
    UniqueSyncRegs.insert(SubT->getDetach()->getSyncRegion());
    if (!FirstSyncRegion)
      FirstSyncRegion = cast<Instruction>(
          SubT->getDetach()->getSyncRegion());
  }
  NumUniqueSyncRegs += UniqueSyncRegs.size();
  // Skip this task if there's only one unique sync region.
  if (UniqueSyncRegs.size() < 2)
    return false;

  bool Changed = false;
  SmallPtrSet<Value *, 1> NonRedundantSyncRegs;
  for (Spindle *S : T->spindles()) {
    // Only consider spindles that might have tasks in parallel.
    if (MPTasks.TaskList[S].empty()) continue;

    // Filter the task list of S to exclude tasks in parallel with the entry.
    SmallPtrSet<const Task *, 4> LocalTaskList;
    for (const Task *MPTask : MPTasks.TaskList[S])
      if (!EntryTaskList.count(MPTask))
        LocalTaskList.insert(MPTask);
    if (LocalTaskList.empty()) continue;

    // Iterate over outgoing edges of S to find discriminating syncs.
    for (Spindle::SpindleEdge &Edge : S->out_edges())
      if (const SyncInst *Y = dyn_cast<SyncInst>(Edge.second->getTerminator()))
        if (syncIsDiscriminating(Y->getSyncRegion(), LocalTaskList)) {
          ++NumDiscriminatingSyncs;
          LLVM_DEBUG(dbgs() << "Found discriminating sync " << *Y << "\n");
          NonRedundantSyncRegs.insert(Y->getSyncRegion());
          for (const Task *MPTask : LocalTaskList)
            NonRedundantSyncRegs.insert(MPTask->getDetach()->getSyncRegion());
        }
  }

  // Replace all redundant sync regions with the first sync region.
  for (Value *SR : UniqueSyncRegs) {
    if (!NonRedundantSyncRegs.count(SR) && SR != FirstSyncRegion) {
      LLVM_DEBUG(dbgs() << "Replacing " << *SR << " with " << *FirstSyncRegion
                 << "\n");
      Changed = true;
      SR->replaceAllUsesWith(FirstSyncRegion);
      // Ensure that the first sync region is in the entry block of T.
      if (FirstSyncRegion->getParent() != T->getEntry())
        FirstSyncRegion->moveAfter(&*T->getEntry()->getFirstInsertionPt());
    }
  }

  return Changed;
}

bool llvm::simplifySyncs(Task *T, MaybeParallelTasks &MPTasks) {
  bool Changed = false;

  LLVM_DEBUG(dbgs() <<
             "Simplifying syncs in task @ " << T->getEntry()->getName() <<
             "\n");

  // Remove redundant syncs.  This optimization might not be necessary here,
  // because SimplifyCFG seems to do a good job removing syncs that cannot sync
  // anything.
  Changed |= removeRedundantSyncs(MPTasks, T);

  // Remove redundant sync regions.
  Changed |= removeRedundantSyncRegions(MPTasks, T);

  return Changed;
}  

static bool taskCanThrow(const Task *T) {
  for (const Spindle *S : T->spindles())
    for (const BasicBlock *BB : S->blocks())
      if (isa<InvokeInst>(BB->getTerminator()))
        return true;
  return false;
}

static bool taskCanReachContinuation(Task *T) {
  if (T->isRootTask())
    return true;

  DetachInst *DI = T->getDetach();
  BasicBlock *Continue = DI->getContinue();
  for (BasicBlock *Pred : predecessors(Continue)) {
    if (ReattachInst *RI = dyn_cast<ReattachInst>(Pred->getTerminator()))
      if (T->encloses(RI->getParent()))
        return true;
  }

  return false;
}

static bool detachImmediatelySyncs(DetachInst *DI) {
  Instruction *I = DI->getParent()->getFirstNonPHIOrDbgOrLifetime();
  return isa<SyncInst>(I);
}

bool llvm::simplifyTask(Task *T) {
  if (T->isRootTask())
    return false;

  LLVM_DEBUG(dbgs() <<
             "Simplifying task @ " << T->getEntry()->getName() << "\n");

  bool Changed = false;
  DetachInst *DI = T->getDetach();

  // If T's detach has an unwind dest and T cannot throw, remove the unwind
  // destination from T's detach.
  if (DI->hasUnwindDest()) {
    if (!taskCanThrow(T)) {
      removeUnwindEdge(DI->getParent());
      // removeUnwindEdge will invalidate the DI pointer.  Get the new DI
      // pointer.
      DI = T->getDetach();
      Changed = true;
    }
  }

  if (!taskCanReachContinuation(T)) {
    // This optimization assumes that if a task cannot reach its continuation
    // then we shouldn't bother spawning it.  The task might perform code that
    // can reach the unwind destination, however.
    SerializeDetach(DI, T);
    Changed = true;
  } else if (detachImmediatelySyncs(DI)) {
    SerializeDetach(DI, T);
    Changed = true;
  }

  return Changed;
}

static bool canRemoveTaskFrame(const Spindle *TF, MaybeParallelTasks &MPTasks) {
  Value *TFCreate = TF->getTaskFrameCreate();
  if (!TFCreate)
    // Ignore implicit taskframes created from the start of a task that does not
    // explicitly use another taskframe.
    return false;

  // We can remove a taskframe if it does not allocate any stack storage of its
  // own and it does not contain any distinguishing syncs.

  // We only need to check the spindles in the taskframe itself for these
  // properties.  We do not need to check the task that uses this taskframe.
  const Task *UserT = TF->getTaskFromTaskFrame();

  if (!UserT && !MPTasks.TaskList[TF].empty() && getTaskFrameResume(TFCreate))
    // Landingpads perform an implicit sync, so if there are logically parallel
    // tasks with this unassociated taskframe and it has a resume destination,
    // then it has a distinguishing sync.
    return false;

  // Create filter for MPTasks of tasks from parent of task UserT, if UserT
  // exists.
  SmallPtrSet<const Task *, 4> EntryTaskList;
  if (UserT)
    for (const Task *MPTask : MPTasks.TaskList[UserT->getEntrySpindle()])
      EntryTaskList.insert(MPTask);

  for (const Spindle *S : TF->taskframe_spindles()) {
    // Skip spindles in the user task.
    if (UserT && UserT->contains(S))
      continue;

    // Filter the task list of S to exclude tasks in parallel with the entry.
    SmallPtrSet<const Task *, 4> LocalTaskList;
    for (const Task *MPTask : MPTasks.TaskList[S])
      if (!EntryTaskList.count(MPTask))
        LocalTaskList.insert(MPTask);

    for (const BasicBlock *BB : S->blocks()) {
      // Skip spindles that are placeholders.
      if (isPlaceholderSuccessor(S->getEntry()))
        continue;

      // We cannot remove taskframes that perform allocas.  Doing so would cause
      // these allocas to affect the stack of the parent taskframe.
      for (const Instruction &I : *BB)
        if (isa<AllocaInst>(I))
          return false;

      // We cannot remove taskframes that contain discriminating syncs.  Doing
      // so would cause these syncs to sync tasks spawned in the parent
      // taskframe.
      if (const SyncInst *SI = dyn_cast<SyncInst>(BB->getTerminator()))
        if (syncIsDiscriminating(SI->getSyncRegion(), LocalTaskList))
          return false;
    }
  }

  return true;
}

static bool skipForHoisting(const Instruction *I,
                            SmallPtrSetImpl<const Instruction *> &NotHoisted) {
  if (I->isTerminator() || isTapirIntrinsic(Intrinsic::taskframe_create, I) ||
      isTapirIntrinsic(Intrinsic::syncregion_start, I) ||
      isa<AllocaInst>(I))
    return true;

  if (const CallInst *CI = dyn_cast<CallInst>(I))
    if (!(CI->doesNotAccessMemory() || CI->onlyAccessesArgMemory()))
      return true;

  for (const Value *V : I->operand_values())
    if (const Instruction *I = dyn_cast<Instruction>(V))
      if (NotHoisted.count(I))
        return true;

  return false;
}

static bool hoistOutOfTaskFrame(Instruction *TFCreate) {
  bool Changed = false;

  BasicBlock *Entry = TFCreate->getParent();
  // We'll move instructions immediately before the taskframe.create
  // instruction.
  BasicBlock::iterator InsertPoint = Entry->begin();

  // Scan the instructions in the entry block and find instructions to hoist
  // before the taskframe.create.
  SmallPtrSet<const Instruction *, 8> NotHoisted;
  for (BasicBlock::iterator I = Entry->begin(), E = Entry->end(); I != E; ) {
    Instruction *Start = &*I++;
    if (skipForHoisting(Start, NotHoisted)) {
      NotHoisted.insert(Start);
      continue;
    }

    while (!skipForHoisting(&*I, NotHoisted))
      ++I;

    // Move the instructions
    Entry->getInstList().splice(InsertPoint, Entry->getInstList(),
                                Start->getIterator(), I);

    Changed = true;
  }

  return Changed;
}

bool llvm::simplifyTaskFrames(TaskInfo &TI, DominatorTree &DT) {
  // We compute maybe-parallel tasks here, to ensure the analysis is properly
  // discarded if the CFG changes.
  MaybeParallelTasks MPTasks;
  TI.evaluateParallelState<MaybeParallelTasks>(MPTasks);

  bool Changed = false;

  // Get the set of taskframes we can erase.
  SmallVector<Instruction *, 8> TaskFramesToErase;
  SmallVector<Instruction *, 8> TaskFramesToOptimize;
  for (Spindle *TFRoot : TI.getRootTask()->taskframe_roots()) {
    for (Spindle *TF : post_order<TaskFrames<Spindle *>>(TFRoot)) {
      if (canRemoveTaskFrame(TF, MPTasks))
        TaskFramesToErase.push_back(
            cast<Instruction>(TF->getTaskFrameCreate()));
      else if (Value *TFCreate = TF->getTaskFrameCreate())
        TaskFramesToOptimize.push_back(cast<Instruction>(TFCreate));
    }
  }

  // First handle hoisting instructions out of a taskframe entry block, since
  // this transformation does not change the CFG.
  for (Instruction *TFCreate : TaskFramesToOptimize) {
    LLVM_DEBUG(dbgs() <<
               "Hoisting instructions out of taskframe " << *TFCreate << "\n");
    Changed |= hoistOutOfTaskFrame(TFCreate);
  }

  // Now delete any taskframes we don't need.
  for (Instruction *TFCreate : TaskFramesToErase) {
    LLVM_DEBUG(dbgs() <<
               "Removing taskframe " << *TFCreate << "\n");
    eraseTaskFrame(TFCreate, &DT);
    ++NumTaskFramesErased;
    Changed = true;
  }

  return Changed;
}


/// Call SimplifyCFG on all the blocks in the function,
/// iterating until no more changes are made.
static bool iterativelySimplifyCFG(Function &F, const TargetTransformInfo &TTI,
                                   const SimplifyCFGOptions &Options) {
  bool Changed = false;
  bool LocalChange = true;

  SmallVector<std::pair<const BasicBlock *, const BasicBlock *>, 32> Edges;
  FindFunctionBackedges(F, Edges);
  SmallPtrSet<BasicBlock *, 16> LoopHeaders;
  for (unsigned i = 0, e = Edges.size(); i != e; ++i)
    LoopHeaders.insert(const_cast<BasicBlock *>(Edges[i].second));

  while (LocalChange) {
    LocalChange = false;

    // Loop over all of the basic blocks and remove them if they are unneeded.
    for (Function::iterator BBIt = F.begin(); BBIt != F.end(); ) {
      if (simplifyCFG(&*BBIt++, TTI, Options, &LoopHeaders)) {
        LocalChange = true;
        ++NumSimpl;
      }
    }
    Changed |= LocalChange;
  }
  return Changed;
}

static bool simplifyFunctionCFG(Function &F, const TargetTransformInfo &TTI,
                                const SimplifyCFGOptions &Options) {
  bool EverChanged = removeUnreachableBlocks(F);
  EverChanged |= iterativelySimplifyCFG(F, TTI, Options);

  // If neither pass changed anything, we're done.
  if (!EverChanged) return false;

  // iterativelySimplifyCFG can (rarely) make some loops dead.  If this happens,
  // removeUnreachableBlocks is needed to nuke them, which means we should
  // iterate between the two optimizations.  We structure the code like this to
  // avoid rerunning iterativelySimplifyCFG if the second pass of
  // removeUnreachableBlocks doesn't do anything.
  if (!removeUnreachableBlocks(F))
    return true;

  do {
    EverChanged = iterativelySimplifyCFG(F, TTI, Options);
    EverChanged |= removeUnreachableBlocks(F);
  } while (EverChanged);

  return true;
}

namespace {
struct TaskSimplify : public FunctionPass {
  static char ID; // Pass identification, replacement for typeid
  TaskSimplify() : FunctionPass(ID) {
    initializeTaskSimplifyPass(*PassRegistry::getPassRegistry());
  }

  bool runOnFunction(Function &F) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AssumptionCacheTracker>();
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<TargetTransformInfoWrapperPass>();
    AU.addRequired<TaskInfoWrapperPass>();
    AU.addPreserved<GlobalsAAWrapperPass>();
  }
};
}

char TaskSimplify::ID = 0;
INITIALIZE_PASS_BEGIN(TaskSimplify, "task-simplify",
                "Simplify Tapir tasks", false, false)
INITIALIZE_PASS_DEPENDENCY(AssumptionCacheTracker)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetTransformInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TaskInfoWrapperPass)
INITIALIZE_PASS_END(TaskSimplify, "task-simplify",
                "Simplify Tapir tasks", false, false)

namespace llvm {
Pass *createTaskSimplifyPass() { return new TaskSimplify(); }
} // end namespace llvm

/// runOnFunction - Run through all tasks in the function and simplify them in
/// post order.
///
bool TaskSimplify::runOnFunction(Function &F) {
  if (skipFunction(F))
    return false;

  DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  TaskInfo &TI = getAnalysis<TaskInfoWrapperPass>().getTaskInfo();
  bool SplitBlocks = splitTaskFrameCreateBlocks(F, &DT, &TI);
  TI.findTaskFrameTree();
  if (TI.isSerial() && !TI.foundChildTaskFrames())
    return false;

  SimplifyCFGOptions Options;
  auto &TTI = getAnalysis<TargetTransformInfoWrapperPass>().getTTI(F);
  Options.AC = &getAnalysis<AssumptionCacheTracker>().getAssumptionCache(F);

  bool Changed = false;
  LLVM_DEBUG(dbgs() << "TaskSimplify running on function " << F.getName()
             << "\n");

  if (SimplifyTaskFrames) {
    // Simplify taskframes.  If anything changed, update the analysis.
    Changed |= simplifyTaskFrames(TI, DT);
    if (Changed) {
      TI.recalculate(F, DT);
      if (TI.isSerial()) {
        if (PostCleanupCFG && SplitBlocks)
          simplifyFunctionCFG(F, TTI, Options);
        return Changed;
      }
    }
  }

  // Evaluate the tasks that might be in parallel with each spindle, and
  // determine number of discriminating syncs: syncs that sync a subset of the
  // detached tasks, based on sync regions.
  MaybeParallelTasks MPTasks;
  TI.evaluateParallelState<MaybeParallelTasks>(MPTasks);

  // Simplify syncs in each task in the function.
  for (Task *T : post_order(TI.getRootTask()))
    Changed |= simplifySyncs(T, MPTasks);

  // Simplify each task in the function.
  for (Task *T : post_order(TI.getRootTask()))
    Changed |= simplifyTask(T);

  if (PostCleanupCFG && (Changed | SplitBlocks))
    Changed |= simplifyFunctionCFG(F, TTI, Options);

  return Changed;
}

PreservedAnalyses TaskSimplifyPass::run(Function &F,
                                        FunctionAnalysisManager &AM) {
  if (F.empty())
    return PreservedAnalyses::all();

  DominatorTree &DT = AM.getResult<DominatorTreeAnalysis>(F);
  TaskInfo &TI = AM.getResult<TaskAnalysis>(F);
  bool SplitBlocks = splitTaskFrameCreateBlocks(F, &DT, &TI);
  TI.findTaskFrameTree();
  if (TI.isSerial() && !TI.foundChildTaskFrames())
    return PreservedAnalyses::all();

  SimplifyCFGOptions Options;
  auto &TTI = AM.getResult<TargetIRAnalysis>(F);
  Options.AC = &AM.getResult<AssumptionAnalysis>(F);

  bool Changed = false;
  LLVM_DEBUG(dbgs() << "TaskSimplify running on function " << F.getName()
             << "\n");

  if (SimplifyTaskFrames) {
    // Simplify taskframes.  If anything changed, update the analysis.
    Changed |= simplifyTaskFrames(TI, DT);
    if (Changed) {
      TI.recalculate(F, DT);
      if (TI.isSerial()) {
        if (PostCleanupCFG && SplitBlocks)
          simplifyFunctionCFG(F, TTI, Options);
        PreservedAnalyses PA;
        PA.preserve<GlobalsAA>();
        return PA;
      }
    }
  }

  // Evaluate the tasks that might be in parallel with each spindle, and
  // determine number of discriminating syncs: syncs that sync a subset of the
  // detached tasks, based on sync regions.
  MaybeParallelTasks MPTasks;
  TI.evaluateParallelState<MaybeParallelTasks>(MPTasks);

  // Simplify syncs in each task in the function.
  for (Task *T : post_order(TI.getRootTask()))
    Changed |= simplifySyncs(T, MPTasks);

  // Simplify each task in the function.
  for (Task *T : post_order(TI.getRootTask()))
    Changed |= simplifyTask(T);

  if (PostCleanupCFG && (Changed | SplitBlocks))
    Changed |= simplifyFunctionCFG(F, TTI, Options);

  if (!Changed)
    return PreservedAnalyses::all();
  PreservedAnalyses PA;
  PA.preserve<GlobalsAA>();
  return PA;
}
