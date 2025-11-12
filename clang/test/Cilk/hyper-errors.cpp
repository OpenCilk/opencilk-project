// RUN: %clang_cc1 %s --std=c++20 -x c++ -fopencilk -verify -fsyntax-only

extern void reduce(void *, void *), identity(void *);

struct __reducer_base { };
extern "C" __reducer_base *__hyper_lookup_class(__reducer_base *);
struct __reducer_callbacks {
  __reducer_callbacks(__reducer_callbacks &) = delete;
};
extern "C" void *__hyper_lookup_internal_1(void *, const __reducer_callbacks &);

struct C : __reducer_base {
  int _Hyperobject(identity, reduce) c = 0;
  // expected-note@-1{{here}}
};
struct C _Hyperobject c;
// expected-error@-1{{view type 'struct C' contains a hyperobject}}

extern long _Hyperobject(identity, reduce) hyper_fn(void);
// expected-error@-1{{return hyperobject type}}

long _Hyperobject(identity, reduce) d; // expected-note{{previous definition}}
void f() {
  extern int _Hyperobject(identity, reduce) d;
  // expected-error@-1{{redeclaration of 'd' with a different type: 'int _Hyperobject(identity, reduce)' vs 'long _Hyperobject(identity, reduce)'}}
}
char _Hyperobject(identity, reduce) e; // expected-note{{previous definition}}
typedef long _Hyperobject(identity, reduce) long_h;
void g() {
  extern long_h e; // expected-error{{redeclaration of 'e'}}
}

struct D {
  int _Hyperobject(identity, reduce) field;
  // expected-note@-1{{here}}
};

int _Hyperobject(reduce, identity) h;
// expected-error@-1{{different number of parameters (1 vs 2)}}
// expected-error@-2{{different number of parameters (2 vs 1)}}

int _Hyperobject(x) i;
// expected-error@-1{{use of undeclared identifier 'x'}}
int get_i() { return i; }
// No additional error on reference to j.

int _Hyperobject(0) j;
// expected-error@-1{{reference to type 'const __reducer_callbacks' could not bind to an rvalue of type 'int'}}
int get_j() { return j; }
// No additional error on reference to j.

int _Hyperobject(0,0,0,0) k;
// expected-error@-1{{extra hyperobject callbacks ignored}}

int get_k() { return k; }
// No additional error on reference to k.

int _Hyperobject(0,1) x;
// expected-error@-1{{cannot initialize a parameter of type 'void (*)(void *, void *)' with an rvalue of type 'int'}}
// TODO: int get_x() { return x; }

template<typename View> struct T {
  static void identity(void *), reduce(void *, void *);
  View _Hyperobject(identity, reduce) field;
  // expected-error@-1{{qualified type 'const int' may not be a hyperobject}}
  // expected-error@-2{{view type 'int _Hyperobject(identity, reduce)' is a hyperobject}}
  // expected-error@-3{{type 'int &' may not be a hyperobject}}
  View &get_view() { return field; }
  // expected-error@-1{{non-const lvalue reference to type 'int' cannot bind to a value of unrelated type '}}
  // The text of the preceding error message is unimportant.
  // The compiler used to crash on on the preceding line.
  View &&get_view_xvalue() { return (View &&)field; }
  const View &get_view_const() const { return field; }
  T();
  ~T();
};

void function() {
  int _Hyperobject(typo1, reduce) var1 = 0;
  // expected-error@-1{{use of undeclared identifier 'typo1'}}
  int _Hyperobject(typo2, typo3) var2 = 0;
  // expected-error@-1{{use of undeclared identifier 'typo2'}}
  // NOTE: LLVM 21 removed delayed typo checks: https://github.com/llvm/llvm-project/pull/143423
  // no-expected-error@-2{{use of undeclared identifier 'typo3'}}
  int _Hyperobject(0, typo4) var3 = 0;
  // expected-error@-1{{use of undeclared identifier 'typo4'}}
  T<const int> var4;
  // expected-note@-1{{requested here}}
  T<int _Hyperobject(identity, reduce)> var5;
  // expected-note@-1{{requested here}}
  T<int> var6;
  T<int &> var7;
  // expected-note@-1{{requested here}}
  int &ref1 = var6.get_view();
  const int &ref2 = var6.get_view_const();
  int &&ref3 = var6.get_view_xvalue();
  var7.get_view();
  // expected-note@-1{{requested here}}
}

