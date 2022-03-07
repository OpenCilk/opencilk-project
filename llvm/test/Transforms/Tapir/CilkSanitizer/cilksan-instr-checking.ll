; Check Cilksan's handling of some special cases, including:
; - Accesses based on NULL pointers
; - Calls to llvm.experimental.noalias.scope.decl
;
; RUN: opt < %s -enable-new-pm=0 -csan -S | FileCheck %s
; RUN: opt < %s -passes='cilksan' -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::basic_ostream" = type { i32 (...)**, %"class.std::basic_ios" }
%"class.std::basic_ios" = type { %"class.std::ios_base", %"class.std::basic_ostream"*, i8, i8, %"class.std::basic_streambuf"*, %"class.std::ctype"*, %"class.std::num_put"*, %"class.std::num_get"* }
%"class.std::ios_base" = type { i32 (...)**, i64, i64, i32, i32, i32, %"struct.std::ios_base::_Callback_list"*, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, %"struct.std::ios_base::_Words"*, %"class.std::locale" }
%"struct.std::ios_base::_Callback_list" = type { %"struct.std::ios_base::_Callback_list"*, void (i32, %"class.std::ios_base"*, i32)*, i32, i32 }
%"struct.std::ios_base::_Words" = type { i8*, i64 }
%"class.std::locale" = type { %"class.std::locale::_Impl"* }
%"class.std::locale::_Impl" = type { i32, %"class.std::locale::facet"**, i64, %"class.std::locale::facet"**, i8** }
%"class.std::locale::facet" = type <{ i32 (...)**, i32, [4 x i8] }>
%"class.std::basic_streambuf" = type { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, %"class.std::locale" }
%"class.std::ctype" = type <{ %"class.std::locale::facet.base", [4 x i8], %struct.__locale_struct*, i8, [7 x i8], i32*, i32*, i16*, i8, [256 x i8], [256 x i8], i8, [6 x i8] }>
%"class.std::locale::facet.base" = type <{ i32 (...)**, i32 }>
%struct.__locale_struct = type { [13 x %struct.__locale_data*], i16*, i32*, i32*, [13 x i8*] }
%struct.__locale_data = type opaque
%"class.std::num_put" = type { %"class.std::locale::facet.base", [4 x i8] }
%"class.std::num_get" = type { %"class.std::locale::facet.base", [4 x i8] }
%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char>::_Alloc_hider", i64, %union.anon.3 }
%"struct.std::__cxx11::basic_string<char>::_Alloc_hider" = type { i8* }
%union.anon.3 = type { i64, [8 x i8] }
%"class.cxxopts::argument_incorrect_type" = type { %"class.cxxopts::OptionParseException" }
%"class.cxxopts::OptionParseException" = type { %"class.cxxopts::OptionException" }
%"class.cxxopts::OptionException" = type { %"class.std::exception", %"class.std::__cxx11::basic_string" }
%"class.std::exception" = type { i32 (...)** }

$_ZTVN7cxxopts23argument_incorrect_typeE = comdat any

$_ZNK7cxxopts15OptionException4whatEv = comdat any

@0 = private unnamed_addr global { { [18 x i8]*, i32, i32 } } { { [18 x i8]*, i32, i32 } { [18 x i8]* @.src.71, i32 119, i32 48 } }
@.src.71 = private unnamed_addr constant [18 x i8] c"./algorithms/BC.h\00", align 1
@_ZTVN7cxxopts23argument_incorrect_typeE = linkonce_odr dso_local unnamed_addr constant { [5 x i8*] } { [5 x i8*] [i8* null, i8* bitcast ({ i8*, i8*, i8* }* @_ZTIN7cxxopts23argument_incorrect_typeE to i8*), i8* bitcast (void (%"class.cxxopts::OptionException"*)* @_ZN7cxxopts15OptionExceptionD2Ev to i8*), i8* bitcast (void (%"class.cxxopts::argument_incorrect_type"*)* @_ZN7cxxopts23argument_incorrect_typeD0Ev to i8*), i8* bitcast (i8* (%"class.cxxopts::OptionException"*)* @_ZNK7cxxopts15OptionException4whatEv to i8*)] }, comdat, align 8
@_ZTIN7cxxopts23argument_incorrect_typeE = linkonce_odr dso_local constant { i8*, i8*, i8* } zeroinitializer

declare dso_local i8* @_ZNK7cxxopts15OptionException4whatEv(%"class.cxxopts::OptionException"* nonnull dereferenceable(40) %this) unnamed_addr #6

declare dso_local void @_ZN7cxxopts15OptionExceptionD2Ev(%"class.cxxopts::OptionException"* nonnull dereferenceable(40) %this) unnamed_addr #30

declare dso_local void @_ZN7cxxopts23argument_incorrect_typeD0Ev(%"class.cxxopts::argument_incorrect_type"* nonnull dereferenceable(40) %this) unnamed_addr #30

; Function Attrs: inlinehint uwtable mustprogress
declare dso_local nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_(%"class.std::basic_ostream"* nonnull align 8 dereferenceable(8)) #17

define dso_local void @foo(i64 %umax651, i64 %tmp) #9 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  call void @llvm.experimental.noalias.scope.decl(metadata !41122)
  call void @llvm.dbg.value(metadata %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_, metadata !49839, metadata !DIExpression())
  br label %pfor.cond28

