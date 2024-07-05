// RUN: %clang_cc1 -std=c++1z -fopencilk -fsyntax-only -verify %s

int main() { _Cilk_spawn return 0; } // expected-error{{cannot return from within a 'cilk_spawn' statement}}
