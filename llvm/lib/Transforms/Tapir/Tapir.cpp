//===- Tapir.cpp ----------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements common infrastructure for libLLVMTapirOpts.a, which
// implements several transformations over the Tapir/LLVM intermediate
// representation, including the C bindings for that library.
//
//===----------------------------------------------------------------------===//

#include "llvm-c/Initialization.h"
#include "llvm-c/Transforms/Tapir.h"
#include "llvm/Analysis/Passes.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/PassRegistry.h"
#include "llvm/Transforms/Tapir.h"

using namespace llvm;

/// initializeTapirOpts - Initialize all passes linked into the
/// TapirOpts library.
void llvm::initializeTapirOpts(PassRegistry &Registry) {
  initializeLoopSpawningTIPass(Registry);
  initializeLowerTapirToTargetPass(Registry);
  initializeTaskCanonicalizePass(Registry);
  initializeTaskSimplifyPass(Registry);
  initializeDRFScopedNoAliasWrapperPassPass(Registry);
  initializeLoopStripMinePass(Registry);
  initializeSerializeSmallTasksPass(Registry);
}

void LLVMInitializeTapirOpts(LLVMPassRegistryRef R) {
  initializeTapirOpts(*unwrap(R));
}

void LLVMAddLowerTapirToTargetPass(LLVMPassManagerRef PM)
{
  unwrap(PM)->add(createLowerTapirToTargetPass());
}

void LLVMAddLoopSpawningPass(LLVMPassManagerRef PM)
{
  unwrap(PM)->add(createLoopSpawningTIPass());
}
