; Check that jump threading does not thread a detach-continue edge if
; it does not also thread the corresponding reattach-continue edge.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(inline,function<eager-inv>(loop(indvars,loop-unroll-full),gvn<>,instcombine,loop-mssa(licm<allowspeculation>)))),function<eager-inv>(loop-stripmine,jump-threading)" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.anon.1003 = type { ptr, ptr, ptr, ptr }

define linkonce_odr ptr @_ZSt3minImERKT_S2_S2_(ptr %__a, ptr %__b) {
entry:
  %0 = load i64, ptr %__a, align 8
  %cmp.not = icmp eq i64 %0, 0
  %__b.__a = select i1 %cmp.not, ptr %__a, ptr %__b
  ret ptr %__b.__a
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

define linkonce_odr void @_ZN21delta_compressed_leafIjE14parallel_splitILb1ELb0ELb0EZZN4CPMAI10PMA_traitsIS0_L8HeadForm0ELm0ELb0ELb0ELb0ELm4096ELb1E19overwrite_on_insertISt5tupleIJRjEES6_IJjEEEEE9grow_listEmENKUlvE0_clEvEUlmE_10empty_typeSF_EEvmmmPjmT2_T3_T4_m(i64 %num_leaves) personality ptr null {
entry:
  call void @_ZN13ParallelTools12parallel_forIZN21delta_compressed_leafIjE14parallel_splitILb1ELb0ELb0EZZN4CPMAI10PMA_traitsIS2_L8HeadForm0ELm0ELb0ELb0ELb0ELm4096ELb1E19overwrite_on_insertISt5tupleIJRjEES8_IJjEEEEE9grow_listEmENKUlvE0_clEvEUlmE_10empty_typeSH_EEvmmmPjmT2_T3_T4_mEUlmE_EEvmmT_(i64 1, i64 %num_leaves, ptr byval(%class.anon.1003) null)
  ret void
}

define linkonce_odr void @_ZN13ParallelTools12parallel_forIZN21delta_compressed_leafIjE14parallel_splitILb1ELb0ELb0EZZN4CPMAI10PMA_traitsIS2_L8HeadForm0ELm0ELb0ELb0ELb0ELm4096ELb1E19overwrite_on_insertISt5tupleIJRjEES8_IJjEEEEE9grow_listEmENKUlvE0_clEvEUlmE_10empty_typeSH_EEvmmmPjmT2_T3_T4_mEUlmE_EEvmmT_(i64 %start, i64 %end, ptr %f) {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %cmp = icmp ugt i64 %end, %start
  br i1 %cmp, label %pfor.ph, label %common.ret

pfor.ph:                                          ; preds = %entry
  %sub = sub i64 %end, %start
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  %__begin.0 = phi i64 [ 0, %pfor.ph ], [ %inc, %pfor.inc ]
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  call void @_ZZN21delta_compressed_leafIjE14parallel_splitILb1ELb0ELb0EZZN4CPMAI10PMA_traitsIS0_L8HeadForm0ELm0ELb0ELb0ELb0ELm4096ELb1E19overwrite_on_insertISt5tupleIJRjEES6_IJjEEEEE9grow_listEmENKUlvE0_clEvEUlmE_10empty_typeSF_EEvmmmPjmT2_T3_T4_mENKUlmE_clEm(ptr %f, i64 %__begin.0)
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body.entry, %pfor.cond
  %inc = add i64 %__begin.0, 1
  %cmp3 = icmp ult i64 %inc, %sub
  br i1 %cmp3, label %pfor.cond, label %common.ret

common.ret:                                       ; preds = %pfor.inc, %entry
  ret void
}

define linkonce_odr void @_ZZN21delta_compressed_leafIjE14parallel_splitILb1ELb0ELb0EZZN4CPMAI10PMA_traitsIS0_L8HeadForm0ELm0ELb0ELb0ELb0ELm4096ELb1E19overwrite_on_insertISt5tupleIJRjEES6_IJjEEEEE9grow_listEmENKUlvE0_clEvEUlmE_10empty_typeSF_EEvmmmPjmT2_T3_T4_mENKUlmE_clEm(ptr %this, i64 %i) {
entry:
  %i.addr111 = alloca [0 x [0 x [0 x i64]]], i32 0, align 8
  store i64 %i, ptr %i.addr111, align 8
  %0 = load ptr, ptr %this, align 8
  %call = call ptr @_ZSt3minImERKT_S2_S2_(ptr %i.addr111, ptr %0)
  %1 = load i64, ptr %call, align 8
  %add.ptr = getelementptr i8, ptr null, i64 %1
  %add.ptr2 = getelementptr i8, ptr %add.ptr, i64 -1
  store i8 0, ptr null, align 4294967296
  br i1 poison, label %if.then, label %for.cond

if.then:                                          ; preds = %entry
  store i1 false, ptr null, align 4294967296
  store ptr null, ptr null, align 4294967296
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.then, %entry
  %j.0 = phi i8 [ %inc, %for.inc ], [ 0, %if.then ], [ 0, %entry ]
  %cmp6 = icmp ult i8 %j.0, 5
  br i1 %cmp6, label %for.body, label %cleanup

for.body:                                         ; preds = %for.cond
  %conv5 = zext i8 %j.0 to i64
  %arrayidx = getelementptr i8, ptr %add.ptr2, i64 %conv5
  %2 = load i8, ptr %arrayidx, align 1
  %cmp9 = icmp sgt i8 %2, 0
  br i1 %cmp9, label %if.then10, label %for.inc

if.then10:                                        ; preds = %for.body
  br label %cleanup

for.inc:                                          ; preds = %for.body
  %inc = add i8 %j.0, 1
  br label %for.cond

cleanup:                                          ; preds = %if.then10, %for.cond
  ret void
}

; CHECK: define linkonce_odr void @_ZN21delta_compressed_leafIjE14parallel_splitILb1ELb0ELb0EZZN4CPMAI10PMA_traitsIS0_L8HeadForm0ELm0ELb0ELb0ELb0ELm4096ELb1E19overwrite_on_insertISt5tupleIJRjEES6_IJjEEEEE9grow_listEmENKUlvE0_clEvEUlmE_10empty_typeSF_EEvmmmPjmT2_T3_T4_m(

; CHECK: pfor.ph.i.new.strpm.detachloop:
; CHECK-NEXT: detach within %[[SYNCREG_I:.+]], label %[[DETACHED:.+]], label %[[DETACH_CONT:.+]]

; CHECK: pfor.cond.i.strpm.detachloop.reattach.split:
; CHECK-NEXT: reattach within %[[SYNCREG_I]], label %[[DETACH_CONT]]


; uselistorder directives
uselistorder ptr null, { 0, 1, 2, 3, 4, 6, 7, 8, 5 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
