; RUN: opt < %s -loop-stripmine -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-stripmine' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: argmemonly norecurse nounwind uwtable
define dso_local void @parfor_novec(double* noalias nocapture %y, double* noalias nocapture readonly %x, double %a, i32 %n) local_unnamed_addr #0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %entry
  %wide.trip.count = zext i32 %n to i64
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %indvars.iv = phi i64 [ 0, %pfor.cond.preheader ], [ %indvars.iv.next, %pfor.inc ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %arrayidx = getelementptr inbounds double, double* %x, i64 %indvars.iv
  %0 = load double, double* %arrayidx, align 8, !tbaa !2
  %mul3 = fmul double %0, %a
  %arrayidx5 = getelementptr inbounds double, double* %y, i64 %indvars.iv
  %1 = load double, double* %arrayidx5, align 8, !tbaa !2
  %add6 = fadd double %1, %mul3
  store double %add6, double* %arrayidx5, align 8, !tbaa !2
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %entry
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly norecurse nounwind uwtable
define dso_local void @parfor_unroll_vec(double* noalias nocapture %y, double* noalias nocapture readonly %x, double %a, i32 %n) local_unnamed_addr #0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %entry
  %wide.trip.count = zext i32 %n to i64
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %indvars.iv = phi i64 [ 0, %pfor.cond.preheader ], [ %indvars.iv.next, %pfor.inc ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %arrayidx = getelementptr inbounds double, double* %x, i64 %indvars.iv
  %0 = load double, double* %arrayidx, align 8, !tbaa !2
  %mul3 = fmul double %0, %a
  %arrayidx5 = getelementptr inbounds double, double* %y, i64 %indvars.iv
  %1 = load double, double* %arrayidx5, align 8, !tbaa !2
  %add6 = fadd double %1, %mul3
  store double %add6, double* %arrayidx5, align 8, !tbaa !2
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !9

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %entry
  ret void
}

; CHECK: define dso_local void @parfor_novec(double* noalias nocapture %y, double* noalias nocapture readonly %x, double %a, i32 %n)
; CHECK: !llvm.loop [[STRPM_LOOPID1:![0-9]+]]
; CHECK: !llvm.loop [[STRPM_OUTER_LOOPID1:![0-9]+]]
; CHECK: !llvm.loop [[STRPM_EPIL_LOOPID1:![0-9]+]]

; CHECK: define dso_local void @parfor_unroll_vec(double* noalias nocapture %y, double* noalias nocapture readonly %x, double %a, i32 %n)
; CHECK: !llvm.loop [[STRPM_LOOPID2:![0-9]+]]
; CHECK: !llvm.loop [[STRPM_OUTER_LOOPID2:![0-9]+]]
; CHECK: !llvm.loop [[STRPM_EPIL_LOOPID2:![0-9]+]]

attributes #0 = { argmemonly norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 54aa2d0357285fbd777b71244f245f1105cf4dd7)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"double", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = distinct !{!6, !7, !8}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
!8 = !{!"llvm.loop.vectorize.width", i32 1}
!9 = distinct !{!9, !7, !10, !11, !12}
!10 = !{!"llvm.loop.vectorize.width", i32 4}
!11 = !{!"llvm.loop.vectorize.enable", i1 true}
!12 = !{!"llvm.loop.vectorize.followup_all", !13}
!13 = distinct !{!13, !7, !14, !15}
!14 = !{!"llvm.loop.isvectorized"}
!15 = !{!"llvm.loop.unroll.count", i32 4}

; CHECK: [[STRPM_LOOPID1]] = distinct !{[[STRPM_LOOPID1]], [[NOVEC:![0-9]+]], [[FROM_TAPIR:![0-9]+]]}
; CHECK: [[NOVEC]] = !{!"llvm.loop.vectorize.width", i32 1}
; CHECK: [[FROM_TAPIR]] = !{!"llvm.loop.from.tapir.loop"}

; CHECK: [[STRPM_OUTER_LOOPID1]] = distinct !{[[STRPM_OUTER_LOOPID1]], [[SPAWN_STRATEGY:![0-9]+]], [[NOVEC]], [[GRAINSIZE:![0-9]+]]}
; CHECK: [[SPAWN_STRATEGY]] = !{!"tapir.loop.spawn.strategy", i32 1}
; CHECK: [[GRAINSIZE]] = !{!"tapir.loop.grainsize", i32 1}

; CHECK: [[STRPM_EPIL_LOOPID1]] = distinct !{[[STRPM_EPIL_LOOPID1]], [[FROM_TAPIR]], [[NOVEC]]}

; CHECK: [[STRPM_LOOPID2]] = distinct !{[[STRPM_LOOPID2]], [[VECATTRS:!.+]], [[FROM_TAPIR]]}

; CHECK: [[STRPM_OUTER_LOOPID2]] = distinct !{[[STRPM_OUTER_LOOPID2]], [[SPAWN_STRATEGY]], [[VECATTRS]], [[GRAINSIZE]]}

; CHECK: [[STRPM_EPIL_LOOPID2]] = distinct !{[[STRPM_EPIL_LOOPID2]], [[FROM_TAPIR]], [[VECATTRS]]}
