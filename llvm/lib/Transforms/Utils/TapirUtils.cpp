//===- TapirUtils.cpp - Utility methods for Tapir --------------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file utility methods for handling code containing Tapir instructions.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/TapirUtils.h"
#include "llvm/Analysis/DomTreeUpdater.h"
#include "llvm/Analysis/EHPersonalities.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/IR/DIBuilder.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

using namespace llvm;

#define DEBUG_TYPE "tapirutils"

// Check if the given instruction is an intrinsic with the specified ID.  If a
// value \p V is specified, then additionally checks that the first argument of
// the intrinsic matches \p V.
bool llvm::isTapirIntrinsic(Intrinsic::ID ID, const Instruction *I,
                            const Value *V) {
  if (const CallBase *CB = dyn_cast<CallBase>(I))
    if (const Function *Called = CB->getCalledFunction())
      if (ID == Called->getIntrinsicID())
        if (!V || (V == CB->getArgOperand(0)))
          return true;
  return false;
}

/// Returns true if the given instruction performs a detached.rethrow, false
/// otherwise.  If \p SyncRegion is specified, then additionally checks that the
/// detached.rethrow uses \p SyncRegion.
bool llvm::isDetachedRethrow(const Instruction *I, const Value *SyncRegion) {
  return isa<InvokeInst>(I) &&
      isTapirIntrinsic(Intrinsic::detached_rethrow, I, SyncRegion);
}

/// Returns true if the given instruction performs a taskframe.resume, false
/// otherwise.  If \p TaskFrame is specified, then additionally checks that the
/// taskframe.resume uses \p TaskFrame.
bool llvm::isTaskFrameResume(const Instruction *I, const Value *TaskFrame) {
  return isa<InvokeInst>(I) &&
      isTapirIntrinsic(Intrinsic::taskframe_resume, I, TaskFrame);
}

/// Returns a taskframe.resume that uses the given taskframe, or nullptr if no
/// taskframe.resume uses this taskframe.
InvokeInst *llvm::getTaskFrameResume(Value *TaskFrame) {
  // It should suffice to get the unwind destination of the first
  // taskframe.resume we find.
  for (User *U : TaskFrame->users())
    if (Instruction *I = dyn_cast<Instruction>(U))
      if (isTaskFrameResume(I))
        return cast<InvokeInst>(I);
  return nullptr;
}

/// Returns the unwind destination of a taskframe.resume that uses the given
/// taskframe, or nullptr if no such unwind destination exists.
BasicBlock *llvm::getTaskFrameResumeDest(Value *TaskFrame) {
  if (InvokeInst *TFResume = getTaskFrameResume(TaskFrame))
    return TFResume->getUnwindDest();
  return nullptr;
}

/// Returns true if the given instruction is a sync.uwnind, false otherwise.  If
/// \p SyncRegion is specified, then additionally checks that the sync.unwind
/// uses \p SyncRegion.
bool llvm::isSyncUnwind(const Instruction *I, const Value *SyncRegion) {
  return isTapirIntrinsic(Intrinsic::sync_unwind, I, SyncRegion);
}

/// Returns true if BasicBlock \p B is a placeholder successor, that is, it's
/// the immediate successor of only detached-rethrow and taskframe-resume
/// instructions.
bool llvm::isPlaceholderSuccessor(const BasicBlock *B) {
  for (const BasicBlock *Pred : predecessors(B)) {
    if (!isDetachedRethrow(Pred->getTerminator()) &&
        !isTaskFrameResume(Pred->getTerminator()))
      return false;
    if (B == cast<InvokeInst>(
            Pred->getTerminator())->getUnwindDest())
      return false;
  }
  return true;
}

/// Returns true if the given basic block ends a taskframe, false otherwise.  If
/// \p TaskFrame is specified, then additionally checks that the
/// taskframe.end uses \p TaskFrame.
bool llvm::endsTaskFrame(const BasicBlock *B, const Value *TaskFrame) {
  const Instruction *I = B->getTerminator()->getPrevNode();
  return I && isTapirIntrinsic(Intrinsic::taskframe_end, I, TaskFrame);
}

/// Returns the spindle containing the taskframe.create used by task \p T, or
/// the entry spindle of \p T if \p T has no such taskframe.create spindle.
Spindle *llvm::getTaskFrameForTask(Task *T) {
  Spindle *TF = T->getTaskFrameCreateSpindle();
  if (!TF)
    TF = T->getEntrySpindle();
  return TF;
}

// Removes the given sync.unwind instruction, if it is dead.  Returns true if
// the sync.unwind was removed, false otherwise.
bool llvm::removeDeadSyncUnwind(CallBase *SyncUnwind,
                                DomTreeUpdater *DTU) {
  assert(isSyncUnwind(SyncUnwind) &&
         "removeDeadSyncUnwind not called on a sync.unwind.");
  const Value *SyncRegion = SyncUnwind->getArgOperand(0);

  // Scan predecessor blocks for syncs using this sync.unwind.
  for (BasicBlock *Pred : predecessors(SyncUnwind->getParent()))
    if (SyncInst *SI = dyn_cast<SyncInst>(Pred->getTerminator()))
      if (SyncRegion == SI->getSyncRegion())
        return false;

  // We found no predecessor syncs that use this sync.unwind, so remove it.
  if (InvokeInst *II = dyn_cast<InvokeInst>(SyncUnwind)) {
    II->getUnwindDest()->removePredecessor(II->getParent());
    if (DTU)
      DTU->applyUpdates(
          {{DominatorTree::Delete, II->getUnwindDest(), II->getParent()}});
    ReplaceInstWithInst(II, BranchInst::Create(II->getNormalDest()));
  } else {
    SyncUnwind->eraseFromParent();
  }
  return true;
}

/// Returns true if the reattach instruction appears to match the given detach
/// instruction, false otherwise.
///
/// If a dominator tree is not given, then this method does a best-effort check.
/// In particular, this function might return true when the reattach instruction
/// does not actually match the detach instruction, but instead matches a
/// sibling detach instruction with the same continuation.  This best-effort
/// check is sufficient in some cases, such as during a traversal of a detached
/// task..
bool llvm::ReattachMatchesDetach(const ReattachInst *RI, const DetachInst *DI,
                                 DominatorTree *DT) {
  // Check that the reattach instruction belonds to the same sync region as the
  // detach instruction.
  if (RI->getSyncRegion() != DI->getSyncRegion())
    return false;

  // Check that the destination of the reattach matches the continue destination
  // of the detach.
  if (RI->getDetachContinue() != DI->getContinue())
    return false;

  // If we have a dominator tree, check that the detach edge dominates the
  // reattach.
  if (DT) {
    BasicBlockEdge DetachEdge(DI->getParent(), DI->getDetached());
    if (!DT->dominates(DetachEdge, RI->getParent()))
      return false;
  }

  return true;
}

/// Return the result of AI->isStaticAlloca() if AI were moved to the entry
/// block. Allocas used in inalloca calls and allocas of dynamic array size
/// cannot be static.
/// (Borrowed from Transforms/Utils/InlineFunction.cpp)
static bool allocaWouldBeStaticInEntry(const AllocaInst *AI) {
  return isa<Constant>(AI->getArraySize()) && !AI->isUsedWithInAlloca();
}

// Check whether this Value is used by a lifetime intrinsic.
static bool isUsedByLifetimeMarker(Value *V) {
  for (User *U : V->users()) {
    if (IntrinsicInst *II = dyn_cast<IntrinsicInst>(U)) {
      switch (II->getIntrinsicID()) {
      default: break;
      case Intrinsic::lifetime_start:
      case Intrinsic::lifetime_end:
        return true;
      }
    }
  }
  return false;
}

// Check whether the given alloca already has lifetime.start or lifetime.end
// intrinsics.
static bool hasLifetimeMarkers(AllocaInst *AI) {
  Type *Ty = AI->getType();
  Type *Int8PtrTy = Type::getInt8PtrTy(Ty->getContext(),
                                       Ty->getPointerAddressSpace());
  if (Ty == Int8PtrTy)
    return isUsedByLifetimeMarker(AI);

  // Do a scan to find all the casts to i8*.
  for (User *U : AI->users()) {
    if (U->getType() != Int8PtrTy) continue;
    if (U->stripPointerCasts() != AI) continue;
    if (isUsedByLifetimeMarker(U))
      return true;
  }
  return false;
}

// Move static allocas in Block into Entry, which is assumed to dominate Block.
// Leave lifetime markers behind in Block and before each instruction in
// ExitPoints for those static allocas.  Returns true if Block still contains
// dynamic allocas, which cannot be moved.
bool llvm::MoveStaticAllocasInBlock(
    BasicBlock *Entry, BasicBlock *Block,
    SmallVectorImpl<Instruction *> &ExitPoints) {
  Function *F = Entry->getParent();
  SmallVector<AllocaInst *, 4> StaticAllocas;
  bool ContainsDynamicAllocas = false;
  BasicBlock::iterator InsertPoint = Entry->begin();
  for (BasicBlock::iterator I = Block->begin(),
         E = Block->end(); I != E; ) {
    AllocaInst *AI = dyn_cast<AllocaInst>(I++);
    if (!AI) continue;

    if (!allocaWouldBeStaticInEntry(AI)) {
      ContainsDynamicAllocas = true;
      continue;
    }

    StaticAllocas.push_back(AI);

    // Scan for the block of allocas that we can move over, and move them all at
    // once.
    while (isa<AllocaInst>(I) &&
           allocaWouldBeStaticInEntry(cast<AllocaInst>(I))) {
      StaticAllocas.push_back(cast<AllocaInst>(I));
      ++I;
    }

    // Transfer all of the allocas over in a block.  Using splice means that the
    // instructions aren't removed from the symbol table, then reinserted.
    Entry->getInstList().splice(
        InsertPoint, Block->getInstList(), AI->getIterator(), I);
  }
  // Move any dbg.declares describing the allocas into the entry basic block.
  DIBuilder DIB(*F->getParent());
  for (auto &AI : StaticAllocas)
    replaceDbgDeclareForAlloca(AI, AI, DIB, DIExpression::ApplyOffset, 0);

  // Move any syncregion_start's into the entry basic block.
  for (BasicBlock::iterator I = Block->begin(),
         E = Block->end(); I != E; ) {
    IntrinsicInst *II = dyn_cast<IntrinsicInst>(I++);
    if (!II) continue;
    if (Intrinsic::syncregion_start != II->getIntrinsicID())
      continue;

    while (isa<IntrinsicInst>(I) &&
           Intrinsic::syncregion_start ==
           cast<IntrinsicInst>(I)->getIntrinsicID())
        ++I;

    Entry->getInstList().splice(
        InsertPoint, Block->getInstList(), II->getIterator(), I);
  }

  // Leave lifetime markers for the static alloca's, scoping them to the
  // from cloned block to cloned exit.
  if (!StaticAllocas.empty()) {
    IRBuilder<> Builder(&Block->front());
    for (unsigned ai = 0, ae = StaticAllocas.size(); ai != ae; ++ai) {
      AllocaInst *AI = StaticAllocas[ai];
      // Don't mark swifterror allocas. They can't have bitcast uses.
      if (AI->isSwiftError())
        continue;

      // If the alloca is already scoped to something smaller than the whole
      // function then there's no need to add redundant, less accurate markers.
      if (hasLifetimeMarkers(AI))
        continue;

      // Try to determine the size of the allocation.
      ConstantInt *AllocaSize = nullptr;
      if (ConstantInt *AIArraySize =
          dyn_cast<ConstantInt>(AI->getArraySize())) {
        auto &DL = F->getParent()->getDataLayout();
        Type *AllocaType = AI->getAllocatedType();
        uint64_t AllocaTypeSize = DL.getTypeAllocSize(AllocaType);
        uint64_t AllocaArraySize = AIArraySize->getLimitedValue();

        // Don't add markers for zero-sized allocas.
        if (AllocaArraySize == 0)
          continue;

        // Check that array size doesn't saturate uint64_t and doesn't
        // overflow when it's multiplied by type size.
        if (AllocaArraySize != ~0ULL &&
            UINT64_MAX / AllocaArraySize >= AllocaTypeSize) {
          AllocaSize = ConstantInt::get(Type::getInt64Ty(AI->getContext()),
                                        AllocaArraySize * AllocaTypeSize);
        }
      }

      Builder.CreateLifetimeStart(AI, AllocaSize);
      for (Instruction *ExitPoint : ExitPoints)
        IRBuilder<>(ExitPoint).CreateLifetimeEnd(AI, AllocaSize);
    }
  }

  return ContainsDynamicAllocas;
}

