; RUN: opt < %s -csan -S -o - | FileCheck %s
; RUN: opt < %s -aa-pipeline=default -passes='cilksan' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.Line = type { %struct.Vec, %struct.Vec, %struct.Vec, i32, i32 }
%struct.Vec = type { double, double }
%struct.CollisionWorld = type { double, %struct.Line**, i32, i32, i32 }
%struct.IntersectionEventList = type { %struct.IntersectionEventNode*, %struct.IntersectionEventNode* }
%struct.IntersectionEventNode = type { %struct.Line*, %struct.Line*, i32, %struct.IntersectionEventNode* }

@comparisons = common dso_local local_unnamed_addr global i32 0, align 4

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind uwtable sanitize_cilk
define dso_local void @walkTree(%struct.CollisionWorld* %collisionWorld, %struct.IntersectionEventList* %eventList, i32* %myset, i32 %n, i32 %depth, double %xmin, double %xmax, double %ymin, double %ymax) local_unnamed_addr #2 {
entry:
  %sub_n = alloca [5 x i32], align 16
  %temp_lists = alloca [4 x %struct.IntersectionEventList], align 16
  %syncreg = tail call token @llvm.syncregion.start()
  %add = fadd double %xmin, %xmax
  %div = fmul double %add, 5.000000e-01
  %add1 = fadd double %ymin, %ymax
  %div2 = fmul double %add1, 5.000000e-01
  %0 = bitcast [5 x i32]* %sub_n to i8*
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %0) #4
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(20) %0, i8 0, i64 20, i1 false)
  %cmp = icmp sgt i32 %n, 10
  %cmp3 = icmp slt i32 %depth, 10
  %or.cond = and i1 %cmp, %cmp3
  br i1 %or.cond, label %for.body.lr.ph, label %if.end.thread

for.body.lr.ph:                                   ; preds = %entry
  %lines = getelementptr inbounds %struct.CollisionWorld, %struct.CollisionWorld* %collisionWorld, i64 0, i32 1
  %1 = load %struct.Line**, %struct.Line*** %lines, align 8, !tbaa !14
  %wide.trip.count283 = zext i32 %n to i64
  %arrayidx14 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 4
  %arrayidx14.1 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 3
  %arrayidx14.2 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 2
  %arrayidx14.3 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 1
  br label %for.body

for.body:                                         ; preds = %for.cond.cleanup11, %for.body.lr.ph
  %indvars.iv281 = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next282, %for.cond.cleanup11 ]
  %arrayidx = getelementptr inbounds i32, i32* %myset, i64 %indvars.iv281
  %2 = load i32, i32* %arrayidx, align 4, !tbaa !17
  %idxprom5 = sext i32 %2 to i64
  %arrayidx6 = getelementptr inbounds %struct.Line*, %struct.Line** %1, i64 %idxprom5
  %3 = load %struct.Line*, %struct.Line** %arrayidx6, align 8, !tbaa !18
  %x.i = getelementptr inbounds %struct.Line, %struct.Line* %3, i64 0, i32 0, i32 0
  %4 = load double, double* %x.i, align 8, !tbaa !2
  %x3.i = getelementptr inbounds %struct.Line, %struct.Line* %3, i64 0, i32 2, i32 0
  %5 = load double, double* %x3.i, align 8, !tbaa !9
  %add.i = fadd double %4, %5
  %cmp.i = fcmp olt double %4, %add.i
  %cond.i = select i1 %cmp.i, double %4, double %add.i
  %x11.i = getelementptr inbounds %struct.Line, %struct.Line* %3, i64 0, i32 1, i32 0
  %6 = load double, double* %x11.i, align 8, !tbaa !10
  %add16.i = fadd double %5, %6
  %cmp17.i = fcmp olt double %6, %add16.i
  %cond28.i = select i1 %cmp17.i, double %6, double %add16.i
  %cmp29.i = fcmp olt double %cond.i, %cond28.i
  br i1 %cmp29.i, label %cond.true30.i, label %cond.false50.i

cond.true30.i:                                    ; preds = %for.body
  br i1 %cmp.i, label %cond.end70.i, label %cond.false42.i

cond.false42.i:                                   ; preds = %cond.true30.i
  br label %cond.end70.i

cond.false50.i:                                   ; preds = %for.body
  br i1 %cmp17.i, label %cond.end70.i, label %cond.false62.i

cond.false62.i:                                   ; preds = %cond.false50.i
  br label %cond.end70.i

cond.end70.i:                                     ; preds = %cond.false62.i, %cond.false50.i, %cond.false42.i, %cond.true30.i
  %cond71.i = phi double [ %add.i, %cond.false42.i ], [ %4, %cond.true30.i ], [ %add16.i, %cond.false62.i ], [ %6, %cond.false50.i ]
  %y.i = getelementptr inbounds %struct.Line, %struct.Line* %3, i64 0, i32 0, i32 1
  %7 = load double, double* %y.i, align 8, !tbaa !11
  %y76.i = getelementptr inbounds %struct.Line, %struct.Line* %3, i64 0, i32 2, i32 1
  %8 = load double, double* %y76.i, align 8, !tbaa !12
  %add77.i = fadd double %7, %8
  %cmp78.i = fcmp olt double %7, %add77.i
  %cond89.i = select i1 %cmp78.i, double %7, double %add77.i
  %y91.i = getelementptr inbounds %struct.Line, %struct.Line* %3, i64 0, i32 1, i32 1
  %9 = load double, double* %y91.i, align 8, !tbaa !13
  %add96.i = fadd double %8, %9
  %cmp97.i = fcmp olt double %9, %add96.i
  %cond108.i = select i1 %cmp97.i, double %9, double %add96.i
  %cmp109.i = fcmp olt double %cond89.i, %cond108.i
  br i1 %cmp109.i, label %cond.true110.i, label %cond.false130.i

cond.true110.i:                                   ; preds = %cond.end70.i
  br i1 %cmp78.i, label %cond.end150.i, label %cond.false122.i

cond.false122.i:                                  ; preds = %cond.true110.i
  br label %cond.end150.i

cond.false130.i:                                  ; preds = %cond.end70.i
  br i1 %cmp97.i, label %cond.end150.i, label %cond.false142.i

