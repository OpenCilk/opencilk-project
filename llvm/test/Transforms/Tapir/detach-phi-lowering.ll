; Check that PHI nodes in detached blocks are handled properly during
; Tapir lowering.
;
; RUN: opt < %s -tapir2target -tapir-target=opencilk -use-opencilk-runtime-bc=false -S -o - | FileCheck %s
; RUN: opt < %s -passes='tapir2target' -tapir-target=opencilk -use-opencilk-runtime-bc=false -S -o - | FileCheck %s

; ModuleID = 'bugpoint-reduced-simplified.bc'
source_filename = "error.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@__llvm_gcov_ctr.415 = external dso_local global [30 x i64]

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

define dso_local void @_Z23get_edges_from_file_mtxRKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEPmPjb() #1 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %if.end32

if.end32:                                         ; preds = %entry
  br i1 undef, label %if.then37, label %if.end40

if.then37:                                        ; preds = %if.end32
  unreachable

if.end40:                                         ; preds = %if.end32
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %if.end40
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  %0 = phi i64* [ getelementptr inbounds ([30 x i64], [30 x i64]* @__llvm_gcov_ctr.415, i64 0, i64 20), %pfor.cond ]
  unreachable

pfor.inc:                                         ; preds = %pfor.cond
  br label %pfor.cond
}

; CHECK-LABEL: define dso_local void @_Z23get_edges_from_file_mtxRKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEPmPjb()

; CHECK: pfor.cond:
; CHECK: br i1 %{{.+}}, label %[[SPAWN_BLK:.+]], label %pfor.inc

; CHECK: [[SPAWN_BLK]]:
; CHECK: call {{.*}}void @_Z23get_edges_from_file_mtxRKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEPmPjb.outline_pfor.body.entry.otd1(
; CHECK: br label %pfor.inc

; CHECK: pfor.body.entry:
; CHECK-NOT: phi i64*

; CHECK: pfor.inc:

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 11.1.0 (git@github.com:OpenCilk/opencilk-project.git 9af3bad35efe3d0f2b486e471d3791302b7c22cd)"}
