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

; CHECK: for.body130.tf.tf.tf.tf.peel:
; CHECK-NOT: phi i1
; CHECK-NEXT: %[[TF1:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %syncreg, label %[[DETACHED_PEEL:.+]], label %[[FORBODY_BACKEDGE_PEEL:.+]] unwind label %[[LPAD_LOOPEXIT_PEEL:.+]]

; CHECK: [[DETACHED_PEEL]]:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF1]])
; CHECK-NEXT: reattach within %syncreg, label %[[FORBODY_BACKEDGE_PEEL]]

; CHECK: [[FORBODY_BACKEDGE_PEEL]]:
; CHECK-NEXT: br label %[[FORBODY_PEEL_NEXT:.+]]

; CHECK: [[LPAD_LOOPEXIT_PEEL]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: br label %[[LPAD_PEEL:.+]]

; CHECK: [[LPAD_PEEL]]:
; CHECK-NEXT: phi { ptr, i32 } [ %{{.+}}, %[[LPAD_LOOPEXIT_PEEL]] ]
; CHECK-NOT: [ %{{.+}}, %{{.+}} ]
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF1]],
; CHECK-NEXT: to label %unreachable unwind label %lpad151

for.body130.tf.tf.tf.tf:                          ; preds = %det.achd131, %for.body130.tf.tf.tf.tf, %entry
  %stream_num126.0145 = phi i32 [ 0, %entry ], [ 1, %det.achd131 ], [ 1, %for.body130.tf.tf.tf.tf ]
  %1 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd131, label %for.body130.tf.tf.tf.tf unwind label %lpad142

; CHECK: for.body130.tf.tf.tf.tf:
; CHECK-NOT: phi i32
; CHECK-NEXT: %[[TF2:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %syncreg, label %det.achd131, label %[[FORBODY_BACKEDGE:.+]] unwind label %[[LPAD_LOOPEXIT:.+]]

det.achd131:                                      ; preds = %for.body130.tf.tf.tf.tf
  call void @llvm.taskframe.use(token %1)
  reattach within %syncreg, label %for.body130.tf.tf.tf.tf

; CHECK: det.achd131:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF2]])
; CHECK-NEXT: reattach within %syncreg, label %[[FORBODY_BACKEDGE]]

lpad132:                                          ; No predecessors!
  %2 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg, { ptr, i32 } zeroinitializer)
          to label %unreachable unwind label %lpad142

; CHECK: lpad132:
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg,
; CHECK-NEXT: to label %unreachable unwind label %[[LPAD_LOOPEXIT_SPLIT:.+]]

; CHECK: [[LPAD_LOOPEXIT]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: br label %lpad142

; CHECK: [[LPAD_LOOPEXIT_SPLIT]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: br label %lpad142

lpad142:                                          ; preds = %lpad132, %for.body130.tf.tf.tf.tf
  %3 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i32s(token %1, { ptr, i32 } %3)
          to label %unreachable unwind label %lpad151

; CHECK: lpad142:
; CHECK-NEXT: phi { ptr, i32 }
; CHECK-DAG: [ %{{.+}}, %[[LPAD_LOOPEXIT]] ]
; CHECK-DAG: [ %{{.+}}, %[[LPAD_LOOPEXIT_SPLIT]] ]
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF2]],
; CHECK-NEXT: to label %unreachable unwind label %lpad151

lpad151:                                          ; preds = %lpad142
  %4 = landingpad { ptr, i32 }
          cleanup
  resume { ptr, i32 } zeroinitializer

if.end156:                                        ; No predecessors!
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %if.end156
  call void @llvm.tapir.runtime.end(token %0)
  ret void

unreachable:                                      ; preds = %lpad142, %lpad132
  unreachable
}

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { willreturn memory(argmem: readwrite) }
