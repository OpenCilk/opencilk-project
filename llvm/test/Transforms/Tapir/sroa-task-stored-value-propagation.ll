; Check that SROA respects stores in tasks when propagating stored values to loads, even when values escape into readonly nocapture calls.
;
; RUN: opt < %s -passes="sroa" -S | FileCheck %s
; ModuleID = 'example.c'
source_filename = "example.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [28 x i8] c"Expect output to be 10: %d\0A\00", align 1
@__csi_unit_func_base_id = internal global i64 0
@__csi_unit_func_exit_base_id = internal global i64 0
@__csi_unit_loop_base_id = internal global i64 0
@__csi_unit_loop_exit_base_id = internal global i64 0
@__csi_unit_bb_base_id = internal global i64 0
@__csi_unit_callsite_base_id = internal global i64 0
@__csi_unit_load_base_id = internal global i64 0
@__csi_unit_store_base_id = internal global i64 0
@__csi_unit_alloca_base_id = internal global i64 0
@__csi_unit_detach_base_id = internal global i64 0
@__csi_unit_task_base_id = internal global i64 0
@__csi_unit_task_exit_base_id = internal global i64 0
@__csi_unit_detach_continue_base_id = internal global i64 0
@__csi_unit_sync_base_id = internal global i64 0
@__csi_unit_allocfn_base_id = internal global i64 0
@__csi_unit_free_base_id = internal global i64 0
@__csi_func_id_f = weak global i64 -1
@__csi_func_id_printf = weak global i64 -1
@__csi_unit_filename_example.c = private unnamed_addr constant [10 x i8] c"example.c\00"
@__csi_unit_function_name_f = private unnamed_addr constant [2 x i8] c"f\00"
@__csi_unit_function_name_main = private unnamed_addr constant [5 x i8] c"main\00"
@__csi_unit_fed_table__csi_unit_func_base_id = internal global [2 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_func_exit_base_id = internal global [2 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_loop_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_loop_exit_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_bb_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_callsite_base_id = internal global [4 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_load_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_store_base_id = internal global [2 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_detach_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_task_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr null, i32 -1, i32 -1, ptr null }]
@__csi_unit_fed_table__csi_unit_task_exit_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_detach_continue_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr null, i32 -1, i32 -1, ptr null }]
@__csi_unit_fed_table__csi_unit_sync_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_alloca_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_f, i32 -1, i32 -1, ptr @__csi_unit_filename_example.c }]
@__csi_unit_fed_table__csi_unit_allocfn_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_free_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_object_name_y = private unnamed_addr constant [2 x i8] c"y\00"
@__csi_unit_obj_table = internal global [1 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr @__csi_unit_object_name_y, i32 -1, ptr null }]
@__csi_unit_obj_table.1 = internal global [2 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr @__csi_unit_object_name_y, i32 -1, ptr null }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_y, i32 -1, ptr null }]
@__csi_unit_obj_table.2 = internal global [1 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr @__csi_unit_object_name_y, i32 -1, ptr null }]
@__csi_unit_obj_table.3 = internal global [0 x { ptr, i32, ptr }] zeroinitializer
@__csi_func_id_main = weak global i64 -1
@__csi_unit_fed_tables = internal global [16 x { i64, ptr, ptr }] [{ i64, ptr, ptr } { i64 2, ptr @__csi_unit_func_base_id, ptr @__csi_unit_fed_table__csi_unit_func_base_id }, { i64, ptr, ptr } { i64 2, ptr @__csi_unit_func_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_func_exit_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_loop_base_id, ptr @__csi_unit_fed_table__csi_unit_loop_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_loop_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_loop_exit_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_bb_base_id, ptr @__csi_unit_fed_table__csi_unit_bb_base_id }, { i64, ptr, ptr } { i64 4, ptr @__csi_unit_callsite_base_id, ptr @__csi_unit_fed_table__csi_unit_callsite_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_load_base_id, ptr @__csi_unit_fed_table__csi_unit_load_base_id }, { i64, ptr, ptr } { i64 2, ptr @__csi_unit_store_base_id, ptr @__csi_unit_fed_table__csi_unit_store_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_detach_base_id, ptr @__csi_unit_fed_table__csi_unit_detach_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_task_base_id, ptr @__csi_unit_fed_table__csi_unit_task_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_task_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_task_exit_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_detach_continue_base_id, ptr @__csi_unit_fed_table__csi_unit_detach_continue_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_sync_base_id, ptr @__csi_unit_fed_table__csi_unit_sync_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_alloca_base_id, ptr @__csi_unit_fed_table__csi_unit_alloca_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_allocfn_base_id, ptr @__csi_unit_fed_table__csi_unit_allocfn_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_free_base_id, ptr @__csi_unit_fed_table__csi_unit_free_base_id }]
@__csi_unit_obj_tables = internal global [4 x { i64, ptr }] [{ i64, ptr } { i64 1, ptr @__csi_unit_obj_table }, { i64, ptr } { i64 2, ptr @__csi_unit_obj_table.1 }, { i64, ptr } { i64 1, ptr @__csi_unit_obj_table.2 }, { i64, ptr } { i64 0, ptr @__csi_unit_obj_table.3 }]
@0 = private unnamed_addr constant [10 x i8] c"example.c\00", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 0, ptr @csirt.unit_ctor, ptr null }]

; Function Attrs: nofree nosync nounwind memory(readwrite, argmem: none, errnomem: none) uwtable
define dso_local i32 @f(i32 noundef %a, i32 noundef %x) local_unnamed_addr #0 {
entry:
  %y = alloca i32, align 4
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = load i64, ptr @__csi_unit_func_base_id, align 8, !invariant.load !5
  %1 = add i64 %0, 0
  %2 = call ptr @llvm.frameaddress.p0(i32 0)
  %3 = call ptr @llvm.stacksave.p0()
  call void @__csan_func_entry(i64 %1, ptr %2, ptr %3, i64 257)
  %4 = load i64, ptr @__csi_unit_alloca_base_id, align 8, !invariant.load !5
  %5 = add i64 %4, 0
  call void @__csi_after_alloca(i64 %5, ptr %y, i64 4, i64 1)
  %6 = load i64, ptr @__csi_unit_detach_base_id, align 8, !invariant.load !5
  %7 = add i64 %6, 0
  %8 = load i64, ptr @__csi_unit_task_base_id, align 8, !invariant.load !5
  %9 = add i64 %8, 0
  %10 = load i64, ptr @__csi_unit_task_exit_base_id, align 8, !invariant.load !5
  %11 = add i64 %10, 0
  %12 = load i64, ptr @__csi_unit_detach_continue_base_id, align 8, !invariant.load !5
  %13 = add i64 %12, 0
  %cmp = icmp slt i32 %a, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %add = add nsw i32 %x, 1
  br label %return

if.end:                                           ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %y)
  %div14 = lshr i32 %a, 1
  %14 = load i64, ptr @__csi_unit_callsite_base_id, align 8, !invariant.load !5
  %15 = add i64 %14, 0
  %16 = load i64, ptr @__csi_func_id_f, align 8
  call void @__csan_before_call(i64 %15, i64 %16, i8 0, i64 0)
  %call = tail call i32 @f(i32 noundef %div14, i32 noundef 0)
  call void @__csan_after_call(i64 %15, i64 %16, i8 0, i64 0)
  br label %if.end.split

if.end.split:                                     ; preds = %if.end
  %17 = load i64, ptr @__csi_unit_store_base_id, align 8, !invariant.load !5
  %18 = add i64 %17, 0
  call void @__csan_store(i64 %18, ptr %y, i32 4, i64 4)
  store i32 %call, ptr %y, align 4, !tbaa !6
  %rem = and i32 %a, 1
  %tobool.not = icmp eq i32 %rem, 0
  br i1 %tobool.not, label %if.end4, label %if.then1.tf

; CHECK: if.end.split:
; CHECK: store i32 %call, ptr %y,
; CHECK: br i1 %tobool.not,

if.then1.tf:                                      ; preds = %if.end.split
  call void @__csan_detach(i64 %7, i32 0, i64 0)
  detach within %syncreg, label %det.achd, label %if.then1.tf.if.end4_crit_edge

if.then1.tf.if.end4_crit_edge:                    ; preds = %det.achd.split, %if.then1.tf
  call void @__csan_detach_continue(i64 %13, i64 %7, i32 0, i64 0)
  br label %if.end4

; CHECK: if.then1.tf.if.end4_crit_edge:
; CHECK-NOT: phi
; CHECK: call void @__csan_detach_continue

det.achd:                                         ; preds = %if.then1.tf
  %19 = call ptr @llvm.task.frameaddress(i32 0)
  %20 = call ptr @llvm.stacksave.p0()
  call void @__csan_task(i64 %9, i64 %7, ptr %19, ptr %20, i64 0)
  %21 = load i64, ptr @__csi_unit_callsite_base_id, align 8, !invariant.load !5
  %22 = add i64 %21, 1
  %23 = load i64, ptr @__csi_func_id_f, align 8
  call void @__csan_before_call(i64 %22, i64 %23, i8 0, i64 0)
  %call3 = tail call i32 @f(i32 noundef %div14, i32 noundef %call)
  call void @__csan_after_call(i64 %22, i64 %23, i8 0, i64 0)
  br label %det.achd.split

det.achd.split:                                   ; preds = %det.achd
  %24 = load i64, ptr @__csi_unit_store_base_id, align 8, !invariant.load !5
  %25 = add i64 %24, 1
  call void @__csan_store(i64 %25, ptr %y, i32 4, i64 4)
  store i32 %call3, ptr %y, align 4, !tbaa !6
  call void @__csan_task_exit(i64 %11, i64 %9, i64 %7, i32 0, i64 0)
  reattach within %syncreg, label %if.then1.tf.if.end4_crit_edge

if.end4:                                          ; preds = %if.then1.tf.if.end4_crit_edge, %if.end.split
  %inc = add nsw i32 %x, 1
  %26 = load i64, ptr @__csi_unit_sync_base_id, align 8, !invariant.load !5
  %27 = add i64 %26, 0
  call void @__csan_sync(i64 %27, i32 0)
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %if.end4
  %28 = load i64, ptr @__csi_unit_load_base_id, align 8, !invariant.load !5
  %29 = add i64 %28, 0
  call void @__csan_load(i64 %29, ptr %y, i32 4, i64 4)
  %y.0.load17 = load i32, ptr %y, align 4
  %add5 = add nsw i32 %inc, %y.0.load17
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %y)
  br label %return

return:                                           ; preds = %sync.continue, %if.then
  %retval.0 = phi i32 [ %add, %if.then ], [ %add5, %sync.continue ]
  %30 = load i64, ptr @__csi_unit_func_exit_base_id, align 8, !invariant.load !5
  %31 = add i64 %30, 0
  call void @__csan_func_exit(i64 %31, i64 %1, i64 1)
  ret i32 %retval.0
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: nofree nounwind uwtable
define dso_local noundef i32 @main() local_unnamed_addr #3 {
entry:
  %0 = load i64, ptr @__csi_unit_func_base_id, align 8, !invariant.load !5
  %1 = add i64 %0, 1
  %2 = call ptr @llvm.frameaddress.p0(i32 0)
  %3 = call ptr @llvm.stacksave.p0()
  call void @__csan_func_entry(i64 %1, ptr %2, ptr %3, i64 0)
  %4 = load i64, ptr @__csi_unit_callsite_base_id, align 8, !invariant.load !5
  %5 = add i64 %4, 3
  %6 = load i64, ptr @__csi_func_id_f, align 8
  call void @__csan_before_call(i64 %5, i64 %6, i8 0, i64 0)
  %call = tail call i32 @f(i32 noundef 10, i32 noundef 0)
  call void @__csan_after_call(i64 %5, i64 %6, i8 0, i64 0)
  br label %entry.split

