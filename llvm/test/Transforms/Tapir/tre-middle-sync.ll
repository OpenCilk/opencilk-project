; RUN: opt < %s -passes="tailcallelim" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.timeval = type { i64, i64 }

@A = dso_local global [1024 x [1024 x double]] zeroinitializer, align 16
@B = dso_local global [1024 x [1024 x double]] zeroinitializer, align 16
@C = dso_local global [1024 x [1024 x double]] zeroinitializer, align 16
@.str = private unnamed_addr constant [7 x i8] c"%0.6f\0A\00", align 1

; Function Attrs: mustprogress nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fmuladd.f64(double, double, double) #1

; Function Attrs: argmemonly nofree nosync nounwind uwtable
declare dso_local void @mmbase(double* noalias nocapture noundef %C, double* nocapture noundef readonly %A, double* nocapture noundef readonly %B, i32 noundef %size) local_unnamed_addr #2

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: inaccessiblemem_or_argmemonly nounwind uwtable
define dso_local void @mmdac(double* noalias noundef %C, double* noundef %A, double* noundef %B, i32 noundef %size) local_unnamed_addr #4 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %cmp = icmp slt i32 %size, 33
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  call void @llvm.experimental.noalias.scope.decl(metadata !15)
  %cmp43.i = icmp sgt i32 %size, 0
  br i1 %cmp43.i, label %for.cond1.preheader.lr.ph.i, label %if.end

for.cond1.preheader.lr.ph.i:                      ; preds = %if.then
  %wide.trip.count59.i = zext i32 %size to i64
  br label %for.cond5.preheader.lr.ph.i

for.cond5.preheader.lr.ph.i:                      ; preds = %for.cond.cleanup3.i, %for.cond1.preheader.lr.ph.i
  %indvars.iv56.i = phi i64 [ 0, %for.cond1.preheader.lr.ph.i ], [ %indvars.iv.next57.i, %for.cond.cleanup3.i ]
  %0 = trunc i64 %indvars.iv56.i to i32
  %mul.i = shl nsw i32 %0, 10
  %1 = zext i32 %mul.i to i64
  br label %for.body8.lr.ph.i

for.body8.lr.ph.i:                                ; preds = %for.cond.cleanup7.i, %for.cond5.preheader.lr.ph.i
  %indvars.iv50.i = phi i64 [ 0, %for.cond5.preheader.lr.ph.i ], [ %indvars.iv.next51.i, %for.cond.cleanup7.i ]
  %2 = trunc i64 %indvars.iv50.i to i32
  %3 = add i32 %mul.i, %2
  %idxprom16.i = zext i32 %3 to i64
  %arrayidx17.i = getelementptr inbounds double, double* %C, i64 %idxprom16.i
  %arrayidx17.promoted.i = load double, double* %arrayidx17.i, align 8, !tbaa !9, !alias.scope !15
  br label %for.body8.i

for.cond.cleanup3.i:                              ; preds = %for.cond.cleanup7.i
  %indvars.iv.next57.i = add nuw nsw i64 %indvars.iv56.i, 1
  %exitcond60.not.i = icmp eq i64 %indvars.iv.next57.i, %wide.trip.count59.i
  br i1 %exitcond60.not.i, label %if.end, label %for.cond5.preheader.lr.ph.i, !llvm.loop !11

for.cond.cleanup7.i:                              ; preds = %for.body8.i
  store double %10, double* %arrayidx17.i, align 8, !tbaa !9, !alias.scope !15
  %indvars.iv.next51.i = add nuw nsw i64 %indvars.iv50.i, 1
  %exitcond55.not.i = icmp eq i64 %indvars.iv.next51.i, %wide.trip.count59.i
  br i1 %exitcond55.not.i, label %for.cond.cleanup3.i, label %for.body8.lr.ph.i, !llvm.loop !13

for.body8.i:                                      ; preds = %for.body8.i, %for.body8.lr.ph.i
  %indvars.iv.i = phi i64 [ 0, %for.body8.lr.ph.i ], [ %indvars.iv.next.i, %for.body8.i ]
  %4 = phi double [ %arrayidx17.promoted.i, %for.body8.lr.ph.i ], [ %10, %for.body8.i ]
  %5 = add nuw nsw i64 %indvars.iv.i, %1
  %arrayidx.i = getelementptr inbounds double, double* %A, i64 %5
  %6 = load double, double* %arrayidx.i, align 8, !tbaa !9, !noalias !15
  %7 = shl nsw i64 %indvars.iv.i, 10
  %8 = add nuw nsw i64 %7, %indvars.iv50.i
  %arrayidx12.i = getelementptr inbounds double, double* %B, i64 %8
  %9 = load double, double* %arrayidx12.i, align 8, !tbaa !9, !noalias !15
  %10 = call double @llvm.fmuladd.f64(double %6, double %9, double %4) #10
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.not.i = icmp eq i64 %indvars.iv.next.i, %wide.trip.count59.i
  br i1 %exitcond.not.i, label %for.cond.cleanup7.i, label %for.body8.i, !llvm.loop !14

if.else:                                          ; preds = %entry
  %div130 = lshr i32 %size, 1
  %mul = shl nsw i32 %div130, 10
  %mul3 = mul nsw i32 %div130, 1025
  detach within %syncreg, label %det.achd, label %det.cont.tf

