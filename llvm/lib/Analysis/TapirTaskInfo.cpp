//===- TapirTaskInfo.cpp - Tapir task calculator --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the TapirTaskInfo class that is used to identify parallel
// tasks and spindles in Tapir.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/ScopeExit.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/IteratedDominanceFrontier.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DebugLoc.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/PassManager.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include <algorithm>

using namespace llvm;

#define DEBUG_TYPE "task-info"

// Statistics
STATISTIC(NumBasicBlocks, "Number of basic blocks analyzed.");
STATISTIC(NumTasks, "Number of tasks found.");
STATISTIC(NumSpindles, "Number of spindles found.");
STATISTIC(NumSharedEHSpindles, "Number of shared exception-handling spindles "
          "found in this function.");
STATISTIC(NumBasicBlocksInPF,
          "Number of basic blocks analyzed in parallel functions.");
STATISTIC(NumTasksInPF, "Number of tasks found in parallel functions.");
STATISTIC(NumSpindlesInPF, "Number of spindles found in parallel functions.");

// Always verify taskinfo if expensive checking is enabled.
#ifdef EXPENSIVE_CHECKS
bool llvm::VerifyTaskInfo = true;
#else
bool llvm::VerifyTaskInfo = false;
#endif
static cl::opt<bool, true>
    VerifyTaskInfoX("verify-task-info", cl::location(VerifyTaskInfo),
                    cl::Hidden, cl::desc("Verify task info (time consuming)"));

static cl::opt<bool> PrintTaskFrameTree(
    "print-taskframe-tree", cl::init(false),
    cl::Hidden, cl::desc("Print tree of task frames."));

static cl::opt<bool> PrintMayHappenInParallel(
    "print-may-happen-in-parallel", cl::init(false),
    cl::Hidden, cl::desc("Print may-happen-in-parallel analysis results "
                         "derived from Tapir control flow."));

/// Returns the taskframe.create at the start of BB if one exists, nullptr
/// otherwise.
static const Instruction *getTaskFrameCreate(const BasicBlock *BB) {
  if (const IntrinsicInst *II = dyn_cast<IntrinsicInst>(&BB->front()))
    if (Intrinsic::taskframe_create == II->getIntrinsicID())
      return &BB->front();
  return nullptr;
}
static Instruction *getTaskFrameCreate(BasicBlock *BB) {
  return const_cast<Instruction *>(
      getTaskFrameCreate(const_cast<const BasicBlock *>(BB)));
}

static bool isCanonicalTaskFrameEnd(const Instruction *TFEnd) {
  // Check that the last instruction in the basic block containing TFEnd is
  // TFEnd.
  const Instruction *Term = &TFEnd->getParent()->back();
  if (!Term || isa<SyncInst>(Term) || isa<ReattachInst>(Term))
    return false;

  const Instruction *Prev = Term->getPrevNode();
  if (!Prev || Prev != TFEnd)
    return false;

  return true;
}

// Check if the given instruction is an intrinsic with the specified ID.  If a
// value \p V is specified, then additionally checks that the first argument of
// the intrinsic matches \p V.  This function matches the behavior of
// isTapirIntrinsic in Transforms/Utils/TapirUtils.
static bool isTapirIntrinsic(Intrinsic::ID ID, const Instruction *I,
                             const Value *V = nullptr) {
  if (const CallBase *CB = dyn_cast<CallBase>(I))
    if (const Function *Called = CB->getCalledFunction())
      if (ID == Called->getIntrinsicID())
        if (!V || (V == CB->getArgOperand(0)))
          return true;
  return false;
}

// Check if the basic block terminates a taskframe via a taskframe.end.
static bool endsUnassociatedTaskFrame(const BasicBlock *B) {
  const Instruction *Prev = B->getTerminator()->getPrevNode();
  if (!Prev)
    return false;
  if (isTapirIntrinsic(Intrinsic::taskframe_end, Prev) &&
      isCanonicalTaskFrameEnd(Prev))
    return true;
  return false;
}

/// Checks if the given taskframe.create instruction is in canonical form.  This
/// function mirrors the behavior of needToSplitTaskFrameCreate in
/// Transforms/Utils/TapirUtils.
static bool isCanonicalTaskFrameCreate(const Instruction *TFCreate) {
  // If the taskframe.create is not the first instruction, split.
  if (TFCreate != &TFCreate->getParent()->front())
    return false;

  // The taskframe.create is at the front of the block.  Check that we have a
  // single predecessor.
  const BasicBlock *Pred = TFCreate->getParent()->getSinglePredecessor();
  if (!Pred)
    return false;

  // Check that the single predecessor has a single successor.
  if (!Pred->getSingleSuccessor())
    return false;

  // Check whether the single predecessor is terminated with a sync.
  if (isa<SyncInst>(Pred->getTerminator()))
    return false;

  // If the taskframe.create has no users, ignore it.
  if (TFCreate->user_empty())
    return false;

  // Check that the uses of the taskframe.create are canonical as well.
  for (const User *U : TFCreate->users()) {
    if (const Instruction *I = dyn_cast<Instruction>(U)) {
      if (isTapirIntrinsic(Intrinsic::taskframe_use, I) ||
          isTapirIntrinsic(Intrinsic::taskframe_resume, I))
        return true;
      if (isTapirIntrinsic(Intrinsic::taskframe_end, I))
        return isCanonicalTaskFrameEnd(I);
    }
  }
  return true;
}

/// Returns true if the given instruction performs a taskframe resume, false
/// otherwise.
static bool isDetachedRethrow(const Instruction *I,
                              const Value *SyncReg = nullptr) {
  if (const InvokeInst *II = dyn_cast<InvokeInst>(I))
    if (const Function *Called = II->getCalledFunction())
      if (Intrinsic::detached_rethrow == Called->getIntrinsicID())
        if (!SyncReg || (SyncReg == II->getArgOperand(0)))
          return true;
  return false;
}

/// Returns true if the given instruction performs a taskframe resume, false
/// otherwise.
static bool isTaskFrameResume(const Instruction *I,
                              const Value *TaskFrame = nullptr) {
  if (const InvokeInst *II = dyn_cast<InvokeInst>(I))
    if (const Function *Called = II->getCalledFunction())
      if (Intrinsic::taskframe_resume == Called->getIntrinsicID())
        if (!TaskFrame || (TaskFrame == II->getArgOperand(0)))
          return true;
  return false;
}

//===----------------------------------------------------------------------===//
// Spindle implementation
//

/// Return true if this spindle is a shared EH spindle.
bool Spindle::isSharedEH() const {
  return getParentTask()->containsSharedEH(this);
}

/// Return true if this spindle is the continuation of a detached task.
bool Spindle::isTaskContinuation() const {
  for (const Spindle *Pred : predecessors(this))
    if (predInDifferentTask(Pred))
      return true;
  return false;
}

/// Return true if the successor spindle Succ is part of the same task as this
/// spindle.
bool Spindle::succInSameTask(const Spindle *Succ) const {
  // If this spindle is a shared EH spindle, the successor must be a shared EH
  // spindle tracked by the same task.
  if (isSharedEH())
    return (Succ->isSharedEH() && (getParentTask() == Succ->getParentTask()));

  // Otherwise we have an ordinary spindle.  If this spindle and Succ are both
  // properly contained in ParentTask, return true;
  if (getParentTask()->contains(Succ))
    return true;
  else {
    // Otherwise, check if Succ is a shared EH spindle tracked by the parent of
    // ParentTask.
    const Task *GrandParent = getParentTask()->getParentTask();
    return (GrandParent && GrandParent->containsSharedEH(Succ));
  }
}

/// Return true if the successor spindle Succ is part of the same task as this
/// spindle.
bool Spindle::succInSubTask(const Spindle *Succ) const {
  return (Succ->getParentTask()->getParentTask() == getParentTask());
}

/// Return the taskframe.create intrinsic at the start of the entry block of
/// this Spindle, or nullptr if no such intrinsic exists.
Value *Spindle::getTaskFrameCreate() const {
  if (Instruction *TFCreate = ::getTaskFrameCreate(getEntry()))
    if (isCanonicalTaskFrameCreate(TFCreate))
      return TFCreate;
  return nullptr;
}

/// Return the task associated with this taskframe, or nullptr of this spindle
/// is not a taskframe.
Task *Spindle::getTaskFromTaskFrame() const {
  if (TaskFrameUser) return TaskFrameUser;
  if (getParentTask()->getEntrySpindle() == this) return getParentTask();
  return nullptr;
}

