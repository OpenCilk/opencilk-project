//===- CilkRABI.h - Interface to the CilkR runtime system ------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the CilkR ABI to converts Tapir instructions to calls
// into the CilkR runtime system.
//
//===----------------------------------------------------------------------===//
#ifndef CILK_RABI_H_
#define CILK_RABI_H_

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"

namespace llvm {
class Value;
class TapirLoopInfo;

class CilkRABI : public TapirTarget {
  ValueToValueMapTy DetachCtxToStackFrame;
  SmallPtrSet<CallBase *, 8> CallsToInline;

  // Cilk RTS data types
  StructType *StackFrameTy = nullptr;
  StructType *WorkerTy = nullptr;
  short StackFrameFieldFlags = -1;
  short StackFrameFieldParent = -1;
  short StackFrameFieldWorker = -1;
  short StackFrameFieldContext = -1;
  short StackFrameFieldMXCSR = -1;
  short StackFrameFieldFPCSR = -1;
  short WorkerFieldTail = 0;
  short WorkerFieldFrame = 7;

  // Opaque Cilk RTS functions
  FunctionCallee CilkRTSLeaveFrame = nullptr;
  // FunctionCallee CilkRTSRethrow = nullptr;
  FunctionCallee CilkRTSSync = nullptr;
  FunctionCallee CilkRTSGetNworkers = nullptr;
  FunctionCallee CilkRTSGetTLSWorker = nullptr;
  FunctionCallee CilkRTSStoreExnSel = nullptr;

  const int FrameVersion;
  int FrameVersionFlag() const { return FrameVersion << 24; }

  // Accessors for opaque Cilk RTS functions
  FunctionCallee Get__cilkrts_leave_frame();
  // FunctionCallee Get__cilkrts_rethrow();
  FunctionCallee Get__cilkrts_sync();
  FunctionCallee Get__cilkrts_get_nworkers();
  FunctionCallee Get__cilkrts_get_tls_worker();
  FunctionCallee Get__cilkrts_store_exn_sel();

  // Accessors for generated Cilk RTS functions
  Function *Get__cilkrts_enter_frame();
  Function *Get__cilkrts_enter_frame_fast();
  Function *Get__cilkrts_detach();
  Function *Get__cilkrts_pop_frame();

  // Helper functions for implementing the Cilk ABI protocol
  Function *GetCilkSyncFn();
  Function *GetCilkSyncNoThrowFn();
  Function *GetCilkParentEpilogueFn();
  void EmitSaveFloatingPointState(IRBuilder<> &B, Value *SF);

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
  CilkRABI(Module &M, bool OpenCilk);
  ~CilkRABI() { DetachCtxToStackFrame.clear(); }
  Value *lowerGrainsizeCall(CallInst *GrainsizeCall) override final;
  void lowerSync(SyncInst &SI) override final;

  ArgStructMode getArgStructMode() const override final {
    return ArgStructMode::None;
  }
  void addHelperAttributes(Function &F) override final;

  void preProcessFunction(Function &F, TaskInfo &TI,
                          bool OutliningTapirLoops) override final;
  void postProcessFunction(Function &F, bool OutliningTapirLoops)
    override final;
  void postProcessHelper(Function &F) override final;

  void preProcessOutlinedTask(Function &F, Instruction *DetachPt,
                              Instruction *TaskFrameCreate,
                              bool IsSpawner) override final;
  void postProcessOutlinedTask(Function &F, Instruction *DetachPt,
                               Instruction *TaskFrameCreate,
                               bool IsSpawner) override final;
  void preProcessRootSpawner(Function &F) override final;
  void postProcessRootSpawner(Function &F) override final;
  void processSubTaskCall(TaskOutlineInfo &TOI, DominatorTree &DT)
    override final;

  LoopOutlineProcessor *getLoopOutlineProcessor(const TapirLoopInfo *TL) const
    override final;
};
}  // end of llvm namespace

#endif
