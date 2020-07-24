; RUN: opt < %s -licm -S -o - | FileCheck %s
; RUN: opt < %s -aa-pipeline=basic-aa -passes='require<opt-remark-emit>,loop(licm)' -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.cilk::provisional_guard" = type { %"struct.cilk::op_add"* }
%"struct.cilk::op_add" = type { i8 }
%"class.cilk::reducer_opadd" = type { %"class.cilk::reducer.base", [56 x i8] }
%"class.cilk::reducer.base" = type { %"class.cilk::internal::reducer_content.base" }
%"class.cilk::internal::reducer_content.base" = type { %"class.cilk::internal::reducer_base", [48 x i8], [8 x i8] }
%"class.cilk::internal::reducer_base" = type { %struct.__cilkrts_hyperobject_base, %"class.cilk::internal::storage_for_object", i8* }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i32, i64, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (i8*, i64)*, void (i8*, i8*)* }
%"class.cilk::internal::storage_for_object" = type { %"class.cilk::internal::aligned_storage" }
%"class.cilk::internal::aligned_storage" = type { [1 x i8] }
%"class.cilk::reducer" = type { %"class.cilk::internal::reducer_content.base", [56 x i8] }
%"class.cilk::internal::reducer_content" = type { %"class.cilk::internal::reducer_base", [48 x i8], [8 x i8], [56 x i8] }
%"class.cilk::op_add_view" = type { %"class.cilk::scalar_view" }
%"class.cilk::scalar_view" = type { i64 }
%"class.cilk::monoid_with_view" = type { i8 }
%"class.cilk::monoid_base" = type { i8 }

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev = comdat any

$__clang_call_terminate = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_ = comdat any

@.str.1 = private unnamed_addr constant [140 x i8] c"reducer_is_cache_aligned() && \22Reducer should be cache aligned. Please see comments following \22 \22this assertion for explanation and fixes.\22\00", align 1
@.str.2 = private unnamed_addr constant [80 x i8] c"/data/animals/opencilk-project/build-dbg/lib/clang/9.0.1/include/cilk/reducer.h\00", align 1
@__PRETTY_FUNCTION__._ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev = private unnamed_addr constant [145 x i8] c"cilk::internal::reducer_content<cilk::op_add<long long, true>, true>::reducer_content() [Monoid = cilk::op_add<long long, true>, Aligned = true]\00", align 1

; Function Attrs: uwtable
define dso_local i64 @_Z13accum_reducerl(i64 %n) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %ref.tmp1.epil = alloca i64, align 8
  %guard.i.i.i = alloca %"class.cilk::provisional_guard", align 8
  %accum = alloca %"class.cilk::reducer_opadd", align 64
  %ref.tmp = alloca i64, align 8
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = bitcast %"class.cilk::reducer_opadd"* %accum to i8*
  call void @llvm.lifetime.start.p0i8(i64 192, i8* nonnull %0) #10
  %1 = bitcast i64* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1) #10
  store i64 0, i64* %ref.tmp, align 8, !tbaa !2
  %2 = bitcast %"class.cilk::reducer_opadd"* %accum to %"class.cilk::reducer"*
  %3 = bitcast %"class.cilk::reducer"* %2 to %"class.cilk::internal::reducer_content"*
  %4 = getelementptr inbounds %"class.cilk::internal::reducer_content", %"class.cilk::internal::reducer_content"* %3, i64 0, i32 0
  %5 = getelementptr inbounds %"class.cilk::internal::reducer_content", %"class.cilk::internal::reducer_content"* %3, i64 0, i32 2, i64 0
  %m_base.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0
  %reduce_fn.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0, i32 0, i32 0
  store void (i8*, i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, void (i8*, i8*, i8*)** %reduce_fn.i.i.i.i, align 8, !tbaa !6
  %identity_fn.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0, i32 0, i32 1
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, void (i8*, i8*)** %identity_fn.i.i.i.i, align 8, !tbaa !9
  %destroy_fn.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0, i32 0, i32 2
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, void (i8*, i8*)** %destroy_fn.i.i.i.i, align 8, !tbaa !10
  %allocate_fn.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0, i32 0, i32 3
  store i8* (i8*, i64)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i8* (i8*, i64)** %allocate_fn.i.i.i.i, align 8, !tbaa !11
  %deallocate_fn.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0, i32 0, i32 4
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, void (i8*, i8*)** %deallocate_fn.i.i.i.i, align 8, !tbaa !12
  %__id_num.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0, i32 1
  store i32 0, i32* %__id_num.i.i.i.i, align 8, !tbaa !13
  %__view_offset.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0, i32 2
  %sub.ptr.lhs.cast.i.i.i.i = ptrtoint i8* %5 to i64
  %sub.ptr.rhs.cast.i.i.i.i = ptrtoint %"class.cilk::internal::reducer_base"* %4 to i64
  store i64 128, i64* %__view_offset.i.i.i.i, align 8, !tbaa !17
  %__view_size.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 0, i32 3
  store i64 8, i64* %__view_size.i.i.i.i, align 8, !tbaa !18
  %m_initialThis.i.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %4, i64 0, i32 2
  %6 = bitcast i8** %m_initialThis.i.i.i.i to %"class.cilk::internal::reducer_base"**
  store %"class.cilk::internal::reducer_base"* %4, %"class.cilk::internal::reducer_base"** %6, align 8, !tbaa !19
  call void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base* %m_base.i.i.i.i)
  %7 = ptrtoint %"class.cilk::internal::reducer_content"* %3 to i64
  %8 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %2, i64 0, i32 0, i32 0
  %m_monoid.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %8, i64 0, i32 1
  %9 = bitcast %"class.cilk::internal::storage_for_object"* %m_monoid.i.i.i to %"struct.cilk::op_add"*
  %10 = bitcast %"class.cilk::internal::reducer_base"* %8 to i8*
  %__view_offset.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %8, i64 0, i32 0, i32 2
  %11 = load i64, i64* %__view_offset.i.i.i, align 8, !tbaa !22
  %add.ptr.i.i.i = getelementptr inbounds i8, i8* %10, i64 %11
  %12 = bitcast i8* %add.ptr.i.i.i to %"class.cilk::op_add_view"*
  %13 = bitcast %"class.cilk::provisional_guard"* %guard.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %13) #10
  %m_ptr.i.i.i.i = getelementptr inbounds %"class.cilk::provisional_guard", %"class.cilk::provisional_guard"* %guard.i.i.i, i64 0, i32 0
  store %"struct.cilk::op_add"* %9, %"struct.cilk::op_add"** %m_ptr.i.i.i.i, align 8, !tbaa !23
  %14 = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %12, i64 0, i32 0
  %m_value.i.i.i.i.i = getelementptr inbounds %"class.cilk::scalar_view", %"class.cilk::scalar_view"* %14, i64 0, i32 0
  %15 = load i64, i64* %ref.tmp, align 8, !tbaa !2
  store i64 %15, i64* %m_value.i.i.i.i.i, align 8, !tbaa !25
  %m_ptr.i1.i.i.i = getelementptr inbounds %"class.cilk::provisional_guard", %"class.cilk::provisional_guard"* %guard.i.i.i, i64 0, i32 0
  store %"struct.cilk::op_add"* null, %"struct.cilk::op_add"** %m_ptr.i1.i.i.i, align 8, !tbaa !23
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %13) #10
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1) #10
  %cmp = icmp sgt i64 %n, -1
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %entry
  %xtraiter = and i64 %n, 2047
  %16 = icmp ult i64 %n, 2047
  br i1 %16, label %pfor.cond.cleanup.strpm-lcssa, label %pfor.cond.preheader.new

pfor.cond.preheader.new:                          ; preds = %pfor.cond.preheader
  %stripiter = udiv i64 %n, 2048
  br label %pfor.cond.strpm.outer

pfor.cond.strpm.outer:                            ; preds = %pfor.inc.strpm.outer, %pfor.cond.preheader.new
  %niter = phi i64 [ 0, %pfor.cond.preheader.new ], [ %niter.nadd, %pfor.inc.strpm.outer ]
  detach within %syncreg, label %pfor.body.strpm.outer, label %pfor.inc.strpm.outer unwind label %lpad5.loopexit

