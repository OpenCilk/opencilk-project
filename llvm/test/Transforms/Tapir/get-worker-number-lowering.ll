; Check that lowering the thread-local memory access in
; __cilkrts_get_worker_number does not get misoptimized around
; function calls, where the worker executing that function might
; change in the middle of execution.
;
; RUN: opt < %s -passes="tapir2target,default<O1>" -tapir-target=opencilk -opencilk-runtime-bc-path=%S/libopencilk-abi.bc -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Reducer_Vector = type { %"class.std::vector" }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl" }
%"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl" = type { %"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl_data" }
%"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl_data" = type { ptr, ptr, ptr }
%"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data" = type { ptr, ptr, ptr }
%"struct.Reducer_Vector<int>::aligned_f" = type { %"class.std::vector.0", [40 x i8] }
%"class.std::vector.0" = type { %"struct.std::_Vector_base.1" }
%"struct.std::_Vector_base.1" = type { %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl" }
%"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl" = type { %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data" }

$_ZN14Reducer_VectorIiED2Ev = comdat any

$_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev = comdat any

$_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE17_M_default_appendEm = comdat any

@.str.1 = private unnamed_addr constant [26 x i8] c"vector::_M_default_append\00", align 1
@.str.2 = private unnamed_addr constant [26 x i8] c"vector::_M_realloc_insert\00", align 1
@str = private unnamed_addr constant [21 x i8] c"something went wrong\00", align 1

; Function Attrs: norecurse uwtable
define dso_local noundef i32 @main() local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %frontier = alloca %class.Reducer_Vector, align 8
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %frontier) #16
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %frontier, i8 0, i64 24, i1 false)
  %call.i = invoke i32 @__cilkrts_get_nworkers()
          to label %invoke.cont.i unwind label %lpad.i

invoke.cont.i:                                    ; preds = %entry
  %_M_finish.i.i.i = getelementptr inbounds %"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl_data", ptr %frontier, i64 0, i32 1
  %cmp.i.i.not = icmp eq i32 %call.i, 0
  br i1 %cmp.i.i.not, label %pfor.cond.preheader, label %if.then.i.i

if.then.i.i:                                      ; preds = %invoke.cont.i
  %conv.i = zext i32 %call.i to i64
  invoke void @_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE17_M_default_appendEm(ptr noundef nonnull align 8 dereferenceable(24) %frontier, i64 noundef %conv.i)
          to label %pfor.cond.preheader unwind label %lpad.i

pfor.cond.preheader:                              ; preds = %if.then.i.i, %invoke.cont.i
  invoke fastcc void @main.outline_pfor.cond.ls1(i64 0, i64 10000, i64 1, ptr nonnull %frontier)
          to label %cleanup54 unwind label %lpad40.loopexit

common.resume:                                    ; preds = %lpad40.loopexit, %lpad.i
  %common.resume.op = phi { ptr, i32 } [ %0, %lpad.i ], [ %lpad.loopexit104, %lpad40.loopexit ]
  resume { ptr, i32 } %common.resume.op

lpad.i:                                           ; preds = %if.then.i.i, %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  call void @_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev(ptr noundef nonnull align 8 dereferenceable(24) %frontier) #16
  br label %common.resume

lpad40.loopexit:                                  ; preds = %pfor.cond.preheader
  %lpad.loopexit104 = landingpad { ptr, i32 }
          cleanup
  call void @_ZN14Reducer_VectorIiED2Ev(ptr noundef nonnull align 8 dereferenceable(24) %frontier) #16
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %frontier) #16
  br label %common.resume

cleanup54:                                        ; preds = %pfor.cond.preheader
  %1 = load ptr, ptr %frontier, align 8, !tbaa !5
  %2 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !5
  %cmp.i13.i = icmp eq ptr %1, %2
  br i1 %cmp.i13.i, label %if.then, label %for.body.i

for.body.i:                                       ; preds = %cleanup54, %for.body.i
  %n.015.i = phi i64 [ %add.i, %for.body.i ], [ 0, %cleanup54 ]
  %__begin0.sroa.0.014.i = phi ptr [ %incdec.ptr.i.i97, %for.body.i ], [ %1, %cleanup54 ]
  %_M_finish.i10.i = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data", ptr %__begin0.sroa.0.014.i, i64 0, i32 1
  %3 = load ptr, ptr %_M_finish.i10.i, align 8, !tbaa !9
  %4 = load ptr, ptr %__begin0.sroa.0.014.i, align 8, !tbaa !11
  %sub.ptr.lhs.cast.i.i = ptrtoint ptr %3 to i64
  %sub.ptr.rhs.cast.i.i = ptrtoint ptr %4 to i64
  %sub.ptr.sub.i.i = sub i64 %sub.ptr.lhs.cast.i.i, %sub.ptr.rhs.cast.i.i
  %sub.ptr.div.i.i = ashr exact i64 %sub.ptr.sub.i.i, 2
  %add.i = add i64 %sub.ptr.div.i.i, %n.015.i
  %incdec.ptr.i.i97 = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %__begin0.sroa.0.014.i, i64 1
  %cmp.i.i98 = icmp eq ptr %incdec.ptr.i.i97, %2
  br i1 %cmp.i.i98, label %_ZNK14Reducer_VectorIiE4sizeEv.exit, label %for.body.i

_ZNK14Reducer_VectorIiE4sizeEv.exit:              ; preds = %for.body.i
  %cmp62.not = icmp eq i64 %add.i, 100000000
  br i1 %cmp62.not, label %cleanup65, label %if.then

if.then:                                          ; preds = %_ZNK14Reducer_VectorIiE4sizeEv.exit, %cleanup54
  %puts = call i32 @puts(ptr nonnull dereferenceable(1) @str)
  %.pre = load ptr, ptr %frontier, align 8, !tbaa !12
  %.pre108 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !14
  br label %cleanup65

cleanup65:                                        ; preds = %if.then, %_ZNK14Reducer_VectorIiE4sizeEv.exit
  %5 = phi ptr [ %.pre108, %if.then ], [ %2, %_ZNK14Reducer_VectorIiE4sizeEv.exit ]
  %6 = phi ptr [ %.pre, %if.then ], [ %1, %_ZNK14Reducer_VectorIiE4sizeEv.exit ]
  %retval.0 = phi i32 [ 1, %if.then ], [ 0, %_ZNK14Reducer_VectorIiE4sizeEv.exit ]
  %cmp.not3.i.i.i.i.i = icmp eq ptr %6, %5
  br i1 %cmp.not3.i.i.i.i.i, label %invoke.cont.i.i, label %for.body.i.i.i.i.i

for.body.i.i.i.i.i:                               ; preds = %cleanup65, %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i.i
  %__first.addr.04.i.i.i.i.i = phi ptr [ %incdec.ptr.i.i.i.i.i, %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i.i ], [ %6, %cleanup65 ]
  %7 = load ptr, ptr %__first.addr.04.i.i.i.i.i, align 64, !tbaa !11
  %tobool.not.i.i.i.i.i.i.i.i.i.i.i = icmp eq ptr %7, null
  br i1 %tobool.not.i.i.i.i.i.i.i.i.i.i.i, label %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i.i.i.i:                    ; preds = %for.body.i.i.i.i.i
  call void @_ZdlPv(ptr noundef nonnull %7) #17
  br label %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i.i

_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i.i: ; preds = %if.then.i.i.i.i.i.i.i.i.i.i.i, %for.body.i.i.i.i.i
  %incdec.ptr.i.i.i.i.i = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %__first.addr.04.i.i.i.i.i, i64 1
  %cmp.not.i.i.i.i.i = icmp eq ptr %incdec.ptr.i.i.i.i.i, %5
  br i1 %cmp.not.i.i.i.i.i, label %invoke.contthread-pre-split.i.i, label %for.body.i.i.i.i.i, !llvm.loop !15

invoke.contthread-pre-split.i.i:                  ; preds = %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i.i
  %.pr.i.i = load ptr, ptr %frontier, align 8, !tbaa !12
  br label %invoke.cont.i.i

invoke.cont.i.i:                                  ; preds = %invoke.contthread-pre-split.i.i, %cleanup65
  %8 = phi ptr [ %.pr.i.i, %invoke.contthread-pre-split.i.i ], [ %5, %cleanup65 ]
  %tobool.not.i.i.i.i100 = icmp eq ptr %8, null
  br i1 %tobool.not.i.i.i.i100, label %_ZN14Reducer_VectorIiED2Ev.exit, label %if.then.i.i.i.i101

if.then.i.i.i.i101:                               ; preds = %invoke.cont.i.i
  call void @_ZdlPvSt11align_val_t(ptr noundef nonnull %8, i64 noundef 64) #17
  br label %_ZN14Reducer_VectorIiED2Ev.exit

_ZN14Reducer_VectorIiED2Ev.exit:                  ; preds = %if.then.i.i.i.i101, %invoke.cont.i.i
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %frontier) #16
  ret i32 %retval.0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #2

declare i32 @__gxx_personality_v0(...)

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #3

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #3

; Function Attrs: inlinehint nounwind uwtable
define linkonce_odr dso_local void @_ZN14Reducer_VectorIiED2Ev(ptr noundef nonnull align 8 dereferenceable(24) %this) unnamed_addr #4 comdat align 2 personality ptr @__gxx_personality_v0 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !12
  %_M_finish.i = getelementptr inbounds %"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl_data", ptr %this, i64 0, i32 1
  %1 = load ptr, ptr %_M_finish.i, align 8, !tbaa !14
  %cmp.not3.i.i.i.i = icmp eq ptr %0, %1
  br i1 %cmp.not3.i.i.i.i, label %invoke.cont.i, label %for.body.i.i.i.i

for.body.i.i.i.i:                                 ; preds = %entry, %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i
  %__first.addr.04.i.i.i.i = phi ptr [ %incdec.ptr.i.i.i.i, %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i ], [ %0, %entry ]
  %2 = load ptr, ptr %__first.addr.04.i.i.i.i, align 64, !tbaa !11
  %tobool.not.i.i.i.i.i.i.i.i.i.i = icmp eq ptr %2, null
  br i1 %tobool.not.i.i.i.i.i.i.i.i.i.i, label %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i.i.i:                      ; preds = %for.body.i.i.i.i
  tail call void @_ZdlPv(ptr noundef nonnull %2) #17
  br label %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i

_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i: ; preds = %if.then.i.i.i.i.i.i.i.i.i.i, %for.body.i.i.i.i
  %incdec.ptr.i.i.i.i = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %__first.addr.04.i.i.i.i, i64 1
  %cmp.not.i.i.i.i = icmp eq ptr %incdec.ptr.i.i.i.i, %1
  br i1 %cmp.not.i.i.i.i, label %invoke.contthread-pre-split.i, label %for.body.i.i.i.i, !llvm.loop !15

invoke.contthread-pre-split.i:                    ; preds = %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i.i
  %.pr.i = load ptr, ptr %this, align 8, !tbaa !12
  br label %invoke.cont.i

invoke.cont.i:                                    ; preds = %invoke.contthread-pre-split.i, %entry
  %3 = phi ptr [ %.pr.i, %invoke.contthread-pre-split.i ], [ %0, %entry ]
  %tobool.not.i.i.i = icmp eq ptr %3, null
  br i1 %tobool.not.i.i.i, label %_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev.exit, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %invoke.cont.i
  tail call void @_ZdlPvSt11align_val_t(ptr noundef nonnull %3, i64 noundef 64) #17
  br label %_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev.exit

_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev.exit: ; preds = %if.then.i.i.i, %invoke.cont.i
  ret void
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev(ptr noundef nonnull align 8 dereferenceable(24) %this) unnamed_addr #5 comdat align 2 personality ptr @__gxx_personality_v0 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !12
  %_M_finish = getelementptr inbounds %"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl_data", ptr %this, i64 0, i32 1
  %1 = load ptr, ptr %_M_finish, align 8, !tbaa !14
  %cmp.not3.i.i.i = icmp eq ptr %0, %1
  br i1 %cmp.not3.i.i.i, label %invoke.cont, label %for.body.i.i.i

for.body.i.i.i:                                   ; preds = %entry, %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i
  %__first.addr.04.i.i.i = phi ptr [ %incdec.ptr.i.i.i, %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i ], [ %0, %entry ]
  %2 = load ptr, ptr %__first.addr.04.i.i.i, align 64, !tbaa !11
  %tobool.not.i.i.i.i.i.i.i.i.i = icmp eq ptr %2, null
  br i1 %tobool.not.i.i.i.i.i.i.i.i.i, label %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i, label %if.then.i.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i.i:                        ; preds = %for.body.i.i.i
  tail call void @_ZdlPv(ptr noundef nonnull %2) #17
  br label %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i

_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i: ; preds = %if.then.i.i.i.i.i.i.i.i.i, %for.body.i.i.i
  %incdec.ptr.i.i.i = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %__first.addr.04.i.i.i, i64 1
  %cmp.not.i.i.i = icmp eq ptr %incdec.ptr.i.i.i, %1
  br i1 %cmp.not.i.i.i, label %invoke.contthread-pre-split, label %for.body.i.i.i, !llvm.loop !15

invoke.contthread-pre-split:                      ; preds = %_ZSt8_DestroyIN14Reducer_VectorIiE9aligned_fEEvPT_.exit.i.i.i
  %.pr = load ptr, ptr %this, align 8, !tbaa !12
  br label %invoke.cont

invoke.cont:                                      ; preds = %invoke.contthread-pre-split, %entry
  %3 = phi ptr [ %.pr, %invoke.contthread-pre-split ], [ %0, %entry ]
  %tobool.not.i.i = icmp eq ptr %3, null
  br i1 %tobool.not.i.i, label %_ZNSt12_Vector_baseIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev.exit, label %if.then.i.i

if.then.i.i:                                      ; preds = %invoke.cont
  tail call void @_ZdlPvSt11align_val_t(ptr noundef nonnull %3, i64 noundef 64) #17
  br label %_ZNSt12_Vector_baseIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev.exit

_ZNSt12_Vector_baseIN14Reducer_VectorIiE9aligned_fESaIS2_EED2Ev.exit: ; preds = %if.then.i.i, %invoke.cont
  ret void
}

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPv(ptr noundef) local_unnamed_addr #6

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPvSt11align_val_t(ptr noundef, i64 noundef) local_unnamed_addr #6

; Function Attrs: mustprogress nofree willreturn
declare i32 @__cilkrts_get_nworkers() local_unnamed_addr #7

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE17_M_default_appendEm(ptr noundef nonnull align 8 dereferenceable(24) %this, i64 noundef %__n) local_unnamed_addr #8 comdat align 2 personality ptr @__gxx_personality_v0 {
entry:
  %cmp.not = icmp eq i64 %__n, 0
  br i1 %cmp.not, label %if.end44, label %if.then

if.then:                                          ; preds = %entry
  %_M_finish.i = getelementptr inbounds %"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl_data", ptr %this, i64 0, i32 1
  %0 = load ptr, ptr %_M_finish.i, align 8, !tbaa !14
  %1 = load ptr, ptr %this, align 8, !tbaa !12
  %sub.ptr.lhs.cast.i = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast.i = ptrtoint ptr %1 to i64
  %sub.ptr.sub.i = sub i64 %sub.ptr.lhs.cast.i, %sub.ptr.rhs.cast.i
  %sub.ptr.div.i = lshr exact i64 %sub.ptr.sub.i, 6
  %_M_end_of_storage = getelementptr inbounds %"struct.std::_Vector_base<Reducer_Vector<int>::aligned_f, std::allocator<Reducer_Vector<int>::aligned_f>>::_Vector_impl_data", ptr %this, i64 0, i32 2
  %2 = load ptr, ptr %_M_end_of_storage, align 8, !tbaa !17
  %sub.ptr.lhs.cast = ptrtoint ptr %2 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.lhs.cast.i
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 6
  %cmp4 = icmp sgt i64 %sub.ptr.sub.i, -1
  tail call void @llvm.assume(i1 %cmp4)
  %sub = xor i64 %sub.ptr.div.i, 144115188075855871
  %cmp6 = icmp ule i64 %sub.ptr.div, %sub
  tail call void @llvm.assume(i1 %cmp6)
  %cmp8.not = icmp ult i64 %sub.ptr.div, %__n
  br i1 %cmp8.not, label %if.else, label %_ZSt27__uninitialized_default_n_aIPN14Reducer_VectorIiE9aligned_fEmS2_ET_S4_T0_RSaIT1_E.exit

_ZSt27__uninitialized_default_n_aIPN14Reducer_VectorIiE9aligned_fEmS2_ET_S4_T0_RSaIT1_E.exit: ; preds = %if.then
  %3 = shl nuw i64 %__n, 6
  tail call void @llvm.memset.p0.i64(ptr align 64 %0, i8 0, i64 %3, i1 false)
  %uglygep.i.i.i = getelementptr i8, ptr %0, i64 %3
  store ptr %uglygep.i.i.i, ptr %_M_finish.i, align 8, !tbaa !14
  br label %if.end44

if.else:                                          ; preds = %if.then
  %cmp.i = icmp ult i64 %sub, %__n
  br i1 %cmp.i, label %if.then.i, label %_ZNKSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE12_M_check_lenEmPKc.exit

if.then.i:                                        ; preds = %if.else
  tail call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.1) #18
  unreachable

_ZNKSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE12_M_check_lenEmPKc.exit: ; preds = %if.else
  %.sroa.speculated.i = tail call i64 @llvm.umax.i64(i64 %sub.ptr.div.i, i64 %__n)
  %add.i = add i64 %.sroa.speculated.i, %sub.ptr.div.i
  %cmp7.i = icmp ult i64 %add.i, %sub.ptr.div.i
  %cmp9.i = icmp ugt i64 %add.i, 144115188075855871
  %or.cond.i = or i1 %cmp7.i, %cmp9.i
  %cond.i = select i1 %or.cond.i, i64 144115188075855871, i64 %add.i
  %cmp.not.i = icmp eq i64 %cond.i, 0
  br i1 %cmp.not.i, label %try.cont, label %_ZNSt16allocator_traitsISaIN14Reducer_VectorIiE9aligned_fEEE8allocateERS3_m.exit.i

_ZNSt16allocator_traitsISaIN14Reducer_VectorIiE9aligned_fEEE8allocateERS3_m.exit.i: ; preds = %_ZNKSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE12_M_check_lenEmPKc.exit
  %mul.i.i.i.i = shl nuw nsw i64 %cond.i, 6
  %call5.i.i.i.i = tail call noalias noundef nonnull align 64 ptr @_ZnwmSt11align_val_t(i64 noundef %mul.i.i.i.i, i64 noundef 64) #19
  call void @llvm.assume(i1 true) [ "align"(ptr %call5.i.i.i.i, i64 64) ]
  br label %try.cont

try.cont:                                         ; preds = %_ZNSt16allocator_traitsISaIN14Reducer_VectorIiE9aligned_fEEE8allocateERS3_m.exit.i, %_ZNKSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE12_M_check_lenEmPKc.exit
  %cond.i65 = phi ptr [ %call5.i.i.i.i, %_ZNSt16allocator_traitsISaIN14Reducer_VectorIiE9aligned_fEEE8allocateERS3_m.exit.i ], [ null, %_ZNKSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE12_M_check_lenEmPKc.exit ]
  %add.ptr = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %cond.i65, i64 %sub.ptr.div.i
  %4 = shl nuw i64 %__n, 6
  tail call void @llvm.memset.p0.i64(ptr align 64 %add.ptr, i8 0, i64 %4, i1 false)
  %cmp.not6.i.i.i = icmp eq ptr %1, %0
  br i1 %cmp.not6.i.i.i, label %_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE11_S_relocateEPS2_S5_S5_RS3_.exit, label %for.body.i.i.i

