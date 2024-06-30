// Test case for code generation of Tapir for Cilk code that uses exceptions.
//
// RUN: %clang_cc1 -fcxx-exceptions -fexceptions -fopencilk -ftapir=none -triple x86_64-unknown-linux-gnu -std=c++11 -emit-llvm %s -o - | FileCheck %s

void handle_exn(int e = -1);

class Foo {
public:
  Foo() {}
  ~Foo() {}
};

int bar(Foo *f);
int quuz(int i) noexcept;
int baz(const Foo &f);
__attribute__((always_inline))
int foo(Foo *f) {
  try
    {
      bar(f);
    }
  catch (int e)
    {
      handle_exn(e);
    }
  return 0;
}

////////////////////////////////////////////////////////////////////////////////
/// Serial code snippets
////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @_Z15serial_noexcepti(
// CHECK-NOT: sync
void serial_noexcept(int n) {
  quuz(n);
  quuz(n);
}

// CHECK-LABEL: @_Z13serial_excepti(
// CHECK-NOT: sync
void serial_except(int n) {
  bar(new Foo());
  quuz(n);
}

// CHECK-LABEL: @_Z15serial_tryblocki(
// CHECK-NOT: sync
void serial_tryblock(int n) {
  try
    {
      quuz(n);
      bar(new Foo());
      quuz(n);
      bar(new Foo());
    }
  catch (int e)
    {
      handle_exn(e);
    }
  catch (...)
    {
      handle_exn();
    }
}

////////////////////////////////////////////////////////////////////////////////
/// _Cilk_for code snippets
////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @_Z20parallelfor_noexcepti(
// CHECK-NOT: detach within %{{.+}}, label %{{.+}}, label %{{.+}} unwind
// CHECK-NOT: landingpad
// CHECK-NOT: resume
void parallelfor_noexcept(int n) {
  _Cilk_for (int i = 0; i < n; ++i)
    quuz(i);
}

// CHECK-LABEL: @_Z18parallelfor_excepti(
// CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[DUNWIND:.+]]
// CHECK: call {{.*}}i8* @_Znwm(i64 noundef 1)
// CHECK: invoke void @_ZN3FooC1Ev(
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[TASKLPAD:.+]]
// CHECK: [[INVOKECONT2]]:
// CHECK: call {{.*}}i32 @_Z3barP3Foo(
// CHECK: reattach within %[[SYNCREG]]
// CHECK-DAG: sync within %[[SYNCREG]]
// CHECK: [[TASKLPAD]]:
// CHECK-NEXT: landingpad [[LPADTYPE:.+]]
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow
// CHECK: (token %[[SYNCREG]], [[LPADTYPE]] {{.+}})
// CHECK-NEXT: to label %[[DRUNREACH:.+]] unwind label %[[DUNWIND]]
// CHECK: [[DUNWIND]]:
// CHECK-NEXT: landingpad [[LPADTYPE]]
// CHECK-NEXT: cleanup
// CHECK: [[DRUNREACH]]:
// CHECK-NEXT: unreachable
void parallelfor_except(int n) {
  _Cilk_for (int i = 0; i < n; ++i)
    bar(new Foo());
}

