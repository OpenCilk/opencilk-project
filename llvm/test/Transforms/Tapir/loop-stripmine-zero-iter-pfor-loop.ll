; Check that loop-stripmining generates the correct IR to enable a zero-iteration parallel loop to be optimized away.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(inline,function<eager-inv;no-rerun>(loop(indvars),sroa<modify-cfg>))),function<eager-inv>(loop-stripmine,early-cse<memssa>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>),function(simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>)" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.parlay::slice.759" = type { ptr, ptr }

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

define i64 @_ZNK6parlay5sliceIPSt5tupleIJmmEES3_E4sizeEv(ptr %this) {
entry:
  %0 = load ptr, ptr %this, align 8
  %sub.ptr.rhs.cast = ptrtoint ptr %0 to i64
  %sub.ptr.div = ashr i64 %sub.ptr.rhs.cast, 1
  ret i64 %sub.ptr.div
}

define void @_ZN6parlay8internal13bucket_sort_rIPSt5tupleIJmmEES4_N4cpam5buildINS5_14map_full_entryIN17ConcurrentAdaptor10MapAdaptorImmE5entryEEEE4lessMUlS3_S3_E_EEEvNS_5sliceIT_SH_EENSG_IT0_SJ_EET1_bb() personality ptr null {
entry:
  %in1111 = alloca [0 x [0 x [0 x %"struct.parlay::slice.759"]]], i32 0, align 8
  %call1 = call i64 @_ZNK6parlay5sliceIPSt5tupleIJmmEES3_E4sizeEv(ptr %in1111)
  %cmp = icmp ult i64 %call1, 512
  br i1 %cmp, label %if.then, label %common.ret

common.ret:                                       ; preds = %if.then, %entry
  ret void

if.then:                                          ; preds = %entry
  %agg.tmp.sroa.0.0.copyload = load ptr, ptr %in1111, align 8
  call void @_ZN6parlay8internal9base_sortIPSt5tupleIJmmEES4_N4cpam5buildINS5_14map_full_entryIN17ConcurrentAdaptor10MapAdaptorImmE5entryEEEE4lessMUlS3_S3_E_EEEvNS_5sliceIT_SH_EENSG_IT0_SJ_EET1_bb(ptr %agg.tmp.sroa.0.0.copyload)
  br label %common.ret
}

define void @_ZN6parlay8internal9base_sortIPSt5tupleIJmmEES4_N4cpam5buildINS5_14map_full_entryIN17ConcurrentAdaptor10MapAdaptorImmE5entryEEEE4lessMUlS3_S3_E_EEEvNS_5sliceIT_SH_EENSG_IT0_SJ_EET1_bb(ptr %in.coerce0) {
entry:
  store ptr %in.coerce0, ptr %in.coerce0, align 8
  %call91 = call i64 @_ZNK6parlay5sliceIPSt5tupleIJmmEES3_E4sizeEv(ptr %in.coerce0)
  call void @_ZN6parlay24uninitialized_relocate_nIPSt5tupleIJmmEES3_EEvT_T0_m(i64 %call91)
  ret void
}

define void @_ZN6parlay24uninitialized_relocate_nIPSt5tupleIJmmEES3_EEvT_T0_m(i64 %n) {
entry:
  call void @_ZN6parlay26uninitialized_relocate_n_aIPSt5tupleIJmmEES3_SaIS2_EEEvT_T0_mRT1_(i64 %n)
  ret void
}

define void @_ZN6parlay26uninitialized_relocate_n_aIPSt5tupleIJmmEES3_SaIS2_EEEvT_T0_mRT1_(i64 %n) {
entry:
  call void @_ZN6parlay12parallel_forIZNS_26uninitialized_relocate_n_aIPSt5tupleIJmmEES4_SaIS3_EEEvT_T0_mRT1_EUlmE_EEvmmOS6_lb(i64 %n)
  ret void
}

; CHECK: define {{.*}}void @_ZN6parlay8internal13bucket_sort_rIPSt5tupleIJmmEES4_N4cpam5buildINS5_14map_full_entryIN17ConcurrentAdaptor10MapAdaptorImmE5entryEEEE4lessMUlS3_S3_E_EEEvNS_5sliceIT_SH_EENSG_IT0_SJ_EET1_bb
; CHECK: %[[CMP:.+]] = icmp ult i64 %[[SUB_PTR:.+]], 512
; CHECK-NEXT: br i1 %[[CMP]], label %[[IF_THEN:.+]], label %[[RET:.+]]

; CHECK: [[RET]]:
; CHECK-NEXT: ret void

; CHECK: [[IF_THEN]]:
; CHECK: %[[LOOP_GUARD_CMP:.+]] = icmp ult ptr
; CHECK-NEXT: br i1 %[[LOOP_GUARD_CMP]], label %[[RET]], label %[[EPIL:.+]]

; CHECK: [[EPIL]]:
; The parallel loop should have been optimized out.  Only the epilogue should remain.
; CHECK-NOT: detach
; CHECK: store volatile i32 0, ptr null
; CHECK-NEXT: %[[EPIL_SUB:.+]] = add nsw i64
; CHECK-NEXT: %[[EPIL_CMP:.+]] = icmp eq i64 %[[EPIL_SUB]]
; CHECK-NEXT: br i1 %[[EPIL_CMP]], label %[[RET]], label %[[EPIL]]

define void @_ZN6parlay12parallel_forIZNS_26uninitialized_relocate_n_aIPSt5tupleIJmmEES4_SaIS3_EEEvT_T0_mRT1_EUlmE_EEvmmOS6_lb(i64 %end) {
entry:
  %syncreg15 = call token @llvm.syncregion.start()
  %cmp1.not = icmp eq i64 %end, 0
  br i1 %cmp1.not, label %common.ret, label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %entry
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %entry ]
  detach within %syncreg15, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  store volatile i32 0, ptr null, align 4
  reattach within %syncreg15, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body.entry, %pfor.cond
  %inc = add i64 %__begin.0, 1
  %cmp2 = icmp ult i64 %inc, %end
  br i1 %cmp2, label %pfor.cond, label %common.ret

common.ret:                                       ; preds = %pfor.inc, %entry
  ret void
}

; uselistorder directives
uselistorder ptr null, { 0, 2, 3, 1 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
