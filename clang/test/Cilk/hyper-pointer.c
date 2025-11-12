// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
extern double array[];
extern const int size;

extern void identity(void *), reduce(void *, void *);

// CHECK-LABEL: g
// hyperobject-aware function
void g(double _Hyperobject(identity, reduce) *sum) {
    // CHECK-LABEL: pfor.body
    _Cilk_for (int i = 0; i < size; ++i)
        // CHECK: call ptr @llvm.hyper.lookup.2
        *sum += array[i];
}
