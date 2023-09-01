; Check that Cilksan properly splits predecessors of ordinary basic
; blocks terminated by different types if instrumented operations.
;
; RUN: opt < %s -passes="cilksan" -S | FileCheck %s
; RUN: opt < %s -passes="csi-setup,csi" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

; Function Attrs: sanitize_cilk
define ptr @_ZN6google8protobuf8compiler6Parser18ParseReservedNamesEPNS0_15DescriptorProtoERKNS2_16LocationRecorderE() #0 personality ptr null {
entry:
  br i1 true, label %if.then.i.i.i.i.i.i.i.i.i.i.i, label %if.else.i.i.i.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i.i.i.i:
  %call.i.i.i.i.i.i.i.i.i.i.i18 = invoke noalias noundef nonnull dereferenceable(24) ptr @_Znwm(i64 noundef 24) #19
          to label %_ZN6google8protobuf8internal17StringTypeHandler16NewFromPrototypeEPKNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEPNS0_5ArenaE.exit.i.i.i.i unwind label %lpad

if.else.i.i.i.i.i.i.i.i.i.i.i:
  %call3.i.i.i.i.i.i.i.i.i.i.i.i.i20 = invoke ptr null(ptr null, i64 0, ptr null)
          to label %_ZN6google8protobuf8internal17StringTypeHandler16NewFromPrototypeEPKNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEPNS0_5ArenaE.exit.i.i.i.i unwind label %lpad

_ZN6google8protobuf8internal17StringTypeHandler16NewFromPrototypeEPKNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEPNS0_5ArenaE.exit.i.i.i.i: ; preds = %if.else.i.i.i.i.i.i.i.i.i.i.i, %if.then.i.i.i.i.i.i.i.i.i.i.i
  %retval = phi ptr [ %call.i.i.i.i.i.i.i.i.i.i.i18, %if.then.i.i.i.i.i.i.i.i.i.i.i], [ null, %if.else.i.i.i.i.i.i.i.i.i.i.i ]
  ret ptr %retval

lpad:                                             ; preds = %if.else.i.i.i.i.i.i.i.i.i.i.i, %new
  %0 = landingpad { ptr, i32 }
          cleanup
  resume { ptr, i32 } zeroinitializer
}

; CHECK: if.then.i.i.i.i.i.i.i.i.i.i.i:
; CHECK: invoke noalias {{.*}}ptr @_Znwm(i64 noundef 24)
; CHECK-NEXT: to label %[[SPLIT_ALLOCFN_PRED:.+]] unwind label %[[SPLIT_ALLOCFN_LPAD_PRED:.+]]

; CHECK: if.else.i.i.i.i.i.i.i.i.i.i.i:
; CHECK: invoke ptr null(ptr null, i64 0, ptr null)
; CHECK-NEXT: to label %[[SPLIT_INVOKE_PRED:.+]] unwind label %[[SPLIT_INVOKE_LPAD_PRED:.+]]

; CHECK: [[SPLIT_ALLOCFN_PRED]]:
; CHECK-NEXT: call void @__{{csan|csi}}_after_allocfn(
; CHECK: br label %_ZN6google8protobuf8internal17StringTypeHandler16NewFromPrototypeEPKNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEPNS0_5ArenaE.exit.i.i.i.i

; CHECK: [[SPLIT_INVOKE_PRED]]:
; CHECK-NEXT: call void @__{{csan|csi}}_after_call(
; CHECK: br label %_ZN6google8protobuf8internal17StringTypeHandler16NewFromPrototypeEPKNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEPNS0_5ArenaE.exit.i.i.i.i

; CHECK: _ZN6google8protobuf8internal17StringTypeHandler16NewFromPrototypeEPKNSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEPNS0_5ArenaE.exit.i.i.i.i:
; CHECK-NEXT: %retval = phi ptr
; CHECK-NOT: phi i64
; CHECK-NOT: call void @__{{csan|csi}}_after_call(
; CHECK: call void @__{{csan|csi}}_func_exit(
; CHECK: ret ptr %retval

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #19

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 4, 5, 6, 0 }

attributes #0 = { sanitize_cilk }
attributes #19 = { nobuiltin allocsize(0) }
