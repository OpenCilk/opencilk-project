; Verify that static allocas in task entries are handled as such.
;
; RUN: opt < %s -passes=sroa -S | FileCheck %s
source_filename = "delaunay.C"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

module asm ".globl _ZSt21ios_base_library_initv"

%struct.simplex = type <{ ptr, i32, i8, [3 x i8] }>

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #3

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #4

; Function Attrs: mustprogress sanitize_address uwtable
define void @_Z22incrementallyAddPointsPP6vertexiS0_() #5 personality ptr null {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg54 = call token @llvm.syncregion.start()
  %syncreg91 = call token @llvm.syncregion.start()
  %syncreg126 = call token @llvm.syncregion.start()
  sync within %syncreg126, label %sync.continue

sync.continue:                                    ; preds = %entry
  br label %pfor.cond63

pfor.cond63:                                      ; preds = %pfor.inc79, %sync.continue
  detach within %syncreg126, label %pfor.body.entry66, label %pfor.inc79

pfor.body.entry66:                                ; preds = %pfor.cond63
  %t.i = alloca %struct.simplex, align 8
  store ptr null, ptr %t.i, align 8, !DIAssignID !94
  call void @llvm.dbg.assign(metadata ptr null, metadata !95, metadata !DIExpression(DW_OP_LLVM_fragment, 0, 64), metadata !94, metadata ptr %t.i, metadata !DIExpression()), !dbg !99
  br label %for.body12.i

; CHECK: pfor.body.entry66:
; CHECK-NOT: %t.i = alloca
; CHECK-NOT: store ptr null, ptr %t.i,
; CHECK: call void @llvm.dbg.assign(

for.body12.i:                                     ; preds = %for.body12.i, %pfor.body.entry66
  br label %for.body12.i

pfor.inc79:                                       ; preds = %pfor.cond63
  br label %pfor.cond63
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #6

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #0

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.floor.f32(float) #0

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.assign(metadata, metadata, metadata, metadata, metadata, metadata) #0

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.value(metadata, metadata, metadata) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #7

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.experimental.noalias.scope.decl(metadata) #8

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.sqrt.f64(double) #0

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smin.i64(i64, i64) #0

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smax.i64(i64, i64) #0

; uselistorder directives
uselistorder ptr null, { 0, 2, 3, 1 }

attributes #0 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { willreturn memory(argmem: readwrite) }
attributes #5 = { mustprogress sanitize_address uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="alderlake" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-complex,-amx-fp16,-amx-int8,-amx-tile,-avx10.1-256,-avx10.1-512,-avx512bf16,-avx512bitalg,-avx512bw,-avx512cd,-avx512dq,-avx512er,-avx512f,-avx512fp16,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vl,-avx512vnni,-avx512vp2intersect,-avx512vpopcntdq,-avxifma,-avxneconvert,-avxvnni,-avxvnniint16,-avxvnniint8,-cldemote,-clzero,-cmpccxadd,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchi,-prefetchwt1,-ptwrite,-raoint,-rdpru,-rtm,-serialize,-sgx,-sha512,-shstk,-sm3,-sm4,-sse4a,-tbm,-tsxldtrk,-uintr,-usermsr,-waitpkg,-wbnoinvd,-widekl,-xop" }
attributes #6 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #7 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #8 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!93}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_11, file: !1, producer: "clang version 18.1.8 (git@github.com:OpenCilk/opencilk-project.git 2d0cbf4d9385387673a9596a902dbb6c3a96f6a6)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !2, globals: !3, imports: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "delaunay.C", directory: "/home/neboat/cilkbench/pbbs/delaunayTriangulation/incrementalDelaunay", checksumkind: CSK_MD5, checksum: "2ca73d1b68e27a946f3cf66355af38cc")
!2 = !{}
!3 = !{!4, !8, !10, !14, !19, !22, !25, !28, !33, !36, !38, !41, !45, !47, !50, !53, !58, !61, !63, !65, !68, !73, !76, !79, !81, !85, !89}
!4 = !DIGlobalVariableExpression(var: !5, expr: !DIExpression())
!5 = distinct !DIGlobalVariable(name: "__ii", linkageName: "_ZL4__ii", scope: !0, file: !6, line: 38, type: !7, isLocal: true, isDefinition: true)
!6 = !DIFile(filename: "./utils.h", directory: "/home/neboat/cilkbench/pbbs/delaunayTriangulation/incrementalDelaunay", checksumkind: CSK_MD5, checksum: "9def8f7d06ffc5a7267f1ea19daca9d9")
!7 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!8 = !DIGlobalVariableExpression(var: !9, expr: !DIExpression())
!9 = distinct !DIGlobalVariable(name: "__jj", linkageName: "_ZL4__jj", scope: !0, file: !6, line: 39, type: !7, isLocal: true, isDefinition: true)
!10 = !DIGlobalVariableExpression(var: !11, expr: !DIExpression())
!11 = distinct !DIGlobalVariable(name: "_tm", linkageName: "_ZL3_tm", scope: !0, file: !12, line: 89, type: !13, isLocal: true, isDefinition: true)
!12 = !DIFile(filename: "./gettime.h", directory: "/home/neboat/cilkbench/pbbs/delaunayTriangulation/incrementalDelaunay", checksumkind: CSK_MD5, checksum: "fb1a35bd4364fabe77847482736052cf")
!13 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timer", file: !12, line: 11, size: 320, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2, identifier: "_ZTS5timer")
!14 = !DIGlobalVariableExpression(var: !15, expr: !DIExpression())
!15 = distinct !DIGlobalVariable(scope: null, file: !1, line: 134, type: !16, isLocal: true, isDefinition: true)
!16 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 104, elements: !2)
!17 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !18)
!18 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!19 = !DIGlobalVariableExpression(var: !20, expr: !DIExpression())
!20 = distinct !DIGlobalVariable(scope: null, file: !1, line: 136, type: !21, isLocal: true, isDefinition: true)
!21 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 176, elements: !2)
!22 = !DIGlobalVariableExpression(var: !23, expr: !DIExpression())
!23 = distinct !DIGlobalVariable(scope: null, file: !1, line: 143, type: !24, isLocal: true, isDefinition: true)
!24 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 256, elements: !2)
!25 = !DIGlobalVariableExpression(var: !26, expr: !DIExpression())
!26 = distinct !DIGlobalVariable(scope: null, file: !1, line: 144, type: !27, isLocal: true, isDefinition: true)
!27 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 40, elements: !2)
!28 = !DIGlobalVariableExpression(var: !29, expr: !DIExpression())
!29 = distinct !DIGlobalVariable(scope: null, file: !1, line: 217, type: !30, isLocal: true, isDefinition: true)
!30 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 64, elements: !31)
!31 = !{!32}
!32 = !DISubrange(count: 8)
!33 = !DIGlobalVariableExpression(var: !34, expr: !DIExpression())
!34 = distinct !DIGlobalVariable(scope: null, file: !1, line: 319, type: !35, isLocal: true, isDefinition: true)
!35 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 88, elements: !2)
!36 = !DIGlobalVariableExpression(var: !37, expr: !DIExpression())
!37 = distinct !DIGlobalVariable(scope: null, file: !1, line: 323, type: !35, isLocal: true, isDefinition: true)
!38 = !DIGlobalVariableExpression(var: !39, expr: !DIExpression())
!39 = distinct !DIGlobalVariable(scope: null, file: !1, line: 348, type: !40, isLocal: true, isDefinition: true)
!40 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 128, elements: !2)
!41 = !DIGlobalVariableExpression(var: !42, expr: !DIExpression())
!42 = distinct !DIGlobalVariable(scope: null, file: !43, line: 58, type: !44, isLocal: true, isDefinition: true)
!43 = !DIFile(filename: "./topology.h", directory: "/home/neboat/cilkbench/pbbs/delaunayTriangulation/incrementalDelaunay", checksumkind: CSK_MD5, checksum: "b5bb25069afeb2b6dd48e5877714bae0")
!44 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 368, elements: !2)
!45 = !DIGlobalVariableExpression(var: !46, expr: !DIExpression())
!46 = distinct !DIGlobalVariable(scope: null, file: !43, line: 64, type: !40, isLocal: true, isDefinition: true)
!47 = !DIGlobalVariableExpression(var: !48, expr: !DIExpression())
!48 = distinct !DIGlobalVariable(scope: null, file: !43, line: 108, type: !49, isLocal: true, isDefinition: true)
!49 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 80, elements: !2)
!50 = !DIGlobalVariableExpression(var: !51, expr: !DIExpression())
!51 = distinct !DIGlobalVariable(scope: null, file: !43, line: 110, type: !52, isLocal: true, isDefinition: true)
!52 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 48, elements: !2)
!53 = !DIGlobalVariableExpression(var: !54, expr: !DIExpression())
!54 = distinct !DIGlobalVariable(scope: null, file: !43, line: 113, type: !55, isLocal: true, isDefinition: true)
!55 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 24, elements: !56)
!56 = !{!57}
!57 = !DISubrange(count: 3)
!58 = !DIGlobalVariableExpression(var: !59, expr: !DIExpression())
!59 = distinct !DIGlobalVariable(scope: null, file: !43, line: 114, type: !60, isLocal: true, isDefinition: true)
!60 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 16, elements: !2)
!61 = !DIGlobalVariableExpression(var: !62, expr: !DIExpression())
!62 = distinct !DIGlobalVariable(scope: null, file: !43, line: 115, type: !55, isLocal: true, isDefinition: true)
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(scope: null, file: !43, line: 116, type: !52, isLocal: true, isDefinition: true)
!65 = !DIGlobalVariableExpression(var: !66, expr: !DIExpression())
!66 = distinct !DIGlobalVariable(scope: null, file: !43, line: 216, type: !67, isLocal: true, isDefinition: true)
!67 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 240, elements: !2)
!68 = !DIGlobalVariableExpression(var: !69, expr: !DIExpression())
!69 = distinct !DIGlobalVariable(scope: null, file: !12, line: 86, type: !70, isLocal: true, isDefinition: true)
!70 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 32, elements: !71)
!71 = !{!72}
!72 = !DISubrange(count: 4)
!73 = !DIGlobalVariableExpression(var: !74, expr: !DIExpression())
!74 = distinct !DIGlobalVariable(scope: null, file: !12, line: 61, type: !75, isLocal: true, isDefinition: true)
!75 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 96, elements: !2)
!76 = !DIGlobalVariableExpression(var: !77, expr: !DIExpression())
!77 = distinct !DIGlobalVariable(scope: null, file: !78, line: 147, type: !55, isLocal: true, isDefinition: true)
!78 = !DIFile(filename: "./geometry.h", directory: "/home/neboat/cilkbench/pbbs/delaunayTriangulation/incrementalDelaunay", checksumkind: CSK_MD5, checksum: "1706b6ef457c0af43a6dac32d9407cee")
!79 = !DIGlobalVariableExpression(var: !80, expr: !DIExpression())
!80 = distinct !DIGlobalVariable(scope: null, file: !78, line: 147, type: !55, isLocal: true, isDefinition: true)
!81 = !DIGlobalVariableExpression(var: !82, expr: !DIExpression())
!82 = distinct !DIGlobalVariable(scope: null, file: !83, line: 259, type: !84, isLocal: true, isDefinition: true)
!83 = !DIFile(filename: "./octTree.h", directory: "/home/neboat/cilkbench/pbbs/delaunayTriangulation/incrementalDelaunay", checksumkind: CSK_MD5, checksum: "3a50486373e915388dcef0b995664c18")
!84 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 144, elements: !2)
!85 = !DIGlobalVariableExpression(var: !86, expr: !DIExpression())
!86 = distinct !DIGlobalVariable(scope: null, file: !87, line: 651, type: !88, isLocal: true, isDefinition: true)
!87 = !DIFile(filename: "/usr/lib/gcc/x86_64-linux-gnu/14/../../../../include/c++/14/bits/basic_string.h", directory: "")
!88 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 400, elements: !2)
!89 = !DIGlobalVariableExpression(var: !90, expr: !DIExpression())
!90 = distinct !DIGlobalVariable(scope: null, file: !91, line: 67, type: !92, isLocal: true, isDefinition: true)
!91 = !DIFile(filename: "./nearestNeighbors.h", directory: "/home/neboat/cilkbench/pbbs/delaunayTriangulation/incrementalDelaunay", checksumkind: CSK_MD5, checksum: "34ff059f552a2ef48b8502d182d4af47")
!92 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 152, elements: !2)
!93 = !{i32 2, !"Debug Info Version", i32 3}
!94 = distinct !DIAssignID()
!95 = !DILocalVariable(name: "t", arg: 2, scope: !96, file: !1, line: 98, type: !98)
!96 = distinct !DISubprogram(name: "insert", linkageName: "_Z6insertP6vertex7simplexP2Qs", scope: !1, file: !1, line: 98, type: !97, scopeLine: 98, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!97 = distinct !DISubroutineType(types: !2)
!98 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "simplex", file: !43, line: 91, size: 128, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2, identifier: "_ZTS7simplex")
!99 = !DILocation(line: 0, scope: !96, inlinedAt: !100)
!100 = distinct !DILocation(line: 240, column: 18, scope: !101)
!101 = distinct !DILexicalBlock(scope: !102, file: !1, line: 239, column: 45)
!102 = distinct !DILexicalBlock(scope: !103, file: !1, line: 239, column: 5)
!103 = distinct !DILexicalBlock(scope: !104, file: !1, line: 239, column: 5)
!104 = distinct !DILexicalBlock(scope: !105, file: !1, line: 212, column: 18)
!105 = distinct !DISubprogram(name: "incrementallyAddPoints", linkageName: "_Z22incrementallyAddPointsPP6vertexiS0_", scope: !1, file: !1, line: 192, type: !106, scopeLine: 192, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!106 = distinct !DISubroutineType(types: !107)
!107 = !{null}
