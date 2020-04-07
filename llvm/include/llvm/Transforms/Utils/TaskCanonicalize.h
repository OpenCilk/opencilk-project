//===- TaskCanonicalize.h - Tapir task canonicalization pass -*- C++ -*----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass canonicalizes Tapir tasks.  In particular, this pass splits blocks
// at taskframe.create intrinsics.
//
//===----------------------------------------------------------------------===//
#ifndef LLVM_TRANSFORMS_UTILS_TASKCANONICALIZE_H
#define LLVM_TRANSFORMS_UTILS_TASKCANONICALIZE_H

#include "llvm/IR/PassManager.h"

namespace llvm {

/// This pass is responsible for Tapir task simplification.
class TaskCanonicalizePass : public PassInfoMixin<TaskCanonicalizePass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};

} // end namespace llvm

#endif // LLVM_TRANSFORMS_UTILS_TASKCANONICALIZE_H
