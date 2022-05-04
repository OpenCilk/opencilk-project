// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// There are too many warnings now.  The alternative is too few.
template <typename T>
struct Constructed {
  Constructed();
  ~Constructed();
  static void identity(void *, Constructed<T> *);
  static void reduce(Constructed<T> *left, Constructed<T> *right);
};

template<typename T>
using Alias
  __attribute__((reducer(Constructed<T>::reduce, Constructed<T>::identity)))
  // expected-warning@-1{{'reducer' attribute ignored when parsing type}}
  // expected-warning@-2{{attribute 'reducer' ignored, because it is not attached to a declaration}}
  =
  _Hyperobject
  Constructed<T>
  __attribute__((reducer(Constructed<T>::reduce, Constructed<T>::identity)))
  // expected-warning@-1{{'reducer' attribute ignored when parsing type}}
  ;

void f()
{
  Alias<int> local; // expected-note{{in instantiation}}
}

