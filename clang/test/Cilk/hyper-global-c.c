// RUN: %clang_cc1 %s -triple amd64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

void identity_long(void *v);
void reduce_long(void *l, void *r);

// CHECK-LABEL: cxx_global_var_init
// CHECK: store i64 1, i64* @global
// CHECK: call void @llvm.reducer.register.i64
long _Hyperobject(identity_long, reduce_long) global = 1;

// CHECK: call void @llvm.reducer.unregister
