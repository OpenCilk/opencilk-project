; RUN: opt < %s -loop-spawning-ti -S | FileCheck %s
; RUN: opt < %s -passes=loop-spawning -S | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Bar = type { i8 }

@_ZTIc = external dso_local constant i8*
@_ZTIi = external dso_local constant i8*

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind readnone
declare i32 @llvm.eh.typeid.for(i8*) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

; Function Attrs: nounwind
declare dso_local void @_Z9catchfn_cic(i32, i8 signext) local_unnamed_addr #3

declare dso_local void @__cxa_end_catch() local_unnamed_addr

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: uwtable
declare dso_local void @_Z3bari(i32 %a) local_unnamed_addr #0

; Function Attrs: uwtable
define dso_local void @_Z3fooi(i32 %a) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_Z3bari(i32 %a)
          to label %try.cont unwind label %lpad

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIc to i8*)
  %1 = extractvalue { i8*, i32 } %0, 1
  %2 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIc to i8*)) #6
  %matches = icmp eq i32 %1, %2
  br i1 %matches, label %catch, label %eh.resume

catch:                                            ; preds = %lpad
  %3 = extractvalue { i8*, i32 } %0, 0
  %4 = tail call i8* @__cxa_begin_catch(i8* %3) #6
  %5 = load i8, i8* %4, align 1, !tbaa !6
  tail call void @_Z9catchfn_cic(i32 1, i8 signext %5) #6
  tail call void @__cxa_end_catch() #6
  br label %try.cont

try.cont:                                         ; preds = %entry, %catch
  ret void

eh.resume:                                        ; preds = %lpad
  resume { i8*, i32 } %0
}

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly nounwind
declare token @llvm.taskframe.create() #2

; Function Attrs: argmemonly nounwind
declare void @llvm.taskframe.use(token) #2

; Function Attrs: nounwind
declare dso_local void @_Z9nothrowfni(i32) local_unnamed_addr #3

declare dso_local void @_ZN3BarC1Ev(%class.Bar*) unnamed_addr #4

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #5

; Function Attrs: argmemonly
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #5

; Function Attrs: nounwind
declare dso_local void @_ZN3BarD1Ev(%class.Bar*) unnamed_addr #3

; Function Attrs: nounwind
declare dso_local void @_Z9catchfn_iii(i32, i32) local_unnamed_addr #3

; Function Attrs: uwtable
define dso_local i32 @_Z15parfor_trycatchi(i32 %a) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local i32 @_Z15parfor_trycatchi(
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %syncreg1 = tail call token @llvm.syncregion.start()
  %syncreg36 = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %entry
  tail call void @llvm.taskframe.use(token %0)
  tail call void @_Z3fooi(i32 1)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %entry
  %cmp = icmp sgt i32 %a, 0
  br i1 %cmp, label %pfor.cond, label %cleanup104
; CHECK: det.cont:
; CHECK: br i1 %cmp, label %[[PREHEADER:.+]], label %cleanup104

; CHECK: [[PREHEADER]]:
; CHECK: call i32 @llvm.tapir.loop.grainsize.i32(
; CHECK: call fastcc void @_Z15parfor_trycatchi.outline_pfor.cond.ls1(
; CHECK: br label %pfor.cond.cleanup

pfor.cond:                                        ; preds = %det.cont, %pfor.inc
  %__begin.0 = phi i32 [ %inc, %pfor.inc ], [ 0, %det.cont ]
  detach within %syncreg1, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %syncreg4 = tail call token @llvm.syncregion.start()
  %1 = tail call token @llvm.taskframe.create()
  detach within %syncreg4, label %det.achd5, label %det.cont10 unwind label %lpad7

det.achd5:                                        ; preds = %pfor.body
  tail call void @llvm.taskframe.use(token %1)
  invoke void @_Z3fooi(i32 2)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %det.achd5
  reattach within %syncreg4, label %det.cont10

det.cont10:                                       ; preds = %pfor.body, %invoke.cont
  tail call void @_Z9nothrowfni(i32 3) #6
  sync within %syncreg4, label %pfor.preattach

lpad:                                             ; preds = %det.achd5
  %2 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg4, { i8*, i32 } %2)
          to label %unreachable unwind label %lpad7

lpad7:                                            ; preds = %pfor.body, %lpad
  %3 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %1, { i8*, i32 } %3)
          to label %unreachable unwind label %lpad15

lpad15:                                           ; preds = %lpad7
  %4 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %5 = extractvalue { i8*, i32 } %4, 1
  %6 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #6
  %matches = icmp eq i32 %5, %6
  call void @llvm.assume(i1 %matches)
  %7 = extractvalue { i8*, i32 } %4, 0
  %8 = tail call i8* @__cxa_begin_catch(i8* %7) #6
  %9 = bitcast i8* %8 to i32*
  %10 = load i32, i32* %9, align 4, !tbaa !2
  tail call void @_Z9catchfn_iii(i32 1, i32 %10) #6
  tail call void @__cxa_end_catch() #6
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %lpad15, %det.cont10
  reattach within %syncreg1, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.cond, %pfor.preattach
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond158 = icmp eq i32 %inc, %a
  br i1 %exitcond158, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !10

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg1, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup
  br i1 %cmp, label %pfor.cond48, label %cleanup104
; CHECK: cleanup:
; CHECK: br i1 %cmp, label %[[PREHEADER2:.+]], label %cleanup104

; CHECK: [[PREHEADER2]]:
; CHECK: call i32 @llvm.tapir.loop.grainsize.i32(
; CHECK: call fastcc void @_Z15parfor_trycatchi.outline_pfor.cond48.ls1(
; CHECK: br label %pfor.cond.cleanup97

pfor.cond48:                                      ; preds = %cleanup, %pfor.inc94
  %__begin42.0 = phi i32 [ %inc95, %pfor.inc94 ], [ 0, %cleanup ]
  detach within %syncreg36, label %pfor.body54, label %pfor.inc94

pfor.body54:                                      ; preds = %pfor.cond48
  %syncreg55 = tail call token @llvm.syncregion.start()
  %11 = tail call token @llvm.taskframe.create()
  detach within %syncreg55, label %det.achd56, label %det.cont69 unwind label %lpad66

det.achd56:                                       ; preds = %pfor.body54
  tail call void @llvm.taskframe.use(token %11)
  invoke void @_Z3fooi(i32 4)
          to label %invoke.cont60 unwind label %lpad57

invoke.cont60:                                    ; preds = %det.achd56
  reattach within %syncreg55, label %det.cont69

det.cont69:                                       ; preds = %pfor.body54, %invoke.cont60
  tail call void @_Z9nothrowfni(i32 5) #6
  sync within %syncreg55, label %pfor.preattach86

lpad57:                                           ; preds = %det.achd56
  %12 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg55, { i8*, i32 } %12)
          to label %unreachable unwind label %lpad66

lpad66:                                           ; preds = %pfor.body54, %lpad57
  %13 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %11, { i8*, i32 } %13)
          to label %unreachable unwind label %lpad75

lpad75:                                           ; preds = %lpad66
  %14 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %15 = extractvalue { i8*, i32 } %14, 1
  %16 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #6
  %matches81 = icmp eq i32 %15, %16
  call void @llvm.assume(i1 %matches81)
  %17 = extractvalue { i8*, i32 } %14, 0
  %18 = tail call i8* @__cxa_begin_catch(i8* %17) #6
  %19 = bitcast i8* %18 to i32*
  %20 = load i32, i32* %19, align 4, !tbaa !2
  tail call void @_Z9catchfn_iii(i32 2, i32 %20) #6
  tail call void @__cxa_end_catch() #6
  br label %pfor.preattach86

pfor.preattach86:                                 ; preds = %lpad75, %det.cont69
  reattach within %syncreg36, label %pfor.inc94

pfor.inc94:                                       ; preds = %pfor.cond48, %pfor.preattach86
  %inc95 = add nuw nsw i32 %__begin42.0, 1
  %exitcond = icmp eq i32 %inc95, %a
  br i1 %exitcond, label %pfor.cond.cleanup97, label %pfor.cond48, !llvm.loop !11

pfor.cond.cleanup97:                              ; preds = %pfor.inc94
  sync within %syncreg36, label %cleanup104

cleanup104:                                       ; preds = %det.cont, %pfor.cond.cleanup97, %cleanup
  %21 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd109, label %det.cont110

det.achd109:                                      ; preds = %cleanup104
  tail call void @llvm.taskframe.use(token %21)
  tail call void @_Z3fooi(i32 6)
  reattach within %syncreg, label %det.cont110

det.cont110:                                      ; preds = %det.achd109, %cleanup104
  tail call void @_Z9nothrowfni(i32 7) #6
  sync within %syncreg, label %sync.continue111

sync.continue111:                                 ; preds = %det.cont110
  ret i32 0

unreachable:                                      ; preds = %lpad7, %lpad, %lpad66, %lpad57
  unreachable
}

