// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
// XFAIL: *

template <typename T> static void zero(void *v) {
    *static_cast<T *>(v) = static_cast<T>(0);
}

template <typename T> static void plus(void *l, void *r) {
    *static_cast<T *>(l) += *static_cast<T *>(r);
}

template <typename T>
using reducer_opadd = T _Hyperobject(zero<T>, plus<T>);

extern double X[], Y[];

template<typename T>
T mult(T *x, T *y) {
  reducer_opadd<T> result_reducer = 0;
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  result_reducer += x[0]*y[0];
  return result_reducer;
}


double f() {
  return mult(X, Y);
}
