; Check that inlining after Tapir lowering correctly propagates the stealable attribute
;
; RUN: opt < %s -passes="function<eager-inv>(simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),cgscc(devirt<4>(inline<only-mandatory>))" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.__cilkrts_stack_frame = type { i64 }

; Function Attrs: nounwind uwtable
define dso_local void @do_work() local_unnamed_addr #0 {
entry:
  tail call fastcc void @recur()
  ret void
}

; Function Attrs: alwaysinline nounwind stealable memory(readwrite, argmem: none, inaccessiblemem: none) uwtable
define internal fastcc void @recur() unnamed_addr #1 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  call void @__cilkrts_enter_frame(ptr %__cilkrts_sf)
  br label %tailrecurse

tailrecurse:                                      ; preds = %det.achd1, %entry
  %call = tail call zeroext i1 (...) @check() #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %tailrecurse
  %0 = call i32 @__cilk_prepare_spawn(ptr %__cilkrts_sf)
  %1 = icmp eq i32 %0, 0
  br i1 %1, label %if.then.split, label %det.achd1

if.then.split:                                    ; preds = %if.then
  call fastcc void @recur.outline_det.achd.otd1() #4
  br label %det.achd1

det.achd:                                         ; No predecessors!
  tail call fastcc void @recur()
  reattach within %syncreg, label %det.achd1

det.achd1:                                        ; preds = %if.then, %if.then.split, %det.achd
  br label %tailrecurse

if.end:                                           ; preds = %tailrecurse
  tail call void (...) @base() #4
  call void @__cilk_sync_nothrow(ptr %__cilkrts_sf)
  br label %return.split

return.split:                                     ; preds = %if.end
  call void @__cilk_parent_epilogue(ptr %__cilkrts_sf)
  ret void
}

; CHECK: define dso_local void @do_work() local_unnamed_addr #[[ATTRIBUTE:[0-9]+]]
; CHECK-NOT: call {{.*}}void @recur()
; CHECK: call {{.*}}void @recur.outline_det.achd.otd1()
; CHECK: ret void

; CHECK: define internal fastcc void @recur.outline_det.achd.otd1() unnamed_addr #[[ATTRIBUTE2:[0-9]+]]
; CHECK-NOT: call {{.*}}void @recur()
; CHECK: call {{.*}}void @recur.outline_det.achd.otd1()
; CHECK: ret void

; CHECK: attributes #[[ATTRIBUTE]] = {
; CHECK: stealable
; CHECK: }
; CHECK: attributes #[[ATTRIBUTE2]] = {
; CHECK: stealable
; CHECK: }

declare zeroext i1 @check(...) local_unnamed_addr #2

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #3

declare void @base(...) local_unnamed_addr #2

; Function Attrs: nounwind
declare void @__cilkrts_enter_frame(ptr) #4

; Function Attrs: nounwind
declare void @__cilkrts_enter_frame_helper(ptr) #4

; Function Attrs: nounwind
declare void @__cilkrts_detach(ptr) #4

; Function Attrs: nounwind
declare void @__cilkrts_leave_frame(ptr) #4

; Function Attrs: nounwind
declare void @__cilkrts_leave_frame_helper(ptr) #4

; Function Attrs: nounwind
declare i32 @__cilk_prepare_spawn(ptr) #4

; Function Attrs: nounwind
declare void @__cilk_sync_nothrow(ptr) #4

; Function Attrs: nounwind
declare void @__cilk_parent_epilogue(ptr) #4

; Function Attrs: nounwind
declare void @__cilk_helper_epilogue(ptr) #4

; Function Attrs: noinline nounwind memory(readwrite) uwtable
define internal fastcc void @recur.outline_det.achd.otd1() unnamed_addr #5 {
if.then.otd1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  call void @__cilkrts_enter_frame_helper(ptr %__cilkrts_sf)
  call void @__cilkrts_detach(ptr %__cilkrts_sf)
  br label %det.achd.otd1

det.achd.otd1:                                    ; preds = %if.then.otd1
  tail call fastcc void @recur()
  br label %det.achd1.otd1

det.achd1.otd1:                                   ; preds = %det.achd.otd1
  call void @__cilk_helper_epilogue(ptr %__cilkrts_sf)
  ret void
}

attributes #0 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { alwaysinline nounwind stealable memory(readwrite, argmem: none, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nounwind }
attributes #5 = { noinline nounwind memory(readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 16.0.6 (git@github.com:OpenCilk/opencilk-project.git aec81473380a60ff86b0fdc535600ff27fc1534a)"}
