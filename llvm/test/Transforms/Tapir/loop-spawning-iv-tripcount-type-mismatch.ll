; Check that the loop-spawning pass properly handles Tapir loops where
; the primary IV and trip count do not have the same type.
;
; RUN: opt < %s -loop-spawning-ti -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init.0.1.2.3.5.6.8.9.10.15.18.23" = type { i8 }

@_ZStL8__ioinit = external dso_local global %"class.std::ios_base::Init.0.1.2.3.5.6.8.9.10.15.18.23", align 1
@__dso_handle = external hidden global i8
@naa = external dso_local local_unnamed_addr global i32, align 4
@nzz = external dso_local local_unnamed_addr global i32, align 4
@firstrow = external dso_local local_unnamed_addr global i32, align 4
@lastrow = external dso_local local_unnamed_addr global i32, align 4
@firstcol = external dso_local local_unnamed_addr global i32, align 4
@lastcol = external dso_local local_unnamed_addr global i32, align 4
@colidx = external dso_local local_unnamed_addr global i32*, align 8
@rowstr = external dso_local local_unnamed_addr global i32*, align 8
@iv = external dso_local local_unnamed_addr global i32*, align 8
@arow = external dso_local local_unnamed_addr global i32*, align 8
@acol = external dso_local local_unnamed_addr global i32*, align 8
@v = external dso_local local_unnamed_addr global double*, align 8
@aelt = external dso_local local_unnamed_addr global double*, align 8
@a = external dso_local local_unnamed_addr global double*, align 8
@x = external dso_local local_unnamed_addr global double*, align 8
@z = external dso_local local_unnamed_addr global double*, align 8
@p = external dso_local local_unnamed_addr global double*, align 8
@q = external dso_local local_unnamed_addr global double*, align 8
@r = external dso_local local_unnamed_addr global double*, align 8
@w = external dso_local local_unnamed_addr global double*, align 8
@amult = external dso_local local_unnamed_addr global double, align 8
@tran = external dso_local global double, align 8
@num_workers = external dso_local local_unnamed_addr global i32, align 4
@.str.2 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.3 = external dso_local unnamed_addr constant [18 x i8], align 1
@__const.main.pattern_array = external dso_local unnamed_addr constant [4 x i32], align 16
@.str.4 = external dso_local unnamed_addr constant [25 x i8], align 1
@.str.6 = external dso_local unnamed_addr constant [30 x i8], align 1
@.str.9 = external dso_local unnamed_addr constant [21 x i8], align 1
@.str.10 = external dso_local unnamed_addr constant [21 x i8], align 1
@.str.12 = external dso_local unnamed_addr constant [30 x i8], align 1
@.str.13 = external dso_local unnamed_addr constant [30 x i8], align 1
@.str.16 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.17 = external dso_local unnamed_addr constant [25 x i8], align 1
@.str.18 = external dso_local unnamed_addr constant [4 x i8], align 1
@.str.19 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.20 = external dso_local unnamed_addr constant [47 x i8], align 1
@.str.21 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.22 = external dso_local unnamed_addr constant [47 x i8], align 1
@.str.23 = external dso_local unnamed_addr constant [47 x i8], align 1
@.str.24 = external dso_local unnamed_addr constant [7 x i8], align 1
@.str.25 = external dso_local unnamed_addr constant [7 x i8], align 1
@.str.27 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.28 = external dso_local unnamed_addr constant [13 x i8], align 1
@llvm.global_ctors = external global [1 x { i32, void ()*, i8* }]
@str = external dso_local unnamed_addr constant [59 x i8], align 1
@str.29 = external dso_local unnamed_addr constant [98 x i8], align 1
@str.30 = external dso_local unnamed_addr constant [21 x i8], align 1
@str.31 = external dso_local unnamed_addr constant [21 x i8], align 1
@str.32 = external dso_local unnamed_addr constant [25 x i8], align 1
@str.33 = external dso_local unnamed_addr constant [50 x i8], align 1
@str.35 = external dso_local unnamed_addr constant [44 x i8], align 1

