// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fopencilk -fsyntax-only -verify

extern int f(int);

// CHECK_LABEL: stmt_expr_fn
void stmt_expr_fn(int arg)
{
  int x = cilk_spawn(f( ({cilk_sync; 1;}) ));
  // expected-error@-1{{'cilk_sync' cannot be used inside a statement expression}}
  int y = ({cilk_spawn f(2); -1;});
  // expected-error@-1{{'cilk_spawn' cannot be used inside a statement expression}}
  int z = cilk_spawn f(3);
}