cond.false142.i:                                  ; preds = %cond.false130.i
  br label %cond.end150.i

cond.end150.i:                                    ; preds = %cond.false142.i, %cond.false130.i, %cond.false122.i, %cond.true110.i
  %cond151.i = phi double [ %add77.i, %cond.false122.i ], [ %7, %cond.true110.i ], [ %add96.i, %cond.false142.i ], [ %9, %cond.false130.i ]
  %cmp159.i = fcmp ogt double %4, %add.i
  %cond170.i = select i1 %cmp159.i, double %4, double %add.i
  %cmp178.i = fcmp ogt double %6, %add16.i
  %cond189.i = select i1 %cmp178.i, double %6, double %add16.i
  %cmp190.i = fcmp ogt double %cond170.i, %cond189.i
  br i1 %cmp190.i, label %cond.true191.i, label %cond.false211.i

cond.true191.i:                                   ; preds = %cond.end150.i
  br i1 %cmp159.i, label %cond.end231.i, label %cond.false203.i

cond.false203.i:                                  ; preds = %cond.true191.i
  br label %cond.end231.i

cond.false211.i:                                  ; preds = %cond.end150.i
  br i1 %cmp178.i, label %cond.end231.i, label %cond.false223.i

cond.false223.i:                                  ; preds = %cond.false211.i
  br label %cond.end231.i

cond.end231.i:                                    ; preds = %cond.false223.i, %cond.false211.i, %cond.false203.i, %cond.true191.i
  %cond232.i = phi double [ %add.i, %cond.false203.i ], [ %4, %cond.true191.i ], [ %add16.i, %cond.false223.i ], [ %6, %cond.false211.i ]
  %cmp240.i = fcmp ogt double %7, %add77.i
  %cond251.i = select i1 %cmp240.i, double %7, double %add77.i
  %cmp259.i = fcmp ogt double %9, %add96.i
  %cond270.i = select i1 %cmp259.i, double %9, double %add96.i
  %cmp271.i = fcmp ogt double %cond251.i, %cond270.i
  br i1 %cmp271.i, label %cond.true272.i, label %cond.false292.i

cond.true272.i:                                   ; preds = %cond.end231.i
  br i1 %cmp240.i, label %cond.end312.i, label %cond.false284.i

cond.false284.i:                                  ; preds = %cond.true272.i
  br label %cond.end312.i

cond.false292.i:                                  ; preds = %cond.end231.i
  br i1 %cmp259.i, label %cond.end312.i, label %cond.false304.i

cond.false304.i:                                  ; preds = %cond.false292.i
  br label %cond.end312.i

cond.end312.i:                                    ; preds = %cond.false304.i, %cond.false292.i, %cond.false284.i, %cond.true272.i
  %cond313.i = phi double [ %add77.i, %cond.false284.i ], [ %7, %cond.true272.i ], [ %add96.i, %cond.false304.i ], [ %9, %cond.false292.i ]
  %cmp314.i = fcmp oge double %cond71.i, %div
  %cmp314.not.i = xor i1 %cmp314.i, true
  %cmp315.i = fcmp ult double %cond151.i, %div2
  %or.cond.i = or i1 %cmp315.i, %cmp314.not.i
  br i1 %or.cond.i, label %if.end.i, label %for.body12

if.end.i:                                         ; preds = %cond.end312.i
  %cmp316.i = fcmp olt double %cond232.i, %div
  %cmp316.not.i = xor i1 %cmp316.i, true
  %or.cond438.i = or i1 %cmp315.i, %cmp316.not.i
  br i1 %or.cond438.i, label %if.end320.i, label %for.body12

if.end320.i:                                      ; preds = %if.end.i
  %cmp323.i = fcmp olt double %cond313.i, %div2
  %or.cond439.i = and i1 %cmp316.i, %cmp323.i
  br i1 %or.cond439.i, label %for.body12, label %if.end325.i

if.end325.i:                                      ; preds = %if.end320.i
  %or.cond440.i = and i1 %cmp314.i, %cmp323.i
  br i1 %or.cond440.i, label %getQuadrant.exit.for.cond.cleanup11_crit_edge, label %for.body12

getQuadrant.exit.for.cond.cleanup11_crit_edge:    ; preds = %if.end325.i
  %sext = shl i64 %indvars.iv281, 32
  %.pre289 = ashr exact i64 %sext, 32
  br label %for.cond.cleanup11

for.cond.cleanup11:                               ; preds = %for.body12.1, %for.body12.2, %for.body12.3, %for.body12, %getQuadrant.exit.for.cond.cleanup11_crit_edge
  %call258293 = phi i32 [ 4, %getQuadrant.exit.for.cond.cleanup11_crit_edge ], [ %call258.ph, %for.body12 ], [ %call258.ph, %for.body12.3 ], [ %call258.ph, %for.body12.2 ], [ %call258.ph, %for.body12.1 ]
  %idxprom22.pre-phi = phi i64 [ %.pre289, %getQuadrant.exit.for.cond.cleanup11_crit_edge ], [ %idxprom15, %for.body12 ], [ %idxprom15.1, %for.body12.1 ], [ %idxprom15.2, %for.body12.2 ], [ %idxprom15.3, %for.body12.3 ]
  %arrayidx23 = getelementptr inbounds i32, i32* %myset, i64 %idxprom22.pre-phi
  store i32 %2, i32* %arrayidx23, align 4, !tbaa !17
  %idxprom24 = zext i32 %call258293 to i64
  %arrayidx25 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 %idxprom24
  %10 = load i32, i32* %arrayidx25, align 4, !tbaa !17
  %inc = add nsw i32 %10, 1
  store i32 %inc, i32* %arrayidx25, align 4, !tbaa !17
  %indvars.iv.next282 = add nuw nsw i64 %indvars.iv281, 1
  %exitcond284 = icmp eq i64 %indvars.iv.next282, %wide.trip.count283
  br i1 %exitcond284, label %if.end, label %for.body

for.body12:                                       ; preds = %if.end320.i, %if.end.i, %cond.end312.i, %if.end325.i
  %call258.ph = phi i32 [ 3, %if.end320.i ], [ 2, %if.end.i ], [ 1, %cond.end312.i ], [ 0, %if.end325.i ]
  %11 = trunc i64 %indvars.iv281 to i32
  %12 = load i32, i32* %arrayidx14, align 16, !tbaa !17
  %sub = sub nsw i32 %11, %12
  %idxprom15 = sext i32 %sub to i64
  %arrayidx16 = getelementptr inbounds i32, i32* %myset, i64 %idxprom15
  %13 = load i32, i32* %arrayidx16, align 4, !tbaa !17
  %sext301 = shl i64 %indvars.iv281, 32
  %idxprom17 = ashr exact i64 %sext301, 32
  %arrayidx18 = getelementptr inbounds i32, i32* %myset, i64 %idxprom17
  store i32 %13, i32* %arrayidx18, align 4, !tbaa !17
  %cmp10 = icmp eq i32 %call258.ph, 3
  br i1 %cmp10, label %for.cond.cleanup11, label %for.body12.1

if.end.thread:                                    ; preds = %entry
  %arrayidx29 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 0
  store i32 %n, i32* %arrayidx29, align 16, !tbaa !17
  %14 = bitcast [4 x %struct.IntersectionEventList]* %temp_lists to i8*
  call void @llvm.lifetime.start.p0i8(i64 64, i8* nonnull %14) #4
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(64) %14, i8 0, i64 64, i1 false)
  br label %if.end36

if.end:                                           ; preds = %for.cond.cleanup11
  %arrayidx30.phi.trans.insert = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 0
  %.pre = load i32, i32* %arrayidx30.phi.trans.insert, align 16, !tbaa !17
  %arrayidx31.phi.trans.insert = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 1
  %.pre285 = load i32, i32* %arrayidx31.phi.trans.insert, align 4, !tbaa !17
  %15 = bitcast [4 x %struct.IntersectionEventList]* %temp_lists to i8*
  call void @llvm.lifetime.start.p0i8(i64 64, i8* nonnull %15) #4
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(64) %15, i8 0, i64 64, i1 false)
  %tobool = icmp eq i32 %.pre285, 0
  br i1 %tobool, label %if.end36, label %if.then32.tf

if.then32.tf:                                     ; preds = %if.end
  detach within %syncreg, label %det.achd, label %if.end36

det.achd:                                         ; preds = %if.then32.tf
  %add35 = add nsw i32 %depth, 1
  %idx.ext = sext i32 %.pre to i64
  %add.ptr = getelementptr inbounds i32, i32* %myset, i64 %idx.ext
  %arrayidx33 = getelementptr inbounds [4 x %struct.IntersectionEventList], [4 x %struct.IntersectionEventList]* %temp_lists, i64 0, i64 0
  call void @walkTree(%struct.CollisionWorld* %collisionWorld, %struct.IntersectionEventList* nonnull %arrayidx33, i32* %add.ptr, i32 %.pre285, i32 %add35, double %div, double %xmax, double %div2, double %ymax)
  reattach within %syncreg, label %if.end36

if.end36:                                         ; preds = %if.end.thread, %if.then32.tf, %det.achd, %if.end
  %16 = phi i8* [ %14, %if.end.thread ], [ %15, %if.then32.tf ], [ %15, %if.end ], [ %15, %det.achd ]
  %17 = phi i32 [ %n, %if.end.thread ], [ %.pre, %if.then32.tf ], [ %.pre, %if.end ], [ %.pre, %det.achd ]
  %18 = phi i32 [ 0, %if.end.thread ], [ %.pre285, %if.then32.tf ], [ 0, %if.end ], [ %.pre285, %det.achd ]
  %add38 = add nsw i32 %18, %17
  %arrayidx39 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 2
  %19 = load i32, i32* %arrayidx39, align 8, !tbaa !17
  %tobool40 = icmp eq i32 %19, 0
  br i1 %tobool40, label %if.end49, label %if.then41.tf

if.then41.tf:                                     ; preds = %if.end36
  detach within %syncreg, label %det.achd47, label %if.end49

det.achd47:                                       ; preds = %if.then41.tf
  %add46 = add nsw i32 %depth, 1
  %idx.ext43 = sext i32 %add38 to i64
  %add.ptr44 = getelementptr inbounds i32, i32* %myset, i64 %idx.ext43
  %arrayidx42 = getelementptr inbounds [4 x %struct.IntersectionEventList], [4 x %struct.IntersectionEventList]* %temp_lists, i64 0, i64 1
  call void @walkTree(%struct.CollisionWorld* %collisionWorld, %struct.IntersectionEventList* nonnull %arrayidx42, i32* %add.ptr44, i32 %19, i32 %add46, double %xmin, double %div, double %div2, double %ymax)
  reattach within %syncreg, label %if.end49

if.end49:                                         ; preds = %if.then41.tf, %det.achd47, %if.end36
  %add51 = add nsw i32 %19, %add38
  %arrayidx52 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 3
  %20 = load i32, i32* %arrayidx52, align 4, !tbaa !17
  %tobool53 = icmp eq i32 %20, 0
  br i1 %tobool53, label %if.end62, label %if.then54.tf

if.then54.tf:                                     ; preds = %if.end49
  detach within %syncreg, label %det.achd60, label %if.end62

det.achd60:                                       ; preds = %if.then54.tf
  %add59 = add nsw i32 %depth, 1
  %idx.ext56 = sext i32 %add51 to i64
  %add.ptr57 = getelementptr inbounds i32, i32* %myset, i64 %idx.ext56
  %arrayidx55 = getelementptr inbounds [4 x %struct.IntersectionEventList], [4 x %struct.IntersectionEventList]* %temp_lists, i64 0, i64 2
  call void @walkTree(%struct.CollisionWorld* %collisionWorld, %struct.IntersectionEventList* nonnull %arrayidx55, i32* %add.ptr57, i32 %20, i32 %add59, double %xmin, double %div, double %ymin, double %div2)
  reattach within %syncreg, label %if.end62

