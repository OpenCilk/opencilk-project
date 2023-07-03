; Check that Cilksan spills structure-type values for hooks onto the
; stack.
;
; RUN: opt < %s -passes="csi-setup,cilksan" -S | FileCheck %s

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx12.0.0"

; Function Attrs: nofree nosync nounwind sanitize_cilk ssp uwtable
define void @"_ZN3c1012function_refIFvPPcPKxxxEE11callback_fnIN2at6native7DEFAULT16VectorizedLoop2dIZZZNS9_12_GLOBAL__N_116div_trunc_kernelERNS8_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNSC_16div_trunc_kernelESE_ENKSF_clEvENKSG_clEvEUlNS8_3vec7DEFAULT10VectorizedIfEESL_E_EEEEvlS2_S4_xx"(i64 noundef %callable, i8** noundef %params, i64* noundef %params1, i64 noundef %params3, i64 noundef %params5) #0 align 2 {
entry:
  %data.sroa.0.0.copyload.i = load i8*, i8** %params, align 8
  %data.sroa.14.0..sroa_idx74.i = getelementptr inbounds i8*, i8** %params, i64 1
  %data.sroa.14.0.copyload.i = load i8*, i8** %data.sroa.14.0..sroa_idx74.i, align 8
  %data.sroa.25.0..sroa_idx78.i = getelementptr inbounds i8*, i8** %params, i64 2
  %data.sroa.25.0.copyload.i = load i8*, i8** %data.sroa.25.0..sroa_idx78.i, align 8
  %arrayidx.i = getelementptr inbounds i64, i64* %params1, i64 3
  %arrayidx.i.i.i = getelementptr inbounds i64, i64* %params1, i64 2
  %0 = load i64, i64* %arrayidx.i.i.i, align 8, !tbaa !10
  switch i64 %0, label %if.else.i.i.i [
    i64 4, label %land.rhs.i.i.i
    i64 0, label %land.rhs.i.i.i8.i.i
  ]

land.rhs.i.i.i:                                   ; preds = %entry
  %arrayidx.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 1
  %1 = load i64, i64* %arrayidx.i.i.i.i, align 8, !tbaa !10
  switch i64 %1, label %if.else.i.i.i [
    i64 4, label %"_ZN2at6native7DEFAULTL13is_contiguousI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELPv0EEEbPKx.exit.i"
    i64 0, label %"_ZN2at6native7DEFAULTL20is_contiguous_scalarI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELi1ELPv0EEEbPKx.exit.i.i"
  ]

"_ZN2at6native7DEFAULTL13is_contiguousI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELPv0EEEbPKx.exit.i": ; preds = %land.rhs.i.i.i
  %strides.val.i.i.i.i = load i64, i64* %params1, align 8, !tbaa !10
  %cmp.i.i.i.i.i = icmp eq i64 %strides.val.i.i.i.i, 4
  br i1 %cmp.i.i.i.i.i, label %if.then.i, label %if.else.i.i.i

if.then.i:                                        ; preds = %"_ZN2at6native7DEFAULTL13is_contiguousI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELPv0EEEbPKx.exit.i"
  %cmp.i.i.i.i16.i = icmp slt i64 %params5, 1
  br i1 %cmp.i.i.i.i16.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body.lr.ph.i

for.body.lr.ph.i:                                 ; preds = %if.then.i
  %sub.i.i = add nsw i64 %params3, -16
  %cmp13.not145.i.i = icmp slt i64 %params3, 16
  %arrayidx.1.i.i = getelementptr inbounds i64, i64* %params1, i64 4
  %arrayidx.2.i.i = getelementptr inbounds i64, i64* %params1, i64 5
  br i1 %cmp13.not145.i.i, label %for.body.lr.ph.split.us.i, label %for.body.i.preheader

for.body.i.preheader:                             ; preds = %for.body.lr.ph.i
  %2 = shl i64 %params3, 2
  br label %for.body.i

for.body.lr.ph.split.us.i:                        ; preds = %for.body.lr.ph.i
  %cmp45.i.us.i = icmp sgt i64 %params3, 0
  %3 = load i64, i64* %arrayidx.i, align 8, !tbaa !10
  %4 = load i64, i64* %arrayidx.1.i.i, align 8, !tbaa !10
  %5 = load i64, i64* %arrayidx.2.i.i, align 8, !tbaa !10
  br i1 %cmp45.i.us.i, label %for.body.us.us.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit"

