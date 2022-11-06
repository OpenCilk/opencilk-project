//===--- CGCilk.cpp - Emit LLVM Code for Cilk expressions -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This contains code dealing with code generation of Cilk statements and
// expressions.
//
//===----------------------------------------------------------------------===//

#include "CodeGenFunction.h"
#include "CGCleanup.h"
#include "clang/AST/ExprCilk.h"
#include "clang/AST/StmtCilk.h"

using namespace clang;
using namespace CodeGen;

CodeGenFunction::IsSpawnedScope::IsSpawnedScope(CodeGenFunction *CGF)
    : CGF(CGF), OldIsSpawned(CGF->IsSpawned),
      OldSpawnedCleanup(CGF->SpawnedCleanup) {
  CGF->IsSpawned = false;
  CGF->SpawnedCleanup = OldIsSpawned;
}

CodeGenFunction::IsSpawnedScope::~IsSpawnedScope() {
  RestoreOldScope();
}

bool CodeGenFunction::IsSpawnedScope::OldScopeIsSpawned() const {
  return OldIsSpawned;
}

void CodeGenFunction::IsSpawnedScope::RestoreOldScope() {
  CGF->IsSpawned = OldIsSpawned;
  CGF->SpawnedCleanup = OldSpawnedCleanup;
}

void CodeGenFunction::EmitImplicitSyncCleanup(llvm::Instruction *SyncRegion) {
  llvm::Instruction *SR = SyncRegion;
  // If a sync region wasn't specified with this cleanup initially, try to grab
  // the current sync region.
  if (!SR && CurSyncRegion && CurSyncRegion->getSyncRegionStart())
    SR = CurSyncRegion->getSyncRegionStart();
  if (!SR)
    return;

  llvm::BasicBlock *ContinueBlock = createBasicBlock("sync.continue");
  Builder.CreateSync(ContinueBlock, SR);
  EmitBlockAfterUses(ContinueBlock);
  if (getLangOpts().Exceptions && !CurFn->doesNotThrow())
    EmitCallOrInvoke(CGM.getIntrinsic(llvm::Intrinsic::sync_unwind), { SR });
}

void CodeGenFunction::DetachScope::CreateTaskFrameEHState() {
  // Save the old EH state.
  OldEHResumeBlock = CGF.EHResumeBlock;
  CGF.EHResumeBlock = nullptr;
  OldExceptionSlot = CGF.ExceptionSlot;
  CGF.ExceptionSlot = nullptr;
  OldEHSelectorSlot = CGF.EHSelectorSlot;
  CGF.EHSelectorSlot = nullptr;
  OldNormalCleanupDest = CGF.NormalCleanupDest;
  CGF.NormalCleanupDest = Address::invalid();
}

void CodeGenFunction::DetachScope::CreateDetachedEHState() {
  // Save the old EH state.
  TFEHResumeBlock = CGF.EHResumeBlock;
  CGF.EHResumeBlock = nullptr;
  TFExceptionSlot = CGF.ExceptionSlot;
  CGF.ExceptionSlot = nullptr;
  TFEHSelectorSlot = CGF.EHSelectorSlot;
  CGF.EHSelectorSlot = nullptr;
  TFNormalCleanupDest = CGF.NormalCleanupDest;
  CGF.NormalCleanupDest = Address::invalid();
}

llvm::BasicBlock *CodeGenFunction::DetachScope::RestoreTaskFrameEHState() {
  llvm::BasicBlock *NestedEHResumeBlock = CGF.EHResumeBlock;
  CGF.EHResumeBlock = TFEHResumeBlock;
  CGF.ExceptionSlot = TFExceptionSlot;
  CGF.EHSelectorSlot = TFEHSelectorSlot;
  CGF.NormalCleanupDest = TFNormalCleanupDest;
  return NestedEHResumeBlock;
}

llvm::BasicBlock *CodeGenFunction::DetachScope::RestoreParentEHState() {
  llvm::BasicBlock *NestedEHResumeBlock = CGF.EHResumeBlock;
  CGF.EHResumeBlock = OldEHResumeBlock;
  CGF.ExceptionSlot = OldExceptionSlot;
  CGF.EHSelectorSlot = OldEHSelectorSlot;
  CGF.NormalCleanupDest = OldNormalCleanupDest;
  return NestedEHResumeBlock;
}

