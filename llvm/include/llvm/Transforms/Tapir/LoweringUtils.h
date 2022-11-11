//===- LoweringUtils.h - Utility functions for lowering Tapir --*- C++ -*--===//
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

#ifndef LOWERING_UTILS_H_
#define LOWERING_UTILS_H_

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/Tapir/TapirTargetIDs.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

namespace llvm {

class AssumptionCache;
class BasicBlock;
class DominatorTree;
class Function;
class Loop;
class LoopOutlineProcessor;
class Spindle;
class TapirLoopInfo;
class Task;
class TaskInfo;
class Value;

using ValueSet = SetVector<Value *>;
using SpindleSet = SetVector<Spindle *>;
using TaskValueSetMap = DenseMap<const Task *, ValueSet>;
using TFValueSetMap = DenseMap<const Spindle *, ValueSet>;

/// Structure that captures relevant information about an outlined task,
/// including the following:
/// -) A pointer to the outlined function.
/// -) The inputs passed to the call or invoke of that outlined function.
/// -) Pointers to the instructions that replaced the detach in the parent
/// function, ending with the call or invoke instruction to the outlined
/// function.
/// -) The normal and unwind destinations of the call or invoke of the outlined
/// function.
struct TaskOutlineInfo {
  // The outlined helper function.
  Function *Outline = nullptr;

  // Instruction in Outline corresponding to the detach point.
  Instruction *DetachPt = nullptr;

  // Instruction in Outline corresponding to the taskframe.create.
  Instruction *TaskFrameCreate = nullptr;

  // The set of values in the caller passed to the helper function.  These
  // values might be passed directly to a call to the helper function, or they
  // might be marshalled into a structure.
  ValueSet InputSet;

  // Instruction denoting the start of the code in the caller that replaced the
  // task or Tapir loop.
  Instruction *ReplStart = nullptr;

  // Instruction denoting the call or invoke instruction in the caller that
  // calls the outlined helper function.
  Instruction *ReplCall = nullptr;

  // Basic block to which the call to the outlined helper function returns.
  // For an outlined task, this block corresponds to the continuation block
  // of the original detach instruction.  For an outlined Tapir loop, this
  // block corresponds to the normal exit block after the loop latch.
  BasicBlock *ReplRet = nullptr;

  // Basic block denoting the unwind destination of an invocation of the
  // outlined helper function.  This block corresponds to the unwind block of
  // the original detach instruction, or nullptr if the original detach had no
  // unwind block.
  BasicBlock *ReplUnwind = nullptr;

  // Pointer to the basic block corresponding with the entry of this outlined
  // taskframe in the function from which this taskframe was outlined.  This
  // pointer is maintained to help Tapir targets use taskframe-entry blocks as
  // keys for target-specific maps.
  BasicBlock *OriginalTFEntry = nullptr;

  TaskOutlineInfo() = default;
  TaskOutlineInfo(Function *Outline, BasicBlock *OriginalTFEntry,
                  Instruction *DetachPt, Instruction *TaskFrameCreate,
                  ValueSet &InputSet, Instruction *ReplStart,
                  Instruction *ReplCall, BasicBlock *ReplRet,
                  BasicBlock *ReplUnwind = nullptr)
      : Outline(Outline), DetachPt(DetachPt), TaskFrameCreate(TaskFrameCreate),
        InputSet(InputSet), ReplStart(ReplStart), ReplCall(ReplCall),
        ReplRet(ReplRet), ReplUnwind(ReplUnwind),
        OriginalTFEntry(OriginalTFEntry) {}

  // Replaces the stored call or invoke instruction to the outlined function
  // with \p NewReplCall, and updates other information in this TaskOutlineInfo
  // struct appropriately.
  void replaceReplCall(Instruction *NewReplCall) {
    if (ReplStart == ReplCall)
      ReplStart = NewReplCall;
    ReplCall = NewReplCall;
  }

  // Helper routine to remap relevant TaskOutlineInfo values in the event, for
  // instance, that these values are themselves outlined.
  void remapOutlineInfo(ValueToValueMapTy &VMap, ValueToValueMapTy &InputMap) {
    ReplStart = cast<Instruction>(VMap[ReplStart]);
    ReplCall = cast<Instruction>(VMap[ReplCall]);
    ReplRet = cast<BasicBlock>(VMap[ReplRet]);
    if (ReplUnwind)
      ReplUnwind = cast<BasicBlock>(VMap[ReplUnwind]);

    // Remap the contents of InputSet.
    ValueSet NewInputSet;
    for (Value *V : InputSet) {
      if (VMap[V])
        NewInputSet.insert(VMap[V]);
      else if (InputMap[V] && VMap[InputMap[V]])
        NewInputSet.insert(VMap[InputMap[V]]);
      else
        NewInputSet.insert(V);
    }
    InputSet = NewInputSet;
  }
};

// Map from tasks to TaskOutlineInfo structures.
using TaskOutlineMapTy = DenseMap<const Task *, TaskOutlineInfo>;
using TFOutlineMapTy = DenseMap<const Spindle *, TaskOutlineInfo>;

/// Abstract class for a parallel-runtime-system target for Tapir lowering.
///
/// The majority of the Tapir-lowering infrastructure focuses on outlining Tapir
/// tasks into separate functions, which is a common lowering step for many
/// different back-ends.  Most of the heavy-lifting for this outlining process
/// is handled by the lowering infrastructure itself, implemented in
/// TapirToTarget and LoweringUtils.  The TapirTarget class defines several
/// callbacks to tailor this lowering process for a particular back-end.
///
/// The high-level Tapir-lowering algorithm, including the TapirTarget
/// callbacks, operates as follows:
///
/// 1) For each Function F in the Module, call
/// TapirTarget::shouldProcessFunction(F) to decide whether to enqueue F for
/// processing.
///
/// 2) Process each enqueued Function F as follows:
///
///   a) Run TapirTarget::preProcessFunction(F).
///
///   b) If TapirTarget::shouldDoOutlining(F) returns false, skip the subsequent
///   outlining steps, and only process grainsize calls, task-frameaddress
///   calls, and sync instructions in F.
///
///   c) For each Tapir task T in F in post-order:
///
///     i) Prepare the set of inputs to a helper function for T, using the
///     return value of OutlineProcessor::getArgStructMode() to guide this
///     preparation.  For example, if getArgStructMode() != None, insert code to
///     allocate a structure and marshal the inputs in that structure.
///
///     ii) Outline T into a new Function Helper, using the set of inputs
///     prepared in step 2ci and a constant NULL return value of type
///     TapirTarget::getReturnType().
///
///     iii) Run TapirTarget::addHelperAttributes(Helper).
///
///   d) Let Helper[T] denote the outlined Function for a task T.
///
///   e) For each Tapir task T in F in post-order:
///
///     i) Run TapirTarget::preProcessOutlinedTask(Helper[T]).
///
///     ii) For each subtask SubT spawned by Helper[T], run
///       TapirTarget::processSubTaskCall(Helper[SubT])
///
///     iii) Run TapirTarget::postProcessOutlinedTask(Helper[T]).
///
///     iv) Process the grainsize calls, task-frameaddress calls, and sync
///     instructions in Helper[T].
///
///   e) If F spawns tasks, run TapirTarget::preProcessRootSpawner(F); then, for
///   each child task T of F, run TapirTarget::processSubTaskCall(Helper[T]);
///   and finally run TapirTarget::postProcessRootSpawner(F).
///
///   f) Process the grainsize calls, task-frameaddress calls, and sync
///   instructions in F.
///
///   g) Run TapirTarget::postProcessFunction(F).
///
///   h) For each generated helper Function Helper, run
///   TapirTarget::postProcessHelper(Helper).
class TapirTarget {
protected:
  /// The Module of the original Tapir code.
  Module &M;
  /// The Module into which the outlined Helper functions will be placed.
  Module &DestM;

  TapirTarget(Module &M, Module &DestM) : M(M), DestM(DestM) {}

public:
  // Enumeration of ways arguments can be passed to outlined functions.
  enum class ArgStructMode {
    None,   // Pass arguments directly.
    Static, // Statically allocate a structure to store arguments.
    Dynamic // Dynamically allocate a structure to store arguments.
  };

  TapirTarget(Module &M) : M(M), DestM(M) {}
  virtual ~TapirTarget() {}