pfor.body.strpm.outer:                            ; preds = %pfor.cond.strpm.outer
  %ref.tmp1 = alloca i64, align 8
  %17 = mul i64 2048, %niter
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.body.strpm.outer, %pfor.inc
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ %17, %pfor.body.strpm.outer ]
  %inneriter = phi i64 [ 2048, %pfor.body.strpm.outer ], [ %inneriter.nsub, %pfor.inc ]
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.cond
  %18 = bitcast i64* %ref.tmp1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %18) #10
  store i64 %__begin.0, i64* %ref.tmp1, align 8, !tbaa !2
  %19 = bitcast %"class.cilk::reducer_opadd"* %accum to %"class.cilk::reducer"*
  %20 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %19, i64 0, i32 0, i32 0
  %m_base.i.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %20, i64 0, i32 0
  %call.i.i.i = call noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base* %m_base.i.i.i) #11
  %21 = bitcast i8* %call.i.i.i to %"class.cilk::op_add_view"*
  %22 = load i64, i64* %ref.tmp1, align 8, !tbaa !2
  %m_value.i.i = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %21, i64 0, i32 0, i32 0
  %23 = load i64, i64* %m_value.i.i, align 8, !tbaa !25
  %add.i.i = add nsw i64 %23, %22
  store i64 %add.i.i, i64* %m_value.i.i, align 8, !tbaa !25
  br label %invoke.cont2

invoke.cont2:                                     ; preds = %pfor.body
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %18) #10
  br label %pfor.inc

pfor.inc:                                         ; preds = %invoke.cont2
  %inc = add nuw i64 %__begin.0, 1
  %inneriter.nsub = sub nuw nsw i64 %inneriter, 1
  %inneriter.ncmp = icmp eq i64 %inneriter.nsub, 0
  br i1 %inneriter.ncmp, label %pfor.inc.reattach, label %pfor.cond, !llvm.loop !27

; CHECK: pfor.cond.strpm.outer:
; CHECK: call noalias i8* @__cilkrts_hyper_lookup(
; CHECK: br label %pfor.cond

; CHECK: pfor.cond:
; CHECK: br label %pfor.body

; CHECK: pfor.body:
; CHECK-NOT: call noalias i8* @__cilkrts_hyper_lookup(
; CHECK: br label %pfor.inc

; CHECK: pfor.inc:
; CHECK: br i1 %{{.+}}, label %{{.+}}, label %pfor.cond

pfor.inc.reattach:                                ; preds = %pfor.inc
  reattach within %syncreg, label %pfor.inc.strpm.outer

pfor.inc.strpm.outer:                             ; preds = %pfor.inc.reattach, %pfor.cond.strpm.outer
  %niter.nadd = add nuw i64 %niter, 1
  %niter.ncmp = icmp eq i64 %niter.nadd, %stripiter
  br i1 %niter.ncmp, label %pfor.cond.cleanup.strpm-lcssa.loopexit, label %pfor.cond.strpm.outer, !llvm.loop !29

pfor.cond.cleanup.strpm-lcssa.loopexit:           ; preds = %pfor.inc.strpm.outer
  br label %pfor.cond.cleanup.strpm-lcssa

pfor.cond.cleanup.strpm-lcssa:                    ; preds = %pfor.cond.cleanup.strpm-lcssa.loopexit, %pfor.cond.preheader
  %lcmp.mod = icmp ne i64 %xtraiter, 0
  br i1 %lcmp.mod, label %pfor.cond.epil.preheader, label %pfor.cond.cleanup

pfor.cond.epil.preheader:                         ; preds = %pfor.cond.cleanup.strpm-lcssa
  %24 = udiv i64 %n, 2048
  %25 = mul nuw i64 %24, 2048
  br label %pfor.cond.epil

pfor.cond.epil:                                   ; preds = %pfor.inc.epil, %pfor.cond.epil.preheader
  %__begin.0.epil = phi i64 [ %inc.epil, %pfor.inc.epil ], [ %25, %pfor.cond.epil.preheader ]
  %epil.iter = phi i64 [ %xtraiter, %pfor.cond.epil.preheader ], [ %epil.iter.sub, %pfor.inc.epil ]
  br label %pfor.body.epil

pfor.body.epil:                                   ; preds = %pfor.cond.epil
  %26 = bitcast i64* %ref.tmp1.epil to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %26) #10
  store i64 %__begin.0.epil, i64* %ref.tmp1.epil, align 8, !tbaa !2
  %27 = bitcast %"class.cilk::reducer_opadd"* %accum to %"class.cilk::reducer"*
  %28 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %27, i64 0, i32 0, i32 0
  %m_base.i.i.i.epil = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %28, i64 0, i32 0
  %call.i.i.i.epil = call noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base* %m_base.i.i.i.epil) #11
  %29 = bitcast i8* %call.i.i.i.epil to %"class.cilk::op_add_view"*
  %30 = load i64, i64* %ref.tmp1.epil, align 8, !tbaa !2
  %m_value.i.i.epil = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %29, i64 0, i32 0, i32 0
  %31 = load i64, i64* %m_value.i.i.epil, align 8, !tbaa !25
  %add.i.i.epil = add nsw i64 %31, %30
  store i64 %add.i.i.epil, i64* %m_value.i.i.epil, align 8, !tbaa !25
  br label %invoke.cont2.epil

