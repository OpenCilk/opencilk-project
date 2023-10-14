; Check that jump threading releases value handles to basic blocks
; containing Tapir instructions.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(function<eager-inv>(jump-threading,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>)))" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define linkonce_odr void @_ZN4gbbs8nn_chain3HACINS_10MinLinkageINS_15symmetric_graphINS_16symmetric_vertexEjEENS_20SimilarityClusteringENS_12ActualWeightEEES4_jEEDaRNS3_IT0_T1_EERT_() personality ptr null {
entry:
  unreachable

pfor.body.entry.i.i.i:                            ; preds = %pfor.inc.i.i.i
  reattach within none, label %pfor.inc.i.i.i

pfor.inc.i.i.i:                                   ; preds = %pfor.inc.i.i.i, %pfor.body.entry.i.i.i
  detach within none, label %pfor.body.entry.i.i.i, label %pfor.inc.i.i.i
}

; CHECK: define linkonce_odr void @_ZN4gbbs8nn_chain3HACINS_10MinLinkageINS_15symmetric_graphINS_16symmetric_vertexEjEENS_20SimilarityClusteringENS_12ActualWeightEEES4_jEEDaRNS3_IT0_T1_EERT_()
; CHECK: entry:
; CHECK-NEXT: unreachable
; CHECK-NOT: pfor.body.entry.i.i.i:
; CHECK-NOT: reattach
; CHECK-NOT: pfor.inc.i.i.i:
; CHECK-NOT: detach

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }
