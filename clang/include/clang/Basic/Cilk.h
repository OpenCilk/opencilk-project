//===- Cilk.h - Cilk Language Family Options --------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_BASIC_CILK_H
#define LLVM_CLANG_BASIC_CILK_H

#include "clang/Basic/LLVM.h"

namespace clang {

using CilkOptionMask = uint64_t;
enum CilkOption : uint64_t {
  // Each Cilk option is mapped to a distinct bit.  Currently we support at most
  // 64 Cilk options.
  CilkOpt_Pedigrees = 1ULL << 0,
};

struct CilkOptionSet {
private:
  static bool isPowerOf2(CilkOptionMask CO) {
    return (CO & -CO) == CO;
  }

public:
  // Check if a given single Cilk option is enabled.
  bool has(CilkOptionMask CO) const {
    assert(isPowerOf2(CO) && "Must be a single Cilk option.");
    return static_cast<bool>(Mask & CO);
  }

  // Enable or disable a particular Cilk option.
  void set(CilkOptionMask CO, bool Value) {
    // Ensure that CO is a power of 2.
    assert(isPowerOf2(CO) && "Must be a single Cilk option.");
    Mask = Value ? (Mask | CO) : (Mask & ~CO);
  }

  // Bitmask of enabled Cilk options.
  CilkOptionMask Mask = 0;
};

} // namespace clang
 
#endif // LLVM_CLANG_BASIC_CILK_H
