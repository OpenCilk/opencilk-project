// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
extern void identity_short(short *);
extern void reduce_short(short *, short *);

int into(int x)
{
  if (x)
    goto skip; // expected-error{{cannot jump}}
  short _Hyperobject(identity_short, reduce_short) y; // expected-note{{jump bypasses initialization}}
skip:
  return y;
}
