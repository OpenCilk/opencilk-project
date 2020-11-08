; RUN: opt < %s -tti -tbaa -loop-stripmine -indvars -licm -loop-vectorize -instcombine -simplifycfg -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<long, std::allocator<long> >::_Vector_impl" }
%"struct.std::_Vector_base<long, std::allocator<long> >::_Vector_impl" = type { %"struct.std::_Vector_base<long, std::allocator<long> >::_Vector_impl_data" }
%"struct.std::_Vector_base<long, std::allocator<long> >::_Vector_impl_data" = type { i64*, i64*, i64* }
%"class.cilk::reducer_opadd" = type { %"class.cilk::reducer.base", [56 x i8] }
%"class.cilk::reducer.base" = type { %"class.cilk::internal::reducer_content.base" }
%"class.cilk::internal::reducer_content.base" = type { %"class.cilk::internal::reducer_base", [56 x i8], [8 x i8] }
%"class.cilk::internal::reducer_base" = type { %struct.__cilkrts_hyperobject_base, %"class.cilk::internal::storage_for_object", i8* }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i32, i32, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (i8*, i64)*, void (i8*, i8*)* }
%"class.cilk::internal::storage_for_object" = type { %"class.cilk::internal::aligned_storage" }
%"class.cilk::internal::aligned_storage" = type { [1 x i8] }

$__clang_call_terminate = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_ = comdat any

@.str.13 = private unnamed_addr constant [22 x i8] c"this == m_initialThis\00", align 1
@.str.14 = private unnamed_addr constant [69 x i8] c"/data/animals/opencilk/build/lib/clang/10.0.1/include/cilk/reducer.h\00", align 1
@__PRETTY_FUNCTION__._ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev = private unnamed_addr constant [119 x i8] c"cilk::internal::reducer_base<cilk::op_add<long long, true> >::~reducer_base() [Monoid = cilk::op_add<long long, true>]\00", align 1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #0

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #1

; Function Attrs: uwtable
define dso_local i64 @_Z13accum_reducerRKSt6vectorIlSaIlEE(%"class.std::vector"* nocapture readonly dereferenceable(24) %vals) local_unnamed_addr #2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %sum = alloca %"class.cilk::reducer_opadd", align 64
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = bitcast %"class.cilk::reducer_opadd"* %sum to i8*
  call void @llvm.lifetime.start.p0i8(i64 192, i8* nonnull %0) #9
  %1 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0
  %m_base.i.i.i.i = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0
  %reduce_fn.i.i.i.i = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  store void (i8*, i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, void (i8*, i8*, i8*)** %reduce_fn.i.i.i.i, align 64, !tbaa !2
  %2 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, void (i8*, i8*)** %2, align 8, !tbaa !7
  %3 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 2
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, void (i8*, i8*)** %3, align 16, !tbaa !8
  %4 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 3
  store i8* (i8*, i64)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i8* (i8*, i64)** %4, align 8, !tbaa !9
  %5 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 4
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, void (i8*, i8*)** %5, align 32, !tbaa !10
  %6 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0, i32 1
  store i32 0, i32* %6, align 8, !tbaa !11
  %7 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0, i32 2
  store i32 128, i32* %7, align 4, !tbaa !15
  %8 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 0, i32 3
  store i64 8, i64* %8, align 16, !tbaa !16
  %9 = getelementptr inbounds %"class.cilk::reducer_opadd", %"class.cilk::reducer_opadd"* %sum, i64 0, i32 0, i32 0, i32 0, i32 2
  %10 = bitcast i8** %9 to %"class.cilk::internal::reducer_base"**
  store %"class.cilk::internal::reducer_base"* %1, %"class.cilk::internal::reducer_base"** %10, align 64, !tbaa !17
  call void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base* nonnull %m_base.i.i.i.i)
  %11 = load i32, i32* %7, align 4, !tbaa !20
  %idx.ext.i.i.i = zext i32 %11 to i64
  %add.ptr.i.i.i = getelementptr inbounds i8, i8* %0, i64 %idx.ext.i.i.i
  %m_value.i.i.i.i.i = bitcast i8* %add.ptr.i.i.i to i64*
  store i64 0, i64* %m_value.i.i.i.i.i, align 8, !tbaa !21
  %_M_finish.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %vals, i64 0, i32 0, i32 0, i32 0, i32 1
  %12 = bitcast i64** %_M_finish.i to i64*
  %13 = load i64, i64* %12, align 8, !tbaa !24
  %14 = bitcast %"class.std::vector"* %vals to i64*
  %15 = load i64, i64* %14, align 8, !tbaa !26
  %sub.ptr.sub.i = sub i64 %13, %15
  %16 = lshr exact i64 %sub.ptr.sub.i, 3
  %conv = trunc i64 %16 to i32
  %cmp = icmp sgt i32 %conv, 0
  %17 = inttoptr i64 %15 to i64*
  br i1 %cmp, label %pfor.cond.preheader, label %invoke.cont20

pfor.cond.preheader:                              ; preds = %entry
  %wide.trip.count = and i64 %16, 4294967295
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %indvars.iv = phi i64 [ 0, %pfor.cond.preheader ], [ %indvars.iv.next, %pfor.inc ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  detach within %syncreg, label %invoke.cont7, label %pfor.inc

invoke.cont7:                                     ; preds = %pfor.cond
  %add.ptr.i = getelementptr inbounds i64, i64* %17, i64 %indvars.iv
  %18 = load i64, i64* %add.ptr.i, align 8, !tbaa !27
  %call.i.i.i = call strand_noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base* nonnull %m_base.i.i.i.i) #10
  %m_value.i.i = bitcast i8* %call.i.i.i to i64*
  %19 = load i64, i64* %m_value.i.i, align 8, !tbaa !21
  %add.i.i = add nsw i64 %19, %18
  store i64 %add.i.i, i64* %m_value.i.i, align 8, !tbaa !21
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %invoke.cont7, %pfor.cond
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !28

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue

lpad10:                                           ; preds = %sync.continue
  %20 = landingpad { i8*, i32 }
          cleanup
  %21 = load i8*, i8** %9, align 64, !tbaa !17
  %cmp.i.i = icmp eq i8* %21, %0
  br i1 %cmp.i.i, label %cond.end.i.i, label %cond.false.i.i

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %invoke.cont20 unwind label %lpad10

invoke.cont20:                                    ; preds = %sync.continue, %entry
  %call.i.i.i.i = call strand_noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base* nonnull %m_base.i.i.i.i) #10
  %m_value.i.i.i = bitcast i8* %call.i.i.i.i to i64*
  %22 = load i64, i64* %m_value.i.i.i, align 8, !tbaa !30
  %23 = load i8*, i8** %9, align 64, !tbaa !17
  %cmp.i.i48 = icmp eq i8* %23, %0
  br i1 %cmp.i.i48, label %cond.end.i.i51, label %cond.false.i.i49

cond.false.i.i49:                                 ; preds = %invoke.cont20
  call void @__assert_fail(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.13, i64 0, i64 0), i8* getelementptr inbounds ([69 x i8], [69 x i8]* @.str.14, i64 0, i64 0), i32 840, i8* getelementptr inbounds ([119 x i8], [119 x i8]* @__PRETTY_FUNCTION__._ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev, i64 0, i64 0)) #11
  unreachable

cond.end.i.i51:                                   ; preds = %invoke.cont20
  invoke void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base* nonnull %m_base.i.i.i.i)
          to label %_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev.exit53 unwind label %terminate.lpad.i.i52

terminate.lpad.i.i52:                             ; preds = %cond.end.i.i51
  %24 = landingpad { i8*, i32 }
          catch i8* null
  %25 = extractvalue { i8*, i32 } %24, 0
  call void @__clang_call_terminate(i8* %25) #11
  unreachable

_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev.exit53:  ; preds = %cond.end.i.i51
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %0) #9
  ret i64 %22

cond.false.i.i:                                   ; preds = %lpad10
  call void @__assert_fail(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.13, i64 0, i64 0), i8* getelementptr inbounds ([69 x i8], [69 x i8]* @.str.14, i64 0, i64 0), i32 840, i8* getelementptr inbounds ([119 x i8], [119 x i8]* @__PRETTY_FUNCTION__._ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev, i64 0, i64 0)) #11
  unreachable

cond.end.i.i:                                     ; preds = %lpad10
  invoke void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base* nonnull %m_base.i.i.i.i)
          to label %_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev.exit unwind label %terminate.lpad.i.i

terminate.lpad.i.i:                               ; preds = %cond.end.i.i
  %26 = landingpad { i8*, i32 }
          catch i8* null
  %27 = extractvalue { i8*, i32 } %26, 0
  call void @__clang_call_terminate(i8* %27) #11
  unreachable

_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev.exit:    ; preds = %cond.end.i.i
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %0) #9
  resume { i8*, i32 } %20
}

