; Check that Cilksan properly instruments programs with loops in the
; exits of Tapir loops.
;
; RUN: opt < %s -csan -S -o - | FileCheck %s
; RUN: opt < %s -passes='cilksan' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i64, %union.anon.1 }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider" = type { i8* }
%union.anon.1 = type { i64, [8 x i8] }
%"class.parlay::sequence.2" = type { %"struct.parlay::_sequence_base.3" }
%"struct.parlay::_sequence_base.3" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::_data_impl" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::_data_impl" = type { %union.anon.6, i8 }
%union.anon.6 = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::long_seq" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::long_seq" = type <{ %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer", [6 x i8] }>
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer::header"* }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer::header" = type <{ i64, %union.anon.33, [7 x i8] }>
%union.anon.33 = type { [1 x i8] }
%"class.parlay::sequence" = type { %"struct.parlay::_sequence_base" }
%"struct.parlay::_sequence_base" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::_data_impl" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::_data_impl" = type { %union.anon, i8 }
%union.anon = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::long_seq" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::long_seq" = type <{ %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer", [6 x i8] }>
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header" = type <{ i64, %union.anon.32, [7 x i8] }>
%union.anon.32 = type { [1 x i8] }
%class.anon.86 = type { %class.anon.27*, %"struct.std::pair.87"* }
%class.anon.27 = type { %"class.parlay::sequence"*, %"class.parlay::sequence"* }
%"struct.std::pair.87" = type { %"class.parlay::sequence", i64 }
%class.anon.92 = type { %"class.parlay::sequence"*, i8**, i8** }
%"struct.parlay::pool_allocator" = type { i64, i64, i64, i64, %"struct.std::atomic", %"struct.std::atomic", %"class.std::unique_ptr", %"struct.parlay::block_allocator"*, %"class.std::vector", i64 }
%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"struct.std::__atomic_base" = type { i64 }
%"class.std::unique_ptr" = type { %"struct.std::__uniq_ptr_data" }
%"struct.std::__uniq_ptr_data" = type { %"class.std::__uniq_ptr_impl" }
%"class.std::__uniq_ptr_impl" = type { %"class.std::tuple" }
%"class.std::tuple" = type { %"struct.std::_Tuple_impl" }
%"struct.std::_Tuple_impl" = type { %"struct.std::_Head_base.38" }
%"struct.std::_Head_base.38" = type { %"class.parlay::concurrent_stack"* }
%"class.parlay::concurrent_stack" = type { %"class.parlay::concurrent_stack<void *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<void *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<void *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<void *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<void *>::Node" = type { i8*, %"struct.parlay::concurrent_stack<void *>::Node"*, i64 }
%"class.std::mutex" = type { %"class.std::__mutex_base" }
%"class.std::__mutex_base" = type { %union.pthread_mutex_t }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%"struct.parlay::block_allocator" = type { i8, [63 x i8], %"class.parlay::concurrent_stack.39", %"class.parlay::concurrent_stack.40", %"struct.parlay::block_allocator::thread_list"*, i64, i64, i64, %"struct.std::atomic", i64, [16 x i8] }
%"class.parlay::concurrent_stack.39" = type { %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<char *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<char *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<char *>::Node" = type { i8*, %"struct.parlay::concurrent_stack<char *>::Node"*, i64 }
%"class.parlay::concurrent_stack.40" = type { %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node" = type { %"struct.parlay::block_allocator::block"*, %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node"*, i64 }
%"struct.parlay::block_allocator::block" = type { %"struct.parlay::block_allocator::block"* }
%"struct.parlay::block_allocator::thread_list" = type { i64, %"struct.parlay::block_allocator::block"*, %"struct.parlay::block_allocator::block"*, [256 x i8], [40 x i8] }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl_data" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl_data" = type { i64*, i64*, i64* }

@_ZN7benchIO11intHeaderIOB5cxx11E = dso_local global %"class.std::__cxx11::basic_string" zeroinitializer, align 8
@.str.18 = private unnamed_addr constant [4 x i8] c"%lu\00", align 1

; Function Attrs: inlinehint sanitize_cilk uwtable
define void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb"(i64 %end, %"class.parlay::sequence.2"* %f.0, %"class.parlay::sequence"** %f.1, %class.anon.86* %f.2) unnamed_addr #0 personality i32 (...)* @__gxx_personality_v0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp1 = icmp eq i64 %end, 0
  br i1 %cmp1, label %sync.continue23, label %pfor.cond.preheader

pfor.cond.preheader:                              ; preds = %entry
  %.idx.i = getelementptr %class.anon.86, %class.anon.86* %f.2, i64 0, i32 0
  %.idx2.i = getelementptr %class.anon.86, %class.anon.86* %f.2, i64 0, i32 1
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  detach within %syncreg, label %pfor.body.tf.tf, label %pfor.inc

pfor.body.tf.tf:                                  ; preds = %pfor.cond
  %first.addr.i.i.i.i = alloca i8*, align 8
  %buffer.i.i.i.i = alloca i8*, align 8
  %agg.tmp.i.i.i.i = alloca %class.anon.92, align 8
  %s.i.i.i.i = alloca [22 x i8], align 16
  %s.i.i.i = alloca %"class.parlay::sequence.2", align 8
  %ref.tmp.i.i.i = alloca [4 x %"class.parlay::sequence"], align 8
  %agg.tmp.i.i = alloca %"struct.std::pair.87", align 8
  %ref.tmp.i = alloca %"class.parlay::sequence", align 8
  %0 = load %"class.parlay::sequence"*, %"class.parlay::sequence"** %f.1, align 8, !tbaa !2
  %arrayidx.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %0, i64 %__begin.0
  %1 = bitcast %"class.parlay::sequence"* %ref.tmp.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %1) #8
  %.idx.val.i = load %class.anon.27*, %class.anon.27** %.idx.i, align 8, !tbaa !6
  %.idx2.val.i = load %"struct.std::pair.87"*, %"struct.std::pair.87"** %.idx2.i, align 8, !tbaa !8
  %2 = bitcast %"struct.std::pair.87"* %agg.tmp.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %2)
  %impl.i.i.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0
  %second.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 1
  %second3.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %.idx2.val.i, i64 %__begin.0, i32 1
  %3 = load i64, i64* %second3.i.i.i, align 8, !tbaa !9, !noalias !13
  store i64 %3, i64* %second.i.i.i, align 8, !tbaa !9, !noalias !13
  %4 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %4) #8, !noalias !16
  %5 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 60, i8* nonnull %5) #8, !noalias !16
  %impl.i.i.i2.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0
  br label %pfor.body.tf.tf.tf

