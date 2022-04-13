// RUN: %clang_cc1 %s -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

struct S { ~S(); int x; };

void identity_long(void *r, struct S *v);
void reduce_long(void *z, S *l, S *r);

// CHECK-LABEL: __cxx_global_var_init
// CHECK: call void @llvm.reducer.register.i64
_Hyperobject S global __attribute__((reducer(reduce_long, identity_long, 0)));

// CHECK: call void @llvm.reducer.unregister
// CHECK: call void @_ZN1SD1Ev
