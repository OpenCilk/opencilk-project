// RUN: %clang_cc1 %s -x c -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
struct S { int first, second; };

extern struct S _Hyperobject a __attribute__((aligned(8)));
extern struct S b __attribute__((aligned(8)));

// CHECK-LABEL: scopy
void scopy()
{
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @a, i64 8, ptr null, ptr null)
  // CHECK: call void @llvm.memcpy.p0.p0.i64(ptr align 8 @b,
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @a, i64 8, ptr null, ptr null)
  // CHECK: call void @llvm.memcpy.p0.p0.i64
  // CHECK: ret void
  b = a;
  a = b;
}