BasicBlock *Spindle::getTaskFrameContinuation() const {
  // If this taskframe is used by a task, return that task's continuation.
  if (TaskFrameUser)
    return TaskFrameUser->getContinuationSpindle()->getEntry();

  Value *TFCreate = getTaskFrameCreate();
  if (!TFCreate)
    return nullptr;
  // Scan the uses of the taskframe.create for a canonical taskframe.end.
  for (User *U : TFCreate->users())
    if (Instruction *I = dyn_cast<Instruction>(U)) {
      if (isTapirIntrinsic(Intrinsic::taskframe_end, I) &&
          isCanonicalTaskFrameEnd(I))
        return I->getParent()->getSingleSuccessor();
    }
  return nullptr;
}

//===----------------------------------------------------------------------===//
// Task implementation
//

#if !defined(NDEBUG) || defined(LLVM_ENABLE_DUMP)
LLVM_DUMP_METHOD void Task::dump() const { print(dbgs()); }

LLVM_DUMP_METHOD void Task::dumpVerbose() const {
  print(dbgs(), /*Depth=*/0, /*Verbose=*/true);
}
#endif

// Get the shared EH spindles that this task can exit to and append them to
// SpindleVec.
void Task::getSharedEHExits(SmallVectorImpl<Spindle *> &SpindleVec) const {
  if (isRootTask()) return;
  if (!getParentTask()->tracksSharedEHSpindles()) return;

  // Scan the successors of the spindles in this task to find shared EH exits.
  SmallVector<Spindle *, 4> WorkList;
  SmallPtrSet<Spindle *, 4> Visited;
  for (Spindle *S : getSpindles())
    for (Spindle *Succ : successors(S))
      if (getParentTask()->containsSharedEH(Succ))
        WorkList.push_back(Succ);

  // Perform a DFS of the shared EH exits to push each one onto SpindleVec and
  // continue searching for more shared EH exits.
  while (!WorkList.empty()) {
    Spindle *EHExit = WorkList.pop_back_val();
    if (!Visited.insert(EHExit).second) continue;

    // Push EHExit onto SpindleVec.
    SpindleVec.push_back(EHExit);

    // Scan the successors of EHExit for more shared EH exits.
    for (Spindle *Succ : successors(EHExit))
      if (getParentTask()->containsSharedEH(Succ))
        WorkList.push_back(Succ);
  }
}

// Get the shared EH spindles that this task can exit to and append them to
// SpindleVec.
bool Task::isSharedEHExit(const Spindle *SharedEH) const {
  if (isRootTask()) return false;
  // Quickly confirm that the given spindle is a shared EH spindle tracked by
  // the parent.
  if (!getParentTask()->containsSharedEH(SharedEH)) return false;

  // Scan the successors of the spindles in this task to find shared EH exits.
  SmallVector<Spindle *, 4> WorkList;
  SmallPtrSet<Spindle *, 4> Visited;
  for (Spindle *S : getSpindles())
    for (Spindle *Succ : successors(S))
      if (SharedEH == Succ)
        return true;
      else if (getParentTask()->containsSharedEH(Succ))
        WorkList.push_back(Succ);

  // Perform a DFS of the shared EH exits to push each one onto SpindleVec and
  // continue searching for more shared EH exits.
  while (!WorkList.empty()) {
    Spindle *EHExit = WorkList.pop_back_val();
    if (!Visited.insert(EHExit).second) continue;

    // Check if this exit is the shared EH exit we're looking for.
    if (SharedEH == EHExit)
      return true;

    // Scan the successors of EHExit for more shared EH exits.
    for (Spindle *Succ : successors(EHExit))
      if (getParentTask()->containsSharedEH(Succ))
        WorkList.push_back(Succ);
  }

  return false;
}

//===----------------------------------------------------------------------===//
// TaskInfo implementation
//

// Add the unassociated spindles to the task T in order of a DFS CFG traversal
// starting at the entry block of T.
static void
AssociateWithTask(TaskInfo *TI, Task *T,
                  SmallPtrSetImpl<Spindle *> &UnassocSpindles) {
  SmallVector<Spindle *, 8> WorkList;
  SmallPtrSet<Spindle *, 8> Visited;
  // Add the successor spindles of the entry block of T to the worklist.
  Spindle *Entry = T->getEntrySpindle();
  for (BasicBlock *Exit : Entry->spindle_exits())
    for (BasicBlock *Child : successors(Exit))
      if (Spindle *S = TI->getSpindleFor(Child))
        if (UnassocSpindles.count(S))
          WorkList.push_back(S);

  // Perform a DFS CFG traversal of the spindles associated with task T, and add
  // each spindle to T in that order.
  while (!WorkList.empty()) {
    Spindle *S = WorkList.pop_back_val();
    if (!Visited.insert(S).second) continue;

    // Add the spindle S to T.
    LLVM_DEBUG(dbgs() << "Adding spindle@" << S->getEntry()->getName()
                      << " to task@" << Entry->getEntry()->getName() << "\n");
    TI->addSpindleToTask(S, T);

    // Add the successor spindles of S that are associated with T to the
    // worklist.
    for (BasicBlock *Exit : S->spindle_exits())
      for (BasicBlock *Child : successors(Exit))
        if (Spindle *S = TI->getSpindleFor(Child))
          if (UnassocSpindles.count(S))
            WorkList.push_back(S);
  }

  // We can have remaining unassociated spindles when subtasks share
  // exception-handling spindles.
  for (Spindle *S : UnassocSpindles)
    if (!Visited.count(S)) {
      TI->addEHSpindleToTask(S, T);
      ++NumSharedEHSpindles;
    }

  assert(T->getNumSpindles() + T->getNumSharedEHSpindles() ==
         UnassocSpindles.size() + 1 &&
         "Not all unassociated spindles were associated with task.");
}

// Add the unassociated blocks to the spindle S in order of a DFS CFG traversal
// starting at the entry block of S.
static void
AssociateWithSpindle(TaskInfo *TI, Spindle *S,
                     SmallPtrSetImpl<BasicBlock *> &UnassocBlocks) {
  SmallVector<BasicBlock *, 32> WorkList;
  SmallPtrSet<BasicBlock *, 32> Visited;
  // Add the successor blocks of the entry of S to the worklist.
  for (BasicBlock *Child : successors(S->getEntry()))
    if (UnassocBlocks.count(Child))
      WorkList.push_back(Child);

  // Perform a DFS CFG traversal of the blocks associated with spindle S, and
  // add each block to S in that order.
  while (!WorkList.empty()) {
    BasicBlock *BB = WorkList.pop_back_val();
    if (!Visited.insert(BB).second) continue;

    // Add the block BB to S.
    TI->addBlockToSpindle(*BB, S);

    // Add the successors of block BB that are associated with S to the
    // worklist.
    for (BasicBlock *Child : successors(BB))
      if (UnassocBlocks.count(Child))
        WorkList.push_back(Child);
  }

  assert(S->getNumBlocks() == UnassocBlocks.size() + 1 &&
         "Not all unassociated blocks were associated with spindle.");
}

// Helper function to add spindle edges to spindles.
static void computeSpindleEdges(TaskInfo *TI) {
  // Walk all spindles in the CFG to find all spindle edges.
  SmallVector<Spindle *, 8> WorkList;
  SmallPtrSet<Spindle *, 8> Visited;

  WorkList.push_back(TI->getRootTask()->getEntrySpindle());
  while (!WorkList.empty()) {
    Spindle *S = WorkList.pop_back_val();

    if (!Visited.insert(S).second) continue;

    // Examine all outgoing CFG edges from this spindle and create a spindle
    // edge for each one.  Filter out self-edges.
    for (BasicBlock *Exit : S->spindle_exits()) {
      for (BasicBlock *SB : successors(Exit)) {
        Spindle *Succ = TI->getSpindleFor(SB);
        if (Succ != S) {
          S->addSpindleEdgeTo(Succ, Exit);
          // Add this successor spindle for processing.
          WorkList.push_back(Succ);
        }
      }
    }
  }
}

// Search the PHI nodes in BB for a user of Val.  Return Val if no PHI node in
// BB uses Val.
static Value *FindUserAmongPHIs(Value *Val, BasicBlock *BB) {
  for (PHINode &PN : BB->phis()) {
    if (Val->getType() != PN.getType())
      continue;
    for (Value *Incoming : PN.incoming_values())
      if (Incoming == Val)
        return &PN;
  }
  return Val;
}

// Helper function to record the normal and exceptional continuation spindles
// for each task.
static void recordContinuationSpindles(TaskInfo *TI) {
  for (Task *T : post_order(TI->getRootTask())) {
    if (T->isRootTask())
      continue;

    DetachInst *DI = T->getDetach();
    Spindle *S = TI->getSpindleFor(DI->getParent());

    // Set the continuation spindle for the spawned task.
    assert(S != TI->getSpindleFor(DI->getContinue()) &&
           "Detach and continuation should appear in different spindles");
    T->setContinuationSpindle(TI->getSpindleFor(DI->getContinue()));

    // If the detach has an unwind destination, set the exceptional continuation
    // spindle for the spawned task.
    if (DI->hasUnwindDest()) {
      BasicBlock *Unwind = DI->getUnwindDest();
      // We also follow the use-def chain for the landingpad of the
      // detach-unwind to determine the value of the landingpad in the
      // exceptional continuation.
      Value *LPadVal = Unwind->getLandingPadInst();
      // There should be no substantive code between the detach unwind and the
      // exceptional continuation.  Instead, we expect a sequence of basic
      // blocks in the parent spindle S that merges control flow from different
      // exception-handling code together.  Each basic block in this sequence
      // should have a unique successor, and the landingpad of the unwind
      // destination should propagate to the exceptional continuation through
      // PHI nodes in these blocks.
      while (TI->getSpindleFor(Unwind) == S) {
        assert(Unwind->getUniqueSuccessor() &&
               "Unwind destination of detach has many successors, but belongs to "
               "the same spindle as the detach.");
        Unwind = Unwind->getUniqueSuccessor();
        LPadVal = FindUserAmongPHIs(LPadVal, Unwind);
      }
      // Set the exceptional continuation spindle for this task.
      Spindle *UnwindSpindle = TI->getSpindleFor(Unwind);
      LLVM_DEBUG({
          // Check that Task T is indeed a predecessor of this unwind spindle.
          bool TaskIsPredecessor = false;
          for (Spindle *Pred : predecessors(UnwindSpindle)) {
            if (TI->getTaskFor(Pred) == T) {
              TaskIsPredecessor = true;
              break;
            }
          }
          if (!TaskIsPredecessor)
            // Report that an unusual exceptional continuation was found.  This
            // can happen, for example, due to splitting of landing pads or when
            // part of the CFG becomes disconnected due to function inlining.
            dbgs() << "TaskInfo: Found exceptional continuation at "
                   << Unwind->getName() << " with no predecessors in task\n";
        });
      T->setEHContinuationSpindle(UnwindSpindle, LPadVal);
    }
  }
}

static bool shouldCreateSpindleAtDetachUnwind(const BasicBlock *MaybeUnwind,
                                              const TaskInfo &TI,
                                              const DominatorTree &DT) {
  // Check that MaybeUnwind is a detach-unwind block.
  if (!MaybeUnwind->isLandingPad())
    return false;
  const BasicBlock *Pred = MaybeUnwind->getSinglePredecessor();
  if (!Pred) {
    unsigned NumReachablePredecessors = 0;
    for (const BasicBlock *P : predecessors(MaybeUnwind)) {
      if (DT.isReachableFromEntry(P)) {
        ++NumReachablePredecessors;
        Pred = P;
      }
    }
    if (NumReachablePredecessors > 1)
      return false;
  }
  if (!isa<DetachInst>(Pred->getTerminator()))
    return false;

  const BasicBlock *UnwindSpindleEntry = MaybeUnwind;
  // First suppose that a more appropriate detach-unwind spindle entry exists
  // later on the chain of unique successors of Unwind.  Traverse this chain of
  // unique successors of Unwind until we find a spindle entry.
  while (!TI.getSpindleFor(UnwindSpindleEntry)) {
    if (isa<SyncInst>(UnwindSpindleEntry->getTerminator()))
      // We found a sync instruction terminating a basic block along the chain
      // of unique successors of Unwind.  Such a sync instruction should appear
      // within a detach-unwind spindle.
      return true;

    const BasicBlock *Succ = UnwindSpindleEntry->getUniqueSuccessor();
    if (!Succ)
      // We discovered a basic block without a unique successor before we found
      // an appropriate detach-unwind spindle entry.  Return true, so a new
      // detach-unwind spindle entry will be created.
      return true;
    UnwindSpindleEntry = Succ;
  }

  // Check the type of spindle discovered, to make sure it's appropriate for a
  // detach-unwind spindle.
  const Spindle *S = TI.getSpindleFor(UnwindSpindleEntry);
  return !S->isPhi();
}

static bool isTaskFrameCreateSpindleEntry(const BasicBlock *B) {
  if (const Instruction *TFCreate = getTaskFrameCreate(B))
    if (isCanonicalTaskFrameCreate(TFCreate))
      return true;
  return false;
}

