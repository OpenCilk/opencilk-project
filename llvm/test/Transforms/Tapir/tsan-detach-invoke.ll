; Check that ThreadSanitizer promotes calls in detached tasks to
; invokes correctly.
;
; RUN: opt < %s -passes="function(tsan)" -S | FileCheck %s

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare { i64, i1 } @llvm.smul.with.overflow.i64(i64, i64) #0

define linkonce_odr void @_ZN17ConcurrentHashSetImSt4hashImEE12insert_batchEPmm() {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc
  detach within %syncreg, label %cont7, label %pfor.inc

; CHECK: pfor.cond:
; CHECK-NEXT: detach within %syncreg, label %cont7, label %pfor.inc unwind label %[[TSAN_CLEANUP:.+]]

cont7:                                            ; preds = %pfor.cond
  call void @foo(i64 0, i64 0, i8* null, i8* null, i64 0)
  br label %cont9

; CHECK: cont7:
; CHECK-NEXT: invoke void @foo(i64 0, i64 0, i8* null, i8* null, i64 0)
; CHECK-NEXT: to label %{{.+}} unwind label %[[TSAN_CLEANUP_TASK:.+]]

cont9:                                            ; preds = %cont7
  br label %cont11

cont11:                                           ; preds = %cont9
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %cont11, %pfor.cond
  br label %pfor.cond

; CHECK: [[TSAN_CLEANUP]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: call void @__tsan_func_exit()
; CHECK-NEXT: resume

; CHECK: [[TSAN_CLEANUP_TASK]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %{{.+}})
; CHECK-NEXT: to label %{{.+}} unwind label %[[TSAN_CLEANUP]]
}

declare void @foo(i64, i64, i8*, i8*, i64) #2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #0

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #3

; Function Attrs: nofree nosync nounwind willreturn
declare i8* @llvm.stacksave() #4

; Function Attrs: nounwind willreturn
declare i8* @llvm.task.frameaddress(i32) #5

attributes #0 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly willreturn }
attributes #3 = { nofree nosync nounwind readnone willreturn }
attributes #4 = { nofree nosync nounwind willreturn }
attributes #5 = { nounwind willreturn }
