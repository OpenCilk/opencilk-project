// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// expected-no-diagnostics
extern void f(int &, int _Hyperobject &);
void g(int _Hyperobject *p)
{
  f(*p, *p);
}
