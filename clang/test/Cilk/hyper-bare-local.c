// RUN: %clang_cc1 %s -x c -fopencilk -ftapir=none -S -emit-llvm -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics
extern void add(void *key, void *l, void *r);
extern void zero(void *key, void *v);

// Test reducer attribute on non-hyperobject.

typedef double double_reducer __attribute__((reducer(add, zero)));
#ifdef __cplusplus
extern "C"
#endif
void g(double *);

// CHECK_LABEL: f1
double f1(double x)
{
  // CHECK-NOT: call void @llvm.reducer.register
  double_reducer y = x;
  // CHECK: call void @g
  g(&y);
  // CHECK-NOT: call void @llvm.reducer.unregister
  // CHECK: ret double
  return y;
}
