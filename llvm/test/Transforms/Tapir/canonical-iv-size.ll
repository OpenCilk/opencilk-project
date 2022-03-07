; Check that LoopSpawning transforms Tapir loops where the canonical
; induction variable does not necessarily have the widest type.
;
; RUN: opt < %s -enable-new-pm=0 -loop-spawning-ti -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S -o - | FileCheck %s

%struct.sphere = type { %struct.vector, %struct.vector, %struct.vector, float, float, %struct.material }
%struct.vector = type { float, float, float }
%struct.material = type { %struct.color, float }
%struct.color = type { float, float, float }

@spheres = dso_local local_unnamed_addr global %struct.sphere* null, align 8
@bodies = dso_local local_unnamed_addr global i32 0, align 4
@G = dso_local local_unnamed_addr global double 0.000000e+00, align 8
@numSpheres = dso_local local_unnamed_addr global i32 0, align 4

; Function Attrs: nofree nounwind ssp uwtable willreturn
declare dso_local i32 @checkForCollision(i32, i32, float, float* nocapture) local_unnamed_addr #0

; Function Attrs: nounwind ssp uwtable
declare dso_local void @doMiniStepWithCollisions(float, i32, i32) local_unnamed_addr #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: nounwind ssp uwtable
define dso_local void @doTimeStep(float %timeStep) local_unnamed_addr #1 {
entry:
  %minCollisionTime = alloca float, align 4
  %indexCollider1 = alloca i32, align 4
  %indexCollider2 = alloca i32, align 4
  %syncreg = tail call token @llvm.syncregion.start()
  %conv111 = fpext float %timeStep to double
  %cmp112 = fcmp ogt double %conv111, 0x3EB0C6F7A0B5ED8D
  br i1 %cmp112, label %while.body.lr.ph, label %while.end

while.body.lr.ph:                                 ; preds = %entry
  %minCollisionTime.0.minCollisionTime.0.minCollisionTime.0..sroa_cast = bitcast float* %minCollisionTime to i8*
  %indexCollider1.0.indexCollider1.0.indexCollider1.0..sroa_cast = bitcast i32* %indexCollider1 to i8*
  %indexCollider2.0.indexCollider2.0.indexCollider2.0..sroa_cast = bitcast i32* %indexCollider2 to i8*
  br label %while.body

while.body:                                       ; preds = %cleanup, %while.body.lr.ph
  %timeLeft.0113 = phi float [ %timeStep, %while.body.lr.ph ], [ %sub35, %cleanup ]
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %minCollisionTime.0.minCollisionTime.0.minCollisionTime.0..sroa_cast)
  store float %timeLeft.0113, float* %minCollisionTime, align 4, !tbaa !10
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %indexCollider1.0.indexCollider1.0.indexCollider1.0..sroa_cast)
  store i32 -1, i32* %indexCollider1, align 4, !tbaa !14
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %indexCollider2.0.indexCollider2.0.indexCollider2.0..sroa_cast)
  store i32 -1, i32* %indexCollider2, align 4, !tbaa !14
  %0 = load i32, i32* @bodies, align 4, !tbaa !14
  %cmp2 = icmp sgt i32 %0, 0
  br i1 %cmp2, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %while.body
  %conv12 = fmul float %timeLeft.0113, 5.000000e-01
  %1 = insertelement <2 x float> poison, float %conv12, i32 0
  %2 = shufflevector <2 x float> %1, <2 x float> undef, <2 x i32> zeroinitializer
  br label %pfor.cond

