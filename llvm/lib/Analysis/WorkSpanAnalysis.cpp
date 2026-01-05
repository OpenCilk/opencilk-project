//===- WorkSpanAnalysis.cpp - Analysis to estimate work and span ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements an analysis pass to estimate the work and span of the
// program.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/WorkSpanAnalysis.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Analysis/BlockFrequencyInfo.h"
#include "llvm/Analysis/CodeMetrics.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/OptimizationRemarkEmitter.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/Support/BlockFrequency.h"
#include "llvm/Support/InstructionCost.h"

using namespace llvm;

#define DEBUG_TYPE "work-span"

// Get a constant trip count for the given loop.
unsigned llvm::getConstTripCount(const Loop *L, ScalarEvolution &SE) {
  int64_t ConstTripCount = 0;
  // If there are multiple exiting blocks but one of them is the latch, use
  // the latch for the trip count estimation. Otherwise insist on a single
  // exiting block for the trip count estimation.
  BasicBlock *ExitingBlock = L->getLoopLatch();
  if (!ExitingBlock || !L->isLoopExiting(ExitingBlock))
    ExitingBlock = L->getExitingBlock();
  if (ExitingBlock)
    ConstTripCount = SE.getSmallConstantTripCount(L, ExitingBlock);
  return ConstTripCount;
}

/// Recursive helper routine to estimate the amount of work in a loop.
static void estimateLoopCostHelper(const Loop *L, CodeMetrics &Metrics,
                                   WSCost &LoopCost, LoopInfo *LI,
                                   ScalarEvolution *SE, BlockFrequencyInfo *BFI,
                                   OptimizationRemarkEmitter *ORE) {
  if (LoopCost.UnknownCost)
    return;

  BlockFrequency LoopEntryFreq =
      BFI ? BFI->getBlockFreq(L->getHeader()) : BlockFrequency();
  for (Loop *SubL : *L) {
    WSCost SubLoopCost;
    BlockFrequency SubLoopEntryFreq =
        BFI ? BFI->getBlockFreq(SubL->getHeader()) : BlockFrequency();
    // Recursively evaluate the cost of the subloop.
    estimateLoopCostHelper(SubL, Metrics, SubLoopCost, LI, SE, BFI, ORE);
    int64_t TripCount = 1;

    if (LoopEntryFreq.getFrequency() && SubLoopEntryFreq.getFrequency()) {
      // Use block frequencies to scale the cost of the subloop.
      if (ORE)
        ORE->emit([&]() {
          return OptimizationRemarkAnalysis(
                     "work-span-analysis", "BFISubloopCost",
                     SubL->getStartLoc(), SubL->getHeader())
                 << "Using block-frequency analysis to estimate contribution "
                    "of subloop.  Subloop-entry frequency in loop is "
                 << ore::NV("SubloopFreq", SubLoopEntryFreq.getFrequency() /
                                               LoopEntryFreq.getFrequency())
                 << ".";
        });
      if (SubLoopEntryFreq < LoopEntryFreq) {
        // Scale down the work of the subloop to lower its contribution to this
        // loop's work.
        SubLoopCost.Work /=
            (LoopEntryFreq.getFrequency() / SubLoopEntryFreq.getFrequency());
      } else if (SubLoopEntryFreq > LoopEntryFreq) {
        // Scale up the subloop trip count to raise its contribution to this
        // loop's work.
        TripCount =
            SubLoopEntryFreq.getFrequency() / LoopEntryFreq.getFrequency();
      }
    } else {
      // Try to find a constant trip count for this loop.
      TripCount = SE ? getConstTripCount(SubL, *SE) : 0;
      if (!TripCount) {
        if (ORE)
          ORE->emit([&]() {
            return OptimizationRemarkAnalysis(
                       "work-span-analysis", "NoConstTripCount",
                       SubL->getStartLoc(), SubL->getHeader())
                   << "Could not determine constant trip count for subloop.";
          });
        // Could not compute a constant trip count.  Assume this subloop
        // executes once.
        LoopCost.UnknownCost = true;
        TripCount = 1;
      }
    }

    if (LoopEntryFreq.getFrequency() && SubLoopEntryFreq.getFrequency() &&
        SubLoopEntryFreq < LoopEntryFreq)
      SubLoopCost.Work /=
          (LoopEntryFreq.getFrequency() / SubLoopEntryFreq.getFrequency());
    // Quit early if the size of this subloop is already too big.
    if (InstructionCost::getMax() == SubLoopCost.Work)
      LoopCost.Work = InstructionCost::getMax();

    // Check if this subloop suffices to make this loop huge.
    if (InstructionCost::getMax() - LoopCost.Work <
        (SubLoopCost.Work * TripCount)) {
      if (ORE)
        ORE->emit([&]() {
          return OptimizationRemarkAnalysis("work-span-analysis",
                                            "LargeSubloop", SubL->getStartLoc(),
                                            SubL->getHeader())
                 << "Subloop work makes this loop large.";
        });
      LoopCost.Work = InstructionCost::getMax();
      return;
    }

    if (LoopCost.Work < InstructionCost::getMax())
      // Add in the work of this subloop scaled by its trip count.
      LoopCost.Work += (SubLoopCost.Work * TripCount);
  }

  // Add in the work of all other blocks in this loop that are not in some
  // subloop.
  for (BasicBlock *BB : L->blocks()) {
    if (LI->getLoopFor(BB) == L) {
      InstructionCost BBCost = Metrics.NumBBInsts[BB];
      BlockFrequency BBFreq = BFI ? BFI->getBlockFreq(BB) : BlockFrequency();
      if (LoopEntryFreq.getFrequency() && BBFreq.getFrequency() &&
          BBFreq < LoopEntryFreq) {
        // Scale this basic-block cost by its relative frequency.
        BBCost /= (LoopEntryFreq.getFrequency() / BBFreq.getFrequency());
      }
      // Check if this BB suffices to make loop L huge.
      if (InstructionCost::getMax() - LoopCost.Work < BBCost) {
        if (ORE)
          ORE->emit([&]() {
            return OptimizationRemarkAnalysis("work-span-analysis", "LargeLoop",
                                              L->getStartLoc(), BB)
                   << "Loop contains a lot of work.";
          });
        LoopCost.Work = InstructionCost::getMax();
        return;
      }
      LoopCost.Work += BBCost;
    }
  }

  if (ORE)
    ORE->emit([&]() {
      return OptimizationRemarkAnalysis("work-span-analysis", "LargeSubloop",
                                        L->getStartLoc(), L->getHeader())
             << "Estimated loop work: " << ore::NV("LoopWork", LoopCost.Work)
             << ".";
    });
}

void llvm::estimateLoopCost(WSCost &LoopCost, const Loop *L, LoopInfo *LI,
                            ScalarEvolution *SE, const TargetTransformInfo &TTI,
                            TargetLibraryInfo *TLI, BlockFrequencyInfo *BFI,
                            const SmallPtrSetImpl<const Value *> &EphValues,
                            OptimizationRemarkEmitter *ORE) {
  // TODO: Use vectorizability to enhance cost analysis.

  // Gather code metrics for all basic blocks in the loop.
  for (BasicBlock *BB : L->blocks())
    LoopCost.Metrics.analyzeBasicBlock(BB, TTI, EphValues,
                                       /*PrepareForLTO*/ false, L, TLI);

  estimateLoopCostHelper(L, LoopCost.Metrics, LoopCost, LI, SE, BFI, ORE);
}
