; Verify that TRE properly handles a sync with an associated landing pad.
;
; RUN: opt < %s -tailcallelim -S | FileCheck %s
; RUN: opt < %s -passes='tailcallelim' -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$_ZN6miniFE6VectorIdiiEC2Eii = comdat any

declare dso_local i32 @__gxx_personality_v0(...)

define dso_local void @_ZN6miniFE6VectorIdiiEC2Eii() unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %entry
  detach within %syncreg, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  unreachable

pfor.inc:                                         ; preds = %pfor.cond
  br i1 undef, label %pfor.cond, label %pfor.cond.cleanup

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %cleanup unwind label %lpad9

lpad9:                                            ; preds = %sync.continue
  %0 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } %0

cleanup:                                          ; preds = %sync.continue
  ret void
}

; CHECK: pfor.cond.cleanup:
; CHECK-NEXT: sync within %syncreg, label %sync.continue

; CHECK: sync.continue:
; CHECK-NEXT: invoke void @llvm.sync.unwind(token %syncreg)
; CHECK-NEXT: to label %cleanup unwind label %lpad9

; CHECK: lpad9:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: resume

; CHECK: cleanup:
; CHECK-NEXT: ret void

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #2

attributes #0 = { "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly willreturn }

!llvm.ident = !{!0}

!0 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 59dcdc73a701d0d8e4569cc80f1ef56b1bc69f83)"}
