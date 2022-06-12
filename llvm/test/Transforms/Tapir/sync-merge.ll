; Check that SimplifyCFG can combine redundant syncs.
;
; RUN: opt < %s -simplifycfg -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress nounwind uwtable
define dso_local void @_Z14transR_nothrowmmmmmm(i64 noundef %rStart, i64 noundef %rCount, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %cCount, i64 noundef %cLength) local_unnamed_addr #0 {
entry:
  %syncreg17 = tail call token @llvm.syncregion.start()
  br label %tailrecurse

tailrecurse:                                      ; preds = %det.cont27, %det.cont, %entry
  %rStart.tr = phi i64 [ %rStart, %entry ], [ %rStart.tr, %det.cont ], [ %add28, %det.cont27 ]
  %rCount.tr = phi i64 [ %rCount, %entry ], [ %rCount.tr, %det.cont ], [ %sub25, %det.cont27 ]
  %cStart.tr = phi i64 [ %cStart, %entry ], [ %add18, %det.cont ], [ %cStart.tr, %det.cont27 ]
  %cCount.tr = phi i64 [ %cCount, %entry ], [ %sub16, %det.cont ], [ %cCount.tr, %det.cont27 ]
  %0 = or i64 %cCount.tr, %rCount.tr
  %1 = icmp ult i64 %0, 64
  br i1 %1, label %if.then, label %if.else

if.then:                                          ; preds = %tailrecurse
  %add = add i64 %rCount.tr, %rStart.tr
  %cmp2 = icmp ugt i64 %add, %rStart.tr
  br i1 %cmp2, label %pfor.cond.preheader, label %if.end30

pfor.cond.preheader:                              ; preds = %if.then
  %add6 = add i64 %cCount.tr, %cStart.tr
  %cmp781 = icmp ugt i64 %add6, %cStart.tr
  %umax = tail call i64 @llvm.umax.i64(i64 %rCount.tr, i64 1)
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %__begin.0 = phi i64 [ %inc9, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  %add5 = add i64 %__begin.0, %rStart.tr
  detach within %syncreg17, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  br i1 %cmp781, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %pfor.body
  reattach within %syncreg17, label %pfor.inc

for.body:                                         ; preds = %for.body, %pfor.body
  %j.082 = phi i64 [ %inc, %for.body ], [ %cStart.tr, %pfor.body ]
  tail call void @_Z11foo_nothrowmm(i64 noundef %add5, i64 noundef %j.082) #7
  %inc = add nuw i64 %j.082, 1
  %exitcond.not = icmp eq i64 %inc, %add6
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !3

pfor.inc:                                         ; preds = %for.cond.cleanup, %pfor.cond
  %inc9 = add nuw i64 %__begin.0, 1
  %exitcond83.not = icmp eq i64 %inc9, %umax
  br i1 %exitcond83.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg17, label %if.end30

if.else:                                          ; preds = %tailrecurse
  %cmp12 = icmp ugt i64 %cCount.tr, %rCount.tr
  br i1 %cmp12, label %if.then13, label %if.else20

if.then13:                                        ; preds = %if.else
  %div14 = lshr i64 %cCount.tr, 1
  %sub16 = sub i64 %cCount.tr, %div14
  detach within %syncreg17, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.then13
  tail call void @_Z14transR_nothrowmmmmmm(i64 noundef %rStart.tr, i64 noundef %rCount.tr, i64 noundef %rLength, i64 noundef %cStart.tr, i64 noundef %div14, i64 noundef %cLength) #7
  reattach within %syncreg17, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.then13
  %add18 = add i64 %div14, %cStart.tr
  br label %tailrecurse

if.else20:                                        ; preds = %if.else
  %div22 = lshr i64 %rCount.tr, 1
  %sub25 = sub i64 %rCount.tr, %div22
  detach within %syncreg17, label %det.achd26, label %det.cont27

det.achd26:                                       ; preds = %if.else20
  tail call void @_Z14transR_nothrowmmmmmm(i64 noundef %rStart.tr, i64 noundef %div22, i64 noundef %rLength, i64 noundef %cStart.tr, i64 noundef %cCount.tr, i64 noundef %cLength) #7
  reattach within %syncreg17, label %det.cont27

det.cont27:                                       ; preds = %det.achd26, %if.else20
  %add28 = add i64 %div22, %rStart.tr
  br label %tailrecurse

if.end30:                                         ; preds = %pfor.cond.cleanup, %if.then
  sync within %syncreg17, label %if.end30.split

if.end30.split:                                   ; preds = %if.end30
  ret void
}

