// RUN: %clang_cc1 %s -xc -fopencilk -verify -fsyntax-only
// RUN: %clang_cc1 %s -xc++ -fopencilk -verify -fsyntax-only

void f()
{
  (void)(int)1;
  (void)(_Hyperobject int)1; // expected-error{{cast to hyperobject}}
  // A complaint about an incomplete type would also be correct.
  (void)(_Hyperobject struct S)1; // expected-error{{cast to hyperobject}}
}
