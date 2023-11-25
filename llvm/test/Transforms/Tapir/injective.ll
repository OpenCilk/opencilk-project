; RUN: opt -O1 -S < %s | FileCheck %s
; ModuleID = 'injective.c'
; Check for alias analysis of hyperobject views and CSE of
; multiple calls to llvm.tapir.frame within a spindle.
source_filename = "injective.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-freebsd13.2"

@x = external dso_local global i32, align 4
@y = external dso_local global i32, align 4

; CHECK-LABEL: @alter
; Function Attrs: nounwind uwtable
define dso_local i32 @alter() #0 {
entry:
; One frame lookup remains.
; CHECK: %frame = notail call ptr @llvm.tapir.frame()
  %frame = notail call ptr @llvm.tapir.frame()
; CHECK: %viewx = notail call ptr @llvm.hyper.lookup.i64(ptr %frame, ptr hyper_view injective @x, i64 4, ptr nonnull @zero, ptr nonnull @plus)
  %viewx = notail call ptr @llvm.hyper.lookup.i64(ptr %frame, ptr hyper_view injective @x, i64 4, ptr nonnull @zero, ptr nonnull @plus)
; CHECK: %0 = load i32, ptr %viewx, align 4, !tbaa !4
  %0 = load i32, ptr %viewx, align 4, !tbaa !4
  %inc = add nsw i32 %0, 1
  store i32 %inc, ptr %viewx, align 4, !tbaa !4
  %1 = call ptr @llvm.tapir.frame()
; The frame lookups should have been CSE-ed.
; CHECK-NOT: call ptr @llvm.tapir.frame()
; CHECK: notail call ptr @llvm.hyper.lookup.i64(ptr %frame, ptr hyper_view injective @y, i64 4, ptr nonnull @zero, ptr nonnull @plus)
; CHECK-NOT: @llvm.tapir.frame()
; CHECK-NOT: @llvm.hyper.lookup.i64
  %viewy = notail call ptr @llvm.hyper.lookup.i64(ptr %1, ptr hyper_view injective @y, i64 4, ptr nonnull @zero, ptr nonnull @plus)
; CHECK: %yinit = load i32, ptr %viewy, align 4, !tbaa !4
  %yinit = load i32, ptr %viewy, align 4, !tbaa !4
; CHECK-NOT: load
; CHECK-NOT: @llvm.tapir.frame()
; CHECK-NOT: @llvm.hyper.lookup.i64
  %inc1 = add nsw i32 %yinit, 1
  store i32 %inc1, ptr %viewy, align 4, !tbaa !4
  %2 = call ptr @llvm.tapir.frame()
  %3 = notail call ptr @llvm.hyper.lookup.i64(ptr %2, ptr hyper_view injective @x, i64 4, ptr nonnull @zero, ptr nonnull @plus)
  %4 = load i32, ptr %3, align 4, !tbaa !4
  %5 = call ptr @llvm.tapir.frame()
  %6 = notail call ptr @llvm.hyper.lookup.i64(ptr %5, ptr hyper_view injective @y, i64 4, ptr nonnull @zero, ptr nonnull @plus)
  %7 = load i32, ptr %6, align 4, !tbaa !4
  %add = add nsw i32 %4, %7
; CHECK: ret i32 %add
  ret i32 %add
}

; Function Attrs: nounwind strand_pure willreturn memory(read)
declare ptr @llvm.tapir.frame() #1

; Function Attrs: nounwind strand_pure willreturn memory(inaccessiblemem: read)
declare ptr @llvm.hyper.lookup.i64(ptr, ptr align 1 injective, i64, ptr, ptr) #2

declare dso_local void @zero(ptr noundef) #3

declare dso_local void @plus(ptr noundef, ptr noundef) #3

attributes #0 = { nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind strand_pure willreturn memory(read) }
attributes #2 = { nounwind strand_pure willreturn memory(inaccessiblemem: read) }
attributes #3 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 2}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{!"clang version 16.0.6 (git@github.com:OpenCilk/opencilk-project.git 0ae760ffead5cd23cdd587da515c256f2c0570d6)"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