pfor.body.tf.tf.tf:                               ; preds = %pfor.body.tf.tf
  %impl.i.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %.idx2.val.i, i64 %__begin.0, i32 0, i32 0, i32 0
  %tf.i = call token @llvm.taskframe.create()
  %syncreg19.i.i.i.i.i = call token @llvm.syncregion.start(), !noalias !16
  call void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i), !noalias !13
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i2.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i)
          to label %invoke.cont.i.i.i unwind label %lpad.body.i.i.i, !noalias !16

invoke.cont.i.i.i:                                ; preds = %pfor.body.tf.tf.tf
  %6 = getelementptr inbounds %class.anon.27, %class.anon.27* %.idx.val.i, i64 0, i32 0
  %7 = load %"class.parlay::sequence"*, %"class.parlay::sequence"** %6, align 8, !tbaa !19, !noalias !16
  %impl.i1.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %7, i64 0, i32 0, i32 0
  %impl.i.i2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i2.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i1.i.i.i)
          to label %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i.i.i.i unwind label %lpad.body.thread89.i.i.i, !noalias !16

_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i.i.i.i: ; preds = %invoke.cont.i.i.i
  %arrayinit.element3.ptr.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2
  %8 = load i64, i64* %second.i.i.i, align 8, !tbaa !9, !noalias !16
  %9 = getelementptr inbounds [22 x i8], [22 x i8]* %s.i.i.i.i, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 22, i8* nonnull %9) #8, !noalias !21
  %call.i.i.i.i = call i32 (i8*, i64, i8*, ...) @snprintf(i8* nonnull %9, i64 21, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.18, i64 0, i64 0), i64 %8) #8, !noalias !21
  %cmp.i.i.i.i.i = icmp slt i32 %call.i.i.i.i, 20
  %.sroa.speculated.i.i.i.i = select i1 %cmp.i.i.i.i.i, i32 %call.i.i.i.i, i32 20
  %idx.ext.i.i.i.i = sext i32 %.sroa.speculated.i.i.i.i to i64
  %small_n.i.i.i.i.i.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 1
  store i8 0, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !alias.scope !24, !noalias !16
  %10 = bitcast i8** %first.addr.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %10), !noalias !16
  %11 = bitcast %class.anon.92* %agg.tmp.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %11), !noalias !16
  store i8* %9, i8** %first.addr.i.i.i.i, align 8, !tbaa !2, !noalias !16
  %cmp.i.i55.i.i.i = icmp ugt i32 %.sroa.speculated.i.i.i.i, 13
  br i1 %cmp.i.i55.i.i.i, label %if.then.i6.i61.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread.i.i.i: ; preds = %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i.i.i.i
  %12 = bitcast i8** %buffer.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %12) #8, !noalias !16
  br label %if.then.i10.i64.i.i.i

if.then.i6.i61.i.i.i:                             ; preds = %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i.i.i.i
  store i8 -128, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !16
  %call.i.i.i.i.i.i76.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.i.noexc75.i.i.i unwind label %lpad.i.i.i.i.i

call.i.i.i.i.i.i.noexc75.i.i.i:                   ; preds = %if.then.i6.i61.i.i.i
  %add.i.i.i.i.i.i.i = add nsw i64 %idx.ext.i.i.i.i, 8
  %call2.i.i.i.i.i.i78.i.i.i = invoke i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i.i76.i.i.i, i64 %add.i.i.i.i.i.i.i)
          to label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i unwind label %lpad.i.i.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i: ; preds = %call.i.i.i.i.i.i.noexc75.i.i.i
  %capacity.i.i.i3.i.i57.i.i.i = bitcast i8* %call2.i.i.i.i.i.i78.i.i.i to i64*
  store i64 %idx.ext.i.i.i.i, i64* %capacity.i.i.i3.i.i57.i.i.i, align 8, !tbaa !25
  %13 = bitcast %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i to i8**
  store i8* %call2.i.i.i.i.i.i78.i.i.i, i8** %13, align 2, !tbaa.struct !27, !noalias !16
  %ref.tmp.sroa.4.0..sroa_idx5.i.i58.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast6.i.i59.i.i.i = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i58.i.i.i to i48*
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i59.i.i.i, align 2, !tbaa.struct !27, !noalias !16
  %bf.load.i.i8.pre.i60.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !16
  %14 = bitcast i8** %buffer.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %14) #8, !noalias !16
  %cmp.i.i9.i63.i.i.i = icmp sgt i8 %bf.load.i.i8.pre.i60.i.i.i, -1
  br i1 %cmp.i.i9.i63.i.i.i, label %if.then.i10.i64.i.i.i, label %if.else.i11.i66.i.i.i

if.then.i10.i64.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread.i.i.i
  %15 = phi i8* [ %12, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread.i.i.i ], [ %14, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i ]
  %16 = bitcast %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i to i8*
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i

if.else.i11.i66.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i
  %17 = getelementptr inbounds i8, i8* %call2.i.i.i.i.i.i78.i.i.i, i64 8
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i: ; preds = %if.else.i11.i66.i.i.i, %if.then.i10.i64.i.i.i
  %18 = phi i8* [ %15, %if.then.i10.i64.i.i.i ], [ %14, %if.else.i11.i66.i.i.i ]
  %retval.0.i.i67.i.i.i = phi i8* [ %16, %if.then.i10.i64.i.i.i ], [ %17, %if.else.i11.i66.i.i.i ]
  store i8* %retval.0.i.i67.i.i.i, i8** %buffer.i.i.i.i, align 8, !tbaa !2, !noalias !16
  %19 = getelementptr inbounds %class.anon.92, %class.anon.92* %agg.tmp.i.i.i.i, i64 0, i32 0
  store %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i, %"class.parlay::sequence"** %19, align 8, !tbaa !29, !noalias !16
  %20 = getelementptr inbounds %class.anon.92, %class.anon.92* %agg.tmp.i.i.i.i, i64 0, i32 1
  store i8** %buffer.i.i.i.i, i8*** %20, align 8, !tbaa !2, !noalias !16
  %21 = getelementptr inbounds %class.anon.92, %class.anon.92* %agg.tmp.i.i.i.i, i64 0, i32 2
  store i8** %first.addr.i.i.i.i, i8*** %21, align 8, !tbaa !2, !noalias !16
  invoke void @_ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb(i64 0, i64 %idx.ext.i.i.i.i, %class.anon.92* nonnull byval(%class.anon.92) align 8 %agg.tmp.i.i.i.i, i64 8193, i1 zeroext false)
          to label %.noexc79.i.i.i unwind label %lpad.i.i.i.i.i, !noalias !16

.noexc79.i.i.i:                                   ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i
  %bf.load.i.i.i68.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !16
  %cmp.i.i.i69.i.i.i = icmp sgt i8 %bf.load.i.i.i68.i.i.i, -1
  br i1 %cmp.i.i.i69.i.i.i, label %if.then.i.i72.i.i.i, label %if.else.i.i74.i.i.i

