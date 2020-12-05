; RUN: opt < %s -analyze -tapir-race-detect -evaluate-aa-metadata 2>&1 | FileCheck %s
; RUN: opt < %s -passes='print<race-detect>' -aa-pipeline=default -evaluate-aa-metadata -disable-output 2>&1 | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.__cilkrts_hyperobject_base.23.67.122.133.144 = type { %struct.cilk_c_monoid.22.66.121.132.143, i32, i32, i64 }
%struct.cilk_c_monoid.22.66.121.132.143 = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, {}*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }
%struct.IntersectionEventList.27.71.126.137.148 = type { %struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147* }
%struct.IntersectionEventNode.26.70.125.136.147 = type { %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146*, i32, %struct.IntersectionEventNode.26.70.125.136.147* }
%struct.Line.25.69.124.135.146 = type { %struct.Vec.24.68.123.134.145, %struct.Vec.24.68.123.134.145, %struct.Vec.24.68.123.134.145, i32, double, double, double, double, double, i32 }
%struct.Vec.24.68.123.134.145 = type { double, double }
%struct.CollisionWorld.30.74.129.140.151 = type { %struct.Line.25.69.124.135.146**, %struct.Line.25.69.124.135.146*, i32, i32, i32, %struct.QuadTree.29.73.128.139.150*, i32, i32 }
%struct.QuadTree.29.73.128.139.150 = type { %struct.Boundary.28.72.127.138.149, %struct.Boundary.28.72.127.138.149, i32, %struct.QuadTree.29.73.128.139.150*, [4 x %struct.QuadTree.29.73.128.139.150*], [350 x %struct.Line.25.69.124.135.146*], i32 }
%struct.Boundary.28.72.127.138.149 = type { double, double, double, double }
%struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153 = type { %struct.__cilkrts_hyperobject_base.23.67.122.133.144, [8 x i8], i32, [60 x i8] }
%struct.IEL_Reducer.31.75.130.141.152 = type { %struct.__cilkrts_hyperobject_base.23.67.122.133.144, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }

@intersectionEventListR = external dso_local global { { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }, align 64
@.str = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.1 = external dso_local unnamed_addr constant [17 x i8], align 1
@__PRETTY_FUNCTION__.CollisionWorld_new = external dso_local unnamed_addr constant [55 x i8], align 1
@__const.CollisionWorld_detectIntersection.numLineLineCollisions = external dso_local unnamed_addr constant { { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], i32, [60 x i8] }, align 64
@.str.2 = external dso_local unnamed_addr constant [25 x i8], align 1
@__PRETTY_FUNCTION__.CollisionWorld_collisionSolver = external dso_local unnamed_addr constant [88 x i8], align 1
@.str.3 = external dso_local unnamed_addr constant [108 x i8], align 1

declare dso_local void @IEL_Reduce(i8*, i8*, i8*) #0

declare dso_local void @IEL_Identity(i8*, i8*) #0

declare dso_local void @IEL_Destroy(i8*, i8*) #0

declare dso_local i8* @__cilkrts_hyper_alloc(%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64) #0

declare dso_local void @__cilkrts_hyper_dealloc(%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*) #0

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local %struct.CollisionWorld.30.74.129.140.151* @CollisionWorld_new(i32) local_unnamed_addr #1

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @malloc(i64) local_unnamed_addr #4

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc void @boundary_make(%struct.Boundary.28.72.127.138.149* noalias sret, double, double, double) unnamed_addr #5

declare dso_local %struct.QuadTree.29.73.128.139.150* @quadtree_new(%struct.Boundary.28.72.127.138.149* byval(%struct.Boundary.28.72.127.138.149) align 8, %struct.QuadTree.29.73.128.139.150*) local_unnamed_addr #0

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @CollisionWorld_delete(%struct.CollisionWorld.30.74.129.140.151*) local_unnamed_addr #1

; Function Attrs: nounwind
declare dso_local void @free(i8* nocapture) local_unnamed_addr #6

declare dso_local void @quadtree_delete(%struct.QuadTree.29.73.128.139.150*) local_unnamed_addr #0

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local i32 @CollisionWorld_getNumOfLines(%struct.CollisionWorld.30.74.129.140.151*) local_unnamed_addr #5

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @CollisionWorld_addOldLine(%struct.CollisionWorld.30.74.129.140.151*, %struct.Line.25.69.124.135.146*) local_unnamed_addr #1

declare dso_local zeroext i1 @quadtree_addLine(%struct.QuadTree.29.73.128.139.150*, %struct.Line.25.69.124.135.146*) local_unnamed_addr #0

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @CollisionWorld_addLines(%struct.CollisionWorld.30.74.129.140.151*, i32) local_unnamed_addr #1

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local %struct.Line.25.69.124.135.146* @CollisionWorld_getLine(%struct.CollisionWorld.30.74.129.140.151*, i32) local_unnamed_addr #1

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @CollisionWorld_updateLines(%struct.CollisionWorld.30.74.129.140.151*) local_unnamed_addr #1

; Function Attrs: nounwind sanitize_cilk uwtable
define dso_local void @CollisionWorld_detectIntersection(%struct.CollisionWorld.30.74.129.140.151* %collisionWorld) local_unnamed_addr #1 {
entry:
  %numLineLineCollisions = alloca %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153, align 64
  %syncreg = call token @llvm.syncregion.start()
  call void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base.23.67.122.133.144* getelementptr inbounds (%struct.IEL_Reducer.31.75.130.141.152, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), i32 0, i32 0))
  %0 = bitcast %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153* %numLineLineCollisions to i8*
  call void @llvm.lifetime.start.p0i8(i64 128, i8* %0) #8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 64 %0, i8* align 64 bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], i32, [60 x i8] }* @__const.CollisionWorld_detectIntersection.numLineLineCollisions to i8*), i64 128, i1 false)
  %__cilkrts_hyperbase = getelementptr inbounds %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153, %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153* %numLineLineCollisions, i32 0, i32 0
  call void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base.23.67.122.133.144* %__cilkrts_hyperbase)
  %numOfLines = getelementptr inbounds %struct.CollisionWorld.30.74.129.140.151, %struct.CollisionWorld.30.74.129.140.151* %collisionWorld, i32 0, i32 2
  %1 = load i32, i32* %numOfLines, align 8, !tbaa !2
  %cmp = icmp slt i32 0, %1
  br i1 %cmp, label %pfor.ph, label %cleanup32

pfor.ph:                                          ; preds = %entry
  %lines = getelementptr inbounds %struct.CollisionWorld.30.74.129.140.151, %struct.CollisionWorld.30.74.129.140.151* %collisionWorld, i32 0, i32 0
  %qt = getelementptr inbounds %struct.CollisionWorld.30.74.129.140.151, %struct.CollisionWorld.30.74.129.140.151* %collisionWorld, i32 0, i32 5
  %lines24 = getelementptr inbounds %struct.CollisionWorld.30.74.129.140.151, %struct.CollisionWorld.30.74.129.140.151* %collisionWorld, i32 0, i32 0
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.ph
  %__begin.0 = phi i32 [ 0, %pfor.ph ], [ %inc27, %pfor.inc ]
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %add3 = add nsw i32 %__begin.0, 1
  %idxprom = sext i32 %__begin.0 to i64
  br label %for.cond

for.cond:                                         ; preds = %cleanup, %pfor.body
  %j.0 = phi i32 [ %add3, %pfor.body ], [ %inc22, %cleanup ]
  %2 = load i32, i32* %numOfLines, align 8, !tbaa !2
  %cmp5 = icmp ult i32 %j.0, %2
  br i1 %cmp5, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  %3 = load %struct.QuadTree.29.73.128.139.150*, %struct.QuadTree.29.73.128.139.150** %qt, align 8, !tbaa !8
  %4 = load %struct.Line.25.69.124.135.146**, %struct.Line.25.69.124.135.146*** %lines24, align 8, !tbaa !9
  %idxprom25 = sext i32 %__begin.0 to i64
  %arrayidx26 = getelementptr inbounds %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146** %4, i64 %idxprom25
  %5 = load %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146** %arrayidx26, align 8, !tbaa !10
  call void @quadtree_detectLineCollision(%struct.QuadTree.29.73.128.139.150* %3, %struct.Line.25.69.124.135.146* %5, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153* %numLineLineCollisions)
  reattach within %syncreg, label %pfor.inc

; CHECK: I = call void @quadtree_detectLineCollision(%struct.QuadTree.29.73.128.139.150* %3, %struct.Line.25.69.124.135.146* %5, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153* %numLineLineCollisions)
; CHECK: Loc = %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*)
; CHECK-NEXT: OperandNum = 2

for.body:                                         ; preds = %for.cond
  %6 = load %struct.Line.25.69.124.135.146**, %struct.Line.25.69.124.135.146*** %lines, align 8, !tbaa !9
  %arrayidx = getelementptr inbounds %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146** %6, i64 %idxprom
  %7 = load %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146** %arrayidx, align 8, !tbaa !10
  %idxprom8 = sext i32 %j.0 to i64
  %arrayidx9 = getelementptr inbounds %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146** %6, i64 %idxprom8
  %8 = load %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146** %arrayidx9, align 8, !tbaa !10
  %call = call fastcc zeroext i1 @quick_intersection_detection(%struct.Line.25.69.124.135.146* %7, %struct.Line.25.69.124.135.146* %8)
  br i1 %call, label %if.end, label %cleanup

if.end:                                           ; preds = %for.body
  %call10 = call fastcc i32 @compareLines(%struct.Line.25.69.124.135.146* %7, %struct.Line.25.69.124.135.146* %8)
  %cmp11 = icmp sge i32 %call10, 0
  %spec.select = select i1 %cmp11, %struct.Line.25.69.124.135.146* %8, %struct.Line.25.69.124.135.146* %7
  %spec.select1 = select i1 %cmp11, %struct.Line.25.69.124.135.146* %7, %struct.Line.25.69.124.135.146* %8
  %call14 = call i32 @intersect(%struct.Line.25.69.124.135.146* %spec.select, %struct.Line.25.69.124.135.146* %spec.select1)
  %cmp15 = icmp ne i32 %call14, 0
  br i1 %cmp15, label %if.then16, label %cleanup

if.then16:                                        ; preds = %if.end
  %call17 = call strand_noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base.23.67.122.133.144* getelementptr inbounds (%struct.IEL_Reducer.31.75.130.141.152, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), i32 0, i32 0)) #9
  %9 = bitcast i8* %call17 to %struct.IntersectionEventList.27.71.126.137.148*
  call void @IntersectionEventList_appendNode(%struct.IntersectionEventList.27.71.126.137.148* %9, %struct.Line.25.69.124.135.146* %spec.select, %struct.Line.25.69.124.135.146* %spec.select1, i32 %call14)
  %call19 = call strand_noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base.23.67.122.133.144* %__cilkrts_hyperbase) #9
  %10 = bitcast i8* %call19 to i32*
  %11 = load i32, i32* %10, align 4, !tbaa !11
  %inc = add i32 %11, 1
  store i32 %inc, i32* %10, align 4, !tbaa !11
  br label %cleanup

cleanup:                                          ; preds = %if.then16, %if.end, %for.body
  %inc22 = add nsw i32 %j.0, 1
  br label %for.cond

pfor.inc:                                         ; preds = %for.cond.cleanup, %pfor.cond
  %inc27 = add nsw i32 %__begin.0, 1
  %cmp28 = icmp slt i32 %inc27, %1
  br i1 %cmp28, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !12

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup32

