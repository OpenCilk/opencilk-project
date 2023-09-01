; Check that Cilksan properly computes Tapir Task info after setting
; up basic blocks.
;
; RUN: opt < %s -passes="cilksan" -S | FileCheck %s
; RUN: opt < %s -passes="csi" -csi-instrument-basic-blocks=false -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

; Function Attrs: sanitize_cilk
define i64 @_ZN3c106detail19maybe_wrap_dim_slowExxb() #0 personality ptr null {
entry:
  invoke void null(ptr null, ptr null, ptr null)
          to label %unreachable unwind label %lpad2

lpad2:                                            ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  resume { ptr, i32 } zeroinitializer

if.then43:                                        ; No predecessors!
  br label %unreachable

unreachable:                                      ; preds = %if.then43, %entry
  unreachable
}

; CHECK: define i64 @_ZN3c106detail19maybe_wrap_dim_slowExxb()
; CHECK: entry:
; CHECK: invoke void null(ptr null, ptr null, ptr null)
; CHECK-NEXT: to label %[[UNREACHABLE_SPLIT:.+]] unwind label %lpad2

; CHECK: if.then43:
; CHECK: br label %unreachable

; CHECK: [[UNREACHABLE_SPLIT]]:
; CHECK-NEXT: call void @__{{csan|csi}}_after_call(
; CHECK-NEXT: unreachable

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 4, 5, 6, 0 }

attributes #0 = { sanitize_cilk }