if.then.i.i72.i.i.i:                              ; preds = %.noexc79.i.i.i
  %conv.i.i.i.i.i = trunc i32 %.sroa.speculated.i.i.i.i to i8
  %bf.value.i.i.i.i.i = and i8 %conv.i.i.i.i.i, 127
  %bf.clear.i.i70.i.i.i = and i8 %bf.load.i.i.i68.i.i.i, -128
  %bf.set.i.i71.i.i.i = or i8 %bf.clear.i.i70.i.i.i, %bf.value.i.i.i.i.i
  store i8 %bf.set.i.i71.i.i.i, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !16
  br label %invoke.cont4.i.i.i

if.else.i.i74.i.i.i:                              ; preds = %.noexc79.i.i.i
  %n.i.i.i73.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %22 = bitcast [6 x i8]* %n.i.i.i73.i.i.i to i48*
  %23 = sext i32 %.sroa.speculated.i.i.i.i to i48
  store i48 %23, i48* %22, align 2, !noalias !16
  br label %invoke.cont4.i.i.i

lpad.i.i.i.i.i:                                   ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i, %call.i.i.i.i.i.i.noexc75.i.i.i, %if.then.i6.i61.i.i.i
  %24 = landingpad { i8*, i32 }
          cleanup
  %25 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  %26 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  %arrayinit.begin.i.i.i.le = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0
  %bf.load.i.i.i.i.i.i.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !alias.scope !24, !noalias !16
  %cmp.i.i.i.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i.i.i.i, label %lpad.body.thread.i.i.i, label %if.then.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i:                          ; preds = %lpad.i.i.i.i.i
  %buffer.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %27 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i.i.i, align 2, !tbaa !31, !alias.scope !24, !noalias !16
  %capacity.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %27, i64 0, i32 0
  %28 = load i64, i64* %capacity.i.i.i.i.i.i.i.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i.i.i.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i unwind label %lpad.i.i.i.i.i.i.i

call.i.i.i.i.i.noexc.i.i.i.i.i.i.i:               ; preds = %if.then.i.i.i.i.i.i.i.i
  %29 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %27 to i8*
  %add.i.i.i.i.i.i.i.i.i.i = add i64 %28, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.i.i.i.i.i, i8* %29, i64 %add.i.i.i.i.i.i.i.i.i.i)
          to label %.noexc.i.i.i.i.i.i.i unwind label %lpad.i.i.i.i.i.i.i

.noexc.i.i.i.i.i.i.i:                             ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i.i.i, align 2, !tbaa !31, !alias.scope !24, !noalias !16
  br label %lpad.body.thread.i.i.i

lpad.i.i.i.i.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i, %if.then.i.i.i.i.i.i.i.i
  %30 = landingpad { i8*, i32 }
          catch i8* null
  %31 = extractvalue { i8*, i32 } %30, 0
  call void @__clang_call_terminate(i8* %31) #9
  unreachable

lpad.body.thread.i.i.i:                           ; preds = %.noexc.i.i.i.i.i.i.i, %lpad.i.i.i.i.i
  store i8 0, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !alias.scope !24, !noalias !16
  br label %arraydestroy.body.preheader.i.i.i

invoke.cont4.i.i.i:                               ; preds = %if.else.i.i74.i.i.i, %if.then.i.i72.i.i.i
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %18) #8, !noalias !16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %10), !noalias !16
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %11), !noalias !16
  call void @llvm.lifetime.end.p0i8(i64 22, i8* nonnull %9) #8, !noalias !21
  %32 = getelementptr inbounds %class.anon.27, %class.anon.27* %.idx.val.i, i64 0, i32 1
  %33 = load %"class.parlay::sequence"*, %"class.parlay::sequence"** %32, align 8, !tbaa !33, !noalias !16
  %impl.i4.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %33, i64 0, i32 0, i32 0
  %impl.i.i5.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i5.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i4.i.i.i)
          to label %if.then.i6.i.i.i.i unwind label %lpad.body.thread89.i.i.i, !noalias !16

if.then.i6.i.i.i.i:                               ; preds = %invoke.cont4.i.i.i
  %small_n.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 -128, i8* %small_n.i.i.i.i.i.i.i, align 2, !noalias !16
  %call.i.i.i.i.i.i12.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.i.noexc.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i, !noalias !16

call.i.i.i.i.i.i.noexc.i.i.i:                     ; preds = %if.then.i6.i.i.i.i
  %call2.i.i.i.i.i.i13.i.i.i = invoke i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i.i12.i.i.i, i64 68)
          to label %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i, !noalias !16

_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i: ; preds = %call.i.i.i.i.i.i.noexc.i.i.i
  %capacity.i.i.i3.i.i.i.i.i = bitcast i8* %call2.i.i.i.i.i.i13.i.i.i to i64*
  store i64 4, i64* %capacity.i.i.i3.i.i.i.i.i, align 8, !tbaa !34, !noalias !16
  %34 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8**
  store i8* %call2.i.i.i.i.i.i13.i.i.i, i8** %34, align 8, !tbaa.struct !27, !noalias !16
  %ref.tmp.sroa.4.0..sroa_idx5.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i.i = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i.i.i.i to i48*
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i.i, align 8, !tbaa.struct !27, !noalias !16
  %bf.load.i.i8.pre.i.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i, align 2, !noalias !16
  %cmp.i.i9.i.i.i.i = icmp sgt i8 %bf.load.i.i8.pre.i.i.i.i, -1
  %35 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to %"class.parlay::sequence"*
  %data.i.i.i.i.i.i.i.i = getelementptr inbounds i8, i8* %call2.i.i.i.i.i.i13.i.i.i, i64 8
  %36 = bitcast i8* %data.i.i.i.i.i.i.i.i to %"class.parlay::sequence"*
  %retval.0.i.i.i.i.i = select i1 %cmp.i.i9.i.i.i.i, %"class.parlay::sequence"* %35, %"class.parlay::sequence"* %36
  detach within %syncreg19.i.i.i.i.i, label %pfor.body.i.i.i.i.i, label %pfor.inc.i.i.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i

pfor.body.i.i.i.i.i:                              ; preds = %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i
  %impl.i.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i.i.i.i, i64 0, i32 0, i32 0
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i2.i.i)
          to label %.noexc.i.i.i unwind label %lpad.i10.i.i.i

.noexc.i.i.i:                                     ; preds = %pfor.body.i.i.i.i.i
  reattach within %syncreg19.i.i.i.i.i, label %pfor.inc.i.i.i.i.i

pfor.inc.i.i.i.i.i:                               ; preds = %.noexc.i.i.i, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i
  detach within %syncreg19.i.i.i.i.i, label %pfor.body.i.i.1.i.i.i, label %pfor.inc.i.i.1.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i