void CodeGenFunction::DetachScope::EnsureTaskFrame() {
  if (!TaskFrame) {
    llvm::Function *TaskFrameCreate =
        CGF.CGM.getIntrinsic(llvm::Intrinsic::taskframe_create);
    TaskFrame = CGF.Builder.CreateCall(TaskFrameCreate);

    // Create a new alloca insertion point within the task frame.
    OldAllocaInsertPt = CGF.AllocaInsertPt;
    llvm::Value *Undef = llvm::UndefValue::get(CGF.Int32Ty);
    CGF.AllocaInsertPt = new llvm::BitCastInst(Undef, CGF.Int32Ty, "",
                                               CGF.Builder.GetInsertBlock());
    // SavedDetachedAllocaInsertPt = CGF.AllocaInsertPt;

    CreateTaskFrameEHState();

    CGF.pushFullExprCleanup<CallTaskEnd>(
        static_cast<CleanupKind>(EHCleanup | LifetimeMarker | TaskExit),
        TaskFrame);
  }
}

void CodeGenFunction::DetachScope::InitDetachScope() {
  // Create the detached and continue blocks.
  DetachedBlock = CGF.createBasicBlock("det.achd");
  ContinueBlock = CGF.createBasicBlock("det.cont");
}

void CodeGenFunction::DetachScope::PushSpawnedTaskTerminate() {
  CGF.pushFullExprCleanupImpl<CallDetRethrow>(
      // This cleanup should not be a TaskExit, because we've pushed a TaskExit
      // cleanup onto EHStack already, corresponding with the taskframe.
      static_cast<CleanupKind>(EHCleanup | LifetimeMarker),
      CGF.CurSyncRegion->getSyncRegionStart());
}

void CodeGenFunction::DetachScope::StartDetach() {
  InitDetachScope();

  // Set the detached block as the new alloca insertion point.
  TFAllocaInsertPt = CGF.AllocaInsertPt;
  llvm::Value *Undef = llvm::UndefValue::get(CGF.Int32Ty);
  CGF.AllocaInsertPt = new llvm::BitCastInst(Undef, CGF.Int32Ty, "",
                                             DetachedBlock);

  if (StmtCleanupsScope)
    StmtCleanupsScope->DoDetach();
  else
    PushSpawnedTaskTerminate();

  // Create the detach
  Detach = CGF.Builder.CreateDetach(DetachedBlock, ContinueBlock,
                                    CGF.CurSyncRegion->getSyncRegionStart());

  // Save the old EH state.
  CreateDetachedEHState();

  // Emit the detached block.
  CGF.EmitBlock(DetachedBlock);

  // Link this detach block to the task frame, if it exists.
  if (TaskFrame) {
    llvm::Function *TaskFrameUse =
        CGF.CGM.getIntrinsic(llvm::Intrinsic::taskframe_use);
    CGF.Builder.CreateCall(TaskFrameUse, { TaskFrame });
  }

  // For Cilk, ensure that the detached task is implicitly synced before it
  // returns.
  CGF.PushSyncRegion()->addImplicitSync();

  // Initialize lifetime intrinsics for the reference temporary.
  if (RefTmp.isValid()) {
    switch (RefTmpSD) {
    case SD_Automatic:
    case SD_FullExpression:
      if (auto *Size = CGF.EmitLifetimeStart(
              CGF.CGM.getDataLayout().getTypeAllocSize(RefTmp.getElementType()),
              RefTmp.getPointer())) {
        if (RefTmpSD == SD_Automatic)
          CGF.pushCleanupAfterFullExpr<CallLifetimeEnd>(NormalEHLifetimeMarker,
                                                        RefTmp, Size);
        else
          CGF.pushFullExprCleanup<CallLifetimeEnd>(NormalEHLifetimeMarker,
                                                   RefTmp, Size);
      }
      break;
    default:
      break;
    }
  }

  DetachStarted = true;
}

void CodeGenFunction::DetachScope::CleanupDetach() {
  if (!DetachStarted || DetachCleanedUp)
    return;

  // Pop the sync region for the detached task.
  CGF.PopSyncRegion();
  DetachCleanedUp = true;
}

void CodeGenFunction::DetachScope::EmitTaskEnd() {
  if (!CGF.HaveInsertPoint())
    return;

  // The CFG path into the spawned statement should terminate with a `reattach'.
  CGF.Builder.CreateReattach(ContinueBlock,
                             CGF.CurSyncRegion->getSyncRegionStart());
}

