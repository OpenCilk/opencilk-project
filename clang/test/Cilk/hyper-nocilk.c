// RUN: %clang_cc1 %s -verify -fsyntax-only
// RUN: %clang_cc1 -x c++ %s -verify -fsyntax-only

int _Hyperobject x; // expected-warning{{_Hyperobject ignored}}

extern void f(int _Hyperobject *); // expected-warning{{_Hyperobject ignored}}
extern void g(int *);
void h() {
  f(&x);
  g(&x);
}
