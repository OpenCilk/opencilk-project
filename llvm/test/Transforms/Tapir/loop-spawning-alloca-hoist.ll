; Check that loop-spawning hoists allocas out of the parallel-loop
; body but below the recursive calls in the generated helper.
;
; RUN: opt < %s -loop-spawning-ti -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.dcomplex = type { double, double }

@fftblock = dso_local local_unnamed_addr global i32 0, align 4
@fftblockpad = dso_local local_unnamed_addr global i32 0, align 4
@num_workers = dso_local local_unnamed_addr global i32 0, align 4
@worker_tmp = dso_local local_unnamed_addr global double** null, align 8
@_ZL4dims.2.0 = internal unnamed_addr global i1 false, align 8
@_ZL4dims.2.1 = internal unnamed_addr global i1 false, align 8
@_ZL4dims.2.2 = internal unnamed_addr global i1 false, align 8

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

; Function Attrs: norecurse nounwind uwtable
define void @_ZL6cffts3iPiPA256_A512_8dcomplexS3_PA18_S0_S5_(i32 %is, [256 x [512 x %struct.dcomplex]]* nocapture readonly %x, [256 x [512 x %struct.dcomplex]]* nocapture %xout) unnamed_addr #1 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %.b = load i1, i1* @_ZL4dims.2.0, align 8
  %0 = select i1 %.b, i32 512, i32 0
  br i1 %.b, label %while.body.i, label %_ZL5ilog2i.exit

pfor.cond.preheader:                              ; preds = %_ZL5ilog2i.exit.2
  %wide.trip.count31 = zext i32 %1 to i64
  br label %pfor.cond

while.body.i:                                     ; preds = %while.body.i, %entry
  %nn.09.i = phi i32 [ %shl.i, %while.body.i ], [ 2, %entry ]
  %shl.i = shl i32 %nn.09.i, 1
  %cmp1.i = icmp slt i32 %shl.i, %0
  br i1 %cmp1.i, label %while.body.i, label %_ZL5ilog2i.exit

_ZL5ilog2i.exit:                                  ; preds = %while.body.i, %entry
  %.b41 = load i1, i1* @_ZL4dims.2.1, align 8
  %1 = select i1 %.b41, i32 256, i32 0
  br i1 %.b41, label %while.body.i.1, label %while.cond.preheader.i.2