int _Hyperobject xx;
// expected-error@-1{{view type must be a class when hyperobject has no callbacks}}
int _Hyperobject(nullptr) yy;
// expected-error@-1{{reference to type 'const __reducer_callbacks' could not bind to an rvalue of type 'std::nullptr_t'}}
int _Hyperobject(nullptr, nullptr) zz;
// Currently OK to declare this unusable type.

template<__reducer_callbacks &C>
struct U { int _Hyperobject(C) field = 0; };
// expected-note@-2{{template parameter is declared here}}
// expected-note@-3{{template parameter is declared here}}
// expected-note@-4{{template parameter is declared here}}

extern struct Random {} random;
extern struct Derived : __reducer_callbacks { } derived;

U<nullptr> u0;
// expected-error@-1{{value of type 'std::nullptr_t' is not implicitly convertible to '__reducer_callbacks &'}}
// this generates a "template parameter is declared here" note above
U<random> u1;
// expected-error@-1{{value of type 'struct Random' is not implicitly convertible to '__reducer_callbacks &'}}
// this generates a "template parameter is declared here" note above
U<derived> u2;
// expected-error@-1{{conversion from 'struct Derived' to '__reducer_callbacks &' is not allowed in a converted constant expression}}
// this generates a "template parameter is declared here" note above
// The preceding error is not designed in but is a consequence of template
// rules.  The argument is supposed to be constant and implicit type
// conversions are not performed for a "converted constant expression".
U<static_cast<__reducer_callbacks &>(derived)> u3;

template<int I> struct V { int _Hyperobject(I) field = I; };
// expected-error@-1{{const __reducer_callbacks' could not bind to an rvalue of type 'int'}}

V<0> v0;

int l()
{
  int cilk_reducer(typo) x;
  // expected-error@-1{{use of undeclared identifier 'typo'}}
  return x.field;
  // expected-error@-1{{base type 'int' is not a structure or union}}
  // The preceding line must not crash the compiler.  The error is
  // new in llvm 21.
}

struct W : public __reducer_base {
  D &field; // D contains a hyperobject
  // TODO: It would be nice for the compiler to call out the previous
  // line as being part of the chain from error below to note above.
  W();
};

W _Hyperobject w;
// expected-error@-1{{view type 'W' contains a hyperobject}}

struct Z : private __reducer_base { int value; };
// expected-note@-1{{declared private}} (one for the type definition)
// expected-note@-2{{declared private}} (one for the type use)

Z cilk_reducer z;
// expected-error@-1{{private base class}}
int get_z() { return z.value; }
// expected-error@-1{{private base class}}

// View type must be unambiguously convertible to __reducer_base.

struct ZA : private Z, public __reducer_base {
  // expected-warning@-1{{due to ambiguity}}
};

ZA cilk_reducer za;
// expected-error@-1{{ambiguous conversion}}

unsigned int sizeof_ZA_reducer = sizeof (ZA cilk_reducer);
// expected-error@-1{{ambiguous conversion}}
// The error above is optional because a reducer has the same size
// as its view type.

typedef ZA cilk_reducer ZA_reducer;
// expected-error@-1{{ambiguous conversion}}
// Again, the error is optional...
ZA_reducer za2;
// ... but if it is not on the ZA_reducer type declaration it must be here.

// Check for expected parse errors.  The exact messages are unimportant.
// Changes should be reviewed.

using ZB = Z cilk_reducer(1 +);
// expected-error@-1{{expected expression}}

using ZC = Z cilk_reducer(1, 1 +);
// expected-error@-1{{expected expression}}

using ZD = Z cilk_reducer(cilk_reducer);
// expected-error@-1{{expected expression}}

int cilk_reducer = 0;
// expected-error@-1{{unqualified-id}}

// All parse errors should have been recovered from.
int eof = -1;
