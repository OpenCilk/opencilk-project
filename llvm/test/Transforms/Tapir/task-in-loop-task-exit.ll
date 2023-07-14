; Check that loop optimizations properly handle tasks within task
; exits.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(inline,function<eager-inv>(early-cse<memssa>,loop-mssa(loop-instsimplify))))" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.anon.645 = type { ptr, ptr }

define void @_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEv() personality ptr null {
entry:
  call fastcc void @"_ZN6parlay8internal7delayed9filter_opIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1EEDaOT_OT0_"()
  ret void
}

define internal fastcc void @"_ZN6parlay8internal7delayed9filter_opIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1EEDaOT_OT0_"() {
entry:
  call fastcc void @"_ZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1EC2ISB_SC_EEOT_OT0_"()
  ret void
}

define linkonce_odr void @_ZN6parlay17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EED2Ev() {
entry:
  call void @_ZN6parlay17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EE12storage_implD2Ev()
  ret void
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

define internal fastcc void @"_ZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1EC2ISB_SC_EEOT_OT0_"() personality ptr null {
entry:
  call fastcc void @"_ZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1E13filter_blocksISB_SC_EEDaOT_OT0_"()
  ret void
}

define internal fastcc void @"_ZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1E13filter_blocksISB_SC_EEDaOT_OT0_"() {
entry:
  call fastcc void @"_ZN6parlay8internal8tabulateIZNS0_7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES7_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS8_8TestBodyEvE3$_1E13filter_blocksISC_SD_EEDaOT_OT0_EUlmE_EEDamSH_m"()
  ret void
}

define internal fastcc void @"_ZN6parlay8internal8tabulateIZNS0_7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES7_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS8_8TestBodyEvE3$_1E13filter_blocksISC_SD_EEDaOT_OT0_EUlmE_EEDamSH_m"() {
entry:
  call fastcc void @"_ZN6parlay8sequenceINS0_ISt6vectorIiSaIiEENS_9allocatorIS3_EELb0EEENS4_IS6_EELb0EE13from_functionIZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS3_S3_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSE_8TestBodyEvE3$_1E13filter_blocksISI_SJ_EEDaOT_OT0_EUlmE_EES8_mSN_m"()
  ret void
}

define internal fastcc void @"_ZN6parlay8sequenceINS0_ISt6vectorIiSaIiEENS_9allocatorIS3_EELb0EEENS4_IS6_EELb0EE13from_functionIZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS3_S3_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSE_8TestBodyEvE3$_1E13filter_blocksISI_SJ_EEDaOT_OT0_EUlmE_EES8_mSN_m"() {
entry:
  call fastcc void @"_ZN6parlay8sequenceINS0_ISt6vectorIiSaIiEENS_9allocatorIS3_EELb0EEENS4_IS6_EELb0EEC2IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS3_S3_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSE_8TestBodyEvE3$_1E13filter_blocksISI_SJ_EEDaOT_OT0_EUlmE_EEmSN_NS8_18_from_function_tagEm"()
  ret void
}

define internal fastcc void @"_ZN6parlay8sequenceINS0_ISt6vectorIiSaIiEENS_9allocatorIS3_EELb0EEENS4_IS6_EELb0EEC2IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS3_S3_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSE_8TestBodyEvE3$_1E13filter_blocksISI_SJ_EEDaOT_OT0_EUlmE_EEmSN_NS8_18_from_function_tagEm"() personality ptr null {
entry:
  call fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_ISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EEENS5_IS7_EELb0EEC1IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS4_S4_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSF_8TestBodyEvE3$_1E13filter_blocksISJ_SK_EEDaOT_OT0_EUlmE_EEmSO_NS9_18_from_function_tagEmEUlmE_EEvmmSO_lb"()
  ret void
}

define internal fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_ISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EEENS5_IS7_EELb0EEC1IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS4_S4_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSF_8TestBodyEvE3$_1E13filter_blocksISJ_SK_EEDaOT_OT0_EUlmE_EEmSO_NS9_18_from_function_tagEmEUlmE_EEvmmSO_lb"() {
entry:
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.body.entry, %pfor.cond, %entry
  detach within none, label %pfor.body.entry, label %pfor.cond

pfor.body.entry:                                  ; preds = %pfor.cond
  call fastcc void @"_ZZN6parlay8sequenceINS0_ISt6vectorIiSaIiEENS_9allocatorIS3_EELb0EEENS4_IS6_EELb0EEC1IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS3_S3_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSE_8TestBodyEvE3$_1E13filter_blocksISI_SJ_EEDaOT_OT0_EUlmE_EEmSN_NS8_18_from_function_tagEmENKUlmE_clEm"()
  reattach within none, label %pfor.cond
}

define internal fastcc void @"_ZZN6parlay8sequenceINS0_ISt6vectorIiSaIiEENS_9allocatorIS3_EELb0EEENS4_IS6_EELb0EEC1IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS3_S3_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSE_8TestBodyEvE3$_1E13filter_blocksISI_SJ_EEDaOT_OT0_EUlmE_EEmSN_NS8_18_from_function_tagEmENKUlmE_clEm"() personality ptr null {
entry:
  call fastcc void @"_ZZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1E13filter_blocksISB_SC_EEDaOT_OT0_ENKUlmE_clEm"()
  call void @_ZN6parlay17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EED2Ev()
  ret void
}

define internal fastcc void @"_ZZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1E13filter_blocksISB_SC_EEDaOT_OT0_ENKUlmE_clEm"() {
entry:
  call fastcc void @"_ZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1E12filter_blockINS9_8iteratorERSC_EEDaT_SH_OT0_m"()
  ret void
}

