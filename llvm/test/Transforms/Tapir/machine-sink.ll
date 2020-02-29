; Test that machine-sink does not sink register arithmetic past
; setjmps implementing continuations.
;
; This test is derived from the LU benchmark in the Cilk5 suite.
;
; RUN: llc < %s -mtriple=x86_64-- -stop-after machine-sink | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.__cilkrts_stack_frame = type { i32, %struct.__cilkrts_stack_frame*, %struct.__cilkrts_worker*, [5 x i8*], i32, i16, i16, i32 }
%struct.__cilkrts_worker = type { %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, i32, i8*, i8*, %struct.__cilkrts_stack_frame* }

; Function Attrs: stealable
define dso_local void @schur([16 x [16 x double]]* nocapture %M, [16 x [16 x double]]* nocapture readonly %V, [16 x [16 x double]]* nocapture readonly %W, i32 %nb) local_unnamed_addr #0 {
entry:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  %0 = call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #3
  %1 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 0
  store atomic i32 16777216, i32* %1 release, align 8
  %2 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %0, i64 0, i32 7
  %3 = load atomic %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %2 acquire, align 8
  %4 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 1
  store atomic %struct.__cilkrts_stack_frame* %3, %struct.__cilkrts_stack_frame** %4 release, align 8
  %5 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 2
  store atomic %struct.__cilkrts_worker* %0, %struct.__cilkrts_worker** %5 release, align 8
  store atomic %struct.__cilkrts_stack_frame* %__cilkrts_sf, %struct.__cilkrts_stack_frame** %2 release, align 8
  %cmp129 = icmp eq i32 %nb, 1
  br i1 %cmp129, label %for.cond1.preheader.i.preheader, label %if.end.preheader

if.end.preheader:                                 ; preds = %entry
  %6 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4
  %7 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 5
  %8 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 3
  %9 = getelementptr inbounds [5 x i8*], [5 x i8*]* %8, i64 0, i64 0
  %10 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 3, i64 2
  %11 = bitcast [5 x i8*]* %8 to i8*
  br label %if.end

for.cond1.preheader.i.preheader:                  ; preds = %det.cont56, %entry
  %M.tr.lcssa = phi [16 x [16 x double]]* [ %M, %entry ], [ %arrayidx6, %det.cont56 ]
  %V.tr.lcssa = phi [16 x [16 x double]]* [ %V, %entry ], [ %arrayidx22, %det.cont56 ]
  %W.tr.lcssa = phi [16 x [16 x double]]* [ %W, %entry ], [ %arrayidx38, %det.cont56 ]
  br label %for.cond1.preheader.i

for.cond1.preheader.i:                            ; preds = %for.inc12.i, %for.cond1.preheader.i.preheader
  %indvars.iv25.i = phi i64 [ %indvars.iv.next26.i, %for.inc12.i ], [ 0, %for.cond1.preheader.i.preheader ]
  %arrayidx2.i.2.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 13
  %.pre.i = load double, double* %arrayidx2.i.2.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.3.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 12
  %.pre28.i = load double, double* %arrayidx2.i.3.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.4.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 11
  %.pre29.i = load double, double* %arrayidx2.i.4.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.5.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 10
  %.pre30.i = load double, double* %arrayidx2.i.5.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.6.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 9
  %.pre31.i = load double, double* %arrayidx2.i.6.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.7.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 8
  %.pre32.i = load double, double* %arrayidx2.i.7.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.8.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 7
  %.pre33.i = load double, double* %arrayidx2.i.8.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.9.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 6
  %.pre34.i = load double, double* %arrayidx2.i.9.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.10.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 5
  %.pre35.i = load double, double* %arrayidx2.i.10.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.11.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 4
  %.pre36.i = load double, double* %arrayidx2.i.11.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.12.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 3
  %.pre37.i = load double, double* %arrayidx2.i.12.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.13.phi.trans.insert.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 2
  %.pre38.i = load double, double* %arrayidx2.i.13.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx2.i.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 15
  %arrayidx2.i.1.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 14
  %arrayidx2.i.14.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 1
  %arrayidx2.i.15.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 0
  %.pre = load double, double* %arrayidx2.i.i, align 8, !tbaa !0
  %.pre139 = load double, double* %arrayidx2.i.1.i, align 8, !tbaa !0
  %.pre140 = load double, double* %arrayidx2.i.14.i, align 8, !tbaa !0
  %.pre141 = load double, double* %arrayidx2.i.15.i, align 8, !tbaa !0
  br label %for.body3.i

for.body3.i:                                      ; preds = %for.body3.i, %for.cond1.preheader.i
  %12 = phi double [ %.pre141, %for.cond1.preheader.i ], [ %sub.i.15.i, %for.body3.i ]
  %13 = phi double [ %.pre140, %for.cond1.preheader.i ], [ %sub.i.14.i, %for.body3.i ]
  %14 = phi double [ %.pre139, %for.cond1.preheader.i ], [ %sub.i.1.i, %for.body3.i ]
  %15 = phi double [ %.pre, %for.cond1.preheader.i ], [ %sub.i.i, %for.body3.i ]
  %16 = phi double [ %.pre38.i, %for.cond1.preheader.i ], [ %sub.i.13.i, %for.body3.i ]
  %17 = phi double [ %.pre37.i, %for.cond1.preheader.i ], [ %sub.i.12.i, %for.body3.i ]
  %18 = phi double [ %.pre36.i, %for.cond1.preheader.i ], [ %sub.i.11.i, %for.body3.i ]
  %19 = phi double [ %.pre35.i, %for.cond1.preheader.i ], [ %sub.i.10.i, %for.body3.i ]
  %20 = phi double [ %.pre34.i, %for.cond1.preheader.i ], [ %sub.i.9.i, %for.body3.i ]
  %21 = phi double [ %.pre33.i, %for.cond1.preheader.i ], [ %sub.i.8.i, %for.body3.i ]
  %22 = phi double [ %.pre32.i, %for.cond1.preheader.i ], [ %sub.i.7.i, %for.body3.i ]
  %23 = phi double [ %.pre31.i, %for.cond1.preheader.i ], [ %sub.i.6.i, %for.body3.i ]
  %24 = phi double [ %.pre30.i, %for.cond1.preheader.i ], [ %sub.i.5.i, %for.body3.i ]
  %25 = phi double [ %.pre29.i, %for.cond1.preheader.i ], [ %sub.i.4.i, %for.body3.i ]
  %26 = phi double [ %.pre28.i, %for.cond1.preheader.i ], [ %sub.i.3.i, %for.body3.i ]
  %27 = phi double [ %.pre.i, %for.cond1.preheader.i ], [ %sub.i.2.i, %for.body3.i ]
  %indvars.iv.i = phi i64 [ 0, %for.cond1.preheader.i ], [ %indvars.iv.next.i, %for.body3.i ]
  %arrayidx5.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %V.tr.lcssa, i64 0, i64 %indvars.iv25.i, i64 %indvars.iv.i
  %28 = load double, double* %arrayidx5.i, align 8, !tbaa !0
  %arrayidx.i.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 15
  %29 = load double, double* %arrayidx.i.i, align 8, !tbaa !0
  %mul.i.i = fmul double %28, %29
  %sub.i.i = fsub double %15, %mul.i.i
  store double %sub.i.i, double* %arrayidx2.i.i, align 8, !tbaa !0
  %arrayidx.i.1.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 14
  %30 = load double, double* %arrayidx.i.1.i, align 8, !tbaa !0
  %mul.i.1.i = fmul double %28, %30
  %sub.i.1.i = fsub double %14, %mul.i.1.i
  store double %sub.i.1.i, double* %arrayidx2.i.1.i, align 8, !tbaa !0
  %arrayidx.i.2.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 13
  %31 = load double, double* %arrayidx.i.2.i, align 8, !tbaa !0
  %mul.i.2.i = fmul double %28, %31
  %sub.i.2.i = fsub double %27, %mul.i.2.i
  store double %sub.i.2.i, double* %arrayidx2.i.2.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.3.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 12
  %32 = load double, double* %arrayidx.i.3.i, align 8, !tbaa !0
  %mul.i.3.i = fmul double %28, %32
  %sub.i.3.i = fsub double %26, %mul.i.3.i
  store double %sub.i.3.i, double* %arrayidx2.i.3.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.4.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 11
  %33 = load double, double* %arrayidx.i.4.i, align 8, !tbaa !0
  %mul.i.4.i = fmul double %28, %33
  %sub.i.4.i = fsub double %25, %mul.i.4.i
  store double %sub.i.4.i, double* %arrayidx2.i.4.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.5.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 10
  %34 = load double, double* %arrayidx.i.5.i, align 8, !tbaa !0
  %mul.i.5.i = fmul double %28, %34
  %sub.i.5.i = fsub double %24, %mul.i.5.i
  store double %sub.i.5.i, double* %arrayidx2.i.5.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.6.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 9
  %35 = load double, double* %arrayidx.i.6.i, align 8, !tbaa !0
  %mul.i.6.i = fmul double %28, %35
  %sub.i.6.i = fsub double %23, %mul.i.6.i
  store double %sub.i.6.i, double* %arrayidx2.i.6.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.7.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 8
  %36 = load double, double* %arrayidx.i.7.i, align 8, !tbaa !0
  %mul.i.7.i = fmul double %28, %36
  %sub.i.7.i = fsub double %22, %mul.i.7.i
  store double %sub.i.7.i, double* %arrayidx2.i.7.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.8.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 7
  %37 = load double, double* %arrayidx.i.8.i, align 8, !tbaa !0
  %mul.i.8.i = fmul double %28, %37
  %sub.i.8.i = fsub double %21, %mul.i.8.i
  store double %sub.i.8.i, double* %arrayidx2.i.8.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.9.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 6
  %38 = load double, double* %arrayidx.i.9.i, align 8, !tbaa !0
  %mul.i.9.i = fmul double %28, %38
  %sub.i.9.i = fsub double %20, %mul.i.9.i
  store double %sub.i.9.i, double* %arrayidx2.i.9.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.10.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 5
  %39 = load double, double* %arrayidx.i.10.i, align 8, !tbaa !0
  %mul.i.10.i = fmul double %28, %39
  %sub.i.10.i = fsub double %19, %mul.i.10.i
  store double %sub.i.10.i, double* %arrayidx2.i.10.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.11.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 4
  %40 = load double, double* %arrayidx.i.11.i, align 8, !tbaa !0
  %mul.i.11.i = fmul double %28, %40
  %sub.i.11.i = fsub double %18, %mul.i.11.i
  store double %sub.i.11.i, double* %arrayidx2.i.11.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.12.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 3
  %41 = load double, double* %arrayidx.i.12.i, align 8, !tbaa !0
  %mul.i.12.i = fmul double %28, %41
  %sub.i.12.i = fsub double %17, %mul.i.12.i
  store double %sub.i.12.i, double* %arrayidx2.i.12.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.13.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 2
  %42 = load double, double* %arrayidx.i.13.i, align 8, !tbaa !0
  %mul.i.13.i = fmul double %28, %42
  %sub.i.13.i = fsub double %16, %mul.i.13.i
  store double %sub.i.13.i, double* %arrayidx2.i.13.phi.trans.insert.i, align 8, !tbaa !0
  %arrayidx.i.14.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 1
  %43 = load double, double* %arrayidx.i.14.i, align 8, !tbaa !0
  %mul.i.14.i = fmul double %28, %43
  %sub.i.14.i = fsub double %13, %mul.i.14.i
  store double %sub.i.14.i, double* %arrayidx2.i.14.i, align 8, !tbaa !0
  %arrayidx.i.15.i = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr.lcssa, i64 0, i64 %indvars.iv.i, i64 0
  %44 = load double, double* %arrayidx.i.15.i, align 8, !tbaa !0
  %mul.i.15.i = fmul double %28, %44
  %sub.i.15.i = fsub double %12, %mul.i.15.i
  store double %sub.i.15.i, double* %arrayidx2.i.15.i, align 8, !tbaa !0
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, 16
  br i1 %exitcond.i, label %for.inc12.i, label %for.body3.i

for.inc12.i:                                      ; preds = %for.body3.i
  %indvars.iv.next26.i = add nuw nsw i64 %indvars.iv25.i, 1
  %exitcond27.i = icmp eq i64 %indvars.iv.next26.i, 16
  br i1 %exitcond27.i, label %cleanup, label %for.cond1.preheader.i

if.end:                                           ; preds = %if.end.preheader, %det.cont56
  %nb.tr136 = phi i32 [ %div, %det.cont56 ], [ %nb, %if.end.preheader ]
  %W.tr134 = phi [16 x [16 x double]]* [ %arrayidx38, %det.cont56 ], [ %W, %if.end.preheader ]
  %V.tr132 = phi [16 x [16 x double]]* [ %arrayidx22, %det.cont56 ], [ %V, %if.end.preheader ]
  %M.tr130 = phi [16 x [16 x double]]* [ %arrayidx6, %det.cont56 ], [ %M, %if.end.preheader ]
  %div = sdiv i32 %nb.tr136, 2
  %idxprom5 = sext i32 %div to i64
  %arrayidx6 = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %M.tr130, i64 %idxprom5
  %arrayidx22 = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %V.tr132, i64 %idxprom5
  %arrayidx38 = getelementptr inbounds [16 x [16 x double]], [16 x [16 x double]]* %W.tr134, i64 %idxprom5
  call void asm sideeffect "stmxcsr $0\0A\09fnstcw $1", "*m,*m,~{dirflag},~{fpsr},~{flags}"(i32* nonnull %6, i16* nonnull %7) #3
  %45 = call i8* @llvm.frameaddress(i32 0)
  store volatile i8* %45, i8** %9, align 8
  %46 = call i8* @llvm.stacksave()
  store volatile i8* %46, i8** %10, align 8
  %47 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %11) #4
  %48 = icmp eq i32 %47, 0
  br i1 %48, label %if.end.split, label %det.cont

if.end.split:                                     ; preds = %if.end
  call fastcc void @schur.outline_det.achd.otd1([16 x [16 x double]]* %M.tr130, [16 x [16 x double]]* %V.tr132, [16 x [16 x double]]* %W.tr134, i32 %div) #3
  br label %det.cont

det.cont:                                         ; preds = %if.end, %if.end.split
  call void asm sideeffect "stmxcsr $0\0A\09fnstcw $1", "*m,*m,~{dirflag},~{fpsr},~{flags}"(i32* nonnull %6, i16* nonnull %7) #3
  store volatile i8* %45, i8** %9, align 8
  %49 = call i8* @llvm.stacksave()
  store volatile i8* %49, i8** %10, align 8
  %50 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %11) #4
  %51 = icmp eq i32 %50, 0
  br i1 %51, label %det.cont.split, label %det.cont48

det.cont.split:                                   ; preds = %det.cont
  call fastcc void @schur.outline_det.achd47.otd1([16 x [16 x double]]* %arrayidx6, [16 x [16 x double]]* %V.tr132, [16 x [16 x double]]* %arrayidx38, i32 %div) #3
  br label %det.cont48

det.cont48:                                       ; preds = %det.cont, %det.cont.split
  call void asm sideeffect "stmxcsr $0\0A\09fnstcw $1", "*m,*m,~{dirflag},~{fpsr},~{flags}"(i32* nonnull %6, i16* nonnull %7) #3
  store volatile i8* %45, i8** %9, align 8
  %52 = call i8* @llvm.stacksave()
  store volatile i8* %52, i8** %10, align 8
  %53 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %11) #4
  %54 = icmp eq i32 %53, 0
  br i1 %54, label %det.cont48.split, label %det.cont50

