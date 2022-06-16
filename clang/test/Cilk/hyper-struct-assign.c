// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only

struct S { long _Hyperobject field; };
extern struct S x, y;

struct S simple_assign(long val)
{
  struct S tmp = {val};
  return x = tmp; // expected-error{{unimplemented assignment to structure with hyperobject member}}
}
