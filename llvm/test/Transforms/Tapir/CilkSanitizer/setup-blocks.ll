; RUN: opt < %s -csan -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-CSAN
; RUN: opt < %s -aa-pipeline=default -passes='cilksan' -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-CSAN
; RUN: opt < %s -csi -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-CSI
; RUN: opt < %s -passes='csi' -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-CSI

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
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
%"class.std::basic_ifstream" = type { %"class.std::basic_istream.base", %"class.std::basic_filebuf", %"class.std::basic_ios" }
%"class.std::basic_istream.base" = type { i32 (...)**, i64 }
%"class.std::basic_filebuf" = type { %"class.std::basic_streambuf", %union.pthread_mutex_t, %"class.std::__basic_file", i32, %struct.__mbstate_t, %struct.__mbstate_t, %struct.__mbstate_t, i8*, i64, i8, i8, i8, i8, i8*, i8*, i8, %"class.std::codecvt"*, i8*, i64, i8*, i8* }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%"class.std::__basic_file" = type <{ %struct._IO_FILE*, i8, [7 x i8] }>
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt*, %struct._IO_wide_data*, %struct._IO_FILE*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type opaque
%struct._IO_codecvt = type opaque
%struct._IO_wide_data = type opaque
%struct.__mbstate_t = type { i32, %union.anon }
%union.anon = type { i32 }
%"class.std::codecvt" = type { %"class.std::__codecvt_abstract_base.base", %struct.__locale_struct* }
%"class.std::__codecvt_abstract_base.base" = type { %"class.std::locale::facet.base" }
%"class.std::basic_istream" = type { i32 (...)**, i64, %"class.std::basic_ios" }
%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i64, %union.anon.0 }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider" = type { i8* }
%union.anon.0 = type { i64, [8 x i8] }
%"class.std::basic_fstream" = type { %"class.std::basic_iostream.base", %"class.std::basic_filebuf", %"class.std::basic_ios" }
%"class.std::basic_iostream.base" = type { %"class.std::basic_istream.base", %"class.std::basic_ostream.base" }
%"class.std::basic_ostream.base" = type { i32 (...)** }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@_ZSt4cerr = external dso_local global %"class.std::basic_ostream", align 8
@.str = private unnamed_addr constant [6 x i8] c"File \00", align 1
@.str.1 = private unnamed_addr constant [34 x i8] c" could not be opened! Aborting...\00", align 1
@.str.2 = private unnamed_addr constant [7 x i8] c"matrix\00", align 1
@.str.3 = private unnamed_addr constant [55 x i8] c"Currently works only with 'matrix' option, aborting...\00", align 1
@.str.4 = private unnamed_addr constant [11 x i8] c"coordinate\00", align 1
@.str.5 = private unnamed_addr constant [59 x i8] c"Currently works only with 'coordinate' option, aborting...\00", align 1
@.str.7 = private unnamed_addr constant [56 x i8] c"Currently works only with 'pattern' format, aborting...\00", align 1
@.str.8 = private unnamed_addr constant [10 x i8] c"symmetric\00", align 1
@.str.9 = private unnamed_addr constant [14 x i8] c"n[0] == n_col\00", align 1
@.str.10 = private unnamed_addr constant [20 x i8] c"../src/fglt_mtx.cpp\00", align 1
@__PRETTY_FUNCTION__._Z7readMTXPPmS0_S_S_PKc = private unnamed_addr constant [86 x i8] c"void readMTX(mwIndex **, mwIndex **, mwSize *const, mwSize *const, const char *const)\00", align 1
@.str.11 = private unnamed_addr constant [21 x i8] c"\22Node id (0-based)\22,\00", align 1
@.str.12 = private unnamed_addr constant [20 x i8] c"\22[0] vertex (==1)\22,\00", align 1
@.str.13 = private unnamed_addr constant [14 x i8] c"\22[1] degree\22,\00", align 1
@.str.14 = private unnamed_addr constant [14 x i8] c"\22[2] 2-path\22,\00", align 1
@.str.15 = private unnamed_addr constant [14 x i8] c"\22[3] bifork\22,\00", align 1
@.str.16 = private unnamed_addr constant [15 x i8] c"\22[4] 3-cycle\22,\00", align 1
@.str.17 = private unnamed_addr constant [19 x i8] c"\22[5] 3-path, end\22,\00", align 1
@.str.18 = private unnamed_addr constant [24 x i8] c"\22[6] 3-path, interior\22,\00", align 1
@.str.19 = private unnamed_addr constant [18 x i8] c"\22[7] claw, leaf\22,\00", align 1
@.str.20 = private unnamed_addr constant [18 x i8] c"\22[8] claw, root\22,\00", align 1
@.str.21 = private unnamed_addr constant [19 x i8] c"\22[9] paw, handle\22,\00", align 1
@.str.22 = private unnamed_addr constant [18 x i8] c"\22[10] paw, base\22,\00", align 1
@.str.23 = private unnamed_addr constant [20 x i8] c"\22[11] paw, center\22,\00", align 1
@.str.24 = private unnamed_addr constant [16 x i8] c"\22[12] 4-cycle\22,\00", align 1
@.str.25 = private unnamed_addr constant [26 x i8] c"\22[13] diamond, off-cord\22,\00", align 1
@.str.26 = private unnamed_addr constant [25 x i8] c"\22[14] diamond, on-cord\22,\00", align 1
@.str.27 = private unnamed_addr constant [16 x i8] c"\22[15] 4-clique\22\00", align 1
@.str.28 = private unnamed_addr constant [2 x i8] c",\00", align 1
@.str.29 = private unnamed_addr constant [10 x i8] c"graph.mtx\00", align 1
@_ZSt4cout = external dso_local global %"class.std::basic_ostream", align 8
@.str.30 = private unnamed_addr constant [41 x i8] c"No filename provided, using 'graph.mtx'.\00", align 1
@.str.31 = private unnamed_addr constant [24 x i8] c"Using graph stored in '\00", align 1
@.str.32 = private unnamed_addr constant [3 x i8] c"'.\00", align 1
@.str.33 = private unnamed_addr constant [40 x i8] c"Initiating fast graphlet transform for'\00", align 1
@.str.34 = private unnamed_addr constant [9 x i8] c"' using \00", align 1
@.str.35 = private unnamed_addr constant [10 x i8] c" threads.\00", align 1
@.str.36 = private unnamed_addr constant [68 x i8] c"Computation complete, outputting frequency counts to 'freq_net.csv'\00", align 1
@.str.37 = private unnamed_addr constant [13 x i8] c"freq_net.csv\00", align 1
@.str.38 = private unnamed_addr constant [25 x i8] c"Finished, cleaning up...\00", align 1
@_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE = external unnamed_addr constant [4 x i8*], align 8
@_ZTTSt13basic_fstreamIcSt11char_traitsIcEE = external unnamed_addr constant [10 x i8*], align 8

declare dso_local void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"*) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init"*) unnamed_addr #1

; Function Attrs: nofree nounwind
declare dso_local i32 @__cxa_atexit(void (i8*)*, i8*, i8*) local_unnamed_addr #2

; Function Attrs: uwtable
define dso_local void @_Z7readMTXPPmS0_S_S_PKc(i64** nocapture %row, i64** nocapture %col, i64* %n, i64* %m, i8* %filename) local_unnamed_addr #3 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
invoke.cont:
  %n_col = alloca i64, align 8
  %mmx = alloca [20 x i8], align 16
  %b1 = alloca [20 x i8], align 16
  %b2 = alloca [20 x i8], align 16
  %b3 = alloca [20 x i8], align 16
  %b4 = alloca [20 x i8], align 16
  %fin = alloca %"class.std::basic_ifstream", align 8
  %0 = bitcast i64* %n_col to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %0) #14
  %1 = getelementptr inbounds [20 x i8], [20 x i8]* %mmx, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %1) #14
  %2 = getelementptr inbounds [20 x i8], [20 x i8]* %b1, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %2) #14
  %3 = getelementptr inbounds [20 x i8], [20 x i8]* %b2, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %3) #14
  %4 = getelementptr inbounds [20 x i8], [20 x i8]* %b3, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %4) #14
  %5 = getelementptr inbounds [20 x i8], [20 x i8]* %b4, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %5) #14
  %6 = bitcast %"class.std::basic_ifstream"* %fin to i8*
  call void @llvm.lifetime.start.p0i8(i64 520, i8* nonnull %6) #14
  call void @_ZNSt14basic_ifstreamIcSt11char_traitsIcEEC1EPKcSt13_Ios_Openmode(%"class.std::basic_ifstream"* nonnull %fin, i8* %filename, i32 8)
  %7 = bitcast %"class.std::basic_ifstream"* %fin to i8**
  %vtable = load i8*, i8** %7, align 8, !tbaa !2
  %vbase.offset.ptr = getelementptr i8, i8* %vtable, i64 -24
  %8 = bitcast i8* %vbase.offset.ptr to i64*
  %vbase.offset = load i64, i64* %8, align 8
  %add.ptr = getelementptr inbounds i8, i8* %6, i64 %vbase.offset
  %_M_streambuf_state.i.i = getelementptr inbounds i8, i8* %add.ptr, i64 32
  %9 = bitcast i8* %_M_streambuf_state.i.i to i32*
  %10 = load i32, i32* %9, align 8, !tbaa !5
  %and.i.i = and i32 %10, 5
  %cmp.i = icmp eq i32 %and.i.i, 0
  br i1 %cmp.i, label %if.end, label %if.then

if.then:                                          ; preds = %invoke.cont
  %call1.i308 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cerr, i8* nonnull getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i64 0, i64 0), i64 5)
          to label %invoke.cont1 unwind label %lpad.loopexit.split-lp

invoke.cont1:                                     ; preds = %if.then
  %tobool.i = icmp eq i8* %filename, null
  br i1 %tobool.i, label %if.then.i, label %if.else.i

if.then.i:                                        ; preds = %invoke.cont1
  %vtable.i = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8**), align 8, !tbaa !2
  %vbase.offset.ptr.i = getelementptr i8, i8* %vtable.i, i64 -24
  %11 = bitcast i8* %vbase.offset.ptr.i to i64*
  %vbase.offset.i = load i64, i64* %11, align 8
  %add.ptr.i = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8*), i64 %vbase.offset.i
  %12 = bitcast i8* %add.ptr.i to %"class.std::basic_ios"*
  %_M_streambuf_state.i.i.i = getelementptr inbounds i8, i8* %add.ptr.i, i64 32
  %13 = bitcast i8* %_M_streambuf_state.i.i.i to i32*
  %14 = load i32, i32* %13, align 8, !tbaa !5
  %or.i.i.i = or i32 %14, 1
  invoke void @_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate(%"class.std::basic_ios"* nonnull %12, i32 %or.i.i.i)
          to label %invoke.cont3 unwind label %lpad.loopexit.split-lp

if.else.i:                                        ; preds = %invoke.cont1
  %call.i.i309 = call i64 @strlen(i8* nonnull dereferenceable(1) %filename) #14
  %call1.i310 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cerr, i8* nonnull %filename, i64 %call.i.i309)
          to label %invoke.cont3 unwind label %lpad.loopexit.split-lp

invoke.cont3:                                     ; preds = %if.then.i, %if.else.i
  %call1.i315 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cerr, i8* nonnull getelementptr inbounds ([34 x i8], [34 x i8]* @.str.1, i64 0, i64 0), i64 33)
          to label %invoke.cont5 unwind label %lpad.loopexit.split-lp

invoke.cont5:                                     ; preds = %invoke.cont3
  %vtable.i318 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8**), align 8, !tbaa !2
  %vbase.offset.ptr.i319 = getelementptr i8, i8* %vtable.i318, i64 -24
  %15 = bitcast i8* %vbase.offset.ptr.i319 to i64*
  %vbase.offset.i320 = load i64, i64* %15, align 8
  %add.ptr.i321 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8*), i64 %vbase.offset.i320
  %_M_ctype.i = getelementptr inbounds i8, i8* %add.ptr.i321, i64 240
  %16 = bitcast i8* %_M_ctype.i to %"class.std::ctype"**
  %17 = load %"class.std::ctype"*, %"class.std::ctype"** %16, align 8, !tbaa !15
  %tobool.i485 = icmp eq %"class.std::ctype"* %17, null
  br i1 %tobool.i485, label %if.then.i486, label %call.i.noexc425

if.then.i486:                                     ; preds = %invoke.cont5
  invoke void @_ZSt16__throw_bad_castv() #15
          to label %.noexc488 unwind label %lpad.loopexit.split-lp

.noexc488:                                        ; preds = %if.then.i486
  unreachable

call.i.noexc425:                                  ; preds = %invoke.cont5
  %_M_widen_ok.i = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %17, i64 0, i32 8
  %18 = load i8, i8* %_M_widen_ok.i, align 8, !tbaa !18
  %tobool.i428 = icmp eq i8 %18, 0
  br i1 %tobool.i428, label %if.end.i, label %if.then.i429

if.then.i429:                                     ; preds = %call.i.noexc425
  %arrayidx.i = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %17, i64 0, i32 9, i64 10
  %19 = load i8, i8* %arrayidx.i, align 1, !tbaa !20
  br label %call.i.noexc

if.end.i:                                         ; preds = %call.i.noexc425
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %17)
          to label %.noexc431 unwind label %lpad.loopexit.split-lp

.noexc431:                                        ; preds = %if.end.i
  %20 = bitcast %"class.std::ctype"* %17 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i430 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %20, align 8, !tbaa !2
  %vfn.i = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i430, i64 6
  %21 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i, align 8
  %call.i433 = invoke signext i8 %21(%"class.std::ctype"* nonnull %17, i8 signext 10)
          to label %call.i.noexc unwind label %lpad.loopexit.split-lp

call.i.noexc:                                     ; preds = %.noexc431, %if.then.i429
  %retval.0.i = phi i8 [ %19, %if.then.i429 ], [ %call.i433, %.noexc431 ]
  %call1.i324 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull @_ZSt4cerr, i8 signext %retval.0.i)
          to label %call1.i.noexc323 unwind label %lpad.loopexit.split-lp

call1.i.noexc323:                                 ; preds = %call.i.noexc
  %call.i327 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i324)
          to label %invoke.cont7 unwind label %lpad.loopexit.split-lp

invoke.cont7:                                     ; preds = %call1.i.noexc323
  call void @exit(i32 1) #16
  unreachable

lpad.loopexit:                                    ; preds = %while.cond, %while.body
  %lpad.loopexit504 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup201

lpad.loopexit.split-lp:                           ; preds = %if.end, %invoke.cont9, %invoke.cont12, %invoke.cont15, %invoke.cont18, %if.end48, %if.then, %if.then.i, %if.else.i, %invoke.cont3, %call.i.noexc, %call1.i.noexc323, %if.then25, %call.i.noexc340, %call1.i.noexc342, %if.then34, %call.i.noexc361, %call1.i.noexc363, %if.then43, %call.i.noexc382, %call1.i.noexc384, %while.end, %invoke.cont61, %invoke.cont63, %if.end.i, %.noexc431, %if.end.i445, %.noexc447, %if.end.i462, %.noexc464, %if.end.i479, %.noexc481, %if.then.i486, %if.then.i490, %if.then.i495, %if.then.i500
  %lpad.loopexit.split-lp505 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup201

if.end:                                           ; preds = %invoke.cont
  %22 = bitcast %"class.std::basic_ifstream"* %fin to %"class.std::basic_istream"*
  %call10 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZStrsIcSt11char_traitsIcEERSt13basic_istreamIT_T0_ES6_PS3_(%"class.std::basic_istream"* nonnull dereferenceable(280) %22, i8* nonnull %1)
          to label %invoke.cont9 unwind label %lpad.loopexit.split-lp

invoke.cont9:                                     ; preds = %if.end
  %call13 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZStrsIcSt11char_traitsIcEERSt13basic_istreamIT_T0_ES6_PS3_(%"class.std::basic_istream"* nonnull dereferenceable(280) %call10, i8* nonnull %2)
          to label %invoke.cont12 unwind label %lpad.loopexit.split-lp

invoke.cont12:                                    ; preds = %invoke.cont9
  %call16 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZStrsIcSt11char_traitsIcEERSt13basic_istreamIT_T0_ES6_PS3_(%"class.std::basic_istream"* nonnull dereferenceable(280) %call13, i8* nonnull %3)
          to label %invoke.cont15 unwind label %lpad.loopexit.split-lp

invoke.cont15:                                    ; preds = %invoke.cont12
  %call19 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZStrsIcSt11char_traitsIcEERSt13basic_istreamIT_T0_ES6_PS3_(%"class.std::basic_istream"* nonnull dereferenceable(280) %call16, i8* nonnull %4)
          to label %invoke.cont18 unwind label %lpad.loopexit.split-lp

invoke.cont18:                                    ; preds = %invoke.cont15
  %call22 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZStrsIcSt11char_traitsIcEERSt13basic_istreamIT_T0_ES6_PS3_(%"class.std::basic_istream"* nonnull dereferenceable(280) %call19, i8* nonnull %5)
          to label %invoke.cont21 unwind label %lpad.loopexit.split-lp

invoke.cont21:                                    ; preds = %invoke.cont18
  %bcmp = call i32 @bcmp(i8* nonnull dereferenceable(7) %2, i8* nonnull dereferenceable(7) getelementptr inbounds ([7 x i8], [7 x i8]* @.str.2, i64 0, i64 0), i64 7)
  %tobool = icmp eq i32 %bcmp, 0
  br i1 %tobool, label %if.end30, label %if.then25

if.then25:                                        ; preds = %invoke.cont21
  %call1.i331 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cerr, i8* nonnull getelementptr inbounds ([55 x i8], [55 x i8]* @.str.3, i64 0, i64 0), i64 54)
          to label %invoke.cont26 unwind label %lpad.loopexit.split-lp

invoke.cont26:                                    ; preds = %if.then25
  %vtable.i336 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8**), align 8, !tbaa !2
  %vbase.offset.ptr.i337 = getelementptr i8, i8* %vtable.i336, i64 -24
  %23 = bitcast i8* %vbase.offset.ptr.i337 to i64*
  %vbase.offset.i338 = load i64, i64* %23, align 8
  %add.ptr.i339 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8*), i64 %vbase.offset.i338
  %_M_ctype.i434 = getelementptr inbounds i8, i8* %add.ptr.i339, i64 240
  %24 = bitcast i8* %_M_ctype.i434 to %"class.std::ctype"**
  %25 = load %"class.std::ctype"*, %"class.std::ctype"** %24, align 8, !tbaa !15
  %tobool.i489 = icmp eq %"class.std::ctype"* %25, null
  br i1 %tobool.i489, label %if.then.i490, label %call.i.noexc435

if.then.i490:                                     ; preds = %invoke.cont26
  invoke void @_ZSt16__throw_bad_castv() #15
          to label %.noexc492 unwind label %lpad.loopexit.split-lp

.noexc492:                                        ; preds = %if.then.i490
  unreachable

call.i.noexc435:                                  ; preds = %invoke.cont26
  %_M_widen_ok.i439 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %25, i64 0, i32 8
  %26 = load i8, i8* %_M_widen_ok.i439, align 8, !tbaa !18
  %tobool.i440 = icmp eq i8 %26, 0
  br i1 %tobool.i440, label %if.end.i445, label %if.then.i442

if.then.i442:                                     ; preds = %call.i.noexc435
  %arrayidx.i441 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %25, i64 0, i32 9, i64 10
  %27 = load i8, i8* %arrayidx.i441, align 1, !tbaa !20
  br label %call.i.noexc340

if.end.i445:                                      ; preds = %call.i.noexc435
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %25)
          to label %.noexc447 unwind label %lpad.loopexit.split-lp

.noexc447:                                        ; preds = %if.end.i445
  %28 = bitcast %"class.std::ctype"* %25 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i443 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %28, align 8, !tbaa !2
  %vfn.i444 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i443, i64 6
  %29 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i444, align 8
  %call.i449 = invoke signext i8 %29(%"class.std::ctype"* nonnull %25, i8 signext 10)
          to label %call.i.noexc340 unwind label %lpad.loopexit.split-lp

call.i.noexc340:                                  ; preds = %.noexc447, %if.then.i442
  %retval.0.i446 = phi i8 [ %27, %if.then.i442 ], [ %call.i449, %.noexc447 ]
  %call1.i343 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull @_ZSt4cerr, i8 signext %retval.0.i446)
          to label %call1.i.noexc342 unwind label %lpad.loopexit.split-lp

call1.i.noexc342:                                 ; preds = %call.i.noexc340
  %call.i347 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i343)
          to label %invoke.cont28 unwind label %lpad.loopexit.split-lp

invoke.cont28:                                    ; preds = %call1.i.noexc342
  call void @exit(i32 1) #16
  unreachable

if.end30:                                         ; preds = %invoke.cont21
  %bcmp306 = call i32 @bcmp(i8* nonnull dereferenceable(11) %3, i8* nonnull dereferenceable(11) getelementptr inbounds ([11 x i8], [11 x i8]* @.str.4, i64 0, i64 0), i64 11)
  %tobool33 = icmp eq i32 %bcmp306, 0
  br i1 %tobool33, label %if.end39, label %if.then34

if.then34:                                        ; preds = %if.end30
  %call1.i352 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cerr, i8* nonnull getelementptr inbounds ([59 x i8], [59 x i8]* @.str.5, i64 0, i64 0), i64 58)
          to label %invoke.cont35 unwind label %lpad.loopexit.split-lp

invoke.cont35:                                    ; preds = %if.then34
  %vtable.i357 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8**), align 8, !tbaa !2
  %vbase.offset.ptr.i358 = getelementptr i8, i8* %vtable.i357, i64 -24
  %30 = bitcast i8* %vbase.offset.ptr.i358 to i64*
  %vbase.offset.i359 = load i64, i64* %30, align 8
  %add.ptr.i360 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8*), i64 %vbase.offset.i359
  %_M_ctype.i451 = getelementptr inbounds i8, i8* %add.ptr.i360, i64 240
  %31 = bitcast i8* %_M_ctype.i451 to %"class.std::ctype"**
  %32 = load %"class.std::ctype"*, %"class.std::ctype"** %31, align 8, !tbaa !15
  %tobool.i494 = icmp eq %"class.std::ctype"* %32, null
  br i1 %tobool.i494, label %if.then.i495, label %call.i.noexc452

if.then.i495:                                     ; preds = %invoke.cont35
  invoke void @_ZSt16__throw_bad_castv() #15
          to label %.noexc497 unwind label %lpad.loopexit.split-lp

.noexc497:                                        ; preds = %if.then.i495
  unreachable

call.i.noexc452:                                  ; preds = %invoke.cont35
  %_M_widen_ok.i456 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %32, i64 0, i32 8
  %33 = load i8, i8* %_M_widen_ok.i456, align 8, !tbaa !18
  %tobool.i457 = icmp eq i8 %33, 0
  br i1 %tobool.i457, label %if.end.i462, label %if.then.i459

if.then.i459:                                     ; preds = %call.i.noexc452
  %arrayidx.i458 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %32, i64 0, i32 9, i64 10
  %34 = load i8, i8* %arrayidx.i458, align 1, !tbaa !20
  br label %call.i.noexc361

if.end.i462:                                      ; preds = %call.i.noexc452
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %32)
          to label %.noexc464 unwind label %lpad.loopexit.split-lp

.noexc464:                                        ; preds = %if.end.i462
  %35 = bitcast %"class.std::ctype"* %32 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i460 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %35, align 8, !tbaa !2
  %vfn.i461 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i460, i64 6
  %36 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i461, align 8
  %call.i466 = invoke signext i8 %36(%"class.std::ctype"* nonnull %32, i8 signext 10)
          to label %call.i.noexc361 unwind label %lpad.loopexit.split-lp

call.i.noexc361:                                  ; preds = %.noexc464, %if.then.i459
  %retval.0.i463 = phi i8 [ %34, %if.then.i459 ], [ %call.i466, %.noexc464 ]
  %call1.i364 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull @_ZSt4cerr, i8 signext %retval.0.i463)
          to label %call1.i.noexc363 unwind label %lpad.loopexit.split-lp

call1.i.noexc363:                                 ; preds = %call.i.noexc361
  %call.i368 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i364)
          to label %invoke.cont37 unwind label %lpad.loopexit.split-lp

invoke.cont37:                                    ; preds = %call1.i.noexc363
  call void @exit(i32 1) #16
  unreachable

if.end39:                                         ; preds = %if.end30
  %37 = bitcast [20 x i8]* %b3 to i64*
  %lhsv = load i64, i64* %37, align 16
  %38 = icmp eq i64 %lhsv, 31088027509219696
  br i1 %38, label %if.end48, label %if.then43

if.then43:                                        ; preds = %if.end39
  %call1.i373 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cerr, i8* nonnull getelementptr inbounds ([56 x i8], [56 x i8]* @.str.7, i64 0, i64 0), i64 55)
          to label %invoke.cont44 unwind label %lpad.loopexit.split-lp

invoke.cont44:                                    ; preds = %if.then43
  %vtable.i378 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8**), align 8, !tbaa !2
  %vbase.offset.ptr.i379 = getelementptr i8, i8* %vtable.i378, i64 -24
  %39 = bitcast i8* %vbase.offset.ptr.i379 to i64*
  %vbase.offset.i380 = load i64, i64* %39, align 8
  %add.ptr.i381 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cerr to i8*), i64 %vbase.offset.i380
  %_M_ctype.i468 = getelementptr inbounds i8, i8* %add.ptr.i381, i64 240
  %40 = bitcast i8* %_M_ctype.i468 to %"class.std::ctype"**
  %41 = load %"class.std::ctype"*, %"class.std::ctype"** %40, align 8, !tbaa !15
  %tobool.i499 = icmp eq %"class.std::ctype"* %41, null
  br i1 %tobool.i499, label %if.then.i500, label %call.i.noexc469

if.then.i500:                                     ; preds = %invoke.cont44
  invoke void @_ZSt16__throw_bad_castv() #15
          to label %.noexc502 unwind label %lpad.loopexit.split-lp

.noexc502:                                        ; preds = %if.then.i500
  unreachable

call.i.noexc469:                                  ; preds = %invoke.cont44
  %_M_widen_ok.i473 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %41, i64 0, i32 8
  %42 = load i8, i8* %_M_widen_ok.i473, align 8, !tbaa !18
  %tobool.i474 = icmp eq i8 %42, 0
  br i1 %tobool.i474, label %if.end.i479, label %if.then.i476

if.then.i476:                                     ; preds = %call.i.noexc469
  %arrayidx.i475 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %41, i64 0, i32 9, i64 10
  %43 = load i8, i8* %arrayidx.i475, align 1, !tbaa !20
  br label %call.i.noexc382

if.end.i479:                                      ; preds = %call.i.noexc469
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %41)
          to label %.noexc481 unwind label %lpad.loopexit.split-lp

.noexc481:                                        ; preds = %if.end.i479
  %44 = bitcast %"class.std::ctype"* %41 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i477 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %44, align 8, !tbaa !2
  %vfn.i478 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i477, i64 6
  %45 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i478, align 8
  %call.i483 = invoke signext i8 %45(%"class.std::ctype"* nonnull %41, i8 signext 10)
          to label %call.i.noexc382 unwind label %lpad.loopexit.split-lp

call.i.noexc382:                                  ; preds = %.noexc481, %if.then.i476
  %retval.0.i480 = phi i8 [ %43, %if.then.i476 ], [ %call.i483, %.noexc481 ]
  %call1.i385 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull @_ZSt4cerr, i8 signext %retval.0.i480)
          to label %call1.i.noexc384 unwind label %lpad.loopexit.split-lp

call1.i.noexc384:                                 ; preds = %call.i.noexc382
  %call.i389 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i385)
          to label %invoke.cont46 unwind label %lpad.loopexit.split-lp

invoke.cont46:                                    ; preds = %call1.i.noexc384
  call void @exit(i32 1) #16
  unreachable

if.end48:                                         ; preds = %if.end39
  %bcmp307 = call i32 @bcmp(i8* nonnull dereferenceable(10) %5, i8* nonnull dereferenceable(10) getelementptr inbounds ([10 x i8], [10 x i8]* @.str.8, i64 0, i64 0), i64 10)
  %tobool51 = icmp eq i32 %bcmp307, 0
  %call56 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi6ignoreEli(%"class.std::basic_istream"* nonnull %22, i64 9223372036854775807, i32 10)
          to label %while.cond unwind label %lpad.loopexit.split-lp
; CHECK: if.end48:
; CHECK: invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi6ignoreEli(%"class.std::basic_istream"* nonnull %{{.+}}, i64 9223372036854775807, i32 10)
; CHECK-NEXT: to label %[[WHILE_COND_PREHEADER:.+]] unwind label %lpad.loopexit.split-lp