; CHECK: entry:
; CHECK-NOT: call void @__csan_llvm_experimental_noalias_scope_decl(
; CHECK: br label %pfor.cond28

pfor.cond28:
  %__begin20.0 = phi i64 [ %inc42, %pfor.inc41 ], [ 0, %entry ]
  detach within %syncreg, label %pfor.body34, label %pfor.inc41

; CHECK: pfor.cond28:
; CHECK: call void @__csan_detach(
; CHECK-NEXT: detach within %syncreg, label %pfor.body34, label %pfor.inc41

pfor.body34:
  %funcload = load i32, i32* bitcast (%"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_ to i32*), align 4
  %arrayidx35 = getelementptr inbounds i8, i8* null, i64 %__begin20.0
  %tmp2 = add nuw i64 %__begin20.0, %tmp
  %.not703 = icmp eq i64 %tmp2, 0
  br i1 %.not703, label %handler.type_mismatch38, label %handler.pointer_overflow36

; CHECK: pfor.body34:
; CHECK: call void @__csan_task(

; CHECK: call void @__csan_load(i64 %{{.+}}, i8* bitcast (%"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_ to i8*),
; CHECK: %funcload = load i32, i32* bitcast (%"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_ to i32*), align 4

handler.pointer_overflow36:
  tail call void @__ubsan_handle_pointer_overflow(i8* bitcast ({ { [18 x i8]*, i32, i32 } }* @0 to i8*), i64 %tmp, i64 %tmp2) #38
  br label %handler.type_mismatch38

; CHECK: handler.pointer_overflow36:
; CHECK: call void @__csan_before_call(
; CHECK-NEXT: tail call void @__ubsan_handle_pointer_overflow(
; CHECK-NEXT: call void @__csan_after_call(
; CHECK-NEXT: br label %handler.type_mismatch38

handler.type_mismatch38:
  store i8 undef, i8* %arrayidx35, align 1
  reattach within %syncreg, label %pfor.inc41

; CHECK: handler.type_mismatch38:
; CHECK-NOT: call void @__csan_store
; CHECK: store i8 undef, i8* %arrayidx35,
; CHECK: call void @__csan_task_exit(
; CHECK-NEXT: reattach within %syncreg, label %pfor.inc41

pfor.inc41:
  %inc42 = add nuw nsw i64 %__begin20.0, 1
  %exitcond652.not = icmp eq i64 %inc42, %umax651
  br i1 %exitcond652.not, label %pfor.cond.cleanup44, label %pfor.cond28, !llvm.loop !41075

; CHECK: pfor.inc41:
; CHECK: call void @__csan_detach_continue(

pfor.cond.cleanup44:
  sync within %syncreg, label %sync.continue46

sync.continue46:
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #10

; Function Attrs: uwtable
declare dso_local void @__ubsan_handle_pointer_overflow(i8*, i64, i64) local_unnamed_addr #0

; Function Attrs: inaccessiblememonly nofree nosync nounwind willreturn
declare void @llvm.experimental.noalias.scope.decl(metadata) #37

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #5

attributes #0 = { uwtable }
attributes #5 = { sanitize_cilk nofree nosync nounwind readnone speculatable willreturn }
attributes #6 = { nounwind uwtable mustprogress "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { sanitize_cilk uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { argmemonly nounwind willreturn }
attributes #17 = { inlinehint uwtable mustprogress "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #30 = { inlinehint nounwind uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #37 = { inaccessiblememonly nofree nosync nounwind willreturn }
attributes #38 = { nounwind }

!11 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 64)
!103 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !104, size: 64)
!104 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!2013 = !DIFile(filename: "", directory: "")
!34472 = !{!"tapir.loop.spawn.strategy", i32 1}
!41075 = distinct !{!41075, !34472}
!41122 = !{!41123}
!41123 = distinct !{!41123, !41124, !"_ZNK13SparseMatrixV9vertexMapI11BC_Vertex_FEE12VertexSubsetRS2_T_b: %agg.result"}
!41124 = distinct !{!41124, !"_ZNK13SparseMatrixV9vertexMapI11BC_Vertex_FEE12VertexSubsetRS2_T_b"}
!47467 = distinct !DISubprogram(name: "main", scope: !2013, file: !2013, line: 846, type: !47468, scopeLine: 846, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized)
!47468 = !DISubroutineType(types: !47469)
!47469 = !{!11, !11, !102}
!49814 = distinct !DILexicalBlock(scope: !47467, file: !2013, line: 902, column: 7)
!49823 = distinct !DILexicalBlock(scope: !49814, file: !2013, line: 902, column: 34)
!49831 = distinct !DISubprogram(name: "operator<<", linkageName: "_ZNSolsEPFRSoS_E")
!49839 = !DILocalVariable(name: "__pf", arg: 2, scope: !49831, line: 108)
!49841 = distinct !DILocation(line: 903, column: 46, scope: !49823)
!49842 = !DILocation(line: 113, column: 9, scope: !49831, inlinedAt: !49841)
!49844 = distinct !DILocation(line: 903, column: 5, scope: !49823)