declare dso_local void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init.0.1.2.3.5.6.8.9.10.15.18.23"*) unnamed_addr #0

declare dso_local void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init.0.1.2.3.5.6.8.9.10.15.18.23"*) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local i32 @__cxa_atexit(void (i8*)*, i8*, i8*) local_unnamed_addr #1

declare dso_local void @_Z10initializePdS_S_S_S_mm(double*, double*, double*, double*, double*, i64, i64) local_unnamed_addr #0

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

declare dso_local void @_Z14map_mul_scalarPdS_dmm(double*, double*, double, i64, i64) local_unnamed_addr #0

declare dso_local void @_Z11map_add_mulPdS_S_dmm(double*, double*, double*, double, i64, i64) local_unnamed_addr #0

declare dso_local double @_Z14reduce_add_muldPdS_mm(double, double*, double*, i64, i64) local_unnamed_addr #0

declare dso_local i32 @main(i32, i8**) local_unnamed_addr #0

declare dso_local i32 @printf(i8*, ...) local_unnamed_addr #0

declare dso_local double @_Z6randlcPdd(double*, double) local_unnamed_addr #0

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #3

declare dso_local i32 @__cilkrts_get_nworkers() local_unnamed_addr #0

declare dso_local i8* @calloc(i64, i64) local_unnamed_addr #0

declare dso_local i8* @_Z24pattern_bind_memory_numaiiPi(i32, i32, i32*) local_unnamed_addr #0

declare dso_local void @free(i8*) local_unnamed_addr #0

define internal fastcc void @_ZL9conj_gradPiS_PdS0_S0_S0_S0_S0_S0_S0_(i32* %colidx, i32* %rowstr, double* %x, double* %z, double* %a, double* %p, double* %q, double* %r, double* %w, double* %rnorm) unnamed_addr #0 {
entry:
  %_ZZL9conj_gradPiS_PdS0_S0_S0_S0_S0_S0_S0_E3sum = alloca double, align 8
  store double 0.000000e+00, double* %_ZZL9conj_gradPiS_PdS0_S0_S0_S0_S0_S0_S0_E3sum, align 8
  %syncreg143 = tail call token @llvm.syncregion.start()
  %0 = load i32, i32* @naa, align 4, !tbaa !4
  %cmp.i = icmp sgt i32 %0, -1
  %1 = add nuw i32 %0, 1
  %wide.trip.count.i = zext i32 %1 to i64
  %2 = add nsw i64 %wide.trip.count.i, -1
  %xtraiter406 = and i64 %wide.trip.count.i, 2047
  %3 = icmp ult i64 %2, 2047
  %lcmp.mod412 = icmp eq i64 %xtraiter406, 0
  sync within %syncreg143, label %_Z10initializePdS_S_S_S_mm.exit

