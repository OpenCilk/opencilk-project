; Check GCov instrumentation in a function with Tapir instructions.
;
; Inject metadata to set the .gcno file location
; RUN: rm -rf %t && mkdir -p %t
; RUN: echo '!5 = !{!"%/t/detach-gcov.ll", !0}' > %t/1
; RUN: cat %s %t/1 > %t/2
;
; RUN: opt -insert-gcov-profiling -S < %t/2 | FileCheck %s
; RUN: opt -passes=insert-gcov-profiling -S < %t/2 | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@__profn_main = private constant [4 x i8] c"main"

; Function Attrs: norecurse uwtable mustprogress
define dso_local i32 @main(i32 %argc, i8** %argv) #0 !dbg !7 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  call void @llvm.instrprof.increment(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__profn_main, i32 0, i32 0), i64 560837720, i32 2, i32 0), !dbg !9
  br i1 true, label %pfor.ph, label %pfor.initcond.cleanup, !dbg !10

pfor.initcond.cleanup:                            ; preds = %entry
  br label %cleanup, !dbg !10

pfor.ph:                                          ; preds = %entry
  br label %pfor.cond, !dbg !11

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  %__begin.0 = phi i32 [ 0, %pfor.ph ], [ %inc, %pfor.inc ], !dbg !12
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc, !dbg !13

; CHECK: pfor.cond:
; CHECK: detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body, !dbg !13

; CHECK: pfor.body.entry:
; CHECK: br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  call void @llvm.instrprof.increment(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__profn_main, i32 0, i32 0), i64 560837720, i32 2, i32 1), !dbg !13
  reattach within %syncreg, label %pfor.inc, !dbg !14

; CHECK: pfor.body:
; CHECK: %[[GCOV_CTR:.+]] = load i64, i64* getelementptr inbounds ([{{[0-9]+}} x i64], [{{[0-9]+}} x i64]* @__llvm_gcov_ctr, i64 {{[0-9]+}}, i64 {{[0-9]+}})
; CHECK: %[[ADD:.+]] = add i64 %[[GCOV_CTR]], 1
; CHECK: store i64 %[[ADD]], i64* getelementptr inbounds ([{{[0-9]+}} x i64], [{{[0-9]+}} x i64]* @__llvm_gcov_ctr, i64 {{[0-9]+}}, i64 {{[0-9]+}})
; CHECK: call void @llvm.instrprof.increment(
; CHECK: reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %inc = add nsw i32 %__begin.0, 1, !dbg !15
  %cmp3 = icmp slt i32 %inc, 100, !dbg !11
  br i1 %cmp3, label %pfor.cond, label %pfor.cond.cleanup, !dbg !13, !llvm.loop !16

; CHECK: pfor.inc:
; CHECK: %inc = add nsw i32 %__begin.0, 1
; CHECK: %cmp3 = icmp slt i32 %inc, 100
; CHECK: br i1 %cmp3, label %pfor.cond, label %pfor.cond.cleanup

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue, !dbg !13

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg), !dbg !13
  br label %cleanup

cleanup:                                          ; preds = %sync.continue, %pfor.initcond.cleanup
  ret i32 0, !dbg !19
}

; Function Attrs: nounwind
declare void @llvm.instrprof.increment(i8*, i64, i32, i32) #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #4

attributes #0 = { norecurse uwtable mustprogress "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nofree nosync nounwind willreturn }
attributes #4 = { argmemonly willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4}
!llvm.gcov = !{!5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 7ae859a161cba12018d3915ef01c11f16bbf1eca)", isOptimized: true, runtimeVersion: 0, emissionKind: NoDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "test.cpp", directory: "/data/compilers/tests/adhoc/wheatman-20220107")
!2 = !{}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 7ae859a161cba12018d3915ef01c11f16bbf1eca)"}
!7 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 3, type: !8, scopeLine: 3, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !2)
!9 = !DILocation(line: 3, column: 34, scope: !7)
!10 = !DILocation(line: 4, column: 27, scope: !7)
!11 = !DILocation(line: 4, column: 25, scope: !7)
!12 = !DILocation(line: 0, scope: !7)
!13 = !DILocation(line: 4, column: 3, scope: !7)
!14 = !DILocation(line: 4, column: 38, scope: !7)
!15 = !DILocation(line: 4, column: 33, scope: !7)
!16 = distinct !{!16, !13, !14, !17, !18}
!17 = !{!"tapir.loop.spawn.strategy", i32 1}
!18 = !{!"llvm.loop.unroll.disable"}
!19 = !DILocation(line: 5, column: 3, scope: !7)
