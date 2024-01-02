// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
extern void id(void *), reduce(void *, void *);
struct one_hyperobject {
  // expected-note@-1{{implicit copy}}
  // expected-note@-2{{implicit move}}
  // expected-note@-3{{implicit default}}
  int _Hyperobject(id, reduce) field;
};

// braced initializer lists do not work
one_hyperobject h1 = {-1};
// expected-error@-1{{no matching constructor for initialization}}

one_hyperobject h2;
