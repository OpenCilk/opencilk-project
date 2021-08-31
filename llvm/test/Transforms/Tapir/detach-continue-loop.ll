; Check that the continuation of a detach can be the same spindle as the detach itself.
;
; RUN: opt < %s -analyze -tasks | FileCheck %s
; RUN: opt < %s -passes='print<tasks>' -disable-output 2>&1 | FileCheck %s
source_filename = "heat_recursive_dp.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx11.0.0"

%struct.SimState = type { i32, i32, i32, double, double, double, double, double, double, double, double, i32, i32, double*, i8*, float }

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

define internal fastcc void @walk_dp_xyt(%struct.SimState* %Q, i32 %t0, i32 %t1, i32 %y0, i32 %dy0, i32 %y1, i32 %dy1) unnamed_addr {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  br label %if.then45

if.then45:                                        ; preds = %if.then45, %det.achd57, %entry
  detach within %syncreg, label %det.achd57, label %if.then45

det.achd57:                                       ; preds = %if.then45
  call fastcc void @walk_dp_xyt(%struct.SimState* %Q, i32 %t0, i32 %t1, i32 %y0, i32 %dy0, i32 %y1, i32 %dy1)
  reattach within %syncreg, label %if.then45
}

attributes #0 = { argmemonly nounwind willreturn }

; CHECK: Spindles:
; CHECK-NEXT: {<task entry><func sp entry>%entry<sp exit>}{<phi sp entry>%if.then45<sp exit>}{<task entry><task sp entry>%det.achd57<sp exit><task exit>}

; CHECK: Task tree:
; CHECK-NEXT: task at depth 0: {<task entry><func sp entry>%entry<sp exit>}{<phi sp entry>%if.then45<sp exit>}
; CHECK-NEXT: task at depth 1: {<task entry><task sp entry>%det.achd57<sp exit><task exit>}
