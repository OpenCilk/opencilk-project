; Check that loop exits account for unassociated taskframes properly in detached blocks.
;
; RUN: opt < %s -passes="function(tapir-indvars)" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

define void @_ZN31TestPrimitives_TestFlatten_Test8TestBodyEv() personality ptr null {
entry:
  %syncreg.i.i.i.i.i113 = tail call token @llvm.syncregion.start()
  br label %pfor.cond.i.i.i.i.i

pfor.cond.i.i.i.i.i:                              ; preds = %pfor.inc.i.i.i.i.i, %entry
  %__begin.0.i.i.i.i.i = phi i64 [ 0, %entry ], [ %inc.i.i.i.i.i, %pfor.inc.i.i.i.i.i ]
  detach within %syncreg.i.i.i.i.i113, label %pfor.body.entry.i.i.i.i.i, label %pfor.inc.i.i.i.i.i unwind label %lpad.i.i.i.i.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp

pfor.body.entry.i.i.i.i.i:                        ; preds = %pfor.cond.i.i.i.i.i
  %tf.i.i.i.i.i.i = call token @llvm.taskframe.create()
  invoke void @llvm.taskframe.resume.sl_p0i32s(token %tf.i.i.i.i.i.i, { ptr, i32 } zeroinitializer)
          to label %"_ZZN6parlay8sequenceINS0_ImNS_9allocatorImEELb0EEENS1_IS3_EELb0EEC1IZN31TestPrimitives_TestFlatten_Test8TestBodyEvE3$_0EEmOT_NS5_18_from_function_tagEmENKUlmE_clEm.unreachable.i.i.i.i.i" unwind label %lpad.i.i.i.i.i.i.split.i.i.i.i.i

lpad.i.i.i.i.i.i.split.i.i.i.i.i:                 ; preds = %pfor.body.entry.i.i.i.i.i
  %0 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg.i.i.i.i.i113, { ptr, i32 } zeroinitializer)
          to label %"_ZZN6parlay8sequenceINS0_ImNS_9allocatorImEELb0EEENS1_IS3_EELb0EEC1IZN31TestPrimitives_TestFlatten_Test8TestBodyEvE3$_0EEmOT_NS5_18_from_function_tagEmENKUlmE_clEm.unreachable.i.i.i.i.i" unwind label %lpad.i.i.i.i.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp

"_ZZN6parlay8sequenceINS0_ImNS_9allocatorImEELb0EEENS1_IS3_EELb0EEC1IZN31TestPrimitives_TestFlatten_Test8TestBodyEvE3$_0EEmOT_NS5_18_from_function_tagEmENKUlmE_clEm.unreachable.i.i.i.i.i": ; preds = %lpad.i.i.i.i.i.i.split.i.i.i.i.i, %pfor.body.entry.i.i.i.i.i
  unreachable

pfor.inc.i.i.i.i.i:                               ; preds = %pfor.cond.i.i.i.i.i
  %inc.i.i.i.i.i = add i64 %__begin.0.i.i.i.i.i, 1
  %cmp2.i.i.i.i.i = icmp ult i64 %inc.i.i.i.i.i, 100
  br i1 %cmp2.i.i.i.i.i, label %pfor.cond.i.i.i.i.i, label %pfor.cond.cleanup.i.i.i.i.i, !llvm.loop !0

; CHECK: pfor.inc.i.i.i.i.i:
; CHECK-NEXT: %inc.i.i.i.i.i = add nuw nsw i64 %__begin.0.i.i.i.i.i, 1
; CHECK-NOT: icmp ult
; CHECK-NEXT: %exitcond = icmp ne i64 %inc.i.i.i.i.i, 100
; CHECK-NEXT: br i1 %exitcond, label %pfor.cond.i.i.i.i.i, label %pfor.cond.cleanup.i.i.i.i.i

pfor.cond.cleanup.i.i.i.i.i:                      ; preds = %pfor.inc.i.i.i.i.i
  ret void

lpad.i.i.i.i.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp.loopexit.split-lp: ; preds = %lpad.i.i.i.i.i.i.split.i.i.i.i.i, %pfor.cond.i.i.i.i.i
  %lpad.loopexit.split-lp199 = landingpad { ptr, i32 }
          cleanup
  unreachable
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.resume.sl_p0i32s(token, { ptr, i32 }) #1

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { willreturn memory(argmem: readwrite) }

!0 = distinct !{!0, !1, !2, !3}
!1 = !{!"llvm.loop.mustprogress"}
!2 = !{!"tapir.loop.spawn.strategy", i32 1}
!3 = !{!"llvm.loop.unroll.disable"}
