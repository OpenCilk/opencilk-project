//===- LoweringUtils.cpp - Utility functions for lowering Tapir -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements several utility functions for lowering Tapir.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/Timer.h"
#include "llvm/Transforms/Tapir/CilkABI.h"
#include "llvm/Transforms/Tapir/CilkRABI.h"
#include "llvm/Transforms/Tapir/CudaABI.h"
#include "llvm/Transforms/Tapir/OpenMPABI.h"
#include "llvm/Transforms/Tapir/Outline.h"
#include "llvm/Transforms/Tapir/QthreadsABI.h"
#include "llvm/Transforms/Tapir/SerialABI.h"
#include "llvm/Transforms/Tapir/TapirLoopInfo.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "tapirlowering"

static const char TimerGroupName[] = DEBUG_TYPE;
static const char TimerGroupDescription[] = "Tapir lowering";

TapirTarget *llvm::getTapirTargetFromID(Module &M, TapirTargetID ID) {
  switch (ID) {
  case TapirTargetID::None:
    return nullptr;
  case TapirTargetID::Serial:
    return new SerialABI(M);
  case TapirTargetID::Cilk:
    return new CilkABI(M);
  case TapirTargetID::CilkR:
  case TapirTargetID::Cheetah:
    return new CilkRABI(M);
  case TapirTargetID::Cuda:
    return new CudaABI(M);
  case TapirTargetID::OpenMP:
    return new OpenMPABI(M);
  case TapirTargetID::Qthreads:
    return new QthreadsABI(M);
  default:
    llvm_unreachable("Invalid TapirTargetID");
  }
}

//----------------------------------------------------------------------------//
// Lowering utilities for Tapir tasks.

/// Returns true if the value \p V is defined outside the set \p Blocks of basic
/// blocks in a function.
static bool definedOutsideBlocks(const Value *V,
                                 SmallPtrSetImpl<BasicBlock *> &Blocks) {
  if (isa<Argument>(V)) return true;
  if (const Instruction *I = dyn_cast<Instruction>(V))
    return !Blocks.count(I->getParent());
  return false;
}

