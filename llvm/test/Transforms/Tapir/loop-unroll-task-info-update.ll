; Check that Task Info is properly updated by loop unrolling.
;
; RUN: opt < %s -passes="function<eager-inv>(loop-unroll<O3>,loop-mssa(licm<allowspeculation>))" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @"_ZN102_$LT$core..iter..adapters..map..Map$LT$I$C$F$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4fold17h7ca9d764f65b661fE"() personality ptr null {
  br label %1

1:                                                ; preds = %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread", %2, %0
  %.sroa.9.0 = phi i16 [ 0, %0 ], [ 1, %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread" ], [ 0, %2 ]
  %.sroa.12.0 = phi i16 [ 1, %0 ], [ 0, %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread" ], [ %.sroa.12.0, %2 ]
  br i1 false, label %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit", label %2

"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit": ; preds = %1
  tail call void @llvm.assume(i1 false)
  br label %2

2:                                                ; preds = %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit", %1
  br i1 false, label %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread", label %1

"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread": ; preds = %2
  br label %1
}

; CHECK: define void @"_ZN102_$LT$core..iter..adapters..map..Map$LT$I$C$F$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4fold17h7ca9d764f65b661fE"()
; CHECK-NEXT: br label %.outer

; CHECK: .outer:
; CHECK-NEXT: br label %.peel.begin

; CHECK: .peel.begin:
; CHECK-NEXT: br label %1

; CHECK: 1:
; CHECK-NEXT: br i1 false, label %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit.peel", label %2

; CHECK: "_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit.peel":
; CHECK-NEXT: tail call void @llvm.assume(i1 false)
; CHECK-NEXT: br label %2

; CHECK: 2:
; CHECK-NEXT: br i1 false, label %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread", label %.peel.next

; CHECK: .peel.next:
; CHECK-NEXT: br label %.peel.next1

; CHECK: .peel.next1:
; CHECK-NEXT: br label %.outer.peel.newph

; CHECK: .outer.peel.newph:
; CHECK-NEXT: br label %3

; CHECK: 3:
; CHECK-NEXT: br i1 false, label %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit", label %4

; CHECK: "_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit":
; CHECK-NEXT: tail call void @llvm.assume(i1 false)
; CHECK-NEXT: br label %4

; CHECK: 4:
; CHECK-NEXT: br i1 false, label %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread.loopexit", label %3

; CHECK: "_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread.loopexit":
; CHECK-NEXT: br label %"_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread"

; CHECK: "_ZN104_$LT$core..iter..adapters..cloned..Cloned$LT$I$GT$$u20$as$u20$core..iter..traits..iterator..Iterator$GT$4next17h2f9fd05836d8afd1E.exit3.thread":
; CHECK-NEXT: br label %.outer

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.assume(i1 noundef) #0

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