; CHECK: [[WHILE_COND_PREHEADER]]:
; CHECK-CSAN-NEXT: call void @__csan_after_call(
; CHECK-CSAN-NEXT: br label %while.cond
; CHECK-CSI-NEXT: call void @__csi_after_call(
; CHECK-CSI: br label %while.cond

while.cond:                                       ; preds = %if.end48, %while.body
  %call58 = invoke i32 @_ZNSi4peekEv(%"class.std::basic_istream"* nonnull %22)
          to label %invoke.cont57 unwind label %lpad.loopexit

; CHECK: while.cond:
; CHECK-CSAN-NOT: call void @__csan_after_call(
; CHECK-CSAN: call void @__csan_before_call(
; CHECK-CSI-NOT: call void @__csi_after_call(
; CHECK-CSI: call void @__csi_before_call(
; CHECK-NEXT: invoke i32 @_ZNSi4peekEv(%"class.std::basic_istream"* nonnull %{{.+}})

invoke.cont57:                                    ; preds = %while.cond
  %cmp = icmp eq i32 %call58, 37
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %invoke.cont57
  %call60 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi6ignoreEli(%"class.std::basic_istream"* nonnull %22, i64 2048, i32 10)
          to label %while.cond unwind label %lpad.loopexit

; CHECK: while.body:
; CHECK-CSAN: call void @__csan_before_call(
; CHECK-CSI: call void @__csi_before_call(
; CHECK-NEXT: invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi6ignoreEli(%"class.std::basic_istream"* nonnull %{{.+}}, i64 2048, i32 10)
; CHECK-NOT: to label %while.cond unwind label %lpad.loopexit

while.end:                                        ; preds = %invoke.cont57
  %call.i392 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractImEERSiRT_(%"class.std::basic_istream"* nonnull %22, i64* nonnull dereferenceable(8) %n)
          to label %invoke.cont61 unwind label %lpad.loopexit.split-lp

invoke.cont61:                                    ; preds = %while.end
  %call.i394 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractImEERSiRT_(%"class.std::basic_istream"* nonnull %call.i392, i64* nonnull dereferenceable(8) %n_col)
          to label %invoke.cont63 unwind label %lpad.loopexit.split-lp

invoke.cont63:                                    ; preds = %invoke.cont61
  %call.i397 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractImEERSiRT_(%"class.std::basic_istream"* nonnull %call.i394, i64* nonnull dereferenceable(8) %m)
          to label %invoke.cont66 unwind label %lpad.loopexit.split-lp

invoke.cont66:                                    ; preds = %invoke.cont63
  %46 = load i64, i64* %m, align 8, !tbaa !21
  %mul = zext i1 %tobool51 to i64
  %m_mat.0 = shl i64 %46, %mul
  %47 = load i64, i64* %n, align 8, !tbaa !21
  %48 = load i64, i64* %n_col, align 8, !tbaa !21
  %cmp74 = icmp eq i64 %47, %48
  br i1 %cmp74, label %cond.end, label %cond.false

cond.false:                                       ; preds = %invoke.cont66
  call void @__assert_fail(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.9, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str.10, i64 0, i64 0), i32 79, i8* getelementptr inbounds ([86 x i8], [86 x i8]* @__PRETTY_FUNCTION__._Z7readMTXPPmS0_S_S_PKc, i64 0, i64 0)) #16
  unreachable

cond.end:                                         ; preds = %invoke.cont66
  %mul75 = shl i64 %m_mat.0, 3
  %call76 = call noalias i8* @malloc(i64 %mul75) #14
  %49 = bitcast i8* %call76 to i64*
  %call78 = call noalias i8* @malloc(i64 %mul75) #14
  %50 = bitcast i8* %call78 to i64*
  %cmp80517 = icmp eq i64 %46, 0
  br i1 %cmp80517, label %for.cond.cleanup, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %cond.end
  br i1 %tobool51, label %for.body.us, label %for.body

for.body.us:                                      ; preds = %for.body.lr.ph, %for.inc.us
  %m_mat.1520.us = phi i64 [ %m_mat.2.us, %for.inc.us ], [ %m_mat.0, %for.body.lr.ph ]
  %l.0519.us = phi i64 [ %inc111.us, %for.inc.us ], [ 0, %for.body.lr.ph ]
  %k.0518.us = phi i64 [ %k.1.us, %for.inc.us ], [ 0, %for.body.lr.ph ]
  %arrayidx81.us = getelementptr inbounds i64, i64* %49, i64 %k.0518.us
  %call.i411.us = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractImEERSiRT_(%"class.std::basic_istream"* nonnull %22, i64* nonnull dereferenceable(8) %arrayidx81.us)
          to label %invoke.cont83.us unwind label %lpad82.us-lcssa.us

invoke.cont83.us:                                 ; preds = %for.body.us
  %arrayidx85.us = getelementptr inbounds i64, i64* %50, i64 %k.0518.us
  %call.i414.us = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractImEERSiRT_(%"class.std::basic_istream"* nonnull %call.i411.us, i64* nonnull dereferenceable(8) %arrayidx85.us)
          to label %invoke.cont86.us unwind label %lpad82.us-lcssa.us

invoke.cont86.us:                                 ; preds = %invoke.cont83.us
  %51 = load i64, i64* %arrayidx81.us, align 8, !tbaa !21
  %52 = load i64, i64* %arrayidx85.us, align 8, !tbaa !21
  %cmp92.us = icmp eq i64 %51, %52
  br i1 %cmp92.us, label %if.then93.us, label %if.else94.us

if.else94.us:                                     ; preds = %invoke.cont86.us
  %add.us = add i64 %k.0518.us, 1
  %arrayidx96.us = getelementptr inbounds i64, i64* %49, i64 %add.us
  store i64 %52, i64* %arrayidx96.us, align 8, !tbaa !21
  %arrayidx99.us = getelementptr inbounds i64, i64* %50, i64 %add.us
  store i64 %51, i64* %arrayidx99.us, align 8, !tbaa !21
  %add100.us = add i64 %k.0518.us, 2
  br label %for.inc.us

if.then93.us:                                     ; preds = %invoke.cont86.us
  %sub.us = add i64 %m_mat.1520.us, -2
  br label %for.inc.us

for.inc.us:                                       ; preds = %if.then93.us, %if.else94.us
  %k.1.us = phi i64 [ %k.0518.us, %if.then93.us ], [ %add100.us, %if.else94.us ]
  %m_mat.2.us = phi i64 [ %sub.us, %if.then93.us ], [ %m_mat.1520.us, %if.else94.us ]
  %inc111.us = add nuw i64 %l.0519.us, 1
  %53 = load i64, i64* %m, align 8, !tbaa !21
  %cmp80.us = icmp ult i64 %inc111.us, %53
  br i1 %cmp80.us, label %for.body.us, label %for.cond.cleanup

lpad82.us-lcssa.us:                               ; preds = %invoke.cont83.us, %for.body.us
  %lpad.us-lcssa.us = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup201

for.cond.cleanup:                                 ; preds = %invoke.cont86, %for.inc.us, %cond.end
  %m_mat.1.lcssa = phi i64 [ 0, %cond.end ], [ %m_mat.2.us, %for.inc.us ], [ %m_mat.2, %invoke.cont86 ]
  store i64 %m_mat.1.lcssa, i64* %m, align 8, !tbaa !21
  %mul114 = shl i64 %m_mat.1.lcssa, 3
  %call115 = call i8* @realloc(i8* %call76, i64 %mul114) #14
  %54 = bitcast i8* %call115 to i64*
  %55 = load i64, i64* %m, align 8, !tbaa !21
  %mul117 = shl i64 %55, 3
  %call118 = call i8* @realloc(i8* %call78, i64 %mul117) #14
  %56 = bitcast i8* %call118 to i64*
  %_M_filebuf.i = getelementptr inbounds %"class.std::basic_ifstream", %"class.std::basic_ifstream"* %fin, i64 0, i32 1
  %call.i408 = invoke %"class.std::basic_filebuf"* @_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv(%"class.std::basic_filebuf"* nonnull %_M_filebuf.i)
          to label %call.i.noexc407 unwind label %lpad119

call.i.noexc407:                                  ; preds = %for.cond.cleanup
  %tobool.i399 = icmp eq %"class.std::basic_filebuf"* %call.i408, null
  br i1 %tobool.i399, label %if.then.i406, label %invoke.cont120

if.then.i406:                                     ; preds = %call.i.noexc407
  %vtable.i400 = load i8*, i8** %7, align 8, !tbaa !2
  %vbase.offset.ptr.i401 = getelementptr i8, i8* %vtable.i400, i64 -24
  %57 = bitcast i8* %vbase.offset.ptr.i401 to i64*
  %vbase.offset.i402 = load i64, i64* %57, align 8
  %add.ptr.i403 = getelementptr inbounds i8, i8* %6, i64 %vbase.offset.i402
  %58 = bitcast i8* %add.ptr.i403 to %"class.std::basic_ios"*
  %_M_streambuf_state.i.i.i404 = getelementptr inbounds i8, i8* %add.ptr.i403, i64 32
  %59 = bitcast i8* %_M_streambuf_state.i.i.i404 to i32*
  %60 = load i32, i32* %59, align 8, !tbaa !5
  %or.i.i.i405 = or i32 %60, 4
  invoke void @_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate(%"class.std::basic_ios"* nonnull %58, i32 %or.i.i.i405)
          to label %invoke.cont120 unwind label %lpad119

for.body:                                         ; preds = %for.body.lr.ph, %invoke.cont86
  %m_mat.1520 = phi i64 [ %m_mat.2, %invoke.cont86 ], [ %m_mat.0, %for.body.lr.ph ]
  %l.0519 = phi i64 [ %inc111, %invoke.cont86 ], [ 0, %for.body.lr.ph ]
  %k.0518 = phi i64 [ %k.1, %invoke.cont86 ], [ 0, %for.body.lr.ph ]
  %arrayidx81 = getelementptr inbounds i64, i64* %49, i64 %k.0518
  %call.i411 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractImEERSiRT_(%"class.std::basic_istream"* nonnull %22, i64* nonnull dereferenceable(8) %arrayidx81)
          to label %invoke.cont83 unwind label %lpad82.us-lcssa

invoke.cont83:                                    ; preds = %for.body
  %arrayidx85 = getelementptr inbounds i64, i64* %50, i64 %k.0518
  %call.i414 = invoke dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractImEERSiRT_(%"class.std::basic_istream"* nonnull %call.i411, i64* nonnull dereferenceable(8) %arrayidx85)
          to label %invoke.cont86 unwind label %lpad82.us-lcssa

invoke.cont86:                                    ; preds = %invoke.cont83
  %61 = load i64, i64* %arrayidx81, align 8, !tbaa !21
  %62 = load i64, i64* %arrayidx85, align 8, !tbaa !21
  %cmp92 = icmp eq i64 %61, %62
  %not.cmp92 = xor i1 %cmp92, true
  %inc = zext i1 %not.cmp92 to i64
  %k.1 = add i64 %k.0518, %inc
  %sub107 = sext i1 %cmp92 to i64
  %m_mat.2 = add i64 %m_mat.1520, %sub107
  %inc111 = add nuw i64 %l.0519, 1
  %63 = load i64, i64* %m, align 8, !tbaa !21
  %cmp80 = icmp ult i64 %inc111, %63
  br i1 %cmp80, label %for.body, label %for.cond.cleanup

lpad82.us-lcssa:                                  ; preds = %for.body, %invoke.cont83
  %lpad.us-lcssa = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup201

invoke.cont120:                                   ; preds = %call.i.noexc407, %if.then.i406
  %64 = load i64, i64* %m, align 8, !tbaa !21
  %mul122 = shl i64 %64, 3
  %call123 = call noalias i8* @malloc(i64 %mul122) #14
  %65 = bitcast i64** %row to i8**
  store i8* %call123, i8** %65, align 8, !tbaa !22
  %66 = load i64, i64* %n, align 8, !tbaa !21
  %add126 = add i64 %66, 1
  %call127 = call noalias i8* @calloc(i64 %add126, i64 8) #14
  %67 = bitcast i64** %col to i8**
  store i8* %call127, i8** %67, align 8, !tbaa !22
  %cmp132515 = icmp eq i64 %64, 0
  %68 = bitcast i8* %call127 to i64*
  br i1 %cmp132515, label %for.cond143.preheader, label %for.body134.preheader

for.body134.preheader:                            ; preds = %invoke.cont120
  %xtraiter535 = and i64 %64, 1
  %69 = icmp eq i64 %64, 1
  br i1 %69, label %for.cond143.preheader.loopexit.unr-lcssa, label %for.body134.preheader.new

for.body134.preheader.new:                        ; preds = %for.body134.preheader
  %unroll_iter537 = sub i64 %64, %xtraiter535
  br label %for.body134

for.cond143.preheader.loopexit.unr-lcssa:         ; preds = %for.body134, %for.body134.preheader
  %l129.0516.unr = phi i64 [ 0, %for.body134.preheader ], [ %inc141.1, %for.body134 ]
  %lcmp.mod536 = icmp eq i64 %xtraiter535, 0
  br i1 %lcmp.mod536, label %for.cond143.preheader, label %for.body134.epil

for.body134.epil:                                 ; preds = %for.cond143.preheader.loopexit.unr-lcssa
  %arrayidx136.epil = getelementptr inbounds i64, i64* %56, i64 %l129.0516.unr
  %70 = load i64, i64* %arrayidx136.epil, align 8, !tbaa !21
  %sub137.epil = add i64 %70, -1
  %arrayidx138.epil = getelementptr inbounds i64, i64* %68, i64 %sub137.epil
  %71 = load i64, i64* %arrayidx138.epil, align 8, !tbaa !21
  %inc139.epil = add i64 %71, 1
  store i64 %inc139.epil, i64* %arrayidx138.epil, align 8, !tbaa !21
  br label %for.cond143.preheader

for.cond143.preheader:                            ; preds = %for.body134.epil, %for.cond143.preheader.loopexit.unr-lcssa, %invoke.cont120
  %cmp145512 = icmp eq i64 %66, 0
  br i1 %cmp145512, label %for.cond.cleanup146, label %for.body147.preheader

for.body147.preheader:                            ; preds = %for.cond143.preheader
  %xtraiter531 = and i64 %66, 1
  %72 = icmp eq i64 %66, 1
  br i1 %72, label %for.cond.cleanup146.loopexit.unr-lcssa, label %for.body147.preheader.new

for.body147.preheader.new:                        ; preds = %for.body147.preheader
  %unroll_iter533 = sub i64 %66, %xtraiter531
  br label %for.body147

lpad119:                                          ; preds = %if.then.i406, %for.cond.cleanup
  %73 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup201

for.body134:                                      ; preds = %for.body134, %for.body134.preheader.new
  %l129.0516 = phi i64 [ 0, %for.body134.preheader.new ], [ %inc141.1, %for.body134 ]
  %niter538 = phi i64 [ %unroll_iter537, %for.body134.preheader.new ], [ %niter538.nsub.1, %for.body134 ]
  %arrayidx136 = getelementptr inbounds i64, i64* %56, i64 %l129.0516
  %74 = load i64, i64* %arrayidx136, align 8, !tbaa !21
  %sub137 = add i64 %74, -1
  %arrayidx138 = getelementptr inbounds i64, i64* %68, i64 %sub137
  %75 = load i64, i64* %arrayidx138, align 8, !tbaa !21
  %inc139 = add i64 %75, 1
  store i64 %inc139, i64* %arrayidx138, align 8, !tbaa !21
  %inc141 = or i64 %l129.0516, 1
  %arrayidx136.1 = getelementptr inbounds i64, i64* %56, i64 %inc141
  %76 = load i64, i64* %arrayidx136.1, align 8, !tbaa !21
  %sub137.1 = add i64 %76, -1
  %arrayidx138.1 = getelementptr inbounds i64, i64* %68, i64 %sub137.1
  %77 = load i64, i64* %arrayidx138.1, align 8, !tbaa !21
  %inc139.1 = add i64 %77, 1
  store i64 %inc139.1, i64* %arrayidx138.1, align 8, !tbaa !21
  %inc141.1 = add nuw i64 %l129.0516, 2
  %niter538.nsub.1 = add i64 %niter538, -2
  %niter538.ncmp.1 = icmp eq i64 %niter538.nsub.1, 0
  br i1 %niter538.ncmp.1, label %for.cond143.preheader.loopexit.unr-lcssa, label %for.body134

for.cond.cleanup146.loopexit.unr-lcssa:           ; preds = %for.body147, %for.body147.preheader
  %cumsum.0514.unr = phi i64 [ 0, %for.body147.preheader ], [ %add153.1, %for.body147 ]
  %i.0513.unr = phi i64 [ 0, %for.body147.preheader ], [ %inc155.1, %for.body147 ]
  %lcmp.mod532 = icmp eq i64 %xtraiter531, 0
  br i1 %lcmp.mod532, label %for.cond.cleanup146, label %for.body147.epil

for.body147.epil:                                 ; preds = %for.cond.cleanup146.loopexit.unr-lcssa
  %arrayidx149.epil = getelementptr inbounds i64, i64* %68, i64 %i.0513.unr
  store i64 %cumsum.0514.unr, i64* %arrayidx149.epil, align 8, !tbaa !21
  br label %for.cond.cleanup146

for.cond.cleanup146:                              ; preds = %for.body147.epil, %for.cond.cleanup146.loopexit.unr-lcssa, %for.cond143.preheader
  %arrayidx160 = getelementptr inbounds i64, i64* %68, i64 %66
  store i64 %64, i64* %arrayidx160, align 8, !tbaa !21
  br i1 %cmp132515, label %for.cond186.preheader, label %for.body166.lr.ph

for.body166.lr.ph:                                ; preds = %for.cond.cleanup146
  %78 = load i64*, i64** %row, align 8, !tbaa !22
  br label %for.body166

for.body147:                                      ; preds = %for.body147, %for.body147.preheader.new
  %cumsum.0514 = phi i64 [ 0, %for.body147.preheader.new ], [ %add153.1, %for.body147 ]
  %i.0513 = phi i64 [ 0, %for.body147.preheader.new ], [ %inc155.1, %for.body147 ]
  %niter534 = phi i64 [ %unroll_iter533, %for.body147.preheader.new ], [ %niter534.nsub.1, %for.body147 ]
  %arrayidx149 = getelementptr inbounds i64, i64* %68, i64 %i.0513
  %79 = load i64, i64* %arrayidx149, align 8, !tbaa !21
  store i64 %cumsum.0514, i64* %arrayidx149, align 8, !tbaa !21
  %sext305 = shl i64 %79, 32
  %conv152 = ashr exact i64 %sext305, 32
  %add153 = add i64 %conv152, %cumsum.0514
  %inc155 = or i64 %i.0513, 1
  %arrayidx149.1 = getelementptr inbounds i64, i64* %68, i64 %inc155
  %80 = load i64, i64* %arrayidx149.1, align 8, !tbaa !21
  store i64 %add153, i64* %arrayidx149.1, align 8, !tbaa !21
  %sext305.1 = shl i64 %80, 32
  %conv152.1 = ashr exact i64 %sext305.1, 32
  %add153.1 = add i64 %conv152.1, %add153
  %inc155.1 = add nuw i64 %i.0513, 2
  %niter534.nsub.1 = add i64 %niter534, -2
  %niter534.ncmp.1 = icmp eq i64 %niter534.nsub.1, 0
  br i1 %niter534.ncmp.1, label %for.cond.cleanup146.loopexit.unr-lcssa, label %for.body147

for.cond186.preheader.loopexit:                   ; preds = %for.body166
  %.pre = load i64, i64* %n, align 8, !tbaa !21
  br label %for.cond186.preheader

for.cond186.preheader:                            ; preds = %for.cond186.preheader.loopexit, %for.cond.cleanup146
  %81 = phi i64 [ %.pre, %for.cond186.preheader.loopexit ], [ %66, %for.cond.cleanup146 ]
  %cmp188507 = icmp eq i64 %81, 0
  br i1 %cmp188507, label %for.cond.cleanup189, label %for.body190.preheader

for.body190.preheader:                            ; preds = %for.cond186.preheader
  %82 = add i64 %81, -1
  %xtraiter = and i64 %81, 3
  %83 = icmp ult i64 %82, 3
  br i1 %83, label %for.cond.cleanup189.loopexit.unr-lcssa, label %for.body190.preheader.new

for.body190.preheader.new:                        ; preds = %for.body190.preheader
  %unroll_iter = sub i64 %81, %xtraiter
  br label %for.body190

for.body166:                                      ; preds = %for.body166.lr.ph, %for.body166
  %l161.0511 = phi i64 [ 0, %for.body166.lr.ph ], [ %inc183, %for.body166 ]
  %arrayidx167 = getelementptr inbounds i64, i64* %56, i64 %l161.0511
  %84 = load i64, i64* %arrayidx167, align 8, !tbaa !21
  %conv169 = shl i64 %84, 32
  %sext303 = add i64 %conv169, -4294967296
  %idxprom = ashr exact i64 %sext303, 32
  %arrayidx171 = getelementptr inbounds i64, i64* %68, i64 %idxprom
  %85 = load i64, i64* %arrayidx171, align 8, !tbaa !21
  %arrayidx173 = getelementptr inbounds i64, i64* %54, i64 %l161.0511
  %86 = load i64, i64* %arrayidx173, align 8, !tbaa !21
  %sub174 = add i64 %86, -1
  %sext304 = shl i64 %85, 32
  %idxprom176 = ashr exact i64 %sext304, 32
  %arrayidx177 = getelementptr inbounds i64, i64* %78, i64 %idxprom176
  store i64 %sub174, i64* %arrayidx177, align 8, !tbaa !21
  %87 = load i64, i64* %arrayidx171, align 8, !tbaa !21
  %inc181 = add i64 %87, 1
  store i64 %inc181, i64* %arrayidx171, align 8, !tbaa !21
  %inc183 = add nuw i64 %l161.0511, 1
  %88 = load i64, i64* %m, align 8, !tbaa !21
  %cmp164 = icmp ult i64 %inc183, %88
  br i1 %cmp164, label %for.body166, label %for.cond186.preheader.loopexit

for.cond.cleanup189.loopexit.unr-lcssa:           ; preds = %for.body190, %for.body190.preheader
  %last.0509.unr = phi i64 [ 0, %for.body190.preheader ], [ %conv197.3, %for.body190 ]
  %i185.0508.unr = phi i64 [ 0, %for.body190.preheader ], [ %inc199.3, %for.body190 ]
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %for.cond.cleanup189, label %for.body190.epil

for.body190.epil:                                 ; preds = %for.cond.cleanup189.loopexit.unr-lcssa, %for.body190.epil
  %last.0509.epil = phi i64 [ %conv197.epil, %for.body190.epil ], [ %last.0509.unr, %for.cond.cleanup189.loopexit.unr-lcssa ]
  %i185.0508.epil = phi i64 [ %inc199.epil, %for.body190.epil ], [ %i185.0508.unr, %for.cond.cleanup189.loopexit.unr-lcssa ]
  %epil.iter = phi i64 [ %epil.iter.sub, %for.body190.epil ], [ %xtraiter, %for.cond.cleanup189.loopexit.unr-lcssa ]
  %arrayidx193.epil = getelementptr inbounds i64, i64* %68, i64 %i185.0508.epil
  %89 = load i64, i64* %arrayidx193.epil, align 8, !tbaa !21
  store i64 %last.0509.epil, i64* %arrayidx193.epil, align 8, !tbaa !21
  %sext.epil = shl i64 %89, 32
  %conv197.epil = ashr exact i64 %sext.epil, 32
  %inc199.epil = add nuw i64 %i185.0508.epil, 1
  %epil.iter.sub = add i64 %epil.iter, -1
  %epil.iter.cmp = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp, label %for.cond.cleanup189, label %for.body190.epil, !llvm.loop !23

for.cond.cleanup189:                              ; preds = %for.cond.cleanup189.loopexit.unr-lcssa, %for.body190.epil, %for.cond186.preheader
  call void @free(i8* %call115) #14
  call void @free(i8* %call118) #14
  %90 = load i64, i64* bitcast ([4 x i8*]* @_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE to i64*), align 8
  %91 = bitcast %"class.std::basic_ifstream"* %fin to i64*
  store i64 %90, i64* %91, align 8, !tbaa !2
  %92 = load i64, i64* bitcast (i8** getelementptr inbounds ([4 x i8*], [4 x i8*]* @_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE, i64 0, i64 3) to i64*), align 8
  %vtable.cast.i.i416 = inttoptr i64 %90 to i8*
  %vbase.offset.ptr.i.i417 = getelementptr i8, i8* %vtable.cast.i.i416, i64 -24
  %93 = bitcast i8* %vbase.offset.ptr.i.i417 to i64*
  %vbase.offset.i.i418 = load i64, i64* %93, align 8
  %add.ptr.i.i419 = getelementptr inbounds i8, i8* %6, i64 %vbase.offset.i.i418
  %94 = bitcast i8* %add.ptr.i.i419 to i64*
  store i64 %92, i64* %94, align 8, !tbaa !2
  call void @_ZNSt13basic_filebufIcSt11char_traitsIcEED2Ev(%"class.std::basic_filebuf"* nonnull %_M_filebuf.i) #14
  %95 = load i64, i64* bitcast (i8** getelementptr inbounds ([4 x i8*], [4 x i8*]* @_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE, i64 0, i64 1) to i64*), align 8
  store i64 %95, i64* %91, align 8, !tbaa !2
  %96 = load i64, i64* bitcast (i8** getelementptr inbounds ([4 x i8*], [4 x i8*]* @_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE, i64 0, i64 2) to i64*), align 8
  %vtable.cast.i.i.i421 = inttoptr i64 %95 to i8*
  %vbase.offset.ptr.i.i.i422 = getelementptr i8, i8* %vtable.cast.i.i.i421, i64 -24
  %97 = bitcast i8* %vbase.offset.ptr.i.i.i422 to i64*
  %vbase.offset.i.i.i423 = load i64, i64* %97, align 8
  %add.ptr.i.i.i424 = getelementptr inbounds i8, i8* %6, i64 %vbase.offset.i.i.i423
  %98 = bitcast i8* %add.ptr.i.i.i424 to i64*
  store i64 %96, i64* %98, align 8, !tbaa !2
  %99 = getelementptr inbounds %"class.std::basic_ifstream", %"class.std::basic_ifstream"* %fin, i64 0, i32 0, i32 1
  store i64 0, i64* %99, align 8, !tbaa !25
  %100 = getelementptr inbounds %"class.std::basic_ifstream", %"class.std::basic_ifstream"* %fin, i64 0, i32 2, i32 0
  call void @_ZNSt8ios_baseD2Ev(%"class.std::ios_base"* nonnull %100) #14
  call void @llvm.lifetime.end.p0i8(i64 520, i8* nonnull %6) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %5) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %4) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %3) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %2) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %1) #14
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %0) #14
  ret void

for.body190:                                      ; preds = %for.body190, %for.body190.preheader.new
  %last.0509 = phi i64 [ 0, %for.body190.preheader.new ], [ %conv197.3, %for.body190 ]
  %i185.0508 = phi i64 [ 0, %for.body190.preheader.new ], [ %inc199.3, %for.body190 ]
  %niter = phi i64 [ %unroll_iter, %for.body190.preheader.new ], [ %niter.nsub.3, %for.body190 ]
  %arrayidx193 = getelementptr inbounds i64, i64* %68, i64 %i185.0508
  %101 = load i64, i64* %arrayidx193, align 8, !tbaa !21
  store i64 %last.0509, i64* %arrayidx193, align 8, !tbaa !21
  %sext = shl i64 %101, 32
  %conv197 = ashr exact i64 %sext, 32
  %inc199 = or i64 %i185.0508, 1
  %arrayidx193.1 = getelementptr inbounds i64, i64* %68, i64 %inc199
  %102 = load i64, i64* %arrayidx193.1, align 8, !tbaa !21
  store i64 %conv197, i64* %arrayidx193.1, align 8, !tbaa !21
  %sext.1 = shl i64 %102, 32
  %conv197.1 = ashr exact i64 %sext.1, 32
  %inc199.1 = or i64 %i185.0508, 2
  %arrayidx193.2 = getelementptr inbounds i64, i64* %68, i64 %inc199.1
  %103 = load i64, i64* %arrayidx193.2, align 8, !tbaa !21
  store i64 %conv197.1, i64* %arrayidx193.2, align 8, !tbaa !21
  %sext.2 = shl i64 %103, 32
  %conv197.2 = ashr exact i64 %sext.2, 32
  %inc199.2 = or i64 %i185.0508, 3
  %arrayidx193.3 = getelementptr inbounds i64, i64* %68, i64 %inc199.2
  %104 = load i64, i64* %arrayidx193.3, align 8, !tbaa !21
  store i64 %conv197.2, i64* %arrayidx193.3, align 8, !tbaa !21
  %sext.3 = shl i64 %104, 32
  %conv197.3 = ashr exact i64 %sext.3, 32
  %inc199.3 = add nuw i64 %i185.0508, 4
  %niter.nsub.3 = add i64 %niter, -4
  %niter.ncmp.3 = icmp eq i64 %niter.nsub.3, 0
  br i1 %niter.ncmp.3, label %for.cond.cleanup189.loopexit.unr-lcssa, label %for.body190

ehcleanup201:                                     ; preds = %lpad82.us-lcssa, %lpad82.us-lcssa.us, %lpad.loopexit, %lpad.loopexit.split-lp, %lpad119
  %.sink529 = phi { i8*, i32 } [ %73, %lpad119 ], [ %lpad.loopexit504, %lpad.loopexit ], [ %lpad.loopexit.split-lp505, %lpad.loopexit.split-lp ], [ %lpad.us-lcssa.us, %lpad82.us-lcssa.us ], [ %lpad.us-lcssa, %lpad82.us-lcssa ]
  %105 = load i64, i64* bitcast ([4 x i8*]* @_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE to i64*), align 8
  %106 = bitcast %"class.std::basic_ifstream"* %fin to i64*
  store i64 %105, i64* %106, align 8, !tbaa !2
  %107 = load i64, i64* bitcast (i8** getelementptr inbounds ([4 x i8*], [4 x i8*]* @_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE, i64 0, i64 3) to i64*), align 8
  %vtable.cast.i.i = inttoptr i64 %105 to i8*
  %vbase.offset.ptr.i.i = getelementptr i8, i8* %vtable.cast.i.i, i64 -24
  %108 = bitcast i8* %vbase.offset.ptr.i.i to i64*
  %vbase.offset.i.i = load i64, i64* %108, align 8
  %add.ptr.i.i = getelementptr inbounds i8, i8* %6, i64 %vbase.offset.i.i
  %109 = bitcast i8* %add.ptr.i.i to i64*
  store i64 %107, i64* %109, align 8, !tbaa !2
  %_M_filebuf.i.i = getelementptr inbounds %"class.std::basic_ifstream", %"class.std::basic_ifstream"* %fin, i64 0, i32 1
  call void @_ZNSt13basic_filebufIcSt11char_traitsIcEED2Ev(%"class.std::basic_filebuf"* nonnull %_M_filebuf.i.i) #14
  %110 = load i64, i64* bitcast (i8** getelementptr inbounds ([4 x i8*], [4 x i8*]* @_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE, i64 0, i64 1) to i64*), align 8
  store i64 %110, i64* %106, align 8, !tbaa !2
  %111 = load i64, i64* bitcast (i8** getelementptr inbounds ([4 x i8*], [4 x i8*]* @_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE, i64 0, i64 2) to i64*), align 8
  %vtable.cast.i.i.i = inttoptr i64 %110 to i8*
  %vbase.offset.ptr.i.i.i = getelementptr i8, i8* %vtable.cast.i.i.i, i64 -24
  %112 = bitcast i8* %vbase.offset.ptr.i.i.i to i64*
  %vbase.offset.i.i.i = load i64, i64* %112, align 8
  %add.ptr.i.i.i = getelementptr inbounds i8, i8* %6, i64 %vbase.offset.i.i.i
  %113 = bitcast i8* %add.ptr.i.i.i to i64*
  store i64 %111, i64* %113, align 8, !tbaa !2
  %114 = getelementptr inbounds %"class.std::basic_ifstream", %"class.std::basic_ifstream"* %fin, i64 0, i32 0, i32 1
  store i64 0, i64* %114, align 8, !tbaa !25
  %115 = getelementptr inbounds %"class.std::basic_ifstream", %"class.std::basic_ifstream"* %fin, i64 0, i32 2, i32 0
  call void @_ZNSt8ios_baseD2Ev(%"class.std::ios_base"* nonnull %115) #14
  call void @llvm.lifetime.end.p0i8(i64 520, i8* nonnull %6) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %5) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %4) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %3) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %2) #14
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %1) #14
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %0) #14
  resume { i8*, i32 } %.sink529
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #4

