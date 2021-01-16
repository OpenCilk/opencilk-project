; RUN: llc < %s -mtriple=x86_64-unknown-freebsd13.0 -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-freebsd13.0"

; Function Attrs: noreturn nounwind uwtable
define dso_local void @go([5 x i8*]* nocapture %in) local_unnamed_addr #0 {
; CHECK-LABEL: go:
entry:
  %tmp = alloca [5 x i8*], align 16
  %0 = bitcast [5 x i8*]* %tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %0) #4
  %1 = bitcast [5 x i8*]* %in to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(40) %0, i8* nonnull align 8 dereferenceable(40) %1, i64 40, i1 false)
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 dereferenceable(40) %1, i8 -35, i64 40, i1 false)
; CHECK-NOT: (%rbp), %rbp
  call void @llvm.eh.sjlj.longjmp(i8* nonnull %0)
  unreachable
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: noreturn nounwind
declare void @llvm.eh.sjlj.longjmp(i8*) #3

attributes #0 = { noreturn nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { noreturn nounwind }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"FreeBSD clang version 11.0.0 (git@github.com:llvm/llvm-project.git llvmorg-11.0.0-0-g176249bd673)"}
