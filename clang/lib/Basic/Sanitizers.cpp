//===- Sanitizers.cpp - C Language Family Language Options ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//  This file defines the classes from Sanitizers.h
//
//===----------------------------------------------------------------------===//

#include "clang/Basic/Sanitizers.h"
#include "llvm/ADT/Hashing.h"
#include "llvm/ADT/StringSwitch.h"

using namespace clang;

SanitizerMask clang::parseSanitizerValue(StringRef Value, bool AllowGroups) {
  SanitizerMask ParsedKind = llvm::StringSwitch<SanitizerMask>(Value)
#define SANITIZER(NAME, ID) .Case(NAME, SanitizerKind::ID)
#define SANITIZER_GROUP(NAME, ID, ALIAS)                                       \
  .Case(NAME, AllowGroups ? SanitizerKind::ID##Group : SanitizerMask())
#include "clang/Basic/Sanitizers.def"
    .Default(SanitizerMask());
  return ParsedKind;
}

SanitizerMask clang::expandSanitizerGroups(SanitizerMask Kinds) {
#define SANITIZER(NAME, ID)
#define SANITIZER_GROUP(NAME, ID, ALIAS)                                       \
  if (Kinds & SanitizerKind::ID##Group)                                        \
    Kinds |= SanitizerKind::ID;
#include "clang/Basic/Sanitizers.def"
  return Kinds;
}

llvm::hash_code SanitizerMask::hash_value() const {
  return llvm::hash_combine_range(&maskLoToHigh[0], &maskLoToHigh[kNumElem]);
}

namespace clang {
llvm::hash_code hash_value(const clang::SanitizerMask &Arg) {
  return Arg.hash_value();
}
} // namespace clang