for.body.us.us.i:                                 ; preds = %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.loopexit.us.us.i", %for.body.lr.ph.split.us.i
  %__begin4.sroa.0.092.us.us.i = phi i64 [ %inc.i.us.us.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.loopexit.us.us.i" ], [ 0, %for.body.lr.ph.split.us.i ]
  %data.sroa.25.091.us.us.i = phi i8* [ %add.ptr.2.i.us.us.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.loopexit.us.us.i" ], [ %data.sroa.25.0.copyload.i, %for.body.lr.ph.split.us.i ]
  %data.sroa.14.090.us.us.i = phi i8* [ %add.ptr.1.i.us.us.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.loopexit.us.us.i" ], [ %data.sroa.14.0.copyload.i, %for.body.lr.ph.split.us.i ]
  %data.sroa.0.089.us.us.i = phi i8* [ %add.ptr.i23.us.us.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.loopexit.us.us.i" ], [ %data.sroa.0.0.copyload.i, %for.body.lr.ph.split.us.i ]
  br label %for.body.i.i.i.us.us.i

for.body.i.i.i.us.us.i:                           ; preds = %for.body.i.i.i.us.us.i, %for.body.us.us.i
  %i.addr.05.i.i.i.us.us.i = phi i64 [ %inc.i.i.i.us.us.i, %for.body.i.i.i.us.us.i ], [ 0, %for.body.us.us.i ]
  %mul.i.i72.i.us.us.i = shl nsw i64 %i.addr.05.i.i.i.us.us.i, 2
  %add.ptr.i.i73.i.us.us.i = getelementptr inbounds i8, i8* %data.sroa.0.089.us.us.i, i64 %mul.i.i72.i.us.us.i
  %6 = bitcast i8* %add.ptr.i.i73.i.us.us.i to float*
  %add.ptr.i.i.i.i.i.us.us.i = getelementptr inbounds i8, i8* %data.sroa.14.090.us.us.i, i64 %mul.i.i72.i.us.us.i
  %7 = bitcast i8* %add.ptr.i.i.i.i.i.us.us.i to float*
  %8 = load float, float* %7, align 4, !tbaa !14
  %add.ptr6.i.i.i.i.i.us.us.i = getelementptr inbounds i8, i8* %data.sroa.25.091.us.us.i, i64 %mul.i.i72.i.us.us.i
  %9 = bitcast i8* %add.ptr6.i.i.i.i.i.us.us.i to float*
  %10 = load float, float* %9, align 4, !tbaa !14
  %div.i.i.i.i.i74.i.us.us.i = fdiv float %8, %10
  %11 = tail call float @llvm.trunc.f32(float %div.i.i.i.i.i74.i.us.us.i) #4
  store float %11, float* %6, align 4, !tbaa !14
  %inc.i.i.i.us.us.i = add nuw nsw i64 %i.addr.05.i.i.i.us.us.i, 1
  %exitcond.not.i.i.i.us.us.i = icmp eq i64 %inc.i.i.i.us.us.i, %params3
  br i1 %exitcond.not.i.i.i.us.us.i, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.loopexit.us.us.i", label %for.body.i.i.i.us.us.i, !llvm.loop !16

"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.loopexit.us.us.i": ; preds = %for.body.i.i.i.us.us.i
  %add.ptr.i23.us.us.i = getelementptr inbounds i8, i8* %data.sroa.0.089.us.us.i, i64 %3
  %add.ptr.1.i.us.us.i = getelementptr inbounds i8, i8* %data.sroa.14.090.us.us.i, i64 %4
  %add.ptr.2.i.us.us.i = getelementptr inbounds i8, i8* %data.sroa.25.091.us.us.i, i64 %5
  %inc.i.us.us.i = add nuw nsw i64 %__begin4.sroa.0.092.us.us.i, 1
  %cmp.i.not.us.us.i = icmp eq i64 %inc.i.us.us.i, %params5
  br i1 %cmp.i.not.us.us.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body.us.us.i

for.body.i:                                       ; preds = %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i", %for.body.i.preheader
  %__begin4.sroa.0.092.i = phi i64 [ %inc.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i" ], [ 0, %for.body.i.preheader ]
  %data.sroa.25.091.i = phi i8* [ %add.ptr.2.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i" ], [ %data.sroa.25.0.copyload.i, %for.body.i.preheader ]
  %data.sroa.14.090.i = phi i8* [ %add.ptr.1.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i" ], [ %data.sroa.14.0.copyload.i, %for.body.i.preheader ]
  %data.sroa.0.089.i = phi i8* [ %add.ptr.i23.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i" ], [ %data.sroa.0.0.copyload.i, %for.body.i.preheader ]
  br label %for.body14.i.i

for.body14.i.i:                                   ; preds = %for.body14.i.i, %for.body.i
  %i.0146.i.i = phi i64 [ %add43.i.i, %for.body14.i.i ], [ 0, %for.body.i ]
  %.pre.i.i.i.i = shl i64 %i.0146.i.i, 2
  %add.ptr.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.14.090.i, i64 %.pre.i.i.i.i
  %12 = bitcast i8* %add.ptr.i.i.i.i to float*
  %vld1xN.i.i.i.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float* %12) #4
  %vld1xN.fca.0.extract.i.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i.i.i.i.i, 0
  %vld1xN.fca.1.extract.i.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i.i.i.i.i, 1
  %add.ptr8.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.25.091.i, i64 %.pre.i.i.i.i
  %13 = bitcast i8* %add.ptr8.i.i.i.i to float*
  %vld1xN.i4.i.i.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float* %13) #4
  %mul.i.i15.i.i = or i64 %.pre.i.i.i.i, 32
  %add.ptr.i.i16.i.i = getelementptr inbounds i8, i8* %data.sroa.14.090.i, i64 %mul.i.i15.i.i
  %14 = bitcast i8* %add.ptr.i.i16.i.i to float*
  %vld1xN.i.i.i17.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float* nonnull %14) #4
  %vld1xN.fca.0.extract.i.i.i18.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i.i.i17.i.i, 0
  %vld1xN.fca.1.extract.i.i.i19.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i.i.i17.i.i, 1
  %vld1xN.fca.0.extract.i5.i.i170.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i4.i.i.i.i, 0
  %vld1xN.fca.1.extract.i6.i.i172.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i4.i.i.i.i, 1
  %add.ptr8.i.i26.i.i = getelementptr inbounds i8, i8* %data.sroa.25.091.i, i64 %mul.i.i15.i.i
  %15 = bitcast i8* %add.ptr8.i.i26.i.i to float*
  %vld1xN.i4.i.i27.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float* nonnull %15) #4
  %vld1xN.fca.0.extract.i5.i.i28.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i4.i.i27.i.i, 0
  %vld1xN.fca.1.extract.i6.i.i29.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i4.i.i27.i.i, 1
  %div.i.i.i.i.i.i.i = fdiv <4 x float> %vld1xN.fca.0.extract.i.i.i.i.i, %vld1xN.fca.0.extract.i5.i.i170.i.i
  %div.i11.i.i.i.i.i.i = fdiv <4 x float> %vld1xN.fca.1.extract.i.i.i.i.i, %vld1xN.fca.1.extract.i6.i.i172.i.i
  %vrndz1.i.i.i.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i.i.i.i.i.i.i) #4
  %vrndz1.i9.i.i.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i11.i.i.i.i.i.i) #4
  %div.i.i.i.i.i45.i.i = fdiv <4 x float> %vld1xN.fca.0.extract.i.i.i18.i.i, %vld1xN.fca.0.extract.i5.i.i28.i.i
  %div.i11.i.i.i.i46.i.i = fdiv <4 x float> %vld1xN.fca.1.extract.i.i.i19.i.i, %vld1xN.fca.1.extract.i6.i.i29.i.i
  %vrndz1.i.i.i.i.i47.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i.i.i.i.i45.i.i) #4
  %vrndz1.i9.i.i.i.i48.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i11.i.i.i.i46.i.i) #4
  %add.ptr.i.i = getelementptr inbounds i8, i8* %data.sroa.0.089.i, i64 %.pre.i.i.i.i
  %16 = bitcast i8* %add.ptr.i.i to float*
  tail call void @llvm.aarch64.neon.st1x2.v4f32.p0f32(<4 x float> %vrndz1.i.i.i.i.i.i.i, <4 x float> %vrndz1.i9.i.i.i.i.i.i, float* %16) #4
  %add.ptr36.i.i = getelementptr inbounds i8, i8* %data.sroa.0.089.i, i64 %mul.i.i15.i.i
  %17 = bitcast i8* %add.ptr36.i.i to float*
  tail call void @llvm.aarch64.neon.st1x2.v4f32.p0f32(<4 x float> %vrndz1.i.i.i.i.i47.i.i, <4 x float> %vrndz1.i9.i.i.i.i48.i.i, float* nonnull %17) #4
  %add43.i.i = add nuw nsw i64 %i.0146.i.i, 16
  %cmp13.not.i.i = icmp sgt i64 %add43.i.i, %sub.i.i
  br i1 %cmp13.not.i.i, label %for.end44.i.loopexit.i, label %for.body14.i.i, !llvm.loop !18

; CHECK: %vld1xN.i.i.i.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0(ptr %[[ARG:.+]])
; CHECK-NEXT: %[[STACKSAVE:.+]] = call ptr @llvm.stacksave()
; CHECK-NEXT: %[[SPILL:.+]] = alloca { <4 x float>, <4 x float> }
; CHECK-NEXT: store { <4 x float>, <4 x float> } %vld1xN.i.i.i.i.i, ptr %[[SPILL]]
; CHECK-NEXT: call void @__csan_llvm_aarch64_neon_ld1x2_v4f32_p0(
; CHECK: ptr %[[SPILL]],
; CHECK: ptr %[[ARG]])
; CHECK-NEXT: call void @llvm.stackrestore(ptr %[[STACKSAVE]])

; CHECK: tail call void @llvm.aarch64.neon.st1x2.v4f32.p0(<4 x float> %vrndz1.i.i.i.i.i.i.i, <4 x float> %vrndz1.i9.i.i.i.i.i.i, ptr %[[ARG2:.+]])
; CHECK-NEXT: %[[STACKSAVE2:.+]] = call ptr @llvm.stacksave()
; CHECK-NEXT: %[[SPILL2A:.+]] = alloca <4 x float>
; CHECK-NEXT: store <4 x float> %vrndz1.i.i.i.i.i.i.i, ptr %[[SPILL2A]]
; CHECK-NEXT: %[[SPILL2B:.+]] = alloca <4 x float>
; CHECK-NEXT: store <4 x float> %vrndz1.i9.i.i.i.i.i.i, ptr %[[SPILL2B]]
; CHECK-NEXT: call void @__csan_llvm_aarch64_neon_st1x2_v4f32_p0(
; CHECK: ptr %[[SPILL2A]],
; CHECK: ptr %[[SPILL2B]],
; CHECK: ptr %[[ARG2]])
; CHECK-NEXT: call void @llvm.stackrestore(ptr %[[STACKSAVE2]])

for.end44.i.loopexit.i:                           ; preds = %for.body14.i.i
  %cmp45.i.i = icmp slt i64 %add43.i.i, %params3
  br i1 %cmp45.i.i, label %for.body.i.i.i.i.preheader, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i"

for.body.i.i.i.i.preheader:                       ; preds = %for.end44.i.loopexit.i
  %18 = sub i64 %params3, %add43.i.i
  %min.iters.check89 = icmp ult i64 %18, 8
  br i1 %min.iters.check89, label %for.body.i.i.i.i.preheader104, label %vector.memcheck72

vector.memcheck72:                                ; preds = %for.body.i.i.i.i.preheader
  %19 = shl i64 %add43.i.i, 2
  %scevgep73 = getelementptr i8, i8* %data.sroa.0.089.i, i64 %19
  %scevgep74 = getelementptr i8, i8* %data.sroa.0.089.i, i64 %2
  %scevgep75 = getelementptr i8, i8* %data.sroa.14.090.i, i64 %19
  %scevgep76 = getelementptr i8, i8* %data.sroa.14.090.i, i64 %2
  %scevgep77 = getelementptr i8, i8* %data.sroa.25.091.i, i64 %19
  %scevgep78 = getelementptr i8, i8* %data.sroa.25.091.i, i64 %2
  %bound079 = icmp ult i8* %scevgep73, %scevgep76
  %bound180 = icmp ult i8* %scevgep75, %scevgep74
  %found.conflict81 = and i1 %bound079, %bound180
  %bound082 = icmp ult i8* %scevgep73, %scevgep78
  %bound183 = icmp ult i8* %scevgep77, %scevgep74
  %found.conflict84 = and i1 %bound082, %bound183
  %conflict.rdx85 = or i1 %found.conflict81, %found.conflict84
  br i1 %conflict.rdx85, label %for.body.i.i.i.i.preheader104, label %vector.ph90

vector.ph90:                                      ; preds = %vector.memcheck72
  %n.vec92 = and i64 %18, -8
  %ind.end94 = add i64 %add43.i.i, %n.vec92
  br label %vector.body88

vector.body88:                                    ; preds = %vector.body88, %vector.ph90
  %index96 = phi i64 [ 0, %vector.ph90 ], [ %index.next102, %vector.body88 ]
  %offset.idx97 = add i64 %add43.i.i, %index96
  %20 = shl nsw i64 %offset.idx97, 2
  %21 = getelementptr inbounds i8, i8* %data.sroa.0.089.i, i64 %20
  %22 = getelementptr inbounds i8, i8* %data.sroa.14.090.i, i64 %20
  %23 = bitcast i8* %22 to <4 x float>*
  %wide.load98 = load <4 x float>, <4 x float>* %23, align 4, !tbaa !14, !alias.scope !19
  %24 = getelementptr inbounds i8, i8* %22, i64 16
  %25 = bitcast i8* %24 to <4 x float>*
  %wide.load99 = load <4 x float>, <4 x float>* %25, align 4, !tbaa !14, !alias.scope !19
  %26 = getelementptr inbounds i8, i8* %data.sroa.25.091.i, i64 %20
  %27 = bitcast i8* %26 to <4 x float>*
  %wide.load100 = load <4 x float>, <4 x float>* %27, align 4, !tbaa !14, !alias.scope !22
  %28 = getelementptr inbounds i8, i8* %26, i64 16
  %29 = bitcast i8* %28 to <4 x float>*
  %wide.load101 = load <4 x float>, <4 x float>* %29, align 4, !tbaa !14, !alias.scope !22
  %30 = fdiv <4 x float> %wide.load98, %wide.load100
  %31 = fdiv <4 x float> %wide.load99, %wide.load101
  %32 = call <4 x float> @llvm.trunc.v4f32(<4 x float> %30)
  %33 = call <4 x float> @llvm.trunc.v4f32(<4 x float> %31)
  %34 = bitcast i8* %21 to <4 x float>*
  store <4 x float> %32, <4 x float>* %34, align 4, !tbaa !14, !alias.scope !24, !noalias !26
  %35 = getelementptr inbounds i8, i8* %21, i64 16
  %36 = bitcast i8* %35 to <4 x float>*
  store <4 x float> %33, <4 x float>* %36, align 4, !tbaa !14, !alias.scope !24, !noalias !26
  %index.next102 = add nuw i64 %index96, 8
  %37 = icmp eq i64 %index.next102, %n.vec92
  br i1 %37, label %middle.block86, label %vector.body88, !llvm.loop !27

middle.block86:                                   ; preds = %vector.body88
  %cmp.n95 = icmp eq i64 %18, %n.vec92
  br i1 %cmp.n95, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i", label %for.body.i.i.i.i.preheader104

for.body.i.i.i.i.preheader104:                    ; preds = %middle.block86, %vector.memcheck72, %for.body.i.i.i.i.preheader
  %i.addr.05.i.i.i.i.ph = phi i64 [ %add43.i.i, %vector.memcheck72 ], [ %add43.i.i, %for.body.i.i.i.i.preheader ], [ %ind.end94, %middle.block86 ]
  br label %for.body.i.i.i.i

for.body.i.i.i.i:                                 ; preds = %for.body.i.i.i.i, %for.body.i.i.i.i.preheader104
  %i.addr.05.i.i.i.i = phi i64 [ %inc.i.i.i.i, %for.body.i.i.i.i ], [ %i.addr.05.i.i.i.i.ph, %for.body.i.i.i.i.preheader104 ]
  %mul.i.i72.i.i = shl nsw i64 %i.addr.05.i.i.i.i, 2
  %add.ptr.i.i73.i.i = getelementptr inbounds i8, i8* %data.sroa.0.089.i, i64 %mul.i.i72.i.i
  %38 = bitcast i8* %add.ptr.i.i73.i.i to float*
  %add.ptr.i.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.14.090.i, i64 %mul.i.i72.i.i
  %39 = bitcast i8* %add.ptr.i.i.i.i.i.i to float*
  %40 = load float, float* %39, align 4, !tbaa !14
  %add.ptr6.i.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.25.091.i, i64 %mul.i.i72.i.i
  %41 = bitcast i8* %add.ptr6.i.i.i.i.i.i to float*
  %42 = load float, float* %41, align 4, !tbaa !14
  %div.i.i.i.i.i74.i.i = fdiv float %40, %42
  %43 = tail call float @llvm.trunc.f32(float %div.i.i.i.i.i74.i.i) #4
  store float %43, float* %38, align 4, !tbaa !14
  %inc.i.i.i.i = add nuw nsw i64 %i.addr.05.i.i.i.i, 1
  %exitcond.not.i.i.i.i = icmp eq i64 %inc.i.i.i.i, %params3
  br i1 %exitcond.not.i.i.i.i, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i", label %for.body.i.i.i.i, !llvm.loop !29

"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i": ; preds = %for.body.i.i.i.i, %middle.block86, %for.end44.i.loopexit.i
  %44 = load i64, i64* %arrayidx.i, align 8, !tbaa !10
  %add.ptr.i23.i = getelementptr inbounds i8, i8* %data.sroa.0.089.i, i64 %44
  %45 = load i64, i64* %arrayidx.1.i.i, align 8, !tbaa !10
  %add.ptr.1.i.i = getelementptr inbounds i8, i8* %data.sroa.14.090.i, i64 %45
  %46 = load i64, i64* %arrayidx.2.i.i, align 8, !tbaa !10
  %add.ptr.2.i.i = getelementptr inbounds i8, i8* %data.sroa.25.091.i, i64 %46
  %inc.i.i = add nuw nsw i64 %__begin4.sroa.0.092.i, 1
  %cmp.i.not.i = icmp eq i64 %inc.i.i, %params5
  br i1 %cmp.i.not.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body.i

"_ZN2at6native7DEFAULTL20is_contiguous_scalarI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELi1ELPv0EEEbPKx.exit.i.i": ; preds = %land.rhs.i.i.i
  %strides.val.i.i.i.i.i = load i64, i64* %params1, align 8, !tbaa !10
  %cmp.i.i.i.i.i.i = icmp eq i64 %strides.val.i.i.i.i.i, 4
  br i1 %cmp.i.i.i.i.i.i, label %if.then.i28.i, label %if.else.i.i.i

if.then.i28.i:                                    ; preds = %"_ZN2at6native7DEFAULTL20is_contiguous_scalarI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELi1ELPv0EEEbPKx.exit.i.i"
  %cmp.i.i.i.i43.i.i.i = icmp slt i64 %params5, 1
  br i1 %cmp.i.i.i.i43.i.i.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body.i.i.preheader.i

for.body.i.i.preheader.i:                         ; preds = %if.then.i28.i
  %sub.i.i.i.i = add nsw i64 %params3, -16
  %cmp13.not145.i.i.i.i = icmp slt i64 %params3, 16
  %arrayidx.1.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 4
  %arrayidx.2.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 5
  %47 = shl i64 %params3, 2
  br label %for.body.i.i.i

