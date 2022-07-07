; Check that SROA preserves the atomicity of loads and stores on an atomic bool.
;
; RUN: opt < %s -passes='sroa' -S | FileCheck %s --check-prefix=SROA
; RUN: opt < %s -passes='sroa,tapir-indvars,loop-stripmine,loop-mssa(licm)' -S | FileCheck %s --check-prefix=LICM
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"struct.std::__atomic_base" = type { i8 }

; Function Attrs: mustprogress uwtable
define dso_local noundef i32 @_Z4testi(i32 noundef %n) local_unnamed_addr #0 personality i32 (...)* @__gxx_personality_v0 {
entry:
  %stop = alloca %"struct.std::atomic", align 1
  %syncreg = call token @llvm.syncregion.start()
  %syncreg26 = call token @llvm.syncregion.start()
  %conv = sext i32 %n to i64
  %call = call noalias i8* @malloc(i64 noundef %conv) #7
  %call3 = call noalias i8* @malloc(i64 noundef %conv) #7
  br label %for.cond

; SROA: entry:
; SROA-NOT: %stop = alloca %"struct.std::atomic", align 1
; SROA: %stop.sroa.0 = alloca i8, align 1
; SROA: br label %for.cond

for.cond:                                         ; preds = %for.body, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i.0, %n
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  %0 = getelementptr inbounds %"struct.std::atomic", %"struct.std::atomic"* %stop, i64 0, i32 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %0) #7
  br label %do.body

for.body:                                         ; preds = %for.cond
  %idxprom = zext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds i8, i8* %call, i64 %idxprom
  store i8 0, i8* %arrayidx, align 1, !tbaa !3
  %arrayidx5 = getelementptr inbounds i8, i8* %call3, i64 %idxprom
  store i8 0, i8* %arrayidx5, align 1, !tbaa !3
  %inc = add nuw nsw i32 %i.0, 1
  br label %for.cond, !llvm.loop !7

do.body:                                          ; preds = %cleanup66, %for.cond.cleanup
  %k.0 = phi i32 [ 0, %for.cond.cleanup ], [ %inc69, %cleanup66 ]
  %_M_i.i.i.i = getelementptr inbounds %"struct.std::atomic", %"struct.std::atomic"* %stop, i64 0, i32 0, i32 0
  store atomic i8 0, i8* %_M_i.i.i.i seq_cst, align 1
  %cmp7 = icmp sgt i32 %n, 0
  br i1 %cmp7, label %pfor.cond, label %cleanup66

; SROA: do.body:
; SROA-NOT: store i8 0, i8* %stop.sroa.0
; SROA: store atomic i8 0, i8* %stop.sroa.0 seq_cst

pfor.cond:                                        ; preds = %do.body, %pfor.inc
  %__begin.0 = phi i32 [ %inc23, %pfor.inc ], [ 0, %do.body ]
  detach within %syncreg26, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %idxprom12 = zext i32 %__begin.0 to i64
  %arrayidx13 = getelementptr inbounds i8, i8* %call, i64 %idxprom12
  %1 = load i8, i8* %arrayidx13, align 1, !tbaa !3, !range !9
  %tobool.not = icmp eq i8 %1, 0
  br i1 %tobool.not, label %pfor.preattach, label %if.then

if.then:                                          ; preds = %pfor.body
  store i8 0, i8* %arrayidx13, align 1, !tbaa !3
  %call18 = call noundef zeroext i1 @_Z3fooi(i32 noundef %__begin.0)
  br i1 %call18, label %if.then19, label %pfor.preattach

if.then19:                                        ; preds = %if.then
  %arrayidx21 = getelementptr inbounds i8, i8* %call3, i64 %idxprom12
  store i8 1, i8* %arrayidx21, align 1, !tbaa !3
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %pfor.body, %if.then19, %if.then
  reattach within %syncreg26, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.cond
  %inc23 = add nuw nsw i32 %__begin.0, 1
  %cmp24 = icmp slt i32 %inc23, %n
  br i1 %cmp24, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !10

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg26, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg26)
  br i1 %cmp7, label %pfor.cond38, label %cleanup66

pfor.cond38:                                      ; preds = %sync.continue, %pfor.inc58
  %__begin32.0 = phi i32 [ %inc59, %pfor.inc58 ], [ 0, %sync.continue ]
  detach within %syncreg26, label %pfor.body44, label %pfor.inc58

pfor.body44:                                      ; preds = %pfor.cond38
  %idxprom45 = zext i32 %__begin32.0 to i64
  %arrayidx46 = getelementptr inbounds i8, i8* %call3, i64 %idxprom45
  %2 = load i8, i8* %arrayidx46, align 1, !tbaa !3, !range !9
  %tobool47.not = icmp eq i8 %2, 0
  br i1 %tobool47.not, label %pfor.preattach57, label %if.then50

if.then50:                                        ; preds = %pfor.body44
  %arrayidx52 = getelementptr inbounds i8, i8* %call, i64 %idxprom45
  store i8 1, i8* %arrayidx52, align 1, !tbaa !3
  %_M_i.i.i.i120 = getelementptr inbounds %"struct.std::atomic", %"struct.std::atomic"* %stop, i64 0, i32 0, i32 0
  store atomic i8 1, i8* %_M_i.i.i.i120 seq_cst, align 1
  store i8 0, i8* %arrayidx46, align 1, !tbaa !3
  br label %pfor.preattach57

; SROA: if.then50:
; SROA-NOT: store i8 1, i8* %stop.sroa.0
; SROA: store atomic i8 1, i8* %stop.sroa.0 seq_cst
; SROA: br label %pfor.preattach57

; LICM: if.then50:
; LICM: store atomic i8 1, i8* %stop.sroa.0 seq_cst
; LICM: br label %pfor.preattach57

; LICM: pfor.preattach57:
; LICM-NOT: phi i8
; LICM-NOT: store i8 %{{.+}}, i8* %stop.sroa.0
; LICM: reattach within %{{.+}}, label

; LICM: if.then50.epil:
; LICM: store atomic i8 1, i8* %stop.sroa.0 seq_cst
; LICM: br label %pfor.preattach57.epil

; LICM: pfor.preattach57.epil:
; LICM-NOT: phi i8
; LICM-NOT: store i8 %{{.+}}, i8* %stop.sroa.0
; LICM: sync within %{{.+}}, label

pfor.preattach57:                                 ; preds = %pfor.body44, %if.then50
  reattach within %syncreg26, label %pfor.inc58

pfor.inc58:                                       ; preds = %pfor.preattach57, %pfor.cond38
  %inc59 = add nuw nsw i32 %__begin32.0, 1
  %cmp60 = icmp slt i32 %inc59, %n
  br i1 %cmp60, label %pfor.cond38, label %pfor.cond.cleanup61, !llvm.loop !12

pfor.cond.cleanup61:                              ; preds = %pfor.inc58
  sync within %syncreg26, label %sync.continue63

sync.continue63:                                  ; preds = %pfor.cond.cleanup61
  call void @llvm.sync.unwind(token %syncreg26)
  br label %cleanup66

cleanup66:                                        ; preds = %do.body, %sync.continue, %sync.continue63
  %inc69 = add nuw nsw i32 %k.0, 1
  %_M_i.i.i = getelementptr inbounds %"struct.std::atomic", %"struct.std::atomic"* %stop, i64 0, i32 0, i32 0
  %3 = load atomic i8, i8* %_M_i.i.i acquire, align 1
  %4 = and i8 %3, 1
  %tobool.i.i = icmp ne i8 %4, 0
  br i1 %tobool.i.i, label %do.body, label %do.end, !llvm.loop !13

; SROA: cleanup66:
; SROA-NOT: load i8, i8* %stop.sroa.0
; SROA: load atomic i8, i8* %stop.sroa.0 acquire
; SROA: br i1 %tobool.i.i, label %do.body, label %do.end

do.end:                                           ; preds = %cleanup66
  call void @free(i8* noundef %call) #7
  call void @free(i8* noundef %call3) #7
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %0) #7
  ret i32 %inc69
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare dso_local noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #2

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #3

declare dso_local noundef zeroext i1 @_Z3fooi(i32 noundef) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress willreturn
declare void @llvm.sync.unwind(token) #5

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare dso_local void @free(i8* nocapture noundef) local_unnamed_addr #6

declare dso_local i32 @__gxx_personality_v0(...)

attributes #0 = { mustprogress uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { inaccessiblememonly mustprogress nofree nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { argmemonly mustprogress nounwind willreturn }
attributes #4 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { argmemonly mustprogress willreturn }
attributes #6 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 14.0.5 (git@github.com:OpenCilk/opencilk-project.git 528c971c56ac75f41a19857be8641e8aee7f09f9)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"bool", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = distinct !{!7, !8}
!8 = !{!"llvm.loop.mustprogress"}
!9 = !{i8 0, i8 2}
!10 = distinct !{!10, !11}
!11 = !{!"tapir.loop.spawn.strategy", i32 1}
!12 = distinct !{!12, !11}
!13 = distinct !{!13, !8}
