; RUN: opt < %s -passes="instcombine" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.timeval = type { i64, i64 }

@A = dso_local global [1024 x [1024 x double]] zeroinitializer, align 16
@B = dso_local global [1024 x [1024 x double]] zeroinitializer, align 16
@C = dso_local global [1024 x [1024 x double]] zeroinitializer, align 16
@.str = private unnamed_addr constant [7 x i8] c"%0.6f\0A\00", align 1

; Function Attrs: mustprogress nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fmuladd.f64(double, double, double) #1

; Function Attrs: nounwind uwtable
declare dso_local void @mmbase(double* noalias noundef %C, double* noundef %A, double* noundef %B, i32 noundef %size) local_unnamed_addr #0

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nounwind uwtable
define dso_local void @mmdac(double* noalias noundef %C, double* noundef %A, double* noundef %B, i32 noundef %size) local_unnamed_addr #0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg36 = call token @llvm.syncregion.start()
  %cmp = icmp sle i32 %size, 32
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  call void @mmbase(double* noundef %C, double* noundef %A, double* noundef %B, i32 noundef %size)
  br label %if.end

if.else:                                          ; preds = %entry
  %div = sdiv i32 %size, 2
  %mul = mul nsw i32 %div, 1024
  %mul3 = mul nsw i32 %div, 1025
  %0 = call token @llvm.tapir.runtime.start()
  %1 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.else
  call void @llvm.taskframe.use(token %1)
  call void @mmdac(double* noundef %C, double* noundef %A, double* noundef %B, i32 noundef %div)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.else
  %2 = call token @llvm.taskframe.create()
  %3 = zext i32 %div to i64
  %add.ptr10 = getelementptr inbounds double, double* %C, i64 %3
  %add.ptr14 = getelementptr inbounds double, double* %B, i64 %3
  detach within %syncreg, label %det.achd16, label %det.cont17

det.achd16:                                       ; preds = %det.cont
  call void @llvm.taskframe.use(token %2)
  call void @mmdac(double* noundef %add.ptr10, double* noundef %A, double* noundef %add.ptr14, i32 noundef %div)
  reattach within %syncreg, label %det.cont17

det.cont17:                                       ; preds = %det.achd16, %det.cont
  %4 = call token @llvm.taskframe.create()
  %idx.ext18 = sext i32 %mul to i64
  %add.ptr19 = getelementptr inbounds double, double* %C, i64 %idx.ext18
  %add.ptr21 = getelementptr inbounds double, double* %A, i64 %idx.ext18
  detach within %syncreg, label %det.achd25, label %det.cont26

det.achd25:                                       ; preds = %det.cont17
  call void @llvm.taskframe.use(token %4)
  call void @mmdac(double* noundef %add.ptr19, double* noundef %add.ptr21, double* noundef %B, i32 noundef %div)
  reattach within %syncreg, label %det.cont26

det.cont26:                                       ; preds = %det.achd25, %det.cont17
  %idx.ext27 = sext i32 %mul3 to i64
  %add.ptr28 = getelementptr inbounds double, double* %C, i64 %idx.ext27
  call void @mmdac(double* noundef %add.ptr28, double* noundef %add.ptr21, double* noundef %add.ptr14, i32 noundef %div)
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont26
  call void @llvm.tapir.runtime.end(token %0)
  %5 = call token @llvm.tapir.runtime.start()
  %6 = call token @llvm.taskframe.create()
  %add.ptr40 = getelementptr inbounds double, double* %A, i64 %3
  %add.ptr42 = getelementptr inbounds double, double* %B, i64 %idx.ext18
  detach within %syncreg36, label %det.achd44, label %det.cont45

; CHECK: %[[TRS1:.+]] = call token @llvm.tapir.runtime.start()

; CHECK: sync.continue:
; CHECK-NOT: call void @llvm.tapir.runtime.end($[[TRS1]])
; CHECK-NOT: call token @llvm.tapir.runtime.start()
; CHECK: detach within

det.achd44:                                       ; preds = %sync.continue
  call void @llvm.taskframe.use(token %6)
  call void @mmdac(double* noundef %C, double* noundef %add.ptr40, double* noundef %add.ptr42, i32 noundef %div)
  reattach within %syncreg36, label %det.cont45

det.cont45:                                       ; preds = %det.achd44, %sync.continue
  %7 = call token @llvm.taskframe.create()
  %add.ptr51 = getelementptr inbounds double, double* %B, i64 %idx.ext27
  detach within %syncreg36, label %det.achd53, label %det.cont54

det.achd53:                                       ; preds = %det.cont45
  call void @llvm.taskframe.use(token %7)
  call void @mmdac(double* noundef %add.ptr10, double* noundef %add.ptr40, double* noundef %add.ptr51, i32 noundef %div)
  reattach within %syncreg36, label %det.cont54

det.cont54:                                       ; preds = %det.achd53, %det.cont45
  %8 = call token @llvm.taskframe.create()
  %add.ptr58 = getelementptr inbounds double, double* %A, i64 %idx.ext27
  detach within %syncreg36, label %det.achd62, label %det.cont63

det.achd62:                                       ; preds = %det.cont54
  call void @llvm.taskframe.use(token %8)
  call void @mmdac(double* noundef %add.ptr19, double* noundef %add.ptr58, double* noundef %add.ptr42, i32 noundef %div)
  reattach within %syncreg36, label %det.cont63

det.cont63:                                       ; preds = %det.achd62, %det.cont54
  call void @mmdac(double* noundef %add.ptr28, double* noundef %add.ptr58, double* noundef %add.ptr51, i32 noundef %div)
  sync within %syncreg36, label %sync.continue73

sync.continue73:                                  ; preds = %det.cont63
  call void @llvm.tapir.runtime.end(token %5)
  br label %if.end

; CHECK: sync.continue73:
; CHECK: call void @llvm.tapir.runtime.end(token %[[TRS1]])

if.end:                                           ; preds = %sync.continue73, %if.then
  ret void
}

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.tapir.runtime.start() #3

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.taskframe.create() #3

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare void @llvm.taskframe.use(token) #3

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare void @llvm.tapir.runtime.end(token) #3

attributes #0 = { nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #3 = { argmemonly mustprogress nounwind willreturn }
attributes #4 = { nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nounwind }

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
!9 = distinct !{!9, !10, !11}
!10 = !{!"llvm.loop.mustprogress"}
!11 = !{!"llvm.loop.unroll.disable"}
!12 = distinct !{!12, !10, !11}
!13 = !{!14, !14, i64 0}
!14 = !{!"double", !6, i64 0}
!15 = distinct !{!15, !10, !11}
!16 = distinct !{!16, !10, !11}
!17 = distinct !{!17, !10, !11}
