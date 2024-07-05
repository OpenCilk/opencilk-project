// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only

void f1() {
  _Cilk_for(bad i = 0; i < 42; ++i); // expected-error{{use of undeclared identifier 'bad'}} expected-error{{use of undeclared identifier 'i'}} expected-error{{use of undeclared identifier 'i'}} expected-error{{expected control variable declaration in initializer in 'cilk_for'}}
}

void f2() {
  _Cilk_for(int i = 0; ; ++i); // expected-error{{missing loop condition expression}} expected-error{{expected binary comparison operator in 'cilk_for' loop condition}}
}

void f3() {
  _Cilk_for(int i = 0; i < 42; ); // expected-error{{missing loop increment expression}} expected-warning{{'cilk_for' loop has empty body}}
}

void f4() {
  int i;
  _Cilk_for(; i < 42; ++i); // expected-error{{missing control variable declaration and initialization in 'cilk_for'}} expected-error{{expected control variable declaration in initializer in 'cilk_for'}}
}

void f5(const long *begin) {
  _Cilk_for (const long *p = begin; p != 666; ++p)
    ;
  // expected-warning@-2{{comparison between pointer and integer}}
  // expected-warning@-3{{'cilk_for' loop has empty body}}
}
