// RUN: %clang_cc1 %s -x c++ -O1 -fopencilk -verify -S -fsyntax-only
// RUN: %clang_cc1 --std=c++17 %s -x c++ -O1 -fopencilk -verify -S -fsyntax-only
// expected-no-diagnostics
// See opencilk-project issue 132.  The reference to hyperobject red
// does not have a dependent type but arises in a dependent context.

void zero(void *v) { *(int *)v = 0; }

void plus(void *l, void *r) { *(int *)l += *(int *)r; }

template <typename T> int f() {
  int _Hyperobject(zero, plus) red;
  red += 5;
  return red;
}

int main() { return f<int>(); }
