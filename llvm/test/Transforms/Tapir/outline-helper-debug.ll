; Check that Tapir lowering ensures the call to the outlined helper
; function has debug information.
;
; RUN: opt < %s -passes="tapir-lowering<O0>" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"done\0A\00", align 1, !dbg !0

; Function Attrs: mustprogress noinline norecurse optnone sanitize_address uwtable
define dso_local noundef i32 @main() #0 !dbg !18 {
entry:
  %retval = alloca i32, align 4
  %x = alloca [10 x i32], align 16
  %syncreg = call token @llvm.syncregion.start(), !dbg !23
  %__init = alloca i32, align 4
  %__limit = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %__begin = alloca i32, align 4
  %__end = alloca i32, align 4
  %syncreg6 = call token @llvm.syncregion.start(), !dbg !23
  store i32 0, ptr %retval, align 4
  call void @llvm.lifetime.start.p0(i64 40, ptr %x) #7, !dbg !24
  call void @llvm.dbg.declare(metadata ptr %x, metadata !25, metadata !DIExpression()), !dbg !29
  call void @llvm.memset.p0.i64(ptr align 16 %x, i8 0, i64 40, i1 false), !dbg !29
  call void @llvm.lifetime.start.p0(i64 4, ptr %__init) #7, !dbg !30
  call void @llvm.dbg.declare(metadata ptr %__init, metadata !32, metadata !DIExpression()), !dbg !33
  store i32 0, ptr %__init, align 4, !dbg !30
  call void @llvm.lifetime.start.p0(i64 4, ptr %__limit) #7, !dbg !34
  call void @llvm.dbg.declare(metadata ptr %__limit, metadata !35, metadata !DIExpression()), !dbg !33
  store i32 0, ptr %__limit, align 4, !dbg !34
  %0 = load i32, ptr %__init, align 4, !dbg !30
  %1 = load i32, ptr %__limit, align 4, !dbg !34
  %cmp = icmp slt i32 %0, %1, !dbg !36
  br i1 %cmp, label %pfor.ph, label %pfor.initcond.cleanup, !dbg !34

pfor.initcond.cleanup:                            ; preds = %entry
  store i32 2, ptr %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !34

pfor.ph:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 4, ptr %__begin) #7, !dbg !36
  call void @llvm.dbg.declare(metadata ptr %__begin, metadata !37, metadata !DIExpression()), !dbg !33
  store i32 0, ptr %__begin, align 4, !dbg !36
  call void @llvm.lifetime.start.p0(i64 4, ptr %__end) #7, !dbg !36
  call void @llvm.dbg.declare(metadata ptr %__end, metadata !38, metadata !DIExpression()), !dbg !33
  %2 = load i32, ptr %__limit, align 4, !dbg !34
  %3 = load i32, ptr %__init, align 4, !dbg !30
  %sub = sub nsw i32 %2, %3, !dbg !36
  %sub1 = sub nsw i32 %sub, 1, !dbg !36
  %div = sdiv i32 %sub1, 1, !dbg !36
  %add = add nsw i32 %div, 1, !dbg !36
  store i32 %add, ptr %__end, align 4, !dbg !36
  br label %pfor.cond, !dbg !36

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  br label %pfor.detach, !dbg !39

pfor.detach:                                      ; preds = %pfor.cond
  %4 = load i32, ptr %__init, align 4, !dbg !40
  %5 = load i32, ptr %__begin, align 4, !dbg !42
  %mul = mul nsw i32 %5, 1, !dbg !43
  %add2 = add nsw i32 %4, %mul, !dbg !43
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc, !dbg !39

pfor.body.entry:                                  ; preds = %pfor.detach
  %i = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr %i) #7, !dbg !39
  call void @llvm.dbg.declare(metadata ptr %i, metadata !44, metadata !DIExpression()), !dbg !45
  store i32 %add2, ptr %i, align 4, !dbg !39
  br label %pfor.body, !dbg !39