sync.continue.i.i.i.i.i:                          ; preds = %pfor.inc.i.i.3.i.i.i
  invoke void @llvm.sync.unwind(token %syncreg19.i.i.i.i.i)
          to label %.noexc11.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i, !noalias !16

.noexc11.i.i.i:                                   ; preds = %sync.continue.i.i.i.i.i
  %bf.load.i.i.i.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i, align 2, !noalias !16
  %cmp.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i, label %if.then.i.i.i.i.i, label %if.else.i.i.i.i.i

if.then.i.i.i.i.i:                                ; preds = %.noexc11.i.i.i
  %bf.clear.i.i.i.i.i = and i8 %bf.load.i.i.i.i.i.i, -128
  %bf.set.i.i.i.i.i = or i8 %bf.clear.i.i.i.i.i, 4
  store i8 %bf.set.i.i.i.i.i, i8* %small_n.i.i.i.i.i.i.i, align 2, !noalias !16
  br label %invoke.cont9.i.i.i

if.else.i.i.i.i.i:                                ; preds = %.noexc11.i.i.i
  store i48 4, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i.i, align 8, !noalias !16
  br label %invoke.cont9.i.i.i

lpad.i.unreachable.i.i.i:                         ; preds = %lpad.i10.i.i.i
  unreachable

lpad.i10.i.i.i:                                   ; preds = %pfor.body.i.i.3.i.i.i, %pfor.body.i.i.2.i.i.i, %pfor.body.i.i.1.i.i.i, %pfor.body.i.i.i.i.i
  %37 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg19.i.i.i.i.i, { i8*, i32 } %37)
          to label %lpad.i.unreachable.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i, !noalias !16

lpad.i.loopexit.split-lp.i.i.i:                   ; preds = %pfor.inc.i.i.2.i.i.i, %pfor.inc.i.i.1.i.i.i, %lpad.i10.i.i.i, %sync.continue.i.i.i.i.i, %pfor.inc.i.i.i.i.i, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i, %call.i.i.i.i.i.i.noexc.i.i.i, %if.then.i6.i.i.i.i
  %lpad.loopexit.split-lp.i.i.i = landingpad { i8*, i32 }
          cleanup
  %38 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  %39 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  %impl.i.i7.i.i.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0, i32 0
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev(%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl"* nonnull %impl.i.i7.i.i.i) #8
  %flag.i.i.i.i33.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i34.i.i.i = load i8, i8* %flag.i.i.i.i33.i.i.i, align 1, !noalias !16
  %cmp.i.i.i.i35.i.i.i = icmp sgt i8 %bf.load.i.i.i.i34.i.i.i, -1
  br i1 %cmp.i.i.i.i35.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.i.i.i, label %if.then.i.i.i39.i.i.i

invoke.cont9.i.i.i:                               ; preds = %if.else.i.i.i.i.i, %if.then.i.i.i.i.i
  %flag.i.i.i.i14.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i15.i.i.i = load i8, i8* %flag.i.i.i.i14.i.i.i, align 1, !noalias !16
  %cmp.i.i.i.i16.i.i.i = icmp sgt i8 %bf.load.i.i.i.i15.i.i.i, -1
  br i1 %cmp.i.i.i.i16.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i, label %if.then.i.i.i.i.i.i

if.then.i.i.i.i.i.i:                              ; preds = %invoke.cont9.i.i.i
  %buffer.i.i.i.i17.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %40 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i17.i.i.i, align 1, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i18.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %40, i64 0, i32 0
  %41 = load i64, i64* %capacity.i.i.i.i.i18.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i.i.i unwind label %lpad.i.i19.i.i.i

call.i.i.i.i.i.noexc.i.i.i.i.i:                   ; preds = %if.then.i.i.i.i.i.i
  %42 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %40 to i8*
  %add.i.i.i.i.i.i.i.i = add i64 %41, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.i.i.i, i8* %42, i64 %add.i.i.i.i.i.i.i.i)
          to label %.noexc.i.i.i.i.i unwind label %lpad.i.i19.i.i.i

.noexc.i.i.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i17.i.i.i, align 1, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i

lpad.i.i19.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i.3.i.i.i, %if.then.i.i.i.3.i.i.i, %call.i.i.i.i.i.noexc.i.i.2.i.i.i, %if.then.i.i.i.2.i.i.i, %call.i.i.i.i.i.noexc.i.i.1.i.i.i, %if.then.i.i.i.1.i.i.i, %call.i.i.i.i.i.noexc.i.i.i.i.i, %if.then.i.i.i.i.i.i
  %43 = landingpad { i8*, i32 }
          catch i8* null
  %44 = extractvalue { i8*, i32 } %43, 0
  call void @__clang_call_terminate(i8* %44) #9
  unreachable

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i: ; preds = %.noexc.i.i.i.i.i, %invoke.cont9.i.i.i
  store i8 0, i8* %flag.i.i.i.i14.i.i.i, align 1, !noalias !16
  %bf.load.i.i.i.i15.1.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !16
  %cmp.i.i.i.i16.1.i.i.i = icmp sgt i8 %bf.load.i.i.i.i15.1.i.i.i, -1
  br i1 %cmp.i.i.i.i16.1.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i, label %if.then.i.i.i.1.i.i.i

lpad.body.thread89.i.i.i:                         ; preds = %invoke.cont4.i.i.i, %invoke.cont.i.i.i
  %arrayinit.endOfInit.0.idx.ph.i.i.i = phi i64 [ 3, %invoke.cont4.i.i.i ], [ 1, %invoke.cont.i.i.i ]
  %lpad.thr_comm.i.i.i = landingpad { i8*, i32 }
          cleanup
  %45 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  %46 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  %arrayinit.begin.i.i.i.le51 = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0
  br label %arraydestroy.body.preheader.i.i.i

lpad.body.i.i.i:                                  ; preds = %pfor.body.tf.tf.tf
  %lpad.thr_comm.split-lp.i.i.i = landingpad { i8*, i32 }
          cleanup
  %47 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  %48 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  br label %ehcleanup.i.i.i

arraydestroy.body.preheader.i.i.i:                ; preds = %lpad.body.thread89.i.i.i, %lpad.body.thread.i.i.i
  %49 = phi i8* [ %25, %lpad.body.thread.i.i.i ], [ %45, %lpad.body.thread89.i.i.i ]
  %50 = phi i8* [ %26, %lpad.body.thread.i.i.i ], [ %46, %lpad.body.thread89.i.i.i ]
  %arrayinit.begin.i.i.i29 = phi %"class.parlay::sequence"* [ %arrayinit.begin.i.i.i.le, %lpad.body.thread.i.i.i ], [ %arrayinit.begin.i.i.i.le51, %lpad.body.thread89.i.i.i ]
  %arrayinit.endOfInit.0.idx.lpad-body87.i.i.i = phi i64 [ 2, %lpad.body.thread.i.i.i ], [ %arrayinit.endOfInit.0.idx.ph.i.i.i, %lpad.body.thread89.i.i.i ]
  %arrayinit.endOfInit.0.ptr.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 %arrayinit.endOfInit.0.idx.lpad-body87.i.i.i
  br label %arraydestroy.body.i.i.i

