//===- LoopStripMinePass.cpp - Loop strip-mining pass ---------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a pass to perform Tapir loop strip-mining.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Tapir/LoopStripMinePass.h"
#include "llvm/ADT/PriorityWorklist.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/BlockFrequencyInfo.h"
#include "llvm/Analysis/CodeMetrics.h"
#include "llvm/Analysis/LoopAnalysisManager.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/Analysis/OptimizationRemarkEmitter.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/Analysis/WorkSpanAnalysis.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/PassManager.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/InstructionCost.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Tapir.h"
#include "llvm/Transforms/Tapir/LoopStripMine.h"
#include "llvm/Transforms/Utils.h"
#include "llvm/Transforms/Utils/LoopSimplify.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "loop-stripmine"

cl::opt<bool> llvm::EnableTapirLoopStripmine(
    "stripmine-loops", cl::init(true), cl::Hidden,
    cl::desc("Run the Tapir Loop stripmining pass"));

static cl::opt<bool> AllowParallelEpilog(
  "allow-parallel-epilog", cl::Hidden, cl::init(true),
  cl::desc("Allow stripmined Tapir loops to execute their epilogs in parallel."));

static cl::opt<bool> IncludeNestedSync(
  "include-nested-sync", cl::Hidden, cl::init(true),
  cl::desc("If the epilog is allowed to execute in parallel, include a sync "
           "instruction in the nested task."));

static cl::opt<bool> RequireParallelEpilog(
    "require-parallel-epilog", cl::Hidden, cl::init(false),
    cl::desc("Require stripmined Tapir loops to execute their epilogs in "
             "parallel.  Intended for debugging."));

/// Create an analysis remark that explains why stripmining failed
///
/// \p RemarkName is the identifier for the remark.  If \p I is passed it is an
/// instruction that prevents vectorization.  Otherwise \p TheLoop is used for
/// the location of the remark.  \return the remark object that can be streamed
/// to.
static OptimizationRemarkAnalysis createMissedAnalysis(StringRef RemarkName,
                                                       const Loop *TheLoop,
                                                       Instruction *I = nullptr,
                                                       DebugLoc DL = {}) {
  BasicBlock *CodeRegion = I ? I->getParent() : TheLoop->getHeader();
  // If debug location is attached to the instruction, use it. Otherwise if DL
  // was not provided, use the loop's.
  if (I && I->getDebugLoc())
    DL = I->getDebugLoc();
  else if (!DL)
    DL = TheLoop->getStartLoc();

  return OptimizationRemarkAnalysis(DEBUG_TYPE, RemarkName, DL, CodeRegion)
         << "Loop not stripmined: ";
}

/// Approximate the work of the body of the loop L.  Returns several relevant
/// properties of loop L via by-reference arguments.
static InstructionCost approximateLoopCost(
    const Loop *L, unsigned &NumCalls, bool &NotDuplicatable, bool &Convergent,
    bool &IsRecursive, bool &UnknownSize, const TargetTransformInfo &TTI,
    LoopInfo *LI, ScalarEvolution &SE,
    const SmallPtrSetImpl<const Value *> &EphValues, TargetLibraryInfo *TLI,
    BlockFrequencyInfo *BFI, OptimizationRemarkEmitter *ORE) {

  WSCost LoopCost;
  estimateLoopCost(LoopCost, L, LI, &SE, TTI, TLI, BFI, EphValues, ORE);

  // Exclude calls to builtins when counting the calls.  This assumes that all
  // builtin functions are cheap.
  NumCalls = LoopCost.Metrics.NumCalls - LoopCost.Metrics.NumBuiltinCalls;
  NotDuplicatable = LoopCost.Metrics.notDuplicatable;
  Convergent = LoopCost.Metrics.Convergence != ConvergenceKind::None;
  IsRecursive = LoopCost.Metrics.isRecursive;
  UnknownSize = LoopCost.UnknownCost;

  return LoopCost.Work;
}

static bool tryToStripMineLoop(Loop *L, DominatorTree &DT, LoopInfo *LI,
                               ScalarEvolution &SE,
                               const TargetTransformInfo &TTI,
                               AssumptionCache &AC, TaskInfo *TI,
                               OptimizationRemarkEmitter &ORE,
                               TargetLibraryInfo *TLI, BlockFrequencyInfo *BFI,
                               bool PreserveLCSSA,
                               std::optional<unsigned> ProvidedCount) {
  Task *T = getTaskIfTapirLoopStructure(L, TI);
  if (!T)
    return false;
  TapirLoopHints Hints(L);

  if (TM_Disable == hasLoopStripmineTransformation(L))
    return false;

  Function *F = L->getHeader()->getParent();
  LLVM_DEBUG(dbgs() << "Loop Strip Mine: F[" << F->getName() << "] Loop %"
                    << L->getHeader()->getName() << "\n");

  if (!L->isLoopSimplifyForm()) {
    LLVM_DEBUG(dbgs() << "  Not stripmining loop which is not in loop-simplify "
                         "form.\n");
    return false;
  }
  bool StripMiningRequested =
      (hasLoopStripmineTransformation(L) == TM_ForcedByUser);
  TargetTransformInfo::StripMiningPreferences SMP =
    gatherStripMiningPreferences(L, SE, TTI, ProvidedCount);

  unsigned NumCalls = 0;
  bool NotDuplicatable = false;
  bool Convergent = false;
  bool IsRecursive = false;
  bool UnknownSize = false;

  SmallPtrSet<const Value *, 32> EphValues;
  CodeMetrics::collectEphemeralValues(L, &AC, EphValues);

  InstructionCost LoopCost =
      approximateLoopCost(L, NumCalls, NotDuplicatable, Convergent, IsRecursive,
                          UnknownSize, TTI, LI, SE, EphValues, TLI, BFI, &ORE);
  // Determine the iteration count of the eventual stripmined the loop.
  bool ExplicitCount = computeStripMineCount(L, TTI, LoopCost, SMP);
  ORE.emit([&]() {
    return OptimizationRemarkAnalysis(DEBUG_TYPE, "StripmineCount",
                                      L->getStartLoc(), L->getHeader())
           << "Found stripmine count " << ore::NV("StripmineCount", SMP.Count)
           << (ExplicitCount ? " (from annotation or command-line option)."
                             : ".");
  });

  // If the work in the loop body is big, then use a stripmine count of 1 for
  // it.
  LLVM_DEBUG(dbgs() << "  Loop cost = " << LoopCost
                    << ", Stripmine count = " << SMP.Count
                    << (ExplicitCount ? " (explicit count)\n" : "\n"));
  if (SMP.Count <= 1) {
    LLVM_DEBUG(dbgs() << "  Using grainsize 1 for big loop.\n");
    if (Hints.getGrainsize() == 1)
      return false;
    ORE.emit([&]() {
      return OptimizationRemark(DEBUG_TYPE, "BigLoop", L->getStartLoc(),
                                L->getHeader())
             << "using grainsize 1 for big loop";
    });
    Hints.setAlreadyStripMined();
    return true;
  }

  // If the loop is recursive, set the stripmine count to be 1.
  if (!ExplicitCount && IsRecursive) {
    LLVM_DEBUG(dbgs() << "  Not stripmining loop that recursively calls the "
                      << "containing function.\n");
    if (Hints.getGrainsize() == 1)
      return false;
    ORE.emit([&]() {
      return OptimizationRemark(DEBUG_TYPE, "RecursiveCalls", L->getStartLoc(),
                                L->getHeader())
             << "Using grainsize 1 for loop with recursive calls";
    });
    Hints.setAlreadyStripMined();
    return true;
  }

  // If the loop size is unknown, then we cannot compute a stripmining count for
  // it.
  if (!ExplicitCount && UnknownSize) {
    LLVM_DEBUG(dbgs() << "  Not stripmining loop with unknown size.\n");
    ORE.emit(createMissedAnalysis("UnknownSize", L)
             << "Cannot stripmine loop with unknown size.");
    return false;
  }

  // TODO: We can stripmine loops if the stripmined version does not require a
  // prolog or epilog.
  if (NotDuplicatable) {
    LLVM_DEBUG(dbgs() << "  Not stripmining loop which contains "
                      << "non-duplicatable instructions.\n");
    ORE.emit(createMissedAnalysis("NotDuplicatable", L)
             << "Cannot stripmine loop containing instructions that cannot be "
                "duplicated.");
    return false;
  }

  // If the loop contains a convergent operation, then the control flow
  // introduced between the stripmined loop and epilog is unsafe -- it adds a
  // control-flow dependency to the convergent operation.
  if (Convergent) {
    LLVM_DEBUG(dbgs() << "  Skipping loop with convergent operations.\n");
    ORE.emit(createMissedAnalysis("Convergent", L)
             << "Cannot stripmine loop containing convergent instructions.");
    return false;
  }

  // If the loop contains potentially expensive function calls, then the
  // stripmine count might be an underestimate.  Avoid stripmining these loops
  // unless we would use grainsize 1 or stripmining is explicitly requested.
  if (NumCalls > 0 && !ExplicitCount && !StripMiningRequested) {
    LLVM_DEBUG(dbgs() << "  Skipping loop with expensive function calls.\n");
    ORE.emit(createMissedAnalysis("ExpensiveCalls", L)
             << "Loop contains function calls with unknown cost.");
    ORE.emit([&]() {
      return OptimizationRemarkAnalysis(DEBUG_TYPE, "BoundRuntimeGrainsize",
                                        L->getStartLoc(), L->getHeader())
             << "Applying runtime grainsize bound: "
             << ore::NV("GrainsizeBound", SMP.Count) << ".";
    });
    Hints.setGrainsizeBound(SMP.Count);
    return false;
  }

  // Make sure the count is a power of 2.
  // TODO: Support stripmining by not a power of 2.
  if (!isPowerOf2_32(SMP.Count))
    SMP.Count = NextPowerOf2(SMP.Count);

  // Find a constant trip count if available
  unsigned ConstTripCount = getConstTripCount(L, SE);

  // Stripmining factor (Count) must be less or equal to TripCount, or else it's
  // better to just execute this loop serially.
  if (ConstTripCount && SMP.Count >= ConstTripCount) {
    ORE.emit([&]() {
      return OptimizationRemarkAnalysis(DEBUG_TYPE, "FullStripMine",
                                        L->getStartLoc(), L->getHeader())
             << "stripmine count (" << ore::NV("StripmineCount", SMP.Count)
             << ") exceeds loop trip count ("
             << ore::NV("ConstTripCount", ConstTripCount) << ").";
    });

    // Serialize the loop's detach, since it appears to be too small to be worth
    // parallelizing.
    ORE.emit([&]() {
      return OptimizationRemark(DEBUG_TYPE, "SerializingSmallLoop",
                                L->getStartLoc(), L->getHeader())
             << "Serializing parallel loop that appears not to be profitable "
                "to parallelize.";
    });
    SerializeDetach(cast<DetachInst>(L->getHeader()->getTerminator()), T,
                    /*ReplaceWithTaskFrame=*/taskContainsSync(T), &DT);
    Hints.clearHintsMetadata();
    L->setDerivedFromTapirLoop();
    // Update TaskInfo manually using the updated DT.
    if (TI)
      // FIXME: Recalculating TaskInfo for the whole function is wasteful.
      // Optimize this routine in the future.
      TI->recalculate(*L->getHeader()->getParent(), DT);
    return true;
  }

  // When is it worthwhile to allow the epilog to run in parallel with the
  // stripmined loop?  We expect the epilog to perform G/2 iterations on
  // average, where G is the selected grainsize.  Our goal is to ensure that
  // these G/2 iterations offset the cost of an additional detach.
  // Mathematically, this means
  //
  // (G/2) * S + d <= (1 + \eps) * G/2 * S ,
  //
  // where S is the work of one loop iteration, d is the cost of a detach, and
  // \eps is a sufficiently small constant, e.g., 1/C for a coarsening factor C.
  // We assume that the choice of G is chosen such that G * \eps <= 1, which is
  // true for the automatic computation of G aimed at ensuring the stripmined
  // loop performs at most a (1 + \eps) factor more work than its serial
  // projection.  Solving the above equation thus shows that the epilog should
  // be allowed to run in parallel when S >= 2 * d.  We check for this case and
  // encode the result in ParallelEpilog.
  Instruction *DetachI = L->getHeader()->getTerminator();
  bool ParallelEpilog =
      RequireParallelEpilog ||
      (AllowParallelEpilog &&
       ((SMP.Count < SMP.DefaultCoarseningFactor) ||
        (2 * TTI.getInstructionCost(DetachI,
                                    TargetTransformInfo::TCK_SizeAndLatency)) <=
            LoopCost));

  // Some parallel runtimes, such as Cilk, require nested parallel tasks to be
  // synchronized.
  bool NeedNestedSync = IncludeNestedSync;
  if (!NeedNestedSync && TLI)
    NeedNestedSync = (TLI->getTapirTarget() == TapirTargetID::CilkPlus ||
                      TLI->getTapirTarget() == TapirTargetID::OpenCilk);

  // Save loop properties before it is transformed.
  MDNode *OrigLoopID = L->getLoopID();

  // Stripmine the loop
  Loop *RemainderLoop = nullptr;
  Loop *NewLoop = StripMineLoop(L, SMP.Count, SMP.AllowExpensiveTripCount,
                                SMP.UnrollRemainder, LI, &SE, &DT, TTI, &AC, TI,
                                &ORE, PreserveLCSSA, ParallelEpilog,
                                NeedNestedSync, &RemainderLoop);
  if (!NewLoop)
    return false;

  // Copy metadata to remainder loop
  if (RemainderLoop && OrigLoopID) {
    MDNode *NewRemainderLoopID =
        CopyNonTapirLoopMetadata(RemainderLoop->getLoopID(), OrigLoopID);
    RemainderLoop->setLoopID(NewRemainderLoopID);
  }

  // Mark the new loop as stripmined.
  TapirLoopHints NewHints(NewLoop);
  NewHints.setAlreadyStripMined();

  return true;
}

namespace {

class LoopStripMine : public LoopPass {
public:
  static char ID; // Pass ID, replacement for typeid

  std::optional<unsigned> ProvidedCount;

  LoopStripMine(std::optional<unsigned> Count = std::nullopt)
      : LoopPass(ID), ProvidedCount(Count) {
    initializeLoopStripMinePass(*PassRegistry::getPassRegistry());
  }

  bool runOnLoop(Loop *L, LPPassManager &LPM) override {
    if (skipLoop(L))
      return false;

    Function &F = *L->getHeader()->getParent();

    auto &TLI = getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);
    auto &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
    LoopInfo *LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    TaskInfo *TI = &getAnalysis<TaskInfoWrapperPass>().getTaskInfo();
    ScalarEvolution &SE = getAnalysis<ScalarEvolutionWrapperPass>().getSE();
    const TargetTransformInfo &TTI =
        getAnalysis<TargetTransformInfoWrapperPass>().getTTI(F);
    auto &AC = getAnalysis<AssumptionCacheTracker>().getAssumptionCache(F);
    // For the old PM, we can't use OptimizationRemarkEmitter as an analysis
    // pass.  Function analyses need to be preserved across loop transformations
    // but ORE cannot be preserved (see comment before the pass definition).
    OptimizationRemarkEmitter ORE(&F);
    bool PreserveLCSSA = mustPreserveAnalysisID(LCSSAID);

