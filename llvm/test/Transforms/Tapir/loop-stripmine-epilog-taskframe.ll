; RUN: opt < %s -passes="loop-stripmine" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<long, std::allocator<long>>::_Vector_impl" }
%"struct.std::_Vector_base<long, std::allocator<long>>::_Vector_impl" = type { %"struct.std::_Vector_base<long, std::allocator<long>>::_Vector_impl_data" }
%"struct.std::_Vector_base<long, std::allocator<long>>::_Vector_impl_data" = type { i64*, i64*, i64* }

$_Z3sumIlEvRSt6vectorIT_SaIS1_EE = comdat any

$_ZNSt6vectorIlSaIlEE17_M_realloc_insertIJRKlEEEvN9__gnu_cxx17__normal_iteratorIPlS1_EEDpOT_ = comdat any

@.str = private unnamed_addr constant [26 x i8] c"vector::_M_realloc_insert\00", align 1
@.str.1 = private unnamed_addr constant [38 x i8] c"sum_pos %ld\0Asum_neg %ld\0Asum_racy %ld\0A\00", align 1
@str = private unnamed_addr constant [45 x i8] c"WARNING: sum_pos is not negation of sum_neg!\00", align 1

; Function Attrs: norecurse uwtable
define dso_local noundef i32 @main(i32 noundef %argc, i8** nocapture noundef readonly %argv) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %vec = alloca %"class.std::vector", align 8
  %i = alloca i64, align 8
  %cmp = icmp sgt i32 %argc, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %arrayidx = getelementptr inbounds i8*, i8** %argv, i64 1
  %0 = load i8*, i8** %arrayidx, align 8, !tbaa !3
  %call.i = call i64 @strtol(i8* nocapture noundef nonnull %0, i8** noundef null, i32 noundef 10) #20
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %n.0 = phi i64 [ %call.i, %if.then ], [ 10000, %entry ]
  %1 = bitcast %"class.std::vector"* %vec to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %1) #20
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 8 dereferenceable(24) %1, i8 0, i64 24, i1 false) #20
  %2 = bitcast i64* %i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %2) #20
  store i64 0, i64* %i, align 8, !tbaa !7
  %cmp114 = icmp sgt i64 %n.0, 0
  br i1 %cmp114, label %for.body.lr.ph, label %for.cond.cleanup

for.body.lr.ph:                                   ; preds = %if.end
  %_M_finish.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %vec, i64 0, i32 0, i32 0, i32 0, i32 1
  %_M_end_of_storage.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %vec, i64 0, i32 0, i32 0, i32 0, i32 2
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.inc, %if.end
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %2) #20
  invoke void @_Z3sumIlEvRSt6vectorIT_SaIS1_EE(%"class.std::vector"* noundef nonnull align 8 dereferenceable(24) %vec)
          to label %invoke.cont3 unwind label %lpad2

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %storemerge15 = phi i64 [ 0, %for.body.lr.ph ], [ %inc, %for.inc ]
  %3 = load i64*, i64** %_M_finish.i, align 8, !tbaa !9
  %4 = load i64*, i64** %_M_end_of_storage.i, align 8, !tbaa !11
  %cmp.not.i = icmp eq i64* %3, %4
  br i1 %cmp.not.i, label %if.else.i, label %if.then.i

if.then.i:                                        ; preds = %for.body
  store i64 %storemerge15, i64* %3, align 8, !tbaa !7
  %incdec.ptr.i = getelementptr inbounds i64, i64* %3, i64 1
  store i64* %incdec.ptr.i, i64** %_M_finish.i, align 8, !tbaa !9
  br label %for.inc

if.else.i:                                        ; preds = %for.body
  invoke void @_ZNSt6vectorIlSaIlEE17_M_realloc_insertIJRKlEEEvN9__gnu_cxx17__normal_iteratorIPlS1_EEDpOT_(%"class.std::vector"* noundef nonnull align 8 dereferenceable(24) %vec, i64* %3, i64* noundef nonnull align 8 dereferenceable(8) %i)
          to label %for.inc unwind label %lpad

for.inc:                                          ; preds = %if.then.i, %if.else.i
  %5 = load i64, i64* %i, align 8, !tbaa !7
  %inc = add nsw i64 %5, 1
  store i64 %inc, i64* %i, align 8, !tbaa !7
  %cmp1 = icmp slt i64 %inc, %n.0
  br i1 %cmp1, label %for.body, label %for.cond.cleanup, !llvm.loop !12

lpad:                                             ; preds = %if.else.i
  %6 = landingpad { i8*, i32 }
          cleanup
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %2) #20
  br label %ehcleanup

invoke.cont3:                                     ; preds = %for.cond.cleanup
  %_M_start.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %vec, i64 0, i32 0, i32 0, i32 0, i32 0
  %7 = load i64*, i64** %_M_start.i.i, align 8, !tbaa !15
  %tobool.not.i.i.i = icmp eq i64* %7, null
  br i1 %tobool.not.i.i.i, label %_ZNSt6vectorIlSaIlEED2Ev.exit, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %invoke.cont3
  %8 = bitcast i64* %7 to i8*
  call void @_ZdlPv(i8* noundef %8) #21
  br label %_ZNSt6vectorIlSaIlEED2Ev.exit

_ZNSt6vectorIlSaIlEED2Ev.exit:                    ; preds = %invoke.cont3, %if.then.i.i.i
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %1) #20
  ret i32 0

lpad2:                                            ; preds = %for.cond.cleanup
  %9 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad2, %lpad
  %.pn = phi { i8*, i32 } [ %6, %lpad ], [ %9, %lpad2 ]
  %_M_start.i.i10 = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %vec, i64 0, i32 0, i32 0, i32 0, i32 0
  %10 = load i64*, i64** %_M_start.i.i10, align 8, !tbaa !15
  %tobool.not.i.i.i11 = icmp eq i64* %10, null
  br i1 %tobool.not.i.i.i11, label %_ZNSt6vectorIlSaIlEED2Ev.exit13, label %if.then.i.i.i12

if.then.i.i.i12:                                  ; preds = %ehcleanup
  %11 = bitcast i64* %10 to i8*
  call void @_ZdlPv(i8* noundef %11) #21
  br label %_ZNSt6vectorIlSaIlEED2Ev.exit13

_ZNSt6vectorIlSaIlEED2Ev.exit13:                  ; preds = %ehcleanup, %if.then.i.i.i12
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %1) #20
  resume { i8*, i32 } %.pn
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_Z3sumIlEvRSt6vectorIT_SaIS1_EE(%"class.std::vector"* noundef nonnull align 8 dereferenceable(24) %v) local_unnamed_addr #2 comdat personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %sum_racy = alloca i64, align 8
  %sum_pos = alloca i64, align 8
  %sum_neg = alloca i64, align 8
  %syncreg = call token @llvm.syncregion.start()
  %sum_racy.0.sum_racy.0.sum_racy.0..sroa_cast = bitcast i64* %sum_racy to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %sum_racy.0.sum_racy.0.sum_racy.0..sroa_cast)
  store i64 0, i64* %sum_racy, align 8, !tbaa !7
  %0 = bitcast i64* %sum_pos to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %0) #20
  store i64 0, i64* %sum_pos, align 8, !tbaa !7
  call void @llvm.reducer.register.i64(i8* nonnull %0, i64 8, i8* bitcast (void (i8*)* @_ZN4cilkL4zeroIlEEvPv to i8*), i8* bitcast (void (i8*, i8*)* @_ZN4cilkL4plusIlEEvPvS1_ to i8*))
  %1 = bitcast i64* %sum_neg to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1) #20
  store i64 0, i64* %sum_neg, align 8, !tbaa !7
  call void @llvm.reducer.register.i64(i8* nonnull %1, i64 8, i8* bitcast (void (i8*)* @_ZN4cilkL4zeroIlEEvPv to i8*), i8* bitcast (void (i8*, i8*)* @_ZN4cilkL4plusIlEEvPvS1_ to i8*))
  %_M_finish.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %v, i64 0, i32 0, i32 0, i32 0, i32 1
  %2 = load i64*, i64** %_M_finish.i, align 8, !tbaa !9
  %_M_start.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %v, i64 0, i32 0, i32 0, i32 0, i32 0
  %3 = load i64*, i64** %_M_start.i, align 8, !tbaa !15
  %sub.ptr.lhs.cast.i = ptrtoint i64* %2 to i64
  %sub.ptr.rhs.cast.i = ptrtoint i64* %3 to i64
  %sub.ptr.sub.i = sub i64 %sub.ptr.lhs.cast.i, %sub.ptr.rhs.cast.i
  %cmp = icmp sgt i64 %sub.ptr.sub.i, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %entry
  %sub.ptr.div.i = ashr i64 %sub.ptr.sub.i, 3
  %smax = call i64 @llvm.smax.i64(i64 %sub.ptr.div.i, i64 1)
  br label %pfor.cond

