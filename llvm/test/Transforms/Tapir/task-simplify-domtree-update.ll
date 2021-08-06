; Verify that task-simplify properly handles with unreachable blocks,
; specifically, during its incremental updates to the dominator tree.
;
; RUN: opt < %s -task-simplify -S -o - | FileCheck %s
; RUN: opt < %s -passes='task-simplify' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@_ZTIi = external dso_local constant i8*
@.str.16 = external dso_local unnamed_addr constant [9 x i8], align 1

declare dso_local i32 @__gxx_personality_v0(...)

declare dso_local void @_ZN3ObjC2EPKc() unnamed_addr #0 align 2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #1

; Function Attrs: argmemonly willreturn
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #2

define dso_local void @main() local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg54 = call token @llvm.syncregion.start()
  %syncreg157 = call token @llvm.syncregion.start()
  invoke void @_ZN3ObjC2EPKc()
          to label %invoke.cont unwind label %lpad

; CHECK: entry
; CHECK: invoke void @_ZN3ObjC2EPKc()
; CHECK-NEXT: to label %[[CONT:.+]] unwind label %[[UNWIND:.+]]

; CHECK: [[CONT]]:
; CHECK: unreachable

; CHECK: [[UNWIND]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch
; CHECK: unreachable

invoke.cont:                                      ; preds = %entry
  %0 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad6

det.achd:                                         ; preds = %invoke.cont
  unreachable

det.cont:                                         ; preds = %invoke.cont
  %1 = call token @llvm.taskframe.create()
  unreachable

lpad:                                             ; preds = %entry
  %2 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %3 = call token @llvm.taskframe.create()
  br label %det.achd55

lpad6:                                            ; preds = %invoke.cont
  %4 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %0, { i8*, i32 } %4)
          to label %unreachable unwind label %lpad13

lpad13:                                           ; preds = %lpad6
  %5 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  unreachable

det.achd55:                                       ; preds = %lpad
  unreachable

det.cont68:                                       ; No predecessors!
  %6 = call token @llvm.taskframe.create()
  detach within %syncreg54, label %det.achd75, label %det.cont88 unwind label %lpad85

det.achd75:                                       ; preds = %det.cont68
  unreachable

det.cont88:                                       ; preds = %det.cont68
  %7 = call token @llvm.taskframe.create()
  unreachable

lpad74:                                           ; preds = %lpad85
  %8 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  unreachable

lpad85:                                           ; preds = %det.cont68
  %9 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %6, { i8*, i32 } %9)
          to label %unreachable unwind label %lpad74

unreachable:                                      ; preds = %lpad85, %lpad6
  unreachable
}

attributes #0 = { "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly willreturn }

!llvm.ident = !{!0}

!0 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 31ad596bd7126d79fa36fd82538084e8a8f4d913)"}
