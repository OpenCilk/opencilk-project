// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// The text of the first two warnings differs between C and C++.
_Hyperobject struct A; // expected-warning{{'_Hyperobject' is not permitted on a declaration of a type}}
_Hyperobject struct B { int b; }; // expected-warning{{'_Hyperobject' is not permitted on a declaration of a type}}
struct C { _Hyperobject int c; };
_Hyperobject struct C c; // expected-error{{type 'struct C', which contains a hyperobject, may not be a hyperobject}}
_Hyperobject long d; // expected-note{{previous definition}}
void f() {
  extern _Hyperobject int d; // expected-error{{redeclaration of 'd' with a different type: '_Hyperobject int' vs '_Hyperobject long'}}
}
_Hyperobject char e; // expected-note{{previous definition}}
typedef _Hyperobject long long_h;
void g() {
  extern long_h e; // expected-error{{redeclaration of 'e'}}
}
