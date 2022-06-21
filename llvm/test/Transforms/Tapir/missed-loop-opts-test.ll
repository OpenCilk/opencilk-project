; Check that Tapir loops can be peeled and subsequently stripmined.
;
; RUN: opt < %s -passes='loop(loop-unroll-full),gvn,loop(tapir-indvars),loop-stripmine' -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: argmemonly norecurse nounwind uwtable
define dso_local void @test(i64 noundef %size, i64* nocapture noundef %data) local_unnamed_addr #0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp.not = icmp eq i64 %size, 0
  br i1 %cmp.not, label %cleanup, label %pfor.cond.preheader

pfor.cond.preheader:                              ; preds = %entry
  br label %pfor.cond

; CHECK: pfor.cond.preheader:
; CHECK-NEXT: detach within %syncreg, label %pfor.body.peel, label %pfor.inc.peel

; CHECK: pfor.body.peel:
; CHECK-NEXT: br i1 true, label %if.then.peel, label %if.else.peel

; CHECK: pfor.inc.peel:
; CHECK-NEXT: %[[EXITCOND_PEEL:.+]] = icmp ne i64 1, %size
; CHECK-NEXT: br i1 %[[EXITCOND_PEEL]], label %[[PFOR_COND_AFTER_PEEL:.+]], label %pfor.cond.cleanup

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  detach within %syncreg, label %pfor.body, label %pfor.inc

; CHECK: pfor.cond.strpm.outer:
; CHECK: detach within %syncreg, label %pfor.body.strpm.outer, label %pfor.inc.strpm.outer

; CHECK: pfor.inc.strpm.outer:
; CHECK: br i1 %{{.+}}, label %{{.+}}  label %pfor.cond.strpm.outer

pfor.body:                                        ; preds = %pfor.cond
  %cmp3 = icmp eq i64 %__begin.0, 0
  br i1 %cmp3, label %if.then, label %if.else

if.then:                                          ; preds = %pfor.body
  %0 = load i64, i64* %data, align 8, !tbaa !3
  %mul4 = shl i64 %0, 2
  store i64 %mul4, i64* %data, align 8, !tbaa !3
  br label %pfor.preattach

if.else:                                          ; preds = %pfor.body
  %arrayidx5 = getelementptr inbounds i64, i64* %data, i64 %__begin.0
  %1 = load i64, i64* %arrayidx5, align 8, !tbaa !3
  %mul6 = shl i64 %1, 1
  store i64 %mul6, i64* %arrayidx5, align 8, !tbaa !3
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %if.then, %if.else
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.cond
  %inc = add nuw i64 %__begin.0, 1
  %exitcond = icmp ne i64 %inc, %size
  br i1 %exitcond, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !7

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %entry
  ret void
}

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #1

attributes #0 = { argmemonly norecurse nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nounwind willreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 14.0.5 (git@github.com:OpenCilk/opencilk-project.git b924d7dea48d317137eb07823b63f9c5fbfbf341)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"long", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = distinct !{!7, !8}
!8 = !{!"tapir.loop.spawn.strategy", i32 1}
