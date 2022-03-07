; Check that loop spawning removes the norecurse and noreturn attributes.
;
; RUN: opt < %s -enable-new-pm=0 -loop-spawning-ti -S | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: norecurse noreturn nounwind uwtable mustprogress
define dso_local float @_Z3sumiPfS_(i32 %n, float* nocapture readonly %a, float* nocapture %b) local_unnamed_addr #0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %n, 0
  call void @llvm.assume(i1 %cmp)
  %0 = icmp ugt i32 %n, 1
  %umax = select i1 %0, i32 %n, i32 1
  %wide.trip.count = zext i32 %umax to i64
  br label %pfor.cond

pfor.cond:                                        ; preds = %entry, %pfor.inc
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %pfor.inc ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %arrayidx = getelementptr inbounds float, float* %a, i64 %indvars.iv
  %1 = load float, float* %arrayidx, align 4, !tbaa !2
  %mul5 = fmul float %1, %1
  %arrayidx7 = getelementptr inbounds float, float* %b, i64 %indvars.iv
  store float %mul5, float* %arrayidx7, align 4, !tbaa !2
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %exitcond.not = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  unreachable
}

; CHECK: define {{.*}}void @_Z3sumiPfS_.outline_pfor.cond.ls1(
; CHECK: #[[HELPER_ATTR:[0-9]+]] {

; CHECK: attributes #[[HELPER_ATTR]] = {
; CHECK-NOT: norecurse
; CHECK-NOT: noreturn
; CHECK: }

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: nofree nosync nounwind willreturn
declare void @llvm.assume(i1 noundef) #2

attributes #0 = { norecurse noreturn nounwind uwtable mustprogress "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nofree nosync nounwind willreturn }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 31ad596bd7126d79fa36fd82538084e8a8f4d913)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"float", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = distinct !{!6, !7, !8}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
!8 = !{!"llvm.loop.unroll.disable"}
