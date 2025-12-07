; Check that inlining does not insert taskframes unnecessarily due to allocas in tasks.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(inline))" -S | FileCheck %s
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; CHECK-NOT: call token @llvm.taskframe.create()

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

define fastcc { ptr, i32 } @"_ZN6parlay8internal13bucket_sort_rIPNSt3__110unique_ptrIxNS2_14default_deleteIxEEEES7_ZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEvNS_5sliceIT_SB_EENSA_IT0_SD_EET1_bb"() personality ptr null {
entry:
  %call11 = invoke fastcc i1 @"_ZN6parlay8internal11get_bucketsIPNSt3__110unique_ptrIxNS2_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SB_EEPhT0_m"([2 x ptr] zeroinitializer, ptr null, i64 0)
          to label %common.ret unwind label %lpad5

common.ret:                                       ; preds = %lpad5, %entry
  %common.ret.op = phi { ptr, i32 } [ zeroinitializer, %lpad5 ], [ zeroinitializer, %entry ]
  ret { ptr, i32 } %common.ret.op

lpad5:                                            ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  br label %common.ret
}

define fastcc i1 @"_ZN6parlay8internal11get_bucketsIPNSt3__110unique_ptrIxNS2_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SB_EEPhT0_m"([2 x ptr] %A.coerce, ptr %buckets, i64 %rounds) personality ptr null {
entry:
  %0 = call fastcc ptr @"_ZN6parlay8sequenceImNS_9allocatorImEELb0EE13from_functionIZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS7_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SG_EEPhT0_mEUlmE_EES3_mOSG_m"()
  resume { ptr, i32 } zeroinitializer
}

define fastcc ptr @"_ZN6parlay8sequenceImNS_9allocatorImEELb0EE13from_functionIZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS7_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SG_EEPhT0_mEUlmE_EES3_mOSG_m"() {
entry:
  %call = call fastcc ptr @"_ZN6parlay8sequenceImNS_9allocatorImEELb0EEC1IZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS7_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SG_EEPhT0_mEUlmE_EEmOSG_NS3_18_from_function_tagEm"()
  ret ptr %call
}

define fastcc ptr @"_ZN6parlay8sequenceImNS_9allocatorImEELb0EEC1IZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS7_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SG_EEPhT0_mEUlmE_EEmOSG_NS3_18_from_function_tagEm"() {
entry:
  %call = call fastcc ptr @"_ZN6parlay8sequenceImNS_9allocatorImEELb0EEC2IZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS7_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SG_EEPhT0_mEUlmE_EEmOSG_NS3_18_from_function_tagEm"()
  ret ptr %call
}

define fastcc ptr @"_ZN6parlay8sequenceImNS_9allocatorImEELb0EEC2IZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS7_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SG_EEPhT0_mEUlmE_EEmOSG_NS3_18_from_function_tagEm"() {
entry:
  call fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEELb0EEC1IZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS8_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SH_EEPhT0_mEUlmE_EEmOSH_NS4_18_from_function_tagEmEUlmE_EEvmmSM_lb"()
  ret ptr null
}

define fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEELb0EEC1IZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS8_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SH_EEPhT0_mEUlmE_EEmOSH_NS4_18_from_function_tagEmEUlmE_EEvmmSM_lb"() {
entry:
  %syncreg = call token @llvm.syncregion.start()
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %entry
  %0 = call fastcc ptr @"_ZZN6parlay8sequenceImNS_9allocatorImEELb0EEC1IZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS7_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SG_EEPhT0_mEUlmE_EEmOSG_NS3_18_from_function_tagEmENKUlmE_clEm"()
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body.entry, %entry
  ret void
}

define fastcc ptr @"_ZZN6parlay8sequenceImNS_9allocatorImEELb0EEC1IZNS_8internal11get_bucketsIPNSt3__110unique_ptrIxNS7_14default_deleteIxEEEEZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEbNS_5sliceIT_SG_EEPhT0_mEUlmE_EEmOSG_NS3_18_from_function_tagEmENKUlmE_clEm"() {
entry:
  %ref.tmp = alloca i64, align 8
  ret ptr %ref.tmp
}

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
