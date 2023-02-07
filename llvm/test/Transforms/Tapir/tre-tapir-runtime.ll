; RUN: opt < %s -passes="tailcallelim" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress nounwind uwtable
define dso_local void @_Z12sample_qsortPiS_(i32* noundef %begin, i32* noundef %end) local_unnamed_addr #0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %cmp.not = icmp eq i32* %begin, %end
  br i1 %cmp.not, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %incdec.ptr = getelementptr inbounds i32, i32* %end, i64 -1
  %call = call noundef i32* @_Z9partitionPiS_(i32* noundef %begin, i32* noundef nonnull %incdec.ptr) #3
  call void @_Z4swapRiS_(i32* noundef nonnull align 4 dereferenceable(4) %incdec.ptr, i32* noundef nonnull align 4 dereferenceable(4) %call) #3
  %0 = call token @llvm.tapir.runtime.start()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.then
  call void @_Z12sample_qsortPiS_(i32* noundef %begin, i32* noundef nonnull %call)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.then
  %incdec.ptr1 = getelementptr inbounds i32, i32* %call, i64 1
  call void @_Z12sample_qsortPiS_(i32* noundef nonnull %incdec.ptr1, i32* noundef %end)
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  call void @llvm.tapir.runtime.end(token %0)
  br label %if.end

if.end:                                           ; preds = %sync.continue, %entry
  ret void
}

; CHECK: define {{.*}}void @_Z12sample_qsortPiS_(
; CHECK: tail call token @llvm.syncregion.start()
; CHECK-NEXT: br label %[[TAILRECURSE:.+]]
; CHECK: [[TAILRECURSE]]:
; CHECK-NOT: call token @llvm.tapir.runtime.start()
; CHECK: det.cont:
; CHECK: br label %[[TAILRECURSE]]
; CHECK-NOT: call void @llvm.tapir.runtime.end(token
; CHECK: sync within

declare dso_local noundef i32* @_Z9partitionPiS_(i32* noundef, i32* noundef) local_unnamed_addr #1

declare dso_local void @_Z4swapRiS_(i32* noundef nonnull align 4 dereferenceable(4), i32* noundef nonnull align 4 dereferenceable(4)) local_unnamed_addr #1

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.tapir.runtime.start() #2

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.taskframe.create() #2

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare void @llvm.taskframe.use(token) #2

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare void @llvm.tapir.runtime.end(token) #2

attributes #0 = { mustprogress nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { argmemonly mustprogress nounwind willreturn }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git f125821debd115939f9177c347e3780f27f4be03)"}
