// Check unusual lvalue conversions involving hyperobject lookups, qualifiers, and xvalues.
//
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

// Simplified version of std::move for standalone test.
namespace std {
template <typename T>
T &&move(T &obj) {
  return static_cast<T &&>(obj);
}
}

// Reducer definition.
template <typename T> void sum_init(void *v) { *reinterpret_cast<T *>(v) = T{}; }

template <typename T> void sum_reduce(void *v, void *v2) {
  T *a = reinterpret_cast<T *>(v), *b = reinterpret_cast<T *>(v2);
  *a += *b;
}

template <typename T> using SumReducer = T _Hyperobject(sum_init<T>, sum_reduce<T>);

using Real = double;

void h(Real arg);

template <typename T>
void g(const T &arg) { h(arg); }

template <typename T>
void f(T&& arg) { h(std::move(arg)); }

void run() {
  SumReducer<Real> sumAParRelError = 0;
  // Check handling of hyperobject lookup when result requires extra const qualifier.
  g(sumAParRelError);
  // Check handling of hyperobject lookup when result treated as xvalue.
  f(sumAParRelError);
}

// CHECK-LABEL: define {{.*}}void @_Z3runv()
// CHECK: %[[SUMAPARRELERROR:.+]] = alloca double
// CHECK: call void @llvm.reducer.register.i64(ptr %[[SUMAPARRELERROR]]
// CHECK-NEXT: call void @_Z1gIHdEvRKT_(ptr {{.*}}%[[SUMAPARRELERROR]])
// CHECK-NEXT: call void @_Z1fIRHdEvOT_(ptr {{.*}}%[[SUMAPARRELERROR]])
// CHECK-NEXT: call void @llvm.reducer.unregister(ptr %sumAParRelError)

// CHECK-LABEL: define {{.*}}void @_Z1gIHdEvRKT_(ptr
// CHECK: %[[LOOKUP:.+]] = call ptr @llvm.hyper.lookup.i64(ptr
// CHECK-NEXT: %[[VIEW:.+]] = load double, ptr %[[LOOKUP]]
// CHECK-NEXT: call void @_Z1hd(double {{.*}}%[[VIEW]])

// CHECK-LABEL: define {{.*}}void @_Z1fIRHdEvOT_(ptr
// CHECK: %[[LOOKUP:.+]] = call ptr @llvm.hyper.lookup.i64(ptr
// CHECK-NEXT: %[[VIEW:.+]] = load double, ptr %[[LOOKUP]]
// CHECK-NEXT: call void @_Z1hd(double {{.*}}%[[VIEW]])
