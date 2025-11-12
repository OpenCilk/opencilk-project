// RUN: %clang_cc1 %s -x c -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
extern
#ifdef __cplusplus
"C"
#endif
void identity(void *), reduce(void *, void *);

struct S { int first, second; };

extern struct S _Hyperobject(identity, reduce) a __attribute__((aligned(8)));
extern struct S b __attribute__((aligned(8)));

// CHECK-LABEL: scopy
#ifdef __cplusplus
extern "C"
#endif
void scopy()
{
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @a, i64 8, ptr @identity, ptr @reduce)
  // CHECK: call void @llvm.memcpy.p0.p0.i64(ptr align 8 @b,
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @a, i64 8, ptr @identity, ptr @reduce)
  // CHECK: call void @llvm.memcpy.p0.p0.i64
  // CHECK: ret void
  b = a;
  a = b;
}
