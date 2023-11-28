//===-- Tapir.h - Tapir Transformations -------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This header file defines prototypes for accessor functions that expose passes
// in the Tapir transformations library.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_TAPIR_H
#define LLVM_TRANSFORMS_TAPIR_H

#include "llvm/Transforms/Tapir/TapirUtils.h"

namespace llvm {
class Pass;
class ModulePass;
class FunctionPass;

//===----------------------------------------------------------------------===//
//
// LoopSpawning - Create a loop spawning pass.
//
Pass *createLoopSpawningPass(tapir::TapirTarget*);

//===----------------------------------------------------------------------===//
//
// SmallBlock - Do SmallBlock Pass
//
FunctionPass *createSmallBlockPass();

//===----------------------------------------------------------------------===//
//
// SyncElimination - TODO
//
FunctionPass *createSyncEliminationPass();

//===----------------------------------------------------------------------===//
//
// RedundantSpawn - Do RedundantSpawn Pass
//
FunctionPass *createRedundantSpawnPass();

//===----------------------------------------------------------------------===//
//
// SpawnRestructure - Do SpawnRestructure Pass
//
FunctionPass *createSpawnRestructurePass();

//===----------------------------------------------------------------------===//
//
// SpawnUnswitch - Do SpawnUnswitch Pass
//
FunctionPass *createSpawnUnswitchPass();

//===----------------------------------------------------------------------===//
//
// PromoteDetachToCilk
//
ModulePass *createLowerTapirToTargetPass(tapir::TapirTarget*);

} // End llvm namespace

#endif
