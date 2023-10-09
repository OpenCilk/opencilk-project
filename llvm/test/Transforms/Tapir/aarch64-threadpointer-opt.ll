; Check that reads of the threadpointer register on AArch64 are not hoisted
; across function calls where the Cilk worker might change.
;
; RUN: llc < %s -O2 -mtriple=aarch64--linux-gnu | FileCheck %s
; REQUIRES: aarch64-registered-target
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

%struct.__cilkrts_worker = type { i32, ptr, ptr, ptr, ptr, ptr, ptr, [8 x i8], ptr, [56 x i8], ptr, ptr, [880 x i8] }
%struct.local_hyper_table = type { i32, i32, i32, ptr }
%struct.bucket = type { i64, %struct.reducer_base }
%struct.reducer_base = type { ptr, ptr }
%struct.__cilkrts_stack_frame = type { i32, i32, ptr, ptr, [5 x ptr], ptr }
%struct.fiber_header = type { ptr, ptr, ptr, [104 x i8] }

@cilkg_nproc = external local_unnamed_addr global i32, align 4
@__cilkrts_need_to_cilkify = external local_unnamed_addr global i8, align 1
@__cilkrts_current_fh = external thread_local global ptr, align 8
@__cilkrts_tls_worker = external thread_local global ptr, align 8

; Function Attrs: nounwind uwtable
define dso_local void @reducer_stuff(i32 noundef %count_8, ptr nocapture noundef writeonly %out) local_unnamed_addr #0 {
entry:
  %sum0 = alloca i64, align 16
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %sum0) #8
  store i64 -1, ptr %sum0, align 16, !tbaa !8
  call void @__cilkrts_reducer_register_64(ptr nonnull %sum0, i64 8, ptr nonnull @identity_long, ptr nonnull @reduce_long)
  %cmp = icmp sgt i32 %count_8, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %entry
  %conv = zext i32 %count_8 to i64
  %mul = shl nuw nsw i64 %conv, 3
  %0 = load i32, ptr @cilkg_nproc, align 4, !tbaa !12
  %mul.i = shl i32 %0, 3
  %conv.i = zext i32 %mul.i to i64
  %div.i = udiv i64 %mul, %conv.i
  %cond.i = call i64 @llvm.umin.i64(i64 %div.i, i64 2048)
  %retval.0.i = call i64 @llvm.umax.i64(i64 %cond.i, i64 1)
  call fastcc void @reducer_stuff.outline_pfor.cond.ls1(i64 0, i64 %mul, i64 %retval.0.i, ptr nonnull %sum0) #8
  br label %cleanup

cleanup:                                          ; preds = %pfor.cond.preheader, %entry
  %1 = load i8, ptr @__cilkrts_need_to_cilkify, align 1, !tbaa !14, !range !16, !noundef !17
  %tobool.not.i = icmp eq i8 %1, 0
  br i1 %tobool.not.i, label %if.end.i, label %__cilkrts_reducer_lookup.exit

if.end.i:                                         ; preds = %cleanup
  %2 = call align 8 ptr @llvm.threadlocal.address.p0(ptr align 8 @__cilkrts_tls_worker)
  %3 = load ptr, ptr %2, align 8, !tbaa !18
  %hyper_table.i.i.i = getelementptr inbounds %struct.__cilkrts_worker, ptr %3, i64 0, i32 1
  %4 = load ptr, ptr %hyper_table.i.i.i, align 8, !tbaa !20
  %cmp.i.i.i = icmp eq ptr %4, null
  br i1 %cmp.i.i.i, label %if.then.i.i.i, label %get_hyper_table.exit.i

if.then.i.i.i:                                    ; preds = %if.end.i
  %call.i.i.i = call ptr @__cilkrts_local_hyper_table_alloc() #8
  store ptr %call.i.i.i, ptr %hyper_table.i.i.i, align 8, !tbaa !20
  br label %get_hyper_table.exit.i

get_hyper_table.exit.i:                           ; preds = %if.then.i.i.i, %if.end.i
  %5 = phi ptr [ %call.i.i.i, %if.then.i.i.i ], [ %4, %if.end.i ]
  %6 = ptrtoint ptr %sum0 to i64
  %7 = load i32, ptr %5, align 8, !tbaa !22
  %cmp.i.i = icmp ult i32 %7, 8
  br i1 %cmp.i.i, label %if.then.i.i, label %find_hyperobject.exit.i

if.then.i.i:                                      ; preds = %get_hyper_table.exit.i
  %buckets1.i.i.i = getelementptr inbounds %struct.local_hyper_table, ptr %5, i64 0, i32 3
  %8 = load ptr, ptr %buckets1.i.i.i, align 8, !tbaa !24
  %occupancy2.i.i.i = getelementptr inbounds %struct.local_hyper_table, ptr %5, i64 0, i32 1
  %9 = load i32, ptr %occupancy2.i.i.i, align 4, !tbaa !25
  %10 = zext i32 %9 to i64
  br label %for.cond.i.i.i

for.cond.i.i.i:                                   ; preds = %for.body.i.i.i, %if.then.i.i
  %indvars.iv.i.i.i = phi i64 [ %12, %for.body.i.i.i ], [ %10, %if.then.i.i ]
  %11 = trunc i64 %indvars.iv.i.i.i to i32
  %cmp.i.i13.i = icmp slt i32 %11, 1
  br i1 %cmp.i.i13.i, label %if.end6.i, label %for.body.i.i.i

for.body.i.i.i:                                   ; preds = %for.cond.i.i.i
  %12 = add nsw i64 %indvars.iv.i.i.i, -1
  %arrayidx.i.i.i = getelementptr inbounds %struct.bucket, ptr %8, i64 %12
  %13 = load i64, ptr %arrayidx.i.i.i, align 8, !tbaa !26
  %cmp4.i.i.i = icmp eq i64 %13, %6
  br i1 %cmp4.i.i.i, label %if.then5.i, label %for.cond.i.i.i, !llvm.loop !29

find_hyperobject.exit.i:                          ; preds = %get_hyper_table.exit.i
  %call1.i.i = call ptr @__cilkrts_find_hyperobject_hash(ptr noundef nonnull %5, i64 noundef %6) #8
  %tobool2.not.i = icmp eq ptr %call1.i.i, null
  br i1 %tobool2.not.i, label %if.end6.i, label %if.then5.i, !prof !31

if.then5.i:                                       ; preds = %find_hyperobject.exit.i, %for.body.i.i.i
  %retval.0.i19.i = phi ptr [ %call1.i.i, %find_hyperobject.exit.i ], [ %arrayidx.i.i.i, %for.body.i.i.i ]
  %value.i = getelementptr inbounds %struct.bucket, ptr %retval.0.i19.i, i64 0, i32 1
  %14 = load ptr, ptr %value.i, align 8, !tbaa !32
  br label %__cilkrts_reducer_lookup.exit

if.end6.i:                                        ; preds = %find_hyperobject.exit.i, %for.cond.i.i.i
  %call7.i = call ptr @__cilkrts_insert_new_view(ptr noundef nonnull %5, i64 noundef %6, i64 noundef 8, ptr noundef nonnull @identity_long, ptr noundef nonnull @reduce_long) #8
  br label %__cilkrts_reducer_lookup.exit

__cilkrts_reducer_lookup.exit:                    ; preds = %if.end6.i, %if.then5.i, %cleanup
  %retval.1.i = phi ptr [ %sum0, %cleanup ], [ %14, %if.then5.i ], [ %call7.i, %if.end6.i ]
  %15 = load i64, ptr %retval.1.i, align 8, !tbaa !8
  store i64 %15, ptr %out, align 8, !tbaa !8
  call void @__cilkrts_reducer_unregister(ptr nonnull %sum0)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %sum0) #8
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

declare void @identity_long(ptr noundef) #2

declare void @reduce_long(ptr noundef, ptr noundef) #2

declare i64 @f(i64 noundef) local_unnamed_addr #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; CHECK: reducer_stuff.outline_pfor.cond.ls1:
; CHECK: #EH_SjLj_Setup
; CHECK: mrs x{{[0-9]+}}, TPIDR_EL0
; CHECK: #EH_SjLj_Setup
; CHECK: bl reducer_stuff.outline_pfor.cond.ls1.outline_.split.otd1
; CHECK: mrs x{{[0-9]+}}, TPIDR_EL0
; CHECK: bl __cilkrts_local_hyper_table_alloc

; Function Attrs: nounwind stealable memory(readwrite, argmem: none, inaccessiblemem: none) uwtable
define internal fastcc void @reducer_stuff.outline_pfor.cond.ls1(i64 %__begin.0.start.ls1, i64 %end.ls1, i64 %grainsize.ls1, ptr align 16 %sum0.ls1) unnamed_addr #3 {
pfor.cond.preheader.ls1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  store i32 0, ptr %__cilkrts_sf, align 8, !tbaa !33
  %0 = load i8, ptr @__cilkrts_need_to_cilkify, align 1, !tbaa !14, !range !16, !noundef !17
  %tobool.not.i7 = icmp eq i8 %0, 0
  br i1 %tobool.not.i7, label %__cilkrts_enter_frame.exit, label %if.then.i

if.then.i:                                        ; preds = %pfor.cond.preheader.ls1
  %ctx.i.i = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 4
  %1 = tail call ptr @llvm.frameaddress.p0(i32 0)
  store ptr %1, ptr %ctx.i.i, align 8
  %2 = tail call ptr @llvm.stacksave()
  %3 = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 4, i64 2
  store ptr %2, ptr %3, align 8
  %4 = call i32 @llvm.eh.sjlj.setjmp(ptr nonnull %ctx.i.i)
  %cmp.i.i8 = icmp eq i32 %4, 0
  br i1 %cmp.i.i8, label %if.then.i.i9, label %__cilkrts_enter_frame.exit

if.then.i.i9:                                     ; preds = %if.then.i
  call void @__cilkrts_internal_invoke_cilkified_root(ptr noundef nonnull %__cilkrts_sf) #8
  br label %__cilkrts_enter_frame.exit

__cilkrts_enter_frame.exit:                       ; preds = %if.then.i.i9, %if.then.i, %pfor.cond.preheader.ls1
  %magic.i = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 1
  store i32 2179696, ptr %magic.i, align 4, !tbaa !35
  %5 = call align 8 ptr @llvm.threadlocal.address.p0(ptr align 8 @__cilkrts_current_fh)
  %6 = load ptr, ptr %5, align 8, !tbaa !18
  %fh2.i = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 2
  store ptr %6, ptr %fh2.i, align 8, !tbaa !36
  %current_stack_frame.i = getelementptr inbounds %struct.fiber_header, ptr %6, i64 0, i32 1
  %7 = load ptr, ptr %current_stack_frame.i, align 8, !tbaa !37
  %call_parent.i = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 3
  store ptr %7, ptr %call_parent.i, align 8, !tbaa !39
  store ptr %__cilkrts_sf, ptr %current_stack_frame.i, align 8, !tbaa !37
  %itercount1 = sub i64 %end.ls1, %__begin.0.start.ls1
  %8 = icmp ugt i64 %itercount1, %grainsize.ls1
  br i1 %8, label %.lr.ph.preheader, label %pfor.body.ls1.preheader

.lr.ph.preheader:                                 ; preds = %__cilkrts_enter_frame.exit
  %ctx.i = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 4
  %9 = call ptr @llvm.frameaddress.p0(i32 0)
  %10 = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 4, i64 2
  br label %.lr.ph

pfor.body.ls1.preheader:                          ; preds = %.split.split, %__cilkrts_enter_frame.exit
  %__begin.0.ls1.dac.lcssa = phi i64 [ %__begin.0.start.ls1, %__cilkrts_enter_frame.exit ], [ %miditer, %.split.split ]
  %11 = ptrtoint ptr %sum0.ls1 to i64
  br label %pfor.body.ls1

.lr.ph:                                           ; preds = %.split.split, %.lr.ph.preheader
  %itercount3 = phi i64 [ %itercount, %.split.split ], [ %itercount1, %.lr.ph.preheader ]
  %__begin.0.ls1.dac2 = phi i64 [ %miditer, %.split.split ], [ %__begin.0.start.ls1, %.lr.ph.preheader ]
  %halfcount = lshr i64 %itercount3, 1
  %miditer = add nuw nsw i64 %halfcount, %__begin.0.ls1.dac2
  store ptr %9, ptr %ctx.i, align 8
  %12 = call ptr @llvm.stacksave()
  store ptr %12, ptr %10, align 8
  %13 = call i32 @llvm.eh.sjlj.setjmp(ptr nonnull %ctx.i)
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %.lr.ph.split, label %.split.split

.lr.ph.split:                                     ; preds = %.lr.ph
  call fastcc void @reducer_stuff.outline_pfor.cond.ls1.outline_.split.otd1(i64 %__begin.0.ls1.dac2, i64 %miditer, i64 %grainsize.ls1, ptr %sum0.ls1) #8
  br label %.split.split

.split.split:                                     ; preds = %.lr.ph.split, %.lr.ph
  %itercount = sub i64 %end.ls1, %miditer
  %15 = icmp ugt i64 %itercount, %grainsize.ls1
  br i1 %15, label %.lr.ph, label %pfor.body.ls1.preheader

pfor.body.ls1:                                    ; preds = %pfor.inc.ls1, %pfor.body.ls1.preheader
  %__begin.0.ls1 = phi i64 [ %inc.ls1, %pfor.inc.ls1 ], [ %__begin.0.ls1.dac.lcssa, %pfor.body.ls1.preheader ]
  %call.ls1 = tail call i64 @f(i64 noundef %__begin.0.ls1) #8
  %and.ls1 = and i64 %call.ls1, 3
  %cond.ls1 = icmp eq i64 %and.ls1, 0
  br i1 %cond.ls1, label %sw.bb.ls1, label %pfor.inc.ls1

sw.bb.ls1:                                        ; preds = %pfor.body.ls1
  %shr.ls1 = ashr i64 %call.ls1, 2
  %16 = load i8, ptr @__cilkrts_need_to_cilkify, align 1, !tbaa !14, !range !16, !noundef !17
  %tobool.not.i5 = icmp eq i8 %16, 0
  br i1 %tobool.not.i5, label %if.end.i, label %__cilkrts_reducer_lookup.exit

if.end.i:                                         ; preds = %sw.bb.ls1
  %17 = tail call align 8 ptr @llvm.threadlocal.address.p0(ptr align 8 @__cilkrts_tls_worker)
  %18 = load ptr, ptr %17, align 8, !tbaa !18
  %hyper_table.i.i.i = getelementptr inbounds %struct.__cilkrts_worker, ptr %18, i64 0, i32 1
  %19 = load ptr, ptr %hyper_table.i.i.i, align 8, !tbaa !20
  %cmp.i.i.i = icmp eq ptr %19, null
  br i1 %cmp.i.i.i, label %if.then.i.i.i, label %get_hyper_table.exit.i

if.then.i.i.i:                                    ; preds = %if.end.i
  %call.i.i.i = tail call ptr @__cilkrts_local_hyper_table_alloc() #8
  store ptr %call.i.i.i, ptr %hyper_table.i.i.i, align 8, !tbaa !20
  br label %get_hyper_table.exit.i

get_hyper_table.exit.i:                           ; preds = %if.then.i.i.i, %if.end.i
  %20 = phi ptr [ %call.i.i.i, %if.then.i.i.i ], [ %19, %if.end.i ]
  %21 = load i32, ptr %20, align 8, !tbaa !22
  %cmp.i.i = icmp ult i32 %21, 8
  br i1 %cmp.i.i, label %if.then.i.i, label %find_hyperobject.exit.i

if.then.i.i:                                      ; preds = %get_hyper_table.exit.i
  %buckets1.i.i.i = getelementptr inbounds %struct.local_hyper_table, ptr %20, i64 0, i32 3
  %22 = load ptr, ptr %buckets1.i.i.i, align 8, !tbaa !24
  %occupancy2.i.i.i = getelementptr inbounds %struct.local_hyper_table, ptr %20, i64 0, i32 1
  %23 = load i32, ptr %occupancy2.i.i.i, align 4, !tbaa !25
  %24 = zext i32 %23 to i64
  br label %for.cond.i.i.i

for.cond.i.i.i:                                   ; preds = %for.body.i.i.i, %if.then.i.i
  %indvars.iv.i.i.i = phi i64 [ %26, %for.body.i.i.i ], [ %24, %if.then.i.i ]
  %25 = trunc i64 %indvars.iv.i.i.i to i32
  %cmp.i.i13.i = icmp slt i32 %25, 1
  br i1 %cmp.i.i13.i, label %if.end6.i, label %for.body.i.i.i

