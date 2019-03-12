//===-- ComprehensiveStaticInstrumentation.cpp - CSI compiler pass --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is part of CSI, a framework that provides comprehensive static
// instrumentation.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Instrumentation/ComprehensiveStaticInstrumentation.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/CaptureTracking.h"
#include "llvm/Analysis/EHPersonalities.h"
#include "llvm/Analysis/MemoryBuiltins.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Linker/Linker.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/CSI.h"
#include "llvm/Transforms/Instrumentation.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/EscapeEnumerator.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "csi"

static cl::opt<bool>
    ClInstrumentFuncEntryExit("csi-instrument-func-entry-exit", cl::init(true),
                              cl::desc("Instrument function entry and exit"),
                              cl::Hidden);
static cl::opt<bool>
    ClInstrumentBasicBlocks("csi-instrument-basic-blocks", cl::init(true),
                            cl::desc("Instrument basic blocks"), cl::Hidden);
static cl::opt<bool>
    ClInstrumentMemoryAccesses("csi-instrument-memory-accesses", cl::init(true),
                               cl::desc("Instrument memory accesses"),
                               cl::Hidden);
static cl::opt<bool> ClInstrumentCalls("csi-instrument-function-calls",
                                       cl::init(true),
                                       cl::desc("Instrument function calls"),
                                       cl::Hidden);
static cl::opt<bool> ClInstrumentAtomics("csi-instrument-atomics",
                                         cl::init(true),
                                         cl::desc("Instrument atomics"),
                                         cl::Hidden);
static cl::opt<bool> ClInstrumentMemIntrinsics(
    "csi-instrument-memintrinsics", cl::init(true),
    cl::desc("Instrument memintrinsics (memset/memcpy/memmove)"), cl::Hidden);
static cl::opt<bool> ClInstrumentTapir("csi-instrument-tapir", cl::init(true),
                                       cl::desc("Instrument tapir constructs"),
                                       cl::Hidden);
static cl::opt<bool> ClInstrumentAllocas("csi-instrument-alloca",
                                         cl::init(true),
                                         cl::desc("Instrument allocas"),
                                         cl::Hidden);
static cl::opt<bool>
    ClInstrumentAllocFns("csi-instrument-allocfn", cl::init(true),
                         cl::desc("Instrument allocation functions"),
                         cl::Hidden);

static cl::opt<bool>
    ClInstrumentArithmetic("csi-instrument-arithmetic", cl::init(true),
                           cl::desc("Instrument arithmetic operations"),
                           cl::Hidden);

static cl::opt<bool> ClInterpose("csi-interpose", cl::init(true),
                                 cl::desc("Enable function interpositioning"),
                                 cl::Hidden);

static cl::opt<std::string> ClToolBitcode(
    "csi-tool-bitcode", cl::init(""),
    cl::desc("Path to the tool bitcode file for compile-time instrumentation"),
    cl::Hidden);

static cl::opt<std::string>
    ClRuntimeBitcode("csi-runtime-bitcode", cl::init(""),
                     cl::desc("Path to the CSI runtime bitcode file for "
                              "optimized compile-time instrumentation"),
                     cl::Hidden);

static cl::opt<std::string> ClConfigurationFilename(
    "csi-config-filename", cl::init(""),
    cl::desc("Path to the configuration file for surgical instrumentation"),
    cl::Hidden);

static cl::opt<InstrumentationConfigMode> ClConfigurationMode(
    "csi-config-mode", cl::init(InstrumentationConfigMode::WHITELIST),
    cl::values(clEnumValN(InstrumentationConfigMode::WHITELIST, "whitelist",
                          "Use configuration file as a whitelist"),
               clEnumValN(InstrumentationConfigMode::BLACKLIST, "blacklist",
                          "Use configuration file as a blacklist")),
    cl::desc("Specifies how to interpret the configuration file"), cl::Hidden);

namespace {

static CSIOptions OverrideFromCL(CSIOptions Options) {
  Options.InstrumentFuncEntryExit = ClInstrumentFuncEntryExit;
  Options.InstrumentBasicBlocks = ClInstrumentBasicBlocks;
  Options.InstrumentMemoryAccesses = ClInstrumentMemoryAccesses;
  Options.InstrumentCalls = ClInstrumentCalls;
  Options.InstrumentAtomics = ClInstrumentAtomics;
  Options.InstrumentMemIntrinsics = ClInstrumentMemIntrinsics;
  Options.InstrumentTapir = ClInstrumentTapir;
  Options.InstrumentAllocas = ClInstrumentAllocas;
  Options.InstrumentAllocFns = ClInstrumentAllocFns;
  Options.InstrumentArithmetic = ClInstrumentArithmetic;
  return Options;
}

/// The Comprehensive Static Instrumentation pass.
/// Inserts calls to user-defined hooks at predefined points in the IR.
struct ComprehensiveStaticInstrumentationLegacyPass : public ModulePass {
  static char ID; // Pass identification, replacement for typeid.

  ComprehensiveStaticInstrumentationLegacyPass(
      const CSIOptions &Options = OverrideFromCL(CSIOptions()))
      : ModulePass(ID), Options(Options) {
    initializeComprehensiveStaticInstrumentationLegacyPassPass(
        *PassRegistry::getPassRegistry());
  }
  StringRef getPassName() const override {
    return "ComprehensiveStaticInstrumentation";
  }
  bool runOnModule(Module &M) override;
  void getAnalysisUsage(AnalysisUsage &AU) const override;

private:
  CSIOptions Options;
}; // struct ComprehensiveStaticInstrumentation
} // anonymous namespace

char ComprehensiveStaticInstrumentationLegacyPass::ID = 0;

INITIALIZE_PASS_BEGIN(ComprehensiveStaticInstrumentationLegacyPass, "csi",
                      "ComprehensiveStaticInstrumentation pass", false, false)
INITIALIZE_PASS_DEPENDENCY(CallGraphWrapperPass)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TaskInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetLibraryInfoWrapperPass)
INITIALIZE_PASS_END(ComprehensiveStaticInstrumentationLegacyPass, "csi",
                    "ComprehensiveStaticInstrumentation pass", false, false)

ModulePass *llvm::createComprehensiveStaticInstrumentationLegacyPass() {
  return new ComprehensiveStaticInstrumentationLegacyPass();
}
ModulePass *llvm::createComprehensiveStaticInstrumentationLegacyPass(
    const CSIOptions &Options) {
  return new ComprehensiveStaticInstrumentationLegacyPass(Options);
}

/// Return the first DILocation in the given basic block, or nullptr
/// if none exists.
static const DILocation *getFirstDebugLoc(const BasicBlock &BB) {
  for (const Instruction &Inst : BB)
    if (const DILocation *Loc = Inst.getDebugLoc())
      return Loc;

  return nullptr;
}

/// Set DebugLoc on the call instruction to a CSI hook, based on the
/// debug information of the instrumented instruction.
static void setInstrumentationDebugLoc(Instruction *Instrumented,
                                       Instruction *Call) {
  DISubprogram *Subprog = Instrumented->getFunction()->getSubprogram();
  if (Subprog) {
    if (Instrumented->getDebugLoc()) {
      Call->setDebugLoc(Instrumented->getDebugLoc());
    } else {
      LLVMContext &C = Instrumented->getFunction()->getParent()->getContext();
      Call->setDebugLoc(DILocation::get(C, 0, 0, Subprog));
    }
  }
}

/// Set DebugLoc on the call instruction to a CSI hook, based on the
/// debug information of the instrumented instruction.
static void setInstrumentationDebugLoc(BasicBlock &Instrumented,
                                       Instruction *Call) {
  DISubprogram *Subprog = Instrumented.getParent()->getSubprogram();
  if (Subprog) {
    if (const DILocation *FirstDebugLoc = getFirstDebugLoc(Instrumented))
      Call->setDebugLoc(FirstDebugLoc);
    else {
      LLVMContext &C = Instrumented.getParent()->getParent()->getContext();
      Call->setDebugLoc(DILocation::get(C, 0, 0, Subprog));
    }
  }
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

bool CSIImpl::callsPlaceholderFunction(const Instruction &I) {
  if (isa<DbgInfoIntrinsic>(I))
    return true;

  if (isDetachedRethrow(&I))
    return true;

  if (const IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I))
    if (Intrinsic::syncregion_start == II->getIntrinsicID() ||
        Intrinsic::lifetime_start == II->getIntrinsicID() ||
        Intrinsic::lifetime_end == II->getIntrinsicID())
      return true;

  return false;
}

bool CSIImpl::run() {
  initializeCsi();

  for (GlobalValue &G : M.globals()) {
    if (isa<Function>(G)) continue;
    if (G.isDeclaration()) continue;
    if (G.getName().startswith("__csi")) continue;
    // Assign an ID for this global.
    csi_id_t LocalId = GlobalFED.add(G);
    GlobalOffsetMap[G.getName()] = LocalId;
  }

  for (Function &F : M)
    instrumentFunction(F);

  collectUnitFEDTables();
  collectUnitSizeTables();
  finalizeCsi();

  linkInToolFromBitcode(ClToolBitcode);
  linkInToolFromBitcode(ClRuntimeBitcode);

  return true; // We always insert the unit constructor.
}

Constant *ForensicTable::getObjectStrGV(Module &M, StringRef Str,
                                        const Twine GVName) {
  LLVMContext &C = M.getContext();
  IntegerType *Int32Ty = IntegerType::get(C, 32);
  Constant *Zero = ConstantInt::get(Int32Ty, 0);
  Value *GepArgs[] = {Zero, Zero};
  if (Str.empty())
    return ConstantPointerNull::get(
        PointerType::get(IntegerType::get(C, 8), 0));

  Constant *NameStrConstant = ConstantDataArray::getString(C, Str);
  GlobalVariable *GV = M.getGlobalVariable((GVName + Str).str(), true);
  if (GV == NULL) {
    GV = new GlobalVariable(M, NameStrConstant->getType(), true,
                            GlobalValue::PrivateLinkage, NameStrConstant,
                            GVName + Str, nullptr,
                            GlobalVariable::NotThreadLocal, 0);
    GV->setUnnamedAddr(GlobalValue::UnnamedAddr::Global);
  }
  assert(GV);
  return ConstantExpr::getGetElementPtr(GV->getValueType(), GV, GepArgs);
}

ForensicTable::ForensicTable(Module &M, StringRef BaseIdName,
                             StringRef TableName)
    : TableName(TableName) {
  LLVMContext &C = M.getContext();
  IntegerType *Int64Ty = IntegerType::get(C, 64);
  IdCounter = 0;
  BaseId = M.getGlobalVariable(BaseIdName, true);
  if (NULL == BaseId)
    BaseId = new GlobalVariable(M, Int64Ty, false, GlobalValue::InternalLinkage,
                                ConstantInt::get(Int64Ty, 0), BaseIdName);
  assert(BaseId);
}

csi_id_t ForensicTable::getId(const Value *V) {
  if (!ValueToLocalIdMap.count(V))
    ValueToLocalIdMap[V] = IdCounter++;
  assert(ValueToLocalIdMap.count(V) && "Value not in ID map.");
  return ValueToLocalIdMap[V];
}

Value *ForensicTable::localToGlobalId(csi_id_t LocalId,
                                      IRBuilder<> &IRB) const {
  if (CsiUnknownId == LocalId)
    return IRB.getInt64(CsiUnknownId);

  assert(BaseId);
  LLVMContext &C = IRB.getContext();
  LoadInst *Base = IRB.CreateLoad(BaseId);
  MDNode *MD = llvm::MDNode::get(C, None);
  Base->setMetadata(LLVMContext::MD_invariant_load, MD);
  Value *Offset = IRB.getInt64(LocalId);
  return IRB.CreateAdd(Base, Offset);
}

csi_id_t SizeTable::add(const BasicBlock &BB) {
  csi_id_t ID = getId(&BB);
  // Count the LLVM IR instructions
  int32_t NonEmptyIRSize = 0;
  for (const Instruction &I : BB) {
    if (isa<PHINode>(I))
      continue;
    if (CSIImpl::callsPlaceholderFunction(I))
      continue;
    NonEmptyIRSize++;
  }
  add(ID, BB.size(), NonEmptyIRSize);
  return ID;
}

PointerType *SizeTable::getPointerType(LLVMContext &C) {
  return PointerType::get(getSizeStructType(C), 0);
}

StructType *SizeTable::getSizeStructType(LLVMContext &C) {
  return StructType::get(
      /* FullIRSize */ IntegerType::get(C, 32),
      /* NonEmptyIRSize */ IntegerType::get(C, 32));
}

void SizeTable::add(csi_id_t ID, int32_t FullIRSize, int32_t NonEmptyIRSize) {
  assert(NonEmptyIRSize <= FullIRSize && "Broken basic block IR sizes");
  assert(LocalIdToSizeMap.find(ID) == LocalIdToSizeMap.end() &&
         "ID already exists in FED table.");
  LocalIdToSizeMap[ID] = {FullIRSize, NonEmptyIRSize};
}

Constant *SizeTable::insertIntoModule(Module &M) const {
  LLVMContext &C = M.getContext();
  StructType *TableType = getSizeStructType(C);
  IntegerType *Int32Ty = IntegerType::get(C, 32);
  Constant *Zero = ConstantInt::get(Int32Ty, 0);
  Value *GepArgs[] = {Zero, Zero};
  SmallVector<Constant *, 1> TableEntries;

  for (csi_id_t LocalID = 0; LocalID < IdCounter; ++LocalID) {
    const SizeInformation &E = LocalIdToSizeMap.find(LocalID)->second;
    Constant *FullIRSize = ConstantInt::get(Int32Ty, E.FullIRSize);
    Constant *NonEmptyIRSize = ConstantInt::get(Int32Ty, E.NonEmptyIRSize);
    // The order of arguments to ConstantStruct::get() must match the
    // sizeinfo_t type in csi.h.
    TableEntries.push_back(
        ConstantStruct::get(TableType, FullIRSize, NonEmptyIRSize));
  }

  ArrayType *TableArrayType = ArrayType::get(TableType, TableEntries.size());
  Constant *Table = ConstantArray::get(TableArrayType, TableEntries);
  GlobalVariable *GV =
      new GlobalVariable(M, TableArrayType, false, GlobalValue::InternalLinkage,
                         Table, TableName);
  return ConstantExpr::getGetElementPtr(GV->getValueType(), GV, GepArgs);
}

csi_id_t FrontEndDataTable::add(const Function &F) {
  csi_id_t ID = getId(&F);
  add(ID, F.getSubprogram());
  return ID;
}

csi_id_t FrontEndDataTable::add(const BasicBlock &BB) {
  csi_id_t ID = getId(&BB);
  add(ID, getFirstDebugLoc(BB));
  return ID;
}

csi_id_t FrontEndDataTable::add(const Instruction &I,
                                const StringRef &RealName) {
  csi_id_t ID = getId(&I);
  StringRef Name = RealName;
  if (Name == "") {
    // Look for a llvm.dbg.declare intrinsic.
    TinyPtrVector<DbgInfoIntrinsic *> DbgDeclares =
      FindDbgAddrUses(const_cast<Instruction *>(&I));
    if (!DbgDeclares.empty()) {
      auto *LV = DbgDeclares.front()->getVariable();
      add(ID, (int32_t)LV->getLine(), -1,
          LV->getFilename(), LV->getDirectory(), LV->getName());
      return ID;
    }

    // Examine the llvm.dbg.value intrinsics for this object.
    SmallVector<DbgValueInst *, 1> DbgValues;
    findDbgValues(DbgValues, const_cast<Instruction *>(&I));
    for (auto *DVI : DbgValues) {
      auto *LV = DVI->getVariable();
      if (LV->getName() != "") {
        Name = LV->getName();
        break;
      }
    }
  }
  add(ID, I.getDebugLoc(), Name);
  return ID;
}

csi_id_t FrontEndDataTable::add(Value &V) {
  csi_id_t ID = getId(&V);
  // Look for a llvm.dbg.declare intrinsic.
  TinyPtrVector<DbgInfoIntrinsic *> DbgDeclares = FindDbgAddrUses(&V);
  if (!DbgDeclares.empty()) {
    auto *LV = DbgDeclares.front()->getVariable();
    add(ID, (int32_t)LV->getLine(), -1,
        LV->getFilename(), LV->getDirectory(), LV->getName());
    return ID;
  }

  // Examine the llvm.dbg.value intrinsics for this object.
  SmallVector<DbgValueInst *, 1> DbgValues;
  findDbgValues(DbgValues, &V);
  for (auto *DVI : DbgValues) {
    auto *LV = DVI->getVariable();
    if (LV->getName() != "") {
      add(ID, (int32_t)LV->getLine(), -1,
          LV->getFilename(), LV->getDirectory(), LV->getName());
      return ID;
    }
  }

  add(ID);
  return ID;
}

csi_id_t FrontEndDataTable::add(const GlobalValue &Val) {
  csi_id_t ID = getId(&Val);
  // If the underlying object is a global variable, get that variable's
  // debug information.
  if (const GlobalVariable *GV = dyn_cast<GlobalVariable>(&Val)) {
    SmallVector<DIGlobalVariableExpression *, 1> DbgGVExprs;
    GV->getDebugInfo(DbgGVExprs);
    for (auto *GVE : DbgGVExprs) {
      auto *DGV = GVE->getVariable();
      if (DGV->getName() != "") {
        add(ID, (int32_t)DGV->getLine(), -1,
            DGV->getFilename(), DGV->getDirectory(), DGV->getName());
        return ID;
      }
    }
  }
  add(ID);
  return ID;
}

PointerType *FrontEndDataTable::getPointerType(LLVMContext &C) {
  return PointerType::get(getSourceLocStructType(C), 0);
}

StructType *FrontEndDataTable::getSourceLocStructType(LLVMContext &C) {
  return StructType::get(
      /* Name */ PointerType::get(IntegerType::get(C, 8), 0),
      /* Line */ IntegerType::get(C, 32),
      /* Column */ IntegerType::get(C, 32),
      /* File */ PointerType::get(IntegerType::get(C, 8), 0));
}

void FrontEndDataTable::add(csi_id_t ID, const DILocation *Loc,
                            const StringRef &RealName) {
  if (Loc) {
    // TODO: Add location information for inlining
    const DISubprogram *Subprog = Loc->getScope()->getSubprogram();
    add(ID, (int32_t)Loc->getLine(), (int32_t)Loc->getColumn(),
        Loc->getFilename(), Loc->getDirectory(),
        RealName == "" ? Subprog->getName() : RealName);
  } else
    add(ID);
}

