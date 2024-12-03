// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -fsyntax-only
struct C { int _Hyperobject c = 0; };
struct C _Hyperobject c; // expected-error{{type 'struct C', which contains a hyperobject, may not be a hyperobject}}
long _Hyperobject d; // expected-note{{previous definition}}
void f() {
  extern int _Hyperobject d;
  // expected-error@-1{{redeclaration of 'd' with a different type: 'int _Hyperobject' vs 'long _Hyperobject'}}
}
char _Hyperobject e; // expected-note{{previous definition}}
typedef long _Hyperobject long_h;
void g() {
  extern long_h e; // expected-error{{redeclaration of 'e'}}
}

extern void reduce(void *, void *), identity(void *);

struct D {
  int _Hyperobject(identity, reduce) field;
};

int _Hyperobject(reduce, identity) h;
  // expected-error@-1{{incompatible function pointer types passing 'void (*)(void *, void *)' to parameter of type 'void (*)(void *)'}}
  // expected-error@-2{{incompatible function pointer types passing 'void (*)(void *)' to parameter of type 'void (*)(void *, void *)'}}

int _Hyperobject(x) i; // expected-error{{use of undeclared identifier 'x'}}
int _Hyperobject(0) j; // expected-error{{hyperobject must have 0 or 2 callbacks}}
int _Hyperobject(0,0,0,0) k; // expected-error{{hyperobject must have 0 or 2 callbacks}}
int _Hyperobject(0, 1) x; // expected-error{{incompatible integer to pointer conversion passing 'int' to parameter of type 'void (*)(void *, void *)'}}

template<typename View> struct T {
  View _Hyperobject field;
  // expected-error@-1{{qualified type 'const int' may not be a hyperobject}}
  // expected-error@-2{{type 'int _Hyperobject', which contains a hyperobject, may not be a hyperobject}}
  // expected-error@-3{{type 'int &' may not be a hyperobject}}
  // expected-error@-4{{type 'int &' may not be a hyperobject}}
  View &get_view() { return field; }
  // expected-error@-1{{non-const lvalue reference to type 'int' cannot bind to a value of unrelated type 'int &_Hyperobject'}}
  // The text of the preceding error message is unimportant.
  // The compiler used to crash in this situation.
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
  // expected-error@-2{{use of undeclared identifier 'typo3'}}
  int _Hyperobject(0, typo4) var3 = 0;
  // expected-error@-1{{use of undeclared identifier 'typo4'}}
  T<const int> var4;
  // expected-note@-1{{requested here}}
  T<int _Hyperobject> var5;
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