  virtual void setOptions(const TapirTargetOptions &Options) {}

  // Prepare the module for final Tapir lowering.
  virtual void prepareModule() {}

  /// Lower a call to the tapir.loop.grainsize intrinsic into a grainsize
  /// (coarsening) value.
  virtual Value *lowerGrainsizeCall(CallInst *GrainsizeCall) = 0;

  /// Lower a call to the task.frameaddress intrinsic to get the frame pointer
  /// for the containing function, i.e., after the task has been outlined.
  virtual void lowerTaskFrameAddrCall(CallInst *TaskFrameAddrCall);

  /// Lower a Tapir sync instruction SI.
  virtual void lowerSync(SyncInst &SI) = 0;

  virtual void lowerReducerOperation(CallBase *Call) {
  }

  /// Lower calls to the tapir.runtime.{start,end} intrinsics.  Only
  /// tapir.runtime.start intrinsics are stored; uses of those intrinsics
  /// identify the tapir.runtime.end intrinsics to lower.
  virtual void lowerTapirRTCalls(SmallVectorImpl<CallInst *> &TapirRTCalls,
                                 Function &F, BasicBlock *TFEntry);

  // TODO: Add more options to control outlining.

  /// Returns true if Function F should be processed.
  virtual bool shouldProcessFunction(const Function &F) const;

  /// Returns true if tasks in Function F should be outlined into their own
  /// functions.  Such outlining is a common step for many Tapir backends.
  virtual bool shouldDoOutlining(const Function &F) const { return true; }

  /// Process Function F before any function outlining is performed.  This
  /// routine should not modify the CFG structure, unless it processes all Tapir
  /// instructions in F itself.  Returns true if it modifies the CFG, false
  /// otherwise.
  virtual bool preProcessFunction(Function &F, TaskInfo &TI,
                                  bool ProcessingTapirLoops = false) = 0;

  /// Returns an ArgStructMode enum value describing how inputs to a task should
  /// be passed to the task, e.g., directly as arguments to the outlined
  /// function, or marshalled in a structure.
  virtual ArgStructMode getArgStructMode() const { return ArgStructMode::None; }

  /// Get the return type of an outlined function for a task.
  virtual Type *getReturnType() const {
    return Type::getVoidTy(DestM.getContext());
  }

  /// Get the Module where outlined Helper will be placed.
  Module &getDestinationModule() const { return DestM; }

  // Add attributes to the Function Helper produced from outlining a task.
  virtual void addHelperAttributes(Function &Helper) {}

  // Remap any Target-local structures after taskframe starting at TFEntry is
  // outlined.
  virtual void remapAfterOutlining(BasicBlock *TFEntry,
                                   ValueToValueMapTy &VMap) {}

  // Pre-process the Function F that has just been outlined from a task.  This
  // routine is executed on each outlined function by traversing in post-order
  // the tasks in the original function.
  virtual void preProcessOutlinedTask(Function &F, Instruction *DetachPt,
                                      Instruction *TaskFrameCreate,
                                      bool IsSpawner, BasicBlock *TFEntry) = 0;

  // Post-process the Function F that has just been outlined from a task.  This
  // routine is executed on each outlined function by traversing in post-order
  // the tasks in the original function.
  virtual void postProcessOutlinedTask(Function &F, Instruction *DetachPt,
                                       Instruction *TaskFrameCreate,
                                       bool IsSpawner, BasicBlock *TFEntry) = 0;

  // Pre-process the root Function F as a function that can spawn subtasks.
  virtual void preProcessRootSpawner(Function &F, BasicBlock *TFEntry) = 0;

  // Post-process the root Function F as a function that can spawn subtasks.
  virtual void postProcessRootSpawner(Function &F, BasicBlock *TFEntry) = 0;

  // Process the invocation of a task for an outlined function.  This routine is
  // invoked after processSpawner once for each child subtask.
  virtual void processSubTaskCall(TaskOutlineInfo &TOI, DominatorTree &DT) = 0;

  // Process Function F at the end of the lowering process.
  virtual void postProcessFunction(Function &F,
                                   bool ProcessingTapirLoops = false) = 0;

