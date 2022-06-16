// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
extern double array[];
extern const int size;

// CHECK-LABEL: g
void g(double _Hyperobject *sum) { // hyperobject-aware function
    // CHECK-LABEL: pfor.body
    _Cilk_for (int i = 0; i < size; ++i)
        // CHECK: call i8* @llvm.hyper.lookup
        *sum += array[i];
}
