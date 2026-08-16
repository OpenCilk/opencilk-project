; Check how a taskframe with a resume gets simplified.
;
; RUN: opt < %s -passes="function<eager-inv>(simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-hoist-loads-stores-with-cond-faulting;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>)" -S | FileCheck %s --check-prefixes=CHECK,CHECK-SIMPLIFYCFG
; RUN: opt < %s -passes="function<eager-inv>(task-simplify)" -S | FileCheck %s --check-prefixes=CHECK,CHECK-TASKSIMPLIFY
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.mytype = type { ptr }

$_ZN6mytypeC2ERKS_ = comdat any

$_ZN6mytypeD2Ev = comdat any

; Function Attrs: mustprogress uwtable
define dso_local void @_Z3bar6mytype(ptr noundef %bararg) #0 personality ptr @__gxx_personality_v0 {
entry:
  %bararg.indirect_addr = alloca ptr, align 8
  %syncreg = call token @llvm.syncregion.start()
  %exn.slot13 = alloca ptr, align 8
  %ehselector.slot14 = alloca i32, align 4
  store ptr %bararg, ptr %bararg.indirect_addr, align 8, !tbaa !5
  %0 = call token @llvm.taskframe.create()
  %agg.tmp = alloca %class.mytype, align 8
  %agg.tmp1 = alloca %class.mytype, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  call void @_ZN6mytypeC2ERKS_(ptr noundef nonnull align 8 dereferenceable(8) %agg.tmp, ptr noundef nonnull align 8 dereferenceable(8) %bararg)
  invoke void @_ZN6mytypeC2ERKS_(ptr noundef nonnull align 8 dereferenceable(8) %agg.tmp1, ptr noundef nonnull align 8 dereferenceable(8) %bararg)
          to label %invoke.cont unwind label %lpad

; SimplifyCFG should skip this taskframe, because it requires more complex logic to effectively inline.
; CHECK: %[[TF:.+]] = call token @llvm.taskframe.create()
; CHECK-SIMPLIFYCFG: detach within %syncreg, label %det.achd,
; CHECK-TASKSIMPLIFY-NOT: detach within

; CHECK: det.achd:
; CHECK-SIMPLIFYCFG: call void @llvm.taskframe.use(token %[[TF]])
; CHECK-TASKSIMPLIFY-NOT: call void @llvm.taskframe.use(
; CHECK: invoke void @_Z3foo6mytypeS_(

; CHECK-SIMPLIFYCFG: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF]]
; CHECK-TASKSIMPLIFY-NOT: invoke void @llvm.taskframe.resume.sl_p0i32s(

invoke.cont:                                      ; preds = %entry
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad7

det.achd:                                         ; preds = %invoke.cont
  %exn.slot3 = alloca ptr, align 8
  %ehselector.slot4 = alloca i32, align 4
  call void @llvm.taskframe.use(token %0)
  invoke void @_Z3foo6mytypeS_(ptr noundef %agg.tmp, ptr noundef %agg.tmp1)
          to label %invoke.cont5 unwind label %lpad2

invoke.cont5:                                     ; preds = %det.achd
  call void @_ZN6mytypeD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %agg.tmp1) #6
  call void @_ZN6mytypeD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %agg.tmp) #6
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %invoke.cont, %invoke.cont5
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  call void @llvm.sync.unwind(token %syncreg)
  ret void

lpad:                                             ; preds = %entry
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  store ptr %2, ptr %exn.slot, align 8
  %3 = extractvalue { ptr, i32 } %1, 1
  store i32 %3, ptr %ehselector.slot, align 4
  call void @_ZN6mytypeD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %agg.tmp) #6
  br label %ehcleanup

lpad2:                                            ; preds = %det.achd
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot3, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot4, align 4
  call void @_ZN6mytypeD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %agg.tmp1) #6
  call void @_ZN6mytypeD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %agg.tmp) #6
  %exn = load ptr, ptr %exn.slot3, align 8
  %sel = load i32, ptr %ehselector.slot4, align 4
  %lpad.val = insertvalue { ptr, i32 } undef, ptr %exn, 0
  %lpad.val6 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg, { ptr, i32 } %lpad.val6)
          to label %unreachable unwind label %lpad7

lpad7:                                            ; preds = %invoke.cont, %lpad2
  %7 = landingpad { ptr, i32 }
          cleanup
  %8 = extractvalue { ptr, i32 } %7, 0
  store ptr %8, ptr %exn.slot, align 8
  %9 = extractvalue { ptr, i32 } %7, 1
  store i32 %9, ptr %ehselector.slot, align 4
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad7, %lpad
  %exn8 = load ptr, ptr %exn.slot, align 8
  %sel9 = load i32, ptr %ehselector.slot, align 4
  %lpad.val10 = insertvalue { ptr, i32 } undef, ptr %exn8, 0
  %lpad.val11 = insertvalue { ptr, i32 } %lpad.val10, i32 %sel9, 1
  invoke void @llvm.taskframe.resume.sl_p0i32s(token %0, { ptr, i32 } %lpad.val11)
          to label %unreachable unwind label %lpad12

lpad12:                                           ; preds = %ehcleanup
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  store ptr %11, ptr %exn.slot13, align 8
  %12 = extractvalue { ptr, i32 } %10, 1
  store i32 %12, ptr %ehselector.slot14, align 4
  br label %eh.resume

eh.resume:                                        ; preds = %lpad12
  %exn15 = load ptr, ptr %exn.slot13, align 8
  %sel16 = load i32, ptr %ehselector.slot14, align 4
  %lpad.val17 = insertvalue { ptr, i32 } poison, ptr %exn15, 0
  %lpad.val18 = insertvalue { ptr, i32 } %lpad.val17, i32 %sel16, 1
  resume { ptr, i32 } %lpad.val18

unreachable:                                      ; preds = %ehcleanup, %lpad2
  unreachable
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #1

declare void @_Z3foo6mytypeS_(ptr noundef, ptr noundef) #2

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN6mytypeC2ERKS_(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr noundef nonnull align 8 dereferenceable(8) %other) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  store ptr %other, ptr %other.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noalias noundef nonnull ptr @_Znam(i64 noundef 32) #7
  %beg = getelementptr inbounds nuw %class.mytype, ptr %this1, i32 0, i32 0
  store ptr %call, ptr %beg, align 8, !tbaa !10
  ret void
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress nounwind uwtable
define linkonce_odr dso_local void @_ZN6mytypeD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this) unnamed_addr #3 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  ret void
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #4

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.resume.sl_p0i32s(token, { ptr, i32 }) #4

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #4

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znam(i64 noundef) #5

attributes #0 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { willreturn memory(argmem: readwrite) }
attributes #5 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nounwind }
attributes #7 = { builtin allocsize(0) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 21.1.3 (git@github.com:OpenCilk/opencilk-project.git b461e87c31a354376bdc710562f32f2ad899fa33)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"p1 _ZTS6mytype", !7, i64 0}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C++ TBAA"}
!10 = !{!11, !12, i64 0}
!11 = !{!"_ZTS6mytype", !12, i64 0}
!12 = !{!"p1 int", !7, i64 0}
