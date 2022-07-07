; Check that simple loop unswitching handles task-exit blocks in loops.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(function<eager-inv>(loop-mssa(simple-loop-unswitch<nontrivial;trivial>))))" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: inaccessiblememonly nounwind reducer_register willreturn
declare void @llvm.reducer.register.i64(i8*, i64, i8*, i8*, i8*) #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fmuladd.f64(double, double, double) #3

; Function Attrs: hyper_view inaccessiblememonly injective nounwind readonly strand_pure willreturn
declare i8* @llvm.hyper.lookup(i8*) #4

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #5

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #5

; Function Attrs: inaccessiblememonly nounwind reducer_unregister willreturn
declare void @llvm.reducer.unregister(i8*) #6

define i32 @main(i1 %cmp.i) personality i32 (...)* undef {
entry:
  %syncreg.i = tail call token @llvm.syncregion.start()
  br label %if.end10

if.end10:                                         ; preds = %entry
  br label %for.body.i

for.body.i:                                       ; preds = %for.body.i, %if.end10
  br i1 false, label %_ZN7cilkpub13DotMixGenericILi1ELi4EE9init_seedEm.exit, label %for.body.i

_ZN7cilkpub13DotMixGenericILi1ELi4EE9init_seedEm.exit: ; preds = %for.body.i
  br label %for.body.preheader

for.body.preheader:                               ; preds = %_ZN7cilkpub13DotMixGenericILi1ELi4EE9init_seedEm.exit
  %cmp.i1 = icmp sgt i64 0, 0
  br label %for.body

for.body:                                         ; preds = %_Z9pi_dprandl.exit, %for.body.preheader
  br i1 %cmp.i, label %pfor.cond.i.preheader, label %_Z9pi_dprandl.exit

pfor.cond.i.preheader:                            ; preds = %for.body
  br label %pfor.cond.i

pfor.cond.i:                                      ; preds = %pfor.inc.i, %pfor.cond.i.preheader
  detach within %syncreg.i, label %pfor.body.i, label %pfor.inc.i unwind label %lpad21.loopexit.i

pfor.body.i:                                      ; preds = %pfor.cond.i
  br label %invoke.cont.i

invoke.cont.i:                                    ; preds = %pfor.body.i
  br label %invoke.cont4.i

invoke.cont4.i:                                   ; preds = %invoke.cont.i
  %call7.i = invoke i64 undef()
          to label %invoke.cont6.i unwind label %lpad5.i

invoke.cont6.i:                                   ; preds = %invoke.cont4.i
  br label %if.end.i

lpad5.i:                                          ; preds = %invoke.cont4.i
  %0 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup18.i

if.end.i:                                         ; preds = %invoke.cont6.i
  reattach within %syncreg.i, label %pfor.inc.i

pfor.inc.i:                                       ; preds = %if.end.i, %pfor.cond.i
  br i1 false, label %pfor.cond.cleanup.i, label %pfor.cond.i

pfor.cond.cleanup.i:                              ; preds = %pfor.inc.i
  sync within none, label %sync.continue.i

ehcleanup18.i:                                    ; preds = %lpad5.i
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i, { i8*, i32 } zeroinitializer)
          to label %unreachable.i unwind label %lpad21.loopexit.i

lpad21.loopexit.i:                                ; preds = %ehcleanup18.i, %pfor.cond.i
  %lpad.loopexit.i = landingpad { i8*, i32 }
          cleanup
  ret i32 0

sync.continue.i:                                  ; preds = %pfor.cond.cleanup.i
  br label %_Z9pi_dprandl.exit

unreachable.i:                                    ; preds = %ehcleanup18.i
  unreachable

_Z9pi_dprandl.exit:                               ; preds = %sync.continue.i, %for.body
  br label %for.body
}

; CHECK: br i1 %cmp.i, label %for.body.preheader.split.us, label %for.body.preheader.split

; CHECK: for.body.preheader.split.us:
; CHECK-NEXT: br label %for.body.us

; CHECK: for.body.us:
; CHECK-NEXT: br label %pfor.cond.i.preheader.us

; CHECK: pfor.cond.i.preheader.us:
; CHECK-NEXT: br label %pfor.cond.i.us

; CHECK: pfor.cond.i.us:
; CHECK-NEXT: detach within %syncreg.i, label %pfor.body.i.us, label %pfor.inc.i.us unwind label %lpad21.loopexit.i.split.us

; CHECK: pfor.body.i.us:
; CHECK-NEXT: br label %invoke.cont.i.us

; CHECK: invoke.cont.i.us:
; CHECK-NEXT: br label %invoke.cont4.i.us

; CHECK: invoke.cont4.i.us:
; CHECK-NEXT: %call7.i.us = invoke i64 undef()
; CHECK-NEXT: to label %invoke.cont6.i.us unwind label %lpad5.i.us

; CHECK: lpad5.i.us:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: br label %ehcleanup18.i.us

; CHECK: ehcleanup18.i.us:
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i, { i8*, i32 } zeroinitializer)
; CHECK-NEXT: to label %unreachable.i unwind label %lpad21.loopexit.i.split.us

; CHECK: lpad21.loopexit.i.split.us:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: br label %lpad21.loopexit.i

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i64 @llvm.fshl.i64(i64, i64, i64) #3

attributes #0 = { argmemonly nofree nosync nounwind willreturn }
attributes #1 = { inaccessiblememonly nounwind reducer_register willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #4 = { hyper_view inaccessiblememonly injective nounwind readonly strand_pure willreturn }
attributes #5 = { argmemonly willreturn }
attributes #6 = { inaccessiblememonly nounwind reducer_unregister willreturn }