  // Process a generated helper Function F produced via outlining, at the end of
  // the lowering process.
  virtual void postProcessHelper(Function &F) = 0;

  virtual bool processOrdinaryFunction(Function &F, BasicBlock *TFEntry);

  // Get the LoopOutlineProcessor associated with this Tapir target.
  virtual LoopOutlineProcessor *
  getLoopOutlineProcessor(const TapirLoopInfo *TL) const {
    return nullptr;
  }
};

/// A loop-outline processor customizes the transformation of Tapir loops,
/// outlined via LoopSpawningTI, for a particular back-end.  A loop-outline
/// processor serves a similar role for the LoopSpawningTI pass as a TapirTarget
/// serves for Tapir lowering.
///
/// The LoopSpawningTI pass outlines Tapir loops by examining each Function F in
/// a Module and performing the following algorithm:
///
/// 1) Analyze all loops in Function F to discover Tapir loops that are amenable
/// to LoopSpawningTI.
///
/// 2) Run TapirTarget::preProcessFunction(F, OutliningTapirLoops = true).
///
/// 3) Process each Tapir loop L as follows:
///
///   a) Prepare the set of inputs to the helper function derived from the Tapir
///   task in L, using the return value of OutlineProcessor::getArgStructMode()
///   to guide this preparation.  For example, if getArgStructMode() != None,
///   insert code to allocate a structure and marshal the inputs in that
///   structure.
///
///   b) Run OutlineProcessor::setupLoopOutlineArgs() to get the complete set
///   of inputs for the outlined helper function for L.
///
///   c) Outline L into a Function Helper, whose inputs are the prepared set of
///   inputs produced in step 2b and whose return type is void.  This outlining
///   step uses OutlineProcessor::getIVArgIndex() and
///   OutlineProcessor::getLimitArgIndex() to identify the helper input
///   parameters that specify the strating and ending iterations, respectively.
///
///   d) Call OutlineProcessor::postProcessOutline(Helper).
///
/// 4) For each Tapir loop L in F in post-order, run
/// OutlineProcessor::processOutlinedLoopCall().
///
/// 5) Run TapirTarget::postProcessFunction(F, OutliningTapirLoops = true).
///
/// Two generic loop-outline processors are provided with LoopSpawningTI.  The
/// default loop-outline processor performs no special modifications to outlined
/// Tapir loops.  The DACSpawning loop-outline processor transforms an outlined
/// Tapir loop to evaluate the iterations using parallel recursive
/// divide-and-conquer.
class LoopOutlineProcessor {
protected:
  /// The Module of the original Tapir code.
  Module &M;
  /// The Module into which the outlined Helper functions will be placed.
  Module &DestM;

  LoopOutlineProcessor(Module &M, Module &DestM) : M(M), DestM(DestM) {}
public:
  using ArgStructMode = TapirTarget::ArgStructMode;

  LoopOutlineProcessor(Module &M) : M(M), DestM(M) {}
  virtual ~LoopOutlineProcessor() = default;

  /// Returns an ArgStructMode enum value describing how inputs to the
  /// underlying task of a Tapir loop should be passed to the task, e.g.,
  /// directly as arguments to the outlined function, or marshalled in a
  /// structure.
  virtual ArgStructMode getArgStructMode() const {
    return ArgStructMode::None;
  }

  /// Prepares the set HelperArgs of function arguments for the outlined helper
  /// function Helper for a Tapir loop.  Also prepares the list HelperInputs of
  /// input values passed to a call to Helper.  HelperArgs and HelperInputs are
  /// derived from the loop-control arguments LCArgs and loop-control inputs
  /// LCInputs for the Tapir loop, as well the set TLInputsFixed of arguments to
  /// the task underlying the Tapir loop.
  virtual void setupLoopOutlineArgs(
      Function &F, ValueSet &HelperArgs, SmallVectorImpl<Value *> &HelperInputs,
      ValueSet &InputSet, const SmallVectorImpl<Value *> &LCArgs,
      const SmallVectorImpl<Value *> &LCInputs, const ValueSet &TLInputsFixed);

  /// Get the Module where outlined Helper will be placed.
  Module &getDestinationModule() const { return DestM; }

