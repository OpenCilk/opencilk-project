// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only

void f1() {
  _Cilk_for(bad i = 0; i < 42; ++i); // expected-error{{use of undeclared identifier 'bad'}} expected-error{{use of undeclared identifier 'i'}} expected-error{{use of undeclared identifier 'i'}} expected-error{{expected control variable declaration in initializer in '_Cilk_for'}}
}

void f2() {
  _Cilk_for(int i = 0; ; ++i); // expected-error{{missing loop condition expression}} expected-error{{expected binary comparison operator in '_Cilk_for' loop condition}}
}

void f3() {
  _Cilk_for(int i = 0; i < 42; ); // expected-error{{missing loop increment expression}} expected-warning{{Cilk for loop has empty body}}
}

void f4() {
  int i;
  _Cilk_for(; i < 42; ++i); // expected-error{{missing control variable declaration and initialization in '_Cilk_for'}} expected-error{{expected control variable declaration in initializer in '_Cilk_for'}}
}

void f5(const long *begin, const long *end) { // expected-note{{previous}}
  long end = 666; // expected-error{{redefinition of 'end' with a different type}}
  _Cilk_for (const long *p = begin; p != end; ++p)
    ;
  // expected-error@-2{{invalid operands}}
  // expected-warning@-3{{incompatible integer to pointer conversion}}
  // expected-warning@-4{{Cilk for loop has empty body}}
}
