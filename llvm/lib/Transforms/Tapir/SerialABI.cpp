//===- SerialABI.cpp - Replace Tapir with serial projection ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the SerialABI interface, which is used to convert Tapir
// instructions into their serial projection.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Tapir/SerialABI.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "serialabi"

Value *SerialABI::lowerGrainsizeCall(CallInst *GrainsizeCall) {
  Value *Grainsize = ConstantInt::get(GrainsizeCall->getType(), 1);

  // Replace uses of grainsize intrinsic call with this grainsize value.
  GrainsizeCall->replaceAllUsesWith(Grainsize);
  return Grainsize;
}

void SerialABI::lowerSync(SyncInst &SI) {
  ReplaceInstWithInst(&SI, BranchInst::Create(SI.getSuccessor(0)));
}

void SerialABI::preProcessFunction(Function &F, TaskInfo &TI,
                                   bool ProcessingTapirLoops) {
  if (ProcessingTapirLoops)
    // Don't do any preprocessing when outlining Tapir loops.
    return;

  for (Task *T : post_order(TI.getRootTask())) {
    if (T->isRootTask())
      continue;
    DetachInst *DI = T->getDetach();
    SerializeDetach(DI, T);
  }
}


