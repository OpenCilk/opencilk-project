; Check that SROA preserves Tapir task info while processing allocas.
;
; RUN: opt < %s -passes='cgscc(devirt<4>(function<eager-inv>(sroa<modify-cfg>)))' -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class._point3d = type { double, double, double }

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #1

define ptr @_Z9buildTreePP8particleS1_Pbii(i1 %cmp.i) personality ptr null {
entry:
  %maxPt = alloca %class._point3d, align 8
  %syncreg = call token @llvm.syncregion.start()
  %syncreg33 = call token @llvm.syncregion.start()
  %syncreg70 = call token @llvm.syncregion.start()
  %syncreg105 = call token @llvm.syncregion.start()
  call void @llvm.memcpy.p0.p0.i64(ptr %maxPt, ptr null, i64 24, i1 false)
  %cond-lvalue.i = select i1 false, ptr null, ptr %maxPt
  %cond-lvalue6.i = select i1 %cmp.i, ptr %maxPt, ptr %cond-lvalue.i
  %0 = load double, ptr %cond-lvalue6.i, align 8
  br label %pfor.cond

; CHECK: entry:
; CHECK: %maxPt.sroa.3 = alloca { double, double }
; CHECK: %maxPt.sroa.0.0.copyload = load double, ptr null
; CHECK: br i1 %cmp.i, label %[[ENTRY_CONT:.+]], label %[[ENTRY_ELSE:.+]]

; CHECK: [[ENTRY_ELSE]]:
; CHECK-NEXT: br label %[[ENTRY_CONT]]

; CHECK: [[ENTRY_CONT]]:
; CHECK: phi double [ %maxPt.sroa.0.0.copyload, %entry ], [ %maxPt.sroa.0.0.copyload, %[[ENTRY_ELSE]] ]
; CHECK: br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.body.entry, %pfor.cond, %entry
  detach within none, label %pfor.body.entry, label %pfor.cond

pfor.body.entry:                                  ; preds = %pfor.cond
  reattach within none, label %pfor.cond
}

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 4, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
