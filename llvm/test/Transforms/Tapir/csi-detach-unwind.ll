; Check that calls within a detached task with an unwind destination
; are not promoted to invokes.  Because the detach has an unwind
; destination, these calls are implicitly assumed not to throw when
; promoting calls to invokes.
;
; RUN: opt < %s -csi -S -o - | FileCheck %s
; RUN: opt < %s -passes='csi' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$_ZN8sequence4packIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_ = comdat any

@__csi_unit_func_base_id = internal global i64 0
@__csi_unit_func_exit_base_id = internal global i64 0
@__csi_unit_loop_base_id = internal global i64 0
@__csi_unit_loop_exit_base_id = internal global i64 0
@__csi_unit_callsite_base_id = internal global i64 0
@__csi_unit_load_base_id = internal global i64 0
@__csi_unit_store_base_id = internal global i64 0
@__csi_unit_detach_base_id = internal global i64 0
@__csi_unit_task_base_id = internal global i64 0
@__csi_unit_task_exit_base_id = internal global i64 0
@__csi_unit_detach_continue_base_id = internal global i64 0
@__csi_unit_sync_base_id = internal global i64 0
@__csi_unit_allocfn_base_id = internal global i64 0
@__csi_unit_free_base_id = internal global i64 0
@__csi_func_id__ZN8sequence4scanIll4addFIlENS_4getAIllEEEET_PS5_T0_S7_T1_T2_S5_bb = weak global i64 -1
@__csi_func_id__ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_ = weak global i64 -1

; Function Attrs: uwtable
define linkonce_odr dso_local { i64*, i64 } @_ZN8sequence4packIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_(i64* %Out, i8* %Fl, i64 %s, i64 %e) local_unnamed_addr #8 comdat personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 7
  %2 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %3 = add i64 %2, 7
  %4 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %5 = add i64 %4, 7
  %6 = add i64 %4, 8
  %7 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %8 = add i64 %7, 7
  %9 = add i64 %7, 8
  %10 = add i64 %0, 6
  %11 = add i64 %2, 6
  %12 = add i64 %4, 6
  %13 = add i64 %7, 6
  %14 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %15 = add i64 %14, 22
  %16 = call i8* @llvm.frameaddress.p0i8(i32 0)
  %17 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %15, i8* %16, i8* %17, i64 257)
  %syncreg38 = tail call token @llvm.syncregion.start()
  %18 = xor i64 %s, -1
  %sub1 = add i64 %18, %e
  %div = sdiv i64 %sub1, 2048
  %add = add nsw i64 %div, 1
  %cmp = icmp slt i64 %sub1, 2048
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %19 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %20 = add i64 %19, 108
  %21 = load i64, i64* @__csi_func_id__ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_, align 8
  call void @__csan_before_call(i64 %20, i64 %21, i8 0, i64 0)
  %call169 = invoke { i64*, i64 } @_ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_(i64* %Out, i8* %Fl, i64 %s, i64 %e)
          to label %call.noexc unwind label %csi.cleanup.loopexit.split-lp.csi-split

call.noexc:                                       ; preds = %if.then
  call void @__csan_after_call(i64 %20, i64 %21, i8 0, i64 0)
  %22 = extractvalue { i64*, i64 } %call169, 0
  %23 = extractvalue { i64*, i64 } %call169, 1
  br label %cleanup82

if.end:                                           ; preds = %entry
  %mul = shl nsw i64 %add, 3
  %24 = load i64, i64* @__csi_unit_allocfn_base_id, align 8, !invariant.load !2
  %25 = add i64 %24, 11
  %call2 = tail call noalias i8* @malloc(i64 %mul) #27
  call void @__csan_after_allocfn(i64 %25, i8* %call2, i64 %mul, i64 1, i64 0, i8* null, i64 0)
  %26 = bitcast i8* %call2 to i64*
  %27 = load i64, i64* @__csi_unit_loop_base_id, align 8, !invariant.load !2
  %28 = add i64 %27, 6
  call void @__csan_before_loop(i64 %28, i64 -1, i64 3)
  %29 = load i64, i64* @__csi_unit_load_base_id, align 8
  %30 = add i64 %29, 150
  %31 = add i64 %29, 151
  %32 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %33 = add i64 %32, 84
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %if.end
  %__begin.0 = phi i64 [ 0, %if.end ], [ %inc, %pfor.inc ]
  %34 = shl i64 %__begin.0, 11
  %35 = add i64 %34, %s
  %scevgep = getelementptr i8, i8* %Fl, i64 %35
  %36 = add i64 %35, 2048
  %37 = icmp sgt i64 %36, %e
  %smin = select i1 %37, i64 %e, i64 %36
  %38 = mul i64 %__begin.0, -2048
  %39 = sub i64 %smin, %s
  %40 = add i64 %39, %38
  call void @__csan_detach(i64 %10, i8 0)
  detach within %syncreg38, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %41 = call i8* @llvm.task.frameaddress(i32 0)
  %42 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %11, i64 %10, i8* %41, i8* %42, i64 1)
  %sub20 = sub nsw i64 %smin, %35
  %cmp.i141 = icmp sgt i64 %sub20, 127
  %and.i = and i64 %sub20, 511
  %cmp1.i = icmp eq i64 %and.i, 0
  %or.cond.i = and i1 %cmp.i141, %cmp1.i
  br i1 %or.cond.i, label %land.lhs.true2.i, label %if.else.i

land.lhs.true2.i:                                 ; preds = %pfor.body
  %43 = ptrtoint i8* %scevgep to i64
  %and3.i = and i64 %43, 3
  %cmp4.i = icmp eq i64 %and3.i, 0
  br i1 %cmp4.i, label %if.then.i, label %for.body29.i.preheader