; CHECK: pfor.cond.preheader:
; CHECK: %[[ICMP:.+]] = icmp ult i64
; CHECK-NEXT: br i1 %[[ICMP]], label %[[EPIL_CHECK:.+]], label %[[PLOOP_START:.+]]

; CHECK: [[EPIL_CHECK]]:
; CHECK: %[[ICMP_XTRA:.+]] = icmp ne i64
; CHECK-NEXT: br i1 %[[ICMP_XTRA]], label %[[EPIL_PH:.+]], label %pfor.cond.cleanup

; CHECK: [[EPIL_PH]]:
; CHECK: br label %[[EPIL_HEAD:.+]]

; CHECK: [[EPIL_HEAD]]:
; CHECK: br label %[[EPIL_BODY_ENTRY:.+]]

; CHECK: [[EPIL_BODY_ENTRY]]:
; CHECK-NEXT: %[[REPLTF:.+]] = call token @llvm.taskframe.create()

; CHECK: detach within %[[SYNCREG_EPIL:.+]], label %[[EPIL_DETACHED:.+]], label %[[EPIL_DETCONT:.+]]

; CHECK: [[EPIL_DETCONT]]:
; CHECK: sync within %[[SYNCREG_EPIL]], label %[[SYNC_CONT_EPIL:.+]]

; CHECK: [[SYNC_CONT_EPIL]]:
; CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG_EPIL]])
; CHECK-NEXT: to label %[[EPIL_PREATTACH:.+]] unwind label %[[EPIL_LPAD:.+]]

; CHECK: [[EPIL_PREATTACH]]:
; CHECK-NEXT: call void @llvm.taskframe.end(token %[[REPLTF]])
; CHECK-NEXT: br label %[[EPIL_INC:.+]]

; CHECK: [[EPIL_LPAD]]:
; CHECK-NEXT: %[[LANDINGPAD:.+]] = landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[REPLTF]], { ptr, i32 } %[[LANDINGPAD]])
; CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[DETLOOP_UNWIND:.+]]

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc unwind label %lpad17.loopexit

pfor.body.entry:                                  ; preds = %pfor.cond
  %syncreg3 = call token @llvm.syncregion.start()
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  detach within %syncreg3, label %det.achd, label %det.cont

