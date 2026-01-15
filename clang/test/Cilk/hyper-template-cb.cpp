// RUN: %clang_cc1 %s -triple amd64-freebsd -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

// This code below used to trigger a crash because of a missing
// function-to-pointer decay in a particular templated context.

struct IsStolen {
  bool flag = false;
  IsStolen(bool _flag = true);
  // Destructively check if the flag is set.  Ensures the flag is set false
  // after call.
  bool check_destructive();
};

template <typename A> void holder_init_fn(void *view);
template <typename A> void holder_reduce_fn(void *left, void *right);
template <typename A>
using holder = A cilk_reducer(holder_init_fn<A>, holder_reduce_fn<A>);

// CHECK-LABEL: define linkonce_odr noundef i32 @_Z2fnIlEiPT_(ptr noundef %c)
// CHECK: call void @llvm.reducer.register
// CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr %s, i64 1, ptr @_Z14holder_init_fnI8IsStolenEvPv, ptr @_Z16holder_reduce_fnI8IsStolenEvPvS1_)

template<class C>
int fn(C *c) {
  holder<IsStolen> s;
  if (s.check_destructive())
    return 2;
  return 1;
}

int x = fn<long>(nullptr);
