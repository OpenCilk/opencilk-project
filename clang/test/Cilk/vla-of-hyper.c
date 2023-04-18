// RUN: %clang_cc1 -x c %s -fopencilk -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s
// RUN: %clang_cc1 -x c++ %s -fopencilk -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s

extern void reduce(void *, void *), identity(void *);

// VLA of hyperobject
// CHECK-LABEL: test_vla_hyper
int test_vla_hyper(unsigned long size)
{
  int _Hyperobject(identity, reduce) array[size];
  // expected-warning@-1{{array of reducer not implemented}}

  // CHECK: getelementptr
  // CHECK: %[[RAW:.+]] = call ptr @llvm.hyper.lookup
  // CHECK-NEXT: %[[RET:.+]] = load i32, ptr %[[RAW]]
  // CHECK-NOT: getelementptr
  // CHECK: ret i32 %[[RET]]
  return array[2];
}
