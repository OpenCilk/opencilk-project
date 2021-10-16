; RUN: opt < %s -inline -S -o - | FileCheck %s
; RUN: opt < %s -passes='inline' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$_ZN5outerC2ERKS_ = comdat any

$_ZNSt5arrayI5outerLm2EED2Ev = comdat any

define dso_local void @main() local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_ZN5outerC2ERKS_()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  invoke void @_ZN5outerC2ERKS_()
          to label %invoke.cont1 unwind label %lpad

invoke.cont1:                                     ; preds = %invoke.cont
  ret void

lpad:                                             ; preds = %entry, %invoke.cont
  %arrayinit.endOfInit.0.idx = phi i64 [ 1, %invoke.cont ], [ 0, %entry ]
  %0 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } %0
}

; CHECK: define {{.*}}void @main()
; CHECK: entry:
; CHECK: detach within %{{.*}}, label %[[PFOR_BODY_1:.+]], label %{{.*}} unwind label %lpad

; CHECK: [[PFOR_BODY_1]]:
; CHECK-NEXT: invoke void @_Znwm()
; CHECK-NEXT: to label %{{.*}} unwind label %[[LPAD1:.+]]

; CHECK: [[LPAD1]]:
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %{{.*}},
; CHECK-NEXT: to label %{{.*}} unwind label %lpad

; CHECK: invoke.cont:
; CHECK: detach within %{{.*}}, label %[[PFOR_BODY_2:.+]], label %{{.*}} unwind label %lpad

; CHECK: [[PFOR_BODY_2]]:
; CHECK-NEXT: invoke void @_Znwm()
; CHECK-NEXT: to label %{{.*}} unwind label %[[LPAD2:.+]]

; CHECK: [[LPAD2]]:
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %{{.*}},
; CHECK-NEXT: to label %{{.*}} unwind label %lpad

; CHECK: lpad:
; CHECK-NEXT: %arrayinit.endOfInit.0.idx = phi i64 [ 0, %[[LPAD1]] ], [ 0, %entry ], [ 1, %[[LPAD2]] ], [ 1, %invoke.cont ]

define dso_local void @_ZN5outerC2ERKS_() unnamed_addr #1 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %entry
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  call void @_Znwm() #3
  unreachable

pfor.inc:                                         ; preds = %pfor.cond
  unreachable
}

declare dso_local i32 @__gxx_personality_v0(...)

define dso_local void @_ZNSt5arrayI5outerLm2EED2Ev() unnamed_addr #1 comdat align 2 {
entry:
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

declare dso_local void @_Znwm() local_unnamed_addr #1

attributes #0 = { "target-cpu"="x86-64" }
attributes #1 = { "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { builtin }

!llvm.ident = !{!0}

!0 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 973aa8d610bafa8c98286f78c034ce1c27c26eec)"}