if.end62:                                         ; preds = %if.then54.tf, %det.achd60, %if.end49
  %arrayidx65 = getelementptr inbounds [5 x i32], [5 x i32]* %sub_n, i64 0, i64 4
  %21 = load i32, i32* %arrayidx65, align 16, !tbaa !17
  %tobool66 = icmp eq i32 %21, 0
  br i1 %tobool66, label %if.end73, label %if.then67

if.then67:                                        ; preds = %if.end62
  %add64 = add nsw i32 %20, %add51
  %arrayidx68 = getelementptr inbounds [4 x %struct.IntersectionEventList], [4 x %struct.IntersectionEventList]* %temp_lists, i64 0, i64 3
  %idx.ext69 = sext i32 %add64 to i64
  %add.ptr70 = getelementptr inbounds i32, i32* %myset, i64 %idx.ext69
  %add72 = add nsw i32 %depth, 1
  call void @walkTree(%struct.CollisionWorld* %collisionWorld, %struct.IntersectionEventList* nonnull %arrayidx68, i32* %add.ptr70, i32 %21, i32 %add72, double %div, double %xmax, double %ymin, double %div2)
  br label %if.end73

if.end73:                                         ; preds = %if.end62, %if.then67
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %if.end73
  %arrayidx74 = getelementptr inbounds [4 x %struct.IntersectionEventList], [4 x %struct.IntersectionEventList]* %temp_lists, i64 0, i64 0
  call void @IntersectionEventList_merge(%struct.IntersectionEventList* %eventList, %struct.IntersectionEventList* nonnull %arrayidx74) #4
  %arrayidx75 = getelementptr inbounds [4 x %struct.IntersectionEventList], [4 x %struct.IntersectionEventList]* %temp_lists, i64 0, i64 1
  call void @IntersectionEventList_merge(%struct.IntersectionEventList* %eventList, %struct.IntersectionEventList* nonnull %arrayidx75) #4
  %arrayidx76 = getelementptr inbounds [4 x %struct.IntersectionEventList], [4 x %struct.IntersectionEventList]* %temp_lists, i64 0, i64 2
  call void @IntersectionEventList_merge(%struct.IntersectionEventList* %eventList, %struct.IntersectionEventList* nonnull %arrayidx76) #4
  %arrayidx77 = getelementptr inbounds [4 x %struct.IntersectionEventList], [4 x %struct.IntersectionEventList]* %temp_lists, i64 0, i64 3
  call void @IntersectionEventList_merge(%struct.IntersectionEventList* %eventList, %struct.IntersectionEventList* nonnull %arrayidx77) #4
  %cmp81267 = icmp sgt i32 %17, 0
  br i1 %cmp81267, label %for.body83.lr.ph, label %for.cond.cleanup82

for.body83.lr.ph:                                 ; preds = %sync.continue
  %lines84 = getelementptr inbounds %struct.CollisionWorld, %struct.CollisionWorld* %collisionWorld, i64 0, i32 1
  %timeStep = getelementptr inbounds %struct.CollisionWorld, %struct.CollisionWorld* %collisionWorld, i64 0, i32 0
  %numLineLineCollisions = getelementptr inbounds %struct.CollisionWorld, %struct.CollisionWorld* %collisionWorld, i64 0, i32 4
  %wide.trip.count = zext i32 %17 to i64
  %22 = zext i32 %17 to i64
  %23 = sext i32 %add38 to i64
  %24 = sext i32 %add51 to i64
  %add106261.3 = add nsw i32 %20, %add51
  %25 = sext i32 %add106261.3 to i64
  %26 = add nsw i64 %22, -1
  %add106261.4 = add nsw i32 %21, %add106261.3
  %27 = sext i32 %add106261.4 to i64
  br label %if.then98

for.cond.cleanup82:                               ; preds = %if.end133.4, %sync.continue
  call void @llvm.lifetime.end.p0i8(i64 64, i8* nonnull %16) #4
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %0) #4
  ret void

if.then98:                                        ; preds = %for.body83.lr.ph, %if.end133.4
  %indvars.iv277 = phi i64 [ 0, %for.body83.lr.ph ], [ %indvars.iv.next278, %if.end133.4 ]
  %28 = load %struct.Line**, %struct.Line*** %lines84, align 8, !tbaa !14
  %arrayidx86 = getelementptr inbounds i32, i32* %myset, i64 %indvars.iv277
  %29 = load i32, i32* %arrayidx86, align 4, !tbaa !17
  %idxprom87 = sext i32 %29 to i64
  %arrayidx88 = getelementptr inbounds %struct.Line*, %struct.Line** %28, i64 %idxprom87
  %30 = load %struct.Line*, %struct.Line** %arrayidx88, align 8, !tbaa !18
  %call89 = call i32 @getQuadrantMask(%struct.Line* %30, double undef, double undef, double %div, double undef, double undef, double %div2)
  %indvars.iv.next278 = add nuw nsw i64 %indvars.iv277, 1
  %cmp107262 = icmp ult i64 %indvars.iv.next278, %22
  br i1 %cmp107262, label %for.body109, label %lor.lhs.false.1

; CHECK: if.then98:
; CHECK: %[[SCEVGEP:.+]] = getelementptr i32, i32* %myset
; CHECK: %[[SCEVBC:.+]] = bitcast i32* %[[SCEVGEP]] to i8*

; CHECK: for.body109.preheader:
; CHECK: call void @__csan_large_load(i64 %{{.+}}, i8* %[[SCEVBC]],
; CHECK: br label %for.body109

for.body109:                                      ; preds = %if.then98, %if.end129.for.body109_crit_edge
  %31 = phi %struct.Line* [ %.pre288, %if.end129.for.body109_crit_edge ], [ %30, %if.then98 ]
  %32 = phi %struct.Line** [ %.pre286, %if.end129.for.body109_crit_edge ], [ %28, %if.then98 ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %if.end129.for.body109_crit_edge ], [ %indvars.iv.next278, %if.then98 ]
  %arrayidx117 = getelementptr inbounds i32, i32* %myset, i64 %indvars.iv
  %33 = load i32, i32* %arrayidx117, align 4, !tbaa !17
  %idxprom118 = sext i32 %33 to i64
  %arrayidx119 = getelementptr inbounds %struct.Line*, %struct.Line** %32, i64 %idxprom118
  %34 = load %struct.Line*, %struct.Line** %arrayidx119, align 8, !tbaa !18
  %35 = load i32, i32* @comparisons, align 4, !tbaa !17
  %inc120 = add nsw i32 %35, 1
  store i32 %inc120, i32* @comparisons, align 4, !tbaa !17
  %.idx = getelementptr %struct.Line, %struct.Line* %31, i64 0, i32 4
  %.idx.val = load i32, i32* %.idx, align 4, !tbaa !19
  %.idx257 = getelementptr %struct.Line, %struct.Line* %34, i64 0, i32 4
  %.idx257.val = load i32, i32* %.idx257, align 4, !tbaa !19
  %cmp.i259 = icmp uge i32 %.idx.val, %.idx257.val
  %spec.select = select i1 %cmp.i259, %struct.Line* %34, %struct.Line* %31
  %spec.select256 = select i1 %cmp.i259, %struct.Line* %31, %struct.Line* %34
  %36 = load double, double* %timeStep, align 8, !tbaa !20
  %call125 = call i32 @intersect(%struct.Line* %spec.select, %struct.Line* %spec.select256, double %36) #4
  %cmp126 = icmp eq i32 %call125, 0
  br i1 %cmp126, label %if.end129, label %if.then127

; CHECK: for.body109:
; CHECK-NOT: call void @__csan_load(
; CHECK: load i32, i32* %arrayidx117
; CHECK: br i1 %cmp126, label %if.end129, label %if.then127

if.then127:                                       ; preds = %for.body109
  call void @IntersectionEventList_appendNode(%struct.IntersectionEventList* %eventList, %struct.Line* %spec.select, %struct.Line* %spec.select256, i32 %call125) #4
  %37 = load i32, i32* %numLineLineCollisions, align 8, !tbaa !21
  %inc128 = add i32 %37, 1
  store i32 %inc128, i32* %numLineLineCollisions, align 8, !tbaa !21
  br label %if.end129

if.end129:                                        ; preds = %for.body109, %if.then127
  %exitcond296 = icmp eq i64 %indvars.iv, %26
  br i1 %exitcond296, label %lor.lhs.false.1, label %if.end129.for.body109_crit_edge

if.end129.for.body109_crit_edge:                  ; preds = %if.end129
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %.pre286 = load %struct.Line**, %struct.Line*** %lines84, align 8, !tbaa !14
  %.pre287 = load i32, i32* %arrayidx86, align 4, !tbaa !17
  %idxprom113.phi.trans.insert = sext i32 %.pre287 to i64
  %arrayidx114.phi.trans.insert = getelementptr inbounds %struct.Line*, %struct.Line** %.pre286, i64 %idxprom113.phi.trans.insert
  %.pre288 = load %struct.Line*, %struct.Line** %arrayidx114.phi.trans.insert, align 8, !tbaa !18
  br label %for.body109

lor.lhs.false.1:                                  ; preds = %if.end129, %if.then98
  %and.1 = and i32 %call89, 2
  %tobool97.1 = icmp eq i32 %and.1, 0
  br i1 %tobool97.1, label %lor.lhs.false.2, label %if.then98.1

if.then98.1:                                      ; preds = %lor.lhs.false.1
  %cmp101.1 = icmp ult i64 %indvars.iv277, %22
  %38 = trunc i64 %indvars.iv.next278 to i32
  %cond.1 = select i1 %cmp101.1, i32 %17, i32 %38
  %cmp107262.1 = icmp slt i32 %cond.1, %add38
  br i1 %cmp107262.1, label %for.body109.preheader.1, label %lor.lhs.false.2

for.body109.preheader.1:                          ; preds = %if.then98.1
  %39 = sext i32 %cond.1 to i64
  br label %for.body109.1

for.body109.1:                                    ; preds = %if.end129.1, %for.body109.preheader.1
  %indvars.iv.1 = phi i64 [ %39, %for.body109.preheader.1 ], [ %indvars.iv.next.1, %if.end129.1 ]
  %40 = load %struct.Line**, %struct.Line*** %lines84, align 8, !tbaa !14
  %41 = load i32, i32* %arrayidx86, align 4, !tbaa !17
  %idxprom113.1 = sext i32 %41 to i64
  %arrayidx114.1 = getelementptr inbounds %struct.Line*, %struct.Line** %40, i64 %idxprom113.1
  %42 = load %struct.Line*, %struct.Line** %arrayidx114.1, align 8, !tbaa !18
  %arrayidx117.1 = getelementptr inbounds i32, i32* %myset, i64 %indvars.iv.1
  %43 = load i32, i32* %arrayidx117.1, align 4, !tbaa !17
  %idxprom118.1 = sext i32 %43 to i64
  %arrayidx119.1 = getelementptr inbounds %struct.Line*, %struct.Line** %40, i64 %idxprom118.1
  %44 = load %struct.Line*, %struct.Line** %arrayidx119.1, align 8, !tbaa !18
  %45 = load i32, i32* @comparisons, align 4, !tbaa !17
  %inc120.1 = add nsw i32 %45, 1
  store i32 %inc120.1, i32* @comparisons, align 4, !tbaa !17
  %.idx.1 = getelementptr %struct.Line, %struct.Line* %42, i64 0, i32 4
  %.idx.val.1 = load i32, i32* %.idx.1, align 4, !tbaa !19
  %.idx257.1 = getelementptr %struct.Line, %struct.Line* %44, i64 0, i32 4
  %.idx257.val.1 = load i32, i32* %.idx257.1, align 4, !tbaa !19
  %cmp.i259.1 = icmp uge i32 %.idx.val.1, %.idx257.val.1
  %spec.select.1 = select i1 %cmp.i259.1, %struct.Line* %44, %struct.Line* %42
  %spec.select256.1 = select i1 %cmp.i259.1, %struct.Line* %42, %struct.Line* %44
  %46 = load double, double* %timeStep, align 8, !tbaa !20
  %call125.1 = call i32 @intersect(%struct.Line* %spec.select.1, %struct.Line* %spec.select256.1, double %46) #4
  %cmp126.1 = icmp eq i32 %call125.1, 0
  br i1 %cmp126.1, label %if.end129.1, label %if.then127.1

if.then127.1:                                     ; preds = %for.body109.1
  call void @IntersectionEventList_appendNode(%struct.IntersectionEventList* %eventList, %struct.Line* %spec.select.1, %struct.Line* %spec.select256.1, i32 %call125.1) #4
  %47 = load i32, i32* %numLineLineCollisions, align 8, !tbaa !21
  %inc128.1 = add i32 %47, 1
  store i32 %inc128.1, i32* %numLineLineCollisions, align 8, !tbaa !21
  br label %if.end129.1

if.end129.1:                                      ; preds = %if.then127.1, %for.body109.1
  %indvars.iv.next.1 = add nsw i64 %indvars.iv.1, 1
  %exitcond297 = icmp eq i64 %indvars.iv.next.1, %23
  br i1 %exitcond297, label %lor.lhs.false.2, label %for.body109.1

lor.lhs.false.2:                                  ; preds = %if.end129.1, %lor.lhs.false.1, %if.then98.1
  %and.2 = and i32 %call89, 4
  %tobool97.2 = icmp eq i32 %and.2, 0
  br i1 %tobool97.2, label %lor.lhs.false.3, label %if.then98.2

if.then98.2:                                      ; preds = %lor.lhs.false.2
  %cmp101.2 = icmp slt i64 %indvars.iv277, %23
  %48 = trunc i64 %indvars.iv.next278 to i32
  %cond.2 = select i1 %cmp101.2, i32 %add38, i32 %48
  %cmp107262.2 = icmp slt i32 %cond.2, %add51
  br i1 %cmp107262.2, label %for.body109.preheader.2, label %lor.lhs.false.3

for.body109.preheader.2:                          ; preds = %if.then98.2
  %49 = sext i32 %cond.2 to i64
  br label %for.body109.2

for.body109.2:                                    ; preds = %if.end129.2, %for.body109.preheader.2
  %indvars.iv.2 = phi i64 [ %49, %for.body109.preheader.2 ], [ %indvars.iv.next.2, %if.end129.2 ]
  %50 = load %struct.Line**, %struct.Line*** %lines84, align 8, !tbaa !14
  %51 = load i32, i32* %arrayidx86, align 4, !tbaa !17
  %idxprom113.2 = sext i32 %51 to i64
  %arrayidx114.2 = getelementptr inbounds %struct.Line*, %struct.Line** %50, i64 %idxprom113.2
  %52 = load %struct.Line*, %struct.Line** %arrayidx114.2, align 8, !tbaa !18
  %arrayidx117.2 = getelementptr inbounds i32, i32* %myset, i64 %indvars.iv.2
  %53 = load i32, i32* %arrayidx117.2, align 4, !tbaa !17
  %idxprom118.2 = sext i32 %53 to i64
  %arrayidx119.2 = getelementptr inbounds %struct.Line*, %struct.Line** %50, i64 %idxprom118.2
  %54 = load %struct.Line*, %struct.Line** %arrayidx119.2, align 8, !tbaa !18
  %55 = load i32, i32* @comparisons, align 4, !tbaa !17
  %inc120.2 = add nsw i32 %55, 1
  store i32 %inc120.2, i32* @comparisons, align 4, !tbaa !17
  %.idx.2 = getelementptr %struct.Line, %struct.Line* %52, i64 0, i32 4
  %.idx.val.2 = load i32, i32* %.idx.2, align 4, !tbaa !19
  %.idx257.2 = getelementptr %struct.Line, %struct.Line* %54, i64 0, i32 4
  %.idx257.val.2 = load i32, i32* %.idx257.2, align 4, !tbaa !19
  %cmp.i259.2 = icmp uge i32 %.idx.val.2, %.idx257.val.2
  %spec.select.2 = select i1 %cmp.i259.2, %struct.Line* %54, %struct.Line* %52
  %spec.select256.2 = select i1 %cmp.i259.2, %struct.Line* %52, %struct.Line* %54
  %56 = load double, double* %timeStep, align 8, !tbaa !20
  %call125.2 = call i32 @intersect(%struct.Line* %spec.select.2, %struct.Line* %spec.select256.2, double %56) #4
  %cmp126.2 = icmp eq i32 %call125.2, 0
  br i1 %cmp126.2, label %if.end129.2, label %if.then127.2

if.then127.2:                                     ; preds = %for.body109.2
  call void @IntersectionEventList_appendNode(%struct.IntersectionEventList* %eventList, %struct.Line* %spec.select.2, %struct.Line* %spec.select256.2, i32 %call125.2) #4
  %57 = load i32, i32* %numLineLineCollisions, align 8, !tbaa !21
  %inc128.2 = add i32 %57, 1
  store i32 %inc128.2, i32* %numLineLineCollisions, align 8, !tbaa !21
  br label %if.end129.2

if.end129.2:                                      ; preds = %if.then127.2, %for.body109.2
  %indvars.iv.next.2 = add nsw i64 %indvars.iv.2, 1
  %exitcond298 = icmp eq i64 %indvars.iv.next.2, %24
  br i1 %exitcond298, label %lor.lhs.false.3, label %for.body109.2

lor.lhs.false.3:                                  ; preds = %if.end129.2, %lor.lhs.false.2, %if.then98.2
  %and.3 = and i32 %call89, 8
  %tobool97.3 = icmp eq i32 %and.3, 0
  br i1 %tobool97.3, label %lor.lhs.false.4, label %if.then98.3

if.then98.3:                                      ; preds = %lor.lhs.false.3
  %cmp101.3 = icmp slt i64 %indvars.iv277, %24
  %58 = trunc i64 %indvars.iv.next278 to i32
  %cond.3 = select i1 %cmp101.3, i32 %add51, i32 %58
  %cmp107262.3 = icmp slt i32 %cond.3, %add106261.3
  br i1 %cmp107262.3, label %for.body109.preheader.3, label %lor.lhs.false.4

for.body109.preheader.3:                          ; preds = %if.then98.3
  %59 = sext i32 %cond.3 to i64
  br label %for.body109.3

for.body109.3:                                    ; preds = %if.end129.3, %for.body109.preheader.3
  %indvars.iv.3 = phi i64 [ %59, %for.body109.preheader.3 ], [ %indvars.iv.next.3, %if.end129.3 ]
  %60 = load %struct.Line**, %struct.Line*** %lines84, align 8, !tbaa !14
  %61 = load i32, i32* %arrayidx86, align 4, !tbaa !17
  %idxprom113.3 = sext i32 %61 to i64
  %arrayidx114.3 = getelementptr inbounds %struct.Line*, %struct.Line** %60, i64 %idxprom113.3
  %62 = load %struct.Line*, %struct.Line** %arrayidx114.3, align 8, !tbaa !18
  %arrayidx117.3 = getelementptr inbounds i32, i32* %myset, i64 %indvars.iv.3
  %63 = load i32, i32* %arrayidx117.3, align 4, !tbaa !17
  %idxprom118.3 = sext i32 %63 to i64
  %arrayidx119.3 = getelementptr inbounds %struct.Line*, %struct.Line** %60, i64 %idxprom118.3
  %64 = load %struct.Line*, %struct.Line** %arrayidx119.3, align 8, !tbaa !18
  %65 = load i32, i32* @comparisons, align 4, !tbaa !17
  %inc120.3 = add nsw i32 %65, 1
  store i32 %inc120.3, i32* @comparisons, align 4, !tbaa !17
  %.idx.3 = getelementptr %struct.Line, %struct.Line* %62, i64 0, i32 4
  %.idx.val.3 = load i32, i32* %.idx.3, align 4, !tbaa !19
  %.idx257.3 = getelementptr %struct.Line, %struct.Line* %64, i64 0, i32 4
  %.idx257.val.3 = load i32, i32* %.idx257.3, align 4, !tbaa !19
  %cmp.i259.3 = icmp uge i32 %.idx.val.3, %.idx257.val.3
  %spec.select.3 = select i1 %cmp.i259.3, %struct.Line* %64, %struct.Line* %62
  %spec.select256.3 = select i1 %cmp.i259.3, %struct.Line* %62, %struct.Line* %64
  %66 = load double, double* %timeStep, align 8, !tbaa !20
  %call125.3 = call i32 @intersect(%struct.Line* %spec.select.3, %struct.Line* %spec.select256.3, double %66) #4
  %cmp126.3 = icmp eq i32 %call125.3, 0
  br i1 %cmp126.3, label %if.end129.3, label %if.then127.3

if.then127.3:                                     ; preds = %for.body109.3
  call void @IntersectionEventList_appendNode(%struct.IntersectionEventList* %eventList, %struct.Line* %spec.select.3, %struct.Line* %spec.select256.3, i32 %call125.3) #4
  %67 = load i32, i32* %numLineLineCollisions, align 8, !tbaa !21
  %inc128.3 = add i32 %67, 1
  store i32 %inc128.3, i32* %numLineLineCollisions, align 8, !tbaa !21
  br label %if.end129.3

if.end129.3:                                      ; preds = %if.then127.3, %for.body109.3
  %indvars.iv.next.3 = add nsw i64 %indvars.iv.3, 1
  %exitcond299 = icmp eq i64 %indvars.iv.next.3, %25
  br i1 %exitcond299, label %lor.lhs.false.4, label %for.body109.3

lor.lhs.false.4:                                  ; preds = %if.end129.3, %lor.lhs.false.3, %if.then98.3
  %and.4 = and i32 %call89, 16
  %tobool97.4 = icmp eq i32 %and.4, 0
  br i1 %tobool97.4, label %if.end133.4, label %if.then98.4

if.then98.4:                                      ; preds = %lor.lhs.false.4
  %cmp101.4 = icmp slt i64 %indvars.iv277, %25
  %68 = trunc i64 %indvars.iv.next278 to i32
  %cond.4 = select i1 %cmp101.4, i32 %add106261.3, i32 %68
  %cmp107262.4 = icmp slt i32 %cond.4, %add106261.4
  br i1 %cmp107262.4, label %for.body109.preheader.4, label %if.end133.4

for.body109.preheader.4:                          ; preds = %if.then98.4
  %69 = sext i32 %cond.4 to i64
  br label %for.body109.4

for.body109.4:                                    ; preds = %if.end129.4, %for.body109.preheader.4
  %indvars.iv.4 = phi i64 [ %69, %for.body109.preheader.4 ], [ %indvars.iv.next.4, %if.end129.4 ]
  %70 = load %struct.Line**, %struct.Line*** %lines84, align 8, !tbaa !14
  %71 = load i32, i32* %arrayidx86, align 4, !tbaa !17
  %idxprom113.4 = sext i32 %71 to i64
  %arrayidx114.4 = getelementptr inbounds %struct.Line*, %struct.Line** %70, i64 %idxprom113.4
  %72 = load %struct.Line*, %struct.Line** %arrayidx114.4, align 8, !tbaa !18
  %arrayidx117.4 = getelementptr inbounds i32, i32* %myset, i64 %indvars.iv.4
  %73 = load i32, i32* %arrayidx117.4, align 4, !tbaa !17
  %idxprom118.4 = sext i32 %73 to i64
  %arrayidx119.4 = getelementptr inbounds %struct.Line*, %struct.Line** %70, i64 %idxprom118.4
  %74 = load %struct.Line*, %struct.Line** %arrayidx119.4, align 8, !tbaa !18
  %75 = load i32, i32* @comparisons, align 4, !tbaa !17
  %inc120.4 = add nsw i32 %75, 1
  store i32 %inc120.4, i32* @comparisons, align 4, !tbaa !17
  %.idx.4 = getelementptr %struct.Line, %struct.Line* %72, i64 0, i32 4
  %.idx.val.4 = load i32, i32* %.idx.4, align 4, !tbaa !19
  %.idx257.4 = getelementptr %struct.Line, %struct.Line* %74, i64 0, i32 4
  %.idx257.val.4 = load i32, i32* %.idx257.4, align 4, !tbaa !19
  %cmp.i259.4 = icmp uge i32 %.idx.val.4, %.idx257.val.4
  %spec.select.4 = select i1 %cmp.i259.4, %struct.Line* %74, %struct.Line* %72
  %spec.select256.4 = select i1 %cmp.i259.4, %struct.Line* %72, %struct.Line* %74
  %76 = load double, double* %timeStep, align 8, !tbaa !20
  %call125.4 = call i32 @intersect(%struct.Line* %spec.select.4, %struct.Line* %spec.select256.4, double %76) #4
  %cmp126.4 = icmp eq i32 %call125.4, 0
  br i1 %cmp126.4, label %if.end129.4, label %if.then127.4

if.then127.4:                                     ; preds = %for.body109.4
  call void @IntersectionEventList_appendNode(%struct.IntersectionEventList* %eventList, %struct.Line* %spec.select.4, %struct.Line* %spec.select256.4, i32 %call125.4) #4
  %77 = load i32, i32* %numLineLineCollisions, align 8, !tbaa !21
  %inc128.4 = add i32 %77, 1
  store i32 %inc128.4, i32* %numLineLineCollisions, align 8, !tbaa !21
  br label %if.end129.4

if.end129.4:                                      ; preds = %if.then127.4, %for.body109.4
  %indvars.iv.next.4 = add nsw i64 %indvars.iv.4, 1
  %exitcond300 = icmp eq i64 %indvars.iv.next.4, %27
  br i1 %exitcond300, label %if.end133.4, label %for.body109.4

if.end133.4:                                      ; preds = %if.end129.4, %if.then98.4, %lor.lhs.false.4
  %exitcond = icmp eq i64 %indvars.iv.next278, %wide.trip.count
  br i1 %exitcond, label %for.cond.cleanup82, label %if.then98

for.body12.1:                                     ; preds = %for.body12
  %78 = load i32, i32* %arrayidx14.1, align 4, !tbaa !17
  %sub.1 = sub nsw i32 %sub, %78
  %idxprom15.1 = sext i32 %sub.1 to i64
  %arrayidx16.1 = getelementptr inbounds i32, i32* %myset, i64 %idxprom15.1
  %79 = load i32, i32* %arrayidx16.1, align 4, !tbaa !17
  %idxprom17.1 = sext i32 %sub to i64
  %arrayidx18.1 = getelementptr inbounds i32, i32* %myset, i64 %idxprom17.1
  store i32 %79, i32* %arrayidx18.1, align 4, !tbaa !17
  %cmp10.1 = icmp ult i32 %call258.ph, 2
  br i1 %cmp10.1, label %for.body12.2, label %for.cond.cleanup11

for.body12.2:                                     ; preds = %for.body12.1
  %80 = load i32, i32* %arrayidx14.2, align 8, !tbaa !17
  %sub.2 = sub nsw i32 %sub.1, %80
  %idxprom15.2 = sext i32 %sub.2 to i64
  %arrayidx16.2 = getelementptr inbounds i32, i32* %myset, i64 %idxprom15.2
  %81 = load i32, i32* %arrayidx16.2, align 4, !tbaa !17
  %idxprom17.2 = sext i32 %sub.1 to i64
  %arrayidx18.2 = getelementptr inbounds i32, i32* %myset, i64 %idxprom17.2
  store i32 %81, i32* %arrayidx18.2, align 4, !tbaa !17
  %cmp10.2 = icmp eq i32 %call258.ph, 0
  br i1 %cmp10.2, label %for.body12.3, label %for.cond.cleanup11

for.body12.3:                                     ; preds = %for.body12.2
  %82 = load i32, i32* %arrayidx14.3, align 4, !tbaa !17
  %sub.3 = sub nsw i32 %sub.2, %82
  %idxprom15.3 = sext i32 %sub.3 to i64
  %arrayidx16.3 = getelementptr inbounds i32, i32* %myset, i64 %idxprom15.3
  %83 = load i32, i32* %arrayidx16.3, align 4, !tbaa !17
  %idxprom17.3 = sext i32 %sub.2 to i64
  %arrayidx18.3 = getelementptr inbounds i32, i32* %myset, i64 %idxprom17.3
  store i32 %83, i32* %arrayidx18.3, align 4, !tbaa !17
  br label %for.cond.cleanup11
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

declare dso_local void @IntersectionEventList_merge(%struct.IntersectionEventList*, %struct.IntersectionEventList*) local_unnamed_addr #3

declare dso_local i32 @intersect(%struct.Line*, %struct.Line*, double) local_unnamed_addr #3

declare dso_local void @IntersectionEventList_appendNode(%struct.IntersectionEventList*, %struct.Line*, %struct.Line*, i32) local_unnamed_addr #3

declare dso_local i32 @getQuadrantMask(%struct.Line* nocapture readonly %line, double %xmin, double %xmax, double %xmid, double %ymin, double %ymax, double %ymid) local_unnamed_addr #0

attributes #0 = { argmemonly norecurse nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nounwind uwtable sanitize_cilk "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git ff885a5bdaadaf081873e642d53c38aeca4587db)"}
!2 = !{!3, !5, i64 0}
!3 = !{!"Line", !4, i64 0, !4, i64 16, !4, i64 32, !6, i64 48, !8, i64 52}
!4 = !{!"Vec", !5, i64 0, !5, i64 8}
!5 = !{!"double", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = !{!"int", !6, i64 0}
!9 = !{!3, !5, i64 32}
!10 = !{!3, !5, i64 16}
!11 = !{!3, !5, i64 8}
!12 = !{!3, !5, i64 40}
!13 = !{!3, !5, i64 24}
!14 = !{!15, !16, i64 8}
!15 = !{!"CollisionWorld", !5, i64 0, !16, i64 8, !8, i64 16, !8, i64 20, !8, i64 24}
!16 = !{!"any pointer", !6, i64 0}
!17 = !{!8, !8, i64 0}
!18 = !{!16, !16, i64 0}
!19 = !{!3, !8, i64 52}
!20 = !{!15, !5, i64 0}
!21 = !{!15, !8, i64 24}
!22 = !{!15, !8, i64 16}
!23 = distinct !{!23, !24}
!24 = !{!"llvm.loop.isvectorized", i32 1}
!25 = distinct !{!25, !26}
!26 = !{!"llvm.loop.unroll.disable"}
!27 = distinct !{!27, !28, !24}
!28 = !{!"llvm.loop.unroll.runtime.disable"}
