; Check that CSI properly handles llvm.global_ctors initialized with
; zeroinitializer.
;
; RUN: opt < %s -csi -S -o - | FileCheck %s
; RUN: opt < %s -passes='csi' -S -o - | FileCheck %s
; RUN: opt < %s -csan -S -o - | FileCheck %s
; RUN: opt < %s -passes='cilksan' -S -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.absl::base_internal::SpinLock" = type { %"struct.std::atomic" }
%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"struct.std::__atomic_base" = type { i32 }
%"struct.absl::base_internal::LowLevelAlloc::Arena" = type opaque
%"class.absl::synchronization_internal::GraphCycles" = type { %"struct.absl::synchronization_internal::GraphCycles::Rep"* }
%"struct.absl::synchronization_internal::GraphCycles::Rep" = type { %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0" }
%"class.absl::synchronization_internal::(anonymous namespace)::Vec" = type { %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**, [8 x %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*], i32, i32 }
%"struct.absl::synchronization_internal::(anonymous namespace)::Node" = type { i32, i32, i32, i8, i64, %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", i32, i32, [40 x i8*] }
%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet" = type <{ %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", i32, [4 x i8] }>
%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap" = type <{ %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"struct.std::array", [4 x i8] }>
%"struct.std::array" = type { [8171 x i32] }
%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0" = type { i32*, [8 x i32], i32, i32 }
%"struct.absl::synchronization_internal::GraphId" = type { i64 }
%"struct.__gnu_cxx::__ops::_Iter_comp_iter" = type { %struct.ByRank }
%struct.ByRank = type { %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* }
%"struct.__gnu_cxx::__ops::_Iter_comp_val" = type { %struct.ByRank }
%"struct.__gnu_cxx::__ops::_Val_comp_iter" = type { %struct.ByRank }
%"struct.__gnu_cxx::__ops::_Iter_less_iter" = type { i8 }

$_ZN4absl24synchronization_internal11GraphCycles3RepC2Ev = comdat any

$__clang_call_terminate = comdat any

$_ZN4absl24synchronization_internal11GraphCycles3RepD2Ev = comdat any

$_ZN4absl13base_internal9UnhidePtrIvEEPT_m = comdat any

$_ZN4absl13base_internal7HidePtrIvEEmPT_ = comdat any

$_ZNSt14numeric_limitsIjE3maxEv = comdat any

$_ZN4absl13base_internal8SpinLock4LockEv = comdat any

$_ZN4absl13base_internal8SpinLock6UnlockEv = comdat any

$_ZN4absl13base_internal8SpinLock11TryLockImplEv = comdat any

$_ZN4absl13base_internal8SpinLock15TryLockInternalEjj = comdat any

$_ZStanSt12memory_orderSt23__memory_order_modifier = comdat any

$_ZN4absl13base_internal15SchedulingGuard19DisableReschedulingEv = comdat any

$_ZN4absl13base_internal15SchedulingGuard18EnableReschedulingEb = comdat any

$_ZNSt5arrayIiLm8171EE4fillERKi = comdat any

$_ZSt6fill_nIPimiET_S1_T0_RKT1_ = comdat any

$_ZNSt5arrayIiLm8171EE5beginEv = comdat any

$_ZNKSt5arrayIiLm8171EE4sizeEv = comdat any

$_ZSt10__fill_n_aIPimiET_S1_T0_RKT1_St26random_access_iterator_tag = comdat any

$_ZSt17__size_to_integerm = comdat any

$_ZSt19__iterator_categoryIPiENSt15iterator_traitsIT_E17iterator_categoryERKS2_ = comdat any

$_ZSt8__fill_aIPiiEvT_S1_RKT0_ = comdat any

$_ZSt9__fill_a1IPiiEN9__gnu_cxx11__enable_ifIXsr11__is_scalarIT0_EE7__valueEvE6__typeET_S6_RKS3_ = comdat any

$_ZNSt5arrayIiLm8171EE4dataEv = comdat any

$_ZNSt14__array_traitsIiLm8171EE6_S_ptrERA8171_Ki = comdat any

$_ZSt4copyIPiS0_ET0_T_S2_S1_ = comdat any

$_ZSt13__copy_move_aILb0EPiS0_ET1_T0_S2_S1_ = comdat any

$_ZSt12__miter_baseIPiET_S1_ = comdat any

$_ZSt12__niter_wrapIPiET_RKS1_S1_ = comdat any

$_ZSt14__copy_move_a1ILb0EPiS0_ET1_T0_S2_S1_ = comdat any

$_ZSt12__niter_baseIPiET_S1_ = comdat any

$_ZSt14__copy_move_a2ILb0EPiS0_ET1_T0_S2_S1_ = comdat any

$_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mIiEEPT_PKS3_S6_S4_ = comdat any

$_ZNSt5arrayIiLm8171EEixEm = comdat any

$_ZNSt14__array_traitsIiLm8171EE6_S_refERA8171_Kim = comdat any

$_ZSt5mergeIPiS0_S0_ET1_T_S2_T0_S3_S1_ = comdat any

$_ZSt4__lgl = comdat any

$_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_ = comdat any

$_ZSt9iter_swapIPiS0_EvT_T0_ = comdat any

$_ZSt4swapIiENSt9enable_ifIXsr6__and_ISt6__not_ISt15__is_tuple_likeIT_EESt21is_move_constructibleIS3_ESt18is_move_assignableIS3_EEE5valueEvE4typeERS3_SC_ = comdat any

$_ZSt13move_backwardIPiS0_ET0_T_S2_S1_ = comdat any

$_ZSt22__copy_move_backward_aILb1EPiS0_ET1_T0_S2_S1_ = comdat any

$_ZSt23__copy_move_backward_a1ILb1EPiS0_ET1_T0_S2_S1_ = comdat any

$_ZSt23__copy_move_backward_a2ILb1EPiS0_ET1_T0_S2_S1_ = comdat any

$_ZNSt20__copy_move_backwardILb1ELb1ESt26random_access_iterator_tagE13__copy_move_bIiEEPT_PKS3_S6_S4_ = comdat any

$_ZSt7__mergeIPiS0_S0_N9__gnu_cxx5__ops15_Iter_less_iterEET1_T_S5_T0_S6_S4_T2_ = comdat any

$_ZN9__gnu_cxx5__ops16__iter_less_iterEv = comdat any

$_ZNK9__gnu_cxx5__ops15_Iter_less_iterclIPiS3_EEbT_T0_ = comdat any

$_ZN4absl13base_internal8HideMaskEv = comdat any

@_ZN4absl24synchronization_internal12_GLOBAL__N_18arena_muE = internal global %"class.absl::base_internal::SpinLock" zeroinitializer, align 4
@_ZN4absl24synchronization_internal12_GLOBAL__N_15arenaE = internal unnamed_addr global %"struct.absl::base_internal::LowLevelAlloc::Arena"* null, align 8
@.str = private unnamed_addr constant [70 x i8] c"external/com_google_absl/absl/synchronization/internal/graphcycles.cc\00", align 1
@.str.1 = private unnamed_addr constant [43 x i8] c"Did not find live node in hash table %u %p\00", align 1
@.str.2 = private unnamed_addr constant [40 x i8] c"Did not clear visited marker on node %u\00", align 1
@.str.3 = private unnamed_addr constant [32 x i8] c"Duplicate occurrence of rank %d\00", align 1
@.str.4 = private unnamed_addr constant [43 x i8] c"Edge %u->%d has bad rank assignment %d->%d\00", align 1
@llvm.global_ctors = appending global [0 x { i32, void ()*, i8* }] zeroinitializer

; CHECK: @llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 0, void ()* @csirt.unit_ctor, i8* null }]

@_ZN4absl24synchronization_internal11GraphCyclesC1Ev = dso_local unnamed_addr alias void (%"class.absl::synchronization_internal::GraphCycles"*), void (%"class.absl::synchronization_internal::GraphCycles"*)* @_ZN4absl24synchronization_internal11GraphCyclesC2Ev
@_ZN4absl24synchronization_internal11GraphCyclesD1Ev = dso_local unnamed_addr alias void (%"class.absl::synchronization_internal::GraphCycles"*), void (%"class.absl::synchronization_internal::GraphCycles"*)* @_ZN4absl24synchronization_internal11GraphCyclesD2Ev

; Function Attrs: sanitize_cilk uwtable
define dso_local void @_ZN4absl24synchronization_internal11GraphCyclesC2Ev(%"class.absl::synchronization_internal::GraphCycles"* nocapture %this) unnamed_addr #0 align 2 {
entry:
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_120InitArenaIfNecessaryEv()
  %0 = load %"struct.absl::base_internal::LowLevelAlloc::Arena"*, %"struct.absl::base_internal::LowLevelAlloc::Arena"** @_ZN4absl24synchronization_internal12_GLOBAL__N_15arenaE, align 8, !tbaa !2
  %call = call i8* @_ZN4absl13base_internal13LowLevelAlloc14AllocWithArenaEmPNS1_5ArenaE(i64 33064, %"struct.absl::base_internal::LowLevelAlloc::Arena"* %0)
  %1 = bitcast i8* %call to %"struct.absl::synchronization_internal::GraphCycles::Rep"*
  call void @_ZN4absl24synchronization_internal11GraphCycles3RepC2Ev(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %1)
  %2 = bitcast %"class.absl::synchronization_internal::GraphCycles"* %this to i8**
  store i8* %call, i8** %2, align 8, !tbaa !6
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_120InitArenaIfNecessaryEv() unnamed_addr #0 {
entry:
  call void @_ZN4absl13base_internal8SpinLock4LockEv(%"class.absl::base_internal::SpinLock"* nonnull @_ZN4absl24synchronization_internal12_GLOBAL__N_18arena_muE)
  %0 = load %"struct.absl::base_internal::LowLevelAlloc::Arena"*, %"struct.absl::base_internal::LowLevelAlloc::Arena"** @_ZN4absl24synchronization_internal12_GLOBAL__N_15arenaE, align 8, !tbaa !2
  %cmp = icmp eq %"struct.absl::base_internal::LowLevelAlloc::Arena"* %0, null
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %call = call %"struct.absl::base_internal::LowLevelAlloc::Arena"* @_ZN4absl13base_internal13LowLevelAlloc8NewArenaEi(i32 0)
  store %"struct.absl::base_internal::LowLevelAlloc::Arena"* %call, %"struct.absl::base_internal::LowLevelAlloc::Arena"** @_ZN4absl24synchronization_internal12_GLOBAL__N_15arenaE, align 8, !tbaa !2
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  call void @_ZN4absl13base_internal8SpinLock6UnlockEv(%"class.absl::base_internal::SpinLock"* nonnull @_ZN4absl24synchronization_internal12_GLOBAL__N_18arena_muE)
  ret void
}

declare dso_local i8* @_ZN4absl13base_internal13LowLevelAlloc14AllocWithArenaEmPNS1_5ArenaE(i64, %"struct.absl::base_internal::LowLevelAlloc::Arena"*) local_unnamed_addr #1 section "malloc_hook"

; Function Attrs: sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN4absl24synchronization_internal11GraphCycles3RepC2Ev(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %this) unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 0
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_)
  %free_nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 1
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %free_nodes_)
  %ptrmap_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 2
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMapC2EPKNS1_3VecIPNS1_4NodeEEE(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* nonnull %ptrmap_, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_)
          to label %invoke.cont4 unwind label %lpad3

invoke.cont4:                                     ; preds = %entry
  %deltaf_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 3
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_)
  %deltab_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 4
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_)
  %list_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 5
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %list_)
  %merged_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 6
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %merged_)
  %stack_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 7
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  ret void

lpad3:                                            ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %free_nodes_) #19
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_) #19
  resume { i8*, i32 } %0
}

; Function Attrs: nounwind sanitize_cilk uwtable
define dso_local void @_ZN4absl24synchronization_internal11GraphCyclesD2Ev(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this) unnamed_addr #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 0, i32 0
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_)
  %call4 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_)
  %cmp13 = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call, %call4
  br i1 %cmp13, label %for.cond.cleanup, label %for.body

for.cond.cleanup:                                 ; preds = %invoke.cont6, %entry
  %1 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  call void @_ZN4absl24synchronization_internal11GraphCycles3RepD2Ev(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %1) #19
  %2 = bitcast %"class.absl::synchronization_internal::GraphCycles"* %this to i8**
  %3 = load i8*, i8** %2, align 8, !tbaa !6
  invoke void @_ZN4absl13base_internal13LowLevelAlloc4FreeEPv(i8* %3)
          to label %invoke.cont11 unwind label %terminate.lpad

for.body:                                         ; preds = %entry, %invoke.cont6
  %__begin2.014 = phi %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** [ %incdec.ptr, %invoke.cont6 ], [ %call, %entry ]
  %4 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__begin2.014, align 8, !tbaa !2
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_14NodeD2Ev(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4) #19
  %5 = bitcast %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4 to i8*
  invoke void @_ZN4absl13base_internal13LowLevelAlloc4FreeEPv(i8* %5)
          to label %invoke.cont6 unwind label %lpad5

invoke.cont6:                                     ; preds = %for.body
  %incdec.ptr = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__begin2.014, i64 1
  %cmp = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %incdec.ptr, %call4
  br i1 %cmp, label %for.cond.cleanup, label %for.body

lpad5:                                            ; preds = %for.body
  %6 = landingpad { i8*, i32 }
          catch i8* null
  %7 = extractvalue { i8*, i32 } %6, 0
  call void @__clang_call_terminate(i8* %7) #20
  unreachable

invoke.cont11:                                    ; preds = %for.cond.cleanup
  ret void

terminate.lpad:                                   ; preds = %for.cond.cleanup
  %8 = landingpad { i8*, i32 }
          catch i8* null
  %9 = extractvalue { i8*, i32 } %8, 0
  call void @__clang_call_terminate(i8* %9) #20
  unreachable
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nocapture readonly %this) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*** %ptr_, align 8, !tbaa !8
  ret %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %0
}

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nocapture readonly %this) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*** %ptr_, align 8, !tbaa !8
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 2
  %1 = load i32, i32* %size_, align 8, !tbaa !11
  %idx.ext = zext i32 %1 to i64
  %add.ptr = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %0, i64 %idx.ext
  ret %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %add.ptr
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_14NodeD2Ev(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"* readonly %this) unnamed_addr #5 align 2 {
entry:
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %this, i64 0, i32 6
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetD2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out) #19
  %in = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %this, i64 0, i32 5
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetD2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in) #19
  ret void
}

declare dso_local void @_ZN4absl13base_internal13LowLevelAlloc4FreeEPv(i8*) local_unnamed_addr #1 section "malloc_hook"

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8* %0) local_unnamed_addr #6 comdat {
  %2 = call i8* @__cxa_begin_catch(i8* %0) #19
  call void @_ZSt9terminatev() #20
  unreachable
}

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN4absl24synchronization_internal11GraphCycles3RepD2Ev(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %this) unnamed_addr #5 comdat align 2 {
entry:
  %stack_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 7
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_) #19
  %merged_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 6
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %merged_) #19
  %list_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 5
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %list_) #19
  %deltab_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 4
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_) #19
  %deltaf_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 3
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_) #19
  %free_nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 1
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %free_nodes_) #19
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %this, i64 0, i32 0
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_) #19
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define dso_local zeroext i1 @_ZNK4absl24synchronization_internal11GraphCycles15CheckInvariantsEv(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this) local_unnamed_addr #0 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %ranks = alloca %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", align 8
  %y = alloca i32, align 4
  %_cursor = alloca i32, align 4
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %1 = bitcast %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %ranks to i8*
  call void @llvm.lifetime.start.p0i8(i64 56, i8* nonnull %1) #19
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %ranks)
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 0, i32 0
  %call40 = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_)
  %cmp41 = icmp eq i32 %call40, 0
  br i1 %cmp41, label %for.cond.cleanup, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %ptrmap_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 0, i32 2
  %2 = bitcast i32* %y to i8*
  %3 = bitcast i32* %_cursor to i8*
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.cond.cleanup38, %entry
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetD2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %ranks) #19
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %1) #19
  ret i1 true

for.body:                                         ; preds = %for.body.lr.ph, %for.cond.cleanup38
  %x.042 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.cond.cleanup38 ]
  %call5 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %x.042)
  %4 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call5, align 8, !tbaa !2
  %masked_ptr = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4, i64 0, i32 4
  %5 = load i64, i64* %masked_ptr, align 8, !tbaa !12
  %call8 = call i8* @_ZN4absl13base_internal9UnhidePtrIvEEPT_m(i64 %5)
  %cmp9 = icmp eq i8* %call8, null
  br i1 %cmp9, label %if.end, label %land.lhs.true

land.lhs.true:                                    ; preds = %for.body
  %call11 = invoke fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap4FindEPv(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* nonnull %ptrmap_, i8* nonnull %call8)
          to label %invoke.cont10 unwind label %lpad6

invoke.cont10:                                    ; preds = %land.lhs.true
  %cmp12 = icmp eq i32 %call11, %x.042
  br i1 %cmp12, label %if.end, label %do.body

do.body:                                          ; preds = %invoke.cont10
  invoke void (i32, i8*, i32, i8*, ...) @_ZN4absl20raw_logging_internal6RawLogENS_11LogSeverityEPKciS3_z(i32 3, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @.str, i64 0, i64 55), i32 386, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.1, i64 0, i64 0), i32 %x.042, i8* nonnull %call8)
          to label %if.end unwind label %lpad13

lpad6:                                            ; preds = %if.end22, %land.lhs.true
  %6 = landingpad { i8*, i32 }
          cleanup
  %7 = extractvalue { i8*, i32 } %6, 0
  %8 = extractvalue { i8*, i32 } %6, 1
  br label %ehcleanup59

lpad13:                                           ; preds = %do.body
  %9 = landingpad { i8*, i32 }
          cleanup
  %10 = extractvalue { i8*, i32 } %9, 0
  %11 = extractvalue { i8*, i32 } %9, 1
  br label %ehcleanup59

if.end:                                           ; preds = %do.body, %invoke.cont10, %for.body
  %visited = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4, i64 0, i32 3
  %12 = load i8, i8* %visited, align 4, !tbaa !18, !range !19
  %tobool = icmp eq i8 %12, 0
  br i1 %tobool, label %if.end22, label %do.body16

do.body16:                                        ; preds = %if.end
  invoke void (i32, i8*, i32, i8*, ...) @_ZN4absl20raw_logging_internal6RawLogENS_11LogSeverityEPKciS3_z(i32 3, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @.str, i64 0, i64 55), i32 389, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.2, i64 0, i64 0), i32 %x.042)
          to label %if.end22 unwind label %lpad18

lpad18:                                           ; preds = %do.body16
  %13 = landingpad { i8*, i32 }
          cleanup
  %14 = extractvalue { i8*, i32 } %13, 0
  %15 = extractvalue { i8*, i32 } %13, 1
  br label %ehcleanup59

if.end22:                                         ; preds = %do.body16, %if.end
  %rank = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4, i64 0, i32 0
  %16 = load i32, i32* %rank, align 8, !tbaa !20
  %call24 = invoke fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet6insertEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %ranks, i32 %16)
          to label %invoke.cont23 unwind label %lpad6

invoke.cont23:                                    ; preds = %if.end22
  br i1 %call24, label %if.end33, label %do.body26

do.body26:                                        ; preds = %invoke.cont23
  %17 = load i32, i32* %rank, align 8, !tbaa !20
  invoke void (i32, i8*, i32, i8*, ...) @_ZN4absl20raw_logging_internal6RawLogENS_11LogSeverityEPKciS3_z(i32 3, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @.str, i64 0, i64 55), i32 392, i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.3, i64 0, i64 0), i32 %17)
          to label %if.end33 unwind label %lpad29

lpad29:                                           ; preds = %do.body26
  %18 = landingpad { i8*, i32 }
          cleanup
  %19 = extractvalue { i8*, i32 } %18, 0
  %20 = extractvalue { i8*, i32 } %18, 1
  br label %ehcleanup59

if.end33:                                         ; preds = %do.body26, %invoke.cont23
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %2) #19
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #19
  store i32 0, i32* %_cursor, align 4, !tbaa !21
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4, i64 0, i32 6
  %call3739 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32* nonnull %_cursor, i32* nonnull %y)
  br i1 %call3739, label %for.body39, label %for.cond.cleanup38

