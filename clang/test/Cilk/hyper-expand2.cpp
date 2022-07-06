// RUN: %clang_cc1 %s -x c++ -O1 -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern double X[], Y[];

template<typename T>
struct Box { T value; };

template<typename T>
// CHECK-LABEL: mult_indirect
void mult_indirect(Box<T> _Hyperobject *H, T *x, T *y) {
  // CHECK-NOT: call void @llvm.reducer.register
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  // CHECK: getelementptr
  // CHECK-NEXT: load double,
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  // CHECK: getelementptr
  // CHECK-NEXT: load double,
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  // CHECK: load double
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  // CHECK: store double
  H->value += x[0]*y[0];
  // CHECK: ret void
}

typedef void (*Fn)(Box<double> _Hyperobject*, double *, double *);

Fn g() {
  return &mult_indirect<double>;
}
