; RUN: opt < %s -loop-spawning-ti -S | FileCheck %s --check-prefixes=CHECK,CHECK-LCSSA
; RUN: opt < %s -passes=loop-spawning -S | FileCheck %s --check-prefixes=CHECK,CHECK-NOLCSSA

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Foo = type { i8 }

$_ZN3FooC2Ev = comdat any

$__clang_call_terminate = comdat any

$_ZN3FooD2Ev = comdat any

@_ZTIi = external dso_local constant i8*

; Function Attrs: alwaysinline uwtable
define dso_local i32 @_Z3fooP3Foo(%class.Foo* %f) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %call = invoke i32 @_Z3barP3Foo(%class.Foo* %f)
          to label %try.cont unwind label %lpad

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %1 = extractvalue { i8*, i32 } %0, 0
  %2 = extractvalue { i8*, i32 } %0, 1
  %3 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #10
  %matches = icmp eq i32 %2, %3
  br i1 %matches, label %catch, label %eh.resume

catch:                                            ; preds = %lpad
  %4 = tail call i8* @__cxa_begin_catch(i8* %1) #10
  %5 = bitcast i8* %4 to i32*
  %6 = load i32, i32* %5, align 4, !tbaa !2
  invoke void @_Z10handle_exni(i32 %6)
          to label %invoke.cont2 unwind label %lpad1

invoke.cont2:                                     ; preds = %catch
  tail call void @__cxa_end_catch() #10
  br label %try.cont

try.cont:                                         ; preds = %entry, %invoke.cont2
  ret i32 0

lpad1:                                            ; preds = %catch
  %7 = landingpad { i8*, i32 }
          cleanup
  %8 = extractvalue { i8*, i32 } %7, 0
  %9 = extractvalue { i8*, i32 } %7, 1
  tail call void @__cxa_end_catch() #10
  br label %eh.resume

eh.resume:                                        ; preds = %lpad1, %lpad
  %ehselector.slot.0 = phi i32 [ %9, %lpad1 ], [ %2, %lpad ]
  %exn.slot.0 = phi i8* [ %8, %lpad1 ], [ %1, %lpad ]
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.0, 0
  %lpad.val5 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.0, 1
  resume { i8*, i32 } %lpad.val5
}

declare dso_local i32 @_Z3barP3Foo(%class.Foo*) local_unnamed_addr #1

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind readnone
declare i32 @llvm.eh.typeid.for(i8*) #2

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_Z10handle_exni(i32) local_unnamed_addr #1

declare dso_local void @__cxa_end_catch() local_unnamed_addr

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: nounwind
declare dso_local i32 @_Z4quuzi(i32) local_unnamed_addr #5

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #7

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN3FooC2Ev(%class.Foo* %this) unnamed_addr #4 comdat align 2 {
entry:
  ret void
}

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8*) local_unnamed_addr #8 comdat {
  %2 = tail call i8* @__cxa_begin_catch(i8* %0) #10
  tail call void @_ZSt9terminatev() #12
  unreachable
}

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: nounwind uwtable
define dso_local void @_Z20parallelfor_noexcepti(i32 %n) local_unnamed_addr #4 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond, label %cleanup

pfor.cond:                                        ; preds = %entry, %pfor.inc
  %__begin.0 = phi i32 [ %inc, %pfor.inc ], [ 0, %entry ]
  detach within %syncreg, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %call = tail call i32 @_Z4quuzi(i32 %__begin.0) #10
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %entry
  ret void
}

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #3

; Function Attrs: uwtable
define dso_local void @_Z19parallelfor_nocatchi(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z19parallelfor_nocatchi(i32 %n)
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond, label %cleanup
; CHECK: call fastcc void @_Z19parallelfor_nocatchi.outline_pfor.cond.ls1(i32 0, i32 %n, i32
; CHECK-NEXT: br label %pfor.cond.cleanup

pfor.cond:                                        ; preds = %entry, %pfor.inc
  %__begin.0 = phi i32 [ %inc, %pfor.inc ], [ 0, %entry ]
  detach within %syncreg, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %call = tail call i8* @_Znwm(i64 1) #11
  %0 = bitcast i8* %call to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %0)
  %call3 = tail call i32 @_Z3barP3Foo(%class.Foo* nonnull %0)
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.cond, %pfor.body
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !8

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %entry
  ret void
}

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #9