invoke.cont2.epil:                                ; preds = %pfor.body.epil
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %26) #10
  br label %pfor.inc.epil

pfor.inc.epil:                                    ; preds = %invoke.cont2.epil
  %inc.epil = add nuw nsw i64 %__begin.0.epil, 1
  %epil.iter.sub = sub nsw i64 %epil.iter, 1
  %epil.iter.cmp = icmp ne i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp, label %pfor.cond.epil, label %pfor.cond.cleanup.epilog-lcssa, !llvm.loop !32

pfor.cond.cleanup.epilog-lcssa:                   ; preds = %pfor.inc.epil
  br label %pfor.cond.cleanup

pfor.cond.cleanup:                                ; preds = %pfor.cond.cleanup.strpm-lcssa, %pfor.cond.cleanup.epilog-lcssa
  sync within %syncreg, label %sync.continue

lpad:                                             ; No predecessors!
  %32 = landingpad { i8*, i32 }
          cleanup
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %18) #10
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %32)
          to label %unreachable unwind label %lpad5.loopexit.split-lp

lpad5.loopexit:                                   ; preds = %pfor.cond.strpm.outer
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup18

lpad5.loopexit.split-lp:                          ; preds = %sync.continue, %lpad
  %lpad.loopexit.split-lp = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup18

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %cleanup unwind label %lpad5.loopexit.split-lp

cleanup:                                          ; preds = %sync.continue, %entry
  %33 = bitcast %"class.cilk::reducer_opadd"* %accum to %"class.cilk::reducer"*
  %34 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %33, i64 0, i32 0, i32 0
  %m_base.i.i.i.i1 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %34, i64 0, i32 0
  %call.i.i.i.i = call noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base* %m_base.i.i.i.i1) #11
  %35 = bitcast i8* %call.i.i.i.i to %"class.cilk::op_add_view"*
  %36 = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %35, i64 0, i32 0
  %m_value.i.i.i = getelementptr inbounds %"class.cilk::scalar_view", %"class.cilk::scalar_view"* %36, i64 0, i32 0
  br label %invoke.cont15

invoke.cont15:                                    ; preds = %cleanup
  %37 = load i64, i64* %m_value.i.i.i, align 8, !tbaa !2
  %38 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %33, i64 0, i32 0, i32 0
  %39 = bitcast %"class.cilk::internal::reducer_base"* %38 to i8*
  %__view_offset.i.i2 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %38, i64 0, i32 0, i32 2
  %40 = load i64, i64* %__view_offset.i.i2, align 8, !tbaa !22
  %add.ptr.i.i3 = getelementptr inbounds i8, i8* %39, i64 %40
  %41 = bitcast i8* %add.ptr.i.i3 to %"class.cilk::op_add_view"*
  %m_monoid.i.i4 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %38, i64 0, i32 1
  %42 = bitcast %"class.cilk::internal::storage_for_object"* %m_monoid.i.i4 to %"struct.cilk::op_add"*
  %m_base.i.i5 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %38, i64 0, i32 0
  invoke void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base* %m_base.i.i5)
          to label %_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev.exit7 unwind label %terminate.lpad.i.i6

