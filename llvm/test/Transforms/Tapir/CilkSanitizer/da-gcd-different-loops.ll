; Check that DependenceAnalysis properly handles memory accesses in
; different loops.
;
; RUN: opt < %s -enable-new-pm=0 -analyze -da 2>&1 | FileCheck %s
; RUN: opt < %s -disable-output -passes='print<da>' 2>&1 | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.sqrt.f64(double) #1

define dso_local void @particleFilter() local_unnamed_addr {
entry:
  %syncreg603 = tail call token @llvm.syncregion.start()
  br label %for.cond1.preheader.us.i

for.cond1.preheader.us.i:                         ; preds = %for.cond1.for.inc14_crit_edge.us.i, %entry
  br label %for.body3.us.i

for.body3.us.i:                                   ; preds = %if.end.us.i, %for.cond1.preheader.us.i
  br label %if.end.us.i

if.end.us.i:                                      ; preds = %for.body3.us.i
  br i1 undef, label %for.cond1.for.inc14_crit_edge.us.i, label %for.body3.us.i, !llvm.loop !0

for.cond1.for.inc14_crit_edge.us.i:               ; preds = %if.end.us.i
  br i1 undef, label %for.cond14.preheader.preheader, label %for.cond1.preheader.us.i, !llvm.loop !2

for.cond14.preheader.preheader:                   ; preds = %for.cond1.for.inc14_crit_edge.us.i
  br label %for.cond2.preheader.us.i

for.cond2.preheader.us.i:                         ; preds = %for.inc.us.i.8, %for.cond14.preheader.preheader
  br label %for.inc.us.i

for.inc.us.i:                                     ; preds = %for.cond2.preheader.us.i
  br label %for.inc.us.i.1

getneighbors.exit:                                ; preds = %for.inc.us.i.8
  br label %cleanup

cleanup:                                          ; preds = %getneighbors.exit
  %call82 = call i8* undef(i64 undef)
  %0 = bitcast i8* %call82 to i32*
  br label %cleanup117

cleanup117:                                       ; preds = %cleanup
  br label %for.body127.lr.ph

for.body127.lr.ph:                                ; preds = %cleanup117
  %1 = and i32 undef, -2048
  %2 = zext i32 %1 to i64
  br label %for.body127

for.body127:                                      ; preds = %for.body127.lr.ph
  br label %cleanup171

cleanup171:                                       ; preds = %for.body127
  br label %pfor.cond191.preheader

pfor.cond191.preheader:                           ; preds = %cleanup171
  br label %pfor.cond191

pfor.cond191:                                     ; preds = %pfor.inc312, %pfor.cond191.preheader
  %indvars.iv1208 = phi i64 [ %indvars.iv.next1209, %pfor.inc312 ], [ 0, %pfor.cond191.preheader ]
  %indvars.iv.next1209 = add nuw nsw i64 %indvars.iv1208, 1
  detach within %syncreg603, label %pfor.body197, label %pfor.inc312

pfor.body197:                                     ; preds = %pfor.cond191
  br label %pfor.cond212.preheader

pfor.cond212.preheader:                           ; preds = %pfor.body197
  %3 = mul nuw nsw i64 %indvars.iv1208, undef
  br label %pfor.cond.cleanup265.strpm-lcssa

pfor.cond.cleanup265.strpm-lcssa:                 ; preds = %pfor.cond212.preheader
  switch i64 undef, label %vector.ph1557 [
    i64 0, label %for.body279.lr.ph
  ]

vector.ph1557:                                    ; preds = %pfor.cond.cleanup265.strpm-lcssa
  br label %vector.body1555

vector.body1555:                                  ; preds = %vector.body1555, %vector.ph1557
  %index1560 = phi i64 [ 0, %vector.ph1557 ], [ undef, %vector.body1555 ]
  %offset.idx1567 = add i64 %index1560, %2
  %4 = add nuw nsw i64 %offset.idx1567, %3
  %5 = getelementptr inbounds i32, i32* %0, i64 %4
  %6 = bitcast i32* %5 to <2 x i32>*
  store <2 x i32> undef, <2 x i32>* %6, align 4, !tbaa !3
  br label %vector.body1555

for.body279.lr.ph:                                ; preds = %pfor.cond.cleanup265.strpm-lcssa
  br label %for.body279

for.body279:                                      ; preds = %for.body279, %for.body279.lr.ph
  %indvars.iv1203 = phi i64 [ undef, %for.body279 ], [ 0, %for.body279.lr.ph ]
  %indvars.iv.next1204 = or i64 %indvars.iv1203, 1
  %7 = add nuw nsw i64 %indvars.iv.next1204, %3
  %arrayidx283.1 = getelementptr inbounds i32, i32* %0, i64 %7
  %8 = load i32, i32* %arrayidx283.1, align 4, !tbaa !3
  br label %for.body279

pfor.inc312:                                      ; preds = %pfor.cond191
  br label %pfor.cond191

for.inc.us.i.1:                                   ; preds = %for.inc.us.i
  br label %for.inc.us.i.2

for.inc.us.i.2:                                   ; preds = %for.inc.us.i.1
  br label %for.inc.us.i.3

for.inc.us.i.3:                                   ; preds = %for.inc.us.i.2
  br label %for.inc.us.i.4

for.inc.us.i.4:                                   ; preds = %for.inc.us.i.3
  br label %for.inc.us.i.5

for.inc.us.i.5:                                   ; preds = %for.inc.us.i.4
  br label %for.inc.us.i.6

for.inc.us.i.6:                                   ; preds = %for.inc.us.i.5
  br label %for.inc.us.i.7

for.inc.us.i.7:                                   ; preds = %for.inc.us.i.6
  br label %for.inc.us.i.8

for.inc.us.i.8:                                   ; preds = %for.inc.us.i.7
  br i1 undef, label %getneighbors.exit, label %for.cond2.preheader.us.i, !llvm.loop !7
}

; CHECK: Src:  store <2 x i32> undef, <2 x i32>* %6, align 4, !tbaa !3 --> Dst:  %8 = load i32, i32* %arrayidx283.1, align 4, !tbaa !3
; CHECK-NEXT: da analyze - flow [|<]!

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #0

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x i32> @llvm.abs.v2i32(<2 x i32>, i1 immarg) #1

attributes #0 = { argmemonly nofree nosync nounwind willreturn }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }

!0 = distinct !{!0, !1}
!1 = !{!"llvm.loop.mustprogress"}
!2 = distinct !{!2, !1}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = distinct !{!7, !1}