  /// Returns an integer identifying the index of the helper-function argument
  /// in Args that specifies the starting iteration number.  This return value
  /// must complement the behavior of setupLoopOutlineArgs().
  virtual unsigned getIVArgIndex(const Function &F, const ValueSet &Args) const;

  /// Returns an integer identifying the index of the helper-function argument
  /// in Args that specifies the ending iteration number.  This return value
  /// must complement the behavior of setupLoopOutlineArgs().
  virtual unsigned getLimitArgIndex(const Function &F,
                                    const ValueSet &Args) const {
    return getIVArgIndex(F, Args) + 1;
  }

  /// Processes an outlined Function Helper for a Tapir loop, just after the
  /// function has been outlined.
  virtual void postProcessOutline(TapirLoopInfo &TL, TaskOutlineInfo &Out,
                                  ValueToValueMapTy &VMap);

  /// Add syncs to the escape points of each helper function.  This operation is
  /// a common post-processing step for outlined helper functions.
  void addSyncToOutlineReturns(TapirLoopInfo &TL, TaskOutlineInfo &Out,
                               ValueToValueMapTy &VMap);

  /// Move Cilksan instrumentation out of cloned loop.
  void moveCilksanInstrumentation(TapirLoopInfo &TL, TaskOutlineInfo &Out,
                                  ValueToValueMapTy &VMap);

  /// Remap any data members of the LoopOutlineProcessor.  This method is called
  /// whenever a loop L is outlined, in order to update data for subloops of L.
  virtual void remapData(ValueToValueMapTy &VMap) {};

