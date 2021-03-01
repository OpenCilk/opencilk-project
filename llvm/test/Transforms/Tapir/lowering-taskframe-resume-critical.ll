; Check Tapir outlining properly handles taskframe.resume instructions
; with critical unwind edges.
;
; RUN: opt < %s -tapir2target -use-opencilk-runtime-bc=false -S -o - | FileCheck %s
; RUN: opt < %s -passes='tapir2target' -use-opencilk-runtime-bc=false -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.std::pair" = type { %"class.std::vector", %"class.std::vector" }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<std::vector<long, std::allocator<long> >, std::allocator<std::vector<long, std::allocator<long> > > >::_Vector_impl" }
%"struct.std::_Vector_base<std::vector<long, std::allocator<long> >, std::allocator<std::vector<long, std::allocator<long> > > >::_Vector_impl" = type { %"struct.std::_Vector_base<std::vector<long, std::allocator<long> >, std::allocator<std::vector<long, std::allocator<long> > > >::_Vector_impl_data" }
%"struct.std::_Vector_base<std::vector<long, std::allocator<long> >, std::allocator<std::vector<long, std::allocator<long> > > >::_Vector_impl_data" = type { %"class.std::vector.0"*, %"class.std::vector.0"*, %"class.std::vector.0"* }
%"class.std::vector.0" = type { %"struct.std::_Vector_base.1" }
%"struct.std::_Vector_base.1" = type { %"struct.std::_Vector_base<long, std::allocator<long> >::_Vector_impl" }
%"struct.std::_Vector_base<long, std::allocator<long> >::_Vector_impl" = type { %"struct.std::_Vector_base<long, std::allocator<long> >::_Vector_impl_data" }
%"struct.std::_Vector_base<long, std::allocator<long> >::_Vector_impl_data" = type { i64*, i64*, i64* }

$__clang_call_terminate = comdat any

$_ZNSt20__uninitialized_copyILb0EE13__uninit_copyIN9__gnu_cxx17__normal_iteratorIPKSt6vectorIlSaIlEES4_IS6_SaIS6_EEEEPS6_EET0_T_SE_SD_ = comdat any

; Function Attrs: uwtable
define dso_local void @_Z15SerialPartitionv(%"struct.std::pair"* noalias nocapture sret %agg.result) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %ref.tmp = alloca %"class.std::vector", align 16
  %ref.tmp1 = alloca %"class.std::vector", align 16
  %0 = bitcast %"class.std::vector"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %0) #8
  call void @_Z1gv(%"class.std::vector"* nonnull sret %ref.tmp)
  %1 = bitcast %"class.std::vector"* %ref.tmp1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %1) #8
  invoke void @_Z1gv(%"class.std::vector"* nonnull sret %ref.tmp1)
          to label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit40 unwind label %lpad

_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit40:       ; preds = %entry
  %2 = bitcast %"class.std::vector"* %ref.tmp to <2 x i64>*
  %3 = load <2 x i64>, <2 x i64>* %2, align 16, !tbaa !2
  %4 = bitcast %"struct.std::pair"* %agg.result to <2 x i64>*
  store <2 x i64> %3, <2 x i64>* %4, align 8, !tbaa !2
  %_M_end_of_storage.i.i.i.i5.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %agg.result, i64 0, i32 0, i32 0, i32 0, i32 0, i32 2
  %_M_end_of_storage4.i.i.i.i6.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ref.tmp, i64 0, i32 0, i32 0, i32 0, i32 2
  %5 = bitcast %"class.std::vector.0"** %_M_end_of_storage4.i.i.i.i6.i to i64*
  %6 = load i64, i64* %5, align 16, !tbaa !6
  %7 = bitcast %"class.std::vector.0"** %_M_end_of_storage.i.i.i.i5.i to i64*
  store i64 %6, i64* %7, align 8, !tbaa !6
  %second.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %agg.result, i64 0, i32 1
  %8 = bitcast %"class.std::vector"* %ref.tmp1 to <2 x i64>*
  %9 = load <2 x i64>, <2 x i64>* %8, align 16, !tbaa !2
  %10 = bitcast %"class.std::vector"* %second.i to <2 x i64>*
  store <2 x i64> %9, <2 x i64>* %10, align 8, !tbaa !2
  %_M_end_of_storage.i.i.i.i.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %agg.result, i64 0, i32 1, i32 0, i32 0, i32 0, i32 2
  %_M_end_of_storage4.i.i.i.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ref.tmp1, i64 0, i32 0, i32 0, i32 0, i32 2
  %11 = bitcast %"class.std::vector.0"** %_M_end_of_storage4.i.i.i.i.i to i64*
  %12 = load i64, i64* %11, align 16, !tbaa !6
  %13 = bitcast %"class.std::vector.0"** %_M_end_of_storage.i.i.i.i.i to i64*
  store i64 %12, i64* %13, align 8, !tbaa !6
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %1) #8
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %0) #8
  ret void

lpad:                                             ; preds = %entry
  %14 = landingpad { i8*, i32 }
          cleanup
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %1) #8
  %_M_start.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ref.tmp, i64 0, i32 0, i32 0, i32 0, i32 0
  %15 = load %"class.std::vector.0"*, %"class.std::vector.0"** %_M_start.i, align 16, !tbaa !8
  %_M_finish.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ref.tmp, i64 0, i32 0, i32 0, i32 0, i32 1
  %16 = load %"class.std::vector.0"*, %"class.std::vector.0"** %_M_finish.i, align 8, !tbaa !9
  %cmp3.i.i.i.i = icmp eq %"class.std::vector.0"* %15, %16
  br i1 %cmp3.i.i.i.i, label %invoke.cont.i, label %for.body.i.i.i.i

for.body.i.i.i.i:                                 ; preds = %lpad, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i
  %__first.addr.04.i.i.i.i = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i ], [ %15, %lpad ]
  %_M_start.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %17 = load i64*, i64** %_M_start.i.i.i.i.i.i.i, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i.i.i = icmp eq i64* %17, null
  br i1 %tobool.i.i.i.i.i.i.i.i, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i:                          ; preds = %for.body.i.i.i.i
  %18 = bitcast i64* %17 to i8*
  call void @_ZdlPv(i8* nonnull %18) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i: ; preds = %if.then.i.i.i.i.i.i.i.i, %for.body.i.i.i.i
  %incdec.ptr.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i, i64 1
  %cmp.i.i.i.i = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i, %16
  br i1 %cmp.i.i.i.i, label %invoke.cont.loopexit.i, label %for.body.i.i.i.i

