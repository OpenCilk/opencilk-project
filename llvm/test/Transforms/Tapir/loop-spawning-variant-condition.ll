; Check the loop-spawning pass's handling to loop-variant loop conditions.
;
; RUN: opt < %s -enable-new-pm=0 -loop-spawning-ti -S 2>&1 | FileCheck %s --check-prefix=CHECK-ERROR
; RUN: opt < %s -passes='loop-spawning' -S 2>&1 | FileCheck %s --check-prefix=CHECK-ERROR
; RUN: opt < %s -enable-new-pm=0 -licm -loop-spawning-ti -S 2>&1 | FileCheck %s
; RUN: opt < %s -passes='function(loop-mssa(licm)),loop-spawning' -S 2>&1 | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$_ZNK4CPMAI21delta_compressed_leafImEE3sumEv = comdat any

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

declare dso_local i32 @__gxx_personality_v0(...)

declare dso_local void @_ZNSt6vectorImSaImEEC2EmRKS0_() unnamed_addr #1 align 2

define dso_local void @_ZNK4CPMAI21delta_compressed_leafImEE3sumEv() local_unnamed_addr #1 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = call token @llvm.syncregion.start()
  invoke void @_ZNSt6vectorImSaImEEC2EmRKS0_()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  br label %pfor.cond

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  unreachable

pfor.cond:                                        ; preds = %pfor.inc, %invoke.cont
  %__begin.0 = phi i64 [ %inc42, %pfor.inc ], [ 0, %invoke.cont ]
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc unwind label %lpad41.loopexit

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  unreachable

pfor.inc:                                         ; preds = %pfor.cond
  %inc42 = add nuw i64 %__begin.0, 1
  %umax117 = select i1 undef, i64 undef, i64 1
  %exitcond118.not = icmp eq i64 %inc42, %umax117
  br i1 %exitcond118.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !1

pfor.cond.cleanup:                                ; preds = %pfor.inc
  unreachable

lpad41.loopexit:                                  ; preds = %pfor.cond
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } %lpad.loopexit
}

; CHECK-ERROR: Tapir loop not transformed: failed to use divide-and-conquer loop spawning.

; CHECK: define dso_local void @_ZNK4CPMAI21delta_compressed_leafImEE3sumEv()
; CHECK: invoke.cont:
; CHECK: invoke {{.*}}void @_ZNK4CPMAI21delta_compressed_leafImEE3sumEv.outline_pfor.cond.ls1(

; CHECK: define {{.*}}void @_ZNK4CPMAI21delta_compressed_leafImEE3sumEv.outline_pfor.cond.ls1(
; CHECK: pfor.inc.ls1:
; CHECK: %[[INC:.+]] = add nuw i64
; CHECK: %[[CMP:.+]] = icmp eq i64 %[[INC]]
; CHECK: br i1 %[[CMP]], label %pfor.cond.cleanup.ls1, label %pfor.cond.ls1

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 6483c891d59b7ee269d7dbde7cbf3dd36b83dd69)"}
!1 = distinct !{!1, !2, !3}
!2 = !{!"tapir.loop.spawn.strategy", i32 1}
!3 = !{!"llvm.loop.unroll.disable"}
