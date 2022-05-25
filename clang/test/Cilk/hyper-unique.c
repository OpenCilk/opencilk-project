// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -fsyntax-only

extern void (*reduce)(void *, void *, void *), (*identity)(void *, void *);

extern int _Hyperobject(reduce, identity) x; // expected-note{{previous declaration is here}}
int _Hyperobject(reduce, identity) x; // expected-error{{redefinition of 'x' with a different type: 'int _Hyperobject(reduce, identity)' vs 'int _Hyperobject(reduce, identity)'}}

