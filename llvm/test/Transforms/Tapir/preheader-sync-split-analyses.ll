; Check that preheader blocks of loops terminated by syncs are
; properly split and that compiler analyses are properly updated.
;
; RUN: opt < %s -licm -S -o - | FileCheck %s
; RUN: opt < %s -passes='lcssa,require<opt-remark-emit>,loop-mssa(licm)' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE.3.9.15.21.27.33.39.45.63.75.159.231.237.381 = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker.0.6.12.18.24.30.36.42.60.72.156.228.234.378*, %struct._IO_FILE.3.9.15.21.27.33.39.45.63.75.159.231.237.381*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt.1.7.13.19.25.31.37.43.61.73.157.229.235.379*, %struct._IO_wide_data.2.8.14.20.26.32.38.44.62.74.158.230.236.380*, %struct._IO_FILE.3.9.15.21.27.33.39.45.63.75.159.231.237.381*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker.0.6.12.18.24.30.36.42.60.72.156.228.234.378 = type opaque
%struct._IO_codecvt.1.7.13.19.25.31.37.43.61.73.157.229.235.379 = type opaque
%struct._IO_wide_data.2.8.14.20.26.32.38.44.62.74.158.230.236.380 = type opaque
%struct.timeval.4.10.16.22.28.34.40.46.64.76.160.232.238.382 = type { i64, i64 }
%struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383 = type { float, float }

