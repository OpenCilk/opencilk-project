// RUN: %clang_cc1 -std=c++1z -fexceptions -fcxx-exceptions -fopencilk -ftapir=none -triple x86_64-unknown-linux-gnu -emit-llvm %s -o - | FileCheck %s
// expected-no-diagnostics

void printf(const char *format, ...);
void pitcher(int x);
void pitcher(const char *x);

void foo() {
  _Cilk_spawn printf("Hi\n");
  try {
    _Cilk_spawn pitcher(1);
    try {
      pitcher("a");
    } catch (int x) {
      printf("foo inner caught %d\n", x);
    }
  }
  catch (const char *x) {
    printf("foo caught \"%s\"\n", x);
  }
}

// CHECK: define {{.*}}void @_Z3foov()
// CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
// CHECK: detach within %[[SYNCREG]]
// CHECK: reattach within %[[SYNCREG]]

// CHECK: call token @llvm.taskframe.create()
// CHECK: %[[SYNCREG1:.+]] = call token @llvm.syncregion.start()
// CHECK: detach within %[[SYNCREG1]]
// CHECK: reattach within %[[SYNCREG1]]

// CHECK: %[[TF:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: invoke void @_Z7pitcherPKc(
// CHECK-NEXT: to label %{{.+}} unwind label %[[NESTEDLPAD:.+]]

// CHECK: [[NESTEDLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br i1 {{.+}}, label {{.+}}, label %[[EHCLEANUP:.+]]

// CHECK: call void @llvm.taskframe.end(token %[[TF]])
// CHECK: sync within %[[SYNCREG1]]

// CHECK: [[EHCLEANUP]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TF]],

int main(int argc, char *argv[])
{
  try {
    foo();
  } catch (int x) {
    printf("main caught %d\n", x);
  }
  return 0;
}
