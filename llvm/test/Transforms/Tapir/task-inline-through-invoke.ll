; RUN: opt < %s -inline -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
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
%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i64, %union.anon.1 }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider" = type { i8* }
%union.anon.1 = type { i64, [8 x i8] }
%"class.std::allocator" = type { i8 }
%"struct.benchIO::seqData" = type { i8*, i64, i32, i8* }
%struct.commandLine = type { i32, i8**, %"class.std::__cxx11::basic_string" }

$_Z9quickSortIdSt4lessIdEiEvPT_T1_T0_ = comdat any

$_Z9quickSortIPc7strLessiEvPT_T1_T0_ = comdat any

$_Z9quickSortIPc7strLesslEvPT_T1_T0_ = comdat any

$_Z9quickSortIdSt4lessIdElEvPT_T1_T0_ = comdat any

@_ZSt4cout = external dso_local global %"class.std::basic_ostream", align 8
@.str.13 = private unnamed_addr constant [19 x i8] c"<infile> <outfile>\00", align 1
@.str.14 = private unnamed_addr constant [33 x i8] c"compSortCheck: types don't match\00", align 1
@.str.15 = private unnamed_addr constant [35 x i8] c"compSortCheck: lengths dont' match\00", align 1
@.str.16 = private unnamed_addr constant [34 x i8] c"compSortCheck: check failed at i=\00", align 1
@.str.17 = private unnamed_addr constant [45 x i8] c"CompSortCheck: input files not of right type\00", align 1

; Function Attrs: uwtable
define linkonce_odr dso_local void @_Z9quickSortIdSt4lessIdEiEvPT_T1_T0_(double* %A, i32 %n) local_unnamed_addr #0 comdat {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp slt i32 %n, 256
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  tail call void @_Z15quickSortSerialIdSt4lessIdEiEvPT_T1_T0_(double* %A, i32 %n)
  br label %if.end

if.else:                                          ; preds = %entry
  %call = tail call { double*, double* } @_Z5splitIdSt4lessIdEiESt4pairIPT_S4_ES4_T1_T0_(double* %A, i32 %n)
  %0 = extractvalue { double*, double* } %call, 1
  %1 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.else
  %2 = extractvalue { double*, double* } %call, 0
  %sub.ptr.lhs.cast = ptrtoint double* %2 to i64
  %sub.ptr.rhs.cast = ptrtoint double* %A to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 3
  tail call void @llvm.taskframe.use(token %1)
  tail call void @_Z9quickSortIdSt4lessIdElEvPT_T1_T0_(double* %A, i64 %sub.ptr.div)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.else
  %idx.ext = sext i32 %n to i64
  %add.ptr = getelementptr inbounds double, double* %A, i64 %idx.ext
  %sub.ptr.lhs.cast4 = ptrtoint double* %add.ptr to i64
  %sub.ptr.rhs.cast5 = ptrtoint double* %0 to i64
  %sub.ptr.sub6 = sub i64 %sub.ptr.lhs.cast4, %sub.ptr.rhs.cast5
  %sub.ptr.div7 = ashr exact i64 %sub.ptr.sub6, 3
  tail call void @_Z9quickSortIdSt4lessIdElEvPT_T1_T0_(double* %0, i64 %sub.ptr.div7)
  sync within %syncreg, label %if.end

if.end:                                           ; preds = %det.cont, %if.then
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_Z9quickSortIdSt4lessIdElEvPT_T1_T0_(double* %A, i64 %n) local_unnamed_addr #0 comdat {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp20 = icmp slt i64 %n, 256
  br i1 %cmp20, label %if.then, label %if.else

if.then:                                          ; preds = %det.cont, %entry
  %A.tr.lcssa = phi double* [ %A, %entry ], [ %0, %det.cont ]
  %n.tr.lcssa = phi i64 [ %n, %entry ], [ %sub.ptr.div7, %det.cont ]
  tail call void @_Z15quickSortSerialIdSt4lessIdElEvPT_T1_T0_(double* %A.tr.lcssa, i64 %n.tr.lcssa)
  sync within %syncreg, label %if.end.split

if.else:                                          ; preds = %entry, %det.cont
  %n.tr22 = phi i64 [ %sub.ptr.div7, %det.cont ], [ %n, %entry ]
  %A.tr21 = phi double* [ %0, %det.cont ], [ %A, %entry ]
  %call = tail call { double*, double* } @_Z5splitIdSt4lessIdElESt4pairIPT_S4_ES4_T1_T0_(double* %A.tr21, i64 %n.tr22)
  %0 = extractvalue { double*, double* } %call, 1
  %1 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.else
  %2 = extractvalue { double*, double* } %call, 0
  %sub.ptr.lhs.cast = ptrtoint double* %2 to i64
  %sub.ptr.rhs.cast = ptrtoint double* %A.tr21 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 3
  tail call void @llvm.taskframe.use(token %1)
  tail call void @_Z9quickSortIdSt4lessIdElEvPT_T1_T0_(double* %A.tr21, i64 %sub.ptr.div)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.else
  %add.ptr = getelementptr inbounds double, double* %A.tr21, i64 %n.tr22
  %sub.ptr.lhs.cast4 = ptrtoint double* %add.ptr to i64
  %sub.ptr.rhs.cast5 = ptrtoint double* %0 to i64
  %sub.ptr.sub6 = sub i64 %sub.ptr.lhs.cast4, %sub.ptr.rhs.cast5
  %sub.ptr.div7 = ashr exact i64 %sub.ptr.sub6, 3
  %cmp = icmp slt i64 %sub.ptr.sub6, 2048
  br i1 %cmp, label %if.then, label %if.else

if.end.split:                                     ; preds = %if.then
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_Z9quickSortIPc7strLessiEvPT_T1_T0_(i8** %A, i32 %n) local_unnamed_addr #0 comdat {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp slt i32 %n, 256
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  tail call void @_Z15quickSortSerialIPc7strLessiEvPT_T1_T0_(i8** %A, i32 %n)
  br label %if.end

if.else:                                          ; preds = %entry
  %call = tail call { i8**, i8** } @_Z5splitIPc7strLessiESt4pairIPT_S4_ES4_T1_T0_(i8** %A, i32 %n)
  %0 = extractvalue { i8**, i8** } %call, 1
  %1 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.else
  %2 = extractvalue { i8**, i8** } %call, 0
  %sub.ptr.lhs.cast = ptrtoint i8** %2 to i64
  %sub.ptr.rhs.cast = ptrtoint i8** %A to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 3
  tail call void @llvm.taskframe.use(token %1)
  tail call void @_Z9quickSortIPc7strLesslEvPT_T1_T0_(i8** %A, i64 %sub.ptr.div)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.else
  %idx.ext = sext i32 %n to i64
  %add.ptr = getelementptr inbounds i8*, i8** %A, i64 %idx.ext
  %sub.ptr.lhs.cast4 = ptrtoint i8** %add.ptr to i64
  %sub.ptr.rhs.cast5 = ptrtoint i8** %0 to i64
  %sub.ptr.sub6 = sub i64 %sub.ptr.lhs.cast4, %sub.ptr.rhs.cast5
  %sub.ptr.div7 = ashr exact i64 %sub.ptr.sub6, 3
  tail call void @_Z9quickSortIPc7strLesslEvPT_T1_T0_(i8** %0, i64 %sub.ptr.div7)
  sync within %syncreg, label %if.end

if.end:                                           ; preds = %det.cont, %if.then
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_Z9quickSortIPc7strLesslEvPT_T1_T0_(i8** %A, i64 %n) local_unnamed_addr #0 comdat {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp20 = icmp slt i64 %n, 256
  br i1 %cmp20, label %if.then, label %if.else

if.then:                                          ; preds = %det.cont, %entry
  %A.tr.lcssa = phi i8** [ %A, %entry ], [ %0, %det.cont ]
  %n.tr.lcssa = phi i64 [ %n, %entry ], [ %sub.ptr.div7, %det.cont ]
  tail call void @_Z15quickSortSerialIPc7strLesslEvPT_T1_T0_(i8** %A.tr.lcssa, i64 %n.tr.lcssa)
  sync within %syncreg, label %if.end.split

if.else:                                          ; preds = %entry, %det.cont
  %n.tr22 = phi i64 [ %sub.ptr.div7, %det.cont ], [ %n, %entry ]
  %A.tr21 = phi i8** [ %0, %det.cont ], [ %A, %entry ]
  %call = tail call { i8**, i8** } @_Z5splitIPc7strLesslESt4pairIPT_S4_ES4_T1_T0_(i8** %A.tr21, i64 %n.tr22)
  %0 = extractvalue { i8**, i8** } %call, 1
  %1 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.else
  %2 = extractvalue { i8**, i8** } %call, 0
  %sub.ptr.lhs.cast = ptrtoint i8** %2 to i64
  %sub.ptr.rhs.cast = ptrtoint i8** %A.tr21 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 3
  tail call void @llvm.taskframe.use(token %1)
  tail call void @_Z9quickSortIPc7strLesslEvPT_T1_T0_(i8** %A.tr21, i64 %sub.ptr.div)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.else
  %add.ptr = getelementptr inbounds i8*, i8** %A.tr21, i64 %n.tr22
  %sub.ptr.lhs.cast4 = ptrtoint i8** %add.ptr to i64
  %sub.ptr.rhs.cast5 = ptrtoint i8** %0 to i64
  %sub.ptr.sub6 = sub i64 %sub.ptr.lhs.cast4, %sub.ptr.rhs.cast5
  %sub.ptr.div7 = ashr exact i64 %sub.ptr.sub6, 3
  %cmp = icmp slt i64 %sub.ptr.sub6, 2048
  br i1 %cmp, label %if.then, label %if.else

if.end.split:                                     ; preds = %if.then
  ret void
}

; Function Attrs: norecurse uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #15 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %P = alloca %struct.commandLine, align 8
  %agg.tmp = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp = alloca %"class.std::allocator", align 1
  %In = alloca %"struct.benchIO::seqData", align 8
  %Out = alloca %"struct.benchIO::seqData", align 8
  %0 = bitcast %struct.commandLine* %P to i8*
  call void @llvm.lifetime.start.p0i8(i64 48, i8* nonnull %0) #22
  %1 = getelementptr inbounds %"class.std::allocator", %"class.std::allocator"* %ref.tmp, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1) #22
  call void @_ZNSaIcEC2Ev(%"class.std::allocator"* nonnull %ref.tmp) #22
  invoke void @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_(%"class.std::__cxx11::basic_string"* nonnull %agg.tmp, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.13, i64 0, i64 0), %"class.std::allocator"* nonnull dereferenceable(1) %ref.tmp)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  invoke void @_ZN11commandLineC2EiPPcNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%struct.commandLine* nonnull %P, i32 %argc, i8** %argv, %"class.std::__cxx11::basic_string"* nonnull %agg.tmp)
          to label %invoke.cont2 unwind label %lpad1

invoke.cont2:                                     ; preds = %invoke.cont
  call void @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev(%"class.std::__cxx11::basic_string"* nonnull %agg.tmp) #22
  call void @_ZNSaIcED2Ev(%"class.std::allocator"* nonnull %ref.tmp) #22
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1) #22
  %call = invoke { i8*, i8* } @_ZN11commandLine11IOFileNamesEv(%struct.commandLine* nonnull %P)
          to label %invoke.cont5 unwind label %lpad4

invoke.cont5:                                     ; preds = %invoke.cont2
  %2 = extractvalue { i8*, i8* } %call, 0
  %3 = bitcast %"struct.benchIO::seqData"* %In to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %3) #22
  invoke void @_ZN7benchIO20readSequenceFromFileEPc(%"struct.benchIO::seqData"* nonnull sret %In, i8* %2)
          to label %invoke.cont7 unwind label %lpad6

invoke.cont7:                                     ; preds = %invoke.cont5
  %4 = extractvalue { i8*, i8* } %call, 1
  %5 = bitcast %"struct.benchIO::seqData"* %Out to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %5) #22
  invoke void @_ZN7benchIO20readSequenceFromFileEPc(%"struct.benchIO::seqData"* nonnull sret %Out, i8* %4)
          to label %invoke.cont9 unwind label %lpad8

invoke.cont9:                                     ; preds = %invoke.cont7
  %n10 = getelementptr inbounds %"struct.benchIO::seqData", %"struct.benchIO::seqData"* %In, i64 0, i32 1
  %6 = load i64, i64* %n10, align 8, !tbaa !48
  %conv = trunc i64 %6 to i32
  %dt11 = getelementptr inbounds %"struct.benchIO::seqData", %"struct.benchIO::seqData"* %In, i64 0, i32 2
  %7 = load i32, i32* %dt11, align 8, !tbaa !49
  %dt12 = getelementptr inbounds %"struct.benchIO::seqData", %"struct.benchIO::seqData"* %Out, i64 0, i32 2
  %8 = load i32, i32* %dt12, align 8, !tbaa !49
  %cmp = icmp eq i32 %7, %8
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %invoke.cont9
  %call15 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.14, i64 0, i64 0))
          to label %invoke.cont14 unwind label %lpad13

invoke.cont14:                                    ; preds = %if.then
  %call17 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* nonnull %call15, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* nonnull @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
          to label %cleanup unwind label %lpad13

lpad:                                             ; preds = %entry
  %9 = landingpad { i8*, i32 }
          cleanup
  %10 = extractvalue { i8*, i32 } %9, 0
  %11 = extractvalue { i8*, i32 } %9, 1
  br label %ehcleanup

lpad1:                                            ; preds = %invoke.cont
  %12 = landingpad { i8*, i32 }
          cleanup
  %13 = extractvalue { i8*, i32 } %12, 0
  %14 = extractvalue { i8*, i32 } %12, 1
  call void @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev(%"class.std::__cxx11::basic_string"* nonnull %agg.tmp) #22
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad1, %lpad
  %ehselector.slot.0 = phi i32 [ %14, %lpad1 ], [ %11, %lpad ]
  %exn.slot.0 = phi i8* [ %13, %lpad1 ], [ %10, %lpad ]
  call void @_ZNSaIcED2Ev(%"class.std::allocator"* nonnull %ref.tmp) #22
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1) #22
  br label %ehcleanup103

lpad4:                                            ; preds = %invoke.cont2
  %15 = landingpad { i8*, i32 }
          cleanup
  %16 = extractvalue { i8*, i32 } %15, 0
  %17 = extractvalue { i8*, i32 } %15, 1
  br label %ehcleanup99

lpad6:                                            ; preds = %invoke.cont5
  %18 = landingpad { i8*, i32 }
          cleanup
  %19 = extractvalue { i8*, i32 } %18, 0
  %20 = extractvalue { i8*, i32 } %18, 1
  br label %ehcleanup97

lpad8:                                            ; preds = %invoke.cont7
  %21 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup95

lpad13:                                           ; preds = %invoke.cont85, %if.else84, %invoke.cont22, %if.then21, %invoke.cont14, %if.then
  %22 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup95

if.end:                                           ; preds = %invoke.cont9
  %sext = shl i64 %6, 32
  %conv18 = ashr exact i64 %sext, 32
  %n19 = getelementptr inbounds %"struct.benchIO::seqData", %"struct.benchIO::seqData"* %Out, i64 0, i32 1
  %23 = load i64, i64* %n19, align 8, !tbaa !48
  %cmp20 = icmp eq i64 %conv18, %23
  br i1 %cmp20, label %if.end26, label %if.then21

if.then21:                                        ; preds = %if.end
  %call23 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.15, i64 0, i64 0))
          to label %invoke.cont22 unwind label %lpad13

invoke.cont22:                                    ; preds = %if.then21
  %call25 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* nonnull %call23, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* nonnull @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
          to label %cleanup unwind label %lpad13

if.end26:                                         ; preds = %if.end
  switch i32 %7, label %if.else84 [
    i32 4, label %if.then28
    i32 5, label %if.then51
  ]

if.then28:                                        ; preds = %if.end26
  %24 = bitcast %"struct.benchIO::seqData"* %In to double**
  %25 = load double*, double** %24, align 8, !tbaa !45
  %26 = bitcast %"struct.benchIO::seqData"* %Out to double**
  %27 = load double*, double** %26, align 8, !tbaa !45
  invoke void @_Z9quickSortIdSt4lessIdEiEvPT_T1_T0_(double* %25, i32 %conv)
          to label %for.cond.preheader unwind label %lpad32

; CHECK: if.then28:
; CHECK-NOT: invoke void @_Z9quickSortIdSt4lessIdEiEvPT_T1_T0_
; CHECK: br i1 %cmp.i, label %if.then.i, label %if.else.i

; CHECK: if.then.i:
; CHECK-NEXT: invoke void @_Z15quickSortSerialIdSt4lessIdEiEvPT_T1_T0_
; CHECK-NEXT: to label {{.+}} unwind label %lpad32

; CHECK: if.else.i:
; CHECK-NEXT: call { double*, double* } @_Z5splitIdSt4lessIdEiESt4pairIPT_S4_ES4_T1_T0_
; CHECK: br label %if.else.i.split

; CHECK: if.else.i.split:
; CHECK-NEXT: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %syncreg.i, label %det.achd.i, label %det.cont.i unwind label %[[TASKFRAMELPAD:.+]]

; CHECK: det.achd.i:
; CHECK: call void @llvm.taskframe.use(token %[[TASKFRAME]])
; CHECK: invoke void @_Z9quickSortIdSt4lessIdElEvPT_T1_T0_
; CHECK-NEXT: to label %.noexc unwind label %[[DETACHLPAD:.+]]

; CHECK: .noexc:
; CHECK-NEXT: reattach within %syncreg.i, label %det.cont.i

