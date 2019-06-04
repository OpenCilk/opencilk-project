//===- TaskSimplify.h - Tapir task simplification pass -*- C++ -*----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This pass performs several transformations to simplify Tapir tasks.
//
//===----------------------------------------------------------------------===//
#ifndef LLVM_TRANSFORMS_UTILS_TASKSIMPLIFY_H
#define LLVM_TRANSFORMS_UTILS_TASKSIMPLIFY_H

#include "llvm/IR/PassManager.h"

namespace llvm {

struct MaybeParallelTasks;
class Task;
class TaskInfo;

/// This pass is responsible for Tapir task simplification.
class TaskSimplifyPass : public PassInfoMixin<TaskSimplifyPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};

/// Simplify syncs in the specified task T.
bool simplifySyncs(Task *T, MaybeParallelTasks &MPTasks);

/// Simplify the specified task T.
bool simplifyTask(Task *T);

} // end namespace llvm

#endif // LLVM_TRANSFORMS_UTILS_TASKSIMPLIFY_H
