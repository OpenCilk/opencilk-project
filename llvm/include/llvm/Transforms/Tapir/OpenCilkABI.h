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
  signed char StackFrameFieldFlags = -1;
  signed char StackFrameFieldParent = -1;
  signed char StackFrameFieldWorker = -1;
  signed char StackFrameFieldContext = -1;
  signed char StackFrameFieldMXCSR = -1;
  signed char StackFrameFieldMagic = -1;
  signed char WorkerFieldTail = 0;
  signed char WorkerFieldFrame = 7;

  uint32_t FrameMagic = 0;

  // Opaque Cilk RTS functions
  FunctionCallee CilkRTSLeaveFrame = nullptr;
  // FunctionCallee CilkRTSRethrow = nullptr;
  FunctionCallee CilkRTSSync = nullptr;
  FunctionCallee CilkRTSGetNworkers = nullptr;
  FunctionCallee CilkRTSGetTLSWorker = nullptr;
  FunctionCallee CilkRTSPauseFrame = nullptr;
  FunctionCallee CilkRTSCheckExceptionResume = nullptr;
  FunctionCallee CilkRTSCheckExceptionRaise = nullptr;
  FunctionCallee CilkRTSCleanupFiber = nullptr;

  // Accessors for opaque Cilk RTS functions
  FunctionCallee Get__cilkrts_leave_frame();
  // FunctionCallee Get__cilkrts_rethrow();
  FunctionCallee Get__cilkrts_sync();
  FunctionCallee Get__cilkrts_get_nworkers();
  FunctionCallee Get__cilkrts_get_tls_worker();
  FunctionCallee Get__cilkrts_pause_frame();
  FunctionCallee Get__cilkrts_check_exception_resume();
  FunctionCallee Get__cilkrts_check_exception_raise();
  FunctionCallee Get__cilkrts_cleanup_fiber();

  // Accessors for generated Cilk RTS functions
  Function *Get__cilkrts_enter_frame();
  Function *Get__cilkrts_enter_frame_fast();
  Function *Get__cilkrts_detach();
  Function *Get__cilkrts_save_fp_ctrl_state();
  Function *Get__cilkrts_pop_frame();

  // Helper functions for implementing the Cilk ABI protocol
  Function *GetCilkSyncFn();
  Function *GetCilkSyncNoThrowFn();
  Function *GetCilkPauseFrameFn();
  Function *GetCilkParentEpilogueFn();

  AllocaInst *CreateStackFrame(Function &F);
  Value *GetOrCreateCilkStackFrame(Function &F);

  CallInst *InsertStackFramePush(Function &F,
                                 Instruction *TaskFrameCreate = nullptr,
                                 bool Helper = false);
  void InsertStackFramePop(Function &F, bool PromoteCallsToInvokes,
                           bool InsertPauseFrame, bool Helper);

  CallInst *EmitCilkSetJmp(IRBuilder<> &B, Value *SF);

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
                              Instruction *TaskFrameCreate,
                              bool IsSpawner) override final;
  void postProcessOutlinedTask(Function &F, Instruction *DetachPt,
                               Instruction *TaskFrameCreate,
                               bool IsSpawner) override final;
  void preProcessRootSpawner(Function &F) override final;
  void postProcessRootSpawner(Function &F) override final;
  void processSubTaskCall(TaskOutlineInfo &TOI,
                          DominatorTree &DT) override final;

  LoopOutlineProcessor *
  getLoopOutlineProcessor(const TapirLoopInfo *TL) const override final;
};
} // namespace llvm

#endif