entry.split:                                      ; preds = %entry
  %7 = load i64, ptr @__csi_unit_callsite_base_id, align 8, !invariant.load !5
  %8 = add i64 %7, 2
  %9 = load i64, ptr @__csi_func_id_printf, align 8
  %call1 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str, i32 noundef %call)
  call void (i64, i64, i8, i64, i32, ptr, ...) @__csan_printf(i64 %8, i64 %9, i8 0, i64 0, i32 %call1, ptr @.str, i32 %call)
  %10 = load i64, ptr @__csi_unit_func_exit_base_id, align 8, !invariant.load !5
  %11 = add i64 %10, 1
  call void @__csan_func_exit(i64 %11, i64 %1, i64 0)
  ret i32 0
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr noundef readonly captures(none), ...) local_unnamed_addr #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_func_entry(i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_func_exit(i64, i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_before_loop(i64, i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_after_loop(i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_loopbody_entry(i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_loopbody_exit(i64, i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_after_alloca(i64, ptr readnone captures(none), i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_before_allocfn(i64, i64, i64, i64, ptr, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_after_allocfn(i64, ptr, i64, i64, i64, ptr, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_before_free(i64, ptr, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csi_after_free(i64, ptr, i64) #5

define internal void @__csi_init_callsite_to_function() {
  %1 = load i64, ptr @__csi_unit_func_base_id, align 8
  %2 = add i64 %1, 1
  store i64 %2, ptr @__csi_func_id_main, align 8
  %3 = add i64 %1, 0
  store i64 %3, ptr @__csi_func_id_f, align 8
  ret void
}

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_func_entry(i64, ptr readnone captures(none), ptr readnone, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_func_exit(i64, i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_load(i64, ptr readnone captures(none), i32, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_store(i64, ptr readnone captures(none), i32, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_large_load(i64, ptr readnone captures(none), i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_large_store(i64, ptr readnone captures(none), i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_before_call(i64, i64, i8, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_after_call(i64, i64, i8, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_detach(i64, i32, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_task(i64, i64, ptr readnone captures(none), ptr readnone captures(none), i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_task_exit(i64, i64, i64, i32, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_detach_continue(i64, i64, i32, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_sync(i64, i32) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_after_allocfn(i64, ptr readnone captures(none), i64, i64, i64, ptr readnone captures(none), i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_after_free(i64, ptr readnone captures(none), i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__cilksan_disable_checking() #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__cilksan_enable_checking() #5

; Function Attrs: nounwind memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @__csan_get_MAAP(ptr captures(none), i64, i8) #6

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_set_MAAP(i8, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_before_loop(i64, i64, i64) #5

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_after_loop(i64, i8, i64) #5

; Function Attrs: nounwind willreturn
declare ptr @llvm.task.frameaddress(i32) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave.p0() #8

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare ptr @llvm.frameaddress.p0(i32 immarg) #9

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_printf(i64, i64, i8, i64, i32, ptr, ...) #5

define internal void @csirt.unit_ctor() {
  call void @__csanrt_unit_init(ptr @0, ptr @__csi_unit_fed_tables, ptr @__csi_unit_obj_tables, ptr @__csi_init_callsite_to_function)
  ret void
}

declare void @__csanrt_unit_init(ptr, ptr, ptr, ptr)

attributes #0 = { nofree nosync nounwind memory(readwrite, argmem: none, errnomem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { nofree nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nofree nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nounwind memory(argmem: read, inaccessiblemem: readwrite) }
attributes #6 = { nounwind memory(argmem: readwrite, inaccessiblemem: readwrite) }
attributes #7 = { nounwind willreturn }
attributes #8 = { nocallback nofree nosync nounwind willreturn }
attributes #9 = { nocallback nofree nosync nounwind willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 21.1.3 (git@github.com:OpenCilk/opencilk-project.git 6c10bb2c4635d3c3e07eaff17ecdd20da28f5eb8)"}
!5 = !{}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
