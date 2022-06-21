//===- LoopSpawningTI.cpp - Spawn loop iterations efficiently -------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Modify Tapir loops to spawn their iterations efficiently.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Tapir/LoopSpawningTI.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/LoopIterator.h"
#include "llvm/Analysis/OptimizationRemarkEmitter.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/ValueMap.h"
#include "llvm/IR/Verifier.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Timer.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Scalar/IndVarSimplify.h"
#include "llvm/Transforms/Scalar/SimplifyCFG.h"
#include "llvm/Transforms/Scalar/LoopDeletion.h"
#include "llvm/Transforms/Tapir.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"
#include "llvm/Transforms/Tapir/Outline.h"
#include "llvm/Transforms/Tapir/TapirLoopInfo.h"
#include "llvm/Transforms/Utils.h"
#include "llvm/Transforms/Utils/EscapeEnumerator.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
#include "llvm/Transforms/Utils/ScalarEvolutionExpander.h"
#include "llvm/Transforms/Utils/TapirUtils.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include <utility>

using namespace llvm;

#define LS_NAME "loop-spawning-ti"
#define DEBUG_TYPE LS_NAME

STATISTIC(TapirLoopsFound,
          "Number of Tapir loops discovered spawning");
STATISTIC(LoopsConvertedToDAC,
          "Number of Tapir loops converted to divide-and-conquer iteration "
          "spawning");

static const char TimerGroupName[] = DEBUG_TYPE;
static const char TimerGroupDescription[] = "Loop spawning";

/// The default loop-outline processor leaves the outlined Tapir loop as is.
class DefaultLoopOutlineProcessor : public LoopOutlineProcessor {
public:
  DefaultLoopOutlineProcessor(Module &M) : LoopOutlineProcessor(M) {}
  void postProcessOutline(TapirLoopInfo &TL, TaskOutlineInfo &Out,
                          ValueToValueMapTy &VMap) override final {
    LoopOutlineProcessor::postProcessOutline(TL, Out, VMap);
    addSyncToOutlineReturns(TL, Out, VMap);
  }
};

/// The DACSpawning loop-outline processor transforms an outlined Tapir loop to
/// evaluate the iterations using parallel recursive divide-and-conquer.
class DACSpawning : public LoopOutlineProcessor {
public:
  DACSpawning(Module &M) : LoopOutlineProcessor(M) {}
  void postProcessOutline(TapirLoopInfo &TL, TaskOutlineInfo &Out,
                          ValueToValueMapTy &VMap) override final {
    LoopOutlineProcessor::postProcessOutline(TL, Out, VMap);
    implementDACIterSpawnOnHelper(TL, Out, VMap);
    ++LoopsConvertedToDAC;

    // Move Cilksan instrumentation.
    moveCilksanInstrumentation(TL, Out, VMap);

    // Add syncs to all exits of the outline.
    addSyncToOutlineReturns(TL, Out, VMap);
  }

private:
  void implementDACIterSpawnOnHelper(
      TapirLoopInfo &TL, TaskOutlineInfo &Out, ValueToValueMapTy &VMap);
};

static bool isSRetInput(const Value *V, const Function &F) {
  if (!isa<Argument>(V))
    return false;

  auto ArgIter = F.arg_begin();
  if (F.hasParamAttribute(0, Attribute::StructRet) && V == &*ArgIter)
    return true;
  ++ArgIter;
  if (F.hasParamAttribute(1, Attribute::StructRet) && V == &*ArgIter)
    return true;

  return false;
}

void LoopOutlineProcessor::setupLoopOutlineArgs(
    Function &F, ValueSet &HelperArgs, SmallVectorImpl<Value *> &HelperInputs,
    ValueSet &InputSet, const SmallVectorImpl<Value *> &LCArgs,
    const SmallVectorImpl<Value *> &LCInputs, const ValueSet &TLInputsFixed) {
  // Add Tapir-loop inputs to vectors for args and helpers.
  //
  // First add the sret task input, if it exists.
  ValueSet::iterator TLInputIter = TLInputsFixed.begin();
  if ((TLInputIter != TLInputsFixed.end()) && isSRetInput(*TLInputIter, F)) {
    HelperArgs.insert(*TLInputIter);
    HelperInputs.push_back(*TLInputIter);
    ++TLInputIter;
  }

  // Then add the loop control inputs.
  for (Value *V : LCArgs)
    HelperArgs.insert(V);
  for (Value *V : LCInputs) {
    HelperInputs.push_back(V);
    // Add all loop-control inputs to the input set.
    InputSet.insert(V);
  }

  // Finally add the remaining inputs
  while (TLInputIter != TLInputsFixed.end()) {
    Value *V = *TLInputIter++;
    assert(!HelperArgs.count(V));
    HelperArgs.insert(V);
    HelperInputs.push_back(V);
  }
}

unsigned LoopOutlineProcessor::getIVArgIndex(const Function &F,
                                             const ValueSet &Args) const {
  // The argument for the primary induction variable is either the first or
  // second input, depending on whether there is an sret input.
  unsigned IVArgOffset = 0;
  if (isSRetInput(Args[IVArgOffset], F))
    ++IVArgOffset;
  return IVArgOffset;
}

void LoopOutlineProcessor::postProcessOutline(TapirLoopInfo &TL,
                                              TaskOutlineInfo &Out,
                                              ValueToValueMapTy &VMap) {
  Function *Helper = Out.Outline;
  // Use a fast calling convention for the helper.
  Helper->setCallingConv(CallingConv::Fast);
  // Note that the address of the helper is unimportant.
  Helper->setUnnamedAddr(GlobalValue::UnnamedAddr::Global);
  // The helper is private to this module.
  Helper->setLinkage(GlobalValue::PrivateLinkage);
}

void LoopOutlineProcessor::addSyncToOutlineReturns(TapirLoopInfo &TL,
                                                   TaskOutlineInfo &Out,
                                                   ValueToValueMapTy &VMap) {
  Value *SyncRegion =
    cast<Value>(VMap[TL.getTask()->getDetach()->getSyncRegion()]);
  EscapeEnumerator EE(*Out.Outline, "ls.sync", false);
  while (IRBuilder<> *AtExit = EE.Next()) {
    // TODO: Add an option to insert syncs before resumes.
    if (!isa<ReturnInst>(*AtExit->GetInsertPoint()))
      continue;

    BasicBlock *Exit = AtExit->GetInsertBlock();
    BasicBlock *NewExit = SplitBlock(Exit, Exit->getTerminator());
    SyncInst *NewSync = SyncInst::Create(NewExit, SyncRegion);
    ReplaceInstWithInst(Exit->getTerminator(), NewSync);

    // If the helper does not throw, there's no need to insert a sync.unwind.
    if (Out.Outline->doesNotThrow())
      return;

    // Insert a call to sync.unwind.
    CallInst *SyncUnwind = CallInst::Create(
        Intrinsic::getDeclaration(&M, Intrinsic::sync_unwind),
        { SyncRegion }, "", NewExit->getFirstNonPHIOrDbg());
    // If the Tapir loop has an unwind destination, change the sync.unwind to an
    // invoke that unwinds to the cloned unwind destination.
    if (TL.getUnwindDest())
      changeToInvokeAndSplitBasicBlock(
          SyncUnwind, cast<BasicBlock>(VMap[TL.getUnwindDest()]));
  }
}

static void getDependenciesInSameBlock(Instruction *I,
                                       SmallPtrSetImpl<Instruction *> &Deps) {
  const BasicBlock *Block = I->getParent();
  for (Value *Op : I->operand_values())
    if (Instruction *OpI = dyn_cast<Instruction>(Op))
      if (OpI->getParent() == Block) {
        if (!Deps.insert(OpI).second)
          continue;
        getDependenciesInSameBlock(OpI, Deps);
      }
}

static void moveInstrumentation(StringRef Name, BasicBlock &From,
                                BasicBlock &To,
                                Instruction *InsertBefore = nullptr) {
  assert((!InsertBefore || InsertBefore->getParent() == &To) &&
         "Insert point not in To block.");
  BasicBlock::iterator InsertPoint =
      InsertBefore ? InsertBefore->getIterator() : To.getFirstInsertionPt();

  // Search the From block for instrumentation to move.
  SmallPtrSet<Instruction *, 8> ToHoist;
  for (Instruction &I : From) {
    if (CallBase *CB = dyn_cast<CallBase>(&I))
      if (const Function *Called = CB->getCalledFunction())
        if (Called->getName() == Name) {
          ToHoist.insert(&I);
          getDependenciesInSameBlock(&I, ToHoist);
        }
  }

  // If we found no instrumentation to hoist, give up.
  if (ToHoist.empty())
    return;

  // Hoist the instrumentation to InsertPoint in the To block.
  for (BasicBlock::iterator II = From.begin(), IE = From.end(); II != IE;) {
    Instruction *I = dyn_cast<Instruction>(II++);
    if (!I || !ToHoist.count(I))
      continue;

    while (isa<Instruction>(II) && ToHoist.count(cast<Instruction>(II)))
      ++II;

    To.getInstList().splice(InsertPoint, From.getInstList(), I->getIterator(),
                            II);
  }
}

void LoopOutlineProcessor::moveCilksanInstrumentation(TapirLoopInfo &TL,
                                                      TaskOutlineInfo &Out,
                                                      ValueToValueMapTy &VMap) {
  Task *T = TL.getTask();
  Loop *L = TL.getLoop();

  // Get the header of the cloned loop.
  BasicBlock *Header = cast<BasicBlock>(VMap[L->getHeader()]);
  assert(Header && "No cloned header block found");

  // Get the task entry of the cloned loop.
  BasicBlock *TaskEntry = cast<BasicBlock>(VMap[T->getEntry()]);
  assert(TaskEntry && "No cloned task-entry block found");

  // Get the latch of the cloned loop.
  BasicBlock *Latch = cast<BasicBlock>(VMap[L->getLoopLatch()]);
  assert(Latch && "No cloned loop latch found");

  // Get the normal task exit of the cloned loop.
  BasicBlock *TaskExit = Latch->getSinglePredecessor();

  // Get the preheader of the cloned loop.
  BasicBlock *Preheader = nullptr;
  for (BasicBlock *Pred : predecessors(Header)) {
    if (Latch == Pred)
      continue;
    Preheader = Pred;
    break;
  }
  if (!Preheader) {
    LLVM_DEBUG(dbgs() << "No preheader for hoisting Cilksan instrumentation\n");
    return;
  }

  // Get the normal exit of the cloned loop.
  BasicBlock *LatchExit = nullptr;
  for (BasicBlock *Succ : successors(Latch)) {
    if (Header == Succ)
      continue;
    LatchExit = Succ;
    break;
  }
  if (!LatchExit) {
    LLVM_DEBUG(
        dbgs() << "No normal exit for hoisting Cilksan instrumentation\n");
    return;
  }

  // Move __csan_detach and __csan_task to the Preheader.
  moveInstrumentation("__csan_detach", *Header, *Preheader,
                      Preheader->getTerminator());
  moveInstrumentation("__csan_task", *TaskEntry, *Preheader,
                      Preheader->getTerminator());

  // Move __csan_detach_continue and __csan_task_exit on the normal exit path to
  // LatchExit.
  moveInstrumentation("__csan_detach_continue", *Latch, *LatchExit);
  if (TaskExit)
    // There's only one block with __csan_task_exit instrumentation to move, so
    // move it from that block.
    moveInstrumentation("__csan_task_exit", *TaskExit, *LatchExit);
  else {
    // We need to create PHI nodes for the arguments of a new instrumentation
    // call in LatchExit.

    // Scan all predecessors of Latch for __csan_task_exit instrumentation.
    DenseMap<BasicBlock *, CallBase *> Instrumentation;
    Function *InstrFunc = nullptr;
    for (BasicBlock *Pred : predecessors(Latch))
      for (Instruction &I : *Pred)
        if (CallBase *CB = dyn_cast<CallBase>(&I))
          if (Function *Called = CB->getCalledFunction())
            if (Called->getName() == "__csan_task_exit") {
              Instrumentation.insert(std::make_pair(Pred, CB));
              InstrFunc = Called;
            }

    // Return early if we found no instrumentation.
    if (!InstrFunc || Instrumentation.empty()) {
      LLVM_DEBUG(dbgs() << "No task_exit instrumentation found");
      return;
    }

    // Create PHI nodes at the start of Latch for the arguments of the moved
    // instrumentation.
    SmallVector<Value *, 4> InstrArgs;
    for (BasicBlock *Pred : predecessors(Latch)) {
      CallBase *Instr = Instrumentation[Pred];
      if (InstrArgs.empty()) {
        // Create PHI nodes at the start of Latch for the instrumentation
        // arguments.
        IRBuilder<> IRB(&Latch->front());
        for (Value *Arg : Instr->args()) {
          PHINode *ArgPHI =
              IRB.CreatePHI(Arg->getType(), Instrumentation.size());
          ArgPHI->addIncoming(Arg, Pred);
          InstrArgs.push_back(ArgPHI);
        }
      } else {
        // Update the PHI nodes at the start of Latch for the instrumentation.
        unsigned ArgIdx = 0;
        for (Value *Arg : Instr->args()) {
          cast<PHINode>(InstrArgs[ArgIdx])->addIncoming(Arg, Pred);
          ++ArgIdx;
        }
      }
    }

    // Insert new instrumentation call at the start of LatchExit.
    CallInst::Create(InstrFunc->getFunctionType(), InstrFunc, InstrArgs, "",
                     &*LatchExit->getFirstInsertionPt());

    // Remove old instrumentation calls from predecessors
    for (BasicBlock *Pred : predecessors(Latch))
      Instrumentation[Pred]->eraseFromParent();
  }
}

namespace {
static void emitMissedWarning(const Loop *L, const TapirLoopHints &LH,
                              OptimizationRemarkEmitter *ORE) {
  switch (LH.getStrategy()) {
  case TapirLoopHints::ST_DAC:
    ORE->emit(DiagnosticInfoOptimizationFailure(
                  DEBUG_TYPE, "FailedRequestedSpawning",
                  L->getStartLoc(), L->getHeader())
              << "Tapir loop not transformed: "
              << "failed to use divide-and-conquer loop spawning."
              << "  Compile with -Rpass-analysis=" << LS_NAME
              << " for more details.");
    break;
  case TapirLoopHints::ST_SEQ:
    ORE->emit(DiagnosticInfoOptimizationFailure(
                  DEBUG_TYPE, "SpawningDisabled",
                  L->getStartLoc(), L->getHeader())
              << "Tapir loop not transformed: "
              << "loop-spawning transformation disabled");
    break;
  case TapirLoopHints::ST_END:
    ORE->emit(DiagnosticInfoOptimizationFailure(
                  DEBUG_TYPE, "FailedRequestedSpawning",
                  L->getStartLoc(), L->getHeader())
              << "Tapir loop not transformed: "
              << "unknown loop-spawning strategy");
    break;
  }
}

/// Process Tapir loops within the given function for loop spawning.
class LoopSpawningImpl {
public:
  LoopSpawningImpl(Function &F, DominatorTree &DT, LoopInfo &LI, TaskInfo &TI,
                   ScalarEvolution &SE, AssumptionCache &AC,
                   TargetTransformInfo &TTI, TapirTarget *Target,
                   OptimizationRemarkEmitter &ORE)
      : F(F), DT(DT), LI(LI), TI(TI), SE(SE), AC(AC), TTI(TTI), Target(Target),
        ORE(ORE) {}

  ~LoopSpawningImpl() {
    for (TapirLoopInfo *TL : TapirLoops)
      delete TL;
    TapirLoops.clear();
    TaskToTapirLoop.clear();
    LoopToTapirLoop.clear();
  }

  bool run();

  // If loop \p L defines a recorded Tapir loop, returns the Tapir loop info for
  // that Tapir loop.  Otherwise returns null.
  TapirLoopInfo *getTapirLoop(Loop *L) {
    if (!LoopToTapirLoop.count(L))
      return nullptr;
    return LoopToTapirLoop[L];
  }

  // If task \p T defines a recorded Tapir loop, returns the Tapir loop info for
  // that Tapir loop.  Otherwise returns null.
  TapirLoopInfo *getTapirLoop(Task *T) {
    if (!TaskToTapirLoop.count(T))
      return nullptr;
    return TaskToTapirLoop[T];
  }

  // Gets the Tapir loop that contains basic block \p B, i.e., the Tapir loop
  // for the loop associated with \p B.
  TapirLoopInfo *getTapirLoop(const BasicBlock *B) {
    return getTapirLoop(LI.getLoopFor(B));
  }

private:
  // Record a Tapir loop defined by loop \p L and task \p T.
  TapirLoopInfo *createTapirLoop(Loop *L, Task *T) {
    TapirLoops.push_back(new TapirLoopInfo(L, T, ORE));
    TaskToTapirLoop[T] = TapirLoops.back();
    LoopToTapirLoop[L] = TapirLoops.back();
    ++TapirLoopsFound;
    return TapirLoops.back();
  }

  // Forget the specified Tapir loop \p TL.
  void forgetTapirLoop(TapirLoopInfo *TL) {
    TaskToTapirLoop.erase(TL->getTask());
    LoopToTapirLoop.erase(TL->getLoop());
  }

  // If loop \p L is a Tapir loop, return its corresponding task.
  Task *getTaskIfTapirLoop(const Loop *L);

  // Get the LoopOutlineProcessor for handling Tapir loop \p TL.
  LoopOutlineProcessor *getOutlineProcessor(TapirLoopInfo *TL);

  using LOPMapTy = DenseMap<TapirLoopInfo *,
                            std::unique_ptr<LoopOutlineProcessor>>;

  // For all recorded Tapir loops, determine the function arguments and inputs
  // for the outlined helper functions for those loops.
  //
  // The \p LoopArgs map will store the function arguments for these outlined
  // loop helpers.  The \p LoopInputs map will store the corresponding arguments
  // for calling those outlined helpers from the parent function.  The \p
  // LoopArgStarts map will store the instruction in the parent where new code
  // for computing these outlined-helper-call arguments is first inserted.
  void getAllTapirLoopInputs(
      DenseMap<Loop *, ValueSet> &LoopInputSets,
      DenseMap<Loop *, SmallVector<Value *, 3>> &LoopCtlArgs,
      DenseMap<Loop *, SmallVector<Value *, 3>> &LoopCtlInputs);

