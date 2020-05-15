// RUN: %clang_cc1 -fcxx-exceptions -fexceptions -fcilkplus -ftapir=none -triple x86_64-unknown-linux-gnu -std=c++11 -emit-llvm %s -o - | FileCheck %s

class Obj {
public:
  Obj();
  ~Obj();
};

void bar();

void foo(int p) {
  Obj o1;
  _Cilk_spawn bar();
  if (p)
    return;
  Obj o2;
  bar();
}

// CHECK-LABEL: define {{.*}}void @_Z3fooi(i32
// CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind

// CHECK: [[DETACHED]]:
// CHECK: invoke void @_Z3barv()
// CHECK: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK: br i1 %{{.+}}, label %[[THEN:.+]], label %[[END:.+]]

// CHECK: [[THEN]]:
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[SUCONT:.+]] unwind label

// CHECK: [[SUCONT]]:
// CHECK: br label %[[CLEANUP:.+]]

// CHECK: [[END]]:
// CHECK-NEXT: invoke void @_ZN3ObjC1Ev(%class.Obj* %[[O2:.+]])
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: invoke void @_Z3barv()
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT2:.+]]

// CHECK: [[SYNCCONT2]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[SUCONT2:.+]] unwind label

// CHECK: [[SUCONT2]]:
// CHECK-NEXT: call void @_ZN3ObjD1Ev(%class.Obj* %[[O2:.+]])
// CHECK: br label %[[CLEANUP]]

// CHECK: [[CLEANUP]]:
// CHECK-NEXT: call void @_ZN3ObjD1Ev(%class.Obj* %[[O1:.+]])

// CHECK: ret void