pfor.body:                                        ; preds = %pfor.body.entry
  %6 = load i32, ptr %i, align 4, !dbg !46
  %idxprom = sext i32 %6 to i64, !dbg !48
  %arrayidx = getelementptr inbounds [10 x i32], ptr %x, i64 0, i64 %idxprom, !dbg !48
  %7 = load i32, ptr %arrayidx, align 4, !dbg !49
  %inc = add nsw i32 %7, 1, !dbg !49
  store i32 %inc, ptr %arrayidx, align 4, !dbg !49
  br label %pfor.preattach, !dbg !50

pfor.preattach:                                   ; preds = %pfor.body
  call void @llvm.lifetime.end.p0(i64 4, ptr %i) #7, !dbg !50
  reattach within %syncreg, label %pfor.inc, !dbg !50

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.detach
  %8 = load i32, ptr %__begin, align 4, !dbg !51
  %inc3 = add nsw i32 %8, 1, !dbg !51
  store i32 %inc3, ptr %__begin, align 4, !dbg !51
  %9 = load i32, ptr %__begin, align 4, !dbg !42
  %10 = load i32, ptr %__end, align 4, !dbg !42
  %cmp4 = icmp slt i32 %9, %10, !dbg !42
  br i1 %cmp4, label %pfor.cond, label %pfor.cond.cleanup, !dbg !52, !llvm.loop !53

pfor.cond.cleanup:                                ; preds = %pfor.inc
  store i32 2, ptr %cleanup.dest.slot, align 4
  sync within %syncreg, label %sync.continue, !dbg !52

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg), !dbg !52
  call void @llvm.lifetime.end.p0(i64 4, ptr %__end) #7, !dbg !52
  call void @llvm.lifetime.end.p0(i64 4, ptr %__begin) #7, !dbg !52
  br label %cleanup

cleanup:                                          ; preds = %sync.continue, %pfor.initcond.cleanup
  call void @llvm.lifetime.end.p0(i64 4, ptr %__limit) #7, !dbg !52
  call void @llvm.lifetime.end.p0(i64 4, ptr %__init) #7, !dbg !52
  br label %pfor.end

; CHECK: sync.continue:
; CHECK: br label %cleanup