    return tryToStripMineLoop(L, DT, LI, SE, TTI, AC, TI, ORE, &TLI, nullptr,
                              PreserveLCSSA, ProvidedCount);
  }

  /// This transformation requires natural loop information & requires that
  /// loop preheaders be inserted into the CFG...
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AssumptionCacheTracker>();
    AU.addRequired<TargetTransformInfoWrapperPass>();
    AU.addRequired<TargetLibraryInfoWrapperPass>();
    getLoopAnalysisUsage(AU);
  }
};

} // end anonymous namespace

char LoopStripMine::ID = 0;

INITIALIZE_PASS_BEGIN(LoopStripMine, "loop-stripmine", "Stripmine Tapir loops",
                      false, false)
INITIALIZE_PASS_DEPENDENCY(AssumptionCacheTracker)
INITIALIZE_PASS_DEPENDENCY(LoopPass)
INITIALIZE_PASS_DEPENDENCY(TargetTransformInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetLibraryInfoWrapperPass)
INITIALIZE_PASS_END(LoopStripMine, "loop-stripmine", "Stripmine Tapir loops",
                    false, false)

Pass *llvm::createLoopStripMinePass(int Count) {
  // TODO: It would make more sense for this function to take the optionals
  // directly, but that's dangerous since it would silently break out of tree
  // callers.
  return new LoopStripMine(Count == -1 ? std::nullopt
                                       : std::optional<unsigned>(Count));
}

