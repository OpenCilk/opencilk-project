//===- TapirLoopInfo.h - Utility functions for Tapir loops -----*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines utility functions for handling Tapir loops.
//
//===----------------------------------------------------------------------===//

#ifndef TAPIR_LOOP_INFO_H_
#define TAPIR_LOOP_INFO_H_

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/ValueHandle.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"
#include "llvm/Transforms/Utils/LoopUtils.h"

namespace llvm {

class AssumptionCache;
class BasicBlock;
class DominatorTree;
class ICmpInst;
class Instruction;
class OptimizationRemarkAnalysis;
class OptimizationRemarkEmitter;
class PHINode;
class PredicatedScalarEvolution;
class ScalarEvolution;
class TargetTransformInfo;

/// Class for managing information about a Tapir loop, primarily for the purpose
/// of outlining Tapir loops.
///
/// A Tapir loop is defined as an ordinary Loop whose body -- all code in the
/// loop except for the indiction variables and loop control --- is contained in
/// a spawned task.
class TapirLoopInfo {
public:
  /// InductionList saves induction variables and maps them to the induction
  /// descriptor.
  using InductionList = MapVector<PHINode *, InductionDescriptor>;

  TapirLoopInfo(Loop *L, Task *T) : TheLoop(L), TheTask(T) {
    // Get the exit block for this loop.
    Instruction *TI = TheLoop->getLoopLatch()->getTerminator();
    ExitBlock = TI->getSuccessor(0);
    if (ExitBlock == TheLoop->getHeader())
      ExitBlock = TI->getSuccessor(1);

    // Get the unwind destination for this loop.
    DetachInst *DI = T->getDetach();
    if (DI->hasUnwindDest())
      UnwindDest = DI->getUnwindDest();
  }

  /// Constructor that automatically reads the metadata for the loop.
  TapirLoopInfo(Loop *L, Task *T, OptimizationRemarkEmitter &ORE)
      : TapirLoopInfo(L, T) {
    readTapirLoopMetadata(ORE);
  }

  ~TapirLoopInfo() {
    if (StartIterArg)
      delete StartIterArg;
    if (EndIterArg)
      delete EndIterArg;
    if (GrainsizeArg)
      delete GrainsizeArg;

    DescendantTasks.clear();
    Inductions.clear();
  }

  Loop *getLoop() const { return TheLoop; }
  Task *getTask() const { return TheTask; }

  /// Top-level call to prepare a Tapir loop for outlining.
  bool prepareForOutlining(
    DominatorTree &DT, LoopInfo &LI, TaskInfo &TI,
    PredicatedScalarEvolution &PSE, AssumptionCache &AC, const char *PassName,
    OptimizationRemarkEmitter &ORE, const TargetTransformInfo &TTI);

  /// Gather all induction variables in this loop that need special handling
  /// during outlining.
  bool collectIVs(PredicatedScalarEvolution &PSE, const char *PassName,
                  OptimizationRemarkEmitter *ORE);

  /// Replace all induction variables in this loop that are not primary with
  /// stronger forms.
  void replaceNonPrimaryIVs(PredicatedScalarEvolution &PSE);

  /// Identify the loop condition instruction, and determine if the loop uses an
  /// inclusive or exclusive range.
  bool getLoopCondition(const char *PassName, OptimizationRemarkEmitter *ORE);

  /// Fix up external users of the induction variable.
  void fixupIVUsers(PHINode *OrigPhi, const InductionDescriptor &II,
                    PredicatedScalarEvolution &PSE);

  /// Returns (and creates if needed) the original loop trip count.
  const SCEV *getBackedgeTakenCount(PredicatedScalarEvolution &PSE) const;
  const SCEV *getExitCount(const SCEV *BackedgeTakenCount,
                           PredicatedScalarEvolution &PSE) const;
  // Return a non-overflowing value representing the trip count.  For the
  // typical case of a loop over a non-inclusive range (e.g., i \in [0,n),
  // excluding n), this value is the backedge count plus 1.  But to avoid
  // overflow conditions, for a loop over an inclusive range (e.g., i \in [0,n],
  // including n), this value is simply the backedge count.  Passes are expected
  // to use isInclusiveRange() to determine when they need to handle loops over
  // inclusive ranges as a special case.
  Value *getOrCreateTripCount(PredicatedScalarEvolution &PSE,
                              const char *PassName,
                              OptimizationRemarkEmitter *ORE);

  /// Record task T as a descendant task under this loop and not under a
  /// descendant Tapir loop.
  void addDescendantTask(Task *T) { DescendantTasks.push_back(T); }

