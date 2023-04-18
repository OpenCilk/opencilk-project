// RUN: %clang_cc1 %s -x c -fopencilk -verify -Wno-error=int-conversion -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
extern int c;
extern void *d;

// Test for crash on definition of empty hyperobject
// CHECK-LABEL: __cxx_global_var_init
// CHECK: call void @llvm.reducer.register.i64(ptr @x, i64 0
typedef char Empty[0];
Empty _Hyperobject(d, d) x;

void declares_hyperobject()
{
  // Test for crash on int to pointer conversion in hyperobject definition
  int _Hyperobject(c, d) y;
  //expected-warning@-1{{incompatible integer to pointer conversion}}
}