; Function Attrs: uwtable
define dso_local i32 @_Z27parfor_trycatch_destructorsi(i32 %a) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local i32 @_Z27parfor_trycatch_destructorsi(
entry:
  %b1 = alloca %class.Bar, align 1
  %syncreg = tail call token @llvm.syncregion.start()
  %syncreg12 = tail call token @llvm.syncregion.start()
  %syncreg58 = tail call token @llvm.syncregion.start()
  %b4 = alloca %class.Bar, align 1
  %0 = getelementptr inbounds %class.Bar, %class.Bar* %b1, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %0) #6
  call void @_ZN3BarC1Ev(%class.Bar* nonnull %b1)
  %1 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad2

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %1)
  invoke void @_Z3fooi(i32 1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %det.achd
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %entry, %invoke.cont
  %cmp = icmp sgt i32 %a, 0
  br i1 %cmp, label %pfor.cond, label %cleanup130
; CHECK: det.cont:
; CHECK: br i1 %cmp, label %[[PREHEADER:.+]], label %cleanup130

; CHECK: [[PREHEADER]]:
; CHECK: call i32 @llvm.tapir.loop.grainsize.i32(
; CHECK: invoke fastcc void @_Z27parfor_trycatch_destructorsi.outline_pfor.cond.ls1(
; CHECK-NEXT: to label %pfor.cond.cleanup unwind label %lpad50.loopexit

lpad:                                             ; preds = %det.achd
  %2 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %2)
          to label %unreachable unwind label %lpad2

lpad2:                                            ; preds = %entry, %lpad
  %3 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %1, { i8*, i32 } %3)
          to label %unreachable unwind label %lpad9

lpad9:                                            ; preds = %lpad2
  %4 = landingpad { i8*, i32 }
          cleanup
  %5 = extractvalue { i8*, i32 } %4, 0
  %6 = extractvalue { i8*, i32 } %4, 1
  br label %ehcleanup163

pfor.cond:                                        ; preds = %det.cont, %pfor.inc
  %__begin.0 = phi i32 [ %inc, %pfor.inc ], [ 0, %det.cont ]
  detach within %syncreg12, label %pfor.body, label %pfor.inc unwind label %lpad50.loopexit

pfor.body:                                        ; preds = %pfor.cond
  %b2 = alloca %class.Bar, align 1
  %syncreg19 = call token @llvm.syncregion.start()
  %7 = getelementptr inbounds %class.Bar, %class.Bar* %b2, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %7) #6
  invoke void @_ZN3BarC1Ev(%class.Bar* nonnull %b2)
          to label %invoke.cont18 unwind label %lpad15

invoke.cont18:                                    ; preds = %pfor.body
  %8 = call token @llvm.taskframe.create()
  detach within %syncreg19, label %det.achd20, label %det.cont33 unwind label %lpad30

det.achd20:                                       ; preds = %invoke.cont18
  call void @llvm.taskframe.use(token %8)
  invoke void @_Z3fooi(i32 2)
          to label %invoke.cont24 unwind label %lpad21

invoke.cont24:                                    ; preds = %det.achd20
  reattach within %syncreg19, label %det.cont33

det.cont33:                                       ; preds = %invoke.cont18, %invoke.cont24
  call void @_Z9nothrowfni(i32 3) #6
  sync within %syncreg19, label %sync.continue

sync.continue:                                    ; preds = %det.cont33
  call void @_ZN3BarD1Ev(%class.Bar* nonnull %b2) #6
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %7) #6
  br label %pfor.preattach

lpad15:                                           ; preds = %pfor.body
  %9 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %10 = extractvalue { i8*, i32 } %9, 0
  %11 = extractvalue { i8*, i32 } %9, 1
  br label %ehcleanup41

lpad21:                                           ; preds = %det.achd20
  %12 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg19, { i8*, i32 } %12)
          to label %unreachable unwind label %lpad30

lpad30:                                           ; preds = %invoke.cont18, %lpad21
  %13 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %8, { i8*, i32 } %13)
          to label %unreachable unwind label %lpad39

lpad39:                                           ; preds = %lpad30
  %14 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %15 = extractvalue { i8*, i32 } %14, 0
  %16 = extractvalue { i8*, i32 } %14, 1
  call void @_ZN3BarD1Ev(%class.Bar* nonnull %b2) #6
  br label %ehcleanup41

ehcleanup41:                                      ; preds = %lpad39, %lpad15
  %exn.slot16.0 = phi i8* [ %15, %lpad39 ], [ %10, %lpad15 ]
  %ehselector.slot17.0 = phi i32 [ %16, %lpad39 ], [ %11, %lpad15 ]
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %7) #6
  %17 = call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #6
  %matches = icmp eq i32 %ehselector.slot17.0, %17
  br i1 %matches, label %catch, label %ehcleanup44

catch:                                            ; preds = %ehcleanup41
  %18 = call i8* @__cxa_begin_catch(i8* %exn.slot16.0) #6
  %19 = bitcast i8* %18 to i32*
  %20 = load i32, i32* %19, align 4, !tbaa !2
  call void @_Z9catchfn_iii(i32 1, i32 %20) #6
  call void @__cxa_end_catch() #6
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %sync.continue, %catch
  reattach within %syncreg12, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.cond, %pfor.preattach
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond210 = icmp eq i32 %inc, %a
  br i1 %exitcond210, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !12

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg12, label %cleanup

ehcleanup44:                                      ; preds = %ehcleanup41
  %lpad.val48 = insertvalue { i8*, i32 } undef, i8* %exn.slot16.0, 0
  %lpad.val49 = insertvalue { i8*, i32 } %lpad.val48, i32 %ehselector.slot17.0, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg12, { i8*, i32 } %lpad.val49)
          to label %unreachable unwind label %lpad50.loopexit.split-lp

lpad50.loopexit:                                  ; preds = %pfor.cond
  %lpad.loopexit205 = landingpad { i8*, i32 }
          cleanup
  br label %lpad50

lpad50.loopexit.split-lp:                         ; preds = %ehcleanup44
  %lpad.loopexit.split-lp206 = landingpad { i8*, i32 }
          cleanup
  br label %lpad50

lpad50:                                           ; preds = %lpad50.loopexit.split-lp, %lpad50.loopexit
  %lpad.phi207 = phi { i8*, i32 } [ %lpad.loopexit205, %lpad50.loopexit ], [ %lpad.loopexit.split-lp206, %lpad50.loopexit.split-lp ]
  %21 = extractvalue { i8*, i32 } %lpad.phi207, 0
  %22 = extractvalue { i8*, i32 } %lpad.phi207, 1
  br label %ehcleanup163

cleanup:                                          ; preds = %pfor.cond.cleanup
  br i1 %cmp, label %pfor.cond70, label %cleanup130
; CHECK: cleanup:
; CHECK: br i1 %cmp, label %[[PREHEADER2:.+]], label %cleanup130

; CHECK: [[PREHEADER2]]:
; CHECK: call i32 @llvm.tapir.loop.grainsize.i32(
; CHECK: invoke fastcc void @_Z27parfor_trycatch_destructorsi.outline_pfor.cond70.ls1(
; CHECK-NEXT: to label %pfor.cond.cleanup123 unwind label %lpad119.loopexit

pfor.cond70:                                      ; preds = %cleanup, %pfor.inc120
  %__begin64.0 = phi i32 [ %inc121, %pfor.inc120 ], [ 0, %cleanup ]
  detach within %syncreg58, label %pfor.body76, label %pfor.inc120 unwind label %lpad119.loopexit

pfor.body76:                                      ; preds = %pfor.cond70
  %b3 = alloca %class.Bar, align 1
  %syncreg81 = call token @llvm.syncregion.start()
  %23 = getelementptr inbounds %class.Bar, %class.Bar* %b3, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %23) #6
  invoke void @_ZN3BarC1Ev(%class.Bar* nonnull %b3)
          to label %invoke.cont80 unwind label %lpad77

invoke.cont80:                                    ; preds = %pfor.body76
  %24 = call token @llvm.taskframe.create()
  detach within %syncreg81, label %det.achd82, label %det.cont95 unwind label %lpad92

det.achd82:                                       ; preds = %invoke.cont80
  call void @llvm.taskframe.use(token %24)
  invoke void @_Z3fooi(i32 4)
          to label %invoke.cont86 unwind label %lpad83

invoke.cont86:                                    ; preds = %det.achd82
  reattach within %syncreg81, label %det.cont95

det.cont95:                                       ; preds = %invoke.cont80, %invoke.cont86
  call void @_Z9nothrowfni(i32 5) #6
  sync within %syncreg81, label %sync.continue102

sync.continue102:                                 ; preds = %det.cont95
  call void @_ZN3BarD1Ev(%class.Bar* nonnull %b3) #6
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %23) #6
  br label %pfor.preattach112

lpad77:                                           ; preds = %pfor.body76
  %25 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %26 = extractvalue { i8*, i32 } %25, 0
  %27 = extractvalue { i8*, i32 } %25, 1
  br label %ehcleanup104

lpad83:                                           ; preds = %det.achd82
  %28 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg81, { i8*, i32 } %28)
          to label %unreachable unwind label %lpad92

lpad92:                                           ; preds = %invoke.cont80, %lpad83
  %29 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %24, { i8*, i32 } %29)
          to label %unreachable unwind label %lpad101

lpad101:                                          ; preds = %lpad92
  %30 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %31 = extractvalue { i8*, i32 } %30, 0
  %32 = extractvalue { i8*, i32 } %30, 1
  call void @_ZN3BarD1Ev(%class.Bar* nonnull %b3) #6
  br label %ehcleanup104

ehcleanup104:                                     ; preds = %lpad101, %lpad77
  %ehselector.slot79.0 = phi i32 [ %32, %lpad101 ], [ %27, %lpad77 ]
  %exn.slot78.0 = phi i8* [ %31, %lpad101 ], [ %26, %lpad77 ]
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %23) #6
  %33 = call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #6
  %matches107 = icmp eq i32 %ehselector.slot79.0, %33
  br i1 %matches107, label %catch108, label %ehcleanup113

catch108:                                         ; preds = %ehcleanup104
  %34 = call i8* @__cxa_begin_catch(i8* %exn.slot78.0) #6
  %35 = bitcast i8* %34 to i32*
  %36 = load i32, i32* %35, align 4, !tbaa !2
  call void @_Z9catchfn_iii(i32 2, i32 %36) #6
  call void @__cxa_end_catch() #6
  br label %pfor.preattach112

pfor.preattach112:                                ; preds = %sync.continue102, %catch108
  reattach within %syncreg58, label %pfor.inc120

pfor.inc120:                                      ; preds = %pfor.cond70, %pfor.preattach112
  %inc121 = add nuw nsw i32 %__begin64.0, 1
  %exitcond = icmp eq i32 %inc121, %a
  br i1 %exitcond, label %pfor.cond.cleanup123, label %pfor.cond70, !llvm.loop !13

pfor.cond.cleanup123:                             ; preds = %pfor.inc120
  sync within %syncreg58, label %cleanup130

ehcleanup113:                                     ; preds = %ehcleanup104
  %lpad.val117 = insertvalue { i8*, i32 } undef, i8* %exn.slot78.0, 0
  %lpad.val118 = insertvalue { i8*, i32 } %lpad.val117, i32 %ehselector.slot79.0, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg58, { i8*, i32 } %lpad.val118)
          to label %unreachable unwind label %lpad119.loopexit.split-lp

lpad119.loopexit:                                 ; preds = %pfor.cond70
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  br label %lpad119

lpad119.loopexit.split-lp:                        ; preds = %ehcleanup113
  %lpad.loopexit.split-lp = landingpad { i8*, i32 }
          cleanup
  br label %lpad119

lpad119:                                          ; preds = %lpad119.loopexit.split-lp, %lpad119.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad119.loopexit ], [ %lpad.loopexit.split-lp, %lpad119.loopexit.split-lp ]
  %37 = extractvalue { i8*, i32 } %lpad.phi, 0
  %38 = extractvalue { i8*, i32 } %lpad.phi, 1
  br label %ehcleanup163

cleanup130:                                       ; preds = %det.cont, %pfor.cond.cleanup123, %cleanup
  %39 = getelementptr inbounds %class.Bar, %class.Bar* %b4, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %39) #6
  invoke void @_ZN3BarC1Ev(%class.Bar* nonnull %b4)
          to label %invoke.cont136 unwind label %lpad135

invoke.cont136:                                   ; preds = %cleanup130
  %40 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd137, label %det.cont150 unwind label %lpad147

det.achd137:                                      ; preds = %invoke.cont136
  call void @llvm.taskframe.use(token %40)
  invoke void @_Z3fooi(i32 6)
          to label %invoke.cont141 unwind label %lpad138

invoke.cont141:                                   ; preds = %det.achd137
  reattach within %syncreg, label %det.cont150

det.cont150:                                      ; preds = %invoke.cont136, %invoke.cont141
  call void @_Z9nothrowfni(i32 7) #6
  sync within %syncreg, label %sync.continue158

lpad135:                                          ; preds = %cleanup130
  %41 = landingpad { i8*, i32 }
          cleanup
  %42 = extractvalue { i8*, i32 } %41, 0
  %43 = extractvalue { i8*, i32 } %41, 1
  br label %ehcleanup161

lpad138:                                          ; preds = %det.achd137
  %44 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %44)
          to label %unreachable unwind label %lpad147

lpad147:                                          ; preds = %invoke.cont136, %lpad138
  %45 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %40, { i8*, i32 } %45)
          to label %unreachable unwind label %lpad156

lpad156:                                          ; preds = %lpad147
  %46 = landingpad { i8*, i32 }
          cleanup
  %47 = extractvalue { i8*, i32 } %46, 0
  %48 = extractvalue { i8*, i32 } %46, 1
  call void @_ZN3BarD1Ev(%class.Bar* nonnull %b4) #6
  br label %ehcleanup161

sync.continue158:                                 ; preds = %det.cont150
  call void @_ZN3BarD1Ev(%class.Bar* nonnull %b4) #6
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %39) #6
  call void @_ZN3BarD1Ev(%class.Bar* nonnull %b1) #6
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %0) #6
  ret i32 0

ehcleanup161:                                     ; preds = %lpad156, %lpad135
  %ehselector.slot11.0 = phi i32 [ %48, %lpad156 ], [ %43, %lpad135 ]
  %exn.slot10.0 = phi i8* [ %47, %lpad156 ], [ %42, %lpad135 ]
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %39) #6
  br label %ehcleanup163

ehcleanup163:                                     ; preds = %ehcleanup161, %lpad119, %lpad50, %lpad9
  %ehselector.slot11.1 = phi i32 [ %ehselector.slot11.0, %ehcleanup161 ], [ %38, %lpad119 ], [ %22, %lpad50 ], [ %6, %lpad9 ]
  %exn.slot10.1 = phi i8* [ %exn.slot10.0, %ehcleanup161 ], [ %37, %lpad119 ], [ %21, %lpad50 ], [ %5, %lpad9 ]
  call void @_ZN3BarD1Ev(%class.Bar* nonnull %b1) #6
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %0) #6
  %lpad.val168 = insertvalue { i8*, i32 } undef, i8* %exn.slot10.1, 0
  %lpad.val169 = insertvalue { i8*, i32 } %lpad.val168, i32 %ehselector.slot11.1, 1
  resume { i8*, i32 } %lpad.val169

unreachable:                                      ; preds = %lpad30, %lpad21, %lpad92, %lpad83, %lpad147, %lpad138, %ehcleanup113, %ehcleanup44, %lpad2, %lpad
  unreachable
}

; Function Attrs: nounwind
declare void @llvm.assume(i1) #6

; Function Attrs: nounwind readnone speculatable
declare i32 @llvm.tapir.loop.grainsize.i32(i32) #7

; CHECK-LABEL: define private fastcc void @_Z15parfor_trycatchi.outline_pfor.cond48.ls1(
; CHECK: %[[SYNCREG:.+]] = tail call token @llvm.syncregion.start()
; CHECK: %[[DACSYNCREG:.+]] = tail call token @llvm.syncregion.start()

; CHECK: detach within %[[DACSYNCREG]], label %[[DACSPAWN:.+]], label %[[DACCONT:.+]]

; CHECK: [[DACSPAWN]]:
; CHECK: call fastcc void @_Z15parfor_trycatchi.outline_pfor.cond48.ls1(
; CHECK-NEXT: reattach within %[[DACSYNCREG]], label %[[DACCONT]]

; CHECK: pfor.body54.ls1:
; CHECK-NEXT: %[[TASKFRAME:.+]] = tail call token @llvm.taskframe.create()
; CHECK: detach within %[[SYNCREG]], label %det.achd56.ls1, label %det.cont69.ls1 unwind label %lpad66.ls1

; CHECK: lpad66.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
; CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %lpad75.ls1

; CHECK: lpad75.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: tail call void @_Z9catchfn_iii(i32 2,

; CHECK: det.achd56.ls1:
; CHECK-NEXT: tail call void @llvm.taskframe.use(token %[[TASKFRAME]])
; CHECK-NEXT: invoke void @_Z3fooi(i32 4)
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %lpad57.ls1

; CHECK: lpad57.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
; CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %lpad66.ls1

; CHECK: [[INVOKECONT]]:
; CHECK-NEXT: reattach within %[[SYNCREG]]

; CHECK: [[UNREACHABLE]]:
; CHECK-NEXT: unreachable


; CHECK-LABEL: define private fastcc void @_Z15parfor_trycatchi.outline_pfor.cond.ls1(
; CHECK: %[[SYNCREG:.+]] = tail call token @llvm.syncregion.start()
; CHECK: %[[DACSYNCREG:.+]] = tail call token @llvm.syncregion.start()

; CHECK: detach within %[[DACSYNCREG]], label %[[DACSPAWN:.+]], label %[[DACCONT:.+]]

; CHECK: [[DACSPAWN]]:
; CHECK: call fastcc void @_Z15parfor_trycatchi.outline_pfor.cond.ls1(
; CHECK-NEXT: reattach within %[[DACSYNCREG]], label %[[DACCONT]]

; CHECK: pfor.body.ls1:
; CHECK-NEXT: %[[TASKFRAME:.+]] = tail call token @llvm.taskframe.create()
; CHECK: detach within %[[SYNCREG]], label %det.achd5.ls1, label %det.cont10.ls1 unwind label %lpad7.ls1

; CHECK: lpad7.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
; CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %lpad15.ls1

; CHECK: lpad15.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: tail call void @_Z9catchfn_iii(i32 1,

; CHECK: det.achd5.ls1:
; CHECK-NEXT: tail call void @llvm.taskframe.use(token %[[TASKFRAME]])
; CHECK-NEXT: invoke void @_Z3fooi(i32 2)
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %lpad.ls1

; CHECK: lpad.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
; CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %lpad7.ls1

; CHECK: [[INVOKECONT]]:
; CHECK-NEXT: reattach within %[[SYNCREG]]

; CHECK: [[UNREACHABLE]]:
; CHECK-NEXT: unreachable


; CHECK-LABEL: define private fastcc void @_Z27parfor_trycatch_destructorsi.outline_pfor.cond70.ls1(
; CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
; CHECK: %[[DACSYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()

; CHECK: detach within %[[DACSYNCREG]], label %[[DACSPAWN:.+]], label %[[DACCONT:.+]] unwind label %[[DACDU:.+]]

; CHECK: [[DACSPAWN]]:
; CHECK-NEXT: invoke fastcc void @_Z27parfor_trycatch_destructorsi.outline_pfor.cond70.ls1(
; CHECK-NEXT: to label %[[DACINVOKECONT:.+]] unwind label %[[DACLPAD:.+]]

; CHECK: [[DACINVOKECONT]]:
; CHECK-NEXT: reattach within %[[DACSYNCREG]], label %[[DACCONT]]

; CHECK: pfor.body76.ls1:
; CHECK: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[B3PTR:.+]])
; CHECK-NEXT: invoke void @_ZN3BarC1Ev(%class.Bar* nonnull %[[B3:.+]])
; CHECK-NEXT: to label %[[B3CONSTRCONT:.+]] unwind label %lpad77.ls1

; CHECK: lpad77.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: br label %ehcleanup104.ls1

; CHECK: [[B3CONSTRCONT]]:
; CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %[[SYNCREG]], label %det.achd82.ls1, label %det.cont95.ls1 unwind label %lpad92.ls1

; CHECK: ehcleanup104.ls1:
; CHECK: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[B3PTR]])

; CHECK: det.cont95.ls1:
; CHECK-NEXT: call void @_Z9nothrowfni(i32 5)
; CHECK-NEXT: sync within %[[SYNCREG]], label %sync.continue102.ls1

; CHECK: sync.continue102.ls1:
; CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* nonnull %[[B3]])
; CHECK-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[B3PTR]])

; CHECK: lpad92.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
; CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %lpad101.ls1

; CHECK: lpad101.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: br label %ehcleanup104.ls1

; CHECK: det.achd82.ls1:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
; CHECK-NEXT: invoke void @_Z3fooi(i32 4)
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %lpad83.ls1

; CHECK: lpad83.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
; CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %lpad92.ls1

; CHECK: [[INVOKECONT]]:
; CHECK-NEXT: reattach within %[[SYNCREG]], label %det.cont95.ls1

; CHECK: [[DACDU]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup

; CHECK: [[UNREACHABLE]]:
; CHECK-NEXT: unreachable

; CHECK: [[DACLPAD]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[DACSYNCREG]],
; CHECK-NEXT: to label %[[UNREACHABLE2:.+]] unwind label


; CHECK-LABEL: define private fastcc void @_Z27parfor_trycatch_destructorsi.outline_pfor.cond.ls1(
; CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
; CHECK: %[[DACSYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()

; CHECK: detach within %[[DACSYNCREG]], label %[[DACSPAWN:.+]], label %[[DACCONT:.+]] unwind label %[[DACDU:.+]]

; CHECK: [[DACSPAWN]]:
; CHECK-NEXT: invoke fastcc void @_Z27parfor_trycatch_destructorsi.outline_pfor.cond.ls1(
; CHECK-NEXT: to label %[[DACINVOKECONT:.+]] unwind label %[[DACLPAD:.+]]

; CHECK: [[DACINVOKECONT]]:
; CHECK-NEXT: reattach within %[[DACSYNCREG]], label %[[DACCONT]]

; CHECK: pfor.body.ls1:
; CHECK: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[B2PTR:.+]])
; CHECK-NEXT: invoke void @_ZN3BarC1Ev(%class.Bar* nonnull %[[B2:.+]])
; CHECK-NEXT: to label %[[B2CONSTRCONT:.+]] unwind label %lpad15.ls1

; CHECK: lpad15.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: br label %ehcleanup41.ls1

; CHECK: [[B2CONSTRCONT]]:
; CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: detach within %[[SYNCREG]], label %det.achd20.ls1, label %det.cont33.ls1 unwind label %lpad30.ls1

; CHECK: ehcleanup41.ls1:
; CHECK: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[B2PTR]])

; CHECK: det.cont33.ls1:
; CHECK-NEXT: call void @_Z9nothrowfni(i32 3)
; CHECK-NEXT: sync within %[[SYNCREG]], label %sync.continue.ls1

; CHECK: sync.continue.ls1:
; CHECK-NEXT: call void @_ZN3BarD1Ev(%class.Bar* nonnull %[[B2]])
; CHECK-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[B2PTR]])

; CHECK: lpad30.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]],
; CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %lpad39.ls1

; CHECK: lpad39.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: br label %ehcleanup41.ls1

; CHECK: det.achd20.ls1:
; CHECK-NEXT: call void @llvm.taskframe.use(token %[[TASKFRAME]])
; CHECK-NEXT: invoke void @_Z3fooi(i32 2)
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %lpad21.ls1

; CHECK: lpad21.ls1:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[SYNCREG]],
; CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %lpad30.ls1

; CHECK: [[INVOKECONT]]:
; CHECK-NEXT: reattach within %[[SYNCREG]], label %det.cont33.ls1

; CHECK: [[DACDU]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup

; CHECK: [[UNREACHABLE]]:
; CHECK-NEXT: unreachable

; CHECK: [[DACLPAD]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %[[DACSYNCREG]],
; CHECK-NEXT: to label %[[UNREACHABLE2:.+]] unwind label

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { argmemonly nounwind }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { argmemonly }
attributes #6 = { nounwind }
attributes #7 = { noreturn }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git b6ce6eb1070ae2e02b016c746738c14b19c8e746)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!4, !4, i64 0}
!7 = distinct !{!7, !8}
!8 = !{!"tapir.loop.spawn.strategy", i32 1}
!9 = distinct !{!9, !8}
!10 = distinct !{!10, !8}
!11 = distinct !{!11, !8}
!12 = distinct !{!12, !8}
!13 = distinct !{!13, !8}
