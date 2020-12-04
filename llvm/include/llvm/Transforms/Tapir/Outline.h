//===- Outline.h - Outlining for Tapir -------------------------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines helper functions for outlining portions of code containing
// Tapir instructions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_TAPIR_OUTLINE_H
#define LLVM_TRANSFORMS_TAPIR_OUTLINE_H

#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

namespace llvm {

using ValueSet = SetVector<Value *>;

// Value materializer for Tapir outlining.
class OutlineMaterializer : public ValueMaterializer {
  const Value *SrcSyncRegion = nullptr;
public:
  OutlineMaterializer(const Value *SrcSyncRegion = nullptr)
      : SrcSyncRegion(SrcSyncRegion) {}
  virtual ~OutlineMaterializer() {}

  Value *materialize(Value *V) override;

  SetVector<BasicBlock *> BlocksToRemap;
};

/// Clone Blocks into NewFunc, transforming the old arguments into references to
/// VMap values.
///
/// TODO: Fix the std::vector part of the type of this function.
void CloneIntoFunction(
    Function *NewFunc, const Function *OldFunc,
    std::vector<BasicBlock *> Blocks, ValueToValueMapTy &VMap,
    bool ModuleLevelChanges, SmallVectorImpl<ReturnInst *> &Returns,
    const StringRef NameSuffix,
    SmallPtrSetImpl<BasicBlock *> *ReattachBlocks = nullptr,
    SmallPtrSetImpl<BasicBlock *> *DetachedRethrowBlocks = nullptr,
    SmallPtrSetImpl<BasicBlock *> *SharedEHEntries = nullptr,
    DISubprogram *SP = nullptr, ClonedCodeInfo *CodeInfo = nullptr,
    ValueMapTypeRemapper *TypeMapper = nullptr,
    OutlineMaterializer *Materializer = nullptr);

/// Create a helper function whose signature is based on Inputs and
/// Outputs as follows: f(in0, ..., inN, out0, ..., outN)
///
/// TODO: Fix the std::vector part of the type of this function.
Function *
CreateHelper(const ValueSet &Inputs, const ValueSet &Outputs,
             std::vector<BasicBlock *> Blocks, BasicBlock *Header,
             const BasicBlock *OldEntry, const BasicBlock *OldExit,
             ValueToValueMapTy &VMap, Module *DestM, bool ModuleLevelChanges,
             SmallVectorImpl<ReturnInst *> &Returns, const StringRef NameSuffix,
             SmallPtrSetImpl<BasicBlock *> *ReattachBlocks = nullptr,
             SmallPtrSetImpl<BasicBlock *> *TaskResumeBlocks = nullptr,
             SmallPtrSetImpl<BasicBlock *> *SharedEHEntries = nullptr,
             const BasicBlock *OldUnwind = nullptr,
             SmallPtrSetImpl<BasicBlock *> *UnreachableExits = nullptr,
             Type *ReturnType = nullptr, ClonedCodeInfo *CodeInfo = nullptr,
             ValueMapTypeRemapper *TypeMapper = nullptr,
             OutlineMaterializer *Materializer = nullptr);

// Add alignment assumptions to parameters of outlined function, based on known
// alignment data in the caller.
void AddAlignmentAssumptions(const Function *Caller, const ValueSet &Args,
                             ValueToValueMapTy &VMap,
                             const Instruction *CallSite, AssumptionCache *AC,
                             DominatorTree *DT);

} // End llvm namespace

#endif