define internal fastcc void @"_ZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1E12filter_blockINS9_8iteratorERSC_EEDaT_SH_OT0_m"() personality ptr null {
entry:
  invoke void null(ptr null, i64 0)
          to label %invoke.cont15 unwind label %lpad14

invoke.cont15:                                    ; preds = %entry
  ret void

lpad14:                                           ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  resume { ptr, i32 } zeroinitializer
}

define linkonce_odr void @_ZN6parlay17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EE12storage_implD2Ev() personality ptr null {
entry:
  call void @_ZN6parlay17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EE12storage_impl5clearEv()
  ret void
}

define linkonce_odr void @_ZN6parlay17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EE12storage_impl5clearEv() {
entry:
  br i1 poison, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  call void @_ZN6parlay17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EE12storage_impl11destroy_allEv()
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

define linkonce_odr void @_ZN6parlay17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EE12storage_impl11destroy_allEv() {
entry:
  %ref.tmp111 = alloca [0 x [0 x [0 x %class.anon.645]]], i32 0, align 8
  call void @_ZN6parlay12parallel_forIZNS_17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS5_EELb0EE12storage_impl11destroy_allEvEUlmE_EEvmmOT_lb(ptr %ref.tmp111)
  ret void
}

define linkonce_odr void @_ZN6parlay12parallel_forIZNS_17sequence_internal13sequence_baseISt6vectorIiSaIiEENS_9allocatorIS5_EELb0EE12storage_impl11destroy_allEvEUlmE_EEvmmOT_lb(ptr %f) {
entry:
  %syncreg19 = call token @llvm.syncregion.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.body.entry, %pfor.cond, %entry
  detach within %syncreg19, label %pfor.body.entry, label %pfor.cond

pfor.body.entry:                                  ; preds = %pfor.cond
  store i64 0, ptr %f, align 8
  reattach within %syncreg19, label %pfor.cond
}

; CHECK: define internal fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_ISt6vectorIiSaIiEENS_9allocatorIS4_EELb0EEENS5_IS7_EELb0EEC1IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS4_S4_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSF_8TestBodyEvE3$_1E13filter_blocksISJ_SK_EEDaOT_OT0_EUlmE_EEmSO_NS9_18_from_function_tagEmEUlmE_EEvmmSO_lb"() personality ptr null {

; CHECK: pfor.cond:
; CHECK-NEXT: detach within none, label %pfor.body.entry, label %pfor.cond.backedge unwind label

; CHECK: pfor.body.entry:
; CHECK-NEXT: [[REFTMP11IIIII:%.+]] = alloca [0 x [0 x [0 x %class.anon.645]]], i32 0
; CHECK-NEXT: [[TFI:%.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: [[SYNCREG19IIIIII:%.+]] = call token @llvm.syncregion.start()
; CHECK-NEXT: invoke void null(ptr null, i64 0)
; CHECK-NEXT: to label %"_ZZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1E13filter_blocksISB_SC_EEDaOT_OT0_ENKUlmE_clEm.exit.i" unwind label %lpad14.i.i.i

; CHECK: "_ZZN6parlay8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceISt6vectorIiSaIiEES6_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNS7_8TestBodyEvE3$_1E13filter_blocksISB_SC_EEDaOT_OT0_ENKUlmE_clEm.exit.i":
; CHECK-NEXT: br i1 false, label %"_ZZN6parlay8sequenceINS0_ISt6vectorIiSaIiEENS_9allocatorIS3_EELb0EEENS4_IS6_EELb0EEC1IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS3_S3_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSE_8TestBodyEvE3$_1E13filter_blocksISI_SJ_EEDaOT_OT0_EUlmE_EEmSN_NS8_18_from_function_tagEmENKUlmE_clEm.exit", label %if.then.i.i.i.i

; CHECK: if.then.i.i.i.i:
; CHECK-NEXT: br label %pfor.cond.i.i.i.i.i.i

; CHECK: pfor.cond.i.i.i.i.i.i:
; CHECK-NEXT: detach within [[SYNCREG19IIIIII]], label %pfor.body.entry.i.i.i.i.i.i, label %pfor.cond.backedge.i.i.i.i.i.i

; CHECK: pfor.body.entry.i.i.i.i.i.i:
; CHECK-NEXT: store i64 0, ptr %ref.tmp111.i.i.i.i.i
; CHECK-NEXT: reattach within [[SYNCREG19IIIIII]], label %pfor.cond.backedge.i.i.i.i.i.i

; CHECK: "_ZZN6parlay8sequenceINS0_ISt6vectorIiSaIiEENS_9allocatorIS3_EELb0EEENS4_IS6_EELb0EEC1IZNS_8internal7delayed25block_delayed_filter_op_tIRKNS_16delayed_sequenceIS3_S3_ZN58TestDelayedFilterOp_TestFilterOpNonTrivialTemporaries_Test8TestBodyEvE3$_0EEZNSE_8TestBodyEvE3$_1E13filter_blocksISI_SJ_EEDaOT_OT0_EUlmE_EEmSN_NS8_18_from_function_tagEmENKUlmE_clEm.exit":
; CHECK: reattach within none, label %pfor.cond.backedge

; uselistorder directives
uselistorder ptr null, { 8, 9, 0, 2, 3, 10, 11, 1, 12, 13, 4, 14, 15, 5, 16, 17, 6, 18, 19, 7 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
