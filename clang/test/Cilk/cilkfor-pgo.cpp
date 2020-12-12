// Check that -fprofile-instrument generates atomic
// instrumentation instructions inside of _Cilk_for loops.
//
// Credit to Brian Wheatman for the original source of this test.
//
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fprofile-instrument=clang -fprofile-update=atomic %s -S -emit-llvm -fopencilk -ftapir=none -o - 2>&1 | FileCheck %s
// expected-no-diagnostics

int main() {
  int sum = 0;
  _Cilk_for(int i = 0; i < 1000000; i++) { sum += i; }

  return sum;
}

// CHECK: @__profc_main = {{.*}}global [2 x i64] zeroinitializer, section "__llvm_prf_cnts"

// CHECK-LABEL: define {{.*}}i32 @main()

// CHECK: detach within %{{.+}}, label %[[PFOR_BODY:.+]], label %[[PFOR_INC:.+]]

// CHECK: [[PFOR_BODY]]:
// CHECK: atomicrmw add i64* getelementptr inbounds ([2 x i64], [2 x i64]* @__profc_main, i64 0, i64 1), i64 1 monotonic
// CHECK: reattach within %{{.+}}, label %[[PFOR_INC]]
