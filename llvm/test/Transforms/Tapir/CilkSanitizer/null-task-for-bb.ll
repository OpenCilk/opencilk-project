; Check that Cilksan properly handles unreachable blocks with Tapir
; intrinsics.
;
; RUN: opt < %s -enable-new-pm=0 -csan -S | FileCheck %s
; RUN: opt < %s -passes='cilksan' -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.cos.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.log.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.sqrt.f64(double) #1

; Function Attrs: nounwind uwtable sanitize_cilk
define dso_local void @particleFilter(i32* nocapture readonly %I, i32 %IszX, i32 %IszY, i32 %Nfr, i32* nocapture %seed, i32 %Nparticles) local_unnamed_addr #2 {
pfor.cond142.strpm.detachloop.entry:
  %syncreg603.strpm.detachloop = call token @llvm.syncregion.start()
  %0 = fdiv fast double 1.000000e+00, undef
  ret void

pfor.body197:                                     ; No predecessors!
  %syncreg198 = call token @llvm.syncregion.start()
  call void @llvm.dbg.value(metadata i64 undef, metadata !18, metadata !DIExpression()), !dbg !215
  call void @llvm.dbg.value(metadata i32 0, metadata !216, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 undef, metadata !220, metadata !DIExpression()), !dbg !219
  ret void
}

; CHECK: define {{.*}}void @particleFilter(
; CHECK: pfor.cond142.strpm.detachloop.entry:
; CHECK: ret void

; CHECK: pfor.body197:
; CHECK-NOT: call void @__csan
; CHECK: ret void

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #0

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.exp.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i32 @llvm.abs.i32(i32, i1 immarg) #1

; Function Attrs: nofree nosync nounwind readnone willreturn
declare double @llvm.vector.reduce.fadd.v2f64(double, <2 x double>) #4

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x double> @llvm.exp.v2f64(<2 x double>) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x i32> @llvm.abs.v2i32(<2 x i32>, i1 immarg) #1

attributes #0 = { argmemonly nofree nosync nounwind willreturn }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind uwtable sanitize_cilk "denormal-fp-math"="preserve-sign,preserve-sign" "denormal-fp-math-f32"="ieee,ieee" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { nofree nosync nounwind readnone willreturn }

!llvm.dbg.cu = !{!0}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 27f44805274426f41b3e5a0ba3b15e9afc0b5d34)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, globals: !10, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "ex_particle_Cilk_seq.c", directory: "/data/compilers/tests/rodinia_3.1/cilk/particlefilter")
!2 = !{}
!3 = !{!4, !5, !6, !7, !8, !9}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!5 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!6 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!7 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !6, size: 64)
!9 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !7, size: 64)
!10 = !{!11, !14, !16}
!11 = !DIGlobalVariableExpression(var: !12, expr: !DIExpression())
!12 = distinct !DIGlobalVariable(name: "M", scope: !0, file: !1, line: 20, type: !13, isLocal: false, isDefinition: true)
!13 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!14 = !DIGlobalVariableExpression(var: !15, expr: !DIExpression())
!15 = distinct !DIGlobalVariable(name: "A", scope: !0, file: !1, line: 24, type: !6, isLocal: false, isDefinition: true)
!16 = !DIGlobalVariableExpression(var: !17, expr: !DIExpression())
!17 = distinct !DIGlobalVariable(name: "C", scope: !0, file: !1, line: 28, type: !6, isLocal: false, isDefinition: true)
!18 = !DILocalVariable(name: "x", scope: !19, file: !1, line: 420, type: !6)
!19 = distinct !DILexicalBlock(scope: !20, file: !1, line: 420, column: 3)
!20 = distinct !DILexicalBlock(scope: !21, file: !1, line: 420, column: 3)
!21 = distinct !DILexicalBlock(scope: !22, file: !1, line: 406, column: 26)
!22 = distinct !DILexicalBlock(scope: !23, file: !1, line: 406, column: 2)
!23 = distinct !DILexicalBlock(scope: !24, file: !1, line: 406, column: 2)
!24 = distinct !DISubprogram(name: "particleFilter", scope: !1, file: !1, line: 347, type: !25, scopeLine: 347, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !27)
!25 = !DISubroutineType(types: !26)
!26 = !{null, !8, !6, !6, !6, !8, !6}
!27 = !{!28, !29, !30, !31, !32, !33, !34, !35, !37, !38, !39, !88, !89, !90, !91, !92, !93, !94, !95, !96, !97, !98, !99, !101, !102, !103, !104, !106, !107, !108, !109, !110, !111, !112, !113, !114, !115, !117, !118, !119, !120, !122, !123, !124, !125, !129, !131, !132, !133, !134, !136, !137, !139, !140, !141, !142, !144, !147, !148, !149, !150, !152, !154, !155, !157, !158, !160, !161, !162, !163, !165, !166, !168, !169, !170, !171, !173, !174, !175, !177, !178, !179, !180, !182, !183, !185, !186, !187, !188, !190, !191, !192, !193, !194, !196, !197, !198, !199, !201, !202, !203, !204, !206, !207, !208, !209, !211, !213, !214}
!28 = !DILocalVariable(name: "I", arg: 1, scope: !24, file: !1, line: 347, type: !8)
!29 = !DILocalVariable(name: "IszX", arg: 2, scope: !24, file: !1, line: 347, type: !6)
!30 = !DILocalVariable(name: "IszY", arg: 3, scope: !24, file: !1, line: 347, type: !6)
!31 = !DILocalVariable(name: "Nfr", arg: 4, scope: !24, file: !1, line: 347, type: !6)
!32 = !DILocalVariable(name: "seed", arg: 5, scope: !24, file: !1, line: 347, type: !8)
!33 = !DILocalVariable(name: "Nparticles", arg: 6, scope: !24, file: !1, line: 347, type: !6)
!34 = !DILocalVariable(name: "max_size", scope: !24, file: !1, line: 349, type: !6)
!35 = !DILocalVariable(name: "start", scope: !24, file: !1, line: 350, type: !36)
!36 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!37 = !DILocalVariable(name: "xe", scope: !24, file: !1, line: 352, type: !7)
!38 = !DILocalVariable(name: "ye", scope: !24, file: !1, line: 353, type: !7)
!39 = !DILocalVariable(name: "xe_r", scope: !24, file: !1, line: 354, type: !40)
!40 = !DIDerivedType(tag: DW_TAG_typedef, name: "cilk_c_reducer_opadd_double", file: !41, line: 689, baseType: !42)
!41 = !DIFile(filename: "animals/opencilk/build-test4/lib/clang/12.0.0/include/cilk/reducer_opadd.h", directory: "/data")
!42 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !41, line: 689, size: 1024, elements: !43)
!43 = !{!44, !87}
!44 = !DIDerivedType(tag: DW_TAG_member, name: "__cilkrts_hyperbase", scope: !42, file: !41, line: 689, baseType: !45, size: 448)
!45 = !DIDerivedType(tag: DW_TAG_typedef, name: "__cilkrts_hyperobject_base", file: !46, line: 37, baseType: !47)
!46 = !DIFile(filename: "animals/opencilk/build-test4/lib/clang/12.0.0/include/cilk/hyperobject_base.h", directory: "/data")
!47 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "__cilkrts_hyperobject_base", file: !46, line: 32, size: 448, elements: !48)
!48 = !{!49, !79, !85, !86}
!49 = !DIDerivedType(tag: DW_TAG_member, name: "__c_monoid", scope: !47, file: !46, line: 33, baseType: !50, size: 320)
!50 = !DIDerivedType(tag: DW_TAG_typedef, name: "cilk_c_monoid", file: !46, line: 29, baseType: !51)
!51 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "cilk_c_monoid", file: !46, line: 23, size: 320, elements: !52)
!52 = !{!53, !58, !63, !65, !74}
!53 = !DIDerivedType(tag: DW_TAG_member, name: "reduce_fn", scope: !51, file: !46, line: 24, baseType: !54, size: 64)
!54 = !DIDerivedType(tag: DW_TAG_typedef, name: "cilk_reduce_fn_t", file: !46, line: 16, baseType: !55)
!55 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !56, size: 64)
!56 = !DISubroutineType(types: !57)
!57 = !{null, !4, !4, !4}
!58 = !DIDerivedType(tag: DW_TAG_member, name: "identity_fn", scope: !51, file: !46, line: 25, baseType: !59, size: 64, offset: 64)
!59 = !DIDerivedType(tag: DW_TAG_typedef, name: "cilk_identity_fn_t", file: !46, line: 17, baseType: !60)
!60 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !61, size: 64)
!61 = !DISubroutineType(types: !62)
!62 = !{null, !4, !4}
!63 = !DIDerivedType(tag: DW_TAG_member, name: "destroy_fn", scope: !51, file: !46, line: 26, baseType: !64, size: 64, offset: 128)
!64 = !DIDerivedType(tag: DW_TAG_typedef, name: "cilk_destroy_fn_t", file: !46, line: 18, baseType: !60)
!65 = !DIDerivedType(tag: DW_TAG_member, name: "allocate_fn", scope: !51, file: !46, line: 27, baseType: !66, size: 64, offset: 192)
!66 = !DIDerivedType(tag: DW_TAG_typedef, name: "cilk_allocate_fn_t", file: !46, line: 19, baseType: !67)
!67 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !68, size: 64)
!68 = !DISubroutineType(types: !69)
!69 = !{!4, !70, !71}
!70 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !47, size: 64)
!71 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !72, line: 46, baseType: !73)
!72 = !DIFile(filename: "animals/opencilk/build-test4/lib/clang/12.0.0/include/stddef.h", directory: "/data")
!73 = !DIBasicType(name: "long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!74 = !DIDerivedType(tag: DW_TAG_member, name: "deallocate_fn", scope: !51, file: !46, line: 28, baseType: !75, size: 64, offset: 256)
!75 = !DIDerivedType(tag: DW_TAG_typedef, name: "cilk_deallocate_fn_t", file: !46, line: 20, baseType: !76)
!76 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !77, size: 64)
!77 = !DISubroutineType(types: !78)
!78 = !{null, !70, !4}
!79 = !DIDerivedType(tag: DW_TAG_member, name: "__id_num", scope: !47, file: !46, line: 34, baseType: !80, size: 32, offset: 320)
!80 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !81, line: 26, baseType: !82)
!81 = !DIFile(filename: "/usr/include/bits/stdint-uintn.h", directory: "")
!82 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !83, line: 42, baseType: !84)
!83 = !DIFile(filename: "/usr/include/bits/types.h", directory: "")
!84 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!85 = !DIDerivedType(tag: DW_TAG_member, name: "__view_offset", scope: !47, file: !46, line: 35, baseType: !80, size: 32, offset: 352)
!86 = !DIDerivedType(tag: DW_TAG_member, name: "__view_size", scope: !47, file: !46, line: 36, baseType: !71, size: 64, offset: 384)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !42, file: !41, line: 689, baseType: !7, size: 64, align: 512, offset: 512)
!88 = !DILocalVariable(name: "ye_r", scope: !24, file: !1, line: 356, type: !40)
!89 = !DILocalVariable(name: "sumWeights_r", scope: !24, file: !1, line: 359, type: !40)
!90 = !DILocalVariable(name: "radius", scope: !24, file: !1, line: 363, type: !6)
!91 = !DILocalVariable(name: "diameter", scope: !24, file: !1, line: 364, type: !6)
!92 = !DILocalVariable(name: "disk", scope: !24, file: !1, line: 365, type: !8)
!93 = !DILocalVariable(name: "countOnes", scope: !24, file: !1, line: 367, type: !6)
!94 = !DILocalVariable(name: "x", scope: !24, file: !1, line: 368, type: !6)
!95 = !DILocalVariable(name: "y", scope: !24, file: !1, line: 368, type: !6)
!96 = !DILocalVariable(name: "objxy", scope: !24, file: !1, line: 375, type: !9)
!97 = !DILocalVariable(name: "get_neighbors", scope: !24, file: !1, line: 378, type: !36)
!98 = !DILocalVariable(name: "weights", scope: !24, file: !1, line: 381, type: !9)
!99 = !DILocalVariable(name: "__init", scope: !100, type: !6, flags: DIFlagArtificial)
!100 = distinct !DILexicalBlock(scope: !24, file: !1, line: 383, column: 2)
!101 = !DILocalVariable(name: "__limit", scope: !100, type: !6, flags: DIFlagArtificial)
!102 = !DILocalVariable(name: "__begin", scope: !100, type: !6, flags: DIFlagArtificial)
!103 = !DILocalVariable(name: "__end", scope: !100, type: !6, flags: DIFlagArtificial)
!104 = !DILocalVariable(name: "x", scope: !105, file: !1, line: 383, type: !6)
!105 = distinct !DILexicalBlock(scope: !100, file: !1, line: 383, column: 2)
!106 = !DILocalVariable(name: "get_weights", scope: !24, file: !1, line: 386, type: !36)
!107 = !DILocalVariable(name: "likelihood", scope: !24, file: !1, line: 389, type: !9)
!108 = !DILocalVariable(name: "arrayX", scope: !24, file: !1, line: 390, type: !9)
!109 = !DILocalVariable(name: "arrayY", scope: !24, file: !1, line: 391, type: !9)
!110 = !DILocalVariable(name: "xj", scope: !24, file: !1, line: 392, type: !9)
!111 = !DILocalVariable(name: "yj", scope: !24, file: !1, line: 393, type: !9)
!112 = !DILocalVariable(name: "CDF", scope: !24, file: !1, line: 394, type: !9)
!113 = !DILocalVariable(name: "u", scope: !24, file: !1, line: 395, type: !9)
!114 = !DILocalVariable(name: "ind", scope: !24, file: !1, line: 396, type: !8)
!115 = !DILocalVariable(name: "__init", scope: !116, type: !6, flags: DIFlagArtificial)
!116 = distinct !DILexicalBlock(scope: !24, file: !1, line: 398, column: 2)
!117 = !DILocalVariable(name: "__limit", scope: !116, type: !6, flags: DIFlagArtificial)
!118 = !DILocalVariable(name: "__begin", scope: !116, type: !6, flags: DIFlagArtificial)
!119 = !DILocalVariable(name: "__end", scope: !116, type: !6, flags: DIFlagArtificial)
!120 = !DILocalVariable(name: "x", scope: !121, file: !1, line: 398, type: !6)
!121 = distinct !DILexicalBlock(scope: !116, file: !1, line: 398, column: 2)
!122 = !DILocalVariable(name: "k", scope: !24, file: !1, line: 402, type: !6)
!123 = !DILocalVariable(name: "indX", scope: !24, file: !1, line: 405, type: !6)
!124 = !DILocalVariable(name: "indY", scope: !24, file: !1, line: 405, type: !6)
!125 = !DILocalVariable(name: "set_arrays", scope: !126, file: !1, line: 407, type: !36)
!126 = distinct !DILexicalBlock(scope: !127, file: !1, line: 406, column: 26)
!127 = distinct !DILexicalBlock(scope: !128, file: !1, line: 406, column: 2)
!128 = distinct !DILexicalBlock(scope: !24, file: !1, line: 406, column: 2)
!129 = !DILocalVariable(name: "__init", scope: !130, type: !6, flags: DIFlagArtificial)
!130 = distinct !DILexicalBlock(scope: !126, file: !1, line: 412, column: 3)
!131 = !DILocalVariable(name: "__limit", scope: !130, type: !6, flags: DIFlagArtificial)
!132 = !DILocalVariable(name: "__begin", scope: !130, type: !6, flags: DIFlagArtificial)
!133 = !DILocalVariable(name: "__end", scope: !130, type: !6, flags: DIFlagArtificial)
!134 = !DILocalVariable(name: "x", scope: !135, file: !1, line: 412, type: !6)
!135 = distinct !DILexicalBlock(scope: !130, file: !1, line: 412, column: 3)
!136 = !DILocalVariable(name: "error", scope: !126, file: !1, line: 416, type: !36)
!137 = !DILocalVariable(name: "__init", scope: !138, type: !6, flags: DIFlagArtificial)
!138 = distinct !DILexicalBlock(scope: !126, file: !1, line: 420, column: 3)
!139 = !DILocalVariable(name: "__limit", scope: !138, type: !6, flags: DIFlagArtificial)
!140 = !DILocalVariable(name: "__begin", scope: !138, type: !6, flags: DIFlagArtificial)
!141 = !DILocalVariable(name: "__end", scope: !138, type: !6, flags: DIFlagArtificial)
!142 = !DILocalVariable(name: "x", scope: !143, file: !1, line: 420, type: !6)
!143 = distinct !DILexicalBlock(scope: !138, file: !1, line: 420, column: 3)
!144 = !DILocalVariable(name: "__init", scope: !145, type: !6, flags: DIFlagArtificial)
!145 = distinct !DILexicalBlock(scope: !146, file: !1, line: 426, column: 4)
!146 = distinct !DILexicalBlock(scope: !143, file: !1, line: 420, column: 43)
!147 = !DILocalVariable(name: "__limit", scope: !145, type: !6, flags: DIFlagArtificial)
!148 = !DILocalVariable(name: "__begin", scope: !145, type: !6, flags: DIFlagArtificial)
!149 = !DILocalVariable(name: "__end", scope: !145, type: !6, flags: DIFlagArtificial)
!150 = !DILocalVariable(name: "y", scope: !151, file: !1, line: 426, type: !6)
!151 = distinct !DILexicalBlock(scope: !145, file: !1, line: 426, column: 4)
!152 = !DILocalVariable(name: "indX", scope: !153, file: !1, line: 427, type: !6)
!153 = distinct !DILexicalBlock(scope: !151, file: !1, line: 426, column: 43)
!154 = !DILocalVariable(name: "indY", scope: !153, file: !1, line: 428, type: !6)
!155 = !DILocalVariable(name: "y", scope: !156, file: !1, line: 434, type: !6)
!156 = distinct !DILexicalBlock(scope: !146, file: !1, line: 434, column: 4)
!157 = !DILocalVariable(name: "likelihood_time", scope: !126, file: !1, line: 438, type: !36)
!158 = !DILocalVariable(name: "__init", scope: !159, type: !6, flags: DIFlagArtificial)
!159 = distinct !DILexicalBlock(scope: !126, file: !1, line: 443, column: 3)
!160 = !DILocalVariable(name: "__limit", scope: !159, type: !6, flags: DIFlagArtificial)
!161 = !DILocalVariable(name: "__begin", scope: !159, type: !6, flags: DIFlagArtificial)
!162 = !DILocalVariable(name: "__end", scope: !159, type: !6, flags: DIFlagArtificial)
!163 = !DILocalVariable(name: "x", scope: !164, file: !1, line: 443, type: !6)
!164 = distinct !DILexicalBlock(scope: !159, file: !1, line: 443, column: 3)
!165 = !DILocalVariable(name: "exponential", scope: !126, file: !1, line: 446, type: !36)
!166 = !DILocalVariable(name: "__init", scope: !167, type: !6, flags: DIFlagArtificial)
!167 = distinct !DILexicalBlock(scope: !126, file: !1, line: 450, column: 3)
!168 = !DILocalVariable(name: "__limit", scope: !167, type: !6, flags: DIFlagArtificial)
!169 = !DILocalVariable(name: "__begin", scope: !167, type: !6, flags: DIFlagArtificial)
!170 = !DILocalVariable(name: "__end", scope: !167, type: !6, flags: DIFlagArtificial)
!171 = !DILocalVariable(name: "x", scope: !172, file: !1, line: 450, type: !6)
!172 = distinct !DILexicalBlock(scope: !167, file: !1, line: 450, column: 3)
!173 = !DILocalVariable(name: "sumWeights", scope: !126, file: !1, line: 453, type: !7)
!174 = !DILocalVariable(name: "sum_time", scope: !126, file: !1, line: 454, type: !36)
!175 = !DILocalVariable(name: "__init", scope: !176, type: !6, flags: DIFlagArtificial)
!176 = distinct !DILexicalBlock(scope: !126, file: !1, line: 457, column: 3)
!177 = !DILocalVariable(name: "__limit", scope: !176, type: !6, flags: DIFlagArtificial)
!178 = !DILocalVariable(name: "__begin", scope: !176, type: !6, flags: DIFlagArtificial)
!179 = !DILocalVariable(name: "__end", scope: !176, type: !6, flags: DIFlagArtificial)
!180 = !DILocalVariable(name: "x", scope: !181, file: !1, line: 457, type: !6)
!181 = distinct !DILexicalBlock(scope: !176, file: !1, line: 457, column: 3)
!182 = !DILocalVariable(name: "normalize", scope: !126, file: !1, line: 460, type: !36)
!183 = !DILocalVariable(name: "__init", scope: !184, type: !6, flags: DIFlagArtificial)
!184 = distinct !DILexicalBlock(scope: !126, file: !1, line: 472, column: 3)
!185 = !DILocalVariable(name: "__limit", scope: !184, type: !6, flags: DIFlagArtificial)
!186 = !DILocalVariable(name: "__begin", scope: !184, type: !6, flags: DIFlagArtificial)
!187 = !DILocalVariable(name: "__end", scope: !184, type: !6, flags: DIFlagArtificial)
!188 = !DILocalVariable(name: "x", scope: !189, file: !1, line: 472, type: !6)
!189 = distinct !DILexicalBlock(scope: !184, file: !1, line: 472, column: 3)
!190 = !DILocalVariable(name: "move_time", scope: !126, file: !1, line: 478, type: !36)
!191 = !DILocalVariable(name: "distance", scope: !126, file: !1, line: 482, type: !7)
!192 = !DILocalVariable(name: "cum_sum", scope: !126, file: !1, line: 495, type: !36)
!193 = !DILocalVariable(name: "u1", scope: !126, file: !1, line: 497, type: !7)
!194 = !DILocalVariable(name: "__init", scope: !195, type: !6, flags: DIFlagArtificial)
!195 = distinct !DILexicalBlock(scope: !126, file: !1, line: 499, column: 3)
!196 = !DILocalVariable(name: "__limit", scope: !195, type: !6, flags: DIFlagArtificial)
!197 = !DILocalVariable(name: "__begin", scope: !195, type: !6, flags: DIFlagArtificial)
!198 = !DILocalVariable(name: "__end", scope: !195, type: !6, flags: DIFlagArtificial)
!199 = !DILocalVariable(name: "x", scope: !200, file: !1, line: 499, type: !6)
!200 = distinct !DILexicalBlock(scope: !195, file: !1, line: 499, column: 3)
!201 = !DILocalVariable(name: "u_time", scope: !126, file: !1, line: 502, type: !36)
!202 = !DILocalVariable(name: "j", scope: !126, file: !1, line: 504, type: !6)
!203 = !DILocalVariable(name: "i", scope: !126, file: !1, line: 504, type: !6)
!204 = !DILocalVariable(name: "__init", scope: !205, type: !6, flags: DIFlagArtificial)
!205 = distinct !DILexicalBlock(scope: !126, file: !1, line: 507, column: 3)
!206 = !DILocalVariable(name: "__limit", scope: !205, type: !6, flags: DIFlagArtificial)
!207 = !DILocalVariable(name: "__begin", scope: !205, type: !6, flags: DIFlagArtificial)
!208 = !DILocalVariable(name: "__end", scope: !205, type: !6, flags: DIFlagArtificial)
!209 = !DILocalVariable(name: "j", scope: !210, file: !1, line: 507, type: !6)
!210 = distinct !DILexicalBlock(scope: !205, file: !1, line: 507, column: 3)
!211 = !DILocalVariable(name: "i", scope: !212, file: !1, line: 508, type: !6)
!212 = distinct !DILexicalBlock(scope: !210, file: !1, line: 507, column: 43)
!213 = !DILocalVariable(name: "xyj_time", scope: !126, file: !1, line: 515, type: !36)
!214 = !DILocalVariable(name: "reset", scope: !126, file: !1, line: 525, type: !36)
!215 = !DILocation(line: 0, scope: !19)
!216 = !DILocalVariable(name: "__init", scope: !217, type: !6, flags: DIFlagArtificial)
!217 = distinct !DILexicalBlock(scope: !218, file: !1, line: 426, column: 4)
!218 = distinct !DILexicalBlock(scope: !19, file: !1, line: 420, column: 43)
!219 = !DILocation(line: 0, scope: !217)
!220 = !DILocalVariable(name: "__limit", scope: !217, type: !6, flags: DIFlagArtificial)