// CHECK-LABEL: @_Z20parallelfor_tryblocki(
void parallelfor_tryblock(int n) {
  // CHECK: %[[SYNCREG1:.+]] = call token @llvm.syncregion.start()
  // CHECK: %[[SYNCREG2:.+]] = call token @llvm.syncregion.start()
  try
    {
      // CHECK-NOT: detach within %[[SYNCREG1]], label %{{.+}}, label %{{.+}} unwind
      _Cilk_for (int i = 0; i < n; ++i)
        quuz(i);
      // CHECK: invoke void @llvm.sync.unwind(token %[[SYNCREG1]])
      // CHECK-NEXT: to label %{{.+}} unwind label %[[CATCH:.+]]
      // CHECK: [[CATCH]]:
      // CHECK: landingpad [[LPADTYPE]]
      // CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
      // CHECK-NEXT: catch i8* null

      // CHECK: detach within %[[SYNCREG2]], label %[[DETACHED:.+]], label %{{.+}} unwind label %[[CATCH]]
      // CHECK: [[DETACHED]]:
      // CHECK: %[[OBJ:.+]] = invoke {{.*}}i8* @_Znwm(i64 noundef 1)
      // CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[TASKLPAD:.+]]
      // CHECK: [[INVOKECONT1]]
      // CHECK: invoke void @_ZN3FooC1Ev(%class.Foo*
      // CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[TASKLPAD2:.+]]
      // CHECK: [[INVOKECONT2]]
      // CHECK: invoke {{.*}}i32 @_Z3barP3Foo(%class.Foo*
      // CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[TASKLPAD:.+]]
      // CHECK: [[INVOKECONT3]]
      // CHECK: reattach within %[[SYNCREG2]]
      // CHECK-DAG: sync within %[[SYNCREG2]]
      // CHECK: [[TASKLPAD]]:
      // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
      // CHECK-NEXT: cleanup
      // CHECK: br label %[[TASKRESUME:.+]]
      // CHECK: [[TASKLPAD2]]:
      // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
      // CHECK-NEXT: cleanup
      // CHECK: call void @_ZdlPv(i8* noundef %[[OBJ]])
      // CHECK: br label %[[TASKRESUME]]
      // CHECK: [[TASKRESUME]]:
      // CHECK: invoke void @llvm.detached.rethrow
      // CHECK: (token %[[SYNCREG2]], [[LPADTYPE]] {{.+}})
      // CHECK-NEXT: to label {{.+}} unwind label %[[CATCH]]
      _Cilk_for (int i = 0; i < n; ++i)
        bar(new Foo());
    }
  catch (int e)
    {
      handle_exn(e);
    }
  catch (...)
    {
      handle_exn();
    }
}

// CHECK-LABEL: @_Z27parallelfor_tryblock_inlinei(
void parallelfor_tryblock_inline(int n) {
  // CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
  try
    {
      // CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %{{.+}} unwind label %[[DUNWIND:.+]]
      // CHECK: [[DETACHED]]:
      // CHECK: invoke {{.*}}i8* @_Znwm(
      // CHECK: invoke void @_ZN3FooC1Ev(
      // CHECK: invoke {{.*}}i32 @_Z3barP3Foo(
      // CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[TASKLPAD:.+]]
      // CHECK: [[TASKLPAD]]:
      // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
      // CHECK-NEXT: cleanup
      // CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
      // CHECK: br i1 {{.+}}, label {{.+}}, label %[[CATCHRESUME:.+]]
      // CHECK: [[CATCHRESUME]]:
      // CHECK: invoke void @llvm.detached.rethrow
      // CHECK: (token %[[SYNCREG]], [[LPADTYPE]] {{.+}})
      // CHECK-NEXT: to label {{.+}} unwind label %[[DUNWIND]]
      // CHECK: [[DUNWIND]]:
      // CHECK: landingpad [[LPADTYPE]]
      // CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
      // CHECK-NEXT: catch i8* null
      _Cilk_for (int i = 0; i < n; ++i)
        foo(new Foo());
    }
  catch (int e)
    {
      handle_exn(e);
    }
  catch (...)
    {
      handle_exn();
    }
}

////////////////////////////////////////////////////////////////////////////////
/// _Cilk_spawn code snippets
////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @_Z14spawn_noexcepti(
// CHECK-NOT: landingpad
// CHECK-NOT: detached.rethrow
void spawn_noexcept(int n) {
  _Cilk_spawn quuz(n);
  quuz(n);
}

