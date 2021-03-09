// RUN: %clang_cc1 -fcxx-exceptions -fexceptions -fcilkplus -ftapir=none -triple x86_64-unknown-linux-gnu -std=c++11 -emit-llvm %s -o - | FileCheck %s --check-prefixes CHECK,CHECK-O0
// RUN: %clang_cc1 -fcxx-exceptions -fexceptions -fcilkplus -ftapir=none -triple x86_64-unknown-linux-gnu -std=c++11 -O1 -mllvm -simplify-taskframes=false -emit-llvm %s -o - | FileCheck %s --check-prefixes CHECK,CHECK-O1

class Baz {
public:
  Baz();
  ~Baz();
  Baz(const Baz &that);
  Baz(Baz &&that);
  Baz &operator=(Baz that);
  friend void swap(Baz &left, Baz &right);
};

class Bar {
  int val[4] = {0,0,0,0};
public:
  Bar();
  ~Bar();
  Bar(const Bar &that);
  Bar(Bar &&that);
  Bar &operator=(Bar that);
  friend void swap(Bar &left, Bar &right);

  Bar(const Baz &that);

  const int &getVal(int i) const { return val[i]; }
  void incVal(int i) { val[i]++; }
};

class DBar : public Bar {
public:
  DBar();
  ~DBar();
  DBar(const DBar &that);
  DBar(DBar &&that);
  DBar &operator=(DBar that);
  friend void swap(DBar &left, DBar &right);
};

int foo(const Bar &b);

Bar makeBar();
void useBar(Bar b);

DBar makeDBar();
DBar makeDBarFromBar(Bar b);

Baz makeBaz();
Baz makeBazFromBar(Bar b);

void rule_of_four() {
  // CHECK-LABEL: define void @_Z12rule_of_fourv()
  Bar b0;
  Bar b5(_Cilk_spawn makeBar());
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[TFLPAD:.+]]
  // CHECK: [[DETACHED]]:
  // CHECK: invoke void @_Z7makeBarv(%class.Bar* {{(nonnull )?}}sret {{.*}}%[[b5:.+]])
  // CHECK-NEXT: to label %[[REATTACH:.+]] unwind label %[[DETLPAD:.+]]
  // CHECK: [[REATTACH]]:
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]
  // CHECK: [[CONTINUE]]:
  Bar b4 = _Cilk_spawn makeBar();
  // CHECK: %[[TASKFRAME2:.+]] = call token @llvm.taskframe.create()
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[TFLPAD2:.+]]
  // CHECK: [[DETACHED2]]:
  // CHECK: invoke void @_Z7makeBarv(%class.Bar* {{(nonnull )?}}sret {{.*}}%[[b4:.+]])
  // CHECK-NEXT: to label %[[REATTACH2:.+]] unwind label %[[DETLPAD2:.+]]
  // CHECK: [[REATTACH2]]:
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]
  // CHECK: [[CONTINUE2]]:
  b0 = _Cilk_spawn makeBar();
  // CHECK: %[[TASKFRAME3:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[AGGTMP:.+]] = alloca %class.Bar
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]] unwind label %[[TFLPAD3:.+]]
  // CHECK: [[DETACHED3]]:
  // CHECK: invoke void @_Z7makeBarv(%class.Bar* {{(nonnull )?}}sret {{.*}}%[[AGGTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[DETLPAD3:.+]]
  // CHECK: [[INVOKECONT]]:
  // CHECK-NEXT: %[[CALL:.+]] = invoke {{.*}}dereferenceable(16) %class.Bar* @_ZN3BaraSES_(%class.Bar* {{(nonnull )?}}%[[b0:.+]], %class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[DETLPAD3_2:.+]]
  // CHECK: [[INVOKECONT2]]:
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]
  // CHECK: [[CONTINUE3]]:
  _Cilk_spawn useBar(b0);
  // CHECK: %[[TASKFRAME4:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[AGGTMP2:.+]] = alloca %class.Bar
  // CHECK: invoke void @_ZN3BarC1ERKS_(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]], %class.Bar* {{(nonnull )?}}{{.*}}dereferenceable(16) %[[b0:.+]])
  // CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[TFLPAD4:.+]]
  // CHECK: [[INVOKECONT3]]:
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED4:.+]], label %[[CONTINUE4:.+]] unwind label %[[TFLPAD4:.+]]
  // CHECK: [[DETACHED4]]:
  // CHECK: invoke void @_Z6useBar3Bar(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]])
  // CHECK-NEXT: to label %[[INVOKECONT4:.+]] unwind label %[[DETLPAD4:.+]]
  // CHECK: [[INVOKECONT4]]:
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE4]]
  // CHECK: [[CONTINUE4]]:

  // CHECK: [[DETLPAD]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[TFLPAD]]

  // CHECK: [[TFLPAD]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD2]]

  // CHECK: [[TFLPAD2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK: [[DETLPAD3_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD3]]

  // CHECK: [[TFLPAD3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[TFLPAD4]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK-O0: br label %[[EHCLEANUP:.+]]
  // CHECK-O1: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME4]],
  // CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD4]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD4]]

  // CHECK-O0: [[EHCLEANUP]]:
  // CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME4]],
  // CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind
}