PreservedAnalyses LoopStripMinePass::run(Function &F,
                                         FunctionAnalysisManager &AM) {
  auto &TLI = AM.getResult<TargetLibraryAnalysis>(F);
  auto &SE = AM.getResult<ScalarEvolutionAnalysis>(F);
  auto &LI = AM.getResult<LoopAnalysis>(F);
  auto &TTI = AM.getResult<TargetIRAnalysis>(F);
  auto &DT = AM.getResult<DominatorTreeAnalysis>(F);
  auto &AC = AM.getResult<AssumptionAnalysis>(F);
  auto &TI = AM.getResult<TaskAnalysis>(F);
  auto &ORE = AM.getResult<OptimizationRemarkEmitterAnalysis>(F);
  auto &BFI = AM.getResult<BlockFrequencyAnalysis>(F);

  LoopAnalysisManager *LAM = nullptr;
  if (auto *LAMProxy = AM.getCachedResult<LoopAnalysisManagerFunctionProxy>(F))
    LAM = &LAMProxy->getManager();

  bool Changed = false;

  // The stripminer requires loops to be in simplified form, and also needs
  // LCSSA.  Since simplification may add new inner loops, it has to run before
  // the legality and profitability checks. This means running the loop
  // stripminer will simplify all loops, regardless of whether anything end up
  // being stripmined.
  for (auto &L : LI) {
    Changed |= simplifyLoop(L, &DT, &LI, &SE, &AC, nullptr,
                            /* PreserveLCSSA */ false);
    Changed |= formLCSSARecursively(*L, DT, &LI, &SE);
  }

  SmallPriorityWorklist<Loop *, 4> Worklist;
  appendLoopsToWorklist(LI, Worklist);

  while (!Worklist.empty()) {
    // Because the LoopInfo stores the loops in RPO, we walk the worklist from
    // back to front so that we work forward across the CFG, which for
    // stripmining is only needed to get optimization remarks emitted in a
    // forward order.
    Loop &L = *Worklist.pop_back_val();
#ifndef NDEBUG
    Loop *ParentL = L.getParentLoop();
#endif

    // // Check if the profile summary indicates that the profiled application
    // // has a huge working set size, in which case we disable peeling to avoid
    // // bloating it further.
    // if (PSI && PSI->hasHugeWorkingSetSize())
    //   AllowPeeling = false;
    std::string LoopName = std::string(L.getName());
    bool LoopChanged =
        tryToStripMineLoop(&L, DT, &LI, SE, TTI, AC, &TI, ORE, &TLI, &BFI,
                           /*PreserveLCSSA*/ true, /*Count*/ std::nullopt);
    Changed |= LoopChanged;

    // The parent must not be damaged by stripmining!
#ifndef NDEBUG
    if (LoopChanged && ParentL)
      ParentL->verifyLoop();
#endif

    // Clear any cached analysis results for L if we removed it completely.
    if (LAM && LoopChanged)
      LAM->clear(L, LoopName);
  }

  if (!Changed)
    return PreservedAnalyses::all();

  return getLoopPassPreservedAnalyses();
}
