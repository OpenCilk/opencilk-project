// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
extern void identity_short(void *, short *);
extern void reduce_short(void *, short *, short *);

int into(int x)
{
  if (x)
    goto skip; // expected-error{{cannot jump}}
  short _Hyperobject(reduce_short, identity_short) y; // expected-note{{jump bypasses initialization}}
skip:
  return y;
}
