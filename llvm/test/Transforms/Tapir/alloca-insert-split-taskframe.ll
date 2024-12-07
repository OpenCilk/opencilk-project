; RUN: opt < %s -passes="tapir2target" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.parlay::sequence_internal::sequence_base<double, parlay::allocator<double>, false>::storage_impl::capacitated_buffer::header" = type { i64, %union.anon.229 }
%union.anon.229 = type { [1 x i8], [7 x i8] }

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

define fastcc void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2(ptr %call.i.i.i.i31.i874.ls2) personality ptr null {
invoke.cont61.tf.i.i.ls2:
  %syncreg15.i.i.i.i.i.ls2 = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.syncregion.start()
  %tf.i.i.i.i.ls2 = call token @llvm.taskframe.create()
  %1 = call token @llvm.tapir.runtime.start()
  call void @llvm.tapir.runtime.end(token %1)
  %tf.i872.ls2 = call token @llvm.taskframe.create()
  %2 = getelementptr %"struct.parlay::sequence_internal::sequence_base<double, parlay::allocator<double>, false>::storage_impl::capacitated_buffer::header", ptr %call.i.i.i.i31.i874.ls2, i64 0, i32 1
  %3 = call token @llvm.tapir.runtime.start()
  detach within %syncreg15.i.i.i.i.i.ls2, label %det.achd.i.i.ls2, label %det.cont.i.i.ls2 unwind label %lpad17.i.i.ls2

vector.ph3079.ls2:                                ; No predecessors!
  %4 = getelementptr double, ptr %2, i64 0
  br label %invoke.cont.i.i.i.i.i266.i.i.ls2

invoke.cont.i.i.i.i.i266.i.i.ls2:                 ; preds = %det.cont.i.i.ls2, %vector.ph3079.ls2
  call void @llvm.taskframe.end(token %tf.i872.ls2)
  %tf.i1536.ls2 = call token @llvm.taskframe.create()
  %5 = call token @llvm.tapir.runtime.start()
  detach within %syncreg15.i.i.i.i.i.ls2, label %det.achd.i.i1532.ls2, label %det.cont.i.i1526.ls2 unwind label %lpad17.i.i1523.ls2

det.cont.i.i1526.ls2:                             ; preds = %det.achd.i.i1532.ls2, %invoke.cont.i.i.i.i.i266.i.i.ls2
  sync within %syncreg15.i.i.i.i.i.ls2, label %sync.continue28.i.i1530.ls2

sync.continue28.i.i1530.ls2:                      ; preds = %det.cont.i.i1526.ls2
  call void @llvm.taskframe.end(token %tf.i1536.ls2)
  call void @llvm.taskframe.end(token %tf.i.i.i.i.ls2)
  ret void

lpad17.i.i1523.ls2:                               ; preds = %invoke.cont.i.i.i.i.i266.i.i.ls2
  %6 = landingpad { ptr, i32 }
          cleanup
  call void @llvm.tapir.runtime.end(token %5)
  unreachable

det.cont.i.i.ls2:                                 ; preds = %det.achd.i.i.ls2, %invoke.cont61.tf.i.i.ls2
  sync within %syncreg15.i.i.i.i.i.ls2, label %invoke.cont.i.i.i.i.i266.i.i.ls2

lpad17.i.i.ls2:                                   ; preds = %invoke.cont61.tf.i.i.ls2
  %7 = landingpad { ptr, i32 }
          cleanup
  call void @llvm.tapir.runtime.end(token %3)
  unreachable

det.achd.i.i1532.ls2:                             ; preds = %invoke.cont.i.i.i.i.i266.i.i.ls2
  reattach within %syncreg15.i.i.i.i.i.ls2, label %det.cont.i.i1526.ls2

det.achd.i.i.ls2:                                 ; preds = %invoke.cont61.tf.i.i.ls2
  reattach within %syncreg15.i.i.i.i.i.ls2, label %det.cont.i.i.ls2
}

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2(ptr %call.i.i.i.i31.i874.ls2)
; CHECK: invoke.cont61.tf.i.i.ls2:
; CHECK-NEXT: %[[FIXUP_ALLOCA:.+]] = alloca ptr
; CHECK-NEXT: call token @llvm.syncregion.start()
; CHECK-NEXT: call token @llvm.syncregion.start()
; CHECK-NEXT: call {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_invoke.cont61.tf.i.i.ls2.tf.otf0(ptr %call.i.i.i.i31.i874.ls2, ptr %[[FIXUP_ALLOCA]])
; CHECK-NEXT: br label %sync.continue28.i.i1530.ls2.tfend

; CHECK: sync.continue28.i.i1530.ls2.tfend:
; CHECK: ret void

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_det.achd.i.i.ls2.otd1
; CHECK: (ptr %[[ARG:.+]])
; CHECK: call void @__cilkrts_detach(
; CHECK: ret void

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_invoke.cont61.tf.i.i.ls2.tf.tf.otf1(ptr {{.*}}%call.i.i.i.i31.i874.ls2.otf1,
; CHECK: ptr {{.*}}%[[ARG:.+]])

; CHECK: invoke.cont61.tf.i.i.ls2.tf.tf.otf1:
; CHECK: %[[ADDR:.+]] = getelementptr %"struct.parlay::sequence_internal::sequence_base<double, parlay::allocator<double>, false>::storage_impl::capacitated_buffer::header", ptr %call.i.i.i.i31.i874.ls2.otf1, i64 0, i32 1
; CHECK-NEXT: store ptr %[[ADDR]], ptr %[[ARG]]
; CHECK-NEXT: call void @__cilkrts_enter_frame(
; CHECK-NEXT: %[[TAPIR_RT_START:.+]] = call token @llvm.tapir.runtime.start()
; CHECK-NEXT: call i32 @__cilk_prepare_spawn(

; CHECK: invoke {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_det.achd.i.i.ls2.otd1(
; CHECK-NEXT: to label %det.cont.i.i.ls2.otf1 unwind label %lpad17.i.i.ls2.otf1

; CHECK: lpad17.i.i.ls2.otf1:
; CHECK: landingpad
; CHECK: call void @llvm.tapir.runtime.end(token %[[TAPIR_RT_START]])
; CHECK-NEXT: unreachable

; CHECK: det.cont.i.i.ls2.otf1:
; CHECK-NEXT: call void @__cilk_sync(

; CHECK: ret void

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_det.achd.i.i1532.ls2.otd1(
; CHECK: (ptr %[[ARG:.+]])
; CHECK: call void @__cilkrts_detach(
; CHECK: ret void

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_invoke.cont.i.i.i.i.i266.i.i.ls2.tf.otf1()
; CHECK: invoke.cont.i.i.i.i.i266.i.i.ls2.tf.otf1:
; CHECK: call void @__cilkrts_enter_frame(
; CHECK-NEXT: %[[TAPIR_RT_START:.+]] = call token @llvm.tapir.runtime.start()
; CHECK-NEXT: call i32 @__cilk_prepare_spawn(

; CHECK: invoke {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_det.achd.i.i1532.ls2.otd1(
; CHECK-NEXT: to label %det.cont.i.i1526.ls2.otf1 unwind label %lpad17.i.i1523.ls2.otf1

; CHECK: lpad17.i.i1523.ls2.otf1:
; CHECK-NEXT: landingpad
; CHECK: call void @llvm.tapir.runtime.end(token %[[TAPIR_RT_START]])
; CHECK-NEXT: unreachable

; CHECK: det.cont.i.i1526.ls2.otf1:
; CHECK-NEXT: call void @__cilk_sync(

; CHECK: ret void

; CHECK-LABEL: define {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_invoke.cont61.tf.i.i.ls2.tf.otf0(ptr align 1 %call.i.i.i.i31.i874.ls2.otf0,
; CHECK: ptr {{.*}}%[[ARG:.+]])
; CHECK: %[[FIXUP_ALLOCA:.+]] = alloca ptr

; CHECK: call void @llvm.lifetime.start.p0(i64 8, ptr %[[FIXUP_ALLOCA]])
; CHECK-NEXT: call void @__cilkrts_enter_frame(
; CHECK-NEXT: %[[TAPIR_RT_START:.+]] = call token @llvm.tapir.runtime.start()
; CHECK-NEXT: call void @__cilk_parent_epilogue(
; CHECK-NEXT: call void @llvm.tapir.runtime.end(token %[[TAPIR_RT_START]])
; CHECK-NEXT: call {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_invoke.cont61.tf.i.i.ls2.tf.tf.otf1(ptr %call.i.i.i.i31.i874.ls2.otf0, ptr %[[FIXUP_ALLOCA]])

; CHECK: %[[FIXUP_LOAD:.+]] = load ptr, ptr %[[FIXUP_ALLOCA]]
; CHECK-NEXT: store ptr %[[FIXUP_LOAD]], ptr %[[ARG]]
; CHECK-NEXT: call {{.*}}void @_Z6kmeansIFdRKN6parlay8sequenceIdNS0_9allocatorIdEELb0EEES6_EEDaRNS1_IS4_NS2_IS4_EELb0EEEiRT_d.outline_pfor.cond.i.i.i182.ls2.outline_invoke.cont.i.i.i.i.i266.i.i.ls2.tf.otf1()

; CHECK: call void @llvm.lifetime.end.p0(i64 8, ptr %[[FIXUP_ALLOCA]])

; CHECK: ret void

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
