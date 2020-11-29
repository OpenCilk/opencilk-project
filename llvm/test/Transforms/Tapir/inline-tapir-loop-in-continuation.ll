; RUN: opt < %s -inline -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Graph = type { i32, i32, i32*, i32* }
%class.Pennant = type { i32*, %class.Pennant*, %class.Pennant* }
%class.Bag_reducer = type { %"class.cilk::reducer" }
%"class.cilk::reducer" = type { %"class.cilk::internal::reducer_content.base", i8 }
%"class.cilk::internal::reducer_content.base" = type <{ %"class.cilk::internal::reducer_base", [127 x i8] }>
%"class.cilk::internal::reducer_base" = type { %struct.__cilkrts_hyperobject_base, %"class.cilk::internal::storage_for_object", i8* }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i32, i32, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (i8*, i64)*, void (i8*, i8*)* }
%"class.cilk::internal::storage_for_object" = type { %"class.cilk::internal::aligned_storage" }
%"class.cilk::internal::aligned_storage" = type { [1 x i8] }
%class.Bag = type <{ i32, [4 x i8], %class.Pennant**, i32*, i32, [4 x i8] }>

$_ZNK5Graph17pbfs_walk_PennantEP7PennantIiEP11Bag_reducerIiEjPj = comdat any

$_ZN7PennantIiE7getLeftEv = comdat any

$_ZN7PennantIiE8getRightEv = comdat any

$_ZN7PennantIiE11getElementsEv = comdat any

; Function Attrs: inlinehint uwtable
define linkonce_odr dso_local void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiEP11Bag_reducerIiEjPj(%class.Graph* %this, %class.Pennant* %p, %class.Bag_reducer* %next, i32 %newdist, i32* %distances) local_unnamed_addr #0 comdat align 2 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg11 = call token @llvm.syncregion.start()
  %call = call %class.Pennant* @_ZN7PennantIiE7getLeftEv(%class.Pennant* %p)
  %cmp = icmp eq %class.Pennant* %call, null
  br i1 %cmp, label %if.end, label %if.then.tf

; CHECK: entry:
; CHECK-NOT: call token @llvm.taskframe.create
; CHECK: getelementptr
; CHECK-NEXT: load
; CHECK-NEXT: %cmp = icmp eq
; CHECK-NEXT: br i1 %cmp, label %if.end, label %if.then.tf

if.then.tf:                                       ; preds = %entry
  %call2 = call %class.Pennant* @_ZN7PennantIiE7getLeftEv(%class.Pennant* %p)
  detach within %syncreg, label %det.achd, label %if.end

; CHECK: if.then.tf:
; CHECK-NOT: call token @llvm.taskframe.create
; CHECK-NEXT: getelementptr
; CHECK-NEXT: load
; CHECK-NEXT: detach within %syncreg, label %det.achd, label %if.end

det.achd:                                         ; preds = %if.then.tf
  call void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiEP11Bag_reducerIiEjPj(%class.Graph* %this, %class.Pennant* %call2, %class.Bag_reducer* %next, i32 %newdist, i32* %distances)
  reattach within %syncreg, label %if.end

if.end:                                           ; preds = %det.achd, %if.then.tf, %entry
  %call3 = call %class.Pennant* @_ZN7PennantIiE8getRightEv(%class.Pennant* %p)
  %cmp4 = icmp eq %class.Pennant* %call3, null
  br i1 %cmp4, label %if.end9, label %if.then5.tf

; CHECK: if.end:
; CHECK-NOT: call token @llvm.taskframe.create
; CHECK-NEXT: getelementptr
; CHECK-NEXT: load
; CHECK-NEXT: %cmp4 = icmp eq
; CHECK-NEXT: br i1 %cmp4, label %if.end9, label %if.then5.tf

if.then5.tf:                                      ; preds = %if.end
  %call6 = call %class.Pennant* @_ZN7PennantIiE8getRightEv(%class.Pennant* %p)
  detach within %syncreg, label %det.achd7, label %if.end9