det.achd:                                         ; preds = %pfor.body
  %add.ptr.i = getelementptr inbounds i64, i64* %3, i64 %__begin.0
  %4 = load i64, i64* %add.ptr.i, align 8, !tbaa !7
  %sum_racy.0.load = load i64, i64* %sum_racy, align 8
  %add5 = add nsw i64 %sum_racy.0.load, %4
  store i64 %add5, i64* %sum_racy, align 8, !tbaa !7
  %5 = call i8* @llvm.hyper.lookup.i64(i8* nonnull %0, i64 8, i8* bitcast (void (i8*)* @_ZN4cilkL4zeroIlEEvPv to i8*), i8* bitcast (void (i8*, i8*)* @_ZN4cilkL4plusIlEEvPvS1_ to i8*))
  %6 = bitcast i8* %5 to i64*
  %7 = load i64, i64* %6, align 8, !tbaa !7
  %add7 = add nsw i64 %7, %4
  store i64 %add7, i64* %6, align 8, !tbaa !7
  %8 = load i64, i64* %add.ptr.i, align 8, !tbaa !7
  %9 = call i8* @llvm.hyper.lookup.i64(i8* nonnull %1, i64 8, i8* bitcast (void (i8*)* @_ZN4cilkL4zeroIlEEvPv to i8*), i8* bitcast (void (i8*, i8*)* @_ZN4cilkL4plusIlEEvPvS1_ to i8*))
  %10 = bitcast i8* %9 to i64*
  %11 = load i64, i64* %10, align 8, !tbaa !7
  %sub9 = sub nsw i64 %11, %8
  store i64 %sub9, i64* %10, align 8, !tbaa !7
  reattach within %syncreg3, label %det.cont

det.cont:                                         ; preds = %det.achd, %pfor.body
  %add.ptr.i79 = getelementptr inbounds i64, i64* %3, i64 %__begin.0
  %12 = load i64, i64* %add.ptr.i79, align 8, !tbaa !7
  %sum_racy.0.load91 = load i64, i64* %sum_racy, align 8
  %add11 = add nsw i64 %sum_racy.0.load91, %12
  store i64 %add11, i64* %sum_racy, align 8, !tbaa !7
  %13 = call i8* @llvm.hyper.lookup.i64(i8* nonnull %0, i64 8, i8* bitcast (void (i8*)* @_ZN4cilkL4zeroIlEEvPv to i8*), i8* bitcast (void (i8*, i8*)* @_ZN4cilkL4plusIlEEvPvS1_ to i8*))
  %14 = bitcast i8* %13 to i64*
  %15 = load i64, i64* %14, align 8, !tbaa !7
  %add13 = add nsw i64 %15, %12
  store i64 %add13, i64* %14, align 8, !tbaa !7
  %16 = load i64, i64* %add.ptr.i79, align 8, !tbaa !7
  %17 = call i8* @llvm.hyper.lookup.i64(i8* nonnull %1, i64 8, i8* bitcast (void (i8*)* @_ZN4cilkL4zeroIlEEvPv to i8*), i8* bitcast (void (i8*, i8*)* @_ZN4cilkL4plusIlEEvPvS1_ to i8*))
  %18 = bitcast i8* %17 to i64*
  %19 = load i64, i64* %18, align 8, !tbaa !7
  %sub15 = sub nsw i64 %19, %16
  store i64 %sub15, i64* %18, align 8, !tbaa !7
  sync within %syncreg3, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  invoke void @llvm.sync.unwind(token %syncreg3)
          to label %pfor.preattach unwind label %lpad

pfor.preattach:                                   ; preds = %sync.continue
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.cond, %pfor.preattach
  %inc = add nuw nsw i64 %__begin.0, 1
  %exitcond.not = icmp eq i64 %inc, %smax
  br i1 %exitcond.not, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !16

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue21

lpad:                                             ; preds = %sync.continue
  %20 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %20)
          to label %unreachable unwind label %lpad17.loopexit

lpad17.loopexit:                                  ; preds = %lpad, %pfor.cond
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  br label %lpad17

lpad17.loopexit.split-lp:                         ; preds = %sync.continue21
  %lpad.loopexit.split-lp = landingpad { i8*, i32 }
          cleanup
  br label %lpad17

lpad17:                                           ; preds = %lpad17.loopexit.split-lp, %lpad17.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad17.loopexit ], [ %lpad.loopexit.split-lp, %lpad17.loopexit.split-lp ]
  call void @llvm.reducer.unregister(i8* nonnull %1)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1) #20
  call void @llvm.reducer.unregister(i8* nonnull %0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %0) #20
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %sum_racy.0.sum_racy.0.sum_racy.0..sroa_cast)
  resume { i8*, i32 } %lpad.phi

