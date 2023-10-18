; Check that ASan properly checks for parallel-promotable allocas.
;
; RUN: opt < %s -passes="asan<>" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: sanitize_address
define void @do_timestep() #1 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = load i32, ptr null, align 8
  %vla = alloca float, i64 0, align 16
  detach within %syncreg, label %for.body.lr.ph.us, label %pfor.inc.us

pfor.inc.us:                                      ; preds = %for.body.lr.ph.us, %entry
  ret void

for.body.lr.ph.us:                                ; preds = %entry
  %call.us = call i32 null(ptr null, i32 0, i32 0, ptr %vla)
  reattach within %syncreg, label %pfor.inc.us
}

; CHECK: define void @do_timestep()
; CHECK: entry:
; CHECK: br i1 %{{.*}}, label %[[ASAN_BLK_2:[a-zA-Z0-9_\.]+]], label %[[ASAN_BLK_5:[a-zA-Z0-9_\.]+]]

; CHECK: [[ASAN_BLK_2]]:
; CHECK: br i1 %{{.*}}, label %[[ASAN_BLK_4:[a-zA-Z0-9_\.]+]], label %[[ASAN_BLK_5]]

; CHECK: [[ASAN_BLK_5]]:
; CHECK-NEXT: load i32, ptr null
; CHECK-NEXT: %vla = alloca float, i64 0
; CHECK-NEXT: detach within %syncreg, label %for.body.lr.ph.us, label %pfor.inc.us

; CHECK: pfor.inc.us:
; CHECK-NEXT: ret void

; CHECK: for.body.lr.ph.us:
; CHECK-NEXT: call i32 null(ptr null, i32 0, i32 0, ptr %vla)
; CHECK-NEXT: reattach within %syncreg, label %pfor.inc.us

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { sanitize_address }