void FrontEndDataTable::add(csi_id_t ID, const DISubprogram *Subprog) {
  if (Subprog)
    add(ID, (int32_t)Subprog->getLine(), -1, Subprog->getFilename(),
        Subprog->getDirectory(), Subprog->getName());
  else
    add(ID);
}

void FrontEndDataTable::add(csi_id_t ID, int32_t Line, int32_t Column,
                            StringRef Filename, StringRef Directory,
                            StringRef Name) {
  // TODO: This assert is too strong for unwind basic blocks' FED.
  /*assert(LocalIdToSourceLocationMap.find(ID) ==
             LocalIdToSourceLocationMap.end() &&
         "Id already exists in FED table."); */
  LocalIdToSourceLocationMap[ID] = {Name, Line, Column, Filename, Directory};
}

// The order of arguments to ConstantStruct::get() must match the source_loc_t
// type in csi.h.
static void addFEDTableEntries(SmallVectorImpl<Constant *> &FEDEntries,
                               StructType *FedType, Constant *Name,
                               Constant *Line, Constant *Column,
                               Constant *File) {
  FEDEntries.push_back(ConstantStruct::get(FedType, Name, Line, Column, File));
}

Constant *FrontEndDataTable::insertIntoModule(Module &M) const {
  LLVMContext &C = M.getContext();
  StructType *FedType = getSourceLocStructType(C);
  IntegerType *Int32Ty = IntegerType::get(C, 32);
  Constant *Zero = ConstantInt::get(Int32Ty, 0);
  Value *GepArgs[] = {Zero, Zero};
  SmallVector<Constant *, 11> FEDEntries;

  for (csi_id_t LocalID = 0; LocalID < IdCounter; ++LocalID) {
    const SourceLocation &E = LocalIdToSourceLocationMap.find(LocalID)->second;
    Constant *Line = ConstantInt::get(Int32Ty, E.Line);
    Constant *Column = ConstantInt::get(Int32Ty, E.Column);
    Constant *File;
    {
      std::string Filename = E.Filename.str();
      if (!E.Directory.empty())
        Filename = E.Directory.str() + "/" + Filename;
      File = getObjectStrGV(M, Filename, "__csi_unit_filename_");
    }
    Constant *Name = getObjectStrGV(M, E.Name, DebugNamePrefix);
    addFEDTableEntries(FEDEntries, FedType, Name, Line, Column, File);
  }

  ArrayType *FedArrayType = ArrayType::get(FedType, FEDEntries.size());
  Constant *Table = ConstantArray::get(FedArrayType, FEDEntries);
  GlobalVariable *GV =
      new GlobalVariable(M, FedArrayType, false, GlobalValue::InternalLinkage,
                         Table, TableName);
  return ConstantExpr::getGetElementPtr(GV->getValueType(), GV, GepArgs);
}

/// Function entry and exit hook initialization
void CSIImpl::initializeFuncHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *IDType = IRB.getInt64Ty();
  Type *ValCatType = IRB.getInt8Ty();
  // Initialize function entry hooks
  Type *FuncPropertyTy = CsiFuncProperty::getType(C);
  CsiFuncEntry = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_func_entry", IRB.getVoidTy(), IDType, IDType, IRB.getInt32Ty(),
      FuncPropertyTy));
  // Initialize function exit hooks
  Type *FuncExitPropertyTy = CsiFuncExitProperty::getType(C);
  CsiFuncExit = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_func_exit", IRB.getVoidTy(), IDType, IDType,
      ValCatType, IDType, FuncExitPropertyTy));
}

/// Basic-block hook initialization
void CSIImpl::initializeBasicBlockHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *PropertyTy = CsiBBProperty::getType(C);
  CsiBBEntry = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_bb_entry", IRB.getVoidTy(), IRB.getInt64Ty(), PropertyTy));
  CsiBBExit = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_bb_exit", IRB.getVoidTy(), IRB.getInt64Ty(), PropertyTy));
}

// Call-site hook initialization
void CSIImpl::initializeCallsiteHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *IDType = IRB.getInt64Ty();
  Type *FuncOpType = IRB.getInt8Ty();
  Type *ValCatType = IRB.getInt8Ty();
  Type *OperandIDType = StructType::get(IRB.getInt8Ty(), IRB.getInt64Ty());
  Type *PropertyTy = CsiCallProperty::getType(C);
  CsiBeforeCallsite = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_call", IRB.getVoidTy(), IDType,
                            IDType, PointerType::get(OperandIDType, 0),
                            IRB.getInt32Ty(), PropertyTy));
  CsiBeforeCallsite->addParamAttr(2, Attribute::ReadOnly);
  CsiAfterCallsite = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_call", IRB.getVoidTy(), IDType,
                            IDType, PropertyTy));

  // Special callsite hooks for builtins.
  CsiBeforeBuiltinFF = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_builtin_float_float",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getFloatTy()));
  CsiAfterBuiltinFF = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_builtin_float_float",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeBuiltinDD = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_builtin_double_double",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getDoubleTy()));
  CsiAfterBuiltinDD = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_builtin_double_double",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getDoubleTy()));

  CsiBeforeBuiltinFFF = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_builtin_float_float_float",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getFloatTy(),
                            ValCatType, IDType, IRB.getFloatTy()));
  CsiAfterBuiltinFFF = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_builtin_float_float_float",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getFloatTy(),
                            ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeBuiltinDDD = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_builtin_double_double_double",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getDoubleTy(),
                            ValCatType, IDType, IRB.getDoubleTy()));
  CsiAfterBuiltinDDD = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_builtin_double_double_double",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getDoubleTy(),
                            ValCatType, IDType, IRB.getDoubleTy()));

  CsiBeforeBuiltinFFI = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_builtin_float_float_i32",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getFloatTy(),
                            ValCatType, IDType, IRB.getInt32Ty()));
  CsiAfterBuiltinFFI = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_builtin_float_float_i32",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getFloatTy(),
                            ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeBuiltinDDI = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_builtin_double_double_i32",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getDoubleTy(),
                            ValCatType, IDType, IRB.getInt32Ty()));
  CsiAfterBuiltinDDI = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_builtin_double_double_i32",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getDoubleTy(),
                            ValCatType, IDType, IRB.getInt32Ty()));

  CsiBeforeBuiltinFFFF = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_builtin_float_float_float_float",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getFloatTy(),
                            ValCatType, IDType, IRB.getFloatTy(),
                            ValCatType, IDType, IRB.getFloatTy()));
  CsiAfterBuiltinFFFF = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_builtin_float_float_float_float",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getFloatTy(),
                            ValCatType, IDType, IRB.getFloatTy(),
                            ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeBuiltinDDDD = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_builtin_double_double_double_double",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getDoubleTy(),
                            ValCatType, IDType, IRB.getDoubleTy(),
                            ValCatType, IDType, IRB.getDoubleTy()));
  CsiAfterBuiltinDDDD = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_builtin_double_double_double_double",
                            IRB.getVoidTy(), IDType, FuncOpType,
                            ValCatType, IDType, IRB.getDoubleTy(),
                            ValCatType, IDType, IRB.getDoubleTy(),
                            ValCatType, IDType, IRB.getDoubleTy()));
}

// Non-local-variable allocation/free hook initialization
void CSIImpl::initializeArithmeticHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *RetType = IRB.getVoidTy();
  Type *IDType = IRB.getInt64Ty();
  Type *OpcodeType = IRB.getInt8Ty();
  // Single-type opcodes: Add, FAdd, Sub, FSub, Mul, FMul, UDiv, SDiv, FDiv,
  // URem, SRem, FRem, Shl, LShr, AShr, And, Or, Xor
  Type *ValCatType = IRB.getInt8Ty();
  Type *FlagsType = CsiArithmeticFlags::getType(C);

  // Single-type floating-point operations
  // CsiBeforeArithmeticH = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_arithmetic_half", RetType, IDType,
  //         OpcodeType,
  //         ValCatType, IDType, IRB.getHalfTy(),
  //         ValCatType, IDType, IRB.getHalfTy(), FlagsType));
  CsiBeforeArithmeticF = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_arithmetic_float", RetType, IDType,
          OpcodeType,
          ValCatType, IDType, IRB.getFloatTy(),
          ValCatType, IDType, IRB.getFloatTy(), FlagsType));
  CsiBeforeArithmeticD = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_arithmetic_double", RetType, IDType,
          OpcodeType,
          ValCatType, IDType, IRB.getDoubleTy(),
          ValCatType, IDType, IRB.getDoubleTy(), FlagsType));

  // TODO: Consider passing integer precision as an extra argument.

  // Single-type integer operations
  CsiBeforeArithmeticI8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_arithmetic_i8", RetType, IDType,
          OpcodeType,
          ValCatType, IDType, IRB.getInt8Ty(),
          ValCatType, IDType, IRB.getInt8Ty(), FlagsType));
  CsiBeforeArithmeticI16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_arithmetic_i16", RetType, IDType,
          OpcodeType,
          ValCatType, IDType, IRB.getInt16Ty(),
          ValCatType, IDType, IRB.getInt16Ty(), FlagsType));
  CsiBeforeArithmeticI32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_arithmetic_i32", RetType, IDType,
          OpcodeType,
          ValCatType, IDType, IRB.getInt32Ty(),
          ValCatType, IDType, IRB.getInt32Ty(), FlagsType));
  CsiBeforeArithmeticI64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_arithmetic_i64", RetType, IDType,
          OpcodeType,
          ValCatType, IDType, IRB.getInt64Ty(),
          ValCatType, IDType, IRB.getInt64Ty(), FlagsType));
  CsiBeforeArithmeticI128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_arithmetic_i128", RetType, IDType,
          OpcodeType,
          ValCatType, IDType, IRB.getInt128Ty(),
          ValCatType, IDType, IRB.getInt128Ty(), FlagsType));

  // Floating-point type conversions
  // CsiBeforeExtendHF = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_extend_half_float", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeExtendHD = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_extend_half_double", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  CsiBeforeExtendFD = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_extend_float_double", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));

  CsiBeforeTruncateDF = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_double_float", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  // CsiBeforeTruncateDH = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_truncate_double_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getDoubleTy()));
  // CsiBeforeTruncateFH = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_truncate_float_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getFloatTy()));

  // Integer type truncation
  CsiBeforeTruncateI128I8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i128_i8", RetType, IDType,
          ValCatType, IDType, IRB.getInt128Ty()));
  CsiBeforeTruncateI128I16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i128_i16", RetType, IDType,
          ValCatType, IDType, IRB.getInt128Ty()));
  CsiBeforeTruncateI128I32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i128_i32", RetType, IDType,
          ValCatType, IDType, IRB.getInt128Ty()));
  CsiBeforeTruncateI128I64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i128_i64", RetType, IDType,
          ValCatType, IDType, IRB.getInt128Ty()));
  CsiBeforeTruncateI64I8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i64_i8", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));
  CsiBeforeTruncateI64I16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i64_i16", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));
  CsiBeforeTruncateI64I32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i64_i32", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));
  CsiBeforeTruncateI32I8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i32_i8", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeTruncateI32I16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i32_i16", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeTruncateI16I8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_truncate_i16_i8", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));

  // Integer type zero extension
  CsiBeforeZeroExtendI8I16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i8_i16", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeZeroExtendI8I32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i8_i32", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeZeroExtendI8I64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i8_i64", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeZeroExtendI8I128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i8_i128", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeZeroExtendI16I32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i16_i32", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeZeroExtendI16I64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i16_i64", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeZeroExtendI16I128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i16_i128", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeZeroExtendI32I64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i32_i64", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeZeroExtendI32I128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i32_i128", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeZeroExtendI64I128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_zero_extend_i64_i128", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));

  // Integer type sign extension
  CsiBeforeSignExtendI8I16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i8_i16", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeSignExtendI8I32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i8_i32", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeSignExtendI8I64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i8_i64", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeSignExtendI8I128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i8_i128", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeSignExtendI16I32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i16_i32", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeSignExtendI16I64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i16_i64", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeSignExtendI16I128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i16_i128", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeSignExtendI32I64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i32_i64", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeSignExtendI32I128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i32_i128", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeSignExtendI64I128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_sign_extend_i64_i128", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));

  // Floating-point-to-integer unsigned type conversions
  // CsiBeforeConvertHUI8 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_unsigned_i8", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeConvertHUI16 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_unsigned_i16", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeConvertHUI32 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_unsigned_i32", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeConvertHUI64 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_unsigned_i64", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeConvertHUI128 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_unsigned_i128", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));

  CsiBeforeConvertFUI8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_unsigned_i8", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeConvertFUI16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_unsigned_i16", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeConvertFUI32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_unsigned_i32", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeConvertFUI64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_unsigned_i64", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeConvertFUI128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_unsigned_i128", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));

  CsiBeforeConvertDUI8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_unsigned_i8", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  CsiBeforeConvertDUI16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_unsigned_i16", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  CsiBeforeConvertDUI32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_unsigned_i32", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  CsiBeforeConvertDUI64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_unsigned_i64", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  CsiBeforeConvertDUI128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_unsigned_i128", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));

  // Floating-point-to-integer signed type conversions
  // CsiBeforeConvertHSI8 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_signed_i8", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeConvertHSI16 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_signed_i16", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeConvertHSI32 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_signed_i32", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeConvertHSI64 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_signed_i64", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));
  // CsiBeforeConvertHSI128 = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_half_signed_i128", RetType, IDType,
  //         ValCatType, IDType, IRB.getHalfTy()));

  CsiBeforeConvertFSI8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_signed_i8", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeConvertFSI16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_signed_i16", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeConvertFSI32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_signed_i32", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeConvertFSI64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_signed_i64", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));
  CsiBeforeConvertFSI128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_float_signed_i128", RetType, IDType,
          ValCatType, IDType, IRB.getFloatTy()));

  CsiBeforeConvertDSI8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_signed_i8", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  CsiBeforeConvertDSI16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_signed_i16", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  CsiBeforeConvertDSI32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_signed_i32", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  CsiBeforeConvertDSI64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_signed_i64", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));
  CsiBeforeConvertDSI128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_double_signed_i128", RetType, IDType,
          ValCatType, IDType, IRB.getDoubleTy()));

  // Integer-to-floating-point unsigned type conversions
  // CsiBeforeConvertUI8H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_unsigned_i8_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeConvertUI8F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i8_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeConvertUI8D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i8_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));

  // CsiBeforeConvertUI16H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_unsigned_i16_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeConvertUI16F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i16_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeConvertUI16D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i16_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));

  // CsiBeforeConvertUI32H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_unsigned_i32_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeConvertUI32F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i32_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeConvertUI32D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i32_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));

  // CsiBeforeConvertUI64H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_unsigned_i64_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt64Ty()));
  CsiBeforeConvertUI64F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i64_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));
  CsiBeforeConvertUI64D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i64_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));

  // CsiBeforeConvertUI128H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_unsigned_i128_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt128Ty()));
  CsiBeforeConvertUI128F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i128_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt128Ty()));
  CsiBeforeConvertUI128D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_unsigned_i128_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt128Ty()));

  // Integer-to-floating-point signed type conversions
  // CsiBeforeConvertSI8H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_signed_i8_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeConvertSI8F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i8_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));
  CsiBeforeConvertSI8D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i8_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt8Ty()));

  // CsiBeforeConvertSI16H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_signed_i16_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeConvertSI16F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i16_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));
  CsiBeforeConvertSI16D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i16_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt16Ty()));

  // CsiBeforeConvertSI32H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_signed_i32_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeConvertSI32F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i32_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));
  CsiBeforeConvertSI32D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i32_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt32Ty()));

  // CsiBeforeConvertSI64H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_signed_i64_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt64Ty()));
  CsiBeforeConvertSI64F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i64_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));
  CsiBeforeConvertSI64D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i64_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt64Ty()));

  // CsiBeforeConvertSI128H = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_before_convert_signed_i128_half", RetType, IDType,
  //         ValCatType, IDType, IRB.getInt128Ty()));
  CsiBeforeConvertSI128F = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i128_float", RetType, IDType,
          ValCatType, IDType, IRB.getInt128Ty()));
  CsiBeforeConvertSI128D = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_before_convert_signed_i128_double", RetType, IDType,
          ValCatType, IDType, IRB.getInt128Ty()));

  // Phi nodes for scalar types
  CsiPhiI8 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_phi_i8", RetType, IDType, ValCatType, IDType,
          IRB.getInt8Ty()));
  CsiPhiI16 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_phi_i16", RetType, IDType, ValCatType, IDType,
          IRB.getInt16Ty()));
  CsiPhiI32 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_phi_i32", RetType, IDType, ValCatType, IDType,
          IRB.getInt32Ty()));
  CsiPhiI64 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_phi_i64", RetType, IDType, ValCatType, IDType,
          IRB.getInt64Ty()));
  CsiPhiI128 = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_phi_i128", RetType, IDType, ValCatType, IDType,
          IRB.getInt128Ty()));

  // CsiPhiH = checkCsiInterfaceFunction(
  //     M.getOrInsertFunction(
  //         "__csi_phi_half", RetType, IDType, ValCatType, IDType,
  //         IRB.getHalfTy()));
  CsiPhiF = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_phi_float", RetType, IDType, ValCatType, IDType,
          IRB.getFloatTy()));
  CsiPhiD = checkCsiInterfaceFunction(
      M.getOrInsertFunction(
          "__csi_phi_double", RetType, IDType, ValCatType, IDType,
          IRB.getDoubleTy()));
}

// Alloca (local variable) hook initialization
void CSIImpl::initializeAllocaHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *IDType = IRB.getInt64Ty();
  Type *AddrType = IRB.getInt8PtrTy();
  Type *PropType = CsiAllocaProperty::getType(C);

  CsiBeforeAlloca = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_before_alloca", IRB.getVoidTy(), IDType, IntptrTy, PropType));
  CsiAfterAlloca = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_alloca", IRB.getVoidTy(), IDType,
                            AddrType, IntptrTy, PropType));
  CsiAfterAlloca->addParamAttr(1, Attribute::ReadOnly);
}