void TaskInfo::analyze(Function &F, DominatorTree &DomTree) {
  // We first compute defining blocks and IDFs based on the detach and sync
  // instructions.
  DenseMap<const BasicBlock *, unsigned> BBNumbers;
  unsigned NextBBNum = 0;
  int64_t BBCount = 0, SpindleCount = 0, TaskCount = 0;
  SmallPtrSet<BasicBlock *, 32> DefiningBlocks;
  // Go through each block to figure out where tasks begin and where sync
  // instructions occur.
  for (BasicBlock &B : F) {
    BBCount++;
    BBNumbers[&B] = NextBBNum++;
    if (&F.getEntryBlock() == &B) {
      DefiningBlocks.insert(&B);
      // Create a spindle and root task for the entry block.
      Spindle *S = createSpindleWithEntry(&B, Spindle::SPType::Entry);
      SpindleCount++;
      RootTask = createTaskWithEntry(S, DomTree);
      TaskCount++;
    }
    if (DetachInst *DI = dyn_cast<DetachInst>(B.getTerminator())) {
      BasicBlock *TaskEntry = DI->getDetached();
      DefiningBlocks.insert(TaskEntry);
      // Create a new spindle and task.
      Spindle *S = createSpindleWithEntry(TaskEntry, Spindle::SPType::Detach);
      SpindleCount++;
      createTaskWithEntry(S, DomTree);
      TaskCount++;

      // Create a new Phi spindle for the task continuation.  We do this
      // explicitly to handle cases where the spawned task does not return
      // (reattach).
      BasicBlock *TaskContinue = DI->getContinue();
      DefiningBlocks.insert(TaskContinue);
      if (!getSpindleFor(TaskContinue)) {
        createSpindleWithEntry(TaskContinue, Spindle::SPType::Phi);
        SpindleCount++;
      }
    } else if (isa<SyncInst>(B.getTerminator())) {
      BasicBlock *SPEntry = B.getSingleSuccessor();
      // For sync instructions, we mark the block containing the sync
      // instruction as the defining block for the sake of calculating IDF's.
      // If the successor of the sync has multiple predecessors, then we want to
      // allow a phi node to be created starting at that block.
      DefiningBlocks.insert(&B);
      // Create a new spindle.  The type of this spindle might change later, if
      // we discover it requires a phi.
      if (!getSpindleFor(SPEntry)) {
        createSpindleWithEntry(SPEntry, Spindle::SPType::Sync);
        SpindleCount++;
      }
      assert((getSpindleFor(SPEntry)->isSync() ||
              getSpindleFor(SPEntry)->isPhi()) &&
             "Discovered early a non-sync, non-phi spindle after sync");
    }
    // Create new spindles based on taskframe instrinsics.  We need only work
    // about taskframe.create and taskframe.resume.
    if (isTaskFrameCreateSpindleEntry(&B)) {
      // This block starts with a taskframe.create.  Mark is as a spindle entry.
      DefiningBlocks.insert(&B);
      if (!getSpindleFor(&B)) {
        // Create a new spindle.
        createSpindleWithEntry(&B, Spindle::SPType::Phi);
        SpindleCount++;
      }
    } else if (endsUnassociatedTaskFrame(&B)) {
      BasicBlock *SPEntry = B.getSingleSuccessor();
      // This block ends with a taskframe.end.  Mark its successor as a spindle
      // entry.
      DefiningBlocks.insert(SPEntry);
      if (!getSpindleFor(SPEntry)) {
        // Create a new spindle.
        createSpindleWithEntry(SPEntry, Spindle::SPType::Phi);
        SpindleCount++;
      }
    } else if (isTaskFrameResume(B.getTerminator())) {
      // This block ends with a taskframe.resume invocation.  Mark the unwind
      // destination as a spindle entry.
      InvokeInst *II = cast<InvokeInst>(B.getTerminator());
      BasicBlock *ResumeDest = II->getUnwindDest();
      DefiningBlocks.insert(ResumeDest);
      if (!getSpindleFor(ResumeDest)) {
        createSpindleWithEntry(ResumeDest, Spindle::SPType::Phi);
        SpindleCount++;
      }
    }
  }
  NumBasicBlocks += BBCount;
  NumSpindles += SpindleCount;
  NumTasks += TaskCount;
  bool ParallelFunc = (DefiningBlocks.size() > 1);
  if (ParallelFunc) {
    NumBasicBlocksInPF += BBCount;
    NumSpindlesInPF += SpindleCount;
    NumTasksInPF += TaskCount;
  }
  LLVM_DEBUG({
      dbgs() << "DefiningBlocks:\n";
      for (BasicBlock *BB : DefiningBlocks)
        dbgs() << "  " << BB->getName() << "\n";
    });

  // Compute IDFs to determine additional starting points of spindles, e.g.,
  // continuation points and other spindle PHI-nodes.
  ForwardIDFCalculator IDFs(DomTree);
  IDFs.setDefiningBlocks(DefiningBlocks);
  SmallVector<BasicBlock *, 32> IDFBlocks;
  IDFs.calculate(IDFBlocks);

  llvm::sort(IDFBlocks.begin(), IDFBlocks.end(),
             [&BBNumbers](const BasicBlock *A, const BasicBlock *B) {
               return BBNumbers.find(A)->second < BBNumbers.find(B)->second;
             });

  LLVM_DEBUG({
      dbgs() << "IDFBlocks:\n";
      for (BasicBlock *BB : IDFBlocks)
        dbgs() << "  " << BB->getName() << "\n";
    });

  // Create spindles for all IDFBlocks.
  for (BasicBlock *B : IDFBlocks)
    if (Spindle *S = getSpindleFor(B)) {
      assert((S->isSync() || S->isPhi()) &&
             "Phi spindle to be created on existing non-sync spindle");
      // Change the type of this spindle.
      S->Ty = Spindle::SPType::Phi;
    } else {
      // Create a new spindle.
      createSpindleWithEntry(B, Spindle::SPType::Phi);
      ++NumSpindles;
      if (ParallelFunc)
        ++NumSpindlesInPF;
    }

  // Use the following linear-time algorithm to partition the function's blocks
  // into spindles, partition the spindles into tasks, and compute the tree of
  // tasks in this function.
  //
  // -) A post-order traversal of the dominator tree looks for a spindle entry
  // and creates a stack of blocks it finds along the way.
  //
  // -) Once a spindle entry is encountered, the blocks belonging to that
  // spindle equal the suffix of the stack of found blocks that are all
  // dominated by the spindle's entry.  These blocks are removed from the stack
  // and added to the spindle according to a DFS CFG traversal starting at the
  // spindle's entry.
  //
  // -) Similarly, the post-order travesal of the dominator tree finds the set
  // of spindles that make up each task.  These spindles are collected and added
  // to their enclosing task using the same algorithm as above.
  //
  // -) Finally, the post-order traversal of the dominator tree deduces the
  // hierarchical nesting of tasks within the function.  Subtasks are associated
  // with their parent task whenever a task entry that dominates the previous
  // task entry is encountered.
  std::vector<BasicBlock *> FoundBlocks;
  SmallVector<Spindle *, 8> FoundSpindles;
  SmallVector<Spindle *, 8> FoundTFCreates;
  SmallVector<Task *, 4> UnassocTasks;
  for (auto DomNode : post_order(DomTree.getRootNode())) {
    BasicBlock *BB = DomNode->getBlock();
    // If a basic block is not a spindle entry, mark it found and continue.
    if (!getSpindleFor(BB)) {
      // Perform some rare, special-case handling of detach unwind blocks.
      if (shouldCreateSpindleAtDetachUnwind(BB, *this, DomTree)) {
        createSpindleWithEntry(BB, Spindle::SPType::Phi);
        ++NumSpindles;
      } else {
        FoundBlocks.push_back(BB);
        continue;
      }
    }
    // This block is a spindle entry.
    Spindle *S = getSpindleFor(BB);

    // Associated blocks dominated by spindle S with spindle S.
    {
      SmallPtrSet<BasicBlock *, 32> UnassocBlocks;
      // Determine which found blocks are associated with this spindle.  Because
      // of the post-order tree traversal, these blocks form a suffix of
      // FoundBlocks.
      while (!FoundBlocks.empty()) {
        BasicBlock *FB = FoundBlocks.back();
        if (DomTree.dominates(S->getEntry(), FB)) {
          UnassocBlocks.insert(FB);
          FoundBlocks.pop_back();
        } else
          break;
      }

      // Associate the unassociated blocks with spindle S.
      if (!UnassocBlocks.empty())
        AssociateWithSpindle(this, S, UnassocBlocks);
    }

    // Mark taskframe.create spindles found.
    if (Value *TaskFrame = S->getTaskFrameCreate()) {
      FoundTFCreates.push_back(S);
      for (Task *SubT : reverse(UnassocTasks)) {
        if (!DomTree.dominates(S->getEntry(), SubT->getEntry()))
          break;
        // If SubT uses the TaskFrame created in S, associate the two.
        if (SubT->getTaskFrameUsed() == TaskFrame) {
          AssociateTaskFrameWithUser(SubT, S);
          break;
        }
      }
    }

    // If this spindle is not an entry to a task, mark it found and continue.
    if (!getTaskFor(S)) {
      FoundSpindles.push_back(S);
      continue;
    }
    // This spindle is a task entry.
    Task *T = getTaskFor(S);

    // Associate spindles dominated by task T with task T.
    {
      SmallPtrSet<Spindle *, 8> UnassocSpindles;
      // Determine which found spindles are associated with this task.  Because
      // of the post-order tree traversal, these spindles form a suffix of
      // FoundSpindles.
      while (!FoundSpindles.empty()) {
        Spindle *FS = FoundSpindles.back();
        if (DomTree.dominates(T->getEntry(), FS->getEntry())) {
          UnassocSpindles.insert(FS);
          FoundSpindles.pop_back();
        } else
          break;
      }
      // Associate the unassociated spindles with task T.
      if (!UnassocSpindles.empty())
        AssociateWithTask(this, T, UnassocSpindles);
    }

    // If the last task is dominated by this task, add the unassociated tasks as
    // children of this task.
    while (!UnassocTasks.empty()) {
      Task *LastTask = UnassocTasks.back();
      if (!DomTree.dominates(T->getEntry(), LastTask->getEntry()))
        break;
      T->addSubTask(LastTask);
      UnassocTasks.pop_back();
    }
    UnassocTasks.push_back(T);

    // Add taskframe.create spindles as children of this task.
    while (!FoundTFCreates.empty()) {
      Spindle *TF = FoundTFCreates.back();
      if (!DomTree.dominates(T->getEntry(), TF->getEntry()))
        break;
      T->TaskFrameCreates.push_back(TF);
      FoundTFCreates.pop_back();
    }
  }

  // Populate the predecessors and successors of all spindles.
  computeSpindleEdges(this);

  // Record continuation spindles for each task.
  recordContinuationSpindles(this);

  if (PrintTaskFrameTree)
    // Determine the subtasks of taskframes discovered.
    findTaskFrameTree();
}

