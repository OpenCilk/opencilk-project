// RUN: %clang_cc1 -fopencilk -fsyntax-only -verify %s

void bar(int x);

void foo(int x) {
  goto lbl1; // expected-error{{cannot jump from this goto statement to its label}}
  _Cilk_scope { // expected-note{{jump bypasses '_Cilk_scope'}}
    _Cilk_spawn bar(x);
  lbl1:
    bar(x-1);
  }
  bar(x+1);
}
