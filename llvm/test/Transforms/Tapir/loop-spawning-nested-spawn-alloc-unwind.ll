; Check that loop-spawning and task-simplify correctly handle a static memory allocation and
; nested spawn within a parallel loop body with a landingpad.
;
; RUN: opt < %s -passes="loop-spawning,task-simplify" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx14.0.0"

%struct.ggml_type_traits_t = type { ptr, i32, i64, i8, ptr, ptr, ptr, ptr, i32, i64 }
%struct.ggml_tensor = type { i32, i32, ptr, [4 x i64], [4 x i64], i32, [16 x i32], i32, ptr, [10 x ptr], i32, i64, i64, ptr, i64, ptr, [64 x i8], ptr, [8 x i8] }
%struct.ggml_compute_params = type { i32, i32, i32, i64, ptr }

@type_traits = external local_unnamed_addr global [24 x %struct.ggml_type_traits_t], align 8
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
@__csi_func_id_ggml_is_contiguous = weak local_unnamed_addr global i64 -1
@__csi_func_id_ggml_row_size = weak local_unnamed_addr global i64 -1
@"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" = private unnamed_addr constant [66 x i8] c"/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp\00"
@__csi_unit_function_name_ggml_compute_forward_mul_mat = private unnamed_addr constant [29 x i8] c"ggml_compute_forward_mul_mat\00"
@__csi_unit_fed_table__csi_unit_func_base_id = internal global [1 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 33, i32 -1, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_func_exit_base_id = internal global [2 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 170, i32 1, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 124, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_loop_base_id = internal global [2 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 124, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_loop_exit_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_bb_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_callsite_base_id = internal global [5 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 50, i32 28, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 81, i32 29, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 161, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 161, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 161, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_load_base_id = internal global [40 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 48, i32 39, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 52, i32 71, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 53, i32 71, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 55, i32 71, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 80, i32 36, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 80, i32 29, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 122, i32 55, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 144, i32 62, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 151, i32 41, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 144, i32 62, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 151, i32 41, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 144, i32 62, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 151, i32 41, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 37, i32 39, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 38, i32 39, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 43, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 154, i32 60, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 154, i32 60, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 154, i32 60, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 165, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 165, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 165, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_store_base_id = internal global [3 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 165, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 165, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 165, i32 21, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_detach_base_id = internal global [3 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 124, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_task_base_id = internal global [3 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 0, i32 0, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_task_exit_base_id = internal global [6 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 169, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 124, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_detach_continue_base_id = internal global [6 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 124, i32 56, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 124, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 124, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_sync_base_id = internal global [3 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 127, i32 9, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 124, i32 5, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_alloca_base_id = internal global [2 x { ptr, i32, i32, ptr }] [{ ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 33, i32 -1, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, i32, ptr } { ptr @__csi_unit_function_name_ggml_compute_forward_mul_mat, i32 33, i32 -1, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_fed_table__csi_unit_allocfn_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_fed_table__csi_unit_free_base_id = internal global [0 x { ptr, i32, i32, ptr }] zeroinitializer
@__csi_unit_object_name_src0 = private unnamed_addr constant [5 x i8] c"src0\00"
@__csi_unit_object_name_src1 = private unnamed_addr constant [5 x i8] c"src1\00"
@__csi_unit_object_name_type_traits = private unnamed_addr constant [12 x i8] c"type_traits\00"
@__csi_unit_object_name_cond.in = private unnamed_addr constant [8 x i8] c"cond.in\00"
@__csi_unit_object_name_dst = private unnamed_addr constant [4 x i8] c"dst\00"
@__csi_unit_object_name_tmp = private unnamed_addr constant [4 x i8] c"tmp\00"
@__csi_unit_obj_table = internal global [40 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_type_traits, i32 -1, ptr null }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_type_traits, i32 -1, ptr null }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_type_traits, i32 -1, ptr null }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_cond.in, i32 -1, ptr null }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src0, i32 37, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_src1, i32 38, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_dst, i32 35, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_tmp, i32 130, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_tmp, i32 130, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_tmp, i32 130, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_obj_table.1 = internal global [3 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr null, i32 -1, ptr null }, { ptr, i32, ptr } { ptr null, i32 -1, ptr null }, { ptr, i32, ptr } { ptr null, i32 -1, ptr null }]
@__csi_unit_obj_table.2 = internal global [2 x { ptr, i32, ptr }] [{ ptr, i32, ptr } { ptr @__csi_unit_object_name_tmp, i32 130, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }, { ptr, i32, ptr } { ptr @__csi_unit_object_name_tmp, i32 130, ptr @"__csi_unit_filename_/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp" }]
@__csi_unit_obj_table.3 = internal global [0 x { ptr, i32, ptr }] zeroinitializer
@__csi_func_id__Z28ggml_compute_forward_mul_matPK19ggml_compute_paramsP11ggml_tensor = weak local_unnamed_addr global i64 -1
@__csi_unit_fed_tables = internal global [16 x { i64, ptr, ptr }] [{ i64, ptr, ptr } { i64 1, ptr @__csi_unit_func_base_id, ptr @__csi_unit_fed_table__csi_unit_func_base_id }, { i64, ptr, ptr } { i64 2, ptr @__csi_unit_func_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_func_exit_base_id }, { i64, ptr, ptr } { i64 2, ptr @__csi_unit_loop_base_id, ptr @__csi_unit_fed_table__csi_unit_loop_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_loop_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_loop_exit_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_bb_base_id, ptr @__csi_unit_fed_table__csi_unit_bb_base_id }, { i64, ptr, ptr } { i64 5, ptr @__csi_unit_callsite_base_id, ptr @__csi_unit_fed_table__csi_unit_callsite_base_id }, { i64, ptr, ptr } { i64 40, ptr @__csi_unit_load_base_id, ptr @__csi_unit_fed_table__csi_unit_load_base_id }, { i64, ptr, ptr } { i64 3, ptr @__csi_unit_store_base_id, ptr @__csi_unit_fed_table__csi_unit_store_base_id }, { i64, ptr, ptr } { i64 3, ptr @__csi_unit_detach_base_id, ptr @__csi_unit_fed_table__csi_unit_detach_base_id }, { i64, ptr, ptr } { i64 3, ptr @__csi_unit_task_base_id, ptr @__csi_unit_fed_table__csi_unit_task_base_id }, { i64, ptr, ptr } { i64 6, ptr @__csi_unit_task_exit_base_id, ptr @__csi_unit_fed_table__csi_unit_task_exit_base_id }, { i64, ptr, ptr } { i64 6, ptr @__csi_unit_detach_continue_base_id, ptr @__csi_unit_fed_table__csi_unit_detach_continue_base_id }, { i64, ptr, ptr } { i64 3, ptr @__csi_unit_sync_base_id, ptr @__csi_unit_fed_table__csi_unit_sync_base_id }, { i64, ptr, ptr } { i64 2, ptr @__csi_unit_alloca_base_id, ptr @__csi_unit_fed_table__csi_unit_alloca_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_allocfn_base_id, ptr @__csi_unit_fed_table__csi_unit_allocfn_base_id }, { i64, ptr, ptr } { i64 0, ptr @__csi_unit_free_base_id, ptr @__csi_unit_fed_table__csi_unit_free_base_id }]
@__csi_unit_obj_tables = internal global [4 x { i64, ptr }] [{ i64, ptr } { i64 40, ptr @__csi_unit_obj_table }, { i64, ptr } { i64 3, ptr @__csi_unit_obj_table.1 }, { i64, ptr } { i64 2, ptr @__csi_unit_obj_table.2 }, { i64, ptr } { i64 0, ptr @__csi_unit_obj_table.3 }]
@0 = private unnamed_addr constant [66 x i8] c"/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp\00", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 0, ptr @csirt.unit_ctor, ptr null }]

; Function Attrs: mustprogress ssp uwtable(sync)
define void @_Z28ggml_compute_forward_mul_matPK19ggml_compute_paramsP11ggml_tensor(ptr nocapture noundef readonly %params, ptr nocapture noundef readonly %dst) local_unnamed_addr #0 personality ptr @__gcc_personality_v0 !dbg !228 {
entry:
  %syncreg = tail call token @llvm.syncregion.start(), !dbg !400
  call void @llvm.dbg.value(metadata ptr %params, metadata !283, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata ptr %dst, metadata !284, metadata !DIExpression()), !dbg !400
  %0 = load i64, ptr @__csi_unit_func_base_id, align 8, !dbg !401, !invariant.load !402
  %1 = call ptr @llvm.frameaddress.p0(i32 0), !dbg !401
  %2 = call ptr @llvm.stacksave(), !dbg !401
  call void @__csan_func_entry(i64 %0, ptr %1, ptr %2, i64 257), !dbg !400
  %3 = alloca i8, align 1, !dbg !401
  call void @__csan_get_MAAP(ptr nonnull %3, i64 %0, i8 0), !dbg !401
  %4 = load i8, ptr %3, align 1, !dbg !401
  %5 = alloca i8, align 1, !dbg !401
  call void @__csan_get_MAAP(ptr nonnull %5, i64 %0, i8 1), !dbg !401
  %6 = load i8, ptr %5, align 1, !dbg !401
  %7 = load i64, ptr @__csi_unit_detach_base_id, align 8, !dbg !401, !invariant.load !402
  %8 = load i64, ptr @__csi_unit_task_base_id, align 8, !dbg !401, !invariant.load !402
  %9 = load i64, ptr @__csi_unit_task_exit_base_id, align 8, !dbg !401, !invariant.load !402
  %10 = add i64 %9, 1, !dbg !401
  %11 = load i64, ptr @__csi_unit_detach_continue_base_id, align 8, !dbg !401, !invariant.load !402
  %12 = add i64 %11, 1, !dbg !401
  %src = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 9, !dbg !401
  %13 = and i8 %6, 1, !dbg !403
  %14 = icmp eq i8 %13, 0, !dbg !403
  %15 = and i8 %4, 1, !dbg !403
  %16 = icmp eq i8 %15, 0, !dbg !403
  %17 = or i8 %6, %4, !dbg !403
  %18 = and i8 %17, 4, !dbg !403
  %19 = icmp ne i8 %18, 0, !dbg !403
  %20 = or i1 %16, %19, !dbg !403
  %21 = and i1 %14, %20, !dbg !403
  br i1 %21, label %22, label %24, !dbg !403

22:                                               ; preds = %entry
  %23 = load ptr, ptr %src, align 8, !dbg !403, !tbaa !404
  call void @llvm.dbg.value(metadata ptr %23, metadata !285, metadata !DIExpression()), !dbg !400
  %arrayidx3 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 9, i64 1, !dbg !408
  br label %29, !dbg !408

24:                                               ; preds = %entry
  %25 = load i64, ptr @__csi_unit_load_base_id, align 8, !dbg !403, !invariant.load !402
  %26 = add i64 %25, 27, !dbg !403
  call void @__csan_load(i64 %26, ptr nonnull %src, i32 8, i64 8), !dbg !403
  %27 = load ptr, ptr %src, align 8, !dbg !403, !tbaa !404
  call void @llvm.dbg.value(metadata ptr %27, metadata !285, metadata !DIExpression()), !dbg !400
  %arrayidx3408 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 9, i64 1, !dbg !408
  %28 = add i64 %25, 28, !dbg !408
  call void @__csan_load(i64 %28, ptr nonnull %arrayidx3408, i32 8, i64 8), !dbg !408
  br label %29, !dbg !408

29:                                               ; preds = %22, %24
  %arrayidx3409 = phi ptr [ %arrayidx3, %22 ], [ %arrayidx3408, %24 ]
  %30 = phi ptr [ %23, %22 ], [ %27, %24 ]
  %31 = load ptr, ptr %arrayidx3409, align 8, !dbg !408, !tbaa !404
  call void @llvm.dbg.value(metadata ptr %31, metadata !288, metadata !DIExpression()), !dbg !400
  %ne = getelementptr inbounds %struct.ggml_tensor, ptr %30, i64 0, i32 3, !dbg !409
  %32 = load i64, ptr @__csi_unit_load_base_id, align 8, !dbg !409, !invariant.load !402
  call void @__csan_load(i64 %32, ptr nonnull %ne, i32 8, i64 8), !dbg !409
  %33 = load i64, ptr %ne, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %33, metadata !289, metadata !DIExpression()), !dbg !400
  %arrayidx6 = getelementptr inbounds %struct.ggml_tensor, ptr %30, i64 0, i32 3, i64 1, !dbg !409
  %34 = add i64 %32, 1, !dbg !409
  call void @__csan_load(i64 %34, ptr nonnull %arrayidx6, i32 8, i64 8), !dbg !409
  %35 = load i64, ptr %arrayidx6, align 8, !dbg !409, !tbaa !410
  %.fr = freeze i64 %35
  call void @llvm.dbg.value(metadata i64 %35, metadata !291, metadata !DIExpression()), !dbg !400
  %arrayidx8 = getelementptr inbounds %struct.ggml_tensor, ptr %30, i64 0, i32 3, i64 2, !dbg !409
  %36 = add i64 %32, 2, !dbg !409
  call void @__csan_load(i64 %36, ptr nonnull %arrayidx8, i32 8, i64 8), !dbg !409
  %37 = load i64, ptr %arrayidx8, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %37, metadata !292, metadata !DIExpression()), !dbg !400
  %arrayidx10 = getelementptr inbounds %struct.ggml_tensor, ptr %30, i64 0, i32 3, i64 3, !dbg !409
  %38 = add i64 %32, 3, !dbg !409
  call void @__csan_load(i64 %38, ptr nonnull %arrayidx10, i32 8, i64 8), !dbg !409
  %39 = load i64, ptr %arrayidx10, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %39, metadata !293, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 poison, metadata !294, metadata !DIExpression()), !dbg !400
  %arrayidx13 = getelementptr inbounds %struct.ggml_tensor, ptr %30, i64 0, i32 4, i64 1, !dbg !409
  %40 = add i64 %32, 4, !dbg !409
  call void @__csan_load(i64 %40, ptr nonnull %arrayidx13, i32 8, i64 8), !dbg !409
  %41 = load i64, ptr %arrayidx13, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %41, metadata !296, metadata !DIExpression()), !dbg !400
  %arrayidx15 = getelementptr inbounds %struct.ggml_tensor, ptr %30, i64 0, i32 4, i64 2, !dbg !409
  %42 = add i64 %32, 5, !dbg !409
  call void @__csan_load(i64 %42, ptr nonnull %arrayidx15, i32 8, i64 8), !dbg !409
  %43 = load i64, ptr %arrayidx15, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %43, metadata !297, metadata !DIExpression()), !dbg !400
  %arrayidx17 = getelementptr inbounds %struct.ggml_tensor, ptr %30, i64 0, i32 4, i64 3, !dbg !409
  %44 = add i64 %32, 6, !dbg !409
  call void @__csan_load(i64 %44, ptr nonnull %arrayidx17, i32 8, i64 8), !dbg !409
  %45 = load i64, ptr %arrayidx17, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %45, metadata !298, metadata !DIExpression()), !dbg !400
  %ne18 = getelementptr inbounds %struct.ggml_tensor, ptr %31, i64 0, i32 3, !dbg !409
  %46 = add i64 %32, 7, !dbg !409
  call void @__csan_load(i64 %46, ptr nonnull %ne18, i32 8, i64 8), !dbg !409
  %47 = load i64, ptr %ne18, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %47, metadata !299, metadata !DIExpression()), !dbg !400
  %arrayidx21 = getelementptr inbounds %struct.ggml_tensor, ptr %31, i64 0, i32 3, i64 1, !dbg !409
  %48 = add i64 %32, 8, !dbg !409
  call void @__csan_load(i64 %48, ptr nonnull %arrayidx21, i32 8, i64 8), !dbg !409
  %49 = load i64, ptr %arrayidx21, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %49, metadata !300, metadata !DIExpression()), !dbg !400
  %arrayidx23 = getelementptr inbounds %struct.ggml_tensor, ptr %31, i64 0, i32 3, i64 2, !dbg !409
  %50 = add i64 %32, 9, !dbg !409
  call void @__csan_load(i64 %50, ptr nonnull %arrayidx23, i32 8, i64 8), !dbg !409
  %51 = load i64, ptr %arrayidx23, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %51, metadata !301, metadata !DIExpression()), !dbg !400
  %arrayidx25 = getelementptr inbounds %struct.ggml_tensor, ptr %31, i64 0, i32 3, i64 3, !dbg !409
  %52 = add i64 %32, 10, !dbg !409
  call void @__csan_load(i64 %52, ptr nonnull %arrayidx25, i32 8, i64 8), !dbg !409
  %53 = load i64, ptr %arrayidx25, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %53, metadata !302, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 poison, metadata !303, metadata !DIExpression()), !dbg !400
  %arrayidx29 = getelementptr inbounds %struct.ggml_tensor, ptr %31, i64 0, i32 4, i64 1, !dbg !409
  %54 = add i64 %32, 11, !dbg !409
  call void @__csan_load(i64 %54, ptr nonnull %arrayidx29, i32 8, i64 8), !dbg !409
  %55 = load i64, ptr %arrayidx29, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %55, metadata !304, metadata !DIExpression()), !dbg !400
  %arrayidx32 = getelementptr inbounds %struct.ggml_tensor, ptr %31, i64 0, i32 4, i64 2, !dbg !409
  %56 = add i64 %32, 12, !dbg !409
  call void @__csan_load(i64 %56, ptr nonnull %arrayidx32, i32 8, i64 8), !dbg !409
  %57 = load i64, ptr %arrayidx32, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %57, metadata !305, metadata !DIExpression()), !dbg !400
  %arrayidx34 = getelementptr inbounds %struct.ggml_tensor, ptr %31, i64 0, i32 4, i64 3, !dbg !409
  %58 = add i64 %32, 13, !dbg !409
  call void @__csan_load(i64 %58, ptr nonnull %arrayidx34, i32 8, i64 8), !dbg !409
  %59 = load i64, ptr %arrayidx34, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %59, metadata !306, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 poison, metadata !307, metadata !DIExpression()), !dbg !400
  %arrayidx38 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 3, i64 1, !dbg !409
  br i1 %21, label %60, label %65, !dbg !409

