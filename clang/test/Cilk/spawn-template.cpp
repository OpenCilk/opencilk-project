// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fcilkplus -fcxx-exceptions -fexceptions -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

template<typename intT>
intT fib(intT n) {
  if (n < 2) return n;
  intT x = _Cilk_spawn fib(n - 1);
  intT y = fib(n - 2);
  _Cilk_sync;
  return (x + y);
}

template<typename intT>
intT fib_exc(intT n) {
  if (n < 2) return n;
  try {
    intT x = _Cilk_spawn fib_exc(n - 1);
    intT y = fib_exc(n - 2);
    _Cilk_sync;
    return (x + y);
  } catch (...) {
    return intT(-1);
  }
}

long foo() {
  return fib(38) + fib_exc(38);
}

// CHECK-LABEL: define {{.+}}i32 @_Z3fibIiET_S0_(i32 %n)

// CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETBLK:.+]], label %[[CONTBLK:.+]]

// CHECK: [[DETBLK]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: %[[RETVAL:.+]] = call i32 @_Z3fibIiET_S0_
// CHECK-NEXT: store i32 %[[RETVAL]], i32*
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTBLK]]

// CHECK: [[CONTBLK]]:
// CHECK: %[[RETVAL2:.+]] = call i32 @_Z3fibIiET_S0_
// CHECK-NEXT: store i32 %[[RETVAL2]]
// CHECK-NEXT: sync within %[[SYNCREG]]


// CHECK-LABEL: define {{.+}}i32 @_Z7fib_excIiET_S0_(i32 %n)

// CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETBLK:.+]], label %[[CONTBLK:.+]] unwind label %[[TFLPAD:.+]]

// CHECK: [[DETBLK]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK: %[[RETVAL:.+]] = invoke i32 @_Z7fib_excIiET_S0_
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[DETLPAD:.+]]

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: store i32 %[[RETVAL]], i32*
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTBLK]]

// CHECK: [[CONTBLK]]:
// CHECK: %[[RETVAL2:.+]] = invoke i32 @_Z7fib_excIiET_S0_
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[OUTERLPAD:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: store i32 %[[RETVAL2]]
// CHECK-NEXT: sync within %[[SYNCREG]]

// CHECK: [[DETLPAD]]:
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[TFLPAD]]

// CHECK: [[TFLPAD]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[OUTERLPAD]]

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable
