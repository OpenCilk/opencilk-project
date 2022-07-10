; Check that machie code generation, specifically machine-sink, does
; not put arithmetic that stores to stack slots in basic blocks that
; can execute twice.
;
; RUN: llc < %s -mtriple=x86_64-- -o - | FileCheck %s
; REQUIRES: x86-registered-target
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.__cilkrts_worker = type { %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, i32, %struct.global_state*, %struct.local_state*, %struct.__cilkrts_stack_frame*, %struct.cilkred_map*, [184 x i8] }
%struct.global_state = type { %struct.rts_options, i32, %struct.__cilkrts_worker**, %struct.ReadyDeque*, i64*, %struct.Closure*, [56 x i8], %struct.cilk_fiber_pool, %struct.global_im_pool, [8 x i8], %struct.cilk_im_desc, %union.cilk_mutex, [52 x i8], [5 x i8*], i8*, i8, [15 x i8], i32, i32, i32, i8, %union.pthread_mutex_t, %union.pthread_cond_t, %union.pthread_mutex_t, %union.pthread_cond_t, i8, i8, i8, [61 x i8], i32*, i32*, %union.cilk_mutex, [44 x i8], i64, [56 x i8], i32, %union.pthread_mutex_t, %union.pthread_cond_t, %union.cilk_mutex, %struct.reducer_id_manager*, %struct.global_sched_stats, [40 x i8] }
%struct.rts_options = type { i64, i32, i32, i32, i32, i32 }
%struct.ReadyDeque = type { %union.cilk_mutex, %struct.Closure*, %struct.Closure*, i32, [36 x i8] }
%struct.Closure = type { %union.cilk_mutex, %struct.__cilkrts_stack_frame*, %struct.cilk_fiber*, %struct.cilk_fiber*, i32, i32, i8, i8, i8, i8, i32, i8*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.cilkred_map*, %struct.cilkred_map*, %struct.cilkred_map*, i8*, i8*, %struct.cilk_fiber*, %union.anon.10, %union.anon.10, %union.anon.10 }
%struct.cilk_fiber = type opaque
%union.anon.10 = type { i8* }
%struct.cilk_fiber_pool = type { %union.cilk_mutex, i32, i32, i64, %struct.cilk_fiber_pool*, %struct.cilk_fiber**, i32, i32, %struct.fiber_pool_stats }
%struct.fiber_pool_stats = type { i32, i32, i32 }
%struct.global_im_pool = type { i8*, i8*, i8**, i32, i32, i64, i64, i64 }
%struct.cilk_im_desc = type { [7 x %struct.im_bucket], i64, [4 x i64] }
%struct.im_bucket = type { i8*, i32, i32, i32, i32, i64 }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%union.pthread_cond_t = type { %struct.__pthread_cond_s }
%struct.__pthread_cond_s = type { %"struct.std::__atomic_base", %"struct.std::__atomic_base", [2 x i32], [2 x i32], i32, i32, [2 x i32] }
%"struct.std::__atomic_base" = type { i64 }
%union.cilk_mutex = type { i32 }
%struct.reducer_id_manager = type opaque
%struct.global_sched_stats = type { i64, i64, i64, i64, i64, i64, i64, [7 x double], [7 x i64] }
%struct.local_state = type { %struct.__cilkrts_stack_frame**, i16, i8, i8, i32, i32*, [5 x i8*], %struct.cilk_fiber_pool, %struct.cilk_im_desc, %struct.cilk_fiber*, %struct.sched_stats }
%struct.sched_stats = type { [7 x i64], [7 x i64], [7 x i64], [7 x i64], i64, i64 }
%struct.__cilkrts_stack_frame = type { i32, i32, %struct.__cilkrts_stack_frame*, %struct.__cilkrts_worker*, [5 x i8*] }
%struct.cilkred_map = type { i32, i32, i32, i8, i32*, %struct.view_info* }
%struct.view_info = type { i8*, %struct.__cilkrts_hyperobject_base* }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i32, i32, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base*, i64)*, void (%struct.__cilkrts_hyperobject_base*, i8*)* }
%"struct.parlay::block_allocator::block" = type { %"struct.parlay::block_allocator::block"* }
%"struct.parlay::block_allocator" = type { i8, [63 x i8], %"class.parlay::concurrent_stack.8", %"class.parlay::concurrent_stack.9", %"struct.parlay::block_allocator::thread_list"*, i64, i64, i64, %"struct.std::atomic", i64, [16 x i8] }
%"class.parlay::concurrent_stack.8" = type { %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<char *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<char *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<char *>::Node" = type { i8*, %"struct.parlay::concurrent_stack<char *>::Node"*, i64 }
%"class.std::mutex" = type { %"class.std::__mutex_base" }
%"class.std::__mutex_base" = type { %union.pthread_mutex_t }
%"class.parlay::concurrent_stack.9" = type { %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node" = type { %"struct.parlay::block_allocator::block"*, %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node"*, i64 }
%"struct.parlay::block_allocator::thread_list" = type { i64, %"struct.parlay::block_allocator::block"*, %"struct.parlay::block_allocator::block"*, [256 x i8], [40 x i8] }
%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long>>::_Vector_impl" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long>>::_Vector_impl" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long>>::_Vector_impl_data" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long>>::_Vector_impl_data" = type { i64*, i64*, i64* }

$_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb = comdat any

@.str.12 = private unnamed_addr constant [39 x i8] c"[W%d] parallel_for: start %ld end %ld\0A\00", align 1
@tls_worker = external thread_local local_unnamed_addr global %struct.__cilkrts_worker*, align 8
@default_cilkrts = external local_unnamed_addr global %struct.global_state*, align 8
@cilkg_nproc = external local_unnamed_addr global i32, align 4

; Function Attrs: inlinehint stealable uwtable
define linkonce_odr dso_local void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb(i64 %start, i64 %end, %"struct.parlay::block_allocator::block"** %f.coerce0, %"struct.parlay::block_allocator"* %f.coerce1, i64 %granularity, i1 zeroext %0) local_unnamed_addr #0 comdat personality i32 (...)* @__cilk_personality_v0 !prof !34 {
entry:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  %1 = load %struct.__cilkrts_worker*, %struct.__cilkrts_worker** @tls_worker, align 8, !tbaa !35
  %flags.i105 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 0
  store i32 0, i32* %flags.i105, align 8, !tbaa !39
  %cmp.i106 = icmp eq %struct.__cilkrts_worker* %1, null
  br i1 %cmp.i106, label %if.then.i107, label %__cilkrts_enter_frame.exit

if.then.i107:                                     ; preds = %entry
  %2 = load %struct.global_state*, %struct.global_state** @default_cilkrts, align 8, !tbaa !35
  %arraydecay.i.i = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4, i64 0
  %3 = tail call i8* @llvm.frameaddress.p0i8(i32 0) #3
  store i8* %3, i8** %arraydecay.i.i, align 8
  %4 = tail call i8* @llvm.stacksave() #3
  %5 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4, i64 2
  store i8* %4, i8** %5, align 8
  %6 = bitcast i8** %arraydecay.i.i to i8*
  %7 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %6) #3
  %cmp.i.i = icmp eq i32 %7, 0
  br i1 %cmp.i.i, label %if.then.i.i108, label %cilkify.exit.i

if.then.i.i108:                                   ; preds = %if.then.i107
  call void @__cilkrts_internal_invoke_cilkified_root(%struct.global_state* %2, %struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %cilkify.exit.i

cilkify.exit.i:                                   ; preds = %if.then.i.i108, %if.then.i107
  %8 = load %struct.__cilkrts_worker*, %struct.__cilkrts_worker** @tls_worker, align 8, !tbaa !35
  br label %__cilkrts_enter_frame.exit

__cilkrts_enter_frame.exit:                       ; preds = %cilkify.exit.i, %entry
  %w.0.i = phi %struct.__cilkrts_worker* [ %8, %cilkify.exit.i ], [ %1, %entry ]
  %magic.i = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 1
  store i32 1624267, i32* %magic.i, align 4, !tbaa !42
  %current_stack_frame.i = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %w.0.i, i64 0, i32 7
  %9 = load %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %current_stack_frame.i, align 8, !tbaa !43
  %call_parent.i = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 2
  store %struct.__cilkrts_stack_frame* %9, %struct.__cilkrts_stack_frame** %call_parent.i, align 8, !tbaa !45
  %worker.i = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 3
  %10 = bitcast %struct.__cilkrts_worker** %worker.i to i64*
  %11 = ptrtoint %struct.__cilkrts_worker* %w.0.i to i64
  store atomic i64 %11, i64* %10 monotonic, align 8
  store %struct.__cilkrts_stack_frame* %__cilkrts_sf, %struct.__cilkrts_stack_frame** %current_stack_frame.i, align 8, !tbaa !43
  %cmp = icmp eq i64 %granularity, 0
  br i1 %cmp, label %if.then, label %if.else.preheader, !prof !46

if.else.preheader:                                ; preds = %__cilkrts_enter_frame.exit
  %sub669 = sub i64 %end, %start
  %cmp7.not70 = icmp ugt i64 %sub669, %granularity
  br i1 %cmp7.not70, label %if.else13.peel, label %for.cond.preheader, !prof !47

if.else13.peel:                                   ; preds = %if.else.preheader
  %call.peel = tail call i32 @__cilkrts_get_worker_number()
  %call14.peel = tail call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([39 x i8], [39 x i8]* @.str.12, i64 0, i64 0), i32 %call.peel, i64 %start, i64 %end)
  %12 = mul i64 %sub669, 9
  %mul17.peel = add i64 %12, 9
  %div18.peel = lshr i64 %mul17.peel, 4
  %add19.peel = add i64 %div18.peel, %start
  %arraydecay.i98 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4, i64 0
  %13 = call i8* @llvm.frameaddress.p0i8(i32 0) #3
  store i8* %13, i8** %arraydecay.i98, align 8
  %14 = call i8* @llvm.stacksave() #3
  %15 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4, i64 2
  store i8* %14, i8** %15, align 8
  %16 = bitcast i8** %arraydecay.i98 to i8*
  %17 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %16) #3
  %18 = icmp eq i32 %17, 0
  br i1 %18, label %if.else13.peel.split, label %det.cont.peel

if.else13.peel.split:                             ; preds = %if.else13.peel
  call fastcc void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.peel.otd1(i64 %start, i64 %add19.peel, %"struct.parlay::block_allocator::block"** %f.coerce0, %"struct.parlay::block_allocator"* %f.coerce1, i64 %granularity)
  br label %det.cont.peel

det.cont.peel:                                    ; preds = %if.else13.peel.split, %if.else13.peel
  %sub6.peel = sub i64 %end, %add19.peel
  %cmp7.not.peel = icmp ugt i64 %sub6.peel, %granularity
  br i1 %cmp7.not.peel, label %if.else13.peel78, label %for.cond.preheader, !prof !47

if.else13.peel78:                                 ; preds = %det.cont.peel
  %call.peel79 = tail call i32 @__cilkrts_get_worker_number()
  %call14.peel80 = tail call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([39 x i8], [39 x i8]* @.str.12, i64 0, i64 0), i32 %call.peel79, i64 %add19.peel, i64 %end)
  %19 = mul i64 %sub6.peel, 9
  %mul17.peel81 = add i64 %19, 9
  %div18.peel82 = lshr i64 %mul17.peel81, 4
  %add19.peel83 = add i64 %div18.peel82, %add19.peel
  store i8* %13, i8** %arraydecay.i98, align 8
  %20 = call i8* @llvm.stacksave() #3
  store i8* %20, i8** %15, align 8
  %21 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %16) #3
  %22 = icmp eq i32 %21, 0
  br i1 %22, label %if.else13.peel78.split, label %det.cont.peel85

if.else13.peel78.split:                           ; preds = %if.else13.peel78
  call fastcc void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.peel84.otd1(i64 %add19.peel, i64 %add19.peel83, %"struct.parlay::block_allocator::block"** %f.coerce0, %"struct.parlay::block_allocator"* %f.coerce1, i64 %granularity)
  br label %det.cont.peel85

det.cont.peel85:                                  ; preds = %if.else13.peel78.split, %if.else13.peel78
  %sub6.peel86 = sub i64 %end, %add19.peel83
  %cmp7.not.peel87 = icmp ugt i64 %sub6.peel86, %granularity
  br i1 %cmp7.not.peel87, label %if.else13, label %for.cond.preheader, !prof !48

if.then:                                          ; preds = %__cilkrts_enter_frame.exit
  %cmp1 = icmp ugt i64 %end, %start
  br i1 %cmp1, label %pfor.ph, label %if.end23

pfor.ph:                                          ; preds = %if.then
  %sub = sub i64 %end, %start
  %23 = bitcast %"struct.parlay::block_allocator::block"** %f.coerce0 to i8**
  %block_size_.i = getelementptr inbounds %"struct.parlay::block_allocator", %"struct.parlay::block_allocator"* %f.coerce1, i64 0, i32 7
  %24 = load i64, i64* %block_size_.i, align 8, !tbaa !49
  %25 = xor i64 %start, -1
  %26 = add i64 %25, %end
  %xtraiter = and i64 %sub, 2047
  %27 = icmp ult i64 %26, 2047
  br i1 %27, label %pfor.cond.cleanup.strpm-lcssa, label %pfor.ph.new

pfor.ph.new:                                      ; preds = %pfor.ph
  %stripiter = lshr i64 %sub, 11
  tail call fastcc void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_pfor.cond.strpm.outer.ls1(i64 0, i64 %stripiter, i64 %start, i8** %23, i64 %24)
  br label %pfor.cond.cleanup.strpm-lcssa

pfor.cond.cleanup.strpm-lcssa:                    ; preds = %pfor.ph.new, %pfor.ph
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %if.end23, label %pfor.cond.epil.preheader

pfor.cond.epil.preheader:                         ; preds = %pfor.cond.cleanup.strpm-lcssa
  %28 = and i64 %sub, -2048
  %29 = add nsw i64 %xtraiter, -1
  %xtraiter73 = and i64 %sub, 3
  %lcmp.mod.not89 = icmp eq i64 %xtraiter73, 0
  br i1 %lcmp.mod.not89, label %pfor.cond.epil.prol.loopexit, label %pfor.cond.epil.prol

pfor.cond.epil.prol:                              ; preds = %pfor.cond.epil.prol, %pfor.cond.epil.preheader
  %__begin.0.epil.prol = phi i64 [ %inc.epil.prol, %pfor.cond.epil.prol ], [ %28, %pfor.cond.epil.preheader ]
  %prol.iter = phi i64 [ %prol.iter.sub, %pfor.cond.epil.prol ], [ %xtraiter73, %pfor.cond.epil.preheader ]
  %add3.epil.prol = add i64 %__begin.0.epil.prol, %start
  %30 = load i8*, i8** %23, align 8, !tbaa !62
  %mul.i.epil.prol = mul i64 %add3.epil.prol, %24
  %add.ptr.i.epil.prol = getelementptr inbounds i8, i8* %30, i64 %mul.i.epil.prol
  %add.ptr3.i.epil.prol = getelementptr inbounds i8, i8* %add.ptr.i.epil.prol, i64 %24
  %31 = bitcast i8* %add.ptr.i.epil.prol to i8**
  store i8* %add.ptr3.i.epil.prol, i8** %31, align 8, !tbaa !63
  %inc.epil.prol = add nuw nsw i64 %__begin.0.epil.prol, 1
  %prol.iter.sub = add nsw i64 %prol.iter, -1
  %prol.iter.cmp.not = icmp eq i64 %prol.iter.sub, 0
  br i1 %prol.iter.cmp.not, label %pfor.cond.epil.prol.loopexit.loopexit, label %pfor.cond.epil.prol, !llvm.loop !65

pfor.cond.epil.prol.loopexit.loopexit:            ; preds = %pfor.cond.epil.prol
  %32 = sub nsw i64 %xtraiter, %xtraiter73
  br label %pfor.cond.epil.prol.loopexit

pfor.cond.epil.prol.loopexit:                     ; preds = %pfor.cond.epil.prol.loopexit.loopexit, %pfor.cond.epil.preheader
  %__begin.0.epil.unr = phi i64 [ %28, %pfor.cond.epil.preheader ], [ %inc.epil.prol, %pfor.cond.epil.prol.loopexit.loopexit ]
  %epil.iter.unr = phi i64 [ %xtraiter, %pfor.cond.epil.preheader ], [ %32, %pfor.cond.epil.prol.loopexit.loopexit ]
  %33 = icmp ult i64 %29, 3
  br i1 %33, label %if.end23, label %pfor.cond.epil

pfor.cond.epil:                                   ; preds = %pfor.cond.epil, %pfor.cond.epil.prol.loopexit
  %__begin.0.epil = phi i64 [ %inc.epil.3, %pfor.cond.epil ], [ %__begin.0.epil.unr, %pfor.cond.epil.prol.loopexit ]
  %epil.iter = phi i64 [ %epil.iter.sub.3, %pfor.cond.epil ], [ %epil.iter.unr, %pfor.cond.epil.prol.loopexit ]
  %add3.epil = add i64 %__begin.0.epil, %start
  %34 = load i8*, i8** %23, align 8, !tbaa !62
  %mul.i.epil = mul i64 %add3.epil, %24
  %add.ptr.i.epil = getelementptr inbounds i8, i8* %34, i64 %mul.i.epil
  %add.ptr3.i.epil = getelementptr inbounds i8, i8* %add.ptr.i.epil, i64 %24
  %35 = bitcast i8* %add.ptr.i.epil to i8**
  store i8* %add.ptr3.i.epil, i8** %35, align 8, !tbaa !63
  %add3.epil.1 = add i64 %add3.epil, 1
  %36 = load i8*, i8** %23, align 8, !tbaa !62
  %mul.i.epil.1 = mul i64 %add3.epil.1, %24
  %add.ptr.i.epil.1 = getelementptr inbounds i8, i8* %36, i64 %mul.i.epil.1
  %add.ptr3.i.epil.1 = getelementptr inbounds i8, i8* %add.ptr.i.epil.1, i64 %24
  %37 = bitcast i8* %add.ptr.i.epil.1 to i8**
  store i8* %add.ptr3.i.epil.1, i8** %37, align 8, !tbaa !63
  %add3.epil.2 = add i64 %add3.epil, 2
  %38 = load i8*, i8** %23, align 8, !tbaa !62
  %mul.i.epil.2 = mul i64 %add3.epil.2, %24
  %add.ptr.i.epil.2 = getelementptr inbounds i8, i8* %38, i64 %mul.i.epil.2
  %add.ptr3.i.epil.2 = getelementptr inbounds i8, i8* %add.ptr.i.epil.2, i64 %24
  %39 = bitcast i8* %add.ptr.i.epil.2 to i8**
  store i8* %add.ptr3.i.epil.2, i8** %39, align 8, !tbaa !63
  %add3.epil.3 = add i64 %add3.epil, 3
  %40 = load i8*, i8** %23, align 8, !tbaa !62
  %mul.i.epil.3 = mul i64 %add3.epil.3, %24
  %add.ptr.i.epil.3 = getelementptr inbounds i8, i8* %40, i64 %mul.i.epil.3
  %add.ptr3.i.epil.3 = getelementptr inbounds i8, i8* %add.ptr.i.epil.3, i64 %24
  %41 = bitcast i8* %add.ptr.i.epil.3 to i8**
  store i8* %add.ptr3.i.epil.3, i8** %41, align 8, !tbaa !63
  %inc.epil.3 = add nuw nsw i64 %__begin.0.epil, 4
  %epil.iter.sub.3 = add nsw i64 %epil.iter, -4
  %epil.iter.cmp.not.3 = icmp eq i64 %epil.iter.sub.3, 0
  br i1 %epil.iter.cmp.not.3, label %if.end23, label %pfor.cond.epil, !llvm.loop !67

for.cond.preheader:                               ; preds = %det.cont, %det.cont.peel85, %det.cont.peel, %if.else.preheader
  %start.tr66.lcssa = phi i64 [ %start, %if.else.preheader ], [ %add19.peel, %det.cont.peel ], [ %add19.peel83, %det.cont.peel85 ], [ %add19, %det.cont ]
  %cmp1064 = icmp ult i64 %start.tr66.lcssa, %end
  br i1 %cmp1064, label %for.body.lr.ph, label %if.end23, !prof !69

for.body.lr.ph:                                   ; preds = %for.cond.preheader
  %42 = bitcast %"struct.parlay::block_allocator::block"** %f.coerce0 to i8**
  %block_size_.i57 = getelementptr inbounds %"struct.parlay::block_allocator", %"struct.parlay::block_allocator"* %f.coerce1, i64 0, i32 7
  %43 = load i64, i64* %block_size_.i57, align 8, !tbaa !49
  %44 = sub i64 %end, %start.tr66.lcssa
  %45 = xor i64 %start.tr66.lcssa, -1
  %46 = add i64 %45, %end
  %xtraiter74 = and i64 %44, 3
  %lcmp.mod75.not = icmp eq i64 %xtraiter74, 0
  br i1 %lcmp.mod75.not, label %for.body.prol.loopexit, label %for.body.prol

for.body.prol:                                    ; preds = %for.body.prol, %for.body.lr.ph
  %i9.065.prol = phi i64 [ %inc11.prol, %for.body.prol ], [ %start.tr66.lcssa, %for.body.lr.ph ]
  %prol.iter76 = phi i64 [ %prol.iter76.sub, %for.body.prol ], [ %xtraiter74, %for.body.lr.ph ]
  %47 = load i8*, i8** %42, align 8, !tbaa !62
  %mul.i58.prol = mul i64 %i9.065.prol, %43
  %add.ptr.i59.prol = getelementptr inbounds i8, i8* %47, i64 %mul.i58.prol
  %add.ptr3.i60.prol = getelementptr inbounds i8, i8* %add.ptr.i59.prol, i64 %43
  %48 = bitcast i8* %add.ptr.i59.prol to i8**
  store i8* %add.ptr3.i60.prol, i8** %48, align 8, !tbaa !63
  %inc11.prol = add nuw i64 %i9.065.prol, 1
  %prol.iter76.sub = add nsw i64 %prol.iter76, -1
  %prol.iter76.cmp.not = icmp eq i64 %prol.iter76.sub, 0
  br i1 %prol.iter76.cmp.not, label %for.body.prol.loopexit, label %for.body.prol, !prof !70, !llvm.loop !71

for.body.prol.loopexit:                           ; preds = %for.body.prol, %for.body.lr.ph
  %i9.065.unr = phi i64 [ %start.tr66.lcssa, %for.body.lr.ph ], [ %inc11.prol, %for.body.prol ]
  %49 = icmp ult i64 %46, 3
  br i1 %49, label %if.end23, label %for.body

for.body:                                         ; preds = %for.body, %for.body.prol.loopexit
  %i9.065 = phi i64 [ %inc11.3, %for.body ], [ %i9.065.unr, %for.body.prol.loopexit ]
  %50 = load i8*, i8** %42, align 8, !tbaa !62
  %mul.i58 = mul i64 %i9.065, %43
  %add.ptr.i59 = getelementptr inbounds i8, i8* %50, i64 %mul.i58
  %add.ptr3.i60 = getelementptr inbounds i8, i8* %add.ptr.i59, i64 %43
  %51 = bitcast i8* %add.ptr.i59 to i8**
  store i8* %add.ptr3.i60, i8** %51, align 8, !tbaa !63
  %inc11 = add nuw i64 %i9.065, 1
  %52 = load i8*, i8** %42, align 8, !tbaa !62
  %mul.i58.1 = mul i64 %inc11, %43
  %add.ptr.i59.1 = getelementptr inbounds i8, i8* %52, i64 %mul.i58.1
  %add.ptr3.i60.1 = getelementptr inbounds i8, i8* %add.ptr.i59.1, i64 %43
  %53 = bitcast i8* %add.ptr.i59.1 to i8**
  store i8* %add.ptr3.i60.1, i8** %53, align 8, !tbaa !63
  %inc11.1 = add nuw i64 %i9.065, 2
  %54 = load i8*, i8** %42, align 8, !tbaa !62
  %mul.i58.2 = mul i64 %inc11.1, %43
  %add.ptr.i59.2 = getelementptr inbounds i8, i8* %54, i64 %mul.i58.2
  %add.ptr3.i60.2 = getelementptr inbounds i8, i8* %add.ptr.i59.2, i64 %43
  %55 = bitcast i8* %add.ptr.i59.2 to i8**
  store i8* %add.ptr3.i60.2, i8** %55, align 8, !tbaa !63
  %inc11.2 = add nuw i64 %i9.065, 3
  %56 = load i8*, i8** %42, align 8, !tbaa !62
  %mul.i58.3 = mul i64 %inc11.2, %43
  %add.ptr.i59.3 = getelementptr inbounds i8, i8* %56, i64 %mul.i58.3
  %add.ptr3.i60.3 = getelementptr inbounds i8, i8* %add.ptr.i59.3, i64 %43
  %57 = bitcast i8* %add.ptr.i59.3 to i8**
  store i8* %add.ptr3.i60.3, i8** %57, align 8, !tbaa !63
  %inc11.3 = add nuw i64 %i9.065, 4
  %exitcond67.not.3 = icmp eq i64 %inc11.3, %end
  br i1 %exitcond67.not.3, label %if.end23, label %for.body, !prof !72, !llvm.loop !73

