; RUN: opt < %s -loop-spawning-ti -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S -o - | FileCheck %s

; ModuleID = 'vectoroutline.cpp'
source_filename = "vectoroutline.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: argmemonly norecurse nounwind uwtable
define dso_local void @_Z14vectorlooptestPjll(i32* nocapture %SA12, i64 %n1, i64 %n12) local_unnamed_addr #0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp sgt i64 %n12, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %entry
  %0 = add nsw i64 %n12, -1
  %xtraiter = and i64 %n12, 2047
  %1 = icmp ult i64 %0, 2047
  br i1 %1, label %pfor.cond.cleanup.strpm-lcssa, label %pfor.cond.preheader.new

pfor.cond.preheader.new:                          ; preds = %pfor.cond.preheader
  %stripiter = lshr i64 %n12, 11
  %broadcast.splatinsert34 = insertelement <8 x i64> undef, i64 %n1, i32 0
  %broadcast.splat35 = shufflevector <8 x i64> %broadcast.splatinsert34, <8 x i64> undef, <8 x i32> zeroinitializer
  br label %pfor.cond.strpm.outer

pfor.cond.strpm.outer:                            ; preds = %pfor.inc.strpm.outer, %pfor.cond.preheader.new
  %niter = phi i64 [ 0, %pfor.cond.preheader.new ], [ %niter.nadd, %pfor.inc.strpm.outer ]
  detach within %syncreg, label %pfor.body.strpm.outer, label %pfor.inc.strpm.outer

pfor.body.strpm.outer:                            ; preds = %pfor.cond.strpm.outer
  %2 = shl i64 %niter, 11
  br label %vector.body

vector.body:                                      ; preds = %pfor.body.strpm.outer, %vector.body
  %index = phi i64 [ %index.next.1, %vector.body ], [ 0, %pfor.body.strpm.outer ]
  %offset.idx = add nuw nsw i64 %2, %index
  %3 = getelementptr inbounds i32, i32* %SA12, i64 %offset.idx
  %4 = bitcast i32* %3 to <8 x i32>*
  %wide.load = load <8 x i32>, <8 x i32>* %4, align 4, !tbaa !2
  %5 = zext <8 x i32> %wide.load to <8 x i64>
  %6 = icmp sgt <8 x i64> %broadcast.splat35, %5
  %7 = sub nsw <8 x i64> %5, %broadcast.splat35
  %8 = mul nsw <8 x i64> %7, <i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3>
  %9 = add nsw <8 x i64> %8, <i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2>
  %10 = mul nuw nsw <8 x i64> %5, <i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3>
  %11 = add nuw nsw <8 x i64> %10, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
  %predphi = select <8 x i1> %6, <8 x i64> %11, <8 x i64> %9
  %12 = trunc <8 x i64> %predphi to <8 x i32>
  %13 = bitcast i32* %3 to <8 x i32>*
  store <8 x i32> %12, <8 x i32>* %13, align 4, !tbaa !2
  %index.next = or i64 %index, 8
  %offset.idx.1 = add nuw nsw i64 %2, %index.next
  %14 = getelementptr inbounds i32, i32* %SA12, i64 %offset.idx.1
  %15 = bitcast i32* %14 to <8 x i32>*
  %wide.load.1 = load <8 x i32>, <8 x i32>* %15, align 4, !tbaa !2
  %16 = zext <8 x i32> %wide.load.1 to <8 x i64>
  %17 = icmp sgt <8 x i64> %broadcast.splat35, %16
  %18 = sub nsw <8 x i64> %16, %broadcast.splat35
  %19 = mul nsw <8 x i64> %18, <i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3>
  %20 = add nsw <8 x i64> %19, <i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2>
  %21 = mul nuw nsw <8 x i64> %16, <i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3>
  %22 = add nuw nsw <8 x i64> %21, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
  %predphi.1 = select <8 x i1> %17, <8 x i64> %22, <8 x i64> %20
  %23 = trunc <8 x i64> %predphi.1 to <8 x i32>
  %24 = bitcast i32* %14 to <8 x i32>*
  store <8 x i32> %23, <8 x i32>* %24, align 4, !tbaa !2
  %index.next.1 = add nuw nsw i64 %index, 16
  %25 = icmp eq i64 %index.next.1, 2048
  br i1 %25, label %pfor.inc.reattach, label %vector.body, !llvm.loop !6

pfor.inc.reattach:                                ; preds = %vector.body
  reattach within %syncreg, label %pfor.inc.strpm.outer

pfor.inc.strpm.outer:                             ; preds = %pfor.inc.reattach, %pfor.cond.strpm.outer
  %niter.nadd = add nuw nsw i64 %niter, 1
  %niter.ncmp = icmp eq i64 %niter.nadd, %stripiter
  br i1 %niter.ncmp, label %pfor.cond.cleanup.strpm-lcssa, label %pfor.cond.strpm.outer, !llvm.loop !9

pfor.cond.cleanup.strpm-lcssa:                    ; preds = %pfor.inc.strpm.outer, %pfor.cond.preheader
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %pfor.cond.cleanup, label %pfor.cond.epil.preheader

pfor.cond.epil.preheader:                         ; preds = %pfor.cond.cleanup.strpm-lcssa
  %26 = and i64 %n12, -2048
  %min.iters.check = icmp ult i64 %xtraiter, 8
  br i1 %min.iters.check, label %pfor.cond.epil.preheader59, label %vector.ph39

vector.ph39:                                      ; preds = %pfor.cond.epil.preheader
  %n.mod.vf = and i64 %n12, 7
  %n.vec = sub nsw i64 %xtraiter, %n.mod.vf
  %ind.end43 = add i64 %26, %n.vec
  %broadcast.splatinsert56 = insertelement <8 x i64> undef, i64 %n1, i32 0
  %broadcast.splat57 = shufflevector <8 x i64> %broadcast.splatinsert56, <8 x i64> undef, <8 x i32> zeroinitializer
  br label %vector.body38

vector.body38:                                    ; preds = %vector.body38, %vector.ph39
  %index40 = phi i64 [ 0, %vector.ph39 ], [ %index.next41, %vector.body38 ]
  %offset.idx47 = add i64 %26, %index40
  %27 = getelementptr inbounds i32, i32* %SA12, i64 %offset.idx47
  %28 = bitcast i32* %27 to <8 x i32>*
  %wide.load55 = load <8 x i32>, <8 x i32>* %28, align 4, !tbaa !2
  %29 = zext <8 x i32> %wide.load55 to <8 x i64>
  %30 = icmp sgt <8 x i64> %broadcast.splat57, %29
  %31 = sub nsw <8 x i64> %29, %broadcast.splat57
  %32 = mul nsw <8 x i64> %31, <i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3>
  %33 = add nsw <8 x i64> %32, <i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2>
  %34 = mul nuw nsw <8 x i64> %29, <i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3, i64 3>
  %35 = add nuw nsw <8 x i64> %34, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
  %predphi58 = select <8 x i1> %30, <8 x i64> %35, <8 x i64> %33
  %36 = trunc <8 x i64> %predphi58 to <8 x i32>
  %37 = bitcast i32* %27 to <8 x i32>*
  store <8 x i32> %36, <8 x i32>* %37, align 4, !tbaa !2
  %index.next41 = add i64 %index40, 8
  %38 = icmp eq i64 %index.next41, %n.vec
  br i1 %38, label %middle.block36, label %vector.body38, !llvm.loop !12

middle.block36:                                   ; preds = %vector.body38
  %cmp.n46 = icmp eq i64 %n.mod.vf, 0
  br i1 %cmp.n46, label %pfor.cond.cleanup, label %pfor.cond.epil.preheader59

pfor.cond.epil.preheader59:                       ; preds = %middle.block36, %pfor.cond.epil.preheader
  %__begin.0.epil.ph = phi i64 [ %26, %pfor.cond.epil.preheader ], [ %ind.end43, %middle.block36 ]
  %epil.iter.ph = phi i64 [ %xtraiter, %pfor.cond.epil.preheader ], [ %n.mod.vf, %middle.block36 ]
  br label %pfor.cond.epil

pfor.cond.epil:                                   ; preds = %pfor.cond.epil.preheader59, %pfor.cond.epil
  %__begin.0.epil = phi i64 [ %inc.epil, %pfor.cond.epil ], [ %__begin.0.epil.ph, %pfor.cond.epil.preheader59 ]
  %epil.iter = phi i64 [ %epil.iter.sub, %pfor.cond.epil ], [ %epil.iter.ph, %pfor.cond.epil.preheader59 ]
  %arrayidx.epil = getelementptr inbounds i32, i32* %SA12, i64 %__begin.0.epil
  %39 = load i32, i32* %arrayidx.epil, align 4, !tbaa !2
  %conv.epil = zext i32 %39 to i64
  %cmp3.epil = icmp slt i64 %conv.epil, %n1
  %sub6.epil = select i1 %cmp3.epil, i64 0, i64 %n1
  %conv.epil.sink = sub nsw i64 %conv.epil, %sub6.epil
  %.sink = select i1 %cmp3.epil, i64 1, i64 2
  %mul4.epil = mul nsw i64 %conv.epil.sink, 3
  %add5.epil = add nsw i64 %mul4.epil, %.sink
  %conv9.epil = trunc i64 %add5.epil to i32
  store i32 %conv9.epil, i32* %arrayidx.epil, align 4, !tbaa !2
  %inc.epil = add nuw nsw i64 %__begin.0.epil, 1
  %epil.iter.sub = add nsw i64 %epil.iter, -1
  %epil.iter.cmp = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp, label %pfor.cond.cleanup, label %pfor.cond.epil, !llvm.loop !13

pfor.cond.cleanup:                                ; preds = %pfor.cond.epil, %middle.block36, %pfor.cond.cleanup.strpm-lcssa
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %entry
  ret void
}

; CHECK: define dso_local void @_Z14vectorlooptestPjll(i32* nocapture %SA12, i64 %n1, i64 %n12) local_unnamed_addr [[ATTRIBUTE:#.+]] {
; CHECK: call {{.*}}void @_Z14vectorlooptestPjll.outline_pfor.cond.strpm.outer.ls1(
; CHECK: <8 x i64> %{{.+}}, i32* %{{.+}})

; CHECK: define {{.*}}void @_Z14vectorlooptestPjll.outline_pfor.cond.strpm.outer.ls1(
; CHECK: [[ATTRIBUTE2:#.+]] {

; CHECK: attributes [[ATTRIBUTE]] = {
; CHECK-NOT: "min-legal-vector-width"="0"
; CHECK: }

; CHECK: attributes [[ATTRIBUTE2]] = {
; CHECK: "min-legal-vector-width"="0"
; CHECK: }


; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

attributes #0 = { argmemonly norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 54aa2d0357285fbd777b71244f245f1105cf4dd7)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = distinct !{!6, !7, !8}
!7 = !{!"llvm.loop.from.tapir.loop"}
!8 = !{!"llvm.loop.isvectorized", i32 1}
!9 = distinct !{!9, !10, !11}
!10 = !{!"tapir.loop.spawn.strategy", i32 1}
!11 = !{!"tapir.loop.grainsize", i32 1}
!12 = distinct !{!12, !7, !8}
!13 = distinct !{!13, !7, !14, !8}
!14 = !{!"llvm.loop.unroll.runtime.disable"}