cleanup32:                                        ; preds = %pfor.cond.cleanup, %entry
  %qt34 = getelementptr inbounds %struct.CollisionWorld.30.74.129.140.151, %struct.CollisionWorld.30.74.129.140.151* %collisionWorld, i32 0, i32 5
  %12 = load %struct.QuadTree.29.73.128.139.150*, %struct.QuadTree.29.73.128.139.150** %qt34, align 8, !tbaa !8
  call void @quadtree_detectIntersection(%struct.QuadTree.29.73.128.139.150* %12, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153* %numLineLineCollisions)
  %value = getelementptr inbounds %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153, %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153* %numLineLineCollisions, i32 0, i32 2
  %13 = load i32, i32* %value, align 64, !tbaa !14
  %numLineLineCollisions35 = getelementptr inbounds %struct.CollisionWorld.30.74.129.140.151, %struct.CollisionWorld.30.74.129.140.151* %collisionWorld, i32 0, i32 7
  %14 = load i32, i32* %numLineLineCollisions35, align 4, !tbaa !19
  %add36 = add i32 %14, %13
  store i32 %add36, i32* %numLineLineCollisions35, align 4, !tbaa !19
  call void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base.23.67.122.133.144* %__cilkrts_hyperbase)
  %15 = load %struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147** getelementptr inbounds (%struct.IEL_Reducer.31.75.130.141.152, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), i32 0, i32 2, i32 0), align 64, !tbaa !20
  br label %while.cond

while.cond:                                       ; preds = %if.end49, %cleanup32
  %startNode.0 = phi %struct.IntersectionEventNode.26.70.125.136.147* [ %15, %cleanup32 ], [ %18, %if.end49 ]
  %cmp38 = icmp ne %struct.IntersectionEventNode.26.70.125.136.147* %startNode.0, null
  br i1 %cmp38, label %while.body, label %while.end51

while.body:                                       ; preds = %while.cond
  %next = getelementptr inbounds %struct.IntersectionEventNode.26.70.125.136.147, %struct.IntersectionEventNode.26.70.125.136.147* %startNode.0, i32 0, i32 3
  %16 = load %struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147** %next, align 8, !tbaa !23
  br label %while.cond39

while.cond39:                                     ; preds = %while.body41, %while.body
  %minNode.0 = phi %struct.IntersectionEventNode.26.70.125.136.147* [ %startNode.0, %while.body ], [ %spec.select2, %while.body41 ]
  %curNode.0 = phi %struct.IntersectionEventNode.26.70.125.136.147* [ %16, %while.body ], [ %17, %while.body41 ]
  %cmp40 = icmp ne %struct.IntersectionEventNode.26.70.125.136.147* %curNode.0, null
  br i1 %cmp40, label %while.body41, label %while.end

while.body41:                                     ; preds = %while.cond39
  %call42 = call i32 @IntersectionEventNode_compareData(%struct.IntersectionEventNode.26.70.125.136.147* %curNode.0, %struct.IntersectionEventNode.26.70.125.136.147* %minNode.0)
  %cmp43 = icmp slt i32 %call42, 0
  %spec.select2 = select i1 %cmp43, %struct.IntersectionEventNode.26.70.125.136.147* %curNode.0, %struct.IntersectionEventNode.26.70.125.136.147* %minNode.0
  %next46 = getelementptr inbounds %struct.IntersectionEventNode.26.70.125.136.147, %struct.IntersectionEventNode.26.70.125.136.147* %curNode.0, i32 0, i32 3
  %17 = load %struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147** %next46, align 8, !tbaa !23
  br label %while.cond39

while.end:                                        ; preds = %while.cond39
  %minNode.0.lcssa = phi %struct.IntersectionEventNode.26.70.125.136.147* [ %minNode.0, %while.cond39 ]
  %cmp47 = icmp ne %struct.IntersectionEventNode.26.70.125.136.147* %minNode.0.lcssa, %startNode.0
  br i1 %cmp47, label %if.then48, label %if.end49

if.then48:                                        ; preds = %while.end
  call void @IntersectionEventNode_swapData(%struct.IntersectionEventNode.26.70.125.136.147* %minNode.0.lcssa, %struct.IntersectionEventNode.26.70.125.136.147* %startNode.0)
  br label %if.end49

if.end49:                                         ; preds = %if.then48, %while.end
  %18 = load %struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147** %next, align 8, !tbaa !23
  br label %while.cond

while.end51:                                      ; preds = %while.cond
  %19 = load %struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147** getelementptr inbounds (%struct.IEL_Reducer.31.75.130.141.152, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), i32 0, i32 2, i32 0), align 64, !tbaa !20
  br label %while.cond53