; CHECK: cleanup:
; CHECK: call i32 @__cilk_prepare_spawn(
; CHECK-NEXT: icmp eq i32
; CHECK-NEXT: br i1 %{{.+}}, label %[[CLEANUP_SPLIT:.+]], label %det.cont

; CHECK: [[CLEANUP_SPLIT]]:
; CHECK-NEXT: call {{.*}}void @main.outline_pfor.end.otd1(ptr %x), !dbg ![[DBGMD:[0-9]+]]

; CHECK: pfor.end:
; CHECK: detach within %syncreg6, label %det.achd, label %det.cont, !dbg ![[DBGMD]]

pfor.end:                                         ; preds = %cleanup
  %11 = call token @llvm.taskframe.create(), !dbg !56
  detach within %syncreg6, label %det.achd, label %det.cont, !dbg !56

det.achd:                                         ; preds = %pfor.end
  %y = alloca [10 x i32], align 16
  %i7 = alloca i32, align 4
  call void @llvm.taskframe.use(token %11), !dbg !56
  call void @llvm.lifetime.start.p0(i64 40, ptr %y) #7, !dbg !57
  call void @llvm.dbg.declare(metadata ptr %y, metadata !59, metadata !DIExpression()), !dbg !60
  call void @llvm.lifetime.start.p0(i64 4, ptr %i7) #7, !dbg !61
  call void @llvm.dbg.declare(metadata ptr %i7, metadata !63, metadata !DIExpression()), !dbg !64
  store i32 0, ptr %i7, align 4, !dbg !64
  br label %for.cond, !dbg !61

for.cond:                                         ; preds = %for.inc, %det.achd
  %12 = load i32, ptr %i7, align 4, !dbg !65
  %cmp8 = icmp slt i32 %12, 0, !dbg !67
  br i1 %cmp8, label %for.body, label %for.cond.cleanup, !dbg !68

for.cond.cleanup:                                 ; preds = %for.cond
  call void @llvm.lifetime.end.p0(i64 4, ptr %i7) #7, !dbg !69
  br label %for.end

for.body:                                         ; preds = %for.cond
  %13 = load i32, ptr %i7, align 4, !dbg !70
  %idxprom10 = sext i32 %13 to i64, !dbg !71
  %arrayidx11 = getelementptr inbounds [10 x i32], ptr %x, i64 0, i64 %idxprom10, !dbg !71
  %14 = load i32, ptr %arrayidx11, align 4, !dbg !71
  %15 = load i32, ptr %i7, align 4, !dbg !72
  %idxprom12 = sext i32 %15 to i64, !dbg !73
  %arrayidx13 = getelementptr inbounds [10 x i32], ptr %y, i64 0, i64 %idxprom12, !dbg !73
  store i32 %14, ptr %arrayidx13, align 4, !dbg !74
  br label %for.inc, !dbg !73

for.inc:                                          ; preds = %for.body
  %16 = load i32, ptr %i7, align 4, !dbg !75
  %inc14 = add nsw i32 %16, 1, !dbg !75
  store i32 %inc14, ptr %i7, align 4, !dbg !75
  br label %for.cond, !dbg !69, !llvm.loop !76

for.end:                                          ; preds = %for.cond.cleanup
  call void @llvm.lifetime.end.p0(i64 40, ptr %y) #7, !dbg !77
  reattach within %syncreg6, label %det.cont, !dbg !79

det.cont:                                         ; preds = %for.end, %pfor.end
  %call = call i32 (ptr, ...) @printf(ptr noundef @.str), !dbg !80
  store i32 0, ptr %retval, align 4, !dbg !81
  sync within %syncreg6, label %sync.continue16, !dbg !81

sync.continue16:                                  ; preds = %det.cont
  call void @llvm.sync.unwind(token %syncreg6), !dbg !81
  store i32 1, ptr %cleanup.dest.slot, align 4
  sync within %syncreg6, label %sync.continue18, !dbg !82

sync.continue18:                                  ; preds = %sync.continue16
  call void @llvm.sync.unwind(token %syncreg6), !dbg !82
  call void @llvm.lifetime.end.p0(i64 40, ptr %x) #7, !dbg !82
  %17 = load i32, ptr %retval, align 4, !dbg !82
  ret i32 %17, !dbg !82
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #5

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #4

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #4

declare i32 @printf(ptr noundef, ...) #6

attributes #0 = { mustprogress noinline norecurse optnone sanitize_address uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #4 = { nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { willreturn memory(argmem: readwrite) }
attributes #6 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nounwind }

!llvm.dbg.cu = !{!8}
!llvm.module.flags = !{!10, !11, !12, !13, !14, !15, !16}
!llvm.ident = !{!17}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 22, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "issue197.cpp", directory: "/data/compilers/tests/adhoc/wheatman-20230918", checksumkind: CSK_MD5, checksum: "03c71acb3f9c3691222532d01901cd3a")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 48, elements: !6)
!4 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !5)
!5 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!6 = !{!7}
!7 = !DISubrange(count: 6)
!8 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !2, producer: "clang version 16.0.6 (git@github.com:OpenCilk/opencilk-project.git d631c52742bc32d008a8101e6fc002f5085e1274)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !9, splitDebugInlining: false, nameTableKind: None)
!9 = !{!0}
!10 = !{i32 7, !"Dwarf Version", i32 5}
!11 = !{i32 2, !"Debug Info Version", i32 3}
!12 = !{i32 1, !"wchar_size", i32 4}
!13 = !{i32 8, !"PIC Level", i32 2}
!14 = !{i32 7, !"PIE Level", i32 2}
!15 = !{i32 7, !"uwtable", i32 2}
!16 = !{i32 7, !"frame-pointer", i32 2}
!17 = !{!"clang version 16.0.6 (git@github.com:OpenCilk/opencilk-project.git d631c52742bc32d008a8101e6fc002f5085e1274)"}
!18 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 11, type: !19, scopeLine: 11, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !8, retainedNodes: !22)
!19 = !DISubroutineType(types: !20)
!20 = !{!21}
!21 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!22 = !{}
!23 = !DILocation(line: 0, scope: !18)
!24 = !DILocation(line: 13, column: 3, scope: !18)
!25 = !DILocalVariable(name: "x", scope: !18, file: !2, line: 13, type: !26)
!26 = !DICompositeType(tag: DW_TAG_array_type, baseType: !21, size: 320, elements: !27)
!27 = !{!28}
!28 = !DISubrange(count: 10)
!29 = !DILocation(line: 13, column: 7, scope: !18)
!30 = !DILocation(line: 15, column: 20, scope: !31)
!31 = distinct !DILexicalBlock(scope: !18, file: !2, line: 15, column: 3)
!32 = !DILocalVariable(name: "__init", scope: !31, type: !21, flags: DIFlagArtificial)
!33 = !DILocation(line: 0, scope: !31)
!34 = !DILocation(line: 15, column: 27, scope: !31)
!35 = !DILocalVariable(name: "__limit", scope: !31, type: !21, flags: DIFlagArtificial)
!36 = !DILocation(line: 15, column: 25, scope: !31)
!37 = !DILocalVariable(name: "__begin", scope: !31, type: !21, flags: DIFlagArtificial)
!38 = !DILocalVariable(name: "__end", scope: !31, type: !21, flags: DIFlagArtificial)
!39 = !DILocation(line: 15, column: 3, scope: !31)
!40 = !DILocation(line: 15, column: 20, scope: !41)
!41 = distinct !DILexicalBlock(scope: !31, file: !2, line: 15, column: 3)
!42 = !DILocation(line: 15, column: 25, scope: !41)
!43 = !DILocation(line: 15, column: 12, scope: !41)
!44 = !DILocalVariable(name: "i", scope: !41, file: !2, line: 15, type: !21)
!45 = !DILocation(line: 15, column: 16, scope: !41)
!46 = !DILocation(line: 15, column: 39, scope: !47)
!47 = distinct !DILexicalBlock(scope: !41, file: !2, line: 15, column: 35)
!48 = !DILocation(line: 15, column: 37, scope: !47)
!49 = !DILocation(line: 15, column: 41, scope: !47)
!50 = !DILocation(line: 15, column: 45, scope: !47)
!51 = !DILocation(line: 15, column: 31, scope: !41)
!52 = !DILocation(line: 15, column: 3, scope: !41)
!53 = distinct !{!53, !39, !54, !55}
!54 = !DILocation(line: 15, column: 45, scope: !31)
!55 = !{!"tapir.loop.spawn.strategy", i32 1}
!56 = !DILocation(line: 17, column: 3, scope: !18)
!57 = !DILocation(line: 18, column: 5, scope: !58)
!58 = distinct !DILexicalBlock(scope: !18, file: !2, line: 17, column: 14)
!59 = !DILocalVariable(name: "y", scope: !58, file: !2, line: 18, type: !26)
!60 = !DILocation(line: 18, column: 9, scope: !58)
!61 = !DILocation(line: 19, column: 10, scope: !62)
!62 = distinct !DILexicalBlock(scope: !58, file: !2, line: 19, column: 5)
!63 = !DILocalVariable(name: "i", scope: !62, file: !2, line: 19, type: !21)
!64 = !DILocation(line: 19, column: 14, scope: !62)
!65 = !DILocation(line: 19, column: 21, scope: !66)
!66 = distinct !DILexicalBlock(scope: !62, file: !2, line: 19, column: 5)
!67 = !DILocation(line: 19, column: 23, scope: !66)
!68 = !DILocation(line: 19, column: 5, scope: !62)
!69 = !DILocation(line: 19, column: 5, scope: !66)
!70 = !DILocation(line: 20, column: 16, scope: !66)
!71 = !DILocation(line: 20, column: 14, scope: !66)
!72 = !DILocation(line: 20, column: 9, scope: !66)
!73 = !DILocation(line: 20, column: 7, scope: !66)
!74 = !DILocation(line: 20, column: 12, scope: !66)
!75 = !DILocation(line: 19, column: 28, scope: !66)
!76 = distinct !{!76, !68, !77, !78}
!77 = !DILocation(line: 20, column: 17, scope: !62)
!78 = !{!"llvm.loop.mustprogress"}
!79 = !DILocation(line: 21, column: 3, scope: !58)
!80 = !DILocation(line: 22, column: 3, scope: !18)
!81 = !DILocation(line: 23, column: 3, scope: !18)
!82 = !DILocation(line: 24, column: 1, scope: !18)
