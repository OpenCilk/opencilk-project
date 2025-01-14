// RUN: %clang_cc1 %s -fopencilk -fsyntax-only -verify
// RUN: %clang_cc1 %s -fsyntax-only -verify=nokeyword
// nokeyword-no-diagnostics
int cilk_spawn;
// expected-error@-1{{expected identifier}}
int cilk_sync = 1;
// expected-error@-1{{expected identifier}}
int cilk_scope = 2;
// expected-error@-1{{expected identifier}}
int cilk_for(int x)
// expected-error@-1{{expected identifier}}
{
  return cilk_spawn + cilk_sync + cilk_scope;
}
int cilk_reducer = 3;
// expected-error@-1{{expected identifier}}
