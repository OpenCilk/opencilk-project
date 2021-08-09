// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -O0 -fopencilk -verify -S -emit-llvm -ftapir=none -o - | FileCheck %s
// expected-no-diagnostics

void bar(int x);

void foo(int x) {
  _Cilk_scope {
    _Cilk_spawn bar(x);
    if (x < 1)
      return;
    bar(x-1);
  }
  bar(x+1);
}

// CHECK: define {{.*}}void @foo(

// CHECK: %[[TAPIR_RT_START:.+]] = call token @llvm.tapir.runtime.start()
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call void @bar(
// CHECK: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK: %[[CMP:.+]] = icmp slt i32 %{{.+}}, 1
// CHECK-NEXT: br i1 %[[CMP]], label %[[IF_THEN:.+]], label %[[IF_END:.+]]

// CHECK: [[IF_THEN]]:
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONT:.+]]

// CHECK: [[IF_END]]:
// CHECK: call void @bar(
// CHECK: br label %[[CLEANUP:.+]]

// CHECK: [[CLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONT2:.+]]

// CHECK: call void @llvm.tapir.runtime.end(token %[[TAPIR_RT_START]])

// CHECK: call void @bar(

// CHECK: ret void