for.body.i.i.i:                                   ; preds = %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i", %for.body.i.i.preheader.i
  %data.sroa.0.1.i = phi i8* [ %add.ptr.i41.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i" ], [ %data.sroa.0.0.copyload.i, %for.body.i.i.preheader.i ]
  %data.sroa.14.1.i = phi i8* [ %add.ptr.1.i.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i" ], [ %data.sroa.14.0.copyload.i, %for.body.i.i.preheader.i ]
  %data.sroa.25.1.i = phi i8* [ %add.ptr.2.i.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i" ], [ %data.sroa.25.0.copyload.i, %for.body.i.i.preheader.i ]
  %__begin6.sroa.0.079.i.i.i = phi i64 [ %inc.i.i.i30.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i" ], [ 0, %for.body.i.i.preheader.i ]
  %48 = bitcast i8* %data.sroa.14.1.i to float*
  %49 = load float, float* %48, align 4, !tbaa !14
  %vecinit.i.i.i.i.i.i.i = insertelement <4 x float> undef, float %49, i64 0
  %vecinit3.i.i.i.i.i.i.i = shufflevector <4 x float> %vecinit.i.i.i.i.i.i.i, <4 x float> poison, <4 x i32> zeroinitializer
  br i1 %cmp13.not145.i.i.i.i, label %for.end44.i.i.i.i, label %for.body14.i.i.i.i

for.body14.i.i.i.i:                               ; preds = %for.body14.i.i.i.i, %for.body.i.i.i
  %i.0146.i.i.i.i = phi i64 [ %add43.i.i.i.i, %for.body14.i.i.i.i ], [ 0, %for.body.i.i.i ]
  %.pre.i.i.i.i.i.i = shl i64 %i.0146.i.i.i.i, 2
  %add.ptr8.i.i161.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.25.1.i, i64 %.pre.i.i.i.i.i.i
  %50 = bitcast i8* %add.ptr8.i.i161.i.i.i.i to float*
  %vld1xN.i4.i.i162.i.i.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float* %50) #4
  %.pre.i.i13.i.i.i.i = or i64 %.pre.i.i.i.i.i.i, 32
  %vld1xN.fca.0.extract.i5.i.i170.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i4.i.i162.i.i.i.i, 0
  %vld1xN.fca.1.extract.i6.i.i172.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i4.i.i162.i.i.i.i, 1
  %add.ptr8.i.i26.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.25.1.i, i64 %.pre.i.i13.i.i.i.i
  %51 = bitcast i8* %add.ptr8.i.i26.i.i.i.i to float*
  %vld1xN.i4.i.i27.i.i.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float* nonnull %51) #4
  %vld1xN.fca.0.extract.i5.i.i28.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i4.i.i27.i.i.i.i, 0
  %vld1xN.fca.1.extract.i6.i.i29.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i4.i.i27.i.i.i.i, 1
  %div.i.i.i.i.i.i.i.i.i = fdiv <4 x float> %vecinit3.i.i.i.i.i.i.i, %vld1xN.fca.0.extract.i5.i.i170.i.i.i.i
  %div.i11.i.i.i.i.i.i.i.i = fdiv <4 x float> %vecinit3.i.i.i.i.i.i.i, %vld1xN.fca.1.extract.i6.i.i172.i.i.i.i
  %vrndz1.i.i.i.i.i.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i.i.i.i.i.i.i.i.i) #4
  %vrndz1.i9.i.i.i.i.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i11.i.i.i.i.i.i.i.i) #4
  %div.i.i.i.i.i45.i.i.i.i = fdiv <4 x float> %vecinit3.i.i.i.i.i.i.i, %vld1xN.fca.0.extract.i5.i.i28.i.i.i.i
  %div.i11.i.i.i.i46.i.i.i.i = fdiv <4 x float> %vecinit3.i.i.i.i.i.i.i, %vld1xN.fca.1.extract.i6.i.i29.i.i.i.i
  %vrndz1.i.i.i.i.i47.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i.i.i.i.i45.i.i.i.i) #4
  %vrndz1.i9.i.i.i.i48.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i11.i.i.i.i46.i.i.i.i) #4
  %add.ptr.i.i.i29.i = getelementptr inbounds i8, i8* %data.sroa.0.1.i, i64 %.pre.i.i.i.i.i.i
  %52 = bitcast i8* %add.ptr.i.i.i29.i to float*
  tail call void @llvm.aarch64.neon.st1x2.v4f32.p0f32(<4 x float> %vrndz1.i.i.i.i.i.i.i.i.i, <4 x float> %vrndz1.i9.i.i.i.i.i.i.i.i, float* %52) #4
  %add.ptr36.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.0.1.i, i64 %.pre.i.i13.i.i.i.i
  %53 = bitcast i8* %add.ptr36.i.i.i.i to float*
  tail call void @llvm.aarch64.neon.st1x2.v4f32.p0f32(<4 x float> %vrndz1.i.i.i.i.i47.i.i.i.i, <4 x float> %vrndz1.i9.i.i.i.i48.i.i.i.i, float* nonnull %53) #4
  %add43.i.i.i.i = add nuw nsw i64 %i.0146.i.i.i.i, 16
  %cmp13.not.i.i.i.i = icmp sgt i64 %add43.i.i.i.i, %sub.i.i.i.i
  br i1 %cmp13.not.i.i.i.i, label %for.end44.i.i.i.i, label %for.body14.i.i.i.i, !llvm.loop !18

for.end44.i.i.i.i:                                ; preds = %for.body14.i.i.i.i, %for.body.i.i.i
  %i.0.lcssa.i.i.i.i = phi i64 [ 0, %for.body.i.i.i ], [ %add43.i.i.i.i, %for.body14.i.i.i.i ]
  %cmp45.i.i.i.i = icmp slt i64 %i.0.lcssa.i.i.i.i, %params3
  br i1 %cmp45.i.i.i.i, label %for.body.i.i.i.i.i.i.preheader, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i"

for.body.i.i.i.i.i.i.preheader:                   ; preds = %for.end44.i.i.i.i
  %54 = sub i64 %params3, %i.0.lcssa.i.i.i.i
  %min.iters.check56 = icmp ult i64 %54, 8
  br i1 %min.iters.check56, label %for.body.i.i.i.i.i.i.preheader106, label %vector.memcheck40

vector.memcheck40:                                ; preds = %for.body.i.i.i.i.i.i.preheader
  %55 = shl i64 %i.0.lcssa.i.i.i.i, 2
  %scevgep41 = getelementptr i8, i8* %data.sroa.0.1.i, i64 %55
  %scevgep42 = getelementptr i8, i8* %data.sroa.0.1.i, i64 %47
  %scevgep43 = getelementptr i8, i8* %data.sroa.14.1.i, i64 4
  %scevgep44 = getelementptr i8, i8* %data.sroa.25.1.i, i64 %55
  %scevgep45 = getelementptr i8, i8* %data.sroa.25.1.i, i64 %47
  %bound046 = icmp ult i8* %scevgep41, %scevgep43
  %bound147 = icmp ult i8* %data.sroa.14.1.i, %scevgep42
  %found.conflict48 = and i1 %bound046, %bound147
  %bound049 = icmp ult i8* %scevgep41, %scevgep45
  %bound150 = icmp ult i8* %scevgep44, %scevgep42
  %found.conflict51 = and i1 %bound049, %bound150
  %conflict.rdx52 = or i1 %found.conflict48, %found.conflict51
  br i1 %conflict.rdx52, label %for.body.i.i.i.i.i.i.preheader106, label %vector.ph57

vector.ph57:                                      ; preds = %vector.memcheck40
  %n.vec59 = and i64 %54, -8
  %ind.end61 = add i64 %i.0.lcssa.i.i.i.i, %n.vec59
  %56 = load float, float* %48, align 4, !tbaa !14, !alias.scope !30
  %broadcast.splatinsert67 = insertelement <4 x float> poison, float %56, i64 0
  %broadcast.splat68 = shufflevector <4 x float> %broadcast.splatinsert67, <4 x float> poison, <4 x i32> zeroinitializer
  br label %vector.body55

