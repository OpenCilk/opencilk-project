; RUN: opt < %s -loop-stripmine -disable-output -pass-remarks-analysis=loop-stripmine 2>&1 | FileCheck %s
; RUN: opt < %s -passes='loop-stripmine' -disable-output -pass-remarks-analysis=loop-stripmine 2>&1 | FileCheck %s
; RUN: opt < %s -loop-spawning-ti -disable-output -pass-remarks-analysis=loop-spawning 2>&1 | FileCheck %s --check-prefixes=CHECK,CHECK-LS
; RUN: opt < %s -passes='loop-spawning' -disable-output -pass-remarks-analysis=loop-spawning 2>&1 | FileCheck %s --check-prefixes=CHECK,CHECK-LS

; ModuleID = 'loop-analysis.c'
source_filename = "loop-analysis.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: norecurse nounwind readnone uwtable
define dso_local i64 @racy_accum(i64 %n) local_unnamed_addr #0 !dbg !7 {
entry:
  %accum = alloca i64, align 8
  %syncreg = tail call token @llvm.syncregion.start()
  %accum.0.accum.0..sroa_cast = bitcast i64* %accum to i8*, !dbg !9
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %accum.0.accum.0..sroa_cast), !dbg !9
  store i64 0, i64* %accum, align 8, !dbg !10, !tbaa !11
  br label %pfor.cond, !dbg !15

pfor.cond:                                        ; preds = %pfor.inc, %entry
  %__begin.0 = phi i64 [ 0, %entry ], [ %inc, %pfor.inc ], !dbg !16
  detach within %syncreg, label %pfor.body, label %pfor.inc, !dbg !17

pfor.body:                                        ; preds = %pfor.cond
  %accum.0.load18 = load i64, i64* %accum, align 8, !dbg !18
  %add1 = add i64 %accum.0.load18, %__begin.0, !dbg !18
  store i64 %add1, i64* %accum, align 8, !dbg !18, !tbaa !11
  reattach within %syncreg, label %pfor.inc, !dbg !19

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %inc = add i64 %__begin.0, 1, !dbg !20
  %cmp2 = icmp ugt i64 %inc, %n, !dbg !15
  br i1 %cmp2, label %pfor.cond.cleanup, label %pfor.cond, !dbg !17, !llvm.loop !21

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup, !dbg !17

cleanup:                                          ; preds = %pfor.cond.cleanup
  %accum.0.load19 = load i64, i64* %accum, align 8, !dbg !23
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %accum.0.accum.0..sroa_cast), !dbg !24
  ret i64 %accum.0.load19, !dbg !25
}

; CHECK: remark:{{.*}}Tapir loop not transformed: could not compute finite loop trip count.
; CHECK-LS: warning:{{.*}}Tapir loop not transformed: failed to use divide-and-conquer loop spawning.

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { norecurse nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git 82fd5fe9995f87bf65578a1ecd0e098a2770913f)", isOptimized: true, runtimeVersion: 0, emissionKind: LineTablesOnly, enums: !2, nameTableKind: None)
!1 = !DIFile(filename: "loop-analysis.c", directory: "")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git 82fd5fe9995f87bf65578a1ecd0e098a2770913f)"}
!7 = distinct !DISubprogram(name: "racy_accum", scope: !1, file: !1, line: 2, type: !8, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !2)
!9 = !DILocation(line: 3, column: 3, scope: !7)
!10 = !DILocation(line: 3, column: 17, scope: !7)
!11 = !{!12, !12, i64 0}
!12 = !{!"long", !13, i64 0}
!13 = !{!"omnipotent char", !14, i64 0}
!14 = !{!"Simple C/C++ TBAA"}
!15 = !DILocation(line: 4, column: 37, scope: !7)
!16 = !DILocation(line: 0, scope: !7)
!17 = !DILocation(line: 4, column: 3, scope: !7)
!18 = !DILocation(line: 5, column: 11, scope: !7)
!19 = !DILocation(line: 6, column: 3, scope: !7)
!20 = !DILocation(line: 4, column: 43, scope: !7)
!21 = distinct !{!21, !17, !19, !22}
!22 = !{!"tapir.loop.spawn.strategy", i32 1}
!23 = !DILocation(line: 7, column: 10, scope: !7)
!24 = !DILocation(line: 8, column: 1, scope: !7)
!25 = !DILocation(line: 7, column: 3, scope: !7)
