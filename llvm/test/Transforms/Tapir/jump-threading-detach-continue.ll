; Check that jump-threading through two blocks does not disrupt Tapir
; CFG structures.
;
; RUN: opt < %s -jump-threading -S -o - | FileCheck %s
; RUN: opt < %s -passes='jump-threading' -S -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.IntersectionEventList = type { %struct.IntersectionEventNode*, %struct.IntersectionEventNode*, i64 }
%struct.IntersectionEventNode = type { %struct.Line*, %struct.Line*, i32, %struct.IntersectionEventNode* }
%struct.Line = type { %struct.Vec, %struct.Vec, double, i8, i8, double, double, double, double, %struct.Vec, %struct.Vec, i32, i32 }
%struct.Vec = type { double, double }
%struct.QuadNode = type { %struct.Vec, double, double, %struct.QuadNode*, %struct.QuadNode*, %struct.QuadNode*, %struct.QuadNode*, %struct.Line**, i32, double }
%struct.IntersectionEventListReducer = type { %struct.__cilkrts_hyperobject_base, [8 x i8], %struct.IntersectionEventList, [40 x i8] }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i32, i32, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base*, i64)*, void (%struct.__cilkrts_hyperobject_base*, i8*)* }

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #10

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #9

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #9

declare dso_local void @QuadNode_addInNodeIntersections(%struct.QuadNode* nocapture readonly %quadnode, %struct.IntersectionEventListReducer* %intersectionEventList) local_unnamed_addr #2

declare dso_local void @QuadNode_lineAddDescendantIntersections(%struct.Line* %line, %struct.QuadNode* nocapture readonly %quadnode, %struct.IntersectionEventListReducer* %intersectionEventList) local_unnamed_addr #2

; Function Attrs: nounwind uwtable
define dso_local void @QuadNode_addIntersections(%struct.QuadNode* nocapture readonly %quadnode, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %depth) local_unnamed_addr #2 {
entry:
  %syncreg.i1 = tail call token @llvm.syncregion.start()
  %syncreg = call token @llvm.syncregion.start()
  %cmp = icmp slt i32 %depth, 4
  br i1 %cmp, label %if.then.tf, label %if.else

if.then.tf:                                       ; preds = %entry
  detach within %syncreg, label %det.achd, label %det.cont.tf

det.achd:                                         ; preds = %if.then.tf
  call void @QuadNode_addInNodeIntersections(%struct.QuadNode* %quadnode, %struct.IntersectionEventListReducer* %intersectionEventList)
  reattach within %syncreg, label %det.cont.tf

det.cont.tf:                                      ; preds = %det.achd, %if.then.tf
  detach within %syncreg, label %det.achd1, label %if.end

det.achd1:                                        ; preds = %det.cont.tf
  br label %det.achd1.tf

det.achd1.tf:                                     ; preds = %det.achd1
  %tf.i = call token @llvm.taskframe.create()
  %syncreg.i = call token @llvm.syncregion.start() #11
  %swChild.i = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 4
  %0 = load %struct.QuadNode*, %struct.QuadNode** %swChild.i, align 8, !tbaa !25
  %cmp.i = icmp eq %struct.QuadNode* %0, null
  br i1 %cmp.i, label %QuadNode_addDescendantIntersections.exit, label %if.end.i

if.end.i:                                         ; preds = %det.achd1.tf
  %numLines.i = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 8
  %1 = load i32, i32* %numLines.i, align 8, !tbaa !22
  %cmp1.i = icmp sgt i32 %1, 0
  br i1 %cmp1.i, label %pfor.cond.preheader.i, label %QuadNode_addDescendantIntersections.exit

pfor.cond.preheader.i:                            ; preds = %if.end.i
  %containedLines.i = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 7
  %nwChild.i = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 3
  %neChild.i = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 5
  %seChild.i = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 6
  %wide.trip.count.i = zext i32 %1 to i64
  br label %pfor.cond.i

pfor.cond.i:                                      ; preds = %pfor.inc.i, %pfor.cond.preheader.i
  %indvars.iv.i = phi i64 [ 0, %pfor.cond.preheader.i ], [ %indvars.iv.next.i, %pfor.inc.i ]
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  detach within %syncreg.i, label %pfor.body.i, label %pfor.inc.i

pfor.body.i:                                      ; preds = %pfor.cond.i
  %2 = load %struct.Line**, %struct.Line*** %containedLines.i, align 8, !tbaa !21
  %arrayidx.i = getelementptr inbounds %struct.Line*, %struct.Line** %2, i64 %indvars.iv.i
  %3 = load %struct.Line*, %struct.Line** %arrayidx.i, align 8, !tbaa !29
  %4 = load %struct.QuadNode*, %struct.QuadNode** %swChild.i, align 8, !tbaa !25
  call void @QuadNode_lineAddDescendantIntersections(%struct.Line* %3, %struct.QuadNode* %4, %struct.IntersectionEventListReducer* %intersectionEventList) #11
  %5 = load %struct.QuadNode*, %struct.QuadNode** %nwChild.i, align 8, !tbaa !23
  call void @QuadNode_lineAddDescendantIntersections(%struct.Line* %3, %struct.QuadNode* %5, %struct.IntersectionEventListReducer* %intersectionEventList) #11
  %6 = load %struct.QuadNode*, %struct.QuadNode** %neChild.i, align 8, !tbaa !24
  call void @QuadNode_lineAddDescendantIntersections(%struct.Line* %3, %struct.QuadNode* %6, %struct.IntersectionEventListReducer* %intersectionEventList) #11
  %7 = load %struct.QuadNode*, %struct.QuadNode** %seChild.i, align 8, !tbaa !26
  call void @QuadNode_lineAddDescendantIntersections(%struct.Line* %3, %struct.QuadNode* %7, %struct.IntersectionEventListReducer* %intersectionEventList) #11
  reattach within %syncreg.i, label %pfor.inc.i

pfor.inc.i:                                       ; preds = %pfor.body.i, %pfor.cond.i
  %exitcond.not.i = icmp eq i64 %indvars.iv.next.i, %wide.trip.count.i
  br i1 %exitcond.not.i, label %pfor.cond.cleanup.i, label %pfor.cond.i, !llvm.loop !41

pfor.cond.cleanup.i:                              ; preds = %pfor.inc.i
  sync within %syncreg.i, label %QuadNode_addDescendantIntersections.exit

QuadNode_addDescendantIntersections.exit:         ; preds = %det.achd1.tf, %if.end.i, %pfor.cond.cleanup.i
  call void @llvm.taskframe.end(token %tf.i)
  br label %QuadNode_addDescendantIntersections.exit.tfend

QuadNode_addDescendantIntersections.exit.tfend:   ; preds = %QuadNode_addDescendantIntersections.exit
  reattach within %syncreg, label %if.end

if.else:                                          ; preds = %entry
  call void @QuadNode_addInNodeIntersections(%struct.QuadNode* %quadnode, %struct.IntersectionEventListReducer* %intersectionEventList)
  %swChild.i2 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 4
  %8 = load %struct.QuadNode*, %struct.QuadNode** %swChild.i2, align 8, !tbaa !25
  %cmp.i3 = icmp eq %struct.QuadNode* %8, null
  br i1 %cmp.i3, label %QuadNode_addDescendantIntersections.exit21, label %if.end.i6

if.end.i6:                                        ; preds = %if.else
  %numLines.i4 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 8
  %9 = load i32, i32* %numLines.i4, align 8, !tbaa !22
  %cmp1.i5 = icmp sgt i32 %9, 0
  br i1 %cmp1.i5, label %pfor.cond.preheader.i12, label %QuadNode_addDescendantIntersections.exit21

pfor.cond.preheader.i12:                          ; preds = %if.end.i6
  %containedLines.i7 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 7
  %nwChild.i8 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 3
  %neChild.i9 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 5
  %seChild.i10 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 6
  %wide.trip.count.i11 = zext i32 %9 to i64
  br label %pfor.cond.i15

pfor.cond.i15:                                    ; preds = %pfor.inc.i19, %pfor.cond.preheader.i12
  %indvars.iv.i13 = phi i64 [ 0, %pfor.cond.preheader.i12 ], [ %indvars.iv.next.i14, %pfor.inc.i19 ]
  %indvars.iv.next.i14 = add nuw nsw i64 %indvars.iv.i13, 1
  detach within %syncreg.i1, label %pfor.body.i17, label %pfor.inc.i19

