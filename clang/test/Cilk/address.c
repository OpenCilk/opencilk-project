/* Test two ways to take the address of a reducer:
   1. __builtin_addressof returns leftmost view
   2. & returns current view
*/
// RUN: %clang_cc1 %s -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
void identity(void* reducer, long * value);
void reduce(void* reducer, long* left, long* right);
extern void consume_view(long *);
extern void consume_hyper(_Hyperobject long *);
// CHECK_LABEL: assorted_addresses
void assorted_addresses()
{
  // CHECK: call void @llvm.reducer.register
  _Hyperobject long __attribute__((reducer(reduce, identity))) sum = 0;
  // CHECK-NOT: llvm.hyper.lookup
  // CHECK: call void @consume_hyper
  consume_hyper(__builtin_addressof(sum));
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: call void @consume_view
  consume_view(&sum);
  // CHECK: call void @llvm.reducer.unregister
  // CHECK: ret void
}

