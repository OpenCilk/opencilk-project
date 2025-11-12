// RUN: %clang_cc1 %s -triple aarch64-freebsd -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// Fails for no discernible reason.
// expected-no-diagnostics

extern void identity(void *), reduce(void *, void *);

struct S { S() noexcept; int val; ~S() noexcept; };
typedef S S10[10];
S10 _Hyperobject(identity, reduce) s;

// CHECK-LABEL: @__cxx_global_var_init
// CHECK: call void @_ZN1SC1Ev
// CHECK: call i32 @__cxa_atexit
// CHECK: call void @llvm.reducer.register

// CHECK-LABEL: define internal void @__cxx_global_hyperobject_dtor
// CHECK: call void @llvm.reducer.unregister
// CHECK: call void @_ZN1SD1Ev

