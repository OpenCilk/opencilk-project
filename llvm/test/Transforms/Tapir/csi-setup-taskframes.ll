; Check that CSI-setup properly promotes calls to invokes around various kinds of taskframes.
;
; RUN: opt < %s -passes="csi-setup" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define dso_local void @_Z1fv() #0 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline norecurse optnone uwtable
define dso_local noundef i32 @main() #1 {
entry:
  %retval = alloca i32, align 4
  %syncreg = call token @llvm.syncregion.start()
  %cleanup.dest.slot = alloca i32, align 4
  store i32 0, ptr %retval, align 4
  %0 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %0)
  call void @_Z1fv()
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %entry
  %1 = call token @llvm.taskframe.create()
  %syncreg1 = call token @llvm.syncregion.start()
  %2 = call token @llvm.taskframe.create()
  detach within %syncreg1, label %det.achd2, label %det.cont3

det.achd2:                                        ; preds = %det.cont
  call void @llvm.taskframe.use(token %2)
  call void @_Z1fv()
  reattach within %syncreg1, label %det.cont3

det.cont3:                                        ; preds = %det.achd2, %det.cont
  call void @_Z1fv()
  sync within %syncreg1, label %sync.continue

sync.continue:                                    ; preds = %det.cont3
  call void @llvm.sync.unwind(token %syncreg1)
  call void @llvm.taskframe.end(token %1)
  %3 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd4, label %det.cont5

det.achd4:                                        ; preds = %sync.continue
  call void @llvm.taskframe.use(token %3)
  call void @_Z1fv()
  reattach within %syncreg, label %det.cont5

det.cont5:                                        ; preds = %det.achd4, %sync.continue
  call void @_Z1fv()
  sync within %syncreg, label %sync.continue6

sync.continue6:                                   ; preds = %det.cont5
  call void @llvm.sync.unwind(token %syncreg)
  %4 = load i32, ptr %retval, align 4
  ret i32 %4
}

; CHECK: define {{.*}}i32 @main()
; CHECK: entry:
; CHECK: br label %[[ENTRY_SPLIT:.+]]

; CHECK: [[ENTRY_SPLIT]]:
; CHECK-NEXT: %[[TF0:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %syncreg, label %det.achd, label %det.cont

; CHECK: det.achd:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF0]])
; CHECK-NEXT: call void @_Z1fv()
; CHECK-NEXT: reattach within %syncreg, label %det.cont

; CHECK: det.cont:
; CHECK-NEXT: %[[TF1:.+]] = call token @llvm.taskframe.create()
; CHECK: br label %[[DET_CONT_SPLIT:.+]]

; CHECK: [[DET_CONT_SPLIT]]:
; CHECK-NEXT: %[[TF2:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %syncreg1, label %det.achd2, label %det.cont3

; CHECK: det.achd2:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF2]])
; CHECK-NEXT: call void @_Z1fv()
; CHECK-NEXT: reattach within %syncreg1, label %det.cont3

; CHECK: det.cont3:
; CHECK-NEXT: call void @_Z1fv()
; CHECK-NEXT: sync within %syncreg1, label %sync.continue

; CHECK: sync.continue:
; CHECK-NEXT: invoke void @llvm.sync.unwind(token %syncreg1)
; CHECK-NEXT: to label %[[SYNC_CONT_SPLIT:.+]] unwind label %[[CSI_CLEANUP5:.+]]

; CHECK: [[SYNC_CONT_SPLIT]]:
; CHECK-NEXT: call void @llvm.taskframe.end(token %[[TF1]])
; CHECK-NEXT: br label %[[TF1_END_SPLIT:.+]]

; CHECK: [[TF1_END_SPLIT]]:
; CHECK-NEXT: %[[TF3:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %syncreg, label %det.achd4, label %det.cont5

; CHECK: det.achd4:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF3]])
; CHECK-NEXT: call void @_Z1fv()
; CHECK-NEXT: reattach within %syncreg, label %det.cont5

; CHECK: det.cont5:
; CHECK-NEXT: call void @_Z1fv()
; CHECK-NEXT: sync within %syncreg, label %sync.continue6

; CHECK: sync.continue6:
; CHECK-NEXT: invoke void @llvm.sync.unwind(token %syncreg)
; CHECK-NEXT: to label %[[SYNC_CONT6_SPLIT:.+]] unwind label %[[CSI_CLEANUP:.+]]

; CHECK: [[SYNC_CONT6_SPLIT]]:
; CHECK-NEXT: load i32
; CHECK-NEXT: ret i32

; CHECK: [[CSI_CLEANUP]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: resume

; CHECK: [[CSI_CLEANUP5]]:
; CHECK-NEXT: %[[LPAD:.+]] = landingpad { ptr, i32 }
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF1]], { ptr, i32 } %[[LPAD]])
; CHECK-NEXT: to label %[[CSI_CLEANUP_UNREACHABLE:.+]] unwind label %[[CSI_CLEANUP]]

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #2

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #2

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #2

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #3

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.end(token) #2

attributes #0 = { mustprogress noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress noinline norecurse optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 21.1.3 (git@github.com:OpenCilk/opencilk-project.git e60c5d62805dcca1d1d8982f759586f545cdc051)"}