for.cond.cleanup38:                               ; preds = %if.end56, %if.end33
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %2) #19
  %inc = add nuw i32 %x.042, 1
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_)
  %cmp = icmp ult i32 %inc, %call
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.body39:                                       ; preds = %if.end33, %if.end56
  %21 = load i32, i32* %y, align 4, !tbaa !21
  %call43 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %21)
  %22 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call43, align 8, !tbaa !2
  %23 = load i32, i32* %rank, align 8, !tbaa !20
  %rank45 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %22, i64 0, i32 0
  %24 = load i32, i32* %rank45, align 8, !tbaa !20
  %cmp46 = icmp slt i32 %23, %24
  br i1 %cmp46, label %if.end56, label %do.body48

do.body48:                                        ; preds = %for.body39
  invoke void (i32, i8*, i32, i8*, ...) @_ZN4absl20raw_logging_internal6RawLogENS_11LogSeverityEPKciS3_z(i32 3, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @.str, i64 0, i64 55), i32 398, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.4, i64 0, i64 0), i32 %x.042, i32 %21, i32 %23, i32 %24)
          to label %if.end56 unwind label %lpad52

lpad52:                                           ; preds = %do.body48
  %25 = landingpad { i8*, i32 }
          cleanup
  %26 = extractvalue { i8*, i32 } %25, 0
  %27 = extractvalue { i8*, i32 } %25, 1
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %2) #19
  br label %ehcleanup59

if.end56:                                         ; preds = %do.body48, %for.body39
  %call37 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32* nonnull %_cursor, i32* nonnull %y)
  br i1 %call37, label %for.body39, label %for.cond.cleanup38

ehcleanup59:                                      ; preds = %lpad52, %lpad29, %lpad18, %lpad13, %lpad6
  %ehselector.slot.0 = phi i32 [ %27, %lpad52 ], [ %20, %lpad29 ], [ %8, %lpad6 ], [ %15, %lpad18 ], [ %11, %lpad13 ]
  %exn.slot.0 = phi i8* [ %26, %lpad52 ], [ %19, %lpad29 ], [ %7, %lpad6 ], [ %14, %lpad18 ], [ %10, %lpad13 ]
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetD2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %ranks) #19
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %1) #19
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.0, 0
  %lpad.val66 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.0, 1
  resume { i8*, i32 } %lpad.val66
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this) unnamed_addr #0 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_)
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  ret void

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_) #19
  resume { i8*, i32 } %0
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nocapture readonly %this) unnamed_addr #4 align 2 {
entry:
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 2
  %0 = load i32, i32* %size_, align 8, !tbaa !11
  ret i32 %0
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nocapture readonly %this, i32 %i) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*** %ptr_, align 8, !tbaa !8
  %idxprom = zext i32 %i to i64
  %arrayidx = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %0, i64 %idxprom
  ret %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %arrayidx
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i8* @_ZN4absl13base_internal9UnhidePtrIvEEPT_m(i64 %hidden) local_unnamed_addr #5 comdat {
entry:
  %call = call i64 @_ZN4absl13base_internal8HideMaskEv()
  %xor = xor i64 %call, %hidden
  %0 = inttoptr i64 %xor to i8*
  ret i8* %0
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap4FindEPv(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i8* %ptr) unnamed_addr #0 align 2 {
entry:
  %call = call i64 @_ZN4absl13base_internal7HidePtrIvEEmPT_(i8* %ptr)
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i64 0, i32 1
  %call2 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap4HashEPv(i8* %ptr)
  %conv = zext i32 %call2 to i64
  %call3 = call dereferenceable(4) i32* @_ZNSt5arrayIiLm8171EEixEm(%"struct.std::array"* nonnull %table_, i64 %conv) #19
  %nodes_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i64 0, i32 0
  %i.017 = load i32, i32* %call3, align 4, !tbaa !21
  %cmp18 = icmp eq i32 %i.017, -1
  br i1 %cmp18, label %cleanup6, label %for.body.preheader

for.body.preheader:                               ; preds = %entry
  %0 = load %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %nodes_, align 8, !tbaa !22
  br label %for.body

for.cond:                                         ; preds = %for.body
  %next_hash = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %1, i64 0, i32 2
  %i.0 = load i32, i32* %next_hash, align 4, !tbaa !21
  %cmp = icmp eq i32 %i.0, -1
  br i1 %cmp, label %cleanup6, label %for.body

for.body:                                         ; preds = %for.body.preheader, %for.cond
  %i.019 = phi i32 [ %i.0, %for.cond ], [ %i.017, %for.body.preheader ]
  %call4 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %0, i32 %i.019)
  %1 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call4, align 8, !tbaa !2
  %masked_ptr = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %1, i64 0, i32 4
  %2 = load i64, i64* %masked_ptr, align 8, !tbaa !12
  %cmp5 = icmp eq i64 %2, %call
  br i1 %cmp5, label %cleanup6, label %for.cond

cleanup6:                                         ; preds = %for.body, %for.cond, %entry
  %i.0.lcssa = phi i32 [ %i.017, %entry ], [ %i.019, %for.body ], [ %i.0, %for.cond ]
  ret i32 %i.0.lcssa
}

declare dso_local void @_ZN4absl20raw_logging_internal6RawLogENS_11LogSeverityEPKciS3_z(i32, i8*, i32, i8*, ...) local_unnamed_addr #1

; Function Attrs: sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet6insertEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i32 %v) unnamed_addr #0 align 2 {
entry:
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_17NodeSet9FindIndexEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i32 %v)
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  %call2 = call fastcc dereferenceable(4) i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 %call)
  %0 = load i32, i32* %call2, align 4, !tbaa !21
  %cmp = icmp eq i32 %0, %v
  br i1 %cmp, label %cleanup, label %if.end

if.end:                                           ; preds = %entry
  %cmp5 = icmp eq i32 %0, -1
  br i1 %cmp5, label %if.then6, label %if.end7

if.then6:                                         ; preds = %if.end
  %occupied_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 1
  %1 = load i32, i32* %occupied_, align 8, !tbaa !25
  %inc = add i32 %1, 1
  store i32 %inc, i32* %occupied_, align 8, !tbaa !25
  br label %if.end7

if.end7:                                          ; preds = %if.then6, %if.end
  %call9 = call fastcc dereferenceable(4) i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 %call)
  store i32 %v, i32* %call9, align 4, !tbaa !21
  %occupied_10 = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 1
  %2 = load i32, i32* %occupied_10, align 8, !tbaa !25
  %call12 = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_)
  %div = lshr i32 %call12, 2
  %sub = sub i32 %call12, %div
  %cmp15 = icmp ult i32 %2, %sub
  br i1 %cmp15, label %cleanup, label %if.then16

if.then16:                                        ; preds = %if.end7
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4GrowEv(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %this)
  br label %cleanup

cleanup:                                          ; preds = %if.then16, %if.end7, %entry
  %retval.0 = phi i1 [ false, %entry ], [ true, %if.end7 ], [ true, %if.then16 ]
  ret i1 %retval.0
}

; Function Attrs: nofree norecurse nounwind sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nocapture readonly %this, i32* nocapture %cursor, i32* nocapture %elem) unnamed_addr #7 align 2 {
entry:
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load i32, i32* %cursor, align 4, !tbaa !21
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_)
  %cmp = icmp ult i32 %0, %call
  br i1 %cmp, label %while.body, label %return

while.body:                                       ; preds = %while.cond
  %call3 = call fastcc dereferenceable(4) i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 %0)
  %1 = load i32, i32* %call3, align 4, !tbaa !21
  %inc = add nuw nsw i32 %0, 1
  store i32 %inc, i32* %cursor, align 4, !tbaa !21
  %cmp4 = icmp sgt i32 %1, -1
  br i1 %cmp4, label %if.then, label %while.cond

if.then:                                          ; preds = %while.body
  store i32 %1, i32* %elem, align 4, !tbaa !21
  br label %return

return:                                           ; preds = %while.cond, %if.then
  %retval.2 = phi i1 [ true, %if.then ], [ false, %while.cond ]
  ret i1 %retval.2
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetD2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* readonly %this) unnamed_addr #5 align 2 {
entry:
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_) #19
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define dso_local i64 @_ZN4absl24synchronization_internal11GraphCycles5GetIdEPv(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i8* %ptr) local_unnamed_addr #0 align 2 {
entry:
  %n = alloca %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, align 8
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %ptrmap_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 0, i32 2
  %call = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap4FindEPv(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* nonnull %ptrmap_, i8* %ptr)
  %cmp = icmp eq i32 %call, -1
  %1 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  br i1 %cmp, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %1, i64 0, i32 0
  %call3 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %call)
  %2 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call3, align 8, !tbaa !2
  %version = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %2, i64 0, i32 1
  %3 = load i32, i32* %version, align 4, !tbaa !26
  %call4 = call fastcc i64 @_ZN4absl24synchronization_internal12_GLOBAL__N_16MakeIdEij(i32 %call, i32 %3)
  br label %cleanup

if.else:                                          ; preds = %entry
  %free_nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %1, i64 0, i32 1
  %call6 = call fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE5emptyEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %free_nodes_)
  br i1 %call6, label %if.then7, label %if.else23

if.then7:                                         ; preds = %if.else
  %4 = bitcast %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %n to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %4) #19
  %5 = load %"struct.absl::base_internal::LowLevelAlloc::Arena"*, %"struct.absl::base_internal::LowLevelAlloc::Arena"** @_ZN4absl24synchronization_internal12_GLOBAL__N_15arenaE, align 8, !tbaa !2
  %call8 = call i8* @_ZN4absl13base_internal13LowLevelAlloc14AllocWithArenaEmPNS1_5ArenaE(i64 464, %"struct.absl::base_internal::LowLevelAlloc::Arena"* %5)
  %6 = bitcast i8* %call8 to %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_14NodeC2Ev(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %6)
  %7 = bitcast %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %n to i8**
  store i8* %call8, i8** %7, align 8, !tbaa !2
  %version9 = getelementptr inbounds i8, i8* %call8, i64 4
  %8 = bitcast i8* %version9 to i32*
  store i32 1, i32* %8, align 4, !tbaa !26
  %9 = getelementptr inbounds i8, i8* %call8, i64 12
  store i8 0, i8* %9, align 4, !tbaa !18
  %10 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %nodes_11 = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %10, i64 0, i32 0
  %call12 = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_11)
  %rank = bitcast i8* %call8 to i32*
  store i32 %call12, i32* %rank, align 8, !tbaa !20
  %call13 = call i64 @_ZN4absl13base_internal7HidePtrIvEEmPT_(i8* %ptr)
  %masked_ptr = getelementptr inbounds i8, i8* %call8, i64 16
  %11 = bitcast i8* %masked_ptr to i64*
  store i64 %call13, i64* %11, align 8, !tbaa !12
  %nstack = getelementptr inbounds i8, i8* %call8, i64 140
  %12 = bitcast i8* %nstack to i32*
  store i32 0, i32* %12, align 4, !tbaa !27
  %priority = getelementptr inbounds i8, i8* %call8, i64 136
  %13 = bitcast i8* %priority to i32*
  store i32 0, i32* %13, align 8, !tbaa !28
  %14 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %nodes_15 = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %14, i64 0, i32 0
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE9push_backERKS4_(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_15, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** nonnull dereferenceable(8) %n)
  %15 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %ptrmap_17 = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %15, i64 0, i32 2
  %16 = load i32, i32* %rank, align 8, !tbaa !20
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap3AddEPvi(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* nonnull %ptrmap_17, i8* %ptr, i32 %16)
  %17 = load i32, i32* %rank, align 8, !tbaa !20
  %18 = load i32, i32* %8, align 4, !tbaa !26
  %call21 = call fastcc i64 @_ZN4absl24synchronization_internal12_GLOBAL__N_16MakeIdEij(i32 %17, i32 %18)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %4) #19
  br label %cleanup

if.else23:                                        ; preds = %if.else
  %call26 = call fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %free_nodes_)
  %19 = load i32, i32* %call26, align 4, !tbaa !21
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE8pop_backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %free_nodes_)
  %20 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %nodes_31 = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %20, i64 0, i32 0
  %call32 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_31, i32 %19)
  %21 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call32, align 8, !tbaa !2
  %call33 = call i64 @_ZN4absl13base_internal7HidePtrIvEEmPT_(i8* %ptr)
  %masked_ptr34 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %21, i64 0, i32 4
  store i64 %call33, i64* %masked_ptr34, align 8, !tbaa !12
  %nstack35 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %21, i64 0, i32 8
  store i32 0, i32* %nstack35, align 4, !tbaa !27
  %priority36 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %21, i64 0, i32 7
  store i32 0, i32* %priority36, align 8, !tbaa !28
  %22 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %ptrmap_38 = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %22, i64 0, i32 2
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap3AddEPvi(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* nonnull %ptrmap_38, i8* %ptr, i32 %19)
  %version39 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %21, i64 0, i32 1
  %23 = load i32, i32* %version39, align 4, !tbaa !26
  %call40 = call fastcc i64 @_ZN4absl24synchronization_internal12_GLOBAL__N_16MakeIdEij(i32 %19, i32 %23)
  br label %cleanup

cleanup:                                          ; preds = %if.else23, %if.then7, %if.then
  %retval.sroa.0.0 = phi i64 [ %call4, %if.then ], [ %call21, %if.then7 ], [ %call40, %if.else23 ]
  ret i64 %retval.sroa.0.0
}

; Function Attrs: inlinehint norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc i64 @_ZN4absl24synchronization_internal12_GLOBAL__N_16MakeIdEij(i32 %index, i32 %version) unnamed_addr #8 {
entry:
  %conv = zext i32 %version to i64
  %shl = shl nuw i64 %conv, 32
  %conv1 = zext i32 %index to i64
  %or = or i64 %shl, %conv1
  ret i64 %or
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE5emptyEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %this) unnamed_addr #4 align 2 {
entry:
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  %0 = load i32, i32* %size_, align 8, !tbaa !29
  %cmp = icmp eq i32 %0, 0
  ret i1 %cmp
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_14NodeC2Ev(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %this) unnamed_addr #9 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %in = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %this, i64 0, i32 5
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in)
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %this, i64 0, i32 6
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  ret void

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetD2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in) #19
  resume { i8*, i32 } %0
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i64 @_ZN4absl13base_internal7HidePtrIvEEmPT_(i8* %ptr) local_unnamed_addr #9 comdat {
entry:
  %0 = ptrtoint i8* %ptr to i64
  %call = call i64 @_ZN4absl13base_internal8HideMaskEv()
  %xor = xor i64 %call, %0
  ret i64 %xor
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE9push_backERKS4_(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** nocapture readonly dereferenceable(8) %v) unnamed_addr #0 align 2 {
entry:
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 2
  %0 = load i32, i32* %size_, align 8, !tbaa !11
  %capacity_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 3
  %1 = load i32, i32* %capacity_, align 4, !tbaa !30
  %cmp = icmp eq i32 %0, %1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %add = add i32 %0, 1
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE4GrowEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nonnull %this, i32 %add)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %2 = bitcast %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %v to i64*
  %3 = load i64, i64* %2, align 8, !tbaa !2
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 0
  %4 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*** %ptr_, align 8, !tbaa !8
  %5 = load i32, i32* %size_, align 8, !tbaa !11
  %idxprom = zext i32 %5 to i64
  %arrayidx = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %4, i64 %idxprom
  %6 = bitcast %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %arrayidx to i64*
  store i64 %3, i64* %6, align 8, !tbaa !2
  %inc = add i32 %5, 1
  store i32 %inc, i32* %size_, align 8, !tbaa !11
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap3AddEPvi(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i8* %ptr, i32 %i) unnamed_addr #2 align 2 {
entry:
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i64 0, i32 1
  %call = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap4HashEPv(i8* %ptr)
  %conv = zext i32 %call to i64
  %call2 = call dereferenceable(4) i32* @_ZNSt5arrayIiLm8171EEixEm(%"struct.std::array"* nonnull %table_, i64 %conv) #19
  %0 = load i32, i32* %call2, align 4, !tbaa !21
  %nodes_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i64 0, i32 0
  %1 = load %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %nodes_, align 8, !tbaa !22
  %call3 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %1, i32 %i)
  %2 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call3, align 8, !tbaa !2
  %next_hash = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %2, i64 0, i32 2
  store i32 %0, i32* %next_hash, align 8, !tbaa !31
  store i32 %i, i32* %call2, align 4, !tbaa !21
  ret void
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %this) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %0 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  %1 = load i32, i32* %size_, align 8, !tbaa !29
  %sub = add i32 %1, -1
  %idxprom = zext i32 %sub to i64
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %idxprom
  ret i32* %arrayidx
}

; Function Attrs: argmemonly nofree norecurse nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE8pop_backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture %this) unnamed_addr #10 align 2 {
entry:
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  %0 = load i32, i32* %size_, align 8, !tbaa !29
  %dec = add i32 %0, -1
  store i32 %dec, i32* %size_, align 8, !tbaa !29
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define dso_local void @_ZN4absl24synchronization_internal11GraphCycles10RemoveNodeEPv(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i8* %ptr) local_unnamed_addr #0 align 2 {
entry:
  %i = alloca i32, align 4
  %y = alloca i32, align 4
  %_cursor = alloca i32, align 4
  %y8 = alloca i32, align 4
  %_cursor9 = alloca i32, align 4
  %0 = bitcast i32* %i to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %1 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %ptrmap_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %1, i64 0, i32 2
  %call = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap6RemoveEPv(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* nonnull %ptrmap_, i8* %ptr)
  store i32 %call, i32* %i, align 4, !tbaa !21
  %cmp = icmp eq i32 %call, -1
  br i1 %cmp, label %cleanup, label %if.end

if.end:                                           ; preds = %entry
  %2 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %2, i64 0, i32 0
  %call3 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %call)
  %3 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call3, align 8, !tbaa !2
  %4 = bitcast i32* %y to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %4) #19
  %5 = bitcast i32* %_cursor to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %5) #19
  store i32 0, i32* %_cursor, align 4, !tbaa !21
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 6
  %call49 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32* nonnull %_cursor, i32* nonnull %y)
  br i1 %call49, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %if.end
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %5) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %4) #19
  %6 = bitcast i32* %y8 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %6) #19
  %7 = bitcast i32* %_cursor9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %7) #19
  store i32 0, i32* %_cursor9, align 4, !tbaa !21
  %in11 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 5
  %call128 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in11, i32* nonnull %_cursor9, i32* nonnull %y8)
  br i1 %call128, label %for.body14, label %for.cond.cleanup13

for.body:                                         ; preds = %if.end, %for.body
  %8 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %nodes_6 = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %8, i64 0, i32 0
  %9 = load i32, i32* %y, align 4, !tbaa !21
  %call7 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_6, i32 %9)
  %10 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call7, align 8, !tbaa !2
  %in = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %10, i64 0, i32 5
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5eraseEj(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in, i32 %call)
  %call4 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32* nonnull %_cursor, i32* nonnull %y)
  br i1 %call4, label %for.body, label %for.cond.cleanup

for.cond.cleanup13:                               ; preds = %for.body14, %for.cond.cleanup
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %7) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %6) #19
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in11)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out)
  %call22 = call i64 @_ZN4absl13base_internal7HidePtrIvEEmPT_(i8* null)
  %masked_ptr = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 4
  store i64 %call22, i64* %masked_ptr, align 8, !tbaa !12
  %version = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 1
  %11 = load i32, i32* %version, align 4, !tbaa !26
  %call23 = call i32 @_ZNSt14numeric_limitsIjE3maxEv() #19
  %cmp24 = icmp eq i32 %11, %call23
  br i1 %cmp24, label %cleanup, label %if.else

for.body14:                                       ; preds = %for.cond.cleanup, %for.body14
  %12 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %nodes_16 = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %12, i64 0, i32 0
  %13 = load i32, i32* %y8, align 4, !tbaa !21
  %call17 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_16, i32 %13)
  %14 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call17, align 8, !tbaa !2
  %out18 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %14, i64 0, i32 6
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5eraseEj(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out18, i32 %call)
  %call12 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in11, i32* nonnull %_cursor9, i32* nonnull %y8)
  br i1 %call12, label %for.body14, label %for.cond.cleanup13

if.else:                                          ; preds = %for.cond.cleanup13
  %15 = load i32, i32* %version, align 4, !tbaa !26
  %inc = add i32 %15, 1
  store i32 %inc, i32* %version, align 4, !tbaa !26
  %16 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %free_nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %16, i64 0, i32 1
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %free_nodes_, i32* nonnull dereferenceable(4) %i)
  br label %cleanup

