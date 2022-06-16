// RUN: %clang_cc1 %s -x c -fopencilk -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics
#ifdef __cplusplus
extern "C"
#else
extern
#endif
void add(void *l, void *r), zero(void *v);

typedef double _Hyperobject(zero, add) double_reducer;

#ifdef __cplusplus
extern "C" void g(double *);
#else
extern void g(double *);
#endif

// A register and unregister call pair should be generated whether
// the reducer attribute is directly on the variable declaration
// or inherited from a typedef.

// CHECK_LABEL: f1
double f1(double x)
{
  // CHECK: call void @llvm.reducer.register
  double_reducer y = x;
  // CHECK: call void @g
  g(&y);
  // CHECK: call void @llvm.reducer.unregister
  // CHECK: ret double
  return y;
}

// CHECK_LABEL: f2
double f2(double x)
{
  // CHECK: store double
  // CHECK: call void @llvm.reducer.register
  double _Hyperobject(zero, add) y = x;
  // CHECK: call void @g
  g(&y);
  // CHECK: call void @llvm.reducer.unregister
  // CHECK: ret double
  return y;
}
