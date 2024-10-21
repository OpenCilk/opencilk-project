// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
extern void id(void *), reduce(void *, void *);
struct uninit_hyperobject {
  // expected-note@-1{{implicit copy}}
  // expected-note@-2{{implicit move}}
  // expected-note@-3{{implicit default}}
  int _Hyperobject(id, reduce) field;
  // expected-note@-1{{would not be initialized}}
};

// braced initializer lists do not work
uninit_hyperobject h1 = {-1};
// expected-error@-1{{no matching constructor for initialization}}

uninit_hyperobject h2;
// expected-error@-1{{implicitly-deleted default constructor}}

struct init_hyperobject {
  int _Hyperobject(id, reduce) field = 0;
};

init_hyperobject h3;
