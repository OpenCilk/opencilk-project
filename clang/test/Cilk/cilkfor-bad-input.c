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
