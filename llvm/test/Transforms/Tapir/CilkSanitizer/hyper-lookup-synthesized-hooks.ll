; Check synthesis of hooks for hyper.lookup calls.
;
; RUN: opt < %s -passes="cilksan" -cilksan-bc-path=%S/null-bitcode.bc -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$_Z8sum_initIdEvPv = comdat any

$_Z10sum_reduceIdEvPvS0_ = comdat any

; Function Attrs: mustprogress sanitize_cilk uwtable
define dso_local void @_Z3runv() local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %sumAParRelError = alloca double, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %sumAParRelError) #7
  store double 0.000000e+00, ptr %sumAParRelError, align 8, !tbaa !5
  call void @llvm.reducer.register.i64(ptr nonnull %sumAParRelError, i64 8, ptr nonnull @_Z8sum_initIdEvPv, ptr nonnull @_Z10sum_reduceIdEvPvS0_)
  %0 = call ptr @llvm.hyper.lookup.i64(ptr nonnull %sumAParRelError, i64 8, ptr nonnull @_Z8sum_initIdEvPv, ptr nonnull @_Z10sum_reduceIdEvPvS0_)
  %1 = load double, ptr %0, align 8, !tbaa !5
  invoke void @_Z1hd(double noundef %1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %2 = call ptr @llvm.hyper.lookup.i64(ptr nonnull %sumAParRelError, i64 8, ptr nonnull @_Z8sum_initIdEvPv, ptr nonnull @_Z10sum_reduceIdEvPvS0_)
  %3 = load double, ptr %2, align 8, !tbaa !5
  invoke void @_Z1hd(double noundef %3)
          to label %invoke.cont1 unwind label %lpad

invoke.cont1:                                     ; preds = %invoke.cont
  call void @llvm.reducer.unregister(ptr nonnull %sumAParRelError)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %sumAParRelError) #7
  ret void

lpad:                                             ; preds = %invoke.cont, %entry
  %4 = landingpad { ptr, i32 }
          cleanup
  call void @llvm.reducer.unregister(ptr nonnull %sumAParRelError)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %sumAParRelError) #7
  resume { ptr, i32 } %4
}

; Check insertion of __csan_llvm_hyper_lookup calls and use of their return values.

; CHECK: define dso_local void @_Z3runv()

; CHECK: %[[HYPER_LOOKUP:.+]] = call ptr @llvm.hyper.lookup.i64(ptr nonnull %sumAParRelError
; CHECK: %[[CSAN_HYPER_LOOKUP:.+]] = call {{.*}}ptr @__csan_llvm_hyper_lookup_i64(i64 %{{.*}}, i64 %{{.*}}, i8 3, i64 0, ptr %[[HYPER_LOOKUP]],
; CHECK: call void @__csan_load(i64 %{{.*}}, ptr %[[CSAN_HYPER_LOOKUP]],
; CHECK-NEXT: %[[VIEW_LOAD:.+]] = load double, ptr %[[CSAN_HYPER_LOOKUP]]

; CHECK: invoke void @_Z1hd(double noundef %[[VIEW_LOAD]])

; CHECK: %[[HYPER_LOOKUP_2:.+]] = call ptr @llvm.hyper.lookup.i64(ptr nonnull %sumAParRelError
; CHECK: %[[CSAN_HYPER_LOOKUP_2:.+]] = call {{.*}}ptr @__csan_llvm_hyper_lookup_i64(i64 %{{.*}}, i64 %{{.*}}, i8 3, i64 0, ptr %[[HYPER_LOOKUP_2]],
; CHECK: call void @__csan_load(i64 %{{.*}}, ptr %[[CSAN_HYPER_LOOKUP_2]],
; CHECK-NEXT: %[[VIEW_LOAD_2:.+]] = load double, ptr %[[CSAN_HYPER_LOOKUP_2]]

; CHECK: invoke void @_Z1hd(double noundef %[[VIEW_LOAD_2]])


; Check that synthesized __csan_llvm_hyper_lookup function simply calls the default hook and returns the return-value parameter.

; CHECK: define {{.*}}ptr @__csan_llvm_hyper_lookup_i64(i64 %0, i64 %1, i8 %2, i64 %3, ptr %4, ptr %5, i64 %6, ptr %7, ptr %8)
; CHECK-NEXT: entry:
; CHECK-NEXT: call {{.*}}void @__csan_default_libhook(i64 %0, i64 %1, i8 %2)
; CHECK-NEXT: ret ptr %4
; CHECK-NEXT: }

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_Z8sum_initIdEvPv(ptr noundef %v) #2 comdat {
entry:
  store double 0.000000e+00, ptr %v, align 8, !tbaa !5
  ret void
}

; Function Attrs: mustprogress nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_Z10sum_reduceIdEvPvS0_(ptr noundef %v, ptr noundef %v2) #2 comdat {
entry:
  %0 = load double, ptr %v2, align 8, !tbaa !5
  %1 = load double, ptr %v, align 8, !tbaa !5
  %add = fadd double %0, %1
  store double %add, ptr %v, align 8, !tbaa !5
  ret void
}

; Function Attrs: mustprogress nounwind reducer_register willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.reducer.register.i64(ptr, i64, ptr, ptr) #3

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress nounwind reducer_unregister willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.reducer.unregister(ptr) #4

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

declare void @_Z1hd(double noundef) local_unnamed_addr #5

; Function Attrs: hyper_view injective mustprogress nofree nounwind strand_pure willreturn memory(inaccessiblemem: read)
declare ptr @llvm.hyper.lookup.i64(ptr, i64, ptr, ptr) #6

attributes #0 = { mustprogress sanitize_cilk uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nounwind sanitize_cilk uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nounwind reducer_register willreturn memory(inaccessiblemem: readwrite) }
attributes #4 = { mustprogress nounwind reducer_unregister willreturn memory(inaccessiblemem: readwrite) }
attributes #5 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { hyper_view injective mustprogress nofree nounwind strand_pure willreturn memory(inaccessiblemem: read) }
attributes #7 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 18.1.8 (git@github.com:neboat/opencilk-project.git c3cd84365e099ab6dfa4b484475ef66f33f16eab)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"double", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
