; Check that detach-unwind blocks are properly inlined when they are reachable only from the detach instruction itself.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(inline))" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx15.0.0"

; CHECK: define void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiERH3BagIiEjPj()

; CHECK: pfor.cond:
; CHECK-NEXT: detach within none, label %pfor.body.entry, label %pfor.cond unwind label %lpad59

; CHECK: pfor.body.entry:
; CHECK: br label %[[INLINED_PFOR_COND:.+]]

; CHECK: [[INLINED_PFOR_COND]]:
; CHECK: detach within {{.+}}, label %{{.+}}, label %{{.+}} unwind label %[[INLINED_DETACH_UNWIND:.+]]

; CHECK: [[INLINED_DETACH_UNWIND]]:
; CHECK-NOT: resume
; CHECK: br label %[[UNWIND_TO_PARENT:.+]]

; CHECK: [[UNWIND_TO_PARENT]]:
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i32s(token
; CHECK-NEXT: to label %{{.+}} unwind label %lpad49

define void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiERH3BagIiEjPj() personality ptr null {
entry:
  %0 = call token @llvm.tapir.runtime.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.preattach, %pfor.cond, %entry
  detach within none, label %pfor.body.entry, label %pfor.cond unwind label %lpad59

pfor.body.entry:                                  ; preds = %pfor.cond
  invoke fastcc void @_ZL14pbfs_proc_NodePKiiRH3BagIiEjPjS0_S0_(ptr null, i32 0, ptr null, i32 0, ptr null, ptr null, ptr null)
          to label %pfor.preattach unwind label %lpad49

pfor.preattach:                                   ; preds = %pfor.body.entry
  reattach within none, label %pfor.cond

lpad49:                                           ; preds = %pfor.body.entry
  %1 = landingpad { ptr, i32 }
          cleanup
  unreachable

lpad59:                                           ; preds = %pfor.cond
  %2 = landingpad { ptr, i32 }
          cleanup
  call void @llvm.tapir.runtime.end(token %0)
  resume { ptr, i32 } zeroinitializer
}

define fastcc void @_ZL14pbfs_proc_NodePKiiRH3BagIiEjPjS0_S0_(ptr %n, i32 %fillSize, ptr %next, i32 %newdist, ptr %distances, ptr %nodes, ptr %edges) personality ptr null {
entry:
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.cond, %entry
  detach within none, label %pfor.body.entry, label %pfor.cond unwind label %lpad20

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %for.cond

for.cond:                                         ; preds = %for.cond, %pfor.body.entry
  br label %for.cond

lpad20:                                           ; preds = %pfor.cond
  %0 = landingpad { ptr, i32 }
          cleanup
  resume { ptr, i32 } zeroinitializer
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #0

; uselistorder directives
uselistorder ptr null, { 7, 8, 0, 2, 3, 4, 5, 6, 9, 10, 1 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
