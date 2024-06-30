; Test to verify that LoopSpawning properly outlines helper functions
; for nested Tapir loops that each include exception-handling code.
;
; Credit to Tim Kaler for producing the source code that inspired this test
; case.
;
; RUN: opt < %s -enable-new-pm=0 -loop-spawning-ti -S | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::vector.0" = type { %"struct.std::_Vector_base.1" }
%"struct.std::_Vector_base.1" = type { %"struct.std::_Vector_base<std::tuple<int, double, int>, std::allocator<std::tuple<int, double, int> > >::_Vector_impl" }
%"struct.std::_Vector_base<std::tuple<int, double, int>, std::allocator<std::tuple<int, double, int> > >::_Vector_impl" = type { %"class.std::tuple"*, %"class.std::tuple"*, %"class.std::tuple"* }
%"class.std::tuple" = type { %"struct.std::_Tuple_impl.base", [4 x i8] }
%"struct.std::_Tuple_impl.base" = type <{ %"struct.std::_Tuple_impl.5", %"struct.std::_Head_base.8" }>
%"struct.std::_Tuple_impl.5" = type { %"struct.std::_Tuple_impl.6", %"struct.std::_Head_base.7" }
%"struct.std::_Tuple_impl.6" = type { %"struct.std::_Head_base" }
%"struct.std::_Head_base" = type { i32 }
%"struct.std::_Head_base.7" = type { double }
%"struct.std::_Head_base.8" = type { i32 }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<params, std::allocator<params> >::_Vector_impl" }
%"struct.std::_Vector_base<params, std::allocator<params> >::_Vector_impl" = type { %struct.params*, %struct.params*, %struct.params* }
%struct.params = type { i32, i32, float, float, float, i32 }

$_ZNSt6vectorISt5tupleIJidiEESaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_ = comdat any

$_ZNSt6vectorISt5tupleIJidiEESaIS1_EE17_M_realloc_insertIJRKS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_ = comdat any

@.str = private unnamed_addr constant [16 x i8] c"vector::reserve\00", align 1

; Function Attrs: uwtable
define void @_Z14func_with_sretidRSt6vectorI6paramsSaIS0_EE(%"class.std::vector.0"* noalias sret(%"class.std::vector.0") %agg.result, i32 %trials, double %threshold, %"class.std::vector"* nocapture readonly dereferenceable(24) %ps) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = bitcast %"class.std::vector.0"* %agg.result to i8*
  tail call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 24, i32 8, i1 false) #8
  %_M_finish.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ps, i64 0, i32 0, i32 0, i32 1
  %1 = bitcast %struct.params** %_M_finish.i to i64*
  %2 = load i64, i64* %1, align 8, !tbaa !2
  %3 = bitcast %"class.std::vector"* %ps to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !8
  %sub.ptr.sub.i = sub i64 %2, %4
  %sub.ptr.div.i = sdiv exact i64 %sub.ptr.sub.i, 24
  %cmp.i = icmp ugt i64 %sub.ptr.div.i, 768614336404564650
  br i1 %cmp.i, label %if.then.i, label %if.end.i

if.then.i:                                        ; preds = %entry
  invoke void @_ZSt20__throw_length_errorPKc(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str, i64 0, i64 0)) #9
          to label %.noexc unwind label %lpad

.noexc:                                           ; preds = %if.then.i
  unreachable

if.end.i:                                         ; preds = %entry
  %_M_end_of_storage.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %agg.result, i64 0, i32 0, i32 0, i32 2
  %5 = icmp eq i64 %sub.ptr.sub.i, 0
  br i1 %5, label %pfor.cond.cleanup, label %_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE11_M_allocateEm.exit.i.i

_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE11_M_allocateEm.exit.i.i: ; preds = %if.end.i
  %_M_finish.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %agg.result, i64 0, i32 0, i32 0, i32 1
  %call2.i.i.i.i.i179 = invoke i8* @_Znwm(i64 %sub.ptr.sub.i)
          to label %_ZNSt6vectorISt5tupleIJidiEESaIS1_EE20_M_allocate_and_copyISt13move_iteratorIPS1_EEES6_mT_S8_.exit.i unwind label %lpad

_ZNSt6vectorISt5tupleIJidiEESaIS1_EE20_M_allocate_and_copyISt13move_iteratorIPS1_EEES6_mT_S8_.exit.i: ; preds = %_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE11_M_allocateEm.exit.i.i
  %_M_start.i178 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %agg.result, i64 0, i32 0, i32 0, i32 0
  %6 = bitcast i8* %call2.i.i.i.i.i179 to %"class.std::tuple"*
  %7 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_start.i178, align 8, !tbaa !9
  %tobool.i.i = icmp eq %"class.std::tuple"* %7, null
  br i1 %tobool.i.i, label %invoke.cont, label %if.then.i.i

if.then.i.i:                                      ; preds = %_ZNSt6vectorISt5tupleIJidiEESaIS1_EE20_M_allocate_and_copyISt13move_iteratorIPS1_EEES6_mT_S8_.exit.i
  %8 = bitcast %"class.std::tuple"* %7 to i8*
  tail call void @_ZdlPv(i8* %8) #8
  br label %invoke.cont

invoke.cont:                                      ; preds = %if.then.i.i, %_ZNSt6vectorISt5tupleIJidiEESaIS1_EE20_M_allocate_and_copyISt13move_iteratorIPS1_EEES6_mT_S8_.exit.i
  %9 = bitcast %"class.std::vector.0"* %agg.result to i8**
  store i8* %call2.i.i.i.i.i179, i8** %9, align 8, !tbaa !9
  %10 = bitcast %"class.std::tuple"** %_M_finish.i.i to i8**
  store i8* %call2.i.i.i.i.i179, i8** %10, align 8, !tbaa !12
  %add.ptr30.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %6, i64 %sub.ptr.div.i
  store %"class.std::tuple"* %add.ptr30.i, %"class.std::tuple"** %_M_end_of_storage.i.i, align 8, !tbaa !13
  %.pre = load i64, i64* %1, align 8, !tbaa !2
  %.pre442 = load i64, i64* %3, align 8, !tbaa !8
  %.pre443 = sub i64 %.pre, %.pre442
  %.pre444 = sdiv exact i64 %.pre443, 24
  %conv = trunc i64 %.pre444 to i32
  %sext = shl i64 %.pre444, 32
  %conv2 = ashr exact i64 %sext, 32
  %cmp.i.i.i.i183 = icmp eq i64 %sext, 0
  br i1 %cmp.i.i.i.i183, label %invoke.cont4, label %cond.true.i.i.i.i

cond.true.i.i.i.i:                                ; preds = %invoke.cont
  %cmp.i.i.i.i.i.i = icmp ugt i64 %conv2, 768614336404564650
  br i1 %cmp.i.i.i.i.i.i, label %if.then.i.i.i.i.i.i, label %_ZNSt16allocator_traitsISaISt6vectorISt5tupleIJidiEESaIS2_EEEE8allocateERS5_m.exit.i.i.i.i

if.then.i.i.i.i.i.i:                              ; preds = %cond.true.i.i.i.i
  invoke void @_ZSt17__throw_bad_allocv() #9
          to label %.noexc186 unwind label %lpad3

.noexc186:                                        ; preds = %if.then.i.i.i.i.i.i
  unreachable

_ZNSt16allocator_traitsISaISt6vectorISt5tupleIJidiEESaIS2_EEEE8allocateERS5_m.exit.i.i.i.i: ; preds = %cond.true.i.i.i.i
  %mul.i.i.i.i.i.i = mul nsw i64 %conv2, 24
  %call2.i.i.i.i3.i.i187 = invoke i8* @_Znwm(i64 %mul.i.i.i.i.i.i)
          to label %for.body.lr.ph.i.i.i.i.i184 unwind label %lpad3

for.body.lr.ph.i.i.i.i.i184:                      ; preds = %_ZNSt16allocator_traitsISaISt6vectorISt5tupleIJidiEESaIS2_EEEE8allocateERS5_m.exit.i.i.i.i
  %11 = bitcast i8* %call2.i.i.i.i3.i.i187 to %"class.std::vector.0"*
  %12 = ptrtoint i8* %call2.i.i.i.i3.i.i187 to i64
  %add.ptr.i.i.i = getelementptr %"class.std::vector.0", %"class.std::vector.0"* %11, i64 %conv2
  tail call void @llvm.memset.p0i8.i64(i8* nonnull %call2.i.i.i.i3.i.i187, i8 0, i64 %mul.i.i.i.i.i.i, i32 8, i1 false)
  br label %invoke.cont4

invoke.cont4:                                     ; preds = %for.body.lr.ph.i.i.i.i.i184, %invoke.cont
  %13 = phi i64 [ %12, %for.body.lr.ph.i.i.i.i.i184 ], [ 0, %invoke.cont ]
  %14 = phi i8* [ %call2.i.i.i.i3.i.i187, %for.body.lr.ph.i.i.i.i.i184 ], [ null, %invoke.cont ]
  %cond.i.i.i.i339 = phi %"class.std::vector.0"* [ %11, %for.body.lr.ph.i.i.i.i.i184 ], [ null, %invoke.cont ]
  %__cur.0.lcssa.i.i.i.i.i = phi %"class.std::vector.0"* [ %add.ptr.i.i.i, %for.body.lr.ph.i.i.i.i.i184 ], [ null, %invoke.cont ]
  %15 = ptrtoint %"class.std::vector.0"* %__cur.0.lcssa.i.i.i.i.i to i64
  %cmp404 = icmp sgt i32 %conv, 0
  br i1 %cmp404, label %pfor.detach.lr.ph, label %pfor.cond.cleanup

pfor.detach.lr.ph:                                ; preds = %invoke.cont4
  %conv8 = sext i32 %trials to i64
  %cmp.i.i.i.i193 = icmp eq i32 %trials, 0
  %add.ptr.i.i.i243354 = getelementptr i32, i32* null, i64 %conv8
  %cmp27397 = icmp sgt i32 %trials, 0
  %cmp.i.i.i.i.i.i194366 = icmp slt i32 %trials, 0
  %mul.i.i.i.i.i.i197 = shl nsw i64 %conv8, 2
  %sext445 = shl i64 %.pre444, 32
  %16 = ashr exact i64 %sext445, 32
  br label %pfor.detach
