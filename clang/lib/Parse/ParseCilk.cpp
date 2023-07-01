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

namespace {

enum MisleadingStatementKind { MSK_if, MSK_else, MSK_for, MSK_while };

struct MisleadingIndentationChecker {
  Parser &P;
  SourceLocation StmtLoc;
  SourceLocation PrevLoc;
  unsigned NumDirectives;
  MisleadingStatementKind Kind;
  bool ShouldSkip;
  MisleadingIndentationChecker(Parser &P, MisleadingStatementKind K,
                               SourceLocation SL)
      : P(P), StmtLoc(SL), PrevLoc(P.getCurToken().getLocation()),
        NumDirectives(P.getPreprocessor().getNumDirectives()), Kind(K),
        ShouldSkip(P.getCurToken().is(tok::l_brace)) {
    if (!P.MisleadingIndentationElseLoc.isInvalid()) {
      StmtLoc = P.MisleadingIndentationElseLoc;
      P.MisleadingIndentationElseLoc = SourceLocation();
    }
    if (Kind == MSK_else && !ShouldSkip)
      P.MisleadingIndentationElseLoc = SL;
  }

  /// Compute the column number will aligning tabs on TabStop (-ftabstop), this
  /// gives the visual indentation of the SourceLocation.
  static unsigned getVisualIndentation(SourceManager &SM, SourceLocation Loc) {
    unsigned TabStop = SM.getDiagnostics().getDiagnosticOptions().TabStop;

    unsigned ColNo = SM.getSpellingColumnNumber(Loc);
    if (ColNo == 0 || TabStop == 1)
      return ColNo;

    std::pair<FileID, unsigned> FIDAndOffset = SM.getDecomposedLoc(Loc);

    bool Invalid;
    StringRef BufData = SM.getBufferData(FIDAndOffset.first, &Invalid);
    if (Invalid)
      return 0;

    const char *EndPos = BufData.data() + FIDAndOffset.second;
    // FileOffset are 0-based and Column numbers are 1-based
    assert(FIDAndOffset.second + 1 >= ColNo &&
           "Column number smaller than file offset?");

    unsigned VisualColumn = 0; // Stored as 0-based column, here.
    // Loop from beginning of line up to Loc's file position, counting columns,
    // expanding tabs.
    for (const char *CurPos = EndPos - (ColNo - 1); CurPos != EndPos;
         ++CurPos) {
      if (*CurPos == '\t')
        // Advance visual column to next tabstop.
        VisualColumn += (TabStop - VisualColumn % TabStop);
      else
        VisualColumn++;
    }
    return VisualColumn + 1;
  }

  void Check() {
    Token Tok = P.getCurToken();
    if (P.getActions().getDiagnostics().isIgnored(
            diag::warn_misleading_indentation, Tok.getLocation()) ||
        ShouldSkip || NumDirectives != P.getPreprocessor().getNumDirectives() ||
        Tok.isOneOf(tok::semi, tok::r_brace) || Tok.isAnnotation() ||
        Tok.getLocation().isMacroID() || PrevLoc.isMacroID() ||
        StmtLoc.isMacroID() ||
        (Kind == MSK_else && P.MisleadingIndentationElseLoc.isInvalid())) {
      P.MisleadingIndentationElseLoc = SourceLocation();
      return;
    }
    if (Kind == MSK_else)
      P.MisleadingIndentationElseLoc = SourceLocation();

    SourceManager &SM = P.getPreprocessor().getSourceManager();
    unsigned PrevColNum = getVisualIndentation(SM, PrevLoc);
    unsigned CurColNum = getVisualIndentation(SM, Tok.getLocation());
    unsigned StmtColNum = getVisualIndentation(SM, StmtLoc);

    if (PrevColNum != 0 && CurColNum != 0 && StmtColNum != 0 &&
        ((PrevColNum > StmtColNum && PrevColNum == CurColNum) ||
         !Tok.isAtStartOfLine()) &&
        SM.getPresumedLineNumber(StmtLoc) !=
            SM.getPresumedLineNumber(Tok.getLocation()) &&
        (Tok.isNot(tok::identifier) ||
         P.getPreprocessor().LookAhead(0).isNot(tok::colon))) {
      P.Diag(Tok.getLocation(), diag::warn_misleading_indentation) << Kind;
      P.Diag(StmtLoc, diag::note_previous_statement);
    }
  }
};

}

