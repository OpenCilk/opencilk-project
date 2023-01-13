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
  // The C front end is not smart enough to call llvm.hyper.read 
  // CHECK: %[[RAW:.+]] = call i8* @llvm.hyper.
  // CHECK-NEXT: %[[VIEW:.+]] = bitcast i8* %[[RAW]] to i32*
  // CHECK-NEXT: %[[RET:.+]] = load i32, i32* %[[VIEW]]
  // CHECK-NOT: getelementptr
  // CHECK: ret i32 %[[RET]]
  return array[2];
}