; CHECK: {{^pfor.detach.lr.ph:}}
; CHECK: invoke fastcc void @_Z14func_with_sretidRSt6vectorI6paramsSaIS0_EE.outline_pfor.detach.ls1(i64 0
; CHECK-NEXT: to label %pfor.cond.cleanup.loopexit unwind label %lpad80.loopexit

pfor.cond.cleanup.loopexit:                       ; preds = %pfor.inc78
  br label %pfor.cond.cleanup

pfor.cond.cleanup:                                ; preds = %pfor.cond.cleanup.loopexit, %invoke.cont4, %if.end.i
  %17 = phi i64 [ %15, %invoke.cont4 ], [ 0, %if.end.i ], [ %15, %pfor.cond.cleanup.loopexit ]
  %__cur.0.lcssa.i.i.i.i.i461 = phi %"class.std::vector.0"* [ %__cur.0.lcssa.i.i.i.i.i, %invoke.cont4 ], [ null, %if.end.i ], [ %__cur.0.lcssa.i.i.i.i.i, %pfor.cond.cleanup.loopexit ]
  %cond.i.i.i.i339453 = phi %"class.std::vector.0"* [ %cond.i.i.i.i339, %invoke.cont4 ], [ null, %if.end.i ], [ %cond.i.i.i.i339, %pfor.cond.cleanup.loopexit ]
  %18 = phi i8* [ %14, %invoke.cont4 ], [ null, %if.end.i ], [ %14, %pfor.cond.cleanup.loopexit ]
  %19 = phi i64 [ %13, %invoke.cont4 ], [ 0, %if.end.i ], [ %13, %pfor.cond.cleanup.loopexit ]
  sync within %syncreg, label %sync.continue87

lpad:                                             ; preds = %_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE11_M_allocateEm.exit.i.i, %if.then.i
  %20 = landingpad { i8*, i32 }
          cleanup
  %21 = extractvalue { i8*, i32 } %20, 0
  %22 = extractvalue { i8*, i32 } %20, 1
  br label %ehcleanup126

lpad3:                                            ; preds = %_ZNSt16allocator_traitsISaISt6vectorISt5tupleIJidiEESaIS2_EEEE8allocateERS5_m.exit.i.i.i.i, %if.then.i.i.i.i.i.i
  %23 = landingpad { i8*, i32 }
          cleanup
  %24 = extractvalue { i8*, i32 } %23, 0
  %25 = extractvalue { i8*, i32 } %23, 1
  br label %ehcleanup126

pfor.detach:                                      ; preds = %pfor.inc78, %pfor.detach.lr.ph
  %indvars.iv440 = phi i64 [ 0, %pfor.detach.lr.ph ], [ %indvars.iv.next441, %pfor.inc78 ]
  detach within %syncreg, label %pfor.body, label %pfor.inc78 unwind label %lpad80.loopexit

pfor.body:                                        ; preds = %pfor.detach
  %worker_matches_count.sroa.13 = alloca i32*, align 8
  %syncreg18 = call token @llvm.syncregion.start()
  %ref.tmp65 = alloca %"class.std::tuple", align 8
  %call7 = call i64 @clock() #8
  br i1 %cmp.i.i.i.i193, label %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread, label %cond.true.i.i.i.i195

_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread: ; preds = %pfor.body
  %worker_matches_count.sroa.13.0..sroa_cast302348 = bitcast i32** %worker_matches_count.sroa.13 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %worker_matches_count.sroa.13.0..sroa_cast302348)
  store i32* %add.ptr.i.i.i243354, i32** %worker_matches_count.sroa.13, align 8
  br label %invoke.cont17

cond.true.i.i.i.i195:                             ; preds = %pfor.body
  br i1 %cmp.i.i.i.i.i.i194366, label %if.then.i.i.i.i.i.i196, label %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i

if.then.i.i.i.i.i.i196:                           ; preds = %cond.true.i.i.i.i195
  invoke void @_ZSt17__throw_bad_allocv() #9
          to label %.noexc204 unwind label %lpad10.loopexit.split-lp

.noexc204:                                        ; preds = %if.then.i.i.i.i.i.i196
  unreachable

_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i: ; preds = %cond.true.i.i.i.i195
  %call2.i.i.i.i3.i.i206 = invoke i8* @_Znwm(i64 %mul.i.i.i.i.i.i197)
          to label %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i239 unwind label %lpad10.loopexit

_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i239: ; preds = %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i
  call void @llvm.memset.p0i8.i64(i8* nonnull %call2.i.i.i.i3.i.i206, i8 0, i64 %mul.i.i.i.i.i.i197, i32 4, i1 false)
  %worker_matches_count.sroa.13.0..sroa_cast302 = bitcast i32** %worker_matches_count.sroa.13 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %worker_matches_count.sroa.13.0..sroa_cast302)
  store i32* null, i32** %worker_matches_count.sroa.13, align 8
  %call2.i.i.i.i3.i.i251 = invoke i8* @_Znwm(i64 %mul.i.i.i.i.i.i197)
          to label %for.body.lr.ph.i.i.i.i.i.i.i246 unwind label %ehcleanup69.thread

for.body.lr.ph.i.i.i.i.i.i.i246:                  ; preds = %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i239
  %26 = bitcast i8* %call2.i.i.i.i3.i.i206 to i32*
  %27 = bitcast i8* %call2.i.i.i.i3.i.i251 to i32*
  %28 = ptrtoint i8* %call2.i.i.i.i3.i.i251 to i64
  %add.ptr.i.i.i243 = getelementptr i32, i32* %27, i64 %conv8
  store i32* %add.ptr.i.i.i243, i32** %worker_matches_count.sroa.13, align 8
  call void @llvm.memset.p0i8.i64(i8* nonnull %call2.i.i.i.i3.i.i251, i8 0, i64 %mul.i.i.i.i.i.i197, i32 4, i1 false)
  br label %invoke.cont17

invoke.cont17:                                    ; preds = %for.body.lr.ph.i.i.i.i.i.i.i246, %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread
  %29 = phi i64 [ %28, %for.body.lr.ph.i.i.i.i.i.i.i246 ], [ 0, %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread ]
  %30 = phi i8* [ %call2.i.i.i.i3.i.i251, %for.body.lr.ph.i.i.i.i.i.i.i246 ], [ null, %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread ]
  %cond.i.i.i.i240357 = phi i32* [ %27, %for.body.lr.ph.i.i.i.i.i.i.i246 ], [ null, %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread ]
  %31 = phi i8* [ %call2.i.i.i.i3.i.i206, %for.body.lr.ph.i.i.i.i.i.i.i246 ], [ null, %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread ]
  %cond.i.i.i.i198346350356 = phi i32* [ %26, %for.body.lr.ph.i.i.i.i.i.i.i246 ], [ null, %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread ]
  %worker_matches_count.sroa.13.0..sroa_cast302351355 = phi i8* [ %worker_matches_count.sroa.13.0..sroa_cast302, %for.body.lr.ph.i.i.i.i.i.i.i246 ], [ %worker_matches_count.sroa.13.0..sroa_cast302348, %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread ]
  %__first.addr.0.lcssa.i.i.i.i.i.i.i247 = phi i32* [ %add.ptr.i.i.i243, %for.body.lr.ph.i.i.i.i.i.i.i246 ], [ null, %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i245.thread ]
  %32 = ptrtoint i32* %__first.addr.0.lcssa.i.i.i.i.i.i.i247 to i64
  br i1 %cmp27397, label %pfor.detach29.preheader, label %pfor.cond.cleanup28

pfor.detach29.preheader:                          ; preds = %invoke.cont17
  br label %pfor.detach29

pfor.cond.cleanup28.loopexit:                     ; preds = %pfor.inc
  br label %pfor.cond.cleanup28

pfor.cond.cleanup28:                              ; preds = %pfor.cond.cleanup28.loopexit, %invoke.cont17
  sync within %syncreg18, label %sync.continue

lpad10.loopexit:                                  ; preds = %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i
  %lpad.loopexit370 = landingpad { i8*, i32 }
          catch i8* null
  br label %lpad10

lpad10.loopexit.split-lp:                         ; preds = %if.then.i.i.i.i.i.i196
  %lpad.loopexit.split-lp371 = landingpad { i8*, i32 }
          catch i8* null
  br label %lpad10

lpad10:                                           ; preds = %lpad10.loopexit.split-lp, %lpad10.loopexit
  %lpad.phi372 = phi { i8*, i32 } [ %lpad.loopexit370, %lpad10.loopexit ], [ %lpad.loopexit.split-lp371, %lpad10.loopexit.split-lp ]
  %33 = extractvalue { i8*, i32 } %lpad.phi372, 0
  %34 = extractvalue { i8*, i32 } %lpad.phi372, 1
  br label %ehcleanup71

ehcleanup69.thread:                               ; preds = %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i239
  %worker_matches_count.sroa.13.lcssa11 = phi i32** [ %worker_matches_count.sroa.13, %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i239 ]
  %call2.i.i.i.i3.i.i206.lcssa = phi i8* [ %call2.i.i.i.i3.i.i206, %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i239 ]
  %35 = landingpad { i8*, i32 }
          catch i8* null
  %worker_matches_count.sroa.13.0..sroa_cast302.le = bitcast i32** %worker_matches_count.sroa.13.lcssa11 to i8*
  %36 = extractvalue { i8*, i32 } %35, 0
  %37 = extractvalue { i8*, i32 } %35, 1
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %worker_matches_count.sroa.13.0..sroa_cast302.le)
  br label %if.then.i.i.i259

pfor.detach29:                                    ; preds = %pfor.inc, %pfor.detach29.preheader
  %indvars.iv436 = phi i64 [ %indvars.iv.next437, %pfor.inc ], [ 0, %pfor.detach29.preheader ]
  detach within %syncreg18, label %pfor.body33, label %pfor.inc unwind label %lpad45.loopexit

pfor.body33:                                      ; preds = %pfor.detach29
  %38 = trunc i64 %indvars.iv436 to i32
  %call38 = invoke i32 @_Z15get_valid_movesi(i32 %38)
          to label %invoke.cont37 unwind label %lpad34

invoke.cont37:                                    ; preds = %pfor.body33
  %add.ptr.i261 = getelementptr inbounds i32, i32* %cond.i.i.i.i198346350356, i64 %indvars.iv436
  store i32 %call38, i32* %add.ptr.i261, align 4, !tbaa !14
  %call42 = invoke i32 @_Z17get_matches_counti(i32 %38)
          to label %invoke.cont41 unwind label %lpad34

invoke.cont41:                                    ; preds = %invoke.cont37
  %add.ptr.i268 = getelementptr inbounds i32, i32* %cond.i.i.i.i240357, i64 %indvars.iv436
  store i32 %call42, i32* %add.ptr.i268, align 4, !tbaa !14
  reattach within %syncreg18, label %pfor.inc

pfor.inc:                                         ; preds = %invoke.cont41, %pfor.detach29
  %indvars.iv.next437 = add nuw nsw i64 %indvars.iv436, 1
  %exitcond = icmp ne i64 %indvars.iv.next437, %conv8
  br i1 %exitcond, label %pfor.detach29, label %pfor.cond.cleanup28.loopexit, !llvm.loop !16

lpad34:                                           ; preds = %invoke.cont37, %pfor.body33
  %.lcssa31 = phi i8* [ %30, %invoke.cont37 ], [ %30, %pfor.body33 ]
  %cond.i.i.i.i240357.lcssa26 = phi i32* [ %cond.i.i.i.i240357, %invoke.cont37 ], [ %cond.i.i.i.i240357, %pfor.body33 ]
  %.lcssa24 = phi i8* [ %31, %invoke.cont37 ], [ %31, %pfor.body33 ]
  %cond.i.i.i.i198346350356.lcssa19 = phi i32* [ %cond.i.i.i.i198346350356, %invoke.cont37 ], [ %cond.i.i.i.i198346350356, %pfor.body33 ]
  %worker_matches_count.sroa.13.0..sroa_cast302351355.lcssa15 = phi i8* [ %worker_matches_count.sroa.13.0..sroa_cast302351355, %invoke.cont37 ], [ %worker_matches_count.sroa.13.0..sroa_cast302351355, %pfor.body33 ]
  %39 = landingpad { i8*, i32 }
          catch i8* null
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg18, { i8*, i32 } %39)
          to label %det.rethrow.unreachable unwind label %lpad45.loopexit

det.rethrow.unreachable:                          ; preds = %lpad34
  unreachable

lpad45.loopexit:                                  ; preds = %pfor.detach29, %lpad34
  %.lcssa30 = phi i8* [ %30, %pfor.detach29 ], [ %30, %lpad34 ]
  %cond.i.i.i.i240357.lcssa = phi i32* [ %cond.i.i.i.i240357, %pfor.detach29 ], [ %cond.i.i.i.i240357, %lpad34 ]
  %.lcssa23 = phi i8* [ %31, %pfor.detach29 ], [ %31, %lpad34 ]
  %cond.i.i.i.i198346350356.lcssa = phi i32* [ %cond.i.i.i.i198346350356, %pfor.detach29 ], [ %cond.i.i.i.i198346350356, %lpad34 ]
  %worker_matches_count.sroa.13.0..sroa_cast302351355.lcssa = phi i8* [ %worker_matches_count.sroa.13.0..sroa_cast302351355, %pfor.detach29 ], [ %worker_matches_count.sroa.13.0..sroa_cast302351355, %lpad34 ]
  %lpad.loopexit = landingpad { i8*, i32 }
          catch i8* null
  br label %lpad45

lpad45:                                           ; preds = %lpad45.loopexit
  %40 = phi i8* [ %.lcssa30, %lpad45.loopexit ]
  %cond.i.i.i.i24035729 = phi i32* [ %cond.i.i.i.i240357.lcssa, %lpad45.loopexit ]
  %41 = phi i8* [ %.lcssa23, %lpad45.loopexit ]
  %cond.i.i.i.i19834635035622 = phi i32* [ %cond.i.i.i.i198346350356.lcssa, %lpad45.loopexit ]
  %worker_matches_count.sroa.13.0..sroa_cast30235135518 = phi i8* [ %worker_matches_count.sroa.13.0..sroa_cast302351355.lcssa, %lpad45.loopexit ]
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad45.loopexit ]
  %42 = extractvalue { i8*, i32 } %lpad.phi, 0
  %43 = extractvalue { i8*, i32 } %lpad.phi, 1
  sync within %syncreg18, label %ehcleanup

sync.continue:                                    ; preds = %pfor.cond.cleanup28
  %sub.ptr.sub.i275 = sub i64 %32, %29
  %sub.ptr.div.i276 = ashr exact i64 %sub.ptr.sub.i275, 2
  %cmp51399 = icmp eq i64 %sub.ptr.sub.i275, 0
  br i1 %cmp51399, label %invoke.cont67, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %sync.continue
  %44 = icmp ugt i64 %sub.ptr.div.i276, 1
  %umax = select i1 %44, i64 %sub.ptr.div.i276, i64 1
  %min.iters.check = icmp ult i64 %umax, 8
  br i1 %min.iters.check, label %for.body.preheader, label %vector.ph

vector.ph:                                        ; preds = %for.body.lr.ph
  %n.vec = and i64 %umax, -8
  %45 = add nsw i64 %n.vec, -8
  %46 = lshr exact i64 %45, 3
  %47 = add nuw nsw i64 %46, 1
  %xtraiter = and i64 %47, 1
  %48 = icmp eq i64 %45, 0
  br i1 %48, label %middle.block.unr-lcssa, label %vector.ph.new

vector.ph.new:                                    ; preds = %vector.ph
  %unroll_iter = sub nsw i64 %47, %xtraiter
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph.new
  %index = phi i64 [ 0, %vector.ph.new ], [ %index.next.1, %vector.body ]
  %vec.phi = phi <4 x i32> [ zeroinitializer, %vector.ph.new ], [ %65, %vector.body ]
  %vec.phi509 = phi <4 x i32> [ zeroinitializer, %vector.ph.new ], [ %66, %vector.body ]
  %vec.phi510 = phi <4 x i32> [ zeroinitializer, %vector.ph.new ], [ %71, %vector.body ]
  %vec.phi511 = phi <4 x i32> [ zeroinitializer, %vector.ph.new ], [ %72, %vector.body ]
  %niter = phi i64 [ %unroll_iter, %vector.ph.new ], [ %niter.nsub.1, %vector.body ]
  %49 = getelementptr inbounds i32, i32* %cond.i.i.i.i240357, i64 %index
  %50 = bitcast i32* %49 to <4 x i32>*
  %wide.load = load <4 x i32>, <4 x i32>* %50, align 4, !tbaa !14
  %51 = getelementptr i32, i32* %49, i64 4
  %52 = bitcast i32* %51 to <4 x i32>*
  %wide.load512 = load <4 x i32>, <4 x i32>* %52, align 4, !tbaa !14
  %53 = add nsw <4 x i32> %wide.load, %vec.phi
  %54 = add nsw <4 x i32> %wide.load512, %vec.phi509
  %55 = getelementptr inbounds i32, i32* %cond.i.i.i.i198346350356, i64 %index
  %56 = bitcast i32* %55 to <4 x i32>*
  %wide.load513 = load <4 x i32>, <4 x i32>* %56, align 4, !tbaa !14
  %57 = getelementptr i32, i32* %55, i64 4
  %58 = bitcast i32* %57 to <4 x i32>*
  %wide.load514 = load <4 x i32>, <4 x i32>* %58, align 4, !tbaa !14
  %59 = add nsw <4 x i32> %wide.load513, %vec.phi510
  %60 = add nsw <4 x i32> %wide.load514, %vec.phi511
  %index.next = or i64 %index, 8
  %61 = getelementptr inbounds i32, i32* %cond.i.i.i.i240357, i64 %index.next
  %62 = bitcast i32* %61 to <4 x i32>*
  %wide.load.1 = load <4 x i32>, <4 x i32>* %62, align 4, !tbaa !14
  %63 = getelementptr i32, i32* %61, i64 4
  %64 = bitcast i32* %63 to <4 x i32>*
  %wide.load512.1 = load <4 x i32>, <4 x i32>* %64, align 4, !tbaa !14
  %65 = add nsw <4 x i32> %wide.load.1, %53
  %66 = add nsw <4 x i32> %wide.load512.1, %54
  %67 = getelementptr inbounds i32, i32* %cond.i.i.i.i198346350356, i64 %index.next
  %68 = bitcast i32* %67 to <4 x i32>*
  %wide.load513.1 = load <4 x i32>, <4 x i32>* %68, align 4, !tbaa !14
  %69 = getelementptr i32, i32* %67, i64 4
  %70 = bitcast i32* %69 to <4 x i32>*
  %wide.load514.1 = load <4 x i32>, <4 x i32>* %70, align 4, !tbaa !14
  %71 = add nsw <4 x i32> %wide.load513.1, %59
  %72 = add nsw <4 x i32> %wide.load514.1, %60
  %index.next.1 = add i64 %index, 16
  %niter.nsub.1 = add i64 %niter, -2
  %niter.ncmp.1 = icmp eq i64 %niter.nsub.1, 0
  br i1 %niter.ncmp.1, label %middle.block.unr-lcssa.loopexit, label %vector.body, !llvm.loop !18

middle.block.unr-lcssa.loopexit:                  ; preds = %vector.body
  %.lcssa4 = phi <4 x i32> [ %65, %vector.body ]
  %.lcssa3 = phi <4 x i32> [ %66, %vector.body ]
  %.lcssa2 = phi <4 x i32> [ %71, %vector.body ]
  %.lcssa1 = phi <4 x i32> [ %72, %vector.body ]
  %index.next.1.lcssa = phi i64 [ %index.next.1, %vector.body ]
  br label %middle.block.unr-lcssa

middle.block.unr-lcssa:                           ; preds = %middle.block.unr-lcssa.loopexit, %vector.ph
  %.lcssa526.ph = phi <4 x i32> [ undef, %vector.ph ], [ %.lcssa4, %middle.block.unr-lcssa.loopexit ]
  %.lcssa525.ph = phi <4 x i32> [ undef, %vector.ph ], [ %.lcssa3, %middle.block.unr-lcssa.loopexit ]
  %.lcssa524.ph = phi <4 x i32> [ undef, %vector.ph ], [ %.lcssa2, %middle.block.unr-lcssa.loopexit ]
  %.lcssa.ph = phi <4 x i32> [ undef, %vector.ph ], [ %.lcssa1, %middle.block.unr-lcssa.loopexit ]
  %index.unr = phi i64 [ 0, %vector.ph ], [ %index.next.1.lcssa, %middle.block.unr-lcssa.loopexit ]
  %vec.phi.unr = phi <4 x i32> [ zeroinitializer, %vector.ph ], [ %.lcssa4, %middle.block.unr-lcssa.loopexit ]
  %vec.phi509.unr = phi <4 x i32> [ zeroinitializer, %vector.ph ], [ %.lcssa3, %middle.block.unr-lcssa.loopexit ]
  %vec.phi510.unr = phi <4 x i32> [ zeroinitializer, %vector.ph ], [ %.lcssa2, %middle.block.unr-lcssa.loopexit ]
  %vec.phi511.unr = phi <4 x i32> [ zeroinitializer, %vector.ph ], [ %.lcssa1, %middle.block.unr-lcssa.loopexit ]
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %middle.block, label %vector.body.epil

