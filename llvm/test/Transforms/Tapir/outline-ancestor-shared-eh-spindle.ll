; Check that tapir2target handles shared-eh spindles tracked in an
; ancestor task other than the parent.
;
; RUN: opt < %s -passes="tapir2target" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@height = internal global i32 0, align 4
@width = internal global i32 0, align 4
@img = internal global float* null, align 8
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
@__csi_unit_filename_crash.i = private unnamed_addr constant [8 x i8] c"crash.i\00"
@__csi_unit_function_name_render = private unnamed_addr constant [7 x i8] c"render\00"
@__csi_unit_fed_table__csi_unit_func_base_id = internal global [1 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_func_exit_base_id = internal global [1 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_loop_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_fed_table__csi_unit_loop_exit_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_fed_table__csi_unit_bb_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_fed_table__csi_unit_callsite_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_fed_table__csi_unit_load_base_id = internal global [16 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_store_base_id = internal global [3 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_detach_base_id = internal global [4 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_task_base_id = internal global [4 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }]
@__csi_unit_fed_table__csi_unit_task_exit_base_id = internal global [4 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_detach_continue_base_id = internal global [4 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }]
@__csi_unit_fed_table__csi_unit_sync_base_id = internal global [4 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_function_name_render, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_filename_crash.i, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_alloca_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_fed_table__csi_unit_allocfn_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_fed_table__csi_unit_free_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_object_name_height = private unnamed_addr constant [7 x i8] c"height\00"
@__csi_unit_object_name_width = private unnamed_addr constant [6 x i8] c"width\00"
@__csi_unit_object_name_img = private unnamed_addr constant [4 x i8] c"img\00"
@__csi_unit_obj_table = internal global [16 x { i8*, i32, i8* }] [{ i8*, i32, i8* } { i8* null, i32 -1, i8* null }, { i8*, i32, i8* } { i8* null, i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_object_name_height, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_width, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_img, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_width, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_object_name_height, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_width, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_img, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_width, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_img, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_width, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_img, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_width, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_img, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_width, i32 0, i32 0), i32 -1, i8* null }]
@__csi_unit_obj_table.1 = internal global [3 x { i8*, i32, i8* }] [{ i8*, i32, i8* } { i8* null, i32 -1, i8* null }, { i8*, i32, i8* } { i8* null, i32 -1, i8* null }, { i8*, i32, i8* } { i8* null, i32 -1, i8* null }]
@__csi_unit_obj_table.2 = internal global [0 x { i8*, i32, i8* }] zeroinitializer
@__csi_unit_obj_table.3 = internal global [0 x { i8*, i32, i8* }] zeroinitializer
@__csi_func_id_render = weak global i64 -1
@__csi_unit_fed_tables = internal global [16 x { i64, i8*, { i8*, i32, i32, i8* }* }] [{ i64, i8*, { i8*, i32, i32, i8* }* } { i64 1, i8* bitcast (i64* @__csi_unit_func_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([1 x { i8*, i32, i32, i8* }], [1 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_func_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 1, i8* bitcast (i64* @__csi_unit_func_exit_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([1 x { i8*, i32, i32, i8* }], [1 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_func_exit_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_loop_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_loop_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_loop_exit_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_loop_exit_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_bb_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_bb_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_callsite_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_callsite_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 16, i8* bitcast (i64* @__csi_unit_load_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([16 x { i8*, i32, i32, i8* }], [16 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_load_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 3, i8* bitcast (i64* @__csi_unit_store_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([3 x { i8*, i32, i32, i8* }], [3 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_store_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 4, i8* bitcast (i64* @__csi_unit_detach_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([4 x { i8*, i32, i32, i8* }], [4 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_detach_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 4, i8* bitcast (i64* @__csi_unit_task_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([4 x { i8*, i32, i32, i8* }], [4 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_task_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 4, i8* bitcast (i64* @__csi_unit_task_exit_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([4 x { i8*, i32, i32, i8* }], [4 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_task_exit_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 4, i8* bitcast (i64* @__csi_unit_detach_continue_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([4 x { i8*, i32, i32, i8* }], [4 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_detach_continue_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 4, i8* bitcast (i64* @__csi_unit_sync_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([4 x { i8*, i32, i32, i8* }], [4 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_sync_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_alloca_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_alloca_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_allocfn_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_allocfn_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_free_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_free_base_id, i32 0, i32 0) }]
@__csi_unit_obj_tables = internal global [4 x { i64, { i8*, i32, i8* }* }] [{ i64, { i8*, i32, i8* }* } { i64 16, { i8*, i32, i8* }* getelementptr inbounds ([16 x { i8*, i32, i8* }], [16 x { i8*, i32, i8* }]* @__csi_unit_obj_table, i32 0, i32 0) }, { i64, { i8*, i32, i8* }* } { i64 3, { i8*, i32, i8* }* getelementptr inbounds ([3 x { i8*, i32, i8* }], [3 x { i8*, i32, i8* }]* @__csi_unit_obj_table.1, i32 0, i32 0) }, { i64, { i8*, i32, i8* }* } { i64 0, { i8*, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i8* }], [0 x { i8*, i32, i8* }]* @__csi_unit_obj_table.2, i32 0, i32 0) }, { i64, { i8*, i32, i8* }* } { i64 0, { i8*, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i8* }], [0 x { i8*, i32, i8* }]* @__csi_unit_obj_table.3, i32 0, i32 0) }]
@0 = private unnamed_addr constant [8 x i8] c"crash.i\00", align 1
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 0, void ()* @csirt.unit_ctor, i8* null }]

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @render() #0 {
entry:
  %0 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !4
  %1 = add i64 %0, 2
  %2 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !4
  %3 = add i64 %2, 2
  %4 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !4
  %5 = add i64 %4, 2
  %6 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !4
  %7 = add i64 %6, 2
  %8 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !4
  %9 = add i64 %8, 0
  %10 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !4
  %11 = add i64 %10, 0
  %12 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !4
  %13 = add i64 %12, 0
  %14 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !4
  %15 = add i64 %14, 0
  %16 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !4
  %17 = add i64 %16, 0
  %18 = call i8* @llvm.frameaddress.p0i8(i32 0)
  %19 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %17, i8* %18, i8* %19, i64 258)
  %syncreg = call token @llvm.syncregion.start()
  %__init = alloca i32, align 4
  %__limit = alloca i32, align 4
  %__begin = alloca i32, align 4
  %__end = alloca i32, align 4
  %syncreg35 = call token @llvm.syncregion.start()
  %__init36 = alloca i32, align 4
  %__limit37 = alloca i32, align 4
  %__begin41 = alloca i32, align 4
  %__end42 = alloca i32, align 4
  store i32 0, i32* %__init, align 4
  %20 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %21 = add i64 %20, 2
  call void @__csan_load(i64 %21, i8* bitcast (i32* @height to i8*), i32 4, i64 4)
  %22 = load i32, i32* @height, align 4
  store i32 %22, i32* %__limit, align 4
  %23 = load i32, i32* %__init, align 4
  %24 = load i32, i32* %__limit, align 4
  %cmp = icmp sle i32 %23, %24
  br i1 %cmp, label %pfor.ph, label %pfor.end34

pfor.ph:                                          ; preds = %entry
  store i32 0, i32* %__begin, align 4
  %25 = load i32, i32* %__limit, align 4
  %26 = load i32, i32* %__init, align 4
  %sub = sub nsw i32 %25, %26
  %div = sdiv i32 %sub, 1
  store i32 %div, i32* %__end, align 4
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc26, %pfor.ph
  br label %pfor.detach

pfor.detach:                                      ; preds = %pfor.cond
  %27 = load i32, i32* %__init, align 4
  %28 = load i32, i32* %__begin, align 4
  %mul = mul nsw i32 %28, 1
  %add = add nsw i32 %27, %mul
  call void @__csan_detach(i64 %9, i32 0)
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc26

pfor.body.entry:                                  ; preds = %pfor.detach
  %29 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !4
  %30 = add i64 %29, 1
  %31 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !4
  %32 = add i64 %31, 1
  %33 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !4
  %34 = add i64 %33, 1
  %35 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !4
  %36 = add i64 %35, 1
  %37 = call i8* @llvm.task.frameaddress(i32 0)
  %38 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %11, i64 %9, i8* %37, i8* %38, i64 2)
  %y = alloca i32, align 4
  %syncreg1 = call token @llvm.syncregion.start()
  %__init2 = alloca i32, align 4
  %__limit3 = alloca i32, align 4
  %__begin6 = alloca i32, align 4
  %__end7 = alloca i32, align 4
  store i32 %add, i32* %y, align 4
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  store i32 0, i32* %__init2, align 4
  %39 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %40 = add i64 %39, 3
  call void @__csan_load(i64 %40, i8* bitcast (i32* @width to i8*), i32 4, i64 4)
  %41 = load i32, i32* @width, align 4
  store i32 %41, i32* %__limit3, align 4
  %42 = load i32, i32* %__init2, align 4
  %43 = load i32, i32* %__limit3, align 4
  %cmp4 = icmp sle i32 %42, %43
  br i1 %cmp4, label %pfor.ph5, label %pfor.end

pfor.ph5:                                         ; preds = %pfor.body
  store i32 0, i32* %__begin6, align 4
  %44 = load i32, i32* %__limit3, align 4
  %45 = load i32, i32* %__init2, align 4
  %sub8 = sub nsw i32 %44, %45
  %div9 = sdiv i32 %sub8, 1
  store i32 %div9, i32* %__end7, align 4
  br label %pfor.cond10

pfor.cond10:                                      ; preds = %pfor.inc, %pfor.ph5
  br label %pfor.detach11

pfor.detach11:                                    ; preds = %pfor.cond10
  %46 = load i32, i32* %__init2, align 4
  %47 = load i32, i32* %__begin6, align 4
  %mul12 = mul nsw i32 %47, 1
  %add13 = add nsw i32 %46, %mul12
  call void @__csan_detach(i64 %30, i32 0)
  detach within %syncreg1, label %pfor.body.entry14, label %pfor.inc

pfor.body.entry14:                                ; preds = %pfor.detach11
  %48 = call i8* @llvm.task.frameaddress(i32 0)
  %49 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %32, i64 %30, i8* %48, i8* %49, i64 0)
  %x = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  store i32 %add13, i32* %x, align 4
  br label %pfor.body15

pfor.body15:                                      ; preds = %pfor.body.entry14
  %50 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %51 = add i64 %50, 4
  call void @__csan_load(i64 %51, i8* bitcast (float** @img to i8*), i32 8, i64 8)
  %52 = load float*, float** @img, align 8
  %53 = load i32, i32* %x, align 4
  %54 = load i32, i32* %y, align 4
  %55 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %56 = add i64 %55, 5
  call void @__csan_load(i64 %56, i8* bitcast (i32* @width to i8*), i32 4, i64 4)
  %57 = load i32, i32* @width, align 4
  %mul16 = mul nsw i32 %54, %57
  %add17 = add nsw i32 %53, %mul16
  %mul18 = mul nsw i32 %add17, 3
  %idxprom = sext i32 %mul18 to i64
  %arrayidx = getelementptr inbounds float, float* %52, i64 %idxprom
  %58 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %59 = add i64 %58, 0
  %60 = bitcast float* %arrayidx to i8*
  call void @__csan_load(i64 %59, i8* %60, i32 4, i64 4)
  %61 = load float, float* %arrayidx, align 4
  %conv = fpext float %61 to double
  %cmp19 = fcmp oge double %conv, 0.000000e+00
  br i1 %cmp19, label %if.then, label %if.end

if.then:                                          ; preds = %pfor.body15
  store i32 9, i32* %cleanup.dest.slot, align 4
  br label %cleanup

if.end:                                           ; preds = %pfor.body15
  store i32 0, i32* %cleanup.dest.slot, align 4
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %unreachable.loopexit124 [
    i32 0, label %cleanup.cont
    i32 9, label %pfor.preattach
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %cleanup.cont, %cleanup
  call void @__csan_task_exit(i64 %34, i64 %32, i64 %30, i32 0, i64 0)
  reattach within %syncreg1, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.detach11
  call void @__csan_detach_continue(i64 %36, i64 %30, i32 0, i64 0)
  %62 = load i32, i32* %__begin6, align 4
  %inc = add nsw i32 %62, 1
  store i32 %inc, i32* %__begin6, align 4
  %63 = load i32, i32* %__begin6, align 4
  %64 = load i32, i32* %__end7, align 4
  %cmp21 = icmp sle i32 %63, %64
  br i1 %cmp21, label %pfor.cond10, label %pfor.cond.cleanup, !llvm.loop !5

pfor.cond.cleanup:                                ; preds = %pfor.inc
  %65 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !4
  %66 = add i64 %65, 0
  call void @__csan_sync(i64 %66, i32 0)
  sync within %syncreg1, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  br label %pfor.end

pfor.end:                                         ; preds = %sync.continue, %pfor.body
  br label %pfor.preattach25

pfor.preattach25:                                 ; preds = %pfor.end
  call void @__csan_task_exit(i64 %13, i64 %11, i64 %9, i32 0, i64 0)
  reattach within %syncreg, label %pfor.inc26

pfor.inc26:                                       ; preds = %pfor.preattach25, %pfor.detach
  call void @__csan_detach_continue(i64 %15, i64 %9, i32 0, i64 0)
  %67 = load i32, i32* %__begin, align 4
  %inc27 = add nsw i32 %67, 1
  store i32 %inc27, i32* %__begin, align 4
  %68 = load i32, i32* %__begin, align 4
  %69 = load i32, i32* %__end, align 4
  %cmp28 = icmp sle i32 %68, %69
  br i1 %cmp28, label %pfor.cond, label %pfor.cond.cleanup30, !llvm.loop !7

pfor.cond.cleanup30:                              ; preds = %pfor.inc26
  %70 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !4
  %71 = add i64 %70, 1
  call void @__csan_sync(i64 %71, i32 0)
  sync within %syncreg, label %sync.continue33

sync.continue33:                                  ; preds = %pfor.cond.cleanup30
  br label %pfor.end34

pfor.end34:                                       ; preds = %sync.continue33, %entry
  store i32 0, i32* %__init36, align 4
  %72 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %73 = add i64 %72, 6
  call void @__csan_load(i64 %73, i8* bitcast (i32* @height to i8*), i32 4, i64 4)
  %74 = load i32, i32* @height, align 4
  store i32 %74, i32* %__limit37, align 4
  %75 = load i32, i32* %__init36, align 4
  %76 = load i32, i32* %__limit37, align 4
  %cmp38 = icmp slt i32 %75, %76
  br i1 %cmp38, label %pfor.ph40, label %pfor.end123

pfor.ph40:                                        ; preds = %pfor.end34
  store i32 0, i32* %__begin41, align 4
  %77 = load i32, i32* %__limit37, align 4
  %78 = load i32, i32* %__init36, align 4
  %sub43 = sub nsw i32 %77, %78
  %sub44 = sub nsw i32 %sub43, 1
  %div45 = sdiv i32 %sub44, 1
  %add46 = add nsw i32 %div45, 1
  store i32 %add46, i32* %__end42, align 4
  br label %pfor.cond47

pfor.cond47:                                      ; preds = %pfor.inc115, %pfor.ph40
  br label %pfor.detach48

pfor.detach48:                                    ; preds = %pfor.cond47
  %79 = load i32, i32* %__init36, align 4
  %80 = load i32, i32* %__begin41, align 4
  %mul49 = mul nsw i32 %80, 1
  %add50 = add nsw i32 %79, %mul49
  call void @__csan_detach(i64 %1, i32 1)
  detach within %syncreg35, label %pfor.body.entry51, label %pfor.inc115

pfor.body.entry51:                                ; preds = %pfor.detach48
  %81 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !4
  %82 = add i64 %81, 3
  %83 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !4
  %84 = add i64 %83, 3
  %85 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !4
  %86 = add i64 %85, 3
  %87 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !4
  %88 = add i64 %87, 3
  %89 = call i8* @llvm.task.frameaddress(i32 0)
  %90 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %3, i64 %1, i8* %89, i8* %90, i64 2)
  %y52 = alloca i32, align 4
  %syncreg54 = call token @llvm.syncregion.start()
  %__init55 = alloca i32, align 4
  %__limit56 = alloca i32, align 4
  %__begin60 = alloca i32, align 4
  %__end61 = alloca i32, align 4
  store i32 %add50, i32* %y52, align 4
  br label %pfor.body53

pfor.body53:                                      ; preds = %pfor.body.entry51
  store i32 0, i32* %__init55, align 4
  %91 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %92 = add i64 %91, 7
  call void @__csan_load(i64 %92, i8* bitcast (i32* @width to i8*), i32 4, i64 4)
  %93 = load i32, i32* @width, align 4
  store i32 %93, i32* %__limit56, align 4
  %94 = load i32, i32* %__init55, align 4
  %95 = load i32, i32* %__limit56, align 4
  %cmp57 = icmp slt i32 %94, %95
  br i1 %cmp57, label %pfor.ph59, label %pfor.end113

pfor.ph59:                                        ; preds = %pfor.body53
  store i32 0, i32* %__begin60, align 4
  %96 = load i32, i32* %__limit56, align 4
  %97 = load i32, i32* %__init55, align 4
  %sub62 = sub nsw i32 %96, %97
  %sub63 = sub nsw i32 %sub62, 1
  %div64 = sdiv i32 %sub63, 1
  %add65 = add nsw i32 %div64, 1
  store i32 %add65, i32* %__end61, align 4
  br label %pfor.cond66

pfor.cond66:                                      ; preds = %pfor.inc105, %pfor.ph59
  br label %pfor.detach67

pfor.detach67:                                    ; preds = %pfor.cond66
  %98 = load i32, i32* %__init55, align 4
  %99 = load i32, i32* %__begin60, align 4
  %mul68 = mul nsw i32 %99, 1
  %add69 = add nsw i32 %98, %mul68
  call void @__csan_detach(i64 %82, i32 0)
  detach within %syncreg54, label %pfor.body.entry70, label %pfor.inc105

pfor.body.entry70:                                ; preds = %pfor.detach67
  %100 = call i8* @llvm.task.frameaddress(i32 0)
  %101 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %84, i64 %82, i8* %100, i8* %101, i64 0)
  %z = alloca i32, align 4
  %cleanup.dest.slot81 = alloca i32, align 4
  store i32 %add69, i32* %z, align 4
  br label %pfor.body71

pfor.body71:                                      ; preds = %pfor.body.entry70
  %102 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %103 = add i64 %102, 8
  call void @__csan_load(i64 %103, i8* bitcast (float** @img to i8*), i32 8, i64 8)
  %104 = load float*, float** @img, align 8
  %105 = load i32, i32* %z, align 4
  %106 = load i32, i32* %y52, align 4
  %107 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %108 = add i64 %107, 9
  call void @__csan_load(i64 %108, i8* bitcast (i32* @width to i8*), i32 4, i64 4)
  %109 = load i32, i32* @width, align 4
  %mul72 = mul nsw i32 %106, %109
  %add73 = add nsw i32 %105, %mul72
  %mul74 = mul nsw i32 %add73, 3
  %add75 = add nsw i32 %mul74, 0
  %idxprom76 = sext i32 %add75 to i64
  %arrayidx77 = getelementptr inbounds float, float* %104, i64 %idxprom76
  %110 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %111 = add i64 %110, 1
  %112 = bitcast float* %arrayidx77 to i8*
  call void @__csan_load(i64 %111, i8* %112, i32 4, i64 4)
  %113 = load float, float* %arrayidx77, align 4
  %cmp78 = fcmp oge float %113, 0.000000e+00
  br i1 %cmp78, label %if.then80, label %if.end82

if.then80:                                        ; preds = %pfor.body71
  store i32 17, i32* %cleanup.dest.slot81, align 4
  br label %cleanup101

if.end82:                                         ; preds = %pfor.body71
  %114 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %115 = add i64 %114, 10
  call void @__csan_load(i64 %115, i8* bitcast (float** @img to i8*), i32 8, i64 8)
  %116 = load float*, float** @img, align 8
  %117 = load i32, i32* %z, align 4
  %118 = load i32, i32* %y52, align 4
  %119 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %120 = add i64 %119, 11
  call void @__csan_load(i64 %120, i8* bitcast (i32* @width to i8*), i32 4, i64 4)
  %121 = load i32, i32* @width, align 4
  %mul83 = mul nsw i32 %118, %121
  %add84 = add nsw i32 %117, %mul83
  %mul85 = mul nsw i32 %add84, 3
  %add86 = add nsw i32 %mul85, 0
  %idxprom87 = sext i32 %add86 to i64
  %arrayidx88 = getelementptr inbounds float, float* %116, i64 %idxprom87
  %122 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !4
  %123 = add i64 %122, 0
  %124 = bitcast float* %arrayidx88 to i8*
  call void @__csan_store(i64 %123, i8* %124, i32 4, i64 4)
  store float 0.000000e+00, float* %arrayidx88, align 4
  %125 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %126 = add i64 %125, 12
  call void @__csan_load(i64 %126, i8* bitcast (float** @img to i8*), i32 8, i64 8)
  %127 = load float*, float** @img, align 8
  %128 = load i32, i32* %z, align 4
  %129 = load i32, i32* %y52, align 4
  %130 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %131 = add i64 %130, 13
  call void @__csan_load(i64 %131, i8* bitcast (i32* @width to i8*), i32 4, i64 4)
  %132 = load i32, i32* @width, align 4
  %mul89 = mul nsw i32 %129, %132
  %add90 = add nsw i32 %128, %mul89
  %mul91 = mul nsw i32 %add90, 3
  %add92 = add nsw i32 %mul91, 1
  %idxprom93 = sext i32 %add92 to i64
  %arrayidx94 = getelementptr inbounds float, float* %127, i64 %idxprom93
  %133 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !4
  %134 = add i64 %133, 1
  %135 = bitcast float* %arrayidx94 to i8*
  call void @__csan_store(i64 %134, i8* %135, i32 4, i64 4)
  store float 0.000000e+00, float* %arrayidx94, align 4
  %136 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %137 = add i64 %136, 14
  call void @__csan_load(i64 %137, i8* bitcast (float** @img to i8*), i32 8, i64 8)
  %138 = load float*, float** @img, align 8
  %139 = load i32, i32* %z, align 4
  %140 = load i32, i32* %y52, align 4
  %141 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !4
  %142 = add i64 %141, 15
  call void @__csan_load(i64 %142, i8* bitcast (i32* @width to i8*), i32 4, i64 4)
  %143 = load i32, i32* @width, align 4
  %mul95 = mul nsw i32 %140, %143
  %add96 = add nsw i32 %139, %mul95
  %mul97 = mul nsw i32 %add96, 3
  %add98 = add nsw i32 %mul97, 2
  %idxprom99 = sext i32 %add98 to i64
  %arrayidx100 = getelementptr inbounds float, float* %138, i64 %idxprom99
  %144 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !4
  %145 = add i64 %144, 2
  %146 = bitcast float* %arrayidx100 to i8*
  call void @__csan_store(i64 %145, i8* %146, i32 4, i64 4)
  store float 0.000000e+00, float* %arrayidx100, align 4
  store i32 0, i32* %cleanup.dest.slot81, align 4
  br label %cleanup101

cleanup101:                                       ; preds = %if.end82, %if.then80
  %cleanup.dest102 = load i32, i32* %cleanup.dest.slot81, align 4
  switch i32 %cleanup.dest102, label %unreachable.loopexit [
    i32 0, label %cleanup.cont103
    i32 17, label %pfor.preattach104
  ]

cleanup.cont103:                                  ; preds = %cleanup101
  br label %pfor.preattach104

pfor.preattach104:                                ; preds = %cleanup.cont103, %cleanup101
  call void @__csan_task_exit(i64 %86, i64 %84, i64 %82, i32 0, i64 0)
  reattach within %syncreg54, label %pfor.inc105

pfor.inc105:                                      ; preds = %pfor.preattach104, %pfor.detach67
  call void @__csan_detach_continue(i64 %88, i64 %82, i32 0, i64 0)
  %147 = load i32, i32* %__begin60, align 4
  %inc106 = add nsw i32 %147, 1
  store i32 %inc106, i32* %__begin60, align 4
  %148 = load i32, i32* %__begin60, align 4
  %149 = load i32, i32* %__end61, align 4
  %cmp107 = icmp slt i32 %148, %149
  br i1 %cmp107, label %pfor.cond66, label %pfor.cond.cleanup109, !llvm.loop !8

pfor.cond.cleanup109:                             ; preds = %pfor.inc105
  %150 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !4
  %151 = add i64 %150, 2
  call void @__csan_sync(i64 %151, i32 0)
  sync within %syncreg54, label %sync.continue112

sync.continue112:                                 ; preds = %pfor.cond.cleanup109
  br label %pfor.end113

pfor.end113:                                      ; preds = %sync.continue112, %pfor.body53
  br label %pfor.preattach114

pfor.preattach114:                                ; preds = %pfor.end113
  call void @__csan_task_exit(i64 %5, i64 %3, i64 %1, i32 1, i64 0)
  reattach within %syncreg35, label %pfor.inc115

pfor.inc115:                                      ; preds = %pfor.preattach114, %pfor.detach48
  call void @__csan_detach_continue(i64 %7, i64 %1, i32 1, i64 0)
  %152 = load i32, i32* %__begin41, align 4
  %inc116 = add nsw i32 %152, 1
  store i32 %inc116, i32* %__begin41, align 4
  %153 = load i32, i32* %__begin41, align 4
  %154 = load i32, i32* %__end42, align 4
  %cmp117 = icmp slt i32 %153, %154
  br i1 %cmp117, label %pfor.cond47, label %pfor.cond.cleanup119, !llvm.loop !9

pfor.cond.cleanup119:                             ; preds = %pfor.inc115
  %155 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !4
  %156 = add i64 %155, 3
  call void @__csan_sync(i64 %156, i32 1)
  sync within %syncreg35, label %sync.continue122

sync.continue122:                                 ; preds = %pfor.cond.cleanup119
  br label %pfor.end123

pfor.end123:                                      ; preds = %sync.continue122, %pfor.end34
  %157 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !4
  %158 = add i64 %157, 0
  call void @__csan_func_exit(i64 %158, i64 %17, i64 1)
  ret void

unreachable.loopexit:                             ; preds = %cleanup101
  br label %unreachable

unreachable.loopexit124:                          ; preds = %cleanup
  br label %unreachable

unreachable:                                      ; preds = %unreachable.loopexit124, %unreachable.loopexit
  unreachable
}

; CHECK: define internal fastcc void @render.outline_pfor.body.entry70.otd2(

; CHECK: cleanup101.otd2:
; CHECK: switch i32 %{{.+}}, label %unreachable.loopexit.otd2 [

; CHECK: unreachable.loopexit.otd2:
; CHECK-NEXT: br label %unreachable.otd2

; CHECK: unreachable.otd2: ; preds = %unreachable.loopexit.otd2
; CHECK-NEXT: unreachable


; CHECK: define internal fastcc void @render.outline_pfor.body.entry14.otd2(

; CHECK: cleanup.otd2:
; CHECK: switch i32 %{{.+}}, label %unreachable.loopexit124.otd2 [

; CHECK: unreachable.loopexit124.otd2:
; CHECK-NEXT: br label %unreachable.otd2

; CHECK: unreachable.otd2: ; preds = %unreachable.loopexit124.otd2
; CHECK-NEXT: unreachable

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

define internal void @__csi_init_callsite_to_function() {
  %1 = load i64, i64* @__csi_unit_func_base_id, align 8
  %2 = add i64 %1, 0
  store i64 %2, i64* @__csi_func_id_render, align 8
  ret void
}

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_func_entry(i64, i8* nocapture readnone, i8* nocapture readnone, i64) #2

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_func_exit(i64, i64, i64) #2

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_load(i64, i8* nocapture readnone, i32, i64) #2

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_store(i64, i8* nocapture readnone, i32, i64) #2

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_detach(i64, i32) #2

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_task(i64, i64, i8* nocapture readnone, i8* nocapture readnone, i64) #2

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_task_exit(i64, i64, i64, i32, i64) #2

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_detach_continue(i64, i64, i32, i64) #2

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_sync(i64, i32) #2

; Function Attrs: nounwind willreturn
declare i8* @llvm.task.frameaddress(i32) #3

; Function Attrs: nofree nosync nounwind willreturn
declare i8* @llvm.stacksave() #4

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #5

define internal void @csirt.unit_ctor() {
  call void @__csanrt_unit_init(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @0, i32 0, i32 0), { i64, i8*, { i8*, i32, i32, i8* }* }* getelementptr inbounds ([16 x { i64, i8*, { i8*, i32, i32, i8* }* }], [16 x { i64, i8*, { i8*, i32, i32, i8* }* }]* @__csi_unit_fed_tables, i32 0, i32 0), { i64, { i8*, i32, i8* }* }* getelementptr inbounds ([4 x { i64, { i8*, i32, i8* }* }], [4 x { i64, { i8*, i32, i8* }* }]* @__csi_unit_obj_tables, i32 0, i32 0), void ()* @__csi_init_callsite_to_function)
  ret void
}

declare void @__csanrt_unit_init(i8*, { i64, i8*, { i8*, i32, i32, i8* }* }*, { i64, { i8*, i32, i8* }* }*, void ()*)

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { inaccessiblemem_or_argmemonly nounwind }
attributes #3 = { nounwind willreturn }
attributes #4 = { nofree nosync nounwind willreturn }
attributes #5 = { nofree nosync nounwind readnone willreturn }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git de2e0acefcde3d5f14282cec03dc421dbb908997)"}
!4 = !{}
!5 = distinct !{!5, !6}
!6 = !{!"tapir.loop.spawn.strategy", i32 1}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}
!9 = distinct !{!9, !6}