vector.body55:                                    ; preds = %vector.body55, %vector.ph57
  %index63 = phi i64 [ 0, %vector.ph57 ], [ %index.next71, %vector.body55 ]
  %offset.idx64 = add i64 %i.0.lcssa.i.i.i.i, %index63
  %57 = shl nsw i64 %offset.idx64, 2
  %58 = getelementptr inbounds i8, i8* %data.sroa.0.1.i, i64 %57
  %59 = getelementptr inbounds i8, i8* %data.sroa.25.1.i, i64 %57
  %60 = bitcast i8* %59 to <4 x float>*
  %wide.load65 = load <4 x float>, <4 x float>* %60, align 4, !tbaa !14, !alias.scope !33
  %61 = getelementptr inbounds i8, i8* %59, i64 16
  %62 = bitcast i8* %61 to <4 x float>*
  %wide.load66 = load <4 x float>, <4 x float>* %62, align 4, !tbaa !14, !alias.scope !33
  %63 = fdiv <4 x float> %broadcast.splat68, %wide.load65
  %64 = fdiv <4 x float> %broadcast.splat68, %wide.load66
  %65 = call <4 x float> @llvm.trunc.v4f32(<4 x float> %63)
  %66 = call <4 x float> @llvm.trunc.v4f32(<4 x float> %64)
  %67 = bitcast i8* %58 to <4 x float>*
  store <4 x float> %65, <4 x float>* %67, align 4, !tbaa !14, !alias.scope !35, !noalias !37
  %68 = getelementptr inbounds i8, i8* %58, i64 16
  %69 = bitcast i8* %68 to <4 x float>*
  store <4 x float> %66, <4 x float>* %69, align 4, !tbaa !14, !alias.scope !35, !noalias !37
  %index.next71 = add nuw i64 %index63, 8
  %70 = icmp eq i64 %index.next71, %n.vec59
  br i1 %70, label %middle.block53, label %vector.body55, !llvm.loop !38

middle.block53:                                   ; preds = %vector.body55
  %cmp.n62 = icmp eq i64 %54, %n.vec59
  br i1 %cmp.n62, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i", label %for.body.i.i.i.i.i.i.preheader106

for.body.i.i.i.i.i.i.preheader106:                ; preds = %middle.block53, %vector.memcheck40, %for.body.i.i.i.i.i.i.preheader
  %i.addr.05.i.i.i.i.i.i.ph = phi i64 [ %i.0.lcssa.i.i.i.i, %vector.memcheck40 ], [ %i.0.lcssa.i.i.i.i, %for.body.i.i.i.i.i.i.preheader ], [ %ind.end61, %middle.block53 ]
  br label %for.body.i.i.i.i.i.i

for.body.i.i.i.i.i.i:                             ; preds = %for.body.i.i.i.i.i.i, %for.body.i.i.i.i.i.i.preheader106
  %i.addr.05.i.i.i.i.i.i = phi i64 [ %inc.i.i.i.i.i.i, %for.body.i.i.i.i.i.i ], [ %i.addr.05.i.i.i.i.i.i.ph, %for.body.i.i.i.i.i.i.preheader106 ]
  %mul.i.i72.i.i.i.i = shl nsw i64 %i.addr.05.i.i.i.i.i.i, 2
  %add.ptr.i.i73.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.0.1.i, i64 %mul.i.i72.i.i.i.i
  %71 = bitcast i8* %add.ptr.i.i73.i.i.i.i to float*
  %72 = load float, float* %48, align 4, !tbaa !14
  %add.ptr6.i.i.i.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.25.1.i, i64 %mul.i.i72.i.i.i.i
  %73 = bitcast i8* %add.ptr6.i.i.i.i.i.i.i.i to float*
  %74 = load float, float* %73, align 4, !tbaa !14
  %div.i.i.i.i.i74.i.i.i.i = fdiv float %72, %74
  %75 = tail call float @llvm.trunc.f32(float %div.i.i.i.i.i74.i.i.i.i) #4
  store float %75, float* %71, align 4, !tbaa !14
  %inc.i.i.i.i.i.i = add nuw nsw i64 %i.addr.05.i.i.i.i.i.i, 1
  %exitcond.not.i.i.i.i.i.i = icmp eq i64 %inc.i.i.i.i.i.i, %params3
  br i1 %exitcond.not.i.i.i.i.i.i, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i", label %for.body.i.i.i.i.i.i, !llvm.loop !39

"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i": ; preds = %for.body.i.i.i.i.i.i, %middle.block53, %for.end44.i.i.i.i
  %76 = load i64, i64* %arrayidx.i, align 8, !tbaa !10
  %add.ptr.i41.i.i.i = getelementptr inbounds i8, i8* %data.sroa.0.1.i, i64 %76
  %77 = load i64, i64* %arrayidx.1.i.i.i.i, align 8, !tbaa !10
  %add.ptr.1.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.14.1.i, i64 %77
  %78 = load i64, i64* %arrayidx.2.i.i.i.i, align 8, !tbaa !10
  %add.ptr.2.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.25.1.i, i64 %78
  %inc.i.i.i30.i = add nuw nsw i64 %__begin6.sroa.0.079.i.i.i, 1
  %cmp.i.not.i.i.i = icmp eq i64 %inc.i.i.i30.i, %params5
  br i1 %cmp.i.not.i.i.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body.i.i.i

land.rhs.i.i.i8.i.i:                              ; preds = %entry
  %arrayidx.i.i.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 1
  %79 = load i64, i64* %arrayidx.i.i.i.i.i.i, align 8, !tbaa !10
  %cmp.i.i.i.i7.i.i = icmp eq i64 %79, 4
  br i1 %cmp.i.i.i.i7.i.i, label %"_ZN2at6native7DEFAULTL20is_contiguous_scalarI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELi2ELPv0EEEbPKx.exit.i.i.i", label %if.else.i.i.i

"_ZN2at6native7DEFAULTL20is_contiguous_scalarI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELi2ELPv0EEEbPKx.exit.i.i.i": ; preds = %land.rhs.i.i.i8.i.i
  %strides.val.i.i.i.i.i.i = load i64, i64* %params1, align 8, !tbaa !10
  %cmp.i.i.i.i.i.i.i = icmp eq i64 %strides.val.i.i.i.i.i.i, 4
  br i1 %cmp.i.i.i.i.i.i.i, label %if.then.i.i.i, label %if.else.i.i.i

if.then.i.i.i:                                    ; preds = %"_ZN2at6native7DEFAULTL20is_contiguous_scalarI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELi2ELPv0EEEbPKx.exit.i.i.i"
  %cmp.i.i.i.i43.i.i.i.i = icmp slt i64 %params5, 1
  br i1 %cmp.i.i.i.i43.i.i.i.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body.i.i.i31.preheader.i

for.body.i.i.i31.preheader.i:                     ; preds = %if.then.i.i.i
  %sub.i.i.i.i.i = add nsw i64 %params3, -16
  %cmp13.not145.i.i.i.i.i = icmp slt i64 %params3, 16
  %arrayidx.1.i.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 4
  %arrayidx.2.i.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 5
  %80 = shl i64 %params3, 2
  br label %for.body.i.i.i31.i

for.body.i.i.i31.i:                               ; preds = %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i", %for.body.i.i.i31.preheader.i
  %data.sroa.0.2.i = phi i8* [ %add.ptr.i41.i.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i" ], [ %data.sroa.0.0.copyload.i, %for.body.i.i.i31.preheader.i ]
  %data.sroa.14.2.i = phi i8* [ %add.ptr.1.i.i.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i" ], [ %data.sroa.14.0.copyload.i, %for.body.i.i.i31.preheader.i ]
  %data.sroa.25.2.i = phi i8* [ %add.ptr.2.i.i.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i" ], [ %data.sroa.25.0.copyload.i, %for.body.i.i.i31.preheader.i ]
  %__begin6.sroa.0.079.i.i.i.i = phi i64 [ %inc.i.i.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i" ], [ 0, %for.body.i.i.i31.preheader.i ]
  %81 = bitcast i8* %data.sroa.25.2.i to float*
  %82 = load float, float* %81, align 4, !tbaa !14
  %vecinit.i.i.i.i.i.i.i.i = insertelement <4 x float> undef, float %82, i64 0
  %vecinit3.i.i.i.i.i.i.i.i = shufflevector <4 x float> %vecinit.i.i.i.i.i.i.i.i, <4 x float> poison, <4 x i32> zeroinitializer
  br i1 %cmp13.not145.i.i.i.i.i, label %for.end44.i.i.i.i.i, label %for.body14.i.i.i.i.i

for.body14.i.i.i.i.i:                             ; preds = %for.body14.i.i.i.i.i, %for.body.i.i.i31.i
  %i.0146.i.i.i.i.i = phi i64 [ %add43.i.i.i.i.i, %for.body14.i.i.i.i.i ], [ 0, %for.body.i.i.i31.i ]
  %.pre.i.i.i.i.i.i.i = shl i64 %i.0146.i.i.i.i.i, 2
  %add.ptr.i.i.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.14.2.i, i64 %.pre.i.i.i.i.i.i.i
  %83 = bitcast i8* %add.ptr.i.i.i.i.i.i.i to float*
  %vld1xN.i.i.i.i.i.i.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float* %83) #4
  %vld1xN.fca.0.extract.i.i.i.i.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i.i.i.i.i.i.i.i, 0
  %vld1xN.fca.1.extract.i.i.i.i.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i.i.i.i.i.i.i.i, 1
  %mul.i.i15138.i.i.i.i.i = or i64 %.pre.i.i.i.i.i.i.i, 32
  %add.ptr.i.i16139.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.14.2.i, i64 %mul.i.i15138.i.i.i.i.i
  %84 = bitcast i8* %add.ptr.i.i16139.i.i.i.i.i to float*
  %vld1xN.i.i.i17140.i.i.i.i.i = tail call { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float* nonnull %84) #4
  %vld1xN.fca.0.extract.i.i.i18141.i.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i.i.i17140.i.i.i.i.i, 0
  %vld1xN.fca.1.extract.i.i.i19142.i.i.i.i.i = extractvalue { <4 x float>, <4 x float> } %vld1xN.i.i.i17140.i.i.i.i.i, 1
  %div.i.i.i.i.i.i.i.i.i.i = fdiv <4 x float> %vld1xN.fca.0.extract.i.i.i.i.i.i.i.i, %vecinit3.i.i.i.i.i.i.i.i
  %div.i11.i.i.i.i.i.i.i.i.i = fdiv <4 x float> %vld1xN.fca.1.extract.i.i.i.i.i.i.i.i, %vecinit3.i.i.i.i.i.i.i.i
  %vrndz1.i.i.i.i.i.i.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i.i.i.i.i.i.i.i.i.i) #4
  %vrndz1.i9.i.i.i.i.i.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i11.i.i.i.i.i.i.i.i.i) #4
  %div.i.i.i.i.i45.i.i.i.i.i = fdiv <4 x float> %vld1xN.fca.0.extract.i.i.i18141.i.i.i.i.i, %vecinit3.i.i.i.i.i.i.i.i
  %div.i11.i.i.i.i46.i.i.i.i.i = fdiv <4 x float> %vld1xN.fca.1.extract.i.i.i19142.i.i.i.i.i, %vecinit3.i.i.i.i.i.i.i.i
  %vrndz1.i.i.i.i.i47.i.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i.i.i.i.i45.i.i.i.i.i) #4
  %vrndz1.i9.i.i.i.i48.i.i.i.i.i = tail call <4 x float> @llvm.trunc.v4f32(<4 x float> %div.i11.i.i.i.i46.i.i.i.i.i) #4
  %add.ptr.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.0.2.i, i64 %.pre.i.i.i.i.i.i.i
  %85 = bitcast i8* %add.ptr.i.i.i.i.i to float*
  tail call void @llvm.aarch64.neon.st1x2.v4f32.p0f32(<4 x float> %vrndz1.i.i.i.i.i.i.i.i.i.i, <4 x float> %vrndz1.i9.i.i.i.i.i.i.i.i.i, float* %85) #4
  %add.ptr36.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.0.2.i, i64 %mul.i.i15138.i.i.i.i.i
  %86 = bitcast i8* %add.ptr36.i.i.i.i.i to float*
  tail call void @llvm.aarch64.neon.st1x2.v4f32.p0f32(<4 x float> %vrndz1.i.i.i.i.i47.i.i.i.i.i, <4 x float> %vrndz1.i9.i.i.i.i48.i.i.i.i.i, float* nonnull %86) #4
  %add43.i.i.i.i.i = add nuw nsw i64 %i.0146.i.i.i.i.i, 16
  %cmp13.not.i.i.i.i.i = icmp sgt i64 %add43.i.i.i.i.i, %sub.i.i.i.i.i
  br i1 %cmp13.not.i.i.i.i.i, label %for.end44.i.i.i.i.i, label %for.body14.i.i.i.i.i, !llvm.loop !18

for.end44.i.i.i.i.i:                              ; preds = %for.body14.i.i.i.i.i, %for.body.i.i.i31.i
  %i.0.lcssa.i.i.i.i.i = phi i64 [ 0, %for.body.i.i.i31.i ], [ %add43.i.i.i.i.i, %for.body14.i.i.i.i.i ]
  %cmp45.i.i.i.i.i = icmp slt i64 %i.0.lcssa.i.i.i.i.i, %params3
  br i1 %cmp45.i.i.i.i.i, label %for.body.i.i.i.i.i.i.i.preheader, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i"

for.body.i.i.i.i.i.i.i.preheader:                 ; preds = %for.end44.i.i.i.i.i
  %87 = sub i64 %params3, %i.0.lcssa.i.i.i.i.i
  %min.iters.check = icmp ult i64 %87, 8
  br i1 %min.iters.check, label %for.body.i.i.i.i.i.i.i.preheader108, label %vector.memcheck

vector.memcheck:                                  ; preds = %for.body.i.i.i.i.i.i.i.preheader
  %88 = shl i64 %i.0.lcssa.i.i.i.i.i, 2
  %scevgep = getelementptr i8, i8* %data.sroa.0.2.i, i64 %88
  %scevgep30 = getelementptr i8, i8* %data.sroa.0.2.i, i64 %80
  %scevgep31 = getelementptr i8, i8* %data.sroa.14.2.i, i64 %88
  %scevgep32 = getelementptr i8, i8* %data.sroa.14.2.i, i64 %80
  %scevgep33 = getelementptr i8, i8* %data.sroa.25.2.i, i64 4
  %bound0 = icmp ult i8* %scevgep, %scevgep32
  %bound1 = icmp ult i8* %scevgep31, %scevgep30
  %found.conflict = and i1 %bound0, %bound1
  %bound034 = icmp ult i8* %scevgep, %scevgep33
  %bound135 = icmp ult i8* %data.sroa.25.2.i, %scevgep30
  %found.conflict36 = and i1 %bound034, %bound135
  %conflict.rdx = or i1 %found.conflict, %found.conflict36
  br i1 %conflict.rdx, label %for.body.i.i.i.i.i.i.i.preheader108, label %vector.ph

