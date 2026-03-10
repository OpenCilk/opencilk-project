// RUN: %clang_cc1 %s -Wall -std=c++20 -triple arm64-apple-darwin24.6.0 -fopencilk -disable-llvm-passes -verify -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

struct reducer_base {};

extern "C" reducer_base *__hyper_lookup_class(const reducer_base *);

struct vector {
  int operator[](int);
  int operator+(int);
};

struct vector_reducer : public reducer_base, vector {
};

// operator[] is handled differently.
// CHECK-LABEL: test_index
int test_index(vector_reducer cilk_reducer &v) {
  // CHECK: call ptr @llvm.hyper.lookup.0
  // CHECK: call noundef i32 @_ZN6vectorixEi
  return v[0]; // note that 0[v] does not work here
}

// operator+ works like most operators.
// CHECK-LABEL: test_plus
int test_plus(vector_reducer cilk_reducer &v) {
  // CHECK: call ptr @llvm.hyper.lookup.0
  // CHECK: call noundef i32 @_ZN6vectorplEi
  return v + 0;
}

