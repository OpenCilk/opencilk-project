// Bug 154: Spurious "not needed" warnings for reducer callbacks with -Wall.
// RUN: %clang_cc1 %s -x c++ -fopencilk -fsyntax-only -Wall -verify
// expected-no-diagnostics

static void identity_64(void *p) { *(long *)p = 0; }
static void sum_64(void *l, void *r) { *(long *)l += *(long *)r; }

template <class T>
T sum_cilk(){
  long _Hyperobject(identity_64, sum_64) sum = 0;
  return sum;
}

long f() {
  long total = sum_cilk<long>();
  return total;
}
