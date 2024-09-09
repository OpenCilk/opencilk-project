// RUN: %clang_cc1 %s -x c++ -fopencilk -S -emit-llvm -disable-llvm-passes -triple aarch64-freebsd14.1 -o - | FileCheck %s

struct S {
  static void identity(void *);
  static void reduce(void *, void *);
  int _Hyperobject(identity, reduce) member = 0;
  S();
  ~S();
};

// CHECK-LABEL: _ZN1SC2Ev
// CHECK: call void @llvm.reducer.register
S::S() {}

// CHECK-LABEL: _ZN1SD2Ev
// CHECK: call void @llvm.reducer.unregister
S::~S() {}

void f() {
  struct S s;
}