cleanup:                                          ; preds = %if.else, %for.cond.cleanup13, %entry
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap6RemoveEPv(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i8* %ptr) unnamed_addr #0 align 2 {
entry:
  %call = call i64 @_ZN4absl13base_internal7HidePtrIvEEmPT_(i8* %ptr)
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i64 0, i32 1
  %call2 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap4HashEPv(i8* %ptr)
  %conv = zext i32 %call2 to i64
  %call3 = call dereferenceable(4) i32* @_ZNSt5arrayIiLm8171EEixEm(%"struct.std::array"* nonnull %table_, i64 %conv) #19
  %nodes_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i64 0, i32 0
  %0 = load i32, i32* %call3, align 4, !tbaa !21
  %cmp22 = icmp eq i32 %0, -1
  br i1 %cmp22, label %.loopexit, label %for.body.preheader

for.body.preheader:                               ; preds = %entry
  %1 = load %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %nodes_, align 8, !tbaa !22
  br label %for.body

for.cond:                                         ; preds = %for.body
  %2 = load i32, i32* %next_hash, align 4, !tbaa !21
  %cmp = icmp eq i32 %2, -1
  br i1 %cmp, label %.loopexit, label %for.body

for.body:                                         ; preds = %for.body.preheader, %for.cond
  %3 = phi i32 [ %2, %for.cond ], [ %0, %for.body.preheader ]
  %slot.023 = phi i32* [ %next_hash, %for.cond ], [ %call3, %for.body.preheader ]
  %call4 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %1, i32 %3)
  %4 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call4, align 8, !tbaa !2
  %masked_ptr = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4, i64 0, i32 4
  %5 = load i64, i64* %masked_ptr, align 8, !tbaa !12
  %cmp5 = icmp eq i64 %5, %call
  %next_hash = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4, i64 0, i32 2
  br i1 %cmp5, label %cleanup9, label %for.cond

cleanup9:                                         ; preds = %for.body
  %6 = load i32, i32* %next_hash, align 8, !tbaa !31
  store i32 %6, i32* %slot.023, align 4, !tbaa !21
  store i32 -1, i32* %next_hash, align 8, !tbaa !31
  br label %.loopexit

.loopexit:                                        ; preds = %for.cond, %entry, %cleanup9
  %7 = phi i32 [ %3, %cleanup9 ], [ %0, %entry ], [ %2, %for.cond ]
  ret i32 %7
}

; Function Attrs: nofree norecurse nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5eraseEj(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nocapture readonly %this, i32 %v) unnamed_addr #7 align 2 {
entry:
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_17NodeSet9FindIndexEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i32 %v)
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  %call2 = call fastcc dereferenceable(4) i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 %call)
  %0 = load i32, i32* %call2, align 4, !tbaa !21
  %cmp = icmp eq i32 %0, %v
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 -2, i32* %call2, align 4, !tbaa !21
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this) unnamed_addr #0 align 2 {
entry:
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this)
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32 @_ZNSt14numeric_limitsIjE3maxEv() local_unnamed_addr #2 comdat align 2 {
entry:
  ret i32 -1
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i32* nocapture readonly dereferenceable(4) %v) unnamed_addr #0 align 2 {
entry:
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  %0 = load i32, i32* %size_, align 8, !tbaa !29
  %capacity_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 3
  %1 = load i32, i32* %capacity_, align 4, !tbaa !33
  %cmp = icmp eq i32 %0, %1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %add = add i32 %0, 1
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4GrowEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %this, i32 %add)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %2 = load i32, i32* %v, align 4, !tbaa !21
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %3 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %4 = load i32, i32* %size_, align 8, !tbaa !29
  %idxprom = zext i32 %4 to i64
  %arrayidx = getelementptr inbounds i32, i32* %3, i64 %idxprom
  store i32 %2, i32* %arrayidx, align 4, !tbaa !21
  %5 = load i32, i32* %size_, align 8, !tbaa !29
  %inc = add i32 %5, 1
  store i32 %inc, i32* %size_, align 8, !tbaa !29
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define dso_local i8* @_ZN4absl24synchronization_internal11GraphCycles3PtrENS0_7GraphIdE(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %id.coerce) local_unnamed_addr #2 align 2 {
entry:
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %id.coerce)
  %cmp = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, null
  br i1 %cmp, label %cond.end, label %cond.false

cond.false:                                       ; preds = %entry
  %masked_ptr = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, i64 0, i32 4
  %1 = load i64, i64* %masked_ptr, align 8, !tbaa !12
  %call3 = call i8* @_ZN4absl13base_internal9UnhidePtrIvEEPT_m(i64 %1)
  br label %cond.end

cond.end:                                         ; preds = %entry, %cond.false
  %cond = phi i8* [ %call3, %cond.false ], [ null, %entry ]
  ret i8* %cond
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* nocapture readonly %rep, i64 %id.coerce) unnamed_addr #11 {
entry:
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %rep, i64 0, i32 0
  %call = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %id.coerce)
  %call2 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %call)
  %0 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call2, align 8, !tbaa !2
  %version = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %0, i64 0, i32 1
  %1 = load i32, i32* %version, align 4, !tbaa !26
  %call5 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_111NodeVersionENS0_7GraphIdE(i64 %id.coerce)
  %cmp = icmp eq i32 %1, %call5
  %cond = select i1 %cmp, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %0, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* null
  ret %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %cond
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define dso_local zeroext i1 @_ZN4absl24synchronization_internal11GraphCycles7HasNodeENS0_7GraphIdE(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %node.coerce) local_unnamed_addr #11 align 2 {
entry:
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %node.coerce)
  %cmp = icmp ne %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, null
  ret i1 %cmp
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define dso_local zeroext i1 @_ZNK4absl24synchronization_internal11GraphCycles7HasEdgeENS0_7GraphIdES2_(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %x.coerce, i64 %y.coerce) local_unnamed_addr #11 align 2 {
entry:
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %x.coerce)
  %tobool = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, null
  br i1 %tobool, label %land.end, label %land.lhs.true

land.lhs.true:                                    ; preds = %entry
  %call7 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %y.coerce)
  %tobool8 = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call7, null
  br i1 %tobool8, label %land.end, label %land.rhs

land.rhs:                                         ; preds = %land.lhs.true
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, i64 0, i32 6
  %call11 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %y.coerce)
  %call12 = call fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_17NodeSet8containsEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32 %call11)
  br label %land.end

land.end:                                         ; preds = %land.lhs.true, %entry, %land.rhs
  %1 = phi i1 [ false, %land.lhs.true ], [ false, %entry ], [ %call12, %land.rhs ]
  ret i1 %1
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_17NodeSet8containsEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nocapture readonly %this, i32 %v) unnamed_addr #11 align 2 {
entry:
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_17NodeSet9FindIndexEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i32 %v)
  %call2 = call fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 %call)
  %0 = load i32, i32* %call2, align 4, !tbaa !21
  %cmp = icmp eq i32 %0, %v
  ret i1 %cmp
}

; Function Attrs: inlinehint norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %id.coerce) unnamed_addr #8 {
entry:
  %conv = trunc i64 %id.coerce to i32
  ret i32 %conv
}

; Function Attrs: nofree norecurse nounwind sanitize_cilk uwtable
define dso_local void @_ZN4absl24synchronization_internal11GraphCycles10RemoveEdgeENS0_7GraphIdES2_(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %x.coerce, i64 %y.coerce) local_unnamed_addr #7 align 2 {
entry:
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %x.coerce)
  %call7 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %y.coerce)
  %tobool = icmp ne %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, null
  %tobool8 = icmp ne %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call7, null
  %or.cond = and i1 %tobool, %tobool8
  br i1 %or.cond, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, i64 0, i32 6
  %call11 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %y.coerce)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5eraseEj(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32 %call11)
  %in = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call7, i64 0, i32 5
  %call14 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %x.coerce)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5eraseEj(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in, i32 %call14)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define dso_local zeroext i1 @_ZN4absl24synchronization_internal11GraphCycles10InsertEdgeENS0_7GraphIdES2_(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %idx.coerce, i64 %idy.coerce) local_unnamed_addr #0 align 2 {
entry:
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %call = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %idx.coerce)
  %call6 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %idy.coerce)
  %call9 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %idx.coerce)
  %call12 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %idy.coerce)
  %cmp = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call9, null
  %cmp13 = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call12, null
  %or.cond = or i1 %cmp, %cmp13
  br i1 %or.cond, label %cleanup, label %if.end

if.end:                                           ; preds = %entry
  %cmp14 = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call9, %call12
  br i1 %cmp14, label %cleanup, label %if.end16

if.end16:                                         ; preds = %if.end
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call9, i64 0, i32 6
  %call17 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet6insertEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32 %call6)
  br i1 %call17, label %if.end19, label %cleanup

if.end19:                                         ; preds = %if.end16
  %in = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call12, i64 0, i32 5
  %call20 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet6insertEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in, i32 %call)
  %rank = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call9, i64 0, i32 0
  %1 = load i32, i32* %rank, align 8, !tbaa !20
  %rank21 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call12, i64 0, i32 0
  %2 = load i32, i32* %rank21, align 8, !tbaa !20
  %cmp22 = icmp sgt i32 %1, %2
  br i1 %cmp22, label %if.end24, label %cleanup

if.end24:                                         ; preds = %if.end19
  %call26 = call fastcc zeroext i1 @_ZN4absl24synchronization_internalL10ForwardDFSEPNS0_11GraphCycles3RepEii(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i32 %call6, i32 %1)
  br i1 %call26, label %if.end34, label %if.then27

if.then27:                                        ; preds = %if.end24
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5eraseEj(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32 %call6)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet5eraseEj(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in, i32 %call)
  %deltaf_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 0, i32 3
  %call30 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_)
  %call31 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_)
  %cmp3235 = icmp eq i32* %call30, %call31
  br i1 %cmp3235, label %cleanup, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %if.then27
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 0, i32 0
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %__begin3.036 = phi i32* [ %call30, %for.body.lr.ph ], [ %incdec.ptr, %for.body ]
  %3 = load i32, i32* %__begin3.036, align 4, !tbaa !21
  %call33 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %3)
  %4 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call33, align 8, !tbaa !2
  %visited = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4, i64 0, i32 3
  store i8 0, i8* %visited, align 4, !tbaa !18
  %incdec.ptr = getelementptr inbounds i32, i32* %__begin3.036, i64 1
  %cmp32 = icmp eq i32* %incdec.ptr, %call31
  br i1 %cmp32, label %cleanup, label %for.body

if.end34:                                         ; preds = %if.end24
  %5 = load i32, i32* %rank21, align 8, !tbaa !20
  call fastcc void @_ZN4absl24synchronization_internalL11BackwardDFSEPNS0_11GraphCycles3RepEii(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i32 %call, i32 %5)
  call fastcc void @_ZN4absl24synchronization_internalL7ReorderEPNS0_11GraphCycles3RepE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0)
  br label %cleanup

cleanup:                                          ; preds = %for.body, %if.then27, %if.end19, %if.end16, %if.end, %entry, %if.end34
  %retval.0 = phi i1 [ true, %if.end34 ], [ true, %entry ], [ false, %if.end ], [ true, %if.end16 ], [ true, %if.end19 ], [ false, %if.then27 ], [ false, %for.body ]
  ret i1 %retval.0
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZN4absl24synchronization_internalL10ForwardDFSEPNS0_11GraphCycles3RepEii(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i32 %n, i32 %upper_bound) unnamed_addr #0 {
entry:
  %n.addr = alloca i32, align 4
  %w = alloca i32, align 4
  %_cursor = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4, !tbaa !21
  %deltaf_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 3
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_)
  %stack_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 7
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_, i32* nonnull dereferenceable(4) %n.addr)
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 0
  %0 = bitcast i32* %w to i8*
  %1 = bitcast i32* %_cursor to i8*
  %call28 = call fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE5emptyEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  br i1 %call28, label %return, label %while.body

while.body:                                       ; preds = %entry, %cleanup24
  %call4 = call fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  %2 = load i32, i32* %call4, align 4, !tbaa !21
  store i32 %2, i32* %n.addr, align 4, !tbaa !21
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE8pop_backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  %call6 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %2)
  %3 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call6, align 8, !tbaa !2
  %visited = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 3
  %4 = load i8, i8* %visited, align 4, !tbaa !18, !range !19
  %tobool = icmp eq i8 %4, 0
  br i1 %tobool, label %if.end, label %cleanup24

if.end:                                           ; preds = %while.body
  store i8 1, i8* %visited, align 4, !tbaa !18
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_, i32* nonnull dereferenceable(4) %n.addr)
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %1) #19
  store i32 0, i32* %_cursor, align 4, !tbaa !21
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 6
  %call927 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32* nonnull %_cursor, i32* nonnull %w)
  br i1 %call927, label %for.body, label %for.cond._crit_edge

for.body:                                         ; preds = %if.end, %cleanup
  %5 = load i32, i32* %w, align 4, !tbaa !21
  %call11 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %5)
  %6 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call11, align 8, !tbaa !2
  %rank = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %6, i64 0, i32 0
  %7 = load i32, i32* %rank, align 8, !tbaa !20
  %cmp = icmp eq i32 %7, %upper_bound
  br i1 %cmp, label %cleanup24.thread, label %if.end13

if.end13:                                         ; preds = %for.body
  %visited14 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %6, i64 0, i32 3
  %8 = load i8, i8* %visited14, align 4, !tbaa !18, !range !19
  %tobool15 = icmp eq i8 %8, 0
  %cmp17 = icmp slt i32 %7, %upper_bound
  %or.cond = and i1 %cmp17, %tobool15
  br i1 %or.cond, label %if.then18, label %cleanup

if.then18:                                        ; preds = %if.end13
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_, i32* nonnull dereferenceable(4) %w)
  br label %cleanup

cleanup:                                          ; preds = %if.then18, %if.end13
  %call9 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32* nonnull %_cursor, i32* nonnull %w)
  br i1 %call9, label %for.body, label %for.cond._crit_edge

cleanup24.thread:                                 ; preds = %for.body
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %1) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  br label %return

for.cond._crit_edge:                              ; preds = %cleanup, %if.end
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %1) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  br label %cleanup24

cleanup24:                                        ; preds = %for.cond._crit_edge, %while.body
  %call = call fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE5emptyEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  br i1 %call, label %return, label %while.body

return:                                           ; preds = %cleanup24, %entry, %cleanup24.thread
  %retval.5 = phi i1 [ false, %cleanup24.thread ], [ true, %entry ], [ true, %cleanup24 ]
  ret i1 %retval.5
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %this) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %0 = load i32*, i32** %ptr_, align 8, !tbaa !32
  ret i32* %0
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %this) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %0 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  %1 = load i32, i32* %size_, align 8, !tbaa !29
  %idx.ext = zext i32 %1 to i64
  %add.ptr = getelementptr inbounds i32, i32* %0, i64 %idx.ext
  ret i32* %add.ptr
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internalL11BackwardDFSEPNS0_11GraphCycles3RepEii(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i32 %n, i32 %lower_bound) unnamed_addr #0 {
entry:
  %n.addr = alloca i32, align 4
  %w = alloca i32, align 4
  %_cursor = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4, !tbaa !21
  %deltab_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 4
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_)
  %stack_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 7
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_, i32* nonnull dereferenceable(4) %n.addr)
  %call17 = call fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE5emptyEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  br i1 %call17, label %while.end, label %while.body.lr.ph

while.body.lr.ph:                                 ; preds = %entry
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 0
  %0 = bitcast i32* %w to i8*
  %1 = bitcast i32* %_cursor to i8*
  br label %while.body

while.body:                                       ; preds = %while.body.lr.ph, %cleanup
  %call4 = call fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  %2 = load i32, i32* %call4, align 4, !tbaa !21
  store i32 %2, i32* %n.addr, align 4, !tbaa !21
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE8pop_backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  %call6 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %2)
  %3 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call6, align 8, !tbaa !2
  %visited = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 3
  %4 = load i8, i8* %visited, align 4, !tbaa !18, !range !19
  %tobool = icmp eq i8 %4, 0
  br i1 %tobool, label %if.end, label %cleanup

if.end:                                           ; preds = %while.body
  store i8 1, i8* %visited, align 4, !tbaa !18
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_, i32* nonnull dereferenceable(4) %n.addr)
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %1) #19
  store i32 0, i32* %_cursor, align 4, !tbaa !21
  %in = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 5
  %call916 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in, i32* nonnull %_cursor, i32* nonnull %w)
  br i1 %call916, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %if.end16, %if.end
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %1) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  br label %cleanup

for.body:                                         ; preds = %if.end, %if.end16
  %5 = load i32, i32* %w, align 4, !tbaa !21
  %call11 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %5)
  %6 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call11, align 8, !tbaa !2
  %visited12 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %6, i64 0, i32 3
  %7 = load i8, i8* %visited12, align 4, !tbaa !18, !range !19
  %tobool13 = icmp eq i8 %7, 0
  br i1 %tobool13, label %land.lhs.true, label %if.end16

land.lhs.true:                                    ; preds = %for.body
  %rank = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %6, i64 0, i32 0
  %8 = load i32, i32* %rank, align 8, !tbaa !20
  %cmp = icmp sgt i32 %8, %lower_bound
  br i1 %cmp, label %if.then14, label %if.end16

if.then14:                                        ; preds = %land.lhs.true
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_, i32* nonnull dereferenceable(4) %w)
  br label %if.end16

if.end16:                                         ; preds = %for.body, %if.then14, %land.lhs.true
  %call9 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %in, i32* nonnull %_cursor, i32* nonnull %w)
  br i1 %call9, label %for.body, label %for.cond.cleanup

cleanup:                                          ; preds = %while.body, %for.cond.cleanup
  %call = call fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE5emptyEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  br i1 %call, label %while.end, label %while.body

while.end:                                        ; preds = %cleanup, %entry
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internalL7ReorderEPNS0_11GraphCycles3RepE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %r) unnamed_addr #0 {
entry:
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 0
  %deltab_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 4
  call fastcc void @_ZN4absl24synchronization_internalL4SortERKNS0_12_GLOBAL__N_13VecIPNS1_4NodeEEEPNS2_IiEE(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* dereferenceable(80) %nodes_, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_)
  %deltaf_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 3
  call fastcc void @_ZN4absl24synchronization_internalL4SortERKNS0_12_GLOBAL__N_13VecIPNS1_4NodeEEEPNS2_IiEE(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nonnull dereferenceable(80) %nodes_, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_)
  %list_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 5
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %list_)
  call fastcc void @_ZN4absl24synchronization_internalL10MoveToListEPNS0_11GraphCycles3RepEPNS0_12_GLOBAL__N_13VecIiEES7_(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %list_)
  call fastcc void @_ZN4absl24synchronization_internalL10MoveToListEPNS0_11GraphCycles3RepEPNS0_12_GLOBAL__N_13VecIiEES7_(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %list_)
  %merged_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 6
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_)
  %call8 = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_)
  %add = add i32 %call8, %call
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE6resizeEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %merged_, i32 %add)
  %call10 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_)
  %call12 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltab_)
  %call14 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_)
  %call16 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %deltaf_)
  %call18 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %merged_)
  %call19 = call i32* @_ZSt5mergeIPiS0_S0_ET1_T_S2_T0_S3_S1_(i32* %call10, i32* %call12, i32* %call14, i32* %call16, i32* %call18)
  %call2127 = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %list_)
  %cmp28 = icmp eq i32 %call2127, 0
  br i1 %cmp28, label %for.cond.cleanup, label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %entry
  ret void

for.body:                                         ; preds = %entry, %for.body
  %i.029 = phi i32 [ %inc, %for.body ], [ 0, %entry ]
  %call23 = call fastcc dereferenceable(4) i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %merged_, i32 %i.029)
  %0 = load i32, i32* %call23, align 4, !tbaa !21
  %call26 = call fastcc dereferenceable(4) i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %list_, i32 %i.029)
  %1 = load i32, i32* %call26, align 4, !tbaa !21
  %call27 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nonnull %nodes_, i32 %1)
  %2 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call27, align 8, !tbaa !2
  %rank = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %2, i64 0, i32 0
  store i32 %0, i32* %rank, align 8, !tbaa !20
  %inc = add nuw i32 %i.029, 1
  %call21 = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %list_)
  %cmp = icmp ult i32 %inc, %call21
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