60:                                               ; preds = %29
  %61 = load i64, ptr %arrayidx38, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %61, metadata !308, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 poison, metadata !309, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 poison, metadata !310, metadata !DIExpression()), !dbg !400
  %nb43 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, !dbg !409
  %62 = load i64, ptr %nb43, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %62, metadata !311, metadata !DIExpression()), !dbg !400
  %arrayidx46 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 1, !dbg !409
  %63 = load i64, ptr %arrayidx46, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %63, metadata !312, metadata !DIExpression()), !dbg !400
  %arrayidx48 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 2, !dbg !409
  %64 = load i64, ptr %arrayidx48, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %64, metadata !313, metadata !DIExpression()), !dbg !400
  %arrayidx50 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 3, !dbg !409
  br label %75, !dbg !409

65:                                               ; preds = %29
  %66 = add i64 %32, 29, !dbg !409
  call void @__csan_load(i64 %66, ptr nonnull %arrayidx38, i32 8, i64 8), !dbg !409
  %67 = load i64, ptr %arrayidx38, align 8, !dbg !409, !tbaa !410
  call void @llvm.dbg.value(metadata i64 %67, metadata !308, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 poison, metadata !309, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 poison, metadata !310, metadata !DIExpression()), !dbg !400
  %nb43412 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, !dbg !409
  %68 = add i64 %32, 30, !dbg !409
  call void @__csan_load(i64 %68, ptr nonnull %nb43412, i32 8, i64 8), !dbg !409
  %69 = load i64, ptr %nb43412, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %69, metadata !311, metadata !DIExpression()), !dbg !400
  %arrayidx46417 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 1, !dbg !409
  %70 = add i64 %32, 31, !dbg !409
  call void @__csan_load(i64 %70, ptr nonnull %arrayidx46417, i32 8, i64 8), !dbg !409
  %71 = load i64, ptr %arrayidx46417, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %71, metadata !312, metadata !DIExpression()), !dbg !400
  %arrayidx48422 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 2, !dbg !409
  %72 = add i64 %32, 32, !dbg !409
  call void @__csan_load(i64 %72, ptr nonnull %arrayidx48422, i32 8, i64 8), !dbg !409
  %73 = load i64, ptr %arrayidx48422, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %73, metadata !313, metadata !DIExpression()), !dbg !400
  %arrayidx50427 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 4, i64 3, !dbg !409
  %74 = add i64 %32, 33, !dbg !409
  call void @__csan_load(i64 %74, ptr nonnull %arrayidx50427, i32 8, i64 8), !dbg !409
  br label %75, !dbg !409

75:                                               ; preds = %60, %65
  %arrayidx50428 = phi ptr [ %arrayidx50, %60 ], [ %arrayidx50427, %65 ]
  %76 = phi i64 [ %64, %60 ], [ %73, %65 ]
  %77 = phi i64 [ %62, %60 ], [ %69, %65 ]
  %78 = phi i64 [ %61, %60 ], [ %67, %65 ]
  %79 = phi i64 [ %63, %60 ], [ %71, %65 ]
  %80 = load i64, ptr %arrayidx50428, align 8, !dbg !409, !tbaa !412
  call void @llvm.dbg.value(metadata i64 %80, metadata !314, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i32 0, metadata !315, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i32 1, metadata !317, metadata !DIExpression()), !dbg !400
  %81 = add i64 %32, 14, !dbg !414
  call void @__csan_load(i64 %81, ptr nonnull %30, i32 4, i64 8), !dbg !414
  %82 = load i32, ptr %30, align 8, !dbg !414, !tbaa !415
  call void @llvm.dbg.value(metadata i32 %82, metadata !318, metadata !DIExpression()), !dbg !400
  %83 = load i64, ptr @__csi_func_id_ggml_is_contiguous, align 8, !dbg !421
  call void @__csan_set_MAAP(i8 3, i64 %83), !dbg !421
  %84 = load i64, ptr @__csi_unit_callsite_base_id, align 8, !dbg !421, !invariant.load !402
  call void @__csan_before_call(i64 %84, i64 %83, i8 1, i64 0), !dbg !421
  %call387 = invoke zeroext i1 @ggml_is_contiguous(ptr noundef nonnull %31)
          to label %call.noexc unwind label %csi.cleanup.loopexit.split-lp.csi-split, !dbg !421

call.noexc:                                       ; preds = %75
  call void @__csan_after_call(i64 %84, i64 %83, i8 1, i64 0), !dbg !400
  call void @llvm.dbg.value(metadata i1 %call387, metadata !320, metadata !DIExpression(DW_OP_LLVM_convert, 1, DW_ATE_unsigned, DW_OP_LLVM_convert, 8, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !400
  %idxprom = zext i32 %82 to i64, !dbg !422
  %vec_dot53 = getelementptr inbounds [24 x %struct.ggml_type_traits_t], ptr @type_traits, i64 0, i64 %idxprom, i32 7, !dbg !423
  %85 = add i64 %32, 15, !dbg !423
  call void @__csan_load(i64 %85, ptr nonnull %vec_dot53, i32 8, i64 8), !dbg !423
  %86 = load ptr, ptr %vec_dot53, align 8, !dbg !423, !tbaa !424
  call void @llvm.dbg.value(metadata ptr %86, metadata !323, metadata !DIExpression()), !dbg !400
  %vec_dot_type56 = getelementptr inbounds [24 x %struct.ggml_type_traits_t], ptr @type_traits, i64 0, i64 %idxprom, i32 8, !dbg !427
  %87 = add i64 %32, 16, !dbg !427
  call void @__csan_load(i64 %87, ptr nonnull %vec_dot_type56, i32 4, i64 8), !dbg !427
  %88 = load i32, ptr %vec_dot_type56, align 8, !dbg !427, !tbaa !428
  call void @llvm.dbg.value(metadata i32 %88, metadata !331, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata ptr poison, metadata !332, metadata !DIExpression()), !dbg !400
  %nrows = getelementptr inbounds [24 x %struct.ggml_type_traits_t], ptr @type_traits, i64 0, i64 %idxprom, i32 9, !dbg !429
  %89 = add i64 %32, 17, !dbg !429
  call void @__csan_load(i64 %89, ptr nonnull %nrows, i32 8, i64 8), !dbg !429
  %90 = load i64, ptr %nrows, align 8, !dbg !429, !tbaa !430
  call void @llvm.dbg.value(metadata i64 %90, metadata !340, metadata !DIExpression()), !dbg !400
  %div = sdiv i64 %51, %37, !dbg !431
  call void @llvm.dbg.value(metadata i64 %div, metadata !341, metadata !DIExpression()), !dbg !400
  %div61 = sdiv i64 %53, %39, !dbg !432
  call void @llvm.dbg.value(metadata i64 %div61, metadata !342, metadata !DIExpression()), !dbg !400
  %91 = add i64 %32, 18, !dbg !433
  call void @__csan_load(i64 %91, ptr nonnull %31, i32 4, i64 8), !dbg !433
  %92 = load i32, ptr %31, align 8, !dbg !433, !tbaa !415
  %cmp = icmp eq i32 %92, %88, !dbg !434
  %data = getelementptr inbounds %struct.ggml_tensor, ptr %31, i64 0, i32 15, !dbg !435
  %wdata63 = getelementptr inbounds %struct.ggml_compute_params, ptr %params, i64 0, i32 4, !dbg !435
  %cond.in = select i1 %cmp, ptr %data, ptr %wdata63, !dbg !435
  %93 = add i64 %32, 19, !dbg !435
  call void @__csan_load(i64 %93, ptr nonnull %cond.in, i32 8, i64 8), !dbg !435
  %cond = load ptr, ptr %cond.in, align 8, !dbg !435, !tbaa !404
  call void @llvm.dbg.value(metadata ptr %cond, metadata !343, metadata !DIExpression()), !dbg !400
  %94 = add i64 %84, 1, !dbg !436
  %95 = load i64, ptr @__csi_func_id_ggml_row_size, align 8, !dbg !436
  call void @__csan_before_call(i64 %94, i64 %95, i8 0, i64 0), !dbg !436
  %call64388 = invoke i64 @ggml_row_size(i32 noundef %88, i64 noundef %47)
          to label %call64.noexc unwind label %csi.cleanup.loopexit.split-lp.csi-split, !dbg !436

call64.noexc:                                     ; preds = %call.noexc
  call void @__csan_after_call(i64 %94, i64 %95, i8 0, i64 0), !dbg !400
  call void @llvm.dbg.value(metadata i64 %call64388, metadata !344, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 %35, metadata !345, metadata !DIExpression()), !dbg !400
  %mul = mul nsw i64 %78, %51, !dbg !437
  %mul65 = mul nsw i64 %mul, %53, !dbg !438
  %mul65.fr = freeze i64 %mul65
  call void @llvm.dbg.value(metadata i64 %mul65, metadata !346, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 1, metadata !347, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 1, metadata !348, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 0, metadata !349, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 0, metadata !350, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 %35, metadata !351, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 %mul65, metadata !352, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 0, metadata !353, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 %35, metadata !354, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 0, metadata !355, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 %mul65, metadata !356, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 16, metadata !357, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 16, metadata !358, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 %90, metadata !359, metadata !DIExpression()), !dbg !400
  %96 = and i64 %.fr, 1, !dbg !439
  %cmp93.not = icmp eq i64 %96, 0, !dbg !439
  %97 = and i64 %49, 1
  %cmp95.not = icmp eq i64 %97, 0
  %or.cond = select i1 %cmp93.not, i1 %cmp95.not, i1 false, !dbg !441
  %nrc.0 = select i1 %or.cond, i64 %90, i64 1, !dbg !441
  call void @llvm.dbg.value(metadata i64 %nrc.0, metadata !359, metadata !DIExpression()), !dbg !400
  br i1 %call387, label %cond.end101, label %lor.lhs.false96, !dbg !442

lor.lhs.false96:                                  ; preds = %call64.noexc
  %98 = add i64 %32, 20, !dbg !443
  call void @__csan_load(i64 %98, ptr nonnull %31, i32 4, i64 8), !dbg !443
  %99 = load i32, ptr %31, align 8, !dbg !443, !tbaa !415
  %cmp98.not = icmp eq i32 %99, %88, !dbg !444
  %spec.select = select i1 %cmp98.not, i64 %55, i64 %call64388, !dbg !445
  br label %cond.end101, !dbg !445

cond.end101:                                      ; preds = %lor.lhs.false96, %call64.noexc
  %cond102 = phi i64 [ %call64388, %call64.noexc ], [ %spec.select, %lor.lhs.false96 ], !dbg !445
  call void @llvm.dbg.value(metadata i64 %cond102, metadata !360, metadata !DIExpression()), !dbg !400
  call void @llvm.dbg.value(metadata i64 0, metadata !361, metadata !DIExpression()), !dbg !446
  call void @llvm.dbg.value(metadata i64 %35, metadata !363, metadata !DIExpression()), !dbg !446
  %cmp103 = icmp sgt i64 %.fr, 0, !dbg !447
  br i1 %cmp103, label %pfor.ph, label %cleanup244, !dbg !448

pfor.ph:                                          ; preds = %cond.end101
  call void @llvm.dbg.value(metadata i64 0, metadata !364, metadata !DIExpression()), !dbg !446
  call void @llvm.dbg.value(metadata i64 %.fr, metadata !365, metadata !DIExpression(DW_OP_constu, 1, DW_OP_minus, DW_OP_constu, 4, DW_OP_shr, DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !446
  %cmp113 = icmp sgt i64 %mul65.fr, 0
  %data146 = getelementptr inbounds %struct.ggml_tensor, ptr %30, i64 0, i32 15
  %data171 = getelementptr inbounds %struct.ggml_tensor, ptr %dst, i64 0, i32 15
  %conv186 = trunc i64 %33 to i32
  %cmp189 = icmp sgt i64 %nrc.0, 1
  %conv191 = select i1 %cmp189, i64 16, i64 0
  %cond198 = select i1 %cmp189, i64 %41, i64 0
  %cond203 = select i1 %cmp189, i64 %cond102, i64 0
  %conv204 = trunc i64 %nrc.0 to i32
  %cmp208376 = icmp sgt i64 %nrc.0, 0
  br i1 %cmp113, label %pfor.cond.us.preheader.split.split, label %pfor.cond.cleanup239, !dbg !449

pfor.cond.us.preheader.split.split:               ; preds = %pfor.ph
  %sub120 = add nsw i64 %mul65.fr, -1
  %div121374 = and i64 %sub120, -32, !dbg !450
  %sub105 = add nsw i64 %.fr, -1, !dbg !447
  call void @llvm.dbg.value(metadata i64 %sub105, metadata !365, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !446
  %div106373 = lshr i64 %sub105, 4
  call void @llvm.dbg.value(metadata i64 %div106373, metadata !365, metadata !DIExpression(DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !446
  %100 = icmp ult i64 %mul65.fr, 33
  %stripiter386 = lshr i64 %sub120, 5
  %add129.us.epil = or i64 %div121374, 16
  %invariant.smin379.us.epil = tail call i64 @llvm.smin.i64(i64 %add129.us.epil, i64 %mul65.fr)
  %101 = icmp ult i64 %div121374, %invariant.smin379.us.epil
  %102 = and i64 %sub120, 16
  %epil.iter.cmp.not = icmp eq i64 %102, 0
  %add129.us.epil.1 = add nuw i64 %div121374, 32
  %invariant.smin379.us.epil.1 = tail call i64 @llvm.smin.i64(i64 %add129.us.epil.1, i64 %mul65.fr)
  %103 = icmp slt i64 %add129.us.epil, %invariant.smin379.us.epil.1
  %104 = load i64, ptr @__csi_unit_loop_base_id, align 8, !dbg !451, !invariant.load !402
  call void @__csan_before_loop(i64 %104, i64 -1, i64 1), !dbg !451
  %105 = load i64, ptr @__csi_unit_alloca_base_id, align 8
  %106 = add i64 %7, 2
  %107 = add i64 %8, 2
  %108 = add i64 %9, 4
  %109 = add i64 %9, 5
  %110 = add i64 %11, 4
  %111 = add i64 %11, 5
  %112 = add i64 %7, 1
  %113 = add i64 %8, 1
  %114 = add i64 %9, 2
  %115 = add i64 %9, 3
  %116 = add i64 %11, 2
  %117 = add i64 %11, 3
  %118 = add i64 %104, 1
  %119 = add i64 %105, 1
  %120 = add i64 %32, 25
  %121 = add i64 %32, 26
  %122 = add i64 %32, 36
  %123 = add i64 %84, 4
  %124 = add i64 %32, 39
  %125 = load i64, ptr @__csi_unit_sync_base_id, align 8
  %126 = add i64 %32, 21
  %127 = add i64 %32, 22
  %128 = add i64 %32, 34
  %129 = add i64 %84, 2
  %130 = add i64 %32, 37
  %131 = add i64 %32, 23
  %132 = add i64 %32, 24
  %133 = add i64 %32, 35
  %134 = add i64 %84, 3
  %135 = add i64 %32, 38
  %136 = add i64 %125, 1
  br label %pfor.cond.us, !dbg !451

pfor.cond.us:                                     ; preds = %pfor.cond.us.preheader.split.split, %pfor.inc236.us
  %__begin.0.us = phi i64 [ %inc237.us, %pfor.inc236.us ], [ 0, %pfor.cond.us.preheader.split.split ], !dbg !452
  call void @llvm.dbg.value(metadata i64 %__begin.0.us, metadata !364, metadata !DIExpression()), !dbg !446
  %mul108.us = shl nsw i64 %__begin.0.us, 4, !dbg !453
  call void @__csan_detach(i64 %7, i32 0, i64 1), !dbg !451
  detach within %syncreg, label %pfor.ph116.us.split, label %pfor.inc236.us unwind label %csi.cleanup.loopexit, !dbg !451

pfor.ph116.us.split:                              ; preds = %pfor.cond.us
  %137 = call ptr @llvm.task.frameaddress(i32 0)
  %138 = call ptr @llvm.stacksave()
  call void @__csan_task(i64 %8, i64 %7, ptr %137, ptr %138, i64 3)
  %tmp.us.epil = alloca [32 x float], align 4
  %syncreg110.us = call token @llvm.syncregion.start(), !dbg !454
  call void @llvm.dbg.value(metadata i64 %mul108.us, metadata !366, metadata !DIExpression()), !dbg !455
  call void @llvm.dbg.value(metadata i64 0, metadata !368, metadata !DIExpression()), !dbg !456
  call void @llvm.dbg.value(metadata i64 %mul65, metadata !371, metadata !DIExpression()), !dbg !456
  call void @llvm.dbg.value(metadata i64 0, metadata !372, metadata !DIExpression()), !dbg !456
  call void @llvm.dbg.value(metadata i64 %sub120, metadata !373, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !456
  call void @__csi_after_alloca(i64 %105, ptr nonnull %tmp.us.epil, i64 128, i64 0), !dbg !400
  %add179.us = add nuw nsw i64 %mul108.us, 16
  %invariant.smin.us = call i64 @llvm.smin.i64(i64 %add179.us, i64 %.fr)
  %139 = icmp slt i64 %mul108.us, %invariant.smin.us
  %sub225.us = sub nsw i64 %invariant.smin.us, %mul108.us
  %mul226.us = shl i64 %sub225.us, 2
  br i1 %100, label %pfor.cond123.us.epil, label %pfor.ph116.us.new, !dbg !457

pfor.ph116.us.new:                                ; preds = %pfor.ph116.us.split
  call void @__csan_detach(i64 %106, i32 0, i64 0), !dbg !458
  detach within %syncreg110.us, label %pfor.cond123.us.strpm.detachloop.entry, label %pfor.ph116.us.new.pfor.cond123.us.epil_crit_edge unwind label %csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split, !dbg !458

pfor.ph116.us.new.pfor.cond123.us.epil_crit_edge: ; preds = %pfor.cond123.us.strpm.detachloop.reattach.split, %pfor.ph116.us.new
  call void @__csan_detach_continue(i64 %110, i64 %106, i32 0, i64 0), !dbg !458
  br label %pfor.cond123.us.epil, !dbg !458

pfor.cond123.us.strpm.detachloop.entry:           ; preds = %pfor.ph116.us.new
  %140 = call ptr @llvm.task.frameaddress(i32 0)
  %141 = call ptr @llvm.stacksave()
  call void @__csan_task(i64 %107, i64 %106, ptr %140, ptr %141, i64 2)
  %syncreg110.us.strpm.detachloop = call token @llvm.syncregion.start()
  call void @__csan_before_loop(i64 %118, i64 -1, i64 1), !dbg !458
  br label %pfor.cond123.us.strpm.outer, !dbg !458

pfor.cond123.us.strpm.outer:                      ; preds = %pfor.inc.us.strpm.outer, %pfor.cond123.us.strpm.detachloop.entry
  %niter = phi i64 [ 0, %pfor.cond123.us.strpm.detachloop.entry ], [ %niter.nadd, %pfor.inc.us.strpm.outer ]
  call void @__csan_detach(i64 %112, i32 0, i64 1), !dbg !458
  detach within %syncreg110.us.strpm.detachloop, label %pfor.body128.us.strpm.outer, label %pfor.inc.us.strpm.outer unwind label %csi.cleanup389391, !dbg !458

pfor.body128.us.strpm.outer:                      ; preds = %pfor.cond123.us.strpm.outer
  %142 = call ptr @llvm.task.frameaddress(i32 0)
  %143 = call ptr @llvm.stacksave()
  call void @__csan_task(i64 %113, i64 %112, ptr %142, ptr %143, i64 1)
  %tmp.us = alloca [32 x float], align 4
  call void @__csi_after_alloca(i64 %119, ptr nonnull %tmp.us, i64 128, i64 0), !dbg !458
  %144 = shl nuw i64 %niter, 1, !dbg !458
  br label %pfor.cond123.us.split, !dbg !458

pfor.cond123.us.split:                            ; preds = %for.cond.cleanup.us, %pfor.body128.us.strpm.outer
  %__begin117.0.us = phi i64 [ %inc232.us, %for.cond.cleanup.us ], [ %144, %pfor.body128.us.strpm.outer ], !dbg !459
  %inneriter = phi i64 [ %inneriter.nsub, %for.cond.cleanup.us ], [ 2, %pfor.body128.us.strpm.outer ]
  call void @llvm.dbg.value(metadata i64 %__begin117.0.us, metadata !372, metadata !DIExpression()), !dbg !456
  %mul125.us = shl nsw i64 %__begin117.0.us, 4, !dbg !450
  call void @llvm.dbg.value(metadata i64 %mul125.us, metadata !374, metadata !DIExpression()), !dbg !460
  call void @llvm.lifetime.start.p0(i64 128, ptr nonnull %tmp.us) #14, !dbg !461
  call void @llvm.dbg.declare(metadata ptr %tmp.us, metadata !376, metadata !DIExpression()), !dbg !462
  call void @llvm.dbg.value(metadata i64 %mul125.us, metadata !381, metadata !DIExpression()), !dbg !463
  %add129.us = add nuw nsw i64 %mul125.us, 16
  %invariant.smin379.us = call i64 @llvm.smin.i64(i64 %add129.us, i64 %mul65.fr), !dbg !464
  %145 = icmp slt i64 %mul125.us, %invariant.smin379.us, !dbg !465
  br i1 %145, label %for.body.us.preheader, label %for.cond.cleanup.us, !dbg !466

for.body.us.preheader:                            ; preds = %pfor.cond123.us.split
  %146 = load i64, ptr @__csi_unit_store_base_id, align 8
  %147 = add i64 %146, 2
  br label %for.body.us, !dbg !466

for.cond.cleanup.us:                              ; preds = %for.cond.cleanup209.us, %pfor.cond123.us.split
  call void @llvm.lifetime.end.p0(i64 128, ptr nonnull %tmp.us) #14, !dbg !467
  %inc232.us = add nuw nsw i64 %__begin117.0.us, 1, !dbg !468
  call void @llvm.dbg.value(metadata i64 %inc232.us, metadata !372, metadata !DIExpression()), !dbg !456
  %inneriter.nsub = add nsw i64 %inneriter, -1, !dbg !469
  %inneriter.ncmp = icmp eq i64 %inneriter.nsub, 0, !dbg !469
  br i1 %inneriter.ncmp, label %pfor.inc.us.reattach, label %pfor.cond123.us.split, !dbg !469, !llvm.loop !470

pfor.inc.us.reattach:                             ; preds = %for.cond.cleanup.us
  call void @__csan_task_exit(i64 %114, i64 %113, i64 %112, i32 0, i64 1), !dbg !458
  reattach within %syncreg110.us.strpm.detachloop, label %pfor.inc.us.strpm.outer, !dbg !458

pfor.inc.us.strpm.outer:                          ; preds = %pfor.cond123.us.strpm.outer, %pfor.inc.us.reattach
  call void @__csan_detach_continue(i64 %116, i64 %112, i32 0, i64 2), !dbg !458
  %niter.nadd = add nuw nsw i64 %niter, 1, !dbg !458
  %niter.ncmp = icmp eq i64 %niter.nadd, %stripiter386, !dbg !458
  br i1 %niter.ncmp, label %pfor.cond123.us.strpm.detachloop.sync, label %pfor.cond123.us.strpm.outer, !dbg !458, !llvm.loop !475

pfor.cond123.us.strpm.detachloop.sync:            ; preds = %pfor.inc.us.strpm.outer
  call void @__csan_after_loop(i64 %118, i8 0, i64 1), !dbg !458
  call void @__csan_sync(i64 %125, i32 0), !dbg !458
  sync within %syncreg110.us.strpm.detachloop, label %pfor.cond123.us.strpm.detachloop.reattach.split, !dbg !458

pfor.cond123.us.strpm.detachloop.reattach.split:  ; preds = %pfor.cond123.us.strpm.detachloop.sync
  call void @__csan_task_exit(i64 %108, i64 %107, i64 %106, i32 0, i64 0), !dbg !458
  reattach within %syncreg110.us, label %pfor.ph116.us.new.pfor.cond123.us.epil_crit_edge, !dbg !458

pfor.cond123.us.epil:                             ; preds = %pfor.ph116.us.new.pfor.cond123.us.epil_crit_edge, %pfor.ph116.us.split
  call void @llvm.dbg.value(metadata i64 %sub120, metadata !372, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_constu, 1152921504606846974, DW_OP_and, DW_OP_stack_value)), !dbg !456
  call void @llvm.dbg.value(metadata i64 %div121374, metadata !374, metadata !DIExpression()), !dbg !460
  call void @llvm.lifetime.start.p0(i64 128, ptr nonnull %tmp.us.epil) #14, !dbg !461
  call void @llvm.dbg.declare(metadata ptr %tmp.us.epil, metadata !376, metadata !DIExpression()), !dbg !462
  call void @llvm.dbg.value(metadata i64 %div121374, metadata !381, metadata !DIExpression()), !dbg !463
  br i1 %101, label %for.body.us.epil.preheader, label %for.cond.cleanup.us.epil, !dbg !466

for.body.us.epil.preheader:                       ; preds = %pfor.cond123.us.epil
  %148 = load i64, ptr @__csi_unit_store_base_id, align 8
  br label %for.body.us.epil, !dbg !466

for.body.us.epil:                                 ; preds = %for.body.us.epil.preheader, %for.cond.cleanup209.us.epil
  %ir1.0380.us.epil = phi i64 [ %add230.us.epil, %for.cond.cleanup209.us.epil ], [ %div121374, %for.body.us.epil.preheader ]
  call void @llvm.dbg.value(metadata i64 %ir1.0380.us.epil, metadata !381, metadata !DIExpression()), !dbg !463
  %div134.us.epil = sdiv i64 %ir1.0380.us.epil, %mul, !dbg !478
  call void @llvm.dbg.value(metadata i64 %div134.us.epil, metadata !383, metadata !DIExpression()), !dbg !479
  %mul135.us.epil = mul nsw i64 %div134.us.epil, %51, !dbg !480
  %mul136.us.epil = mul nsw i64 %mul135.us.epil, %78, !dbg !481
  %sub137.us.epil = sub nsw i64 %ir1.0380.us.epil, %mul136.us.epil, !dbg !482
  %div138.us.epil = sdiv i64 %sub137.us.epil, %78, !dbg !483
  call void @llvm.dbg.value(metadata i64 %div138.us.epil, metadata !386, metadata !DIExpression()), !dbg !479
  %mul142.us.epil = mul nsw i64 %div138.us.epil, %78, !dbg !484
  %sub143.us.epil = sub nsw i64 %sub137.us.epil, %mul142.us.epil, !dbg !485
  call void @llvm.dbg.value(metadata i64 %sub143.us.epil, metadata !387, metadata !DIExpression()), !dbg !479
  %div144.us.epil = sdiv i64 %div134.us.epil, %div61, !dbg !486
  call void @llvm.dbg.value(metadata i64 %div144.us.epil, metadata !388, metadata !DIExpression()), !dbg !479
  %div145.us.epil = sdiv i64 %div138.us.epil, %div, !dbg !487
  call void @llvm.dbg.value(metadata i64 %div145.us.epil, metadata !389, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %sub143.us.epil, metadata !390, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %div138.us.epil, metadata !391, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %div134.us.epil, metadata !392, metadata !DIExpression()), !dbg !479
  call void @__csan_load(i64 %126, ptr nonnull %data146, i32 8, i64 8), !dbg !488
  %149 = load ptr, ptr %data146, align 8, !dbg !488, !tbaa !489
  %mul147.us.epil = mul i64 %div145.us.epil, %43, !dbg !490
  %mul149.us.epil = mul i64 %div144.us.epil, %45, !dbg !491
  %add150.us.epil = add i64 %mul147.us.epil, %mul149.us.epil, !dbg !492
  %add.ptr.us.epil = getelementptr inbounds i8, ptr %149, i64 %add150.us.epil, !dbg !493
  call void @llvm.dbg.value(metadata ptr %add.ptr.us.epil, metadata !393, metadata !DIExpression()), !dbg !479
  br i1 %call387, label %cond.true155.us.epil, label %lor.lhs.false152.us.epil, !dbg !494

lor.lhs.false152.us.epil:                         ; preds = %for.body.us.epil
  call void @__csan_load(i64 %127, ptr nonnull %31, i32 4, i64 8), !dbg !495
  %150 = load i32, ptr %31, align 8, !dbg !495, !tbaa !415
  %cmp154.not.us.epil = icmp eq i32 %150, %88, !dbg !496
  br i1 %cmp154.not.us.epil, label %cond.false162.us.epil, label %cond.true155.us.epil, !dbg !497

cond.false162.us.epil:                            ; preds = %lor.lhs.false152.us.epil
  %mul163.us.epil = mul i64 %sub143.us.epil, %55, !dbg !498
  %mul164.us.epil = mul i64 %div138.us.epil, %57, !dbg !499
  %mul166.us.epil = mul i64 %div134.us.epil, %59, !dbg !500
  %add165.us.epil = add i64 %mul164.us.epil, %mul166.us.epil, !dbg !501
  %add167.us.epil = add i64 %add165.us.epil, %mul163.us.epil, !dbg !502
  br label %cond.end168.us.epil, !dbg !497

cond.true155.us.epil:                             ; preds = %lor.lhs.false152.us.epil, %for.body.us.epil
  %reass.add.us.epil = add i64 %mul135.us.epil, %div138.us.epil
  %reass.mul.us.epil = mul i64 %reass.add.us.epil, %49
  %add160.us.epil = add i64 %sub143.us.epil, %reass.mul.us.epil, !dbg !503
  %mul161.us.epil = mul i64 %add160.us.epil, %call64388, !dbg !504
  br label %cond.end168.us.epil, !dbg !497

cond.end168.us.epil:                              ; preds = %cond.true155.us.epil, %cond.false162.us.epil
  %cond169.us.epil = phi i64 [ %mul161.us.epil, %cond.true155.us.epil ], [ %add167.us.epil, %cond.false162.us.epil ], !dbg !497
  %add.ptr170.us.epil = getelementptr inbounds i8, ptr %cond, i64 %cond169.us.epil, !dbg !505
  call void @llvm.dbg.value(metadata ptr %add.ptr170.us.epil, metadata !394, metadata !DIExpression()), !dbg !479
  call void @__csan_load(i64 %128, ptr nonnull %data171, i32 8, i64 8), !dbg !506
  %151 = load ptr, ptr %data171, align 8, !dbg !506, !tbaa !489
  %mul172.us.epil = mul i64 %sub143.us.epil, %79, !dbg !507
  %mul173.us.epil = mul i64 %div138.us.epil, %76, !dbg !508
  %mul175.us.epil = mul i64 %div134.us.epil, %80, !dbg !509
  %add174.us.epil = add i64 %mul173.us.epil, %mul175.us.epil, !dbg !510
  %add176.us.epil = add i64 %add174.us.epil, %mul172.us.epil, !dbg !511
  %add.ptr177.us.epil = getelementptr inbounds i8, ptr %151, i64 %add176.us.epil, !dbg !512
  call void @llvm.dbg.value(metadata ptr %add.ptr177.us.epil, metadata !395, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %mul108.us, metadata !396, metadata !DIExpression()), !dbg !513
  br i1 %139, label %for.body185.us.epil, label %for.cond206.preheader.us.epil, !dbg !514

for.body185.us.epil:                              ; preds = %cond.end168.us.epil, %.noexc398
  %ir0.0375.us.epil = phi i64 [ %add205.us.epil, %.noexc398 ], [ %mul108.us, %cond.end168.us.epil ]
  call void @llvm.dbg.value(metadata i64 %ir0.0375.us.epil, metadata !396, metadata !DIExpression()), !dbg !513
  %sub187.us.epil = sub nsw i64 %ir0.0375.us.epil, %mul108.us, !dbg !515
  %arrayidx188.us.epil = getelementptr inbounds [32 x float], ptr %tmp.us.epil, i64 0, i64 %sub187.us.epil, !dbg !518
  %mul192.us.epil = mul i64 %ir0.0375.us.epil, %41, !dbg !519
  %add.ptr193.us.epil = getelementptr inbounds i8, ptr %add.ptr.us.epil, i64 %mul192.us.epil, !dbg !520
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_before_call(i64 %129, i64 -1, i8 3, i64 1), !dbg !521
  invoke void %86(i32 noundef %conv186, ptr noundef nonnull %arrayidx188.us.epil, i64 noundef %conv191, ptr noundef %add.ptr193.us.epil, i64 noundef %cond198, ptr noundef %add.ptr170.us.epil, i64 noundef %cond203, i32 noundef %conv204)
          to label %.noexc398 unwind label %csi.cleanup389.loopexit.split-lp.loopexit, !dbg !521

.noexc398:                                        ; preds = %for.body185.us.epil
  call void @__csan_after_call(i64 %129, i64 -1, i8 3, i64 1), !dbg !522
  %add205.us.epil = add nsw i64 %ir0.0375.us.epil, %nrc.0, !dbg !522
  call void @llvm.dbg.value(metadata i64 %add205.us.epil, metadata !396, metadata !DIExpression()), !dbg !513
  %152 = icmp slt i64 %add205.us.epil, %invariant.smin.us, !dbg !523
  br i1 %152, label %for.body185.us.epil, label %for.cond206.preheader.us.epil, !dbg !514, !llvm.loop !524

for.cond206.preheader.us.epil:                    ; preds = %.noexc398, %cond.end168.us.epil
  call void @llvm.dbg.value(metadata i32 0, metadata !398, metadata !DIExpression()), !dbg !526
  br i1 %cmp208376, label %for.body210.us.epil.split, label %for.cond.cleanup209.us.epil, !dbg !527

for.body210.us.epil.split:                        ; preds = %for.cond206.preheader.us.epil, %for.body210.us.epil.split
  %indvars.iv.epil = phi i64 [ %indvars.iv.next.epil, %for.body210.us.epil.split ], [ 0, %for.cond206.preheader.us.epil ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv.epil, metadata !398, metadata !DIExpression()), !dbg !526
  %mul212.us.epil = mul i64 %indvars.iv.epil, %79, !dbg !528
  %div213.us.epil = udiv i64 %mul212.us.epil, %77, !dbg !531
  %add214.us.epil = add i64 %div213.us.epil, %mul108.us, !dbg !532
  %arrayidx215.us.epil = getelementptr inbounds float, ptr %add.ptr177.us.epil, i64 %add214.us.epil, !dbg !533
  %mul216.us.epil = shl i64 %indvars.iv.epil, 4, !dbg !534
  %idx.ext.us.epil = and i64 %mul216.us.epil, 4294967280, !dbg !535
  %add.ptr217.us.epil = getelementptr inbounds float, ptr %tmp.us.epil, i64 %idx.ext.us.epil, !dbg !535
  call void @__csan_large_store(i64 %148, ptr %arrayidx215.us.epil, i64 %mul226.us, i64 4), !dbg !536
  call void @__csan_large_load(i64 %130, ptr nonnull %add.ptr217.us.epil, i64 %mul226.us, i64 4), !dbg !536
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %arrayidx215.us.epil, ptr nonnull align 4 %add.ptr217.us.epil, i64 %mul226.us, i1 false), !dbg !536
  %indvars.iv.next.epil = add nuw nsw i64 %indvars.iv.epil, 1, !dbg !537
  call void @llvm.dbg.value(metadata i64 %indvars.iv.next.epil, metadata !398, metadata !DIExpression()), !dbg !526
  %exitcond.not.epil = icmp eq i64 %indvars.iv.next.epil, %nrc.0, !dbg !538
  br i1 %exitcond.not.epil, label %for.cond.cleanup209.us.epil, label %for.body210.us.epil.split, !dbg !527, !llvm.loop !539

for.cond.cleanup209.us.epil:                      ; preds = %for.body210.us.epil.split, %for.cond206.preheader.us.epil
  %add230.us.epil = add nsw i64 %ir1.0380.us.epil, %nrc.0, !dbg !541
  call void @llvm.dbg.value(metadata i64 %add230.us.epil, metadata !381, metadata !DIExpression()), !dbg !463
  %153 = icmp slt i64 %add230.us.epil, %invariant.smin379.us.epil, !dbg !465
  br i1 %153, label %for.body.us.epil, label %for.cond.cleanup.us.epil, !dbg !466, !llvm.loop !542

for.cond.cleanup.us.epil:                         ; preds = %for.cond.cleanup209.us.epil, %pfor.cond123.us.epil
  call void @llvm.lifetime.end.p0(i64 128, ptr nonnull %tmp.us.epil) #14, !dbg !467
  call void @llvm.dbg.value(metadata i64 %sub120, metadata !372, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_constu, 1152921504606846974, DW_OP_and, DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !456
  br i1 %epil.iter.cmp.not, label %pfor.cond.cleanup.us, label %pfor.cond123.us.epil.1, !dbg !469

pfor.cond123.us.epil.1:                           ; preds = %for.cond.cleanup.us.epil
  call void @llvm.dbg.value(metadata i64 %sub120, metadata !372, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_constu, 1152921504606846974, DW_OP_and, DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !456
  call void @llvm.dbg.value(metadata i64 %add129.us.epil, metadata !374, metadata !DIExpression()), !dbg !460
  call void @llvm.lifetime.start.p0(i64 128, ptr nonnull %tmp.us.epil) #14, !dbg !461
  call void @llvm.dbg.declare(metadata ptr %tmp.us.epil, metadata !376, metadata !DIExpression()), !dbg !462
  call void @llvm.dbg.value(metadata i64 %add129.us.epil, metadata !381, metadata !DIExpression()), !dbg !463
  br i1 %103, label %for.body.us.epil.1.preheader, label %for.cond.cleanup.us.epil.1, !dbg !466

for.body.us.epil.1.preheader:                     ; preds = %pfor.cond123.us.epil.1
  %154 = load i64, ptr @__csi_unit_store_base_id, align 8
  %155 = add i64 %154, 1
  br label %for.body.us.epil.1, !dbg !466

for.body.us.epil.1:                               ; preds = %for.body.us.epil.1.preheader, %for.cond.cleanup209.us.epil.1
  %ir1.0380.us.epil.1 = phi i64 [ %add230.us.epil.1, %for.cond.cleanup209.us.epil.1 ], [ %add129.us.epil, %for.body.us.epil.1.preheader ]
  call void @llvm.dbg.value(metadata i64 %ir1.0380.us.epil.1, metadata !381, metadata !DIExpression()), !dbg !463
  %div134.us.epil.1 = sdiv i64 %ir1.0380.us.epil.1, %mul, !dbg !478
  call void @llvm.dbg.value(metadata i64 %div134.us.epil.1, metadata !383, metadata !DIExpression()), !dbg !479
  %mul135.us.epil.1 = mul nsw i64 %div134.us.epil.1, %51, !dbg !480
  %mul136.us.epil.1 = mul nsw i64 %mul135.us.epil.1, %78, !dbg !481
  %sub137.us.epil.1 = sub nsw i64 %ir1.0380.us.epil.1, %mul136.us.epil.1, !dbg !482
  %div138.us.epil.1 = sdiv i64 %sub137.us.epil.1, %78, !dbg !483
  call void @llvm.dbg.value(metadata i64 %div138.us.epil.1, metadata !386, metadata !DIExpression()), !dbg !479
  %mul142.us.epil.1 = mul nsw i64 %div138.us.epil.1, %78, !dbg !484
  %sub143.us.epil.1 = sub nsw i64 %sub137.us.epil.1, %mul142.us.epil.1, !dbg !485
  call void @llvm.dbg.value(metadata i64 %sub143.us.epil.1, metadata !387, metadata !DIExpression()), !dbg !479
  %div144.us.epil.1 = sdiv i64 %div134.us.epil.1, %div61, !dbg !486
  call void @llvm.dbg.value(metadata i64 %div144.us.epil.1, metadata !388, metadata !DIExpression()), !dbg !479
  %div145.us.epil.1 = sdiv i64 %div138.us.epil.1, %div, !dbg !487
  call void @llvm.dbg.value(metadata i64 %div145.us.epil.1, metadata !389, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %sub143.us.epil.1, metadata !390, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %div138.us.epil.1, metadata !391, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %div134.us.epil.1, metadata !392, metadata !DIExpression()), !dbg !479
  call void @__csan_load(i64 %131, ptr nonnull %data146, i32 8, i64 8), !dbg !488
  %156 = load ptr, ptr %data146, align 8, !dbg !488, !tbaa !489
  %mul147.us.epil.1 = mul i64 %div145.us.epil.1, %43, !dbg !490
  %mul149.us.epil.1 = mul i64 %div144.us.epil.1, %45, !dbg !491
  %add150.us.epil.1 = add i64 %mul147.us.epil.1, %mul149.us.epil.1, !dbg !492
  %add.ptr.us.epil.1 = getelementptr inbounds i8, ptr %156, i64 %add150.us.epil.1, !dbg !493
  call void @llvm.dbg.value(metadata ptr %add.ptr.us.epil.1, metadata !393, metadata !DIExpression()), !dbg !479
  br i1 %call387, label %cond.true155.us.epil.1, label %lor.lhs.false152.us.epil.1, !dbg !494

lor.lhs.false152.us.epil.1:                       ; preds = %for.body.us.epil.1
  call void @__csan_load(i64 %132, ptr nonnull %31, i32 4, i64 8), !dbg !495
  %157 = load i32, ptr %31, align 8, !dbg !495, !tbaa !415
  %cmp154.not.us.epil.1 = icmp eq i32 %157, %88, !dbg !496
  br i1 %cmp154.not.us.epil.1, label %cond.false162.us.epil.1, label %cond.true155.us.epil.1, !dbg !497

cond.false162.us.epil.1:                          ; preds = %lor.lhs.false152.us.epil.1
  %mul163.us.epil.1 = mul i64 %sub143.us.epil.1, %55, !dbg !498
  %mul164.us.epil.1 = mul i64 %div138.us.epil.1, %57, !dbg !499
  %mul166.us.epil.1 = mul i64 %div134.us.epil.1, %59, !dbg !500
  %add165.us.epil.1 = add i64 %mul164.us.epil.1, %mul166.us.epil.1, !dbg !501
  %add167.us.epil.1 = add i64 %add165.us.epil.1, %mul163.us.epil.1, !dbg !502
  br label %cond.end168.us.epil.1, !dbg !497

cond.true155.us.epil.1:                           ; preds = %lor.lhs.false152.us.epil.1, %for.body.us.epil.1
  %reass.add.us.epil.1 = add i64 %mul135.us.epil.1, %div138.us.epil.1
  %reass.mul.us.epil.1 = mul i64 %reass.add.us.epil.1, %49
  %add160.us.epil.1 = add i64 %sub143.us.epil.1, %reass.mul.us.epil.1, !dbg !503
  %mul161.us.epil.1 = mul i64 %add160.us.epil.1, %call64388, !dbg !504
  br label %cond.end168.us.epil.1, !dbg !497

cond.end168.us.epil.1:                            ; preds = %cond.true155.us.epil.1, %cond.false162.us.epil.1
  %cond169.us.epil.1 = phi i64 [ %mul161.us.epil.1, %cond.true155.us.epil.1 ], [ %add167.us.epil.1, %cond.false162.us.epil.1 ], !dbg !497
  %add.ptr170.us.epil.1 = getelementptr inbounds i8, ptr %cond, i64 %cond169.us.epil.1, !dbg !505
  call void @llvm.dbg.value(metadata ptr %add.ptr170.us.epil.1, metadata !394, metadata !DIExpression()), !dbg !479
  call void @__csan_load(i64 %133, ptr nonnull %data171, i32 8, i64 8), !dbg !506
  %158 = load ptr, ptr %data171, align 8, !dbg !506, !tbaa !489
  %mul172.us.epil.1 = mul i64 %sub143.us.epil.1, %79, !dbg !507
  %mul173.us.epil.1 = mul i64 %div138.us.epil.1, %76, !dbg !508
  %mul175.us.epil.1 = mul i64 %div134.us.epil.1, %80, !dbg !509
  %add174.us.epil.1 = add i64 %mul173.us.epil.1, %mul175.us.epil.1, !dbg !510
  %add176.us.epil.1 = add i64 %add174.us.epil.1, %mul172.us.epil.1, !dbg !511
  %add.ptr177.us.epil.1 = getelementptr inbounds i8, ptr %158, i64 %add176.us.epil.1, !dbg !512
  call void @llvm.dbg.value(metadata ptr %add.ptr177.us.epil.1, metadata !395, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %mul108.us, metadata !396, metadata !DIExpression()), !dbg !513
  br i1 %139, label %for.body185.us.epil.1, label %for.cond206.preheader.us.epil.1, !dbg !514

for.body185.us.epil.1:                            ; preds = %cond.end168.us.epil.1, %.noexc397
  %ir0.0375.us.epil.1 = phi i64 [ %add205.us.epil.1, %.noexc397 ], [ %mul108.us, %cond.end168.us.epil.1 ]
  call void @llvm.dbg.value(metadata i64 %ir0.0375.us.epil.1, metadata !396, metadata !DIExpression()), !dbg !513
  %sub187.us.epil.1 = sub nsw i64 %ir0.0375.us.epil.1, %mul108.us, !dbg !515
  %arrayidx188.us.epil.1 = getelementptr inbounds [32 x float], ptr %tmp.us.epil, i64 0, i64 %sub187.us.epil.1, !dbg !518
  %mul192.us.epil.1 = mul i64 %ir0.0375.us.epil.1, %41, !dbg !519
  %add.ptr193.us.epil.1 = getelementptr inbounds i8, ptr %add.ptr.us.epil.1, i64 %mul192.us.epil.1, !dbg !520
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_before_call(i64 %134, i64 -1, i8 3, i64 1), !dbg !521
  invoke void %86(i32 noundef %conv186, ptr noundef nonnull %arrayidx188.us.epil.1, i64 noundef %conv191, ptr noundef %add.ptr193.us.epil.1, i64 noundef %cond198, ptr noundef %add.ptr170.us.epil.1, i64 noundef %cond203, i32 noundef %conv204)
          to label %.noexc397 unwind label %csi.cleanup389.loopexit, !dbg !521

.noexc397:                                        ; preds = %for.body185.us.epil.1
  call void @__csan_after_call(i64 %134, i64 -1, i8 3, i64 1), !dbg !522
  %add205.us.epil.1 = add nsw i64 %ir0.0375.us.epil.1, %nrc.0, !dbg !522
  call void @llvm.dbg.value(metadata i64 %add205.us.epil.1, metadata !396, metadata !DIExpression()), !dbg !513
  %159 = icmp slt i64 %add205.us.epil.1, %invariant.smin.us, !dbg !523
  br i1 %159, label %for.body185.us.epil.1, label %for.cond206.preheader.us.epil.1, !dbg !514, !llvm.loop !524

for.cond206.preheader.us.epil.1:                  ; preds = %.noexc397, %cond.end168.us.epil.1
  call void @llvm.dbg.value(metadata i32 0, metadata !398, metadata !DIExpression()), !dbg !526
  br i1 %cmp208376, label %for.body210.us.epil.1.split, label %for.cond.cleanup209.us.epil.1, !dbg !527

for.body210.us.epil.1.split:                      ; preds = %for.cond206.preheader.us.epil.1, %for.body210.us.epil.1.split
  %indvars.iv.epil.1 = phi i64 [ %indvars.iv.next.epil.1, %for.body210.us.epil.1.split ], [ 0, %for.cond206.preheader.us.epil.1 ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv.epil.1, metadata !398, metadata !DIExpression()), !dbg !526
  %mul212.us.epil.1 = mul i64 %indvars.iv.epil.1, %79, !dbg !528
  %div213.us.epil.1 = udiv i64 %mul212.us.epil.1, %77, !dbg !531
  %add214.us.epil.1 = add i64 %div213.us.epil.1, %mul108.us, !dbg !532
  %arrayidx215.us.epil.1 = getelementptr inbounds float, ptr %add.ptr177.us.epil.1, i64 %add214.us.epil.1, !dbg !533
  %mul216.us.epil.1 = shl i64 %indvars.iv.epil.1, 4, !dbg !534
  %idx.ext.us.epil.1 = and i64 %mul216.us.epil.1, 4294967280, !dbg !535
  %add.ptr217.us.epil.1 = getelementptr inbounds float, ptr %tmp.us.epil, i64 %idx.ext.us.epil.1, !dbg !535
  call void @__csan_large_store(i64 %155, ptr %arrayidx215.us.epil.1, i64 %mul226.us, i64 4), !dbg !536
  call void @__csan_large_load(i64 %135, ptr nonnull %add.ptr217.us.epil.1, i64 %mul226.us, i64 4), !dbg !536
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %arrayidx215.us.epil.1, ptr nonnull align 4 %add.ptr217.us.epil.1, i64 %mul226.us, i1 false), !dbg !536
  %indvars.iv.next.epil.1 = add nuw nsw i64 %indvars.iv.epil.1, 1, !dbg !537
  call void @llvm.dbg.value(metadata i64 %indvars.iv.next.epil.1, metadata !398, metadata !DIExpression()), !dbg !526
  %exitcond.not.epil.1 = icmp eq i64 %indvars.iv.next.epil.1, %nrc.0, !dbg !538
  br i1 %exitcond.not.epil.1, label %for.cond.cleanup209.us.epil.1, label %for.body210.us.epil.1.split, !dbg !527, !llvm.loop !539

for.cond.cleanup209.us.epil.1:                    ; preds = %for.body210.us.epil.1.split, %for.cond206.preheader.us.epil.1
  %add230.us.epil.1 = add nsw i64 %ir1.0380.us.epil.1, %nrc.0, !dbg !541
  call void @llvm.dbg.value(metadata i64 %add230.us.epil.1, metadata !381, metadata !DIExpression()), !dbg !463
  %160 = icmp slt i64 %add230.us.epil.1, %invariant.smin379.us.epil.1, !dbg !465
  br i1 %160, label %for.body.us.epil.1, label %for.cond.cleanup.us.epil.1, !dbg !466, !llvm.loop !542

for.cond.cleanup.us.epil.1:                       ; preds = %for.cond.cleanup209.us.epil.1, %pfor.cond123.us.epil.1
  call void @llvm.lifetime.end.p0(i64 128, ptr nonnull %tmp.us.epil) #14, !dbg !467
  call void @llvm.dbg.value(metadata i64 %sub120, metadata !372, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_constu, 1152921504606846974, DW_OP_and, DW_OP_plus_uconst, 2, DW_OP_stack_value)), !dbg !456
  br label %pfor.cond.cleanup.us

pfor.cond.cleanup.us:                             ; preds = %for.cond.cleanup.us.epil.1, %for.cond.cleanup.us.epil
  call void @__csan_sync(i64 %136, i32 0), !dbg !469
  sync within %syncreg110.us, label %sync.continue.us, !dbg !469

sync.continue.us:                                 ; preds = %pfor.cond.cleanup.us
  invoke void @llvm.sync.unwind(token %syncreg110.us)
          to label %.noexc396 unwind label %csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split-lp, !dbg !469

.noexc396:                                        ; preds = %sync.continue.us
  call void @__csan_task_exit(i64 %9, i64 %8, i64 %7, i32 0, i64 1), !dbg !543
  reattach within %syncreg, label %pfor.inc236.us, !dbg !543

pfor.inc236.us:                                   ; preds = %pfor.cond.us, %.noexc396
  call void @__csan_detach_continue(i64 %11, i64 %7, i32 0, i64 2), !dbg !544
  %inc237.us = add nuw nsw i64 %__begin.0.us, 1, !dbg !544
  call void @llvm.dbg.value(metadata i64 %inc237.us, metadata !364, metadata !DIExpression()), !dbg !446
  %exitcond384.not = icmp eq i64 %__begin.0.us, %div106373, !dbg !545
  br i1 %exitcond384.not, label %pfor.cond.cleanup239.loopexit, label %pfor.cond.us, !dbg !546, !llvm.loop !547

for.body.us:                                      ; preds = %for.body.us.preheader, %for.cond.cleanup209.us
  %ir1.0380.us = phi i64 [ %add230.us, %for.cond.cleanup209.us ], [ %mul125.us, %for.body.us.preheader ]
  call void @llvm.dbg.value(metadata i64 %ir1.0380.us, metadata !381, metadata !DIExpression()), !dbg !463
  %div134.us = sdiv i64 %ir1.0380.us, %mul, !dbg !478
  call void @llvm.dbg.value(metadata i64 %div134.us, metadata !383, metadata !DIExpression()), !dbg !479
  %mul135.us = mul nsw i64 %div134.us, %51, !dbg !480
  %mul136.us = mul nsw i64 %mul135.us, %78, !dbg !481
  %sub137.us = sub nsw i64 %ir1.0380.us, %mul136.us, !dbg !482
  %div138.us = sdiv i64 %sub137.us, %78, !dbg !483
  call void @llvm.dbg.value(metadata i64 %div138.us, metadata !386, metadata !DIExpression()), !dbg !479
  %mul142.us = mul nsw i64 %div138.us, %78, !dbg !484
  %sub143.us = sub nsw i64 %sub137.us, %mul142.us, !dbg !485
  call void @llvm.dbg.value(metadata i64 %sub143.us, metadata !387, metadata !DIExpression()), !dbg !479
  %div144.us = sdiv i64 %div134.us, %div61, !dbg !486
  call void @llvm.dbg.value(metadata i64 %div144.us, metadata !388, metadata !DIExpression()), !dbg !479
  %div145.us = sdiv i64 %div138.us, %div, !dbg !487
  call void @llvm.dbg.value(metadata i64 %div145.us, metadata !389, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %sub143.us, metadata !390, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %div138.us, metadata !391, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %div134.us, metadata !392, metadata !DIExpression()), !dbg !479
  call void @__csan_load(i64 %120, ptr nonnull %data146, i32 8, i64 8), !dbg !488
  %161 = load ptr, ptr %data146, align 8, !dbg !488, !tbaa !489
  %mul147.us = mul i64 %div145.us, %43, !dbg !490
  %mul149.us = mul i64 %div144.us, %45, !dbg !491
  %add150.us = add i64 %mul147.us, %mul149.us, !dbg !492
  %add.ptr.us = getelementptr inbounds i8, ptr %161, i64 %add150.us, !dbg !493
  call void @llvm.dbg.value(metadata ptr %add.ptr.us, metadata !393, metadata !DIExpression()), !dbg !479
  br i1 %call387, label %cond.true155.us, label %lor.lhs.false152.us, !dbg !494

lor.lhs.false152.us:                              ; preds = %for.body.us
  call void @__csan_load(i64 %121, ptr nonnull %31, i32 4, i64 8), !dbg !495
  %162 = load i32, ptr %31, align 8, !dbg !495, !tbaa !415
  %cmp154.not.us = icmp eq i32 %162, %88, !dbg !496
  br i1 %cmp154.not.us, label %cond.false162.us, label %cond.true155.us, !dbg !497

cond.false162.us:                                 ; preds = %lor.lhs.false152.us
  %mul163.us = mul i64 %sub143.us, %55, !dbg !498
  %mul164.us = mul i64 %div138.us, %57, !dbg !499
  %mul166.us = mul i64 %div134.us, %59, !dbg !500
  %add165.us = add i64 %mul164.us, %mul166.us, !dbg !501
  %add167.us = add i64 %add165.us, %mul163.us, !dbg !502
  br label %cond.end168.us, !dbg !497

cond.true155.us:                                  ; preds = %lor.lhs.false152.us, %for.body.us
  %reass.add.us = add i64 %mul135.us, %div138.us
  %reass.mul.us = mul i64 %reass.add.us, %49
  %add160.us = add i64 %sub143.us, %reass.mul.us, !dbg !503
  %mul161.us = mul i64 %add160.us, %call64388, !dbg !504
  br label %cond.end168.us, !dbg !497

cond.end168.us:                                   ; preds = %cond.true155.us, %cond.false162.us
  %cond169.us = phi i64 [ %mul161.us, %cond.true155.us ], [ %add167.us, %cond.false162.us ], !dbg !497
  %add.ptr170.us = getelementptr inbounds i8, ptr %cond, i64 %cond169.us, !dbg !505
  call void @llvm.dbg.value(metadata ptr %add.ptr170.us, metadata !394, metadata !DIExpression()), !dbg !479
  call void @__csan_load(i64 %122, ptr nonnull %data171, i32 8, i64 8), !dbg !506
  %163 = load ptr, ptr %data171, align 8, !dbg !506, !tbaa !489
  %mul172.us = mul i64 %sub143.us, %79, !dbg !507
  %mul173.us = mul i64 %div138.us, %76, !dbg !508
  %mul175.us = mul i64 %div134.us, %80, !dbg !509
  %add174.us = add i64 %mul173.us, %mul175.us, !dbg !510
  %add176.us = add i64 %add174.us, %mul172.us, !dbg !511
  %add.ptr177.us = getelementptr inbounds i8, ptr %163, i64 %add176.us, !dbg !512
  call void @llvm.dbg.value(metadata ptr %add.ptr177.us, metadata !395, metadata !DIExpression()), !dbg !479
  call void @llvm.dbg.value(metadata i64 %mul108.us, metadata !396, metadata !DIExpression()), !dbg !513
  br i1 %139, label %for.body185.us, label %for.cond206.preheader.us, !dbg !514

for.cond.cleanup209.us:                           ; preds = %for.body210.us.split, %for.cond206.preheader.us
  %add230.us = add nsw i64 %ir1.0380.us, %nrc.0, !dbg !541
  call void @llvm.dbg.value(metadata i64 %add230.us, metadata !381, metadata !DIExpression()), !dbg !463
  %164 = icmp slt i64 %add230.us, %invariant.smin379.us, !dbg !465
  br i1 %164, label %for.body.us, label %for.cond.cleanup.us, !dbg !466, !llvm.loop !542

for.body210.us.split:                             ; preds = %for.cond206.preheader.us, %for.body210.us.split
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body210.us.split ], [ 0, %for.cond206.preheader.us ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv, metadata !398, metadata !DIExpression()), !dbg !526
  %mul212.us = mul i64 %indvars.iv, %79, !dbg !528
  %div213.us = udiv i64 %mul212.us, %77, !dbg !531
  %add214.us = add i64 %div213.us, %mul108.us, !dbg !532
  %arrayidx215.us = getelementptr inbounds float, ptr %add.ptr177.us, i64 %add214.us, !dbg !533
  %mul216.us = shl i64 %indvars.iv, 4, !dbg !534
  %idx.ext.us = and i64 %mul216.us, 4294967280, !dbg !535
  %add.ptr217.us = getelementptr inbounds float, ptr %tmp.us, i64 %idx.ext.us, !dbg !535
  call void @__csan_large_store(i64 %147, ptr %arrayidx215.us, i64 %mul226.us, i64 4), !dbg !536
  call void @__csan_large_load(i64 %124, ptr nonnull %add.ptr217.us, i64 %mul226.us, i64 4), !dbg !536
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %arrayidx215.us, ptr nonnull align 4 %add.ptr217.us, i64 %mul226.us, i1 false), !dbg !536
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !537
  call void @llvm.dbg.value(metadata i64 %indvars.iv.next, metadata !398, metadata !DIExpression()), !dbg !526
  %exitcond.not = icmp eq i64 %indvars.iv.next, %nrc.0, !dbg !538
  br i1 %exitcond.not, label %for.cond.cleanup209.us, label %for.body210.us.split, !dbg !527, !llvm.loop !539

for.body185.us:                                   ; preds = %cond.end168.us, %.noexc395
  %ir0.0375.us = phi i64 [ %add205.us, %.noexc395 ], [ %mul108.us, %cond.end168.us ]
  call void @llvm.dbg.value(metadata i64 %ir0.0375.us, metadata !396, metadata !DIExpression()), !dbg !513
  %sub187.us = sub nsw i64 %ir0.0375.us, %mul108.us, !dbg !515
  %arrayidx188.us = getelementptr inbounds [32 x float], ptr %tmp.us, i64 0, i64 %sub187.us, !dbg !518
  %mul192.us = mul i64 %ir0.0375.us, %41, !dbg !519
  %add.ptr193.us = getelementptr inbounds i8, ptr %add.ptr.us, i64 %mul192.us, !dbg !520
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_set_MAAP(i8 3, i64 -1), !dbg !521
  call void @__csan_before_call(i64 %123, i64 -1, i8 3, i64 1), !dbg !521
  invoke void %86(i32 noundef %conv186, ptr noundef nonnull %arrayidx188.us, i64 noundef %conv191, ptr noundef %add.ptr193.us, i64 noundef %cond198, ptr noundef %add.ptr170.us, i64 noundef %cond203, i32 noundef %conv204)
          to label %.noexc395 unwind label %csi.cleanup389391393, !dbg !521

.noexc395:                                        ; preds = %for.body185.us
  call void @__csan_after_call(i64 %123, i64 -1, i8 3, i64 1), !dbg !522
  %add205.us = add nsw i64 %ir0.0375.us, %nrc.0, !dbg !522
  call void @llvm.dbg.value(metadata i64 %add205.us, metadata !396, metadata !DIExpression()), !dbg !513
  %165 = icmp slt i64 %add205.us, %invariant.smin.us, !dbg !523
  br i1 %165, label %for.body185.us, label %for.cond206.preheader.us, !dbg !514, !llvm.loop !524

for.cond206.preheader.us:                         ; preds = %.noexc395, %cond.end168.us
  call void @llvm.dbg.value(metadata i32 0, metadata !398, metadata !DIExpression()), !dbg !526
  br i1 %cmp208376, label %for.body210.us.split, label %for.cond.cleanup209.us, !dbg !527

pfor.cond.cleanup239.loopexit:                    ; preds = %pfor.inc236.us
  call void @__csan_after_loop(i64 %104, i8 0, i64 1), !dbg !546
  br label %pfor.cond.cleanup239, !dbg !546

pfor.cond.cleanup239:                             ; preds = %pfor.cond.cleanup239.loopexit, %pfor.ph
  %166 = load i64, ptr @__csi_unit_sync_base_id, align 8, !dbg !546, !invariant.load !402
  %167 = add i64 %166, 2, !dbg !546
  call void @__csan_sync(i64 %167, i32 0), !dbg !546
  sync within %syncreg, label %sync.continue241, !dbg !546

sync.continue241:                                 ; preds = %pfor.cond.cleanup239
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %cleanup244 unwind label %csi.cleanup.loopexit.split-lp.csi-split-lp, !dbg !546

cleanup244:                                       ; preds = %sync.continue241, %cond.end101
  %168 = load i64, ptr @__csi_unit_func_exit_base_id, align 8, !dbg !549, !invariant.load !402
  call void @__csan_func_exit(i64 %168, i64 %0, i64 1), !dbg !400
  ret void, !dbg !549

csi.cleanup.loopexit:                             ; preds = %csi.cleanup389, %pfor.cond.us
  %lpad.loopexit402 = landingpad { ptr, i32 }
          cleanup, !dbg !451
  call void @__csan_after_loop(i64 %104, i8 0, i64 1), !dbg !451
  call void @__csan_detach_continue(i64 %12, i64 %7, i32 0, i64 3), !dbg !451
  br label %csi.cleanup, !dbg !451

csi.cleanup.loopexit.split-lp.csi-split-lp:       ; preds = %sync.continue241
  %lpad.csi-split-lp405 = landingpad { ptr, i32 }
          cleanup, !dbg !451
  br label %csi.cleanup, !dbg !451

csi.cleanup.loopexit.split-lp.csi-split:          ; preds = %call.noexc, %75
  %169 = phi i64 [ %94, %call.noexc ], [ %84, %75 ], !dbg !451
  %170 = phi i64 [ %95, %call.noexc ], [ %83, %75 ], !dbg !451
  %171 = phi i8 [ 0, %call.noexc ], [ 1, %75 ], !dbg !451
  %lpad.csi-split406 = landingpad { ptr, i32 }
          cleanup, !dbg !451
  call void @__csan_after_call(i64 %169, i64 %170, i8 %171, i64 2), !dbg !451
  br label %csi.cleanup, !dbg !451

csi.cleanup:                                      ; preds = %csi.cleanup.loopexit.split-lp.csi-split-lp, %csi.cleanup.loopexit.split-lp.csi-split, %csi.cleanup.loopexit
  %lpad.phi403 = phi { ptr, i32 } [ %lpad.loopexit402, %csi.cleanup.loopexit ], [ %lpad.csi-split-lp405, %csi.cleanup.loopexit.split-lp.csi-split-lp ], [ %lpad.csi-split406, %csi.cleanup.loopexit.split-lp.csi-split ]
  %172 = load i64, ptr @__csi_unit_func_exit_base_id, align 8, !dbg !451, !invariant.load !402
  %173 = add i64 %172, 1, !dbg !451
  call void @__csan_func_exit(i64 %173, i64 %0, i64 3), !dbg !400
  resume { ptr, i32 } %lpad.phi403, !dbg !451

csi.cleanup.unreachable:                          ; preds = %csi.cleanup389391393, %csi.cleanup389391, %csi.cleanup389
  unreachable

csi.cleanup389.loopexit:                          ; preds = %for.body185.us.epil.1
  %lpad.loopexit = landingpad { ptr, i32 }
          cleanup, !dbg !451
  call void @__csan_after_call(i64 %134, i64 -1, i8 3, i64 3), !dbg !451
  br label %csi.cleanup389, !dbg !451

csi.cleanup389.loopexit.split-lp.loopexit:        ; preds = %for.body185.us.epil
  %lpad.loopexit399 = landingpad { ptr, i32 }
          cleanup, !dbg !451
  call void @__csan_after_call(i64 %129, i64 -1, i8 3, i64 3), !dbg !451
  br label %csi.cleanup389, !dbg !451

csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split-lp: ; preds = %sync.continue.us
  %lpad.csi-split-lp = landingpad { ptr, i32 }
          cleanup, !dbg !451
  br label %csi.cleanup389, !dbg !451

csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split: ; preds = %csi.cleanup389391, %pfor.ph116.us.new
  %lpad.csi-split = landingpad { ptr, i32 }
          cleanup, !dbg !451
  call void @__csan_detach_continue(i64 %111, i64 %106, i32 0, i64 1), !dbg !451
  br label %csi.cleanup389, !dbg !451

csi.cleanup389:                                   ; preds = %csi.cleanup389.loopexit.split-lp.loopexit, %csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split, %csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split-lp, %csi.cleanup389.loopexit
  %lpad.phi = phi { ptr, i32 } [ %lpad.loopexit, %csi.cleanup389.loopexit ], [ %lpad.loopexit399, %csi.cleanup389.loopexit.split-lp.loopexit ], [ %lpad.csi-split-lp, %csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split-lp ], [ %lpad.csi-split, %csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split ]
  call void @__csan_task_exit(i64 %10, i64 %8, i64 %7, i32 0, i64 1), !dbg !451
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg, { ptr, i32 } %lpad.phi)
          to label %csi.cleanup.unreachable unwind label %csi.cleanup.loopexit, !dbg !451

csi.cleanup389391:                                ; preds = %pfor.cond123.us.strpm.outer, %csi.cleanup389391393
  %csi.cleanup.lpad390392 = landingpad { ptr, i32 }
          cleanup, !dbg !458
  call void @__csan_after_loop(i64 %118, i8 0, i64 1), !dbg !458
  call void @__csan_detach_continue(i64 %117, i64 %112, i32 0, i64 3), !dbg !458
  call void @__csan_task_exit(i64 %109, i64 %107, i64 %106, i32 0, i64 0), !dbg !458
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg110.us, { ptr, i32 } %csi.cleanup.lpad390392)
          to label %csi.cleanup.unreachable unwind label %csi.cleanup389.loopexit.split-lp.loopexit.split-lp.csi-split, !dbg !458

csi.cleanup389391393:                             ; preds = %for.body185.us
  %csi.cleanup.lpad390392394 = landingpad { ptr, i32 }
          cleanup, !dbg !458
  call void @__csan_after_call(i64 %123, i64 -1, i8 3, i64 3), !dbg !458
  call void @__csan_task_exit(i64 %115, i64 %113, i64 %112, i32 0, i64 1), !dbg !458
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg110.us.strpm.detachloop, { ptr, i32 } %csi.cleanup.lpad390392394)
          to label %csi.cleanup.unreachable unwind label %csi.cleanup389391, !dbg !458
}