invoke.cont.loopexit.i:                           ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i
  %.pre.i = load %"class.std::vector.0"*, %"class.std::vector.0"** %_M_start.i, align 16, !tbaa !8
  br label %invoke.cont.i

invoke.cont.i:                                    ; preds = %invoke.cont.loopexit.i, %lpad
  %19 = phi %"class.std::vector.0"* [ %.pre.i, %invoke.cont.loopexit.i ], [ %15, %lpad ]
  %tobool.i.i.i = icmp eq %"class.std::vector.0"* %19, null
  br i1 %tobool.i.i.i, label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %invoke.cont.i
  %20 = bitcast %"class.std::vector.0"* %19 to i8*
  call void @_ZdlPv(i8* nonnull %20) #8
  br label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit

_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit:         ; preds = %invoke.cont.i, %if.then.i.i.i
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %0) #8
  resume { i8*, i32 } %14
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local void @_Z1gv(%"class.std::vector"* sret) local_unnamed_addr #2

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: uwtable
define dso_local void @_Z2dcSt6vectorIS_IlSaIlEESaIS1_EE(%"class.std::vector"* nocapture readonly %messages) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %ref.tmp.i = alloca %"class.std::vector", align 8
  %ref.tmp1.i = alloca %"class.std::vector", align 8
  %syncreg = tail call token @llvm.syncregion.start()
  %agg.tmp13 = alloca %"class.std::vector", align 8
  %0 = getelementptr %"class.std::vector", %"class.std::vector"* %messages, i64 0, i32 0, i32 0, i32 0, i32 0
  %1 = load %"class.std::vector.0"*, %"class.std::vector.0"** %0, align 8, !tbaa !2
  %_M_finish.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %messages, i64 0, i32 0, i32 0, i32 0, i32 1
  %2 = load %"class.std::vector.0"*, %"class.std::vector.0"** %_M_finish.i.i, align 8, !tbaa !2
  %cmp.i.i = icmp eq %"class.std::vector.0"* %1, %2
  br i1 %cmp.i.i, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %3 = bitcast %"class.std::vector"* %ref.tmp.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %3) #8, !noalias !12
  call void @_Z1gv(%"class.std::vector"* nonnull sret %ref.tmp.i), !noalias !12
  %4 = bitcast %"class.std::vector"* %ref.tmp1.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %4) #8, !noalias !12
  invoke void @_Z1gv(%"class.std::vector"* nonnull sret %ref.tmp1.i)
          to label %if.then.tf unwind label %lpad.i, !noalias !12

lpad.i:                                           ; preds = %if.then
  %5 = landingpad { i8*, i32 }
          cleanup
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %4) #8, !noalias !12
  %_M_start.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ref.tmp.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %6 = load %"class.std::vector.0"*, %"class.std::vector.0"** %_M_start.i.i, align 8, !tbaa !8, !noalias !12
  %_M_finish.i.i26 = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ref.tmp.i, i64 0, i32 0, i32 0, i32 0, i32 1
  %7 = load %"class.std::vector.0"*, %"class.std::vector.0"** %_M_finish.i.i26, align 8, !tbaa !9, !noalias !12
  %cmp3.i.i.i.i.i = icmp eq %"class.std::vector.0"* %6, %7
  br i1 %cmp3.i.i.i.i.i, label %invoke.cont.i.i, label %for.body.i.i.i.i.i

for.body.i.i.i.i.i:                               ; preds = %lpad.i, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i
  %__first.addr.04.i.i.i.i.i = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i.i, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i ], [ %6, %lpad.i ]
  %_M_start.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %8 = load i64*, i64** %_M_start.i.i.i.i.i.i.i.i, align 8, !tbaa !10, !noalias !12
  %tobool.i.i.i.i.i.i.i.i.i = icmp eq i64* %8, null
  br i1 %tobool.i.i.i.i.i.i.i.i.i, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i.i:                        ; preds = %for.body.i.i.i.i.i
  %9 = bitcast i64* %8 to i8*
  call void @_ZdlPv(i8* nonnull %9) #8, !noalias !12
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i: ; preds = %if.then.i.i.i.i.i.i.i.i.i, %for.body.i.i.i.i.i
  %incdec.ptr.i.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i.i, i64 1
  %cmp.i.i.i.i.i = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i.i, %7
  br i1 %cmp.i.i.i.i.i, label %invoke.cont.loopexit.i.i, label %for.body.i.i.i.i.i

invoke.cont.loopexit.i.i:                         ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i
  %.pre.i.i = load %"class.std::vector.0"*, %"class.std::vector.0"** %_M_start.i.i, align 8, !tbaa !8, !noalias !12
  br label %invoke.cont.i.i

invoke.cont.i.i:                                  ; preds = %invoke.cont.loopexit.i.i, %lpad.i
  %10 = phi %"class.std::vector.0"* [ %.pre.i.i, %invoke.cont.loopexit.i.i ], [ %6, %lpad.i ]
  %tobool.i.i.i.i = icmp eq %"class.std::vector.0"* %10, null
  br i1 %tobool.i.i.i.i, label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i, label %if.then.i.i.i.i

if.then.i.i.i.i:                                  ; preds = %invoke.cont.i.i
  %11 = bitcast %"class.std::vector.0"* %10 to i8*
  call void @_ZdlPv(i8* nonnull %11) #8, !noalias !12
  br label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i

_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i:       ; preds = %if.then.i.i.i.i, %invoke.cont.i.i
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %3) #8, !noalias !12
  resume { i8*, i32 } %5

if.then.tf:                                       ; preds = %if.then
  %12 = bitcast %"class.std::vector"* %ref.tmp.i to i64*
  %13 = load i64, i64* %12, align 8, !tbaa !8, !noalias !12
  %_M_finish3.i.i.i.i4.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ref.tmp.i, i64 0, i32 0, i32 0, i32 0, i32 1
  %14 = bitcast %"class.std::vector.0"** %_M_finish3.i.i.i.i4.i.i to i64*
  %15 = load i64, i64* %14, align 8, !tbaa !9, !noalias !12
  %16 = bitcast %"class.std::vector"* %ref.tmp1.i to i64*
  %17 = load i64, i64* %16, align 8, !tbaa !8, !noalias !12
  %_M_finish3.i.i.i.i.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %ref.tmp1.i, i64 0, i32 0, i32 0, i32 0, i32 1
  %18 = bitcast %"class.std::vector.0"** %_M_finish3.i.i.i.i.i.i to <2 x i64>*
  %19 = load <2 x i64>, <2 x i64>* %18, align 8, !tbaa !2, !noalias !12
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %4) #8, !noalias !12
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %3) #8, !noalias !12
  %sub.ptr.sub.i.i = sub i64 %15, %13
  %sub.ptr.div.i.i = sdiv exact i64 %sub.ptr.sub.i.i, 24
  %20 = icmp eq i64 %sub.ptr.sub.i.i, 0
  %21 = call token @llvm.taskframe.create()
  %agg.tmp = alloca %"class.std::vector", align 8
  %22 = bitcast %"class.std::vector"* %agg.tmp to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 dereferenceable(24) %22, i8 0, i64 24, i1 false) #8
  br i1 %20, label %invoke.cont.i, label %cond.true.i.i.i.i

; CHECK: if.then.tf:
; CHECK: br i1 %{{.+}}, label %[[SPAWN:.+]], label %[[CONTINUE:.+]]

; CHECK: [[SPAWN]]:
; CHECK: invoke {{.*}}@_Z2dcSt6vectorIS_IlSaIlEESaIS1_EE.outline_if.then.tf
; CHECK-NEXT: to label %[[CONTINUE]] unwind label %[[TFLPAD_SPLIT:.+]]

cond.true.i.i.i.i:                                ; preds = %if.then.tf
  %cmp.i.i.i.i.i.i = icmp ugt i64 %sub.ptr.div.i.i, 384307168202282325
  br i1 %cmp.i.i.i.i.i.i, label %if.then.i.i.i.i.i.i, label %_ZNSt16allocator_traitsISaISt6vectorIlSaIlEEEE8allocateERS3_m.exit.i.i.i.i

if.then.i.i.i.i.i.i:                              ; preds = %cond.true.i.i.i.i
  invoke void @_ZSt17__throw_bad_allocv() #9
          to label %.noexc.i unwind label %lpad.i28

.noexc.i:                                         ; preds = %if.then.i.i.i.i.i.i
  unreachable

_ZNSt16allocator_traitsISaISt6vectorIlSaIlEEEE8allocateERS3_m.exit.i.i.i.i: ; preds = %cond.true.i.i.i.i
  %call2.i.i.i.i3.i20.i = invoke i8* @_Znwm(i64 %sub.ptr.sub.i.i)
          to label %call2.i.i.i.i3.i.noexc.i unwind label %lpad.i28

call2.i.i.i.i3.i.noexc.i:                         ; preds = %_ZNSt16allocator_traitsISaISt6vectorIlSaIlEEEE8allocateERS3_m.exit.i.i.i.i
  %23 = bitcast i8* %call2.i.i.i.i3.i20.i to %"class.std::vector.0"*
  br label %invoke.cont.i

invoke.cont.i:                                    ; preds = %call2.i.i.i.i3.i.noexc.i, %if.then.tf
  %cond.i.i.i.i = phi %"class.std::vector.0"* [ %23, %call2.i.i.i.i3.i.noexc.i ], [ null, %if.then.tf ]
  %_M_start.i.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %agg.tmp, i64 0, i32 0, i32 0, i32 0, i32 0
  store %"class.std::vector.0"* %cond.i.i.i.i, %"class.std::vector.0"** %_M_start.i.i.i, align 8, !tbaa !8
  %_M_finish.i.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %agg.tmp, i64 0, i32 0, i32 0, i32 0, i32 1
  store %"class.std::vector.0"* %cond.i.i.i.i, %"class.std::vector.0"** %_M_finish.i.i.i, align 8, !tbaa !9
  %add.ptr.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %cond.i.i.i.i, i64 %sub.ptr.div.i.i
  %_M_end_of_storage.i.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %agg.tmp, i64 0, i32 0, i32 0, i32 0, i32 2
  store %"class.std::vector.0"* %add.ptr.i.i.i, %"class.std::vector.0"** %_M_end_of_storage.i.i.i, align 8, !tbaa !6
  %24 = inttoptr i64 %13 to %"class.std::vector.0"*
  %25 = inttoptr i64 %15 to %"class.std::vector.0"*
  %call.i.i18.i = invoke %"class.std::vector.0"* @_ZNSt20__uninitialized_copyILb0EE13__uninit_copyIN9__gnu_cxx17__normal_iteratorIPKSt6vectorIlSaIlEES4_IS6_SaIS6_EEEEPS6_EET0_T_SE_SD_(%"class.std::vector.0"* %24, %"class.std::vector.0"* %25, %"class.std::vector.0"* %cond.i.i.i.i)
          to label %invoke.cont unwind label %lpad10.i

lpad.i28:                                         ; preds = %_ZNSt16allocator_traitsISaISt6vectorIlSaIlEEEE8allocateERS3_m.exit.i.i.i.i, %if.then.i.i.i.i.i.i
  %26 = landingpad { i8*, i32 }
          cleanup
  %27 = extractvalue { i8*, i32 } %26, 0
  %28 = extractvalue { i8*, i32 } %26, 1
  br label %eh.resume.i

lpad10.i:                                         ; preds = %invoke.cont.i
  %29 = landingpad { i8*, i32 }
          cleanup
  %30 = extractvalue { i8*, i32 } %29, 0
  %31 = extractvalue { i8*, i32 } %29, 1
  %tobool.i.i.i = icmp eq %"class.std::vector.0"* %cond.i.i.i.i, null
  br i1 %tobool.i.i.i, label %eh.resume.i, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %lpad10.i
  %32 = bitcast %"class.std::vector.0"* %cond.i.i.i.i to i8*
  call void @_ZdlPv(i8* nonnull %32) #8
  br label %eh.resume.i

