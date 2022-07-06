// RUN: %clang_cc1 %s -x c++ -O1 -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

template <typename T> static void zero(void *v);

template <typename T> static void zero(void *v) {
    *static_cast<T *>(v) = static_cast<T>(0);
}

template <typename T> static void plus(void *l, void *r) {
    *static_cast<T *>(l) += *static_cast<T *>(r);
}

template <typename T>
using reducer_opadd = T _Hyperobject(zero<T>, plus<T>);

extern double X[], Y[];

// CHECK-LABEL: mult_direct
template<typename T>
T mult_direct(T *x, T *y) {
  reducer_opadd<T> * a = nullptr;
  reducer_opadd<T> * b = a;

  reducer_opadd<T> result_reducer = 0;
  // CHECK: call void @llvm.reducer.register
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
  result_reducer += x[0]*y[0];
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  // CHECK: ret double
  return result_reducer;
}

double f() {
  return mult_direct(X, Y);
}