vector.body.epil:                                 ; preds = %middle.block.unr-lcssa
  %73 = getelementptr inbounds i32, i32* %cond.i.i.i.i240357, i64 %index.unr
  %74 = getelementptr inbounds i32, i32* %cond.i.i.i.i198346350356, i64 %index.unr
  %75 = getelementptr i32, i32* %74, i64 4
  %76 = bitcast i32* %75 to <4 x i32>*
  %wide.load514.epil = load <4 x i32>, <4 x i32>* %76, align 4, !tbaa !14
  %77 = add nsw <4 x i32> %wide.load514.epil, %vec.phi511.unr
  %78 = bitcast i32* %74 to <4 x i32>*
  %wide.load513.epil = load <4 x i32>, <4 x i32>* %78, align 4, !tbaa !14
  %79 = add nsw <4 x i32> %wide.load513.epil, %vec.phi510.unr
  %80 = getelementptr i32, i32* %73, i64 4
  %81 = bitcast i32* %80 to <4 x i32>*
  %wide.load512.epil = load <4 x i32>, <4 x i32>* %81, align 4, !tbaa !14
  %82 = add nsw <4 x i32> %wide.load512.epil, %vec.phi509.unr
  %83 = bitcast i32* %73 to <4 x i32>*
  %wide.load.epil = load <4 x i32>, <4 x i32>* %83, align 4, !tbaa !14
  %84 = add nsw <4 x i32> %wide.load.epil, %vec.phi.unr
  br label %middle.block

middle.block:                                     ; preds = %vector.body.epil, %middle.block.unr-lcssa
  %.lcssa526 = phi <4 x i32> [ %.lcssa526.ph, %middle.block.unr-lcssa ], [ %84, %vector.body.epil ]
  %.lcssa525 = phi <4 x i32> [ %.lcssa525.ph, %middle.block.unr-lcssa ], [ %82, %vector.body.epil ]
  %.lcssa524 = phi <4 x i32> [ %.lcssa524.ph, %middle.block.unr-lcssa ], [ %79, %vector.body.epil ]
  %.lcssa = phi <4 x i32> [ %.lcssa.ph, %middle.block.unr-lcssa ], [ %77, %vector.body.epil ]
  %bin.rdx518 = add <4 x i32> %.lcssa, %.lcssa524
  %rdx.shuf519 = shufflevector <4 x i32> %bin.rdx518, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %bin.rdx520 = add <4 x i32> %bin.rdx518, %rdx.shuf519
  %rdx.shuf521 = shufflevector <4 x i32> %bin.rdx520, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %bin.rdx522 = add <4 x i32> %bin.rdx520, %rdx.shuf521
  %85 = extractelement <4 x i32> %bin.rdx522, i32 0
  %bin.rdx = add <4 x i32> %.lcssa525, %.lcssa526
  %rdx.shuf = shufflevector <4 x i32> %bin.rdx, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %bin.rdx515 = add <4 x i32> %bin.rdx, %rdx.shuf
  %rdx.shuf516 = shufflevector <4 x i32> %bin.rdx515, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %bin.rdx517 = add <4 x i32> %bin.rdx515, %rdx.shuf516
  %86 = extractelement <4 x i32> %bin.rdx517, i32 0
  %cmp.n = icmp eq i64 %umax, %n.vec
  br i1 %cmp.n, label %invoke.cont67, label %for.body.preheader

for.body.preheader:                               ; preds = %middle.block, %for.body.lr.ph
  %indvars.iv438.ph = phi i64 [ 0, %for.body.lr.ph ], [ %n.vec, %middle.block ]
  %matches_count.0401.ph = phi i32 [ 0, %for.body.lr.ph ], [ %86, %middle.block ]
  %valid_moves.0400.ph = phi i32 [ 0, %for.body.lr.ph ], [ %85, %middle.block ]
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.preheader
  %indvars.iv438 = phi i64 [ %indvars.iv.next439, %for.body ], [ %indvars.iv438.ph, %for.body.preheader ]
  %matches_count.0401 = phi i32 [ %add54, %for.body ], [ %matches_count.0401.ph, %for.body.preheader ]
  %valid_moves.0400 = phi i32 [ %add57, %for.body ], [ %valid_moves.0400.ph, %for.body.preheader ]
  %add.ptr.i291 = getelementptr inbounds i32, i32* %cond.i.i.i.i240357, i64 %indvars.iv438
  %87 = load i32, i32* %add.ptr.i291, align 4, !tbaa !14
  %add54 = add nsw i32 %87, %matches_count.0401
  %add.ptr.i289 = getelementptr inbounds i32, i32* %cond.i.i.i.i198346350356, i64 %indvars.iv438
  %88 = load i32, i32* %add.ptr.i289, align 4, !tbaa !14
  %add57 = add nsw i32 %88, %valid_moves.0400
  %indvars.iv.next439 = add nuw i64 %indvars.iv438, 1
  %cmp51 = icmp ugt i64 %sub.ptr.div.i276, %indvars.iv.next439
  br i1 %cmp51, label %for.body, label %invoke.cont67.loopexit, !llvm.loop !20

invoke.cont67.loopexit:                           ; preds = %for.body
  %add54.lcssa = phi i32 [ %add54, %for.body ]
  %add57.lcssa = phi i32 [ %add57, %for.body ]
  br label %invoke.cont67

invoke.cont67:                                    ; preds = %invoke.cont67.loopexit, %middle.block, %sync.continue
  %valid_moves.0.lcssa = phi i32 [ 0, %sync.continue ], [ %85, %middle.block ], [ %add57.lcssa, %invoke.cont67.loopexit ]
  %matches_count.0.lcssa = phi i32 [ 0, %sync.continue ], [ %86, %middle.block ], [ %add54.lcssa, %invoke.cont67.loopexit ]
  %call59 = call i64 @clock() #8
  %sub60 = sub nsw i64 %call59, %call7
  %conv61 = sitofp i64 %sub60 to double
  %div62 = fdiv double %conv61, 1.000000e+06
  %89 = bitcast %"class.std::tuple"* %ref.tmp65 to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %89) #8
  %_M_head_impl.i.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %ref.tmp65, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  store i32 %matches_count.0.lcssa, i32* %_M_head_impl.i.i.i.i.i.i, align 8, !tbaa !22, !alias.scope !24
  %90 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %ref.tmp65, i64 0, i32 0, i32 0, i32 1, i32 0
  store double %div62, double* %90, align 8, !tbaa !27, !alias.scope !24
  %91 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %ref.tmp65, i64 0, i32 0, i32 1, i32 0
  store i32 %valid_moves.0.lcssa, i32* %91, align 8, !tbaa !30, !alias.scope !24
  %_M_finish.i.i284 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %cond.i.i.i.i339, i64 %indvars.iv440, i32 0, i32 0, i32 1
  %92 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_finish.i.i284, align 8, !tbaa !12
  %_M_end_of_storage.i.i285 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %cond.i.i.i.i339, i64 %indvars.iv440, i32 0, i32 0, i32 2
  %93 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_end_of_storage.i.i285, align 8, !tbaa !13
  %cmp.i.i = icmp eq %"class.std::tuple"* %92, %93
  br i1 %cmp.i.i, label %if.else.i.i, label %if.then.i.i286

if.then.i.i286:                                   ; preds = %invoke.cont67
  %_M_head_impl.i.i6.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %92, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  store i32 %matches_count.0.lcssa, i32* %_M_head_impl.i.i6.i.i.i.i.i.i.i, align 4, !tbaa !22
  %94 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %92, i64 0, i32 0, i32 0, i32 1, i32 0
  store double %div62, double* %94, align 8, !tbaa !27
  %95 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %92, i64 0, i32 0, i32 1, i32 0
  %96 = load i32, i32* %91, align 8, !tbaa !14
  store i32 %96, i32* %95, align 4, !tbaa !30
  %incdec.ptr.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %92, i64 1
  store %"class.std::tuple"* %incdec.ptr.i.i, %"class.std::tuple"** %_M_finish.i.i284, align 8, !tbaa !12
  br label %invoke.cont68

if.else.i.i:                                      ; preds = %invoke.cont67
  %add.ptr.i283 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %cond.i.i.i.i339, i64 %indvars.iv440
  invoke void @_ZNSt6vectorISt5tupleIJidiEESaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_(%"class.std::vector.0"* nonnull %add.ptr.i283, %"class.std::tuple"* %92, %"class.std::tuple"* nonnull dereferenceable(24) %ref.tmp65)
          to label %invoke.cont68 unwind label %lpad66

invoke.cont68:                                    ; preds = %if.else.i.i, %if.then.i.i286
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %89) #8
  %tobool.i.i.i278 = icmp eq i32* %cond.i.i.i.i240357, null
  br i1 %tobool.i.i.i278, label %_ZNSt6vectorIiSaIiEED2Ev.exit281, label %if.then.i.i.i280

if.then.i.i.i280:                                 ; preds = %invoke.cont68
  call void @_ZdlPv(i8* %30) #8
  br label %_ZNSt6vectorIiSaIiEED2Ev.exit281

_ZNSt6vectorIiSaIiEED2Ev.exit281:                 ; preds = %if.then.i.i.i280, %invoke.cont68
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %worker_matches_count.sroa.13.0..sroa_cast302351355)
  %tobool.i.i.i270 = icmp eq i32* %cond.i.i.i.i198346350356, null
  br i1 %tobool.i.i.i270, label %_ZNSt6vectorIiSaIiEED2Ev.exit273, label %if.then.i.i.i272

if.then.i.i.i272:                                 ; preds = %_ZNSt6vectorIiSaIiEED2Ev.exit281
  call void @_ZdlPv(i8* %31) #8
  br label %_ZNSt6vectorIiSaIiEED2Ev.exit273

_ZNSt6vectorIiSaIiEED2Ev.exit273:                 ; preds = %if.then.i.i.i272, %_ZNSt6vectorIiSaIiEED2Ev.exit281
  reattach within %syncreg, label %pfor.inc78

pfor.inc78:                                       ; preds = %_ZNSt6vectorIiSaIiEED2Ev.exit273, %pfor.detach
  %indvars.iv.next441 = add nuw nsw i64 %indvars.iv440, 1
  %exitcond33 = icmp ne i64 %indvars.iv.next441, %16
  br i1 %exitcond33, label %pfor.detach, label %pfor.cond.cleanup.loopexit, !llvm.loop !32