// Non-local-variable allocation/free hook initialization
void CSIImpl::initializeAllocFnHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *RetType = IRB.getVoidTy();
  Type *IDType = IRB.getInt64Ty();
  Type *AddrType = IRB.getInt8PtrTy();
  Type *LargeNumBytesType = IntptrTy;
  Type *AllocFnPropType = CsiAllocFnProperty::getType(C);
  Type *FreePropType = CsiFreeProperty::getType(C);

  CsiBeforeAllocFn = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_before_allocfn", RetType, IDType, LargeNumBytesType,
      LargeNumBytesType, LargeNumBytesType, AddrType, AllocFnPropType));
  CsiBeforeAllocFn->addParamAttr(4, Attribute::ReadOnly);
  CsiAfterAllocFn = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_allocfn", RetType, IDType,
                            /* new ptr */ AddrType,
                            /* size */ LargeNumBytesType,
                            /* num elements */ LargeNumBytesType,
                            /* alignment */ LargeNumBytesType,
                            /* old ptr */ AddrType,
                            /* property */ AllocFnPropType));
  CsiAfterAllocFn->addParamAttr(1, Attribute::ReadOnly);
  CsiAfterAllocFn->addParamAttr(5, Attribute::ReadOnly);

  CsiBeforeFree = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_before_free", RetType, IDType, AddrType, FreePropType));
  CsiBeforeFree->addParamAttr(1, Attribute::ReadOnly);
  CsiAfterFree = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_after_free", RetType, IDType, AddrType, FreePropType));
  CsiAfterFree->addParamAttr(1, Attribute::ReadOnly);
}

// Load and store hook initialization
void CSIImpl::initializeLoadStoreHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *IDType = IRB.getInt64Ty();
  Type *ValCatType = IRB.getInt8Ty();
  Type *LoadPropertyTy = CsiLoadStoreProperty::getType(C);
  Type *StorePropertyTy = CsiLoadStoreProperty::getType(C);
  Type *RetType = IRB.getVoidTy();
  Type *AddrType = IRB.getInt8PtrTy();
  Type *NumBytesType = IRB.getInt32Ty();

  CsiBeforeRead = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_load", RetType, IDType,
                            AddrType, NumBytesType, LoadPropertyTy));
  CsiBeforeRead->addParamAttr(1, Attribute::ReadOnly);
  CsiAfterRead = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_load", RetType, IDType,
                            AddrType, NumBytesType, LoadPropertyTy));
  CsiAfterRead->addParamAttr(1, Attribute::ReadOnly);

  CsiBeforeWrite = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_store", RetType, IDType,
                            AddrType, NumBytesType, ValCatType, IDType,
                            StorePropertyTy));
  CsiBeforeWrite->addParamAttr(1, Attribute::ReadOnly);
  CsiAfterWrite = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_store", RetType, IDType,
                            AddrType, NumBytesType, ValCatType, IDType,
                            StorePropertyTy));
  CsiAfterWrite->addParamAttr(1, Attribute::ReadOnly);
}

// Initialization of hooks for LLVM memory intrinsics
void CSIImpl::initializeMemIntrinsicsHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);

  MemmoveFn = checkCsiInterfaceFunction(
      M.getOrInsertFunction("memmove", IRB.getInt8PtrTy(), IRB.getInt8PtrTy(),
                            IRB.getInt8PtrTy(), IntptrTy));
  MemcpyFn = checkCsiInterfaceFunction(
      M.getOrInsertFunction("memcpy", IRB.getInt8PtrTy(), IRB.getInt8PtrTy(),
                            IRB.getInt8PtrTy(), IntptrTy));
  MemsetFn = checkCsiInterfaceFunction(
      M.getOrInsertFunction("memset", IRB.getInt8PtrTy(), IRB.getInt8PtrTy(),
                            IRB.getInt32Ty(), IntptrTy));
}

// Initialization of Tapir hooks
void CSIImpl::initializeTapirHooks() {
  LLVMContext &C = M.getContext();
  IRBuilder<> IRB(C);
  Type *IDType = IRB.getInt64Ty();
  Type *RetType = IRB.getVoidTy();

  // TODO: Can we change the type of the TrackVars variable to be a simple i32?
  // That would allow the optimizer to more generally optimize away the
  // TrackVars stack allocation.

  CsiDetach = checkCsiInterfaceFunction(M.getOrInsertFunction(
      "__csi_detach", RetType,
      /* detach_id */ IDType, IntegerType::getInt32Ty(C)->getPointerTo()));
  CsiDetach->addParamAttr(1, Attribute::ReadOnly);
  CsiTaskEntry =
      checkCsiInterfaceFunction(M.getOrInsertFunction("__csi_task", RetType,
                                                      /* task_id */ IDType,
                                                      /* detach_id */ IDType));
  CsiTaskExit = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_task_exit", RetType,
                            /* task_exit_id */ IDType,
                            /* task_id */ IDType,
                            /* detach_id */ IDType));
  CsiDetachContinue = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_detach_continue", RetType,
                            /* detach_continue_id */ IDType,
                            /* detach_id */ IDType));
  CsiBeforeSync = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_before_sync", RetType, IDType,
                            IntegerType::getInt32Ty(C)->getPointerTo()));
  CsiBeforeSync->addParamAttr(1, Attribute::ReadOnly);
  CsiAfterSync = checkCsiInterfaceFunction(
      M.getOrInsertFunction("__csi_after_sync", RetType, IDType,
                            IntegerType::getInt32Ty(C)->getPointerTo()));
  CsiAfterSync->addParamAttr(1, Attribute::ReadOnly);
}

// Prepare any calls in the CFG for instrumentation, e.g., by making sure any
// call that can throw is modeled with an invoke.
void CSIImpl::setupCalls(Function &F) {
  // We use the EscapeEnumerator's built-in functionality to promote calls to
  // invokes.
  EscapeEnumerator EE(F, "csi.cleanup", true);
  while (EE.Next())
    ;

  // TODO: Split each basic block immediately after each call, to ensure that
  // calls act like terminators?
}

static BasicBlock *SplitOffPreds(BasicBlock *BB,
                                 SmallVectorImpl<BasicBlock *> &Preds,
                                 DominatorTree *DT) {
  if (BB->isLandingPad()) {
    SmallVector<BasicBlock *, 2> NewBBs;
    SplitLandingPadPredecessors(BB, Preds, ".csi-split-lp", ".csi-split",
                                NewBBs, DT);
    return NewBBs[1];
  }

  SplitBlockPredecessors(BB, Preds, ".csi-split", DT);
  return BB;
}

// Setup each block such that all of its predecessors belong to the same CSI ID
// space.
static void setupBlock(BasicBlock *BB, const TargetLibraryInfo *TLI,
                       DominatorTree *DT) {
  if (BB->getUniquePredecessor())
    return;

  SmallVector<BasicBlock *, 4> DetachPreds;
  SmallVector<BasicBlock *, 4> DetRethrowPreds;
  SmallVector<BasicBlock *, 4> SyncPreds;
  SmallVector<BasicBlock *, 4> AllocFnPreds;
  SmallVector<BasicBlock *, 4> InvokePreds;
  bool HasOtherPredTypes = false;
  unsigned NumPredTypes = 0;

  // Partition the predecessors of the landing pad.
  for (BasicBlock *Pred : predecessors(BB)) {
    if (isa<DetachInst>(Pred->getTerminator()))
      DetachPreds.push_back(Pred);
    else if (isDetachedRethrow(Pred->getTerminator()))
      DetRethrowPreds.push_back(Pred);
    else if (isa<SyncInst>(Pred->getTerminator()))
      SyncPreds.push_back(Pred);
    else if (isAllocationFn(Pred->getTerminator(), TLI))
      AllocFnPreds.push_back(Pred);
    else if (isa<InvokeInst>(Pred->getTerminator()))
      InvokePreds.push_back(Pred);
    else
      HasOtherPredTypes = true;
  }

  NumPredTypes = static_cast<unsigned>(!DetachPreds.empty()) +
                 static_cast<unsigned>(!DetRethrowPreds.empty()) +
                 static_cast<unsigned>(!SyncPreds.empty()) +
                 static_cast<unsigned>(!AllocFnPreds.empty()) +
                 static_cast<unsigned>(!InvokePreds.empty()) +
                 static_cast<unsigned>(HasOtherPredTypes);

  BasicBlock *BBToSplit = BB;
  // Split off the predecessors of each type.
  if (!DetachPreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, DetachPreds, DT);
    NumPredTypes--;
  }
  if (!DetRethrowPreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, DetRethrowPreds, DT);
    NumPredTypes--;
  }
  if (!SyncPreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, SyncPreds, DT);
    NumPredTypes--;
  }
  if (!AllocFnPreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, AllocFnPreds, DT);
    NumPredTypes--;
  }
  if (!InvokePreds.empty() && NumPredTypes > 1) {
    BBToSplit = SplitOffPreds(BBToSplit, InvokePreds, DT);
    NumPredTypes--;
  }
}

// Setup all basic blocks such that each block's predecessors belong entirely to
// one CSI ID space.
void CSIImpl::setupBlocks(Function &F, const TargetLibraryInfo *TLI,
                          DominatorTree *DT) {
  SmallPtrSet<BasicBlock *, 8> BlocksToSetup;
  for (BasicBlock &BB : F) {
    if (BB.isLandingPad())
      BlocksToSetup.insert(&BB);

    if (InvokeInst *II = dyn_cast<InvokeInst>(BB.getTerminator()))
      BlocksToSetup.insert(II->getNormalDest());
    else if (SyncInst *SI = dyn_cast<SyncInst>(BB.getTerminator()))
      BlocksToSetup.insert(SI->getSuccessor(0));
  }

  for (BasicBlock *BB : BlocksToSetup)
    setupBlock(BB, TLI, DT);
}

int CSIImpl::getNumBytesAccessed(Value *Addr, const DataLayout &DL) {
  Type *OrigPtrTy = Addr->getType();
  Type *OrigTy = cast<PointerType>(OrigPtrTy)->getElementType();
  assert(OrigTy->isSized());
  uint32_t TypeSize = DL.getTypeStoreSizeInBits(OrigTy);
  if (TypeSize % 8 != 0)
    return -1;
  return TypeSize / 8;
}

void CSIImpl::addLoadStoreInstrumentation(Instruction *I, Function *BeforeFn,
                                          Function *AfterFn, Value *CsiId,
                                          Type *AddrType, Value *Addr,
                                          int NumBytes, Value *StoreValCat,
                                          Value *StoreValID,
                                          CsiLoadStoreProperty &Prop) {
  IRBuilder<> IRB(I);
  Value *PropVal = Prop.getValue(IRB);
  if (StoreValCat && StoreValID)
    insertHookCall(I, BeforeFn,
                   {CsiId, IRB.CreatePointerCast(Addr, AddrType),
                    IRB.getInt32(NumBytes), StoreValCat, StoreValID, PropVal});
  else
    insertHookCall(I, BeforeFn,
                   {CsiId, IRB.CreatePointerCast(Addr, AddrType),
                    IRB.getInt32(NumBytes), PropVal});

  BasicBlock::iterator Iter = ++I->getIterator();
  IRB.SetInsertPoint(&*Iter);
  if (StoreValCat && StoreValID)
    insertHookCall(&*Iter, AfterFn,
                   {CsiId, IRB.CreatePointerCast(Addr, AddrType),
                    IRB.getInt32(NumBytes), StoreValCat, StoreValID, PropVal});
  else
    insertHookCall(&*Iter, AfterFn,
                   {CsiId, IRB.CreatePointerCast(Addr, AddrType),
                    IRB.getInt32(NumBytes), PropVal});
}

void CSIImpl::assignLoadOrStoreID(Instruction *I) {
  if (isa<StoreInst>(I))
    StoreFED.add(*I);
  else
    LoadFED.add(*I);
}

void CSIImpl::instrumentLoadOrStore(Instruction *I, CsiLoadStoreProperty &Prop,
                                    const DataLayout &DL) {
  IRBuilder<> IRB(I);
  bool IsWrite = isa<StoreInst>(I);
  Value *Addr = IsWrite ? cast<StoreInst>(I)->getPointerOperand()
                        : cast<LoadInst>(I)->getPointerOperand();
  int NumBytes = getNumBytesAccessed(Addr, DL);
  Type *AddrType = IRB.getInt8PtrTy();

  if (NumBytes == -1)
    return; // size that we don't recognize

  if (IsWrite) {
    csi_id_t LocalId = StoreFED.lookupId(I);
    Value *CsiId = StoreFED.localToGlobalId(LocalId, IRB);
    StoreInst *SI = cast<StoreInst>(I);
    Value *Operand = SI->getValueOperand();
    std::pair<Value *, Value *> OperandID = getOperandID(Operand, IRB);
    addLoadStoreInstrumentation(I, CsiBeforeWrite, CsiAfterWrite, CsiId,
                                AddrType, Addr, NumBytes, OperandID.first,
                                OperandID.second, Prop);
  } else { // is read
    csi_id_t LocalId = LoadFED.lookupId(I);
    Value *CsiId = LoadFED.localToGlobalId(LocalId, IRB);

    addLoadStoreInstrumentation(I, CsiBeforeRead, CsiAfterRead, CsiId, AddrType,
                                Addr, NumBytes, nullptr, nullptr, Prop);
  }
}

void CSIImpl::assignAtomicID(Instruction *I) {
  // TODO: Instrument atomics.
}

void CSIImpl::instrumentAtomic(Instruction *I, const DataLayout &DL) {
  // TODO: Instrument atomics.

  // For now, print a message that this code contains atomics.
  dbgs()
      << "WARNING: Uninstrumented atomic operations in program-under-test!\n";
}

// TODO: This code for instrumenting memory intrinsics was borrowed
// from TSan.  Different tools might have better ways to handle these
// function calls.  Replace this logic with a more flexible solution,
// possibly one based on interpositioning.
//
// If a memset intrinsic gets inlined by the code gen, we will miss it.
// So, we either need to ensure the intrinsic is not inlined, or instrument it.
// We do not instrument memset/memmove/memcpy intrinsics (too complicated),
// instead we simply replace them with regular function calls, which are then
// intercepted by the run-time.
// Since our pass runs after everyone else, the calls should not be
// replaced back with intrinsics. If that becomes wrong at some point,
// we will need to call e.g. __csi_memset to avoid the intrinsics.
bool CSIImpl::instrumentMemIntrinsic(Instruction *I) {
  IRBuilder<> IRB(I);
  if (MemSetInst *M = dyn_cast<MemSetInst>(I)) {
    Instruction *Call = IRB.CreateCall(
        MemsetFn,
        {IRB.CreatePointerCast(M->getArgOperand(0), IRB.getInt8PtrTy()),
         IRB.CreateIntCast(M->getArgOperand(1), IRB.getInt32Ty(), false),
         IRB.CreateIntCast(M->getArgOperand(2), IntptrTy, false)});
    setInstrumentationDebugLoc(I, Call);
    I->eraseFromParent();
    return true;
  } else if (MemTransferInst *M = dyn_cast<MemTransferInst>(I)) {
    Instruction *Call = IRB.CreateCall(
        isa<MemCpyInst>(M) ? MemcpyFn : MemmoveFn,
        {IRB.CreatePointerCast(M->getArgOperand(0), IRB.getInt8PtrTy()),
         IRB.CreatePointerCast(M->getArgOperand(1), IRB.getInt8PtrTy()),
         IRB.CreateIntCast(M->getArgOperand(2), IntptrTy, false)});
    setInstrumentationDebugLoc(I, Call);
    I->eraseFromParent();
    return true;
  }
  return false;
}

void CSIImpl::instrumentBasicBlock(BasicBlock &BB) {
  IRBuilder<> IRB(&*BB.getFirstInsertionPt());
  csi_id_t LocalId = BasicBlockFED.add(BB);
  csi_id_t BBSizeId = BBSize.add(BB);
  assert(LocalId == BBSizeId &&
         "BB recieved different ID's in FED and sizeinfo tables.");
  Value *CsiId = BasicBlockFED.localToGlobalId(LocalId, IRB);
  CsiBBProperty Prop;
  Prop.setIsLandingPad(BB.isLandingPad());
  Prop.setIsEHPad(BB.isEHPad());
  TerminatorInst *TI = BB.getTerminator();
  Value *PropVal = Prop.getValue(IRB);
  insertHookCall(&*IRB.GetInsertPoint(), CsiBBEntry, {CsiId, PropVal});
  IRB.SetInsertPoint(TI);
  insertHookCall(TI, CsiBBExit, {CsiId, PropVal});
}

void CSIImpl::assignCallsiteID(Instruction *I) {
  Function *Called = nullptr;
  if (CallInst *CI = dyn_cast<CallInst>(I))
    Called = CI->getCalledFunction();
  else if (InvokeInst *II = dyn_cast<InvokeInst>(I))
    Called = II->getCalledFunction();
  /*csi_id_t LocalId =*/CallsiteFED.add(*I, Called ? Called->getName() : "");
}

