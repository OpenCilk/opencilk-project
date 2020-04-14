; Test inliner when the caller or callee contain Tapir tasks and when
; the caller or callee contains landingpads.
;
; RUN: opt < %s -inline -S -o - | FileCheck %s
; RUN: opt < %s -passes='inline' -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@_ZTIc = external dso_local constant i8*
@_ZTIi = external dso_local constant i8*

; Function Attrs: uwtable
define dso_local void @_Z8pitcher1i(i32 %a) local_unnamed_addr #8 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %exception = tail call i8* @__cxa_allocate_exception(i64 4) #5
  %0 = bitcast i8* %exception to i32*
  store i32 %a, i32* %0, align 16, !tbaa !2
  invoke void @__cxa_throw(i8* %exception, i8* bitcast (i8** @_ZTIi to i8*), i8* null) #6
          to label %unreachable unwind label %lpad

lpad:                                             ; preds = %entry
  %1 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIc to i8*)
  %2 = extractvalue { i8*, i32 } %1, 1
  %3 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIc to i8*)) #5
  %matches = icmp eq i32 %2, %3
  br i1 %matches, label %catch, label %eh.resume

catch:                                            ; preds = %lpad
  %4 = extractvalue { i8*, i32 } %1, 0
  %5 = tail call i8* @__cxa_begin_catch(i8* %4) #5
  %6 = load i8, i8* %5, align 1, !tbaa !6
  tail call void @_Z7catch_cc(i8 signext %6) #5
  tail call void @__cxa_end_catch() #5
  ret void

eh.resume:                                        ; preds = %lpad
  resume { i8*, i32 } %1

unreachable:                                      ; preds = %entry
  unreachable
}

declare dso_local i8* @__cxa_allocate_exception(i64) local_unnamed_addr

declare dso_local void @__cxa_throw(i8*, i8*, i8*) local_unnamed_addr

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind readnone
declare i32 @llvm.eh.typeid.for(i8*) #1

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

; Function Attrs: nounwind
declare dso_local void @_Z7catch_cc(i8 signext) local_unnamed_addr #2

declare dso_local void @__cxa_end_catch() local_unnamed_addr

; Function Attrs: uwtable
define dso_local void @_Z20inline_try_into_taski(i32 %a) local_unnamed_addr #0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %entry
  tail call void @llvm.taskframe.use(token %0)
  tail call void @_Z8pitcher1i(i32 %a)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %entry
  tail call void @_Z7nothrowv() #5
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  ret void
}

;;; Test inlining of functions with landingpads into spawned tasks.

; CHECK-LABEL: define {{.*}}void @_Z20inline_try_into_taski(i32
; CHECK: %[[TASKFRAME:.+]] = tail call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[DETUNWIND:.+]]

; CHECK: [[DETACHED]]:
; CHECK-NEXT: tail call void @llvm.taskframe.use(token %[[TASKFRAME]])
; CHECK: invoke void @__cxa_throw(
; CHECK-NEXT: to label %[[UNREACHABLEI:.+]] unwind label %[[LPADI:.+]]

; CHECK: [[LPADI]]:
; CHECK-NEXT: %[[LPADVAL:.+]] = landingpad [[LPADTYPE:{.+}]]
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIc to i8*)
; CHECK: br i1 %{{.+}}, label %[[EXITI:.+]], label %[[RESUMEI:.+]]

; CHECK: [[RESUMEI]]:
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]], [[LPADTYPE]] %[[LPADVAL]])
; CHECK-NEXT: to label %[[NEWUNREACHABLE:.+]] unwind label %[[DETUNWIND]]

; CHECK: [[DETUNWIND]]:
; CHECK-NEXT: %[[LPADVALSPLIT:.+]] = landingpad [[LPADTYPE]]
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]], [[LPADTYPE]] %[[LPADVALSPLIT]])
; CHECK-NEXT: to label %[[NEWUNREACHABLE]] unwind label %[[RESUMEISPLITSPLIT:.+]]

; CHECK: [[RESUMEISPLITSPLIT]]:
; CHECK-NEXT: %[[LPADVALSPLITSPLIT:.+]] = landingpad [[LPADTYPE]]
; CHECK-NEXT: cleanup
; CHECK-NEXT: resume [[LPADTYPE]] %[[LPADVALSPLITSPLIT]]

; CHECK: [[UNREACHABLEI]]:
; CHECK-NEXT: unreachable

; CHECK: [[NEWUNREACHABLE]]
; CHECK-NEXT: unreachable

; CHECK: [[EXITI]]:
; CHECK: reattach within %[[SYNCREG]], label %[[CONTINUE]]

; CHECK: [[CONTINUE]]:
; CHECK-NEXT: tail call void @_Z7nothrowv()
; CHECK-NEXT: sync within %[[SYNCREG]],

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #3

