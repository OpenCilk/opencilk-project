// RUN: %clang_cc1 %s -x c -fopencilk -verify -emit-llvm -disable-llvm-passes -o /dev/null
// Compiling this file should not crash.

extern int _Hyperobject x;
// expected-error@-1{{view type must be a class}}

void function1()
{
  int _Hyperobject y = 1;
  // expected-error@-1{{view type must be a class}}
  (void)x;
  // The next two errors are consequences of BuildHyperobjectLookup
  // returning its argument if it contains errors.
  // They would be better off suppressed.
  ++x;
  // expected-error@-1{{cannot increment value of type 'int _Hyperobject'}}
  y++;
  // expected-error@-1{{cannot increment value of type 'int _Hyperobject'}}
  (void)y;
}
