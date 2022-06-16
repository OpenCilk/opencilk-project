// RUN: %clang_cc1 %s -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

struct S { ~S(); int x; };

void identity_long(struct S *v);
void reduce_long(S *l, S *r);

// CHECK-LABEL: __cxx_global_var_init
// CHECK: call void @llvm.reducer.register.i64
S _Hyperobject(identity_long, reduce_long, 0) global;

// CHECK: call void @llvm.reducer.unregister
// CHECK: call void @_ZN1SD1Ev
