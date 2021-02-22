//===- CilkSanitizer.cpp - Nondeterminism detector for Cilk/Tapir ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file is a part of CilkSan, a determinacy-race detector for Cilk
// programs.
//
// This instrumentation pass inserts calls to the runtime library before
// appropriate memory accesses.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Instrumentation/CilkSanitizer.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/CaptureTracking.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/MemoryBuiltins.h"
#include "llvm/Analysis/MustExecute.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/ScalarEvolutionExpander.h"
#include "llvm/Analysis/TapirRaceDetect.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Analysis/VectorUtils.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Module.h"
#include "llvm/InitializePasses.h"
#include "llvm/ProfileData/InstrProf.h"
#include "llvm/Transforms/Instrumentation.h"
#include "llvm/Transforms/Instrumentation/CSI.h"
#include "llvm/Transforms/IPO/FunctionAttrs.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/EscapeEnumerator.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/LoopSimplify.h"
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include "llvm/Transforms/Utils/PromoteMemToReg.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "cilksan"

STATISTIC(NumInstrumentedReads, "Number of instrumented reads");
STATISTIC(NumInstrumentedWrites, "Number of instrumented writes");
STATISTIC(NumAccessesWithBadSize, "Number of accesses with bad size");
STATISTIC(NumOmittedReadsBeforeWrite,
          "Number of reads ignored due to following writes");
STATISTIC(NumOmittedReadsFromConstants, "Number of reads from constant data");
STATISTIC(NumOmittedNonCaptured, "Number of accesses ignored due to capturing");
STATISTIC(NumInstrumentedMemIntrinsicReads,
          "Number of instrumented reads from memory intrinsics");
STATISTIC(NumInstrumentedMemIntrinsicWrites,
          "Number of instrumented writes from memory intrinsics");
STATISTIC(NumInstrumentedDetaches, "Number of instrumented detaches");
STATISTIC(NumInstrumentedDetachExits, "Number of instrumented detach exits");
STATISTIC(NumInstrumentedSyncs, "Number of instrumented syncs");
STATISTIC(NumInstrumentedAllocas, "Number of instrumented allocas");
STATISTIC(NumInstrumentedAllocFns,
          "Number of instrumented allocation functions");
STATISTIC(NumInstrumentedFrees, "Number of instrumented free calls");
STATISTIC(
    NumHoistedInstrumentedReads,
    "Number of reads whose instrumentation has been coalesced and hoisted");
STATISTIC(
    NumHoistedInstrumentedWrites,
    "Number of writes whose instrumentation has been coalesced and hoisted");
STATISTIC(NumSunkInstrumentedReads,
          "Number of reads whose instrumentation has been coalesced and sunk");
STATISTIC(NumSunkInstrumentedWrites,
          "Number of writes whose instrumentation has been coalesced and sunk");

static cl::opt<bool>
    EnableStaticRaceDetection(
        "enable-static-race-detection", cl::init(true), cl::Hidden,
        cl::desc("Enable static detection of determinacy races."));

static cl::opt<bool>
    AssumeRaceFreeLibraryFunctions(
        "assume-race-free-lib", cl::init(false), cl::Hidden,
        cl::desc("Assume library functions are race free."));

static cl::opt<bool>
    IgnoreInaccessibleMemory(
        "ignore-inaccessible-memory", cl::init(false), cl::Hidden,
        cl::desc("Ignore inaccessible memory when checking for races."));

static cl::opt<bool>
    AssumeNoExceptions(
        "cilksan-assume-no-exceptions", cl::init(false), cl::Hidden,
        cl::desc("Assume that ordinary calls cannot throw exceptions."));

static cl::opt<unsigned>
    MaxUsesToExploreCapture(
        "cilksan-max-uses-to-explore-capture", cl::init(unsigned(-1)),
        cl::Hidden,
        cl::desc("Maximum number of uses to explore for a capture query."));

static cl::opt<bool> MAAPChecks("cilksan-maap-checks", cl::init(true),
                                cl::Hidden,
                                cl::desc("Enable or disable MAAP checks."));

static cl::opt<bool> LoopHoisting(
    "cilksan-loop-hoisting", cl::init(true), cl::Hidden,
    cl::desc("Enable or disable hoisting instrumentation out of loops."));

static cl::opt<bool>
    IgnoreSanitizeCilkAttr(
        "ignore-sanitize-cilk-attr", cl::init(false), cl::Hidden,
        cl::desc("Ignore the 'sanitize_cilk' attribute when choosing what to "
                 "instrument."));

static const unsigned SERIESPARALLEL = 0x1;
static const unsigned SHADOWMEMORY = 0x2;
static cl::opt<unsigned> InstrumentationSet(
    "cilksan-instrumentation-set", cl::init(SERIESPARALLEL | SHADOWMEMORY),
    cl::Hidden,
    cl::desc("Specify the set of instrumentation hooks to insert."));

static const char *const CsanRtUnitInitName = "__csanrt_unit_init";
static const char *const CsiUnitObjTableName = "__csi_unit_obj_table";
static const char *const CsiUnitObjTableArrayName = "__csi_unit_obj_tables";

/// Maintains a mapping from CSI ID of a load or store to the source information
/// of the object accessed by that load or store.
class ObjectTable : public ForensicTable {
public:
  ObjectTable() : ForensicTable() {}
  ObjectTable(Module &M, StringRef BaseIdName) : ForensicTable(M, BaseIdName) {}

  /// The number of entries in this table
  uint64_t size() const { return LocalIdToSourceLocationMap.size(); }

  /// Add the given instruction to this table.
  /// \returns The local ID of the Instruction.
  uint64_t add(Instruction &I, Value *Obj);

  /// Get the Type for a pointer to a table entry.
  ///
  /// A table entry is just a source location.
  static PointerType *getPointerType(LLVMContext &C);

  /// Insert this table into the given Module.
  ///
  /// The table is constructed as a ConstantArray indexed by local IDs.  The
  /// runtime is responsible for performing the mapping that allows the table to
  /// be indexed by global ID.
  Constant *insertIntoModule(Module &M) const;

private:
  struct SourceLocation {
    StringRef Name;
    int32_t Line;
    StringRef Filename;
    StringRef Directory;
  };

  /// Map of local ID to SourceLocation.
  DenseMap<uint64_t, SourceLocation> LocalIdToSourceLocationMap;

  /// Create a struct type to match the "struct SourceLocation" type.
  /// (and the source_loc_t type in csi.h).
  static StructType *getSourceLocStructType(LLVMContext &C);

  /// Append the line and file information to the table.
  void add(uint64_t ID, int32_t Line = -1,
           StringRef Filename = "", StringRef Directory = "",
           StringRef Name = "");
};

namespace {
struct CilkSanitizerImpl : public CSIImpl {
  class SimpleInstrumentor {
  public:
    SimpleInstrumentor(CilkSanitizerImpl &CilkSanImpl, TaskInfo &TI,
                       LoopInfo &LI, DominatorTree *DT,
                       const TargetLibraryInfo *TLI)
        : CilkSanImpl(CilkSanImpl), TI(TI), LI(LI), DT(DT), TLI(TLI) {}

    bool InstrumentSimpleInstructions(
        SmallVectorImpl<Instruction *> &Instructions);
    bool InstrumentAnyMemIntrinsics(
        SmallVectorImpl<Instruction *> &MemIntrinsics);
    bool InstrumentCalls(SmallVectorImpl<Instruction *> &Calls);
    bool InstrumentAncillaryInstructions(
        SmallPtrSetImpl<Instruction *> &Allocas,
        SmallPtrSetImpl<Instruction *> &AllocationFnCalls,
        SmallPtrSetImpl<Instruction *> &FreeCalls,
        DenseMap<Value *, unsigned> &SyncRegNums,
        DenseMap<BasicBlock *, unsigned> &SRCounters, const DataLayout &DL);

  private:
    void getDetachesForInstruction(Instruction *I);

    CilkSanitizerImpl &CilkSanImpl;
    TaskInfo &TI;
    LoopInfo &LI;
    DominatorTree *DT;
    const TargetLibraryInfo *TLI;

    SmallPtrSet<DetachInst *, 8> Detaches;

    SmallVector<Instruction *, 8> DelayedSimpleInsts;
    SmallVector<std::pair<Instruction *, unsigned>, 8> DelayedMemIntrinsics;
    SmallVector<Instruction *, 8> DelayedCalls;
  };

  class Instrumentor {
  public:
    Instrumentor(CilkSanitizerImpl &CilkSanImpl, RaceInfo &RI, TaskInfo &TI,
                 LoopInfo &LI, DominatorTree *DT, const TargetLibraryInfo *TLI)
        : CilkSanImpl(CilkSanImpl), RI(RI), TI(TI), LI(LI), DT(DT), TLI(TLI) {}

    void InsertArgMAAPs(Function &F, Value *FuncId);
    bool InstrumentSimpleInstructions(
        SmallVectorImpl<Instruction *> &Instructions);
    bool InstrumentAnyMemIntrinsics(
        SmallVectorImpl<Instruction *> &MemIntrinsics);
    bool InstrumentCalls(SmallVectorImpl<Instruction *> &Calls);
    void GetDetachesForCoalescedInstrumentation(
        SmallPtrSetImpl<Instruction *> &LoopInstToHoist,
        SmallPtrSetImpl<Instruction *> &LoopInstToSink);
    bool InstrumentAncillaryInstructions(
        SmallPtrSetImpl<Instruction *> &Allocas,
        SmallPtrSetImpl<Instruction *> &AllocationFnCalls,
        SmallPtrSetImpl<Instruction *> &FreeCalls,
        DenseMap<Value *, unsigned> &SyncRegNums,
        DenseMap<BasicBlock *, unsigned> &SRCounters, const DataLayout &DL);
    bool InstrumentLoops(SmallPtrSetImpl<Instruction *> &LoopInstToHoist,
                         SmallPtrSetImpl<Instruction *> &LoopInstToSink,
                         SmallPtrSetImpl<const Loop *> &TapirLoops,
                         ScalarEvolution *);
    bool PerformDelayedInstrumentation();

  private:
    void getDetachesForInstruction(Instruction *I);
    // A MAAP (May Access Alias in Parallel) encodes static information about
    // memory access that may result in a race, in order to propagate that
    // information dynamically at runtime.  In particular, a MAAP for a pointer
    // argument to a called function communicates to the callee whether the
    // caller or some ancestor may read or write the referenced memory in
    // parallel and whether the caller can provide any noalias guarantee on that
    // memory location.
    enum class MAAPValue : uint8_t
      {
       NoAccess = 0,
       Mod = 1,
       Ref = 2,
       ModRef = Mod | Ref,
       NoAlias = 4,
      };
    static unsigned RaceTypeToFlagVal(RaceInfo::RaceType RT);
    // Get the MAAP value for specific instruction and operand.
    Value *getMAAPValue(Instruction *I, IRBuilder<> &IRB,
                        unsigned OperandNum = static_cast<unsigned>(-1),
                        MAAPValue DefaultMV = MAAPValue::ModRef,
                        bool CheckArgs = true);
    // Helper method to determine noalias MAAP bit.
    Value *getNoAliasMAAPValue(Instruction *I, IRBuilder<> &IRB,
                               unsigned OperandNum, MemoryLocation Loc,
                               const RaceInfo::RaceData &RD,
                               const Value *Obj, Value *MAAPVal);
    // Synthesize a check of the MAAP to determine whether the MAAP means we can
    // skip executing instrumentation for the given instruction.
    Value *getMAAPCheck(Instruction *I, IRBuilder<> &IRB,
                        unsigned OperandNum = static_cast<unsigned>(-1));
    // Helper method to read a MAAP value.
    Value *readMAAPVal(Value *V, IRBuilder<> &IRB);

    CilkSanitizerImpl &CilkSanImpl;
    RaceInfo &RI;
    TaskInfo &TI;
    LoopInfo &LI;
    DominatorTree *DT;
    const TargetLibraryInfo *TLI;

    SmallPtrSet<DetachInst *, 8> Detaches;

    DenseMap<const Value *, Value *> LocalMAAPs;
    SmallPtrSet<const Value *, 8> ArgMAAPs;

    SmallVector<Instruction *, 8> DelayedSimpleInsts;
    SmallVector<std::pair<Instruction *, unsigned>, 8> DelayedMemIntrinsics;
    SmallVector<Instruction *, 8> DelayedCalls;
  };

  CilkSanitizerImpl(Module &M, CallGraph *CG,
                    function_ref<DominatorTree &(Function &)> GetDomTree,
                    function_ref<TaskInfo &(Function &)> GetTaskInfo,
                    function_ref<LoopInfo &(Function &)> GetLoopInfo,
                    function_ref<RaceInfo &(Function &)> GetRaceInfo,
                    function_ref<TargetLibraryInfo &(Function &)> GetTLI,
                    function_ref<ScalarEvolution &(Function &)> GetSE,
                    // function_ref<TargetTransformInfo &(Function &)> GetTTI,
                    bool JitMode = false,
                    bool CallsMayThrow = !AssumeNoExceptions)
      : CSIImpl(M, CG, GetDomTree, GetLoopInfo, GetTaskInfo, GetTLI, GetSE,
                nullptr),
        GetRaceInfo(GetRaceInfo) {
    // Even though we're doing our own instrumentation, we want the CSI setup
    // for the instrumentation of function entry/exit, memory accesses (i.e.,
    // loads and stores), atomics, memory intrinsics.  We also want call sites,
    // for extracting debug information.
    Options.InstrumentBasicBlocks = false;
    Options.InstrumentLoops = true;
    // Cilksan defines its own hooks for instrumenting memory accesses, memory
    // intrinsics, and Tapir instructions, so we disable the default CSI
    // instrumentation hooks for these IR objects.
    Options.InstrumentMemoryAccesses = false;
    Options.InstrumentMemIntrinsics = false;
    Options.InstrumentTapir = false;
    Options.InstrumentCalls = false;
    Options.jitMode = JitMode;
    Options.CallsMayThrow = CallsMayThrow;
  }
  bool setup();
  bool run();

  static StructType *getUnitObjTableType(LLVMContext &C,
                                         PointerType *EntryPointerType);
  static Constant *objTableToUnitObjTable(Module &M,
                                          StructType *UnitObjTableType,
                                          ObjectTable &ObjTable);
  static bool isAllocFn(const Instruction *I, const TargetLibraryInfo *TLI);
  static bool isLibCall(const Instruction &I, const TargetLibraryInfo *TLI);
  static bool simpleCallCannotRace(const Instruction &I);
  static bool shouldIgnoreCall(const Instruction &I);
  static bool getAllocFnArgs(
      const Instruction *I, SmallVectorImpl<Value*> &AllocFnArgs,
      Type *SizeTy, Type *AddrTy, const TargetLibraryInfo &TLI);

  void setupBlocks(Function &F, DominatorTree *DT = nullptr,
                   LoopInfo *LI = nullptr);
  bool setupFunction(Function &F);

  // Methods for handling FED tables
  void initializeFEDTables() {}
  void collectUnitFEDTables() {}

  // Methods for handling object tables
  void initializeCsanObjectTables();
  void collectUnitObjectTables();

  // Create a call to the runtime unit initialization routine in a global
  // constructor.
  CallInst *createRTUnitInitCall(IRBuilder<> &IRB) override;

  // Initialize custom hooks for CilkSanitizer
  void initializeCsanHooks();

  Value *GetCalleeFuncID(const Function *Callee, IRBuilder<> &IRB);

  // Helper function for prepareToInstrumentFunction that chooses loads and
  // stores in a basic block to instrument.
  void chooseInstructionsToInstrument(SmallVectorImpl<Instruction *> &Local,
                                      SmallVectorImpl<Instruction *> &All,
                                      const TaskInfo &TI, LoopInfo &LI,
                                      const TargetLibraryInfo *TLI);

  // Helper methods for instrumenting different IR objects.
  bool instrumentLoadOrStore(Instruction *I, IRBuilder<> &IRB);
  bool instrumentLoadOrStore(Instruction *I) {
    IRBuilder<> IRB(I);
    return instrumentLoadOrStore(I, IRB);
  }
  bool instrumentAtomic(Instruction *I, IRBuilder<> &IRB);
  bool instrumentAtomic(Instruction *I) {
    IRBuilder<> IRB(I);
    return instrumentAtomic(I, IRB);
  }
  bool instrumentIntrinsicCall(Instruction *I,
                               SmallVectorImpl<Value *> *MAAPVals = nullptr);
  bool instrumentLibCall(Instruction *I,
                         SmallVectorImpl<Value *> *MAAPVals = nullptr);
  bool instrumentCallsite(Instruction *I,
                          SmallVectorImpl<Value *> *MAAPVals = nullptr);
  bool suppressCallsite(Instruction *I);
  bool instrumentAllocFnLibCall(Instruction *I, const TargetLibraryInfo *TLI);
  bool instrumentAllocationFn(Instruction *I, DominatorTree *DT,
                              const TargetLibraryInfo *TLI);
  bool instrumentFree(Instruction *I, const TargetLibraryInfo *TLI);
  bool instrumentDetach(DetachInst *DI, unsigned SyncRegNum,
                        unsigned NumSyncRegs, DominatorTree *DT, TaskInfo &TI,
                        LoopInfo &LI);
  bool instrumentSync(SyncInst *SI, unsigned SyncRegNum);
  void instrumentTapirLoop(Loop &L, TaskInfo &TI,
                      DenseMap<Value *, unsigned> &SyncRegNums,
                      ScalarEvolution *SE = nullptr);
  bool instrumentAlloca(Instruction *I);

  bool instrumentFunctionUsingRI(Function &F);
  // Helper method for RI-based race detection for instrumenting an access by a
  // memory intrinsic.
  bool instrumentAnyMemIntrinAcc(Instruction *I, unsigned OperandNum,
                                 IRBuilder<> &IRB);
  bool instrumentAnyMemIntrinAcc(Instruction *I, unsigned OperandNum) {
    IRBuilder<> IRB(I);
    return instrumentAnyMemIntrinAcc(I, OperandNum, IRB);
  }

  bool instrumentLoadOrStoreHoisted(Instruction *I,
                                    Value *Addr,
                                    Value *RangeVal,
                                    IRBuilder<> &IRB,
                                    uint64_t LocalId);

private:
  // Analysis results
  function_ref<RaceInfo &(Function &)> GetRaceInfo;

  // Instrumentation hooks
  FunctionCallee CsanFuncEntry = nullptr;
  FunctionCallee CsanFuncExit = nullptr;
  FunctionCallee CsanRead = nullptr;
  FunctionCallee CsanWrite = nullptr;
  FunctionCallee CsanLargeRead = nullptr;
  FunctionCallee CsanLargeWrite = nullptr;
  FunctionCallee CsanBeforeCallsite = nullptr;
  FunctionCallee CsanAfterCallsite = nullptr;
  FunctionCallee CsanDetach = nullptr;
  FunctionCallee CsanDetachContinue = nullptr;
  FunctionCallee CsanTaskEntry = nullptr;
  FunctionCallee CsanTaskExit = nullptr;
  FunctionCallee CsanSync = nullptr;
  FunctionCallee CsanBeforeLoop = nullptr;
  FunctionCallee CsanAfterLoop = nullptr;
  FunctionCallee CsanAfterAllocFn = nullptr;
  FunctionCallee CsanAfterFree = nullptr;

  // Hooks for suppressing instrumentation, e.g., around callsites that cannot
  // expose a race.
  FunctionCallee CsanDisableChecking = nullptr;
  FunctionCallee CsanEnableChecking = nullptr;

  FunctionCallee GetMAAP = nullptr;
  FunctionCallee SetMAAP = nullptr;

  // CilkSanitizer custom forensic tables
  ObjectTable LoadObj, StoreObj, AllocaObj, AllocFnObj;

  SmallVector<Constant *, 4> UnitObjTables;

  SmallVector<Instruction *, 8> AllocationFnCalls;
  SmallVector<Instruction *, 8> FreeCalls;
  SmallVector<Instruction *, 8> Allocas;
  SmallPtrSet<Instruction *, 8> ToInstrument;

  // Map of functions to updated race type, for interprocedural analysis of
  // races.
  DenseMap<const Function *, RaceInfo::RaceType> FunctionRaceType;
  DenseMap<const Value *, ModRefInfo> ObjectMRForRace;

  DenseMap<DetachInst *, SmallVector<SyncInst *, 2>> DetachToSync;

  bool LocalBaseObj(const Value *Addr, LoopInfo *LI,
                    const TargetLibraryInfo *TLI) const;
  bool PossibleRaceByCapture(const Value *Addr, const TaskInfo &TI,
                             LoopInfo *LI) const;
  bool unknownObjectUses(const Value *Addr, LoopInfo *LI,
                         const TargetLibraryInfo *TLI) const;

  // Cached results of calls to GetUnderlyingObjects.
  using BaseObjMapTy =
      DenseMap<const Value *, SmallVector<const Value *, 1>>;
  mutable BaseObjMapTy BaseObjects;
  SmallVectorImpl<const Value *> &lookupBaseObjects(const Value *Addr,
                                                    LoopInfo *LI) const {
    if (!BaseObjects.count(Addr)) {
      if (isa<GlobalValue>(Addr))
        BaseObjects.lookup(Addr);
      else
        GetUnderlyingObjects(Addr, BaseObjects[Addr], DL, LI, 0);
    }
    return BaseObjects[Addr];
  }

  bool MightHaveDetachedUse(const Value *Addr, const TaskInfo &TI) const;
  // // Cached results of calls to MightHaveDetachedUse.
  // using DetachedUseMapTy = DenseMap<const Value *, bool>;
  // mutable DetachedUseMapTy DetachedUseCache;
  bool lookupMightHaveDetachedUse(const Value *Addr, const TaskInfo &TI) const {
    return MightHaveDetachedUse(Addr, TI);
    // if (!DetachedUseCache.count(Addr))
    //   DetachedUseCache[Addr] = MightHaveDetachedUse(Addr, TI);
    // return DetachedUseCache[Addr];
  }

  // Cached results of calls to PointerMayBeCaptured.
  using MayBeCapturedMapTy = DenseMap<const Value *, bool>;
  mutable MayBeCapturedMapTy MayBeCapturedCache;
  bool lookupPointerMayBeCaptured(const Value *Ptr) const {
    if (!Ptr->getType()->isPointerTy())
      return false;

    if (!MayBeCapturedCache.count(Ptr)) {
      if (isa<GlobalValue>(Ptr))
        MayBeCapturedCache.lookup(Ptr);
      else
        MayBeCapturedCache[Ptr] = PointerMayBeCaptured(Ptr, true, false,
                                                       MaxUsesToExploreCapture);
    }
    return MayBeCapturedCache[Ptr];
  }

  FunctionCallee getOrInsertSynthesizedHook(StringRef Name, FunctionType *T,
                                            AttributeList AL);
};

/// CilkSanitizer: instrument the code in module to find races.
struct CilkSanitizerLegacyPass : public ModulePass {
  static char ID;  // Pass identification, replacement for typeid.
  CilkSanitizerLegacyPass(bool JitMode = false,
                          bool CallsMayThrow = !AssumeNoExceptions)
      : ModulePass(ID), JitMode(JitMode), CallsMayThrow(CallsMayThrow) {
    initializeCilkSanitizerLegacyPassPass(*PassRegistry::getPassRegistry());
  }
  StringRef getPassName() const override { return "CilkSanitizer"; }
  void getAnalysisUsage(AnalysisUsage &AU) const override;
  bool runOnModule(Module &M) override;

  bool JitMode = false;
  bool CallsMayThrow = true;
};
} // end anonymous namespace

char CilkSanitizerLegacyPass::ID = 0;

INITIALIZE_PASS_BEGIN(
    CilkSanitizerLegacyPass, "csan",
    "CilkSanitizer: detects determinacy races in Cilk programs.",
    false, false)
INITIALIZE_PASS_DEPENDENCY(BasicAAWrapperPass)
INITIALIZE_PASS_DEPENDENCY(AAResultsWrapperPass)
INITIALIZE_PASS_DEPENDENCY(GlobalsAAWrapperPass)
INITIALIZE_PASS_DEPENDENCY(CallGraphWrapperPass)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TapirRaceDetectWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TaskInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetLibraryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(ScalarEvolutionWrapperPass)
INITIALIZE_PASS_END(
    CilkSanitizerLegacyPass, "csan",
    "CilkSanitizer: detects determinacy races in Cilk programs.",
    false, false)

void CilkSanitizerLegacyPass::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<CallGraphWrapperPass>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.addRequired<LoopInfoWrapperPass>();
  AU.addRequired<TapirRaceDetectWrapperPass>();
  AU.addRequired<TaskInfoWrapperPass>();
  AU.addRequired<TargetLibraryInfoWrapperPass>();
  AU.addRequired<AAResultsWrapperPass>();
  AU.addPreserved<BasicAAWrapperPass>();
  AU.addRequired<ScalarEvolutionWrapperPass>();
}

ModulePass *llvm::createCilkSanitizerLegacyPass(bool JitMode) {
  return new CilkSanitizerLegacyPass(JitMode);
}

ModulePass *llvm::createCilkSanitizerLegacyPass(bool JitMode,
                                                bool CallsMayThrow) {
  return new CilkSanitizerLegacyPass(JitMode, CallsMayThrow);
}

uint64_t ObjectTable::add(Instruction &I, Value *Obj) {
  uint64_t ID = getId(&I);
  // First, if the underlying object is a global variable, get that variable's
  // debug information.
  if (GlobalVariable *GV = dyn_cast<GlobalVariable>(Obj)) {
    SmallVector<DIGlobalVariableExpression *, 1> DbgGVExprs;
    GV->getDebugInfo(DbgGVExprs);
    for (auto *GVE : DbgGVExprs) {
      auto *DGV = GVE->getVariable();
      if (DGV->getName() != "") {
        add(ID, DGV->getLine(), DGV->getFilename(), DGV->getDirectory(),
            DGV->getName());
        return ID;
      }
    }
    add(ID, -1, "", "", Obj->getName());
    return ID;
  }

  // Next, if this is an alloca instruction, look for a llvm.dbg.declare
  // intrinsic.
  if (AllocaInst *AI = dyn_cast<AllocaInst>(Obj)) {
    TinyPtrVector<DbgVariableIntrinsic *> DbgDeclares = FindDbgAddrUses(AI);
    if (!DbgDeclares.empty()) {
      auto *LV = DbgDeclares.front()->getVariable();
      add(ID, LV->getLine(), LV->getFilename(), LV->getDirectory(),
          LV->getName());
      return ID;
    }
  }

  // Otherwise just examine the llvm.dbg.value intrinsics for this object.
  SmallVector<DbgValueInst *, 1> DbgValues;
  findDbgValues(DbgValues, Obj);
  for (auto *DVI : DbgValues) {
    auto *LV = DVI->getVariable();
    if (LV->getName() != "") {
      add(ID, LV->getLine(), LV->getFilename(), LV->getDirectory(),
          LV->getName());
      return ID;
    }
  }

  add(ID, -1, "", "", Obj->getName());
  return ID;
}

PointerType *ObjectTable::getPointerType(LLVMContext &C) {
  return PointerType::get(getSourceLocStructType(C), 0);
}

StructType *ObjectTable::getSourceLocStructType(LLVMContext &C) {
  return StructType::get(
      /* Name */ PointerType::get(IntegerType::get(C, 8), 0),
      /* Line */ IntegerType::get(C, 32),
      /* File */ PointerType::get(IntegerType::get(C, 8), 0));
}

void ObjectTable::add(uint64_t ID, int32_t Line,
                      StringRef Filename, StringRef Directory,
                      StringRef Name) {
  assert(LocalIdToSourceLocationMap.find(ID) ==
             LocalIdToSourceLocationMap.end() &&
         "Id already exists in FED table.");
  LocalIdToSourceLocationMap[ID] = {Name, Line, Filename, Directory};
}

// The order of arguments to ConstantStruct::get() must match the
// obj_source_loc_t type in csan.h.
static void addObjTableEntries(SmallVectorImpl<Constant *> &TableEntries,
                               StructType *TableType, Constant *Name,
                               Constant *Line, Constant *File) {
  TableEntries.push_back(ConstantStruct::get(TableType, Name, Line, File));
}

Constant *ObjectTable::insertIntoModule(Module &M) const {
  LLVMContext &C = M.getContext();
  StructType *TableType = getSourceLocStructType(C);
  IntegerType *Int32Ty = IntegerType::get(C, 32);
  Constant *Zero = ConstantInt::get(Int32Ty, 0);
  Value *GepArgs[] = {Zero, Zero};
  SmallVector<Constant *, 6> TableEntries;

  // Get the object-table entries for each ID.
  for (uint64_t LocalID = 0; LocalID < IdCounter; ++LocalID) {
    const SourceLocation &E = LocalIdToSourceLocationMap.find(LocalID)->second;
    // Source line
    Constant *Line = ConstantInt::get(Int32Ty, E.Line);
    // Source file
    Constant *File;
    {
      std::string Filename = E.Filename.str();
      if (!E.Directory.empty())
        Filename = E.Directory.str() + "/" + Filename;
      File = getObjectStrGV(M, Filename, "__csi_unit_filename_");
    }
    // Variable name
    Constant *Name = getObjectStrGV(M, E.Name, "__csi_unit_object_name_");

    // Add entry to the table
    addObjTableEntries(TableEntries, TableType, Name, Line, File);
  }

  ArrayType *TableArrayType = ArrayType::get(TableType, TableEntries.size());
  Constant *Table = ConstantArray::get(TableArrayType, TableEntries);
  GlobalVariable *GV =
    new GlobalVariable(M, TableArrayType, false, GlobalValue::InternalLinkage,
                       Table, CsiUnitObjTableName);
  return ConstantExpr::getGetElementPtr(GV->getValueType(), GV, GepArgs);
}

namespace {

using SCCNodeSet = SmallSetVector<Function *, 8>;

} // end anonymous namespace

bool CilkSanitizerImpl::setup() {
  // Setup functions for instrumentation.
  for (scc_iterator<CallGraph *> I = scc_begin(CG); !I.isAtEnd(); ++I) {
    const std::vector<CallGraphNode *> &SCC = *I;
    for (CallGraphNode *N : SCC)
      if (Function *F = N->getFunction())
        setupFunction(*F);
  }
  return true;
}

bool CilkSanitizerImpl::run() {
  // Initialize components of the CSI and Cilksan system.
  initializeCsi();
  initializeFEDTables();
  initializeCsanObjectTables();
  initializeCsanHooks();

  // Evaluate the SCC's in the callgraph in post order to support
  // interprocedural analysis of potential races in the module.
  SmallVector<Function *, 16> InstrumentedFunctions;

  // Instrument functions.
  for (scc_iterator<CallGraph *> I = scc_begin(CG); !I.isAtEnd(); ++I) {
    const std::vector<CallGraphNode *> &SCC = *I;
    for (CallGraphNode *N : SCC) {
      if (Function *F = N->getFunction())
        if (instrumentFunctionUsingRI(*F))
          InstrumentedFunctions.push_back(F);
    }
  }
  // After all functions have been analyzed and instrumented, update their
  // attributes.
  for (Function *F : InstrumentedFunctions) {
    updateInstrumentedFnAttrs(*F);
    F->removeFnAttr(Attribute::SanitizeCilk);
  }

  CSIImpl::collectUnitFEDTables();
  collectUnitFEDTables();
  collectUnitObjectTables();
  finalizeCsi();
  return true;
}

void CilkSanitizerImpl::initializeCsanObjectTables() {
  LoadObj = ObjectTable(M, CsiLoadBaseIdName);
  StoreObj = ObjectTable(M, CsiStoreBaseIdName);
  AllocaObj = ObjectTable(M, CsiAllocaBaseIdName);
  AllocFnObj = ObjectTable(M, CsiAllocFnBaseIdName);
}

// Create a struct type to match the unit_obj_entry_t type in csanrt.c.
StructType *CilkSanitizerImpl::getUnitObjTableType(
    LLVMContext &C, PointerType *EntryPointerType) {
  return StructType::get(IntegerType::get(C, 64), EntryPointerType);
}

Constant *CilkSanitizerImpl::objTableToUnitObjTable(
    Module &M, StructType *UnitObjTableType, ObjectTable &ObjTable) {
  Constant *NumEntries =
    ConstantInt::get(IntegerType::get(M.getContext(), 64), ObjTable.size());
  // Constant *BaseIdPtr =
  //   ConstantExpr::getPointerCast(FedTable.baseId(),
  //                                Type::getInt8PtrTy(M.getContext(), 0));
  Constant *InsertedTable = ObjTable.insertIntoModule(M);
  return ConstantStruct::get(UnitObjTableType, NumEntries,
                             InsertedTable);
}

void CilkSanitizerImpl::collectUnitObjectTables() {
  LLVMContext &C = M.getContext();
  StructType *UnitObjTableType =
      getUnitObjTableType(C, ObjectTable::getPointerType(C));

  UnitObjTables.push_back(
      objTableToUnitObjTable(M, UnitObjTableType, LoadObj));
  UnitObjTables.push_back(
      objTableToUnitObjTable(M, UnitObjTableType, StoreObj));
  UnitObjTables.push_back(
      objTableToUnitObjTable(M, UnitObjTableType, AllocaObj));
  UnitObjTables.push_back(
      objTableToUnitObjTable(M, UnitObjTableType, AllocFnObj));
}

CallInst *CilkSanitizerImpl::createRTUnitInitCall(IRBuilder<> &IRB) {
  LLVMContext &C = M.getContext();

  StructType *UnitFedTableType =
      getUnitFedTableType(C, FrontEndDataTable::getPointerType(C));
  StructType *UnitObjTableType =
      getUnitObjTableType(C, ObjectTable::getPointerType(C));

  // Lookup __csanrt_unit_init
  SmallVector<Type *, 4> InitArgTypes({IRB.getInt8PtrTy(),
                                       PointerType::get(UnitFedTableType, 0),
                                       PointerType::get(UnitObjTableType, 0),
                                       InitCallsiteToFunction->getType()});
  FunctionType *InitFunctionTy =
      FunctionType::get(IRB.getVoidTy(), InitArgTypes, false);
  RTUnitInit = M.getOrInsertFunction(CsanRtUnitInitName, InitFunctionTy);
  assert(isa<Function>(RTUnitInit.getCallee()) &&
         "Failed to get or insert __csanrt_unit_init function");

  ArrayType *UnitFedTableArrayType =
      ArrayType::get(UnitFedTableType, UnitFedTables.size());
  Constant *FEDTable = ConstantArray::get(UnitFedTableArrayType, UnitFedTables);
  GlobalVariable *FEDGV = new GlobalVariable(M, UnitFedTableArrayType, false,
                                             GlobalValue::InternalLinkage, FEDTable,
                                             CsiUnitFedTableArrayName);

  ArrayType *UnitObjTableArrayType =
      ArrayType::get(UnitObjTableType, UnitObjTables.size());
  Constant *ObjTable = ConstantArray::get(UnitObjTableArrayType, UnitObjTables);
  GlobalVariable *ObjGV = new GlobalVariable(M, UnitObjTableArrayType, false,
                                             GlobalValue::InternalLinkage, ObjTable,
                                             CsiUnitObjTableArrayName);

  Constant *Zero = ConstantInt::get(IRB.getInt32Ty(), 0);
  Value *GepArgs[] = {Zero, Zero};

  // Insert call to __csanrt_unit_init
  return IRB.CreateCall(
      RTUnitInit,
      {IRB.CreateGlobalStringPtr(M.getName()),
          ConstantExpr::getGetElementPtr(FEDGV->getValueType(), FEDGV, GepArgs),
          ConstantExpr::getGetElementPtr(ObjGV->getValueType(), ObjGV, GepArgs),
          InitCallsiteToFunction});
}

// Initialize all instrumentation hooks that are specific to CilkSanitizer.
void CilkSanitizerImpl::initializeCsanHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *FuncPropertyTy = CsiFuncProperty::getType(C);
  Type *FuncExitPropertyTy = CsiFuncExitProperty::getType(C);
  Type *TaskPropertyTy = CsiTaskProperty::getType(C);
  Type *TaskExitPropertyTy = CsiTaskExitProperty::getType(C);
  Type *LoadPropertyTy = CsiLoadStoreProperty::getType(C);
  Type *StorePropertyTy = CsiLoadStoreProperty::getType(C);
  Type *CallPropertyTy = CsiCallProperty::getType(C);
  Type *LoopPropertyTy = CsiLoopProperty::getType(C);
  Type *AllocFnPropertyTy = CsiAllocFnProperty::getType(C);
  Type *FreePropertyTy = CsiFreeProperty::getType(C);
  Type *RetType = IRB.getVoidTy();
  Type *AddrType = IRB.getInt8PtrTy();
  Type *NumBytesType = IRB.getInt32Ty();
  Type *LargeNumBytesType = IntptrTy;
  Type *IDType = IRB.getInt64Ty();

  AttributeList GeneralFnAttrs;
  GeneralFnAttrs = GeneralFnAttrs.addAttribute(
      C, AttributeList::FunctionIndex, Attribute::InaccessibleMemOrArgMemOnly);
  GeneralFnAttrs = GeneralFnAttrs.addAttribute(C, AttributeList::FunctionIndex,
                                               Attribute::NoUnwind);
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::ReadNone);
    FnAttrs = FnAttrs.addParamAttribute(C, 2, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 2, Attribute::ReadNone);
    CsanFuncEntry = M.getOrInsertFunction("__csan_func_entry", FnAttrs, RetType,
                                          /* func_id */ IDType,
                                          /* frame_ptr */ AddrType,
                                          /* stack_ptr */ AddrType,
                                          FuncPropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanFuncExit = M.getOrInsertFunction("__csan_func_exit", FnAttrs, RetType,
                                         /* func_exit_id */ IDType,
                                         /* func_id */ IDType,
                                         FuncExitPropertyTy);
  }

  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::ReadNone);
    CsanRead = M.getOrInsertFunction("__csan_load", FnAttrs, RetType, IDType,
                                     AddrType, NumBytesType, LoadPropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::ReadNone);
    CsanWrite = M.getOrInsertFunction("__csan_store", FnAttrs, RetType, IDType,
                                      AddrType, NumBytesType, StorePropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::ReadNone);
    CsanLargeRead = M.getOrInsertFunction("__csan_large_load", FnAttrs, RetType,
                                          IDType, AddrType, LargeNumBytesType,
                                          LoadPropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::ReadNone);
    CsanLargeWrite = M.getOrInsertFunction("__csan_large_store", FnAttrs,
                                           RetType, IDType, AddrType,
                                           LargeNumBytesType, StorePropertyTy);
  }

  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanBeforeCallsite = M.getOrInsertFunction("__csan_before_call", FnAttrs,
                                               IRB.getVoidTy(), IDType,
                                               /*callee func_id*/ IDType,
                                               IRB.getInt8Ty(), CallPropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanAfterCallsite = M.getOrInsertFunction("__csan_after_call", FnAttrs,
                                              IRB.getVoidTy(), IDType, IDType,
                                              IRB.getInt8Ty(), CallPropertyTy);
  }

  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanDetach = M.getOrInsertFunction("__csan_detach", FnAttrs, RetType,
                                       /* detach_id */ IDType,
                                       /* sync_reg */ IRB.getInt8Ty());
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 2, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 2, Attribute::ReadNone);
    FnAttrs = FnAttrs.addParamAttribute(C, 3, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 3, Attribute::ReadNone);
    CsanTaskEntry = M.getOrInsertFunction("__csan_task", FnAttrs, RetType,
                                          /* task_id */ IDType,
                                          /* detach_id */ IDType,
                                          /* frame_ptr */ AddrType,
                                          /* stack_ptr */ AddrType,
                                          TaskPropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanTaskExit = M.getOrInsertFunction("__csan_task_exit", FnAttrs, RetType,
                                         /* task_exit_id */ IDType,
                                         /* task_id */ IDType,
                                         /* detach_id */ IDType,
                                         /* sync_reg */ IRB.getInt8Ty(),
                                         TaskExitPropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanDetachContinue = M.getOrInsertFunction("__csan_detach_continue",
                                               FnAttrs, RetType,
                                               /* detach_continue_id */ IDType,
                                               /* detach_id */ IDType);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanSync = M.getOrInsertFunction("__csan_sync", FnAttrs, RetType, IDType,
                                     /* sync_reg */ IRB.getInt8Ty());
  }

  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::ReadNone);
    FnAttrs = FnAttrs.addParamAttribute(C, 5, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 5, Attribute::ReadNone);
    CsanAfterAllocFn = M.getOrInsertFunction(
        "__csan_after_allocfn", FnAttrs, RetType, IDType,
        /* new ptr */ AddrType, /* size */ LargeNumBytesType,
        /* num elements */ LargeNumBytesType, /* alignment */ LargeNumBytesType,
        /* old ptr */ AddrType, /* property */ AllocFnPropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::NoCapture);
    FnAttrs = FnAttrs.addParamAttribute(C, 1, Attribute::ReadNone);
    CsanAfterFree = M.getOrInsertFunction("__csan_after_free", FnAttrs, RetType,
                                          IDType, AddrType,
                                          /* property */ FreePropertyTy);
  }

  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanDisableChecking = M.getOrInsertFunction("__cilksan_disable_checking",
                                                FnAttrs, RetType);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanEnableChecking = M.getOrInsertFunction("__cilksan_enable_checking",
                                               FnAttrs, RetType);
  }

  Type *MAAPTy = IRB.getInt8Ty();
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    FnAttrs = FnAttrs.addParamAttribute(C, 0, Attribute::NoCapture);
    GetMAAP = M.getOrInsertFunction("__csan_get_MAAP", FnAttrs, RetType,
                                    PointerType::get(MAAPTy, 0), IDType,
                                    IRB.getInt8Ty());
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    SetMAAP = M.getOrInsertFunction("__csan_set_MAAP", FnAttrs, RetType, MAAPTy,
                                    IDType);
  }

  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanBeforeLoop = M.getOrInsertFunction(
        "__csan_before_loop", FnAttrs, IRB.getVoidTy(), IDType,
        IRB.getInt64Ty(), LoopPropertyTy);
  }
  {
    AttributeList FnAttrs = GeneralFnAttrs;
    CsanAfterLoop = M.getOrInsertFunction("__csan_after_loop", FnAttrs,
                                          IRB.getVoidTy(), IDType,
                                          IRB.getInt8Ty(), LoopPropertyTy);
  }

  // Cilksan-specific attributes on CSI hooks
  Function *CsiAfterAllocaFn = cast<Function>(CsiAfterAlloca.getCallee());
  CsiAfterAllocaFn->addParamAttr(1, Attribute::NoCapture);
  CsiAfterAllocaFn->addParamAttr(1, Attribute::ReadNone);
  CsiAfterAllocaFn->addFnAttr(Attribute::InaccessibleMemOrArgMemOnly);
  CsiAfterAllocaFn->setDoesNotThrow();
}

static BasicBlock *SplitOffPreds(
    BasicBlock *BB, SmallVectorImpl<BasicBlock *> &Preds, DominatorTree *DT,
    LoopInfo *LI) {
  if (BB->isLandingPad()) {
    SmallVector<BasicBlock *, 2> NewBBs;
    SplitLandingPadPredecessors(BB, Preds, ".csi-split-lp", ".csi-split",
                                NewBBs, DT, LI);
    return NewBBs[1];
  }

  SplitBlockPredecessors(BB, Preds, ".csi-split", DT, LI);
  return BB;
}

// Setup each block such that all of its predecessors belong to the same CSI ID
// space.
static void setupBlock(BasicBlock *BB, DominatorTree *DT, LoopInfo *LI,
                       const TargetLibraryInfo *TLI) {
  if (BB->getUniquePredecessor())
    return;

  SmallVector<BasicBlock *, 4> DetachPreds;
  SmallVector<BasicBlock *, 4> TFResumePreds;
  SmallVector<BasicBlock *, 4> SyncPreds;
  SmallVector<BasicBlock *, 4> SyncUnwindPreds;
  SmallVector<BasicBlock *, 4> AllocFnPreds;
  DenseMap<const Function *, SmallVector<BasicBlock *, 4>> LibCallPreds;
  SmallVector<BasicBlock *, 4> InvokePreds;
  bool HasOtherPredTypes = false;
  unsigned NumPredTypes = 0;

  // Partition the predecessors of the landing pad.
  for (BasicBlock *Pred : predecessors(BB)) {
    if (isa<DetachInst>(Pred->getTerminator()) ||
        isDetachedRethrow(Pred->getTerminator()))
      DetachPreds.push_back(Pred);
    else if (isTaskFrameResume(Pred->getTerminator()))
      TFResumePreds.push_back(Pred);
    else if (isa<SyncInst>(Pred->getTerminator()))
      SyncPreds.push_back(Pred);
    else if (isSyncUnwind(Pred->getTerminator()))
      SyncUnwindPreds.push_back(Pred);
    else if (CilkSanitizerImpl::isAllocFn(Pred->getTerminator(), TLI))
      AllocFnPreds.push_back(Pred);
    else if (CilkSanitizerImpl::isLibCall(*Pred->getTerminator(), TLI)) {
      const Function *Called =
          dyn_cast<CallBase>(Pred->getTerminator())->getCalledFunction();
      LibCallPreds[Called].push_back(Pred);
    } else if (isa<InvokeInst>(Pred->getTerminator()))
      InvokePreds.push_back(Pred);
    else
      HasOtherPredTypes = true;
  }

  NumPredTypes = static_cast<unsigned>(!DetachPreds.empty()) +
    static_cast<unsigned>(!TFResumePreds.empty()) +
    static_cast<unsigned>(!SyncPreds.empty()) +
    static_cast<unsigned>(!SyncUnwindPreds.empty()) +
    static_cast<unsigned>(!AllocFnPreds.empty()) +
    static_cast<unsigned>(LibCallPreds.size()) +
    static_cast<unsigned>(!InvokePreds.empty()) +
    static_cast<unsigned>(HasOtherPredTypes);

  BasicBlock *BBToSplit = BB;
  // Split off the predecessors of each type.
  if (!SyncPreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, SyncPreds, DT, LI);
    NumPredTypes--;
  }
  if (!SyncUnwindPreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, SyncUnwindPreds, DT, LI);
    NumPredTypes--;
  }
  if (!AllocFnPreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, AllocFnPreds, DT, LI);
    NumPredTypes--;
  }
  if (!LibCallPreds.empty() && NumPredTypes > 1) {
    for (auto KeyVal : LibCallPreds) {
      if (NumPredTypes > 1) {
        BBToSplit = SplitOffPreds(BBToSplit, KeyVal.second, DT, LI);
        NumPredTypes--;
      }
    }
  }
  if (!InvokePreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, InvokePreds, DT, LI);
    NumPredTypes--;
  }
  if (!TFResumePreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, TFResumePreds, DT, LI);
    NumPredTypes--;
  }
  // We handle detach and detached.rethrow predecessors at the end to preserve
  // invariants on the CFG structure about the deadness of basic blocks after
  // detached-rethrows.
  if (!DetachPreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, DetachPreds, DT, LI);
    NumPredTypes--;
  }
}

// Setup all basic blocks such that each block's predecessors belong entirely to
// one CSI ID space.
void CilkSanitizerImpl::setupBlocks(Function &F, DominatorTree *DT,
                                    LoopInfo *LI) {
  SmallPtrSet<BasicBlock *, 8> BlocksToSetup;
  for (BasicBlock &BB : F) {
    if (BB.isLandingPad())
      BlocksToSetup.insert(&BB);

    if (InvokeInst *II = dyn_cast<InvokeInst>(BB.getTerminator())) {
      if (!isTapirPlaceholderSuccessor(II->getNormalDest()))
        BlocksToSetup.insert(II->getNormalDest());
    } else if (SyncInst *SI = dyn_cast<SyncInst>(BB.getTerminator()))
      BlocksToSetup.insert(SI->getSuccessor(0));
  }

  for (BasicBlock *BB : BlocksToSetup)
    setupBlock(BB, DT, LI, &GetTLI(F));
}

// Do not instrument known races/"benign races" that come from compiler
// instrumentation. The user has no way of suppressing them.
static bool shouldInstrumentReadWriteFromAddress(const Module *M, Value *Addr) {
  // Peel off GEPs and BitCasts.
  Addr = Addr->stripInBoundsOffsets();

  if (GlobalVariable *GV = dyn_cast<GlobalVariable>(Addr)) {
    if (GV->hasSection()) {
      StringRef SectionName = GV->getSection();
      // Check if the global is in the PGO counters section.
      auto OF = Triple(M->getTargetTriple()).getObjectFormat();
      if (SectionName.endswith(
              getInstrProfSectionName(IPSK_cnts, OF,
                                      /*AddSegmentInfo*/ false)))
        return false;
    }

    // Check if the global is private gcov data.
    if (GV->getName().startswith("__llvm_gcov") ||
        GV->getName().startswith("__llvm_gcda"))
      return false;
  }

  // Do not instrument acesses from different address spaces; we cannot deal
  // with them.
  if (Addr) {
    Type *PtrTy = cast<PointerType>(Addr->getType()->getScalarType());
    if (PtrTy->getPointerAddressSpace() != 0)
      return false;
  }

  return true;
}

/// Returns true if Addr can only refer to a locally allocated base object, that
/// is, an object created via an AllocaInst or an AllocationFn.
bool CilkSanitizerImpl::LocalBaseObj(const Value *Addr, LoopInfo *LI,
                                     const TargetLibraryInfo *TLI) const {
  // If we don't have an address, give up.
  if (!Addr)
    return false;

  // Get the base objects that this address might refer to.
  SmallVectorImpl<const Value *> &BaseObjs = lookupBaseObjects(Addr, LI);

  // If we could not determine the base objects, conservatively return false.
  if (BaseObjs.empty())
    return false;

  // If any base object is not an alloca or allocation function, then it's not
  // local.
  for (const Value *BaseObj : BaseObjs) {
    if (isa<AllocaInst>(BaseObj) || isNoAliasCall(BaseObj))
      continue;

    if (const Argument *A = dyn_cast<Argument>(BaseObj))
      if (A->hasByValAttr())
        continue;

    LLVM_DEBUG(dbgs() << "Non-local base object " << *BaseObj << "\n");
    return false;
  }

  return true;
}

// Examine the uses of a Instruction AI to determine if it is used in a subtask.
// This method assumes that AI is an allocation instruction, i.e., either an
// AllocaInst or an AllocationFn.
bool CilkSanitizerImpl::MightHaveDetachedUse(const Value *V,
                                             const TaskInfo &TI) const {
  // Get the task for this allocation.
  const Task *AllocTask = nullptr;
  if (const Instruction *I = dyn_cast<Instruction>(V))
    AllocTask = TI.getTaskFor(I->getParent());
  else if (const Argument *A = dyn_cast<Argument>(V))
    AllocTask = TI.getTaskFor(&A->getParent()->getEntryBlock());

  // assert(AllocTask && "Null task for instruction.");
  if (!AllocTask) {
    LLVM_DEBUG(dbgs() << "MightHaveDetachedUse: No task found for given value "
               << *V << "\n");
    return false;
  }

  if (AllocTask->isSerial())
    // Alloc AI cannot be used in a subtask if its enclosing task is serial.
    return false;

  SmallVector<const Use *, 20> Worklist;
  SmallSet<const Use *, 20> Visited;

  // Add all uses of AI to the worklist.
  for (const Use &U : V->uses()) {
    Visited.insert(&U);
    Worklist.push_back(&U);
  }

  // Evaluate each use of AI.
  while (!Worklist.empty()) {
    const Use *U = Worklist.pop_back_val();

    // Check if this use of AI is in a different task from the allocation.
    Instruction *I = cast<Instruction>(U->getUser());
    LLVM_DEBUG(dbgs() << "\tExamining use: " << *I << "\n");
    if (AllocTask != TI.getTaskFor(I->getParent())) {
      assert(TI.getTaskFor(I->getParent()) != AllocTask->getParentTask() &&
             "Use of alloca appears in a parent task of that alloca");
      // Because the use of AI cannot appear in a parent task of AI, it must be
      // in a subtask.  In particular, the use cannot be in a shared-EH spindle.
      return true;
    }

    // If the pointer to AI is transformed using one of the following
    // operations, add uses of the transformed pointer to the worklist.
    switch (I->getOpcode()) {
    case Instruction::BitCast:
    case Instruction::GetElementPtr:
    case Instruction::PHI:
    case Instruction::Select:
    case Instruction::AddrSpaceCast:
      for (Use &UU : I->uses())
        if (Visited.insert(&UU).second)
          Worklist.push_back(&UU);
      break;
    default:
      break;
    }
  }
  return false;
}

/// Returns true if accesses on Addr could race due to pointer capture.
bool CilkSanitizerImpl::PossibleRaceByCapture(const Value *Addr,
                                              const TaskInfo &TI,
                                              LoopInfo *LI) const {
  if (isa<GlobalValue>(Addr))
    // For this analysis, we consider all global values to be captured.
    return true;

  // Check for detached uses of the underlying base objects.
  SmallVectorImpl<const Value *> &BaseObjs = lookupBaseObjects(Addr, LI);

  // If we could not determine the base objects, conservatively return true.
  if (BaseObjs.empty())
    return true;

  for (const Value *BaseObj : BaseObjs) {
    // Skip any null objects
    if (const Constant *C = dyn_cast<Constant>(BaseObj)) {
      // if (C->isNullValue())
      //   continue;
      // Is this value a constant that cannot be derived from any pointer
      // value (we need to exclude constant expressions, for example, that
      // are formed from arithmetic on global symbols).
      bool IsNonPtrConst = isa<ConstantInt>(C) || isa<ConstantFP>(C) ||
                           isa<ConstantPointerNull>(C) ||
                           isa<ConstantDataVector>(C) || isa<UndefValue>(C);
      if (IsNonPtrConst)
        continue;
    }

    // If the base object is not an instruction, conservatively return true.
    if (!isa<Instruction>(BaseObj)) {
      // From BasicAliasAnalysis.cpp: If this is an argument that corresponds to
      // a byval or noalias argument, then it has not escaped before entering
      // the function.
      if (const Argument *A = dyn_cast<Argument>(BaseObj)) {
        if (!A->hasByValAttr() && !A->hasNoAliasAttr())
          return true;
      } else
        return true;
    }

    // If the base object might have a detached use, return true.
    if (lookupMightHaveDetachedUse(BaseObj, TI))
      return true;
  }

  // Perform normal pointer-capture analysis.
  // if (PointerMayBeCaptured(Addr, false, false))
  if (lookupPointerMayBeCaptured(Addr))
    return true;

  return false;
}

bool CilkSanitizerImpl::unknownObjectUses(const Value *Addr, LoopInfo *LI,
                                          const TargetLibraryInfo *TLI) const {
  // Perform normal pointer-capture analysis.
  if (lookupPointerMayBeCaptured(Addr))
    return true;

  // Check for detached uses of the underlying base objects.
  SmallVectorImpl<const Value *> &BaseObjs = lookupBaseObjects(Addr, LI);

  // If we could not determine the base objects, conservatively return true.
  if (BaseObjs.empty())
    return true;

  // If the base object is not an allocation function, return true.
  for (const Value *BaseObj : BaseObjs)
    if (!isAllocationFn(BaseObj, TLI))
      return true;

  return false;
}

void CilkSanitizerImpl::chooseInstructionsToInstrument(
    SmallVectorImpl<Instruction *> &Local, SmallVectorImpl<Instruction *> &All,
    const TaskInfo &TI, LoopInfo &LI, const TargetLibraryInfo *TLI) {
  SmallSet<Value*, 8> WriteTargets;
  // Iterate from the end.
  for (Instruction *I : reverse(Local)) {
    if (StoreInst *Store = dyn_cast<StoreInst>(I)) {
      Value *Addr = Store->getPointerOperand();
      if (!shouldInstrumentReadWriteFromAddress(I->getModule(), Addr))
        continue;
      WriteTargets.insert(Addr);
    } else {
      LoadInst *Load = cast<LoadInst>(I);
      Value *Addr = Load->getPointerOperand();
      if (!shouldInstrumentReadWriteFromAddress(I->getModule(), Addr))
        continue;
      if (WriteTargets.count(Addr)) {
        // We will write to this temp, so no reason to analyze the read.
        NumOmittedReadsBeforeWrite++;
        continue;
      }
      if (addrPointsToConstantData(Addr)) {
        // Addr points to some constant data -- it can not race with any writes.
        NumOmittedReadsFromConstants++;
        continue;
      }
    }
    Value *Addr = isa<StoreInst>(*I)
        ? cast<StoreInst>(I)->getPointerOperand()
        : cast<LoadInst>(I)->getPointerOperand();
    if (LocalBaseObj(Addr, &LI, TLI) &&
        !PossibleRaceByCapture(Addr, TI, &LI)) {
      // The variable is addressable but not captured, so it cannot be
      // referenced from a different thread and participate in a data race
      // (see llvm/Analysis/CaptureTracking.h for details).
      NumOmittedNonCaptured++;
      continue;
    }
    LLVM_DEBUG(dbgs() << "Pushing " << *I << "\n");
    All.push_back(I);
  }
  Local.clear();
}

bool CilkSanitizerImpl::isAllocFn(const Instruction *I,
                                  const TargetLibraryInfo *TLI) {
  if (!isa<CallBase>(I))
    return false;

  if (!TLI)
    return false;

  if (isAllocationFn(I, TLI, /*LookThroughBitCast*/ false,
                     /*IgnoreBuiltinAttr*/ true))
    return true;

  if (const Function *Called = dyn_cast<CallBase>(I)->getCalledFunction()) {
    if (Called->getName() != "posix_memalign")
      return false;

    // Confirm that this function is a recognized library function
    LibFunc F;
    bool FoundLibFunc = TLI->getLibFunc(*Called, F);
    return FoundLibFunc;
  }

  return false;
}

bool CilkSanitizerImpl::isLibCall(const Instruction &I,
                                  const TargetLibraryInfo *TLI) {
  if (!isa<CallBase>(I))
    return false;

  if (!TLI)
    return false;

  if (const Function *Called = dyn_cast<CallBase>(&I)->getCalledFunction()) {
    LibFunc F;
    bool FoundLibFunc = TLI->getLibFunc(*Called, F);
    if (FoundLibFunc)
      return true;
  }

  return false;
}

// Helper function to determine if the call-base instruction \p I should be
// skipped when examining calls that affect race detection.  Returns true if and
// only if \p I is a simple call that cannot race.
bool CilkSanitizerImpl::simpleCallCannotRace(const Instruction &I) {
  return callsPlaceholderFunction(I);
}

// Helper function to determine if the call-base instruction \p I should be
// skipped when examining calls that affect race detection.  Returns true if and
// only if \p I is identified as a special function that should be ignored.
bool CilkSanitizerImpl::shouldIgnoreCall(const Instruction &I) {
  if (const CallBase *Call = dyn_cast<CallBase>(&I))
    if (const Function *Called = Call->getCalledFunction())
      if (Called->hasName() && (Called->getName().startswith("__csi") ||
                                Called->getName().startswith("__csan") ||
                                Called->getName().startswith("__cilksan")))
        return true;
  return false;
}

// Helper function to get the ID of a function being called.  These IDs are
// stored in separate global variables in the program.  This method will create
// a new global variable for the Callee's ID if necessary.
Value *CilkSanitizerImpl::GetCalleeFuncID(const Function *Callee,
                                          IRBuilder<> &IRB) {
  if (!Callee)
    // Unknown targets (i.e., indirect calls) are always unknown.
    return IRB.getInt64(CsiCallsiteUnknownTargetId);

  std::string GVName =
    CsiFuncIdVariablePrefix + Callee->getName().str();
  GlobalVariable *FuncIdGV = M.getNamedGlobal(GVName);
  if (!FuncIdGV) {
    FuncIdGV = dyn_cast<GlobalVariable>(M.getOrInsertGlobal(GVName,
                                                            IRB.getInt64Ty()));
    assert(FuncIdGV);
    FuncIdGV->setConstant(false);
    if (Options.jitMode && !Callee->empty())
      FuncIdGV->setLinkage(Callee->getLinkage());
    else
      FuncIdGV->setLinkage(GlobalValue::WeakAnyLinkage);
    FuncIdGV->setInitializer(IRB.getInt64(CsiCallsiteUnknownTargetId));
  }
  return IRB.CreateLoad(FuncIdGV);
}

//------------------------------------------------------------------------------
// SimpleInstrumentor methods, which do not do static race detection.
//------------------------------------------------------------------------------

bool CilkSanitizerImpl::SimpleInstrumentor::InstrumentSimpleInstructions(
    SmallVectorImpl<Instruction *> &Instructions) {
  bool Result = false;
  for (Instruction *I : Instructions) {
    bool LocalResult = false;
    if (isa<LoadInst>(I) || isa<StoreInst>(I))
      LocalResult |= CilkSanImpl.instrumentLoadOrStore(I);
    else if (isa<AtomicRMWInst>(I) || isa<AtomicCmpXchgInst>(I))
      LocalResult |= CilkSanImpl.instrumentAtomic(I);
    else
      dbgs() << "[Cilksan] Unknown simple instruction: " << *I << "\n";

    if (LocalResult) {
      Result |= LocalResult;
      // Record the detaches for the task containing this instruction.  These
      // detaches need to be instrumented.
      getDetachesForInstruction(I);
    }
  }
  return Result;
}

bool CilkSanitizerImpl::SimpleInstrumentor::InstrumentAnyMemIntrinsics(
    SmallVectorImpl<Instruction *> &MemIntrinsics) {
  bool Result = false;
  for (Instruction *I : MemIntrinsics) {
    bool LocalResult = false;
    if (isa<AnyMemTransferInst>(I)) {
      LocalResult |= CilkSanImpl.instrumentAnyMemIntrinAcc(I, /*Src*/ 1);
      LocalResult |= CilkSanImpl.instrumentAnyMemIntrinAcc(I, /*Dst*/ 0);
    } else {
      assert(isa<AnyMemIntrinsic>(I) &&
             "InstrumentAnyMemIntrinsics operating on not a memory intrinsic.");
      LocalResult |= CilkSanImpl.instrumentAnyMemIntrinAcc(I, unsigned(-1));
    }
    if (LocalResult) {
      Result |= LocalResult;
      // Record the detaches for the task containing this instruction.  These
      // detaches need to be instrumented.
      getDetachesForInstruction(I);
    }
  }
  return Result;
}

bool CilkSanitizerImpl::SimpleInstrumentor::InstrumentCalls(
    SmallVectorImpl<Instruction *> &Calls) {
  bool Result = false;
  for (Instruction *I : Calls) {
    // Allocation-function and free calls are handled separately.
    if (isAllocFn(I, TLI) || isFreeCall(I, TLI, true))
      continue;

    bool LocalResult = false;
    if (isa<IntrinsicInst>(I))
      LocalResult |=
          CilkSanImpl.instrumentIntrinsicCall(I, /*MAAPVals*/ nullptr);
    else if (isLibCall(*I, TLI))
      LocalResult |=
          CilkSanImpl.instrumentLibCall(I, /*MAAPVals*/ nullptr);
    else
      LocalResult |= CilkSanImpl.instrumentCallsite(I, /*MAAPVals*/ nullptr);
    if (LocalResult) {
      Result |= LocalResult;
      // Record the detaches for the task containing this instruction.  These
      // detaches need to be instrumented.
      getDetachesForInstruction(I);
    }
  }
  return Result;
}

bool CilkSanitizerImpl::SimpleInstrumentor::InstrumentAncillaryInstructions(
    SmallPtrSetImpl<Instruction *> &Allocas,
    SmallPtrSetImpl<Instruction *> &AllocationFnCalls,
    SmallPtrSetImpl<Instruction *> &FreeCalls,
    DenseMap<Value *, unsigned> &SyncRegNums,
    DenseMap<BasicBlock *, unsigned> &SRCounters, const DataLayout &DL) {
  bool Result = false;
  SmallPtrSet<SyncInst *, 4> Syncs;
  SmallPtrSet<Loop *, 4> Loops;

  // Instrument allocas and allocation-function calls that may be involved in a
  // race.
  for (Instruction *I : Allocas) {
    // The simple instrumentor just instruments everything
    CilkSanImpl.instrumentAlloca(I);
    getDetachesForInstruction(I);
    Result = true;
  }
  for (Instruction *I : AllocationFnCalls) {
    // The simple instrumentor just instruments everything
    CilkSanImpl.instrumentAllocationFn(I, DT, TLI);
    getDetachesForInstruction(I);
    Result = true;
  }
  for (Instruction *I : FreeCalls) {
    // The first argument of the free call is the pointer.
    Value *Ptr = I->getOperand(0);
    // If the pointer corresponds to an allocation function call in this
    // function, then instrument it.
    if (Instruction *PtrI = dyn_cast<Instruction>(Ptr)) {
      if (AllocationFnCalls.count(PtrI)) {
        CilkSanImpl.instrumentFree(I, TLI);
        getDetachesForInstruction(I);
        Result = true;
        continue;
      }
    }
    // The simple instrumentor just instruments everything
    CilkSanImpl.instrumentFree(I, TLI);
    getDetachesForInstruction(I);
    Result = true;
  }

  // Instrument detaches
  for (DetachInst *DI : Detaches) {
    CilkSanImpl.instrumentDetach(DI, SyncRegNums[DI->getSyncRegion()],
                                 SRCounters[DI->getDetached()], DT, TI, LI);
    Result = true;
    // Get syncs associated with this detach
    for (SyncInst *SI : CilkSanImpl.DetachToSync[DI])
      Syncs.insert(SI);

    if (CilkSanImpl.Options.InstrumentLoops) {
      // Get any loop associated with this detach.
      Loop *L = LI.getLoopFor(DI->getParent());
      if (spawnsTapirLoopBody(DI, LI, TI))
        Loops.insert(L);
    }
  }

  // Instrument associated syncs
  for (SyncInst *SI : Syncs)
    CilkSanImpl.instrumentSync(SI, SyncRegNums[SI->getSyncRegion()]);

  if (CilkSanImpl.Options.InstrumentLoops) {
    // Recursively instrument all Tapir loops
    for (Loop *L : Loops)
      CilkSanImpl.instrumentTapirLoop(*L, TI, SyncRegNums);
  }

  return Result;
}

// TODO: Combine this redundant logic with that in Instrumentor
void CilkSanitizerImpl::SimpleInstrumentor::getDetachesForInstruction(
    Instruction *I) {
  // Get the Task for I.
  Task *T = TI.getTaskFor(I->getParent());
  // Add the ancestors of T to the set of detaches to instrument.
  while (!T->isRootTask()) {
    // Once we encounter a detach we've previously added to the set, we know
    // that all its parents are also in the set.
    if (!Detaches.insert(T->getDetach()).second)
      return;
    T = T->getParentTask();
  }
}

//------------------------------------------------------------------------------
// Instrumentor methods
//------------------------------------------------------------------------------

void CilkSanitizerImpl::Instrumentor::getDetachesForInstruction(
    Instruction *I) {
  // Get the Task for I.
  Task *T = TI.getTaskFor(I->getParent());
  // Add the ancestors of T to the set of detaches to instrument.
  while (!T->isRootTask()) {
    // Once we encounter a detach we've previously added to the set, we know
    // that all its parents are also in the set.
    if (!Detaches.insert(T->getDetach()).second)
      return;
    T = T->getParentTask();
  }
}

unsigned CilkSanitizerImpl::Instrumentor::RaceTypeToFlagVal(
    RaceInfo::RaceType RT) {
  unsigned FlagVal = static_cast<unsigned>(MAAPValue::NoAccess);
  if (RaceInfo::isLocalRace(RT) || RaceInfo::isOpaqueRace(RT))
    FlagVal = static_cast<unsigned>(MAAPValue::ModRef);
  if (RaceInfo::isRaceViaAncestorMod(RT))
    FlagVal |= static_cast<unsigned>(MAAPValue::Mod);
  if (RaceInfo::isRaceViaAncestorRef(RT))
    FlagVal |= static_cast<unsigned>(MAAPValue::Ref);
  return FlagVal;
}

static Value *getMAAPIRValue(IRBuilder<> &IRB, unsigned MV) {
  return IRB.getInt8(MV);
}

// Insert per-argument MAAPs for this function
void CilkSanitizerImpl::Instrumentor::InsertArgMAAPs(Function &F,
                                                     Value *FuncId) {
  if (!MAAPChecks)
    return;
  LLVM_DEBUG(dbgs() << "InsertArgMAAPs: " << F.getName() << "\n");
  IRBuilder<> IRB(&*(++(cast<Instruction>(FuncId)->getIterator())));
  unsigned ArgIdx = 0;
  for (Argument &Arg : F.args()) {
    if (!Arg.getType()->isPtrOrPtrVectorTy())
      continue;

    // Create a new flag for this argument MAAP.
    Value *NewFlag = IRB.CreateAlloca(getMAAPIRValue(IRB, 0)->getType(),
                                      Arg.getType()->getPointerAddressSpace());
    Value *FinalMV;
    // If this function is main, then it has no ancestors that can create races.
    if (F.getName() == "main") {
      FinalMV = getMAAPIRValue(IRB, RaceTypeToFlagVal(RaceInfo::None));
      IRB.CreateStore(FinalMV, NewFlag);
    } else {
      // Call the runtime function to set the value of this flag.
      IRB.CreateCall(CilkSanImpl.GetMAAP,
                     {NewFlag, FuncId, IRB.getInt8(ArgIdx)});

      // Incorporate local information into this MAAP value.
      unsigned LocalMV = static_cast<unsigned>(MAAPValue::NoAccess);
      if (Arg.hasNoAliasAttr())
        LocalMV |= static_cast<unsigned>(MAAPValue::NoAlias);

      // Store this local MAAP value.
      FinalMV =
          IRB.CreateOr(getMAAPIRValue(IRB, LocalMV), IRB.CreateLoad(NewFlag));
      IRB.CreateStore(FinalMV, NewFlag);
    }
    // Associate this flag with the argument for future lookups.
    LLVM_DEBUG(dbgs() << "Recording local MAAP for arg " << Arg << ": "
                      << *NewFlag << "\n");
    LocalMAAPs[&Arg] = FinalMV;
    ArgMAAPs.insert(FinalMV);
    ++ArgIdx;
  }

  // Record other objects known to be involved in races.
  for (auto &ObjRD : RI.getObjectMRForRace()) {
    if (isa<Instruction>(ObjRD.first)) {
      unsigned MAAPVal = static_cast<unsigned>(MAAPValue::NoAccess);
      if (isModSet(ObjRD.second))
        MAAPVal |= static_cast<unsigned>(MAAPValue::Mod);
      if (isRefSet(ObjRD.second))
        MAAPVal |= static_cast<unsigned>(MAAPValue::Ref);
      // Determine if this object is no-alias.
      if (const CallBase *CB = dyn_cast<CallBase>(ObjRD.first)) {
        if (CB->hasRetAttr(Attribute::NoAlias))
          MAAPVal |= static_cast<unsigned>(MAAPValue::NoAlias);
      } else if (isa<AllocaInst>(ObjRD.first))
        MAAPVal |= static_cast<unsigned>(MAAPValue::NoAlias);

      LLVM_DEBUG(dbgs() << "Setting LocalMAAPs for " << *ObjRD.first << " = "
                        << MAAPVal << "\n");
      LocalMAAPs[ObjRD.first] = getMAAPIRValue(IRB, MAAPVal);
    }
  }
}

bool CilkSanitizerImpl::Instrumentor::InstrumentSimpleInstructions(
    SmallVectorImpl<Instruction *> &Instructions) {
  bool Result = false;
  for (Instruction *I : Instructions) {
    bool LocalResult = false;
    // Simple instructions, such as loads, stores, or atomics, have just one
    // pointer operand, and therefore should have at most one entry of RaceData.

    // If the instruction might participate in a local or opaque race,
    // instrument it unconditionally.
    if (RI.mightRaceOpaquely(I)) {
      if (isa<LoadInst>(I) || isa<StoreInst>(I))
        LocalResult |= CilkSanImpl.instrumentLoadOrStore(I);
      else if (isa<AtomicRMWInst>(I) || isa<AtomicCmpXchgInst>(I))
        LocalResult |= CilkSanImpl.instrumentAtomic(I);
      else
        dbgs() << "[Cilksan] Unknown simple instruction: " << *I << "\n";
    } else if (RI.mightRaceViaAncestor(I) || RI.mightRaceLocally(I)) {
      // Otherwise, if the instruction might participate in a race via an
      // ancestor function instantiation, instrument it conditionally, based on
      // the pointer.
      //
      // Delay handling this instruction.
      DelayedSimpleInsts.push_back(I);
      LocalResult |= true;
    }

    // If any instrumentation was inserted, collect associated instructions to
    // instrument.
    if (LocalResult) {
      Result |= LocalResult;
      // Record the detaches for the task containing this instruction.  These
      // detaches need to be instrumented.
      getDetachesForInstruction(I);
    }
  }
  return Result;
}

bool CilkSanitizerImpl::Instrumentor::InstrumentAnyMemIntrinsics(
    SmallVectorImpl<Instruction *> &MemIntrinsics) {
  bool Result = false;
  for (Instruction *I : MemIntrinsics) {
    bool LocalResult = false;
    // If this instruction cannot race, skip it.
    if (!RI.mightRace(I))
      continue;

    // Look over the race data to determine what memory intrinsics need to be
    // instrumented and how.
    SmallSet<std::pair<Instruction *, unsigned>, 2> ToInstrument;
    SmallSet<std::pair<Instruction *, unsigned>, 2> MaybeDelay;
    for (const RaceInfo::RaceData &RD : RI.getRaceData(I)) {
      assert(RD.getPtr() && "No pointer for race with memory intrinsic.");
      if (RaceInfo::isOpaqueRace(RD.Type)) {
        ToInstrument.insert(std::make_pair(I, RD.OperandNum));
        LocalResult |= true;
      } else if (RaceInfo::isRaceViaAncestor(RD.Type) ||
                 RaceInfo::isLocalRace(RD.Type)) {
        // Possibly delay handling this instruction.
        MaybeDelay.insert(std::make_pair(I, RD.OperandNum));
        LocalResult |= true;
      }
    }

    // Do the instrumentation
    for (const std::pair<Instruction *, unsigned> &MemIntrin : ToInstrument)
      CilkSanImpl.instrumentAnyMemIntrinAcc(MemIntrin.first, MemIntrin.second);
    for (const std::pair<Instruction *, unsigned> &MemIntrin : MaybeDelay)
      if (!ToInstrument.count(MemIntrin))
        DelayedMemIntrinsics.push_back(MemIntrin);

    // If any instrumentation was inserted, collect associated instructions to
    // instrument.
    if (LocalResult) {
      Result |= LocalResult;
      // Record the detaches for the task containing this instruction.  These
      // detaches need to be instrumented.
      getDetachesForInstruction(I);
    }
  }
  return Result;
}

