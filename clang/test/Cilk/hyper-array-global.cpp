// RUN: %clang_cc1 %s -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

struct S { S() noexcept; int val; ~S() noexcept; };
typedef S S10[10];
S10 _Hyperobject s;

// CHECK-NOT: call void @llvm.reducer.register
// CHECK-NOT: call void @llvm.reducer.unregister
// CHECK: call void @_ZN1SC1Ev
// CHECK-NOT: call void @llvm.reducer.register
// CHECK-NOT: call void @llvm.reducer.unregister
// CHECK: call void @_ZN1SD1Ev
// CHECK-NOT: call void @llvm.reducer.register
// CHECK-NOT: call void @llvm.reducer.unregister