; CHECK: det.cont.i:
; CHECK: invoke void @_Z9quickSortIdSt4lessIdElEvPT_T1_T0_
; CHECK-NEXT: to label %.noexc3 unwind label %lpad32

; CHECK: .noexc3:
; CHECK-NEXT: sync within %syncreg.i, label %_Z9quickSortIdSt4lessIdEiEvPT_T1_T0_.exit

; CHECK: [[TASKFRAMELPAD]]:
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
; CHECK-NEXT: to label %{{.+}} unwind label %lpad32

; CHECK: [[DETACHLPAD]]:
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i,
; CHECK-NEXT: to label %{{.+}} unwind label %[[TASKFRAMELPAD]]

for.cond.preheader:                               ; preds = %if.then28
  %cmp34145 = icmp sgt i32 %conv, 0
  br i1 %cmp34145, label %for.body.preheader, label %cleanup

for.body.preheader:                               ; preds = %for.cond.preheader
  %wide.trip.count = and i64 %6, 4294967295
  br label %for.body

lpad32:                                           ; preds = %if.then28
  %28 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup95

for.body:                                         ; preds = %for.inc, %for.body.preheader
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.inc ]
  %arrayidx = getelementptr inbounds double, double* %25, i64 %indvars.iv
  %29 = load double, double* %arrayidx, align 8, !tbaa !33
  %arrayidx36 = getelementptr inbounds double, double* %27, i64 %indvars.iv
  %30 = load double, double* %arrayidx36, align 8, !tbaa !33
  %cmp37 = fcmp une double %29, %30
  br i1 %cmp37, label %if.then38, label %for.inc

if.then38:                                        ; preds = %for.body
  %call41 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.16, i64 0, i64 0))
          to label %invoke.cont40 unwind label %lpad39

invoke.cont40:                                    ; preds = %if.then38
  %31 = trunc i64 %indvars.iv to i32
  %call43 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEi(%"class.std::basic_ostream"* nonnull %call41, i32 %31)
          to label %invoke.cont42 unwind label %lpad39

invoke.cont42:                                    ; preds = %invoke.cont40
  %call45 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* nonnull %call43, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* nonnull @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
          to label %invoke.cont44 unwind label %lpad39

invoke.cont44:                                    ; preds = %invoke.cont42
  call void @abort() #23
  unreachable

lpad39:                                           ; preds = %invoke.cont42, %invoke.cont40, %if.then38
  %32 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup95

for.inc:                                          ; preds = %for.body
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond, label %cleanup, label %for.body

if.then51:                                        ; preds = %if.end26
  %33 = bitcast %"struct.benchIO::seqData"* %In to i8***
  %34 = load i8**, i8*** %33, align 8, !tbaa !45
  %35 = bitcast %"struct.benchIO::seqData"* %Out to i8***
  %36 = load i8**, i8*** %35, align 8, !tbaa !45
  invoke void @_Z9quickSortIPc7strLessiEvPT_T1_T0_(i8** %34, i32 %conv)
          to label %for.cond60.preheader unwind label %lpad57

for.cond60.preheader:                             ; preds = %if.then51
  %cmp61147 = icmp sgt i32 %conv, 0
  br i1 %cmp61147, label %for.body63.preheader, label %cleanup

for.body63.preheader:                             ; preds = %for.cond60.preheader
  %wide.trip.count154 = and i64 %6, 4294967295
  br label %for.body63

lpad57:                                           ; preds = %if.then51
  %37 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup95

for.body63:                                       ; preds = %for.inc78, %for.body63.preheader
  %indvars.iv152 = phi i64 [ 0, %for.body63.preheader ], [ %indvars.iv.next153, %for.inc78 ]
  %arrayidx65 = getelementptr inbounds i8*, i8** %34, i64 %indvars.iv152
  %38 = load i8*, i8** %arrayidx65, align 8, !tbaa !12
  %arrayidx67 = getelementptr inbounds i8*, i8** %36, i64 %indvars.iv152
  %39 = load i8*, i8** %arrayidx67, align 8, !tbaa !12
  %call68 = call i32 @strcmp(i8* %38, i8* %39) #25
  %tobool = icmp eq i32 %call68, 0
  br i1 %tobool, label %for.inc78, label %if.then69

if.then69:                                        ; preds = %for.body63
  %call72 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.16, i64 0, i64 0))
          to label %invoke.cont71 unwind label %lpad70

invoke.cont71:                                    ; preds = %if.then69
  %40 = trunc i64 %indvars.iv152 to i32
  %call74 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEi(%"class.std::basic_ostream"* nonnull %call72, i32 %40)
          to label %invoke.cont73 unwind label %lpad70

invoke.cont73:                                    ; preds = %invoke.cont71
  %call76 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* nonnull %call74, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* nonnull @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
          to label %invoke.cont75 unwind label %lpad70

invoke.cont75:                                    ; preds = %invoke.cont73
  call void @abort() #23
  unreachable

lpad70:                                           ; preds = %invoke.cont73, %invoke.cont71, %if.then69
  %41 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup95

for.inc78:                                        ; preds = %for.body63
  %indvars.iv.next153 = add nuw nsw i64 %indvars.iv152, 1
  %exitcond155 = icmp eq i64 %indvars.iv.next153, %wide.trip.count154
  br i1 %exitcond155, label %cleanup, label %for.body63

if.else84:                                        ; preds = %if.end26
  %call86 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* getelementptr inbounds ([45 x i8], [45 x i8]* @.str.17, i64 0, i64 0))
          to label %invoke.cont85 unwind label %lpad13

invoke.cont85:                                    ; preds = %if.else84
  %call88 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* nonnull %call86, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* nonnull @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
          to label %cleanup unwind label %lpad13

cleanup:                                          ; preds = %for.inc78, %for.inc, %for.cond60.preheader, %for.cond.preheader, %invoke.cont85, %invoke.cont22, %invoke.cont14
  %retval.0 = phi i32 [ 1, %invoke.cont14 ], [ 1, %invoke.cont22 ], [ 1, %invoke.cont85 ], [ 0, %for.cond.preheader ], [ 0, %for.cond60.preheader ], [ 0, %for.inc ], [ 0, %for.inc78 ]
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %5) #22
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %3) #22
  call void @_ZN11commandLineD2Ev(%struct.commandLine* nonnull %P) #22
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %0) #22
  ret i32 %retval.0

ehcleanup95:                                      ; preds = %lpad13, %lpad39, %lpad32, %lpad70, %lpad57, %lpad8
  %.sink162 = phi { i8*, i32 } [ %22, %lpad13 ], [ %32, %lpad39 ], [ %28, %lpad32 ], [ %41, %lpad70 ], [ %37, %lpad57 ], [ %21, %lpad8 ]
  %42 = extractvalue { i8*, i32 } %.sink162, 0
  %43 = extractvalue { i8*, i32 } %.sink162, 1
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %5) #22
  br label %ehcleanup97

ehcleanup97:                                      ; preds = %ehcleanup95, %lpad6
  %ehselector.slot.5 = phi i32 [ %43, %ehcleanup95 ], [ %20, %lpad6 ]
  %exn.slot.5 = phi i8* [ %42, %ehcleanup95 ], [ %19, %lpad6 ]
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %3) #22
  br label %ehcleanup99

ehcleanup99:                                      ; preds = %ehcleanup97, %lpad4
  %ehselector.slot.6 = phi i32 [ %ehselector.slot.5, %ehcleanup97 ], [ %17, %lpad4 ]
  %exn.slot.6 = phi i8* [ %exn.slot.5, %ehcleanup97 ], [ %16, %lpad4 ]
  call void @_ZN11commandLineD2Ev(%struct.commandLine* nonnull %P) #22
  br label %ehcleanup103

ehcleanup103:                                     ; preds = %ehcleanup99, %ehcleanup
  %ehselector.slot.7 = phi i32 [ %ehselector.slot.6, %ehcleanup99 ], [ %ehselector.slot.0, %ehcleanup ]
  %exn.slot.7 = phi i8* [ %exn.slot.6, %ehcleanup99 ], [ %exn.slot.0, %ehcleanup ]
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %0) #22
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.7, 0
  %lpad.val105 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.7, 1
  resume { i8*, i32 } %lpad.val105

; CHECK: ehcleanup103:
; CHECK: resume { i8*, i32 } %lpad.val105
}

; Function Attrs: inaccessiblememonly nounwind
declare token @llvm.syncregion.start() #5

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #6

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #6

; Function Attrs: inaccessiblememonly nounwind
declare token @llvm.taskframe.create() #5

; Function Attrs: inaccessiblememonly nounwind
declare void @llvm.taskframe.use(token) #5

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: inlinehint nounwind uwtable
declare dso_local void @_ZN11commandLineD2Ev(%struct.commandLine* %this) unnamed_addr #7

; Function Attrs: nounwind uwtable
declare dso_local void @_ZNSaIcEC2Ev(%"class.std::allocator"* %this) unnamed_addr #4

