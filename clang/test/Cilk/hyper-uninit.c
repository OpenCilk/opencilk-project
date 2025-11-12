// RUN: %clang_cc1 %s -x c -fopencilk -verify -fsyntax-only -Wall
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -fsyntax-only -Wall
extern void identity(void *), reduce(void *, void *);

int f()
{
  int cilk_reducer(identity, reduce) x;
  // expected-note@-1{{declared here}}
  return x;
  // expected-warning@-1{{uninitialized when used}}
}
