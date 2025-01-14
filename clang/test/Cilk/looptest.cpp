// RUN: %clang_cc1 -std=c++1z -fopencilk -verify %s

int foo(int n);

int Cilk_for_tests(int n) {
  /* int n = 10; */
  /* cilk_for(int i = 0; i < n; i += 2); */
  /* cilk_for(int j = 0, __begin = 0, __end = n/2; __begin < __end; j += 2, __begin++); */
  cilk_for (int i = 0; i < n; ++i); // expected-warning {{'cilk_for' loop has empty body}}
  cilk_for (int i = 0, __end = n; i < __end; ++i); // expected-warning {{'cilk_for' loop has empty body}}
  unsigned long long m = 10;
  cilk_for (int i = 0; i < m; ++i); // expected-warning {{'cilk_for' loop has empty body}}
  cilk_for (int i = 0, __end = m; i < __end; ++i); // expected-warning {{'cilk_for' loop has empty body}}

  // Check for return statements, which cannot appear anywhere in the body of a
  // cilk_for loop.
  cilk_for (int i = 0; i < n; ++i) return 7; // expected-error{{cannot return}}
  cilk_for (int i = 0; i < n; ++i)
    for (int j = 1; j < i; ++j)
      return 7; // expected-error{{cannot return}}

  // Check for illegal break statements, which cannot bind to the scope of a
  // cilk_for loop, but can bind to loops nested within.
  cilk_for (int i = 0; i < n; ++i) break; // expected-error{{cannot break}}
  cilk_for (int i = 0; i < n; ++i)
    for (int j = 1; j < i; ++j)
      break;
  return 0;
}

int pragma_tests(int n) {
#pragma clang loop unroll_count(4)
  cilk_for (int i = 0; i < n; ++i)
    foo(i);

#pragma cilk grainsize(4)
  cilk_for (int i = 0; i < n; ++i)
    foo(i);

#pragma cilk grainsize 4
  cilk_for (int i = 0; i < n; ++i)
    foo(i);

#pragma cilk grainsize = 4 \
// expected-warning{{'#pragma cilk grainsize' no longer requires '='}}
  cilk_for (int i = 0; i < n; ++i)
    foo(i);

  return 0;
}

int scope_tests(int n) {
  int A[5];
  cilk_for(int i = 0; i < n; ++i) {
    int A[5];
    A[i%5] = i;
  }
  for(int i = 0; i < n; ++i) {
    A[i%5] = i%5;
  }
  return 0;
}
