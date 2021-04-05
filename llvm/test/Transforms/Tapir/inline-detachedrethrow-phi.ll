; Check that PHI nodes are properly updated when inlining introduces a
; detached.rethrow instruction.
;
; RUN: opt < %s -inline -S -o - | FileCheck %s
; RUN: opt < %s -passes='inline' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$_ZNSt5dequeI9_pair_elsSaIS0_EEC2Ev = comdat any

$_ZNSt11_Deque_baseI9_pair_elsSaIS0_EEC2Ev = comdat any

@__llvm_gcov_ctr.566 = external dso_local global [109 x i64]

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #1

define dso_local void @_ZN13SparseMatrixV12insert_batchEP9_pair_elsm() #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg86 = call token @llvm.syncregion.start()
  detach within %syncreg86, label %pfor.body.entry, label %pfor.inc unwind label %lpad75

pfor.body.entry:                                  ; preds = %entry
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  call void @_ZNSt5dequeI9_pair_elsSaIS0_EEC2Ev()
  invoke void @_ZNK14TinySetV_small17prefetch_pma_dataEv()
          to label %invoke.cont43 unwind label %lpad42

invoke.cont43:                                    ; preds = %pfor.body
  unreachable

lpad42:                                           ; preds = %pfor.body
  %0 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg86, { i8*, i32 } %0)
          to label %unreachable unwind label %lpad75

pfor.inc:                                         ; preds = %entry
  unreachable

lpad75:                                           ; preds = %lpad42, %entry
  %1 = phi i64* [ getelementptr inbounds ([109 x i64], [109 x i64]* @__llvm_gcov_ctr.566, i64 0, i64 8), %entry ], [ getelementptr inbounds ([109 x i64], [109 x i64]* @__llvm_gcov_ctr.566, i64 0, i64 51), %lpad42 ]
  %2 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } %2

unreachable:                                      ; preds = %lpad42
  unreachable
}

; CHECK-LABEL: define dso_local void @_ZN13SparseMatrixV12insert_batchEP9_pair_elsm()

; CHECK: pfor.body:
; CHECK-NOT: call void @_ZNSt5dequeI9_pair_elsSaIS0_EEC2Ev()
; CHECK: invoke void @_ZNSt11_Deque_baseI9_pair_elsSaIS0_EE17_M_initialize_mapEm()
; CHECK-NEXT: to label %{{.+}} unwind label %[[LPAD_I:.+]]

; CHECK: [[LPAD_I]]:
; CHECK: %[[LPAD_I_VAL:.+]] = landingpad { i8*, i32 }
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg86, { i8*, i32 } %[[LPAD_I_VAL]])
; CHECK-NEXT: to label %{{.+}} unwind label %lpad75

; CHECK: lpad75:
; CHECK-NEXT: phi i64*
; CHECK-DAG: [ getelementptr inbounds ([109 x i64], [109 x i64]* @__llvm_gcov_ctr.566, i64 0, i64 8), %entry ]
; CHECK-DAG: [ getelementptr inbounds ([109 x i64], [109 x i64]* @__llvm_gcov_ctr.566, i64 0, i64 8), %[[LPAD_I]] ]
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: resume

define dso_local void @_ZNSt5dequeI9_pair_elsSaIS0_EEC2Ev() unnamed_addr #3 comdat align 2 {
entry:
  call void @_ZNSt11_Deque_baseI9_pair_elsSaIS0_EEC2Ev()
  ret void
}

declare dso_local void @_ZNK14TinySetV_small17prefetch_pma_dataEv() #3 align 2

define dso_local void @_ZNSt11_Deque_baseI9_pair_elsSaIS0_EEC2Ev() unnamed_addr #3 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_ZNSt11_Deque_baseI9_pair_elsSaIS0_EE17_M_initialize_mapEm()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  ret void

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } %0
}

declare dso_local void @_ZNSt11_Deque_baseI9_pair_elsSaIS0_EE17_M_initialize_mapEm() #3 align 2

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { argmemonly willreturn }
attributes #2 = { "target-cpu"="x86-64" }
attributes #3 = { "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 11.1.0 (git@github.com:OpenCilk/opencilk-project.git 9af3bad35efe3d0f2b486e471d3791302b7c22cd)"}
