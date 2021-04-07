//===--- ParseCilk.cpp - Cilk Parsing -------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file implements the Cilk portions of the Parser interface.
//
//===----------------------------------------------------------------------===//

#include "clang/Parse/RAIIObjectsForParser.h"
#include "clang/Parse/Parser.h"

using namespace clang;

/// ParseCilkSyncStatement
///       cilk_sync-statement:
///         '_Cilk_sync' ';'
StmtResult Parser::ParseCilkSyncStatement() {
  assert(Tok.is(tok::kw__Cilk_sync) && "Not a _Cilk_sync stmt!");
  return Actions.ActOnCilkSyncStmt(ConsumeToken());
}

/// ParseCilkSpawnStatement
///       cilk_spawn-statement:
///         '_Cilk_spawn' statement
StmtResult Parser::ParseCilkSpawnStatement() {
  assert(Tok.is(tok::kw__Cilk_spawn) && "Not a _Cilk_spawn stmt!");
  SourceLocation SpawnLoc = ConsumeToken();  // eat the '_Cilk_spawn'.

  unsigned ScopeFlags = Scope::BlockScope | Scope::FnScope | Scope::DeclScope;

  if (Tok.is(tok::l_brace)) {
    StmtResult SubStmt = ParseCompoundStatement(false, ScopeFlags |
                                                Scope::CompoundStmtScope);
    if (SubStmt.isInvalid())
      return StmtError();

    return Actions.ActOnCilkSpawnStmt(SpawnLoc, SubStmt.get());
  }

  ParseScope CilkSpawnScope(this, ScopeFlags);

  // Parse statement of spawned child
  StmtResult SubStmt = ParseStatement();
  CilkSpawnScope.Exit();

  if (SubStmt.isInvalid())
    return StmtError();

  return Actions.ActOnCilkSpawnStmt(SpawnLoc, SubStmt.get());
}

/// ParseCilkForStatement
///       cilk_for-statement:
///         '_Cilk_for' '(' expr ';' expr ';' expr ')' statement
///         '_Cilk_for' '(' declaration expr ';' expr ';' expr ')' statement
/// [C++0x] '_Cilk_for'
///             '(' for-range-declaration ':' for-range-initializer ')'
///             statement
///
/// [C++0x] for-range-declaration:
/// [C++0x]   attribute-specifier-seq[opt] type-specifier-seq declarator
/// [C++0x] for-range-initializer:
/// [C++0x]   expression
/// [C++0x]   braced-init-list

