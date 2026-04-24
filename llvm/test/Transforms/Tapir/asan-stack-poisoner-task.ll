; Check that ASan's function stack poisoner handles allocas in tasks correctly.
;
; RUN: opt < %s -passes="asan<use-after-scope>" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::complex" = type { { float, float } }

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #1

; Function Attrs: sanitize_address
define void @_Z4gemvIfQsr3stdE14floating_pointIT_EEvmmPKSt7complexIS0_ES4_PS2_S2_S2_() #2 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %entry
  detach within %syncreg, label %pfor.body.entry49, label %pfor.inc114

pfor.body.entry49:                                ; preds = %sync.continue
  %sum = alloca %"class.std::complex", align 8
  %syncreg52 = call token @llvm.syncregion.start()
  call void @llvm.lifetime.start.p0(i64 0, ptr %sum)
  br label %pfor.cond62

; CHECK: pfor.body.entry49:
; CHECK-NEXT: %[[ASAN_LOCAL_STACK_BASE:.+]] = alloca i64
; CHECK-NEXT: load i32, ptr @__asan_option_detect_stack_use_after_return
; CHECK: call i64 @__asan_stack_malloc_0(i64 64)
; CHECK: %[[MYALLOC:.+]] = alloca i8, i64 64
; CHECK: %[[ALLOCA_PHI:.+]] = phi i64
; CHECK: store i64 %[[ALLOCA_PHI]], ptr %[[ASAN_LOCAL_STACK_BASE]]
; CHECK: %[[SUM_SLOT:.+]] = add i64 %[[ALLOCA_PHI]], 32
; CHECK: %[[SUM_SLOT_PTR:.+]] = inttoptr i64 %[[SUM_SLOT]] to ptr
; CHECK: add i64 %[[ALLOCA_PHI]], 8
; CHECK: add i64 %[[ALLOCA_PHI]], 16

pfor.cond62:                                      ; preds = %pfor.body.entry65, %pfor.cond62, %pfor.body.entry49
  detach within %syncreg52, label %pfor.body.entry65, label %pfor.cond62

pfor.body.entry65:                                ; preds = %pfor.cond62
  %0 = load <2 x float>, ptr %sum, align 8
  store <2 x float> zeroinitializer, ptr %sum, align 8
  reattach within %syncreg52, label %pfor.cond62

; CHECK: pfor.body.entry65:
; CHECK: %[[SUM_SLOT_INT:.+]] = ptrtoint ptr %[[SUM_SLOT_PTR]] to i64
; CHECK: call void @__asan_report_load8(i64 %[[SUM_SLOT_INT]])
; CHECK: load <2 x float>, ptr %[[SUM_SLOT_PTR]]
; CHECK-NEXT: store <2 x float> zeroinitializer, ptr %[[SUM_SLOT_PTR]]
; CHECK-NEXT: reattach within %syncreg52, label %pfor.cond62

pfor.inc114:                                      ; preds = %sync.continue
  ret void
}

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { sanitize_address }
