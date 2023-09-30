; Check that inlining a simple detach with no unwind into a taskframe with
; an unwind destimation works as intended.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(inline,function<eager-inv>(sroa<modify-cfg>)))" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

define linkonce_odr void @_ZN4gbbs2bc26SSBetweennessCentrality_EMINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIdSaIdELb0EEERT_RKj() personality ptr null {
entry:
  call void @_ZN4gbbs9vertexMapINS_16vertexSubsetDataINS_5emptyEEENS_2bc37SSBetweennessCentrality_Back_Vertex_FIN6parlay8sequenceIbSaIbELb0EEENS7_IdSaIdELb0EEEEELi0EEEvRT_T0_m(ptr null, ptr null, i64 0)
  br label %for.cond86

for.cond86:                                       ; preds = %for.cond86, %entry
  invoke void @_ZN4gbbs9vertexMapINS_16vertexSubsetDataINS_5emptyEEENS_2bc37SSBetweennessCentrality_Back_Vertex_FIN6parlay8sequenceIbSaIbELb0EEENS7_IdSaIdELb0EEEEELi0EEEvRT_T0_m(ptr null, ptr null, i64 1)
          to label %for.cond86 unwind label %lpad90

; CHECK: for.cond86:
; CHECK: br label %for.cond86.tf

; CHECK: for.cond86.tf:
; CHECK-NEXT: %[[TF_I:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: %syncreg19.i = call token @llvm.syncregion.start()
; CHECK: br i1 {{.+}}, label %[[IF_THEN_I:.+]], label %[[IF_ELSE_I:.+]]

; CHECK: [[IF_ELSE_I]]:
; CHECK-NEXT: detach within %syncreg19.i, label %det.achd.i, label
; CHECK-NOT: unwind label

; CHECK: det.achd.i:
; CHECK-NEXT: reattach within %syncreg19.i, label

lpad90:                                           ; preds = %for.cond86
  %0 = landingpad { ptr, i32 }
          cleanup
  ret void
}

define linkonce_odr void @_ZN4gbbs9vertexMapINS_16vertexSubsetDataINS_5emptyEEENS_2bc37SSBetweennessCentrality_Back_Vertex_FIN6parlay8sequenceIbSaIbELb0EEENS7_IdSaIdELb0EEEEELi0EEEvRT_T0_m(ptr %V, ptr %f, i64 %granularity) {
entry:
  br i1 poison, label %if.then, label %if.else

common.ret:                                       ; preds = %if.else, %if.then
  ret void

if.then:                                          ; preds = %entry
  call void @_ZN6parlay12parallel_forIZN4gbbs9vertexMapINS1_16vertexSubsetDataINS1_5emptyEEENS1_2bc37SSBetweennessCentrality_Back_Vertex_FINS_8sequenceIbSaIbELb0EEENS8_IdSaIdELb0EEEEELi0EEEvRT_T0_mEUlmE_EEvmmOSE_lb()
  br label %common.ret

if.else:                                          ; preds = %entry
  call void @_ZN6parlay12parallel_forIZN4gbbs9vertexMapINS1_16vertexSubsetDataINS1_5emptyEEENS1_2bc37SSBetweennessCentrality_Back_Vertex_FINS_8sequenceIbSaIbELb0EEENS8_IdSaIdELb0EEEEELi0EEEvRT_T0_mEUlmE0_EEvmmOSE_lb(i64 %granularity)
  br label %common.ret
}

define linkonce_odr void @_ZN6parlay12parallel_forIZN4gbbs9vertexMapINS1_16vertexSubsetDataINS1_5emptyEEENS1_2bc37SSBetweennessCentrality_Back_Vertex_FINS_8sequenceIbSaIbELb0EEENS8_IdSaIdELb0EEEEELi0EEEvRT_T0_mEUlmE_EEvmmOSE_lb() {
entry:
  detach within none, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %entry
  reattach within none, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body.entry, %entry
  ret void
}

define linkonce_odr void @_ZN6parlay12parallel_forIZN4gbbs9vertexMapINS1_16vertexSubsetDataINS1_5emptyEEENS1_2bc37SSBetweennessCentrality_Back_Vertex_FINS_8sequenceIbSaIbELb0EEENS8_IdSaIdELb0EEEEELi0EEEvRT_T0_mEUlmE0_EEvmmOSE_lb(i64 %granularity) {
entry:
  %syncreg19 = call token @llvm.syncregion.start()
  %cmp = icmp eq i64 %granularity, 0
  br i1 %cmp, label %pfor.cond, label %if.else

pfor.cond:                                        ; preds = %pfor.body.entry, %pfor.cond, %entry
  detach within none, label %pfor.body.entry, label %pfor.cond

pfor.body.entry:                                  ; preds = %pfor.cond
  call void @_ZZN4gbbs9vertexMapINS_16vertexSubsetDataINS_5emptyEEENS_2bc37SSBetweennessCentrality_Back_Vertex_FIN6parlay8sequenceIbSaIbELb0EEENS7_IdSaIdELb0EEEEELi0EEEvRT_T0_mENKUlmE0_clEm()
  reattach within none, label %pfor.cond

if.else:                                          ; preds = %entry
  detach within %syncreg19, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.else
  reattach within %syncreg19, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.else
  ret void
}

define linkonce_odr void @_ZZN4gbbs9vertexMapINS_16vertexSubsetDataINS_5emptyEEENS_2bc37SSBetweennessCentrality_Back_Vertex_FIN6parlay8sequenceIbSaIbELb0EEENS7_IdSaIdELb0EEEEELi0EEEvRT_T0_mENKUlmE0_clEm() {
entry:
  %ref.tmp = alloca i32, i32 0, align 4
  %call = call ptr null(ptr null, ptr %ref.tmp)
  ret void
}

; uselistorder directives
uselistorder ptr null, { 0, 1, 3, 4, 5, 6, 7, 8, 2 }
uselistorder ptr @_ZN4gbbs9vertexMapINS_16vertexSubsetDataINS_5emptyEEENS_2bc37SSBetweennessCentrality_Back_Vertex_FIN6parlay8sequenceIbSaIbELb0EEENS7_IdSaIdELb0EEEEELi0EEEvRT_T0_m, { 1, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