; CHECK-LABEL: define {{.*}}void @_ZL6cffts3iPiPA256_A512_8dcomplexS3_PA18_S0_S5_.outline_pfor.cond.ls1(

; CHECK: pfor.cond.preheader.ls1:
; CHECK: call token @llvm.syncregion.start()
; CHECK: br label %[[PREHEADER_SPLIT:.+]]

; CHECK: [[PREHEADER_SPLIT]]:
; CHECK: br i1 %{{.+}}, label %{{.+}}, label %[[LOOP_PREHEADER:.+]]

; CHECK: [[LOOP_PREHEADER]]:
; CHECK: %[[Y08ALLOC:.+]] = alloca [512 x [18 x %struct.dcomplex]], align 16
; CHECK: %[[Y19ALLOC:.+]] = alloca [512 x [18 x %struct.dcomplex]], align 16
; CHECK: br label %pfor.cond.ls1

; CHECK: pfor.cond.ls1:
; CHECK: br label %pfor.body.ls1

; CHECK: pfor.body.ls1:
; CHECK-NOT: alloca [512 x [18 x %struct.dcomplex]], align 16
; CHECK-NOT: alloca [512 x [18 x %struct.dcomplex]], align 16
; CHECK: %[[Y08BITCAST:.+]] = bitcast [512 x [18 x %struct.dcomplex]]* %[[Y08ALLOC]] to i8*
; CHECK: call void @llvm.lifetime.start.p0i8({{.+}}, i8* {{.*}}%[[Y08BITCAST]])
; CHECK: %[[Y19BITCAST:.+]] = bitcast [512 x [18 x %struct.dcomplex]]* %[[Y19ALLOC]] to i8*
; CHECK: call void @llvm.lifetime.start.p0i8({{.+}}, i8* {{.*}}%[[Y19BITCAST]])

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %indvars.iv29 = phi i64 [ 0, %pfor.cond.preheader ], [ %indvars.iv.next30, %pfor.inc ]
  %indvars.iv.next30 = add nuw nsw i64 %indvars.iv29, 1
  detach within %syncreg, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %y08 = alloca [512 x [18 x %struct.dcomplex]], align 16
  %y19 = alloca [512 x [18 x %struct.dcomplex]], align 16
  %2 = bitcast [512 x [18 x %struct.dcomplex]]* %y08 to i8*
  call void @llvm.lifetime.start.p0i8(i64 147456, i8* nonnull %2) #2
  %3 = bitcast [512 x [18 x %struct.dcomplex]]* %y19 to i8*
  call void @llvm.lifetime.start.p0i8(i64 147456, i8* nonnull %3) #2
  %.b39 = load i1, i1* @_ZL4dims.2.0, align 8
  %4 = select i1 %.b39, i32 512, i32 0
  %5 = load i32, i32* @fftblock, align 4, !tbaa !2
  %cmp1312 = icmp slt i32 %4, %5
  br i1 %cmp1312, label %for.end96, label %for.cond15.preheader.lr.ph

for.cond15.preheader.lr.ph:                       ; preds = %pfor.body
  %arraydecay = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 0
  %arraydecay54 = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y19, i64 0, i64 0
  br label %for.cond15.preheader

for.cond15.preheader:                             ; preds = %for.inc94, %for.cond15.preheader.lr.ph
  %6 = phi i32 [ %5, %for.cond15.preheader.lr.ph ], [ %32, %for.inc94 ]
  %ii.013 = phi i32 [ 0, %for.cond15.preheader.lr.ph ], [ %add95, %for.inc94 ]
  %.b44 = load i1, i1* @_ZL4dims.2.2, align 8
  %7 = select i1 %.b44, i32 256, i32 0
  %cmp201 = icmp sgt i32 %6, 0
  %or.cond36 = and i1 %.b44, %cmp201
  br i1 %or.cond36, label %for.cond19.preheader.us.preheader, label %for.end51

for.cond19.preheader.us.preheader:                ; preds = %for.cond15.preheader
  %8 = sext i32 %ii.013 to i64
  %9 = zext i32 %7 to i64
  %wide.trip.count = zext i32 %6 to i64
  %10 = add nsw i64 %wide.trip.count, -1
  %xtraiter = and i64 %wide.trip.count, 3
  %11 = icmp ult i64 %10, 3
  %unroll_iter = sub nsw i64 %wide.trip.count, %xtraiter
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br label %for.cond19.preheader.us

for.cond19.preheader.us:                          ; preds = %for.cond19.for.inc49_crit_edge.us, %for.cond19.preheader.us.preheader
  %indvars.iv20 = phi i64 [ 0, %for.cond19.preheader.us.preheader ], [ %indvars.iv.next21, %for.cond19.for.inc49_crit_edge.us ]
  br i1 %11, label %for.cond19.for.inc49_crit_edge.us.unr-lcssa, label %for.body21.us

for.body21.us:                                    ; preds = %for.body21.us, %for.cond19.preheader.us
  %indvars.iv = phi i64 [ %indvars.iv.next.3, %for.body21.us ], [ 0, %for.cond19.preheader.us ]
  %niter = phi i64 [ %niter.nsub.3, %for.body21.us ], [ %unroll_iter, %for.cond19.preheader.us ]
  %12 = add nsw i64 %indvars.iv, %8
  %arrayidx28.us = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %x, i64 %indvars.iv20, i64 %indvars.iv29, i64 %12
  %arrayidx32.us = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv20, i64 %indvars.iv
  %13 = bitcast %struct.dcomplex* %arrayidx28.us to <2 x i64>*
  %14 = load <2 x i64>, <2 x i64>* %13, align 8, !tbaa !6
  %15 = bitcast %struct.dcomplex* %arrayidx32.us to <2 x i64>*
  store <2 x i64> %14, <2 x i64>* %15, align 16, !tbaa !6
  %indvars.iv.next = or i64 %indvars.iv, 1
  %16 = add nsw i64 %indvars.iv.next, %8
  %arrayidx28.us.1 = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %x, i64 %indvars.iv20, i64 %indvars.iv29, i64 %16
  %arrayidx32.us.1 = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv20, i64 %indvars.iv.next
  %17 = bitcast %struct.dcomplex* %arrayidx28.us.1 to <2 x i64>*
  %18 = load <2 x i64>, <2 x i64>* %17, align 8, !tbaa !6
  %19 = bitcast %struct.dcomplex* %arrayidx32.us.1 to <2 x i64>*
  store <2 x i64> %18, <2 x i64>* %19, align 16, !tbaa !6
  %indvars.iv.next.1 = or i64 %indvars.iv, 2
  %20 = add nsw i64 %indvars.iv.next.1, %8
  %arrayidx28.us.2 = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %x, i64 %indvars.iv20, i64 %indvars.iv29, i64 %20
  %arrayidx32.us.2 = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv20, i64 %indvars.iv.next.1
  %21 = bitcast %struct.dcomplex* %arrayidx28.us.2 to <2 x i64>*
  %22 = load <2 x i64>, <2 x i64>* %21, align 8, !tbaa !6
  %23 = bitcast %struct.dcomplex* %arrayidx32.us.2 to <2 x i64>*
  store <2 x i64> %22, <2 x i64>* %23, align 16, !tbaa !6
  %indvars.iv.next.2 = or i64 %indvars.iv, 3
  %24 = add nsw i64 %indvars.iv.next.2, %8
  %arrayidx28.us.3 = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %x, i64 %indvars.iv20, i64 %indvars.iv29, i64 %24
  %arrayidx32.us.3 = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv20, i64 %indvars.iv.next.2
  %25 = bitcast %struct.dcomplex* %arrayidx28.us.3 to <2 x i64>*
  %26 = load <2 x i64>, <2 x i64>* %25, align 8, !tbaa !6
  %27 = bitcast %struct.dcomplex* %arrayidx32.us.3 to <2 x i64>*
  store <2 x i64> %26, <2 x i64>* %27, align 16, !tbaa !6
  %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv, 4
  %niter.nsub.3 = add i64 %niter, -4
  %niter.ncmp.3 = icmp eq i64 %niter.nsub.3, 0
  br i1 %niter.ncmp.3, label %for.cond19.for.inc49_crit_edge.us.unr-lcssa, label %for.body21.us

for.cond19.for.inc49_crit_edge.us.unr-lcssa:      ; preds = %for.body21.us, %for.cond19.preheader.us
  %indvars.iv.unr = phi i64 [ 0, %for.cond19.preheader.us ], [ %indvars.iv.next.3, %for.body21.us ]
  br i1 %lcmp.mod, label %for.cond19.for.inc49_crit_edge.us, label %for.body21.us.epil

for.body21.us.epil:                               ; preds = %for.body21.us.epil, %for.cond19.for.inc49_crit_edge.us.unr-lcssa
  %indvars.iv.epil = phi i64 [ %indvars.iv.next.epil, %for.body21.us.epil ], [ %indvars.iv.unr, %for.cond19.for.inc49_crit_edge.us.unr-lcssa ]
  %epil.iter = phi i64 [ %epil.iter.sub, %for.body21.us.epil ], [ %xtraiter, %for.cond19.for.inc49_crit_edge.us.unr-lcssa ]
  %28 = add nsw i64 %indvars.iv.epil, %8
  %arrayidx28.us.epil = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %x, i64 %indvars.iv20, i64 %indvars.iv29, i64 %28
  %arrayidx32.us.epil = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv20, i64 %indvars.iv.epil
  %29 = bitcast %struct.dcomplex* %arrayidx28.us.epil to <2 x i64>*
  %30 = load <2 x i64>, <2 x i64>* %29, align 8, !tbaa !6
  %31 = bitcast %struct.dcomplex* %arrayidx32.us.epil to <2 x i64>*
  store <2 x i64> %30, <2 x i64>* %31, align 16, !tbaa !6
  %indvars.iv.next.epil = add nuw nsw i64 %indvars.iv.epil, 1
  %epil.iter.sub = add i64 %epil.iter, -1
  %epil.iter.cmp = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp, label %for.cond19.for.inc49_crit_edge.us, label %for.body21.us.epil, !llvm.loop !8

for.cond19.for.inc49_crit_edge.us:                ; preds = %for.body21.us.epil, %for.cond19.for.inc49_crit_edge.us.unr-lcssa
  %indvars.iv.next21 = add nuw nsw i64 %indvars.iv20, 1
  %exitcond45 = icmp eq i64 %indvars.iv.next21, %9
  br i1 %exitcond45, label %for.end51, label %for.cond19.preheader.us

for.end51:                                        ; preds = %for.cond19.for.inc49_crit_edge.us, %for.cond15.preheader
  call fastcc void @_ZL5cfftziiiPA18_8dcomplexS1_(i32 %is, i32 %59, i32 %7, [18 x %struct.dcomplex]* nonnull %arraydecay, [18 x %struct.dcomplex]* nonnull %arraydecay54)
  %.b43 = load i1, i1* @_ZL4dims.2.2, align 8
  %32 = load i32, i32* @fftblock, align 4
  %cmp606 = icmp sgt i32 %32, 0
  %or.cond37 = and i1 %.b43, %cmp606
  br i1 %or.cond37, label %for.cond59.preheader.us.preheader, label %for.inc94

for.cond59.preheader.us.preheader:                ; preds = %for.end51
  %33 = sext i32 %ii.013 to i64
  %34 = select i1 %.b43, i64 256, i64 0
  %wide.trip.count25 = zext i32 %32 to i64
  %35 = add nsw i64 %wide.trip.count25, -1
  %xtraiter47 = and i64 %wide.trip.count25, 3
  %36 = icmp ult i64 %35, 3
  %unroll_iter50 = sub nsw i64 %wide.trip.count25, %xtraiter47
  %lcmp.mod49 = icmp eq i64 %xtraiter47, 0
  br label %for.cond59.preheader.us

for.cond59.preheader.us:                          ; preds = %for.cond59.for.inc91_crit_edge.us, %for.cond59.preheader.us.preheader
  %indvars.iv27 = phi i64 [ 0, %for.cond59.preheader.us.preheader ], [ %indvars.iv.next28, %for.cond59.for.inc91_crit_edge.us ]
  br i1 %36, label %for.cond59.for.inc91_crit_edge.us.unr-lcssa, label %for.body61.us

for.body61.us:                                    ; preds = %for.body61.us, %for.cond59.preheader.us
  %indvars.iv22 = phi i64 [ %indvars.iv.next23.3, %for.body61.us ], [ 0, %for.cond59.preheader.us ]
  %niter51 = phi i64 [ %niter51.nsub.3, %for.body61.us ], [ %unroll_iter50, %for.cond59.preheader.us ]
  %arrayidx65.us = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv27, i64 %indvars.iv22
  %37 = add nsw i64 %indvars.iv22, %33
  %arrayidx73.us = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %xout, i64 %indvars.iv27, i64 %indvars.iv29, i64 %37
  %38 = bitcast %struct.dcomplex* %arrayidx65.us to <2 x i64>*
  %39 = load <2 x i64>, <2 x i64>* %38, align 16, !tbaa !6
  %40 = bitcast %struct.dcomplex* %arrayidx73.us to <2 x i64>*
  store <2 x i64> %39, <2 x i64>* %40, align 8, !tbaa !6
  %indvars.iv.next23 = or i64 %indvars.iv22, 1
  %arrayidx65.us.1 = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv27, i64 %indvars.iv.next23
  %41 = add nsw i64 %indvars.iv.next23, %33
  %arrayidx73.us.1 = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %xout, i64 %indvars.iv27, i64 %indvars.iv29, i64 %41
  %42 = bitcast %struct.dcomplex* %arrayidx65.us.1 to <2 x i64>*
  %43 = load <2 x i64>, <2 x i64>* %42, align 16, !tbaa !6
  %44 = bitcast %struct.dcomplex* %arrayidx73.us.1 to <2 x i64>*
  store <2 x i64> %43, <2 x i64>* %44, align 8, !tbaa !6
  %indvars.iv.next23.1 = or i64 %indvars.iv22, 2
  %arrayidx65.us.2 = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv27, i64 %indvars.iv.next23.1
  %45 = add nsw i64 %indvars.iv.next23.1, %33
  %arrayidx73.us.2 = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %xout, i64 %indvars.iv27, i64 %indvars.iv29, i64 %45
  %46 = bitcast %struct.dcomplex* %arrayidx65.us.2 to <2 x i64>*
  %47 = load <2 x i64>, <2 x i64>* %46, align 16, !tbaa !6
  %48 = bitcast %struct.dcomplex* %arrayidx73.us.2 to <2 x i64>*
  store <2 x i64> %47, <2 x i64>* %48, align 8, !tbaa !6
  %indvars.iv.next23.2 = or i64 %indvars.iv22, 3
  %arrayidx65.us.3 = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv27, i64 %indvars.iv.next23.2
  %49 = add nsw i64 %indvars.iv.next23.2, %33
  %arrayidx73.us.3 = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %xout, i64 %indvars.iv27, i64 %indvars.iv29, i64 %49
  %50 = bitcast %struct.dcomplex* %arrayidx65.us.3 to <2 x i64>*
  %51 = load <2 x i64>, <2 x i64>* %50, align 16, !tbaa !6
  %52 = bitcast %struct.dcomplex* %arrayidx73.us.3 to <2 x i64>*
  store <2 x i64> %51, <2 x i64>* %52, align 8, !tbaa !6
  %indvars.iv.next23.3 = add nuw nsw i64 %indvars.iv22, 4
  %niter51.nsub.3 = add i64 %niter51, -4
  %niter51.ncmp.3 = icmp eq i64 %niter51.nsub.3, 0
  br i1 %niter51.ncmp.3, label %for.cond59.for.inc91_crit_edge.us.unr-lcssa, label %for.body61.us

for.cond59.for.inc91_crit_edge.us.unr-lcssa:      ; preds = %for.body61.us, %for.cond59.preheader.us
  %indvars.iv22.unr = phi i64 [ 0, %for.cond59.preheader.us ], [ %indvars.iv.next23.3, %for.body61.us ]
  br i1 %lcmp.mod49, label %for.cond59.for.inc91_crit_edge.us, label %for.body61.us.epil

for.body61.us.epil:                               ; preds = %for.body61.us.epil, %for.cond59.for.inc91_crit_edge.us.unr-lcssa
  %indvars.iv22.epil = phi i64 [ %indvars.iv.next23.epil, %for.body61.us.epil ], [ %indvars.iv22.unr, %for.cond59.for.inc91_crit_edge.us.unr-lcssa ]
  %epil.iter48 = phi i64 [ %epil.iter48.sub, %for.body61.us.epil ], [ %xtraiter47, %for.cond59.for.inc91_crit_edge.us.unr-lcssa ]
  %arrayidx65.us.epil = getelementptr inbounds [512 x [18 x %struct.dcomplex]], [512 x [18 x %struct.dcomplex]]* %y08, i64 0, i64 %indvars.iv27, i64 %indvars.iv22.epil
  %53 = add nsw i64 %indvars.iv22.epil, %33
  %arrayidx73.us.epil = getelementptr inbounds [256 x [512 x %struct.dcomplex]], [256 x [512 x %struct.dcomplex]]* %xout, i64 %indvars.iv27, i64 %indvars.iv29, i64 %53
  %54 = bitcast %struct.dcomplex* %arrayidx65.us.epil to <2 x i64>*
  %55 = load <2 x i64>, <2 x i64>* %54, align 16, !tbaa !6
  %56 = bitcast %struct.dcomplex* %arrayidx73.us.epil to <2 x i64>*
  store <2 x i64> %55, <2 x i64>* %56, align 8, !tbaa !6
  %indvars.iv.next23.epil = add nuw nsw i64 %indvars.iv22.epil, 1
  %epil.iter48.sub = add i64 %epil.iter48, -1
  %epil.iter48.cmp = icmp eq i64 %epil.iter48.sub, 0
  br i1 %epil.iter48.cmp, label %for.cond59.for.inc91_crit_edge.us, label %for.body61.us.epil, !llvm.loop !10

for.cond59.for.inc91_crit_edge.us:                ; preds = %for.body61.us.epil, %for.cond59.for.inc91_crit_edge.us.unr-lcssa
  %indvars.iv.next28 = add nuw nsw i64 %indvars.iv27, 1
  %exitcond46 = icmp eq i64 %indvars.iv.next28, %34
  br i1 %exitcond46, label %for.inc94, label %for.cond59.preheader.us

for.inc94:                                        ; preds = %for.cond59.for.inc91_crit_edge.us, %for.end51
  %add95 = add nsw i32 %32, %ii.013
  %.b40 = load i1, i1* @_ZL4dims.2.0, align 8
  %57 = select i1 %.b40, i32 512, i32 0
  %sub12 = sub nsw i32 %57, %32
  %cmp13 = icmp sgt i32 %add95, %sub12
  br i1 %cmp13, label %for.end96, label %for.cond15.preheader

for.end96:                                        ; preds = %for.inc94, %pfor.body
  call void @llvm.lifetime.end.p0i8(i64 147456, i8* nonnull %3) #2
  call void @llvm.lifetime.end.p0i8(i64 147456, i8* nonnull %2) #2
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %for.end96, %pfor.cond
  %exitcond32 = icmp eq i64 %indvars.iv.next30, %wide.trip.count31
  br i1 %exitcond32, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !11

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %_ZL5ilog2i.exit.2, %pfor.cond.cleanup
  ret void

while.body.i.1:                                   ; preds = %while.body.i.1, %_ZL5ilog2i.exit
  %nn.09.i.1 = phi i32 [ %shl.i.1, %while.body.i.1 ], [ 2, %_ZL5ilog2i.exit ]
  %shl.i.1 = shl i32 %nn.09.i.1, 1
  %cmp1.i.1 = icmp slt i32 %shl.i.1, %1
  br i1 %cmp1.i.1, label %while.body.i.1, label %while.cond.preheader.i.2

while.cond.preheader.i.2:                         ; preds = %while.body.i.1, %_ZL5ilog2i.exit
  %.b42 = load i1, i1* @_ZL4dims.2.2, align 8
  %58 = select i1 %.b42, i32 256, i32 0
  br i1 %.b42, label %while.body.i.2, label %_ZL5ilog2i.exit.2

while.body.i.2:                                   ; preds = %while.body.i.2, %while.cond.preheader.i.2
  %lg.010.i.2 = phi i32 [ %inc.i.2, %while.body.i.2 ], [ 1, %while.cond.preheader.i.2 ]
  %nn.09.i.2 = phi i32 [ %shl.i.2, %while.body.i.2 ], [ 2, %while.cond.preheader.i.2 ]
  %shl.i.2 = shl i32 %nn.09.i.2, 1
  %inc.i.2 = add nuw nsw i32 %lg.010.i.2, 1
  %cmp1.i.2 = icmp slt i32 %shl.i.2, %58
  br i1 %cmp1.i.2, label %while.body.i.2, label %_ZL5ilog2i.exit.2

_ZL5ilog2i.exit.2:                                ; preds = %while.body.i.2, %while.cond.preheader.i.2
  %59 = phi i32 [ 1, %while.cond.preheader.i.2 ], [ %inc.i.2, %while.body.i.2 ]
  br i1 %.b41, label %pfor.cond.preheader, label %cleanup
}

; Function Attrs: norecurse nounwind uwtable
declare void @_ZL5cfftziiiPA18_8dcomplexS1_(i32, i32, i32, [18 x %struct.dcomplex]* nocapture, [18 x %struct.dcomplex]* nocapture) unnamed_addr #1

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:neboat/opencilk-project.git f963102c6dc932d9bff01a71fbd39749dccb171f)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"double", !4, i64 0}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.unroll.disable"}
!10 = distinct !{!10, !9}
!11 = distinct !{!11, !12}
!12 = !{!"tapir.loop.spawn.strategy", i32 1}
