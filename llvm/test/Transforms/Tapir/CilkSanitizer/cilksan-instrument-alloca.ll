; Check that Cilksan and CSI instrument allocas properly in a function's entry block.
;
; RUN: opt < %s -passes="cilksan" -S | FileCheck %s
; RUN: opt < %s -passes="csi" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: sanitize_cilk
define i32 @ggml_graph_compute() #0 {
entry:
  %0 = call i64 @llvm.bswap.i64(i64 0)
  %MyAlloca = alloca i8, i64 0, align 32
  %1 = ptrtoint ptr %MyAlloca to i64
  unreachable
}

; CHECK: define i32 @ggml_graph_compute()
; CHECK-NOT: call void @__csi_after_alloca(
; CHECK: %MyAlloca = alloca i8, i64 0
; CHECK: call void @__csi_after_alloca(

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.bswap.i64(i64) #1

attributes #0 = { sanitize_cilk }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
