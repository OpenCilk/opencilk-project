; Check that the CSI pass properly splits the predecessors of a detach-continuation block.
;
; RUN: opt < %s -csi -S -o - | FileCheck %s
; RUN: opt < %s -passes='csi' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

define dso_local void @QuadNode_addIntersections() local_unnamed_addr #1 {
entry:
  %syncreg.i28 = tail call token @llvm.syncregion.start()
  br i1 undef, label %if.then.tf, label %if.else

if.then.tf:                                       ; preds = %entry
  detach within %syncreg.i28, label %det.achd, label %det.cont.tf

det.achd:                                         ; preds = %if.then.tf
  unreachable

det.cont.tf:                                      ; preds = %if.then.tf
  detach within %syncreg.i28, label %det.achd1.tf.tf.tf, label %if.end

; CHECK: det.cont.tf:
; CHECK: detach within %syncreg.i28, label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

; CHECK: [[CONTINUE]]:
; CHECK-NEXT: call void @__csi_detach_continue(
; CHECK-NEXT: br label %if.end

det.achd1.tf.tf.tf:                               ; preds = %det.cont.tf
  br label %det.achd1.tf.tf.tf.tf

det.achd1.tf.tf.tf.tf:                            ; preds = %det.achd1.tf.tf.tf
  %tf.i = tail call token @llvm.taskframe.create()
  %syncreg.i = tail call token @llvm.syncregion.start() #2
  reattach within %syncreg.i28, label %if.end

; CHECK: [[DETACHED]]:
; CHECK: reattach within %syncreg.i28, label %[[CONTINUE]]

if.else:                                          ; preds = %entry
  sync within %syncreg.i28, label %if.end

; CHECK: if.else:
; CHECK: sync within %syncreg.i28, label %[[SYNC_SPLIT:.+]]

; CHECK: [[SYNC_SPLIT]]:
; CHECK: call void @__csi_after_sync(
; CHECK: br label %if.end

if.end:                                           ; preds = %if.else, %det.achd1.tf.tf.tf.tf, %det.cont.tf
  unreachable
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #0

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 94a2a3eb6c9f8dd53def6e21c5ab8ff45acb586f)"}