lpad66:                                           ; preds = %if.else.i.i
  %.lcssa32 = phi i8* [ %30, %if.else.i.i ]
  %cond.i.i.i.i240357.lcssa27 = phi i32* [ %cond.i.i.i.i240357, %if.else.i.i ]
  %.lcssa25 = phi i8* [ %31, %if.else.i.i ]
  %cond.i.i.i.i198346350356.lcssa20 = phi i32* [ %cond.i.i.i.i198346350356, %if.else.i.i ]
  %worker_matches_count.sroa.13.0..sroa_cast302351355.lcssa16 = phi i8* [ %worker_matches_count.sroa.13.0..sroa_cast302351355, %if.else.i.i ]
  %ref.tmp65.lcssa9 = phi %"class.std::tuple"* [ %ref.tmp65, %if.else.i.i ]
  %97 = landingpad { i8*, i32 }
          catch i8* null
  %98 = bitcast %"class.std::tuple"* %ref.tmp65.lcssa9 to i8*
  %99 = extractvalue { i8*, i32 } %97, 0
  %100 = extractvalue { i8*, i32 } %97, 1
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %98) #8
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad66, %lpad45
  %101 = phi i8* [ %.lcssa32, %lpad66 ], [ %40, %lpad45 ]
  %cond.i.i.i.i24035728 = phi i32* [ %cond.i.i.i.i240357.lcssa27, %lpad66 ], [ %cond.i.i.i.i24035729, %lpad45 ]
  %102 = phi i8* [ %.lcssa25, %lpad66 ], [ %41, %lpad45 ]
  %cond.i.i.i.i19834635035621 = phi i32* [ %cond.i.i.i.i198346350356.lcssa20, %lpad66 ], [ %cond.i.i.i.i19834635035622, %lpad45 ]
  %worker_matches_count.sroa.13.0..sroa_cast30235135517 = phi i8* [ %worker_matches_count.sroa.13.0..sroa_cast302351355.lcssa16, %lpad66 ], [ %worker_matches_count.sroa.13.0..sroa_cast30235135518, %lpad45 ]
  %exn.slot11.0 = phi i8* [ %99, %lpad66 ], [ %42, %lpad45 ]
  %ehselector.slot12.0 = phi i32 [ %100, %lpad66 ], [ %43, %lpad45 ]
  %tobool.i.i.i263 = icmp eq i32* %cond.i.i.i.i24035728, null
  br i1 %tobool.i.i.i263, label %ehcleanup69, label %if.then.i.i.i265

if.then.i.i.i265:                                 ; preds = %ehcleanup
  call void @_ZdlPv(i8* %101) #8
  br label %ehcleanup69

ehcleanup69:                                      ; preds = %if.then.i.i.i265, %ehcleanup
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %worker_matches_count.sroa.13.0..sroa_cast30235135517)
  %tobool.i.i.i257 = icmp eq i32* %cond.i.i.i.i19834635035621, null
  br i1 %tobool.i.i.i257, label %ehcleanup71, label %if.then.i.i.i259

if.then.i.i.i259:                                 ; preds = %ehcleanup69, %ehcleanup69.thread
  %ehselector.slot12.1364 = phi i32 [ %37, %ehcleanup69.thread ], [ %ehselector.slot12.0, %ehcleanup69 ]
  %exn.slot11.1362 = phi i8* [ %36, %ehcleanup69.thread ], [ %exn.slot11.0, %ehcleanup69 ]
  %103 = phi i8* [ %call2.i.i.i.i3.i.i206.lcssa, %ehcleanup69.thread ], [ %102, %ehcleanup69 ]
  call void @_ZdlPv(i8* %103) #8
  br label %ehcleanup71

ehcleanup71:                                      ; preds = %if.then.i.i.i259, %ehcleanup69, %lpad10
  %exn.slot11.2 = phi i8* [ %33, %lpad10 ], [ %exn.slot11.0, %ehcleanup69 ], [ %exn.slot11.1362, %if.then.i.i.i259 ]
  %ehselector.slot12.2 = phi i32 [ %34, %lpad10 ], [ %ehselector.slot12.0, %ehcleanup69 ], [ %ehselector.slot12.1364, %if.then.i.i.i259 ]
  %lpad.val83 = insertvalue { i8*, i32 } undef, i8* %exn.slot11.2, 0
  %lpad.val84 = insertvalue { i8*, i32 } %lpad.val83, i32 %ehselector.slot12.2, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %lpad.val84)
          to label %det.rethrow.unreachable86 unwind label %lpad80.loopexit

det.rethrow.unreachable86:                        ; preds = %ehcleanup71
  unreachable

lpad80.loopexit:                                  ; preds = %pfor.detach, %ehcleanup71
  %lpad.loopexit367 = landingpad { i8*, i32 }
          cleanup
  br label %lpad80

lpad80:                                           ; preds = %lpad80.loopexit
  %lpad.phi369 = phi { i8*, i32 } [ %lpad.loopexit367, %lpad80.loopexit ]
  %104 = extractvalue { i8*, i32 } %lpad.phi369, 0
  %105 = extractvalue { i8*, i32 } %lpad.phi369, 1
  sync within %syncreg, label %ehcleanup123

sync.continue87:                                  ; preds = %pfor.cond.cleanup
  %sub.ptr.sub.i254 = sub i64 %17, %19
  %sub.ptr.div.i255 = sdiv exact i64 %sub.ptr.sub.i254, 24
  %106 = icmp eq i64 %sub.ptr.sub.i254, 0
  br i1 %106, label %for.cond.cleanup99, label %for.body100.lr.ph

for.body100.lr.ph:                                ; preds = %sync.continue87
  %_M_finish.i188 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %agg.result, i64 0, i32 0, i32 0, i32 1
  br label %for.body100

for.cond.cleanup99.loopexit:                      ; preds = %for.cond.cleanup107
  br label %for.cond.cleanup99

for.cond.cleanup99:                               ; preds = %for.cond.cleanup99.loopexit, %sync.continue87
  %cmp3.i.i.i.i218 = icmp eq %"class.std::vector.0"* %cond.i.i.i.i339453, %__cur.0.lcssa.i.i.i.i.i461
  br i1 %cmp3.i.i.i.i218, label %invoke.cont.i231, label %for.body.i.i.i.i223.preheader

for.body.i.i.i.i223.preheader:                    ; preds = %for.cond.cleanup99
  br label %for.body.i.i.i.i223

for.body.i.i.i.i223:                              ; preds = %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i227, %for.body.i.i.i.i223.preheader
  %__first.addr.04.i.i.i.i220 = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i225, %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i227 ], [ %cond.i.i.i.i339453, %for.body.i.i.i.i223.preheader ]
  %_M_start.i.i.i.i.i.i.i221 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i220, i64 0, i32 0, i32 0, i32 0
  %107 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_start.i.i.i.i.i.i.i221, align 8, !tbaa !9
  %tobool.i.i.i.i.i.i.i.i222 = icmp eq %"class.std::tuple"* %107, null
  br i1 %tobool.i.i.i.i.i.i.i.i222, label %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i227, label %if.then.i.i.i.i.i.i.i.i224

if.then.i.i.i.i.i.i.i.i224:                       ; preds = %for.body.i.i.i.i223
  %108 = bitcast %"class.std::tuple"* %107 to i8*
  call void @_ZdlPv(i8* %108) #8
  br label %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i227

_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i227: ; preds = %if.then.i.i.i.i.i.i.i.i224, %for.body.i.i.i.i223
  %incdec.ptr.i.i.i.i225 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i220, i64 1
  %cmp.i.i.i.i226 = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i225, %__cur.0.lcssa.i.i.i.i.i461
  br i1 %cmp.i.i.i.i226, label %invoke.cont.i231.loopexit, label %for.body.i.i.i.i223

invoke.cont.i231.loopexit:                        ; preds = %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i227
  br label %invoke.cont.i231

invoke.cont.i231:                                 ; preds = %invoke.cont.i231.loopexit, %for.cond.cleanup99
  %tobool.i.i.i230 = icmp eq %"class.std::vector.0"* %cond.i.i.i.i339453, null
  br i1 %tobool.i.i.i230, label %_ZNSt6vectorIS_ISt5tupleIJidiEESaIS1_EESaIS3_EED2Ev.exit233, label %if.then.i.i.i232

if.then.i.i.i232:                                 ; preds = %invoke.cont.i231
  call void @_ZdlPv(i8* %18) #8
  br label %_ZNSt6vectorIS_ISt5tupleIJidiEESaIS1_EESaIS3_EED2Ev.exit233

_ZNSt6vectorIS_ISt5tupleIJidiEESaIS1_EESaIS3_EED2Ev.exit233: ; preds = %if.then.i.i.i232, %invoke.cont.i231
  ret void

for.body100:                                      ; preds = %for.cond.cleanup107, %for.body100.lr.ph
  %indvars.iv434 = phi i64 [ 0, %for.body100.lr.ph ], [ %indvars.iv.next435, %for.cond.cleanup107 ]
  %add.ptr.i215 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %cond.i.i.i.i339453, i64 %indvars.iv434
  %_M_finish.i211 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %cond.i.i.i.i339453, i64 %indvars.iv434, i32 0, i32 0, i32 1
  %109 = bitcast %"class.std::tuple"** %_M_finish.i211 to i64*
  %110 = load i64, i64* %109, align 8, !tbaa !12
  %111 = bitcast %"class.std::vector.0"* %add.ptr.i215 to i64*
  %112 = load i64, i64* %111, align 8, !tbaa !9
  %113 = icmp eq i64 %110, %112
  br i1 %113, label %for.cond.cleanup107, label %for.body108.preheader

for.body108.preheader:                            ; preds = %for.body100
  br label %for.body108

for.cond.cleanup107.loopexit:                     ; preds = %for.inc115
  br label %for.cond.cleanup107

for.cond.cleanup107:                              ; preds = %for.cond.cleanup107.loopexit, %for.body100
  %indvars.iv.next435 = add nuw i64 %indvars.iv434, 1
  %cmp98 = icmp ugt i64 %sub.ptr.div.i255, %indvars.iv.next435
  br i1 %cmp98, label %for.body100, label %for.cond.cleanup99.loopexit

for.body108:                                      ; preds = %for.inc115, %for.body108.preheader
  %.in = phi i64 [ %121, %for.inc115 ], [ %112, %for.body108.preheader ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.inc115 ], [ 0, %for.body108.preheader ]
  %114 = inttoptr i64 %.in to %"class.std::tuple"*
  %add.ptr.i208 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %114, i64 %indvars.iv
  %115 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_finish.i188, align 8, !tbaa !12
  %116 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_end_of_storage.i.i, align 8, !tbaa !13
  %cmp.i189 = icmp eq %"class.std::tuple"* %115, %116
  br i1 %cmp.i189, label %if.else.i, label %if.then.i190

if.then.i190:                                     ; preds = %for.body108
  %117 = bitcast %"class.std::tuple"* %115 to i8*
  %118 = bitcast %"class.std::tuple"* %add.ptr.i208 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %117, i8* nonnull %118, i64 24, i32 8, i1 false) #8
  %119 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_finish.i188, align 8, !tbaa !12
  %incdec.ptr.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %119, i64 1
  store %"class.std::tuple"* %incdec.ptr.i, %"class.std::tuple"** %_M_finish.i188, align 8, !tbaa !12
  br label %for.inc115

if.else.i:                                        ; preds = %for.body108
  invoke void @_ZNSt6vectorISt5tupleIJidiEESaIS1_EE17_M_realloc_insertIJRKS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_(%"class.std::vector.0"* nonnull %agg.result, %"class.std::tuple"* %115, %"class.std::tuple"* nonnull dereferenceable(24) %add.ptr.i208)
          to label %for.inc115 unwind label %lpad113

