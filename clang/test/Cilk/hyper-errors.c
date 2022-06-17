// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only -Werror=incompatible-function-pointer-types -Werror=int-conversion
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -fsyntax-only
struct C { int _Hyperobject c; };
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
  // expected-warning@-1{{reducer callbacks not implemented for structure members}}
};

int _Hyperobject(reduce, identity) h;
  // expected-error@-1{{incompatible function pointer types passing 'void (*)(void *, void *)' to parameter of type 'void (*)(void *)'}}
  // expected-error@-2{{incompatible function pointer types passing 'void (*)(void *)' to parameter of type 'void (*)(void *, void *)'}}

int _Hyperobject(x) i; // expected-error{{use of undeclared identifier 'x'}}
int _Hyperobject(0) j; // expected-error{{hyperobject must have 0, 2, or 3 callbacks}}
int _Hyperobject(0,0,0,0) k; // expected-error{{hyperobject must have 0, 2, or 3 callbacks}}
int _Hyperobject(0, 1) x; // expected-error{{incompatible integer to pointer conversion passing 'int' to parameter of type 'void (*)(void *, void *)'}}
