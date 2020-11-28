// Verify that a sync is added implicitly at the end of appropriate scopes and
// before destructors.
//
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fcilkplus -fcxx-exceptions -fexceptions -ftapir=none -S -emit-llvm -o - | FileCheck %s --check-prefixes=CHECK,CHECK-O0
// RUN: %clang_cc1 %s -O1 -mllvm -simplify-taskframes=false -triple x86_64-unknown-linux-gnu -fcilkplus -fcxx-exceptions -fexceptions -ftapir=none -S -emit-llvm -o - | FileCheck %s --check-prefixes=CHECK,CHECK-O1
// expected-no-diagnostics

class Bar {
public:
  Bar();
  ~Bar();
  Bar(const Bar &that);
  Bar(Bar &&that);
  Bar &operator=(Bar that);
  friend void swap(Bar &left, Bar &right);
};

void nothrowfn(int a) noexcept;
void catchfn_c(int i, char e) noexcept;
void catchfn_i(int i, int e) noexcept;

void bar(int a) {
  try {
    throw a;
  } catch (char e) {
    catchfn_c(1, e);
  }
}

/// Test that no sync is inserted in a function with no Cilk constructs.

// CHECK-LABEL: define {{.*}}void @_Z3bari(i32 %a)
// CHECK-NOT: sync
// CHECK: ret void

void foo(int a) {
  try {
    bar(a);
  } catch (char e) {
    catchfn_c(1, e);
  }
}

// CHECK-LABEL: define {{.*}}void @_Z3fooi(i32 %a)
// CHECK-NOT: sync
// CHECK: ret void

void spawn(int a) {
  _Cilk_spawn bar(a);
  nothrowfn(a);
}

/// Test that an implicit sync is inserted for the _Cilk_spawn in spawn().

// CHECK-LABEL: define {{.*}}void @_Z5spawni(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: call void @_Z3bari(
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK: call void @_Z9nothrowfni(
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONTINUE:.+]]

// CHECK: [[SYNCCONTINUE]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: ret void

void spawn_destructor(int a) {
  Bar b1;
  _Cilk_spawn bar(a);
  nothrowfn(a);
}

/// Test that an implicit sync is inserted for the _Cilk_spawn in
/// spawn_destructor(), and that the sync is inserted before implicit
/// destructors.

// CHECK-LABEL: define {{.*}}void @_Z16spawn_destructori(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(
// CHECK: call void @_ZN3BarC1Ev(
// CHECK: %[[TASKFRAME:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[DETUNWIND:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: invoke void @_Z3bari(
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK: call void @_Z9nothrowfni(
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONTINUE:.+]]

// CHECK: [[SYNCCONTINUE]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[SUCONT:.+]] unwind label %[[B1CLEANUP:.+]]
// CHECK: [[SUCONT]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(
// CHECK-NEXT: ret void

// CHECK: [[LPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND]]

// CHECK: [[DETUNWIND]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B1CLEANUP]]

// CHECK: [[B1CLEANUP]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: call void @_ZN3BarD1Ev(
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(
// CHECK-O1-NEXT: resume
// CHECK-O0-NEXT: br label %[[RESUME:.+]]

// CHECK-O0: [[RESUME]]:
// CHECK-O0: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int trycatch(int a) {
  try {
    _Cilk_spawn foo(1);
    nothrowfn(2);
  } catch (int e) {
    catchfn_i(1, e);
  }
  return 0;
}

/// Test that an implicit sync is inserted for a _Cilk_spawn in a try block, and
/// that the sync is inserted at the end of the try block.

// CHECK-LABEL: define {{.*}}i32 @_Z8trycatchi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[DETUNWIND:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 1)
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 2)
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[SUCONT:.+]] unwind label %[[CATCHLPAD:.+]]
// CHECK-O0: [[SUCONT]]:
// CHECK-O0-NEXT: br label %[[TRYCONT:.+]]

// CHECK: [[LPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND]]

// CHECK: [[DETUNWIND]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD]]

// CHECK: [[CATCHLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)

// CHECK-O0: [[TRYCONT]]:
// CHECK-O1: [[SUCONT]]:
// CHECK-NEXT: ret i32 0

int trycatch_destructor(int a) {
  Bar b1;
  try {
    Bar b2;
    _Cilk_spawn foo(1);
    nothrowfn(2);
  } catch (int e) {
    catchfn_i(1, e);
  }
  return 0;
}

/// Test that an implicit sync is inserted for a _Cilk_spawn in a try block, and
/// that the sync is inserted at the end of the try block, but before
/// destructors for that try block.

// CHECK-LABEL: define {{.*}}i32 @_Z19trycatch_destructori(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B1SIZE:.+]], i8* nonnull %[[B1ADDR:.+]])
// CHECK: call void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B1:.+]])
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B2SIZE:.+]], i8* nonnull %[[B2ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B2:.+]])
// CHECK-NEXT: to label %[[BARCONSTRCONT:.+]] unwind label %[[BARCONSTRLPAD:.+]]

// CHECK: [[BARCONSTRCONT]]:
// CHECK: %[[TASKFRAME:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[DETUNWIND:.+]]

// CHECK: [[DETACHED]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 1)
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 2)
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[SUCONT:.+]] unwind label %[[BARCONSTRLPAD]]
// CHECK: [[SUCONT]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK-NEXT: br label %[[TRYCONT:.+]]

// CHECK: [[BARCONSTRLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br label %[[CATCHDISPATCH:.+]]

// CHECK: [[LPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NOT: catch
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND]]

// CHECK: [[DETUNWIND]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NOT: catch
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD:.+]]

// CHECK: [[CATCHLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK: br label %[[CATCHDISPATCH]]

// CHECK: [[CATCHDISPATCH]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK: br i1 %{{.+}}, label %[[CATCH:.+]], label %[[EHCLEANUP:.+]]

// CHECK: [[CATCH]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT]]

// CHECK: [[TRYCONT]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-NEXT: ret i32 0

// CHECK: [[EHCLEANUP]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK: resume

int mix_spawn_trycatch(int a) {
  _Cilk_spawn foo(1);
  try {
    _Cilk_spawn foo(2);
    nothrowfn(3);
  } catch (int e) {
    catchfn_i(1, e);
  }
  return 0;
}

/// Test that separate implicit syncs are inserted for the _Cilk_spawn in a try
/// block, inserted at the end of the try block, and for a _Cilk_spawn outside
/// of the try block.

// CHECK-LABEL: define {{.*}}i32 @_Z18mix_spawn_trycatchi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-NEXT: call void @_Z3fooi(i32 1)
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK: %[[TFTRY:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TRYSYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 3)
// CHECK-NEXT: sync within %[[TRYSYNCREG]], label %[[TRYSYNCCONT:.+]]

// CHECK: [[TRYSYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG]])
// CHECK-NEXT: to label %[[TRYSUCONT:.+]] unwind label %[[CATCHLPAD:.+]]
// CHECK-O0: [[TRYSUCONT]]:
// CHECK-O0-NEXT: br label %[[TRYCONT:.+]]

// CHECK: [[LPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND]]

// CHECK: [[DETUNWIND]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD]]

// CHECK: [[CATCHLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br i1 %{{.+}}, label %[[CATCH:.+]], label %[[EHRESUME:.+]]

// CHECK: [[CATCH]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT]]

// CHECK-O0: [[TRYCONT]]:
// CHECK-O1: [[TRYSUCONT]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY]])
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK: ret i32 0

// CHECK: [[EHRESUME]]:
// CHECK: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int mix_spawn_trycatch_destructors(int a) {
  Bar b1;
  _Cilk_spawn foo(1);
  try {
    Bar b2;
    _Cilk_spawn foo(2);
    nothrowfn(3);
  } catch (int e) {
    catchfn_i(1, e);
  }
  return 0;
}

/// Test that separate implicit syncs are inserted for a _Cilk_spawn in a try
/// block and a _Cilk_spawn outside of the try block, and that the sync is
/// inserted before the end of those scopes, but before destructors.

// CHECK-LABEL: define {{.*}}i32 @_Z30mix_spawn_trycatch_destructorsi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B1SIZE:.+]], i8* nonnull %[[B1ADDR:.+]])
// CHECK: call void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B1:.+]])
// CHECK: %[[TASKFRAME:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]] unwind label %[[DETUNWIND1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 1)
// CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKECONT1]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK: %[[TFTRY:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TRYSYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B2SIZE:.+]], i8* nonnull %[[B2ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B2:.+]])
// CHECK-NEXT: to label %[[B2CONSTRCONT:.+]] unwind label %[[B2CONSTRLPAD:.+]]

// CHECK: [[B2CONSTRCONT]]:
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 3)
// CHECK-NEXT: sync within %[[TRYSYNCREG]], label %[[TRYSYNCCONT:.+]]

// CHECK: [[TRYSYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG]])
// CHECK-NEXT: to label %[[SUCONT:.+]] unwind label %[[CATCHLPAD:.+]]
// CHECK: [[SUCONT]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK-NEXT: br label %[[TRYCONT:.+]]

// CHECK: [[LPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NOT: catch
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND1]]

// CHECK: [[DETUNWIND1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NOT: catch
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[OUTERCLEANUPLPAD:.+]]

// CHECK: [[OUTERCLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NOT: catch
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-O0: br label %[[EHCLEANUP:.+]]
// CHECK-O1: resume

// CHECK: [[B2CONSTRLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br label %[[CATCHDISPATCH:.+]]

// CHECK: [[LPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NOT: catch
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND2]]

// CHECK: [[DETUNWIND2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NOT: catch
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD]]

// CHECK: [[CATCHLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK: br label %[[CATCHDISPATCH]]

// CHECK: [[CATCHDISPATCH]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK: br i1 %{{.+}}, label %[[CATCH:.+]], label %[[TFTRYCLEANUP:.+]]

// CHECK: [[CATCH]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT]]

// CHECK: [[TRYCONT]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY]])
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-O0-NEXT: to label %[[SUCONT:.+]] unwind label %[[OUTERCLEANUPLPAD]]
// CHECK-O0: [[SUCONT]]:
// CHECK-O0-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT2:.+]]
// CHECK-O1-NEXT: to label %[[SUCONT2:.+]] unwind label %[[OUTERCLEANUPLPAD]]

// CHECK: [[TFTRYCLEANUP]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TFTRY]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[OUTERCLEANUPLPAD]]

// CHECK-O0: [[SYNCCONT2]]:
// CHECK-O0-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-O0-NEXT: to label %[[SUCONT2:.+]] unwind label %[[OUTERCLEANUPLPAD]]

// CHECK: [[SUCONT2]]:
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-NEXT: ret i32 0

// CHECK-O0: [[EHCLEANUP]]:
// CHECK-O0: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int nested_trycatch(int a) {
  _Cilk_spawn foo(1);
  try {
    _Cilk_spawn foo(2);
    try {
      _Cilk_spawn foo(3);
      nothrowfn(4);
    } catch (int e) {
      catchfn_i(2, e);
    }
  } catch (int e) {
    catchfn_i(1, e);
  }
  return 0;
}

/// Test that implicit syncs are properly inserted at the end of try blocks when
/// there are nested try-catch statements.

// CHECK-LABEL: define {{.*}}i32 @_Z15nested_trycatchi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-NEXT: call void @_Z3fooi(i32 1)
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK: %[[TFTRY1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TRYSYNCREG1:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG1]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG1]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK: %[[TFTRY2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TRYSYNCREG2:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME3:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG2]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]] unwind label %[[DETUNWIND3:.+]]

// CHECK: [[DETACHED3]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 3)
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG2]], label %[[CONTINUE3]]

// CHECK: [[CONTINUE3]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 4)
// CHECK-NEXT: sync within %[[TRYSYNCREG2]], label %[[TRYSYNCCONT2:.+]]

// CHECK: [[TRYSYNCCONT2]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG2]])
// CHECK-NEXT: to label %[[TRYSUCONT2:.+]] unwind label %[[CATCHLPAD2:.+]]
// CHECK-O0: [[TRYSUCONT2]]:
// CHECK-O0-NEXT: br label %[[TRYCONT2:.+]]

// CHECK: [[LPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG1]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND2]]

// CHECK: [[DETUNWIND2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD1:.+]]

// CHECK: [[CATCHLPAD1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: br label %[[CATCHDISPATCH1:.+]]

// CHECK-O0: [[CATCHDISPATCH1]]:
// CHECK: br i1 %{{.+}}, label %[[CATCH1:.+]], label %[[TFTRYCLEANUP1:.+]]

// CHECK: [[CATCH1]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT1:.+]]

// CHECK: [[TRYCONT1]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY1]])
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK: ret i32 0

// CHECK: [[LPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND3]]

// CHECK: [[DETUNWIND3]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD2]]

// CHECK: [[CATCHLPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: br label %[[CATCHDISPATCH2:.+]]

// CHECK-O0: [[CATCHDISPATCH2]]:
// CHECK: br i1 %{{.+}}, label %[[CATCH2:.+]], label %[[TFTRYCLEANUP2:.+]]

// CHECK: [[CATCH2]]:
// CHECK: call void @_Z9catchfn_iii(i32 2,
// CHECK-O0: br label %[[TRYCONT2]]
// CHECK-O1: br label %[[TRYSUCONT2]]

// CHECK-O0: [[TRYCONT2]]:
// CHECK-O1: [[TRYSUCONT2]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY2]])
// CHECK-NEXT: sync within %[[TRYSYNCREG1]], label %[[TRYSYNCCONT1:.+]]

// CHECK: [[TRYSYNCCONT1]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG1]])
// CHECK-O0-NEXT: to label %[[TRYSUCONT1:.+]] unwind label %[[CATCHLPAD1]]
// CHECK-O0: [[TRYSUCONT1]]:
// CHECK-O0-NEXT: br label %[[TRYCONT1]]
// CHECK-O1-NEXT: to label %[[TRYCONT1:.+]] unwind label %[[CATCHLPAD1]]

// CHECK: [[TFTRYCLEANUP2]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TFTRY2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD1]]

// CHECK: [[TFTRYCLEANUP1]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TFTRY1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[EHRESUME:.+]]

// CHECK: [[EHRESUME]]:
// CHECK: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int nested_trycatch_destructors(int a) {
  Bar b1;
  _Cilk_spawn foo(1);
  try {
    Bar b2;
    _Cilk_spawn foo(2);
    try {
      Bar b3;
      _Cilk_spawn foo(3);
      nothrowfn(4);
    } catch (int e) {
      catchfn_i(2, e);
    }
  } catch (int e) {
    catchfn_i(1, e);
  }
  return 0;
}

/// Test that implicit syncs are properly inserted at the end of try blocks, but
/// before destructors, when there are nested try-catch statements.

// CHECK-LABEL: define {{.*}}i32 @_Z27nested_trycatch_destructorsi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B1SIZE:.+]], i8* nonnull %[[B1ADDR:.+]])
// CHECK: call void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B1:.+]])
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]] unwind label %[[DETUNWIND1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 1)
// CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[LPAD1:.+]]

// CHECK: [[INVOKECONT1]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK: %[[TFTRY1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TRYSYNCREG1:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B2SIZE:.+]], i8* nonnull %[[B2ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B2:.+]])
// CHECK-NEXT: to label %[[B2CONSTRCONT:.+]] unwind label %[[B2CONSTRLPAD:.+]]

// CHECK: [[B2CONSTRCONT]]:
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG1]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG1]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK: %[[TFTRY2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TRYSYNCREG2:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B3SIZE:.+]], i8* nonnull %[[B3ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B3:.+]])
// CHECK-NEXT: to label %[[B3CONSTRCONT:.+]] unwind label %[[B3CONSTRLPAD:.+]]

// CHECK: [[B3CONSTRCONT]]:
// CHECK: %[[TASKFRAME3:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG2]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]] unwind label %[[DETUNWIND3:.+]]

// CHECK: [[DETACHED3]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 3)
// CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[LPAD3:.+]]

// CHECK: [[INVOKECONT3]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG2]], label %[[CONTINUE3]]

// CHECK: [[CONTINUE3]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 4)
// CHECK-NEXT: sync within %[[TRYSYNCREG2]], label %[[TRYSYNCCONT2:.+]]

// CHECK: [[TRYSYNCCONT2]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG2]])
// CHECK-NEXT: to label %[[TRYSUCONT2:.+]] unwind label %[[B3CLEANUPLPAD:.+]]

// CHECK: [[TRYSUCONT2]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B3]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B3SIZE]], i8* nonnull %[[B3ADDR]])
// CHECK-NEXT: br label %[[TRYCONT2:.+]]

// CHECK: [[LPAD1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND1]]

// CHECK: [[DETUNWIND1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B1CLEANUPLPAD:.+]]

// CHECK: [[B1CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-O0: br label %[[EHRESUME:.+]]
// CHECK-O1: resume

// CHECK: [[B2CONSTRLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br label %[[CATCHDISPATCH1:.+]]

// CHECK: [[LPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND2]]

// CHECK: [[DETUNWIND2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B2CLEANUPLPAD:.+]]

// CHECK: [[B2CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK: br label %[[CATCHDISPATCH1]]

// CHECK-O0: [[CATCHDISPATCH1]]:
// CHECK-O0: br i1 %{{.+}}, label %[[CATCH1:.+]], label %[[EHCLEANUP1:.+]]

// CHECK-O0: [[CATCH1]]:
// CHECK-O0: call void @_Z9catchfn_iii(i32 1,
// CHECK-O0: br label %[[TRYCONT1:.+]]

// CHECK-O0: [[TRYCONT1]]:
// CHECK-O0-NEXT: call void @llvm.taskframe.end(token %[[TFTRY1]])
// CHECK-O0-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK-O0: [[SYNCCONT]]:
// CHECK-O0-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-O0-NEXT: to label %[[SUCONT:.+]] unwind label %[[B1CLEANUPLPAD]]

// CHECK-O0: [[SUCONT]]:
// CHECK-O0-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT2:.+]]

// CHECK: [[B3CONSTRLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br label %[[CATCHDISPATCH2:.+]]

// CHECK: [[LPAD3]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND3]]

// CHECK: [[DETUNWIND3]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B3CLEANUPLPAD]]

// CHECK: [[B3CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B3]])
// CHECK: br label %[[CATCHDISPATCH2]]

// CHECK: [[CATCHDISPATCH2]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B3SIZE]], i8* nonnull %[[B3ADDR]])
// CHECK: br i1 %{{.+}}, label %[[CATCH2:.+]], label %[[EHCLEANUP2:.+]]

// CHECK: [[CATCH2]]:
// CHECK: call void @_Z9catchfn_iii(i32 2,
// CHECK: br label %[[TRYCONT2]]

// CHECK: [[TRYCONT2]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY2]])
// CHECK-NEXT: sync within %[[TRYSYNCREG1]], label %[[TRYSYNCCONT1:.+]]

// CHECK: [[TRYSYNCCONT1]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG1]])
// CHECK-NEXT: to label %[[TRYSUCONT1:.+]] unwind label %[[B2CLEANUPLPAD]]

// CHECK: [[TRYSUCONT1]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK-O0-NEXT: br label %[[TRYCONT1]]
// CHECK-O1-NEXT: br label %[[TRYCONT1:.+]]

// CHECK: [[EHCLEANUP2]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TFTRY2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B2CLEANUPLPAD]]

// CHECK-O1: [[CATCHDISPATCH1]]:
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK-O1: br i1 %{{.+}}, label %[[CATCH1:.+]], label %[[EHCLEANUP1:.+]]

// CHECK-O1: [[CATCH1]]:
// CHECK-O1: call void @_Z9catchfn_iii(i32 1,
// CHECK-O1: br label %[[TRYCONT1:.+]]

// CHECK-O1: [[TRYCONT1]]:
// CHECK-O1-NEXT: call void @llvm.taskframe.end(token %[[TFTRY1]])
// CHECK-O1-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK-O1: [[SYNCCONT]]:
// CHECK-O1-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-O1-NEXT: to label %[[SUCONT:.+]] unwind label %[[B1CLEANUPLPAD]]

// CHECK: [[EHCLEANUP1]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TFTRY1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B1CLEANUPLPAD]]

// CHECK-O0: [[SYNCCONT2]]:
// CHECK-O0-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-O0-NEXT: to label %[[SUCONT:.+]] unwind label %[[B1CLEANUPLPAD]]

// CHECK: [[SUCONT]]:
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-NEXT: ret i32 0

// CHECK-O0: [[EHRESUME]]:
// CHECK-O0: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int mix_parfor_trycatch(int a) {
  _Cilk_spawn foo(1);
  try {
    _Cilk_spawn foo(2);
    _Cilk_for (int i = 0; i < a; ++i)
      foo(3);
    nothrowfn(4);
  } catch (int e) {
    catchfn_i(1, e);
  }
  _Cilk_spawn foo(5);
  nothrowfn(6);
  return 0;
}

/// Test that implicit syncs are properly inserted at the end of try blocks when
/// there are mixtures of spawns and parallel for loops.

// CHECK-LABEL: define {{.*}}i32 @_Z19mix_parfor_trycatchi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-NEXT: call void @_Z3fooi(i32 1)
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK: %[[TFTRY:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TRYSYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[PFORSYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK-O0: detach within %[[PFORSYNCREG]], label %[[PFORBODY:.+]], label %[[PFORINC:.+]] unwind label %[[CATCHLPAD:.+]]

// CHECK-O1: [[LPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND2]]

// CHECK-O1: [[DETUNWIND2]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD:.+]]

// CHECK-O1: [[CATCHLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O1: br label %[[CATCHDISPATCH:.+]]

// CHECK-O1: detach within %[[PFORSYNCREG]], label %[[PFORBODY:.+]], label %[[PFORINC:.+]] unwind label %[[PFORUNW:.+]]

// CHECK: [[PFORBODY]]:
// CHECK: invoke void @_Z3fooi(i32 3)
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[PFORLPAD:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK: reattach within %[[PFORSYNCREG]], label %[[PFORINC]]

// CHECK: [[PFORINC]]:
// CHECK-O0: br i1 {{.+}}, label %{{.+}}, label %[[PFORSYNC:.+]], !llvm.loop
// CHECK-O1: br i1 {{.+}}, label %[[PFORSYNC:.+]], label %{{.+}}, !llvm.loop

// CHECK: [[PFORSYNC]]:
// CHECK: sync within %[[PFORSYNCREG]], label %[[PFORSYNCCONT:.+]]

// CHECK-O0: [[LPAD]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND2]]

// CHECK-O0: [[DETUNWIND2]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD]]

// CHECK-O0: [[CATCHLPAD]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: br label %[[CATCHDISPATCH:.+]]

// CHECK-O1: [[PFORLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[PFORSYNCREG]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind label %[[PFORUNW:.+]]

// CHECK-O1: [[PFORUNW]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O1-NEXT: br label %[[CATCHDISPATCH]]

// CHECK-O1: [[PFORSYNCCONT]]:
// CHECK-O1-NEXT: invoke void @llvm.sync.unwind(token %[[PFORSYNCREG]])
// CHECK-O1-NEXT: to label %[[PFORSUCONT:.+]] unwind label %[[PFORUNW]]

// CHECK: [[CATCHDISPATCH]]:
// CHECK: br i1 {{.+}}, label %[[CATCH:.+]], label %[[RESUME:.+]]

// CHECK: [[CATCH]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT:.+]]

// CHECK: [[TRYCONT]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY]])
// CHECK: %[[TASKFRAME3:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]]

// CHECK: [[DETACHED3]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
// CHECK-NEXT: call void @_Z3fooi(i32 5)
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]

// CHECK: [[CONTINUE3]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 6)
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK: ret i32 0

// CHECK-O0: [[PFORLPAD]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[PFORSYNCREG]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD]]

// CHECK-O0: [[PFORSYNCCONT]]:
// CHECK-O0-NEXT: invoke void @llvm.sync.unwind(token %[[PFORSYNCREG]])
// CHECK-O0-NEXT: to label %[[PFORSUCONT:.+]] unwind label %[[CATCHLPAD]]

// CHECK: [[PFORSUCONT]]:
// CHECK-O0-NEXT: br label %[[PFOREND:.+]]
// CHECK-O0: [[PFOREND]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 4)
// CHECK-NEXT: sync within %[[TRYSYNCREG]], label %[[TRYSYNCCONT:.+]]

// CHECK: [[TRYSYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG]])
// CHECK-O0-NEXT: to label %[[TRYSUCONT:.+]] unwind label %[[CATCHLPAD]]
// CHECK-O0: [[TRYSUCONT]]:
// CHECK-O0: br label %[[TRYCONT]]
// CHECK-O1-NEXT: to label %[[TRYCONT]] unwind label %[[CATCHLPAD]]

// CHECK: [[RESUME]]:
// CHECK: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int mix_parfor_trycatch_destructors(int a) {
  Bar b1;
  _Cilk_spawn foo(1);
  try {
    Bar b2;
    _Cilk_spawn foo(2);
    _Cilk_for (int i = 0; i < a; ++i)
      foo(3);
    nothrowfn(4);
  } catch (int e) {
    catchfn_i(1, e);
  }
  Bar b3;
  _Cilk_spawn foo(5);
  nothrowfn(6);
  return 0;
}

/// Test that implicit syncs are properly inserted at the end of try blocks, but
/// before destructors, when there are mixtures of spawns and parallel for
/// loops.

// CHECK-LABEL: define {{.*}}i32 @_Z31mix_parfor_trycatch_destructorsi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B1SIZE:.+]], i8* nonnull %[[B1ADDR:.+]])
// CHECK: call void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B1:.+]])
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]] unwind label %[[DETUNWIND1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 1)
// CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKECONT]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK: %[[TFTRY:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TRYSYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[PFORSYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B2SIZE:.+]], i8* nonnull %[[B2ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B2:.+]])
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[B2CONSTRLPAD:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[INVOKECONT3]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK-O0: detach within %[[PFORSYNCREG]], label %[[PFORBODY:.+]], label %[[PFORINC:.+]] unwind label %[[CATCHLPAD:.+]]

// CHECK-O1: [[LPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND1]]

// CHECK-O1: [[DETUNWIND1]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME1]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind label %[[B1CLEANUPLPAD:.+]]

// CHECK-O1: [[B1CLEANUPLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: br label %[[B1CLEANUP:.+]]

// CHECK-O1: [[B2CONSTRLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O1: br label %[[CATCHDISPATCH:.+]]

// CHECK-O1: [[LPAD2]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND2]]

// CHECK-O1: [[DETUNWIND2]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD:.+]]

// CHECK-O1: [[CATCHLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O1: br label %[[B2CLEANUP:.+]]

// CHECK-O1: detach within %[[PFORSYNCREG]], label %[[PFORBODY:.+]], label %[[PFORINC:.+]] unwind label %[[PFORUNW:.+]]

// CHECK: [[PFORBODY]]:
// CHECK: invoke void @_Z3fooi(i32 3)
// CHECK-NEXT: to label %[[INVOKECONT4:.+]] unwind label %[[PFORLPAD:.+]]

// CHECK: [[INVOKECONT4]]:
// CHECK: reattach within %[[PFORSYNCREG]], label %[[PFORINC]]

// CHECK: [[PFORINC]]:
// CHECK-O0: br i1 {{.+}}, label %{{.+}}, label %[[PFORSYNC:.+]], !llvm.loop
// CHECK-O1: br i1 {{.+}}, label %[[PFORSYNC:.+]], label %{{.+}}, !llvm.loop

// CHECK: [[PFORSYNC]]:
// CHECK: sync within %[[PFORSYNCREG]], label %[[PFORSYNCCONT:.+]]

// CHECK-O1: [[PFORLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[PFORSYNCREG]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind label %[[PFORUNW:.+]]

// CHECK-O1: [[PFORUNW]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O1-NEXT: br label %[[PFORLPADJOIN:.+]]

// CHECK-O1: [[PFORLPADJOIN]]:
// CHECK-O1: br label %[[B2CLEANUP]]

// CHECK-O1: [[PFORSYNCCONT]]:
// CHECK-O1: call void @_Z9nothrowfni(i32 4)
// CHECK-O1-NEXT: sync within %[[TRYSYNCREG]], label %[[TRYSYNCCONT:.+]]

// CHECK-O1: [[TRYSYNCCONT]]:
// CHECK-O1: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK-O1-NEXT: br label %[[TRYCONT:.+]]

// CHECK-O0: [[LPAD]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND1]]

// CHECK-O0: [[DETUNWIND1]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME1]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[B1CLEANUPLPAD:.+]]

// CHECK-O0: [[B1CLEANUPLPAD]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: br label %[[B1CLEANUP:.+]]

// CHECK-O0: [[B2CONSTRLPAD]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: br label %[[CATCHDISPATCH:.+]]

// CHECK-O0: [[LPAD2]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND2]]

// CHECK-O0: [[DETUNWIND2]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD:.+]]

// CHECK-O0: [[CATCHLPAD]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK-O0: br label %[[CATCHDISPATCH:.+]]

// CHECK-O1: [[B2CLEANUP]]:
// CHECK-O1: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK-O1-NEXT: br label %[[CATCHDISPATCH]]

// CHECK: [[CATCHDISPATCH]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK: br i1 {{.+}}, label %[[CATCH:.+]], label %[[RESUME:.+]]

// CHECK: [[CATCH]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT]]

// CHECK: [[TRYCONT]]:
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B3SIZE:.+]], i8* nonnull %[[B3ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B3:.+]])
// CHECK-O0-NEXT: to label %[[INVOKECONT5:.+]] unwind label %[[B1CLEANUPLPAD]]
// CHECK-O1-NEXT: to label %[[INVOKECONT5:.+]] unwind label %[[B3LIFETIMEENDLPAD:.+]]

// CHECK: [[INVOKECONT5]]:
// CHECK: %[[TASKFRAME3:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]] unwind label %[[DETUNWIND3:.+]]

// CHECK: [[DETACHED3]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 5)
// CHECK-NEXT: to label %[[INVOKECONT6:.+]] unwind label %[[LPAD3:.+]]

// CHECK: [[INVOKECONT6]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]

// CHECK: [[CONTINUE3]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 6)
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]
// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[SUCONT:.+]] unwind label %[[B3CLEANUPLPAD:.+]]
// CHECK-O0: [[SUCONT]]:
// CHECK-O0-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK-O0: [[PFORLPAD]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[PFORSYNCREG]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD]]

// CHECK-O0: [[PFORSYNCCONT]]:
// CHECK-O0: call void @_Z9nothrowfni(i32 4)
// CHECK-O0-NEXT: sync within %[[TRYSYNCREG]], label %[[TRYSYNCCONT:.+]]

// CHECK-O0: [[TRYSYNCCONT]]:
// CHECK-O0: call void @_ZN3BarD1Ev(%class.Bar* %[[B2]])
// CHECK-O0-NEXT: br label %[[TRYCONT]]

// CHECK-O1: [[B3LIFETIMEENDLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: br label %[[B3LIFETIMEEND:.+]]

// CHECK: [[LPAD3]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND3]]

// CHECK: [[DETUNWIND3]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B3CLEANUPLPAD]]

// CHECK: [[B3CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B3]])
// CHECK-O0: br label %[[B1CLEANUP]]
// CHECK-O1: br label %[[B3LIFETIMEEND]]

// CHECK-O0: [[SYNCCONT]]:
// CHECK-O1: [[SUCONT]]:
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B3]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B3SIZE]], i8* nonnull %[[B3ADDR]])
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK: ret i32 0

// CHECK-O1: [[B3LIFETIMEEND]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B3SIZE]], i8* nonnull %[[B3ADDR]])
// CHECK-O1: br label %[[B1CLEANUP]]

// CHECK: [[B1CLEANUP]]:
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-O0: br label %[[RESUME:.+]]

// CHECK-O0: [[RESUME]]:
// CHECK: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int spawn_trycatch(int a) {
  _Cilk_spawn try {
    _Cilk_spawn foo(1);
    nothrowfn(2);
  } catch (int e) {
    catchfn_i(1, e);
  }
  _Cilk_spawn {
    try {
      _Cilk_spawn foo(3);
      nothrowfn(4);
    } catch (int e) {
      catchfn_i(2, e);
    }
  };
  _Cilk_spawn foo(5);
  nothrowfn(6);
  return 0;
}

/// Test that implicit syncs are properly inserted for spawned statements.

// CHECK-LABEL: define {{.*}}i32 @_Z14spawn_trycatchi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK-O0: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]] unwind label %[[DETUNWIND1:.+]]
// CHECK-O1: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK-DAG: %[[TRYSYNCREG1:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-DAG: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-DAG: %[[TFTRY1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG1]], label %[[TRYDETACHED1:.+]], label %[[TRYDETCONT1:.+]] unwind label %[[TRYDETUNWIND1:.+]]

// CHECK: [[TRYDETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 1)
// CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[LPAD1:.+]]

// CHECK: [[INVOKECONT1]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG1]], label %[[TRYDETCONT1]]

// CHECK: [[TRYDETCONT1]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 2)
// CHECK-NEXT: sync within %[[TRYSYNCREG1]], label %[[TRYSYNCCONT1:.+]]

// CHECK: [[TRYSYNCCONT1]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG1]])
// CHECK-O0-NEXT: to label %[[TRYSUCONT1:.+]] unwind label %[[CATCHLPAD:.+]]
// CHECK-O0: [[TRYSUCONT1]]:
// CHECK-O0-NEXT: br label %[[TRYCONT1:.+]]
// CHECK-O1-NEXT: to label %[[TRYCONT1:.+]] unwind label %[[CATCHLPAD:.+]]

// CHECK: [[LPAD1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG1]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[TRYDETUNWIND1]]

// CHECK: [[TRYDETUNWIND1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD]]

// CHECK: [[CATCHLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: br label %[[CATCHDISPATCH1:.+]]

// CHECK-O0: [[CATCHDISPATCH1]]:
// CHECK-O0: br i1 {{.+}}, label %[[CATCH1:.+]], label %[[TASKCLEANUP1:.+]]

// CHECK-O0: [[CATCH1]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT1]]

// CHECK: [[TRYCONT1]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY1]])
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK: %[[TASKFRAME3:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK-O0: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND2:.+]]
// CHECK-O1: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK-DAG: %[[TRYSYNCREG2:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-DAG: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
// CHECK-DAG: %[[TFTRY2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: %[[TASKFRAME4:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG2]], label %[[TRYDETACHED2:.+]], label %[[TRYDETCONT2:.+]] unwind label %[[TRYDETUNWIND2:.+]]

// CHECK: [[TRYDETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME4]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 3)
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG2]], label %[[TRYDETCONT2]]

// CHECK: [[TRYDETCONT2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 4)
// CHECK-NEXT: sync within %[[TRYSYNCREG2]], label %[[TRYSYNCCONT2:.+]]

// CHECK: [[TRYSYNCCONT2]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG2]])
// CHECK-O0-NEXT: to label %[[TRYSUCONT2:.+]] unwind label %[[CATCHLPAD2:.+]]

// CHECK-O0: [[TRYSUCONT2]]:
// CHECK-O0-NEXT: br label %[[TRYCONT2:.+]]
// CHECK-O1-NEXT: to label %[[TRYCONT2:.+]] unwind label %[[CATCHLPAD2:.+]]

// CHECK-O0: [[TASKCLEANUP1]]:
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND1]]

// CHECK-O0: [[DETUNWIND1]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME1]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFUNWIND1:.+]]

// CHECK-O0: [[TFUNWIND1]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: br label %[[RESUME:.+]]

// CHECK: [[LPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG2]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[TRYDETUNWIND2]]

// CHECK: [[TRYDETUNWIND2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME4]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD2]]

// CHECK: [[CATCHLPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: br label %[[CATCHDISPATCH2:.+]]

// CHECK-O0: [[CATCHDISPATCH2]]:
// CHECK-O0: br i1 {{.+}}, label %[[CATCH2:.+]], label %[[TASKCLEANUP2:.+]]

// CHECK-O0: [[CATCH2]]:
// CHECK: call void @_Z9catchfn_iii(i32 2,
// CHECK: br label %[[TRYCONT2]]

// CHECK: [[TRYCONT2]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY2]])
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]

// CHECK: %[[TASKFRAME5:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME5]])
// CHECK-NEXT: call void @_Z3fooi(i32 5)
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 6)
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT2:.+]]

// CHECK: [[SYNCCONT2]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK: ret i32 0

// CHECK-O0: [[TASKCLEANUP2]]:
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND2]]

// CHECK-O0: [[DETUNWIND2]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFUNWIND3:.+]]

// CHECK-O0: [[TFUNWIND3]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: br label %[[RESUME]]

// CHECK-O0: [[RESUME]]:
// CHECK-O0: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int spawn_trycatch_destructors(int a) {
  Bar b1;
  _Cilk_spawn foo(1);
  _Cilk_spawn try {
    Bar b2;
    _Cilk_spawn foo(2);
    nothrowfn(3);
  } catch (int e) {
    catchfn_i(1, e);
  }
  _Cilk_spawn {
    try {
      Bar b3;
      _Cilk_spawn foo(4);
      nothrowfn(5);
    } catch (int e) {
      catchfn_i(2, e);
    }
  };
  Bar b4;
  _Cilk_spawn foo(6);
  nothrowfn(7);
  return 0;
}

/// Test that implicit syncs are properly inserted before destructors for
/// spawned statements.

// CHECK-LABEL: define {{.*}}i32 @_Z26spawn_trycatch_destructorsi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B1SIZE:.+]], i8* nonnull %[[B1ADDR:.+]])
// CHECK: call void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B1:.+]])
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]] unwind label %[[DETUNWIND1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 1)
// CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[LPAD1:.+]]

// CHECK: [[INVOKECONT1]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK-DAG: %[[TRYSYNCREG1:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-DAG: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-DAG: %[[TFTRY1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B2SIZE:.+]], i8* nonnull %[[B2ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B2:.+]])
// CHECK-NEXT: to label %[[B2CONSTRCONT:.+]] unwind label %[[B2CONSTRLPAD:.+]]

// CHECK: [[B2CONSTRCONT]]:
// CHECK: %[[TASKFRAME3:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG1]], label %[[TRYDETACHED1:.+]], label %[[TRYDETCONT1:.+]] unwind label %[[TRYDETUNWIND1:.+]]

// CHECK: [[TRYDETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG1]], label %[[TRYDETCONT1]]

// CHECK: [[TRYDETCONT1]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 3)
// CHECK-NEXT: sync within %[[TRYSYNCREG1]], label %[[TRYSYNCCONT1:.+]]

// CHECK: [[TRYSYNCCONT1]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG1]])
// CHECK-NEXT: to label %[[TRYSUCONT1:.+]] unwind label %[[B2CLEANUPLPAD:.+]]
// CHECK: [[TRYSUCONT1]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK-NEXT: br label %[[TRYCONT1:.+]]

// CHECK: [[LPAD1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND1]]

// CHECK: [[DETUNWIND1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFUNWIND1:.+]]

// CHECK: [[TFUNWIND1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: br label %[[EHCLEANUP:.+]]

// CHECK: [[B2CONSTRLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br label %[[CATCHDISPATCH1:.+]]

// CHECK: [[LPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TRYDETUNWIND1]]

// CHECK: [[TRYDETUNWIND1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B2CLEANUPLPAD]]

// CHECK: [[B2CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK: br label %[[CATCHDISPATCH1]]

// CHECK: [[CATCHDISPATCH1]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK: br i1 {{.+}}, label %[[CATCH1:.+]], label %[[TASKCLEANUP1:.+]]

// CHECK: [[CATCH1]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT1]]

// CHECK: [[TRYCONT1]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY1]])
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK: %[[TASKFRAME4:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]] unwind label %[[DETUNWIND3:.+]]

// CHECK: [[DETACHED3]]:
// CHECK-DAG: %[[TRYSYNCREG2:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-DAG: call void @llvm.taskframe.use(token %[[TASKFRAME4]])
// CHECK-DAG: %[[TFTRY2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B3SIZE:.+]], i8* nonnull %[[B3ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B3:.+]])
// CHECK-NEXT: to label %[[B3CONSTRCONT:.+]] unwind label %[[B3CONSTRLPAD:.+]]

// CHECK: [[B3CONSTRCONT]]:
// CHECK: %[[TASKFRAME5:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG2]], label %[[TRYDETACHED2:.+]], label %[[TRYDETCONT2:.+]] unwind label %[[TRYDETUNWIND2:.+]]

// CHECK: [[TRYDETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME5]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 4)
// CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[LPAD3:.+]]

// CHECK: [[INVOKECONT3]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG2]], label %[[TRYDETCONT2]]

// CHECK: [[TRYDETCONT2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 5)
// CHECK-NEXT: sync within %[[TRYSYNCREG2]], label %[[TRYSYNCCONT2:.+]]

// CHECK: [[TRYSYNCCONT2]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG2]])
// CHECK-NEXT: to label %[[TRYSUCONT2:.+]] unwind label %[[B3CLEANUPLPAD:.+]]
// CHECK: [[TRYSUCONT2]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B3]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B3SIZE]], i8* nonnull %[[B3ADDR]])
// CHECK-NEXT: br label %[[TRYCONT2:.+]]

// CHECK: [[TASKCLEANUP1]]:
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND2]]

// CHECK: [[DETUNWIND2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFUNWIND1]]

// CHECK: [[B3CONSTRLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br label %[[CATCHDISPATCH2:.+]]

// CHECK: [[LPAD3]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TRYDETUNWIND2]]

// CHECK: [[TRYDETUNWIND2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME5]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B3CLEANUPLPAD]]

// CHECK: [[B3CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B3]])
// CHECK: br label %[[CATCHDISPATCH2]]

// CHECK: [[CATCHDISPATCH2]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B3SIZE]], i8* nonnull %[[B3ADDR]])
// CHECK: br i1 {{.+}}, label %[[CATCH2:.+]], label %[[TASKCLEANUP2:.+]]

// CHECK: [[CATCH2]]:
// CHECK: call void @_Z9catchfn_iii(i32 2,
// CHECK: br label %[[TRYCONT2]]

// CHECK: [[TRYCONT2]]:
// CHECK-NEXT: call void @llvm.taskframe.end(token %[[TFTRY2]])
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]

// CHECK: [[CONTINUE3]]:
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B4SIZE:.+]], i8* nonnull %[[B4ADDR:.+]])
// CHECK-NEXT: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B4:.+]])
// CHECK-NEXT: to label %[[B4CONSTRCONT:.+]] unwind label %[[B4CONSTRLPAD:.+]]

// CHECK: [[B4CONSTRCONT]]:
// CHECK: %[[TASKFRAME6:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED4:.+]], label %[[CONTINUE4:.+]] unwind label %[[DETUNWIND4:.+]]

// CHECK: [[DETACHED4]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME6]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 6)
// CHECK-NEXT: to label %[[INVOKECONT4:.+]] unwind label %[[LPAD4:.+]]

// CHECK: [[INVOKECONT4]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE4]]

// CHECK: [[CONTINUE4]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 7)
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]
// CHECK: [[SYNCCONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[SUCONT:.+]] unwind label %[[B4CLEANUPLPAD:.+]]
// CHECK-O0: [[SUCONT]]:
// CHECK-O0-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT:.+]]

// CHECK: [[TASKCLEANUP2]]:
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND3]]

// CHECK: [[DETUNWIND3]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME4]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFUNWIND1]]

// CHECK: [[LPAD4]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND4]]

// CHECK: [[DETUNWIND4]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME6]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B4CLEANUPLPAD]]

// CHECK: [[B4CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B4]])
// CHECK-O0: br label %[[EHCLEANUP]]
// CHECK-O1: br label %[[EHCLEANUP2:.+]]

// CHECK-O0: [[SYNCCONT]]:
// CHECK-O0-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-O0-NEXT: to label %[[SUCONT:.+]] unwind label %[[B4CLEANUPLPAD]]
// CHECK: [[SUCONT]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B4]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B4SIZE]], i8* nonnull %[[B4ADDR]])
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-NEXT: ret i32 0

// CHECK-O1: [[EHCLEANUP2]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B4SIZE]], i8* nonnull %[[B4ADDR]])
// CHECK-O1: br label %[[EHCLEANUP]]

// CHECK: [[EHCLEANUP]]:
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-O0: br label %[[RESUME:.+]]

// CHECK-O0: [[RESUME]]:
// CHECK: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int parfor_trycatch(int a) {
  _Cilk_spawn foo(1);
  _Cilk_for(int i = 0; i < a; ++i)
    try {
      _Cilk_spawn foo(2);
      nothrowfn(3);
    } catch (int e) {
      catchfn_i(1, e);
    }
  _Cilk_for(int i = 0; i < a; ++i) {
    try {
      _Cilk_spawn foo(4);
      nothrowfn(5);
    } catch (int e) {
      catchfn_i(2, e);
    }
  }
  _Cilk_spawn foo(6);
  nothrowfn(7);
  return 0;
}

/// Test that implicit syncs are properly inserted for parallel-for statements.

// CHECK-LABEL: define {{.*}}i32 @_Z15parfor_trycatchi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[PFORSYNCREG1:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[PFORSYNCREG2:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-NEXT: call void @_Z3fooi(i32 1)
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:
// CHECK-O0: detach within %[[PFORSYNCREG1]], label %[[PFORBODY1:.+]], label %[[PFORINC1:.+]] unwind label %[[PFORDU1:.+]]
// CHECK-O1: detach within %[[PFORSYNCREG1]], label %[[PFORBODY1:.+]], label %[[PFORINC1:.+]]

// CHECK: [[PFORBODY1]]:
// CHECK: %[[TRYSYNCREG1:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG1]], label %[[TRYDET1:.+]], label %[[TRYDETCONT1:.+]] unwind label %[[TRYDU1:.+]]

// CHECK: [[TRYDET1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[LPAD1:.+]]

// CHECK: [[INVOKECONT1]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG1]], label %[[TRYDETCONT1]]

// CHECK: [[TRYDETCONT1]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 3)
// CHECK-NEXT: sync within %[[TRYSYNCREG1]], label %[[TRYSYNCCONT1:.+]]

// CHECK: [[TRYSYNCCONT1]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG1]])
// CHECK-O0-NEXT: to label %[[TRYSUCONT1:.+]] unwind label %[[CATCHLPAD:.+]]
// CHECK-O0: [[TRYSUCONT1]]:
// CHECK-O0-NEXT: br label %[[TRYCONT1:.+]]
// CHECK-O1-NEXT: to label %[[TRYCONT1:.+]] unwind label %[[CATCHLPAD:.+]]

// CHECK: [[LPAD1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG1]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[TRYDU1]]

// CHECK: [[TRYDU1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD]]

// CHECK: [[CATCHLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: br label %[[CATCHDISPATCH1:.+]]

// CHECK-O0: [[CATCHDISPATCH1]]:
// CHECK-O0: br i1 {{.+}}, label %[[CATCH1:.+]], label %[[TASKCLEANUP1:.+]]

// CHECK-O0: [[CATCH1]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT1]]

// CHECK: [[TRYCONT1]]:
// CHECK: reattach within %[[PFORSYNCREG1]], label %[[PFORINC1]]

// CHECK: [[PFORINC1]]:
// CHECK-O0: br i1 {{.+}}, label {{.+}}, label %[[PFORSYNC1:.+]], !llvm.loop
// CHECK-O1: br i1 {{.+}}, label %[[PFORSYNC1:.+]], label {{.+}}, !llvm.loop

// CHECK: [[PFORSYNC1]]:
// CHECK-O0: sync within %[[PFORSYNCREG1]], label %[[PFORSYNCCONT1:.+]]
// CHECK-O1: sync within %[[PFORSYNCREG1]], label %[[PFOREND1:.+]]

// CHECK-O0: [[TASKCLEANUP1]]:
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[PFORSYNCREG1]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[PFORDU1]]

// CHECK-O0: [[PFORDU1]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: br label %[[EHRESUME:.+]]

// CHECK-O0: [[PFORSYNCCONT1]]:
// CHECK-O0-NEXT: call void @llvm.sync.unwind(token %[[PFORSYNCREG1]])
// CHECK-O0-NEXT: br label %[[PFOREND1:.+]]

// CHECK: [[PFOREND1]]:
// CHECK-O0: detach within %[[PFORSYNCREG2]], label %[[PFORBODY2:.+]], label %[[PFORINC2:.+]] unwind label %[[PFORDU2:.+]]
// CHECK-O1: detach within %[[PFORSYNCREG2]], label %[[PFORBODY2:.+]], label %[[PFORINC2:.+]]