eh.resume.i:                                      ; preds = %if.then.i.i.i, %lpad10.i, %lpad.i28
  %ehselector.slot.0.i = phi i32 [ %28, %lpad.i28 ], [ %31, %lpad10.i ], [ %31, %if.then.i.i.i ]
  %exn.slot.0.i = phi i8* [ %27, %lpad.i28 ], [ %30, %lpad10.i ], [ %30, %if.then.i.i.i ]
  %lpad.val.i = insertvalue { i8*, i32 } undef, i8* %exn.slot.0.i, 0
  %lpad.val14.i = insertvalue { i8*, i32 } %lpad.val.i, i32 %ehselector.slot.0.i, 1
  br label %lpad.body

invoke.cont:                                      ; preds = %invoke.cont.i
  store %"class.std::vector.0"* %call.i.i18.i, %"class.std::vector.0"** %_M_finish.i.i.i, align 8, !tbaa !9
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad

det.achd:                                         ; preds = %invoke.cont
  call void @llvm.taskframe.use(token %21)
  invoke void @_Z2dcSt6vectorIS_IlSaIlEESaIS1_EE(%"class.std::vector"* nonnull %agg.tmp)
          to label %invoke.cont4 unwind label %lpad1

invoke.cont4:                                     ; preds = %det.achd
  %cmp3.i.i.i.i = icmp eq %"class.std::vector.0"* %cond.i.i.i.i, %call.i.i18.i
  br i1 %cmp3.i.i.i.i, label %invoke.cont.i47, label %for.body.i.i.i.i

for.body.i.i.i.i:                                 ; preds = %invoke.cont4, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i
  %__first.addr.04.i.i.i.i = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i ], [ %cond.i.i.i.i, %invoke.cont4 ]
  %_M_start.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %33 = load i64*, i64** %_M_start.i.i.i.i.i.i.i, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i.i.i = icmp eq i64* %33, null
  br i1 %tobool.i.i.i.i.i.i.i.i, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i:                          ; preds = %for.body.i.i.i.i
  %34 = bitcast i64* %33 to i8*
  call void @_ZdlPv(i8* nonnull %34) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i: ; preds = %if.then.i.i.i.i.i.i.i.i, %for.body.i.i.i.i
  %incdec.ptr.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i, i64 1
  %cmp.i.i.i.i = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i, %call.i.i18.i
  br i1 %cmp.i.i.i.i, label %invoke.cont.i47, label %for.body.i.i.i.i

invoke.cont.i47:                                  ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i, %invoke.cont4
  %tobool.i.i.i46 = icmp eq %"class.std::vector.0"* %cond.i.i.i.i, null
  br i1 %tobool.i.i.i46, label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit, label %if.then.i.i.i48

if.then.i.i.i48:                                  ; preds = %invoke.cont.i47
  %35 = bitcast %"class.std::vector.0"* %cond.i.i.i.i to i8*
  call void @_ZdlPv(i8* nonnull %35) #8
  br label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit

_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit:         ; preds = %invoke.cont.i47, %if.then.i.i.i48
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %invoke.cont, %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit
  %36 = bitcast %"class.std::vector"* %agg.tmp13 to i64*
  store i64 %17, i64* %36, align 8, !tbaa !8
  %_M_finish.i.i.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %agg.tmp13, i64 0, i32 0, i32 0, i32 0, i32 1
  %37 = bitcast %"class.std::vector.0"** %_M_finish.i.i.i.i to <2 x i64>*
  store <2 x i64> %19, <2 x i64>* %37, align 8, !tbaa !2
  %38 = inttoptr i64 %17 to %"class.std::vector.0"*
  %39 = extractelement <2 x i64> %19, i32 0
  %40 = inttoptr i64 %39 to %"class.std::vector.0"*
  invoke void @_Z2dcSt6vectorIS_IlSaIlEESaIS1_EE(%"class.std::vector"* nonnull %agg.tmp13)
          to label %invoke.cont16 unwind label %lpad15

invoke.cont16:                                    ; preds = %det.cont
  %cmp3.i.i.i.i68 = icmp eq %"class.std::vector.0"* %38, %40
  br i1 %cmp3.i.i.i.i68, label %invoke.cont.i80, label %for.body.i.i.i.i72

for.body.i.i.i.i72:                               ; preds = %invoke.cont16, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i76
  %__first.addr.04.i.i.i.i69 = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i74, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i76 ], [ %38, %invoke.cont16 ]
  %_M_start.i.i.i.i.i.i.i70 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i69, i64 0, i32 0, i32 0, i32 0, i32 0
  %41 = load i64*, i64** %_M_start.i.i.i.i.i.i.i70, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i.i.i71 = icmp eq i64* %41, null
  br i1 %tobool.i.i.i.i.i.i.i.i71, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i76, label %if.then.i.i.i.i.i.i.i.i73

if.then.i.i.i.i.i.i.i.i73:                        ; preds = %for.body.i.i.i.i72
  %42 = bitcast i64* %41 to i8*
  call void @_ZdlPv(i8* nonnull %42) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i76

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i76: ; preds = %if.then.i.i.i.i.i.i.i.i73, %for.body.i.i.i.i72
  %incdec.ptr.i.i.i.i74 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i69, i64 1
  %cmp.i.i.i.i75 = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i74, %40
  br i1 %cmp.i.i.i.i75, label %invoke.cont.i80, label %for.body.i.i.i.i72

invoke.cont.i80:                                  ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i76, %invoke.cont16
  %tobool.i.i.i79 = icmp eq i64 %17, 0
  br i1 %tobool.i.i.i79, label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit82, label %if.then.i.i.i81

if.then.i.i.i81:                                  ; preds = %invoke.cont.i80
  %43 = inttoptr i64 %17 to i8*
  call void @_ZdlPv(i8* nonnull %43) #8
  br label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit82

_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit82:       ; preds = %invoke.cont.i80, %if.then.i.i.i81
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit82
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i102 unwind label %lpad10

_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i102:    ; preds = %sync.continue
  %cmp3.i.i.i.i4.i101 = icmp eq %"class.std::vector.0"* %24, %25
  br i1 %cmp3.i.i.i.i4.i101, label %invoke.cont.i16.i114, label %for.body.i.i.i.i8.i106

