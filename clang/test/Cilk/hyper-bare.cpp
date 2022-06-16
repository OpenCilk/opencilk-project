// RUN: %clang_cc1 %s -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

struct S { S(); ~S(); int x; };
// Should be constructed and destructed like a regular variable.
struct S _Hyperobject shyper;

// CHECK-NOT: call void @llvm.reducer.register
// CHECK: call void @_ZN1SC1Ev
// CHECK-NOT: call void @llvm.reducer.register
// CHECK-NOT: call void @llvm.reducer.unregister
// CHECK: call void @_ZN1SD1Ev(%struct.S* noundef nonnull align 4 dereferenceable(4) @shyper)
// CHECK-NOT: call void @llvm.reducer.register
// CHECK-NOT: call void @llvm.reducer.unregister