det.cont48.split:                                 ; preds = %det.cont48
  call fastcc void @schur.outline_det.achd49.otd1([16 x [16 x double]]* %M.tr130, [16 x [16 x double]]* %V.tr132, [16 x [16 x double]]* %W.tr134, i32 %div) #3
  br label %det.cont50

det.cont50:                                       ; preds = %det.cont48, %det.cont48.split
  tail call void @schur([16 x [16 x double]]* %arrayidx6, [16 x [16 x double]]* %V.tr132, [16 x [16 x double]]* %arrayidx38, i32 %div)
  %55 = load atomic i32, i32* %1 acquire, align 8
  %56 = and i32 %55, 2
  %57 = icmp eq i32 %56, 0
  br i1 %57, label %sync.continue, label %cilk.sync.savestate.i

cilk.sync.savestate.i:                            ; preds = %det.cont50
  call void asm sideeffect "stmxcsr $0\0A\09fnstcw $1", "*m,*m,~{dirflag},~{fpsr},~{flags}"(i32* nonnull %6, i16* nonnull %7) #3
  store volatile i8* %45, i8** %9, align 8
  %58 = call i8* @llvm.stacksave()
  store volatile i8* %58, i8** %10, align 8
  %59 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %11) #4
  %60 = icmp eq i32 %59, 0
  br i1 %60, label %cilk.sync.runtimecall.i, label %sync.continue

cilk.sync.runtimecall.i:                          ; preds = %cilk.sync.savestate.i
  call void @__cilkrts_sync(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf)
  br label %sync.continue

sync.continue:                                    ; preds = %cilk.sync.runtimecall.i, %cilk.sync.savestate.i, %det.cont50
  call void asm sideeffect "stmxcsr $0\0A\09fnstcw $1", "*m,*m,~{dirflag},~{fpsr},~{flags}"(i32* nonnull %6, i16* nonnull %7) #3
  store volatile i8* %45, i8** %9, align 8
  %61 = call i8* @llvm.stacksave()
  store volatile i8* %61, i8** %10, align 8
  %62 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %11) #4
  %63 = icmp eq i32 %62, 0
  br i1 %63, label %sync.continue.split, label %det.cont52

sync.continue.split:                              ; preds = %sync.continue
  call fastcc void @schur.outline_det.achd51.otd1([16 x [16 x double]]* %M.tr130, [16 x [16 x double]]* %arrayidx22, [16 x [16 x double]]* %W.tr134, i32 %div) #3
  br label %det.cont52

det.cont52:                                       ; preds = %sync.continue, %sync.continue.split
  call void asm sideeffect "stmxcsr $0\0A\09fnstcw $1", "*m,*m,~{dirflag},~{fpsr},~{flags}"(i32* nonnull %6, i16* nonnull %7) #3
  store volatile i8* %45, i8** %9, align 8
  %64 = call i8* @llvm.stacksave()
  store volatile i8* %64, i8** %10, align 8
  %65 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %11) #4
  %66 = icmp eq i32 %65, 0
  br i1 %66, label %det.cont52.split, label %det.cont54

det.cont52.split:                                 ; preds = %det.cont52
  call fastcc void @schur.outline_det.achd53.otd1([16 x [16 x double]]* %arrayidx6, [16 x [16 x double]]* %arrayidx22, [16 x [16 x double]]* %arrayidx38, i32 %div) #3
  br label %det.cont54

det.cont54:                                       ; preds = %det.cont52, %det.cont52.split
  call void asm sideeffect "stmxcsr $0\0A\09fnstcw $1", "*m,*m,~{dirflag},~{fpsr},~{flags}"(i32* nonnull %6, i16* nonnull %7) #3
  store volatile i8* %45, i8** %9, align 8
  %67 = call i8* @llvm.stacksave()
  store volatile i8* %67, i8** %10, align 8
  %68 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %11) #4
  %69 = icmp eq i32 %68, 0
  br i1 %69, label %det.cont54.split, label %det.cont56

det.cont54.split:                                 ; preds = %det.cont54
  call fastcc void @schur.outline_det.achd55.otd1([16 x [16 x double]]* %M.tr130, [16 x [16 x double]]* %arrayidx22, [16 x [16 x double]]* %W.tr134, i32 %div) #3
  br label %det.cont56

det.cont56:                                       ; preds = %det.cont54, %det.cont54.split
  %70 = and i32 %nb.tr136, -2
  %71 = icmp eq i32 %70, 2
  br i1 %71, label %for.cond1.preheader.i.preheader, label %if.end

cleanup:                                          ; preds = %for.inc12.i
  %72 = load atomic i32, i32* %1 acquire, align 8
  %73 = and i32 %72, 2
  %74 = icmp eq i32 %73, 0
  br i1 %74, label %cleanup.split, label %cilk.sync.savestate.i1

cilk.sync.savestate.i1:                           ; preds = %cleanup
  %75 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4
  %76 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 5
  call void asm sideeffect "stmxcsr $0\0A\09fnstcw $1", "*m,*m,~{dirflag},~{fpsr},~{flags}"(i32* nonnull %75, i16* nonnull %76) #3
  %77 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 3
  %78 = call i8* @llvm.frameaddress(i32 0)
  %79 = getelementptr inbounds [5 x i8*], [5 x i8*]* %77, i64 0, i64 0
  store volatile i8* %78, i8** %79, align 8
  %80 = call i8* @llvm.stacksave()
  %81 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 3, i64 2
  store volatile i8* %80, i8** %81, align 8
  %82 = bitcast [5 x i8*]* %77 to i8*
  %83 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %82) #4
  %84 = icmp eq i32 %83, 0
  br i1 %84, label %cilk.sync.runtimecall.i2, label %cleanup.split

cilk.sync.runtimecall.i2:                         ; preds = %cilk.sync.savestate.i1
  call void @__cilkrts_sync(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf)
  br label %cleanup.split

cleanup.split:                                    ; preds = %cilk.sync.runtimecall.i2, %cilk.sync.savestate.i1, %cleanup
  %85 = bitcast %struct.__cilkrts_stack_frame** %4 to i64*
  %86 = load i64, i64* %85, align 8
  %87 = load atomic %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5 acquire, align 8
  %88 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %87, i64 0, i32 7
  %89 = bitcast %struct.__cilkrts_stack_frame** %88 to i64*
  store atomic i64 %86, i64* %89 release, align 8
  store atomic %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %4 release, align 8
  %90 = load atomic i32, i32* %1 acquire, align 8
  %91 = icmp eq i32 %90, 16777216
  br i1 %91, label %__cilk_parent_epilogue.exit, label %body.i

body.i:                                           ; preds = %cleanup.split
  call void @__cilkrts_leave_frame(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %cleanup.split, %body.i
  ret void
}

; Function Attrs: noinline nounwind
define private fastcc void @schur.outline_det.achd55.otd1([16 x [16 x double]]* nocapture align 1 %arrayidx10.otd1, [16 x [16 x double]]* nocapture readonly align 1 %arrayidx30.otd1, [16 x [16 x double]]* nocapture readonly align 1 %arrayidx42.otd1, i32 %div.otd1) unnamed_addr #1 {
det.cont54.otd1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  %0 = tail call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #3
  %1 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 0
  store atomic i32 16777216, i32* %1 release, align 8
  %2 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %0, i64 0, i32 7
  %3 = load atomic %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %2 acquire, align 8
  %4 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 1
  store atomic %struct.__cilkrts_stack_frame* %3, %struct.__cilkrts_stack_frame** %4 release, align 8
  %5 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 2
  store atomic %struct.__cilkrts_worker* %0, %struct.__cilkrts_worker** %5 release, align 8
  store atomic %struct.__cilkrts_stack_frame* %__cilkrts_sf, %struct.__cilkrts_stack_frame** %2 release, align 8
  %6 = load %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5, align 8
  %7 = bitcast %struct.__cilkrts_stack_frame** %4 to i64*
  %8 = load i64, i64* %7, align 8
  %9 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %6, i64 0, i32 0
  %10 = load atomic %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame*** %9 acquire, align 8
  fence release
  %11 = bitcast %struct.__cilkrts_stack_frame** %10 to i64*
  store volatile i64 %8, i64* %11, align 8
  %12 = getelementptr %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %10, i64 1
  store atomic %struct.__cilkrts_stack_frame** %12, %struct.__cilkrts_stack_frame*** %9 release, align 8
  %13 = load atomic i32, i32* %1 acquire, align 8
  %14 = or i32 %13, 4
  store atomic i32 %14, i32* %1 release, align 8
  tail call void @schur([16 x [16 x double]]* %arrayidx10.otd1, [16 x [16 x double]]* %arrayidx30.otd1, [16 x [16 x double]]* %arrayidx42.otd1, i32 %div.otd1) #3
  %15 = load i64, i64* %7, align 8
  %16 = load atomic %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5 acquire, align 8
  %17 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %16, i64 0, i32 7
  %18 = bitcast %struct.__cilkrts_stack_frame** %17 to i64*
  store atomic i64 %15, i64* %18 release, align 8
  store atomic %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %4 release, align 8
  %19 = load atomic i32, i32* %1 acquire, align 8
  %20 = icmp eq i32 %19, 16777216
  br i1 %20, label %__cilk_parent_epilogue.exit, label %body.i

body.i:                                           ; preds = %det.cont54.otd1
  call void @__cilkrts_leave_frame(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %det.cont54.otd1, %body.i
  ret void
}

