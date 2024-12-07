; Check that dead tapir.runtime.start intrinsics are removed after removing unreachable blocks.
;
; RUN: opt < %s -passes="function<eager-inv>(task-simplify)" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx15.0.0"

; CHECK: define void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiERH3BagIiEjPj()
; CHECK-NEXT: entry:
; CHECK-NEXT: call ptr @_Znwm
; CHECK-NEXT: unreachable

define void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiERH3BagIiEjPj() personality ptr null {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %0 = tail call token @llvm.tapir.runtime.start()
  detach within %syncreg, label %pfor.body.entry.tf, label %pfor.inc unwind label %lpad59.loopexit

pfor.body.entry.tf:                               ; preds = %entry
  %call.i15.i26.1 = call ptr @_Znwm()
  unreachable

pfor.inc:                                         ; preds = %entry
  sync within %syncreg, label %sync.continue

common.ret:                                       ; preds = %sync.continue, %lpad59.loopexit
  ret void

lpad59.loopexit:                                  ; preds = %entry
  %lpad.loopexit28 = landingpad { ptr, i32 }
          cleanup
  br label %common.ret

sync.continue:                                    ; preds = %pfor.inc
  tail call void @llvm.tapir.runtime.end(token %0)
  br label %common.ret
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #0

declare ptr @_Znwm()

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