/// Recursive helper to traverse the spindles to discover the taskframe tree.
void TaskInfo::findTaskFrameTreeHelper(
    Spindle *TFSpindle, SmallVectorImpl<Spindle *> &ParentWorkList,
    SmallPtrSetImpl<Spindle *> &SubTFVisited) {
  const Value *TFCreate = TFSpindle->getTaskFrameCreate();
  const Task *UserT = TFSpindle->getTaskFromTaskFrame();
  const Spindle *Continuation = nullptr;
  const Spindle *EHContinuation = nullptr;
  if (UserT) {
    Continuation = UserT->getContinuationSpindle();
    EHContinuation = UserT->getEHContinuationSpindle();
  } else {
    // This taskframe is not associated with a task.  Examine the uses of the
    // taskframe to determine its continuation and exceptional-continuation
    // spindles.
    for (const User *U : TFCreate->users()) {
      if (const Instruction *I = dyn_cast<Instruction>(U)) {
        if (isTapirIntrinsic(Intrinsic::taskframe_end, I) &&
            isCanonicalTaskFrameEnd(I))
          Continuation = getSpindleFor(I->getParent()->getSingleSuccessor());
        else if (isTaskFrameResume(I)) {
          const InvokeInst *II = dyn_cast<InvokeInst>(I);
          EHContinuation = getSpindleFor(II->getUnwindDest());
        }
      }
    }
  }

  SmallVector<Spindle *, 8> WorkList;
  SmallPtrSet<Spindle *, 8> Visited;
  WorkList.push_back(TFSpindle);
  while (!WorkList.empty()) {
    Spindle *S = WorkList.pop_back_val();
    if (!Visited.insert(S).second)
      continue;

    // Add S to the set of taskframe spindles.
    TFSpindle->TaskFrameSpindles.insert(S);

    for (Spindle::SpindleEdge &SuccEdge : S->out_edges()) {
      // If the successor spindle is itself a TaskFrameCreate spindle, add the
      // subtask that uses it, and continue.
      if (SuccEdge.first->getTaskFrameCreate()) {
        Spindle *SubTF = SuccEdge.first;
        if (!SubTFVisited.insert(SubTF).second)
          continue;

        if (Task *SubTFUser = SubTF->getTaskFrameUser())
          // Add SubTFUser as a subtask of the taskframe spindle.
          TFSpindle->TaskFrameSubtasks.insert(SubTFUser);

        // Add SubTF as a subtaskframe of the taskframe spindle.
        TFSpindle->SubTaskFrames.insert(SubTF);
        SubTF->TaskFrameParent = TFSpindle;

        // Recur into the new taskframe.
        findTaskFrameTreeHelper(SubTF, WorkList, SubTFVisited);
        continue;
      }

      // Handle any spindles not in the same task as TFSpindle.
      if (!TFSpindle->succInSameTask(SuccEdge.first))
        if (isa<DetachInst>(SuccEdge.second->getTerminator())) {
          Task *SubT = getTaskFor(SuccEdge.first);
          if (SubT != UserT) {
            // Add SubT as a subtask of the taskframe spindle.
            TFSpindle->TaskFrameSubtasks.insert(SubT);

            // Add a spindle representing the subtask.
            if (!SubT->getTaskFrameCreateSpindle()) {
              Spindle *SubTF = SuccEdge.first;
              // Add the subtask's entry spindle to the set of subtaskframes.
              TFSpindle->SubTaskFrames.insert(SubTF);
              SubTF->TaskFrameParent = TFSpindle;

              // Recur into the new taskframe.
              findTaskFrameTreeHelper(SubTF, WorkList, SubTFVisited);
              continue;
            } else {
              LLVM_DEBUG({
                  if (!TFSpindle->SubTaskFrames.count(SuccEdge.first))
                    dbgs() << "Search encountered subtask@"
                           << SubT->getEntry()->getName() << " with taskframe "
                           << "before that subtask's taskframe.create.";
                });
            }
          }
        }

      // Add the normal continuation to parent worklist.
      if (SuccEdge.first == Continuation) {
        ParentWorkList.push_back(SuccEdge.first);
        continue;
      }
      // Add the exception-handling continuation to the appropriate worklist.
      if (SuccEdge.first == EHContinuation) {
        // If TFSpindle corresponds to a taskframe.create associated with a
        // task, push the successor onto our worklist.  Otherwise push it onto
        // the parent's worklist.
        //
        // TODO: Why do we ever push the EHContinuation onto our own worklist?
        if (TFCreate && UserT)
          WorkList.push_back(SuccEdge.first);
        else
          ParentWorkList.push_back(SuccEdge.first);
        continue;
      }

      Instruction *ExitTerm = SuccEdge.second->getTerminator();
      // Add landingpad successor of taskframe.resume to parent worklist.
      if (isTaskFrameResume(ExitTerm, TFCreate)) {
        if (SuccEdge.first->getEntry() ==
            cast<InvokeInst>(ExitTerm)->getUnwindDest())
          ParentWorkList.push_back(SuccEdge.first);
        continue;
      }
      // Add landingpad successor of detached.rethrow to the appropriate worklist.
      if (isDetachedRethrow(ExitTerm)) {
        if (SuccEdge.first->getEntry() ==
            cast<InvokeInst>(ExitTerm)->getUnwindDest()) {
          // If TFSpindle corresponds to a taskframe.create, push the successor
          // onto our worklist.  Otherwise push it onto the parent's worklist.
          if (TFCreate)
            WorkList.push_back(SuccEdge.first);
          else
            ParentWorkList.push_back(SuccEdge.first);
        }
        continue;
      }

      WorkList.push_back(SuccEdge.first);
    }
  }
}

/// Compute the spindles and subtasks contained in all taskframes.
void TaskInfo::findTaskFrameTree() {
  // If we've already found the taskframe tree, don't recompute it.
  if (ComputedTaskFrameTree)
    return;

  SmallPtrSet<Spindle *, 8> SubTFVisited;
  // Get the taskframe tree under each taskframe.create in the root task.
  for (Spindle *TFSpindle : getRootTask()->taskframe_creates()) {
    SmallVector<Spindle *, 8> WorkList;
    if (!SubTFVisited.insert(TFSpindle).second)
      continue;
    findTaskFrameTreeHelper(TFSpindle, WorkList, SubTFVisited);
  }

  // Get the taskframe tree under each subtask that does not have an associated
  // taskframe.create.
  for (Task *SubT : getRootTask()->subtasks()) {
    // If this subtask uses a taskframe, then we should have discovered its
    // taskframe tree already.
    if (SubT->getTaskFrameUsed())
      continue;
    SmallVector<Spindle *, 8> WorkList;
    // Treat the entry spindle of the subtask as the taskframe spindle.
    Spindle *TFSpindle = SubT->getEntrySpindle();
    if (!SubTFVisited.insert(TFSpindle).second)
      continue;
    findTaskFrameTreeHelper(TFSpindle, WorkList, SubTFVisited);
  }

  // Discover taskframe roots for all tasks in the function.
  for (Task *T : post_order(getRootTask())) {
    // Find taskframe.creates in T that do not have parents in T, and add them
    // as taskframe roots of T.
    for (Spindle *TFSpindle : T->taskframe_creates()) {
      if (Spindle *Parent = TFSpindle->getTaskFrameParent()) {
        if (!T->contains(Parent))
          T->TaskFrameRoots.push_back(TFSpindle);
      } else {
        T->TaskFrameRoots.push_back(TFSpindle);
      }
    }

    // For any subtask of T that does not have a taskframe, add its entry
    // spindle as a taskframe root.
    for (Task *SubT : T->subtasks()) {
      // If SubT does not have an associated taskframe, then we might need to
      // mark it as a taskframe root.
      if (!SubT->getTaskFrameUsed()) {
        Spindle *EffectiveTF = SubT->getEntrySpindle();
        if (Spindle *Parent = EffectiveTF->getTaskFrameParent()) {
          if (!T->contains(Parent))
            T->TaskFrameRoots.push_back(EffectiveTF);
        } else {
          T->TaskFrameRoots.push_back(EffectiveTF);
        }
      }
    }
  }

  // Record that the taskframe tree has been computed.
  ComputedTaskFrameTree = true;
}

/// Determine which blocks the value is live in.
///
/// These are blocks which lead to uses.  Knowing this allows us to avoid
/// inserting PHI nodes into blocks which don't lead to uses (thus, the inserted
/// phi nodes would be dead).
static void ComputeLiveInBlocks(
    const AllocaInst *AI,
    const SmallVectorImpl<BasicBlock *> &UsingBlocks,
    const SmallPtrSetImpl<BasicBlock *> &DefBlocks,
    SmallPtrSetImpl<BasicBlock *> &LiveInBlocks) {
  // To determine liveness, we must iterate through the predecessors of blocks
  // where the def is live.  Blocks are added to the worklist if we need to
  // check their predecessors.  Start with all the using blocks.
  SmallVector<BasicBlock *, 64> LiveInBlockWorklist(UsingBlocks.begin(),
                                                    UsingBlocks.end());

  // If any of the using blocks is also a definition block, check to see if the
  // definition occurs before or after the use.  If it happens before the use,
  // the value isn't really live-in.
  for (unsigned i = 0, e = LiveInBlockWorklist.size(); i != e; ++i) {
    BasicBlock *BB = LiveInBlockWorklist[i];
    if (!DefBlocks.count(BB))
      continue;

    // Okay, this is a block that both uses and defines the value.  If the first
    // reference to the alloca is a def (store), then we know it isn't live-in.
    for (BasicBlock::iterator I = BB->begin();; ++I) {
      if (StoreInst *SI = dyn_cast<StoreInst>(I)) {
        if (SI->getOperand(1) != AI)
          continue;

        // We found a store to the alloca before a load.  The alloca is not
        // actually live-in here.
        LiveInBlockWorklist[i] = LiveInBlockWorklist.back();
        LiveInBlockWorklist.pop_back();
        --i;
        --e;
        break;
      }

      if (LoadInst *LI = dyn_cast<LoadInst>(I)) {
        if (LI->getOperand(0) != AI)
          continue;

        // Okay, we found a load before a store to the alloca.  It is actually
        // live into this block.
        break;
      }
    }
  }

  // Now that we have a set of blocks where the phi is live-in, recursively add
  // their predecessors until we find the full region the value is live.
  while (!LiveInBlockWorklist.empty()) {
    BasicBlock *BB = LiveInBlockWorklist.pop_back_val();

    // The block really is live in here, insert it into the set.  If already in
    // the set, then it has already been processed.
    if (!LiveInBlocks.insert(BB).second)
      continue;

    // Since the value is live into BB, it is either defined in a predecessor or
    // live into it to.  Add the preds to the worklist unless they are a
    // defining block.
    for (BasicBlock *P : predecessors(BB)) {
      // The value is not live into a predecessor if it defines the value.
      if (DefBlocks.count(P))
        continue;

      // Otherwise it is, add to the worklist.
      LiveInBlockWorklist.push_back(P);
    }
  }
}