/// Helper function to find the inputs and outputs to task T, based only the
/// blocks in T and no subtask of T.
static void
findTaskInputsOutputs(const Task *T, ValueSet &Inputs, ValueSet &Outputs,
                      const DominatorTree &DT) {
  NamedRegionTimer NRT("findTaskInputsOutputs", "Find task inputs and outputs",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  // Get the sync region for this task's detach, so we can filter it out of
  // this inputs.
  const Value *SyncRegion = nullptr;
  SmallPtrSet<BasicBlock *, 8> UnwindPHIs;
  if (DetachInst *DI = T->getDetach()) {
    SyncRegion = DI->getSyncRegion();
    // Get the PHI nodes that directly or indirectly use the landing pad of the
    // unwind destination of this task's detach.
    getDetachUnwindPHIUses(DI, UnwindPHIs);
  }

  for (Spindle *S : depth_first<InTask<Spindle *>>(T->getEntrySpindle())) {
    LLVM_DEBUG(dbgs() <<
               "Examining spindle for inputs/outputs: " << *S << "\n");
    for (BasicBlock *BB : S->blocks()) {
      // Skip basic blocks that are successors of detached rethrows.  They're
      // dead anyway.
      if (isSuccessorOfDetachedRethrow(BB))
        continue;

      // If a used value is defined outside the region, it's an input.  If an
      // instruction is used outside the region, it's an output.
      for (Instruction &II : *BB) {
        // Examine all operands of this instruction.
        for (User::op_iterator OI = II.op_begin(), OE = II.op_end(); OI != OE;
             ++OI) {
          // PHI nodes in the entry block of a shared-EH exit will be
          // rewritten in any cloned helper, so we skip operands of these PHI
          // nodes for blocks not in this task.
          if (S->isSharedEH() && S->isEntry(BB))
            if (PHINode *PN = dyn_cast<PHINode>(&II)) {
              LLVM_DEBUG(dbgs() <<
                         "\tPHI node in shared-EH spindle: " << *PN << "\n");
              if (!T->simplyEncloses(PN->getIncomingBlock(*OI))) {
                LLVM_DEBUG(dbgs() << "skipping\n");
                continue;
              }
            }
          // If the operand is the sync region of this task's detach, skip it.
          if (SyncRegion == *OI)
            continue;
          // If this operand is defined in the parent, it's an input.
          if (T->definedInParent(*OI))
            Inputs.insert(*OI);
        }
        // Examine all uses of this instruction
        for (User *U : II.users()) {
          // If we find a live use outside of the task, it's an output.
          if (Instruction *I = dyn_cast<Instruction>(U)) {
            // Skip uses in PHI nodes that depend on the unwind landing pad of
            // the detach.
            if (UnwindPHIs.count(I->getParent()))
              continue;
            if (!T->encloses(I->getParent()) &&
                DT.isReachableFromEntry(I->getParent()))
              Outputs.insert(&II);
          }
        }
      }
    }
  }
}

/// Determine the inputs for all tasks in this function.  Returns a map from
/// tasks to their inputs.
///
/// Aggregating all of this work into a single routine allows us to avoid
/// redundant traversals of basic blocks in nested tasks.
TaskValueSetMap llvm::findAllTaskInputs(Function &F, const DominatorTree &DT,
                                        const TaskInfo &TI) {
  TaskValueSetMap TaskInputs;
  for (Task *T : post_order(TI.getRootTask())) {
    // Skip the root task
    if (T->isRootTask()) break;

    LLVM_DEBUG(dbgs() << "Finding inputs/outputs for task @ "
          << T->getEntry()->getName() << "\n");
    ValueSet Inputs, Outputs;
    // Check all inputs of subtasks to determine if they're inputs to this task.
    for (Task *SubT : T->subtasks()) {
      LLVM_DEBUG(dbgs() <<
                 "\tsubtask @ " << SubT->getEntry()->getName() << "\n");

      if (TaskInputs.count(SubT))
        for (Value *V : TaskInputs[SubT])
          if (T->definedInParent(V))
            Inputs.insert(V);
    }

    LLVM_DEBUG({
        dbgs() << "Subtask Inputs:\n";
        for (Value *V : Inputs)
          dbgs() << "\t" << *V << "\n";
        dbgs() << "Subtask Outputs:\n";
        for (Value *V : Outputs)
          dbgs() << "\t" << *V << "\n";
      });
    assert(Outputs.empty() && "Task should have no outputs.");

    // Find additional inputs and outputs of task T by examining blocks in T and
    // not in any subtask of T.
    findTaskInputsOutputs(T, Inputs, Outputs, DT);

    LLVM_DEBUG({
        dbgs() << "Inputs:\n";
        for (Value *V : Inputs)
          dbgs() << "\t" << *V << "\n";
        dbgs() << "Outputs:\n";
        for (Value *V : Outputs)
          dbgs() << "\t" << *V << "\n";
      });
    assert(Outputs.empty() && "Task should have no outputs.");

    // Map the computed inputs to this task.
    TaskInputs[T] = Inputs;
  }
  return TaskInputs;
}

// Helper function to check if a value is defined outside of a given spindle.
static bool taskInputDefinedOutsideTaskFrame(
    const Value *V, const SpindleSet &TFSpindles,// ValueSet &TaskFrameInputs,
    const TaskInfo &TI) {
  // Arguments are always defined outside of spindles.
  if (isa<Argument>(V))
    return true;

  // If we have no taskframe spindles, return true.
  if (TFSpindles.empty()) {
    LLVM_DEBUG(dbgs() << "LoweringUtils: No taskframe spindles to check\n");
    return true;
  }

  // If V is an instruction, check if Spindle contains it.
  if (const Instruction *I = dyn_cast<Instruction>(V))
    return !TFSpindles.count(TI.getSpindleFor(I->getParent()));

  return true;
}

/// Get the set of inputs for the given task T, accounting for the taskframe of
/// T, if it exists.
void llvm::getTaskFrameInputsOutputs(ValueSet &TFInputs, ValueSet &TFOutputs,
                                     const Task &T, const ValueSet &TaskInputs,
                                     const SpindleSet &TFSpindles,
                                     const TaskInfo &TI,
                                     const DominatorTree &DT) {
  LLVM_DEBUG(dbgs() << "getTaskFrameInputsOutputs: task@"
             << T.getEntry()->getName() << "\n");
  // Check the taskframe spindles.
  for (Value *V : TaskInputs)
    if (taskInputDefinedOutsideTaskFrame(V, TFSpindles, TI))
      TFInputs.insert(V);

  // Get the set of basic blocks in the taskframe spindles.
  SmallPtrSet<BasicBlock *, 1> BlocksToCheck;
  for (Spindle *S : TFSpindles)
    for (BasicBlock *BB : S->blocks()) {
      LLVM_DEBUG(dbgs() << "Adding block to check: " << BB->getName() << "\n");
      BlocksToCheck.insert(BB);
    }

  // Get inputs and outputs and outputs of the taskframe.
  for (BasicBlock *BB : BlocksToCheck) {
    for (Instruction &I : *BB) {
      // Ignore certain instructions from consideration: the taskframe.create
      // intrinsic for this taskframe, the detach instruction that spawns T, and
      // the landingpad value in T's EH continuation.
      if ((T.getTaskFrameUsed() == &I) || (T.getDetach() == &I) ||
          (T.getLPadValueInEHContinuationSpindle() == &I))
        continue;

      // Examine all operands of this instruction
      for (User::op_iterator OI = I.op_begin(), OE = I.op_end(); OI != OE;
           ++OI) {
        LLVM_DEBUG({
            if (Instruction *OP = dyn_cast<Instruction>(*OI))
              assert(!T.encloses(OP->getParent()) &&
                     "TaskFrame uses value defined in task.");
          });
        // If this operand is not defined in one of the blocks to check, then
        // it's an input.
        if (definedOutsideBlocks(*OI, BlocksToCheck))
          TFInputs.insert(*OI);
      }
      // Examine all users of this instruction.
      for (User *U : I.users()) {
        // If we find a live use outside of the task, it's an output.
        if (Instruction *UI = dyn_cast<Instruction>(U)) {
          if (!T.encloses(UI->getParent()) &&
              !BlocksToCheck.count(UI->getParent()) &&
              DT.isReachableFromEntry(UI->getParent()))
            TFOutputs.insert(&I);
        }
      }
    }
  }
}

/// Determine the inputs for all tasks in this function.  Returns a map from
/// tasks to their inputs.
///
/// Aggregating all of this work into a single routine allows us to avoid
/// redundant traversals of basic blocks in nested tasks.
void llvm::findAllTaskFrameInputs(
    TaskValueSetMap &TFInputs, TaskValueSetMap &TFOutputs, Function &F,
    const DominatorTree &DT, TaskInfo &TI) {
  // Determine the inputs for all tasks.
  TaskValueSetMap TaskInputs = findAllTaskInputs(F, DT, TI);

  for (Task *T : post_order(TI.getRootTask())) {
    // Collects spindles in the taskframe for task T.
    SpindleSet TFSpindles;
    Spindle *TFUsed = TI.getTaskFrameSpindleFor(T);
    if (TFUsed)
      for (Spindle *S : TFUsed->taskframe_spindles())
        TFSpindles.insert(S);

    // Update the inputs to account for the taskframe.
    getTaskFrameInputsOutputs(TFInputs[T], TFOutputs[T], *T, TaskInputs[T],
                              TFSpindles, TI, DT);
  }
}

/// Create a structure for storing all arguments to a task.
///
/// NOTE: This function inserts the struct for task arguments in the same
/// location as the Reference compiler and other compilers that lower parallel
/// constructs in the front end.  This location is NOT the correct place,
/// however, for handling tasks that are spawned inside of a serial loop.
std::pair<AllocaInst *, Instruction *>
llvm::createTaskArgsStruct(const ValueSet &Inputs, Task *T,
                           Instruction *StorePt, Instruction *LoadPt,
                           bool staticStruct, ValueToValueMapTy &InputsMap,
                           Loop *TapirL) {
  assert(T && T->getParentTask() && "Expected spawned task.");
  assert((T->encloses(LoadPt->getParent()) ||
          (TapirL && LoadPt->getParent() == TapirL->getHeader())) &&
         "Loads of struct arguments must be inside task.");
  assert(!T->encloses(StorePt->getParent()) &&
         "Store of struct arguments must be outside task.");
  assert(T->getParentTask()->encloses(StorePt->getParent()) &&
         "Store of struct arguments expected to be in parent task.");
  SmallVector<Value *, 8> InputsToSort;
  {
    for (Value *V : Inputs)
      InputsToSort.push_back(V);
    Function *F = T->getEntry()->getParent();
    const DataLayout &DL = F->getParent()->getDataLayout();
    std::sort(InputsToSort.begin(), InputsToSort.end(),
              [&DL](const Value *A, const Value *B) {
                return DL.getTypeSizeInBits(A->getType()) >
                  DL.getTypeSizeInBits(B->getType());
              });
  }

  // Get vector of struct inputs and their types.
  SmallVector<Value *, 8> StructInputs;
  SmallVector<Type *, 8> StructIT;
  for (Value *V : InputsToSort) {
    StructInputs.push_back(V);
    StructIT.push_back(V->getType());
  }

  // Create an alloca for this struct in the parent task's entry block.
  Instruction *ArgsStart = StorePt;
  IRBuilder<> B(StorePt);
  // TODO: Add lifetime intrinsics for this allocation.
  AllocaInst *Closure;
  StructType *ST = StructType::get(T->getEntry()->getContext(), StructIT);
  LLVM_DEBUG(dbgs() << "Closure struct type " << *ST << "\n");
  if (staticStruct) {
    BasicBlock *AllocaInsertBlk = T->getParentTask()->getEntry();
    IRBuilder<> Builder(&*AllocaInsertBlk->getFirstInsertionPt());
    Closure = Builder.CreateAlloca(ST);
    // Store arguments into the structure
    if (!StructInputs.empty())
      ArgsStart = B.CreateStore(StructInputs[0],
                                B.CreateConstGEP2_32(ST, Closure, 0, 0));
    for (unsigned i = 1; i < StructInputs.size(); ++i)
      B.CreateStore(StructInputs[i], B.CreateConstGEP2_32(ST, Closure, 0, i));
  } else {
    // Add code to store values into struct immediately before detach.
    Closure = B.CreateAlloca(ST);
    ArgsStart = Closure;
    // Store arguments into the structure
    for (unsigned i = 0; i < StructInputs.size(); ++i)
      B.CreateStore(StructInputs[i], B.CreateConstGEP2_32(ST, Closure, 0, i));
  }

  // Add code to load values from struct in task entry and use those loaded
  // values.
  IRBuilder<> B2(LoadPt);
  for (unsigned i = 0; i < StructInputs.size(); ++i) {
    auto STGEP = cast<Instruction>(B2.CreateConstGEP2_32(ST, Closure, 0, i));
    auto STLoad = B2.CreateLoad(STGEP);
    InputsMap[StructInputs[i]] = STLoad;

    // Update all uses of the struct inputs in the loop body.
    auto UI = StructInputs[i]->use_begin(), E = StructInputs[i]->use_end();
    for (; UI != E;) {
      Use &U = *UI;
      ++UI;
      auto *Usr = dyn_cast<Instruction>(U.getUser());
      if (!Usr)
        continue;
      if ((!T->encloses(Usr->getParent()) &&
           (!TapirL || (Usr->getParent() != TapirL->getHeader() &&
                        Usr->getParent() != TapirL->getLoopLatch()))))
        continue;
      U.set(STLoad);
    }
  }

  return std::make_pair(Closure, ArgsStart);
}

/// Organize the set \p Inputs of values in \p F into a set \p Fixed of values
/// that can be used as inputs to a helper function.
void llvm::fixupInputSet(Function &F, const ValueSet &Inputs, ValueSet &Fixed) {
  // Scan for any sret parameters in TaskInputs and add them first.  These
  // parameters must appear first or second in the prototype of the Helper
  // function.
  Value *SRetInput = nullptr;
  if (F.hasStructRetAttr()) {
    Function::arg_iterator ArgIter = F.arg_begin();
    if (F.hasParamAttribute(0, Attribute::StructRet))
      if (Inputs.count(&*ArgIter))
        SRetInput = &*ArgIter;
    if (F.hasParamAttribute(1, Attribute::StructRet)) {
      ++ArgIter;
      if (Inputs.count(&*ArgIter))
        SRetInput = &*ArgIter;
    }
  }
  if (SRetInput) {
    LLVM_DEBUG(dbgs() << "sret input " << *SRetInput << "\n");
    Fixed.insert(SRetInput);
  }

  // Sort the inputs to the task with largest arguments first, in order to
  // improve packing or arguments in memory.
  SmallVector<Value *, 8> InputsToSort;
  for (Value *V : Inputs)
    if (V != SRetInput)
      InputsToSort.push_back(V);
  LLVM_DEBUG({
      dbgs() << "After sorting:\n";
      for (Value *V : InputsToSort)
        dbgs() << "\t" << *V << "\n";
    });
  const DataLayout &DL = F.getParent()->getDataLayout();
  std::sort(InputsToSort.begin(), InputsToSort.end(),
            [&DL](const Value *A, const Value *B) {
              return DL.getTypeSizeInBits(A->getType()) >
                DL.getTypeSizeInBits(B->getType());
            });

  // Add the remaining inputs.
  for (Value *V : InputsToSort)
    if (!Fixed.count(V))
      Fixed.insert(V);
}

/// Organize the inputs to task \p T, given in \p TaskInputs, to create an
/// appropriate set of inputs, \p HelperInputs, to pass to the outlined
/// function for \p T.
Instruction *llvm::fixupHelperInputs(
    Function &F, Task *T, ValueSet &TaskInputs, ValueSet &HelperArgs,
    Instruction *StorePt, Instruction *LoadPt,
    TapirTarget::ArgStructMode useArgStruct,
    ValueToValueMapTy &InputsMap, Loop *TapirL) {
  if (TapirTarget::ArgStructMode::None != useArgStruct) {
    std::pair<AllocaInst *, Instruction *> ArgsStructInfo =
      createTaskArgsStruct(TaskInputs, T, StorePt, LoadPt,
                           TapirTarget::ArgStructMode::Static == useArgStruct,
                           InputsMap, TapirL);
    HelperArgs.insert(ArgsStructInfo.first);
    return ArgsStructInfo.second;
  }

  fixupInputSet(F, TaskInputs, HelperArgs);
  return StorePt;
}

/// Returns true if BasicBlock \p B is the immediate successor of only
/// detached-rethrow instructions.
bool llvm::isSuccessorOfDetachedRethrow(const BasicBlock *B) {
  for (const BasicBlock *Pred : predecessors(B))
    if (!isDetachedRethrow(Pred->getTerminator()))
      return false;
  return true;
}

/// Collect the set of blocks in task \p T.  All blocks enclosed by \p T will be
/// pushed onto \p TaskBlocks.  The set of blocks terminated by reattaches from
/// \p T are added to \p ReattachBlocks.  The set of blocks terminated by
/// detached-rethrow instructions are added to \p DetachedRethrowBlocks.  The
/// set of entry points to exception-handling blocks shared by \p T and other
/// tasks in the same function are added to \p SharedEHEntries.
void llvm::getTaskBlocks(Task *T, std::vector<BasicBlock *> &TaskBlocks,
                         SmallPtrSetImpl<BasicBlock *> &ReattachBlocks,
                         SmallPtrSetImpl<BasicBlock *> &DetachedRethrowBlocks,
                         SmallPtrSetImpl<BasicBlock *> &SharedEHEntries) {
  NamedRegionTimer NRT("getTaskBlocks", "Get task blocks", TimerGroupName,
                       TimerGroupDescription, TimePassesIsEnabled);
  SmallPtrSet<Spindle *, 8> SpindlesToExclude;
  for (Spindle *TFSpindle : T->taskframe_creates())
    for (Spindle *S : TFSpindle->taskframe_spindles())
      SpindlesToExclude.insert(S);

  // Add taskframe-spindle blocks.
  if (Spindle *TFCreateSpindle = T->getTaskFrameCreateSpindle()) {
    for (Spindle *S : TFCreateSpindle->taskframe_spindles()) {
      assert(!SpindlesToExclude.count(S) &&
             "Taskframe spindle marked for exclusion.");
      if (T->getEHContinuationSpindle() == S)
        SharedEHEntries.insert(S->getEntry());

      for (BasicBlock *B : S->blocks()) {
        LLVM_DEBUG(dbgs() << "Adding task block " << B->getName() << "\n");
        TaskBlocks.push_back(B);

        // TODO: Rename DetachedRethrowBlocks.
        if (isTaskFrameResume(B->getTerminator()))
          DetachedRethrowBlocks.insert(B);
      }
    }
  }

  // Add the spindles in the task proper.
  for (Spindle *S : depth_first<InTask<Spindle *>>(T->getEntrySpindle())) {
    if (SpindlesToExclude.count(S))
      continue;

    // Record the entry blocks of any shared-EH spindles.
    if (S->isSharedEH())
      SharedEHEntries.insert(S->getEntry());

    for (BasicBlock *B : S->blocks()) {
      // Skip basic blocks that are successors of detached rethrows.  They're
      // dead anyway.
      if (isSuccessorOfDetachedRethrow(B))
        continue;

      LLVM_DEBUG(dbgs() << "Adding task block " << B->getName() << "\n");
      TaskBlocks.push_back(B);

      // Record the blocks terminated by reattaches and detached rethrows.
      if (isa<ReattachInst>(B->getTerminator()))
        ReattachBlocks.insert(B);
      if (isDetachedRethrow(B->getTerminator()))
        DetachedRethrowBlocks.insert(B);
    }
  }
}

/// Outlines the content of task \p T in function \p F into a new helper
/// function.  The parameter \p Inputs specified the inputs to the helper
/// function.  The map \p VMap is updated with the mapping of instructions in
/// \p T to instructions in the new helper function.
Function *llvm::createHelperForTask(
    Function &F, Task *T, ValueSet &Args, Module *DestM,
    ValueToValueMapTy &VMap, Type *ReturnType, AssumptionCache *AC,
    DominatorTree *DT) {
  // Collect all basic blocks in this task.
  std::vector<BasicBlock *> TaskBlocks;
  // Reattach instructions and detached rethrows in this task might need special
  // handling.
  SmallPtrSet<BasicBlock *, 4> ReattachBlocks;
  SmallPtrSet<BasicBlock *, 4> DetachedRethrowBlocks;
  // Entry blocks of shared-EH spindles may contain PHI nodes that need to be
  // rewritten in the cloned helper.
  SmallPtrSet<BasicBlock *, 4> SharedEHEntries;
  getTaskBlocks(T, TaskBlocks, ReattachBlocks, DetachedRethrowBlocks,
                SharedEHEntries);

  SmallVector<ReturnInst *, 4> Returns;  // Ignore returns cloned.
  ValueSet Outputs;
  DetachInst *DI = T->getDetach();

  BasicBlock *Header = T->getEntry();
  BasicBlock *Entry = DI->getParent();
  if (Spindle *TaskFrameCreate = T->getTaskFrameCreateSpindle()) {
    Header = TaskFrameCreate->getEntry();
    Entry = Header->getSinglePredecessor();
  }

  Twine NameSuffix = ".otd" + Twine(T->getTaskDepth());
  Function *Helper;
  {
  NamedRegionTimer NRT("CreateHelper", "Create helper function",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Helper =
    CreateHelper(Args, Outputs, TaskBlocks, Header,Entry, DI->getContinue(),
                 VMap, DestM, F.getSubprogram() != nullptr, Returns,
                 NameSuffix.str(), DT &ReattachBlocks,
                 &DetachedRethrowBlocks, &SharedEHEntries, nullptr,
                 dyn_cast<Instruction>(DI->getSyncRegion()), ReturnType,
                 nullptr, nullptr, nullptr);
  }
  assert(Returns.empty() && "Returns cloned when cloning detached CFG.");

  // Add alignment assumptions to arguments of helper, based on alignment of
  // values in old function.
  AddAlignmentAssumptions(&F, Args, VMap, DI, AC, DT);

  // Move allocas in the newly cloned detached CFG to the entry block of the
  // helper.
  {
    NamedRegionTimer NRT("MoveAllocas", "Move allocas in cloned helper",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    // Collect the end instructions of the task.
    SmallVector<Instruction *, 4> TaskEnds;
    for (BasicBlock *EndBlock : ReattachBlocks)
      TaskEnds.push_back(cast<BasicBlock>(VMap[EndBlock])->getTerminator());
    for (BasicBlock *EndBlock : DetachedRethrowBlocks)
      TaskEnds.push_back(cast<BasicBlock>(VMap[EndBlock])->getTerminator());

    // Move allocas in cloned detached block to entry of helper function.
    BasicBlock *ClonedDetachedBlock = cast<BasicBlock>(VMap[T->getEntry()]);
    MoveStaticAllocasInBlock(&Helper->getEntryBlock(), ClonedDetachedBlock,
                             TaskEnds);

    // We do not need to add new llvm.stacksave/llvm.stackrestore intrinsics,
    // because calling and returning from the helper will automatically manage
    // the stack appropriately.
  }

  if (VMap[DI]) {
    // Convert the cloned detach into an unconditional branch.
    NamedRegionTimer NRT("serializeClone", "Serialize cloned Tapir task",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    DetachInst *ClonedDI = cast<DetachInst>(VMap[DI]);
    BasicBlock *ClonedDetacher = ClonedDI->getParent();
    BasicBlock *ClonedContinue = ClonedDI->getContinue();
    ClonedContinue->removePredecessor(ClonedDetacher);
    BranchInst *DetachRepl = BranchInst::Create(ClonedDI->getDetached());
    ReplaceInstWithInst(ClonedDI, DetachRepl);
    VMap[DI] = DetachRepl;
  }

  return Helper;
}

/// Helper function to unlink task T's exception-handling blocks from T's
/// parent.
static void unlinkTaskEHFromParent(Task *T) {
  DetachInst *DI = T->getDetach();

  // Get the PHI's that use the landing pad of the detach's unwind.
  SmallPtrSet<BasicBlock *, 8> UnwindPHIs;
  getDetachUnwindPHIUses(DI, UnwindPHIs);

  SmallVector<Instruction *, 8> ToRemove;
  // Look through PHI's that use the landing pad of the detach's unwind, and
  // update those PHI's to not refer to task T.
  for (BasicBlock *BB : UnwindPHIs) {
    for (BasicBlock *Pred : predecessors(BB)) {
      // Ignore the shared-EH spindles in T, because those might be used by
      // other subtasks of T's parent.  The shared-EH spindles tracked by T's
      // parent will be handled once all subtasks of T's parent have been
      // processed.
      if (T->simplyEncloses(Pred) && !T->encloses(BB) &&
          T->getParentTask()->encloses(BB)) {
        // Update the PHI nodes in BB.
        BB->removePredecessor(Pred);
        // Remove the edge from Pred to BB.
        IRBuilder<> B(Pred->getTerminator());
        Instruction *Unreach = B.CreateUnreachable();
        Unreach->setDebugLoc(Pred->getTerminator()->getDebugLoc());
        ToRemove.push_back(Pred->getTerminator());
      }
    }
  }

  // Remove the terminators we no longer need.
  for (Instruction *I : ToRemove)
    I->eraseFromParent();
}

/// Replaces the detach instruction that spawns task \p T, with associated
/// TaskOutlineInfo \p Out, with a call or invoke to the outlined helper function
/// created for \p T.
Instruction *llvm::replaceDetachWithCallToOutline(
    Task *T, TaskOutlineInfo &Out, SmallVectorImpl<Value *> &OutlineInputs) {
  // Remove any dependencies from T's exception-handling code to T's parent.
  unlinkTaskEHFromParent(T);

  Instruction *ToReplace = Out.ReplCall;

  // Add call to new helper function in original function.
  if (!Out.ReplUnwind) {
    // Common case.  Insert a call to the outline immediately before the detach.
    CallInst *TopCall;
    // Create call instruction.
    IRBuilder<> Builder(Out.ReplCall);
    TopCall = Builder.CreateCall(Out.Outline, OutlineInputs);
    // Use a fast calling convention for the outline.
    TopCall->setCallingConv(Out.Outline->getCallingConv());
    TopCall->setDebugLoc(ToReplace->getDebugLoc());
    if (Out.Outline->doesNotThrow())
      TopCall->setDoesNotThrow();
    // Replace the detach with an unconditional branch to its continuation.
    ReplaceInstWithInst(ToReplace, BranchInst::Create(Out.ReplRet));
    return TopCall;
  } else {
    // The detach might catch an exception from the task.  Replace the detach
    // with an invoke of the outline.
    InvokeInst *TopCall;
    // Create invoke instruction.  The ordinary return of the invoke is the
    // detach's continuation, and the unwind return is the detach's unwind.
    TopCall = InvokeInst::Create(Out.Outline, Out.ReplRet, Out.ReplUnwind,
                                 OutlineInputs, "", ToReplace->getParent());
    // Use a fast calling convention for the outline.
    TopCall->setCallingConv(Out.Outline->getCallingConv());
    TopCall->setDebugLoc(ToReplace->getDebugLoc());
    // Remove the detach.  The invoke serves as a replacement terminator.
    ToReplace->eraseFromParent();
    return TopCall;
  }
}

/// Outlines a task \p T into a helper function that accepts the inputs \p
/// Inputs.  The map \p VMap is updated with the mapping of instructions in \p T
/// to instructions in the new helper function.  Information about the helper
/// function is returned as a TaskOutlineInfo structure.
TaskOutlineInfo llvm::outlineTask(
    Task *T, ValueSet &Inputs, SmallVectorImpl<Value *> &HelperInputs,
    Module *DestM, ValueToValueMapTy &VMap,
    TapirTarget::ArgStructMode useArgStruct, Type *ReturnType,
    ValueToValueMapTy &InputMap, AssumptionCache *AC, DominatorTree *DT) {
  assert(!T->isRootTask() && "Cannot outline the root task.");
  Function &F = *T->getEntry()->getParent();
  DetachInst *DI = T->getDetach();
  Value *TFCreate = T->getTaskFrameUsed();

  Instruction *LoadPt = T->getEntry()->getFirstNonPHIOrDbgOrLifetime();
  Instruction *StorePt = DI;
  BasicBlock *Unwind = DI->getUnwindDest();
  if (Spindle *TaskFrameCreate = T->getTaskFrameCreateSpindle()) {
    LoadPt = &TaskFrameCreate->getEntry()->front();
    StorePt =
        TaskFrameCreate->getEntry()->getSinglePredecessor()->getTerminator();
    if (Unwind) {
      // Find the corresponding taskframe.resume.
      for (User *U : T->getTaskFrameUsed()->users()) {
        if (Instruction *I = dyn_cast<Instruction>(U))
          if (isTaskFrameResume(I)) {
            Unwind = cast<InvokeInst>(I)->getUnwindDest();
            break;
          }
      }
    }
  }

  // Convert the inputs of the task to inputs to the helper.
  ValueSet HelperArgs;
  Instruction *ArgsStart = fixupHelperInputs(F, T, Inputs, HelperArgs, StorePt,
                                             LoadPt, useArgStruct, InputMap);
  for (Value *V : HelperArgs)
    HelperInputs.push_back(V);

  // Clone the blocks into a helper function.
  Function *Helper = createHelperForTask(F, T, HelperArgs, DestM, VMap,
                                         ReturnType, AC, DT);
  Value *ClonedTFCreate = TFCreate ? VMap[TFCreate] : nullptr;
  return TaskOutlineInfo(
      Helper, dyn_cast_or_null<Instruction>(VMap[DI]),
      dyn_cast_or_null<Instruction>(ClonedTFCreate), Inputs,
      ArgsStart, StorePt, DI->getContinue(), Unwind);
}

//----------------------------------------------------------------------------//
// Methods for lowering Tapir loops

/// Returns true if the value V used inside the body of Tapir loop L is defined
/// outside of L.
static bool taskInputDefinedOutsideLoop(const Value *V, const Loop *L) {
  if (isa<Argument>(V))
    return true;

  const BasicBlock *Header = L->getHeader();
  const BasicBlock *Latch = L->getLoopLatch();
  if (const Instruction *I = dyn_cast<Instruction>(V))
    if ((Header != I->getParent()) && (Latch != I->getParent()))
      return true;
  return false;
}

/// Given a Tapir loop \p TL and the set of inputs to the task inside that loop,
/// returns the set of inputs for the Tapir loop itself.
ValueSet llvm::getTapirLoopInputs(TapirLoopInfo *TL, ValueSet &TaskInputs) {
  Loop *L = TL->getLoop();
  Task *T = TL->getTask();
  ValueSet LoopInputs;

  for (Value *V : TaskInputs)
    if (taskInputDefinedOutsideLoop(V, L))
      LoopInputs.insert(V);

  const Value *SyncRegion = T->getDetach()->getSyncRegion();

  SmallPtrSet<BasicBlock *, 2> BlocksToCheck;
  BlocksToCheck.insert(L->getHeader());
  BlocksToCheck.insert(L->getLoopLatch());
  for (BasicBlock *BB : BlocksToCheck) {
    for (Instruction &II : *BB) {
      // Skip the condition of this loop, since we will process that specially.
      if (TL->getCondition() == &II) continue;
      // Examine all operands of this instruction.
      for (User::op_iterator OI = II.op_begin(), OE = II.op_end(); OI != OE;
           ++OI) {
        // If the operand is the sync region of this task's detach, skip it.
        if (SyncRegion == *OI)
          continue;
        LLVM_DEBUG({
            if (Instruction *OP = dyn_cast<Instruction>(*OI))
              assert(!T->encloses(OP->getParent()) &&
                     "Loop control uses value defined in body task.");
          });
        // If this operand is not defined in the header or latch, it's an input.
        if (definedOutsideBlocks(*OI, BlocksToCheck))
          LoopInputs.insert(*OI);
      }
    }
  }

  return LoopInputs;
}

/// Replaces the Tapir loop \p TL, with associated TaskOutlineInfo \p Out, with
/// a call or invoke to the outlined helper function created for \p TL.
Instruction *llvm::replaceLoopWithCallToOutline(
    TapirLoopInfo *TL, TaskOutlineInfo &Out,
    SmallVectorImpl<Value *> &OutlineInputs) {
  // Remove any dependencies from the detach unwind of T code to T's parent.
  unlinkTaskEHFromParent(TL->getTask());

  LLVM_DEBUG({
      dbgs() << "Creating call with arguments:\n";
      for (Value *V : OutlineInputs)
        dbgs() << "\t" << *V << "\n";
    });

  Loop *L = TL->getLoop();
  // Add call to new helper function in original function.
  if (!Out.ReplUnwind) {
    // Common case.  Insert a call to the outline immediately before the detach.
    CallInst *TopCall;
    // Create call instruction.
    IRBuilder<> Builder(Out.ReplCall);
    TopCall = Builder.CreateCall(Out.Outline, OutlineInputs);
    // Use a fast calling convention for the outline.
    TopCall->setCallingConv(Out.Outline->getCallingConv());
    TopCall->setDebugLoc(TL->getDebugLoc());
    if (Out.Outline->doesNotThrow())
      TopCall->setDoesNotThrow();
    // Replace the loop with an unconditional branch to its exit.
    L->getHeader()->removePredecessor(Out.ReplCall->getParent());
    ReplaceInstWithInst(Out.ReplCall, BranchInst::Create(Out.ReplRet));
    return TopCall;
  } else {
    // The detach might catch an exception from the task.  Replace the detach
    // with an invoke of the outline.
    InvokeInst *TopCall;

    // Create invoke instruction.  The ordinary return of the invoke is the
    // detach's continuation, and the unwind return is the detach's unwind.
    TopCall = InvokeInst::Create(Out.Outline, Out.ReplRet, Out.ReplUnwind,
                                 OutlineInputs);
    // Use a fast calling convention for the outline.
    TopCall->setCallingConv(Out.Outline->getCallingConv());
    TopCall->setDebugLoc(TL->getDebugLoc());
    // Replace the loop with the invoke.
    L->getHeader()->removePredecessor(Out.ReplCall->getParent());
    ReplaceInstWithInst(Out.ReplCall, TopCall);
    // Add invoke parent as a predecessor for all Phi nodes in ReplUnwind.
    for (PHINode &Phi : Out.ReplUnwind->phis())
      Phi.addIncoming(Phi.getIncomingValueForBlock(L->getHeader()),
                      TopCall->getParent());
    return TopCall;
  }
}

bool TapirTarget::shouldProcessFunction(const Function &F) const {
  if (F.getName() == "main")
    return true;

  if (canDetach(&F))
    return true;

  for (const Instruction &I : instructions(&F))
    if (const IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I))
      if (Intrinsic::tapir_loop_grainsize == II->getIntrinsicID())
        return true;

  return false;
}

void TapirTarget::lowerTaskFrameAddrCall(CallInst *TaskFrameAddrCall) {
  // By default, replace calls to task_frameaddress with ordinary calls to the
  // frameaddress intrinsic.
  TaskFrameAddrCall->setCalledFunction(
      Intrinsic::getDeclaration(&M, Intrinsic::frameaddress));
}