; Function Attrs: argmemonly nounwind
declare token @llvm.taskframe.create() #3

; Function Attrs: argmemonly nounwind
declare void @llvm.taskframe.use(token) #3

; Function Attrs: nounwind
declare dso_local void @_Z7nothrowv() local_unnamed_addr #2

; Function Attrs: uwtable
define dso_local void @_Z13spawn_pitcheri(i32 %a) local_unnamed_addr #8 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %entry
  tail call void @llvm.taskframe.use(token %0)
  tail call void @_Z8pitcher2i(i32 %a)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %entry
  tail call void @_Z7nothrowv() #5
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  ret void
}

declare dso_local void @_Z8pitcher2i(i32) local_unnamed_addr #4

; Function Attrs: uwtable
define dso_local void @_Z20inline_task_into_tryi(i32 %a) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_Z13spawn_pitcheri(i32 %a)
          to label %try.cont unwind label %lpad

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %1 = extractvalue { i8*, i32 } %0, 1
  %2 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #5
  %matches = icmp eq i32 %1, %2
  br i1 %matches, label %catch, label %eh.resume

catch:                                            ; preds = %lpad
  %3 = extractvalue { i8*, i32 } %0, 0
  %4 = tail call i8* @__cxa_begin_catch(i8* %3) #5
  %5 = bitcast i8* %4 to i32*
  %6 = load i32, i32* %5, align 4, !tbaa !2
  tail call void @_Z7catch_ii(i32 %6) #5
  tail call void @__cxa_end_catch() #5
  br label %try.cont

try.cont:                                         ; preds = %entry, %catch
  ret void

eh.resume:                                        ; preds = %lpad
  resume { i8*, i32 } %0
}

;;; Test inlining of tasks at invokes (function calls that have unwinds).

; CHECK-LABEL: define {{.*}}void @_Z20inline_task_into_tryi(
; CHECK: i32 %a)
; CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[DETUNWIND:.+]]

; CHECK: [[DETACHED]]:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
; CHECK-NEXT: invoke void @_Z8pitcher2i(i32 %a)
; CHECK-NEXT: to label %[[NOEXC:.+]] unwind label %[[TASKLPAD:.+]]

; CHECK: [[NOEXC]]:
; CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

; CHECK: [[CONTINUE]]:
; CHECK-NEXT: call void @_Z7nothrowv()
; CHECK-NEXT: sync within %[[SYNCREG]], label %[[EXITI:.+]]

; CHECK: [[NEWUNREACHABLE:.+]]:
; CHECK-NEXT: unreachable

; CHECK: [[DETUNWIND]]:
; CHECK-NEXT: %[[TFLPADVAL:.+]] = landingpad [[LPADTYPE:{.+}]]
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]], [[LPADTYPE]] %[[TFLPADVAL]])
; CHECK-NEXT: to label %[[NEWUNREACHABLE]] unwind label %[[LPAD:.+]]

; CHECK: [[TASKLPAD]]:
; CHECK-NEXT: %[[TASKLPADVAL:.+]] = landingpad [[LPADTYPE]]
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]], [[LPADTYPE]] %[[TASKLPADVAL]])
; CHECK-NEXT: to label %[[NEWUNREACHABLE]] unwind label %[[DETUNWIND]]

; CHECK: [[EXITI]]:
; CHECK-NEXT: br label %[[TRYCONT:.+]]

; CHECK: [[LPAD]]:
; CHECK-NEXT: %[[LPADVAL:.+]] = landingpad [[LPADTYPE]]
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: br i1 %{{.+}}, label %[[CATCH:.+]], label %[[RESUME:.+]]

; CHECK: [[CATCH]]:
; CHECK: br label %[[TRYCONT]]

; CHECK: [[TRYCONT]]:
; CHECK-NEXT: ret void

; CHECK: [[RESUME]]:
; CHECK-NEXT: resume [[LPADTYPE]] %[[LPADVAL]]

; Function Attrs: nounwind
declare dso_local void @_Z7catch_ii(i32) local_unnamed_addr #2

; Function Attrs: alwaysinline uwtable
define dso_local void @_Z17try_spawn_pitcheri(i32 %a) local_unnamed_addr #8 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad2

det.achd:                                         ; preds = %entry
  tail call void @llvm.taskframe.use(token %0)
  invoke void @_Z8pitcher2i(i32 %a)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %det.achd
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %entry, %invoke.cont
  tail call void @_Z7nothrowv() #5
  sync within %syncreg, label %try.cont

lpad:                                             ; preds = %det.achd
  %1 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %1)
          to label %unreachable unwind label %lpad2