// Check the set PHIBlocks if a PHI needs to be inserted in a task-continue
// block.
static bool needPhiInTaskContinue(
    const TaskInfo &TI, const AllocaInst *AI,
    SmallVectorImpl<BasicBlock *> &PHIBlocks) {
  // Determine which PHI nodes want to use a value from a detached predecessor.
  // Because register state is not preserved across a reattach, these alloca's
  // cannot be promoted.
  for (unsigned i = 0, e = PHIBlocks.size(); i != e; ++i) {
    const BasicBlock *BB = PHIBlocks[i];
    for (const_pred_iterator PI = pred_begin(BB), E = pred_end(BB);
         PI != E; ++PI) {
      const BasicBlock *P = *PI;
      if (TI.getSpindleFor(BB) && TI.getSpindleFor(P) &&
          TI.getSpindleFor(BB)->predInDifferentTask(TI.getSpindleFor(P))) {
        // TODO: Check if there's a store to this alloca in the task enclosing
        // P.
        LLVM_DEBUG(dbgs() << "Alloca " << *AI << " has use reattached from " <<
                   P->getName() << "\n");
        return true;
      }
    }
  }
  return false;
}

/// Check if a alloca AI is promotable based on uses in subtasks.
bool TaskInfo::isAllocaParallelPromotable(const AllocaInst *AIP) const {
  if (getTaskFor(AIP->getParent())->isSerial()) return true;

  DominatorTree &DomTree = getRootTask()->DomTree;
  AllocaInst *AI = const_cast<AllocaInst *>(AIP);
  SmallPtrSet<BasicBlock *, 32> DefBlocks;
  SmallVector<BasicBlock *, 32> UsingBlocks;
  const Spindle *OnlySpindle = getSpindleFor(AIP->getParent());
  bool OnlyUsedInOneSpindle = true;

  // As we scan the uses of the alloca instruction, keep track of stores, and
  // decide whether all of the loads and stores to the alloca are within the
  // same basic block.
  for (auto UI = AI->user_begin(), E = AI->user_end(); UI != E;) {
    Instruction *User = cast<Instruction>(*UI++);
    if (StoreInst *SI = dyn_cast<StoreInst>(User)) {
      // Remember the basic blocks which define new values for the alloca
      DefBlocks.insert(SI->getParent());
    } else if (LoadInst *LI = dyn_cast<LoadInst>(User)) {
      // Otherwise it must be a load instruction, keep track of variable reads.
      UsingBlocks.push_back(LI->getParent());
    } else continue;

    if (OnlyUsedInOneSpindle)
      if (getSpindleFor(User->getParent()) != OnlySpindle)
        OnlyUsedInOneSpindle = false;
  }

  // A spindle is guaranteed to execute as a serial unit.  Hence, if an alloca
  // is only used in a single spindle, it is safe to promote.
  if (OnlyUsedInOneSpindle) return true;

  ForwardIDFCalculator IDF(DomTree);
  // Determine which blocks the value is live in.  These are blocks which lead
  // to uses.
  SmallPtrSet<BasicBlock *, 32> LiveInBlocks;
  ComputeLiveInBlocks(AI, UsingBlocks, DefBlocks, LiveInBlocks);
  // Filter out live-in blocks that are not dominated by the alloca.
  if (AI->getParent() != DomTree.getRoot()) {
    SmallVector<BasicBlock *, 32> LiveInToRemove;
    for (BasicBlock *LiveIn : LiveInBlocks)
      if (!DomTree.dominates(AI->getParent(), LiveIn))
        LiveInToRemove.push_back(LiveIn);
    for (BasicBlock *ToRemove : LiveInToRemove)
      LiveInBlocks.erase(ToRemove);
  }

  // Determine which blocks need PHI nodes and see if we can optimize out some
  // work by avoiding insertion of dead phi nodes.
  IDF.setLiveInBlocks(LiveInBlocks);
  IDF.setDefiningBlocks(DefBlocks);
  SmallVector<BasicBlock *, 32> PHIBlocks;
  IDF.calculate(PHIBlocks);

  return !needPhiInTaskContinue(*this, AI, PHIBlocks);
}

// This method is called once per spindle during an initial DFS traversal of the
// spindle graph.
bool IsSyncedState::markDefiningSpindle(const Spindle *S) {
  LLVM_DEBUG(dbgs() << "markDefiningSpindle @ " << *S << "\n");
  // Entry spindles, detach spindles, sync spindles, and continuation-Phi
  // spindles all define their sync state directly.  Other Phi spindles
  // determine their sync state based on their predecessors.
  switch (S->getType()) {
  case Spindle::SPType::Entry:
  case Spindle::SPType::Detach:
    SyncedState[S] = SyncInfo::TaskEntry;
    return true;
  case Spindle::SPType::Sync:
    SyncedState[S] = SyncInfo::Synced;
    return true;
  case Spindle::SPType::Phi:
    if (S->isTaskContinuation()) {
      SyncedState[S] = SyncInfo::Unsynced;
      return true;
    }
  }
  return false;
}

// This method is called once per unevaluated spindle in an inverse-post-order
// walk of the spindle graph.
bool IsSyncedState::evaluate(const Spindle *S, unsigned EvalNum) {
  LLVM_DEBUG(dbgs() << "evaluate @ " << *S << "\n");

  // For the first evaluation, optimistically assume that we are synced.  Any
  // unsynced predecessor will clear this bit.
  if (!EvalNum && !SyncedState.count(S)) {
    SyncedState[S] = SyncInfo::Synced;
  }

  for (const Spindle::SpindleEdge &PredEdge : S->in_edges()) {
    const Spindle *Pred = PredEdge.first;
    const BasicBlock *Inc = PredEdge.second;

    // During the first evaluation, if we have a loop amongst Phi spindles, then
    // the predecessor might not be defined.  Skip predecessors that aren't
    // defined.
    if (!EvalNum && !SyncedState.count(Pred)) {
      SyncedState[S] = setIncomplete(SyncedState[S]);
      continue;
    } else
      assert(SyncedState.count(Pred) &&
             "All predecessors should have synced states after first eval.");

    // If we find an unsynced predecessor that is not terminated by a sync
    // instruction, then we must be unsynced.
    if (isUnsynced(SyncedState[Pred]) &&
        !isa<SyncInst>(Inc->getTerminator())) {
      SyncedState[S] = setUnsynced(SyncedState[S]);
      break;
    }
  }
  // Because spindles are evaluated in each round in an inverse post-order
  // traversal, two evaluations should suffice.  If we have an incomplete synced
  // state at the end of the first evaluation, then we conclude that it's synced
  // at set it complete.
  if (EvalNum && isIncomplete(SyncedState[S])) {
    SyncedState[S] = setComplete(SyncedState[S]);
    return true;
  }
  return !isIncomplete(SyncedState[S]);
}

// This method is called once per spindle during an initial DFS traversal of
// the spindle graph.
bool MaybeParallelTasks::markDefiningSpindle(const Spindle *S) {
  LLVM_DEBUG(dbgs() << "MaybeParallelTasks::markDefiningSpindle @ "
             << S->getEntry()->getName() << "\n");
  switch (S->getType()) {
    // Emplace empty task lists for Entry, Detach, and Sync spindles.
  case Spindle::SPType::Entry:
  case Spindle::SPType::Detach:
    TaskList.try_emplace(S);
    return true;
  case Spindle::SPType::Sync:
    return false;
  case Spindle::SPType::Phi: {
    // At task-continuation Phi's, initialize the task list with the detached
    // task that reattaches to this continuation.
    if (S->isTaskContinuation()) {
      LLVM_DEBUG(dbgs() << "  TaskCont spindle " << S->getEntry()->getName()
                 << "\n");
      for (const Spindle *Pred : predecessors(S)) {
        LLVM_DEBUG(dbgs() << "    pred spindle "
                   << Pred->getEntry()->getName() << "\n");
        if (S->predInDifferentTask(Pred))
          TaskList[S].insert(Pred->getParentTask());
      }
      LLVM_DEBUG({
          for (const Task *MPT : TaskList[S])
            dbgs() << "  Added MPT " << MPT->getEntry()->getName() << "\n";
        });
      return true;
    }
    return false;
  }
  }
  return false;
}

// This method is called once per unevaluated spindle in an inverse-post-order
// walk of the spindle graph.
bool MaybeParallelTasks::evaluate(const Spindle *S, unsigned EvalNum) {
  LLVM_DEBUG(dbgs() << "MaybeParallelTasks::evaluate @ "
             << S->getEntry()->getName() << "\n");
  if (!TaskList.count(S))
    TaskList.try_emplace(S);

  bool NoChange = true;
  for (const Spindle::SpindleEdge &PredEdge : S->in_edges()) {
    const Spindle *Pred = PredEdge.first;
    const BasicBlock *Inc = PredEdge.second;

    // If the incoming edge is a sync edge, get the associated sync region.
    const Value *SyncRegSynced = nullptr;
    if (const SyncInst *SI = dyn_cast<SyncInst>(Inc->getTerminator()))
      SyncRegSynced = SI->getSyncRegion();

    // Iterate through the tasks in the task list for Pred.
    for (const Task *MP : TaskList[Pred]) {
      // Filter out any tasks that are synced by the sync region.
      if (const DetachInst *DI = MP->getDetach())
        if (SyncRegSynced == DI->getSyncRegion())
          continue;
      // Insert the task into this spindle's task list.  If this task is a new
      // addition, then we haven't yet reached the fixed point of this analysis.
      if (TaskList[S].insert(MP).second)
        NoChange = false;
    }
  }
  LLVM_DEBUG({
      dbgs() << "  New MPT list for " << S->getEntry()->getName()
             << " (NoChange? " << NoChange << ")\n";
      for (const Task *MP : TaskList[S])
        dbgs() << "    " << MP->getEntry()->getName() << "\n";
    });
  return NoChange;
}