for.inc115:                                       ; preds = %if.else.i, %if.then.i190
  %indvars.iv.next = add nuw i64 %indvars.iv, 1
  %120 = load i64, i64* %109, align 8, !tbaa !12
  %121 = load i64, i64* %111, align 8, !tbaa !9
  %sub.ptr.sub.i212 = sub i64 %120, %121
  %sub.ptr.div.i213 = sdiv exact i64 %sub.ptr.sub.i212, 24
  %cmp106 = icmp ugt i64 %sub.ptr.div.i213, %indvars.iv.next
  br i1 %cmp106, label %for.body108, label %for.cond.cleanup107.loopexit

lpad113:                                          ; preds = %if.else.i
  %122 = landingpad { i8*, i32 }
          cleanup
  %123 = extractvalue { i8*, i32 } %122, 0
  %124 = extractvalue { i8*, i32 } %122, 1
  br label %ehcleanup123

ehcleanup123:                                     ; preds = %lpad113, %lpad80
  %__cur.0.lcssa.i.i.i.i.i460 = phi %"class.std::vector.0"* [ %__cur.0.lcssa.i.i.i.i.i461, %lpad113 ], [ %__cur.0.lcssa.i.i.i.i.i, %lpad80 ]
  %cond.i.i.i.i339455 = phi %"class.std::vector.0"* [ %cond.i.i.i.i339453, %lpad113 ], [ %cond.i.i.i.i339, %lpad80 ]
  %125 = phi i8* [ %18, %lpad113 ], [ %14, %lpad80 ]
  %ehselector.slot.0 = phi i32 [ %124, %lpad113 ], [ %105, %lpad80 ]
  %exn.slot.0 = phi i8* [ %123, %lpad113 ], [ %104, %lpad80 ]
  %cmp3.i.i.i.i = icmp eq %"class.std::vector.0"* %cond.i.i.i.i339455, %__cur.0.lcssa.i.i.i.i.i460
  br i1 %cmp3.i.i.i.i, label %invoke.cont.i, label %for.body.i.i.i.i.preheader

for.body.i.i.i.i.preheader:                       ; preds = %ehcleanup123
  br label %for.body.i.i.i.i

for.body.i.i.i.i:                                 ; preds = %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i, %for.body.i.i.i.i.preheader
  %__first.addr.04.i.i.i.i = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i, %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i ], [ %cond.i.i.i.i339455, %for.body.i.i.i.i.preheader ]
  %_M_start.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i, i64 0, i32 0, i32 0, i32 0
  %126 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_start.i.i.i.i.i.i.i, align 8, !tbaa !9
  %tobool.i.i.i.i.i.i.i.i = icmp eq %"class.std::tuple"* %126, null
  br i1 %tobool.i.i.i.i.i.i.i.i, label %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i:                          ; preds = %for.body.i.i.i.i
  %127 = bitcast %"class.std::tuple"* %126 to i8*
  call void @_ZdlPv(i8* %127) #8
  br label %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i

_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i: ; preds = %if.then.i.i.i.i.i.i.i.i, %for.body.i.i.i.i
  %incdec.ptr.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i, i64 1
  %cmp.i.i.i.i = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i, %__cur.0.lcssa.i.i.i.i.i460
  br i1 %cmp.i.i.i.i, label %invoke.cont.i.loopexit, label %for.body.i.i.i.i

invoke.cont.i.loopexit:                           ; preds = %_ZSt8_DestroyISt6vectorISt5tupleIJidiEESaIS2_EEEvPT_.exit.i.i.i.i
  br label %invoke.cont.i

invoke.cont.i:                                    ; preds = %invoke.cont.i.loopexit, %ehcleanup123
  %tobool.i.i.i176 = icmp eq %"class.std::vector.0"* %cond.i.i.i.i339455, null
  br i1 %tobool.i.i.i176, label %ehcleanup126, label %if.then.i.i.i177

if.then.i.i.i177:                                 ; preds = %invoke.cont.i
  call void @_ZdlPv(i8* %125) #8
  br label %ehcleanup126

ehcleanup126:                                     ; preds = %if.then.i.i.i177, %invoke.cont.i, %lpad3, %lpad
  %ehselector.slot.2 = phi i32 [ %22, %lpad ], [ %25, %lpad3 ], [ %ehselector.slot.0, %invoke.cont.i ], [ %ehselector.slot.0, %if.then.i.i.i177 ]
  %exn.slot.2 = phi i8* [ %21, %lpad ], [ %24, %lpad3 ], [ %exn.slot.0, %invoke.cont.i ], [ %exn.slot.0, %if.then.i.i.i177 ]
  %_M_start.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %agg.result, i64 0, i32 0, i32 0, i32 0
  %128 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_start.i.i, align 8, !tbaa !9
  %tobool.i.i.i = icmp eq %"class.std::tuple"* %128, null
  br i1 %tobool.i.i.i, label %_ZNSt6vectorISt5tupleIJidiEESaIS1_EED2Ev.exit, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %ehcleanup126
  %129 = bitcast %"class.std::tuple"* %128 to i8*
  call void @_ZdlPv(i8* %129) #8
  br label %_ZNSt6vectorISt5tupleIJidiEESaIS1_EED2Ev.exit

_ZNSt6vectorISt5tupleIJidiEESaIS1_EED2Ev.exit:    ; preds = %if.then.i.i.i, %ehcleanup126
  %lpad.val129 = insertvalue { i8*, i32 } undef, i8* %exn.slot.2, 0
  %lpad.val130 = insertvalue { i8*, i32 } %lpad.val129, i32 %ehselector.slot.2, 1
  resume { i8*, i32 } %lpad.val130
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #1

; Function Attrs: nounwind
declare i64 @clock() local_unnamed_addr #2

declare i32 @_Z15get_valid_movesi(i32) local_unnamed_addr #3

declare i32 @_Z17get_matches_counti(i32) local_unnamed_addr #3

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #4

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPv(i8*) local_unnamed_addr #5

; Function Attrs: noreturn
declare void @_ZSt20__throw_length_errorPKc(i8*) local_unnamed_addr #6

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #1

; Function Attrs: noreturn
declare void @_ZSt17__throw_bad_allocv() local_unnamed_addr #6

; Function Attrs: nobuiltin
declare noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #7

; Function Attrs: uwtable
define linkonce_odr void @_ZNSt6vectorISt5tupleIJidiEESaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_(%"class.std::vector.0"* %this, %"class.std::tuple"* %__position.coerce, %"class.std::tuple"* dereferenceable(24) %__args) local_unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %0 = ptrtoint %"class.std::tuple"* %__position.coerce to i64
  %_M_finish.i20.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %this, i64 0, i32 0, i32 0, i32 1
  %1 = bitcast %"class.std::tuple"** %_M_finish.i20.i to i64*
  %2 = load i64, i64* %1, align 8, !tbaa !12
  %3 = bitcast %"class.std::vector.0"* %this to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !33
  %sub.ptr.sub.i21.i = sub i64 %2, %4
  %sub.ptr.div.i22.i = sdiv exact i64 %sub.ptr.sub.i21.i, 24
  %5 = icmp eq i64 %sub.ptr.sub.i21.i, 0
  %.sroa.speculated.i = select i1 %5, i64 1, i64 %sub.ptr.div.i22.i
  %add.i = add nsw i64 %.sroa.speculated.i, %sub.ptr.div.i22.i
  %cmp7.i = icmp ult i64 %add.i, %sub.ptr.div.i22.i
  %cmp9.i = icmp ugt i64 %add.i, 768614336404564650
  %or.cond.i = or i1 %cmp7.i, %cmp9.i
  %cond.i = select i1 %or.cond.i, i64 768614336404564650, i64 %add.i
  %sub.ptr.sub.i = sub i64 %0, %4
  %sub.ptr.div.i = sdiv exact i64 %sub.ptr.sub.i, 24
  %cmp.i.i.i = icmp ugt i64 %cond.i, 768614336404564650
  br i1 %cmp.i.i.i, label %if.then.i.i.i, label %_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i

if.then.i.i.i:                                    ; preds = %entry
  tail call void @_ZSt17__throw_bad_allocv() #9
  unreachable

_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i: ; preds = %entry
  %6 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %this, i64 0, i32 0, i32 0, i32 0
  %mul.i.i.i = mul i64 %cond.i, 24
  %call2.i.i.i = tail call i8* @_Znwm(i64 %mul.i.i.i)
  %7 = bitcast i8* %call2.i.i.i to %"class.std::tuple"*
  %_M_head_impl.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__args, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %_M_head_impl.i.i6.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %7, i64 %sub.ptr.div.i, i32 0, i32 0, i32 0, i32 0, i32 0
  %8 = load i32, i32* %_M_head_impl.i.i.i.i.i.i.i.i, align 4, !tbaa !14
  store i32 %8, i32* %_M_head_impl.i.i6.i.i.i.i.i, align 4, !tbaa !22
  %9 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %7, i64 %sub.ptr.div.i, i32 0, i32 0, i32 1
  %10 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__args, i64 0, i32 0, i32 0, i32 1, i32 0
  %11 = bitcast double* %10 to i64*
  %12 = load i64, i64* %11, align 8, !tbaa !34
  %13 = bitcast %"struct.std::_Head_base.7"* %9 to i64*
  store i64 %12, i64* %13, align 8, !tbaa !27
  %14 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__args, i64 0, i32 0, i32 1, i32 0
  %15 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %7, i64 %sub.ptr.div.i, i32 0, i32 1, i32 0
  %16 = load i32, i32* %14, align 4, !tbaa !14
  store i32 %16, i32* %15, align 4, !tbaa !30
  %17 = load %"class.std::tuple"*, %"class.std::tuple"** %6, align 8, !tbaa !9
  %cmp.i.i21.i.i.i.i73 = icmp eq %"class.std::tuple"* %17, %__position.coerce
  br i1 %cmp.i.i21.i.i.i.i73, label %invoke.cont10, label %for.body.i.i.i.i82.preheader

for.body.i.i.i.i82.preheader:                     ; preds = %_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i
  br label %for.body.i.i.i.i82

