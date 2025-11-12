// RUN: %clang_cc1 %s -xc -fopencilk -verify -fsyntax-only
extern void identity(void *), reduce(void *, void *);
int f(int _Hyperobject(identity, reduce) x)
// expected-error@-1{{parameter is hyperobject}}
{
  return x;
}
