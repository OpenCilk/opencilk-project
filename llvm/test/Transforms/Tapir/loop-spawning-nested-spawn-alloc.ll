; Check that loop-spawning and task-simplify correctly handle a static memory allocation and
; nested spawn within a parallel loop body.
;
; RUN: opt < %s -passes="loop-spawning,task-simplify" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx14.0.0"

%struct.ggml_type_traits_t = type { ptr, i32, i64, i8, ptr, ptr, ptr, ptr, i32, i64 }
%struct.ggml_tensor = type { i32, i32, ptr, [4 x i64], [4 x i64], i32, [16 x i32], i32, ptr, [10 x ptr], i32, i64, i64, ptr, i64, ptr, [64 x i8], ptr, [8 x i8] }

@type_traits = local_unnamed_addr constant [24 x %struct.ggml_type_traits_t] zeroinitializer, align 8

; Function Attrs: nounwind ssp uwtable(sync)
define void @ggml_compute_forward_mul_mat(ptr nocapture noundef readnone %params, ptr nocapture noundef readonly %dst) local_unnamed_addr #0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %src = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 9
  %0 = load ptr, ptr %src, align 8, !tbaa !6
  %arrayidx3 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 9, i64 1
  %1 = load ptr, ptr %arrayidx3, align 8, !tbaa !6
  %arrayidx6 = getelementptr inbounds %struct.ggml_tensor, ptr %0, i64 0, i32 3, i64 1
  %2 = load i64, ptr %arrayidx6, align 8, !tbaa !10
  %ne18 = getelementptr inbounds %struct.ggml_tensor, ptr %1, i64 0, i32 3
  %3 = load i64, ptr %ne18, align 8, !tbaa !10
  %arrayidx21 = getelementptr inbounds %struct.ggml_tensor, ptr %1, i64 0, i32 3, i64 1
  %4 = load i64, ptr %arrayidx21, align 8, !tbaa !10
  %arrayidx23 = getelementptr inbounds %struct.ggml_tensor, ptr %1, i64 0, i32 3, i64 2
  %5 = load i64, ptr %arrayidx23, align 8, !tbaa !10
  %arrayidx25 = getelementptr inbounds %struct.ggml_tensor, ptr %1, i64 0, i32 3, i64 3
  %6 = load i64, ptr %arrayidx25, align 8, !tbaa !10
  %arrayidx38 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 3, i64 1
  %7 = load i64, ptr %arrayidx38, align 8, !tbaa !10
  %arrayidx46 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 1
  %8 = load i64, ptr %arrayidx46, align 8, !tbaa !12
  %arrayidx48 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 2
  %9 = load i64, ptr %arrayidx48, align 8, !tbaa !12
  %arrayidx50 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 3
  %10 = load i64, ptr %arrayidx50, align 8, !tbaa !12
  %call = tail call zeroext i1 @ggml_is_contiguous(ptr noundef %1) #7
  %call64 = tail call i64 @ggml_row_size(i32 noundef 0, i64 noundef %3) #7
  %mul = mul i64 %7, %5
  %mul65 = mul nsw i64 %mul, %6
  %11 = and i64 %2, 1
  %cmp96.not = icmp ne i64 %11, 0
  %12 = and i64 %4, 1
  %cmp99.not = icmp ne i64 %12, 0
  %or.cond.not = select i1 %cmp96.not, i1 true, i1 %cmp99.not
  %or.cond.not.fr = freeze i1 %or.cond.not
  %nrc.0 = zext i1 %or.cond.not.fr to i64
  %cmp110 = icmp sgt i64 %2, 0
  br i1 %cmp110, label %pfor.ph, label %cleanup272

pfor.ph:                                          ; preds = %entry
  %sub113 = add nsw i64 %2, -1
  %div114425 = lshr i64 %sub113, 4
  %cmp121 = icmp sgt i64 %mul65, 0
  %data184 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 15
  %brmerge.not = and i1 %cmp121, %or.cond.not.fr
  br i1 %brmerge.not, label %pfor.cond.us.us.preheader, label %pfor.cond.cleanup267

pfor.cond.us.us.preheader:                        ; preds = %pfor.ph
  %sub129 = add nsw i64 %mul65, -1
  %div130426 = lshr i64 %sub129, 4
  %xtraiter = and i64 %div130426, 1
  %13 = add nuw nsw i64 %xtraiter, 1
  %14 = icmp ult i64 %mul65, 33
  %stripiter453 = lshr i64 %sub129, 5
  %15 = and i64 %div130426, 1152921504606846974
  br label %pfor.cond.us.us

pfor.cond.us.us:                                  ; preds = %pfor.cond.us.us.preheader, %pfor.inc263.us.us
  %__begin.0.us.us = phi i64 [ %inc264.us.us, %pfor.inc263.us.us ], [ 0, %pfor.cond.us.us.preheader ]
  %mul116.us.us = shl nsw i64 %__begin.0.us.us, 4
  detach within %syncreg, label %pfor.ph125.us.us, label %pfor.inc263.us.us

pfor.ph125.us.us:                                 ; preds = %pfor.cond.us.us
  %tmp.us.us.us.epil = alloca [32 x float], align 4
  %syncreg118.us.us = tail call token @llvm.syncregion.start()
  %add192.us.us = add nuw nsw i64 %mul116.us.us, 16
  %cmp196.us.us = icmp sge i64 %mul116.us.us, %2
  %cond244.us.us = tail call i64 @llvm.smin.i64(i64 %add192.us.us, i64 %2)
  %sub245.us.us = sub nsw i64 %cond244.us.us, %mul116.us.us
  %mul246.us.us = shl i64 %sub245.us.us, 2
  br i1 %14, label %pfor.cond132.us.us.us.epil.preheader, label %pfor.ph125.us.us.new

pfor.ph125.us.us.new:                             ; preds = %pfor.ph125.us.us
  detach within %syncreg118.us.us, label %pfor.cond132.us.us.us.strpm.detachloop.entry, label %pfor.cond132.us.us.us.epil.preheader

pfor.cond132.us.us.us.epil.preheader:             ; preds = %pfor.ph125.us.us, %pfor.cond132.us.us.us.strpm.detachloop.reattach.split, %pfor.ph125.us.us.new
  br label %pfor.cond132.us.us.us.epil

cleanup.us.us:                                    ; preds = %pfor.cond.cleanup.split.us.us.us
  reattach within %syncreg, label %pfor.inc263.us.us

pfor.inc263.us.us:                                ; preds = %cleanup.us.us, %pfor.cond.us.us
  %inc264.us.us = add nuw nsw i64 %__begin.0.us.us, 1
  %exitcond449.not = icmp eq i64 %__begin.0.us.us, %div114425
  br i1 %exitcond449.not, label %pfor.cond.cleanup267, label %pfor.cond.us.us, !llvm.loop !14

pfor.cond132.us.us.us.strpm.detachloop.entry:     ; preds = %pfor.ph125.us.us.new
  %syncreg118.us.us.strpm.detachloop = tail call token @llvm.syncregion.start()
  br label %pfor.cond132.us.us.us.strpm.outer

pfor.cond132.us.us.us.strpm.outer:                ; preds = %pfor.inc.us.us.us.strpm.outer, %pfor.cond132.us.us.us.strpm.detachloop.entry
  %niter = phi i64 [ 0, %pfor.cond132.us.us.us.strpm.detachloop.entry ], [ %niter.nadd, %pfor.inc.us.us.us.strpm.outer ]
  detach within %syncreg118.us.us.strpm.detachloop, label %pfor.body137.us.us.us.strpm.outer, label %pfor.inc.us.us.us.strpm.outer