arraydestroy.body.i.i.i:                          ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit32.i.i.i, %arraydestroy.body.preheader.i.i.i
  %arraydestroy.elementPast.i.i.i = phi %"class.parlay::sequence"* [ %arraydestroy.element.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit32.i.i.i ], [ %arrayinit.endOfInit.0.ptr.i.i.i, %arraydestroy.body.preheader.i.i.i ]
  %arraydestroy.element.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.elementPast.i.i.i, i64 -1
  %flag.i.i.i.i21.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.elementPast.i.i.i, i64 -1, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i22.i.i.i = load i8, i8* %flag.i.i.i.i21.i.i.i, align 1, !noalias !16
  %cmp.i.i.i.i23.i.i.i = icmp sgt i8 %bf.load.i.i.i.i22.i.i.i, -1
  br i1 %cmp.i.i.i.i23.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit32.i.i.i, label %if.then.i.i.i27.i.i.i

if.then.i.i.i27.i.i.i:                            ; preds = %arraydestroy.body.i.i.i
  %buffer.i.i.i.i24.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.element.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %51 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i24.i.i.i, align 1, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i25.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %51, i64 0, i32 0
  %52 = load i64, i64* %capacity.i.i.i.i.i25.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i26.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i29.i.i.i unwind label %lpad.i.i31.i.i.i

; CHECK: if.then.i.i.i27.i.i.i:
; CHECK: call void @__csan_before_call(i64 %[[CALL_ID1:[a-zA-Z0-9._]+]], i64
; CHECK-NEXT: invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
; CHECK-NEXT: to label %call.i.i.i.i.i.noexc.i.i29.i.i.i unwind label %lpad.i.i31.i.i.i

call.i.i.i.i.i.noexc.i.i29.i.i.i:                 ; preds = %if.then.i.i.i27.i.i.i
  %53 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %51 to i8*
  %add.i.i.i.i.i28.i.i.i = add i64 %52, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i26.i.i.i, i8* %53, i64 %add.i.i.i.i.i28.i.i.i)
          to label %.noexc.i.i30.i.i.i unwind label %lpad.i.i31.i.i.i

; CHECK: call.i.i.i.i.i.noexc.i.i29.i.i.i:
; CHECK: call void @__csan_after_call(i64 %[[CALL_ID1]], i64
; CHECK: call void @__csan_before_call(i64 %[[CALL_ID2:[a-zA-Z0-9._]+]], i64
; CHECK: invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(
; CHECK-NEXT: to label %.noexc.i.i30.i.i.i unwind label %lpad.i.i31.i.i.i

.noexc.i.i30.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i29.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i24.i.i.i, align 1, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit32.i.i.i

; CHECK: .noexc.i.i30.i.i.i:
; CHECK: call void @__csan_after_call(i64 %[[CALL_ID2]], i64

lpad.i.i31.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i29.i.i.i, %if.then.i.i.i27.i.i.i
  %54 = landingpad { i8*, i32 }
          catch i8* null
  %55 = extractvalue { i8*, i32 } %54, 0
  call void @__clang_call_terminate(i8* %55) #9
  unreachable

; CHECK: lpad.i.i31.i.i.i:
; CHECK: %[[CALL_ID_PHI:.+]] = phi i64 [ %[[CALL_ID2]], %call.i.i.i.i.i.noexc.i.i29.i.i.i ], [ %[[CALL_ID1]], %{{.+}} ]
; CHECK: landingpad
; CHECK-NEXT: catch i8* null
; CHECK-NEXT: call void @__csan_after_call(i64 %[[CALL_ID_PHI]],

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit32.i.i.i: ; preds = %.noexc.i.i30.i.i.i, %arraydestroy.body.i.i.i
  store i8 0, i8* %flag.i.i.i.i21.i.i.i, align 1, !noalias !16
  %arraydestroy.done.i.i.i = icmp eq %"class.parlay::sequence"* %arraydestroy.element.i.i.i, %arrayinit.begin.i.i.i29
  br i1 %arraydestroy.done.i.i.i, label %ehcleanup.i.i.i, label %arraydestroy.body.i.i.i

if.then.i.i.i39.i.i.i:                            ; preds = %lpad.i.loopexit.split-lp.i.i.i
  %buffer.i.i.i.i36.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %56 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i36.i.i.i, align 1, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i37.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %56, i64 0, i32 0
  %57 = load i64, i64* %capacity.i.i.i.i.i37.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i38.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i41.i.i.i unwind label %lpad.i.i43.i.i.i

call.i.i.i.i.i.noexc.i.i41.i.i.i:                 ; preds = %if.then.i.i.i39.i.i.i
  %58 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %56 to i8*
  %add.i.i.i.i.i40.i.i.i = add i64 %57, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i38.i.i.i, i8* %58, i64 %add.i.i.i.i.i40.i.i.i)
          to label %.noexc.i.i42.i.i.i unwind label %lpad.i.i43.i.i.i

.noexc.i.i42.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i41.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i36.i.i.i, align 1, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.i.i.i

lpad.i.i43.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i41.3.i.i.i, %if.then.i.i.i39.3.i.i.i, %call.i.i.i.i.i.noexc.i.i41.2.i.i.i, %if.then.i.i.i39.2.i.i.i, %call.i.i.i.i.i.noexc.i.i41.1.i.i.i, %if.then.i.i.i39.1.i.i.i, %call.i.i.i.i.i.noexc.i.i41.i.i.i, %if.then.i.i.i39.i.i.i
  %59 = landingpad { i8*, i32 }
          catch i8* null
  %60 = extractvalue { i8*, i32 } %59, 0
  call void @__clang_call_terminate(i8* %60) #9
  unreachable

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.i.i.i: ; preds = %.noexc.i.i42.i.i.i, %lpad.i.loopexit.split-lp.i.i.i
  store i8 0, i8* %flag.i.i.i.i33.i.i.i, align 1, !noalias !16
  %bf.load.i.i.i.i34.1.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !16
  %cmp.i.i.i.i35.1.i.i.i = icmp sgt i8 %bf.load.i.i.i.i34.1.i.i.i, -1
  br i1 %cmp.i.i.i.i35.1.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.1.i.i.i, label %if.then.i.i.i39.1.i.i.i

ehcleanup.i.i.i:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.3.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit32.i.i.i, %lpad.body.i.i.i
  %61 = phi i8* [ %38, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.3.i.i.i ], [ %47, %lpad.body.i.i.i ], [ %49, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit32.i.i.i ]
  %62 = phi i8* [ %39, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.3.i.i.i ], [ %48, %lpad.body.i.i.i ], [ %50, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit32.i.i.i ]
  call void @llvm.lifetime.end.p0i8(i64 60, i8* nonnull %62) #8, !noalias !16
  br label %ehcleanup24.i.i.i

lpad21.i.i.i:                                     ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i
  %63 = landingpad { i8*, i32 }
          cleanup
  %64 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  %impl.i45.i.i.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0, i32 0
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev(%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl"* nonnull %impl.i45.i.i.i) #8
  br label %ehcleanup24.i.i.i

ehcleanup24.i.i.i:                                ; preds = %lpad21.i.i.i, %ehcleanup.i.i.i
  %65 = phi i8* [ %64, %lpad21.i.i.i ], [ %61, %ehcleanup.i.i.i ]
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %65) #8, !noalias !16
  %flag.i.i.i.i.i11.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i12.i.i = load i8, i8* %flag.i.i.i.i.i11.i.i, align 2, !noalias !13
  %cmp.i.i.i.i.i13.i.i = icmp slt i8 %bf.load.i.i.i.i.i12.i.i, 0
  call void @llvm.assume(i1 %cmp.i.i.i.i.i13.i.i)
  %buffer.i.i.i.i.i14.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %66 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i14.i.i, align 8, !tbaa !31, !noalias !13
  %capacity.i.i.i.i.i.i15.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %66, i64 0, i32 0
  %67 = load i64, i64* %capacity.i.i.i.i.i.i15.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i.i16.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i19.i.i unwind label %lpad.i.i.i21.i.i

if.then.i.i.i.1.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i
  %buffer.i.i.i.i17.1.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %68 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i17.1.i.i.i, align 2, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i18.1.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %68, i64 0, i32 0
  %69 = load i64, i64* %capacity.i.i.i.i.i18.1.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i.1.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.1.i.i.i unwind label %lpad.i.i19.i.i.i

call.i.i.i.i.i.noexc.i.i.1.i.i.i:                 ; preds = %if.then.i.i.i.1.i.i.i
  %70 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %68 to i8*
  %add.i.i.i.i.i.1.i.i.i = add i64 %69, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.1.i.i.i, i8* %70, i64 %add.i.i.i.i.i.1.i.i.i)
          to label %.noexc.i.i.1.i.i.i unwind label %lpad.i.i19.i.i.i

.noexc.i.i.1.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.1.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i17.1.i.i.i, align 2, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i: ; preds = %.noexc.i.i.1.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i
  store i8 0, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !16
  %flag.i.i.i.i14.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i15.2.i.i.i = load i8, i8* %flag.i.i.i.i14.2.i.i.i, align 1, !noalias !16
  %cmp.i.i.i.i16.2.i.i.i = icmp sgt i8 %bf.load.i.i.i.i15.2.i.i.i, -1
  br i1 %cmp.i.i.i.i16.2.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i, label %if.then.i.i.i.2.i.i.i

if.then.i.i.i.2.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i
  %buffer.i.i.i.i17.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %71 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i17.2.i.i.i, align 1, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i18.2.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %71, i64 0, i32 0
  %72 = load i64, i64* %capacity.i.i.i.i.i18.2.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i.2.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.2.i.i.i unwind label %lpad.i.i19.i.i.i

call.i.i.i.i.i.noexc.i.i.2.i.i.i:                 ; preds = %if.then.i.i.i.2.i.i.i
  %73 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %71 to i8*
  %add.i.i.i.i.i.2.i.i.i = add i64 %72, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.2.i.i.i, i8* %73, i64 %add.i.i.i.i.i.2.i.i.i)
          to label %.noexc.i.i.2.i.i.i unwind label %lpad.i.i19.i.i.i

.noexc.i.i.2.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.2.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i17.2.i.i.i, align 1, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i: ; preds = %.noexc.i.i.2.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i
  store i8 0, i8* %flag.i.i.i.i14.2.i.i.i, align 1, !noalias !16
  %flag.i.i.i.i14.3.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i15.3.i.i.i = load i8, i8* %flag.i.i.i.i14.3.i.i.i, align 2, !noalias !16
  %cmp.i.i.i.i16.3.i.i.i = icmp sgt i8 %bf.load.i.i.i.i15.3.i.i.i, -1
  br i1 %cmp.i.i.i.i16.3.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i, label %if.then.i.i.i.3.i.i.i

if.then.i.i.i.3.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i
  %buffer.i.i.i.i17.3.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %74 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i17.3.i.i.i, align 8, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i18.3.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %74, i64 0, i32 0
  %75 = load i64, i64* %capacity.i.i.i.i.i18.3.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i.3.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.3.i.i.i unwind label %lpad.i.i19.i.i.i

call.i.i.i.i.i.noexc.i.i.3.i.i.i:                 ; preds = %if.then.i.i.i.3.i.i.i
  %76 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %74 to i8*
  %add.i.i.i.i.i.3.i.i.i = add i64 %75, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.3.i.i.i, i8* %76, i64 %add.i.i.i.i.i.3.i.i.i)
          to label %.noexc.i.i.3.i.i.i unwind label %lpad.i.i19.i.i.i

.noexc.i.i.3.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.3.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i17.3.i.i.i, align 8, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i: ; preds = %.noexc.i.i.3.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i
  call void @llvm.lifetime.end.p0i8(i64 60, i8* nonnull %5) #8, !noalias !16
  invoke void @_ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_(%"class.parlay::sequence"* nonnull sret %ref.tmp.i, %"class.parlay::sequence.2"* nonnull dereferenceable(15) %s.i.i.i)
          to label %invoke.cont.i.i unwind label %lpad21.i.i.i

if.then.i.i.i39.1.i.i.i:                          ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.i.i.i
  %buffer.i.i.i.i36.1.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %77 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i36.1.i.i.i, align 2, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i37.1.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %77, i64 0, i32 0
  %78 = load i64, i64* %capacity.i.i.i.i.i37.1.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i38.1.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i41.1.i.i.i unwind label %lpad.i.i43.i.i.i

call.i.i.i.i.i.noexc.i.i41.1.i.i.i:               ; preds = %if.then.i.i.i39.1.i.i.i
  %79 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %77 to i8*
  %add.i.i.i.i.i40.1.i.i.i = add i64 %78, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i38.1.i.i.i, i8* %79, i64 %add.i.i.i.i.i40.1.i.i.i)
          to label %.noexc.i.i42.1.i.i.i unwind label %lpad.i.i43.i.i.i