; Function Attrs: uwtable
declare dso_local void @_ZNSt14basic_ifstreamIcSt11char_traitsIcEEC1EPKcSt13_Ios_Openmode(%"class.std::basic_ifstream"*, i8*, i32) unnamed_addr #3 align 2

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) local_unnamed_addr #5

declare dso_local dereferenceable(280) %"class.std::basic_istream"* @_ZStrsIcSt11char_traitsIcEERSt13basic_istreamIT_T0_ES6_PS3_(%"class.std::basic_istream"* dereferenceable(280), i8*) local_unnamed_addr #0

declare dso_local dereferenceable(280) %"class.std::basic_istream"* @_ZNSi6ignoreEli(%"class.std::basic_istream"*, i64, i32) local_unnamed_addr #0

declare dso_local i32 @_ZNSi4peekEv(%"class.std::basic_istream"*) local_unnamed_addr #0

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #5

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @malloc(i64) local_unnamed_addr #6

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #4

; Function Attrs: nounwind
declare dso_local noalias i8* @realloc(i8* nocapture, i64) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @calloc(i64, i64) local_unnamed_addr #6

; Function Attrs: nounwind
declare dso_local void @free(i8* nocapture) local_unnamed_addr #1

; Function Attrs: nounwind uwtable
declare dso_local void @_ZNSt13basic_filebufIcSt11char_traitsIcEED2Ev(%"class.std::basic_filebuf"*) unnamed_addr #9 align 2

