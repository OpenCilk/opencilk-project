// RUN: %clang_cc1 %s -O -triple x86_64-unknown-linux-gnu -verify -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

// This tests that a call in tail position is not subject to tail
// call optimization in a function that calls __builtin_setjmp.

extern void f(void **);

// CHECK-LABEL: caller
void caller(void **data)
{
  // CHECK: call i32 @llvm.eh.sjlj.setjmp
  if (__builtin_setjmp(data) == 0)
    // CHECK-NOT: tail
    f(data);
}
