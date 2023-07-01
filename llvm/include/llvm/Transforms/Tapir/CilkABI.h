//===- CilkABI.h - Interface to the Intel Cilk Plus runtime ----*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the Cilk ABI to converts Tapir instructions to calls
// into the Cilk runtime system.
//
//===----------------------------------------------------------------------===//
#ifndef CILK_ABI_H_
#define CILK_ABI_H_

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"

namespace llvm {
class Value;
class TapirLoopInfo;

class CilkABI : public TapirTarget {
  ValueToValueMapTy DetachCtxToStackFrame;
  SmallPtrSet<CallBase *, 8> CallsToInline;

  // Cilk RTS data types
  StructType *PedigreeTy = nullptr;
  enum PedigreeFields { rank = 0, next };
  StructType *StackFrameTy = nullptr;
  enum StackFrameFields
    {
     flags = 0,
     size,
     call_parent,
     worker,
     except_data,
     ctx,
     mxcsr,
     fpcsr,
     reserved,
     parent_pedigree
    };
  StructType *WorkerTy = nullptr;
  enum WorkerFields
    {
     tail = 0,
     head,
     exc,
     protected_tail,
     ltq_limit,
     self,
     g,
     l,
     reducer_map,
     current_stack_frame,
     saved_protected_tail,
     sysdep,
     pedigree
    };

  // Opaque Cilk RTS functions
  FunctionCallee CilkRTSInit = nullptr;
  FunctionCallee CilkRTSLeaveFrame = nullptr;
  FunctionCallee CilkRTSRethrow = nullptr;
  FunctionCallee CilkRTSSync = nullptr;
  FunctionCallee CilkRTSGetNworkers = nullptr;
  FunctionCallee CilkRTSGetTLSWorker = nullptr;
  FunctionCallee CilkRTSGetTLSWorkerFast = nullptr;
  FunctionCallee CilkRTSBindThread1 = nullptr;

  // Accessors for opaque Cilk RTS functions
  FunctionCallee Get__cilkrts_init();
  FunctionCallee Get__cilkrts_leave_frame();
  FunctionCallee Get__cilkrts_rethrow();
  FunctionCallee Get__cilkrts_sync();
  FunctionCallee Get__cilkrts_get_nworkers();
  FunctionCallee Get__cilkrts_get_tls_worker();
  FunctionCallee Get__cilkrts_get_tls_worker_fast();
  FunctionCallee Get__cilkrts_bind_thread_1();
  // Accessors for compiler-generated Cilk RTS functions
  Function *Get__cilkrts_enter_frame_1();
  Function *Get__cilkrts_enter_frame_fast_1();
  Function *Get__cilkrts_detach();
  Function *Get__cilkrts_pop_frame();

  // Helper functions for implementing the Cilk ABI protocol
  Function *GetCilkSyncFn(bool instrument = false);
  Function *GetCilkSyncNothrowFn(bool instrument = false);
  Function *GetCilkCatchExceptionFn(Type *ExnTy);
  Function *GetCilkParentEpilogueFn(bool instrument = false);
  static void EmitSaveFloatingPointState(IRBuilder<> &B, Value *SF);
  AllocaInst *CreateStackFrame(Function &F);
  Value *GetOrInitCilkStackFrame(Function &F, bool Helper,
                                 bool instrumet = false);
  CallInst *EmitCilkSetJmp(IRBuilder<> &B, Value *SF);
  bool makeFunctionDetachable(Function &Extracted, Instruction *DetachPt,
                              Instruction *TaskFrameCreate,
                              bool instrument = false);

public:
  CilkABI(Module &M);
  ~CilkABI() { DetachCtxToStackFrame.clear(); }
  void prepareModule() override final;
  Value *lowerGrainsizeCall(CallInst *GrainsizeCall) override final;
  void lowerSync(SyncInst &SI) override final;

  ArgStructMode getArgStructMode() const override final;
  void addHelperAttributes(Function &F) override final;

  bool preProcessFunction(Function &F, TaskInfo &TI,
                          bool ProcessingTapirLoops) override final;
  void postProcessFunction(Function &F,
                           bool ProcessingTapirLoops) override final;
  void postProcessHelper(Function &F) override final;

  void preProcessOutlinedTask(Function &F, Instruction *DetachPt,
                              Instruction *TaskFrameCreate, bool IsSpawner,
                              BasicBlock *TFEntry) override final;
  void postProcessOutlinedTask(Function &F, Instruction *DetachPt,
                               Instruction *TaskFrameCreate, bool IsSpaner,
                               BasicBlock *TFEntry) override final;
  void preProcessRootSpawner(Function &F, BasicBlock *TFEntry) override final;
  void postProcessRootSpawner(Function &F, BasicBlock *TFEntry) override final;
  void processSubTaskCall(TaskOutlineInfo &TOI,
                          DominatorTree &DT) override final;

  LoopOutlineProcessor *
  getLoopOutlineProcessor(const TapirLoopInfo *TL) const override final;
};
} // namespace llvm

#endif