static void EmitTrivialLandingPad(CodeGenFunction &CGF,
                                  llvm::BasicBlock *TempInvokeDest) {
  // Save the current IR generation state.
  CGBuilderTy::InsertPoint savedIP = CGF.Builder.saveAndClearIP();

  // Insert a simple cleanup landingpad at the start of TempInvokeDest.
  TempInvokeDest->setName("lpad");
  CGF.EmitBlock(TempInvokeDest);
  CGF.Builder.SetInsertPoint(&TempInvokeDest->front());

  llvm::LandingPadInst *LPadInst =
      CGF.Builder.CreateLandingPad(llvm::StructType::get(CGF.Int8PtrTy,
                                                         CGF.Int32Ty), 0);

  llvm::Value *LPadExn = CGF.Builder.CreateExtractValue(LPadInst, 0);
  CGF.Builder.CreateStore(LPadExn, CGF.getExceptionSlot());
  llvm::Value *LPadSel = CGF.Builder.CreateExtractValue(LPadInst, 1);
  CGF.Builder.CreateStore(LPadSel, CGF.getEHSelectorSlot());

  LPadInst->setCleanup(true);

  // Restore the old IR generation state.
  CGF.Builder.restoreIP(savedIP);
}

void CodeGenFunction::DetachScope::FinishDetach() {
  if (!DetachStarted)
    return;

  CleanupDetach();
  // Pop the detached_rethrow.
  CGF.PopCleanupBlock();

  EmitTaskEnd();

  // Restore the alloca insertion point to taskframe_create.
  {
    llvm::Instruction *Ptr = CGF.AllocaInsertPt;
    CGF.AllocaInsertPt = TFAllocaInsertPt;
    SavedDetachedAllocaInsertPt = nullptr;
    Ptr->eraseFromParent();
  }

  // Restore the task frame's EH state.
  llvm::BasicBlock *TaskResumeBlock = RestoreTaskFrameEHState();
  assert(!TaskResumeBlock && "Emission of task produced a resume block");

  llvm::BasicBlock *InvokeDest = nullptr;
  if (TempInvokeDest) {
    InvokeDest = CGF.getInvokeDest();
    if (InvokeDest)
      TempInvokeDest->replaceAllUsesWith(InvokeDest);
    else {
      InvokeDest = TempInvokeDest;
      EmitTrivialLandingPad(CGF, TempInvokeDest);
      TempInvokeDest = nullptr;
    }
  }

  // Emit the continue block.
  CGF.EmitBlock(ContinueBlock);

  // If the detached-rethrow handler is used, add an unwind destination to the
  // detach.
  if (InvokeDest) {
    CGBuilderTy::InsertPoint SavedIP = CGF.Builder.saveIP();
    CGF.Builder.SetInsertPoint(Detach);
    // Create the new detach instruction.
    llvm::DetachInst *NewDetach = CGF.Builder.CreateDetach(
        Detach->getDetached(), Detach->getContinue(), InvokeDest,
        Detach->getSyncRegion());
    // Remove the old detach.
    Detach->eraseFromParent();
    Detach = NewDetach;
    CGF.Builder.restoreIP(SavedIP);
  }

  // Pop the taskframe.
  CGF.PopCleanupBlock();

  // Restore the alloca insertion point.
  {
    llvm::Instruction *Ptr = CGF.AllocaInsertPt;
    CGF.AllocaInsertPt = OldAllocaInsertPt;
    TFAllocaInsertPt = nullptr;
    Ptr->eraseFromParent();
  }

  // Restore the original EH state.
  llvm::BasicBlock *NestedEHResumeBlock = RestoreParentEHState();

  if (TempInvokeDest) {
    if (llvm::BasicBlock *InvokeDest = CGF.getInvokeDest()) {
      TempInvokeDest->replaceAllUsesWith(InvokeDest);
    } else
      EmitTrivialLandingPad(CGF, TempInvokeDest);
  }

  // If invocations in the parallel task led to the creation of EHResumeBlock,
  // we need to create for outside the task.  In particular, the new
  // EHResumeBlock must use an ExceptionSlot and EHSelectorSlot allocated
  // outside of the task.
  if (NestedEHResumeBlock) {
    if (!NestedEHResumeBlock->use_empty()) {
      // Translate the nested EHResumeBlock into an appropriate EHResumeBlock in
      // the outer scope.
      NestedEHResumeBlock->replaceAllUsesWith(
          CGF.getEHResumeBlock(
              isa<llvm::ResumeInst>(NestedEHResumeBlock->getTerminator())));
    }
    delete NestedEHResumeBlock;
  }
}

