; RUN: opt < %s -loop-spawning-ti -simplifycfg -functionattrs -tapir2target -S -o - | FileCheck %s
; RUN: opt < %s -loop-spawning-ti -simplifycfg -functionattrs -tapir2target -always-inline -S -o - | FileCheck %s
; RUN: opt < %s -passes="loop-spawning,function(simplify-cfg),cgscc(function-attrs),tapir2target" -S -o - | FileCheck %s
; RUN: opt < %s -passes="loop-spawning,function(simplify-cfg),cgscc(function-attrs),tapir2target,always-inline" -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.timer = type <{ double, double, double, i8, [3 x i8], %struct.timezone, [4 x i8] }>
%struct.timezone = type { i32, i32 }
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
%struct.timeval = type { i64, i64 }
%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i64, %union.anon }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider" = type { i8* }
%union.anon = type { i64, [8 x i8] }
%struct.seg = type { i32, i32 }
%"struct.std::pair" = type { i32, i32 }
%struct.__cilkrts_stack_frame = type { i32, i32, %struct.__cilkrts_stack_frame*, %struct.__cilkrts_worker*, [5 x i8*], i32 }
%struct.__cilkrts_worker = type { %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, i32, %struct.global_state*, %struct.local_state*, %struct.__cilkrts_stack_frame*, %struct.cilkred_map* }
%struct.global_state = type { %struct.rts_options, i32, %struct.__cilkrts_worker**, %struct.ReadyDeque*, i64*, %struct.Closure*, [56 x i8], %struct.cilk_fiber_pool, %struct.global_im_pool, [8 x i8], %struct.cilk_im_desc, %union.cilk_mutex, i8, i8, i8, i32, i32, %union.cilk_mutex, i32, i8**, %struct.reducer_id_manager*, %struct.global_sched_stats, [56 x i8] }
%struct.rts_options = type { i64, i32, i32, i32, i32, i32 }
%struct.ReadyDeque = type { %union.cilk_mutex, %struct.Closure*, %struct.Closure*, i32, [36 x i8] }
%struct.Closure = type { %union.cilk_mutex, %struct.__cilkrts_stack_frame*, %struct.cilk_fiber*, %struct.cilk_fiber*, i32, i32, i8, i8, i8, i8, i32, i8*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i8*, i8*, %struct.cilkred_map*, %struct.cilkred_map*, %struct.cilkred_map*, [8 x i8] }
%struct.cilk_fiber = type opaque
%struct.cilk_fiber_pool = type { %union.cilk_mutex, i32, i32, i64, %struct.cilk_fiber_pool*, %struct.cilk_fiber**, i32, i32, %struct.fiber_pool_stats }
%struct.fiber_pool_stats = type { i32, i32, i32 }
%struct.global_im_pool = type { i8*, i8*, i8**, i32, i32, i64, i64, i64 }
%struct.cilk_im_desc = type { [7 x %struct.im_bucket], i64, [4 x i64] }
%struct.im_bucket = type { i8*, i32, i32, i32, i32, i64 }
%union.cilk_mutex = type { i32 }
%struct.reducer_id_manager = type opaque
%struct.global_sched_stats = type { [3 x double] }
%struct.local_state = type opaque
%struct.cilkred_map = type { i32, i32, i32, i8, i32*, %struct.view_info* }
%struct.view_info = type { i8*, %struct.__cilkrts_hyperobject_base* }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i32, i32, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base*, i64)*, void (%struct.__cilkrts_hyperobject_base*, i8*)* }

@_ZL3_tm = internal global %struct.timer zeroinitializer, align 8
@_ZSt4cout = external dso_local global %"class.std::basic_ostream", align 8
@.str.6 = private unnamed_addr constant [5 x i8] c"m = \00", align 1
@.str.7 = private unnamed_addr constant [6 x i8] c" n = \00", align 1
@.str.8 = private unnamed_addr constant [3 x i8] c", \00", align 1
@.str.11 = private unnamed_addr constant [6 x i8] c"split\00", align 1
@.str.12 = private unnamed_addr constant [31 x i8] c"Suffix Array:  Too many rounds\00", align 1
@.str.13 = private unnamed_addr constant [9 x i8] c"nSegs = \00", align 1
@.str.14 = private unnamed_addr constant [10 x i8] c" nKeys = \00", align 1
@.str.15 = private unnamed_addr constant [18 x i8] c" common length = \00", align 1
@.str.16 = private unnamed_addr constant [16 x i8] c"filter and scan\00", align 1
@.str.17 = private unnamed_addr constant [4 x i8] c" : \00", align 1

; Function Attrs: uwtable
define dso_local i32* @_Z19suffixArrayInternalPhl(i8* nocapture readonly %ss, i64 %n) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %now.i.i.i.i966 = alloca %struct.timeval, align 8
  %syncreg.i = tail call token @llvm.syncregion.start()
  %now.i.i.i.i920 = alloca %struct.timeval, align 8
  %now.i.i.i.i874 = alloca %struct.timeval, align 8
  %__dnew.i.i.i.i783 = alloca i64, align 8
  %now.i.i.i.i757 = alloca %struct.timeval, align 8
  %now.i.i.i.i716 = alloca %struct.timeval, align 8
  %now.i.i.i.i = alloca %struct.timeval, align 8
  %now.i.i = alloca %struct.timeval, align 8
  %flags = alloca [256 x i32], align 16
  %0 = bitcast [256 x i32]* %flags to i8*
  %agg.tmp142 = alloca %"class.std::__cxx11::basic_string", align 8
  %agg.tmp147 = alloca %"class.std::__cxx11::basic_string", align 8
  %agg.tmp162 = alloca %"class.std::__cxx11::basic_string", align 8
  %agg.tmp179 = alloca %"class.std::__cxx11::basic_string", align 8
  %agg.tmp237 = alloca %"class.std::__cxx11::basic_string", align 8
  %agg.tmp331 = alloca %"class.std::__cxx11::basic_string", align 8
  %agg.tmp384 = alloca %"class.std::__cxx11::basic_string", align 8
  store i8 1, i8* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 3), align 8, !tbaa !2
  %1 = bitcast %struct.timeval* %now.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %1) #16
  %call.i.i = call i32 @gettimeofday(%struct.timeval* nonnull %now.i.i, i8* nonnull bitcast (%struct.timezone* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 5) to i8*)) #16
  %tv_sec.i.i = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i, i64 0, i32 0
  %2 = load i64, i64* %tv_sec.i.i, align 8, !tbaa !10
  %conv.i.i = sitofp i64 %2 to double
  %tv_usec.i.i = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i, i64 0, i32 1
  %3 = load i64, i64* %tv_usec.i.i, align 8, !tbaa !13
  %conv2.i.i = sitofp i64 %3 to double
  %div.i.i = fdiv double %conv2.i.i, 1.000000e+06
  %add.i.i = fadd double %div.i.i, %conv.i.i
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %1) #16
  store double %add.i.i, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  %add = add i64 %n, 48
  %call = tail call noalias i8* @malloc(i64 %add) #16
  call void @llvm.lifetime.start.p0i8(i64 1024, i8* nonnull %0) #16
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(1024) %0, i8 0, i64 1024, i1 false)
  %conv = trunc i64 %n to i32
  %cmp1 = icmp ne i32 %conv, 0
  br i1 %cmp1, label %pfor.cond.preheader, label %for.body41.i.i.preheader

pfor.cond.preheader:                              ; preds = %entry
  %wide.trip.count1129 = and i64 %n, 4294967295
  %4 = add nsw i64 %wide.trip.count1129, -1
  %xtraiter1185 = and i64 %n, 2047
  %5 = icmp ult i64 %4, 2047
  br i1 %5, label %pfor.cond.cleanup.strpm-lcssa, label %pfor.cond.preheader.new

pfor.cond.preheader.new:                          ; preds = %pfor.cond.preheader
  %stripiter11881196 = lshr i64 %n, 11
  %stripiter1188.zext = and i64 %stripiter11881196, 2097151
  br label %pfor.cond.strpm.outer

pfor.cond.strpm.outer:                            ; preds = %pfor.inc.strpm.outer, %pfor.cond.preheader.new
  %niter1189 = phi i64 [ 0, %pfor.cond.preheader.new ], [ %niter1189.nadd, %pfor.inc.strpm.outer ]
  detach within %syncreg.i, label %pfor.body.strpm.outer, label %pfor.inc.strpm.outer

pfor.body.strpm.outer:                            ; preds = %pfor.cond.strpm.outer
  %6 = shl i64 %niter1189, 11
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.preattach.3, %pfor.body.strpm.outer
  %indvars.iv1127 = phi i64 [ %6, %pfor.body.strpm.outer ], [ %indvars.iv.next1128.3, %pfor.preattach.3 ]
  %inneriter1190 = phi i64 [ 2048, %pfor.body.strpm.outer ], [ %inneriter1190.nsub.3, %pfor.preattach.3 ]
  %indvars.iv.next1128 = or i64 %indvars.iv1127, 1
  %arrayidx8 = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv1127
  %7 = load i8, i8* %arrayidx8, align 1, !tbaa !15
  %idxprom9 = zext i8 %7 to i64
  %arrayidx10 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9
  %8 = load i32, i32* %arrayidx10, align 4, !tbaa !16
  %tobool = icmp eq i32 %8, 0
  br i1 %tobool, label %if.then, label %pfor.preattach

if.then:                                          ; preds = %pfor.cond
  store i32 1, i32* %arrayidx10, align 4, !tbaa !16
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %if.then, %pfor.cond
  %indvars.iv.next1128.1 = or i64 %indvars.iv1127, 2
  %arrayidx8.1 = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv.next1128
  %9 = load i8, i8* %arrayidx8.1, align 1, !tbaa !15
  %idxprom9.1 = zext i8 %9 to i64
  %arrayidx10.1 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9.1
  %10 = load i32, i32* %arrayidx10.1, align 4, !tbaa !16
  %tobool.1 = icmp eq i32 %10, 0
  br i1 %tobool.1, label %if.then.1, label %pfor.preattach.1

pfor.inc.reattach:                                ; preds = %pfor.preattach.3
  reattach within %syncreg.i, label %pfor.inc.strpm.outer

pfor.inc.strpm.outer:                             ; preds = %pfor.inc.reattach, %pfor.cond.strpm.outer
  %niter1189.nadd = add nuw nsw i64 %niter1189, 1
  %niter1189.ncmp = icmp eq i64 %niter1189.nadd, %stripiter1188.zext
  br i1 %niter1189.ncmp, label %pfor.cond.cleanup.strpm-lcssa.loopexit, label %pfor.cond.strpm.outer, !llvm.loop !17

pfor.cond.cleanup.strpm-lcssa.loopexit:           ; preds = %pfor.inc.strpm.outer
  br label %pfor.cond.cleanup.strpm-lcssa

pfor.cond.cleanup.strpm-lcssa:                    ; preds = %pfor.cond.cleanup.strpm-lcssa.loopexit, %pfor.cond.preheader
  %lcmp.mod1191 = icmp eq i64 %xtraiter1185, 0
  br i1 %lcmp.mod1191, label %pfor.cond.cleanup, label %pfor.cond.epil.preheader

pfor.cond.epil.preheader:                         ; preds = %pfor.cond.cleanup.strpm-lcssa
  %11 = and i64 %n, 4294965248
  %12 = add nsw i64 %xtraiter1185, -1
  %xtraiter1525 = and i64 %n, 3
  %lcmp.mod1526 = icmp eq i64 %xtraiter1525, 0
  br i1 %lcmp.mod1526, label %pfor.cond.epil.prol.loopexit, label %pfor.cond.epil.prol.preheader

pfor.cond.epil.prol.preheader:                    ; preds = %pfor.cond.epil.preheader
  br label %pfor.cond.epil.prol

pfor.cond.epil.prol:                              ; preds = %pfor.cond.epil.prol.preheader, %pfor.preattach.epil.prol
  %indvars.iv1127.epil.prol = phi i64 [ %indvars.iv.next1128.epil.prol, %pfor.preattach.epil.prol ], [ %11, %pfor.cond.epil.prol.preheader ]
  %epil.iter1186.prol = phi i64 [ %epil.iter1186.sub.prol, %pfor.preattach.epil.prol ], [ %xtraiter1185, %pfor.cond.epil.prol.preheader ]
  %prol.iter1527 = phi i64 [ %prol.iter1527.sub, %pfor.preattach.epil.prol ], [ %xtraiter1525, %pfor.cond.epil.prol.preheader ]
  %indvars.iv.next1128.epil.prol = add nuw nsw i64 %indvars.iv1127.epil.prol, 1
  %arrayidx8.epil.prol = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv1127.epil.prol
  %13 = load i8, i8* %arrayidx8.epil.prol, align 1, !tbaa !15
  %idxprom9.epil.prol = zext i8 %13 to i64
  %arrayidx10.epil.prol = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9.epil.prol
  %14 = load i32, i32* %arrayidx10.epil.prol, align 4, !tbaa !16
  %tobool.epil.prol = icmp eq i32 %14, 0
  br i1 %tobool.epil.prol, label %if.then.epil.prol, label %pfor.preattach.epil.prol

if.then.epil.prol:                                ; preds = %pfor.cond.epil.prol
  store i32 1, i32* %arrayidx10.epil.prol, align 4, !tbaa !16
  br label %pfor.preattach.epil.prol

pfor.preattach.epil.prol:                         ; preds = %if.then.epil.prol, %pfor.cond.epil.prol
  %epil.iter1186.sub.prol = add nsw i64 %epil.iter1186.prol, -1
  %prol.iter1527.sub = add i64 %prol.iter1527, -1
  %prol.iter1527.cmp = icmp eq i64 %prol.iter1527.sub, 0
  br i1 %prol.iter1527.cmp, label %pfor.cond.epil.prol.loopexit.loopexit, label %pfor.cond.epil.prol, !llvm.loop !20

pfor.cond.epil.prol.loopexit.loopexit:            ; preds = %pfor.preattach.epil.prol
  %epil.iter1186.sub.prol.lcssa = phi i64 [ %epil.iter1186.sub.prol, %pfor.preattach.epil.prol ]
  %indvars.iv.next1128.epil.prol.lcssa = phi i64 [ %indvars.iv.next1128.epil.prol, %pfor.preattach.epil.prol ]
  br label %pfor.cond.epil.prol.loopexit

pfor.cond.epil.prol.loopexit:                     ; preds = %pfor.cond.epil.prol.loopexit.loopexit, %pfor.cond.epil.preheader
  %indvars.iv1127.epil.unr = phi i64 [ %11, %pfor.cond.epil.preheader ], [ %indvars.iv.next1128.epil.prol.lcssa, %pfor.cond.epil.prol.loopexit.loopexit ]
  %epil.iter1186.unr = phi i64 [ %xtraiter1185, %pfor.cond.epil.preheader ], [ %epil.iter1186.sub.prol.lcssa, %pfor.cond.epil.prol.loopexit.loopexit ]
  %15 = icmp ult i64 %12, 3
  br i1 %15, label %pfor.cond.cleanup, label %pfor.cond.epil.preheader3

pfor.cond.epil.preheader3:                        ; preds = %pfor.cond.epil.prol.loopexit
  br label %pfor.cond.epil

pfor.cond.epil:                                   ; preds = %pfor.cond.epil.preheader3, %pfor.preattach.epil.3
  %indvars.iv1127.epil = phi i64 [ %indvars.iv.next1128.epil.3, %pfor.preattach.epil.3 ], [ %indvars.iv1127.epil.unr, %pfor.cond.epil.preheader3 ]
  %epil.iter1186 = phi i64 [ %epil.iter1186.sub.3, %pfor.preattach.epil.3 ], [ %epil.iter1186.unr, %pfor.cond.epil.preheader3 ]
  %indvars.iv.next1128.epil = add nuw nsw i64 %indvars.iv1127.epil, 1
  %arrayidx8.epil = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv1127.epil
  %16 = load i8, i8* %arrayidx8.epil, align 1, !tbaa !15
  %idxprom9.epil = zext i8 %16 to i64
  %arrayidx10.epil = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9.epil
  %17 = load i32, i32* %arrayidx10.epil, align 4, !tbaa !16
  %tobool.epil = icmp eq i32 %17, 0
  br i1 %tobool.epil, label %if.then.epil, label %pfor.preattach.epil

if.then.epil:                                     ; preds = %pfor.cond.epil
  store i32 1, i32* %arrayidx10.epil, align 4, !tbaa !16
  br label %pfor.preattach.epil

pfor.preattach.epil:                              ; preds = %if.then.epil, %pfor.cond.epil
  %indvars.iv.next1128.epil.1 = add nuw nsw i64 %indvars.iv1127.epil, 2
  %arrayidx8.epil.1 = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv.next1128.epil
  %18 = load i8, i8* %arrayidx8.epil.1, align 1, !tbaa !15
  %idxprom9.epil.1 = zext i8 %18 to i64
  %arrayidx10.epil.1 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9.epil.1
  %19 = load i32, i32* %arrayidx10.epil.1, align 4, !tbaa !16
  %tobool.epil.1 = icmp eq i32 %19, 0
  br i1 %tobool.epil.1, label %if.then.epil.1, label %pfor.preattach.epil.1

pfor.cond.cleanup.loopexit:                       ; preds = %pfor.preattach.epil.3
  br label %pfor.cond.cleanup

pfor.cond.cleanup:                                ; preds = %pfor.cond.cleanup.loopexit, %pfor.cond.epil.prol.loopexit, %pfor.cond.cleanup.strpm-lcssa
  sync within %syncreg.i, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  tail call void @llvm.sync.unwind(token %syncreg.i)
  br label %for.body41.i.i.preheader

for.body41.i.i.preheader:                         ; preds = %sync.continue, %entry
  br label %for.body41.i.i

for.body41.i.i:                                   ; preds = %for.body41.i.i, %for.body41.i.i.preheader
  %indvars.iv125.i.i = phi i64 [ 0, %for.body41.i.i.preheader ], [ %indvars.iv.next126.i.i.7, %for.body41.i.i ]
  %r.3119.i.i = phi i32 [ 1, %for.body41.i.i.preheader ], [ %add.i.i.i.7, %for.body41.i.i ]
  %arrayidx.i79.i.i = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %indvars.iv125.i.i
  %20 = load i32, i32* %arrayidx.i79.i.i, align 16, !tbaa !16
  store i32 %r.3119.i.i, i32* %arrayidx.i79.i.i, align 16, !tbaa !16
  %add.i.i.i = add i32 %20, %r.3119.i.i
  %indvars.iv.next126.i.i = or i64 %indvars.iv125.i.i, 1
  %arrayidx.i79.i.i.1 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %indvars.iv.next126.i.i
  %21 = load i32, i32* %arrayidx.i79.i.i.1, align 4, !tbaa !16
  store i32 %add.i.i.i, i32* %arrayidx.i79.i.i.1, align 4, !tbaa !16
  %add.i.i.i.1 = add i32 %21, %add.i.i.i
  %indvars.iv.next126.i.i.1 = or i64 %indvars.iv125.i.i, 2
  %arrayidx.i79.i.i.2 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %indvars.iv.next126.i.i.1
  %22 = load i32, i32* %arrayidx.i79.i.i.2, align 8, !tbaa !16
  store i32 %add.i.i.i.1, i32* %arrayidx.i79.i.i.2, align 8, !tbaa !16
  %add.i.i.i.2 = add i32 %22, %add.i.i.i.1
  %indvars.iv.next126.i.i.2 = or i64 %indvars.iv125.i.i, 3
  %arrayidx.i79.i.i.3 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %indvars.iv.next126.i.i.2
  %23 = load i32, i32* %arrayidx.i79.i.i.3, align 4, !tbaa !16
  store i32 %add.i.i.i.2, i32* %arrayidx.i79.i.i.3, align 4, !tbaa !16
  %add.i.i.i.3 = add i32 %23, %add.i.i.i.2
  %indvars.iv.next126.i.i.3 = or i64 %indvars.iv125.i.i, 4
  %arrayidx.i79.i.i.4 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %indvars.iv.next126.i.i.3
  %24 = load i32, i32* %arrayidx.i79.i.i.4, align 16, !tbaa !16
  store i32 %add.i.i.i.3, i32* %arrayidx.i79.i.i.4, align 16, !tbaa !16
  %add.i.i.i.4 = add i32 %24, %add.i.i.i.3
  %indvars.iv.next126.i.i.4 = or i64 %indvars.iv125.i.i, 5
  %arrayidx.i79.i.i.5 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %indvars.iv.next126.i.i.4
  %25 = load i32, i32* %arrayidx.i79.i.i.5, align 4, !tbaa !16
  store i32 %add.i.i.i.4, i32* %arrayidx.i79.i.i.5, align 4, !tbaa !16
  %add.i.i.i.5 = add i32 %25, %add.i.i.i.4
  %indvars.iv.next126.i.i.5 = or i64 %indvars.iv125.i.i, 6
  %arrayidx.i79.i.i.6 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %indvars.iv.next126.i.i.5
  %26 = load i32, i32* %arrayidx.i79.i.i.6, align 8, !tbaa !16
  store i32 %add.i.i.i.5, i32* %arrayidx.i79.i.i.6, align 8, !tbaa !16
  %add.i.i.i.6 = add i32 %26, %add.i.i.i.5
  %indvars.iv.next126.i.i.6 = or i64 %indvars.iv125.i.i, 7
  %arrayidx.i79.i.i.7 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %indvars.iv.next126.i.i.6
  %27 = load i32, i32* %arrayidx.i79.i.i.7, align 4, !tbaa !16
  store i32 %add.i.i.i.6, i32* %arrayidx.i79.i.i.7, align 4, !tbaa !16
  %add.i.i.i.7 = add i32 %27, %add.i.i.i.6
  %indvars.iv.next126.i.i.7 = add nuw nsw i64 %indvars.iv125.i.i, 8
  %exitcond128.i.i.7 = icmp eq i64 %indvars.iv.next126.i.i.7, 256
  br i1 %exitcond128.i.i.7, label %_ZN8sequence4scanIjiN5utils4addFIjEENS_4getAIjiEELi1024EEET_PS6_T0_S8_T1_T2_S6_bb.exit, label %for.body41.i.i

_ZN8sequence4scanIjiN5utils4addFIjEENS_4getAIjiEELi1024EEET_PS6_T0_S8_T1_T2_S6_bb.exit: ; preds = %for.body41.i.i
  %add.i.i.i.7.lcssa = phi i32 [ %add.i.i.i.7, %for.body41.i.i ]
  %call1.i = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([5 x i8], [5 x i8]* @.str.6, i64 0, i64 0), i64 4)
  %conv.i = zext i32 %add.i.i.i.7.lcssa to i64
  %call.i = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream"* nonnull @_ZSt4cout, i64 %conv.i)
  %call1.i669 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i, i8* nonnull getelementptr inbounds ([6 x i8], [6 x i8]* @.str.7, i64 0, i64 0), i64 5)
  %call.i670 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIlEERSoT_(%"class.std::basic_ostream"* nonnull %call.i, i64 %n)
  %28 = bitcast %"class.std::basic_ostream"* %call.i670 to i8**
  %vtable.i = load i8*, i8** %28, align 8, !tbaa !22
  %vbase.offset.ptr.i = getelementptr i8, i8* %vtable.i, i64 -24
  %29 = bitcast i8* %vbase.offset.ptr.i to i64*
  %vbase.offset.i = load i64, i64* %29, align 8
  %30 = bitcast %"class.std::basic_ostream"* %call.i670 to i8*
  %add.ptr.i = getelementptr inbounds i8, i8* %30, i64 %vbase.offset.i
  %_M_ctype.i = getelementptr inbounds i8, i8* %add.ptr.i, i64 240
  %31 = bitcast i8* %_M_ctype.i to %"class.std::ctype"**
  %32 = load %"class.std::ctype"*, %"class.std::ctype"** %31, align 8, !tbaa !24
  %tobool.i1024 = icmp eq %"class.std::ctype"* %32, null
  br i1 %tobool.i1024, label %if.then.i1025, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit

if.then.i1025:                                    ; preds = %_ZN8sequence4scanIjiN5utils4addFIjEENS_4getAIjiEELi1024EEET_PS6_T0_S8_T1_T2_S6_bb.exit
  tail call void @_ZSt16__throw_bad_castv() #17
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit:    ; preds = %_ZN8sequence4scanIjiN5utils4addFIjEENS_4getAIjiEELi1024EEET_PS6_T0_S8_T1_T2_S6_bb.exit
  %_M_widen_ok.i = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %32, i64 0, i32 8
  %33 = load i8, i8* %_M_widen_ok.i, align 8, !tbaa !27
  %tobool.i993 = icmp eq i8 %33, 0
  br i1 %tobool.i993, label %if.end.i998, label %if.then.i995

if.then.i995:                                     ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit
  %arrayidx.i994 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %32, i64 0, i32 9, i64 10
  %34 = load i8, i8* %arrayidx.i994, align 1, !tbaa !15
  br label %_ZNKSt5ctypeIcE5widenEc.exit

if.end.i998:                                      ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %32)
  %35 = bitcast %"class.std::ctype"* %32 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i996 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %35, align 8, !tbaa !22
  %vfn.i = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i996, i64 6
  %36 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i, align 8
  %call.i997 = tail call signext i8 %36(%"class.std::ctype"* nonnull %32, i8 signext 10)
  br label %_ZNKSt5ctypeIcE5widenEc.exit

_ZNKSt5ctypeIcE5widenEc.exit:                     ; preds = %if.end.i998, %if.then.i995
  %retval.0.i999 = phi i8 [ %34, %if.then.i995 ], [ %call.i997, %if.end.i998 ]
  %call1.i673 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i670, i8 signext %retval.0.i999)
  %call.i674 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i673)
  br i1 %cmp1, label %pfor.cond38.preheader, label %cleanup61

pfor.cond38.preheader:                            ; preds = %_ZNKSt5ctypeIcE5widenEc.exit
  %wide.trip.count1125 = and i64 %n, 4294967295
  %37 = add nsw i64 %wide.trip.count1125, -1
  %xtraiter1178 = and i64 %n, 2047
  %38 = icmp ult i64 %37, 2047
  br i1 %38, label %pfor.cond.cleanup56.strpm-lcssa, label %pfor.cond38.preheader.new

pfor.cond38.preheader.new:                        ; preds = %pfor.cond38.preheader
  %stripiter11811195 = lshr i64 %n, 11
  %stripiter1181.zext = and i64 %stripiter11811195, 2097151
  br label %pfor.cond38.strpm.outer

pfor.cond38.strpm.outer:                          ; preds = %pfor.inc53.strpm.outer, %pfor.cond38.preheader.new
  %niter1182 = phi i64 [ 0, %pfor.cond38.preheader.new ], [ %niter1182.nadd, %pfor.inc53.strpm.outer ]
  detach within %syncreg.i, label %pfor.body44.strpm.outer, label %pfor.inc53.strpm.outer

pfor.body44.strpm.outer:                          ; preds = %pfor.cond38.strpm.outer
  %39 = shl i64 %niter1182, 11
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %pfor.body44.strpm.outer
  %index = phi i64 [ 0, %pfor.body44.strpm.outer ], [ %index.next.3, %vector.body ]
  %offset.idx = add nuw nsw i64 %39, %index
  %40 = getelementptr inbounds i8, i8* %ss, i64 %offset.idx
  %41 = bitcast i8* %40 to <8 x i8>*
  %wide.load = load <8 x i8>, <8 x i8>* %41, align 1, !tbaa !15
  %42 = zext <8 x i8> %wide.load to <8 x i64>
  %43 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, <8 x i64> %42
  %wide.masked.gather = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %43, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <8 x i32> undef), !tbaa !16
  %44 = trunc <8 x i32> %wide.masked.gather to <8 x i8>
  %45 = getelementptr inbounds i8, i8* %call, i64 %offset.idx
  %46 = bitcast i8* %45 to <8 x i8>*
  store <8 x i8> %44, <8 x i8>* %46, align 1, !tbaa !15
  %index.next = or i64 %index, 8
  %offset.idx.1 = add nuw nsw i64 %39, %index.next
  %47 = getelementptr inbounds i8, i8* %ss, i64 %offset.idx.1
  %48 = bitcast i8* %47 to <8 x i8>*
  %wide.load.1 = load <8 x i8>, <8 x i8>* %48, align 1, !tbaa !15
  %49 = zext <8 x i8> %wide.load.1 to <8 x i64>
  %50 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, <8 x i64> %49
  %wide.masked.gather.1 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %50, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <8 x i32> undef), !tbaa !16
  %51 = trunc <8 x i32> %wide.masked.gather.1 to <8 x i8>
  %52 = getelementptr inbounds i8, i8* %call, i64 %offset.idx.1
  %53 = bitcast i8* %52 to <8 x i8>*
  store <8 x i8> %51, <8 x i8>* %53, align 1, !tbaa !15
  %index.next.1 = or i64 %index, 16
  %offset.idx.2 = add nuw nsw i64 %39, %index.next.1
  %54 = getelementptr inbounds i8, i8* %ss, i64 %offset.idx.2
  %55 = bitcast i8* %54 to <8 x i8>*
  %wide.load.2 = load <8 x i8>, <8 x i8>* %55, align 1, !tbaa !15
  %56 = zext <8 x i8> %wide.load.2 to <8 x i64>
  %57 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, <8 x i64> %56
  %wide.masked.gather.2 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %57, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <8 x i32> undef), !tbaa !16
  %58 = trunc <8 x i32> %wide.masked.gather.2 to <8 x i8>
  %59 = getelementptr inbounds i8, i8* %call, i64 %offset.idx.2
  %60 = bitcast i8* %59 to <8 x i8>*
  store <8 x i8> %58, <8 x i8>* %60, align 1, !tbaa !15
  %index.next.2 = or i64 %index, 24
  %offset.idx.3 = add nuw nsw i64 %39, %index.next.2
  %61 = getelementptr inbounds i8, i8* %ss, i64 %offset.idx.3
  %62 = bitcast i8* %61 to <8 x i8>*
  %wide.load.3 = load <8 x i8>, <8 x i8>* %62, align 1, !tbaa !15
  %63 = zext <8 x i8> %wide.load.3 to <8 x i64>
  %64 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, <8 x i64> %63
  %wide.masked.gather.3 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %64, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <8 x i32> undef), !tbaa !16
  %65 = trunc <8 x i32> %wide.masked.gather.3 to <8 x i8>
  %66 = getelementptr inbounds i8, i8* %call, i64 %offset.idx.3
  %67 = bitcast i8* %66 to <8 x i8>*
  store <8 x i8> %65, <8 x i8>* %67, align 1, !tbaa !15
  %index.next.3 = add nuw nsw i64 %index, 32
  %68 = icmp eq i64 %index.next.3, 2048
  br i1 %68, label %pfor.inc53.reattach, label %vector.body, !llvm.loop !29

