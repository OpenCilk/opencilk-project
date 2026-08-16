; Check that CSI setup maintains one unwind desintation for a taskframe.
;
; RUN: opt < %s -passes="csi-setup" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl" }
%"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl" = type { %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data" }
%"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data" = type { ptr, ptr, ptr }

; Function Attrs: mustprogress uwtable
define dso_local noundef i32 @_Z3fooSt6vectorIiSaIiEE(ptr noundef readonly captures(none) %fooarg) local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %agg.tmp = alloca %"class.std::vector", align 8
  %ret = alloca i32, align 4
  %syncreg = tail call token @llvm.syncregion.start()
  %agg.tmp16 = alloca %"class.std::vector", align 8
  %_M_finish.i.i = getelementptr inbounds nuw i8, ptr %fooarg, i64 8
  %0 = load ptr, ptr %_M_finish.i.i, align 8, !tbaa !5
  %1 = load ptr, ptr %fooarg, align 8, !tbaa !11
  %sub.ptr.lhs.cast.i.i = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast.i.i = ptrtoint ptr %1 to i64
  %sub.ptr.sub.i.i = sub i64 %sub.ptr.lhs.cast.i.i, %sub.ptr.rhs.cast.i.i
  %sub.ptr.div.i.i = ashr exact i64 %sub.ptr.sub.i.i, 2
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %agg.tmp, i8 0, i64 24, i1 false)
  %cmp.not.i.i.i.i = icmp eq ptr %0, %1
  br i1 %cmp.not.i.i.i.i, label %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i, label %cond.true.i.i.i.i

cond.true.i.i.i.i:                                ; preds = %entry
  %cmp.i.i.i.i.i = icmp ugt i64 %sub.ptr.div.i.i, 2305843009213693951
  br i1 %cmp.i.i.i.i.i, label %if.then.i.i.i.i.i, label %_ZNSt15__new_allocatorIiE8allocateEmPKv.exit.i.i.i.i, !prof !12

if.then.i.i.i.i.i:                                ; preds = %cond.true.i.i.i.i
  %cmp2.i.i.i.i.i = icmp ugt i64 %sub.ptr.div.i.i, 4611686018427387903
  br i1 %cmp2.i.i.i.i.i, label %if.then3.i.i.i.i.i, label %if.end.i.i.i.i.i

if.then3.i.i.i.i.i:                               ; preds = %if.then.i.i.i.i.i
  tail call void @_ZSt28__throw_bad_array_new_lengthv() #10
  unreachable

if.end.i.i.i.i.i:                                 ; preds = %if.then.i.i.i.i.i
  tail call void @_ZSt17__throw_bad_allocv() #10
  unreachable

_ZNSt15__new_allocatorIiE8allocateEmPKv.exit.i.i.i.i: ; preds = %cond.true.i.i.i.i
  %call5.i.i.i1.i5.i = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %sub.ptr.sub.i.i) #11
  br label %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i

_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i:      ; preds = %_ZNSt15__new_allocatorIiE8allocateEmPKv.exit.i.i.i.i, %entry
  %cond.i.i.i.i = phi ptr [ null, %entry ], [ %call5.i.i.i1.i5.i, %_ZNSt15__new_allocatorIiE8allocateEmPKv.exit.i.i.i.i ]
  store ptr %cond.i.i.i.i, ptr %agg.tmp, align 8, !tbaa !11
  %_M_finish.i.i.i = getelementptr inbounds nuw i8, ptr %agg.tmp, i64 8
  store ptr %cond.i.i.i.i, ptr %_M_finish.i.i.i, align 8, !tbaa !5
  %add.ptr.i.i.i = getelementptr inbounds i8, ptr %cond.i.i.i.i, i64 %sub.ptr.sub.i.i
  %_M_end_of_storage.i.i.i = getelementptr inbounds nuw i8, ptr %agg.tmp, i64 16
  store ptr %add.ptr.i.i.i, ptr %_M_end_of_storage.i.i.i, align 8, !tbaa !13
  %cmp.i.i.i.i.i.i.i.i.i = icmp sgt i64 %sub.ptr.sub.i.i, 4
  br i1 %cmp.i.i.i.i.i.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i.i, label %if.else.i.i.i.i.i.i.i.i.i, !prof !14

if.then.i.i.i.i.i.i.i.i.i:                        ; preds = %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i
  tail call void @llvm.memmove.p0.p0.i64(ptr align 4 %cond.i.i.i.i, ptr align 4 %1, i64 %sub.ptr.sub.i.i, i1 false)
  br label %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit

if.else.i.i.i.i.i.i.i.i.i:                        ; preds = %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i
  %cmp1.i.i.i.i.i.i.i.i.i = icmp eq i64 %sub.ptr.sub.i.i, 4
  br i1 %cmp1.i.i.i.i.i.i.i.i.i, label %if.then2.i.i.i.i.i.i.i.i.i, label %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit

if.then2.i.i.i.i.i.i.i.i.i:                       ; preds = %if.else.i.i.i.i.i.i.i.i.i
  %2 = load i32, ptr %1, align 4, !tbaa !15
  store i32 %2, ptr %cond.i.i.i.i, align 4, !tbaa !15
  br label %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit

_ZNSt6vectorIiSaIiEEC2ERKS1_.exit:                ; preds = %if.then.i.i.i.i.i.i.i.i.i, %if.else.i.i.i.i.i.i.i.i.i, %if.then2.i.i.i.i.i.i.i.i.i
  store ptr %add.ptr.i.i.i, ptr %_M_finish.i.i.i, align 8, !tbaa !5
  %call = invoke noundef i32 @_Z3barSt6vectorIiSaIiEE(ptr noundef nonnull %agg.tmp)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit
  %3 = load ptr, ptr %agg.tmp, align 8, !tbaa !11
  %tobool.not.i.i.i = icmp eq ptr %3, null
  br i1 %tobool.not.i.i.i, label %_ZNSt6vectorIiSaIiEED2Ev.exit, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %invoke.cont
  %4 = load ptr, ptr %_M_end_of_storage.i.i.i, align 8, !tbaa !13
  %sub.ptr.lhs.cast.i.i4 = ptrtoint ptr %4 to i64
  %sub.ptr.rhs.cast.i.i5 = ptrtoint ptr %3 to i64
  %sub.ptr.sub.i.i6 = sub i64 %sub.ptr.lhs.cast.i.i4, %sub.ptr.rhs.cast.i.i5
  call void @_ZdlPvm(ptr noundef nonnull %3, i64 noundef %sub.ptr.sub.i.i6) #12
  br label %_ZNSt6vectorIiSaIiEED2Ev.exit

_ZNSt6vectorIiSaIiEED2Ev.exit:                    ; preds = %invoke.cont, %if.then.i.i.i
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %ret)
  %5 = load ptr, ptr %_M_finish.i.i, align 8, !tbaa !5
  %6 = load ptr, ptr %fooarg, align 8, !tbaa !11
  %sub.ptr.lhs.cast.i.i8 = ptrtoint ptr %5 to i64
  %sub.ptr.rhs.cast.i.i9 = ptrtoint ptr %6 to i64
  %sub.ptr.sub.i.i10 = sub i64 %sub.ptr.lhs.cast.i.i8, %sub.ptr.rhs.cast.i.i9
  %sub.ptr.div.i.i11 = ashr exact i64 %sub.ptr.sub.i.i10, 2
  %cmp.not.i.i.i.i12 = icmp eq ptr %5, %6
  %7 = call token @llvm.taskframe.create()
  %agg.tmp1 = alloca %"class.std::vector", align 8
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %agg.tmp1, i8 0, i64 24, i1 false)
  br i1 %cmp.not.i.i.i.i12, label %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i17, label %cond.true.i.i.i.i13

; CHECK: _ZNSt6vectorIiSaIiEED2Ev.exit:
; CHECK: %[[TF:.+]] = call token @llvm.taskframe.create()
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF]],
; CHECK-NOT: void @llvm.taskframe.resume.sl_p0i32s(token %[[TF]],

cond.true.i.i.i.i13:                              ; preds = %_ZNSt6vectorIiSaIiEED2Ev.exit
  %cmp.i.i.i.i.i14 = icmp ugt i64 %sub.ptr.div.i.i11, 2305843009213693951
  br i1 %cmp.i.i.i.i.i14, label %if.then.i.i.i.i.i31, label %_ZNSt15__new_allocatorIiE8allocateEmPKv.exit.i.i.i.i15, !prof !12

if.then.i.i.i.i.i31:                              ; preds = %cond.true.i.i.i.i13
  %cmp2.i.i.i.i.i32 = icmp ugt i64 %sub.ptr.div.i.i11, 4611686018427387903
  br i1 %cmp2.i.i.i.i.i32, label %if.then3.i.i.i.i.i34, label %if.end.i.i.i.i.i33

if.then3.i.i.i.i.i34:                             ; preds = %if.then.i.i.i.i.i31
  call void @_ZSt28__throw_bad_array_new_lengthv() #10
  unreachable

if.end.i.i.i.i.i33:                               ; preds = %if.then.i.i.i.i.i31
  call void @_ZSt17__throw_bad_allocv() #10
  unreachable

_ZNSt15__new_allocatorIiE8allocateEmPKv.exit.i.i.i.i15: ; preds = %cond.true.i.i.i.i13
  %call5.i.i.i1.i5.i16 = call noalias noundef nonnull ptr @_Znwm(i64 noundef %sub.ptr.sub.i.i10) #11
  br label %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i17

_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i17:    ; preds = %_ZNSt15__new_allocatorIiE8allocateEmPKv.exit.i.i.i.i15, %_ZNSt6vectorIiSaIiEED2Ev.exit
  %cond.i.i.i.i18 = phi ptr [ null, %_ZNSt6vectorIiSaIiEED2Ev.exit ], [ %call5.i.i.i1.i5.i16, %_ZNSt15__new_allocatorIiE8allocateEmPKv.exit.i.i.i.i15 ]
  store ptr %cond.i.i.i.i18, ptr %agg.tmp1, align 8, !tbaa !11
  %_M_finish.i.i.i19 = getelementptr inbounds nuw i8, ptr %agg.tmp1, i64 8
  store ptr %cond.i.i.i.i18, ptr %_M_finish.i.i.i19, align 8, !tbaa !5
  %add.ptr.i.i.i20 = getelementptr inbounds i8, ptr %cond.i.i.i.i18, i64 %sub.ptr.sub.i.i10
  %_M_end_of_storage.i.i.i21 = getelementptr inbounds nuw i8, ptr %agg.tmp1, i64 16
  store ptr %add.ptr.i.i.i20, ptr %_M_end_of_storage.i.i.i21, align 8, !tbaa !13
  %cmp.i.i.i.i.i.i.i.i.i25 = icmp sgt i64 %sub.ptr.sub.i.i10, 4
  br i1 %cmp.i.i.i.i.i.i.i.i.i25, label %if.then.i.i.i.i.i.i.i.i.i30, label %if.else.i.i.i.i.i.i.i.i.i26, !prof !14

if.then.i.i.i.i.i.i.i.i.i30:                      ; preds = %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i17
  call void @llvm.memmove.p0.p0.i64(ptr align 4 %cond.i.i.i.i18, ptr align 4 %6, i64 %sub.ptr.sub.i.i10, i1 false)
  br label %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit35

if.else.i.i.i.i.i.i.i.i.i26:                      ; preds = %_ZNSt12_Vector_baseIiSaIiEEC2EmRKS0_.exit.i17
  %cmp1.i.i.i.i.i.i.i.i.i27 = icmp eq i64 %sub.ptr.sub.i.i10, 4
  br i1 %cmp1.i.i.i.i.i.i.i.i.i27, label %if.then2.i.i.i.i.i.i.i.i.i29, label %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit35

if.then2.i.i.i.i.i.i.i.i.i29:                     ; preds = %if.else.i.i.i.i.i.i.i.i.i26
  %8 = load i32, ptr %6, align 4, !tbaa !15
  store i32 %8, ptr %cond.i.i.i.i18, align 4, !tbaa !15
  br label %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit35

_ZNSt6vectorIiSaIiEEC2ERKS1_.exit35:              ; preds = %if.then.i.i.i.i.i.i.i.i.i30, %if.else.i.i.i.i.i.i.i.i.i26, %if.then2.i.i.i.i.i.i.i.i.i29
  store ptr %add.ptr.i.i.i20, ptr %_M_finish.i.i.i19, align 8, !tbaa !5
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad8

det.achd:                                         ; preds = %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit35
  call void @llvm.taskframe.use(token %7)
  %call6 = invoke noundef i32 @_Z3barSt6vectorIiSaIiEE(ptr noundef nonnull %agg.tmp1)
          to label %invoke.cont5 unwind label %lpad2

invoke.cont5:                                     ; preds = %det.achd
  %9 = load ptr, ptr %agg.tmp1, align 8, !tbaa !11
  %tobool.not.i.i.i36 = icmp eq ptr %9, null
  br i1 %tobool.not.i.i.i36, label %_ZNSt6vectorIiSaIiEED2Ev.exit42, label %if.then.i.i.i37

if.then.i.i.i37:                                  ; preds = %invoke.cont5
  %10 = load ptr, ptr %_M_end_of_storage.i.i.i21, align 8, !tbaa !13
  %sub.ptr.lhs.cast.i.i39 = ptrtoint ptr %10 to i64
  %sub.ptr.rhs.cast.i.i40 = ptrtoint ptr %9 to i64
  %sub.ptr.sub.i.i41 = sub i64 %sub.ptr.lhs.cast.i.i39, %sub.ptr.rhs.cast.i.i40
  call void @_ZdlPvm(ptr noundef nonnull %9, i64 noundef %sub.ptr.sub.i.i41) #12
  br label %_ZNSt6vectorIiSaIiEED2Ev.exit42

_ZNSt6vectorIiSaIiEED2Ev.exit42:                  ; preds = %invoke.cont5, %if.then.i.i.i37
  store i32 %call6, ptr %ret, align 4, !tbaa !15
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %_ZNSt6vectorIiSaIiEED2Ev.exit42, %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit35
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %agg.tmp16, i8 0, i64 24, i1 false)
  %call5.i.i.i2.i = invoke noalias noundef nonnull dereferenceable(4) ptr @_Znwm(i64 noundef 4) #11
          to label %_ZNSt6vectorIiSaIiEEC2ESt16initializer_listIiERKS0_.exit unwind label %lpad.i

lpad.i:                                           ; preds = %det.cont
  %11 = landingpad { ptr, i32 }
          cleanup
  %12 = load ptr, ptr %agg.tmp16, align 8, !tbaa !11
  %tobool.not.i.i.i43 = icmp eq ptr %12, null
  br i1 %tobool.not.i.i.i43, label %ehcleanup28, label %if.then.i.i3.i

if.then.i.i3.i:                                   ; preds = %lpad.i
  %_M_end_of_storage.i4.i = getelementptr inbounds nuw i8, ptr %agg.tmp16, i64 16
  %13 = load ptr, ptr %_M_end_of_storage.i4.i, align 8, !tbaa !13
  %sub.ptr.lhs.cast.i.i44 = ptrtoint ptr %13 to i64
  %sub.ptr.rhs.cast.i.i45 = ptrtoint ptr %12 to i64
  %sub.ptr.sub.i.i46 = sub i64 %sub.ptr.lhs.cast.i.i44, %sub.ptr.rhs.cast.i.i45
  call void @_ZdlPvm(ptr noundef nonnull %12, i64 noundef %sub.ptr.sub.i.i46) #12
  br label %ehcleanup28

_ZNSt6vectorIiSaIiEEC2ESt16initializer_listIiERKS0_.exit: ; preds = %det.cont
  store ptr %call5.i.i.i2.i, ptr %agg.tmp16, align 8, !tbaa !11
  %add.ptr.i1.i = getelementptr inbounds nuw i8, ptr %call5.i.i.i2.i, i64 4
  %_M_end_of_storage.i.i47 = getelementptr inbounds nuw i8, ptr %agg.tmp16, i64 16
  store ptr %add.ptr.i1.i, ptr %_M_end_of_storage.i.i47, align 8, !tbaa !13
  store i32 1, ptr %call5.i.i.i2.i, align 4, !tbaa !15
  %_M_finish.i.i48 = getelementptr inbounds nuw i8, ptr %agg.tmp16, i64 8
  store ptr %add.ptr.i1.i, ptr %_M_finish.i.i48, align 8, !tbaa !5
  %call23 = invoke noundef i32 @_Z3barSt6vectorIiSaIiEE(ptr noundef nonnull %agg.tmp16)
          to label %invoke.cont22 unwind label %lpad21

invoke.cont22:                                    ; preds = %_ZNSt6vectorIiSaIiEEC2ESt16initializer_listIiERKS0_.exit
  %14 = load ptr, ptr %agg.tmp16, align 8, !tbaa !11
  %tobool.not.i.i.i49 = icmp eq ptr %14, null
  br i1 %tobool.not.i.i.i49, label %_ZNSt6vectorIiSaIiEED2Ev.exit56, label %if.then.i.i.i50

if.then.i.i.i50:                                  ; preds = %invoke.cont22
  %15 = load ptr, ptr %_M_end_of_storage.i.i47, align 8, !tbaa !13
  %sub.ptr.lhs.cast.i.i52 = ptrtoint ptr %15 to i64
  %sub.ptr.rhs.cast.i.i53 = ptrtoint ptr %14 to i64
  %sub.ptr.sub.i.i54 = sub i64 %sub.ptr.lhs.cast.i.i52, %sub.ptr.rhs.cast.i.i53
  call void @_ZdlPvm(ptr noundef nonnull %14, i64 noundef %sub.ptr.sub.i.i54) #12
  br label %_ZNSt6vectorIiSaIiEED2Ev.exit56

_ZNSt6vectorIiSaIiEED2Ev.exit56:                  ; preds = %invoke.cont22, %if.then.i.i.i50
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %_ZNSt6vectorIiSaIiEED2Ev.exit56
  call void @llvm.sync.unwind(token %syncreg)
  %ret.0.load82 = load i32, ptr %ret, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %ret)
  ret i32 %ret.0.load82

lpad:                                             ; preds = %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit
  %16 = landingpad { ptr, i32 }
          cleanup
  %17 = load ptr, ptr %agg.tmp, align 8, !tbaa !11
  %tobool.not.i.i.i57 = icmp eq ptr %17, null
  br i1 %tobool.not.i.i.i57, label %eh.resume, label %if.then.i.i.i58

if.then.i.i.i58:                                  ; preds = %lpad
  %18 = load ptr, ptr %_M_end_of_storage.i.i.i, align 8, !tbaa !13
  %sub.ptr.lhs.cast.i.i60 = ptrtoint ptr %18 to i64
  %sub.ptr.rhs.cast.i.i61 = ptrtoint ptr %17 to i64
  %sub.ptr.sub.i.i62 = sub i64 %sub.ptr.lhs.cast.i.i60, %sub.ptr.rhs.cast.i.i61
  call void @_ZdlPvm(ptr noundef nonnull %17, i64 noundef %sub.ptr.sub.i.i62) #12
  br label %eh.resume

lpad2:                                            ; preds = %det.achd
  %19 = landingpad { ptr, i32 }
          cleanup
  %20 = load ptr, ptr %agg.tmp1, align 8, !tbaa !11
  %tobool.not.i.i.i65 = icmp eq ptr %20, null
  br i1 %tobool.not.i.i.i65, label %_ZNSt6vectorIiSaIiEED2Ev.exit72, label %if.then.i.i.i66

if.then.i.i.i66:                                  ; preds = %lpad2
  %21 = load ptr, ptr %_M_end_of_storage.i.i.i21, align 8, !tbaa !13
  %sub.ptr.lhs.cast.i.i68 = ptrtoint ptr %21 to i64
  %sub.ptr.rhs.cast.i.i69 = ptrtoint ptr %20 to i64
  %sub.ptr.sub.i.i70 = sub i64 %sub.ptr.lhs.cast.i.i68, %sub.ptr.rhs.cast.i.i69
  call void @_ZdlPvm(ptr noundef nonnull %20, i64 noundef %sub.ptr.sub.i.i70) #12
  br label %_ZNSt6vectorIiSaIiEED2Ev.exit72

_ZNSt6vectorIiSaIiEED2Ev.exit72:                  ; preds = %lpad2, %if.then.i.i.i66
  invoke void @llvm.detached.rethrow.sl_p0i32s(token %syncreg, { ptr, i32 } %19)
          to label %unreachable unwind label %lpad8

lpad8:                                            ; preds = %_ZNSt6vectorIiSaIiEED2Ev.exit72, %_ZNSt6vectorIiSaIiEEC2ERKS1_.exit35
  %22 = landingpad { ptr, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i32s(token %7, { ptr, i32 } %22)
          to label %unreachable unwind label %lpad15

lpad15:                                           ; preds = %lpad8
  %23 = landingpad { ptr, i32 }
          cleanup
  br label %ehcleanup28

lpad21:                                           ; preds = %_ZNSt6vectorIiSaIiEEC2ESt16initializer_listIiERKS0_.exit
  %24 = landingpad { ptr, i32 }
          cleanup
  %25 = load ptr, ptr %agg.tmp16, align 8, !tbaa !11
  %tobool.not.i.i.i73 = icmp eq ptr %25, null
  br i1 %tobool.not.i.i.i73, label %ehcleanup28, label %if.then.i.i.i74

if.then.i.i.i74:                                  ; preds = %lpad21
  %26 = load ptr, ptr %_M_end_of_storage.i.i47, align 8, !tbaa !13
  %sub.ptr.lhs.cast.i.i76 = ptrtoint ptr %26 to i64
  %sub.ptr.rhs.cast.i.i77 = ptrtoint ptr %25 to i64
  %sub.ptr.sub.i.i78 = sub i64 %sub.ptr.lhs.cast.i.i76, %sub.ptr.rhs.cast.i.i77
  call void @_ZdlPvm(ptr noundef nonnull %25, i64 noundef %sub.ptr.sub.i.i78) #12
  br label %ehcleanup28

ehcleanup28:                                      ; preds = %lpad.i, %if.then.i.i3.i, %lpad21, %if.then.i.i.i74, %lpad15
  %.pn.pn = phi { ptr, i32 } [ %23, %lpad15 ], [ %11, %lpad.i ], [ %11, %if.then.i.i3.i ], [ %24, %lpad21 ], [ %24, %if.then.i.i.i74 ]
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %ret)
  br label %eh.resume

eh.resume:                                        ; preds = %if.then.i.i.i58, %lpad, %ehcleanup28
  %.pn.pn.pn = phi { ptr, i32 } [ %.pn.pn, %ehcleanup28 ], [ %16, %lpad ], [ %16, %if.then.i.i.i58 ]
  resume { ptr, i32 } %.pn.pn.pn

unreachable:                                      ; preds = %lpad8, %_ZNSt6vectorIiSaIiEED2Ev.exit72
  unreachable
}

declare noundef i32 @_Z3barSt6vectorIiSaIiEE(ptr noundef) local_unnamed_addr #1

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #2

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #3

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #3

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #3

; Function Attrs: mustprogress willreturn memory(argmem: readwrite)
declare void @llvm.detached.rethrow.sl_p0i32s(token, { ptr, i32 }) #4

; Function Attrs: mustprogress willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.resume.sl_p0i32s(token, { ptr, i32 }) #4

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #2

; Function Attrs: mustprogress willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #4

; Function Attrs: noreturn
declare void @_ZSt28__throw_bad_array_new_lengthv() local_unnamed_addr #5

; Function Attrs: noreturn
declare void @_ZSt17__throw_bad_allocv() local_unnamed_addr #5

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #6

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr writeonly captures(none), ptr readonly captures(none), i64, i1 immarg) #7

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPvm(ptr noundef, i64 noundef) local_unnamed_addr #8

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #9

attributes #0 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { mustprogress nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { mustprogress willreturn memory(argmem: readwrite) }
attributes #5 = { noreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #8 = { nobuiltin nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #10 = { noreturn }
attributes #11 = { builtin allocsize(0) }
attributes #12 = { builtin nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 21.1.3 (git@github.com:OpenCilk/opencilk-project.git 9dbd14e54e7029671dcbdf1f82242aa968a32eac)"}
!5 = !{!6, !7, i64 8}
!6 = !{!"_ZTSNSt12_Vector_baseIiSaIiEE17_Vector_impl_dataE", !7, i64 0, !7, i64 8, !7, i64 16}
!7 = !{!"p1 int", !8, i64 0}
!8 = !{!"any pointer", !9, i64 0}
!9 = !{!"omnipotent char", !10, i64 0}
!10 = !{!"Simple C++ TBAA"}
!11 = !{!6, !7, i64 0}
!12 = !{!"branch_weights", !"expected", i32 1, i32 2000}
!13 = !{!6, !7, i64 16}
!14 = !{!"branch_weights", !"expected", i32 2000, i32 1}
!15 = !{!16, !16, i64 0}
!16 = !{!"int", !9, i64 0}