pfor.body137.us.us.us.strpm.outer:                ; preds = %pfor.cond132.us.us.us.strpm.outer
  %tmp.us.us.us = alloca [32 x float], align 4
  %16 = shl nuw i64 %niter, 1
  br label %pfor.cond132.us.us.us

pfor.cond132.us.us.us:                            ; preds = %pfor.body137.us.us.us.strpm.outer, %for.cond.cleanup.us.us.us
  %__begin126.0.us.us.us = phi i64 [ %inc258.us.us.us, %for.cond.cleanup.us.us.us ], [ %16, %pfor.body137.us.us.us.strpm.outer ]
  %inneriter = phi i64 [ %inneriter.nsub, %for.cond.cleanup.us.us.us ], [ 2, %pfor.body137.us.us.us.strpm.outer ]
  %mul134.us.us.us = shl nsw i64 %__begin126.0.us.us.us, 4
  call void @llvm.lifetime.start.p0(i64 128, ptr nonnull %tmp.us.us.us)
  %add138.us.us.us = add nuw nsw i64 %mul134.us.us.us, 16
  %cmp141429.us.us.us = icmp slt i64 %mul134.us.us.us, %mul65
  br i1 %cmp141429.us.us.us, label %for.body.lr.ph.us.us.us, label %for.cond.cleanup.us.us.us

for.cond.cleanup.us.us.us:                        ; preds = %for.body.us.us.us.us, %pfor.cond132.us.us.us
  call void @llvm.lifetime.end.p0(i64 128, ptr nonnull %tmp.us.us.us)
  %inc258.us.us.us = add nuw nsw i64 %__begin126.0.us.us.us, 1
  %inneriter.nsub = add nsw i64 %inneriter, -1
  %inneriter.ncmp = icmp eq i64 %inneriter.nsub, 0
  br i1 %inneriter.ncmp, label %pfor.inc.us.us.us.reattach, label %pfor.cond132.us.us.us, !llvm.loop !18

pfor.inc.us.us.us.reattach:                       ; preds = %for.cond.cleanup.us.us.us
  reattach within %syncreg118.us.us.strpm.detachloop, label %pfor.inc.us.us.us.strpm.outer

pfor.inc.us.us.us.strpm.outer:                    ; preds = %pfor.inc.us.us.us.reattach, %pfor.cond132.us.us.us.strpm.outer
  %niter.nadd = add nuw nsw i64 %niter, 1
  %niter.ncmp = icmp eq i64 %niter.nadd, %stripiter453
  br i1 %niter.ncmp, label %pfor.cond132.us.us.us.strpm.detachloop.sync, label %pfor.cond132.us.us.us.strpm.outer, !llvm.loop !21

pfor.cond132.us.us.us.strpm.detachloop.sync:      ; preds = %pfor.inc.us.us.us.strpm.outer
  sync within %syncreg118.us.us.strpm.detachloop, label %pfor.cond132.us.us.us.strpm.detachloop.reattach.split

pfor.cond132.us.us.us.strpm.detachloop.reattach.split: ; preds = %pfor.cond132.us.us.us.strpm.detachloop.sync
  reattach within %syncreg118.us.us, label %pfor.cond132.us.us.us.epil.preheader

for.body.lr.ph.us.us.us:                          ; preds = %pfor.cond132.us.us.us
  tail call void @llvm.assume(i1 %cmp196.us.us)
  br label %for.body.us.us.us.us

for.body.us.us.us.us:                             ; preds = %for.body.us.us.us.us, %for.body.lr.ph.us.us.us
  %ir1.0430.us.us.us.us = phi i64 [ %mul134.us.us.us, %for.body.lr.ph.us.us.us ], [ %add256.us.us.us.us, %for.body.us.us.us.us ]
  %div145.us.us.us.us = sdiv i64 %ir1.0430.us.us.us.us, %mul
  %mul147.us.us.us.us = mul i64 %mul, %div145.us.us.us.us
  %sub148.us.us.us.us = sub nsw i64 %ir1.0430.us.us.us.us, %mul147.us.us.us.us
  %div149.us.us.us.us = sdiv i64 %sub148.us.us.us.us, %7
  %mul153.us.us.us.us = mul nsw i64 %div149.us.us.us.us, %7
  %sub154.us.us.us.us = sub nsw i64 %sub148.us.us.us.us, %mul153.us.us.us.us
  %17 = load ptr, ptr %data184, align 8, !tbaa !22
  %mul185.us.us.us.us = mul i64 %sub154.us.us.us.us, %8
  %mul186.us.us.us.us = mul i64 %div149.us.us.us.us, %9
  %mul188.us.us.us.us = mul i64 %div145.us.us.us.us, %10
  %add187.us.us.us.us = add i64 %mul186.us.us.us.us, %mul188.us.us.us.us
  %add189.us.us.us.us = add i64 %add187.us.us.us.us, %mul185.us.us.us.us
  %add.ptr190.us.us.us.us = getelementptr inbounds i8, ptr %17, i64 %add189.us.us.us.us
  %arrayidx234.us.us.us.us = getelementptr inbounds float, ptr %add.ptr190.us.us.us.us, i64 %mul116.us.us
  call void @llvm.memcpy.p0.p0.i64(ptr noundef align 1 %arrayidx234.us.us.us.us, ptr noundef nonnull align 4 %tmp.us.us.us, i64 noundef %mul246.us.us, i1 noundef false) #7
  %add256.us.us.us.us = add nuw nsw i64 %ir1.0430.us.us.us.us, %nrc.0
  %cmp139.us.us.us.us = icmp ult i64 %add256.us.us.us.us, %add138.us.us.us
  %cmp141.us.us.us.us = icmp slt i64 %add256.us.us.us.us, %mul65
  %18 = select i1 %cmp139.us.us.us.us, i1 %cmp141.us.us.us.us, i1 false
  br i1 %18, label %for.body.us.us.us.us, label %for.cond.cleanup.us.us.us, !llvm.loop !25

pfor.cond132.us.us.us.epil:                       ; preds = %pfor.cond132.us.us.us.epil.preheader, %for.cond.cleanup.us.us.us.epil
  %__begin126.0.us.us.us.epil = phi i64 [ %inc258.us.us.us.epil, %for.cond.cleanup.us.us.us.epil ], [ %15, %pfor.cond132.us.us.us.epil.preheader ]
  %epil.iter = phi i64 [ %epil.iter.sub, %for.cond.cleanup.us.us.us.epil ], [ %13, %pfor.cond132.us.us.us.epil.preheader ]
  %mul134.us.us.us.epil = shl nsw i64 %__begin126.0.us.us.us.epil, 4
  call void @llvm.lifetime.start.p0(i64 128, ptr nonnull %tmp.us.us.us.epil)
  %add138.us.us.us.epil = add nuw nsw i64 %mul134.us.us.us.epil, 16
  %cmp141429.us.us.us.epil = icmp slt i64 %mul134.us.us.us.epil, %mul65
  br i1 %cmp141429.us.us.us.epil, label %for.body.lr.ph.us.us.us.epil, label %for.cond.cleanup.us.us.us.epil

for.body.lr.ph.us.us.us.epil:                     ; preds = %pfor.cond132.us.us.us.epil
  tail call void @llvm.assume(i1 %cmp196.us.us)
  br label %for.body.us.us.us.us.epil

