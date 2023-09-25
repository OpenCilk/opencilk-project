; Check that the Cilksan and Tapir lowering keep allocas at the start
; of the function together and before a potential stack switch, so
; that ASan does not attempt to unpoison allocas that end up on
; different stacks.
;
; RUN: opt < %s -passes="cilksan" -S | FileCheck %s --check-prefixes=CHECK,CHECK-CSAN
; RUN: opt < %s -passes="cilksan,tapir-lowering<O0>" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s --check-prefixes=CHECK,CHECK-CSAN,CHECK-TAPIR
; RUN: opt < %s -passes="cilksan,tapir-lowering<O0>,asan" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s --check-prefixes=CHECK,CHECK-ASAN
; RUN: opt < %s -passes="csi-setup,csi" -S | FileCheck %s --check-prefixes=CHECK,CHECK-CSI
; RUN: opt < %s -passes="csi-setup,csi,tapir-lowering<O0>" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s --check-prefixes=CHECK,CHECK-CSI,CHECK-TAPIR
; RUN: opt < %s -passes="csi-setup,csi,tapir-lowering<O0>,asan" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s --check-prefixes=CHECK-CSI-ASAN
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"done\0A\00", align 1

; Function Attrs: mustprogress noinline norecurse optnone sanitize_address sanitize_cilk uwtable
define dso_local noundef i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %x = alloca [10 x i32], align 16
  %syncreg = call token @llvm.syncregion.start()
  %__init = alloca i32, align 4
  %__limit = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %__begin = alloca i32, align 4
  %__end = alloca i32, align 4
  %syncreg6 = call token @llvm.syncregion.start()
  store i32 0, ptr %retval, align 4
  call void @llvm.lifetime.start.p0(i64 40, ptr %x) #6
  call void @llvm.memset.p0.i64(ptr align 16 %x, i8 0, i64 40, i1 false)
  call void @llvm.lifetime.start.p0(i64 4, ptr %__init) #6
  store i32 0, ptr %__init, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr %__limit) #6
  store i32 0, ptr %__limit, align 4
  %0 = load i32, ptr %__init, align 4
  %1 = load i32, ptr %__limit, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %pfor.ph, label %pfor.initcond.cleanup

; CHECK: entry:
; CHECK-NEXT: %retval = alloca
; CHECK-CSAN-NEXT: %x = alloca
; CHECK-CSAN-NEXT: %syncreg = call token @llvm.syncregion.start()
; CHECK-CSI-NEXT: %x = alloca
; CHECK-CSI-NEXT: %syncreg = call token @llvm.syncregion.start()
; CHECK-NEXT: %__init = alloca
; CHECK-NEXT: %__limit = alloca
; CHECK-NEXT: %cleanup.dest.slot = alloca
; CHECK-NEXT: %__begin = alloca
; CHECK-NEXT: %__end = alloca
; CHECK-ASAN-NEXT: %asan_local_stack_base = alloca

; CHECK-ASAN: %MyAlloca = alloca

; CHECK-CSAN-NEXT: %syncreg6 = call token @llvm.syncregion.start()
; CHECK-CSI-NEXT: %syncreg6 = call token @llvm.syncregion.start()
; CHECK-TAPIR-NEXT: %__cilkrts_sf = alloca
; CHECK-TAPIR-NEXT: call void @__cilkrts_enter_frame(
; CHECK-ASAN: call void @__cilkrts_enter_frame(
; CHECK: call void @__{{csan|csi}}_func_entry(
; CHECK-CSI: call void @__csi_bb_entry(
; CHECK: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_before_store(
; CHECK: store i32 0, ptr %retval
; CHECK-CSI: call void @__csi_after_store(
; CHECK-CSI: call void @__csi_bb_exit(
; CHECK-CSAN: br i1 %cmp, label %pfor.ph, label %pfor.initcond.cleanup

; CHECK-CSI-ASAN: entry:
; CHECK-CSI-ASAN-NEXT: %asan_local_stack_base = alloca

; CHECK-CSI-ASAN: %MyAlloca = alloca

; CHECK-CSI-ASAN: call void @__cilkrts_enter_frame(
; CHECK-CSI-ASAN: call void @__csi_func_entry(
; CHECK-CSI-ASAN: call void @__csi_bb_entry(
; CHECK-CSI-ASAN: call void @__csi_after_alloca(
; CHECK-CSI-ASAN: call void @__csi_after_alloca(
; CHECK-CSI-ASAN: call void @__csi_after_alloca(
; CHECK-CSI-ASAN: call void @__csi_after_alloca(
; CHECK-CSI-ASAN: call void @__csi_after_alloca(
; CHECK-CSI-ASAN: call void @__csi_after_alloca(
; CHECK-CSI-ASAN: call void @__csi_before_store(
; CHECK-CSI-ASAN: store i32 0, ptr
; CHECK-CSI-ASAN: call void @__csi_after_store(
; CHECK-CSI-ASAN: call void @__csi_bb_exit(

; CHECK-NOT: call void @__asan_allocas_unpoison(
; CHECK-ASAN-CSI-NOT: call void @__asan_allocas_unpoison(

pfor.initcond.cleanup:                            ; preds = %entry
  store i32 2, ptr %cleanup.dest.slot, align 4
  br label %cleanup

pfor.ph:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 4, ptr %__begin) #6
  store i32 0, ptr %__begin, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr %__end) #6
  %2 = load i32, ptr %__limit, align 4
  %3 = load i32, ptr %__init, align 4
  %sub = sub nsw i32 %2, %3
  %sub1 = sub nsw i32 %sub, 1
  %div = sdiv i32 %sub1, 1
  %add = add nsw i32 %div, 1
  store i32 %add, ptr %__end, align 4
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  br label %pfor.detach

pfor.detach:                                      ; preds = %pfor.cond
  %4 = load i32, ptr %__init, align 4
  %5 = load i32, ptr %__begin, align 4
  %mul = mul nsw i32 %5, 1
  %add2 = add nsw i32 %4, %mul
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.detach
  %i = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr %i) #6
  store i32 %add2, ptr %i, align 4
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %6 = load i32, ptr %i, align 4
  %idxprom = sext i32 %6 to i64
  %arrayidx = getelementptr inbounds [10 x i32], ptr %x, i64 0, i64 %idxprom
  %7 = load i32, ptr %arrayidx, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, ptr %arrayidx, align 4
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %pfor.body
  call void @llvm.lifetime.end.p0(i64 4, ptr %i) #6
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.detach
  %8 = load i32, ptr %__begin, align 4
  %inc3 = add nsw i32 %8, 1
  store i32 %inc3, ptr %__begin, align 4
  %9 = load i32, ptr %__begin, align 4
  %10 = load i32, ptr %__end, align 4
  %cmp4 = icmp slt i32 %9, %10
  br i1 %cmp4, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %pfor.inc
  store i32 2, ptr %cleanup.dest.slot, align 4
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg)
  call void @llvm.lifetime.end.p0(i64 4, ptr %__end) #6
  call void @llvm.lifetime.end.p0(i64 4, ptr %__begin) #6
  br label %cleanup

cleanup:                                          ; preds = %sync.continue, %pfor.initcond.cleanup
  call void @llvm.lifetime.end.p0(i64 4, ptr %__limit) #6
  call void @llvm.lifetime.end.p0(i64 4, ptr %__init) #6
  br label %pfor.end

pfor.end:                                         ; preds = %cleanup
  %11 = call token @llvm.taskframe.create()
  detach within %syncreg6, label %det.achd, label %det.cont

det.achd:                                         ; preds = %pfor.end
  %y = alloca [10 x i32], align 16
  %i7 = alloca i32, align 4
  call void @llvm.taskframe.use(token %11)
  call void @llvm.lifetime.start.p0(i64 40, ptr %y) #6
  call void @llvm.lifetime.start.p0(i64 4, ptr %i7) #6
  store i32 0, ptr %i7, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %det.achd
  %12 = load i32, ptr %i7, align 4
  %cmp8 = icmp slt i32 %12, 0
  br i1 %cmp8, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  call void @llvm.lifetime.end.p0(i64 4, ptr %i7) #6
  br label %for.end

for.body:                                         ; preds = %for.cond
  %13 = load i32, ptr %i7, align 4
  %idxprom10 = sext i32 %13 to i64
  %arrayidx11 = getelementptr inbounds [10 x i32], ptr %x, i64 0, i64 %idxprom10
  %14 = load i32, ptr %arrayidx11, align 4
  %15 = load i32, ptr %i7, align 4
  %idxprom12 = sext i32 %15 to i64
  %arrayidx13 = getelementptr inbounds [10 x i32], ptr %y, i64 0, i64 %idxprom12
  store i32 %14, ptr %arrayidx13, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %16 = load i32, ptr %i7, align 4
  %inc14 = add nsw i32 %16, 1
  store i32 %inc14, ptr %i7, align 4
  br label %for.cond, !llvm.loop !8

for.end:                                          ; preds = %for.cond.cleanup
  call void @llvm.lifetime.end.p0(i64 40, ptr %y) #6
  reattach within %syncreg6, label %det.cont

det.cont:                                         ; preds = %for.end, %pfor.end
  %call = call i32 (ptr, ...) @printf(ptr noundef @.str)
  store i32 0, ptr %retval, align 4
  sync within %syncreg6, label %sync.continue16

sync.continue16:                                  ; preds = %det.cont
  call void @llvm.sync.unwind(token %syncreg6)
  store i32 1, ptr %cleanup.dest.slot, align 4
  sync within %syncreg6, label %sync.continue18

sync.continue18:                                  ; preds = %sync.continue16
  call void @llvm.sync.unwind(token %syncreg6)
  call void @llvm.lifetime.end.p0(i64 40, ptr %x) #6
  %17 = load i32, ptr %retval, align 4
  ret i32 %17
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #3

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #4

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #3

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #3

declare i32 @printf(ptr noundef, ...) #5

attributes #0 = { mustprogress noinline norecurse optnone sanitize_address sanitize_cilk uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #3 = { nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { willreturn memory(argmem: readwrite) }
attributes #5 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 16.0.6 (git@github.com:OpenCilk/opencilk-project.git d631c52742bc32d008a8101e6fc002f5085e1274)"}
!6 = distinct !{!6, !7}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
