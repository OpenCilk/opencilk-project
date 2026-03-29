; Check that mem2reg processes allocas in task-entry blocks correctly when
; those blocks can be discovered in multiple ways.
;
; RUN: opt < %s -passes="function<eager-inv>(mem2reg)" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.std::_Rb_tree_const_iterator" = type { ptr }

define void @_ZN6summit17MechanicsWeakForm8ResidualERKNS_10NodalFieldIdEES4_dbRS2_RKNS_20CommunicationManagerEb() {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %__begin2191 = alloca %"struct.std::_Rb_tree_const_iterator", align 8
  %0 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

; CHECK-LABEL: define void @_ZN6summit17MechanicsWeakForm8ResidualERKNS_10NodalFieldIdEES4_dbRS2_RKNS_20CommunicationManagerEb(
; CHECK: entry:
; CHECK-NOT: alloca
; CHECK: taskframe.create
; CHECK-NEXT: detach
; CHECK: taskframe.use

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %0)
  br label %for.cond

for.cond:                                         ; preds = %for.cond, %det.achd
  br label %for.cond

det.cont:                                         ; preds = %entry
  ret void
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #0

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