; Function Attrs: uwtable
define dso_local void @_Z20parallelfor_tryblocki(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z20parallelfor_tryblocki(i32 %n)
entry:
  %syncreg5 = tail call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond, label %try.cont
; CHECK: call fastcc void @_Z20parallelfor_tryblocki.outline_pfor.cond.ls1(i32 0, i32 %n, i32

pfor.cond:                                        ; preds = %entry, %pfor.inc
  %__begin.0 = phi i32 [ %inc, %pfor.inc ], [ 0, %entry ]
  detach within %syncreg5, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %call = tail call i32 @_Z4quuzi(i32 %__begin.0) #10
  reattach within %syncreg5, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond95 = icmp eq i32 %inc, %n
  br i1 %exitcond95, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !9

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg5, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup
  br i1 %cmp, label %pfor.cond17, label %try.cont
; CHECK: invoke fastcc void @_Z20parallelfor_tryblocki.outline_pfor.cond17.ls1(i32 0, i32 %n, i32
; CHECK-NEXT: to label %{{.+}} unwind label %lpad32.loopexit

pfor.cond17:                                      ; preds = %cleanup, %pfor.inc35
  %__begin11.0 = phi i32 [ %inc36, %pfor.inc35 ], [ 0, %cleanup ]
  detach within %syncreg5, label %pfor.body23, label %pfor.inc35 unwind label %lpad32.loopexit

pfor.body23:                                      ; preds = %pfor.cond17
  %call24 = invoke i8* @_Znwm(i64 1) #11
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %pfor.body23
  %0 = bitcast i8* %call24 to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %0)
  %call28 = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %0)
          to label %pfor.preattach29 unwind label %lpad

pfor.preattach29:                                 ; preds = %invoke.cont
  reattach within %syncreg5, label %pfor.inc35

pfor.inc35:                                       ; preds = %pfor.cond17, %pfor.preattach29
  %inc36 = add nuw nsw i32 %__begin11.0, 1
  %exitcond = icmp eq i32 %inc36, %n
  br i1 %exitcond, label %pfor.cond.cleanup38, label %pfor.cond17, !llvm.loop !10

pfor.cond.cleanup38:                              ; preds = %pfor.inc35
  sync within %syncreg5, label %try.cont

lpad:                                             ; preds = %invoke.cont, %pfor.body23
  %1 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg5, { i8*, i32 } %1)
          to label %unreachable unwind label %lpad32.loopexit.split-lp

lpad32.loopexit:                                  ; preds = %pfor.cond17
  %lpad.loopexit = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
          catch i8* null
  br label %lpad32

lpad32.loopexit.split-lp:                         ; preds = %lpad
  %lpad.loopexit.split-lp = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
          catch i8* null
  br label %lpad32

lpad32:                                           ; preds = %lpad32.loopexit.split-lp, %lpad32.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad32.loopexit ], [ %lpad.loopexit.split-lp, %lpad32.loopexit.split-lp ]
  %2 = extractvalue { i8*, i32 } %lpad.phi, 0
  %3 = extractvalue { i8*, i32 } %lpad.phi, 1
  %4 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #10
  %matches = icmp eq i32 %3, %4
  %5 = tail call i8* @__cxa_begin_catch(i8* %2) #10
  br i1 %matches, label %catch56, label %catch

catch56:                                          ; preds = %lpad32
  %6 = bitcast i8* %5 to i32*
  %7 = load i32, i32* %6, align 4, !tbaa !2
  invoke void @_Z10handle_exni(i32 %7)
          to label %invoke.cont59 unwind label %lpad58