CSIImpl::CSIBuiltinFuncOp CSIImpl::getBuiltinFuncOp(CallSite &CS) {
  const Function *F = CS.getCalledFunction();
  switch (F->getIntrinsicID()) {
  default: break;
  case Intrinsic::fma:
  case Intrinsic::fmuladd:
    return CSIBuiltinFuncOp::F_Fma;
  case Intrinsic::sqrt:
    return CSIBuiltinFuncOp::F_Sqrt;
  case Intrinsic::sin:
    return CSIBuiltinFuncOp::F_Sin;
  case Intrinsic::cos:
    return CSIBuiltinFuncOp::F_Cos;
  case Intrinsic::log:
    return CSIBuiltinFuncOp::F_Log;
  case Intrinsic::log10:
    return CSIBuiltinFuncOp::F_Log10;
  case Intrinsic::log2:
    return CSIBuiltinFuncOp::F_Log2;
  case Intrinsic::exp:
    return CSIBuiltinFuncOp::F_Exp;
  case Intrinsic::exp2:
    return CSIBuiltinFuncOp::F_Exp2;
  case Intrinsic::fabs:
    return CSIBuiltinFuncOp::F_Fabs;
  case Intrinsic::floor:
    return CSIBuiltinFuncOp::F_Floor;
  case Intrinsic::ceil:
    return CSIBuiltinFuncOp::F_Ceil;
  case Intrinsic::trunc:
    return CSIBuiltinFuncOp::F_Trunc;
  case Intrinsic::rint:
    return CSIBuiltinFuncOp::F_Rint;
  case Intrinsic::nearbyint:
    return CSIBuiltinFuncOp::F_NearbyInt;
  case Intrinsic::round:
    return CSIBuiltinFuncOp::F_Round;
  case Intrinsic::canonicalize:
    return CSIBuiltinFuncOp::F_Canonicalize;
  case Intrinsic::pow:
  case Intrinsic::powi:
    return CSIBuiltinFuncOp::F_Pow;
  case Intrinsic::copysign:
    return CSIBuiltinFuncOp::F_CopySign;
  case Intrinsic::minnum:
    return CSIBuiltinFuncOp::F_MinNum;
  case Intrinsic::maxnum:
    return CSIBuiltinFuncOp::F_MaxNum;
  }

  // Called function is not an intrinsic.  Try to handle it as a library call.
  LibFunc Func;
  if (!TLI || !TLI->getLibFunc(*F, Func))
    return CSIBuiltinFuncOp::LAST_CSIBuiltinFuncOp;

  // TODO: Handle frexp, frexpf, modf, modff
  switch (Func) {
  case LibFunc_log:
  case LibFunc_log_finite:
  case LibFunc_logf:
  case LibFunc_logf_finite:
    return CSIBuiltinFuncOp::F_Log;
  case LibFunc_log2:
  case LibFunc_log2_finite:
  case LibFunc_log2f:
  case LibFunc_log2f_finite:
    return CSIBuiltinFuncOp::F_Log2;
  case LibFunc_logb:
  case LibFunc_logbf:
    return CSIBuiltinFuncOp::F_Logb;
  case LibFunc_log10:
  case LibFunc_log10_finite:
  case LibFunc_log10f:
  case LibFunc_log10f_finite:
    return CSIBuiltinFuncOp::F_Log10;
  case LibFunc_log1p:
  case LibFunc_log1pf:
    return CSIBuiltinFuncOp::F_Log1p;
  case LibFunc_exp:
  case LibFunc_exp_finite:
  case LibFunc_expf:
  case LibFunc_expf_finite:
    return CSIBuiltinFuncOp::F_Exp;
  case LibFunc_exp2:
  case LibFunc_exp2_finite:
  case LibFunc_exp2f:
  case LibFunc_exp2f_finite:
    return CSIBuiltinFuncOp::F_Exp2;
  case LibFunc_exp10:
  case LibFunc_exp10_finite:
  case LibFunc_exp10f:
  case LibFunc_exp10f_finite:
    return CSIBuiltinFuncOp::F_Exp10;
  case LibFunc_expm1:
  case LibFunc_expm1f:
    return CSIBuiltinFuncOp::F_Expm1;
  case LibFunc_sin:
  case LibFunc_sinf:
    return CSIBuiltinFuncOp::F_Sin;
  case LibFunc_cos:
  case LibFunc_cosf:
    return CSIBuiltinFuncOp::F_Cos;
  case LibFunc_sinpi:
  case LibFunc_sinpif:
    return CSIBuiltinFuncOp::F_SinPi;
  case LibFunc_cospi:
  case LibFunc_cospif:
    return CSIBuiltinFuncOp::F_CosPi;
  case LibFunc_sincospi_stret:
  case LibFunc_sincospif_stret:
    return CSIBuiltinFuncOp::F_SinCosPi;
  case LibFunc_tan:
  case LibFunc_tanf:
    return CSIBuiltinFuncOp::F_Tan;
  case LibFunc_asin:
  case LibFunc_asin_finite:
  case LibFunc_asinf:
  case LibFunc_asinf_finite:
    return CSIBuiltinFuncOp::F_ASin;
  case LibFunc_acos:
  case LibFunc_acos_finite:
  case LibFunc_acosf:
  case LibFunc_acosf_finite:
    return CSIBuiltinFuncOp::F_ACos;
  case LibFunc_atan:
  case LibFunc_atanf:
    return CSIBuiltinFuncOp::F_ATan;
  case LibFunc_sinh:
  case LibFunc_sinh_finite:
  case LibFunc_sinhf:
  case LibFunc_sinhf_finite:
    return CSIBuiltinFuncOp::F_Sinh;
  case LibFunc_cosh:
  case LibFunc_cosh_finite:
  case LibFunc_coshf:
  case LibFunc_coshf_finite:
    return CSIBuiltinFuncOp::F_Cosh;
  case LibFunc_tanh:
  case LibFunc_tanhf:
    return CSIBuiltinFuncOp::F_Tanh;
  case LibFunc_asinh:
  case LibFunc_asinhf:
    return CSIBuiltinFuncOp::F_ASinh;
  case LibFunc_acosh:
  case LibFunc_acosh_finite:
  case LibFunc_acoshf:
  case LibFunc_acoshf_finite:
    return CSIBuiltinFuncOp::F_ACosh;
  case LibFunc_atanh:
  case LibFunc_atanh_finite:
  case LibFunc_atanhf:
  case LibFunc_atanhf_finite:
    return CSIBuiltinFuncOp::F_ATanh;
  case LibFunc_sqrt:
  case LibFunc_sqrt_finite:
  case LibFunc_sqrtf:
  case LibFunc_sqrtf_finite:
    return CSIBuiltinFuncOp::F_Sqrt;
  case LibFunc_cbrt:
  case LibFunc_cbrtf:
    return CSIBuiltinFuncOp::F_Cbrt;
  case LibFunc_ceil:
  case LibFunc_ceilf:
    return CSIBuiltinFuncOp::F_Ceil;
  case LibFunc_fabs:
  case LibFunc_fabsf:
    return CSIBuiltinFuncOp::F_Fabs;
  case LibFunc_floor:
  case LibFunc_floorf:
    return CSIBuiltinFuncOp::F_Floor;
  case LibFunc_nearbyint:
  case LibFunc_nearbyintf:
    return CSIBuiltinFuncOp::F_NearbyInt;
  case LibFunc_rint:
  case LibFunc_rintf:
    return CSIBuiltinFuncOp::F_Rint;
  case LibFunc_round:
  case LibFunc_roundf:
    return CSIBuiltinFuncOp::F_Round;
  case LibFunc_trunc:
  case LibFunc_truncf:
    return CSIBuiltinFuncOp::F_Trunc;
  case LibFunc_atan2:
  case LibFunc_atan2_finite:
  case LibFunc_atan2f:
  case LibFunc_atan2f_finite:
    return CSIBuiltinFuncOp::F_ATan2;
  case LibFunc_copysign:
  case LibFunc_copysignf:
    return CSIBuiltinFuncOp::F_CopySign;
  case LibFunc_pow:
  case LibFunc_pow_finite:
  case LibFunc_powf:
  case LibFunc_powf_finite:
    return CSIBuiltinFuncOp::F_Pow;
  case LibFunc_fmod:
  case LibFunc_fmodf:
    return CSIBuiltinFuncOp::F_Fmod;
  case LibFunc_fmin:
  case LibFunc_fminf:
    return CSIBuiltinFuncOp::F_MinNum;
  case LibFunc_fmax:
  case LibFunc_fmaxf:
    return CSIBuiltinFuncOp::F_MaxNum;
  case LibFunc_ldexp:
  case LibFunc_ldexpf:
    return CSIBuiltinFuncOp::F_Ldexp;
  default: break;
  }

  return CSIBuiltinFuncOp::LAST_CSIBuiltinFuncOp;
}

bool CSIImpl::handleFPBuiltinCall(CallInst *I, Function *F) {
  CallSite CS(I);

  CSIBuiltinFuncOp Op = getBuiltinFuncOp(CS);
  if (CSIBuiltinFuncOp::LAST_CSIBuiltinFuncOp == Op)
    // Unrecognized builtin; just instrument it like any other call.
    return false;

  IRBuilder<> IRB(I);
  csi_id_t LocalId = CallsiteFED.lookupId(I);
  Type *Ty = F->getReturnType();
  if (CS.getNumArgOperands() == 1) {
    Value *Operand = CS.getArgOperand(0);
    Function *BeforeHook = nullptr, *AfterHook = nullptr;
    // Determine the correct hooks to use
    if (Ty->isFloatTy()) {
      if (!Operand->getType()->isFloatTy())
        return false;
      BeforeHook = CsiBeforeBuiltinFF;
      AfterHook = CsiAfterBuiltinFF;
    } else if (Ty->isDoubleTy()) {
      if (!Operand->getType()->isDoubleTy())
        return false;
      BeforeHook = CsiBeforeBuiltinDD;
      AfterHook = CsiAfterBuiltinDD;
    } else {
      return false;
    }
    // Emit the hooks
    Value *CallsiteId = CallsiteFED.localToGlobalId(LocalId, IRB);
    Value *OpArg = IRB.getInt8(static_cast<unsigned>(Op));
    std::pair<Value *, Value *> OperandID = getOperandID(Operand, IRB);
    insertHookCall(I, BeforeHook, {CallsiteId, OpArg, OperandID.first,
                                   OperandID.second, Operand});

    BasicBlock::iterator Iter(I);
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    insertHookCall(&*Iter, AfterHook, {CallsiteId, OpArg, OperandID.first,
                                       OperandID.second, Operand});
    return true;
  } else if (CS.getNumArgOperands() == 2) {
    Value *Operand0 = CS.getArgOperand(0);
    Value *Operand1 = CS.getArgOperand(1);
    // Determine the correct hooks to use
    Function *BeforeHook = nullptr, *AfterHook = nullptr;
    if (Ty->isFloatTy()) {
      if (!Operand0->getType()->isFloatTy())
        return false;
      if (Operand1->getType()->isIntegerTy()) {
        BeforeHook = CsiBeforeBuiltinFFI;
        AfterHook = CsiAfterBuiltinFFI;
      } else if (Operand1->getType()->isFloatTy()) {
        BeforeHook = CsiBeforeBuiltinFFF;
        AfterHook = CsiAfterBuiltinFFF;
      } else {
        return false;
      }
    } else if (Ty->isDoubleTy()) {
      if (!Operand0->getType()->isDoubleTy())
        return false;
      if (Operand1->getType()->isIntegerTy()) {
        BeforeHook = CsiBeforeBuiltinDDI;
        AfterHook = CsiAfterBuiltinDDI;
      } else if (Operand1->getType()->isFloatTy()) {
        BeforeHook = CsiBeforeBuiltinDDD;
        AfterHook = CsiAfterBuiltinDDD;
      } else {
        return false;
      }
    }
    // Emit the hooks
    Value *CallsiteId = CallsiteFED.localToGlobalId(LocalId, IRB);
    Value *OpArg = IRB.getInt8(static_cast<unsigned>(Op));
    std::pair<Value *, Value *> Operand0ID = getOperandID(Operand0, IRB);
    std::pair<Value *, Value *> Operand1ID = getOperandID(Operand1, IRB);
    insertHookCall(I, BeforeHook, {CallsiteId, OpArg, Operand0ID.first,
                                   Operand0ID.second, Operand0,
                                   Operand1ID.first, Operand1ID.second,
                                   Operand1});
    BasicBlock::iterator Iter(I);
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    insertHookCall(&*Iter, AfterHook, {CallsiteId, OpArg, Operand0ID.first,
                                       Operand0ID.second, Operand0,
                                       Operand1ID.first, Operand1ID.second,
                                       Operand1});
    return true;
  } else {
    if (CS.getNumArgOperands() != 3)
      return false;
    Value *Operand0 = CS.getArgOperand(0);
    Value *Operand1 = CS.getArgOperand(1);
    Value *Operand2 = CS.getArgOperand(2);
    // Determine the correct hooks to use
    Function *BeforeHook = nullptr, *AfterHook = nullptr;
    if (Ty->isFloatTy()) {
      if (!Operand0->getType()->isFloatTy() ||
          !Operand1->getType()->isFloatTy() ||
          !Operand2->getType()->isFloatTy())
        return false;
      BeforeHook = CsiBeforeBuiltinFFFF;
      AfterHook = CsiAfterBuiltinFFFF;
    } else if (Ty->isDoubleTy()) {
      if (!Operand0->getType()->isDoubleTy() ||
          !Operand1->getType()->isDoubleTy() ||
          !Operand2->getType()->isDoubleTy())
        return false;
      BeforeHook = CsiBeforeBuiltinDDDD;
      AfterHook = CsiAfterBuiltinDDDD;
    }

    Value *CallsiteId = CallsiteFED.localToGlobalId(LocalId, IRB);
    Value *OpArg = IRB.getInt8(static_cast<unsigned>(Op));
    std::pair<Value *, Value *> Operand0ID = getOperandID(Operand0, IRB);
    std::pair<Value *, Value *> Operand1ID = getOperandID(Operand1, IRB);
    std::pair<Value *, Value *> Operand2ID = getOperandID(Operand2, IRB);
    insertHookCall(I, BeforeHook, {CallsiteId, OpArg, Operand0ID.first,
                                   Operand0ID.second, Operand0,
                                   Operand1ID.first, Operand1ID.second,
                                   Operand1, Operand2ID.first,
                                   Operand2ID.second, Operand2});
    BasicBlock::iterator Iter(I);
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    insertHookCall(&*Iter, AfterHook, {CallsiteId, OpArg, Operand0ID.first,
                                       Operand0ID.second, Operand0,
                                       Operand1ID.first, Operand1ID.second,
                                       Operand1, Operand2ID.first,
                                       Operand2ID.second, Operand2});
    return true;
  }
  return false;
}

void CSIImpl::instrumentCallsite(Instruction *I, DominatorTree *DT) {
  if (callsPlaceholderFunction(*I))
    return;

  bool IsInvoke = isa<InvokeInst>(I);
  Function *Called = nullptr;
  unsigned NumArgs = 0;
  if (CallInst *CI = dyn_cast<CallInst>(I)) {
    Called = CI->getCalledFunction();
    NumArgs = CI->getNumArgOperands();
  } else if (InvokeInst *II = dyn_cast<InvokeInst>(I)) {
    Called = II->getCalledFunction();
    NumArgs = II->getNumArgOperands();
  }

  // Handle calls to builtins
  if (!IsInvoke && Called &&
      handleFPBuiltinCall(cast<CallInst>(I), Called))
    return;

  bool shouldInstrumentBefore = true;
  bool shouldInstrumentAfter = true;

  // Does this call require instrumentation before or after?
  if (Called) {
    shouldInstrumentBefore = Config->DoesFunctionRequireInstrumentationForPoint(
        Called->getName(), InstrumentationPoint::INSTR_BEFORE_CALL);
    shouldInstrumentAfter = Config->DoesFunctionRequireInstrumentationForPoint(
        Called->getName(), InstrumentationPoint::INSTR_AFTER_CALL);
  }

  if (!shouldInstrumentAfter && !shouldInstrumentBefore)
    return;

  IRBuilder<> IRB(I);
  // Get the CSI ID of this callsite, along with a default value for handling
  // invokes.
  Value *DefaultID = getDefaultID(IRB);
  csi_id_t LocalId = CallsiteFED.lookupId(I);
  Value *CallsiteId = CallsiteFED.localToGlobalId(LocalId, IRB);

  // Get the CSI ID of the called function.
  Value *FuncId = nullptr;
  GlobalVariable *FuncIdGV = nullptr;
  if (Called) {
    // Because we're calling this function, we must ensure that the CSI global
    // storing the CSI ID of the callee is available.  Create the CSI global in
    // this module if necessary.
    std::string GVName = CsiFuncIdVariablePrefix + Called->getName().str();
    FuncIdGV = dyn_cast<GlobalVariable>(M.getOrInsertGlobal(GVName,
                                                            IRB.getInt64Ty()));
    assert(FuncIdGV);
    FuncIdGV->setConstant(false);
    FuncIdGV->setLinkage(GlobalValue::WeakAnyLinkage);
    FuncIdGV->setInitializer(IRB.getInt64(CsiCallsiteUnknownTargetId));
    FuncId = IRB.CreateLoad(FuncIdGV);
  } else {
    // Unknown targets (i.e. indirect calls) are always unknown.
    FuncId = IRB.getInt64(CsiCallsiteUnknownTargetId);
  }
  assert(FuncId != NULL);
  Type *OperandIDType = StructType::get(IRB.getInt8Ty(), IRB.getInt64Ty());
  // Save the stack for proper deallocation of this allocated array later.
  Value *StackAddr = IRB.CreateCall(
      Intrinsic::getDeclaration(&M, Intrinsic::stacksave));
  // Create an array to store operand ID information for the call.
  AllocaInst *ArgArray = IRB.CreateAlloca(OperandIDType, IRB.getInt32(NumArgs));
  IRB.CreateLifetimeStart(
      ArgArray, IRB.getInt64(DL.getTypeAllocSize(
                                 ArgArray->getAllocatedType()) * NumArgs));

  // Store operand ID information into the array.
  if (CallInst *CI = dyn_cast<CallInst>(I)) {
    unsigned ArgNum = 0;
    for (Value *Operand : CI->arg_operands()) {
      std::pair<Value *, Value *> OperandID = getOperandID(Operand, IRB);
      IRB.CreateStore(OperandID.first,
                      IRB.CreateInBoundsGEP(ArgArray, {IRB.getInt32(ArgNum),
                                                       IRB.getInt32(0)}));
      IRB.CreateStore(OperandID.second,
                      IRB.CreateInBoundsGEP(ArgArray, {IRB.getInt32(ArgNum),
                                                       IRB.getInt32(1)}));
      ArgNum++;
    }
  } else if (InvokeInst *II = dyn_cast<InvokeInst>(I)) {
    unsigned ArgNum = 0;
    for (Value *Operand : II->arg_operands()) {
      std::pair<Value *, Value *> OperandID = getOperandID(Operand, IRB);
      IRB.CreateStore(OperandID.first,
                      IRB.CreateInBoundsGEP(ArgArray, {IRB.getInt32(ArgNum),
                                                       IRB.getInt32(0)}));
      IRB.CreateStore(OperandID.second,
                      IRB.CreateInBoundsGEP(ArgArray, {IRB.getInt32(ArgNum),
                                                       IRB.getInt32(1)}));
      ArgNum++;
    }
  }

  // Get properties of this call.
  CsiCallProperty Prop;
  Value *DefaultPropVal = Prop.getValue(IRB);
  Prop.setIsIndirect(!Called);
  Value *PropVal = Prop.getValue(IRB);

  // Instrument the call
  if (shouldInstrumentBefore)
    insertHookCall(I, CsiBeforeCallsite, {CallsiteId, FuncId, ArgArray,
                                          IRB.getInt32(NumArgs), PropVal});
  // Clean up the array of operand args
  IRB.CreateLifetimeEnd(
      ArgArray, IRB.getInt64(DL.getTypeAllocSize(
                                 ArgArray->getAllocatedType()) * NumArgs));
  IRB.CreateCall(Intrinsic::getDeclaration(&M, Intrinsic::stackrestore),
                 {StackAddr});

  BasicBlock::iterator Iter(I);
  if (shouldInstrumentAfter) {
    if (IsInvoke) {
      // There are two "after" positions for invokes: the normal block and the
      // exception block.
      InvokeInst *II = cast<InvokeInst>(I);
      insertHookCallInSuccessorBB(II, II->getNormalDest(), II->getParent(),
                                  CsiAfterCallsite,
                                  {CallsiteId, FuncId, PropVal},
                                  {DefaultID, DefaultID, DefaultPropVal});
      insertHookCallInSuccessorBB(II, II->getUnwindDest(), II->getParent(),
                                  CsiAfterCallsite,
                                  {CallsiteId, FuncId, PropVal},
                                  {DefaultID, DefaultID, DefaultPropVal});
    } else {
      // Simple call instruction; there is only one "after" position.
      Iter++;
      IRB.SetInsertPoint(&*Iter);
      PropVal = Prop.getValue(IRB);
      insertHookCall(&*Iter, CsiAfterCallsite, {CallsiteId, FuncId, PropVal});
    }
  }
}

