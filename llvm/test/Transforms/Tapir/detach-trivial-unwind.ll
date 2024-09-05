; Check that simplifycfg properly handles trivial detach-unwind blocks.
; Incrementally removing trivial detach-unwind blocks causes invoke
; instructions to be marked as nounwind calls, which breaks subsequent Tapir
; lowering that might reintroduce landingpads.
;
; RUN: opt < %s -passes="simplifycfg" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@threshold = dso_local local_unnamed_addr global i32 0, align 4
@_ZTIi = external constant ptr
@stdout = external local_unnamed_addr global ptr, align 8
@.str = private unnamed_addr constant [11 x i8] c"caught %d\0A\00", align 1
@.str.1 = private unnamed_addr constant [23 x i8] c"count=%d threshold=%d\0A\00", align 1
@.str.2 = private unnamed_addr constant [6 x i8] c"\0A%6d \00", align 1
@.str.3 = private unnamed_addr constant [3 x i8] c" .\00", align 1

; Function Attrs: mustprogress uwtable
define dso_local noundef i32 @_Z1fi(i32 noundef %i) local_unnamed_addr #0 {
entry:
  %0 = load i32, ptr @threshold, align 4, !tbaa !5
  %cmp = icmp eq i32 %0, %i
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %exception = tail call ptr @__cxa_allocate_exception(i64 4) #11
  store i32 0, ptr %exception, align 16, !tbaa !5
  tail call void @__cxa_throw(ptr nonnull %exception, ptr nonnull @_ZTIi, ptr null) #12
  unreachable

if.end:                                           ; preds = %entry
  ret i32 1
}

declare ptr @__cxa_allocate_exception(i64) local_unnamed_addr

declare void @__cxa_throw(ptr, ptr, ptr) local_unnamed_addr

; Function Attrs: mustprogress uwtable
define dso_local void @_Z4loopiPc(i32 noundef %n, ptr nocapture noundef writeonly %array) local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond.preheader, label %sync.continue21

pfor.cond.preheader:                              ; preds = %entry
  %wide.trip.count = zext nneg i32 %n to i64
  %0 = call i64 @llvm.tapir.loop.grainsize.i64(i64 %wide.trip.count)
  invoke fastcc void @_Z4loopiPc.outline_pfor.cond.ls1(i64 0, i64 %wide.trip.count, i64 %0, ptr %array)
          to label %pfor.cond.cleanup unwind label %lpad2.loopexit

pfor.cond:                                        ; preds = %pfor.inc
  %indvars.iv.next = add nuw nsw i64 %indvars.iv.next, 1
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc unwind label %lpad2.loopexit

pfor.body.entry:                                  ; preds = %pfor.cond
  %1 = load i32, ptr @threshold, align 4, !tbaa !5
  %2 = zext i32 %1 to i64
  %cmp.i = icmp eq i64 %indvars.iv.next, %2
  br i1 %cmp.i, label %if.then.i, label %invoke.cont

if.then.i:                                        ; preds = %pfor.body.entry
  %exception.i = tail call ptr @__cxa_allocate_exception(i64 4) #11
  store i32 0, ptr %exception.i, align 16, !tbaa !5
  invoke void @__cxa_throw(ptr nonnull %exception.i, ptr nonnull @_ZTIi, ptr null) #12
          to label %.noexc unwind label %lpad

.noexc:                                           ; preds = %if.then.i
  unreachable

invoke.cont:                                      ; preds = %pfor.body.entry
  %arrayidx = getelementptr inbounds i8, ptr %array, i64 %indvars.iv.next
  store i8 1, ptr %arrayidx, align 1, !tbaa !9
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %invoke.cont, %pfor.cond
  %exitcond.not = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !10

pfor.cond.cleanup:                                ; preds = %pfor.cond.preheader, %pfor.inc
  sync within %syncreg, label %sync.continue

lpad:                                             ; preds = %if.then.i
  %3 = landingpad { ptr, i32 }
          cleanup
  unreachable

lpad2.loopexit:                                   ; preds = %pfor.cond.preheader, %pfor.cond
  %lpad.loopexit = landingpad { ptr, i32 }
          cleanup
          catch ptr @_ZTIi
  br label %lpad2

lpad2.loopexit.split-lp:                          ; preds = %sync.continue
  %lpad.loopexit.split-lp = landingpad { ptr, i32 }
          cleanup
          catch ptr @_ZTIi
  br label %lpad2

lpad2:                                            ; preds = %lpad2.loopexit.split-lp, %lpad2.loopexit
  %lpad.phi = phi { ptr, i32 } [ %lpad.loopexit, %lpad2.loopexit ], [ %lpad.loopexit.split-lp, %lpad2.loopexit.split-lp ]
  %4 = extractvalue { ptr, i32 } %lpad.phi, 1
  %5 = tail call i32 @llvm.eh.typeid.for(ptr nonnull @_ZTIi) #11
  %matches = icmp eq i32 %4, %5
  br i1 %matches, label %catch, label %eh.resume

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %sync.continue21 unwind label %lpad2.loopexit.split-lp

catch:                                            ; preds = %lpad2
  %6 = extractvalue { ptr, i32 } %lpad.phi, 0
  %7 = tail call ptr @__cxa_begin_catch(ptr %6) #11
  %8 = load i32, ptr %7, align 4, !tbaa !5
  %9 = load ptr, ptr @stdout, align 8, !tbaa !14
  %call15 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %9, ptr noundef nonnull @.str, i32 noundef %8)
  tail call void @__cxa_end_catch() #11
  br label %sync.continue21

sync.continue21:                                  ; preds = %catch, %sync.continue, %entry
  ret void

eh.resume:                                        ; preds = %lpad2
  resume { ptr, i32 } %lpad.phi

unreachable:                                      ; No predecessors!
  unreachable
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #1

declare i32 @__gxx_personality_v0(...)

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #2

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #2

; Function Attrs: nounwind memory(none)
declare i32 @llvm.eh.typeid.for(ptr) #3

declare ptr @__cxa_begin_catch(ptr) local_unnamed_addr

; Function Attrs: nofree nounwind
declare noundef i32 @fprintf(ptr nocapture noundef, ptr nocapture noundef readonly, ...) local_unnamed_addr #4

declare void @__cxa_end_catch() local_unnamed_addr

; Function Attrs: mustprogress norecurse uwtable
define dso_local noundef i32 @main(i32 noundef %argc, ptr nocapture noundef readonly %argv) local_unnamed_addr #5 personality ptr @__gxx_personality_v0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp slt i32 %argc, 3
  br i1 %cmp, label %return, label %if.end

if.end:                                           ; preds = %entry
  %arrayidx = getelementptr inbounds ptr, ptr %argv, i64 1
  %0 = load ptr, ptr %arrayidx, align 8, !tbaa !14
  %call.i = tail call i64 @__isoc23_strtol(ptr noundef nonnull %0, ptr noundef null, i32 noundef 10) #11
  %conv.i = trunc i64 %call.i to i32
  %cmp1 = icmp slt i32 %conv.i, 1
  br i1 %cmp1, label %return, label %if.end3

if.end3:                                          ; preds = %if.end
  %arrayidx4 = getelementptr inbounds ptr, ptr %argv, i64 2
  %1 = load ptr, ptr %arrayidx4, align 8, !tbaa !14
  %call.i60 = tail call i64 @__isoc23_strtol(ptr noundef nonnull %1, ptr noundef null, i32 noundef 10) #11
  %conv.i61 = trunc i64 %call.i60 to i32
  store i32 %conv.i61, ptr @threshold, align 4, !tbaa !5
  %2 = tail call token @llvm.tapir.runtime.start()
  %3 = load ptr, ptr @stdout, align 8, !tbaa !14
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.end3
  %call6 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %3, ptr noundef nonnull @.str.1, i32 noundef %conv.i, i32 noundef %conv.i61)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.end3
  %4 = and i64 %call.i, 4294967295
  %5 = tail call ptr @llvm.stacksave.p0()
  %vla = alloca i8, i64 %4, align 16
  call void @llvm.memset.p0.i64(ptr nonnull align 16 %vla, i8 0, i64 %4, i1 false)
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %invoke.cont21 unwind label %lpad15

invoke.cont21:                                    ; preds = %sync.continue
  invoke void @_Z4loopiPc(i32 noundef %conv.i, ptr noundef nonnull %vla)
          to label %for.body.preheader unwind label %lpad15

for.body.preheader:                               ; preds = %invoke.cont21
  %smax = tail call i32 @llvm.smax.i32(i32 %conv.i, i32 1)
  %wide.trip.count = zext nneg i32 %smax to i64
  br label %for.body

for.cond.cleanup:                                 ; preds = %if.end29
  %6 = load ptr, ptr @stdout, align 8, !tbaa !14
  %call41 = tail call i32 @fputc(i32 noundef 10, ptr noundef %6)
  tail call void @llvm.stackrestore.p0(ptr %5)
  tail call void @llvm.tapir.runtime.end(token %2)
  br label %return

lpad15:                                           ; preds = %invoke.cont21, %sync.continue
  %7 = landingpad { ptr, i32 }
          cleanup
  tail call void @llvm.tapir.runtime.end(token %2)
  resume { ptr, i32 } %7

for.body:                                         ; preds = %if.end29, %for.body.preheader
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %if.end29 ]
  %rem65 = and i64 %indvars.iv, 63
  %cmp24 = icmp eq i64 %rem65, 0
  br i1 %cmp24, label %if.then25, label %if.end29

if.then25:                                        ; preds = %for.body
  %8 = load ptr, ptr @stdout, align 8, !tbaa !14
  %tobool.not = icmp eq i64 %indvars.iv, 0
  %idx.ext = zext i1 %tobool.not to i64
  %add.ptr = getelementptr inbounds i8, ptr @.str.2, i64 %idx.ext
  %9 = trunc i64 %indvars.iv to i32
  %call28 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %8, ptr noundef nonnull %add.ptr, i32 noundef %9)
  br label %if.end29

if.end29:                                         ; preds = %if.then25, %for.body
  %arrayidx30 = getelementptr inbounds i8, ptr %vla, i64 %indvars.iv
  %10 = load i8, ptr %arrayidx30, align 1, !tbaa !9
  %tobool31 = icmp ne i8 %10, 0
  %idxprom34 = zext i1 %tobool31 to i64
  %arrayidx35 = getelementptr inbounds [3 x i8], ptr @.str.3, i64 0, i64 %idxprom34
  %11 = load i8, ptr %arrayidx35, align 1, !tbaa !9
  %conv36 = sext i8 %11 to i32
  %12 = load ptr, ptr @stdout, align 8, !tbaa !14
  %call38 = tail call i32 @fputc(i32 noundef %conv36, ptr noundef %12)
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.not = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !16

return:                                           ; preds = %for.cond.cleanup, %if.end, %entry
  %retval.1 = phi i32 [ 1, %entry ], [ 0, %for.cond.cleanup ], [ 1, %if.end ]
  ret i32 %retval.1
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.tapir.runtime.start() #1

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave.p0() #6

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #7

; Function Attrs: nofree nounwind
declare noundef i32 @fputc(i32 noundef, ptr nocapture noundef) local_unnamed_addr #4

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.stackrestore.p0(ptr) #6

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.tapir.runtime.end(token) #1

; Function Attrs: nounwind
declare i64 @__isoc23_strtol(ptr noundef, ptr noundef, i32 noundef) local_unnamed_addr #8

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #9

; Function Attrs: nounwind speculatable willreturn memory(none)
declare i64 @llvm.tapir.loop.grainsize.i64(i64) #10

; Function Attrs: mustprogress uwtable
define internal fastcc void @_Z4loopiPc.outline_pfor.cond.ls1(i64 %indvars.iv.start.ls1, i64 %end.ls1, i64 %grainsize.ls1, ptr nocapture noundef writeonly align 1 %array.ls1) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
pfor.cond.preheader.ls1:
  %0 = tail call token @llvm.syncregion.start()
  br label %pfor.cond.preheader.ls1.dac.head

pfor.cond.preheader.ls1.dac.head:                 ; preds = %pfor.cond.preheader.ls1.dac.cont, %pfor.cond.preheader.ls1
  %indvars.iv.ls1.dac = phi i64 [ %indvars.iv.start.ls1, %pfor.cond.preheader.ls1 ], [ %miditer, %pfor.cond.preheader.ls1.dac.cont ]
  %itercount = sub i64 %end.ls1, %indvars.iv.ls1.dac
  %1 = icmp ugt i64 %itercount, %grainsize.ls1
  br i1 %1, label %2, label %3

2:                                                ; preds = %pfor.cond.preheader.ls1.dac.head
  %halfcount = lshr i64 %itercount, 1
  %miditer = add nuw nsw i64 %indvars.iv.ls1.dac, %halfcount
  detach within %0, label %pfor.cond.preheader.ls1.dac.detach, label %pfor.cond.preheader.ls1.dac.cont unwind label %lpad2.loopexit.ls1

pfor.cond.preheader.ls1.dac.detach:               ; preds = %2
  invoke fastcc void @_Z4loopiPc.outline_pfor.cond.ls1(i64 %indvars.iv.ls1.dac, i64 %miditer, i64 %grainsize.ls1, ptr %array.ls1)
          to label %pfor.cond.preheader.ls1.dac.detach.noexc unwind label %pfor.cond.preheader.ls1.dac.detach.unwind

pfor.cond.preheader.ls1.dac.detach.noexc:         ; preds = %pfor.cond.preheader.ls1.dac.detach
  reattach within %0, label %pfor.cond.preheader.ls1.dac.cont

pfor.cond.preheader.ls1.dac.cont:                 ; preds = %pfor.cond.preheader.ls1.dac.detach.noexc, %2
  br label %pfor.cond.preheader.ls1.dac.head

3:                                                ; preds = %pfor.cond.preheader.ls1.dac.head
  br label %pfor.cond.ls1

pfor.cond.ls1:                                    ; preds = %3, %pfor.inc.ls1
  %indvars.iv.ls1 = phi i64 [ %indvars.iv.ls1.dac, %3 ], [ %indvars.iv.next.ls1, %pfor.inc.ls1 ]
  %indvars.iv.next.ls1 = add nuw nsw i64 %indvars.iv.ls1, 1
  br label %pfor.body.entry.ls1

pfor.body.entry.ls1:                              ; preds = %pfor.cond.ls1
  %4 = load i32, ptr @threshold, align 4, !tbaa !5
  %5 = zext i32 %4 to i64
  %cmp.i.ls1 = icmp eq i64 %indvars.iv.ls1, %5
  br i1 %cmp.i.ls1, label %if.then.i.ls1, label %invoke.cont.ls1

invoke.cont.ls1:                                  ; preds = %pfor.body.entry.ls1
  %arrayidx.ls1 = getelementptr inbounds i8, ptr %array.ls1, i64 %indvars.iv.ls1
  store i8 1, ptr %arrayidx.ls1, align 1, !tbaa !9
  br label %pfor.inc.ls1

if.then.i.ls1:                                    ; preds = %pfor.body.entry.ls1
  %exception.i.ls1 = tail call ptr @__cxa_allocate_exception(i64 4) #11
  store i32 0, ptr %exception.i.ls1, align 16, !tbaa !5
  invoke void @__cxa_throw(ptr nonnull %exception.i.ls1, ptr nonnull @_ZTIi, ptr null) #12
          to label %.noexc.ls1 unwind label %lpad.ls1

lpad.ls1:                                         ; preds = %if.then.i.ls1
  %6 = landingpad { ptr, i32 }
          cleanup
  resume { ptr, i32 } %6

.noexc.ls1:                                       ; preds = %if.then.i.ls1
  unreachable

pfor.inc.ls1:                                     ; preds = %invoke.cont.ls1
  %exitcond.not.ls1 = icmp eq i64 %indvars.iv.next.ls1, %end.ls1
  br i1 %exitcond.not.ls1, label %pfor.cond.cleanup.ls1, label %pfor.cond.ls1, !llvm.loop !17

pfor.cond.cleanup.ls1:                            ; preds = %pfor.inc.ls1
  sync within %0, label %pfor.cond.cleanup.ls1.synced

pfor.cond.cleanup.ls1.synced:                     ; preds = %pfor.cond.cleanup.ls1
  invoke void @llvm.sync.unwind(token %0)
          to label %.noexc unwind label %lpad2.loopexit.ls1

.noexc:                                           ; preds = %pfor.cond.cleanup.ls1.synced
  ret void

lpad2.loopexit.ls1:                               ; preds = %pfor.cond.cleanup.ls1.synced, %2, %pfor.cond.preheader.ls1.dac.detach.unwind
  %lpadval = landingpad { ptr, i32 }
          cleanup
  resume { ptr, i32 } %lpadval

pfor.cond.preheader.ls1.dac.detach.unwind:        ; preds = %pfor.cond.preheader.ls1.dac.detach
  %7 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %0, { ptr, i32 } %7)
          to label %pfor.cond.preheader.ls1.dac.detach.unwind.unreachable unwind label %lpad2.loopexit.ls1

pfor.cond.preheader.ls1.dac.detach.unwind.unreachable: ; preds = %pfor.cond.preheader.ls1.dac.detach.unwind
  unreachable
}

; CHECK: define {{.*}}void @_Z4loopiPc.outline_pfor.cond.ls1(
; CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[DETACH_CONTINUE:.+]]
; CHECK-NOT: unwind

; CHECK: [[DETACHED]]:
; CHECK-NEXT: call {{.*}}void @_Z4loopiPc.outline_pfor.cond.ls1(
; Make sure there is no attribute on this call marking the call nounwind.
; CHECK-NOT: #{{[0-9]+}}
; CHECK-NEXT: reattach within %[[SYNCREG]], label %[[DETACH_CONTINUE]]

; CHECK-NOT: landingpad
; CHECK-NOT: invoke {{.*}}void @llvm.detached.rethrow

attributes #0 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { willreturn memory(argmem: readwrite) }
attributes #3 = { nounwind memory(none) }
attributes #4 = { nofree nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress norecurse uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nocallback nofree nosync nounwind willreturn }
attributes #7 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #8 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #10 = { nounwind speculatable willreturn memory(none) }
attributes #11 = { nounwind }
attributes #12 = { noreturn }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 18.1.8 (git@github.com:OpenCilk/opencilk-project.git 92be4f41e49d315a28c9cc6a6cbb3cfc1124958a)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = !{!7, !7, i64 0}
!10 = distinct !{!10, !11, !12, !13}
!11 = !{!"llvm.loop.mustprogress"}
!12 = !{!"llvm.loop.unroll.disable"}
!13 = !{!"tapir.loop.spawn.strategy", i32 0}
!14 = !{!15, !15, i64 0}
!15 = !{!"any pointer", !7, i64 0}
!16 = distinct !{!16, !11, !12}
!17 = distinct !{!17, !13}