; CHECK-LABEL: define dso_local i64 @_Z13accum_reducerRKSt6vectorIlSaIlEE(

; CHECK: call void @__cilkrts_hyper_create(

; CHECK: detach within %syncreg, label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

; CHECK: [[DETACHED]]:
; CHECK: %[[CALL:.+]] = call strand_noalias i8* @__cilkrts_hyper_lookup(
; CHECK: %[[VIEW:.+]] = bitcast i8* %[[CALL]] to i64*
; CHECK: br label %[[VECTOR_PH:.+]]

; CHECK: [[VECTOR_PH]]:
; CHECK: br label %[[VECTOR_BODY:.+]]

; CHECK: [[VECTOR_BODY]]:
; CHECK: phi <2 x i64>
; CHECK: load <2 x i64>
; CHECK: add <2 x i64>
; CHECK: br i1 %{{.+}}, label %[[MIDDLE_BLOCK:.+]], label %[[VECTOR_BODY]], !llvm.loop

; CHECK: [[MIDDLE_BLOCK]]:
; CHECK: add <2 x i64>
; CHECK: shufflevector <2 x i64>
; CHECK: add <2 x i64>
; CHECK: %[[RESULT:.+]] = extractelement <2 x i64>
; CHECK: store i64 %[[RESULT]], i64* %[[VIEW]]
; CHECK: reattach within %syncreg

; CHECK: sync within %syncreg

; CHECK: %[[CALL2:.+]] = call strand_noalias i8* @__cilkrts_hyper_lookup(
; CHECK-NEXT: %[[VIEW2:.+]] = bitcast i8* %[[CALL2]] to i64*
; CHECK-NEXT: %[[SUM:.+]] = load i64, i64* %[[VIEW2]]

; CHECK: invoke void @__cilkrts_hyper_destroy(
; CHECK-NEXT: to label %[[RET_BLOCK:.+]] unwind label %{{.+}}

; CHECK: [[RET_BLOCK]]:
; CHECK: ret i64 %[[SUM]]

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8* %0) local_unnamed_addr #3 comdat {
  %2 = tail call i8* @__cxa_begin_catch(i8* %0) #9
  tail call void @_ZSt9terminatev() #11
  unreachable
}

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #4

declare dso_local void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #5

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #6

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #7

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_(i8* %r, i8* %lhs, i8* %rhs) #2 comdat align 2 {
entry:
  %m_value.i.i = bitcast i8* %rhs to i64*
  %0 = load i64, i64* %m_value.i.i, align 8, !tbaa !21
  %m_value2.i.i = bitcast i8* %lhs to i64*
  %1 = load i64, i64* %m_value2.i.i, align 8, !tbaa !21
  %add.i.i = add nsw i64 %1, %0
  store i64 %add.i.i, i64* %m_value2.i.i, align 8, !tbaa !21
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_(i8* %r, i8* %view) #2 comdat align 2 {
entry:
  %m_value.i.i.i = bitcast i8* %view to i64*
  store i64 0, i64* %m_value.i.i.i, align 8, !tbaa !21
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_(i8* %r, i8* %view) #2 comdat align 2 {
entry:
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local i8* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm(i8* %r, i64 %bytes) #2 comdat align 2 {
entry:
  %call.i = tail call i8* @_Znwm(i64 %bytes)
  ret i8* %call.i
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_(i8* %r, i8* %view) #2 comdat align 2 {
entry:
  tail call void @_ZdlPv(i8* %view) #9
  ret void
}

declare dso_local void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #5

; Function Attrs: nounwind readonly strand_pure
declare dso_local strand_noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #8

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { argmemonly willreturn }
attributes #2 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline noreturn nounwind }
attributes #4 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nounwind readonly strand_pure "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { nounwind }
attributes #10 = { nounwind readonly strand_pure }
attributes #11 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 9c5f1e03ba9dc39b9bee419084e1cb1c698f6fe2)"}
!2 = !{!3, !4, i64 0}
!3 = !{!"_ZTS13cilk_c_monoid", !4, i64 0, !4, i64 8, !4, i64 16, !4, i64 24, !4, i64 32}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!3, !4, i64 8}
!8 = !{!3, !4, i64 16}
!9 = !{!3, !4, i64 24}
!10 = !{!3, !4, i64 32}
!11 = !{!12, !13, i64 40}
!12 = !{!"_ZTS26__cilkrts_hyperobject_base", !3, i64 0, !13, i64 40, !13, i64 44, !14, i64 48}
!13 = !{!"int", !5, i64 0}
!14 = !{!"long", !5, i64 0}
!15 = !{!12, !13, i64 44}
!16 = !{!12, !14, i64 48}
!17 = !{!18, !4, i64 64}
!18 = !{!"_ZTSN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEE", !12, i64 0, !19, i64 56, !4, i64 64}
!19 = !{!"_ZTSN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEEE"}
!20 = !{!18, !13, i64 44}
!21 = !{!22, !23, i64 0}
!22 = !{!"_ZTSN4cilk11scalar_viewIxEE", !23, i64 0}
!23 = !{!"long long", !5, i64 0}
!24 = !{!25, !4, i64 8}
!25 = !{!"_ZTSNSt12_Vector_baseIlSaIlEE17_Vector_impl_dataE", !4, i64 0, !4, i64 8, !4, i64 16}
!26 = !{!25, !4, i64 0}
!27 = !{!14, !14, i64 0}
!28 = distinct !{!28, !29}
!29 = !{!"tapir.loop.spawn.strategy", i32 1}
!30 = !{!23, !23, i64 0}