for.body.i.i.i:                                   ; preds = %for.cond.i.i.i
  %26 = add nsw i64 %indvars.iv.i.i.i, -1
  %arrayidx.i.i.i = getelementptr inbounds %struct.bucket, ptr %22, i64 %26
  %27 = load i64, ptr %arrayidx.i.i.i, align 8, !tbaa !26
  %cmp4.i.i.i = icmp eq i64 %27, %11
  br i1 %cmp4.i.i.i, label %if.then5.i6, label %for.cond.i.i.i, !llvm.loop !40

find_hyperobject.exit.i:                          ; preds = %get_hyper_table.exit.i
  %call1.i.i = tail call ptr @__cilkrts_find_hyperobject_hash(ptr noundef nonnull %20, i64 noundef %11) #8
  %tobool2.not.i = icmp eq ptr %call1.i.i, null
  br i1 %tobool2.not.i, label %if.end6.i, label %if.then5.i6, !prof !31

if.then5.i6:                                      ; preds = %find_hyperobject.exit.i, %for.body.i.i.i
  %retval.0.i19.i = phi ptr [ %call1.i.i, %find_hyperobject.exit.i ], [ %arrayidx.i.i.i, %for.body.i.i.i ]
  %value.i = getelementptr inbounds %struct.bucket, ptr %retval.0.i19.i, i64 0, i32 1
  %28 = load ptr, ptr %value.i, align 8, !tbaa !32
  br label %__cilkrts_reducer_lookup.exit

if.end6.i:                                        ; preds = %find_hyperobject.exit.i, %for.cond.i.i.i
  %call7.i = tail call ptr @__cilkrts_insert_new_view(ptr noundef nonnull %20, i64 noundef %11, i64 noundef 8, ptr noundef nonnull @identity_long, ptr noundef nonnull @reduce_long) #8
  br label %__cilkrts_reducer_lookup.exit

__cilkrts_reducer_lookup.exit:                    ; preds = %if.end6.i, %if.then5.i6, %sw.bb.ls1
  %retval.1.i = phi ptr [ %sum0.ls1, %sw.bb.ls1 ], [ %28, %if.then5.i6 ], [ %call7.i, %if.end6.i ]
  %29 = load i64, ptr %retval.1.i, align 8, !tbaa !8
  %add5.ls1 = add nsw i64 %29, %shr.ls1
  store i64 %add5.ls1, ptr %retval.1.i, align 8, !tbaa !8
  br label %pfor.inc.ls1

pfor.inc.ls1:                                     ; preds = %__cilkrts_reducer_lookup.exit, %pfor.body.ls1
  %inc.ls1 = add nuw nsw i64 %__begin.0.ls1, 1
  %exitcond.not.ls1 = icmp eq i64 %inc.ls1, %end.ls1
  br i1 %exitcond.not.ls1, label %pfor.cond.cleanup.ls1, label %pfor.body.ls1, !llvm.loop !41

pfor.cond.cleanup.ls1:                            ; preds = %pfor.inc.ls1
  %30 = load i32, ptr %__cilkrts_sf, align 8, !tbaa !33
  %and.i = and i32 %30, 2
  %tobool.not.i = icmp eq i32 %and.i, 0
  br i1 %tobool.not.i, label %pfor.cond.cleanup.ls1.split, label %if.then4.i

if.then4.i:                                       ; preds = %pfor.cond.cleanup.ls1
  %ctx.i4 = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 4
  %31 = call ptr @llvm.frameaddress.p0(i32 0)
  store ptr %31, ptr %ctx.i4, align 8
  %32 = call ptr @llvm.stacksave()
  %33 = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 4, i64 2
  store ptr %32, ptr %33, align 8
  %34 = call i32 @llvm.eh.sjlj.setjmp(ptr nonnull %ctx.i4)
  %cmp.i = icmp eq i32 %34, 0
  br i1 %cmp.i, label %if.then5.i, label %if.then4.i.pfor.cond.cleanup.ls1.split_crit_edge

if.then4.i.pfor.cond.cleanup.ls1.split_crit_edge: ; preds = %if.then4.i
  %.pre = load i32, ptr %__cilkrts_sf, align 8, !tbaa !33
  br label %pfor.cond.cleanup.ls1.split

