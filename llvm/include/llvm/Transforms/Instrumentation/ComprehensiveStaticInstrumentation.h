//===- ComprehensiveStaticInstrumentation.h ---------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
/// \file
/// This file is part of CSI, a framework that provides comprehensive static
/// instrumentation.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_COMPREHENSIVESTATICINSTRUMENTATION_H
#define LLVM_TRANSFORMS_COMPREHENSIVESTATICINSTRUMENTATION_H

#include "llvm/IR/PassManager.h"
#include "llvm/Transforms/Instrumentation.h"

namespace llvm {

/// CSISetup pass for new pass manager.
class CSISetupPass : public PassInfoMixin<CSISetupPass> {
public:
  CSISetupPass();
  CSISetupPass(const CSIOptions &Options);
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);

private:
  CSIOptions Options;
};

/// ComprehensiveStaticInstrumentation pass for new pass manager.
class ComprehensiveStaticInstrumentationPass :
    public PassInfoMixin<ComprehensiveStaticInstrumentationPass> {
public:
  ComprehensiveStaticInstrumentationPass();
  ComprehensiveStaticInstrumentationPass(const CSIOptions &Options);
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);

private:
  CSIOptions Options;
};

} // end namespace llvm

#endif // LLVM_TRANSFORMS_COMPREHENSIVESTATICINSTRUMENTATION_H
