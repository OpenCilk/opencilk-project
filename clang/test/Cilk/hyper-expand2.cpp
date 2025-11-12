// RUN: %clang_cc1 %s -x c++ -O1 -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern double X[], Y[];

struct Base { virtual void polymorphic(); };
extern "C" struct Base *__hyper_lookup_class(struct Base *);

template<typename T>
struct Box : public Base { T value; };

template<typename T>
// CHECK-LABEL: mult_indirect
void mult_indirect(Box<T> _Hyperobject *H, T *x, T *y) {
  // CHECK-NOT: call void @llvm.reducer.register
  // CHECK-NOT: call ptr @llvm.hyper.lookup
  // CHECK: getelementptr
  // CHECK-NEXT: load double,
  // CHECK-NOT: call ptr @llvm.hyper.lookup
  // CHECK: getelementptr
  // CHECK-NEXT: load double,
  // CHECK: call ptr @llvm.hyper.lookup
  // CHECK-NOT: call ptr @llvm.hyper.lookup
  // CHECK: load double
  // CHECK-NOT: call ptr @llvm.hyper.lookup
  // CHECK: store double
  H->value += x[0]*y[0];
  // CHECK: ret void
}

typedef void (*Fn)(Box<double> _Hyperobject*, double *, double *);

Fn g() {
  return &mult_indirect<double>;
}
