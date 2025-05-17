; Check that tapir-cleanup pass serializes nested tasks correctly, specifically
; when the tasks have unwind destinations.
;
; RUN: llc < %s -o - 2>&1 | FileCheck %s
; REQUIRES: x86-registered-target
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @_ZNK5Graph4pbfsEiPj() personality ptr null {
entry:
  %syncreg13 = tail call token @llvm.syncregion.start()
  detach within %syncreg13, label %pfor.cond28.strpm.detachloop.entry, label %common.ret unwind label %lpad55.loopexit

pfor.cond28.strpm.detachloop.entry:               ; preds = %entry
  %syncreg13.strpm.detachloop = call token @llvm.syncregion.start()
  detach within %syncreg13.strpm.detachloop, label %pfor.body.entry31.strpm.outer, label %pfor.inc56.strpm.outer unwind label %lpad55.loopexit.strpm

pfor.body.entry31.strpm.outer:                    ; preds = %pfor.cond28.strpm.detachloop.entry
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg13.strpm.detachloop, { ptr, i32 } zeroinitializer)
          to label %unreachable unwind label %lpad55.loopexit.strpm

pfor.inc56.strpm.outer:                           ; preds = %pfor.cond28.strpm.detachloop.entry
  sync within %syncreg13.strpm.detachloop, label %pfor.cond28.strpm.detachloop.reattach.split

pfor.cond28.strpm.detachloop.reattach.split:      ; preds = %pfor.inc56.strpm.outer
  reattach within %syncreg13, label %common.ret

common.ret:                                       ; preds = %lpad55.loopexit, %pfor.cond28.strpm.detachloop.reattach.split, %entry
  ret i32 0

lpad55.loopexit.strpm:                            ; preds = %pfor.body.entry31.strpm.outer, %pfor.cond28.strpm.detachloop.entry
  %lpad.strpm = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg13, { ptr, i32 } zeroinitializer)
          to label %lpad55.loopexit.strpm.unreachable unwind label %lpad55.loopexit

lpad55.loopexit.strpm.unreachable:                ; preds = %lpad55.loopexit.strpm
  unreachable

lpad55.loopexit:                                  ; preds = %lpad55.loopexit.strpm, %entry
  %lpad.strpm.detachloop.unwind = landingpad { ptr, i32 }
          cleanup
  br label %common.ret

unreachable:                                      ; preds = %pfor.body.entry31.strpm.outer
  unreachable
}

; CHECK: CodeGen found Tapir instructions to serialize.
; CHECK: CodeGen found Tapir instructions to serialize.
; CHECK: .globl	_ZNK5Graph4pbfsEiPj
; CHECK: _ZNK5Graph4pbfsEiPj:
; CHECK: xorl %eax, %eax
; CHECK-NEXT: retq

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #1

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }
uselistorder ptr @llvm.syncregion.start, { 1, 0 }
uselistorder ptr @llvm.detached.rethrow.sl_p0i32s, { 1, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { willreturn memory(argmem: readwrite) }
