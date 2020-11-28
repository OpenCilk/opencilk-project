; Thanks to Sai Sameer Pusapaty and Shreyas Balaji for the original
; source code for this test case.
;
; RUN: opt < %s -loop-unswitch -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%struct.graph = type { %struct.vertex*, i32, i32, i32* }
%struct.vertex = type <{ i32*, i32, [4 x i8] }>

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_alg4.cpp, i8* null }]

; Function Attrs: uwtable
define internal fastcc void @__cxx_global_var_init() unnamed_addr #0 section ".text.startup" {
entry:
  tail call void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"* nonnull @_ZStL8__ioinit)
  %0 = tail call i32 @__cxa_atexit(void (i8*)* bitcast (void (%"class.std::ios_base::Init"*)* @_ZNSt8ios_base4InitD1Ev to void (i8*)*), i8* getelementptr inbounds (%"class.std::ios_base::Init", %"class.std::ios_base::Init"* @_ZStL8__ioinit, i64 0, i32 0), i8* nonnull @__dso_handle) #10
  ret void
}

declare dso_local void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"*) unnamed_addr #1

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init"*) unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local i32 @__cxa_atexit(void (i8*)*, i8*, i8*) local_unnamed_addr #3

; Function Attrs: nounwind uwtable
define internal fastcc void @__cxx_global_var_init.1() unnamed_addr #4 section ".text.startup" {
entry:
  %call = tail call i32 @mallopt(i32 -4, i32 0) #10
  ret void
}

; Function Attrs: nounwind
declare dso_local i32 @mallopt(i32, i32) local_unnamed_addr #2

; Function Attrs: nounwind uwtable
define internal fastcc void @__cxx_global_var_init.2() unnamed_addr #4 section ".text.startup" {
entry:
  %call = tail call i32 @mallopt(i32 -1, i32 -1) #10
  ret void
}

; Function Attrs: argmemonly norecurse nounwind readonly uwtable
define dso_local i32 @_Z12intersectionPKiiS0_i(i32* nocapture readonly %AdjA, i32 %na, i32* nocapture readonly %AdjB, i32 %nb) local_unnamed_addr #5 {
entry:
  %cmp28 = icmp sgt i32 %na, 0
  %cmp129 = icmp sgt i32 %nb, 0
  %or.cond30 = and i1 %cmp129, %cmp28
  br i1 %or.cond30, label %while.body, label %while.end

while.body:                                       ; preds = %entry, %if.end12
  %intersect.033 = phi i32 [ %intersect.1, %if.end12 ], [ 0, %entry ]
  %ii.032 = phi i32 [ %ii.1, %if.end12 ], [ 0, %entry ]
  %jj.031 = phi i32 [ %jj.1, %if.end12 ], [ 0, %entry ]
  %idxprom = sext i32 %ii.032 to i64
  %arrayidx = getelementptr inbounds i32, i32* %AdjA, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !2
  %idxprom2 = sext i32 %jj.031 to i64
  %arrayidx3 = getelementptr inbounds i32, i32* %AdjB, i64 %idxprom2
  %1 = load i32, i32* %arrayidx3, align 4, !tbaa !2
  %cmp4 = icmp eq i32 %0, %1
  br i1 %cmp4, label %if.then, label %if.else

if.then:                                          ; preds = %while.body
  %inc = add nsw i32 %ii.032, 1
  %inc5 = add nsw i32 %jj.031, 1
  %inc6 = add nsw i32 %intersect.033, 1
  br label %if.end12

if.else:                                          ; preds = %while.body
  %cmp7 = icmp slt i32 %0, %1
  br i1 %cmp7, label %if.then8, label %if.else10

if.then8:                                         ; preds = %if.else
  %inc9 = add nsw i32 %ii.032, 1
  br label %if.end12

if.else10:                                        ; preds = %if.else
  %inc11 = add nsw i32 %jj.031, 1
  br label %if.end12

