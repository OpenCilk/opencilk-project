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

class OpenCilkABI : public TapirTarget {
  ValueToValueMapTy DetachCtxToStackFrame;
  SmallPtrSet<CallBase *, 8> CallsToInline;

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
  FunctionCallee CilkHelperEpilogueExn = nullptr;
  FunctionCallee CilkRTSCilkForGrainsize8 = nullptr;
  FunctionCallee CilkRTSCilkForGrainsize16 = nullptr;
  FunctionCallee CilkRTSCilkForGrainsize32 = nullptr;
  FunctionCallee CilkRTSCilkForGrainsize64 = nullptr;

  // Accessors for Cilk RTS functions
  FunctionCallee Get__cilkrts_enter_frame();
  FunctionCallee Get__cilkrts_enter_frame_helper();
  FunctionCallee Get__cilkrts_detach();
  FunctionCallee Get__cilkrts_leave_frame();
  FunctionCallee Get__cilkrts_leave_frame_helper();
  FunctionCallee Get__cilkrts_pause_frame();
  FunctionCallee Get__cilkrts_enter_landingpad();
  FunctionCallee Get__cilkrts_cilk_for_grainsize_8();
  FunctionCallee Get__cilkrts_cilk_for_grainsize_16();
  FunctionCallee Get__cilkrts_cilk_for_grainsize_32();
  FunctionCallee Get__cilkrts_cilk_for_grainsize_64();

  // Helper functions for implementing the Cilk ABI protocol
  FunctionCallee GetCilkPrepareSpawnFn();
  FunctionCallee GetCilkSyncFn();
  FunctionCallee GetCilkSyncNoThrowFn();
  FunctionCallee GetCilkParentEpilogueFn();
  FunctionCallee GetCilkHelperEpilogueFn();
  FunctionCallee GetCilkHelperEpilogueExnFn();

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
  void prepareModule() override final;
  Value *lowerGrainsizeCall(CallInst *GrainsizeCall) override final;
  void lowerSync(SyncInst &SI) override final;

  ArgStructMode getArgStructMode() const override final {
    return ArgStructMode::None;
  }
  void addHelperAttributes(Function &F) override final;

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