; CHECK: define internal fastcc void @_Z28ggml_compute_forward_mul_matPK19ggml_compute_paramsP11ggml_tensor.outline_pfor.cond.us.ls1(
; CHECK: pfor.cond.us.preheader.split.split.ls1:
; CHECK-NEXT: %[[NESTED_SPAWN_SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
; CHECK-NEXT: %[[LOOP_DAC_SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
; CHECK: br label %[[LOOP_DAC_HEADER:.+]], !dbg

; CHECK: [[LOOP_DAC_HEADER]]:

; The task-simplify pass should optimize away the unwind edge from the DAC spawn,
; which should not depend on the inserted taskframe for the loop body.
; CHECK: detach within %[[LOOP_DAC_SYNCREG]], label %[[DAC_SPAWN:.+]], label %[[DAC_SPAWN_CONT:.+]], !dbg

; CHECK: [[DAC_SPAWN]]:
; CHECK-NEXT: call {{.*}}void @_Z28ggml_compute_forward_mul_matPK19ggml_compute_paramsP11ggml_tensor.outline_pfor.cond.us.ls1(
; CHECK-NEXT: reattach within %[[LOOP_DAC_SYNCREG]], label %[[DAC_SPAWN_CONT]]

; CHECK: [[DAC_SPAWN_CONT]]:
; CHECK: br label %[[LOOP_DAC_HEADER]]

; Check for a newly introduced taskframe that contains the static alloca.
; CHECK: call void @__csan_detach(
; CHECK: call void @__csan_task(
; CHECK: %[[NEW_TF:.+]] = call token @llvm.taskframe.create(), !dbg
; CHECK-NEXT: %[[TMP:.+]] = alloca [32 x float]
; CHECK: br label %[[NESTED_LOOP_HEADER:.+]], !dbg

; CHECK: [[NESTED_LOOP_HEADER]]:
; CHECK: br i1 %{{.*}}, label %[[NESTED_LOOP_EPIL:.+]], label %[[NESTED_LOOP_SPAWN:.+]], !dbg

; Check for the nested spawn
; CHECK: [[NESTED_LOOP_SPAWN]]:
; CHECK-NEXT: call void @__csan_detach(
; CHECK-NEXT: detach within %[[NESTED_SPAWN_SYNCREG]], label %[[NESTED_SPAWN:.+]], label %[[NESTED_LOOP_EPIL_CRIT_EDGE:.+]] unwind label %[[NESTED_CSI_CLEANUP:.+]], !dbg

; CHECK: [[NESTED_LOOP_EPIL]]:
; CHECK: sync within %[[NESTED_SPAWN_SYNCREG]], label %[[NESTED_LOOP_SYNC_CONT:.+]], !dbg

; CHECK: [[NESTED_LOOP_SYNC_CONT]]:
; CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[NESTED_SPAWN_SYNCREG]])
; CHECK-NEXT: to label %[[NESTED_LOOP_INC:.+]] unwind label %[[NESTED_CSI_CLEANUP_SPLIT:.+]], !dbg

; CHECK: [[NESTED_CSI_CLEANUP_SPLIT]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: br label %csi.cleanup389.ls1

; CHECK: csi.cleanup389.ls1:
; CHECK-NEXT: %[[CSI_CLEANUP_LPAD:.+]] = phi
; CHECK-NEXT: call void @__csan_task_exit(
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[NEW_TF]], { ptr, i32 } %[[CSI_CLEANUP_LPAD]])
; CHECK-NEXT: to label %{{.*}} unwind label %[[NEW_TF_UNWIND:.+]], !dbg

; CHECK: [[NESTED_LOOP_INC]]:
; CHECK: br i1 %{{.*}}, label %[[NESTED_LOOP_EXIT:.+]], label %[[NESTED_LOOP_HEADER]]

; CHECK: [[NESTED_LOOP_EXIT]]:
; CHECK-NEXT: call void @llvm.taskframe.end(token %[[NEW_TF]])
; CHECK-NEXT: call void @__csan_task_exit(
; CHECK-NEXT: call void @__csan_detach_continue(
; CHECK-NEXT: sync within %[[LOOP_DAC_SYNCREG]], label %{{.*}}

; CHECK: [[NEW_TF_UNWIND]]:
; CHECK-NEXT: %[[NEW_TF_LPAD:.+]] = landingpad { ptr, i32 }
; CHECK-NEXT: cleanup
; CHECK-NEXT: resume { ptr, i32 } %[[NEW_TF_LPAD]]

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #2

declare !dbg !550 zeroext i1 @ggml_is_contiguous(ptr noundef) local_unnamed_addr #3

declare !dbg !553 i64 @ggml_row_size(i32 noundef, i64 noundef) local_unnamed_addr #3

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #4

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #5

; Function Attrs: mustprogress willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #6

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.value(metadata, metadata, metadata) #7

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smin.i64(i64, i64) #7

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #8

declare i32 @__gcc_personality_v0(...)

; Function Attrs: nounwind memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @__csi_after_alloca(i64, ptr nocapture readnone, i64, i64) local_unnamed_addr #9

define internal void @__csi_init_callsite_to_function() {
  %1 = load i64, ptr @__csi_unit_func_base_id, align 8
  store i64 %1, ptr @__csi_func_id__Z28ggml_compute_forward_mul_matPK19ggml_compute_paramsP11ggml_tensor, align 8
  ret void
}

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_func_entry(i64, ptr nocapture readnone, ptr nocapture readnone, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_func_exit(i64, i64, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_load(i64, ptr nocapture readnone, i32, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_large_load(i64, ptr nocapture readnone, i64, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_large_store(i64, ptr nocapture readnone, i64, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_before_call(i64, i64, i8, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_after_call(i64, i64, i8, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_detach(i64, i32, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_task(i64, i64, ptr nocapture readnone, ptr nocapture readnone, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_task_exit(i64, i64, i64, i32, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_detach_continue(i64, i64, i32, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_sync(i64, i32) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @__csan_get_MAAP(ptr nocapture, i64, i8) local_unnamed_addr #9

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_set_MAAP(i8, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_before_loop(i64, i64, i64) local_unnamed_addr #10

; Function Attrs: nounwind memory(argmem: read, inaccessiblemem: readwrite)
declare void @__csan_after_loop(i64, i8, i64) local_unnamed_addr #10

; Function Attrs: nounwind willreturn
declare ptr @llvm.task.frameaddress(i32) #11

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave() #12

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare ptr @llvm.frameaddress.p0(i32 immarg) #13

define internal void @csirt.unit_ctor() {
  call void @__csanrt_unit_init(ptr nonnull @0, ptr nonnull @__csi_unit_fed_tables, ptr nonnull @__csi_unit_obj_tables, ptr nonnull @__csi_init_callsite_to_function)
  ret void
}

declare void @__csanrt_unit_init(ptr, ptr, ptr, ptr) local_unnamed_addr

attributes #0 = { mustprogress ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #4 = { mustprogress nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #6 = { mustprogress willreturn memory(argmem: readwrite) }
attributes #7 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #8 = { willreturn memory(argmem: readwrite) }
attributes #9 = { nounwind memory(argmem: readwrite, inaccessiblemem: readwrite) }
attributes #10 = { nounwind memory(argmem: read, inaccessiblemem: readwrite) }
attributes #11 = { nounwind willreturn }
attributes #12 = { nocallback nofree nosync nounwind willreturn }
attributes #13 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #14 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6}
!llvm.dbg.cu = !{!7}
!llvm.ident = !{!227}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 14, i32 2]}
!1 = !{i32 7, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 1}
!6 = !{i32 7, !"frame-pointer", i32 1}
!7 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_11, file: !8, producer: "clang version 17.0.6 (git@github.com:OpenCilk/opencilk-project.git c85f242a46d579145a8538338c78acd94c43c5f4)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !9, retainedTypes: !122, imports: !129, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk", sdk: "MacOSX.sdk")
!8 = !DIFile(filename: "/Users/neboat/Software/llama.cpp/ggml_compute_forward_mul_mat.cpp", directory: "/Users/neboat/Software/llama.cpp")
!9 = !{!10, !17, !42, !47}
!10 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "ggml_task_type", file: !11, line: 642, baseType: !12, size: 32, elements: !13, identifier: "_ZTS14ggml_task_type")
!11 = !DIFile(filename: "ggml.h", directory: "/Users/neboat/Software/llama.cpp")
!12 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!13 = !{!14, !15, !16}
!14 = !DIEnumerator(name: "GGML_TASK_INIT", value: 0, isUnsigned: true)
!15 = !DIEnumerator(name: "GGML_TASK_COMPUTE", value: 1, isUnsigned: true)
!16 = !DIEnumerator(name: "GGML_TASK_FINALIZE", value: 2, isUnsigned: true)
!17 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "ggml_type", file: !11, line: 330, baseType: !12, size: 32, elements: !18, identifier: "_ZTS9ggml_type")
!18 = !{!19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41}
!19 = !DIEnumerator(name: "GGML_TYPE_F32", value: 0, isUnsigned: true)
!20 = !DIEnumerator(name: "GGML_TYPE_F16", value: 1, isUnsigned: true)
!21 = !DIEnumerator(name: "GGML_TYPE_Q4_0", value: 2, isUnsigned: true)
!22 = !DIEnumerator(name: "GGML_TYPE_Q4_1", value: 3, isUnsigned: true)
!23 = !DIEnumerator(name: "GGML_TYPE_Q5_0", value: 6, isUnsigned: true)
!24 = !DIEnumerator(name: "GGML_TYPE_Q5_1", value: 7, isUnsigned: true)
!25 = !DIEnumerator(name: "GGML_TYPE_Q8_0", value: 8, isUnsigned: true)
!26 = !DIEnumerator(name: "GGML_TYPE_Q8_1", value: 9, isUnsigned: true)
!27 = !DIEnumerator(name: "GGML_TYPE_Q2_K", value: 10, isUnsigned: true)
!28 = !DIEnumerator(name: "GGML_TYPE_Q3_K", value: 11, isUnsigned: true)
!29 = !DIEnumerator(name: "GGML_TYPE_Q4_K", value: 12, isUnsigned: true)
!30 = !DIEnumerator(name: "GGML_TYPE_Q5_K", value: 13, isUnsigned: true)
!31 = !DIEnumerator(name: "GGML_TYPE_Q6_K", value: 14, isUnsigned: true)
!32 = !DIEnumerator(name: "GGML_TYPE_Q8_K", value: 15, isUnsigned: true)
!33 = !DIEnumerator(name: "GGML_TYPE_IQ2_XXS", value: 16, isUnsigned: true)
!34 = !DIEnumerator(name: "GGML_TYPE_IQ2_XS", value: 17, isUnsigned: true)
!35 = !DIEnumerator(name: "GGML_TYPE_IQ3_XXS", value: 18, isUnsigned: true)
!36 = !DIEnumerator(name: "GGML_TYPE_IQ1_S", value: 19, isUnsigned: true)
!37 = !DIEnumerator(name: "GGML_TYPE_IQ4_NL", value: 20, isUnsigned: true)
!38 = !DIEnumerator(name: "GGML_TYPE_I8", value: 21, isUnsigned: true)
!39 = !DIEnumerator(name: "GGML_TYPE_I16", value: 22, isUnsigned: true)
!40 = !DIEnumerator(name: "GGML_TYPE_I32", value: 23, isUnsigned: true)
!41 = !DIEnumerator(name: "GGML_TYPE_COUNT", value: 24, isUnsigned: true)
!42 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "ggml_backend_type", file: !11, line: 365, baseType: !12, size: 32, elements: !43, identifier: "_ZTS17ggml_backend_type")
!43 = !{!44, !45, !46}
!44 = !DIEnumerator(name: "GGML_BACKEND_CPU", value: 0, isUnsigned: true)
!45 = !DIEnumerator(name: "GGML_BACKEND_GPU", value: 10, isUnsigned: true)
!46 = !DIEnumerator(name: "GGML_BACKEND_GPU_SPLIT", value: 20, isUnsigned: true)
!47 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "ggml_op", file: !11, line: 395, baseType: !12, size: 32, elements: !48, identifier: "_ZTS7ggml_op")
!48 = !{!49, !50, !51, !52, !53, !54, !55, !56, !57, !58, !59, !60, !61, !62, !63, !64, !65, !66, !67, !68, !69, !70, !71, !72, !73, !74, !75, !76, !77, !78, !79, !80, !81, !82, !83, !84, !85, !86, !87, !88, !89, !90, !91, !92, !93, !94, !95, !96, !97, !98, !99, !100, !101, !102, !103, !104, !105, !106, !107, !108, !109, !110, !111, !112, !113, !114, !115, !116, !117, !118, !119, !120, !121}
!49 = !DIEnumerator(name: "GGML_OP_NONE", value: 0, isUnsigned: true)
!50 = !DIEnumerator(name: "GGML_OP_DUP", value: 1, isUnsigned: true)
!51 = !DIEnumerator(name: "GGML_OP_ADD", value: 2, isUnsigned: true)
!52 = !DIEnumerator(name: "GGML_OP_ADD1", value: 3, isUnsigned: true)
!53 = !DIEnumerator(name: "GGML_OP_ACC", value: 4, isUnsigned: true)
!54 = !DIEnumerator(name: "GGML_OP_SUB", value: 5, isUnsigned: true)
!55 = !DIEnumerator(name: "GGML_OP_MUL", value: 6, isUnsigned: true)
!56 = !DIEnumerator(name: "GGML_OP_DIV", value: 7, isUnsigned: true)
!57 = !DIEnumerator(name: "GGML_OP_SQR", value: 8, isUnsigned: true)
!58 = !DIEnumerator(name: "GGML_OP_SQRT", value: 9, isUnsigned: true)
!59 = !DIEnumerator(name: "GGML_OP_LOG", value: 10, isUnsigned: true)
!60 = !DIEnumerator(name: "GGML_OP_SUM", value: 11, isUnsigned: true)
!61 = !DIEnumerator(name: "GGML_OP_SUM_ROWS", value: 12, isUnsigned: true)
!62 = !DIEnumerator(name: "GGML_OP_MEAN", value: 13, isUnsigned: true)
!63 = !DIEnumerator(name: "GGML_OP_ARGMAX", value: 14, isUnsigned: true)
!64 = !DIEnumerator(name: "GGML_OP_REPEAT", value: 15, isUnsigned: true)
!65 = !DIEnumerator(name: "GGML_OP_REPEAT_BACK", value: 16, isUnsigned: true)
!66 = !DIEnumerator(name: "GGML_OP_CONCAT", value: 17, isUnsigned: true)
!67 = !DIEnumerator(name: "GGML_OP_SILU_BACK", value: 18, isUnsigned: true)
!68 = !DIEnumerator(name: "GGML_OP_NORM", value: 19, isUnsigned: true)
!69 = !DIEnumerator(name: "GGML_OP_RMS_NORM", value: 20, isUnsigned: true)
!70 = !DIEnumerator(name: "GGML_OP_RMS_NORM_BACK", value: 21, isUnsigned: true)
!71 = !DIEnumerator(name: "GGML_OP_GROUP_NORM", value: 22, isUnsigned: true)
!72 = !DIEnumerator(name: "GGML_OP_MUL_MAT", value: 23, isUnsigned: true)
!73 = !DIEnumerator(name: "GGML_OP_MUL_MAT_ID", value: 24, isUnsigned: true)
!74 = !DIEnumerator(name: "GGML_OP_OUT_PROD", value: 25, isUnsigned: true)
!75 = !DIEnumerator(name: "GGML_OP_SCALE", value: 26, isUnsigned: true)
!76 = !DIEnumerator(name: "GGML_OP_SET", value: 27, isUnsigned: true)
!77 = !DIEnumerator(name: "GGML_OP_CPY", value: 28, isUnsigned: true)
!78 = !DIEnumerator(name: "GGML_OP_CONT", value: 29, isUnsigned: true)
!79 = !DIEnumerator(name: "GGML_OP_RESHAPE", value: 30, isUnsigned: true)
!80 = !DIEnumerator(name: "GGML_OP_VIEW", value: 31, isUnsigned: true)
!81 = !DIEnumerator(name: "GGML_OP_PERMUTE", value: 32, isUnsigned: true)
!82 = !DIEnumerator(name: "GGML_OP_TRANSPOSE", value: 33, isUnsigned: true)
!83 = !DIEnumerator(name: "GGML_OP_GET_ROWS", value: 34, isUnsigned: true)
!84 = !DIEnumerator(name: "GGML_OP_GET_ROWS_BACK", value: 35, isUnsigned: true)
!85 = !DIEnumerator(name: "GGML_OP_DIAG", value: 36, isUnsigned: true)
!86 = !DIEnumerator(name: "GGML_OP_DIAG_MASK_INF", value: 37, isUnsigned: true)
!87 = !DIEnumerator(name: "GGML_OP_DIAG_MASK_ZERO", value: 38, isUnsigned: true)
!88 = !DIEnumerator(name: "GGML_OP_SOFT_MAX", value: 39, isUnsigned: true)
!89 = !DIEnumerator(name: "GGML_OP_SOFT_MAX_BACK", value: 40, isUnsigned: true)
!90 = !DIEnumerator(name: "GGML_OP_ROPE", value: 41, isUnsigned: true)
!91 = !DIEnumerator(name: "GGML_OP_ROPE_BACK", value: 42, isUnsigned: true)
!92 = !DIEnumerator(name: "GGML_OP_ALIBI", value: 43, isUnsigned: true)
!93 = !DIEnumerator(name: "GGML_OP_CLAMP", value: 44, isUnsigned: true)
!94 = !DIEnumerator(name: "GGML_OP_CONV_TRANSPOSE_1D", value: 45, isUnsigned: true)
!95 = !DIEnumerator(name: "GGML_OP_IM2COL", value: 46, isUnsigned: true)
!96 = !DIEnumerator(name: "GGML_OP_CONV_TRANSPOSE_2D", value: 47, isUnsigned: true)
!97 = !DIEnumerator(name: "GGML_OP_POOL_1D", value: 48, isUnsigned: true)
!98 = !DIEnumerator(name: "GGML_OP_POOL_2D", value: 49, isUnsigned: true)
!99 = !DIEnumerator(name: "GGML_OP_UPSCALE", value: 50, isUnsigned: true)
!100 = !DIEnumerator(name: "GGML_OP_PAD", value: 51, isUnsigned: true)
!101 = !DIEnumerator(name: "GGML_OP_ARGSORT", value: 52, isUnsigned: true)
!102 = !DIEnumerator(name: "GGML_OP_LEAKY_RELU", value: 53, isUnsigned: true)
!103 = !DIEnumerator(name: "GGML_OP_FLASH_ATTN", value: 54, isUnsigned: true)
!104 = !DIEnumerator(name: "GGML_OP_FLASH_FF", value: 55, isUnsigned: true)
!105 = !DIEnumerator(name: "GGML_OP_FLASH_ATTN_BACK", value: 56, isUnsigned: true)
!106 = !DIEnumerator(name: "GGML_OP_WIN_PART", value: 57, isUnsigned: true)
!107 = !DIEnumerator(name: "GGML_OP_WIN_UNPART", value: 58, isUnsigned: true)
!108 = !DIEnumerator(name: "GGML_OP_GET_REL_POS", value: 59, isUnsigned: true)
!109 = !DIEnumerator(name: "GGML_OP_ADD_REL_POS", value: 60, isUnsigned: true)
!110 = !DIEnumerator(name: "GGML_OP_UNARY", value: 61, isUnsigned: true)
!111 = !DIEnumerator(name: "GGML_OP_MAP_UNARY", value: 62, isUnsigned: true)
!112 = !DIEnumerator(name: "GGML_OP_MAP_BINARY", value: 63, isUnsigned: true)
!113 = !DIEnumerator(name: "GGML_OP_MAP_CUSTOM1_F32", value: 64, isUnsigned: true)
!114 = !DIEnumerator(name: "GGML_OP_MAP_CUSTOM2_F32", value: 65, isUnsigned: true)
!115 = !DIEnumerator(name: "GGML_OP_MAP_CUSTOM3_F32", value: 66, isUnsigned: true)
!116 = !DIEnumerator(name: "GGML_OP_MAP_CUSTOM1", value: 67, isUnsigned: true)
!117 = !DIEnumerator(name: "GGML_OP_MAP_CUSTOM2", value: 68, isUnsigned: true)
!118 = !DIEnumerator(name: "GGML_OP_MAP_CUSTOM3", value: 69, isUnsigned: true)
!119 = !DIEnumerator(name: "GGML_OP_CROSS_ENTROPY_LOSS", value: 70, isUnsigned: true)
!120 = !DIEnumerator(name: "GGML_OP_CROSS_ENTROPY_LOSS_BACK", value: 71, isUnsigned: true)
!121 = !DIEnumerator(name: "GGML_OP_COUNT", value: 72, isUnsigned: true)
!122 = !{!123, !126, !128}
!123 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !124, size: 64)
!124 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !125)
!125 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!126 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !127, size: 64)
!127 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!128 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !125, size: 64)
!129 = !{!130, !137, !141, !144, !148, !153, !157, !161, !165, !169, !173, !176, !180, !183, !185, !187, !189, !191, !193, !195, !197, !199, !201, !203, !205, !207, !209, !211, !213, !218, !221, !224}
!130 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !133, file: !136, line: 59)
!131 = !DINamespace(name: "__1", scope: !132, exportSymbols: true)
!132 = !DINamespace(name: "std", scope: null)
!133 = !DIDerivedType(tag: DW_TAG_typedef, name: "nullptr_t", file: !134, line: 50, baseType: !135)
!134 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/c++/v1/stddef.h", directory: "")
!135 = !DIBasicType(tag: DW_TAG_unspecified_type, name: "decltype(nullptr)")
!136 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/c++/v1/cstddef", directory: "")
!137 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !138, file: !136, line: 60)
!138 = !DIDerivedType(tag: DW_TAG_typedef, name: "ptrdiff_t", file: !139, line: 35, baseType: !140)
!139 = !DIFile(filename: "opencilk-project/build-17/lib/clang/17/include/stddef.h", directory: "/Users/neboat/Software")
!140 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!141 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !142, file: !136, line: 61)
!142 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !139, line: 46, baseType: !143)
!143 = !DIBasicType(name: "unsigned long", size: 64, encoding: DW_ATE_unsigned)
!144 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !145, file: !136, line: 64)
!145 = !DIDerivedType(tag: DW_TAG_typedef, name: "max_align_t", file: !146, line: 16, baseType: !147)
!146 = !DIFile(filename: "opencilk-project/build-17/lib/clang/17/include/__stddef_max_align_t.h", directory: "/Users/neboat/Software")
!147 = !DIBasicType(name: "long double", size: 64, encoding: DW_ATE_float)
!148 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !149, file: !152, line: 162)
!149 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !150, line: 30, baseType: !151)
!150 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/_types/_int8_t.h", directory: "")
!151 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!152 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/c++/v1/cstdint", directory: "")
!153 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !154, file: !152, line: 163)
!154 = !DIDerivedType(tag: DW_TAG_typedef, name: "int16_t", file: !155, line: 30, baseType: !156)
!155 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/_types/_int16_t.h", directory: "")
!156 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!157 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !158, file: !152, line: 164)
!158 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !159, line: 30, baseType: !160)
!159 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/_types/_int32_t.h", directory: "")
!160 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!161 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !162, file: !152, line: 165)
!162 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !163, line: 30, baseType: !164)
!163 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/_types/_int64_t.h", directory: "")
!164 = !DIBasicType(name: "long long", size: 64, encoding: DW_ATE_signed)
!165 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !166, file: !152, line: 167)
!166 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !167, line: 31, baseType: !168)
!167 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/_types/_uint8_t.h", directory: "")
!168 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!169 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !170, file: !152, line: 168)
!170 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !171, line: 31, baseType: !172)
!171 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/_types/_uint16_t.h", directory: "")
!172 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!173 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !174, file: !152, line: 169)
!174 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !175, line: 31, baseType: !12)
!175 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/_types/_uint32_t.h", directory: "")
!176 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !177, file: !152, line: 170)
!177 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !178, line: 31, baseType: !179)
!178 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/_types/_uint64_t.h", directory: "")
!179 = !DIBasicType(name: "unsigned long long", size: 64, encoding: DW_ATE_unsigned)
!180 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !181, file: !152, line: 172)
!181 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least8_t", file: !182, line: 29, baseType: !149)
!182 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/stdint.h", directory: "")
!183 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !184, file: !152, line: 173)
!184 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least16_t", file: !182, line: 30, baseType: !154)
!185 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !186, file: !152, line: 174)
!186 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least32_t", file: !182, line: 31, baseType: !158)
!187 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !188, file: !152, line: 175)
!188 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least64_t", file: !182, line: 32, baseType: !162)
!189 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !190, file: !152, line: 177)
!190 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least8_t", file: !182, line: 33, baseType: !166)
!191 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !192, file: !152, line: 178)
!192 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least16_t", file: !182, line: 34, baseType: !170)
!193 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !194, file: !152, line: 179)
!194 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least32_t", file: !182, line: 35, baseType: !174)
!195 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !196, file: !152, line: 180)
!196 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least64_t", file: !182, line: 36, baseType: !177)
!197 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !198, file: !152, line: 182)
!198 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast8_t", file: !182, line: 40, baseType: !149)
!199 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !200, file: !152, line: 183)
!200 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast16_t", file: !182, line: 41, baseType: !154)
!201 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !202, file: !152, line: 184)
!202 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast32_t", file: !182, line: 42, baseType: !158)
!203 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !204, file: !152, line: 185)
!204 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast64_t", file: !182, line: 43, baseType: !162)
!205 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !206, file: !152, line: 187)
!206 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast8_t", file: !182, line: 44, baseType: !166)
!207 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !208, file: !152, line: 188)
!208 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast16_t", file: !182, line: 45, baseType: !170)
!209 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !210, file: !152, line: 189)
!210 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast32_t", file: !182, line: 46, baseType: !174)
!211 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !212, file: !152, line: 190)
!212 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast64_t", file: !182, line: 47, baseType: !177)
!213 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !214, file: !152, line: 192)
!214 = !DIDerivedType(tag: DW_TAG_typedef, name: "intptr_t", file: !215, line: 32, baseType: !216)
!215 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/_types/_intptr_t.h", directory: "")
!216 = !DIDerivedType(tag: DW_TAG_typedef, name: "__darwin_intptr_t", file: !217, line: 27, baseType: !140)
!217 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/arm/_types.h", directory: "")
!218 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !219, file: !152, line: 193)
!219 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !220, line: 34, baseType: !143)
!220 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/_types/_uintptr_t.h", directory: "")
!221 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !222, file: !152, line: 195)
!222 = !DIDerivedType(tag: DW_TAG_typedef, name: "intmax_t", file: !223, line: 32, baseType: !140)
!223 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/_types/_intmax_t.h", directory: "")
!224 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !131, entity: !225, file: !152, line: 196)
!225 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintmax_t", file: !226, line: 32, baseType: !143)
!226 = !DIFile(filename: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/_types/_uintmax_t.h", directory: "")
!227 = !{!"clang version 17.0.6 (git@github.com:OpenCilk/opencilk-project.git c85f242a46d579145a8538338c78acd94c43c5f4)"}
!228 = distinct !DISubprogram(name: "ggml_compute_forward_mul_mat", linkageName: "_Z28ggml_compute_forward_mul_matPK19ggml_compute_paramsP11ggml_tensor", scope: !229, file: !229, line: 33, type: !230, scopeLine: 35, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, retainedNodes: !282)
!229 = !DIFile(filename: "ggml_compute_forward_mul_mat.cpp", directory: "/Users/neboat/Software/llama.cpp")
!230 = !DISubroutineType(types: !231)
!231 = !{null, !232, !242}
!232 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !233, size: 64)
!233 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !234)
!234 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ggml_compute_params", file: !11, line: 648, size: 256, flags: DIFlagTypePassByValue, elements: !235, identifier: "_ZTS19ggml_compute_params")
!235 = !{!236, !237, !238, !239, !240}
!236 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !234, file: !11, line: 649, baseType: !10, size: 32)
!237 = !DIDerivedType(tag: DW_TAG_member, name: "ith", scope: !234, file: !11, line: 652, baseType: !160, size: 32, offset: 32)
!238 = !DIDerivedType(tag: DW_TAG_member, name: "nth", scope: !234, file: !11, line: 652, baseType: !160, size: 32, offset: 64)
!239 = !DIDerivedType(tag: DW_TAG_member, name: "wsize", scope: !234, file: !11, line: 655, baseType: !142, size: 64, offset: 128)
!240 = !DIDerivedType(tag: DW_TAG_member, name: "wdata", scope: !234, file: !11, line: 656, baseType: !241, size: 64, offset: 192)
!241 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!242 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !243, size: 64)
!243 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ggml_tensor", file: !11, line: 532, size: 2944, flags: DIFlagTypePassByValue, elements: !244, identifier: "_ZTS11ggml_tensor")
!244 = !{!245, !246, !247, !250, !254, !256, !257, !261, !262, !263, !267, !268, !269, !270, !271, !272, !273, !277, !278}
!245 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !243, file: !11, line: 533, baseType: !17, size: 32)
!246 = !DIDerivedType(tag: DW_TAG_member, name: "backend", scope: !243, file: !11, line: 534, baseType: !42, size: 32, offset: 32)
!247 = !DIDerivedType(tag: DW_TAG_member, name: "buffer", scope: !243, file: !11, line: 536, baseType: !248, size: 64, offset: 64)
!248 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !249, size: 64)
!249 = !DICompositeType(tag: DW_TAG_structure_type, name: "ggml_backend_buffer", file: !11, line: 536, flags: DIFlagFwdDecl | DIFlagNonTrivial, identifier: "_ZTS19ggml_backend_buffer")
!250 = !DIDerivedType(tag: DW_TAG_member, name: "ne", scope: !243, file: !11, line: 538, baseType: !251, size: 256, offset: 128)
!251 = !DICompositeType(tag: DW_TAG_array_type, baseType: !162, size: 256, elements: !252)
!252 = !{!253}
!253 = !DISubrange(count: 4)
!254 = !DIDerivedType(tag: DW_TAG_member, name: "nb", scope: !243, file: !11, line: 539, baseType: !255, size: 256, offset: 384)
!255 = !DICompositeType(tag: DW_TAG_array_type, baseType: !142, size: 256, elements: !252)
!256 = !DIDerivedType(tag: DW_TAG_member, name: "op", scope: !243, file: !11, line: 545, baseType: !47, size: 32, offset: 640)
!257 = !DIDerivedType(tag: DW_TAG_member, name: "op_params", scope: !243, file: !11, line: 548, baseType: !258, size: 512, offset: 672)
!258 = !DICompositeType(tag: DW_TAG_array_type, baseType: !158, size: 512, elements: !259)
!259 = !{!260}
!260 = !DISubrange(count: 16)
!261 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !243, file: !11, line: 550, baseType: !158, size: 32, offset: 1184)
!262 = !DIDerivedType(tag: DW_TAG_member, name: "grad", scope: !243, file: !11, line: 552, baseType: !242, size: 64, offset: 1216)
!263 = !DIDerivedType(tag: DW_TAG_member, name: "src", scope: !243, file: !11, line: 553, baseType: !264, size: 640, offset: 1280)
!264 = !DICompositeType(tag: DW_TAG_array_type, baseType: !242, size: 640, elements: !265)
!265 = !{!266}
!266 = !DISubrange(count: 10)
!267 = !DIDerivedType(tag: DW_TAG_member, name: "perf_runs", scope: !243, file: !11, line: 556, baseType: !160, size: 32, offset: 1920)
!268 = !DIDerivedType(tag: DW_TAG_member, name: "perf_cycles", scope: !243, file: !11, line: 557, baseType: !162, size: 64, offset: 1984)
!269 = !DIDerivedType(tag: DW_TAG_member, name: "perf_time_us", scope: !243, file: !11, line: 558, baseType: !162, size: 64, offset: 2048)
!270 = !DIDerivedType(tag: DW_TAG_member, name: "view_src", scope: !243, file: !11, line: 560, baseType: !242, size: 64, offset: 2112)
!271 = !DIDerivedType(tag: DW_TAG_member, name: "view_offs", scope: !243, file: !11, line: 561, baseType: !142, size: 64, offset: 2176)
!272 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !243, file: !11, line: 563, baseType: !241, size: 64, offset: 2240)
!273 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !243, file: !11, line: 565, baseType: !274, size: 512, offset: 2304)
!274 = !DICompositeType(tag: DW_TAG_array_type, baseType: !125, size: 512, elements: !275)
!275 = !{!276}
!276 = !DISubrange(count: 64)
!277 = !DIDerivedType(tag: DW_TAG_member, name: "extra", scope: !243, file: !11, line: 567, baseType: !241, size: 64, offset: 2816)
!278 = !DIDerivedType(tag: DW_TAG_member, name: "padding", scope: !243, file: !11, line: 569, baseType: !279, size: 64, offset: 2880)
!279 = !DICompositeType(tag: DW_TAG_array_type, baseType: !125, size: 64, elements: !280)
!280 = !{!281}
!281 = !DISubrange(count: 8)
!282 = !{!283, !284, !285, !288, !289, !291, !292, !293, !294, !296, !297, !298, !299, !300, !301, !302, !303, !304, !305, !306, !307, !308, !309, !310, !311, !312, !313, !314, !315, !317, !318, !320, !323, !331, !332, !340, !341, !342, !343, !344, !345, !346, !347, !348, !349, !350, !351, !352, !353, !354, !355, !356, !357, !358, !359, !360, !361, !363, !364, !365, !366, !368, !371, !372, !373, !374, !376, !381, !383, !386, !387, !388, !389, !390, !391, !392, !393, !394, !395, !396, !398}
!283 = !DILocalVariable(name: "params", arg: 1, scope: !228, file: !229, line: 34, type: !232)
!284 = !DILocalVariable(name: "dst", arg: 2, scope: !228, file: !229, line: 35, type: !242)
!285 = !DILocalVariable(name: "src0", scope: !228, file: !229, line: 37, type: !286)
!286 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !287, size: 64)
!287 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !243)
!288 = !DILocalVariable(name: "src1", scope: !228, file: !229, line: 38, type: !286)
!289 = !DILocalVariable(name: "ne00", scope: !228, file: !229, line: 43, type: !290)
!290 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !162)
!291 = !DILocalVariable(name: "ne01", scope: !228, file: !229, line: 43, type: !290)
!292 = !DILocalVariable(name: "ne02", scope: !228, file: !229, line: 43, type: !290)
!293 = !DILocalVariable(name: "ne03", scope: !228, file: !229, line: 43, type: !290)
!294 = !DILocalVariable(name: "nb00", scope: !228, file: !229, line: 43, type: !295)
!295 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !142)
!296 = !DILocalVariable(name: "nb01", scope: !228, file: !229, line: 43, type: !295)
!297 = !DILocalVariable(name: "nb02", scope: !228, file: !229, line: 43, type: !295)
!298 = !DILocalVariable(name: "nb03", scope: !228, file: !229, line: 43, type: !295)
!299 = !DILocalVariable(name: "ne10", scope: !228, file: !229, line: 43, type: !290)
!300 = !DILocalVariable(name: "ne11", scope: !228, file: !229, line: 43, type: !290)
!301 = !DILocalVariable(name: "ne12", scope: !228, file: !229, line: 43, type: !290)
!302 = !DILocalVariable(name: "ne13", scope: !228, file: !229, line: 43, type: !290)
!303 = !DILocalVariable(name: "nb10", scope: !228, file: !229, line: 43, type: !295)
!304 = !DILocalVariable(name: "nb11", scope: !228, file: !229, line: 43, type: !295)
!305 = !DILocalVariable(name: "nb12", scope: !228, file: !229, line: 43, type: !295)
!306 = !DILocalVariable(name: "nb13", scope: !228, file: !229, line: 43, type: !295)
!307 = !DILocalVariable(name: "ne0", scope: !228, file: !229, line: 43, type: !290)
!308 = !DILocalVariable(name: "ne1", scope: !228, file: !229, line: 43, type: !290)
!309 = !DILocalVariable(name: "ne2", scope: !228, file: !229, line: 43, type: !290)
!310 = !DILocalVariable(name: "ne3", scope: !228, file: !229, line: 43, type: !290)
!311 = !DILocalVariable(name: "nb0", scope: !228, file: !229, line: 43, type: !295)
!312 = !DILocalVariable(name: "nb1", scope: !228, file: !229, line: 43, type: !295)
!313 = !DILocalVariable(name: "nb2", scope: !228, file: !229, line: 43, type: !295)
!314 = !DILocalVariable(name: "nb3", scope: !228, file: !229, line: 43, type: !295)
!315 = !DILocalVariable(name: "ith", scope: !228, file: !229, line: 45, type: !316)
!316 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !160)
!317 = !DILocalVariable(name: "nth", scope: !228, file: !229, line: 46, type: !316)
!318 = !DILocalVariable(name: "type", scope: !228, file: !229, line: 48, type: !319)
!319 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !17)
!320 = !DILocalVariable(name: "src1_cont", scope: !228, file: !229, line: 50, type: !321)
!321 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !322)
!322 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!323 = !DILocalVariable(name: "vec_dot", scope: !228, file: !229, line: 52, type: !324)
!324 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !325)
!325 = !DIDerivedType(tag: DW_TAG_typedef, name: "ggml_vec_dot_t", file: !11, line: 2320, baseType: !326)
!326 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !327, size: 64)
!327 = !DISubroutineType(types: !328)
!328 = !{null, !160, !126, !142, !329, !142, !329, !142, !160}
!329 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !330, size: 64)
!330 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!331 = !DILocalVariable(name: "vec_dot_type", scope: !228, file: !229, line: 53, type: !319)
!332 = !DILocalVariable(name: "from_float_to_vec_dot", scope: !228, file: !229, line: 54, type: !333)
!333 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !334)
!334 = !DIDerivedType(tag: DW_TAG_typedef, name: "ggml_from_float_t", file: !11, line: 2319, baseType: !335)
!335 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !336, size: 64)
!336 = !DISubroutineType(types: !337)
!337 = !{null, !338, !241, !160}
!338 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !339, size: 64)
!339 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !127)
!340 = !DILocalVariable(name: "vec_dot_num_rows", scope: !228, file: !229, line: 55, type: !290)
!341 = !DILocalVariable(name: "r2", scope: !228, file: !229, line: 73, type: !290)
!342 = !DILocalVariable(name: "r3", scope: !228, file: !229, line: 74, type: !290)
!343 = !DILocalVariable(name: "wdata", scope: !228, file: !229, line: 80, type: !329)
!344 = !DILocalVariable(name: "row_size", scope: !228, file: !229, line: 81, type: !295)
!345 = !DILocalVariable(name: "nr0", scope: !228, file: !229, line: 83, type: !290)
!346 = !DILocalVariable(name: "nr1", scope: !228, file: !229, line: 84, type: !290)
!347 = !DILocalVariable(name: "nth0", scope: !228, file: !229, line: 90, type: !290)
!348 = !DILocalVariable(name: "nth1", scope: !228, file: !229, line: 91, type: !290)
!349 = !DILocalVariable(name: "ith0", scope: !228, file: !229, line: 93, type: !290)
!350 = !DILocalVariable(name: "ith1", scope: !228, file: !229, line: 94, type: !290)
!351 = !DILocalVariable(name: "dr0", scope: !228, file: !229, line: 96, type: !290)
!352 = !DILocalVariable(name: "dr1", scope: !228, file: !229, line: 97, type: !290)
!353 = !DILocalVariable(name: "ir010", scope: !228, file: !229, line: 99, type: !290)
!354 = !DILocalVariable(name: "ir011", scope: !228, file: !229, line: 100, type: !290)
!355 = !DILocalVariable(name: "ir110", scope: !228, file: !229, line: 102, type: !290)
!356 = !DILocalVariable(name: "ir111", scope: !228, file: !229, line: 103, type: !290)
!357 = !DILocalVariable(name: "blck_0", scope: !228, file: !229, line: 111, type: !290)
!358 = !DILocalVariable(name: "blck_1", scope: !228, file: !229, line: 112, type: !290)
!359 = !DILocalVariable(name: "nrc", scope: !228, file: !229, line: 115, type: !162)
!360 = !DILocalVariable(name: "src1_col_stride", scope: !228, file: !229, line: 122, type: !295)
!361 = !DILocalVariable(name: "__init", scope: !362, type: !162, flags: DIFlagArtificial)
!362 = distinct !DILexicalBlock(scope: !228, file: !229, line: 124, column: 5)
!363 = !DILocalVariable(name: "__limit", scope: !362, type: !162, flags: DIFlagArtificial)
!364 = !DILocalVariable(name: "__begin", scope: !362, type: !162, flags: DIFlagArtificial)
!365 = !DILocalVariable(name: "__end", scope: !362, type: !162, flags: DIFlagArtificial)
!366 = !DILocalVariable(name: "iir0", scope: !367, file: !229, line: 124, type: !162)
!367 = distinct !DILexicalBlock(scope: !362, file: !229, line: 124, column: 5)
!368 = !DILocalVariable(name: "__init", scope: !369, type: !162, flags: DIFlagArtificial)
!369 = distinct !DILexicalBlock(scope: !370, file: !229, line: 127, column: 9)
!370 = distinct !DILexicalBlock(scope: !367, file: !229, line: 124, column: 67)
!371 = !DILocalVariable(name: "__limit", scope: !369, type: !162, flags: DIFlagArtificial)
!372 = !DILocalVariable(name: "__begin", scope: !369, type: !162, flags: DIFlagArtificial)
!373 = !DILocalVariable(name: "__end", scope: !369, type: !162, flags: DIFlagArtificial)
!374 = !DILocalVariable(name: "iir1", scope: !375, file: !229, line: 127, type: !162)
!375 = distinct !DILexicalBlock(scope: !369, file: !229, line: 127, column: 9)
!376 = !DILocalVariable(name: "tmp", scope: !377, file: !229, line: 130, type: !378)
!377 = distinct !DILexicalBlock(scope: !375, file: !229, line: 127, column: 71)
!378 = !DICompositeType(tag: DW_TAG_array_type, baseType: !127, size: 1024, elements: !379)
!379 = !{!380}
!380 = !DISubrange(count: 32)
!381 = !DILocalVariable(name: "ir1", scope: !382, file: !229, line: 131, type: !162)
!382 = distinct !DILexicalBlock(scope: !377, file: !229, line: 131, column: 13)
!383 = !DILocalVariable(name: "i13", scope: !384, file: !229, line: 132, type: !290)
!384 = distinct !DILexicalBlock(scope: !385, file: !229, line: 131, column: 86)
!385 = distinct !DILexicalBlock(scope: !382, file: !229, line: 131, column: 13)
!386 = !DILocalVariable(name: "i12", scope: !384, file: !229, line: 133, type: !290)
!387 = !DILocalVariable(name: "i11", scope: !384, file: !229, line: 134, type: !290)
!388 = !DILocalVariable(name: "i03", scope: !384, file: !229, line: 137, type: !290)
!389 = !DILocalVariable(name: "i02", scope: !384, file: !229, line: 138, type: !290)
!390 = !DILocalVariable(name: "i1", scope: !384, file: !229, line: 140, type: !290)
!391 = !DILocalVariable(name: "i2", scope: !384, file: !229, line: 141, type: !290)
!392 = !DILocalVariable(name: "i3", scope: !384, file: !229, line: 142, type: !290)
!393 = !DILocalVariable(name: "src0_row", scope: !384, file: !229, line: 144, type: !123)
!394 = !DILocalVariable(name: "src1_col", scope: !384, file: !229, line: 150, type: !123)
!395 = !DILocalVariable(name: "dst_col", scope: !384, file: !229, line: 154, type: !126)
!396 = !DILocalVariable(name: "ir0", scope: !397, file: !229, line: 160, type: !162)
!397 = distinct !DILexicalBlock(scope: !384, file: !229, line: 160, column: 17)
!398 = !DILocalVariable(name: "cn", scope: !399, file: !229, line: 164, type: !160)
!399 = distinct !DILexicalBlock(scope: !384, file: !229, line: 164, column: 17)
!400 = !DILocation(line: 0, scope: !228)
!401 = !DILocation(line: 37, column: 44, scope: !228)
!402 = !{}
!403 = !DILocation(line: 37, column: 39, scope: !228)
!404 = !{!405, !405, i64 0}
!405 = !{!"any pointer", !406, i64 0}
!406 = !{!"omnipotent char", !407, i64 0}
!407 = !{!"Simple C++ TBAA"}
!408 = !DILocation(line: 38, column: 39, scope: !228)
!409 = !DILocation(line: 43, column: 5, scope: !228)
!410 = !{!411, !411, i64 0}
!411 = !{!"long long", !406, i64 0}
!412 = !{!413, !413, i64 0}
!413 = !{!"long", !406, i64 0}
!414 = !DILocation(line: 48, column: 39, scope: !228)
!415 = !{!416, !417, i64 0}
!416 = !{!"_ZTS11ggml_tensor", !417, i64 0, !418, i64 4, !405, i64 8, !406, i64 16, !406, i64 48, !419, i64 80, !406, i64 84, !420, i64 148, !405, i64 152, !406, i64 160, !420, i64 240, !411, i64 248, !411, i64 256, !405, i64 264, !413, i64 272, !405, i64 280, !406, i64 288, !405, i64 352, !406, i64 360}
!417 = !{!"_ZTS9ggml_type", !406, i64 0}
!418 = !{!"_ZTS17ggml_backend_type", !406, i64 0}
!419 = !{!"_ZTS7ggml_op", !406, i64 0}
!420 = !{!"int", !406, i64 0}
!421 = !DILocation(line: 50, column: 28, scope: !228)
!422 = !DILocation(line: 52, column: 53, scope: !228)
!423 = !DILocation(line: 52, column: 71, scope: !228)
!424 = !{!425, !405, i64 56}
!425 = !{!"_ZTS18ggml_type_traits_t", !405, i64 0, !420, i64 8, !413, i64 16, !426, i64 24, !405, i64 32, !405, i64 40, !405, i64 48, !405, i64 56, !417, i64 64, !411, i64 72}
!426 = !{!"bool", !406, i64 0}
!427 = !DILocation(line: 53, column: 71, scope: !228)
!428 = !{!425, !417, i64 64}
!429 = !DILocation(line: 55, column: 71, scope: !228)
!430 = !{!425, !411, i64 72}
!431 = !DILocation(line: 73, column: 28, scope: !228)
!432 = !DILocation(line: 74, column: 28, scope: !228)
!433 = !DILocation(line: 80, column: 36, scope: !228)
!434 = !DILocation(line: 80, column: 41, scope: !228)
!435 = !DILocation(line: 80, column: 29, scope: !228)
!436 = !DILocation(line: 81, column: 29, scope: !228)
!437 = !DILocation(line: 84, column: 28, scope: !228)
!438 = !DILocation(line: 84, column: 33, scope: !228)
!439 = !DILocation(line: 118, column: 18, scope: !440)
!440 = distinct !DILexicalBlock(scope: !228, file: !229, line: 118, column: 9)
!441 = !DILocation(line: 118, column: 24, scope: !440)
!442 = !DILocation(line: 122, column: 46, scope: !228)
!443 = !DILocation(line: 122, column: 55, scope: !228)
!444 = !DILocation(line: 122, column: 60, scope: !228)
!445 = !DILocation(line: 122, column: 36, scope: !228)
!446 = !DILocation(line: 0, scope: !362)
!447 = !DILocation(line: 124, column: 42, scope: !362)
!448 = !DILocation(line: 124, column: 44, scope: !362)
!449 = !DILocation(line: 127, column: 48, scope: !369)
!450 = !DILocation(line: 127, column: 34, scope: !375)
!451 = !DILocation(line: 124, column: 5, scope: !362)
!452 = !DILocation(line: 124, scope: !362)
!453 = !DILocation(line: 124, column: 30, scope: !367)
!454 = !DILocation(line: 0, scope: !370)
!455 = !DILocation(line: 0, scope: !367)
!456 = !DILocation(line: 0, scope: !369)
!457 = !DILocation(line: 127, column: 46, scope: !369)
!458 = !DILocation(line: 127, column: 9, scope: !369)
!459 = !DILocation(line: 127, scope: !369)
!460 = !DILocation(line: 0, scope: !375)
!461 = !DILocation(line: 130, column: 13, scope: !377)
!462 = !DILocation(line: 130, column: 19, scope: !377)
!463 = !DILocation(line: 0, scope: !382)
!464 = !DILocation(line: 131, column: 18, scope: !382)
!465 = !DILocation(line: 131, column: 58, scope: !385)
!466 = !DILocation(line: 131, column: 13, scope: !382)
!467 = !DILocation(line: 167, column: 13, scope: !382)
!468 = !DILocation(line: 127, column: 60, scope: !375)
!469 = !DILocation(line: 127, column: 9, scope: !375)
!470 = distinct !{!470, !458, !471, !472, !473, !474}
!471 = !DILocation(line: 168, column: 9, scope: !369)
!472 = !{!"llvm.loop.mustprogress"}
!473 = !{!"llvm.loop.unroll.disable"}
!474 = !{!"llvm.loop.fromtapirloop"}
!475 = distinct !{!475, !458, !471, !472, !476, !473, !477}
!476 = !{!"tapir.loop.spawn.strategy", i32 1}
!477 = !{!"tapir.loop.grainsize", i32 1}
!478 = !DILocation(line: 132, column: 41, scope: !384)
!479 = !DILocation(line: 0, scope: !384)
!480 = !DILocation(line: 133, column: 47, scope: !384)
!481 = !DILocation(line: 133, column: 52, scope: !384)
!482 = !DILocation(line: 133, column: 42, scope: !384)
!483 = !DILocation(line: 133, column: 57, scope: !384)
!484 = !DILocation(line: 134, column: 62, scope: !384)
!485 = !DILocation(line: 134, column: 57, scope: !384)
!486 = !DILocation(line: 137, column: 40, scope: !384)
!487 = !DILocation(line: 138, column: 40, scope: !384)
!488 = !DILocation(line: 144, column: 62, scope: !384)
!489 = !{!416, !405, i64 280}
!490 = !DILocation(line: 144, column: 77, scope: !384)
!491 = !DILocation(line: 144, column: 88, scope: !384)
!492 = !DILocation(line: 144, column: 83, scope: !384)
!493 = !DILocation(line: 144, column: 67, scope: !384)
!494 = !DILocation(line: 151, column: 32, scope: !384)
!495 = !DILocation(line: 151, column: 41, scope: !384)
!496 = !DILocation(line: 151, column: 46, scope: !384)
!497 = !DILocation(line: 151, column: 22, scope: !384)
!498 = !DILocation(line: 153, column: 28, scope: !384)
!499 = !DILocation(line: 153, column: 39, scope: !384)
!500 = !DILocation(line: 153, column: 50, scope: !384)
!501 = !DILocation(line: 153, column: 34, scope: !384)
!502 = !DILocation(line: 153, column: 45, scope: !384)
!503 = !DILocation(line: 152, column: 45, scope: !384)
!504 = !DILocation(line: 152, column: 61, scope: !384)
!505 = !DILocation(line: 150, column: 62, scope: !384)
!506 = !DILocation(line: 154, column: 60, scope: !384)
!507 = !DILocation(line: 154, column: 70, scope: !384)
!508 = !DILocation(line: 154, column: 79, scope: !384)
!509 = !DILocation(line: 154, column: 88, scope: !384)
!510 = !DILocation(line: 154, column: 75, scope: !384)
!511 = !DILocation(line: 154, column: 84, scope: !384)
!512 = !DILocation(line: 154, column: 65, scope: !384)
!513 = !DILocation(line: 0, scope: !397)
!514 = !DILocation(line: 160, column: 17, scope: !397)
!515 = !DILocation(line: 161, column: 44, scope: !516)
!516 = distinct !DILexicalBlock(scope: !517, file: !229, line: 160, column: 90)
!517 = distinct !DILexicalBlock(scope: !397, file: !229, line: 160, column: 17)
!518 = !DILocation(line: 161, column: 36, scope: !516)
!519 = !DILocation(line: 161, column: 85, scope: !516)
!520 = !DILocation(line: 161, column: 80, scope: !516)
!521 = !DILocation(line: 161, column: 21, scope: !516)
!522 = !DILocation(line: 160, column: 82, scope: !517)
!523 = !DILocation(line: 160, column: 62, scope: !517)
!524 = distinct !{!524, !514, !525, !472}
!525 = !DILocation(line: 162, column: 17, scope: !397)
!526 = !DILocation(line: 0, scope: !399)
!527 = !DILocation(line: 164, column: 17, scope: !399)
!528 = !DILocation(line: 165, column: 46, scope: !529)
!529 = distinct !DILexicalBlock(scope: !530, file: !229, line: 164, column: 50)
!530 = distinct !DILexicalBlock(scope: !399, file: !229, line: 164, column: 17)
!531 = !DILocation(line: 165, column: 50, scope: !529)
!532 = !DILocation(line: 165, column: 42, scope: !529)
!533 = !DILocation(line: 165, column: 29, scope: !529)
!534 = !DILocation(line: 165, column: 66, scope: !529)
!535 = !DILocation(line: 165, column: 61, scope: !529)
!536 = !DILocation(line: 165, column: 21, scope: !529)
!537 = !DILocation(line: 164, column: 44, scope: !530)
!538 = !DILocation(line: 164, column: 37, scope: !530)
!539 = distinct !{!539, !527, !540, !472}
!540 = !DILocation(line: 166, column: 17, scope: !399)
!541 = !DILocation(line: 131, column: 78, scope: !385)
!542 = distinct !{!542, !466, !467, !472}
!543 = !DILocation(line: 169, column: 5, scope: !370)
!544 = !DILocation(line: 124, column: 56, scope: !367)
!545 = !DILocation(line: 124, column: 42, scope: !367)
!546 = !DILocation(line: 124, column: 5, scope: !367)
!547 = distinct !{!547, !451, !548, !472, !476, !477}
!548 = !DILocation(line: 169, column: 5, scope: !362)
!549 = !DILocation(line: 170, column: 1, scope: !228)
!550 = !DISubprogram(name: "ggml_is_contiguous", scope: !11, file: !11, line: 713, type: !551, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!551 = !DISubroutineType(types: !552)
!552 = !{!322, !286}
!553 = !DISubprogram(name: "ggml_row_size", scope: !11, file: !11, line: 692, type: !554, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!554 = !DISubroutineType(types: !555)
!555 = !{!142, !17, !162}