while.cond53:                                     ; preds = %while.body55, %while.end51
  %curNode52.0 = phi %struct.IntersectionEventNode.26.70.125.136.147* [ %19, %while.end51 ], [ %23, %while.body55 ]
  %cmp54 = icmp ne %struct.IntersectionEventNode.26.70.125.136.147* %curNode52.0, null
  br i1 %cmp54, label %while.body55, label %while.end60

while.body55:                                     ; preds = %while.cond53
  %l156 = getelementptr inbounds %struct.IntersectionEventNode.26.70.125.136.147, %struct.IntersectionEventNode.26.70.125.136.147* %curNode52.0, i32 0, i32 0
  %20 = load %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146** %l156, align 8, !tbaa !25
  %l257 = getelementptr inbounds %struct.IntersectionEventNode.26.70.125.136.147, %struct.IntersectionEventNode.26.70.125.136.147* %curNode52.0, i32 0, i32 1
  %21 = load %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146** %l257, align 8, !tbaa !26
  %intersectionType58 = getelementptr inbounds %struct.IntersectionEventNode.26.70.125.136.147, %struct.IntersectionEventNode.26.70.125.136.147* %curNode52.0, i32 0, i32 2
  %22 = load i32, i32* %intersectionType58, align 8, !tbaa !27
  call void @CollisionWorld_collisionSolver(%struct.CollisionWorld.30.74.129.140.151* %collisionWorld, %struct.Line.25.69.124.135.146* %20, %struct.Line.25.69.124.135.146* %21, i32 %22)
  %next59 = getelementptr inbounds %struct.IntersectionEventNode.26.70.125.136.147, %struct.IntersectionEventNode.26.70.125.136.147* %curNode52.0, i32 0, i32 3
  %23 = load %struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147** %next59, align 8, !tbaa !23
  br label %while.cond53

while.end60:                                      ; preds = %while.cond53
  call void @IntersectionEventList_deleteNodes(%struct.IntersectionEventList.27.71.126.137.148* getelementptr inbounds (%struct.IEL_Reducer.31.75.130.141.152, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), i32 0, i32 2))
  call void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base.23.67.122.133.144* getelementptr inbounds (%struct.IEL_Reducer.31.75.130.141.152, %struct.IEL_Reducer.31.75.130.141.152* bitcast ({ { { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i64)*, void (%struct.__cilkrts_hyperobject_base.23.67.122.133.144*, i8*)* }, i32, i32, i64 }, [8 x i8], %struct.IntersectionEventList.27.71.126.137.148, [48 x i8] }* @intersectionEventListR to %struct.IEL_Reducer.31.75.130.141.152*), i32 0, i32 0))
  call void @llvm.lifetime.end.p0i8(i64 128, i8* %0) #8
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @CollisionWorld_updatePosition(%struct.CollisionWorld.30.74.129.140.151*) local_unnamed_addr #1

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @CollisionWorld_lineWallCollision(%struct.CollisionWorld.30.74.129.140.151*) local_unnamed_addr #1

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc void @line_update(%struct.Line.25.69.124.135.146*) unnamed_addr #5

declare dso_local void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base.23.67.122.133.144*) local_unnamed_addr #0

declare dso_local void @cilk_c_reducer_opadd_reduce_unsigned(i8*, i8*, i8*) #0

declare dso_local void @cilk_c_reducer_opadd_identity_unsigned(i8*, i8*) #0

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc zeroext i1 @quick_intersection_detection(%struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146*) unnamed_addr #5

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc i32 @compareLines(%struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146*) unnamed_addr #5

declare dso_local i32 @intersect(%struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146*) local_unnamed_addr #0

declare dso_local void @IntersectionEventList_appendNode(%struct.IntersectionEventList.27.71.126.137.148*, %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146*, i32) local_unnamed_addr #0

; Function Attrs: nounwind readonly strand_pure
declare dso_local strand_noalias i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base.23.67.122.133.144*) local_unnamed_addr #7

declare dso_local void @quadtree_detectLineCollision(%struct.QuadTree.29.73.128.139.150*, %struct.Line.25.69.124.135.146*, %struct.IEL_Reducer.31.75.130.141.152*, %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153*) local_unnamed_addr #0

