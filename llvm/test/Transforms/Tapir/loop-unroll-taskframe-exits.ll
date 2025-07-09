; Check that loop peeling handles taskframes with unwind blocks correctly.
;
; RUN: opt < %s -passes="function<eager-inv>(loop-unroll<O3>)" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #0

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.resume.sl_p0i32s(token, { ptr, i32 }) #1

define void @_ZN9LAMMPS_NS6Verlet37run_stencil_md_many_cuts_proc_to_procILb1EEEviPPdS3_S3_RSt6vectorISt6atomicIiESaIS6_EES9_RS4_IS4_IiSaIiEESaISB_EESE_RS4_ISD_SaISD_EESE_RS4_ISt11atomic_flagSaISI_EESL_PNS_19MPIX_Stream_ManagerE() personality ptr null {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = call token @llvm.tapir.runtime.start()
  br label %for.body130.tf.tf.tf.tf

for.body130.tf.tf.tf.tf:                          ; preds = %for.inc152, %entry
  %exitcond.not = phi i1 [ true, %for.inc152 ], [ false, %entry ]
  %1 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd131, label %for.inc152 unwind label %lpad142

; CHECK: for.body130.tf.tf.tf.tf:
; CHECK-NOT: phi i1
; CHECK-NEXT: %[[TF1:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %syncreg, label %det.achd131, label %for.inc152 unwind label %lpad142

det.achd131:                                      ; preds = %for.body130.tf.tf.tf.tf
  call void @llvm.taskframe.use(token %1)
  invoke void null(ptr null, i32 0, i32 0, i32 0, ptr null, ptr null, ptr null, ptr null, ptr null, ptr null, ptr null, ptr null, ptr null, ptr null, ptr null)
          to label %invoke.cont135 unwind label %lpad132

; CHECK: det.achd131:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF1]])

invoke.cont135:                                   ; preds = %det.achd131
  reattach within %syncreg, label %for.inc152

for.inc152:                                       ; preds = %invoke.cont135, %for.body130.tf.tf.tf.tf
  br i1 %exitcond.not, label %if.end156, label %for.body130.tf.tf.tf.tf

; CHECK: for.inc152:
; CHECK-NOT: br i1
; CHECK-NEXT: %[[TF2:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %syncreg, label %[[DETACHED1:.+]], label %[[FORINC1:.+]] unwind label %[[LPAD1:.+]]

; CHECK: [[DETACHED1]]:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF2]])
; CHECK-NEXT: invoke void
; CHECK-NEXT: to label %[[INVOKE_CONT:.+]] unwind label %[[TASK_LPAD:.+]]

; CHECK: [[INVOKE_CONT]]:
; CHECK-NEXT: reattach within %syncreg, label %[[FORINC1]]

; CHECK: [[FORINC1]]:
; CHECK-NEXT: sync within %syncreg, label %sync.continue

; CHECK: [[TASK_LPAD]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg,
; CHECK-NEXT: to label %unreachable unwind label %[[LPAD1]]

; CHECK: [[LPAD1]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF2]],
; CHECK-NEXT: to label %unreachable unwind label %lpad151

lpad132:                                          ; preds = %det.achd131
  %2 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg, { ptr, i32 } zeroinitializer)
          to label %unreachable unwind label %lpad142

; CHECK: lpad132:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg,
; CHECK-NEXT: to label %unreachable unwind label %lpad142

lpad142:                                          ; preds = %lpad132, %for.body130.tf.tf.tf.tf
  %3 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i32s(token %1, { ptr, i32 } zeroinitializer)
          to label %unreachable unwind label %lpad151

; CHECK: lpad142:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF1]],
; CHECK-NEXT: to label %unreachable unwind label %lpad151

lpad151:                                          ; preds = %lpad142
  %4 = landingpad { ptr, i32 }
          cleanup
  ret void

if.end156:                                        ; preds = %for.inc152
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %if.end156
  call void @llvm.tapir.runtime.end(token %0)
  ret void

unreachable:                                      ; preds = %lpad142, %lpad132
  unreachable
}

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { willreturn memory(argmem: readwrite) }
