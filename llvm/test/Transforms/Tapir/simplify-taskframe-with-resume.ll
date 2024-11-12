; Check that taskframes using in taskframe.resume calls are properly simplified.
;
; RUN: opt < %s -passes="function<eager-inv>(task-simplify)" -S | FileCheck %s
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #0

; Function Attrs: nounwind reducer_register willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.reducer.register.i64(ptr, i64, ptr, ptr) #1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #2

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #3

; Function Attrs: hyper_view injective nounwind strand_pure willreturn memory(inaccessiblemem: read)
declare ptr @llvm.hyper.lookup.i64(ptr, i64, ptr, ptr) #4

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #3

; Function Attrs: nounwind reducer_unregister willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.reducer.unregister(ptr) #5

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #2

; CHECK: define void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiERH3BagIiEjPj()
; CHECK-NOT: %tf.i = tail call token @llvm.taskframe.create()
; CHECK-NOT: {{call|invoke}} void @llvm.taskframe.resume.sl_p0i32s(token

; Function Attrs: inlinehint mustprogress ssp uwtable(sync)
define void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiERH3BagIiEjPj() #6 personality ptr null {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %syncreg45 = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.tapir.runtime.start()
  detach within %syncreg45, label %pfor.body.entry.tf, label %pfor.inc unwind label %lpad59.loopexit

pfor.body.entry.tf:                               ; preds = %entry
  %tf.i = tail call token @llvm.taskframe.create()
  %syncreg.i = tail call token @llvm.syncregion.start()
  detach within %syncreg.i, label %pfor.cond.i.strpm.detachloop.entry, label %pfor.cond.cleanup.i unwind label %lpad4924.loopexit.strpm.detachloop.unwind

pfor.cond.i.strpm.detachloop.entry:               ; preds = %pfor.body.entry.tf
  %syncreg.i.strpm.detachloop = tail call token @llvm.syncregion.start()
  reattach within %syncreg.i, label %pfor.cond.cleanup.i

pfor.cond.cleanup.i:                              ; preds = %pfor.cond.i.strpm.detachloop.entry, %pfor.body.entry.tf
  sync within %syncreg.i, label %sync.continue.i

lpad4924.loopexit.strpm.detachloop.unwind:        ; preds = %pfor.body.entry.tf
  %lpad.strpm.detachloop.unwind = landingpad { ptr, i32 }
          cleanup
  call void @llvm.taskframe.resume.sl_p0i32s(token %tf.i, { ptr, i32 } %lpad.strpm.detachloop.unwind)
  unreachable

sync.continue.i:                                  ; preds = %pfor.cond.cleanup.i
  reattach within %syncreg45, label %pfor.inc

pfor.inc:                                         ; preds = %sync.continue.i, %entry
  sync within %syncreg45, label %sync.continue

lpad59.loopexit:                                  ; preds = %entry
  %lpad.loopexit28 = landingpad { ptr, i32 }
          cleanup
  ret void

sync.continue:                                    ; preds = %pfor.inc
  tail call void @llvm.tapir.runtime.end(token %0)
  ret void
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #2

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.resume.sl_p0i32s(token, { ptr, i32 }) #3

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #7

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) #8

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #9

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umax.i32(i32, i32) #9

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #10

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umin.i32(i32, i32) #9

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.end(token) #2

; uselistorder directives
uselistorder ptr null, { 1, 2, 0 }

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nounwind reducer_register willreturn memory(inaccessiblemem: readwrite) }
attributes #2 = { nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { willreturn memory(argmem: readwrite) }
attributes #4 = { hyper_view injective nounwind strand_pure willreturn memory(inaccessiblemem: read) }
attributes #5 = { nounwind reducer_unregister willreturn memory(inaccessiblemem: readwrite) }
attributes #6 = { inlinehint mustprogress ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+complxnum,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+jsconv,+lse,+neon,+pauth,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #7 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #8 = { nobuiltin allocsize(0) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+complxnum,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+jsconv,+lse,+neon,+pauth,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #9 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #10 = { nocallback nofree nounwind willreturn memory(argmem: write) }
