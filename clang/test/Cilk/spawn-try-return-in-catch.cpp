// RUN: %clang_cc1 -std=c++1z -fexceptions -fcxx-exceptions -fopencilk -ftapir=none -triple x86_64-unknown-linux-gnu -emit-llvm %s -o - | FileCheck %s
// expected-no-diagnostics
extern "C" int sleep(int);

struct S {
  int s;
  S() noexcept;
  ~S();
};

int __attribute__((noinline)) spawning()
{
  S s1;
  cilk_spawn sleep(3);
  try {
    S s2;
    cilk_spawn sleep(1);
  } catch (int x) {
    return x;
  }
  sleep(2);
  return 0;
}

// CHECK: define dso_local noundef i32 @_Z8spawningv()
// CHECK: entry:
// CHECK-NEXT: %[[RETVAL:.+]] = alloca i32
// CHECK-NEXT: %[[S1:.+]] = alloca %struct.S
// CHECK-NEXT: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
// CHECK-NEXT: alloca ptr
// CHECK-NEXT: alloca i32
// CHECK-NEXT: %[[CLEANUP_DEST_SLOT:.+]] = alloca i32
// CHECK-NEXT: call void @_ZN1SC1Ev(ptr {{.*}}%[[S1]])
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind

// CHECK: [[CONTINUE]]:
// CHECK: %[[TF1:.+]] = call token @llvm.taskframe.create()
// CHECK: %[[S2:.+]] = alloca %struct.S
// CHECK: %[[SYNCREG12:.+]] = call token @llvm.syncregion.start()
// CHECK-NEXT: alloca ptr
// CHECK-NEXT: alloca i32
// CHECK-NEXT: %[[X:.+]] = alloca i32
// CHECK-NEXT: call void @_ZN1SC1Ev(ptr {{.*}}%[[S2]])
// CHECK: %[[TF2:.+]] = call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG12]], label %[[DETACHED13:.+]], label %[[CONTINUE27:.+]] unwind label %[[LPAD24:.+]]

// CHECK: [[CONTINUE27]]:
// CHECK-NEXT: sync within %[[SYNCREG12]], label %[[SYNC_CONTINUE:.+]]

// CHECK: [[SYNC_CONTINUE]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG12]])
// CHECK-NEXT: to label %[[INVOKE_CONT36:.+]] unwind label %[[LPAD33:.+]]

// CHECK: [[INVOKE_CONT36]]:
// CHECK-NEXT: call void @_ZN1SD1Ev(ptr {{.*}}%[[S2]])
// CHECK-NEXT: br label %[[TRY_CONT:.+]]

// CHECK: [[LPAD24]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF2]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[LPAD33]]

// CHECK: [[LPAD33]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch ptr @_ZTIi
// CHECK: call void @_ZN1SD1Ev(ptr {{.*}}%[[S2]])

// CHECK: call i32 @llvm.eh.typeid.for.p0(ptr @_ZTIi)
// CHECK: br i1 {{.+}}, label %[[CATCH:.+]], label %[[EHCLEANUP44:.+]]

// CHECK: [[CATCH]]:
// CHECK: %[[CAUGHT:.+]] = call ptr @__cxa_begin_catch(ptr
// CHECK-NEXT: %[[LOAD23:.+]] = load i32, ptr %[[CAUGHT]]
// CHECK-NEXT: store i32 %[[LOAD23]], ptr %[[X]]
// CHECK-NEXT: %[[LOAD24:.+]] = load i32, ptr %[[X]]
// CHECK-NEXT: store i32 %[[LOAD24]], ptr %[[RETVAL]]
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONTINUE40:.+]]

// CHECK: [[SYNC_CONTINUE40]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[INVOKE_CONT42:.+]] unwind label %[[LPAD41:.+]]

// CHECK: [[INVOKE_CONT42]]:
// CHECK-NEXT: store i32 1, ptr %[[CLEANUP_DEST_SLOT]]
// CHECK-NEXT: call void @__cxa_end_catch()
// CHECK-NEXT: br label %[[CLEANUP:.+]]

// CHECK: [[LPAD41]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: call void @__cxa_end_catch()
// CHECK-NEXT: br label %[[EHCLEANUP44]]

// CHECK: [[TRY_CONT]]:
// CHECK-NEXT: store i32 0, ptr %[[CLEANUP_DEST_SLOT]]
// CHECK-NEXT: br label %[[CLEANUP]]

// CHECK: [[CLEANUP]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TF1]])
// CHECK-NEXT: %[[CLEANUP_DEST:.+]] = load i32, ptr %[[CLEANUP_DEST_SLOT]]
// CHECK-NEXT: switch i32 %[[CLEANUP_DEST]], label %[[CLEANUP53:.+]] [
// CHECK-NEXT: i32 0, label %[[CLEANUP_CONT:.+]]
// CHECK-NEXT: ]

// CHECK: [[CLEANUP_CONT]]:
// CHECK-NEXT: invoke i32 @sleep(i32 {{.*}}2)
// CHECK-NEXT: to label %[[INVOKE_CONT49:.+]] unwind

// CHECK: [[INVOKE_CONT49]]:
// CHECK-NEXT: store i32 0, ptr %[[RETVAL]]
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONTINUE51:.+]]

// CHECK: [[SYNC_CONTINUE51]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[INVOKE_CONT52:.+]] unwind

// CHECK: [[INVOKE_CONT52]]:
// CHECK-NEXT: store i32 1, ptr %[[CLEANUP_DEST_SLOT]]
// CHECK-NEXT: br label %[[CLEANUP53]]

// CHECK: [[EHCLEANUP44]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind

// CHECK: [[CLEANUP53]]:
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONTINUE54:.+]]

// CHECK: [[SYNC_CONTINUE54]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[INVOKE_CONT55:.+]] unwind

// CHECK: [[INVOKE_CONT55]]:
// CHECK-NEXT: call void @_ZN1SD1Ev(ptr {{.*}}%[[S1]])
// CHECK-NEXT: %[[LOAD28:.+]] = load i32, ptr %[[RETVAL]]
// CHECK-NEXT: ret i32 %[[LOAD28]]