bool CilkSanitizerImpl::Instrumentor::InstrumentCalls(
    SmallVectorImpl<Instruction *> &Calls) {
  bool Result = false;
  for (Instruction *I : Calls) {
    // Allocation-function and free calls are handled separately.
    if (isAllocFn(I, TLI) || isFreeCall(I, TLI, true))
      continue;

    bool LocalResult = false;
    bool GetDetaches = false;

    // Get current race data for this call.
    RaceInfo::RaceType CallRT = RI.getRaceType(I);
    LLVM_DEBUG({
        dbgs() << "Call " << *I << ": ";
        RaceInfo::printRaceType(CallRT, dbgs());
        dbgs() << "\n";
      });

    // Get update race data, if it's available.
    RaceInfo::RaceType FuncRT = CallRT;
    CallBase *CB = dyn_cast<CallBase>(I);
    if (Function *CF = CB->getCalledFunction())
      if (CilkSanImpl.FunctionRaceType.count(CF))
        FuncRT = CilkSanImpl.FunctionRaceType[CF];

    LLVM_DEBUG({
        dbgs() << "  FuncRT: ";
        RaceInfo::printRaceType(FuncRT, dbgs());
        dbgs() << "\n";
      });

    // Propagate information about opaque races from function to call.
    if (!RaceInfo::isOpaqueRace(FuncRT))
      CallRT = RaceInfo::clearOpaqueRace(CallRT);

    LLVM_DEBUG({
        dbgs() << "  New CallRT: ";
        RaceInfo::printRaceType(CallRT, dbgs());
        dbgs() << "\n";
      });

    // If this instruction cannot race, see if we can suppress it
    if (!RaceInfo::isRace(CallRT)) {
      // Nothing to suppress if this is an intrinsic
      if (isa<IntrinsicInst>(I))
        continue;

      // We can only suppress calls whose functions don't have local races.
      if (!RaceInfo::isLocalRace(FuncRT)) {
        if (!CB->doesNotAccessMemory())
          LocalResult |= CilkSanImpl.suppressCallsite(I);
        continue;
      // } else {
      //   GetDetaches |= CilkSanImpl.instrumentCallsite(I);
      //   // SmallPtrSet<Value *, 1> Objects;
      //   // RI.getObjectsFor(I, Objects);
      //   // for (Value *Obj : Objects) {
      //   //   CilkSanImpl.ObjectMRForRace[Obj] = ModRefInfo::ModRef;
      //   // }
      }
      // continue;
    }

    // We're going to instrument this call for potential races.  First get
    // MAAP information for its arguments, if any races depend on the
    // ancestor.
    SmallVector<Value *, 8> MAAPVals;
    LLVM_DEBUG(dbgs() << "Getting MAAP values for " << *CB << "\n");
    IRBuilder<> IRB(I);
    unsigned OpIdx = 0;
    for (const Value *Op : CB->args()) {
      if (!MAAPChecks)
        continue;

      if (!Op->getType()->isPtrOrPtrVectorTy()) {
        ++OpIdx;
        continue;
      }

      // Check if this operand might race via ancestor.
      bool RaceViaAncestor = false;
      for (const RaceInfo::RaceData &RD : RI.getRaceData(I)) {
        if (RD.OperandNum != OpIdx)
          continue;
        if (RaceInfo::isRaceViaAncestor(RD.Type)) {
          RaceViaAncestor = true;
          break;
        }
      }

      Value *MAAPVal;
      if (RaceViaAncestor)
        // Evaluate race data for I and OpIdx to compute the MAAP value.
        MAAPVal = getMAAPValue(I, IRB, OpIdx);
      else
        // We have either an opaque race or a local race, but _not_ a race via
        // an ancestor.  We want to propagate MAAP information on pointer
        // arguments, but we don't need to be pessimistic when a value can't be
        // found.
        MAAPVal = getMAAPValue(I, IRB, OpIdx, MAAPValue::NoAccess,
                               /*CheckArgs*/ false);
      LLVM_DEBUG({
          dbgs() << "  Op: " << *CB->getArgOperand(OpIdx) << "\n";
          dbgs() << "  MAAP value: " << *MAAPVal << "\n";
        });
      MAAPVals.push_back(MAAPVal);
      ++OpIdx;
    }

    Value *CalleeID = CilkSanImpl.GetCalleeFuncID(CB->getCalledFunction(), IRB);
    // We set the MAAPs in reverse order to support stack-like accesses of the
    // MAAPs by in-order calls to GetMAAP in the callee.
    for (Value *MAAPVal : reverse(MAAPVals))
      IRB.CreateCall(CilkSanImpl.SetMAAP, {MAAPVal, CalleeID});

    if (isa<IntrinsicInst>(I))
      GetDetaches |= CilkSanImpl.instrumentIntrinsicCall(I, &MAAPVals);
    else if (isLibCall(*I, TLI))
      GetDetaches |= CilkSanImpl.instrumentLibCall(I, &MAAPVals);
    else
      GetDetaches |= CilkSanImpl.instrumentCallsite(I, &MAAPVals);

    // If any instrumentation was inserted, collect associated instructions to
    // instrument.
    Result |= LocalResult;
    if (GetDetaches) {
      Result |= GetDetaches;
      // Record the detaches for the task containing this instruction.  These
      // detaches need to be instrumented.
      getDetachesForInstruction(I);
    }
  }
  return Result;
}

Value *CilkSanitizerImpl::Instrumentor::readMAAPVal(Value *V,
                                                    IRBuilder<> &IRB) {
  if (!ArgMAAPs.count(V))
    return V;
  // Marking the load as invariant is not technically correct, because the
  // __csan_get_MAAP call sets the value.  But this call happens
  // once, and all subsequent loads will return the same value.
  //
  // MDNode *MD = llvm::MDNode::get(IRB.getContext(), llvm::None);
  // cast<Instruction>(Load)->setMetadata(LLVMContext::MD_invariant_load, MD);

  // TODO: See if there's a better way to annotate this load for optimization.
  // LoadInst *I = IRB.CreateLoad(V);
  // if (auto *IMD = I->getMetadata(LLVMContext::MD_invariant_group))
  //   I->setMetadata(LLVMContext::MD_invariant_group, IMD);
  // else
  //   I->setMetadata(LLVMContext::MD_invariant_group,
  //                  MDNode::get(IRB.getContext(), {}));
  Value *MV;
  if (isa<AllocaInst>(V))
    MV = IRB.CreateLoad(V);
  else
    MV = V;
  return MV;
}

// Get the memory location for this instruction and operand.
static MemoryLocation getMemoryLocation(Instruction *I, unsigned OperandNum,
                                        const TargetLibraryInfo *TLI) {
  if (auto *MI = dyn_cast<AnyMemIntrinsic>(I)) {
    if (auto *MT = dyn_cast<AnyMemTransferInst>(I)) {
      if (OperandNum == 1)
        return MemoryLocation::getForSource(MT);
    }
    return MemoryLocation::getForDest(MI);
  } else if (OperandNum == static_cast<unsigned>(-1)) {
    return MemoryLocation::get(I);
  } else {
    assert(isa<CallBase>(I) &&
           "Unknown instruction and operand ID for getting MemoryLocation.");
    CallBase *CB = cast<CallBase>(I);
    return MemoryLocation::getForArgument(CB, OperandNum, TLI);
  }
}

// Evaluate the noalias value in the MAAP for Obj, and intersect that result
// with the noalias information for other objects.
Value *CilkSanitizerImpl::Instrumentor::getNoAliasMAAPValue(
    Instruction *I, IRBuilder<> &IRB, unsigned OperandNum,
    MemoryLocation Loc, const RaceInfo::RaceData &RD, const Value *Obj,
    Value *ObjNoAliasFlag) {
  AliasAnalysis *AA = RI.getAA();

  for (const RaceInfo::RaceData &OtherRD : RI.getRaceData(I)) {
    // Skip checking other accesses that don't involve a pointer
    if (!OtherRD.Access.getPointer())
      continue;
    // Skip this operand when scanning for aliases
    if (OperandNum == OtherRD.OperandNum)
      continue;

    // If we can tell statically that these two memory locations don't alias,
    // move on.
    if (!AA->alias(Loc, getMemoryLocation(I, OtherRD.OperandNum, TLI)))
      continue;

    // We trust that the MAAP value in LocalMAAPs[] for this object Obj, set by
    // InsertArgMAAPs, is correct.  We need to check the underlying objects of
    // the other arguments to see if they match this object.

    // Otherwise we check the underlying objects.
    SmallPtrSet<const Value *, 1> OtherObjects;
    RI.getObjectsFor(OtherRD.Access, OtherObjects);
    for (const Value *OtherObj : OtherObjects) {
      // If we find another instance of this object in another argument,
      // then we don't have "no alias".
      if (Obj == OtherObj) {
        LLVM_DEBUG({
            dbgs() << "getNoAliasMAAPValue: Matching objects found:\n";
            dbgs() << "  Obj: " << *Obj << "\n";
            dbgs() << "    I: " << *I << "\n";
            dbgs() << " Operands " << OperandNum << ", " << OtherRD.OperandNum
                   << "\n";
          });
        return getMAAPIRValue(IRB, 0);
      }

      // We now know that Obj and OtherObj don't match.

      // If the other object is an argument, then we trust the noalias value in
      // the MAAP for Obj.
      if (isa<Argument>(OtherObj))
        continue;

      // // If the other object is something we can't reason about locally, then we
      // // give up.
      // if (!isa<Instruction>(OtherObj))
      //   return getMAAPIRValue(IRB, 0);

      // Otherwise, check if the other object might alias this one.
      if (AA->alias(Loc, MemoryLocation(OtherObj))) {
        LLVM_DEBUG({
            dbgs() << "getNoAliasMAAPValue: Possible aliasing between:\n";
            dbgs() << "  Obj: " << *Obj << "\n";
            dbgs() << "  OtherObj: " << *OtherObj << "\n";
          });
        return getMAAPIRValue(IRB, 0);
      }
    }
  }
  return ObjNoAliasFlag;
}

Value *CilkSanitizerImpl::Instrumentor::getMAAPValue(Instruction *I,
                                                     IRBuilder<> &IRB,
                                                     unsigned OperandNum,
                                                     MAAPValue DefaultMV,
                                                     bool CheckArgs) {
  Function *F = I->getFunction();
  AliasAnalysis *AA = RI.getAA();
  MemoryLocation Loc = getMemoryLocation(I, OperandNum, TLI);
  Value *MV = getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAccess));
  Value *DefaultMAAP = getMAAPIRValue(IRB, static_cast<unsigned>(DefaultMV));
  Value *NoAliasFlag =
      getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAlias));

  // If I is a call, check if any other arguments of this call alias the
  // specified operand.
  if (const CallBase *CB = dyn_cast<CallBase>(I)) {
    unsigned OpIdx = 0;
    bool FoundAliasingArg = false;
    for (const Value *Arg : CB->args()) {
      // Skip this operand and any operands that are not pointers.
      if (OpIdx == OperandNum || !Arg->getType()->isPtrOrPtrVectorTy()) {
        ++OpIdx;
        continue;
      }

      // If this argument does not alias Loc, skip it.
      if (!AA->alias(Loc, getMemoryLocation(I, OpIdx, TLI))) {
        ++OpIdx;
        continue;
      }

      // If the operands must alias, then discard the default noalias MAAP
      // value.
      AliasResult ArgAlias = AA->alias(Loc, getMemoryLocation(I, OpIdx, TLI));
      if (MustAlias == ArgAlias || PartialAlias == ArgAlias) {
        NoAliasFlag = getMAAPIRValue(IRB, 0);
        break;
      }

      // Get objects corresponding to this argument.
      SmallPtrSet<const Value *, 1> ArgObjects;
      RI.getObjectsFor(RaceInfo::MemAccessInfo(
                           Arg, isModSet(AA->getArgModRefInfo(CB, OpIdx))),
                       ArgObjects);
      for (const Value *Obj : ArgObjects) {
        // If Loc and the racer object cannot alias, then there's nothing to
        // check.
        if (!AA->alias(Loc, MemoryLocation(Obj)))
          continue;

        // If we have no local MAAP data for Obj, then act pessimally.
        if (!LocalMAAPs.count(Obj)) {
          FoundAliasingArg = true;
          break;
        }

        // Intersect the dynamic noalias information for this object into the
        // noalias flag.
        Value *FlagLoad = readMAAPVal(LocalMAAPs[Obj], IRB);
        Value *ObjNoAliasFlag = IRB.CreateAnd(
            FlagLoad,
            getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAlias)));
        NoAliasFlag = IRB.CreateAnd(NoAliasFlag, ObjNoAliasFlag);
      }

      if (FoundAliasingArg) {
        // If we found an aliasing argument, fall back to noalias = false.
        NoAliasFlag = getMAAPIRValue(IRB, 0);
        break;
      }
      ++OpIdx;
    }
  }

  // Check the recorded race data for I.
  for (const RaceInfo::RaceData &RD : RI.getRaceData(I)) {
    // Skip race data for different operands of the same instruction.
    if (OperandNum != RD.OperandNum)
      continue;

    // Otherwise use information about the possibly accessed objects to
    // determine the MAAP value.
    SmallPtrSet<const Value *, 1> Objects;
    RI.getObjectsFor(RD.Access, Objects);

    // If we have a valid racer, get the objects that that racer might access.
    SmallPtrSet<const Value *, 1> RacerObjects;
    unsigned LocalRaceVal = static_cast<unsigned>(MAAPValue::NoAccess);
    if (RD.Racer.isValid()) {
      // Get the local race value for this racer
      assert(RaceInfo::isLocalRace(RD.Type) && "Valid racer for nonlocal race");
      RI.getObjectsFor(
          RaceInfo::MemAccessInfo(RD.Racer.getPtr(), RD.Racer.isMod()),
          RacerObjects);
      if (RD.Racer.isMod())
        LocalRaceVal |= static_cast<unsigned>(MAAPValue::Mod);
      if (RD.Racer.isRef())
        LocalRaceVal |= static_cast<unsigned>(MAAPValue::Ref);
    }

    // Get MAAPs from objects
    for (const Value *Obj : Objects) {
      // If we find an object with no MAAP, give up.
      if (!LocalMAAPs.count(Obj)) {
        LLVM_DEBUG(dbgs() << "No local MAAP found for obj " << *Obj << "\n");
        if (RD.Racer.isValid())
          return getMAAPIRValue(IRB, LocalRaceVal);
        return DefaultMAAP;
      }

      Value *FlagLoad = readMAAPVal(LocalMAAPs[Obj], IRB);
      Value *FlagCheck = IRB.CreateAnd(
          FlagLoad, getMAAPIRValue(IRB, RaceTypeToFlagVal(RD.Type)));
      MV = IRB.CreateOr(MV, FlagCheck);

      // Get the dynamic no-alias bit from the MAAP value.
      Value *ObjNoAliasFlag = IRB.CreateAnd(
          FlagLoad,
          getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAlias)));
      Value *NoAliasCheck =
          IRB.CreateICmpNE(getMAAPIRValue(IRB, 0), ObjNoAliasFlag);

      if (RD.Racer.isValid()) {
        for (const Value *RObj : RacerObjects) {
          // If the racer object matches Obj, there's no need to check a flag.
          if (RObj == Obj) {
            MV = IRB.CreateOr(MV, LocalRaceVal);
            continue;
          }

          // If Loc and the racer object cannot alias, then there's nothing to
          // check.
          if (!AA->alias(Loc, MemoryLocation(RObj)))
            continue;

          // If there is must or partial aliasing between this object and racer
          // object, or we have no local MAAP information for RObj, then
          // act conservatively, because there's nothing to check.
          if (MustAlias == AA->alias(Loc, MemoryLocation(RObj)) ||
              PartialAlias == AA->alias(Loc, MemoryLocation(RObj)) ||
              !LocalMAAPs.count(RObj)) {
            if (!LocalMAAPs.count(RObj))
              LLVM_DEBUG(dbgs() << "No local MAAP found for racer object "
                                << *RObj << "\n");
            else
              LLVM_DEBUG(dbgs() << "AA indicates must or partial alias with "
                                   "racer object "
                                << *RObj << "\n");
            MV = IRB.CreateOr(MV, LocalRaceVal);
            continue;
          }

          // These two objects may alias, based on static analysis.  Check the
          // dynamic MAAP values.  We can suppress the race if either this
          // object or the racer object is dynamically noalias, i.e., if either
          // was derived from an allocation or noalias function argument.
          Value *FlagLoad = readMAAPVal(LocalMAAPs[RObj], IRB);
          Value *RObjNoAliasFlag = IRB.CreateAnd(
              FlagLoad,
              getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAlias)));
          Value *RObjNoAliasCheck =
              IRB.CreateICmpNE(getMAAPIRValue(IRB, 0), RObjNoAliasFlag);
          Value *FlagCheck = IRB.CreateSelect(
              IRB.CreateOr(NoAliasCheck, RObjNoAliasCheck),
              getMAAPIRValue(IRB, 0),
              IRB.CreateAnd(FlagLoad, getMAAPIRValue(IRB, LocalRaceVal)));
          MV = IRB.CreateOr(MV, FlagCheck);
        }
      } else if (CheckArgs) {
        // Check the function arguments that might alias this object.
        for (Argument &Arg : F->args()) {
          // Ignore non-pointer arguments
          if (!Arg.getType()->isPtrOrPtrVectorTy())
            continue;
          // Ignore any arguments that match checked objects.
          if (&Arg == Obj)
            continue;
          // Check if Loc and Arg may alias.
          if (!AA->alias(Loc, MemoryLocation(&Arg)))
            continue;
          // If we have no local MAAP information about the argument,
          // then there's nothing to check.
          if (!LocalMAAPs.count(&Arg)) {
            LLVM_DEBUG(dbgs() << "No local MAAP found for arg " << Arg << "\n");
            return DefaultMAAP;
          }

          // These two objects may alias, based on static analysis.  Check the
          // dynamic MAAP values.  We can suppress the race if either
          // this object or the racer object is dynamically noalias, i.e., if
          // either was derived from an allocation or noalias function argument.
          Value *FlagLoad = readMAAPVal(LocalMAAPs[&Arg], IRB);
          Value *ArgNoAliasFlag = IRB.CreateAnd(
              FlagLoad,
              getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAlias)));
          Value *ArgNoAliasCheck =
              IRB.CreateICmpNE(getMAAPIRValue(IRB, 0), ArgNoAliasFlag);
          Value *FlagCheck = IRB.CreateSelect(
              IRB.CreateOr(NoAliasCheck, ArgNoAliasCheck),
              getMAAPIRValue(IRB, 0),
              IRB.CreateAnd(FlagLoad,
                            getMAAPIRValue(IRB, RaceTypeToFlagVal(RD.Type))));
          MV = IRB.CreateOr(MV, FlagCheck);
        }
      }
      // Call getNoAliasMAAPValue to evaluate the no-alias value in the
      // MAAP for Obj, and intersect that result with the noalias
      // information for other objects.
      NoAliasFlag = IRB.CreateAnd(NoAliasFlag,
                                  getNoAliasMAAPValue(I, IRB, OperandNum, Loc,
                                                      RD, Obj, ObjNoAliasFlag));
    }
  }
  // Record the no-alias information.
  MV = IRB.CreateOr(MV, NoAliasFlag);
  return MV;
}

Value *CilkSanitizerImpl::Instrumentor::getMAAPCheck(Instruction *I,
                                                     IRBuilder<> &IRB,
                                                     unsigned OperandNum) {
  Function *F = I->getFunction();
  bool LocalRace = RI.mightRaceLocally(I);
  AliasAnalysis *AA = RI.getAA();
  MemoryLocation Loc = getMemoryLocation(I, OperandNum, TLI);
  Value *MAAPChk = IRB.getTrue();
  // Check the recorded race data for I.
  for (const RaceInfo::RaceData &RD : RI.getRaceData(I)) {
    // Skip race data for different operands of the same instruction.
    if (OperandNum != RD.OperandNum)
      continue;

    SmallPtrSet<const Value *, 1> Objects;
    RI.getObjectsFor(RD.Access, Objects);

    // If we have a valid racer, get the objects that that racer might access.
    SmallPtrSet<const Value *, 1> RacerObjects;
    unsigned LocalRaceVal = static_cast<unsigned>(MAAPValue::NoAccess);
    if (RD.Racer.isValid()) {
      assert(RaceInfo::isLocalRace(RD.Type) && "Valid racer for nonlocal race");
      RI.getObjectsFor(
          RaceInfo::MemAccessInfo(RD.Racer.getPtr(), RD.Racer.isMod()),
          RacerObjects);
      if (RD.Racer.isMod())
        LocalRaceVal |= static_cast<unsigned>(MAAPValue::Mod);
      if (RD.Racer.isRef())
        LocalRaceVal |= static_cast<unsigned>(MAAPValue::Ref);
    }

    for (const Value *Obj : Objects) {
      // Ignore objects that are not involved in races.
      if (!RI.ObjectInvolvedInRace(Obj))
        continue;

      // If we find an object with no MAAP, give up.
      if (!LocalMAAPs.count(Obj)) {
        LLVM_DEBUG(dbgs() << "No local MAAP found for obj " << *Obj << "\n"
                          << "  I: " << *I << "\n"
                          << "  Ptr: " << *RD.Access.getPointer() << "\n");
        return IRB.getFalse();
      }

      Value *FlagLoad = readMAAPVal(LocalMAAPs[Obj], IRB);
      // If we're dealing with a local race, then don't suppress based on the
      // race-type information from the MAAP value.  For function arguments,
      // that MAAP value reflects potential races via an ancestor, which should
      // not disable checking of local races.
      Value *FlagCheck;
      if (LocalRace)
        FlagCheck =
            getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::ModRef));
      else
        FlagCheck = IRB.CreateAnd(
            FlagLoad, getMAAPIRValue(IRB, RaceTypeToFlagVal(RD.Type)));
      MAAPChk = IRB.CreateAnd(
          MAAPChk, IRB.CreateICmpEQ(getMAAPIRValue(IRB, 0), FlagCheck));
      // Get the dynamic no-alias bit from the MAAP value.
      Value *NoAliasCheck = IRB.CreateICmpNE(
          getMAAPIRValue(IRB, 0),
          IRB.CreateAnd(
              FlagLoad,
              getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAlias))));

      if (RD.Racer.isValid()) {
        for (const Value *RObj : RacerObjects) {
          // If the racer object matches Obj, there's no need to check a flag.
          if (RObj == Obj) {
            MAAPChk = IRB.getFalse();
            continue;
          }

          // Check if Loc and the racer object may alias.
          if (!AA->alias(Loc, MemoryLocation(RObj)))
            continue;

          if (!LocalMAAPs.count(RObj)) {
            LLVM_DEBUG(dbgs() << "No local MAAP found for racer object " << RObj
                              << "\n");
            MAAPChk = IRB.getFalse();
            continue;
          }

          Value *FlagLoad = readMAAPVal(LocalMAAPs[RObj], IRB);
          Value *FlagCheck;
          if (LocalRace)
            FlagCheck =
                getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::ModRef));
          else
            FlagCheck =
                IRB.CreateAnd(FlagLoad, getMAAPIRValue(IRB, LocalRaceVal));
          Value *RObjNoAliasFlag = IRB.CreateAnd(
              FlagLoad,
              getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAlias)));
          Value *RObjNoAliasCheck =
              IRB.CreateICmpNE(getMAAPIRValue(IRB, 0), RObjNoAliasFlag);
          MAAPChk = IRB.CreateAnd(
              MAAPChk,
              IRB.CreateOr(
                  IRB.CreateOr(NoAliasCheck, RObjNoAliasCheck),
                  IRB.CreateICmpEQ(getMAAPIRValue(IRB, 0), FlagCheck)));
        }
      }

      // Check the function arguments that might alias this object.
      for (Argument &Arg : F->args()) {
        // Ignore non-pointer arguments
        if (!Arg.getType()->isPtrOrPtrVectorTy())
          continue;
        // Ignore any arguments that match checked objects.
        if (&Arg == Obj)
          continue;
        // Check if Loc and Arg may alias.
        if (!AA->alias(Loc, MemoryLocation(&Arg)))
          continue;
        // If we have no local MAAP information about the argument, give up.
        if (!LocalMAAPs.count(&Arg)) {
          LLVM_DEBUG(dbgs() << "No local MAAP found for arg " << Arg << "\n");
          return IRB.getFalse();
        }

        // Incorporate the MAAP value for this argument if we don't have
        // a dynamic no-alias bit set.
        Value *FlagLoad = readMAAPVal(LocalMAAPs[&Arg], IRB);
        Value *FlagCheck;
        if (LocalRace)
          FlagCheck =
              getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::ModRef));
        else
          FlagCheck = IRB.CreateAnd(
              FlagLoad, getMAAPIRValue(IRB, RaceTypeToFlagVal(RD.Type)));
        Value *ArgNoAliasFlag = IRB.CreateAnd(
            FlagLoad,
            getMAAPIRValue(IRB, static_cast<unsigned>(MAAPValue::NoAlias)));
        Value *ArgNoAliasCheck =
            IRB.CreateICmpNE(getMAAPIRValue(IRB, 0), ArgNoAliasFlag);
        MAAPChk = IRB.CreateAnd(
            MAAPChk,
            IRB.CreateOr(IRB.CreateOr(NoAliasCheck, ArgNoAliasCheck),
                         IRB.CreateICmpEQ(getMAAPIRValue(IRB, 0), FlagCheck)));
      }
    }
  }
  return MAAPChk;
}

bool CilkSanitizerImpl::Instrumentor::PerformDelayedInstrumentation() {
  bool Result = false;
  // Handle delayed simple instructions
  for (Instruction *I : DelayedSimpleInsts) {
    assert((RI.mightRaceViaAncestor(I) || RI.mightRaceLocally(I)) &&
           "Delayed instrumentation is not local race or race via ancestor");
    IRBuilder<> IRB(I);

    if (MAAPChecks) {
      Value *MAAPChk = getMAAPCheck(I, IRB);
      Instruction *CheckTerm = SplitBlockAndInsertIfThen(
          IRB.CreateICmpEQ(MAAPChk, IRB.getFalse()), I, false, nullptr, DT,
          /*LI*/ nullptr);
      IRB.SetInsertPoint(CheckTerm);
    }
    if (isa<LoadInst>(I) || isa<StoreInst>(I))
      Result |= CilkSanImpl.instrumentLoadOrStore(I, IRB);
    else if (isa<AtomicRMWInst>(I) || isa<AtomicCmpXchgInst>(I))
      Result |= CilkSanImpl.instrumentAtomic(I, IRB);
    else
      dbgs() << "[Cilksan] Unknown simple instruction: " << *I << "\n";
  }

  // Handle delayed memory intrinsics
  for (auto &MemIntrinOp : DelayedMemIntrinsics) {
    Instruction *I = MemIntrinOp.first;
    assert((RI.mightRaceViaAncestor(I)  || RI.mightRaceLocally(I)) &&
           "Delayed instrumentation is not local race or race via ancestor");
    unsigned OperandNum = MemIntrinOp.second;
    IRBuilder<> IRB(I);

    if (MAAPChecks) {
      Value *MAAPChk = getMAAPCheck(I, IRB, OperandNum);
      Instruction *CheckTerm = SplitBlockAndInsertIfThen(
          IRB.CreateICmpEQ(MAAPChk, IRB.getFalse()), I, false, nullptr, DT,
          /*LI*/ nullptr);
      IRB.SetInsertPoint(CheckTerm);
    }
    Result |= CilkSanImpl.instrumentAnyMemIntrinAcc(I, OperandNum, IRB);
  }
  return Result;
}

// Helper function to walk the hierarchy of tasks containing BasicBlock BB to
// get the top-level task in loop L that contains BB.
static Task *GetTopLevelTaskFor(BasicBlock *BB, Loop *L, TaskInfo &TI) {
  Task *T = TI.getTaskFor(BB);
  // Return null if we don't find a task for BB contained in L.
  if (!T || !L->contains(T->getEntry()))
    return nullptr;

  // Walk up the tree of tasks until we discover a task containing BB that is
  // outside of L.
  while (L->contains(T->getParentTask()->getEntry()))
    T = T->getParentTask();

  return T;
}

void CilkSanitizerImpl::Instrumentor::GetDetachesForCoalescedInstrumentation(
    SmallPtrSetImpl<Instruction *> &LoopInstToHoist,
    SmallPtrSetImpl<Instruction *> &LoopInstToSink) {
  // Determine detaches to instrument for the coalesced instrumentation.
  for (Instruction *I : LoopInstToHoist) {
    Loop *L = LI.getLoopFor(I->getParent());
    // Record the detaches for the loop preheader, where the coalesced
    // instrumentation will be inserted.
    getDetachesForInstruction(L->getLoopPreheader()->getTerminator());
  }
  for (Instruction *I : LoopInstToSink) {
    Loop *L = LI.getLoopFor(I->getParent());
    SmallVector<BasicBlock *, 4> ExitBlocks;
    L->getUniqueExitBlocks(ExitBlocks);
    for (BasicBlock *ExitBB : ExitBlocks) {
      if (GetTopLevelTaskFor(ExitBB, L, TI))
        // Skip any exit blocks in a Tapir task inside the loop.  These exit
        // blocks lie on exception-handling paths, and to handle these blocks,
        // it suffices to insert instrumentation in the unwind destination of
        // the corresponding detach, which must also be a loop-exit block.
        continue;

      // Record the detaches for the exit block, where the coalesced
      // instrumentation will be inserted.
      getDetachesForInstruction(ExitBB->getTerminator());
    }
  }
}

bool CilkSanitizerImpl::Instrumentor::InstrumentAncillaryInstructions(
    SmallPtrSetImpl<Instruction *> &Allocas,
    SmallPtrSetImpl<Instruction *> &AllocationFnCalls,
    SmallPtrSetImpl<Instruction *> &FreeCalls,
    DenseMap<Value *, unsigned> &SyncRegNums,
    DenseMap<BasicBlock *, unsigned> &SRCounters, const DataLayout &DL) {
  bool Result = false;
  SmallPtrSet<SyncInst *, 4> Syncs;
  SmallPtrSet<Loop *, 4> Loops;

  // Instrument allocas and allocation-function calls that may be involved in a
  // race.
  for (Instruction *I : Allocas) {
    if (CilkSanImpl.ObjectMRForRace.count(I) ||
        CilkSanImpl.lookupPointerMayBeCaptured(I)) {
      CilkSanImpl.instrumentAlloca(I);
      getDetachesForInstruction(I);
      Result = true;
    }
  }
  for (Instruction *I : AllocationFnCalls) {
    // FIXME: This test won't identify posix_memalign calls as needing
    // instrumentation, because posix_memalign modifies a pointer to the pointer
    // to the object.
    if (CilkSanImpl.ObjectMRForRace.count(I) ||
        CilkSanImpl.lookupPointerMayBeCaptured(I)) {
      CilkSanImpl.instrumentAllocationFn(I, DT, TLI);
      getDetachesForInstruction(I);
      Result = true;
    }
  }
  for (Instruction *I : FreeCalls) {
    // The first argument of the free call is the pointer.
    Value *Ptr = I->getOperand(0);
    // If the pointer corresponds to an allocation function call in this
    // function, or if the pointer is involved in a race, then instrument it.
    if (Instruction *PtrI = dyn_cast<Instruction>(Ptr)) {
      if (AllocationFnCalls.count(PtrI)) {
        CilkSanImpl.instrumentFree(I, TLI);
        getDetachesForInstruction(I);
        Result = true;
        continue;
      }
    }
    if (RI.ObjectInvolvedInRace(Ptr) ||
        CilkSanImpl.unknownObjectUses(Ptr, &LI, TLI)) {
      CilkSanImpl.instrumentFree(I, TLI);
      getDetachesForInstruction(I);
      Result = true;
    }
  }

  // Instrument detaches
  for (DetachInst *DI : Detaches) {
    CilkSanImpl.instrumentDetach(DI, SyncRegNums[DI->getSyncRegion()],
                                 SRCounters[DI->getDetached()], DT, TI, LI);
    Result = true;
    // Get syncs associated with this detach
    for (SyncInst *SI : CilkSanImpl.DetachToSync[DI])
      Syncs.insert(SI);

    if (CilkSanImpl.Options.InstrumentLoops) {
      // Get any loop associated with this detach.
      Loop *L = LI.getLoopFor(DI->getParent());
      if (spawnsTapirLoopBody(DI, LI, TI))
        Loops.insert(L);
    }
  }

  // Instrument associated syncs
  for (SyncInst *SI : Syncs)
    CilkSanImpl.instrumentSync(SI, SyncRegNums[SI->getSyncRegion()]);

  if (CilkSanImpl.Options.InstrumentLoops) {
    // Recursively instrument all loops
    for (Loop *L : Loops)
      CilkSanImpl.instrumentTapirLoop(*L, TI, SyncRegNums);
  }

  return Result;
}

// Helper function to get a value for the runtime trip count of the given loop.
static const SCEV *getRuntimeTripCount(Loop &L, ScalarEvolution *SE,
                                       bool IsTapirLoop) {
  BasicBlock *Latch = L.getLoopLatch();

  // The exit count from the latch is sufficient for Tapir loops, because early
  // exits from such loops are handled in a special manner.  For other loops, we
  // use the backedge taken count.
  const SCEV *BECountSC =
      IsTapirLoop ? SE->getExitCount(&L, Latch) : SE->getBackedgeTakenCount(&L);
  if (isa<SCEVCouldNotCompute>(BECountSC) ||
      !BECountSC->getType()->isIntegerTy()) {
    LLVM_DEBUG(dbgs() << "Could not compute exit block SCEV\n");
    return SE->getCouldNotCompute();
  }

  // Add 1 since the backedge count doesn't include the first loop iteration.
  const SCEV *TripCountSC =
      SE->getAddExpr(BECountSC, SE->getConstant(BECountSC->getType(), 1));
  if (isa<SCEVCouldNotCompute>(TripCountSC)) {
    LLVM_DEBUG(dbgs() << "Could not compute trip count SCEV.\n");
    return SE->getCouldNotCompute();
  }

  return TripCountSC;
}

// Helper function to find where in the given basic block to insert coalesced
// instrumentation.
static Instruction *getLoopBlockInsertPt(BasicBlock *BB, FunctionCallee LoopHook,
                                         bool AfterHook) {
  // BasicBlock *PreheaderBB = L->getLoopPreheader();
  for (Instruction &I : *BB)
    if (CallBase *CB = dyn_cast<CallBase>(&I))
      if (const Function *Called = CB->getCalledFunction())
        if (Called == LoopHook.getCallee()) {
          // We found a call to the specified hook.  Pick an insertion point
          // with respect to it.
          if (AfterHook)
            return &*CB->getIterator()->getNextNode();
          else
            return CB;
        }

  if (AfterHook)
    return &*BB->getFirstInsertionPt();
  else
    return BB->getTerminator();
}

// TODO: Maybe to avoid confusion with CilkSanImpl.Options.InstrumentLoops
// (which is unrelated to this), rename this to involve the word "hoist" or something.
bool CilkSanitizerImpl::Instrumentor::InstrumentLoops(
    SmallPtrSetImpl<Instruction *> &LoopInstToHoist,
    SmallPtrSetImpl<Instruction *> &LoopInstToSink,
    SmallPtrSetImpl<const Loop *> &TapirLoops, ScalarEvolution *SE) {
  bool Result = false;

  // First insert computation for the hook arguments for all instructions to
  // hoist or sink coalesced instrumentation.  We do this before inserting the
  // hook calls themselves, so that changes to the CFG -- specifically, from
  // inserting MAAP checks -- do not disrupt any function analyses we need.

  // Map instructions in the loop to address and range arguments for coalesced
  // instrumentation.
  DenseMap<Instruction *, std::pair<Value *, Value *>> HoistedHookArgs;
  // Compute arguments for coalesced instrumentation hoisted to before the loop.
  for (Instruction *I : LoopInstToHoist) {
    // Get the insertion point in the preheader of the loop.
    Loop *L = LI.getLoopFor(I->getParent());
    assert(L->getLoopPreheader() && "No preheader for loop");
    Instruction *PreheaderInsertPt =
        getLoopBlockInsertPt(L->getLoopPreheader(), CilkSanImpl.CsanBeforeLoop,
                             /*AfterHook*/ false);

    // TODO: Unify this SCEV computation with the similar computation for
    // instructions in LoopInstToSink.

    // Get the SCEV describing this instruction's pointer
    const SCEV *V = SE->getSCEV(getLoadStorePointerOperand(I));
    const SCEVAddRecExpr *SrcAR = dyn_cast<SCEVAddRecExpr>(V);

    // Get the stride
    const SCEV *StrideExpr = SrcAR->getStepRecurrence(*SE);
    assert(!isa<SCEVCouldNotCompute>(StrideExpr) &&
           "Stride should be computable");
    bool NegativeStride = SE->isKnownNegative(StrideExpr);
    if (NegativeStride)
      StrideExpr = SE->getNegativeSCEV(StrideExpr);

    // Get the first address accessed.
    const SCEV *FirstAddr = SrcAR->getStart();

    // Get the last address accessed.
    BasicBlock *Latch = L->getLoopLatch();
    const SCEV *BECount = TapirLoops.count(L) ? SE->getExitCount(L, Latch)
                                              : SE->getBackedgeTakenCount(L);
    const SCEV *LastAddr = SrcAR->evaluateAtIteration(BECount, *SE);

    // Get the size (number of bytes) of the address range accessed.
    const SCEV *RangeExpr = NegativeStride
                                ? SE->getMinusSCEV(FirstAddr, LastAddr)
                                : SE->getMinusSCEV(LastAddr, FirstAddr);
    RangeExpr = SE->getAddExpr(RangeExpr, StrideExpr);

    // Get the start (lowest address) of the address range accessed.
    const SCEV *Addr = NegativeStride ? LastAddr : FirstAddr;

    // Get instructions for calculating address range
    const DataLayout &DL = CilkSanImpl.M.getDataLayout();
    LLVMContext &Ctx = CilkSanImpl.M.getContext();
    SCEVExpander Expander(*SE, DL, "cilksan");

    Value *AddrVal = Expander.expandCodeFor(Addr, Type::getInt8PtrTy(Ctx),
                                            PreheaderInsertPt);
    Value *RangeVal = Expander.expandCodeFor(RangeExpr, Type::getInt64Ty(Ctx),
                                             PreheaderInsertPt);
    HoistedHookArgs[I] = std::make_pair(AddrVal, RangeVal);
  }

  // Map pairs of instruction and loop-exit to address and range arguments for
  // coalesced instrumentation.
  DenseMap<std::pair<Instruction *, BasicBlock *>, std::pair<Value *, Value *>>
      SunkHookArgs;
  // Map to track which loops we have already created counters for
  SmallMapVector<Loop*, Value*, 8> LoopToCounterMap;
  // Compute arguments for coalesced instrumentation sunk after the loop.
  for (Instruction *I : LoopInstToSink) {
    // Get the loop
    Loop *L = LI.getLoopFor(I->getParent());

    // Add a counter to count the number of iterations executed in this loop.
    // In particular, this count will record the number of times the backedge of
    // the loop is taken.
    if (!LoopToCounterMap.count(L)) {
      assert(L->getLoopPreheader() && "No preheader for loop");
      assert(L->getLoopLatch() && "No unique latch for loop");
      IRBuilder<> IRB(&L->getHeader()->front());
      LLVMContext &Ctx = CilkSanImpl.M.getContext();

      PHINode *PN = IRB.CreatePHI(Type::getInt64Ty(Ctx), 2);
      PN->addIncoming(ConstantInt::getNullValue(Type::getInt64Ty(Ctx)),
                      L->getLoopPreheader());
      IRB.SetInsertPoint(&*L->getLoopLatch()->getFirstInsertionPt());
      Value *Add = IRB.CreateAdd(PN, ConstantInt::get(Type::getInt64Ty(Ctx), 1),
                                 "", true, true);
      PN->addIncoming(Add, L->getLoopLatch());
      LoopToCounterMap.insert(std::make_pair(L, PN));
    }

    // Get the counter for this loop.
    Value *Counter = LoopToCounterMap[L];

    // Get the SCEV describing this instruction's pointer
    const SCEV *V = SE->getSCEV(getLoadStorePointerOperand(I));
    const SCEVAddRecExpr *SrcAR = dyn_cast<SCEVAddRecExpr>(V);

    // Get the stride
    const SCEV *StrideExpr = SrcAR->getStepRecurrence(*SE);
    assert(!isa<SCEVCouldNotCompute>(StrideExpr) &&
           "Stride should be computable");
    bool NegativeStride = SE->isKnownNegative(StrideExpr);
    if (NegativeStride)
      StrideExpr = SE->getNegativeSCEV(StrideExpr);

    // Get the first address accessed.
    const SCEV *FirstAddr = SrcAR->getStart();

    // Get the last address accessed, based on the counter value..
    const SCEV *BECount = SE->getUnknown(Counter);
    const SCEV *LastAddr = SrcAR->evaluateAtIteration(BECount, *SE);

    // Get the size (number of bytes) of the address range accessed.
    const SCEV *RangeExpr = NegativeStride
                                ? SE->getMinusSCEV(FirstAddr, LastAddr)
                                : SE->getMinusSCEV(LastAddr, FirstAddr);
    RangeExpr = SE->getAddExpr(RangeExpr, StrideExpr);
    // Get the start (lowest address) of the address range accessed.
    const SCEV *Addr = NegativeStride ? LastAddr : FirstAddr;

    // Expand SCEV's into instructions for calculating the coalesced hook
    // arguments in each exit block.
    LLVMContext &Ctx = CilkSanImpl.M.getContext();
    const DataLayout &DL = CilkSanImpl.M.getDataLayout();
    SCEVExpander Expander(*SE, DL, "cilksan");
    SmallVector<BasicBlock *, 4> ExitBlocks;
    L->getUniqueExitBlocks(ExitBlocks);
    for (BasicBlock *ExitBB : ExitBlocks) {
      if (GetTopLevelTaskFor(ExitBB, L, TI))
        // Skip any exit blocks in a Tapir task inside the loop.  These exit
        // blocks lie on exception-handling paths, and to handle these blocks,
        // it suffices to insert instrumentation in the unwind destination of
        // the corresponding detach, which must also be a loop-exit block.
        continue;

      // Instruction *InsertPt = &*ExitBB->getFirstInsertionPt();
      Instruction *InsertPt =
          getLoopBlockInsertPt(ExitBB, CilkSanImpl.CsanAfterLoop,
                               /*AfterHook*/ true);
      Value *AddrVal =
          Expander.expandCodeFor(Addr, Type::getInt8PtrTy(Ctx), InsertPt);
      Value *RangeVal =
          Expander.expandCodeFor(RangeExpr, Type::getInt64Ty(Ctx), InsertPt);

      assert(isa<Instruction>(RangeVal) &&
             "Expected computation of RangeVal to produce an instruction.");
      SunkHookArgs[std::make_pair(I, ExitBB)] =
          std::make_pair(AddrVal, RangeVal);
    }
  }

  // Now insert coalesced instrumentation, including relevant MAAP checks.
  //
  // TODO: For now, we only handle LoadInst and StoreInst.  Add other operations
  // later, such as atomics and memory intrinsics.

  // Insert coalesced instrumentation hoisted before the loop.
  for (Instruction *I : LoopInstToHoist) {
    LLVM_DEBUG(dbgs() << "Loop instruction for hoisting instrumentation: " << *I
                      << "\n");

    // Get the local ID of this instruction.
    uint64_t LocalId;
    if (LoadInst *LI = dyn_cast<LoadInst>(I)) {
      uint64_t LoadId = CilkSanImpl.LoadFED.add(*LI);

      // TODO: Don't recalculate underlying objects
      uint64_t LoadObjId = CilkSanImpl.LoadObj.add(
          *LI,
          CilkSanImpl.lookupUnderlyingObject(getLoadStorePointerOperand(LI)));
      assert(LoadId == LoadObjId &&
             "Load received different ID's in FED and object tables.");
      LocalId = LoadId;
      // Update the statistic here, since we're guaranteed to insert the hook at
      // this point.
      ++NumHoistedInstrumentedReads;
    } else if (StoreInst *SI = dyn_cast<StoreInst>(I)) {
      uint64_t StoreId = CilkSanImpl.StoreFED.add(*SI);

      // TODO: Don't recalculate underlying objects
      uint64_t StoreObjId = CilkSanImpl.StoreObj.add(
          *SI,
          CilkSanImpl.lookupUnderlyingObject(getLoadStorePointerOperand(SI)));
      assert(StoreId == StoreObjId &&
             "Store received different ID's in FED and object tables.");
      LocalId = StoreId;
      // Update the statistic here, since we're guaranteed to insert the hook at
      // this point.
      ++NumHoistedInstrumentedWrites;
    } else
      llvm_unreachable("Unexpected instruction to hoist instrumentation.");

    // For now, there shouldn't be a reason to return false since we already
    // verified the size, stride, and tripcount.
    Loop *L = LI.getLoopFor(I->getParent());
    Instruction *PreheaderInsertPt =
        getLoopBlockInsertPt(L->getLoopPreheader(), CilkSanImpl.CsanBeforeLoop,
                             /*AfterLoop*/ false);
    IRBuilder<> IRB(PreheaderInsertPt);
    if (MAAPChecks) {
      Value *MAAPChk = getMAAPCheck(I, IRB);
      Instruction *CheckTerm =
          SplitBlockAndInsertIfThen(IRB.CreateICmpEQ(MAAPChk, IRB.getFalse()),
                                    PreheaderInsertPt, false, nullptr, DT, &LI);
      IRB.SetInsertPoint(CheckTerm);
    }

    CilkSanImpl.instrumentLoadOrStoreHoisted(
        I, HoistedHookArgs[I].first, HoistedHookArgs[I].second, IRB, LocalId);
    Result = true;
  }

  // Insert coalesced instrumentation sunk after the loop.
  for (Instruction *I : LoopInstToSink) {
    LLVM_DEBUG(dbgs() << "Loop instruction for sinking instrumentation: " << *I
                      << "\n");
    Loop *L = LI.getLoopFor(I->getParent());

    // Get the local ID of this instruction.  We do this computation early to
    // avoid recomputing the local ID once per exit block.
    uint64_t LocalId;
    if (LoadInst *LI = dyn_cast<LoadInst>(I)) {
      uint64_t LoadId = CilkSanImpl.LoadFED.add(*LI);

      // TODO: Don't recalculate underlying objects
      uint64_t LoadObjId = CilkSanImpl.LoadObj.add(
          *LI,
          CilkSanImpl.lookupUnderlyingObject(getLoadStorePointerOperand(LI)));
      assert(LoadId == LoadObjId &&
             "Load received different ID's in FED and object tables.");
      LocalId = LoadId;
      // Update the statistic here, since we're guaranteed to insert the hooks
      // at this point, and to avoid overcounting the number of instructions on
      // loops with multiple exits.
      ++NumSunkInstrumentedReads;
    } else if (StoreInst *SI = dyn_cast<StoreInst>(I)) {
      uint64_t StoreId = CilkSanImpl.StoreFED.add(*SI);

      // TODO: Don't recalculate underlying objects
      uint64_t StoreObjId = CilkSanImpl.StoreObj.add(
          *SI,
          CilkSanImpl.lookupUnderlyingObject(getLoadStorePointerOperand(SI)));
      assert(StoreId == StoreObjId &&
             "Store received different ID's in FED and object tables.");
      LocalId = StoreId;
      // Update the statistic here, since we're guaranteed to insert the hooks
      // at this point, and to avoid overcounting the number of instructions on
      // loops with multiple exits.
      ++NumSunkInstrumentedWrites;
    } else
      llvm_unreachable("Unexpected instruction to sink instrumentation.");

    SmallVector<BasicBlock *, 4> ExitBlocks;
    L->getUniqueExitBlocks(ExitBlocks);
    for (BasicBlock *ExitBB : ExitBlocks) {
      if (GetTopLevelTaskFor(ExitBB, L, TI))
        // Skip any exit blocks in a Tapir task inside the loop.  These exit
        // blocks lie on exception-handling paths, and to handle these blocks,
        // it suffices to insert instrumentation in the unwind destination of
        // the corresponding detach, which must also be a loop-exit block.
        continue;

      // After the loop, perform the coalesced read/write.
      auto HookArgsKey = std::make_pair(I, ExitBB);

      // Insert the hook call after the computation of RangeVal.
      Instruction *InsertPt =
          cast<Instruction>(SunkHookArgs[HookArgsKey].second)
              ->getIterator()
              ->getNextNode();
      IRBuilder<> IRB(&*InsertPt);
      if (MAAPChecks) {
        Value *MAAPChk = getMAAPCheck(I, IRB);
        Instruction *CheckTerm =
            SplitBlockAndInsertIfThen(IRB.CreateICmpEQ(MAAPChk, IRB.getFalse()),
                                      &*InsertPt, false, nullptr, DT, &LI);
        IRB.SetInsertPoint(CheckTerm);
      }

      CilkSanImpl.instrumentLoadOrStoreHoisted(
          I, SunkHookArgs[HookArgsKey].first, SunkHookArgs[HookArgsKey].second,
          IRB, LocalId);
      Result = true;
    }
  }

  return Result;
}

bool CilkSanitizerImpl::instrumentLoadOrStoreHoisted(
    Instruction *I, Value *Addr, Value *Size, IRBuilder<> &IRB, uint64_t LocalId) {
  // The caller of this method is guaranteed to have computed the Addr and Size
  // values with the right type for the hook, so no additional type conversions
  // are needed.
  CsiLoadStoreProperty Prop;
  if (LoadInst *LI = dyn_cast<LoadInst>(I)) {
    Prop.setAlignment(LI->getAlignment());
    // Instrument the load
    Value *CsiId = LoadFED.localToGlobalId(LocalId, IRB);
    Value *Args[] = {CsiId, Addr, Size, Prop.getValue(IRB)};
    Instruction *Call = IRB.CreateCall(CsanLargeRead, Args);
    IRB.SetInstDebugLocation(Call);
  } else if (StoreInst *SI = dyn_cast<StoreInst>(I)) {
    Prop.setAlignment(SI->getAlignment());
    // Instrument the store
    Value *CsiId = StoreFED.localToGlobalId(LocalId, IRB);
    Value *Args[] = {CsiId, Addr, Size, Prop.getValue(IRB)};
    Instruction *Call = IRB.CreateCall(CsanLargeWrite, Args);
    IRB.SetInstDebugLocation(Call);
  }
  return true;
}

static bool CheckSanitizeCilkAttr(Function &F) {
  if (IgnoreSanitizeCilkAttr)
    return true;
  return F.hasFnAttribute(Attribute::SanitizeCilk);
}

bool CilkSanitizerImpl::setupFunction(Function &F) {
  if (F.empty() || shouldNotInstrumentFunction(F) ||
      !CheckSanitizeCilkAttr(F)) {
    LLVM_DEBUG({
        dbgs() << "Skipping " << F.getName() << "\n";
        if (F.empty())
          dbgs() << "  Empty function\n";
        else if (shouldNotInstrumentFunction(F))
          dbgs() << "  Function should not be instrumented\n";
        else if (!CheckSanitizeCilkAttr(F))
          dbgs() << "  Function lacks sanitize_cilk attribute\n";});
    return false;
  }

  LLVM_DEBUG(dbgs() << "Setting up " << F.getName()
                    << " for instrumentation\n");

  if (Options.CallsMayThrow)
    // Promote calls to invokes to insert instrumentation in exception-handling
    // code.
    setupCalls(F);

  DominatorTree *DT = &GetDomTree(F);
  LoopInfo &LI = GetLoopInfo(F);

  if (Options.InstrumentLoops)
    // Simplify loops to prepare for loop instrumentation
    for (Loop *L : LI)
      simplifyLoop(L, DT, &LI, nullptr, nullptr, nullptr,
                   /* PreserveLCSSA */ false);

  // Canonicalize the CFG for instrumentation
  setupBlocks(F, DT, &LI);

  return true;
}

