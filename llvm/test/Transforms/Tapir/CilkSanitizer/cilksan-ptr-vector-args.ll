; Check how Cilksan handles pointer-vector types.
;
; RUN: opt < %s -passes="cilksan" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: sanitize_cilk
define i1 @_ZNSt8__detail17__regex_algo_implIN9__gnu_cxx17__normal_iteratorIPKcNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEEESaINS5_9sub_matchISB_EEEcNS5_12regex_traitsIcEEEEbT_SH_RNS5_13match_resultsISH_T0_EERKNS5_11basic_regexIT1_T2_EENSt15regex_constants15match_flag_typeENS_20_RegexExecutorPolicyEb() #0 {
entry:
; CHECK-LABEL: define i1 @_ZNSt8__detail17__regex_algo_implIN9__gnu_cxx17__normal_iteratorIPKcNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEEESaINS5_9sub_matchISB_EEEcNS5_12regex_traitsIcEEEEbT_SH_RNS5_13match_resultsISH_T0_EERKNS5_11basic_regexIT1_T2_EENSt15regex_constants15match_flag_typeENS_20_RegexExecutorPolicyEb
  call void @llvm.masked.scatter.v8p0.v8p0(<8 x ptr> zeroinitializer, <8 x ptr> zeroinitializer, i32 0, <8 x i1> zeroinitializer)

; Currently, Cilksan does not check aliasing through pointer-vector arguments, but it does save vector arguments onto the stack for the instrumentation hook.
; CHECK: call void @llvm.masked.scatter.v8p0.v8p0
; CHECK-NEXT: %[[STACKSAVE:.+]] = call ptr @llvm.stacksave.p0()
; CHECK-NEXT: %[[ALLOCA1:.+]] = alloca <8 x ptr>
; CHECK-NEXT: store <8 x ptr> zeroinitializer, ptr %[[ALLOCA1]]
; CHECK-NEXT: %[[ALLOCA2:.+]] = alloca <8 x ptr>
; CHECK-NEXT: store <8 x ptr> zeroinitializer, ptr %[[ALLOCA2]]
; CHECK-NEXT: %[[ALLOCA3:.+]] = alloca <8 x i1>
; CHECK-NEXT: store <8 x i1> zeroinitializer, ptr %[[ALLOCA3]]
; CHECK-NEXT: call void @__csan_llvm_masked_scatter_v8p0_v8p0
; CHECK: ptr %[[ALLOCA1]],
; CHECK: ptr %[[ALLOCA2]],
; CHECK: i32 0,
; CHECK: ptr %[[ALLOCA3]]
; CHECK-NEXT: call void @llvm.stackrestore.p0(ptr %[[STACKSAVE]])
  ret i1 false
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(write)
declare void @llvm.masked.scatter.v8p0.v8p0(<8 x ptr>, <8 x ptr>, i32 immarg, <8 x i1>) #1

attributes #0 = { sanitize_cilk }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(write) }