vector.ph:                                        ; preds = %vector.memcheck
  %n.vec = and i64 %87, -8
  %ind.end = add i64 %i.0.lcssa.i.i.i.i.i, %n.vec
  %89 = load float, float* %81, align 4, !tbaa !14, !alias.scope !40
  %broadcast.splatinsert = insertelement <4 x float> poison, float %89, i64 0
  %broadcast.splat = shufflevector <4 x float> %broadcast.splatinsert, <4 x float> poison, <4 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %offset.idx = add i64 %i.0.lcssa.i.i.i.i.i, %index
  %90 = shl nsw i64 %offset.idx, 2
  %91 = getelementptr inbounds i8, i8* %data.sroa.0.2.i, i64 %90
  %92 = getelementptr inbounds i8, i8* %data.sroa.14.2.i, i64 %90
  %93 = bitcast i8* %92 to <4 x float>*
  %wide.load = load <4 x float>, <4 x float>* %93, align 4, !tbaa !14, !alias.scope !43
  %94 = getelementptr inbounds i8, i8* %92, i64 16
  %95 = bitcast i8* %94 to <4 x float>*
  %wide.load37 = load <4 x float>, <4 x float>* %95, align 4, !tbaa !14, !alias.scope !43
  %96 = fdiv <4 x float> %wide.load, %broadcast.splat
  %97 = fdiv <4 x float> %wide.load37, %broadcast.splat
  %98 = call <4 x float> @llvm.trunc.v4f32(<4 x float> %96)
  %99 = call <4 x float> @llvm.trunc.v4f32(<4 x float> %97)
  %100 = bitcast i8* %91 to <4 x float>*
  store <4 x float> %98, <4 x float>* %100, align 4, !tbaa !14, !alias.scope !45, !noalias !47
  %101 = getelementptr inbounds i8, i8* %91, i64 16
  %102 = bitcast i8* %101 to <4 x float>*
  store <4 x float> %99, <4 x float>* %102, align 4, !tbaa !14, !alias.scope !45, !noalias !47
  %index.next = add nuw i64 %index, 8
  %103 = icmp eq i64 %index.next, %n.vec
  br i1 %103, label %middle.block, label %vector.body, !llvm.loop !48

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %87, %n.vec
  br i1 %cmp.n, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i", label %for.body.i.i.i.i.i.i.i.preheader108

for.body.i.i.i.i.i.i.i.preheader108:              ; preds = %middle.block, %vector.memcheck, %for.body.i.i.i.i.i.i.i.preheader
  %i.addr.05.i.i.i.i.i.i.i.ph = phi i64 [ %i.0.lcssa.i.i.i.i.i, %vector.memcheck ], [ %i.0.lcssa.i.i.i.i.i, %for.body.i.i.i.i.i.i.i.preheader ], [ %ind.end, %middle.block ]
  br label %for.body.i.i.i.i.i.i.i

for.body.i.i.i.i.i.i.i:                           ; preds = %for.body.i.i.i.i.i.i.i, %for.body.i.i.i.i.i.i.i.preheader108
  %i.addr.05.i.i.i.i.i.i.i = phi i64 [ %inc.i.i.i.i.i.i.i, %for.body.i.i.i.i.i.i.i ], [ %i.addr.05.i.i.i.i.i.i.i.ph, %for.body.i.i.i.i.i.i.i.preheader108 ]
  %mul.i.i72.i.i.i.i.i = shl nsw i64 %i.addr.05.i.i.i.i.i.i.i, 2
  %add.ptr.i.i73.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.0.2.i, i64 %mul.i.i72.i.i.i.i.i
  %104 = bitcast i8* %add.ptr.i.i73.i.i.i.i.i to float*
  %add.ptr.i.i.i.i.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.14.2.i, i64 %mul.i.i72.i.i.i.i.i
  %105 = bitcast i8* %add.ptr.i.i.i.i.i.i.i.i.i to float*
  %106 = load float, float* %105, align 4, !tbaa !14
  %107 = load float, float* %81, align 4, !tbaa !14
  %div.i.i.i.i.i74.i.i.i.i.i = fdiv float %106, %107
  %108 = tail call float @llvm.trunc.f32(float %div.i.i.i.i.i74.i.i.i.i.i) #4
  store float %108, float* %104, align 4, !tbaa !14
  %inc.i.i.i.i.i.i.i = add nuw nsw i64 %i.addr.05.i.i.i.i.i.i.i, 1
  %exitcond.not.i.i.i.i.i.i.i = icmp eq i64 %inc.i.i.i.i.i.i.i, %params3
  br i1 %exitcond.not.i.i.i.i.i.i.i, label %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i", label %for.body.i.i.i.i.i.i.i, !llvm.loop !49

"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i": ; preds = %for.body.i.i.i.i.i.i.i, %middle.block, %for.end44.i.i.i.i.i
  %109 = load i64, i64* %arrayidx.i, align 8, !tbaa !10
  %add.ptr.i41.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.0.2.i, i64 %109
  %110 = load i64, i64* %arrayidx.1.i.i.i.i.i, align 8, !tbaa !10
  %add.ptr.1.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.14.2.i, i64 %110
  %111 = load i64, i64* %arrayidx.2.i.i.i.i.i, align 8, !tbaa !10
  %add.ptr.2.i.i.i.i.i = getelementptr inbounds i8, i8* %data.sroa.25.2.i, i64 %111
  %inc.i.i.i.i.i = add nuw nsw i64 %__begin6.sroa.0.079.i.i.i.i, 1
  %cmp.i.not.i.i.i.i = icmp eq i64 %inc.i.i.i.i.i, %params5
  br i1 %cmp.i.not.i.i.i.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body.i.i.i31.i

if.else.i.i.i:                                    ; preds = %"_ZN2at6native7DEFAULTL20is_contiguous_scalarI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELi2ELPv0EEEbPKx.exit.i.i.i", %land.rhs.i.i.i8.i.i, %"_ZN2at6native7DEFAULTL20is_contiguous_scalarI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELi1ELPv0EEEbPKx.exit.i.i", %"_ZN2at6native7DEFAULTL13is_contiguousI15function_traitsIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ELPv0EEEbPKx.exit.i", %land.rhs.i.i.i, %entry
  %cmp.i.i.i.i43.i.i.i.i.i = icmp slt i64 %params5, 1
  br i1 %cmp.i.i.i.i43.i.i.i.i.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body21.i.i.i.i.preheader.i

for.body21.i.i.i.i.preheader.i:                   ; preds = %if.else.i.i.i
  %strides.sroa.0.0.copyload.i.i.i.i.i.i = load i64, i64* %params1, align 8, !tbaa !10
  %strides.sroa.4.0.strides_13.sroa_idx17.i.i.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 1
  %strides.sroa.4.0.copyload.i.i.i.i.i.i = load i64, i64* %strides.sroa.4.0.strides_13.sroa_idx17.i.i.i.i.i.i, align 8, !tbaa !10
  %cmp4.i.i.i.i.i.i.i = icmp sgt i64 %params3, 0
  %112 = load i64, i64* %arrayidx.i, align 8, !tbaa !10
  %arrayidx.1.i57.i.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 4
  %113 = load i64, i64* %arrayidx.1.i57.i.i.i.i.i, align 8, !tbaa !10
  %arrayidx.2.i60.i.i.i.i.i = getelementptr inbounds i64, i64* %params1, i64 5
  %114 = load i64, i64* %arrayidx.2.i60.i.i.i.i.i, align 8, !tbaa !10
  br i1 %cmp4.i.i.i.i.i.i.i, label %for.body21.i.i.i.i.us.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit"

for.body21.i.i.i.i.us.i:                          ; preds = %"_ZN2at6native7DEFAULTL10basic_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_EEvPPcPKxxxOT_.exit.i.i.i.i.loopexit.us.i", %for.body21.i.i.i.i.preheader.i
  %data.sroa.0.3.us.i = phi i8* [ %add.ptr.i56.i.i.i.i.us.i, %"_ZN2at6native7DEFAULTL10basic_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_EEvPPcPKxxxOT_.exit.i.i.i.i.loopexit.us.i" ], [ %data.sroa.0.0.copyload.i, %for.body21.i.i.i.i.preheader.i ]
  %data.sroa.14.3.us.i = phi i8* [ %add.ptr.1.i59.i.i.i.i.us.i, %"_ZN2at6native7DEFAULTL10basic_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_EEvPPcPKxxxOT_.exit.i.i.i.i.loopexit.us.i" ], [ %data.sroa.14.0.copyload.i, %for.body21.i.i.i.i.preheader.i ]
  %data.sroa.25.3.us.i = phi i8* [ %add.ptr.2.i62.i.i.i.i.us.i, %"_ZN2at6native7DEFAULTL10basic_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_EEvPPcPKxxxOT_.exit.i.i.i.i.loopexit.us.i" ], [ %data.sroa.25.0.copyload.i, %for.body21.i.i.i.i.preheader.i ]
  %__begin612.sroa.0.081.i.i.i.i.us.i = phi i64 [ %inc.i64.i.i.i.i.us.i, %"_ZN2at6native7DEFAULTL10basic_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_EEvPPcPKxxxOT_.exit.i.i.i.i.loopexit.us.i" ], [ 0, %for.body21.i.i.i.i.preheader.i ]
  br label %for.body.i.i.i.i14.i.i.us.i

