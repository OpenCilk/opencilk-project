// RUN: %clang_cc1 %s -xc -fopencilk -verify -fsyntax-only
// RUN: %clang_cc1 %s -xc++ -fopencilk -verify -fsyntax-only

void f()
{
  (void)(int)1;
  (void)(int _Hyperobject)1; // expected-error{{cast to hyperobject}}
  // TODO: It would be nicer to have only one error here.
  (void)(struct S _Hyperobject)1; // expected-error{{incomplete type 'struct S' may not be a hyperobject}} expected-error{{cast to hyperobject}} expected-note{{forward declaration}}
}