; Function Attrs: noinline nounwind
define private fastcc void @schur.outline_det.achd53.otd1([16 x [16 x double]]* nocapture align 1 %arrayidx6.otd1, [16 x [16 x double]]* nocapture readonly align 1 %arrayidx22.otd1, [16 x [16 x double]]* nocapture readonly align 1 %arrayidx46.otd1, i32 %div.otd1) unnamed_addr #1 {
det.cont52.otd1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  %0 = tail call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #3
  %1 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 0
  store atomic i32 16777216, i32* %1 release, align 8
  %2 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %0, i64 0, i32 7
  %3 = load atomic %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %2 acquire, align 8
  %4 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 1
  store atomic %struct.__cilkrts_stack_frame* %3, %struct.__cilkrts_stack_frame** %4 release, align 8
  %5 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 2
  store atomic %struct.__cilkrts_worker* %0, %struct.__cilkrts_worker** %5 release, align 8
  store atomic %struct.__cilkrts_stack_frame* %__cilkrts_sf, %struct.__cilkrts_stack_frame** %2 release, align 8
  %6 = load %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5, align 8
  %7 = bitcast %struct.__cilkrts_stack_frame** %4 to i64*
  %8 = load i64, i64* %7, align 8
  %9 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %6, i64 0, i32 0
  %10 = load atomic %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame*** %9 acquire, align 8
  fence release
  %11 = bitcast %struct.__cilkrts_stack_frame** %10 to i64*
  store volatile i64 %8, i64* %11, align 8
  %12 = getelementptr %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %10, i64 1
  store atomic %struct.__cilkrts_stack_frame** %12, %struct.__cilkrts_stack_frame*** %9 release, align 8
  %13 = load atomic i32, i32* %1 acquire, align 8
  %14 = or i32 %13, 4
  store atomic i32 %14, i32* %1 release, align 8
  tail call void @schur([16 x [16 x double]]* %arrayidx6.otd1, [16 x [16 x double]]* %arrayidx22.otd1, [16 x [16 x double]]* %arrayidx46.otd1, i32 %div.otd1) #3
  %15 = load i64, i64* %7, align 8
  %16 = load atomic %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5 acquire, align 8
  %17 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %16, i64 0, i32 7
  %18 = bitcast %struct.__cilkrts_stack_frame** %17 to i64*
  store atomic i64 %15, i64* %18 release, align 8
  store atomic %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %4 release, align 8
  %19 = load atomic i32, i32* %1 acquire, align 8
  %20 = icmp eq i32 %19, 16777216
  br i1 %20, label %__cilk_parent_epilogue.exit, label %body.i

body.i:                                           ; preds = %det.cont52.otd1
  call void @__cilkrts_leave_frame(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %det.cont52.otd1, %body.i
  ret void
}

; Function Attrs: noinline nounwind
define private fastcc void @schur.outline_det.achd51.otd1([16 x [16 x double]]* nocapture align 1 %M.tr130.otd1, [16 x [16 x double]]* nocapture readonly align 1 %arrayidx22.otd1, [16 x [16 x double]]* nocapture readonly align 1 %arrayidx42.otd1, i32 %div.otd1) unnamed_addr #1 {
sync.continue.otd1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  %0 = tail call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #3
  %1 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 0
  store atomic i32 16777216, i32* %1 release, align 8
  %2 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %0, i64 0, i32 7
  %3 = load atomic %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %2 acquire, align 8
  %4 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 1
  store atomic %struct.__cilkrts_stack_frame* %3, %struct.__cilkrts_stack_frame** %4 release, align 8
  %5 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 2
  store atomic %struct.__cilkrts_worker* %0, %struct.__cilkrts_worker** %5 release, align 8
  store atomic %struct.__cilkrts_stack_frame* %__cilkrts_sf, %struct.__cilkrts_stack_frame** %2 release, align 8
  %6 = load %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5, align 8
  %7 = bitcast %struct.__cilkrts_stack_frame** %4 to i64*
  %8 = load i64, i64* %7, align 8
  %9 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %6, i64 0, i32 0
  %10 = load atomic %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame*** %9 acquire, align 8
  fence release
  %11 = bitcast %struct.__cilkrts_stack_frame** %10 to i64*
  store volatile i64 %8, i64* %11, align 8
  %12 = getelementptr %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %10, i64 1
  store atomic %struct.__cilkrts_stack_frame** %12, %struct.__cilkrts_stack_frame*** %9 release, align 8
  %13 = load atomic i32, i32* %1 acquire, align 8
  %14 = or i32 %13, 4
  store atomic i32 %14, i32* %1 release, align 8
  tail call void @schur([16 x [16 x double]]* %M.tr130.otd1, [16 x [16 x double]]* %arrayidx22.otd1, [16 x [16 x double]]* %arrayidx42.otd1, i32 %div.otd1) #3
  %15 = load i64, i64* %7, align 8
  %16 = load atomic %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5 acquire, align 8
  %17 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %16, i64 0, i32 7
  %18 = bitcast %struct.__cilkrts_stack_frame** %17 to i64*
  store atomic i64 %15, i64* %18 release, align 8
  store atomic %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %4 release, align 8
  %19 = load atomic i32, i32* %1 acquire, align 8
  %20 = icmp eq i32 %19, 16777216
  br i1 %20, label %__cilk_parent_epilogue.exit, label %body.i

body.i:                                           ; preds = %sync.continue.otd1
  call void @__cilkrts_leave_frame(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %sync.continue.otd1, %body.i
  ret void
}