pfor.body.i17:                                    ; preds = %pfor.cond.i15
  %10 = load %struct.Line**, %struct.Line*** %containedLines.i7, align 8, !tbaa !21
  %arrayidx.i16 = getelementptr inbounds %struct.Line*, %struct.Line** %10, i64 %indvars.iv.i13
  %11 = load %struct.Line*, %struct.Line** %arrayidx.i16, align 8, !tbaa !29
  %12 = load %struct.QuadNode*, %struct.QuadNode** %swChild.i2, align 8, !tbaa !25
  call void @QuadNode_lineAddDescendantIntersections(%struct.Line* %11, %struct.QuadNode* %12, %struct.IntersectionEventListReducer* %intersectionEventList) #11
  %13 = load %struct.QuadNode*, %struct.QuadNode** %nwChild.i8, align 8, !tbaa !23
  call void @QuadNode_lineAddDescendantIntersections(%struct.Line* %11, %struct.QuadNode* %13, %struct.IntersectionEventListReducer* %intersectionEventList) #11
  %14 = load %struct.QuadNode*, %struct.QuadNode** %neChild.i9, align 8, !tbaa !24
  call void @QuadNode_lineAddDescendantIntersections(%struct.Line* %11, %struct.QuadNode* %14, %struct.IntersectionEventListReducer* %intersectionEventList) #11
  %15 = load %struct.QuadNode*, %struct.QuadNode** %seChild.i10, align 8, !tbaa !26
  call void @QuadNode_lineAddDescendantIntersections(%struct.Line* %11, %struct.QuadNode* %15, %struct.IntersectionEventListReducer* %intersectionEventList) #11
  reattach within %syncreg.i1, label %pfor.inc.i19

pfor.inc.i19:                                     ; preds = %pfor.body.i17, %pfor.cond.i15
  %exitcond.not.i18 = icmp eq i64 %indvars.iv.next.i14, %wide.trip.count.i11
  br i1 %exitcond.not.i18, label %pfor.cond.cleanup.i20, label %pfor.cond.i15, !llvm.loop !41

pfor.cond.cleanup.i20:                            ; preds = %pfor.inc.i19
  sync within %syncreg.i1, label %QuadNode_addDescendantIntersections.exit21

QuadNode_addDescendantIntersections.exit21:       ; preds = %if.else, %if.end.i6, %pfor.cond.cleanup.i20
  br label %if.end

if.end:                                           ; preds = %QuadNode_addDescendantIntersections.exit21, %QuadNode_addDescendantIntersections.exit.tfend, %det.cont.tf
  %nwChild = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 3
  %16 = load %struct.QuadNode*, %struct.QuadNode** %nwChild, align 8, !tbaa !23
  %cmp3.not = icmp eq %struct.QuadNode* %16, null
  br i1 %cmp3.not, label %if.end27, label %if.then4

if.then4:                                         ; preds = %if.end
  %add = add nsw i32 %depth, 1
  br i1 %cmp, label %if.then6.tf, label %if.else17

if.then6.tf:                                      ; preds = %if.then4
  detach within %syncreg, label %det.achd8, label %det.cont9.tf

det.achd8:                                        ; preds = %if.then6.tf
  call void @QuadNode_addIntersections(%struct.QuadNode* nonnull %16, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %add)
  reattach within %syncreg, label %det.cont9.tf

det.cont9.tf:                                     ; preds = %det.achd8, %if.then6.tf
  %neChild = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 5
  %17 = load %struct.QuadNode*, %struct.QuadNode** %neChild, align 8, !tbaa !24
  detach within %syncreg, label %det.achd11, label %det.cont12.tf

det.achd11:                                       ; preds = %det.cont9.tf
  call void @QuadNode_addIntersections(%struct.QuadNode* %17, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %add)
  reattach within %syncreg, label %det.cont12.tf

det.cont12.tf:                                    ; preds = %det.achd11, %det.cont9.tf
  %swChild = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 4
  %18 = load %struct.QuadNode*, %struct.QuadNode** %swChild, align 8, !tbaa !25
  detach within %syncreg, label %det.achd14, label %det.cont15

det.achd14:                                       ; preds = %det.cont12.tf
  call void @QuadNode_addIntersections(%struct.QuadNode* %18, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %add)
  reattach within %syncreg, label %det.cont15

det.cont15:                                       ; preds = %det.achd14, %det.cont12.tf
  %seChild = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 6
  %19 = load %struct.QuadNode*, %struct.QuadNode** %seChild, align 8, !tbaa !26
  call void @QuadNode_addIntersections(%struct.QuadNode* %19, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %add)
  sync within %syncreg, label %if.end27