if.else13:                                        ; preds = %det.cont, %det.cont.peel85
  %sub672 = phi i64 [ %sub6, %det.cont ], [ %sub6.peel86, %det.cont.peel85 ]
  %start.tr6671 = phi i64 [ %add19, %det.cont ], [ %add19.peel83, %det.cont.peel85 ]
  %call = tail call i32 @__cilkrts_get_worker_number()
  %call14 = tail call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([39 x i8], [39 x i8]* @.str.12, i64 0, i64 0), i32 %call, i64 %start.tr6671, i64 %end)
  %58 = mul i64 %sub672, 9
  %mul17 = add i64 %58, 9
  %div18 = lshr i64 %mul17, 4
  %add19 = add i64 %div18, %start.tr6671
  store i8* %13, i8** %arraydecay.i98, align 8
  %59 = call i8* @llvm.stacksave() #3
  store i8* %59, i8** %15, align 8
  %60 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %16) #3
  %61 = icmp eq i32 %60, 0
  br i1 %61, label %if.else13.split, label %det.cont

if.else13.split:                                  ; preds = %if.else13
  call fastcc void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.otd1(i64 %start.tr6671, i64 %add19, %"struct.parlay::block_allocator::block"** %f.coerce0, %"struct.parlay::block_allocator"* %f.coerce1, i64 %granularity)
  br label %det.cont

det.cont:                                         ; preds = %if.else13.split, %if.else13
  %sub6 = sub i64 %end, %add19
  %cmp7.not = icmp ugt i64 %sub6, %granularity
  br i1 %cmp7.not, label %if.else13, label %for.cond.preheader, !prof !48, !llvm.loop !75

if.end23:                                         ; preds = %for.body, %for.body.prol.loopexit, %for.cond.preheader, %pfor.cond.epil, %pfor.cond.epil.prol.loopexit, %pfor.cond.cleanup.strpm-lcssa, %if.then
  %62 = load i32, i32* %flags.i105, align 8, !tbaa !39
  %and.i = and i32 %62, 2
  %tobool.not.i = icmp eq i32 %and.i, 0
  br i1 %tobool.not.i, label %if.end23.split, label %if.then.i

if.then.i:                                        ; preds = %if.end23
  %arraydecay.i99 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4, i64 0
  %63 = call i8* @llvm.frameaddress.p0i8(i32 0)
  store i8* %63, i8** %arraydecay.i99, align 8
  %64 = call i8* @llvm.stacksave()
  %65 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4, i64 2
  store i8* %64, i8** %65, align 8
  %66 = bitcast i8** %arraydecay.i99 to i8*
  %67 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %66)
  %cmp.i = icmp eq i32 %67, 0
  br i1 %cmp.i, label %if.then1.i, label %if.else.i

if.then1.i:                                       ; preds = %if.then.i
  call void @__cilkrts_sync(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #11
  unreachable

if.else.i:                                        ; preds = %if.then.i
  %68 = load i32, i32* %flags.i105, align 8, !tbaa !39
  %and3.i = and i32 %68, 8
  %tobool4.not.i = icmp eq i32 %and3.i, 0
  br i1 %tobool4.not.i, label %if.end23.split, label %if.then5.i

if.then5.i:                                       ; preds = %if.else.i
  call void @__cilkrts_check_exception_raise(%struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf)
  %.pre = load i32, i32* %flags.i105, align 8, !tbaa !39
  br label %if.end23.split

if.end23.split:                                   ; preds = %if.then5.i, %if.else.i, %if.end23
  %69 = phi i32 [ %.pre, %if.then5.i ], [ %68, %if.else.i ], [ %62, %if.end23 ]
  %70 = load atomic i64, i64* %10 monotonic, align 8
  %71 = inttoptr i64 %70 to %struct.__cilkrts_worker*
  %72 = load %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %call_parent.i, align 8, !tbaa !45
  %current_stack_frame.i.i = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %71, i64 0, i32 7
  store %struct.__cilkrts_stack_frame* %72, %struct.__cilkrts_stack_frame** %current_stack_frame.i.i, align 8, !tbaa !43
  store %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %call_parent.i, align 8, !tbaa !45
  %73 = trunc i32 %69 to i8
  %tobool4.not.i.i = icmp sgt i8 %73, -1
  br i1 %tobool4.not.i.i, label %if.end.i.i, label %if.then.i.i

if.then.i.i:                                      ; preds = %if.end23.split
  %g.i.i = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %71, i64 0, i32 5
  %74 = load %struct.global_state*, %struct.global_state** %g.i.i, align 8, !tbaa !77
  %arraydecay.i.i.i = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4, i64 0
  %75 = call i8* @llvm.frameaddress.p0i8(i32 0) #3
  store i8* %75, i8** %arraydecay.i.i.i, align 8
  %76 = call i8* @llvm.stacksave() #3
  %77 = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %__cilkrts_sf, i64 0, i32 4, i64 2
  store i8* %76, i8** %77, align 8
  %78 = bitcast i8** %arraydecay.i.i.i to i8*
  %79 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %78) #3
  %cmp.i.i.i = icmp eq i32 %79, 0
  br i1 %cmp.i.i.i, label %if.then.i.i.i, label %uncilkify.exit.i.i