det.achd:                                         ; preds = %if.else
  call void @mmdac(double* noundef %C, double* noundef %A, double* noundef %B, i32 noundef %div130)
  reattach within %syncreg, label %det.cont.tf

det.cont.tf:                                      ; preds = %if.else, %det.achd
  %11 = zext i32 %div130 to i64
  %add.ptr10 = getelementptr inbounds double, double* %C, i64 %11
  %add.ptr14 = getelementptr inbounds double, double* %B, i64 %11
  detach within %syncreg, label %det.achd16, label %det.cont17.tf

det.achd16:                                       ; preds = %det.cont.tf
  call void @mmdac(double* noundef %add.ptr10, double* noundef %A, double* noundef %add.ptr14, i32 noundef %div130)
  reattach within %syncreg, label %det.cont17.tf

det.cont17.tf:                                    ; preds = %det.cont.tf, %det.achd16
  %idx.ext18 = zext i32 %mul to i64
  %add.ptr19 = getelementptr inbounds double, double* %C, i64 %idx.ext18
  %add.ptr21 = getelementptr inbounds double, double* %A, i64 %idx.ext18
  detach within %syncreg, label %det.achd25, label %det.cont26

det.achd25:                                       ; preds = %det.cont17.tf
  call void @mmdac(double* noundef %add.ptr19, double* noundef %add.ptr21, double* noundef %B, i32 noundef %div130)
  reattach within %syncreg, label %det.cont26

det.cont26:                                       ; preds = %det.achd25, %det.cont17.tf
  %idx.ext27 = zext i32 %mul3 to i64
  %add.ptr28 = getelementptr inbounds double, double* %C, i64 %idx.ext27
  call void @mmdac(double* noundef %add.ptr28, double* noundef %add.ptr21, double* noundef %add.ptr14, i32 noundef %div130)
  sync within %syncreg, label %sync.continue.tf

sync.continue.tf:                                 ; preds = %det.cont26
  %add.ptr37 = getelementptr inbounds double, double* %A, i64 %11
  %add.ptr39 = getelementptr inbounds double, double* %B, i64 %idx.ext18
  detach within %syncreg, label %det.achd41, label %det.cont42.tf

det.achd41:                                       ; preds = %sync.continue.tf
  call void @mmdac(double* noundef %C, double* noundef %add.ptr37, double* noundef %add.ptr39, i32 noundef %div130)
  reattach within %syncreg, label %det.cont42.tf

det.cont42.tf:                                    ; preds = %sync.continue.tf, %det.achd41
  %add.ptr48 = getelementptr inbounds double, double* %B, i64 %idx.ext27
  detach within %syncreg, label %det.achd50, label %det.cont51.tf

det.achd50:                                       ; preds = %det.cont42.tf
  call void @mmdac(double* noundef %add.ptr10, double* noundef %add.ptr37, double* noundef %add.ptr48, i32 noundef %div130)
  reattach within %syncreg, label %det.cont51.tf

det.cont51.tf:                                    ; preds = %det.cont42.tf, %det.achd50
  %add.ptr55 = getelementptr inbounds double, double* %A, i64 %idx.ext27
  detach within %syncreg, label %det.achd59, label %det.cont60

det.achd59:                                       ; preds = %det.cont51.tf
  call void @mmdac(double* noundef %add.ptr19, double* noundef %add.ptr55, double* noundef %add.ptr39, i32 noundef %div130)
  reattach within %syncreg, label %det.cont60

det.cont60:                                       ; preds = %det.achd59, %det.cont51.tf
  call void @mmdac(double* noundef %add.ptr28, double* noundef %add.ptr55, double* noundef %add.ptr48, i32 noundef %div130)
  sync within %syncreg, label %if.end

; CHECK: det.cont60:
; CHECK: call void @mmdac
; CHECK-NOT: br label
; CHECK: sync within %syncreg

if.end:                                           ; preds = %for.cond.cleanup3.i, %if.then, %det.cont60
  ret void
}

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #5

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.taskframe.create() #5

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare void @llvm.taskframe.use(token) #5

; Function Attrs: inaccessiblememonly nofree nosync nounwind willreturn
declare void @llvm.experimental.noalias.scope.decl(metadata) #9

attributes #0 = { argmemonly mustprogress nofree nosync nounwind readonly uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nofree nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #4 = { inaccessiblemem_or_argmemonly nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { argmemonly mustprogress nounwind willreturn }
attributes #6 = { nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { inaccessiblememonly nofree nosync nounwind willreturn }
attributes #10 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git 5f6bec7c28155ec1f1ae0efebdb5cec40d39fda1)"}
!3 = !{!4, !5, i64 0}
!4 = !{!"timeval", !5, i64 0, !5, i64 8}
!5 = !{!"long", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = !{!4, !5, i64 8}
!9 = !{!10, !10, i64 0}
!10 = !{!"double", !6, i64 0}
!11 = distinct !{!11, !12}
!12 = !{!"llvm.loop.mustprogress"}
!13 = distinct !{!13, !12}
!14 = distinct !{!14, !12}
!15 = !{!16}
!16 = distinct !{!16, !17, !"mmbase: %C"}
!17 = distinct !{!17, !"mmbase"}
!18 = distinct !{!18, !12}
!19 = distinct !{!19, !12}
