// RUN: %clang_cc1 %s -xc -fopencilk -verify -fsyntax-only
int f(int _Hyperobject x) // expected-error{{parameter is hyperobject}}
{
  return x;
}
