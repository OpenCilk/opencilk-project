; Test optimization and lowering of tapir.runtime intrinsics.
; 1) Check that tapir.runtime.start intrinsics aren't hoisted out of taskframes.
; 2) Check that tapir.runtime intrinsics only cause one OpenCilk ABI call to be inserted for each.
;
; RUN: opt < %s -passes="task-simplify" -S | FileCheck %s --check-prefix=TS
; RUN: opt < %s -passes="tapir2target" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s --check-prefix=TT
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.resume.sl_p0i32s(token, { ptr, i32 }) #1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #0

; TS: define {{.*}} void @_ZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_(
; TS: %[[SYNCREG_I8:.+]] = tail call token @llvm.syncregion.start()
; TS: %[[OUTER_TRS:.+]] = call token @llvm.tapir.runtime.start()
; TS: detach within %[[SYNCREG_I8]], label %[[NESTED:.+]], label %[[NESTED_CONT:.+]] unwind

; TS: [[NESTED]]:
; TS: reattach within %[[SYNCREG_I8]], label %[[NESTED_CONT]]

; TS: [[NESTED_CONT]]:
; TS: %[[INLINED_TF:.+]] = call token @llvm.taskframe.create()
; TS-DAG: %[[INLINED_TRS:.+]] = call token @llvm.tapir.runtime.start()
; TS-DAG: %[[SYNCREG_I25:.+]] = call token @llvm.syncregion.start()
; TS: detach within %[[SYNCREG_I25]], label %[[NESTED_TF:.+]], label %{{.+}} unwind label %[[LPAD2_I26:.+]]

; TS: [[NESTED_TF]]:
; TS: invoke void @_ZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_(
; TS-NEXT: to label %{{.+}} unwind label %[[NESTED_TF_LPAD:.+]]

; TS: sync within %[[SYNCREG_I25]], label %[[SYNC_CONT:.+]]

; TS: [[SYNC_CONT]]:
; TS-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG_I25]])
; TS-NEXT: to label %[[SYNC_UNWIND_CONT:.+]] unwind

; TS: [[NESTED_TF_LPAD]]:
; TS-NEXT: landingpad
; TS-NEXT: cleanup
; TS-NEXT: invoke void @llvm.detached.rethrow.sl_p0i32s(token %[[SYNCREG_I25]],
; TS-NEXT: to label %{{.+}} unwind label %[[LPAD2_I26]]

; TS: [[LPAD2_I26]]:
; TS-NEXT: landingpad
; TS-NEXT: cleanup
; TS: call void @llvm.tapir.runtime.end(token %[[INLINED_TRS]])
; TS: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[INLINED_TF]],

; TS: [[SYNC_UNWIND_CONT]]:
; TS: call void @llvm.tapir.runtime.end(token %[[INLINED_TRS]])
; TS: call void @llvm.taskframe.end(token %[[INLINED_TF]])
; TS: sync within %[[SYNCREG_I8]], label

; TS: call void @llvm.tapir.runtime.end(token %[[OUTER_TRS]])

; TS: call void @llvm.tapir.runtime.end(token %[[OUTER_TRS]])

; TS: ret void

define dso_local void @_ZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_() personality ptr null {
entry:
  %syncreg.i8 = tail call token @llvm.syncregion.start()
  %0 = call token @llvm.tapir.runtime.start()
  detach within %syncreg.i8, label %det.achd.i17, label %det.cont.i12.tf.tf.tf.tf.tf unwind label %lpad2.i9

det.achd.i17:                                     ; preds = %entry
  invoke void @_ZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_()
          to label %_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE1_clEv.exit.i unwind label %lpad.i18

_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE1_clEv.exit.i: ; preds = %det.achd.i17
  reattach within %syncreg.i8, label %det.cont.i12.tf.tf.tf.tf.tf

det.cont.i12.tf.tf.tf.tf.tf:                      ; preds = %_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE1_clEv.exit.i, %entry
  %tf.i = call token @llvm.taskframe.create()
  %syncreg.i25 = call token @llvm.syncregion.start()
  %1 = call token @llvm.tapir.runtime.start()
  detach within %syncreg.i25, label %det.achd.i34, label %det.cont.i29 unwind label %lpad2.i26

det.achd.i34:                                     ; preds = %det.cont.i12.tf.tf.tf.tf.tf
  invoke void @_ZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_()
          to label %_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE0_clEv.exit.i unwind label %lpad.i40

_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE0_clEv.exit.i: ; preds = %det.achd.i34
  reattach within %syncreg.i25, label %det.cont.i29

det.cont.i29:                                     ; preds = %_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE0_clEv.exit.i, %det.cont.i12.tf.tf.tf.tf.tf
  invoke void @_ZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_()
          to label %_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE_clEv.exit.i unwind label %lpad9.tfsplit.split-lp.i30

_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE_clEv.exit.i: ; preds = %det.cont.i29
  sync within %syncreg.i25, label %sync.continue.i33

sync.continue.i33:                                ; preds = %_ZZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_ENKUlvE_clEv.exit.i
  invoke void @llvm.sync.unwind(token %syncreg.i25)
          to label %_ZN6parlay6par_doIRZNS_8internal9quicksortIP20SelfReferentialThingSt4lessIS3_EEEvT_mRKT0_EUlvE_RZNS2_IS4_S6_EEvS7_mSA_EUlvE0_EEvOS7_OS8_b.exit unwind label %lpad9.tfsplit.split-lp.i30

lpad.i40:                                         ; preds = %det.achd.i34
  %2 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg.i25, { ptr, i32 } zeroinitializer)
          to label %unreachable.i41 unwind label %lpad2.i26