void derived_class() {
  // CHECK-LABEL: define void @_Z13derived_classv()
  Bar b0, b6, b7;
  Bar b8 = _Cilk_spawn makeDBar(), b2 = _Cilk_spawn makeDBarFromBar(b0);
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[REFTMP:.+]] = alloca %class.DBar
  // CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[TFLPAD:.+]]
  // CHECK: [[DETACHED]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
  // CHECK-O1-NEXT: %[[REFTMPADDR:.+]] = bitcast %class.DBar* %[[REFTMP]] to i8*
  // CHECK-O1-NEXT: call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %[[REFTMPADDR]])
  // CHECK: invoke void @_Z8makeDBarv(%class.DBar* {{(nonnull )?}}sret {{.*}}%[[REFTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[DETLPAD:.+]]
  // CHECK: [[INVOKECONT]]:
  // CHECK-O0-NEXT: %[[CAST:.+]] = bitcast %class.DBar* %[[REFTMP]] to %class.Bar*
  // CHECK-O1-NEXT: %[[CAST:.+]] = getelementptr inbounds %class.DBar, %class.DBar* %[[REFTMP]], i64 0, i32 0
  // CHECK-NEXT: invoke void @_ZN3BarC1EOS_(%class.Bar* {{(nonnull )?}}%[[b8:.+]], %class.Bar* {{(nonnull )?}}{{.*}}dereferenceable(16) %[[CAST]])
  // CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[DETLPAD_2:.+]]
  // CHECK: [[INVOKECONT2]]:
  // CHECK-NEXT: call void @_ZN4DBarD1Ev(%class.DBar* {{(nonnull )?}}%[[REFTMP]])
  // CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %[[REFTMPADDR]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]
  // CHECK: [[CONTINUE]]:
  // CHECK: %[[TASKFRAME2:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[REFTMP2:.+]] = alloca %class.DBar
  // CHECK: %[[AGGTMP:.+]] = alloca %class.Bar
  // CHECK: invoke void @_ZN3BarC1ERKS_(%class.Bar* {{(nonnull )?}}%[[AGGTMP]], %class.Bar* {{(nonnull )?}}{{.*}}dereferenceable(16) %[[b0:.+]])
  // CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[TFLPAD2:.+]]
  // CHECK: [[INVOKECONT3]]:
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[TFLPAD2]]
  // CHECK: [[DETACHED2]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
  // CHECK-O1-NEXT: %[[REFTMP2ADDR:.+]] = bitcast %class.DBar* %[[REFTMP2]] to i8*
  // CHECK-O1-NEXT: call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %[[REFTMP2ADDR]])
  // CHECK: invoke void @_Z15makeDBarFromBar3Bar(%class.DBar* {{(nonnull )?}}sret {{.*}}%[[REFTMP2]], %class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT4:.+]] unwind label %[[DETLPAD2:.+]]
  // CHECK: [[INVOKECONT4]]:
  // CHECK-O0-NEXT: %[[CAST2:.+]] = bitcast %class.DBar* %[[REFTMP2]] to %class.Bar*
  // CHECK-O1-NEXT: %[[CAST2:.+]] = getelementptr inbounds %class.DBar, %class.DBar* %[[REFTMP2]], i64 0, i32 0
  // CHECK-NEXT: invoke void @_ZN3BarC1EOS_(%class.Bar* {{(nonnull )?}}%[[b2:.+]], %class.Bar* {{(nonnull )?}}{{.*}}dereferenceable(16) %[[CAST2]])
  // CHECK-NEXT: to label %[[INVOKECONT5:.+]] unwind label %[[DETLPAD2_2:.+]]
  // CHECK: [[INVOKECONT5]]:
  // CHECK-NEXT: call void @_ZN4DBarD1Ev(%class.DBar* {{(nonnull )?}}%[[REFTMP2]])
  // CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %[[REFTMP2ADDR]])
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]
  // CHECK: [[CONTINUE2]]:
  b6 = _Cilk_spawn makeDBarFromBar(b7);
  // CHECK: %[[TASKFRAME3:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[AGGTMP3:.+]] = alloca %class.Bar
  // CHECK: %[[REFTMP3:.+]] = alloca %class.DBar
  // CHECK: %[[AGGTMP2:.+]] = alloca %class.Bar
  // CHECK: invoke void @_ZN3BarC1ERKS_(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]], %class.Bar* {{(nonnull )?}}{{.*}}dereferenceable(16) %[[b7:.+]])
  // CHECK-NEXT: to label %[[INVOKECONT6:.+]] unwind label %[[TFLPAD3:.+]]
  // CHECK: [[INVOKECONT6]]:
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]] unwind label %[[TFLPAD3]]
  // CHECK: [[DETACHED3]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
  // CHECK-O1-NEXT: %[[REFTMP3ADDR:.+]] = bitcast %class.DBar* %[[REFTMP3]] to i8*
  // CHECK-O1-NEXT: call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %[[REFTMP3ADDR]])
  // CHECK: invoke void @_Z15makeDBarFromBar3Bar(%class.DBar* {{(nonnull )?}}sret {{.*}}%[[REFTMP3]], %class.Bar* {{(nonnull )?}}%[[AGGTMP2]])
  // CHECK-NEXT: to label %[[INVOKECONT7:.+]] unwind label %[[DETLPAD3:.+]]
  // CHECK: [[INVOKECONT7]]:
  // CHECK-O0-NEXT: %[[CAST3:.+]] = bitcast %class.DBar* %[[REFTMP3]] to %class.Bar*
  // CHECK-O1-NEXT: %[[CAST3:.+]] = getelementptr inbounds %class.DBar, %class.DBar* %[[REFTMP3]], i64 0, i32 0
  // CHECK-NEXT: invoke {{.*}}void @_ZN3BarC1EOS_(%class.Bar* {{(nonnull )?}}%[[AGGTMP3]], %class.Bar* {{(nonnull )?}}{{.*}}dereferenceable(16) %[[CAST3]])
  // CHECK-NEXT: to label %[[INVOKECONT8:.+]] unwind label %[[DETLPAD3_2:.+]]
  // CHECK: [[INVOKECONT8]]:
  // CHECK-NEXT: %[[CALL:.+]] = invoke {{.*}}dereferenceable(16) %class.Bar* @_ZN3BaraSES_(%class.Bar* {{(nonnull )?}}%[[b6:.+]], %class.Bar* {{(nonnull )?}}%[[AGGTMP3]])
  // CHECK-NEXT: to label %[[INVOKECONT9:.+]] unwind label %[[DETLPAD3_3:.+]]
  // CHECK: [[INVOKECONT9]]:
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP3]])
  // CHECK-NEXT: call void @_ZN4DBarD1Ev(%class.DBar* {{(nonnull )?}}%[[REFTMP3]])
  // CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %[[REFTMP3ADDR]])
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]
  // CHECK: [[CONTINUE3]]:

  // CHECK: [[DETLPAD]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[TFLPAD]]

  // CHECK: [[TFLPAD]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[TFLPAD2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK-O1-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
  // CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD2_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD2]]

  // CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
  // CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[TFLPAD3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK-O1-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
  // CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD3_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD3_3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD3]]

  // CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
  // CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind
}

void two_classes() {
  // CHECK-LABEL: define void @_Z11two_classesv()
  Bar b9, b11;
  Bar b12 = _Cilk_spawn makeBaz();
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[REFTMP:.+]] = alloca %class.Baz
  // CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[TFLPAD:.+]]
  // CHECK: [[DETACHED]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
  // CHECK-O1-NEXT: %[[REFTMPADDR:.+]] = getelementptr inbounds %class.Baz, %class.Baz* %[[REFTMP]], i64 0, i32 0
  // CHECK-O1-NEXT: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[REFTMPADDR]])
  // CHECK: invoke void @_Z7makeBazv(%class.Baz* {{(nonnull )?}}sret {{.*}}%[[REFTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[DETLPAD:.+]]
  // CHECK: [[INVOKECONT]]:
  // CHECK-NEXT: invoke void @_ZN3BarC1ERK3Baz(%class.Bar* {{(nonnull )?}}%[[b12:.+]], %class.Baz* {{(nonnull )?}}{{.*}}dereferenceable(1) %[[REFTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT2:.+]] unwind label %[[DETLPAD_2:.+]]
  // CHECK: [[INVOKECONT2]]:
  // CHECK-NEXT: call void @_ZN3BazD1Ev(%class.Baz* {{(nonnull )?}}%[[REFTMP]])
  // CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[REFTMPADDR]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]
  // CHECK: [[CONTINUE]]:
  Bar b13 = _Cilk_spawn makeBazFromBar(b9);
  // CHECK: %[[TASKFRAME2:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[REFTMP2:.+]] = alloca %class.Baz
  // CHECK: %[[AGGTMP:.+]] = alloca %class.Bar
  // CHECK: invoke void @_ZN3BarC1ERKS_(%class.Bar* {{(nonnull )?}}%[[AGGTMP]], %class.Bar* {{(nonnull )?}}{{.*}}dereferenceable(16) %[[b9:.+]])
  // CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[TFLPAD2:.+]]
  // CHECK: [[INVOKECONT3]]:
  // CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[TFLPAD2]]
  // CHECK: [[DETACHED2]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME2]])
  // CHECK-O1-NEXT: %[[REFTMP2ADDR:.+]] = getelementptr inbounds %class.Baz, %class.Baz* %[[REFTMP2]], i64 0, i32 0
  // CHECK-O1-NEXT: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[REFTMP2ADDR]])
  // CHECK: invoke void @_Z14makeBazFromBar3Bar(%class.Baz* {{(nonnull )?}}sret {{.*}}%[[REFTMP2]], %class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT4:.+]] unwind label %[[DETLPAD2:.+]]
  // CHECK: [[INVOKECONT4]]:
  // CHECK-NEXT: invoke void @_ZN3BarC1ERK3Baz(%class.Bar* {{(nonnull )?}}%[[b13:.+]], %class.Baz* {{(nonnull )?}}{{.*}}dereferenceable(1) %[[REFTMP2]])
  // CHECK-NEXT: to label %[[INVOKECONT5:.+]] unwind label %[[DETLPAD2_2:.+]]
  // CHECK: [[INVOKECONT5]]:
  // CHECK-NEXT: call void @_ZN3BazD1Ev(%class.Baz* {{(nonnull )?}}%[[REFTMP2]])
  // CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[REFTMP2ADDR]])
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]
  // CHECK: [[CONTINUE2]]:
  b9 = _Cilk_spawn makeBazFromBar(b11);
  // CHECK: %[[TASKFRAME3:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[AGGTMP3:.+]] = alloca %class.Bar
  // CHECK: %[[REFTMP3:.+]] = alloca %class.Baz
  // CHECK: %[[AGGTMP2:.+]] = alloca %class.Bar
  // CHECK: invoke void @_ZN3BarC1ERKS_(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]], %class.Bar* {{(nonnull )?}}{{.*}}dereferenceable(16) %[[b11:.+]])
  // CHECK-NEXT: to label %[[INVOKECONT6:.+]] unwind label %[[TFLPAD3:.+]]
  // CHECK: [[INVOKECONT6]]:
  // CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]] unwind label %[[TFLPAD3]]
  // CHECK: [[DETACHED3]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME3]])
  // CHECK-O1-NEXT: %[[REFTMP3ADDR:.+]] = getelementptr inbounds %class.Baz, %class.Baz* %[[REFTMP3]], i64 0, i32 0
  // CHECK-O1-NEXT: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[REFTMP3ADDR]])
  // CHECK: invoke void @_Z14makeBazFromBar3Bar(%class.Baz* {{(nonnull )?}}sret {{.*}}%[[REFTMP3]], %class.Bar* {{(nonnull )?}}%[[AGGTMP2]])
  // CHECK-NEXT: to label %[[INVOKECONT7:.+]] unwind label %[[DETLPAD3:.+]]
  // CHECK: [[INVOKECONT7]]:
  // CHECK-NEXT: invoke void @_ZN3BarC1ERK3Baz(%class.Bar* {{(nonnull )?}}%[[AGGTMP3]], %class.Baz* {{(nonnull )?}}{{.*}}dereferenceable(1) %[[REFTMP3]])
  // CHECK-NEXT: to label %[[INVOKECONT8:.+]] unwind label %[[DETLPAD3_2:.+]]
  // CHECK: [[INVOKECONT8]]:
  // CHECK-NEXT: %[[CALL:.+]] = invoke {{.*}}dereferenceable(16) %class.Bar* @_ZN3BaraSES_(%class.Bar* {{(nonnull )?}}%[[b9:.+]], %class.Bar* {{(nonnull )?}}%[[AGGTMP3]])
  // CHECK-NEXT: to label %[[INVOKECONT9:.+]] unwind label %[[DETLPAD3_3:.+]]
  // CHECK: [[INVOKECONT9]]:
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP3]])
  // CHECK-NEXT: call void @_ZN3BazD1Ev(%class.Baz* {{(nonnull )?}}%[[REFTMP3]])
  // CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[REFTMP3ADDR]])
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]
  // CHECK: [[CONTINUE3]]:

  // CHECK: [[DETLPAD]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[TFLPAD]]

  // CHECK: [[TFLPAD]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[TFLPAD2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK-O1-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
  // CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD2_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD2]]

  // CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
  // CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[TFLPAD3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK-O1-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
  // CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD3_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD3_3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD3]]

  // CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
  // CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind
}

void array_out() {
  // CHECK-LABEL: define void @_Z9array_outv()
  // int Arri[5];
  // Example that produces a BinAssign expr.
  // bool Assign0 = (Arri[0] = foo(makeBazFromBar((Bar()))));
  // Pretty sure the following just isn't legal Cilk.
  // bool Assign1 = (Arri[1] = _Cilk_spawn foo(makeBazFromBar((Bar()))));

  Bar ArrBar[5];
  // ArrBar[0] = makeBazFromBar((Bar()));
  ArrBar[1] = _Cilk_spawn makeBazFromBar((Bar()));
  // CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[AGGTMP2:.+]] = alloca %class.Bar
  // CHECK: %[[REFTMP:.+]] = alloca %class.Baz
  // CHECK: %[[AGGTMP:.+]] = alloca %class.Bar
  // CHECK: %[[ARRIDX:.+]] = getelementptr inbounds [5 x %class.Bar], [5 x %class.Bar]* %[[ArrBar:.+]], i64 0, i64 1
  // CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[TFLPAD:.+]]
  // CHECK: [[INVOKECONT]]:
  // CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[TFLPAD]]
  // CHECK: [[DETACHED]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
  // CHECK-O1-NEXT: %[[REFTMPADDR:.+]] = getelementptr inbounds %class.Baz, %class.Baz* %[[REFTMP]], i64 0, i32 0
  // CHECK-O1-NEXT: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[REFTMPADDR]])
  // CHECK: invoke void @_Z14makeBazFromBar3Bar(%class.Baz* {{(nonnull )?}}sret {{.*}}%[[REFTMP]], %class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK: to label %[[INVOKECONT2:.+]] unwind label %[[DETLPAD:.+]]
  // CHECK: [[INVOKECONT2]]:
  // CHECK-NEXT: invoke void @_ZN3BarC1ERK3Baz(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]], %class.Baz* {{(nonnull )?}}{{.*}}dereferenceable(1) %[[REFTMP]])
  // CHECK-NEXT: to label %[[INVOKECONT3:.+]] unwind label %[[DETLPAD_2:.+]]
  // CHECK: [[INVOKECONT3]]:
  // CHECK-NEXT: %[[CALL:.+]] = invoke {{.*}}dereferenceable(16) %class.Bar* @_ZN3BaraSES_(%class.Bar* {{(nonnull )?}}%[[ARRIDX]], %class.Bar* {{(nonnull )?}}%[[AGGTMP2]])
  // CHECK-NEXT: to label %[[INVOKECONT4:.+]] unwind label %[[DETLPAD_3:.+]]
  // CHECK: [[INVOKECONT4]]:
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP2]])
  // CHECK-NEXT: call void @_ZN3BazD1Ev(%class.Baz* {{(nonnull )?}}%[[REFTMP]])
  // CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[REFTMPADDR]])
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]
  // CHECL: [[CONTINUE]]:

  // List initialization
  // Bar ListBar1[3] = { Bar(), makeBar(), makeBazFromBar((Bar())) };
  Bar ListBar2[3] = { _Cilk_spawn Bar(), _Cilk_spawn makeBar(), _Cilk_spawn makeBazFromBar((Bar())) };
  // CHECK: %[[ARRIDX2:.+]] = getelementptr inbounds [3 x %class.Bar], [3 x %class.Bar]* %[[ListBar2:.+]], i64 0, i64 0
  // CHECK: %[[TASKFRAME2:.+]] = call token @llvm.taskframe.create()
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED2:.+]], label %[[CONTINUE2:.+]] unwind label %[[TFLPAD2:.+]]
  // CHECK: [[DETACHED2]]:
  // CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{(nonnull )?}}%[[ARRIDX2]])
  // CHECK-NEXT: to label %[[INVOKECONT5:.+]] unwind label %[[DETLPAD2:.+]]
  // CHECK: [[INVOKECONT5]]:
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE2]]
  // CHECK: [[CONTINUE2]]:

  // CHECK-O0: %[[ARRIDX3:.+]] = getelementptr inbounds %class.Bar, %class.Bar* %[[ARRIDX2]], i64 1
  // CHECK: %[[TASKFRAME3:.+]] = call token @llvm.taskframe.create()
  // CHECK: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE3:.+]] unwind label %[[TFLPAD3:.+]]
  // CHECK: [[DETACHED3]]:
  // CHECK-O1: %[[ARRIDX3:.+]] = getelementptr inbounds [3 x %class.Bar], [3 x %class.Bar]* %[[ListBar2]], i64 0, i64 1
  // CHECK: invoke void @_Z7makeBarv(%class.Bar* {{(nonnull )?}}sret {{.*}}%[[ARRIDX3]])
  // CHECK-NEXT: to label %[[INVOKECONT6:.+]] unwind label %[[DETLPAD3:.+]]
  // CHECK: [[INVOKECONT6]]:
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]

  // CHECK-O0: %[[ARRIDX4:.+]] = getelementptr inbounds %class.Bar, %class.Bar* %[[ARRIDX3]], i64 1
  // CHECK-O1: %[[ARRIDX4:.+]] = getelementptr inbounds [3 x %class.Bar], [3 x %class.Bar]* %[[ListBar2]], i64 0, i64 2
  // CHECK: %[[TASKFRAME4:.+]] = call token @llvm.taskframe.create()
  // CHECK: %[[REFTMP2:.+]] = alloca %class.Baz
  // CHECK: %[[AGGTMP3:.+]] = alloca %class.Bar
  // CHECK: invoke void @_ZN3BarC1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP3]])
  // CHECK-NEXT: to label %[[INVOKECONT7:.+]] unwind label %[[TFLPAD4:.+]]
  // CHECK: [[INVOKECONT7]]:
  // CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED4:.+]], label %[[CONTINUE4:.+]] unwind label %[[TFLPAD4]]
  // CHECK: [[DETACHED4]]:
  // CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME4]])
  // CHECK-O1-NEXT: %[[REFTMP2ADDR:.+]] = getelementptr inbounds %class.Baz, %class.Baz* %[[REFTMP2]], i64 0, i32 0
  // CHECK-O1-NEXT: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[REFTMP2ADDR]])
  // CHECK: invoke void @_Z14makeBazFromBar3Bar(%class.Baz* {{(nonnull )?}}sret {{.*}}%[[REFTMP2]], %class.Bar* {{(nonnull )?}}%[[AGGTMP3]])
  // CHECK: to label %[[INVOKECONT8:.+]] unwind label %[[DETLPAD4:.+]]
  // CHECK: [[INVOKECONT8]]:
  // CHECK-NEXT: invoke void @_ZN3BarC1ERK3Baz(%class.Bar* {{(nonnull )?}}{{.*}}%[[ARRIDX4:.+]], %class.Baz* {{(nonnull )?}}{{.*}}dereferenceable(1) %[[REFTMP2]])
  // CHECK-NEXT: to label %[[INVOKECONT9:.+]] unwind label %[[DETLPAD4_2:.+]]
  // CHECK: [[INVOKECONT9]]:
  // CHECK-NEXT: call void @_ZN3BazD1Ev(%class.Baz* {{(nonnull )?}}%[[REFTMP2]])
  // CHECK-O1-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[REFTMP2ADDR]])
  // CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* {{(nonnull )?}}%[[AGGTMP3]])
  // CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE4]]
  // CHECK: [[CONTINUE4]]:

  // CHECK: [[TFLPAD]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK-O1-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
  // CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD_3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[TFLPAD]]

  // CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
  // CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD2]]

  // CHECK: [[TFLPAD2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME2]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD3]]

  // CHECK: [[TFLPAD3]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME3]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[TFLPAD4]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup
  // CHECK-O1-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME4]],
  // CHECK-O1-NEXT: to label %[[UNREACHABLE]] unwind

  // CHECK: [[DETLPAD4]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: [[DETLPAD4_2]]:
  // CHECK-NEXT: landingpad
  // CHECK-NEXT: cleanup

  // CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
  // CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[TFLPAD4]]

  // CHECK-O0: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME4]],
  // CHECK-O0-NEXT: to label %[[UNREACHABLE]] unwind
}