for.body.i.i.i.i82:                               ; preds = %for.body.i.i.i.i82, %for.body.i.i.i.i82.preheader
  %__cur.023.i.i.i.i75 = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i80, %for.body.i.i.i.i82 ], [ %7, %for.body.i.i.i.i82.preheader ]
  %__first.sroa.0.022.i.i.i.i76 = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i.i79, %for.body.i.i.i.i82 ], [ %17, %for.body.i.i.i.i82.preheader ]
  %_M_head_impl.i.i.i.i.i.i.i.i.i.i.i77 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i76, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %_M_head_impl.i.i6.i.i.i.i.i.i.i.i78 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i75, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %18 = load i32, i32* %_M_head_impl.i.i.i.i.i.i.i.i.i.i.i77, align 4, !tbaa !14
  store i32 %18, i32* %_M_head_impl.i.i6.i.i.i.i.i.i.i.i78, align 4, !tbaa !22
  %19 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i75, i64 0, i32 0, i32 0, i32 1
  %20 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i76, i64 0, i32 0, i32 0, i32 1, i32 0
  %21 = bitcast double* %20 to i64*
  %22 = load i64, i64* %21, align 8, !tbaa !34
  %23 = bitcast %"struct.std::_Head_base.7"* %19 to i64*
  store i64 %22, i64* %23, align 8, !tbaa !27
  %24 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i76, i64 0, i32 0, i32 1, i32 0
  %25 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i75, i64 0, i32 0, i32 1, i32 0
  %26 = load i32, i32* %24, align 4, !tbaa !14
  store i32 %26, i32* %25, align 4, !tbaa !30
  %incdec.ptr.i.i.i.i.i79 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i76, i64 1
  %incdec.ptr.i.i.i.i80 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i75, i64 1
  %cmp.i.i.i.i.i.i81 = icmp eq %"class.std::tuple"* %incdec.ptr.i.i.i.i.i79, %__position.coerce
  br i1 %cmp.i.i.i.i.i.i81, label %invoke.cont10.loopexit, label %for.body.i.i.i.i82

invoke.cont10.loopexit:                           ; preds = %for.body.i.i.i.i82
  %incdec.ptr.i.i.i.i80.lcssa = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i80, %for.body.i.i.i.i82 ]
  br label %invoke.cont10

invoke.cont10:                                    ; preds = %invoke.cont10.loopexit, %_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i
  %__cur.0.lcssa.i.i.i.i83 = phi %"class.std::tuple"* [ %7, %_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i ], [ %incdec.ptr.i.i.i.i80.lcssa, %invoke.cont10.loopexit ]
  %incdec.ptr = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.0.lcssa.i.i.i.i83, i64 1
  %27 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_finish.i20.i, align 8, !tbaa !12
  %cmp.i.i21.i.i.i.i = icmp eq %"class.std::tuple"* %27, %__position.coerce
  br i1 %cmp.i.i21.i.i.i.i, label %invoke.cont15, label %for.body.i.i.i.i.preheader

for.body.i.i.i.i.preheader:                       ; preds = %invoke.cont10
  br label %for.body.i.i.i.i

for.body.i.i.i.i:                                 ; preds = %for.body.i.i.i.i, %for.body.i.i.i.i.preheader
  %__cur.023.i.i.i.i = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i, %for.body.i.i.i.i ], [ %incdec.ptr, %for.body.i.i.i.i.preheader ]
  %__first.sroa.0.022.i.i.i.i = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i.i, %for.body.i.i.i.i ], [ %__position.coerce, %for.body.i.i.i.i.preheader ]
  %_M_head_impl.i.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %_M_head_impl.i.i6.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %28 = load i32, i32* %_M_head_impl.i.i.i.i.i.i.i.i.i.i.i, align 4, !tbaa !14
  store i32 %28, i32* %_M_head_impl.i.i6.i.i.i.i.i.i.i.i, align 4, !tbaa !22
  %29 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i, i64 0, i32 0, i32 0, i32 1
  %30 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i, i64 0, i32 0, i32 0, i32 1, i32 0
  %31 = bitcast double* %30 to i64*
  %32 = load i64, i64* %31, align 8, !tbaa !34
  %33 = bitcast %"struct.std::_Head_base.7"* %29 to i64*
  store i64 %32, i64* %33, align 8, !tbaa !27
  %34 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i, i64 0, i32 0, i32 1, i32 0
  %35 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i, i64 0, i32 0, i32 1, i32 0
  %36 = load i32, i32* %34, align 4, !tbaa !14
  store i32 %36, i32* %35, align 4, !tbaa !30
  %incdec.ptr.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i, i64 1
  %incdec.ptr.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i, i64 1
  %cmp.i.i.i.i.i.i = icmp eq %"class.std::tuple"* %incdec.ptr.i.i.i.i.i, %27
  br i1 %cmp.i.i.i.i.i.i, label %invoke.cont15.loopexit, label %for.body.i.i.i.i

invoke.cont15.loopexit:                           ; preds = %for.body.i.i.i.i
  %incdec.ptr.i.i.i.i.lcssa = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i, %for.body.i.i.i.i ]
  br label %invoke.cont15

invoke.cont15:                                    ; preds = %invoke.cont15.loopexit, %invoke.cont10
  %__cur.0.lcssa.i.i.i.i = phi %"class.std::tuple"* [ %incdec.ptr, %invoke.cont10 ], [ %incdec.ptr.i.i.i.i.lcssa, %invoke.cont15.loopexit ]
  %_M_end_of_storage = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %this, i64 0, i32 0, i32 0, i32 2
  %tobool.i69 = icmp eq %"class.std::tuple"* %17, null
  br i1 %tobool.i69, label %_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE13_M_deallocateEPS1_m.exit71, label %if.then.i70

if.then.i70:                                      ; preds = %invoke.cont15
  %37 = bitcast %"class.std::tuple"* %17 to i8*
  tail call void @_ZdlPv(i8* %37) #8
  br label %_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE13_M_deallocateEPS1_m.exit71

_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE13_M_deallocateEPS1_m.exit71: ; preds = %if.then.i70, %invoke.cont15
  %38 = bitcast %"class.std::vector.0"* %this to i8**
  store i8* %call2.i.i.i, i8** %38, align 8, !tbaa !9
  store %"class.std::tuple"* %__cur.0.lcssa.i.i.i.i, %"class.std::tuple"** %_M_finish.i20.i, align 8, !tbaa !12
  %add.ptr39 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %7, i64 %cond.i
  store %"class.std::tuple"* %add.ptr39, %"class.std::tuple"** %_M_end_of_storage, align 8, !tbaa !13
  ret void
}

; Function Attrs: uwtable
define linkonce_odr void @_ZNSt6vectorISt5tupleIJidiEESaIS1_EE17_M_realloc_insertIJRKS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_(%"class.std::vector.0"* %this, %"class.std::tuple"* %__position.coerce, %"class.std::tuple"* dereferenceable(24) %__args) local_unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %0 = ptrtoint %"class.std::tuple"* %__position.coerce to i64
  %_M_finish.i20.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %this, i64 0, i32 0, i32 0, i32 1
  %1 = bitcast %"class.std::tuple"** %_M_finish.i20.i to i64*
  %2 = load i64, i64* %1, align 8, !tbaa !12
  %3 = bitcast %"class.std::vector.0"* %this to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !33
  %sub.ptr.sub.i21.i = sub i64 %2, %4
  %sub.ptr.div.i22.i = sdiv exact i64 %sub.ptr.sub.i21.i, 24
  %5 = icmp eq i64 %sub.ptr.sub.i21.i, 0
  %.sroa.speculated.i = select i1 %5, i64 1, i64 %sub.ptr.div.i22.i
  %add.i = add nsw i64 %.sroa.speculated.i, %sub.ptr.div.i22.i
  %cmp7.i = icmp ult i64 %add.i, %sub.ptr.div.i22.i
  %cmp9.i = icmp ugt i64 %add.i, 768614336404564650
  %or.cond.i = or i1 %cmp7.i, %cmp9.i
  %cond.i = select i1 %or.cond.i, i64 768614336404564650, i64 %add.i
  %6 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %this, i64 0, i32 0, i32 0, i32 0
  %sub.ptr.sub.i = sub i64 %0, %4
  %sub.ptr.div.i = sdiv exact i64 %sub.ptr.sub.i, 24
  %cmp.i67 = icmp eq i64 %cond.i, 0
  %7 = inttoptr i64 %4 to %"class.std::tuple"*
  br i1 %cmp.i67, label %invoke.cont, label %cond.true.i

cond.true.i:                                      ; preds = %entry
  %cmp.i.i.i = icmp ugt i64 %cond.i, 768614336404564650
  br i1 %cmp.i.i.i, label %if.then.i.i.i, label %_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i

if.then.i.i.i:                                    ; preds = %cond.true.i
  tail call void @_ZSt17__throw_bad_allocv() #9
  unreachable

_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i: ; preds = %cond.true.i
  %mul.i.i.i = mul i64 %cond.i, 24
  %call2.i.i.i = tail call i8* @_Znwm(i64 %mul.i.i.i)
  %8 = bitcast i8* %call2.i.i.i to %"class.std::tuple"*
  %.pre = load %"class.std::tuple"*, %"class.std::tuple"** %6, align 8, !tbaa !9
  br label %invoke.cont

invoke.cont:                                      ; preds = %_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i, %entry
  %9 = phi %"class.std::tuple"* [ %.pre, %_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i ], [ %7, %entry ]
  %cond.i68 = phi %"class.std::tuple"* [ %8, %_ZNSt16allocator_traitsISaISt5tupleIJidiEEEE8allocateERS2_m.exit.i ], [ null, %entry ]
  %add.ptr = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %cond.i68, i64 %sub.ptr.div.i
  %10 = bitcast %"class.std::tuple"* %add.ptr to i8*
  %11 = bitcast %"class.std::tuple"* %__args to i8*
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* %10, i8* nonnull %11, i64 24, i32 8, i1 false) #8
  %cmp.i.i21.i.i.i.i73 = icmp eq %"class.std::tuple"* %9, %__position.coerce
  br i1 %cmp.i.i21.i.i.i.i73, label %invoke.cont10, label %for.body.i.i.i.i82.preheader

for.body.i.i.i.i82.preheader:                     ; preds = %invoke.cont
  br label %for.body.i.i.i.i82

for.body.i.i.i.i82:                               ; preds = %for.body.i.i.i.i82, %for.body.i.i.i.i82.preheader
  %__cur.023.i.i.i.i75 = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i80, %for.body.i.i.i.i82 ], [ %cond.i68, %for.body.i.i.i.i82.preheader ]
  %__first.sroa.0.022.i.i.i.i76 = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i.i79, %for.body.i.i.i.i82 ], [ %9, %for.body.i.i.i.i82.preheader ]
  %_M_head_impl.i.i.i.i.i.i.i.i.i.i.i77 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i76, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %_M_head_impl.i.i6.i.i.i.i.i.i.i.i78 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i75, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %12 = load i32, i32* %_M_head_impl.i.i.i.i.i.i.i.i.i.i.i77, align 4, !tbaa !14
  store i32 %12, i32* %_M_head_impl.i.i6.i.i.i.i.i.i.i.i78, align 4, !tbaa !22
  %13 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i75, i64 0, i32 0, i32 0, i32 1
  %14 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i76, i64 0, i32 0, i32 0, i32 1, i32 0
  %15 = bitcast double* %14 to i64*
  %16 = load i64, i64* %15, align 8, !tbaa !34
  %17 = bitcast %"struct.std::_Head_base.7"* %13 to i64*
  store i64 %16, i64* %17, align 8, !tbaa !27
  %18 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i76, i64 0, i32 0, i32 1, i32 0
  %19 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i75, i64 0, i32 0, i32 1, i32 0
  %20 = load i32, i32* %18, align 4, !tbaa !14
  store i32 %20, i32* %19, align 4, !tbaa !30
  %incdec.ptr.i.i.i.i.i79 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i76, i64 1
  %incdec.ptr.i.i.i.i80 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i75, i64 1
  %cmp.i.i.i.i.i.i81 = icmp eq %"class.std::tuple"* %incdec.ptr.i.i.i.i.i79, %__position.coerce
  br i1 %cmp.i.i.i.i.i.i81, label %invoke.cont10.loopexit, label %for.body.i.i.i.i82

