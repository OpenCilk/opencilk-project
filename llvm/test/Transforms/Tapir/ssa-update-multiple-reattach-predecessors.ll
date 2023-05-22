; Check that SSAUpdater handles inserting PHI nodes into blocks with
; multiple reattach predecessors.
;
; RUN: opt < %s -passes="function<eager-inv>(lcssa)" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define linkonce_odr void @_Z10matmul_dacIfLb0ELb1EEvPT_PKS0_S3_llllll(ptr %arrayidx83) {
if.end.lr.ph.lr.ph.preheader:
  br label %if.end.lr.ph.lr.ph

if.end.lr.ph.lr.ph:                               ; preds = %tailrecurse.outer.outer.backedge, %if.end.lr.ph.lr.ph.preheader
  br label %if.end.lr.ph

if.end.lr.ph:                                     ; preds = %if.end.lr.ph.lr.ph
  br label %if.end

if.end:                                           ; preds = %_ZL9split_diml.exit174, %if.end.lr.ph
  %lhs.tr2511 = phi ptr [ null, %if.end.lr.ph ], [ %arrayidx83, %_ZL9split_diml.exit174 ]
  br i1 false, label %land.lhs.true, label %if.else57

land.lhs.true:                                    ; preds = %if.end
  br label %det.cont22.tf

det.cont22.tf:                                    ; preds = %land.lhs.true
  detach within none, label %det.achd32, label %tailrecurse.outer.outer.backedge

det.achd32:                                       ; preds = %det.cont22.tf
  reattach within none, label %tailrecurse.outer.outer.backedge

if.else57:                                        ; preds = %if.end
  br i1 false, label %if.then59, label %if.else75

if.then59:                                        ; preds = %if.else57
  br label %_ZL9split_diml.exit164

_ZL9split_diml.exit164:                           ; preds = %if.then59
  detach within none, label %det.achd66, label %tailrecurse.outer.outer.backedge

det.achd66:                                       ; preds = %_ZL9split_diml.exit164
  reattach within none, label %tailrecurse.outer.outer.backedge

tailrecurse.outer.outer.backedge:                 ; preds = %det.achd66, %_ZL9split_diml.exit164, %det.achd32, %det.cont22.tf
  %lhs.tr.ph.ph.be = getelementptr inbounds float, ptr %lhs.tr2511, i64 0
  br label %if.end.lr.ph.lr.ph

; CHECK: tailrecurse.outer.outer.backedge:
; CHECK-NEXT: %[[NEW_PHI:.+]] = phi ptr
; CHECK: [ %[[VAL1:.+]], %_ZL9split_diml.exit164 ]
; CHECK: [ %[[VAL2:.+]], %det.cont22.tf ]
; CHECK-DAG: [ %[[VAL1]], %det.achd66 ]
; CHECK-DAG: [ %[[VAL2]], %det.achd32 ]
; CHECK-NEXT: %lhs.tr.ph.ph.be = getelementptr inbounds float, ptr %[[NEW_PHI]], i64 0

if.else75:                                        ; preds = %if.else57
  br label %_ZL9split_diml.exit174

_ZL9split_diml.exit174:                           ; preds = %if.else75
  br label %if.end
}
