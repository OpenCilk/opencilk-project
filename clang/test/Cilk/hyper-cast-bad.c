// RUN: %clang_cc1 %s -xc -fopencilk -verify -fsyntax-only
// RUN: %clang_cc1 %s -xc++ -fopencilk -verify -fsyntax-only

extern void identity(void *), reduce(void *, void *);

void f()
{
  (void)(int)1;
  (void)(int _Hyperobject(identity, reduce))1;
  // expected-error@-1{{cast to hyperobject}}
  // TODO: It would be nicer to have only one error here.
  (void)(struct S _Hyperobject)1;
  // expected-error@-1{{hyperobject has incomplete view type 'struct S'}}
  // expected-note@-2{{forward declaration}}
  // expected-error@-3{{cast to hyperobject}}
}