; CHECK: if.then5.tf:
; CHECK-NOT: call token @llvm.taskframe.create
; CHECK-NEXT: getelementptr
; CHECK-NEXT: load
; CHECK-NEXT: detach within %syncreg, label %det.achd7, label %if.end9

det.achd7:                                        ; preds = %if.then5.tf
  call void @_ZNK5Graph17pbfs_walk_PennantEP7PennantIiEP11Bag_reducerIiEjPj(%class.Graph* %this, %class.Pennant* %call6, %class.Bag_reducer* %next, i32 %newdist, i32* %distances)
  reattach within %syncreg, label %if.end9

if.end9:                                          ; preds = %det.achd7, %if.then5.tf, %if.end
  %call10 = call i32* @_ZN7PennantIiE11getElementsEv(%class.Pennant* %p)
  %nodes = getelementptr inbounds %class.Graph, %class.Graph* %this, i64 0, i32 2
  %edges = getelementptr inbounds %class.Graph, %class.Graph* %this, i64 0, i32 3
  br label %pfor.cond

; CHECK: if.end9:
; CHECK-NOT: call token @llvm.taskframe.create
; CHECK-NEXT: getelementptr
; CHECK-NEXT: load
; CHECK-NEXT: %nodes = getelementptr inbounds %class.Graph
; CHECK-NEXT: %edges = getelementptr inbounds %class.Graph
; CHECK-NEXT: br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %if.end9
  %indvars.iv = phi i64 [ %indvars.iv.next, %pfor.inc ], [ 0, %if.end9 ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %0 = shl nsw i64 %indvars.iv, 8
  detach within %syncreg11, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %add.ptr = getelementptr inbounds i32, i32* %call10, i64 %0
  %1 = load i32*, i32** %nodes, align 8, !tbaa !0
  %2 = load i32*, i32** %edges, align 8, !tbaa !6
  call fastcc void @_ZL14pbfs_proc_NodePKiiP11Bag_reducerIiEjPjS0_S0_(i32* %add.ptr, i32 256, %class.Bag_reducer* %next, i32 %newdist, i32* %distances, i32* %1, i32* %2)
  reattach within %syncreg11, label %pfor.inc

; CHECK: pfor.body:
; CHECK-NEXT: getelementptr
; CHECK-NEXT: load
; CHECK-NEXT: load
; CHECK-NOT: call fastcc void @_ZL14pbfs_proc_NodePKiiP11Bag_reducerIiEjPjS0_S0_
; CHECK: %[[TF:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: call token @llvm.syncregion.start
; CHECK: call {{.*}}%class.Bag* @_ZN11Bag_reducerIiE13get_referenceEv(
; CHECK: br label %for.body.i

; CHECK: _ZL14pbfs_proc_NodePKiiP11Bag_reducerIiEjPjS0_S0_.exit:
; CHECK-NEXT: call void @llvm.taskframe.end(token %[[TF]])
; CHECK: reattach within %syncreg11, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %exitcond = icmp eq i64 %indvars.iv.next, 8
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !7

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg11, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg11)
  %isnull = icmp eq %class.Pennant* %p, null
  br i1 %isnull, label %delete.end, label %delete.notnull

delete.notnull:                                   ; preds = %sync.continue
  call void @_ZN7PennantIiED2Ev(%class.Pennant* nonnull %p) #8
  %3 = bitcast %class.Pennant* %p to i8*
  call void @_ZdlPv(i8* %3) #9
  br label %delete.end

delete.end:                                       ; preds = %delete.notnull, %sync.continue
  sync within %syncreg, label %sync.continue17

sync.continue17:                                  ; preds = %delete.end
  call void @llvm.sync.unwind(token %syncreg)
  ret void
}

; Function Attrs: inlinehint uwtable
define internal fastcc void @_ZL14pbfs_proc_NodePKiiP11Bag_reducerIiEjPjS0_S0_(i32* nocapture readonly %n, i32 %fillSize, %class.Bag_reducer* %next, i32 %newdist, i32* nocapture %distances, i32* nocapture readonly %nodes, i32* nocapture readonly %edges) unnamed_addr #0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %call = call dereferenceable(32) %class.Bag* @_ZN11Bag_reducerIiE13get_referenceEv(%class.Bag_reducer* %next)
  %cmp86 = icmp sgt i32 %fillSize, 0
  br i1 %cmp86, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count94 = zext i32 %fillSize to i64
  br label %for.body

for.cond.cleanup:                                 ; preds = %if.end39, %entry
  ret void

for.body:                                         ; preds = %if.end39, %for.body.preheader
  %indvars.iv92 = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next93, %if.end39 ]
  %arrayidx = getelementptr inbounds i32, i32* %n, i64 %indvars.iv92
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !10
  %idxprom1 = sext i32 %0 to i64
  %arrayidx2 = getelementptr inbounds i32, i32* %nodes, i64 %idxprom1
  %1 = load i32, i32* %arrayidx2, align 4, !tbaa !10
  %add = add nsw i32 %0, 1
  %idxprom5 = sext i32 %add to i64
  %arrayidx6 = getelementptr inbounds i32, i32* %nodes, i64 %idxprom5
  %2 = load i32, i32* %arrayidx6, align 4, !tbaa !10
  %sub = sub i32 %2, %1
  %cmp7 = icmp slt i32 %sub, 128
  %cmp984 = icmp sgt i32 %2, %1
  br i1 %cmp7, label %for.cond8.preheader, label %if.else

for.cond8.preheader:                              ; preds = %for.body
  br i1 %cmp984, label %for.body11.preheader, label %if.end39

for.body11.preheader:                             ; preds = %for.cond8.preheader
  %3 = sext i32 %1 to i64
  br label %for.body11

for.body11:                                       ; preds = %if.end, %for.body11.preheader
  %indvars.iv89 = phi i64 [ %3, %for.body11.preheader ], [ %indvars.iv.next90, %if.end ]
  %arrayidx13 = getelementptr inbounds i32, i32* %edges, i64 %indvars.iv89
  %4 = load i32, i32* %arrayidx13, align 4, !tbaa !10
  %idxprom14 = sext i32 %4 to i64
  %arrayidx15 = getelementptr inbounds i32, i32* %distances, i64 %idxprom14
  %5 = load i32, i32* %arrayidx15, align 4, !tbaa !10
  %cmp16 = icmp ugt i32 %5, %newdist
  br i1 %cmp16, label %if.then17, label %if.end

if.then17:                                        ; preds = %for.body11
  call void @_ZN3BagIiE6insertEi(%class.Bag* nonnull %call, i32 %4)
  store i32 %newdist, i32* %arrayidx15, align 4, !tbaa !10
  br label %if.end

if.end:                                           ; preds = %if.then17, %for.body11
  %indvars.iv.next90 = add nsw i64 %indvars.iv89, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next90 to i32
  %exitcond91 = icmp eq i32 %2, %lftr.wideiv
  br i1 %exitcond91, label %if.end39, label %for.body11

if.else:                                          ; preds = %for.body
  br i1 %cmp984, label %pfor.cond.preheader, label %if.end39

pfor.cond.preheader:                              ; preds = %if.else
  %6 = sext i32 %1 to i64
  %wide.trip.count = zext i32 %sub to i64
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %indvars.iv = phi i64 [ 0, %pfor.cond.preheader ], [ %indvars.iv.next, %pfor.inc ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %7 = add nsw i64 %indvars.iv, %6
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %arrayidx28 = getelementptr inbounds i32, i32* %edges, i64 %7
  %8 = load i32, i32* %arrayidx28, align 4, !tbaa !10
  %idxprom29 = sext i32 %8 to i64
  %arrayidx30 = getelementptr inbounds i32, i32* %distances, i64 %idxprom29
  %9 = load i32, i32* %arrayidx30, align 4, !tbaa !10
  %cmp31 = icmp ugt i32 %9, %newdist
  br i1 %cmp31, label %if.then32, label %if.end35

if.then32:                                        ; preds = %pfor.body
  call void @_ZN11Bag_reducerIiE6insertEi(%class.Bag_reducer* %next, i32 %8)
  store i32 %newdist, i32* %arrayidx30, align 4, !tbaa !10
  br label %if.end35

if.end35:                                         ; preds = %if.then32, %pfor.body
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %if.end35, %pfor.cond
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !11

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg)
  br label %if.end39

if.end39:                                         ; preds = %sync.continue, %if.else, %if.end, %for.cond8.preheader
  %indvars.iv.next93 = add nuw nsw i64 %indvars.iv92, 1
  %exitcond95 = icmp eq i64 %indvars.iv.next93, %wide.trip.count94
  br i1 %exitcond95, label %for.cond.cleanup, label %for.body
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #2

; Function Attrs: inlinehint uwtable
declare dso_local dereferenceable(32) %class.Bag* @_ZN11Bag_reducerIiE13get_referenceEv(%class.Bag_reducer*) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN11Bag_reducerIiE6insertEi(%class.Bag_reducer*, i32) local_unnamed_addr #3

; Function Attrs: noinline uwtable
declare dso_local void @_ZN3BagIiE6insertEi(%class.Bag*, i32) local_unnamed_addr #4

; Function Attrs: inlinehint nounwind uwtable
define linkonce_odr dso_local %class.Pennant* @_ZN7PennantIiE7getLeftEv(%class.Pennant* %this) local_unnamed_addr #5 comdat align 2 {
entry:
  %l = getelementptr inbounds %class.Pennant, %class.Pennant* %this, i64 0, i32 1
  %0 = load %class.Pennant*, %class.Pennant** %l, align 8, !tbaa !13
  ret %class.Pennant* %0
}

