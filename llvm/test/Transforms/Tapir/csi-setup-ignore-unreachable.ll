; Check that CSI-setup ignores unreachable code when promoting calls to invokes.
;
; RUN: opt < %s -passes="csi-setup" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @main() {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %__cilk_parent_epilogue.exit

det.cont.tf:                                      ; No predecessors!
  %0 = call token @llvm.taskframe.create()
  %syncreg1 = call token @llvm.syncregion.start()
  br label %det.cont3

det.cont.tf.tf:                                   ; No predecessors!
  %1 = call token @llvm.taskframe.create()
  detach within %syncreg1, label %det.achd2, label %det.cont3

det.achd2:                                        ; preds = %det.cont.tf.tf
  call void @llvm.taskframe.use(token %1)
  reattach within %syncreg1, label %det.cont3

det.cont3:                                        ; preds = %det.achd2, %det.cont.tf.tf, %det.cont.tf
  call void null()
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %det.cont3, %entry
  ret i32 0
}

; CHECK: det.cont3:
; CHECK-NOT: invoke void null()

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #0

; uselistorder directives
uselistorder ptr @llvm.syncregion.start, { 1, 0 }
uselistorder ptr @llvm.taskframe.create, { 1, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