namespace {
/// A class for recording information about inlining a landing pad.
class LandingPadInliningInfo {
  /// Destination of the invoke's unwind.
  BasicBlock *OuterResumeDest;

  /// Destination for the callee's resume.
  BasicBlock *InnerResumeDest = nullptr;

  /// LandingPadInst associated with the detach.
  Value *SpawnerLPad = nullptr;

  /// PHI for EH values from landingpad insts.
  PHINode *InnerEHValuesPHI = nullptr;

  SmallVector<Value*, 8> UnwindDestPHIValues;

  /// Dominator tree to update.
  DominatorTree *DT = nullptr;
public:
  LandingPadInliningInfo(DetachInst *DI, BasicBlock *EHContinue,
                         Value *LPadValInEHContinue,
                         DominatorTree *DT = nullptr)
      : OuterResumeDest(EHContinue), SpawnerLPad(LPadValInEHContinue), DT(DT) {
    // Find the predecessor block of OuterResumeDest.
    BasicBlock *DetachBB = DI->getParent();
    BasicBlock *DetachUnwind = DI->getUnwindDest();
    while (DetachUnwind != OuterResumeDest) {
      DetachBB = DetachUnwind;
      DetachUnwind = DetachUnwind->getUniqueSuccessor();
    }

    // If there are PHI nodes in the unwind destination block, we need to keep
    // track of which values came into them from the detach before removing the
    // edge from this block.
    BasicBlock::iterator I = OuterResumeDest->begin();
    for (; isa<PHINode>(I); ++I) {
      if (&*I == LPadValInEHContinue)
        continue;
      // Save the value to use for this edge.
      PHINode *PHI = cast<PHINode>(I);
      UnwindDestPHIValues.push_back(PHI->getIncomingValueForBlock(DetachBB));
    }
  }

  LandingPadInliningInfo(InvokeInst *TaskFrameResume,
                         DominatorTree *DT = nullptr)
      : OuterResumeDest(TaskFrameResume->getUnwindDest()),
        SpawnerLPad(TaskFrameResume->getLandingPadInst()), DT(DT) {
    // If there are PHI nodes in the unwind destination block, we need to keep
    // track of which values came into them from the detach before removing the
    // edge from this block.
    BasicBlock *InvokeBB = TaskFrameResume->getParent();
    BasicBlock::iterator I = OuterResumeDest->begin();
    for (; isa<PHINode>(I); ++I) {
      // Save the value to use for this edge.
      PHINode *PHI = cast<PHINode>(I);
      UnwindDestPHIValues.push_back(PHI->getIncomingValueForBlock(InvokeBB));
    }
  }

  /// The outer unwind destination is the target of unwind edges introduced for
  /// calls within the inlined function.
  BasicBlock *getOuterResumeDest() const {
    return OuterResumeDest;
  }

  BasicBlock *getInnerResumeDest();

  /// Forward a task resume - a terminator, such as a detached.rethrow or
  /// taskframe.resume, marking the exit from a task for exception handling - to
  /// the spawner's landing pad block.  When the landing pad block has only one
  /// predecessor, this is a simple branch. When there is more than one
  /// predecessor, we need to split the landing pad block after the landingpad
  /// instruction and jump to there.
  void forwardTaskResume(InvokeInst *TR);

  /// Add incoming-PHI values to the unwind destination block for the given
  /// basic block, using the values for the original invoke's source block.
  void addIncomingPHIValuesFor(BasicBlock *BB) const {
    addIncomingPHIValuesForInto(BB, OuterResumeDest);
  }

  void addIncomingPHIValuesForInto(BasicBlock *Src, BasicBlock *Dest) const {
    BasicBlock::iterator I = Dest->begin();
    for (unsigned i = 0, e = UnwindDestPHIValues.size(); i != e; ++i, ++I) {
      PHINode *Phi = cast<PHINode>(I);
      Phi->addIncoming(UnwindDestPHIValues[i], Src);
    }
  }
};
} // end anonymous namespace

/// Get or create a target for the branch from ResumeInsts.
BasicBlock *LandingPadInliningInfo::getInnerResumeDest() {
  if (InnerResumeDest) return InnerResumeDest;

  // Split the outer resume destionation.
  BasicBlock::iterator SplitPoint;
  if (isa<LandingPadInst>(SpawnerLPad))
    SplitPoint = ++cast<Instruction>(SpawnerLPad)->getIterator();
  else
    SplitPoint = OuterResumeDest->getFirstNonPHI()->getIterator();
  InnerResumeDest =
    OuterResumeDest->splitBasicBlock(SplitPoint,
                                     OuterResumeDest->getName() + ".body");
  if (DT)
    // OuterResumeDest dominates InnerResumeDest, which dominates all other
    // nodes dominated by OuterResumeDest.
    if (DomTreeNode *OldNode = DT->getNode(OuterResumeDest)) {
      std::vector<DomTreeNode *> Children(OldNode->begin(), OldNode->end());

      DomTreeNode *NewNode = DT->addNewBlock(InnerResumeDest, OuterResumeDest);
      for (DomTreeNode *I : Children)
        DT->changeImmediateDominator(I, NewNode);
    }

  // The number of incoming edges we expect to the inner landing pad.
  const unsigned PHICapacity = 2;

  // Create corresponding new PHIs for all the PHIs in the outer landing pad.
  Instruction *InsertPoint = &InnerResumeDest->front();
  BasicBlock::iterator I = OuterResumeDest->begin();
  for (unsigned i = 0, e = UnwindDestPHIValues.size(); i != e; ++i, ++I) {
    PHINode *OuterPHI = cast<PHINode>(I);
    PHINode *InnerPHI = PHINode::Create(OuterPHI->getType(), PHICapacity,
                                        OuterPHI->getName() + ".lpad-body",
                                        InsertPoint);
    OuterPHI->replaceAllUsesWith(InnerPHI);
    InnerPHI->addIncoming(OuterPHI, OuterResumeDest);
  }

  // Create a PHI for the exception values.
  InnerEHValuesPHI = PHINode::Create(SpawnerLPad->getType(), PHICapacity,
                                     "eh.lpad-body", InsertPoint);
  SpawnerLPad->replaceAllUsesWith(InnerEHValuesPHI);
  InnerEHValuesPHI->addIncoming(SpawnerLPad, OuterResumeDest);

  // All done.
  return InnerResumeDest;
}

/// Forward a task resume - a terminator, such as a detached.rethrow or
/// taskframe.resume, marking the exit from a task for exception handling - to
/// the spawner's landing pad block.  When the landing pad block has only one
/// predecessor, this is a simple branch. When there is more than one
/// predecessor, we need to split the landing pad block after the landingpad
/// instruction and jump to there.
void LandingPadInliningInfo::forwardTaskResume(InvokeInst *TR) {
  BasicBlock *Dest = getInnerResumeDest();
  BasicBlock *Src = TR->getParent();

  BranchInst::Create(Dest, Src);
  if (DT)
    DT->changeImmediateDominator(
        Dest, DT->findNearestCommonDominator(Dest, Src));

  // Update the PHIs in the destination. They were inserted in an order which
  // makes this work.
  addIncomingPHIValuesForInto(Src, Dest);

  InnerEHValuesPHI->addIncoming(TR->getOperand(1), Src);

  // Update the DT
  BasicBlock *NormalDest = nullptr, *UnwindDest = nullptr;
  if (DT) {
    if (TR->getNormalDest()->getSinglePredecessor()) {
      NormalDest = TR->getNormalDest();
      DT->eraseNode(TR->getNormalDest());
    } else
      DT->deleteEdge(Src, TR->getNormalDest());

    if (TR->getUnwindDest()->getSinglePredecessor()) {
      UnwindDest = TR->getUnwindDest();
      DT->eraseNode(TR->getUnwindDest());
    } else
      DT->deleteEdge(Src, TR->getUnwindDest());
  }

  // Remove the TR
  if (!NormalDest)
    for (PHINode &PN : TR->getNormalDest()->phis())
      PN.removeIncomingValue(Src);
  if (!UnwindDest)
    for (PHINode &PN : TR->getUnwindDest()->phis())
      PN.removeIncomingValue(Src);

  TR->eraseFromParent();
  if (NormalDest)
    NormalDest->eraseFromParent();
  if (UnwindDest)
    UnwindDest->eraseFromParent();
}

static void handleDetachedLandingPads(
    DetachInst *DI, BasicBlock *EHContinue, Value *LPadValInEHContinue,
    SmallPtrSetImpl<LandingPadInst *> &InlinedLPads,
    SmallVectorImpl<Instruction *> &DetachedRethrows,
    DominatorTree *DT = nullptr) {
  LandingPadInliningInfo DetUnwind(DI, EHContinue, LPadValInEHContinue, DT);

  // Append the clauses from the outer landing pad instruction into the inlined
  // landing pad instructions.
  LandingPadInst *OuterLPad = DI->getLandingPadInst();
  for (LandingPadInst *InlinedLPad : InlinedLPads) {
    unsigned OuterNum = OuterLPad->getNumClauses();
    InlinedLPad->reserveClauses(OuterNum);
    for (unsigned OuterIdx = 0; OuterIdx != OuterNum; ++OuterIdx)
      InlinedLPad->addClause(OuterLPad->getClause(OuterIdx));
    if (OuterLPad->isCleanup())
      InlinedLPad->setCleanup(true);
  }

  // Forward the detached rethrows.
  for (Instruction *DR : DetachedRethrows)
    DetUnwind.forwardTaskResume(cast<InvokeInst>(DR));
}

static void cloneEHBlocks(Function *F, Value *SyncRegion,
                          SmallVectorImpl<BasicBlock *> &EHBlocksToClone,
                          SmallPtrSetImpl<BasicBlock *> &EHBlockPreds,
                          SmallPtrSetImpl<LandingPadInst *> *InlinedLPads,
                          SmallVectorImpl<Instruction *> *DetachedRethrows,
                          DominatorTree *DT = nullptr) {
  ValueToValueMapTy VMap;
  SmallVector<BasicBlock *, 8> NewBlocks;
  SmallPtrSet<BasicBlock *, 8> NewBlocksSet;
  SmallPtrSet<LandingPadInst *, 4> NewInlinedLPads;
  SmallPtrSet<Instruction *, 4> NewDetachedRethrows;
  for (BasicBlock *BB : EHBlocksToClone) {
    BasicBlock *New = CloneBasicBlock(BB, VMap, ".sd", F);
    VMap[BB] = New;
    if (DT)
      DT->addNewBlock(New, DT->getRoot());
    NewBlocks.push_back(New);
    NewBlocksSet.insert(New);
  }

  SmallPtrSet<BasicBlock *, 8> NewSuccSet;
  // For all old successors, remove the predecessors in EHBlockPreds.
  for (BasicBlock *EHPred : EHBlockPreds)
    for (BasicBlock *OldSucc : successors(EHPred))
      if (VMap.count(OldSucc)) {
        OldSucc->removePredecessor(EHPred);
        NewSuccSet.insert(cast<BasicBlock>(VMap[OldSucc]));
      }

  // For all new successors, remove the predecessors not in EHBlockPreds.
  for (BasicBlock *NewSucc : NewSuccSet) {
    for (BasicBlock::iterator I = NewSucc->begin(); isa<PHINode>(I); ) {
      PHINode *PN = cast<PHINode>(I++);

      // NOTE! This loop walks backwards for a reason! First off, this minimizes
      // the cost of removal if we end up removing a large number of values, and
      // second off, this ensures that the indices for the incoming values
      // aren't invalidated when we remove one.
      for (int64_t i = PN->getNumIncomingValues() - 1; i >= 0; --i)
        if (!EHBlockPreds.count(PN->getIncomingBlock(i)))
          PN->removeIncomingValue(i, false);
    }
  }

  for (BasicBlock *EHBlock : EHBlocksToClone) {
    BasicBlock *NewEHBlock = cast<BasicBlock>(VMap[EHBlock]);
    BasicBlock *IDomBB = nullptr;
    if (DT) {
      BasicBlock *IDomBB = DT->getNode(EHBlock)->getIDom()->getBlock();
      if (VMap.lookup(IDomBB))
        DT->changeImmediateDominator(cast<BasicBlock>(VMap[EHBlock]),
                                     cast<BasicBlock>(VMap[IDomBB]));
      else
        DT->changeImmediateDominator(cast<BasicBlock>(VMap[EHBlock]), IDomBB);
    }
    // Move the edges from Preds to point to NewBB instead of BB.
    for (BasicBlock *Pred : EHBlockPreds) {
      // This is slightly more strict than necessary; the minimum requirement is
      // that there be no more than one indirectbr branching to BB. And all
      // BlockAddress uses would need to be updated.
      assert(!isa<IndirectBrInst>(Pred->getTerminator()) &&
             "Cannot split an edge from an IndirectBrInst");
      Pred->getTerminator()->replaceUsesOfWith(EHBlock, NewEHBlock);
      if (DT && Pred == IDomBB)
        DT->deleteEdge(Pred, EHBlock);
    }
  }

  // Remap instructions in the cloned blocks based on VMap.
  remapInstructionsInBlocks(NewBlocks, VMap);

  // Update all successors of the cloned EH blocks.
  for (BasicBlock *BB : EHBlocksToClone) {
    for (BasicBlock *Succ : successors(BB)) {
      if (NewBlocksSet.count(Succ)) continue;
      // Update the PHI's in the successor of the cloned EH block.
      for (PHINode &PN : Succ->phis()) {
        Value *Val = PN.getIncomingValueForBlock(BB);
        Value *NewVal = VMap.count(Val) ? cast<Value>(VMap[Val]) : Val;
        PN.addIncoming(NewVal, cast<BasicBlock>(VMap[BB]));
      }
    }
  }

  // Move the new InlinedLPads and DetachedRethrows to the appropriate
  // set/vector.
  if (InlinedLPads) {
    for (LandingPadInst *LPad : *InlinedLPads) {
      if (VMap.count(LPad))
        NewInlinedLPads.insert(cast<LandingPadInst>(VMap[LPad]));
      else
        NewInlinedLPads.insert(LPad);
    }
    InlinedLPads->clear();
    for (LandingPadInst *LPad : NewInlinedLPads)
      InlinedLPads->insert(LPad);
  }
  if (DetachedRethrows) {
    for (Instruction *DR : *DetachedRethrows) {
      if (VMap.count(DR))
        NewDetachedRethrows.insert(cast<Instruction>(VMap[DR]));
      else
        NewDetachedRethrows.insert(DR);
    }
    DetachedRethrows->clear();
    for (Instruction *DR : NewDetachedRethrows)
      DetachedRethrows->push_back(DR);
  }
}

// Helper function to find landingpads in the specified taskframe.
static void getTaskFrameLandingPads(
    Value *TaskFrame, Instruction *TaskFrameResume,
    SmallPtrSetImpl<LandingPadInst *> &InlinedLPads) {
  const BasicBlock *TaskFrameBB = cast<Instruction>(TaskFrame)->getParent();
  SmallVector<BasicBlock *, 8> Worklist;
  SmallPtrSet<BasicBlock *, 8> Visited;
  // Add the parent of TaskFrameResume to the worklist.
  Worklist.push_back(TaskFrameResume->getParent());

  while (!Worklist.empty()) {
    BasicBlock *BB = Worklist.pop_back_val();
    if (!Visited.insert(BB).second)
      continue;

    // Terminate the search once we encounter the BB where the taskframe is
    // defined.
    if (TaskFrameBB == BB)
      continue;

    // If we find a landingpad, add it to the set.
    if (BB->isLandingPad())
      InlinedLPads.insert(BB->getLandingPadInst());

    // Add predecessors to the worklist, but skip any predecessors within nested
    // tasks or nested taskframes.
    for (BasicBlock *Pred : predecessors(BB)) {
      if (isa<ReattachInst>(Pred->getTerminator()) ||
          isDetachedRethrow(Pred->getTerminator()) ||
          isTaskFrameResume(Pred->getTerminator()))
        continue;
      Worklist.push_back(Pred);
    }
  }
}

// Helper method to handle a given taskframe.resume.
static void handleTaskFrameResume(Value *TaskFrame,
                                  Instruction *TaskFrameResume,
                                  DominatorTree *DT = nullptr) {
  // Get landingpads to inline.
  SmallPtrSet<LandingPadInst *, 1> InlinedLPads;
  getTaskFrameLandingPads(TaskFrame, TaskFrameResume, InlinedLPads);

  InvokeInst *TFR = cast<InvokeInst>(TaskFrameResume);
  LandingPadInliningInfo TFResumeDest(TFR);

  // Append the clauses from the outer landing pad instruction into the inlined
  // landing pad instructions.
  LandingPadInst *OuterLPad = TFR->getLandingPadInst();
  for (LandingPadInst *InlinedLPad : InlinedLPads) {
    unsigned OuterNum = OuterLPad->getNumClauses();
    InlinedLPad->reserveClauses(OuterNum);
    for (unsigned OuterIdx = 0; OuterIdx != OuterNum; ++OuterIdx)
      InlinedLPad->addClause(OuterLPad->getClause(OuterIdx));
    if (OuterLPad->isCleanup())
      InlinedLPad->setCleanup(true);
  }

  // Forward the taskframe.resume.
  TFResumeDest.forwardTaskResume(TFR);
}

void llvm::InlineTaskFrameResumes(Value *TaskFrame, DominatorTree *DT) {
  SmallVector<Instruction *, 1> TaskFrameResumes;
  // Record all taskframe.resume markers that use TaskFrame.
  for (User *U : TaskFrame->users())
    if (Instruction *I = dyn_cast<Instruction>(U))
      if (isTaskFrameResume(I))
        TaskFrameResumes.push_back(I);

  // Handle all taskframe.resume markers.
  for (Instruction *TFR : TaskFrameResumes)
    handleTaskFrameResume(TaskFrame, TFR, DT);
}

void llvm::SerializeDetach(DetachInst *DI, BasicBlock *ParentEntry,
                           BasicBlock *EHContinue, Value *LPadValInEHContinue,
                           SmallVectorImpl<Instruction *> &Reattaches,
                           SmallVectorImpl<BasicBlock *> *EHBlocksToClone,
                           SmallPtrSetImpl<BasicBlock *> *EHBlockPreds,
                           SmallPtrSetImpl<LandingPadInst *> *InlinedLPads,
                           SmallVectorImpl<Instruction *> *DetachedRethrows,
                           DominatorTree *DT) {
  BasicBlock *Spawner = DI->getParent();
  BasicBlock *TaskEntry = DI->getDetached();
  BasicBlock *Continue = DI->getContinue();
  BasicBlock *Unwind = DI->getUnwindDest();
  Value *SyncRegion = DI->getSyncRegion();

  // If the spawned task has a taskframe, serialize the taskframe.
  if (Value *TaskFrame = getTaskFrameUsed(TaskEntry))
    InlineTaskFrameResumes(TaskFrame, DT);

  // Clone any EH blocks that need cloning.
  if (EHBlocksToClone) {
    assert(EHBlockPreds &&
           "Given EH blocks to clone, but not blocks exiting to them.");
    cloneEHBlocks(Spawner->getParent(), SyncRegion, *EHBlocksToClone,
                  *EHBlockPreds, InlinedLPads, DetachedRethrows, DT);
  }

  // Collect the exit points into a single vector.
  SmallVector<Instruction *, 8> ExitPoints;
  for (Instruction *Exit : Reattaches)
    ExitPoints.push_back(Exit);
  if (DetachedRethrows)
    for (Instruction *Exit : *DetachedRethrows)
      ExitPoints.push_back(Exit);

  // Move static alloca instructions in the task entry to the appropriate entry
  // block.
  bool ContainsDynamicAllocas =
    MoveStaticAllocasInBlock(ParentEntry, TaskEntry, ExitPoints);
  // If the cloned loop contained dynamic alloca instructions, wrap the inlined
  // code with llvm.stacksave/llvm.stackrestore intrinsics.
  if (ContainsDynamicAllocas) {
    Module *M = Spawner->getParent()->getParent();
    // Get the two intrinsics we care about.
    Function *StackSave = Intrinsic::getDeclaration(M, Intrinsic::stacksave);
    Function *StackRestore =
      Intrinsic::getDeclaration(M,Intrinsic::stackrestore);

    // Insert the llvm.stacksave.
    CallInst *SavedPtr = IRBuilder<>(TaskEntry, TaskEntry->begin())
      .CreateCall(StackSave, {}, "savedstack");

    // Insert a call to llvm.stackrestore before the reattaches in the original
    // Tapir loop.
    for (Instruction *Exit : ExitPoints)
      IRBuilder<>(Exit).CreateCall(StackRestore, SavedPtr);
  }

  // Handle any detached-rethrows in the task.
  if (DI->hasUnwindDest()) {
    assert(InlinedLPads && "Missing set of landing pads in task.");
    assert(DetachedRethrows && "Missing set of detached rethrows in task.");
    handleDetachedLandingPads(DI, EHContinue, LPadValInEHContinue,
                              *InlinedLPads, *DetachedRethrows, DT);
  }

  // Replace reattaches with unconditional branches to the continuation.
  BasicBlock *ReattachDom = nullptr;
  for (Instruction *I : Reattaches) {
    assert(isa<ReattachInst>(I) && "Recorded reattach is not a reattach");
    assert(cast<ReattachInst>(I)->getSyncRegion() == SyncRegion &&
           "Reattach does not match sync region of detach.");
    if (DT) {
      if (!ReattachDom)
        ReattachDom = I->getParent();
      else
        ReattachDom = DT->findNearestCommonDominator(ReattachDom,
                                                     I->getParent());
    }
    ReplaceInstWithInst(I, BranchInst::Create(Continue));
  }

  // Replace the detach with an unconditional branch to the task entry.
  Continue->removePredecessor(Spawner);
  ReplaceInstWithInst(DI, BranchInst::Create(TaskEntry));

  // Update dominator tree.
  if (DT) {
    if (DT->dominates(Spawner, Continue))
      DT->changeImmediateDominator(Continue, ReattachDom);
    if (DI->hasUnwindDest())
      DT->deleteEdge(Spawner, Unwind);
  }
}

/// Analyze a task for serialization
void llvm::AnalyzeTaskForSerialization(
    Task *T, SmallVectorImpl<Instruction *> &Reattaches,
    SmallVectorImpl<BasicBlock *> &EHBlocksToClone,
    SmallPtrSetImpl<BasicBlock *> &EHBlockPreds,
    SmallPtrSetImpl<LandingPadInst *> &InlinedLPads,
    SmallVectorImpl<Instruction *> &DetachedRethrows) {
  assert(!T->isRootTask() && "Cannot serialize root task.");
  Value *SyncRegion = T->getDetach()->getSyncRegion();
  for (Spindle *S : depth_first<InTask<Spindle *>>(T->getEntrySpindle())) {
    // Look for landing pads in the task (and no subtask) to be merged with a
    // spawner landing pad.
    for (BasicBlock *BB : S->blocks()) {
      // Record any shared-EH blocks that need to be cloned.
      if (S->isSharedEH()) {
	// Skip basic blocks that are placeholder successors
	if (isPlaceholderSuccessor(BB))
	  continue;
        EHBlocksToClone.push_back(BB);
        if (S->getEntry() == BB)
          for (BasicBlock *Pred : predecessors(BB))
            if (T->simplyEncloses(Pred))
              EHBlockPreds.insert(Pred);
      }
      if (InvokeInst *II = dyn_cast<InvokeInst>(BB->getTerminator())) {
        if (!isDetachedRethrow(BB->getTerminator(), SyncRegion)) {
          assert(!isDetachedRethrow(BB->getTerminator()) &&
                 "Detached rethrow in task does not match sync region.");
          // Record this landing pad to merge with DI's landing pad.
          InlinedLPads.insert(II->getLandingPadInst());
        }
      } else if (DetachInst *SubDI = dyn_cast<DetachInst>(BB->getTerminator()))
        if (SubDI->hasUnwindDest())
          // Record this landing pad to merge with DI's landing pad.
          InlinedLPads.insert(SubDI->getLandingPadInst());
    }

    if (!T->isTaskExiting(S))
      continue;

    // Find the reattach and detached-rethrow exits from this task.
    for (BasicBlock *BB : S->blocks()) {
      if (isa<ReattachInst>(BB->getTerminator())) {
        assert(cast<ReattachInst>(BB->getTerminator())->getSyncRegion() ==
               SyncRegion &&
               "Reattach in task does not match sync region with detach.");
        Reattaches.push_back(BB->getTerminator());
      } else if (InvokeInst *II = dyn_cast<InvokeInst>(BB->getTerminator())) {
        if (isDetachedRethrow(II, SyncRegion))
          // Get detached rethrows in the task to forward.
          DetachedRethrows.push_back(II);
      }
    }
  }
}

/// Serialize the detach DI that spawns task T.  If provided, the dominator tree
/// DT will be updated to reflect the serialization.
void llvm::SerializeDetach(DetachInst *DI, Task *T, DominatorTree *DT) {
  assert(DI && "SerializeDetach given nullptr for detach.");
  assert(DI == T->getDetach() && "Task and detach arguments do not match.");
  SmallVector<BasicBlock *, 4> EHBlocksToClone;
  SmallPtrSet<BasicBlock *, 4> EHBlockPreds;
  SmallVector<Instruction *, 4> Reattaches;
  SmallPtrSet<LandingPadInst *, 4> InlinedLPads;
  SmallVector<Instruction *, 4> DetachedRethrows;

  AnalyzeTaskForSerialization(T, Reattaches, EHBlocksToClone, EHBlockPreds,
                              InlinedLPads, DetachedRethrows);
  BasicBlock *EHContinue = nullptr;
  Value *LPadVal = nullptr;
  if (DI->hasUnwindDest()) {
    EHContinue = T->getEHContinuationSpindle()->getEntry();
    LPadVal = T->getLPadValueInEHContinuationSpindle();
  }
  SerializeDetach(DI, T->getParentTask()->getEntry(), EHContinue, LPadVal,
                  Reattaches, &EHBlocksToClone, &EHBlockPreds, &InlinedLPads,
                  &DetachedRethrows, DT);
}

/// SerializeDetachedCFG - Serialize the sub-CFG detached by the specified
/// detach instruction.  Removes the detach instruction and returns a pointer to
/// the branch instruction that replaces it.
///
BranchInst *llvm::SerializeDetachedCFG(DetachInst *DI, DominatorTree *DT) {
  // Get the parent of the detach instruction.
  BasicBlock *Detacher = DI->getParent();
  // Get the detached block and continuation of this detach.
  BasicBlock *Detached = DI->getDetached();
  BasicBlock *Continuation = DI->getContinue();
  BasicBlock *Unwind = nullptr;
  if (DI->hasUnwindDest())
    Unwind = DI->getUnwindDest();

  assert(Detached->getSinglePredecessor() &&
         "Detached block has multiple predecessors.");

  // Get the detach edge from DI.
  BasicBlockEdge DetachEdge(Detacher, Detached);

  // Collect the reattaches into the continuation.  If DT is available, verify
  // that all reattaches are dominated by the detach edge from DI.
  SmallVector<ReattachInst *, 8> Reattaches;
  // If we only find a single reattach into the continuation, capture it so we
  // can later update the dominator tree.
  BasicBlock *SingleReattacher = nullptr;
  int ReattachesFound = 0;
  for (auto PI = pred_begin(Continuation), PE = pred_end(Continuation);
       PI != PE; PI++) {
    BasicBlock *Pred = *PI;
    // Skip the detacher.
    if (Detacher == Pred) continue;
    // Record the reattaches found.
    if (isa<ReattachInst>(Pred->getTerminator())) {
      ReattachesFound++;
      if (!SingleReattacher)
        SingleReattacher = Pred;
      if (DT) {
        assert(DT->dominates(DetachEdge, Pred) &&
               "Detach edge does not dominate a reattach "
               "into its continuation.");
      }
      Reattaches.push_back(cast<ReattachInst>(Pred->getTerminator()));
    }
  }
  // TODO: It's possible to detach a CFG that does not terminate with a
  // reattach.  For example, optimizations can create detached CFG's that are
  // terminated by unreachable terminators only.  Some of these special cases
  // lead to problems with other passes, however, and this check will identify
  // those special cases early while we sort out those issues.
  assert(!Reattaches.empty() && "No reattach found for detach.");

  // Replace each reattach with branches to the continuation.
  for (ReattachInst *RI : Reattaches) {
    BranchInst *ReplacementBr = BranchInst::Create(Continuation, RI);
    ReplacementBr->setDebugLoc(RI->getDebugLoc());
    RI->eraseFromParent();
  }

  // Replace the new detach with a branch to the detached CFG.
  Continuation->removePredecessor(DI->getParent());
  if (Unwind)
    Unwind->removePredecessor(DI->getParent());
  BranchInst *ReplacementBr = BranchInst::Create(Detached, DI);
  ReplacementBr->setDebugLoc(DI->getDebugLoc());
  DI->eraseFromParent();

  // Update the dominator tree.
  if (DT)
    if (DT->dominates(Detacher, Continuation) && 1 == ReattachesFound)
      DT->changeImmediateDominator(Continuation, SingleReattacher);

  return ReplacementBr;
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

static const Value *getCanonicalTaskFrameCreate(const BasicBlock *BB) {
  if (const IntrinsicInst *II = dyn_cast<IntrinsicInst>(&BB->front()))
    if (Intrinsic::taskframe_create == II->getIntrinsicID() &&
        isCanonicalTaskFrameCreate(II))
      return II;
  return nullptr;
}

/// GetDetachedCtx - Get the entry basic block to the detached context
/// that contains the specified block.
///
BasicBlock *llvm::GetDetachedCtx(BasicBlock *BB) {
  return const_cast<BasicBlock *>(
      GetDetachedCtx(const_cast<const BasicBlock *>(BB)));
}

const BasicBlock *llvm::GetDetachedCtx(const BasicBlock *BB) {
  // Traverse the CFG backwards until we either reach the entry block of the
  // function or we find a detach instruction that detaches the current block.
  SmallPtrSet<const BasicBlock *, 32> Visited;
  SmallVector<const BasicBlock *, 32> WorkList;
  SmallPtrSet<const Value *, 2> TaskFramesToIgnore;
  WorkList.push_back(BB);
  while (!WorkList.empty()) {
    const BasicBlock *CurrBB = WorkList.pop_back_val();
    if (!Visited.insert(CurrBB).second)
      continue;

    // If we find a canonical taskframe.create that we're not ignoring, then
    // we've found the context.
    if (const Value *TaskFrame = getCanonicalTaskFrameCreate(CurrBB))
      if (!TaskFramesToIgnore.count(TaskFrame))
        return CurrBB;

    for (const BasicBlock *PredBB : predecessors(CurrBB)) {
      // Skip predecessors via reattach instructions.  The detacher block
      // corresponding to this reattach is also a predecessor of the current
      // basic block.
      if (isa<ReattachInst>(PredBB->getTerminator()))
        continue;

      // Skip predecessors via detach rethrows.
      if (isDetachedRethrow(PredBB->getTerminator()))
        continue;

      // If we find a taskframe.resume, add its taskframe to the set of
      // taskframes to ignore.
      if (isTaskFrameResume(PredBB->getTerminator())) {
        const InvokeInst *II = cast<InvokeInst>(PredBB->getTerminator());
        TaskFramesToIgnore.insert(II->getArgOperand(0));
      } else if (endsUnassociatedTaskFrame(PredBB)) {
        const CallBase *TFEnd = cast<CallBase>(
            PredBB->getTerminator()->getPrevNode());
        TaskFramesToIgnore.insert(TFEnd->getArgOperand(0));
      }

      // If the predecessor is terminated by a detach, check to see if
      // that detach spawned the current basic block.
      if (isa<DetachInst>(PredBB->getTerminator())) {
        const DetachInst *DI = cast<DetachInst>(PredBB->getTerminator());
        if (DI->getDetached() == CurrBB)
          // Return the current block, which is the entry of this detached
          // sub-CFG.
          return CurrBB;
        else if (const Value *SubTaskFrame =
                 getTaskFrameUsed(DI->getDetached()))
          // Ignore this tasks's taskframe, if it has one.
          TaskFramesToIgnore.insert(SubTaskFrame);
      }

      // Otherwise, add the predecessor block to the work list to search.
      WorkList.push_back(PredBB);
    }
  }

  // Our search didn't find anything, so return the entry of the function
  // containing the given block.
  return &(BB->getParent()->getEntryBlock());
}

// Returns true if the function may not be synced at the point of the given
// basic block, false otherwise.  This function does a simple depth-first
// traversal of the CFG, and as such, produces a conservative result.
bool llvm::mayBeUnsynced(const BasicBlock *BB) {
  SmallPtrSet<const BasicBlock *, 32> Visited;
  SmallVector<const BasicBlock *, 32> WorkList;
  SmallPtrSet<const Value *, 2> TaskFramesToIgnore;
  WorkList.push_back(BB);
  while (!WorkList.empty()) {
    const BasicBlock *CurrBB = WorkList.pop_back_val();
    if (!Visited.insert(CurrBB).second)
      continue;

    // If we find a canonical taskframe.create that we're not ignoring, then
    // we've found the context.
    if (const Value *TaskFrame = getCanonicalTaskFrameCreate(CurrBB))
      if (!TaskFramesToIgnore.count(TaskFrame))
        continue;

    for (const BasicBlock *PredBB : predecessors(CurrBB)) {
      // If we find a predecessor via reattach instructions, then
      // wconservatively return that we may not be synced.
      if (isa<ReattachInst>(PredBB->getTerminator()))
          return true;

      // If we find a predecessor via a detached.rethrow, then conservatively
      // return that we may not be synced.
      if (isDetachedRethrow(PredBB->getTerminator()))
        return true;

      // If we find a taskframe.resume, add its taskframe to the set of
      // taskframes to ignore.
      if (isTaskFrameResume(PredBB->getTerminator())) {
        const InvokeInst *II = cast<InvokeInst>(PredBB->getTerminator());
        TaskFramesToIgnore.insert(II->getArgOperand(0));
      } else if (endsUnassociatedTaskFrame(PredBB)) {
        const CallBase *TFEnd = cast<CallBase>(
            PredBB->getTerminator()->getPrevNode());
        TaskFramesToIgnore.insert(TFEnd->getArgOperand(0));
      }

      // If the predecessor is terminated by a detach, check to see if
      // that detach spawned the current basic block.
      if (isa<DetachInst>(PredBB->getTerminator())) {
        const DetachInst *DI = cast<DetachInst>(PredBB->getTerminator());
        if (DI->getDetached() == CurrBB)
          // Return the current block, which is the entry of this detached
          // sub-CFG.
          continue;
        else
          // We encountered a continue or unwind destination of a detach.
          // Conservatively return that we may not be synced.
          return true;
      }

      // Otherwise, add the predecessor block to the work list to search.
      WorkList.push_back(PredBB);
    }
  }
  return false;
}

/// isCriticalContinueEdge - Return true if the specified edge is a critical
/// detach-continue edge.  Critical detach-continue edges are critical edges -
/// from a block with multiple successors to a block with multiple predecessors
/// - even after ignoring all reattach edges.
bool llvm::isCriticalContinueEdge(const Instruction *TI, unsigned SuccNum) {
  assert(SuccNum < TI->getNumSuccessors() && "Illegal edge specification!");
  if (TI->getNumSuccessors() == 1) return false;

  // Edge must come from a detach.
  if (!isa<DetachInst>(TI)) return false;
  // Edge must go to the continuation.
  if (SuccNum != 1) return false;

  const BasicBlock *Dest = TI->getSuccessor(SuccNum);
  const_pred_iterator I = pred_begin(Dest), E = pred_end(Dest);

  // If there is more than one predecessor, this is a critical edge...
  assert(I != E && "No preds, but we have an edge to the block?");
  const BasicBlock *DetachPred = TI->getParent();
  for (; I != E; ++I) {
    if (DetachPred == *I) continue;
    // Even if a reattach instruction isn't associated with the detach
    // instruction TI, we can safely skip it, because it will be associated with
    // a different detach instruction that precedes this block.
    if (isa<ReattachInst>((*I)->getTerminator())) continue;
    return true;
  }
  return false;
}

/// canDetach - Return true if the given function can perform a detach, false
/// otherwise.
bool llvm::canDetach(const Function *F) {
  for (const BasicBlock &BB : *F)
    if (isa<DetachInst>(BB.getTerminator()))
      return true;
  return false;
}

void llvm::GetDetachedCFG(const DetachInst &DI, const DominatorTree &DT,
                          SmallPtrSetImpl<BasicBlock *> &TaskBlocks,
                          SmallPtrSetImpl<BasicBlock *> &EHBlocks,
                          SmallPtrSetImpl<BasicBlock *> &TaskReturns) {
  SmallVector<BasicBlock *, 32> Todo;
  SmallVector<BasicBlock *, 4> WorkListEH;

  LLVM_DEBUG(dbgs() << "Finding CFG detached by " << DI << "\n");

  BasicBlock *Detached = DI.getDetached();
  BasicBlock *Continue = DI.getContinue();
  Value *SyncRegion = DI.getSyncRegion();
  BasicBlockEdge DetachEdge(DI.getParent(), Detached);

  Todo.push_back(Detached);
  while (!Todo.empty()) {
    BasicBlock *BB = Todo.pop_back_val();

    if (!TaskBlocks.insert(BB).second) continue;

    LLVM_DEBUG(dbgs() << "  Found block " << BB->getName() << "\n");

    Instruction *Term = BB->getTerminator();
    if (nullptr == Term)
      llvm_unreachable("BB with null terminator found.");

    if (ReattachInst *RI = dyn_cast<ReattachInst>(Term)) {
      // Either a reattach instruction terminates the detached CFG or it
      // terminates a nested detached CFG.  If it terminates a nested detached
      // CFG, it can simply be ignored, because the corresponding nested detach
      // instruction will be processed later.
      if (RI->getDetachContinue() != Continue) continue;
      assert(RI->getSyncRegion() == SyncRegion &&
             "Reattach terminating detached CFG has nonmatching sync region.");
      TaskReturns.insert(BB);
      continue;
    } else if (DetachInst *NestedDI = dyn_cast<DetachInst>(Term)) {
      assert(NestedDI != &DI && "Found recursive Detach");
      // Add the successors of the nested detach instruction for searching.
      Todo.push_back(NestedDI->getDetached());
      Todo.push_back(NestedDI->getContinue());
      if (NestedDI->hasUnwindDest())
        Todo.push_back(NestedDI->getUnwindDest());
      continue;
    } else if (SyncInst *SI = dyn_cast<SyncInst>(Term)) {
      // A sync instruction should only apply to nested detaches within this
      // task.  Hence it can be treated like a branch.
      assert(SI->getSyncRegion() != SyncRegion &&
             "Sync in detached task applies to parent parallel context.");
      Todo.push_back(SI->getSuccessor(0));
      continue;
    } else if (isa<BranchInst>(Term) || isa<SwitchInst>(Term) ||
               isa<InvokeInst>(Term)) {
      if (isDetachedRethrow(Term, SyncRegion)) {
        // A detached rethrow terminates this task and is included in the set of
        // exception-handling blocks that might not be unique to this task.
        LLVM_DEBUG(dbgs() << "  Exit block " << BB->getName() << "\n");
        TaskReturns.insert(BB);
        EHBlocks.insert(BB);
      } else {
        for (BasicBlock *Succ : successors(BB)) {
          if (DT.dominates(DetachEdge, Succ)) {
            LLVM_DEBUG(dbgs() <<
                       "Adding successor " << Succ->getName() << "\n");
            Todo.push_back(Succ);
          } else {
            // We assume that this block is an exception-handling block and save
            // it for later processing.
            LLVM_DEBUG(dbgs() <<
                       "  Exit block to search " << Succ->getName() << "\n");
            EHBlocks.insert(Succ);
            WorkListEH.push_back(Succ);
          }
        }
      }
      continue;
    } else if (isa<UnreachableInst>(Term)) {
      // We don't bother cloning unreachable exits from the detached CFG at this
      // point.  We're cloning the entire detached CFG anyway when we outline
      // the function.
      continue;
    } else {
      llvm_unreachable("Detached task does not absolutely terminate in reattach");
    }
  }

  // Find the exception-handling exit blocks.
  {
    SmallPtrSet<BasicBlock *, 4> Visited;
    while (!WorkListEH.empty()) {
      BasicBlock *BB = WorkListEH.pop_back_val();
      if (!Visited.insert(BB).second)
        continue;

      // Make sure that the control flow through these exception-handling blocks
      // cannot re-enter the blocks being outlined.
      assert(!TaskBlocks.count(BB) &&
             "EH blocks for a detached task reenter that task.");

      // Make sure that the control flow through these exception-handling blocks
      // doesn't perform an ordinary return or resume.
      assert(!isa<ReturnInst>(BB->getTerminator()) &&
             "EH block terminated by return.");
      assert(!isa<ResumeInst>(BB->getTerminator()) &&
             "EH block terminated by resume.");

      // Make sure that the control flow through these exception-handling blocks
      // doesn't reattach to the detached CFG's continuation.
      LLVM_DEBUG({
          if (ReattachInst *RI = dyn_cast<ReattachInst>(BB->getTerminator()))
            assert(RI->getSuccessor(0) != Continue &&
                   "Exit block reaches a reattach to the continuation.");
        });

      // Stop searching down this path upon finding a detached rethrow.
      if (isDetachedRethrow(BB->getTerminator(), SyncRegion)) {
        TaskReturns.insert(BB);
        continue;
      }

      for (BasicBlock *Succ : successors(BB)) {
        EHBlocks.insert(Succ);
        WorkListEH.push_back(Succ);
      }
    }

    // Visited now contains exception-handling blocks that we want to clone as
    // part of outlining.
    for (BasicBlock *EHBlock : Visited)
      TaskBlocks.insert(EHBlock);
  }

  LLVM_DEBUG({
      dbgs() << "Exit blocks:";
      for (BasicBlock *Exit : EHBlocks) {
        if (DT.dominates(DetachEdge, Exit))
          dbgs() << "(dominated)";
        else
          dbgs() << "(shared)";
        dbgs() << *Exit;
      }
      dbgs() << "\n";
    });
}

// Helper function to find PHI nodes that depend on the landing pad in the
// unwind destination of this task's detach.
void llvm::getDetachUnwindPHIUses(DetachInst *DI,
                                  SmallPtrSetImpl<BasicBlock *> &UnwindPHIs) {
  // Get the landing pad of the unwind destination of the detach.
  LandingPadInst *LPad = nullptr;
  if (DI && DI->hasUnwindDest()) {
    BasicBlock *UnwindDest = DI->getUnwindDest();
    LPad = UnwindDest->getLandingPadInst();
    assert(LPad && "Unwind of detach is not a landing pad.");
  }
  if (!LPad) return;

  // Walk the chain of uses of this landing pad to find all PHI nodes that
  // depend on it, directly or indirectly.
  SmallVector<User *, 8> WorkList;
  SmallPtrSet<User *, 8> Visited;
  for (User *U : LPad->users())
    WorkList.push_back(U);

  while (!WorkList.empty()) {
    User *Curr = WorkList.pop_back_val();
    if (!Visited.insert(Curr).second) continue;

    // If we find a PHI-node user, add it to UnwindPHIs
    if (PHINode *PN = dyn_cast<PHINode>(Curr))
      UnwindPHIs.insert(PN->getParent());

    // Queue the successors for processing
    for (User *U : Curr->users())
      WorkList.push_back(U);
  }
}

/// Return the taskframe used in the given detached block.
Value *llvm::getTaskFrameUsed(BasicBlock *Detached) {
  // Scan the detached block for a taskframe.use intrinsic.  If we find one,
  // return its argument.
  for (const Instruction &I : *Detached)
    if (const IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I))
      if (Intrinsic::taskframe_use == II->getIntrinsicID())
        return II->getArgOperand(0);
  return nullptr;
}

// Helper function to check if the given taskframe.create instruction requires
// the parent basic block to be split in order to canonicalize the
// representation of taskframes.
static bool needToSplitTaskFrameCreate(const Instruction *TFCreate) {
  // If the taskframe.create is not the first instruction, split.
  if (TFCreate != &TFCreate->getParent()->front())
    return true;

  // The taskframe.create is at the front of the block.  Check that we have a
  // single predecessor.
  const BasicBlock *Pred = TFCreate->getParent()->getSinglePredecessor();
  if (!Pred)
    return true;

  // Check that the single predecessor has a single successor.
  if (!Pred->getSingleSuccessor())
    return true;

  // Check whether the single predecessor is terminated with a sync.
  if (isa<SyncInst>(Pred->getTerminator()))
    return true;

  return false;
}

// Helper function to check if the given taskframe.end instruction requires the
// parent basic block to be split in order to canonicalize the representation of
// taskframes.
static bool needToSplitTaskFrameEnd(const Instruction *TFEnd) {
  const BasicBlock *B = TFEnd->getParent();
  // If the taskframe.end is not the penultimate instruction, split.
  if (TFEnd != B->getTerminator()->getPrevNode())
    return true;

  // Check whether the parent block has a single successor.
  const BasicBlock *Succ = B->getSingleSuccessor();
  if (!Succ)
    return true;

  // Check that the single successor has a single predecessor.
  if (!Succ->getSinglePredecessor())
    return true;

  // Check that the single successor is not a taskframe.create entry.
  if (isTapirIntrinsic(Intrinsic::taskframe_create, &Succ->front()))
    return true;

  // Check whether the parent block is terminated with a sync or a reattach.
  if (isa<SyncInst>(B->getTerminator()) ||
      isa<ReattachInst>(B->getTerminator()))
    return true;

  return false;
}

/// Split blocks in function F containing taskframe.create calls to canonicalize
/// the representation of Tapir taskframes in F.
bool llvm::splitTaskFrameCreateBlocks(Function &F, DominatorTree *DT,
                                      TaskInfo *TI) {
  if (F.empty() || (TI && TI->isSerial()))
    return false;

  // Scan the function for taskframe.create instructions to split.
  SmallVector<Instruction *, 32> TFCreateToSplit;
  SmallVector<DetachInst *, 8> DetachesWithTaskFrames;
  SmallVector<Instruction *, 8> TFEndToSplit;
  SmallVector<BasicBlock *, 8> WorkList;
  SmallPtrSet<BasicBlock *, 32> Visited;
  WorkList.push_back(&F.getEntryBlock());
  while (!WorkList.empty()) {
    BasicBlock *BB = WorkList.pop_back_val();
    if (!Visited.insert(BB).second)
      continue;

    // Scan the instructions in BB for taskframe.create intrinsics.
    for (Instruction &I : *BB) {
      if (IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I)) {
        if (Intrinsic::taskframe_create == II->getIntrinsicID()) {
          // Record this taskframe.create for splitting.
          LLVM_DEBUG(dbgs() << "Pushing TFCreate " << *II << "\n");
          TFCreateToSplit.push_back(II);

          // Look for a detach instructions and taskframe.end intrinsics that
          // use this taskframe.
          for (User *U : II->users()) {
            if (IntrinsicInst *UI = dyn_cast<IntrinsicInst>(U)) {
              if (Intrinsic::taskframe_use == UI->getIntrinsicID()) {
                if (BasicBlock *Pred = UI->getParent()->getSinglePredecessor())
                  if (DetachInst *DI =
                      dyn_cast<DetachInst>(Pred->getTerminator())) {
                    // Record this detach as using a taskframe.
                    DetachesWithTaskFrames.push_back(DI);
                    break;
                  }
              } else if (Intrinsic::taskframe_end == UI->getIntrinsicID()) {
                // Record this taskframe.end.
                TFEndToSplit.push_back(UI);
                break;
              }
            }
          }
        }
      }
    }

    // Add all successors of BB
    for (BasicBlock *Succ : successors(BB))
      WorkList.push_back(Succ);
  }

  bool Changed = false;
  // Split the basic blocks containing taskframe.create calls so that the
  // taskframe.create call starts the basic block.
  for (Instruction *I : TFCreateToSplit)
    if (needToSplitTaskFrameCreate(I)) {
      LLVM_DEBUG(dbgs() << "Splitting at " << *I << "\n");
      SplitBlock(I->getParent(), I, DT);
      Changed = true;
    }

  // Split basic blocks containing taskframe.end calls, so that they end with an
  // unconditional branch immediately after the taskframe.end call.
  for (Instruction *TFEnd : TFEndToSplit)
    if (needToSplitTaskFrameEnd(TFEnd)) {
      LLVM_DEBUG(dbgs() << "Splitting block after " << *TFEnd << "\n");
      BasicBlock::iterator Iter = ++TFEnd->getIterator();
      SplitBlock(TFEnd->getParent(), &*Iter, DT);
      Changed = true;
    }

  // Also split critical continue edges, if we need to.  For example, we need to
  // split critical continue edges if we're planning to fixup external uses of
  // variables defined in a taskframe.
  //
  // TODO: Predicate this canonicalization on something more intuitive than the
  // existence of DT.
  for (DetachInst *DI : DetachesWithTaskFrames) {
    if (DT && isCriticalContinueEdge(DI, 1)) {
      SplitCriticalEdge(
          DI, 1,
          CriticalEdgeSplittingOptions(DT, nullptr).setSplitDetachContinue());
      Changed = true;
    }
  }

  // Recalculate TaskInfo if necessary.
  if (Changed && DT && TI)
    TI->recalculate(F, *DT);

  return Changed;
}

/// taskFrameContains - Returns true if the given basic block \p B is contained
/// within the taskframe \p TF.
bool llvm::taskFrameContains(const Spindle *TF, const BasicBlock *B,
                             const TaskInfo &TI) {
  if (TF->getTaskFrameCreate()) {
    if (TF->taskFrameContains(TI.getSpindleFor(B)))
      return true;
  } else {
    // If TF is a task entry, check that that task encloses I's basic block.
    return TF->getParentTask()->encloses(B);
  }
  return false;
}

/// taskFrameEncloses - Returns true if the given basic block \p B is enclosed
/// within the taskframe \p TF.
bool llvm::taskFrameEncloses(const Spindle *TF, const BasicBlock *B,
                             const TaskInfo &TI) {
  if (taskFrameContains(TF, B, TI))
    return true;

  if (!TF->getTaskFrameCreate())
    return false;

  // TF is a taskframe.create spindle.  Recursively check its subtaskframes.
  for (const Spindle *SubTF : TF->subtaskframes())
    if (taskFrameEncloses(SubTF, B, TI))
      return true;

  return false;
}

/// fixupTaskFrameExternalUses - Fix any uses of variables defined in
/// taskframes, but outside of tasks themselves.  For each such variable, insert
/// a memory allocation in the parent frame, add a store to that memory in the
/// taskframe, and modify external uses to use the value in that memory loaded
/// at the tasks continuation.
void llvm::fixupTaskFrameExternalUses(Spindle *TF, const TaskInfo &TI,
                                      const DominatorTree &DT) {
  Value *TaskFrame = TF->getTaskFrameCreate();
  if (!TaskFrame)
    // Nothing to do for taskframe spindles that are actually task entries.
    return;
  Task *T = TF->getTaskFrameUser();

  LLVM_DEBUG(dbgs() << "fixupTaskFrameExternalUses: spindle@"
             << TF->getEntry()->getName() << "\n");
  LLVM_DEBUG({
      if (T)
        dbgs() << "  used by task@" << T->getEntry()->getName() << "\n";
    });

  // Get the set of basic blocks in the taskframe spindles.  At the same time,
  // find the continuation of corresponding taskframe.resume intrinsics.

  SmallPtrSet<BasicBlock *, 1> BlocksToCheck;
  BasicBlock *TFResumeContin = nullptr;
  for (Spindle *S : TF->taskframe_spindles()) {
    // Skip taskframe spindles within the task itself.
    if (T && T->contains(S))
      continue;
    for (BasicBlock *BB : S->blocks()) {
      BlocksToCheck.insert(BB);
      if (isTaskFrameResume(BB->getTerminator(), TaskFrame)) {
        InvokeInst *TFResume = cast<InvokeInst>(BB->getTerminator());
        assert((nullptr == TFResumeContin) ||
               (TFResumeContin == TFResume->getUnwindDest()) &&
               "Multiple taskframe.resume destinations found");
        TFResumeContin = TFResume->getUnwindDest();
      }
    }
  }

  BasicBlock *Continuation = TF->getTaskFrameContinuation();

  MapVector<Instruction *, SmallVector<Use *, 16>> ToRewrite;
  MapVector<Value *, SmallVector<Instruction *, 8>> SyncRegionsToLocalize;
  // Find instructions in the taskframe that are used outside of the taskframe.
  for (BasicBlock *BB : BlocksToCheck) {
    for (Instruction &I : *BB) {
      // Ignore certain instructions from consideration: the taskframe.create
      // intrinsic for this taskframe, the detach instruction that spawns T, and
      // the landingpad value in T's EH continuation.
      if (T && ((T->getTaskFrameUsed() == &I) || (T->getDetach() == &I) ||
                (T->getLPadValueInEHContinuationSpindle() == &I)))
        continue;

      // Examine all users of this instruction.
      for (Use &U : I.uses()) {
        // If we find a live use outside of the task, it's an output.
        if (Instruction *UI = dyn_cast<Instruction>(U.getUser())) {
          if (!taskFrameEncloses(TF, UI->getParent(), TI)) {
            LLVM_DEBUG(dbgs() << "  ToRewrite: " << I << " (user " << *UI
                       << ")\n");
            ToRewrite[&I].push_back(&U);
          }
        }
      }
    }
    // Collect any syncregions used in this taskframe that are defined outside.
    if (!T) {
      if (DetachInst *DI = dyn_cast<DetachInst>(BB->getTerminator()))
        if (!taskFrameContains(
                TF, cast<Instruction>(DI->getSyncRegion())->getParent(), TI)) {
          LLVM_DEBUG(dbgs() << "  Sync region to localize: "
                     << *DI->getSyncRegion() << "(user " << *DI << ")\n");
          // Only record the detach.  We can find associated reattaches and
          // detached-rethrows later.
          SyncRegionsToLocalize[DI->getSyncRegion()].push_back(DI);
        }

      if (SyncInst *SI = dyn_cast<SyncInst>(BB->getTerminator()))
        if (!taskFrameContains(
                TF, cast<Instruction>(SI->getSyncRegion())->getParent(), TI)) {
          LLVM_DEBUG(dbgs() << "  Sync region to localize: "
                     << *SI->getSyncRegion() << "(user " << *SI << ")\n");
          SyncRegionsToLocalize[SI->getSyncRegion()].push_back(SI);
        }
    }
  }

  Module *M = TF->getEntry()->getModule();

  // Localize any syncregions used in this taskframe.
  for (auto &SRUsed : SyncRegionsToLocalize) {
    Value *ReplSR = CallInst::Create(
        Intrinsic::getDeclaration(M, Intrinsic::syncregion_start),
        SRUsed.first->getName(), cast<Instruction>(TaskFrame)->getNextNode());
    for (Instruction *UseToRewrite : SRUsed.second) {
      // Replace the syncregion of each sync.
      if (SyncInst *SI = dyn_cast<SyncInst>(UseToRewrite)) {
        SI->setSyncRegion(ReplSR);
        // Replace the syncregion of each sync.unwind.
        if (CallBase *CB = dyn_cast<CallBase>(
                SI->getSuccessor(0)->getFirstNonPHIOrDbgOrLifetime()))
          if (isSyncUnwind(CB, SRUsed.first))
            CB->setArgOperand(0, ReplSR);
      } else if (DetachInst *DI = dyn_cast<DetachInst>(UseToRewrite)) {
        // Replace the syncregion of each detach.
        DI->setSyncRegion(ReplSR);
        Task *SubT = TI.getTaskFor(DI->getDetached());
        // Replace the syncregion of corresponding reattach instructions.
        for (BasicBlock *Pred : predecessors(DI->getContinue()))
          if (ReattachInst *RI = dyn_cast<ReattachInst>(Pred->getTerminator()))
            if (SubT->encloses(Pred))
              RI->setSyncRegion(ReplSR);

        // Replace the syncregion of corresponding detached.rethrows.
        for (User *U : SRUsed.first->users())
          if (InvokeInst *II = dyn_cast<InvokeInst>(U))
            if (isDetachedRethrow(II) && SubT->encloses(II->getParent()))
              II->setArgOperand(0, ReplSR);
      }
    }
  }

  // Rewrite any uses of values defined in the taskframe that are used outside.
  for (auto &TFInstr : ToRewrite) {
    LLVM_DEBUG(dbgs() << "Fixing taskframe output " << *TFInstr.first << "\n");
    // Create an allocation to store the result of the instruction.
    BasicBlock *ParentEntry;
    if (Spindle *ParentTF = TF->getTaskFrameParent())
      ParentEntry = ParentTF->getEntry();
    else
      ParentEntry = TF->getParentTask()->getEntry();
    IRBuilder<> Builder(&*ParentEntry->getFirstInsertionPt());
    AllocaInst *AI = Builder.CreateAlloca(TFInstr.first->getType());
    AI->setName(TFInstr.first->getName());

    // Store the result of the instruction into that alloca.
    if (isa<PHINode>(TFInstr.first))
      Builder.SetInsertPoint(
          &*TFInstr.first->getParent()->getFirstInsertionPt());
    else
      Builder.SetInsertPoint(&*(++TFInstr.first->getIterator()));
    Builder.CreateStore(TFInstr.first, AI);

    // Load the result of the instruction at the continuation.
    Builder.SetInsertPoint(&*Continuation->getFirstInsertionPt());
    Builder.CreateCall(
        Intrinsic::getDeclaration(M, Intrinsic::taskframe_load_guard,
                                  { AI->getType() }), { AI });
    LoadInst *ContinVal = Builder.CreateLoad(AI);
    LoadInst *EHContinVal = nullptr;

    // For each external use, replace the use with a load from the alloca.
    for (Use *UseToRewrite : TFInstr.second) {
      Instruction *User = cast<Instruction>(UseToRewrite->getUser());
      BasicBlock *UserBB = User->getParent();
      if (auto *PN = dyn_cast<PHINode>(User))
        UserBB = PN->getIncomingBlock(*UseToRewrite);

      if (!DT.dominates(Continuation, UserBB)) {
        assert(DT.dominates(TFResumeContin, UserBB) &&
               "Use not dominated by continuation or taskframe.resume");
        // If necessary, load the value at the taskframe.resume continuation.
        if (!EHContinVal) {
          Builder.SetInsertPoint(&*(TFResumeContin->getFirstInsertionPt()));
          Builder.CreateCall(
              Intrinsic::getDeclaration(M, Intrinsic::taskframe_load_guard,
                                        { AI->getType() }), { AI });
          EHContinVal = Builder.CreateLoad(AI);
        }

        // Rewrite to use the value loaded at the taskframe.resume continuation.
        if (UseToRewrite->get()->hasValueHandle())
          ValueHandleBase::ValueIsRAUWd(*UseToRewrite, EHContinVal);
        UseToRewrite->set(EHContinVal);
        continue;
      }

      // Rewrite to use the value loaded at the continuation.
      if (UseToRewrite->get()->hasValueHandle())
        ValueHandleBase::ValueIsRAUWd(*UseToRewrite, ContinVal);
      UseToRewrite->set(ContinVal);
    }
  }
}

// Helper method to find a taskframe.create intrinsic in the given basic block.
Instruction *llvm::FindTaskFrameCreateInBlock(BasicBlock *BB) {
  for (BasicBlock::iterator BBI = BB->begin(), E = BB->end(); BBI != E; ) {
    Instruction *I = &*BBI++;

    // Check if this instruction is a call to taskframe_create.
    if (CallInst *CI = dyn_cast<CallInst>(I))
      if (isTapirIntrinsic(Intrinsic::taskframe_create, I))
        return CI;
  }
  return nullptr;
}

// Helper method to create an unwind edge for a nested taskframe or spawned
// task.  This unwind edge is a new basic block terminated by an appropriate
// terminator, i.e., a taskframe.resume or detached.rethrow intrinsic.
BasicBlock *llvm::CreateSubTaskUnwindEdge(Intrinsic::ID TermFunc, Value *Token,
                                          BasicBlock *UnwindEdge,
                                          BasicBlock *Unreachable) {
  Function *Caller = UnwindEdge->getParent();
  Module *M = Caller->getParent();
  LandingPadInst *OldLPad = UnwindEdge->getLandingPadInst();

  // Create a new unwind edge for the detached rethrow.
  BasicBlock *NewUnwindEdge = BasicBlock::Create(
      Caller->getContext(), UnwindEdge->getName(), Caller);
  IRBuilder<> Builder(NewUnwindEdge);

  // Add a landingpad to the new unwind edge.
  LandingPadInst *LPad = Builder.CreateLandingPad(OldLPad->getType(), 0,
                                                  OldLPad->getName());
  LPad->setCleanup(true);

  // Add the terminator-function invocation.
  Builder.CreateInvoke(Intrinsic::getDeclaration(M, TermFunc,
                                                 { LPad->getType() }),
                       Unreachable, UnwindEdge, { Token, LPad });

  return NewUnwindEdge;
}

static BasicBlock *MaybePromoteCallInBlock(BasicBlock *BB,
                                           BasicBlock *UnwindEdge) {
  for (BasicBlock::iterator BBI = BB->begin(), E = BB->end(); BBI != E; ) {
    Instruction *I = &*BBI++;

    // We only need to check for function calls: inlined invoke
    // instructions require no special handling.
    CallInst *CI = dyn_cast<CallInst>(I);

    if (!CI || CI->doesNotThrow() || isa<InlineAsm>(CI->getCalledValue()))
      continue;

    // We do not need to (and in fact, cannot) convert possibly throwing calls
    // to @llvm.experimental_deoptimize (resp. @llvm.experimental.guard) into
    // invokes.  The caller's "segment" of the deoptimization continuation
    // attached to the newly inlined @llvm.experimental_deoptimize
    // (resp. @llvm.experimental.guard) call should contain the exception
    // handling logic, if any.
    if (auto *F = CI->getCalledFunction())
      if (F->getIntrinsicID() == Intrinsic::experimental_deoptimize ||
          F->getIntrinsicID() == Intrinsic::experimental_guard)
        continue;

    changeToInvokeAndSplitBasicBlock(CI, UnwindEdge);
    return BB;
  }
  return nullptr;
}

// Recursively handle inlined tasks.
static void PromoteCallsInTasksHelper(
    BasicBlock *EntryBlock, BasicBlock *UnwindEdge,
    BasicBlock *Unreachable, Value *CurrentTaskFrame,
    SmallVectorImpl<BasicBlock *> *ParentWorklist) {
  SmallVector<DetachInst *, 8> DetachesToReplace;
  SmallVector<BasicBlock *, 32> Worklist;
  // TODO: See if we need a global Visited set over all recursive calls, i.e.,
  // to handle shared exception-handling blocks.
  SmallPtrSet<BasicBlock *, 32> Visited;
  Worklist.push_back(EntryBlock);
  do {
    BasicBlock *BB = Worklist.pop_back_val();
    // Skip blocks we've seen before
    if (!Visited.insert(BB).second)
      continue;

    if (Instruction *TFCreate = FindTaskFrameCreateInBlock(BB)) {
      if (TFCreate != CurrentTaskFrame) {
        // Split the block at the taskframe.create, if necessary.
        BasicBlock *NewBB;
        if (TFCreate != &BB->front())
          NewBB = SplitBlock(BB, TFCreate);
        else
          NewBB = BB;

        // Create an unwind edge for the taskframe.
        BasicBlock *TaskFrameUnwindEdge = CreateSubTaskUnwindEdge(
            Intrinsic::taskframe_resume, TFCreate, UnwindEdge,
            Unreachable);

        // Recursively check all blocks
        PromoteCallsInTasksHelper(NewBB, TaskFrameUnwindEdge, Unreachable,
                                  TFCreate, &Worklist);

        // Remove the unwind edge for the taskframe if it is not needed.
        if (pred_empty(TaskFrameUnwindEdge))
          TaskFrameUnwindEdge->eraseFromParent();
        continue;
      }
    }

    // Promote any calls in the block to invokes.
    while (BasicBlock *NewBB = MaybePromoteCallInBlock(BB, UnwindEdge)) {
      BB = cast<InvokeInst>(NewBB->getTerminator())->getNormalDest();
    }

    // Ignore reattach terminators.
    if (isa<ReattachInst>(BB->getTerminator()) ||
        isDetachedRethrow(BB->getTerminator()))
      continue;

    // If we find a taskframe.end, add its successor to the parent search.
    if (endsTaskFrame(BB, CurrentTaskFrame)) {
      assert(ParentWorklist &&
             "Unexpected taskframe.resume: no parent worklist");
      ParentWorklist->push_back(BB->getSingleSuccessor());
      continue;
    }

    // If we find a taskframe.resume terminator, add its successor to the
    // parent search.
    if (isTaskFrameResume(BB->getTerminator())) {
      assert(isTaskFrameResume(UnwindEdge->getTerminator()) &&
             "Unexpected taskframe.resume, doesn't correspond to unwind edge");
      InvokeInst *II = cast<InvokeInst>(BB->getTerminator());
      assert(ParentWorklist &&
             "Unexpected taskframe.resume: no parent worklist");
      ParentWorklist->push_back(II->getUnwindDest());
      continue;
    }

    // Process a detach instruction specially.  In particular, process th
    // spawned task recursively.
    if (DetachInst *DI = dyn_cast<DetachInst>(BB->getTerminator())) {
      if (!DI->hasUnwindDest()) {
        // Create an unwind edge for the subtask, which is terminated with a
        // detached-rethrow.
        BasicBlock *SubTaskUnwindEdge = CreateSubTaskUnwindEdge(
            Intrinsic::detached_rethrow, DI->getSyncRegion(), UnwindEdge,
            Unreachable);
        // Recursively check all blocks in the detached task.
        PromoteCallsInTasksHelper(DI->getDetached(), SubTaskUnwindEdge,
                                  Unreachable, CurrentTaskFrame, &Worklist);
        // If the new unwind edge is not used, remove it.
        if (pred_empty(SubTaskUnwindEdge))
          SubTaskUnwindEdge->eraseFromParent();
        else
          DetachesToReplace.push_back(DI);

      } else {
        PromoteCallsInTasksHelper(DI->getDetached(), DI->getUnwindDest(),
                                  Unreachable, CurrentTaskFrame, &Worklist);

        if (Visited.insert(DI->getUnwindDest()).second)
          // If the detach-unwind isn't dead, add it to the worklist.
          Worklist.push_back(DI->getUnwindDest());
      }
      // Add the continuation to the worklist.
      if (isTaskFrameResume(UnwindEdge->getTerminator()) &&
          (CurrentTaskFrame == getTaskFrameUsed(DI->getDetached()))) {
        // This detach-continuation terminates the current taskframe, so push it
        // onto the parent worklist.
        assert(ParentWorklist && "Unexpected taskframe unwind edge");
        ParentWorklist->push_back(DI->getContinue());
      } else {
        // We can process this detach-continuation directly, because it does not
        // terminate the current taskframe.
        Worklist.push_back(DI->getContinue());
      }
      continue;
    }

    // In the normal case, add all successors of BB to the worklist.
    for (BasicBlock *Successor : successors(BB))
      Worklist.push_back(Successor);

  } while (!Worklist.empty());

  // Replace detaches that now require unwind destinations.
  while (!DetachesToReplace.empty()) {
    DetachInst *DI = DetachesToReplace.pop_back_val();
    ReplaceInstWithInst(DI, DetachInst::Create(
                            DI->getDetached(), DI->getContinue(), UnwindEdge,
                            DI->getSyncRegion()));
  }
}

static FunctionCallee getDefaultPersonalityFn(Module *M) {
  LLVMContext &C = M->getContext();
  Triple T(M->getTargetTriple());
  EHPersonality Pers = getDefaultEHPersonality(T);
  return M->getOrInsertFunction(getEHPersonalityName(Pers),
                                FunctionType::get(Type::getInt32Ty(C), true));
}

void llvm::promoteCallsInTasksToInvokes(Function &F, const Twine Name) {
  // Create a cleanup block.
  LLVMContext &C = F.getContext();
  BasicBlock *CleanupBB = BasicBlock::Create(C, Name, &F);
  Type *ExnTy = StructType::get(Type::getInt8PtrTy(C), Type::getInt32Ty(C));

  LandingPadInst *LPad =
      LandingPadInst::Create(ExnTy, 1, Name+".lpad", CleanupBB);
  LPad->setCleanup(true);
  ResumeInst::Create(LPad, CleanupBB);

  // Create the normal return for the task resumes.
  BasicBlock *UnreachableBlk = BasicBlock::Create(C, Name+".unreachable", &F);

  // Recursively handle inlined tasks.
  PromoteCallsInTasksHelper(&F.getEntryBlock(), CleanupBB, UnreachableBlk,
                            nullptr, nullptr);

  // Either finish inserting the cleanup block (and associated data) or remove
  // it, depending on whether it is used.
  if (!pred_empty(CleanupBB)) {
    if (!F.hasPersonalityFn()) {
      FunctionCallee PersFn = getDefaultPersonalityFn(F.getParent());
      F.setPersonalityFn(cast<Constant>(PersFn.getCallee()));
    }
  } else {
    CleanupBB->eraseFromParent();
  }

  // Either finish the unreachable block or remove it, depending on whether it
  // is used.
  if (!pred_empty(UnreachableBlk)) {
    IRBuilder<> Builder(UnreachableBlk);
    Builder.CreateUnreachable();
  } else {
    UnreachableBlk->eraseFromParent();
  }
}

/// Find hints specified in the loop metadata and update local values.
void llvm::TapirLoopHints::getHintsFromMetadata() {
  MDNode *LoopID = TheLoop->getLoopID();
  if (!LoopID)
    return;

  // First operand should refer to the loop id itself.
  assert(LoopID->getNumOperands() > 0 && "requires at least one operand");
  assert(LoopID->getOperand(0) == LoopID && "invalid loop id");

  for (unsigned i = 1, ie = LoopID->getNumOperands(); i < ie; ++i) {
    const MDString *S = nullptr;
    SmallVector<Metadata *, 4> Args;

    // The expected hint is either a MDString or a MDNode with the first
    // operand a MDString.
    if (const MDNode *MD = dyn_cast<MDNode>(LoopID->getOperand(i))) {
      if (!MD || MD->getNumOperands() == 0)
        continue;
      S = dyn_cast<MDString>(MD->getOperand(0));
      for (unsigned i = 1, ie = MD->getNumOperands(); i < ie; ++i)
        Args.push_back(MD->getOperand(i));
    } else {
      S = dyn_cast<MDString>(LoopID->getOperand(i));
      assert(Args.size() == 0 && "too many arguments for MDString");
    }

    if (!S)
      continue;

    // Check if the hint starts with the loop metadata prefix.
    StringRef Name = S->getString();
    if (Args.size() == 1)
      setHint(Name, Args[0]);
  }
}

/// Checks string hint with one operand and set value if valid.
void llvm::TapirLoopHints::setHint(StringRef Name, Metadata *Arg) {
  if (!Name.startswith(Prefix()))
    return;
  Name = Name.substr(Prefix().size(), StringRef::npos);

  const ConstantInt *C = mdconst::dyn_extract<ConstantInt>(Arg);
  if (!C)
    return;
  unsigned Val = C->getZExtValue();

  Hint *Hints[] = {&Strategy, &Grainsize};
  for (auto H : Hints) {
    if (Name == H->Name) {
      if (H->validate(Val))
        H->Value = Val;
      else
        LLVM_DEBUG(dbgs() << "Tapir: ignoring invalid hint '" <<
                   Name << "'\n");
      break;
    }
  }
}

/// Create a new hint from name / value pair.
MDNode *llvm::TapirLoopHints::createHintMetadata(
    StringRef Name, unsigned V) const {
  LLVMContext &Context = TheLoop->getHeader()->getContext();
  Metadata *MDs[] = {MDString::get(Context, Name),
                     ConstantAsMetadata::get(
                         ConstantInt::get(Type::getInt32Ty(Context), V))};
  return MDNode::get(Context, MDs);
}

/// Matches metadata with hint name.
bool llvm::TapirLoopHints::matchesHintMetadataName(
    MDNode *Node, ArrayRef<Hint> HintTypes) const {
  MDString *Name = dyn_cast<MDString>(Node->getOperand(0));
  if (!Name)
    return false;

  for (auto H : HintTypes)
    if (Name->getString().endswith(H.Name))
      return true;
  return false;
}

/// Sets current hints into loop metadata, keeping other values intact.
void llvm::TapirLoopHints::writeHintsToMetadata(ArrayRef<Hint> HintTypes) {
  if (HintTypes.size() == 0)
    return;

  LLVMContext &Context = TheLoop->getHeader()->getContext();
  SmallVector<Metadata *, 4> MDs;

  // Reserve first location for self reference to the LoopID metadata node.
  TempMDTuple TempNode = MDNode::getTemporary(Context, None);
  MDs.push_back(TempNode.get());

  // If the loop already has metadata, then ignore the existing operands.
  MDNode *LoopID = TheLoop->getLoopID();
  if (LoopID) {
    for (unsigned i = 1, ie = LoopID->getNumOperands(); i < ie; ++i) {
      MDNode *Node = cast<MDNode>(LoopID->getOperand(i));
      // If node in update list, ignore old value.
      if (!matchesHintMetadataName(Node, HintTypes))
        MDs.push_back(Node);
    }
  }

  // Now, add the missing hints.
  for (auto H : HintTypes)
    MDs.push_back(createHintMetadata(Twine(Prefix(), H.Name).str(), H.Value));

  // Replace current metadata node with new one.
  MDNode *NewLoopID = MDNode::get(Context, MDs);
  // Set operand 0 to refer to the loop id itself.
  NewLoopID->replaceOperandWith(0, NewLoopID);

  TheLoop->setLoopID(NewLoopID);
}

/// Sets current hints into loop metadata, keeping other values intact.
void llvm::TapirLoopHints::writeHintsToClonedMetadata(ArrayRef<Hint> HintTypes,
                                                      ValueToValueMapTy &VMap) {
  if (HintTypes.size() == 0)
    return;

  LLVMContext &Context =
    cast<BasicBlock>(VMap[TheLoop->getHeader()])->getContext();
  SmallVector<Metadata *, 4> MDs;

  // Reserve first location for self reference to the LoopID metadata node.
  TempMDTuple TempNode = MDNode::getTemporary(Context, None);
  MDs.push_back(TempNode.get());

  // If the loop already has metadata, then ignore the existing operands.
  MDNode *OrigLoopID = TheLoop->getLoopID();
  if (!OrigLoopID)
    return;

  if (MDNode *LoopID = dyn_cast_or_null<MDNode>(VMap.MD()[OrigLoopID])) {
    for (unsigned i = 1, ie = LoopID->getNumOperands(); i < ie; ++i) {
      MDNode *Node = cast<MDNode>(LoopID->getOperand(i));
      // If node in update list, ignore old value.
      if (!matchesHintMetadataName(Node, HintTypes))
        MDs.push_back(Node);
    }
  }

  // Now, add the missing hints.
  for (auto H : HintTypes)
    MDs.push_back(createHintMetadata(Twine(Prefix(), H.Name).str(), H.Value));

  // Replace current metadata node with new one.
  MDNode *NewLoopID = MDNode::get(Context, MDs);
  // Set operand 0 to refer to the loop id itself.
  NewLoopID->replaceOperandWith(0, NewLoopID);

  // Set the metadata on the terminator of the cloned loop's latch.
  BasicBlock *ClonedLatch = cast<BasicBlock>(VMap[TheLoop->getLoopLatch()]);
  assert(ClonedLatch && "Cloned Tapir loop does not have a single latch.");
  ClonedLatch->getTerminator()->setMetadata(LLVMContext::MD_loop, NewLoopID);
}

/// Sets current hints into loop metadata, keeping other values intact.
void llvm::TapirLoopHints::clearHintsMetadata() {
  Hint Hints[] = {Hint("spawn.strategy", ST_SEQ, HK_STRATEGY),
                  Hint("grainsize", 0, HK_GRAINSIZE)};
  LLVMContext &Context = TheLoop->getHeader()->getContext();
  SmallVector<Metadata *, 4> MDs;

  // Reserve first location for self reference to the LoopID metadata node.
  TempMDTuple TempNode = MDNode::getTemporary(Context, None);
  MDs.push_back(TempNode.get());

  // If the loop already has metadata, then ignore the existing operands.
  MDNode *LoopID = TheLoop->getLoopID();
  if (LoopID) {
    for (unsigned i = 1, ie = LoopID->getNumOperands(); i < ie; ++i) {
      MDNode *Node = cast<MDNode>(LoopID->getOperand(i));
      // If node in update list, ignore old value.
      if (!matchesHintMetadataName(Node, Hints))
        MDs.push_back(Node);
    }
  }

  // Replace current metadata node with new one.
  MDNode *NewLoopID = MDNode::get(Context, MDs);
  // Set operand 0 to refer to the loop id itself.
  NewLoopID->replaceOperandWith(0, NewLoopID);

  TheLoop->setLoopID(NewLoopID);
}

/// Returns true if Tapir-loop hints require loop outlining during lowering.
bool llvm::hintsDemandOutlining(const TapirLoopHints &Hints) {
  switch (Hints.getStrategy()) {
  case TapirLoopHints::ST_DAC: return true;
  default: return false;
  }
}

/// Given an loop id metadata node, returns the loop hint metadata node with the
/// given name (for example, "tapir.loop.stripmine.count"). If no such metadata
/// node exists, then nullptr is returned.
MDNode *llvm::GetStripMineMetadata(MDNode *LoopID, StringRef Name) {
  // First operand should refer to the loop id itself.
  assert(LoopID->getNumOperands() > 0 && "requires at least one operand");
  assert(LoopID->getOperand(0) == LoopID && "invalid loop id");

  for (unsigned i = 1, e = LoopID->getNumOperands(); i < e; ++i) {
    MDNode *MD = dyn_cast<MDNode>(LoopID->getOperand(i));
    if (!MD)
      continue;

    MDString *S = dyn_cast<MDString>(MD->getOperand(0));
    if (!S)
      continue;

    if (Name.equals(S->getString()))
      return MD;
  }
  return nullptr;
}

/// Examine a given loop to determine if it is a Tapir loop.  Returns the Task
/// that encodes the loop body if so, or nullptr if not.
Task *llvm::getTaskIfTapirLoop(const Loop *L, TaskInfo *TI) {
  if (!L || !TI)
    return nullptr;

  TapirLoopHints Hints(L);

  LLVM_DEBUG(dbgs() << "Loop hints:"
             << " strategy = " << Hints.printStrategy(Hints.getStrategy())
             << " grainsize = " << Hints.getGrainsize()
             << "\n");

  // Check that this loop has the structure of a Tapir loop.
  Task *T = getTaskIfTapirLoopStructure(L, TI);
  if (!T)
    return nullptr;

  // Check that the loop hints require this loop to be outlined.
  if (!hintsDemandOutlining(Hints))
    return nullptr;

  return T;
}
