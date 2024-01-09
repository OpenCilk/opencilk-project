// Check that Clang properly handles cilk_for loops with complicated stride
// calculations.
//
// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// expected-no-diagnostics

void test(char *data, unsigned long size)
{
  _Cilk_for (unsigned long i = 0; i < size; i = i + (1 << 21))
    ((char*) data)[i] = 0;
}