  // Associate tasks with Tapir loops that enclose them.
  void associateTasksToTapirLoops();

  // Get the set of basic blocks within the task of Tapir loop \p TL.  The \p
  // TaskBlocks vector stores all of these basic blocks.  The \p ReattachBlocks
  // set identifies which blocks are terminated by a reattach instruction that
  // terminates the task.  The \p DetachedRethrowBlocks set identifies which
  // blocks are terminated by detached-rethrow instructions that terminate the
  // task.  Entry points to shared exception-handling code is stored in the
  // \p SharedEHEntries set.
  //
  // This method relies on being executed on the Tapir loops in a function in
  // post order.
  void getTapirLoopTaskBlocks(
      TapirLoopInfo *TL, std::vector<BasicBlock *> &TaskBlocks,
      SmallPtrSetImpl<BasicBlock *> &ReattachBlocks,
      SmallPtrSetImpl<BasicBlock *> &DetachedRethrowBlocks,
      SmallPtrSetImpl<BasicBlock *> &SharedEHEntries,
      SmallPtrSetImpl<BasicBlock *> &UnreachableExits);

  // Outline Tapir loop \p TL into a helper function.  The \p Args set specified
  // the arguments to that helper function.  The map \p VMap will store the
  // mapping of values in the original function to values in the outlined
  // helper.
  Function *createHelperForTapirLoop(TapirLoopInfo *TL, ValueSet &Args,
                                     unsigned IVArgIndex,
                                     unsigned LimitArgIndex, Module *DestM,
                                     ValueToValueMapTy &VMap,
                                     ValueToValueMapTy &InputMap);

  // Outline all recorded Tapir loops in the function.
  TaskOutlineMapTy outlineAllTapirLoops();

private:
  Function &F;

  DominatorTree &DT;
  LoopInfo &LI;
  TaskInfo &TI;
  ScalarEvolution &SE;
  AssumptionCache &AC;
  TargetTransformInfo &TTI;
  TapirTarget *Target;
  OptimizationRemarkEmitter &ORE;

  std::vector<TapirLoopInfo *> TapirLoops;
  DenseMap<Task *, TapirLoopInfo *> TaskToTapirLoop;
  DenseMap<Loop *, TapirLoopInfo *> LoopToTapirLoop;
  LOPMapTy OutlineProcessors;
};
} // end anonymous namespace

// Set up a basic unwind for a detached task:
//
// callunwind:
//   lpad = landingpad
//            catch null
//   invoke detached_rethrow(lpad), label unreachable, label detach_unwind
static BasicBlock *createTaskUnwind(Function *F, BasicBlock *UnwindDest,
                                    Value *SyncRegion, const Twine &Name = "") {
  Module *M = F->getParent();
  LLVMContext &Ctx = M->getContext();
  BasicBlock *CallUnwind = BasicBlock::Create(Ctx, Name, F);

  // Create the landing bad.
  IRBuilder<> Builder(CallUnwind);
  LandingPadInst *LPad = Builder.CreateLandingPad(
      UnwindDest->getLandingPadInst()->getType(), 0);
  LPad->setCleanup(true);
  // Create the normal return for the detached rethrow.
  BasicBlock *DRUnreachable = BasicBlock::Create(
      Ctx, CallUnwind->getName()+".unreachable", F);
  // Invoke the detached rethrow.
  Builder.CreateInvoke(
      Intrinsic::getDeclaration(M, Intrinsic::detached_rethrow,
                                { LPad->getType() }),
      DRUnreachable, UnwindDest, { SyncRegion, LPad });

  // Terminate the normal return of the detached rethrow with unreachable.
  Builder.SetInsertPoint(DRUnreachable);
  Builder.CreateUnreachable();

  return CallUnwind;
}