for.body.us.us.us.us.epil:                        ; preds = %for.body.us.us.us.us.epil, %for.body.lr.ph.us.us.us.epil
  %ir1.0430.us.us.us.us.epil = phi i64 [ %mul134.us.us.us.epil, %for.body.lr.ph.us.us.us.epil ], [ %add256.us.us.us.us.epil, %for.body.us.us.us.us.epil ]
  %div145.us.us.us.us.epil = sdiv i64 %ir1.0430.us.us.us.us.epil, %mul
  %mul147.us.us.us.us.epil = mul i64 %mul, %div145.us.us.us.us.epil
  %sub148.us.us.us.us.epil = sub nsw i64 %ir1.0430.us.us.us.us.epil, %mul147.us.us.us.us.epil
  %div149.us.us.us.us.epil = sdiv i64 %sub148.us.us.us.us.epil, %7
  %mul153.us.us.us.us.epil = mul nsw i64 %div149.us.us.us.us.epil, %7
  %sub154.us.us.us.us.epil = sub nsw i64 %sub148.us.us.us.us.epil, %mul153.us.us.us.us.epil
  %19 = load ptr, ptr %data184, align 8, !tbaa !22
  %mul185.us.us.us.us.epil = mul i64 %sub154.us.us.us.us.epil, %8
  %mul186.us.us.us.us.epil = mul i64 %div149.us.us.us.us.epil, %9
  %mul188.us.us.us.us.epil = mul i64 %div145.us.us.us.us.epil, %10
  %add187.us.us.us.us.epil = add i64 %mul186.us.us.us.us.epil, %mul188.us.us.us.us.epil
  %add189.us.us.us.us.epil = add i64 %add187.us.us.us.us.epil, %mul185.us.us.us.us.epil
  %add.ptr190.us.us.us.us.epil = getelementptr inbounds i8, ptr %19, i64 %add189.us.us.us.us.epil
  %arrayidx234.us.us.us.us.epil = getelementptr inbounds float, ptr %add.ptr190.us.us.us.us.epil, i64 %mul116.us.us
  call void @llvm.memcpy.p0.p0.i64(ptr noundef align 1 %arrayidx234.us.us.us.us.epil, ptr noundef nonnull align 4 %tmp.us.us.us.epil, i64 noundef %mul246.us.us, i1 noundef false) #7
  %add256.us.us.us.us.epil = add nuw nsw i64 %ir1.0430.us.us.us.us.epil, %nrc.0
  %cmp139.us.us.us.us.epil = icmp ult i64 %add256.us.us.us.us.epil, %add138.us.us.us.epil
  %cmp141.us.us.us.us.epil = icmp slt i64 %add256.us.us.us.us.epil, %mul65
  %20 = select i1 %cmp139.us.us.us.us.epil, i1 %cmp141.us.us.us.us.epil, i1 false
  br i1 %20, label %for.body.us.us.us.us.epil, label %for.cond.cleanup.us.us.us.epil, !llvm.loop !25

for.cond.cleanup.us.us.us.epil:                   ; preds = %for.body.us.us.us.us.epil, %pfor.cond132.us.us.us.epil
  call void @llvm.lifetime.end.p0(i64 128, ptr nonnull %tmp.us.us.us.epil)
  %inc258.us.us.us.epil = add nuw nsw i64 %__begin126.0.us.us.us.epil, 1
  %epil.iter.sub = add nsw i64 %epil.iter, -1
  %epil.iter.cmp.not = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp.not, label %pfor.cond.cleanup.split.us.us.us, label %pfor.cond132.us.us.us.epil, !llvm.loop !26

pfor.cond.cleanup.split.us.us.us:                 ; preds = %for.cond.cleanup.us.us.us.epil
  sync within %syncreg118.us.us, label %cleanup.us.us

pfor.cond.cleanup267:                             ; preds = %pfor.inc263.us.us, %pfor.ph
  sync within %syncreg, label %cleanup272

cleanup272:                                       ; preds = %pfor.cond.cleanup267, %entry
  ret void
}

; CHECK: define internal fastcc void @ggml_compute_forward_mul_mat.outline_pfor.cond.us.us.ls1(
; CHECK: pfor.cond.us.us.preheader.ls1:
; CHECK-NEXT: %[[NESTED_SPAWN_SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
; CHECK-NEXT: %[[LOOP_DAC_SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
; CHECK: br label %[[LOOP_DAC_HEADER:.+]]

; CHECK: [[LOOP_DAC_HEADER]]:

; CHECK: detach within %[[LOOP_DAC_SYNCREG]], label %[[DAC_SPAWN:.+]], label %[[DAC_SPAWN_CONT:.+]]

; CHECK: [[DAC_SPAWN]]:
; CHECK-NEXT: call {{.*}}void @ggml_compute_forward_mul_mat.outline_pfor.cond.us.us.ls1(
; CHECK-NEXT: reattach within %[[LOOP_DAC_SYNCREG]], label %[[DAC_SPAWN_CONT]]

; CHECK: [[DAC_SPAWN_CONT]]:
; CHECK: br label %[[LOOP_DAC_HEADER]]

; Check for a newly introduced taskframe that contains the static alloca.
; CHECK: %[[NEW_TF:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: %[[TMP:.+]] = alloca [32 x float]
; CHECK-NEXT: br label %[[NESTED_LOOP_HEADER:.+]]

; CHECK: [[NESTED_LOOP_HEADER]]:
; CHECK: br i1 %{{.*}}, label %[[NESTED_LOOP_EPIL:.+]], label %[[NESTED_LOOP_SPAWN:.+]]

; Check for the nested spawn
; CHECK: [[NESTED_LOOP_SPAWN]]:
; CHECK-NEXT: detach within %[[NESTED_SPAWN_SYNCREG]], label %[[NESTED_SPAWN:.+]], label %[[NESTED_LOOP_EPIL]]

; CHECK: [[NESTED_LOOP_EPIL]]:
; CHECK: sync within %[[NESTED_SPAWN_SYNCREG]], label %[[NESTED_LOOP_INC:.+]]

; CHECK: [[NESTED_LOOP_INC]]:
; CHECK: br i1 %{{.*}}, label %[[NESTED_LOOP_EXIT:.+]], label %[[NESTED_LOOP_HEADER]]

; CHECK: [[NESTED_LOOP_EXIT]]:
; CHECK-NEXT: call void @llvm.taskframe.end(token %[[NEW_TF]])
; CHECK-NEXT: sync within %[[LOOP_DAC_SYNCREG]], label %{{.*}}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

declare zeroext i1 @ggml_is_contiguous(ptr noundef) local_unnamed_addr #2

declare i64 @ggml_row_size(i32 noundef, i64 noundef) local_unnamed_addr #2

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smin.i64(i64, i64) #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.assume(i1 noundef) #5

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #6

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #3 = { mustprogress nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
attributes #6 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #7 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 14, i32 2]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"clang version 17.0.6 (git@github.com:OpenCilk/opencilk-project.git c85f242a46d579145a8538338c78acd94c43c5f4)"}
!6 = !{!7, !7, i64 0}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!11, !11, i64 0}
!11 = !{!"long long", !8, i64 0}
!12 = !{!13, !13, i64 0}
!13 = !{!"long", !8, i64 0}
!14 = distinct !{!14, !15, !16, !17}
!15 = !{!"llvm.loop.mustprogress"}
!16 = !{!"tapir.loop.spawn.strategy", i32 1}
!17 = !{!"tapir.loop.grainsize", i32 1}
!18 = distinct !{!18, !15, !19, !20}
!19 = !{!"llvm.loop.unroll.disable"}
!20 = !{!"llvm.loop.fromtapirloop"}
!21 = distinct !{!21, !15, !16, !19, !17}
!22 = !{!23, !7, i64 280}
!23 = !{!"ggml_tensor", !8, i64 0, !8, i64 4, !7, i64 8, !8, i64 16, !8, i64 48, !8, i64 80, !8, i64 84, !24, i64 148, !7, i64 152, !8, i64 160, !24, i64 240, !11, i64 248, !11, i64 256, !7, i64 264, !13, i64 272, !7, i64 280, !8, i64 288, !7, i64 352, !8, i64 360}
!24 = !{!"int", !8, i64 0}
!25 = distinct !{!25, !15}
!26 = distinct !{!26, !20, !15, !19}