// CHECK-LABEL: @_Z15spawn_tf_excepti(
void spawn_tf_except(int n) {
  // CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[EXN:.+]] = alloca i8*
  // CHECK: %[[EHSELECTOR:.+]] = alloca i32
  // CHECK: invoke void @_ZN3FooC1Ev(%class.Foo*
  // CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[TASKLPAD:.+]]
  // CHECK: [[INVOKECONT]]
  // CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %{{.+}}
  // CHECK: [[DETACHED]]:
  // CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
  // CHECK-NEXT: call {{.*}}i32 @_Z3barP3Foo(
  // CHECK-NEXT: reattach within %[[SYNCREG]]
  // CHECK: [[TASKLPAD]]:
  // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
  // CHECK-NEXT: cleanup
  // CHECK: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK: invoke void @llvm.taskframe.resume
  // CHECK: (token %[[TASKFRAME]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[TFUNWIND:.+]]
  // CHECK: [[TFUNWIND]]:
  // CHECK-NEXT: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK-NOT: load i8*, i8** %[[EXN]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTOR]],
  // CHECK: resume [[LPADTYPE]]
  _Cilk_spawn bar(new Foo());
  quuz(n);
}

// CHECK-LABEL: @_Z21spawn_stmt_destructori(
void spawn_stmt_destructor(int n) {
  // CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[REFTMP:.+]] = alloca %class.Foo
  // CHECK: %[[EXNTF:.+]] = alloca i8*
  // CHECK: %[[EHSELECTORTF:.+]] = alloca i32
  // CHECK: call void @_ZN3FooC1Ev(%class.Foo* {{.*}}nonnull {{.*}}dereferenceable(1) %[[REFTMP]])
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %{{.+}} unwind label %[[DUNWIND:.+]]
  // CHECK: [[DETACHED]]:
  // CHECK-NEXT: %[[EXN:.+]] = alloca i8*
  // CHECK-NEXT: %[[EHSELECTOR:.+]] = alloca i32
  // CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
  // CHECK-NEXT: invoke {{.*}}i32 @_Z3bazRK3Foo(
  // CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[TASKLPAD:.+]]
  // CHECK: [[INVOKECONT]]:
  // CHECK-NEXT: call void @_ZN3FooD1Ev(%class.Foo* {{.*}}nonnull {{.*}}dereferenceable(1) %[[REFTMP]])
  // CHECK-NEXT: reattach within %[[SYNCREG]]
  // CHECK: [[TASKLPAD]]:
  // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
  // CHECK-NEXT: cleanup
  // CHECK: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK: call void @_ZN3FooD1Ev(%class.Foo* {{.*}}nonnull {{.*}}dereferenceable(1) %[[REFTMP]])
  // CHECK: invoke void @llvm.detached.rethrow
  // CHECK: (token %[[SYNCREG]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[DUNWIND]]
  // CHECK: [[DUNWIND]]:
  // CHECK-NEXT: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK-NOT: load i8*, i8** %[[EXN]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTOR]],
  // CHECK: store i8* %{{.+}}, i8** %[[EXNTF]],
  // CHECK: store i32 %{{.+}}, i32* %[[EHSELECTORTF]],
  // CHECK: invoke void @llvm.taskframe.resume
  // CHECK: (token %[[TASKFRAME]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[TFUNWIND:.+]]
  // CHECK: [[TFUNWIND]]:
  // CHECK-NEXT: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK-NOT: load i8*, i8** %[[EXN]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTOR]],
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXNTF]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTORTF]],
  // CHECK-NOT: load i8*, i8** %[[EXNTF]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTORTF]],
  // CHECK: resume [[LPADTYPE]]
  _Cilk_spawn baz(Foo());
  quuz(n);
}

// CHECK-LABEL: @_Z21spawn_decl_destructori(
void spawn_decl_destructor(int n) {
  // CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[REFTMP:.+]] = alloca %class.Foo
  // CHECK: %[[EXNTF:.+]] = alloca i8*
  // CHECK: %[[EHSELECTORTF:.+]] = alloca i32
  // CHECK: call void @_ZN3FooC1Ev(%class.Foo* {{.*}}nonnull {{.*}}dereferenceable(1) %[[REFTMP]])
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %{{.+}} unwind label %[[DUNWIND:.+]]
  // CHECK: [[DETACHED]]:
  // CHECK-NEXT: %[[EXN:.+]] = alloca i8*
  // CHECK-NEXT: %[[EHSELECTOR:.+]] = alloca i32
  // CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
  // CHECK: %[[CALL:.+]] = invoke {{.*}}i32 @_Z3bazRK3Foo(
  // CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[TASKLPAD:.+]]
  // CHECK: [[INVOKECONT]]:
  // CHECK-NEXT: call void @_ZN3FooD1Ev(%class.Foo* {{.*}}nonnull {{.*}}dereferenceable(1) %[[REFTMP]])
  // CHECK-NEXT: store i32 %[[CALL]]
  // CHECK-NEXT: reattach within %[[SYNCREG]]
  // CHECK: [[TASKLPAD]]:
  // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
  // CHECK-NEXT: cleanup
  // CHECK: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK: call void @_ZN3FooD1Ev(%class.Foo* {{.*}}nonnull {{.*}}dereferenceable(1) %[[REFTMP]])
  // CHECK: invoke void @llvm.detached.rethrow
  // CHECK: (token %[[SYNCREG]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[DUNWIND]]
  // CHECK: [[DUNWIND]]:
  // CHECK-NEXT: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK-NOT: load i8*, i8** %[[EXN]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTOR]],
  // CHECK: store i8* %{{.+}}, i8** %[[EXNTF]],
  // CHECK: store i32 %{{.+}}, i32* %[[EHSELECTORTF]],
  // CHECK: invoke void @llvm.taskframe.resume
  // CHECK: (token %[[TASKFRAME]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[TFUNWIND:.+]]
  // CHECK: [[TFUNWIND]]:
  // CHECK-NEXT: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK-NOT: load i8*, i8** %[[EXN]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTOR]],
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXNTF]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTORTF]],
  // CHECK-NOT: load i8*, i8** %[[EXNTF]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTORTF]],
  // CHECK: resume [[LPADTYPE]]
  int result = _Cilk_spawn baz(Foo());
  quuz(n);
}

// Technically this code has a potential race between the spawned execution of
// baz and the destructor for f.  I see two ways around this problem.  1) Leave
// it to the user to resolve these races.  2) Delegate the execution of
// destructors to the runtime system and ensure that the runtime system executes
// destructors only on when the leftmost child returns.  I don't see a way the
// compiler can solve this on its own, particularly when spawns and syncs can
// happen dynamically.

// CHECK-LABEL: @_Z22spawn_block_destructori(
void spawn_block_destructor(int n) {
  // CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
  // CHECK: call void @_ZN3FooC1Ev(%class.Foo* {{.*}}nonnull {{.*}}dereferenceable(1) %[[REFTMP:.+]])
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK-NEXT: %[[EXNTF:.+]] = alloca i8*
  // CHECK-NEXT: %[[EHSELECTORTF:.+]] = alloca i32
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[DETCONT:.+]] unwind label %[[DUNWIND:.+]]
  // CHECK: [[DETACHED]]:
  // CHECK-NEXT: %[[EXN:.+]] = alloca i8*
  // CHECK-NEXT: %[[EHSELECTOR:.+]] = alloca i32
  // CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
  // CHECK: %[[CALL:.+]] = invoke {{.*}}i32 @_Z3bazRK3Foo(
  // CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[TASKLPAD:.+]]
  // CHECK: [[INVOKECONT]]:
  // CHECK-NEXT: store i32 %[[CALL]]
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[DETCONT]]
  // CHECK: [[DETCONT]]:
  // CHECK: call {{.*}}i32 @_Z4quuzi(
  // CHECK-NEXT: call void @_ZN3FooD1Ev(
  // CHECK: [[TASKLPAD]]:
  // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
  // CHECK-NEXT: cleanup
  // CHECK: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK: invoke void @llvm.detached.rethrow
  // CHECK: (token %[[SYNCREG]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[DUNWIND]]
  // CHECK: [[DUNWIND]]:
  // CHECK: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK-NOT: load i8*, i8** %[[EXN]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTOR]],
  // CHECK: store i8* %{{.+}}, i8** %[[EXNTF]],
  // CHECK: store i32 %{{.+}}, i32* %[[EHSELECTORTF]],
  // CHECK: invoke void @llvm.taskframe.resume
  // CHECK: (token %[[TASKFRAME]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[TFUNWIND:.+]]
  // CHECK: [[TFUNWIND]]:
  // CHECK-NEXT: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXN]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTOR]],
  // CHECK-NOT: load i8*, i8** %[[EXN]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTOR]],
  // CHECK-NOT: store i8* %{{.+}}, i8** %[[EXNTF]],
  // CHECK-NOT: store i32 %{{.+}}, i32* %[[EHSELECTORTF]],
  // CHECK-NOT: load i8*, i8** %[[EXNTF]],
  // CHECK-NOT: load i32, i32* %[[EHSELECTORTF]],
  // CHECK: resume [[LPADTYPE]]
  {
    auto f = Foo();
    int result = _Cilk_spawn baz(f);
    quuz(n);
  }
}

