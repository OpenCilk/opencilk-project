// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fcilkplus -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

void bar();
int baz(int);

void foo(int p) {
  while (p) {
    if (baz(p))
      return;
    _Cilk_spawn bar();
    --p;
  }
  bar();
}

// CHECK-LABEL: define {{.*}}void @foo(

// CHECK: br i1 %{{.+}}, label %[[WHILE_BODY:.+]], label %[[WHILE_END:.+]]

// CHECK: [[WHILE_BODY]]:
// CHECK: br i1 %{{.+}}, label %[[THEN:.+]], label %[[END:.+]]

// CHECK: [[THEN]]:
// CHECK-NEXT: br label %[[RETURN:.+]]

// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call void {{.*}}@bar()
// CHECK: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK: br

// CHECK: [[WHILE_END]]:
// CHECK-NEXT: call void {{.*}}@bar()
// CHECK-NEXT: br label %[[RETURN]]

// CHECK: [[RETURN]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

// CHECK: ret void