Address CodeGenFunction::DetachScope::CreateDetachedMemTemp(
    QualType Ty, StorageDuration SD, const Twine &Name) {
  // There shouldn't be multiple reference temporaries needed.
  assert(!RefTmp.isValid() &&
         "Already created a reference temporary in this detach scope.");

  // Create the reference temporary
  RefTmp = CGF.CreateMemTemp(Ty, Name);
  RefTmpSD = SD;

  return RefTmp;
}

CodeGenFunction::TaskFrameScope::TaskFrameScope(CodeGenFunction &CGF)
    : CGF(CGF) {
  if (LangOptions::Cilk_none == CGF.getLangOpts().getCilk())
    return;
  if (!CGF.CurSyncRegion)
    return;

  llvm::Function *TaskFrameCreate =
      CGF.CGM.getIntrinsic(llvm::Intrinsic::taskframe_create);
  TaskFrame = CGF.Builder.CreateCall(TaskFrameCreate);

  // Create a new alloca insertion point within the task frame.
  OldAllocaInsertPt = CGF.AllocaInsertPt;
  llvm::Value *Undef = llvm::UndefValue::get(CGF.Int32Ty);
  CGF.AllocaInsertPt = new llvm::BitCastInst(Undef, CGF.Int32Ty, "",
                                             CGF.Builder.GetInsertBlock());

  // Save the old EH state.
  OldEHResumeBlock = CGF.EHResumeBlock;
  CGF.EHResumeBlock = nullptr;
  OldExceptionSlot = CGF.ExceptionSlot;
  CGF.ExceptionSlot = nullptr;
  OldEHSelectorSlot = CGF.EHSelectorSlot;
  CGF.EHSelectorSlot = nullptr;
  OldNormalCleanupDest = CGF.NormalCleanupDest;
  CGF.NormalCleanupDest = Address::invalid();

  CGF.pushFullExprCleanup<EndUnassocTaskFrame>(
      static_cast<CleanupKind>(NormalAndEHCleanup | LifetimeMarker | TaskExit),
      this);
}

CodeGenFunction::TaskFrameScope::~TaskFrameScope() {
  if (LangOptions::Cilk_none == CGF.getLangOpts().getCilk())
    return;
  if (!CGF.CurSyncRegion)
    return;

  // Pop the taskframe.
  CGF.PopCleanupBlock();

  // Restore the alloca insertion point.
  {
    llvm::Instruction *Ptr = CGF.AllocaInsertPt;
    CGF.AllocaInsertPt = OldAllocaInsertPt;
    Ptr->eraseFromParent();
  }

  // Restore the original EH state.
  llvm::BasicBlock *NestedEHResumeBlock = CGF.EHResumeBlock;
  CGF.EHResumeBlock = OldEHResumeBlock;
  CGF.ExceptionSlot = OldExceptionSlot;
  CGF.EHSelectorSlot = OldEHSelectorSlot;
  CGF.NormalCleanupDest = OldNormalCleanupDest;

  if (TempInvokeDest) {
    if (llvm::BasicBlock *InvokeDest = CGF.getInvokeDest()) {
      TempInvokeDest->replaceAllUsesWith(InvokeDest);
    } else
      EmitTrivialLandingPad(CGF, TempInvokeDest);

    if (TempInvokeDest->use_empty())
      delete TempInvokeDest;
  }

  // If invocations in the parallel task led to the creation of EHResumeBlock,
  // we need to create for outside the task.  In particular, the new
  // EHResumeBlock must use an ExceptionSlot and EHSelectorSlot allocated
  // outside of the task.
  if (NestedEHResumeBlock) {
    if (!NestedEHResumeBlock->use_empty()) {
      // Translate the nested EHResumeBlock into an appropriate EHResumeBlock in
      // the outer scope.
      NestedEHResumeBlock->replaceAllUsesWith(
          CGF.getEHResumeBlock(
              isa<llvm::ResumeInst>(NestedEHResumeBlock->getTerminator())));
    }
    delete NestedEHResumeBlock;
  }
}

