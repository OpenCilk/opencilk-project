// RUN: %clang_cc1 %s -x c -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
struct S { int first, second; };

extern struct S _Hyperobject a __attribute__((aligned(8)));
extern struct S b __attribute__((aligned(8)));

// CHECK-LABEL: scopy
void scopy()
{
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* bitcast (%struct.S* @a to i8*), i64 8, i8* null, i8* null)
  // CHECK: call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 bitcast (%struct.S* @b to i8*)
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* bitcast (%struct.S* @a to i8*), i64 8, i8* null, i8* null)
  // CHECK: call void @llvm.memcpy.p0i8.p0i8.i64
  // CHECK: ret void
  b = a;
  a = b;
}