.noexc.i.i42.1.i.i.i:                             ; preds = %call.i.i.i.i.i.noexc.i.i41.1.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i36.1.i.i.i, align 2, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.1.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.1.i.i.i: ; preds = %.noexc.i.i42.1.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.i.i.i
  store i8 0, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !16
  %flag.i.i.i.i33.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i34.2.i.i.i = load i8, i8* %flag.i.i.i.i33.2.i.i.i, align 1, !noalias !16
  %cmp.i.i.i.i35.2.i.i.i = icmp sgt i8 %bf.load.i.i.i.i34.2.i.i.i, -1
  br i1 %cmp.i.i.i.i35.2.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.2.i.i.i, label %if.then.i.i.i39.2.i.i.i

if.then.i.i.i39.2.i.i.i:                          ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.1.i.i.i
  %buffer.i.i.i.i36.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %80 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i36.2.i.i.i, align 1, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i37.2.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %80, i64 0, i32 0
  %81 = load i64, i64* %capacity.i.i.i.i.i37.2.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i38.2.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i41.2.i.i.i unwind label %lpad.i.i43.i.i.i

call.i.i.i.i.i.noexc.i.i41.2.i.i.i:               ; preds = %if.then.i.i.i39.2.i.i.i
  %82 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %80 to i8*
  %add.i.i.i.i.i40.2.i.i.i = add i64 %81, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i38.2.i.i.i, i8* %82, i64 %add.i.i.i.i.i40.2.i.i.i)
          to label %.noexc.i.i42.2.i.i.i unwind label %lpad.i.i43.i.i.i

.noexc.i.i42.2.i.i.i:                             ; preds = %call.i.i.i.i.i.noexc.i.i41.2.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i36.2.i.i.i, align 1, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.2.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.2.i.i.i: ; preds = %.noexc.i.i42.2.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.1.i.i.i
  store i8 0, i8* %flag.i.i.i.i33.2.i.i.i, align 1, !noalias !16
  %flag.i.i.i.i33.3.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i34.3.i.i.i = load i8, i8* %flag.i.i.i.i33.3.i.i.i, align 2, !noalias !16
  %cmp.i.i.i.i35.3.i.i.i = icmp sgt i8 %bf.load.i.i.i.i34.3.i.i.i, -1
  br i1 %cmp.i.i.i.i35.3.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.3.i.i.i, label %if.then.i.i.i39.3.i.i.i

if.then.i.i.i39.3.i.i.i:                          ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.2.i.i.i
  %buffer.i.i.i.i36.3.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %83 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i36.3.i.i.i, align 8, !tbaa !31, !noalias !16
  %capacity.i.i.i.i.i37.3.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %83, i64 0, i32 0
  %84 = load i64, i64* %capacity.i.i.i.i.i37.3.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i38.3.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i41.3.i.i.i unwind label %lpad.i.i43.i.i.i

call.i.i.i.i.i.noexc.i.i41.3.i.i.i:               ; preds = %if.then.i.i.i39.3.i.i.i
  %85 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %83 to i8*
  %add.i.i.i.i.i40.3.i.i.i = add i64 %84, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i38.3.i.i.i, i8* %85, i64 %add.i.i.i.i.i40.3.i.i.i)
          to label %.noexc.i.i42.3.i.i.i unwind label %lpad.i.i43.i.i.i

.noexc.i.i42.3.i.i.i:                             ; preds = %call.i.i.i.i.i.noexc.i.i41.3.i.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i36.3.i.i.i, align 8, !tbaa !31, !noalias !16
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.3.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.3.i.i.i: ; preds = %.noexc.i.i42.3.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit44.2.i.i.i
  store i8 0, i8* %flag.i.i.i.i33.3.i.i.i, align 2, !noalias !16
  br label %ehcleanup.i.i.i

pfor.body.i.i.1.i.i.i:                            ; preds = %pfor.inc.i.i.i.i.i
  %impl.i.i.i.i.i.i.i.i.1.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i.i.i.i, i64 1, i32 0, i32 0
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.1.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i2.i.i.i)
          to label %.noexc.1.i.i.i unwind label %lpad.i10.i.i.i

.noexc.1.i.i.i:                                   ; preds = %pfor.body.i.i.1.i.i.i
  reattach within %syncreg19.i.i.i.i.i, label %pfor.inc.i.i.1.i.i.i

pfor.inc.i.i.1.i.i.i:                             ; preds = %.noexc.1.i.i.i, %pfor.inc.i.i.i.i.i
  detach within %syncreg19.i.i.i.i.i, label %pfor.body.i.i.2.i.i.i, label %pfor.inc.i.i.2.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i

pfor.body.i.i.2.i.i.i:                            ; preds = %pfor.inc.i.i.1.i.i.i
  %impl.i.i.i.i.i.i.i.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0
  %impl.i.i.i.i.i.i.i.i.2.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i.i.i.i, i64 2, i32 0, i32 0
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.2.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i.i.i.2.i.i.i)
          to label %.noexc.2.i.i.i unwind label %lpad.i10.i.i.i

.noexc.2.i.i.i:                                   ; preds = %pfor.body.i.i.2.i.i.i
  reattach within %syncreg19.i.i.i.i.i, label %pfor.inc.i.i.2.i.i.i

pfor.inc.i.i.2.i.i.i:                             ; preds = %.noexc.2.i.i.i, %pfor.inc.i.i.1.i.i.i
  detach within %syncreg19.i.i.i.i.i, label %pfor.body.i.i.3.i.i.i, label %pfor.inc.i.i.3.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i

pfor.body.i.i.3.i.i.i:                            ; preds = %pfor.inc.i.i.2.i.i.i
  %impl.i.i.i.i.i.i.i.i.3.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i.i.i.i, i64 3, i32 0, i32 0
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.3.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i5.i.i.i)
          to label %.noexc.3.i.i.i unwind label %lpad.i10.i.i.i

.noexc.3.i.i.i:                                   ; preds = %pfor.body.i.i.3.i.i.i
  reattach within %syncreg19.i.i.i.i.i, label %pfor.inc.i.i.3.i.i.i

pfor.inc.i.i.3.i.i.i:                             ; preds = %.noexc.3.i.i.i, %pfor.inc.i.i.2.i.i.i
  sync within %syncreg19.i.i.i.i.i, label %sync.continue.i.i.i.i.i

invoke.cont.i.i:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i
  %impl.i20.i.i.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0, i32 0
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev(%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl"* nonnull %impl.i20.i.i.i) #8
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %4) #8, !noalias !16
  %flag.i.i.i.i.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i.i.i = load i8, i8* %flag.i.i.i.i.i.i.i, align 2, !noalias !13
  %cmp.i.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i.i, label %"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm.exit", label %if.then.i.i.i.i5.i.i