; Function Attrs: uwtable
declare dso_local void @_Z15quickSortSerialIdSt4lessIdEiEvPT_T1_T0_(double* %A, i32 %n) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local { double*, double* } @_Z5splitIdSt4lessIdEiESt4pairIPT_S4_ES4_T1_T0_(double* %A, i32 %n) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_Z15quickSortSerialIPc7strLessiEvPT_T1_T0_(i8** %A, i32 %n) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local { i8**, i8** } @_Z5splitIPc7strLessiESt4pairIPT_S4_ES4_T1_T0_(i8** %A, i32 %n) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_Z15quickSortSerialIPc7strLesslEvPT_T1_T0_(i8** %A, i64 %n) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local { i8**, i8** } @_Z5splitIPc7strLesslESt4pairIPT_S4_ES4_T1_T0_(i8** %A, i64 %n) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_Z15quickSortSerialIdSt4lessIdElEvPT_T1_T0_(double* %A, i64 %n) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local { double*, double* } @_Z5splitIdSt4lessIdElESt4pairIPT_S4_ES4_T1_T0_(double* %A, i64 %n) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local { i8*, i8* } @_ZN11commandLine11IOFileNamesEv(%struct.commandLine* %this) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN11commandLineC2EiPPcNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%struct.commandLine* %this, i32 %_c, i8** %_v, %"class.std::__cxx11::basic_string"* %_cl) unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN7benchIO20readSequenceFromFileEPc(%"struct.benchIO::seqData"* noalias sret %agg.result, i8* %fileName) local_unnamed_addr #0

; Function Attrs: nounwind uwtable
declare dso_local void @_ZNSaIcED2Ev(%"class.std::allocator"* %this) unnamed_addr #4

; Function Attrs: uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* %this, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* %__pf) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEi(%"class.std::basic_ostream"*, i32) local_unnamed_addr #1

; Function Attrs: uwtable
declare dso_local void @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_(%"class.std::__cxx11::basic_string"* %this, i8* %__s, %"class.std::allocator"* dereferenceable(1) %__a) unnamed_addr #0

; Function Attrs: nounwind uwtable
declare dso_local void @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev(%"class.std::__cxx11::basic_string"* %this) unnamed_addr #4

; Function Attrs: inlinehint uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_(%"class.std::basic_ostream"* dereferenceable(272) %__os) #9

; Function Attrs: inlinehint uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* dereferenceable(272) %__out, i8* %__s) local_unnamed_addr #9

; Function Attrs: noreturn nounwind
declare dso_local void @abort() local_unnamed_addr #10

; Function Attrs: nofree nounwind readonly
declare dso_local i32 @strcmp(i8* nocapture, i8* nocapture) local_unnamed_addr #16

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nofree nounwind }
attributes #4 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { inaccessiblememonly nounwind }
attributes #6 = { argmemonly nounwind }
attributes #7 = { inlinehint nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { inlinehint uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { norecurse nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #12 = { nounwind readnone speculatable }
attributes #13 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #14 = { inlinehint nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { norecurse uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #17 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #18 = { noinline noreturn nounwind }
attributes #19 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #20 = { argmemonly nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #21 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #22 = { nounwind }
attributes #23 = { noreturn nounwind }
attributes #24 = { builtin }
attributes #25 = { nounwind readonly }
attributes #26 = { noreturn }

