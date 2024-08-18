; Check that task-simplify removes unneeded taskframes from inside of parallel loops.
;
; RUN: opt %s -passes="task-simplify" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define internal fastcc void @_ZN10benchmarks15cilk_mandelbrot17h1d757ad11ef25f85E() personality ptr null {
"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17h8cffd88cc6b3a5e9E.exit.i":
  %0 = tail call token @llvm.syncregion.start()
  br label %bb11.i

bb11.i:                                           ; preds = %"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$17h9b0c8d58900499abE.exit.i.tfend", %bb11.i, %"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17h8cffd88cc6b3a5e9E.exit.i"
  detach within %0, label %bb3.tf.i.tf.tf.tf, label %bb11.i

bb3.tf.i.tf.tf.tf:                                ; preds = %bb11.i
  %tf.i.i = tail call token @llvm.taskframe.create()
  %1 = tail call token @llvm.syncregion.start()
  detach within %1, label %bb3.i.i.i, label %bb4.i.i.i

bb3.i.i.i:                                        ; preds = %bb3.tf.i.tf.tf.tf
  %sext = shl i64 0, 0
  reattach within %1, label %bb4.i.i.i

bb4.i.i.i:                                        ; preds = %bb3.i.i.i, %bb3.tf.i.tf.tf.tf
  %exitcond.not.i.i.i = icmp eq i64 0, 0
  sync within %1, label %"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$17h9b0c8d58900499abE.exit.i.tfend"

"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$17h9b0c8d58900499abE.exit.i.tfend": ; preds = %bb4.i.i.i
  tail call void @llvm.taskframe.end(token %tf.i.i)
  reattach within %0, label %bb11.i
}

; CHECK: define internal fastcc void @_ZN10benchmarks15cilk_mandelbrot17h1d757ad11ef25f85E(
; CHECK: detach within %[[OUTER_SYNCREG:.+]], label %{{.+}}, label %{{.+}}
; CHECK-NOT: call token @llvm.taskframe.create()
; CHECK: detach within %[[INNER_SYNCREG:.+]], label %{{.+}}, label %{{.+}}
; CHECK: reattach within %[[INNER_SYNCREG]]
; CHECK-NOT: call void @llvm.taskframe.end(
; CHECK: reattach within %[[OUTER_SYNCREG]]

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.end(token) #0

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }
uselistorder ptr @llvm.syncregion.start, { 1, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
