; RUN: opt < %s -tapir2target -tapir-target=opencilk -S -o - | FileCheck %s
; RUN: opt < %s -passes='tapir2target' -tapir-target=opencilk -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.Line = type { %struct.Vec, %struct.Vec, %struct.Vec, %struct.Vec, %struct.Vec, i32, i16, i8, %struct.Box, i32 }
%struct.Vec = type { double, double }
%struct.Box = type { double, double, double, double }

@lines = common dso_local local_unnamed_addr global %struct.Line** null, align 8

; Function Attrs: nounwind uwtable
define dso_local void @detectLocalizedCollisions(i32 %l, i32 %r, i8 zeroext %h) local_unnamed_addr #0 {
entry:
  %m = alloca [6 x i32], align 16
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp sle i32 %r, %l
  %0 = or i32 %r, %l
  %1 = icmp slt i32 %0, 0
  %2 = or i1 %cmp, %1
  br i1 %2, label %cleanup.cont, label %if.end

if.end:                                           ; preds = %entry
  %cmp4 = icmp ult i8 %h, 4
  %sub = sub nsw i32 %r, %l
  %cmp7 = icmp slt i32 %sub, 100
  %or.cond = or i1 %cmp4, %cmp7
  br i1 %or.cond, label %if.then9, label %for.body.lr.ph.i

if.then9:                                         ; preds = %if.end
  tail call void @detectCollisionsSlow(i32 %l, i32 %r)
  br label %cleanup.cont

for.body.lr.ph.i:                                 ; preds = %if.end
  %3 = bitcast [6 x i32]* %m to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %3) #6
  %arrayinit.begin = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 0
  store i32 %l, i32* %arrayinit.begin, align 16, !tbaa !31
  %arrayinit.element = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 1
  %arrayinit.element11 = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 2
  %arrayinit.element12 = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 3
  %arrayinit.element13 = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 4
  %arrayinit.element14 = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 5
  %add15 = add nsw i32 %r, 1
  %4 = bitcast i32* %arrayinit.element to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 4 %4, i8 -1, i64 16, i1 false)
  store i32 %add15, i32* %arrayinit.element14, align 4, !tbaa !31
  %5 = load %struct.Line**, %struct.Line*** @lines, align 8, !tbaa !2
  br label %for.body.i

for.body.i:                                       ; preds = %if.else.i, %for.body.lr.ph.i
  %r.047.i = phi i32 [ %r, %for.body.lr.ph.i ], [ %r.1.i, %if.else.i ]
  %l.046.i = phi i32 [ %l, %for.body.lr.ph.i ], [ %l.1.i, %if.else.i ]
  %add.i = add nsw i32 %l.046.i, %r.047.i
  %div.i = sdiv i32 %add.i, 2
  %idxprom.i = sext i32 %div.i to i64
  %arrayidx.i = getelementptr inbounds %struct.Line*, %struct.Line** %5, i64 %idxprom.i
  %6 = load %struct.Line*, %struct.Line** %arrayidx.i, align 8, !tbaa !2
  %height.i = getelementptr inbounds %struct.Line, %struct.Line* %6, i64 0, i32 7
  %7 = load i8, i8* %height.i, align 2, !tbaa !20
  %cmp2.i = icmp eq i8 %7, %h
  br i1 %cmp2.i, label %land.lhs.true.i, label %for.body.if.else_crit_edge.i

for.body.if.else_crit_edge.i:                     ; preds = %for.body.i
  %.pre.i = add nsw i32 %div.i, -1
  br label %if.else.i

land.lhs.true.i:                                  ; preds = %for.body.i
  %cmp4.i = icmp eq i32 %div.i, %l.046.i
  br i1 %cmp4.i, label %bsearch_parents.exit, label %lor.lhs.false.i

lor.lhs.false.i:                                  ; preds = %land.lhs.true.i
  %sub.i = add nsw i32 %div.i, -1
  %idxprom6.i = sext i32 %sub.i to i64
  %arrayidx7.i = getelementptr inbounds %struct.Line*, %struct.Line** %5, i64 %idxprom6.i
  %8 = load %struct.Line*, %struct.Line** %arrayidx7.i, align 8, !tbaa !2
  %height8.i = getelementptr inbounds %struct.Line, %struct.Line* %8, i64 0, i32 7
  %9 = load i8, i8* %height8.i, align 2, !tbaa !20
  %cmp11.i = icmp ult i8 %9, %h
  br i1 %cmp11.i, label %bsearch_parents.exit, label %if.else.i

if.else.i:                                        ; preds = %lor.lhs.false.i, %for.body.if.else_crit_edge.i
  %sub21.pre-phi.i = phi i32 [ %.pre.i, %for.body.if.else_crit_edge.i ], [ %sub.i, %lor.lhs.false.i ]
  %cmp18.i = icmp ult i8 %7, %h
  %add23.i = add nsw i32 %div.i, 1
  %l.1.i = select i1 %cmp18.i, i32 %add23.i, i32 %l.046.i
  %r.1.i = select i1 %cmp18.i, i32 %r.047.i, i32 %sub21.pre-phi.i
  %cmp.i = icmp sgt i32 %l.1.i, %r.1.i
  br i1 %cmp.i, label %bsearch_parents.exit, label %for.body.i

bsearch_parents.exit:                             ; preds = %if.else.i, %land.lhs.true.i, %lor.lhs.false.i
  %10 = phi i32 [ %l.046.i, %land.lhs.true.i ], [ %div.i, %lor.lhs.false.i ], [ %add15, %if.else.i ]
  store i32 %10, i32* %arrayinit.element13, align 16, !tbaa !31
  %sub17 = add nsw i32 %10, -1
  %conv.i = zext i8 %h to i32
  %mul.i = shl nuw nsw i32 %conv.i, 1
  %sub.i94 = add nsw i32 %mul.i, -2
  %shl.i = shl i32 3, %sub.i94
  %cmp65.i = icmp sle i32 %10, %l
  br i1 %cmp65.i, label %for.inc.1.thread, label %for.body.lr.ph.i95

for.body.lr.ph.i95:                               ; preds = %bsearch_parents.exit
  %shl7.i = shl i32 1, %sub.i94
  %conv12.i = and i32 %shl7.i, 65535
  br label %for.body.i100

for.body.i100:                                    ; preds = %if.else.i108, %for.body.lr.ph.i95
  %r.067.i = phi i32 [ %sub17, %for.body.lr.ph.i95 ], [ %r.1.i106, %if.else.i108 ]
  %l.066.i = phi i32 [ %l, %for.body.lr.ph.i95 ], [ %l.1.i105, %if.else.i108 ]
  %add.i96 = add nsw i32 %l.066.i, %r.067.i
  %div.i97 = sdiv i32 %add.i96, 2
  %idxprom.i98 = sext i32 %div.i97 to i64
  %arrayidx.i99 = getelementptr inbounds %struct.Line*, %struct.Line** %5, i64 %idxprom.i98
  %11 = load %struct.Line*, %struct.Line** %arrayidx.i99, align 8, !tbaa !2
  %index.i = getelementptr inbounds %struct.Line, %struct.Line* %11, i64 0, i32 6
  %12 = load i16, i16* %index.i, align 4, !tbaa !25
  %conv10.i = zext i16 %12 to i32
  %and.i = and i32 %shl.i, %conv10.i
  %cmp13.i = icmp eq i32 %and.i, %conv12.i
  br i1 %cmp13.i, label %land.lhs.true.i103, label %for.body.if.else_crit_edge.i102

for.body.if.else_crit_edge.i102:                  ; preds = %for.body.i100
  %.pre.i101 = add nsw i32 %div.i97, -1
  br label %if.else.i108

land.lhs.true.i103:                               ; preds = %for.body.i100
  %cmp15.i = icmp eq i32 %div.i97, %l.066.i
  br i1 %cmp15.i, label %for.body.lr.ph.i116, label %lor.lhs.false.i104

