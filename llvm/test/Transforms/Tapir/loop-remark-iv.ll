; RUN: opt < %s -loop-spawning-ti -pass-remarks-analysis=loop-spawning -disable-output 2>&1 | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -pass-remarks-analysis=loop-spawning-ti -disable-output 2>&1 | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt*, %struct._IO_wide_data*, %struct._IO_FILE*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type opaque
%struct._IO_codecvt = type opaque
%struct._IO_wide_data = type opaque

$_ZN4pbbs17new_array_no_initIjEEPT_mb = comdat any

@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE*, align 8
@.str.40 = private unnamed_addr constant [22 x i8] c"Cannot allocate space\00", align 1

; Function Attrs: uwtable
define linkonce_odr dso_local i32* @_ZN4pbbs17new_array_no_initIjEEPT_mb(i64 %n, i1 zeroext %touch_pages) local_unnamed_addr #0 comdat {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = lshr i64 %n, 4
  %add = shl i64 %0, 6
  %mul1 = add i64 %add, 64
  %call = tail call noalias i8* @aligned_alloc(i64 64, i64 %mul1) #25
  %1 = bitcast i8* %call to i32*
  %cmp = icmp eq i8* %call, null
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %2 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !18
  %3 = tail call i64 @fwrite(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.40, i64 0, i64 0), i64 21, i64 1, %struct._IO_FILE* %2) #26
  tail call void @exit(i32 1) #27
  unreachable

if.end:                                           ; preds = %entry
  br i1 %touch_pages, label %pfor.cond, label %if.end6

pfor.cond:                                        ; preds = %if.end, %pfor.inc
  %i.0 = phi i64 [ %add4, %pfor.inc ], [ 0, %if.end ]
  detach within %syncreg, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %arrayidx = getelementptr inbounds i8, i8* %call, i64 %i.0
  store i8 0, i8* %arrayidx, align 1, !tbaa !41
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %add4 = add i64 %i.0, 2097152
  %cmp5 = icmp ult i64 %add4, %mul1
  br i1 %cmp5, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !171

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  tail call void @llvm.sync.unwind(token %syncreg)
  %4 = bitcast i8* %call to i32*
  ret i32* %4

if.end6:                                          ; preds = %if.end
  ret i32* %1
}

; CHECK: remark:{{.*}}Tapir loop not transformed: canonical loop induction variable could not be identified
; CHECK: warning:{{.*}}Tapir loop not transformed: failed to use divide-and-conquer loop spawning.

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #6

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @aligned_alloc(i64, i64) local_unnamed_addr #10

; Function Attrs: nofree nounwind
declare i64 @fwrite(i8* nocapture, i64, i64, %struct._IO_FILE* nocapture) local_unnamed_addr #3

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) local_unnamed_addr #14

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #12

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #25 = { nounwind }
attributes #26 = { cold }
attributes #27 = { noreturn nounwind }

!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!"bool", !5, i64 0}
!17 = !{!"tapir.loop.spawn.strategy", i32 1}
!18 = !{!19, !19, i64 0}
!19 = !{!"any pointer", !5, i64 0}
!41 = !{!7, !7, i64 0}
!171 = distinct !{!171, !17}
