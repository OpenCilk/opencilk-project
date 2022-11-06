// Check that Clang attaches some debug information to
// syncregion.start intrinsics.  Doing so helps ensure that bitcode
// files with debug information can be properly linked during Tapir
// lowering and their functions subsequently inlined.
//
// RUN: %clang_cc1 %s -debug-info-kind=standalone -fopencilk -ftapir=none -S -emit-llvm -o - | FileCheck %s

int fib(int n) {
  if (n < 2) return n;
  int x = _Cilk_spawn fib(n-1);
  int y = fib(n-2);
  _Cilk_sync;
  return x + y;
}

// CHECK-LABEL: define i32 @fib(
// CHECK: call token @llvm.syncregion.start(), !dbg
