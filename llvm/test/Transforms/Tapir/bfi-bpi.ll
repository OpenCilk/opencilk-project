; Check branch probabilities and block frequencies around Tapir instructions.
; Specifically, the CFG edge to a detached block should be heavily favored.
;
; RUN: opt < %s -passes="print<block-freq>,print<branch-prob>" -disable-output 2>&1 | FileCheck %s
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: nounwind ssp uwtable(sync)
define void @foo(i32 noundef %n) local_unnamed_addr #0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %syncreg1 = tail call token @llvm.syncregion.start()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %entry
  tail call void @bar() #3
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %entry
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond, label %cleanup

pfor.cond:                                        ; preds = %det.cont, %pfor.inc
  %__begin.0 = phi i32 [ %inc, %pfor.inc ], [ 0, %det.cont ]
  detach within %syncreg1, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  tail call void @bar() #3
  reattach within %syncreg1, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body.entry, %pfor.cond
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond.not = icmp eq i32 %inc, %n
  br i1 %exitcond.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !5

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg1, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %det.cont
  sync within %syncreg, label %sync.continue4

sync.continue4:                                   ; preds = %cleanup
  ret void
}

; CHECK-LABEL: block-frequency-info: foo
; Check that the integral frequencies of detached blocks match those of their parents in the 3 most significant figures.
; CHECK: entry: float = 1.0, int = [[ENTRY_FREQ:[0-9][0-9][0-9]]]{{[0-9]*}}
; CHECK-NEXT: det.achd: float = {{.*}}, int = [[ENTRY_FREQ]]{{[0-9]*}}
; CHECK-NEXT: det.cont: float = 1.0, int = [[ENTRY_FREQ]]{{[0-9]*}}
; CHECK-NEXT: pfor.cond: float = {{.*}}, int = [[PFOR_COND_FREQ:[0-9][0-9][0-9]]]{{[0-9]*}}
; CHECK-NEXT: pfor.body.entry: float = {{.*}}, int = [[PFOR_COND_FREQ]]{{[0-9]*}}
; CHECK-NEXT: pfor.inc: float = {{.*}}, int = [[PFOR_COND_FREQ]]{{[0-9]*}}

; CHECK-LABEL: Branch Probabilities
; CHECK: edge %entry -> %det.achd probability is {{.*}} = 99.99% [HOT edge]
; CHECK: edge %det.achd -> %det.cont probability is {{.*}} = 100.00% [HOT edge]
; CHECK: edge %pfor.cond -> %pfor.body.entry probability is {{.*}} = 99.99% [HOT edge]

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #1

declare void @bar(...) local_unnamed_addr #2

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { mustprogress nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 1}
!4 = !{!"clang version 21.1.3 (git@github.com:OpenCilk/opencilk-project.git 25825e88610ce6e13e15addeb237e6e602d5ec49)"}
!5 = distinct !{!5, !6, !7, !8}
!6 = !{!"llvm.loop.mustprogress"}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
!8 = !{!"llvm.loop.unroll.disable"}