terminate.lpad.i.i6:                              ; preds = %invoke.cont15
  %43 = landingpad { i8*, i32 }
          catch i8* null
  %44 = extractvalue { i8*, i32 } %43, 0
  call void @__clang_call_terminate(i8* %44) #12
  unreachable

_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev.exit7:   ; preds = %invoke.cont15
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %0) #10
  ret i64 %37

lpad14:                                           ; No predecessors!
  %45 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup18

ehcleanup18:                                      ; preds = %lpad14, %lpad5.loopexit.split-lp, %lpad5.loopexit
  %.sink40 = phi { i8*, i32 } [ %45, %lpad14 ], [ %lpad.loopexit, %lpad5.loopexit ], [ %lpad.loopexit.split-lp, %lpad5.loopexit.split-lp ]
  %46 = bitcast %"class.cilk::reducer_opadd"* %accum to %"class.cilk::reducer"*
  %47 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %46, i64 0, i32 0, i32 0
  %48 = bitcast %"class.cilk::internal::reducer_base"* %47 to i8*
  %__view_offset.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %47, i64 0, i32 0, i32 2
  %49 = load i64, i64* %__view_offset.i.i, align 8, !tbaa !22
  %add.ptr.i.i = getelementptr inbounds i8, i8* %48, i64 %49
  %50 = bitcast i8* %add.ptr.i.i to %"class.cilk::op_add_view"*
  %m_monoid.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %47, i64 0, i32 1
  %51 = bitcast %"class.cilk::internal::storage_for_object"* %m_monoid.i.i to %"struct.cilk::op_add"*
  %m_base.i.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %47, i64 0, i32 0
  invoke void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base* %m_base.i.i)
          to label %_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev.exit unwind label %terminate.lpad.i.i

terminate.lpad.i.i:                               ; preds = %ehcleanup18
  %52 = landingpad { i8*, i32 }
          catch i8* null
  %53 = extractvalue { i8*, i32 } %52, 0
  call void @__clang_call_terminate(i8* %53) #12
  unreachable

_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev.exit:    ; preds = %ehcleanup18
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %0) #10
  resume { i8*, i32 } %.sink40

unreachable:                                      ; preds = %lpad
  unreachable
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #1

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #2

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #2

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev(%"class.cilk::internal::reducer_base"* %this) unnamed_addr #3 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %m_base = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0
  invoke void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base* %m_base)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %entry
  ret void

terminate.lpad:                                   ; preds = %entry
  %0 = landingpad { i8*, i32 }
          catch i8* null
  %1 = extractvalue { i8*, i32 } %0, 0
  tail call void @__clang_call_terminate(i8* %1) #12
  unreachable
}

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8*) local_unnamed_addr #4 comdat {
  %2 = tail call i8* @__cxa_begin_catch(i8* %0) #10
  tail call void @_ZSt9terminatev() #12
  unreachable
}

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

