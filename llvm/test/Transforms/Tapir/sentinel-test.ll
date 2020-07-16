; RUN: opt < %s -instcombine -S -o - | FileCheck %s
; RUN: opt < %s -passes='instcombine' -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.vertexSubsetData = type <{ i32*, i8*, i64, i64, i8, [7 x i8] }>
%"class.std::tuple" = type { %"struct.std::_Tuple_impl" }
%"struct.std::_Tuple_impl" = type { %"struct.std::_Head_base.18" }
%"struct.std::_Head_base.18" = type { i8 }
%class.anon.31 = type { %"class.std::tuple"* }
%struct.BFS_F = type { i64* }
%struct.symmetricVertex = type <{ i32*, i32, [4 x i8] }>

$_ZN19decode_uncompressed21decodeInNghBreakEarlyI15symmetricVertex5BFS_FZ15get_emdense_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_16vertexSubsetDataIS5_EEEvPS7_lRT2_RT0_RT1_b = comdat any

; Function Attrs: inlinehint uwtable
define dso_local void @_ZN19decode_uncompressed21decodeInNghBreakEarlyI15symmetricVertex5BFS_FZ15get_emdense_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_16vertexSubsetDataIS5_EEEvPS7_lRT2_RT0_RT1_b(%struct.symmetricVertex* %v, i64 %v_id, %struct.vertexSubsetData* dereferenceable(40) %vertexSubset, %struct.BFS_F* dereferenceable(8) %f, %class.anon.31* dereferenceable(8) %g, i1 zeroext %parallel) local_unnamed_addr #9 comdat personality i32 (...)* @__gxx_personality_v0 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %degree.i = getelementptr inbounds %struct.symmetricVertex, %struct.symmetricVertex* %v, i64 0, i32 1
  %0 = load i32, i32* %degree.i, align 8, !tbaa !395
  %tobool.not = xor i1 %parallel, true
  %cmp = icmp ult i32 %0, 1000
  %or.cond = or i1 %cmp, %tobool.not
  %conv = zext i32 %0 to i64
  br i1 %or.cond, label %for.cond.preheader, label %pfor.cond.preheader

pfor.cond.preheader:                              ; preds = %entry
  %neighbors.i = getelementptr inbounds %struct.symmetricVertex, %struct.symmetricVertex* %v, i64 0, i32 0
  %1 = load i32*, i32** %neighbors.i, align 8, !tbaa !397
  %d.i = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %vertexSubset, i64 0, i32 1
  %2 = load i8*, i8** %d.i, align 8, !tbaa !93
  br label %pfor.cond

for.cond.preheader:                               ; preds = %entry
  %cmp166 = icmp eq i32 %0, 0
  br i1 %cmp166, label %if.end39, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %for.cond.preheader
  %neighbors.i12 = getelementptr inbounds %struct.symmetricVertex, %struct.symmetricVertex* %v, i64 0, i32 0
  %3 = load i32*, i32** %neighbors.i12, align 8, !tbaa !397
  %4 = load i32, i32* %3, align 4, !tbaa !13
  %d.i8 = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %vertexSubset, i64 0, i32 1
  %5 = load i8*, i8** %d.i8, align 8, !tbaa !93
  %idxprom.i9 = zext i32 %4 to i64
  %arrayidx.i10 = getelementptr inbounds i8, i8* %5, i64 %idxprom.i9
  %6 = load i8, i8* %arrayidx.i10, align 1, !tbaa !56, !range !66
  %tobool.i11 = icmp eq i8 %6, 0
  tail call void @llvm.assume(i1 %tobool.i11)
  unreachable

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc
  %__begin.0 = phi i64 [ %inc32, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  detach within %syncreg, label %if.end31, label %pfor.inc

if.end31:                                         ; preds = %pfor.cond
  %arrayidx.i3 = getelementptr inbounds i32, i32* %1, i64 %__begin.0
  %7 = load i32, i32* %arrayidx.i3, align 4, !tbaa !13
  %idxprom.i1 = zext i32 %7 to i64
  %arrayidx.i = getelementptr inbounds i8, i8* %2, i64 %idxprom.i1
  %8 = load i8, i8* %arrayidx.i, align 1, !tbaa !56, !range !66
  %tobool.i = icmp eq i8 %8, 0
  tail call void @llvm.assume(i1 %tobool.i)
  reattach within %syncreg, label %pfor.inc

; CHECK: if.end31:
; CHECK: tail call void @llvm.assume(i1 %tobool.i)
; CHECK-NEXT: reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %if.end31, %pfor.cond
  %inc32 = add nuw nsw i64 %__begin.0, 1
  %exitcond = icmp eq i64 %inc32, %conv
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !485

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  tail call void @llvm.sync.unwind(token %syncreg)
  ret void

if.end39:                                         ; preds = %for.cond.preheader
  ret void
}

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #6

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #12

; Function Attrs: nounwind
declare void @llvm.assume(i1) #26

!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!"bool", !5, i64 0}
!9 = !{!"int", !5, i64 0}
!13 = !{!9, !9, i64 0}
!18 = !{!"any pointer", !5, i64 0}
!22 = !{!"long", !5, i64 0}
!24 = !{!"tapir.loop.spawn.strategy", i32 1}
!56 = !{!7, !7, i64 0}
!66 = !{i8 0, i8 2}
!93 = !{!94, !18, i64 8}
!94 = !{!"_ZTS16vertexSubsetDataIN4pbbs5emptyEE", !18, i64 0, !18, i64 8, !22, i64 16, !22, i64 24, !7, i64 32}
!395 = !{!396, !9, i64 8}
!396 = !{!"_ZTS15symmetricVertex", !18, i64 0, !9, i64 8}
!397 = !{!396, !18, i64 0}
!485 = distinct !{!485, !24}
