// RUN: %clang_cc1 %s -fopencilk -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

// VLA of hyperobject
// CHECK-LABEL: test_vla_hyper
int test_vla_hyper(unsigned long size)
{
  _Hyperobject int array[size];

  // CHECK: getelementptr
  // CHECK: %[[RAW:.+]] = call i8* @llvm.hyper.lookup
  // CHECK-NEXT: %[[VIEW:.+]] = bitcast i8* %[[RAW]] to i32*
  // CHECK-NEXT: %[[RET:.+]] = load i32, i32* %[[VIEW]]
  // CHECK-NOT: getelementptr
  // CHECK: ret i32 %[[RET]]
  return array[2];
}
