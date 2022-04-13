// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// The text of the first two warnings differs between C and C++.
_Hyperobject struct A; // expected-warning{{'_Hyperobject' is not permitted on a declaration of a type}}
_Hyperobject struct B { int b; }; // expected-warning{{'_Hyperobject' is not permitted on a declaration of a type}}
struct C { _Hyperobject int c; };
_Hyperobject struct C c; // expected-warning{{type 'struct C', which contains a hyperobject, may not be a hyperobject}}