invoke.cont59:                                    ; preds = %catch56
  tail call void @__cxa_end_catch() #10
  br label %try.cont

try.cont:                                         ; preds = %entry, %cleanup, %pfor.cond.cleanup38, %invoke.cont59, %invoke.cont53
  ret void

catch:                                            ; preds = %lpad32
  invoke void @_Z10handle_exni(i32 -1)
          to label %invoke.cont53 unwind label %lpad52

invoke.cont53:                                    ; preds = %catch
  tail call void @__cxa_end_catch()
  br label %try.cont

lpad52:                                           ; preds = %catch
  %8 = landingpad { i8*, i32 }
          cleanup
  %9 = extractvalue { i8*, i32 } %8, 0
  %10 = extractvalue { i8*, i32 } %8, 1
  invoke void @__cxa_end_catch()
          to label %eh.resume unwind label %terminate.lpad

lpad58:                                           ; preds = %catch56
  %11 = landingpad { i8*, i32 }
          cleanup
  %12 = extractvalue { i8*, i32 } %11, 0
  %13 = extractvalue { i8*, i32 } %11, 1
  tail call void @__cxa_end_catch() #10
  br label %eh.resume

eh.resume:                                        ; preds = %lpad52, %lpad58
  %ehselector.slot34.0 = phi i32 [ %13, %lpad58 ], [ %10, %lpad52 ]
  %exn.slot33.0 = phi i8* [ %12, %lpad58 ], [ %9, %lpad52 ]
  %lpad.val64 = insertvalue { i8*, i32 } undef, i8* %exn.slot33.0, 0
  %lpad.val65 = insertvalue { i8*, i32 } %lpad.val64, i32 %ehselector.slot34.0, 1
  resume { i8*, i32 } %lpad.val65

terminate.lpad:                                   ; preds = %lpad52
  %14 = landingpad { i8*, i32 }
          catch i8* null
  %15 = extractvalue { i8*, i32 } %14, 0
  tail call void @__clang_call_terminate(i8* %15) #12
  unreachable

unreachable:                                      ; preds = %lpad
  unreachable
}

; Function Attrs: uwtable
define dso_local void @_Z27parallelfor_tryblock_inlinei(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @_Z27parallelfor_tryblock_inlinei(i32 %n)
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %pfor.cond, label %try.cont
; CHECK: invoke fastcc void @_Z27parallelfor_tryblock_inlinei.outline_pfor.cond.ls1(i32 0, i32 %n, i32
; CHECK-NEXT: to label %{{.+}} unwind label %lpad9.loopexit

pfor.cond:                                        ; preds = %entry, %pfor.inc
  %__begin.0 = phi i32 [ %inc, %pfor.inc ], [ 0, %entry ]
  detach within %syncreg, label %pfor.body, label %pfor.inc unwind label %lpad9.loopexit

pfor.body:                                        ; preds = %pfor.cond
  %call = invoke i8* @_Znwm(i64 1) #11
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %pfor.body
  %0 = bitcast i8* %call to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %0)
  %call.i = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %0)
          to label %pfor.preattach unwind label %lpad.i

lpad.i:                                           ; preds = %invoke.cont
  %1 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %2 = extractvalue { i8*, i32 } %1, 0
  %3 = extractvalue { i8*, i32 } %1, 1
  %4 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #10
  %matches.i = icmp eq i32 %3, %4
  br i1 %matches.i, label %catch.i, label %eh.resume.i

catch.i:                                          ; preds = %lpad.i
  %5 = tail call i8* @__cxa_begin_catch(i8* %2) #10
  %6 = bitcast i8* %5 to i32*
  %7 = load i32, i32* %6, align 4, !tbaa !2
  invoke void @_Z10handle_exni(i32 %7)
          to label %invoke.cont2.i unwind label %lpad1.i

invoke.cont2.i:                                   ; preds = %catch.i
  tail call void @__cxa_end_catch() #10
  br label %pfor.preattach

lpad1.i:                                          ; preds = %catch.i
  %8 = landingpad { i8*, i32 }
          cleanup
  %9 = extractvalue { i8*, i32 } %8, 0
  %10 = extractvalue { i8*, i32 } %8, 1
  tail call void @__cxa_end_catch() #10
  br label %eh.resume.i

eh.resume.i:                                      ; preds = %lpad.i, %lpad1.i
  %ehselector.slot.0.i = phi i32 [ %10, %lpad1.i ], [ %3, %lpad.i ]
  %exn.slot.0.i = phi i8* [ %9, %lpad1.i ], [ %2, %lpad.i ]
  %lpad.val.i = insertvalue { i8*, i32 } undef, i8* %exn.slot.0.i, 0
  %lpad.val5.i = insertvalue { i8*, i32 } %lpad.val.i, i32 %ehselector.slot.0.i, 1
  br label %lpad.body

pfor.preattach:                                   ; preds = %invoke.cont2.i, %invoke.cont
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.cond, %pfor.preattach
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !11

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %try.cont

lpad:                                             ; preds = %pfor.body
  %11 = landingpad { i8*, i32 }
          cleanup
  br label %lpad.body

lpad.body:                                        ; preds = %eh.resume.i, %lpad
  %eh.lpad-body = phi { i8*, i32 } [ %11, %lpad ], [ %lpad.val5.i, %eh.resume.i ]
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %eh.lpad-body)
          to label %unreachable unwind label %lpad9.loopexit.split-lp

lpad9.loopexit:                                   ; preds = %pfor.cond
  %lpad.loopexit = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
          catch i8* null
  br label %lpad9

lpad9.loopexit.split-lp:                          ; preds = %lpad.body
  %lpad.loopexit.split-lp = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
          catch i8* null
  br label %lpad9

lpad9:                                            ; preds = %lpad9.loopexit.split-lp, %lpad9.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad9.loopexit ], [ %lpad.loopexit.split-lp, %lpad9.loopexit.split-lp ]
  %12 = extractvalue { i8*, i32 } %lpad.phi, 0
  %13 = extractvalue { i8*, i32 } %lpad.phi, 1
  %14 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #10
  %matches = icmp eq i32 %13, %14
  %15 = tail call i8* @__cxa_begin_catch(i8* %12) #10
  br i1 %matches, label %catch24, label %catch

catch24:                                          ; preds = %lpad9
  %16 = bitcast i8* %15 to i32*
  %17 = load i32, i32* %16, align 4, !tbaa !2
  invoke void @_Z10handle_exni(i32 %17)
          to label %invoke.cont27 unwind label %lpad26

invoke.cont27:                                    ; preds = %catch24
  tail call void @__cxa_end_catch() #10
  br label %try.cont

try.cont:                                         ; preds = %entry, %pfor.cond.cleanup, %invoke.cont27, %invoke.cont21
  ret void

catch:                                            ; preds = %lpad9
  invoke void @_Z10handle_exni(i32 -1)
          to label %invoke.cont21 unwind label %lpad20

invoke.cont21:                                    ; preds = %catch
  tail call void @__cxa_end_catch()
  br label %try.cont

lpad20:                                           ; preds = %catch
  %18 = landingpad { i8*, i32 }
          cleanup
  %19 = extractvalue { i8*, i32 } %18, 0
  %20 = extractvalue { i8*, i32 } %18, 1
  invoke void @__cxa_end_catch()
          to label %eh.resume unwind label %terminate.lpad

lpad26:                                           ; preds = %catch24
  %21 = landingpad { i8*, i32 }
          cleanup
  %22 = extractvalue { i8*, i32 } %21, 0
  %23 = extractvalue { i8*, i32 } %21, 1
  tail call void @__cxa_end_catch() #10
  br label %eh.resume

eh.resume:                                        ; preds = %lpad20, %lpad26
  %ehselector.slot11.0 = phi i32 [ %23, %lpad26 ], [ %20, %lpad20 ]
  %exn.slot10.0 = phi i8* [ %22, %lpad26 ], [ %19, %lpad20 ]
  %lpad.val32 = insertvalue { i8*, i32 } undef, i8* %exn.slot10.0, 0
  %lpad.val33 = insertvalue { i8*, i32 } %lpad.val32, i32 %ehselector.slot11.0, 1
  resume { i8*, i32 } %lpad.val33

terminate.lpad:                                   ; preds = %lpad20
  %24 = landingpad { i8*, i32 }
          catch i8* null
  %25 = extractvalue { i8*, i32 } %24, 0
  tail call void @__clang_call_terminate(i8* %25) #12
  unreachable

unreachable:                                      ; preds = %lpad.body
  unreachable
}

; CHECK-LABEL: define private fastcc void @_Z19parallelfor_nocatchi.outline_pfor.cond.ls1(
; CHECK: %[[SYNCREG:.+]] = tail call token @llvm.syncregion.start()
; CHECK: detach within %[[SYNCREG]], label %[[RECURDET:.+]], label %[[RECURCONT:.+]]

; CHECK: [[RECURDET]]:
; CHECK-NEXT: call fastcc void @_Z19parallelfor_nocatchi.outline_pfor.cond.ls1(
; CHECK-NEXT: reattach within %[[SYNCREG]], label %[[RECURCONT]]

; CHECK: {{^pfor.body.ls1}}:
; CHECK-NEXT: %[[NEWRET:.+]] = tail call i8* @_Znwm(i64 1)
; CHECK-NEXT: %[[FOOARG:.+]] = bitcast i8* %[[NEWRET]] to %class.Foo*
; CHECK-NEXT: tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: %[[BARCALL:.+]] = tail call i32 @_Z3barP3Foo(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: br label %pfor.inc.ls1

; CHECK-NOT: invoke
; CHECK-NOT: resume
; CHECK-NOT: detached.rethrow


; CHECK-LABEL: define private fastcc void @_Z20parallelfor_tryblocki.outline_pfor.cond17.ls1(
; CHECK: %[[SYNCREG:.+]] = tail call token @llvm.syncregion.start()
; CHECK: detach within %[[SYNCREG]], label %[[RECURDET:.+]], label %[[RECURCONT:.+]] unwind label %[[RECURUW:.+]]

; CHECK: [[RECURDET]]:
; CHECK-NEXT: invoke fastcc void @_Z20parallelfor_tryblocki.outline_pfor.cond17.ls1(
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[TASKLPAD:.+]]

; CHECK: [[INVOKECONT]]:
; CHECK-NEXT: reattach within %[[SYNCREG]], label %[[RECURCONT]]

; CHECK: {{^pfor.body23.ls1}}:
; CHECK-NEXT: %[[NEWRET:.+]] = invoke i8* @_Znwm(i64 1)
; CHECK-NEXT: to label %invoke.cont.ls1 unwind label %lpad.ls1
; CHECK: {{^lpad.ls1}}:
; CHECK-NEXT: landingpad [[LPADTYPE:.+]]
; CHECK-NEXT: cleanup
; CHECK: resume [[LPADTYPE]] %{{.+}}
; CHECK: {{^invoke.cont.ls1}}:
; CHECK-NEXT: %[[FOOARG:.+]] = bitcast i8* %[[NEWRET]] to %class.Foo*
; CHECK-NEXT: tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: %[[BARCALL:.+]] = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: to label %pfor.preattach29.ls1 unwind label %lpad.ls1

; CHECK: [[RECURUW]]:
; CHECK-NEXT: landingpad [[LPADTYPE]]
; CHECK-NEXT: cleanup
; CHECK: resume [[LPADTYPE]] %{{.+}}

; CHECK: [[TASKLPAD]]:
; CHECK-LCSSA-NEXT: phi
; CHECK-NEXT: landingpad [[LPADTYPE]]
; CHECK: invoke void @llvm.detached.rethrow
; CHECK: (token %[[SYNCREG]], [[LPADTYPE]] %{{.+}})
; CHECK-NEXT: to label %{{.+}} unwind label %[[RECURUW]]


; CHECK-LABEL: define private fastcc void @_Z20parallelfor_tryblocki.outline_pfor.cond.ls1(
; CHECK-NOT: invoke
; CHECK-NOT: resume
; CHECK-NOT: detached.rethrow


; CHECK-LABEL: define private fastcc void @_Z27parallelfor_tryblock_inlinei.outline_pfor.cond.ls1(
; CHECK: %[[SYNCREG:.+]] = tail call token @llvm.syncregion.start()
; CHECK: detach within %[[SYNCREG]], label %[[RECURDET:.+]], label %[[RECURCONT:.+]] unwind label %[[RECURUW:.+]]

; CHECK: [[RECURDET]]:
; CHECK-NEXT: invoke fastcc void @_Z27parallelfor_tryblock_inlinei.outline_pfor.cond.ls1(
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[TASKLPAD:.+]]

; CHECK: [[INVOKECONT]]:
; CHECK-NEXT: reattach within %[[SYNCREG]], label %[[RECURCONT]]

; CHECK: {{^pfor.body.ls1}}:
; CHECK-NEXT: %[[NEWRET:.+]] = invoke i8* @_Znwm(i64 1)
; CHECK-NEXT: to label %invoke.cont.ls1 unwind label %lpad.ls1
; CHECK: {{^lpad.ls1}}:
; CHECK-NEXT: landingpad [[LPADTYPE:.+]]
; CHECK-NEXT: cleanup
; CHECK-NEXT: br label %lpad.body.ls1
; CHECK: {{^lpad.body.ls1}}:
; CHECK: resume [[LPADTYPE]] %{{.+}}
; CHECK: {{^invoke.cont.ls1}}:
; CHECK-NEXT: %[[FOOARG:.+]] = bitcast i8* %[[NEWRET]] to %class.Foo*
; CHECK-NEXT: tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: %call.i.ls1 = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: to label %pfor.preattach.ls1 unwind label %lpad.i.ls1
; CHECK: {{^lpad.i.ls1}}:
; CHECK-NEXT: landingpad [[LPADTYPE]]
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch {{.+}} bitcast
; CHECK-NOLCSSA: br i1 %{{.+}}, label %[[CATCHIN:.+]], label %[[RESUMEIN:.+]]
; CHECK-LCSSA: br i1 %{{.+}}, label %[[CATCHIN:.+]], label %[[RESUME_LOOPEXIT:.+]]
; CHECK-LCSSA: [[RESUME_LOOPEXIT]]:
; CHECK-LCSSA: br label %[[RESUMEIN:.+]]
; CHECK: [[RESUMEIN]]:
; CHECK: br label %lpad.body.ls1
; CHECK: [[CATCHIN]]:
; CHECK: tail call i8* @__cxa_begin_catch(
; CHECK: invoke void @_Z10handle_exni(
; CHECK: br label %[[RESUMEIN]]

; CHECK: [[RECURUW]]:
; CHECK-NEXT: landingpad [[LPADTYPE]]
; CHECK-NEXT: cleanup
; CHECK: resume [[LPADTYPE]] %{{.+}}

; CHECK: [[TASKLPAD]]:
; CHECK-LCSSA-NEXT: phi
; CHECK-NEXT: landingpad [[LPADTYPE]]
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.detached.rethrow
; CHECK: (token %[[SYNCREG]], [[LPADTYPE]] %{{.+}})
; CHECK-NEXT: to label %{{.+}} unwind label %[[RECURUW]]

attributes #0 = { alwaysinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone }
attributes #3 = { argmemonly nounwind }
attributes #4 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { noinline noreturn nounwind }
attributes #9 = { argmemonly }
attributes #10 = { nounwind }
attributes #11 = { builtin }
attributes #12 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git 95a4531f33e1ff8e0b26cf9bc77a83f5da8f2152)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = distinct !{!6, !7}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
