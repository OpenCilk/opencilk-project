; Check that sets of basic blocks from shared terminate landingpads are outlined properly.
;
; RUN: opt < %s -passes="function(loop(loop-deletion)),tapir2target" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-freebsd14.2"

define i32 @BZ2_compressDescriptorCilk() personality ptr null {
entry:
  %syncreg = call token @llvm.syncregion.start()
  invoke void @_ZN16opencilk_reducerI6writerEC2IJP7__sFILEEEEDpT_(ptr null, ptr null)
          to label %while.cond unwind label %terminate.lpad

while.cond:                                       ; preds = %invoke.cont54, %invoke.cont19, %entry
  %call20 = invoke ptr @_ZL22BZ2_bzCompressInitCilkiii(i32 0, i32 0, i32 0)
          to label %invoke.cont19 unwind label %terminate.lpad

invoke.cont19:                                    ; preds = %while.cond
  detach within %syncreg, label %det.achd, label %while.cond

det.achd:                                         ; preds = %invoke.cont19
  %call55 = invoke i32 @_Z21BZ2_compressBlockCilkP6EStateR16opencilk_reducerI6writerEPKhS6_(ptr null, ptr null, ptr null, ptr null)
          to label %invoke.cont54 unwind label %terminate.lpad

invoke.cont54:                                    ; preds = %det.achd
  reattach within %syncreg, label %while.cond

terminate.lpad:                                   ; preds = %det.achd, %while.cond, %entry
  %0 = landingpad { ptr, i32 }
          catch ptr null
  %1 = extractvalue { ptr, i32 } %0, 0
  store volatile i32 0, ptr %1, align 4
  unreachable
}

; CHECK-LABEL: define {{.*}}void @BZ2_compressDescriptorCilk.outline_det.achd.otd1(

; CHECK: invoke i32 @_Z21BZ2_compressBlockCilkP6EStateR16opencilk_reducerI6writerEPKhS6_(
; CHECK-NEXT: to label %[[INVOKE_CONT:.+]] unwind label %[[TERMINATE_LPAD_LOOPEXIT:.+]]

; CHECK: [[INVOKE_CONT]]:
; CHECK-NEXT: br label %[[WHILE_COND:.+]]

; CHECK: [[TERMINATE_LPAD_LOOPEXIT]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: catch ptr null
; CHECK-NEXT: br label %[[TERMINATE_LPAD:.+]]

; CHECK: [[TERMINATE_LPAD]]:
; CHECK-NEXT: phi
; CHECK-NEXT: extractvalue
; CHECK-NEXT: store volatile
; CHECK-NEXT: unreachable

; CHECK: [[WHILE_COND]]:
; CHECK-NEXT: call void @__cilk_helper_epilogue(
; CHECK-NEXT: ret void

declare void @_ZN16opencilk_reducerI6writerEC2IJP7__sFILEEEEDpT_()

declare ptr @_ZL22BZ2_bzCompressInitCilkiii()

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

declare i32 @_Z21BZ2_compressBlockCilkP6EStateR16opencilk_reducerI6writerEPKhS6_()

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }