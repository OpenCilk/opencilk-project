//===- TapirLoopInfo.cpp - Utility functions for Tapir loops --------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements utility functions for handling Tapir loops.
//
// Many of these routines are adapted from
// Transforms/Vectorize/LoopVectorize.cpp.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Tapir/TapirLoopInfo.h"
#include "llvm/Analysis/OptimizationRemarkEmitter.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ScalarEvolutionExpander.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "tapir"

/// Create an analysis remark that explains why the transformation failed
///
/// \p RemarkName is the identifier for the remark.  If \p I is passed it is an
/// instruction that prevents the transformation.  Otherwise \p TheLoop is used
/// for the location of the remark.  \return the remark object that can be
/// streamed to.
///
/// Based on createMissedAnalysis in the LoopVectorize pass.
OptimizationRemarkAnalysis
TapirLoopInfo::createMissedAnalysis(const char *PassName, StringRef RemarkName,
                                    const Loop *TheLoop, Instruction *I) {
  const Value *CodeRegion = TheLoop->getHeader();
  DebugLoc DL = TheLoop->getStartLoc();

  if (I) {
    CodeRegion = I->getParent();
    // If there is no debug location attached to the instruction, revert back to
    // using the loop's.
    if (I->getDebugLoc())
      DL = I->getDebugLoc();
  }

  OptimizationRemarkAnalysis R(PassName, RemarkName, DL, CodeRegion);
  R << "Tapir loop not transformed: ";
  return R;
}

/// Update information on this Tapir loop based on its metadata.
void TapirLoopInfo::readTapirLoopMetadata(OptimizationRemarkEmitter &ORE) {
  TapirLoopHints Hints(getLoop());

  // Get a grainsize for this Tapir loop from the metadata, if the metadata
  // gives a grainsize.
  Grainsize = Hints.getGrainsize();
}

static Type *convertPointerToIntegerType(const DataLayout &DL, Type *Ty) {
  if (Ty->isPointerTy())
    return DL.getIntPtrType(Ty);

  // It is possible that char's or short's overflow when we ask for the loop's
  // trip count, work around this by changing the type size.
  if (Ty->getScalarSizeInBits() < 32)
    return Type::getInt32Ty(Ty->getContext());

  return Ty;
}

static Type *getWiderType(const DataLayout &DL, Type *Ty0, Type *Ty1) {
  Ty0 = convertPointerToIntegerType(DL, Ty0);
  Ty1 = convertPointerToIntegerType(DL, Ty1);
  if (Ty0->getScalarSizeInBits() > Ty1->getScalarSizeInBits())
    return Ty0;
  return Ty1;
}

/// Adds \p Phi, with induction descriptor ID, to the inductions list.  This can
/// set \p Phi as the main induction of the loop if \p Phi is a better choice
/// for the main induction than the existing one.
void TapirLoopInfo::addInductionPhi(PHINode *Phi,
                                    const InductionDescriptor &ID) {
  Inductions[Phi] = ID;

  Type *PhiTy = Phi->getType();
  const DataLayout &DL = Phi->getModule()->getDataLayout();

  // Int inductions are special because we only allow one IV.
  if (ID.getKind() == InductionDescriptor::IK_IntInduction &&
      ID.getConstIntStepValue() && ID.getConstIntStepValue()->isOne() &&
      isa<Constant>(ID.getStartValue()) &&
      cast<Constant>(ID.getStartValue())->isNullValue()) {

    // Get the widest type.
    if (!WidestIndTy)
      WidestIndTy = convertPointerToIntegerType(DL, PhiTy);
    else
      WidestIndTy = getWiderType(DL, PhiTy, WidestIndTy);

    // Use the phi node with the widest type as induction. Use the last
    // one if there are multiple (no good reason for doing this other
    // than it is expedient). We've checked that it begins at zero and
    // steps by one, so this is a canonical induction variable.
    if (!PrimaryInduction || PhiTy == WidestIndTy)
      PrimaryInduction = Phi;
  }

  // // Both the PHI node itself, and the "post-increment" value feeding
  // // back into the PHI node may have external users.
  // // We can allow those uses, except if the SCEVs we have for them rely
  // // on predicates that only hold within the loop, since allowing the exit
  // // currently means re-using this SCEV outside the loop.
  // if (PSE.getUnionPredicate().isAlwaysTrue()) {
  //   AllowedExit.insert(Phi);
  //   AllowedExit.insert(Phi->getIncomingValueForBlock(TheLoop->getLoopLatch()));
  // }

  LLVM_DEBUG(dbgs() << "TapirLoop: Found an induction variable: " << *Phi
             << "\n");
}