; CHECK: pfor.cond.preheader:
; CHECK-NOT: br label
; CHECK: %[[GRAINSIZE:.+]] = call i32 @llvm.tapir.loop.grainsize.i32(i32 %0)
; CHECK: call {{.*}}void @doTimeStep.outline_pfor.cond.ls2(
; CHECK: i32 0,
; CHECK: i32 %0,
; CHECK: i32 %[[GRAINSIZE]],
; CHECK-NEXT: br label %pfor.cond.cleanup

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %indvars.iv = phi i64 [ 1, %pfor.cond.preheader ], [ %indvars.iv.next, %pfor.inc ]
  %__begin.0 = phi i32 [ 0, %pfor.cond.preheader ], [ %inc31, %pfor.inc ]
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  %refFrameAdjustedVelMag = alloca float, align 4
  %j.0107 = add nuw nsw i32 %__begin.0, 1
  %3 = load i32, i32* @bodies, align 4, !tbaa !14
  %cmp7108 = icmp slt i32 %j.0107, %3
  br i1 %cmp7108, label %for.body.lr.ph, label %for.cond.cleanup

for.body.lr.ph:                                   ; preds = %pfor.body.entry
  %4 = bitcast float* %refFrameAdjustedVelMag to i8*
  %minCollisionTime.0.minCollisionTime.promoted = load float, float* %minCollisionTime, align 4, !tbaa !10
  %indexCollider1.0.load126 = load i32, i32* %indexCollider1, align 4
  %indexCollider2.0.load124 = load i32, i32* %indexCollider2, align 4
  br label %for.body

for.cond.for.cond.cleanup_crit_edge:              ; preds = %if.end30
  store float %mul24115, float* %minCollisionTime, align 4, !tbaa !10
  store i32 %__begin.0118, i32* %indexCollider1, align 4, !tbaa !14
  store i32 %j.0109120, i32* %indexCollider2, align 4, !tbaa !14
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond.for.cond.cleanup_crit_edge, %pfor.body.entry
  reattach within %syncreg, label %pfor.inc

for.body:                                         ; preds = %if.end30, %for.body.lr.ph
  %indvars.iv121 = phi i64 [ %indvars.iv, %for.body.lr.ph ], [ %indvars.iv.next122, %if.end30 ]
  %j.0109119 = phi i32 [ %indexCollider2.0.load124, %for.body.lr.ph ], [ %j.0109120, %if.end30 ]
  %__begin.0117 = phi i32 [ %indexCollider1.0.load126, %for.body.lr.ph ], [ %__begin.0118, %if.end30 ]
  %mul24116 = phi float [ %minCollisionTime.0.minCollisionTime.promoted, %for.body.lr.ph ], [ %mul24115, %if.end30 ]
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %4) #5
  %5 = trunc i64 %indvars.iv121 to i32
  %call = call i32 @checkForCollision(i32 %__begin.0, i32 %5, float %timeLeft.0113, float* nonnull %refFrameAdjustedVelMag)
  %tobool.not = icmp eq i32 %call, 0
  br i1 %tobool.not, label %if.end30, label %if.then

if.then:                                          ; preds = %for.body
  %6 = load %struct.sphere*, %struct.sphere** @spheres, align 8, !tbaa !16
  %.elt = getelementptr inbounds %struct.sphere, %struct.sphere* %6, i64 %indvars.iv121, i32 2, i32 0
  %.unpack = load float, float* %.elt, align 4
  %7 = getelementptr inbounds %struct.sphere, %struct.sphere* %6, i64 %indvars.iv121, i32 2, i32 1
  %8 = bitcast float* %7 to <2 x float>*
  %9 = load <2 x float>, <2 x float>* %8, align 4
  %mul.i = fmul float %conv12, %.unpack
  %10 = fmul <2 x float> %2, %9
  %.elt91 = getelementptr inbounds %struct.sphere, %struct.sphere* %6, i64 %indvars.iv121, i32 1, i32 0
  %.unpack92 = load float, float* %.elt91, align 4
  %11 = getelementptr inbounds %struct.sphere, %struct.sphere* %6, i64 %indvars.iv121, i32 1, i32 1
  %12 = bitcast float* %11 to <2 x float>*
  %13 = load <2 x float>, <2 x float>* %12, align 4
  %add.i = fadd float %mul.i, %.unpack92
  %14 = fadd <2 x float> %10, %13
  %mul.i100 = fmul float %add.i, %add.i
  %15 = fmul <2 x float> %14, %14
  %16 = extractelement <2 x float> %15, i32 0
  %add.i101 = fadd float %mul.i100, %16
  %17 = extractelement <2 x float> %15, i32 1
  %add6.i = fadd float %17, %add.i101
  %18 = tail call float @llvm.sqrt.f32(float %add6.i) #5
  %mul18 = fmul float %timeLeft.0113, %18
  %19 = load float, float* %refFrameAdjustedVelMag, align 4, !tbaa !10
  %div19 = fdiv float %mul18, %19
  %cmp20 = fcmp ogt float %div19, 1.000000e+00
  %div23 = fdiv float 1.000000e+00, %div19
  %touchTimePct.0 = select i1 %cmp20, float %div23, float %div19
  %mul24 = fmul float %timeLeft.0113, %touchTimePct.0
  %cmp25 = fcmp olt float %mul24, %mul24116
  br i1 %cmp25, label %if.then27, label %if.end30

if.then27:                                        ; preds = %if.then
  br label %if.end30