if.then5.i:                                       ; preds = %if.then4.i
  call void @__cilkrts_sync(ptr noundef nonnull %__cilkrts_sf) #12
  unreachable

pfor.cond.cleanup.ls1.split:                      ; preds = %if.then4.i.pfor.cond.cleanup.ls1.split_crit_edge, %pfor.cond.cleanup.ls1
  %35 = phi i32 [ %.pre, %if.then4.i.pfor.cond.cleanup.ls1.split_crit_edge ], [ %30, %pfor.cond.cleanup.ls1 ]
  %36 = load ptr, ptr %fh2.i, align 8, !tbaa !36
  %37 = load ptr, ptr %36, align 128, !tbaa !43
  %38 = load ptr, ptr %call_parent.i, align 8, !tbaa !39
  %current_stack_frame.i.i = getelementptr inbounds %struct.fiber_header, ptr %36, i64 0, i32 1
  store ptr %38, ptr %current_stack_frame.i.i, align 8, !tbaa !37
  store ptr null, ptr %call_parent.i, align 8, !tbaa !39
  %and3.i.i = and i32 %35, 128
  %tobool4.not.i.i = icmp eq i32 %and3.i.i, 0
  br i1 %tobool4.not.i.i, label %if.end.i.i, label %if.then.i.i12

if.then.i.i12:                                    ; preds = %pfor.cond.cleanup.ls1.split
  %g.i.i = getelementptr inbounds %struct.__cilkrts_worker, ptr %37, i64 0, i32 2
  %39 = load ptr, ptr %g.i.i, align 16, !tbaa !44
  %ctx.i.i.i = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 4
  %40 = call ptr @llvm.frameaddress.p0(i32 0)
  store ptr %40, ptr %ctx.i.i.i, align 8
  %41 = call ptr @llvm.stacksave()
  %42 = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 4, i64 2
  store ptr %41, ptr %42, align 8
  %43 = call i32 @llvm.eh.sjlj.setjmp(ptr nonnull %ctx.i.i.i)
  %cmp.i.i.i11 = icmp eq i32 %43, 0
  br i1 %cmp.i.i.i11, label %if.then.i.i.i13, label %uncilkify.exit.i.i

if.then.i.i.i13:                                  ; preds = %if.then.i.i12
  call void @__cilkrts_internal_exit_cilkified_root(ptr noundef %39, ptr noundef nonnull %__cilkrts_sf) #8
  br label %uncilkify.exit.i.i

uncilkify.exit.i.i:                               ; preds = %if.then.i.i.i13, %if.then.i.i12
  %44 = load i32, ptr %__cilkrts_sf, align 8, !tbaa !33
  br label %if.end.i.i

if.end.i.i:                                       ; preds = %uncilkify.exit.i.i, %pfor.cond.cleanup.ls1.split
  %flags.0.i.i = phi i32 [ %44, %uncilkify.exit.i.i ], [ %35, %pfor.cond.cleanup.ls1.split ]
  %and8.i.i = and i32 %flags.0.i.i, 1
  %tobool9.not.i.i = icmp eq i32 %and8.i.i, 0
  br i1 %tobool9.not.i.i, label %__cilk_parent_epilogue.exit, label %cond.end15.i.i

cond.end15.i.i:                                   ; preds = %if.end.i.i
  call void @Cilk_set_return(ptr noundef %37) #8
  br label %__cilk_parent_epilogue.exit

__cilk_parent_epilogue.exit:                      ; preds = %cond.end15.i.i, %if.end.i.i
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.value(metadata, metadata, metadata) #4

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(inaccessiblemem: read)
declare nonnull ptr @llvm.threadlocal.address.p0(ptr nonnull) #5

declare ptr @__cilkrts_local_hyper_table_alloc(...) local_unnamed_addr #2

declare ptr @__cilkrts_find_hyperobject_hash(ptr noundef, i64 noundef) local_unnamed_addr #2

declare ptr @__cilkrts_insert_new_view(ptr noundef, i64 noundef, i64 noundef, ptr noundef, ptr noundef) local_unnamed_addr #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare ptr @llvm.frameaddress.p0(i32 immarg) #6

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave() #7

; Function Attrs: nounwind
declare i32 @llvm.eh.sjlj.setjmp(ptr) #8

