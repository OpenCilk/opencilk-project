; RUN: llc < %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=TAPIRCLEANUP
; RUN: opt < %s -tapir2target -tapir-target=cilk -debug-abi-calls -S | FileCheck %s
; RUN: opt < %s -passes=tapir2target -tapir-target=cilk -debug-abi-calls -S | FileCheck %s

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

; Function Attrs: nounwind uwtable
define dso_local void @_Z15serial_noexcepti(i32 %n) local_unnamed_addr #4 {
entry:
  %call = tail call i32 @_Z4quuzi(i32 %n) #10
  %call1 = tail call i32 @_Z4quuzi(i32 %n) #10
  ret void
}

; Function Attrs: nounwind
declare dso_local i32 @_Z4quuzi(i32) local_unnamed_addr #5

; Function Attrs: uwtable
define dso_local void @_Z13serial_excepti(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %call = tail call i8* @_Znwm(i64 1) #11
  %0 = bitcast i8* %call to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %0)
  %call1 = tail call i32 @_Z3barP3Foo(%class.Foo* nonnull %0)
  %call2 = tail call i32 @_Z4quuzi(i32 %n) #10
  ret void
}

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #7

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN3FooC2Ev(%class.Foo* %this) unnamed_addr #4 comdat align 2 {
entry:
  ret void
}

; Function Attrs: uwtable
define dso_local void @_Z15serial_tryblocki(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %call = tail call i32 @_Z4quuzi(i32 %n) #10
  %call1 = invoke i8* @_Znwm(i64 1) #11
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %0 = bitcast i8* %call1 to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %0)
  %call5 = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %0)
          to label %invoke.cont4 unwind label %lpad

invoke.cont4:                                     ; preds = %invoke.cont
  %call6 = tail call i32 @_Z4quuzi(i32 %n) #10
  %call8 = invoke i8* @_Znwm(i64 1) #11
          to label %invoke.cont7 unwind label %lpad

invoke.cont7:                                     ; preds = %invoke.cont4
  %1 = bitcast i8* %call8 to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %1)
  %call12 = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %1)
          to label %try.cont unwind label %lpad

lpad:                                             ; preds = %invoke.cont7, %invoke.cont4, %invoke.cont, %entry
  %2 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
          catch i8* null
  %3 = extractvalue { i8*, i32 } %2, 0
  %4 = extractvalue { i8*, i32 } %2, 1
  %5 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #10
  %matches = icmp eq i32 %4, %5
  %6 = tail call i8* @__cxa_begin_catch(i8* %3) #10
  br i1 %matches, label %catch16, label %catch

catch16:                                          ; preds = %lpad
  %7 = bitcast i8* %6 to i32*
  %8 = load i32, i32* %7, align 4, !tbaa !2
  invoke void @_Z10handle_exni(i32 %8)
          to label %invoke.cont19 unwind label %lpad18

invoke.cont19:                                    ; preds = %catch16
  tail call void @__cxa_end_catch() #10
  br label %try.cont

try.cont:                                         ; preds = %invoke.cont7, %invoke.cont19, %invoke.cont14
  ret void

catch:                                            ; preds = %lpad
  invoke void @_Z10handle_exni(i32 -1)
          to label %invoke.cont14 unwind label %lpad13

invoke.cont14:                                    ; preds = %catch
  tail call void @__cxa_end_catch()
  br label %try.cont

lpad13:                                           ; preds = %catch
  %9 = landingpad { i8*, i32 }
          cleanup
  %10 = extractvalue { i8*, i32 } %9, 0
  %11 = extractvalue { i8*, i32 } %9, 1
  invoke void @__cxa_end_catch()
          to label %eh.resume unwind label %terminate.lpad

lpad18:                                           ; preds = %catch16
  %12 = landingpad { i8*, i32 }
          cleanup
  %13 = extractvalue { i8*, i32 } %12, 0
  %14 = extractvalue { i8*, i32 } %12, 1
  tail call void @__cxa_end_catch() #10
  br label %eh.resume