// CHECK: [[PFORBODY2]]:
// CHECK: %[[TRYSYNCREG2:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[TASKFRAME3:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG2]], label %[[TRYDET2:.+]], label %[[TRYDETCONT2:.+]] unwind label %[[TRYDU2:.+]]

// CHECK: [[TRYDET2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 4)
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG2]], label %[[TRYDETCONT2]]

// CHECK: [[TRYDETCONT2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 5)
// CHECK-NEXT: sync within %[[TRYSYNCREG2]], label %[[TRYSYNCCONT2:.+]]

// CHECK: [[TRYSYNCCONT2]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG2]])
// CHECK-O0-NEXT: to label %[[TRYSUCONT2:.+]] unwind label %[[CATCHLPAD2:.+]]
// CHECK-O0: [[TRYSUCONT2]]:
// CHECK-O0-NEXT: br label %[[TRYCONT2:.+]]
// CHECK-O1-NEXT: to label %[[TRYCONT2:.+]] unwind label %[[CATCHLPAD2:.+]]

// CHECK: [[LPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TRYDU2]]

// CHECK: [[TRYDU2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[CATCHLPAD2]]

// CHECK: [[CATCHLPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK-O0: br label %[[CATCHDISPATCH2:.+]]

// CHECK-O0: [[CATCHDISPATCH2]]:
// CHECK-O0: br i1 {{.+}}, label %[[CATCH2:.+]], label %[[TASKCLEANUP2:.+]]

// CHECK-O0: [[CATCH2]]:
// CHECK: call void @_Z9catchfn_iii(i32 2,
// CHECK: br label %[[TRYCONT2]]

// CHECK: [[TRYCONT2]]:
// CHECK: reattach within %[[PFORSYNCREG2]], label %[[PFORINC2]]

// CHECK: [[PFORINC2]]:
// CHECK-O0: br i1 {{.+}}, label {{.+}}, label %[[PFORSYNC2:.+]], !llvm.loop
// CHECK-O1: br i1 {{.+}}, label %[[PFORSYNC2:.+]], label {{.+}}, !llvm.loop

// CHECK: [[PFORSYNC2]]:
// CHECK-O0: sync within %[[PFORSYNCREG2]], label %[[PFORSYNCCONT2:.+]]
// CHECK-O1: sync within %[[PFORSYNCREG2]], label %[[PFOREND2:.+]]

// CHECK-O0: [[TASKCLEANUP2]]:
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[PFORSYNCREG2]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[PFORDU2]]

// CHECK-O0: [[PFORDU2]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: br label %[[EHRESUME]]

// CHECK-O0: [[PFORSYNCCONT2]]:
// CHECK-O0-NEXT: call void @llvm.sync.unwind(token %[[PFORSYNCREG2]])
// CHECK-O0-NEXT: br label %[[PFOREND2:.+]]

// CHECK: [[PFOREND2]]:
// CHECK: %[[TASKFRAME4:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME4]])
// CHECK-NEXT: call void @_Z3fooi(i32 6)
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 7)
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT2:.+]]

// CHECK: [[SYNCCONT2]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK: ret i32 0

// CHECK-O0: [[EHRESUME]]:
// CHECK-O0: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

int parfor_trycatch_destructors(int a) {
  Bar b1;
  _Cilk_spawn foo(1);
  _Cilk_for(int i = 0; i < a; ++i)
    try {
      Bar b2;
      _Cilk_spawn foo(2);
      nothrowfn(3);
    } catch (int e) {
      catchfn_i(1, e);
    }
  _Cilk_for(int i = 0; i < a; ++i) {
    try {
      Bar b3;
      _Cilk_spawn foo(4);
      nothrowfn(5);
    } catch (int e) {
      catchfn_i(2, e);
    }
  }
  Bar b4;
  _Cilk_spawn foo(6);
  nothrowfn(7);
  return 0;
}

/// Test that implicit syncs are properly inserted before destructors for
/// parallel-for statements.

// CHECK-LABEL: define {{.*}}i32 @_Z27parfor_trycatch_destructorsi(
// CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[PFORSYNCREG1:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK: %[[PFORSYNCREG2:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B1SIZE:.+]], i8* nonnull %[[B1ADDR:.+]])
// CHECK: call void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B1:.+]])
// CHECK: %[[TASKFRAME1:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE1:.+]] unwind label %[[DETUNWIND1:.+]]

// CHECK: [[DETACHED1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME1]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 1)
// CHECK-NEXT: to label %[[INVOKECONT1:.+]] unwind label %[[LPAD1:.+]]

// CHECK: [[INVOKECONT1]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE1]]

// CHECK: [[CONTINUE1]]:

// CHECK-O1: [[LPAD1]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND1]]

// CHECK-O1: [[DETUNWIND1]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME1]],
// CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind label %[[TASKCLEANUPLPAD:.+]]

// CHECK-O1: [[TASKCLEANUPLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: br label %[[TASKCLEANUP1:.+]]

// CHECK: detach within %[[PFORSYNCREG1]], label %[[PFORBODY1:.+]], label %[[PFORINC1:.+]] unwind label %[[PFORDU1:.+]]

// CHECK: [[PFORBODY1]]:
// CHECK: %[[TRYSYNCREG1:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B2SIZE:.+]], i8* nonnull %[[B2ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B2:.+]])
// CHECK-NEXT: to label %[[B2CONSTRCONT:.+]] unwind label %[[B2CONSTRLPAD:.+]]

// CHECK: [[B2CONSTRCONT]]:
// CHECK: %[[TASKFRAME2:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG1]], label %[[TRYDET1:.+]], label %[[TRYDETCONT1:.+]] unwind label %[[TRYDU1:.+]]

// CHECK: [[TRYDET1]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 2)
// CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[INVOKECONT2]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG1]], label %[[TRYDETCONT1]]

// CHECK: [[TRYDETCONT1]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 3)
// CHECK-NEXT: sync within %[[TRYSYNCREG1]], label %[[TRYSYNCCONT1:.+]]

// CHECK: [[TRYSYNCCONT1]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG1]])
// CHECK-NEXT: to label %[[SUCONT:.+]] unwind label %[[B2CLEANUPLPAD:.+]]
// CHECK: [[SUCONT]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK-NEXT: br label %[[TRYCONT1:.+]]

// CHECK-O0: [[LPAD1]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETUNWIND1]]

// CHECK-O0: [[DETUNWIND1]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME1]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[PFORDU1]]

// CHECK-O0: [[PFORDU1]]:
// CHECK-O0-NEXT: landingpad
// CHECK-O0-NEXT: cleanup
// CHECK-O0: br label %[[TASKCLEANUP1:.+]]

// CHECK: [[B2CONSTRLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br label %[[CATCHDISPATCH1:.+]]

// CHECK: [[LPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TRYDU1]]

// CHECK: [[TRYDU1]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B2CLEANUPLPAD]]

// CHECK: [[B2CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B2]])
// CHECK: br label %[[CATCHDISPATCH1:.+]]

// CHECK: [[CATCHDISPATCH1]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B2SIZE]], i8* nonnull %[[B2ADDR]])
// CHECK: br i1 {{.+}}, label %[[CATCH1:.+]], label %[[PFORCLEANUP1:.+]]

// CHECK: [[CATCH1]]:
// CHECK: call void @_Z9catchfn_iii(i32 1,
// CHECK: br label %[[TRYCONT1]]

// CHECK: [[TRYCONT1]]:
// CHECK: reattach within %[[PFORSYNCREG1]], label %[[PFORINC1]]

// CHECK: [[PFORINC1]]:
// CHECK-O0: br i1 {{.+}}, label {{.+}}, label %[[PFORSYNC1:.+]], !llvm.loop
// CHECK-O1: br i1 {{.+}}, label %[[PFORSYNC1:.+]], label {{.+}}, !llvm.loop

// CHECK: [[PFORSYNC1]]:
// CHECK-O0: sync within %[[PFORSYNCREG1]], label %[[PFORSYNCCONT1:.+]]
// CHECK-O1: sync within %[[PFORSYNCREG1]], label %[[PFOREND1:.+]]

// CHECK: [[PFORCLEANUP1]]:
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[PFORSYNCREG1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[PFORDU1]]

