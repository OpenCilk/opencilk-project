// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
extern void identity_short(void *, short *);
extern void reduce_short(void *, short *, short *);

int into(int x)
{
  if (x)
    goto skip; // expected-error{{cannot jump}}
  _Hyperobject short y __attribute__((reducer(reduce_short, identity_short))); // expected-note{{jump bypasses initialization}}
skip:
  return y;
}