if.then.i:                                        ; preds = %land.lhs.true2.i
  %shr75.i = lshr i64 %sub20, 9
  %cmp562.i = icmp sgt i64 %sub20, 511
  br i1 %cmp562.i, label %for.cond6.preheader.preheader.i, label %_ZN8sequence14sumFlagsSerialIlEET_PbS1_.exit

for.cond6.preheader.preheader.i:                  ; preds = %if.then.i
  %44 = bitcast i8* %scevgep to i32*
  br label %for.cond6.preheader.i

for.cond6.preheader.i:                            ; preds = %for.cond.cleanup8.i, %for.cond6.preheader.preheader.i
  %indvars.iv71.i = phi i64 [ 0, %for.cond6.preheader.preheader.i ], [ %indvars.iv.next72.i, %for.cond.cleanup8.i ]
  %IFl.064.i = phi i32* [ %44, %for.cond6.preheader.preheader.i ], [ %add.ptr.i, %for.cond.cleanup8.i ]
  %r.063.i = phi i64 [ 0, %for.cond6.preheader.preheader.i ], [ %add21.i, %for.cond.cleanup8.i ]
  br label %for.body9.i

for.cond.cleanup8.i:                              ; preds = %for.body9.i
  %and10.i = and i32 %add.i, 255
  %45 = lshr i32 %add.i, 8
  %and12.i = and i32 %45, 255
  %46 = lshr i32 %add.i, 16
  %and15.i = and i32 %46, 255
  %47 = lshr i32 %add.i, 24
  %add13.i = add nuw nsw i32 %47, %and10.i
  %add16.i = add nuw nsw i32 %add13.i, %and12.i
  %add19.i = add nuw nsw i32 %add16.i, %and15.i
  %conv20.i = zext i32 %add19.i to i64
  %add21.i = add nuw nsw i64 %r.063.i, %conv20.i
  %add.ptr.i = getelementptr inbounds i32, i32* %IFl.064.i, i64 128
  %indvars.iv.next72.i = add nuw nsw i64 %indvars.iv71.i, 1
  %cmp5.i = icmp ugt i64 %shr75.i, %indvars.iv.next72.i
  br i1 %cmp5.i, label %for.cond6.preheader.i, label %_ZN8sequence14sumFlagsSerialIlEET_PbS1_.exit

for.body9.i:                                      ; preds = %for.body9.i, %for.cond6.preheader.i
  %indvars.iv.i = phi i64 [ 0, %for.cond6.preheader.i ], [ %indvars.iv.next.i, %for.body9.i ]
  %rr.060.i = phi i32 [ 0, %for.cond6.preheader.i ], [ %add.i, %for.body9.i ]
  %arrayidx.i = getelementptr inbounds i32, i32* %IFl.064.i, i64 %indvars.iv.i
  %48 = bitcast i32* %arrayidx.i to i8*
  call void @__csan_load(i64 %31, i8* %48, i32 4, i64 4)
  %49 = load i32, i32* %arrayidx.i, align 4, !tbaa !6
  %add.i = add nsw i32 %49, %rr.060.i
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, 128
  br i1 %exitcond.i, label %for.cond.cleanup8.i, label %for.body9.i

if.else.i:                                        ; preds = %pfor.body
  %cmp2766.i = icmp sgt i64 %sub20, 0
  br i1 %cmp2766.i, label %for.body29.i.preheader, label %_ZN8sequence14sumFlagsSerialIlEET_PbS1_.exit

for.body29.i.preheader:                           ; preds = %if.else.i, %land.lhs.true2.i
  call void @__csan_large_load(i64 %30, i8* %scevgep, i64 %40, i64 1)
  br label %for.body29.i

for.body29.i:                                     ; preds = %for.body29.i.preheader, %for.body29.i
  %j25.068.i = phi i64 [ %inc34.i, %for.body29.i ], [ 0, %for.body29.i.preheader ]
  %r.167.i = phi i64 [ %add32.i, %for.body29.i ], [ 0, %for.body29.i.preheader ]
  %arrayidx30.i = getelementptr inbounds i8, i8* %scevgep, i64 %j25.068.i
  %50 = load i8, i8* %arrayidx30.i, align 1, !tbaa !42, !range !70
  %51 = zext i8 %50 to i64
  %add32.i = add nuw nsw i64 %r.167.i, %51
  %inc34.i = add nuw nsw i64 %j25.068.i, 1
  %exitcond73.i = icmp eq i64 %inc34.i, %sub20
  br i1 %exitcond73.i, label %_ZN8sequence14sumFlagsSerialIlEET_PbS1_.exit, label %for.body29.i

_ZN8sequence14sumFlagsSerialIlEET_PbS1_.exit:     ; preds = %for.body29.i, %for.cond.cleanup8.i, %if.then.i, %if.else.i
  %r.2.i = phi i64 [ 0, %if.then.i ], [ 0, %if.else.i ], [ %add21.i, %for.cond.cleanup8.i ], [ %add32.i, %for.body29.i ]
  %arrayidx = getelementptr inbounds i64, i64* %26, i64 %__begin.0
  %52 = bitcast i64* %arrayidx to i8*
  call void @__csan_store(i64 %33, i8* %52, i32 8, i64 8)
  store i64 %r.2.i, i64* %arrayidx, align 8, !tbaa !16
  call void @__csan_task_exit(i64 %12, i64 %11, i64 %10, i8 0, i64 1)
  reattach within %syncreg38, label %pfor.inc

pfor.inc:                                         ; preds = %_ZN8sequence14sumFlagsSerialIlEET_PbS1_.exit, %pfor.cond
  call void @__csan_detach_continue(i64 %13, i64 %10)
  %inc = add nuw nsw i64 %__begin.0, 1
  %exitcond158 = icmp eq i64 %__begin.0, %div
  br i1 %exitcond158, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !128

pfor.cond.cleanup:                                ; preds = %pfor.inc
  call void @__csan_after_loop(i64 %28, i8 0, i64 3)
  %53 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !2
  %54 = add i64 %53, 6
  call void @__csan_sync(i64 %54, i8 0)
  sync within %syncreg38, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg38)
          to label %.noexc unwind label %csi.cleanup.loopexit.split-lp.csi-split-lp