!2 = !{!3, !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
!5 = distinct !{!5, !6}
!6 = !{!"tapir.loop.spawn.strategy", i32 1}
!7 = !{!8, !8, i64 0}
!8 = !{!"bool", !3, i64 0}
!9 = distinct !{!9, !6}
!10 = !{!11, !11, i64 0}
!11 = !{!"long", !3, i64 0}
!12 = !{!13, !13, i64 0}
!13 = !{!"any pointer", !3, i64 0}
!14 = distinct !{!14, !6}
!15 = !{!16, !11, i64 0}
!16 = !{!"_ZTSN7benchIO5wordsE", !11, i64 0, !13, i64 8, !11, i64 16, !13, i64 24}
!17 = !{!16, !13, i64 8}
!18 = !{!16, !11, i64 16}
!19 = !{!16, !13, i64 24}
!20 = !{!21, !21, i64 0}
!21 = !{!"vtable pointer", !4, i64 0}
!22 = distinct !{!22, !6}
!23 = !{!24, !11, i64 0}
!24 = !{!"_ZTSSt4fposI11__mbstate_tE", !11, i64 0, !25, i64 8}
!25 = !{!"_ZTS11__mbstate_t", !26, i64 0, !3, i64 4}
!26 = !{!"int", !3, i64 0}
!27 = distinct !{!27, !6}
!28 = !{!29, !13, i64 0}
!29 = !{!"_ZTS4_seqIcE", !13, i64 0, !11, i64 8}
!30 = !{!29, !11, i64 8}
!31 = !{!26, !26, i64 0}
!32 = distinct !{!32, !6}
!33 = !{!34, !34, i64 0}
!34 = !{!"double", !3, i64 0}
!35 = distinct !{!35, !6}
!36 = distinct !{!36, !6}
!37 = !{!38, !26, i64 0}
!38 = !{!"_ZTSSt4pairIiiE", !26, i64 0, !26, i64 4}
!39 = !{!38, !26, i64 4}
!40 = distinct !{!40, !6}
!41 = !{!42, !13, i64 0}
!42 = !{!"_ZTSSt4pairIPciE", !13, i64 0, !26, i64 8}
!43 = !{!42, !26, i64 8}
!44 = distinct !{!44, !6}
!45 = !{!46, !13, i64 0}
!46 = !{!"_ZTSN7benchIO7seqDataE", !13, i64 0, !11, i64 8, !47, i64 16, !13, i64 24}
!47 = !{!"_ZTSN7benchIO11elementTypeE", !3, i64 0}
!48 = !{!46, !11, i64 8}
!49 = !{!46, !47, i64 16}
!50 = !{!46, !13, i64 24}
!51 = !{!52, !26, i64 0}
!52 = !{!"_ZTS11commandLine", !26, i64 0, !13, i64 8, !53, i64 16}
!53 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", !54, i64 0, !11, i64 8, !3, i64 16}
!54 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_Alloc_hiderE", !13, i64 0}
!55 = !{!52, !13, i64 8}
!56 = !{!54, !13, i64 0}
!57 = !{!53, !13, i64 0}
!58 = !{!53, !11, i64 8}
!59 = !{!60, !13, i64 0}
!60 = !{!"_ZTSSt4pairIPcS0_E", !13, i64 0, !13, i64 8}
!61 = !{!60, !13, i64 8}
!62 = !{!63, !65, i64 32}
!63 = !{!"_ZTSSt8ios_base", !11, i64 8, !11, i64 16, !64, i64 24, !65, i64 28, !65, i64 32, !13, i64 40, !66, i64 48, !3, i64 64, !26, i64 192, !13, i64 200, !67, i64 208}
!64 = !{!"_ZTSSt13_Ios_Fmtflags", !3, i64 0}
!65 = !{!"_ZTSSt12_Ios_Iostate", !3, i64 0}
!66 = !{!"_ZTSNSt8ios_base6_WordsE", !13, i64 0, !11, i64 8}
!67 = !{!"_ZTSSt6locale", !13, i64 0}
!68 = !{!69, !13, i64 240}
!69 = !{!"_ZTSSt9basic_iosIcSt11char_traitsIcEE", !13, i64 216, !3, i64 224, !8, i64 225, !13, i64 232, !13, i64 240, !13, i64 248, !13, i64 256}
!70 = !{!71, !3, i64 56}
!71 = !{!"_ZTSSt5ctypeIcE", !13, i64 16, !8, i64 24, !13, i64 32, !13, i64 40, !13, i64 48, !3, i64 56, !3, i64 57, !3, i64 313, !3, i64 569}
!72 = distinct !{!72, !6}
!73 = distinct !{!73, !6}
!74 = !{i8 0, i8 2}
!75 = !{!76, !13, i64 0}
!76 = !{!"_ZTS4_seqIlE", !13, i64 0, !11, i64 8}
!77 = !{!76, !11, i64 8}
!78 = !{!79, !13, i64 0}
!79 = !{!"_ZTSN8sequence4getAIllEE", !13, i64 0}
!80 = distinct !{!80, !6}
!81 = distinct !{!81, !6}
!82 = !{!69, !13, i64 216}
!83 = !{!69, !3, i64 224}
!84 = !{!69, !8, i64 225}
!85 = !{!86, !11, i64 8}
!86 = !{!"_ZTSSi", !11, i64 8}
!87 = !{!88, !13, i64 0}
!88 = !{!"_ZTSSt4pairIPdS0_E", !13, i64 0, !13, i64 8}
!89 = !{!88, !13, i64 8}
!90 = !{!91, !13, i64 0}
!91 = !{!"_ZTSSt4pairIPPcS1_E", !13, i64 0, !13, i64 8}
!92 = !{!91, !13, i64 8}
