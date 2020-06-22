// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

extern int g(int);

void f(int x)
{
  g(_Cilk_spawn g(x));
}

// CHECK-LABEL define {{.*}}void @f(
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTIN:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call i32 @g(
// CHECK: call i32 @g(
// CHECK: reattach within %[[SYNCREG]], label %[[CONTIN]]