/// Implement the parallel loop control for a given outlined Tapir loop to
/// process loop iterations in a parallel recursive divide-and-conquer fashion.
void DACSpawning::implementDACIterSpawnOnHelper(
    TapirLoopInfo &TL, TaskOutlineInfo &Out, ValueToValueMapTy &VMap) {
  NamedRegionTimer NRT("implementDACIterSpawnOnHelper",
                       "Implement D&C spawning of loop iterations",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Task *T = TL.getTask();
  Loop *L = TL.getLoop();

  DebugLoc TLDebugLoc = cast<Instruction>(VMap[T->getDetach()])->getDebugLoc();
  Value *SyncRegion = cast<Value>(VMap[T->getDetach()->getSyncRegion()]);
  Function *Helper = Out.Outline;
  BasicBlock *Preheader = cast<BasicBlock>(VMap[L->getLoopPreheader()]);

  PHINode *PrimaryIV = cast<PHINode>(VMap[TL.getPrimaryInduction().first]);

  // Remove the norecurse attribute from Helper.
  if (Helper->doesNotRecurse())
    Helper->removeFnAttr(Attribute::NoRecurse);

  // Convert the cloned loop into the strip-mined loop body.
  assert(Preheader->getParent() == Helper &&
         "Preheader does not belong to helper function.");
  assert(PrimaryIV->getParent()->getParent() == Helper &&
         "PrimaryIV does not belong to header");

  // Get end and grainsize arguments
  Argument *End, *Grainsize;
  {
    auto OutlineArgsIter = Helper->arg_begin();
    if (Helper->hasParamAttribute(0, Attribute::StructRet))
      ++OutlineArgsIter;
    // End argument is second LC input.
    End = &*++OutlineArgsIter;
    // Grainsize argument is third LC input.
    Grainsize = &*++OutlineArgsIter;
  }

  BasicBlock *DACHead = Preheader;
  if (&(Helper->getEntryBlock()) == Preheader) {
    // Split the entry block.  We'll want to create a backedge into
    // the split block later.
    DACHead = SplitBlock(Preheader, &Preheader->front());

    // Move any syncregion_start's in DACHead into Preheader.
    BasicBlock::iterator InsertPoint = Preheader->begin();
    for (BasicBlock::iterator I = DACHead->begin(), E = DACHead->end();
         I != E;) {
      IntrinsicInst *II = dyn_cast<IntrinsicInst>(I++);
      if (!II)
        continue;
      if (Intrinsic::syncregion_start != II->getIntrinsicID())
        continue;

      while (isa<IntrinsicInst>(I) &&
             Intrinsic::syncregion_start ==
                 cast<IntrinsicInst>(I)->getIntrinsicID())
        ++I;

      Preheader->getInstList().splice(InsertPoint, DACHead->getInstList(),
                                      II->getIterator(), I);
    }

    if (!Preheader->getTerminator()->getDebugLoc())
      Preheader->getTerminator()->setDebugLoc(
          DACHead->getTerminator()->getDebugLoc());
  }

  Value *PrimaryIVInput = PrimaryIV->getIncomingValueForBlock(DACHead);
  Value *PrimaryIVInc = PrimaryIV->getIncomingValueForBlock(
      cast<BasicBlock>(VMap[L->getLoopLatch()]));

  // At this point, DACHead is the preheader to the loop and is guaranteed to
  // not be the function entry:
  //
  // DACHead:           ; preds = %entry
  //   br label Header
  //
  // From this block, we first create the skeleton of the parallel D&C loop
  // control:
  //
  // DACHead:
  //   PrimaryIVStart = phi ???
  //   IterCount = sub End, PrimaryIVStart
  //   IterCountCmp = icmp ugt IterCount, Grainsize
  //   br i1 IterCountCmp, label RecurHead, label Header
  //
  // RecurHead:
  //   br label RecurDet
  //
  // RecurDet:
  //   br label RecurCont
  //
  // RecurCont:
  //   br label DACHead
  BasicBlock *RecurHead, *RecurDet, *RecurCont;
  Value *IterCount;
  PHINode *PrimaryIVStart;
  Value *Start;
  {
    Instruction *PreheaderOrigFront = &(DACHead->front());
    IRBuilder<> Builder(PreheaderOrigFront);
    if (!Builder.getCurrentDebugLocation())
      Builder.SetCurrentDebugLocation(
          Preheader->getTerminator()->getDebugLoc());
    // Create branch based on grainsize.
    PrimaryIVStart = Builder.CreatePHI(PrimaryIV->getType(), 2,
                                       PrimaryIV->getName()+".dac");
    PrimaryIVStart->setDebugLoc(PrimaryIV->getDebugLoc());
    PrimaryIVInput->replaceAllUsesWith(PrimaryIVStart);
    Start = PrimaryIVStart;
    // Extend or truncate start, if necessary.
    if (PrimaryIVStart->getType() != End->getType())
      Start = Builder.CreateZExtOrTrunc(PrimaryIVStart, End->getType());
    IterCount = Builder.CreateSub(End, Start, "itercount");
    Value *IterCountCmp = Builder.CreateICmpUGT(IterCount, Grainsize);
    Instruction *RecurTerm =
      SplitBlockAndInsertIfThen(IterCountCmp, PreheaderOrigFront,
                                /*Unreachable=*/false,
                                /*BranchWeights=*/nullptr);
    RecurHead = RecurTerm->getParent();
    // Create RecurHead, RecurDet, and RecurCont, with appropriate branches.
    RecurDet = SplitBlock(RecurHead, RecurHead->getTerminator());
    RecurCont = SplitBlock(RecurDet, RecurDet->getTerminator());
    RecurCont->getTerminator()->replaceUsesOfWith(RecurTerm->getSuccessor(0),
                                                  DACHead);
  }

  // Compute the mid iteration in RecurHead:
  //
  // RecurHead:
  //   %halfcount = lshr IterCount, 1
  //   MidIter = add PrimaryIVStart, %halfcount
  //   br label RecurDet
  Instruction *MidIter;
  {
    IRBuilder<> Builder(&(RecurHead->front()));
    Value *HalfCount = Builder.CreateLShr(IterCount, 1, "halfcount");
    MidIter = cast<Instruction>(Builder.CreateAdd(Start, HalfCount, "miditer"));
    // Copy flags from the increment operation on the primary IV.
    MidIter->copyIRFlags(PrimaryIVInc);
  }

  // Create a recursive call in RecurDet.  If the call cannot throw, then
  // RecurDet becomes:
  //
  // RecurDet:
  //   call Helper(..., PrimaryIVStart, MidIter, ...)
  //   br label RecurCont
  //
  // Otherwise an a new unwind destination, CallUnwind, is created or the
  // invoke, and RecurDet becomes:
  //
  // RecurDet:
  //   invoke Helper(..., PrimaryIVStart, MidIter, ...)
  //     to label CallDest unwind label CallUnwind
  //
  // CallDest:
  //   br label RecurCont
  BasicBlock *RecurCallDest = RecurDet;
  BasicBlock *UnwindDest = nullptr;
  if (TL.getUnwindDest())
    UnwindDest = cast<BasicBlock>(VMap[TL.getUnwindDest()]);
  {
    // Create input array for recursive call.
    IRBuilder<> Builder(&(RecurDet->front()));
    SmallVector<Value *, 8> RecurCallInputs;
    for (Value &V : Helper->args()) {
      // Only the inputs for the start and end iterations need special care.
      // All other inputs should match the arguments of Helper.
      if (&V == PrimaryIVInput)
        RecurCallInputs.push_back(PrimaryIVStart);
      else if (&V == End)
        RecurCallInputs.push_back(MidIter);
      else
        RecurCallInputs.push_back(&V);
    }

    if (!UnwindDest) {
      // Common case.  Insert a call to the outline immediately before the detach.
      CallInst *RecurCall;
      // Create call instruction.
      RecurCall = Builder.CreateCall(Helper, RecurCallInputs);
      // Use a fast calling convention for the outline.
      RecurCall->setCallingConv(CallingConv::Fast);
      RecurCall->setDebugLoc(TLDebugLoc);
      if (Helper->doesNotThrow())
        RecurCall->setDoesNotThrow();
    } else {
      InvokeInst *RecurCall;
      BasicBlock *CallDest = SplitBlock(RecurDet, RecurDet->getTerminator());
      BasicBlock *CallUnwind =
        createTaskUnwind(Helper, UnwindDest, SyncRegion,
                         RecurDet->getName()+".unwind");
      RecurCall = InvokeInst::Create(Helper, CallDest, CallUnwind,
                                     RecurCallInputs);
      // Use a fast calling convention for the outline.
      RecurCall->setCallingConv(CallingConv::Fast);
      RecurCall->setDebugLoc(TLDebugLoc);
      ReplaceInstWithInst(RecurDet->getTerminator(), RecurCall);
      RecurCallDest = CallDest;
    }
  }

  // Set up continuation of detached recursive call to compute the next loop
  // iteration to execute.  For inclusive ranges, this means adding one to
  // MidIter:
  //
  // RecurCont:
  //   MidIterPlusOne = add MidIter, 1
  //   br label DACHead
  Instruction *NextIter = MidIter;
  if (TL.isInclusiveRange()) {
    IRBuilder<> Builder(&(RecurCont->front()));
    NextIter = cast<Instruction>(
        Builder.CreateAdd(MidIter, ConstantInt::get(End->getType(), 1),
                          "miditerplusone"));
    // Copy flags from the increment operation on the primary IV.
    NextIter->copyIRFlags(PrimaryIVInc);
    // Extend or truncate NextIter, if necessary
    if (PrimaryIVStart->getType() != NextIter->getType())
      NextIter = cast<Instruction>(
          Builder.CreateZExtOrTrunc(NextIter, PrimaryIVStart->getType()));
  } else if (PrimaryIVStart->getType() != NextIter->getType()) {
    IRBuilder<> Builder(&(RecurCont->front()));
    NextIter = cast<Instruction>(
        Builder.CreateZExtOrTrunc(NextIter, PrimaryIVStart->getType()));
  }

  // Finish the phi node in DACHead.
  //
  // DACHead:
  //   PrimaryIVStart = phi [ PrimaryIVInput, %entry ], [ NextIter, RecurCont ]
  //   ...
  PrimaryIVStart->addIncoming(PrimaryIVInput, Preheader);
  PrimaryIVStart->addIncoming(NextIter, RecurCont);

  // Make the recursive DAC call parallel.
  //
  // RecurHead:
  //   detach within SyncRegion, label RecurDet, label RecurCont
  //     (unwind label DetachUnwind)
  //
  // RecurDet:
  //   call Helper(...)
  //   reattach label RecurCont
  //
  // or
  //
  // RecurDet:
  //   invoke Helper(...) to CallDest unwind UnwindDest
  //
  // CallDest:
  //   reattach label RecurCont
  {
    IRBuilder<> Builder(RecurHead->getTerminator());
    // Create the detach.
    DetachInst *NewDI;
    if (!UnwindDest)
      NewDI = Builder.CreateDetach(RecurDet, RecurCont, SyncRegion);
    else
      NewDI = Builder.CreateDetach(RecurDet, RecurCont, UnwindDest,
                                   SyncRegion);
    NewDI->setDebugLoc(TLDebugLoc);
    RecurHead->getTerminator()->eraseFromParent();

    // Create the reattach.
    Builder.SetInsertPoint(RecurCallDest->getTerminator());
    ReattachInst *RI = Builder.CreateReattach(RecurCont, SyncRegion);
    RI->setDebugLoc(TLDebugLoc);
    RecurCallDest->getTerminator()->eraseFromParent();
  }
}

/// Examine a given loop to determine if its a Tapir loop that can and should be
/// processed.  Returns the Task that encodes the loop body if so, or nullptr if
/// not.
Task *LoopSpawningImpl::getTaskIfTapirLoop(const Loop *L) {
  NamedRegionTimer NRT("getTaskIfTapirLoop",
                       "Check if loop is a Tapir loop to process",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);

  LLVM_DEBUG(dbgs() << "Analyzing for spawning: " << *L);

  TapirLoopHints Hints(L);

  // Loop must have a preheader.  LoopSimplify should guarantee that the loop
  // preheader is not terminated by a sync.
  const BasicBlock *Preheader = L->getLoopPreheader();
  if (!Preheader) {
    LLVM_DEBUG(dbgs() << "Loop lacks a preheader.\n");
    if (hintsDemandOutlining(Hints)) {
      ORE.emit(TapirLoopInfo::createMissedAnalysis(LS_NAME, "NoPreheader", L)
               << "loop lacks a preheader");
      emitMissedWarning(L, Hints, &ORE);
    }
    return nullptr;
  } else if (!isa<BranchInst>(Preheader->getTerminator())) {
    LLVM_DEBUG(dbgs() << "Loop preheader is not terminated by a branch.\n");
    if (hintsDemandOutlining(Hints)) {
      ORE.emit(TapirLoopInfo::createMissedAnalysis(LS_NAME, "ComplexPreheader",
                                                   L)
               << "loop preheader not terminated by a branch");
      emitMissedWarning(L, Hints, &ORE);
    }
    return nullptr;
  }

  // Get the task for this loop if it is a Tapir loop.
  Task *T = llvm::getTaskIfTapirLoop(L, &TI);
  if (!T) {
    LLVM_DEBUG(dbgs() << "Loop does not match structure of Tapir loop.\n");
    if (hintsDemandOutlining(Hints)) {
      ORE.emit(TapirLoopInfo::createMissedAnalysis(LS_NAME, "NonCanonicalLoop",
                                                   L)
               << "loop does not have the canonical structure of a Tapir loop");
      emitMissedWarning(L, Hints, &ORE);
    }
    return nullptr;
  }

  return T;
}

/// Get the LoopOutlineProcessor for handling Tapir loop \p TL.
LoopOutlineProcessor *LoopSpawningImpl::getOutlineProcessor(TapirLoopInfo *TL) {
  NamedRegionTimer NRT("getOutlineProcessor",
                       "Get a loop-outline processor for a Tapir loop",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);

  // Allow the Tapir target to define a custom loop-outline processor.
  if (LoopOutlineProcessor *TargetLOP = Target->getLoopOutlineProcessor(TL))
    return TargetLOP;

  Module &M = *F.getParent();
  Loop *L = TL->getLoop();
  TapirLoopHints Hints(L);

  switch (Hints.getStrategy()) {
  case TapirLoopHints::ST_DAC: return new DACSpawning(M);
  default: return new DefaultLoopOutlineProcessor(M);
  }
}

/// Associate tasks with Tapir loops that enclose them.
void LoopSpawningImpl::associateTasksToTapirLoops() {
  NamedRegionTimer NRT("associateTasksToTapirLoops",
                       "Associate tasks to Tapir loops",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);

  SmallVector<Task *, 4> UnassocTasks;
  // Traverse the tasks in post order, queueing up tasks that are not roots of
  // Tapir loops.
  for (Task *T : post_order(TI.getRootTask())) {
    TapirLoopInfo *TL = getTapirLoop(T);
    if (!TL) {
      UnassocTasks.push_back(T);
      continue;
    }

    // When we find a Task T at the root of a Tapir loop TL, associate
    // previously traversed tasks that are enclosed in T with TL.
    while (!UnassocTasks.empty()) {
      Task *UT = UnassocTasks.back();
      if (!TI.encloses(T, UT))
        break;
      TL->addDescendantTask(UT);
      UnassocTasks.pop_back();
    }
  }
}

// Helper test to see if the given basic block is the placeholder normal
// destination of a detached.rethrow or taskframe.resume intrinsic.
static bool isUnreachablePlaceholder(const BasicBlock *B) {
  for (const BasicBlock *Pred : predecessors(B)) {
    if (!isDetachedRethrow(Pred->getTerminator()) &&
        !isTaskFrameResume(Pred->getTerminator()))
      return false;
    if (B != cast<InvokeInst>(Pred->getTerminator())->getNormalDest())
      return false;
  }
  return true;
}

/// Get the set of basic blocks within the task of Tapir loop \p TL.  The \p
/// TaskBlocks vector stores all of these basic blocks.  The \p ReattachBlocks
/// set identifies which blocks are terminated by a reattach instruction that
/// terminates the task.  The \p DetachedRethrowBlocks set identifies which
/// blocks are terminated by detached-rethrow instructions that terminate the
/// task.  Entry points to shared exception-handling code is stored in the
/// \p SharedEHEntries set.
///
/// This method relies on being executed on the Tapir loops in a function in
/// post order.
void LoopSpawningImpl::getTapirLoopTaskBlocks(
    TapirLoopInfo *TL, std::vector<BasicBlock *> &TaskBlocks,
    SmallPtrSetImpl<BasicBlock *> &ReattachBlocks,
    SmallPtrSetImpl<BasicBlock *> &DetachedRethrowBlocks,
    SmallPtrSetImpl<BasicBlock *> &SharedEHEntries,
    SmallPtrSetImpl<BasicBlock *> &UnreachableExits) {
  NamedRegionTimer NRT("getTapirLoopTaskBlocks",
                       "Get basic blocks for Tapir loop",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);

  Task *T = TL->getTask();
  SmallVector<Task *, 4> EnclosedTasks;
  TL->getEnclosedTasks(EnclosedTasks);
  SmallPtrSet<Spindle *, 4> VisitedSharedEH;

  // Get the header and loop-latch blocks of all Tapir subloops.
  SmallPtrSet<BasicBlock *, 4> SubloopControlToExclude;
  for (Task *EncT : EnclosedTasks) {
    for (Task *SubT : EncT->subtasks()) {
      if (TapirLoopInfo *SubTL = getTapirLoop(SubT)) {
        SubloopControlToExclude.insert(SubTL->getLoop()->getHeader());
        SubloopControlToExclude.insert(SubTL->getLoop()->getLoopLatch());
        // Mark the unwind destination of this subloop's detach as a
        // "SharedEHEntry," meaning it needs its Phi nodes updated after
        // cloning.
        DetachInst *SubDI =
          cast<DetachInst>(SubTL->getLoop()->getHeader()->getTerminator());
        if (SubDI->hasUnwindDest())
          SharedEHEntries.insert(SubDI->getUnwindDest());
      }
    }
  }

  for (Task *EncT : EnclosedTasks) {
    for (Spindle *S : depth_first<InTask<Spindle *>>(EncT->getEntrySpindle())) {
      // Record the entry blocks of any shared-EH spindles.
      if (S->isSharedEH()) {
        SharedEHEntries.insert(S->getEntry());
        if (!VisitedSharedEH.insert(S).second)
          continue;
      }

      bool TopLevelTaskSpindle = T->contains(S) || T->isSharedEHExit(S);
      for (BasicBlock *B : S->blocks()) {
        // Don't clone header and loop-latch blocks for Tapir subloops.
        if (SubloopControlToExclude.count(B))
          continue;

        // Skip basic blocks that are successors of detached rethrows in T.
        // They're dead anyway.
        if (TopLevelTaskSpindle && isSuccessorOfDetachedRethrow(B))
          continue;

        // Skip unreachable placeholder blocks, namely, the normal destinations
        // of detached.rethrow and taskframe.resume instructions.
        if (isUnreachablePlaceholder(B))
          continue;

        LLVM_DEBUG(dbgs() << "Adding block " << B->getName() << "\n");
        TaskBlocks.push_back(B);

        if (TopLevelTaskSpindle) {
          // Record the blocks terminated by reattaches and detached rethrows.
          if (isa<ReattachInst>(B->getTerminator()))
            ReattachBlocks.insert(B);
          if (isDetachedRethrow(B->getTerminator()))
            DetachedRethrowBlocks.insert(B);
          if (isTaskFrameResume(B->getTerminator()))
            UnreachableExits.insert(
                cast<InvokeInst>(B->getTerminator())->getNormalDest());
        } else if (isDetachedRethrow(B->getTerminator()) ||
                   isTaskFrameResume(B->getTerminator())) {
          UnreachableExits.insert(
              cast<InvokeInst>(B->getTerminator())->getNormalDest());
        }
      }
    }
  }
}

/// Compute the grainsize of the loop, based on the limit.  Currently this
/// routine injects a call to the tapir_loop_grainsize intrinsic, which is
/// handled in a target-specific way by subsequent lowering passes.
static Value *computeGrainsize(TapirLoopInfo *TL) {
  Value *TripCount = TL->getTripCount();
  assert(TripCount &&
         "No trip count found for computing grainsize of Tapir loop.");
  Type *IdxTy = TripCount->getType();
  BasicBlock *Preheader = TL->getLoop()->getLoopPreheader();
  Module *M = Preheader->getModule();
  IRBuilder<> B(Preheader->getTerminator());
  B.SetCurrentDebugLocation(TL->getDebugLoc());
  return B.CreateCall(
      Intrinsic::getDeclaration(M, Intrinsic::tapir_loop_grainsize,
                                { IdxTy }), { TripCount });
}

/// Get the grainsize of this loop either from metadata or by computing the
/// grainsize.
static Value *getGrainsizeVal(TapirLoopInfo *TL) {
  Value *GrainVal;
  if (unsigned Grainsize = TL->getGrainsize())
    GrainVal = ConstantInt::get(TL->getTripCount()->getType(), Grainsize);
  else
    GrainVal = computeGrainsize(TL);

  LLVM_DEBUG(dbgs() << "Grainsize value: " << *GrainVal << "\n");
  return GrainVal;
}

/// Determine the inputs to Tapir loop \p TL for the loop control.
static void getLoopControlInputs(TapirLoopInfo *TL,
                                 SmallVectorImpl<Value *> &LCArgs,
                                 SmallVectorImpl<Value *> &LCInputs) {
  // Add an argument for the primary induction variable.
  auto &PrimaryInduction = TL->getPrimaryInduction();
  PHINode *PrimaryPhi = PrimaryInduction.first;
  TL->StartIterArg = new Argument(PrimaryPhi->getType(),
                                  PrimaryPhi->getName() + ".start");
  LCArgs.push_back(TL->StartIterArg);
  LCInputs.push_back(PrimaryInduction.second.getStartValue());

  // Add an argument for the trip count.
  Value *TripCount = TL->getTripCount();
  assert(TripCount && "No trip count found for Tapir loop end argument.");
  TL->EndIterArg = new Argument(TripCount->getType(), "end");
  LCArgs.push_back(TL->EndIterArg);
  LCInputs.push_back(TripCount);

  // Add an argument for the grainsize.
  Value *GrainsizeVal = getGrainsizeVal(TL);
  TL->GrainsizeArg = new Argument(GrainsizeVal->getType(), "grainsize");
  LCArgs.push_back(TL->GrainsizeArg);
  LCInputs.push_back(GrainsizeVal);

  assert(TL->getInductionVars()->size() == 1 &&
         "Induction vars to process for arguments.");
  // // Add arguments for the other IV's.
  // for (auto &InductionEntry : *TL->getInductionVars()) {
  //   PHINode *Phi = InductionEntry.first;
  //   InductionDescriptor II = InductionEntry.second;
  //   if (Phi == PrimaryInduction.first) continue;
  //   LCArgs.push_back(new Argument(Phi->getType(),
  //                                 Phi->getName() + ".start"));
  //   LCInputs.push_back(II.getStartValue());
  // }
}

/// For all recorded Tapir loops, determine the function arguments and inputs
/// for the outlined helper functions for those loops.
///
/// The \p LoopArgs map will store the function arguments for these outlined
/// loop helpers.  The \p LoopInputs map will store the corresponding arguments
/// for calling those outlined helpers from the parent function.  The \p
/// LoopArgStarts map will store the instruction in the parent where new code
/// for computing these outlined-helper-call arguments is first inserted.
void LoopSpawningImpl::getAllTapirLoopInputs(
    DenseMap<Loop *, ValueSet> &LoopInputSets,
    DenseMap<Loop *, SmallVector<Value *, 3>> &LoopCtlArgs,
    DenseMap<Loop *, SmallVector<Value *, 3>> &LoopCtlInputs) {
  NamedRegionTimer NRT("getAllTapirLoopInputs",
                       "Determine inputs for all Tapir loops",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);

  // Determine the inputs for all tasks.
  TaskValueSetMap TaskInputs = findAllTaskInputs(F, DT, TI);

  // Combine these sets of inputs to determine inputs for each Tapir loop.
  DenseMap<Loop *, ValueSet> TapirLoopInputs;
  for (Task *T : post_order(TI.getRootTask())) {
    if (TapirLoopInfo *TL = getTapirLoop(T)) {
      Loop *L = TL->getLoop();

      // Convert inputs for task T to Tapir-loop inputs.
      ValueSet TLInputs = getTapirLoopInputs(TL, TaskInputs[T]);
      LoopInputSets[L] = TLInputs;
      LLVM_DEBUG({
          dbgs() << "TLInputs\n";
          for (Value *V : TLInputs)
            dbgs() << "\t" << *V << "\n";
        });

      // Determine loop-control inputs.
      getLoopControlInputs(TL, LoopCtlArgs[L], LoopCtlInputs[L]);

      LLVM_DEBUG({
          dbgs() << "LoopCtlArgs:\n";
          for (Value *V : LoopCtlArgs[L])
            dbgs() << "\t" << *V << "\n";
          dbgs() << "LoopCtlInputs:\n";
          for (Value *V : LoopCtlInputs[L])
            dbgs() << "\t" << *V << "\n";
        });
    }
  }
}

static void updateClonedIVs(
    TapirLoopInfo *TL, BasicBlock *OrigPreheader,
    ValueSet &Args, ValueToValueMapTy &VMap, unsigned IVArgIndex,
    unsigned NextIVArgOffset = 3) {
  NamedRegionTimer NRT("updateClonedIVs", "Updated IVs in Tapir-loop helper",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);

  auto &PrimaryInduction = TL->getPrimaryInduction();
  PHINode *PrimaryPhi = PrimaryInduction.first;

  Value *PrimaryArg = Args[IVArgIndex];

  // TODO: This assertion implies that the following loop should only run once,
  // for the primary induction variable.  However, the loop is provided in case
  // we decide to handle more complicated sets of induction variables in the
  // future.
  assert(TL->getInductionVars()->size() == 1 &&
         "updateClonedIVs to process multiple inductions.");

  // Get the next argument that provides an input to an IV, which is typically 3
  // after the input for the primary induction variable, after the end-teration
  // and grainsize arguments.
  unsigned ArgIdx = IVArgIndex + NextIVArgOffset;
  for (auto &InductionEntry : *TL->getInductionVars()) {
    PHINode *OrigPhi = InductionEntry.first;
    InductionDescriptor II = InductionEntry.second;
    assert(II.getKind() == InductionDescriptor::IK_IntInduction &&
           "Non-integer induction found.");
    assert((II.getConstIntStepValue()->isOne() ||
            II.getConstIntStepValue()->isMinusOne()) &&
           "Non-canonical induction found: non-unit step.");
    assert(isa<Constant>(II.getStartValue()) &&
           "Non-canonical induction found: non-constant start.");
    assert(cast<Constant>(II.getStartValue())->isNullValue() &&
           "Non-canonical induction found: non-zero start.");

    // Get the remapped PHI node and preheader
    PHINode *NewPhi = cast<PHINode>(VMap[OrigPhi]);
    BasicBlock *NewPreheader = cast<BasicBlock>(VMap[OrigPreheader]);

    // Replace the input for the remapped PHI node from the preheader with the
    // input argument.
    unsigned BBIdx = NewPhi->getBasicBlockIndex(NewPreheader);
    if (OrigPhi == PrimaryPhi)
      NewPhi->setIncomingValue(BBIdx, VMap[PrimaryArg]);
    else
      // TODO: Because of the assertion above, this line should never run.
      NewPhi->setIncomingValue(BBIdx, VMap[Args[ArgIdx++]]);
  }
}

namespace {
// ValueMaterializer to manage remapping uses of the tripcount in the helper
// function for the loop, when the only uses of tripcount occur in the condition
// for the loop backedge and, possibly, in metadata.
class ArgEndMaterializer final : public OutlineMaterializer {
private:
  Value *TripCount;
  Value *ArgEnd;
public:
  ArgEndMaterializer(const Instruction *SrcSyncRegion, Value *TripCount,
                     Value *ArgEnd)
      : OutlineMaterializer(SrcSyncRegion), TripCount(TripCount),
        ArgEnd(ArgEnd) {}

  Value *materialize(Value *V) final {
    // If we're materializing metadata for TripCount, materialize empty metadata
    // instead.
    if (auto *MDV = dyn_cast<MetadataAsValue>(V)) {
      Metadata *MD = MDV->getMetadata();
      if (auto *LAM = dyn_cast<LocalAsMetadata>(MD))
        if (LAM->getValue() == TripCount)
          return MetadataAsValue::get(V->getContext(),
                                      MDTuple::get(V->getContext(), None));
    }

    // Materialize TripCount with ArgEnd.  This should only occur in the loop
    // latch, and we'll overwrite the use of ArgEnd later.
    if (V == TripCount)
      return ArgEnd;

    // Otherwise go with the default behavior.
    return OutlineMaterializer::materialize(V);
  }
};
}

/// Outline Tapir loop \p TL into a helper function.  The \p Args set specified
/// the arguments to that helper function.  The map \p VMap will store the
/// mapping of values in the original function to values in the outlined helper.
Function *LoopSpawningImpl::createHelperForTapirLoop(
    TapirLoopInfo *TL, ValueSet &Args, unsigned IVArgIndex,
    unsigned LimitArgIndex, Module *DestM, ValueToValueMapTy &VMap,
    ValueToValueMapTy &InputMap) {
  Task *T = TL->getTask();
  Loop *L = TL->getLoop();
  BasicBlock *Header = L->getHeader();
  BasicBlock *Preheader = L->getLoopPreheader();

  // Collect all basic blocks in the Tapir loop.
  std::vector<BasicBlock *> TLBlocks;
  TLBlocks.push_back(L->getHeader());
  // Entry blocks of shared-EH spindles may contain PHI nodes that need to be
  // rewritten in the cloned helper.
  SmallPtrSet<BasicBlock *, 4> SharedEHEntries;
  SmallPtrSet<BasicBlock *, 4> DetachedRethrowBlocks;
  SmallPtrSet<BasicBlock *, 4> UnreachableExits;
  // Reattach instructions and detached rethrows in this task might need special
  // handling.
  SmallPtrSet<BasicBlock *, 4> ReattachBlocks;
  getTapirLoopTaskBlocks(TL, TLBlocks, ReattachBlocks, DetachedRethrowBlocks,
                         SharedEHEntries, UnreachableExits);
  TLBlocks.push_back(L->getLoopLatch());

  DetachInst *DI = T->getDetach();
  const Instruction *InputSyncRegion =
      dyn_cast<Instruction>(DI->getSyncRegion());

  OutlineMaterializer *Mat = nullptr;
  if (!isa<Constant>(TL->getTripCount()) && !Args.count(TL->getTripCount()))
    // Create an ArgEndMaterializer to handle uses of TL->getTripCount().
    Mat = new ArgEndMaterializer(InputSyncRegion, TL->getTripCount(),
                                 Args[LimitArgIndex]);
  else
    Mat = new OutlineMaterializer(InputSyncRegion);

  Twine NameSuffix = ".ls" + Twine(TL->getLoop()->getLoopDepth());
  SmallVector<ReturnInst *, 4> Returns;  // Ignore returns cloned.
  ValueSet Outputs;  // Outputs must be empty.
  Function *Helper;
  {
    NamedRegionTimer NRT("CreateHelper", "Create helper for Tapir loop",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    Helper = CreateHelper(
        Args, Outputs, TLBlocks, Header, Preheader, TL->getExitBlock(), VMap,
        DestM, F.getSubprogram() != nullptr, Returns, NameSuffix.str(), nullptr,
        &DetachedRethrowBlocks, &SharedEHEntries, TL->getUnwindDest(),
        &UnreachableExits, nullptr, nullptr, nullptr, Mat);
  } // end timed region

  assert(Returns.empty() && "Returns cloned when cloning detached CFG.");
  // If the Tapir loop has no unwind destination, then the outlined function
  // cannot throw.
  if (F.doesNotThrow() && !TL->getUnwindDest())
    Helper->setDoesNotThrow();
  // Don't inherit the noreturn attribute from the caller.
  if (F.doesNotReturn())
    Helper->removeFnAttr(Attribute::NoReturn);

  // Update cloned loop condition to use the end-iteration argument.
  unsigned TripCountIdx = 0;
  Value *TripCount = TL->getTripCount();
  if (InputMap[TripCount])
    TripCount = InputMap[TripCount];
  if (TL->getCondition()->getOperand(0) != TripCount)
    ++TripCountIdx;
  assert(TL->getCondition()->getOperand(TripCountIdx) == TripCount &&
         "Trip count not used in condition");
  ICmpInst *ClonedCond = cast<ICmpInst>(VMap[TL->getCondition()]);
  ClonedCond->setOperand(TripCountIdx, VMap[Args[LimitArgIndex]]);

  // If the trip count is variable and we're not passing the trip count as an
  // argument, undo the eariler temporarily mapping.
  if (!isa<Constant>(TL->getTripCount()) && !Args.count(TL->getTripCount())) {
    VMap.erase(TL->getTripCount());
    // Delete the ArgEndMaterializer.
    delete Mat;
  }

  // Rewrite cloned IV's to start at their start-iteration arguments.
  updateClonedIVs(TL, Preheader, Args, VMap, IVArgIndex);

  // Add alignment assumptions to arguments of helper, based on alignment of
  // values in old function.
  {
  NamedRegionTimer NRT("AddAlignmentAssumptions",
                       "Add alignment assumptions to Tapir-loop helper",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  AddAlignmentAssumptions(&F, Args, VMap, Preheader->getTerminator(), &AC, &DT);
  } // end timed region

  // CreateHelper partially serializes the cloned copy of the loop by converting
  // detached-rethrows into resumes.  We now finish the job of serializing the
  // cloned Tapir loop.

  // Move allocas in the newly cloned detached CFG to the entry block of the
  // helper.
  {
    NamedRegionTimer NRT("updateAllocas", "Update allocas in Tapir-loop helper",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    // Collect the end instructions of the task.
    SmallVector<Instruction *, 4> TaskEnds;
    for (BasicBlock *EndBlock : ReattachBlocks)
      TaskEnds.push_back(cast<BasicBlock>(VMap[EndBlock])->getTerminator());
    for (BasicBlock *EndBlock : DetachedRethrowBlocks)
      TaskEnds.push_back(cast<BasicBlock>(VMap[EndBlock])->getTerminator());

    // Move allocas in cloned detached block to entry of helper function.
    BasicBlock *ClonedTaskEntry = cast<BasicBlock>(VMap[T->getEntry()]);
    bool ContainsDynamicAllocas = MoveStaticAllocasInBlock(
        &Helper->getEntryBlock(), ClonedTaskEntry, TaskEnds);

    // If this task uses a taskframe, move allocas in cloned taskframe entry to
    // entry of helper function.
    if (Spindle *TFCreate = T->getTaskFrameCreateSpindle()) {
      BasicBlock *ClonedTFEntry = cast<BasicBlock>(VMap[TFCreate->getEntry()]);
      ContainsDynamicAllocas |= MoveStaticAllocasInBlock(
          &Helper->getEntryBlock(), ClonedTFEntry, TaskEnds);
    }
    // If the cloned loop contained dynamic alloca instructions, wrap the cloned
    // loop with llvm.stacksave/llvm.stackrestore intrinsics.
    if (ContainsDynamicAllocas) {
      Module *M = Helper->getParent();
      // Get the two intrinsics we care about.
      Function *StackSave = Intrinsic::getDeclaration(M, Intrinsic::stacksave);
      Function *StackRestore =
          Intrinsic::getDeclaration(M, Intrinsic::stackrestore);

      // Insert the llvm.stacksave.
      CallInst *SavedPtr =
          IRBuilder<>(&*ClonedTaskEntry, ClonedTaskEntry->begin())
              .CreateCall(StackSave, {}, "savedstack");

      // Insert a call to llvm.stackrestore before the reattaches in the
      // original Tapir loop.
      for (Instruction *ExitPoint : TaskEnds)
        IRBuilder<>(ExitPoint).CreateCall(StackRestore, SavedPtr);
    }
  }

  // Convert the cloned detach and reattaches into unconditional branches.
  {
  NamedRegionTimer NRT("serializeClonedLoop", "Serialize cloned Tapir loop",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  DetachInst *ClonedDI = cast<DetachInst>(VMap[DI]);
  BasicBlock *ClonedDetacher = ClonedDI->getParent();
  BasicBlock *ClonedContinue = ClonedDI->getContinue();
  for (BasicBlock *RB : ReattachBlocks) {
    ReattachInst *ClonedRI = cast<ReattachInst>(VMap[RB->getTerminator()]);
    ReplaceInstWithInst(ClonedRI, BranchInst::Create(ClonedContinue));
  }
  ClonedContinue->removePredecessor(ClonedDetacher);
  BranchInst *DetachRepl = BranchInst::Create(ClonedDI->getDetached());
  ReplaceInstWithInst(ClonedDI, DetachRepl);
  VMap[DI] = DetachRepl;
  } // end timed region

  return Helper;
}

/// Outline all recorded Tapir loops in the function.
TaskOutlineMapTy LoopSpawningImpl::outlineAllTapirLoops() {
  // Prepare Tapir loops for outlining.
  for (Task *T : post_order(TI.getRootTask())) {
    if (TapirLoopInfo *TL = getTapirLoop(T)) {
      PredicatedScalarEvolution PSE(SE, *TL->getLoop());
      bool canOutline = TL->prepareForOutlining(DT, LI, TI, PSE, AC, LS_NAME,
                                                ORE, TTI);
      if (!canOutline) {
        const Loop *L = TL->getLoop();
        TapirLoopHints Hints(L);
        emitMissedWarning(L, Hints, &ORE);
        forgetTapirLoop(TL);
        continue;
      }

      // Get an outline processor for each Tapir loop.
      OutlineProcessors[TL] =
        std::unique_ptr<LoopOutlineProcessor>(getOutlineProcessor(TL));
    }
  }

  TaskOutlineMapTy TaskToOutline;
  DenseMap<Loop *, ValueSet> LoopInputSets;
  DenseMap<Loop *, SmallVector<Value *, 3>> LoopCtlArgs;
  DenseMap<Loop *, SmallVector<Value *, 3>> LoopCtlInputs;

  DenseMap<Loop *, ValueSet> LoopArgs;
  DenseMap<Loop *, SmallVector<Value *, 1>> LoopInputs;
  DenseMap<Loop *, Instruction *> LoopArgStarts;

  getAllTapirLoopInputs(LoopInputSets, LoopCtlArgs, LoopCtlInputs);

  associateTasksToTapirLoops();

  for (Task *T : post_order(TI.getRootTask())) {
    LLVM_DEBUG(dbgs() << "Examining task@" << T->getEntry()->getName() <<
               " for outlining\n");
    // If any subtasks were outlined as Tapir loops, replace these loops with
    // calls to the outlined functions.
    {
    NamedRegionTimer NRT("replaceSubLoopCalls",
                         "Update sub-Tapir-loops with calls to helpers",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    for (Task *SubT : T->subtasks()) {
      if (TapirLoopInfo *TL = getTapirLoop(SubT)) {
        // emitSCEVChecks(TL->getLoop(), TL->getBypass());
        Loop *L = TL->getLoop();
        TaskToOutline[SubT].replaceReplCall(
            replaceLoopWithCallToOutline(TL, TaskToOutline[SubT], LoopInputs[L]));
      }
    }
    } // end timed region

    TapirLoopInfo *TL = getTapirLoop(T);
    if (!TL)
      continue;

    Loop *L = TL->getLoop();
    LLVM_DEBUG(dbgs() << "Outlining Tapir " << *L << "\n");

    // Convert the inputs of the Tapir loop to inputs to the helper.
    ValueSet TLInputsFixed;
    ValueToValueMapTy InputMap;
    Instruction *ArgStart;
    {
    NamedRegionTimer NRT("fixupHelperInputs",
                         "Fixup inputs to Tapir-loop body",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    ArgStart =
        fixupHelperInputs(F, T, LoopInputSets[L], TLInputsFixed,
                          L->getLoopPreheader()->getTerminator(),
                          &*L->getHeader()->getFirstInsertionPt(),
                          OutlineProcessors[TL]->getArgStructMode(), InputMap,
                          L);
    } // end timed region

    ValueSet HelperArgs;
    SmallVector<Value *, 8> HelperInputs;
    {
    NamedRegionTimer NRT("setupLoopOutlineArgs",
                         "Setup inputs to Tapir-loop helper function",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    OutlineProcessors[TL]->setupLoopOutlineArgs(
        F, HelperArgs, HelperInputs, LoopInputSets[L], LoopCtlArgs[L],
        LoopCtlInputs[L], TLInputsFixed);
    } // end timed region

    LLVM_DEBUG({
        dbgs() << "HelperArgs:\n";
        for (Value *V : HelperArgs)
          dbgs() << "\t" << *V << "\n";
        dbgs() << "HelperInputs:\n";
        for (Value *V : HelperInputs)
          dbgs() << "\t" << *V << "\n";
      });

    LoopArgs[L] = HelperArgs;
    for (Value *V : HelperInputs)
      LoopInputs[L].push_back(V);
    LoopArgStarts[L] = ArgStart;

    ValueToValueMapTy VMap;
    // Create the helper function.
    Function *Outline = createHelperForTapirLoop(
        TL, LoopArgs[L], OutlineProcessors[TL]->getIVArgIndex(F, LoopArgs[L]),
        OutlineProcessors[TL]->getLimitArgIndex(F, LoopArgs[L]),
        &OutlineProcessors[TL]->getDestinationModule(), VMap, InputMap);
    TaskToOutline[T] = TaskOutlineInfo(
        Outline, T->getEntry(), cast<Instruction>(VMap[T->getDetach()]),
        dyn_cast_or_null<Instruction>(VMap[T->getTaskFrameUsed()]),
        LoopInputSets[L], LoopArgStarts[L],
        L->getLoopPreheader()->getTerminator(), TL->getExitBlock(),
        TL->getUnwindDest());

    // Do ABI-dependent processing of each outlined Tapir loop.
    {
    NamedRegionTimer NRT("postProcessOutline",
                         "Post-process Tapir-loop helper function",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    OutlineProcessors[TL]->postProcessOutline(*TL, TaskToOutline[T], VMap);
    } // end timed region

    LLVM_DEBUG({
        dbgs() << "LoopInputs[L]:\n";
        for (Value *V : LoopInputs[L])
          dbgs() << "\t" << *V << "\n";
      });

    {
      NamedRegionTimer NRT("clearMetadata", "Cleanup Tapir-loop metadata",
                           TimerGroupName, TimerGroupDescription,
                           TimePassesIsEnabled);
      TapirLoopHints Hints(L);
      Hints.clearClonedLoopMetadata(VMap);
      Hints.clearStrategy();
    }

    // Update subtask outline info to reflect the fact that their spawner was
    // outlined.
    {
      NamedRegionTimer NRT("remapData", "Remap Tapir subloop information",
                           TimerGroupName, TimerGroupDescription,
                           TimePassesIsEnabled);
      LLVM_DEBUG(dbgs() << "Remapping subloop outline info.\n");
      for (Loop *SubL : *L) {
        if (TapirLoopInfo *SubTL = getTapirLoop(SubL)) {
          Task *SubT = SubTL->getTask();
          if (TaskToOutline.count(SubT)) {
            TaskToOutline[SubT].remapOutlineInfo(VMap, InputMap);
            OutlineProcessors[SubTL]->remapData(VMap);
          }
        }
      }
    }
  }

  return TaskToOutline;
}

bool LoopSpawningImpl::run() {
  if (TI.isSerial())
    return false;

  // Discover all Tapir loops and record them.
  for (Loop *TopLevelLoop : LI)
    for (Loop *L : post_order(TopLevelLoop))
      if (Task *T = getTaskIfTapirLoop(L))
        createTapirLoop(L, T);

  if (TapirLoops.empty())
    return false;

  // Perform any Target-dependent preprocessing of F.
  Target->preProcessFunction(F, TI, true);

  // Outline all Tapir loops.
  TaskOutlineMapTy TapirLoopOutlines = outlineAllTapirLoops();

  // Perform target-specific processing of the outlined-loop calls.
  {
  NamedRegionTimer NRT("processOutlinedLoopCall",
                       "Process calls to outlined loops",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  for (Task *T : post_order(TI.getRootTask()))
    if (TapirLoopInfo *TL = getTapirLoop(T))
      OutlineProcessors[TL]->processOutlinedLoopCall(*TL, TapirLoopOutlines[T],
                                                     DT);
  } // end timed region

  // Perform any Target-dependent postprocessing of F.
  Target->postProcessFunction(F, true);

  LLVM_DEBUG({
    NamedRegionTimer NRT("verify", "Post-loop-spawning verification",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    if (verifyModule(*F.getParent(), &errs())) {
      LLVM_DEBUG(dbgs() << "Module after loop spawning:" << *F.getParent());
      llvm_unreachable("Loop spawning produced bad IR!");
    }
  });

  return true;
}

PreservedAnalyses LoopSpawningPass::run(Module &M, ModuleAnalysisManager &AM) {
  auto &FAM = AM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  auto GetDT = [&FAM](Function &F) -> DominatorTree & {
    return FAM.getResult<DominatorTreeAnalysis>(F);
  };
  auto GetLI = [&FAM](Function &F) -> LoopInfo & {
    return FAM.getResult<LoopAnalysis>(F);
  };
  auto GetTI = [&FAM](Function &F) -> TaskInfo & {
    return FAM.getResult<TaskAnalysis>(F);
  };
  auto GetSE = [&FAM](Function &F) -> ScalarEvolution & {
    return FAM.getResult<ScalarEvolutionAnalysis>(F);
  };
  auto GetAC = [&FAM](Function &F) -> AssumptionCache & {
    return FAM.getResult<AssumptionAnalysis>(F);
  };
  auto GetTTI = [&FAM](Function &F) -> TargetTransformInfo & {
    return FAM.getResult<TargetIRAnalysis>(F);
  };
  auto GetTLI = [&FAM](Function &F) -> TargetLibraryInfo & {
    return FAM.getResult<TargetLibraryAnalysis>(F);
  };
  auto GetORE = [&FAM](Function &F) -> OptimizationRemarkEmitter & {
    return FAM.getResult<OptimizationRemarkEmitterAnalysis>(F);
  };

  SmallVector<Function *, 8> WorkList;
  bool Changed = false;
  for (Function &F : M)
    if (!F.empty())
      WorkList.push_back(&F);

  // Transform all loops into simplified, LCSSA form before we process them.
  for (Function *F : WorkList) {
    LoopInfo &LI = GetLI(*F);
    DominatorTree &DT = GetDT(*F);
    ScalarEvolution &SE = GetSE(*F);
    SmallVector<Loop *, 8> LoopWorkList;
    for (Loop *L : LI) {
      Changed |= simplifyLoop(L, &DT, &LI, &SE, &GetAC(*F), nullptr,
                              /* PreserveLCSSA */ false);
      LoopWorkList.push_back(L);
    }
    for (Loop *L : LoopWorkList)
      Changed |= formLCSSARecursively(*L, DT, &LI, &SE);
  }

  // Now process each loop.
  for (Function *F : WorkList) {
    TapirTargetID TargetID = GetTLI(*F).getTapirTarget();
    std::unique_ptr<TapirTarget> Target(getTapirTargetFromID(M, TargetID));
    Changed |= LoopSpawningImpl(*F, GetDT(*F), GetLI(*F), GetTI(*F), GetSE(*F),
                                GetAC(*F), GetTTI(*F), Target.get(), GetORE(*F))
                   .run();
  }
  if (Changed)
    return PreservedAnalyses::none();
  return PreservedAnalyses::all();
}

namespace {
// NB: Technicaly LoopSpawningTI should be a ModulePass, because it changes the
// contents of the module.  But because a ModulePass cannot use many function
// analyses -- doing so results in invalid memory accesses -- we have to make
// LoopSpawningTI a FunctionPass.  This problem is fixed with the new pass
// manager.
struct LoopSpawningTI : public FunctionPass {
  /// Pass identification, replacement for typeid
  static char ID;
  explicit LoopSpawningTI() : FunctionPass(ID) {
    initializeLoopSpawningTIPass(*PassRegistry::getPassRegistry());
  }

  bool runOnFunction(Function &F) override {
    if (skipFunction(F))
      return false;
    Module &M = *F.getParent();

    auto &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
    auto &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    auto &TI = getAnalysis<TaskInfoWrapperPass>().getTaskInfo();
    auto &SE = getAnalysis<ScalarEvolutionWrapperPass>().getSE();
    auto &AC = getAnalysis<AssumptionCacheTracker>().getAssumptionCache(F);
    auto &TLI = getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);
    TapirTargetID TargetID = TLI.getTapirTarget();
    auto &TTI = getAnalysis<TargetTransformInfoWrapperPass>().getTTI(F);
    auto &ORE = getAnalysis<OptimizationRemarkEmitterWrapperPass>().getORE();

    LLVM_DEBUG(dbgs() << "LoopSpawningTI on function " << F.getName() << "\n");
    TapirTarget *Target = getTapirTargetFromID(M, TargetID);
    bool Changed =
        LoopSpawningImpl(F, DT, LI, TI, SE, AC, TTI, Target, ORE).run();
    delete Target;
    return Changed;
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AssumptionCacheTracker>();
    AU.addRequiredID(LoopSimplifyID);
    AU.addRequiredID(LCSSAID);
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addRequired<ScalarEvolutionWrapperPass>();
    AU.addRequired<TargetTransformInfoWrapperPass>();
    AU.addRequired<TargetLibraryInfoWrapperPass>();
    AU.addRequired<TaskInfoWrapperPass>();
    AU.addRequired<OptimizationRemarkEmitterWrapperPass>();
  }
};
}

char LoopSpawningTI::ID = 0;
static const char ls_name[] = "Loop Spawning with Task Info";
INITIALIZE_PASS_BEGIN(LoopSpawningTI, LS_NAME, ls_name, false, false)
INITIALIZE_PASS_DEPENDENCY(AssumptionCacheTracker)
INITIALIZE_PASS_DEPENDENCY(LoopSimplify)
INITIALIZE_PASS_DEPENDENCY(LCSSAWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(ScalarEvolutionWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetLibraryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetTransformInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TaskInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(OptimizationRemarkEmitterWrapperPass)
INITIALIZE_PASS_END(LoopSpawningTI, LS_NAME, ls_name, false, false)

namespace llvm {
Pass *createLoopSpawningTIPass() {
  return new LoopSpawningTI();
}
}