/// ParseCilkForStatement
///       cilk_for-statement:
///         '_Cilk_for' '(' expr ';' expr ';' expr ')' statement
///         '_Cilk_for' '(' declaration expr ';' expr ';' expr ')' statement
StmtResult Parser::ParseCilkForStatement(SourceLocation *TrailingElseLoc) {
  assert(Tok.is(tok::kw__Cilk_for) && "Not a _Cilk_for stmt!");
  SourceLocation ForLoc = ConsumeToken();  // eat the '_Cilk_for'.

  // SourceLocation CoawaitLoc;
  // if (Tok.is(tok::kw_co_await))
  //   CoawaitLoc = ConsumeToken();

  if (Tok.isNot(tok::l_paren)) {
    Diag(Tok, diag::err_expected_lparen_after) << "_Cilk_for";
    SkipUntil(tok::semi);
    return StmtError();
  }

  bool C99orCXXorObjC = getLangOpts().C99 || getLangOpts().CPlusPlus ||
    getLangOpts().ObjC;

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
    cutOffParsing();
    Actions.CodeCompleteOrdinaryName(getCurScope(), Sema::PCC_ForInit);
    return StmtError();
  }

  ParsedAttributesWithRange attrs(AttrFactory);
  MaybeParseCXX11Attributes(attrs);

  SourceLocation EmptyInitStmtSemiLoc;

  // Parse the first part of the for specifier.
  if (Tok.is(tok::semi)) {  // _Cilk_for (;
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
  } else if (isForInitDeclaration()) {  // _Cilk_for (int X = 4;
    ParenBraceBracketBalancer BalancerRAIIObj(*this);

    // Parse declaration, which eats the ';'.
    if (!C99orCXXorObjC)   // Use of C99-style for loops in C90 mode?
      Diag(Tok, diag::ext_c99_variable_decl_in_for_loop);

    DeclGroupPtrTy DG;
    if (Tok.is(tok::kw_using)) {
      DG = ParseAliasDeclarationInInitStatement(DeclaratorContext::ForInit,
                                                attrs);
    } else {
      // In C++0x, "for (T NS:a" might not be a typo for ::
      bool MightBeForRangeStmt = getLangOpts().CPlusPlus;
      ColonProtectionRAIIObject ColonProtection(*this, MightBeForRangeStmt);

      SourceLocation DeclStart = Tok.getLocation(), DeclEnd;
      DeclGroupPtrTy DG = ParseSimpleDeclaration(
          DeclaratorContext::ForInit, DeclEnd, attrs, false,
          MightBeForRangeStmt ? &ForRangeInfo : nullptr);
      FirstPart = Actions.ActOnDeclStmt(DG, DeclStart, Tok.getLocation());
      if (ForRangeInfo.ParsedForRangeDecl()) {
        Diag(ForRangeInfo.ColonLoc, getLangOpts().CPlusPlus11 ?
             diag::warn_cxx98_compat_for_range : diag::ext_for_range);

        ForRangeInfo.LoopVar = FirstPart;
        FirstPart = StmtResult();
      } else if (Tok.is(tok::semi)) {  // for (int x = 4;
        ConsumeToken();
      } else if ((ForEach = isTokIdentifier_in())) {
        Actions.ActOnForEachDeclStmt(DG);
        // ObjC: for (id x in expr)
        ConsumeToken(); // consume 'in'

        if (Tok.is(tok::code_completion)) {
          cutOffParsing();
          Actions.CodeCompleteObjCForCollection(getCurScope(), DG);
          return StmtError();
        }
        Collection = ParseExpression();
      } else {
        Diag(Tok, diag::err_expected_semi_for);
      }
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
        cutOffParsing();
        Actions.CodeCompleteObjCForCollection(getCurScope(), nullptr);
        return StmtError();
      }
      Collection = ParseExpression();
    } else if (getLangOpts().CPlusPlus11 && Tok.is(tok::colon) && FirstPart.get()) {
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
  if (!ForEach && !ForRangeInfo.ParsedForRangeDecl() &&
      !SecondPart.isInvalid()) {
    // Parse the second part of the for specifier.
    if (Tok.is(tok::semi)) {  // for (...;;
      // no second part.
      Diag(Tok, diag::err_cilk_for_missing_condition);
    } else if (Tok.is(tok::r_paren)) {
      // missing both semicolons.
      Diag(Tok, diag::err_cilk_for_missing_condition);
    } else {
      if (getLangOpts().CPlusPlus) {
        // C++2a: We've parsed an init-statement; we might have a
        // for-range-declaration next.
        bool MightBeForRangeStmt = !ForRangeInfo.ParsedForRangeDecl();
        ColonProtectionRAIIObject ColonProtection(*this, MightBeForRangeStmt);
        SecondPart = ParseCXXCondition(
            nullptr, ForLoc, Sema::ConditionKind::Boolean,
            // FIXME: recovery if we don't see another semi!
            /*MissingOK=*/true, MightBeForRangeStmt ? &ForRangeInfo : nullptr,
            /*EnterForConditionScope*/ true);

        if (ForRangeInfo.ParsedForRangeDecl()) {
          Diag(FirstPart.get() ? FirstPart.get()->getBeginLoc()
                               : ForRangeInfo.ColonLoc,
               getLangOpts().CPlusPlus20
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
        // We permit 'continue' and 'break' in the condition of a for loop.
        getCurScope()->AddFlags(Scope::BreakScope | Scope::ContinueScope);

        ExprResult SecondExpr = ParseExpression();
        if (SecondExpr.isInvalid())
          SecondPart = Sema::ConditionError();
        else
          SecondPart = Actions.ActOnCondition(
              getCurScope(), ForLoc, SecondExpr.get(),
              Sema::ConditionKind::Boolean, /*MissingOK=*/true);
      }
    }
  }

  // Enter a break / continue scope, if we didn't already enter one while
  // parsing the second part.
  if (!(getCurScope()->getFlags() & Scope::ContinueScope))
    getCurScope()->AddFlags(Scope::BreakScope | Scope::ContinueScope);

  // Parse the third part of the for statement.
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
    if (Tok.isNot(tok::r_paren)) {   // for (...;...;)
      ExprResult Third = ParseExpression();
      // FIXME: The C++11 standard doesn't actually say that this is a
      // discarded-value expression, but it clearly should be.
      ThirdPart = Actions.MakeFullDiscardedValueExpr(Third.get());
    } else {
      Diag(Tok, diag::err_cilk_for_missing_increment);
    }
  }
  // Match the ')'.
  T.consumeClose();

  // // C++ Coroutines [stmt.iter]:
  // //   'co_await' can only be used for a range-based for statement.
  // if (CoawaitLoc.isValid() && !ForRangeInfo.ParsedForRangeDecl()) {
  //   Diag(CoawaitLoc, diag::err_for_co_await_not_range_for);
  //   CoawaitLoc = SourceLocation();
  // }

  // if (CoawaitLoc.isValid() && getLangOpts().CPlusPlus20)
  //   Diag(CoawaitLoc, diag::warn_deprecated_for_co_await);

  // // We need to perform most of the semantic analysis for a C++0x for-range
  // // statememt before parsing the body, in order to be able to deduce the type
  // // of an auto-typed loop variable.
  // StmtResult ForRangeStmt;
  // StmtResult ForEachStmt;

  // TODO: Extend _Cilk_for to support these.
  if (ForRangeInfo.ParsedForRangeDecl()) {
    Diag(ForLoc, diag::err_cilk_for_forrange_loop_not_supported);
    // ExprResult CorrectedRange =
    //     Actions.CorrectDelayedTyposInExpr(ForRangeInfo.RangeExpr.get());
    // ForRangeStmt = Actions.ActOnCXXForRangeStmt(
    //     getCurScope(), ForLoc, CoawaitLoc, FirstPart.get(),
    //     ForRangeInfo.LoopVar.get(), ForRangeInfo.ColonLoc, CorrectedRange.get(),
    //     T.getCloseLocation(), Sema::BFRK_Build);

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
  ParseScope InnerScope(this, Scope::DeclScope, /*C99orCXXorObjC*/ true,
                        Tok.is(tok::l_brace));

  // The body of the for loop has the same local mangling number as the
  // for-init-statement.
  // It will only be incremented if the body contains other things that would
  // normally increment the mangling number (like a compound statement).
  getCurScope()->decrementMSManglingNumber();

  MisleadingIndentationChecker MIChecker(*this, MSK_for, ForLoc);

  // Read the body statement.
  StmtResult Body(ParseStatement(TrailingElseLoc));

  if (Body.isUsable())
    MIChecker.Check();

  // Pop the body scope if needed.
  InnerScope.Exit();

  // Leave the for-scope.
  CilkForScope.Exit();

  if (Body.isInvalid())
    return StmtError();

  // if (ForEach)
  //   return Actions.FinishObjCForCollectionStmt(ForEachStmt.get(), Body.get());

  // if (ForRangeInfo.ParsedForRangeDecl())
  //   return Actions.FinishCXXForRangeStmt(ForRangeStmt.get(), Body.get());

  return Actions.ActOnCilkForStmt(ForLoc, T.getOpenLocation(), FirstPart.get(),
                                  nullptr, Sema::ConditionResult(), nullptr,
                                  nullptr, SecondPart, ThirdPart,
                                  T.getCloseLocation(), Body.get());
}

/// ParseCilkScopeStatement
///       cilk_scope-statement:
///         '_Cilk_scope' statement
StmtResult Parser::ParseCilkScopeStatement() {
  assert(Tok.is(tok::kw__Cilk_scope) && "Not a _Cilk_scope stmt!");
  SourceLocation ScopeLoc = ConsumeToken();  // eat the '_Cilk_scope'.

  // TODO: Decide whether to allow break statements in _Cilk_scopes.
  unsigned ScopeFlags = Scope::FnScope | Scope::DeclScope;

  if (Tok.is(tok::l_brace)) {
    StmtResult SubStmt = ParseCompoundStatement(false, ScopeFlags |
                                                Scope::CompoundStmtScope);
    if (SubStmt.isInvalid())
      return StmtError();

    return Actions.ActOnCilkScopeStmt(ScopeLoc, SubStmt.get());
  }

  ParseScope CilkScopeScope(this, ScopeFlags);

  // Parse statement of spawned child
  StmtResult SubStmt = ParseStatement();
  CilkScopeScope.Exit();

  if (SubStmt.isInvalid())
    return StmtError();

  return Actions.ActOnCilkScopeStmt(ScopeLoc, SubStmt.get());
}
