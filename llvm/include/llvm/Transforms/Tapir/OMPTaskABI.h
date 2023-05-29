//===- OMPTaskABI.h - Generic interface to runtime systems -------*- C++ -*--=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the OMP Task ABI to convert Tapir instructions to calls
// into kmpc task runtime calls.
//
//===----------------------------------------------------------------------===//
#ifndef OMPTASK_ABI_H_
#define OMPTASK_ABI_H_

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"

namespace llvm {
class Value;
class TapirLoopInfo;

class OMPTaskABI final : public TapirTarget {
  ValueToValueMapTy DetachCtxToStackFrame;

  StringRef RuntimeBCPath = "";

  // Runtime stack structure
  StructType *StackFrameTy = nullptr;
  StructType *TaskTy = nullptr;
  FunctionType *SpawnBodyFnTy = nullptr;
  Type *SpawnBodyFnArgTy = nullptr;
  Type *SpawnBodyFnArgSizeTy = nullptr;

  // Runtime functions
  FunctionCallee RTSEnterFrame = nullptr;
  FunctionCallee RTSGetArgsFromTask = nullptr;
  FunctionCallee RTSSpawn = nullptr;
  FunctionCallee RTSSync = nullptr;
  FunctionCallee RTSSyncNoThrow = nullptr;

  FunctionCallee RTSLoopGrainsize8 = nullptr;
  FunctionCallee RTSLoopGrainsize16 = nullptr;
  FunctionCallee RTSLoopGrainsize32 = nullptr;
  FunctionCallee RTSLoopGrainsize64 = nullptr;

  FunctionCallee RTSGetNumWorkers = nullptr;
  FunctionCallee RTSGetWorkerID = nullptr;

  Align StackFrameAlign{8};

  Value *CreateStackFrame(Function &F);
  Value *GetOrCreateStackFrame(Function &F);

  CallInst *InsertStackFramePush(Function &F,
                                 Instruction *TaskFrameCreate = nullptr,
                                 bool Helper = false);
  void InsertStackFramePop(Function &F, bool PromoteCallsToInvokes,
                           bool InsertPauseFrame, bool Helper);

public:
  OMPTaskABI(Module &M) : TapirTarget(M) {}
  ~OMPTaskABI() { DetachCtxToStackFrame.clear(); }

  // void setOptions(const TapirTargetOptions &Options) override final;

  void prepareModule() override final;
  Value *lowerGrainsizeCall(CallInst *GrainsizeCall) override final;
  void lowerSync(SyncInst &SI) override final;
  // void lowerReducerOperation(CallBase *CI) override;

  ArgStructMode getArgStructMode() const override final {
    return ArgStructMode::Static;
  }
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
                               Instruction *TaskFrameCreate, bool IsSpawner,
                               BasicBlock *TFEntry) override final;
  void preProcessRootSpawner(Function &F, BasicBlock *TFEntry) override final;
  void postProcessRootSpawner(Function &F, BasicBlock *TFEntry) override final;
  void processSubTaskCall(TaskOutlineInfo &TOI,
                          DominatorTree &DT) override final;

};
} // namespace llvm

#endif // OMPTASK_ABI_H