@.str = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.2 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.4 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.5 = external dso_local unnamed_addr constant [4 x i8], align 1
@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE.3.9.15.21.27.33.39.45.63.75.159.231.237.381*, align 8
@.str.6 = external dso_local unnamed_addr constant [20 x i8], align 1
@.str.7 = external dso_local unnamed_addr constant [41 x i8], align 1
@.str.8 = external dso_local unnamed_addr constant [61 x i8], align 1
@.str.9 = external dso_local unnamed_addr constant [61 x i8], align 1
@.str.10 = external dso_local unnamed_addr constant [72 x i8], align 1
@.str.11 = external dso_local unnamed_addr constant [68 x i8], align 1
@.str.12 = external dso_local unnamed_addr constant [57 x i8], align 1
@.str.13 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.14 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.15 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.16 = external dso_local unnamed_addr constant [3 x i8], align 1
@specifiers = external dso_local global [5 x i8*], align 16
@opt_types = external dso_local global [5 x i32], align 16
@.str.17 = external dso_local unnamed_addr constant [17 x i8], align 1
@str = external dso_local unnamed_addr constant [4 x i8], align 1
@str.1 = external dso_local unnamed_addr constant [5 x i8], align 1
@__csi_unit_func_base_id = external dso_local global i64
@__csi_unit_func_exit_base_id = external dso_local global i64
@__csi_unit_loop_base_id = external dso_local global i64
@__csi_unit_loop_exit_base_id = external dso_local global i64
@__csi_unit_bb_base_id = external dso_local global i64
@__csi_unit_callsite_base_id = external dso_local global i64
@__csi_unit_load_base_id = external dso_local global i64
@__csi_unit_store_base_id = external dso_local global i64
@__csi_unit_alloca_base_id = external dso_local global i64
@__csi_unit_detach_base_id = external dso_local global i64
@__csi_unit_task_base_id = external dso_local global i64
@__csi_unit_task_exit_base_id = external dso_local global i64
@__csi_unit_detach_continue_base_id = external dso_local global i64
@__csi_unit_sync_base_id = external dso_local global i64
@__csi_unit_allocfn_base_id = external dso_local global i64
@__csi_unit_free_base_id = external dso_local global i64
@__csi_func_id_cos = external global i64
@__csi_func_id_sin = external global i64
@__csi_func_id_compute_w_coefficients = external global i64
@__csi_func_id_fft_unshuffle_32 = external global i64
@__csi_func_id_fft_unshuffle_16 = external global i64
@__csi_func_id_fft_unshuffle_8 = external global i64
@__csi_func_id_fft_unshuffle_4 = external global i64
@__csi_func_id_fft_unshuffle_2 = external global i64
@__csi_func_id_unshuffle = external global i64
@__csi_func_id_fft_twiddle_2 = external global i64
@__csi_func_id_fft_twiddle_4 = external global i64
@__csi_func_id_fft_twiddle_8 = external global i64
@__csi_func_id_fft_twiddle_16 = external global i64
@__csi_func_id_fft_twiddle_32 = external global i64
@__csi_func_id_fft_twiddle_gen = external global i64
@__csi_func_id_fft_aux = external global i64
@__csi_func_id_sqrt = external global i64
@__csi_func_id_printf = external global i64
@__csi_func_id_puts = external global i64
@__csi_func_id_cilk_fft = external global i64
@__csi_func_id_gettimeofday = external global i64
@__csi_func_id_fwrite = external global i64
@__csi_func_id_fprintf = external global i64
@__csi_func_id_get_options = external global i64
@__csi_func_id_test_correctness = external global i64
@__csi_func_id_test_speed = external global i64
@__csi_unit_filename_bugpoint-input-95b2422.bc = external dso_local unnamed_addr constant [26 x i8]
@__csi_unit_function_name_todval = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_function_name_compute_w_coefficients = external dso_local unnamed_addr constant [23 x i8]
@__csi_unit_function_name_fft_unshuffle_32 = external dso_local unnamed_addr constant [17 x i8]
@__csi_unit_function_name_fft_unshuffle_16 = external dso_local unnamed_addr constant [17 x i8]
@__csi_unit_function_name_fft_unshuffle_8 = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_function_name_fft_unshuffle_4 = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_function_name_fft_unshuffle_2 = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_function_name_unshuffle = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_function_name_fft_twiddle_2 = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_function_name_fft_twiddle_4 = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_function_name_fft_twiddle_8 = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_function_name_fft_twiddle_16 = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_function_name_fft_twiddle_32 = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_function_name_fft_twiddle_gen = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_function_name_fft_aux = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_function_name_cilk_fft = external dso_local unnamed_addr constant [9 x i8]
@__csi_unit_function_name_test_fft_elem = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_function_name_test_fft = external dso_local unnamed_addr constant [9 x i8]
@__csi_unit_function_name_test_correctness = external dso_local unnamed_addr constant [17 x i8]
@__csi_unit_function_name_test_speed = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_function_name_usage = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_function_name_main = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_fed_table__csi_unit_func_base_id = external dso_local global [22 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_func_exit_base_id = external dso_local global [22 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_loop_base_id = external dso_local global [3 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_loop_exit_base_id = external dso_local global [0 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_bb_base_id = external dso_local global [0 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_callsite_base_id = external dso_local global [65 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_load_base_id = external dso_local global [494 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_store_base_id = external dso_local global [366 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_detach_base_id = external dso_local global [17 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_task_base_id = external dso_local global [17 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_task_exit_base_id = external dso_local global [17 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_detach_continue_base_id = external dso_local global [17 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_sync_base_id = external dso_local global [17 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_alloca_base_id = external dso_local global [7 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_allocfn_base_id = external dso_local global [5 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_free_base_id = external dso_local global [3 x { i8*, i32, i32, i8* }]
@__csi_unit_object_name_tp = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_ip.0145 = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_ip.081 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_ip.049 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_in = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_ip.033 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_ip.025.prol = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_ip.025 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_ip.254.us = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_ip.148.us = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_ip.148.us.unr = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_object_name_ip.254.us.prol = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_object_name_ip.254 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_ip.254.epil = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_W = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_jp.037.us.i = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_factors = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_stderr = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_obj_table = external dso_local global [494 x { i8*, i32, i8* }]
@__csi_unit_object_name_out = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_jp.155.us = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_jp.049.us = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_jp.049.us.unr = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_object_name_jp.155.us.prol = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_object_name_jp.155 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_jp.155.epil = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_kp.02 = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_kp.042.us.i = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_obj_table.1 = external dso_local global [366 x { i8*, i32, i8* }]
@__csi_unit_object_name_t1 = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_t2 = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_correctness = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_help = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_benchmark = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_size = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_obj_table.2 = external dso_local global [7 x { i8*, i32, i8* }]
@__csi_unit_object_name_call = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_call2 = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_obj_table.3 = external dso_local global [5 x { i8*, i32, i8* }]
@__csi_func_id_todval = external global i64
@__csi_func_id_test_fft_elem = external global i64
@__csi_func_id_usage = external global i64
@__csi_func_id_test_fft = external global i64
@__csi_func_id_main = external global i64
@__csi_unit_fed_tables = external dso_local global [16 x { i64, i8*, { i8*, i32, i32, i8* }* }]
@__csi_unit_obj_tables = external dso_local global [4 x { i64, { i8*, i32, i8* }* }]
@0 = external dso_local unnamed_addr constant [26 x i8], align 1
@llvm.global_ctors = external global [1 x { i32, void ()*, i8* }]

declare dso_local i64 @todval(%struct.timeval.4.10.16.22.28.34.40.46.64.76.160.232.238.382*) local_unnamed_addr #0

declare dso_local void @cilk_fft(i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*) local_unnamed_addr #0

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i8* @malloc(i64) local_unnamed_addr #0

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

declare dso_local fastcc void @compute_w_coefficients(i32, i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*) unnamed_addr #0

declare dso_local fastcc void @fft_aux(i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32) unnamed_addr #0

declare dso_local void @free(i8*) local_unnamed_addr #0

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local void @test_fft_elem(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*) local_unnamed_addr #0

declare dso_local double @cos(double) local_unnamed_addr #0

declare dso_local double @sin(double) local_unnamed_addr #0

declare dso_local void @test_fft(i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*) local_unnamed_addr #0

define dso_local void @test_correctness() local_unnamed_addr #0 {
entry:
  %syncreg.i = tail call token @llvm.syncregion.start()
  br label %for.cond4.preheader

for.cond4.preheader:                              ; preds = %for.inc121, %entry
  br label %for.end

for.end:                                          ; preds = %for.cond4.preheader
  br label %pfor.cond.us.i

pfor.cond.us.i:                                   ; preds = %pfor.inc.us.i, %for.end
  detach within %syncreg.i, label %pfor.body.us.i, label %pfor.inc.us.i

pfor.body.us.i:                                   ; preds = %pfor.cond.us.i
  unreachable

pfor.inc.us.i:                                    ; preds = %pfor.cond.us.i
  br i1 undef, label %pfor.cond.cleanup.i, label %pfor.cond.us.i

pfor.cond.cleanup.i:                              ; preds = %pfor.inc.us.i
  sync within %syncreg.i, label %for.body18

for.body18:                                       ; preds = %for.body18, %pfor.cond.cleanup.i
  call void @__csan_sqrt(i64 undef, i64 undef, i8 0, i64 0, double undef, double undef)
  %0 = load i64, i64* @__csi_unit_callsite_base_id, align 8
  %1 = add i64 %0, 37
  call void @__csan_sqrt(i64 %1, i64 undef, i8 0, i64 0, double undef, double undef)
  br i1 undef, label %for.end76, label %for.body18

; CHECK: pfor.cond.cleanup.i:
; CHECK-NEXT: sync within %syncreg.i, label %[[BB_SPLIT:.+]]

; CHECK: [[BB_SPLIT]]:
; CHECK-NEXT: br label %for.body18

; CHECK: for.body18:
; CHECK: call void @__csan_sqrt(i64 undef, i64 undef, i8 0, i64 0, double undef, double undef)
; CHECK: %0 = load i64, i64* @__csi_unit_callsite_base_id, align 8
; CHECK: %1 = add i64 %0, 37
; CHECK: call void @__csan_sqrt(i64 %1, i64 undef, i8 0, i64 0, double undef, double undef)
; CHECK: br i1

for.end76:                                        ; preds = %for.body18
  br label %if.then79

if.then79:                                        ; preds = %for.end76
  br label %if.end115

if.end115:                                        ; preds = %if.then79
  br i1 undef, label %if.then118, label %for.inc121

if.then118:                                       ; preds = %if.end115
  unreachable

for.inc121:                                       ; preds = %if.end115
  br i1 undef, label %for.end123, label %for.cond4.preheader

for.end123:                                       ; preds = %for.inc121
  ret void
}

declare dso_local double @sqrt(double) local_unnamed_addr #0

declare dso_local i32 @printf(i8*, ...) local_unnamed_addr #0

declare dso_local void @test_speed(i64) local_unnamed_addr #0

declare dso_local i32 @gettimeofday(%struct.timeval.4.10.16.22.28.34.40.46.64.76.160.232.238.382*, i8*) local_unnamed_addr #0

declare dso_local i32 @fprintf(%struct._IO_FILE.3.9.15.21.27.33.39.45.63.75.159.231.237.381*, i8*, ...) local_unnamed_addr #0

declare dso_local i32 @usage() local_unnamed_addr #0

declare dso_local i32 @main(i32, i8**) local_unnamed_addr #0

declare dso_local void @get_options(i32, i8**, i8**, i32*, ...) local_unnamed_addr #0

declare dso_local fastcc void @fft_unshuffle_32(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32) unnamed_addr #0

declare dso_local fastcc void @fft_unshuffle_16(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32) unnamed_addr #0

declare dso_local fastcc void @fft_unshuffle_8(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32) unnamed_addr #0

declare dso_local fastcc void @fft_unshuffle_4(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32) unnamed_addr #0

declare dso_local fastcc void @fft_unshuffle_2(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32) unnamed_addr #0

declare dso_local fastcc void @unshuffle(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32, i32) unnamed_addr #0

declare dso_local fastcc void @fft_twiddle_2(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32, i32) unnamed_addr #0

declare dso_local fastcc void @fft_twiddle_4(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32, i32) unnamed_addr #0

declare dso_local fastcc void @fft_twiddle_8(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32, i32) unnamed_addr #0

declare dso_local fastcc void @fft_twiddle_16(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32, i32) unnamed_addr #0

declare dso_local fastcc void @fft_twiddle_32(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32, i32) unnamed_addr #0

declare dso_local fastcc void @fft_twiddle_gen(i32, i32, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, %struct.COMPLEX.5.11.17.23.29.35.41.47.65.77.161.233.239.383*, i32, i32, i32, i32) unnamed_addr #0

; Function Attrs: nounwind
declare i32 @puts(i8*) local_unnamed_addr #2

; Function Attrs: nounwind
declare i64 @fwrite(i8*, i64, i64, %struct._IO_FILE.3.9.15.21.27.33.39.45.63.75.159.231.237.381*) local_unnamed_addr #2

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #3

declare void @__csi_func_entry(i64, i64)

declare void @__csi_func_exit(i64, i64, i64)

declare void @__csi_before_loop(i64, i64, i64)

declare void @__csi_after_loop(i64, i64)

declare void @__csi_loopbody_entry(i64, i64)

declare void @__csi_loopbody_exit(i64, i64, i64)

declare void @__csi_before_alloca(i64, i64, i64)

; Function Attrs: nounwind
declare void @__csi_after_alloca(i64, i8*, i64, i64) #2

declare void @__csi_before_allocfn(i64, i64, i64, i64, i8*, i64)

declare void @__csi_after_allocfn(i64, i8*, i64, i64, i64, i8*, i64)

declare void @__csi_before_free(i64, i8*, i64)

declare void @__csi_after_free(i64, i8*, i64)

declare dso_local void @__csi_init_callsite_to_function()

; Function Attrs: nounwind
declare void @__csan_func_entry(i64, i8*, i8*, i64) #2

; Function Attrs: nounwind
declare void @__csan_func_exit(i64, i64, i64) #2

; Function Attrs: nounwind
declare void @__csan_load(i64, i8*, i32, i64) #2

; Function Attrs: nounwind
declare void @__csan_store(i64, i8*, i32, i64) #2

; Function Attrs: nounwind
declare void @__csan_large_load(i64, i8*, i64, i64) #2

; Function Attrs: nounwind
declare void @__csan_large_store(i64, i8*, i64, i64) #2

; Function Attrs: nounwind
declare void @__csan_before_call(i64, i64, i8, i64) #2

; Function Attrs: nounwind
declare void @__csan_after_call(i64, i64, i8, i64) #2

; Function Attrs: nounwind
declare void @__csan_detach(i64, i8) #2

; Function Attrs: nounwind
declare void @__csan_task(i64, i64, i8*, i8*, i64) #2

; Function Attrs: nounwind
declare void @__csan_task_exit(i64, i64, i64, i8, i64) #2

; Function Attrs: nounwind
declare void @__csan_detach_continue(i64, i64) #2

; Function Attrs: nounwind
declare void @__csan_sync(i64, i8) #2

; Function Attrs: nounwind
declare void @__csan_after_allocfn(i64, i8*, i64, i64, i64, i8*, i64) #2

; Function Attrs: nounwind
declare void @__csan_after_free(i64, i8*, i64) #2

; Function Attrs: nounwind
declare void @__cilksan_disable_checking() #2

; Function Attrs: nounwind
declare void @__cilksan_enable_checking() #2

; Function Attrs: nounwind
declare void @__csan_get_MAAP(i8*, i64, i8) #2

; Function Attrs: nounwind
declare void @__csan_set_MAAP(i8, i64) #2

; Function Attrs: nounwind
declare void @__csan_before_loop(i64, i64, i64) #2

; Function Attrs: nounwind
declare void @__csan_after_loop(i64, i8, i64) #2

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #4

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #2

; Function Attrs: nounwind
declare void @__csan_cos(i64, i64, i8, i64, double, double) #2

; Function Attrs: nounwind
declare void @__csan_sin(i64, i64, i8, i64, double, double) #2

; Function Attrs: nounwind willreturn
declare i8* @llvm.task.frameaddress(i32) #5

; Function Attrs: nounwind
declare void @__csan_sqrt(i64, i64, i8, i64, double, double) #2

; Function Attrs: nounwind
declare void @__csan_printf(i64, i64, i8, i64, i32, i8*, ...) #2

; Function Attrs: nounwind
declare void @__csan_puts(i64, i64, i8, i64, i32, i8*) #2

; Function Attrs: nounwind
declare void @__csan_gettimeofday(i64, i64, i8, i64, i32, %struct.timeval.4.10.16.22.28.34.40.46.64.76.160.232.238.382*, i8*) #2

; Function Attrs: nounwind
declare void @__csan_fwrite(i64, i64, i8, i64, i64, i8*, i64, i64, %struct._IO_FILE.3.9.15.21.27.33.39.45.63.75.159.231.237.381*) #2

; Function Attrs: nounwind
declare void @__csan_fprintf(i64, i64, i8, i64, i32, %struct._IO_FILE.3.9.15.21.27.33.39.45.63.75.159.231.237.381*, i8*, ...) #2

declare dso_local void @csirt.unit_ctor()

declare void @__csanrt_unit_init(i8*, { i64, i8*, { i8*, i32, i32, i8* }* }*, { i64, { i8*, i32, i8* }* }*, void ()*)

attributes #0 = { "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nounwind }
attributes #3 = { argmemonly willreturn }
attributes #4 = { nounwind readnone }
attributes #5 = { nounwind willreturn }

!llvm.ident = !{!0}

!0 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 5974a1c324324924ca49dafec3061e9257f8a455)"}