for.body.i.i.i:                                   ; preds = %try.cont, %for.body.i.i.i
  %__cur.08.i.i.i = phi ptr [ %incdec.ptr1.i.i.i, %for.body.i.i.i ], [ %cond.i65, %try.cont ]
  %__first.addr.07.i.i.i = phi ptr [ %incdec.ptr.i.i.i, %for.body.i.i.i ], [ %1, %try.cont ]
  tail call void @llvm.experimental.noalias.scope.decl(metadata !18)
  tail call void @llvm.experimental.noalias.scope.decl(metadata !21)
  %5 = load <2 x ptr>, ptr %__first.addr.07.i.i.i, align 64, !tbaa !5, !alias.scope !21, !noalias !18
  store <2 x ptr> %5, ptr %__cur.08.i.i.i, align 64, !tbaa !5, !alias.scope !18, !noalias !21
  %_M_end_of_storage.i.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data", ptr %__cur.08.i.i.i, i64 0, i32 2
  %_M_end_of_storage4.i.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data", ptr %__first.addr.07.i.i.i, i64 0, i32 2
  %6 = load ptr, ptr %_M_end_of_storage4.i.i.i.i.i.i.i.i.i.i.i, align 16, !tbaa !23, !alias.scope !21, !noalias !18
  store ptr %6, ptr %_M_end_of_storage.i.i.i.i.i.i.i.i.i.i.i, align 16, !tbaa !23, !alias.scope !18, !noalias !21
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 64 dereferenceable(24) %__first.addr.07.i.i.i, i8 0, i64 24, i1 false), !alias.scope !21, !noalias !18
  %incdec.ptr.i.i.i = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %__first.addr.07.i.i.i, i64 1
  %incdec.ptr1.i.i.i = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %__cur.08.i.i.i, i64 1
  %cmp.not.i.i.i = icmp eq ptr %incdec.ptr.i.i.i, %0
  br i1 %cmp.not.i.i.i, label %_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE11_S_relocateEPS2_S5_S5_RS3_.exit, label %for.body.i.i.i, !llvm.loop !24

_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE11_S_relocateEPS2_S5_S5_RS3_.exit: ; preds = %for.body.i.i.i, %try.cont
  %tobool.not.i73 = icmp eq ptr %1, null
  br i1 %tobool.not.i73, label %_ZNSt12_Vector_baseIN14Reducer_VectorIiE9aligned_fESaIS2_EE13_M_deallocateEPS2_m.exit75, label %if.then.i74

if.then.i74:                                      ; preds = %_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE11_S_relocateEPS2_S5_S5_RS3_.exit
  tail call void @_ZdlPvSt11align_val_t(ptr noundef nonnull %1, i64 noundef 64) #17
  br label %_ZNSt12_Vector_baseIN14Reducer_VectorIiE9aligned_fESaIS2_EE13_M_deallocateEPS2_m.exit75

_ZNSt12_Vector_baseIN14Reducer_VectorIiE9aligned_fESaIS2_EE13_M_deallocateEPS2_m.exit75: ; preds = %if.then.i74, %_ZNSt6vectorIN14Reducer_VectorIiE9aligned_fESaIS2_EE11_S_relocateEPS2_S5_S5_RS3_.exit
  store ptr %cond.i65, ptr %this, align 8, !tbaa !12
  %add.ptr37 = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %add.ptr, i64 %__n
  store ptr %add.ptr37, ptr %_M_finish.i, align 8, !tbaa !14
  %add.ptr40 = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %cond.i65, i64 %cond.i
  store ptr %add.ptr40, ptr %_M_end_of_storage, align 8, !tbaa !17
  br label %if.end44

if.end44:                                         ; preds = %_ZNSt12_Vector_baseIN14Reducer_VectorIiE9aligned_fESaIS2_EE13_M_deallocateEPS2_m.exit75, %_ZSt27__uninitialized_default_n_aIPN14Reducer_VectorIiE9aligned_fEmS2_ET_S4_T0_RSaIT1_E.exit, %entry
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #9

; Function Attrs: noreturn
declare void @_ZSt20__throw_length_errorPKc(ptr noundef) local_unnamed_addr #10

; Function Attrs: nobuiltin allocsize(0)
declare noalias noundef nonnull ptr @_ZnwmSt11align_val_t(i64 noundef, i64 noundef) local_unnamed_addr #11

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.assume(i1 noundef) #12

; Function Attrs: mustprogress nofree willreturn
declare i32 @__cilkrts_get_worker_number() local_unnamed_addr #7

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #11

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg) #13

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #14

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #15

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.experimental.noalias.scope.decl(metadata) #12

; Function Attrs: uwtable
define internal fastcc void @main.outline_pfor.cond16.strpm.outer.ls2(i64 %niter.start.ls2, i64 %end.ls2, i64 %grainsize.ls2, i64 %__begin.0.ls2, ptr align 8 %frontier.ls2) unnamed_addr #8 personality ptr @__gxx_personality_v0 {
pfor.cond16.strpm.detachloop.entry.ls2:
  %0 = tail call token @llvm.syncregion.start()
  %itercount2 = sub i64 %end.ls2, %niter.start.ls2
  %1 = icmp ugt i64 %itercount2, %grainsize.ls2
  br i1 %1, label %.lr.ph, label %pfor.body21.strpm.outer.ls2.preheader

pfor.body21.strpm.outer.ls2.preheader:            ; preds = %.split.split, %pfor.cond16.strpm.detachloop.entry.ls2
  %niter.ls2.dac.lcssa = phi i64 [ %niter.start.ls2, %pfor.cond16.strpm.detachloop.entry.ls2 ], [ %miditer, %.split.split ]
  br label %pfor.body21.strpm.outer.ls2

.lr.ph:                                           ; preds = %pfor.cond16.strpm.detachloop.entry.ls2, %.split.split
  %itercount4 = phi i64 [ %itercount, %.split.split ], [ %itercount2, %pfor.cond16.strpm.detachloop.entry.ls2 ]
  %niter.ls2.dac3 = phi i64 [ %miditer, %.split.split ], [ %niter.start.ls2, %pfor.cond16.strpm.detachloop.entry.ls2 ]
  %halfcount = lshr i64 %itercount4, 1
  %miditer = add nuw nsw i64 %halfcount, %niter.ls2.dac3
  detach within %0, label %.split, label %.split.split

.split:                                           ; preds = %.lr.ph
  tail call fastcc void @main.outline_pfor.cond16.strpm.outer.ls2(i64 %niter.ls2.dac3, i64 %miditer, i64 %grainsize.ls2, i64 %__begin.0.ls2, ptr %frontier.ls2) #16
  reattach within %0, label %.split.split

.split.split:                                     ; preds = %.lr.ph, %.split
  %itercount = sub i64 %end.ls2, %miditer
  %2 = icmp ugt i64 %itercount, %grainsize.ls2
  br i1 %2, label %.lr.ph, label %pfor.body21.strpm.outer.ls2.preheader

pfor.body21.strpm.outer.ls2:                      ; preds = %pfor.body21.strpm.outer.ls2.preheader, %pfor.inc.strpm.outer.ls2
  %niter.ls2 = phi i64 [ %niter.nadd.ls2, %pfor.inc.strpm.outer.ls2 ], [ %niter.ls2.dac.lcssa, %pfor.body21.strpm.outer.ls2.preheader ]
  %3 = shl nuw nsw i64 %niter.ls2, 10
  br label %pfor.cond16.ls2

pfor.cond16.ls2:                                  ; preds = %pfor.preattach.ls2, %pfor.body21.strpm.outer.ls2
  %__begin10.0.ls2 = phi i64 [ %inc.ls2, %pfor.preattach.ls2 ], [ %3, %pfor.body21.strpm.outer.ls2 ]
  %inneriter.ls2 = phi i64 [ %inneriter.nsub.ls2, %pfor.preattach.ls2 ], [ 1024, %pfor.body21.strpm.outer.ls2 ]
  %mul22.ls2 = mul nuw nsw i64 %__begin10.0.ls2, %__begin.0.ls2
  %conv.ls2 = trunc i64 %mul22.ls2 to i32
  %call.i8994.ls2 = tail call i32 @__cilkrts_get_worker_number()
  %conv.i90.ls2 = sext i32 %call.i8994.ls2 to i64
  %4 = load ptr, ptr %frontier.ls2, align 8, !tbaa !12
  %add.ptr.i.i91.ls2 = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %4, i64 %conv.i90.ls2
  %_M_finish.i.i.ls2 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data", ptr %add.ptr.i.i91.ls2, i64 0, i32 1
  %5 = load ptr, ptr %_M_finish.i.i.ls2, align 8, !tbaa !9
  %_M_end_of_storage.i.i.ls2 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data", ptr %add.ptr.i.i91.ls2, i64 0, i32 2
  %6 = load ptr, ptr %_M_end_of_storage.i.i.ls2, align 8, !tbaa !23
  %cmp.not.i.i.ls2 = icmp eq ptr %5, %6
  br i1 %cmp.not.i.i.ls2, label %if.else.i.i93.ls2, label %if.then.i.i92.ls2

if.then.i.i92.ls2:                                ; preds = %pfor.cond16.ls2
  store i32 %conv.ls2, ptr %5, align 4, !tbaa !25
  %incdec.ptr.i.i.ls2 = getelementptr inbounds i32, ptr %5, i64 1
  store ptr %incdec.ptr.i.i.ls2, ptr %_M_finish.i.i.ls2, align 8, !tbaa !9
  br label %pfor.preattach.ls2

pfor.preattach.ls2:                               ; preds = %_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_.exit.i.i.ls2, %if.then.i.i92.ls2
  %inc.ls2 = add nuw nsw i64 %__begin10.0.ls2, 1
  %inneriter.nsub.ls2 = add nsw i64 %inneriter.ls2, -1
  %inneriter.ncmp.ls2 = icmp eq i64 %inneriter.nsub.ls2, 0
  br i1 %inneriter.ncmp.ls2, label %pfor.inc.strpm.outer.ls2, label %pfor.cond16.ls2, !llvm.loop !27

if.else.i.i93.ls2:                                ; preds = %pfor.cond16.ls2
  %7 = load ptr, ptr %add.ptr.i.i91.ls2, align 8, !tbaa !11
  %sub.ptr.lhs.cast.i.i.i.i.i.ls2 = ptrtoint ptr %5 to i64
  %sub.ptr.rhs.cast.i.i.i.i.i.ls2 = ptrtoint ptr %7 to i64
  %sub.ptr.sub.i.i.i.i.i.ls2 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.ls2, %sub.ptr.rhs.cast.i.i.i.i.i.ls2
  %cmp.i.i.i.i.ls2 = icmp eq i64 %sub.ptr.sub.i.i.i.i.i.ls2, 9223372036854775804
  br i1 %cmp.i.i.i.i.ls2, label %if.then.i.i.i.i.ls2, label %_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.ls2

_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.ls2: ; preds = %if.else.i.i93.ls2
  %sub.ptr.div.i.i.i.i.i.ls2 = ashr exact i64 %sub.ptr.sub.i.i.i.i.i.ls2, 2
  %.sroa.speculated.i.i.i.i.ls2 = tail call i64 @llvm.umax.i64(i64 %sub.ptr.div.i.i.i.i.i.ls2, i64 1)
  %add.i.i.i.i.ls2 = add i64 %.sroa.speculated.i.i.i.i.ls2, %sub.ptr.div.i.i.i.i.i.ls2
  %cmp7.i.i.i.i.ls2 = icmp ult i64 %add.i.i.i.i.ls2, %sub.ptr.div.i.i.i.i.i.ls2
  %cmp9.i.i.i.i.ls2 = icmp ugt i64 %add.i.i.i.i.ls2, 2305843009213693951
  %or.cond.i.i.i.i.ls2 = or i1 %cmp7.i.i.i.i.ls2, %cmp9.i.i.i.i.ls2
  %cond.i.i.i.i.ls2 = select i1 %or.cond.i.i.i.i.ls2, i64 2305843009213693951, i64 %add.i.i.i.i.ls2
  %cmp.not.i.i.i.i.ls2 = icmp eq i64 %cond.i.i.i.i.ls2, 0
  br i1 %cmp.not.i.i.i.i.ls2, label %_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.ls2, label %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i.ls2

_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i.ls2: ; preds = %_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.ls2
  %mul.i.i.i.i.i.i.i.ls2 = shl nuw nsw i64 %cond.i.i.i.i.ls2, 2
  %call5.i.i.i.i.i.i.i95.ls2 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %mul.i.i.i.i.i.i.i.ls2) #19
  br label %_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.ls2

_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.ls2: ; preds = %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i.ls2, %_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.ls2
  %cond.i31.i.i.i.ls2 = phi ptr [ null, %_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.ls2 ], [ %call5.i.i.i.i.i.i.i95.ls2, %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i.ls2 ]
  %add.ptr.i.i.i.ls2 = getelementptr inbounds i32, ptr %cond.i31.i.i.i.ls2, i64 %sub.ptr.div.i.i.i.i.i.ls2
  store i32 %conv.ls2, ptr %add.ptr.i.i.i.ls2, align 4, !tbaa !25
  %cmp.i.i.i.i.i.i.ls2 = icmp sgt i64 %sub.ptr.sub.i.i.i.i.i.ls2, 0
  br i1 %cmp.i.i.i.i.i.i.ls2, label %if.then.i.i.i.i.i.i.ls2, label %_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.ls2

_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.ls2: ; preds = %if.then.i.i.i.i.i.i.ls2, %_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.ls2
  %incdec.ptr.i.i.i.ls2 = getelementptr inbounds i32, ptr %add.ptr.i.i.i.ls2, i64 1
  %tobool.not.i.i.i.i.ls2 = icmp eq ptr %7, null
  br i1 %tobool.not.i.i.i.i.ls2, label %_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_.exit.i.i.ls2, label %if.then.i40.i.i.i.ls2

if.then.i40.i.i.i.ls2:                            ; preds = %_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.ls2
  tail call void @_ZdlPv(ptr noundef nonnull %7) #17
  br label %_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_.exit.i.i.ls2

_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_.exit.i.i.ls2: ; preds = %if.then.i40.i.i.i.ls2, %_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.ls2
  store ptr %cond.i31.i.i.i.ls2, ptr %add.ptr.i.i91.ls2, align 8, !tbaa !11
  store ptr %incdec.ptr.i.i.i.ls2, ptr %_M_finish.i.i.ls2, align 8, !tbaa !9
  %add.ptr19.i.i.i.ls2 = getelementptr inbounds i32, ptr %cond.i31.i.i.i.ls2, i64 %cond.i.i.i.i.ls2
  store ptr %add.ptr19.i.i.i.ls2, ptr %_M_end_of_storage.i.i.ls2, align 8, !tbaa !23
  br label %pfor.preattach.ls2

if.then.i.i.i.i.i.i.ls2:                          ; preds = %_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.ls2
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 4 %cond.i31.i.i.i.ls2, ptr align 4 %7, i64 %sub.ptr.sub.i.i.i.i.i.ls2, i1 false)
  br label %_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.ls2

if.then.i.i.i.i.ls2:                              ; preds = %if.else.i.i93.ls2
  tail call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.2) #18
  unreachable

pfor.inc.strpm.outer.ls2:                         ; preds = %pfor.preattach.ls2
  %niter.nadd.ls2 = add nuw nsw i64 %niter.ls2, 1
  %niter.ncmp.ls2 = icmp eq i64 %niter.nadd.ls2, %end.ls2
  br i1 %niter.ncmp.ls2, label %pfor.cond16.strpm.detachloop.sync.ls2, label %pfor.body21.strpm.outer.ls2, !llvm.loop !29

pfor.cond16.strpm.detachloop.sync.ls2:            ; preds = %pfor.inc.strpm.outer.ls2
  sync within %0, label %pfor.cond16.strpm.detachloop.sync.ls2.split

pfor.cond16.strpm.detachloop.sync.ls2.split:      ; preds = %pfor.cond16.strpm.detachloop.sync.ls2
  tail call void @llvm.sync.unwind(token %0)
  ret void
}

; Function Attrs: uwtable
define internal fastcc void @main.outline_pfor.cond.ls1(i64 %__begin.0.start.ls1, i64 %end.ls1, i64 %grainsize.ls1, ptr align 8 %frontier.ls1) unnamed_addr #8 personality ptr @__gxx_personality_v0 {
pfor.cond.preheader.ls1:
  %syncreg3.ls1 = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.syncregion.start()
  %itercount2 = sub i64 %end.ls1, %__begin.0.start.ls1
  %1 = icmp ugt i64 %itercount2, %grainsize.ls1
  br i1 %1, label %.lr.ph, label %pfor.body.entry.new.ls1.preheader

pfor.body.entry.new.ls1.preheader:                ; preds = %.split.split, %pfor.cond.preheader.ls1
  %__begin.0.ls1.dac.lcssa = phi i64 [ %__begin.0.start.ls1, %pfor.cond.preheader.ls1 ], [ %miditer, %.split.split ]
  br label %pfor.body.entry.new.ls1

.lr.ph:                                           ; preds = %pfor.cond.preheader.ls1, %.split.split
  %itercount4 = phi i64 [ %itercount, %.split.split ], [ %itercount2, %pfor.cond.preheader.ls1 ]
  %__begin.0.ls1.dac3 = phi i64 [ %miditer, %.split.split ], [ %__begin.0.start.ls1, %pfor.cond.preheader.ls1 ]
  %halfcount = lshr i64 %itercount4, 1
  %miditer = add nuw nsw i64 %halfcount, %__begin.0.ls1.dac3
  detach within %0, label %.split, label %.split.split

.split:                                           ; preds = %.lr.ph
  tail call fastcc void @main.outline_pfor.cond.ls1(i64 %__begin.0.ls1.dac3, i64 %miditer, i64 %grainsize.ls1, ptr %frontier.ls1) #16
  reattach within %0, label %.split.split

.split.split:                                     ; preds = %.lr.ph, %.split
  %itercount = sub i64 %end.ls1, %miditer
  %2 = icmp ugt i64 %itercount, %grainsize.ls1
  br i1 %2, label %.lr.ph, label %pfor.body.entry.new.ls1.preheader

pfor.body.entry.new.ls1:                          ; preds = %pfor.body.entry.new.ls1.preheader, %sync.continue.ls1
  %__begin.0.ls1 = phi i64 [ %inc44.ls1, %sync.continue.ls1 ], [ %__begin.0.ls1.dac.lcssa, %pfor.body.entry.new.ls1.preheader ]
  detach within %syncreg3.ls1, label %pfor.cond16.strpm.detachloop.entry.ls1, label %pfor.cond16.epil.preheader.ls1

pfor.cond16.epil.preheader.ls1:                   ; preds = %pfor.body.entry.new.ls1, %pfor.cond16.strpm.detachloop.entry.ls1
  br label %pfor.cond16.epil.ls1

pfor.cond16.epil.ls1:                             ; preds = %pfor.preattach.epil.ls1, %pfor.cond16.epil.preheader.ls1
  %__begin10.0.epil.ls1 = phi i64 [ %inc.epil.ls1, %pfor.preattach.epil.ls1 ], [ 9216, %pfor.cond16.epil.preheader.ls1 ]
  %epil.iter.ls1 = phi i64 [ %epil.iter.sub.ls1, %pfor.preattach.epil.ls1 ], [ 784, %pfor.cond16.epil.preheader.ls1 ]
  %mul22.epil.ls1 = mul nuw nsw i64 %__begin10.0.epil.ls1, %__begin.0.ls1
  %conv.epil.ls1 = trunc i64 %mul22.epil.ls1 to i32
  %call.i8994.epil.ls1 = tail call i32 @__cilkrts_get_worker_number()
  %conv.i90.epil.ls1 = sext i32 %call.i8994.epil.ls1 to i64
  %3 = load ptr, ptr %frontier.ls1, align 8, !tbaa !12
  %add.ptr.i.i91.epil.ls1 = getelementptr inbounds %"struct.Reducer_Vector<int>::aligned_f", ptr %3, i64 %conv.i90.epil.ls1
  %_M_finish.i.i.epil.ls1 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data", ptr %add.ptr.i.i91.epil.ls1, i64 0, i32 1
  %4 = load ptr, ptr %_M_finish.i.i.epil.ls1, align 8, !tbaa !9
  %_M_end_of_storage.i.i.epil.ls1 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data", ptr %add.ptr.i.i91.epil.ls1, i64 0, i32 2
  %5 = load ptr, ptr %_M_end_of_storage.i.i.epil.ls1, align 8, !tbaa !23
  %cmp.not.i.i.epil.ls1 = icmp eq ptr %4, %5
  br i1 %cmp.not.i.i.epil.ls1, label %if.else.i.i93.epil.ls1, label %if.then.i.i92.epil.ls1