_Z10initializePdS_S_S_S_mm.exit:                  ; preds = %entry
  %4 = load i32, i32* @lastcol, align 4, !tbaa !4
  %5 = load i32, i32* @firstcol, align 4, !tbaa !4
  %sub = sub nsw i32 %4, %5
  %add1 = add nsw i32 %sub, 2
  %conv2 = sext i32 %add1 to i64
  %call = tail call double @_Z14reduce_add_muldPdS_mm(double 0.000000e+00, double* %x, double* %x, i64 1, i64 %conv2)
  %6 = load i32, i32* @lastrow, align 4, !tbaa !4
  %7 = load i32, i32* @firstrow, align 4, !tbaa !4
  %sub3 = sub nsw i32 %6, %7
  %cmp5 = icmp ult i32 %sub3, -2
  %cmp.i310 = icmp sgt i32 %sub, -1
  %8 = add i32 %sub, 1
  %wide.trip.count.i312 = zext i32 %8 to i64
  %9 = add i32 %6, 1
  %10 = sub i32 %9, %7
  %11 = add nsw i64 %wide.trip.count.i312, -1
  %xtraiter385 = and i64 %wide.trip.count.i312, 2047
  %12 = icmp ult i64 %11, 2047
  %stripiter388420 = lshr i32 %8, 11
  %stripiter388.zext = zext i32 %stripiter388420 to i64
  %lcmp.mod391 = icmp ne i64 %xtraiter385, 0
  %13 = shl nuw nsw i64 %stripiter388.zext, 11
  %14 = or i64 %13, 1
  %scevgep = getelementptr double, double* %p, i64 %14
  %15 = or i64 %13, %xtraiter385
  %16 = add nuw nsw i64 %15, 1
  %scevgep423 = getelementptr double, double* %p, i64 %16
  %scevgep425 = getelementptr double, double* %r, i64 %14
  %scevgep427 = getelementptr double, double* %r, i64 %16
  %scevgep495 = getelementptr double, double* %q, i64 %14
  %scevgep497 = getelementptr double, double* %q, i64 %16
  %scevgep579 = getelementptr double, double* %z, i64 %14
  %scevgep581 = getelementptr double, double* %z, i64 %16
  %min.iters.check577 = icmp ult i64 %xtraiter385, 4
  %bound0587 = icmp ult double* %scevgep579, %scevgep423
  %bound1588 = icmp ult double* %scevgep, %scevgep581
  %found.conflict589 = and i1 %bound0587, %bound1588
  %n.mod.vf593 = and i64 %wide.trip.count.i312, 3
  %n.vec594 = sub nsw i64 %xtraiter385, %n.mod.vf593
  %ind.end598 = add nsw i64 %13, %n.vec594
  %cmp.n601 = icmp eq i64 %n.mod.vf593, 0
  %min.iters.check489 = icmp ult i64 %xtraiter385, 4
  %bound0499 = icmp ult double* %scevgep425, %scevgep497
  %bound1500 = icmp ult double* %scevgep495, %scevgep427
  %found.conflict501 = and i1 %bound0499, %bound1500
  %n.mod.vf505 = and i64 %wide.trip.count.i312, 3
  %n.vec506 = sub nsw i64 %xtraiter385, %n.mod.vf505
  %ind.end510 = add nsw i64 %13, %n.vec506
  %cmp.n513 = icmp eq i64 %n.mod.vf505, 0
  %min.iters.check = icmp ult i64 %xtraiter385, 4
  %bound0 = icmp ult double* %scevgep, %scevgep427
  %bound1 = icmp ult double* %scevgep425, %scevgep423
  %found.conflict = and i1 %bound0, %bound1
  %n.mod.vf = and i64 %wide.trip.count.i312, 3
  %n.vec = sub nsw i64 %xtraiter385, %n.mod.vf
  %ind.end = add nsw i64 %13, %n.vec
  %cmp.n = icmp eq i64 %n.mod.vf, 0
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %_Z10initializePdS_S_S_S_mm.exit
  %indvars.iv376 = phi i64 [ %indvars.iv.next377, %pfor.inc ], [ 0, %_Z10initializePdS_S_S_S_mm.exit ]
  %indvars.iv.next377 = add nuw nsw i64 %indvars.iv376, 1
  detach within %syncreg143, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %arrayidx = getelementptr inbounds i32, i32* %rowstr, i64 %indvars.iv.next377
  %17 = load i32, i32* %arrayidx, align 4, !tbaa !4
  %add12 = add nuw nsw i64 %indvars.iv376, 2
  %idxprom13 = and i64 %add12, 4294967295
  %arrayidx14 = getelementptr inbounds i32, i32* %rowstr, i64 %idxprom13
  %18 = load i32, i32* %arrayidx14, align 4, !tbaa !4
  %cmp15358 = icmp slt i32 %17, %18
  reattach within %syncreg143, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.cond, %pfor.body
  %lftr.wideiv418 = trunc i64 %indvars.iv.next377 to i32
  %exitcond419 = icmp eq i32 %10, %lftr.wideiv418
  br i1 %exitcond419, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !8

