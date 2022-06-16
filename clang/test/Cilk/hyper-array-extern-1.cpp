// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern int _Hyperobject x[10];

// One array with 10 hyperobject elements
// CHECK_LABEL: read_array_hyper
int read_array_hyper(unsigned i)
{
  return x[i];
  // CHECK: %[[ARRAYIDX:.+]] = getelementptr inbounds
  // CHECK: %[[KEY:.+]] = bitcast i32* %[[ARRAYIDX]] to i8*
  // CHECK: %[[VIEWRAW:.+]] = call i8* @llvm.hyper.lookup(i8* %[[KEY]])
  // CHECK: %[[VIEW:.+]] = bitcast i8* %[[VIEWRAW]] to i32*
  // CHECK: %[[VAL:.+]] = load i32, i32* %[[VIEW]]
  // CHECK: ret i32 %[[VAL]]
}