raw_ostream &llvm::operator<<(raw_ostream &OS, const Spindle &S) {
  S.print(OS);
  return OS;
}

bool TaskInfo::invalidate(Function &F, const PreservedAnalyses &PA,
                          FunctionAnalysisManager::Invalidator &) {
  // Check whether the analysis, all analyses on functions, or the function's
  // CFG have been preserved.
  auto PAC = PA.getChecker<TaskAnalysis>();
  return !(PAC.preserved() || PAC.preservedSet<AllAnalysesOn<Function>>() ||
           PAC.preservedSet<CFGAnalyses>());
}

static const BasicBlock *getSingleNotUnreachableSuccessor(
    const BasicBlock *BB) {
  const BasicBlock *SingleSuccessor = nullptr;
  for (const auto *Succ : children<const BasicBlock *>(BB)) {
    if (isa<UnreachableInst>(Succ->getFirstNonPHIOrDbgOrLifetime()))
      continue;
    if (!SingleSuccessor)
      SingleSuccessor = Succ;
    else
      return nullptr;
  }
  return SingleSuccessor;
}

/// Print spindle with all the BBs inside it.
void Spindle::print(raw_ostream &OS, bool Verbose) const {
  if (getParentTask()->getEntrySpindle() == this)
    OS << "<task entry>";
  BasicBlock *Entry = getEntry();
  for (unsigned i = 0; i < getBlocks().size(); ++i) {
    BasicBlock *BB = getBlocks()[i];
    if (BB == Entry) {
      if (getTaskFrameCreate())
        OS << "<tf create>";
      switch (Ty) {
      case SPType::Entry: OS << "<func sp entry>"; break;
      case SPType::Detach: OS << "<task sp entry>"; break;
      case SPType::Sync: OS << "<sync sp entry>"; break;
      case SPType::Phi: OS << "<phi sp entry>"; break;
      }
    }
    if (!Verbose) {
      if (i) OS << ",";
      BB->printAsOperand(OS, false);
    } else
      OS << "\n";

    if (isSpindleExiting(BB)) {
      OS << "<sp exit>";
      if (isTaskFrameResume(BB->getTerminator()))
        OS << "<tf exit>";
      else if (getParentTask()->isTaskExiting(BB)) {
        if (isa<UnreachableInst>(BB->getTerminator()) ||
            isa<ResumeInst>(BB->getTerminator()))
          OS << "<task EH exit>";
        else if (isa<ReattachInst>(BB->getTerminator()) ||
                 isa<ReturnInst>(BB->getTerminator()))
          OS << "<task exit>";
        else if (getParentTask()->getEHContinuationSpindle() &&
                 (getSingleNotUnreachableSuccessor(BB) ==
                  getParentTask()->getEHContinuationSpindle()->getEntry()))
          OS << "<task EH-contin exit>";
        else
          OS << "<task UNUSUAL exit>";
      }
    }
    if (Verbose)
      BB->print(OS);
  }
}

raw_ostream &llvm::operator<<(raw_ostream &OS, const Task &T) {
  T.print(OS);
  return OS;
}

/// Print task with all the BBs inside it.
void Task::print(raw_ostream &OS, unsigned Depth, bool Verbose) const {
  OS.indent(Depth * 2) << "task at depth " << Depth << ": ";

  // Print the spindles in this task.
  for (const Spindle *S :
         depth_first<InTask<const Spindle *>>(getEntrySpindle())) {
    OS << "{";
    S->print(OS, Verbose);
    OS << "}";
  }
  OS << "\n";

  // If this task contains tracks any shared EH spindles for its subtasks, print
  // those shared EH spindles.
  for (const Spindle *S : shared_eh_spindles()) {
    OS << "{<shared EH>";
    S->print(OS, Verbose);
    OS << "}\n";
  }

  // Print the subtasks of this task.
  for (const Task *SubTask : getSubTasks())
    SubTask->print(OS, Depth+1, Verbose);
}

static void printTaskFrame(raw_ostream &OS, const Spindle *TFEntry,
                           unsigned Depth, bool Verbose) {
  OS.indent(Depth * 2) << "taskframe at depth " << Depth << ": ";

  OS << "spindle@" << TFEntry->getEntry()->getName();
  if (const Task *User = TFEntry->getTaskFromTaskFrame())
    OS << "  (used by task@" << User->getEntry()->getName() << ")";
  OS << "\n";

  for (const Spindle *SubTF : TFEntry->subtaskframes())
    printTaskFrame(OS, SubTF, Depth+1, Verbose);
}

// Debugging
void TaskInfo::print(raw_ostream &OS) const {
  OS << "Spindles:\n";
  SmallVector<const Spindle *, 8> WorkList;
  SmallPtrSet<const Spindle *, 8> Visited;
  WorkList.push_back(getRootTask()->getEntrySpindle());
  while (!WorkList.empty()) {
    const Spindle *S = WorkList.pop_back_val();
    if (!Visited.insert(S).second) continue;

    OS << "{";
    S->print(OS);
    OS << "}";

    for (const Spindle *Succ : successors(S))
      WorkList.push_back(Succ);
  }
  OS << "\n\n";

  OS << "Task tree:\n";
  getRootTask()->print(OS);
  OS << "\n";

  for (const Task *T : post_order(getRootTask())) {
    if (T->taskframe_creates().begin() == T->taskframe_creates().end())
      continue;
    OS << "task@" << T->getEntry()->getName() << " has taskframe.creates:\n";
    for (const Spindle *S : T->taskframe_creates()) {
      OS << "  spindle@" << S->getEntry()->getName() << "\n";
      // Print the task that uses this taskframe.create
      if (S->getTaskFrameUser())
        OS << "    used by task@"
           << S->getTaskFrameUser()->getEntry()->getName() << "\n";
      else
        OS << "    not used.\n";

      // Print the subtaskframess under this taskframe.create.
      for (const Spindle *SubTF : S->subtaskframes())
        OS << "    contains subtaskframe@"
           << SubTF->getEntry()->getName() << "\n";

      // Print the subtasks under this taskframe.create.
      for (const Task *SubT : S->taskframe_subtasks())
        OS << "    contains subtask@"
           << SubT->getEntry()->getName() << "\n";

      // Print the taskframe spindles themselves.
      for (const Spindle *TFSpindle : S->taskframe_spindles())
        OS << "    " << *TFSpindle << "\n";
    }
    OS << "\n";
  }

  if (PrintTaskFrameTree) {
    for (const Spindle *TFCreate : getRootTask()->taskframe_roots()) {
      printTaskFrame(OS, TFCreate, 0, false);
      OS << "\n";
    }
  }

  if (PrintMayHappenInParallel) {
    // Evaluate the tasks that might be in parallel with each spindle, and
    // determine number of discriminating syncs: syncs that sync a subset of the
    // detached tasks, based on sync regions.
    MaybeParallelTasks MPTasks;
    evaluateParallelState<MaybeParallelTasks>(MPTasks);
    for (const Task *T : depth_first(getRootTask())) {
      // Skip tasks with no subtasks.
      if (T->isSerial()) continue;

      for (const Spindle *S : T->spindles()) {
        // Only conider spindles that might have tasks in parallel.
        if (MPTasks.TaskList[S].empty()) continue;

        OS << "spindle@" << S->getEntry()->getName();
        OS << " may happen in parallel with:\n";
        for (const Task *MPT : MPTasks.TaskList[S])
          OS << "  task@" << MPT->getEntry()->getName() << "\n";
      }
    }
  }
}

AnalysisKey TaskAnalysis::Key;

TaskInfo TaskAnalysis::run(Function &F, FunctionAnalysisManager &AM) {
  // FIXME: Currently we create a TaskInfo from scratch for every function.
  // This may prove to be too wasteful due to deallocating and re-allocating
  // memory each time for the underlying map and vector datastructures. At some
  // point it may prove worthwhile to use a freelist and recycle TaskInfo
  // objects. I don't want to add that kind of complexity until the scope of
  // the problem is better understood.
  TaskInfo TI;
  TI.analyze(F, AM.getResult<DominatorTreeAnalysis>(F));
  return TI;
}

