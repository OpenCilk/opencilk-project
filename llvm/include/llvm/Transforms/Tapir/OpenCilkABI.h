//===- OpenilkABI.h - Interface to the OpenCilk runtime system ---*- C++ -*--=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the OpenCilk ABI to converts Tapir instructions to calls
// into the OpenCilk runtime system.
//
//===----------------------------------------------------------------------===//
#ifndef OPEN_CILK_ABI_H_
#define OPEN_CILK_ABI_H_

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"

namespace llvm {
class Value;
class TapirLoopInfo;

class OpenCilkABI final : public TapirTarget {
  ValueToValueMapTy DetachCtxToStackFrame;
  SmallPtrSet<CallBase *, 8> CallsToInline;
  DenseMap<BasicBlock *, SmallVector<IntrinsicInst *, 4>> TapirRTCalls;

  StringRef RuntimeBCPath = "";

  // Cilk RTS data types
  StructType *StackFrameTy = nullptr;
  StructType *WorkerTy = nullptr;

  // Opaque Cilk RTS functions
  FunctionCallee CilkRTSEnterFrame = nullptr;
  FunctionCallee CilkRTSEnterFrameHelper = nullptr;
  FunctionCallee CilkRTSDetach = nullptr;
  FunctionCallee CilkRTSLeaveFrame = nullptr;
  FunctionCallee CilkRTSLeaveFrameHelper = nullptr;
  FunctionCallee CilkPrepareSpawn = nullptr;
  FunctionCallee CilkSync = nullptr;
  FunctionCallee CilkSyncNoThrow = nullptr;
  FunctionCallee CilkParentEpilogue = nullptr;
  FunctionCallee CilkHelperEpilogue = nullptr;
  FunctionCallee CilkRTSEnterLandingpad = nullptr;
  FunctionCallee CilkRTSPauseFrame = nullptr;

  FunctionCallee CilkRTSReducerRegister = nullptr;
  FunctionCallee CilkRTSReducerUnregister = nullptr;
  FunctionCallee CilkRTSReducerLookup = nullptr;
  FunctionCallee CilkRTSReducerToken = nullptr;

  // Accessors for opaque Cilk RTS functions
  FunctionCallee CilkHelperEpilogueExn = nullptr;
  FunctionCallee CilkRTSCilkForGrainsize8 = nullptr;
  FunctionCallee CilkRTSCilkForGrainsize16 = nullptr;
  FunctionCallee CilkRTSCilkForGrainsize32 = nullptr;
  FunctionCallee CilkRTSCilkForGrainsize64 = nullptr;

  // Accessors for CilkRTS ABI functions. When a bitcode file is loaded, these
  // functions should return the function defined in the bitcode file.
  // Otherwise, these functions will return FunctionCallees for placeholder
  // declarations of these functions.  The latter case is intended for debugging
  // ABI-call insertion.
  FunctionCallee Get__cilkrts_enter_frame() {
    return CilkRTSEnterFrame;
  }
  FunctionCallee Get__cilkrts_enter_frame_helper() {
    return CilkRTSEnterFrameHelper;
  }
  FunctionCallee Get__cilkrts_detach() {
    return CilkRTSDetach;
  }
  FunctionCallee Get__cilkrts_leave_frame() {
    return CilkRTSLeaveFrame;
  }
  FunctionCallee Get__cilkrts_leave_frame_helper() {
    return CilkRTSLeaveFrameHelper;
  }
  FunctionCallee Get__cilkrts_pause_frame() {
    return CilkRTSPauseFrame;
  }
  FunctionCallee Get__cilkrts_enter_landingpad() {
    return CilkRTSEnterLandingpad;
  }
  FunctionCallee Get__cilkrts_cilk_for_grainsize_8() {
    return CilkRTSCilkForGrainsize8;
  }
  FunctionCallee Get__cilkrts_cilk_for_grainsize_16() {
    return CilkRTSCilkForGrainsize16;
  }
  FunctionCallee Get__cilkrts_cilk_for_grainsize_32() {
    return CilkRTSCilkForGrainsize32;
  }
  FunctionCallee Get__cilkrts_cilk_for_grainsize_64() {
    return CilkRTSCilkForGrainsize64;
  }
  FunctionCallee Get__cilkrts_reducer_register() {
    return CilkRTSReducerRegister;
  }
  FunctionCallee Get__cilkrts_reducer_unregister() {
    return CilkRTSReducerUnregister;
  }
  FunctionCallee Get__cilkrts_reducer_lookup() {
    return CilkRTSReducerLookup;
  }
  FunctionCallee Get__cilkrts_reducer_token() {
    return CilkRTSReducerToken;
  }

