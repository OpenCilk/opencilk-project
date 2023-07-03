; Check that CilkSanitizer instrumentation pass handles
; @llvm.dbg.value() call with complex constant metadata node.
;
; RUN: opt < %s -passes="cilksan" -S | FileCheck %s

%"class.std::__1::basic_string" = type { %"class.std::__1::__compressed_pair.67" }
%"class.std::__1::__compressed_pair.67" = type { %"struct.std::__1::__compressed_pair_elem.68" }
%"struct.std::__1::__compressed_pair_elem.68" = type { %"struct.std::__1::basic_string<char>::__rep" }
%"struct.std::__1::basic_string<char>::__rep" = type { %union.anon.69 }
%union.anon.69 = type { %"struct.std::__1::basic_string<char>::__long" }
%"struct.std::__1::basic_string<char>::__long" = type { i8*, i64, i64 }

@_ZTSN3c107variantIJNSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEdxbEEE = external constant [86 x i8]

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

define linkonce_odr void @_ZN8pybind1122implicitly_convertibleINSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEN3c107variantIJS7_dxbEEEEEvv() personality i8* undef {
if.else:
  invoke fastcc void bitcast (void ()* @_ZN8pybind11L7type_idIN3c107variantIJNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEdxbEEEEES9_v to void (%"class.std::__1::basic_string"*)*)(%"class.std::__1::basic_string"* null)
          to label %.noexc15 unwind label %csi.cleanup

.noexc15:                                         ; preds = %if.else
  ret void

csi.cleanup:                                      ; preds = %if.else
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } zeroinitializer
}

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: sanitize_cilk
define internal fastcc void @_ZN8pybind11L7type_idIN3c107variantIJNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEdxbEEEEES9_v() #4 personality i32 (...)* undef {
if.end9.i.i.i.i:
  call void @llvm.dbg.value(metadata i8* inttoptr (i64 and (i64 add (i64 ptrtoint ([86 x i8]* @_ZTSN3c107variantIJNSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEdxbEEE to i64), i64 -9223372036854775808), i64 9223372036854775807) to i8*), metadata !82956, metadata !DIExpression())
  br label %cond.false.i.i.i.i.i

cond.false.i.i.i.i.i:                             ; preds = %if.end9.i.i.i.i
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* null, i8* inttoptr (i64 and (i64 add (i64 ptrtoint ([86 x i8]* @_ZTSN3c107variantIJNSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEdxbEEE to i64), i64 -9223372036854775808), i64 9223372036854775807) to i8*), i64 0, i1 false)
  ret void
}

; CHECK: define internal fastcc void @_ZN8pybind11L7type_idIN3c107variantIJNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEdxbEEEEES9_v(
; CHECK: cond.false.i.i.i.i.i:
; CHECK: call void @__csan_large_load(
; CHECK: ptr inttoptr (i64 and (i64 add (i64 ptrtoint (ptr @_ZTSN3c107variantIJNSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEdxbEEE to i64), i64 -9223372036854775808), i64 9223372036854775807) to ptr),
; CHECK: tail call void @llvm.memcpy.p0.p0.i64(ptr null, ptr inttoptr (i64 and (i64 add (i64 ptrtoint (ptr @_ZTSN3c107variantIJNSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEdxbEEE to i64), i64 -9223372036854775808), i64 9223372036854775807) to ptr), i64 0, i1 false)
; CHECK: ret void

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #0

; Function Attrs: inaccessiblememonly nofree nosync nounwind willreturn
declare void @llvm.experimental.noalias.scope.decl(metadata) #5

attributes #0 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { argmemonly nofree nounwind willreturn }
attributes #3 = { argmemonly nofree nounwind willreturn writeonly }
attributes #4 = { sanitize_cilk }
attributes #5 = { inaccessiblememonly nofree nosync nounwind willreturn }

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git 3a58729965c94a4a4db90f14d4ba8b5afa1af7c7)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None, sysroot: "/")
!1 = !DIFile(filename: "python_init.cpp", directory: "/Software/cilk/pytorch/pytorch-build")
!197 = !DINamespace(name: "__1", scope: !198, exportSymbols: true)
!198 = !DINamespace(name: "std", scope: null)
!213 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!247 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!248 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !249, line: 46, baseType: !250)
!249 = !DIFile(filename: "opencilk-project/build/lib/clang/14.0.6/include/stddef.h", directory: "/Users/neboat/Software")
!250 = !DIBasicType(name: "unsigned long", size: 64, encoding: DW_ATE_unsigned)
!327 = !DITemplateTypeParameter(name: "_CharT", type: !247)
!363 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!635 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "char_traits<char>", scope: !197, file: !636, line: 324, size: 8, flags: DIFlagTypePassByValue, elements: !637, templateParams: !683, identifier: "_ZTSNSt3__111char_traitsIcEE")
!636 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.3.sdk/usr/include/c++/v1/__string", directory: "")
!637 = !{!638, !645, !648, !649, !653, !656, !659, !663, !664, !667, !671, !674, !677, !680}
!638 = !DISubprogram(name: "assign", linkageName: "_ZNSt3__111char_traitsIcE6assignERcRKc", scope: !635, file: !636, line: 333, type: !639, scopeLine: 333, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!639 = !DISubroutineType(types: !640)
!640 = !{null, !641, !643}
!641 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !642, size: 64)
!642 = !DIDerivedType(tag: DW_TAG_typedef, name: "char_type", scope: !635, file: !636, line: 326, baseType: !247)
!643 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !644, size: 64)
!644 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !642)
!645 = !DISubprogram(name: "eq", linkageName: "_ZNSt3__111char_traitsIcE2eqEcc", scope: !635, file: !636, line: 334, type: !646, scopeLine: 334, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!646 = !DISubroutineType(types: !647)
!647 = !{!213, !642, !642}
!648 = !DISubprogram(name: "lt", linkageName: "_ZNSt3__111char_traitsIcE2ltEcc", scope: !635, file: !636, line: 336, type: !646, scopeLine: 336, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!649 = !DISubprogram(name: "compare", linkageName: "_ZNSt3__111char_traitsIcE7compareEPKcS3_m", scope: !635, file: !636, line: 340, type: !650, scopeLine: 340, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!650 = !DISubroutineType(types: !651)
!651 = !{!363, !652, !652, !248}
!652 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !644, size: 64)
!653 = !DISubprogram(name: "length", linkageName: "_ZNSt3__111char_traitsIcE6lengthEPKc", scope: !635, file: !636, line: 342, type: !654, scopeLine: 342, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!654 = !DISubroutineType(types: !655)
!655 = !{!248, !652}
!656 = !DISubprogram(name: "find", linkageName: "_ZNSt3__111char_traitsIcE4findEPKcmRS2_", scope: !635, file: !636, line: 344, type: !657, scopeLine: 344, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!657 = !DISubroutineType(types: !658)
!658 = !{!652, !652, !248, !643}
!659 = !DISubprogram(name: "move", linkageName: "_ZNSt3__111char_traitsIcE4moveEPcPKcm", scope: !635, file: !636, line: 346, type: !660, scopeLine: 346, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!660 = !DISubroutineType(types: !661)
!661 = !{!662, !662, !652, !248}
!662 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !642, size: 64)
!663 = !DISubprogram(name: "copy", linkageName: "_ZNSt3__111char_traitsIcE4copyEPcPKcm", scope: !635, file: !636, line: 353, type: !660, scopeLine: 353, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!664 = !DISubprogram(name: "assign", linkageName: "_ZNSt3__111char_traitsIcE6assignEPcmc", scope: !635, file: !636, line: 361, type: !665, scopeLine: 361, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!665 = !DISubroutineType(types: !666)
!666 = !{!662, !662, !248, !642}
!667 = !DISubprogram(name: "not_eof", linkageName: "_ZNSt3__111char_traitsIcE7not_eofEi", scope: !635, file: !636, line: 368, type: !668, scopeLine: 368, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!668 = !DISubroutineType(types: !669)
!669 = !{!670, !670}
!670 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_type", scope: !635, file: !636, line: 327, baseType: !363)
!671 = !DISubprogram(name: "to_char_type", linkageName: "_ZNSt3__111char_traitsIcE12to_char_typeEi", scope: !635, file: !636, line: 370, type: !672, scopeLine: 370, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!672 = !DISubroutineType(types: !673)
!673 = !{!642, !670}
!674 = !DISubprogram(name: "to_int_type", linkageName: "_ZNSt3__111char_traitsIcE11to_int_typeEc", scope: !635, file: !636, line: 372, type: !675, scopeLine: 372, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!675 = !DISubroutineType(types: !676)
!676 = !{!670, !642}
!677 = !DISubprogram(name: "eq_int_type", linkageName: "_ZNSt3__111char_traitsIcE11eq_int_typeEii", scope: !635, file: !636, line: 374, type: !678, scopeLine: 374, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!678 = !DISubroutineType(types: !679)
!679 = !{!213, !670, !670}
!680 = !DISubprogram(name: "eof", linkageName: "_ZNSt3__111char_traitsIcE3eofEv", scope: !635, file: !636, line: 376, type: !681, scopeLine: 376, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!681 = !DISubroutineType(types: !682)
!682 = !{!670}
!683 = !{!327}
!82956 = !DILocalVariable(name: "__s2", arg: 2, scope: !82957, file: !636, line: 353, type: !652)
!82957 = distinct !DISubprogram(name: "copy", linkageName: "_ZNSt3__111char_traitsIcE4copyEPcPKcm", scope: !635, file: !636, line: 353, type: !660, scopeLine: 354, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !663, retainedNodes: !82958)
!82958 = !{!82959, !82956, !82960}
!82959 = !DILocalVariable(name: "__s1", arg: 1, scope: !82957, file: !636, line: 353, type: !662)
!82960 = !DILocalVariable(name: "__n", arg: 3, scope: !82957, file: !636, line: 353, type: !248)