/// Gather all induction variables in this loop that need special handling
/// during outlining.
bool TapirLoopInfo::collectIVs(PredicatedScalarEvolution &PSE,
                               const char *PassName,
                               OptimizationRemarkEmitter *ORE) {
  Loop *L = getLoop();
  for (Instruction &I : *L->getHeader()) {
    if (auto *Phi = dyn_cast<PHINode>(&I)) {
      Type *PhiTy = Phi->getType();
      // Check that this PHI type is allowed.
      if (!PhiTy->isIntegerTy() && !PhiTy->isFloatingPointTy() &&
          !PhiTy->isPointerTy()) {
        if (ORE)
          ORE->emit(createMissedAnalysis(PassName, "CFGNotUnderstood", L, Phi)
                    << "loop control flow is not understood by loop spawning");
        LLVM_DEBUG(dbgs() << "TapirLoop: Found an non-int non-pointer PHI.\n");
        return false;
      }

      // We only allow if-converted PHIs with exactly two incoming values.
      if (Phi->getNumIncomingValues() != 2) {
        if (ORE)
          ORE->emit(createMissedAnalysis(PassName, "CFGNotUnderstood", L, Phi)
                    << "loop control flow is not understood by loop spawning");
        LLVM_DEBUG(dbgs() << "TapirLoop: Found an invalid PHI.\n");
        return false;
      }

      InductionDescriptor ID;
      if (InductionDescriptor::isInductionPHI(Phi, L, PSE, ID)) {
        LLVM_DEBUG(dbgs() << "\tFound induction PHI " << *Phi << "\n");
        addInductionPhi(Phi, ID);
        // if (ID.hasUnsafeAlgebra() && !HasFunNoNaNAttr)
        //   Requirements->addUnsafeAlgebraInst(ID.getUnsafeAlgebraInst());
        continue;
      }

      // As a last resort, coerce the PHI to a AddRec expression and re-try
      // classifying it a an induction PHI.
      if (InductionDescriptor::isInductionPHI(Phi, L, PSE, ID, true)) {
        LLVM_DEBUG(dbgs() << "\tCoerced induction PHI " << *Phi << "\n");
        addInductionPhi(Phi, ID);
        continue;
      }

      LLVM_DEBUG(dbgs() << "\tPassed PHI " << *Phi << "\n");
    } // end of PHI handling
  }

  if (!PrimaryInduction) {
    LLVM_DEBUG(dbgs()
               << "TapirLoop: Did not find a primary integer induction var.\n");
    if (ORE)
      ORE->emit(createMissedAnalysis(PassName, "NoInductionVariable", L)
                << "canonical loop induction variable could not be identified");
    if (Inductions.empty())
      return false;
  }

  // Now we know the widest induction type, check if our found induction is the
  // same size.
  //
  // TODO: Check if this code is dead due to IndVarSimplify.
  if (PrimaryInduction && WidestIndTy != PrimaryInduction->getType())
    PrimaryInduction = nullptr;

  return true;
}