for.body.i.i.i.i8.i106:                           ; preds = %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i102, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i110
  %__first.addr.04.i.i.i.i5.i103 = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i10.i108, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i110 ], [ %24, %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i102 ]
  %_M_start.i.i.i.i.i.i.i6.i104 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i5.i103, i64 0, i32 0, i32 0, i32 0, i32 0
  %44 = load i64*, i64** %_M_start.i.i.i.i.i.i.i6.i104, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i.i.i7.i105 = icmp eq i64* %44, null
  br i1 %tobool.i.i.i.i.i.i.i.i7.i105, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i110, label %if.then.i.i.i.i.i.i.i.i9.i107

if.then.i.i.i.i.i.i.i.i9.i107:                    ; preds = %for.body.i.i.i.i8.i106
  %45 = bitcast i64* %44 to i8*
  call void @_ZdlPv(i8* nonnull %45) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i110

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i110: ; preds = %if.then.i.i.i.i.i.i.i.i9.i107, %for.body.i.i.i.i8.i106
  %incdec.ptr.i.i.i.i10.i108 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i5.i103, i64 1
  %cmp.i.i.i.i11.i109 = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i10.i108, %25
  br i1 %cmp.i.i.i.i11.i109, label %invoke.cont.i16.i114, label %for.body.i.i.i.i8.i106

invoke.cont.i16.i114:                             ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i110, %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i102
  %tobool.i.i.i15.i113 = icmp eq i64 %13, 0
  br i1 %tobool.i.i.i15.i113, label %if.end, label %if.then.i.i.i17.i115

if.then.i.i.i17.i115:                             ; preds = %invoke.cont.i16.i114
  %46 = inttoptr i64 %13 to i8*
  call void @_ZdlPv(i8* nonnull %46) #8
  br label %if.end

lpad:                                             ; preds = %invoke.cont, %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit133
  %47 = landingpad { i8*, i32 }
          cleanup
  br label %lpad.body

lpad.body:                                        ; preds = %eh.resume.i, %lpad
  %eh.lpad-body = phi { i8*, i32 } [ %47, %lpad ], [ %lpad.val14.i, %eh.resume.i ]
  %48 = extractelement <2 x i64> %19, i32 0
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %21, { i8*, i32 } %eh.lpad-body)
          to label %unreachable unwind label %lpad10

lpad1:                                            ; preds = %det.achd
  %49 = landingpad { i8*, i32 }
          cleanup
  %cmp3.i.i.i.i119 = icmp eq %"class.std::vector.0"* %cond.i.i.i.i, %call.i.i18.i
  br i1 %cmp3.i.i.i.i119, label %invoke.cont.i131, label %for.body.i.i.i.i123

for.body.i.i.i.i123:                              ; preds = %lpad1, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i127
  %__first.addr.04.i.i.i.i120 = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i125, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i127 ], [ %cond.i.i.i.i, %lpad1 ]
  %_M_start.i.i.i.i.i.i.i121 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i120, i64 0, i32 0, i32 0, i32 0, i32 0
  %50 = load i64*, i64** %_M_start.i.i.i.i.i.i.i121, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i.i.i122 = icmp eq i64* %50, null
  br i1 %tobool.i.i.i.i.i.i.i.i122, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i127, label %if.then.i.i.i.i.i.i.i.i124

if.then.i.i.i.i.i.i.i.i124:                       ; preds = %for.body.i.i.i.i123
  %51 = bitcast i64* %50 to i8*
  call void @_ZdlPv(i8* nonnull %51) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i127

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i127: ; preds = %if.then.i.i.i.i.i.i.i.i124, %for.body.i.i.i.i123
  %incdec.ptr.i.i.i.i125 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i120, i64 1
  %cmp.i.i.i.i126 = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i125, %call.i.i18.i
  br i1 %cmp.i.i.i.i126, label %invoke.cont.i131, label %for.body.i.i.i.i123

invoke.cont.i131:                                 ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i127, %lpad1
  %tobool.i.i.i130 = icmp eq %"class.std::vector.0"* %cond.i.i.i.i, null
  br i1 %tobool.i.i.i130, label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit133, label %if.then.i.i.i132

if.then.i.i.i132:                                 ; preds = %invoke.cont.i131
  %52 = bitcast %"class.std::vector.0"* %cond.i.i.i.i to i8*
  call void @_ZdlPv(i8* nonnull %52) #8
  br label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit133

_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit133:      ; preds = %invoke.cont.i131, %if.then.i.i.i132
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %49)
          to label %unreachable unwind label %lpad

; CHECK: [[TFLPAD_SPLIT]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup

; CHECK: call void @llvm.taskframe.load.guard.p0i64(i64* %{{.+}})
; CHECK-NEXT: load i64, i64*
; CHECK-NEXT: br label %lpad10

lpad10:                                           ; preds = %sync.continue, %lpad.body
  %.sroa.23.0 = phi i64 [ 0, %sync.continue ], [ %48, %lpad.body ]
  %.sroa.16.0 = phi i64 [ 0, %sync.continue ], [ %17, %lpad.body ]
  %53 = landingpad { i8*, i32 }
          cleanup
  %54 = extractvalue { i8*, i32 } %53, 0
  %55 = extractvalue { i8*, i32 } %53, 1
  br label %ehcleanup19

lpad15:                                           ; preds = %det.cont
  %56 = landingpad { i8*, i32 }
          cleanup
  %57 = extractvalue { i8*, i32 } %56, 0
  %58 = extractvalue { i8*, i32 } %56, 1
  %cmp3.i.i.i.i51 = icmp eq %"class.std::vector.0"* %38, %40
  br i1 %cmp3.i.i.i.i51, label %invoke.cont.i63, label %for.body.i.i.i.i55

for.body.i.i.i.i55:                               ; preds = %lpad15, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i59
  %__first.addr.04.i.i.i.i52 = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i57, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i59 ], [ %38, %lpad15 ]
  %_M_start.i.i.i.i.i.i.i53 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i52, i64 0, i32 0, i32 0, i32 0, i32 0
  %59 = load i64*, i64** %_M_start.i.i.i.i.i.i.i53, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i.i.i54 = icmp eq i64* %59, null
  br i1 %tobool.i.i.i.i.i.i.i.i54, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i59, label %if.then.i.i.i.i.i.i.i.i56

