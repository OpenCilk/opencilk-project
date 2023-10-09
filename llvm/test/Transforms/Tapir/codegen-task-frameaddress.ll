; RUN: llc < %s | FileCheck %s
; REQUIRES: x86-registered-target
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

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
@__csi_unit_filename_issue198.cpp = private unnamed_addr constant [13 x i8] c"issue198.cpp\00"
@__csi_unit_function_name_main = private unnamed_addr constant [5 x i8] c"main\00"
@__csi_unit_fed_table__csi_unit_func_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }]
@__csi_unit_fed_table__csi_unit_func_exit_base_id = internal global [2 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }]
@__csi_unit_fed_table__csi_unit_loop_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_loop_exit_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_bb_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_callsite_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_load_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }]
@__csi_unit_fed_table__csi_unit_store_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }]
@__csi_unit_fed_table__csi_unit_detach_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }]
@__csi_unit_fed_table__csi_unit_task_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr null, i32 -1, i32 -1, ptr null }]
@__csi_unit_fed_table__csi_unit_task_exit_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }]
@__csi_unit_fed_table__csi_unit_detach_continue_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr null, i32 -1, i32 -1, ptr null }]
@__csi_unit_fed_table__csi_unit_sync_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }]
@__csi_unit_fed_table__csi_unit_alloca_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_main, i32 -1, i32 -1, ptr @__csi_unit_filename_issue198.cpp }]
@__csi_unit_fed_table__csi_unit_allocfn_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_free_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_object_name_j = private unnamed_addr constant [2 x i8] c"j\00"
@__csi_unit_obj_table = internal global [1 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr @__csi_unit_object_name_j, i32 -1, ptr null }]
@__csi_unit_obj_table.1 = internal global [1 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr @__csi_unit_object_name_j, i32 -1, ptr null }]
@__csi_unit_obj_table.2 = internal global [1 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr @__csi_unit_object_name_j, i32 -1, ptr null }]
@__csi_unit_obj_table.3 = internal global [0 x { ptr, i32, ptr }] zeroinitializer
@__csi_func_id_main = weak global i64 -1
@__csi_unit_fed_tables = internal global [16 x { i64, ptr, ptr }] [{ i64, ptr, ptr } { i64 1, ptr @__csi_unit_func_base_id, ptr @__csi_unit_fed_table__csi_unit_func_base_id }, { i64, ptr, ptr } { i64 2, ptr @__csi_unit_func_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_func_exit_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_loop_base_id, ptr @__csi_unit_fed_table__csi_unit_loop_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_loop_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_loop_exit_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_bb_base_id, ptr @__csi_unit_fed_table__csi_unit_bb_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_callsite_base_id, ptr @__csi_unit_fed_table__csi_unit_callsite_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_load_base_id, ptr @__csi_unit_fed_table__csi_unit_load_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_store_base_id, ptr @__csi_unit_fed_table__csi_unit_store_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_detach_base_id, ptr @__csi_unit_fed_table__csi_unit_detach_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_task_base_id, ptr @__csi_unit_fed_table__csi_unit_task_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_task_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_task_exit_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_detach_continue_base_id, ptr @__csi_unit_fed_table__csi_unit_detach_continue_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_sync_base_id, ptr @__csi_unit_fed_table__csi_unit_sync_base_id }, { i64, ptr, ptr } { i64 1, ptr @__csi_unit_alloca_base_id, ptr @__csi_unit_fed_table__csi_unit_alloca_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_allocfn_base_id, ptr @__csi_unit_fed_table__csi_unit_allocfn_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_free_base_id, ptr @__csi_unit_fed_table__csi_unit_free_base_id }]
@__csi_unit_obj_tables = internal global [4 x { i64, ptr }] [{ i64, ptr } { i64 1, ptr @__csi_unit_obj_table }, { i64, ptr } { i64 1, ptr @__csi_unit_obj_table.1 }, { i64, ptr } { i64 1, ptr @__csi_unit_obj_table.2 }, { i64, ptr } { i64 0, ptr @__csi_unit_obj_table.3 }]
@0 = private unnamed_addr constant [13 x i8] c"issue198.cpp\00", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 0, ptr @csirt.unit_ctor, ptr null }]