pfor.inc53.reattach:                              ; preds = %vector.body
  reattach within %syncreg.i, label %pfor.inc53.strpm.outer

pfor.inc53.strpm.outer:                           ; preds = %pfor.inc53.reattach, %pfor.cond38.strpm.outer
  %niter1182.nadd = add nuw nsw i64 %niter1182, 1
  %niter1182.ncmp = icmp eq i64 %niter1182.nadd, %stripiter1181.zext
  br i1 %niter1182.ncmp, label %pfor.cond.cleanup56.strpm-lcssa.loopexit, label %pfor.cond38.strpm.outer, !llvm.loop !32

pfor.cond.cleanup56.strpm-lcssa.loopexit:         ; preds = %pfor.inc53.strpm.outer
  br label %pfor.cond.cleanup56.strpm-lcssa

pfor.cond.cleanup56.strpm-lcssa:                  ; preds = %pfor.cond.cleanup56.strpm-lcssa.loopexit, %pfor.cond38.preheader
  %lcmp.mod1184 = icmp eq i64 %xtraiter1178, 0
  br i1 %lcmp.mod1184, label %pfor.cond.cleanup56, label %pfor.cond38.epil.preheader

pfor.cond38.epil.preheader:                       ; preds = %pfor.cond.cleanup56.strpm-lcssa
  %69 = and i64 %n, 4294965248
  %min.iters.check = icmp ult i64 %xtraiter1178, 8
  br i1 %min.iters.check, label %pfor.cond38.epil.preheader1501, label %vector.ph1211

vector.ph1211:                                    ; preds = %pfor.cond38.epil.preheader
  %n.mod.vf = and i64 %n, 7
  %n.vec = sub nsw i64 %xtraiter1178, %n.mod.vf
  %ind.end1215 = add nsw i64 %69, %n.vec
  br label %vector.body1210

vector.body1210:                                  ; preds = %vector.body1210, %vector.ph1211
  %index1212 = phi i64 [ 0, %vector.ph1211 ], [ %index.next1213, %vector.body1210 ]
  %offset.idx1219 = add i64 %69, %index1212
  %70 = getelementptr inbounds i8, i8* %ss, i64 %offset.idx1219
  %71 = bitcast i8* %70 to <8 x i8>*
  %wide.load1227 = load <8 x i8>, <8 x i8>* %71, align 1, !tbaa !15
  %72 = zext <8 x i8> %wide.load1227 to <8 x i64>
  %73 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, <8 x i64> %72
  %wide.masked.gather1228 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %73, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <8 x i32> undef), !tbaa !16
  %74 = trunc <8 x i32> %wide.masked.gather1228 to <8 x i8>
  %75 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1219
  %76 = bitcast i8* %75 to <8 x i8>*
  store <8 x i8> %74, <8 x i8>* %76, align 1, !tbaa !15
  %index.next1213 = add i64 %index1212, 8
  %77 = icmp eq i64 %index.next1213, %n.vec
  br i1 %77, label %middle.block1208, label %vector.body1210, !llvm.loop !33

middle.block1208:                                 ; preds = %vector.body1210
  %cmp.n1218 = icmp eq i64 %n.mod.vf, 0
  br i1 %cmp.n1218, label %pfor.cond.cleanup56, label %pfor.cond38.epil.preheader1501

pfor.cond38.epil.preheader1501:                   ; preds = %middle.block1208, %pfor.cond38.epil.preheader
  %indvars.iv1123.epil.ph = phi i64 [ %69, %pfor.cond38.epil.preheader ], [ %ind.end1215, %middle.block1208 ]
  %epil.iter1179.ph = phi i64 [ %xtraiter1178, %pfor.cond38.epil.preheader ], [ %n.mod.vf, %middle.block1208 ]
  br label %pfor.cond38.epil

pfor.cond38.epil:                                 ; preds = %pfor.cond38.epil, %pfor.cond38.epil.preheader1501
  %indvars.iv1123.epil = phi i64 [ %indvars.iv.next1124.epil, %pfor.cond38.epil ], [ %indvars.iv1123.epil.ph, %pfor.cond38.epil.preheader1501 ]
  %epil.iter1179 = phi i64 [ %epil.iter1179.sub, %pfor.cond38.epil ], [ %epil.iter1179.ph, %pfor.cond38.epil.preheader1501 ]
  %indvars.iv.next1124.epil = add nuw nsw i64 %indvars.iv1123.epil, 1
  %arrayidx46.epil = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv1123.epil
  %78 = load i8, i8* %arrayidx46.epil, align 1, !tbaa !15
  %idxprom47.epil = zext i8 %78 to i64
  %arrayidx48.epil = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom47.epil
  %79 = load i32, i32* %arrayidx48.epil, align 4, !tbaa !16
  %conv49.epil = trunc i32 %79 to i8
  %arrayidx51.epil = getelementptr inbounds i8, i8* %call, i64 %indvars.iv1123.epil
  store i8 %conv49.epil, i8* %arrayidx51.epil, align 1, !tbaa !15
  %epil.iter1179.sub = add nsw i64 %epil.iter1179, -1
  %epil.iter1179.cmp = icmp eq i64 %epil.iter1179.sub, 0
  br i1 %epil.iter1179.cmp, label %pfor.cond.cleanup56.loopexit, label %pfor.cond38.epil, !llvm.loop !34

pfor.cond.cleanup56.loopexit:                     ; preds = %pfor.cond38.epil
  br label %pfor.cond.cleanup56

pfor.cond.cleanup56:                              ; preds = %pfor.cond.cleanup56.loopexit, %middle.block1208, %pfor.cond.cleanup56.strpm-lcssa
  sync within %syncreg.i, label %sync.continue58

sync.continue58:                                  ; preds = %pfor.cond.cleanup56
  tail call void @llvm.sync.unwind(token %syncreg.i)
  br label %cleanup61

cleanup61:                                        ; preds = %sync.continue58, %_ZNKSt5ctypeIcE5widenEc.exit
  %conv671072 = and i64 %n, 4294967295
  %cmp691073 = icmp ugt i64 %add, %conv671072
  br i1 %cmp691073, label %for.body71.preheader, label %for.cond.cleanup70

for.body71.preheader:                             ; preds = %cleanup61
  %80 = add i64 %n, 1
  %81 = and i64 %80, 4294967295
  %82 = icmp ugt i64 %add, %81
  %umax1232 = select i1 %82, i64 %add, i64 %81
  %83 = add i64 %umax1232, 1
  %84 = sub i64 %83, %81
  %min.iters.check1233 = icmp ult i64 %84, 128
  br i1 %min.iters.check1233, label %for.body71.preheader1500, label %vector.scevcheck

for.body71.preheader1500:                         ; preds = %middle.block1229, %vector.scevcheck, %for.body71.preheader
  %conv671075.ph = phi i64 [ %conv671072, %vector.scevcheck ], [ %conv671072, %for.body71.preheader ], [ %ind.end1245, %middle.block1229 ]
  %i64.01074.ph = phi i32 [ %conv, %vector.scevcheck ], [ %conv, %for.body71.preheader ], [ %ind.end1247, %middle.block1229 ]
  br label %for.body71

vector.scevcheck:                                 ; preds = %for.body71.preheader
  %85 = call i64 @llvm.usub.sat.i64(i64 %add, i64 %81)
  %86 = trunc i64 %85 to i32
  %87 = xor i32 %conv, -1
  %88 = icmp ult i32 %87, %86
  %89 = icmp ugt i64 %85, 4294967295
  %90 = sub i32 -2, %conv
  %91 = icmp ult i32 %90, %86
  %92 = or i1 %91, %89
  %93 = or i1 %88, %92
  br i1 %93, label %for.body71.preheader1500, label %vector.ph1239

vector.ph1239:                                    ; preds = %vector.scevcheck
  %n.vec1241 = and i64 %84, -128
  %ind.end1245 = add i64 %conv671072, %n.vec1241
  %cast.crd = trunc i64 %n.vec1241 to i32
  %ind.end1247 = add i32 %conv, %cast.crd
  %94 = add i64 %n.vec1241, -128
  %95 = lshr exact i64 %94, 7
  %96 = add nuw nsw i64 %95, 1
  %xtraiter1520 = and i64 %96, 7
  %97 = icmp ult i64 %94, 896
  br i1 %97, label %middle.block1229.unr-lcssa, label %vector.ph1239.new

vector.ph1239.new:                                ; preds = %vector.ph1239
  %unroll_iter1523 = sub nsw i64 %96, %xtraiter1520
  br label %vector.body1231

vector.body1231:                                  ; preds = %vector.body1231, %vector.ph1239.new
  %index1242 = phi i64 [ 0, %vector.ph1239.new ], [ %index.next1243.7, %vector.body1231 ]
  %niter1524 = phi i64 [ %unroll_iter1523, %vector.ph1239.new ], [ %niter1524.nsub.7, %vector.body1231 ]
  %offset.idx1249 = add i64 %conv671072, %index1242
  %98 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249
  %99 = bitcast i8* %98 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %99, align 1, !tbaa !15
  %100 = getelementptr inbounds i8, i8* %98, i64 32
  %101 = bitcast i8* %100 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %101, align 1, !tbaa !15
  %102 = getelementptr inbounds i8, i8* %98, i64 64
  %103 = bitcast i8* %102 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %103, align 1, !tbaa !15
  %104 = getelementptr inbounds i8, i8* %98, i64 96
  %105 = bitcast i8* %104 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %105, align 1, !tbaa !15
  %index.next1243 = or i64 %index1242, 128
  %offset.idx1249.1 = add i64 %conv671072, %index.next1243
  %106 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249.1
  %107 = bitcast i8* %106 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %107, align 1, !tbaa !15
  %108 = getelementptr inbounds i8, i8* %106, i64 32
  %109 = bitcast i8* %108 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %109, align 1, !tbaa !15
  %110 = getelementptr inbounds i8, i8* %106, i64 64
  %111 = bitcast i8* %110 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %111, align 1, !tbaa !15
  %112 = getelementptr inbounds i8, i8* %106, i64 96
  %113 = bitcast i8* %112 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %113, align 1, !tbaa !15
  %index.next1243.1 = or i64 %index1242, 256
  %offset.idx1249.2 = add i64 %conv671072, %index.next1243.1
  %114 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249.2
  %115 = bitcast i8* %114 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %115, align 1, !tbaa !15
  %116 = getelementptr inbounds i8, i8* %114, i64 32
  %117 = bitcast i8* %116 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %117, align 1, !tbaa !15
  %118 = getelementptr inbounds i8, i8* %114, i64 64
  %119 = bitcast i8* %118 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %119, align 1, !tbaa !15
  %120 = getelementptr inbounds i8, i8* %114, i64 96
  %121 = bitcast i8* %120 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %121, align 1, !tbaa !15
  %index.next1243.2 = or i64 %index1242, 384
  %offset.idx1249.3 = add i64 %conv671072, %index.next1243.2
  %122 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249.3
  %123 = bitcast i8* %122 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %123, align 1, !tbaa !15
  %124 = getelementptr inbounds i8, i8* %122, i64 32
  %125 = bitcast i8* %124 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %125, align 1, !tbaa !15
  %126 = getelementptr inbounds i8, i8* %122, i64 64
  %127 = bitcast i8* %126 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %127, align 1, !tbaa !15
  %128 = getelementptr inbounds i8, i8* %122, i64 96
  %129 = bitcast i8* %128 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %129, align 1, !tbaa !15
  %index.next1243.3 = or i64 %index1242, 512
  %offset.idx1249.4 = add i64 %conv671072, %index.next1243.3
  %130 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249.4
  %131 = bitcast i8* %130 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %131, align 1, !tbaa !15
  %132 = getelementptr inbounds i8, i8* %130, i64 32
  %133 = bitcast i8* %132 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %133, align 1, !tbaa !15
  %134 = getelementptr inbounds i8, i8* %130, i64 64
  %135 = bitcast i8* %134 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %135, align 1, !tbaa !15
  %136 = getelementptr inbounds i8, i8* %130, i64 96
  %137 = bitcast i8* %136 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %137, align 1, !tbaa !15
  %index.next1243.4 = or i64 %index1242, 640
  %offset.idx1249.5 = add i64 %conv671072, %index.next1243.4
  %138 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249.5
  %139 = bitcast i8* %138 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %139, align 1, !tbaa !15
  %140 = getelementptr inbounds i8, i8* %138, i64 32
  %141 = bitcast i8* %140 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %141, align 1, !tbaa !15
  %142 = getelementptr inbounds i8, i8* %138, i64 64
  %143 = bitcast i8* %142 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %143, align 1, !tbaa !15
  %144 = getelementptr inbounds i8, i8* %138, i64 96
  %145 = bitcast i8* %144 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %145, align 1, !tbaa !15
  %index.next1243.5 = or i64 %index1242, 768
  %offset.idx1249.6 = add i64 %conv671072, %index.next1243.5
  %146 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249.6
  %147 = bitcast i8* %146 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %147, align 1, !tbaa !15
  %148 = getelementptr inbounds i8, i8* %146, i64 32
  %149 = bitcast i8* %148 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %149, align 1, !tbaa !15
  %150 = getelementptr inbounds i8, i8* %146, i64 64
  %151 = bitcast i8* %150 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %151, align 1, !tbaa !15
  %152 = getelementptr inbounds i8, i8* %146, i64 96
  %153 = bitcast i8* %152 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %153, align 1, !tbaa !15
  %index.next1243.6 = or i64 %index1242, 896
  %offset.idx1249.7 = add i64 %conv671072, %index.next1243.6
  %154 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249.7
  %155 = bitcast i8* %154 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %155, align 1, !tbaa !15
  %156 = getelementptr inbounds i8, i8* %154, i64 32
  %157 = bitcast i8* %156 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %157, align 1, !tbaa !15
  %158 = getelementptr inbounds i8, i8* %154, i64 64
  %159 = bitcast i8* %158 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %159, align 1, !tbaa !15
  %160 = getelementptr inbounds i8, i8* %154, i64 96
  %161 = bitcast i8* %160 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %161, align 1, !tbaa !15
  %index.next1243.7 = add i64 %index1242, 1024
  %niter1524.nsub.7 = add i64 %niter1524, -8
  %niter1524.ncmp.7 = icmp eq i64 %niter1524.nsub.7, 0
  br i1 %niter1524.ncmp.7, label %middle.block1229.unr-lcssa.loopexit, label %vector.body1231, !llvm.loop !36

middle.block1229.unr-lcssa.loopexit:              ; preds = %vector.body1231
  %index.next1243.7.lcssa = phi i64 [ %index.next1243.7, %vector.body1231 ]
  br label %middle.block1229.unr-lcssa

middle.block1229.unr-lcssa:                       ; preds = %middle.block1229.unr-lcssa.loopexit, %vector.ph1239
  %index1242.unr = phi i64 [ 0, %vector.ph1239 ], [ %index.next1243.7.lcssa, %middle.block1229.unr-lcssa.loopexit ]
  %lcmp.mod1522 = icmp eq i64 %xtraiter1520, 0
  br i1 %lcmp.mod1522, label %middle.block1229, label %vector.body1231.epil.preheader

vector.body1231.epil.preheader:                   ; preds = %middle.block1229.unr-lcssa
  br label %vector.body1231.epil

vector.body1231.epil:                             ; preds = %vector.body1231.epil.preheader, %vector.body1231.epil
  %index1242.epil = phi i64 [ %index.next1243.epil, %vector.body1231.epil ], [ %index1242.unr, %vector.body1231.epil.preheader ]
  %epil.iter1521 = phi i64 [ %epil.iter1521.sub, %vector.body1231.epil ], [ %xtraiter1520, %vector.body1231.epil.preheader ]
  %offset.idx1249.epil = add i64 %conv671072, %index1242.epil
  %162 = getelementptr inbounds i8, i8* %call, i64 %offset.idx1249.epil
  %163 = bitcast i8* %162 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %163, align 1, !tbaa !15
  %164 = getelementptr inbounds i8, i8* %162, i64 32
  %165 = bitcast i8* %164 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %165, align 1, !tbaa !15
  %166 = getelementptr inbounds i8, i8* %162, i64 64
  %167 = bitcast i8* %166 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %167, align 1, !tbaa !15
  %168 = getelementptr inbounds i8, i8* %162, i64 96
  %169 = bitcast i8* %168 to <32 x i8>*
  store <32 x i8> zeroinitializer, <32 x i8>* %169, align 1, !tbaa !15
  %index.next1243.epil = add i64 %index1242.epil, 128
  %epil.iter1521.sub = add i64 %epil.iter1521, -1
  %epil.iter1521.cmp = icmp eq i64 %epil.iter1521.sub, 0
  br i1 %epil.iter1521.cmp, label %middle.block1229.loopexit, label %vector.body1231.epil, !llvm.loop !37

middle.block1229.loopexit:                        ; preds = %vector.body1231.epil
  br label %middle.block1229

middle.block1229:                                 ; preds = %middle.block1229.loopexit, %middle.block1229.unr-lcssa
  %cmp.n1248 = icmp eq i64 %84, %n.vec1241
  br i1 %cmp.n1248, label %for.cond.cleanup70, label %for.body71.preheader1500

for.cond.cleanup70.loopexit:                      ; preds = %for.body71
  br label %for.cond.cleanup70

for.cond.cleanup70:                               ; preds = %for.cond.cleanup70.loopexit, %middle.block1229, %cleanup61
  %conv.i675 = uitofp i32 %add.i.i.i.7.lcssa to double
  %call.i676 = tail call double @log2(double %conv.i675) #16
  %div79 = fdiv double 9.600000e+01, %call.i676
  %170 = tail call double @llvm.floor.f64(double %div79)
  %conv80 = fptoui double %170 to i32
  %call.i677 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* nonnull @_ZSt4cout, double %call.i676)
  %call1.i679 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i677, i8* nonnull getelementptr inbounds ([3 x i8], [3 x i8]* @.str.8, i64 0, i64 0), i64 2)
  %conv.i680 = zext i32 %conv80 to i64
  %call.i681 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream"* nonnull %call.i677, i64 %conv.i680)
  %171 = bitcast %"class.std::basic_ostream"* %call.i681 to i8**
  %vtable.i683 = load i8*, i8** %171, align 8, !tbaa !22
  %vbase.offset.ptr.i684 = getelementptr i8, i8* %vtable.i683, i64 -24
  %172 = bitcast i8* %vbase.offset.ptr.i684 to i64*
  %vbase.offset.i685 = load i64, i64* %172, align 8
  %173 = bitcast %"class.std::basic_ostream"* %call.i681 to i8*
  %add.ptr.i686 = getelementptr inbounds i8, i8* %173, i64 %vbase.offset.i685
  %_M_ctype.i1000 = getelementptr inbounds i8, i8* %add.ptr.i686, i64 240
  %174 = bitcast i8* %_M_ctype.i1000 to %"class.std::ctype"**
  %175 = load %"class.std::ctype"*, %"class.std::ctype"** %174, align 8, !tbaa !24
  %tobool.i1027 = icmp eq %"class.std::ctype"* %175, null
  br i1 %tobool.i1027, label %if.then.i1028, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit1030

if.then.i1028:                                    ; preds = %for.cond.cleanup70
  tail call void @_ZSt16__throw_bad_castv() #17
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit1030: ; preds = %for.cond.cleanup70
  %_M_widen_ok.i1002 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %175, i64 0, i32 8
  %176 = load i8, i8* %_M_widen_ok.i1002, align 8, !tbaa !27
  %tobool.i1003 = icmp eq i8 %176, 0
  br i1 %tobool.i1003, label %if.end.i1009, label %if.then.i1005

if.then.i1005:                                    ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit1030
  %arrayidx.i1004 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %175, i64 0, i32 9, i64 10
  %177 = load i8, i8* %arrayidx.i1004, align 1, !tbaa !15
  br label %_ZNKSt5ctypeIcE5widenEc.exit1011

if.end.i1009:                                     ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit1030
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %175)
  %178 = bitcast %"class.std::ctype"* %175 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i1006 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %178, align 8, !tbaa !22
  %vfn.i1007 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i1006, i64 6
  %179 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i1007, align 8
  %call.i1008 = tail call signext i8 %179(%"class.std::ctype"* nonnull %175, i8 signext 10)
  br label %_ZNKSt5ctypeIcE5widenEc.exit1011

_ZNKSt5ctypeIcE5widenEc.exit1011:                 ; preds = %if.end.i1009, %if.then.i1005
  %retval.0.i1010 = phi i8 [ %177, %if.then.i1005 ], [ %call.i1008, %if.end.i1009 ]
  %call1.i688 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i681, i8 signext %retval.0.i1010)
  %call.i689 = tail call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i688)
  %mul85 = shl i64 %n, 4
  %call86 = tail call noalias i8* @malloc(i64 %mul85) #16
  %180 = bitcast i8* %call86 to i128*
  br i1 %cmp1, label %pfor.cond100.preheader, label %cleanup139

pfor.cond100.preheader:                           ; preds = %_ZNKSt5ctypeIcE5widenEc.exit1011
  %cmp1111069 = icmp ugt i32 %conv80, 1
  %conv115 = zext i32 %add.i.i.i.7.lcssa to i128
  br i1 %cmp1111069, label %pfor.cond100.us.preheader, label %pfor.cond100.preheader1142

pfor.cond100.us.preheader:                        ; preds = %pfor.cond100.preheader
  %181 = add nsw i64 %conv.i680, -1
  %182 = add nsw i64 %conv.i680, -2
  %xtraiter1512 = and i64 %181, 7
  %183 = icmp ult i64 %182, 7
  %unroll_iter1516 = sub nsw i64 %181, %xtraiter1512
  %lcmp.mod1514 = icmp eq i64 %xtraiter1512, 0
  br label %pfor.cond100.us

pfor.cond100.preheader1142:                       ; preds = %pfor.cond100.preheader
  %184 = add nsw i64 %conv671072, -1
  %xtraiter1171 = and i64 %n, 2047
  %185 = icmp ult i64 %184, 2047
  br i1 %185, label %pfor.cond.cleanup134.loopexit1143.strpm-lcssa, label %pfor.cond100.preheader1142.new

pfor.cond100.preheader1142.new:                   ; preds = %pfor.cond100.preheader1142
  %stripiter1174 = lshr i64 %conv671072, 11
  br label %pfor.cond100.strpm.outer

pfor.cond100.us:                                  ; preds = %pfor.inc131.us, %pfor.cond100.us.preheader
  %indvars.iv1115 = phi i64 [ %indvars.iv.next1116, %pfor.inc131.us ], [ 0, %pfor.cond100.us.preheader ]
  %indvars.iv.next1116 = add nuw nsw i64 %indvars.iv1115, 1
  detach within %syncreg.i, label %pfor.body106.us, label %pfor.inc131.us

pfor.body106.us:                                  ; preds = %pfor.cond100.us
  %arrayidx108.us = getelementptr inbounds i8, i8* %call, i64 %indvars.iv1115
  %186 = load i8, i8* %arrayidx108.us, align 1, !tbaa !15
  %conv109.us = zext i8 %186 to i128
  br i1 %183, label %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa, label %for.body114.us.preheader

for.body114.us.preheader:                         ; preds = %pfor.body106.us
  br label %for.body114.us

pfor.inc131.us:                                   ; preds = %for.cond110.for.cond.cleanup112_crit_edge.us, %pfor.cond100.us
  %exitcond1118 = icmp eq i64 %indvars.iv.next1116, %conv671072
  br i1 %exitcond1118, label %pfor.cond.cleanup134.loopexit, label %pfor.cond100.us, !llvm.loop !38

for.body114.us:                                   ; preds = %for.body114.us.preheader, %for.body114.us
  %indvars.iv1111 = phi i64 [ %indvars.iv.next1112.7, %for.body114.us ], [ 1, %for.body114.us.preheader ]
  %r.01070.us = phi i128 [ %add121.us.7, %for.body114.us ], [ %conv109.us, %for.body114.us.preheader ]
  %niter1517 = phi i64 [ %niter1517.nsub.7, %for.body114.us ], [ %unroll_iter1516, %for.body114.us.preheader ]
  %mul116.us = mul i128 %r.01070.us, %conv115
  %add117.us = add nuw i64 %indvars.iv1111, %indvars.iv1115
  %idxprom118.us = and i64 %add117.us, 4294967295
  %arrayidx119.us = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us
  %187 = load i8, i8* %arrayidx119.us, align 1, !tbaa !15
  %conv120.us = zext i8 %187 to i128
  %add121.us = add i128 %mul116.us, %conv120.us
  %indvars.iv.next1112 = add nuw nsw i64 %indvars.iv1111, 1
  %mul116.us.1 = mul i128 %add121.us, %conv115
  %add117.us.1 = add nuw i64 %indvars.iv.next1112, %indvars.iv1115
  %idxprom118.us.1 = and i64 %add117.us.1, 4294967295
  %arrayidx119.us.1 = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us.1
  %188 = load i8, i8* %arrayidx119.us.1, align 1, !tbaa !15
  %conv120.us.1 = zext i8 %188 to i128
  %add121.us.1 = add i128 %mul116.us.1, %conv120.us.1
  %indvars.iv.next1112.1 = add nuw nsw i64 %indvars.iv1111, 2
  %mul116.us.2 = mul i128 %add121.us.1, %conv115
  %add117.us.2 = add nuw i64 %indvars.iv.next1112.1, %indvars.iv1115
  %idxprom118.us.2 = and i64 %add117.us.2, 4294967295
  %arrayidx119.us.2 = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us.2
  %189 = load i8, i8* %arrayidx119.us.2, align 1, !tbaa !15
  %conv120.us.2 = zext i8 %189 to i128
  %add121.us.2 = add i128 %mul116.us.2, %conv120.us.2
  %indvars.iv.next1112.2 = add nuw nsw i64 %indvars.iv1111, 3
  %mul116.us.3 = mul i128 %add121.us.2, %conv115
  %add117.us.3 = add nuw i64 %indvars.iv.next1112.2, %indvars.iv1115
  %idxprom118.us.3 = and i64 %add117.us.3, 4294967295
  %arrayidx119.us.3 = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us.3
  %190 = load i8, i8* %arrayidx119.us.3, align 1, !tbaa !15
  %conv120.us.3 = zext i8 %190 to i128
  %add121.us.3 = add i128 %mul116.us.3, %conv120.us.3
  %indvars.iv.next1112.3 = add nuw nsw i64 %indvars.iv1111, 4
  %mul116.us.4 = mul i128 %add121.us.3, %conv115
  %add117.us.4 = add nuw i64 %indvars.iv.next1112.3, %indvars.iv1115
  %idxprom118.us.4 = and i64 %add117.us.4, 4294967295
  %arrayidx119.us.4 = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us.4
  %191 = load i8, i8* %arrayidx119.us.4, align 1, !tbaa !15
  %conv120.us.4 = zext i8 %191 to i128
  %add121.us.4 = add i128 %mul116.us.4, %conv120.us.4
  %indvars.iv.next1112.4 = add nuw nsw i64 %indvars.iv1111, 5
  %mul116.us.5 = mul i128 %add121.us.4, %conv115
  %add117.us.5 = add nuw i64 %indvars.iv.next1112.4, %indvars.iv1115
  %idxprom118.us.5 = and i64 %add117.us.5, 4294967295
  %arrayidx119.us.5 = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us.5
  %192 = load i8, i8* %arrayidx119.us.5, align 1, !tbaa !15
  %conv120.us.5 = zext i8 %192 to i128
  %add121.us.5 = add i128 %mul116.us.5, %conv120.us.5
  %indvars.iv.next1112.5 = add nuw nsw i64 %indvars.iv1111, 6
  %mul116.us.6 = mul i128 %add121.us.5, %conv115
  %add117.us.6 = add nuw i64 %indvars.iv.next1112.5, %indvars.iv1115
  %idxprom118.us.6 = and i64 %add117.us.6, 4294967295
  %arrayidx119.us.6 = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us.6
  %193 = load i8, i8* %arrayidx119.us.6, align 1, !tbaa !15
  %conv120.us.6 = zext i8 %193 to i128
  %add121.us.6 = add i128 %mul116.us.6, %conv120.us.6
  %indvars.iv.next1112.6 = add nuw nsw i64 %indvars.iv1111, 7
  %mul116.us.7 = mul i128 %add121.us.6, %conv115
  %add117.us.7 = add nuw i64 %indvars.iv.next1112.6, %indvars.iv1115
  %idxprom118.us.7 = and i64 %add117.us.7, 4294967295
  %arrayidx119.us.7 = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us.7
  %194 = load i8, i8* %arrayidx119.us.7, align 1, !tbaa !15
  %conv120.us.7 = zext i8 %194 to i128
  %add121.us.7 = add i128 %mul116.us.7, %conv120.us.7
  %indvars.iv.next1112.7 = add nuw nsw i64 %indvars.iv1111, 8
  %niter1517.nsub.7 = add i64 %niter1517, -8
  %niter1517.ncmp.7 = icmp eq i64 %niter1517.nsub.7, 0
  br i1 %niter1517.ncmp.7, label %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa.loopexit, label %for.body114.us

for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa.loopexit: ; preds = %for.body114.us
  %add121.us.7.lcssa = phi i128 [ %add121.us.7, %for.body114.us ]
  %indvars.iv.next1112.7.lcssa = phi i64 [ %indvars.iv.next1112.7, %for.body114.us ]
  br label %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa

for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa: ; preds = %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa.loopexit, %pfor.body106.us
  %add121.us.lcssa.ph = phi i128 [ undef, %pfor.body106.us ], [ %add121.us.7.lcssa, %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa.loopexit ]
  %indvars.iv1111.unr = phi i64 [ 1, %pfor.body106.us ], [ %indvars.iv.next1112.7.lcssa, %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa.loopexit ]
  %r.01070.us.unr = phi i128 [ %conv109.us, %pfor.body106.us ], [ %add121.us.7.lcssa, %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa.loopexit ]
  br i1 %lcmp.mod1514, label %for.cond110.for.cond.cleanup112_crit_edge.us, label %for.body114.us.epil.preheader

for.body114.us.epil.preheader:                    ; preds = %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa
  br label %for.body114.us.epil

for.body114.us.epil:                              ; preds = %for.body114.us.epil.preheader, %for.body114.us.epil
  %indvars.iv1111.epil = phi i64 [ %indvars.iv.next1112.epil, %for.body114.us.epil ], [ %indvars.iv1111.unr, %for.body114.us.epil.preheader ]
  %r.01070.us.epil = phi i128 [ %add121.us.epil, %for.body114.us.epil ], [ %r.01070.us.unr, %for.body114.us.epil.preheader ]
  %epil.iter1513 = phi i64 [ %epil.iter1513.sub, %for.body114.us.epil ], [ %xtraiter1512, %for.body114.us.epil.preheader ]
  %mul116.us.epil = mul i128 %r.01070.us.epil, %conv115
  %add117.us.epil = add nuw i64 %indvars.iv1111.epil, %indvars.iv1115
  %idxprom118.us.epil = and i64 %add117.us.epil, 4294967295
  %arrayidx119.us.epil = getelementptr inbounds i8, i8* %call, i64 %idxprom118.us.epil
  %195 = load i8, i8* %arrayidx119.us.epil, align 1, !tbaa !15
  %conv120.us.epil = zext i8 %195 to i128
  %add121.us.epil = add i128 %mul116.us.epil, %conv120.us.epil
  %indvars.iv.next1112.epil = add nuw nsw i64 %indvars.iv1111.epil, 1
  %epil.iter1513.sub = add i64 %epil.iter1513, -1
  %epil.iter1513.cmp = icmp eq i64 %epil.iter1513.sub, 0
  br i1 %epil.iter1513.cmp, label %for.cond110.for.cond.cleanup112_crit_edge.us.loopexit, label %for.body114.us.epil, !llvm.loop !39

for.cond110.for.cond.cleanup112_crit_edge.us.loopexit: ; preds = %for.body114.us.epil
  %add121.us.epil.lcssa = phi i128 [ %add121.us.epil, %for.body114.us.epil ]
  br label %for.cond110.for.cond.cleanup112_crit_edge.us

for.cond110.for.cond.cleanup112_crit_edge.us:     ; preds = %for.cond110.for.cond.cleanup112_crit_edge.us.loopexit, %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa
  %add121.us.lcssa = phi i128 [ %add121.us.lcssa.ph, %for.cond110.for.cond.cleanup112_crit_edge.us.unr-lcssa ], [ %add121.us.epil.lcssa, %for.cond110.for.cond.cleanup112_crit_edge.us.loopexit ]
  %shl.us = shl i128 %add121.us.lcssa, 32
  %conv126.us = zext i64 %indvars.iv1115 to i128
  %add127.us = or i128 %shl.us, %conv126.us
  %arrayidx129.us = getelementptr inbounds i128, i128* %180, i64 %indvars.iv1115
  store i128 %add127.us, i128* %arrayidx129.us, align 16, !tbaa !40
  reattach within %syncreg.i, label %pfor.inc131.us

for.body71:                                       ; preds = %for.body71, %for.body71.preheader1500
  %conv671075 = phi i64 [ %conv67, %for.body71 ], [ %conv671075.ph, %for.body71.preheader1500 ]
  %i64.01074 = phi i32 [ %inc75, %for.body71 ], [ %i64.01074.ph, %for.body71.preheader1500 ]
  %arrayidx73 = getelementptr inbounds i8, i8* %call, i64 %conv671075
  store i8 0, i8* %arrayidx73, align 1, !tbaa !15
  %inc75 = add i32 %i64.01074, 1
  %conv67 = zext i32 %inc75 to i64
  %cmp69 = icmp ugt i64 %add, %conv67
  br i1 %cmp69, label %for.body71, label %for.cond.cleanup70.loopexit, !llvm.loop !42

pfor.cond100.strpm.outer:                         ; preds = %pfor.inc131.strpm.outer, %pfor.cond100.preheader1142.new
  %niter1175 = phi i64 [ 0, %pfor.cond100.preheader1142.new ], [ %niter1175.nadd, %pfor.inc131.strpm.outer ]
  detach within %syncreg.i, label %for.cond.cleanup112.strpm.outer, label %pfor.inc131.strpm.outer

for.cond.cleanup112.strpm.outer:                  ; preds = %pfor.cond100.strpm.outer
  %196 = shl i64 %niter1175, 11
  br label %pfor.cond100

pfor.cond100:                                     ; preds = %pfor.cond100, %for.cond.cleanup112.strpm.outer
  %indvars.iv1119 = phi i64 [ %196, %for.cond.cleanup112.strpm.outer ], [ %indvars.iv.next1120.3, %pfor.cond100 ]
  %inneriter1176 = phi i64 [ 2048, %for.cond.cleanup112.strpm.outer ], [ %inneriter1176.nsub.3, %pfor.cond100 ]
  %indvars.iv.next1120 = or i64 %indvars.iv1119, 1
  %arrayidx108 = getelementptr inbounds i8, i8* %call, i64 %indvars.iv1119
  %197 = load i8, i8* %arrayidx108, align 1, !tbaa !15
  %conv109 = zext i8 %197 to i128
  %shl = shl nuw nsw i128 %conv109, 32
  %conv126 = zext i64 %indvars.iv1119 to i128
  %add127 = or i128 %shl, %conv126
  %arrayidx129 = getelementptr inbounds i128, i128* %180, i64 %indvars.iv1119
  store i128 %add127, i128* %arrayidx129, align 16, !tbaa !40
  %indvars.iv.next1120.1 = or i64 %indvars.iv1119, 2
  %arrayidx108.1 = getelementptr inbounds i8, i8* %call, i64 %indvars.iv.next1120
  %198 = load i8, i8* %arrayidx108.1, align 1, !tbaa !15
  %conv109.1 = zext i8 %198 to i128
  %shl.1 = shl nuw nsw i128 %conv109.1, 32
  %conv126.1 = zext i64 %indvars.iv.next1120 to i128
  %add127.1 = or i128 %shl.1, %conv126.1
  %arrayidx129.1 = getelementptr inbounds i128, i128* %180, i64 %indvars.iv.next1120
  store i128 %add127.1, i128* %arrayidx129.1, align 16, !tbaa !40
  %indvars.iv.next1120.2 = or i64 %indvars.iv1119, 3
  %arrayidx108.2 = getelementptr inbounds i8, i8* %call, i64 %indvars.iv.next1120.1
  %199 = load i8, i8* %arrayidx108.2, align 1, !tbaa !15
  %conv109.2 = zext i8 %199 to i128
  %shl.2 = shl nuw nsw i128 %conv109.2, 32
  %conv126.2 = zext i64 %indvars.iv.next1120.1 to i128
  %add127.2 = or i128 %shl.2, %conv126.2
  %arrayidx129.2 = getelementptr inbounds i128, i128* %180, i64 %indvars.iv.next1120.1
  store i128 %add127.2, i128* %arrayidx129.2, align 16, !tbaa !40
  %indvars.iv.next1120.3 = add nuw nsw i64 %indvars.iv1119, 4
  %arrayidx108.3 = getelementptr inbounds i8, i8* %call, i64 %indvars.iv.next1120.2
  %200 = load i8, i8* %arrayidx108.3, align 1, !tbaa !15
  %conv109.3 = zext i8 %200 to i128
  %shl.3 = shl nuw nsw i128 %conv109.3, 32
  %conv126.3 = zext i64 %indvars.iv.next1120.2 to i128
  %add127.3 = or i128 %shl.3, %conv126.3
  %arrayidx129.3 = getelementptr inbounds i128, i128* %180, i64 %indvars.iv.next1120.2
  store i128 %add127.3, i128* %arrayidx129.3, align 16, !tbaa !40
  %inneriter1176.nsub.3 = add nsw i64 %inneriter1176, -4
  %inneriter1176.ncmp.3 = icmp eq i64 %inneriter1176.nsub.3, 0
  br i1 %inneriter1176.ncmp.3, label %pfor.inc131.reattach, label %pfor.cond100, !llvm.loop !43

pfor.inc131.reattach:                             ; preds = %pfor.cond100
  reattach within %syncreg.i, label %pfor.inc131.strpm.outer

pfor.inc131.strpm.outer:                          ; preds = %pfor.inc131.reattach, %pfor.cond100.strpm.outer
  %niter1175.nadd = add nuw nsw i64 %niter1175, 1
  %niter1175.ncmp = icmp eq i64 %niter1175.nadd, %stripiter1174
  br i1 %niter1175.ncmp, label %pfor.cond.cleanup134.loopexit1143.strpm-lcssa.loopexit, label %pfor.cond100.strpm.outer, !llvm.loop !44

pfor.cond.cleanup134.loopexit1143.strpm-lcssa.loopexit: ; preds = %pfor.inc131.strpm.outer
  br label %pfor.cond.cleanup134.loopexit1143.strpm-lcssa

pfor.cond.cleanup134.loopexit1143.strpm-lcssa:    ; preds = %pfor.cond.cleanup134.loopexit1143.strpm-lcssa.loopexit, %pfor.cond100.preheader1142
  %lcmp.mod1177 = icmp eq i64 %xtraiter1171, 0
  br i1 %lcmp.mod1177, label %pfor.cond.cleanup134, label %pfor.cond100.epil.preheader

pfor.cond100.epil.preheader:                      ; preds = %pfor.cond.cleanup134.loopexit1143.strpm-lcssa
  %201 = and i64 %n, 4294965248
  %202 = add nsw i64 %xtraiter1171, -1
  %xtraiter1518 = and i64 %n, 3
  %lcmp.mod1519 = icmp eq i64 %xtraiter1518, 0
  br i1 %lcmp.mod1519, label %pfor.cond100.epil.prol.loopexit, label %pfor.cond100.epil.prol.preheader

pfor.cond100.epil.prol.preheader:                 ; preds = %pfor.cond100.epil.preheader
  br label %pfor.cond100.epil.prol

pfor.cond100.epil.prol:                           ; preds = %pfor.cond100.epil.prol.preheader, %pfor.cond100.epil.prol
  %indvars.iv1119.epil.prol = phi i64 [ %indvars.iv.next1120.epil.prol, %pfor.cond100.epil.prol ], [ %201, %pfor.cond100.epil.prol.preheader ]
  %epil.iter1172.prol = phi i64 [ %epil.iter1172.sub.prol, %pfor.cond100.epil.prol ], [ %xtraiter1171, %pfor.cond100.epil.prol.preheader ]
  %prol.iter = phi i64 [ %prol.iter.sub, %pfor.cond100.epil.prol ], [ %xtraiter1518, %pfor.cond100.epil.prol.preheader ]
  %indvars.iv.next1120.epil.prol = add nuw nsw i64 %indvars.iv1119.epil.prol, 1
  %arrayidx108.epil.prol = getelementptr inbounds i8, i8* %call, i64 %indvars.iv1119.epil.prol
  %203 = load i8, i8* %arrayidx108.epil.prol, align 1, !tbaa !15
  %conv109.epil.prol = zext i8 %203 to i128
  %shl.epil.prol = shl nuw nsw i128 %conv109.epil.prol, 32
  %conv126.epil.prol = zext i64 %indvars.iv1119.epil.prol to i128
  %add127.epil.prol = or i128 %shl.epil.prol, %conv126.epil.prol
  %arrayidx129.epil.prol = getelementptr inbounds i128, i128* %180, i64 %indvars.iv1119.epil.prol
  store i128 %add127.epil.prol, i128* %arrayidx129.epil.prol, align 16, !tbaa !40
  %epil.iter1172.sub.prol = add nsw i64 %epil.iter1172.prol, -1
  %prol.iter.sub = add i64 %prol.iter, -1
  %prol.iter.cmp = icmp eq i64 %prol.iter.sub, 0
  br i1 %prol.iter.cmp, label %pfor.cond100.epil.prol.loopexit.loopexit, label %pfor.cond100.epil.prol, !llvm.loop !45

pfor.cond100.epil.prol.loopexit.loopexit:         ; preds = %pfor.cond100.epil.prol
  %indvars.iv.next1120.epil.prol.lcssa = phi i64 [ %indvars.iv.next1120.epil.prol, %pfor.cond100.epil.prol ]
  %epil.iter1172.sub.prol.lcssa = phi i64 [ %epil.iter1172.sub.prol, %pfor.cond100.epil.prol ]
  br label %pfor.cond100.epil.prol.loopexit

pfor.cond100.epil.prol.loopexit:                  ; preds = %pfor.cond100.epil.prol.loopexit.loopexit, %pfor.cond100.epil.preheader
  %indvars.iv1119.epil.unr = phi i64 [ %201, %pfor.cond100.epil.preheader ], [ %indvars.iv.next1120.epil.prol.lcssa, %pfor.cond100.epil.prol.loopexit.loopexit ]
  %epil.iter1172.unr = phi i64 [ %xtraiter1171, %pfor.cond100.epil.preheader ], [ %epil.iter1172.sub.prol.lcssa, %pfor.cond100.epil.prol.loopexit.loopexit ]
  %204 = icmp ult i64 %202, 3
  br i1 %204, label %pfor.cond.cleanup134, label %pfor.cond100.epil.preheader1

pfor.cond100.epil.preheader1:                     ; preds = %pfor.cond100.epil.prol.loopexit
  br label %pfor.cond100.epil

pfor.cond100.epil:                                ; preds = %pfor.cond100.epil.preheader1, %pfor.cond100.epil
  %indvars.iv1119.epil = phi i64 [ %indvars.iv.next1120.epil.3, %pfor.cond100.epil ], [ %indvars.iv1119.epil.unr, %pfor.cond100.epil.preheader1 ]
  %epil.iter1172 = phi i64 [ %epil.iter1172.sub.3, %pfor.cond100.epil ], [ %epil.iter1172.unr, %pfor.cond100.epil.preheader1 ]
  %indvars.iv.next1120.epil = add nuw nsw i64 %indvars.iv1119.epil, 1
  %arrayidx108.epil = getelementptr inbounds i8, i8* %call, i64 %indvars.iv1119.epil
  %205 = load i8, i8* %arrayidx108.epil, align 1, !tbaa !15
  %conv109.epil = zext i8 %205 to i128
  %shl.epil = shl nuw nsw i128 %conv109.epil, 32
  %conv126.epil = zext i64 %indvars.iv1119.epil to i128
  %add127.epil = or i128 %shl.epil, %conv126.epil
  %arrayidx129.epil = getelementptr inbounds i128, i128* %180, i64 %indvars.iv1119.epil
  store i128 %add127.epil, i128* %arrayidx129.epil, align 16, !tbaa !40
  %indvars.iv.next1120.epil.1 = add nuw nsw i64 %indvars.iv1119.epil, 2
  %arrayidx108.epil.1 = getelementptr inbounds i8, i8* %call, i64 %indvars.iv.next1120.epil
  %206 = load i8, i8* %arrayidx108.epil.1, align 1, !tbaa !15
  %conv109.epil.1 = zext i8 %206 to i128
  %shl.epil.1 = shl nuw nsw i128 %conv109.epil.1, 32
  %conv126.epil.1 = zext i64 %indvars.iv.next1120.epil to i128
  %add127.epil.1 = or i128 %shl.epil.1, %conv126.epil.1
  %arrayidx129.epil.1 = getelementptr inbounds i128, i128* %180, i64 %indvars.iv.next1120.epil
  store i128 %add127.epil.1, i128* %arrayidx129.epil.1, align 16, !tbaa !40
  %indvars.iv.next1120.epil.2 = add nuw nsw i64 %indvars.iv1119.epil, 3
  %arrayidx108.epil.2 = getelementptr inbounds i8, i8* %call, i64 %indvars.iv.next1120.epil.1
  %207 = load i8, i8* %arrayidx108.epil.2, align 1, !tbaa !15
  %conv109.epil.2 = zext i8 %207 to i128
  %shl.epil.2 = shl nuw nsw i128 %conv109.epil.2, 32
  %conv126.epil.2 = zext i64 %indvars.iv.next1120.epil.1 to i128
  %add127.epil.2 = or i128 %shl.epil.2, %conv126.epil.2
  %arrayidx129.epil.2 = getelementptr inbounds i128, i128* %180, i64 %indvars.iv.next1120.epil.1
  store i128 %add127.epil.2, i128* %arrayidx129.epil.2, align 16, !tbaa !40
  %indvars.iv.next1120.epil.3 = add nuw nsw i64 %indvars.iv1119.epil, 4
  %arrayidx108.epil.3 = getelementptr inbounds i8, i8* %call, i64 %indvars.iv.next1120.epil.2
  %208 = load i8, i8* %arrayidx108.epil.3, align 1, !tbaa !15
  %conv109.epil.3 = zext i8 %208 to i128
  %shl.epil.3 = shl nuw nsw i128 %conv109.epil.3, 32
  %conv126.epil.3 = zext i64 %indvars.iv.next1120.epil.2 to i128
  %add127.epil.3 = or i128 %shl.epil.3, %conv126.epil.3
  %arrayidx129.epil.3 = getelementptr inbounds i128, i128* %180, i64 %indvars.iv.next1120.epil.2
  store i128 %add127.epil.3, i128* %arrayidx129.epil.3, align 16, !tbaa !40
  %epil.iter1172.sub.3 = add nsw i64 %epil.iter1172, -4
  %epil.iter1172.cmp.3 = icmp eq i64 %epil.iter1172.sub.3, 0
  br i1 %epil.iter1172.cmp.3, label %pfor.cond.cleanup134.loopexit2, label %pfor.cond100.epil, !llvm.loop !46

pfor.cond.cleanup134.loopexit:                    ; preds = %pfor.inc131.us
  br label %pfor.cond.cleanup134

pfor.cond.cleanup134.loopexit2:                   ; preds = %pfor.cond100.epil
  br label %pfor.cond.cleanup134

pfor.cond.cleanup134:                             ; preds = %pfor.cond.cleanup134.loopexit2, %pfor.cond.cleanup134.loopexit, %pfor.cond100.epil.prol.loopexit, %pfor.cond.cleanup134.loopexit1143.strpm-lcssa
  sync within %syncreg.i, label %sync.continue136

sync.continue136:                                 ; preds = %pfor.cond.cleanup134
  tail call void @llvm.sync.unwind(token %syncreg.i)
  br label %cleanup139

cleanup139:                                       ; preds = %sync.continue136, %_ZNKSt5ctypeIcE5widenEc.exit1011
  tail call void @free(i8* %call) #16
  %209 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp142, i64 0, i32 2
  %210 = bitcast %"class.std::__cxx11::basic_string"* %agg.tmp142 to %union.anon**
  store %union.anon* %209, %union.anon** %210, align 8, !tbaa !47
  %211 = bitcast %union.anon* %209 to i8*
  %_M_p.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp142, i64 0, i32 0, i32 0
  %212 = bitcast %union.anon* %209 to i32*
  store i32 2037411683, i32* %212, align 8
  %_M_string_length.i.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp142, i64 0, i32 1
  store i64 4, i64* %_M_string_length.i.i.i.i.i.i, align 8, !tbaa !49
  %arrayidx.i.i.i.i.i = getelementptr inbounds i8, i8* %211, i64 4
  store i8 0, i8* %arrayidx.i.i.i.i.i, align 4, !tbaa !15
  %call2.i.i694 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull %211, i64 4)
          to label %call2.i.i.noexc unwind label %lpad143

call2.i.i.noexc:                                  ; preds = %cleanup139
  %call1.i.i695 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call2.i.i694, i8* nonnull getelementptr inbounds ([4 x i8], [4 x i8]* @.str.17, i64 0, i64 0), i64 3)
          to label %call1.i.i.noexc unwind label %lpad143

call1.i.i.noexc:                                  ; preds = %call2.i.i.noexc
  %213 = load i8, i8* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 3), align 8, !tbaa !2, !range !51
  %tobool.i.i.i = icmp eq i8 %213, 0
  br i1 %tobool.i.i.i, label %_ZN5timer10reportNextEv.exit.i, label %if.end.i.i.i

if.end.i.i.i:                                     ; preds = %call1.i.i.noexc
  %214 = bitcast %struct.timeval* %now.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %214) #16
  %call.i.i.i.i = call i32 @gettimeofday(%struct.timeval* nonnull %now.i.i.i.i, i8* nonnull bitcast (%struct.timezone* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 5) to i8*)) #16
  %tv_sec.i.i.i.i = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i, i64 0, i32 0
  %215 = load i64, i64* %tv_sec.i.i.i.i, align 8, !tbaa !10
  %conv.i.i.i.i = sitofp i64 %215 to double
  %tv_usec.i.i.i.i = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i, i64 0, i32 1
  %216 = load i64, i64* %tv_usec.i.i.i.i, align 8, !tbaa !13
  %conv2.i.i.i.i = sitofp i64 %216 to double
  %div.i.i.i.i = fdiv double %conv2.i.i.i.i, 1.000000e+06
  %add.i.i.i.i = fadd double %div.i.i.i.i, %conv.i.i.i.i
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %214) #16
  %217 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  %sub.i.i.i = fsub double %add.i.i.i.i, %217
  %218 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  %add.i.i.i693 = fadd double %218, %sub.i.i.i
  store double %add.i.i.i693, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  store double %add.i.i.i.i, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  br label %_ZN5timer10reportNextEv.exit.i

_ZN5timer10reportNextEv.exit.i:                   ; preds = %if.end.i.i.i, %call1.i.i.noexc
  %retval.0.i.i.i = phi double [ %sub.i.i.i, %if.end.i.i.i ], [ 0.000000e+00, %call1.i.i.noexc ]
  invoke void @_ZN5timer7reportTEd(%struct.timer* nonnull @_ZL3_tm, double %retval.0.i.i.i)
          to label %invoke.cont144 unwind label %lpad143

invoke.cont144:                                   ; preds = %_ZN5timer10reportNextEv.exit.i
  %219 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !53
  %cmp.i.i.i698 = icmp eq i8* %219, %211
  br i1 %cmp.i.i.i698, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit700, label %if.then.i.i699

if.then.i.i699:                                   ; preds = %invoke.cont144
  call void @_ZdlPv(i8* %219) #16
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit700

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit700: ; preds = %if.then.i.i699, %invoke.cont144
  call void @_Z10sampleSortIoSt4lessIoElEvPT_T1_T0_(i128* %180, i64 %n)
  %220 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp147, i64 0, i32 2
  %221 = bitcast %"class.std::__cxx11::basic_string"* %agg.tmp147 to %union.anon**
  store %union.anon* %220, %union.anon** %221, align 8, !tbaa !47
  %222 = bitcast %union.anon* %220 to i8*
  %_M_p.i.i.i.i.i707 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp147, i64 0, i32 0, i32 0
  %223 = bitcast %union.anon* %220 to i32*
  store i32 1953656691, i32* %223, align 8
  %_M_string_length.i.i.i.i.i.i711 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp147, i64 0, i32 1
  store i64 4, i64* %_M_string_length.i.i.i.i.i.i711, align 8, !tbaa !49
  %arrayidx.i.i.i.i.i712 = getelementptr inbounds i8, i8* %222, i64 4
  store i8 0, i8* %arrayidx.i.i.i.i.i712, align 4, !tbaa !15
  %call2.i.i733 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull %222, i64 4)
          to label %call2.i.i.noexc732 unwind label %lpad151

call2.i.i.noexc732:                               ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit700
  %call1.i.i735 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call2.i.i733, i8* nonnull getelementptr inbounds ([4 x i8], [4 x i8]* @.str.17, i64 0, i64 0), i64 3)
          to label %call1.i.i.noexc734 unwind label %lpad151

call1.i.i.noexc734:                               ; preds = %call2.i.i.noexc732
  %224 = load i8, i8* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 3), align 8, !tbaa !2, !range !51
  %tobool.i.i.i719 = icmp eq i8 %224, 0
  br i1 %tobool.i.i.i719, label %_ZN5timer10reportNextEv.exit.i731, label %if.end.i.i.i729

if.end.i.i.i729:                                  ; preds = %call1.i.i.noexc734
  %225 = bitcast %struct.timeval* %now.i.i.i.i716 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %225) #16
  %call.i.i.i.i720 = call i32 @gettimeofday(%struct.timeval* nonnull %now.i.i.i.i716, i8* nonnull bitcast (%struct.timezone* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 5) to i8*)) #16
  %tv_sec.i.i.i.i721 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i716, i64 0, i32 0
  %226 = load i64, i64* %tv_sec.i.i.i.i721, align 8, !tbaa !10
  %conv.i.i.i.i722 = sitofp i64 %226 to double
  %tv_usec.i.i.i.i723 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i716, i64 0, i32 1
  %227 = load i64, i64* %tv_usec.i.i.i.i723, align 8, !tbaa !13
  %conv2.i.i.i.i724 = sitofp i64 %227 to double
  %div.i.i.i.i725 = fdiv double %conv2.i.i.i.i724, 1.000000e+06
  %add.i.i.i.i726 = fadd double %div.i.i.i.i725, %conv.i.i.i.i722
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %225) #16
  %228 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  %sub.i.i.i727 = fsub double %add.i.i.i.i726, %228
  %229 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  %add.i.i.i728 = fadd double %229, %sub.i.i.i727
  store double %add.i.i.i728, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  store double %add.i.i.i.i726, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  br label %_ZN5timer10reportNextEv.exit.i731

_ZN5timer10reportNextEv.exit.i731:                ; preds = %if.end.i.i.i729, %call1.i.i.noexc734
  %retval.0.i.i.i730 = phi double [ %sub.i.i.i727, %if.end.i.i.i729 ], [ 0.000000e+00, %call1.i.i.noexc734 ]
  invoke void @_ZN5timer7reportTEd(%struct.timer* nonnull @_ZL3_tm, double %retval.0.i.i.i730)
          to label %invoke.cont152 unwind label %lpad151

invoke.cont152:                                   ; preds = %_ZN5timer10reportNextEv.exit.i731
  %230 = load i8*, i8** %_M_p.i.i.i.i.i707, align 8, !tbaa !53
  %cmp.i.i.i739 = icmp eq i8* %230, %222
  br i1 %cmp.i.i.i739, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit741, label %if.then.i.i740

if.then.i.i740:                                   ; preds = %invoke.cont152
  call void @_ZdlPv(i8* %230) #16
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit741

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit741: ; preds = %if.then.i.i740, %invoke.cont152
  %mul156 = shl i64 %n, 2
  %call157 = call noalias i8* @malloc(i64 %mul156) #16
  %231 = bitcast i8* %call157 to i32*
  %mul158 = shl i64 %n, 3
  %call159 = call noalias i8* @malloc(i64 %mul158) #16
  %232 = bitcast i8* %call159 to %struct.seg*
  %call161 = call %"struct.std::pair"* @_Z15splitSegmentTopP3segjPjPo(%struct.seg* %232, i32 %conv, i32* %231, i128* %180)
  %233 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp162, i64 0, i32 2
  %234 = bitcast %"class.std::__cxx11::basic_string"* %agg.tmp162 to %union.anon**
  store %union.anon* %233, %union.anon** %234, align 8, !tbaa !47
  %235 = bitcast %union.anon* %233 to i8*
  %_M_p.i.i.i.i.i748 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp162, i64 0, i32 0, i32 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(5) %235, i8* nonnull align 1 dereferenceable(5) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.11, i64 0, i64 0), i64 5, i1 false) #16
  %_M_string_length.i.i.i.i.i.i752 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp162, i64 0, i32 1
  store i64 5, i64* %_M_string_length.i.i.i.i.i.i752, align 8, !tbaa !49
  %arrayidx.i.i.i.i.i753 = getelementptr inbounds i8, i8* %235, i64 5
  store i8 0, i8* %arrayidx.i.i.i.i.i753, align 1, !tbaa !15
  %call2.i.i774 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull %235, i64 5)
          to label %call2.i.i.noexc773 unwind label %lpad166

call2.i.i.noexc773:                               ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit741
  %call1.i.i776 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call2.i.i774, i8* nonnull getelementptr inbounds ([4 x i8], [4 x i8]* @.str.17, i64 0, i64 0), i64 3)
          to label %call1.i.i.noexc775 unwind label %lpad166

call1.i.i.noexc775:                               ; preds = %call2.i.i.noexc773
  %236 = load i8, i8* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 3), align 8, !tbaa !2, !range !51
  %tobool.i.i.i760 = icmp eq i8 %236, 0
  br i1 %tobool.i.i.i760, label %_ZN5timer10reportNextEv.exit.i772, label %if.end.i.i.i770

if.end.i.i.i770:                                  ; preds = %call1.i.i.noexc775
  %237 = bitcast %struct.timeval* %now.i.i.i.i757 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %237) #16
  %call.i.i.i.i761 = call i32 @gettimeofday(%struct.timeval* nonnull %now.i.i.i.i757, i8* nonnull bitcast (%struct.timezone* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 5) to i8*)) #16
  %tv_sec.i.i.i.i762 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i757, i64 0, i32 0
  %238 = load i64, i64* %tv_sec.i.i.i.i762, align 8, !tbaa !10
  %conv.i.i.i.i763 = sitofp i64 %238 to double
  %tv_usec.i.i.i.i764 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i757, i64 0, i32 1
  %239 = load i64, i64* %tv_usec.i.i.i.i764, align 8, !tbaa !13
  %conv2.i.i.i.i765 = sitofp i64 %239 to double
  %div.i.i.i.i766 = fdiv double %conv2.i.i.i.i765, 1.000000e+06
  %add.i.i.i.i767 = fadd double %div.i.i.i.i766, %conv.i.i.i.i763
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %237) #16
  %240 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  %sub.i.i.i768 = fsub double %add.i.i.i.i767, %240
  %241 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  %add.i.i.i769 = fadd double %241, %sub.i.i.i768
  store double %add.i.i.i769, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  store double %add.i.i.i.i767, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  br label %_ZN5timer10reportNextEv.exit.i772

_ZN5timer10reportNextEv.exit.i772:                ; preds = %if.end.i.i.i770, %call1.i.i.noexc775
  %retval.0.i.i.i771 = phi double [ %sub.i.i.i768, %if.end.i.i.i770 ], [ 0.000000e+00, %call1.i.i.noexc775 ]
  invoke void @_ZN5timer7reportTEd(%struct.timer* nonnull @_ZL3_tm, double %retval.0.i.i.i771)
          to label %invoke.cont167 unwind label %lpad166

invoke.cont167:                                   ; preds = %_ZN5timer10reportNextEv.exit.i772
  %242 = load i8*, i8** %_M_p.i.i.i.i.i748, align 8, !tbaa !53
  %cmp.i.i.i780 = icmp eq i8* %242, %235
  br i1 %cmp.i.i.i780, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit782, label %if.then.i.i781

