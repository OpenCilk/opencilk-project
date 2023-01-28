; Check that loops with reducers can be vectorized (OpenCilk issue 157).
; RUN: opt -S < %s -passes='loop-mssa(tapir-indvars),loop-stripmine,loop-mssa(loop-simplifycfg,licm),loop-vectorize' -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-freebsd13.1"

; Function Attrs: nounwind uwtable
define dso_local i64 @sum_cilk_for_pointer(i64* noundef %begin, i64* noundef %end) local_unnamed_addr #0 {
entry:
  %sum = alloca i64, align 8
  %syncreg = call token @llvm.syncregion.start()
  %0 = bitcast i64* %sum to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %0) #6
  store i64 0, i64* %sum, align 8, !tbaa !4
  %1 = bitcast i64* %sum to i8*
  call void @llvm.reducer.register.i64(i8* nonnull %1, i64 8, i8* bitcast (void (i8*)* @zero to i8*), i8* bitcast (void (i8*, i8*)* @plus to i8*))
  %cmp.not = icmp eq i64* %begin, %end
  br i1 %cmp.not, label %pfor.end, label %pfor.ph

pfor.ph:                                          ; preds = %entry
  %sub.ptr.lhs.cast = ptrtoint i64* %end to i64
  %sub.ptr.rhs.cast = ptrtoint i64* %begin to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 3
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  %__begin.0 = phi i64 [ 0, %pfor.ph ], [ %inc, %pfor.inc ]
  %add.ptr = getelementptr inbounds i64, i64* %begin, i64 %__begin.0
  detach within %syncreg, label %pfor.body, label %pfor.inc

; CHECK: pfor.body
; CHECK: %[[DEST:.+]] = add <4 x i64> %[[SRC1:.+]], %[[SRC2:.+]]

pfor.body:                                        ; preds = %pfor.cond
  %2 = load i64, i64* %add.ptr, align 8, !tbaa !4
  %3 = bitcast i64* %sum to i8*
  %4 = call i8* @llvm.hyper.lookup(i8* nonnull %3, i64 8, i8* bitcast (void (i8*)* @zero to i8*), i8* bitcast (void (i8*, i8*)* @plus to i8*))
  %5 = bitcast i8* %4 to i64*
  %6 = load i64, i64* %5, align 8, !tbaa !4
  %add = add nsw i64 %6, %2
  store i64 %add, i64* %5, align 8, !tbaa !4
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %inc = add nuw nsw i64 %__begin.0, 1
  %cmp1.not = icmp eq i64 %sub.ptr.div, %inc
  br i1 %cmp1.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !8

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %pfor.end

pfor.end:                                         ; preds = %entry, %pfor.cond.cleanup
  %7 = bitcast i64* %sum to i8*
  %8 = call i8* @llvm.hyper.lookup(i8* nonnull %7, i64 8, i8* bitcast (void (i8*)* @zero to i8*), i8* bitcast (void (i8*, i8*)* @plus to i8*))
  %9 = bitcast i8* %8 to i64*
  %10 = load i64, i64* %9, align 8, !tbaa !4
  %11 = bitcast i64* %sum to i8*
  call void @llvm.reducer.unregister(i8* nonnull %11)
  %12 = bitcast i64* %sum to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %12) #6
  ret i64 %10
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind uwtable
define internal void @zero(i8* noundef %p) #0 {
entry:
  %0 = bitcast i8* %p to i64*
  store i64 0, i64* %0, align 8, !tbaa !4
  ret void
}

; Function Attrs: nounwind uwtable
define internal void @plus(i8* noundef %l, i8* noundef %r) #0 {
entry:
  %0 = bitcast i8* %r to i64*
  %1 = load i64, i64* %0, align 8, !tbaa !4
  %2 = bitcast i8* %l to i64*
  %3 = load i64, i64* %2, align 8, !tbaa !4
  %add = add nsw i64 %3, %1
  store i64 %add, i64* %2, align 8, !tbaa !4
  ret void
}

; Function Attrs: inaccessiblememonly mustprogress nounwind reducer_register willreturn
declare void @llvm.reducer.register.i64(i8*, i64, i8*, i8*) #2

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: hyper_view inaccessiblememonly injective mustprogress nofree nounwind readonly strand_pure willreturn
declare i8* @llvm.hyper.lookup(i8*, i64, i8*, i8*) #4

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: inaccessiblememonly mustprogress nounwind reducer_unregister willreturn
declare void @llvm.reducer.unregister(i8*) #5

attributes #0 = { nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { inaccessiblememonly mustprogress nounwind reducer_register willreturn }
attributes #3 = { argmemonly mustprogress nounwind willreturn }
attributes #4 = { hyper_view inaccessiblememonly injective mustprogress nofree nounwind readonly strand_pure willreturn }
attributes #5 = { inaccessiblememonly mustprogress nounwind reducer_unregister willreturn }
attributes #6 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git a854f9701cc2c293d2f3c2438c93f4196e199f96)"}
!4 = !{!5, !5, i64 0}
!5 = !{!"long", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = distinct !{!8, !9}
!9 = !{!"tapir.loop.spawn.strategy", i32 1}
