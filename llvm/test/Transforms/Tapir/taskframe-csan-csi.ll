; RUN: opt < %s -csan -ignore-sanitize-cilk-attr -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-CSAN
; RUN: opt < %s -csi -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-CSI

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@_ZTIi = external dso_local constant i8*

; Function Attrs: noinline optnone uwtable
define dso_local void @_Z3barv() #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %exn.slot28 = alloca i8*
  %ehselector.slot29 = alloca i32
  call void @_Z3foov()
  %0 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

; CHECK: entry:
; CHECK-CSI: call void @__csi_bb_entry(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_bb_exit(
; CHECK-CSI: call void @__csi_before_call(
; CHECK-CSAN: call void @__csan_before_call(
; CHECK-NEXT: invoke void @_Z3foov()
; CHECK-NEXT: to label %[[FOO1_CONT:.+]] unwind label %[[CSI_CLEANUP:.+]]

; CHECK: [[FOO1_CONT]]:
; CHECK-CSI-NEXT: call void @__csi_after_call(
; CHECK-CSAN-NEXT: call void @__csan_after_call(
; CHECK: call token @llvm.taskframe.create()
; CHECK-CSI: call void @__csi_detach(
; CHECK-CSAN: call void @__csan_detach(
; CHECK: detach within %syncreg, label %det.achd, label %det.cont unwind label %[[CSI_CLEANUP_DU:.+]]

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %0)
  call void @_Z3foov()
  reattach within %syncreg, label %det.cont

; CHECK: det.achd:
; CHECK-CSI: call void @__csi_task(
; CHECK-CSAN: call void @__csan_task(
; CHECK-CSI: call void @__csi_before_call(
; CHECK-CSAN: call void @__csan_before_call(
; CHECK: invoke void @_Z3foov()
; CHECK-NEXT: to label %{{.+}} unwind label %[[CSI_CLEANUP_DET:.+]]

det.cont:                                         ; preds = %det.achd, %entry
  %1 = call token @llvm.taskframe.create()
  %syncreg1 = call token @llvm.syncregion.start()
  %exn.slot13 = alloca i8*
  %ehselector.slot14 = alloca i32
  %e = alloca i32, align 4
  %2 = call token @llvm.taskframe.create()
  %exn.slot5 = alloca i8*
  %ehselector.slot6 = alloca i32
  detach within %syncreg1, label %det.achd2, label %det.cont7 unwind label %lpad4

; CHECK: det.cont:
; CHECK-CSI: call void @__csi_detach_continue(
; CHECK-CSAN: call void @__csan_detach_continue(
; CHECK-CSI: call void @__csi_bb_entry(
; CHECK: %[[TRY_TF:.+]] = call token @llvm.taskframe.create()
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_bb_exit(
; CHECK-CSI: call void @__csi_detach(
; CHECK-CSAN: call void @__csan_detach(
; CHECK: detach within %syncreg1, label %det.achd2, label %det.cont7 unwind label %lpad4

det.achd2:                                        ; preds = %det.cont
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  call void @llvm.taskframe.use(token %2)
  invoke void @_Z3foov()
          to label %invoke.cont unwind label %lpad

; CHECK: det.achd2:
; CHECK-CSI: call void @__csi_task(
; CHECK-CSAN: call void @__csan_task(
; CHECK-CSI: call void @__csi_before_call(
; CHECK-CSAN: call void @__csan_before_call(
; CHECK: invoke void @_Z3foov()
; CHECK-NEXT: to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %det.achd2
  reattach within %syncreg1, label %det.cont7

; CHECK: invoke.cont:
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-CSI: call void @__csi_task_exit(
; CHECK-CSAN: call void @__csan_task_exit(
; CHECK: reattach within %syncreg1, label %det.cont7

det.cont7:                                        ; preds = %det.cont, %invoke.cont
  invoke void @_Z3foov()
          to label %invoke.cont15 unwind label %lpad12

; CHECK: det.cont7:
; CHECK-CSAN: call void @__csan_detach_continue(
; CHECK-CSAN: call void @__csan_before_call(
; CHECK: invoke void @_Z3foov()
; CHECK-NEXT: to label %invoke.cont15 unwind label %[[LPAD12_CONT:.+]]

invoke.cont15:                                    ; preds = %det.cont7
  sync within %syncreg1, label %sync.continue

; CHECK: invoke.cont15:
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-CSI: call void @__csi_before_sync(
; CHECK-CSAN: call void @__csan_sync(
; CHECK: sync within %syncreg1, label %sync.continue

sync.continue:                                    ; preds = %invoke.cont15
  invoke void @llvm.sync.unwind(token %syncreg1)
          to label %invoke.cont16 unwind label %lpad12

; CHECK: sync.continue:
; CHECK: invoke void @llvm.sync.unwind(token %syncreg1)
; CHECK-NEXT: to label %invoke.cont16 unwind label %[[LPAD12_SYNC:.+]]

invoke.cont16:                                    ; preds = %sync.continue
  br label %try.cont

; CHECK: invoke.cont16:
; CHECK-CSI: call void @__csi_after_sync(
; CHECK: br label %try.cont

lpad:                                             ; preds = %det.achd2
  %3 = landingpad { i8*, i32 }
          cleanup
  %4 = extractvalue { i8*, i32 } %3, 0
  store i8* %4, i8** %exn.slot, align 8
  %5 = extractvalue { i8*, i32 } %3, 1
  store i32 %5, i32* %ehselector.slot, align 4
  %exn = load i8*, i8** %exn.slot, align 8
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val3 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg1, { i8*, i32 } %lpad.val3)
          to label %unreachable unwind label %lpad4

; CHECK: lpad:
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-CSI: call void @__csi_bb_entry(
; CHECK-CSI: call void @__csi_bb_exit(
; CHECK-CSI: call void @__csi_task_exit(
; CHECK-CSAN: call void @__csan_task_exit(
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg1,
; CHECK-NEXT: to label %unreachable unwind label %lpad4

lpad4:                                            ; preds = %det.cont, %lpad
  %6 = landingpad { i8*, i32 }
          cleanup
  %7 = extractvalue { i8*, i32 } %6, 0
  store i8* %7, i8** %exn.slot5, align 8
  %8 = extractvalue { i8*, i32 } %6, 1
  store i32 %8, i32* %ehselector.slot6, align 4
  br label %ehcleanup

; CHECK: lpad4:
; CHECK: br label %ehcleanup

ehcleanup:                                        ; preds = %lpad4
  %exn8 = load i8*, i8** %exn.slot5, align 8
  %sel9 = load i32, i32* %ehselector.slot6, align 4
  %lpad.val10 = insertvalue { i8*, i32 } undef, i8* %exn8, 0
  %lpad.val11 = insertvalue { i8*, i32 } %lpad.val10, i32 %sel9, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %2, { i8*, i32 } %lpad.val11)
          to label %unreachable unwind label %lpad12

; CHECK: ehcleanup:
; CHECK: invoke void @llvm.taskframe.resume
; CHECK-NEXT: to label %{{.+}} unwind label %[[LPAD12_TF:.+]]

; CHECK: [[LPAD12_SYNC]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch
; CHECK-CSI: call void @__csi_after_sync(
; CHECK: br label %lpad12

; CHECK: [[LPAD12_CONT]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch
; CHECK-CSAN: call void @__csan_after_call(
; CHECK: br label %[[LPAD12_CSI:.+]]

; CHECK: [[LPAD12_TF]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch
; CHECK-CSI: call void @__csi_detach_continue(
; CHECK-CSAN: call void @__csan_detach_continue(
; CHECK: br label %[[LPAD12_CSI]]

; CHECK: [[LPAD12_CSI]]:
; CHECK: br label %lpad12

lpad12:                                           ; preds = %sync.continue, %det.cont7, %ehcleanup
  %9 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %10 = extractvalue { i8*, i32 } %9, 0
  store i8* %10, i8** %exn.slot13, align 8
  %11 = extractvalue { i8*, i32 } %9, 1
  store i32 %11, i32* %ehselector.slot14, align 4
  br label %catch.dispatch

catch.dispatch:                                   ; preds = %lpad12
  %sel17 = load i32, i32* %ehselector.slot14, align 4
  %12 = call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #5
  %matches = icmp eq i32 %sel17, %12
  br i1 %matches, label %catch, label %ehcleanup22

catch:                                            ; preds = %catch.dispatch
  %exn18 = load i8*, i8** %exn.slot13, align 8
  %13 = call i8* @__cxa_begin_catch(i8* %exn18) #5
  %14 = bitcast i8* %13 to i32*
  %15 = load i32, i32* %14, align 4
  store i32 %15, i32* %e, align 4
  %16 = load i32, i32* %e, align 4
  invoke void @_Z6handlei(i32 %16)
          to label %invoke.cont20 unwind label %lpad19

invoke.cont20:                                    ; preds = %catch
  call void @__cxa_end_catch() #5
  br label %try.cont

try.cont:                                         ; preds = %invoke.cont20, %invoke.cont16
  call void @llvm.taskframe.end(token %1)
  call void @_Z3foov()
  %17 = call token @llvm.taskframe.create()
  %syncreg30 = call token @llvm.syncregion.start()
  %exn.slot51 = alloca i8*
  %ehselector.slot52 = alloca i32
  %e60 = alloca i32, align 4
  %18 = call token @llvm.taskframe.create()
  %exn.slot42 = alloca i8*
  %ehselector.slot43 = alloca i32
  detach within %syncreg30, label %det.achd31, label %det.cont44 unwind label %lpad41

; CHECK: try.cont:
; CHECK: call void @llvm.taskframe.end(token %[[TRY_TF]])
; CHECK-CSI: call void @__csi_before_call(
; CHECK-CSAN: call void @__csan_before_call(
; CHECK-NEXT: invoke void @_Z3foov()
; CHECK-NEXT: to label %[[FOO2_CONT:.+]] unwind label %[[CSI_CLEANUP]]

; CHECK: [[FOO2_CONT]]:
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-CSI: call void @__csi_bb_entry(
; CHECK: %[[TRY2_TF:.+]] = call token @llvm.taskframe.create()
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_bb_exit(
; CHECK-CSI: call void @__csi_detach(
; CHECK-CSAN: call void @__csan_detach(
; CHECK: detach within %syncreg30, label %det.achd31, label %det.cont44 unwind label %lpad41

det.achd31:                                       ; preds = %try.cont
  %exn.slot33 = alloca i8*
  %ehselector.slot34 = alloca i32
  call void @llvm.taskframe.use(token %18)
  invoke void @_Z3foov()
          to label %invoke.cont35 unwind label %lpad32

; CHECK: det.achd31:
; CHECK-CSI: call void @__csi_task(
; CHECK-CSAN: call void @__csan_task(
; CHECK-CSI: call void @__csi_bb_entry(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_after_alloca(
; CHECK-CSI: call void @__csi_bb_exit(
; CHECK-CSI: call void @__csi_before_call(
; CHECK-CSAN: call void @__csan_before_call(
; CHECK: invoke void @_Z3foov()
; CHECK-NEXT: to label %invoke.cont35 unwind label %lpad32

invoke.cont35:                                    ; preds = %det.achd31
  reattach within %syncreg30, label %det.cont44

; CHECK: invoke.cont35:
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-CSI: call void @__csi_task_exit(
; CHECK-CSAN: call void @__csan_task_exit(
; CHECK: reattach within %syncreg30, label %det.cont44

det.cont44:                                       ; preds = %try.cont, %invoke.cont35
  invoke void @_Z3foov()
          to label %invoke.cont53 unwind label %lpad50

; CHECK: det.cont44:
; CHECK-CSI: call void @__csi_detach_continue(
; CHECK-CSAN: call void @__csan_detach_continue(
; CHECK-CSI: call void @__csi_before_call(
; CHECK-CSAN: call void @__csan_before_call(
; CHECK-NEXT: invoke void @_Z3foov()
; CHECK-NEXT: to label %invoke.cont53 unwind label %[[LPAD50_CONT:.+]]

invoke.cont53:                                    ; preds = %det.cont44
  sync within %syncreg30, label %sync.continue54

; CHECK: invoke.cont53:
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-CSI: call void @__csi_before_sync(
; CHECK-CSAN: call void @__csan_sync(
; CHECK: sync within %syncreg30, label %sync.continue54

sync.continue54:                                  ; preds = %invoke.cont53
  invoke void @llvm.sync.unwind(token %syncreg30)
          to label %invoke.cont55 unwind label %lpad50

; CHECK: sync.continue54:
; CHECK: invoke void @llvm.sync.unwind(token %syncreg30)
; CHECK-NEXT: to label %invoke.cont55 unwind label %[[LPAD50_SYNC:.+]]

invoke.cont55:                                    ; preds = %sync.continue54
  br label %try.cont65

; CHECK: invoke.cont55:
; CHECK-CSI: call void @__csi_after_sync(
; CHECK: br label %try.cont65

lpad19:                                           ; preds = %catch
  %19 = landingpad { i8*, i32 }
          cleanup
  %20 = extractvalue { i8*, i32 } %19, 0
  store i8* %20, i8** %exn.slot13, align 8
  %21 = extractvalue { i8*, i32 } %19, 1
  store i32 %21, i32* %ehselector.slot14, align 4
  call void @__cxa_end_catch() #5
  br label %ehcleanup22

ehcleanup22:                                      ; preds = %lpad19, %catch.dispatch
  %exn23 = load i8*, i8** %exn.slot13, align 8
  %sel24 = load i32, i32* %ehselector.slot14, align 4
  %lpad.val25 = insertvalue { i8*, i32 } undef, i8* %exn23, 0
  %lpad.val26 = insertvalue { i8*, i32 } %lpad.val25, i32 %sel24, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %1, { i8*, i32 } %lpad.val26)
          to label %unreachable unwind label %lpad27

; CHECK: ehcleanup22:
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TRY_TF]],
; CHECK-NEXT: to label %{{.+}} unwind label %lpad27

lpad27:                                           ; preds = %ehcleanup22
  %22 = landingpad { i8*, i32 }
          cleanup
  %23 = extractvalue { i8*, i32 } %22, 0
  store i8* %23, i8** %exn.slot28, align 8
  %24 = extractvalue { i8*, i32 } %22, 1
  store i32 %24, i32* %ehselector.slot29, align 4
  br label %eh.resume

lpad32:                                           ; preds = %det.achd31
  %25 = landingpad { i8*, i32 }
          cleanup
  %26 = extractvalue { i8*, i32 } %25, 0
  store i8* %26, i8** %exn.slot33, align 8
  %27 = extractvalue { i8*, i32 } %25, 1
  store i32 %27, i32* %ehselector.slot34, align 4
  %exn37 = load i8*, i8** %exn.slot33, align 8
  %sel38 = load i32, i32* %ehselector.slot34, align 4
  %lpad.val39 = insertvalue { i8*, i32 } undef, i8* %exn37, 0
  %lpad.val40 = insertvalue { i8*, i32 } %lpad.val39, i32 %sel38, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg30, { i8*, i32 } %lpad.val40)
          to label %unreachable unwind label %lpad41

; CHECK: lpad32:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-CSI: call void @__csi_bb_entry(
; CHECK-CSI: call void @__csi_bb_exit(
; CHECK-CSI: call void @__csi_task_exit(
; CHECK-CSAN: call void @__csan_task_exit(
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg30,
; CHECK-NEXT: to label %unreachable unwind label %lpad41

lpad41:                                           ; preds = %try.cont, %lpad32
  %28 = landingpad { i8*, i32 }
          cleanup
  %29 = extractvalue { i8*, i32 } %28, 0
  store i8* %29, i8** %exn.slot42, align 8
  %30 = extractvalue { i8*, i32 } %28, 1
  store i32 %30, i32* %ehselector.slot43, align 4
  br label %ehcleanup45

; CHECK: lpad41:
; CHECK: br label %ehcleanup45

ehcleanup45:                                      ; preds = %lpad41
  %exn46 = load i8*, i8** %exn.slot42, align 8
  %sel47 = load i32, i32* %ehselector.slot43, align 4
  %lpad.val48 = insertvalue { i8*, i32 } undef, i8* %exn46, 0
  %lpad.val49 = insertvalue { i8*, i32 } %lpad.val48, i32 %sel47, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %18, { i8*, i32 } %lpad.val49)
          to label %unreachable unwind label %lpad50

; CHECK: ehcleanup45:
; CHECK: invoke void @llvm.taskframe.resume
; CHECK-NEXT: to label %{{.+}} unwind label %[[LPAD50_TF:.+]]

; CHECK: [[LPAD50_SYNC]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch
; CHECK-CSI: call void @__csi_after_sync(
; CHECK: br label %lpad50

; CHECK: [[LPAD50_CONT]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK: br label %[[LPAD50_CSI:.+]]

; CHECK: [[LPAD50_TF]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch
; CHECK-CSI: call void @__csi_detach_continue(
; CHECK-CSAN: call void @__csan_detach_continue(
; CHECK: br label %[[LPAD50_CSI]]

; CHECK: [[LPAD50_CSI]]:
; CHECK: br label %lpad50

lpad50:                                           ; preds = %sync.continue54, %det.cont44, %ehcleanup45
  %31 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %32 = extractvalue { i8*, i32 } %31, 0
  store i8* %32, i8** %exn.slot51, align 8
  %33 = extractvalue { i8*, i32 } %31, 1
  store i32 %33, i32* %ehselector.slot52, align 4
  br label %catch.dispatch56

catch.dispatch56:                                 ; preds = %lpad50
  %sel57 = load i32, i32* %ehselector.slot52, align 4
  %34 = call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #5
  %matches58 = icmp eq i32 %sel57, %34
  br i1 %matches58, label %catch59, label %ehcleanup66

catch59:                                          ; preds = %catch.dispatch56
  %exn61 = load i8*, i8** %exn.slot51, align 8
  %35 = call i8* @__cxa_begin_catch(i8* %exn61) #5
  %36 = bitcast i8* %35 to i32*
  %37 = load i32, i32* %36, align 4
  store i32 %37, i32* %e60, align 4
  %38 = load i32, i32* %e60, align 4
  invoke void @_Z6handlei(i32 %38)
          to label %invoke.cont63 unwind label %lpad62

invoke.cont63:                                    ; preds = %catch59
  call void @__cxa_end_catch() #5
  br label %try.cont65

try.cont65:                                       ; preds = %invoke.cont63, %invoke.cont55
  call void @llvm.taskframe.end(token %17)
  sync within %syncreg, label %sync.continue72

; CHECK: try.cont65:
; CHECK: call void @llvm.taskframe.end(
; CHECK-CSI: call void @__csi_before_sync(
; CHECK-CSAN: call void @__csan_sync(
; CHECK: sync within %syncreg, label %sync.continue72

sync.continue72:                                  ; preds = %try.cont65
  call void @llvm.sync.unwind(token %syncreg)
  ret void

; CHECK: sync.continue72:
; CHECK: invoke void @llvm.sync.unwind(token %syncreg)
; CHECK-NEXT: to label %[[SYNC_CONT:.+]] unwind label %[[CSI_CLEANUP_SYNC:.+]]

; CHECK: [[SYNC_CONT]]:
; CHECK-CSI: call void @__csi_after_sync(
; CHECK-CSI: call void @__csi_func_exit(
; CHECK-CSAN: call void @__csan_func_exit(
; CHECK: ret void

lpad62:                                           ; preds = %catch59
  %39 = landingpad { i8*, i32 }
          cleanup
  %40 = extractvalue { i8*, i32 } %39, 0
  store i8* %40, i8** %exn.slot51, align 8
  %41 = extractvalue { i8*, i32 } %39, 1
  store i32 %41, i32* %ehselector.slot52, align 4
  call void @__cxa_end_catch() #5
  br label %ehcleanup66

ehcleanup66:                                      ; preds = %lpad62, %catch.dispatch56
  %exn67 = load i8*, i8** %exn.slot51, align 8
  %sel68 = load i32, i32* %ehselector.slot52, align 4
  %lpad.val69 = insertvalue { i8*, i32 } undef, i8* %exn67, 0
  %lpad.val70 = insertvalue { i8*, i32 } %lpad.val69, i32 %sel68, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %17, { i8*, i32 } %lpad.val70)
          to label %unreachable unwind label %lpad71

lpad71:                                           ; preds = %ehcleanup66
  %42 = landingpad { i8*, i32 }
          cleanup
  %43 = extractvalue { i8*, i32 } %42, 0
  store i8* %43, i8** %exn.slot28, align 8
  %44 = extractvalue { i8*, i32 } %42, 1
  store i32 %44, i32* %ehselector.slot29, align 4
  br label %eh.resume

eh.resume:                                        ; preds = %lpad71, %lpad27
  %exn73 = load i8*, i8** %exn.slot28, align 8
  %sel74 = load i32, i32* %ehselector.slot29, align 4
  %lpad.val75 = insertvalue { i8*, i32 } undef, i8* %exn73, 0
  %lpad.val76 = insertvalue { i8*, i32 } %lpad.val75, i32 %sel74, 1
  resume { i8*, i32 } %lpad.val76

unreachable:                                      ; preds = %ehcleanup66, %ehcleanup45, %lpad32, %ehcleanup22, %ehcleanup, %lpad
  unreachable

; CHECK: [[CSI_CLEANUP_SYNC]]:
; CHECK-CSI: call void @__csi_after_sync(
; CHECK: br label %[[CSI_RESUME:.+]]

; CHECK: [[CSI_CLEANUP]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-NOT: invoke void @llvm.taskframe.resume
; CHECK: br label %{{.+}}

; CHECK-NOT: invoke void @llvm.taskframe.resume

; CHECK: [[CSI_RESUME]]:
; CHECK-CSI: call void @__csi_func_exit(
; CHECK-CSAN: call void @__csan_func_exit(
; CHECK: resume

; CHECK: [[CSI_CLEANUP_DU]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.taskframe.resume
; CHECK-NEXT: to label %{{.+}} unwind label %[[CSI_TF:.+]]

; CHECK: [[CSI_CLEANUP_DET]]:
; CHECK: landingpad
; CHECK-NEXT: cleanup
; CHECK-CSI: call void @__csi_after_call(
; CHECK-CSAN: call void @__csan_after_call(
; CHECK-CSI: call void @__csi_task_exit(
; CHECK-CSAN: call void @__csan_task_exit(
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg,
; CHECK-NEXT: to label %{{.+}} unwind label %[[CSI_CLEANUP_DU]]
}

declare dso_local void @_Z3foov() #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #2

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #3

; Function Attrs: nounwind readnone
declare i32 @llvm.eh.typeid.for(i8*) #4

declare dso_local i8* @__cxa_begin_catch(i8*)

declare dso_local void @_Z6handlei(i32) #1

declare dso_local void @__cxa_end_catch()

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #2

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly willreturn }
attributes #4 = { nounwind readnone }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 811fc0c48c0764eef7efffcc7acd6c666804e5ed)"}