void CSIImpl::interposeCall(Instruction *I) {

  Function *Called = nullptr;
  if (CallInst *CI = dyn_cast<CallInst>(I))
    Called = CI->getCalledFunction();
  else if (InvokeInst *II = dyn_cast<InvokeInst>(I))
    Called = II->getCalledFunction();

  // Should we interpose this call?
  if (Called && Called->getName().size() > 0) {
    bool shouldInterpose =
        Config->DoesFunctionRequireInterposition(Called->getName());

    if (shouldInterpose) {
      Function *interpositionFunction = getInterpositionFunction(Called);
      assert(interpositionFunction != nullptr);
      if (CallInst *CI = dyn_cast<CallInst>(I)) {
        CI->setCalledFunction(interpositionFunction);
      } else if (InvokeInst *II = dyn_cast<InvokeInst>(I)) {
        II->setCalledFunction(interpositionFunction);
      }
    }
  }
}

static void getTaskExits(DetachInst *DI,
                         SmallVectorImpl<BasicBlock *> &TaskReturns,
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
                       [](const Spindle *Pred) { return !Pred->isSharedEH(); }))
        SharedEHExits.push_back(S);
      continue;
    }

    for (BasicBlock *B : S->blocks())
      if (isDetachedRethrow(B->getTerminator()))
        TaskResumes.push_back(B);
  }
}

void CSIImpl::instrumentDetach(DetachInst *DI, DominatorTree *DT, TaskInfo &TI,
                               const DenseMap<Value *, Value *> &TrackVars) {
  // Instrument the detach instruction itself
  Value *DetachID;
  {
    IRBuilder<> IRB(DI);
    csi_id_t LocalID = DetachFED.add(*DI);
    DetachID = DetachFED.localToGlobalId(LocalID, IRB);
    Value *TrackVar = TrackVars.lookup(DI->getSyncRegion());
    // TODO? Rather than use TrackVars to record the boolean of whether or not a
    // detach in this sync region has happened, we can count the number of such
    // detaches.
    IRB.CreateStore(
        Constant::getIntegerValue(IntegerType::getInt32Ty(DI->getContext()),
                                  APInt(32, 1)),
        TrackVar);
    insertHookCall(DI, CsiDetach, {DetachID, TrackVar});
  }

  // Find the detached block, continuation, and associated reattaches.
  BasicBlock *DetachedBlock = DI->getDetached();
  BasicBlock *ContinueBlock = DI->getContinue();
  SmallVector<BasicBlock *, 8> TaskExits, TaskResumes;
  SmallVector<Spindle *, 2> SharedEHExits;
  getTaskExits(DI, TaskExits, TaskResumes, SharedEHExits, TI);

  // Instrument the entry and exit points of the detached task.
  {
    // Instrument the entry point of the detached task.
    IRBuilder<> IRB(&*DetachedBlock->getFirstInsertionPt());
    csi_id_t LocalID = TaskFED.add(*DetachedBlock);
    Value *TaskID = TaskFED.localToGlobalId(LocalID, IRB);
    // Value *StackSave = IRB.CreateCall(
    //     Intrinsic::getDeclaration(&M, Intrinsic::stacksave));
    Instruction *Call = IRB.CreateCall(CsiTaskEntry, {TaskID, DetachID});
    setInstrumentationDebugLoc(*DetachedBlock, Call);

    // Instrument the exit points of the detached tasks.
    for (BasicBlock *Exit : TaskExits) {
      IRBuilder<> IRB(Exit->getTerminator());
      csi_id_t LocalID = TaskExitFED.add(*Exit->getTerminator());
      Value *ExitID = TaskExitFED.localToGlobalId(LocalID, IRB);
      insertHookCall(Exit->getTerminator(), CsiTaskExit,
                     {ExitID, TaskID, DetachID});
    }
    // Instrument the EH exits of the detached task.
    for (BasicBlock *Exit : TaskResumes) {
      IRBuilder<> IRB(Exit->getTerminator());
      csi_id_t LocalID = TaskExitFED.add(*Exit->getTerminator());
      Value *ExitID = TaskExitFED.localToGlobalId(LocalID, IRB);
      insertHookCall(Exit->getTerminator(), CsiTaskExit,
                     {ExitID, TaskID, DetachID});
    }

    Task *T = TI.getTaskFor(DetachedBlock);
    Value *DefaultID = getDefaultID(IRB);
    for (Spindle *SharedEH : SharedEHExits)
      insertHookCallAtSharedEHSpindleExits(DI, SharedEH, T, CsiTaskExit,
                                           TaskExitFED, {TaskID, DetachID},
                                           {DefaultID, DefaultID});
  }

  // Instrument the continuation of the detach.
  {
    if (isCriticalContinueEdge(DI, 1))
      ContinueBlock = SplitCriticalEdge(
          DI, 1, CriticalEdgeSplittingOptions(DT).setSplitDetachContinue());

    IRBuilder<> IRB(&*ContinueBlock->getFirstInsertionPt());
    csi_id_t LocalID = DetachContinueFED.add(*ContinueBlock);
    Value *ContinueID = DetachContinueFED.localToGlobalId(LocalID, IRB);
    Instruction *Call =
        IRB.CreateCall(CsiDetachContinue, {ContinueID, DetachID});
    setInstrumentationDebugLoc(*ContinueBlock, Call);
  }
  // Instrument the unwind of the detach, if it exists.
  if (DI->hasUnwindDest()) {
    BasicBlock *UnwindBlock = DI->getUnwindDest();
    IRBuilder<> IRB(DI);
    Value *DefaultID = getDefaultID(IRB);
    csi_id_t LocalID = DetachContinueFED.add(*UnwindBlock);
    Value *ContinueID = DetachContinueFED.localToGlobalId(LocalID, IRB);
    insertHookCallInSuccessorBB(DI, UnwindBlock, DI->getParent(),
                                CsiDetachContinue,
                                {ContinueID, DetachID}, {DefaultID, DefaultID});
  }
}

void CSIImpl::instrumentSync(SyncInst *SI,
                             const DenseMap<Value *, Value *> &TrackVars) {
  IRBuilder<> IRB(SI);
  Value *DefaultID = getDefaultID(IRB);
  // Get the ID of this sync.
  csi_id_t LocalID = SyncFED.add(*SI);
  Value *SyncID = SyncFED.localToGlobalId(LocalID, IRB);

  Value *TrackVar = TrackVars.lookup(SI->getSyncRegion());

  // Insert instrumentation before the sync.
  insertHookCall(SI, CsiBeforeSync, {SyncID, TrackVar});
  CallInst *call = insertHookCallInSuccessorBB(
      SI, SI->getSuccessor(0), SI->getParent(), CsiAfterSync,
      {SyncID, TrackVar},
      {DefaultID,
       ConstantPointerNull::get(
           IntegerType::getInt32Ty(SI->getContext())->getPointerTo())});

  // Reset the tracking variable to 0.
  if (call != nullptr) {
    callsAfterSync.insert({SI->getSuccessor(0), call});
    IRB.SetInsertPoint(call->getNextNode());
    IRB.CreateStore(
        Constant::getIntegerValue(IntegerType::getInt32Ty(SI->getContext()),
                                  APInt(32, 0)),
        TrackVar);
  } else {
    assert(callsAfterSync.find(SI->getSuccessor(0)) != callsAfterSync.end());
  }
}

void CSIImpl::assignArithmeticID(Instruction *I) {
  /*csi_id_t LocalId =*/ArithmeticFED.add(*I);
}

void CSIImpl::instrumentArithmetic(Instruction *I) {
  IRBuilder<> IRB(I);
  // We have to make sure not to disrupt the block of PHIs in the block.
  if (isa<PHINode>(I))
    IRB.SetInsertPoint(&*I->getParent()->getFirstInsertionPt());

  if (!ArithmeticFED.hasId(I))
    llvm_unreachable("Missing local ID for arithmetic instruction");

  csi_id_t LocalId = ArithmeticFED.lookupId(I);
  Value *CsiId = ArithmeticFED.localToGlobalId(LocalId, IRB);
  CsiArithmeticFlags Flags;

  if (BinaryOperator *BO = dyn_cast<BinaryOperator>(I)) {
    // Value *Opcode = ConstantInt::get(IRB.getInt8Ty(), BO->getOpcode());
    Value *Opcode = getOpcodeID(BO->getOpcode(), IRB);
    Value *Operand0 = BO->getOperand(0);
    Value *Operand1 = BO->getOperand(1);
    std::pair<Value *, Value *> Operand0ID = getOperandID(Operand0, IRB);
    std::pair<Value *, Value *> Operand1ID = getOperandID(Operand1, IRB);
    Type *OpTy = BO->getType();
    Type *OperandCastTy = OpTy;
    Function *ArithmeticHook = nullptr;
    switch (OpTy->getTypeID()) {
    // case Type::HalfTyID:
    //   ArithmeticHook = CsiBeforeArithmeticH;
    //   break;
    case Type::FloatTyID:
      ArithmeticHook = CsiBeforeArithmeticF;
      break;
    case Type::DoubleTyID:
      ArithmeticHook = CsiBeforeArithmeticD;
      break;
    case Type::IntegerTyID: {
      unsigned Width = OpTy->getIntegerBitWidth();
      if (Width <= 8) {
        ArithmeticHook = CsiBeforeArithmeticI8;
        OperandCastTy = IRB.getInt8Ty();
      } else if (Width <= 16) {
        ArithmeticHook = CsiBeforeArithmeticI16;
        OperandCastTy = IRB.getInt16Ty();
      } else if (Width <= 32) {
        ArithmeticHook = CsiBeforeArithmeticI32;
        OperandCastTy = IRB.getInt32Ty();
      } else if (Width <= 64) {
        ArithmeticHook = CsiBeforeArithmeticI64;
        OperandCastTy = IRB.getInt64Ty();
      } else { // Assume width == 128
        ArithmeticHook = CsiBeforeArithmeticI128;
        OperandCastTy = IRB.getInt128Ty();
      }
      break;
    }
    default:
      dbgs() << "Uninstrumented binary operator " << *BO << "\n";
      break;
    }
    // Exit early if we don't have a hook for this op.
    if (!ArithmeticHook)
      return;
    Value *CastOperand0 = Operand0;
    Value *CastOperand1 = Operand1;
    if (OpTy->isIntegerTy()) {
      CastOperand0 = IRB.CreateZExtOrBitCast(Operand0, OperandCastTy);
      CastOperand1 = IRB.CreateZExtOrBitCast(Operand1, OperandCastTy);
    }
    Flags.copyIRFlags(BO);
    Value *FlagsVal = Flags.getValue(IRB);
    insertHookCall(I, ArithmeticHook,
                   {CsiId, Opcode, Operand0ID.first, Operand0ID.second,
                    CastOperand0, Operand1ID.first, Operand1ID.second,
                    CastOperand1, FlagsVal});
    // TODO: Insert CsiAfterArithmetic hooks
    // BasicBlock::iterator Iter(I);
    // Iter++;
    // IRB.SetInsertPoint(&*Iter);

    // Type *AddrType = IRB.getInt8PtrTy();
    // insertHookCall(&*Iter, CsiAfterArithmetic, {CsiId, });
  } else if (TruncInst *TI = dyn_cast<TruncInst>(I)) {

  } else if (FPTruncInst *TI = dyn_cast<FPTruncInst>(I)) {
    Value *Operand = TI->getOperand(0);
    std::pair<Value *, Value *> OperandID = getOperandID(Operand, IRB);

    Type *OpTy = TI->getType();
    if (OpTy->isVectorTy()) {
      dbgs() << "Uninstrumented operation " << *TI << "\n";
      return;
    }
    Type *OperandTy = Operand->getType();
    Function *ArithmeticHook = nullptr;
    switch (OperandTy->getTypeID()) {
    case Type::DoubleTyID:
      switch (OpTy->getTypeID()) {
      case Type::FloatTyID:
        ArithmeticHook = CsiBeforeTruncateDF;
        break;
      // case Type::HalfTyID:
      //   ArithmeticHook = CsiBeforeTruncateDH;
      //   break;
      default:
        llvm_unreachable("Invalid FPTrunc types?");
        break;
      }
      break;
    case Type::FloatTyID:
      switch (OpTy->getTypeID()) {
      // case Type::HalfTyID:
      //   ArithmeticHook = CsiBeforeTruncateFH;
      //   break;
      default:
        // llvm_unreachable("Invalid FPTrunc types?");
        break;
      }
      break;
    default:
      // llvm_unreachable("Invalid FPTrunc types?");
      break;
    }
    if (!ArithmeticHook) {
      dbgs() << "Uninstrumented operation " << *TI << "\n";
      return;
    }
    insertHookCall(I, ArithmeticHook, {CsiId, OperandID.first, OperandID.second,
                                       Operand});
  } else if (ZExtInst *EI = dyn_cast<ZExtInst>(I)) {

  } else if (SExtInst *EI = dyn_cast<SExtInst>(I)) {

  } else if (FPExtInst *EI = dyn_cast<FPExtInst>(I)) {
    Value *Operand = EI->getOperand(0);
    std::pair<Value *, Value *> OperandID = getOperandID(Operand, IRB);

    Type *OpTy = EI->getType();
    if (OpTy->isVectorTy()) {
      dbgs() << "Uninstrumented operation " << *EI << "\n";
      return;
    }

    Type *OperandTy = Operand->getType();
    Function *ArithmeticHook = nullptr;
    switch (OperandTy->getTypeID()) {
    // case Type::HalfTyID:
    //   switch (OpTy->getTypeID()) {
    //   case Type::FloatTyID:
    //     ArithmeticHook = CsiBeforeExtendHF;
    //     break;
    //   case Type::DoubleTyID:
    //     ArithmeticHook = CsiBeforeExtendHD;
    //     break;
    //   default:
    //     llvm_unreachable("Invalid FPExt types?");
    //     break;
    //   }
    //   break;
    case Type::FloatTyID:
      switch (OpTy->getTypeID()) {
      case Type::DoubleTyID:
        ArithmeticHook = CsiBeforeExtendFD;
        break;
      default:
        // llvm_unreachable("Invalid FPExt types?");
        break;
      }
      break;
    default:
      // llvm_unreachable("Invalid FPExt types?");
      break;
    }
    if (!ArithmeticHook) {
      dbgs() << "Uninstrumented operation " << *EI << "\n";
      return;
    }
    insertHookCall(I, ArithmeticHook, {CsiId, OperandID.first, OperandID.second,
                                       Operand});
  } else if (FPToUIInst *CI = dyn_cast<FPToUIInst>(I)) {

  } else if (FPToSIInst *CI = dyn_cast<FPToSIInst>(I)) {

  } else if (UIToFPInst *CI = dyn_cast<UIToFPInst>(I)) {
    Value *Operand = CI->getOperand(0);
    std::pair<Value *, Value *> OperandID = getOperandID(Operand, IRB);
    Type *OpTy = CI->getType();
    Type *OperandTy = Operand->getType();
    if (OpTy->isVectorTy()) {
      dbgs() << "Uninstrumented operation " << *CI << "\n";
      return;
    }
    assert(OperandTy->isIntegerTy() && "Operand of UIToFP is not an int");
    unsigned Width = OperandTy->getIntegerBitWidth();

    Function *ArithmeticHook = nullptr;
    Type *OperandCastTy = nullptr;
    switch (OpTy->getTypeID()) {
    // case Type::HalfTyID:
    //   if (Width <= 8) {
    //     ArithmeticHook = CsiBeforeConvertUI8H;
    //     OperandCastTy = IRB.getInt8Ty();
    //   } else if (Width <= 16) {
    //     ArithmeticHook = CsiBeforeConvertUI16H;
    //     OperandCastTy = IRB.getInt16Ty();
    //   } else if (Width <= 32) {
    //     ArithmeticHook = CsiBeforeConvertUI32H;
    //     OperandCastTy = IRB.getInt32Ty();
    //   } else if (Width <= 64) {
    //     ArithmeticHook = CsiBeforeConvertUI64H;
    //     OperandCastTy = IRB.getInt64Ty();
    //   } else { // Assume width == 128
    //     ArithmeticHook = CsiBeforeConvertUI128H;
    //     OperandCastTy = IRB.getInt128Ty();
    //   }
    //   break;
    case Type::FloatTyID:
      if (Width <= 8) {
        ArithmeticHook = CsiBeforeConvertUI8F;
        OperandCastTy = IRB.getInt8Ty();
      } else if (Width <= 16) {
        ArithmeticHook = CsiBeforeConvertUI16F;
        OperandCastTy = IRB.getInt16Ty();
      } else if (Width <= 32) {
        ArithmeticHook = CsiBeforeConvertUI32F;
        OperandCastTy = IRB.getInt32Ty();
      } else if (Width <= 64) {
        ArithmeticHook = CsiBeforeConvertUI64F;
        OperandCastTy = IRB.getInt64Ty();
      } else { // Assume width == 128
        ArithmeticHook = CsiBeforeConvertUI128F;
        OperandCastTy = IRB.getInt128Ty();
      }
      break;
    case Type::DoubleTyID:
      if (Width <= 8) {
        ArithmeticHook = CsiBeforeConvertUI8D;
        OperandCastTy = IRB.getInt8Ty();
      } else if (Width <= 16) {
        ArithmeticHook = CsiBeforeConvertUI16D;
        OperandCastTy = IRB.getInt16Ty();
      } else if (Width <= 32) {
        ArithmeticHook = CsiBeforeConvertUI32D;
        OperandCastTy = IRB.getInt32Ty();
      } else if (Width <= 64) {
        ArithmeticHook = CsiBeforeConvertUI64D;
        OperandCastTy = IRB.getInt64Ty();
      } else { // Assume width == 128
        ArithmeticHook = CsiBeforeConvertUI128D;
        OperandCastTy = IRB.getInt128Ty();
      }
      break;
    default:
      // llvm_unreachable("Invalid type for UIToFP");
      break;
    }
    if (!ArithmeticHook) {
      dbgs() << "Uninstrumented operation " << *CI << "\n";
      return;
    }

    assert(OperandCastTy && "No type found for operand.");
    Value *CastOperand = IRB.CreateZExtOrBitCast(Operand, OperandCastTy);
    insertHookCall(I, ArithmeticHook, {CsiId, OperandID.first, OperandID.second,
                                       CastOperand});

  } else if (SIToFPInst *CI = dyn_cast<SIToFPInst>(I)) {
    Value *Operand = CI->getOperand(0);
    std::pair<Value *, Value *> OperandID = getOperandID(Operand, IRB);
    Type *OpTy = CI->getType();
    Type *OperandTy = Operand->getType();
    if (OpTy->isVectorTy()) {
      dbgs() << "Uninstrumented operation " << *CI << "\n";
      return;
    }
    assert(OperandTy->isIntegerTy() && "Operand of UIToFP is not an int");
    unsigned Width = OperandTy->getIntegerBitWidth();

    Function *ArithmeticHook = nullptr;
    Type *OperandCastTy = nullptr;
    switch (OpTy->getTypeID()) {
    // case Type::HalfTyID:
    //   if (Width <= 8) {
    //     ArithmeticHook = CsiBeforeConvertSI8H;
    //     OperandCastTy = IRB.getInt8Ty();
    //   } else if (Width <= 16) {
    //     ArithmeticHook = CsiBeforeConvertSI16H;
    //     OperandCastTy = IRB.getInt16Ty();
    //   } else if (Width <= 32) {
    //     ArithmeticHook = CsiBeforeConvertSI32H;
    //     OperandCastTy = IRB.getInt32Ty();
    //   } else if (Width <= 64) {
    //     ArithmeticHook = CsiBeforeConvertSI64H;
    //     OperandCastTy = IRB.getInt64Ty();
    //   } else { // Assume width == 128
    //     ArithmeticHook = CsiBeforeConvertSI128H;
    //     OperandCastTy = IRB.getInt128Ty();
    //   }
    //   break;
    case Type::FloatTyID:
      if (Width <= 8) {
        ArithmeticHook = CsiBeforeConvertSI8F;
        OperandCastTy = IRB.getInt8Ty();
      } else if (Width <= 16) {
        ArithmeticHook = CsiBeforeConvertSI16F;
        OperandCastTy = IRB.getInt16Ty();
      } else if (Width <= 32) {
        ArithmeticHook = CsiBeforeConvertSI32F;
        OperandCastTy = IRB.getInt32Ty();
      } else if (Width <= 64) {
        ArithmeticHook = CsiBeforeConvertSI64F;
        OperandCastTy = IRB.getInt64Ty();
      } else { // Assume width == 128
        ArithmeticHook = CsiBeforeConvertSI128F;
        OperandCastTy = IRB.getInt128Ty();
      }
      break;
    case Type::DoubleTyID:
      if (Width <= 8) {
        ArithmeticHook = CsiBeforeConvertSI8D;
        OperandCastTy = IRB.getInt8Ty();
      } else if (Width <= 16) {
        ArithmeticHook = CsiBeforeConvertSI16D;
        OperandCastTy = IRB.getInt16Ty();
      } else if (Width <= 32) {
        ArithmeticHook = CsiBeforeConvertSI32D;
        OperandCastTy = IRB.getInt32Ty();
      } else if (Width <= 64) {
        ArithmeticHook = CsiBeforeConvertSI64D;
        OperandCastTy = IRB.getInt64Ty();
      } else { // Assume width == 128
        ArithmeticHook = CsiBeforeConvertSI128D;
        OperandCastTy = IRB.getInt128Ty();
      }
      break;
    default:
      // llvm_unreachable("Invalid type for SIToFP");
      break;
    }
    if (!ArithmeticHook) {
      dbgs() << "Uninstrumented operation " << *CI << "\n";
      return;
    }
    assert(OperandCastTy && "No type found for operand.");
    Value *CastOperand = IRB.CreateSExtOrBitCast(Operand, OperandCastTy);
    insertHookCall(I, ArithmeticHook, {CsiId, OperandID.first, OperandID.second,
                                       CastOperand});

  } else if (PHINode *PN = dyn_cast<PHINode>(I)) {
    Type *OpTy = PN->getType();
    Function *CsiPhiHook = nullptr;

    Type *OperandCastTy = OpTy;
    switch (OpTy->getTypeID()) {
      // case Type::HalfTyID:
      //   CsiPhiHook = CsiPhiH;
      //   break;
    case Type::FloatTyID:
      CsiPhiHook = CsiPhiF;
      break;
    case Type::DoubleTyID:
      CsiPhiHook = CsiPhiD;
      break;
    case Type::IntegerTyID: {
      unsigned Width = OpTy->getIntegerBitWidth();
      if (Width <= 8) {
        CsiPhiHook = CsiPhiI8;
        OperandCastTy = IRB.getInt8Ty();
      } else if (Width <= 16) {
        CsiPhiHook = CsiPhiI16;
        OperandCastTy = IRB.getInt16Ty();
      } else if (Width <= 32) {
        CsiPhiHook = CsiPhiI32;
        OperandCastTy = IRB.getInt32Ty();
      } else if (Width <= 64) {
        CsiPhiHook = CsiPhiI64;
        OperandCastTy = IRB.getInt64Ty();
      } else { // Assume width == 128
        CsiPhiHook = CsiPhiI128;
        OperandCastTy = IRB.getInt128Ty();
      }
      break;
    }
    default:
      // TODO: Add support for more types of PHI nodes.
      dbgs() << "Uninstrumented PHI node:" << *PN << "\n";
      break;
    }
    if (CsiPhiHook) {
      PHINode *PHIArgs[2];
      {
        // Make sure these PHI nodes are inserted at the beginning of the block.
        IRBuilder<> ArgB(&PN->getParent()->front());
        // OperandID.first type
        PHIArgs[0] = ArgB.CreatePHI(ArgB.getInt8Ty(), PN->getNumIncomingValues());
        // OperandID.second type
        PHIArgs[1] = ArgB.CreatePHI(ArgB.getInt64Ty(),
                                    PN->getNumIncomingValues());
      }

      for (BasicBlock *Pred : predecessors(PN->getParent())) {
        IRBuilder<> PredB(Pred->getTerminator());
        Value *Operand = PN->getIncomingValueForBlock(Pred);
        std::pair<Value *, Value *> OperandID = getOperandID(Operand, PredB);
        PHIArgs[0]->addIncoming(OperandID.first, Pred);
        PHIArgs[1]->addIncoming(OperandID.second, Pred);
      }

      Value *CastPN = PN;
      if (OperandCastTy != OpTy)
        CastPN = IRB.CreateZExtOrBitCast(PN, OperandCastTy);

      // Don't use insertHookCall for PHI instrumentation, because we must make
      // sure not to disrupt the PHIs in the block.
      CallInst *Call = IRB.CreateCall(CsiPhiHook, {CsiId, PHIArgs[0],
                                                   PHIArgs[1], CastPN});
      setInstrumentationDebugLoc(I, (Instruction *)Call);
    }
  }
}