if.end30:                                         ; preds = %if.then27, %if.then, %for.body
  %j.0109120 = phi i32 [ %j.0109119, %if.then ], [ %5, %if.then27 ], [ %j.0109119, %for.body ]
  %__begin.0118 = phi i32 [ %__begin.0117, %if.then ], [ %__begin.0, %if.then27 ], [ %__begin.0117, %for.body ]
  %mul24115 = phi float [ %mul24116, %if.then ], [ %mul24, %if.then27 ], [ %mul24116, %for.body ]
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %4) #5
  %indvars.iv.next122 = add nuw nsw i64 %indvars.iv121, 1
  %20 = load i32, i32* @bodies, align 4, !tbaa !14
  %21 = trunc i64 %indvars.iv.next122 to i32
  %cmp7 = icmp sgt i32 %20, %21
  br i1 %cmp7, label %for.body, label %for.cond.for.cond.cleanup_crit_edge, !llvm.loop !18

pfor.inc:                                         ; preds = %for.cond.cleanup, %pfor.cond
  %inc31 = add nuw nsw i32 %__begin.0, 1
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i32 %inc31, %0
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !20

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %while.body
  %minCollisionTime.0.minCollisionTime.0.minCollisionTime.0.66 = load float, float* %minCollisionTime, align 4, !tbaa !10
  %indexCollider1.0.load = load i32, i32* %indexCollider1, align 4
  %indexCollider2.0.load = load i32, i32* %indexCollider2, align 4
  tail call void @doMiniStepWithCollisions(float %minCollisionTime.0.minCollisionTime.0.minCollisionTime.0.66, i32 %indexCollider1.0.load, i32 %indexCollider2.0.load)
  %sub35 = fsub float %timeLeft.0113, %minCollisionTime.0.minCollisionTime.0.minCollisionTime.0.66
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %indexCollider2.0.indexCollider2.0.indexCollider2.0..sroa_cast)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %indexCollider1.0.indexCollider1.0.indexCollider1.0..sroa_cast)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %minCollisionTime.0.minCollisionTime.0.minCollisionTime.0..sroa_cast)
  %conv = fpext float %sub35 to double
  %cmp = fcmp ogt double %conv, 0x3EB0C6F7A0B5ED8D
  br i1 %cmp, label %while.body, label %while.end, !llvm.loop !22

while.end:                                        ; preds = %cleanup, %entry
  ret void
}

; Function Attrs: nounwind ssp uwtable
define dso_local void @simulate() local_unnamed_addr #1 {
entry:
  %0 = load i32, i32* @bodies, align 4, !tbaa !14
  %conv = sitofp i32 %0 to double
  %1 = tail call double @llvm.log.f64(double %conv)
  %div = fdiv double 1.000000e+00, %1
  %conv1 = fptrunc double %div to float
  tail call void @doTimeStep(float %conv1)
  ret void
}

; CHECK: define {{.*}}void @doTimeStep.outline_pfor.cond.ls2(
; CHECK: i32 %__begin.0.start.ls2,
; CHECK: i32 %end.ls2,
; CHECK: i32 %grainsize.ls2,

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.log.f64(double) #4

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32(float) #4

attributes #0 = { nofree nounwind ssp uwtable willreturn "disable-tail-calls"="false" "frame-pointer"="non-leaf" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-a12" "target-features"="+aes,+crc,+crypto,+fp-armv8,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+v8.3a,+zcm,+zcz" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind ssp uwtable "disable-tail-calls"="false" "frame-pointer"="non-leaf" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-a12" "target-features"="+aes,+crc,+crypto,+fp-armv8,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+v8.3a,+zcm,+zcz" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nofree nosync nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8}
!llvm.ident = !{!9}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 11, i32 3]}
!1 = !{i32 7, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 1, !"branch-target-enforcement", i32 0}
!5 = !{i32 1, !"sign-return-address", i32 0}
!6 = !{i32 1, !"sign-return-address-all", i32 0}
!7 = !{i32 1, !"sign-return-address-with-bkey", i32 0}
!8 = !{i32 7, !"PIC Level", i32 2}
!9 = !{!"clang version 12.0.0 (git@github.com:neboat/opencilk-project.git 3a0ff175e635307594371d89f42000f94340b615)"}
!10 = !{!11, !11, i64 0}
!11 = !{!"float", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C/C++ TBAA"}
!14 = !{!15, !15, i64 0}
!15 = !{!"int", !12, i64 0}
!16 = !{!17, !17, i64 0}
!17 = !{!"any pointer", !12, i64 0}
!18 = distinct !{!18, !19}
!19 = !{!"llvm.loop.mustprogress"}
!20 = distinct !{!20, !21}
!21 = !{!"tapir.loop.spawn.strategy", i32 1}
!22 = distinct !{!22, !19}
