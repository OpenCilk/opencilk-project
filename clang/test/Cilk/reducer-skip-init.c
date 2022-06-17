// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
extern void identity_short(void *);
extern void reduce_short(void *, void *);

int into(int x)
{
  if (x)
    goto skip; // expected-error{{cannot jump}}
  short _Hyperobject(identity_short, reduce_short) y; // expected-note{{jump bypasses initialization}}
skip:
  return y;
}
