// RUN: %clang_cc1 %s -std=c++20 -triple x86_64-unknown-linux-gnu -fopencilk -disable-llvm-passes -verify -emit-llvm -o - | FileCheck %s
// Make sure the C++20 init-statement works with cilk_for.

extern bool *getarray(unsigned long size);

extern unsigned int global[1000];

// CHECK-LABEL: _Z4scanv
void scan() {

  // This syntax is new in C++20.
  _Cilk_for (bool *array = getarray(666); unsigned int i : global) {
    // expected-warning@-1{{experimental}}
    // CHECK: %[[ARRAY:.+]] = call noundef ptr @_Z8getarraym(i64 noundef 666)
    // CHECK-NEXT: store ptr %[[ARRAY]], ptr %array, align 8
    // CHECK: pfor.body:
    // CHECK: %[[ARRAY2:.+]] = load ptr, ptr %array
    // CHECK: %[[ELEMENT:.+]] = getelementptr inbounds i8, ptr %[[ARRAY2]]
    // CHECK: store i8 1, ptr %[[ELEMENT]]
    // CHECK-NEXT: br label
    array[i] = true;
  }

  // CHECK: ret void

}
