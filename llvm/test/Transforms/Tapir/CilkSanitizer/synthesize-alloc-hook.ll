; Check synthesis of alloc function hooks.
;
; RUN: opt < %s -passes="cilksan" -cilksan-bc-path=%S/null-bitcode.bc -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [2 x i8] c"a\00", align 1

; Function Attrs: mustprogress nofree nounwind sanitize_cilk willreturn memory(inaccessiblemem: readwrite) uwtable
define dso_local noalias noundef ptr @_Z8strdup_av() local_unnamed_addr #0 {
entry:
  %call = tail call noalias dereferenceable_or_null(2) ptr @strdup(ptr noundef nonnull @.str) #2
  ret ptr %call
}

; CHECK-LABEL: define dso_local noalias noundef ptr @_Z8strdup_av()
; CHECK: %[[CALL:.+]] = tail call noalias dereferenceable_or_null(2) ptr @strdup(ptr noundef nonnull @.str)
; CHECK-NEXT: call void @__csan_alloc_strdup(i64 %{{.*}}, i64 %{{.*}}, i8 0, i64 {{.*}}, ptr %[[CALL]], ptr @.str)
; CHECK: ret ptr %[[CALL]]

; CHECK-LABEL: define void @__csan_alloc_strdup(i64 %0, i64 %1, i8 %2, i64 %3, ptr %4, ptr %5)
; CHECK-NEXT: entry:
; CHECK-NEXT: call void @__csan_default_libhook(i64 %0, i64 %1, i8 %2)
; CHECK-NEXT: ret void

; Function Attrs: mustprogress nofree nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
declare noalias ptr @strdup(ptr nocapture noundef readonly) local_unnamed_addr #1

attributes #0 = { mustprogress nofree nounwind sanitize_cilk willreturn memory(inaccessiblemem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nofree nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 18.1.8 (git@github.com:neboat/opencilk-project.git c3cd84365e099ab6dfa4b484475ef66f33f16eab)"}
