; Check that LoopInstSimplify handles task-exit blocks properly.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(inline,function<eager-inv;no-rerun>(sroa<modify-cfg>,loop-mssa(loop-instsimplify,loop-simplifycfg,loop-rotate<header-duplication;no-prepare-for-lto>,licm<allowspeculation>,simple-loop-unswitch<nontrivial;trivial>),loop(indvars))))" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.absl::container_internal::btree_iterator" = type <{ ptr, i32, [4 x i8] }>

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

define { ptr, i32 } @_ZN18graph_StdContainerI31asymmetricNeighborsAbslBtreeSetEC2EjmPjPlb() personality ptr null {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %pfor.cond84

pfor.cond84:                                      ; preds = %for.cond.cleanup, %pfor.cond84, %entry
  detach within %syncreg, label %pfor.body.entry87, label %pfor.cond84 unwind label %lpad139

pfor.body.entry87:                                ; preds = %pfor.cond84
  %__end0 = alloca %"class.absl::container_internal::btree_iterator", align 8
  %call104.fca.0.extract = extractvalue { ptr, i32 } zeroinitializer, 0
  store ptr %call104.fca.0.extract, ptr %__end0, align 8
  br label %for.cond

; CHECK: pfor.body.entry87:
; CHECK: switch i32 0, label %[[PFOR_BODY_ENTRY87_SPLIT:.+]] [

; CHECK: [[PFOR_BODY_ENTRY87_SPLIT]]:
; CHECK-NOT: phi
; CHECK-NEXT: store ptr null, ptr null
; CHECK-NEXT: br label %for.cond

for.cond:                                         ; preds = %for.cond, %pfor.body.entry87
  %call107 = call i1 @_ZNK4absl18container_internal14btree_iteratorINS0_10btree_nodeINS0_10set_paramsIjSt4lessIjESaIjELi256ELb0EEEEERKjPS9_EneERKSC_(ptr %__end0)
  br i1 true, label %for.cond, label %for.cond.cleanup

; CHECK: for.cond:
; CHECK-NEXT: br label %for.cond

for.cond.cleanup:                                 ; preds = %for.cond
  reattach within %syncreg, label %pfor.cond84

lpad139:                                          ; preds = %pfor.cond84
  %0 = landingpad { ptr, i32 }
          cleanup
  ret { ptr, i32 } %0
}

define i1 @_ZNK4absl18container_internal14btree_iteratorINS0_10btree_nodeINS0_10set_paramsIjSt4lessIjESaIjELi256ELb0EEEEERKjPS9_EneERKSC_(ptr %other) {
entry:
  %agg.tmp2.sroa.0.0.copyload = load ptr, ptr %other, align 8
  store ptr %agg.tmp2.sroa.0.0.copyload, ptr null, align 8
  ret i1 false
}

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
