; Check that the Intel Cilk Plus function __cilkrts_get_nworkers()
; is properly declared in the IR.
;
; RUN: opt < %s -passes="tapir2target" -tapir-target=cilk -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: nounwind ssp uwtable(sync)
define void @normalize(ptr noalias nocapture noundef writeonly %out, ptr noalias noundef %in, i32 noundef %n) local_unnamed_addr #0 {
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %entry
  %wide.trip.count = zext nneg i32 %n to i64
  %0 = call i64 @llvm.tapir.loop.grainsize.i64(i64 %wide.trip.count)
  call fastcc void @normalize.outline_pfor.cond.ls1(i64 0, i64 %wide.trip.count, i64 %0, ptr %in, ptr %out, i32 %n) #4
  br label %cleanup

cleanup:                                          ; preds = %pfor.cond.preheader, %entry
  ret void
}

; CHECK: define {{.*}}void @normalize(
; CHECK: call i32 @__cilkrts_get_nworkers()
; CHECK: call {{.*}}void @normalize.outline_pfor.cond.ls1(

; CHECK: declare i32 @__cilkrts_get_nworkers()

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #1

declare double @norm(ptr noundef, i32 noundef) local_unnamed_addr #2

; Function Attrs: nounwind speculatable willreturn memory(none)
declare i64 @llvm.tapir.loop.grainsize.i64(i64) #3

; Function Attrs: nounwind ssp uwtable(sync)
define internal fastcc void @normalize.outline_pfor.cond.ls1(i64 %indvars.iv.start.ls1, i64 %end.ls1, i64 %grainsize.ls1, ptr noalias noundef align 1 %in.ls1, ptr noalias nocapture noundef writeonly align 1 %out.ls1, i32 noundef %n.ls1) unnamed_addr #0 {
pfor.cond.preheader.ls1:
  %0 = tail call token @llvm.syncregion.start()
  %itercount1 = sub i64 %end.ls1, %indvars.iv.start.ls1
  %1 = icmp ugt i64 %itercount1, %grainsize.ls1
  br i1 %1, label %.lr.ph, label %pfor.cond.ls1.preheader

pfor.cond.ls1.preheader:                          ; preds = %pfor.cond.preheader.ls1.dac.cont, %pfor.cond.preheader.ls1
  %indvars.iv.ls1.dac.lcssa = phi i64 [ %indvars.iv.start.ls1, %pfor.cond.preheader.ls1 ], [ %miditer, %pfor.cond.preheader.ls1.dac.cont ]
  br label %pfor.cond.ls1

.lr.ph:                                           ; preds = %pfor.cond.preheader.ls1, %pfor.cond.preheader.ls1.dac.cont
  %itercount3 = phi i64 [ %itercount, %pfor.cond.preheader.ls1.dac.cont ], [ %itercount1, %pfor.cond.preheader.ls1 ]
  %indvars.iv.ls1.dac2 = phi i64 [ %miditer, %pfor.cond.preheader.ls1.dac.cont ], [ %indvars.iv.start.ls1, %pfor.cond.preheader.ls1 ]
  %halfcount = lshr i64 %itercount3, 1
  %miditer = add nuw nsw i64 %halfcount, %indvars.iv.ls1.dac2
  detach within %0, label %pfor.cond.preheader.ls1.dac.detach, label %pfor.cond.preheader.ls1.dac.cont

pfor.cond.preheader.ls1.dac.detach:               ; preds = %.lr.ph
  call fastcc void @normalize.outline_pfor.cond.ls1(i64 %indvars.iv.ls1.dac2, i64 %miditer, i64 %grainsize.ls1, ptr %in.ls1, ptr %out.ls1, i32 %n.ls1) #4
  reattach within %0, label %pfor.cond.preheader.ls1.dac.cont

pfor.cond.preheader.ls1.dac.cont:                 ; preds = %pfor.cond.preheader.ls1.dac.detach, %.lr.ph
  %itercount = sub i64 %end.ls1, %miditer
  %2 = icmp ugt i64 %itercount, %grainsize.ls1
  br i1 %2, label %.lr.ph, label %pfor.cond.ls1.preheader

pfor.cond.ls1:                                    ; preds = %pfor.cond.ls1.preheader, %pfor.cond.ls1
  %indvars.iv.ls1 = phi i64 [ %indvars.iv.next.ls1, %pfor.cond.ls1 ], [ %indvars.iv.ls1.dac.lcssa, %pfor.cond.ls1.preheader ]
  %indvars.iv.next.ls1 = add nuw nsw i64 %indvars.iv.ls1, 1
  %arrayidx.ls1 = getelementptr inbounds double, ptr %in.ls1, i64 %indvars.iv.ls1
  %3 = load double, ptr %arrayidx.ls1, align 8, !tbaa !6
  %call.ls1 = tail call double @norm(ptr noundef %in.ls1, i32 noundef %n.ls1) #4
  %div.ls1 = fdiv double %3, %call.ls1
  %arrayidx2.ls1 = getelementptr inbounds double, ptr %out.ls1, i64 %indvars.iv.ls1
  store double %div.ls1, ptr %arrayidx2.ls1, align 8, !tbaa !6
  %exitcond.not.ls1 = icmp eq i64 %indvars.iv.next.ls1, %end.ls1
  br i1 %exitcond.not.ls1, label %pfor.cond.cleanup.ls1, label %pfor.cond.ls1, !llvm.loop !10

pfor.cond.cleanup.ls1:                            ; preds = %pfor.cond.ls1
  sync within %0, label %pfor.cond.cleanup.ls1.synced

pfor.cond.cleanup.ls1.synced:                     ; preds = %pfor.cond.cleanup.ls1
  ret void
}

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+complxnum,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+jsconv,+lse,+neon,+pauth,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+complxnum,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+jsconv,+lse,+neon,+pauth,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #3 = { nounwind speculatable willreturn memory(none) }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"clang version 18.1.8 (git@github.com:OpenCilk/opencilk-project.git f78505e37b91651d57f439f34cbcb441c98b59a1)"}
!6 = !{!7, !7, i64 0}
!7 = !{!"double", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = distinct !{!10, !11}
!11 = !{!"tapir.loop.spawn.strategy", i32 0}