if.then.i.i781:                                   ; preds = %invoke.cont167
  call void @_ZdlPv(i8* %242) #16
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit782

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit782: ; preds = %if.then.i.i781, %invoke.cont167
  %call172 = call noalias i8* @malloc(i64 %mul156) #16
  %243 = bitcast i8* %call172 to i32*
  %call174 = call noalias i8* @malloc(i64 %mul158) #16
  %244 = bitcast i8* %call174 to %struct.seg*
  %245 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp179, i64 0, i32 2
  %246 = bitcast %"class.std::__cxx11::basic_string"* %agg.tmp179 to %union.anon**
  %247 = bitcast %union.anon* %245 to i8*
  %248 = bitcast i64* %__dnew.i.i.i.i783 to i8*
  %_M_p.i18.i.i.i.i786 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp179, i64 0, i32 0, i32 0
  %_M_allocated_capacity.i.i.i.i.i787 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp179, i64 0, i32 2, i32 0
  %_M_string_length.i.i.i.i.i.i793 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp179, i64 0, i32 1
  %249 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp237, i64 0, i32 2
  %250 = bitcast %"class.std::__cxx11::basic_string"* %agg.tmp237 to %union.anon**
  %251 = bitcast %union.anon* %249 to i8*
  %_M_p.i.i.i.i.i865 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp237, i64 0, i32 0, i32 0
  %_M_string_length.i.i.i.i.i.i869 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp237, i64 0, i32 1
  %252 = bitcast %struct.timeval* %now.i.i.i.i874 to i8*
  %tv_sec.i.i.i.i879 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i874, i64 0, i32 0
  %tv_usec.i.i.i.i881 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i874, i64 0, i32 1
  %div313 = sdiv i64 %n, 10
  %253 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp331, i64 0, i32 2
  %254 = bitcast %"class.std::__cxx11::basic_string"* %agg.tmp331 to %union.anon**
  %255 = bitcast %union.anon* %253 to i8*
  %_M_p.i.i.i.i.i911 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp331, i64 0, i32 0, i32 0
  %256 = bitcast %union.anon* %253 to i32*
  %_M_string_length.i.i.i.i.i.i915 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp331, i64 0, i32 1
  %257 = bitcast %struct.timeval* %now.i.i.i.i920 to i8*
  %tv_sec.i.i.i.i925 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i920, i64 0, i32 0
  %tv_usec.i.i.i.i927 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i920, i64 0, i32 1
  %258 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp384, i64 0, i32 2
  %259 = bitcast %"class.std::__cxx11::basic_string"* %agg.tmp384 to %union.anon**
  %260 = bitcast %union.anon* %258 to i8*
  %_M_p.i.i.i.i.i957 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp384, i64 0, i32 0, i32 0
  %_M_string_length.i.i.i.i.i.i961 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp384, i64 0, i32 1
  %261 = bitcast %struct.timeval* %now.i.i.i.i966 to i8*
  %tv_sec.i.i.i.i971 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i966, i64 0, i32 0
  %tv_usec.i.i.i.i973 = getelementptr inbounds %struct.timeval, %struct.timeval* %now.i.i.i.i966, i64 0, i32 1
  %262 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %agg.tmp237, i64 0, i32 2, i32 1, i64 7
  %arrayidx.i.i.i.i.i916 = getelementptr inbounds i8, i8* %255, i64 4
  %arrayidx.i.i.i.i.i962 = getelementptr inbounds i8, i8* %260, i64 5
  %broadcast.splatinsert1310 = insertelement <8 x i64> undef, i64 %n, i32 0
  %broadcast.splat1311 = shufflevector <8 x i64> %broadcast.splatinsert1310, <8 x i64> undef, <8 x i32> zeroinitializer
  %broadcast.splatinsert1284 = insertelement <8 x i64> undef, i64 %n, i32 0
  %broadcast.splat1285 = shufflevector <8 x i64> %broadcast.splatinsert1284, <8 x i64> undef, <8 x i32> zeroinitializer
  br label %while.cond

while.cond:                                       ; preds = %cleanup394, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit782
  %nKeys.0 = phi i32 [ %conv, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit782 ], [ %call.i835, %cleanup394 ]
  %round.0 = phi i32 [ 0, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit782 ], [ %inc176, %cleanup394 ]
  %offset.0 = phi i32 [ %conv80, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit782 ], [ %mul393, %cleanup394 ]
  %inc176 = add nuw nsw i32 %round.0, 1
  store %union.anon* %245, %union.anon** %246, align 8, !tbaa !47
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %248) #16
  store i64 30, i64* %__dnew.i.i.i.i783, align 8, !tbaa !54
  %call5.i.i.i9.i796 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* nonnull %agg.tmp179, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i783, i64 0)
          to label %call5.i.i.i9.i.noexc795 unwind label %lpad181

call5.i.i.i9.i.noexc795:                          ; preds = %while.cond
  store i8* %call5.i.i.i9.i796, i8** %_M_p.i18.i.i.i.i786, align 8, !tbaa !53
  %263 = load i64, i64* %__dnew.i.i.i.i783, align 8, !tbaa !54
  store i64 %263, i64* %_M_allocated_capacity.i.i.i.i.i787, align 8, !tbaa !15
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(30) %call5.i.i.i9.i796, i8* nonnull align 1 dereferenceable(30) getelementptr inbounds ([31 x i8], [31 x i8]* @.str.12, i64 0, i64 0), i64 30, i1 false) #16
  store i64 %263, i64* %_M_string_length.i.i.i.i.i.i793, align 8, !tbaa !49
  %264 = load i8*, i8** %_M_p.i18.i.i.i.i786, align 8, !tbaa !53
  %arrayidx.i.i.i.i.i794 = getelementptr inbounds i8, i8* %264, i64 %263
  store i8 0, i8* %arrayidx.i.i.i.i.i794, align 1, !tbaa !15
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %248) #16
  %265 = load i8*, i8** %_M_p.i18.i.i.i.i786, align 8, !tbaa !53
  %exitcond1110 = icmp eq i32 %round.0, 40
  br i1 %exitcond1110, label %if.then.i, label %invoke.cont184

if.then.i:                                        ; preds = %call5.i.i.i9.i.noexc795
  %.lcssa = phi i8* [ %265, %call5.i.i.i9.i.noexc795 ]
  %266 = load i64, i64* %_M_string_length.i.i.i.i.i.i793, align 8, !tbaa !49
  %call2.i829 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* %.lcssa, i64 %266)
          to label %call.i798.noexc unwind label %lpad183

call.i798.noexc:                                  ; preds = %if.then.i
  %call.i.i799801 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call2.i829)
          to label %call.i.i799.noexc unwind label %lpad183

call.i.i799.noexc:                                ; preds = %call.i798.noexc
  call void @abort() #18
  unreachable

invoke.cont184:                                   ; preds = %call5.i.i.i9.i.noexc795
  %cmp.i.i.i804 = icmp eq i8* %265, %247
  br i1 %cmp.i.i.i804, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit806.tf.tf, label %if.then.i.i805

if.then.i.i805:                                   ; preds = %invoke.cont184
  call void @_ZdlPv(i8* %265) #16
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit806.tf.tf

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit806.tf.tf: ; preds = %if.then.i.i805, %invoke.cont184
  %cmp.i = icmp ult i32 %nKeys.0, 2048
  br i1 %cmp.i, label %if.then.i807, label %if.end.i

if.then.i807:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit806.tf.tf
  %cmp13.i.i = icmp eq i32 %nKeys.0, 0
  br i1 %cmp13.i.i, label %while.end, label %for.body.preheader.i.i

for.body.preheader.i.i:                           ; preds = %if.then.i807
  %wide.trip.count.i.i = zext i32 %nKeys.0 to i64
  %267 = add nsw i64 %wide.trip.count.i.i, -1
  %xtraiter1507 = and i64 %wide.trip.count.i.i, 3
  %268 = icmp ult i64 %267, 3
  br i1 %268, label %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa, label %for.body.preheader.i.i.new

for.body.preheader.i.i.new:                       ; preds = %for.body.preheader.i.i
  %unroll_iter = sub nsw i64 %wide.trip.count.i.i, %xtraiter1507
  br label %for.body.i.i

for.body.i.i:                                     ; preds = %for.inc.i.i.3, %for.body.preheader.i.i.new
  %indvars.iv.i.i = phi i64 [ 0, %for.body.preheader.i.i.new ], [ %indvars.iv.next.i.i.3, %for.inc.i.i.3 ]
  %k.015.i.i = phi i32 [ 0, %for.body.preheader.i.i.new ], [ %k.1.i.i.3, %for.inc.i.i.3 ]
  %niter1511 = phi i64 [ %unroll_iter, %for.body.preheader.i.i.new ], [ %niter1511.nsub.3, %for.inc.i.i.3 ]
  %arrayidx.i.i = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %indvars.iv.i.i
  %agg.tmp.sroa.0.0..sroa_cast.i.i = bitcast %struct.seg* %arrayidx.i.i to i64*
  %agg.tmp.sroa.0.0.copyload.i.i = load i64, i64* %agg.tmp.sroa.0.0..sroa_cast.i.i, align 4, !tbaa.struct !55
  %s.sroa.1.0.extract.shift.i.i.i = lshr i64 %agg.tmp.sroa.0.0.copyload.i.i, 32
  %s.sroa.1.0.extract.trunc.i.i.i = trunc i64 %s.sroa.1.0.extract.shift.i.i.i to i32
  %cmp.i.i.i808 = icmp ugt i32 %s.sroa.1.0.extract.trunc.i.i.i, 1
  br i1 %cmp.i.i.i808, label %if.then.i.i809, label %for.inc.i.i

if.then.i.i809:                                   ; preds = %for.body.i.i
  %inc.i.i = add i32 %k.015.i.i, 1
  %idxprom3.i.i = zext i32 %k.015.i.i to i64
  %arrayidx4.i.i = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %idxprom3.i.i
  %269 = bitcast %struct.seg* %arrayidx4.i.i to i64*
  store i64 %agg.tmp.sroa.0.0.copyload.i.i, i64* %269, align 4
  br label %for.inc.i.i

for.inc.i.i:                                      ; preds = %if.then.i.i809, %for.body.i.i
  %k.1.i.i = phi i32 [ %inc.i.i, %if.then.i.i809 ], [ %k.015.i.i, %for.body.i.i ]
  %indvars.iv.next.i.i = or i64 %indvars.iv.i.i, 1
  %arrayidx.i.i.1 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %indvars.iv.next.i.i
  %agg.tmp.sroa.0.0..sroa_cast.i.i.1 = bitcast %struct.seg* %arrayidx.i.i.1 to i64*
  %agg.tmp.sroa.0.0.copyload.i.i.1 = load i64, i64* %agg.tmp.sroa.0.0..sroa_cast.i.i.1, align 4, !tbaa.struct !55
  %s.sroa.1.0.extract.shift.i.i.i.1 = lshr i64 %agg.tmp.sroa.0.0.copyload.i.i.1, 32
  %s.sroa.1.0.extract.trunc.i.i.i.1 = trunc i64 %s.sroa.1.0.extract.shift.i.i.i.1 to i32
  %cmp.i.i.i808.1 = icmp ugt i32 %s.sroa.1.0.extract.trunc.i.i.i.1, 1
  br i1 %cmp.i.i.i808.1, label %if.then.i.i809.1, label %for.inc.i.i.1

if.end.i:                                         ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit806.tf.tf
  %conv.i810 = zext i32 %nKeys.0 to i64
  %call1.i811 = call noalias i8* @malloc(i64 %conv.i810) #16
  %270 = add nsw i64 %conv.i810, -1
  %xtraiter1150 = and i64 %conv.i810, 2047
  %271 = icmp ult i64 %270, 2047
  br i1 %271, label %pfor.cond.cleanup.i.strpm-lcssa, label %if.end.i.new

if.end.i.new:                                     ; preds = %if.end.i
  %stripiter11531194 = lshr i32 %nKeys.0, 11
  %stripiter1153.zext = zext i32 %stripiter11531194 to i64
  br label %pfor.cond.i.strpm.outer

pfor.cond.i.strpm.outer:                          ; preds = %pfor.inc.i.strpm.outer, %if.end.i.new
  %niter1154 = phi i64 [ 0, %if.end.i.new ], [ %niter1154.nadd, %pfor.inc.i.strpm.outer ]
  detach within %syncreg.i, label %pfor.body.i.strpm.outer, label %pfor.inc.i.strpm.outer

pfor.body.i.strpm.outer:                          ; preds = %pfor.cond.i.strpm.outer
  %272 = shl i64 %niter1154, 11
  br label %vector.body1407

vector.body1407:                                  ; preds = %vector.body1407, %pfor.body.i.strpm.outer
  %index1409 = phi i64 [ 0, %pfor.body.i.strpm.outer ], [ %index.next1410.3, %vector.body1407 ]
  %offset.idx1415 = add nuw nsw i64 %272, %index1409
  %273 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %offset.idx1415
  %274 = bitcast %struct.seg* %273 to <4 x i64>*
  %wide.load1423 = load <4 x i64>, <4 x i64>* %274, align 4
  %275 = lshr <4 x i64> %wide.load1423, <i64 32, i64 32, i64 32, i64 32>
  %276 = trunc <4 x i64> %275 to <4 x i32>
  %277 = icmp ugt <4 x i32> %276, <i32 1, i32 1, i32 1, i32 1>
  %278 = getelementptr inbounds i8, i8* %call1.i811, i64 %offset.idx1415
  %279 = zext <4 x i1> %277 to <4 x i8>
  %280 = bitcast i8* %278 to <4 x i8>*
  store <4 x i8> %279, <4 x i8>* %280, align 1, !tbaa !56
  %index.next1410 = or i64 %index1409, 4
  %offset.idx1415.1 = add nuw nsw i64 %272, %index.next1410
  %281 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %offset.idx1415.1
  %282 = bitcast %struct.seg* %281 to <4 x i64>*
  %wide.load1423.1 = load <4 x i64>, <4 x i64>* %282, align 4
  %283 = lshr <4 x i64> %wide.load1423.1, <i64 32, i64 32, i64 32, i64 32>
  %284 = trunc <4 x i64> %283 to <4 x i32>
  %285 = icmp ugt <4 x i32> %284, <i32 1, i32 1, i32 1, i32 1>
  %286 = getelementptr inbounds i8, i8* %call1.i811, i64 %offset.idx1415.1
  %287 = zext <4 x i1> %285 to <4 x i8>
  %288 = bitcast i8* %286 to <4 x i8>*
  store <4 x i8> %287, <4 x i8>* %288, align 1, !tbaa !56
  %index.next1410.1 = or i64 %index1409, 8
  %offset.idx1415.2 = add nuw nsw i64 %272, %index.next1410.1
  %289 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %offset.idx1415.2
  %290 = bitcast %struct.seg* %289 to <4 x i64>*
  %wide.load1423.2 = load <4 x i64>, <4 x i64>* %290, align 4
  %291 = lshr <4 x i64> %wide.load1423.2, <i64 32, i64 32, i64 32, i64 32>
  %292 = trunc <4 x i64> %291 to <4 x i32>
  %293 = icmp ugt <4 x i32> %292, <i32 1, i32 1, i32 1, i32 1>
  %294 = getelementptr inbounds i8, i8* %call1.i811, i64 %offset.idx1415.2
  %295 = zext <4 x i1> %293 to <4 x i8>
  %296 = bitcast i8* %294 to <4 x i8>*
  store <4 x i8> %295, <4 x i8>* %296, align 1, !tbaa !56
  %index.next1410.2 = or i64 %index1409, 12
  %offset.idx1415.3 = add nuw nsw i64 %272, %index.next1410.2
  %297 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %offset.idx1415.3
  %298 = bitcast %struct.seg* %297 to <4 x i64>*
  %wide.load1423.3 = load <4 x i64>, <4 x i64>* %298, align 4
  %299 = lshr <4 x i64> %wide.load1423.3, <i64 32, i64 32, i64 32, i64 32>
  %300 = trunc <4 x i64> %299 to <4 x i32>
  %301 = icmp ugt <4 x i32> %300, <i32 1, i32 1, i32 1, i32 1>
  %302 = getelementptr inbounds i8, i8* %call1.i811, i64 %offset.idx1415.3
  %303 = zext <4 x i1> %301 to <4 x i8>
  %304 = bitcast i8* %302 to <4 x i8>*
  store <4 x i8> %303, <4 x i8>* %304, align 1, !tbaa !56
  %index.next1410.3 = add nuw nsw i64 %index1409, 16
  %305 = icmp eq i64 %index.next1410.3, 2048
  br i1 %305, label %pfor.inc.i.reattach, label %vector.body1407, !llvm.loop !57

pfor.inc.i.reattach:                              ; preds = %vector.body1407
  reattach within %syncreg.i, label %pfor.inc.i.strpm.outer

pfor.inc.i.strpm.outer:                           ; preds = %pfor.inc.i.reattach, %pfor.cond.i.strpm.outer
  %niter1154.nadd = add nuw nsw i64 %niter1154, 1
  %niter1154.ncmp = icmp eq i64 %niter1154.nadd, %stripiter1153.zext
  br i1 %niter1154.ncmp, label %pfor.cond.cleanup.i.strpm-lcssa.loopexit, label %pfor.cond.i.strpm.outer, !llvm.loop !58

pfor.cond.cleanup.i.strpm-lcssa.loopexit:         ; preds = %pfor.inc.i.strpm.outer
  br label %pfor.cond.cleanup.i.strpm-lcssa

pfor.cond.cleanup.i.strpm-lcssa:                  ; preds = %pfor.cond.cleanup.i.strpm-lcssa.loopexit, %if.end.i
  %lcmp.mod1156 = icmp eq i64 %xtraiter1150, 0
  br i1 %lcmp.mod1156, label %pfor.cond.cleanup.i, label %pfor.cond.i.epil.preheader

pfor.cond.i.epil.preheader:                       ; preds = %pfor.cond.cleanup.i.strpm-lcssa
  %306 = and i64 %conv.i810, 4294965248
  %min.iters.check1385 = icmp ult i64 %xtraiter1150, 4
  br i1 %min.iters.check1385, label %pfor.cond.i.epil.preheader1498, label %vector.ph1386

vector.ph1386:                                    ; preds = %pfor.cond.i.epil.preheader
  %n.mod.vf1387 = and i64 %conv.i810, 3
  %n.vec1388 = sub nsw i64 %xtraiter1150, %n.mod.vf1387
  %ind.end1392 = add nsw i64 %306, %n.vec1388
  br label %vector.body1384

vector.body1384:                                  ; preds = %vector.body1384, %vector.ph1386
  %index1389 = phi i64 [ 0, %vector.ph1386 ], [ %index.next1390, %vector.body1384 ]
  %offset.idx1396 = add i64 %306, %index1389
  %307 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %offset.idx1396
  %308 = bitcast %struct.seg* %307 to <4 x i64>*
  %wide.load1404 = load <4 x i64>, <4 x i64>* %308, align 4
  %309 = lshr <4 x i64> %wide.load1404, <i64 32, i64 32, i64 32, i64 32>
  %310 = trunc <4 x i64> %309 to <4 x i32>
  %311 = icmp ugt <4 x i32> %310, <i32 1, i32 1, i32 1, i32 1>
  %312 = getelementptr inbounds i8, i8* %call1.i811, i64 %offset.idx1396
  %313 = zext <4 x i1> %311 to <4 x i8>
  %314 = bitcast i8* %312 to <4 x i8>*
  store <4 x i8> %313, <4 x i8>* %314, align 1, !tbaa !56
  %index.next1390 = add i64 %index1389, 4
  %315 = icmp eq i64 %index.next1390, %n.vec1388
  br i1 %315, label %middle.block1382, label %vector.body1384, !llvm.loop !59

middle.block1382:                                 ; preds = %vector.body1384
  %cmp.n1395 = icmp eq i64 %n.mod.vf1387, 0
  br i1 %cmp.n1395, label %pfor.cond.cleanup.i, label %pfor.cond.i.epil.preheader1498

pfor.cond.i.epil.preheader1498:                   ; preds = %middle.block1382, %pfor.cond.i.epil.preheader
  %indvars.iv.i.epil.ph = phi i64 [ %306, %pfor.cond.i.epil.preheader ], [ %ind.end1392, %middle.block1382 ]
  %epil.iter1151.ph = phi i64 [ %xtraiter1150, %pfor.cond.i.epil.preheader ], [ %n.mod.vf1387, %middle.block1382 ]
  br label %pfor.cond.i.epil

pfor.cond.i.epil:                                 ; preds = %pfor.cond.i.epil, %pfor.cond.i.epil.preheader1498
  %indvars.iv.i.epil = phi i64 [ %indvars.iv.next.i.epil, %pfor.cond.i.epil ], [ %indvars.iv.i.epil.ph, %pfor.cond.i.epil.preheader1498 ]
  %epil.iter1151 = phi i64 [ %epil.iter1151.sub, %pfor.cond.i.epil ], [ %epil.iter1151.ph, %pfor.cond.i.epil.preheader1498 ]
  %indvars.iv.next.i.epil = add nuw nsw i64 %indvars.iv.i.epil, 1
  %arrayidx.i.epil = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %indvars.iv.i.epil
  %agg.tmp6.sroa.0.0..sroa_cast.i.epil = bitcast %struct.seg* %arrayidx.i.epil to i64*
  %agg.tmp6.sroa.0.0.copyload.i.epil = load i64, i64* %agg.tmp6.sroa.0.0..sroa_cast.i.epil, align 4, !tbaa.struct !55
  %s.sroa.1.0.extract.shift.i.i.epil = lshr i64 %agg.tmp6.sroa.0.0.copyload.i.epil, 32
  %s.sroa.1.0.extract.trunc.i.i.epil = trunc i64 %s.sroa.1.0.extract.shift.i.i.epil to i32
  %cmp.i.i.epil = icmp ugt i32 %s.sroa.1.0.extract.trunc.i.i.epil, 1
  %arrayidx9.i.epil = getelementptr inbounds i8, i8* %call1.i811, i64 %indvars.iv.i.epil
  %frombool.i.epil = zext i1 %cmp.i.i.epil to i8
  store i8 %frombool.i.epil, i8* %arrayidx9.i.epil, align 1, !tbaa !56
  %epil.iter1151.sub = add nsw i64 %epil.iter1151, -1
  %epil.iter1151.cmp = icmp eq i64 %epil.iter1151.sub, 0
  br i1 %epil.iter1151.cmp, label %pfor.cond.cleanup.i.loopexit, label %pfor.cond.i.epil, !llvm.loop !60

pfor.cond.cleanup.i.loopexit:                     ; preds = %pfor.cond.i.epil
  br label %pfor.cond.cleanup.i

pfor.cond.cleanup.i:                              ; preds = %pfor.cond.cleanup.i.loopexit, %middle.block1382, %pfor.cond.cleanup.i.strpm-lcssa
  sync within %syncreg.i, label %sync.continue.i

sync.continue.i:                                  ; preds = %pfor.cond.cleanup.i
  call void @llvm.sync.unwind(token %syncreg.i)
  %call.i.i812 = call { %struct.seg*, i64 } @_ZN8sequence4packI3segjNS_4getAIS1_jEELi2048EEE4_seqIT_EPS5_PbT0_S9_T1_(%struct.seg* %244, i8* %call1.i811, i32 0, i32 %nKeys.0, %struct.seg* %232)
  %316 = extractvalue { %struct.seg*, i64 } %call.i.i812, 1
  %conv.i.i813 = trunc i64 %316 to i32
  call void @free(i8* %call1.i811) #16
  br label %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend

_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa.loopexit: ; preds = %for.inc.i.i.3
  %k.1.i.i.3.lcssa = phi i32 [ %k.1.i.i.3, %for.inc.i.i.3 ]
  %indvars.iv.next.i.i.3.lcssa = phi i64 [ %indvars.iv.next.i.i.3, %for.inc.i.i.3 ]
  br label %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa

_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa: ; preds = %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa.loopexit, %for.body.preheader.i.i
  %k.1.i.i.lcssa.ph = phi i32 [ undef, %for.body.preheader.i.i ], [ %k.1.i.i.3.lcssa, %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa.loopexit ]
  %indvars.iv.i.i.unr = phi i64 [ 0, %for.body.preheader.i.i ], [ %indvars.iv.next.i.i.3.lcssa, %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa.loopexit ]
  %k.015.i.i.unr = phi i32 [ 0, %for.body.preheader.i.i ], [ %k.1.i.i.3.lcssa, %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa.loopexit ]
  %lcmp.mod1509 = icmp eq i64 %xtraiter1507, 0
  br i1 %lcmp.mod1509, label %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend, label %for.body.i.i.epil.preheader

for.body.i.i.epil.preheader:                      ; preds = %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa
  br label %for.body.i.i.epil

for.body.i.i.epil:                                ; preds = %for.body.i.i.epil.preheader, %for.inc.i.i.epil
  %indvars.iv.i.i.epil = phi i64 [ %indvars.iv.next.i.i.epil, %for.inc.i.i.epil ], [ %indvars.iv.i.i.unr, %for.body.i.i.epil.preheader ]
  %k.015.i.i.epil = phi i32 [ %k.1.i.i.epil, %for.inc.i.i.epil ], [ %k.015.i.i.unr, %for.body.i.i.epil.preheader ]
  %epil.iter1508 = phi i64 [ %epil.iter1508.sub, %for.inc.i.i.epil ], [ %xtraiter1507, %for.body.i.i.epil.preheader ]
  %arrayidx.i.i.epil = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %indvars.iv.i.i.epil
  %agg.tmp.sroa.0.0..sroa_cast.i.i.epil = bitcast %struct.seg* %arrayidx.i.i.epil to i64*
  %agg.tmp.sroa.0.0.copyload.i.i.epil = load i64, i64* %agg.tmp.sroa.0.0..sroa_cast.i.i.epil, align 4, !tbaa.struct !55
  %s.sroa.1.0.extract.shift.i.i.i.epil = lshr i64 %agg.tmp.sroa.0.0.copyload.i.i.epil, 32
  %s.sroa.1.0.extract.trunc.i.i.i.epil = trunc i64 %s.sroa.1.0.extract.shift.i.i.i.epil to i32
  %cmp.i.i.i808.epil = icmp ugt i32 %s.sroa.1.0.extract.trunc.i.i.i.epil, 1
  br i1 %cmp.i.i.i808.epil, label %if.then.i.i809.epil, label %for.inc.i.i.epil

if.then.i.i809.epil:                              ; preds = %for.body.i.i.epil
  %inc.i.i.epil = add i32 %k.015.i.i.epil, 1
  %idxprom3.i.i.epil = zext i32 %k.015.i.i.epil to i64
  %arrayidx4.i.i.epil = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %idxprom3.i.i.epil
  %317 = bitcast %struct.seg* %arrayidx4.i.i.epil to i64*
  store i64 %agg.tmp.sroa.0.0.copyload.i.i.epil, i64* %317, align 4
  br label %for.inc.i.i.epil

for.inc.i.i.epil:                                 ; preds = %if.then.i.i809.epil, %for.body.i.i.epil
  %k.1.i.i.epil = phi i32 [ %inc.i.i.epil, %if.then.i.i809.epil ], [ %k.015.i.i.epil, %for.body.i.i.epil ]
  %indvars.iv.next.i.i.epil = add nuw nsw i64 %indvars.iv.i.i.epil, 1
  %epil.iter1508.sub = add i64 %epil.iter1508, -1
  %epil.iter1508.cmp = icmp eq i64 %epil.iter1508.sub, 0
  br i1 %epil.iter1508.cmp, label %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit, label %for.body.i.i.epil, !llvm.loop !61

_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit: ; preds = %for.inc.i.i.epil
  %k.1.i.i.epil.lcssa = phi i32 [ %k.1.i.i.epil, %for.inc.i.i.epil ]
  br label %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend

_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend: ; preds = %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit, %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa, %sync.continue.i
  %retval.0.i = phi i32 [ %conv.i.i813, %sync.continue.i ], [ %k.1.i.i.lcssa.ph, %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa ], [ %k.1.i.i.epil.lcssa, %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit ]
  %cmp190 = icmp eq i32 %retval.0.i, 0
  br i1 %cmp190, label %while.end, label %pfor.cond205.preheader

pfor.cond205.preheader:                           ; preds = %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend
  %wide.trip.count1095 = zext i32 %retval.0.i to i64
  %318 = add nsw i64 %wide.trip.count1095, -1
  %xtraiter1157 = and i64 %wide.trip.count1095, 2047
  %319 = icmp ult i64 %318, 2047
  br i1 %319, label %pfor.cond.cleanup220.strpm-lcssa, label %pfor.cond205.preheader.new

pfor.cond205.preheader.new:                       ; preds = %pfor.cond205.preheader
  %stripiter11601193 = lshr i32 %retval.0.i, 11
  %stripiter1160.zext = zext i32 %stripiter11601193 to i64
  br label %pfor.cond205.strpm.outer

lpad143:                                          ; preds = %_ZN5timer10reportNextEv.exit.i, %call2.i.i.noexc, %cleanup139
  %320 = landingpad { i8*, i32 }
          cleanup
  %321 = extractvalue { i8*, i32 } %320, 0
  %322 = extractvalue { i8*, i32 } %320, 1
  %323 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !53
  %cmp.i.i.i816 = icmp eq i8* %323, %211
  br i1 %cmp.i.i.i816, label %ehcleanup450, label %if.then.i.i817

if.then.i.i817:                                   ; preds = %lpad143
  call void @_ZdlPv(i8* %323) #16
  br label %ehcleanup450

lpad151:                                          ; preds = %_ZN5timer10reportNextEv.exit.i731, %call2.i.i.noexc732, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit700
  %324 = landingpad { i8*, i32 }
          cleanup
  %325 = extractvalue { i8*, i32 } %324, 0
  %326 = extractvalue { i8*, i32 } %324, 1
  %327 = load i8*, i8** %_M_p.i.i.i.i.i707, align 8, !tbaa !53
  %cmp.i.i.i821 = icmp eq i8* %327, %222
  br i1 %cmp.i.i.i821, label %ehcleanup450, label %if.then.i.i822

if.then.i.i822:                                   ; preds = %lpad151
  call void @_ZdlPv(i8* %327) #16
  br label %ehcleanup450

