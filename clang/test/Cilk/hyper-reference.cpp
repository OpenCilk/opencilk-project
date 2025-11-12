// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// expected-no-diagnostics
extern void identity(void *), reduce(void *, void *);
extern void f(int &, int _Hyperobject(identity, reduce) &);
void g(int _Hyperobject(identity, reduce) *p)
{
  f(*p, *p);
}
