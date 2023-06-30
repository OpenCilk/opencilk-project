//===- DataRaceFreeAliasAnalysis.h - DRF-based AA ---------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This is the interface for an alias analysis based on the assumption that
/// a Tapir program is data-race free.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_ANALYSIS_DATARACEFREEALIASANALYSIS_H
#define LLVM_ANALYSIS_DATARACEFREEALIASANALYSIS_H

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"

namespace llvm {

class TaskInfo;
class MemoryLocation;

extern cl::opt<bool> EnableDRFAA;

/// A simple alias analysis implementation that implements the assumption that
/// the Tapir program is data-race free.  This analysis uses TaskInfo to
/// determine which may-aliasing instructions may happen in parallel.  If two
/// that may alias instructions may happen in parallel and the instructions are
/// not otherwise marked atomic, then the data-race-free assumption asserts that
/// they do not alias.
class DRFAAResult : public AAResultBase<DRFAAResult> {
  TaskInfo &TI;

public:
  explicit DRFAAResult(TaskInfo &TI) : AAResultBase(), TI(TI) {}
  DRFAAResult(DRFAAResult &&Arg) : AAResultBase(std::move(Arg)), TI(Arg.TI) {}

  /// Handle invalidation events in the new pass manager.
  bool invalidate(Function &Fn, const PreservedAnalyses &PA,
                  FunctionAnalysisManager::Invalidator &Inv);

  AliasResult alias(const MemoryLocation &LocA, const MemoryLocation &LocB,
                    AAQueryInfo &AAQI);
  ModRefInfo getModRefInfo(const CallBase *Call, const MemoryLocation &Loc,
                           AAQueryInfo &AAQI);
  ModRefInfo getModRefInfo(const CallBase *Call1, const CallBase *Call2,
                           AAQueryInfo &AAQI);
};

/// Analysis pass providing a never-invalidated alias analysis result.
class DRFAA : public AnalysisInfoMixin<DRFAA> {
  friend AnalysisInfoMixin<DRFAA>;
  static AnalysisKey Key;

public:
  using Result = DRFAAResult;

  DRFAAResult run(Function &F, FunctionAnalysisManager &AM);
};

/// Legacy wrapper pass to provide the DRFAAResult object.
class DRFAAWrapperPass : public FunctionPass {
  std::unique_ptr<DRFAAResult> Result;

public:
  static char ID;

  DRFAAWrapperPass();

  DRFAAResult &getResult() { return *Result; }
  const DRFAAResult &getResult() const { return *Result; }

  bool runOnFunction(Function &F) override;
  void getAnalysisUsage(AnalysisUsage &AU) const override;
};

/// Creates an instance of \c DRFAAWrapperPass.
FunctionPass *createDRFAAWrapperPass();

} // end namespace llvm

#endif // LLVM_ANALYSIS_DATARACEFREEALIASANALYSIS_H