// CHECK-LABEL: @_Z18spawn_throw_inlinei(
void spawn_throw_inline(int n) {
  // CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK: call {{.*}}i8* @_Znwm(
  // CHECK: invoke void @_ZN3FooC1Ev(
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %{{.+}} unwind label %[[DUNWIND:.+]]
  // CHECK: [[DETACHED]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
  // CHECK: invoke {{.*}}i32 @_Z3barP3Foo(
  // CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[TASKLPAD:.+]]
  // CHECK: [[TASKLPAD]]:
  // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
  // CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
  // CHECK: br i1 {{.+}}, label {{.+}}, label %[[CATCHRESUME:.+]]
  // CHECK: [[CATCHRESUME]]:
  // CHECK: invoke void @llvm.detached.rethrow
  // CHECK: (token %[[SYNCREG]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[DUNWIND]]
  // CHECK: [[DUNWIND]]:
  // CHECK-NEXT: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.taskframe.resume
  // CHECK: (token %[[TASKFRAME]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label {{.+}}
  _Cilk_spawn foo(new Foo());
  quuz(n);
}

// CHECK-LABEL: @_Z14spawn_tryblocki(
void spawn_tryblock(int n) {
  // CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  try
    {
      // CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]]
      // CHECK-NOT: unwind
      // CHECK: [[DETACHED1]]:
      // CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
      // CHECK-NEXT: call {{.*}}i32 @_Z4quuzi(
      // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]
      _Cilk_spawn quuz(n);
      // CHECK: %[[TASKFRAME2:.+]] = call token @llvm.taskframe.create()
      // CHECK: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DUNWIND:.+]]
      // CHECK: [[DETACHED2]]:
      // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
      // CHECK: invoke {{.*}}i32 @_Z3barP3Foo(
      // CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[TASKLPAD:.+]]
      // CHECK: [[INVOKECONT1]]:
      // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]
      _Cilk_spawn bar(new Foo());
      // CHECK: %[[TASKFRAME3:.+]] = call token @llvm.taskframe.create()
      // CHECK: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]]
      // CHECK: [[DETACHED3]]:
      // CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
      // CHECK-NEXT: call {{.*}}i32 @_Z4quuzi(
      // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]
      _Cilk_spawn quuz(n);
      // CHECK: [[CONTINUE3]]:
      // CHECK: invoke {{.*}}i32 @_Z3barP3Foo(
      // CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[CONT3UNWIND:.+]]
      bar(new Foo());
      // CHECK: [[INVOKECONT2]]:
      // CHECK-NEXT: sync within %[[SYNCREG]]
      _Cilk_sync;
    }
  // CHECK: [[DUNWIND]]:
  // CHECK: landingpad [[LPADTYPE]]
  // CHECK-NEXT: cleanup
  // CHECK: [[TASKLPAD]]:
  // CHECK-NEXT: landingpad [[LPADTYPE:.+]]
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.detached.rethrow
  // CHECK: (token %[[SYNCREG]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[DUNWIND]]
  // CHECK: invoke void @llvm.taskframe.resume
  // CHECK: (token %[[TASKFRAME2]], [[LPADTYPE]] {{.+}})
  // CHECK-NEXT: to label {{.+}} unwind label %[[CONT3UNWIND]]
  // CHECK: [[CONT3UNWIND]]:
  // CHECK: landingpad [[LPADTYPE]]
  // CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
  // CHECK-NEXT: catch i8* null
  catch (int e)
    {
      handle_exn(e);
    }
  catch (...)
    {
      handle_exn();
    }
}
