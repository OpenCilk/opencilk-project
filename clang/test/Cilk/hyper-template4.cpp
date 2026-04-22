// RUN: %clang_cc1 %s -O1 -emit-llvm -disable-llvm-passes -fopencilk --std=c++20 -triple amd64-freebsd -o - | FileCheck %s
// expected-no-diagnostics

extern void identity(void *), reduce(void *, void *);

class foo;
// An operator+= in namespace scope causes the += later to be miscompiled.
extern foo &operator +=(foo &, const foo &);

template<typename Number>
struct number {
  number();
  number(Number);
  Number r;
  number &operator+=(number);
};

extern void zero_reduce_number(void *);
extern void plus_reduce_number(void *, void *);

// CHECK-LABEL: gemv
// CHECK: alloca %struct.number
// CHECK: @_ZN6numberIfEC1Ef
// CHECK: call ptr @llvm.hyper.lookup.2
// CHECK: @_ZN6numberIfEpLES0_
template<typename NumT>
void gemv() {
    extern number<NumT> cilk_reducer(zero_reduce_number, plus_reduce_number) sum;
    sum += number<NumT>(1.0f);
}

void (*fn)() = &gemv<float>;