if.then.i.i92.epil.ls1:                           ; preds = %pfor.cond16.epil.ls1
  store i32 %conv.epil.ls1, ptr %4, align 4, !tbaa !25
  %incdec.ptr.i.i.epil.ls1 = getelementptr inbounds i32, ptr %4, i64 1
  store ptr %incdec.ptr.i.i.epil.ls1, ptr %_M_finish.i.i.epil.ls1, align 8, !tbaa !9
  br label %pfor.preattach.epil.ls1

pfor.preattach.epil.ls1:                          ; preds = %_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_.exit.i.i.epil.ls1, %if.then.i.i92.epil.ls1
  %inc.epil.ls1 = add nuw nsw i64 %__begin10.0.epil.ls1, 1
  %epil.iter.sub.ls1 = add nsw i64 %epil.iter.ls1, -1
  %epil.iter.cmp.not.ls1 = icmp eq i64 %epil.iter.sub.ls1, 0
  br i1 %epil.iter.cmp.not.ls1, label %pfor.cond.cleanup.epilog-lcssa.ls1, label %pfor.cond16.epil.ls1, !llvm.loop !31

pfor.cond.cleanup.epilog-lcssa.ls1:               ; preds = %pfor.preattach.epil.ls1
  sync within %syncreg3.ls1, label %sync.continue.ls1

if.else.i.i93.epil.ls1:                           ; preds = %pfor.cond16.epil.ls1
  %6 = load ptr, ptr %add.ptr.i.i91.epil.ls1, align 8, !tbaa !11
  %sub.ptr.lhs.cast.i.i.i.i.i.epil.ls1 = ptrtoint ptr %4 to i64
  %sub.ptr.rhs.cast.i.i.i.i.i.epil.ls1 = ptrtoint ptr %6 to i64
  %sub.ptr.sub.i.i.i.i.i.epil.ls1 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.epil.ls1, %sub.ptr.rhs.cast.i.i.i.i.i.epil.ls1
  %cmp.i.i.i.i.epil.ls1 = icmp eq i64 %sub.ptr.sub.i.i.i.i.i.epil.ls1, 9223372036854775804
  br i1 %cmp.i.i.i.i.epil.ls1, label %if.then.i.i.i.i.epil.ls1, label %_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.epil.ls1

_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.epil.ls1: ; preds = %if.else.i.i93.epil.ls1
  %sub.ptr.div.i.i.i.i.i.epil.ls1 = ashr exact i64 %sub.ptr.sub.i.i.i.i.i.epil.ls1, 2
  %.sroa.speculated.i.i.i.i.epil.ls1 = tail call i64 @llvm.umax.i64(i64 %sub.ptr.div.i.i.i.i.i.epil.ls1, i64 1)
  %add.i.i.i.i.epil.ls1 = add i64 %.sroa.speculated.i.i.i.i.epil.ls1, %sub.ptr.div.i.i.i.i.i.epil.ls1
  %cmp7.i.i.i.i.epil.ls1 = icmp ult i64 %add.i.i.i.i.epil.ls1, %sub.ptr.div.i.i.i.i.i.epil.ls1
  %cmp9.i.i.i.i.epil.ls1 = icmp ugt i64 %add.i.i.i.i.epil.ls1, 2305843009213693951
  %or.cond.i.i.i.i.epil.ls1 = or i1 %cmp7.i.i.i.i.epil.ls1, %cmp9.i.i.i.i.epil.ls1
  %cond.i.i.i.i.epil.ls1 = select i1 %or.cond.i.i.i.i.epil.ls1, i64 2305843009213693951, i64 %add.i.i.i.i.epil.ls1
  %cmp.not.i.i.i.i.epil.ls1 = icmp eq i64 %cond.i.i.i.i.epil.ls1, 0
  br i1 %cmp.not.i.i.i.i.epil.ls1, label %_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.epil.ls1, label %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i.epil.ls1

_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i.epil.ls1: ; preds = %_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.epil.ls1
  %mul.i.i.i.i.i.i.i.epil.ls1 = shl nuw nsw i64 %cond.i.i.i.i.epil.ls1, 2
  %call5.i.i.i.i.i.i.i95.epil.ls1 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %mul.i.i.i.i.i.i.i.epil.ls1) #19
  br label %_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.epil.ls1

_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.epil.ls1: ; preds = %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i.epil.ls1, %_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.epil.ls1
  %cond.i31.i.i.i.epil.ls1 = phi ptr [ null, %_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc.exit.i.i.i.epil.ls1 ], [ %call5.i.i.i.i.i.i.i95.epil.ls1, %_ZNSt16allocator_traitsISaIiEE8allocateERS0_m.exit.i.i.i.i.epil.ls1 ]
  %add.ptr.i.i.i.epil.ls1 = getelementptr inbounds i32, ptr %cond.i31.i.i.i.epil.ls1, i64 %sub.ptr.div.i.i.i.i.i.epil.ls1
  store i32 %conv.epil.ls1, ptr %add.ptr.i.i.i.epil.ls1, align 4, !tbaa !25
  %cmp.i.i.i.i.i.i.epil.ls1 = icmp sgt i64 %sub.ptr.sub.i.i.i.i.i.epil.ls1, 0
  br i1 %cmp.i.i.i.i.i.i.epil.ls1, label %if.then.i.i.i.i.i.i.epil.ls1, label %_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.epil.ls1

_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.epil.ls1: ; preds = %if.then.i.i.i.i.i.i.epil.ls1, %_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.epil.ls1
  %incdec.ptr.i.i.i.epil.ls1 = getelementptr inbounds i32, ptr %add.ptr.i.i.i.epil.ls1, i64 1
  %tobool.not.i.i.i.i.epil.ls1 = icmp eq ptr %6, null
  br i1 %tobool.not.i.i.i.i.epil.ls1, label %_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_.exit.i.i.epil.ls1, label %if.then.i40.i.i.i.epil.ls1

