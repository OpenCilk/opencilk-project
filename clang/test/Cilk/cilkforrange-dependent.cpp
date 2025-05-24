// Check that range-cilk_for loops with dependent types are handled properly.
//
// RUN: %clang_cc1 %s -std=c++11 -triple x86_64-unknown-linux-gnu -fopencilk -ftapir=none -verify -emit-llvm -o - | FileCheck %s
template<typename T>
struct C {
  C();
  struct It {
    T value;
    long operator-(It &);
    It operator+(long);
    It operator++();
    It operator--();
    T &operator*();
    bool operator!=(It &);
  };
  It begin();
  It end();
};

template <typename T>
void bar(T t);

template <typename C>
void iterate(C c) {
  cilk_for(auto &x : c) // expected-warning {{'cilk_for' support for for-range loops is currently experimental}}
      bar(x);
}

void foo() {
    C<int> container;
    iterate(container);
}

// CHECK-LABEL: define {{.*}}void @_Z7iterateI1CIiEEvT_()
// CHECK: detach within %[[SYNCREG:.+]], label %[[PFOR_BODY:.+]], label %[[PFOR_INC:.+]]

// CHECK: [[PFOR_BODY]]:
// CHECK: call void @_Z3barIiEvT_(
// CHECK: reattach within %[[SYNCREG]], label %[[PFOR_INC]]

// CHECK: [[PFOR_INC]]:

// CHECK: sync within %[[SYNCREG]], label %[[SYNC_CONT:.+]]