lor.lhs.false.i104:                               ; preds = %land.lhs.true.i103
  %sub17.i = add nsw i32 %div.i97, -1
  %idxprom18.i = sext i32 %sub17.i to i64
  %arrayidx19.i = getelementptr inbounds %struct.Line*, %struct.Line** %5, i64 %idxprom18.i
  %13 = load %struct.Line*, %struct.Line** %arrayidx19.i, align 8, !tbaa !2
  %index20.i = getelementptr inbounds %struct.Line, %struct.Line* %13, i64 0, i32 6
  %14 = load i16, i16* %index20.i, align 4, !tbaa !25
  %conv21.i = zext i16 %14 to i32
  %and23.i = and i32 %shl.i, %conv21.i
  %cmp25.i = icmp ult i32 %and23.i, %conv12.i
  br i1 %cmp25.i, label %for.body.lr.ph.i116, label %if.else.i108

if.else.i108:                                     ; preds = %lor.lhs.false.i104, %for.body.if.else_crit_edge.i102
  %sub37.pre-phi.i = phi i32 [ %.pre.i101, %for.body.if.else_crit_edge.i102 ], [ %sub17.i, %lor.lhs.false.i104 ]
  %cmp34.i = icmp ult i32 %and.i, %conv12.i
  %add39.i = add nsw i32 %div.i97, 1
  %l.1.i105 = select i1 %cmp34.i, i32 %add39.i, i32 %l.066.i
  %r.1.i106 = select i1 %cmp34.i, i32 %r.067.i, i32 %sub37.pre-phi.i
  %cmp.i107 = icmp sgt i32 %l.1.i105, %r.1.i106
  br i1 %cmp.i107, label %for.body.lr.ph.i116, label %for.body.i100

for.body.lr.ph.i116:                              ; preds = %if.else.i108, %lor.lhs.false.i104, %land.lhs.true.i103
  %15 = phi i32 [ %l.066.i, %land.lhs.true.i103 ], [ %div.i97, %lor.lhs.false.i104 ], [ -1, %if.else.i108 ]
  store i32 %15, i32* %arrayinit.element, align 4, !tbaa !31
  %shl7.i114 = shl i32 2, %sub.i94
  %conv12.i115 = and i32 %shl7.i114, 65535
  br label %for.body.i127

for.body.i127:                                    ; preds = %if.else.i146, %for.body.lr.ph.i116
  %r.067.i117 = phi i32 [ %sub17, %for.body.lr.ph.i116 ], [ %r.1.i144, %if.else.i146 ]
  %l.066.i118 = phi i32 [ %l, %for.body.lr.ph.i116 ], [ %l.1.i143, %if.else.i146 ]
  %add.i119 = add nsw i32 %l.066.i118, %r.067.i117
  %div.i120 = sdiv i32 %add.i119, 2
  %idxprom.i121 = sext i32 %div.i120 to i64
  %arrayidx.i122 = getelementptr inbounds %struct.Line*, %struct.Line** %5, i64 %idxprom.i121
  %16 = load %struct.Line*, %struct.Line** %arrayidx.i122, align 8, !tbaa !2
  %index.i123 = getelementptr inbounds %struct.Line, %struct.Line* %16, i64 0, i32 6
  %17 = load i16, i16* %index.i123, align 4, !tbaa !25
  %conv10.i124 = zext i16 %17 to i32
  %and.i125 = and i32 %shl.i, %conv10.i124
  %cmp13.i126 = icmp eq i32 %and.i125, %conv12.i115
  br i1 %cmp13.i126, label %land.lhs.true.i131, label %for.body.if.else_crit_edge.i129

for.body.if.else_crit_edge.i129:                  ; preds = %for.body.i127
  %.pre.i128 = add nsw i32 %div.i120, -1
  br label %if.else.i146

land.lhs.true.i131:                               ; preds = %for.body.i127
  %cmp15.i130 = icmp eq i32 %div.i120, %l.066.i118
  br i1 %cmp15.i130, label %for.body.lr.ph.i155, label %lor.lhs.false.i139