if.else17:                                        ; preds = %if.then4
  call void @QuadNode_addIntersections(%struct.QuadNode* nonnull %16, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %add)
  %neChild20 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 5
  %20 = load %struct.QuadNode*, %struct.QuadNode** %neChild20, align 8, !tbaa !24
  call void @QuadNode_addIntersections(%struct.QuadNode* %20, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %add)
  %swChild22 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 4
  %21 = load %struct.QuadNode*, %struct.QuadNode** %swChild22, align 8, !tbaa !25
  call void @QuadNode_addIntersections(%struct.QuadNode* %21, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %add)
  %seChild24 = getelementptr inbounds %struct.QuadNode, %struct.QuadNode* %quadnode, i64 0, i32 6
  %22 = load %struct.QuadNode*, %struct.QuadNode** %seChild24, align 8, !tbaa !26
  call void @QuadNode_addIntersections(%struct.QuadNode* %22, %struct.IntersectionEventListReducer* %intersectionEventList, i32 %add)
  br label %if.end27

if.end27:                                         ; preds = %if.else17, %det.cont15, %if.end
  sync within %syncreg, label %sync.continue28

sync.continue28:                                  ; preds = %if.end27
  ret void
}

; CHECK: if.end27:
; CHECK-NEXT: sync within %syncreg, label %[[SYNC_CONT:.+]]
; CHECK: [[SYNC_CONT]]:
; CHECK: ret void

attributes #0 = { nofree norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nofree norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nofree nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { argmemonly norecurse nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nounwind readonly strand_pure "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { argmemonly nounwind willreturn }
attributes #10 = { argmemonly nounwind willreturn writeonly }
attributes #11 = { nounwind }
attributes #12 = { nounwind readonly strand_pure }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 11.1.0 (git@github.com:OpenCilk/opencilk-project.git 7908b67cf1c0d74716d64a5c4f6288a54ce85320)"}
!2 = !{!3, !4, i64 0}
!3 = !{!"IntersectionEventList", !4, i64 0, !4, i64 8, !7, i64 16}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!"long", !5, i64 0}
!8 = !{!3, !7, i64 16}
!9 = !{!3, !4, i64 8}
!10 = !{!11, !4, i64 24}
!11 = !{!"IntersectionEventNode", !4, i64 0, !4, i64 8, !5, i64 16, !4, i64 24}
!12 = !{i64 0, i64 8, !13, i64 8, i64 8, !13}
!13 = !{!14, !14, i64 0}
!14 = !{!"double", !5, i64 0}
!15 = !{!16, !14, i64 16}
!16 = !{!"QuadNode", !17, i64 0, !14, i64 16, !14, i64 24, !4, i64 32, !4, i64 40, !4, i64 48, !4, i64 56, !4, i64 64, !18, i64 72, !14, i64 80}
!17 = !{!"Vec", !14, i64 0, !14, i64 8}
!18 = !{!"int", !5, i64 0}
!19 = !{!16, !14, i64 24}
!20 = !{!16, !14, i64 80}
!21 = !{!16, !4, i64 64}
!22 = !{!16, !18, i64 72}
!23 = !{!16, !4, i64 32}
!24 = !{!16, !4, i64 48}
!25 = !{!16, !4, i64 40}
!26 = !{!16, !4, i64 56}
!27 = !{!16, !14, i64 0}
!28 = !{!16, !14, i64 8}
!29 = !{!4, !4, i64 0}
!30 = distinct !{!30, !31}
!31 = !{!"llvm.loop.unroll.disable"}
!32 = !{!33, !14, i64 48}
!33 = !{!"Line", !17, i64 0, !17, i64 16, !14, i64 32, !34, i64 40, !34, i64 41, !14, i64 48, !14, i64 56, !14, i64 64, !14, i64 72, !17, i64 80, !17, i64 96, !5, i64 112, !18, i64 116}
!34 = !{!"_Bool", !5, i64 0}
!35 = !{!33, !14, i64 64}
!36 = !{!33, !14, i64 72}
!37 = !{!33, !14, i64 56}
!38 = distinct !{!38, !31}
!39 = !{!33, !18, i64 116}
!40 = distinct !{!40, !31}
!41 = distinct !{!41, !31, !42}
!42 = !{!"llvm.loop.from.tapir.loop"}
!43 = distinct !{!43, !44, !31, !45}
!44 = !{!"tapir.loop.spawn.strategy", i32 1}
!45 = !{!"tapir.loop.grainsize", i32 1}
!46 = distinct !{!46, !42, !31}
!47 = distinct !{!47, !31}
!48 = distinct !{!48, !31, !42}
!49 = distinct !{!49, !44, !31, !45}
!50 = distinct !{!50, !42, !31}
!51 = distinct !{!51, !31, !42}
!52 = distinct !{!52, !44, !31, !45}
!53 = distinct !{!53, !42, !31}