if.then.i.i.i.i.i.i.i.i56:                        ; preds = %for.body.i.i.i.i55
  %60 = bitcast i64* %59 to i8*
  call void @_ZdlPv(i8* nonnull %60) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i59

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i59: ; preds = %if.then.i.i.i.i.i.i.i.i56, %for.body.i.i.i.i55
  %incdec.ptr.i.i.i.i57 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i52, i64 1
  %cmp.i.i.i.i58 = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i57, %40
  br i1 %cmp.i.i.i.i58, label %invoke.cont.i63, label %for.body.i.i.i.i55

invoke.cont.i63:                                  ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i59, %lpad15
  %tobool.i.i.i62 = icmp eq i64 %17, 0
  br i1 %tobool.i.i.i62, label %ehcleanup19, label %if.then.i.i.i64

if.then.i.i.i64:                                  ; preds = %invoke.cont.i63
  %61 = inttoptr i64 %17 to i8*
  call void @_ZdlPv(i8* nonnull %61) #8
  br label %ehcleanup19

ehcleanup19:                                      ; preds = %if.then.i.i.i64, %invoke.cont.i63, %lpad10
  %.sroa.23.1 = phi i64 [ %.sroa.23.0, %lpad10 ], [ 0, %invoke.cont.i63 ], [ 0, %if.then.i.i.i64 ]
  %.sroa.16.1 = phi i64 [ %.sroa.16.0, %lpad10 ], [ 0, %invoke.cont.i63 ], [ 0, %if.then.i.i.i64 ]
  %ehselector.slot12.0 = phi i32 [ %55, %lpad10 ], [ %58, %invoke.cont.i63 ], [ %58, %if.then.i.i.i64 ]
  %exn.slot11.0 = phi i8* [ %54, %lpad10 ], [ %57, %invoke.cont.i63 ], [ %57, %if.then.i.i.i64 ]
  %62 = inttoptr i64 %.sroa.16.1 to %"class.std::vector.0"*
  %63 = inttoptr i64 %.sroa.23.1 to %"class.std::vector.0"*
  %cmp3.i.i.i.i.i31 = icmp eq %"class.std::vector.0"* %62, %63
  br i1 %cmp3.i.i.i.i.i31, label %invoke.cont.i.i43, label %for.body.i.i.i.i.i35

for.body.i.i.i.i.i35:                             ; preds = %ehcleanup19, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i39
  %__first.addr.04.i.i.i.i.i32 = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i.i37, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i39 ], [ %62, %ehcleanup19 ]
  %_M_start.i.i.i.i.i.i.i.i33 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i.i32, i64 0, i32 0, i32 0, i32 0, i32 0
  %64 = load i64*, i64** %_M_start.i.i.i.i.i.i.i.i33, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i.i.i.i34 = icmp eq i64* %64, null
  br i1 %tobool.i.i.i.i.i.i.i.i.i34, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i39, label %if.then.i.i.i.i.i.i.i.i.i36

if.then.i.i.i.i.i.i.i.i.i36:                      ; preds = %for.body.i.i.i.i.i35
  %65 = bitcast i64* %64 to i8*
  call void @_ZdlPv(i8* nonnull %65) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i39

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i39: ; preds = %if.then.i.i.i.i.i.i.i.i.i36, %for.body.i.i.i.i.i35
  %incdec.ptr.i.i.i.i.i37 = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i.i32, i64 1
  %cmp.i.i.i.i.i38 = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i.i37, %63
  br i1 %cmp.i.i.i.i.i38, label %invoke.cont.i.i43, label %for.body.i.i.i.i.i35

invoke.cont.i.i43:                                ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i.i39, %ehcleanup19
  %tobool.i.i.i.i42 = icmp eq i64 %.sroa.16.1, 0
  br i1 %tobool.i.i.i.i42, label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i45, label %if.then.i.i.i.i44

if.then.i.i.i.i44:                                ; preds = %invoke.cont.i.i43
  %66 = inttoptr i64 %.sroa.16.1 to i8*
  call void @_ZdlPv(i8* nonnull %66) #8
  br label %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i45

_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i45:     ; preds = %if.then.i.i.i.i44, %invoke.cont.i.i43
  %67 = inttoptr i64 %13 to %"class.std::vector.0"*
  %68 = inttoptr i64 %15 to %"class.std::vector.0"*
  %cmp3.i.i.i.i4.i = icmp eq %"class.std::vector.0"* %67, %68
  br i1 %cmp3.i.i.i.i4.i, label %invoke.cont.i16.i, label %for.body.i.i.i.i8.i

for.body.i.i.i.i8.i:                              ; preds = %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i45, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i
  %__first.addr.04.i.i.i.i5.i = phi %"class.std::vector.0"* [ %incdec.ptr.i.i.i.i10.i, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i ], [ %67, %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i45 ]
  %_M_start.i.i.i.i.i.i.i6.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i5.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %69 = load i64*, i64** %_M_start.i.i.i.i.i.i.i6.i, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i.i.i7.i = icmp eq i64* %69, null
  br i1 %tobool.i.i.i.i.i.i.i.i7.i, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i, label %if.then.i.i.i.i.i.i.i.i9.i

if.then.i.i.i.i.i.i.i.i9.i:                       ; preds = %for.body.i.i.i.i8.i
  %70 = bitcast i64* %69 to i8*
  call void @_ZdlPv(i8* nonnull %70) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i: ; preds = %if.then.i.i.i.i.i.i.i.i9.i, %for.body.i.i.i.i8.i
  %incdec.ptr.i.i.i.i10.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i.i.i5.i, i64 1
  %cmp.i.i.i.i11.i = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i.i.i10.i, %68
  br i1 %cmp.i.i.i.i11.i, label %invoke.cont.i16.i, label %for.body.i.i.i.i8.i

invoke.cont.i16.i:                                ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i.i.i12.i, %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit.i45
  %tobool.i.i.i15.i = icmp eq i64 %13, 0
  br i1 %tobool.i.i.i15.i, label %_ZNSt4pairISt6vectorIS0_IlSaIlEESaIS2_EES4_ED2Ev.exit, label %if.then.i.i.i17.i

if.then.i.i.i17.i:                                ; preds = %invoke.cont.i16.i
  %71 = inttoptr i64 %13 to i8*
  call void @_ZdlPv(i8* nonnull %71) #8
  br label %_ZNSt4pairISt6vectorIS0_IlSaIlEESaIS2_EES4_ED2Ev.exit