; Function Attrs: mustprogress noinline norecurse optnone uwtable
define dso_local noundef i32 @main() #0 personality ptr @__gcc_personality_v0 {
entry:
  %retval = alloca i32, align 4
  %j = alloca i32, align 4
  %syncreg = call token @llvm.syncregion.start()
  %__init = alloca i32, align 4
  %__limit = alloca i32, align 4
  %__begin = alloca i32, align 4
  %__end = alloca i32, align 4
  %0 = load i64, ptr @__csi_unit_func_base_id, align 8, !invariant.load !6
  %1 = add i64 %0, 0
  %2 = call ptr @llvm.frameaddress.p0(i32 0)
  %3 = call ptr @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, ptr %2, ptr %3, i64 257)
  %4 = load i64, ptr @__csi_unit_alloca_base_id, align 8, !invariant.load !6
  %5 = add i64 %4, 0
  call void @__csi_after_alloca(i64 %5, ptr %j, i64 4, i64 1)
  %6 = load i64, ptr @__csi_unit_detach_base_id, align 8, !invariant.load !6
  %7 = add i64 %6, 0
  %8 = load i64, ptr @__csi_unit_task_base_id, align 8, !invariant.load !6
  %9 = add i64 %8, 0
  %10 = load i64, ptr @__csi_unit_task_exit_base_id, align 8, !invariant.load !6
  %11 = add i64 %10, 0
  %12 = load i64, ptr @__csi_unit_detach_continue_base_id, align 8, !invariant.load !6
  %13 = add i64 %12, 0
  store i32 0, ptr %retval, align 4
  store i32 0, ptr %j, align 4
  store i32 0, ptr %__init, align 4
  store i32 10, ptr %__limit, align 4
  %14 = load i32, ptr %__init, align 4
  %15 = load i32, ptr %__limit, align 4
  %cmp = icmp slt i32 %14, %15
  br i1 %cmp, label %pfor.ph, label %pfor.end

pfor.ph:                                          ; preds = %entry
  store i32 0, ptr %__begin, align 4
  %16 = load i32, ptr %__limit, align 4
  %17 = load i32, ptr %__init, align 4
  %sub = sub nsw i32 %16, %17
  %sub1 = sub nsw i32 %sub, 1
  %div = sdiv i32 %sub1, 1
  %add = add nsw i32 %div, 1
  store i32 %add, ptr %__end, align 4
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  br label %pfor.detach

pfor.detach:                                      ; preds = %pfor.cond
  %18 = load i32, ptr %__init, align 4
  %19 = load i32, ptr %__begin, align 4
  %mul = mul nsw i32 %19, 1
  %add2 = add nsw i32 %18, %mul
  call void @__csan_detach(i64 %7, i32 0, i64 0)
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.detach
  %20 = call ptr @llvm.task.frameaddress(i32 0)
  %21 = call ptr @llvm.stacksave()
  call void @__csan_task(i64 %9, i64 %7, ptr %20, ptr %21, i64 0)
  %i = alloca i32, align 4
  store i32 %add2, ptr %i, align 4
  br label %pfor.body

; CHECK: callq __csan_detach
; CHECK: movq %rbp, %rdx
; CHECK: callq __csan_task