void CSIImpl::assignAllocaID(Instruction *I) {
  AllocaFED.add(*I);
}

void CSIImpl::instrumentAlloca(Instruction *I) {
  IRBuilder<> IRB(I);
  AllocaInst *AI = cast<AllocaInst>(I);

  csi_id_t LocalId = AllocaFED.lookupId(I);
  Value *CsiId = AllocaFED.localToGlobalId(LocalId, IRB);

  CsiAllocaProperty Prop;
  Prop.setIsStatic(AI->isStaticAlloca());
  Value *PropVal = Prop.getValue(IRB);

  // Get size of allocation.
  uint64_t Size = DL.getTypeAllocSize(AI->getAllocatedType());
  Value *SizeVal = IRB.getInt64(Size);
  if (AI->isArrayAllocation())
    SizeVal = IRB.CreateMul(SizeVal, AI->getArraySize());

  insertHookCall(I, CsiBeforeAlloca, {CsiId, SizeVal, PropVal});
  BasicBlock::iterator Iter(I);
  Iter++;
  IRB.SetInsertPoint(&*Iter);

  Type *AddrType = IRB.getInt8PtrTy();
  Value *Addr = IRB.CreatePointerCast(I, AddrType);
  insertHookCall(&*Iter, CsiAfterAlloca, {CsiId, Addr, SizeVal, PropVal});
}

void CSIImpl::getAllocFnArgs(const Instruction *I,
                             SmallVectorImpl<Value *> &AllocFnArgs,
                             Type *SizeTy, Type *AddrTy,
                             const TargetLibraryInfo &TLI) {
  const Function *Called = nullptr;
  if (const CallInst *CI = dyn_cast<CallInst>(I))
    Called = CI->getCalledFunction();
  else if (const InvokeInst *II = dyn_cast<InvokeInst>(I))
    Called = II->getCalledFunction();

  LibFunc F;
  bool FoundLibFunc = TLI.getLibFunc(*Called, F);
  if (!FoundLibFunc)
    return;

  switch (F) {
  default:
    return;
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
  case LibFunc_msvc_new_array_longlong_nothrow: {
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
    return;
  }
  case LibFunc_calloc: {
    const CallInst *CI = cast<CallInst>(I);
    // Allocated size
    AllocFnArgs.push_back(CI->getArgOperand(1));
    // Number of elements
    AllocFnArgs.push_back(CI->getArgOperand(0));
    // Alignment = 0
    AllocFnArgs.push_back(ConstantInt::get(SizeTy, 0));
    // Old pointer = NULL
    AllocFnArgs.push_back(Constant::getNullValue(AddrTy));
    return;
  }
  case LibFunc_realloc:
  case LibFunc_reallocf: {
    const CallInst *CI = cast<CallInst>(I);
    // Allocated size
    AllocFnArgs.push_back(CI->getArgOperand(1));
    // Number of elements = 1
    AllocFnArgs.push_back(ConstantInt::get(SizeTy, 1));
    // Alignment = 0
    AllocFnArgs.push_back(ConstantInt::get(SizeTy, 0));
    // Old pointer
    AllocFnArgs.push_back(CI->getArgOperand(0));
    return;
  }
  }
}

void CSIImpl::assignAllocFnID(Instruction *I) {
  AllocFnFED.add(*I);
}

void CSIImpl::instrumentAllocFn(Instruction *I, DominatorTree *DT) {
  bool IsInvoke = isa<InvokeInst>(I);
  Function *Called = nullptr;
  if (CallInst *CI = dyn_cast<CallInst>(I))
    Called = CI->getCalledFunction();
  else if (InvokeInst *II = dyn_cast<InvokeInst>(I))
    Called = II->getCalledFunction();

  assert(Called && "Could not get called function for allocation fn.");

  IRBuilder<> IRB(I);
  Value *DefaultID = getDefaultID(IRB);
  csi_id_t LocalId = AllocFnFED.lookupId(I);
  Value *AllocFnId = AllocFnFED.localToGlobalId(LocalId, IRB);

  SmallVector<Value *, 4> AllocFnArgs;
  getAllocFnArgs(I, AllocFnArgs, IntptrTy, IRB.getInt8PtrTy(), *TLI);
  SmallVector<Value *, 4> DefaultAllocFnArgs({
      /* Allocated size */ Constant::getNullValue(IntptrTy),
      /* Number of elements */ Constant::getNullValue(IntptrTy),
      /* Alignment */ Constant::getNullValue(IntptrTy),
      /* Old pointer */ Constant::getNullValue(IRB.getInt8PtrTy()),
  });

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
      NormalBB =
          SplitCriticalEdge(II, SuccNum, CriticalEdgeSplittingOptions(DT));
    // Insert hook into normal destination.
    {
      IRB.SetInsertPoint(&*NormalBB->getFirstInsertionPt());
      SmallVector<Value *, 4> AfterAllocFnArgs;
      AfterAllocFnArgs.push_back(AllocFnId);
      AfterAllocFnArgs.push_back(IRB.CreatePointerCast(I, IRB.getInt8PtrTy()));
      AfterAllocFnArgs.append(AllocFnArgs.begin(), AllocFnArgs.end());
      insertHookCall(&*IRB.GetInsertPoint(), CsiAfterAllocFn, AfterAllocFnArgs);
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
      insertHookCallInSuccessorBB(II, II->getUnwindDest(), II->getParent(),
                                  CsiAfterAllocFn, AfterAllocFnArgs,
                                  DefaultAfterAllocFnArgs);
    }
  } else {
    // Simple call instruction; there is only one "after" position.
    Iter++;
    IRB.SetInsertPoint(&*Iter);
    SmallVector<Value *, 4> AfterAllocFnArgs;
    AfterAllocFnArgs.push_back(AllocFnId);
    AfterAllocFnArgs.push_back(IRB.CreatePointerCast(I, IRB.getInt8PtrTy()));
    AfterAllocFnArgs.append(AllocFnArgs.begin(), AllocFnArgs.end());
    insertHookCall(&*Iter, CsiAfterAllocFn, AfterAllocFnArgs);
  }
}

void CSIImpl::instrumentFree(Instruction *I) {
  // It appears that frees (and deletes) never throw.
  assert(isa<CallInst>(I) && "Free call is not a call instruction");

  CallInst *FC = cast<CallInst>(I);
  Function *Called = FC->getCalledFunction();
  assert(Called && "Could not get called function for free.");

  IRBuilder<> IRB(I);
  csi_id_t LocalId = FreeFED.add(*I);
  Value *FreeId = FreeFED.localToGlobalId(LocalId, IRB);

  Value *Addr = FC->getArgOperand(0);
  CsiFreeProperty Prop;
  LibFunc FreeLibF;
  TLI->getLibFunc(*Called, FreeLibF);
  Prop.setFreeTy(static_cast<unsigned>(getFreeTy(FreeLibF)));

  insertHookCall(I, CsiBeforeFree, {FreeId, Addr, Prop.getValue(IRB)});
  BasicBlock::iterator Iter(I);
  Iter++;
  insertHookCall(&*Iter, CsiAfterFree, {FreeId, Addr, Prop.getValue(IRB)});
}

CallInst *CSIImpl::insertHookCall(Instruction *I, Function *HookFunction,
                                  ArrayRef<Value *> HookArgs) {
  IRBuilder<> IRB(I);
  CallInst *Call = IRB.CreateCall(HookFunction, HookArgs);
  setInstrumentationDebugLoc(I, (Instruction *)Call);
  return Call;
}

bool CSIImpl::updateArgPHIs(Instruction *I, BasicBlock *Succ, BasicBlock *BB,
                            ArrayRef<Value *> HookArgs,
                            ArrayRef<Value *> DefaultArgs) {
  auto Key = std::make_pair(I, Succ);
  // If we've already created a PHI node in this block for the hook arguments,
  // just add the incoming arguments to the PHIs.
  if (ArgPHIs.count(Key)) {
    unsigned HookArgNum = 0;
    for (PHINode *ArgPHI : ArgPHIs[Key]) {
      ArgPHI->setIncomingValue(ArgPHI->getBasicBlockIndex(BB),
                               HookArgs[HookArgNum]);
      ++HookArgNum;
    }
    return true;
  }

  // Create PHI nodes in this block for each hook argument.
  IRBuilder<> IRB(&Succ->front());
  unsigned HookArgNum = 0;
  for (Value *Arg : HookArgs) {
    PHINode *ArgPHI = IRB.CreatePHI(Arg->getType(), 2);
    for (BasicBlock *Pred : predecessors(Succ)) {
      if (Pred == BB)
        ArgPHI->addIncoming(Arg, BB);
      else
        ArgPHI->addIncoming(DefaultArgs[HookArgNum], Pred);
    }
    ArgPHIs[Key].push_back(ArgPHI);
    ++HookArgNum;
  }
  return false;
}

CallInst *CSIImpl::insertHookCallInSuccessorBB(Instruction *I, BasicBlock *Succ,
                                               BasicBlock *BB,
                                               Function *HookFunction,
                                               ArrayRef<Value *> HookArgs,
                                               ArrayRef<Value *> DefaultArgs) {
  assert(HookFunction && "No hook function given.");
  // If this successor block has a unique predecessor, just insert the hook call
  // as normal.
  if (Succ->getUniquePredecessor()) {
    assert(Succ->getUniquePredecessor() == BB &&
           "BB is not unique predecessor of successor block");
    return insertHookCall(&*Succ->getFirstInsertionPt(), HookFunction,
                          HookArgs);
  }

  if (updateArgPHIs(I, Succ, BB, HookArgs, DefaultArgs))
    return nullptr;

  SmallVector<Value *, 2> SuccessorHookArgs;
  for (PHINode *ArgPHI : ArgPHIs[std::make_pair(I, Succ)])
    SuccessorHookArgs.push_back(ArgPHI);

  IRBuilder<> IRB(&*Succ->getFirstInsertionPt());
  // Insert the hook call, using the PHI as the CSI ID.
  CallInst *Call = IRB.CreateCall(HookFunction, SuccessorHookArgs);
  setInstrumentationDebugLoc(*Succ, (Instruction *)Call);

  return Call;
}

