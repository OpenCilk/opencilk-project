//===- KaleidoscopeJIT.h - A simple JIT for Kaleidoscope --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Contains a simple JIT definition for use in the kaleidoscope tutorials.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_EXECUTIONENGINE_ORC_KALEIDOSCOPEJIT_H
#define LLVM_EXECUTIONENGINE_ORC_KALEIDOSCOPEJIT_H

#include "llvm/ADT/StringRef.h"
#include "llvm/ExecutionEngine/JITSymbol.h"
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/Core.h"
#include "llvm/ExecutionEngine/Orc/ExecutionUtils.h"
#include "llvm/ExecutionEngine/Orc/ExecutorProcessControl.h"
#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/IRTransformLayer.h"
#include "llvm/ExecutionEngine/Orc/JITTargetMachineBuilder.h"
#include "llvm/ExecutionEngine/Orc/RTDyldObjectLinkingLayer.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Support/FormatVariadic.h"
#include <memory>

namespace llvm {
namespace orc {

class KaleidoscopeJIT {
private:
  std::unique_ptr<ExecutionSession> ES;

  DataLayout DL;
  MangleAndInterner Mangle;

  RTDyldObjectLinkingLayer ObjectLayer;
  IRCompileLayer CompileLayer;
  IRTransformLayer InitHelperTransformLayer;

  JITDylib &MainJD;

  SymbolLookupSet InitFunctions;
  SymbolLookupSet DeInitFunctions;

  /// This transform parses llvm.global_ctors to produce a single initialization
  /// function for the module, records the function, then deletes
  /// llvm.global_ctors.
  class GlobalCtorDtorScraper {
  public:
    GlobalCtorDtorScraper(ExecutionSession &ES, SymbolLookupSet &InitFunctions,
                          StringRef InitFunctionPrefix)
        : ES(ES), InitFunctions(InitFunctions),
          InitFunctionPrefix(InitFunctionPrefix) {}
    Expected<ThreadSafeModule> operator()(ThreadSafeModule TSM,
                                          MaterializationResponsibility &R) {
      auto Err = TSM.withModuleDo([&](Module &M) -> Error {
        auto &Ctx = M.getContext();
        auto *GlobalCtors = M.getNamedGlobal("llvm.global_ctors");
        // If there's no llvm.global_ctors or it's just a decl then skip.
        if (!GlobalCtors || GlobalCtors->isDeclaration())
          return Error::success();

        std::string InitFunctionName;
        raw_string_ostream(InitFunctionName)
            << InitFunctionPrefix << M.getModuleIdentifier();

        MangleAndInterner Mangle(ES, M.getDataLayout());
        auto InternedName = Mangle(InitFunctionName);
        if (auto Err = R.defineMaterializing(
                {{InternedName, JITSymbolFlags::Callable}}))
          return Err;

        auto *InitFunc = Function::Create(
            FunctionType::get(Type::getVoidTy(Ctx), {}, false),
            GlobalValue::ExternalLinkage, InitFunctionName, &M);
        InitFunc->setVisibility(GlobalValue::HiddenVisibility);
        std::vector<std::pair<Function *, unsigned>> Inits;
        for (auto E : getConstructors(M))
          Inits.push_back(std::make_pair(E.Func, E.Priority));
        llvm::sort(Inits, [](const std::pair<Function *, unsigned> &LHS,
                             const std::pair<Function *, unsigned> &RHS) {
          return LHS.first < RHS.first;
        });
        auto *EntryBlock = BasicBlock::Create(Ctx, "entry", InitFunc);
        IRBuilder<> IB(EntryBlock);
        for (auto &KV : Inits)
          IB.CreateCall(KV.first);
        IB.CreateRetVoid();

        ES.runSessionLocked([&]() { InitFunctions.add(InternedName); });
        GlobalCtors->eraseFromParent();
        return Error::success();
      });

      if (Err)
        return std::move(Err);

      return std::move(TSM);
    }

  private:
    ExecutionSession &ES;
    SymbolLookupSet &InitFunctions;
    StringRef InitFunctionPrefix;
  };

public:
  KaleidoscopeJIT(std::unique_ptr<ExecutionSession> ES,
                  JITTargetMachineBuilder JTMB, DataLayout DL)
      : ES(std::move(ES)), DL(std::move(DL)),
        Mangle(*this->ES, this->DL),
        ObjectLayer(*this->ES,
                    []() { return std::make_unique<SectionMemoryManager>(); }),
        CompileLayer(*this->ES, ObjectLayer,
                     std::make_unique<ConcurrentIRCompiler>(std::move(JTMB))),
        InitHelperTransformLayer(
            *this->ES, CompileLayer,
            GlobalCtorDtorScraper(*this->ES, InitFunctions, "my_init.")),
        MainJD(this->ES->createBareJITDylib("<main>")) {
    MainJD.addGenerator(
        cantFail(DynamicLibrarySearchGenerator::GetForCurrentProcess(
            DL.getGlobalPrefix())));
  }

  ~KaleidoscopeJIT() {
    if (auto Err = ES->endSession())
      ES->reportError(std::move(Err));
  }

  static Expected<std::unique_ptr<KaleidoscopeJIT>> Create() {
    auto SSP = std::make_shared<SymbolStringPool>();
    auto EPC = SelfExecutorProcessControl::Create();
    if (!EPC)
      return EPC.takeError();

    auto ES = std::make_unique<ExecutionSession>(std::move(*EPC));

    JITTargetMachineBuilder JTMB(
        ES->getExecutorProcessControl().getTargetTriple());

    auto DL = JTMB.getDefaultDataLayoutForTarget();
    if (!DL)
      return DL.takeError();

    return std::make_unique<KaleidoscopeJIT>(std::move(ES),
                                             std::move(JTMB), std::move(*DL));
  }

  const DataLayout &getDataLayout() const { return DL; }

  JITDylib &getMainJITDylib() { return MainJD; }

  void loadLibrary(const char *FileName) {
    MainJD.addGenerator(cantFail(
        DynamicLibrarySearchGenerator::Load(FileName, DL.getGlobalPrefix())));
  }

  Error addModule(ThreadSafeModule TSM, ResourceTrackerSP RT = nullptr) {
    if (!RT)
      RT = MainJD.getDefaultResourceTracker();
    return InitHelperTransformLayer.add(RT, std::move(TSM));
  }

  Error initialize() {
    if (InitFunctions.empty())
      // Nothing to do if there are no initializers.
      return Error::success();

    // Lookup the symbols for the initializer functions.
    DenseMap<JITDylib *, SymbolLookupSet> LookupSymbols;
    LookupSymbols[&MainJD] = std::move(InitFunctions);
    auto LookupResult = Platform::lookupInitSymbols(*ES, LookupSymbols);
    if (!LookupResult)
      return LookupResult.takeError();

    // Collect the addresses of those symbols.
    std::vector<JITTargetAddress> Initializers;
    auto InitsItr = LookupResult->find(&MainJD);
    for (auto &KV : InitsItr->second)
      Initializers.push_back(KV.second.getAddress());

    // Run all initializer functions.
    for (auto InitFnAddr : Initializers) {
      auto *InitFn = jitTargetAddressToFunction<void (*)()>(InitFnAddr);
      InitFn();
    }
    return Error::success();
  }

  Expected<JITEvaluatedSymbol> lookup(StringRef Name) {
    return ES->lookup({&MainJD}, Mangle(Name.str()));
  }
};

} // end namespace orc
} // end namespace llvm

#endif // LLVM_EXECUTIONENGINE_ORC_KALEIDOSCOPEJIT_H