pfor.body:                                        ; preds = %pfor.body.entry
  %22 = load i64, ptr @__csi_unit_load_base_id, align 8, !invariant.load !6
  %23 = add i64 %22, 0
  call void @__csan_load(i64 %23, ptr %j, i32 4, i64 4)
  %24 = load i32, ptr %j, align 4
  %inc = add nsw i32 %24, 1
  %25 = load i64, ptr @__csi_unit_store_base_id, align 8, !invariant.load !6
  %26 = add i64 %25, 0
  call void @__csan_store(i64 %26, ptr %j, i32 4, i64 4)
  store i32 %inc, ptr %j, align 4
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %pfor.body
  call void @__csan_task_exit(i64 %11, i64 %9, i64 %7, i32 0, i64 0)
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.detach
  call void @__csan_detach_continue(i64 %13, i64 %7, i32 0, i64 0)
  %27 = load i32, ptr %__begin, align 4
  %inc3 = add nsw i32 %27, 1
  store i32 %inc3, ptr %__begin, align 4
  %28 = load i32, ptr %__begin, align 4
  %29 = load i32, ptr %__end, align 4
  %cmp4 = icmp slt i32 %28, %29
  br i1 %cmp4, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !7

pfor.cond.cleanup:                                ; preds = %pfor.inc
  %30 = load i64, ptr @__csi_unit_sync_base_id, align 8, !invariant.load !6
  %31 = add i64 %30, 0
  call void @__csan_sync(i64 %31, i32 0)
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %sync.continue
  br label %pfor.end

pfor.end:                                         ; preds = %.noexc, %entry
  %32 = load i64, ptr @__csi_unit_func_exit_base_id, align 8, !invariant.load !6
  %33 = add i64 %32, 0
  call void @__csan_func_exit(i64 %33, i64 %1, i64 1)
  ret i32 0

csi.cleanup:                                      ; preds = %sync.continue
  %csi.cleanup.lpad = landingpad { ptr, i32 }
          cleanup
  %34 = load i64, ptr @__csi_unit_func_exit_base_id, align 8, !invariant.load !6
  %35 = add i64 %34, 1
  call void @__csan_func_exit(i64 %35, i64 %1, i64 3)
  resume { ptr, i32 } %csi.cleanup.lpad
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #2

declare i32 @__gcc_personality_v0(...)

; Function Attrs: nounwind memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @__csi_after_alloca(i64, ptr nocapture readnone, i64, i64) #3

define internal void @__csi_init_callsite_to_function() {
  %1 = load i64, ptr @__csi_unit_func_base_id, align 8
  %2 = add i64 %1, 0
  store i64 %2, ptr @__csi_func_id_main, align 8
  ret void
}

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_func_entry(i64, ptr nocapture readnone, ptr nocapture readnone, i64) #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_func_exit(i64, i64, i64) #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_load(i64, ptr nocapture readnone, i32, i64) #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_store(i64, ptr nocapture readnone, i32, i64) #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_detach(i64, i32, i64) #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_task(i64, i64, ptr nocapture readnone, ptr nocapture readnone, i64) #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_task_exit(i64, i64, i64, i32, i64) #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_detach_continue(i64, i64, i32, i64) #4

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_sync(i64, i32) #4

; Function Attrs: nounwind willreturn
declare ptr @llvm.task.frameaddress(i32) #5

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave() #6

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare ptr @llvm.frameaddress.p0(i32 immarg) #7

define internal void @csirt.unit_ctor() {
  call void @__csanrt_unit_init(ptr @0, ptr @__csi_unit_fed_tables, ptr @__csi_unit_obj_tables, ptr @__csi_init_callsite_to_function)
  ret void
}

declare void @__csanrt_unit_init(ptr, ptr, ptr, ptr)

attributes #0 = { mustprogress noinline norecurse optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { willreturn memory(argmem: readwrite) }
attributes #3 = { nounwind memory(argmem: readwrite, inaccessiblemem: readwrite) }
attributes #4 = { nounwind memory(argmem: read, inaccessiblemem: readwrite) }
attributes #5 = { nounwind willreturn }
attributes #6 = { nocallback nofree nosync nounwind willreturn }
attributes #7 = { nocallback nofree nosync nounwind willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 16.0.6 (git@github.com:OpenCilk/opencilk-project.git d631c52742bc32d008a8101e6fc002f5085e1274)"}
!6 = !{}
!7 = distinct !{!7, !8}
!8 = !{!"tapir.loop.spawn.strategy", i32 1}
