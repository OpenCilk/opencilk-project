// RUN: %clang_cc1 %s -x c++ -O1 -fcxx-exceptions -fexceptions -fopencilk -mllvm -use-opencilk-runtime-bc=false -mllvm -debug-abi-calls=true -verify -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics
extern int maybe_throws(int);

// CHECK-LABEL: _Z9function4v
int function4()
{
  _Cilk_scope {
    try {
// CHECK: i32 @_Z12maybe_throwsi
// CHECK-NEXT: to label %[[NORMAL:.+]] unwind label %[[LPAD:.+]]
      maybe_throws(1);
// CHECK: [[LPAD]]:
// CHECK: invoke
// CHECK-NEXT: to label %[[NORMAL]] unwind label %[[LPAD1:.+]]
      return 1;
    } catch (...) {
// CHECK: [[NORMAL]]:
// CHECK-NEXT: %[[RETVAL:.+]] = phi i32
// CHECK-DAG: [ 2, %[[LPAD]] ]
// CHECK-DAG: [ 1, %entry ]
// CHECK: ret i32 %[[RETVAL]]
      return 2;
    }
  }
// This return is unreachable.
// CHECK-NOT: ret i32 3
  return 3;
}