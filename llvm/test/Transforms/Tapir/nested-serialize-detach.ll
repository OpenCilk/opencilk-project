; Check that nested detaches can be serialized.
;
; RUN: opt < %s -passes="function<eager-inv>(task-simplify)" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; CHECK: define void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiERH3BagIiEjPj()
; CHECK-NEXT: entry:
; CHECK-NOT: detach within
; CHECK: unreachable

define void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiERH3BagIiEjPj() personality ptr null {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %syncreg45 = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.tapir.runtime.start()
  detach within %syncreg45, label %pfor.body.entry.tf, label %pfor.inc unwind label %lpad59.loopexit

pfor.body.entry.tf:                               ; preds = %entry
  %tf.i = tail call token @llvm.taskframe.create()
  %syncreg.i = tail call token @llvm.syncregion.start()
  detach within %syncreg.i, label %pfor.cond.i.strpm.detachloop.entry, label %pfor.cond.cleanup.i unwind label %lpad4924.loopexit.split-lp

pfor.cond.i.strpm.detachloop.entry:               ; preds = %pfor.body.entry.tf
  %syncreg.i.strpm.detachloop = tail call token @llvm.syncregion.start()
  detach within none, label %pfor.body.entry.i.strpm.outer.1, label %pfor.inc.i.strpm.outer.1 unwind label %lpad4924.loopexit.strpm

pfor.body.entry.i.strpm.outer.1:                  ; preds = %pfor.cond.i.strpm.detachloop.entry
  invoke void @llvm.detached.rethrow.sl_p0i32s(token none, { ptr, i32 } zeroinitializer)
          to label %lpad4924.unreachable unwind label %lpad4924.loopexit.strpm

pfor.inc.i.strpm.outer.1:                         ; preds = %pfor.cond.i.strpm.detachloop.entry
  sync within none, label %pfor.cond.i.strpm.detachloop.reattach.split

pfor.cond.i.strpm.detachloop.reattach.split:      ; preds = %pfor.inc.i.strpm.outer.1
  reattach within %syncreg.i, label %pfor.cond.cleanup.i

pfor.cond.cleanup.i:                              ; preds = %pfor.cond.i.strpm.detachloop.reattach.split, %pfor.body.entry.tf
  sync within %syncreg.i, label %sync.continue.i

sync.continue.i:                                  ; preds = %pfor.cond.cleanup.i
  invoke void @llvm.sync.unwind(token none)
          to label %pfor.preattach unwind label %lpad4924.loopexit.split-lp

lpad4924.loopexit.strpm:                          ; preds = %pfor.body.entry.i.strpm.outer.1, %pfor.cond.i.strpm.detachloop.entry
  %lpad.strpm = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg.i, { ptr, i32 } zeroinitializer)
          to label %lpad4924.loopexit.strpm.unreachable unwind label %lpad4924.loopexit.split-lp

lpad4924.loopexit.strpm.unreachable:              ; preds = %lpad4924.loopexit.strpm
  unreachable

lpad4924.loopexit.split-lp:                       ; preds = %lpad4924.loopexit.strpm, %sync.continue.i, %pfor.body.entry.tf
  %lpad.loopexit.split-lp = landingpad { ptr, i32 }
          cleanup
  call void @llvm.detached.rethrow.sl_p0i32s(token none, { ptr, i32 } zeroinitializer)
  unreachable

lpad4924.unreachable:                             ; preds = %pfor.body.entry.i.strpm.outer.1
  unreachable

pfor.preattach:                                   ; preds = %sync.continue.i
  reattach within %syncreg45, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %entry
  ret void

lpad59.loopexit:                                  ; preds = %entry
  %lpad.loopexit28 = landingpad { ptr, i32 }
          cleanup
  tail call void @llvm.tapir.runtime.end(token %0)
  resume { ptr, i32 } zeroinitializer
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #0

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { willreturn memory(argmem: readwrite) }
