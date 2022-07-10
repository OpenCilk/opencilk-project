; Check that serializing a detach removes the taskframe used by that
; detach.
;
; RUN: opt < %s -passes="function<eager-inv>(simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>)" -S | FileCheck %s

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

define linkonce_odr void @_ZN13ParallelTools23parallel_for_each_spawnIZN4mold3elf15resolve_symbolsINS2_6X86_64EEEvRNS2_7ContextIT_EEEUlPNS2_10ObjectFileIS4_EEE0_St6vectorISB_SaISB_EEEEvRT0_S6_m() {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %if.then

if.then:                                          ; preds = %entry
  br label %pfor.ph

pfor.ph:                                          ; preds = %if.then
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  br label %pfor.detach

pfor.detach:                                      ; preds = %pfor.cond
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

; CHECK: detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.detach
  %syncreg5 = call token @llvm.syncregion.start()
  br label %pfor.body

; CHECK: pfor.body.entry:
; CHECK-NOT: call token @llvm.taskframe.create()
; CHECK-NOT: detach within
; CHECK-NOT: call void @llvm.taskframe.use(
; CHECK: call void @_ZN13ParallelTools23parallel_for_each_spawnIZN4mold3elf15resolve_symbolsINS2_6X86_64EEEvRNS2_7ContextIT_EEEUlPNS2_10ObjectFileIS4_EEE0_St6vectorISB_SaISB_EEEEvRT0_S6_m()
; CHECK-NOT: reattach within
; CHECK-NOT: sync within
; CHECK: reattach within %syncreg, label %pfor.inc

pfor.body:                                        ; preds = %pfor.body.entry
  %0 = call token @llvm.taskframe.create()
  detach within %syncreg5, label %det.achd, label %det.cont

det.achd:                                         ; preds = %pfor.body
  call void @llvm.taskframe.use(token %0)
  call void @_ZN13ParallelTools23parallel_for_each_spawnIZN4mold3elf15resolve_symbolsINS2_6X86_64EEEvRNS2_7ContextIT_EEEUlPNS2_10ObjectFileIS4_EEE0_St6vectorISB_SaISB_EEEEvRT0_S6_m()
  reattach within %syncreg5, label %det.cont

det.cont:                                         ; preds = %det.achd, %pfor.body
  sync within %syncreg5, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %sync.continue
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.detach
  br label %pfor.cond
}

declare i64 @_ZNKSt6vectorIPN4mold3elf10ObjectFileINS1_6X86_64EEESaIS5_EE4sizeEv()

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #2

; uselistorder directives
uselistorder token ()* @llvm.syncregion.start, { 1, 0 }

attributes #0 = { argmemonly nofree nosync nounwind willreturn }
attributes #1 = { argmemonly nofree nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn }
