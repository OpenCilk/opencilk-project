// RUN: %clang_cc1 %s -xc -fopencilk -verify -fsyntax-only
// RUN: %clang_cc1 %s -xc++ -fopencilk -verify -fsyntax-only

void f()
{
  (void)(int)1;
  (void)(_Hyperobject int)1; // expected-error{{cast to hyperobject}}
  // TODO: It would be nicer to have only one error here.
  (void)(_Hyperobject struct S)1; // expected-error{{incomplete type 'struct S' may not be a hyperobject}} expected-error{{cast to hyperobject}}
}
