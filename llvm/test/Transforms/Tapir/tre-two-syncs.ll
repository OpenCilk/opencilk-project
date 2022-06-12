; Check that TRE can handle two tail-recursive calls each separated
; from the same return by distinct syncs.
;
; RUN: opt < %s -tailcallelim -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress nounwind uwtable
define dso_local void @_Z14transR_nothrowmmmmmm(i64 noundef %rStart, i64 noundef %rCount, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %cCount, i64 noundef %cLength) local_unnamed_addr #0 {
entry:
  %syncreg17 = call token @llvm.syncregion.start()
  %0 = or i64 %cCount, %rCount
  %1 = icmp ult i64 %0, 64
  br i1 %1, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %add = add i64 %rCount, %rStart
  %cmp2 = icmp ugt i64 %add, %rStart
  br i1 %cmp2, label %pfor.cond.preheader, label %if.end30

pfor.cond.preheader:                              ; preds = %if.then
  %add6 = add i64 %cCount, %cStart
  %cmp781 = icmp ugt i64 %add6, %cStart
  %umax = call i64 @llvm.umax.i64(i64 %rCount, i64 1)
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc
  %__begin.0 = phi i64 [ %inc9, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  %add5 = add i64 %__begin.0, %rStart
  detach within %syncreg17, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  br i1 %cmp781, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %pfor.body
  reattach within %syncreg17, label %pfor.inc

for.body:                                         ; preds = %pfor.body, %for.body
  %j.082 = phi i64 [ %inc, %for.body ], [ %cStart, %pfor.body ]
  call void @_Z11foo_nothrowmm(i64 noundef %add5, i64 noundef %j.082) #7
  %inc = add nuw i64 %j.082, 1
  %exitcond.not = icmp eq i64 %inc, %add6
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !3

pfor.inc:                                         ; preds = %for.cond.cleanup, %pfor.cond
  %inc9 = add nuw i64 %__begin.0, 1
  %exitcond83.not = icmp eq i64 %inc9, %umax
  br i1 %exitcond83.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg17, label %if.end30

if.else:                                          ; preds = %entry
  %cmp12 = icmp ugt i64 %cCount, %rCount
  br i1 %cmp12, label %if.then13, label %if.else20

if.then13:                                        ; preds = %if.else
  %div14 = lshr i64 %cCount, 1
  %sub16 = sub i64 %cCount, %div14
  detach within %syncreg17, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.then13
  call void @_Z14transR_nothrowmmmmmm(i64 noundef %rStart, i64 noundef %rCount, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %div14, i64 noundef %cLength) #7
  reattach within %syncreg17, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.then13
  %add18 = add i64 %div14, %cStart
  call void @_Z14transR_nothrowmmmmmm(i64 noundef %rStart, i64 noundef %rCount, i64 noundef %rLength, i64 noundef %add18, i64 noundef %sub16, i64 noundef %cLength) #7
  sync within %syncreg17, label %if.end30

if.else20:                                        ; preds = %if.else
  %div22 = lshr i64 %rCount, 1
  %sub25 = sub i64 %rCount, %div22
  detach within %syncreg17, label %det.achd26, label %det.cont27

det.achd26:                                       ; preds = %if.else20
  call void @_Z14transR_nothrowmmmmmm(i64 noundef %rStart, i64 noundef %div22, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %cCount, i64 noundef %cLength) #7
  reattach within %syncreg17, label %det.cont27

det.cont27:                                       ; preds = %det.achd26, %if.else20
  %add28 = add i64 %div22, %rStart
  call void @_Z14transR_nothrowmmmmmm(i64 noundef %add28, i64 noundef %sub25, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %cCount, i64 noundef %cLength) #7
  sync within %syncreg17, label %if.end30

if.end30:                                         ; preds = %det.cont27, %det.cont, %if.then, %pfor.cond.cleanup
  ret void
}

; CHECK-LABEL: define dso_local void @_Z14transR_nothrowmmmmmm(

; CHECK: det.cont:
; CHECK-NOT: call void @_Z14transR_nothrowmmmmmm(
; CHECK-NOT: sync within %syncreg17
; CHECK: br label %tailrecurse

; CHECK: det.cont27:
; CHECK-NOT: call void @_Z14transR_nothrowmmmmmm(
; CHECK-NOT: sync within %syncreg17
; CHECK: br label %tailrecurse

; CHECK: if.end30:
; CHECK-NEXT: sync within %syncreg17, label %[[RETBLK:.+]]

; CHECK: [[RETBLK]]:
; CHECK-NEXT: ret void

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: nounwind
declare dso_local void @_Z11foo_nothrowmm(i64 noundef, i64 noundef) local_unnamed_addr #2

; Function Attrs: mustprogress uwtable
define dso_local void @_Z6transRmmmmmm(i64 noundef %rStart, i64 noundef %rCount, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %cCount, i64 noundef %cLength) local_unnamed_addr #3 {
entry:
  %syncreg17 = call token @llvm.syncregion.start()
  %0 = or i64 %cCount, %rCount
  %1 = icmp ult i64 %0, 64
  br i1 %1, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %add = add i64 %rCount, %rStart
  %cmp2 = icmp ugt i64 %add, %rStart
  br i1 %cmp2, label %pfor.cond.preheader, label %if.end30

pfor.cond.preheader:                              ; preds = %if.then
  %add6 = add i64 %cCount, %cStart
  %cmp781 = icmp ugt i64 %add6, %cStart
  %umax = call i64 @llvm.umax.i64(i64 %rCount, i64 1)
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc
  %__begin.0 = phi i64 [ %inc9, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  %add5 = add i64 %__begin.0, %rStart
  detach within %syncreg17, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  br i1 %cmp781, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %pfor.body
  reattach within %syncreg17, label %pfor.inc

for.body:                                         ; preds = %pfor.body, %for.body
  %j.082 = phi i64 [ %inc, %for.body ], [ %cStart, %pfor.body ]
  call void @_Z3foomm(i64 noundef %add5, i64 noundef %j.082)
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
  call void @llvm.sync.unwind(token %syncreg17)
  br label %if.end30

if.else:                                          ; preds = %entry
  %cmp12 = icmp ugt i64 %cCount, %rCount
  br i1 %cmp12, label %if.then13, label %if.else20

if.then13:                                        ; preds = %if.else
  %div14 = lshr i64 %cCount, 1
  %sub16 = sub i64 %cCount, %div14
  detach within %syncreg17, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.then13
  call void @_Z6transRmmmmmm(i64 noundef %rStart, i64 noundef %rCount, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %div14, i64 noundef %cLength)
  reattach within %syncreg17, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.then13
  %add18 = add i64 %div14, %cStart
  call void @_Z6transRmmmmmm(i64 noundef %rStart, i64 noundef %rCount, i64 noundef %rLength, i64 noundef %add18, i64 noundef %sub16, i64 noundef %cLength)
  sync within %syncreg17, label %sync.continue19

sync.continue19:                                  ; preds = %det.cont
  call void @llvm.sync.unwind(token %syncreg17)
  br label %if.end30

if.else20:                                        ; preds = %if.else
  %div22 = lshr i64 %rCount, 1
  %sub25 = sub i64 %rCount, %div22
  detach within %syncreg17, label %det.achd26, label %det.cont27

det.achd26:                                       ; preds = %if.else20
  call void @_Z6transRmmmmmm(i64 noundef %rStart, i64 noundef %div22, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %cCount, i64 noundef %cLength)
  reattach within %syncreg17, label %det.cont27

det.cont27:                                       ; preds = %det.achd26, %if.else20
  %add28 = add i64 %div22, %rStart
  call void @_Z6transRmmmmmm(i64 noundef %add28, i64 noundef %sub25, i64 noundef %rLength, i64 noundef %cStart, i64 noundef %cCount, i64 noundef %cLength)
  sync within %syncreg17, label %sync.continue29

sync.continue29:                                  ; preds = %det.cont27
  call void @llvm.sync.unwind(token %syncreg17)
  br label %if.end30

if.end30:                                         ; preds = %sync.continue, %if.then, %sync.continue19, %sync.continue29
  ret void
}

; CHECK-LABEL: define dso_local void @_Z6transRmmmmmm(

; CHECK: det.cont:
; CHECK-NOT: call void @_Z6transRmmmmmm(
; CHECK-NOT: sync within %syncreg17
; CHECK-NOT: call void @llvm.sync.unwind(
; CHECK: br label %tailrecurse

; CHECK: det.cont27:
; CHECK-NOT: call void @_Z6transRmmmmmm(
; CHECK-NOT: sync within %syncreg17
; CHECK-NOT: call void @llvm.sync.unwind(
; CHECK: br label %tailrecurse

; CHECK: if.end30:
; CHECK-NEXT: sync within %syncreg17, label %[[RETBLK:.+]]

; CHECK: [[RETBLK]]:
; CHECK-NEXT: call void @llvm.sync.unwind(token %syncreg17)
; CHECK-NEXT: ret void

declare dso_local void @_Z3foomm(i64 noundef, i64 noundef) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress willreturn
declare void @llvm.sync.unwind(token) #5

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i64 @llvm.umax.i64(i64, i64) #6

attributes #0 = { mustprogress nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nounwind willreturn }
attributes #2 = { nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { argmemonly mustprogress willreturn }
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
