; Check that CFG passes are properly invalidated by the serial Tapir
; target, which performs a custom lowering of Tapir instructions
; that does not use outlining.
;
; RUN: opt < %s -passes="default<O1>,tapir2target,sroa" -tapir-target=serial -S | FileCheck %s

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

; Function Attrs: nounwind ssp uwtable
define void @daxpy(double* noundef %y, double* noundef %x, double noundef %a, i32 noundef %n) #0 {
entry:
  %y.addr = alloca double*, align 8
  %x.addr = alloca double*, align 8
  %a.addr = alloca double, align 8
  %n.addr = alloca i32, align 4
  %syncreg = call token @llvm.syncregion.start()
  %__init = alloca i32, align 4
  %__limit = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %__begin = alloca i32, align 4
  %__end = alloca i32, align 4
  store double* %y, double** %y.addr, align 8, !tbaa !9
  store double* %x, double** %x.addr, align 8, !tbaa !9
  store double %a, double* %a.addr, align 8, !tbaa !13
  store i32 %n, i32* %n.addr, align 4, !tbaa !15
  %0 = bitcast i32* %__init to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #4
  store i32 0, i32* %__init, align 4, !tbaa !15
  %1 = bitcast i32* %__limit to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #4
  %2 = load i32, i32* %n.addr, align 4, !tbaa !15
  store i32 %2, i32* %__limit, align 4, !tbaa !15
  %3 = load i32, i32* %__init, align 4, !tbaa !15
  %4 = load i32, i32* %__limit, align 4, !tbaa !15
  %cmp = icmp slt i32 %3, %4
  br i1 %cmp, label %pfor.ph, label %pfor.initcond.cleanup

pfor.initcond.cleanup:                            ; preds = %entry
  store i32 2, i32* %cleanup.dest.slot, align 4
  br label %cleanup

pfor.ph:                                          ; preds = %entry
  %5 = bitcast i32* %__begin to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %5) #4
  store i32 0, i32* %__begin, align 4, !tbaa !15
  %6 = bitcast i32* %__end to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %6) #4
  %7 = load i32, i32* %__limit, align 4, !tbaa !15
  %8 = load i32, i32* %__init, align 4, !tbaa !15
  %sub = sub nsw i32 %7, %8
  %sub1 = sub nsw i32 %sub, 1
  %div = sdiv i32 %sub1, 1
  %add = add nsw i32 %div, 1
  store i32 %add, i32* %__end, align 4, !tbaa !15
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  br label %pfor.detach

pfor.detach:                                      ; preds = %pfor.cond
  %9 = load i32, i32* %__init, align 4, !tbaa !15
  %10 = load i32, i32* %__begin, align 4, !tbaa !15
  %mul = mul nsw i32 %10, 1
  %add2 = add nsw i32 %9, %mul
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.detach
  %i = alloca i32, align 4
  %11 = bitcast i32* %i to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %11) #4
  store i32 %add2, i32* %i, align 4, !tbaa !15
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %12 = load double, double* %a.addr, align 8, !tbaa !13
  %13 = load double*, double** %x.addr, align 8, !tbaa !9
  %14 = load i32, i32* %i, align 4, !tbaa !15
  %idxprom = sext i32 %14 to i64
  %arrayidx = getelementptr inbounds double, double* %13, i64 %idxprom
  %15 = load double, double* %arrayidx, align 8, !tbaa !13
  %16 = load double*, double** %y.addr, align 8, !tbaa !9
  %17 = load i32, i32* %i, align 4, !tbaa !15
  %idxprom4 = sext i32 %17 to i64
  %arrayidx5 = getelementptr inbounds double, double* %16, i64 %idxprom4
  %18 = load double, double* %arrayidx5, align 8, !tbaa !13
  %19 = call double @llvm.fmuladd.f64(double %12, double %15, double %18)
  store double %19, double* %arrayidx5, align 8, !tbaa !13
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %pfor.body
  %20 = bitcast i32* %i to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %20) #4
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.detach
  %21 = load i32, i32* %__begin, align 4, !tbaa !15
  %inc = add nsw i32 %21, 1
  store i32 %inc, i32* %__begin, align 4, !tbaa !15
  %22 = load i32, i32* %__begin, align 4, !tbaa !15
  %23 = load i32, i32* %__end, align 4, !tbaa !15
  %cmp6 = icmp slt i32 %22, %23
  br i1 %cmp6, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !17

pfor.cond.cleanup:                                ; preds = %pfor.inc
  store i32 2, i32* %cleanup.dest.slot, align 4
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  %24 = bitcast i32* %__end to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %24) #4
  %25 = bitcast i32* %__begin to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %25) #4
  br label %cleanup

cleanup:                                          ; preds = %sync.continue, %pfor.initcond.cleanup
  %26 = bitcast i32* %__limit to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %26) #4
  %27 = bitcast i32* %__init to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %27) #4
  br label %pfor.end

pfor.end:                                         ; preds = %cleanup
  ret void
}

; CHECK: define {{.*}}void @daxpy(
; CHECK-NOT: detach within
; CHECK-NOT: reattach within
; CHECK-NOT: sync within
; CHECK: ret void

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fmuladd.f64(double, double, double) #3

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

attributes #0 = { nounwind ssp uwtable "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+v8.5a,+zcm,+zcz" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nofree nosync nounwind willreturn }
attributes #3 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7}
!llvm.ident = !{!8}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"branch-target-enforcement", i32 0}
!2 = !{i32 1, !"sign-return-address", i32 0}
!3 = !{i32 1, !"sign-return-address-all", i32 0}
!4 = !{i32 1, !"sign-return-address-with-bkey", i32 0}
!5 = !{i32 7, !"PIC Level", i32 2}
!6 = !{i32 7, !"uwtable", i32 1}
!7 = !{i32 7, !"frame-pointer", i32 1}
!8 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git 79dfacb371a8dd28146628ae581983255a8d6428)"}
!9 = !{!10, !10, i64 0}
!10 = !{!"any pointer", !11, i64 0}
!11 = !{!"omnipotent char", !12, i64 0}
!12 = !{!"Simple C/C++ TBAA"}
!13 = !{!14, !14, i64 0}
!14 = !{!"double", !11, i64 0}
!15 = !{!16, !16, i64 0}
!16 = !{!"int", !11, i64 0}
!17 = distinct !{!17, !18, !19}
!18 = !{!"tapir.loop.spawn.strategy", i32 1}
!19 = !{!"llvm.loop.unroll.disable"}