// CHECK-O1: [[PFORDU1]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1-NEXT: br label %[[PFORLPAD1:.+]]

// CHECK-O1: [[PFORLPAD1]]:
// CHECK-O1: br label %[[TASKCLEANUP1]]

// CHECK-O0: [[PFORSYNCCONT1]]:
// CHECK-O0-NEXT: invoke void @llvm.sync.unwind(token %[[PFORSYNCREG1]])
// CHECK-O0-NEXT: to label %[[PFORSUCONT1:.+]] unwind label %[[PFORDU1]]
// CHECK-O0: [[PFORSUCONT1]]:
// CHECK-O0-NEXT: br label %[[PFOREND1:.+]]

// CHECK: [[PFOREND1]]:
// CHECK-O0: detach within %[[PFORSYNCREG2]], label %[[PFORBODY2:.+]], label %[[PFORINC2:.+]] unwind label %[[PFORDU1]]
// CHECK-O1: detach within %[[PFORSYNCREG2]], label %[[PFORBODY2:.+]], label %[[PFORINC2:.+]] unwind label %[[PFORDU2:.+]]

// CHECK: [[PFORBODY2]]:
// CHECK: %[[TRYSYNCREG2:.+]] = {{.*}}call token @llvm.syncregion.start()
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B3SIZE:.+]], i8* nonnull %[[B3ADDR:.+]])
// CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B3:.+]])
// CHECK-NEXT: to label %[[B3CONSTRCONT:.+]] unwind label %[[B3CONSTRLPAD:.+]]

// CHECK: [[B3CONSTRCONT]]:
// CHECK: %[[TASKFRAME3:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[TRYSYNCREG2]], label %[[TRYDET2:.+]], label %[[TRYDETCONT2:.+]] unwind label %[[TRYDU2:.+]]

// CHECK: [[TRYDET2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 4)
// CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[LPAD3:.+]]

// CHECK: [[INVOKECONT3]]:
// CHECK-NEXT: reattach within %[[TRYSYNCREG2]], label %[[TRYDETCONT2]]

// CHECK: [[TRYDETCONT2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 5)
// CHECK-NEXT: sync within %[[TRYSYNCREG2]], label %[[TRYSYNCCONT2:.+]]

// CHECK: [[TRYSYNCCONT2]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[TRYSYNCREG2]])
// CHECK-NEXT: to label %[[TRYSUCONT2:.+]] unwind label %[[B3CLEANUPLPAD:.+]]
// CHECK: [[TRYSUCONT2]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B3]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B3SIZE]], i8* nonnull %[[B3ADDR]])
// CHECK-NEXT: br label %[[TRYCONT2:.+]]

// CHECK: [[B3CONSTRLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: br label %[[CATCHDISPATCH2:.+]]

// CHECK: [[LPAD3]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[TRYSYNCREG2]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TRYDU2]]

// CHECK: [[TRYDU2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B3CLEANUPLPAD]]

// CHECK: [[B3CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B3]])
// CHECK: br label %[[CATCHDISPATCH2:.+]]

// CHECK: [[CATCHDISPATCH2]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B3SIZE]], i8* nonnull %[[B3ADDR]])
// CHECK: br i1 {{.+}}, label %[[CATCH2:.+]], label %[[PFORCLEANUP2:.+]]

// CHECK: [[CATCH2]]:
// CHECK: call void @_Z9catchfn_iii(i32 2,
// CHECK: br label %[[TRYCONT2]]

// CHECK: [[TRYCONT2]]:
// CHECK: reattach within %[[PFORSYNCREG2]], label %[[PFORINC2]]

// CHECK: [[PFORINC2]]:
// CHECK-O0: br i1 {{.+}}, label {{.+}}, label %[[PFORSYNC2:.+]], !llvm.loop
// CHECK-O1: br i1 {{.+}}, label %[[PFORSYNC2:.+]], label {{.+}}, !llvm.loop

// CHECK: [[PFORSYNC2]]:
// CHECK-O0: sync within %[[PFORSYNCREG2]], label %[[PFORSYNCCONT2:.+]]
// CHECK-O1: sync within %[[PFORSYNCREG2]], label %[[PFOREND2:.+]]

// CHECK: [[PFORCLEANUP2]]:
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[PFORSYNCREG2]],
// CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind label %[[PFORDU1]]
// CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind label %[[PFORDU2]]

// CHECK-O1: [[PFORDU2]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1-NEXT: br label %[[PFORLPAD2:.+]]

// CHECK-O1: [[PFORLPAD2]]:
// CHECK-O1: br label %[[TASKCLEANUP1]]

// CHECK-O0: [[PFORSYNCCONT2]]:
// CHECK-O0-NEXT: invoke void @llvm.sync.unwind(token %[[PFORSYNCREG2]])
// CHECK-O0-NEXT: to label %[[PFORSUCONT2:.+]] unwind label %[[PFORDU1]]
// CHECK-O0: [[PFORSUCONT2]]:
// CHECK-O0-NEXT: br label %[[PFOREND2:.+]]

// CHECK: [[PFOREND2]]:
// CHECK-O1: call void @llvm.lifetime.start.p0i8(i64 [[B4SIZE:.+]], i8* nonnull %[[B4ADDR:.+]])
// CHECK-NEXT: invoke void @_ZN3BarC1Ev(%class.Bar* {{.*}}%[[B4:.+]])
// CHECK-O0-NEXT: to label %[[B4CONSTRCONT:.+]] unwind label %[[PFORDU1]]
// CHECK-O1-NEXT: to label %[[B4CONSTRCONT:.+]] unwind label %[[B4CONSTRLPAD:.+]]

// CHECK: [[B4CONSTRCONT]]:
// CHECK: %[[TASKFRAME4:.+]] = {{.*}}call token @llvm.taskframe.create()
// CHECK: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[DETUNWIND2:.+]]

// CHECK: [[DETACHED2]]:
// CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME4]])
// CHECK-NEXT: invoke void @_Z3fooi(i32 6)
// CHECK-NEXT: to label %[[INVOKECONT4:.+]] unwind label %[[LPAD4:.+]]

// CHECK: [[INVOKECONT4]]:
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]

// CHECK: [[CONTINUE2]]:
// CHECK-NEXT: call void @_Z9nothrowfni(i32 7)
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT2:.+]]
// CHECK: [[SYNCCONT2]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[SUCONT2:.+]] unwind label %[[B4CLEANUPLPAD:.+]]
// CHECK-O0: [[SUCONT2]]:
// CHECK-O0-NEXT: sync within %[[SYNCREG]], label %[[SYNCCONT2:.+]]

// CHECK-O1: [[B4CONSTRLPAD]]:
// CHECK-O1-NEXT: landingpad
// CHECK-O1-NEXT: cleanup
// CHECK-O1: br label %[[TASKCLEANUP2:.+]]

// CHECK: [[LPAD4]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[DETUNWIND2]]

// CHECK: [[DETUNWIND2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME4]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[B4CLEANUPLPAD]]

// CHECK: [[B4CLEANUPLPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B4]])
// CHECK-O0: br label %[[TASKCLEANUP1]]
// CHECK-O1: br label %[[TASKCLEANUP2]]

// CHECK-O0: [[SYNCCONT2]]:
// CHECK-O0-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-O0-NEXT: to label %[[SUCONT2:.+]] unwind label %[[B4CLEANUPLPAD]]
// CHECK: [[SUCONT2]]:
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B4]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B4SIZE]], i8* nonnull %[[B4ADDR]])
// CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-NEXT: ret i32 0

// CHECK-O1: [[TASKCLEANUP2]]:
// CHECK-O1: call void @llvm.lifetime.end.p0i8(i64 [[B4SIZE]], i8* nonnull %[[B4ADDR]])
// CHECK-O1-NEXT: br label %[[TASKCLEANUP1]]

// CHECK: [[TASKCLEANUP1]]:
// CHECK: call void @_ZN3BarD1Ev(%class.Bar* {{.*}}%[[B1]])
// CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 [[B1SIZE]], i8* nonnull %[[B1ADDR]])
// CHECK-O0-NEXT: br label %[[EHRESUME]]

// CHECK-O0: [[EHRESUME]]:
// CHECK: resume

// CHECK: [[UNREACHABLE]]:
// CHECK-NEXT: unreachable

