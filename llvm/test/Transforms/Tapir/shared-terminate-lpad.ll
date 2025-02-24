; Check that shared terminate landingpads are outlined properly.
;
; RUN: opt < %s -passes="tapir2target" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$__clang_call_terminate = comdat any

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define dso_local void @_Z1gv() #0 personality ptr @__gxx_personality_v0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %0 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %0)
  %call = invoke noundef i32 @_Z1fv()
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %det.achd
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %invoke.cont, %entry
  br label %while.cond

while.cond:                                       ; preds = %det.cont6, %det.cont
  %call2 = invoke noundef zeroext i1 @_Z4morev()
          to label %invoke.cont1 unwind label %terminate.lpad

invoke.cont1:                                     ; preds = %while.cond
  br i1 %call2, label %while.body, label %while.end

while.body:                                       ; preds = %invoke.cont1
  %1 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd3, label %det.cont6

det.achd3:                                        ; preds = %while.body
  call void @llvm.taskframe.use(token %1)
  %call5 = invoke noundef i32 @_Z1fv()
          to label %invoke.cont4 unwind label %terminate.lpad

invoke.cont4:                                     ; preds = %det.achd3
  reattach within %syncreg, label %det.cont6

det.cont6:                                        ; preds = %invoke.cont4, %while.body
  br label %while.cond, !llvm.loop !6

while.end:                                        ; preds = %invoke.cont1
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %while.end
  ret void

terminate.lpad:                                   ; preds = %det.achd3, %while.cond, %det.achd
  %2 = landingpad { ptr, i32 }
          catch ptr null
  %3 = extractvalue { ptr, i32 } %2, 0
  call void @__clang_call_terminate(ptr %3) #4
  unreachable
}

; CHECK-LABEL: define {{.*}}void @_Z1gv()
; CHECK: terminate.lpad:
; CHECK-NEXT: %[[LPAD:.+]] = landingpad
; CHECK-NEXT: catch ptr null
; CHECK: call void @__cilkrts_enter_landingpad(ptr
; CHECK-NEXT: %[[EXTRACTED:.+]] = extractvalue { ptr, i32 } %[[LPAD]]
; CHECK-NEXT: call void @__clang_call_terminate(ptr %[[EXTRACTED]])
; CHECK-NEXT: unreachable

; CHECK-LABEL: define {{.*}}void @_Z1gv.outline_entry.tf.otd1(ptr %{{.+}})
; CHECK: invoke {{.*}}i32 @_Z1fv()
; CHECK-NEXT: to label %{{.+}} unwind label %[[TERMINATE_LPAD:.+]]

; CHECK: [[TERMINATE_LPAD]]:
; CHECK-NEXT: %[[LPAD:.+]] = landingpad
; CHECK-NEXT: catch ptr null
; CHECK-NEXT: %[[EXTRACTED:.+]] = extractvalue { ptr, i32 } %[[LPAD]]
; CHECK-NEXT: call void @__clang_call_terminate(ptr %[[EXTRACTED]])
; CHECK-NEXT: unreachable

; CHECK-LABEL: define {{.*}}void @_Z1gv.outline_while.body.tf.otd1(ptr %{{.+}})
; CHECK: invoke {{.*}}i32 @_Z1fv()
; CHECK-NEXT: to label %{{.+}} unwind label %[[TERMINATE_LPAD:.+]]

; CHECK: [[TERMINATE_LPAD]]:
; CHECK-NEXT: %[[LPAD:.+]] = landingpad
; CHECK-NEXT: catch ptr null
; CHECK-NEXT: %[[EXTRACTED:.+]] = extractvalue { ptr, i32 } %[[LPAD]]
; CHECK-NEXT: call void @__clang_call_terminate(ptr %[[EXTRACTED]])
; CHECK-NEXT: unreachable

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #1

declare noundef i32 @_Z1fv() #2

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #1

declare i32 @__gxx_personality_v0(...)

; Function Attrs: noinline noreturn nounwind uwtable
define linkonce_odr hidden void @__clang_call_terminate(ptr noundef %0) #3 comdat {
  %2 = call ptr @__cxa_begin_catch(ptr %0) #5
  call void @_ZSt9terminatev() #4
  unreachable
}

declare ptr @__cxa_begin_catch(ptr)

declare void @_ZSt9terminatev()

declare noundef zeroext i1 @_Z4morev() #2

attributes #0 = { mustprogress noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { noinline noreturn nounwind uwtable "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { noreturn nounwind }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 19.1.7 (git@github.com:OpenCilk/opencilk-project.git d752b94c9e89c4705498985f4325fc7e126492ba)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
