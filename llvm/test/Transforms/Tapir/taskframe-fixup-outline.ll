; RUN: opt < %s -passes="tapir2target" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.end(token) #0

define fastcc void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2() personality ptr null {
invoke.cont61.tf.i.i.ls2:
  %syncreg15.i.i.i.i.i.ls2 = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.syncregion.start()
  %tf.i.i.i.i.ls2 = call token @llvm.taskframe.create()
  br i1 false, label %if.then.tf.i.i.i.i.ls2, label %for.cond.preheader.i.i.i.i.ls2

for.cond.preheader.i.i.i.i.ls2:                   ; preds = %invoke.cont61.tf.i.i.ls2
  call void @llvm.taskframe.end(token %tf.i.i.i.i.ls2)
  ret void

if.then.tf.i.i.i.i.ls2:                           ; preds = %invoke.cont61.tf.i.i.ls2
  %tf.i872.ls2 = call token @llvm.taskframe.create()
  %cmp5.not.i.i.ls2 = icmp ugt i48 0, 0
  %1 = call token @llvm.tapir.runtime.start()
  br label %det.cont.i.i.ls2

if.else11.i.i1520.ls2:                            ; preds = %det.cont.i.i.ls2
  %2 = call token @llvm.tapir.runtime.start()
  br label %invoke.cont29.i.i1531.ls2

.noexc857.ls2:                                    ; preds = %det.cont.i.i.ls2, %invoke.cont29.i.i1531.ls2
  call void @llvm.taskframe.end(token %tf.i1536.ls2)
  unreachable

invoke.cont29.i.i1531.ls2:                        ; preds = %if.else11.i.i1520.ls2
  call void @llvm.tapir.runtime.end(token %2)
  br label %.noexc857.ls2

det.cont.i.i.ls2:                                 ; preds = %if.then.tf.i.i.i.i.ls2
  call void @llvm.tapir.runtime.end(token %1)
  call void @llvm.taskframe.end(token %tf.i872.ls2)
  %tf.i1536.ls2 = call token @llvm.taskframe.create()
  br i1 %cmp5.not.i.i.ls2, label %if.else11.i.i1520.ls2, label %.noexc857.ls2
}

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2()
; CHECK: invoke.cont61.tf.i.i.ls2:
; CHECK: call {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_invoke.cont61.tf.i.i.ls2.tf.otf0()
; CHECK-NEXT: br label %[[TFEND:.+]]
; CHECK: [[TFEND]]:
; CHECK-NEXT: ret void

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_if.then.tf.i.i.i.i.ls2.tf.otf1
; CHECK: (ptr {{.*}}%[[CMP5_NOT_ARG:.+]])
; CHECK: if.then.tf.i.i.i.i.ls2.tf.otf1:
; CHECK-NEXT: %[[CMP5_NOT_VAL:.+]] = icmp ugt i48 0, 0
; CHECK-NEXT: store i1 %[[CMP5_NOT_VAL]], ptr %[[CMP5_NOT_ARG]]
; CHECK-NEXT: call void @__cilkrts_enter_frame(
; CHECK-NEXT: %[[TAPIR_RT_START:.+]] = call token @llvm.tapir.runtime.start()
; CHECK-NEXT: br label %det.cont.i.i.ls2.otf1

; CHECK: det.cont.i.i.ls2.otf1:
; CHECK-NEXT: call void @__cilk_parent_epilogue(
; CHECK-NEXT: call void @llvm.tapir.runtime.end(token %[[TAPIR_RT_START]])
; CHECK-NEXT: br label %det.cont.i.i.ls2.tfend.otf1

; CHECK: det.cont.i.i.ls2.tfend.otf1:
; CHECK-NEXT: ret void

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_det.cont.i.i.ls2.tf.otf1
; CHECK: (i1 %[[ARG:.+]])
; CHECK: det.cont.i.i.ls2.tf.otf1:
; CHECK-NEXT: br i1 %[[ARG]], label %if.else11.i.i1520.ls2.otf1, label %.noexc857.ls2.otf1

; CHECK: .noexc857.ls2.otf1:
; CHECK-NEXT: br label %.noexc857.ls2.tfend.otf1

; CHECK: if.else11.i.i1520.ls2.otf1:
; CHECK-NEXT: call void @__cilkrts_enter_frame(
; CHECK-NEXT: %[[TAPIR_RT_START:.+]] = call token @llvm.tapir.runtime.start()
; CHECK-NEXT: br label %invoke.cont29.i.i1531.ls2.otf1

; CHECK: invoke.cont29.i.i1531.ls2.otf1:
; CHECK-NEXT: call void @__cilk_parent_epilogue(
; CHECK-NEXT: call void @llvm.tapir.runtime.end(token %[[TAPIR_RT_START]])
; CHECK-NEXT: br label %.noexc857.ls2.otf1

; CHECK: .noexc857.ls2.tfend.otf1:
; CHECK-NEXT: ret void

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_invoke.cont61.tf.i.i.ls2.tf.otf0()
; CHECK: invoke.cont61.tf.i.i.ls2.otf0:
; CHECK-NEXT: %[[CMP5_NOT_ALLOCA:.+]] = alloca i1
; CHECK-NEXT: br label %invoke.cont61.tf.i.i.ls2.tf.otf0

; CHECK: invoke.cont61.tf.i.i.ls2.tf.otf0:
; CHECK-NEXT: call void @llvm.lifetime.start.p0(i64 1, ptr %[[CMP5_NOT_ALLOCA]])
; CHECK-NEXT: br i1 false, label %if.then.tf.i.i.i.i.ls2.otf0, label %for.cond.preheader.i.i.i.i.ls2.otf0

; CHECK: for.cond.preheader.i.i.i.i.ls2.otf0:
; CHECK-NEXT: call void @llvm.lifetime.end.p0(i64 1, ptr %[[CMP5_NOT_ALLOCA]])
; CHECK-NEXT: br label %for.cond.preheader.i.i.i.i.ls2.tfend.otf0

; CHECK: if.then.tf.i.i.i.i.ls2.otf0:
; CHECK-NEXT: call {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_if.then.tf.i.i.i.i.ls2.tf.otf1(ptr %[[CMP5_NOT_ALLOCA]])
; CHECK-NEXT: br label %det.cont.i.i.ls2.tfend.otf0

; CHECK: det.cont.i.i.ls2.tfend.otf0:
; CHECK-NEXT: %[[CMP5_NOT_LOAD:.+]] = load i1, ptr %[[CMP5_NOT_ALLOCA]]
; CHECK-NEXT: call fastcc void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_det.cont.i.i.ls2.tf.otf1(i1 %[[CMP5_NOT_LOAD]])
; CHECK-NEXT: br label %.noexc857.ls2.tfend.otf0

; CHECK: .noexc857.ls2.tfend.otf0:
; CHECK-NEXT: unreachable

; CHECK: for.cond.preheader.i.i.i.i.ls2.tfend.otf0
; CHECK-NEXT: ret void

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
