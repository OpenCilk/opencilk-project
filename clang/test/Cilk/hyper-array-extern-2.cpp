// RUN: %clang_cc1 %s -x c -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

// One hyperobject array with 10 integer elementso
typedef int I10[10];
extern I10 _Hyperobject y;
// CHECK_LABEL: read_hyper_array
int read_hyper_array(unsigned i)
{
  return y[i];
  // CHECK: call i8* @llvm.hyper.lookup
  // Make sure the array is not copied to the stack.
  // CHECK-NOT: call void @llvm.memcpy
  // CHECK: getelementptr
  // CHECK: load i32
  // CHECK: ret i32
}
