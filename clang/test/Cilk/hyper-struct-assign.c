// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only

extern void identity(void *), reduce(void *, void *);

struct S { long _Hyperobject(identity, reduce) field; };
// expected-warning@-1{{reducer registration not implemented for structure members}}
extern struct S x, y;

struct S simple_assign(long val)
{
  struct S tmp = {val};
  return x = tmp; // expected-error{{unimplemented assignment to structure with hyperobject member}}
}