  // Helper functions for implementing the Cilk ABI protocol
  FunctionCallee GetCilkPrepareSpawnFn() {
    return CilkPrepareSpawn;
  }
  FunctionCallee GetCilkSyncFn() {
    return CilkSync;
  }
  FunctionCallee GetCilkSyncNoThrowFn() {
    return CilkSyncNoThrow;
  }
  FunctionCallee GetCilkParentEpilogueFn() {
    return CilkParentEpilogue;
  }
  FunctionCallee GetCilkHelperEpilogueFn() {
    return CilkHelperEpilogue;
  }
  FunctionCallee GetCilkHelperEpilogueExnFn() {
    return CilkHelperEpilogueExn;
  }

  void GetTapirRTCalls(Spindle *TaskFrame, bool IsRootTask, TaskInfo &TI);
  void LowerTapirRTCalls(Function &F, BasicBlock *TFEntry);

  Value *CreateStackFrame(Function &F);
  Value *GetOrCreateCilkStackFrame(Function &F);

  CallInst *InsertStackFramePush(Function &F,
                                 Instruction *TaskFrameCreate = nullptr,
                                 bool Helper = false);
  void InsertStackFramePop(Function &F, bool PromoteCallsToInvokes,
                           bool InsertPauseFrame, bool Helper);

  void InsertDetach(Function &F, Instruction *DetachPt);

  void MarkSpawner(Function &F);

public:
  OpenCilkABI(Module &M);
  ~OpenCilkABI() { DetachCtxToStackFrame.clear(); }

  void setOptions(const TapirTargetOptions &Options) override final;

  void prepareModule() override final;
  Value *lowerGrainsizeCall(CallInst *GrainsizeCall) override final;
  void lowerSync(SyncInst &SI) override final;
  void lowerReducerOperation(CallBase *CI) override;

  ArgStructMode getArgStructMode() const override final {
    return ArgStructMode::None;
  }
  void addHelperAttributes(Function &F) override final;

  void remapAfterOutlining(BasicBlock *TFEntry,
                           ValueToValueMapTy &VMap) override final;

  void preProcessFunction(Function &F, TaskInfo &TI,
                          bool ProcessingTapirLoops) override final;
  void postProcessFunction(Function &F,
                           bool ProcessingTapirLoops) override final;
  void postProcessHelper(Function &F) override final;

  void preProcessOutlinedTask(Function &F, Instruction *DetachPt,
                              Instruction *TaskFrameCreate, bool IsSpawner,
                              BasicBlock *TFEntry) override final;
  void postProcessOutlinedTask(Function &F, Instruction *DetachPt,
                               Instruction *TaskFrameCreate, bool IsSpawner,
                               BasicBlock *TFEntry) override final;
  void preProcessRootSpawner(Function &F, BasicBlock *TFEntry) override final;
  void postProcessRootSpawner(Function &F, BasicBlock *TFEntry) override final;
  void processSubTaskCall(TaskOutlineInfo &TOI,
                          DominatorTree &DT) override final;
  bool processOrdinaryFunction(Function &F, BasicBlock *TFEntry) override final;

  LoopOutlineProcessor *
  getLoopOutlineProcessor(const TapirLoopInfo *TL) const override final;
};
} // namespace llvm

#endif