if.then.i.i.i.i5.i.i:                             ; preds = %invoke.cont.i.i
  %buffer.i.i.i.i.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %86 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i, align 8, !tbaa !31, !noalias !13
  %capacity.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %86, i64 0, i32 0
  %87 = load i64, i64* %capacity.i.i.i.i.i.i.i.i, align 8, !tbaa !25
  %call.i.i.i.i.i1.i.i.i4.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i7.i.i unwind label %lpad.i.i.i9.i.i

call.i.i.i.i.i.noexc.i.i.i7.i.i:                  ; preds = %if.then.i.i.i.i5.i.i
  %88 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %86 to i8*
  %add.i.i.i.i.i.i6.i.i = add i64 %87, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.i4.i.i, i8* %88, i64 %add.i.i.i.i.i.i6.i.i)
          to label %.noexc.i.i.i8.i.i unwind label %lpad.i.i.i9.i.i

.noexc.i.i.i8.i.i:                                ; preds = %call.i.i.i.i.i.noexc.i.i.i7.i.i
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i, align 8, !tbaa !31, !noalias !13
  br label %"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm.exit"

lpad.i.i.i9.i.i:                                  ; preds = %call.i.i.i.i.i.noexc.i.i.i7.i.i, %if.then.i.i.i.i5.i.i
  %89 = landingpad { i8*, i32 }
          catch i8* null
  %90 = extractvalue { i8*, i32 } %89, 0
  call void @__clang_call_terminate(i8* %90) #9
  unreachable

call.i.i.i.i.i.noexc.i.i.i19.i.i:                 ; preds = %ehcleanup24.i.i.i
  %91 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %66 to i8*
  %add.i.i.i.i.i.i18.i.i = add i64 %67, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.i16.i.i, i8* %91, i64 %add.i.i.i.i.i.i18.i.i)
          to label %.noexc.i.i.i20.i.i unwind label %lpad.i.i.i21.i.i

.noexc.i.i.i20.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.i19.i.i
  unreachable

lpad.i.i.i21.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i.i19.i.i, %ehcleanup24.i.i.i
  %92 = landingpad { i8*, i32 }
          catch i8* null
  %93 = extractvalue { i8*, i32 } %92, 0
  call void @__clang_call_terminate(i8* %93) #9
  unreachable

"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm.exit": ; preds = %.noexc.i.i.i8.i.i, %invoke.cont.i.i
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %2)
  %small_n.i.i.i.i.i.i.i3.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %0, i64 %__begin.0, i32 0, i32 0, i32 0, i32 1
  store i8 0, i8* %small_n.i.i.i.i.i.i.i3.i, align 1
  %94 = bitcast %"class.parlay::sequence"* %arrayidx.i to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(15) %94, i8* nonnull align 8 dereferenceable(15) %1, i64 15, i1 false) #8
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %1) #8
  call void @llvm.taskframe.end(token %tf.i)
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm.exit", %pfor.cond
  %inc = add nuw i64 %__begin.0, 1
  %exitcond = icmp eq i64 %inc, %end
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !36

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg)
  br label %sync.continue23

sync.continue23:                                  ; preds = %sync.continue, %entry
  ret void
}

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb(i64, i64, %class.anon.92* byval(%class.anon.92) align 8, i64, i1 zeroext) local_unnamed_addr #0

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev(%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl"*) unnamed_addr #1

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* dereferenceable(15)) unnamed_addr #2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"*, i8*, i64) local_unnamed_addr #2

; Function Attrs: sanitize_cilk uwtable
declare dso_local i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator"*, i64) local_unnamed_addr #2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_(%"class.parlay::sequence"* noalias sret, %"class.parlay::sequence.2"* dereferenceable(15)) local_unnamed_addr #2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv() local_unnamed_addr #0

; Function Attrs: noinline noreturn nounwind
declare void @__clang_call_terminate(i8*) local_unnamed_addr #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #4

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #4

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #4

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #4

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #5

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #4

; Function Attrs: nofree nounwind
declare dso_local i32 @snprintf(i8* noalias nocapture, i64, i8* nocapture readonly, ...) local_unnamed_addr #6

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #5

; Function Attrs: nounwind willreturn
declare void @llvm.assume(i1) #7

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #4

attributes #0 = { inlinehint sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline noreturn nounwind }
attributes #4 = { argmemonly nounwind willreturn }
attributes #5 = { argmemonly willreturn }
attributes #6 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nounwind willreturn }
attributes #8 = { nounwind }
attributes #9 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git fffc5516029927e6f93460fb66ad35b34f9b0b9b)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !3, i64 0}
!7 = !{!"_ZTSZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_mEUlmE_", !3, i64 0, !3, i64 8}
!8 = !{!7, !3, i64 8}
!9 = !{!10, !12, i64 16}
!10 = !{!"_ZTSSt4pairIN6parlay8sequenceIcNS0_9allocatorIcEEEEmE", !11, i64 0, !12, i64 16}
!11 = !{!"_ZTSN6parlay8sequenceIcNS_9allocatorIcEEEE"}
!12 = !{!"long", !4, i64 0}
!13 = !{!14}
!14 = distinct !{!14, !15, !"_ZZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_mENKUlmE_clEm: %agg.result"}
!15 = distinct !{!15, !"_ZZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_mENKUlmE_clEm"}
!16 = !{!17, !14}
!17 = distinct !{!17, !18, !"_ZZ21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPcENK3$_1clES5_: %agg.result"}
!18 = distinct !{!18, !"_ZZ21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPcENK3$_1clES5_"}
!19 = !{!20, !3, i64 0}
!20 = !{!"_ZTSZ21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPcE3$_1", !3, i64 0, !3, i64 8}
!21 = !{!22, !17, !14}
!22 = distinct !{!22, !23, !"_ZN6parlay8to_charsEm: %agg.result"}
!23 = distinct !{!23, !"_ZN6parlay8to_charsEm"}
!24 = !{!22}
!25 = !{!26, !12, i64 0}
!26 = !{!"_ZTSN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl18capacitated_buffer6headerE", !12, i64 0, !4, i64 8}
!27 = !{i64 0, i64 8, !2, i64 8, i64 8, !28}
!28 = !{!12, !12, i64 0}
!29 = !{!30, !3, i64 0}
!30 = !{!"_ZTSZN6parlay8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S6_St26random_access_iterator_tagEUlmE_", !3, i64 0, !3, i64 8, !3, i64 16}
!31 = !{!32, !3, i64 0}
!32 = !{!"_ZTSN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl18capacitated_bufferE", !3, i64 0}
!33 = !{!20, !3, i64 8}
!34 = !{!35, !12, i64 0}
!35 = !{!"_ZTSN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl18capacitated_buffer6headerE", !12, i64 0, !4, i64 8}
!36 = distinct !{!36, !37}
!37 = !{!"tapir.loop.spawn.strategy", i32 1}