invoke.cont10.loopexit:                           ; preds = %for.body.i.i.i.i82
  %incdec.ptr.i.i.i.i80.lcssa = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i80, %for.body.i.i.i.i82 ]
  br label %invoke.cont10

invoke.cont10:                                    ; preds = %invoke.cont10.loopexit, %invoke.cont
  %__cur.0.lcssa.i.i.i.i83 = phi %"class.std::tuple"* [ %cond.i68, %invoke.cont ], [ %incdec.ptr.i.i.i.i80.lcssa, %invoke.cont10.loopexit ]
  %incdec.ptr = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.0.lcssa.i.i.i.i83, i64 1
  %21 = load %"class.std::tuple"*, %"class.std::tuple"** %_M_finish.i20.i, align 8, !tbaa !12
  %cmp.i.i21.i.i.i.i = icmp eq %"class.std::tuple"* %21, %__position.coerce
  br i1 %cmp.i.i21.i.i.i.i, label %invoke.cont15, label %for.body.i.i.i.i.preheader

for.body.i.i.i.i.preheader:                       ; preds = %invoke.cont10
  br label %for.body.i.i.i.i

for.body.i.i.i.i:                                 ; preds = %for.body.i.i.i.i, %for.body.i.i.i.i.preheader
  %__cur.023.i.i.i.i = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i, %for.body.i.i.i.i ], [ %incdec.ptr, %for.body.i.i.i.i.preheader ]
  %__first.sroa.0.022.i.i.i.i = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i.i, %for.body.i.i.i.i ], [ %__position.coerce, %for.body.i.i.i.i.preheader ]
  %_M_head_impl.i.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %_M_head_impl.i.i6.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %22 = load i32, i32* %_M_head_impl.i.i.i.i.i.i.i.i.i.i.i, align 4, !tbaa !14
  store i32 %22, i32* %_M_head_impl.i.i6.i.i.i.i.i.i.i.i, align 4, !tbaa !22
  %23 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i, i64 0, i32 0, i32 0, i32 1
  %24 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i, i64 0, i32 0, i32 0, i32 1, i32 0
  %25 = bitcast double* %24 to i64*
  %26 = load i64, i64* %25, align 8, !tbaa !34
  %27 = bitcast %"struct.std::_Head_base.7"* %23 to i64*
  store i64 %26, i64* %27, align 8, !tbaa !27
  %28 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i, i64 0, i32 0, i32 1, i32 0
  %29 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i, i64 0, i32 0, i32 1, i32 0
  %30 = load i32, i32* %28, align 4, !tbaa !14
  store i32 %30, i32* %29, align 4, !tbaa !30
  %incdec.ptr.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__first.sroa.0.022.i.i.i.i, i64 1
  %incdec.ptr.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %__cur.023.i.i.i.i, i64 1
  %cmp.i.i.i.i.i.i = icmp eq %"class.std::tuple"* %incdec.ptr.i.i.i.i.i, %21
  br i1 %cmp.i.i.i.i.i.i, label %invoke.cont15.loopexit, label %for.body.i.i.i.i

invoke.cont15.loopexit:                           ; preds = %for.body.i.i.i.i
  %incdec.ptr.i.i.i.i.lcssa = phi %"class.std::tuple"* [ %incdec.ptr.i.i.i.i, %for.body.i.i.i.i ]
  br label %invoke.cont15

invoke.cont15:                                    ; preds = %invoke.cont15.loopexit, %invoke.cont10
  %__cur.0.lcssa.i.i.i.i = phi %"class.std::tuple"* [ %incdec.ptr, %invoke.cont10 ], [ %incdec.ptr.i.i.i.i.lcssa, %invoke.cont15.loopexit ]
  %_M_end_of_storage = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %this, i64 0, i32 0, i32 0, i32 2
  %tobool.i69 = icmp eq %"class.std::tuple"* %9, null
  br i1 %tobool.i69, label %_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE13_M_deallocateEPS1_m.exit71, label %if.then.i70

if.then.i70:                                      ; preds = %invoke.cont15
  %31 = bitcast %"class.std::tuple"* %9 to i8*
  tail call void @_ZdlPv(i8* %31) #8
  br label %_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE13_M_deallocateEPS1_m.exit71

_ZNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE13_M_deallocateEPS1_m.exit71: ; preds = %if.then.i70, %invoke.cont15
  store %"class.std::tuple"* %cond.i68, %"class.std::tuple"** %6, align 8, !tbaa !9
  store %"class.std::tuple"* %__cur.0.lcssa.i.i.i.i, %"class.std::tuple"** %_M_finish.i20.i, align 8, !tbaa !12
  %add.ptr39 = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %cond.i68, i64 %cond.i
  store %"class.std::tuple"* %add.ptr39, %"class.std::tuple"** %_M_end_of_storage, align 8, !tbaa !13
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #1

; CHECK-LABEL: define private fastcc void @_Z14func_with_sretidRSt6vectorI6paramsSaIS0_EE.outline_pfor.detach29.ls2(i64
; CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
; CHECK: detach within %[[SYNCREG]], label %.split, label %{{.+}} unwind label %[[DUNWIND:.+]]
; CHECK: {{^.split}}:
; CHECK-NEXT: invoke fastcc void @_Z14func_with_sretidRSt6vectorI6paramsSaIS0_EE.outline_pfor.detach29.ls2(i64
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LSUNWIND:.+]]
; CHECK: sync within %[[SYNCREG]]
; CHECK: ret void
; CHECK: [[DUNWIND]]:
; CHECK: resume
; CHECK: [[LSUNWIND]]:
; CHECK: %[[LPADVAL:.+]] = landingpad [[LPADTYPE:.+]]
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow
; CHECK: (token %[[SYNCREG]], [[LPADTYPE]] %[[LPADVAL]])
; CHECK-NEXT: to label %{{.+}} unwind label %[[DUNWIND]]

; CHECK-LABEL: define private fastcc void @_Z14func_with_sretidRSt6vectorI6paramsSaIS0_EE.outline_pfor.detach.ls1(i64
; CHECK: %[[SYNCREG:.+]] = tail call token @llvm.syncregion.start()
; CHECK: detach within %[[SYNCREG]], label %.split, label %{{.+}} unwind label %[[DUNWIND:.+]]
; CHECK: {{^.split:}}
; CHECK-NEXT: invoke fastcc void @_Z14func_with_sretidRSt6vectorI6paramsSaIS0_EE.outline_pfor.detach.ls1(i64
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LSUNWIND:.+]]
; CHECK: {{^pfor.detach29.preheader.ls1:}}
; CHECK: invoke fastcc void @_Z14func_with_sretidRSt6vectorI6paramsSaIS0_EE.outline_pfor.detach29.ls2(i64 0,
; CHECK: sync within %[[SYNCREG]]
; CHECK: ret void
; CHECK: [[DUNWIND]]:
; CHECK resume
; CHECK: [[LSUNWIND]]:
; CHECK: %[[LPADVAL:.+]] = landingpad [[LPADTYPE:.+]]
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow
; CHECK: (token %[[SYNCREG]], [[LPADTYPE]] %[[LPADVAL]])
; CHECK-NEXT: to label %{{.+}} unwind label %[[DUNWIND]]

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { argmemonly }
attributes #5 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nobuiltin "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nounwind }
attributes #9 = { noreturn }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0 (git@github.com:wsmoses/Tapir-Clang.git e0c101088ce269d4bb0fcbc91d328db51fa809ae) (git@github.com:wsmoses/Tapir-LLVM.git 108f1043ddbc9e235a885e734a031d213eeabe5a)"}
!2 = !{!3, !5, i64 8}
!3 = !{!"_ZTSSt12_Vector_baseI6paramsSaIS0_EE", !4, i64 0}
!4 = !{!"_ZTSNSt12_Vector_baseI6paramsSaIS0_EE12_Vector_implE", !5, i64 0, !5, i64 8, !5, i64 16}
!5 = !{!"any pointer", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
!8 = !{!3, !5, i64 0}
!9 = !{!10, !5, i64 0}
!10 = !{!"_ZTSSt12_Vector_baseISt5tupleIJidiEESaIS1_EE", !11, i64 0}
!11 = !{!"_ZTSNSt12_Vector_baseISt5tupleIJidiEESaIS1_EE12_Vector_implE", !5, i64 0, !5, i64 8, !5, i64 16}
!12 = !{!10, !5, i64 8}
!13 = !{!10, !5, i64 16}
!14 = !{!15, !15, i64 0}
!15 = !{!"int", !6, i64 0}
!16 = distinct !{!16, !17}
!17 = !{!"tapir.loop.spawn.strategy", i32 1}
!18 = distinct !{!18, !19}
!19 = !{!"llvm.loop.isvectorized", i32 1}
!20 = distinct !{!20, !21, !19}
!21 = !{!"llvm.loop.unroll.runtime.disable"}
!22 = !{!23, !15, i64 0}
!23 = !{!"_ZTSSt10_Head_baseILm2EiLb0EE", !15, i64 0}
!24 = !{!25}
!25 = distinct !{!25, !26, !"_ZSt10make_tupleIJRiRdS0_EESt5tupleIJDpNSt17__decay_and_stripIT_E6__typeEEEDpOS4_: %agg.result"}
!26 = distinct !{!26, !"_ZSt10make_tupleIJRiRdS0_EESt5tupleIJDpNSt17__decay_and_stripIT_E6__typeEEEDpOS4_"}
!27 = !{!28, !29, i64 0}
!28 = !{!"_ZTSSt10_Head_baseILm1EdLb0EE", !29, i64 0}
!29 = !{!"double", !6, i64 0}
!30 = !{!31, !15, i64 0}
!31 = !{!"_ZTSSt10_Head_baseILm0EiLb0EE", !15, i64 0}
!32 = distinct !{!32, !17}
!33 = !{!5, !5, i64 0}
!34 = !{!29, !29, i64 0}