sync.continue21:                                  ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %cleanup unwind label %lpad17.loopexit.split-lp

cleanup:                                          ; preds = %sync.continue21, %entry
  %21 = call i8* @llvm.hyper.lookup.i64(i8* nonnull %0, i64 8, i8* bitcast (void (i8*)* @_ZN4cilkL4zeroIlEEvPv to i8*), i8* bitcast (void (i8*, i8*)* @_ZN4cilkL4plusIlEEvPvS1_ to i8*))
  %22 = bitcast i8* %21 to i64*
  %23 = load i64, i64* %22, align 8, !tbaa !7
  %24 = call i8* @llvm.hyper.lookup.i64(i8* nonnull %1, i64 8, i8* bitcast (void (i8*)* @_ZN4cilkL4zeroIlEEvPv to i8*), i8* bitcast (void (i8*, i8*)* @_ZN4cilkL4plusIlEEvPvS1_ to i8*))
  %25 = bitcast i8* %24 to i64*
  %26 = load i64, i64* %25, align 8, !tbaa !7
  %sum_racy.0.load92 = load i64, i64* %sum_racy, align 8
  %call29 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([38 x i8], [38 x i8]* @.str.1, i64 0, i64 0), i64 noundef %23, i64 noundef %26, i64 noundef %sum_racy.0.load92)
  %27 = load i64, i64* %22, align 8, !tbaa !7
  %28 = load i64, i64* %25, align 8, !tbaa !7
  %sub30 = sub nsw i64 0, %28
  %cmp31.not = icmp eq i64 %27, %sub30
  br i1 %cmp31.not, label %if.end, label %if.then

if.then:                                          ; preds = %cleanup
  %puts = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([45 x i8], [45 x i8]* @str, i64 0, i64 0))
  br label %if.end

if.end:                                           ; preds = %if.then, %cleanup
  call void @llvm.reducer.unregister(i8* nonnull %1)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1) #20
  call void @llvm.reducer.unregister(i8* nonnull %0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %0) #20
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %sum_racy.0.sum_racy.0.sum_racy.0..sroa_cast)
  ret void

unreachable:                                      ; preds = %lpad
  unreachable
}

; Function Attrs: mustprogress nofree nounwind willreturn
declare dso_local i64 @strtol(i8* noundef readonly, i8** nocapture noundef, i32 noundef) local_unnamed_addr #3

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8* noundef) local_unnamed_addr #4

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZNSt6vectorIlSaIlEE17_M_realloc_insertIJRKlEEEvN9__gnu_cxx17__normal_iteratorIPlS1_EEDpOT_(%"class.std::vector"* noundef nonnull align 8 dereferenceable(24) %this, i64* %__position.coerce, i64* noundef nonnull align 8 dereferenceable(8) %__args) local_unnamed_addr #5 comdat align 2 personality i32 (...)* @__gxx_personality_v0 {
entry:
  %_M_finish.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %this, i64 0, i32 0, i32 0, i32 0, i32 1
  %0 = load i64*, i64** %_M_finish.i.i, align 8, !tbaa !9
  %_M_start.i.i = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %this, i64 0, i32 0, i32 0, i32 0, i32 0
  %1 = load i64*, i64** %_M_start.i.i, align 8, !tbaa !15
  %sub.ptr.lhs.cast.i.i = ptrtoint i64* %0 to i64
  %sub.ptr.rhs.cast.i.i = ptrtoint i64* %1 to i64
  %sub.ptr.sub.i.i = sub i64 %sub.ptr.lhs.cast.i.i, %sub.ptr.rhs.cast.i.i
  %sub.ptr.div.i.i = ashr exact i64 %sub.ptr.sub.i.i, 3
  %cmp.i = icmp eq i64 %sub.ptr.sub.i.i, 9223372036854775800
  br i1 %cmp.i, label %if.then.i, label %_ZNKSt6vectorIlSaIlEE12_M_check_lenEmPKc.exit

if.then.i:                                        ; preds = %entry
  call void @_ZSt20__throw_length_errorPKc(i8* noundef getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i64 0, i64 0)) #22
  unreachable

_ZNKSt6vectorIlSaIlEE12_M_check_lenEmPKc.exit:    ; preds = %entry
  %cmp.i.i = icmp eq i64 %sub.ptr.sub.i.i, 0
  %.sroa.speculated.i = select i1 %cmp.i.i, i64 1, i64 %sub.ptr.div.i.i
  %add.i = add nsw i64 %.sroa.speculated.i, %sub.ptr.div.i.i
  %cmp7.i = icmp ult i64 %add.i, %sub.ptr.div.i.i
  %cmp9.i = icmp ugt i64 %add.i, 1152921504606846975
  %or.cond.i = or i1 %cmp7.i, %cmp9.i
  %cond.i = select i1 %or.cond.i, i64 1152921504606846975, i64 %add.i
  %sub.ptr.lhs.cast.i = ptrtoint i64* %__position.coerce to i64
  %sub.ptr.sub.i = sub i64 %sub.ptr.lhs.cast.i, %sub.ptr.rhs.cast.i.i
  %sub.ptr.div.i = ashr exact i64 %sub.ptr.sub.i, 3
  %cmp.not.i = icmp eq i64 %cond.i, 0
  br i1 %cmp.not.i, label %_ZNSt12_Vector_baseIlSaIlEE11_M_allocateEm.exit, label %cond.true.i

cond.true.i:                                      ; preds = %_ZNKSt6vectorIlSaIlEE12_M_check_lenEmPKc.exit
  %cmp.i.i.i = icmp ugt i64 %cond.i, 1152921504606846975
  br i1 %cmp.i.i.i, label %if.then.i.i.i, label %_ZNSt16allocator_traitsISaIlEE8allocateERS0_m.exit.i, !prof !19

if.then.i.i.i:                                    ; preds = %cond.true.i
  %cmp2.i.i.i = icmp ugt i64 %cond.i, 2305843009213693951
  br i1 %cmp2.i.i.i, label %if.then3.i.i.i, label %if.end.i.i.i

if.then3.i.i.i:                                   ; preds = %if.then.i.i.i
  call void @_ZSt28__throw_bad_array_new_lengthv() #22
  unreachable

if.end.i.i.i:                                     ; preds = %if.then.i.i.i
  call void @_ZSt17__throw_bad_allocv() #22
  unreachable

_ZNSt16allocator_traitsISaIlEE8allocateERS0_m.exit.i: ; preds = %cond.true.i
  %mul.i.i.i = shl i64 %cond.i, 3
  %call5.i.i.i = call noalias noundef nonnull i8* @_Znwm(i64 noundef %mul.i.i.i) #23
  %2 = bitcast i8* %call5.i.i.i to i64*
  br label %_ZNSt12_Vector_baseIlSaIlEE11_M_allocateEm.exit

_ZNSt12_Vector_baseIlSaIlEE11_M_allocateEm.exit:  ; preds = %_ZNKSt6vectorIlSaIlEE12_M_check_lenEmPKc.exit, %_ZNSt16allocator_traitsISaIlEE8allocateERS0_m.exit.i
  %cond.i38 = phi i64* [ %2, %_ZNSt16allocator_traitsISaIlEE8allocateERS0_m.exit.i ], [ null, %_ZNKSt6vectorIlSaIlEE12_M_check_lenEmPKc.exit ]
  %add.ptr = getelementptr inbounds i64, i64* %cond.i38, i64 %sub.ptr.div.i
  %3 = load i64, i64* %__args, align 8, !tbaa !7
  store i64 %3, i64* %add.ptr, align 8, !tbaa !7
  %cmp.i.i.i.i = icmp sgt i64 %sub.ptr.sub.i, 0
  br i1 %cmp.i.i.i.i, label %if.then.i.i.i.i, label %_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit

if.then.i.i.i.i:                                  ; preds = %_ZNSt12_Vector_baseIlSaIlEE11_M_allocateEm.exit
  %4 = bitcast i64* %cond.i38 to i8*
  %5 = bitcast i64* %1 to i8*
  call void @llvm.memmove.p0i8.p0i8.i64(i8* align 8 %4, i8* align 8 %5, i64 %sub.ptr.sub.i, i1 false) #20
  br label %_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit

_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit: ; preds = %_ZNSt12_Vector_baseIlSaIlEE11_M_allocateEm.exit, %if.then.i.i.i.i
  %incdec.ptr = getelementptr inbounds i64, i64* %add.ptr, i64 1
  %sub.ptr.sub.i.i.i.i42 = sub i64 %sub.ptr.lhs.cast.i.i, %sub.ptr.lhs.cast.i
  %cmp.i.i.i.i43 = icmp sgt i64 %sub.ptr.sub.i.i.i.i42, 0
  br i1 %cmp.i.i.i.i43, label %if.then.i.i.i.i44, label %_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit47

if.then.i.i.i.i44:                                ; preds = %_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit
  %6 = bitcast i64* %incdec.ptr to i8*
  %7 = bitcast i64* %__position.coerce to i8*
  call void @llvm.memmove.p0i8.p0i8.i64(i8* nonnull align 8 %6, i8* align 8 %7, i64 %sub.ptr.sub.i.i.i.i42, i1 false) #20
  br label %_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit47

_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit47: ; preds = %_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit, %if.then.i.i.i.i44
  %tobool.not.i = icmp eq i64* %1, null
  br i1 %tobool.not.i, label %_ZNSt12_Vector_baseIlSaIlEE13_M_deallocateEPlm.exit, label %if.then.i48

if.then.i48:                                      ; preds = %_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit47
  %8 = bitcast i64* %1 to i8*
  call void @_ZdlPv(i8* noundef %8) #21
  br label %_ZNSt12_Vector_baseIlSaIlEE13_M_deallocateEPlm.exit

_ZNSt12_Vector_baseIlSaIlEE13_M_deallocateEPlm.exit: ; preds = %_ZNSt6vectorIlSaIlEE11_S_relocateEPlS2_S2_RS0_.exit47, %if.then.i48
  %_M_end_of_storage = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %this, i64 0, i32 0, i32 0, i32 0, i32 2
  %sub.ptr.div.i.i.i.i45 = ashr exact i64 %sub.ptr.sub.i.i.i.i42, 3
  %add.ptr.i.i.i.i46 = getelementptr inbounds i64, i64* %incdec.ptr, i64 %sub.ptr.div.i.i.i.i45
  store i64* %cond.i38, i64** %_M_start.i.i, align 8, !tbaa !15
  store i64* %add.ptr.i.i.i.i46, i64** %_M_finish.i.i, align 8, !tbaa !9
  %add.ptr20 = getelementptr inbounds i64, i64* %cond.i38, i64 %cond.i
  store i64* %add.ptr20, i64** %_M_end_of_storage, align 8, !tbaa !11
  ret void
}

; Function Attrs: noreturn
declare dso_local void @_ZSt20__throw_length_errorPKc(i8* noundef) local_unnamed_addr #6

; Function Attrs: noreturn
declare dso_local void @_ZSt28__throw_bad_array_new_lengthv() local_unnamed_addr #6

; Function Attrs: noreturn
declare dso_local void @_ZSt17__throw_bad_allocv() local_unnamed_addr #6

; Function Attrs: nobuiltin allocsize(0)
declare dso_local noundef nonnull i8* @_Znwm(i64 noundef) local_unnamed_addr #7

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1 immarg) #8

; Function Attrs: argmemonly mustprogress nofree norecurse nosync nounwind uwtable willreturn writeonly
define internal void @_ZN4cilkL4zeroIlEEvPv(i8* nocapture noundef writeonly %v) #9 {
entry:
  %0 = bitcast i8* %v to i64*
  store i64 0, i64* %0, align 8, !tbaa !7
  ret void
}

; Function Attrs: argmemonly mustprogress nofree norecurse nosync nounwind uwtable willreturn
define internal void @_ZN4cilkL4plusIlEEvPvS1_(i8* nocapture noundef %l, i8* nocapture noundef readonly %r) #10 {
entry:
  %0 = bitcast i8* %r to i64*
  %1 = load i64, i64* %0, align 8, !tbaa !7
  %2 = bitcast i8* %l to i64*
  %3 = load i64, i64* %2, align 8, !tbaa !7
  %add = add nsw i64 %3, %1
  store i64 %add, i64* %2, align 8, !tbaa !7
  ret void
}

; Function Attrs: inaccessiblememonly mustprogress nounwind reducer_register willreturn
declare void @llvm.reducer.register.i64(i8*, i64, i8*, i8*) #11

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #12

; Function Attrs: hyper_view inaccessiblememonly injective mustprogress nofree nounwind readonly strand_pure willreturn
declare i8* @llvm.hyper.lookup.i64(i8*, i64, i8*, i8*) #13

; Function Attrs: argmemonly mustprogress willreturn
declare void @llvm.sync.unwind(token) #14

; Function Attrs: argmemonly mustprogress willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #14

; Function Attrs: nofree nounwind
declare dso_local noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #15

; Function Attrs: inaccessiblememonly mustprogress nounwind reducer_unregister willreturn
declare void @llvm.reducer.unregister(i8*) #16

; Function Attrs: nofree nounwind
declare noundef i32 @puts(i8* nocapture noundef readonly) local_unnamed_addr #17

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #18

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i64 @llvm.smax.i64(i64, i64) #19

attributes #0 = { norecurse uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { mustprogress uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nofree nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nobuiltin nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { noreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nobuiltin allocsize(0) "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { argmemonly mustprogress nofree nounwind willreturn }
attributes #9 = { argmemonly mustprogress nofree norecurse nosync nounwind uwtable willreturn writeonly "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { argmemonly mustprogress nofree norecurse nosync nounwind uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { inaccessiblememonly mustprogress nounwind reducer_register willreturn }
attributes #12 = { argmemonly mustprogress nounwind willreturn }
attributes #13 = { hyper_view inaccessiblememonly injective mustprogress nofree nounwind readonly strand_pure willreturn }
attributes #14 = { argmemonly mustprogress willreturn }
attributes #15 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #16 = { inaccessiblememonly mustprogress nounwind reducer_unregister willreturn }
attributes #17 = { nofree nounwind }
attributes #18 = { argmemonly nofree nounwind willreturn writeonly }
attributes #19 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #20 = { nounwind }
attributes #21 = { builtin nounwind }
attributes #22 = { noreturn }
attributes #23 = { builtin allocsize(0) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git 5f6bec7c28155ec1f1ae0efebdb5cec40d39fda1)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!8, !8, i64 0}
!8 = !{!"long", !5, i64 0}
!9 = !{!10, !4, i64 8}
!10 = !{!"_ZTSNSt12_Vector_baseIlSaIlEE17_Vector_impl_dataE", !4, i64 0, !4, i64 8, !4, i64 16}
!11 = !{!10, !4, i64 16}
!12 = distinct !{!12, !13, !14}
!13 = !{!"llvm.loop.mustprogress"}
!14 = !{!"llvm.loop.unroll.disable"}
!15 = !{!10, !4, i64 0}
!16 = distinct !{!16, !17, !18, !14}
!17 = !{!"tapir.loop.spawn.strategy", i32 1}
!18 = !{!"tapir.loop.grainsize", i32 64}
!19 = !{!"branch_weights", i32 1, i32 2000}
