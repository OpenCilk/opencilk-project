// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only -Werror=incompatible-function-pointer-types -Werror=int-conversion

extern int integer;
extern void identity(void *), reduce(void *, void *);

// Test for crash on integer variable, not literal 0, used as callback.
int cilk_reducer(integer, 0) noint;
//expected-error@-1{{incompatible integer to pointer conversion passing 'int' to parameter of type 'void (*)(void *)'}}

int cilk_reducer needclass;
// expected-error@-1{{view type must be a class when hyperobject has no callbacks}}

struct C { int _Hyperobject(identity, reduce) c; };
// expected-warning@-1{{reducer registration not implemented for structure members}}
// expected-note@-2{{unsupported type}}
struct C _Hyperobject(identity, reduce) c;
// expected-error@-1{{view type 'struct C' contains a hyperobject}}

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

extern void reduce(void *, void *), identity(void *);

struct D {
  int _Hyperobject(identity, reduce) field;
  // expected-warning@-1{{reducer registration not implemented for structure members}}
};

int _Hyperobject(reduce, identity) h;
  // expected-error@-1{{incompatible function pointer types passing 'void (void *, void *)' to parameter of type 'void (*)(void *)'}}
  // expected-error@-2{{incompatible function pointer types passing 'void (void *)' to parameter of type 'void (*)(void *, void *)'}}

int _Hyperobject(x) i;
// expected-error@-1{{use of undeclared identifier 'x'}}
int _Hyperobject(0,0,0,0) k;
// expected-error@-1{{extra hyperobject callbacks ignored}}
int _Hyperobject(0, 1) x;
// expected-error@-1{{incompatible integer to pointer conversion passing 'int' to parameter of type 'void (*)(void *, void *)'}}

void function() {
  int _Hyperobject(typo1, reduce) var1 = 0;
  // expected-error@-1{{use of undeclared identifier 'typo1'}}
  int _Hyperobject(typo2, typo3) var2 = 0;
  // expected-error@-1{{use of undeclared identifier 'typo2'}}
  // NOTE: LLVM 21 removed delayed typo checks: https://github.com/llvm/llvm-project/pull/143423
  // no-expected-error@-2{{use of undeclared identifier 'typo3'}}
  int _Hyperobject(0, typo4) var3 = 0;
  // expected-error@-1{{use of undeclared identifier 'typo4'}}
  const int _Hyperobject(identity, reduce) var4 = 0;
  // expected-error@-1{{qualified type 'const int' may not be a hyperobject}}
  volatile int _Hyperobject(identity, reduce) var5 = 0;
  // expected-error@-1{{qualified type 'volatile int' may not be a hyperobject}}
  typedef const int c_int;
  c_int _Hyperobject(identity, reduce) var6 = 0;
  // expected-error@-1{{qualified type 'c_int' (aka 'const int') may not be a hyperobject}}
  ++var4;
  // expected-error@-1{{read-only variable is not assignable}}
  ++var5;
  ++var6;
  // expected-error@-1{{read-only variable is not assignable}}
}

void _Hyperobject(identity, reduce) v;
// expected-error@-1{{hyperobject has incomplete view type 'void'}}
//typedef int empty[0];
//empty _Hyperobject(identity, reduce) ee;

// It would be nice to support this syntax some day.
int cilk_reducer(0, +) int_add_reducer;
// expected-error@-1{{expected expression}}

int vv(int x)
{
  typedef int vla_t[x];
  vla_t cilk_reducer(identity, reduce) vla;
  // expected-error@-1{{variable length type 'vla_t' (aka 'int[x]') may not be a hyperobject}}
  return vla[0];
}
