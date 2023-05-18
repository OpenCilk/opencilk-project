; Check that the syncs in a function that can throw are lowered to use
; a default cleanup landingpad.  In addition, make sure that the same
; default cleanup landingpad is used for multiple syncs (for
; efficiency).
;
; RUN: opt < %s -passes='tapir2target' -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s

; ModuleID = 'sync-exception-test.cpp'
source_filename = "sync-exception-test.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress noinline optnone uwtable
define dso_local void @_Z7recurseiPFvvE(i32 noundef %n, ptr noundef %fn) #0 {
entry:
  %n.addr = alloca i32, align 4
  %fn.addr = alloca ptr, align 8
  %syncreg = call token @llvm.syncregion.start()
  store i32 %n, ptr %n.addr, align 4
  store ptr %fn, ptr %fn.addr, align 8
  %0 = load i32, ptr %n.addr, align 4
  %cmp = icmp eq i32 %0, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %1 = load ptr, ptr %fn.addr, align 8
  call void %1()
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %2 = load i32, ptr %n.addr, align 4
  %cmp1 = icmp eq i32 %2, 0
  br i1 %cmp1, label %if.then2, label %if.end3

if.then2:                                         ; preds = %if.end
  br label %det.cont6

if.end3:                                          ; preds = %if.end
  %3 = call token @llvm.taskframe.create()
  %4 = load i32, ptr %n.addr, align 4
  %sub = sub nsw i32 %4, 1
  %5 = load ptr, ptr %fn.addr, align 8
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.end3
  call void @llvm.taskframe.use(token %3)
  call void @_Z7recurseiPFvvE(i32 noundef %sub, ptr noundef %5)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.end3
  sync within %syncreg, label %sync.continue

; CHECK: det.cont:
; CHECK-NEXT: invoke void @__cilk_sync(
; CHECK-NEXT: to label %sync.continue unwind label %[[DEFAULT_SYNC_LPAD:.+]]

sync.continue:                                    ; preds = %det.cont
  call void @llvm.sync.unwind(token %syncreg)
  %6 = call token @llvm.taskframe.create()
  %7 = load i32, ptr %n.addr, align 4
  %sub4 = sub nsw i32 %7, 2
  %8 = load ptr, ptr %fn.addr, align 8
  detach within %syncreg, label %det.achd5, label %det.cont6

det.achd5:                                        ; preds = %sync.continue
  call void @llvm.taskframe.use(token %6)
  call void @_Z7recurseiPFvvE(i32 noundef %sub4, ptr noundef %8)
  reattach within %syncreg, label %det.cont6

det.cont6:                                        ; preds = %if.then2, %det.achd5, %sync.continue
  sync within %syncreg, label %sync.continue7

; CHECK: det.cont6:
; CHECK-NEXT: invoke void @__cilk_sync(
; CHECK-NEXT: to label %sync.continue7 unwind label %[[DEFAULT_SYNC_LPAD]]

sync.continue7:                                   ; preds = %det.cont6
  call void @llvm.sync.unwind(token %syncreg)
  ret void
}

; CHECK: [[DEFAULT_SYNC_LPAD]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: __cilkrts_enter_landingpad
; CHECK: resume

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #1

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #2

attributes #0 = { mustprogress noinline optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly willreturn }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 15.0.7 (git@github.com:OpenCilk/opencilk-project.git 6ee5a0fb84be7882928cd895d92665924dc4e6ec)"}
