// RUN: %clang_cc1 %s -xc -fopencilk -verify -fsyntax-only
int f(_Hyperobject int x) // expected-error{{parameter is hyperobject}}
{
  return x;
}
