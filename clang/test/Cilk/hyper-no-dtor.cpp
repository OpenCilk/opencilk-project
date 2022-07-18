// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
// Check for compiler crash trying to call non-existent destructor.
struct S { S(); };
extern void identity(void *), reduce(void *, void *);

// CHECK-LABEL: function
void function()
{
  // call {{.+}} @_ZN1SC1Ev
  // CHECK: call void @llvm.reducer.register.i64
  S _Hyperobject(identity, reduce) s;
  // CHECK: call void @llvm.reducer.unregister
}