void CSIImpl::insertHookCallAtSharedEHSpindleExits(
    Instruction *I, Spindle *SharedEHSpindle, Task *T, Function *HookFunction,
    FrontEndDataTable &FED, ArrayRef<Value *> HookArgs,
    ArrayRef<Value *> DefaultArgs) {
  // Get the set of shared EH spindles to examine.  Store them in post order, so
  // they can be evaluated in reverse post order.
  SmallVector<Spindle *, 2> WorkList;
  for (Spindle *S : post_order<InTask<Spindle *>>(SharedEHSpindle))
    WorkList.push_back(S);

  // Traverse the shared-EH spindles in reverse post order, updating the
  // hook-argument PHI's along the way.
  SmallPtrSet<Spindle *, 2> Visited;
  for (Spindle *S : llvm::reverse(WorkList)) {
    bool NewPHINode = false;
    // If this spindle is the first shared-EH spindle in the traversal, use the
    // given hook arguments to update the PHI node.
    if (S == SharedEHSpindle) {
      for (Spindle::SpindleEdge &InEdge : S->in_edges()) {
        Spindle *SPred = InEdge.first;
        BasicBlock *Pred = InEdge.second;
        if (T->contains(SPred))
          NewPHINode |=
              updateArgPHIs(I, S->getEntry(), Pred, HookArgs, DefaultArgs);
      }
    } else {
      // Otherwise update the PHI node based on the predecessor shared-eh
      // spindles in this RPO traversal.
      for (Spindle::SpindleEdge &InEdge : S->in_edges()) {
        Spindle *SPred = InEdge.first;
        BasicBlock *Pred = InEdge.second;
        if (Visited.count(SPred)) {
          auto Key = std::make_pair(I, SPred->getEntry());
          SmallVector<Value *, 4> NewHookArgs(
              ArgPHIs[Key].begin(), ArgPHIs[Key].end());
          NewPHINode |=
              updateArgPHIs(I, S->getEntry(), Pred, NewHookArgs, DefaultArgs);
        }
      }
    }
    Visited.insert(S);

    if (!NewPHINode)
      continue;

    // Detached-rethrow exits can appear in strange places within a task-exiting
    // spindle.  Hence we loop over all blocks in the spindle to find detached
    // rethrows.
    for (BasicBlock *B : S->blocks()) {
      if (isDetachedRethrow(B->getTerminator())) {
        IRBuilder<> IRB(B->getTerminator());
        csi_id_t LocalID = FED.add(*B->getTerminator());
        Value *HookID = FED.localToGlobalId(LocalID, IRB);
        SmallVector<Value *, 4> Args({HookID});
        auto Key = std::make_pair(I, S->getEntry());
        Args.append(ArgPHIs[Key].begin(), ArgPHIs[Key].end());
        Instruction *Call = IRB.CreateCall(HookFunction, Args);
        setInstrumentationDebugLoc(*B, Call);
      }
    }
  }
}

void CSIImpl::initializeFEDTables() {
  FunctionFED = FrontEndDataTable(M, CsiFunctionBaseIdName,
                                  "__csi_unit_fed_table_function",
                                  "__csi_unit_function_name_");
  FunctionExitFED = FrontEndDataTable(M, CsiFunctionExitBaseIdName,
                                      "__csi_unit_fed_table_function_exit",
                                      "__csi_unit_function_name_");
  BasicBlockFED = FrontEndDataTable(M, CsiBasicBlockBaseIdName,
                                    "__csi_unit_fed_table_basic_block");
  CallsiteFED = FrontEndDataTable(M, CsiCallsiteBaseIdName,
                                  "__csi_unit_fed_table_callsite",
                                  "__csi_unit_function_name_");
  LoadFED = FrontEndDataTable(M, CsiLoadBaseIdName,
                              "__csi_unit_fed_table_load");
  StoreFED = FrontEndDataTable(M, CsiStoreBaseIdName,
                               "__csi_unit_fed_table_store");
  AllocaFED = FrontEndDataTable(M, CsiAllocaBaseIdName,
                                "__csi_unit_fed_table_alloca",
                                "__csi_unit_variable_name_");
  DetachFED = FrontEndDataTable(M, CsiDetachBaseIdName,
                                "__csi_unit_fed_table_detach");
  TaskFED = FrontEndDataTable(M, CsiTaskBaseIdName,
                              "__csi_unit_fed_table_task");
  TaskExitFED = FrontEndDataTable(M, CsiTaskExitBaseIdName,
                                  "__csi_unit_fed_table_task_exit");
  DetachContinueFED = FrontEndDataTable(M, CsiDetachContinueBaseIdName,
                                        "__csi_unit_fed_table_detach_continue");
  SyncFED = FrontEndDataTable(M, CsiSyncBaseIdName,
                              "__csi_unit_fed_table_sync");
  AllocFnFED = FrontEndDataTable(M, CsiAllocFnBaseIdName,
                                 "__csi_unit_fed_table_allocfn",
                                 "__csi_unit_variable_name_");
  FreeFED = FrontEndDataTable(M, CsiFreeBaseIdName,
                              "__csi_unit_fed_free");
  ArithmeticFED = FrontEndDataTable(M, CsiArithmeticBaseIdName,
                                    "__csi_unit_fed_table_arithmetic");
  ParameterFED = FrontEndDataTable(M, CsiParameterBaseIdName,
                                   "__csi_unit_fed_parameter",
                                   "__csi_unit_argument_name_");
  GlobalFED = FrontEndDataTable(M, CsiGlobalBaseIdName,
                                "__csi_unit_fed_table_global",
                                "__csi_unit_global_name_");
}

void CSIImpl::initializeSizeTables() {
  BBSize = SizeTable(M, CsiBasicBlockBaseIdName);
}

csi_id_t CSIImpl::getLocalFunctionID(Function &F) {
  csi_id_t LocalId = FunctionFED.add(F);
  FuncOffsetMap[F.getName()] = LocalId;
  return LocalId;
}

void CSIImpl::generateInitCallsiteToFunction() {
  LLVMContext &C = M.getContext();
  BasicBlock *EntryBB = BasicBlock::Create(C, "", InitCallsiteToFunction);
  IRBuilder<> IRB(ReturnInst::Create(C, EntryBB));

  GlobalVariable *Base = FunctionFED.baseId();
  LoadInst *LI = IRB.CreateLoad(Base);
  // Traverse the map of function name -> function local id. Generate
  // a store of each function's global ID to the corresponding weak
  // global variable.
  for (const auto &it : FuncOffsetMap) {
    std::string GVName = CsiFuncIdVariablePrefix + it.first.str();
    GlobalVariable *GV = nullptr;
    if ((GV = M.getGlobalVariable(GVName)) == nullptr) {
      GV = new GlobalVariable(M, IRB.getInt64Ty(), false,
                              GlobalValue::WeakAnyLinkage,
                              IRB.getInt64(CsiCallsiteUnknownTargetId), GVName);
    }
    assert(GV);
    IRB.CreateStore(IRB.CreateAdd(LI, IRB.getInt64(it.second)), GV);
  }

  GlobalVariable *GlobalBase = GlobalFED.baseId();
  LI = IRB.CreateLoad(GlobalBase);
  for (const auto &it : GlobalOffsetMap) {
    std::string GVName = CsiGlobalIdVariablePrefix + it.first.str();
    GlobalVariable *GV = nullptr;
    if ((GV = M.getGlobalVariable(GVName)) == nullptr) {
      GV = new GlobalVariable(M, IRB.getInt64Ty(), false,
                              GlobalValue::WeakAnyLinkage,
                              IRB.getInt64(CsiUnknownId), GVName);
    }
    assert(GV);
    IRB.CreateStore(IRB.CreateAdd(LI, IRB.getInt64(it.second)), GV);
  }
}

void CSIImpl::initializeCsi() {
  IntptrTy = DL.getIntPtrType(M.getContext());

  initializeFEDTables();
  initializeSizeTables();
  if (Options.InstrumentFuncEntryExit)
    initializeFuncHooks();
  if (Options.InstrumentMemoryAccesses)
    initializeLoadStoreHooks();
  if (Options.InstrumentBasicBlocks)
    initializeBasicBlockHooks();
  if (Options.InstrumentCalls)
    initializeCallsiteHooks();
  if (Options.InstrumentMemIntrinsics)
    initializeMemIntrinsicsHooks();
  if (Options.InstrumentTapir)
    initializeTapirHooks();
  if (Options.InstrumentAllocas)
    initializeAllocaHooks();
  if (Options.InstrumentAllocFns)
    initializeAllocFnHooks();
  if (Options.InstrumentArithmetic)
    initializeArithmeticHooks();

  FunctionType *FnType =
      FunctionType::get(Type::getVoidTy(M.getContext()), {}, false);
  InitCallsiteToFunction = checkCsiInterfaceFunction(
      M.getOrInsertFunction(CsiInitCallsiteToFunctionName, FnType));
  assert(InitCallsiteToFunction);
  InitCallsiteToFunction->setLinkage(GlobalValue::InternalLinkage);

  /*
  The runtime declares this as a __thread var --- need to change this decl
  generation or the tool won't compile DisableInstrGV = new GlobalVariable(M,
  IntegerType::get(M.getContext(), 1), false, GlobalValue::ExternalLinkage,
  nullptr, CsiDisableInstrumentationName, nullptr,
                                      GlobalValue::GeneralDynamicTLSModel, 0,
  true);
  */
}

// Create a struct type to match the unit_fed_entry_t type in csirt.c.
StructType *CSIImpl::getUnitFedTableType(LLVMContext &C,
                                         PointerType *EntryPointerType) {
  return StructType::get(IntegerType::get(C, 64), Type::getInt8PtrTy(C, 0),
                         EntryPointerType);
}

Constant *CSIImpl::fedTableToUnitFedTable(Module &M,
                                          StructType *UnitFedTableType,
                                          FrontEndDataTable &FedTable) {
  Constant *NumEntries =
      ConstantInt::get(IntegerType::get(M.getContext(), 64), FedTable.size());
  Constant *BaseIdPtr = ConstantExpr::getPointerCast(
      FedTable.baseId(), Type::getInt8PtrTy(M.getContext(), 0));
  Constant *InsertedTable = FedTable.insertIntoModule(M);
  return ConstantStruct::get(UnitFedTableType, NumEntries, BaseIdPtr,
                             InsertedTable);
}

void CSIImpl::collectUnitFEDTables() {
  LLVMContext &C = M.getContext();
  StructType *UnitFedTableType =
      getUnitFedTableType(C, FrontEndDataTable::getPointerType(C));

  // The order of the FED tables here must match the enum in csirt.c and the
  // instrumentation_counts_t in csi.h.
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, FunctionFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, FunctionExitFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, BasicBlockFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, CallsiteFED));
  UnitFedTables.push_back(fedTableToUnitFedTable(M, UnitFedTableType, LoadFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, StoreFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, DetachFED));
  UnitFedTables.push_back(fedTableToUnitFedTable(M, UnitFedTableType, TaskFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, TaskExitFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, DetachContinueFED));
  UnitFedTables.push_back(fedTableToUnitFedTable(M, UnitFedTableType, SyncFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, AllocaFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, AllocFnFED));
  UnitFedTables.push_back(fedTableToUnitFedTable(M, UnitFedTableType, FreeFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, ArithmeticFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, ParameterFED));
  UnitFedTables.push_back(
      fedTableToUnitFedTable(M, UnitFedTableType, GlobalFED));
}

// Create a struct type to match the unit_obj_entry_t type in csirt.c.
StructType *CSIImpl::getUnitSizeTableType(LLVMContext &C,
                                          PointerType *EntryPointerType) {
  return StructType::get(IntegerType::get(C, 64), EntryPointerType);
}

Constant *CSIImpl::sizeTableToUnitSizeTable(Module &M,
                                            StructType *UnitSizeTableType,
                                            SizeTable &SzTable) {
  Constant *NumEntries =
      ConstantInt::get(IntegerType::get(M.getContext(), 64), SzTable.size());
  // Constant *BaseIdPtr =
  //   ConstantExpr::getPointerCast(FedTable.baseId(),
  //                                Type::getInt8PtrTy(M.getContext(), 0));
  Constant *InsertedTable = SzTable.insertIntoModule(M);
  return ConstantStruct::get(UnitSizeTableType, NumEntries, InsertedTable);
}

void CSIImpl::collectUnitSizeTables() {
  LLVMContext &C = M.getContext();
  StructType *UnitSizeTableType =
      getUnitSizeTableType(C, SizeTable::getPointerType(C));

  UnitSizeTables.push_back(
      sizeTableToUnitSizeTable(M, UnitSizeTableType, BBSize));
}

CallInst *CSIImpl::createRTUnitInitCall(IRBuilder<> &IRB) {
  LLVMContext &C = M.getContext();

  StructType *UnitFedTableType =
      getUnitFedTableType(C, FrontEndDataTable::getPointerType(C));
  StructType *UnitSizeTableType =
      getUnitSizeTableType(C, SizeTable::getPointerType(C));

  // Lookup __csirt_unit_init
  SmallVector<Type *, 4> InitArgTypes({IRB.getInt8PtrTy(),
                                       PointerType::get(UnitFedTableType, 0),
                                       PointerType::get(UnitSizeTableType, 0),
                                       InitCallsiteToFunction->getType()});
  FunctionType *InitFunctionTy =
      FunctionType::get(IRB.getVoidTy(), InitArgTypes, false);
  RTUnitInit = checkCsiInterfaceFunction(
      M.getOrInsertFunction(CsiRtUnitInitName, InitFunctionTy));
  assert(RTUnitInit);

  ArrayType *UnitFedTableArrayType =
      ArrayType::get(UnitFedTableType, UnitFedTables.size());
  Constant *FEDTable = ConstantArray::get(UnitFedTableArrayType, UnitFedTables);
  GlobalVariable *FEDGV = new GlobalVariable(
      M, UnitFedTableArrayType, false, GlobalValue::InternalLinkage, FEDTable,
      CsiUnitFedTableArrayName);
  ArrayType *UnitSizeTableArrayType =
      ArrayType::get(UnitSizeTableType, UnitSizeTables.size());
  Constant *SzTable =
      ConstantArray::get(UnitSizeTableArrayType, UnitSizeTables);
  GlobalVariable *SizeGV = new GlobalVariable(
      M, UnitSizeTableArrayType, false, GlobalValue::InternalLinkage, SzTable,
      CsiUnitSizeTableArrayName);

  Constant *Zero = ConstantInt::get(IRB.getInt32Ty(), 0);
  Value *GepArgs[] = {Zero, Zero};

  // Insert call to __csirt_unit_init
  return IRB.CreateCall(
      RTUnitInit,
      {IRB.CreateGlobalStringPtr(M.getName()),
       ConstantExpr::getGetElementPtr(FEDGV->getValueType(), FEDGV, GepArgs),
       ConstantExpr::getGetElementPtr(SizeGV->getValueType(), SizeGV, GepArgs),
       InitCallsiteToFunction});
}

void CSIImpl::finalizeCsi() {
  LLVMContext &C = M.getContext();

  // Add CSI global constructor, which calls unit init.
  Function *Ctor =
      Function::Create(FunctionType::get(Type::getVoidTy(C), false),
                       GlobalValue::InternalLinkage, CsiRtUnitCtorName, &M);
  BasicBlock *CtorBB = BasicBlock::Create(C, "", Ctor);
  IRBuilder<> IRB(ReturnInst::Create(C, CtorBB));

  // Insert __csi_func_id_<f> weak symbols for all defined functions and
  // generate the runtime code that stores to all of them.
  generateInitCallsiteToFunction();

  CallInst *Call = createRTUnitInitCall(IRB);

  // Add the constructor to the global list
  appendToGlobalCtors(M, Ctor, CsiUnitCtorPriority);

  CallGraphNode *CNCtor = CG->getOrInsertFunction(Ctor);
  CallGraphNode *CNFunc = CG->getOrInsertFunction(RTUnitInit);
  CNCtor->addCalledFunction(Call, CNFunc);
}

void llvm::CSIImpl::linkInToolFromBitcode(const std::string &bitcodePath) {
  if (bitcodePath != "") {
    std::unique_ptr<Module> toolModule;

    SMDiagnostic error;
    auto m = parseIRFile(bitcodePath, error, M.getContext());
    if (m) {
      toolModule = std::move(m);
    } else {
      llvm::errs() << "Error loading bitcode (" << bitcodePath
                   << "): " << error.getMessage() << "\n";
      report_fatal_error(error.getMessage());
    }

    std::vector<std::string> functions;

    for (Function &F : *toolModule) {
      if (!F.isDeclaration() && F.hasName()) {
        functions.push_back(F.getName());
      }
    }

    std::vector<std::string> globalVariables;

    std::vector<GlobalValue *> toRemove;
    for (GlobalValue &val : toolModule->getGlobalList()) {
      if (!val.isDeclaration()) {
        if (val.hasName() && (val.getName() == "llvm.global_ctors" ||
                              val.getName() == "llvm.global_dtors")) {
          toRemove.push_back(&val);
          continue;
        }

        // We can't have globals with internal linkage due to how compile-time
        // instrumentation works. Treat "static" variables as non-static.
        if (val.getLinkage() == GlobalValue::InternalLinkage)
          val.setLinkage(llvm::GlobalValue::CommonLinkage);

        if (val.hasName())
          globalVariables.push_back(val.getName());
      }
    }

    // We remove global constructors and destructors because they'll be linked
    // in at link time when the tool is linked. We can't have duplicates for
    // each translation unit.
    for (auto &val : toRemove) {
      val->eraseFromParent();
    }

    llvm::Linker linker(M);

    linker.linkInModule(std::move(toolModule),
                        llvm::Linker::Flags::LinkOnlyNeeded);

    // Set all tool's globals and functions to be "available externally" so
    // the linker won't complain about multiple definitions.
    for (auto &globalVariableName : globalVariables) {
      auto var = M.getGlobalVariable(globalVariableName);

      if (var && !var->isDeclaration() && !var->hasComdat()) {
        var->setLinkage(
            llvm::GlobalValue::LinkageTypes::AvailableExternallyLinkage);
      }
    }
    for (auto &functionName : functions) {
      auto function = M.getFunction(functionName);
      if (function && !function->isDeclaration() && !function->hasComdat()) {
        function->setLinkage(
            GlobalValue::LinkageTypes::AvailableExternallyLinkage);
      }
    }
  }
}

void llvm::CSIImpl::loadConfiguration() {
  if (ClConfigurationFilename != "")
    Config = InstrumentationConfig::ReadFromConfigurationFile(
        ClConfigurationFilename);
  else
    Config = InstrumentationConfig::GetDefault();

  Config->SetConfigMode(ClConfigurationMode);
}

bool CSIImpl::shouldNotInstrumentFunction(Function &F) {
  // Don't instrument standard library calls.
#ifdef WIN32
  if (F.hasName() && F.getName().find("_") == 0) {
    return true;
  }
#endif

  if (F.hasName() && F.getName().startswith("__csi"))
    return true;

  // Never instrument the CSI ctor.
  if (F.hasName() && F.getName() == CsiRtUnitCtorName)
    return true;

  // Don't instrument functions that will run before or
  // simultaneously with CSI ctors.
  GlobalVariable *GV = M.getGlobalVariable("llvm.global_ctors");
  if (GV == nullptr)
    return false;
  ConstantArray *CA = cast<ConstantArray>(GV->getInitializer());
  for (Use &OP : CA->operands()) {
    if (isa<ConstantAggregateZero>(OP))
      continue;
    ConstantStruct *CS = cast<ConstantStruct>(OP);

    if (Function *CF = dyn_cast<Function>(CS->getOperand(1))) {
      uint64_t Priority =
          dyn_cast<ConstantInt>(CS->getOperand(0))->getLimitedValue();
      if (Priority <= CsiUnitCtorPriority && CF->getName() == F.getName()) {
        // Do not instrument F.
        return true;
      }
    }
  }
  // false means do instrument it.
  return false;
}

bool CSIImpl::isVtableAccess(Instruction *I) {
  if (MDNode *Tag = I->getMetadata(LLVMContext::MD_tbaa))
    return Tag->isTBAAVtableAccess();
  return false;
}

bool CSIImpl::addrPointsToConstantData(Value *Addr) {
  // If this is a GEP, just analyze its pointer operand.
  if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Addr))
    Addr = GEP->getPointerOperand();

  if (GlobalVariable *GV = dyn_cast<GlobalVariable>(Addr)) {
    if (GV->isConstant()) {
      return true;
    }
  } else if (LoadInst *L = dyn_cast<LoadInst>(Addr)) {
    if (isVtableAccess(L)) {
      return true;
    }
  }
  return false;
}

bool CSIImpl::isAtomic(Instruction *I) {
  if (LoadInst *LI = dyn_cast<LoadInst>(I))
    return LI->isAtomic() && LI->getSyncScopeID() != SyncScope::SingleThread;
  if (StoreInst *SI = dyn_cast<StoreInst>(I))
    return SI->isAtomic() && SI->getSyncScopeID() != SyncScope::SingleThread;
  if (isa<AtomicRMWInst>(I))
    return true;
  if (isa<AtomicCmpXchgInst>(I))
    return true;
  if (isa<FenceInst>(I))
    return true;
  return false;
}

void CSIImpl::computeLoadAndStoreProperties(
    SmallVectorImpl<std::pair<Instruction *, CsiLoadStoreProperty>>
        &LoadAndStoreProperties,
    SmallVectorImpl<Instruction *> &BBLoadsAndStores, const DataLayout &DL) {
  SmallSet<Value *, 8> WriteTargets;

  for (SmallVectorImpl<Instruction *>::reverse_iterator
           It = BBLoadsAndStores.rbegin(),
           E = BBLoadsAndStores.rend();
       It != E; ++It) {
    Instruction *I = *It;
    unsigned Alignment;
    if (StoreInst *Store = dyn_cast<StoreInst>(I)) {
      Value *Addr = Store->getPointerOperand();
      WriteTargets.insert(Addr);
      CsiLoadStoreProperty Prop;
      // Update alignment property data
      Alignment = Store->getAlignment();
      Prop.setAlignment(Alignment);
      // Set vtable-access property
      Prop.setIsVtableAccess(isVtableAccess(Store));
      // Set constant-data-access property
      Prop.setIsConstant(addrPointsToConstantData(Addr));
      Value *Obj = GetUnderlyingObject(Addr, DL);
      // Set is-on-stack property
      Prop.setIsOnStack(isa<AllocaInst>(Obj));
      // Set may-be-captured property
      Prop.setMayBeCaptured(isa<GlobalValue>(Obj) ||
                            PointerMayBeCaptured(Addr, true, true));
      LoadAndStoreProperties.push_back(std::make_pair(I, Prop));
    } else {
      LoadInst *Load = cast<LoadInst>(I);
      Value *Addr = Load->getPointerOperand();
      CsiLoadStoreProperty Prop;
      // Update alignment property data
      Alignment = Load->getAlignment();
      Prop.setAlignment(Alignment);
      // Set vtable-access property
      Prop.setIsVtableAccess(isVtableAccess(Load));
      // Set constant-data-access-property
      Prop.setIsConstant(addrPointsToConstantData(Addr));
      Value *Obj = GetUnderlyingObject(Addr, DL);
      // Set is-on-stack property
      Prop.setIsOnStack(isa<AllocaInst>(Obj));
      // Set may-be-captured property
      Prop.setMayBeCaptured(isa<GlobalValue>(Obj) ||
                            PointerMayBeCaptured(Addr, true, true));
      // Set load-read-before-write-in-bb property
      bool HasBeenSeen = WriteTargets.count(Addr) > 0;
      Prop.setLoadReadBeforeWriteInBB(HasBeenSeen);
      LoadAndStoreProperties.push_back(std::make_pair(I, Prop));
    }
  }
  BBLoadsAndStores.clear();
}

// Update the attributes on the instrumented function that might be invalidated
// by the inserted instrumentation.
void CSIImpl::updateInstrumentedFnAttrs(Function &F) {
  AttrBuilder B;
  B.addAttribute(Attribute::ReadOnly)
      .addAttribute(Attribute::ReadNone)
      .addAttribute(Attribute::ArgMemOnly)
      .addAttribute(Attribute::InaccessibleMemOnly)
      .addAttribute(Attribute::InaccessibleMemOrArgMemOnly);
  F.removeAttributes(AttributeList::FunctionIndex, B);
}

void CSIImpl::instrumentFunction(Function &F) {
  // This is required to prevent instrumenting the call to
  // __csi_module_init from within the module constructor.

  if (F.empty() || shouldNotInstrumentFunction(F))
    return;

  setupCalls(F);

  setupBlocks(F, TLI);

  SmallVector<std::pair<Instruction *, CsiLoadStoreProperty>, 8>
      LoadAndStoreProperties;
  SmallVector<Instruction *, 8> AllocationFnCalls;
  SmallVector<Instruction *, 8> FreeCalls;
  SmallVector<Instruction *, 8> MemIntrinsics;
  SmallVector<Instruction *, 8> Callsites;
  SmallVector<BasicBlock *, 8> BasicBlocks;
  SmallVector<Instruction *, 8> AtomicAccesses;
  SmallVector<DetachInst *, 8> Detaches;
  SmallVector<SyncInst *, 8> Syncs;
  SmallVector<Instruction *, 8> Allocas;
  SmallVector<Instruction *, 8> AllCalls;
  SmallVector<Instruction *, 32> Arithmetic;
  bool MaySpawn = false;

  DominatorTree *DT = &GetDomTree(F);
  TaskInfo &TI = GetTaskInfo(F);

  for (Argument &Arg : F.args())
    // Add an ID for this function argument.
    /*csi_id_t LocalId =*/ParameterFED.add(Arg);

  // Compile lists of all instrumentation points before anything is modified.
  for (BasicBlock &BB : F) {
    SmallVector<Instruction *, 8> BBLoadsAndStores;
    for (Instruction &I : BB) {
      if (isAtomic(&I))
        AtomicAccesses.push_back(&I);
      else if (isa<LoadInst>(I) || isa<StoreInst>(I)) {
        BBLoadsAndStores.push_back(&I);
      } else if (DetachInst *DI = dyn_cast<DetachInst>(&I)) {
        MaySpawn = true;
        Detaches.push_back(DI);
      } else if (SyncInst *SI = dyn_cast<SyncInst>(&I)) {
        Syncs.push_back(SI);
      } else if (isa<CallInst>(I) || isa<InvokeInst>(I)) {

        // Record this function call as either an allocation function, a call to
        // free (or delete), a memory intrinsic, or an ordinary real function
        // call.
        if (isAllocationFn(&I, TLI))
          AllocationFnCalls.push_back(&I);
        else if (isFreeCall(&I, TLI))
          FreeCalls.push_back(&I);
        else if (isa<MemIntrinsic>(I))
          MemIntrinsics.push_back(&I);
        else
          Callsites.push_back(&I);

        // All calls are candidates for interpositioning except for calls to
        // placeholder functions.
        if (!callsPlaceholderFunction(I))
          AllCalls.push_back(&I);

        computeLoadAndStoreProperties(LoadAndStoreProperties, BBLoadsAndStores,
                                      DL);
      } else if (isa<AllocaInst>(I)) {
        Allocas.push_back(&I);
      } else {
        if (isa<BinaryOperator>(I) || isa<TruncInst>(I) || isa<ZExtInst>(I) ||
            isa<SExtInst>(I) || isa<FPToUIInst>(I) || isa<FPToSIInst>(I) ||
            isa<UIToFPInst>(I) || isa<SIToFPInst>(I) || isa<FPTruncInst>(I) ||
            isa<FPExtInst>(I) || isa<PHINode>(I))
          Arithmetic.push_back(&I);

        // TODO: Handle GetElementPtr, PtrToInt, IntToPtr, BitCast,
        // AddrSpaceCast

        // TODO: Handle ExtractElement, InsertElement, ShuffleVector,
        // ExtractValue, InsertValue
      }
    }
    computeLoadAndStoreProperties(LoadAndStoreProperties, BBLoadsAndStores, DL);
    BasicBlocks.push_back(&BB);
  }

  csi_id_t LocalId = getLocalFunctionID(F);
  // First assign local ID's to all ops in the function that are involved in
  // data flow, so that these IDs can be supplied as arguments to other hooks.
  for (std::pair<Instruction *, CsiLoadStoreProperty> p :
         LoadAndStoreProperties)
    assignLoadOrStoreID(p.first);
  for (Instruction *I : AtomicAccesses)
    assignAtomicID(I);
  for (Instruction *I : Callsites)
    assignCallsiteID(I);
  for (Instruction *I : Allocas)
    assignAllocaID(I);
  for (Instruction *I : AllocationFnCalls)
    assignAllocFnID(I);
  for (Instruction *I : Arithmetic)
    assignArithmeticID(I);

  // Instrument basic blocks.  Note that we do this before other instrumentation
  // so that we put this at the beginning of the basic block, and then the
  // function entry call goes before the call to basic block entry.
  if (Options.InstrumentBasicBlocks)
    for (BasicBlock *BB : BasicBlocks)
      instrumentBasicBlock(*BB);

  // Instrument Tapir constructs.
  if (Options.InstrumentTapir) {
    // Allocate a local variable that will keep track of whether
    // a spawn has occurred before a sync. It will be set to 1 after
    // a spawn and reset to 0 after a sync.
    auto TrackVars = keepTrackOfSpawns(F, Detaches, Syncs);

    if (Config->DoesFunctionRequireInstrumentationForPoint(
            F.getName(), InstrumentationPoint::INSTR_TAPIR_DETACH)) {
      for (DetachInst *DI : Detaches)
        instrumentDetach(DI, DT, TI, TrackVars);
    }
    if (Config->DoesFunctionRequireInstrumentationForPoint(
            F.getName(), InstrumentationPoint::INSTR_TAPIR_SYNC)) {
      for (SyncInst *SI : Syncs)
        instrumentSync(SI, TrackVars);
    }
  }

  // Do this work in a separate loop after copying the iterators so that we
  // aren't modifying the list as we're iterating.
  if (Options.InstrumentMemoryAccesses)
    for (std::pair<Instruction *, CsiLoadStoreProperty> p :
         LoadAndStoreProperties)
      instrumentLoadOrStore(p.first, p.second, DL);

  // Instrument atomic memory accesses in any case (they can be used to
  // implement synchronization).
  if (Options.InstrumentAtomics)
    for (Instruction *I : AtomicAccesses)
      instrumentAtomic(I, DL);

  if (Options.InstrumentMemIntrinsics)
    for (Instruction *I : MemIntrinsics)
      instrumentMemIntrinsic(I);

  if (Options.InstrumentCalls)
    for (Instruction *I : Callsites)
      instrumentCallsite(I, DT);

  if (Options.InstrumentAllocas)
    for (Instruction *I : Allocas)
      instrumentAlloca(I);

  if (Options.InstrumentAllocFns) {
    for (Instruction *I : AllocationFnCalls)
      instrumentAllocFn(I, DT);
    for (Instruction *I : FreeCalls)
      instrumentFree(I);
  }

  if (Options.InstrumentArithmetic)
    for (Instruction *I : Arithmetic)
      instrumentArithmetic(I);

  if (Options.Interpose) {
    for (Instruction *I : AllCalls)
      interposeCall(I);
  }

  // Instrument function entry/exit points.
  if (Options.InstrumentFuncEntryExit) {
    IRBuilder<> IRB(&*F.getEntryBlock().getFirstInsertionPt());
    Value *FuncId = FunctionFED.localToGlobalId(LocalId, IRB);
    if (Config->DoesFunctionRequireInstrumentationForPoint(
            F.getName(), InstrumentationPoint::INSTR_FUNCTION_ENTRY)) {
      // Get the ID of the first function argument
      Value *FirstArgID = ParameterFED.localToGlobalId(
          ParameterFED.lookupId(&*F.arg_begin()), IRB);
      // Get the number of function arguments
      Value *NumArgs = IRB.getInt32(F.arg_size());
      CsiFuncProperty FuncEntryProp;
      FuncEntryProp.setMaySpawn(MaySpawn);
      Value *PropVal = FuncEntryProp.getValue(IRB);
      insertHookCall(&*IRB.GetInsertPoint(), CsiFuncEntry,
                     {FuncId, FirstArgID, NumArgs, PropVal});
    }
    if (Config->DoesFunctionRequireInstrumentationForPoint(
            F.getName(), InstrumentationPoint::INSTR_FUNCTION_EXIT)) {
      EscapeEnumerator EE(F, "csi.cleanup", false);
      while (IRBuilder<> *AtExit = EE.Next()) {
        // csi_id_t ExitLocalId = FunctionExitFED.add(F);
        Instruction *ExitInst = cast<Instruction>(AtExit->GetInsertPoint());
        csi_id_t ExitLocalId = FunctionExitFED.add(*ExitInst);
        Value *ExitCsiId =
            FunctionExitFED.localToGlobalId(ExitLocalId, *AtExit);
        Value *ReturnOp = (ExitInst->getNumOperands() == 0) ? nullptr :
          ExitInst->getOperand(0);
        std::pair<Value *, Value *> OperandID = getOperandID(ReturnOp, *AtExit);
        CsiFuncExitProperty FuncExitProp;
        FuncExitProp.setMaySpawn(MaySpawn);
        FuncExitProp.setEHReturn(isa<ResumeInst>(ExitInst));
        Value *PropVal = FuncExitProp.getValue(*AtExit);
        insertHookCall(&*AtExit->GetInsertPoint(), CsiFuncExit,
                       {ExitCsiId, FuncId, OperandID.first, OperandID.second,
                        PropVal});
      }
    }
  }

  updateInstrumentedFnAttrs(F);
}

DenseMap<Value *, Value *>
llvm::CSIImpl::keepTrackOfSpawns(Function &F,
                                 const SmallVectorImpl<DetachInst *> &Detaches,
                                 const SmallVectorImpl<SyncInst *> &Syncs) {
  DenseMap<Value *, Value *> TrackVars;
  // SyncRegions are created using an LLVM instrinsic within the task where the
  // region is used.  Store each sync region as an LLVM instruction.
  SmallPtrSet<Instruction *, 8> Regions;
  for (auto &Detach : Detaches) {
    Regions.insert(cast<Instruction>(Detach->getSyncRegion()));
  }
  for (auto &Sync : Syncs) {
    Regions.insert(cast<Instruction>(Sync->getSyncRegion()));
  }

  LLVMContext &C = F.getContext();

  size_t RegionIndex = 0;
  for (auto Region : Regions) {
    // Build a local variable for the sync region within the task where it is
    // used.
    IRBuilder<> Builder(Region);
    Value *TrackVar = Builder.CreateAlloca(IntegerType::getInt32Ty(C), nullptr,
                                           "has_spawned_region_" +
                                               std::to_string(RegionIndex));
    Builder.CreateStore(
        Constant::getIntegerValue(IntegerType::getInt32Ty(C), APInt(32, 0)),
        TrackVar);

    TrackVars.insert({Region, TrackVar});
    RegionIndex++;
  }

  return TrackVars;
}

Function *llvm::CSIImpl::getInterpositionFunction(Function *F) {
  if (InterpositionFunctions.find(F) != InterpositionFunctions.end()) {
    return InterpositionFunctions.lookup(F);
  }

  std::string InterposedName =
      (std::string) "__csi_interpose_" + F->getName().str();

  Function *InterpositionFunction =
      (Function *)M.getOrInsertFunction(InterposedName, F->getFunctionType());

  InterpositionFunctions.insert({F, InterpositionFunction});

  return InterpositionFunction;
}

void ComprehensiveStaticInstrumentationLegacyPass::getAnalysisUsage(
    AnalysisUsage &AU) const {
  AU.addRequired<CallGraphWrapperPass>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.addRequired<TaskInfoWrapperPass>();
  AU.addRequired<TargetLibraryInfoWrapperPass>();
}

bool ComprehensiveStaticInstrumentationLegacyPass::runOnModule(Module &M) {
  if (skipModule(M))
    return false;

  CallGraph *CG = &getAnalysis<CallGraphWrapperPass>().getCallGraph();
  const TargetLibraryInfo *TLI =
      &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI();
  auto GetDomTree = [this](Function &F) -> DominatorTree & {
    return this->getAnalysis<DominatorTreeWrapperPass>(F).getDomTree();
  };
  auto GetTaskInfo = [this](Function &F) -> TaskInfo & {
    return this->getAnalysis<TaskInfoWrapperPass>(F).getTaskInfo();
  };

  bool res = CSIImpl(M, CG, GetDomTree, GetTaskInfo, TLI, Options).run();

  verifyModule(M, &llvm::errs());

  return res;
}

ComprehensiveStaticInstrumentationPass::ComprehensiveStaticInstrumentationPass(
    const CSIOptions &Options)
    : Options(OverrideFromCL(Options)) {}

PreservedAnalyses
ComprehensiveStaticInstrumentationPass::run(Module &M,
                                            ModuleAnalysisManager &AM) {
  auto &FAM = AM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();

  auto &CG = AM.getResult<CallGraphAnalysis>(M);
  auto GetDT = [&FAM](Function &F) -> DominatorTree & {
    return FAM.getResult<DominatorTreeAnalysis>(F);
  };
  auto GetTI = [&FAM](Function &F) -> TaskInfo & {
    return FAM.getResult<TaskAnalysis>(F);
  };
  auto *TLI = &AM.getResult<TargetLibraryAnalysis>(M);

  if (!CSIImpl(M, &CG, GetDT, GetTI, TLI, Options).run())
    return PreservedAnalyses::all();

  return PreservedAnalyses::none();
}