lpad166:                                          ; preds = %_ZN5timer10reportNextEv.exit.i772, %call2.i.i.noexc773, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit741
  %328 = landingpad { i8*, i32 }
          cleanup
  %329 = extractvalue { i8*, i32 } %328, 0
  %330 = extractvalue { i8*, i32 } %328, 1
  %331 = load i8*, i8** %_M_p.i.i.i.i.i748, align 8, !tbaa !53
  %cmp.i.i.i826 = icmp eq i8* %331, %235
  br i1 %cmp.i.i.i826, label %ehcleanup450, label %if.then.i.i827

if.then.i.i827:                                   ; preds = %lpad166
  call void @_ZdlPv(i8* %331) #16
  br label %ehcleanup450

lpad181:                                          ; preds = %while.cond
  %332 = landingpad { i8*, i32 }
          cleanup
  %333 = extractvalue { i8*, i32 } %332, 0
  %334 = extractvalue { i8*, i32 } %332, 1
  br label %ehcleanup450

lpad183:                                          ; preds = %call.i798.noexc, %if.then.i
  %335 = landingpad { i8*, i32 }
          cleanup
  %336 = extractvalue { i8*, i32 } %335, 0
  %337 = extractvalue { i8*, i32 } %335, 1
  %338 = load i8*, i8** %_M_p.i18.i.i.i.i786, align 8, !tbaa !53
  %cmp.i.i.i832 = icmp eq i8* %338, %247
  br i1 %cmp.i.i.i832, label %ehcleanup450, label %if.then.i.i833

if.then.i.i833:                                   ; preds = %lpad183
  call void @_ZdlPv(i8* %338) #16
  br label %ehcleanup450

pfor.cond205.strpm.outer:                         ; preds = %pfor.inc217.strpm.outer, %pfor.cond205.preheader.new
  %niter1161 = phi i64 [ 0, %pfor.cond205.preheader.new ], [ %niter1161.nadd, %pfor.inc217.strpm.outer ]
  detach within %syncreg.i, label %pfor.body211.strpm.outer, label %pfor.inc217.strpm.outer

pfor.body211.strpm.outer:                         ; preds = %pfor.cond205.strpm.outer
  %339 = shl i64 %niter1161, 11
  br label %vector.ph1353

vector.ph1353:                                    ; preds = %pfor.body211.strpm.outer
  %ind.end1357 = or i64 %339, 2016
  br label %vector.body1352

vector.body1352:                                  ; preds = %vector.body1352.1, %vector.ph1353
  %index1354 = phi i64 [ 0, %vector.ph1353 ], [ %index.next1355.1, %vector.body1352.1 ]
  %offset.idx1360 = add nuw nsw i64 %339, %index1354
  %340 = or i64 %offset.idx1360, 8
  %341 = or i64 %offset.idx1360, 16
  %342 = or i64 %offset.idx1360, 24
  %343 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %offset.idx1360, i32 1
  %344 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %340, i32 1
  %345 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %341, i32 1
  %346 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %342, i32 1
  %347 = bitcast i32* %343 to <16 x i32>*
  %348 = bitcast i32* %344 to <16 x i32>*
  %349 = bitcast i32* %345 to <16 x i32>*
  %350 = bitcast i32* %346 to <16 x i32>*
  %wide.vec1374 = load <16 x i32>, <16 x i32>* %347, align 4, !tbaa !62
  %wide.vec1375 = load <16 x i32>, <16 x i32>* %348, align 4, !tbaa !62
  %wide.vec1376 = load <16 x i32>, <16 x i32>* %349, align 4, !tbaa !62
  %wide.vec1377 = load <16 x i32>, <16 x i32>* %350, align 4, !tbaa !62
  %strided.vec1378 = shufflevector <16 x i32> %wide.vec1374, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1379 = shufflevector <16 x i32> %wide.vec1375, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1380 = shufflevector <16 x i32> %wide.vec1376, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1381 = shufflevector <16 x i32> %wide.vec1377, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %351 = getelementptr inbounds i32, i32* %243, i64 %offset.idx1360
  %352 = bitcast i32* %351 to <8 x i32>*
  store <8 x i32> %strided.vec1378, <8 x i32>* %352, align 4, !tbaa !16
  %353 = getelementptr inbounds i32, i32* %351, i64 8
  %354 = bitcast i32* %353 to <8 x i32>*
  store <8 x i32> %strided.vec1379, <8 x i32>* %354, align 4, !tbaa !16
  %355 = getelementptr inbounds i32, i32* %351, i64 16
  %356 = bitcast i32* %355 to <8 x i32>*
  store <8 x i32> %strided.vec1380, <8 x i32>* %356, align 4, !tbaa !16
  %357 = getelementptr inbounds i32, i32* %351, i64 24
  %358 = bitcast i32* %357 to <8 x i32>*
  store <8 x i32> %strided.vec1381, <8 x i32>* %358, align 4, !tbaa !16
  %index.next1355 = or i64 %index1354, 32
  %359 = icmp eq i64 %index.next1355, 2016
  br i1 %359, label %pfor.cond205, label %vector.body1352.1, !llvm.loop !64

pfor.cond205:                                     ; preds = %vector.body1352
  %indvars.iv.next1094 = or i64 %339, 2017
  %length = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %ind.end1357, i32 1
  %360 = load i32, i32* %length, align 4, !tbaa !62
  %arrayidx215 = getelementptr inbounds i32, i32* %243, i64 %ind.end1357
  store i32 %360, i32* %arrayidx215, align 4, !tbaa !16
  %indvars.iv.next1094.1 = add nuw nsw i64 %indvars.iv.next1094, 1
  %length.1 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094, i32 1
  %361 = load i32, i32* %length.1, align 4, !tbaa !62
  %arrayidx215.1 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094
  store i32 %361, i32* %arrayidx215.1, align 4, !tbaa !16
  %indvars.iv.next1094.2 = or i64 %339, 2019
  %length.2 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.1, i32 1
  %362 = load i32, i32* %length.2, align 4, !tbaa !62
  %arrayidx215.2 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.1
  store i32 %362, i32* %arrayidx215.2, align 4, !tbaa !16
  %indvars.iv.next1094.3 = add nuw nsw i64 %indvars.iv.next1094.2, 1
  %length.3 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.2, i32 1
  %363 = load i32, i32* %length.3, align 4, !tbaa !62
  %arrayidx215.3 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.2
  store i32 %363, i32* %arrayidx215.3, align 4, !tbaa !16
  %indvars.iv.next1094.4 = add nuw nsw i64 %indvars.iv.next1094.2, 2
  %length.4 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.3, i32 1
  %364 = load i32, i32* %length.4, align 4, !tbaa !62
  %arrayidx215.4 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.3
  store i32 %364, i32* %arrayidx215.4, align 4, !tbaa !16
  %indvars.iv.next1094.5 = add nuw nsw i64 %indvars.iv.next1094.2, 3
  %length.5 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.4, i32 1
  %365 = load i32, i32* %length.5, align 4, !tbaa !62
  %arrayidx215.5 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.4
  store i32 %365, i32* %arrayidx215.5, align 4, !tbaa !16
  %indvars.iv.next1094.6 = or i64 %339, 2023
  %length.6 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.5, i32 1
  %366 = load i32, i32* %length.6, align 4, !tbaa !62
  %arrayidx215.6 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.5
  store i32 %366, i32* %arrayidx215.6, align 4, !tbaa !16
  %indvars.iv.next1094.7 = add nuw nsw i64 %indvars.iv.next1094.6, 1
  %length.7 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.6, i32 1
  %367 = load i32, i32* %length.7, align 4, !tbaa !62
  %arrayidx215.7 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.6
  store i32 %367, i32* %arrayidx215.7, align 4, !tbaa !16
  %indvars.iv.next1094.8 = add nuw nsw i64 %indvars.iv.next1094.6, 2
  %length.8 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.7, i32 1
  %368 = load i32, i32* %length.8, align 4, !tbaa !62
  %arrayidx215.8 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.7
  store i32 %368, i32* %arrayidx215.8, align 4, !tbaa !16
  %indvars.iv.next1094.9 = add nuw nsw i64 %indvars.iv.next1094.6, 3
  %length.9 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.8, i32 1
  %369 = load i32, i32* %length.9, align 4, !tbaa !62
  %arrayidx215.9 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.8
  store i32 %369, i32* %arrayidx215.9, align 4, !tbaa !16
  %indvars.iv.next1094.10 = add nuw nsw i64 %indvars.iv.next1094.6, 4
  %length.10 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.9, i32 1
  %370 = load i32, i32* %length.10, align 4, !tbaa !62
  %arrayidx215.10 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.9
  store i32 %370, i32* %arrayidx215.10, align 4, !tbaa !16
  %indvars.iv.next1094.11 = add nuw nsw i64 %indvars.iv.next1094.6, 5
  %length.11 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.10, i32 1
  %371 = load i32, i32* %length.11, align 4, !tbaa !62
  %arrayidx215.11 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.10
  store i32 %371, i32* %arrayidx215.11, align 4, !tbaa !16
  %indvars.iv.next1094.12 = add nuw nsw i64 %indvars.iv.next1094.6, 6
  %length.12 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.11, i32 1
  %372 = load i32, i32* %length.12, align 4, !tbaa !62
  %arrayidx215.12 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.11
  store i32 %372, i32* %arrayidx215.12, align 4, !tbaa !16
  %indvars.iv.next1094.13 = add nuw nsw i64 %indvars.iv.next1094.6, 7
  %length.13 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.12, i32 1
  %373 = load i32, i32* %length.13, align 4, !tbaa !62
  %arrayidx215.13 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.12
  store i32 %373, i32* %arrayidx215.13, align 4, !tbaa !16
  %indvars.iv.next1094.14 = or i64 %339, 2031
  %length.14 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.13, i32 1
  %374 = load i32, i32* %length.14, align 4, !tbaa !62
  %arrayidx215.14 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.13
  store i32 %374, i32* %arrayidx215.14, align 4, !tbaa !16
  %indvars.iv.next1094.15 = add nuw nsw i64 %indvars.iv.next1094.14, 1
  %length.15 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.14, i32 1
  %375 = load i32, i32* %length.15, align 4, !tbaa !62
  %arrayidx215.15 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.14
  store i32 %375, i32* %arrayidx215.15, align 4, !tbaa !16
  %indvars.iv.next1094.16 = add nuw nsw i64 %indvars.iv.next1094.14, 2
  %length.16 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.15, i32 1
  %376 = load i32, i32* %length.16, align 4, !tbaa !62
  %arrayidx215.16 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.15
  store i32 %376, i32* %arrayidx215.16, align 4, !tbaa !16
  %indvars.iv.next1094.17 = add nuw nsw i64 %indvars.iv.next1094.14, 3
  %length.17 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.16, i32 1
  %377 = load i32, i32* %length.17, align 4, !tbaa !62
  %arrayidx215.17 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.16
  store i32 %377, i32* %arrayidx215.17, align 4, !tbaa !16
  %indvars.iv.next1094.18 = add nuw nsw i64 %indvars.iv.next1094.14, 4
  %length.18 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.17, i32 1
  %378 = load i32, i32* %length.18, align 4, !tbaa !62
  %arrayidx215.18 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.17
  store i32 %378, i32* %arrayidx215.18, align 4, !tbaa !16
  %indvars.iv.next1094.19 = add nuw nsw i64 %indvars.iv.next1094.14, 5
  %length.19 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.18, i32 1
  %379 = load i32, i32* %length.19, align 4, !tbaa !62
  %arrayidx215.19 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.18
  store i32 %379, i32* %arrayidx215.19, align 4, !tbaa !16
  %indvars.iv.next1094.20 = add nuw nsw i64 %indvars.iv.next1094.14, 6
  %length.20 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.19, i32 1
  %380 = load i32, i32* %length.20, align 4, !tbaa !62
  %arrayidx215.20 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.19
  store i32 %380, i32* %arrayidx215.20, align 4, !tbaa !16
  %indvars.iv.next1094.21 = add nuw nsw i64 %indvars.iv.next1094.14, 7
  %length.21 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.20, i32 1
  %381 = load i32, i32* %length.21, align 4, !tbaa !62
  %arrayidx215.21 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.20
  store i32 %381, i32* %arrayidx215.21, align 4, !tbaa !16
  %indvars.iv.next1094.22 = add nuw nsw i64 %indvars.iv.next1094.14, 8
  %length.22 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.21, i32 1
  %382 = load i32, i32* %length.22, align 4, !tbaa !62
  %arrayidx215.22 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.21
  store i32 %382, i32* %arrayidx215.22, align 4, !tbaa !16
  %indvars.iv.next1094.23 = add nuw nsw i64 %indvars.iv.next1094.14, 9
  %length.23 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.22, i32 1
  %383 = load i32, i32* %length.23, align 4, !tbaa !62
  %arrayidx215.23 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.22
  store i32 %383, i32* %arrayidx215.23, align 4, !tbaa !16
  %indvars.iv.next1094.24 = add nuw nsw i64 %indvars.iv.next1094.14, 10
  %length.24 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.23, i32 1
  %384 = load i32, i32* %length.24, align 4, !tbaa !62
  %arrayidx215.24 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.23
  store i32 %384, i32* %arrayidx215.24, align 4, !tbaa !16
  %indvars.iv.next1094.25 = add nuw nsw i64 %indvars.iv.next1094.14, 11
  %length.25 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.24, i32 1
  %385 = load i32, i32* %length.25, align 4, !tbaa !62
  %arrayidx215.25 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.24
  store i32 %385, i32* %arrayidx215.25, align 4, !tbaa !16
  %indvars.iv.next1094.26 = add nuw nsw i64 %indvars.iv.next1094.14, 12
  %length.26 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.25, i32 1
  %386 = load i32, i32* %length.26, align 4, !tbaa !62
  %arrayidx215.26 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.25
  store i32 %386, i32* %arrayidx215.26, align 4, !tbaa !16
  %indvars.iv.next1094.27 = add nuw nsw i64 %indvars.iv.next1094.14, 13
  %length.27 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.26, i32 1
  %387 = load i32, i32* %length.27, align 4, !tbaa !62
  %arrayidx215.27 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.26
  store i32 %387, i32* %arrayidx215.27, align 4, !tbaa !16
  %indvars.iv.next1094.28 = add nuw nsw i64 %indvars.iv.next1094.14, 14
  %length.28 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.27, i32 1
  %388 = load i32, i32* %length.28, align 4, !tbaa !62
  %arrayidx215.28 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.27
  store i32 %388, i32* %arrayidx215.28, align 4, !tbaa !16
  %indvars.iv.next1094.29 = add nuw nsw i64 %indvars.iv.next1094.14, 15
  %length.29 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.28, i32 1
  %389 = load i32, i32* %length.29, align 4, !tbaa !62
  %arrayidx215.29 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.28
  store i32 %389, i32* %arrayidx215.29, align 4, !tbaa !16
  %indvars.iv.next1094.30 = or i64 %339, 2047
  %length.30 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.29, i32 1
  %390 = load i32, i32* %length.30, align 4, !tbaa !62
  %arrayidx215.30 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.29
  store i32 %390, i32* %arrayidx215.30, align 4, !tbaa !16
  %length.31 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv.next1094.30, i32 1
  %391 = load i32, i32* %length.31, align 4, !tbaa !62
  %arrayidx215.31 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv.next1094.30
  store i32 %391, i32* %arrayidx215.31, align 4, !tbaa !16
  reattach within %syncreg.i, label %pfor.inc217.strpm.outer

pfor.inc217.strpm.outer:                          ; preds = %pfor.cond205, %pfor.cond205.strpm.outer
  %niter1161.nadd = add nuw nsw i64 %niter1161, 1
  %niter1161.ncmp = icmp eq i64 %niter1161.nadd, %stripiter1160.zext
  br i1 %niter1161.ncmp, label %pfor.cond.cleanup220.strpm-lcssa.loopexit, label %pfor.cond205.strpm.outer, !llvm.loop !65

pfor.cond.cleanup220.strpm-lcssa.loopexit:        ; preds = %pfor.inc217.strpm.outer
  br label %pfor.cond.cleanup220.strpm-lcssa

pfor.cond.cleanup220.strpm-lcssa:                 ; preds = %pfor.cond.cleanup220.strpm-lcssa.loopexit, %pfor.cond205.preheader
  %lcmp.mod1163 = icmp eq i64 %xtraiter1157, 0
  br i1 %lcmp.mod1163, label %pfor.cond.cleanup220, label %pfor.cond205.epil.preheader

pfor.cond205.epil.preheader:                      ; preds = %pfor.cond.cleanup220.strpm-lcssa
  %392 = and i64 %wide.trip.count1095, 4294965248
  %min.iters.check1317 = icmp ult i64 %xtraiter1157, 33
  br i1 %min.iters.check1317, label %pfor.cond205.epil.preheader1497, label %vector.ph1318

vector.ph1318:                                    ; preds = %pfor.cond205.epil.preheader
  %n.mod.vf1319 = and i64 %wide.trip.count1095, 31
  %393 = icmp eq i64 %n.mod.vf1319, 0
  %394 = select i1 %393, i64 32, i64 %n.mod.vf1319
  %n.vec1320 = sub nsw i64 %xtraiter1157, %394
  %ind.end1324 = add nsw i64 %392, %n.vec1320
  br label %vector.body1316

vector.body1316:                                  ; preds = %vector.body1316, %vector.ph1318
  %index1321 = phi i64 [ 0, %vector.ph1318 ], [ %index.next1322, %vector.body1316 ]
  %offset.idx1328 = add i64 %392, %index1321
  %395 = or i64 %offset.idx1328, 8
  %396 = or i64 %offset.idx1328, 16
  %397 = or i64 %offset.idx1328, 24
  %398 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %offset.idx1328, i32 1
  %399 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %395, i32 1
  %400 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %396, i32 1
  %401 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %397, i32 1
  %402 = bitcast i32* %398 to <16 x i32>*
  %403 = bitcast i32* %399 to <16 x i32>*
  %404 = bitcast i32* %400 to <16 x i32>*
  %405 = bitcast i32* %401 to <16 x i32>*
  %wide.vec1342 = load <16 x i32>, <16 x i32>* %402, align 4, !tbaa !62
  %wide.vec1343 = load <16 x i32>, <16 x i32>* %403, align 4, !tbaa !62
  %wide.vec1344 = load <16 x i32>, <16 x i32>* %404, align 4, !tbaa !62
  %wide.vec1345 = load <16 x i32>, <16 x i32>* %405, align 4, !tbaa !62
  %strided.vec1346 = shufflevector <16 x i32> %wide.vec1342, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1347 = shufflevector <16 x i32> %wide.vec1343, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1348 = shufflevector <16 x i32> %wide.vec1344, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1349 = shufflevector <16 x i32> %wide.vec1345, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %406 = getelementptr inbounds i32, i32* %243, i64 %offset.idx1328
  %407 = bitcast i32* %406 to <8 x i32>*
  store <8 x i32> %strided.vec1346, <8 x i32>* %407, align 4, !tbaa !16
  %408 = getelementptr inbounds i32, i32* %406, i64 8
  %409 = bitcast i32* %408 to <8 x i32>*
  store <8 x i32> %strided.vec1347, <8 x i32>* %409, align 4, !tbaa !16
  %410 = getelementptr inbounds i32, i32* %406, i64 16
  %411 = bitcast i32* %410 to <8 x i32>*
  store <8 x i32> %strided.vec1348, <8 x i32>* %411, align 4, !tbaa !16
  %412 = getelementptr inbounds i32, i32* %406, i64 24
  %413 = bitcast i32* %412 to <8 x i32>*
  store <8 x i32> %strided.vec1349, <8 x i32>* %413, align 4, !tbaa !16
  %index.next1322 = add i64 %index1321, 32
  %414 = icmp eq i64 %index.next1322, %n.vec1320
  br i1 %414, label %pfor.cond205.epil.preheader1497.loopexit, label %vector.body1316, !llvm.loop !66

pfor.cond205.epil.preheader1497.loopexit:         ; preds = %vector.body1316
  br label %pfor.cond205.epil.preheader1497

pfor.cond205.epil.preheader1497:                  ; preds = %pfor.cond205.epil.preheader1497.loopexit, %pfor.cond205.epil.preheader
  %indvars.iv1093.epil.ph = phi i64 [ %392, %pfor.cond205.epil.preheader ], [ %ind.end1324, %pfor.cond205.epil.preheader1497.loopexit ]
  %epil.iter1158.ph = phi i64 [ %xtraiter1157, %pfor.cond205.epil.preheader ], [ %394, %pfor.cond205.epil.preheader1497.loopexit ]
  br label %pfor.cond205.epil

pfor.cond205.epil:                                ; preds = %pfor.cond205.epil, %pfor.cond205.epil.preheader1497
  %indvars.iv1093.epil = phi i64 [ %indvars.iv.next1094.epil, %pfor.cond205.epil ], [ %indvars.iv1093.epil.ph, %pfor.cond205.epil.preheader1497 ]
  %epil.iter1158 = phi i64 [ %epil.iter1158.sub, %pfor.cond205.epil ], [ %epil.iter1158.ph, %pfor.cond205.epil.preheader1497 ]
  %indvars.iv.next1094.epil = add nuw nsw i64 %indvars.iv1093.epil, 1
  %length.epil = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv1093.epil, i32 1
  %415 = load i32, i32* %length.epil, align 4, !tbaa !62
  %arrayidx215.epil = getelementptr inbounds i32, i32* %243, i64 %indvars.iv1093.epil
  store i32 %415, i32* %arrayidx215.epil, align 4, !tbaa !16
  %epil.iter1158.sub = add nsw i64 %epil.iter1158, -1
  %epil.iter1158.cmp = icmp eq i64 %epil.iter1158.sub, 0
  br i1 %epil.iter1158.cmp, label %pfor.cond.cleanup220.loopexit, label %pfor.cond205.epil, !llvm.loop !67

pfor.cond.cleanup220.loopexit:                    ; preds = %pfor.cond205.epil
  br label %pfor.cond.cleanup220

pfor.cond.cleanup220:                             ; preds = %pfor.cond.cleanup220.loopexit, %pfor.cond.cleanup220.strpm-lcssa
  sync within %syncreg.i, label %sync.continue222

sync.continue222:                                 ; preds = %pfor.cond.cleanup220
  call void @llvm.sync.unwind(token %syncreg.i)
  %call.i835 = call i32 @_ZN8sequence4scanIjjN5utils4addFIjEENS_4getAIjjEELi1024EEET_PS6_T0_S8_T1_T2_S6_bb(i32* %243, i32 0, i32 %retval.0.i, i32* %243, i32 0, i1 zeroext false, i1 zeroext false)
  %call1.i837 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([9 x i8], [9 x i8]* @.str.13, i64 0, i64 0), i64 8)
  %call.i840 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream"* nonnull @_ZSt4cout, i64 %wide.trip.count1095)
  %call1.i842 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i840, i8* nonnull getelementptr inbounds ([10 x i8], [10 x i8]* @.str.14, i64 0, i64 0), i64 9)
  %conv.i844 = zext i32 %call.i835 to i64
  %call.i845 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream"* nonnull %call.i840, i64 %conv.i844)
  %call1.i847 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i845, i8* nonnull getelementptr inbounds ([18 x i8], [18 x i8]* @.str.15, i64 0, i64 0), i64 17)
  %conv.i849 = zext i32 %offset.0 to i64
  %call.i850 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream"* nonnull %call.i845, i64 %conv.i849)
  %416 = bitcast %"class.std::basic_ostream"* %call.i850 to i8**
  %vtable.i852 = load i8*, i8** %416, align 8, !tbaa !22
  %vbase.offset.ptr.i853 = getelementptr i8, i8* %vtable.i852, i64 -24
  %417 = bitcast i8* %vbase.offset.ptr.i853 to i64*
  %vbase.offset.i854 = load i64, i64* %417, align 8
  %add.ptr.i855 = getelementptr inbounds %"class.std::basic_ostream", %"class.std::basic_ostream"* %call.i850, i64 0, i32 1, i32 4
  %418 = bitcast %"class.std::basic_streambuf"** %add.ptr.i855 to i8*
  %_M_ctype.i1012 = getelementptr inbounds i8, i8* %418, i64 %vbase.offset.i854
  %419 = bitcast i8* %_M_ctype.i1012 to %"class.std::ctype"**
  %420 = load %"class.std::ctype"*, %"class.std::ctype"** %419, align 8, !tbaa !24
  %tobool.i1031 = icmp eq %"class.std::ctype"* %420, null
  br i1 %tobool.i1031, label %if.then.i1032, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit1034

if.then.i1032:                                    ; preds = %sync.continue222
  call void @_ZSt16__throw_bad_castv() #17
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit1034: ; preds = %sync.continue222
  %_M_widen_ok.i1014 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %420, i64 0, i32 8
  %421 = load i8, i8* %_M_widen_ok.i1014, align 8, !tbaa !27
  %tobool.i1015 = icmp eq i8 %421, 0
  br i1 %tobool.i1015, label %if.end.i1021, label %if.then.i1017

if.then.i1017:                                    ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit1034
  %arrayidx.i1016 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %420, i64 0, i32 9, i64 10
  %422 = load i8, i8* %arrayidx.i1016, align 1, !tbaa !15
  br label %_ZNKSt5ctypeIcE5widenEc.exit1023

if.end.i1021:                                     ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit1034
  call void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %420)
  %423 = bitcast %"class.std::ctype"* %420 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i1018 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %423, align 8, !tbaa !22
  %vfn.i1019 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i1018, i64 6
  %424 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i1019, align 8
  %call.i1020 = call signext i8 %424(%"class.std::ctype"* nonnull %420, i8 signext 10)
  br label %_ZNKSt5ctypeIcE5widenEc.exit1023

_ZNKSt5ctypeIcE5widenEc.exit1023:                 ; preds = %if.end.i1021, %if.then.i1017
  %retval.0.i1022 = phi i8 [ %422, %if.then.i1017 ], [ %call.i1020, %if.end.i1021 ]
  %call1.i857 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i850, i8 signext %retval.0.i1022)
  %call.i858 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i857)
  store %union.anon* %249, %union.anon** %250, align 8, !tbaa !47
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(15) %251, i8* nonnull align 1 dereferenceable(15) getelementptr inbounds ([16 x i8], [16 x i8]* @.str.16, i64 0, i64 0), i64 15, i1 false) #16
  store i64 15, i64* %_M_string_length.i.i.i.i.i.i869, align 8, !tbaa !49
  store i8 0, i8* %262, align 1, !tbaa !15
  %call2.i.i891 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull %251, i64 15)
          to label %call2.i.i.noexc890 unwind label %lpad241

call2.i.i.noexc890:                               ; preds = %_ZNKSt5ctypeIcE5widenEc.exit1023
  %call1.i.i893 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call2.i.i891, i8* nonnull getelementptr inbounds ([4 x i8], [4 x i8]* @.str.17, i64 0, i64 0), i64 3)
          to label %call1.i.i.noexc892 unwind label %lpad241

call1.i.i.noexc892:                               ; preds = %call2.i.i.noexc890
  %425 = load i8, i8* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 3), align 8, !tbaa !2, !range !51
  %tobool.i.i.i877 = icmp eq i8 %425, 0
  br i1 %tobool.i.i.i877, label %_ZN5timer10reportNextEv.exit.i889, label %if.end.i.i.i887

if.end.i.i.i887:                                  ; preds = %call1.i.i.noexc892
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %252) #16
  %call.i.i.i.i878 = call i32 @gettimeofday(%struct.timeval* nonnull %now.i.i.i.i874, i8* nonnull bitcast (%struct.timezone* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 5) to i8*)) #16
  %426 = load i64, i64* %tv_sec.i.i.i.i879, align 8, !tbaa !10
  %conv.i.i.i.i880 = sitofp i64 %426 to double
  %427 = load i64, i64* %tv_usec.i.i.i.i881, align 8, !tbaa !13
  %conv2.i.i.i.i882 = sitofp i64 %427 to double
  %div.i.i.i.i883 = fdiv double %conv2.i.i.i.i882, 1.000000e+06
  %add.i.i.i.i884 = fadd double %div.i.i.i.i883, %conv.i.i.i.i880
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %252) #16
  %428 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  %sub.i.i.i885 = fsub double %add.i.i.i.i884, %428
  %429 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  %add.i.i.i886 = fadd double %429, %sub.i.i.i885
  store double %add.i.i.i886, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  store double %add.i.i.i.i884, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  br label %_ZN5timer10reportNextEv.exit.i889

_ZN5timer10reportNextEv.exit.i889:                ; preds = %if.end.i.i.i887, %call1.i.i.noexc892
  %retval.0.i.i.i888 = phi double [ %sub.i.i.i885, %if.end.i.i.i887 ], [ 0.000000e+00, %call1.i.i.noexc892 ]
  invoke void @_ZN5timer7reportTEd(%struct.timer* nonnull @_ZL3_tm, double %retval.0.i.i.i888)
          to label %invoke.cont242 unwind label %lpad241

invoke.cont242:                                   ; preds = %_ZN5timer10reportNextEv.exit.i889
  %430 = load i8*, i8** %_M_p.i.i.i.i.i865, align 8, !tbaa !53
  %cmp.i.i.i897 = icmp eq i8* %430, %251
  br i1 %cmp.i.i.i897, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit899, label %if.then.i.i898

if.then.i.i898:                                   ; preds = %invoke.cont242
  call void @_ZdlPv(i8* %430) #16
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit899

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit899: ; preds = %if.then.i.i898, %invoke.cont242
  %431 = icmp ugt i32 %retval.0.i, 1
  %umax = select i1 %431, i32 %retval.0.i, i32 1
  %wide.trip.count1103 = zext i32 %umax to i64
  %broadcast.splatinsert1308 = insertelement <8 x i32> undef, i32 %offset.0, i32 0
  %broadcast.splat1309 = shufflevector <8 x i32> %broadcast.splatinsert1308, <8 x i32> undef, <8 x i32> zeroinitializer
  %broadcast.splatinsert1282 = insertelement <8 x i32> undef, i32 %offset.0, i32 0
  %broadcast.splat1283 = shufflevector <8 x i32> %broadcast.splatinsert1282, <8 x i32> undef, <8 x i32> zeroinitializer
  br label %pfor.cond258

lpad241:                                          ; preds = %_ZN5timer10reportNextEv.exit.i889, %call2.i.i.noexc890, %_ZNKSt5ctypeIcE5widenEc.exit1023
  %432 = landingpad { i8*, i32 }
          cleanup
  %433 = extractvalue { i8*, i32 } %432, 0
  %434 = extractvalue { i8*, i32 } %432, 1
  %435 = load i8*, i8** %_M_p.i.i.i.i.i865, align 8, !tbaa !53
  %cmp.i.i.i902 = icmp eq i8* %435, %251
  br i1 %cmp.i.i.i902, label %ehcleanup450, label %if.then.i.i903

if.then.i.i903:                                   ; preds = %lpad241
  call void @_ZdlPv(i8* %435) #16
  br label %ehcleanup450

pfor.cond258:                                     ; preds = %pfor.inc320, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit899
  %indvars.iv1101 = phi i64 [ %indvars.iv.next1102, %pfor.inc320 ], [ 0, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit899 ]
  %indvars.iv.next1102 = add nuw nsw i64 %indvars.iv1101, 1
  detach within %syncreg.i, label %pfor.body264, label %pfor.inc320

pfor.body264:                                     ; preds = %pfor.cond258
  %syncreg271 = call token @llvm.syncregion.start()
  %start267 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv1101, i32 0
  %436 = load i32, i32* %start267, align 4, !tbaa !68
  %idx.ext = zext i32 %436 to i64
  %add.ptr = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %idx.ext
  %length270 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv1101, i32 1
  %437 = load i32, i32* %length270, align 4, !tbaa !62
  %cmp274 = icmp eq i32 %437, 0
  br i1 %cmp274, label %cleanup309, label %pfor.cond284.preheader

pfor.cond284.preheader:                           ; preds = %pfor.body264
  %wide.trip.count1099 = zext i32 %437 to i64
  %438 = add nsw i64 %wide.trip.count1099, -1
  %xtraiter1164 = and i64 %wide.trip.count1099, 255
  %439 = icmp ult i64 %438, 255
  br i1 %439, label %pfor.cond.cleanup304.strpm-lcssa, label %pfor.cond284.preheader.new

pfor.cond284.preheader.new:                       ; preds = %pfor.cond284.preheader
  detach within %syncreg271, label %pfor.cond284.strpm.detachloop.entry, label %pfor.cond.cleanup304.strpm-lcssa

pfor.cond284.strpm.detachloop.entry:              ; preds = %pfor.cond284.preheader.new
  %syncreg271.strpm.detachloop = call token @llvm.syncregion.start()
  %stripiter11671192 = lshr i32 %437, 8
  %stripiter1167.zext = zext i32 %stripiter11671192 to i64
  br label %pfor.cond284.strpm.outer

pfor.cond284.strpm.outer:                         ; preds = %pfor.inc301.strpm.outer, %pfor.cond284.strpm.detachloop.entry
  %niter1168 = phi i64 [ 0, %pfor.cond284.strpm.detachloop.entry ], [ %niter1168.nadd, %pfor.inc301.strpm.outer ]
  detach within %syncreg271.strpm.detachloop, label %pfor.body290.strpm.outer, label %pfor.inc301.strpm.outer

pfor.body290.strpm.outer:                         ; preds = %pfor.cond284.strpm.outer
  %440 = shl i64 %niter1168, 8
  br label %vector.ph1290

vector.ph1290:                                    ; preds = %pfor.body290.strpm.outer
  %ind.end1294 = or i64 %440, 248
  %.splatinsert1297 = insertelement <8 x i64> undef, i64 %440, i32 0
  %.splat1298 = shufflevector <8 x i64> %.splatinsert1297, <8 x i64> undef, <8 x i32> zeroinitializer
  %induction1299 = add <8 x i64> %.splat1298, <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7>
  br label %vector.body1289

vector.body1289:                                  ; preds = %vector.body1289.3, %vector.ph1290
  %index1291 = phi i64 [ 0, %vector.ph1290 ], [ %index.next1292.3, %vector.body1289.3 ]
  %vec.ind1300 = phi <8 x i64> [ %induction1299, %vector.ph1290 ], [ %vec.ind.next1301.3, %vector.body1289.3 ]
  %441 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, <8 x i64> %vec.ind1300
  %442 = extractelement <8 x %"struct.std::pair"*> %441, i32 0
  %443 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %442, i64 0, i32 1
  %444 = bitcast i32* %443 to <16 x i32>*
  %wide.vec1306 = load <16 x i32>, <16 x i32>* %444, align 4, !tbaa !69
  %strided.vec1307 = shufflevector <16 x i32> %wide.vec1306, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %445 = add <8 x i32> %strided.vec1307, %broadcast.splat1309
  %446 = zext <8 x i32> %445 to <8 x i64>
  %447 = icmp sgt <8 x i64> %broadcast.splat1311, %446
  %448 = getelementptr inbounds i32, i32* %231, <8 x i64> %446
  %wide.masked.gather1312 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %448, i32 4, <8 x i1> %447, <8 x i32> undef), !tbaa !16
  %predphi1313 = select <8 x i1> %447, <8 x i32> %wide.masked.gather1312, <8 x i32> zeroinitializer
  %449 = getelementptr inbounds %"struct.std::pair", <8 x %"struct.std::pair"*> %441, i64 0, i32 0
  call void @llvm.masked.scatter.v8i32.v8p0i32(<8 x i32> %predphi1313, <8 x i32*> %449, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>), !tbaa !71
  %vec.ind.next1301 = add <8 x i64> %vec.ind1300, <i64 8, i64 8, i64 8, i64 8, i64 8, i64 8, i64 8, i64 8>
  %450 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, <8 x i64> %vec.ind.next1301
  %451 = extractelement <8 x %"struct.std::pair"*> %450, i32 0
  %452 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %451, i64 0, i32 1
  %453 = bitcast i32* %452 to <16 x i32>*
  %wide.vec1306.1 = load <16 x i32>, <16 x i32>* %453, align 4, !tbaa !69
  %strided.vec1307.1 = shufflevector <16 x i32> %wide.vec1306.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %454 = add <8 x i32> %strided.vec1307.1, %broadcast.splat1309
  %455 = zext <8 x i32> %454 to <8 x i64>
  %456 = icmp sgt <8 x i64> %broadcast.splat1311, %455
  %457 = getelementptr inbounds i32, i32* %231, <8 x i64> %455
  %wide.masked.gather1312.1 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %457, i32 4, <8 x i1> %456, <8 x i32> undef), !tbaa !16
  %predphi1313.1 = select <8 x i1> %456, <8 x i32> %wide.masked.gather1312.1, <8 x i32> zeroinitializer
  %458 = getelementptr inbounds %"struct.std::pair", <8 x %"struct.std::pair"*> %450, i64 0, i32 0
  call void @llvm.masked.scatter.v8i32.v8p0i32(<8 x i32> %predphi1313.1, <8 x i32*> %458, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>), !tbaa !71
  %vec.ind.next1301.1 = add <8 x i64> %vec.ind1300, <i64 16, i64 16, i64 16, i64 16, i64 16, i64 16, i64 16, i64 16>
  %459 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, <8 x i64> %vec.ind.next1301.1
  %460 = extractelement <8 x %"struct.std::pair"*> %459, i32 0
  %461 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %460, i64 0, i32 1
  %462 = bitcast i32* %461 to <16 x i32>*
  %wide.vec1306.2 = load <16 x i32>, <16 x i32>* %462, align 4, !tbaa !69
  %strided.vec1307.2 = shufflevector <16 x i32> %wide.vec1306.2, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %463 = add <8 x i32> %strided.vec1307.2, %broadcast.splat1309
  %464 = zext <8 x i32> %463 to <8 x i64>
  %465 = icmp sgt <8 x i64> %broadcast.splat1311, %464
  %466 = getelementptr inbounds i32, i32* %231, <8 x i64> %464
  %wide.masked.gather1312.2 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %466, i32 4, <8 x i1> %465, <8 x i32> undef), !tbaa !16
  %predphi1313.2 = select <8 x i1> %465, <8 x i32> %wide.masked.gather1312.2, <8 x i32> zeroinitializer
  %467 = getelementptr inbounds %"struct.std::pair", <8 x %"struct.std::pair"*> %459, i64 0, i32 0
  call void @llvm.masked.scatter.v8i32.v8p0i32(<8 x i32> %predphi1313.2, <8 x i32*> %467, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>), !tbaa !71
  %index.next1292.2 = or i64 %index1291, 24
  %468 = icmp eq i64 %index.next1292.2, 248
  br i1 %468, label %pfor.cond284, label %vector.body1289.3, !llvm.loop !72

pfor.cond284:                                     ; preds = %vector.body1289
  %indvars.iv.next1098 = or i64 %440, 249
  %arrayidx292 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %ind.end1294
  %second = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292, i64 0, i32 1
  %469 = load i32, i32* %second, align 4, !tbaa !69
  %add293 = add i32 %469, %offset.0
  %conv294 = zext i32 %add293 to i64
  %cmp295 = icmp slt i64 %conv294, %n
  br i1 %cmp295, label %cond.false, label %cond.end

cond.false:                                       ; preds = %pfor.cond284
  %arrayidx297 = getelementptr inbounds i32, i32* %231, i64 %conv294
  %470 = load i32, i32* %arrayidx297, align 4, !tbaa !16
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %pfor.cond284
  %cond = phi i32 [ %470, %cond.false ], [ 0, %pfor.cond284 ]
  %first = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292, i64 0, i32 0
  store i32 %cond, i32* %first, align 4, !tbaa !71
  %indvars.iv.next1098.1 = add nuw nsw i64 %indvars.iv.next1098, 1
  %arrayidx292.1 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %indvars.iv.next1098
  %second.1 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.1, i64 0, i32 1
  %471 = load i32, i32* %second.1, align 4, !tbaa !69
  %add293.1 = add i32 %471, %offset.0
  %conv294.1 = zext i32 %add293.1 to i64
  %cmp295.1 = icmp slt i64 %conv294.1, %n
  br i1 %cmp295.1, label %cond.false.1, label %cond.end.1

pfor.inc301.strpm.outer:                          ; preds = %cond.end.7, %pfor.cond284.strpm.outer
  %niter1168.nadd = add nuw nsw i64 %niter1168, 1
  %niter1168.ncmp = icmp eq i64 %niter1168.nadd, %stripiter1167.zext
  br i1 %niter1168.ncmp, label %pfor.cond284.strpm.detachloop.sync, label %pfor.cond284.strpm.outer, !llvm.loop !73

pfor.cond284.strpm.detachloop.sync:               ; preds = %pfor.inc301.strpm.outer
  sync within %syncreg271.strpm.detachloop, label %pfor.cond284.strpm.detachloop.reattach.split

pfor.cond284.strpm.detachloop.reattach.split:     ; preds = %pfor.cond284.strpm.detachloop.sync
  reattach within %syncreg271, label %pfor.cond.cleanup304.strpm-lcssa

pfor.cond.cleanup304.strpm-lcssa:                 ; preds = %pfor.cond284.strpm.detachloop.reattach.split, %pfor.cond284.preheader.new, %pfor.cond284.preheader
  %lcmp.mod1170 = icmp eq i64 %xtraiter1164, 0
  br i1 %lcmp.mod1170, label %pfor.cond.cleanup304, label %pfor.cond284.epil.preheader

pfor.cond284.epil.preheader:                      ; preds = %pfor.cond.cleanup304.strpm-lcssa
  %472 = and i64 %wide.trip.count1099, 4294967040
  %min.iters.check1266 = icmp ult i64 %xtraiter1164, 9
  br i1 %min.iters.check1266, label %pfor.cond284.epil.preheader1495, label %vector.ph1267

vector.ph1267:                                    ; preds = %pfor.cond284.epil.preheader
  %n.mod.vf1268 = and i64 %wide.trip.count1099, 7
  %473 = icmp eq i64 %n.mod.vf1268, 0
  %474 = select i1 %473, i64 8, i64 %n.mod.vf1268
  %n.vec1269 = sub nsw i64 %xtraiter1164, %474
  %ind.end1273 = add nsw i64 %472, %n.vec1269
  %.splatinsert = insertelement <8 x i64> undef, i64 %472, i32 0
  %.splat = shufflevector <8 x i64> %.splatinsert, <8 x i64> undef, <8 x i32> zeroinitializer
  %induction1277 = add <8 x i64> %.splat, <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7>
  br label %vector.body1265

vector.body1265:                                  ; preds = %vector.body1265, %vector.ph1267
  %index1270 = phi i64 [ 0, %vector.ph1267 ], [ %index.next1271, %vector.body1265 ]
  %vec.ind = phi <8 x i64> [ %induction1277, %vector.ph1267 ], [ %vec.ind.next, %vector.body1265 ]
  %475 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, <8 x i64> %vec.ind
  %476 = extractelement <8 x %"struct.std::pair"*> %475, i32 0
  %477 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %476, i64 0, i32 1
  %478 = bitcast i32* %477 to <16 x i32>*
  %wide.vec = load <16 x i32>, <16 x i32>* %478, align 4, !tbaa !69
  %strided.vec = shufflevector <16 x i32> %wide.vec, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %479 = add <8 x i32> %strided.vec, %broadcast.splat1283
  %480 = zext <8 x i32> %479 to <8 x i64>
  %481 = icmp sgt <8 x i64> %broadcast.splat1285, %480
  %482 = getelementptr inbounds i32, i32* %231, <8 x i64> %480
  %wide.masked.gather1286 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %482, i32 4, <8 x i1> %481, <8 x i32> undef), !tbaa !16
  %predphi = select <8 x i1> %481, <8 x i32> %wide.masked.gather1286, <8 x i32> zeroinitializer
  %483 = getelementptr inbounds %"struct.std::pair", <8 x %"struct.std::pair"*> %475, i64 0, i32 0
  call void @llvm.masked.scatter.v8i32.v8p0i32(<8 x i32> %predphi, <8 x i32*> %483, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>), !tbaa !71
  %index.next1271 = add i64 %index1270, 8
  %vec.ind.next = add <8 x i64> %vec.ind, <i64 8, i64 8, i64 8, i64 8, i64 8, i64 8, i64 8, i64 8>
  %484 = icmp eq i64 %index.next1271, %n.vec1269
  br i1 %484, label %pfor.cond284.epil.preheader1495.loopexit, label %vector.body1265, !llvm.loop !74

pfor.cond284.epil.preheader1495.loopexit:         ; preds = %vector.body1265
  br label %pfor.cond284.epil.preheader1495

pfor.cond284.epil.preheader1495:                  ; preds = %pfor.cond284.epil.preheader1495.loopexit, %pfor.cond284.epil.preheader
  %indvars.iv1097.epil.ph = phi i64 [ %472, %pfor.cond284.epil.preheader ], [ %ind.end1273, %pfor.cond284.epil.preheader1495.loopexit ]
  %epil.iter1165.ph = phi i64 [ %xtraiter1164, %pfor.cond284.epil.preheader ], [ %474, %pfor.cond284.epil.preheader1495.loopexit ]
  br label %pfor.cond284.epil

pfor.cond284.epil:                                ; preds = %cond.end.epil, %pfor.cond284.epil.preheader1495
  %indvars.iv1097.epil = phi i64 [ %indvars.iv.next1098.epil, %cond.end.epil ], [ %indvars.iv1097.epil.ph, %pfor.cond284.epil.preheader1495 ]
  %epil.iter1165 = phi i64 [ %epil.iter1165.sub, %cond.end.epil ], [ %epil.iter1165.ph, %pfor.cond284.epil.preheader1495 ]
  %indvars.iv.next1098.epil = add nuw nsw i64 %indvars.iv1097.epil, 1
  %arrayidx292.epil = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %indvars.iv1097.epil
  %second.epil = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.epil, i64 0, i32 1
  %485 = load i32, i32* %second.epil, align 4, !tbaa !69
  %add293.epil = add i32 %485, %offset.0
  %conv294.epil = zext i32 %add293.epil to i64
  %cmp295.epil = icmp slt i64 %conv294.epil, %n
  br i1 %cmp295.epil, label %cond.false.epil, label %cond.end.epil

cond.false.epil:                                  ; preds = %pfor.cond284.epil
  %arrayidx297.epil = getelementptr inbounds i32, i32* %231, i64 %conv294.epil
  %486 = load i32, i32* %arrayidx297.epil, align 4, !tbaa !16
  br label %cond.end.epil

cond.end.epil:                                    ; preds = %cond.false.epil, %pfor.cond284.epil
  %cond.epil = phi i32 [ %486, %cond.false.epil ], [ 0, %pfor.cond284.epil ]
  %first.epil = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.epil, i64 0, i32 0
  store i32 %cond.epil, i32* %first.epil, align 4, !tbaa !71
  %epil.iter1165.sub = add nsw i64 %epil.iter1165, -1
  %epil.iter1165.cmp = icmp eq i64 %epil.iter1165.sub, 0
  br i1 %epil.iter1165.cmp, label %pfor.cond.cleanup304.loopexit, label %pfor.cond284.epil, !llvm.loop !75

pfor.cond.cleanup304.loopexit:                    ; preds = %cond.end.epil
  br label %pfor.cond.cleanup304

pfor.cond.cleanup304:                             ; preds = %pfor.cond.cleanup304.loopexit, %pfor.cond.cleanup304.strpm-lcssa
  sync within %syncreg271, label %sync.continue306

sync.continue306:                                 ; preds = %pfor.cond.cleanup304
  call void @llvm.sync.unwind(token %syncreg271)
  br label %cleanup309

cleanup309:                                       ; preds = %sync.continue306, %pfor.body264
  %conv312.pre-phi = phi i64 [ %wide.trip.count1099, %sync.continue306 ], [ 0, %pfor.body264 ]
  %cmp314 = icmp sgt i64 %div313, %conv312.pre-phi
  br i1 %cmp314, label %if.else, label %if.then315

if.then315:                                       ; preds = %cleanup309
  call void @_Z10sampleSortISt4pairIjjE9pairCompFjEvPT_T1_T0_(%"struct.std::pair"* %add.ptr, i32 %437)
  br label %if.end318

if.else:                                          ; preds = %cleanup309
  call void @_Z9quickSortISt4pairIjjE9pairCompFjEvPT_T1_T0_(%"struct.std::pair"* %add.ptr, i32 %437)
  br label %if.end318

if.end318:                                        ; preds = %if.else, %if.then315
  reattach within %syncreg.i, label %pfor.inc320

pfor.inc320:                                      ; preds = %if.end318, %pfor.cond258
  %exitcond1104 = icmp eq i64 %indvars.iv.next1102, %wide.trip.count1103
  br i1 %exitcond1104, label %pfor.cond.cleanup323, label %pfor.cond258, !llvm.loop !76

pfor.cond.cleanup323:                             ; preds = %pfor.inc320
  sync within %syncreg.i, label %sync.continue325

sync.continue325:                                 ; preds = %pfor.cond.cleanup323
  call void @llvm.sync.unwind(token %syncreg.i)
  store %union.anon* %253, %union.anon** %254, align 8, !tbaa !47
  store i32 1953656691, i32* %256, align 8
  store i64 4, i64* %_M_string_length.i.i.i.i.i.i915, align 8, !tbaa !49
  store i8 0, i8* %arrayidx.i.i.i.i.i916, align 4, !tbaa !15
  %call2.i.i937 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull %255, i64 4)
          to label %call2.i.i.noexc936 unwind label %lpad335

call2.i.i.noexc936:                               ; preds = %sync.continue325
  %call1.i.i939 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call2.i.i937, i8* nonnull getelementptr inbounds ([4 x i8], [4 x i8]* @.str.17, i64 0, i64 0), i64 3)
          to label %call1.i.i.noexc938 unwind label %lpad335

call1.i.i.noexc938:                               ; preds = %call2.i.i.noexc936
  %487 = load i8, i8* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 3), align 8, !tbaa !2, !range !51
  %tobool.i.i.i923 = icmp eq i8 %487, 0
  br i1 %tobool.i.i.i923, label %_ZN5timer10reportNextEv.exit.i935, label %if.end.i.i.i933

if.end.i.i.i933:                                  ; preds = %call1.i.i.noexc938
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %257) #16
  %call.i.i.i.i924 = call i32 @gettimeofday(%struct.timeval* nonnull %now.i.i.i.i920, i8* nonnull bitcast (%struct.timezone* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 5) to i8*)) #16
  %488 = load i64, i64* %tv_sec.i.i.i.i925, align 8, !tbaa !10
  %conv.i.i.i.i926 = sitofp i64 %488 to double
  %489 = load i64, i64* %tv_usec.i.i.i.i927, align 8, !tbaa !13
  %conv2.i.i.i.i928 = sitofp i64 %489 to double
  %div.i.i.i.i929 = fdiv double %conv2.i.i.i.i928, 1.000000e+06
  %add.i.i.i.i930 = fadd double %div.i.i.i.i929, %conv.i.i.i.i926
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %257) #16
  %490 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  %sub.i.i.i931 = fsub double %add.i.i.i.i930, %490
  %491 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  %add.i.i.i932 = fadd double %491, %sub.i.i.i931
  store double %add.i.i.i932, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  store double %add.i.i.i.i930, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  br label %_ZN5timer10reportNextEv.exit.i935

_ZN5timer10reportNextEv.exit.i935:                ; preds = %if.end.i.i.i933, %call1.i.i.noexc938
  %retval.0.i.i.i934 = phi double [ %sub.i.i.i931, %if.end.i.i.i933 ], [ 0.000000e+00, %call1.i.i.noexc938 ]
  invoke void @_ZN5timer7reportTEd(%struct.timer* nonnull @_ZL3_tm, double %retval.0.i.i.i934)
          to label %invoke.cont336 unwind label %lpad335

invoke.cont336:                                   ; preds = %_ZN5timer10reportNextEv.exit.i935
  %492 = load i8*, i8** %_M_p.i.i.i.i.i911, align 8, !tbaa !53
  %cmp.i.i.i943 = icmp eq i8* %492, %255
  br i1 %cmp.i.i.i943, label %pfor.cond352.preheader, label %if.then.i.i944

if.then.i.i944:                                   ; preds = %invoke.cont336
  call void @_ZdlPv(i8* %492) #16
  br label %pfor.cond352.preheader

pfor.cond352.preheader:                           ; preds = %if.then.i.i944, %invoke.cont336
  br label %pfor.cond352

lpad335:                                          ; preds = %_ZN5timer10reportNextEv.exit.i935, %call2.i.i.noexc936, %sync.continue325
  %493 = landingpad { i8*, i32 }
          cleanup
  %494 = extractvalue { i8*, i32 } %493, 0
  %495 = extractvalue { i8*, i32 } %493, 1
  %496 = load i8*, i8** %_M_p.i.i.i.i.i911, align 8, !tbaa !53
  %cmp.i.i.i948 = icmp eq i8* %496, %255
  br i1 %cmp.i.i.i948, label %ehcleanup450, label %if.then.i.i949

if.then.i.i949:                                   ; preds = %lpad335
  call void @_ZdlPv(i8* %496) #16
  br label %ehcleanup450

pfor.cond352:                                     ; preds = %pfor.inc373, %pfor.cond352.preheader
  %indvars.iv1105 = phi i64 [ %indvars.iv.next1106, %pfor.inc373 ], [ 0, %pfor.cond352.preheader ]
  %indvars.iv.next1106 = add nuw nsw i64 %indvars.iv1105, 1
  detach within %syncreg.i, label %pfor.body358, label %pfor.inc373

pfor.body358:                                     ; preds = %pfor.cond352
  %start362 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv1105, i32 0
  %497 = load i32, i32* %start362, align 4, !tbaa !68
  %arrayidx364 = getelementptr inbounds i32, i32* %243, i64 %indvars.iv1105
  %498 = load i32, i32* %arrayidx364, align 4, !tbaa !16
  %idx.ext365 = zext i32 %498 to i64
  %add.ptr366 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %idx.ext365
  %length369 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %indvars.iv1105, i32 1
  %499 = load i32, i32* %length369, align 4, !tbaa !62
  %idx.ext370 = zext i32 %497 to i64
  %add.ptr371 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %idx.ext370
  call void @_Z12splitSegmentISt4pairIjjEEvP3segjjPjPT_(%struct.seg* %add.ptr366, i32 %497, i32 %499, i32* %231, %"struct.std::pair"* %add.ptr371)
  reattach within %syncreg.i, label %pfor.inc373

pfor.inc373:                                      ; preds = %pfor.body358, %pfor.cond352
  %exitcond1109 = icmp eq i64 %indvars.iv.next1106, %wide.trip.count1103
  br i1 %exitcond1109, label %pfor.cond.cleanup376, label %pfor.cond352, !llvm.loop !77

pfor.cond.cleanup376:                             ; preds = %pfor.inc373
  sync within %syncreg.i, label %sync.continue378

sync.continue378:                                 ; preds = %pfor.cond.cleanup376
  call void @llvm.sync.unwind(token %syncreg.i)
  store %union.anon* %258, %union.anon** %259, align 8, !tbaa !47
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(5) %260, i8* nonnull align 1 dereferenceable(5) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.11, i64 0, i64 0), i64 5, i1 false) #16
  store i64 5, i64* %_M_string_length.i.i.i.i.i.i961, align 8, !tbaa !49
  store i8 0, i8* %arrayidx.i.i.i.i.i962, align 1, !tbaa !15
  %call2.i.i983 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull %260, i64 5)
          to label %call2.i.i.noexc982 unwind label %lpad388

call2.i.i.noexc982:                               ; preds = %sync.continue378
  %call1.i.i985 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call2.i.i983, i8* nonnull getelementptr inbounds ([4 x i8], [4 x i8]* @.str.17, i64 0, i64 0), i64 3)
          to label %call1.i.i.noexc984 unwind label %lpad388

call1.i.i.noexc984:                               ; preds = %call2.i.i.noexc982
  %500 = load i8, i8* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 3), align 8, !tbaa !2, !range !51
  %tobool.i.i.i969 = icmp eq i8 %500, 0
  br i1 %tobool.i.i.i969, label %_ZN5timer10reportNextEv.exit.i981, label %if.end.i.i.i979

if.end.i.i.i979:                                  ; preds = %call1.i.i.noexc984
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %261) #16
  %call.i.i.i.i970 = call i32 @gettimeofday(%struct.timeval* nonnull %now.i.i.i.i966, i8* nonnull bitcast (%struct.timezone* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 5) to i8*)) #16
  %501 = load i64, i64* %tv_sec.i.i.i.i971, align 8, !tbaa !10
  %conv.i.i.i.i972 = sitofp i64 %501 to double
  %502 = load i64, i64* %tv_usec.i.i.i.i973, align 8, !tbaa !13
  %conv2.i.i.i.i974 = sitofp i64 %502 to double
  %div.i.i.i.i975 = fdiv double %conv2.i.i.i.i974, 1.000000e+06
  %add.i.i.i.i976 = fadd double %div.i.i.i.i975, %conv.i.i.i.i972
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %261) #16
  %503 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  %sub.i.i.i977 = fsub double %add.i.i.i.i976, %503
  %504 = load double, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  %add.i.i.i978 = fadd double %504, %sub.i.i.i977
  store double %add.i.i.i978, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 0), align 8, !tbaa !52
  store double %add.i.i.i.i976, double* getelementptr inbounds (%struct.timer, %struct.timer* @_ZL3_tm, i64 0, i32 1), align 8, !tbaa !14
  br label %_ZN5timer10reportNextEv.exit.i981

_ZN5timer10reportNextEv.exit.i981:                ; preds = %if.end.i.i.i979, %call1.i.i.noexc984
  %retval.0.i.i.i980 = phi double [ %sub.i.i.i977, %if.end.i.i.i979 ], [ 0.000000e+00, %call1.i.i.noexc984 ]
  invoke void @_ZN5timer7reportTEd(%struct.timer* nonnull @_ZL3_tm, double %retval.0.i.i.i980)
          to label %invoke.cont389 unwind label %lpad388

invoke.cont389:                                   ; preds = %_ZN5timer10reportNextEv.exit.i981
  %505 = load i8*, i8** %_M_p.i.i.i.i.i957, align 8, !tbaa !53
  %cmp.i.i.i989 = icmp eq i8* %505, %260
  br i1 %cmp.i.i.i989, label %cleanup394, label %if.then.i.i990

if.then.i.i990:                                   ; preds = %invoke.cont389
  call void @_ZdlPv(i8* %505) #16
  br label %cleanup394

cleanup394:                                       ; preds = %if.then.i.i990, %invoke.cont389
  %mul393 = shl i32 %offset.0, 1
  br label %while.cond

lpad388:                                          ; preds = %_ZN5timer10reportNextEv.exit.i981, %call2.i.i.noexc982, %sync.continue378
  %506 = landingpad { i8*, i32 }
          cleanup
  %507 = extractvalue { i8*, i32 } %506, 0
  %508 = extractvalue { i8*, i32 } %506, 1
  %509 = load i8*, i8** %_M_p.i.i.i.i.i957, align 8, !tbaa !53
  %cmp.i.i.i = icmp eq i8* %509, %260
  br i1 %cmp.i.i.i, label %ehcleanup450, label %if.then.i.i

if.then.i.i:                                      ; preds = %lpad388
  call void @_ZdlPv(i8* %509) #16
  br label %ehcleanup450

while.end:                                        ; preds = %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend, %if.then.i807
  br i1 %cmp1, label %pfor.cond409.preheader, label %cleanup430

pfor.cond409.preheader:                           ; preds = %while.end
  %510 = add nsw i64 %conv671072, -1
  %xtraiter = and i64 %n, 2047
  %511 = icmp ult i64 %510, 2047
  br i1 %511, label %pfor.cond.cleanup425.strpm-lcssa, label %pfor.cond409.preheader.new

pfor.cond409.preheader.new:                       ; preds = %pfor.cond409.preheader
  %stripiter = lshr i64 %conv671072, 11
  br label %pfor.cond409.strpm.outer

pfor.cond409.strpm.outer:                         ; preds = %pfor.inc422.strpm.outer, %pfor.cond409.preheader.new
  %niter = phi i64 [ 0, %pfor.cond409.preheader.new ], [ %niter.nadd, %pfor.inc422.strpm.outer ]
  detach within %syncreg.i, label %pfor.body415.strpm.outer, label %pfor.inc422.strpm.outer

pfor.body415.strpm.outer:                         ; preds = %pfor.cond409.strpm.outer
  %512 = shl i64 %niter, 11
  br label %vector.ph1427

vector.ph1427:                                    ; preds = %pfor.body415.strpm.outer
  %ind.end1431 = or i64 %512, 2016
  br label %vector.body1426