llvm::Instruction *CodeGenFunction::EmitSyncRegionStart() {
  // Start the sync region.  To ensure the syncregion.start call dominates all
  // uses of the generated token, we insert this call at the alloca insertion
  // point.
  auto NL = ApplyDebugLocation::CreateArtificial(*this);
  llvm::Instruction *SRStart = llvm::CallInst::Create(
      CGM.getIntrinsic(llvm::Intrinsic::syncregion_start),
      "syncreg", AllocaInsertPt);
  SRStart->setDebugLoc(Builder.getCurrentDebugLocation());
  return SRStart;
}

/// EmitCilkSyncStmt - Emit a _Cilk_sync node.
void CodeGenFunction::EmitCilkSyncStmt(const CilkSyncStmt &S) {
  llvm::BasicBlock *ContinueBlock = createBasicBlock("sync.continue");

  // Check if we are generating unreachable code.
  if (!HaveInsertPoint())
    // We don't need to generate actual code.
    return;

  // Generate a stoppoint if we are emitting debug info.
  EmitStopPoint(&S);

  EnsureSyncRegion();

  llvm::Instruction *SRStart = CurSyncRegion->getSyncRegionStart();

  Builder.CreateSync(ContinueBlock, SRStart);
  EmitBlock(ContinueBlock);
  if (getLangOpts().Exceptions && !CurFn->doesNotThrow())
    EmitCallOrInvoke(CGM.getIntrinsic(llvm::Intrinsic::sync_unwind),
                     { SRStart });
}

void CodeGenFunction::EmitCilkScopeStmt(const CilkScopeStmt &S) {
  LexicalScope CilkScope(*this, S.getSourceRange());

  // If this _Cilk_scope is outermost in the function, emit
  // tapir_runtime_{start,end} intrinsics around the scope.
  bool ThisScopeIsOutermost = false;
  if (!WithinCilkScope) {
    WithinCilkScope = true;
    ThisScopeIsOutermost = true;
  }

  {
    // Add a taskframe around this scope in case there are other spawns outside
    // of this scope, which would need to be synced separately.
    TaskFrameScope TFScope(*this);
    if (ThisScopeIsOutermost && !CurSyncRegion) {
      llvm::Instruction *TapirRTStart = Builder.CreateCall(
          CGM.getIntrinsic(llvm::Intrinsic::tapir_runtime_start));
      // Mark the end of the _Cilk_scope with tapir_runtime_end.
      EHStack.pushCleanup<TapirRuntimeEndCleanup>(NormalAndEHCleanup,
                                                  TapirRTStart);
    }
    // Create a nested synced scope.
    SyncedScopeRAII SyncedScp(*this);
    PushSyncRegion()->addImplicitSync();
    bool BodyIsCompoundStmt = isa<CompoundStmt>(S.getBody());
    if (BodyIsCompoundStmt)
      ScopeIsSynced = true;

    // Emit the spawned statement.
    EmitStmt(S.getBody());

    PopSyncRegion();
  }

  // If this _Cilk_scope is outermost in the function, mark that CodeGen is no
  // longer emitting within a _Cilk_scope.
  if (ThisScopeIsOutermost)
    WithinCilkScope = false;
}

static const Stmt *IgnoreImplicitAndCleanups(const Stmt *S) {
  const Stmt *Current = S;
  if (auto *E = dyn_cast_or_null<Expr>(S))
    Current = E->IgnoreImplicit();
  const Stmt *Lasts = nullptr;
  while (Current != Lasts) {
    Lasts = Current;
    if (const auto *EWC = dyn_cast<ExprWithCleanups>(Current))
      Current = EWC->getSubExpr()->IgnoreImplicit();
  }
  return Current;
}

void CodeGenFunction::EmitCilkSpawnStmt(const CilkSpawnStmt &S) {
  // Handle spawning of calls in a special manner, to evaluate
  // arguments before spawn.
  if (isa<CallExpr>(IgnoreImplicitAndCleanups(S.getSpawnedStmt()))) {
    // Set up to perform a detach.
    assert(!IsSpawned &&
           "_Cilk_spawn statement found in spawning environment.");
    IsSpawned = true;
    PushDetachScope();

    // Emit the call.
    EmitStmt(S.getSpawnedStmt());

    // Finish the detach.
    if (IsSpawned) {
      if (!CurDetachScope->IsDetachStarted())
        FailedSpawnWarning(S.getBeginLoc());
      IsSpawned = false;
      PopDetachScope();
    }

    return;
  }

  // Otherwise, we assume that the programmer dealt with races correctly.

  // Set up to perform a detach.
  PushDetachScope();
  CurDetachScope->StartDetach();

  SyncedScopeRAII SyncedScp(*this);
  if (isa<CompoundStmt>(S.getSpawnedStmt()))
    ScopeIsSynced = true;

  // Emit the spawned statement.
  EmitStmt(S.getSpawnedStmt());

  // Finish the detach.
  PopDetachScope();
}