; CHECK-LABEL: define dso_local void @_Z14transR_nothrowmmmmmm(

; CHECK: pfor.cond:
; CHECK: detach within %syncreg17, label %pfor.body, label %pfor.inc

; CHECK: pfor.inc:
; CHECK: br i1 {{.*}}, label %[[SYNC_BLOCK:.+]], label %pfor.cond

; CHECK-NOT: pfor.cond.cleanup:
; CHECK-NOT: sync within %syncreg17
; CHECK-NOT: call void @llvm.sync.unwind(token %syncreg17)

; CHECK: if.then13:
; CHECK: detach within %syncreg17, label %det.achd, label %det.cont

; CHECK: det.cont:
; CHECK-NOT: call void @_Z6transRmmmmmm(
; CHECK-NOT: sync within %syncreg17
; CHECK-NOT: call void @llvm.sync.unwind(
; CHECK: br label %tailrecurse

; CHECK: if.else20:
; CHECK: detach within %syncreg17, label %det.achd26, label %det.cont27

; CHECK: det.cont27:
; CHECK-NOT: call void @_Z6transRmmmmmm(
; CHECK-NOT: sync within %syncreg17
; CHECK-NOT: call void @llvm.sync.unwind(
; CHECK: br label %tailrecurse

; CHECK: [[SYNC_BLOCK]]:
; CHECK-NEXT: sync within %syncreg17, label %[[RETBLK:.+]]

; CHECK: [[RETBLK]]:
; CHECK-NEXT: ret void

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: nounwind
declare dso_local void @_Z11foo_nothrowmm(i64 noundef, i64 noundef) local_unnamed_addr #2

; Function Attrs: mustprogress uwtable
define dso_local void @_Z6transRmmmmmm(i64 noundef %rStart, i64 noundef %rCount, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %cCount, i64 noundef %cLength) local_unnamed_addr #3 {
entry:
  %syncreg17 = tail call token @llvm.syncregion.start()
  br label %tailrecurse

tailrecurse:                                      ; preds = %det.cont27, %det.cont, %entry
  %rStart.tr = phi i64 [ %rStart, %entry ], [ %rStart.tr, %det.cont ], [ %add28, %det.cont27 ]
  %rCount.tr = phi i64 [ %rCount, %entry ], [ %rCount.tr, %det.cont ], [ %sub25, %det.cont27 ]
  %cStart.tr = phi i64 [ %cStart, %entry ], [ %add18, %det.cont ], [ %cStart.tr, %det.cont27 ]
  %cCount.tr = phi i64 [ %cCount, %entry ], [ %sub16, %det.cont ], [ %cCount.tr, %det.cont27 ]
  %0 = or i64 %cCount.tr, %rCount.tr
  %1 = icmp ult i64 %0, 64
  br i1 %1, label %if.then, label %if.else

if.then:                                          ; preds = %tailrecurse
  %add = add i64 %rCount.tr, %rStart.tr
  %cmp2 = icmp ugt i64 %add, %rStart.tr
  br i1 %cmp2, label %pfor.cond.preheader, label %if.end30

pfor.cond.preheader:                              ; preds = %if.then
  %add6 = add i64 %cCount.tr, %cStart.tr
  %cmp781 = icmp ugt i64 %add6, %cStart.tr
  %umax = tail call i64 @llvm.umax.i64(i64 %rCount.tr, i64 1)
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %__begin.0 = phi i64 [ %inc9, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  %add5 = add i64 %__begin.0, %rStart.tr
  detach within %syncreg17, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  br i1 %cmp781, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %pfor.body
  reattach within %syncreg17, label %pfor.inc

for.body:                                         ; preds = %for.body, %pfor.body
  %j.082 = phi i64 [ %inc, %for.body ], [ %cStart.tr, %pfor.body ]
  tail call void @_Z3foomm(i64 noundef %add5, i64 noundef %j.082)
  %inc = add nuw i64 %j.082, 1
  %exitcond.not = icmp eq i64 %inc, %add6
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !8

pfor.inc:                                         ; preds = %for.cond.cleanup, %pfor.cond
  %inc9 = add nuw i64 %__begin.0, 1
  %exitcond83.not = icmp eq i64 %inc9, %umax
  br i1 %exitcond83.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !9

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg17, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  tail call void @llvm.sync.unwind(token %syncreg17)
  br label %if.end30

if.else:                                          ; preds = %tailrecurse
  %cmp12 = icmp ugt i64 %cCount.tr, %rCount.tr
  br i1 %cmp12, label %if.then13, label %if.else20

if.then13:                                        ; preds = %if.else
  %div14 = lshr i64 %cCount.tr, 1
  %sub16 = sub i64 %cCount.tr, %div14
  detach within %syncreg17, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.then13
  tail call void @_Z6transRmmmmmm(i64 noundef %rStart.tr, i64 noundef %rCount.tr, i64 noundef %rLength, i64 noundef %cStart.tr, i64 noundef %div14, i64 noundef %cLength)
  reattach within %syncreg17, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.then13
  %add18 = add i64 %div14, %cStart.tr
  br label %tailrecurse

if.else20:                                        ; preds = %if.else
  %div22 = lshr i64 %rCount.tr, 1
  %sub25 = sub i64 %rCount.tr, %div22
  detach within %syncreg17, label %det.achd26, label %det.cont27

det.achd26:                                       ; preds = %if.else20
  tail call void @_Z6transRmmmmmm(i64 noundef %rStart.tr, i64 noundef %div22, i64 noundef %rLength, i64 noundef %cStart.tr, i64 noundef %cCount.tr, i64 noundef %cLength)
  reattach within %syncreg17, label %det.cont27

det.cont27:                                       ; preds = %det.achd26, %if.else20
  %add28 = add i64 %div22, %rStart.tr
  br label %tailrecurse

if.end30:                                         ; preds = %sync.continue, %if.then
  sync within %syncreg17, label %if.end30.split

if.end30.split:                                   ; preds = %if.end30
  call void @llvm.sync.unwind(token %syncreg17)
  ret void
}

; CHECK-LABEL: define dso_local void @_Z6transRmmmmmm(

; CHECK: pfor.cond:
; CHECK: detach within %syncreg17, label %pfor.body, label %pfor.inc

; CHECK: pfor.inc:
; CHECK: br i1 {{.*}}, label %[[SYNC_BLOCK:.+]], label %pfor.cond

; CHECK-NOT: pfor.cond.cleanup:
; CHECK-NOT: sync within %syncreg17
; CHECK-NOT: call void @llvm.sync.unwind(token %syncreg17)

; CHECK: if.then13:
; CHECK: detach within %syncreg17, label %det.achd, label %det.cont

; CHECK: det.cont:
; CHECK-NOT: call void @_Z6transRmmmmmm(
; CHECK-NOT: sync within %syncreg17
; CHECK-NOT: call void @llvm.sync.unwind(
; CHECK: br label %tailrecurse

; CHECK: if.else20:
; CHECK: detach within %syncreg17, label %det.achd26, label %det.cont27

; CHECK: det.cont27:
; CHECK-NOT: call void @_Z6transRmmmmmm(
; CHECK-NOT: sync within %syncreg17
; CHECK-NOT: call void @llvm.sync.unwind(
; CHECK: br label %tailrecurse

; CHECK: [[SYNC_BLOCK]]:
; CHECK-NEXT: sync within %syncreg17, label %[[RETBLK:.+]]

; CHECK: [[RETBLK]]:
; CHECK-NEXT: call void @llvm.sync.unwind(token %syncreg17)
; CHECK-NEXT: ret void

declare dso_local void @_Z3foomm(i64 noundef, i64 noundef) local_unnamed_addr #4

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #5

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i64 @llvm.umax.i64(i64, i64) #6

attributes #0 = { mustprogress nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { argmemonly willreturn }
attributes #6 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 14.0.4 (git@github.com:OpenCilk/opencilk-project.git bb40f6253a942b78bd0be7d50945fed88960a60e)"}
!3 = distinct !{!3, !4, !5}
!4 = !{!"llvm.loop.mustprogress"}
!5 = !{!"llvm.loop.unroll.disable"}
!6 = distinct !{!6, !7, !5}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
!8 = distinct !{!8, !4, !5}
!9 = distinct !{!9, !7, !5}