.noexc:                                           ; preds = %sync.continue
  %55 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %56 = add i64 %55, 109
  %57 = load i64, i64* @__csi_func_id__ZN8sequence4scanIll4addFIlENS_4getAIllEEEET_PS5_T0_S7_T1_T2_S5_bb, align 8
  call void @__csan_before_call(i64 %56, i64 %57, i8 0, i64 0)
  %call.i164 = invoke i64 @_ZN8sequence4scanIll4addFIlENS_4getAIllEEEET_PS5_T0_S7_T1_T2_S5_bb(i64* %26, i64 0, i64 %add, i64* %26, i64 0, i1 zeroext false, i1 zeroext false)
          to label %call.i.noexc unwind label %csi.cleanup.loopexit.split-lp.csi-split

call.i.noexc:                                     ; preds = %.noexc
  call void @__csan_after_call(i64 %56, i64 %57, i8 0, i64 0)
  %cmp25 = icmp eq i64* %Out, null
  br i1 %cmp25, label %if.then26, label %if.end29

if.then26:                                        ; preds = %call.i.noexc
  %mul27 = shl i64 %call.i164, 3
  %58 = add i64 %24, 12
  %call28 = tail call noalias i8* @malloc(i64 %mul27) #27
  call void @__csan_after_allocfn(i64 %58, i8* %call28, i64 %mul27, i64 1, i64 0, i8* null, i64 0)
  %59 = bitcast i8* %call28 to i64*
  br label %if.end29

if.end29:                                         ; preds = %if.then26, %call.i.noexc
  %Out.addr.0 = phi i64* [ %59, %if.then26 ], [ %Out, %call.i.noexc ]
  %60 = icmp sgt i64 %div, 0
  %smax = select i1 %60, i64 %div, i64 0
  %61 = add i64 %27, 7
  call void @__csan_before_loop(i64 %61, i64 -1, i64 1)
  %62 = add i64 %55, 110
  br label %pfor.cond50

pfor.cond50:                                      ; preds = %pfor.inc69, %if.end29
  %__begin44.0 = phi i64 [ 0, %if.end29 ], [ %inc70, %pfor.inc69 ]
  call void @__csan_detach(i64 %1, i8 0)
  detach within %syncreg38, label %pfor.body56, label %pfor.inc69 unwind label %csi.cleanup.loopexit

; CHECK: pfor.cond50:
; CHECK: detach within %syncreg38, label %pfor.body56, label %pfor.inc69 unwind label %csi.cleanup.loopexit

pfor.body56:                                      ; preds = %pfor.cond50
  %63 = call i8* @llvm.task.frameaddress(i32 0)
  %64 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %3, i64 %1, i8* %63, i8* %64, i64 1)
  %mul58 = shl nsw i64 %__begin44.0, 11
  %add59 = add nsw i64 %mul58, %s
  %add62 = add nsw i64 %add59, 2048
  %cmp.i142 = icmp sgt i64 %add62, %e
  %.sroa.speculated149 = select i1 %cmp.i142, i64 %e, i64 %add62
  %arrayidx64 = getelementptr inbounds i64, i64* %26, i64 %__begin44.0
  %65 = load i64, i64* %arrayidx64, align 8, !tbaa !16
  %add.ptr65 = getelementptr inbounds i64, i64* %Out.addr.0, i64 %65
  %66 = load i64, i64* @__csi_func_id__ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_, align 8
  call void @__csan_before_call(i64 %62, i64 %66, i8 0, i64 0)
  %call67167 = invoke { i64*, i64 } @_ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_(i64* %add.ptr65, i8* %Fl, i64 %add59, i64 %.sroa.speculated149)
          to label %call67.noexc unwind label %csi.cleanup165

; CHECK: call void @__csan_task(

; CHECK: call void @__csan_before_call(

; CHECK: %call67167 = invoke { i64*, i64 } @_ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_(
; CHECK-NEXT: to label %call67.noexc unwind label %csi.cleanup165

call67.noexc:                                     ; preds = %pfor.body56
  call void @__csan_after_call(i64 %62, i64 %66, i8 0, i64 0)
  call void @__csan_task_exit(i64 %5, i64 %3, i64 %1, i8 0, i64 1)
  reattach within %syncreg38, label %pfor.inc69

; CHECK: call void @__csan_after_call(

; CHECK: call void @__csan_task_exit(

; CHECK: reattach within %syncreg38, label %pfor.inc69

pfor.inc69:                                       ; preds = %pfor.cond50, %call67.noexc
  call void @__csan_detach_continue(i64 %8, i64 %1)
  %inc70 = add nuw nsw i64 %__begin44.0, 1
  %exitcond = icmp eq i64 %__begin44.0, %smax
  br i1 %exitcond, label %pfor.cond.cleanup72, label %pfor.cond50, !llvm.loop !129

pfor.cond.cleanup72:                              ; preds = %pfor.inc69
  call void @__csan_after_loop(i64 %61, i8 0, i64 1)
  %67 = add i64 %53, 7
  call void @__csan_sync(i64 %67, i8 0)
  sync within %syncreg38, label %sync.continue74

sync.continue74:                                  ; preds = %pfor.cond.cleanup72
  invoke void @llvm.sync.unwind(token %syncreg38)
          to label %.noexc168 unwind label %csi.cleanup.loopexit.split-lp.csi-split-lp

.noexc168:                                        ; preds = %sync.continue74
  %68 = load i64, i64* @__csi_unit_free_base_id, align 8, !invariant.load !2
  %69 = add i64 %68, 9
  tail call void @free(i8* %call2) #27
  call void @__csan_after_free(i64 %69, i8* %call2, i64 0)
  br label %cleanup82

cleanup82:                                        ; preds = %.noexc168, %call.noexc
  %retval.sroa.0.0 = phi i64* [ %22, %call.noexc ], [ %Out.addr.0, %.noexc168 ]
  %retval.sroa.3.0 = phi i64 [ %23, %call.noexc ], [ %call.i164, %.noexc168 ]
  %.fca.0.insert = insertvalue { i64*, i64 } undef, i64* %retval.sroa.0.0, 0
  %.fca.1.insert = insertvalue { i64*, i64 } %.fca.0.insert, i64 %retval.sroa.3.0, 1
  %70 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %71 = add i64 %70, 20
  call void @__csan_func_exit(i64 %71, i64 %15, i64 1)
  ret { i64*, i64 } %.fca.1.insert

csi.cleanup.loopexit:                             ; preds = %csi.cleanup165, %pfor.cond50
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_loop(i64 %61, i8 0, i64 1)
  call void @__csan_detach_continue(i64 %9, i64 %1)
  br label %csi.cleanup

csi.cleanup.loopexit.split-lp.csi-split-lp:       ; preds = %sync.continue74, %sync.continue
  %lpad.csi-split-lp = landingpad { i8*, i32 }
          cleanup
  br label %csi.cleanup

csi.cleanup.loopexit.split-lp.csi-split:          ; preds = %if.then, %.noexc
  %72 = phi i64 [ %20, %if.then ], [ %56, %.noexc ]
  %73 = phi i64 [ %21, %if.then ], [ %57, %.noexc ]
  %lpad.csi-split = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %72, i64 %73, i8 0, i64 0)
  br label %csi.cleanup

csi.cleanup:                                      ; preds = %csi.cleanup.loopexit.split-lp.csi-split-lp, %csi.cleanup.loopexit.split-lp.csi-split, %csi.cleanup.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %csi.cleanup.loopexit ], [ %lpad.csi-split-lp, %csi.cleanup.loopexit.split-lp.csi-split-lp ], [ %lpad.csi-split, %csi.cleanup.loopexit.split-lp.csi-split ]
  %74 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %75 = add i64 %74, 21
  call void @__csan_func_exit(i64 %75, i64 %15, i64 3)
  resume { i8*, i32 } %lpad.phi

csi.cleanup.unreachable:                          ; preds = %csi.cleanup165
  unreachable

csi.cleanup165:                                   ; preds = %pfor.body56
  %csi.cleanup.lpad166 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %62, i64 %66, i8 0, i64 0)
  call void @__csan_task_exit(i64 %6, i64 %3, i64 %1, i8 0, i64 1)
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg38, { i8*, i32 } %csi.cleanup.lpad166)
          to label %csi.cleanup.unreachable unwind label %csi.cleanup.loopexit
}

; Function Attrs: uwtable
declare dso_local { i64*, i64 } @_ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_(i64* %Out, i8* %Fl, i64 %s, i64 %e) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN8sequence4scanIll4addFIlENS_4getAIllEEEET_PS5_T0_S7_T1_T2_S5_bb(i64* %Out, i64 %s, i64 %e, i64* %g.coerce, i64 %zero, i1 zeroext %inclusive, i1 zeroext %back) local_unnamed_addr #8

declare i32 @__gcc_personality_v0(...)

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @malloc(i64) local_unnamed_addr #10

; Function Attrs: nounwind
declare dso_local void @free(i8* nocapture) local_unnamed_addr #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #5

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #11

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #11

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_func_entry(i64, i8* nocapture readnone, i8* nocapture readnone, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_func_exit(i64, i64, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_load(i64, i8* nocapture readnone, i32, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_store(i64, i8* nocapture readnone, i32, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_large_load(i64, i8* nocapture readnone, i64, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_before_call(i64, i64, i8, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_after_call(i64, i64, i8, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_detach(i64, i8) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_task(i64, i64, i8* nocapture readnone, i8* nocapture readnone, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_task_exit(i64, i64, i64, i8, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_detach_continue(i64, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_sync(i64, i8) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_after_allocfn(i64, i8* nocapture readnone, i64, i64, i64, i8* nocapture readnone, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_after_free(i64, i8* nocapture readnone, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_before_loop(i64, i64, i64) #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_after_loop(i64, i8, i64) #25

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #26

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #27

; Function Attrs: nounwind willreturn
declare i8* @llvm.task.frameaddress(i32) #28

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nofree nounwind }
attributes #3 = { norecurse nounwind readnone sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { argmemonly nounwind willreturn }
attributes #6 = { nofree norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { inlinehint sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { argmemonly willreturn }
attributes #12 = { nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #13 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #14 = { sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { norecurse uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #17 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #18 = { argmemonly nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #19 = { nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #20 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #21 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #22 = { inlinehint uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #23 = { nounwind readnone speculatable willreturn }
attributes #24 = { nofree nounwind readonly }
attributes #25 = { inaccessiblemem_or_argmemonly }
attributes #26 = { nounwind readnone }
attributes #27 = { nounwind }
attributes #28 = { nounwind willreturn }
attributes #29 = { noreturn }
attributes #30 = { cold }
attributes #31 = { noreturn nounwind }
attributes #32 = { nounwind readonly }
attributes #33 = { builtin }

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git f7db8a6e8b0d5ae5b7b95196879fc5c144497320)"}
!2 = !{}
!3 = !{!4, !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !4, i64 0}
!8 = !{!9, !9, i64 0}
!9 = !{!"vtable pointer", !5, i64 0}
!10 = !{!11, !12, i64 240}
!11 = !{!"_ZTSSt9basic_iosIcSt11char_traitsIcEE", !12, i64 216, !4, i64 224, !13, i64 225, !12, i64 232, !12, i64 240, !12, i64 248, !12, i64 256}
!12 = !{!"any pointer", !4, i64 0}
!13 = !{!"bool", !4, i64 0}
!14 = !{!15, !4, i64 56}
!15 = !{!"_ZTSSt5ctypeIcE", !12, i64 16, !13, i64 24, !12, i64 32, !12, i64 40, !12, i64 48, !4, i64 56, !4, i64 57, !4, i64 313, !4, i64 569}
!16 = !{!17, !17, i64 0}
!17 = !{!"long", !4, i64 0}
!18 = distinct !{!18, !19}
!19 = !{!"tapir.loop.spawn.strategy", i32 1}
!20 = !{!12, !12, i64 0}
!21 = distinct !{!21, !19}
!22 = distinct !{!22, !19}
!23 = !{!24, !7, i64 0}
!24 = !{!"_ZTSSt4pairIjiE", !7, i64 0, !7, i64 4}
!25 = !{!24, !7, i64 4}
!26 = distinct !{!26, !19}
!27 = distinct !{!27, !19}
!28 = distinct !{!28, !19}
!29 = !{!30, !7, i64 24}
!30 = !{!"_ZTS4stat", !17, i64 0, !17, i64 8, !17, i64 16, !7, i64 24, !7, i64 28, !7, i64 32, !7, i64 36, !17, i64 40, !17, i64 48, !17, i64 56, !17, i64 64, !31, i64 72, !31, i64 88, !31, i64 104, !4, i64 120}
!31 = !{!"_ZTS8timespec", !17, i64 0, !17, i64 8}
!32 = !{!30, !17, i64 48}
!33 = !{!34, !36, i64 32}
!34 = !{!"_ZTSSt8ios_base", !17, i64 8, !17, i64 16, !35, i64 24, !36, i64 28, !36, i64 32, !12, i64 40, !37, i64 48, !4, i64 64, !7, i64 192, !12, i64 200, !38, i64 208}
!35 = !{!"_ZTSSt13_Ios_Fmtflags", !4, i64 0}
!36 = !{!"_ZTSSt12_Ios_Iostate", !4, i64 0}
!37 = !{!"_ZTSNSt8ios_base6_WordsE", !12, i64 0, !17, i64 8}
!38 = !{!"_ZTSSt6locale", !12, i64 0}
!39 = !{!40, !17, i64 8}
!40 = !{!"_ZTSSi", !17, i64 8}
!41 = distinct !{!41, !19}
!42 = !{!13, !13, i64 0}
!43 = distinct !{!43, !19}
!44 = distinct !{!44, !19}
!45 = !{!46, !17, i64 0}
!46 = !{!"_ZTS5words", !17, i64 0, !12, i64 8, !17, i64 16, !12, i64 24}
!47 = !{!46, !12, i64 8}
!48 = !{!46, !17, i64 16}
!49 = !{!46, !12, i64 24}
!50 = !{!51, !12, i64 0}
!51 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_Alloc_hiderE", !12, i64 0}
!52 = !{!53, !17, i64 8}
!53 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", !51, i64 0, !17, i64 8, !4, i64 16}
!54 = !{!55, !7, i64 0}
!55 = !{!"_ZTS11commandLine", !7, i64 0, !12, i64 8, !53, i64 16}
!56 = !{!55, !12, i64 8}
!57 = !{!53, !12, i64 0}
!58 = !{!59, !12, i64 32}
!59 = !{!"_ZTS5graphI25compressedSymmetricVertexE", !12, i64 0, !17, i64 8, !17, i64 16, !13, i64 24, !12, i64 32, !12, i64 40}
!60 = !{!59, !12, i64 40}
!61 = !{!62, !13, i64 96}
!62 = !{!"_ZTS5timer", !63, i64 0, !63, i64 8, !63, i64 16, !64, i64 24, !64, i64 48, !64, i64 72, !13, i64 96, !65, i64 100}
!63 = !{!"double", !4, i64 0}
!64 = !{!"_ZTS5wsp_t", !17, i64 0, !17, i64 8, !17, i64 16}
!65 = !{!"_ZTS8timezone", !7, i64 0, !7, i64 4}
!66 = !{!67, !17, i64 0}
!67 = !{!"_ZTS7timeval", !17, i64 0, !17, i64 8}
!68 = !{!67, !17, i64 8}
!69 = !{!62, !63, i64 8}
!70 = !{i8 0, i8 2}
!71 = !{!62, !63, i64 0}
!72 = !{!73, !13, i64 24}
!73 = !{!"_ZTS5graphI26compressedAsymmetricVertexE", !12, i64 0, !17, i64 8, !17, i64 16, !13, i64 24, !12, i64 32, !12, i64 40}
!74 = !{!73, !17, i64 8}
!75 = !{!73, !12, i64 0}
!76 = distinct !{!76, !19}
!77 = !{!73, !12, i64 32}
!78 = !{!73, !12, i64 40}
!79 = !{!80, !12, i64 32}
!80 = !{!"_ZTS5graphI15symmetricVertexE", !12, i64 0, !17, i64 8, !17, i64 16, !13, i64 24, !12, i64 32, !12, i64 40}
!81 = !{!80, !12, i64 40}
!82 = !{!83, !13, i64 24}
!83 = !{!"_ZTS5graphI16asymmetricVertexE", !12, i64 0, !17, i64 8, !17, i64 16, !13, i64 24, !12, i64 32, !12, i64 40}
!84 = !{!83, !17, i64 8}
!85 = !{!83, !12, i64 0}
!86 = distinct !{!86, !19}
!87 = !{!83, !12, i64 32}
!88 = !{!83, !12, i64 40}
!89 = distinct !{!89, !19}
!90 = !{!91, !7, i64 8}
!91 = !{!"_ZTS25compressedSymmetricVertex", !12, i64 0, !7, i64 8}
!92 = !{!91, !12, i64 0}
!93 = distinct !{!93, !19}
!94 = !{!95, !12, i64 8}
!95 = !{!"_ZTS14Compressed_MemI25compressedSymmetricVertexE", !12, i64 8, !12, i64 16}
!96 = !{!95, !12, i64 16}
!97 = !{!59, !12, i64 0}
!98 = !{!59, !17, i64 8}
!99 = !{!59, !17, i64 16}
!100 = !{!59, !13, i64 24}
!101 = distinct !{!101, !19}
!102 = !{!103, !12, i64 8}
!103 = !{!"_ZTS16vertexSubsetDataIN4pbbs5emptyEE", !12, i64 0, !12, i64 8, !17, i64 16, !17, i64 24, !13, i64 32}
!104 = !{!103, !17, i64 16}
!105 = !{!103, !17, i64 24}
!106 = !{!103, !13, i64 32}
!107 = !{!103, !12, i64 0}
!108 = !{i64 0, i64 8, !20, i64 8, i64 8, !20, i64 16, i64 8, !16, i64 24, i64 8, !16, i64 32, i64 1, !42}
!109 = distinct !{!109, !19}
!110 = !{!111, !7, i64 16}
!111 = !{!"_ZTS26compressedAsymmetricVertex", !12, i64 0, !12, i64 8, !7, i64 16, !7, i64 20}
!112 = !{!111, !12, i64 8}
!113 = distinct !{!113, !19}
!114 = !{!111, !7, i64 20}
!115 = !{!111, !12, i64 0}
!116 = distinct !{!116, !19}
!117 = !{!118, !12, i64 8}
!118 = !{!"_ZTS14Compressed_MemI26compressedAsymmetricVertexE", !12, i64 8, !12, i64 16}
!119 = !{!118, !12, i64 16}
!120 = !{!73, !17, i64 16}
!121 = distinct !{!121, !19}
!122 = !{!80, !17, i64 8}
!123 = distinct !{!123, !19}
!124 = distinct !{!124, !19}
!125 = !{!34, !17, i64 8}
!126 = distinct !{!126, !19}
!127 = distinct !{!127, !19}
!128 = distinct !{!128, !19}
!129 = distinct !{!129, !19}
!130 = !{i64 0, i64 8, !20, i64 8, i64 4, !6}
!131 = distinct !{!131, !19}
!132 = distinct !{!132, !19}
!133 = distinct !{!133, !19}
!134 = !{!135, !17, i64 8}
!135 = !{!"_ZTS7in_imapIjZN4pbbs10pack_indexIjS_IbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_E", !136, i64 0, !17, i64 8, !17, i64 16}
!136 = !{!"_ZTSZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_"}
!137 = !{!138}
!138 = distinct !{!138, !139, !"_Z12make_in_imapIjZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES2_IS9_SB_EmSB_: %agg.result"}
!139 = distinct !{!139, !"_Z12make_in_imapIjZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES2_IS9_SB_EmSB_"}
!140 = !{!141}
!141 = distinct !{!141, !142, !"_ZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_j: %agg.result"}
!142 = distinct !{!142, !"_ZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_j"}
!143 = !{!135, !17, i64 16}
!144 = !{!145, !13, i64 16}
!145 = !{!"_ZTS10array_imapIjE", !12, i64 0, !12, i64 8, !13, i64 16}
!146 = !{!145, !12, i64 0}
!147 = !{!145, !12, i64 8}
!148 = distinct !{!148, !19}
!149 = distinct !{!149, !19}
!150 = !{i64 0, i64 8, !20, i64 8, i64 8, !16, i64 16, i64 8, !16}
!151 = distinct !{!151, !19}
!152 = !{!153, !12, i64 0}
!153 = !{!"_ZTS5BFS_F", !12, i64 0}
!154 = distinct !{!154, !19}
!155 = distinct !{!155, !19}
!156 = distinct !{!156, !19}
!157 = !{!158, !7, i64 0}
!158 = !{!"_ZTSN17decode_compressed10sparseTSeqI5BFS_FZ26get_emsparse_no_filter_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_EE", !7, i64 0, !7, i64 4, !153, i64 8, !159, i64 16, !12, i64 24}
!159 = !{!"_ZTSZ26get_emsparse_no_filter_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_", !12, i64 0}
!160 = !{!158, !7, i64 4}
!161 = distinct !{!161, !19}
!162 = distinct !{!162, !19}
!163 = distinct !{!163, !19}
!164 = distinct !{!164, !19}
!165 = distinct !{!165, !19}
!166 = !{!167, !7, i64 0}
!167 = !{!"_ZTSN17decode_compressed7sparseTI5BFS_FZ16get_emsparse_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_EE", !7, i64 0, !7, i64 4, !153, i64 8, !168, i64 16}
!168 = !{!"_ZTSZ16get_emsparse_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_", !12, i64 0}
!169 = !{!167, !7, i64 4}
!170 = distinct !{!170, !19}
!171 = !{!172, !7, i64 0}
!172 = !{!"_ZTSN17decode_compressed7sparseTI5BFS_FZ25get_emsparse_nooutput_genIN4pbbs5emptyELi0EEDavEUljjbE_EE", !7, i64 0, !7, i64 4, !153, i64 8, !173, i64 16}
!173 = !{!"_ZTSZ25get_emsparse_nooutput_genIN4pbbs5emptyELi0EEDavEUljjbE_"}
!174 = !{!172, !7, i64 4}
!175 = distinct !{!175, !19}
!176 = distinct !{!176, !19}
!177 = distinct !{!177, !19}
!178 = distinct !{!178, !19}
!179 = !{!180}
!180 = distinct !{!180, !181, !"_ZN4pbbs11pack_serialI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_: %agg.result"}
!181 = distinct !{!181, !"_ZN4pbbs11pack_serialI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_"}
!182 = !{!183, !180}
!183 = distinct !{!183, !184, !"_Z15make_array_imapIjE10array_imapIT_EPS1_m: %agg.result"}
!184 = distinct !{!184, !"_Z15make_array_imapIjE10array_imapIT_EPS1_m"}
!185 = !{!186, !17, i64 8}
!186 = !{!"_ZTS7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E", !187, i64 0, !17, i64 8, !17, i64 16}
!187 = !{!"_ZTSZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_", !12, i64 0}
!188 = !{!189}
!189 = distinct !{!189, !190, !"_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm: %agg.result"}
!190 = distinct !{!190, !"_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm"}
!191 = !{i64 0, i64 8, !20}
!192 = !{!193}
!193 = distinct !{!193, !194, !"_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm: %agg.result"}
!194 = distinct !{!194, !"_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm"}
!195 = distinct !{!195, !19, !196}
!196 = !{!"tapir.loop.grainsize", i32 1}
!197 = !{!198, !12, i64 0}
!198 = !{!"_ZTS10array_imapImE", !12, i64 0, !12, i64 8, !13, i64 16}
!199 = !{!198, !12, i64 8}
!200 = !{!198, !13, i64 16}
!201 = !{!202}
!202 = distinct !{!202, !203, !"_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm: %agg.result"}
!203 = distinct !{!203, !"_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm"}
!204 = distinct !{!204, !19, !196}
!205 = !{!206}
!206 = distinct !{!206, !207, !"_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm: %agg.result"}
!207 = distinct !{!207, !"_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm"}
!208 = !{!209}
!209 = distinct !{!209, !210, !"_Z15make_array_imapIjE10array_imapIT_EPS1_m: %agg.result"}
!210 = distinct !{!210, !"_Z15make_array_imapIjE10array_imapIT_EPS1_m"}
!211 = distinct !{!211, !19, !196}
!212 = !{!213, !12, i64 0}
!213 = !{!"_ZTSZN4pbbs4scanI10array_imapImES2_ZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_S6_RKT1_S5_jEUlmmmE0_", !12, i64 0, !12, i64 8, !12, i64 16, !12, i64 24, !12, i64 32}
!214 = !{!213, !12, i64 8}
!215 = !{!213, !12, i64 24}
!216 = !{!213, !12, i64 32}
!217 = !{!218}
!218 = distinct !{!218, !219, !"_ZN10array_imapImE3cutEmm: %agg.result"}
!219 = distinct !{!219, !"_ZN10array_imapImE3cutEmm"}
!220 = !{!221}
!221 = distinct !{!221, !222, !"_ZN10array_imapImE3cutEmm: %agg.result"}
!222 = distinct !{!222, !"_ZN10array_imapImE3cutEmm"}
!223 = distinct !{!223, !19, !196}
!224 = distinct !{!224, !19}
!225 = !{!226, !17, i64 16}
!226 = !{!"_ZTS7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_E", !227, i64 0, !17, i64 8, !17, i64 16}
!227 = !{!"_ZTSZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS1_EEEUlmE_", !12, i64 0}
!228 = !{!226, !17, i64 8}
!229 = !{!230}
!230 = distinct !{!230, !231, !"_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_E3cutEmm: %agg.result"}
!231 = distinct !{!231, !"_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_E3cutEmm"}
!232 = distinct !{!232, !19, !196}
!233 = !{!234, !12, i64 0}
!234 = !{!"_ZTSZ15get_emdense_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_", !12, i64 0}
!235 = distinct !{!235, !19, !196}
!236 = distinct !{!236, !19, !196}
!237 = distinct !{!237, !19}
!238 = distinct !{!238, !19}
!239 = !{!158, !12, i64 24}
!240 = !{!159, !12, i64 0}
!241 = distinct !{!241, !19}
!242 = distinct !{!242, !19}
!243 = distinct !{!243, !19, !196}
!244 = distinct !{!244, !19, !196}
!245 = !{!168, !12, i64 0}
!246 = !{i64 0, i64 8, !20, i64 8, i64 8, !20, i64 16, i64 4, !6, i64 20, i64 4, !6}
!247 = distinct !{!247, !19}
!248 = distinct !{!248, !19}
!249 = distinct !{!249, !19}
!250 = distinct !{!250, !19}
!251 = distinct !{!251, !19}
!252 = distinct !{!252, !19}
!253 = distinct !{!253, !19}
!254 = distinct !{!254, !19}
!255 = distinct !{!255, !19}
!256 = distinct !{!256, !19}
!257 = distinct !{!257, !19}
!258 = distinct !{!258, !19}
!259 = distinct !{!259, !19}
!260 = distinct !{!260, !19}
!261 = distinct !{!261, !19}
!262 = distinct !{!262, !19}
!263 = distinct !{!263, !19}
!264 = distinct !{!264, !19, !196}
!265 = distinct !{!265, !19, !196}
!266 = distinct !{!266, !19, !196}
!267 = distinct !{!267, !19, !196}
!268 = !{!269, !7, i64 8}
!269 = !{!"_ZTS15symmetricVertex", !12, i64 0, !7, i64 8}
!270 = !{!269, !12, i64 0}
!271 = distinct !{!271, !19}
!272 = distinct !{!272, !19}
!273 = !{!274, !7, i64 0}
!274 = !{!"_ZTSSt4pairIjjE", !7, i64 0, !7, i64 4}
!275 = !{!274, !7, i64 4}
!276 = distinct !{!276, !19}
!277 = distinct !{!277, !19}
!278 = distinct !{!278, !19}
!279 = !{!280, !12, i64 8}
!280 = !{!"_ZTS16Uncompressed_MemI15symmetricVertexE", !12, i64 8, !17, i64 16, !17, i64 24, !12, i64 32, !12, i64 40}
!281 = !{!280, !17, i64 16}
!282 = !{!280, !17, i64 24}
!283 = !{!280, !12, i64 32}
!284 = !{!280, !12, i64 40}
!285 = !{!80, !12, i64 0}
!286 = !{!80, !17, i64 16}
!287 = !{!80, !13, i64 24}
!288 = distinct !{!288, !19}
!289 = !{i64 0, i64 8, !16, i64 8, i64 8, !20, i64 16, i64 8, !16, i64 24, i64 8, !20}
!290 = distinct !{!290, !19}
!291 = distinct !{!291, !19}
!292 = distinct !{!292, !19}
!293 = distinct !{!293, !19}
!294 = distinct !{!294, !19}
!295 = distinct !{!295, !19}
!296 = distinct !{!296, !19}
!297 = !{!298, !17, i64 8}
!298 = !{!"_ZTSN7intSort5eBitsISt4pairIjjE8getFirstIjEEE", !299, i64 0, !17, i64 8, !17, i64 16}
!299 = !{!"_ZTS8getFirstIjE"}
!300 = !{!298, !17, i64 16}
!301 = !{i64 8, i64 8, !16, i64 16, i64 8, !16}
!302 = distinct !{!302, !19, !196}
!303 = !{!304, !12, i64 0}
!304 = !{!"_ZTS9transposeIjjE", !12, i64 0, !12, i64 8}
!305 = !{!304, !12, i64 8}
!306 = !{!307, !12, i64 0}
!307 = !{!"_ZTS10blockTransISt4pairIjjEjE", !12, i64 0, !12, i64 8, !12, i64 16, !12, i64 24, !12, i64 32}
!308 = !{!307, !12, i64 8}
!309 = !{!307, !12, i64 16}
!310 = !{!307, !12, i64 24}
!311 = !{!307, !12, i64 32}
!312 = distinct !{!312, !19}
!313 = distinct !{!313, !19}
!314 = distinct !{!314, !19}
!315 = distinct !{!315, !19, !196}
!316 = !{!317, !12, i64 0}
!317 = !{!"_ZTS9transposeImmE", !12, i64 0, !12, i64 8}
!318 = !{!317, !12, i64 8}
!319 = !{!320, !12, i64 0}
!320 = !{!"_ZTS10blockTransISt4pairIjjEmE", !12, i64 0, !12, i64 8, !12, i64 16, !12, i64 24, !12, i64 32}
!321 = !{!320, !12, i64 8}
!322 = !{!320, !12, i64 16}
!323 = !{!320, !12, i64 24}
!324 = !{!320, !12, i64 32}
!325 = distinct !{!325, !19}
!326 = distinct !{!326, !19}
!327 = distinct !{!327, !19}
!328 = distinct !{!328, !19}
!329 = distinct !{!329, !19}
!330 = distinct !{!330, !19}
!331 = distinct !{!331, !19}
!332 = distinct !{!332, !19}
!333 = distinct !{!333, !19}
!334 = distinct !{!334, !19}
!335 = distinct !{!335, !19}
!336 = distinct !{!336, !19}
!337 = distinct !{!337, !19}
!338 = distinct !{!338, !19}
!339 = distinct !{!339, !19}
!340 = distinct !{!340, !19}
!341 = distinct !{!341, !19}
!342 = distinct !{!342, !19}
!343 = distinct !{!343, !19}
!344 = distinct !{!344, !19}
!345 = distinct !{!345, !19}
!346 = distinct !{!346, !19}
!347 = distinct !{!347, !19}
!348 = distinct !{!348, !19}
!349 = distinct !{!349, !19}
!350 = distinct !{!350, !19}
!351 = distinct !{!351, !19}
!352 = distinct !{!352, !19}
!353 = distinct !{!353, !19, !196}
!354 = distinct !{!354, !19, !196}
!355 = distinct !{!355, !19, !196}
!356 = distinct !{!356, !19, !196}
!357 = !{!358, !7, i64 16}
!358 = !{!"_ZTS16asymmetricVertex", !12, i64 0, !12, i64 8, !7, i64 16, !7, i64 20}
!359 = !{!358, !12, i64 8}
!360 = distinct !{!360, !19}
!361 = distinct !{!361, !19}
!362 = distinct !{!362, !19}
!363 = distinct !{!363, !19}
!364 = !{!358, !7, i64 20}
!365 = !{!358, !12, i64 0}
!366 = distinct !{!366, !19}
!367 = !{!368, !12, i64 8}
!368 = !{!"_ZTS16Uncompressed_MemI16asymmetricVertexE", !12, i64 8, !17, i64 16, !17, i64 24, !12, i64 32, !12, i64 40}
!369 = !{!368, !17, i64 16}
!370 = !{!368, !17, i64 24}
!371 = !{!368, !12, i64 32}
!372 = !{!368, !12, i64 40}
!373 = !{!83, !17, i64 16}
!374 = distinct !{!374, !19}
!375 = distinct !{!375, !19}
!376 = distinct !{!376, !19}
!377 = distinct !{!377, !19}
!378 = distinct !{!378, !19}
!379 = distinct !{!379, !19}
!380 = distinct !{!380, !19}
!381 = distinct !{!381, !19}
!382 = distinct !{!382, !19}
!383 = distinct !{!383, !19}
!384 = distinct !{!384, !19}
!385 = distinct !{!385, !19}
!386 = distinct !{!386, !19}
!387 = distinct !{!387, !19}
!388 = distinct !{!388, !19}
!389 = distinct !{!389, !19}
!390 = distinct !{!390, !19}
!391 = distinct !{!391, !19}
!392 = distinct !{!392, !19}
!393 = distinct !{!393, !19}
!394 = distinct !{!394, !19}
!395 = distinct !{!395, !19}
!396 = distinct !{!396, !19}
!397 = distinct !{!397, !19}
!398 = distinct !{!398, !19}
!399 = distinct !{!399, !19}
!400 = distinct !{!400, !19}
!401 = distinct !{!401, !19}
!402 = distinct !{!402, !19}
!403 = distinct !{!403, !19}
!404 = distinct !{!404, !19}
!405 = distinct !{!405, !19, !196}
!406 = distinct !{!406, !19, !196}
!407 = distinct !{!407, !19, !196}
!408 = distinct !{!408, !19, !196}
