// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fcilkplus -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

void bar();

void foo(int p) {
  _Cilk_spawn bar();
  if (p)
    return;
  bar();
}

// CHECK-LABEL: define {{.*}}void @foo(
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call void {{.*}}@bar()
// CHECK: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK: br i1 %{{.+}}, label %[[THEN:.+]], label %[[END:.+]]

// CHECK: [[THEN]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

// CHECK: [[END]]:
// CHECK-NEXT: call void {{.*}}@bar()
// CHECK-NEXT: sync within %[[SYNCREG]]

// CHECK: ret void