if.end12:                                         ; preds = %if.then8, %if.else10, %if.then
  %jj.1 = phi i32 [ %inc5, %if.then ], [ %jj.031, %if.then8 ], [ %inc11, %if.else10 ]
  %ii.1 = phi i32 [ %inc, %if.then ], [ %inc9, %if.then8 ], [ %ii.032, %if.else10 ]
  %intersect.1 = phi i32 [ %inc6, %if.then ], [ %intersect.033, %if.then8 ], [ %intersect.033, %if.else10 ]
  %cmp = icmp slt i32 %ii.1, %na
  %cmp1 = icmp slt i32 %jj.1, %nb
  %or.cond = and i1 %cmp1, %cmp
  br i1 %or.cond, label %while.body, label %while.end

while.end:                                        ; preds = %if.end12, %entry
  %intersect.0.lcssa = phi i32 [ 0, %entry ], [ %intersect.1, %if.end12 ]
  ret i32 %intersect.0.lcssa
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #6

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #6

; Function Attrs: argmemonly norecurse nounwind readonly uwtable
define dso_local i32 @_Z13binary_searchiPKii(i32 %num, i32* nocapture readonly %arr, i32 %size) local_unnamed_addr #5 {
entry:
  br label %while.cond.outer

while.cond.outer:                                 ; preds = %cleanup, %entry
  %r.0.ph.in = phi i32 [ %div, %cleanup ], [ %size, %entry ]
  %l.0.ph = phi i32 [ %l.049, %cleanup ], [ 0, %entry ]
  %r.0.ph = add nsw i32 %r.0.ph.in, -1
  %cmp48 = icmp slt i32 %l.0.ph, %r.0.ph.in
  br i1 %cmp48, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond.outer, %if.then
  %l.049 = phi i32 [ %add2, %if.then ], [ %l.0.ph, %while.cond.outer ]
  %add = add nsw i32 %l.049, %r.0.ph
  %div = sdiv i32 %add, 2
  %idxprom = sext i32 %div to i64
  %arrayidx = getelementptr inbounds i32, i32* %arr, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !2
  %cmp1 = icmp slt i32 %0, %num
  br i1 %cmp1, label %if.then, label %cleanup

if.then:                                          ; preds = %while.body
  %add2 = add nsw i32 %div, 1
  %cmp = icmp slt i32 %div, %r.0.ph
  br i1 %cmp, label %while.body, label %while.end

cleanup:                                          ; preds = %while.body
  %cmp5 = icmp sgt i32 %0, %num
  br i1 %cmp5, label %while.cond.outer, label %cleanup21

while.end:                                        ; preds = %while.cond.outer, %if.then
  %l.0.lcssa = phi i32 [ %add2, %if.then ], [ %l.0.ph, %while.cond.outer ]
  %cmp10 = icmp slt i32 %r.0.ph.in, 1
  br i1 %cmp10, label %cleanup21, label %if.else12

if.else12:                                        ; preds = %while.end
  %cmp14 = icmp slt i32 %l.0.lcssa, %size
  br i1 %cmp14, label %if.else16, label %cleanup21

if.else16:                                        ; preds = %if.else12
  %cmp17 = icmp slt i32 %l.0.lcssa, %r.0.ph
  %cond.v = select i1 %cmp17, i32 %l.0.lcssa, i32 %r.0.ph
  %cond = add nsw i32 %cond.v, 1
  br label %cleanup21

cleanup21:                                        ; preds = %cleanup, %if.else12, %while.end, %if.else16
  %retval.2 = phi i32 [ %cond, %if.else16 ], [ 0, %while.end ], [ %size, %if.else12 ], [ %div, %cleanup ]
  ret i32 %retval.2
}

; Function Attrs: argmemonly readonly uwtable
define dso_local i32 @_Z11p_intersectPKiiS0_i(i32* nocapture readonly %AdjA, i32 %na, i32* nocapture readonly %AdjB, i32 %nb) local_unnamed_addr #7 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %intersection_l = alloca i32, align 4
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp slt i32 %na, %nb
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = tail call i32 @_Z11p_intersectPKiiS0_i(i32* %AdjB, i32 %nb, i32* %AdjA, i32 %na)
  br label %cleanup

if.else:                                          ; preds = %entry
  %cmp1 = icmp slt i32 %na, 100
  br i1 %cmp1, label %if.then2, label %if.else4

if.then2:                                         ; preds = %if.else
  %call3 = tail call i32 @_Z12intersectionPKiiS0_i(i32* %AdjA, i32 %na, i32* %AdjB, i32 %nb)
  br label %cleanup

if.else4:                                         ; preds = %if.else
  %div55 = lshr i32 %na, 1
  %idxprom = zext i32 %div55 to i64
  %arrayidx = getelementptr inbounds i32, i32* %AdjA, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !2
  %call5 = tail call i32 @_Z13binary_searchiPKii(i32 %0, i32* %AdjB, i32 %nb)
  %intersection_l.0.intersection_l.0..sroa_cast = bitcast i32* %intersection_l to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %intersection_l.0.intersection_l.0..sroa_cast)
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad7

det.achd:                                         ; preds = %if.else4
  %call6 = invoke i32 @_Z11p_intersectPKiiS0_i(i32* nonnull %AdjA, i32 %div55, i32* %AdjB, i32 %call5)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %det.achd
  store i32 %call6, i32* %intersection_l, align 4, !tbaa !2
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %if.else4, %invoke.cont
  %sub = sub nsw i32 %na, %div55
  %idx.ext11 = sext i32 %call5 to i64
  %add.ptr12 = getelementptr inbounds i32, i32* %AdjB, i64 %idx.ext11
  %sub13 = sub nsw i32 %nb, %call5
  %call15 = invoke i32 @_Z11p_intersectPKiiS0_i(i32* %arrayidx, i32 %sub, i32* %add.ptr12, i32 %sub13)
          to label %invoke.cont14 unwind label %lpad7

invoke.cont14:                                    ; preds = %det.cont
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %invoke.cont14
  %intersection_l.0.load54 = load i32, i32* %intersection_l, align 4
  %add = add nsw i32 %intersection_l.0.load54, %call15
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %intersection_l.0.intersection_l.0..sroa_cast)
  br label %cleanup

lpad:                                             ; preds = %det.achd
  %1 = landingpad { i8*, i32 }
          catch i8* null
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %1)
          to label %det.rethrow.unreachable unwind label %lpad7

det.rethrow.unreachable:                          ; preds = %lpad
  unreachable

lpad7:                                            ; preds = %det.cont, %if.else4, %lpad
  %2 = landingpad { i8*, i32 }
          cleanup
  sync within %syncreg, label %sync.continue16

sync.continue16:                                  ; preds = %lpad7
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %intersection_l.0.intersection_l.0..sroa_cast)
  resume { i8*, i32 } %2

cleanup:                                          ; preds = %sync.continue, %if.then2, %if.then
  %retval.0 = phi i32 [ %call, %if.then ], [ %call3, %if.then2 ], [ %add, %sync.continue ]
  ret i32 %retval.0
}

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #6

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #8

; Function Attrs: uwtable
define dso_local noalias float* @_Z11algorithm_45graphIiE(%struct.graph* nocapture readonly byval(%struct.graph) align 8 %G) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %n = getelementptr inbounds %struct.graph, %struct.graph* %G, i64 0, i32 1
  %0 = load i32, i32* %n, align 8, !tbaa !6
  %conv = sext i32 %0 to i64
  %mul = shl nsw i64 %conv, 2
  %mul3 = mul nsw i64 %mul, %conv
  %call = tail call noalias i8* @malloc(i64 %mul3) #10
  %1 = bitcast i8* %call to float*
  %cmp = icmp sgt i32 %0, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup78

pfor.cond.preheader:                              ; preds = %entry
  %V = getelementptr inbounds %struct.graph, %struct.graph* %G, i64 0, i32 0
  %2 = load %struct.vertex*, %struct.vertex** %V, align 8
  %wide.trip.count139 = zext i32 %0 to i64
  %wide.trip.count = zext i32 %0 to i64
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc60, %pfor.cond.preheader
  %indvars.iv137 = phi i64 [ 0, %pfor.cond.preheader ], [ %indvars.iv.next138, %pfor.inc60 ]
  %indvars.iv.next138 = add nuw nsw i64 %indvars.iv137, 1
  detach within %syncreg, label %pfor.body, label %pfor.inc60 unwind label %lpad62.loopexit

pfor.body:                                        ; preds = %pfor.cond
  %syncreg8 = tail call token @llvm.syncregion.start()
  br i1 %cmp, label %pfor.cond22.preheader, label %cleanup

pfor.cond22.preheader:                            ; preds = %pfor.body
  %degree = getelementptr inbounds %struct.vertex, %struct.vertex* %2, i64 %indvars.iv137, i32 1
  %3 = load i32, i32* %degree, align 8, !tbaa !9
  %Neighbors = getelementptr inbounds %struct.vertex, %struct.vertex* %2, i64 %indvars.iv137, i32 0
  %4 = load i32*, i32** %Neighbors, align 8, !tbaa !11
  %mul48 = mul nsw i64 %indvars.iv137, %conv
  br label %pfor.cond22

pfor.cond22:                                      ; preds = %pfor.inc, %pfor.cond22.preheader
  %indvars.iv = phi i64 [ 0, %pfor.cond22.preheader ], [ %indvars.iv.next, %pfor.inc ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  detach within %syncreg8, label %pfor.body27, label %pfor.inc unwind label %lpad52.loopexit

pfor.body27:                                      ; preds = %pfor.cond22
  %degree31 = getelementptr inbounds %struct.vertex, %struct.vertex* %2, i64 %indvars.iv, i32 1
  %5 = load i32, i32* %degree31, align 8, !tbaa !9
  %Neighbors38 = getelementptr inbounds %struct.vertex, %struct.vertex* %2, i64 %indvars.iv, i32 0
  %6 = load i32*, i32** %Neighbors38, align 8, !tbaa !11
  %call39 = invoke i32 @_Z11p_intersectPKiiS0_i(i32* %4, i32 %3, i32* %6, i32 %5)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %pfor.body27
  %conv40 = sitofp i32 %call39 to float
  %add41 = add nsw i32 %5, %3
  %sub42 = sub i32 %add41, %call39
  %conv43 = sitofp i32 %sub42 to float
  %div44 = fdiv float %conv40, %conv43
  %add50 = add nsw i64 %mul48, %indvars.iv
  %arrayidx51 = getelementptr inbounds float, float* %1, i64 %add50
  store float %div44, float* %arrayidx51, align 4, !tbaa !12
  reattach within %syncreg8, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.cond22, %invoke.cont
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond22, !llvm.loop !14

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg8, label %cleanup

lpad:                                             ; preds = %pfor.body27
  %7 = landingpad { i8*, i32 }
          catch i8* null
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg8, { i8*, i32 } %7)
          to label %det.rethrow.unreachable unwind label %lpad52.loopexit

det.rethrow.unreachable:                          ; preds = %lpad
  unreachable

lpad52.loopexit:                                  ; preds = %pfor.cond22
  %lpad.loopexit = landingpad { i8*, i32 }
          catch i8* null
  br label %lpad52

lpad52:                                           ; preds = %lpad52.loopexit.split-lp, %lpad52.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad52.loopexit ]
  sync within %syncreg8, label %sync.continue57

sync.continue57:                                  ; preds = %lpad52
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %lpad.phi)
          to label %det.rethrow.unreachable70 unwind label %lpad62.loopexit

det.rethrow.unreachable70:                        ; preds = %sync.continue57
  unreachable

cleanup:                                          ; preds = %pfor.cond.cleanup, %pfor.body
  reattach within %syncreg, label %pfor.inc60

pfor.inc60:                                       ; preds = %pfor.cond, %cleanup
  %exitcond140 = icmp eq i64 %indvars.iv.next138, %wide.trip.count139
  br i1 %exitcond140, label %pfor.cond.cleanup72, label %pfor.cond, !llvm.loop !16

pfor.cond.cleanup72:                              ; preds = %pfor.inc60
  sync within %syncreg, label %cleanup78

lpad62.loopexit:                                  ; preds = %pfor.cond
  %lpad.loopexit134 = landingpad { i8*, i32 }
          cleanup
  br label %lpad62

lpad62:                                           ; preds = %lpad62.loopexit.split-lp, %lpad62.loopexit
  %lpad.phi136 = phi { i8*, i32 } [ %lpad.loopexit134, %lpad62.loopexit ]
  sync within %syncreg, label %sync.continue75

sync.continue75:                                  ; preds = %lpad62
  resume { i8*, i32 } %lpad.phi136

cleanup78:                                        ; preds = %pfor.cond.cleanup72, %entry
  ret float* %1
}

; CHECK: define {{.+}}@_Z11algorithm_45graphIiE(

; CHECK: pfor.cond.us:
; CHECK: detach within %syncreg, label %pfor.body.us, label %pfor.inc60.us unwind label %lpad62.loopexit.us-lcssa.us

; CHECK: pfor.body.us:
; CHECK-NEXT: %[[USSYNCREG:.+]] = {{.+}}call token @llvm.syncregion

; CHECK: pfor.cond22.us:
; CHECK: detach within %[[USSYNCREG]], label %pfor.body27.us, label %pfor.inc.us unwind label %lpad52.loopexit.us

; CHECK: pfor.body27.us:
; CHECK: invoke i32 @_Z11p_intersectPKiiS0_i(
; CHECK-NEXT: to label %invoke.cont.us unwind label %lpad.us

; CHECK: lpad52.loopexit.us:
; CHECK: br label %lpad52.us

; CHECK: lpad52.us:
; CHECK: sync within %[[USSYNCREG]], label %sync.continue57.us

; CHECK: sync.continue57.us:
; The sync region of this detached-rethrow should match that of the
; detach in pfor.cond.us.
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg,

; CHECK: lpad.us:
; The sync region of this detached-rethrow should match that of the
; detach in pfor.cond22.us.
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[USSYNCREG]]

; CHECK: lpad62.loopexit.us-lcssa.us:
; CHECK: br label %lpad62.loopexit

; CHECK: pfor.cond:
; CHECK: detach within %syncreg, label %pfor.body, label %pfor.inc60 unwind label %lpad62.loopexit.us-lcssa

; CHECK: pfor.body:
; CHECK: %[[OGSYNCREG:.+]] = {{.+}}call token @llvm.syncregion

; CHECK: pfor.cond22:
; CHECK: detach within %[[OGSYNCREG]], label %pfor.body27, label %pfor.inc unwind label %lpad52.loopexit

; CHECK: pfor.body27:
; CHECK: invoke i32 @_Z11p_intersectPKiiS0_i(
; CHECK-NEXT: to label %invoke.cont unwind label %lpad

; CHECK: lpad:
; The sync region of this detached-rethrow should match that of the
; detach in pfor.cond22
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[OGSYNCREG]]

; CHECK: lpad52.loopexit:
; CHECK: br label %lpad52

; CHECK: lpad52:
; CHECK: sync within %[[OGSYNCREG]], label %sync.continue57

; CHECK: sync.continue57:
; The sync region of this detached-rethrow should match that of the
; detach in pfor.cond.
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg

; CHECK: lpad62.loopexit:
; CHECK: br label %lpad62

; CHECK: lpad62:
; CHECK: sync within %syncreg

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @malloc(i64) local_unnamed_addr #9

; Function Attrs: uwtable
define internal void @_GLOBAL__sub_I_alg4.cpp() #0 section ".text.startup" {
entry:
  tail call fastcc void @__cxx_global_var_init()
  tail call fastcc void @__cxx_global_var_init.1()
  tail call fastcc void @__cxx_global_var_init.2()
  ret void
}

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nofree nounwind }
attributes #4 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { argmemonly norecurse nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { argmemonly nounwind }
attributes #7 = { argmemonly readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { argmemonly }
attributes #9 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git 04e9abf109e34719ed58277b4e7de1a98c34f3e0)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !3, i64 8}
!7 = !{!"_ZTS5graphIiE", !8, i64 0, !3, i64 8, !3, i64 12, !8, i64 16}
!8 = !{!"any pointer", !4, i64 0}
!9 = !{!10, !3, i64 8}
!10 = !{!"_ZTS6vertexIiE", !8, i64 0, !3, i64 8}
!11 = !{!10, !8, i64 0}
!12 = !{!13, !13, i64 0}
!13 = !{!"float", !4, i64 0}
!14 = distinct !{!14, !15}
!15 = !{!"tapir.loop.spawn.strategy", i32 1}
!16 = distinct !{!16, !15}