if.then.i.i.i:                                    ; preds = %if.then.i.i
  call void @__cilkrts_internal_exit_cilkified_root(%struct.global_state* %74, %struct.__cilkrts_stack_frame* nonnull %__cilkrts_sf) #3
  br label %uncilkify.exit.i.i

uncilkify.exit.i.i:                               ; preds = %if.then.i.i.i, %if.then.i.i
  %80 = load i32, i32* %flags.i105, align 8, !tbaa !39
  br label %if.end.i.i

if.end.i.i:                                       ; preds = %uncilkify.exit.i.i, %if.end23.split
  %flags.0.i.i = phi i32 [ %80, %uncilkify.exit.i.i ], [ %69, %if.end23.split ]
  %and8.i.i = and i32 %flags.0.i.i, 1
  %tobool9.not.i.i = icmp eq i32 %and8.i.i, 0
  br i1 %tobool9.not.i.i, label %__cilk_parent_epilogue.exit, label %cond.end15.i.i

cond.end15.i.i:                                   ; preds = %if.end.i.i
  call void @Cilk_set_return(%struct.__cilkrts_worker* nonnull %71) #3
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %cond.end15.i.i, %if.end.i.i
  ret void
}

; CHECK: _ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb:
; CHECK: callq	_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.peel.otd1
; CHECK: callq	_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.peel84.otd1
; CHECK: callq	__cilkrts_get_worker_number
; CHECK: callq printf

; CHECK: movq  %rbp
; CHECK: movq  %rsp
; CHECK: xorl  %eax, %eax
; CHECK: jmp   [[LABEL:.+]]

; CHECK: movl  $1, %eax

; CHECK: [[LABEL]]:
; CHECK-NOT: movq	-{{[0-9]+}}(%rbp)
; CHECK-NOT: addq	%{{[a-z0-9]+}}, -{{[0-9]+}}(%rbp)
; CHECK: testl	%eax, %eax
; CHECK: jne

; CHECK: callq	_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.otd1

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #1

; Function Attrs: nofree nosync nounwind willreturn
declare i8* @llvm.stacksave() #2

; Function Attrs: nounwind
declare i32 @llvm.eh.sjlj.setjmp(i8*) #3

declare void @__cilkrts_internal_invoke_cilkified_root(%struct.global_state*, %struct.__cilkrts_stack_frame*) local_unnamed_addr #4

; Function Attrs: noreturn nounwind
declare void @__cilkrts_sync(%struct.__cilkrts_stack_frame*) local_unnamed_addr #5

declare void @__cilkrts_check_exception_raise(%struct.__cilkrts_stack_frame*) local_unnamed_addr #4

declare void @__cilkrts_internal_exit_cilkified_root(%struct.global_state*, %struct.__cilkrts_stack_frame*) local_unnamed_addr #4

declare void @Cilk_set_return(%struct.__cilkrts_worker*) local_unnamed_addr #4

declare void @Cilk_exception_handler(i8*) local_unnamed_addr #4

declare i32 @__gcc_personality_v0(...)

declare i32 @__cilk_personality_v0(...)

; Function Attrs: nofree willreturn
declare dso_local i32 @__cilkrts_get_worker_number() local_unnamed_addr #6

; Function Attrs: nofree nounwind
declare dso_local noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #7

; Function Attrs: uwtable
declare dso_local void @_Z18create_random_dataImESt6vectorIT_SaIS1_EEmm(%"class.std::vector"* noalias sret(%"class.std::vector") align 8, i64, i64) local_unnamed_addr #8

; Function Attrs: inlinehint noinline uwtable
declare fastcc void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.otd1(i64, i64, %"struct.parlay::block_allocator::block"** align 1, %"struct.parlay::block_allocator"* align 1, i64) unnamed_addr #9

; Function Attrs: inlinehint noinline uwtable
declare fastcc void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.peel.otd1(i64, i64, %"struct.parlay::block_allocator::block"** align 1, %"struct.parlay::block_allocator"* align 1, i64) unnamed_addr #9

; Function Attrs: inlinehint noinline uwtable
declare fastcc void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_det.achd.peel84.otd1(i64, i64, %"struct.parlay::block_allocator::block"** align 1, %"struct.parlay::block_allocator"* align 1, i64) unnamed_addr #9

; Function Attrs: inlinehint nounwind stealable uwtable
declare fastcc void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb.outline_pfor.cond.strpm.outer.ls1(i64, i64, i64, i8** nocapture readonly align 1, i64) unnamed_addr #10

attributes #0 = { inlinehint stealable uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone willreturn }
attributes #2 = { nofree nosync nounwind willreturn }
attributes #3 = { nounwind }
attributes #4 = { "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { noreturn nounwind "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nofree willreturn "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree nounwind "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { inlinehint noinline uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { inlinehint nounwind stealable uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { noreturn nounwind }

!llvm.module.flags = !{!0, !29, !30, !31, !32}
!llvm.ident = !{!33, !33}

!0 = !{i32 1, !"ProfileSummary", !1}
!1 = !{!2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!2 = !{!"ProfileFormat", !"InstrProf"}
!3 = !{!"TotalCount", i64 27795559}
!4 = !{!"MaxCount", i64 12579264}
!5 = !{!"MaxInternalCount", i64 12579264}
!6 = !{!"MaxFunctionCount", i64 12579264}
!7 = !{!"NumCounts", i64 1530}
!8 = !{!"NumFunctions", i64 929}
!9 = !{!"IsPartialProfile", i64 0}
!10 = !{!"PartialProfileRatio", double 0.000000e+00}
!11 = !{!"DetailedSummary", !12}
!12 = !{!13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28}
!13 = !{i32 10000, i64 12579264, i32 2}
!14 = !{i32 100000, i64 12579264, i32 2}
!15 = !{i32 200000, i64 12579264, i32 2}
!16 = !{i32 300000, i64 12579264, i32 2}
!17 = !{i32 400000, i64 12579264, i32 2}
!18 = !{i32 500000, i64 12579264, i32 2}
!19 = !{i32 600000, i64 12579264, i32 2}
!20 = !{i32 700000, i64 12579264, i32 2}
!21 = !{i32 800000, i64 12579264, i32 2}
!22 = !{i32 900000, i64 12579264, i32 2}
!23 = !{i32 950000, i64 82058, i32 15}
!24 = !{i32 990000, i64 10000, i32 57}
!25 = !{i32 999000, i64 2058, i32 79}
!26 = !{i32 999900, i64 29, i32 145}
!27 = !{i32 999990, i64 3, i32 358}
!28 = !{i32 999999, i64 1, i32 539}
!29 = !{i32 1, !"wchar_size", i32 4}
!30 = !{i32 7, !"Dwarf Version", i32 4}
!31 = !{i32 2, !"Debug Info Version", i32 3}
!32 = !{i32 7, !"PIC Level", i32 2}
!33 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 5d2851d7d0e689ecb3b893aa6abd12390b838c4b)"}
!34 = !{!"function_entry_count", i64 34944}
!35 = !{!36, !36, i64 0}
!36 = !{!"any pointer", !37, i64 0}
!37 = !{!"omnipotent char", !38, i64 0}
!38 = !{!"Simple C/C++ TBAA"}
!39 = !{!40, !41, i64 0}
!40 = !{!"__cilkrts_stack_frame", !41, i64 0, !41, i64 4, !36, i64 8, !37, i64 16, !37, i64 24}
!41 = !{!"int", !37, i64 0}
!42 = !{!40, !41, i64 4}
!43 = !{!44, !36, i64 56}
!44 = !{!"__cilkrts_worker", !37, i64 0, !37, i64 8, !37, i64 16, !36, i64 24, !41, i64 32, !36, i64 40, !36, i64 48, !36, i64 56, !36, i64 64}
!45 = !{!40, !36, i64 8}
!46 = !{!"branch_weights", i32 1, i32 34945}
!47 = !{!"branch_weights", i32 16705, i32 18241}
!48 = !{!"branch_weights", i32 1, i32 18241}
!49 = !{!50, !60, i64 344}
!50 = !{!"_ZTSN6parlay15block_allocatorE", !51, i64 0, !54, i64 64, !58, i64 192, !56, i64 320, !60, i64 328, !60, i64 336, !60, i64 344, !61, i64 352, !60, i64 360}
!51 = !{!"bool", !52, i64 0}
!52 = !{!"omnipotent char", !53, i64 0}
!53 = !{!"Simple C++ TBAA"}
!54 = !{!"_ZTSN6parlay16concurrent_stackIPcEE", !55, i64 0, !55, i64 64}
!55 = !{!"_ZTSN6parlay16concurrent_stackIPcE24locking_concurrent_stackE", !56, i64 0, !57, i64 8}
!56 = !{!"any pointer", !52, i64 0}
!57 = !{!"_ZTSSt5mutex"}
!58 = !{!"_ZTSN6parlay16concurrent_stackIPNS_15block_allocator5blockEEE", !59, i64 0, !59, i64 64}
!59 = !{!"_ZTSN6parlay16concurrent_stackIPNS_15block_allocator5blockEE24locking_concurrent_stackE", !56, i64 0, !57, i64 8}
!60 = !{!"long", !52, i64 0}
!61 = !{!"_ZTSSt6atomicImE"}
!62 = !{!56, !56, i64 0}
!63 = !{!64, !56, i64 0}
!64 = !{!"_ZTSN6parlay15block_allocator5blockE", !56, i64 0}
!65 = distinct !{!65, !66}
!66 = !{!"llvm.loop.unroll.disable"}
!67 = distinct !{!67, !68}
!68 = !{!"llvm.loop.fromtapirloop"}
!69 = !{!"branch_weights", i32 12579265, i32 18241}
!70 = !{!"branch_weights", i32 18241, i32 54723}
!71 = distinct !{!71, !66}
!72 = !{!"branch_weights", i32 18241, i32 12579265}
!73 = distinct !{!73, !74}
!74 = !{!"llvm.loop.mustprogress"}
!75 = distinct !{!75, !76, !66}
!76 = !{!"llvm.loop.peeled.count", i32 2}
!77 = !{!44, !36, i64 40}
