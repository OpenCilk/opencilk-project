// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -verify -ftapir=none -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

extern int g(int);
extern int h(int, int, int);

void f(int x)
{
  g(_Cilk_spawn g(x));
  _Cilk_spawn g(_Cilk_spawn g(x));
  h(g(x), _Cilk_spawn g(x), g(x));
}

// CHECK-LABEL define {{.*}}void @f(
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTIN:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call i32 @g(
// CHECK: call i32 @g(
// CHECK: reattach within %[[SYNCREG]], label %[[CONTIN]]

// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED2:.+]], label %[[CONTIN2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call i32 @g(
// CHECK: call i32 @g(
// CHECK: reattach within %[[SYNCREG]], label %[[CONTIN2]]

// CHECK: call i32 @g(
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED3:.+]], label %[[CONTIN3:.+]]

// CHECK: [[DETACHED3]]:
// CHECK: call i32 @g(
// CHECK: call i32 @g(
// CHECK: call i32 @h(
// CHECK: reattach within %[[SYNCREG]], label %[[CONTIN3]]