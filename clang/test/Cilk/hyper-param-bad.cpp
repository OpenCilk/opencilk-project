// RUN: %clang_cc1 %s -xc++ -fopencilk -verify -fsyntax-only
struct S
{
  void fn(int _Hyperobject); // expected-error{{parameter is hyperobject}}
};

extern int f(int _Hyperobject x); // expected-error{{parameter is hyperobject}} expected-note{{candidate function not viable}}

void g()
{
  f(1); // expected-error{{no matching function for call to 'f'}}
}
