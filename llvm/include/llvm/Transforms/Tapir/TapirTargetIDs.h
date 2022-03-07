//===- TapirTargetIDs.h - Tapir target ID's --------------------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file enumerates the available Tapir lowering targets.
//
//===----------------------------------------------------------------------===//

#ifndef TAPIR_TARGET_IDS_H_
#define TAPIR_TARGET_IDS_H_

#include "llvm/ADT/StringRef.h"
#include "llvm/Support/Casting.h"

namespace llvm {

enum class TapirTargetID {
  None,     // Perform no lowering
  Serial,   // Lower to serial projection
  Cheetah,  // Lower to the Cheetah ABI
  Cilk,     // Lower to the Cilk Plus ABI
  Cuda,     // Lower to Cuda ABI
  OpenCilk, // Lower to OpenCilk ABI
  OpenMP,   // Lower to OpenMP
  Qthreads, // Lower to Qthreads
  Last_TapirTargetID
};

// Tapir target options

// Virtual base class for Target-specific options.
class TapirTargetOptions {
public:
  enum TapirTargetOptionKind { TTO_OpenCilk, Last_TTO };

private:
  const TapirTargetOptionKind Kind;

public:
  TapirTargetOptionKind getKind() const { return Kind; }

  TapirTargetOptions(TapirTargetOptionKind K) : Kind(K) {}
  TapirTargetOptions(const TapirTargetOptions &) = delete;
  TapirTargetOptions &operator=(const TapirTargetOptions &) = delete;
  virtual ~TapirTargetOptions() {}

  // Top-level method for cloning TapirTargetOptions.  Defined in
  // TargetLibraryInfo.
  TapirTargetOptions *clone() const;
};

// Options for OpenCilkABI Tapir target.
class OpenCilkABIOptions : public TapirTargetOptions {
  std::string RuntimeBCPath;

  OpenCilkABIOptions() = delete;

public:
  OpenCilkABIOptions(StringRef Path)
      : TapirTargetOptions(TTO_OpenCilk), RuntimeBCPath(Path) {}

  StringRef getRuntimeBCPath() const {
    return RuntimeBCPath;
  }

  static bool classof(const TapirTargetOptions *TTO) {
    return TTO->getKind() == TTO_OpenCilk;
  }

protected:
  friend TapirTargetOptions;

  OpenCilkABIOptions *cloneImpl() const {
    return new OpenCilkABIOptions(RuntimeBCPath);
  }
};

} // end namespace llvm

#endif