; Function Attrs: inlinehint nounwind uwtable
define linkonce_odr dso_local %class.Pennant* @_ZN7PennantIiE8getRightEv(%class.Pennant* %this) local_unnamed_addr #5 comdat align 2 {
entry:
  %r = getelementptr inbounds %class.Pennant, %class.Pennant* %this, i64 0, i32 2
  %0 = load %class.Pennant*, %class.Pennant** %r, align 8, !tbaa !15
  ret %class.Pennant* %0
}

; Function Attrs: inlinehint nounwind uwtable
define linkonce_odr dso_local i32* @_ZN7PennantIiE11getElementsEv(%class.Pennant* %this) local_unnamed_addr #5 comdat align 2 {
entry:
  %els = getelementptr inbounds %class.Pennant, %class.Pennant* %this, i64 0, i32 0
  %0 = load i32*, i32** %els, align 8, !tbaa !16
  ret i32* %0
}

; Function Attrs: nounwind uwtable
declare dso_local void @_ZN7PennantIiED2Ev(%class.Pennant*) unnamed_addr #6

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #7

attributes #0 = { inlinehint uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly willreturn }
attributes #3 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { inlinehint nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nounwind }
attributes #9 = { builtin nounwind }

!0 = !{!1, !5, i64 8}
!1 = !{!"_ZTS5Graph", !2, i64 0, !2, i64 4, !5, i64 8, !5, i64 16}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
!5 = !{!"any pointer", !3, i64 0}
!6 = !{!1, !5, i64 16}
!7 = distinct !{!7, !8, !9}
!8 = !{!"tapir.loop.spawn.strategy", i32 1}
!9 = !{!"tapir.loop.grainsize", i32 1}
!10 = !{!2, !2, i64 0}
!11 = distinct !{!11, !8, !12}
!12 = !{!"tapir.loop.grainsize", i32 128}
!13 = !{!14, !5, i64 8}
!14 = !{!"_ZTS7PennantIiE", !5, i64 0, !5, i64 8, !5, i64 16}
!15 = !{!14, !5, i64 16}
!16 = !{!14, !5, i64 0}