declare dso_local void @_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate(%"class.std::basic_ios"*, i32) local_unnamed_addr #0

declare dso_local %"class.std::basic_filebuf"* @_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv(%"class.std::basic_filebuf"*) local_unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_baseD2Ev(%"class.std::ios_base"*) unnamed_addr #1

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* dereferenceable(272), i8*, i64) local_unnamed_addr #0

; Function Attrs: argmemonly nofree nounwind readonly
declare dso_local i64 @strlen(i8* nocapture) local_unnamed_addr #10

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"*, i8 signext) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"*) local_unnamed_addr #0

; Function Attrs: noreturn
declare dso_local void @_ZSt16__throw_bad_castv() local_unnamed_addr #11

declare dso_local void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"*) local_unnamed_addr #0

declare dso_local dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractImEERSiRT_(%"class.std::basic_istream"*, i64* dereferenceable(8)) local_unnamed_addr #0

; Function Attrs: nofree nounwind readonly
declare i32 @bcmp(i8* nocapture, i8* nocapture, i64) local_unnamed_addr #13

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nofree nounwind }
attributes #3 = { uwtable sanitize_cilk "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { argmemonly nounwind willreturn }
attributes #5 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { norecurse uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { argmemonly nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #12 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #13 = { nofree nounwind readonly }
attributes #14 = { nounwind }
attributes #15 = { noreturn }
attributes #16 = { noreturn nounwind }
attributes #17 = { nounwind readonly }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git ab3603035dbe88fbf907488a4dfc17fa4849dad4)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"vtable pointer", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
!5 = !{!6, !10, i64 32}
!6 = !{!"_ZTSSt8ios_base", !7, i64 8, !7, i64 16, !9, i64 24, !10, i64 28, !10, i64 32, !11, i64 40, !12, i64 48, !8, i64 64, !13, i64 192, !11, i64 200, !14, i64 208}
!7 = !{!"long", !8, i64 0}
!8 = !{!"omnipotent char", !4, i64 0}
!9 = !{!"_ZTSSt13_Ios_Fmtflags", !8, i64 0}
!10 = !{!"_ZTSSt12_Ios_Iostate", !8, i64 0}
!11 = !{!"any pointer", !8, i64 0}
!12 = !{!"_ZTSNSt8ios_base6_WordsE", !11, i64 0, !7, i64 8}
!13 = !{!"int", !8, i64 0}
!14 = !{!"_ZTSSt6locale", !11, i64 0}
!15 = !{!16, !11, i64 240}
!16 = !{!"_ZTSSt9basic_iosIcSt11char_traitsIcEE", !11, i64 216, !8, i64 224, !17, i64 225, !11, i64 232, !11, i64 240, !11, i64 248, !11, i64 256}
!17 = !{!"bool", !8, i64 0}
!18 = !{!19, !8, i64 56}
!19 = !{!"_ZTSSt5ctypeIcE", !11, i64 16, !17, i64 24, !11, i64 32, !11, i64 40, !11, i64 48, !8, i64 56, !8, i64 57, !8, i64 313, !8, i64 569}
!20 = !{!8, !8, i64 0}
!21 = !{!7, !7, i64 0}
!22 = !{!11, !11, i64 0}
!23 = distinct !{!23, !24}
!24 = !{!"llvm.loop.unroll.disable"}
!25 = !{!26, !7, i64 8}
!26 = !{!"_ZTSSi", !7, i64 8}
!27 = !{!28, !28, i64 0}
!28 = !{!"double", !8, i64 0}
!29 = !{!30, !11, i64 0}
!30 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_Alloc_hiderE", !11, i64 0}
!31 = !{!32, !7, i64 8}
!32 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", !30, i64 0, !7, i64 8, !8, i64 16}
!33 = !{!32, !11, i64 0}
