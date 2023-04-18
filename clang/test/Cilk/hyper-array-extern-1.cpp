// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern int _Hyperobject x[10];

// One array with 10 hyperobject elements
// CHECK-LABEL: read_array_hyper
int read_array_hyper(unsigned i)
{
  return x[i];
  // CHECK: %[[ARRAYIDX:.+]] = getelementptr inbounds
  // CHECK: %[[VIEWRAW:.+]] = call ptr @llvm.hyper.lookup.i64(ptr %[[ARRAYIDX]], i64 4, ptr null, ptr null)
  // CHECK-NOT: call ptr @llvm.hyper.lookup
  // CHECK: %[[VAL:.+]] = load i32, ptr %[[VIEWRAW]]
  // CHECK: ret i32 %[[VAL]]
}
