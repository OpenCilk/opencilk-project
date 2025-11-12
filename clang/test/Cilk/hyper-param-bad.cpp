// RUN: %clang_cc1 %s -xc++ -fopencilk -verify -fsyntax-only

extern "C" void identity(void *), reduce(void *, void *);

struct S
{
  void fn(int _Hyperobject(identity, reduce));
  // expected-error@-1{{parameter is hyperobject}}
};

extern int f(int _Hyperobject(identity, reduce) x); // expected-error{{parameter is hyperobject}} expected-note{{candidate function not viable}}

void g()
{
  f(1); // expected-error{{no matching function for call to 'f'}}
}