_ZNSt4pairISt6vectorIS0_IlSaIlEESaIS2_EES4_ED2Ev.exit: ; preds = %invoke.cont.i16.i, %if.then.i.i.i17.i
  %lpad.val24 = insertvalue { i8*, i32 } undef, i8* %exn.slot11.0, 0
  %lpad.val25 = insertvalue { i8*, i32 } %lpad.val24, i32 %ehselector.slot12.0, 1
  resume { i8*, i32 } %lpad.val25

if.end:                                           ; preds = %if.then.i.i.i17.i115, %invoke.cont.i16.i114, %entry
  ret void

unreachable:                                      ; preds = %lpad.body, %_ZNSt6vectorIS_IlSaIlEESaIS1_EED2Ev.exit133
  unreachable
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #1

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #3

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8* %0) local_unnamed_addr #4 comdat {
  %2 = tail call i8* @__cxa_begin_catch(i8* %0) #8
  tail call void @_ZSt9terminatev() #10
  unreachable
}

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #5

; Function Attrs: noreturn
declare dso_local void @_ZSt17__throw_bad_allocv() local_unnamed_addr #6

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #7

; Function Attrs: uwtable
define linkonce_odr dso_local %"class.std::vector.0"* @_ZNSt20__uninitialized_copyILb0EE13__uninit_copyIN9__gnu_cxx17__normal_iteratorIPKSt6vectorIlSaIlEES4_IS6_SaIS6_EEEEPS6_EET0_T_SE_SD_(%"class.std::vector.0"* %__first.coerce, %"class.std::vector.0"* %__last.coerce, %"class.std::vector.0"* %__result) local_unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %cmp.i24 = icmp eq %"class.std::vector.0"* %__first.coerce, %__last.coerce
  br i1 %cmp.i24, label %for.end, label %for.body

for.body:                                         ; preds = %entry, %for.inc
  %__cur.026 = phi %"class.std::vector.0"* [ %incdec.ptr, %for.inc ], [ %__result, %entry ]
  %__first.sroa.0.025 = phi %"class.std::vector.0"* [ %incdec.ptr.i, %for.inc ], [ %__first.coerce, %entry ]
  %_M_finish.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.sroa.0.025, i64 0, i32 0, i32 0, i32 0, i32 1
  %0 = bitcast i64** %_M_finish.i.i.i to i64*
  %1 = load i64, i64* %0, align 8, !tbaa !15
  %2 = bitcast %"class.std::vector.0"* %__first.sroa.0.025 to i64*
  %3 = load i64, i64* %2, align 8, !tbaa !10
  %sub.ptr.sub.i.i.i = sub i64 %1, %3
  %sub.ptr.div.i.i.i = ashr exact i64 %sub.ptr.sub.i.i.i, 3
  %4 = bitcast %"class.std::vector.0"* %__cur.026 to i8*
  tail call void @llvm.memset.p0i8.i64(i8* nonnull align 8 dereferenceable(24) %4, i8 0, i64 24, i1 false) #8
  %cmp.i.i.i.i.i = icmp eq i64 %sub.ptr.sub.i.i.i, 0
  br i1 %cmp.i.i.i.i.i, label %invoke.cont.i.i, label %cond.true.i.i.i.i.i

cond.true.i.i.i.i.i:                              ; preds = %for.body
  %cmp.i.i.i.i.i.i.i = icmp ugt i64 %sub.ptr.div.i.i.i, 1152921504606846975
  br i1 %cmp.i.i.i.i.i.i.i, label %if.then.i.i.i.i.i.i.i, label %_ZNSt16allocator_traitsISaIlEE8allocateERS0_m.exit.i.i.i.i.i

if.then.i.i.i.i.i.i.i:                            ; preds = %cond.true.i.i.i.i.i
  invoke void @_ZSt17__throw_bad_allocv() #9
          to label %.noexc unwind label %lpad.loopexit.split-lp

.noexc:                                           ; preds = %if.then.i.i.i.i.i.i.i
  unreachable

_ZNSt16allocator_traitsISaIlEE8allocateERS0_m.exit.i.i.i.i.i: ; preds = %cond.true.i.i.i.i.i
  %call2.i.i.i.i3.i19.i.i16 = invoke i8* @_Znwm(i64 %sub.ptr.sub.i.i.i)
          to label %call2.i.i.i.i3.i19.i.i.noexc unwind label %lpad.loopexit

call2.i.i.i.i3.i19.i.i.noexc:                     ; preds = %_ZNSt16allocator_traitsISaIlEE8allocateERS0_m.exit.i.i.i.i.i
  %5 = bitcast i8* %call2.i.i.i.i3.i19.i.i16 to i64*
  br label %invoke.cont.i.i

invoke.cont.i.i:                                  ; preds = %call2.i.i.i.i3.i19.i.i.noexc, %for.body
  %cond.i.i.i.i.i = phi i64* [ %5, %call2.i.i.i.i3.i19.i.i.noexc ], [ null, %for.body ]
  %_M_start.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__cur.026, i64 0, i32 0, i32 0, i32 0, i32 0
  store i64* %cond.i.i.i.i.i, i64** %_M_start.i.i.i.i, align 8, !tbaa !10
  %_M_finish.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__cur.026, i64 0, i32 0, i32 0, i32 0, i32 1
  store i64* %cond.i.i.i.i.i, i64** %_M_finish.i.i.i.i, align 8, !tbaa !15
  %add.ptr.i.i.i.i = getelementptr inbounds i64, i64* %cond.i.i.i.i.i, i64 %sub.ptr.div.i.i.i
  %_M_end_of_storage.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__cur.026, i64 0, i32 0, i32 0, i32 0, i32 2
  store i64* %add.ptr.i.i.i.i, i64** %_M_end_of_storage.i.i.i.i, align 8, !tbaa !16
  %6 = getelementptr %"class.std::vector.0", %"class.std::vector.0"* %__first.sroa.0.025, i64 0, i32 0, i32 0, i32 0, i32 0
  %7 = load i64*, i64** %6, align 8, !tbaa !2
  %8 = load i64, i64* %0, align 8, !tbaa !2
  %sub.ptr.rhs.cast.i.i.i.i.i.i.i.i.i.i = ptrtoint i64* %7 to i64
  %sub.ptr.sub.i.i.i.i.i.i.i.i.i.i = sub i64 %8, %sub.ptr.rhs.cast.i.i.i.i.i.i.i.i.i.i
  %sub.ptr.div.i.i.i.i.i.i.i.i.i.i = ashr exact i64 %sub.ptr.sub.i.i.i.i.i.i.i.i.i.i, 3
  %tobool.i.i.i.i.i.i.i.i.i.i = icmp eq i64 %sub.ptr.sub.i.i.i.i.i.i.i.i.i.i, 0
  br i1 %tobool.i.i.i.i.i.i.i.i.i.i, label %for.inc, label %if.then.i.i.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i.i.i:                      ; preds = %invoke.cont.i.i
  %9 = bitcast i64* %cond.i.i.i.i.i to i8*
  %10 = bitcast i64* %7 to i8*
  tail call void @llvm.memmove.p0i8.p0i8.i64(i8* align 8 %9, i8* align 8 %10, i64 %sub.ptr.sub.i.i.i.i.i.i.i.i.i.i, i1 false) #8
  br label %for.inc