/// Set DebugLoc on the call instruction to a CSI hook, based on the
/// debug information of the instrumented instruction.
static void setInstrumentationDebugLoc(Function &Instrumented,
                                       Instruction *Call) {
  DISubprogram *Subprog = Instrumented.getSubprogram();
  if (Subprog) {
    LLVMContext &C = Instrumented.getParent()->getContext();
    Call->setDebugLoc(DILocation::get(C, 0, 0, Subprog));
  }
}

bool CilkSanitizerImpl::instrumentFunctionUsingRI(Function &F) {

  if (F.empty() || shouldNotInstrumentFunction(F) ||
      !CheckSanitizeCilkAttr(F)) {
    LLVM_DEBUG({
        dbgs() << "Skipping " << F.getName() << "\n";
        if (F.empty())
          dbgs() << "  Empty function\n";
        else if (shouldNotInstrumentFunction(F))
          dbgs() << "  Function should not be instrumented\n";
        else if (!CheckSanitizeCilkAttr(F))
          dbgs() << "  Function lacks sanitize_cilk attribute\n";});
    return false;
  }

  LLVM_DEBUG(dbgs() << "Instrumenting " << F.getName() << "\n");

  SmallVector<Instruction *, 8> AllLoadsAndStores;
  SmallVector<Instruction *, 8> LocalLoadsAndStores;
  SmallVector<Instruction *, 8> AtomicAccesses;
  SmallVector<Instruction *, 8> MemIntrinCalls;
  SmallVector<Instruction *, 8> IntrinsicCalls;
  SmallVector<Instruction *, 8> LibCalls;
  SmallVector<Instruction *, 8> Callsites;
  // Ancillary instructions
  SmallPtrSet<Instruction *, 8> Allocas;
  SmallPtrSet<Instruction *, 8> AllocationFnCalls;
  SmallPtrSet<Instruction *, 8> FreeCalls;
  SmallVector<SyncInst *, 8> Syncs;
  DenseMap<BasicBlock *, unsigned> SRCounters;
  DenseMap<Value *, unsigned> SyncRegNums;

  // Find instructions that can be hoisted or sinked
  SmallPtrSet<Instruction *, 8> LoopInstToHoist;
  SmallPtrSet<Instruction *, 8> LoopInstToSink;
  SmallPtrSet<const Loop *, 8> TapirLoops;

  const TargetLibraryInfo *TLI = &GetTLI(F);
  DominatorTree *DT = &GetDomTree(F);
  LoopInfo &LI = GetLoopInfo(F);
  TaskInfo &TI = GetTaskInfo(F);
  RaceInfo &RI = GetRaceInfo(F);

  ICFLoopSafetyInfo SafetyInfo(DT);

  ScalarEvolution &SE = *(RI.getSE());

  for (BasicBlock &BB : F) {
    // Record the Tapir sync instructions found
    if (SyncInst *SI = dyn_cast<SyncInst>(BB.getTerminator()))
      Syncs.push_back(SI);

    // get loop for BB
    Loop *L = LI.getLoopFor(&BB);

    // Record the memory accesses in the basic block
    for (Instruction &Inst : BB) {
      bool canCoalesce = false;
      // if the instruction is in a loop and can only race via ancestor,
      // and size < stride, store it.
      if (L && EnableStaticRaceDetection && LoopHoisting &&
          SafetyInfo.isGuaranteedToExecute(Inst, DT, &TI, L)) {
        // TODO: for now, only look @ loads and stores. Add atomics later.
        //       Need to add any others?
        if (isa<LoadInst>(Inst) || isa<StoreInst>(Inst)) {
          bool raceViaAncestor = false;
          bool otherRace = false;
          for (const RaceInfo::RaceData &RD : RI.getRaceData(&Inst)) {
            if (RaceInfo::isRaceViaAncestor(RD.Type)) {
              raceViaAncestor = true;
            } else if (RaceInfo::isLocalRace(RD.Type) ||
                       RaceInfo::isOpaqueRace(RD.Type)) {
              otherRace = true;
              break;
            }
          }
          // if this instruction can only race via an ancestor, see if it
          // can be hoisted.
          if (raceViaAncestor && !otherRace) {
            const SCEV *Size = SE.getElementSize(&Inst);
            const SCEV *V = SE.getSCEV(getLoadStorePointerOperand(&Inst));
            // if not an AddRecExpr, don't proceed
            if (const SCEVAddRecExpr *SrcAR = dyn_cast<SCEVAddRecExpr>(V)) {
              const SCEV *Stride = SrcAR->getStepRecurrence(SE);
              const SCEV *Diff;
              if (SE.isKnownNonNegative(Stride)) {
                Diff = SE.getMinusSCEV(Size, Stride);
              } else {
                // if we can't compare size and stride,
                // SE.isKnownNonNegative(Diff) will be false.
                Diff = SE.getAddExpr(Size, Stride);
              }
              bool isTapirLoop = static_cast<bool>(getTaskIfTapirLoop(L, &TI));
              if (isTapirLoop)
                TapirLoops.insert(L);
              const SCEV *TripCount = getRuntimeTripCount(*L, &SE, isTapirLoop);

              if (SE.isKnownNonNegative(Diff)) {
                if (!isa<SCEVCouldNotCompute>(TripCount) &&
                    SE.isAvailableAtLoopEntry(SrcAR->getStart(), L)) {
                  // can hoist if |stride| <= |size| and the tripcount is known
                  // and the start is available at loop entry.
                  LoopInstToHoist.insert(&Inst);
                  canCoalesce = true;
                } else if (!isa<SCEVCouldNotCompute>(
                               SE.getConstantMaxBackedgeTakenCount(L))) {
                  // can sink if |stride| <= |size| and the tripcount is
                  // unknown but guaranteed to be finite.
                  LoopInstToSink.insert(&Inst);
                  canCoalesce = true;
                }
              }
            }
          }
        }
      }

      if (!canCoalesce) {
        // TODO: Handle VAArgInst
        if (isa<LoadInst>(Inst) || isa<StoreInst>(Inst))
          LocalLoadsAndStores.push_back(&Inst);
        else if (isa<AtomicRMWInst>(Inst) || isa<AtomicCmpXchgInst>(Inst))
          AtomicAccesses.push_back(&Inst);
        else if (isa<AllocaInst>(Inst))
          Allocas.insert(&Inst);
        else if (isa<CallBase>(Inst)) {
          // if (CallInst *CI = dyn_cast<CallInst>(&Inst))
          //   maybeMarkSanitizerLibraryCallNoBuiltin(CI, TLI);

          // If we find a sync region, record it.
          if (const IntrinsicInst *II = dyn_cast<IntrinsicInst>(&Inst))
            if (Intrinsic::syncregion_start == II->getIntrinsicID()) {
              // Identify this sync region with a counter value, where all sync
              // regions within a function or task are numbered from 0.
              BasicBlock *TEntry = TI.getTaskFor(&BB)->getEntry();
              // Create a new counter if need be.
              if (!SRCounters.count(TEntry))
                SRCounters[TEntry] = 0;
              SyncRegNums[&Inst] = SRCounters[TEntry]++;
            }

          // Record this function call as either an allocation function, a call to
          // free (or delete), a memory intrinsic, or an ordinary real function
          // call.
          if (isAllocFn(&Inst, TLI))
            AllocationFnCalls.insert(&Inst);
          else if (isFreeCall(&Inst, TLI, /*IgnoreBuiltinAttr*/ true))
            FreeCalls.insert(&Inst);
          else if (isa<AnyMemIntrinsic>(Inst))
            MemIntrinCalls.push_back(&Inst);
          else if (!simpleCallCannotRace(Inst) && !shouldIgnoreCall(Inst)) {
            if (isa<IntrinsicInst>(&Inst)) {
              if (Inst.mayReadOrWriteMemory())
                IntrinsicCalls.push_back(&Inst);
            } else if (isLibCall(Inst, TLI)) {
              if (Inst.mayReadOrWriteMemory())
                LibCalls.push_back(&Inst);
            } else {
              Callsites.push_back(&Inst);
            }
          }
        }

        // Add the current set of local loads and stores to be considered for
        // instrumentation.
        if (!simpleCallCannotRace(Inst)) {
          chooseInstructionsToInstrument(LocalLoadsAndStores, AllLoadsAndStores,
                                         TI, LI, TLI);
        }
      }
    }
    chooseInstructionsToInstrument(LocalLoadsAndStores, AllLoadsAndStores, TI,
                                   LI, TLI);
  }

  // Evaluate the tasks that might be in parallel with each spindle.
  MaybeParallelTasks MPTasks;
  TI.evaluateParallelState<MaybeParallelTasks>(MPTasks);

  // Map each detach instruction with the sync instructions that could sync it.
  for (SyncInst *Sync : Syncs)
    for (const Task *MPT :
             MPTasks.TaskList[TI.getSpindleFor(Sync->getParent())])
      DetachToSync[MPT->getDetach()].push_back(Sync);

  // Record objects involved in races
  for (auto &ObjRD : RI.getObjectMRForRace())
    ObjectMRForRace[ObjRD.first] = ObjRD.second;

  uint64_t LocalId = getLocalFunctionID(F);
  IRBuilder<> IRB(&*F.getEntryBlock().getFirstInsertionPt());
  Value *FuncId = FunctionFED.localToGlobalId(LocalId, IRB);

  bool Result = false;
  if (!EnableStaticRaceDetection) {
    SimpleInstrumentor FuncI(*this, TI, LI, DT, TLI);
    Result |= FuncI.InstrumentSimpleInstructions(AllLoadsAndStores);
    Result |= FuncI.InstrumentSimpleInstructions(AtomicAccesses);
    Result |= FuncI.InstrumentAnyMemIntrinsics(MemIntrinCalls);
    Result |= FuncI.InstrumentCalls(IntrinsicCalls);
    Result |= FuncI.InstrumentCalls(LibCalls);
    Result |= FuncI.InstrumentCalls(Callsites);

    // Instrument ancillary instructions including allocas, allocation-function
    // calls, free calls, detaches, and syncs.
    Result |= FuncI.InstrumentAncillaryInstructions(Allocas, AllocationFnCalls,
                                                    FreeCalls, SyncRegNums,
                                                    SRCounters, DL);
  } else {
    Instrumentor FuncI(*this, RI, TI, LI, DT, TLI);

    // Insert MAAP flags for each function argument.
    FuncI.InsertArgMAAPs(F, FuncId);

    Result |= FuncI.InstrumentSimpleInstructions(AllLoadsAndStores);
    Result |= FuncI.InstrumentSimpleInstructions(AtomicAccesses);
    Result |= FuncI.InstrumentAnyMemIntrinsics(MemIntrinCalls);
    Result |= FuncI.InstrumentCalls(IntrinsicCalls);
    Result |= FuncI.InstrumentCalls(LibCalls);
    Result |= FuncI.InstrumentCalls(Callsites);

    // Find detaches that need to be instrumented for loop instructions whose
    // instrumentation will be coalesced.
    FuncI.GetDetachesForCoalescedInstrumentation(LoopInstToHoist,
                                                 LoopInstToSink);

    // Instrument ancillary instructions including allocas, allocation-function
    // calls, free calls, detaches, and syncs.
    Result |= FuncI.InstrumentAncillaryInstructions(Allocas, AllocationFnCalls,
                                                    FreeCalls, SyncRegNums,
                                                    SRCounters, DL);

    // Hoist and sink instrumentation when possible (applies to all loops,
    // not just Tapir loops)
    // Also inserts MAAP checks for hoisted/sinked instrumentation
    Result |=
        FuncI.InstrumentLoops(LoopInstToHoist, LoopInstToSink, TapirLoops, &SE);

    // Once we have handled ancillary instructions, we've done the necessary
    // analysis on this function.  We now perform delayed instrumentation, which
    // can involve changing the CFG and thereby violating some analyses.
    Result |= FuncI.PerformDelayedInstrumentation();
  }

  if (Result) {
    bool MaySpawn = !TI.isSerial();
    if (InstrumentationSet & SERIESPARALLEL) {
      IRBuilder<> IRB(&*(++(cast<Instruction>(FuncId)->getIterator())));
      CsiFuncProperty FuncEntryProp;
      FuncEntryProp.setMaySpawn(MaySpawn);
      if (MaySpawn)
        FuncEntryProp.setNumSyncReg(SRCounters[TI.getRootTask()->getEntry()]);
      // TODO: Determine if we actually want the frame pointer, not the stack
      // pointer.
      Value *FrameAddr =
          IRB.CreateCall(Intrinsic::getDeclaration(&M, Intrinsic::frameaddress,
                                                   IRB.getInt8PtrTy()),
                         {IRB.getInt32(0)});
      Value *StackSave =
          IRB.CreateCall(Intrinsic::getDeclaration(&M, Intrinsic::stacksave));
      CallInst *EntryCall =
          IRB.CreateCall(CsanFuncEntry, {FuncId, FrameAddr, StackSave,
                                         FuncEntryProp.getValue(IRB)});
      setInstrumentationDebugLoc(F, EntryCall);
    } else {
      // Search for a call to CsanFuncEntry, and update its ID argument.
      for (BasicBlock::iterator I = cast<Instruction>(FuncId)->getIterator(),
                                E = F.getEntryBlock().end();
           I != E; ++I) {
        if (CallBase *CB = dyn_cast<CallBase>(&*I))
          if (CB->getCalledFunction() == CsanFuncEntry.getCallee()) {
            CB->setArgOperand(0, FuncId);
            break;
          }
      }
    }

    EscapeEnumerator EE(F, "csan_cleanup", false);
    while (IRBuilder<> *AtExit = EE.Next()) {
      if (InstrumentationSet & SERIESPARALLEL) {
        uint64_t ExitLocalId = FunctionExitFED.add(*AtExit->GetInsertPoint());
        Value *ExitCsiId = FunctionExitFED.localToGlobalId(ExitLocalId, *AtExit);
        CsiFuncExitProperty FuncExitProp;
        FuncExitProp.setMaySpawn(MaySpawn);
        FuncExitProp.setEHReturn(isa<ResumeInst>(AtExit->GetInsertPoint()));
        CallInst *ExitCall = AtExit->CreateCall(
            CsanFuncExit, {ExitCsiId, FuncId, FuncExitProp.getValue(*AtExit)});
        setInstrumentationDebugLoc(F, ExitCall);
      } else {
        // Search for a call to CsanFuncExit, and update its ID argument.
        for (BasicBlock::iterator I = AtExit->GetInsertBlock()->begin(),
                                  E = AtExit->GetInsertBlock()->end();
             I != E; ++I) {
          if (CallBase *CB = dyn_cast<CallBase>(&*I))
            if (CB->getCalledFunction() == CsanFuncExit.getCallee()) {
              CB->setArgOperand(1, FuncId);
              break;
            }
        }
      }
    }
  }

  // Record aggregate race information for the function and its arguments for
  // interprocedural analysis.
  //
  // TODO: Clean this up
  RaceInfo::RaceType FuncRT = RaceInfo::None;
  for (Instruction *I : AllLoadsAndStores)
    FuncRT = RaceInfo::unionRaceTypes(FuncRT, RI.getRaceType(I));
  for (Instruction *I : AtomicAccesses)
    FuncRT = RaceInfo::unionRaceTypes(FuncRT, RI.getRaceType(I));
  for (Instruction *I : MemIntrinCalls)
    FuncRT = RaceInfo::unionRaceTypes(FuncRT, RI.getRaceType(I));
  for (Instruction *I : Callsites) {
    if (const CallBase *CB = dyn_cast<CallBase>(I)) {
      // Use updated information about the race type of the call, if it's
      // available.
      const Function *CF = CB->getCalledFunction();
      if (FunctionRaceType.count(CF)) {
        FuncRT = RaceInfo::unionRaceTypes(FuncRT, FunctionRaceType[CF]);
        continue;
      }
    }
    FuncRT = RaceInfo::unionRaceTypes(FuncRT, RI.getRaceType(I));
  }
  FunctionRaceType[&F] = FuncRT;

  return Result;
}

bool CilkSanitizerImpl::instrumentLoadOrStore(Instruction *I,
                                              IRBuilder<> &IRB) {
  bool IsWrite = isa<StoreInst>(*I);
  Value *Addr = IsWrite
      ? cast<StoreInst>(I)->getPointerOperand()
      : cast<LoadInst>(I)->getPointerOperand();

  // swifterror memory addresses are mem2reg promoted by instruction selection.
  // As such they cannot have regular uses like an instrumentation function and
  // it makes no sense to track them as memory.
  if (Addr->isSwiftError())
    return false;

  int NumBytesAccessed = getNumBytesAccessed(Addr, DL);
  if (-1 == NumBytesAccessed) {
    // Ignore accesses with bad sizes.
    NumAccessesWithBadSize++;
    return false;
  }

  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SHADOWMEMORY))
    return true;

  const unsigned Alignment = IsWrite
      ? cast<StoreInst>(I)->getAlignment()
      : cast<LoadInst>(I)->getAlignment();
  CsiLoadStoreProperty Prop;
  Prop.setAlignment(Alignment);
  Prop.setIsAtomic(I->isAtomic());
  if (IsWrite) {
    // Instrument store
    uint64_t LocalId = StoreFED.add(*I);
    uint64_t StoreObjId = StoreObj.add(*I, lookupUnderlyingObject(Addr));
    assert(LocalId == StoreObjId &&
           "Store received different ID's in FED and object tables.");
    Value *CsiId = StoreFED.localToGlobalId(LocalId, IRB);
    Value *Args[] = {CsiId,
                     IRB.CreatePointerCast(Addr, IRB.getInt8PtrTy()),
                     IRB.getInt32(NumBytesAccessed),
                     Prop.getValue(IRB)};
    Instruction *Call = IRB.CreateCall(CsanWrite, Args);
    IRB.SetInstDebugLocation(Call);
    NumInstrumentedWrites++;
  } else {
    // Instrument load
    uint64_t LocalId = LoadFED.add(*I);
    uint64_t LoadObjId = LoadObj.add(*I, lookupUnderlyingObject(Addr));
    assert(LocalId == LoadObjId &&
           "Load received different ID's in FED and object tables.");
    Value *CsiId = LoadFED.localToGlobalId(LocalId, IRB);
    Value *Args[] = {CsiId,
                     IRB.CreatePointerCast(Addr, IRB.getInt8PtrTy()),
                     IRB.getInt32(NumBytesAccessed),
                     Prop.getValue(IRB)};
    Instruction *Call = IRB.CreateCall(CsanRead, Args);
    IRB.SetInstDebugLocation(Call);
    NumInstrumentedReads++;
  }
  return true;
}

bool CilkSanitizerImpl::instrumentAtomic(Instruction *I, IRBuilder<> &IRB) {
  CsiLoadStoreProperty Prop;
  Value *Addr;
  if (AtomicRMWInst *RMWI = dyn_cast<AtomicRMWInst>(I)) {
    Addr = RMWI->getPointerOperand();
  } else if (AtomicCmpXchgInst *CASI = dyn_cast<AtomicCmpXchgInst>(I)) {
    Addr = CASI->getPointerOperand();
  } else {
    return false;
  }

  int NumBytesAccessed = getNumBytesAccessed(Addr, DL);
  if (-1 == NumBytesAccessed) {
    // Ignore accesses with bad sizes.
    NumAccessesWithBadSize++;
    return false;
  }

  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SHADOWMEMORY))
    return true;

  Prop.setIsAtomic(true);
  uint64_t LocalId = StoreFED.add(*I);
  uint64_t StoreObjId = StoreObj.add(*I, lookupUnderlyingObject(Addr));
  assert(LocalId == StoreObjId &&
         "Store received different ID's in FED and object tables.");
  Value *CsiId = StoreFED.localToGlobalId(LocalId, IRB);
  Value *Args[] = {CsiId,
                   IRB.CreatePointerCast(Addr, IRB.getInt8PtrTy()),
                   IRB.getInt32(NumBytesAccessed),
                   Prop.getValue(IRB)};
  Instruction *Call = IRB.CreateCall(CsanWrite, Args);
  IRB.SetInstDebugLocation(Call);
  NumInstrumentedWrites++;
  return true;
}

FunctionCallee CilkSanitizerImpl::getOrInsertSynthesizedHook(StringRef Name,
                                                             FunctionType *T,
                                                             AttributeList AL) {
  // TODO: Modify this routine to insert a call to a default library hook for
  // any call to a library function or intrinsic that the Cilksan runtime does
  // not recognize.  To do this, we may want to modify the CilkSanitizer pass
  // accept a list of hooks recognized by the Cilksan runtime, e.g., in the form
  // of a bitcode file.
  return M.getOrInsertFunction(Name, T, AL);
}

bool CilkSanitizerImpl::instrumentIntrinsicCall(
    Instruction *I, SmallVectorImpl<Value *> *MAAPVals) {
  assert(!callsPlaceholderFunction(*I) &&
         "instrumentIntrinsicCall called on placeholder function");

  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SERIESPARALLEL))
    return true;

  CallBase *CB = dyn_cast<CallBase>(I);
  if (!CB)
    return false;
  Function *Called = CB->getCalledFunction();

  IRBuilder<> IRB(I);
  LLVMContext &Ctx = IRB.getContext();
  uint64_t LocalId = CallsiteFED.add(*I);
  Value *CallsiteId = CallsiteFED.localToGlobalId(LocalId, IRB);
  Value *FuncId = GetCalleeFuncID(Called, IRB);
  assert(FuncId != NULL);

  Value *NumMVVal = IRB.getInt8(0);
  if (MAAPVals && !MAAPVals->empty()) {
    unsigned NumMV = MAAPVals->size();
    NumMVVal = IRB.getInt8(NumMV);
  }

  CsiCallProperty Prop;
  // TODO: Set appropriate property values for this intrinsic call
  Value *PropVal = Prop.getValue(IRB);

  // Since C/C++ does not like '.' characters in function names, convert '.' to
  // '_' in the hook name.
  SmallString<256> Buf;
  for (char C : Called->getName().bytes()) {
    if ('.' == C)
      Buf.push_back('_');
    else
      Buf.push_back(C);
  }

  Type *IDType = IRB.getInt64Ty();
  AttributeList FnAttrs;
  FnAttrs = FnAttrs.addAttribute(Ctx, AttributeList::FunctionIndex,
                                 Attribute::InaccessibleMemOrArgMemOnly);
  FnAttrs = FnAttrs.addAttribute(Ctx, AttributeList::FunctionIndex,
                                 Attribute::NoUnwind);

  // If the intrinsic does not return, insert the hook before the intrinsic.
  if (CB->doesNotReturn()) {
    // Synthesize the before hook for this function.
    SmallVector<Type *, 8> BeforeHookParamTys(
        {IDType, /*callee func_id*/ IDType,
         /*Num MAAPVal*/ IRB.getInt8Ty(), CsiCallProperty::getType(Ctx)});
    SmallVector<Value *, 8> BeforeHookParamVals(
        {CallsiteId, FuncId, NumMVVal, PropVal});

    // Populate the BeforeHook parameters with the parameters of the
    // instrumented function itself.
    Value *SavedStack = nullptr;
    const DataLayout &DL = M.getDataLayout();
    for (Value *Arg : CB->args()) {
      if (!Arg->getType()->isVectorTy()) {
        BeforeHookParamTys.push_back(Arg->getType());
        BeforeHookParamVals.push_back(Arg);
        continue;
      }
      // We need to deal with a vector-type argument.  Spill the vector onto the
      // stack.

      // Save the stack pointer, if we haven't already
      if (!SavedStack)
        SavedStack =
            IRB.CreateCall(Intrinsic::getDeclaration(&M, Intrinsic::stacksave));

      // Spill the vector argument onto the stack
      VectorType *VecTy = cast<VectorType>(Arg->getType());
      AllocaInst *ArgSpill = IRB.CreateAlloca(VecTy);
      IRB.CreateAlignedStore(Arg, ArgSpill, DL.getStackAlignment());

      // Add the spilled vector argument
      BeforeHookParamTys.push_back(ArgSpill->getType());
      BeforeHookParamVals.push_back(ArgSpill);
    }
    FunctionType *BeforeHookTy = FunctionType::get(
        IRB.getVoidTy(), BeforeHookParamTys, Called->isVarArg());
    FunctionCallee BeforeIntrinCallHook = getOrInsertSynthesizedHook(
        ("__csan_" + Buf).str(), BeforeHookTy, FnAttrs);

    // Insert the hook before the call
    insertHookCall(I, BeforeIntrinCallHook, BeforeHookParamVals);

    // If we previously saved the stack pointer, restore it
    if (SavedStack)
      IRB.CreateCall(Intrinsic::getDeclaration(&M, Intrinsic::stackrestore),
                     {SavedStack});
    return true;
  }

  // Otherwise, insert the hook after the intrinsic.
  assert(!isa<InvokeInst>(I) &&
         "instrumentIntrinsicCall called on invoke instruction");

  BasicBlock::iterator Iter(I);
  Iter++;
  IRB.SetInsertPoint(&*Iter);

  // Synthesize the after hook for this function.
  SmallVector<Type *, 8> AfterHookParamTys({IDType, /*callee func_id*/ IDType,
                                            /*Num MAAPVal*/ IRB.getInt8Ty(),
                                            CsiCallProperty::getType(Ctx)});
  SmallVector<Value *, 8> AfterHookParamVals(
      {CallsiteId, FuncId, NumMVVal, PropVal});

  // Populate the AfterHook parameters with the parameters of the instrumented
  // function itself.
  Value *SavedStack = nullptr;
  const DataLayout &DL = M.getDataLayout();
  if (!Called->getReturnType()->isVoidTy()) {
    if (!Called->getReturnType()->isVectorTy()) {
      AfterHookParamTys.push_back(Called->getReturnType());
      AfterHookParamVals.push_back(CB);
    } else {
      // We need to deal with a vector-type return value.  Spill the vector onto
      // the stack.

      // Save the stack pointer, if we haven't already
      if (!SavedStack)
        SavedStack =
            IRB.CreateCall(Intrinsic::getDeclaration(&M, Intrinsic::stacksave));

      // Spill the vector return value onto the stack
      VectorType *VecTy = cast<VectorType>(Called->getReturnType());
      AllocaInst *RetSpill = IRB.CreateAlloca(VecTy);
      IRB.CreateAlignedStore(CB, RetSpill, DL.getStackAlignment());

      // Add the spilled vector return value
      AfterHookParamTys.push_back(RetSpill->getType());
      AfterHookParamVals.push_back(RetSpill);
    }
  }
  for (Value *Arg : CB->args()) {
    if (!Arg->getType()->isVectorTy()) {
      AfterHookParamTys.push_back(Arg->getType());
      AfterHookParamVals.push_back(Arg);
      continue;
    }
    // We need to deal with a vector-type argument.  Spill the vector onto the
    // stack.

    // Save the stack pointer, if we haven't already
    if (!SavedStack)
      SavedStack =
          IRB.CreateCall(Intrinsic::getDeclaration(&M, Intrinsic::stacksave));

    // Spill the vector argument onto the stack
    VectorType *VecTy = cast<VectorType>(Arg->getType());
    AllocaInst *ArgSpill = IRB.CreateAlloca(VecTy);
    IRB.CreateAlignedStore(Arg, ArgSpill, DL.getStackAlignment());

    // Add the spolled vector argument
    AfterHookParamTys.push_back(ArgSpill->getType());
    AfterHookParamVals.push_back(ArgSpill);
  }
  FunctionType *AfterHookTy =
      FunctionType::get(IRB.getVoidTy(), AfterHookParamTys, Called->isVarArg());
  FunctionCallee AfterIntrinCallHook =
      getOrInsertSynthesizedHook(("__csan_" + Buf).str(), AfterHookTy, FnAttrs);

  // Insert the hook call
  insertHookCall(&*Iter, AfterIntrinCallHook, AfterHookParamVals);

  if (SavedStack) {
    IRB.CreateCall(Intrinsic::getDeclaration(&M, Intrinsic::stackrestore),
                   {SavedStack});
  }
  return true;
}

