// Check that a sync is not inserted when clang recognizes that it is not reachable.
//
// RUN: %clang_cc1 -fopencilk -ftapir=none -triple x86_64-unknown-linux-gnu -std=c++11 -emit-llvm %s -o - | FileCheck %s
int create() {
  return 1;
  _Cilk_sync;
}

// CHECK: define dso_local {{.*}}i32 @_Z6createv()
// CHECK: {
// CHECK: ret i32 1
// CHECK-NOT: sync
// CHECK: }

int main([[maybe_unused]] int argc, char *argv[]) {
  int e = create();
  return 0;
}