for.inc:                                          ; preds = %if.then.i.i.i.i.i.i.i.i.i.i, %invoke.cont.i.i
  %add.ptr.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds i64, i64* %cond.i.i.i.i.i, i64 %sub.ptr.div.i.i.i.i.i.i.i.i.i.i
  store i64* %add.ptr.i.i.i.i.i.i.i.i.i.i, i64** %_M_finish.i.i.i.i, align 8, !tbaa !15
  %incdec.ptr.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.sroa.0.025, i64 1
  %incdec.ptr = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__cur.026, i64 1
  %cmp.i = icmp eq %"class.std::vector.0"* %incdec.ptr.i, %__last.coerce
  br i1 %cmp.i, label %for.end, label %for.body

lpad.loopexit:                                    ; preds = %_ZNSt16allocator_traitsISaIlEE8allocateERS0_m.exit.i.i.i.i.i
  %lpad.loopexit19 = landingpad { i8*, i32 }
          catch i8* null
  br label %lpad

lpad.loopexit.split-lp:                           ; preds = %if.then.i.i.i.i.i.i.i
  %lpad.loopexit.split-lp20 = landingpad { i8*, i32 }
          catch i8* null
  br label %lpad

lpad:                                             ; preds = %lpad.loopexit.split-lp, %lpad.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit19, %lpad.loopexit ], [ %lpad.loopexit.split-lp20, %lpad.loopexit.split-lp ]
  %11 = extractvalue { i8*, i32 } %lpad.phi, 0
  %12 = tail call i8* @__cxa_begin_catch(i8* %11) #8
  %cmp3.i.i = icmp eq %"class.std::vector.0"* %__cur.026, %__result
  br i1 %cmp3.i.i, label %invoke.cont6, label %for.body.i.i

for.body.i.i:                                     ; preds = %lpad, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i
  %__first.addr.04.i.i = phi %"class.std::vector.0"* [ %incdec.ptr.i.i, %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i ], [ %__result, %lpad ]
  %_M_start.i.i.i.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %13 = load i64*, i64** %_M_start.i.i.i.i.i, align 8, !tbaa !10
  %tobool.i.i.i.i.i.i = icmp eq i64* %13, null
  br i1 %tobool.i.i.i.i.i.i, label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i, label %if.then.i.i.i.i.i.i

if.then.i.i.i.i.i.i:                              ; preds = %for.body.i.i
  %14 = bitcast i64* %13 to i8*
  tail call void @_ZdlPv(i8* nonnull %14) #8
  br label %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i

_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i:    ; preds = %if.then.i.i.i.i.i.i, %for.body.i.i
  %incdec.ptr.i.i = getelementptr inbounds %"class.std::vector.0", %"class.std::vector.0"* %__first.addr.04.i.i, i64 1
  %cmp.i.i = icmp eq %"class.std::vector.0"* %incdec.ptr.i.i, %__cur.026
  br i1 %cmp.i.i, label %invoke.cont6, label %for.body.i.i

invoke.cont6:                                     ; preds = %_ZSt8_DestroyISt6vectorIlSaIlEEEvPT_.exit.i.i, %lpad
  invoke void @__cxa_rethrow() #9
          to label %unreachable unwind label %lpad5

for.end:                                          ; preds = %for.inc, %entry
  %__cur.0.lcssa = phi %"class.std::vector.0"* [ %__result, %entry ], [ %incdec.ptr, %for.inc ]
  ret %"class.std::vector.0"* %__cur.0.lcssa

lpad5:                                            ; preds = %invoke.cont6
  %15 = landingpad { i8*, i32 }
          cleanup
  invoke void @__cxa_end_catch()
          to label %invoke.cont7 unwind label %terminate.lpad

invoke.cont7:                                     ; preds = %lpad5
  resume { i8*, i32 } %15

terminate.lpad:                                   ; preds = %lpad5
  %16 = landingpad { i8*, i32 }
          catch i8* null
  %17 = extractvalue { i8*, i32 } %16, 0
  tail call void @__clang_call_terminate(i8* %17) #10
  unreachable

unreachable:                                      ; preds = %invoke.cont6
  unreachable
}

declare dso_local void @__cxa_rethrow() local_unnamed_addr

declare dso_local void @__cxa_end_catch() local_unnamed_addr

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #1

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly willreturn }
attributes #4 = { noinline noreturn nounwind }
attributes #5 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nounwind }
attributes #9 = { noreturn }
attributes #10 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 4ea28362975f8437bea89bf786a34bd5ad5dbb5b)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !3, i64 16}
!7 = !{!"_ZTSNSt12_Vector_baseISt6vectorIlSaIlEESaIS2_EE17_Vector_impl_dataE", !3, i64 0, !3, i64 8, !3, i64 16}
!8 = !{!7, !3, i64 0}
!9 = !{!7, !3, i64 8}
!10 = !{!11, !3, i64 0}
!11 = !{!"_ZTSNSt12_Vector_baseIlSaIlEE17_Vector_impl_dataE", !3, i64 0, !3, i64 8, !3, i64 16}
!12 = !{!13}
!13 = distinct !{!13, !14, !"_Z15SerialPartitionv: %agg.result"}
!14 = distinct !{!14, !"_Z15SerialPartitionv"}
!15 = !{!11, !3, i64 8}
!16 = !{!11, !3, i64 16}
