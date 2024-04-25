; Check that unlinking a task from its unwind destination handles
; unreachable blocks correctly.
;
; RUN: opt < %s -passes="tapir2target" -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

define void @_ZN9LAMMPS_NS6Verlet14run_stencil_mdEiPNSt3__16vectorIiNS1_9allocatorIiEEEES6_PiS7_PPdS9_() personality ptr null {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg359 = call token @llvm.syncregion.start()
  %syncreg461 = call token @llvm.syncregion.start()
  %syncreg783 = call token @llvm.syncregion.start()
  %syncreg1089 = call token @llvm.syncregion.start()
  br label %pfor.detach470

for.body87:                                       ; No predecessors!
  %call116 = invoke i64 null(ptr null, ptr null)
          to label %invoke.cont115 unwind label %lpad651

invoke.cont115:                                   ; preds = %for.body87
  store i64 %call116, ptr null, align 8
  br label %for.cond131

for.cond131:                                      ; preds = %for.cond131, %invoke.cont115
  br label %for.cond131

pfor.body.entry:                                  ; preds = %pfor.inc273
  %syncreg223 = call token @llvm.syncregion.start()
  reattach within %syncreg, label %pfor.inc273

pfor.inc273:                                      ; preds = %pfor.inc273, %pfor.body.entry
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc273 unwind label %lpad651

pfor.detach470:                                   ; preds = %pfor.detach470, %entry
  detach within none, label %pfor.body.entry472, label %pfor.detach470 unwind label %lpad651

pfor.body.entry472:                               ; preds = %pfor.detach470
  %syncreg481 = call token @llvm.syncregion.start()
  br label %pfor.detach490

pfor.detach490:                                   ; preds = %pfor.detach490, %pfor.body.entry472
  br label %pfor.detach490

lpad651:                                          ; preds = %pfor.inc907, %pfor.detach470, %pfor.inc273, %for.body87
  %0 = landingpad { ptr, i32 }
          cleanup
  resume { ptr, i32 } zeroinitializer

pfor.body.entry799:                               ; preds = %pfor.inc907
  %syncreg843 = call token @llvm.syncregion.start()
  reattach within none, label %pfor.inc907

pfor.inc907:                                      ; preds = %pfor.inc907, %pfor.body.entry799
  detach within none, label %pfor.body.entry799, label %pfor.inc907 unwind label %lpad651
}

; CHECK: define void @_ZN9LAMMPS_NS6Verlet14run_stencil_mdEiPNSt3__16vectorIiNS1_9allocatorIiEEEES6_PiS7_PPdS9_()

; Outlining the task detached at pfor.detach470 should not delete for.body87 and leave the use of %call116 in invoke.cont115 without its definition.

; CHECK: for.body87:
; CHECK-NEXT: %call116 = invoke i64 null(ptr null, ptr null)
; CHECK-NEXT: to label %invoke.cont115 unwind label %lpad651

; CHECK: invoke.cont115:
; CHECK-NEXT: store i64 %call116, ptr null, align 8

; CHECK: pfor.detach470:
; CHECK-NOT: detach within
; CHECK: invoke fastcc void @_ZN9LAMMPS_NS6Verlet14run_stencil_mdEiPNSt3__16vectorIiNS1_9allocatorIiEEEES6_PiS7_PPdS9_.outline_pfor.body.entry472.otd1()
; CHECK-NEXT: to label %pfor.detach470 unwind label %lpad651

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 4, 5, 6, 0 }
uselistorder ptr @llvm.syncregion.start, { 7, 6, 5, 4, 3, 2, 1, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