; Function Attrs: sanitize_cilk uwtable
define dso_local i32 @_ZNK4absl24synchronization_internal11GraphCycles8FindPathENS0_7GraphIdES2_iPS2_(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %idx.coerce, i64 %idy.coerce, i32 %max_path_len, %"struct.absl::synchronization_internal::GraphId"* nocapture %path) local_unnamed_addr #0 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %x = alloca i32, align 4
  %seen = alloca %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", align 8
  %ref.tmp39 = alloca i32, align 4
  %w = alloca i32, align 4
  %_cursor = alloca i32, align 4
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %idx.coerce)
  %cmp = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, null
  br i1 %cmp, label %cleanup67, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %entry
  %call6 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %idy.coerce)
  %cmp7 = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call6, null
  br i1 %cmp7, label %cleanup67, label %if.end

if.end:                                           ; preds = %lor.lhs.false
  %1 = bitcast i32* %x to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %1) #19
  %call10 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %idx.coerce)
  store i32 %call10, i32* %x, align 4, !tbaa !21
  %call13 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_19NodeIndexENS0_7GraphIdE(i64 %idy.coerce)
  %2 = bitcast %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %seen to i8*
  call void @llvm.lifetime.start.p0i8(i64 56, i8* nonnull %2) #19
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %seen)
  %stack_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 0, i32 7
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %if.end
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_, i32* nonnull dereferenceable(4) %x)
          to label %while.cond.preheader unwind label %lpad

while.cond.preheader:                             ; preds = %invoke.cont
  %call1834 = call fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE5emptyEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  br i1 %call1834, label %cleanup57, label %while.body.lr.ph

while.body.lr.ph:                                 ; preds = %while.cond.preheader
  %3 = bitcast i32* %ref.tmp39 to i8*
  %4 = bitcast i32* %w to i8*
  %5 = bitcast i32* %_cursor to i8*
  %nodes_45 = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 0, i32 0
  br label %while.body

while.body:                                       ; preds = %while.body.lr.ph, %while.cond.backedge
  %path_len.035 = phi i32 [ 0, %while.body.lr.ph ], [ %path_len.1.ph, %while.cond.backedge ]
  %call22 = call fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  %6 = load i32, i32* %call22, align 4, !tbaa !21
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE8pop_backEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  %cmp25 = icmp slt i32 %6, 0
  br i1 %cmp25, label %if.then26, label %if.end27

if.then26:                                        ; preds = %while.body
  %dec = add nsw i32 %path_len.035, -1
  br label %while.cond.backedge

lpad:                                             ; preds = %invoke.cont, %if.end
  %7 = landingpad { i8*, i32 }
          cleanup
  %8 = extractvalue { i8*, i32 } %7, 0
  %9 = extractvalue { i8*, i32 } %7, 1
  br label %ehcleanup58

if.end27:                                         ; preds = %while.body
  %cmp28 = icmp slt i32 %path_len.035, %max_path_len
  br i1 %cmp28, label %if.then29, label %if.end37

if.then29:                                        ; preds = %if.end27
  %10 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %10, i64 0, i32 0
  %call33 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %6)
  %11 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call33, align 8, !tbaa !2
  %version = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %11, i64 0, i32 1
  %12 = load i32, i32* %version, align 4, !tbaa !26
  %call35 = call fastcc i64 @_ZN4absl24synchronization_internal12_GLOBAL__N_16MakeIdEij(i32 %6, i32 %12)
  %idxprom = sext i32 %path_len.035 to i64
  %ref.tmp.sroa.0.0..sroa_idx = getelementptr inbounds %"struct.absl::synchronization_internal::GraphId", %"struct.absl::synchronization_internal::GraphId"* %path, i64 %idxprom, i32 0
  store i64 %call35, i64* %ref.tmp.sroa.0.0..sroa_idx, align 8, !tbaa.struct !34
  br label %if.end37

if.end37:                                         ; preds = %if.then29, %if.end27
  %inc = add nsw i32 %path_len.035, 1
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #19
  store i32 -1, i32* %ref.tmp39, align 4, !tbaa !21
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_, i32* nonnull dereferenceable(4) %ref.tmp39)
          to label %invoke.cont41 unwind label %lpad40

invoke.cont41:                                    ; preds = %if.end37
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #19
  %cmp42 = icmp eq i32 %6, %call13
  br i1 %cmp42, label %cleanup57, label %if.end44

lpad40:                                           ; preds = %if.end37
  %13 = landingpad { i8*, i32 }
          cleanup
  %14 = extractvalue { i8*, i32 } %13, 0
  %15 = extractvalue { i8*, i32 } %13, 1
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #19
  br label %ehcleanup58

if.end44:                                         ; preds = %invoke.cont41
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %4) #19
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %5) #19
  store i32 0, i32* %_cursor, align 4, !tbaa !21
  %call4831 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_45, i32 %6)
  %16 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call4831, align 8, !tbaa !2
  %out32 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %16, i64 0, i32 6
  %call5033 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out32, i32* nonnull %_cursor, i32* nonnull %w)
  br i1 %call5033, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %if.end56, %if.end44
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %5) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %4) #19
  br label %while.cond.backedge

lpad46:                                           ; preds = %if.then53, %for.body
  %17 = landingpad { i8*, i32 }
          cleanup
  %18 = extractvalue { i8*, i32 } %17, 0
  %19 = extractvalue { i8*, i32 } %17, 1
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %5) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %4) #19
  br label %ehcleanup58

for.body:                                         ; preds = %if.end44, %if.end56
  %20 = load i32, i32* %w, align 4, !tbaa !21
  %call52 = invoke fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet6insertEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %seen, i32 %20)
          to label %invoke.cont51 unwind label %lpad46

invoke.cont51:                                    ; preds = %for.body
  br i1 %call52, label %if.then53, label %if.end56

if.then53:                                        ; preds = %invoke.cont51
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_, i32* nonnull dereferenceable(4) %w)
          to label %if.end56 unwind label %lpad46

if.end56:                                         ; preds = %if.then53, %invoke.cont51
  %call48 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_45, i32 %6)
  %21 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call48, align 8, !tbaa !2
  %out = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %21, i64 0, i32 6
  %call50 = call fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4NextEPiS3_(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %out, i32* nonnull %_cursor, i32* nonnull %w)
  br i1 %call50, label %for.body, label %for.cond.cleanup

while.cond.backedge:                              ; preds = %if.then26, %for.cond.cleanup
  %path_len.1.ph = phi i32 [ %inc, %for.cond.cleanup ], [ %dec, %if.then26 ]
  %call18 = call fastcc zeroext i1 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE5emptyEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %stack_)
  br i1 %call18, label %cleanup57, label %while.body

cleanup57:                                        ; preds = %while.cond.backedge, %invoke.cont41, %while.cond.preheader
  %retval.2 = phi i32 [ 0, %while.cond.preheader ], [ 0, %while.cond.backedge ], [ %inc, %invoke.cont41 ]
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetD2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %seen) #19
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %2) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %1) #19
  br label %cleanup67

ehcleanup58:                                      ; preds = %lpad40, %lpad46, %lpad
  %exn.slot.1 = phi i8* [ %8, %lpad ], [ %18, %lpad46 ], [ %14, %lpad40 ]
  %ehselector.slot.1 = phi i32 [ %9, %lpad ], [ %19, %lpad46 ], [ %15, %lpad40 ]
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSetD2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nonnull %seen) #19
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %2) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %1) #19
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.1, 0
  %lpad.val69 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.1, 1
  resume { i8*, i32 } %lpad.val69

cleanup67:                                        ; preds = %entry, %lor.lhs.false, %cleanup57
  %retval.3 = phi i32 [ %retval.2, %cleanup57 ], [ 0, %lor.lhs.false ], [ 0, %entry ]
  ret i32 %retval.3
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this) unnamed_addr #0 align 2 {
entry:
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE7DiscardEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this)
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define dso_local zeroext i1 @_ZNK4absl24synchronization_internal11GraphCycles11IsReachableENS0_7GraphIdES2_(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %x.coerce, i64 %y.coerce) local_unnamed_addr #0 align 2 {
entry:
  %call = call i32 @_ZNK4absl24synchronization_internal11GraphCycles8FindPathENS0_7GraphIdES2_iPS2_(%"class.absl::synchronization_internal::GraphCycles"* %this, i64 %x.coerce, i64 %y.coerce, i32 0, %"struct.absl::synchronization_internal::GraphId"* null)
  %cmp = icmp sgt i32 %call, 0
  ret i1 %cmp
}

; Function Attrs: sanitize_cilk uwtable
define dso_local void @_ZN4absl24synchronization_internal11GraphCycles16UpdateStackTraceENS0_7GraphIdEiPFiPPviE(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %id.coerce, i32 %priority, i32 (i8**, i32)* nocapture %get_stack_trace) local_unnamed_addr #0 align 2 {
entry:
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %id.coerce)
  %cmp = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, null
  br i1 %cmp, label %cleanup, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %entry
  %priority3 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, i64 0, i32 7
  %1 = load i32, i32* %priority3, align 8, !tbaa !28
  %cmp4 = icmp slt i32 %1, %priority
  br i1 %cmp4, label %if.end, label %cleanup

if.end:                                           ; preds = %lor.lhs.false
  %arraydecay = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, i64 0, i32 9, i64 0
  %call5 = call i32 %get_stack_trace(i8** nonnull %arraydecay, i32 40)
  %nstack = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, i64 0, i32 8
  store i32 %call5, i32* %nstack, align 4, !tbaa !27
  store i32 %priority, i32* %priority3, align 8, !tbaa !28
  br label %cleanup

cleanup:                                          ; preds = %entry, %lor.lhs.false, %if.end
  ret void
}

; Function Attrs: nofree norecurse nounwind sanitize_cilk uwtable
define dso_local i32 @_ZN4absl24synchronization_internal11GraphCycles13GetStackTraceENS0_7GraphIdEPPPv(%"class.absl::synchronization_internal::GraphCycles"* nocapture readonly %this, i64 %id.coerce, i8*** nocapture %ptr) local_unnamed_addr #7 align 2 {
entry:
  %rep_ = getelementptr inbounds %"class.absl::synchronization_internal::GraphCycles", %"class.absl::synchronization_internal::GraphCycles"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::GraphCycles::Rep"*, %"struct.absl::synchronization_internal::GraphCycles::Rep"** %rep_, align 8, !tbaa !6
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* @_ZN4absl24synchronization_internalL8FindNodeEPNS0_11GraphCycles3RepENS0_7GraphIdE(%"struct.absl::synchronization_internal::GraphCycles::Rep"* %0, i64 %id.coerce)
  %cmp = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, null
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  store i8** null, i8*** %ptr, align 8, !tbaa !2
  br label %cleanup

if.else:                                          ; preds = %entry
  %arraydecay = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, i64 0, i32 9, i64 0
  store i8** %arraydecay, i8*** %ptr, align 8, !tbaa !2
  %nstack = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %call, i64 0, i32 8
  %1 = load i32, i32* %nstack, align 4, !tbaa !27
  br label %cleanup

cleanup:                                          ; preds = %if.else, %if.then
  %retval.0 = phi i32 [ 0, %if.then ], [ %1, %if.else ]
  ret i32 %retval.0
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN4absl13base_internal8SpinLock4LockEv(%"class.absl::base_internal::SpinLock"* %this) local_unnamed_addr #9 comdat align 2 {
entry:
  %call = call zeroext i1 @_ZN4absl13base_internal8SpinLock11TryLockImplEv(%"class.absl::base_internal::SpinLock"* %this)
  br i1 %call, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  call void @_ZN4absl13base_internal8SpinLock8SlowLockEv(%"class.absl::base_internal::SpinLock"* %this) #21
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

declare dso_local %"struct.absl::base_internal::LowLevelAlloc::Arena"* @_ZN4absl13base_internal13LowLevelAlloc8NewArenaEi(i32) local_unnamed_addr #1

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN4absl13base_internal8SpinLock6UnlockEv(%"class.absl::base_internal::SpinLock"* %this) local_unnamed_addr #9 comdat align 2 personality i32 (...)* @__gxx_personality_v0 {
entry:
  %call.i = call i32 @_ZStanSt12memory_orderSt23__memory_order_modifier(i32 0, i32 65535) #19
  %_M_i.i = getelementptr inbounds %"class.absl::base_internal::SpinLock", %"class.absl::base_internal::SpinLock"* %this, i64 0, i32 0, i32 0, i32 0
  %0 = load atomic i32, i32* %_M_i.i monotonic, align 4
  %and = and i32 %0, 2
  %1 = atomicrmw xchg i32* %_M_i.i, i32 %and release
  %and4 = and i32 %1, 4
  %cmp = icmp eq i32 %and4, 0
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  call void @_ZN4absl13base_internal15SchedulingGuard18EnableReschedulingEb(i1 zeroext true)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %cmp6 = icmp ugt i32 %1, 7
  br i1 %cmp6, label %if.then7, label %if.end8

if.then7:                                         ; preds = %if.end
  call void @_ZN4absl13base_internal8SpinLock10SlowUnlockEj(%"class.absl::base_internal::SpinLock"* nonnull %this, i32 %1) #21
  br label %if.end8

if.end8:                                          ; preds = %if.then7, %if.end
  ret void
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local zeroext i1 @_ZN4absl13base_internal8SpinLock11TryLockImplEv(%"class.absl::base_internal::SpinLock"* %this) local_unnamed_addr #9 comdat align 2 personality i32 (...)* @__gxx_personality_v0 {
entry:
  %call.i = call i32 @_ZStanSt12memory_orderSt23__memory_order_modifier(i32 0, i32 65535) #19
  %_M_i.i = getelementptr inbounds %"class.absl::base_internal::SpinLock", %"class.absl::base_internal::SpinLock"* %this, i64 0, i32 0, i32 0, i32 0
  %0 = load atomic i32, i32* %_M_i.i monotonic, align 4
  %call2 = call i32 @_ZN4absl13base_internal8SpinLock15TryLockInternalEjj(%"class.absl::base_internal::SpinLock"* %this, i32 %0, i32 0)
  %and = and i32 %call2, 1
  %cmp = icmp eq i32 %and, 0
  ret i1 %cmp
}

; Function Attrs: cold
declare dso_local void @_ZN4absl13base_internal8SpinLock8SlowLockEv(%"class.absl::base_internal::SpinLock"*) local_unnamed_addr #12

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32 @_ZN4absl13base_internal8SpinLock15TryLockInternalEjj(%"class.absl::base_internal::SpinLock"* %this, i32 %lock_value, i32 %wait_cycles) local_unnamed_addr #9 comdat align 2 personality i32 (...)* @__gxx_personality_v0 {
entry:
  %and = and i32 %lock_value, 1
  %cmp = icmp eq i32 %and, 0
  br i1 %cmp, label %if.end, label %return

if.end:                                           ; preds = %entry
  %and2 = and i32 %lock_value, 2
  %cmp3 = icmp eq i32 %and2, 0
  br i1 %cmp3, label %if.then4, label %if.end7

if.then4:                                         ; preds = %if.end
  %call = call zeroext i1 @_ZN4absl13base_internal15SchedulingGuard19DisableReschedulingEv()
  %spec.select = select i1 %call, i32 4, i32 0
  br label %if.end7

if.end7:                                          ; preds = %if.then4, %if.end
  %sched_disabled_bit.0 = phi i32 [ 0, %if.end ], [ %spec.select, %if.then4 ]
  %or = or i32 %lock_value, %wait_cycles
  %or8 = or i32 %or, %sched_disabled_bit.0
  %or9 = or i32 %or8, 1
  %call.i = call i32 @_ZStanSt12memory_orderSt23__memory_order_modifier(i32 0, i32 65535) #19
  %call4.i = call i32 @_ZStanSt12memory_orderSt23__memory_order_modifier(i32 2, i32 65535) #19
  %_M_i.i = getelementptr inbounds %"class.absl::base_internal::SpinLock", %"class.absl::base_internal::SpinLock"* %this, i64 0, i32 0, i32 0, i32 0
  %0 = cmpxchg i32* %_M_i.i, i32 %lock_value, i32 %or9 acquire monotonic
  %1 = extractvalue { i32, i1 } %0, 1
  %2 = extractvalue { i32, i1 } %0, 0
  br i1 %1, label %return, label %if.then11

if.then11:                                        ; preds = %if.end7
  %cmp12 = icmp ne i32 %sched_disabled_bit.0, 0
  call void @_ZN4absl13base_internal15SchedulingGuard18EnableReschedulingEb(i1 zeroext %cmp12)
  br label %return

return:                                           ; preds = %if.end7, %if.then11, %entry
  %retval.0 = phi i32 [ %lock_value, %entry ], [ %2, %if.then11 ], [ %2, %if.end7 ]
  ret i32 %retval.0
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32 @_ZStanSt12memory_orderSt23__memory_order_modifier(i32 %__m, i32 %__mod) local_unnamed_addr #2 comdat {
entry:
  %and = and i32 %__mod, %__m
  ret i32 %and
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local zeroext i1 @_ZN4absl13base_internal15SchedulingGuard19DisableReschedulingEv() local_unnamed_addr #5 comdat align 2 {
entry:
  ret i1 false
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN4absl13base_internal15SchedulingGuard18EnableReschedulingEb(i1 zeroext %0) local_unnamed_addr #5 comdat align 2 {
entry:
  ret void
}

; Function Attrs: cold
declare dso_local void @_ZN4absl13base_internal8SpinLock10SlowUnlockEj(%"class.absl::base_internal::SpinLock"*, i32) local_unnamed_addr #12

; Function Attrs: argmemonly nofree norecurse nounwind sanitize_cilk uwtable writeonly
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this) unnamed_addr #13 align 2 {
entry:
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this)
  ret void
}

; Function Attrs: argmemonly nofree norecurse nounwind sanitize_cilk uwtable writeonly
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this) unnamed_addr #13 align 2 {
entry:
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this)
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMapC2EPKNS1_3VecIPNS1_4NodeEEE(%"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes) unnamed_addr #0 align 2 {
entry:
  %ref.tmp = alloca i32, align 4
  %nodes_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i64 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %nodes_, align 8, !tbaa !22
  %table_2 = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap", %"class.absl::synchronization_internal::(anonymous namespace)::PointerMap"* %this, i64 0, i32 1
  %0 = bitcast i32* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  store i32 -1, i32* %ref.tmp, align 4, !tbaa !21
  call void @_ZNSt5arrayIiLm8171EE4fillERKi(%"struct.std::array"* nonnull %table_2, i32* nonnull dereferenceable(4) %ref.tmp)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* readonly %this) unnamed_addr #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE7DiscardEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %entry
  ret void

terminate.lpad:                                   ; preds = %entry
  %0 = landingpad { i8*, i32 }
          catch i8* null
  %1 = extractvalue { i8*, i32 } %0, 0
  call void @__clang_call_terminate(i8* %1) #20
  unreachable
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* readonly %this) unnamed_addr #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE7DiscardEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %entry
  ret void

terminate.lpad:                                   ; preds = %entry
  %0 = landingpad { i8*, i32 }
          catch i8* null
  %1 = extractvalue { i8*, i32 } %0, 0
  call void @__clang_call_terminate(i8* %1) #20
  unreachable
}

; Function Attrs: argmemonly nofree norecurse nounwind sanitize_cilk uwtable writeonly
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this) unnamed_addr #13 align 2 {
entry:
  %arraydecay = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 1, i64 0
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 0
  store %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %arraydecay, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*** %ptr_, align 8, !tbaa !8
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 2
  store i32 0, i32* %size_, align 8, !tbaa !11
  %capacity_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 3
  store i32 8, i32* %capacity_, align 4, !tbaa !30
  ret void
}

; Function Attrs: argmemonly nofree norecurse nounwind sanitize_cilk uwtable writeonly
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this) unnamed_addr #13 align 2 {
entry:
  %arraydecay = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 1, i64 0
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  store i32* %arraydecay, i32** %ptr_, align 8, !tbaa !32
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  store i32 0, i32* %size_, align 8, !tbaa !29
  %capacity_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 3
  store i32 8, i32* %capacity_, align 4, !tbaa !33
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZNSt5arrayIiLm8171EE4fillERKi(%"struct.std::array"* %this, i32* dereferenceable(4) %__u) local_unnamed_addr #0 comdat align 2 {
entry:
  %call = call i32* @_ZNSt5arrayIiLm8171EE5beginEv(%"struct.std::array"* %this) #19
  %call2 = call i64 @_ZNKSt5arrayIiLm8171EE4sizeEv(%"struct.std::array"* %this) #19
  %call3 = call i32* @_ZSt6fill_nIPimiET_S1_T0_RKT1_(i32* %call, i64 %call2, i32* nonnull dereferenceable(4) %__u)
  ret void
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt6fill_nIPimiET_S1_T0_RKT1_(i32* %__first, i64 %__n, i32* dereferenceable(4) %__value) local_unnamed_addr #9 comdat {
entry:
  %__first.addr = alloca i32*, align 8
  store i32* %__first, i32** %__first.addr, align 8, !tbaa !2
  %call = call i64 @_ZSt17__size_to_integerm(i64 %__n)
  call void @_ZSt19__iterator_categoryIPiENSt15iterator_traitsIT_E17iterator_categoryERKS2_(i32** nonnull dereferenceable(8) %__first.addr)
  %call1 = call i32* @_ZSt10__fill_n_aIPimiET_S1_T0_RKT1_St26random_access_iterator_tag(i32* %__first, i64 %call, i32* nonnull dereferenceable(4) %__value)
  ret i32* %call1
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZNSt5arrayIiLm8171EE5beginEv(%"struct.std::array"* %this) local_unnamed_addr #2 comdat align 2 {
entry:
  %call = call i32* @_ZNSt5arrayIiLm8171EE4dataEv(%"struct.std::array"* %this) #19
  ret i32* %call
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i64 @_ZNKSt5arrayIiLm8171EE4sizeEv(%"struct.std::array"* %this) local_unnamed_addr #2 comdat align 2 {
entry:
  ret i64 8171
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt10__fill_n_aIPimiET_S1_T0_RKT1_St26random_access_iterator_tag(i32* %__first, i64 %__n, i32* dereferenceable(4) %__value) local_unnamed_addr #9 comdat {
entry:
  %cmp = icmp eq i64 %__n, 0
  br i1 %cmp, label %return, label %if.end

if.end:                                           ; preds = %entry
  %add.ptr = getelementptr inbounds i32, i32* %__first, i64 %__n
  call void @_ZSt8__fill_aIPiiEvT_S1_RKT0_(i32* %__first, i32* nonnull %add.ptr, i32* nonnull dereferenceable(4) %__value)
  br label %return

return:                                           ; preds = %entry, %if.end
  %retval.0 = phi i32* [ %add.ptr, %if.end ], [ %__first, %entry ]
  ret i32* %retval.0
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i64 @_ZSt17__size_to_integerm(i64 %__n) local_unnamed_addr #5 comdat {
entry:
  ret i64 %__n
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZSt19__iterator_categoryIPiENSt15iterator_traitsIT_E17iterator_categoryERKS2_(i32** dereferenceable(8) %0) local_unnamed_addr #5 comdat {
entry:
  ret void
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZSt8__fill_aIPiiEvT_S1_RKT0_(i32* %__first, i32* %__last, i32* dereferenceable(4) %__value) local_unnamed_addr #9 comdat {
entry:
  call void @_ZSt9__fill_a1IPiiEN9__gnu_cxx11__enable_ifIXsr11__is_scalarIT0_EE7__valueEvE6__typeET_S6_RKS3_(i32* %__first, i32* %__last, i32* nonnull dereferenceable(4) %__value)
  ret void
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZSt9__fill_a1IPiiEN9__gnu_cxx11__enable_ifIXsr11__is_scalarIT0_EE7__valueEvE6__typeET_S6_RKS3_(i32* %__first, i32* %__last, i32* dereferenceable(4) %__value) local_unnamed_addr #5 comdat {
entry:
  %0 = load i32, i32* %__value, align 4, !tbaa !21
  %cmp4 = icmp eq i32* %__first, %__last
  br i1 %cmp4, label %for.end, label %for.body.preheader

for.body.preheader:                               ; preds = %entry
  %__first7 = ptrtoint i32* %__first to i64
  %scevgep = getelementptr i32, i32* %__last, i64 -1
  %1 = ptrtoint i32* %scevgep to i64
  %2 = sub i64 %1, %__first7
  %3 = lshr i64 %2, 2
  %4 = add nuw nsw i64 %3, 1
  %xtraiter = and i64 %4, 7
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %for.body.prol.loopexit, label %for.body.prol

for.body.prol:                                    ; preds = %for.body.preheader, %for.body.prol
  %__first.addr.05.prol = phi i32* [ %incdec.ptr.prol, %for.body.prol ], [ %__first, %for.body.preheader ]
  %prol.iter = phi i64 [ %prol.iter.sub, %for.body.prol ], [ %xtraiter, %for.body.preheader ]
  store i32 %0, i32* %__first.addr.05.prol, align 4, !tbaa !21
  %incdec.ptr.prol = getelementptr inbounds i32, i32* %__first.addr.05.prol, i64 1
  %prol.iter.sub = add i64 %prol.iter, -1
  %prol.iter.cmp = icmp eq i64 %prol.iter.sub, 0
  br i1 %prol.iter.cmp, label %for.body.prol.loopexit, label %for.body.prol, !llvm.loop !36

for.body.prol.loopexit:                           ; preds = %for.body.prol, %for.body.preheader
  %__first.addr.05.unr = phi i32* [ %__first, %for.body.preheader ], [ %incdec.ptr.prol, %for.body.prol ]
  %5 = icmp ult i64 %2, 28
  br i1 %5, label %for.end, label %for.body

for.body:                                         ; preds = %for.body.prol.loopexit, %for.body
  %__first.addr.05 = phi i32* [ %incdec.ptr.7, %for.body ], [ %__first.addr.05.unr, %for.body.prol.loopexit ]
  store i32 %0, i32* %__first.addr.05, align 4, !tbaa !21
  %incdec.ptr = getelementptr inbounds i32, i32* %__first.addr.05, i64 1
  store i32 %0, i32* %incdec.ptr, align 4, !tbaa !21
  %incdec.ptr.1 = getelementptr inbounds i32, i32* %__first.addr.05, i64 2
  store i32 %0, i32* %incdec.ptr.1, align 4, !tbaa !21
  %incdec.ptr.2 = getelementptr inbounds i32, i32* %__first.addr.05, i64 3
  store i32 %0, i32* %incdec.ptr.2, align 4, !tbaa !21
  %incdec.ptr.3 = getelementptr inbounds i32, i32* %__first.addr.05, i64 4
  store i32 %0, i32* %incdec.ptr.3, align 4, !tbaa !21
  %incdec.ptr.4 = getelementptr inbounds i32, i32* %__first.addr.05, i64 5
  store i32 %0, i32* %incdec.ptr.4, align 4, !tbaa !21
  %incdec.ptr.5 = getelementptr inbounds i32, i32* %__first.addr.05, i64 6
  store i32 %0, i32* %incdec.ptr.5, align 4, !tbaa !21
  %incdec.ptr.6 = getelementptr inbounds i32, i32* %__first.addr.05, i64 7
  store i32 %0, i32* %incdec.ptr.6, align 4, !tbaa !21
  %incdec.ptr.7 = getelementptr inbounds i32, i32* %__first.addr.05, i64 8
  %cmp.7 = icmp eq i32* %incdec.ptr.7, %__last
  br i1 %cmp.7, label %for.end, label %for.body

for.end:                                          ; preds = %for.body.prol.loopexit, %for.body, %entry
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZNSt5arrayIiLm8171EE4dataEv(%"struct.std::array"* %this) local_unnamed_addr #2 comdat align 2 {
entry:
  %_M_elems = getelementptr inbounds %"struct.std::array", %"struct.std::array"* %this, i64 0, i32 0
  %call = call i32* @_ZNSt14__array_traitsIiLm8171EE6_S_ptrERA8171_Ki([8171 x i32]* dereferenceable(32684) %_M_elems) #19
  ret i32* %call
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZNSt14__array_traitsIiLm8171EE6_S_ptrERA8171_Ki([8171 x i32]* dereferenceable(32684) %__t) local_unnamed_addr #2 comdat align 2 {
entry:
  %arraydecay = getelementptr inbounds [8171 x i32], [8171 x i32]* %__t, i64 0, i64 0
  ret i32* %arraydecay
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE7DiscardEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* readonly %this) unnamed_addr #0 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %0 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %arraydecay = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 1, i64 0
  %cmp = icmp eq i32* %0, %arraydecay
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %1 = bitcast i32* %0 to i8*
  call void @_ZN4absl13base_internal13LowLevelAlloc4FreeEPv(i8* %1)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE7DiscardEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* readonly %this) unnamed_addr #0 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*** %ptr_, align 8, !tbaa !8
  %arraydecay = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 1, i64 0
  %cmp = icmp eq %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %0, %arraydecay
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %1 = bitcast %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %0 to i8*
  call void @_ZN4absl13base_internal13LowLevelAlloc4FreeEPv(i8* %1)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this) unnamed_addr #0 align 2 {
entry:
  %ref.tmp = alloca i32, align 4
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5clearEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE6resizeEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 8)
  %0 = bitcast i32* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  store i32 -1, i32* %ref.tmp, align 4, !tbaa !21
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4fillERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32* nonnull dereferenceable(4) %ref.tmp)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  %occupied_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 1
  store i32 0, i32* %occupied_, align 8, !tbaa !25
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE6resizeEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i32 %n) unnamed_addr #0 align 2 {
entry:
  %capacity_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 3
  %0 = load i32, i32* %capacity_, align 4, !tbaa !33
  %cmp = icmp ult i32 %0, %n
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4GrowEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %this, i32 %n)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  store i32 %n, i32* %size_, align 8, !tbaa !29
  ret void
}

; Function Attrs: nofree norecurse nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4fillERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %this, i32* nocapture readonly dereferenceable(4) %val) unnamed_addr #7 align 2 {
entry:
  %call4 = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this)
  %cmp5 = icmp eq i32 %call4, 0
  br i1 %cmp5, label %for.cond.cleanup, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %0 = load i32*, i32** %ptr_, align 8, !tbaa !32
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %entry
  ret void

for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %indvars.iv = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next, %for.body ]
  %1 = load i32, i32* %val, align 4, !tbaa !21
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %indvars.iv
  store i32 %1, i32* %arrayidx, align 4, !tbaa !21
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this)
  %2 = zext i32 %call to i64
  %cmp = icmp ult i64 %indvars.iv.next, %2
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4GrowEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i32 %n) unnamed_addr #0 align 2 {
entry:
  %capacity_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 3
  %0 = load i32, i32* %capacity_, align 4, !tbaa !33
  %cmp4 = icmp ult i32 %0, %n
  br i1 %cmp4, label %while.body, label %while.end

while.body:                                       ; preds = %entry, %while.body
  %1 = phi i32 [ %mul, %while.body ], [ %0, %entry ]
  %mul = shl i32 %1, 1
  %cmp = icmp ult i32 %mul, %n
  br i1 %cmp, label %while.body, label %while.cond.while.end_crit_edge

while.cond.while.end_crit_edge:                   ; preds = %while.body
  store i32 %mul, i32* %capacity_, align 4, !tbaa !33
  br label %while.end

while.end:                                        ; preds = %while.cond.while.end_crit_edge, %entry
  %.lcssa = phi i32 [ %mul, %while.cond.while.end_crit_edge ], [ %0, %entry ]
  %conv = zext i32 %.lcssa to i64
  %mul4 = shl nuw nsw i64 %conv, 2
  %2 = load %"struct.absl::base_internal::LowLevelAlloc::Arena"*, %"struct.absl::base_internal::LowLevelAlloc::Arena"** @_ZN4absl24synchronization_internal12_GLOBAL__N_15arenaE, align 8, !tbaa !2
  %call = call i8* @_ZN4absl13base_internal13LowLevelAlloc14AllocWithArenaEmPNS1_5ArenaE(i64 %mul4, %"struct.absl::base_internal::LowLevelAlloc::Arena"* %2)
  %3 = bitcast i8* %call to i32*
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %4 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  %5 = load i32, i32* %size_, align 8, !tbaa !29
  %idx.ext = zext i32 %5 to i64
  %add.ptr = getelementptr inbounds i32, i32* %4, i64 %idx.ext
  %call6 = call i32* @_ZSt4copyIPiS0_ET0_T_S2_S1_(i32* %4, i32* %add.ptr, i32* %3)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE7DiscardEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %this)
  %6 = bitcast %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this to i8**
  store i8* %call, i8** %6, align 8, !tbaa !32
  ret void
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt4copyIPiS0_ET0_T_S2_S1_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  %call = call i32* @_ZSt12__miter_baseIPiET_S1_(i32* %__first)
  %call1 = call i32* @_ZSt12__miter_baseIPiET_S1_(i32* %__last)
  %call2 = call i32* @_ZSt13__copy_move_aILb0EPiS0_ET1_T0_S2_S1_(i32* %call, i32* %call1, i32* %__result)
  ret i32* %call2
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt13__copy_move_aILb0EPiS0_ET1_T0_S2_S1_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  %__result.addr = alloca i32*, align 8
  store i32* %__result, i32** %__result.addr, align 8, !tbaa !2
  %call = call i32* @_ZSt12__niter_baseIPiET_S1_(i32* %__first) #19
  %call1 = call i32* @_ZSt12__niter_baseIPiET_S1_(i32* %__last) #19
  %0 = load i32*, i32** %__result.addr, align 8, !tbaa !2
  %call2 = call i32* @_ZSt12__niter_baseIPiET_S1_(i32* %0) #19
  %call3 = call i32* @_ZSt14__copy_move_a1ILb0EPiS0_ET1_T0_S2_S1_(i32* %call, i32* %call1, i32* %call2)
  %call4 = call i32* @_ZSt12__niter_wrapIPiET_RKS1_S1_(i32** nonnull dereferenceable(8) %__result.addr, i32* %call3)
  ret i32* %call4
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt12__miter_baseIPiET_S1_(i32* %__it) local_unnamed_addr #5 comdat {
entry:
  ret i32* %__it
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt12__niter_wrapIPiET_RKS1_S1_(i32** dereferenceable(8) %0, i32* %__res) local_unnamed_addr #5 comdat {
entry:
  ret i32* %__res
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt14__copy_move_a1ILb0EPiS0_ET1_T0_S2_S1_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  %call = call i32* @_ZSt14__copy_move_a2ILb0EPiS0_ET1_T0_S2_S1_(i32* %__first, i32* %__last, i32* %__result)
  ret i32* %call
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt12__niter_baseIPiET_S1_(i32* %__it) local_unnamed_addr #5 comdat {
entry:
  ret i32* %__it
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt14__copy_move_a2ILb0EPiS0_ET1_T0_S2_S1_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  %call = call i32* @_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mIiEEPT_PKS3_S6_S4_(i32* %__first, i32* %__last, i32* %__result)
  ret i32* %call
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mIiEEPT_PKS3_S6_S4_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #2 comdat align 2 {
entry:
  %sub.ptr.lhs.cast = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 2
  %tobool = icmp eq i64 %sub.ptr.sub, 0
  br i1 %tobool, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %0 = bitcast i32* %__result to i8*
  %1 = bitcast i32* %__first to i8*
  call void @llvm.memmove.p0i8.p0i8.i64(i8* align 4 %0, i8* align 4 %1, i64 %sub.ptr.sub, i1 false)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %add.ptr = getelementptr inbounds i32, i32* %__result, i64 %sub.ptr.div
  ret i32* %add.ptr
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i1 immarg) #3

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %this) unnamed_addr #4 align 2 {
entry:
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  %0 = load i32, i32* %size_, align 8, !tbaa !29
  ret i32 %0
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local dereferenceable(4) i32* @_ZNSt5arrayIiLm8171EEixEm(%"struct.std::array"* %this, i64 %__n) local_unnamed_addr #2 comdat align 2 {
entry:
  %_M_elems = getelementptr inbounds %"struct.std::array", %"struct.std::array"* %this, i64 0, i32 0
  %call = call dereferenceable(4) i32* @_ZNSt14__array_traitsIiLm8171EE6_S_refERA8171_Kim([8171 x i32]* dereferenceable(32684) %_M_elems, i64 %__n) #19
  ret i32* %call
}

; Function Attrs: norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_110PointerMap4HashEPv(i8* %ptr) unnamed_addr #14 align 2 {
entry:
  %0 = ptrtoint i8* %ptr to i64
  %rem = urem i64 %0, 8171
  %conv = trunc i64 %rem to i32
  ret i32 %conv
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nocapture readonly %this, i32 %i) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 0
  %0 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*** %ptr_, align 8, !tbaa !8
  %idxprom = zext i32 %i to i64
  %arrayidx = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %0, i64 %idxprom
  ret %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %arrayidx
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local dereferenceable(4) i32* @_ZNSt14__array_traitsIiLm8171EE6_S_refERA8171_Kim([8171 x i32]* dereferenceable(32684) %__t, i64 %__n) local_unnamed_addr #2 comdat align 2 {
entry:
  %arrayidx = getelementptr inbounds [8171 x i32], [8171 x i32]* %__t, i64 0, i64 %__n
  ret i32* %arrayidx
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_17NodeSet9FindIndexEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* nocapture readonly %this, i32 %v) unnamed_addr #11 align 2 {
entry:
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_)
  %sub = add i32 %call, -1
  %call2 = call fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4HashEj(i32 %v)
  %i.023 = and i32 %call2, %sub
  %call424 = call fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 %i.023)
  %0 = load i32, i32* %call424, align 4, !tbaa !21
  %cmp25 = icmp eq i32 %0, %v
  br i1 %cmp25, label %cleanup15, label %if.else

if.else:                                          ; preds = %entry, %cleanup
  %1 = phi i32 [ %2, %cleanup ], [ %0, %entry ]
  %i.027 = phi i32 [ %i.0, %cleanup ], [ %i.023, %entry ]
  %deleted_index.026 = phi i32 [ %spec.select, %cleanup ], [ -1, %entry ]
  %cmp5 = icmp eq i32 %1, -1
  br i1 %cmp5, label %if.then6, label %cleanup

if.then6:                                         ; preds = %if.else
  %cmp7 = icmp sgt i32 %deleted_index.026, -1
  %cond = select i1 %cmp7, i32 %deleted_index.026, i32 %i.027
  br label %cleanup15

cleanup:                                          ; preds = %if.else
  %cmp9 = icmp eq i32 %1, -2
  %cmp10 = icmp slt i32 %deleted_index.026, 0
  %or.cond = and i1 %cmp10, %cmp9
  %spec.select = select i1 %or.cond, i32 %i.027, i32 %deleted_index.026
  %add = add i32 %i.027, 1
  %i.0 = and i32 %add, %sub
  %call4 = call fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 %i.0)
  %2 = load i32, i32* %call4, align 4, !tbaa !21
  %cmp = icmp eq i32 %2, %v
  br i1 %cmp, label %cleanup15, label %if.else

cleanup15:                                        ; preds = %cleanup, %entry, %if.then6
  %retval.1.ph = phi i32 [ %cond, %if.then6 ], [ %i.023, %entry ], [ %i.0, %cleanup ]
  ret i32 %retval.1.ph
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc dereferenceable(4) i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %this, i32 %i) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %0 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %idxprom = zext i32 %i to i64
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %idxprom
  ret i32* %arrayidx
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4GrowEv(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this) unnamed_addr #0 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %copy = alloca %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", align 8
  %ref.tmp = alloca i32, align 4
  %0 = bitcast %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %copy to i8*
  call void @llvm.lifetime.start.p0i8(i64 48, i8* nonnull %0) #19
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiEC2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %copy)
  %table_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 0
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE8MoveFromEPS3_(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %copy, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %occupied_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet", %"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i64 0, i32 1
  store i32 0, i32* %occupied_, align 8, !tbaa !25
  %call = call fastcc i32 @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiE4sizeEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %copy)
  %mul = shl i32 %call, 1
  invoke fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE6resizeEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %table_, i32 %mul)
          to label %invoke.cont4 unwind label %lpad

invoke.cont4:                                     ; preds = %invoke.cont
  %1 = bitcast i32* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %1) #19
  store i32 -1, i32* %ref.tmp, align 4, !tbaa !21
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4fillERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %table_, i32* nonnull dereferenceable(4) %ref.tmp)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %1) #19
  %call10 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %copy)
  %call13 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %copy)
  %cmp13 = icmp eq i32* %call10, %call13
  br i1 %cmp13, label %for.cond.cleanup, label %for.body

for.cond.cleanup:                                 ; preds = %if.end, %invoke.cont4
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %copy) #19
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %0) #19
  ret void

lpad:                                             ; preds = %invoke.cont, %entry
  %2 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup20

for.body:                                         ; preds = %invoke.cont4, %if.end
  %__begin3.014 = phi i32* [ %incdec.ptr, %if.end ], [ %call10, %invoke.cont4 ]
  %3 = load i32, i32* %__begin3.014, align 4, !tbaa !21
  %cmp14 = icmp sgt i32 %3, -1
  br i1 %cmp14, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %call17 = invoke fastcc zeroext i1 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet6insertEi(%"class.absl::synchronization_internal::(anonymous namespace)::NodeSet"* %this, i32 %3)
          to label %if.end unwind label %lpad15

lpad15:                                           ; preds = %if.then
  %4 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup20

if.end:                                           ; preds = %if.then, %for.body
  %incdec.ptr = getelementptr inbounds i32, i32* %__begin3.014, i64 1
  %cmp = icmp eq i32* %incdec.ptr, %call13
  br i1 %cmp, label %for.cond.cleanup, label %for.body

ehcleanup20:                                      ; preds = %lpad15, %lpad
  %.sink15 = phi { i8*, i32 } [ %4, %lpad15 ], [ %2, %lpad ]
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiED2Ev(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %copy) #19
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %0) #19
  resume { i8*, i32 } %.sink15
}

; Function Attrs: norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_17NodeSet4HashEj(i32 %a) unnamed_addr #14 align 2 {
entry:
  %mul = mul i32 %a, 41
  ret i32 %mul
}

; Function Attrs: argmemonly norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc dereferenceable(4) i32* @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIiEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %this, i32 %i) unnamed_addr #4 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %0 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %idxprom = zext i32 %i to i64
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %idxprom
  ret i32* %arrayidx
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE8MoveFromEPS3_(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src) unnamed_addr #0 align 2 {
entry:
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src, i64 0, i32 0
  %0 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %arraydecay = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src, i64 0, i32 1, i64 0
  %cmp = icmp eq i32* %0, %arraydecay
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src, i64 0, i32 2
  %1 = load i32, i32* %size_, align 8, !tbaa !29
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE6resizeEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i32 %1)
  %2 = load i32*, i32** %ptr_, align 8, !tbaa !32
  %3 = load i32, i32* %size_, align 8, !tbaa !29
  %idx.ext = zext i32 %3 to i64
  %add.ptr = getelementptr inbounds i32, i32* %2, i64 %idx.ext
  %ptr_5 = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 0
  %4 = load i32*, i32** %ptr_5, align 8, !tbaa !32
  %call = call i32* @_ZSt4copyIPiS0_ET0_T_S2_S1_(i32* %2, i32* %add.ptr, i32* %4)
  store i32 0, i32* %size_, align 8, !tbaa !29
  br label %if.end

if.else:                                          ; preds = %entry
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE7DiscardEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this)
  %5 = bitcast %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src to i64*
  %6 = load i64, i64* %5, align 8, !tbaa !32
  %7 = bitcast %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this to i64*
  store i64 %6, i64* %7, align 8, !tbaa !32
  %size_9 = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src, i64 0, i32 2
  %8 = load i32, i32* %size_9, align 8, !tbaa !29
  %size_10 = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 2
  store i32 %8, i32* %size_10, align 8, !tbaa !29
  %capacity_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src, i64 0, i32 3
  %9 = load i32, i32* %capacity_, align 4, !tbaa !33
  %capacity_11 = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0", %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %this, i64 0, i32 3
  store i32 %9, i32* %capacity_11, align 4, !tbaa !33
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE4InitEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nonnull %src)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret void
}

; Function Attrs: inlinehint norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc i32 @_ZN4absl24synchronization_internal12_GLOBAL__N_111NodeVersionENS0_7GraphIdE(i64 %id.coerce) unnamed_addr #8 {
entry:
  %shr = lshr i64 %id.coerce, 32
  %conv = trunc i64 %shr to i32
  ret i32 %conv
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internalL4SortERKNS0_12_GLOBAL__N_13VecIPNS1_4NodeEEEPNS2_IiEE(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* dereferenceable(80) %nodes, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %delta) unnamed_addr #0 {
entry:
  %call = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %delta)
  %call2 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %delta)
  call fastcc void @_ZSt4sortIPiZN4absl24synchronization_internalL4SortERKNS2_12_GLOBAL__N_13VecIPNS3_4NodeEEEPNS4_IiEEE6ByRankEvT_SD_T0_(i32* %call, i32* %call2, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nonnull %nodes)
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internalL10MoveToListEPNS0_11GraphCycles3RepEPNS0_12_GLOBAL__N_13VecIiEES7_(%"struct.absl::synchronization_internal::GraphCycles::Rep"* nocapture readonly %r, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* nocapture readonly %src, %"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %dst) unnamed_addr #0 {
entry:
  %w = alloca i32, align 4
  %call = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE5beginEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src)
  %call1 = call fastcc i32* @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE3endEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %src)
  %cmp10 = icmp eq i32* %call, %call1
  br i1 %cmp10, label %for.cond.cleanup, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %0 = bitcast i32* %w to i8*
  %nodes_ = getelementptr inbounds %"struct.absl::synchronization_internal::GraphCycles::Rep", %"struct.absl::synchronization_internal::GraphCycles::Rep"* %r, i64 0, i32 0
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %entry
  ret void

for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %__begin2.011 = phi i32* [ %call, %for.body.lr.ph ], [ %incdec.ptr, %for.body ]
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  %1 = load i32, i32* %__begin2.011, align 4, !tbaa !21
  store i32 %1, i32* %w, align 4, !tbaa !21
  %call2 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %1)
  %2 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call2, align 8, !tbaa !2
  %rank = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %2, i64 0, i32 0
  %3 = load i32, i32* %rank, align 8, !tbaa !20
  store i32 %3, i32* %__begin2.011, align 4, !tbaa !21
  %call4 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %nodes_, i32 %1)
  %4 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call4, align 8, !tbaa !2
  %visited = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %4, i64 0, i32 3
  store i8 0, i8* %visited, align 4, !tbaa !18
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIiE9push_backERKi(%"class.absl::synchronization_internal::(anonymous namespace)::Vec.0"* %dst, i32* nonnull dereferenceable(4) %w)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  %incdec.ptr = getelementptr inbounds i32, i32* %__begin2.011, i64 1
  %cmp = icmp eq i32* %incdec.ptr, %call1
  br i1 %cmp, label %for.cond.cleanup, label %for.body
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt5mergeIPiS0_S0_ET1_T_S2_T0_S3_S1_(i32* %__first1, i32* %__last1, i32* %__first2, i32* %__last2, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  call void @_ZN9__gnu_cxx5__ops16__iter_less_iterEv()
  %call = call i32* @_ZSt7__mergeIPiS0_S0_N9__gnu_cxx5__ops15_Iter_less_iterEET1_T_S5_T0_S6_S4_T2_(i32* %__first1, i32* %__last1, i32* %__first2, i32* %__last2, i32* %__result)
  ret i32* %call
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define internal fastcc void @_ZSt4sortIPiZN4absl24synchronization_internalL4SortERKNS2_12_GLOBAL__N_13VecIPNS3_4NodeEEEPNS4_IiEEE6ByRankEvT_SD_T0_(i32* %__first, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #9 {
entry:
  %call = call fastcc %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* @_ZN9__gnu_cxx5__ops16__iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEENS0_15_Iter_comp_iterIT_EESF_(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  call fastcc void @_ZSt6__sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* %__first, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %call)
  ret void
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define internal fastcc void @_ZSt6__sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* %__first, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #9 {
entry:
  %cmp = icmp eq i32* %__first, %__last
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %sub.ptr.lhs.cast = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 2
  %call = call i64 @_ZSt4__lgl(i64 %sub.ptr.div)
  %mul = shl nsw i64 %call, 1
  call fastcc void @_ZSt16__introsort_loopIPilN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_T1_(i32* %__first, i32* %__last, i64 %mul, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  call fastcc void @_ZSt22__final_insertion_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* %__first, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  ret void
}

; Function Attrs: inlinehint nofree norecurse nounwind sanitize_cilk uwtable writeonly
define internal fastcc %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* @_ZN9__gnu_cxx5__ops16__iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEENS0_15_Iter_comp_iterIT_EESF_(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #15 {
entry:
  %retval = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_iter", align 8
  call fastcc void @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEC2ESD_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %retval, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  %coerce.dive3 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %retval, i64 0, i32 0, i32 0
  %0 = load %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive3, align 8
  ret %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %0
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt16__introsort_loopIPilN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_T1_(i32* %__first, i32* %__last, i64 %__depth_limit, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #2 {
entry:
  %sub.ptr.lhs.cast12 = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub13 = sub i64 %sub.ptr.lhs.cast12, %sub.ptr.rhs.cast
  %cmp14 = icmp sgt i64 %sub.ptr.sub13, 64
  br i1 %cmp14, label %while.body, label %while.end

while.body:                                       ; preds = %entry, %if.end
  %__last.addr.016 = phi i32* [ %call, %if.end ], [ %__last, %entry ]
  %__depth_limit.addr.015 = phi i64 [ %dec, %if.end ], [ %__depth_limit, %entry ]
  %cmp2 = icmp eq i64 %__depth_limit.addr.015, 0
  br i1 %cmp2, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  call fastcc void @_ZSt14__partial_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_T0_(i32* %__first, i32* %__last.addr.016, i32* %__last.addr.016, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  br label %while.end

if.end:                                           ; preds = %while.body
  %dec = add nsw i64 %__depth_limit.addr.015, -1
  %call = call fastcc i32* @_ZSt27__unguarded_partition_pivotIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEET_SH_SH_T0_(i32* %__first, i32* %__last.addr.016, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  call fastcc void @_ZSt16__introsort_loopIPilN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_T1_(i32* %call, i32* %__last.addr.016, i64 %dec, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  %sub.ptr.lhs.cast = ptrtoint i32* %call to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %cmp = icmp sgt i64 %sub.ptr.sub, 64
  br i1 %cmp, label %while.body, label %while.end

while.end:                                        ; preds = %if.end, %entry, %if.then
  ret void
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i64 @_ZSt4__lgl(i64 %__n) local_unnamed_addr #5 comdat {
entry:
  %0 = call i64 @llvm.ctlz.i64(i64 %__n, i1 true), !range !38
  %sub = xor i64 %0, 63
  ret i64 %sub
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZSt22__final_insertion_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* %__first, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #0 {
entry:
  %sub.ptr.lhs.cast = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %cmp = icmp sgt i64 %sub.ptr.sub, 64
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %add.ptr = getelementptr inbounds i32, i32* %__first, i64 16
  call fastcc void @_ZSt16__insertion_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* %__first, i32* nonnull %add.ptr, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  call fastcc void @_ZSt26__unguarded_insertion_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* nonnull %add.ptr, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  br label %if.end

if.else:                                          ; preds = %entry
  call fastcc void @_ZSt16__insertion_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* %__first, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret void
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt14__partial_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_T0_(i32* %__first, i32* %__middle, i32* readnone %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #5 {
entry:
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_iter", align 8
  %coerce.dive1 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive1, align 8
  call fastcc void @_ZSt13__heap_selectIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_T0_(i32* %__first, i32* %__middle, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  call fastcc void @_ZSt11__sort_heapIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_RT0_(i32* %__first, i32* %__middle, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull dereferenceable(8) %__comp)
  ret void
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define internal fastcc i32* @_ZSt27__unguarded_partition_pivotIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEET_SH_SH_T0_(i32* %__first, i32* %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #5 {
entry:
  %sub.ptr.lhs.cast = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 2
  %div = sdiv i64 %sub.ptr.div, 2
  %add.ptr = getelementptr inbounds i32, i32* %__first, i64 %div
  %add.ptr2 = getelementptr inbounds i32, i32* %__first, i64 1
  %add.ptr3 = getelementptr inbounds i32, i32* %__last, i64 -1
  call fastcc void @_ZSt22__move_median_to_firstIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_SH_T0_(i32* %__first, i32* nonnull %add.ptr2, i32* %add.ptr, i32* nonnull %add.ptr3, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  %call = call fastcc i32* @_ZSt21__unguarded_partitionIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEET_SH_SH_SH_T0_(i32* nonnull %add.ptr2, i32* %__last, i32* %__first, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  ret i32* %call
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt13__heap_selectIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_T0_(i32* %__first, i32* %__middle, i32* readnone %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #2 {
entry:
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_iter", align 8
  %coerce.dive1 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive1, align 8
  call fastcc void @_ZSt11__make_heapIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_RT0_(i32* %__first, i32* %__middle, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull dereferenceable(8) %__comp)
  %cmp9 = icmp ult i32* %__middle, %__last
  br i1 %cmp9, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.inc, %entry
  ret void

for.body:                                         ; preds = %entry, %for.inc
  %__i.010 = phi i32* [ %incdec.ptr, %for.inc ], [ %__middle, %entry ]
  %call = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %__i.010, i32* %__first)
  br i1 %call, label %if.then, label %for.inc

if.then:                                          ; preds = %for.body
  call fastcc void @_ZSt10__pop_heapIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_RT0_(i32* %__first, i32* %__middle, i32* %__i.010, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull dereferenceable(8) %__comp)
  br label %for.inc

for.inc:                                          ; preds = %for.body, %if.then
  %incdec.ptr = getelementptr inbounds i32, i32* %__i.010, i64 1
  %cmp = icmp ult i32* %incdec.ptr, %__last
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt11__sort_heapIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_RT0_(i32* %__first, i32* %__last, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nocapture readonly dereferenceable(8) %__comp) unnamed_addr #2 {
entry:
  %sub.ptr.lhs.cast5 = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub6 = sub i64 %sub.ptr.lhs.cast5, %sub.ptr.rhs.cast
  %cmp7 = icmp sgt i64 %sub.ptr.sub6, 4
  br i1 %cmp7, label %while.body, label %while.end

while.body:                                       ; preds = %entry, %while.body
  %__last.addr.08 = phi i32* [ %incdec.ptr, %while.body ], [ %__last, %entry ]
  %incdec.ptr = getelementptr inbounds i32, i32* %__last.addr.08, i64 -1
  call fastcc void @_ZSt10__pop_heapIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_RT0_(i32* %__first, i32* nonnull %incdec.ptr, i32* nonnull %incdec.ptr, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull dereferenceable(8) %__comp)
  %sub.ptr.lhs.cast = ptrtoint i32* %incdec.ptr to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %cmp = icmp sgt i64 %sub.ptr.sub, 4
  br i1 %cmp, label %while.body, label %while.end

while.end:                                        ; preds = %while.body, %entry
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt11__make_heapIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_RT0_(i32* %__first, i32* %__last, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nocapture readonly dereferenceable(8) %__comp) unnamed_addr #2 {
entry:
  %__value = alloca i32, align 4
  %sub.ptr.lhs.cast = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 2
  %cmp = icmp slt i64 %sub.ptr.sub, 8
  br i1 %cmp, label %return, label %if.end

if.end:                                           ; preds = %entry
  %sub = add nsw i64 %sub.ptr.div, -2
  %div = sdiv i64 %sub, 2
  %0 = bitcast i32* %__value to i8*
  %agg.tmp.sroa.0.0..sroa_idx = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  br label %while.cond

while.cond:                                       ; preds = %while.cond, %if.end
  %__parent.0 = phi i64 [ %div, %if.end ], [ %dec, %while.cond ]
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  %add.ptr = getelementptr inbounds i32, i32* %__first, i64 %__parent.0
  %call = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* dereferenceable(4) %add.ptr) #19
  %1 = load i32, i32* %call, align 4, !tbaa !21
  store i32 %1, i32* %__value, align 4, !tbaa !21
  %call5 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__value) #19
  %2 = load i32, i32* %call5, align 4, !tbaa !21
  %agg.tmp.sroa.0.0.copyload = load %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %agg.tmp.sroa.0.0..sroa_idx, align 8, !tbaa.struct !39
  call fastcc void @_ZSt13__adjust_heapIPiliN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_T0_SI_T1_T2_(i32* %__first, i64 %__parent.0, i64 %sub.ptr.div, i32 %2, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %agg.tmp.sroa.0.0.copyload)
  %cmp7 = icmp eq i64 %__parent.0, 0
  %dec = add nsw i64 %__parent.0, -1
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  br i1 %cmp7, label %return, label %while.cond

return:                                           ; preds = %while.cond, %entry
  ret void
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nocapture readonly %this, i32* nocapture readonly %__it1, i32* nocapture readonly %__it2) unnamed_addr #11 align 2 {
entry:
  %_M_comp = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %this, i64 0, i32 0
  %0 = load i32, i32* %__it1, align 4, !tbaa !21
  %1 = load i32, i32* %__it2, align 4, !tbaa !21
  %call = call fastcc zeroext i1 @_ZZN4absl24synchronization_internalL4SortERKNS0_12_GLOBAL__N_13VecIPNS1_4NodeEEEPNS2_IiEEENK6ByRankclEii(%struct.ByRank* %_M_comp, i32 %0, i32 %1)
  ret i1 %call
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt10__pop_heapIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_RT0_(i32* %__first, i32* %__last, i32* nonnull %__result, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nocapture readonly dereferenceable(8) %__comp) unnamed_addr #5 {
entry:
  %__value = alloca i32, align 4
  %0 = bitcast i32* %__value to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  %call = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__result) #19
  %1 = load i32, i32* %call, align 4, !tbaa !21
  store i32 %1, i32* %__value, align 4, !tbaa !21
  %call1 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* dereferenceable(4) %__first) #19
  %2 = load i32, i32* %call1, align 4, !tbaa !21
  store i32 %2, i32* %__result, align 4, !tbaa !21
  %sub.ptr.lhs.cast = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 2
  %call2 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__value) #19
  %3 = load i32, i32* %call2, align 4, !tbaa !21
  %agg.tmp.sroa.0.0..sroa_idx = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  %agg.tmp.sroa.0.0.copyload = load %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %agg.tmp.sroa.0.0..sroa_idx, align 8, !tbaa.struct !39
  call fastcc void @_ZSt13__adjust_heapIPiliN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_T0_SI_T1_T2_(i32* nonnull %__first, i64 0, i64 %sub.ptr.div, i32 %3, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %agg.tmp.sroa.0.0.copyload)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* dereferenceable(4) %__t) local_unnamed_addr #2 comdat {
entry:
  ret i32* %__t
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt13__adjust_heapIPiliN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_T0_SI_T1_T2_(i32* %__first, i64 %__holeIndex, i64 %__len, i32 %__value, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #2 {
entry:
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_iter", align 8
  %__value.addr = alloca i32, align 4
  %__cmp = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_val", align 8
  %coerce.dive1 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive1, align 8
  store i32 %__value, i32* %__value.addr, align 4, !tbaa !21
  %sub = add nsw i64 %__len, -1
  %div = sdiv i64 %sub, 2
  %cmp25 = icmp sgt i64 %div, %__holeIndex
  br i1 %cmp25, label %while.body, label %while.end

while.body:                                       ; preds = %entry, %while.body
  %__holeIndex.addr.026 = phi i64 [ %spec.select, %while.body ], [ %__holeIndex, %entry ]
  %add = shl i64 %__holeIndex.addr.026, 1
  %mul = add i64 %add, 2
  %add.ptr = getelementptr inbounds i32, i32* %__first, i64 %mul
  %sub2 = or i64 %add, 1
  %add.ptr3 = getelementptr inbounds i32, i32* %__first, i64 %sub2
  %call = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %add.ptr, i32* nonnull %add.ptr3)
  %spec.select = select i1 %call, i64 %sub2, i64 %mul
  %add.ptr4 = getelementptr inbounds i32, i32* %__first, i64 %spec.select
  %call5 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* dereferenceable(4) %add.ptr4) #19
  %0 = load i32, i32* %call5, align 4, !tbaa !21
  %add.ptr6 = getelementptr inbounds i32, i32* %__first, i64 %__holeIndex.addr.026
  store i32 %0, i32* %add.ptr6, align 4, !tbaa !21
  %cmp = icmp slt i64 %spec.select, %div
  br i1 %cmp, label %while.body, label %while.end

while.end:                                        ; preds = %while.body, %entry
  %__holeIndex.addr.0.lcssa = phi i64 [ %__holeIndex, %entry ], [ %spec.select, %while.body ]
  %and = and i64 %__len, 1
  %cmp7 = icmp eq i64 %and, 0
  br i1 %cmp7, label %land.lhs.true, label %if.end19

land.lhs.true:                                    ; preds = %while.end
  %sub8 = add nsw i64 %__len, -2
  %div9 = sdiv i64 %sub8, 2
  %cmp10 = icmp eq i64 %__holeIndex.addr.0.lcssa, %div9
  br i1 %cmp10, label %if.then11, label %if.end19

if.then11:                                        ; preds = %land.lhs.true
  %add12 = shl i64 %__holeIndex.addr.0.lcssa, 1
  %sub14 = or i64 %add12, 1
  %add.ptr15 = getelementptr inbounds i32, i32* %__first, i64 %sub14
  %call16 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %add.ptr15) #19
  %1 = load i32, i32* %call16, align 4, !tbaa !21
  %add.ptr17 = getelementptr inbounds i32, i32* %__first, i64 %__holeIndex.addr.0.lcssa
  store i32 %1, i32* %add.ptr17, align 4, !tbaa !21
  br label %if.end19

if.end19:                                         ; preds = %if.then11, %land.lhs.true, %while.end
  %__holeIndex.addr.1 = phi i64 [ %sub14, %if.then11 ], [ %__holeIndex.addr.0.lcssa, %land.lhs.true ], [ %__holeIndex.addr.0.lcssa, %while.end ]
  %2 = bitcast %"struct.__gnu_cxx::__ops::_Iter_comp_val"* %__cmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %2) #19
  %call20 = call fastcc dereferenceable(8) %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* @_ZSt4moveIRN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS4_12_GLOBAL__N_13VecIPNS5_4NodeEEEPNS6_IiEEE6ByRankEEEONSt16remove_referenceIT_E4typeEOSI_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull dereferenceable(8) %__comp) #19
  call fastcc void @_ZN9__gnu_cxx5__ops14_Iter_comp_valIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEC2EONS0_15_Iter_comp_iterISD_EE(%"struct.__gnu_cxx::__ops::_Iter_comp_val"* nonnull %__cmp, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull dereferenceable(8) %call20)
  %call21 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__value.addr) #19
  %3 = load i32, i32* %call21, align 4, !tbaa !21
  call fastcc void @_ZSt11__push_heapIPiliN9__gnu_cxx5__ops14_Iter_comp_valIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_T0_SI_T1_RT2_(i32* %__first, i64 %__holeIndex.addr.1, i64 %__holeIndex, i32 %3, %"struct.__gnu_cxx::__ops::_Iter_comp_val"* nonnull dereferenceable(8) %__cmp)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %2) #19
  ret void
}

; Function Attrs: norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc nonnull dereferenceable(8) %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* @_ZSt4moveIRN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS4_12_GLOBAL__N_13VecIPNS5_4NodeEEEPNS6_IiEEE6ByRankEEEONSt16remove_referenceIT_E4typeEOSI_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* readnone returned dereferenceable(8) %__t) unnamed_addr #14 {
entry:
  ret %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__t
}

; Function Attrs: argmemonly nofree norecurse nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN9__gnu_cxx5__ops14_Iter_comp_valIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEC2EONS0_15_Iter_comp_iterISD_EE(%"struct.__gnu_cxx::__ops::_Iter_comp_val"* nocapture %this, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* readonly dereferenceable(8) %__comp) unnamed_addr #10 align 2 {
entry:
  %_M_comp2 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0
  %call = call fastcc dereferenceable(8) %struct.ByRank* @_ZSt4moveIRZN4absl24synchronization_internalL4SortERKNS1_12_GLOBAL__N_13VecIPNS2_4NodeEEEPNS3_IiEEE6ByRankEONSt16remove_referenceIT_E4typeEOSE_(%struct.ByRank* nonnull dereferenceable(8) %_M_comp2) #19
  %0 = bitcast %struct.ByRank* %call to i64*
  %1 = bitcast %"struct.__gnu_cxx::__ops::_Iter_comp_val"* %this to i64*
  %2 = load i64, i64* %0, align 8, !tbaa !2
  store i64 %2, i64* %1, align 8, !tbaa !2
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt11__push_heapIPiliN9__gnu_cxx5__ops14_Iter_comp_valIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_T0_SI_T1_RT2_(i32* %__first, i64 %__holeIndex, i64 %__topIndex, i32 %__value, %"struct.__gnu_cxx::__ops::_Iter_comp_val"* nocapture readonly dereferenceable(8) %__comp) unnamed_addr #2 {
entry:
  %__value.addr = alloca i32, align 4
  store i32 %__value, i32* %__value.addr, align 4, !tbaa !21
  %cmp13 = icmp sgt i64 %__holeIndex, %__topIndex
  br i1 %cmp13, label %land.rhs, label %while.end

land.rhs:                                         ; preds = %entry, %while.body
  %__parent.015.in.in = phi i64 [ %__parent.015, %while.body ], [ %__holeIndex, %entry ]
  %__parent.015.in = add nsw i64 %__parent.015.in.in, -1
  %__parent.015 = sdiv i64 %__parent.015.in, 2
  %add.ptr = getelementptr inbounds i32, i32* %__first, i64 %__parent.015
  %call = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops14_Iter_comp_valIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiiEEbT_RT0_(%"struct.__gnu_cxx::__ops::_Iter_comp_val"* nonnull %__comp, i32* %add.ptr, i32* nonnull dereferenceable(4) %__value.addr)
  br i1 %call, label %while.body, label %while.end

while.body:                                       ; preds = %land.rhs
  %call2 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* dereferenceable(4) %add.ptr) #19
  %0 = load i32, i32* %call2, align 4, !tbaa !21
  %add.ptr3 = getelementptr inbounds i32, i32* %__first, i64 %__parent.015.in.in
  store i32 %0, i32* %add.ptr3, align 4, !tbaa !21
  %cmp = icmp sgt i64 %__parent.015, %__topIndex
  br i1 %cmp, label %land.rhs, label %while.end

while.end:                                        ; preds = %land.rhs, %while.body, %entry
  %__holeIndex.addr.0.lcssa = phi i64 [ %__holeIndex, %entry ], [ %__parent.015, %while.body ], [ %__parent.015.in.in, %land.rhs ]
  %call6 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__value.addr) #19
  %1 = load i32, i32* %call6, align 4, !tbaa !21
  %add.ptr7 = getelementptr inbounds i32, i32* %__first, i64 %__holeIndex.addr.0.lcssa
  store i32 %1, i32* %add.ptr7, align 4, !tbaa !21
  ret void
}

; Function Attrs: norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc nonnull dereferenceable(8) %struct.ByRank* @_ZSt4moveIRZN4absl24synchronization_internalL4SortERKNS1_12_GLOBAL__N_13VecIPNS2_4NodeEEEPNS3_IiEEE6ByRankEONSt16remove_referenceIT_E4typeEOSE_(%struct.ByRank* readnone returned dereferenceable(8) %__t) unnamed_addr #14 {
entry:
  ret %struct.ByRank* %__t
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZN9__gnu_cxx5__ops14_Iter_comp_valIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiiEEbT_RT0_(%"struct.__gnu_cxx::__ops::_Iter_comp_val"* nocapture readonly %this, i32* nocapture readonly %__it, i32* nocapture readonly dereferenceable(4) %__val) unnamed_addr #11 align 2 {
entry:
  %_M_comp = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_val", %"struct.__gnu_cxx::__ops::_Iter_comp_val"* %this, i64 0, i32 0
  %0 = load i32, i32* %__it, align 4, !tbaa !21
  %1 = load i32, i32* %__val, align 4, !tbaa !21
  %call = call fastcc zeroext i1 @_ZZN4absl24synchronization_internalL4SortERKNS0_12_GLOBAL__N_13VecIPNS1_4NodeEEEPNS2_IiEEENK6ByRankclEii(%struct.ByRank* %_M_comp, i32 %0, i32 %1)
  ret i1 %call
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZZN4absl24synchronization_internalL4SortERKNS0_12_GLOBAL__N_13VecIPNS1_4NodeEEEPNS2_IiEEENK6ByRankclEii(%struct.ByRank* nocapture readonly %this, i32 %a, i32 %b) unnamed_addr #11 align 2 {
entry:
  %nodes = getelementptr inbounds %struct.ByRank, %struct.ByRank* %this, i64 0, i32 0
  %0 = load %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %nodes, align 8, !tbaa !40
  %call = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %0, i32 %a)
  %1 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call, align 8, !tbaa !2
  %rank = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %1, i64 0, i32 0
  %2 = load i32, i32* %rank, align 8, !tbaa !20
  %call3 = call fastcc dereferenceable(8) %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZNK4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEixEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %0, i32 %b)
  %3 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call3, align 8, !tbaa !2
  %rank4 = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node", %"struct.absl::synchronization_internal::(anonymous namespace)::Node"* %3, i64 0, i32 0
  %4 = load i32, i32* %rank4, align 8, !tbaa !20
  %cmp = icmp slt i32 %2, %4
  ret i1 %cmp
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt22__move_median_to_firstIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_SH_SH_T0_(i32* %__result, i32* %__a, i32* %__b, i32* %__c, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #2 {
entry:
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_iter", align 8
  %coerce.dive1 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive1, align 8
  %call = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %__a, i32* %__b)
  br i1 %call, label %if.then, label %if.else8

if.then:                                          ; preds = %entry
  %call2 = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %__b, i32* %__c)
  br i1 %call2, label %if.end17, label %if.else

if.else:                                          ; preds = %if.then
  %call4 = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %__a, i32* %__c)
  %__c.__a = select i1 %call4, i32* %__c, i32* %__a
  br label %if.end17

if.else8:                                         ; preds = %entry
  %call9 = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %__a, i32* %__c)
  br i1 %call9, label %if.end17, label %if.else11

if.else11:                                        ; preds = %if.else8
  %call12 = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %__b, i32* %__c)
  %__c.__b = select i1 %call12, i32* %__c, i32* %__b
  br label %if.end17

if.end17:                                         ; preds = %if.else11, %if.else8, %if.else, %if.then
  %__a.sink = phi i32* [ %__b, %if.then ], [ %__c.__a, %if.else ], [ %__a, %if.else8 ], [ %__c.__b, %if.else11 ]
  call void @_ZSt9iter_swapIPiS0_EvT_T0_(i32* %__result, i32* %__a.sink)
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc i32* @_ZSt21__unguarded_partitionIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEET_SH_SH_SH_T0_(i32* %__first, i32* %__last, i32* nocapture readonly %__pivot, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #2 {
entry:
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_iter", align 8
  %coerce.dive1 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive1, align 8
  br label %while.body

while.body:                                       ; preds = %if.end, %entry
  %__last.addr.0 = phi i32* [ %__last, %entry ], [ %__last.addr.1, %if.end ]
  %__first.addr.0 = phi i32* [ %__first, %entry ], [ %incdec.ptr, %if.end ]
  br label %while.cond2

while.cond2:                                      ; preds = %while.cond2, %while.body
  %__first.addr.1 = phi i32* [ %__first.addr.0, %while.body ], [ %incdec.ptr, %while.cond2 ]
  %call = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %__first.addr.1, i32* %__pivot)
  %incdec.ptr = getelementptr inbounds i32, i32* %__first.addr.1, i64 1
  br i1 %call, label %while.cond2, label %while.cond5

while.cond5:                                      ; preds = %while.cond2, %while.cond5
  %__last.addr.0.pn = phi i32* [ %__last.addr.1, %while.cond5 ], [ %__last.addr.0, %while.cond2 ]
  %__last.addr.1 = getelementptr inbounds i32, i32* %__last.addr.0.pn, i64 -1
  %call6 = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* %__pivot, i32* nonnull %__last.addr.1)
  br i1 %call6, label %while.cond5, label %while.end9

while.end9:                                       ; preds = %while.cond5
  %cmp = icmp ult i32* %__first.addr.1, %__last.addr.1
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %while.end9
  ret i32* %__first.addr.1

if.end:                                           ; preds = %while.end9
  call void @_ZSt9iter_swapIPiS0_EvT_T0_(i32* %__first.addr.1, i32* nonnull %__last.addr.1)
  br label %while.body
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZSt9iter_swapIPiS0_EvT_T0_(i32* %__a, i32* %__b) local_unnamed_addr #5 comdat {
entry:
  call void @_ZSt4swapIiENSt9enable_ifIXsr6__and_ISt6__not_ISt15__is_tuple_likeIT_EESt21is_move_constructibleIS3_ESt18is_move_assignableIS3_EEE5valueEvE4typeERS3_SC_(i32* dereferenceable(4) %__a, i32* dereferenceable(4) %__b) #19
  ret void
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZSt4swapIiENSt9enable_ifIXsr6__and_ISt6__not_ISt15__is_tuple_likeIT_EESt21is_move_constructibleIS3_ESt18is_move_assignableIS3_EEE5valueEvE4typeERS3_SC_(i32* dereferenceable(4) %__a, i32* dereferenceable(4) %__b) local_unnamed_addr #5 comdat {
entry:
  %__tmp = alloca i32, align 4
  %0 = bitcast i32* %__tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  %call = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__a) #19
  %1 = load i32, i32* %call, align 4, !tbaa !21
  store i32 %1, i32* %__tmp, align 4, !tbaa !21
  %call1 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__b) #19
  %2 = load i32, i32* %call1, align 4, !tbaa !21
  store i32 %2, i32* %__a, align 4, !tbaa !21
  %call2 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__tmp) #19
  %3 = load i32, i32* %call2, align 4, !tbaa !21
  store i32 %3, i32* %__b, align 4, !tbaa !21
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #16

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZSt16__insertion_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* %__first, i32* readnone %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #0 {
entry:
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_iter", align 8
  %__val = alloca i32, align 4
  %coerce.dive1 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive1, align 8
  %cmp = icmp eq i32* %__first, %__last
  br i1 %cmp, label %for.end, label %for.cond.preheader

for.cond.preheader:                               ; preds = %entry
  %__i.013 = getelementptr inbounds i32, i32* %__first, i64 1
  %cmp214 = icmp eq i32* %__i.013, %__last
  br i1 %cmp214, label %for.end, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %for.cond.preheader
  %0 = bitcast i32* %__val to i8*
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %__i.016 = phi i32* [ %__i.013, %for.body.lr.ph ], [ %__i.0, %for.inc ]
  %__first.pn15 = phi i32* [ %__first, %for.body.lr.ph ], [ %__i.016, %for.inc ]
  %call = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIPiSG_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull %__comp, i32* nonnull %__i.016, i32* %__first)
  br i1 %call, label %if.then3, label %if.else

if.then3:                                         ; preds = %for.body
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  %call4 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__i.016) #19
  %1 = load i32, i32* %call4, align 4, !tbaa !21
  store i32 %1, i32* %__val, align 4, !tbaa !21
  %add.ptr5 = getelementptr inbounds i32, i32* %__first.pn15, i64 2
  %call6 = call i32* @_ZSt13move_backwardIPiS0_ET0_T_S2_S1_(i32* %__first, i32* nonnull %__i.016, i32* nonnull %add.ptr5)
  %call7 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__val) #19
  %2 = load i32, i32* %call7, align 4, !tbaa !21
  store i32 %2, i32* %__first, align 4, !tbaa !21
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  br label %for.inc

if.else:                                          ; preds = %for.body
  %call11 = call fastcc %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* @_ZN9__gnu_cxx5__ops15__val_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEENS0_14_Val_comp_iterIT_EENS0_15_Iter_comp_iterISF_EE(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  call fastcc void @_ZSt25__unguarded_linear_insertIPiN9__gnu_cxx5__ops14_Val_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_T0_(i32* nonnull %__i.016, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %call11)
  br label %for.inc

for.inc:                                          ; preds = %if.then3, %if.else
  %__i.0 = getelementptr inbounds i32, i32* %__i.016, i64 1
  %cmp2 = icmp eq i32* %__i.0, %__last
  br i1 %cmp2, label %for.end, label %for.body

for.end:                                          ; preds = %for.inc, %for.cond.preheader, %entry
  ret void
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt26__unguarded_insertion_sortIPiN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_SH_T0_(i32* %__first, i32* readnone %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #5 {
entry:
  %cmp4 = icmp eq i32* %__first, %__last
  br i1 %cmp4, label %for.cond.cleanup, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %call = call fastcc %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* @_ZN9__gnu_cxx5__ops15__val_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEENS0_14_Val_comp_iterIT_EENS0_15_Iter_comp_iterISF_EE(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce)
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %entry
  ret void

for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %__i.05 = phi i32* [ %__first, %for.body.lr.ph ], [ %incdec.ptr, %for.body ]
  call fastcc void @_ZSt25__unguarded_linear_insertIPiN9__gnu_cxx5__ops14_Val_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_T0_(i32* %__i.05, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %call)
  %incdec.ptr = getelementptr inbounds i32, i32* %__i.05, i64 1
  %cmp = icmp eq i32* %incdec.ptr, %__last
  br i1 %cmp, label %for.cond.cleanup, label %for.body
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt13move_backwardIPiS0_ET0_T_S2_S1_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  %call = call i32* @_ZSt12__miter_baseIPiET_S1_(i32* %__first)
  %call1 = call i32* @_ZSt12__miter_baseIPiET_S1_(i32* %__last)
  %call2 = call i32* @_ZSt22__copy_move_backward_aILb1EPiS0_ET1_T0_S2_S1_(i32* %call, i32* %call1, i32* %__result)
  ret i32* %call2
}

; Function Attrs: nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt25__unguarded_linear_insertIPiN9__gnu_cxx5__ops14_Val_comp_iterIZN4absl24synchronization_internalL4SortERKNS5_12_GLOBAL__N_13VecIPNS6_4NodeEEEPNS7_IiEEE6ByRankEEEvT_T0_(i32* nonnull %__last, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #2 {
entry:
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Val_comp_iter", align 8
  %__val = alloca i32, align 4
  %coerce.dive1 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Val_comp_iter", %"struct.__gnu_cxx::__ops::_Val_comp_iter"* %__comp, i64 0, i32 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive1, align 8
  %0 = bitcast i32* %__val to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #19
  %call = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__last) #19
  %1 = load i32, i32* %call, align 4, !tbaa !21
  store i32 %1, i32* %__val, align 4, !tbaa !21
  %__next.09 = getelementptr inbounds i32, i32* %__last, i64 -1
  %call210 = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops14_Val_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIiPiEEbRT_T0_(%"struct.__gnu_cxx::__ops::_Val_comp_iter"* nonnull %__comp, i32* nonnull dereferenceable(4) %__val, i32* nonnull %__next.09)
  br i1 %call210, label %while.body, label %while.end

while.body:                                       ; preds = %entry, %while.body
  %__next.012 = phi i32* [ %__next.0, %while.body ], [ %__next.09, %entry ]
  %__last.addr.011 = phi i32* [ %__next.012, %while.body ], [ %__last, %entry ]
  %call3 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__next.012) #19
  %2 = load i32, i32* %call3, align 4, !tbaa !21
  store i32 %2, i32* %__last.addr.011, align 4, !tbaa !21
  %__next.0 = getelementptr inbounds i32, i32* %__next.012, i64 -1
  %call2 = call fastcc zeroext i1 @_ZN9__gnu_cxx5__ops14_Val_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIiPiEEbRT_T0_(%"struct.__gnu_cxx::__ops::_Val_comp_iter"* nonnull %__comp, i32* nonnull dereferenceable(4) %__val, i32* nonnull %__next.0)
  br i1 %call2, label %while.body, label %while.end

while.end:                                        ; preds = %while.body, %entry
  %__last.addr.0.lcssa = phi i32* [ %__last, %entry ], [ %__next.012, %while.body ]
  %call5 = call dereferenceable(4) i32* @_ZSt4moveIRiEONSt16remove_referenceIT_E4typeEOS2_(i32* nonnull dereferenceable(4) %__val) #19
  %3 = load i32, i32* %call5, align 4, !tbaa !21
  store i32 %3, i32* %__last.addr.0.lcssa, align 4, !tbaa !21
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #19
  ret void
}

; Function Attrs: inlinehint norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* @_ZN9__gnu_cxx5__ops15__val_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEENS0_14_Val_comp_iterIT_EENS0_15_Iter_comp_iterISF_EE(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #8 {
entry:
  %retval = alloca %"struct.__gnu_cxx::__ops::_Val_comp_iter", align 8
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Iter_comp_iter", align 8
  %coerce.dive1 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0, i32 0
  store %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive1, align 8
  %call = call fastcc dereferenceable(8) %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* @_ZSt4moveIRN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS4_12_GLOBAL__N_13VecIPNS5_4NodeEEEPNS6_IiEEE6ByRankEEEONSt16remove_referenceIT_E4typeEOSI_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull dereferenceable(8) %__comp) #19
  call fastcc void @_ZN9__gnu_cxx5__ops14_Val_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEC2EONS0_15_Iter_comp_iterISD_EE(%"struct.__gnu_cxx::__ops::_Val_comp_iter"* nonnull %retval, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nonnull dereferenceable(8) %call)
  %coerce.dive3 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Val_comp_iter", %"struct.__gnu_cxx::__ops::_Val_comp_iter"* %retval, i64 0, i32 0, i32 0
  %0 = load %"class.absl::synchronization_internal::(anonymous namespace)::Vec"*, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"** %coerce.dive3, align 8
  ret %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %0
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt22__copy_move_backward_aILb1EPiS0_ET1_T0_S2_S1_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  %__result.addr = alloca i32*, align 8
  store i32* %__result, i32** %__result.addr, align 8, !tbaa !2
  %call = call i32* @_ZSt12__niter_baseIPiET_S1_(i32* %__first) #19
  %call1 = call i32* @_ZSt12__niter_baseIPiET_S1_(i32* %__last) #19
  %0 = load i32*, i32** %__result.addr, align 8, !tbaa !2
  %call2 = call i32* @_ZSt12__niter_baseIPiET_S1_(i32* %0) #19
  %call3 = call i32* @_ZSt23__copy_move_backward_a1ILb1EPiS0_ET1_T0_S2_S1_(i32* %call, i32* %call1, i32* %call2)
  %call4 = call i32* @_ZSt12__niter_wrapIPiET_RKS1_S1_(i32** nonnull dereferenceable(8) %__result.addr, i32* %call3)
  ret i32* %call4
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt23__copy_move_backward_a1ILb1EPiS0_ET1_T0_S2_S1_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  %call = call i32* @_ZSt23__copy_move_backward_a2ILb1EPiS0_ET1_T0_S2_S1_(i32* %__first, i32* %__last, i32* %__result)
  ret i32* %call
}

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt23__copy_move_backward_a2ILb1EPiS0_ET1_T0_S2_S1_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #9 comdat {
entry:
  %call = call i32* @_ZNSt20__copy_move_backwardILb1ELb1ESt26random_access_iterator_tagE13__copy_move_bIiEEPT_PKS3_S6_S4_(i32* %__first, i32* %__last, i32* %__result)
  ret i32* %call
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZNSt20__copy_move_backwardILb1ELb1ESt26random_access_iterator_tagE13__copy_move_bIiEEPT_PKS3_S6_S4_(i32* %__first, i32* %__last, i32* %__result) local_unnamed_addr #2 comdat align 2 {
entry:
  %sub.ptr.lhs.cast = ptrtoint i32* %__last to i64
  %sub.ptr.rhs.cast = ptrtoint i32* %__first to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = ashr exact i64 %sub.ptr.sub, 2
  %tobool = icmp eq i64 %sub.ptr.sub, 0
  br i1 %tobool, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %idx.neg = sub nsw i64 0, %sub.ptr.div
  %add.ptr = getelementptr inbounds i32, i32* %__result, i64 %idx.neg
  %0 = bitcast i32* %add.ptr to i8*
  %1 = bitcast i32* %__first to i8*
  call void @llvm.memmove.p0i8.p0i8.i64(i8* align 4 %0, i8* align 4 %1, i64 %sub.ptr.sub, i1 false)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %idx.neg1 = sub nsw i64 0, %sub.ptr.div
  %add.ptr2 = getelementptr inbounds i32, i32* %__result, i64 %idx.neg1
  ret i32* %add.ptr2
}

; Function Attrs: norecurse nounwind readonly sanitize_cilk uwtable
define internal fastcc zeroext i1 @_ZN9__gnu_cxx5__ops14_Val_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEclIiPiEEbRT_T0_(%"struct.__gnu_cxx::__ops::_Val_comp_iter"* nocapture readonly %this, i32* nocapture readonly dereferenceable(4) %__val, i32* nocapture readonly %__it) unnamed_addr #11 align 2 {
entry:
  %_M_comp = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Val_comp_iter", %"struct.__gnu_cxx::__ops::_Val_comp_iter"* %this, i64 0, i32 0
  %0 = load i32, i32* %__val, align 4, !tbaa !21
  %1 = load i32, i32* %__it, align 4, !tbaa !21
  %call = call fastcc zeroext i1 @_ZZN4absl24synchronization_internalL4SortERKNS0_12_GLOBAL__N_13VecIPNS1_4NodeEEEPNS2_IiEEENK6ByRankclEii(%struct.ByRank* %_M_comp, i32 %0, i32 %1)
  ret i1 %call
}

; Function Attrs: argmemonly nofree norecurse nounwind sanitize_cilk uwtable
define internal fastcc void @_ZN9__gnu_cxx5__ops14_Val_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEC2EONS0_15_Iter_comp_iterISD_EE(%"struct.__gnu_cxx::__ops::_Val_comp_iter"* nocapture %this, %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* readonly dereferenceable(8) %__comp) unnamed_addr #10 align 2 {
entry:
  %_M_comp2 = getelementptr inbounds %"struct.__gnu_cxx::__ops::_Iter_comp_iter", %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %__comp, i64 0, i32 0
  %call = call fastcc dereferenceable(8) %struct.ByRank* @_ZSt4moveIRZN4absl24synchronization_internalL4SortERKNS1_12_GLOBAL__N_13VecIPNS2_4NodeEEEPNS3_IiEEE6ByRankEONSt16remove_referenceIT_E4typeEOSE_(%struct.ByRank* nonnull dereferenceable(8) %_M_comp2) #19
  %0 = bitcast %struct.ByRank* %call to i64*
  %1 = bitcast %"struct.__gnu_cxx::__ops::_Val_comp_iter"* %this to i64*
  %2 = load i64, i64* %0, align 8, !tbaa !2
  store i64 %2, i64* %1, align 8, !tbaa !2
  ret void
}

; Function Attrs: argmemonly nofree norecurse nounwind sanitize_cilk uwtable writeonly
define internal fastcc void @_ZN9__gnu_cxx5__ops15_Iter_comp_iterIZN4absl24synchronization_internalL4SortERKNS3_12_GLOBAL__N_13VecIPNS4_4NodeEEEPNS5_IiEEE6ByRankEC2ESD_(%"struct.__gnu_cxx::__ops::_Iter_comp_iter"* nocapture %this, %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce) unnamed_addr #13 align 2 {
entry:
  %0 = bitcast %"struct.__gnu_cxx::__ops::_Iter_comp_iter"* %this to i64*
  %.cast = ptrtoint %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %__comp.coerce to i64
  store i64 %.cast, i64* %0, align 8, !tbaa !2
  ret void
}

; Function Attrs: sanitize_cilk uwtable
define linkonce_odr dso_local i32* @_ZSt7__mergeIPiS0_S0_N9__gnu_cxx5__ops15_Iter_less_iterEET1_T_S5_T0_S6_S4_T2_(i32* %__first1, i32* %__last1, i32* %__first2, i32* %__last2, i32* %__result) local_unnamed_addr #0 comdat {
entry:
  %__comp = alloca %"struct.__gnu_cxx::__ops::_Iter_less_iter", align 1
  %cmp13 = icmp ne i32* %__first1, %__last1
  %cmp114 = icmp ne i32* %__first2, %__last2
  %0 = and i1 %cmp114, %cmp13
  br i1 %0, label %while.body, label %while.end

while.body:                                       ; preds = %entry, %if.end
  %__result.addr.017 = phi i32* [ %incdec.ptr3, %if.end ], [ %__result, %entry ]
  %__first1.addr.016 = phi i32* [ %__first1.addr.1, %if.end ], [ %__first1, %entry ]
  %__first2.addr.015 = phi i32* [ %__first2.addr.1, %if.end ], [ %__first2, %entry ]
  %call = call zeroext i1 @_ZNK9__gnu_cxx5__ops15_Iter_less_iterclIPiS3_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_less_iter"* nonnull %__comp, i32* %__first2.addr.015, i32* %__first1.addr.016)
  br i1 %call, label %if.then, label %if.else

if.then:                                          ; preds = %while.body
  %1 = load i32, i32* %__first2.addr.015, align 4, !tbaa !21
  store i32 %1, i32* %__result.addr.017, align 4, !tbaa !21
  %incdec.ptr = getelementptr inbounds i32, i32* %__first2.addr.015, i64 1
  br label %if.end

if.else:                                          ; preds = %while.body
  %2 = load i32, i32* %__first1.addr.016, align 4, !tbaa !21
  store i32 %2, i32* %__result.addr.017, align 4, !tbaa !21
  %incdec.ptr2 = getelementptr inbounds i32, i32* %__first1.addr.016, i64 1
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %__first2.addr.1 = phi i32* [ %incdec.ptr, %if.then ], [ %__first2.addr.015, %if.else ]
  %__first1.addr.1 = phi i32* [ %__first1.addr.016, %if.then ], [ %incdec.ptr2, %if.else ]
  %incdec.ptr3 = getelementptr inbounds i32, i32* %__result.addr.017, i64 1
  %cmp = icmp ne i32* %__first1.addr.1, %__last1
  %cmp1 = icmp ne i32* %__first2.addr.1, %__last2
  %3 = and i1 %cmp1, %cmp
  br i1 %3, label %while.body, label %while.end

while.end:                                        ; preds = %if.end, %entry
  %__first2.addr.0.lcssa = phi i32* [ %__first2, %entry ], [ %__first2.addr.1, %if.end ]
  %__first1.addr.0.lcssa = phi i32* [ %__first1, %entry ], [ %__first1.addr.1, %if.end ]
  %__result.addr.0.lcssa = phi i32* [ %__result, %entry ], [ %incdec.ptr3, %if.end ]
  %call4 = call i32* @_ZSt4copyIPiS0_ET0_T_S2_S1_(i32* %__first1.addr.0.lcssa, i32* %__last1, i32* %__result.addr.0.lcssa)
  %call5 = call i32* @_ZSt4copyIPiS0_ET0_T_S2_S1_(i32* %__first2.addr.0.lcssa, i32* %__last2, i32* %call4)
  ret i32* %call5
}

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN9__gnu_cxx5__ops16__iter_less_iterEv() local_unnamed_addr #5 comdat {
entry:
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local zeroext i1 @_ZNK9__gnu_cxx5__ops15_Iter_less_iterclIPiS3_EEbT_T0_(%"struct.__gnu_cxx::__ops::_Iter_less_iter"* %this, i32* %__it1, i32* %__it2) local_unnamed_addr #2 comdat align 2 {
entry:
  %0 = load i32, i32* %__it1, align 4, !tbaa !21
  %1 = load i32, i32* %__it2, align 4, !tbaa !21
  %cmp = icmp slt i32 %0, %1
  ret i1 %cmp
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local i64 @_ZN4absl13base_internal8HideMaskEv() local_unnamed_addr #2 comdat {
entry:
  ret i64 -1136490970041655429
}

; Function Attrs: sanitize_cilk uwtable
define internal fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE4GrowEj(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i32 %n) unnamed_addr #0 align 2 {
entry:
  %capacity_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 3
  %0 = load i32, i32* %capacity_, align 4, !tbaa !30
  %cmp4 = icmp ult i32 %0, %n
  br i1 %cmp4, label %while.body, label %while.end

while.body:                                       ; preds = %entry, %while.body
  %1 = phi i32 [ %mul, %while.body ], [ %0, %entry ]
  %mul = shl i32 %1, 1
  %cmp = icmp ult i32 %mul, %n
  br i1 %cmp, label %while.body, label %while.cond.while.end_crit_edge

while.cond.while.end_crit_edge:                   ; preds = %while.body
  store i32 %mul, i32* %capacity_, align 4, !tbaa !30
  br label %while.end

while.end:                                        ; preds = %while.cond.while.end_crit_edge, %entry
  %.lcssa = phi i32 [ %mul, %while.cond.while.end_crit_edge ], [ %0, %entry ]
  %conv = zext i32 %.lcssa to i64
  %mul4 = shl nuw nsw i64 %conv, 3
  %2 = load %"struct.absl::base_internal::LowLevelAlloc::Arena"*, %"struct.absl::base_internal::LowLevelAlloc::Arena"** @_ZN4absl24synchronization_internal12_GLOBAL__N_15arenaE, align 8, !tbaa !2
  %call = call i8* @_ZN4absl13base_internal13LowLevelAlloc14AllocWithArenaEmPNS1_5ArenaE(i64 %mul4, %"struct.absl::base_internal::LowLevelAlloc::Arena"* %2)
  %3 = bitcast i8* %call to %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**
  %ptr_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 0
  %4 = load %"struct.absl::synchronization_internal::(anonymous namespace)::Node"**, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*** %ptr_, align 8, !tbaa !8
  %size_ = getelementptr inbounds %"class.absl::synchronization_internal::(anonymous namespace)::Vec", %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this, i64 0, i32 2
  %5 = load i32, i32* %size_, align 8, !tbaa !11
  %idx.ext = zext i32 %5 to i64
  %add.ptr = getelementptr inbounds %"struct.absl::synchronization_internal::(anonymous namespace)::Node"*, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %4, i64 %idx.ext
  call fastcc void @_ZSt4copyIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeES5_ET0_T_S7_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %4, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %add.ptr, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %3)
  call fastcc void @_ZN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEE7DiscardEv(%"class.absl::synchronization_internal::(anonymous namespace)::Vec"* nonnull %this)
  %6 = bitcast %"class.absl::synchronization_internal::(anonymous namespace)::Vec"* %this to i8**
  store i8* %call, i8** %6, align 8, !tbaa !8
  ret void
}

; Function Attrs: argmemonly inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt4copyIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeES5_ET0_T_S7_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__result) unnamed_addr #17 {
entry:
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZSt12__miter_baseIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeEET_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first)
  %call1 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZSt12__miter_baseIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeEET_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last)
  call fastcc void @_ZSt13__copy_move_aILb0EPPN4absl24synchronization_internal12_GLOBAL__N_14NodeES5_ET1_T0_S7_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call1, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__result)
  ret void
}

; Function Attrs: argmemonly inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt13__copy_move_aILb0EPPN4absl24synchronization_internal12_GLOBAL__N_14NodeES5_ET1_T0_S7_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__result) unnamed_addr #17 {
entry:
  %call = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZSt12__niter_baseIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeEET_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first) #19
  %call1 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZSt12__niter_baseIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeEET_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last) #19
  %call2 = call fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZSt12__niter_baseIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeEET_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__result) #19
  call fastcc void @_ZSt14__copy_move_a1ILb0EPPN4absl24synchronization_internal12_GLOBAL__N_14NodeES5_ET1_T0_S7_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call1, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %call2)
  ret void
}

; Function Attrs: inlinehint norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZSt12__miter_baseIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeEET_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** readnone returned %__it) unnamed_addr #8 {
entry:
  ret %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__it
}

; Function Attrs: argmemonly inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt14__copy_move_a1ILb0EPPN4absl24synchronization_internal12_GLOBAL__N_14NodeES5_ET1_T0_S7_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** nocapture %__result) unnamed_addr #17 {
entry:
  call fastcc void @_ZSt14__copy_move_a2ILb0EPPN4absl24synchronization_internal12_GLOBAL__N_14NodeES5_ET1_T0_S7_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__result)
  ret void
}

; Function Attrs: inlinehint norecurse nounwind readnone sanitize_cilk uwtable
define internal fastcc %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** @_ZSt12__niter_baseIPPN4absl24synchronization_internal12_GLOBAL__N_14NodeEET_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** readnone returned %__it) unnamed_addr #8 {
entry:
  ret %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__it
}

; Function Attrs: argmemonly inlinehint nounwind sanitize_cilk uwtable
define internal fastcc void @_ZSt14__copy_move_a2ILb0EPPN4absl24synchronization_internal12_GLOBAL__N_14NodeES5_ET1_T0_S7_S6_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** nocapture %__result) unnamed_addr #17 {
entry:
  call fastcc void @_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mIPN4absl24synchronization_internal12_GLOBAL__N_14NodeEEEPT_PKS8_SB_S9_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__result)
  ret void
}

; Function Attrs: argmemonly nounwind sanitize_cilk uwtable
define internal fastcc void @_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mIPN4absl24synchronization_internal12_GLOBAL__N_14NodeEEEPT_PKS8_SB_S9_(%"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last, %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** nocapture %__result) unnamed_addr #18 align 2 {
entry:
  %sub.ptr.lhs.cast = ptrtoint %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__last to i64
  %sub.ptr.rhs.cast = ptrtoint %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %tobool = icmp eq i64 %sub.ptr.sub, 0
  br i1 %tobool, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %0 = bitcast %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__result to i8*
  %1 = bitcast %"struct.absl::synchronization_internal::(anonymous namespace)::Node"** %__first to i8*
  call void @llvm.memmove.p0i8.p0i8.i64(i8* align 8 %0, i8* align 8 %1, i64 %sub.ptr.sub, i1 false)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  ret void
}

attributes #0 = { sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { argmemonly norecurse nounwind readonly sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { inlinehint nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noinline noreturn nounwind }
attributes #7 = { nofree norecurse nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { inlinehint norecurse nounwind readnone sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { inlinehint sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { argmemonly nofree norecurse nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { norecurse nounwind readonly sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #12 = { cold "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #13 = { argmemonly nofree norecurse nounwind sanitize_cilk uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #14 = { norecurse nounwind readnone sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { inlinehint nofree norecurse nounwind sanitize_cilk uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { nounwind readnone speculatable willreturn }
attributes #17 = { argmemonly inlinehint nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #18 = { argmemonly nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #19 = { nounwind }
attributes #20 = { noreturn nounwind }
attributes #21 = { cold }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 4ea28362975f8437bea89bf786a34bd5ad5dbb5b)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !3, i64 0}
!7 = !{!"_ZTSN4absl24synchronization_internal11GraphCyclesE", !3, i64 0}
!8 = !{!9, !3, i64 0}
!9 = !{!"_ZTSN4absl24synchronization_internal12_GLOBAL__N_13VecIPNS1_4NodeEEE", !3, i64 0, !4, i64 8, !10, i64 72, !10, i64 76}
!10 = !{!"int", !4, i64 0}
!11 = !{!9, !10, i64 72}
!12 = !{!13, !15, i64 16}
!13 = !{!"_ZTSN4absl24synchronization_internal12_GLOBAL__N_14NodeE", !10, i64 0, !10, i64 4, !10, i64 8, !14, i64 12, !15, i64 16, !16, i64 24, !16, i64 80, !10, i64 136, !10, i64 140, !4, i64 144}
!14 = !{!"bool", !4, i64 0}
!15 = !{!"long", !4, i64 0}
!16 = !{!"_ZTSN4absl24synchronization_internal12_GLOBAL__N_17NodeSetE", !17, i64 0, !10, i64 48}
!17 = !{!"_ZTSN4absl24synchronization_internal12_GLOBAL__N_13VecIiEE", !3, i64 0, !4, i64 8, !10, i64 40, !10, i64 44}
!18 = !{!13, !14, i64 12}
!19 = !{i8 0, i8 2}
!20 = !{!13, !10, i64 0}
!21 = !{!10, !10, i64 0}
!22 = !{!23, !3, i64 0}
!23 = !{!"_ZTSN4absl24synchronization_internal12_GLOBAL__N_110PointerMapE", !3, i64 0, !24, i64 8}
!24 = !{!"_ZTSSt5arrayIiLm8171EE", !4, i64 0}
!25 = !{!16, !10, i64 48}
!26 = !{!13, !10, i64 4}
!27 = !{!13, !10, i64 140}
!28 = !{!13, !10, i64 136}
!29 = !{!17, !10, i64 40}
!30 = !{!9, !10, i64 76}
!31 = !{!13, !10, i64 8}
!32 = !{!17, !3, i64 0}
!33 = !{!17, !10, i64 44}
!34 = !{i64 0, i64 8, !35}
!35 = !{!15, !15, i64 0}
!36 = distinct !{!36, !37}
!37 = !{!"llvm.loop.unroll.disable"}
!38 = !{i64 0, i64 65}
!39 = !{i64 0, i64 8, !2}
!40 = !{!41, !3, i64 0}
!41 = !{!"_ZTSZN4absl24synchronization_internalL4SortERKNS0_12_GLOBAL__N_13VecIPNS1_4NodeEEEPNS2_IiEEE6ByRank", !3, i64 0}
