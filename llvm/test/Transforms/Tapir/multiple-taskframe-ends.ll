; Check that Tapir task simplify properly handles taskframes with
; multiple ends.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(function<eager-inv>(task-simplify)))" -S | FileCheck %s
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #0

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #0

define ptr @render() {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg105 = call token @llvm.syncregion.start()
  br label %for.cond

for.cond:                                         ; preds = %cleanup, %entry
  detach within %syncreg, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %for.cond
  br label %for.cond79

for.cond79:                                       ; preds = %for.inc, %pfor.body
  br i1 false, label %for.cond.cleanup82, label %for.body84

for.cond.cleanup82:                               ; preds = %for.cond79
  reattach within %syncreg, label %pfor.inc

for.body84:                                       ; preds = %for.cond79
  br i1 true, label %if.then.tf, label %for.inc

if.then.tf:
  %tf.i = call token @llvm.taskframe.create()
  %syncreg.i = call token @llvm.syncregion.start()
  br i1 false, label %set_color.exit.tfend, label %if.then.i.i70

if.then.i.i70:
  detach within %syncreg.i, label %pfor.body.entry.i, label %pfor.inc.i

pfor.body.entry.i:                                ; preds = %for.body84
  reattach within %syncreg.i, label %pfor.inc.i

pfor.inc.i:                                       ; preds = %pfor.body.entry.i, %for.body84
  br i1 false, label %if.then.i.i70, label %pfor.cond.cleanup.i

pfor.cond.cleanup.i:                              ; preds = %pfor.inc.i
  sync within %syncreg.i, label %if.then90.critedge

set_color.exit.tfend:                             ; No predecessors!
  call void @llvm.taskframe.end(token %tf.i)
  br label %for.inc

if.then90.critedge:                               ; preds = %pfor.inc.i
  call void @llvm.taskframe.end(token %tf.i)
  br label %for.inc

for.inc:                                          ; preds = %if.then90.critedge, %set_color.exit.tfend
  br label %for.cond79

pfor.inc:                                         ; preds = %for.cond.cleanup82, %for.cond
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.inc
  br label %for.cond

pfor.body125:                                     ; No predecessors!
  br label %for.cond127

for.cond127:                                      ; preds = %for.cond127, %pfor.body125
  br label %for.cond127
}

; CHECK: define ptr @render()

; CHECK: entry:
; CHECK: br label %for.cond79

; CHECK: for.cond79:
; CHECK: br label %for.cond79

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave() #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #4

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.stackrestore(ptr) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #5

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #5

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #5

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.experimental.noalias.scope.decl(metadata) #6

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #4

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.end(token) #4

; uselistorder directives
uselistorder ptr @llvm.syncregion.start, { 2, 1, 0 }

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nosync nounwind willreturn }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #4 = { nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #6 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
