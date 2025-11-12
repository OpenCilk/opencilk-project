// RUN: %clang_cc1 %s -x c -fopencilk -verify -Wno-error=int-conversion -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
extern void (*i)(void *);
extern void (*r)(void *, void *);

// Test for crash on definition of empty hyperobject
// CHECK-LABEL: __cxx_global_var_init
// CHECK: call void @llvm.reducer.register(i32 2, ptr @x
typedef char Empty[0];
Empty _Hyperobject(i, r) x;

