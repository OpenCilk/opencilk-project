; Check that loop stripmining properly handles Tapir loops where the
; primary IV and the tripcount have different types.
;
; RUN: opt < %s -loop-stripmine -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-stripmine' -S -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

define dso_local fastcc void @_ZL9conj_gradPiS_PdS0_S0_S0_S0_S0_S0_S0_() unnamed_addr #1 {
entry:
  %syncreg143 = tail call token @llvm.syncregion.start()
  detach within %syncreg143, label %pfor.body.i, label %pfor.inc.i

pfor.body.i:                                      ; preds = %entry
  unreachable

pfor.inc.i:                                       ; preds = %entry
  sync within %syncreg143, label %_Z10initializePdS_S_S_S_mm.exit

_Z10initializePdS_S_S_S_mm.exit:                  ; preds = %pfor.inc.i
  detach within %syncreg143, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %_Z10initializePdS_S_S_S_mm.exit
  unreachable

pfor.inc:                                         ; preds = %_Z10initializePdS_S_S_S_mm.exit
  sync within %syncreg143, label %sync.continue

sync.continue:                                    ; preds = %pfor.inc
  detach within %syncreg143, label %pfor.body.i122, label %pfor.inc.i124

pfor.body.i122:                                   ; preds = %sync.continue
  unreachable

pfor.inc.i124:                                    ; preds = %sync.continue
  sync within %syncreg143, label %pfor.cond.i136

pfor.cond.i136:                                   ; preds = %pfor.inc.i124
  detach within %syncreg143, label %pfor.body.i142, label %pfor.inc.i144

pfor.body.i142:                                   ; preds = %pfor.cond.i136
  unreachable

pfor.inc.i144:                                    ; preds = %pfor.cond.i136
  sync within %syncreg143, label %cleanup.tf.tfend

cleanup.tf.tfend:                                 ; preds = %pfor.inc.i144
  detach within %syncreg143, label %pfor.body.i105, label %pfor.inc.i107

pfor.body.i105:                                   ; preds = %cleanup.tf.tfend
  unreachable

pfor.inc.i107:                                    ; preds = %cleanup.tf.tfend
  sync within %syncreg143, label %_Z11map_add_mulPdS_S_dmm.exit.tfend.tfend

_Z11map_add_mulPdS_S_dmm.exit.tfend.tfend:        ; preds = %pfor.inc.i107
  detach within %syncreg143, label %pfor.body73, label %pfor.inc101

pfor.body73:                                      ; preds = %_Z11map_add_mulPdS_S_dmm.exit.tfend.tfend
  unreachable

pfor.inc101:                                      ; preds = %_Z11map_add_mulPdS_S_dmm.exit.tfend.tfend
  sync within %syncreg143, label %sync.continue106

sync.continue106:                                 ; preds = %pfor.inc101
  br label %pfor.cond157

pfor.cond157:                                     ; preds = %pfor.inc177, %sync.continue106
  %indvars.iv164 = phi i64 [ 0, %sync.continue106 ], [ %indvars.iv.next165, %pfor.inc177 ]
  %indvars.iv.next165 = add nuw nsw i64 %indvars.iv164, 1
  detach within %syncreg143, label %pfor.body163, label %pfor.inc177

pfor.body163:                                     ; preds = %pfor.cond157
  reattach within %syncreg143, label %pfor.inc177

pfor.inc177:                                      ; preds = %pfor.body163, %pfor.cond157
  %lftr.wideiv = trunc i64 %indvars.iv.next165 to i32
  %exitcond = icmp eq i32 undef, %lftr.wideiv
  br i1 %exitcond, label %pfor.cond.cleanup180, label %pfor.cond157

; CHECK: pfor.cond157.strpm.outer:
; CHECK: %[[NITER:.+]] = phi i32 [ 0, %sync.continue106.new ], [ %[[NITER_ADD:.+]], %pfor.inc177.strpm.outer ]
; CHECK: detach within %syncreg143, label %pfor.body163.strpm.outer, label %pfor.inc177.strpm.outer

; CHECK: pfor.body163.strpm.outer:
; CHECK: mul i32 2048, %[[NITER]]

; CHECK: pfor.inc177.strpm.outer:
; CHECK: %[[NITER_ADD]] = add {{.*}}i32 %[[NITER]], 1

; CHECK: pfor.cond157.epil:
; CHECK: %[[INDVAR_EPIL:.+]] = phi i64
; CHECK: %[[EPIL_ITER:.+]] = phi i32

; CHECK: pfor.inc177.epil:
; CHECK: %[[EPIL_ITER_SUB:.+]] = sub i32 %[[EPIL_ITER]], 1
; CHECK: icmp ne i32 %[[EPIL_ITER_SUB]], 0

pfor.cond.cleanup180:                             ; preds = %pfor.inc177
  unreachable
}

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 10.0.1 (git@github.com:neboat/opencilk-project.git 2c7e581b441a9ae5682f02090613d00aaa26460d)"}