eh.resume:                                        ; preds = %lpad13, %lpad18
  %ehselector.slot.0 = phi i32 [ %14, %lpad18 ], [ %11, %lpad13 ]
  %exn.slot.0 = phi i8* [ %13, %lpad18 ], [ %10, %lpad13 ]
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.0, 0
  %lpad.val22 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.0, 1
  resume { i8*, i32 } %lpad.val22

terminate.lpad:                                   ; preds = %lpad13
  %15 = landingpad { i8*, i32 }
          catch i8* null
  %16 = extractvalue { i8*, i32 } %15, 0
  tail call void @__clang_call_terminate(i8* %16) #12
  unreachable
}

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8*) local_unnamed_addr #8 comdat {
  %2 = tail call i8* @__cxa_begin_catch(i8* %0) #10
  tail call void @_ZSt9terminatev() #12
  unreachable
}

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #3

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #9

; Function Attrs: nounwind uwtable
define dso_local void @_Z14spawn_noexcepti(i32 %n) local_unnamed_addr #4 {
; CHECK-LABEL: define dso_local void @_Z14spawn_noexcepti(i32 %n)
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %entry
  tail call void @llvm.taskframe.use(token %0)
  %call = tail call i32 @_Z4quuzi(i32 %n) #10
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %entry
  %call1 = tail call i32 @_Z4quuzi(i32 %n) #10
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  ret void
}
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.

; Function Attrs: argmemonly nounwind
declare token @llvm.taskframe.create() #3

; Function Attrs: argmemonly nounwind
declare void @llvm.taskframe.use(token) #3

; Function Attrs: uwtable
define dso_local void @_Z16spawn_tf_nocatchi(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z16spawn_tf_nocatchi(i32 %n)
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: call void @__cilkrts_enter_frame_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  %call = tail call i8* @_Znwm(i64 1) #11
  %1 = bitcast i8* %call to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %1)
  detach within %syncreg, label %det.achd, label %det.cont
; CHECK: %[[SETJMPRET:.+]] = call i32 @llvm.eh.sjlj.setjmp(
; CHECK: %[[SETJMPBOOL:.+]] = icmp eq i32 %[[SETJMPRET]], 0
; CHECK: br i1 %[[SETJMPBOOL]], label %[[CALLHELPER:.+]], label %[[CONTINUE:.+]]

det.achd:                                         ; preds = %entry
  tail call void @llvm.taskframe.use(token %0)
  %call1 = tail call i32 @_Z3barP3Foo(%class.Foo* nonnull %1)
  reattach within %syncreg, label %det.cont
; CHECK: [[CALLHELPER]]:
; CHECK-NEXT: call fastcc void @_Z16spawn_tf_nocatchi.outline_entry.split.otd1()
; CHECK-NEXT: br label %[[CONTINUE]]

det.cont:                                         ; preds = %det.achd, %entry
  %call6 = tail call i32 @_Z4quuzi(i32 %n) #10
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  ret void
}
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.

; Function Attrs: argmemonly
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #9

; Function Attrs: nounwind uwtable
define dso_local void @_Z21spawn_stmt_destructori(i32 %n) local_unnamed_addr #4 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z21spawn_stmt_destructori(i32 %n)
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: call void @__cilkrts_enter_frame_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  %ref.tmp = alloca %class.Foo, align 1
  %1 = getelementptr inbounds %class.Foo, %class.Foo* %ref.tmp, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1) #10
  call void @_ZN3FooC2Ev(%class.Foo* nonnull %ref.tmp)
  detach within %syncreg, label %det.achd, label %det.cont
; CHECK: %[[SETJMPRET:.+]] = call i32 @llvm.eh.sjlj.setjmp(
; CHECK: %[[SETJMPBOOL:.+]] = icmp eq i32 %[[SETJMPRET]], 0
; CHECK: br i1 %[[SETJMPBOOL]], label %[[CALLHELPER:.+]], label %[[CONTINUE:.+]]

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %0)
  %call = invoke i32 @_Z3bazRK3Foo(%class.Foo* nonnull dereferenceable(1) %ref.tmp)
          to label %invoke.cont unwind label %lpad
; CHECK: [[CALLHELPER]]:
; CHECK-NEXT: call fastcc void @_Z21spawn_stmt_destructori.outline_entry.split.otd1()
; CHECK-NEXT: br label %[[CONTINUE]]

invoke.cont:                                      ; preds = %det.achd
  call void @_ZN3FooD2Ev(%class.Foo* nonnull %ref.tmp) #10
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1) #10
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %entry, %invoke.cont
  %call12 = call i32 @_Z4quuzi(i32 %n) #10
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  ret void

lpad:                                             ; preds = %det.achd
  %2 = landingpad { i8*, i32 }
          cleanup
  call void @_ZN3FooD2Ev(%class.Foo* nonnull %ref.tmp) #10
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1) #10
  unreachable
}
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.

declare dso_local i32 @_Z3bazRK3Foo(%class.Foo* dereferenceable(1)) local_unnamed_addr #1

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN3FooD2Ev(%class.Foo* %this) unnamed_addr #4 comdat align 2 {
entry:
  ret void
}

; Function Attrs: nounwind uwtable
define dso_local void @_Z21spawn_decl_destructori(i32 %n) local_unnamed_addr #4 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z21spawn_decl_destructori(i32 %n)
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: call void @__cilkrts_enter_frame_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  %ref.tmp = alloca %class.Foo, align 1
  %1 = getelementptr inbounds %class.Foo, %class.Foo* %ref.tmp, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1) #10
  call void @_ZN3FooC2Ev(%class.Foo* nonnull %ref.tmp)
  detach within %syncreg, label %det.achd, label %det.cont
; CHECK: %[[SETJMPRET:.+]] = call i32 @llvm.eh.sjlj.setjmp(
; CHECK: %[[SETJMPBOOL:.+]] = icmp eq i32 %[[SETJMPRET]], 0
; CHECK: br i1 %[[SETJMPBOOL]], label %[[CALLHELPER:.+]], label %[[CONTINUE:.+]]

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %0)
  %call = invoke i32 @_Z3bazRK3Foo(%class.Foo* nonnull dereferenceable(1) %ref.tmp)
          to label %invoke.cont unwind label %lpad
; CHECK: [[CALLHELPER]]:
; CHECK-NEXT: call fastcc void @_Z21spawn_decl_destructori.outline_entry.split.otd1()
; CHECK-NEXT: br label %[[CONTINUE]]

invoke.cont:                                      ; preds = %det.achd
  call void @_ZN3FooD2Ev(%class.Foo* nonnull %ref.tmp) #10
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1) #10
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %entry, %invoke.cont
  %call12 = call i32 @_Z4quuzi(i32 %n) #10
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  ret void

lpad:                                             ; preds = %det.achd
  %2 = landingpad { i8*, i32 }
          cleanup
  call void @_ZN3FooD2Ev(%class.Foo* nonnull %ref.tmp) #10
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1) #10
  unreachable
}
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.

; Function Attrs: uwtable
define dso_local void @_Z22spawn_block_destructori(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z22spawn_block_destructori(i32 %n)
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: call void @__cilkrts_enter_frame_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
entry:
  %f = alloca %class.Foo, align 1
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = getelementptr inbounds %class.Foo, %class.Foo* %f, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %0) #10
  call void @_ZN3FooC2Ev(%class.Foo* nonnull %f)
  %1 = call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad2
; CHECK: %[[SETJMPRET:.+]] = call i32 @llvm.eh.sjlj.setjmp(
; CHECK: %[[SETJMPBOOL:.+]] = icmp eq i32 %[[SETJMPRET]], 0
; CHECK: br i1 %[[SETJMPBOOL]], label %[[CALLHELPER:.+]], label %[[CONTINUE:.+]]

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %1)
  %call = invoke i32 @_Z3bazRK3Foo(%class.Foo* nonnull dereferenceable(1) %f)
          to label %invoke.cont unwind label %lpad
; CHECK: [[CALLHELPER]]:
; CHECK-NEXT: invoke fastcc void @_Z22spawn_block_destructori.outline_entry.split.otd1(%class.Foo*
; CHECK-NEXT: to label %[[CONTINUE]] unwind label %lpad9

invoke.cont:                                      ; preds = %det.achd
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %entry, %invoke.cont
  %call12 = call i32 @_Z4quuzi(i32 %n) #10
  call void @_ZN3FooD2Ev(%class.Foo* nonnull %f) #10
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %0) #10
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  ret void

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
  call void @_ZN3FooD2Ev(%class.Foo* nonnull %f) #10
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %0) #10
  resume { i8*, i32 } %4
; CHECK: {{^lpad9}}:
; CHECK-NEXT: landingpad { i8*, i32 }
; CHECK-NEXT: cleanup
; CHECK: call i8* @__cilk_catch_exception(%struct.__cilkrts_stack_frame* %[[CILKSF]]
; CHECK: call void @_ZN3FooD2Ev(%class.Foo*
; CHECK-NEXT: call void @llvm.lifetime.end.p0i8(
; CHECK: call void @__cilk_parent_epilogue(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: resume { i8*, i32 }

unreachable:                                      ; preds = %lpad2, %lpad
  unreachable
}
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.

; Function Attrs: uwtable
define dso_local void @_Z18spawn_throw_inlinei(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z18spawn_throw_inlinei(i32 %n)
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: call void @__cilkrts_enter_frame_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  %call = tail call i8* @_Znwm(i64 1) #11
  %1 = bitcast i8* %call to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %1)
  detach within %syncreg, label %det.achd, label %det.cont
; CHECK: %[[SETJMPRET:.+]] = call i32 @llvm.eh.sjlj.setjmp(
; CHECK: %[[SETJMPBOOL:.+]] = icmp eq i32 %[[SETJMPRET]], 0
; CHECK: br i1 %[[SETJMPBOOL]], label %[[CALLHELPER:.+]], label %[[CONTINUE:.+]]

det.achd:                                         ; preds = %entry
  tail call void @llvm.taskframe.use(token %0)
  %call.i = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %1)
          to label %_Z3fooP3Foo.exit unwind label %lpad.i
; CHECK: [[CALLHELPER]]:
; CHECK-NEXT: call fastcc void @_Z18spawn_throw_inlinei.outline_entry.split.otd1()
; CHECK-NEXT: br label %[[CONTINUE]]

lpad.i:                                           ; preds = %det.achd
  %2 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %3 = extractvalue { i8*, i32 } %2, 0
  %4 = extractvalue { i8*, i32 } %2, 1
  %5 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #10
  %matches.i = icmp eq i32 %4, %5
  tail call void @llvm.assume(i1 %matches.i)
  %6 = tail call i8* @__cxa_begin_catch(i8* %3) #10
  %7 = bitcast i8* %6 to i32*
  %8 = load i32, i32* %7, align 4, !tbaa !2
  invoke void @_Z10handle_exni(i32 %8)
          to label %invoke.cont2.i unwind label %lpad1.i

invoke.cont2.i:                                   ; preds = %lpad.i
  tail call void @__cxa_end_catch() #10
  br label %_Z3fooP3Foo.exit

lpad1.i:                                          ; preds = %lpad.i
  %9 = landingpad { i8*, i32 }
          cleanup
  tail call void @__cxa_end_catch() #10
  unreachable

_Z3fooP3Foo.exit:                                 ; preds = %det.achd, %invoke.cont2.i
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %entry, %_Z3fooP3Foo.exit
  %call6 = tail call i32 @_Z4quuzi(i32 %n) #10
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  ret void
}
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.

; Function Attrs: uwtable
define dso_local void @_Z14spawn_tryblocki(i32 %n) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z14spawn_tryblocki(i32 %n)
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: call void @__cilkrts_enter_frame_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd, label %det.cont
; CHECK: %[[SETJMPRET:.+]] = call i32 @llvm.eh.sjlj.setjmp(
; CHECK: %[[SETJMPBOOL:.+]] = icmp eq i32 %[[SETJMPRET]], 0
; CHECK: br i1 %[[SETJMPBOOL]], label %[[CALLHELPER1:.+]], label %[[CONTINUE1:.+]]

det.achd:                                         ; preds = %entry
  tail call void @llvm.taskframe.use(token %0)
  %call = tail call i32 @_Z4quuzi(i32 %n) #10
  reattach within %syncreg, label %det.cont
; CHECK: [[CALLHELPER1]]:
; CHECK-NEXT: call fastcc void @_Z14spawn_tryblocki.outline_entry.split.otd1(i32 %n)
; CHECK-NEXT: br label %[[CONTINUE1]]

det.cont:                                         ; preds = %det.achd, %entry
  %1 = tail call token @llvm.taskframe.create()
  %call1 = invoke i8* @_Znwm(i64 1) #11
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %det.cont
  %2 = bitcast i8* %call1 to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %2)
  detach within %syncreg, label %det.achd4, label %det.cont11 unwind label %lpad
; CHECK: %[[SETJMPRET:.+]] = call i32 @llvm.eh.sjlj.setjmp(
; CHECK: %[[SETJMPBOOL:.+]] = icmp eq i32 %[[SETJMPRET]], 0
; CHECK: br i1 %[[SETJMPBOOL]], label %[[CALLHELPER2:.+]], label %[[CONTINUE2:.+]]

det.achd4:                                        ; preds = %invoke.cont
  tail call void @llvm.taskframe.use(token %1)
  %call9 = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %2)
          to label %invoke.cont8 unwind label %lpad5
; CHECK: [[CALLHELPER2]]:
; CHECK-NEXT: invoke fastcc void @_Z14spawn_tryblocki.outline_det.cont.split.otd1()
; CHECK-NEXT: to label %[[CONTINUE2]] unwind label %lpad16

invoke.cont8:                                     ; preds = %det.achd4
  reattach within %syncreg, label %det.cont11

det.cont11:                                       ; preds = %invoke.cont, %invoke.cont8
  %3 = tail call token @llvm.taskframe.create()
  detach within %syncreg, label %det.achd19, label %det.cont21
; CHECK: %[[SETJMPRET:.+]] = call i32 @llvm.eh.sjlj.setjmp(
; CHECK: %[[SETJMPBOOL:.+]] = icmp eq i32 %[[SETJMPRET]], 0
; CHECK: br i1 %[[SETJMPBOOL]], label %[[CALLHELPER3:.+]], label %[[CONTINUE3:.+]]

det.achd19:                                       ; preds = %det.cont11
  tail call void @llvm.taskframe.use(token %3)
  %call20 = tail call i32 @_Z4quuzi(i32 %n) #10
  reattach within %syncreg, label %det.cont21
; CHECK: [[CALLHELPER3]]:
; CHECK-NEXT: call fastcc void @_Z14spawn_tryblocki.outline_det.cont11.split.otd1(i32 %n)
; CHECK-NEXT: br label %[[CONTINUE3]]

det.cont21:                                       ; preds = %det.achd19, %det.cont11
  %call23 = invoke i8* @_Znwm(i64 1) #11
          to label %invoke.cont22 unwind label %lpad16

invoke.cont22:                                    ; preds = %det.cont21
  %4 = bitcast i8* %call23 to %class.Foo*
  tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %4)
  %call28 = invoke i32 @_Z3barP3Foo(%class.Foo* nonnull %4)
          to label %invoke.cont27 unwind label %lpad16

invoke.cont27:                                    ; preds = %invoke.cont22
  sync within %syncreg, label %try.cont

lpad:                                             ; preds = %invoke.cont, %lpad5, %det.cont
  %5 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %1, { i8*, i32 } %5)
          to label %unreachable unwind label %lpad16

lpad5:                                            ; preds = %det.achd4
  %6 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %6)
          to label %unreachable unwind label %lpad

lpad16:                                           ; preds = %invoke.cont22, %det.cont21, %lpad
  %7 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
          catch i8* null
  %8 = extractvalue { i8*, i32 } %7, 0
  %9 = extractvalue { i8*, i32 } %7, 1
  %10 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #10
  %matches = icmp eq i32 %9, %10
  %11 = tail call i8* @__cxa_begin_catch(i8* %8) #10
  br i1 %matches, label %catch36, label %catch
; CHECK: {{^lpad16}}:
; CHECK-NEXT: landingpad { i8*, i32 }
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK-NEXT: catch i8* null
; CHECK: call i8* @__cilk_catch_exception(%struct.__cilkrts_stack_frame* %[[CILKSF]],
; CHECK: br i1 %matches, label %catch36, label %catch

catch36:                                          ; preds = %lpad16
  %12 = bitcast i8* %11 to i32*
  %13 = load i32, i32* %12, align 4, !tbaa !2
  invoke void @_Z10handle_exni(i32 %13)
          to label %invoke.cont39 unwind label %lpad38

invoke.cont39:                                    ; preds = %catch36
  tail call void @__cxa_end_catch() #10
  br label %try.cont

try.cont:                                         ; preds = %invoke.cont27, %invoke.cont39, %invoke.cont33
  ret void

catch:                                            ; preds = %lpad16
  invoke void @_Z10handle_exni(i32 -1)
          to label %invoke.cont33 unwind label %lpad32

invoke.cont33:                                    ; preds = %catch
  tail call void @__cxa_end_catch()
  br label %try.cont

lpad32:                                           ; preds = %catch
  %14 = landingpad { i8*, i32 }
          cleanup
  %15 = extractvalue { i8*, i32 } %14, 0
  %16 = extractvalue { i8*, i32 } %14, 1
  invoke void @__cxa_end_catch()
          to label %eh.resume unwind label %terminate.lpad

lpad38:                                           ; preds = %catch36
  %17 = landingpad { i8*, i32 }
          cleanup
  %18 = extractvalue { i8*, i32 } %17, 0
  %19 = extractvalue { i8*, i32 } %17, 1
  tail call void @__cxa_end_catch() #10
  br label %eh.resume

eh.resume:                                        ; preds = %lpad32, %lpad38
  %ehselector.slot18.0 = phi i32 [ %19, %lpad38 ], [ %16, %lpad32 ]
  %exn.slot17.0 = phi i8* [ %18, %lpad38 ], [ %15, %lpad32 ]
  %lpad.val44 = insertvalue { i8*, i32 } undef, i8* %exn.slot17.0, 0
  %lpad.val45 = insertvalue { i8*, i32 } %lpad.val44, i32 %ehselector.slot18.0, 1
  resume { i8*, i32 } %lpad.val45
; CHECK: {{^eh.resume}}:
; CHECK: call void @__cilk_parent_epilogue(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK-NEXT: resume { i8*, i32 }

terminate.lpad:                                   ; preds = %lpad32
  %20 = landingpad { i8*, i32 }
          catch i8* null
  %21 = extractvalue { i8*, i32 } %20, 0
  tail call void @__clang_call_terminate(i8* %21) #12
  unreachable

unreachable:                                      ; preds = %lpad, %lpad5
  unreachable
}
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.
; TAPIRCLEANUP: CodeGen found Tapir instructions to serialize.

; Function Attrs: nounwind
declare void @llvm.assume(i1) #10

; CHECK-LABEL: define private fastcc void @_Z14spawn_tryblocki.outline_entry.split.otd1(i32
; CHECK: %[[ARG:[a-zA-Z0-9._]+]])
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame

; CHECK: call void @__cilkrts_enter_frame_fast_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: call void @__cilkrts_detach(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: br label %[[BODY:.+]]

; CHECK: [[BODY]]:
; CHECK: call i32 @_Z4quuzi(i32 {{.*}}%[[ARG]])
; CHECK-NEXT: br label %{{.+}}


; CHECK-LABEL: define private fastcc void @_Z14spawn_tryblocki.outline_det.cont.split.otd1()
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame

; CHECK: call void @__cilkrts_enter_frame_fast_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: %[[NEWRET:.+]] = invoke i8* @_Znwm(i64 1)
; CHECK-NEXT: to label %[[NEWCONT:.+]] unwind label %[[NEWLPAD:.+]]

; CHECK: [[NEWCONT]]:
; CHECK-NEXT: %[[FOOARG:.+]] = bitcast i8* %[[NEWRET]] to %class.Foo*
; CHECK-NEXT: tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: call void @__cilkrts_detach(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK-NEXT: br label %[[BODY:.+]]

; CHECK: [[NEWLPAD]]:
; CHECK-NEXT: %[[NEWLPADVAL:.+]] = landingpad { i8*, i32 }
; CHECK-NEXT: cleanup
; CHECK: call void @__cilk_parent_epilogue(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK-NEXT: resume { i8*, i32 } %[[NEWLPADVAL]]

; CHECK: [[BODY]]:
; CHECK: invoke i32 @_Z3barP3Foo(%class.Foo* {{.+}}%[[FOOARG]])
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

; CHECK: [[LPAD]]:
; CHECK-NEXT: %[[LPADVAL:.+]] = landingpad { i8*, i32 }
; CHECK-NEXT: cleanup
; CHECK: %[[EXNDATA:.+]] = extractvalue { i8*, i32 } %[[LPADVAL]], 0
; CHECK-NEXT: %[[FLAGSADDR:.+]] = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %[[CILKSF]], i32 0, i32 0
; CHECK-NEXT: %[[FLAGS:.+]] = load {{.+}} i32, i32* %[[FLAGSADDR]]
; CHECK-NEXT: %[[NEWFLAGS:.+]] = or i32 %[[FLAGS]],
; CHECK: store {{.+}} i32 %[[NEWFLAGS]],
; CHECK: %[[EXNDATAADDR:.+]] = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %[[CILKSF]], i32 0, i32 4
; CHECK-NEXT: store {{.+}} i8* %[[EXNDATA]], i8** %[[EXNDATAADDR]]
; CHECK-NEXT: call void @__cilk_parent_epilogue(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK-NEXT: resume { i8*, i32 } %[[LPADVAL]]


; CHECK-LABEL: define private fastcc void @_Z14spawn_tryblocki.outline_det.cont11.split.otd1(i32
; CHECK: %[[ARG:[a-zA-Z0-9._]+]])
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame

; CHECK: call void @__cilkrts_enter_frame_fast_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: call void @__cilkrts_detach(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: br label %[[BODY:.+]]

; CHECK: [[BODY]]:
; CHECK: call i32 @_Z4quuzi(i32 {{.*}}%[[ARG]])
; CHECK-NEXT: br label %{{.+}}


; CHECK-LABEL: define private fastcc void @_Z18spawn_throw_inlinei.outline_entry.split.otd1()
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame

; CHECK: call void @__cilkrts_enter_frame_fast_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: %[[NEWRET:.+]] = tail call i8* @_Znwm(i64 1)
; CHECK-NEXT: %[[FOOARG:.+]] = bitcast i8* %[[NEWRET]] to %class.Foo*
; CHECK-NEXT: tail call void @_ZN3FooC2Ev(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: call void @__cilkrts_detach(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: br label %[[BODY:.+]]

; CHECK: [[BODY]]:
; CHECK: invoke i32 @_Z3barP3Foo(%class.Foo* {{.+}}%[[FOOARG]])
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

; CHECK: [[LPAD]]:
; CHECK-NEXT: landingpad { i8*, i32 }
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)
; CHECK: tail call i8* @__cxa_begin_catch(
; CHECK: invoke void @_Z10handle_exni(
; CHECK-NEXT: to label %[[HANDLEEXNCONT:.+]] unwind label %[[LPADIN:.+]]

; CHECK: [[LPADIN]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: tail call void @__cxa_end_catch()
; CHECK-NEXT: unreachable


; CHECK-LABEL: define private fastcc void @_Z22spawn_block_destructori.outline_entry.split.otd1(
; CHECK: %[[ARG:[a-zA-Z0-9._]+]])
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame

; CHECK: call void @__cilkrts_enter_frame_fast_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: call void @__cilkrts_detach(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: br label %[[BODY:.+]]

; CHECK: [[BODY]]:
; CHECK: invoke i32 @_Z3bazRK3Foo(%class.Foo* {{.+}}%[[ARG]])
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

; CHECK: [[LPAD]]:
; CHECK-NEXT: %[[LPADVAL:.+]] = landingpad { i8*, i32 }
; CHECK-NEXT: cleanup
; CHECK: %[[EXNDATA:.+]] = extractvalue { i8*, i32 } %[[LPADVAL]], 0
; CHECK-NEXT: %[[FLAGSADDR:.+]] = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %[[CILKSF]], i32 0, i32 0
; CHECK-NEXT: %[[FLAGS:.+]] = load {{.+}} i32, i32* %[[FLAGSADDR]]
; CHECK-NEXT: %[[NEWFLAGS:.+]] = or i32 %[[FLAGS]],
; CHECK: store {{.+}} i32 %[[NEWFLAGS]],
; CHECK: %[[EXNDATAADDR:.+]] = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %[[CILKSF]], i32 0, i32 4
; CHECK-NEXT: store {{.+}} i8* %[[EXNDATA]], i8** %[[EXNDATAADDR]]
; CHECK-NEXT: call void @__cilk_parent_epilogue(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK-NEXT: resume { i8*, i32 } %[[LPADVAL]]


; CHECK-LABEL: define private fastcc void @_Z21spawn_decl_destructori.outline_entry.split.otd1()
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: %[[REFTMP:.+]] = alloca %class.Foo

; CHECK: call void @__cilkrts_enter_frame_fast_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: %[[FOOARG:.+]] = getelementptr inbounds %class.Foo, %class.Foo* %[[REFTMP]], i64 0, i32 0
; CHECK-NEXT: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[FOOARG]])
; CHECK-NEXT: call void @_ZN3FooC2Ev(%class.Foo* nonnull %[[REFTMP]])
; CHECK-NEXT: call void @__cilkrts_detach(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: br label %[[BODY:.+]]

; CHECK: [[BODY]]:
; CHECK: invoke i32 @_Z3bazRK3Foo(%class.Foo* {{.+}}%[[REFTMP]])
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

; CHECK: [[LPAD]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: call void @_ZN3FooD2Ev(%class.Foo* nonnull %[[REFTMP]])
; CHECK-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[FOOARG]])
; CHECK-NEXT: unreachable


; CHECK-LABEL: define private fastcc void @_Z21spawn_stmt_destructori.outline_entry.split.otd1()
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: %[[REFTMP:.+]] = alloca %class.Foo

; CHECK: call void @__cilkrts_enter_frame_fast_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: %[[FOOARG:.+]] = getelementptr inbounds %class.Foo, %class.Foo* %[[REFTMP]], i64 0, i32 0
; CHECK-NEXT: call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %[[FOOARG]])
; CHECK-NEXT: call void @_ZN3FooC2Ev(%class.Foo* nonnull %[[REFTMP]])
; CHECK-NEXT: call void @__cilkrts_detach(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: br label %[[BODY:.+]]

; CHECK: [[BODY]]:
; CHECK: invoke i32 @_Z3bazRK3Foo(%class.Foo* {{.+}}%[[REFTMP]])
; CHECK-NEXT: to label %[[INVOKECONT:.+]] unwind label %[[LPAD:.+]]

; CHECK: [[LPAD]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: call void @_ZN3FooD2Ev(%class.Foo* nonnull %[[REFTMP]])
; CHECK-NEXT: call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %[[FOOARG]])
; CHECK-NEXT: unreachable


; CHECK-LABEL: define private fastcc void @_Z16spawn_tf_nocatchi.outline_entry.split.otd1()
; CHECK: %[[CILKSF:.+]] = alloca %struct.__cilkrts_stack_frame

; CHECK: call void @__cilkrts_enter_frame_fast_1(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: %[[NEWRET:.+]] = tail call i8* @_Znwm(i64 1)
; CHECK-NEXT: %[[FOOARG:.+]] = bitcast i8* %[[NEWRET]] to %class.Foo*
; CHECK-NEXT: call void @_ZN3FooC2Ev(%class.Foo* nonnull %[[FOOARG]])
; CHECK-NEXT: call void @__cilkrts_detach(%struct.__cilkrts_stack_frame* %[[CILKSF]])
; CHECK: br label %[[BODY:.+]]

; CHECK: [[BODY]]:
; CHECK: tail call i32 @_Z3barP3Foo(%class.Foo* {{.+}}%[[FOOARG]])

; CHECK-NOT: landingpad

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