declare dso_local void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #5

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #6

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_(i8* %r, i8* %lhs, i8* %rhs) #0 comdat align 2 {
entry:
  %0 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %m_monoid.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %0, i64 0, i32 1
  %1 = bitcast %"class.cilk::internal::storage_for_object"* %m_monoid.i to %"struct.cilk::op_add"*
  %2 = bitcast %"struct.cilk::op_add"* %1 to %"class.cilk::monoid_with_view"*
  %3 = bitcast i8* %lhs to %"class.cilk::op_add_view"*
  %4 = bitcast i8* %rhs to %"class.cilk::op_add_view"*
  %m_value.i.i = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %4, i64 0, i32 0, i32 0
  %5 = load i64, i64* %m_value.i.i, align 8, !tbaa !25
  %m_value2.i.i = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %3, i64 0, i32 0, i32 0
  %6 = load i64, i64* %m_value2.i.i, align 8, !tbaa !25
  %add.i.i = add nsw i64 %6, %5
  store i64 %add.i.i, i64* %m_value2.i.i, align 8, !tbaa !25
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_(i8* %r, i8* %view) #0 comdat align 2 {
entry:
  %0 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %m_monoid.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %0, i64 0, i32 1
  %1 = bitcast %"class.cilk::internal::storage_for_object"* %m_monoid.i to %"struct.cilk::op_add"*
  %2 = bitcast %"struct.cilk::op_add"* %1 to %"class.cilk::monoid_with_view"*
  %3 = bitcast i8* %view to %"class.cilk::op_add_view"*
  %4 = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %3, i64 0, i32 0
  %m_value.i.i.i = getelementptr inbounds %"class.cilk::scalar_view", %"class.cilk::scalar_view"* %4, i64 0, i32 0
  store i64 0, i64* %m_value.i.i.i, align 8, !tbaa !25
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_(i8* %r, i8* %view) #0 comdat align 2 {
entry:
  %0 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %m_monoid.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %0, i64 0, i32 1
  %1 = bitcast %"class.cilk::internal::storage_for_object"* %m_monoid.i to %"struct.cilk::op_add"*
  %2 = bitcast %"struct.cilk::op_add"* %1 to %"class.cilk::monoid_base"*
  %3 = bitcast i8* %view to %"class.cilk::op_add_view"*
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local i8* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm(i8* %r, i64 %bytes) #0 comdat align 2 {
entry:
  %0 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %m_monoid.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %0, i64 0, i32 1
  %1 = bitcast %"class.cilk::internal::storage_for_object"* %m_monoid.i to %"struct.cilk::op_add"*
  %2 = bitcast %"struct.cilk::op_add"* %1 to %"class.cilk::monoid_base"*
  %call.i = tail call i8* @_Znwm(i64 %bytes)
  ret i8* %call.i
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_(i8* %r, i8* %view) #0 comdat align 2 {
entry:
  %0 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %m_monoid.i = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %0, i64 0, i32 1
  %1 = bitcast %"class.cilk::internal::storage_for_object"* %m_monoid.i to %"struct.cilk::op_add"*
  %2 = bitcast %"struct.cilk::op_add"* %1 to %"class.cilk::monoid_base"*
  tail call void @_ZdlPv(i8* %view) #10
  ret void
}

declare dso_local void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #5

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #7

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #8

; Function Attrs: nounwind readonly strand_pure
declare dso_local noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #9

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { argmemonly }
attributes #3 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noinline noreturn nounwind }
attributes #5 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { nounwind readonly strand_pure "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nounwind }
attributes #11 = { nounwind readonly strand_pure }
attributes #12 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git c95bc4879b9edeebc2203b594f058b6617e529e0)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"long long", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !8, i64 0}
!7 = !{!"_ZTS13cilk_c_monoid", !8, i64 0, !8, i64 8, !8, i64 16, !8, i64 24, !8, i64 32}
!8 = !{!"any pointer", !4, i64 0}
!9 = !{!7, !8, i64 8}
!10 = !{!7, !8, i64 16}
!11 = !{!7, !8, i64 24}
!12 = !{!7, !8, i64 32}
!13 = !{!14, !15, i64 40}
!14 = !{!"_ZTS26__cilkrts_hyperobject_base", !7, i64 0, !15, i64 40, !16, i64 48, !16, i64 56}
!15 = !{!"int", !4, i64 0}
!16 = !{!"long", !4, i64 0}
!17 = !{!14, !16, i64 48}
!18 = !{!14, !16, i64 56}
!19 = !{!20, !8, i64 72}
!20 = !{!"_ZTSN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEE", !14, i64 0, !21, i64 64, !8, i64 72}
!21 = !{!"_ZTSN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEEE"}
!22 = !{!20, !16, i64 48}
!23 = !{!24, !8, i64 0}
!24 = !{!"_ZTSN4cilk17provisional_guardINS_6op_addIxLb1EEEEE", !8, i64 0}
!25 = !{!26, !3, i64 0}
!26 = !{!"_ZTSN4cilk11scalar_viewIxEE", !3, i64 0}
!27 = distinct !{!27, !28}
!28 = !{!"llvm.loop.from.tapir.loop"}
!29 = distinct !{!29, !30, !31}
!30 = !{!"tapir.loop.spawn.strategy", i32 1}
!31 = !{!"tapir.loop.grainsize", i32 1}
!32 = distinct !{!32, !28}