/// Replace all induction variables in this loop that are not primary with
/// stronger forms.
void TapirLoopInfo::replaceNonPrimaryIVs(PredicatedScalarEvolution &PSE) {
  BasicBlock *Header = getLoop()->getHeader();
  IRBuilder<> B(&*Header->getFirstInsertionPt());
  const DataLayout &DL = Header->getModule()->getDataLayout();
  SmallVector<std::pair<PHINode *, InductionDescriptor>, 4> InductionsToRemove;

  // Replace all non-primary inductions with strengthened forms.
  for (auto &InductionEntry : Inductions) {
    PHINode *OrigPhi = InductionEntry.first;
    InductionDescriptor II = InductionEntry.second;
    if (OrigPhi == PrimaryInduction) continue;
    LLVM_DEBUG(dbgs() << "Replacing Phi " << *OrigPhi << "\n");
    // If Induction is not canonical, replace it with some computation based on
    // PrimaryInduction.
    Type *StepType = II.getStep()->getType();
    Instruction::CastOps CastOp =
      CastInst::getCastOpcode(PrimaryInduction, true, StepType, true);
    Value *CRD = B.CreateCast(CastOp, PrimaryInduction, StepType, "cast.crd");
    Value *PhiRepl = emitTransformedIndex(B, CRD, PSE.getSE(), DL, II);
    PhiRepl->setName(OrigPhi->getName() + ".tl.repl");
    OrigPhi->replaceAllUsesWith(PhiRepl);
    InductionsToRemove.push_back(InductionEntry);
  }

  // Remove all inductions that were replaced from Inductions.
  for (auto &InductionEntry : InductionsToRemove) {
    PHINode *OrigPhi = InductionEntry.first;
    OrigPhi->eraseFromParent();
    Inductions.erase(OrigPhi);
  }
}

bool TapirLoopInfo::getLoopCondition(const char *PassName,
                                     OptimizationRemarkEmitter *ORE) {
  Loop *L = getLoop();

  // Check that the latch is terminated by a branch instruction.  The
  // LoopRotate pass can be helpful to ensure this property.
  BranchInst *BI =
    dyn_cast<BranchInst>(L->getLoopLatch()->getTerminator());
  if (!BI || BI->isUnconditional()) {
    LLVM_DEBUG(dbgs()
               << "Loop-latch terminator is not a conditional branch.\n");
    if (ORE)
      ORE->emit(TapirLoopInfo::createMissedAnalysis(PassName, "NoLatchBranch",
                                                    L)
                << "loop latch is not terminated by a conditional branch");
    return false;
  }
  // Check that the condition is an integer-equality comparison.  The
  // IndVarSimplify pass should transform Tapir loops to use integer-equality
  // comparisons when the loop can be analyzed.
  {
    const ICmpInst *Cond = dyn_cast<ICmpInst>(BI->getCondition());
    if (!Cond) {
      LLVM_DEBUG(dbgs() <<
                 "Loop-latch condition is not an integer comparison.\n");
      if (ORE)
        ORE->emit(TapirLoopInfo::createMissedAnalysis(PassName, "NotIntCmp", L)
                  << "loop-latch condition is not an integer comparison");
      return false;
    }
    if (!Cond->isEquality()) {
      LLVM_DEBUG(dbgs() <<
                 "Loop-latch condition is not an equality comparison.\n");
      // TODO: Find a reasonable analysis message to give to users.
      // if (ORE)
      //   ORE->emit(TapirLoopInfo::createMissedAnalysis(PassName,
      //                                                 "NonCanonicalCmp", L)
      //             << "non-canonical loop-latch condition");
      return false;
    }
  }
  Condition = dyn_cast<ICmpInst>(BI->getCondition());
  LLVM_DEBUG(dbgs() << "\tLoop condition " << *Condition << "\n");

  if (Condition->getOperand(0) == PrimaryInduction ||
      Condition->getOperand(1) == PrimaryInduction) {
    // The condition examines the primary induction before the increment.  Check
    // to see if the condition directs control to exit the loop once
    // PrimaryInduction equals the end value.
    if ((ICmpInst::ICMP_EQ == Condition->getPredicate() &&
         BI->getSuccessor(1) == L->getHeader()) ||
        (ICmpInst::ICMP_NE == Condition->getPredicate() &&
         BI->getSuccessor(0) == L->getHeader()))
      // The end iteration is included in the loop bounds.
      InclusiveRange = true;
  }

  return true;
}

static Value *getEscapeValue(Instruction *UI, const InductionDescriptor &II,
                             Value *TripCount, PredicatedScalarEvolution &PSE,
                             bool PostInc) {
  const DataLayout &DL = UI->getModule()->getDataLayout();
  IRBuilder<> B(&*UI->getParent()->getFirstInsertionPt());
  Value *EffTripCount = TripCount;
  if (!PostInc)
    EffTripCount = B.CreateSub(
        TripCount, ConstantInt::get(TripCount->getType(), 1));

  Value *Count = !II.getStep()->getType()->isIntegerTy()
    ? B.CreateCast(Instruction::SIToFP, EffTripCount,
                   II.getStep()->getType())
    : B.CreateSExtOrTrunc(EffTripCount, II.getStep()->getType());
  if (PostInc)
    Count->setName("cast.count");
  else
    Count->setName("cast.cmo");

  Value *Escape = emitTransformedIndex(B, Count, PSE.getSE(), DL, II);
  Escape->setName(UI->getName() + ".escape");
  return Escape;
}

/// Fix up external users of the induction variable.  We assume we are in LCSSA
/// form, with all external PHIs that use the IV having one input value, coming
/// from the remainder loop.  We need those PHIs to also have a correct value
/// for the IV when arriving directly from the middle block.
void TapirLoopInfo::fixupIVUsers(PHINode *OrigPhi, const InductionDescriptor &II,
                                 PredicatedScalarEvolution &PSE) {
  // There are two kinds of external IV usages - those that use the value
  // computed in the last iteration (the PHI) and those that use the penultimate
  // value (the value that feeds into the phi from the loop latch).
  // We allow both, but they, obviously, have different values.
  assert(getExitBlock() && "Expected a single exit block");
  assert(getTripCount() && "Expected valid trip count");
  Loop *L = getLoop();
  Task *T = getTask();
  Value *TripCount = getTripCount();

  DenseMap<Value *, Value *> MissingVals;

  // An external user of the last iteration's value should see the value that
  // the remainder loop uses to initialize its own IV.
  Value *PostInc = OrigPhi->getIncomingValueForBlock(L->getLoopLatch());
  for (User *U : PostInc->users()) {
    Instruction *UI = cast<Instruction>(U);
    if (!L->contains(UI) && !T->encloses(UI->getParent())) {
      assert(isa<PHINode>(UI) && "Expected LCSSA form");
      MissingVals[UI] = getEscapeValue(UI, II, TripCount, PSE, true);
    }
  }

  // An external user of the penultimate value needs to see TripCount - Step.
  // The simplest way to get this is to recompute it from the constituent SCEVs,
  // that is Start + (Step * (TripCount - 1)).
  for (User *U : OrigPhi->users()) {
    Instruction *UI = cast<Instruction>(U);
    if (!L->contains(UI) && !T->encloses(UI->getParent())) {
      assert(isa<PHINode>(UI) && "Expected LCSSA form");
      MissingVals[UI] = getEscapeValue(UI, II, TripCount, PSE, false);
    }
  }

  for (auto &I : MissingVals) {
    LLVM_DEBUG(dbgs() << "Replacing external IV use:" << *I.first << " with "
               << *I.second << "\n");
    PHINode *PHI = cast<PHINode>(I.first);
    PHI->replaceAllUsesWith(I.second);
    PHI->eraseFromParent();
  }
}

const SCEV *TapirLoopInfo::getBackedgeTakenCount(
    PredicatedScalarEvolution &PSE) const {
  Loop *L = getLoop();
  ScalarEvolution *SE = PSE.getSE();
  const SCEV *BackedgeTakenCount = PSE.getBackedgeTakenCount();
  if (BackedgeTakenCount == SE->getCouldNotCompute())
    BackedgeTakenCount = SE->getExitCount(L, L->getLoopLatch());

  if (BackedgeTakenCount == SE->getCouldNotCompute())
    return BackedgeTakenCount;

  Type *IdxTy = getWidestInductionType();

  // The exit count might have the type of i64 while the phi is i32. This can
  // happen if we have an induction variable that is sign extended before the
  // compare. The only way that we get a backedge taken count is that the
  // induction variable was signed and as such will not overflow. In such a case
  // truncation is legal.
  if (BackedgeTakenCount->getType()->getPrimitiveSizeInBits() >
      IdxTy->getPrimitiveSizeInBits())
    BackedgeTakenCount = SE->getTruncateOrNoop(BackedgeTakenCount, IdxTy);
  BackedgeTakenCount = SE->getNoopOrZeroExtend(BackedgeTakenCount, IdxTy);

  return BackedgeTakenCount;
}

const SCEV *TapirLoopInfo::getExitCount(const SCEV *BackedgeTakenCount,
                                        PredicatedScalarEvolution &PSE) const {
  ScalarEvolution *SE = PSE.getSE();
  const SCEV *ExitCount;
  if (InclusiveRange)
    ExitCount = BackedgeTakenCount;
  else
    // Get the total trip count from the count by adding 1.
    ExitCount = SE->getAddExpr(
        BackedgeTakenCount, SE->getOne(BackedgeTakenCount->getType()));
  return ExitCount;
}

/// Returns (and creates if needed) the original loop trip count.
Value *TapirLoopInfo::getOrCreateTripCount(PredicatedScalarEvolution &PSE,
                                           const char *PassName,
                                           OptimizationRemarkEmitter *ORE) {
  if (TripCount)
    return TripCount;
  Loop *L = getLoop();

  // Get the existing SSA value being used for the end condition of the loop.
  if (!Condition)
    if (!getLoopCondition(PassName, ORE))
      return nullptr;

  Value *ConditionEnd = Condition->getOperand(0);
  {
    if (!L->isLoopInvariant(ConditionEnd)) {
      if (!L->isLoopInvariant(Condition->getOperand(1)))
        return nullptr;
      ConditionEnd = Condition->getOperand(1);
    }
  }
  assert(L->isLoopInvariant(ConditionEnd) &&
         "Condition end is not loop invariant.");

  IRBuilder<> Builder(L->getLoopPreheader()->getTerminator());
  ScalarEvolution *SE = PSE.getSE();

  // Find the loop boundaries.
  const SCEV *BackedgeTakenCount = SE->getExitCount(L, L->getLoopLatch());

  if (BackedgeTakenCount == SE->getCouldNotCompute()) {
    LLVM_DEBUG(dbgs() << "Could not compute backedge-taken count.\n");
    return nullptr;
  }

  const SCEV *ExitCount = getExitCount(BackedgeTakenCount, PSE);

  if (ExitCount == SE->getSCEV(ConditionEnd)) {
    TripCount = ConditionEnd;
    return TripCount;
  }

  const DataLayout &DL = L->getHeader()->getModule()->getDataLayout();
  Type *IdxTy = getWidestInductionType();

  // Expand the trip count and place the new instructions in the preheader.
  // Notice that the pre-header does not change, only the loop body.
  SCEVExpander Exp(*SE, DL, "induction");

  // Count holds the overall loop count (N).
  TripCount = Exp.expandCodeFor(ExitCount, ExitCount->getType(),
                                L->getLoopPreheader()->getTerminator());

  if (TripCount->getType()->isPointerTy())
    TripCount =
        CastInst::CreatePointerCast(TripCount, IdxTy, "exitcount.ptrcnt.to.int",
                                    L->getLoopPreheader()->getTerminator());

  // Try to use the existing ConditionEnd for the trip count.
  if (TripCount != ConditionEnd) {
    // Compare the SCEV's of the TripCount and ConditionEnd to see if they're
    // equal.  Normalize these SCEV types to be IdxTy.
    const SCEV *TripCountSCEV =
        SE->getNoopOrAnyExtend(SE->getSCEV(TripCount), IdxTy);
    const SCEV *ConditionEndSCEV =
        SE->getNoopOrAnyExtend(SE->getSCEV(ConditionEnd), IdxTy);
    if (SE->getMinusSCEV(TripCountSCEV, ConditionEndSCEV)->isZero())
      TripCount = ConditionEnd;
  }

  return TripCount;
}

/// Top-level call to prepare a Tapir loop for outlining.
bool TapirLoopInfo::prepareForOutlining(
    DominatorTree &DT, LoopInfo &LI, TaskInfo &TI,
    PredicatedScalarEvolution &PSE, AssumptionCache &AC, const char *PassName,
    OptimizationRemarkEmitter &ORE, const TargetTransformInfo &TTI) {
  LLVM_DEBUG(dbgs() << "Preparing loop for outlining " << *getLoop() << "\n");

  // Collect the IVs in this loop.
  collectIVs(PSE, PassName, &ORE);

  // If no primary induction was found, just bail.
  if (!PrimaryInduction)
    return false;

  LLVM_DEBUG(dbgs() << "\tPrimary induction " << *PrimaryInduction << "\n");

  // Replace any non-primary IV's.
  replaceNonPrimaryIVs(PSE);

  // Compute the trip count for this loop.
  //
  // We need the trip count for two reasons.
  //
  // 1) In the call to the helper that will replace this loop, we need to pass
  // the total number of loop iterations.
  //
  // 2) In the helper itself, the strip-mined loop must iterate to the
  // end-iteration argument, not the total number of iterations.
  Value *TripCount = getOrCreateTripCount(PSE, PassName, &ORE);
  if (!TripCount) {
    ORE.emit(createMissedAnalysis(PassName, "NoTripCount", getLoop())
             << "could not compute finite loop trip count.");
    return false;
  }

  LLVM_DEBUG(dbgs() << "\tTrip count " << *TripCount << "\n");

  // If necessary, rewrite the loop condition to use TripCount.  This code
  // should run very rarely, since IndVarSimplify should have already simplified
  // the loop's induction variables.
  if ((Condition->getOperand(0) != TripCount) &&
      (Condition->getOperand(1) != TripCount)) {
    Loop *L = getLoop();
    // For now, we don't handle the case where there are multiple uses of the
    // condition.
    assert(Condition->hasOneUse() &&
           "Attempting to rewrite Condition with multiple uses.");
    // Get the IV to use for the new condition: either PrimaryInduction or its
    // incremented value, depending on whether the range is inclusive.
    Value *IVForCond =
        InclusiveRange
            ? PrimaryInduction
            : PrimaryInduction->getIncomingValueForBlock(L->getLoopLatch());
    // Get the parity of the LoopLatch terminator, i.e., whether the true or
    // false branch is the backedge.
    BranchInst *BI = dyn_cast<BranchInst>(L->getLoopLatch()->getTerminator());
    bool BEBranchParity = (BI->getSuccessor(0) == L->getHeader());
    // Create the new Condition
    ICmpInst *NewCond =
        new ICmpInst(BEBranchParity ? ICmpInst::ICMP_NE : ICmpInst::ICMP_EQ,
                     IVForCond, TripCount);
    NewCond->setDebugLoc(Condition->getDebugLoc());
    // Replace the old Condition with the new Condition.
    ReplaceInstWithInst(Condition, NewCond);
    Condition = NewCond;
  }

  // FIXME: This test is probably too simple.
  assert(((Condition->getOperand(0) == TripCount) ||
          (Condition->getOperand(1) == TripCount)) &&
         "Condition does not use trip count.");

  // Fixup all external uses of the IVs.
  for (auto &InductionEntry : Inductions)
    fixupIVUsers(InductionEntry.first, InductionEntry.second, PSE);

  return true;
}

