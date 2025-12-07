; Check that SROA unfolds GEP phis appropriately for allocas in tasks.
;
; RUN: opt < %s -passes="function<eager-inv>(sroa<preserve-cfg>)" -S | FileCheck %s
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%"struct.parlay::slice.922" = type { %"class.parlay::delayed_sequence<const std::__1::unique_ptr<long long> &, std::__1::unique_ptr<long long>, (lambda at /Users/neboat/Software/cilktest/parlaylib/include/parlay/internal/sample_sort.h:156:67)>::iterator.923", %"class.parlay::delayed_sequence<const std::__1::unique_ptr<long long> &, std::__1::unique_ptr<long long>, (lambda at /Users/neboat/Software/cilktest/parlaylib/include/parlay/internal/sample_sort.h:156:67)>::iterator.923" }
%"class.parlay::delayed_sequence<const std::__1::unique_ptr<long long> &, std::__1::unique_ptr<long long>, (lambda at /Users/neboat/Software/cilktest/parlaylib/include/parlay/internal/sample_sort.h:156:67)>::iterator.923" = type { ptr, i64 }

define { ptr, i32 } @_ZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEv() personality ptr null {
entry:
  %syncreg.i.i.i.i9.i = call token @llvm.syncregion.start()
  sync within %syncreg.i.i.i.i9.i, label %sync.continue.i.i.i.i.i39

sync.continue.i.i.i.i.i39:                        ; preds = %entry
  detach within %syncreg.i.i.i.i9.i, label %pfor.body.entry.i.i.i152.i, label %pfor.inc.i.i.i89.i unwind label %lpad30.loopexit.i87.i

pfor.body.entry.i.i.i152.i:                       ; preds = %sync.continue.i.i.i.i.i39
  %agg.tmp20.i.i.i.i.i154.i = alloca %"struct.parlay::slice.922", align 8
  br label %"_ZZN6parlay8internal10sliced_forIZNS0_20sample_sort_inplace_ImPNSt3__110unique_ptrIxNS3_14default_deleteIxEEEES8_ZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEvNS_5sliceIT0_SC_EENSB_IT1_SE_EERKT2_EUlmmmE_EEvmmRKT_jENKUlmE_clEm.exit.i.i.i.i"

; CHECK: pfor.body.entry.i.i.i152.i:
; CHECK: [[SROA_GEP:%.+]] = getelementptr i8, ptr %agg.tmp20.i.i.i.i.i154.i, i64 8 

"_ZZN6parlay8internal10sliced_forIZNS0_20sample_sort_inplace_ImPNSt3__110unique_ptrIxNS3_14default_deleteIxEEEES8_ZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEvNS_5sliceIT0_SC_EENSB_IT1_SE_EERKT2_EUlmmmE_EEvmmRKT_jENKUlmE_clEm.exit.i.i.i.i": ; preds = %pfor.body.entry.i.i.i152.i
  %agg.tmp20.i.i.i.i.i154.i.sink195 = phi ptr [ %agg.tmp20.i.i.i.i.i154.i, %pfor.body.entry.i.i.i152.i ]
  %s.sroa.3.0.s2.sroa_idx.i.i.i.i52.i.i.i.i.i199.i = getelementptr i8, ptr %agg.tmp20.i.i.i.i.i154.i.sink195, i64 8
  call fastcc void null([2 x ptr] zeroinitializer, ptr %agg.tmp20.i.i.i.i.i154.i, [2 x ptr] zeroinitializer)
  reattach within %syncreg.i.i.i.i9.i, label %pfor.inc.i.i.i89.i

; CHECK: "_ZZN6parlay8internal10sliced_forIZNS0_20sample_sort_inplace_ImPNSt3__110unique_ptrIxNS3_14default_deleteIxEEEES8_ZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEvNS_5sliceIT0_SC_EENSB_IT1_SE_EERKT2_EUlmmmE_EEvmmRKT_jENKUlmE_clEm.exit.i.i.i.i":
; CHECK: phi ptr [ [[SROA_GEP]], %pfor.body.entry.i.i.i152.i ]
; CHECK: reattach

pfor.inc.i.i.i89.i:                               ; preds = %"_ZZN6parlay8internal10sliced_forIZNS0_20sample_sort_inplace_ImPNSt3__110unique_ptrIxNS3_14default_deleteIxEEEES8_ZN44TestSampleSort_TestSortInplaceUniquePtr_Test8TestBodyEvE3$_2EEvNS_5sliceIT0_SC_EENSB_IT1_SE_EERKT2_EUlmmmE_EEvmmRKT_jENKUlmE_clEm.exit.i.i.i.i", %sync.continue.i.i.i.i.i39
  ret { ptr, i32 } zeroinitializer

lpad30.loopexit.i87.i:                            ; preds = %sync.continue.i.i.i.i.i39
  %lpad.loopexit87.i.i = landingpad { ptr, i32 }
          cleanup
  ret { ptr, i32 } %lpad.loopexit87.i.i
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