lpad2:                                            ; preds = %entry, %lpad
  %2 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %0, { i8*, i32 } %2)
          to label %unreachable unwind label %lpad9

lpad9:                                            ; preds = %lpad2
  %3 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIc to i8*)
  %4 = extractvalue { i8*, i32 } %3, 1
  %5 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIc to i8*)) #5
  %matches = icmp eq i32 %4, %5
  br i1 %matches, label %catch, label %eh.resume

catch:                                            ; preds = %lpad9
  %6 = extractvalue { i8*, i32 } %3, 0
  %7 = tail call i8* @__cxa_begin_catch(i8* %6) #5
  %8 = load i8, i8* %7, align 1, !tbaa !6
  tail call void @_Z7catch_cc(i8 signext %8) #5
  tail call void @__cxa_end_catch() #5
  br label %try.cont

try.cont:                                         ; preds = %det.cont, %catch
  ret void

eh.resume:                                        ; preds = %lpad9
  resume { i8*, i32 } %3

unreachable:                                      ; preds = %lpad2, %lpad
  unreachable
}

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #7

; Function Attrs: argmemonly
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #7

; Function Attrs: uwtable
define dso_local void @_Z24inline_try_task_into_tryi(i32 %a) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_Z17try_spawn_pitcheri(i32 %a)
          to label %try.cont unwind label %lpad

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %1 = extractvalue { i8*, i32 } %0, 1
  %2 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #5
  %matches = icmp eq i32 %1, %2
  br i1 %matches, label %catch, label %eh.resume

catch:                                            ; preds = %lpad
  %3 = extractvalue { i8*, i32 } %0, 0
  %4 = tail call i8* @__cxa_begin_catch(i8* %3) #5
  %5 = bitcast i8* %4 to i32*
  %6 = load i32, i32* %5, align 4, !tbaa !2
  tail call void @_Z7catch_ii(i32 %6) #5
  tail call void @__cxa_end_catch() #5
  br label %try.cont

try.cont:                                         ; preds = %entry, %catch
  ret void

eh.resume:                                        ; preds = %lpad
  resume { i8*, i32 } %0
}

;;; Test inlining of tasks with landingpags at invokes (function calls
;;; that have unwinds).

; CHECK-LABEL: define {{.*}}void @_Z24inline_try_task_into_tryi(
; CHECK: i32 %a)
; CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[DETUNWIND:.+]]

; CHECK: [[DETACHED]]:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
; CHECK-NEXT: invoke void @_Z8pitcher2i(i32 %a)
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[TASKLPADI:.+]]

; CHECK: [[INVOKECONT]]:
; CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

; CHECK: [[CONTINUE]]:
; CHECK-NEXT: call void @_Z7nothrowv()
; CHECK-NEXT: sync within %[[SYNCREG]], label %[[EXITI:.+]]

; CHECK: [[TASKLPADI]]:
; CHECK-NEXT: %[[TASKLPADIVAL:.+]] = landingpad [[LPADTYPE:{.+}]]
; CHECK-NEXT: cleanup
; CHECK-NOT: catch
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]], [[LPADTYPE]] %[[TASKLPADIVAL]])
; CHECK-NEXT: to label %[[UNREACHABLEI:.+]] unwind label %[[DETUNWIND:.+]]

; CHECK: [[DETUNWIND]]:
; CHECK-NEXT: %[[DETUNWINDLPADVAL:.+]] = landingpad [[LPADTYPE]]
; CHECK-NEXT: cleanup
; CHECK-NOT: catch
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]], [[LPADTYPE]] %[[DETUNWINDLPADVAL]])
; CHECK-NEXT: to label %[[UNREACHABLEI]] unwind label %[[LPADI:.+]]

; CHECK: [[LPADI]]:
; CHECK-NEXT: %[[LPADIVAL:.+]] = landingpad [[LPADTYPE]]
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIc to i8*)
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: br i1 %{{.+}}, label %[[CATCHI:.+]], label %[[RESUMEI:.+]]

; CHECK: [[CATCHI]]:
; CHECK: call void @_Z7catch_cc(
; CHECK: br label %[[EXITI:.+]]

; CHECK: [[RESUMEI]]:
; CHECK-NEXT: resume [[LPADTYPE]] %[[LPADIVAL]]

; CHECK: [[UNREACHABLEI]]:
; CHECK-NEXT: unreachable

; CHECK: [[EXITI]]:
; CHECK-NEXT: br label %[[TRYCONT:.+]]

; CHECK: [[TRYCONT]]:
; CHECK-NEXT: ret void

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }
attributes #6 = { noreturn }
attributes #7 = { argmemonly }
attributes #8 = { alwaysinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git 25614152427619803d5913e1b97a84775b67aa29)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!4, !4, i64 0}
