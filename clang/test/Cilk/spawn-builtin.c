// Check the spawning of builtins.
//
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fcilkplus -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s

// Thanks to Brian Wheatman for originally finding the bug captured by this
// test.
void spawn_memcpy(float *A, float *B, int n) {
  _Cilk_spawn __builtin_memcpy(A, B, sizeof(float) * n/2);
  __builtin_memcpy(A+n/2, B+n/2, sizeof(float) * (n-n/2));
  _Cilk_sync;
}

// CHECK-LABEL: define {{.*}}void @spawn_memcpy(
// CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETBLOCK:.+]], label %[[CONT:.+]]
// CHECK: [[DETBLOCK]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: call void @llvm.memcpy
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONT]]
// CHECK: call void @llvm.memcpy
// CHECK: sync within %[[SYNCREG]]

void spawn_unreachable() {
  _Cilk_spawn __builtin_unreachable();
}

// CHECK-LABEL: define {{.*}}void @spawn_unreachable(
// CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETBLOCK:.+]], label %[[CONT:.+]]
// CHECK: [[DETBLOCK]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: unreachable
// CHECK-NOT: reattach
// CHECK: [[CONT]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

void cilkfor_unreachable() {
  _Cilk_for(int i = 0; i < 1; ++i)
      __builtin_unreachable();
}

// CHECK-LABEL: define {{.*}}void @cilkfor_unreachable(
// CHECK: detach within %[[SYNCREG:.+]], label %[[PFORBODY:.+]], label %[[PFORINC:.+]]
// CHECK: [[PFORBODY]]:
// CHECK: unreachable
// Clang codegen for Cilk emits a block with no predecessors that contains a
// reattach.
// CHECK: reattach within %[[SYNCREG]], label %[[PFORINC]]
// CHECK: [[PFORINC]]:
// CHECK: sync within %[[SYNCREG]]

void spawn_trap() {
  _Cilk_spawn __builtin_trap();
}

// CHECK-LABEL: define {{.*}}void @spawn_trap(
// CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETBLOCK:.+]], label %[[CONT:.+]]
// CHECK: [[DETBLOCK]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: call void @llvm.trap()
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONT]]
// CHECK: [[CONT]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

void spawn_assume() {
  _Cilk_spawn __builtin_assume(0); // expected-warning{{Failed to produce spawn}}
}

// It doesn't make sense to spawn an assume, so we expect not to find any
// Tapir instructions.
// CHECK-LABEL: define {{.*}}void @spawn_assume(
// CHECK-NOT: detach
// CHECK: call void @llvm.assume
// CHECK-NOT: sync