bool CilkSanitizerImpl::instrumentLibCall(Instruction *I,
                                          SmallVectorImpl<Value *> *MAAPVals) {
  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SERIESPARALLEL))
    return true;

  bool IsInvoke = isa<InvokeInst>(I);
  CallBase *CB = dyn_cast<CallBase>(I);
  if (!CB)
    return false;
  Function *Called = CB->getCalledFunction();

  IRBuilder<> IRB(I);
  LLVMContext &Ctx = IRB.getContext();
  uint64_t LocalId = CallsiteFED.add(*I);
  Value *DefaultID = getDefaultID(IRB);
  Value *CallsiteId = CallsiteFED.localToGlobalId(LocalId, IRB);
  Value *FuncId = GetCalleeFuncID(Called, IRB);
  assert(FuncId != NULL);

  Value *NumMVVal = IRB.getInt8(0);
  if (MAAPVals && !MAAPVals->empty()) {
    unsigned NumMV = MAAPVals->size();
    NumMVVal = IRB.getInt8(NumMV);
  }

  CsiCallProperty Prop;
  Value *DefaultPropVal = Prop.getValue(IRB);
  // TODO: Set appropriate property values for this intrinsic call
  Value *PropVal = Prop.getValue(IRB);

  Type *IDType = IRB.getInt64Ty();
  AttributeList FnAttrs;
  FnAttrs = FnAttrs.addAttribute(Ctx, AttributeList::FunctionIndex,
                                 Attribute::InaccessibleMemOrArgMemOnly);
  FnAttrs = FnAttrs.addAttribute(Ctx, AttributeList::FunctionIndex,
                                 Attribute::NoUnwind);

  // If the intrinsic does not return, insert the hook before the intrinsic.
  if (CB->doesNotReturn()) {
    // Synthesize the before hook for this function.
    SmallVector<Type *, 8> BeforeHookParamTys(
        {IDType, /*callee func_id*/ IDType,
         /*MAAP_count*/ IRB.getInt8Ty(), CsiCallProperty::getType(Ctx)});
    SmallVector<Value *, 8> BeforeHookParamVals(
        {CallsiteId, FuncId, NumMVVal, PropVal});
    BeforeHookParamTys.append(Called->getFunctionType()->param_begin(),
                              Called->getFunctionType()->param_end());
    BeforeHookParamVals.append(CB->arg_begin(), CB->arg_end());
    FunctionType *BeforeHookTy = FunctionType::get(
        IRB.getVoidTy(), BeforeHookParamTys, Called->isVarArg());
    FunctionCallee BeforeLibCallHook = getOrInsertSynthesizedHook(
        ("__csan_" + Called->getName()).str(), BeforeHookTy, FnAttrs);

    insertHookCall(I, BeforeLibCallHook, BeforeHookParamVals);
    return true;
  }

  // Otherwise, insert the hook after the intrinsic.

  // Synthesize the after hook for this function.
  SmallVector<Type *, 8> AfterHookParamTys(
      {IDType, /*callee func_id*/ IDType,
       /*Num MAAPVal*/ IRB.getInt8Ty(), CsiCallProperty::getType(Ctx)});
  SmallVector<Value *, 8> AfterHookParamVals(
      {CallsiteId, FuncId, NumMVVal, PropVal});
  SmallVector<Value *, 8> AfterHookDefaultVals(
      {DefaultID, DefaultID, IRB.getInt8(0), DefaultPropVal});
  if (!Called->getReturnType()->isVoidTy()) {
    AfterHookParamTys.push_back(Called->getReturnType());
    AfterHookParamVals.push_back(CB);
    AfterHookDefaultVals.push_back(
        Constant::getNullValue(Called->getReturnType()));
  }
  AfterHookParamTys.append(Called->getFunctionType()->param_begin(),
                           Called->getFunctionType()->param_end());
  AfterHookParamVals.append(CB->arg_begin(), CB->arg_end());
  for (Value *Arg : CB->args())
    AfterHookDefaultVals.push_back(Constant::getNullValue(Arg->getType()));
  FunctionType *AfterHookTy =
      FunctionType::get(IRB.getVoidTy(), AfterHookParamTys, Called->isVarArg());
  FunctionCallee AfterLibCallHook = getOrInsertSynthesizedHook(
      ("__csan_" + Called->getName()).str(), AfterHookTy, FnAttrs);

  BasicBlock::iterator Iter(I);
  if (IsInvoke) {
    // There are two "after" positions for invokes: the normal block and the
    // exception block.
    InvokeInst *II = cast<InvokeInst>(I);
    insertHookCallInSuccessorBB(
        II->getNormalDest(), II->getParent(), AfterLibCallHook,
        AfterHookParamVals, AfterHookDefaultVals);
    // Don't insert any instrumentation in the exception block.
  } else {
    // Simple call instruction; there is only one "after" position.
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    insertHookCall(&*Iter, AfterLibCallHook, AfterHookParamVals);
  }

  return true;
}

bool CilkSanitizerImpl::instrumentCallsite(Instruction *I,
                                           SmallVectorImpl<Value *> *MAAPVals) {
  if (callsPlaceholderFunction(*I))
    return false;

  bool IsInvoke = isa<InvokeInst>(I);
  CallBase *CB = dyn_cast<CallBase>(I);
  if (!CB)
    return false;
  Function *Called = CB->getCalledFunction();

  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SERIESPARALLEL))
    return true;

  IRBuilder<> IRB(I);
  uint64_t LocalId = CallsiteFED.add(*I);
  Value *DefaultID = getDefaultID(IRB);
  Value *CallsiteId = CallsiteFED.localToGlobalId(LocalId, IRB);
  Value *FuncId = GetCalleeFuncID(Called, IRB);
  // GlobalVariable *FuncIdGV = NULL;
  // if (Called) {
  //   std::string GVName =
  //     CsiFuncIdVariablePrefix + Called->getName().str();
  //   FuncIdGV = dyn_cast<GlobalVariable>(M.getOrInsertGlobal(GVName,
  //                                                           IRB.getInt64Ty()));
  //   assert(FuncIdGV);
  //   FuncIdGV->setConstant(false);
  //   if (Options.jitMode && !Called->empty())
  //     FuncIdGV->setLinkage(Called->getLinkage());
  //   else
  //     FuncIdGV->setLinkage(GlobalValue::WeakAnyLinkage);
  //   FuncIdGV->setInitializer(IRB.getInt64(CsiCallsiteUnknownTargetId));
  //   FuncId = IRB.CreateLoad(FuncIdGV);
  // } else {
  //   // Unknown targets (i.e. indirect calls) are always unknown.
  //   FuncId = IRB.getInt64(CsiCallsiteUnknownTargetId);
  // }
  assert(FuncId != NULL);

  Value *NumMVVal = IRB.getInt8(0);
  if (MAAPVals && !MAAPVals->empty()) {
    unsigned NumMV = MAAPVals->size();
    NumMVVal = IRB.getInt8(NumMV);
  }

  CsiCallProperty Prop;
  Value *DefaultPropVal = Prop.getValue(IRB);
  Prop.setIsIndirect(!Called);
  Value *PropVal = Prop.getValue(IRB);
  insertHookCall(I, CsanBeforeCallsite, {CallsiteId, FuncId, NumMVVal,
                                         PropVal});

  // Don't bother adding after_call instrumentation for function calls that
  // don't return.
  if (CB->doesNotReturn())
    return true;

  BasicBlock::iterator Iter(I);
  if (IsInvoke) {
    // There are two "after" positions for invokes: the normal block and the
    // exception block.
    InvokeInst *II = cast<InvokeInst>(I);
    insertHookCallInSuccessorBB(
        II->getNormalDest(), II->getParent(), CsanAfterCallsite,
        {CallsiteId, FuncId, NumMVVal, PropVal},
        {DefaultID, DefaultID, IRB.getInt8(0), DefaultPropVal});
    insertHookCallInSuccessorBB(
        II->getUnwindDest(), II->getParent(), CsanAfterCallsite,
        {CallsiteId, FuncId, NumMVVal, PropVal},
        {DefaultID, DefaultID, IRB.getInt8(0), DefaultPropVal});
  } else {
    // Simple call instruction; there is only one "after" position.
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    PropVal = Prop.getValue(IRB);
    insertHookCall(&*Iter, CsanAfterCallsite,
                   {CallsiteId, FuncId, NumMVVal, PropVal});
  }

  return true;
}

bool CilkSanitizerImpl::suppressCallsite(Instruction *I) {
  if (callsPlaceholderFunction(*I))
    return false;

  bool IsInvoke = isa<InvokeInst>(I);

  IRBuilder<> IRB(I);
  insertHookCall(I, CsanDisableChecking, {});

  BasicBlock::iterator Iter(I);
  if (IsInvoke) {
    // There are two "after" positions for invokes: the normal block and the
    // exception block.
    InvokeInst *II = cast<InvokeInst>(I);
    insertHookCallInSuccessorBB(
        II->getNormalDest(), II->getParent(), CsanEnableChecking, {}, {});
    insertHookCallInSuccessorBB(
        II->getUnwindDest(), II->getParent(), CsanEnableChecking, {}, {});
  } else {
    // Simple call instruction; there is only one "after" position.
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    insertHookCall(&*Iter, CsanEnableChecking, {});
  }

  return true;
}

static bool IsMemTransferDstOperand(unsigned OperandNum) {
  // This check should be kept in sync with TapirRaceDetect::GetGeneralAccesses.
  return (OperandNum == 0);
}

static bool IsMemTransferSrcOperand(unsigned OperandNum) {
  // This check should be kept in sync with TapirRaceDetect::GetGeneralAccesses.
  return (OperandNum == 1);
}

bool CilkSanitizerImpl::instrumentAnyMemIntrinAcc(Instruction *I,
                                                  unsigned OperandNum,
                                                  IRBuilder<> &IRB) {
  CsiLoadStoreProperty Prop;
  if (AnyMemTransferInst *M = dyn_cast<AnyMemTransferInst>(I)) {
    // Only instrument the large load and the large store components as
    // necessary.
    bool Instrumented = false;

    if (IsMemTransferDstOperand(OperandNum)) {
      // Only insert instrumentation if requested
      if (!(InstrumentationSet & SHADOWMEMORY))
        return true;

      Value *Addr = M->getDest();
      Prop.setAlignment(M->getDestAlignment());
      // Instrument the store
      uint64_t StoreId = StoreFED.add(*I);

      // TODO: Don't recalculate underlying objects
      uint64_t StoreObjId = StoreObj.add(*I, lookupUnderlyingObject(Addr));
      assert(StoreId == StoreObjId &&
             "Store received different ID's in FED and object tables.");

      Value *CsiId = StoreFED.localToGlobalId(StoreId, IRB);
      Value *Args[] = {CsiId, IRB.CreatePointerCast(Addr, IRB.getInt8PtrTy()),
                       IRB.CreateIntCast(M->getLength(), IntptrTy, false),
                       Prop.getValue(IRB)};
      Instruction *Call = IRB.CreateCall(CsanLargeWrite, Args);
      IRB.SetInstDebugLocation(Call);
      ++NumInstrumentedMemIntrinsicWrites;
      Instrumented = true;
    }

    if (IsMemTransferSrcOperand(OperandNum)) {
      // Only insert instrumentation if requested
      if (!(InstrumentationSet & SHADOWMEMORY))
        return true;

      Value *Addr = M->getSource();
      Prop.setAlignment(M->getSourceAlignment());
      // Instrument the load
      uint64_t LoadId = LoadFED.add(*I);

      // TODO: Don't recalculate underlying objects
      uint64_t LoadObjId = LoadObj.add(*I, lookupUnderlyingObject(Addr));
      assert(LoadId == LoadObjId &&
             "Load received different ID's in FED and object tables.");

      Value *CsiId = LoadFED.localToGlobalId(LoadId, IRB);
      Value *Args[] = {CsiId, IRB.CreatePointerCast(Addr, IRB.getInt8PtrTy()),
                       IRB.CreateIntCast(M->getLength(), IntptrTy, false),
                       Prop.getValue(IRB)};
      Instruction *Call = IRB.CreateCall(CsanLargeRead, Args);
      IRB.SetInstDebugLocation(Call);
      ++NumInstrumentedMemIntrinsicReads;
      Instrumented = true;
    }
    return Instrumented;
  } else if (AnyMemIntrinsic *M = dyn_cast<AnyMemIntrinsic>(I)) {
    // Only insert instrumentation if requested
    if (!(InstrumentationSet & SHADOWMEMORY))
      return true;

    Value *Addr = M->getDest();
    Prop.setAlignment(M->getDestAlignment());
    uint64_t LocalId = StoreFED.add(*I);

    // TODO: Don't recalculate underlying objects
    uint64_t StoreObjId = StoreObj.add(*I, lookupUnderlyingObject(Addr));
    assert(LocalId == StoreObjId &&
           "Store received different ID's in FED and object tables.");

    Value *CsiId = StoreFED.localToGlobalId(LocalId, IRB);
    Value *Args[] = {CsiId, IRB.CreatePointerCast(Addr, IRB.getInt8PtrTy()),
                     IRB.CreateIntCast(M->getLength(), IntptrTy, false),
                     Prop.getValue(IRB)};
    Instruction *Call = IRB.CreateCall(CsanLargeWrite, Args);
    IRB.SetInstDebugLocation(Call);
    ++NumInstrumentedMemIntrinsicWrites;
    return true;
  }
  return false;
}

static void getTaskExits(
    DetachInst *DI, SmallVectorImpl<BasicBlock *> &TaskReturns,
    SmallVectorImpl<BasicBlock *> &TaskResumes,
    SmallVectorImpl<Spindle *> &SharedEHExits,
    TaskInfo &TI) {
  BasicBlock *DetachedBlock = DI->getDetached();
  Task *T = TI.getTaskFor(DetachedBlock);
  BasicBlock *ContinueBlock = DI->getContinue();

  // Examine the predecessors of the continue block and save any predecessors in
  // the task as a task return.
  for (BasicBlock *Pred : predecessors(ContinueBlock)) {
    if (T->simplyEncloses(Pred)) {
      assert(isa<ReattachInst>(Pred->getTerminator()));
      TaskReturns.push_back(Pred);
    }
  }

  // If the detach cannot throw, we're done.
  if (!DI->hasUnwindDest())
    return;

  // Detached-rethrow exits can appear in strange places within a task-exiting
  // spindle.  Hence we loop over all blocks in the spindle to find
  // detached rethrows.
  for (Spindle *S : depth_first<InTask<Spindle *>>(T->getEntrySpindle())) {
    if (S->isSharedEH()) {
      if (llvm::any_of(predecessors(S),
                       [](const Spindle *Pred){ return !Pred->isSharedEH(); }))
        SharedEHExits.push_back(S);
      continue;
    }

    for (BasicBlock *B : S->blocks())
      if (isDetachedRethrow(B->getTerminator()))
        TaskResumes.push_back(B);
  }
}

bool CilkSanitizerImpl::instrumentDetach(DetachInst *DI, unsigned SyncRegNum,
                                         unsigned NumSyncRegs,
                                         DominatorTree *DT, TaskInfo &TI,
                                         LoopInfo &LI) {
  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SERIESPARALLEL))
    return true;

  BasicBlock *TaskEntryBlock = TI.getTaskFor(DI->getParent())->getEntry();
  IRBuilder<> IDBuilder(&*TaskEntryBlock->getFirstInsertionPt());
  bool TapirLoopBody = spawnsTapirLoopBody(DI, LI, TI);
  // Instrument the detach instruction itself
  Value *DetachID;
  {
    IRBuilder<> IRB(DI);
    uint64_t LocalID = DetachFED.add(*DI);
    DetachID = DetachFED.localToGlobalId(LocalID, IDBuilder);
    Instruction *Call = IRB.CreateCall(CsanDetach, {DetachID,
                                                    IRB.getInt8(SyncRegNum)});
    IRB.SetInstDebugLocation(Call);
  }
  NumInstrumentedDetaches++;

  // Find the detached block, continuation, and associated reattaches.
  BasicBlock *DetachedBlock = DI->getDetached();
  BasicBlock *ContinueBlock = DI->getContinue();
  Task *T = TI.getTaskFor(DetachedBlock);
  SmallVector<BasicBlock *, 8> TaskExits, TaskResumes;
  SmallVector<Spindle *, 2> SharedEHExits;
  getTaskExits(DI, TaskExits, TaskResumes, SharedEHExits, TI);

  // Instrument the entry and exit points of the detached task.
  {
    // Instrument the entry point of the detached task.
    IRBuilder<> IRB(&*getFirstInsertionPtInDetachedBlock(DetachedBlock));
    uint64_t LocalID = TaskFED.add(*DetachedBlock);
    Value *TaskID = TaskFED.localToGlobalId(LocalID, IDBuilder);
    CsiTaskProperty Prop;
    Prop.setIsTapirLoopBody(TapirLoopBody);
    Prop.setNumSyncReg(NumSyncRegs);
    // Get the frame and stack pointers.
    Value *FrameAddr = IRB.CreateCall(
        Intrinsic::getDeclaration(&M, Intrinsic::task_frameaddress),
        {IRB.getInt32(0)});
    Value *StackSave = IRB.CreateCall(
        Intrinsic::getDeclaration(&M, Intrinsic::stacksave));
    Instruction *Call = IRB.CreateCall(CsanTaskEntry,
                                       {TaskID, DetachID, FrameAddr,
                                        StackSave, Prop.getValue(IRB)});
    IRB.SetInstDebugLocation(Call);

    // Instrument the exit points of the detached tasks.
    for (BasicBlock *TaskExit : TaskExits) {
      IRBuilder<> IRB(TaskExit->getTerminator());
      uint64_t LocalID = TaskExitFED.add(*TaskExit->getTerminator());
      Value *TaskExitID = TaskExitFED.localToGlobalId(LocalID, IDBuilder);
      CsiTaskExitProperty ExitProp;
      ExitProp.setIsTapirLoopBody(TapirLoopBody);
      Instruction *Call = IRB.CreateCall(
          CsanTaskExit, {TaskExitID, TaskID, DetachID, IRB.getInt8(SyncRegNum),
                         ExitProp.getValue(IRB)});
      IRB.SetInstDebugLocation(Call);
      NumInstrumentedDetachExits++;
    }
    // Instrument the EH exits of the detached task.
    for (BasicBlock *TaskExit : TaskResumes) {
      IRBuilder<> IRB(TaskExit->getTerminator());
      uint64_t LocalID = TaskExitFED.add(*TaskExit->getTerminator());
      Value *TaskExitID = TaskExitFED.localToGlobalId(LocalID, IDBuilder);
      CsiTaskExitProperty ExitProp;
      ExitProp.setIsTapirLoopBody(TapirLoopBody);
      Instruction *Call = IRB.CreateCall(
          CsanTaskExit, {TaskExitID, TaskID, DetachID, IRB.getInt8(SyncRegNum),
                         ExitProp.getValue(IRB)});
      IRB.SetInstDebugLocation(Call);
      NumInstrumentedDetachExits++;
    }

    Value *DefaultID = getDefaultID(IDBuilder);
    for (Spindle *SharedEH : SharedEHExits) {
      CsiTaskExitProperty ExitProp;
      ExitProp.setIsTapirLoopBody(TapirLoopBody);
      insertHookCallAtSharedEHSpindleExits(
          SharedEH, T, CsanTaskExit, TaskExitFED,
          {TaskID, DetachID, IRB.getInt8(SyncRegNum),
           ExitProp.getValueImpl(DI->getContext())},
          {DefaultID, DefaultID, IRB.getInt8(0),
           CsiTaskExitProperty::getDefaultValueImpl(DI->getContext())});
    }
  }

  // Instrument the continuation of the detach.
  {
    if (isCriticalContinueEdge(DI, 1))
      ContinueBlock = SplitCriticalEdge(
          DI, 1,
          CriticalEdgeSplittingOptions(DT, &LI).setSplitDetachContinue());

    IRBuilder<> IRB(&*ContinueBlock->getFirstInsertionPt());
    uint64_t LocalID = DetachContinueFED.add(*ContinueBlock);
    Value *ContinueID = DetachContinueFED.localToGlobalId(LocalID, IDBuilder);
    Instruction *Call = IRB.CreateCall(CsanDetachContinue,
                                       {ContinueID, DetachID});
    IRB.SetInstDebugLocation(Call);
  }
  // Instrument the unwind of the detach, if it exists.
  if (DI->hasUnwindDest()) {
    BasicBlock *UnwindBlock = DI->getUnwindDest();
    BasicBlock *PredBlock = DI->getParent();
    if (Value *TF = T->getTaskFrameUsed()) {
      // If the detached task uses a taskframe, then we want to insert the
      // detach_continue instrumentation for the unwind destination after the
      // taskframe.resume.
      UnwindBlock = getTaskFrameResumeDest(TF);
      assert(UnwindBlock &&
             "Detach with unwind uses a taskframe with no resume");
      PredBlock = getTaskFrameResume(TF)->getParent();
    }
    Value *DefaultID = getDefaultID(IDBuilder);
    uint64_t LocalID = DetachContinueFED.add(*UnwindBlock);
    Value *ContinueID = DetachContinueFED.localToGlobalId(LocalID, IDBuilder);
    insertHookCallInSuccessorBB(UnwindBlock, PredBlock,
                                CsanDetachContinue, {ContinueID, DetachID},
                                {DefaultID, DefaultID});
    for (BasicBlock *DRPred : predecessors(UnwindBlock))
      if (isDetachedRethrow(DRPred->getTerminator(), DI->getSyncRegion()))
        insertHookCallInSuccessorBB(UnwindBlock, DRPred, CsanDetachContinue,
                                    {ContinueID, DetachID},
                                    {DefaultID, DefaultID});
  }
  return true;
}

bool CilkSanitizerImpl::instrumentSync(SyncInst *SI, unsigned SyncRegNum) {
  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SERIESPARALLEL))
    return true;

  IRBuilder<> IRB(SI);
  // Get the ID of this sync.
  uint64_t LocalID = SyncFED.add(*SI);
  Value *SyncID = SyncFED.localToGlobalId(LocalID, IRB);
  // Insert instrumentation before the sync.
  insertHookCall(SI, CsanSync, {SyncID, IRB.getInt8(SyncRegNum)});
  NumInstrumentedSyncs++;
  return true;
}


