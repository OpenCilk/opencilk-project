// Check the spawning of builtins.
//
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fopencilk -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s

int g(int);

int f() {
  int x = _Cilk_spawn 0; // expected-warning {{Failed to emit spawn}}
  g(_Cilk_spawn 7); // expected-warning {{Failed to emit spawn}}
  return _Cilk_spawn 1; // expected-warning {{no parallelism from a '_Cilk_spawn' in a return statement}} expected-warning {{Failed to emit spawn}}
}

// CHECK-LABEL: define {{.*}}i32 @f(
// CHECK-NOT: detach

