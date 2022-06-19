; Check that setjmp properly stores the base pointer (x19) when it is
; used for computing stack offsets.
;
; RUN: llc < %s -o - | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx12.0.0"

%struct.cuts = type { [3 x %struct.cut_info] }
%struct.cut_info = type { double, double, i32 }
%struct.__cilkrts_stack_frame = type { i32, i32, %struct.__cilkrts_stack_frame*, %struct.__cilkrts_worker*, [5 x i8*] }
%struct.__cilkrts_worker = type { %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, %struct.__cilkrts_stack_frame**, i32, %struct.__cilkrts_stack_frame*, %struct.cilkred_map*, %struct.global_state*, %struct.local_state*, %struct.__cilkrts_stack_frame**, [952 x i8] }
%struct.cilkred_map = type { i32, i32, i32, i8, i32*, %struct.view_info* }
%struct.view_info = type { i8*, %struct.__cilkrts_hyperobject_base* }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i32, i32, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base*, i64)*, void (%struct.__cilkrts_hyperobject_base*, i8*)* }
%struct.global_state = type { %struct.rts_options, i32, %struct.worker_args*, %struct.__cilkrts_worker**, %struct.ReadyDeque*, %struct._opaque_pthread_t**, %struct.Closure*, [48 x i8], %struct.cilk_fiber_pool, [8 x i8], %struct.global_im_pool, [8 x i8], %struct.cilk_im_desc, %"class.std::__1::mutex", [56 x i8], [5 x i8*], i8*, i8, [15 x i8], i32, i32, i32, i8, %struct._opaque_pthread_mutex_t, %struct._opaque_pthread_cond_t, %struct._opaque_pthread_mutex_t, %struct._opaque_pthread_cond_t, [16 x i8], i8, i8, i8, [61 x i8], i32*, i32*, %"class.std::__1::mutex", [48 x i8], i64, [56 x i8], i32, %struct._opaque_pthread_mutex_t, %struct._opaque_pthread_cond_t, %"class.std::__1::mutex", %struct.reducer_id_manager*, %struct.global_sched_stats, [8 x i8] }
%struct.rts_options = type { i64, i32, i32, i32, i32, i32 }
%struct.worker_args = type { i32, %struct.global_state* }
%struct.ReadyDeque = type { %"class.std::__1::mutex", %struct.Closure*, %struct.Closure*, i32, [44 x i8] }
%struct._opaque_pthread_t = type { i64, %struct.__darwin_pthread_handler_rec*, [8176 x i8] }
%struct.__darwin_pthread_handler_rec = type { void (i8*)*, i8*, %struct.__darwin_pthread_handler_rec* }
%struct.Closure = type { %"class.std::__1::mutex", %struct.__cilkrts_stack_frame*, %struct.cilk_fiber*, %struct.cilk_fiber*, i32, i32, i8, i8, i8, i8, i32, i8*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.Closure*, %struct.cilkred_map*, %struct.cilkred_map*, %struct.cilkred_map*, i8*, i8*, %struct.cilk_fiber*, %"struct.std::__1::__compressed_pair_elem", %"struct.std::__1::__compressed_pair_elem", %"struct.std::__1::__compressed_pair_elem", [8 x i8] }
%struct.cilk_fiber = type opaque
%"struct.std::__1::__compressed_pair_elem" = type { i8* }
%struct.cilk_fiber_pool = type { %"class.std::__1::mutex", i32, i32, i64, %struct.cilk_fiber_pool*, %struct.cilk_fiber**, i32, i32, %struct.fiber_pool_stats }
%struct.fiber_pool_stats = type { i32, i32, i32 }
%struct.global_im_pool = type { i8*, i8*, i8**, i32, i32, i64, i64, i64 }
%struct.cilk_im_desc = type { [7 x %struct.im_bucket], i64, [4 x i64] }
%struct.im_bucket = type { i8*, i32, i32, i32, i32, i64 }
%struct._opaque_pthread_mutex_t = type { i64, [56 x i8] }
%struct._opaque_pthread_cond_t = type { i64, [40 x i8] }
%"class.std::__1::mutex" = type { %struct._opaque_pthread_mutex_t }
%struct.reducer_id_manager = type opaque
%struct.global_sched_stats = type { i64, i64, i64, i64, i64, i64, i64, i64, i64, [7 x double], [7 x i64] }
%struct.local_state = type { %struct.__cilkrts_stack_frame**, i16, i8, i8, i32, [5 x i8*], %struct.cilk_fiber_pool, %struct.cilk_im_desc, %struct.cilk_fiber*, %struct.sched_stats }
%struct.sched_stats = type { [7 x i64], [7 x i64], [7 x i64], [7 x i64], i64, i64, i64, i64 }

; Function Attrs: stealable
define void @_Z18walk_serial_helperiiPiPP9AtomGraphS2_P5Model4cutsPdRNSt3__13mapIiNS8_IiNS7_3setINS7_4pairIiiEENS7_4lessISB_EENS7_9allocatorISB_EEEENSC_IiEENSE_INSA_IKiSG_EEEEEESH_NSE_INSA_ISI_SL_EEEEEERNS8_IiNS8_Ii13atom_sim_infoSH_NSE_INSA_ISI_SQ_EEEEEESH_NSE_INSA_ISI_ST_EEEEEEP10NoseHooveriRNS9_IiSH_NSE_IiEEEE() #0 personality i32 (...)* undef {
entry:
  %agg.tmp339 = alloca %struct.cuts, align 8
  %agg.tmp362 = alloca %struct.cuts, align 8
  %agg.tmp366 = alloca %struct.cuts, align 8
  %__cilkrts_sf = alloca %struct.__cilkrts_stack_frame, align 8
  br label %if.then.i526

if.then.i526:                                     ; preds = %entry
  %0 = call i32 @llvm.eh.sjlj.setjmp(i8* undef)
  ret void
}

; CHECK: __Z18walk_serial_helperiiPiPP9AtomGraphS2_P5Model4cutsPdRNSt3__13mapIiNS8_IiNS7_3setINS7_4pairIiiEENS7_4lessISB_EENS7_9allocatorISB_EEEENSC_IiEENSE_INSA_IKiSG_EEEEEESH_NSE_INSA_ISI_SL_EEEEEERNS8_IiNS8_Ii13atom_sim_infoSH_NSE_INSA_ISI_SQ_EEEEEESH_NSE_INSA_ISI_ST_EEEEEEP10NoseHooveriRNS9_IiSH_NSE_IiEEEE:
; CHECK: mov x19, sp
; CHECK: adr [[ADDR:x[0-9]+]], [[BLK:LBB[0-9]+_[0-9]+]]
; CHECK-NEXT: str [[ADDR]], {{\[}}[[CTX:x[0-9]+]], #8{{\]}}
; CHECK-NOT: str xzr, {{\[}}[[CTX]], #24{{\]}}
; CHECK-NEXT: str x19, {{\[}}[[CTX]], #24{{\]}}
; CHECK-NEXT: #EH_SjLj_Setup [[BLK]]

; Function Attrs: nounwind
declare i32 @llvm.eh.sjlj.setjmp(i8*) #1

attributes #0 = { stealable }
attributes #1 = { nounwind }