  /// Adds \p Phi, with induction descriptor ID, to the inductions list.  This
  /// can set \p Phi as the main induction of the loop if \p Phi is a better
  /// choice for the main induction than the existing one.
  void addInductionPhi(PHINode *Phi, const InductionDescriptor &ID);

  /// Returns the original loop trip count, if it has been computed.
  Value *getTripCount() const {
    assert(TripCount.pointsToAliveValue() &&
           "TripCount does not point to alive value.");
    return TripCount;
  }

  /// Returns the original loop condition, if it has been computed.
  ICmpInst *getCondition() const { return Condition; }

  /// Returns true if this loop condition includes the end iteration.
  bool isInclusiveRange() const { return InclusiveRange; }

  /// Returns the widest induction type.
  Type *getWidestInductionType() const { return WidestIndTy; }

  /// Returns true if there is a primary induction variable for this Tapir loop.
  bool hasPrimaryInduction() const {
    return (nullptr != PrimaryInduction);
  }

  /// Get the primary induction variable for this Tapir loop.
  const std::pair<PHINode *, InductionDescriptor> &getPrimaryInduction() const {
    assert(PrimaryInduction && "No primary induction.");
    return *Inductions.find(PrimaryInduction);
  }

  /// Returns the induction variables found in the loop.
  InductionList *getInductionVars() { return &Inductions; }

  /// Get the grainsize associated with this Tapir Loop.  A return value of 0
  /// indicates the absence of a specified grainsize.
  unsigned getGrainsize() const { return Grainsize; }

  /// Get the exit block assoicated with this Tapir loop.
  BasicBlock *getExitBlock() const { return ExitBlock; }

  /// Get the unwind destination for this Tapir loop.
  BasicBlock *getUnwindDest() const { return UnwindDest; }

  /// Get the set of tasks enclosed in this Tapir loop and not a descendant
  /// Tapir loop.
  void getEnclosedTasks(SmallVectorImpl<Task *> &TaskVec) const {
    TaskVec.push_back(TheTask);
    for (Task *T : reverse(DescendantTasks))
      TaskVec.push_back(T);
  }

  /// Update information on this Tapir loop based on its metadata.
  void readTapirLoopMetadata(OptimizationRemarkEmitter &ORE);

  /// Get the debug location for this loop.
  DebugLoc getDebugLoc() const { return TheTask->getDetach()->getDebugLoc(); }

  /// Create an analysis remark that explains why the transformation failed
  ///
  /// \p RemarkName is the identifier for the remark.  If \p I is passed it is
  /// an instruction that prevents the transformation.  Otherwise \p TheLoop is
  /// used for the location of the remark.  \return the remark object that can
  /// be streamed to.
  ///
  /// Based on createMissedAnalysis in the LoopVectorize pass.
  static OptimizationRemarkAnalysis
  createMissedAnalysis(const char *PassName, StringRef RemarkName,
                       const Loop *TheLoop, Instruction *I = nullptr);

private:
  /// The loop that we evaluate.
  Loop *TheLoop;

  /// The task contained in this loop.
  Task *TheTask;

  /// Descendants of TheTask that are enclosed by this loop and not a descendant
  /// Tapir loop.
  SmallVector<Task *, 4> DescendantTasks;

  /// The single exit block for this Tapir loop.
  BasicBlock *ExitBlock = nullptr;

  /// The unwind destination of this Tapir loop, if it has one.
  BasicBlock *UnwindDest = nullptr;

  /// Holds the primary induction variable. This is the counter of the loop.
  PHINode *PrimaryInduction = nullptr;

  /// Holds all of the induction variables that we found in the loop.  Notice
  /// that inductions don't need to start at zero and that induction variables
  /// can be pointers.
  InductionList Inductions;

  /// Holds the widest induction type encountered.
  Type *WidestIndTy = nullptr;

  /// Trip count of the original loop.
  WeakTrackingVH TripCount;

  /// Latch condition of the original loop.
  ICmpInst *Condition = nullptr;
  bool InclusiveRange = false;

  /// Grainsize value to use for loop.  A value of 0 indicates that a call to
  /// Tapir's grainsize intrinsic should be used.
  unsigned Grainsize = 0;

public:
  /// Placeholder argument values.
  Argument *StartIterArg = nullptr;
  Argument *EndIterArg = nullptr;
  Argument *GrainsizeArg = nullptr;
};

/// Transforms an induction descriptor into a direct computation of its value at
/// Index.
Value *emitTransformedIndex(
    IRBuilder<> &B, Value *Index, ScalarEvolution *SE, const DataLayout &DL,
    const InductionDescriptor &ID);

}  // end namepsace llvm

#endif
