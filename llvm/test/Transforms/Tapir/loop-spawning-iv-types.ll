; RUN: opt < %s -indvars -loop-spawning-ti -S -o - | FileCheck %s
; RUN: opt < %s -passes='function(loop(indvars)),loop-spawning' -S -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$_Z10doSort_topIdEvPmS0_PjS1_PT_S3_jjjjjjj = comdat any

define void @_Z10doSort_topIdEvPmS0_PjS1_PT_S3_jjjjjjj(i32 %np) local_unnamed_addr #0 comdat {
entry:
  %syncreg165 = tail call token @llvm.syncregion.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %entry
  detach within %syncreg165, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  unreachable

pfor.inc:                                         ; preds = %pfor.cond
  br i1 undef, label %pfor.cond.cleanup, label %pfor.cond

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg165, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  br label %for.cond37.preheader

for.cond37.preheader:                             ; preds = %sync.continue
  switch i32 %np, label %for.body40 [
    i32 0, label %for.cond.cleanup39
    i32 1, label %for.cond.cleanup39.loopexit.unr-lcssa
  ]

for.cond.cleanup34:                               ; preds = %for.cond.cleanup39
  br label %pfor.cond70
; CHECK: for.cond.cleanup34:
; CHECK: %[[WIDETRIPCOUNT:.+]] = zext i32 %np to i64
; CHECK: call {{.*}}void @_Z10doSort_topIdEvPmS0_PjS1_PT_S3_jjjjjjj.outline_pfor.cond70.ls1(i64 0, i64 %[[WIDETRIPCOUNT]], i64 1)
; CHECK: %pfor.cond.cleanup143

for.cond.cleanup39.loopexit.unr-lcssa:            ; preds = %for.cond37.preheader
  unreachable

for.cond.cleanup39:                               ; preds = %for.cond37.preheader
  br label %for.cond.cleanup34

for.body40:                                       ; preds = %for.cond37.preheader
  unreachable

pfor.cond70:                                      ; preds = %pfor.inc140, %for.cond.cleanup34
  %indvar = phi i64 [ %indvar.next, %pfor.inc140 ], [ 0, %for.cond.cleanup34 ]
  %__begin64.0 = phi i32 [ %inc141, %pfor.inc140 ], [ 0, %for.cond.cleanup34 ]
  detach within %syncreg165, label %pfor.body76, label %pfor.inc140

pfor.body76:                                      ; preds = %pfor.cond70
  br label %for.body92.lr.ph

for.body92.lr.ph:                                 ; preds = %pfor.body76
  unreachable

pfor.inc140:                                      ; preds = %pfor.cond70
  %inc141 = add nuw nsw i32 %__begin64.0, 1
  %exitcond389 = icmp eq i32 %inc141, %np
  %indvar.next = add i64 %indvar, 1
  br i1 %exitcond389, label %pfor.cond.cleanup143, label %pfor.cond70, !llvm.loop !1

pfor.cond.cleanup143:                             ; preds = %pfor.inc140
  unreachable
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

attributes #0 = { "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }

!llvm.ident = !{!0}

!0 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git af592c078a4129622f80fbbe0288dc984e63ff40)"}
!1 = distinct !{!1, !2, !3}
!2 = !{!"tapir.loop.spawn.strategy", i32 1}
!3 = !{!"tapir.loop.grainsize", i32 1}