; Function Attrs: noinline nounwind
define private fastcc void @schur.outline_det.achd49.otd1([16 x [16 x double]]* nocapture align 1 %arrayidx10.otd1, [16 x [16 x double]]* nocapture readonly align 1 %arrayidx26.otd1, [16 x [16 x double]]* nocapture readonly align 1 %W.tr134.otd1, i32 %div.otd1) unnamed_addr #1 {
det.cont48.otd1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  %0 = tail call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #3
  %1 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 0
  store atomic i32 16777216, i32* %1 release, align 8
  %2 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %0, i64 0, i32 7
  %3 = load atomic %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %2 acquire, align 8
  %4 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 1
  store atomic %struct.__cilkrts_stack_frame* %3, %struct.__cilkrts_stack_frame** %4 release, align 8
  %5 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 2
  store atomic %struct.__cilkrts_worker* %0, %struct.__cilkrts_worker** %5 release, align 8
  store atomic %struct.__cilkrts_stack_frame* %__cilkrts_sf, %struct.__cilkrts_stack_frame** %2 release, align 8
  %6 = load %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5, align 8
  %7 = bitcast %struct.__cilkrts_stack_frame** %4 to i64*
  %8 = load i64, i64* %7, align 8
  %9 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %6, i64 0, i32 0
  %10 = load atomic %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame*** %9 acquire, align 8
  fence release
  %11 = bitcast %struct.__cilkrts_stack_frame** %10 to i64*
  store volatile i64 %8, i64* %11, align 8
  %12 = getelementptr %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %10, i64 1
  store atomic %struct.__cilkrts_stack_frame** %12, %struct.__cilkrts_stack_frame*** %9 release, align 8
  %13 = load atomic i32, i32* %1 acquire, align 8
  %14 = or i32 %13, 4
  store atomic i32 %14, i32* %1 release, align 8
  tail call void @schur([16 x [16 x double]]* %arrayidx10.otd1, [16 x [16 x double]]* %arrayidx26.otd1, [16 x [16 x double]]* %W.tr134.otd1, i32 %div.otd1) #3
  %15 = load i64, i64* %7, align 8
  %16 = load atomic %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5 acquire, align 8
  %17 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %16, i64 0, i32 7
  %18 = bitcast %struct.__cilkrts_stack_frame** %17 to i64*
  store atomic i64 %15, i64* %18 release, align 8
  store atomic %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %4 release, align 8
  %19 = load atomic i32, i32* %1 acquire, align 8
  %20 = icmp eq i32 %19, 16777216
  br i1 %20, label %__cilk_parent_epilogue.exit, label %body.i

body.i:                                           ; preds = %det.cont48.otd1
  call void @__cilkrts_leave_frame(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %det.cont48.otd1, %body.i
  ret void
}

; Function Attrs: noinline nounwind
define private fastcc void @schur.outline_det.achd47.otd1([16 x [16 x double]]* nocapture align 1 %arrayidx6.otd1, [16 x [16 x double]]* nocapture readonly align 1 %V.tr132.otd1, [16 x [16 x double]]* nocapture readonly align 1 %arrayidx38.otd1, i32 %div.otd1) unnamed_addr #1 {
det.cont.otd1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  %0 = tail call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #3
  %1 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 0
  store atomic i32 16777216, i32* %1 release, align 8
  %2 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %0, i64 0, i32 7
  %3 = load atomic %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %2 acquire, align 8
  %4 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 1
  store atomic %struct.__cilkrts_stack_frame* %3, %struct.__cilkrts_stack_frame** %4 release, align 8
  %5 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 2
  store atomic %struct.__cilkrts_worker* %0, %struct.__cilkrts_worker** %5 release, align 8
  store atomic %struct.__cilkrts_stack_frame* %__cilkrts_sf, %struct.__cilkrts_stack_frame** %2 release, align 8
  %6 = load %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5, align 8
  %7 = bitcast %struct.__cilkrts_stack_frame** %4 to i64*
  %8 = load i64, i64* %7, align 8
  %9 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %6, i64 0, i32 0
  %10 = load atomic %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame*** %9 acquire, align 8
  fence release
  %11 = bitcast %struct.__cilkrts_stack_frame** %10 to i64*
  store volatile i64 %8, i64* %11, align 8
  %12 = getelementptr %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %10, i64 1
  store atomic %struct.__cilkrts_stack_frame** %12, %struct.__cilkrts_stack_frame*** %9 release, align 8
  %13 = load atomic i32, i32* %1 acquire, align 8
  %14 = or i32 %13, 4
  store atomic i32 %14, i32* %1 release, align 8
  tail call void @schur([16 x [16 x double]]* %arrayidx6.otd1, [16 x [16 x double]]* %V.tr132.otd1, [16 x [16 x double]]* %arrayidx38.otd1, i32 %div.otd1) #3
  %15 = load i64, i64* %7, align 8
  %16 = load atomic %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5 acquire, align 8
  %17 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %16, i64 0, i32 7
  %18 = bitcast %struct.__cilkrts_stack_frame** %17 to i64*
  store atomic i64 %15, i64* %18 release, align 8
  store atomic %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %4 release, align 8
  %19 = load atomic i32, i32* %1 acquire, align 8
  %20 = icmp eq i32 %19, 16777216
  br i1 %20, label %__cilk_parent_epilogue.exit, label %body.i

body.i:                                           ; preds = %det.cont.otd1
  call void @__cilkrts_leave_frame(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %det.cont.otd1, %body.i
  ret void
}

; Function Attrs: noinline nounwind
define private fastcc void @schur.outline_det.achd.otd1([16 x [16 x double]]* nocapture align 1 %M.tr130.otd1, [16 x [16 x double]]* nocapture readonly align 1 %V.tr132.otd1, [16 x [16 x double]]* nocapture readonly align 1 %W.tr134.otd1, i32 %div.otd1) unnamed_addr #1 {
if.end.otd1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  %0 = tail call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #3
  %1 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 0
  store atomic i32 16777216, i32* %1 release, align 8
  %2 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %0, i64 0, i32 7
  %3 = load atomic %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %2 acquire, align 8
  %4 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 1
  store atomic %struct.__cilkrts_stack_frame* %3, %struct.__cilkrts_stack_frame** %4 release, align 8
  %5 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 2
  store atomic %struct.__cilkrts_worker* %0, %struct.__cilkrts_worker** %5 release, align 8
  store atomic %struct.__cilkrts_stack_frame* %__cilkrts_sf, %struct.__cilkrts_stack_frame** %2 release, align 8
  %6 = load %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5, align 8
  %7 = bitcast %struct.__cilkrts_stack_frame** %4 to i64*
  %8 = load i64, i64* %7, align 8
  %9 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %6, i64 0, i32 0
  %10 = load atomic %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame*** %9 acquire, align 8
  fence release
  %11 = bitcast %struct.__cilkrts_stack_frame** %10 to i64*
  store volatile i64 %8, i64* %11, align 8
  %12 = getelementptr %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %10, i64 1
  store atomic %struct.__cilkrts_stack_frame** %12, %struct.__cilkrts_stack_frame*** %9 release, align 8
  %13 = load atomic i32, i32* %1 acquire, align 8
  %14 = or i32 %13, 4
  store atomic i32 %14, i32* %1 release, align 8
  tail call void @schur([16 x [16 x double]]* %M.tr130.otd1, [16 x [16 x double]]* %V.tr132.otd1, [16 x [16 x double]]* %W.tr134.otd1, i32 %div.otd1) #3
  %15 = load i64, i64* %7, align 8
  %16 = load atomic %struct.__cilkrts_worker*, %struct.__cilkrts_worker** %5 acquire, align 8
  %17 = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %16, i64 0, i32 7
  %18 = bitcast %struct.__cilkrts_stack_frame** %17 to i64*
  store atomic i64 %15, i64* %18 release, align 8
  store atomic %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %4 release, align 8
  %19 = load atomic i32, i32* %1 acquire, align 8
  %20 = icmp eq i32 %19, 16777216
  br i1 %20, label %__cilk_parent_epilogue.exit, label %body.i

body.i:                                           ; preds = %if.end.otd1
  call void @__cilkrts_leave_frame(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %if.end.otd1, %body.i
  ret void
}

; CHECK: bb.0.entry:
; CHECK: %[[RDXARG:.+]]:gr64 = COPY $rdx
; CHECK: %[[RDIARG:.+]]:gr64 = COPY $rdi

; CHECK: bb.{{.+}}.if.end:
; CHECK: %[[RDXPHI:.+]]:gr64 = PHI %[[RDXARG]]
; CHECK: %[[RDIPHI:.+]]:gr64 = PHI %[[RDIARG]]

; CHECK: %[[IDX1:.+]]:gr64 = ADD64rr %[[RDIPHI]]
; CHECK: %[[IDX2:.+]]:gr64 = ADD64rr %[[RDXPHI]]

; CHECK: EH_SjLj_Setup %bb.{{.+}}, csr_noregs
; CHECK: $rdi = COPY %[[IDX1]]
; CHECK: $rdx = COPY %[[IDX2]]
; CHECK: CALL64pcrel32 @schur.outline_det.achd47.otd1, csr_64, implicit $rsp, implicit $ssp, implicit $rdi, implicit $rsi, implicit $rdx, implicit $ecx, implicit-def $rsp, implicit-def $ssp

; CHECK: EH_SjLj_Setup %bb.{{.+}}, csr_noregs
; CHECK: $rdi = COPY %[[IDX1]]
; CHECK: $rdx = COPY %[[IDX2]]
; CHECK: CALL64pcrel32 @schur, csr_64, implicit $rsp, implicit $ssp, implicit $rdi, implicit $rsi, implicit $rdx, implicit $ecx, implicit-def $rsp, implicit-def $ssp

; CHECK: EH_SjLj_Setup %bb.{{.+}}, csr_noregs
; CHECK: $rdi = COPY %[[IDX1]]
; CHECK: $rdx = COPY %[[IDX2]]
; CHECK: CALL64pcrel32 @schur.outline_det.achd53.otd1, csr_64, implicit $rsp, implicit $ssp, implicit $rdi, implicit $rsi, implicit $rdx, implicit $ecx, implicit-def $rsp, implicit-def $ssp

declare %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() local_unnamed_addr

declare void @__cilkrts_leave_frame(%struct.__cilkrts_stack_frame*) local_unnamed_addr

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress(i32 immarg) #2

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #3

; Function Attrs: nounwind
declare i32 @llvm.eh.sjlj.setjmp(i8*) #3

declare void @__cilkrts_sync(%struct.__cilkrts_stack_frame*) local_unnamed_addr

attributes #0 = { stealable }
attributes #1 = { noinline nounwind }
attributes #2 = { nounwind readnone }
attributes #3 = { nounwind }
attributes #4 = { returns_twice }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
