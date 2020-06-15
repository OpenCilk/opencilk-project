// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fopencilk -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

extern int cilk_main(int, char **);

void f(_Atomic int *out, int argc, char **argv)
{
  __c11_atomic_store(out, _Cilk_spawn cilk_main(argc, argv), __ATOMIC_RELAXED);
}

// CHECK-LABEL define {{.*}}void @f(
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTIN:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call i32 @cilk_main(
// CHECK: store atomic i32
// CHECK: reattach within %[[SYNCREG]], label %[[CONTIN]]