lpad2.i26:                                        ; preds = %lpad.i40, %det.cont.i12.tf.tf.tf.tf.tf
  %3 = landingpad { ptr, i32 }
          cleanup
  br label %lpad9.i27

lpad9.tfsplit.split-lp.i30:                       ; preds = %sync.continue.i33, %det.cont.i29
  %lpad.tfsplit.split-lp.i31 = landingpad { ptr, i32 }
          cleanup
  br label %lpad9.i27

lpad9.i27:                                        ; preds = %lpad9.tfsplit.split-lp.i30, %lpad2.i26
  call void @llvm.tapir.runtime.end(token %1)
  invoke void @llvm.taskframe.resume.sl_p0i32s(token %tf.i, { ptr, i32 } zeroinitializer)
          to label %lpad9.tfsplit.split-lp.i13.unreachable unwind label %lpad9.tfsplit.split-lp.i13.tfsplit

unreachable.i41:                                  ; preds = %lpad.i40
  unreachable

lpad9.tfsplit.split-lp.i13.unreachable:           ; preds = %lpad9.i27
  unreachable

_ZN6parlay6par_doIRZNS_8internal9quicksortIP20SelfReferentialThingSt4lessIS3_EEEvT_mRKT0_EUlvE_RZNS2_IS4_S6_EEvS7_mSA_EUlvE0_EEvOS7_OS8_b.exit: ; preds = %sync.continue.i33
  call void @llvm.tapir.runtime.end(token %1)
  call void @llvm.taskframe.end(token %tf.i)
  sync within %syncreg.i8, label %sync.continue.i16

sync.continue.i16:                                ; preds = %_ZN6parlay6par_doIRZNS_8internal9quicksortIP20SelfReferentialThingSt4lessIS3_EEEvT_mRKT0_EUlvE_RZNS2_IS4_S6_EEvS7_mSA_EUlvE0_EEvOS7_OS8_b.exit
  call void @llvm.tapir.runtime.end(token %0)
  ret void

lpad.i18:                                         ; preds = %det.achd.i17
  %4 = landingpad { ptr, i32 }
          cleanup
  unreachable

lpad2.i9:                                         ; preds = %entry
  %5 = landingpad { ptr, i32 }
          cleanup
  br label %lpad9.i10

lpad9.tfsplit.split-lp.i13.tfsplit:               ; preds = %lpad9.i27
  %lpad.tfsplit = landingpad { ptr, i32 }
          cleanup
  br label %lpad9.i10

lpad9.i10:                                        ; preds = %lpad9.tfsplit.split-lp.i13.tfsplit, %lpad2.i9
  call void @llvm.tapir.runtime.end(token %0)
  ret void
}

; TT: define {{.*}}void @_ZN6parlay8internal9quicksortIP20SelfReferentialThingSt4lessIS2_EEEvT_mRKT0_.outline_det.cont.i12.tf.tf.tf.tf.tf.tf.otf0(
; TT: %[[CILKRTS_SF:.+]] = alloca %struct.__cilkrts_stack_frame

; TT: call void @__cilkrts_enter_frame(ptr %[[CILKRTS_SF]])
; TT-NOT: call void @__cilkrts_enter_frame(ptr %[[CILKRTS_SF]])

; TT: call i32 @__cilk_prepare_spawn(ptr %[[CILKRTS_SF]])

; TT: call void @__cilk_parent_epilogue(ptr %[[CILKRTS_SF]])
; TT-NOT: call void @__cilk_parent_epilogue(ptr %[[CILKRTS_SF]])
; TT: resume

; TT: call void @__cilk_parent_epilogue(ptr %[[CILKRTS_SF]])
; TT-NOT: call void @__cilk_parent_epilogue(ptr %[[CILKRTS_SF]])
; TT: ret void

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.end(token) #0

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { willreturn memory(argmem: readwrite) }
