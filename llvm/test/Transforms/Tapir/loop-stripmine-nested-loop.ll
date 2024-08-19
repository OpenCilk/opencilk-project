; Check that loop stripmining properly analyzes cost of inner serial loop.
;
; RUN: opt < %s -passes="loop-stripmine" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define internal fastcc void @_ZN10benchmarks15cilk_mandelbrot17h1d757ad11ef25f85E(i1 %exitcond.not.i) personality ptr null {
"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17h8cffd88cc6b3a5e9E.exit.i":
  %0 = tail call token @llvm.syncregion.start()
  br label %bb11.i

bb13.i:                                           ; preds = %bb4.i2
  ret void

bb11.i:                                           ; preds = %bb4.i2, %"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17h8cffd88cc6b3a5e9E.exit.i"
  detach within %0, label %bb3.tf.i.tf.tf.tf, label %bb4.i2

bb3.tf.i.tf.tf.tf:                                ; preds = %bb11.i
  %tf.i.i = tail call token @llvm.taskframe.create()
  %1 = tail call token @llvm.syncregion.start()
  br label %bb11.i.i.i

bb11.i.i.i:                                       ; preds = %bb4.i.i.i, %bb3.tf.i.tf.tf.tf
  %iter.sroa.0.08.i.i.i = phi i64 [ %_0.i4.i.i.i, %bb4.i.i.i ], [ 0, %bb3.tf.i.tf.tf.tf ]
  %_0.i4.i.i.i = add i64 %iter.sroa.0.08.i.i.i, 1
  detach within %1, label %bb3.i.i.i, label %bb4.i.i.i

bb3.i.i.i:                                        ; preds = %bb11.i.i.i
  br label %bb2.i.i.i.i

bb2.i.i.i.i:                                      ; preds = %bb2.i.i.i.i, %bb3.i.i.i
  %depth.02.i.i.i.i = phi double [ 0.000000e+00, %bb3.i.i.i ], [ %2, %bb2.i.i.i.i ]
  %2 = fadd double %depth.02.i.i.i.i, 1.000000e+00
  %_16.i.i.i.i.1 = fcmp olt double %2, 1.000000e+02
  br i1 %_16.i.i.i.i.1, label %bb2.i.i.i.i, label %"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$28_$u7b$$u7b$closure$u7d$$u7d$17h37d21dcab212431cE.exit.i.i.i"

"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$28_$u7b$$u7b$closure$u7d$$u7d$17h37d21dcab212431cE.exit.i.i.i": ; preds = %bb2.i.i.i.i
  reattach within %1, label %bb4.i.i.i

bb4.i.i.i:                                        ; preds = %"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$28_$u7b$$u7b$closure$u7d$$u7d$17h37d21dcab212431cE.exit.i.i.i", %bb11.i.i.i
  %exitcond.not.i.i.i = icmp eq i64 %iter.sroa.0.08.i.i.i, 20480
  br i1 %exitcond.not.i.i.i, label %"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$17h9b0c8d58900499abE.exit.i.tfend", label %bb11.i.i.i, !llvm.loop !0

"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$17h9b0c8d58900499abE.exit.i.tfend": ; preds = %bb4.i.i.i
  tail call void @llvm.taskframe.end(token %tf.i.i)
  reattach within %0, label %bb4.i2

bb4.i2:                                           ; preds = %"_ZN10benchmarks15cilk_mandelbrot28_$u7b$$u7b$closure$u7d$$u7d$17h9b0c8d58900499abE.exit.i.tfend", %bb11.i
  br i1 %exitcond.not.i, label %bb13.i, label %bb11.i
}

; CHECK: define internal fastcc void @_ZN10benchmarks15cilk_mandelbrot17h1d757ad11ef25f85E(
; CHECK: detach within %[[OUTER_SYNCREG:.+]], label %{{.+}}, label %{{.+}}
; CHECK: %[[TF_I:.+]] = {{.*}}call token @llvm.taskframe.create()
; CHECK: detach within %[[INNER_SYNCREG:.+]], label %{{.+}}, label %{{.+}}

; CHECK: detach within %[[STRPM_DETACHLOOP:.+]], label %[[STRPM_OUTER:.+]], label %{{.+}}

; CHECK: [[STRPM_OUTER]]:
; CHECK-NEXT: mul
; CHECK-NEXT: br label %[[INNER_SERIAL_LOOP:.+]]

; CHECK: [[INNER_SERIAL_LOOP]]:
; CHECK-NEXT: phi
; CHECK: br label %[[WHILE_LOOP_PH:.+]]

; CHECK: [[WHILE_LOOP_PH]]:
; CHECK: br label %[[WHILE_HEADER:.+]]

; CHECK: [[WHILE_HEADER]]:
; CHECK-NEXT: phi

; CHECK: br i1 %{{.+}}, label %[[WHILE_HEADER]], label %[[WHILE_EXIT:.+]]

; CHECK: [[WHILE_EXIT]]:
; CHECK: br i1 %{{.+}}, label %[[INNER_SERIAL_LOOP_REATTACH:.+]], label %[[INNER_SERIAL_LOOP]]

; CHECK: [[INNER_SERIAL_LOOP_REATTACH]]:
; CHECK-NEXT: reattach within %[[STRPM_DETACHLOOP]], label %[[STRPM_LATCH:.+]]

; CHECK: [[STRPM_LATCH]]:
; CHECK: br i1 %{{.+}}, label %{{.+}}, label %{{.+}}, !llvm.loop ![[STRPM_LOOPMD:.+]]

; CHECK: sync within %[[STRPM_DETACHLOOP]], label %{{.+}}
; CHECK: reattach within %[[INNER_SYNCREG]]
; CHECK: call void @llvm.taskframe.end(token %[[TF_I]]
; CHECK: reattach within %[[OUTER_SYNCREG]], label %[[LATCH:.+]]

; CHECK: [[LATCH]]:
; CHECK: br i1 %{{.+}}, label %{{.+}}, label %{{.+}}, !llvm.loop ![[LOOPMD:.+]]

; CHECK: ![[STRPM_LOOPMD]] = distinct !{![[STRPM_LOOPMD]], !{{[0-9]+}}, ![[GRANSIZEMD:[0-9]+]]}
; CHECK: ![[GRANSIZEMD]] = !{!"tapir.loop.grainsize", i32 1}

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

!0 = distinct !{!0, !1}
!1 = !{!"tapir.loop.spawn.strategy", i32 1}