LValue CodeGenFunction::EmitCilkSpawnExprLValue(const CilkSpawnExpr *E) {
  assert(isa<CallExpr>(IgnoreImplicitAndCleanups(E->getSpawnedExpr())) &&
         "SpawnExprLValue does not spawn a call.");
  assert(!IsSpawned &&
         "_Cilk_spawn statement found in spawning environment.");
  IsSpawned = true;
  PushDetachScope();

  LValue LV = EmitLValue(E->getSpawnedExpr());

  // Finish the detach.
  if (IsSpawned) {
    if (!CurDetachScope->IsDetachStarted())
      FailedSpawnWarning(E->getExprLoc());
    IsSpawned = false;
    PopDetachScope();
  }
  return LV;
}

void CodeGenFunction::EmitCilkForStmt(const CilkForStmt &S,
                                      ArrayRef<const Attr *> ForAttrs) {
  JumpDest LoopExit = getJumpDestInCurrentScope("pfor.end");

  PushSyncRegion();
  llvm::Instruction *SyncRegion = EmitSyncRegionStart();
  CurSyncRegion->setSyncRegionStart(SyncRegion);

  llvm::BasicBlock *TempInvokeDest = createBasicBlock("temp.invoke.dest");

  LexicalScope ForScope(*this, S.getSourceRange());

  // Evaluate the first part before the loop.
  if (S.getInit())
    EmitStmt(S.getInit());

  llvm::BasicBlock *ExitBlock = LoopExit.getBlock();
  // If there are any cleanups between here and the loop-exit scope,
  // create a block to stage a loop exit along.
  if (ForScope.requiresCleanups())
    ExitBlock = createBasicBlock("pfor.initcond.cleanup");

  if (S.getLimitStmt()) {
    EmitStmt(S.getLimitStmt());

    // As long as the condition is true, iterate the loop.
    llvm::BasicBlock *PForPH = createBasicBlock("pfor.ph");

    // C99 6.8.5p2/p4: The first substatement is executed if the expression
    // compares unequal to 0.  The condition must be a scalar type.
    llvm::Value *BoolCondVal = EvaluateExprAsBool(S.getInitCond());
    Builder.CreateCondBr(
        BoolCondVal, PForPH, ExitBlock,
        createProfileWeightsForLoop(S.getInitCond(),
                                    getProfileCount(S.getBody())));

    if (ExitBlock != LoopExit.getBlock()) {
      EmitBlock(ExitBlock);
      EmitBranchThroughCleanup(LoopExit);
    }

    EmitBlock(PForPH);
  }
  if (S.getBeginStmt())
    EmitStmt(S.getBeginStmt());
  if (S.getEndStmt())
    EmitStmt(S.getEndStmt());

  assert(S.getCond() && "_Cilk_for loop has no condition");

  // Start the loop with a block that tests the condition.  If there's an
  // increment, the continue scope will be overwritten later.
  JumpDest Continue = getJumpDestInCurrentScope("pfor.cond");
  llvm::BasicBlock *CondBlock = Continue.getBlock();
  EmitBlock(CondBlock);

  LoopStack.setSpawnStrategy(LoopAttributes::DAC);
  const SourceRange &R = S.getSourceRange();
  LoopStack.push(CondBlock, CGM.getContext(), CGM.getCodeGenOpts(), ForAttrs,
                 SourceLocToDebugLoc(R.getBegin()),
                 SourceLocToDebugLoc(R.getEnd()));

  const Expr *Inc = S.getInc();
  assert(Inc && "_Cilk_for loop has no increment");
  Continue = getJumpDestInCurrentScope("pfor.inc");

  // Ensure that the _Cilk_for loop iterations are synced on exit from the loop.
  EHStack.pushCleanup<ImplicitSyncCleanup>(NormalCleanup, SyncRegion);

  // Create a cleanup scope for the condition variable cleanups.
  LexicalScope ConditionScope(*this, S.getSourceRange());

  // Variables to store the old alloca insert point.
  llvm::AssertingVH<llvm::Instruction> OldAllocaInsertPt;
  // Variables to store the old EH state.
  llvm::BasicBlock *OldEHResumeBlock;
  llvm::Value *OldExceptionSlot;
  llvm::AllocaInst *OldEHSelectorSlot;
  Address OldNormalCleanupDest = Address::invalid();

  const DeclStmt *LoopVar = S.getLoopVarStmt();
  const VarDecl *LoopVarDecl =
      LoopVar ? cast<VarDecl>(LoopVar->getSingleDecl()) : nullptr;
  RValue LoopVarInitRV;
  llvm::BasicBlock *DetachBlock;
  llvm::BasicBlock *ForBodyEntry;
  llvm::BasicBlock *ForBody;
  llvm::DetachInst *Detach;
  {
    // FIXME: Figure out if there is a way to support condition variables in
    // Cilk.
    //
    // // If the for statement has a condition scope, emit the local variable
    // // declaration.
    // if (S.getConditionVariable()) {
    //   EmitAutoVarDecl(*S.getConditionVariable());
    // }

    // If there are any cleanups between here and the loop-exit scope,
    // create a block to stage a loop exit along.
    if (ForScope.requiresCleanups())
      ExitBlock = createBasicBlock("pfor.cond.cleanup");

    // As long as the condition is true, iterate the loop.
    DetachBlock = createBasicBlock("pfor.detach");
    // Emit extra entry block for detached body, to ensure that this detached
    // entry block has just one predecessor.
    ForBodyEntry = createBasicBlock("pfor.body.entry");
    ForBody = createBasicBlock("pfor.body");

    EmitBranch(DetachBlock);

    EmitBlockAfterUses(DetachBlock);

    // Get the value of the loop variable initialization before we emit the
    // detach.
    if (LoopVar)
      LoopVarInitRV = EmitAnyExprToTemp(LoopVarDecl->getInit());

    Detach = Builder.CreateDetach(ForBodyEntry, Continue.getBlock(),
                                  SyncRegion);
    // Save the old alloca insert point.
    OldAllocaInsertPt = AllocaInsertPt;
    // Save the old EH state.
    OldEHResumeBlock = EHResumeBlock;
    OldExceptionSlot = ExceptionSlot;
    OldEHSelectorSlot = EHSelectorSlot;
    OldNormalCleanupDest = NormalCleanupDest;

    // Create a new alloca insert point.
    llvm::Value *Undef = llvm::UndefValue::get(Int32Ty);
    AllocaInsertPt = new llvm::BitCastInst(Undef, Int32Ty, "", ForBodyEntry);

    // Push a cleanup to make sure any exceptional exit from the loop is
    // terminated by a detached.rethrow.
    EHStack.pushCleanup<CallDetRethrow>(
        static_cast<CleanupKind>(EHCleanup | LifetimeMarker | TaskExit),
        SyncRegion, TempInvokeDest);

    // Set up nested EH state.
    EHResumeBlock = nullptr;
    ExceptionSlot = nullptr;
    EHSelectorSlot = nullptr;
    NormalCleanupDest = Address::invalid();

    EmitBlock(ForBodyEntry);
  }

  RunCleanupsScope DetachCleanupsScope(*this);

  // Set up a nested sync region for the loop body, and ensure it has an
  // implicit sync.
  PushSyncRegion()->addImplicitSync();

  // Store the blocks to use for break and continue.
  JumpDest Preattach = getJumpDestInCurrentScope("pfor.preattach");
  BreakContinueStack.push_back(BreakContinue(Preattach, Preattach));

  // Inside the detached block, create the loop variable, setting its value to
  // the saved initialization value.
  if (LoopVar) {
    AutoVarEmission LVEmission = EmitAutoVarAlloca(*LoopVarDecl);
    QualType type = LoopVarDecl->getType();
    Address Loc = LVEmission.getObjectAddress(*this);
    LValue LV = MakeAddrLValue(Loc, type);
    LV.setNonGC(true);
    EmitStoreThroughLValue(LoopVarInitRV, LV, true);
    EmitAutoVarCleanups(LVEmission);
  }

  Builder.CreateBr(ForBody);

  EmitBlock(ForBody);

  incrementProfileCounter(&S);

  {
    // Create a separate cleanup scope for the body, in case it is not
    // a compound statement.
    RunCleanupsScope BodyScope(*this);

    SyncedScopeRAII SyncedScp(*this);
    if (isa<CompoundStmt>(S.getBody()))
      ScopeIsSynced = true;
    EmitStmt(S.getBody());

    if (HaveInsertPoint())
      Builder.CreateBr(Preattach.getBlock());
  }

  // Finish detached body and emit the reattach.
  {
    EmitBlock(Preattach.getBlock());
    // The design of the exception-handling mechanism means we need to cleanup
    // the scope before popping the sync region.
    DetachCleanupsScope.ForceCleanup();
    PopSyncRegion();
    // Pop the detached.rethrow cleanup.
    PopCleanupBlock();
    Builder.CreateReattach(Continue.getBlock(), SyncRegion);
  }

  // Restore CGF state after detached region.
  llvm::BasicBlock *NestedEHResumeBlock;
  {
    // Restore the alloca insertion point.
    llvm::Instruction *Ptr = AllocaInsertPt;
    AllocaInsertPt = OldAllocaInsertPt;
    Ptr->eraseFromParent();

    // Restore the EH state.
    NestedEHResumeBlock = EHResumeBlock;
    EHResumeBlock = OldEHResumeBlock;
    ExceptionSlot = OldExceptionSlot;
    EHSelectorSlot = OldEHSelectorSlot;
    NormalCleanupDest = OldNormalCleanupDest;
  }

  // An invocation of the detached.rethrow intrinsic marks the end of an
  // exceptional return from the parallel-loop body.  That invoke needs a valid
  // landinpad as its unwind destination.  We create that unwind destination
  // here.
  llvm::BasicBlock *InvokeDest = nullptr;
  if (!TempInvokeDest->use_empty()) {
    InvokeDest = getInvokeDest();
    if (InvokeDest)
      TempInvokeDest->replaceAllUsesWith(InvokeDest);
    else {
      InvokeDest = TempInvokeDest;
      EmitTrivialLandingPad(*this, TempInvokeDest);
    }
  }

  // If invocations in the parallel task led to the creation of EHResumeBlock,
  // we need to create for outside the task.  In particular, the new
  // EHResumeBlock must use an ExceptionSlot and EHSelectorSlot allocated
  // outside of the task.
  if (NestedEHResumeBlock) {
    if (!NestedEHResumeBlock->use_empty()) {
      // Translate the nested EHResumeBlock into an appropriate EHResumeBlock in
      // the outer scope.
      NestedEHResumeBlock->replaceAllUsesWith(
          getEHResumeBlock(
              isa<llvm::ResumeInst>(NestedEHResumeBlock->getTerminator())));
    }
    delete NestedEHResumeBlock;
  }

  // Emit the increment next.
  EmitBlockAfterUses(Continue.getBlock());
  EmitStmt(Inc);

  {
    // If the detached-rethrow handler is used, add an unwind destination to the
    // detach.
    if (InvokeDest) {
      CGBuilderTy::InsertPoint SavedIP = Builder.saveIP();
      Builder.SetInsertPoint(Detach);
      // Create the new detach instruction.
      llvm::DetachInst *NewDetach = Builder.CreateDetach(
          ForBodyEntry, Continue.getBlock(), InvokeDest,
          SyncRegion);
      // Remove the old detach.
      Detach->eraseFromParent();
      Detach = NewDetach;
      Builder.restoreIP(SavedIP);
    }
  }

  BreakContinueStack.pop_back();

  ConditionScope.ForceCleanup();

  EmitStopPoint(&S);

  // C99 6.8.5p2/p4: The first substatement is executed if the expression
  // compares unequal to 0.  The condition must be a scalar type.
  llvm::Value *BoolCondVal = EvaluateExprAsBool(S.getCond());
  Builder.CreateCondBr(
      BoolCondVal, CondBlock, ExitBlock,
      createProfileWeightsForLoop(S.getCond(), getProfileCount(S.getBody())));

  if (ExitBlock != LoopExit.getBlock()) {
    EmitBlock(ExitBlock);
    EmitBranchThroughCleanup(LoopExit);
  }

  ForScope.ForceCleanup();

  LoopStack.pop();
  // Emit the fall-through block.
  EmitBlock(LoopExit.getBlock(), true);
  PopSyncRegion();

  if (TempInvokeDest->use_empty())
    delete TempInvokeDest;
}
