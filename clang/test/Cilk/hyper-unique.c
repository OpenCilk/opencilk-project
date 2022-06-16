// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -fsyntax-only

extern void (*reduce)(void *, void *), (*identity)(void *);

extern int _Hyperobject(identity, reduce) x; // expected-note{{previous declaration is here}}
int _Hyperobject(identity, reduce) x; // expected-error{{redefinition of 'x' with a different type: 'int _Hyperobject(identity, reduce)' vs 'int _Hyperobject(identity, reduce)'}}

