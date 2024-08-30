// RUN: %clang_cc1 -triple x86_64-apple-macosx14.0.0 -emit-llvm -S -fopencilk -disable-llvm-passes -fcxx-exceptions -fexceptions -x c++ %s -o /dev/null
// expected-no-diagnostics
// Bug 266: unnecessary sync in catch block crashes compiler

extern int f();

// Nothing really to check here.  If it compiles, great.
void try_catch() {
  try {
    f();
  } catch (int x) {
    _Cilk_sync;
  }
}

