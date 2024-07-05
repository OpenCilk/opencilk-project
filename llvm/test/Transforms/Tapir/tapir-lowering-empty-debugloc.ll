; Check that Tapir lowering adds debug locations to inlinable function calls even when instrumented instructions don't have debug information to copy.
;
; RUN: opt < %s -passes="tapir2target" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define ptr @_Z12generateNodePP5rangePP5eventS0_ii() personality ptr null !dbg !78 {
entry:
  detach within none, label %det.achd.peel, label %for.body.tf, !dbg !80

det.achd.peel:                                    ; preds = %entry
  reattach within none, label %for.body.tf

for.body.tf:                                      ; preds = %det.achd.peel, %entry
  ret ptr null
}

; CHECK: %[[CILKRTS_SF:.+]] = alloca %struct.__cilkrts_stack_frame, align 8, !dbg !{{[0-9]+}}
; CHECK: call void @__cilkrts_enter_frame(ptr %[[CILKRTS_SF]]), !dbg !{{[0-9]+}}
; CHECK: call i32 @__cilk_prepare_spawn(ptr %[[CILKRTS_SF]]), !dbg !{{[0-9]+}}
; CHECK: call void @__cilk_parent_epilogue(ptr %[[CILKRTS_SF]]), !dbg !{{[0-9]+}}

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 0 }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!77}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_11, file: !1, producer: "clang version 18.1.8 (git@github.com:OpenCilk/opencilk-project.git 2d0cbf4d9385387673a9596a902dbb6c3a96f6a6)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !2, globals: !3, imports: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "kdTree.C", directory: "/home/neboat/cilkbench/pbbs/rayCast/kdTree", checksumkind: CSK_MD5, checksum: "fd3990a30bc256321e308c6e7ff72750")
!2 = !{}
!3 = !{!4, !8, !12, !14, !16, !18, !21, !23, !25, !27, !29, !31, !36, !40, !42, !45, !48, !51, !53, !56, !59, !62, !65, !68, !71, !73}
!4 = !DIGlobalVariableExpression(var: !5, expr: !DIExpression())
!5 = distinct !DIGlobalVariable(name: "_tm", linkageName: "_ZL3_tm", scope: !0, file: !6, line: 89, type: !7, isLocal: true, isDefinition: true)
!6 = !DIFile(filename: "./gettime.h", directory: "/home/neboat/cilkbench/pbbs/rayCast/kdTree", checksumkind: CSK_MD5, checksum: "fb1a35bd4364fabe77847482736052cf")
!7 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timer", file: !6, line: 11, size: 320, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2, identifier: "_ZTS5timer")
!8 = !DIGlobalVariableExpression(var: !9, expr: !DIExpression())
!9 = distinct !DIGlobalVariable(name: "__ii", linkageName: "_ZL4__ii", scope: !0, file: !10, line: 38, type: !11, isLocal: true, isDefinition: true)
!10 = !DIFile(filename: "./utils.h", directory: "/home/neboat/cilkbench/pbbs/rayCast/kdTree", checksumkind: CSK_MD5, checksum: "9def8f7d06ffc5a7267f1ea19daca9d9")
!11 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!12 = !DIGlobalVariableExpression(var: !13, expr: !DIExpression())
!13 = distinct !DIGlobalVariable(name: "__jj", linkageName: "_ZL4__jj", scope: !0, file: !10, line: 39, type: !11, isLocal: true, isDefinition: true)
!14 = !DIGlobalVariableExpression(var: !15, expr: !DIExpression())
!15 = distinct !DIGlobalVariable(name: "CHECK", scope: !0, file: !1, line: 35, type: !11, isLocal: false, isDefinition: true)
!16 = !DIGlobalVariableExpression(var: !17, expr: !DIExpression())
!17 = distinct !DIGlobalVariable(name: "STATS", scope: !0, file: !1, line: 36, type: !11, isLocal: false, isDefinition: true)
!18 = !DIGlobalVariableExpression(var: !19, expr: !DIExpression())
!19 = distinct !DIGlobalVariable(name: "CT", scope: !0, file: !1, line: 39, type: !20, isLocal: false, isDefinition: true)
!20 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!21 = !DIGlobalVariableExpression(var: !22, expr: !DIExpression())
!22 = distinct !DIGlobalVariable(name: "CL", scope: !0, file: !1, line: 40, type: !20, isLocal: false, isDefinition: true)
!23 = !DIGlobalVariableExpression(var: !24, expr: !DIExpression())
!24 = distinct !DIGlobalVariable(name: "maxExpand", scope: !0, file: !1, line: 41, type: !20, isLocal: false, isDefinition: true)
!25 = !DIGlobalVariableExpression(var: !26, expr: !DIExpression())
!26 = distinct !DIGlobalVariable(name: "maxRecursionDepth", scope: !0, file: !1, line: 42, type: !11, isLocal: false, isDefinition: true)
!27 = !DIGlobalVariableExpression(var: !28, expr: !DIExpression())
!28 = distinct !DIGlobalVariable(name: "minParallelSize", scope: !0, file: !1, line: 45, type: !11, isLocal: false, isDefinition: true)
!29 = !DIGlobalVariableExpression(var: !30, expr: !DIExpression())
!30 = distinct !DIGlobalVariable(name: "epsilon", scope: !0, file: !1, line: 59, type: !20, isLocal: false, isDefinition: true)
!31 = !DIGlobalVariableExpression(var: !32, expr: !DIExpression())
!32 = distinct !DIGlobalVariable(scope: null, file: !1, line: 242, type: !33, isLocal: true, isDefinition: true)
!33 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 352, elements: !2)
!34 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !35)
!35 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!36 = !DIGlobalVariableExpression(var: !37, expr: !DIExpression())
!37 = distinct !DIGlobalVariable(name: "tcount", scope: !0, file: !1, line: 258, type: !38, isLocal: false, isDefinition: true)
!38 = !DIDerivedType(tag: DW_TAG_typedef, name: "intT", file: !39, line: 84, baseType: !11)
!39 = !DIFile(filename: "./parallel.h", directory: "/home/neboat/cilkbench/pbbs/rayCast/kdTree", checksumkind: CSK_MD5, checksum: "a65e6e962a15b266f22d15dabda7a41a")
!40 = !DIGlobalVariableExpression(var: !41, expr: !DIExpression())
!41 = distinct !DIGlobalVariable(name: "ccount", scope: !0, file: !1, line: 259, type: !38, isLocal: false, isDefinition: true)
!42 = !DIGlobalVariableExpression(var: !43, expr: !DIExpression())
!43 = distinct !DIGlobalVariable(scope: null, file: !1, line: 372, type: !44, isLocal: true, isDefinition: true)
!44 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 200, elements: !2)
!45 = !DIGlobalVariableExpression(var: !46, expr: !DIExpression())
!46 = distinct !DIGlobalVariable(scope: null, file: !1, line: 378, type: !47, isLocal: true, isDefinition: true)
!47 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 88, elements: !2)
!48 = !DIGlobalVariableExpression(var: !49, expr: !DIExpression())
!49 = distinct !DIGlobalVariable(scope: null, file: !1, line: 381, type: !50, isLocal: true, isDefinition: true)
!50 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 248, elements: !2)
!51 = !DIGlobalVariableExpression(var: !52, expr: !DIExpression())
!52 = distinct !DIGlobalVariable(scope: null, file: !1, line: 382, type: !47, isLocal: true, isDefinition: true)
!53 = !DIGlobalVariableExpression(var: !54, expr: !DIExpression())
!54 = distinct !DIGlobalVariable(scope: null, file: !1, line: 388, type: !55, isLocal: true, isDefinition: true)
!55 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 120, elements: !2)
!56 = !DIGlobalVariableExpression(var: !57, expr: !DIExpression())
!57 = distinct !DIGlobalVariable(scope: null, file: !1, line: 390, type: !58, isLocal: true, isDefinition: true)
!58 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 96, elements: !2)
!59 = !DIGlobalVariableExpression(var: !60, expr: !DIExpression())
!60 = distinct !DIGlobalVariable(scope: null, file: !1, line: 399, type: !61, isLocal: true, isDefinition: true)
!61 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 344, elements: !2)
!62 = !DIGlobalVariableExpression(var: !63, expr: !DIExpression())
!63 = distinct !DIGlobalVariable(scope: null, file: !1, line: 406, type: !64, isLocal: true, isDefinition: true)
!64 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 64, elements: !2)
!65 = !DIGlobalVariableExpression(var: !66, expr: !DIExpression())
!66 = distinct !DIGlobalVariable(scope: null, file: !1, line: 406, type: !67, isLocal: true, isDefinition: true)
!67 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 72, elements: !2)
!68 = !DIGlobalVariableExpression(var: !69, expr: !DIExpression())
!69 = distinct !DIGlobalVariable(scope: null, file: !6, line: 86, type: !70, isLocal: true, isDefinition: true)
!70 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 32, elements: !2)
!71 = !DIGlobalVariableExpression(var: !72, expr: !DIExpression())
!72 = distinct !DIGlobalVariable(scope: null, file: !6, line: 61, type: !58, isLocal: true, isDefinition: true)
!73 = !DIGlobalVariableExpression(var: !74, expr: !DIExpression())
!74 = distinct !DIGlobalVariable(scope: null, file: !75, line: 651, type: !76, isLocal: true, isDefinition: true)
!75 = !DIFile(filename: "/usr/lib/gcc/x86_64-linux-gnu/14/../../../../include/c++/14/bits/basic_string.h", directory: "")
!76 = !DICompositeType(tag: DW_TAG_array_type, baseType: !34, size: 400, elements: !2)
!77 = !{i32 2, !"Debug Info Version", i32 3}
!78 = distinct !DISubprogram(name: "generateNode", linkageName: "_Z12generateNodePP5rangePP5eventS0_ii", scope: !1, file: !1, line: 182, type: !79, scopeLine: 183, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!79 = distinct !DISubroutineType(types: !2)
!80 = !DILocation(line: 192, column: 26, scope: !81)
!81 = distinct !DILexicalBlock(scope: !82, file: !1, line: 191, column: 3)
!82 = distinct !DILexicalBlock(scope: !78, file: !1, line: 191, column: 3)