declare dso_local void @quadtree_detectIntersection(%struct.QuadTree.29.73.128.139.150*, %struct.IEL_Reducer.31.75.130.141.152*, %struct.cilk_c_reducer_opadd_unsigned.32.76.131.142.153*) local_unnamed_addr #0

declare dso_local void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base.23.67.122.133.144*) local_unnamed_addr #0

declare dso_local i32 @IntersectionEventNode_compareData(%struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147*) local_unnamed_addr #0

declare dso_local void @IntersectionEventNode_swapData(%struct.IntersectionEventNode.26.70.125.136.147*, %struct.IntersectionEventNode.26.70.125.136.147*) local_unnamed_addr #0

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @CollisionWorld_collisionSolver(%struct.CollisionWorld.30.74.129.140.151*, %struct.Line.25.69.124.135.146*, %struct.Line.25.69.124.135.146*, i32) local_unnamed_addr #1

declare dso_local void @IntersectionEventList_deleteNodes(%struct.IntersectionEventList.27.71.126.137.148*) local_unnamed_addr #0

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local i32 @CollisionWorld_getNumLineWallCollisions(%struct.CollisionWorld.30.74.129.140.151*) local_unnamed_addr #1

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local i32 @CollisionWorld_getNumLineLineCollisions(%struct.CollisionWorld.30.74.129.140.151*) local_unnamed_addr #1

declare dso_local { double, double } @getIntersectionPoint(double, double, double, double, double, double, double, double) local_unnamed_addr #0

declare dso_local double @Vec_length(double, double) local_unnamed_addr #0

declare dso_local { double, double } @Vec_subtract(double, double, double, double) local_unnamed_addr #0

declare dso_local { double, double } @Vec_multiply(double, double, double) local_unnamed_addr #0

declare dso_local { double, double } @Vec_normalize(double, double) local_unnamed_addr #0

declare dso_local { double, double } @Vec_makeFromLine(%struct.Line.25.69.124.135.146* byval(%struct.Line.25.69.124.135.146) align 8) local_unnamed_addr #0

declare dso_local { double, double } @Vec_orthogonal(double, double) local_unnamed_addr #0

declare dso_local double @Vec_dotProduct(double, double, double, double) local_unnamed_addr #0

declare dso_local { double, double } @Vec_add(double, double, double, double) local_unnamed_addr #0

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #1 = { nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #2 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #5 = { inlinehint nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #6 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #7 = { nounwind readonly strand_pure "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #8 = { nounwind }
attributes #9 = { nounwind readonly strand_pure }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 496e6fe856f27dcf0c54f67024b3e85421b1b3a4)"}
!2 = !{!3, !7, i64 16}
!3 = !{!"CollisionWorld", !4, i64 0, !4, i64 8, !7, i64 16, !7, i64 20, !7, i64 24, !4, i64 32, !7, i64 40, !7, i64 44}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!"int", !5, i64 0}
!8 = !{!3, !4, i64 32}
!9 = !{!3, !4, i64 0}
!10 = !{!4, !4, i64 0}
!11 = !{!7, !7, i64 0}
!12 = distinct !{!12, !13}
!13 = !{!"tapir.loop.spawn.strategy", i32 1}
!14 = !{!15, !7, i64 64}
!15 = !{!"", !16, i64 0, !7, i64 64}
!16 = !{!"__cilkrts_hyperobject_base", !17, i64 0, !7, i64 40, !7, i64 44, !18, i64 48}
!17 = !{!"cilk_c_monoid", !4, i64 0, !4, i64 8, !4, i64 16, !4, i64 24, !4, i64 32}
!18 = !{!"long", !5, i64 0}
!19 = !{!3, !7, i64 44}
!20 = !{!21, !4, i64 64}
!21 = !{!"", !16, i64 0, !22, i64 64}
!22 = !{!"IntersectionEventList", !4, i64 0, !4, i64 8}
!23 = !{!24, !4, i64 24}
!24 = !{!"IntersectionEventNode", !4, i64 0, !4, i64 8, !5, i64 16, !4, i64 24}
!25 = !{!24, !4, i64 0}
!26 = !{!24, !4, i64 8}
!27 = !{!24, !5, i64 16}