lor.lhs.false.i139:                               ; preds = %land.lhs.true.i131
  %sub17.i132 = add nsw i32 %div.i120, -1
  %idxprom18.i133 = sext i32 %sub17.i132 to i64
  %arrayidx19.i134 = getelementptr inbounds %struct.Line*, %struct.Line** %5, i64 %idxprom18.i133
  %18 = load %struct.Line*, %struct.Line** %arrayidx19.i134, align 8, !tbaa !2
  %index20.i135 = getelementptr inbounds %struct.Line, %struct.Line* %18, i64 0, i32 6
  %19 = load i16, i16* %index20.i135, align 4, !tbaa !25
  %conv21.i136 = zext i16 %19 to i32
  %and23.i137 = and i32 %shl.i, %conv21.i136
  %cmp25.i138 = icmp ult i32 %and23.i137, %conv12.i115
  br i1 %cmp25.i138, label %for.body.lr.ph.i155, label %if.else.i146

if.else.i146:                                     ; preds = %lor.lhs.false.i139, %for.body.if.else_crit_edge.i129
  %sub37.pre-phi.i140 = phi i32 [ %.pre.i128, %for.body.if.else_crit_edge.i129 ], [ %sub17.i132, %lor.lhs.false.i139 ]
  %cmp34.i141 = icmp ult i32 %and.i125, %conv12.i115
  %add39.i142 = add nsw i32 %div.i120, 1
  %l.1.i143 = select i1 %cmp34.i141, i32 %add39.i142, i32 %l.066.i118
  %r.1.i144 = select i1 %cmp34.i141, i32 %r.067.i117, i32 %sub37.pre-phi.i140
  %cmp.i145 = icmp sgt i32 %l.1.i143, %r.1.i144
  br i1 %cmp.i145, label %for.body.lr.ph.i155, label %for.body.i127

for.inc.1.thread:                                 ; preds = %bsearch_parents.exit
  store i32 -1, i32* %arrayinit.element, align 4, !tbaa !31
  store i32 -1, i32* %arrayinit.element11, align 8, !tbaa !31
  store i32 -1, i32* %arrayinit.element12, align 4, !tbaa !31
  %sub40190 = add i8 %h, -1
  br label %for.inc.2

for.body.lr.ph.i155:                              ; preds = %if.else.i146, %lor.lhs.false.i139, %land.lhs.true.i131
  %20 = phi i32 [ %l.066.i118, %land.lhs.true.i131 ], [ %div.i120, %lor.lhs.false.i139 ], [ -1, %if.else.i146 ]
  store i32 %20, i32* %arrayinit.element11, align 8, !tbaa !31
  %conv12.i154 = and i32 %shl.i, 65535
  br label %for.body.i166

for.body.i166:                                    ; preds = %if.else.i185, %for.body.lr.ph.i155
  %r.067.i156 = phi i32 [ %sub17, %for.body.lr.ph.i155 ], [ %r.1.i183, %if.else.i185 ]
  %l.066.i157 = phi i32 [ %l, %for.body.lr.ph.i155 ], [ %l.1.i182, %if.else.i185 ]
  %add.i158 = add nsw i32 %l.066.i157, %r.067.i156
  %div.i159 = sdiv i32 %add.i158, 2
  %idxprom.i160 = sext i32 %div.i159 to i64
  %arrayidx.i161 = getelementptr inbounds %struct.Line*, %struct.Line** %5, i64 %idxprom.i160
  %21 = load %struct.Line*, %struct.Line** %arrayidx.i161, align 8, !tbaa !2
  %index.i162 = getelementptr inbounds %struct.Line, %struct.Line* %21, i64 0, i32 6
  %22 = load i16, i16* %index.i162, align 4, !tbaa !25
  %conv10.i163 = zext i16 %22 to i32
  %and.i164 = and i32 %shl.i, %conv10.i163
  %cmp13.i165 = icmp eq i32 %and.i164, %conv12.i154
  br i1 %cmp13.i165, label %land.lhs.true.i170, label %for.body.if.else_crit_edge.i168

for.body.if.else_crit_edge.i168:                  ; preds = %for.body.i166
  %.pre.i167 = add nsw i32 %div.i159, -1
  br label %if.else.i185

land.lhs.true.i170:                               ; preds = %for.body.i166
  %cmp15.i169 = icmp eq i32 %div.i159, %l.066.i157
  br i1 %cmp15.i169, label %bsearch_quadrant.exit186, label %lor.lhs.false.i178

lor.lhs.false.i178:                               ; preds = %land.lhs.true.i170
  %sub17.i171 = add nsw i32 %div.i159, -1
  %idxprom18.i172 = sext i32 %sub17.i171 to i64
  %arrayidx19.i173 = getelementptr inbounds %struct.Line*, %struct.Line** %5, i64 %idxprom18.i172
  %23 = load %struct.Line*, %struct.Line** %arrayidx19.i173, align 8, !tbaa !2
  %index20.i174 = getelementptr inbounds %struct.Line, %struct.Line* %23, i64 0, i32 6
  %24 = load i16, i16* %index20.i174, align 4, !tbaa !25
  %conv21.i175 = zext i16 %24 to i32
  %and23.i176 = and i32 %shl.i, %conv21.i175
  %cmp25.i177 = icmp ult i32 %and23.i176, %conv12.i154
  br i1 %cmp25.i177, label %bsearch_quadrant.exit186, label %if.else.i185

if.else.i185:                                     ; preds = %lor.lhs.false.i178, %for.body.if.else_crit_edge.i168
  %sub37.pre-phi.i179 = phi i32 [ %.pre.i167, %for.body.if.else_crit_edge.i168 ], [ %sub17.i171, %lor.lhs.false.i178 ]
  %cmp34.i180 = icmp ult i32 %and.i164, %conv12.i154
  %add39.i181 = add nsw i32 %div.i159, 1
  %l.1.i182 = select i1 %cmp34.i180, i32 %add39.i181, i32 %l.066.i157
  %r.1.i183 = select i1 %cmp34.i180, i32 %r.067.i156, i32 %sub37.pre-phi.i179
  %cmp.i184 = icmp sgt i32 %l.1.i182, %r.1.i183
  br i1 %cmp.i184, label %bsearch_quadrant.exit186, label %for.body.i166

bsearch_quadrant.exit186:                         ; preds = %land.lhs.true.i170, %lor.lhs.false.i178, %if.else.i185
  %25 = phi i32 [ %l.066.i157, %land.lhs.true.i170 ], [ %div.i159, %lor.lhs.false.i178 ], [ -1, %if.else.i185 ]
  store i32 %25, i32* %arrayinit.element12, align 4, !tbaa !31
  %sub40 = add i8 %h, -1
  %cmp31 = icmp eq i32 %15, -1
  br i1 %cmp31, label %for.inc, label %if.then33.tf

if.then33.tf:                                     ; preds = %bsearch_quadrant.exit186
  detach within %syncreg, label %det.achd, label %for.inc

det.achd:                                         ; preds = %if.then33.tf
  %sub38 = add nsw i32 %15, -1
  tail call void @detectLocalizedCollisions(i32 %l, i32 %sub38, i8 zeroext %sub40)
  reattach within %syncreg, label %for.inc

for.inc:                                          ; preds = %if.then33.tf, %det.achd, %bsearch_quadrant.exit186
  %i.1 = phi i32 [ 0, %bsearch_quadrant.exit186 ], [ 1, %det.achd ], [ 1, %if.then33.tf ]
  %cmp31.1 = icmp eq i32 %20, -1
  br i1 %cmp31.1, label %for.inc.1, label %if.then33.tf.1

; CHECK: for.inc:
; CHECK-NEXT: %i.1 = phi i32
; CHECK-DAG: [ 0, %bsearch_quadrant.exit186 ]
; CHECK-DAG: [ 1, %det.achd ]
; CHECK-DAG: [ 1, %if.then33.tf ]
; CHECK-DAG: [ 1, %if.then33.tf.split ]
; CHECK-NEXT: %cmp31.1 = icmp eq i32

det.achd44:                                       ; preds = %for.inc.3
  tail call void @detectCollisionsSlow(i32 %10, i32 %r)
  reattach within %syncreg, label %det.cont45

det.cont45:                                       ; preds = %det.achd44, %for.inc.3
  %cmp52 = icmp sgt i32 %10, %r
  %or.cond93 = or i1 %cmp65.i, %cmp52
  br i1 %or.cond93, label %if.then54, label %if.end55

if.then54:                                        ; preds = %det.cont45
  sync within %syncreg, label %cleanup

if.end55:                                         ; preds = %det.cont45
  tail call void @detectCollisionsSlow2(i32 %l, i32 %sub17, i32 %10, i32 %r)
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %if.end55, %if.then54
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %3) #6
  br label %cleanup.cont

cleanup.cont:                                     ; preds = %entry, %cleanup, %if.then9
  ret void

if.then33.tf.1:                                   ; preds = %for.inc
  %idxprom34.1 = zext i32 %i.1 to i64
  %arrayidx35.1 = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 %idxprom34.1
  %26 = load i32, i32* %arrayidx35.1, align 4, !tbaa !31
  detach within %syncreg, label %det.achd.1, label %for.inc.1

det.achd.1:                                       ; preds = %if.then33.tf.1
  %sub38.1 = add nsw i32 %20, -1
  tail call void @detectLocalizedCollisions(i32 %26, i32 %sub38.1, i8 zeroext %sub40)
  reattach within %syncreg, label %for.inc.1

for.inc.1:                                        ; preds = %det.achd.1, %if.then33.tf.1, %for.inc
  %i.1.1 = phi i32 [ %i.1, %for.inc ], [ 2, %det.achd.1 ], [ 2, %if.then33.tf.1 ]
  %cmp31.2 = icmp eq i32 %25, -1
  br i1 %cmp31.2, label %for.inc.2, label %if.then33.tf.2

; CHECK: for.inc.1:
; CHECK-NEXT: %i.1.1 = phi i32
; CHECK-DAG: [ %i.1, %for.inc ]
; CHECK-DAG: [ 2, %det.achd.1 ]
; CHECK-DAG: [ 2, %if.then33.tf.1 ]
; CHECK-DAG: [ 2, %if.then33.tf.1.split ]
; CHECK-NEXT: %cmp31.2 = icmp eq i32

if.then33.tf.2:                                   ; preds = %for.inc.1
  %idxprom34.2 = sext i32 %i.1.1 to i64
  %arrayidx35.2 = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 %idxprom34.2
  %27 = load i32, i32* %arrayidx35.2, align 4, !tbaa !31
  detach within %syncreg, label %det.achd.2, label %for.inc.2

det.achd.2:                                       ; preds = %if.then33.tf.2
  %sub38.2 = add nsw i32 %25, -1
  tail call void @detectLocalizedCollisions(i32 %27, i32 %sub38.2, i8 zeroext %sub40)
  reattach within %syncreg, label %for.inc.2

for.inc.2:                                        ; preds = %for.inc.1.thread, %det.achd.2, %if.then33.tf.2, %for.inc.1
  %sub40194 = phi i8 [ %sub40, %for.inc.1 ], [ %sub40, %if.then33.tf.2 ], [ %sub40, %det.achd.2 ], [ %sub40190, %for.inc.1.thread ]
  %i.1.2 = phi i32 [ %i.1.1, %for.inc.1 ], [ 3, %if.then33.tf.2 ], [ 3, %det.achd.2 ], [ 0, %for.inc.1.thread ]
  %cmp31.3 = icmp eq i32 %10, -1
  br i1 %cmp31.3, label %for.inc.3, label %if.then33.tf.3

; CHECK: for.inc.2:
; CHECK-NEXT: %sub40194 = phi i8
; CHECK-DAG: [ %sub40, %for.inc.1 ]
; CHECK-DAG: [ %sub40, %if.then33.tf.2 ]
; CHECK-DAG: [ %sub40, %det.achd.2 ]
; CHECK-DAG: [ %sub40190, %for.inc.1.thread ]
; CHECK-DAG: [ %sub40, %if.then33.tf.2.split ]
; CHECK-NEXT: %i.1.2 = phi i32
; CHECK-DAG: [ %i.1.1, %for.inc.1 ]
; CHECK-DAG: [ 3, %if.then33.tf.2 ]
; CHECK-DAG: [ 3, %det.achd.2 ]
; CHECK-DAG: [ 0, %for.inc.1.thread ]
; CHECK-DAG: [ 3, %if.then33.tf.2.split ]
; CHECK-NEXT: %cmp31.3 = icmp eq i32 %10

if.then33.tf.3:                                   ; preds = %for.inc.2
  %idxprom34.3 = sext i32 %i.1.2 to i64
  %arrayidx35.3 = getelementptr inbounds [6 x i32], [6 x i32]* %m, i64 0, i64 %idxprom34.3
  %28 = load i32, i32* %arrayidx35.3, align 4, !tbaa !31
  detach within %syncreg, label %det.achd.3, label %for.inc.3

det.achd.3:                                       ; preds = %if.then33.tf.3
  tail call void @detectLocalizedCollisions(i32 %28, i32 %sub17, i8 zeroext %sub40194)
  reattach within %syncreg, label %for.inc.3

for.inc.3:                                        ; preds = %det.achd.3, %if.then33.tf.3, %for.inc.2
  detach within %syncreg, label %det.achd44, label %det.cont45
}

; Function Attrs: nounwind uwtable
declare dso_local void @detectCollisionsSlow(i32 %l, i32 %r) local_unnamed_addr #0

; Function Attrs: nounwind uwtable
declare dso_local void @detectCollisionsSlow2(i32 %l1, i32 %r1, i32 %l2, i32 %r2) local_unnamed_addr #0

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #3

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable }
attributes #3 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind }

!2 = !{!3, !3, i64 0}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !3, i64 8}
!7 = !{!"CollisionWorld", !8, i64 0, !3, i64 8, !9, i64 16, !9, i64 20, !9, i64 24}
!8 = !{!"double", !4, i64 0}
!9 = !{!"int", !4, i64 0}
!10 = !{!11, !3, i64 0}
!11 = !{!"cilk_c_monoid", !3, i64 0, !3, i64 8, !3, i64 16, !3, i64 24, !3, i64 32}
!12 = !{!11, !3, i64 24}
!13 = !{!11, !3, i64 32}
!14 = !{!15, !9, i64 40}
!15 = !{!"__cilkrts_hyperobject_base", !11, i64 0, !9, i64 40, !16, i64 48, !16, i64 56}
!16 = !{!"long", !4, i64 0}
!17 = !{!16, !16, i64 0}
!18 = !{!7, !9, i64 16}
!19 = !{i64 0, i64 8, !2, i64 8, i64 8, !2}
!20 = !{!21, !4, i64 86}
!21 = !{!"Line", !22, i64 0, !22, i64 16, !22, i64 32, !22, i64 48, !22, i64 64, !4, i64 80, !23, i64 84, !4, i64 86, !24, i64 88, !9, i64 120}
!22 = !{!"Vec", !8, i64 0, !8, i64 8}
!23 = !{!"short", !4, i64 0}
!24 = !{!"Box", !8, i64 0, !8, i64 8, !8, i64 16, !8, i64 24}
!25 = !{!21, !23, i64 84}
!26 = !{!21, !9, i64 120}
!27 = !{!7, !8, i64 0}
!28 = distinct !{!28, !29}
!29 = !{!"tapir.loop.spawn.strategy", i32 1}
!30 = distinct !{!30, !29}
!31 = !{!9, !9, i64 0}
!32 = !{!7, !9, i64 24}