declare void @__cilkrts_internal_invoke_cilkified_root(ptr noundef) local_unnamed_addr #2

; Function Attrs: noreturn nounwind
declare void @__cilkrts_sync(ptr noundef) local_unnamed_addr #9

declare void @__cilkrts_internal_exit_cilkified_root(ptr noundef, ptr noundef) local_unnamed_addr #2

declare void @Cilk_set_return(ptr noundef) local_unnamed_addr #2

declare void @Cilk_exception_handler(ptr noundef, ptr noundef) local_unnamed_addr #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umin.i64(i64, i64) #4

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #4

; Function Attrs: alwaysinline nounwind
declare void @__cilkrts_reducer_register_64(ptr, i64, ptr, ptr) local_unnamed_addr #10

; Function Attrs: alwaysinline nounwind
declare void @__cilkrts_reducer_unregister(ptr) local_unnamed_addr #10

; Function Attrs: noinline nounwind memory(readwrite) uwtable
define internal fastcc void @reducer_stuff.outline_pfor.cond.ls1.outline_.split.otd1(i64 %__begin.0.ls1.dac2.otd1, i64 %miditer.otd1, i64 %grainsize.ls1.otd1, ptr align 16 %sum0.ls1.otd1) unnamed_addr #11 {
.split.split.otd1:
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  store <2 x i32> <i32 0, i32 2179696>, ptr %__cilkrts_sf, align 8, !tbaa !12
  %0 = tail call align 8 ptr @llvm.threadlocal.address.p0(ptr align 8 @__cilkrts_current_fh)
  %1 = load ptr, ptr %0, align 8, !tbaa !18
  %fh1.i = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 2
  store ptr %1, ptr %fh1.i, align 8, !tbaa !36
  %current_stack_frame.i = getelementptr inbounds %struct.fiber_header, ptr %1, i64 0, i32 1
  %2 = load ptr, ptr %current_stack_frame.i, align 8, !tbaa !37
  %call_parent.i = getelementptr inbounds %struct.__cilkrts_stack_frame, ptr %__cilkrts_sf, i64 0, i32 3
  store ptr %2, ptr %call_parent.i, align 8, !tbaa !39
  store ptr %__cilkrts_sf, ptr %current_stack_frame.i, align 8, !tbaa !37
  %3 = load ptr, ptr %1, align 128, !tbaa !43
  store i32 4, ptr %__cilkrts_sf, align 8, !tbaa !33
  %tail1.i = getelementptr inbounds %struct.__cilkrts_worker, ptr %3, i64 0, i32 6
  %4 = load atomic i64, ptr %tail1.i monotonic, align 16
  %5 = inttoptr i64 %4 to ptr
  %incdec.ptr.i = getelementptr inbounds ptr, ptr %5, i64 1
  store ptr %2, ptr %5, align 8, !tbaa !18
  %6 = ptrtoint ptr %incdec.ptr.i to i64
  store atomic i64 %6, ptr %tail1.i release, align 16
  tail call fastcc void @reducer_stuff.outline_pfor.cond.ls1(i64 %__begin.0.ls1.dac2.otd1, i64 %miditer.otd1, i64 %grainsize.ls1.otd1, ptr %sum0.ls1.otd1) #8
  %7 = load ptr, ptr %fh1.i, align 8, !tbaa !36
  %8 = load ptr, ptr %7, align 128, !tbaa !43
  %9 = load ptr, ptr %call_parent.i, align 8, !tbaa !39
  %current_stack_frame.i.i = getelementptr inbounds %struct.fiber_header, ptr %7, i64 0, i32 1
  store ptr %9, ptr %current_stack_frame.i.i, align 8, !tbaa !37
  store ptr null, ptr %call_parent.i, align 8, !tbaa !39
  %tail2.i.i = getelementptr inbounds %struct.__cilkrts_worker, ptr %8, i64 0, i32 6
  %10 = load atomic i64, ptr %tail2.i.i monotonic, align 16
  %11 = inttoptr i64 %10 to ptr
  %incdec.ptr.i.i = getelementptr inbounds ptr, ptr %11, i64 -1
  %12 = ptrtoint ptr %incdec.ptr.i.i to i64
  store atomic i64 %12, ptr %tail2.i.i seq_cst, align 16
  %exc4.i.i = getelementptr inbounds %struct.__cilkrts_worker, ptr %8, i64 0, i32 8
  %13 = load atomic i64, ptr %exc4.i.i seq_cst, align 64
  %14 = inttoptr i64 %13 to ptr
  %15 = load i32, ptr %__cilkrts_sf, align 8, !tbaa !33
  %and6.i.i = and i32 %15, -5
  store i32 %and6.i.i, ptr %__cilkrts_sf, align 8, !tbaa !33
  %cmp.i.i = icmp ult ptr %incdec.ptr.i.i, %14
  br i1 %cmp.i.i, label %if.then.i.i, label %__cilk_helper_epilogue.exit, !prof !31

