/* Test two ways to take the address of a reducer:
   1. __builtin_addressof returns leftmost view
   2. & returns current view
*/
// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
// This does not compile in C++ because function overloading requires
// an exact match for hyperobject types.  C allows assigning to a
// generic hyperobject.
void identity(void * value);
void reduce(void* left, void* right);
extern void consume_view(long *);
extern void consume_hyper(long _Hyperobject *);
// CHECK_LABEL: assorted_addresses
void assorted_addresses()
{
  // CHECK: call void @llvm.reducer.register
  long _Hyperobject(identity, reduce) sum = 0;
  // CHECK-NOT: llvm.hyper.lookup
  // CHECK: call void @[[FN1:.*consume_hyper]]
  consume_hyper(__builtin_addressof(sum));
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: call void @[[FN2:.*consume_view]]
  consume_view(&sum);
  // CHECK: call void @llvm.reducer.unregister
  // CHECK: ret void
}