PreservedAnalyses TaskPrinterPass::run(Function &F,
                                       FunctionAnalysisManager &AM) {
  AM.getResult<TaskAnalysis>(F).print(OS);
  return PreservedAnalyses::all();
}

void llvm::printTask(Task &T, raw_ostream &OS, const std::string &Banner) {

  if (forcePrintModuleIR()) {
    // handling -print-module-scope
    OS << Banner << " (task: ";
    T.getEntry()->printAsOperand(OS, false);
    OS << ")\n";

    // printing whole module
    OS << *T.getEntry()->getModule();
    return;
  }

  OS << Banner;

  for (auto *S : T.spindles()) {
    if (T.getEntrySpindle() == S)
      OS << "entry spindle: ";
    else
      OS << "spindle: ";

    for (auto *Block : S->blocks())
      if (Block)
        Block->print(OS);
      else
        OS << "Printing <null> block";
  }
}

void Task::verify(const TaskInfo *TI, const BasicBlock *Entry,
                  const DominatorTree &DT) const {
  // Scan the blocks and spindles in this task and check that TaskInfo stores
  // the correct information for them.
  SmallPtrSet<BasicBlock *, 4> DetachedBlocks;
  for (Spindle *S : spindles()) {
    assert(TI->getTaskFor(S) == this &&
           "TaskInfo associates spindle with different task");
    for (BasicBlock *B : S->blocks()) {
      assert(encloses(B) &&
             "Task spindle contains a block not enclosed by task");
      assert(DT.dominates(Entry, B) &&
             "Task entry does not dominate all task blocks");
      assert(TI->getSpindleFor(B) == S &&
             "TaskInfo associates block with different spindle");

      if (DetachInst *DI = dyn_cast<DetachInst>(B->getTerminator())) {
        assert(TI->isTaskEntry(DI->getDetached()) &&
               "Detached block is not a task entry");
        // Record all blocks found to be detached by this task.
        DetachedBlocks.insert(DI->getDetached());
      }
    }
  }

  // Verify that the same number of detached blocks and subtasks are found.
  assert(DetachedBlocks.size() == getSubTasks().size() &&
         "Mismatch found between detached blocks and subtasks");

  for (Task *T : getSubTasks()) {
    // Check the entry of this subtask and its predecessor.
    BasicBlock *TEntry = T->getEntry();
    assert(DetachedBlocks.count(TEntry) &&
           "Subtask entry not among set of detached blocks");
#ifndef NDEBUG
    BasicBlock *TPred = TEntry->getSinglePredecessor();
    assert(TPred && "Task entry does not have a single predecessors");

    // Check the successors of the detach instruction that created this task.
    DetachInst *DI = dyn_cast<DetachInst>(TPred->getTerminator());
    assert(DI && "Task predecessor is not terminated by a detach");
    assert(DI->getDetached() == TEntry &&
           "Task entry is not a detached successor");
    assert(!DT.dominates(TEntry, DI->getContinue()) &&
           "Task entry dominates continuation of task.");
    assert((!DI->hasUnwindDest() ||
            !DT.dominates(TEntry, DI->getUnwindDest())) &&
           "Task entry dominates unwind destination of detach");

    // Check that detach edge dominates all blocks in subtask.
    SmallVector<BasicBlock *, 32> TaskBlocks;
    T->getDominatedBlocks(TaskBlocks);
    BasicBlockEdge DetachEdge(TPred, TEntry);
    for (BasicBlock *B : TaskBlocks)
      assert(DT.dominates(DetachEdge, B) &&
             "Detach edge does not dominate all blocks in task");
#endif
    // Recursively verify the subtask.
    T->verify(TI, TEntry, DT);
  }
}

void TaskInfo::verify(const DominatorTree &DT) const {
  assert(RootTask && "No root task found");
  assert(RootTask->getEntry() == DT.getRoot() &&
         "Root task not rooted at dominator tree root");
  // Test the set of blocks extracted by getBlocks(), which uses the Task's
  // associated dominator tree.
  SmallVector<BasicBlock *, 32> TaskBlocks;
  RootTask->getDominatedBlocks(TaskBlocks);
#ifndef NDEBUG
  for (BasicBlock *B : TaskBlocks) {
    Spindle *S = getSpindleFor(B);
    assert(S && "TaskInfo does not associate this block with a spindle");
    assert(getTaskFor(S) &&
           "TaskInfo does not associate a task with this spindle");
  }
#endif
  RootTask->verify(this, DT.getRoot(), DT);
}

//===----------------------------------------------------------------------===//
// TaskInfo implementation
//

TaskInfoWrapperPass::TaskInfoWrapperPass() : FunctionPass(ID) {
  initializeTaskInfoWrapperPassPass(*PassRegistry::getPassRegistry());
}

char TaskInfoWrapperPass::ID = 0;
INITIALIZE_PASS_BEGIN(TaskInfoWrapperPass, "tasks", "Tapir Task Information",
                      true, true)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_END(TaskInfoWrapperPass, "tasks", "Tapir Task Information",
                    true, true)

bool TaskInfoWrapperPass::runOnFunction(Function &F) {
  releaseMemory();
  TI.analyze(F, getAnalysis<DominatorTreeWrapperPass>().getDomTree());
  return false;
}

void TaskInfoWrapperPass::verifyAnalysis() const {
  // TaskInfoWrapperPass is a FunctionPass, but verifying every task in the
  // function each time verifyAnalysis is called is very expensive. The
  // -verify-task-info option can enable this.
  if (VerifyTaskInfo) {
    auto &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
    TI.verify(DT);
  }
}

void TaskInfoWrapperPass::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<DominatorTreeWrapperPass>();
}

void TaskInfoWrapperPass::print(raw_ostream &OS, const Module *) const {
  TI.print(OS);
}

PreservedAnalyses TaskVerifierPass::run(Function &F,
                                        FunctionAnalysisManager &AM) {
  TaskInfo &TI = AM.getResult<TaskAnalysis>(F);
  auto &DT = AM.getResult<DominatorTreeAnalysis>(F);
  TI.verify(DT);
  return PreservedAnalyses::all();
}

//===----------------------------------------------------------------------===//
// Associated analysis routines

/// Examine a given loop to determine if it is structurally a Tapir loop.
/// Returns the Task that encodes the loop body if so, or nullptr if not.
Task *llvm::getTaskIfTapirLoopStructure(const Loop *L, TaskInfo *TI) {
  if (!L || !TI)
    return nullptr;

  const BasicBlock *Header = L->getHeader();
  const BasicBlock *Latch = L->getLoopLatch();

  LLVM_DEBUG(dbgs() << "Analyzing loop: " << *L);

  // Header must be terminated by a detach.
  const DetachInst *DI = dyn_cast<DetachInst>(Header->getTerminator());
  if (!DI) {
    LLVM_DEBUG(dbgs() << "Loop header does not detach.\n");
    return nullptr;
  }

  // Loop must have a unique latch.
  if (!Latch) {
    LLVM_DEBUG(dbgs() << "Loop does not have a unique latch.\n");
    return nullptr;
  }

  // The loop latch must be the continuation of the detach in the header.
  if (Latch != DI->getContinue()) {
    LLVM_DEBUG(dbgs() <<
               "Continuation of detach in header is not the latch.\n");
    return nullptr;
  }

  Task *T = TI->getTaskFor(DI->getDetached());
  assert(T && "Detached block not mapped to a task.");
  assert(T->getDetach() == DI && "Task mapped to unexpected detach.");

  // All predecessors of the latch other than the header must be in the task.
  for (const BasicBlock *Pred : predecessors(Latch)) {
    if (Header == Pred) continue;
    if (!T->encloses(Pred)) {
      LLVM_DEBUG(dbgs() << "Latch has predecessor outside of spawned body.\n");
      return nullptr;
    }
  }

  // For each exit from the latch, any predecessor of that exit inside the loop
  // must be the header or the latch.
  for (const BasicBlock *Exit : successors(Latch)) {
    for (const BasicBlock *ExitPred : predecessors(Exit)) {
      if (!L->contains(ExitPred)) continue;
      if (Header != ExitPred && Latch != ExitPred) {
        LLVM_DEBUG(dbgs() <<
                   "Loop branches to an exit of the latch from a block " <<
                   "other than the header or latch.\n");
        return nullptr;
      }
    }
  }

#ifndef NDEBUG
  // EXPENSIVE CHECK for verification.
  //
  // The blocks in this loop can only be the header, the latch, or a block
  // contained in the task.
  for (const BasicBlock *BB : L->blocks()) {
    if (BB == Header) continue;
    if (BB == Latch) continue;
    assert(T->encloses(BB) &&
           "Loop contains block not enclosed by detached task.\n");
  }
#endif

  return T;
}
