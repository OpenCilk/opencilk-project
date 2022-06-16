// RUN: %clang_cc1 %s -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

struct S { S(int); int x; };

void identity_long(struct S *v);
void reduce_long(S *l, S *r);

// CHECK-LABEL: cxx_global_var_init
// CHECK: call void @_ZN1SC1Ei(%struct.S* nonnull align 4 dereferenceable(4) @global, i32 1)
// CHECK: call void @llvm.reducer.register.i64
S _Hyperobject(identity_long, reduce_long, 0) global = 1;

// CHECK: call void @llvm.reducer.unregister
// CHECK-NOT: _ZN1SD1Ev
