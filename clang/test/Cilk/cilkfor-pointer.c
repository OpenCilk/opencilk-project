// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only

// Make sure the front end accepts pointer loop variables.
long cilk_for_pointer_type(const long *begin, const long *end)
{
  _Cilk_for (const long *p = begin; p != end; ++p)
    ; // expected-warning@-1{{Cilk for loop has empty body}}
  return 0;
}