StmtResult Parser::ParseCilkForStatement(SourceLocation *TrailingElseLoc) {
  assert(Tok.is(tok::kw__Cilk_for) && "Not a _Cilk_for stmt!");
  SourceLocation ForLoc = ConsumeToken(); // eat the '_Cilk_for'.

  // SourceLocation CoawaitLoc;
  // if (Tok.is(tok::kw_co_await))
  //   CoawaitLoc = ConsumeToken();

  if (Tok.isNot(tok::l_paren)) {
    Diag(Tok, diag::err_expected_lparen_after) << "_Cilk_for";
    SkipUntil(tok::semi);
    return StmtError();
  }

  bool C99orCXXorObjC =
      getLangOpts().C99 || getLangOpts().CPlusPlus || getLangOpts().ObjC;

  // A _Cilk_for statement is a block.  Start the loop scope.
  //
  // C++ 6.4p3:
  // A name introduced by a declaration in a condition is in scope from its
  // point of declaration until the end of the substatements controlled by the
  // condition.
  // C++ 3.3.2p4:
  // Names declared in the for-init-statement, and in the condition of if,
  // while, for, and switch statements are local to the if, while, for, or
  // switch statement (including the controlled statement).
  // C++ 6.5.3p1:
  // Names declared in the for-init-statement are in the same declarative-region
  // as those declared in the condition.
  //
  unsigned ScopeFlags = Scope::DeclScope | Scope::ControlScope;

  ParseScope CilkForScope(this, ScopeFlags);

  BalancedDelimiterTracker T(*this, tok::l_paren);
  T.consumeOpen();

  ExprResult Value;

  bool ForEach = false;
  StmtResult FirstPart;
  Sema::ConditionResult SecondPart;
  ExprResult Collection;
  ForRangeInfo ForRangeInfo;
  FullExprArg ThirdPart(Actions);

  if (Tok.is(tok::code_completion)) {
    Actions.CodeCompleteOrdinaryName(getCurScope(), Sema::PCC_ForInit);
    cutOffParsing();
    return StmtError();
  }

  ParsedAttributesWithRange attrs(AttrFactory);
  MaybeParseCXX11Attributes(attrs);

  SourceLocation EmptyInitStmtSemiLoc;

  // Parse the first part of the for specifier.
  if (Tok.is(tok::semi)) { // _Cilk_for (;
    ProhibitAttributes(attrs);
    // We disallow this syntax for now.
    Diag(Tok, diag::err_cilk_for_missing_control_variable) << ";";
    ConsumeToken();
  } else if (getLangOpts().CPlusPlus && Tok.is(tok::identifier) &&
             isForRangeIdentifier()) {
    ProhibitAttributes(attrs);
    IdentifierInfo *Name = Tok.getIdentifierInfo();
    SourceLocation Loc = ConsumeToken();
    MaybeParseCXX11Attributes(attrs);

    ForRangeInfo.ColonLoc = ConsumeToken();
    if (Tok.is(tok::l_brace))
      ForRangeInfo.RangeExpr = ParseBraceInitializer();
    else
      ForRangeInfo.RangeExpr = ParseExpression();

    Diag(Loc, diag::err_for_range_identifier)
        << ((getLangOpts().CPlusPlus11 && !getLangOpts().CPlusPlus17)
                ? FixItHint::CreateInsertion(Loc, "auto &&")
                : FixItHint());

    ForRangeInfo.LoopVar = Actions.ActOnCXXForRangeIdentifier(
        getCurScope(), Loc, Name, attrs, attrs.Range.getEnd());
  } else if (isForInitDeclaration()) { // _Cilk_for (int X = 4;
    // Parse declaration, which eats the ';'.
    if (!C99orCXXorObjC) // Use of C99-style for loops in C90 mode?
      Diag(Tok, diag::ext_c99_variable_decl_in_for_loop);

    // In C++0x, "for (T NS:a" might not be a typo for ::
    bool MightBeForRangeStmt = getLangOpts().CPlusPlus;
    ColonProtectionRAIIObject ColonProtection(*this, MightBeForRangeStmt);

    SourceLocation DeclStart = Tok.getLocation(), DeclEnd;
    DeclGroupPtrTy DG = ParseSimpleDeclaration(
        DeclaratorContext::ForContext, DeclEnd, attrs, false,
        MightBeForRangeStmt ? &ForRangeInfo : nullptr);
    FirstPart = Actions.ActOnDeclStmt(DG, DeclStart, Tok.getLocation());
    if (ForRangeInfo.ParsedForRangeDecl()) {
      Diag(ForRangeInfo.ColonLoc, getLangOpts().CPlusPlus11
                                      ? diag::warn_cxx98_compat_for_range
                                      : diag::ext_for_range);
      ForRangeInfo.LoopVar = FirstPart;
      FirstPart = StmtResult();
    } else if (Tok.is(tok::semi)) { // for (int x = 4;
      ConsumeToken();
    } else if ((ForEach = isTokIdentifier_in())) {
      Actions.ActOnForEachDeclStmt(DG);
      // ObjC: for (id x in expr)
      ConsumeToken(); // consume 'in'

      if (Tok.is(tok::code_completion)) {
        Actions.CodeCompleteObjCForCollection(getCurScope(), DG);
        cutOffParsing();
        return StmtError();
      }
      Collection = ParseExpression();
    } else {
      Diag(Tok, diag::err_expected_semi_for);
    }
  } else {
    ProhibitAttributes(attrs);
    Value = Actions.CorrectDelayedTyposInExpr(ParseExpression());

    ForEach = isTokIdentifier_in();

    // Turn the expression into a stmt.
    if (!Value.isInvalid()) {
      if (ForEach)
        FirstPart = Actions.ActOnForEachLValueExpr(Value.get());
      else {
        // We already know this is not an init-statement within a for loop, so
        // if we are parsing a C++11 range-based for loop, we should treat this
        // expression statement as being a discarded value expression because
        // we will err below. This way we do not warn on an unused expression
        // that was an error in the first place, like with: for (expr : expr);
        bool IsRangeBasedFor =
            getLangOpts().CPlusPlus11 && !ForEach && Tok.is(tok::colon);
        FirstPart = Actions.ActOnExprStmt(Value, !IsRangeBasedFor);
      }
    }

    if (Tok.is(tok::semi)) {
      ConsumeToken();
    } else if (ForEach) {
      ConsumeToken(); // consume 'in'

      if (Tok.is(tok::code_completion)) {
        Actions.CodeCompleteObjCForCollection(getCurScope(), nullptr);
        cutOffParsing();
        return StmtError();
      }
      Collection = ParseExpression();
    } else if (getLangOpts().CPlusPlus11 && Tok.is(tok::colon) &&
               FirstPart.get()) {
      // User tried to write the reasonable, but ill-formed, for-range-statement
      //   for (expr : expr) { ... }
      Diag(Tok, diag::err_for_range_expected_decl)
          << FirstPart.get()->getSourceRange();
      SkipUntil(tok::r_paren, StopBeforeMatch);
      SecondPart = Sema::ConditionError();
    } else {
      if (!Value.isInvalid()) {
        Diag(Tok, diag::err_expected_semi_for);
      } else {
        // Skip until semicolon or rparen, don't consume it.
        SkipUntil(tok::r_paren, StopAtSemi | StopBeforeMatch);
        if (Tok.is(tok::semi))
          ConsumeToken();
      }
    }
  }

  // Parse the second part of the for specifier.
  getCurScope()->AddFlags(Scope::BreakScope | Scope::ContinueScope);
  if (!ForEach && !ForRangeInfo.ParsedForRangeDecl() &&
      !SecondPart.isInvalid()) {
    // Parse the second part of the for specifier.
    if (Tok.is(tok::semi)) { // for (...;;
      // no second part.
      Diag(Tok, diag::err_cilk_for_missing_condition)
          << FirstPart.get()->getSourceRange();
    } else if (Tok.is(tok::r_paren)) {
      // missing both semicolons.
      Diag(Tok, diag::err_cilk_for_missing_condition)
          << FirstPart.get()->getSourceRange();
    } else {
      if (getLangOpts().CPlusPlus) {
        // C++2a: We've parsed an init-statement; we might have a
        // for-range-declaration next.
        bool MightBeForRangeStmt = !ForRangeInfo.ParsedForRangeDecl();
        ColonProtectionRAIIObject ColonProtection(*this, MightBeForRangeStmt);
        SecondPart =
            ParseCXXCondition(nullptr, ForLoc, Sema::ConditionKind::Boolean);

        if (ForRangeInfo.ParsedForRangeDecl()) {
          Diag(FirstPart.get() ? FirstPart.get()->getBeginLoc()
                               : ForRangeInfo.ColonLoc,
               getLangOpts().CPlusPlus2a
                   ? diag::warn_cxx17_compat_for_range_init_stmt
                   : diag::ext_for_range_init_stmt)
              << (FirstPart.get() ? FirstPart.get()->getSourceRange()
                                  : SourceRange());
          if (EmptyInitStmtSemiLoc.isValid()) {
            Diag(EmptyInitStmtSemiLoc, diag::warn_empty_init_statement)
                << /*for-loop*/ 2
                << FixItHint::CreateRemoval(EmptyInitStmtSemiLoc);
          }
        }
      } else {
        ExprResult SecondExpr = ParseExpression();
        if (SecondExpr.isInvalid())
          SecondPart = Sema::ConditionError();
        else
          SecondPart =
              Actions.ActOnCondition(getCurScope(), ForLoc, SecondExpr.get(),
                                     Sema::ConditionKind::Boolean);
      }
    }

    if (!ForEach && !ForRangeInfo.ParsedForRangeDecl()) {
      if (Tok.isNot(tok::semi)) {
        if (!SecondPart.isInvalid())
          Diag(Tok, diag::err_expected_semi_for);
        else
          // Skip until semicolon or rparen, don't consume it.
          SkipUntil(tok::r_paren, StopAtSemi | StopBeforeMatch);
      }

      if (Tok.is(tok::semi)) {
        ConsumeToken();
      }

      // Parse the third part of the _Cilk_for specifier.
      if (Tok.isNot(tok::r_paren)) { // for (...;...;)
        ExprResult Third = ParseExpression();
        // FIXME: The C++11 standard doesn't actually say that this is a
        // discarded-value expression, but it clearly should be.
        ThirdPart = Actions.MakeFullDiscardedValueExpr(Third.get());
      } else
        Diag(Tok, diag::err_cilk_for_missing_increment)
            << FirstPart.get()->getSourceRange();
    }
  }
  // Match the ')'.
  T.consumeClose();

  // // C++ Coroutines [stmt.iter]:
  // //   'co_await' can only be used for a range-based for statement.
  // if (CoawaitLoc.isValid() && !ForRange) {
  //   Diag(CoawaitLoc, diag::err_for_co_await_not_range_for);
  //   CoawaitLoc = SourceLocation();
  // }

  // We need to perform most of the semantic analysis for a C++0x for-range
  // statement before parsing the body, in order to be able to deduce the type
  // of an auto-typed loop variable.
  StmtResult ForRangeStmt;
  // StmtResult ForEachStmt;

  if (ForRangeInfo.ParsedForRangeDecl()) {
    Diag(ForLoc, diag::warn_cilk_for_forrange_loop_experimental);
    ExprResult CorrectedRange =
        Actions.CorrectDelayedTyposInExpr(ForRangeInfo.RangeExpr.get());
    ForRangeStmt = Actions.ActOnCilkForRangeStmt(
        getCurScope(), ForLoc, FirstPart.get(), ForRangeInfo.LoopVar.get(),
        ForRangeInfo.ColonLoc, CorrectedRange.get(), T.getCloseLocation(),
        Sema::BFRK_Build);

    // Similarly, we need to do the semantic analysis for a for-range
    // statement immediately in order to close over temporaries correctly.
  } else if (ForEach) {
    Diag(ForLoc, diag::err_cilk_for_foreach_loop_not_supported);
    // ForEachStmt = Actions.ActOnObjCForCollectionStmt(ForLoc,
    //                                                  FirstPart.get(),
    //                                                  Collection.get(),
    //                                                  T.getCloseLocation());
  }
  // else {
  //   // In OpenMP loop region loop control variable must be captured and be
  //   // private. Perform analysis of first part (if any).
  //   if (getLangOpts().OpenMP && FirstPart.isUsable()) {
  //     Actions.ActOnOpenMPLoopInitialization(ForLoc, FirstPart.get());
  //   }
  // }

  // The body of the _Cilk_for statement is a scope, even if there is no
  // compound stmt.  We only do this if the body isn't a compound statement to
  // avoid push/pop in common cases.
  //
  // C++ 6.5p2:
  // The substatement in an iteration-statement implicitly defines a local scope
  // which is entered and exited each time through the loop.
  //
  // See comments in ParseIfStatement for why we create a scope for
  // for-init-statement/condition and a new scope for substatement in C++.
  //
  ParseScope InnerScope(this, Scope::DeclScope, true, Tok.is(tok::l_brace));

  // The body of the for loop has the same local mangling number as the
  // for-init-statement.
  // It will only be incremented if the body contains other things that would
  // normally increment the mangling number (like a compound statement).
  getCurScope()->decrementMSManglingNumber();
  // if (C99orCXXorObjC)
  //   getCurScope()->decrementMSManglingNumber();

  // Read the body statement.
  StmtResult Body(ParseStatement(TrailingElseLoc));

  // Pop the body scope if needed.
  InnerScope.Exit();

  // Leave the for-scope.
  CilkForScope.Exit();

  if (Body.isInvalid())
    return StmtError();

  // if (ForEach)
  //  return Actions.FinishObjCForCollectionStmt(ForEachStmt.get(),
  //                                             Body.get());

  if (ForRangeInfo.ParsedForRangeDecl())
    return Actions.FinishCilkForRangeStmt(ForRangeStmt.get(), Body.get());

  return Actions.ActOnCilkForStmt(ForLoc, T.getOpenLocation(), FirstPart.get(),
                                  nullptr, Sema::ConditionResult(), nullptr,
                                  nullptr, SecondPart, ThirdPart,
                                  T.getCloseLocation(), Body.get());
}
