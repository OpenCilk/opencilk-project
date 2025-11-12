// RUN: %clang_cc1 %s -x c++ -O1 -fopencilk -verify -fsyntax-only
template <class T>
class A { };

class B {
  A<B> a;
};

void identity(void* view) {}
void reduce(void* l, void* r) {}

B _Hyperobject(identity, reduce) b;

template <class T>
class C { T _Hyperobject(identity, reduce) *field; };
// expected-error@-1{{hyperobject has incomplete view type 'D'}}
// expected-error@-2{{function type 'void (void *)' may not be a hyperobject}}

class D { // expected-note{{}}}
  C<D> a; // expected-note{{}}}
};

D _Hyperobject(identity, reduce) d;

C<void(void *)> cfn;
// expected-note@-1{{in instantiation}}
