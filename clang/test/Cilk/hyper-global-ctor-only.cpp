// RUN: %clang_cc1 %s -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

struct S { S(int); int x; };

void identity_S(void *v);
void reduce_S(void *l, void *r);

// CHECK-LABEL: cxx_global_var_init
// CHECK: call void @_ZN1SC1Ei(%struct.S* noundef nonnull align 4 dereferenceable(4) @global, i32 noundef 1)
// CHECK: call void @llvm.reducer.register.i64
S _Hyperobject(identity_S, reduce_S) global = 1;

// CHECK: call void @llvm.reducer.unregister
// CHECK-NOT: _ZN1SD1Ev
