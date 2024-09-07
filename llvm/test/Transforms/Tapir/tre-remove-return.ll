; Check that tail-call elimination handles deletion of return blocks
; when it attempts to insert sync instructions before returns.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(function<eager-inv;no-rerun>(tailcallelim)))" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx14.0.0"

define void @_Z3dacPfPKfS1_xxxxxx() personality ptr null {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %0 = call token @llvm.tapir.runtime.start()
  br i1 false, label %if.end10, label %if.then7

if.then7:                                         ; preds = %entry
  call void @_Z3dacPfPKfS1_xxxxxx()
  sync within %syncreg, label %cleanup

if.end10:                                         ; preds = %entry
  call void @_Z3dacPfPKfS1_xxxxxx()
  br label %cleanup

cleanup:                                          ; preds = %if.end10, %if.then7
  call void @llvm.tapir.runtime.end(token %0)
  ret void
}

; CHECK: define void @_Z3dacPfPKfS1_xxxxxx()

; CHECK: entry:
; CHECK-NEXT: %syncreg = {{.*}}call token @llvm.syncregion.start()
; CHECK-NEXT: br label %[[TAILRECURSE:.+]]

; CHECK: [[TAILRECURSE]]:
; CHECK: br i1 false, label %if.end10, label %if.then7

; CHECK: if.then7:
; CHECK-NOT: sync
; CHECK-NEXT: br label %[[TAILRECURSE]]

; CHECK: if.end10:
; CHECK-NEXT: br label %[[TAILRECURSE]]

; CHECK-NOT: ret void

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
