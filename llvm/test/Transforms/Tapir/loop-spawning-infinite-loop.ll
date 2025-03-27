; Check that loop spawning does not attempt to process infinite Tapir loops.
;
; RUN: opt < %s -passes="loop-spawning" -pass-remarks-analysis=loop-spawning -disable-output 2>&1 | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

define void @_ZN6parlay8internal13bucket_sort_rIPSt5tupleIJmmEES4_N4cpam5buildINS5_14map_full_entryIN17ConcurrentAdaptor10MapAdaptorImmE5entryEEEE4lessMUlS3_S3_E_EEEvNS_5sliceIT_SH_EENSG_IT0_SJ_EET1_bb() personality ptr null {
entry:
  %syncreg15.i.i.i.i = call token @llvm.syncregion.start()
  br label %pfor.cond.i.i.i.i.strpm.outer

pfor.cond.i.i.i.i.strpm.outer:                    ; preds = %pfor.inc.i.i.i.i.strpm.outer, %entry
  detach within %syncreg15.i.i.i.i, label %pfor.body.entry.i.i.i.i.strpm.outer, label %pfor.inc.i.i.i.i.strpm.outer

pfor.body.entry.i.i.i.i.strpm.outer:              ; preds = %pfor.cond.i.i.i.i.strpm.outer
  reattach within %syncreg15.i.i.i.i, label %pfor.inc.i.i.i.i.strpm.outer

pfor.inc.i.i.i.i.strpm.outer:                     ; preds = %pfor.body.entry.i.i.i.i.strpm.outer, %pfor.cond.i.i.i.i.strpm.outer
  br label %pfor.cond.i.i.i.i.strpm.outer, !llvm.loop !0
}

; CHECK: Tapir loop not transformed: loop latch not terminated by a conditional branch

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }

!0 = distinct !{!0, !1, !2, !3}
!1 = !{!"llvm.loop.mustprogress"}
!2 = !{!"tapir.loop.spawn.strategy", i32 1}
!3 = !{!"tapir.loop.grainsize", i32 1}