/// Transforms an induction descriptor into a direct computation of its value at
/// Index.
///
/// Copied from lib/Transforms/Vectorize/LoopVectorize.cpp
Value *llvm::emitTransformedIndex(
    IRBuilder<> &B, Value *Index, ScalarEvolution *SE, const DataLayout &DL,
    const InductionDescriptor &ID) {

  SCEVExpander Exp(*SE, DL, "induction");
  auto Step = ID.getStep();
  auto StartValue = ID.getStartValue();
  assert(Index->getType() == Step->getType() &&
         "Index type does not match StepValue type");

  // Note: the IR at this point is broken. We cannot use SE to create any new
  // SCEV and then expand it, hoping that SCEV's simplification will give us
  // a more optimal code. Unfortunately, attempt of doing so on invalid IR may
  // lead to various SCEV crashes. So all we can do is to use builder and rely
  // on InstCombine for future simplifications. Here we handle some trivial
  // cases only.
  auto CreateAdd = [&B](Value *X, Value *Y) {
    assert(X->getType() == Y->getType() && "Types don't match!");
    if (auto *CX = dyn_cast<ConstantInt>(X))
      if (CX->isZero())
        return Y;
    if (auto *CY = dyn_cast<ConstantInt>(Y))
      if (CY->isZero())
        return X;
    return B.CreateAdd(X, Y);
  };

  auto CreateMul = [&B](Value *X, Value *Y) {
    assert(X->getType() == Y->getType() && "Types don't match!");
    if (auto *CX = dyn_cast<ConstantInt>(X))
      if (CX->isOne())
        return Y;
    if (auto *CY = dyn_cast<ConstantInt>(Y))
      if (CY->isOne())
        return X;
    return B.CreateMul(X, Y);
  };

  switch (ID.getKind()) {
  case InductionDescriptor::IK_IntInduction: {
    assert(Index->getType() == StartValue->getType() &&
           "Index type does not match StartValue type");
    if (ID.getConstIntStepValue() && ID.getConstIntStepValue()->isMinusOne())
      return B.CreateSub(StartValue, Index);
    auto *Offset = CreateMul(
        Index, Exp.expandCodeFor(Step, Index->getType(), &*B.GetInsertPoint()));
    return CreateAdd(StartValue, Offset);
  }
  case InductionDescriptor::IK_PtrInduction: {
    assert(isa<SCEVConstant>(Step) &&
           "Expected constant step for pointer induction");
    return B.CreateGEP(
        nullptr, StartValue,
        CreateMul(Index, Exp.expandCodeFor(Step, Index->getType(),
                                           &*B.GetInsertPoint())));
  }
  case InductionDescriptor::IK_FpInduction: {
    assert(Step->getType()->isFloatingPointTy() && "Expected FP Step value");
    auto InductionBinOp = ID.getInductionBinOp();
    assert(InductionBinOp &&
           (InductionBinOp->getOpcode() == Instruction::FAdd ||
            InductionBinOp->getOpcode() == Instruction::FSub) &&
           "Original bin op should be defined for FP induction");

    Value *StepValue = cast<SCEVUnknown>(Step)->getValue();

    // Floating point operations had to be 'fast' to enable the induction.
    FastMathFlags Flags;
    Flags.setFast();

    Value *MulExp = B.CreateFMul(StepValue, Index);
    if (isa<Instruction>(MulExp))
      // We have to check, the MulExp may be a constant.
      cast<Instruction>(MulExp)->setFastMathFlags(Flags);

    Value *BOp = B.CreateBinOp(InductionBinOp->getOpcode(), StartValue, MulExp,
                               "induction");
    if (isa<Instruction>(BOp))
      cast<Instruction>(BOp)->setFastMathFlags(Flags);

    return BOp;
  }
  case InductionDescriptor::IK_NoInduction:
    return nullptr;
  }
  llvm_unreachable("invalid enum");
}