if.then.i40.i.i.i.epil.ls1:                       ; preds = %_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.epil.ls1
  tail call void @_ZdlPv(ptr noundef nonnull %6) #17
  br label %_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_.exit.i.i.epil.ls1

_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_.exit.i.i.epil.ls1: ; preds = %if.then.i40.i.i.i.epil.ls1, %_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.epil.ls1
  store ptr %cond.i31.i.i.i.epil.ls1, ptr %add.ptr.i.i91.epil.ls1, align 8, !tbaa !11
  store ptr %incdec.ptr.i.i.i.epil.ls1, ptr %_M_finish.i.i.epil.ls1, align 8, !tbaa !9
  %add.ptr19.i.i.i.epil.ls1 = getelementptr inbounds i32, ptr %cond.i31.i.i.i.epil.ls1, i64 %cond.i.i.i.i.epil.ls1
  store ptr %add.ptr19.i.i.i.epil.ls1, ptr %_M_end_of_storage.i.i.epil.ls1, align 8, !tbaa !23
  br label %pfor.preattach.epil.ls1

if.then.i.i.i.i.i.i.epil.ls1:                     ; preds = %_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm.exit.i.i.i.epil.ls1
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 4 %cond.i31.i.i.i.epil.ls1, ptr align 4 %6, i64 %sub.ptr.sub.i.i.i.i.i.epil.ls1, i1 false)
  br label %_ZNSt6vectorIiSaIiEE11_S_relocateEPiS2_S2_RS0_.exit39.i.i.i.epil.ls1

if.then.i.i.i.i.epil.ls1:                         ; preds = %if.else.i.i93.epil.ls1
  tail call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.2) #18
  unreachable

sync.continue.ls1:                                ; preds = %pfor.cond.cleanup.epilog-lcssa.ls1
  tail call void @llvm.sync.unwind(token %syncreg3.ls1)
  %inc44.ls1 = add nuw nsw i64 %__begin.0.ls1, 1
  %exitcond107.not.ls1 = icmp eq i64 %inc44.ls1, %end.ls1
  br i1 %exitcond107.not.ls1, label %pfor.cond.cleanup46.ls1, label %pfor.body.entry.new.ls1, !llvm.loop !32

pfor.cond16.strpm.detachloop.entry.ls1:           ; preds = %pfor.body.entry.new.ls1
  tail call fastcc void @main.outline_pfor.cond16.strpm.outer.ls2(i64 0, i64 9, i64 1, i64 %__begin.0.ls1, ptr %frontier.ls1) #16
  reattach within %syncreg3.ls1, label %pfor.cond16.epil.preheader.ls1

pfor.cond.cleanup46.ls1:                          ; preds = %sync.continue.ls1
  sync within %0, label %pfor.cond.cleanup46.ls1.split

pfor.cond.cleanup46.ls1.split:                    ; preds = %pfor.cond.cleanup46.ls1
  tail call void @llvm.sync.unwind(token %0)
  ret void
}

; CHECK-LABEL: define internal fastcc void @main.outline_pfor.cond.ls1(

; CHECK: pfor.body.entry.new.ls1.preheader:
; CHECK-NOT: call {{.*}}@llvm.threadlocal.address.p0(ptr {{.*}}@__cilkrts_tls_worker)
; CHECK: br label %pfor.body.entry.new.ls1

; CHECK: pfor.body.entry.new.ls1:
; CHECK: br i1 %{{.*}}, label %[[PFOR_BODY_ENTRY_NEW_LS1_DETACH:.+]], label %pfor.cond16.epil.ls1.preheader

; CHECK: [[PFOR_BODY_ENTRY_NEW_LS1_DETACH]]:
; CHECK-NEXT: call {{.*}}void @main.outline_pfor.cond.ls1.outline_pfor.cond16.strpm.detachloop.entry.ls1.otd1(
; CHECK-NEXT: br label %pfor.cond16.epil.ls1.preheader

; CHECK: pfor.cond16.epil.ls1.preheader:

; CHECK: %[[CILKRTS_TLS_WORKER_TLA:.+]] = {{.*}}call {{.*}}@llvm.threadlocal.address.p0(ptr {{.*}}@__cilkrts_tls_worker)

; CHECK: load ptr, ptr %[[CILKRTS_TLS_WORKER_TLA]]

attributes #0 = { norecurse uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { willreturn memory(argmem: readwrite) }
attributes #4 = { inlinehint nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nobuiltin nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { mustprogress nofree willreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #10 = { noreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #12 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
attributes #13 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #14 = { nofree nounwind }
attributes #15 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #16 = { nounwind }
attributes #17 = { builtin nounwind }
attributes #18 = { noreturn }
attributes #19 = { builtin allocsize(0) }

!llvm.linker.options = !{}
!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 16.0.6 (git@github.com:OpenCilk/opencilk-project.git 6b9364aeceab408e3bce8da0cc8796d75039eb46)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"any pointer", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = !{!10, !6, i64 8}
!10 = !{!"_ZTSNSt12_Vector_baseIiSaIiEE17_Vector_impl_dataE", !6, i64 0, !6, i64 8, !6, i64 16}
!11 = !{!10, !6, i64 0}
!12 = !{!13, !6, i64 0}
!13 = !{!"_ZTSNSt12_Vector_baseIN14Reducer_VectorIiE9aligned_fESaIS2_EE17_Vector_impl_dataE", !6, i64 0, !6, i64 8, !6, i64 16}
!14 = !{!13, !6, i64 8}
!15 = distinct !{!15, !16}
!16 = !{!"llvm.loop.mustprogress"}
!17 = !{!13, !6, i64 16}
!18 = !{!19}
!19 = distinct !{!19, !20, !"_ZSt19__relocate_object_aIN14Reducer_VectorIiE9aligned_fES2_SaIS2_EEvPT_PT0_RT1_: %__dest"}
!20 = distinct !{!20, !"_ZSt19__relocate_object_aIN14Reducer_VectorIiE9aligned_fES2_SaIS2_EEvPT_PT0_RT1_"}
!21 = !{!22}
!22 = distinct !{!22, !20, !"_ZSt19__relocate_object_aIN14Reducer_VectorIiE9aligned_fES2_SaIS2_EEvPT_PT0_RT1_: %__orig"}
!23 = !{!10, !6, i64 16}
!24 = distinct !{!24, !16}
!25 = !{!26, !26, i64 0}
!26 = !{!"int", !7, i64 0}
!27 = distinct !{!27, !28}
!28 = !{!"llvm.loop.fromtapirloop"}
!29 = distinct !{!29, !30}
!30 = !{!"tapir.loop.spawn.strategy", i32 0}
!31 = distinct !{!31, !28}
!32 = distinct !{!32, !30}
