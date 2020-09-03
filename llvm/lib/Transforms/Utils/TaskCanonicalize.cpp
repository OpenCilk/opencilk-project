//===- TaskCanonicalize.cpp - Tapir task simplification pass ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass canonicalizes Tapir tasks, in particular, to split blocks at
// taskframe.create intrinsics.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/TaskCanonicalize.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/InitializePasses.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "task-canonicalize"

namespace {
struct TaskCanonicalize : public FunctionPass {
  static char ID; // Pass identification, replacement for typeid
  TaskCanonicalize() : FunctionPass(ID) {
    initializeTaskCanonicalizePass(*PassRegistry::getPassRegistry());
  }

  bool runOnFunction(Function &F) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addPreserved<GlobalsAAWrapperPass>();
  }
};
}

char TaskCanonicalize::ID = 0;
INITIALIZE_PASS_BEGIN(TaskCanonicalize, "task-canonicalize",
                "Canonicalize Tapir tasks", false, false)
INITIALIZE_PASS_END(TaskCanonicalize, "task-canonicalize",
                "Canonicalize Tapir tasks", false, false)

namespace llvm {
Pass *createTaskCanonicalizePass() { return new TaskCanonicalize(); }
} // end namespace llvm

/// runOnFunction - Run through all tasks in the function and canonicalize.
bool TaskCanonicalize::runOnFunction(Function &F) {
  if (F.empty())
    return false;

  LLVM_DEBUG(dbgs() << "TaskCanonicalize running on function " << F.getName()
             << "\n");

  return splitTaskFrameCreateBlocks(F);
}

PreservedAnalyses TaskCanonicalizePass::run(Function &F,
                                            FunctionAnalysisManager &AM) {
  if (F.empty())
    return PreservedAnalyses::all();

  LLVM_DEBUG(dbgs() << "TaskCanonicalize running on function " << F.getName()
             << "\n");

  bool Changed = splitTaskFrameCreateBlocks(F);
  if (!Changed)
    return PreservedAnalyses::all();
  PreservedAnalyses PA;
  PA.preserve<GlobalsAA>();
  return PA;
}
