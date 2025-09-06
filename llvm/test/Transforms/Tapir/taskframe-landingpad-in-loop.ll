; Check that task-simplify can optimize taskframes with landingpads that appear in parallel loops.
;
; RUN: opt < %s -passes="task-simplify" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

define void @_ZN44TestPrimitives_TestFlattenNestedDelayed_Test8TestBodyEv() personality ptr null {
entry:
  %syncreg.i.i.i.i.i.i = tail call token @llvm.syncregion.start()
  br label %pfor.cond.i.i.i.i.i

pfor.cond.i.i.i.i.i:                              ; preds = %_ZN6parlay17sequence_internal13sequence_baseIiNS_9allocatorIiEELb0EE12storage_impl19initialize_capacityEm.exit.i.i.i.i.i.i.i.i.i.i.i, %pfor.cond.i.i.i.i.i, %entry
  detach within %syncreg.i.i.i.i.i.i, label %pfor.body.entry.i.i.i.i.i, label %pfor.cond.i.i.i.i.i unwind label %lpad.i.i.i.i.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp

pfor.body.entry.i.i.i.i.i:                        ; preds = %pfor.cond.i.i.i.i.i
  %tf.i.i.i.i.i.i = call token @llvm.taskframe.create()
  %call.i.i.i.i.i17.i.i.i.i.i.i.i.i.i.i.i = invoke ptr @_ZN6parlay9allocatorISt4byteE8allocateEm(ptr null, i64 0)
          to label %_ZN6parlay17sequence_internal13sequence_baseIiNS_9allocatorIiEELb0EE12storage_impl19initialize_capacityEm.exit.i.i.i.i.i.i.i.i.i.i.i unwind label %lpad.i.i.i.i.i.i.i.i.i.i.i

; CHECK: detach within %syncreg.i.i.i.i.i.i, label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[DET_UNWIND:.+]]

; CHECK: [[DETACHED]]:
; CHECK-NOT: call token @llvm.taskframe.create()
; CHECK-NEXT: invoke ptr @_ZN6parlay9allocatorISt4byteE8allocateEm(ptr null, i64 0)
; CHECK-NEXT: to label %[[INVOKE_CONT:.+]] unwind label %[[LPAD:.+]]

_ZN6parlay17sequence_internal13sequence_baseIiNS_9allocatorIiEELb0EE12storage_impl19initialize_capacityEm.exit.i.i.i.i.i.i.i.i.i.i.i: ; preds = %pfor.body.entry.i.i.i.i.i
  call void @llvm.taskframe.end(token %tf.i.i.i.i.i.i)
  reattach within %syncreg.i.i.i.i.i.i, label %pfor.cond.i.i.i.i.i

; CHECK: [[INVOKE_CONT]]:
; CHECK-NOT: call void @llvm.taskframe.end
; CHECK-NEXT: reattach within %syncreg.i.i.i.i.i.i, label %[[CONTINUE]]

lpad.i.i.i.i.i.i.i.i.i.i.i:                       ; preds = %pfor.body.entry.i.i.i.i.i
  %0 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i32s(token %tf.i.i.i.i.i.i, { ptr, i32 } zeroinitializer)
          to label %"_ZZN6parlay8sequenceINS0_IiNS_9allocatorIiEELb0EEENS1_IS3_EELb0EEC1IZN44TestPrimitives_TestFlattenNestedDelayed_Test8TestBodyEvE3$_0EEmOT_NS5_18_from_function_tagEmENKUlmE_clEm.unreachable.i.i.i.i.i" unwind label %lpad.i.i.i.i.i.i.split.i.i.i.i.i

lpad.i.i.i.i.i.i.split.i.i.i.i.i:                 ; preds = %lpad.i.i.i.i.i.i.i.i.i.i.i
  %1 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg.i.i.i.i.i.i, { ptr, i32 } zeroinitializer)
          to label %"_ZZN6parlay8sequenceINS0_IiNS_9allocatorIiEELb0EEENS1_IS3_EELb0EEC1IZN44TestPrimitives_TestFlattenNestedDelayed_Test8TestBodyEvE3$_0EEmOT_NS5_18_from_function_tagEmENKUlmE_clEm.unreachable.i.i.i.i.i" unwind label %lpad.i.i.i.i.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp

; CHECK: [[LPAD]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NOT: @llvm.taskframe.resume
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg.i.i.i.i.i.i,
; CHECK-NEXT: to label %{{.+}} unwind label %[[DET_UNWIND]]

"_ZZN6parlay8sequenceINS0_IiNS_9allocatorIiEELb0EEENS1_IS3_EELb0EEC1IZN44TestPrimitives_TestFlattenNestedDelayed_Test8TestBodyEvE3$_0EEmOT_NS5_18_from_function_tagEmENKUlmE_clEm.unreachable.i.i.i.i.i": ; preds = %lpad.i.i.i.i.i.i.split.i.i.i.i.i, %lpad.i.i.i.i.i.i.i.i.i.i.i
  unreachable

lpad.i.i.i.i.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp: ; preds = %lpad.i.i.i.i.i.i.split.i.i.i.i.i, %pfor.cond.i.i.i.i.i
  %lpad.loopexit.split-lp147 = landingpad { ptr, i32 }
          cleanup
  %call.i.i20.i.i.i.i = call ptr @_ZN6parlay17sequence_internal13sequence_baseINS_8sequenceIiNS_9allocatorIiEELb0EEENS3_IS5_EELb0EE12storage_implD2Ev()
  unreachable
}

declare ptr @_ZN6parlay9allocatorISt4byteE8allocateEm()

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.resume.sl_p0i32s(token, { ptr, i32 }) #1

define ptr @_ZN6parlay17sequence_internal13sequence_baseINS_8sequenceIiNS_9allocatorIiEELb0EEENS3_IS5_EELb0EE12storage_implD2Ev() personality ptr null {
entry:
  ret ptr null
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.end(token) #0

; uselistorder directives
uselistorder ptr null, { 1, 4, 5, 0, 3, 6, 7, 2 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { willreturn memory(argmem: readwrite) }