if.then.i.i:                                      ; preds = %.split.split.otd1
  call void @Cilk_exception_handler(ptr noundef nonnull %8, ptr noundef null) #8
  br label %__cilk_helper_epilogue.exit

__cilk_helper_epilogue.exit:                      ; preds = %if.then.i.i, %.split.split.otd1
  ret void
}

attributes #0 = { nounwind uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }
attributes #3 = { nounwind stealable memory(readwrite, argmem: none, inaccessiblemem: none) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }
attributes #4 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nocallback nofree nosync nounwind speculatable willreturn memory(inaccessiblemem: read) }
attributes #6 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #7 = { nocallback nofree nosync nounwind willreturn }
attributes #8 = { nounwind }
attributes #9 = { noreturn nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }
attributes #10 = { alwaysinline nounwind }
attributes #11 = { noinline nounwind memory(readwrite) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }
attributes #12 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6}
!llvm.ident = !{!7, !7}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{i32 7, !"Dwarf Version", i32 4}
!6 = !{i32 2, !"Debug Info Version", i32 3}
!7 = !{!"clang version 16.0.6 (git@github.com:OpenCilk/opencilk-project.git aec81473380a60ff86b0fdc535600ff27fc1534a)"}
!8 = !{!9, !9, i64 0}
!9 = !{!"long", !10, i64 0}
!10 = !{!"omnipotent char", !11, i64 0}
!11 = !{!"Simple C/C++ TBAA"}
!12 = !{!13, !13, i64 0}
!13 = !{!"int", !10, i64 0}
!14 = !{!15, !15, i64 0}
!15 = !{!"_Bool", !10, i64 0}
!16 = !{i8 0, i8 2}
!17 = !{}
!18 = !{!19, !19, i64 0}
!19 = !{!"any pointer", !10, i64 0}
!20 = !{!21, !19, i64 8}
!21 = !{!"__cilkrts_worker", !13, i64 0, !19, i64 8, !19, i64 16, !19, i64 24, !19, i64 32, !19, i64 40, !10, i64 48, !10, i64 64, !10, i64 128, !19, i64 136}
!22 = !{!23, !13, i64 0}
!23 = !{!"local_hyper_table", !13, i64 0, !13, i64 4, !13, i64 8, !19, i64 16}
!24 = !{!23, !19, i64 16}
!25 = !{!23, !13, i64 4}
!26 = !{!27, !9, i64 0}
!27 = !{!"bucket", !9, i64 0, !28, i64 8}
!28 = !{!"reducer_base", !19, i64 0, !19, i64 8}
!29 = distinct !{!29, !30}
!30 = !{!"llvm.loop.mustprogress"}
!31 = !{!"branch_weights", i32 1, i32 2000}
!32 = !{!27, !19, i64 8}
!33 = !{!34, !13, i64 0}
!34 = !{!"__cilkrts_stack_frame", !13, i64 0, !13, i64 4, !19, i64 8, !19, i64 16, !10, i64 24, !19, i64 64}
!35 = !{!34, !13, i64 4}
!36 = !{!34, !19, i64 8}
!37 = !{!38, !19, i64 8}
!38 = !{!"fiber_header", !19, i64 0, !19, i64 8, !19, i64 16}
!39 = !{!34, !19, i64 16}
!40 = distinct !{!40, !30}
!41 = distinct !{!41, !42}
!42 = !{!"tapir.loop.spawn.strategy", i32 0}
!43 = !{!38, !19, i64 0}
!44 = !{!21, !19, i64 16}