void CilkSanitizerImpl::instrumentTapirLoop(Loop &L, TaskInfo &TI,
                                       DenseMap<Value *, unsigned> &SyncRegNums,
                                       ScalarEvolution *SE) {
  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SERIESPARALLEL))
    return;

  assert(L.isLoopSimplifyForm() && "CSI assumes loops are in simplified form.");
  BasicBlock *Preheader = L.getLoopPreheader();
  Task *T = getTaskIfTapirLoop(&L, &TI);
  assert(T && "CilkSanitizer should only instrument Tapir loops.");
  unsigned SyncRegNum = SyncRegNums[T->getDetach()->getSyncRegion()];
  // We assign a local ID for this loop here, so that IDs for loops follow a
  // depth-first ordering.
  // csi_id_t LocalId = LoopFED.add(*Header);
  csi_id_t LocalId = LoopFED.add(*T->getDetach());

  SmallVector<BasicBlock *, 4> ExitingBlocks;
  L.getExitingBlocks(ExitingBlocks);
  SmallVector<BasicBlock *, 4> ExitBlocks;
  L.getUniqueExitBlocks(ExitBlocks);

  // Record properties of this loop.
  CsiLoopProperty LoopProp;
  LoopProp.setIsTapirLoop(static_cast<bool>(getTaskIfTapirLoop(&L, &TI)));
  LoopProp.setHasUniqueExitingBlock((ExitingBlocks.size() == 1));

  IRBuilder<> IRB(Preheader->getTerminator());
  Value *LoopCsiId = LoopFED.localToGlobalId(LocalId, IRB);
  Value *LoopPropVal = LoopProp.getValue(IRB);

  // Try to evaluate the runtime trip count for this loop.  Default to a count
  // of -1 for unknown trip counts.
  Value *TripCount = IRB.getInt64(-1);
  if (SE) {
    const SCEV *TripCountSC = getRuntimeTripCount(L, SE, true);
    if (!isa<SCEVCouldNotCompute>(TripCountSC)) {
      // Extend the TripCount type if necessary.
      if (TripCountSC->getType() != IRB.getInt64Ty())
        TripCountSC = SE->getZeroExtendExpr(TripCountSC, IRB.getInt64Ty());
      // Compute the trip count to pass to the CSI hook.
      SCEVExpander Expander(*SE, DL, "csi");
      TripCount = Expander.expandCodeFor(TripCountSC, IRB.getInt64Ty(),
                                         &*IRB.GetInsertPoint());
    }
  }

  // Insert before-loop hook.
  insertHookCall(&*IRB.GetInsertPoint(), CsanBeforeLoop, {LoopCsiId, TripCount,
                                                          LoopPropVal});

  // // Insert loop-body-entry hook.
  // IRB.SetInsertPoint(&*Header->getFirstInsertionPt());
  // // TODO: Pass IVs to hook?
  // insertHookCall(&*IRB.GetInsertPoint(), CsiLoopBodyEntry, {LoopCsiId,
  //                                                           LoopPropVal});

  // // Insert hooks at the ends of the exiting blocks.
  // for (BasicBlock *BB : ExitingBlocks) {
  //   // Record properties of this loop exit
  //   CsiLoopExitProperty LoopExitProp;
  //   LoopExitProp.setIsLatch(L.isLoopLatch(BB));

  //   // Insert the loop-exit hook
  //   IRB.SetInsertPoint(BB->getTerminator());
  //   csi_id_t LocalExitId = LoopExitFED.add(*BB);
  //   Value *ExitCsiId = LoopFED.localToGlobalId(LocalExitId, IRB);
  //   Value *LoopExitPropVal = LoopExitProp.getValue(IRB);
  //   // TODO: For latches, record whether the loop will repeat.
  //   insertHookCall(&*IRB.GetInsertPoint(), CsiLoopBodyExit,
  //                  {ExitCsiId, LoopCsiId, LoopExitPropVal});
  // }

  // Insert after-loop hooks.
  for (BasicBlock *BB : ExitBlocks) {
    // If the exit block is simply enclosed inside the task, then its on an
    // exceptional exit path from the task.  In that case, the exit path will
    // reach the unwind destination of the detach.  Because the unwind
    // destination of the detach is in the set of exit blocks, we can safely
    // skip any exit blocks enclosed in the task.
    if (!T->encloses(BB)) {
      IRB.SetInsertPoint(&*BB->getFirstInsertionPt());
      insertHookCall(&*IRB.GetInsertPoint(), CsanAfterLoop,
                     {LoopCsiId, IRB.getInt8(SyncRegNum), LoopPropVal});
    }
  }
}

bool CilkSanitizerImpl::instrumentAlloca(Instruction *I) {
  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SHADOWMEMORY))
    return true;

  IRBuilder<> IRB(I);
  AllocaInst* AI = cast<AllocaInst>(I);

  uint64_t LocalId = AllocaFED.add(*I);
  Value *CsiId = AllocaFED.localToGlobalId(LocalId, IRB);
  uint64_t AllocaObjId = AllocaObj.add(*I, I);
  assert(LocalId == AllocaObjId &&
         "Alloca received different ID's in FED and object tables.");

  CsiAllocaProperty Prop;
  Prop.setIsStatic(AI->isStaticAlloca());
  Value *PropVal = Prop.getValue(IRB);

  // Get size of allocation.
  uint64_t Size = DL.getTypeAllocSize(AI->getAllocatedType());
  Value *SizeVal = IRB.getInt64(Size);
  if (AI->isArrayAllocation())
    SizeVal = IRB.CreateMul(SizeVal,
                            IRB.CreateZExtOrBitCast(AI->getArraySize(),
                                                    IRB.getInt64Ty()));

  BasicBlock::iterator Iter(I);
  Iter++;
  IRB.SetInsertPoint(&*Iter);

  Type *AddrType = IRB.getInt8PtrTy();
  Value *Addr = IRB.CreatePointerCast(I, AddrType);
  insertHookCall(&*Iter, CsiAfterAlloca, {CsiId, Addr, SizeVal, PropVal});

  NumInstrumentedAllocas++;
  return true;
}

static Value *getHeapObject(Value *I) {
  Value *Object = nullptr;
  unsigned NumOfBitCastUses = 0;

  // Determine if CallInst has a bitcast use.
  for (Value::user_iterator UI = I->user_begin(), E = I->user_end();
       UI != E;)
    if (BitCastInst *BCI = dyn_cast<BitCastInst>(*UI++)) {
      // Look for a dbg.value intrinsic for this bitcast.
      SmallVector<DbgValueInst *, 1> DbgValues;
      findDbgValues(DbgValues, BCI);
      if (!DbgValues.empty()) {
        Object = BCI;
        NumOfBitCastUses++;
      }
    }

  // Heap-allocation call has 1 debug-bitcast use, so use that bitcast as the
  // object.
  if (NumOfBitCastUses == 1)
    return Object;

  // Otherwise just use the heap-allocation call directly.
  return I;
}

bool CilkSanitizerImpl::getAllocFnArgs(
    const Instruction *I, SmallVectorImpl<Value*> &AllocFnArgs,
    Type *SizeTy, Type *AddrTy, const TargetLibraryInfo &TLI) {
  const Function *Called = dyn_cast<CallBase>(I)->getCalledFunction();;

  LibFunc F;
  bool FoundLibFunc = TLI.getLibFunc(*Called, F);
  if (!FoundLibFunc)
    return false;

  switch(F) {
  default: return false;
    // TODO: Add aligned new's to this list after they're added to TLI.
  case LibFunc_malloc:
  case LibFunc_valloc:
  case LibFunc_Znwj:
  case LibFunc_ZnwjRKSt9nothrow_t:
  case LibFunc_Znwm:
  case LibFunc_ZnwmRKSt9nothrow_t:
  case LibFunc_Znaj:
  case LibFunc_ZnajRKSt9nothrow_t:
  case LibFunc_Znam:
  case LibFunc_ZnamRKSt9nothrow_t:
  case LibFunc_msvc_new_int:
  case LibFunc_msvc_new_int_nothrow:
  case LibFunc_msvc_new_longlong:
  case LibFunc_msvc_new_longlong_nothrow:
  case LibFunc_msvc_new_array_int:
  case LibFunc_msvc_new_array_int_nothrow:
  case LibFunc_msvc_new_array_longlong:
  case LibFunc_msvc_new_array_longlong_nothrow:
    {
      // Allocated size
      if (isa<CallInst>(I))
        AllocFnArgs.push_back(cast<CallInst>(I)->getArgOperand(0));
      else
        AllocFnArgs.push_back(cast<InvokeInst>(I)->getArgOperand(0));
      // Number of elements = 1
      AllocFnArgs.push_back(ConstantInt::get(SizeTy, 1));
      // Alignment = 0
      // TODO: Fix this for aligned new's, once they're added to TLI.
      AllocFnArgs.push_back(ConstantInt::get(SizeTy, 0));
      // Old pointer = NULL
      AllocFnArgs.push_back(Constant::getNullValue(AddrTy));
      return true;
    }
  case LibFunc_ZnwjSt11align_val_t:
  case LibFunc_ZnwmSt11align_val_t:
  case LibFunc_ZnajSt11align_val_t:
  case LibFunc_ZnamSt11align_val_t:
  case LibFunc_ZnwjSt11align_val_tRKSt9nothrow_t:
  case LibFunc_ZnwmSt11align_val_tRKSt9nothrow_t:
  case LibFunc_ZnajSt11align_val_tRKSt9nothrow_t:
  case LibFunc_ZnamSt11align_val_tRKSt9nothrow_t: {
    if (const CallInst *CI = dyn_cast<CallInst>(I)) {
      AllocFnArgs.push_back(CI->getArgOperand(0));
      // Number of elements = 1
      AllocFnArgs.push_back(ConstantInt::get(SizeTy, 1));
      // Alignment
      AllocFnArgs.push_back(CI->getArgOperand(1));
      // Old pointer = NULL
      AllocFnArgs.push_back(Constant::getNullValue(AddrTy));
    } else {
      const InvokeInst *II = cast<InvokeInst>(I);
      AllocFnArgs.push_back(II->getArgOperand(0));
      // Number of elements = 1
      AllocFnArgs.push_back(ConstantInt::get(SizeTy, 1));
      // Alignment
      AllocFnArgs.push_back(II->getArgOperand(1));
      // Old pointer = NULL
      AllocFnArgs.push_back(Constant::getNullValue(AddrTy));
    }
    return true;
  }
  case LibFunc_calloc:
    {
      const CallInst *CI = cast<CallInst>(I);
      // Allocated size
      AllocFnArgs.push_back(CI->getArgOperand(1));
      // Number of elements
      AllocFnArgs.push_back(CI->getArgOperand(0));
      // Alignment = 0
      AllocFnArgs.push_back(ConstantInt::get(SizeTy, 0));
      // Old pointer = NULL
      AllocFnArgs.push_back(Constant::getNullValue(AddrTy));
      return true;
    }
  case LibFunc_realloc:
  case LibFunc_reallocf:
    {
      const CallInst *CI = cast<CallInst>(I);
      // Allocated size
      AllocFnArgs.push_back(CI->getArgOperand(1));
      // Number of elements = 1
      AllocFnArgs.push_back(ConstantInt::get(SizeTy, 1));
      // Alignment = 0
      AllocFnArgs.push_back(ConstantInt::get(SizeTy, 0));
      // Old pointer
      AllocFnArgs.push_back(CI->getArgOperand(0));
      return true;
    }
  case LibFunc_aligned_alloc:
    {
      const CallInst *CI = cast<CallInst>(I);
      // Allocated size
      AllocFnArgs.push_back(CI->getArgOperand(1));
      // Number of elements = 1
      AllocFnArgs.push_back(ConstantInt::get(SizeTy, 1));
      // Alignment
      AllocFnArgs.push_back(CI->getArgOperand(0));
      // Old pointer = NULL
      AllocFnArgs.push_back(Constant::getNullValue(AddrTy));
      return true;
    }
  }
}

bool CilkSanitizerImpl::instrumentAllocFnLibCall(Instruction *I,
                                                 const TargetLibraryInfo *TLI) {
  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SHADOWMEMORY))
    return true;

  bool IsInvoke = isa<InvokeInst>(I);
  CallBase *CB = dyn_cast<CallBase>(I);
  if (!CB)
    return false;
  Function *Called = CB->getCalledFunction();

  // Get the CSI IDs for this hook
  IRBuilder<> IRB(I);
  LLVMContext &Ctx = IRB.getContext();
  Value *DefaultID = getDefaultID(IRB);
  uint64_t LocalId = AllocFnFED.add(*I);
  Value *AllocFnId = AllocFnFED.localToGlobalId(LocalId, IRB);
  Value *FuncId = GetCalleeFuncID(Called, IRB);
  assert(FuncId != NULL);

  // Get the ID for the corresponding heap object
  Value *HeapObj = nullptr;
  if ("posix_memalign" == Called->getName())
    HeapObj = getHeapObject(CB->getArgOperand(0));
  else
    HeapObj = getHeapObject(I);
  uint64_t AllocFnObjId = AllocFnObj.add(*I, HeapObj);
  assert(LocalId == AllocFnObjId &&
         "Allocation fn received different ID's in FED and object tables.");

  // TODO: Propagate MAAPs to allocation-function library calls
  Value *NumMVVal = IRB.getInt8(0);

  CsiAllocFnProperty Prop;
  Value *DefaultPropVal = Prop.getValue(IRB);
  LibFunc AllocLibF;
  TLI->getLibFunc(*Called, AllocLibF);
  Prop.setAllocFnTy(static_cast<unsigned>(getAllocFnTy(AllocLibF)));
  Value *PropVal = Prop.getValue(IRB);

  Type *IDType = IRB.getInt64Ty();
  AttributeList FnAttrs;
  FnAttrs = FnAttrs.addAttribute(Ctx, AttributeList::FunctionIndex,
                                 Attribute::InaccessibleMemOrArgMemOnly);
  FnAttrs = FnAttrs.addAttribute(Ctx, AttributeList::FunctionIndex,
                                 Attribute::NoUnwind);

  // Synthesize the after hook for this function.
  SmallVector<Type *, 8> AfterHookParamTys({IDType, /*callee func_id*/ IDType,
                                            /*MAAP_count*/ IRB.getInt8Ty(),
                                            CsiAllocFnProperty::getType(Ctx)});
  SmallVector<Value *, 8> AfterHookParamVals(
      {AllocFnId, FuncId, NumMVVal, PropVal});
  SmallVector<Value *, 8> AfterHookDefaultVals(
      {DefaultID, DefaultID, IRB.getInt8(0), DefaultPropVal});
  if (!Called->getReturnType()->isVoidTy()) {
    AfterHookParamTys.push_back(Called->getReturnType());
    AfterHookParamVals.push_back(CB);
    AfterHookDefaultVals.push_back(
        Constant::getNullValue(Called->getReturnType()));
  }
  AfterHookParamTys.append(Called->getFunctionType()->param_begin(),
                           Called->getFunctionType()->param_end());
  AfterHookParamVals.append(CB->arg_begin(), CB->arg_end());
  for (Value *Arg : CB->args())
    AfterHookDefaultVals.push_back(Constant::getNullValue(Arg->getType()));
  FunctionType *AfterHookTy =
      FunctionType::get(IRB.getVoidTy(), AfterHookParamTys, Called->isVarArg());
  FunctionCallee AfterLibCallHook = getOrInsertSynthesizedHook(
      ("__csan_alloc_" + Called->getName()).str(), AfterHookTy, FnAttrs);

  // Insert the hook after the call.
  BasicBlock::iterator Iter(I);
  if (IsInvoke) {
    // There are two "after" positions for invokes: the normal block and the
    // exception block.
    InvokeInst *II = cast<InvokeInst>(I);
    insertHookCallInSuccessorBB(
        II->getNormalDest(), II->getParent(), AfterLibCallHook,
        AfterHookParamVals, AfterHookDefaultVals);
    // Don't insert any instrumentation in the exception block.
  } else {
    // Simple call instruction; there is only one "after" position.
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    insertHookCall(&*Iter, AfterLibCallHook, AfterHookParamVals);
  }

  NumInstrumentedAllocFns++;
  return true;
}

bool CilkSanitizerImpl::instrumentAllocationFn(Instruction *I,
                                               DominatorTree *DT,
                                               const TargetLibraryInfo *TLI) {
  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SHADOWMEMORY))
    return true;

  bool IsInvoke = isa<InvokeInst>(I);
  assert(isa<CallBase>(I) &&
         "instrumentAllocationFn not given a call or invoke instruction.");
  Function *Called = dyn_cast<CallBase>(I)->getCalledFunction();
  assert(Called && "Could not get called function for allocation fn.");

  IRBuilder<> IRB(I);
  SmallVector<Value *, 4> AllocFnArgs;
  if (!getAllocFnArgs(I, AllocFnArgs, IntptrTy, IRB.getInt8PtrTy(), *TLI)) {
    return instrumentAllocFnLibCall(I, TLI);
  }
  SmallVector<Value *, 4> DefaultAllocFnArgs(
      {/* Allocated size */ Constant::getNullValue(IntptrTy),
       /* Number of elements */ Constant::getNullValue(IntptrTy),
       /* Alignment */ Constant::getNullValue(IntptrTy),
       /* Old pointer */ Constant::getNullValue(IRB.getInt8PtrTy()),});

  Value *DefaultID = getDefaultID(IRB);
  uint64_t LocalId = AllocFnFED.add(*I);
  Value *AllocFnId = AllocFnFED.localToGlobalId(LocalId, IRB);
  uint64_t AllocFnObjId = AllocFnObj.add(*I, getHeapObject(I));
  assert(LocalId == AllocFnObjId &&
         "Allocation fn received different ID's in FED and object tables.");

  CsiAllocFnProperty Prop;
  Value *DefaultPropVal = Prop.getValue(IRB);
  LibFunc AllocLibF;
  TLI->getLibFunc(*Called, AllocLibF);
  Prop.setAllocFnTy(static_cast<unsigned>(getAllocFnTy(AllocLibF)));
  AllocFnArgs.push_back(Prop.getValue(IRB));
  DefaultAllocFnArgs.push_back(DefaultPropVal);

  BasicBlock::iterator Iter(I);
  if (IsInvoke) {
    // There are two "after" positions for invokes: the normal block and the
    // exception block.
    InvokeInst *II = cast<InvokeInst>(I);

    BasicBlock *NormalBB = II->getNormalDest();
    unsigned SuccNum = GetSuccessorNumber(II->getParent(), NormalBB);
    if (isCriticalEdge(II, SuccNum))
      NormalBB = SplitCriticalEdge(II, SuccNum,
                                   CriticalEdgeSplittingOptions(DT));
    // Insert hook into normal destination.
    {
      IRB.SetInsertPoint(&*NormalBB->getFirstInsertionPt());
      SmallVector<Value *, 4> AfterAllocFnArgs;
      AfterAllocFnArgs.push_back(AllocFnId);
      AfterAllocFnArgs.push_back(IRB.CreatePointerCast(I, IRB.getInt8PtrTy()));
      AfterAllocFnArgs.append(AllocFnArgs.begin(), AllocFnArgs.end());
      insertHookCall(&*IRB.GetInsertPoint(), CsanAfterAllocFn,
                     AfterAllocFnArgs);
    }
    // Insert hook into unwind destination.
    {
      // The return value of the allocation function is not valid in the unwind
      // destination.
      SmallVector<Value *, 4> AfterAllocFnArgs, DefaultAfterAllocFnArgs;
      AfterAllocFnArgs.push_back(AllocFnId);
      AfterAllocFnArgs.push_back(Constant::getNullValue(IRB.getInt8PtrTy()));
      AfterAllocFnArgs.append(AllocFnArgs.begin(), AllocFnArgs.end());
      DefaultAfterAllocFnArgs.push_back(DefaultID);
      DefaultAfterAllocFnArgs.push_back(
          Constant::getNullValue(IRB.getInt8PtrTy()));
      DefaultAfterAllocFnArgs.append(DefaultAllocFnArgs.begin(),
                                     DefaultAllocFnArgs.end());
      insertHookCallInSuccessorBB(
          II->getUnwindDest(), II->getParent(), CsanAfterAllocFn,
          AfterAllocFnArgs, DefaultAfterAllocFnArgs);
    }
  } else {
    // Simple call instruction; there is only one "after" position.
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    SmallVector<Value *, 4> AfterAllocFnArgs;
    AfterAllocFnArgs.push_back(AllocFnId);
    AfterAllocFnArgs.push_back(IRB.CreatePointerCast(I, IRB.getInt8PtrTy()));
    AfterAllocFnArgs.append(AllocFnArgs.begin(), AllocFnArgs.end());
    insertHookCall(&*Iter, CsanAfterAllocFn, AfterAllocFnArgs);
  }

  NumInstrumentedAllocFns++;
  return true;
}

bool CilkSanitizerImpl::instrumentFree(Instruction *I,
                                       const TargetLibraryInfo *TLI) {
  // Only insert instrumentation if requested
  if (!(InstrumentationSet & SHADOWMEMORY))
    return true;

  // It appears that frees (and deletes) never throw.
  assert(isa<CallInst>(I) && "Free call is not a call instruction");

  CallInst *FC = cast<CallInst>(I);
  Function *Called = FC->getCalledFunction();
  assert(Called && "Could not get called function for free.");

  IRBuilder<> IRB(I);
  uint64_t LocalId = FreeFED.add(*I);
  Value *FreeId = FreeFED.localToGlobalId(LocalId, IRB);
  // uint64_t FreeObjId = FreeObj.add(*I, getHeapObject(I));
  // assert(LocalId == FreeObjId &&
  //        "Allocation fn received different ID's in FED and object tables.");

  Value *Addr = FC->getArgOperand(0);
  CsiFreeProperty Prop;
  LibFunc FreeLibF;
  TLI->getLibFunc(*Called, FreeLibF);
  Prop.setFreeTy(static_cast<unsigned>(getFreeTy(FreeLibF)));

  BasicBlock::iterator Iter(I);
  Iter++;
  IRB.SetInsertPoint(&*Iter);
  insertHookCall(&*Iter, CsanAfterFree, {FreeId, Addr, Prop.getValue(IRB)});

  NumInstrumentedFrees++;
  return true;
}

bool CilkSanitizerLegacyPass::runOnModule(Module &M) {
  if (skipModule(M))
    return false;

  CallGraph *CG = &getAnalysis<CallGraphWrapperPass>().getCallGraph();
  // const TargetLibraryInfo *TLI =
  //     &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI();
  auto GetTLI = [this](Function &F) -> TargetLibraryInfo & {
    return this->getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);
  };
  auto GetDomTree = [this](Function &F) -> DominatorTree & {
    return this->getAnalysis<DominatorTreeWrapperPass>(F).getDomTree();
  };
  auto GetTaskInfo = [this](Function &F) -> TaskInfo & {
    return this->getAnalysis<TaskInfoWrapperPass>(F).getTaskInfo();
  };
  auto GetLoopInfo = [this](Function &F) -> LoopInfo & {
    return this->getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
  };
  auto GetRaceInfo = [this](Function &F) -> RaceInfo & {
    return this->getAnalysis<TapirRaceDetectWrapperPass>(F).getRaceInfo();
  };
  auto GetSE = [this](Function &F) -> ScalarEvolution & {
    return this->getAnalysis<ScalarEvolutionWrapperPass>(F).getSE();
  };

  bool Changed =
      CilkSanitizerImpl(M, CG, GetDomTree, nullptr, GetLoopInfo, nullptr,
                        GetTLI, nullptr, JitMode, CallsMayThrow)
          .setup();
  Changed |=
      CilkSanitizerImpl(M, CG, GetDomTree, GetTaskInfo, GetLoopInfo,
                        GetRaceInfo, GetTLI, GetSE, JitMode, CallsMayThrow)
          .run();
  return Changed;
}

PreservedAnalyses CilkSanitizerPass::run(Module &M, ModuleAnalysisManager &AM) {
  auto &FAM = AM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  auto &CG = AM.getResult<CallGraphAnalysis>(M);
  auto GetDT =
    [&FAM](Function &F) -> DominatorTree & {
      return FAM.getResult<DominatorTreeAnalysis>(F);
    };
  auto GetTI =
    [&FAM](Function &F) -> TaskInfo & {
      return FAM.getResult<TaskAnalysis>(F);
    };
  auto GetLI =
    [&FAM](Function &F) -> LoopInfo & {
      return FAM.getResult<LoopAnalysis>(F);
    };
  auto GetRI =
    [&FAM](Function &F) -> RaceInfo & {
      return FAM.getResult<TapirRaceDetect>(F);
    };
  auto GetTLI =
    [&FAM](Function &F) -> TargetLibraryInfo & {
      return FAM.getResult<TargetLibraryAnalysis>(F);
    };
  auto GetSE = [&FAM](Function &F) -> ScalarEvolution & {
    return FAM.getResult<ScalarEvolutionAnalysis>(F);
  };

  bool Changed =
      CilkSanitizerImpl(M, &CG, GetDT, nullptr, GetLI, nullptr, GetTLI, nullptr)
          .setup();
  Changed |=
      CilkSanitizerImpl(M, &CG, GetDT, GetTI, GetLI, GetRI, GetTLI, GetSE)
          .run();

  if (!Changed)
    return PreservedAnalyses::all();

  return PreservedAnalyses::none();
}
