; RUN: opt < %s -licm -require-taskinfo-memoryssa -S -o - | FileCheck %s
; RUN: opt < %s -aa-pipeline=basic-aa -passes='require<opt-remark-emit>,loop-mssa(licm)' -S -o - | FileCheck %s

; ModuleID = 'wls.c'
source_filename = "wls.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.__cilkrts_worker = type opaque

@tls_worker = external thread_local local_unnamed_addr global %struct.__cilkrts_worker*, align 8

; Function Attrs: nounwind uwtable
define dso_local i64 @accum_wls(i64 %n) local_unnamed_addr #0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %call = call i32 @__cilkrts_get_nworkers() #3
  %0 = zext i32 %call to i64
  %vla = alloca i64, i64 %0, align 16
  %call152 = call i32 @__cilkrts_get_nworkers() #3
  %cmp53 = icmp eq i32 %call152, 0
  br i1 %cmp53, label %for.cond.cleanup, label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %entry
  %cmp2 = icmp sgt i64 %n, 0
  br i1 %cmp2, label %pfor.cond, label %cleanup

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv55 = phi i64 [ %indvars.iv.next56, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds i64, i64* %vla, i64 %indvars.iv55
  store i64 0, i64* %arrayidx, align 8, !tbaa !2
  %indvars.iv.next56 = add nuw nsw i64 %indvars.iv55, 1
  %call1 = call i32 @__cilkrts_get_nworkers() #3
  %1 = zext i32 %call1 to i64
  %cmp = icmp ult i64 %indvars.iv.next56, %1
  br i1 %cmp, label %for.body, label %for.cond.cleanup

pfor.cond:                                        ; preds = %for.cond.cleanup, %pfor.inc
  %__begin.0 = phi i64 [ %inc9, %pfor.inc ], [ 0, %for.cond.cleanup ]
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

; CHECK: pfor.cond:
; CHECK: detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %2 = load i64*, i64** bitcast (%struct.__cilkrts_worker** @tls_worker to i64**), align 8, !tbaa !6
  %add.ptr = getelementptr inbounds i64, i64* %2, i64 4
  %3 = load i64, i64* %add.ptr, align 8, !tbaa !8
  %sext = shl i64 %3, 32
  %idxprom6 = ashr exact i64 %sext, 32
  %arrayidx7 = getelementptr inbounds i64, i64* %vla, i64 %idxprom6
  %4 = load i64, i64* %arrayidx7, align 8, !tbaa !2
  %add8 = add nsw i64 %4, %__begin.0
  store i64 %add8, i64* %arrayidx7, align 8, !tbaa !2
  reattach within %syncreg, label %pfor.inc

; CHECK: load {{.*}}@tls_worker
; CHECK: reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %inc9 = add nuw nsw i64 %__begin.0, 1
  %exitcond = icmp eq i64 %inc9, %n
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !10

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %for.cond.cleanup
  %call1548 = call i32 @__cilkrts_get_nworkers() #3
  %cmp1649 = icmp eq i32 %call1548, 0
  br i1 %cmp1649, label %for.cond.cleanup18, label %for.body19

for.cond.cleanup18:                               ; preds = %for.body19, %cleanup
  %sum.0.lcssa = phi i64 [ 0, %cleanup ], [ %add22, %for.body19 ]
  ret i64 %sum.0.lcssa

for.body19:                                       ; preds = %cleanup, %for.body19
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body19 ], [ 0, %cleanup ]
  %sum.051 = phi i64 [ %add22, %for.body19 ], [ 0, %cleanup ]
  %arrayidx21 = getelementptr inbounds i64, i64* %vla, i64 %indvars.iv
  %5 = load i64, i64* %arrayidx21, align 8, !tbaa !2
  %add22 = add nsw i64 %5, %sum.051
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %call15 = call i32 @__cilkrts_get_nworkers() #3
  %6 = zext i32 %call15 to i64
  %cmp16 = icmp ult i64 %indvars.iv.next, %6
  br i1 %cmp16, label %for.body19, label %for.cond.cleanup18
}

declare dso_local i32 @__cilkrts_get_nworkers() local_unnamed_addr #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 0708e4f302164111d98a87c07bb12ecf299dca33)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"long long", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"any pointer", !4, i64 0}
!8 = !{!9, !9, i64 0}
!9 = !{!"long", !4, i64 0}
!10 = distinct !{!10, !11}
!11 = !{!"tapir.loop.spawn.strategy", i32 1}
