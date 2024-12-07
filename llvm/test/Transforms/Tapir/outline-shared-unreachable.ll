; Check that Tapir lowering handles branches to unreachable blocks
; when those blocks are shared with the parent spawner.
;
; RUN: opt < %s -passes="tapir2target" -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start()

define void @_ZN9LAMMPS_NS6Verlet14run_stencil_mdEiRNSt3__13mapIiNS1_6vectorIiNS1_9allocatorIiEEEENS1_4lessIiEENS4_INS1_4pairIKiS6_EEEEEESE_RNS2_IiiS8_NS4_INS9_ISA_iEEEEEESI_PPdSK_() personality ptr null {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br i1 false, label %entry.unreachable_crit_edge, label %pfor.detach

entry.unreachable_crit_edge:                      ; preds = %entry
  br label %unreachable

pfor.detach:                                      ; preds = %pfor.detach, %entry
  detach within %syncreg, label %pfor.body, label %pfor.detach unwind label %lpad714.loopexit

pfor.body:                                        ; preds = %pfor.detach
  br label %unreachable

lpad714.loopexit:                                 ; preds = %pfor.detach
  %lpad.loopexit = landingpad { ptr, i32 }
          cleanup
  ret void

unreachable:                                      ; preds = %entry.unreachable_crit_edge, %pfor.body
  unreachable

; uselistorder directives
  uselistorder label %unreachable, { 1, 0 }
}

; CHECK: define void @_ZN9LAMMPS_NS6Verlet14run_stencil_mdEiRNSt3__13mapIiNS1_6vectorIiNS1_9allocatorIiEEEENS1_4lessIiEENS4_INS1_4pairIKiS6_EEEEEESE_RNS2_IiiS8_NS4_INS9_ISA_iEEEEEESI_PPdSK_()
; CHECK: pfor.detach:
; CHECK: invoke fastcc void @_ZN9LAMMPS_NS6Verlet14run_stencil_mdEiRNSt3__13mapIiNS1_6vectorIiNS1_9allocatorIiEEEENS1_4lessIiEENS4_INS1_4pairIKiS6_EEEEEESE_RNS2_IiiS8_NS4_INS9_ISA_iEEEEEESI_PPdSK_.outline_pfor.body.otd1(ptr {{.*}}%{{.+}})
; CHECK: to label %pfor.detach unwind label %lpad714.loopexit

; CHECK: define internal fastcc void @_ZN9LAMMPS_NS6Verlet14run_stencil_mdEiRNSt3__13mapIiNS1_6vectorIiNS1_9allocatorIiEEEENS1_4lessIiEENS4_INS1_4pairIKiS6_EEEEEESE_RNS2_IiiS8_NS4_INS9_ISA_iEEEEEESI_PPdSK_.outline_pfor.body.otd1(ptr {{.*}}%{{.+}})
; CHECK: pfor.detach.otd1:
; CHECK: br label %pfor.body.otd1

; CHECK: pfor.body.otd1:
; CHECK-NEXT: br label %unreachable.otd1

; CHECK: unreachable.otd1:
; CHECK-NEXT: unreachable

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }
