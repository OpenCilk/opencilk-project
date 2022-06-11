//===--- Tapir.cpp - C Language Family Language Options ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file defines the functions from Tapir.h
//
//===----------------------------------------------------------------------===//

#include "clang/Driver/Tapir.h"
#include "clang/Driver/Options.h"
#include "clang/Driver/ToolChain.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/Option/Arg.h"
#include "llvm/Option/ArgList.h"
#include "llvm/Transforms/Tapir/TapirTargetIDs.h"

using namespace clang::driver;
using namespace clang;
using namespace llvm::opt;

TapirTargetID clang::parseTapirTarget(const ArgList &Args) {
  // Use Cilk if -ftapir is not specified but -fcilkplus is specified.
  if (!Args.hasArg(options::OPT_ftapir_EQ)) {
    if (Args.hasArg(options::OPT_fcilkplus))
      return TapirTargetID::Cilk;
    if (Args.hasArg(options::OPT_fopencilk))
      return TapirTargetID::OpenCilk;
    return TapirTargetID::None;
  }

  // Otherwise use the runtime specified by -ftapir.
  TapirTargetID TapirTarget = TapirTargetID::None;
  if (const Arg *A = Args.getLastArg(options::OPT_ftapir_EQ))
    TapirTarget = llvm::StringSwitch<TapirTargetID>(A->getValue())
      .Case("none", TapirTargetID::None)
      .Case("serial", TapirTargetID::Serial)
      .Case("cheetah", TapirTargetID::Cheetah)
      .Case("cilkplus", TapirTargetID::Cilk)
      .Case("cuda", TapirTargetID::Cuda)
      .Case("opencilk", TapirTargetID::OpenCilk)
      .Case("openmp", TapirTargetID::OpenMP)
      .Case("qthreads", TapirTargetID::Qthreads)
      .Default(TapirTargetID::Last_TapirTargetID);

  return TapirTarget;
}

llvm::Optional<llvm::StringRef>
clang::serializeTapirTarget(TapirTargetID Target) {
  llvm::Optional<llvm::StringRef> TapirTargetStr;
  switch (Target) {
  case TapirTargetID::None:
    TapirTargetStr = "none";
    break;
  case TapirTargetID::Serial:
    TapirTargetStr = "serial";
    break;
  case TapirTargetID::Cheetah:
    TapirTargetStr = "cheetah";
    break;
  case TapirTargetID::Cilk:
    TapirTargetStr = "cilkplus";
    break;
  case TapirTargetID::Cuda:
    TapirTargetStr = "cuda";
    break;
  case TapirTargetID::OpenCilk:
    TapirTargetStr = "opencilk";
    break;
  case TapirTargetID::OpenMP:
    TapirTargetStr = "openmp";
    break;
  case TapirTargetID::Qthreads:
    TapirTargetStr = "qthreads";
    break;
  case TapirTargetID::Last_TapirTargetID:
    break;
  }
  return TapirTargetStr;
}