vector.body1426:                                  ; preds = %vector.body1426.1, %vector.ph1427
  %index1428 = phi i64 [ 0, %vector.ph1427 ], [ %index.next1429.1, %vector.body1426.1 ]
  %offset.idx1434 = add nuw nsw i64 %512, %index1428
  %513 = or i64 %offset.idx1434, 8
  %514 = or i64 %offset.idx1434, 16
  %515 = or i64 %offset.idx1434, 24
  %516 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %offset.idx1434, i32 1
  %517 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %513, i32 1
  %518 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %514, i32 1
  %519 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %515, i32 1
  %520 = bitcast i32* %516 to <16 x i32>*
  %521 = bitcast i32* %517 to <16 x i32>*
  %522 = bitcast i32* %518 to <16 x i32>*
  %523 = bitcast i32* %519 to <16 x i32>*
  %wide.vec1448 = load <16 x i32>, <16 x i32>* %520, align 4, !tbaa !69
  %wide.vec1449 = load <16 x i32>, <16 x i32>* %521, align 4, !tbaa !69
  %wide.vec1450 = load <16 x i32>, <16 x i32>* %522, align 4, !tbaa !69
  %wide.vec1451 = load <16 x i32>, <16 x i32>* %523, align 4, !tbaa !69
  %strided.vec1452 = shufflevector <16 x i32> %wide.vec1448, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1453 = shufflevector <16 x i32> %wide.vec1449, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1454 = shufflevector <16 x i32> %wide.vec1450, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1455 = shufflevector <16 x i32> %wide.vec1451, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %524 = getelementptr inbounds i32, i32* %231, i64 %offset.idx1434
  %525 = bitcast i32* %524 to <8 x i32>*
  store <8 x i32> %strided.vec1452, <8 x i32>* %525, align 4, !tbaa !16
  %526 = getelementptr inbounds i32, i32* %524, i64 8
  %527 = bitcast i32* %526 to <8 x i32>*
  store <8 x i32> %strided.vec1453, <8 x i32>* %527, align 4, !tbaa !16
  %528 = getelementptr inbounds i32, i32* %524, i64 16
  %529 = bitcast i32* %528 to <8 x i32>*
  store <8 x i32> %strided.vec1454, <8 x i32>* %529, align 4, !tbaa !16
  %530 = getelementptr inbounds i32, i32* %524, i64 24
  %531 = bitcast i32* %530 to <8 x i32>*
  store <8 x i32> %strided.vec1455, <8 x i32>* %531, align 4, !tbaa !16
  %index.next1429 = or i64 %index1428, 32
  %532 = icmp eq i64 %index.next1429, 2016
  br i1 %532, label %pfor.cond409, label %vector.body1426.1, !llvm.loop !78

pfor.cond409:                                     ; preds = %vector.body1426
  %indvars.iv.next = or i64 %512, 2017
  %second418 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %ind.end1431, i32 1
  %533 = load i32, i32* %second418, align 4, !tbaa !69
  %arrayidx420 = getelementptr inbounds i32, i32* %231, i64 %ind.end1431
  store i32 %533, i32* %arrayidx420, align 4, !tbaa !16
  %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv.next, 1
  %second418.1 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next, i32 1
  %534 = load i32, i32* %second418.1, align 4, !tbaa !69
  %arrayidx420.1 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next
  store i32 %534, i32* %arrayidx420.1, align 4, !tbaa !16
  %indvars.iv.next.2 = or i64 %512, 2019
  %second418.2 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.1, i32 1
  %535 = load i32, i32* %second418.2, align 4, !tbaa !69
  %arrayidx420.2 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.1
  store i32 %535, i32* %arrayidx420.2, align 4, !tbaa !16
  %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv.next.2, 1
  %second418.3 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.2, i32 1
  %536 = load i32, i32* %second418.3, align 4, !tbaa !69
  %arrayidx420.3 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.2
  store i32 %536, i32* %arrayidx420.3, align 4, !tbaa !16
  %indvars.iv.next.4 = add nuw nsw i64 %indvars.iv.next.2, 2
  %second418.4 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.3, i32 1
  %537 = load i32, i32* %second418.4, align 4, !tbaa !69
  %arrayidx420.4 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.3
  store i32 %537, i32* %arrayidx420.4, align 4, !tbaa !16
  %indvars.iv.next.5 = add nuw nsw i64 %indvars.iv.next.2, 3
  %second418.5 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.4, i32 1
  %538 = load i32, i32* %second418.5, align 4, !tbaa !69
  %arrayidx420.5 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.4
  store i32 %538, i32* %arrayidx420.5, align 4, !tbaa !16
  %indvars.iv.next.6 = or i64 %512, 2023
  %second418.6 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.5, i32 1
  %539 = load i32, i32* %second418.6, align 4, !tbaa !69
  %arrayidx420.6 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.5
  store i32 %539, i32* %arrayidx420.6, align 4, !tbaa !16
  %indvars.iv.next.7 = add nuw nsw i64 %indvars.iv.next.6, 1
  %second418.7 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.6, i32 1
  %540 = load i32, i32* %second418.7, align 4, !tbaa !69
  %arrayidx420.7 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.6
  store i32 %540, i32* %arrayidx420.7, align 4, !tbaa !16
  %indvars.iv.next.8 = add nuw nsw i64 %indvars.iv.next.6, 2
  %second418.8 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.7, i32 1
  %541 = load i32, i32* %second418.8, align 4, !tbaa !69
  %arrayidx420.8 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.7
  store i32 %541, i32* %arrayidx420.8, align 4, !tbaa !16
  %indvars.iv.next.9 = add nuw nsw i64 %indvars.iv.next.6, 3
  %second418.9 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.8, i32 1
  %542 = load i32, i32* %second418.9, align 4, !tbaa !69
  %arrayidx420.9 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.8
  store i32 %542, i32* %arrayidx420.9, align 4, !tbaa !16
  %indvars.iv.next.10 = add nuw nsw i64 %indvars.iv.next.6, 4
  %second418.10 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.9, i32 1
  %543 = load i32, i32* %second418.10, align 4, !tbaa !69
  %arrayidx420.10 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.9
  store i32 %543, i32* %arrayidx420.10, align 4, !tbaa !16
  %indvars.iv.next.11 = add nuw nsw i64 %indvars.iv.next.6, 5
  %second418.11 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.10, i32 1
  %544 = load i32, i32* %second418.11, align 4, !tbaa !69
  %arrayidx420.11 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.10
  store i32 %544, i32* %arrayidx420.11, align 4, !tbaa !16
  %indvars.iv.next.12 = add nuw nsw i64 %indvars.iv.next.6, 6
  %second418.12 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.11, i32 1
  %545 = load i32, i32* %second418.12, align 4, !tbaa !69
  %arrayidx420.12 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.11
  store i32 %545, i32* %arrayidx420.12, align 4, !tbaa !16
  %indvars.iv.next.13 = add nuw nsw i64 %indvars.iv.next.6, 7
  %second418.13 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.12, i32 1
  %546 = load i32, i32* %second418.13, align 4, !tbaa !69
  %arrayidx420.13 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.12
  store i32 %546, i32* %arrayidx420.13, align 4, !tbaa !16
  %indvars.iv.next.14 = or i64 %512, 2031
  %second418.14 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.13, i32 1
  %547 = load i32, i32* %second418.14, align 4, !tbaa !69
  %arrayidx420.14 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.13
  store i32 %547, i32* %arrayidx420.14, align 4, !tbaa !16
  %indvars.iv.next.15 = add nuw nsw i64 %indvars.iv.next.14, 1
  %second418.15 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.14, i32 1
  %548 = load i32, i32* %second418.15, align 4, !tbaa !69
  %arrayidx420.15 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.14
  store i32 %548, i32* %arrayidx420.15, align 4, !tbaa !16
  %indvars.iv.next.16 = add nuw nsw i64 %indvars.iv.next.14, 2
  %second418.16 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.15, i32 1
  %549 = load i32, i32* %second418.16, align 4, !tbaa !69
  %arrayidx420.16 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.15
  store i32 %549, i32* %arrayidx420.16, align 4, !tbaa !16
  %indvars.iv.next.17 = add nuw nsw i64 %indvars.iv.next.14, 3
  %second418.17 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.16, i32 1
  %550 = load i32, i32* %second418.17, align 4, !tbaa !69
  %arrayidx420.17 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.16
  store i32 %550, i32* %arrayidx420.17, align 4, !tbaa !16
  %indvars.iv.next.18 = add nuw nsw i64 %indvars.iv.next.14, 4
  %second418.18 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.17, i32 1
  %551 = load i32, i32* %second418.18, align 4, !tbaa !69
  %arrayidx420.18 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.17
  store i32 %551, i32* %arrayidx420.18, align 4, !tbaa !16
  %indvars.iv.next.19 = add nuw nsw i64 %indvars.iv.next.14, 5
  %second418.19 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.18, i32 1
  %552 = load i32, i32* %second418.19, align 4, !tbaa !69
  %arrayidx420.19 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.18
  store i32 %552, i32* %arrayidx420.19, align 4, !tbaa !16
  %indvars.iv.next.20 = add nuw nsw i64 %indvars.iv.next.14, 6
  %second418.20 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.19, i32 1
  %553 = load i32, i32* %second418.20, align 4, !tbaa !69
  %arrayidx420.20 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.19
  store i32 %553, i32* %arrayidx420.20, align 4, !tbaa !16
  %indvars.iv.next.21 = add nuw nsw i64 %indvars.iv.next.14, 7
  %second418.21 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.20, i32 1
  %554 = load i32, i32* %second418.21, align 4, !tbaa !69
  %arrayidx420.21 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.20
  store i32 %554, i32* %arrayidx420.21, align 4, !tbaa !16
  %indvars.iv.next.22 = add nuw nsw i64 %indvars.iv.next.14, 8
  %second418.22 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.21, i32 1
  %555 = load i32, i32* %second418.22, align 4, !tbaa !69
  %arrayidx420.22 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.21
  store i32 %555, i32* %arrayidx420.22, align 4, !tbaa !16
  %indvars.iv.next.23 = add nuw nsw i64 %indvars.iv.next.14, 9
  %second418.23 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.22, i32 1
  %556 = load i32, i32* %second418.23, align 4, !tbaa !69
  %arrayidx420.23 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.22
  store i32 %556, i32* %arrayidx420.23, align 4, !tbaa !16
  %indvars.iv.next.24 = add nuw nsw i64 %indvars.iv.next.14, 10
  %second418.24 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.23, i32 1
  %557 = load i32, i32* %second418.24, align 4, !tbaa !69
  %arrayidx420.24 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.23
  store i32 %557, i32* %arrayidx420.24, align 4, !tbaa !16
  %indvars.iv.next.25 = add nuw nsw i64 %indvars.iv.next.14, 11
  %second418.25 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.24, i32 1
  %558 = load i32, i32* %second418.25, align 4, !tbaa !69
  %arrayidx420.25 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.24
  store i32 %558, i32* %arrayidx420.25, align 4, !tbaa !16
  %indvars.iv.next.26 = add nuw nsw i64 %indvars.iv.next.14, 12
  %second418.26 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.25, i32 1
  %559 = load i32, i32* %second418.26, align 4, !tbaa !69
  %arrayidx420.26 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.25
  store i32 %559, i32* %arrayidx420.26, align 4, !tbaa !16
  %indvars.iv.next.27 = add nuw nsw i64 %indvars.iv.next.14, 13
  %second418.27 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.26, i32 1
  %560 = load i32, i32* %second418.27, align 4, !tbaa !69
  %arrayidx420.27 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.26
  store i32 %560, i32* %arrayidx420.27, align 4, !tbaa !16
  %indvars.iv.next.28 = add nuw nsw i64 %indvars.iv.next.14, 14
  %second418.28 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.27, i32 1
  %561 = load i32, i32* %second418.28, align 4, !tbaa !69
  %arrayidx420.28 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.27
  store i32 %561, i32* %arrayidx420.28, align 4, !tbaa !16
  %indvars.iv.next.29 = add nuw nsw i64 %indvars.iv.next.14, 15
  %second418.29 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.28, i32 1
  %562 = load i32, i32* %second418.29, align 4, !tbaa !69
  %arrayidx420.29 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.28
  store i32 %562, i32* %arrayidx420.29, align 4, !tbaa !16
  %indvars.iv.next.30 = or i64 %512, 2047
  %second418.30 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.29, i32 1
  %563 = load i32, i32* %second418.30, align 4, !tbaa !69
  %arrayidx420.30 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.29
  store i32 %563, i32* %arrayidx420.30, align 4, !tbaa !16
  %second418.31 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.next.30, i32 1
  %564 = load i32, i32* %second418.31, align 4, !tbaa !69
  %arrayidx420.31 = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.next.30
  store i32 %564, i32* %arrayidx420.31, align 4, !tbaa !16
  reattach within %syncreg.i, label %pfor.inc422.strpm.outer

pfor.inc422.strpm.outer:                          ; preds = %pfor.cond409, %pfor.cond409.strpm.outer
  %niter.nadd = add nuw nsw i64 %niter, 1
  %niter.ncmp = icmp eq i64 %niter.nadd, %stripiter
  br i1 %niter.ncmp, label %pfor.cond.cleanup425.strpm-lcssa.loopexit, label %pfor.cond409.strpm.outer, !llvm.loop !79

pfor.cond.cleanup425.strpm-lcssa.loopexit:        ; preds = %pfor.inc422.strpm.outer
  br label %pfor.cond.cleanup425.strpm-lcssa

pfor.cond.cleanup425.strpm-lcssa:                 ; preds = %pfor.cond.cleanup425.strpm-lcssa.loopexit, %pfor.cond409.preheader
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %pfor.cond.cleanup425, label %pfor.cond409.epil.preheader

pfor.cond409.epil.preheader:                      ; preds = %pfor.cond.cleanup425.strpm-lcssa
  %565 = and i64 %n, 4294965248
  %min.iters.check1459 = icmp ult i64 %xtraiter, 33
  br i1 %min.iters.check1459, label %pfor.cond409.epil.preheader1492, label %vector.ph1460

vector.ph1460:                                    ; preds = %pfor.cond409.epil.preheader
  %n.mod.vf1461 = and i64 %n, 31
  %566 = icmp eq i64 %n.mod.vf1461, 0
  %567 = select i1 %566, i64 32, i64 %n.mod.vf1461
  %n.vec1462 = sub nsw i64 %xtraiter, %567
  %ind.end1466 = add nsw i64 %565, %n.vec1462
  br label %vector.body1458

vector.body1458:                                  ; preds = %vector.body1458, %vector.ph1460
  %index1463 = phi i64 [ 0, %vector.ph1460 ], [ %index.next1464, %vector.body1458 ]
  %offset.idx1470 = add i64 %565, %index1463
  %568 = or i64 %offset.idx1470, 8
  %569 = or i64 %offset.idx1470, 16
  %570 = or i64 %offset.idx1470, 24
  %571 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %offset.idx1470, i32 1
  %572 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %568, i32 1
  %573 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %569, i32 1
  %574 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %570, i32 1
  %575 = bitcast i32* %571 to <16 x i32>*
  %576 = bitcast i32* %572 to <16 x i32>*
  %577 = bitcast i32* %573 to <16 x i32>*
  %578 = bitcast i32* %574 to <16 x i32>*
  %wide.vec1484 = load <16 x i32>, <16 x i32>* %575, align 4, !tbaa !69
  %wide.vec1485 = load <16 x i32>, <16 x i32>* %576, align 4, !tbaa !69
  %wide.vec1486 = load <16 x i32>, <16 x i32>* %577, align 4, !tbaa !69
  %wide.vec1487 = load <16 x i32>, <16 x i32>* %578, align 4, !tbaa !69
  %strided.vec1488 = shufflevector <16 x i32> %wide.vec1484, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1489 = shufflevector <16 x i32> %wide.vec1485, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1490 = shufflevector <16 x i32> %wide.vec1486, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1491 = shufflevector <16 x i32> %wide.vec1487, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %579 = getelementptr inbounds i32, i32* %231, i64 %offset.idx1470
  %580 = bitcast i32* %579 to <8 x i32>*
  store <8 x i32> %strided.vec1488, <8 x i32>* %580, align 4, !tbaa !16
  %581 = getelementptr inbounds i32, i32* %579, i64 8
  %582 = bitcast i32* %581 to <8 x i32>*
  store <8 x i32> %strided.vec1489, <8 x i32>* %582, align 4, !tbaa !16
  %583 = getelementptr inbounds i32, i32* %579, i64 16
  %584 = bitcast i32* %583 to <8 x i32>*
  store <8 x i32> %strided.vec1490, <8 x i32>* %584, align 4, !tbaa !16
  %585 = getelementptr inbounds i32, i32* %579, i64 24
  %586 = bitcast i32* %585 to <8 x i32>*
  store <8 x i32> %strided.vec1491, <8 x i32>* %586, align 4, !tbaa !16
  %index.next1464 = add i64 %index1463, 32
  %587 = icmp eq i64 %index.next1464, %n.vec1462
  br i1 %587, label %pfor.cond409.epil.preheader1492.loopexit, label %vector.body1458, !llvm.loop !80

pfor.cond409.epil.preheader1492.loopexit:         ; preds = %vector.body1458
  br label %pfor.cond409.epil.preheader1492

pfor.cond409.epil.preheader1492:                  ; preds = %pfor.cond409.epil.preheader1492.loopexit, %pfor.cond409.epil.preheader
  %indvars.iv.epil.ph = phi i64 [ %565, %pfor.cond409.epil.preheader ], [ %ind.end1466, %pfor.cond409.epil.preheader1492.loopexit ]
  %epil.iter.ph = phi i64 [ %xtraiter, %pfor.cond409.epil.preheader ], [ %567, %pfor.cond409.epil.preheader1492.loopexit ]
  br label %pfor.cond409.epil

pfor.cond409.epil:                                ; preds = %pfor.cond409.epil, %pfor.cond409.epil.preheader1492
  %indvars.iv.epil = phi i64 [ %indvars.iv.next.epil, %pfor.cond409.epil ], [ %indvars.iv.epil.ph, %pfor.cond409.epil.preheader1492 ]
  %epil.iter = phi i64 [ %epil.iter.sub, %pfor.cond409.epil ], [ %epil.iter.ph, %pfor.cond409.epil.preheader1492 ]
  %indvars.iv.next.epil = add nuw nsw i64 %indvars.iv.epil, 1
  %second418.epil = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %indvars.iv.epil, i32 1
  %588 = load i32, i32* %second418.epil, align 4, !tbaa !69
  %arrayidx420.epil = getelementptr inbounds i32, i32* %231, i64 %indvars.iv.epil
  store i32 %588, i32* %arrayidx420.epil, align 4, !tbaa !16
  %epil.iter.sub = add nsw i64 %epil.iter, -1
  %epil.iter.cmp = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp, label %pfor.cond.cleanup425.loopexit, label %pfor.cond409.epil, !llvm.loop !81

pfor.cond.cleanup425.loopexit:                    ; preds = %pfor.cond409.epil
  br label %pfor.cond.cleanup425

pfor.cond.cleanup425:                             ; preds = %pfor.cond.cleanup425.loopexit, %pfor.cond.cleanup425.strpm-lcssa
  sync within %syncreg.i, label %sync.continue427

sync.continue427:                                 ; preds = %pfor.cond.cleanup425
  call void @llvm.sync.unwind(token %syncreg.i)
  br label %cleanup430

cleanup430:                                       ; preds = %sync.continue427, %while.end
  %589 = bitcast %"struct.std::pair"* %call161 to i8*
  call void @free(i8* %589) #16
  call void @free(i8* %call159) #16
  call void @free(i8* %call174) #16
  call void @free(i8* %call172) #16
  call void @llvm.lifetime.end.p0i8(i64 1024, i8* nonnull %0) #16
  ret i32* %231

ehcleanup450:                                     ; preds = %if.then.i.i, %lpad388, %if.then.i.i949, %lpad335, %if.then.i.i903, %lpad241, %if.then.i.i833, %lpad183, %lpad181, %if.then.i.i827, %lpad166, %if.then.i.i822, %lpad151, %if.then.i.i817, %lpad143
  %ehselector.slot.10 = phi i32 [ %322, %lpad143 ], [ %322, %if.then.i.i817 ], [ %326, %lpad151 ], [ %326, %if.then.i.i822 ], [ %330, %lpad166 ], [ %330, %if.then.i.i827 ], [ %334, %lpad181 ], [ %337, %lpad183 ], [ %337, %if.then.i.i833 ], [ %434, %lpad241 ], [ %434, %if.then.i.i903 ], [ %495, %lpad335 ], [ %495, %if.then.i.i949 ], [ %508, %lpad388 ], [ %508, %if.then.i.i ]
  %exn.slot.10 = phi i8* [ %321, %lpad143 ], [ %321, %if.then.i.i817 ], [ %325, %lpad151 ], [ %325, %if.then.i.i822 ], [ %329, %lpad166 ], [ %329, %if.then.i.i827 ], [ %333, %lpad181 ], [ %336, %lpad183 ], [ %336, %if.then.i.i833 ], [ %433, %lpad241 ], [ %433, %if.then.i.i903 ], [ %494, %lpad335 ], [ %494, %if.then.i.i949 ], [ %507, %lpad388 ], [ %507, %if.then.i.i ]
  call void @llvm.lifetime.end.p0i8(i64 1024, i8* nonnull %0) #16
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.10, 0
  %lpad.val463 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.10, 1
  resume { i8*, i32 } %lpad.val463

vector.body1426.1:                                ; preds = %vector.body1426
  %offset.idx1434.1 = add nuw nsw i64 %512, %index.next1429
  %590 = or i64 %offset.idx1434.1, 8
  %591 = or i64 %offset.idx1434.1, 16
  %592 = or i64 %offset.idx1434.1, 24
  %593 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %offset.idx1434.1, i32 1
  %594 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %590, i32 1
  %595 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %591, i32 1
  %596 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %call161, i64 %592, i32 1
  %597 = bitcast i32* %593 to <16 x i32>*
  %598 = bitcast i32* %594 to <16 x i32>*
  %599 = bitcast i32* %595 to <16 x i32>*
  %600 = bitcast i32* %596 to <16 x i32>*
  %wide.vec1448.1 = load <16 x i32>, <16 x i32>* %597, align 4, !tbaa !69
  %wide.vec1449.1 = load <16 x i32>, <16 x i32>* %598, align 4, !tbaa !69
  %wide.vec1450.1 = load <16 x i32>, <16 x i32>* %599, align 4, !tbaa !69
  %wide.vec1451.1 = load <16 x i32>, <16 x i32>* %600, align 4, !tbaa !69
  %strided.vec1452.1 = shufflevector <16 x i32> %wide.vec1448.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1453.1 = shufflevector <16 x i32> %wide.vec1449.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1454.1 = shufflevector <16 x i32> %wide.vec1450.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1455.1 = shufflevector <16 x i32> %wide.vec1451.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %601 = getelementptr inbounds i32, i32* %231, i64 %offset.idx1434.1
  %602 = bitcast i32* %601 to <8 x i32>*
  store <8 x i32> %strided.vec1452.1, <8 x i32>* %602, align 4, !tbaa !16
  %603 = getelementptr inbounds i32, i32* %601, i64 8
  %604 = bitcast i32* %603 to <8 x i32>*
  store <8 x i32> %strided.vec1453.1, <8 x i32>* %604, align 4, !tbaa !16
  %605 = getelementptr inbounds i32, i32* %601, i64 16
  %606 = bitcast i32* %605 to <8 x i32>*
  store <8 x i32> %strided.vec1454.1, <8 x i32>* %606, align 4, !tbaa !16
  %607 = getelementptr inbounds i32, i32* %601, i64 24
  %608 = bitcast i32* %607 to <8 x i32>*
  store <8 x i32> %strided.vec1455.1, <8 x i32>* %608, align 4, !tbaa !16
  %index.next1429.1 = add nuw nsw i64 %index1428, 64
  br label %vector.body1426

if.then.i.i809.1:                                 ; preds = %for.inc.i.i
  %inc.i.i.1 = add i32 %k.1.i.i, 1
  %idxprom3.i.i.1 = zext i32 %k.1.i.i to i64
  %arrayidx4.i.i.1 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %idxprom3.i.i.1
  %609 = bitcast %struct.seg* %arrayidx4.i.i.1 to i64*
  store i64 %agg.tmp.sroa.0.0.copyload.i.i.1, i64* %609, align 4
  br label %for.inc.i.i.1

for.inc.i.i.1:                                    ; preds = %if.then.i.i809.1, %for.inc.i.i
  %k.1.i.i.1 = phi i32 [ %inc.i.i.1, %if.then.i.i809.1 ], [ %k.1.i.i, %for.inc.i.i ]
  %indvars.iv.next.i.i.1 = or i64 %indvars.iv.i.i, 2
  %arrayidx.i.i.2 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %indvars.iv.next.i.i.1
  %agg.tmp.sroa.0.0..sroa_cast.i.i.2 = bitcast %struct.seg* %arrayidx.i.i.2 to i64*
  %agg.tmp.sroa.0.0.copyload.i.i.2 = load i64, i64* %agg.tmp.sroa.0.0..sroa_cast.i.i.2, align 4, !tbaa.struct !55
  %s.sroa.1.0.extract.shift.i.i.i.2 = lshr i64 %agg.tmp.sroa.0.0.copyload.i.i.2, 32
  %s.sroa.1.0.extract.trunc.i.i.i.2 = trunc i64 %s.sroa.1.0.extract.shift.i.i.i.2 to i32
  %cmp.i.i.i808.2 = icmp ugt i32 %s.sroa.1.0.extract.trunc.i.i.i.2, 1
  br i1 %cmp.i.i.i808.2, label %if.then.i.i809.2, label %for.inc.i.i.2

if.then.i.i809.2:                                 ; preds = %for.inc.i.i.1
  %inc.i.i.2 = add i32 %k.1.i.i.1, 1
  %idxprom3.i.i.2 = zext i32 %k.1.i.i.1 to i64
  %arrayidx4.i.i.2 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %idxprom3.i.i.2
  %610 = bitcast %struct.seg* %arrayidx4.i.i.2 to i64*
  store i64 %agg.tmp.sroa.0.0.copyload.i.i.2, i64* %610, align 4
  br label %for.inc.i.i.2

for.inc.i.i.2:                                    ; preds = %if.then.i.i809.2, %for.inc.i.i.1
  %k.1.i.i.2 = phi i32 [ %inc.i.i.2, %if.then.i.i809.2 ], [ %k.1.i.i.1, %for.inc.i.i.1 ]
  %indvars.iv.next.i.i.2 = or i64 %indvars.iv.i.i, 3
  %arrayidx.i.i.3 = getelementptr inbounds %struct.seg, %struct.seg* %232, i64 %indvars.iv.next.i.i.2
  %agg.tmp.sroa.0.0..sroa_cast.i.i.3 = bitcast %struct.seg* %arrayidx.i.i.3 to i64*
  %agg.tmp.sroa.0.0.copyload.i.i.3 = load i64, i64* %agg.tmp.sroa.0.0..sroa_cast.i.i.3, align 4, !tbaa.struct !55
  %s.sroa.1.0.extract.shift.i.i.i.3 = lshr i64 %agg.tmp.sroa.0.0.copyload.i.i.3, 32
  %s.sroa.1.0.extract.trunc.i.i.i.3 = trunc i64 %s.sroa.1.0.extract.shift.i.i.i.3 to i32
  %cmp.i.i.i808.3 = icmp ugt i32 %s.sroa.1.0.extract.trunc.i.i.i.3, 1
  br i1 %cmp.i.i.i808.3, label %if.then.i.i809.3, label %for.inc.i.i.3

if.then.i.i809.3:                                 ; preds = %for.inc.i.i.2
  %inc.i.i.3 = add i32 %k.1.i.i.2, 1
  %idxprom3.i.i.3 = zext i32 %k.1.i.i.2 to i64
  %arrayidx4.i.i.3 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %idxprom3.i.i.3
  %611 = bitcast %struct.seg* %arrayidx4.i.i.3 to i64*
  store i64 %agg.tmp.sroa.0.0.copyload.i.i.3, i64* %611, align 4
  br label %for.inc.i.i.3

for.inc.i.i.3:                                    ; preds = %if.then.i.i809.3, %for.inc.i.i.2
  %k.1.i.i.3 = phi i32 [ %inc.i.i.3, %if.then.i.i809.3 ], [ %k.1.i.i.2, %for.inc.i.i.2 ]
  %indvars.iv.next.i.i.3 = add nuw nsw i64 %indvars.iv.i.i, 4
  %niter1511.nsub.3 = add i64 %niter1511, -4
  %niter1511.ncmp.3 = icmp eq i64 %niter1511.nsub.3, 0
  br i1 %niter1511.ncmp.3, label %_ZN8sequence6filterI3segj5isSegLi2048EEET0_PT_S5_S3_T1_.exit.tfend.tfend.loopexit.unr-lcssa.loopexit, label %for.body.i.i

vector.body1352.1:                                ; preds = %vector.body1352
  %offset.idx1360.1 = add nuw nsw i64 %339, %index.next1355
  %612 = or i64 %offset.idx1360.1, 8
  %613 = or i64 %offset.idx1360.1, 16
  %614 = or i64 %offset.idx1360.1, 24
  %615 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %offset.idx1360.1, i32 1
  %616 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %612, i32 1
  %617 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %613, i32 1
  %618 = getelementptr inbounds %struct.seg, %struct.seg* %244, i64 %614, i32 1
  %619 = bitcast i32* %615 to <16 x i32>*
  %620 = bitcast i32* %616 to <16 x i32>*
  %621 = bitcast i32* %617 to <16 x i32>*
  %622 = bitcast i32* %618 to <16 x i32>*
  %wide.vec1374.1 = load <16 x i32>, <16 x i32>* %619, align 4, !tbaa !62
  %wide.vec1375.1 = load <16 x i32>, <16 x i32>* %620, align 4, !tbaa !62
  %wide.vec1376.1 = load <16 x i32>, <16 x i32>* %621, align 4, !tbaa !62
  %wide.vec1377.1 = load <16 x i32>, <16 x i32>* %622, align 4, !tbaa !62
  %strided.vec1378.1 = shufflevector <16 x i32> %wide.vec1374.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1379.1 = shufflevector <16 x i32> %wide.vec1375.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1380.1 = shufflevector <16 x i32> %wide.vec1376.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1381.1 = shufflevector <16 x i32> %wide.vec1377.1, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %623 = getelementptr inbounds i32, i32* %243, i64 %offset.idx1360.1
  %624 = bitcast i32* %623 to <8 x i32>*
  store <8 x i32> %strided.vec1378.1, <8 x i32>* %624, align 4, !tbaa !16
  %625 = getelementptr inbounds i32, i32* %623, i64 8
  %626 = bitcast i32* %625 to <8 x i32>*
  store <8 x i32> %strided.vec1379.1, <8 x i32>* %626, align 4, !tbaa !16
  %627 = getelementptr inbounds i32, i32* %623, i64 16
  %628 = bitcast i32* %627 to <8 x i32>*
  store <8 x i32> %strided.vec1380.1, <8 x i32>* %628, align 4, !tbaa !16
  %629 = getelementptr inbounds i32, i32* %623, i64 24
  %630 = bitcast i32* %629 to <8 x i32>*
  store <8 x i32> %strided.vec1381.1, <8 x i32>* %630, align 4, !tbaa !16
  %index.next1355.1 = add nuw nsw i64 %index1354, 64
  br label %vector.body1352

vector.body1289.3:                                ; preds = %vector.body1289
  %vec.ind.next1301.2 = add <8 x i64> %vec.ind1300, <i64 24, i64 24, i64 24, i64 24, i64 24, i64 24, i64 24, i64 24>
  %631 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, <8 x i64> %vec.ind.next1301.2
  %632 = extractelement <8 x %"struct.std::pair"*> %631, i32 0
  %633 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %632, i64 0, i32 1
  %634 = bitcast i32* %633 to <16 x i32>*
  %wide.vec1306.3 = load <16 x i32>, <16 x i32>* %634, align 4, !tbaa !69
  %strided.vec1307.3 = shufflevector <16 x i32> %wide.vec1306.3, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %635 = add <8 x i32> %strided.vec1307.3, %broadcast.splat1309
  %636 = zext <8 x i32> %635 to <8 x i64>
  %637 = icmp sgt <8 x i64> %broadcast.splat1311, %636
  %638 = getelementptr inbounds i32, i32* %231, <8 x i64> %636
  %wide.masked.gather1312.3 = call <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*> %638, i32 4, <8 x i1> %637, <8 x i32> undef), !tbaa !16
  %predphi1313.3 = select <8 x i1> %637, <8 x i32> %wide.masked.gather1312.3, <8 x i32> zeroinitializer
  %639 = getelementptr inbounds %"struct.std::pair", <8 x %"struct.std::pair"*> %631, i64 0, i32 0
  call void @llvm.masked.scatter.v8i32.v8p0i32(<8 x i32> %predphi1313.3, <8 x i32*> %639, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>), !tbaa !71
  %index.next1292.3 = add nuw nsw i64 %index1291, 32
  %vec.ind.next1301.3 = add <8 x i64> %vec.ind1300, <i64 32, i64 32, i64 32, i64 32, i64 32, i64 32, i64 32, i64 32>
  br label %vector.body1289

cond.false.1:                                     ; preds = %cond.end
  %arrayidx297.1 = getelementptr inbounds i32, i32* %231, i64 %conv294.1
  %640 = load i32, i32* %arrayidx297.1, align 4, !tbaa !16
  br label %cond.end.1

cond.end.1:                                       ; preds = %cond.false.1, %cond.end
  %cond.1 = phi i32 [ %640, %cond.false.1 ], [ 0, %cond.end ]
  %first.1 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.1, i64 0, i32 0
  store i32 %cond.1, i32* %first.1, align 4, !tbaa !71
  %indvars.iv.next1098.2 = or i64 %440, 251
  %arrayidx292.2 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %indvars.iv.next1098.1
  %second.2 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.2, i64 0, i32 1
  %641 = load i32, i32* %second.2, align 4, !tbaa !69
  %add293.2 = add i32 %641, %offset.0
  %conv294.2 = zext i32 %add293.2 to i64
  %cmp295.2 = icmp slt i64 %conv294.2, %n
  br i1 %cmp295.2, label %cond.false.2, label %cond.end.2

cond.false.2:                                     ; preds = %cond.end.1
  %arrayidx297.2 = getelementptr inbounds i32, i32* %231, i64 %conv294.2
  %642 = load i32, i32* %arrayidx297.2, align 4, !tbaa !16
  br label %cond.end.2

cond.end.2:                                       ; preds = %cond.false.2, %cond.end.1
  %cond.2 = phi i32 [ %642, %cond.false.2 ], [ 0, %cond.end.1 ]
  %first.2 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.2, i64 0, i32 0
  store i32 %cond.2, i32* %first.2, align 4, !tbaa !71
  %indvars.iv.next1098.3 = add nuw nsw i64 %indvars.iv.next1098.2, 1
  %arrayidx292.3 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %indvars.iv.next1098.2
  %second.3 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.3, i64 0, i32 1
  %643 = load i32, i32* %second.3, align 4, !tbaa !69
  %add293.3 = add i32 %643, %offset.0
  %conv294.3 = zext i32 %add293.3 to i64
  %cmp295.3 = icmp slt i64 %conv294.3, %n
  br i1 %cmp295.3, label %cond.false.3, label %cond.end.3

cond.false.3:                                     ; preds = %cond.end.2
  %arrayidx297.3 = getelementptr inbounds i32, i32* %231, i64 %conv294.3
  %644 = load i32, i32* %arrayidx297.3, align 4, !tbaa !16
  br label %cond.end.3

cond.end.3:                                       ; preds = %cond.false.3, %cond.end.2
  %cond.3 = phi i32 [ %644, %cond.false.3 ], [ 0, %cond.end.2 ]
  %first.3 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.3, i64 0, i32 0
  store i32 %cond.3, i32* %first.3, align 4, !tbaa !71
  %indvars.iv.next1098.4 = add nuw nsw i64 %indvars.iv.next1098.2, 2
  %arrayidx292.4 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %indvars.iv.next1098.3
  %second.4 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.4, i64 0, i32 1
  %645 = load i32, i32* %second.4, align 4, !tbaa !69
  %add293.4 = add i32 %645, %offset.0
  %conv294.4 = zext i32 %add293.4 to i64
  %cmp295.4 = icmp slt i64 %conv294.4, %n
  br i1 %cmp295.4, label %cond.false.4, label %cond.end.4

cond.false.4:                                     ; preds = %cond.end.3
  %arrayidx297.4 = getelementptr inbounds i32, i32* %231, i64 %conv294.4
  %646 = load i32, i32* %arrayidx297.4, align 4, !tbaa !16
  br label %cond.end.4

cond.end.4:                                       ; preds = %cond.false.4, %cond.end.3
  %cond.4 = phi i32 [ %646, %cond.false.4 ], [ 0, %cond.end.3 ]
  %first.4 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.4, i64 0, i32 0
  store i32 %cond.4, i32* %first.4, align 4, !tbaa !71
  %indvars.iv.next1098.5 = add nuw nsw i64 %indvars.iv.next1098.2, 3
  %arrayidx292.5 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %indvars.iv.next1098.4
  %second.5 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.5, i64 0, i32 1
  %647 = load i32, i32* %second.5, align 4, !tbaa !69
  %add293.5 = add i32 %647, %offset.0
  %conv294.5 = zext i32 %add293.5 to i64
  %cmp295.5 = icmp slt i64 %conv294.5, %n
  br i1 %cmp295.5, label %cond.false.5, label %cond.end.5

cond.false.5:                                     ; preds = %cond.end.4
  %arrayidx297.5 = getelementptr inbounds i32, i32* %231, i64 %conv294.5
  %648 = load i32, i32* %arrayidx297.5, align 4, !tbaa !16
  br label %cond.end.5

cond.end.5:                                       ; preds = %cond.false.5, %cond.end.4
  %cond.5 = phi i32 [ %648, %cond.false.5 ], [ 0, %cond.end.4 ]
  %first.5 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.5, i64 0, i32 0
  store i32 %cond.5, i32* %first.5, align 4, !tbaa !71
  %indvars.iv.next1098.6 = or i64 %440, 255
  %arrayidx292.6 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %indvars.iv.next1098.5
  %second.6 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.6, i64 0, i32 1
  %649 = load i32, i32* %second.6, align 4, !tbaa !69
  %add293.6 = add i32 %649, %offset.0
  %conv294.6 = zext i32 %add293.6 to i64
  %cmp295.6 = icmp slt i64 %conv294.6, %n
  br i1 %cmp295.6, label %cond.false.6, label %cond.end.6

cond.false.6:                                     ; preds = %cond.end.5
  %arrayidx297.6 = getelementptr inbounds i32, i32* %231, i64 %conv294.6
  %650 = load i32, i32* %arrayidx297.6, align 4, !tbaa !16
  br label %cond.end.6

cond.end.6:                                       ; preds = %cond.false.6, %cond.end.5
  %cond.6 = phi i32 [ %650, %cond.false.6 ], [ 0, %cond.end.5 ]
  %first.6 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.6, i64 0, i32 0
  store i32 %cond.6, i32* %first.6, align 4, !tbaa !71
  %arrayidx292.7 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %add.ptr, i64 %indvars.iv.next1098.6
  %second.7 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.7, i64 0, i32 1
  %651 = load i32, i32* %second.7, align 4, !tbaa !69
  %add293.7 = add i32 %651, %offset.0
  %conv294.7 = zext i32 %add293.7 to i64
  %cmp295.7 = icmp slt i64 %conv294.7, %n
  br i1 %cmp295.7, label %cond.false.7, label %cond.end.7

cond.false.7:                                     ; preds = %cond.end.6
  %arrayidx297.7 = getelementptr inbounds i32, i32* %231, i64 %conv294.7
  %652 = load i32, i32* %arrayidx297.7, align 4, !tbaa !16
  br label %cond.end.7

cond.end.7:                                       ; preds = %cond.false.7, %cond.end.6
  %cond.7 = phi i32 [ %652, %cond.false.7 ], [ 0, %cond.end.6 ]
  %first.7 = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %arrayidx292.7, i64 0, i32 0
  store i32 %cond.7, i32* %first.7, align 4, !tbaa !71
  reattach within %syncreg271.strpm.detachloop, label %pfor.inc301.strpm.outer

if.then.epil.1:                                   ; preds = %pfor.preattach.epil
  store i32 1, i32* %arrayidx10.epil.1, align 4, !tbaa !16
  br label %pfor.preattach.epil.1

pfor.preattach.epil.1:                            ; preds = %if.then.epil.1, %pfor.preattach.epil
  %indvars.iv.next1128.epil.2 = add nuw nsw i64 %indvars.iv1127.epil, 3
  %arrayidx8.epil.2 = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv.next1128.epil.1
  %653 = load i8, i8* %arrayidx8.epil.2, align 1, !tbaa !15
  %idxprom9.epil.2 = zext i8 %653 to i64
  %arrayidx10.epil.2 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9.epil.2
  %654 = load i32, i32* %arrayidx10.epil.2, align 4, !tbaa !16
  %tobool.epil.2 = icmp eq i32 %654, 0
  br i1 %tobool.epil.2, label %if.then.epil.2, label %pfor.preattach.epil.2

if.then.epil.2:                                   ; preds = %pfor.preattach.epil.1
  store i32 1, i32* %arrayidx10.epil.2, align 4, !tbaa !16
  br label %pfor.preattach.epil.2

pfor.preattach.epil.2:                            ; preds = %if.then.epil.2, %pfor.preattach.epil.1
  %indvars.iv.next1128.epil.3 = add nuw nsw i64 %indvars.iv1127.epil, 4
  %arrayidx8.epil.3 = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv.next1128.epil.2
  %655 = load i8, i8* %arrayidx8.epil.3, align 1, !tbaa !15
  %idxprom9.epil.3 = zext i8 %655 to i64
  %arrayidx10.epil.3 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9.epil.3
  %656 = load i32, i32* %arrayidx10.epil.3, align 4, !tbaa !16
  %tobool.epil.3 = icmp eq i32 %656, 0
  br i1 %tobool.epil.3, label %if.then.epil.3, label %pfor.preattach.epil.3

if.then.epil.3:                                   ; preds = %pfor.preattach.epil.2
  store i32 1, i32* %arrayidx10.epil.3, align 4, !tbaa !16
  br label %pfor.preattach.epil.3

pfor.preattach.epil.3:                            ; preds = %if.then.epil.3, %pfor.preattach.epil.2
  %epil.iter1186.sub.3 = add nsw i64 %epil.iter1186, -4
  %epil.iter1186.cmp.3 = icmp eq i64 %epil.iter1186.sub.3, 0
  br i1 %epil.iter1186.cmp.3, label %pfor.cond.cleanup.loopexit, label %pfor.cond.epil, !llvm.loop !82

if.then.1:                                        ; preds = %pfor.preattach
  store i32 1, i32* %arrayidx10.1, align 4, !tbaa !16
  br label %pfor.preattach.1

pfor.preattach.1:                                 ; preds = %if.then.1, %pfor.preattach
  %indvars.iv.next1128.2 = or i64 %indvars.iv1127, 3
  %arrayidx8.2 = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv.next1128.1
  %657 = load i8, i8* %arrayidx8.2, align 1, !tbaa !15
  %idxprom9.2 = zext i8 %657 to i64
  %arrayidx10.2 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9.2
  %658 = load i32, i32* %arrayidx10.2, align 4, !tbaa !16
  %tobool.2 = icmp eq i32 %658, 0
  br i1 %tobool.2, label %if.then.2, label %pfor.preattach.2

if.then.2:                                        ; preds = %pfor.preattach.1
  store i32 1, i32* %arrayidx10.2, align 4, !tbaa !16
  br label %pfor.preattach.2

pfor.preattach.2:                                 ; preds = %if.then.2, %pfor.preattach.1
  %indvars.iv.next1128.3 = add nuw nsw i64 %indvars.iv1127, 4
  %arrayidx8.3 = getelementptr inbounds i8, i8* %ss, i64 %indvars.iv.next1128.2
  %659 = load i8, i8* %arrayidx8.3, align 1, !tbaa !15
  %idxprom9.3 = zext i8 %659 to i64
  %arrayidx10.3 = getelementptr inbounds [256 x i32], [256 x i32]* %flags, i64 0, i64 %idxprom9.3
  %660 = load i32, i32* %arrayidx10.3, align 4, !tbaa !16
  %tobool.3 = icmp eq i32 %660, 0
  br i1 %tobool.3, label %if.then.3, label %pfor.preattach.3

if.then.3:                                        ; preds = %pfor.preattach.2
  store i32 1, i32* %arrayidx10.3, align 4, !tbaa !16
  br label %pfor.preattach.3

pfor.preattach.3:                                 ; preds = %if.then.3, %pfor.preattach.2
  %inneriter1190.nsub.3 = add nsw i64 %inneriter1190, -4
  %inneriter1190.ncmp.3 = icmp eq i64 %inneriter1190.nsub.3, 0
  br i1 %inneriter1190.ncmp.3, label %pfor.inc.reattach, label %pfor.cond, !llvm.loop !83
}

; CHECK-LABEL: define {{.*}}void @_Z19suffixArrayInternalPhl.outline_pfor.cond284.strpm.outer.ls3(
; CHECK-DAG: <8 x i64> %broadcast.splat1311.ls3
; CHECK-DAG: <8 x i32> %broadcast.splat1309.ls3
; CHECK: ) unnamed_addr #[[ATTRIBUTES:[0-9]+]]

; CHECK-LABEL: define {{.*}}void @_Z19suffixArrayInternalPhl.outline_pfor.cond284.strpm.outer.ls3.outline_.split.otd1(
; CHECK-DAG: <8 x i64> %broadcast.splat1311.ls3.otd1
; CHECK-DAG: <8 x i32> %broadcast.splat1309.ls3.otd1
; CHECK: ) unnamed_addr #[[ATTRIBUTES2:[0-9]+]]

; CHECK: call {{.*}}void @_Z19suffixArrayInternalPhl.outline_pfor.cond284.strpm.outer.ls3(
; CHECK-DAG: <8 x i64> %broadcast.splat1311.ls3.otd1
; CHECK-DAG: <8 x i32> %broadcast.splat1309.ls3.otd1
; CHECK: )

; CHECK: attributes #[[ATTRIBUTES]] = {
; CHECK-NOT: "min-legal-vector-width"="0"
; CHECK: }

; CHECK: attributes #[[ATTRIBUTES2]] = {
; CHECK-NOT: "min-legal-vector-width"="0"
; CHECK: }

; Function Attrs: uwtable
declare dso_local void @_Z10sampleSortISt4pairIjjE9pairCompFjEvPT_T1_T0_(%"struct.std::pair"*, i32) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_Z10sampleSortIoSt4lessIoElEvPT_T1_T0_(i128*, i64) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_Z12splitSegmentISt4pairIjjEEvP3segjjPjPT_(%struct.seg*, i32, i32, i32*, %"struct.std::pair"*) local_unnamed_addr #0

; Function Attrs: uwtable
declare noalias %"struct.std::pair"* @_Z15splitSegmentTopP3segjPjPo(%struct.seg* nocapture, i32, i32* nocapture, i128* nocapture) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_Z9quickSortISt4pairIjjE9pairCompFjEvPT_T1_T0_(%"struct.std::pair"*, i32) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN5timer7reportTEd(%struct.timer*, double) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local { %struct.seg*, i64 } @_ZN8sequence4packI3segjNS_4getAIS1_jEELi2048EEE4_seqIT_EPS5_PbT0_S9_T1_(%struct.seg*, i8*, i32, i32, %struct.seg*) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local i32 @_ZN8sequence4scanIjjN5utils4addFIjEENS_4getAIjjEELi1024EEET_PS6_T0_S8_T1_T2_S6_bb(i32*, i32, i32, i32*, i32, i1 zeroext, i1 zeroext) local_unnamed_addr #0

declare dso_local void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"*) local_unnamed_addr #1

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"*, i8 signext) local_unnamed_addr #1

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"*) local_unnamed_addr #1

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"*, double) local_unnamed_addr #1

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIlEERSoT_(%"class.std::basic_ostream"*, i64) local_unnamed_addr #1

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream"*, i64) local_unnamed_addr #1

declare dso_local i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"*, i64* dereferenceable(8), i64) local_unnamed_addr #1

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* dereferenceable(272), i8*, i64) local_unnamed_addr #1

; Function Attrs: noreturn
declare dso_local void @_ZSt16__throw_bad_castv() local_unnamed_addr #2

; Function Attrs: inlinehint uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_(%"class.std::basic_ostream"* dereferenceable(272)) local_unnamed_addr #3

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #4

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #5

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @malloc(i64) local_unnamed_addr #6

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #5

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #5

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #7

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #5

; Function Attrs: nounwind
declare dso_local void @free(i8* nocapture) local_unnamed_addr #8

; Function Attrs: noreturn nounwind
declare dso_local void @abort() local_unnamed_addr #9

; Function Attrs: nofree nounwind
declare dso_local i32 @gettimeofday(%struct.timeval* nocapture, i8* nocapture) local_unnamed_addr #6

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.floor.f64(double) #10

; Function Attrs: nounwind readonly willreturn
declare <8 x i32> @llvm.masked.gather.v8i32.v8p0i32(<8 x i32*>, i32 immarg, <8 x i1>, <8 x i32>) #11

; Function Attrs: nounwind willreturn
declare void @llvm.masked.scatter.v8i32.v8p0i32(<8 x i32>, <8 x i32*>, i32 immarg, <8 x i1>) #12

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.usub.sat.i64(i64, i64) #10

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #5

; Function Attrs: nofree nounwind
declare dso_local double @log2(double) local_unnamed_addr #6

; Function Attrs: nounwind uwtable
define internal void @__cilkrts_enter_frame(%struct.__cilkrts_stack_frame* %sf) local_unnamed_addr #13 {
entry:
  %call = tail call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #16
  %flags = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 0
  store i32 0, i32* %flags, align 8, !tbaa !84
  %magic = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 1
  store i32 21115535, i32* %magic, align 4, !tbaa !90
  %current_stack_frame = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %call, i64 0, i32 7
  %0 = bitcast %struct.__cilkrts_stack_frame** %current_stack_frame to i64*
  %1 = load i64, i64* %0, align 8, !tbaa !91
  %call_parent = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 2
  %2 = bitcast %struct.__cilkrts_stack_frame** %call_parent to i64*
  store i64 %1, i64* %2, align 8, !tbaa !93
  %worker = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 3
  %3 = ptrtoint %struct.__cilkrts_worker* %call to i64
  %4 = bitcast %struct.__cilkrts_worker** %worker to i64*
  store atomic i64 %3, i64* %4 monotonic, align 8
  store %struct.__cilkrts_stack_frame* %sf, %struct.__cilkrts_stack_frame** %current_stack_frame, align 8, !tbaa !91
  ret void
}

declare dso_local %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() local_unnamed_addr #14

; Function Attrs: nounwind uwtable
define internal void @__cilkrts_enter_frame_fast(%struct.__cilkrts_stack_frame* %sf) local_unnamed_addr #13 {
entry:
  %call = tail call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker() #16
  %flags = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 0
  store i32 0, i32* %flags, align 8, !tbaa !84
  %magic = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 1
  store i32 21115535, i32* %magic, align 4, !tbaa !90
  %current_stack_frame = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %call, i64 0, i32 7
  %0 = bitcast %struct.__cilkrts_stack_frame** %current_stack_frame to i64*
  %1 = load i64, i64* %0, align 8, !tbaa !91
  %call_parent = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 2
  %2 = bitcast %struct.__cilkrts_stack_frame** %call_parent to i64*
  store i64 %1, i64* %2, align 8, !tbaa !93
  %worker = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 3
  %3 = ptrtoint %struct.__cilkrts_worker* %call to i64
  %4 = bitcast %struct.__cilkrts_worker** %worker to i64*
  store atomic i64 %3, i64* %4 monotonic, align 8
  store %struct.__cilkrts_stack_frame* %sf, %struct.__cilkrts_stack_frame** %current_stack_frame, align 8, !tbaa !91
  ret void
}

; Function Attrs: nofree norecurse nounwind uwtable
define internal void @__cilkrts_detach(%struct.__cilkrts_stack_frame* nocapture %sf) local_unnamed_addr #15 {
entry:
  %worker = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 3
  %0 = bitcast %struct.__cilkrts_worker** %worker to i64*
  %1 = load atomic i64, i64* %0 monotonic, align 8
  %call_parent = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 2
  %2 = bitcast %struct.__cilkrts_stack_frame** %call_parent to i64*
  %3 = load i64, i64* %2, align 8, !tbaa !93
  %flags = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 0
  %4 = load i32, i32* %flags, align 8, !tbaa !84
  %or = or i32 %4, 4
  store i32 %or, i32* %flags, align 8, !tbaa !84
  %5 = inttoptr i64 %1 to i64*
  %6 = load atomic i64, i64* %5 monotonic, align 8
  %7 = inttoptr i64 %6 to %struct.__cilkrts_stack_frame**
  %incdec.ptr = getelementptr inbounds %struct.__cilkrts_stack_frame*, %struct.__cilkrts_stack_frame** %7, i64 1
  %8 = inttoptr i64 %6 to i64*
  store i64 %3, i64* %8, align 8, !tbaa !94
  %9 = ptrtoint %struct.__cilkrts_stack_frame** %incdec.ptr to i64
  store atomic i64 %9, i64* %5 release, align 8
  ret void
}

; Function Attrs: nounwind uwtable
define internal void @__cilkrts_save_fp_ctrl_state(%struct.__cilkrts_stack_frame* %sf) local_unnamed_addr #13 {
entry:
  tail call void @sysdep_save_fp_ctrl_state(%struct.__cilkrts_stack_frame* %sf) #16
  ret void
}

declare dso_local void @sysdep_save_fp_ctrl_state(%struct.__cilkrts_stack_frame*) local_unnamed_addr #14

; Function Attrs: nofree norecurse nounwind uwtable
define internal void @__cilkrts_pop_frame(%struct.__cilkrts_stack_frame* nocapture %sf) local_unnamed_addr #15 {
entry:
  %worker = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 3
  %0 = bitcast %struct.__cilkrts_worker** %worker to i64*
  %1 = load atomic i64, i64* %0 monotonic, align 8
  %2 = inttoptr i64 %1 to %struct.__cilkrts_worker*
  %call_parent = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %sf, i64 0, i32 2
  %3 = bitcast %struct.__cilkrts_stack_frame** %call_parent to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !93
  %current_stack_frame = getelementptr inbounds %struct.__cilkrts_worker, %struct.__cilkrts_worker* %2, i64 0, i32 7
  %5 = bitcast %struct.__cilkrts_stack_frame** %current_stack_frame to i64*
  store i64 %4, i64* %5, align 8, !tbaa !91
  store %struct.__cilkrts_stack_frame* null, %struct.__cilkrts_stack_frame** %call_parent, align 8, !tbaa !93
  ret void
}

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { inlinehint uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { argmemonly nounwind willreturn }
attributes #6 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { argmemonly willreturn }
attributes #8 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nounwind readnone speculatable willreturn }
attributes #11 = { nounwind readonly willreturn }
attributes #12 = { nounwind willreturn }
attributes #13 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #14 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { nofree norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { nounwind }
attributes #17 = { noreturn }
attributes #18 = { noreturn nounwind }

!llvm.module.flags = !{!1}

!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!3, !7, i64 24}
!3 = !{!"_ZTS5timer", !4, i64 0, !4, i64 8, !4, i64 16, !7, i64 24, !8, i64 28}
!4 = !{!"double", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!"bool", !5, i64 0}
!8 = !{!"_ZTS8timezone", !9, i64 0, !9, i64 4}
!9 = !{!"int", !5, i64 0}
!10 = !{!11, !12, i64 0}
!11 = !{!"_ZTS7timeval", !12, i64 0, !12, i64 8}
!12 = !{!"long", !5, i64 0}
!13 = !{!11, !12, i64 8}
!14 = !{!3, !4, i64 8}
!15 = !{!5, !5, i64 0}
!16 = !{!9, !9, i64 0}
!17 = distinct !{!17, !18, !19}
!18 = !{!"tapir.loop.spawn.strategy", i32 1}
!19 = !{!"tapir.loop.grainsize", i32 1}
!20 = distinct !{!20, !21}
!21 = !{!"llvm.loop.unroll.disable"}
!22 = !{!23, !23, i64 0}
!23 = !{!"vtable pointer", !6, i64 0}
!24 = !{!25, !26, i64 240}
!25 = !{!"_ZTSSt9basic_iosIcSt11char_traitsIcEE", !26, i64 216, !5, i64 224, !7, i64 225, !26, i64 232, !26, i64 240, !26, i64 248, !26, i64 256}
!26 = !{!"any pointer", !5, i64 0}
!27 = !{!28, !5, i64 56}
!28 = !{!"_ZTSSt5ctypeIcE", !26, i64 16, !7, i64 24, !26, i64 32, !26, i64 40, !26, i64 48, !5, i64 56, !5, i64 57, !5, i64 313, !5, i64 569}
!29 = distinct !{!29, !30, !31}
!30 = !{!"llvm.loop.from.tapir.loop"}
!31 = !{!"llvm.loop.isvectorized", i32 1}
!32 = distinct !{!32, !18, !19}
!33 = distinct !{!33, !30, !31}
!34 = distinct !{!34, !30, !35, !31}
!35 = !{!"llvm.loop.unroll.runtime.disable"}
!36 = distinct !{!36, !31}
!37 = distinct !{!37, !21}
!38 = distinct !{!38, !18}
!39 = distinct !{!39, !21}
!40 = !{!41, !41, i64 0}
!41 = !{!"__int128", !5, i64 0}
!42 = distinct !{!42, !31}
!43 = distinct !{!43, !30}
!44 = distinct !{!44, !18, !19}
!45 = distinct !{!45, !21}
!46 = distinct !{!46, !30}
!47 = !{!48, !26, i64 0}
!48 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_Alloc_hiderE", !26, i64 0}
!49 = !{!50, !12, i64 8}
!50 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", !48, i64 0, !12, i64 8, !5, i64 16}
!51 = !{i8 0, i8 2}
!52 = !{!3, !4, i64 0}
!53 = !{!50, !26, i64 0}
!54 = !{!12, !12, i64 0}
!55 = !{i64 0, i64 4, !16, i64 4, i64 4, !16}
!56 = !{!7, !7, i64 0}
!57 = distinct !{!57, !30, !31}
!58 = distinct !{!58, !18, !19}
!59 = distinct !{!59, !30, !31}
!60 = distinct !{!60, !30, !35, !31}
!61 = distinct !{!61, !21}
!62 = !{!63, !9, i64 4}
!63 = !{!"_ZTS3seg", !9, i64 0, !9, i64 4}
!64 = distinct !{!64, !30, !31}
!65 = distinct !{!65, !18, !19}
!66 = distinct !{!66, !30, !31}
!67 = distinct !{!67, !30, !35, !31}
!68 = !{!63, !9, i64 0}
!69 = !{!70, !9, i64 4}
!70 = !{!"_ZTSSt4pairIjjE", !9, i64 0, !9, i64 4}
!71 = !{!70, !9, i64 0}
!72 = distinct !{!72, !30, !31}
!73 = distinct !{!73, !18, !19}
!74 = distinct !{!74, !30, !31}
!75 = distinct !{!75, !30, !35, !31}
!76 = distinct !{!76, !18}
!77 = distinct !{!77, !18}
!78 = distinct !{!78, !30, !31}
!79 = distinct !{!79, !18, !19}
!80 = distinct !{!80, !30, !31}
!81 = distinct !{!81, !30, !35, !31}
!82 = distinct !{!82, !30}
!83 = distinct !{!83, !30}
!84 = !{!85, !86, i64 0}
!85 = !{!"__cilkrts_stack_frame", !86, i64 0, !86, i64 4, !89, i64 8, !87, i64 16, !87, i64 24, !86, i64 64}
!86 = !{!"int", !87, i64 0}
!87 = !{!"omnipotent char", !88, i64 0}
!88 = !{!"Simple C/C++ TBAA"}
!89 = !{!"any pointer", !87, i64 0}
!90 = !{!85, !86, i64 4}
!91 = !{!92, !89, i64 56}
!92 = !{!"__cilkrts_worker", !87, i64 0, !87, i64 8, !87, i64 16, !89, i64 24, !86, i64 32, !89, i64 40, !89, i64 48, !89, i64 56, !89, i64 64}
!93 = !{!85, !89, i64 8}
!94 = !{!89, !89, i64 0}