pfor.cond.cleanup:                                ; preds = %pfor.inc
  unreachable
}

; CHECK-LABEL: define private fastcc void @_ZL9conj_gradPiS_PdS0_S0_S0_S0_S0_S0_S0_.outline_pfor.cond.ls1(i64 %indvars.iv376.start.ls1,
; CHECK: i32 %[[END:.+]], i32 %[[GRAINSIZE:.+]],

; CHECK: _Z10initializePdS_S_S_S_mm.exit.ls1:
; CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()

; CHECK: _Z10initializePdS_S_S_S_mm.exit.ls1.split:
; CHECK-NEXT: %[[DACIV:.+]] = phi i64 [ %indvars.iv376.start.ls1, %_Z10initializePdS_S_S_S_mm.exit.ls1 ], [ %[[DACIVINC:.+]], %.split.split ]
; CHECK: %[[DACIVSTART:.+]] = trunc i64 %[[DACIV]] to i32
; CHECK: %[[ITERCOUNT:.+]] = sub i32 %[[END]], %[[DACIVSTART]]
; CHECK: %[[CMP:.+]] = icmp ugt i32 %[[ITERCOUNT]], %[[GRAINSIZE]]
; CHECK: br i1 %[[CMP]], label %[[SPAWNBR:.+]], label %[[EXIT:.+]]

; CHECK: [[SPAWNBR]]:
; CHECK: %[[HALFCOUNT:.+]] = lshr i32 %[[ITERCOUNT]], 1
; CHECK: %[[MIDITER:.+]] = add {{.*}}i32 %[[DACIVSTART]], %[[HALFCOUNT]]
; CHECK: detach within %[[SYNCREG]], label %[[SPAWN:.+]], label %[[CONTIN:.+]]

; CHECK: [[SPAWN]]:
; CHECK: call {{.*}}void @_ZL9conj_gradPiS_PdS0_S0_S0_S0_S0_S0_S0_.outline_pfor.cond.ls1(i64 %[[DACIV]], i32 %[[MIDITER]], i32 %[[GRAINSIZE]],
; CHECK: reattach within %[[SYNCREG]], label %[[CONTIN]]

; CHECK: [[CONTIN]]:
; CHECK: %[[DACIVINC]] = zext i32 %[[MIDITER]] to i64
; CHECK: br label %_Z10initializePdS_S_S_S_mm.exit.ls1.split

declare dso_local double @sqrt(double) local_unnamed_addr #0

declare dso_local void @_Z11timer_cleari(i32) local_unnamed_addr #0

declare dso_local void @_Z11timer_starti(i32) local_unnamed_addr #0

declare dso_local void @_Z10timer_stopi(i32) local_unnamed_addr #0

declare dso_local double @_Z10timer_readi(i32) local_unnamed_addr #0

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #2

declare dso_local void @_Z15c_print_resultsPcciiiiddS_iS_S_S_S_S_S_S_S_S_(i8*, i8, i32, i32, i32, i32, double, double, i8*, i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*) local_unnamed_addr #0

declare dso_local i32 @__cilkrts_get_worker_number() local_unnamed_addr #0

declare dso_local double @pow(double, double) local_unnamed_addr #0

declare dso_local void @exit(i32) local_unnamed_addr #0

declare dso_local void @_GLOBAL__sub_I_cg_53c84c.cpp() #0 section ".text.startup"

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

; Function Attrs: nounwind
declare i32 @puts(i8*) local_unnamed_addr #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

attributes #0 = { "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { argmemonly nounwind willreturn }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 7, !"Dwarf Version", i32 4}
!1 = !{i32 2, !"Debug Info Version", i32 3}
!2 = !{i32 1, !"wchar_size", i32 4}
!3 = !{!"clang version 10.0.1 (git@github.com:neboat/opencilk-project.git 2c7e581b441a9ae5682f02090613d00aaa26460d)"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
!8 = distinct !{!8, !9}
!9 = !{!"tapir.loop.spawn.strategy", i32 1}