  /// Processes a call to an outlined Function Helper for a Tapir loop.
  virtual void processOutlinedLoopCall(TapirLoopInfo &TL, TaskOutlineInfo &TOI,
                                       DominatorTree &DT) {}
};

/// Generate a TapirTarget object for the specified TapirTargetID.
TapirTarget *getTapirTargetFromID(Module &M, TapirTargetID TargetID);

/// Find all inputs to tasks within a function \p F, including nested tasks.
TaskValueSetMap findAllTaskInputs(Function &F, const DominatorTree &DT,
                                  const TaskInfo &TI);

void getTaskFrameInputsOutputs(TFValueSetMap &TFInputs,
                               TFValueSetMap &TFOutputs,
                               const Spindle &TF, const ValueSet *TaskInputs,
                               const TaskInfo &TI, const DominatorTree &DT);

void findAllTaskFrameInputs(TFValueSetMap &TFInputs,
                            TFValueSetMap &TFOutputs,
                            const SmallVectorImpl<Spindle *> &AllTaskFrames,
                            Function &F, const DominatorTree &DT, TaskInfo &TI);

/// Create a struct to store the inputs to pass to an outlined function for the
/// task \p T.  Stores into the struct will be inserted \p StorePt, which should
/// precede the detach.  Loads from the struct will be inserted at \p LoadPt,
/// which should be inside \p T.  If a Tapir loop \p TapirL is specified, then
/// its header block is also considered a valid load point.
std::pair<AllocaInst *, Instruction *>
createTaskArgsStruct(const ValueSet &Inputs, Task *T, Instruction *StorePt,
                     Instruction *LoadPt, bool staticStruct,
                     ValueToValueMapTy &InputsMap,
                     Loop *TapirL = nullptr);

/// Organize the set \p Inputs of values in \p F into a set \p Fixed of values
/// that can be used as inputs to a helper function.
void fixupInputSet(Function &F, const ValueSet &Inputs, ValueSet &Fixed);

/// Organize the inputs to task \p T, given in \p TaskInputs, to create an
/// appropriate set of inputs, \p HelperInputs, to pass to the outlined function
/// for \p T.  If a Tapir loop \p TapirL is specified, then its header block is
/// also used in fixing up inputs.
Instruction *fixupHelperInputs(Function &F, Task *T, ValueSet &TaskInputs,
                               ValueSet &HelperInputs, Instruction *StorePt,
                               Instruction *LoadPt,
                               TapirTarget::ArgStructMode useArgStruct,
                               ValueToValueMapTy &InputsMap,
                               Loop *TapirL = nullptr);

/// Returns true if BasicBlock \p B is the immediate successor of only
/// detached-rethrow instructions.
bool isSuccessorOfDetachedRethrow(const BasicBlock *B);

/// Collect the set of blocks in task \p T.  All blocks enclosed by \p T will be
/// pushed onto \p TaskBlocks.  The set of blocks terminated by reattaches from
/// \p T are added to \p ReattachBlocks.  The set of blocks terminated by
/// detached-rethrow instructions are added to \p DetachedRethrowBlocks.  The
/// set of entry points to exception-handling blocks shared by \p T and other
/// tasks in the same function are added to \p SharedEHEntries.
void getTaskBlocks(Task *T, std::vector<BasicBlock *> &TaskBlocks,
                   SmallPtrSetImpl<BasicBlock *> &ReattachBlocks,
                   SmallPtrSetImpl<BasicBlock *> &TaskResumeBlocks,
                   SmallPtrSetImpl<BasicBlock *> &SharedEHEntries,
                   const DominatorTree *DT);

/// Outlines the content of task \p T in function \p F into a new helper
/// function.  The parameter \p Inputs specified the inputs to the helper
/// function.  The map \p VMap is updated with the mapping of instructions in
/// \p T to instructions in the new helper function.
Function *createHelperForTask(
    Function &F, Task *T, ValueSet &Inputs, Module *DestM,
    ValueToValueMapTy &VMap, Type *ReturnType, AssumptionCache *AC,
    DominatorTree *DT);

/// Outlines the content of taskframe \p TF in function \p F into a new helper
/// function.  The parameter \p Inputs specified the inputs to the helper
/// function.  The map \p VMap is updated with the mapping of instructions in \p
/// TF to instructions in the new helper function.
Function *createHelperForTaskFrame(
    Function &F, Spindle *TF, ValueSet &Args, Module *DestM,
    ValueToValueMapTy &VMap, Type *ReturnType, AssumptionCache *AC,
    DominatorTree *DT);

/// Replaces the taskframe \p TF, with associated TaskOutlineInfo \p Out, with a
/// call or invoke to the outlined helper function created for \p TF.
Instruction *replaceTaskFrameWithCallToOutline(
    Spindle *TF, TaskOutlineInfo &Out, SmallVectorImpl<Value *> &OutlineInputs);

/// Outlines a task \p T into a helper function that accepts the inputs \p
/// Inputs.  The map \p VMap is updated with the mapping of instructions in \p T
/// to instructions in the new helper function.  Information about the helper
/// function is returned as a TaskOutlineInfo structure.
TaskOutlineInfo outlineTask(
    Task *T, ValueSet &Inputs, SmallVectorImpl<Value *> &HelperInputs,
    Module *DestM, ValueToValueMapTy &VMap,
    TapirTarget::ArgStructMode useArgStruct, Type *ReturnType,
    ValueToValueMapTy &InputMap, AssumptionCache *AC, DominatorTree *DT);

/// Outlines a taskframe \p TF into a helper function that accepts the inputs \p
/// Inputs.  The map \p VMap is updated with the mapping of instructions in \p
/// TF to instructions in the new helper function.  Information about the helper
/// function is returned as a TaskOutlineInfo structure.
TaskOutlineInfo outlineTaskFrame(
    Spindle *TF, ValueSet &Inputs, SmallVectorImpl<Value *> &HelperInputs,
    Module *DestM, ValueToValueMapTy &VMap,
    TapirTarget::ArgStructMode useArgStruct, Type *ReturnType,
    ValueToValueMapTy &InputMap, AssumptionCache *AC, DominatorTree *DT);

//----------------------------------------------------------------------------//
// Methods for lowering Tapir loops

/// Given a Tapir loop \p TL and the set of inputs to the task inside that loop,
/// returns the set of inputs for the Tapir loop itself.
ValueSet getTapirLoopInputs(TapirLoopInfo *TL, ValueSet &TaskInputs);


/// Replaces the Tapir loop \p TL, with associated TaskOutlineInfo \p Out, with
/// a call or invoke to the outlined helper function created for \p TL.
Instruction *replaceLoopWithCallToOutline(
    TapirLoopInfo *TL, TaskOutlineInfo &Out,
    SmallVectorImpl<Value *> &OutlineInputs);

}  // end namepsace llvm

#endif