for.body.i.i.i.i14.i.i.us.i:                      ; preds = %for.body.i.i.i.i14.i.i.us.i, %for.body21.i.i.i.i.us.i
  %i.addr.05.i.i.i.i7.i.i.us.i = phi i64 [ %inc.i.i.i.i12.i.i.us.i, %for.body.i.i.i.i14.i.i.us.i ], [ 0, %for.body21.i.i.i.i.us.i ]
  %mul.i.i.i.i.i.i.us.i = mul nsw i64 %i.addr.05.i.i.i.i7.i.i.us.i, %strides.sroa.0.0.copyload.i.i.i.i.i.i
  %add.ptr.i.i.i.i8.i.i.us.i = getelementptr inbounds i8, i8* %data.sroa.0.3.us.i, i64 %mul.i.i.i.i.i.i.us.i
  %115 = bitcast i8* %add.ptr.i.i.i.i8.i.i.us.i to float*
  %mul.i.i.i.i.i.i9.i.i.us.i = mul nsw i64 %i.addr.05.i.i.i.i7.i.i.us.i, %strides.sroa.4.0.copyload.i.i.i.i.i.i
  %add.ptr.i.i.i.i.i.i10.i.i.us.i = getelementptr inbounds i8, i8* %data.sroa.14.3.us.i, i64 %mul.i.i.i.i.i.i9.i.i.us.i
  %116 = bitcast i8* %add.ptr.i.i.i.i.i.i10.i.i.us.i to float*
  %117 = load float, float* %116, align 4, !tbaa !14
  %mul5.i.i.i.i.i.i.i.i.us.i = mul nsw i64 %i.addr.05.i.i.i.i7.i.i.us.i, %0
  %add.ptr6.i.i.i.i.i.i.i.i.us.i = getelementptr inbounds i8, i8* %data.sroa.25.3.us.i, i64 %mul5.i.i.i.i.i.i.i.i.us.i
  %118 = bitcast i8* %add.ptr6.i.i.i.i.i.i.i.i.us.i to float*
  %119 = load float, float* %118, align 4, !tbaa !14
  %div.i.i.i.i.i.i.i11.i.i.us.i = fdiv float %117, %119
  %120 = tail call float @llvm.trunc.f32(float %div.i.i.i.i.i.i.i11.i.i.us.i) #4
  store float %120, float* %115, align 4, !tbaa !14
  %inc.i.i.i.i12.i.i.us.i = add nuw nsw i64 %i.addr.05.i.i.i.i7.i.i.us.i, 1
  %exitcond.not.i.i.i.i13.i.i.us.i = icmp eq i64 %inc.i.i.i.i12.i.i.us.i, %params3
  br i1 %exitcond.not.i.i.i.i13.i.i.us.i, label %"_ZN2at6native7DEFAULTL10basic_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_EEvPPcPKxxxOT_.exit.i.i.i.i.loopexit.us.i", label %for.body.i.i.i.i14.i.i.us.i, !llvm.loop !16

"_ZN2at6native7DEFAULTL10basic_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_EEvPPcPKxxxOT_.exit.i.i.i.i.loopexit.us.i": ; preds = %for.body.i.i.i.i14.i.i.us.i
  %add.ptr.i56.i.i.i.i.us.i = getelementptr inbounds i8, i8* %data.sroa.0.3.us.i, i64 %112
  %add.ptr.1.i59.i.i.i.i.us.i = getelementptr inbounds i8, i8* %data.sroa.14.3.us.i, i64 %113
  %add.ptr.2.i62.i.i.i.i.us.i = getelementptr inbounds i8, i8* %data.sroa.25.3.us.i, i64 %114
  %inc.i64.i.i.i.i.us.i = add nuw nsw i64 %__begin612.sroa.0.081.i.i.i.i.us.i, 1
  %cmp.i52.not.i.i.i.i.us.i = icmp eq i64 %inc.i64.i.i.i.i.us.i, %params5
  br i1 %cmp.i52.not.i.i.i.i.us.i, label %"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit", label %for.body21.i.i.i.i.us.i

"_ZN2at6native7DEFAULT16VectorizedLoop2dIZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_ZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESC_E_EclEPPcPKxxx.exit": ; preds = %"_ZN2at6native7DEFAULTL10basic_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_EEvPPcPKxxxOT_.exit.i.i.i.i.loopexit.us.i", %for.body21.i.i.i.i.preheader.i, %if.else.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i.i", %if.then.i.i.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i.i.i", %if.then.i28.i, %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.i", %"_ZN2at6native7DEFAULTL15vectorized_loopIRZZZNS0_12_GLOBAL__N_116div_trunc_kernelERNS_18TensorIteratorBaseEENK3$_5clEvENKUlvE2_clEvEUlffE_RZZZNS3_16div_trunc_kernelES5_ENKS6_clEvENKS7_clEvEUlNS_3vec7DEFAULT10VectorizedIfEESD_E_EEvPPcxxOT_OT0_.exit.loopexit.us.us.i", %for.body.lr.ph.split.us.i, %if.then.i
  ret void
}

; Function Attrs: argmemonly nofree nosync nounwind readonly willreturn
declare { <4 x float>, <4 x float> } @llvm.aarch64.neon.ld1x2.v4f32.p0f32(float*) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.aarch64.neon.st1x2.v4f32.p0f32(<4 x float>, <4 x float>, float* nocapture) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.trunc.f32(float) #3

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <4 x float> @llvm.trunc.v4f32(<4 x float>) #3

attributes #0 = { nofree nosync nounwind sanitize_cilk ssp uwtable "frame-pointer"="non-leaf" "min-legal-vector-width"="128" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+v8.5a,+zcm,+zcz" }
attributes #1 = { argmemonly nofree nosync nounwind readonly willreturn }
attributes #2 = { argmemonly nofree nosync nounwind willreturn }
attributes #3 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8}
!llvm.ident = !{!9}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 12, i32 3]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"branch-target-enforcement", i32 0}
!3 = !{i32 1, !"sign-return-address", i32 0}
!4 = !{i32 1, !"sign-return-address-all", i32 0}
!5 = !{i32 1, !"sign-return-address-with-bkey", i32 0}
!6 = !{i32 7, !"PIC Level", i32 2}
!7 = !{i32 7, !"uwtable", i32 1}
!8 = !{i32 7, !"frame-pointer", i32 1}
!9 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git 9af4ee3b420975e3fb2bb48b16c91bf85657d171)"}
!10 = !{!11, !11, i64 0}
!11 = !{!"long long", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C++ TBAA"}
!14 = !{!15, !15, i64 0}
!15 = !{!"float", !12, i64 0}
!16 = distinct !{!16, !17}
!17 = !{!"llvm.loop.mustprogress"}
!18 = distinct !{!18, !17}
!19 = !{!20}
!20 = distinct !{!20, !21}
!21 = distinct !{!21, !"LVerDomain"}
!22 = !{!23}
!23 = distinct !{!23, !21}
!24 = !{!25}
!25 = distinct !{!25, !21}
!26 = !{!20, !23}
!27 = distinct !{!27, !17, !28}
!28 = !{!"llvm.loop.isvectorized", i32 1}
!29 = distinct !{!29, !17, !28}
!30 = !{!31}
!31 = distinct !{!31, !32}
!32 = distinct !{!32, !"LVerDomain"}
!33 = !{!34}
!34 = distinct !{!34, !32}
!35 = !{!36}
!36 = distinct !{!36, !32}
!37 = !{!31, !34}
!38 = distinct !{!38, !17, !28}
!39 = distinct !{!39, !17, !28}
!40 = !{!41}
!41 = distinct !{!41, !42}
!42 = distinct !{!42, !"LVerDomain"}
!43 = !{!44}
!44 = distinct !{!44, !42}
!45 = !{!46}
!46 = distinct !{!46, !42}
!47 = !{!44, !41}
!48 = distinct !{!48, !17, !28}
!49 = distinct !{!49, !17, !28}
