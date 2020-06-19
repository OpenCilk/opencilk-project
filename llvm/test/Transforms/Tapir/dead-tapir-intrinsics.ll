; Test that basic -O1 optimizations effectively remove Tapir
; instructions and intrinsics.
;
; RUN: opt < %s -O1 -simplify-taskframes=false -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-NOTFSIMPLIFY
; RUN: opt < %s -passes='default<O1>' -simplify-taskframes=false -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-NOTFSIMPLIFY
; RUN: opt < %s -O1 -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-TFSIMPLIFY
; RUN: opt < %s -passes='default<O1>' -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-TFSIMPLIFY

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.object.1 = type { %class.object.2, %class.object.2 }
%class.object.2 = type { i8 }
%class.object.0 = type { %class.object.1, %class.object.1 }
%class.object = type { %class.object.0, %class.object.0 }
%class.object.3 = type { %class.object, %class.object }

@marker = dso_local global i64* null, align 8

; Function Attrs: noinline nounwind uwtable
define dso_local i64 @_Z3addll(i64 %x, i64 %y) #0 {
entry:
  %x.addr = alloca i64, align 8
  %y.addr = alloca i64, align 8
  store i64 %x, i64* %x.addr, align 8
  store i64 %y, i64* %y.addr, align 8
  %0 = load i64, i64* %x.addr, align 8
  %1 = load i64, i64* %y.addr, align 8
  %add = add nsw i64 %0, %1
  ret i64 %add
}

; Function Attrs: noinline uwtable
define dso_local void @_Z6parentl(i64 %x) #1 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z6parentl(i64
; CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
; CHECK-NOT: call token @llvm.syncregion.start()
; CHECK: call token @llvm.taskframe.create()
; CHECK: call token @llvm.taskframe.create()
; CHECK detach within %[[SYNCREG]]
; CHECK-NOTFSIMPLIFY: call token @llvm.taskframe.create()
; CHECK-TFSIMPLIFY-NOT: call token @llvm.taskframe.create()
; CHECK detach within %[[SYNCREG]]
entry:
  %this.addr.i122.i133.i32 = alloca %class.object.1*, align 8
  %exn.slot12.i124.i134.i33 = alloca i8*
  %ehselector.slot13.i125.i135.i34 = alloca i32
  %agg.tmp14.i126.i136.i35 = alloca %class.object.2, align 1
  %agg.tmp.i128.i137.i36 = alloca %class.object.2, align 1
  %exn.slot5.i129.i138.i37 = alloca i8*
  %ehselector.slot6.i130.i139.i38 = alloca i32
  %this.addr.i65.i141.i39 = alloca %class.object.1*, align 8
  %other.addr.i66.i142.i40 = alloca %class.object.1*, align 8
  %exn.slot.i67.i143.i41 = alloca i8*
  %ehselector.slot.i68.i144.i42 = alloca i32
  %agg.tmp20.i70.i145.i43 = alloca %class.object.2, align 1
  %this.addr.i147.i44 = alloca %class.object.0*, align 8
  %other.addr.i148.i45 = alloca %class.object.0*, align 8
  %exn.slot.i149.i46 = alloca i8*
  %ehselector.slot.i150.i47 = alloca i32
  %agg.tmp20.i152.i48 = alloca %class.object.1, align 1
  %this.addr.i55 = alloca %class.object*, align 8
  %other.addr.i56 = alloca %class.object*, align 8
  %exn.slot.i57 = alloca i8*
  %ehselector.slot.i58 = alloca i32
  %agg.tmp20.i60 = alloca %class.object.0, align 1
  %syncreg.i105.i387.i29 = call token @llvm.syncregion.start()
  %syncreg.i56.i393.i30 = call token @llvm.syncregion.start()
  %syncreg.i395.i31 = call token @llvm.syncregion.start()
  %syncreg.i123.i140.i49 = call token @llvm.syncregion.start()
  %syncreg.i69.i146.i50 = call token @llvm.syncregion.start()
  %syncreg.i151.i51 = call token @llvm.syncregion.start()
  %syncreg.i105.i.i52 = call token @llvm.syncregion.start()
  %syncreg.i56.i.i53 = call token @llvm.syncregion.start()
  %syncreg.i38.i54 = call token @llvm.syncregion.start()
  %syncreg.i59 = call token @llvm.syncregion.start()
  %x.addr = alloca i64, align 8
  %obj = alloca %class.object, align 1
  %i = alloca i64, align 8
  %syncreg = call token @llvm.syncregion.start()
  %exn.slot15 = alloca i8*
  %ehselector.slot16 = alloca i32
  store i64 %x, i64* %x.addr, align 8
  call void @_ZN6objectILi3EEC1Ev(%class.object* %obj)
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i64, i64* %i, align 8
  %cmp = icmp slt i64 %0, 100
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  br label %for.body.split

for.body.split:                                   ; preds = %for.body
  %1 = call token @llvm.taskframe.create()
  %this.addr.i122.i133.i = alloca %class.object.1*, align 8
  %exn.slot12.i124.i134.i = alloca i8*
  %ehselector.slot13.i125.i135.i = alloca i32
  %agg.tmp14.i126.i136.i = alloca %class.object.2, align 1
  %agg.tmp.i128.i137.i = alloca %class.object.2, align 1
  %exn.slot5.i129.i138.i = alloca i8*
  %ehselector.slot6.i130.i139.i = alloca i32
  %this.addr.i65.i141.i = alloca %class.object.1*, align 8
  %other.addr.i66.i142.i = alloca %class.object.1*, align 8
  %exn.slot.i67.i143.i = alloca i8*
  %ehselector.slot.i68.i144.i = alloca i32
  %agg.tmp20.i70.i145.i = alloca %class.object.2, align 1
  %this.addr.i147.i = alloca %class.object.0*, align 8
  %other.addr.i148.i = alloca %class.object.0*, align 8
  %exn.slot.i149.i = alloca i8*
  %ehselector.slot.i150.i = alloca i32
  %agg.tmp20.i152.i = alloca %class.object.1, align 1
  %this.addr.i = alloca %class.object*, align 8
  %other.addr.i = alloca %class.object*, align 8
  %exn.slot.i = alloca i8*
  %ehselector.slot.i = alloca i32
  %agg.tmp20.i = alloca %class.object.0, align 1
  %syncreg.i105.i387.i = call token @llvm.syncregion.start()
  %syncreg.i56.i393.i = call token @llvm.syncregion.start()
  %syncreg.i395.i = call token @llvm.syncregion.start()
  %syncreg.i123.i140.i = call token @llvm.syncregion.start()
  %syncreg.i69.i146.i = call token @llvm.syncregion.start()
  %syncreg.i151.i = call token @llvm.syncregion.start()
  %syncreg.i105.i.i = call token @llvm.syncregion.start()
  %syncreg.i56.i.i = call token @llvm.syncregion.start()
  %syncreg.i38.i = call token @llvm.syncregion.start()
  %syncreg.i = call token @llvm.syncregion.start()
  %agg.tmp = alloca %class.object, align 1
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  %agg.tmp3 = alloca %class.object, align 1
  %savedstack = call i8* @llvm.stacksave()
  store %class.object* %agg.tmp, %class.object** %this.addr.i, align 8
  store %class.object* %obj, %class.object** %other.addr.i, align 8
  %this1.i = load %class.object*, %class.object** %this.addr.i, align 8
  %a.i = getelementptr inbounds %class.object, %class.object* %this1.i, i32 0, i32 0
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %a.i)
          to label %.noexc unwind label %lpad

.noexc:                                           ; preds = %for.body.split
  %b.i = getelementptr inbounds %class.object, %class.object* %this1.i, i32 0, i32 1
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %b.i)
          to label %invoke.cont.i unwind label %lpad.i

invoke.cont.i:                                    ; preds = %.noexc
  br label %invoke.cont.i.split

invoke.cont.i.split:                              ; preds = %invoke.cont.i
  %2 = call token @llvm.taskframe.create()
  %agg.tmp.i = alloca %class.object.0, align 1
  %exn.slot12.i = alloca i8*
  %ehselector.slot13.i = alloca i32
  %a2.i = getelementptr inbounds %class.object, %class.object* %this1.i, i32 0, i32 0
  %3 = load %class.object*, %class.object** %other.addr.i, align 8
  %a3.i = getelementptr inbounds %class.object, %class.object* %3, i32 0, i32 0
  detach within %syncreg.i, label %det.achd.i, label %det.cont.i unwind label %lpad11.i

det.achd.i:                                       ; preds = %invoke.cont.i.split
  %this.addr.i122.i.i = alloca %class.object.1*, align 8
  %exn.slot12.i124.i.i = alloca i8*
  %ehselector.slot13.i125.i.i = alloca i32
  %agg.tmp14.i126.i.i = alloca %class.object.2, align 1
  %agg.tmp.i128.i.i = alloca %class.object.2, align 1
  %exn.slot5.i129.i.i = alloca i8*
  %ehselector.slot6.i130.i.i = alloca i32
  %this.addr.i65.i.i = alloca %class.object.1*, align 8
  %other.addr.i66.i.i = alloca %class.object.1*, align 8
  %exn.slot.i67.i.i = alloca i8*
  %ehselector.slot.i68.i.i = alloca i32
  %agg.tmp20.i70.i.i = alloca %class.object.2, align 1
  %this.addr.i.i = alloca %class.object.0*, align 8
  %other.addr.i.i = alloca %class.object.0*, align 8
  %exn.slot.i.i = alloca i8*
  %ehselector.slot.i.i = alloca i32
  %agg.tmp20.i.i = alloca %class.object.1, align 1
  %syncreg.i123.i.i = call token @llvm.syncregion.start()
  %syncreg.i69.i.i = call token @llvm.syncregion.start()
  %syncreg.i.i = call token @llvm.syncregion.start()
  %exn.slot5.i = alloca i8*
  %ehselector.slot6.i = alloca i32
  call void @llvm.taskframe.use(token %2)
  %savedstack.i = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp.i, %class.object.0** %this.addr.i.i, align 8
  store %class.object.0* %a3.i, %class.object.0** %other.addr.i.i, align 8
  %this1.i.i = load %class.object.0*, %class.object.0** %this.addr.i.i, align 8
  %a.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i.i)
          to label %.noexc.i unwind label %lpad4.i

.noexc.i:                                         ; preds = %det.achd.i
  %b.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i.i)
          to label %invoke.cont.i.i unwind label %lpad.i.i

invoke.cont.i.i:                                  ; preds = %.noexc.i
  br label %invoke.cont.i.i.split

invoke.cont.i.i.split:                            ; preds = %invoke.cont.i.i
  %4 = call token @llvm.taskframe.create()
  %agg.tmp.i.i = alloca %class.object.1, align 1
  %exn.slot12.i.i = alloca i8*
  %ehselector.slot13.i.i = alloca i32
  %a2.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i, i32 0, i32 0
  %5 = load %class.object.0*, %class.object.0** %other.addr.i.i, align 8
  %a3.i.i = getelementptr inbounds %class.object.0, %class.object.0* %5, i32 0, i32 0
  detach within %syncreg.i.i, label %det.achd.i.i, label %det.cont.i.i unwind label %lpad11.i.i

det.achd.i.i:                                     ; preds = %invoke.cont.i.i.split
  %this.addr.i36.i.i = alloca %class.object.1*, align 8
  %exn.slot12.i38.i.i = alloca i8*
  %ehselector.slot13.i39.i.i = alloca i32
  %agg.tmp14.i.i.i = alloca %class.object.2, align 1
  %agg.tmp.i41.i.i = alloca %class.object.2, align 1
  %exn.slot5.i42.i.i = alloca i8*
  %ehselector.slot6.i43.i.i = alloca i32
  %syncreg.i37.i.i = call token @llvm.syncregion.start()
  %this.addr.i.i.i = alloca %class.object.1*, align 8
  %other.addr.i.i.i = alloca %class.object.1*, align 8
  %exn.slot.i.i.i = alloca i8*
  %ehselector.slot.i.i.i = alloca i32
  %agg.tmp20.i.i.i = alloca %class.object.2, align 1
  %syncreg.i.i.i = call token @llvm.syncregion.start()
  %exn.slot5.i.i = alloca i8*
  %ehselector.slot6.i.i = alloca i32
  call void @llvm.taskframe.use(token %4)
  %savedstack.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i.i, %class.object.1** %this.addr.i.i.i, align 8
  store %class.object.1* %a3.i.i, %class.object.1** %other.addr.i.i.i, align 8
  %this1.i.i.i = load %class.object.1*, %class.object.1** %this.addr.i.i.i, align 8
  %a.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i.i)
          to label %.noexc.i.i unwind label %lpad4.i.i

.noexc.i.i:                                       ; preds = %det.achd.i.i
  %b.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i.i)
          to label %invoke.cont.i.i.i unwind label %lpad.i.i.i

invoke.cont.i.i.i:                                ; preds = %.noexc.i.i
  br label %invoke.cont.i.i.i.split

invoke.cont.i.i.i.split:                          ; preds = %invoke.cont.i.i.i
  %6 = call token @llvm.taskframe.create()
  %agg.tmp.i.i.i = alloca %class.object.2, align 1
  %exn.slot12.i.i.i = alloca i8*
  %ehselector.slot13.i.i.i = alloca i32
  %a2.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i, i32 0, i32 0
  %7 = load %class.object.1*, %class.object.1** %other.addr.i.i.i, align 8
  %a3.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %7, i32 0, i32 0
  detach within %syncreg.i.i.i, label %det.achd.i.i.i, label %det.cont.i.i.i unwind label %lpad11.i.i.i

det.achd.i.i.i:                                   ; preds = %invoke.cont.i.i.i.split
  %exn.slot5.i.i.i = alloca i8*
  %ehselector.slot6.i.i.i = alloca i32
  call void @llvm.taskframe.use(token %6)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i.i, %class.object.2* dereferenceable(1) %a3.i.i.i)
          to label %invoke.cont7.i.i.i unwind label %lpad4.i.i.i

invoke.cont7.i.i.i:                               ; preds = %det.achd.i.i.i
  %call.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i.i, %class.object.2* %agg.tmp.i.i.i)
          to label %invoke.cont9.i.i.i unwind label %lpad8.i.i.i

invoke.cont9.i.i.i:                               ; preds = %invoke.cont7.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i) #7
  reattach within %syncreg.i.i.i, label %det.cont.i.i.i

det.cont.i.i.i:                                   ; preds = %invoke.cont9.i.i.i, %invoke.cont.i.i.i.split
  %8 = load %class.object.1*, %class.object.1** %other.addr.i.i.i, align 8
  %b21.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %8, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i.i, %class.object.2* dereferenceable(1) %b21.i.i.i)
          to label %invoke.cont22.i.i.i unwind label %lpad19.i.i.i

invoke.cont22.i.i.i:                              ; preds = %det.cont.i.i.i
  %b23.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i, i32 0, i32 1
  %call26.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i.i, %class.object.2* %agg.tmp20.i.i.i)
          to label %invoke.cont25.i.i.i unwind label %lpad24.i.i.i

invoke.cont25.i.i.i:                              ; preds = %invoke.cont22.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i) #7
  sync within %syncreg.i.i.i, label %sync.continue.i.i.i

sync.continue.i.i.i:                              ; preds = %invoke.cont25.i.i.i
  invoke void @llvm.sync.unwind(token %syncreg.i.i.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i.i unwind label %lpad4.i.i

lpad.i.i.i:                                       ; preds = %.noexc.i.i
  %9 = landingpad { i8*, i32 }
          cleanup
  %10 = extractvalue { i8*, i32 } %9, 0
  store i8* %10, i8** %exn.slot.i.i.i, align 8
  %11 = extractvalue { i8*, i32 } %9, 1
  store i32 %11, i32* %ehselector.slot.i.i.i, align 4
  br label %ehcleanup29.i.i.i

lpad4.i.i.i:                                      ; preds = %det.achd.i.i.i
  %12 = landingpad { i8*, i32 }
          cleanup
  %13 = extractvalue { i8*, i32 } %12, 0
  store i8* %13, i8** %exn.slot5.i.i.i, align 8
  %14 = extractvalue { i8*, i32 } %12, 1
  store i32 %14, i32* %ehselector.slot6.i.i.i, align 4
  br label %ehcleanup.i.i.i

lpad8.i.i.i:                                      ; preds = %invoke.cont7.i.i.i
  %15 = landingpad { i8*, i32 }
          cleanup
  %16 = extractvalue { i8*, i32 } %15, 0
  store i8* %16, i8** %exn.slot5.i.i.i, align 8
  %17 = extractvalue { i8*, i32 } %15, 1
  store i32 %17, i32* %ehselector.slot6.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i) #7
  br label %ehcleanup.i.i.i

ehcleanup.i.i.i:                                  ; preds = %lpad8.i.i.i, %lpad4.i.i.i
  %exn.i.i.i = load i8*, i8** %exn.slot5.i.i.i, align 8
  %sel.i.i.i = load i32, i32* %ehselector.slot6.i.i.i, align 4
  %lpad.val.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i.i, 0
  %lpad.val10.i.i.i = insertvalue { i8*, i32 } %lpad.val.i.i.i, i32 %sel.i.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i.i, { i8*, i32 } %lpad.val10.i.i.i)
          to label %unreachable.i.i.i unwind label %lpad11.i.i.i

lpad11.i.i.i:                                     ; preds = %ehcleanup.i.i.i, %invoke.cont.i.i.i.split
  %18 = landingpad { i8*, i32 }
          cleanup
  %19 = extractvalue { i8*, i32 } %18, 0
  store i8* %19, i8** %exn.slot12.i.i.i, align 8
  %20 = extractvalue { i8*, i32 } %18, 1
  store i32 %20, i32* %ehselector.slot13.i.i.i, align 4
  %exn15.i.i.i = load i8*, i8** %exn.slot12.i.i.i, align 8
  %sel16.i.i.i = load i32, i32* %ehselector.slot13.i.i.i, align 4
  %lpad.val17.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i.i, 0
  %lpad.val18.i.i.i = insertvalue { i8*, i32 } %lpad.val17.i.i.i, i32 %sel16.i.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %6, { i8*, i32 } %lpad.val18.i.i.i)
          to label %unreachable.i.i.i unwind label %lpad19.i.i.i

lpad19.i.i.i:                                     ; preds = %lpad11.i.i.i, %det.cont.i.i.i
  %21 = landingpad { i8*, i32 }
          cleanup
  %22 = extractvalue { i8*, i32 } %21, 0
  store i8* %22, i8** %exn.slot.i.i.i, align 8
  %23 = extractvalue { i8*, i32 } %21, 1
  store i32 %23, i32* %ehselector.slot.i.i.i, align 4
  br label %ehcleanup28.i.i.i

lpad24.i.i.i:                                     ; preds = %invoke.cont22.i.i.i
  %24 = landingpad { i8*, i32 }
          cleanup
  %25 = extractvalue { i8*, i32 } %24, 0
  store i8* %25, i8** %exn.slot.i.i.i, align 8
  %26 = extractvalue { i8*, i32 } %24, 1
  store i32 %26, i32* %ehselector.slot.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i) #7
  br label %ehcleanup28.i.i.i

ehcleanup28.i.i.i:                                ; preds = %lpad24.i.i.i, %lpad19.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i.i) #7
  br label %ehcleanup29.i.i.i

ehcleanup29.i.i.i:                                ; preds = %ehcleanup28.i.i.i, %lpad.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i.i) #7
  %exn30.i.i.i = load i8*, i8** %exn.slot.i.i.i, align 8
  %sel31.i.i.i = load i32, i32* %ehselector.slot.i.i.i, align 4
  %lpad.val32.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i.i, 0
  %lpad.val33.i.i.i = insertvalue { i8*, i32 } %lpad.val32.i.i.i, i32 %sel31.i.i.i, 1
  br label %lpad4.body.i.i

unreachable.i.i.i:                                ; preds = %lpad11.i.i.i, %ehcleanup.i.i.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i.i:                ; preds = %sync.continue.i.i.i
  call void @llvm.stackrestore(i8* %savedstack.i.i)
  %savedstack61.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i.i, %class.object.1** %this.addr.i36.i.i, align 8
  %this1.i40.i.i = load %class.object.1*, %class.object.1** %this.addr.i36.i.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit.i.i.split

_ZN6objectILi1EEC2ERKS0_.exit.i.i.split:          ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i
  %27 = call token @llvm.taskframe.create()
  %a.i44.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i, i32 0, i32 0
  %a2.i45.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i, i32 0, i32 0
  detach within %syncreg.i37.i.i, label %det.achd.i49.i.i, label %det.cont.i52.i.i unwind label %lpad4.i58.i.i

det.achd.i49.i.i:                                 ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i.split
  %exn.slot.i46.i.i = alloca i8*
  %ehselector.slot.i47.i.i = alloca i32
  call void @llvm.taskframe.use(token %27)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i.i, %class.object.2* dereferenceable(1) %a2.i45.i.i)
  %call.i48.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i.i, %class.object.2* %agg.tmp.i41.i.i)
          to label %invoke.cont.i50.i.i unwind label %lpad.i56.i.i

invoke.cont.i50.i.i:                              ; preds = %det.achd.i49.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i) #7
  reattach within %syncreg.i37.i.i, label %det.cont.i52.i.i

det.cont.i52.i.i:                                 ; preds = %invoke.cont.i50.i.i, %_ZN6objectILi1EEC2ERKS0_.exit.i.i.split
  %b.i51.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i.i, %class.object.2* dereferenceable(1) %b.i51.i.i)
          to label %.noexc63.i.i unwind label %lpad8.i.i

.noexc63.i.i:                                     ; preds = %det.cont.i52.i.i
  %b15.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i, i32 0, i32 1
  %call18.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i.i, %class.object.2* %agg.tmp14.i.i.i)
          to label %invoke.cont17.i.i.i unwind label %lpad16.i.i.i

invoke.cont17.i.i.i:                              ; preds = %.noexc63.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i.i:                                     ; preds = %det.achd.i49.i.i
  %28 = landingpad { i8*, i32 }
          cleanup
  %29 = extractvalue { i8*, i32 } %28, 0
  store i8* %29, i8** %exn.slot.i46.i.i, align 8
  %30 = extractvalue { i8*, i32 } %28, 1
  store i32 %30, i32* %ehselector.slot.i47.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i) #7
  %exn.i53.i.i = load i8*, i8** %exn.slot.i46.i.i, align 8
  %sel.i54.i.i = load i32, i32* %ehselector.slot.i47.i.i, align 4
  %lpad.val.i55.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i53.i.i, 0
  %lpad.val3.i.i.i = insertvalue { i8*, i32 } %lpad.val.i55.i.i, i32 %sel.i54.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i.i, { i8*, i32 } %lpad.val3.i.i.i)
          to label %unreachable.i60.i.i unwind label %lpad4.i58.i.i

lpad4.i58.i.i:                                    ; preds = %lpad.i56.i.i, %_ZN6objectILi1EEC2ERKS0_.exit.i.i.split
  %31 = landingpad { i8*, i32 }
          cleanup
  %32 = extractvalue { i8*, i32 } %31, 0
  store i8* %32, i8** %exn.slot5.i42.i.i, align 8
  %33 = extractvalue { i8*, i32 } %31, 1
  store i32 %33, i32* %ehselector.slot6.i43.i.i, align 4
  %exn7.i.i.i = load i8*, i8** %exn.slot5.i42.i.i, align 8
  %sel8.i.i.i = load i32, i32* %ehselector.slot6.i43.i.i, align 4
  %lpad.val9.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn7.i.i.i, 0
  %lpad.val10.i57.i.i = insertvalue { i8*, i32 } %lpad.val9.i.i.i, i32 %sel8.i.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %27, { i8*, i32 } %lpad.val10.i57.i.i)
          to label %unreachable.i60.i.i unwind label %lpad11.i59.i.i

lpad11.i59.i.i:                                   ; preds = %lpad4.i58.i.i
  %34 = landingpad { i8*, i32 }
          cleanup
  %35 = extractvalue { i8*, i32 } %34, 0
  store i8* %35, i8** %exn.slot12.i38.i.i, align 8
  %36 = extractvalue { i8*, i32 } %34, 1
  store i32 %36, i32* %ehselector.slot13.i39.i.i, align 4
  br label %eh.resume.i.i.i

lpad16.i.i.i:                                     ; preds = %.noexc63.i.i
  %37 = landingpad { i8*, i32 }
          cleanup
  %38 = extractvalue { i8*, i32 } %37, 0
  store i8* %38, i8** %exn.slot12.i38.i.i, align 8
  %39 = extractvalue { i8*, i32 } %37, 1
  store i32 %39, i32* %ehselector.slot13.i39.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i) #7
  br label %eh.resume.i.i.i

eh.resume.i.i.i:                                  ; preds = %lpad16.i.i.i, %lpad11.i59.i.i
  %exn19.i.i.i = load i8*, i8** %exn.slot12.i38.i.i, align 8
  %sel20.i.i.i = load i32, i32* %ehselector.slot13.i39.i.i, align 4
  %lpad.val21.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn19.i.i.i, 0
  %lpad.val22.i.i.i = insertvalue { i8*, i32 } %lpad.val21.i.i.i, i32 %sel20.i.i.i, 1
  br label %lpad8.body.i.i

unreachable.i60.i.i:                              ; preds = %lpad4.i58.i.i, %lpad.i56.i.i
  unreachable

det.cont.i.i:                                     ; preds = %invoke.cont.i.i.split
  %40 = load %class.object.0*, %class.object.0** %other.addr.i.i, align 8
  %b21.i.i = getelementptr inbounds %class.object.0, %class.object.0* %40, i32 0, i32 1
  %savedstack116.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i.i, %class.object.1** %this.addr.i65.i.i, align 8
  store %class.object.1* %b21.i.i, %class.object.1** %other.addr.i66.i.i, align 8
  %this1.i71.i.i = load %class.object.1*, %class.object.1** %this.addr.i65.i.i, align 8
  %a.i72.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i.i)
          to label %.noexc117.i.i unwind label %lpad19.i.i

.noexc117.i.i:                                    ; preds = %det.cont.i.i
  %b.i73.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i.i)
          to label %invoke.cont.i79.i.i unwind label %lpad.i93.i.i

invoke.cont.i79.i.i:                              ; preds = %.noexc117.i.i
  br label %invoke.cont.i79.i.i.split

invoke.cont.i79.i.i.split:                        ; preds = %invoke.cont.i79.i.i
  %41 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i.i = alloca %class.object.2, align 1
  %exn.slot12.i75.i.i = alloca i8*
  %ehselector.slot13.i76.i.i = alloca i32
  %a2.i77.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i, i32 0, i32 0
  %42 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i, align 8
  %a3.i78.i.i = getelementptr inbounds %class.object.1, %class.object.1* %42, i32 0, i32 0
  detach within %syncreg.i69.i.i, label %det.achd.i82.i.i, label %det.cont.i87.i.i unwind label %lpad11.i101.i.i

det.achd.i82.i.i:                                 ; preds = %invoke.cont.i79.i.i.split
  %exn.slot5.i80.i.i = alloca i8*
  %ehselector.slot6.i81.i.i = alloca i32
  call void @llvm.taskframe.use(token %41)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i.i, %class.object.2* dereferenceable(1) %a3.i78.i.i)
          to label %invoke.cont7.i84.i.i unwind label %lpad4.i94.i.i

invoke.cont7.i84.i.i:                             ; preds = %det.achd.i82.i.i
  %call.i83.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i.i, %class.object.2* %agg.tmp.i74.i.i)
          to label %invoke.cont9.i85.i.i unwind label %lpad8.i95.i.i

invoke.cont9.i85.i.i:                             ; preds = %invoke.cont7.i84.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i) #7
  reattach within %syncreg.i69.i.i, label %det.cont.i87.i.i

det.cont.i87.i.i:                                 ; preds = %invoke.cont9.i85.i.i, %invoke.cont.i79.i.i.split
  %43 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i, align 8
  %b21.i86.i.i = getelementptr inbounds %class.object.1, %class.object.1* %43, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i.i, %class.object.2* dereferenceable(1) %b21.i86.i.i)
          to label %invoke.cont22.i90.i.i unwind label %lpad19.i106.i.i

invoke.cont22.i90.i.i:                            ; preds = %det.cont.i87.i.i
  %b23.i88.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i, i32 0, i32 1
  %call26.i89.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i.i, %class.object.2* %agg.tmp20.i70.i.i)
          to label %invoke.cont25.i91.i.i unwind label %lpad24.i107.i.i

invoke.cont25.i91.i.i:                            ; preds = %invoke.cont22.i90.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i) #7
  sync within %syncreg.i69.i.i, label %sync.continue.i92.i.i

sync.continue.i92.i.i:                            ; preds = %invoke.cont25.i91.i.i
  invoke void @llvm.sync.unwind(token %syncreg.i69.i.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i unwind label %lpad19.i.i

lpad.i93.i.i:                                     ; preds = %.noexc117.i.i
  %44 = landingpad { i8*, i32 }
          cleanup
  %45 = extractvalue { i8*, i32 } %44, 0
  store i8* %45, i8** %exn.slot.i67.i.i, align 8
  %46 = extractvalue { i8*, i32 } %44, 1
  store i32 %46, i32* %ehselector.slot.i68.i.i, align 4
  br label %ehcleanup29.i109.i.i

lpad4.i94.i.i:                                    ; preds = %det.achd.i82.i.i
  %47 = landingpad { i8*, i32 }
          cleanup
  %48 = extractvalue { i8*, i32 } %47, 0
  store i8* %48, i8** %exn.slot5.i80.i.i, align 8
  %49 = extractvalue { i8*, i32 } %47, 1
  store i32 %49, i32* %ehselector.slot6.i81.i.i, align 4
  br label %ehcleanup.i100.i.i

lpad8.i95.i.i:                                    ; preds = %invoke.cont7.i84.i.i
  %50 = landingpad { i8*, i32 }
          cleanup
  %51 = extractvalue { i8*, i32 } %50, 0
  store i8* %51, i8** %exn.slot5.i80.i.i, align 8
  %52 = extractvalue { i8*, i32 } %50, 1
  store i32 %52, i32* %ehselector.slot6.i81.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i) #7
  br label %ehcleanup.i100.i.i

ehcleanup.i100.i.i:                               ; preds = %lpad8.i95.i.i, %lpad4.i94.i.i
  %exn.i96.i.i = load i8*, i8** %exn.slot5.i80.i.i, align 8
  %sel.i97.i.i = load i32, i32* %ehselector.slot6.i81.i.i, align 4
  %lpad.val.i98.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i96.i.i, 0
  %lpad.val10.i99.i.i = insertvalue { i8*, i32 } %lpad.val.i98.i.i, i32 %sel.i97.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i.i, { i8*, i32 } %lpad.val10.i99.i.i)
          to label %unreachable.i115.i.i unwind label %lpad11.i101.i.i

lpad11.i101.i.i:                                  ; preds = %ehcleanup.i100.i.i, %invoke.cont.i79.i.i.split
  %53 = landingpad { i8*, i32 }
          cleanup
  %54 = extractvalue { i8*, i32 } %53, 0
  store i8* %54, i8** %exn.slot12.i75.i.i, align 8
  %55 = extractvalue { i8*, i32 } %53, 1
  store i32 %55, i32* %ehselector.slot13.i76.i.i, align 4
  %exn15.i102.i.i = load i8*, i8** %exn.slot12.i75.i.i, align 8
  %sel16.i103.i.i = load i32, i32* %ehselector.slot13.i76.i.i, align 4
  %lpad.val17.i104.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i.i, 0
  %lpad.val18.i105.i.i = insertvalue { i8*, i32 } %lpad.val17.i104.i.i, i32 %sel16.i103.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %41, { i8*, i32 } %lpad.val18.i105.i.i)
          to label %unreachable.i115.i.i unwind label %lpad19.i106.i.i

lpad19.i106.i.i:                                  ; preds = %lpad11.i101.i.i, %det.cont.i87.i.i
  %56 = landingpad { i8*, i32 }
          cleanup
  %57 = extractvalue { i8*, i32 } %56, 0
  store i8* %57, i8** %exn.slot.i67.i.i, align 8
  %58 = extractvalue { i8*, i32 } %56, 1
  store i32 %58, i32* %ehselector.slot.i68.i.i, align 4
  br label %ehcleanup28.i108.i.i

lpad24.i107.i.i:                                  ; preds = %invoke.cont22.i90.i.i
  %59 = landingpad { i8*, i32 }
          cleanup
  %60 = extractvalue { i8*, i32 } %59, 0
  store i8* %60, i8** %exn.slot.i67.i.i, align 8
  %61 = extractvalue { i8*, i32 } %59, 1
  store i32 %61, i32* %ehselector.slot.i68.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i) #7
  br label %ehcleanup28.i108.i.i

ehcleanup28.i108.i.i:                             ; preds = %lpad24.i107.i.i, %lpad19.i106.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i.i) #7
  br label %ehcleanup29.i109.i.i

ehcleanup29.i109.i.i:                             ; preds = %ehcleanup28.i108.i.i, %lpad.i93.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i.i) #7
  %exn30.i110.i.i = load i8*, i8** %exn.slot.i67.i.i, align 8
  %sel31.i111.i.i = load i32, i32* %ehselector.slot.i68.i.i, align 4
  %lpad.val32.i112.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i.i, 0
  %lpad.val33.i113.i.i = insertvalue { i8*, i32 } %lpad.val32.i112.i.i, i32 %sel31.i111.i.i, 1
  br label %lpad19.body.i.i

unreachable.i115.i.i:                             ; preds = %lpad11.i101.i.i, %ehcleanup.i100.i.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i.i:             ; preds = %sync.continue.i92.i.i
  call void @llvm.stackrestore(i8* %savedstack116.i.i)
  %b23.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i, i32 0, i32 1
  %savedstack161.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i.i, %class.object.1** %this.addr.i122.i.i, align 8
  %this1.i127.i.i = load %class.object.1*, %class.object.1** %this.addr.i122.i.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.split

_ZN6objectILi1EEC2ERKS0_.exit121.i.i.split:       ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i
  %62 = call token @llvm.taskframe.create()
  %a.i131.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i, i32 0, i32 0
  %a2.i132.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i, i32 0, i32 0
  detach within %syncreg.i123.i.i, label %det.achd.i136.i.i, label %det.cont.i141.i.i unwind label %lpad4.i152.i.i

det.achd.i136.i.i:                                ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.split
  %exn.slot.i133.i.i = alloca i8*
  %ehselector.slot.i134.i.i = alloca i32
  call void @llvm.taskframe.use(token %62)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i.i, %class.object.2* dereferenceable(1) %a2.i132.i.i)
  %call.i135.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i.i, %class.object.2* %agg.tmp.i128.i.i)
          to label %invoke.cont.i137.i.i unwind label %lpad.i147.i.i

invoke.cont.i137.i.i:                             ; preds = %det.achd.i136.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i) #7
  reattach within %syncreg.i123.i.i, label %det.cont.i141.i.i

det.cont.i141.i.i:                                ; preds = %invoke.cont.i137.i.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.split
  %b.i138.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i.i, %class.object.2* dereferenceable(1) %b.i138.i.i)
          to label %.noexc164.i.i unwind label %lpad24.i.i

.noexc164.i.i:                                    ; preds = %det.cont.i141.i.i
  %b15.i139.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i, i32 0, i32 1
  %call18.i140.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i.i, %class.object.2* %agg.tmp14.i126.i.i)
          to label %invoke.cont17.i142.i.i unwind label %lpad16.i154.i.i

invoke.cont17.i142.i.i:                           ; preds = %.noexc164.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i.i:                                    ; preds = %det.achd.i136.i.i
  %63 = landingpad { i8*, i32 }
          cleanup
  %64 = extractvalue { i8*, i32 } %63, 0
  store i8* %64, i8** %exn.slot.i133.i.i, align 8
  %65 = extractvalue { i8*, i32 } %63, 1
  store i32 %65, i32* %ehselector.slot.i134.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i) #7
  %exn.i143.i.i = load i8*, i8** %exn.slot.i133.i.i, align 8
  %sel.i144.i.i = load i32, i32* %ehselector.slot.i134.i.i, align 4
  %lpad.val.i145.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i143.i.i, 0
  %lpad.val3.i146.i.i = insertvalue { i8*, i32 } %lpad.val.i145.i.i, i32 %sel.i144.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i.i, { i8*, i32 } %lpad.val3.i146.i.i)
          to label %unreachable.i160.i.i unwind label %lpad4.i152.i.i

lpad4.i152.i.i:                                   ; preds = %lpad.i147.i.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.split
  %66 = landingpad { i8*, i32 }
          cleanup
  %67 = extractvalue { i8*, i32 } %66, 0
  store i8* %67, i8** %exn.slot5.i129.i.i, align 8
  %68 = extractvalue { i8*, i32 } %66, 1
  store i32 %68, i32* %ehselector.slot6.i130.i.i, align 4
  %exn7.i148.i.i = load i8*, i8** %exn.slot5.i129.i.i, align 8
  %sel8.i149.i.i = load i32, i32* %ehselector.slot6.i130.i.i, align 4
  %lpad.val9.i150.i.i = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i.i, 0
  %lpad.val10.i151.i.i = insertvalue { i8*, i32 } %lpad.val9.i150.i.i, i32 %sel8.i149.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %62, { i8*, i32 } %lpad.val10.i151.i.i)
          to label %unreachable.i160.i.i unwind label %lpad11.i153.i.i

lpad11.i153.i.i:                                  ; preds = %lpad4.i152.i.i
  %69 = landingpad { i8*, i32 }
          cleanup
  %70 = extractvalue { i8*, i32 } %69, 0
  store i8* %70, i8** %exn.slot12.i124.i.i, align 8
  %71 = extractvalue { i8*, i32 } %69, 1
  store i32 %71, i32* %ehselector.slot13.i125.i.i, align 4
  br label %eh.resume.i159.i.i

lpad16.i154.i.i:                                  ; preds = %.noexc164.i.i
  %72 = landingpad { i8*, i32 }
          cleanup
  %73 = extractvalue { i8*, i32 } %72, 0
  store i8* %73, i8** %exn.slot12.i124.i.i, align 8
  %74 = extractvalue { i8*, i32 } %72, 1
  store i32 %74, i32* %ehselector.slot13.i125.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i) #7
  br label %eh.resume.i159.i.i

eh.resume.i159.i.i:                               ; preds = %lpad16.i154.i.i, %lpad11.i153.i.i
  %exn19.i155.i.i = load i8*, i8** %exn.slot12.i124.i.i, align 8
  %sel20.i156.i.i = load i32, i32* %ehselector.slot13.i125.i.i, align 4
  %lpad.val21.i157.i.i = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i.i, 0
  %lpad.val22.i158.i.i = insertvalue { i8*, i32 } %lpad.val21.i157.i.i, i32 %sel20.i156.i.i, 1
  br label %lpad24.body.i.i

unreachable.i160.i.i:                             ; preds = %lpad4.i152.i.i, %lpad.i147.i.i
  unreachable

lpad.i.i:                                         ; preds = %.noexc.i
  %75 = landingpad { i8*, i32 }
          cleanup
  %76 = extractvalue { i8*, i32 } %75, 0
  store i8* %76, i8** %exn.slot.i.i, align 8
  %77 = extractvalue { i8*, i32 } %75, 1
  store i32 %77, i32* %ehselector.slot.i.i, align 4
  br label %ehcleanup29.i.i

lpad4.i.i:                                        ; preds = %sync.continue.i.i.i, %det.achd.i.i
  %78 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i.i

lpad4.body.i.i:                                   ; preds = %lpad4.i.i, %ehcleanup29.i.i.i
  %eh.lpad-body.i.i = phi { i8*, i32 } [ %78, %lpad4.i.i ], [ %lpad.val33.i.i.i, %ehcleanup29.i.i.i ]
  %79 = extractvalue { i8*, i32 } %eh.lpad-body.i.i, 0
  store i8* %79, i8** %exn.slot5.i.i, align 8
  %80 = extractvalue { i8*, i32 } %eh.lpad-body.i.i, 1
  store i32 %80, i32* %ehselector.slot6.i.i, align 4
  br label %ehcleanup.i.i

lpad8.i.i:                                        ; preds = %det.cont.i52.i.i
  %81 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i.i

lpad8.body.i.i:                                   ; preds = %lpad8.i.i, %eh.resume.i.i.i
  %eh.lpad-body64.i.i = phi { i8*, i32 } [ %81, %lpad8.i.i ], [ %lpad.val22.i.i.i, %eh.resume.i.i.i ]
  %82 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i, 0
  store i8* %82, i8** %exn.slot5.i.i, align 8
  %83 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i, 1
  store i32 %83, i32* %ehselector.slot6.i.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i.i) #7
  br label %ehcleanup.i.i

ehcleanup.i.i:                                    ; preds = %lpad8.body.i.i, %lpad4.body.i.i
  %exn.i.i = load i8*, i8** %exn.slot5.i.i, align 8
  %sel.i.i = load i32, i32* %ehselector.slot6.i.i, align 4
  %lpad.val.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i, 0
  %lpad.val10.i.i = insertvalue { i8*, i32 } %lpad.val.i.i, i32 %sel.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i, { i8*, i32 } %lpad.val10.i.i)
          to label %unreachable.i.i unwind label %lpad11.i.i

lpad11.i.i:                                       ; preds = %ehcleanup.i.i, %invoke.cont.i.i.split
  %84 = landingpad { i8*, i32 }
          cleanup
  %85 = extractvalue { i8*, i32 } %84, 0
  store i8* %85, i8** %exn.slot12.i.i, align 8
  %86 = extractvalue { i8*, i32 } %84, 1
  store i32 %86, i32* %ehselector.slot13.i.i, align 4
  %exn15.i.i = load i8*, i8** %exn.slot12.i.i, align 8
  %sel16.i.i = load i32, i32* %ehselector.slot13.i.i, align 4
  %lpad.val17.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i, 0
  %lpad.val18.i.i = insertvalue { i8*, i32 } %lpad.val17.i.i, i32 %sel16.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %4, { i8*, i32 } %lpad.val18.i.i)
          to label %unreachable.i.i unwind label %lpad19.i.i

lpad19.i.i:                                       ; preds = %lpad11.i.i, %sync.continue.i92.i.i, %det.cont.i.i
  %87 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i.i

lpad19.body.i.i:                                  ; preds = %lpad19.i.i, %ehcleanup29.i109.i.i
  %eh.lpad-body118.i.i = phi { i8*, i32 } [ %87, %lpad19.i.i ], [ %lpad.val33.i113.i.i, %ehcleanup29.i109.i.i ]
  %88 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i, 0
  store i8* %88, i8** %exn.slot.i.i, align 8
  %89 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i, 1
  store i32 %89, i32* %ehselector.slot.i.i, align 4
  br label %ehcleanup28.i.i

lpad24.i.i:                                       ; preds = %det.cont.i141.i.i
  %90 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i.i

lpad24.body.i.i:                                  ; preds = %lpad24.i.i, %eh.resume.i159.i.i
  %eh.lpad-body165.i.i = phi { i8*, i32 } [ %90, %lpad24.i.i ], [ %lpad.val22.i158.i.i, %eh.resume.i159.i.i ]
  %91 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i, 0
  store i8* %91, i8** %exn.slot.i.i, align 8
  %92 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i, 1
  store i32 %92, i32* %ehselector.slot.i.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i.i) #7
  br label %ehcleanup28.i.i

ehcleanup28.i.i:                                  ; preds = %lpad24.body.i.i, %lpad19.body.i.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i.i) #7
  br label %ehcleanup29.i.i

ehcleanup29.i.i:                                  ; preds = %ehcleanup28.i.i, %lpad.i.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i.i) #7
  %exn30.i.i = load i8*, i8** %exn.slot.i.i, align 8
  %sel31.i.i = load i32, i32* %ehselector.slot.i.i, align 4
  %lpad.val32.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i, 0
  %lpad.val33.i.i = insertvalue { i8*, i32 } %lpad.val32.i.i, i32 %sel31.i.i, 1
  br label %lpad4.body.i

unreachable.i.i:                                  ; preds = %lpad11.i.i, %ehcleanup.i.i
  unreachable

det.cont.i:                                       ; preds = %invoke.cont.i.split
  %93 = load %class.object*, %class.object** %other.addr.i, align 8
  %b21.i = getelementptr inbounds %class.object, %class.object* %93, i32 0, i32 1
  %savedstack373.i = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp20.i, %class.object.0** %this.addr.i147.i, align 8
  store %class.object.0* %b21.i, %class.object.0** %other.addr.i148.i, align 8
  %this1.i153.i = load %class.object.0*, %class.object.0** %this.addr.i147.i, align 8
  %a.i154.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i154.i)
          to label %.noexc374.i unwind label %lpad19.i

.noexc374.i:                                      ; preds = %det.cont.i
  %b.i155.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i155.i)
          to label %invoke.cont.i156.i unwind label %lpad.i342.i

invoke.cont.i156.i:                               ; preds = %.noexc374.i
  br label %invoke.cont.i156.i.split

invoke.cont.i156.i.split:                         ; preds = %invoke.cont.i156.i
  %94 = call token @llvm.taskframe.create()
  %agg.tmp.i157.i = alloca %class.object.1, align 1
  %exn.slot12.i158.i = alloca i8*
  %ehselector.slot13.i159.i = alloca i32
  %a2.i160.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i, i32 0, i32 0
  %95 = load %class.object.0*, %class.object.0** %other.addr.i148.i, align 8
  %a3.i161.i = getelementptr inbounds %class.object.0, %class.object.0* %95, i32 0, i32 0
  detach within %syncreg.i151.i, label %det.achd.i181.i, label %det.cont.i263.i unwind label %lpad11.i354.i

det.achd.i181.i:                                  ; preds = %invoke.cont.i156.i.split
  %this.addr.i36.i162.i = alloca %class.object.1*, align 8
  %exn.slot12.i38.i163.i = alloca i8*
  %ehselector.slot13.i39.i164.i = alloca i32
  %agg.tmp14.i.i165.i = alloca %class.object.2, align 1
  %agg.tmp.i41.i166.i = alloca %class.object.2, align 1
  %exn.slot5.i42.i167.i = alloca i8*
  %ehselector.slot6.i43.i168.i = alloca i32
  %syncreg.i37.i169.i = call token @llvm.syncregion.start()
  %this.addr.i.i170.i = alloca %class.object.1*, align 8
  %other.addr.i.i171.i = alloca %class.object.1*, align 8
  %exn.slot.i.i172.i = alloca i8*
  %ehselector.slot.i.i173.i = alloca i32
  %agg.tmp20.i.i174.i = alloca %class.object.2, align 1
  %syncreg.i.i175.i = call token @llvm.syncregion.start()
  %exn.slot5.i176.i = alloca i8*
  %ehselector.slot6.i177.i = alloca i32
  call void @llvm.taskframe.use(token %94)
  %savedstack.i178.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i157.i, %class.object.1** %this.addr.i.i170.i, align 8
  store %class.object.1* %a3.i161.i, %class.object.1** %other.addr.i.i171.i, align 8
  %this1.i.i179.i = load %class.object.1*, %class.object.1** %this.addr.i.i170.i, align 8
  %a.i.i180.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i180.i)
          to label %.noexc.i183.i unwind label %lpad4.i343.i

.noexc.i183.i:                                    ; preds = %det.achd.i181.i
  %b.i.i182.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i182.i)
          to label %invoke.cont.i.i184.i unwind label %lpad.i.i203.i

invoke.cont.i.i184.i:                             ; preds = %.noexc.i183.i
  br label %invoke.cont.i.i184.i.split

invoke.cont.i.i184.i.split:                       ; preds = %invoke.cont.i.i184.i
  %96 = call token @llvm.taskframe.create()
  %agg.tmp.i.i185.i = alloca %class.object.2, align 1
  %exn.slot12.i.i186.i = alloca i8*
  %ehselector.slot13.i.i187.i = alloca i32
  %a2.i.i188.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i, i32 0, i32 0
  %97 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i, align 8
  %a3.i.i189.i = getelementptr inbounds %class.object.1, %class.object.1* %97, i32 0, i32 0
  detach within %syncreg.i.i175.i, label %det.achd.i.i192.i, label %det.cont.i.i197.i unwind label %lpad11.i.i215.i

det.achd.i.i192.i:                                ; preds = %invoke.cont.i.i184.i.split
  %exn.slot5.i.i190.i = alloca i8*
  %ehselector.slot6.i.i191.i = alloca i32
  call void @llvm.taskframe.use(token %96)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i185.i, %class.object.2* dereferenceable(1) %a3.i.i189.i)
          to label %invoke.cont7.i.i194.i unwind label %lpad4.i.i204.i

invoke.cont7.i.i194.i:                            ; preds = %det.achd.i.i192.i
  %call.i.i193.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i188.i, %class.object.2* %agg.tmp.i.i185.i)
          to label %invoke.cont9.i.i195.i unwind label %lpad8.i.i205.i

invoke.cont9.i.i195.i:                            ; preds = %invoke.cont7.i.i194.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i) #7
  reattach within %syncreg.i.i175.i, label %det.cont.i.i197.i

det.cont.i.i197.i:                                ; preds = %invoke.cont9.i.i195.i, %invoke.cont.i.i184.i.split
  %98 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i, align 8
  %b21.i.i196.i = getelementptr inbounds %class.object.1, %class.object.1* %98, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i174.i, %class.object.2* dereferenceable(1) %b21.i.i196.i)
          to label %invoke.cont22.i.i200.i unwind label %lpad19.i.i216.i

invoke.cont22.i.i200.i:                           ; preds = %det.cont.i.i197.i
  %b23.i.i198.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i, i32 0, i32 1
  %call26.i.i199.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i198.i, %class.object.2* %agg.tmp20.i.i174.i)
          to label %invoke.cont25.i.i201.i unwind label %lpad24.i.i217.i

invoke.cont25.i.i201.i:                           ; preds = %invoke.cont22.i.i200.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i) #7
  sync within %syncreg.i.i175.i, label %sync.continue.i.i202.i

sync.continue.i.i202.i:                           ; preds = %invoke.cont25.i.i201.i
  invoke void @llvm.sync.unwind(token %syncreg.i.i175.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i unwind label %lpad4.i343.i

lpad.i.i203.i:                                    ; preds = %.noexc.i183.i
  %99 = landingpad { i8*, i32 }
          cleanup
  %100 = extractvalue { i8*, i32 } %99, 0
  store i8* %100, i8** %exn.slot.i.i172.i, align 8
  %101 = extractvalue { i8*, i32 } %99, 1
  store i32 %101, i32* %ehselector.slot.i.i173.i, align 4
  br label %ehcleanup29.i.i223.i

lpad4.i.i204.i:                                   ; preds = %det.achd.i.i192.i
  %102 = landingpad { i8*, i32 }
          cleanup
  %103 = extractvalue { i8*, i32 } %102, 0
  store i8* %103, i8** %exn.slot5.i.i190.i, align 8
  %104 = extractvalue { i8*, i32 } %102, 1
  store i32 %104, i32* %ehselector.slot6.i.i191.i, align 4
  br label %ehcleanup.i.i210.i

lpad8.i.i205.i:                                   ; preds = %invoke.cont7.i.i194.i
  %105 = landingpad { i8*, i32 }
          cleanup
  %106 = extractvalue { i8*, i32 } %105, 0
  store i8* %106, i8** %exn.slot5.i.i190.i, align 8
  %107 = extractvalue { i8*, i32 } %105, 1
  store i32 %107, i32* %ehselector.slot6.i.i191.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i) #7
  br label %ehcleanup.i.i210.i

ehcleanup.i.i210.i:                               ; preds = %lpad8.i.i205.i, %lpad4.i.i204.i
  %exn.i.i206.i = load i8*, i8** %exn.slot5.i.i190.i, align 8
  %sel.i.i207.i = load i32, i32* %ehselector.slot6.i.i191.i, align 4
  %lpad.val.i.i208.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i206.i, 0
  %lpad.val10.i.i209.i = insertvalue { i8*, i32 } %lpad.val.i.i208.i, i32 %sel.i.i207.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i175.i, { i8*, i32 } %lpad.val10.i.i209.i)
          to label %unreachable.i.i224.i unwind label %lpad11.i.i215.i

lpad11.i.i215.i:                                  ; preds = %ehcleanup.i.i210.i, %invoke.cont.i.i184.i.split
  %108 = landingpad { i8*, i32 }
          cleanup
  %109 = extractvalue { i8*, i32 } %108, 0
  store i8* %109, i8** %exn.slot12.i.i186.i, align 8
  %110 = extractvalue { i8*, i32 } %108, 1
  store i32 %110, i32* %ehselector.slot13.i.i187.i, align 4
  %exn15.i.i211.i = load i8*, i8** %exn.slot12.i.i186.i, align 8
  %sel16.i.i212.i = load i32, i32* %ehselector.slot13.i.i187.i, align 4
  %lpad.val17.i.i213.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i211.i, 0
  %lpad.val18.i.i214.i = insertvalue { i8*, i32 } %lpad.val17.i.i213.i, i32 %sel16.i.i212.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %96, { i8*, i32 } %lpad.val18.i.i214.i)
          to label %unreachable.i.i224.i unwind label %lpad19.i.i216.i

lpad19.i.i216.i:                                  ; preds = %lpad11.i.i215.i, %det.cont.i.i197.i
  %111 = landingpad { i8*, i32 }
          cleanup
  %112 = extractvalue { i8*, i32 } %111, 0
  store i8* %112, i8** %exn.slot.i.i172.i, align 8
  %113 = extractvalue { i8*, i32 } %111, 1
  store i32 %113, i32* %ehselector.slot.i.i173.i, align 4
  br label %ehcleanup28.i.i218.i

lpad24.i.i217.i:                                  ; preds = %invoke.cont22.i.i200.i
  %114 = landingpad { i8*, i32 }
          cleanup
  %115 = extractvalue { i8*, i32 } %114, 0
  store i8* %115, i8** %exn.slot.i.i172.i, align 8
  %116 = extractvalue { i8*, i32 } %114, 1
  store i32 %116, i32* %ehselector.slot.i.i173.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i) #7
  br label %ehcleanup28.i.i218.i

ehcleanup28.i.i218.i:                             ; preds = %lpad24.i.i217.i, %lpad19.i.i216.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i182.i) #7
  br label %ehcleanup29.i.i223.i

ehcleanup29.i.i223.i:                             ; preds = %ehcleanup28.i.i218.i, %lpad.i.i203.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i180.i) #7
  %exn30.i.i219.i = load i8*, i8** %exn.slot.i.i172.i, align 8
  %sel31.i.i220.i = load i32, i32* %ehselector.slot.i.i173.i, align 4
  %lpad.val32.i.i221.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i219.i, 0
  %lpad.val33.i.i222.i = insertvalue { i8*, i32 } %lpad.val32.i.i221.i, i32 %sel31.i.i220.i, 1
  br label %lpad4.body.i345.i

unreachable.i.i224.i:                             ; preds = %lpad11.i.i215.i, %ehcleanup.i.i210.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i225.i:             ; preds = %sync.continue.i.i202.i
  call void @llvm.stackrestore(i8* %savedstack.i178.i)
  %savedstack61.i226.i = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i160.i, %class.object.1** %this.addr.i36.i162.i, align 8
  %this1.i40.i227.i = load %class.object.1*, %class.object.1** %this.addr.i36.i162.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.split

_ZN6objectILi1EEC2ERKS0_.exit.i225.i.split:       ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i
  %117 = call token @llvm.taskframe.create()
  %a.i44.i228.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i, i32 0, i32 0
  %a2.i45.i229.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i, i32 0, i32 0
  detach within %syncreg.i37.i169.i, label %det.achd.i49.i233.i, label %det.cont.i52.i236.i unwind label %lpad4.i58.i250.i

det.achd.i49.i233.i:                              ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.split
  %exn.slot.i46.i230.i = alloca i8*
  %ehselector.slot.i47.i231.i = alloca i32
  call void @llvm.taskframe.use(token %117)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i166.i, %class.object.2* dereferenceable(1) %a2.i45.i229.i)
  %call.i48.i232.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i228.i, %class.object.2* %agg.tmp.i41.i166.i)
          to label %invoke.cont.i50.i234.i unwind label %lpad.i56.i245.i

invoke.cont.i50.i234.i:                           ; preds = %det.achd.i49.i233.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i) #7
  reattach within %syncreg.i37.i169.i, label %det.cont.i52.i236.i

det.cont.i52.i236.i:                              ; preds = %invoke.cont.i50.i234.i, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.split
  %b.i51.i235.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i165.i, %class.object.2* dereferenceable(1) %b.i51.i235.i)
          to label %.noexc63.i239.i unwind label %lpad8.i346.i

.noexc63.i239.i:                                  ; preds = %det.cont.i52.i236.i
  %b15.i.i237.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i, i32 0, i32 1
  %call18.i.i238.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i237.i, %class.object.2* %agg.tmp14.i.i165.i)
          to label %invoke.cont17.i.i240.i unwind label %lpad16.i.i252.i

invoke.cont17.i.i240.i:                           ; preds = %.noexc63.i239.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i245.i:                                  ; preds = %det.achd.i49.i233.i
  %118 = landingpad { i8*, i32 }
          cleanup
  %119 = extractvalue { i8*, i32 } %118, 0
  store i8* %119, i8** %exn.slot.i46.i230.i, align 8
  %120 = extractvalue { i8*, i32 } %118, 1
  store i32 %120, i32* %ehselector.slot.i47.i231.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i) #7
  %exn.i53.i241.i = load i8*, i8** %exn.slot.i46.i230.i, align 8
  %sel.i54.i242.i = load i32, i32* %ehselector.slot.i47.i231.i, align 4
  %lpad.val.i55.i243.i = insertvalue { i8*, i32 } undef, i8* %exn.i53.i241.i, 0
  %lpad.val3.i.i244.i = insertvalue { i8*, i32 } %lpad.val.i55.i243.i, i32 %sel.i54.i242.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i169.i, { i8*, i32 } %lpad.val3.i.i244.i)
          to label %unreachable.i60.i258.i unwind label %lpad4.i58.i250.i

lpad4.i58.i250.i:                                 ; preds = %lpad.i56.i245.i, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.split
  %121 = landingpad { i8*, i32 }
          cleanup
  %122 = extractvalue { i8*, i32 } %121, 0
  store i8* %122, i8** %exn.slot5.i42.i167.i, align 8
  %123 = extractvalue { i8*, i32 } %121, 1
  store i32 %123, i32* %ehselector.slot6.i43.i168.i, align 4
  %exn7.i.i246.i = load i8*, i8** %exn.slot5.i42.i167.i, align 8
  %sel8.i.i247.i = load i32, i32* %ehselector.slot6.i43.i168.i, align 4
  %lpad.val9.i.i248.i = insertvalue { i8*, i32 } undef, i8* %exn7.i.i246.i, 0
  %lpad.val10.i57.i249.i = insertvalue { i8*, i32 } %lpad.val9.i.i248.i, i32 %sel8.i.i247.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %117, { i8*, i32 } %lpad.val10.i57.i249.i)
          to label %unreachable.i60.i258.i unwind label %lpad11.i59.i251.i

lpad11.i59.i251.i:                                ; preds = %lpad4.i58.i250.i
  %124 = landingpad { i8*, i32 }
          cleanup
  %125 = extractvalue { i8*, i32 } %124, 0
  store i8* %125, i8** %exn.slot12.i38.i163.i, align 8
  %126 = extractvalue { i8*, i32 } %124, 1
  store i32 %126, i32* %ehselector.slot13.i39.i164.i, align 4
  br label %eh.resume.i.i257.i

lpad16.i.i252.i:                                  ; preds = %.noexc63.i239.i
  %127 = landingpad { i8*, i32 }
          cleanup
  %128 = extractvalue { i8*, i32 } %127, 0
  store i8* %128, i8** %exn.slot12.i38.i163.i, align 8
  %129 = extractvalue { i8*, i32 } %127, 1
  store i32 %129, i32* %ehselector.slot13.i39.i164.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i) #7
  br label %eh.resume.i.i257.i

eh.resume.i.i257.i:                               ; preds = %lpad16.i.i252.i, %lpad11.i59.i251.i
  %exn19.i.i253.i = load i8*, i8** %exn.slot12.i38.i163.i, align 8
  %sel20.i.i254.i = load i32, i32* %ehselector.slot13.i39.i164.i, align 4
  %lpad.val21.i.i255.i = insertvalue { i8*, i32 } undef, i8* %exn19.i.i253.i, 0
  %lpad.val22.i.i256.i = insertvalue { i8*, i32 } %lpad.val21.i.i255.i, i32 %sel20.i.i254.i, 1
  br label %lpad8.body.i348.i

unreachable.i60.i258.i:                           ; preds = %lpad4.i58.i250.i, %lpad.i56.i245.i
  unreachable

det.cont.i263.i:                                  ; preds = %invoke.cont.i156.i.split
  %130 = load %class.object.0*, %class.object.0** %other.addr.i148.i, align 8
  %b21.i259.i = getelementptr inbounds %class.object.0, %class.object.0* %130, i32 0, i32 1
  %savedstack116.i260.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i152.i, %class.object.1** %this.addr.i65.i141.i, align 8
  store %class.object.1* %b21.i259.i, %class.object.1** %other.addr.i66.i142.i, align 8
  %this1.i71.i261.i = load %class.object.1*, %class.object.1** %this.addr.i65.i141.i, align 8
  %a.i72.i262.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i262.i)
          to label %.noexc117.i265.i unwind label %lpad19.i359.i

.noexc117.i265.i:                                 ; preds = %det.cont.i263.i
  %b.i73.i264.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i264.i)
          to label %invoke.cont.i79.i266.i unwind label %lpad.i93.i285.i

invoke.cont.i79.i266.i:                           ; preds = %.noexc117.i265.i
  br label %invoke.cont.i79.i266.i.split

invoke.cont.i79.i266.i.split:                     ; preds = %invoke.cont.i79.i266.i
  %131 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i267.i = alloca %class.object.2, align 1
  %exn.slot12.i75.i268.i = alloca i8*
  %ehselector.slot13.i76.i269.i = alloca i32
  %a2.i77.i270.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i, i32 0, i32 0
  %132 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i, align 8
  %a3.i78.i271.i = getelementptr inbounds %class.object.1, %class.object.1* %132, i32 0, i32 0
  detach within %syncreg.i69.i146.i, label %det.achd.i82.i274.i, label %det.cont.i87.i279.i unwind label %lpad11.i101.i297.i

det.achd.i82.i274.i:                              ; preds = %invoke.cont.i79.i266.i.split
  %exn.slot5.i80.i272.i = alloca i8*
  %ehselector.slot6.i81.i273.i = alloca i32
  call void @llvm.taskframe.use(token %131)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i267.i, %class.object.2* dereferenceable(1) %a3.i78.i271.i)
          to label %invoke.cont7.i84.i276.i unwind label %lpad4.i94.i286.i

invoke.cont7.i84.i276.i:                          ; preds = %det.achd.i82.i274.i
  %call.i83.i275.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i270.i, %class.object.2* %agg.tmp.i74.i267.i)
          to label %invoke.cont9.i85.i277.i unwind label %lpad8.i95.i287.i

invoke.cont9.i85.i277.i:                          ; preds = %invoke.cont7.i84.i276.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i) #7
  reattach within %syncreg.i69.i146.i, label %det.cont.i87.i279.i

det.cont.i87.i279.i:                              ; preds = %invoke.cont9.i85.i277.i, %invoke.cont.i79.i266.i.split
  %133 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i, align 8
  %b21.i86.i278.i = getelementptr inbounds %class.object.1, %class.object.1* %133, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i145.i, %class.object.2* dereferenceable(1) %b21.i86.i278.i)
          to label %invoke.cont22.i90.i282.i unwind label %lpad19.i106.i298.i

invoke.cont22.i90.i282.i:                         ; preds = %det.cont.i87.i279.i
  %b23.i88.i280.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i, i32 0, i32 1
  %call26.i89.i281.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i280.i, %class.object.2* %agg.tmp20.i70.i145.i)
          to label %invoke.cont25.i91.i283.i unwind label %lpad24.i107.i299.i

invoke.cont25.i91.i283.i:                         ; preds = %invoke.cont22.i90.i282.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i) #7
  sync within %syncreg.i69.i146.i, label %sync.continue.i92.i284.i

sync.continue.i92.i284.i:                         ; preds = %invoke.cont25.i91.i283.i
  invoke void @llvm.sync.unwind(token %syncreg.i69.i146.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i unwind label %lpad19.i359.i

lpad.i93.i285.i:                                  ; preds = %.noexc117.i265.i
  %134 = landingpad { i8*, i32 }
          cleanup
  %135 = extractvalue { i8*, i32 } %134, 0
  store i8* %135, i8** %exn.slot.i67.i143.i, align 8
  %136 = extractvalue { i8*, i32 } %134, 1
  store i32 %136, i32* %ehselector.slot.i68.i144.i, align 4
  br label %ehcleanup29.i109.i305.i

lpad4.i94.i286.i:                                 ; preds = %det.achd.i82.i274.i
  %137 = landingpad { i8*, i32 }
          cleanup
  %138 = extractvalue { i8*, i32 } %137, 0
  store i8* %138, i8** %exn.slot5.i80.i272.i, align 8
  %139 = extractvalue { i8*, i32 } %137, 1
  store i32 %139, i32* %ehselector.slot6.i81.i273.i, align 4
  br label %ehcleanup.i100.i292.i

lpad8.i95.i287.i:                                 ; preds = %invoke.cont7.i84.i276.i
  %140 = landingpad { i8*, i32 }
          cleanup
  %141 = extractvalue { i8*, i32 } %140, 0
  store i8* %141, i8** %exn.slot5.i80.i272.i, align 8
  %142 = extractvalue { i8*, i32 } %140, 1
  store i32 %142, i32* %ehselector.slot6.i81.i273.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i) #7
  br label %ehcleanup.i100.i292.i

ehcleanup.i100.i292.i:                            ; preds = %lpad8.i95.i287.i, %lpad4.i94.i286.i
  %exn.i96.i288.i = load i8*, i8** %exn.slot5.i80.i272.i, align 8
  %sel.i97.i289.i = load i32, i32* %ehselector.slot6.i81.i273.i, align 4
  %lpad.val.i98.i290.i = insertvalue { i8*, i32 } undef, i8* %exn.i96.i288.i, 0
  %lpad.val10.i99.i291.i = insertvalue { i8*, i32 } %lpad.val.i98.i290.i, i32 %sel.i97.i289.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i146.i, { i8*, i32 } %lpad.val10.i99.i291.i)
          to label %unreachable.i115.i306.i unwind label %lpad11.i101.i297.i

lpad11.i101.i297.i:                               ; preds = %ehcleanup.i100.i292.i, %invoke.cont.i79.i266.i.split
  %143 = landingpad { i8*, i32 }
          cleanup
  %144 = extractvalue { i8*, i32 } %143, 0
  store i8* %144, i8** %exn.slot12.i75.i268.i, align 8
  %145 = extractvalue { i8*, i32 } %143, 1
  store i32 %145, i32* %ehselector.slot13.i76.i269.i, align 4
  %exn15.i102.i293.i = load i8*, i8** %exn.slot12.i75.i268.i, align 8
  %sel16.i103.i294.i = load i32, i32* %ehselector.slot13.i76.i269.i, align 4
  %lpad.val17.i104.i295.i = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i293.i, 0
  %lpad.val18.i105.i296.i = insertvalue { i8*, i32 } %lpad.val17.i104.i295.i, i32 %sel16.i103.i294.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %131, { i8*, i32 } %lpad.val18.i105.i296.i)
          to label %unreachable.i115.i306.i unwind label %lpad19.i106.i298.i

lpad19.i106.i298.i:                               ; preds = %lpad11.i101.i297.i, %det.cont.i87.i279.i
  %146 = landingpad { i8*, i32 }
          cleanup
  %147 = extractvalue { i8*, i32 } %146, 0
  store i8* %147, i8** %exn.slot.i67.i143.i, align 8
  %148 = extractvalue { i8*, i32 } %146, 1
  store i32 %148, i32* %ehselector.slot.i68.i144.i, align 4
  br label %ehcleanup28.i108.i300.i

lpad24.i107.i299.i:                               ; preds = %invoke.cont22.i90.i282.i
  %149 = landingpad { i8*, i32 }
          cleanup
  %150 = extractvalue { i8*, i32 } %149, 0
  store i8* %150, i8** %exn.slot.i67.i143.i, align 8
  %151 = extractvalue { i8*, i32 } %149, 1
  store i32 %151, i32* %ehselector.slot.i68.i144.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i) #7
  br label %ehcleanup28.i108.i300.i

ehcleanup28.i108.i300.i:                          ; preds = %lpad24.i107.i299.i, %lpad19.i106.i298.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i264.i) #7
  br label %ehcleanup29.i109.i305.i

ehcleanup29.i109.i305.i:                          ; preds = %ehcleanup28.i108.i300.i, %lpad.i93.i285.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i262.i) #7
  %exn30.i110.i301.i = load i8*, i8** %exn.slot.i67.i143.i, align 8
  %sel31.i111.i302.i = load i32, i32* %ehselector.slot.i68.i144.i, align 4
  %lpad.val32.i112.i303.i = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i301.i, 0
  %lpad.val33.i113.i304.i = insertvalue { i8*, i32 } %lpad.val32.i112.i303.i, i32 %sel31.i111.i302.i, 1
  br label %lpad19.body.i361.i

unreachable.i115.i306.i:                          ; preds = %lpad11.i101.i297.i, %ehcleanup.i100.i292.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i:          ; preds = %sync.continue.i92.i284.i
  call void @llvm.stackrestore(i8* %savedstack116.i260.i)
  %b23.i308.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i, i32 0, i32 1
  %savedstack161.i309.i = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i308.i, %class.object.1** %this.addr.i122.i133.i, align 8
  %this1.i127.i310.i = load %class.object.1*, %class.object.1** %this.addr.i122.i133.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.split

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.split:    ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i
  %152 = call token @llvm.taskframe.create()
  %a.i131.i311.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i, i32 0, i32 0
  %a2.i132.i312.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i, i32 0, i32 0
  detach within %syncreg.i123.i140.i, label %det.achd.i136.i316.i, label %det.cont.i141.i319.i unwind label %lpad4.i152.i333.i

det.achd.i136.i316.i:                             ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.split
  %exn.slot.i133.i313.i = alloca i8*
  %ehselector.slot.i134.i314.i = alloca i32
  call void @llvm.taskframe.use(token %152)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i137.i, %class.object.2* dereferenceable(1) %a2.i132.i312.i)
  %call.i135.i315.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i311.i, %class.object.2* %agg.tmp.i128.i137.i)
          to label %invoke.cont.i137.i317.i unwind label %lpad.i147.i328.i

invoke.cont.i137.i317.i:                          ; preds = %det.achd.i136.i316.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i) #7
  reattach within %syncreg.i123.i140.i, label %det.cont.i141.i319.i

det.cont.i141.i319.i:                             ; preds = %invoke.cont.i137.i317.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.split
  %b.i138.i318.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i136.i, %class.object.2* dereferenceable(1) %b.i138.i318.i)
          to label %.noexc164.i322.i unwind label %lpad24.i362.i

.noexc164.i322.i:                                 ; preds = %det.cont.i141.i319.i
  %b15.i139.i320.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i, i32 0, i32 1
  %call18.i140.i321.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i320.i, %class.object.2* %agg.tmp14.i126.i136.i)
          to label %invoke.cont17.i142.i323.i unwind label %lpad16.i154.i335.i

invoke.cont17.i142.i323.i:                        ; preds = %.noexc164.i322.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i328.i:                                 ; preds = %det.achd.i136.i316.i
  %153 = landingpad { i8*, i32 }
          cleanup
  %154 = extractvalue { i8*, i32 } %153, 0
  store i8* %154, i8** %exn.slot.i133.i313.i, align 8
  %155 = extractvalue { i8*, i32 } %153, 1
  store i32 %155, i32* %ehselector.slot.i134.i314.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i) #7
  %exn.i143.i324.i = load i8*, i8** %exn.slot.i133.i313.i, align 8
  %sel.i144.i325.i = load i32, i32* %ehselector.slot.i134.i314.i, align 4
  %lpad.val.i145.i326.i = insertvalue { i8*, i32 } undef, i8* %exn.i143.i324.i, 0
  %lpad.val3.i146.i327.i = insertvalue { i8*, i32 } %lpad.val.i145.i326.i, i32 %sel.i144.i325.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i140.i, { i8*, i32 } %lpad.val3.i146.i327.i)
          to label %unreachable.i160.i341.i unwind label %lpad4.i152.i333.i

lpad4.i152.i333.i:                                ; preds = %lpad.i147.i328.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.split
  %156 = landingpad { i8*, i32 }
          cleanup
  %157 = extractvalue { i8*, i32 } %156, 0
  store i8* %157, i8** %exn.slot5.i129.i138.i, align 8
  %158 = extractvalue { i8*, i32 } %156, 1
  store i32 %158, i32* %ehselector.slot6.i130.i139.i, align 4
  %exn7.i148.i329.i = load i8*, i8** %exn.slot5.i129.i138.i, align 8
  %sel8.i149.i330.i = load i32, i32* %ehselector.slot6.i130.i139.i, align 4
  %lpad.val9.i150.i331.i = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i329.i, 0
  %lpad.val10.i151.i332.i = insertvalue { i8*, i32 } %lpad.val9.i150.i331.i, i32 %sel8.i149.i330.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %152, { i8*, i32 } %lpad.val10.i151.i332.i)
          to label %unreachable.i160.i341.i unwind label %lpad11.i153.i334.i

lpad11.i153.i334.i:                               ; preds = %lpad4.i152.i333.i
  %159 = landingpad { i8*, i32 }
          cleanup
  %160 = extractvalue { i8*, i32 } %159, 0
  store i8* %160, i8** %exn.slot12.i124.i134.i, align 8
  %161 = extractvalue { i8*, i32 } %159, 1
  store i32 %161, i32* %ehselector.slot13.i125.i135.i, align 4
  br label %eh.resume.i159.i340.i

lpad16.i154.i335.i:                               ; preds = %.noexc164.i322.i
  %162 = landingpad { i8*, i32 }
          cleanup
  %163 = extractvalue { i8*, i32 } %162, 0
  store i8* %163, i8** %exn.slot12.i124.i134.i, align 8
  %164 = extractvalue { i8*, i32 } %162, 1
  store i32 %164, i32* %ehselector.slot13.i125.i135.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i) #7
  br label %eh.resume.i159.i340.i

eh.resume.i159.i340.i:                            ; preds = %lpad16.i154.i335.i, %lpad11.i153.i334.i
  %exn19.i155.i336.i = load i8*, i8** %exn.slot12.i124.i134.i, align 8
  %sel20.i156.i337.i = load i32, i32* %ehselector.slot13.i125.i135.i, align 4
  %lpad.val21.i157.i338.i = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i336.i, 0
  %lpad.val22.i158.i339.i = insertvalue { i8*, i32 } %lpad.val21.i157.i338.i, i32 %sel20.i156.i337.i, 1
  br label %lpad24.body.i364.i

unreachable.i160.i341.i:                          ; preds = %lpad4.i152.i333.i, %lpad.i147.i328.i
  unreachable

lpad.i342.i:                                      ; preds = %.noexc374.i
  %165 = landingpad { i8*, i32 }
          cleanup
  %166 = extractvalue { i8*, i32 } %165, 0
  store i8* %166, i8** %exn.slot.i149.i, align 8
  %167 = extractvalue { i8*, i32 } %165, 1
  store i32 %167, i32* %ehselector.slot.i150.i, align 4
  br label %ehcleanup29.i366.i

lpad4.i343.i:                                     ; preds = %sync.continue.i.i202.i, %det.achd.i181.i
  %168 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i345.i

lpad4.body.i345.i:                                ; preds = %lpad4.i343.i, %ehcleanup29.i.i223.i
  %eh.lpad-body.i344.i = phi { i8*, i32 } [ %168, %lpad4.i343.i ], [ %lpad.val33.i.i222.i, %ehcleanup29.i.i223.i ]
  %169 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i, 0
  store i8* %169, i8** %exn.slot5.i176.i, align 8
  %170 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i, 1
  store i32 %170, i32* %ehselector.slot6.i177.i, align 4
  br label %ehcleanup.i353.i

lpad8.i346.i:                                     ; preds = %det.cont.i52.i236.i
  %171 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i348.i

lpad8.body.i348.i:                                ; preds = %lpad8.i346.i, %eh.resume.i.i257.i
  %eh.lpad-body64.i347.i = phi { i8*, i32 } [ %171, %lpad8.i346.i ], [ %lpad.val22.i.i256.i, %eh.resume.i.i257.i ]
  %172 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i, 0
  store i8* %172, i8** %exn.slot5.i176.i, align 8
  %173 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i, 1
  store i32 %173, i32* %ehselector.slot6.i177.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i157.i) #7
  br label %ehcleanup.i353.i

ehcleanup.i353.i:                                 ; preds = %lpad8.body.i348.i, %lpad4.body.i345.i
  %exn.i349.i = load i8*, i8** %exn.slot5.i176.i, align 8
  %sel.i350.i = load i32, i32* %ehselector.slot6.i177.i, align 4
  %lpad.val.i351.i = insertvalue { i8*, i32 } undef, i8* %exn.i349.i, 0
  %lpad.val10.i352.i = insertvalue { i8*, i32 } %lpad.val.i351.i, i32 %sel.i350.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i151.i, { i8*, i32 } %lpad.val10.i352.i)
          to label %unreachable.i372.i unwind label %lpad11.i354.i

lpad11.i354.i:                                    ; preds = %ehcleanup.i353.i, %invoke.cont.i156.i.split
  %174 = landingpad { i8*, i32 }
          cleanup
  %175 = extractvalue { i8*, i32 } %174, 0
  store i8* %175, i8** %exn.slot12.i158.i, align 8
  %176 = extractvalue { i8*, i32 } %174, 1
  store i32 %176, i32* %ehselector.slot13.i159.i, align 4
  %exn15.i355.i = load i8*, i8** %exn.slot12.i158.i, align 8
  %sel16.i356.i = load i32, i32* %ehselector.slot13.i159.i, align 4
  %lpad.val17.i357.i = insertvalue { i8*, i32 } undef, i8* %exn15.i355.i, 0
  %lpad.val18.i358.i = insertvalue { i8*, i32 } %lpad.val17.i357.i, i32 %sel16.i356.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %94, { i8*, i32 } %lpad.val18.i358.i)
          to label %unreachable.i372.i unwind label %lpad19.i359.i

lpad19.i359.i:                                    ; preds = %lpad11.i354.i, %sync.continue.i92.i284.i, %det.cont.i263.i
  %177 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i361.i

lpad19.body.i361.i:                               ; preds = %lpad19.i359.i, %ehcleanup29.i109.i305.i
  %eh.lpad-body118.i360.i = phi { i8*, i32 } [ %177, %lpad19.i359.i ], [ %lpad.val33.i113.i304.i, %ehcleanup29.i109.i305.i ]
  %178 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i, 0
  store i8* %178, i8** %exn.slot.i149.i, align 8
  %179 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i, 1
  store i32 %179, i32* %ehselector.slot.i150.i, align 4
  br label %ehcleanup28.i365.i

lpad24.i362.i:                                    ; preds = %det.cont.i141.i319.i
  %180 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i364.i

lpad24.body.i364.i:                               ; preds = %lpad24.i362.i, %eh.resume.i159.i340.i
  %eh.lpad-body165.i363.i = phi { i8*, i32 } [ %180, %lpad24.i362.i ], [ %lpad.val22.i158.i339.i, %eh.resume.i159.i340.i ]
  %181 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i, 0
  store i8* %181, i8** %exn.slot.i149.i, align 8
  %182 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i, 1
  store i32 %182, i32* %ehselector.slot.i150.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i152.i) #7
  br label %ehcleanup28.i365.i

ehcleanup28.i365.i:                               ; preds = %lpad24.body.i364.i, %lpad19.body.i361.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i155.i) #7
  br label %ehcleanup29.i366.i

ehcleanup29.i366.i:                               ; preds = %ehcleanup28.i365.i, %lpad.i342.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i154.i) #7
  %exn30.i367.i = load i8*, i8** %exn.slot.i149.i, align 8
  %sel31.i368.i = load i32, i32* %ehselector.slot.i150.i, align 4
  %lpad.val32.i369.i = insertvalue { i8*, i32 } undef, i8* %exn30.i367.i, 0
  %lpad.val33.i370.i = insertvalue { i8*, i32 } %lpad.val32.i369.i, i32 %sel31.i368.i, 1
  br label %lpad19.body.i

unreachable.i372.i:                               ; preds = %lpad11.i354.i, %ehcleanup.i353.i
  unreachable

lpad.i:                                           ; preds = %.noexc
  %183 = landingpad { i8*, i32 }
          cleanup
  %184 = extractvalue { i8*, i32 } %183, 0
  store i8* %184, i8** %exn.slot.i, align 8
  %185 = extractvalue { i8*, i32 } %183, 1
  store i32 %185, i32* %ehselector.slot.i, align 4
  br label %ehcleanup29.i

lpad4.i:                                          ; preds = %det.achd.i
  %186 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i

lpad4.body.i:                                     ; preds = %lpad4.i, %ehcleanup29.i.i
  %eh.lpad-body.i = phi { i8*, i32 } [ %186, %lpad4.i ], [ %lpad.val33.i.i, %ehcleanup29.i.i ]
  %187 = extractvalue { i8*, i32 } %eh.lpad-body.i, 0
  store i8* %187, i8** %exn.slot5.i, align 8
  %188 = extractvalue { i8*, i32 } %eh.lpad-body.i, 1
  store i32 %188, i32* %ehselector.slot6.i, align 4
  %exn.i = load i8*, i8** %exn.slot5.i, align 8
  %sel.i = load i32, i32* %ehselector.slot6.i, align 4
  %lpad.val.i = insertvalue { i8*, i32 } undef, i8* %exn.i, 0
  %lpad.val10.i = insertvalue { i8*, i32 } %lpad.val.i, i32 %sel.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i, { i8*, i32 } %lpad.val10.i)
          to label %unreachable.i unwind label %lpad11.i

lpad11.i:                                         ; preds = %lpad4.body.i, %invoke.cont.i.split
  %189 = landingpad { i8*, i32 }
          cleanup
  %190 = extractvalue { i8*, i32 } %189, 0
  store i8* %190, i8** %exn.slot12.i, align 8
  %191 = extractvalue { i8*, i32 } %189, 1
  store i32 %191, i32* %ehselector.slot13.i, align 4
  %exn15.i = load i8*, i8** %exn.slot12.i, align 8
  %sel16.i = load i32, i32* %ehselector.slot13.i, align 4
  %lpad.val17.i = insertvalue { i8*, i32 } undef, i8* %exn15.i, 0
  %lpad.val18.i = insertvalue { i8*, i32 } %lpad.val17.i, i32 %sel16.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %2, { i8*, i32 } %lpad.val18.i)
          to label %unreachable.i unwind label %lpad19.i

lpad19.i:                                         ; preds = %lpad11.i, %det.cont.i
  %192 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i

lpad19.body.i:                                    ; preds = %lpad19.i, %ehcleanup29.i366.i
  %eh.lpad-body375.i = phi { i8*, i32 } [ %192, %lpad19.i ], [ %lpad.val33.i370.i, %ehcleanup29.i366.i ]
  %193 = extractvalue { i8*, i32 } %eh.lpad-body375.i, 0
  store i8* %193, i8** %exn.slot.i, align 8
  %194 = extractvalue { i8*, i32 } %eh.lpad-body375.i, 1
  store i32 %194, i32* %ehselector.slot.i, align 4
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %b.i) #7
  br label %ehcleanup29.i

ehcleanup29.i:                                    ; preds = %lpad19.body.i, %lpad.i
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %a.i) #7
  %exn30.i = load i8*, i8** %exn.slot.i, align 8
  %sel31.i = load i32, i32* %ehselector.slot.i, align 4
  %lpad.val32.i = insertvalue { i8*, i32 } undef, i8* %exn30.i, 0
  %lpad.val33.i = insertvalue { i8*, i32 } %lpad.val32.i, i32 %sel31.i, 1
  br label %lpad.body

unreachable.i:                                    ; preds = %lpad11.i, %lpad4.body.i
  unreachable

_ZN6objectILi3EEC2ERKS0_.exit:                    ; No predecessors!
  br label %invoke.cont

invoke.cont:                                      ; preds = %_ZN6objectILi3EEC2ERKS0_.exit
  %195 = load i64, i64* %x.addr, align 8
  %196 = load i64, i64* %i, align 8
  %add = add nsw i64 %195, %196
  %197 = load i64, i64* %x.addr, align 8
  %198 = load i64, i64* %i, align 8
  %call = invoke i64 @_Z3addll(i64 %197, i64 %198)
          to label %invoke.cont2 unwind label %lpad1

invoke.cont2:                                     ; preds = %invoke.cont
  %savedstack559 = call i8* @llvm.stacksave()
  store %class.object* %agg.tmp3, %class.object** %this.addr.i55, align 8
  store %class.object* %obj, %class.object** %other.addr.i56, align 8
  %this1.i61 = load %class.object*, %class.object** %this.addr.i55, align 8
  %a.i62 = getelementptr inbounds %class.object, %class.object* %this1.i61, i32 0, i32 0
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %a.i62)
          to label %.noexc560 unwind label %lpad1

.noexc560:                                        ; preds = %invoke.cont2
  %b.i63 = getelementptr inbounds %class.object, %class.object* %this1.i61, i32 0, i32 1
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %b.i63)
          to label %invoke.cont.i64 unwind label %lpad.i537

invoke.cont.i64:                                  ; preds = %.noexc560
  %199 = call token @llvm.taskframe.create()
  %agg.tmp.i65 = alloca %class.object.0, align 1
  %exn.slot12.i66 = alloca i8*
  %ehselector.slot13.i67 = alloca i32
  %a2.i68 = getelementptr inbounds %class.object, %class.object* %this1.i61, i32 0, i32 0
  %200 = load %class.object*, %class.object** %other.addr.i56, align 8
  %a3.i69 = getelementptr inbounds %class.object, %class.object* %200, i32 0, i32 0
  detach within %syncreg.i59, label %det.achd.i95, label %det.cont.i318 unwind label %lpad11.i545

det.achd.i95:                                     ; preds = %invoke.cont.i64
  %this.addr.i122.i.i70 = alloca %class.object.1*, align 8
  %exn.slot12.i124.i.i71 = alloca i8*
  %ehselector.slot13.i125.i.i72 = alloca i32
  %agg.tmp14.i126.i.i73 = alloca %class.object.2, align 1
  %agg.tmp.i128.i.i74 = alloca %class.object.2, align 1
  %exn.slot5.i129.i.i75 = alloca i8*
  %ehselector.slot6.i130.i.i76 = alloca i32
  %this.addr.i65.i.i77 = alloca %class.object.1*, align 8
  %other.addr.i66.i.i78 = alloca %class.object.1*, align 8
  %exn.slot.i67.i.i79 = alloca i8*
  %ehselector.slot.i68.i.i80 = alloca i32
  %agg.tmp20.i70.i.i81 = alloca %class.object.2, align 1
  %this.addr.i.i82 = alloca %class.object.0*, align 8
  %other.addr.i.i83 = alloca %class.object.0*, align 8
  %exn.slot.i.i84 = alloca i8*
  %ehselector.slot.i.i85 = alloca i32
  %agg.tmp20.i.i86 = alloca %class.object.1, align 1
  %syncreg.i123.i.i87 = call token @llvm.syncregion.start()
  %syncreg.i69.i.i88 = call token @llvm.syncregion.start()
  %syncreg.i.i89 = call token @llvm.syncregion.start()
  %exn.slot5.i90 = alloca i8*
  %ehselector.slot6.i91 = alloca i32
  call void @llvm.taskframe.use(token %199)
  %savedstack.i92 = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp.i65, %class.object.0** %this.addr.i.i82, align 8
  store %class.object.0* %a3.i69, %class.object.0** %other.addr.i.i83, align 8
  %this1.i.i93 = load %class.object.0*, %class.object.0** %this.addr.i.i82, align 8
  %a.i.i94 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i93, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i.i94)
          to label %.noexc.i97 unwind label %lpad4.i538

.noexc.i97:                                       ; preds = %det.achd.i95
  %b.i.i96 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i93, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i.i96)
          to label %invoke.cont.i.i98 unwind label %lpad.i.i284

invoke.cont.i.i98:                                ; preds = %.noexc.i97
  %201 = call token @llvm.taskframe.create()
  %agg.tmp.i.i99 = alloca %class.object.1, align 1
  %exn.slot12.i.i100 = alloca i8*
  %ehselector.slot13.i.i101 = alloca i32
  %a2.i.i102 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i93, i32 0, i32 0
  %202 = load %class.object.0*, %class.object.0** %other.addr.i.i83, align 8
  %a3.i.i103 = getelementptr inbounds %class.object.0, %class.object.0* %202, i32 0, i32 0
  detach within %syncreg.i.i89, label %det.achd.i.i123, label %det.cont.i.i205 unwind label %lpad11.i.i300

det.achd.i.i123:                                  ; preds = %invoke.cont.i.i98
  %this.addr.i36.i.i104 = alloca %class.object.1*, align 8
  %exn.slot12.i38.i.i105 = alloca i8*
  %ehselector.slot13.i39.i.i106 = alloca i32
  %agg.tmp14.i.i.i107 = alloca %class.object.2, align 1
  %agg.tmp.i41.i.i108 = alloca %class.object.2, align 1
  %exn.slot5.i42.i.i109 = alloca i8*
  %ehselector.slot6.i43.i.i110 = alloca i32
  %syncreg.i37.i.i111 = call token @llvm.syncregion.start()
  %this.addr.i.i.i112 = alloca %class.object.1*, align 8
  %other.addr.i.i.i113 = alloca %class.object.1*, align 8
  %exn.slot.i.i.i114 = alloca i8*
  %ehselector.slot.i.i.i115 = alloca i32
  %agg.tmp20.i.i.i116 = alloca %class.object.2, align 1
  %syncreg.i.i.i117 = call token @llvm.syncregion.start()
  %exn.slot5.i.i118 = alloca i8*
  %ehselector.slot6.i.i119 = alloca i32
  call void @llvm.taskframe.use(token %201)
  %savedstack.i.i120 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i.i99, %class.object.1** %this.addr.i.i.i112, align 8
  store %class.object.1* %a3.i.i103, %class.object.1** %other.addr.i.i.i113, align 8
  %this1.i.i.i121 = load %class.object.1*, %class.object.1** %this.addr.i.i.i112, align 8
  %a.i.i.i122 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i121, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i.i122)
          to label %.noexc.i.i125 unwind label %lpad4.i.i285

.noexc.i.i125:                                    ; preds = %det.achd.i.i123
  %b.i.i.i124 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i121, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i.i124)
          to label %invoke.cont.i.i.i126 unwind label %lpad.i.i.i145

invoke.cont.i.i.i126:                             ; preds = %.noexc.i.i125
  %203 = call token @llvm.taskframe.create()
  %agg.tmp.i.i.i127 = alloca %class.object.2, align 1
  %exn.slot12.i.i.i128 = alloca i8*
  %ehselector.slot13.i.i.i129 = alloca i32
  %a2.i.i.i130 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i121, i32 0, i32 0
  %204 = load %class.object.1*, %class.object.1** %other.addr.i.i.i113, align 8
  %a3.i.i.i131 = getelementptr inbounds %class.object.1, %class.object.1* %204, i32 0, i32 0
  detach within %syncreg.i.i.i117, label %det.achd.i.i.i134, label %det.cont.i.i.i139 unwind label %lpad11.i.i.i157

det.achd.i.i.i134:                                ; preds = %invoke.cont.i.i.i126
  %exn.slot5.i.i.i132 = alloca i8*
  %ehselector.slot6.i.i.i133 = alloca i32
  call void @llvm.taskframe.use(token %203)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i.i127, %class.object.2* dereferenceable(1) %a3.i.i.i131)
          to label %invoke.cont7.i.i.i136 unwind label %lpad4.i.i.i146

invoke.cont7.i.i.i136:                            ; preds = %det.achd.i.i.i134
  %call.i.i.i135 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i.i130, %class.object.2* %agg.tmp.i.i.i127)
          to label %invoke.cont9.i.i.i137 unwind label %lpad8.i.i.i147

invoke.cont9.i.i.i137:                            ; preds = %invoke.cont7.i.i.i136
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i127) #7
  reattach within %syncreg.i.i.i117, label %det.cont.i.i.i139

det.cont.i.i.i139:                                ; preds = %invoke.cont9.i.i.i137, %invoke.cont.i.i.i126
  %205 = load %class.object.1*, %class.object.1** %other.addr.i.i.i113, align 8
  %b21.i.i.i138 = getelementptr inbounds %class.object.1, %class.object.1* %205, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i.i116, %class.object.2* dereferenceable(1) %b21.i.i.i138)
          to label %invoke.cont22.i.i.i142 unwind label %lpad19.i.i.i158

invoke.cont22.i.i.i142:                           ; preds = %det.cont.i.i.i139
  %b23.i.i.i140 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i121, i32 0, i32 1
  %call26.i.i.i141 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i.i140, %class.object.2* %agg.tmp20.i.i.i116)
          to label %invoke.cont25.i.i.i143 unwind label %lpad24.i.i.i159

invoke.cont25.i.i.i143:                           ; preds = %invoke.cont22.i.i.i142
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i116) #7
  sync within %syncreg.i.i.i117, label %sync.continue.i.i.i144

sync.continue.i.i.i144:                           ; preds = %invoke.cont25.i.i.i143
  invoke void @llvm.sync.unwind(token %syncreg.i.i.i117)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i.i169 unwind label %lpad4.i.i285

lpad.i.i.i145:                                    ; preds = %.noexc.i.i125
  %206 = landingpad { i8*, i32 }
          cleanup
  %207 = extractvalue { i8*, i32 } %206, 0
  store i8* %207, i8** %exn.slot.i.i.i114, align 8
  %208 = extractvalue { i8*, i32 } %206, 1
  store i32 %208, i32* %ehselector.slot.i.i.i115, align 4
  br label %ehcleanup29.i.i.i165

lpad4.i.i.i146:                                   ; preds = %det.achd.i.i.i134
  %209 = landingpad { i8*, i32 }
          cleanup
  %210 = extractvalue { i8*, i32 } %209, 0
  store i8* %210, i8** %exn.slot5.i.i.i132, align 8
  %211 = extractvalue { i8*, i32 } %209, 1
  store i32 %211, i32* %ehselector.slot6.i.i.i133, align 4
  br label %ehcleanup.i.i.i152

lpad8.i.i.i147:                                   ; preds = %invoke.cont7.i.i.i136
  %212 = landingpad { i8*, i32 }
          cleanup
  %213 = extractvalue { i8*, i32 } %212, 0
  store i8* %213, i8** %exn.slot5.i.i.i132, align 8
  %214 = extractvalue { i8*, i32 } %212, 1
  store i32 %214, i32* %ehselector.slot6.i.i.i133, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i127) #7
  br label %ehcleanup.i.i.i152

ehcleanup.i.i.i152:                               ; preds = %lpad8.i.i.i147, %lpad4.i.i.i146
  %exn.i.i.i148 = load i8*, i8** %exn.slot5.i.i.i132, align 8
  %sel.i.i.i149 = load i32, i32* %ehselector.slot6.i.i.i133, align 4
  %lpad.val.i.i.i150 = insertvalue { i8*, i32 } undef, i8* %exn.i.i.i148, 0
  %lpad.val10.i.i.i151 = insertvalue { i8*, i32 } %lpad.val.i.i.i150, i32 %sel.i.i.i149, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i.i117, { i8*, i32 } %lpad.val10.i.i.i151)
          to label %unreachable.i.i.i166 unwind label %lpad11.i.i.i157

lpad11.i.i.i157:                                  ; preds = %ehcleanup.i.i.i152, %invoke.cont.i.i.i126
  %215 = landingpad { i8*, i32 }
          cleanup
  %216 = extractvalue { i8*, i32 } %215, 0
  store i8* %216, i8** %exn.slot12.i.i.i128, align 8
  %217 = extractvalue { i8*, i32 } %215, 1
  store i32 %217, i32* %ehselector.slot13.i.i.i129, align 4
  %exn15.i.i.i153 = load i8*, i8** %exn.slot12.i.i.i128, align 8
  %sel16.i.i.i154 = load i32, i32* %ehselector.slot13.i.i.i129, align 4
  %lpad.val17.i.i.i155 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i.i153, 0
  %lpad.val18.i.i.i156 = insertvalue { i8*, i32 } %lpad.val17.i.i.i155, i32 %sel16.i.i.i154, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %203, { i8*, i32 } %lpad.val18.i.i.i156)
          to label %unreachable.i.i.i166 unwind label %lpad19.i.i.i158

lpad19.i.i.i158:                                  ; preds = %lpad11.i.i.i157, %det.cont.i.i.i139
  %218 = landingpad { i8*, i32 }
          cleanup
  %219 = extractvalue { i8*, i32 } %218, 0
  store i8* %219, i8** %exn.slot.i.i.i114, align 8
  %220 = extractvalue { i8*, i32 } %218, 1
  store i32 %220, i32* %ehselector.slot.i.i.i115, align 4
  br label %ehcleanup28.i.i.i160

lpad24.i.i.i159:                                  ; preds = %invoke.cont22.i.i.i142
  %221 = landingpad { i8*, i32 }
          cleanup
  %222 = extractvalue { i8*, i32 } %221, 0
  store i8* %222, i8** %exn.slot.i.i.i114, align 8
  %223 = extractvalue { i8*, i32 } %221, 1
  store i32 %223, i32* %ehselector.slot.i.i.i115, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i116) #7
  br label %ehcleanup28.i.i.i160

ehcleanup28.i.i.i160:                             ; preds = %lpad24.i.i.i159, %lpad19.i.i.i158
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i.i124) #7
  br label %ehcleanup29.i.i.i165

ehcleanup29.i.i.i165:                             ; preds = %ehcleanup28.i.i.i160, %lpad.i.i.i145
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i.i122) #7
  %exn30.i.i.i161 = load i8*, i8** %exn.slot.i.i.i114, align 8
  %sel31.i.i.i162 = load i32, i32* %ehselector.slot.i.i.i115, align 4
  %lpad.val32.i.i.i163 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i.i161, 0
  %lpad.val33.i.i.i164 = insertvalue { i8*, i32 } %lpad.val32.i.i.i163, i32 %sel31.i.i.i162, 1
  br label %lpad4.body.i.i287

unreachable.i.i.i166:                             ; preds = %lpad11.i.i.i157, %ehcleanup.i.i.i152
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i.i169:             ; preds = %sync.continue.i.i.i144
  call void @llvm.stackrestore(i8* %savedstack.i.i120)
  %savedstack61.i.i167 = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i.i102, %class.object.1** %this.addr.i36.i.i104, align 8
  %this1.i40.i.i168 = load %class.object.1*, %class.object.1** %this.addr.i36.i.i104, align 8
  %224 = call token @llvm.taskframe.create()
  %a.i44.i.i170 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i168, i32 0, i32 0
  %a2.i45.i.i171 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i99, i32 0, i32 0
  detach within %syncreg.i37.i.i111, label %det.achd.i49.i.i175, label %det.cont.i52.i.i178 unwind label %lpad4.i58.i.i192

det.achd.i49.i.i175:                              ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i169
  %exn.slot.i46.i.i172 = alloca i8*
  %ehselector.slot.i47.i.i173 = alloca i32
  call void @llvm.taskframe.use(token %224)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i.i108, %class.object.2* dereferenceable(1) %a2.i45.i.i171)
  %call.i48.i.i174 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i.i170, %class.object.2* %agg.tmp.i41.i.i108)
          to label %invoke.cont.i50.i.i176 unwind label %lpad.i56.i.i187

invoke.cont.i50.i.i176:                           ; preds = %det.achd.i49.i.i175
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i108) #7
  reattach within %syncreg.i37.i.i111, label %det.cont.i52.i.i178

det.cont.i52.i.i178:                              ; preds = %invoke.cont.i50.i.i176, %_ZN6objectILi1EEC2ERKS0_.exit.i.i169
  %b.i51.i.i177 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i99, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i.i107, %class.object.2* dereferenceable(1) %b.i51.i.i177)
          to label %.noexc63.i.i181 unwind label %lpad8.i.i288

.noexc63.i.i181:                                  ; preds = %det.cont.i52.i.i178
  %b15.i.i.i179 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i168, i32 0, i32 1
  %call18.i.i.i180 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i.i179, %class.object.2* %agg.tmp14.i.i.i107)
          to label %invoke.cont17.i.i.i182 unwind label %lpad16.i.i.i194

invoke.cont17.i.i.i182:                           ; preds = %.noexc63.i.i181
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i107) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i.i187:                                  ; preds = %det.achd.i49.i.i175
  %225 = landingpad { i8*, i32 }
          cleanup
  %226 = extractvalue { i8*, i32 } %225, 0
  store i8* %226, i8** %exn.slot.i46.i.i172, align 8
  %227 = extractvalue { i8*, i32 } %225, 1
  store i32 %227, i32* %ehselector.slot.i47.i.i173, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i108) #7
  %exn.i53.i.i183 = load i8*, i8** %exn.slot.i46.i.i172, align 8
  %sel.i54.i.i184 = load i32, i32* %ehselector.slot.i47.i.i173, align 4
  %lpad.val.i55.i.i185 = insertvalue { i8*, i32 } undef, i8* %exn.i53.i.i183, 0
  %lpad.val3.i.i.i186 = insertvalue { i8*, i32 } %lpad.val.i55.i.i185, i32 %sel.i54.i.i184, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i.i111, { i8*, i32 } %lpad.val3.i.i.i186)
          to label %unreachable.i60.i.i200 unwind label %lpad4.i58.i.i192

lpad4.i58.i.i192:                                 ; preds = %lpad.i56.i.i187, %_ZN6objectILi1EEC2ERKS0_.exit.i.i169
  %228 = landingpad { i8*, i32 }
          cleanup
  %229 = extractvalue { i8*, i32 } %228, 0
  store i8* %229, i8** %exn.slot5.i42.i.i109, align 8
  %230 = extractvalue { i8*, i32 } %228, 1
  store i32 %230, i32* %ehselector.slot6.i43.i.i110, align 4
  %exn7.i.i.i188 = load i8*, i8** %exn.slot5.i42.i.i109, align 8
  %sel8.i.i.i189 = load i32, i32* %ehselector.slot6.i43.i.i110, align 4
  %lpad.val9.i.i.i190 = insertvalue { i8*, i32 } undef, i8* %exn7.i.i.i188, 0
  %lpad.val10.i57.i.i191 = insertvalue { i8*, i32 } %lpad.val9.i.i.i190, i32 %sel8.i.i.i189, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %224, { i8*, i32 } %lpad.val10.i57.i.i191)
          to label %unreachable.i60.i.i200 unwind label %lpad11.i59.i.i193

lpad11.i59.i.i193:                                ; preds = %lpad4.i58.i.i192
  %231 = landingpad { i8*, i32 }
          cleanup
  %232 = extractvalue { i8*, i32 } %231, 0
  store i8* %232, i8** %exn.slot12.i38.i.i105, align 8
  %233 = extractvalue { i8*, i32 } %231, 1
  store i32 %233, i32* %ehselector.slot13.i39.i.i106, align 4
  br label %eh.resume.i.i.i199

lpad16.i.i.i194:                                  ; preds = %.noexc63.i.i181
  %234 = landingpad { i8*, i32 }
          cleanup
  %235 = extractvalue { i8*, i32 } %234, 0
  store i8* %235, i8** %exn.slot12.i38.i.i105, align 8
  %236 = extractvalue { i8*, i32 } %234, 1
  store i32 %236, i32* %ehselector.slot13.i39.i.i106, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i107) #7
  br label %eh.resume.i.i.i199

eh.resume.i.i.i199:                               ; preds = %lpad16.i.i.i194, %lpad11.i59.i.i193
  %exn19.i.i.i195 = load i8*, i8** %exn.slot12.i38.i.i105, align 8
  %sel20.i.i.i196 = load i32, i32* %ehselector.slot13.i39.i.i106, align 4
  %lpad.val21.i.i.i197 = insertvalue { i8*, i32 } undef, i8* %exn19.i.i.i195, 0
  %lpad.val22.i.i.i198 = insertvalue { i8*, i32 } %lpad.val21.i.i.i197, i32 %sel20.i.i.i196, 1
  br label %lpad8.body.i.i290

unreachable.i60.i.i200:                           ; preds = %lpad4.i58.i.i192, %lpad.i56.i.i187
  unreachable

det.cont.i.i205:                                  ; preds = %invoke.cont.i.i98
  %237 = load %class.object.0*, %class.object.0** %other.addr.i.i83, align 8
  %b21.i.i201 = getelementptr inbounds %class.object.0, %class.object.0* %237, i32 0, i32 1
  %savedstack116.i.i202 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i.i86, %class.object.1** %this.addr.i65.i.i77, align 8
  store %class.object.1* %b21.i.i201, %class.object.1** %other.addr.i66.i.i78, align 8
  %this1.i71.i.i203 = load %class.object.1*, %class.object.1** %this.addr.i65.i.i77, align 8
  %a.i72.i.i204 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i203, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i.i204)
          to label %.noexc117.i.i207 unwind label %lpad19.i.i301

.noexc117.i.i207:                                 ; preds = %det.cont.i.i205
  %b.i73.i.i206 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i203, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i.i206)
          to label %invoke.cont.i79.i.i208 unwind label %lpad.i93.i.i227

invoke.cont.i79.i.i208:                           ; preds = %.noexc117.i.i207
  %238 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i.i209 = alloca %class.object.2, align 1
  %exn.slot12.i75.i.i210 = alloca i8*
  %ehselector.slot13.i76.i.i211 = alloca i32
  %a2.i77.i.i212 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i203, i32 0, i32 0
  %239 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i78, align 8
  %a3.i78.i.i213 = getelementptr inbounds %class.object.1, %class.object.1* %239, i32 0, i32 0
  detach within %syncreg.i69.i.i88, label %det.achd.i82.i.i216, label %det.cont.i87.i.i221 unwind label %lpad11.i101.i.i239

det.achd.i82.i.i216:                              ; preds = %invoke.cont.i79.i.i208
  %exn.slot5.i80.i.i214 = alloca i8*
  %ehselector.slot6.i81.i.i215 = alloca i32
  call void @llvm.taskframe.use(token %238)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i.i209, %class.object.2* dereferenceable(1) %a3.i78.i.i213)
          to label %invoke.cont7.i84.i.i218 unwind label %lpad4.i94.i.i228

invoke.cont7.i84.i.i218:                          ; preds = %det.achd.i82.i.i216
  %call.i83.i.i217 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i.i212, %class.object.2* %agg.tmp.i74.i.i209)
          to label %invoke.cont9.i85.i.i219 unwind label %lpad8.i95.i.i229

invoke.cont9.i85.i.i219:                          ; preds = %invoke.cont7.i84.i.i218
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i209) #7
  reattach within %syncreg.i69.i.i88, label %det.cont.i87.i.i221

det.cont.i87.i.i221:                              ; preds = %invoke.cont9.i85.i.i219, %invoke.cont.i79.i.i208
  %240 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i78, align 8
  %b21.i86.i.i220 = getelementptr inbounds %class.object.1, %class.object.1* %240, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i.i81, %class.object.2* dereferenceable(1) %b21.i86.i.i220)
          to label %invoke.cont22.i90.i.i224 unwind label %lpad19.i106.i.i240

invoke.cont22.i90.i.i224:                         ; preds = %det.cont.i87.i.i221
  %b23.i88.i.i222 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i203, i32 0, i32 1
  %call26.i89.i.i223 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i.i222, %class.object.2* %agg.tmp20.i70.i.i81)
          to label %invoke.cont25.i91.i.i225 unwind label %lpad24.i107.i.i241

invoke.cont25.i91.i.i225:                         ; preds = %invoke.cont22.i90.i.i224
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i81) #7
  sync within %syncreg.i69.i.i88, label %sync.continue.i92.i.i226

sync.continue.i92.i.i226:                         ; preds = %invoke.cont25.i91.i.i225
  invoke void @llvm.sync.unwind(token %syncreg.i69.i.i88)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i252 unwind label %lpad19.i.i301

lpad.i93.i.i227:                                  ; preds = %.noexc117.i.i207
  %241 = landingpad { i8*, i32 }
          cleanup
  %242 = extractvalue { i8*, i32 } %241, 0
  store i8* %242, i8** %exn.slot.i67.i.i79, align 8
  %243 = extractvalue { i8*, i32 } %241, 1
  store i32 %243, i32* %ehselector.slot.i68.i.i80, align 4
  br label %ehcleanup29.i109.i.i247

lpad4.i94.i.i228:                                 ; preds = %det.achd.i82.i.i216
  %244 = landingpad { i8*, i32 }
          cleanup
  %245 = extractvalue { i8*, i32 } %244, 0
  store i8* %245, i8** %exn.slot5.i80.i.i214, align 8
  %246 = extractvalue { i8*, i32 } %244, 1
  store i32 %246, i32* %ehselector.slot6.i81.i.i215, align 4
  br label %ehcleanup.i100.i.i234

lpad8.i95.i.i229:                                 ; preds = %invoke.cont7.i84.i.i218
  %247 = landingpad { i8*, i32 }
          cleanup
  %248 = extractvalue { i8*, i32 } %247, 0
  store i8* %248, i8** %exn.slot5.i80.i.i214, align 8
  %249 = extractvalue { i8*, i32 } %247, 1
  store i32 %249, i32* %ehselector.slot6.i81.i.i215, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i209) #7
  br label %ehcleanup.i100.i.i234

ehcleanup.i100.i.i234:                            ; preds = %lpad8.i95.i.i229, %lpad4.i94.i.i228
  %exn.i96.i.i230 = load i8*, i8** %exn.slot5.i80.i.i214, align 8
  %sel.i97.i.i231 = load i32, i32* %ehselector.slot6.i81.i.i215, align 4
  %lpad.val.i98.i.i232 = insertvalue { i8*, i32 } undef, i8* %exn.i96.i.i230, 0
  %lpad.val10.i99.i.i233 = insertvalue { i8*, i32 } %lpad.val.i98.i.i232, i32 %sel.i97.i.i231, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i.i88, { i8*, i32 } %lpad.val10.i99.i.i233)
          to label %unreachable.i115.i.i248 unwind label %lpad11.i101.i.i239

lpad11.i101.i.i239:                               ; preds = %ehcleanup.i100.i.i234, %invoke.cont.i79.i.i208
  %250 = landingpad { i8*, i32 }
          cleanup
  %251 = extractvalue { i8*, i32 } %250, 0
  store i8* %251, i8** %exn.slot12.i75.i.i210, align 8
  %252 = extractvalue { i8*, i32 } %250, 1
  store i32 %252, i32* %ehselector.slot13.i76.i.i211, align 4
  %exn15.i102.i.i235 = load i8*, i8** %exn.slot12.i75.i.i210, align 8
  %sel16.i103.i.i236 = load i32, i32* %ehselector.slot13.i76.i.i211, align 4
  %lpad.val17.i104.i.i237 = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i.i235, 0
  %lpad.val18.i105.i.i238 = insertvalue { i8*, i32 } %lpad.val17.i104.i.i237, i32 %sel16.i103.i.i236, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %238, { i8*, i32 } %lpad.val18.i105.i.i238)
          to label %unreachable.i115.i.i248 unwind label %lpad19.i106.i.i240

lpad19.i106.i.i240:                               ; preds = %lpad11.i101.i.i239, %det.cont.i87.i.i221
  %253 = landingpad { i8*, i32 }
          cleanup
  %254 = extractvalue { i8*, i32 } %253, 0
  store i8* %254, i8** %exn.slot.i67.i.i79, align 8
  %255 = extractvalue { i8*, i32 } %253, 1
  store i32 %255, i32* %ehselector.slot.i68.i.i80, align 4
  br label %ehcleanup28.i108.i.i242

lpad24.i107.i.i241:                               ; preds = %invoke.cont22.i90.i.i224
  %256 = landingpad { i8*, i32 }
          cleanup
  %257 = extractvalue { i8*, i32 } %256, 0
  store i8* %257, i8** %exn.slot.i67.i.i79, align 8
  %258 = extractvalue { i8*, i32 } %256, 1
  store i32 %258, i32* %ehselector.slot.i68.i.i80, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i81) #7
  br label %ehcleanup28.i108.i.i242

ehcleanup28.i108.i.i242:                          ; preds = %lpad24.i107.i.i241, %lpad19.i106.i.i240
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i.i206) #7
  br label %ehcleanup29.i109.i.i247

ehcleanup29.i109.i.i247:                          ; preds = %ehcleanup28.i108.i.i242, %lpad.i93.i.i227
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i.i204) #7
  %exn30.i110.i.i243 = load i8*, i8** %exn.slot.i67.i.i79, align 8
  %sel31.i111.i.i244 = load i32, i32* %ehselector.slot.i68.i.i80, align 4
  %lpad.val32.i112.i.i245 = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i.i243, 0
  %lpad.val33.i113.i.i246 = insertvalue { i8*, i32 } %lpad.val32.i112.i.i245, i32 %sel31.i111.i.i244, 1
  br label %lpad19.body.i.i303

unreachable.i115.i.i248:                          ; preds = %lpad11.i101.i.i239, %ehcleanup.i100.i.i234
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i.i252:          ; preds = %sync.continue.i92.i.i226
  call void @llvm.stackrestore(i8* %savedstack116.i.i202)
  %b23.i.i249 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i93, i32 0, i32 1
  %savedstack161.i.i250 = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i.i249, %class.object.1** %this.addr.i122.i.i70, align 8
  %this1.i127.i.i251 = load %class.object.1*, %class.object.1** %this.addr.i122.i.i70, align 8
  %259 = call token @llvm.taskframe.create()
  %a.i131.i.i253 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i251, i32 0, i32 0
  %a2.i132.i.i254 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i86, i32 0, i32 0
  detach within %syncreg.i123.i.i87, label %det.achd.i136.i.i258, label %det.cont.i141.i.i261 unwind label %lpad4.i152.i.i275

det.achd.i136.i.i258:                             ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i252
  %exn.slot.i133.i.i255 = alloca i8*
  %ehselector.slot.i134.i.i256 = alloca i32
  call void @llvm.taskframe.use(token %259)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i.i74, %class.object.2* dereferenceable(1) %a2.i132.i.i254)
  %call.i135.i.i257 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i.i253, %class.object.2* %agg.tmp.i128.i.i74)
          to label %invoke.cont.i137.i.i259 unwind label %lpad.i147.i.i270

invoke.cont.i137.i.i259:                          ; preds = %det.achd.i136.i.i258
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i74) #7
  reattach within %syncreg.i123.i.i87, label %det.cont.i141.i.i261

det.cont.i141.i.i261:                             ; preds = %invoke.cont.i137.i.i259, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i252
  %b.i138.i.i260 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i86, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i.i73, %class.object.2* dereferenceable(1) %b.i138.i.i260)
          to label %.noexc164.i.i264 unwind label %lpad24.i.i304

.noexc164.i.i264:                                 ; preds = %det.cont.i141.i.i261
  %b15.i139.i.i262 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i251, i32 0, i32 1
  %call18.i140.i.i263 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i.i262, %class.object.2* %agg.tmp14.i126.i.i73)
          to label %invoke.cont17.i142.i.i265 unwind label %lpad16.i154.i.i277

invoke.cont17.i142.i.i265:                        ; preds = %.noexc164.i.i264
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i73) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i.i270:                                 ; preds = %det.achd.i136.i.i258
  %260 = landingpad { i8*, i32 }
          cleanup
  %261 = extractvalue { i8*, i32 } %260, 0
  store i8* %261, i8** %exn.slot.i133.i.i255, align 8
  %262 = extractvalue { i8*, i32 } %260, 1
  store i32 %262, i32* %ehselector.slot.i134.i.i256, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i74) #7
  %exn.i143.i.i266 = load i8*, i8** %exn.slot.i133.i.i255, align 8
  %sel.i144.i.i267 = load i32, i32* %ehselector.slot.i134.i.i256, align 4
  %lpad.val.i145.i.i268 = insertvalue { i8*, i32 } undef, i8* %exn.i143.i.i266, 0
  %lpad.val3.i146.i.i269 = insertvalue { i8*, i32 } %lpad.val.i145.i.i268, i32 %sel.i144.i.i267, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i.i87, { i8*, i32 } %lpad.val3.i146.i.i269)
          to label %unreachable.i160.i.i283 unwind label %lpad4.i152.i.i275

lpad4.i152.i.i275:                                ; preds = %lpad.i147.i.i270, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i252
  %263 = landingpad { i8*, i32 }
          cleanup
  %264 = extractvalue { i8*, i32 } %263, 0
  store i8* %264, i8** %exn.slot5.i129.i.i75, align 8
  %265 = extractvalue { i8*, i32 } %263, 1
  store i32 %265, i32* %ehselector.slot6.i130.i.i76, align 4
  %exn7.i148.i.i271 = load i8*, i8** %exn.slot5.i129.i.i75, align 8
  %sel8.i149.i.i272 = load i32, i32* %ehselector.slot6.i130.i.i76, align 4
  %lpad.val9.i150.i.i273 = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i.i271, 0
  %lpad.val10.i151.i.i274 = insertvalue { i8*, i32 } %lpad.val9.i150.i.i273, i32 %sel8.i149.i.i272, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %259, { i8*, i32 } %lpad.val10.i151.i.i274)
          to label %unreachable.i160.i.i283 unwind label %lpad11.i153.i.i276

lpad11.i153.i.i276:                               ; preds = %lpad4.i152.i.i275
  %266 = landingpad { i8*, i32 }
          cleanup
  %267 = extractvalue { i8*, i32 } %266, 0
  store i8* %267, i8** %exn.slot12.i124.i.i71, align 8
  %268 = extractvalue { i8*, i32 } %266, 1
  store i32 %268, i32* %ehselector.slot13.i125.i.i72, align 4
  br label %eh.resume.i159.i.i282

lpad16.i154.i.i277:                               ; preds = %.noexc164.i.i264
  %269 = landingpad { i8*, i32 }
          cleanup
  %270 = extractvalue { i8*, i32 } %269, 0
  store i8* %270, i8** %exn.slot12.i124.i.i71, align 8
  %271 = extractvalue { i8*, i32 } %269, 1
  store i32 %271, i32* %ehselector.slot13.i125.i.i72, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i73) #7
  br label %eh.resume.i159.i.i282

eh.resume.i159.i.i282:                            ; preds = %lpad16.i154.i.i277, %lpad11.i153.i.i276
  %exn19.i155.i.i278 = load i8*, i8** %exn.slot12.i124.i.i71, align 8
  %sel20.i156.i.i279 = load i32, i32* %ehselector.slot13.i125.i.i72, align 4
  %lpad.val21.i157.i.i280 = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i.i278, 0
  %lpad.val22.i158.i.i281 = insertvalue { i8*, i32 } %lpad.val21.i157.i.i280, i32 %sel20.i156.i.i279, 1
  br label %lpad24.body.i.i306

unreachable.i160.i.i283:                          ; preds = %lpad4.i152.i.i275, %lpad.i147.i.i270
  unreachable

lpad.i.i284:                                      ; preds = %.noexc.i97
  %272 = landingpad { i8*, i32 }
          cleanup
  %273 = extractvalue { i8*, i32 } %272, 0
  store i8* %273, i8** %exn.slot.i.i84, align 8
  %274 = extractvalue { i8*, i32 } %272, 1
  store i32 %274, i32* %ehselector.slot.i.i85, align 4
  br label %ehcleanup29.i.i312

lpad4.i.i285:                                     ; preds = %sync.continue.i.i.i144, %det.achd.i.i123
  %275 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i.i287

lpad4.body.i.i287:                                ; preds = %lpad4.i.i285, %ehcleanup29.i.i.i165
  %eh.lpad-body.i.i286 = phi { i8*, i32 } [ %275, %lpad4.i.i285 ], [ %lpad.val33.i.i.i164, %ehcleanup29.i.i.i165 ]
  %276 = extractvalue { i8*, i32 } %eh.lpad-body.i.i286, 0
  store i8* %276, i8** %exn.slot5.i.i118, align 8
  %277 = extractvalue { i8*, i32 } %eh.lpad-body.i.i286, 1
  store i32 %277, i32* %ehselector.slot6.i.i119, align 4
  br label %ehcleanup.i.i295

lpad8.i.i288:                                     ; preds = %det.cont.i52.i.i178
  %278 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i.i290

lpad8.body.i.i290:                                ; preds = %lpad8.i.i288, %eh.resume.i.i.i199
  %eh.lpad-body64.i.i289 = phi { i8*, i32 } [ %278, %lpad8.i.i288 ], [ %lpad.val22.i.i.i198, %eh.resume.i.i.i199 ]
  %279 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i289, 0
  store i8* %279, i8** %exn.slot5.i.i118, align 8
  %280 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i289, 1
  store i32 %280, i32* %ehselector.slot6.i.i119, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i.i99) #7
  br label %ehcleanup.i.i295

ehcleanup.i.i295:                                 ; preds = %lpad8.body.i.i290, %lpad4.body.i.i287
  %exn.i.i291 = load i8*, i8** %exn.slot5.i.i118, align 8
  %sel.i.i292 = load i32, i32* %ehselector.slot6.i.i119, align 4
  %lpad.val.i.i293 = insertvalue { i8*, i32 } undef, i8* %exn.i.i291, 0
  %lpad.val10.i.i294 = insertvalue { i8*, i32 } %lpad.val.i.i293, i32 %sel.i.i292, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i89, { i8*, i32 } %lpad.val10.i.i294)
          to label %unreachable.i.i313 unwind label %lpad11.i.i300

lpad11.i.i300:                                    ; preds = %ehcleanup.i.i295, %invoke.cont.i.i98
  %281 = landingpad { i8*, i32 }
          cleanup
  %282 = extractvalue { i8*, i32 } %281, 0
  store i8* %282, i8** %exn.slot12.i.i100, align 8
  %283 = extractvalue { i8*, i32 } %281, 1
  store i32 %283, i32* %ehselector.slot13.i.i101, align 4
  %exn15.i.i296 = load i8*, i8** %exn.slot12.i.i100, align 8
  %sel16.i.i297 = load i32, i32* %ehselector.slot13.i.i101, align 4
  %lpad.val17.i.i298 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i296, 0
  %lpad.val18.i.i299 = insertvalue { i8*, i32 } %lpad.val17.i.i298, i32 %sel16.i.i297, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %201, { i8*, i32 } %lpad.val18.i.i299)
          to label %unreachable.i.i313 unwind label %lpad19.i.i301

lpad19.i.i301:                                    ; preds = %lpad11.i.i300, %sync.continue.i92.i.i226, %det.cont.i.i205
  %284 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i.i303

lpad19.body.i.i303:                               ; preds = %lpad19.i.i301, %ehcleanup29.i109.i.i247
  %eh.lpad-body118.i.i302 = phi { i8*, i32 } [ %284, %lpad19.i.i301 ], [ %lpad.val33.i113.i.i246, %ehcleanup29.i109.i.i247 ]
  %285 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i302, 0
  store i8* %285, i8** %exn.slot.i.i84, align 8
  %286 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i302, 1
  store i32 %286, i32* %ehselector.slot.i.i85, align 4
  br label %ehcleanup28.i.i307

lpad24.i.i304:                                    ; preds = %det.cont.i141.i.i261
  %287 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i.i306

lpad24.body.i.i306:                               ; preds = %lpad24.i.i304, %eh.resume.i159.i.i282
  %eh.lpad-body165.i.i305 = phi { i8*, i32 } [ %287, %lpad24.i.i304 ], [ %lpad.val22.i158.i.i281, %eh.resume.i159.i.i282 ]
  %288 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i305, 0
  store i8* %288, i8** %exn.slot.i.i84, align 8
  %289 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i305, 1
  store i32 %289, i32* %ehselector.slot.i.i85, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i.i86) #7
  br label %ehcleanup28.i.i307

ehcleanup28.i.i307:                               ; preds = %lpad24.body.i.i306, %lpad19.body.i.i303
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i.i96) #7
  br label %ehcleanup29.i.i312

ehcleanup29.i.i312:                               ; preds = %ehcleanup28.i.i307, %lpad.i.i284
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i.i94) #7
  %exn30.i.i308 = load i8*, i8** %exn.slot.i.i84, align 8
  %sel31.i.i309 = load i32, i32* %ehselector.slot.i.i85, align 4
  %lpad.val32.i.i310 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i308, 0
  %lpad.val33.i.i311 = insertvalue { i8*, i32 } %lpad.val32.i.i310, i32 %sel31.i.i309, 1
  br label %lpad4.body.i540

unreachable.i.i313:                               ; preds = %lpad11.i.i300, %ehcleanup.i.i295
  unreachable

det.cont.i318:                                    ; preds = %invoke.cont.i64
  %290 = load %class.object*, %class.object** %other.addr.i56, align 8
  %b21.i314 = getelementptr inbounds %class.object, %class.object* %290, i32 0, i32 1
  %savedstack373.i315 = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp20.i60, %class.object.0** %this.addr.i147.i44, align 8
  store %class.object.0* %b21.i314, %class.object.0** %other.addr.i148.i45, align 8
  %this1.i153.i316 = load %class.object.0*, %class.object.0** %this.addr.i147.i44, align 8
  %a.i154.i317 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i316, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i154.i317)
          to label %.noexc374.i320 unwind label %lpad19.i550

.noexc374.i320:                                   ; preds = %det.cont.i318
  %b.i155.i319 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i316, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i155.i319)
          to label %invoke.cont.i156.i321 unwind label %lpad.i342.i507

invoke.cont.i156.i321:                            ; preds = %.noexc374.i320
  %291 = call token @llvm.taskframe.create()
  %agg.tmp.i157.i322 = alloca %class.object.1, align 1
  %exn.slot12.i158.i323 = alloca i8*
  %ehselector.slot13.i159.i324 = alloca i32
  %a2.i160.i325 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i316, i32 0, i32 0
  %292 = load %class.object.0*, %class.object.0** %other.addr.i148.i45, align 8
  %a3.i161.i326 = getelementptr inbounds %class.object.0, %class.object.0* %292, i32 0, i32 0
  detach within %syncreg.i151.i51, label %det.achd.i181.i346, label %det.cont.i263.i428 unwind label %lpad11.i354.i523

det.achd.i181.i346:                               ; preds = %invoke.cont.i156.i321
  %this.addr.i36.i162.i327 = alloca %class.object.1*, align 8
  %exn.slot12.i38.i163.i328 = alloca i8*
  %ehselector.slot13.i39.i164.i329 = alloca i32
  %agg.tmp14.i.i165.i330 = alloca %class.object.2, align 1
  %agg.tmp.i41.i166.i331 = alloca %class.object.2, align 1
  %exn.slot5.i42.i167.i332 = alloca i8*
  %ehselector.slot6.i43.i168.i333 = alloca i32
  %syncreg.i37.i169.i334 = call token @llvm.syncregion.start()
  %this.addr.i.i170.i335 = alloca %class.object.1*, align 8
  %other.addr.i.i171.i336 = alloca %class.object.1*, align 8
  %exn.slot.i.i172.i337 = alloca i8*
  %ehselector.slot.i.i173.i338 = alloca i32
  %agg.tmp20.i.i174.i339 = alloca %class.object.2, align 1
  %syncreg.i.i175.i340 = call token @llvm.syncregion.start()
  %exn.slot5.i176.i341 = alloca i8*
  %ehselector.slot6.i177.i342 = alloca i32
  call void @llvm.taskframe.use(token %291)
  %savedstack.i178.i343 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i157.i322, %class.object.1** %this.addr.i.i170.i335, align 8
  store %class.object.1* %a3.i161.i326, %class.object.1** %other.addr.i.i171.i336, align 8
  %this1.i.i179.i344 = load %class.object.1*, %class.object.1** %this.addr.i.i170.i335, align 8
  %a.i.i180.i345 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i344, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i180.i345)
          to label %.noexc.i183.i348 unwind label %lpad4.i343.i508

.noexc.i183.i348:                                 ; preds = %det.achd.i181.i346
  %b.i.i182.i347 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i344, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i182.i347)
          to label %invoke.cont.i.i184.i349 unwind label %lpad.i.i203.i368

invoke.cont.i.i184.i349:                          ; preds = %.noexc.i183.i348
  %293 = call token @llvm.taskframe.create()
  %agg.tmp.i.i185.i350 = alloca %class.object.2, align 1
  %exn.slot12.i.i186.i351 = alloca i8*
  %ehselector.slot13.i.i187.i352 = alloca i32
  %a2.i.i188.i353 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i344, i32 0, i32 0
  %294 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i336, align 8
  %a3.i.i189.i354 = getelementptr inbounds %class.object.1, %class.object.1* %294, i32 0, i32 0
  detach within %syncreg.i.i175.i340, label %det.achd.i.i192.i357, label %det.cont.i.i197.i362 unwind label %lpad11.i.i215.i380

det.achd.i.i192.i357:                             ; preds = %invoke.cont.i.i184.i349
  %exn.slot5.i.i190.i355 = alloca i8*
  %ehselector.slot6.i.i191.i356 = alloca i32
  call void @llvm.taskframe.use(token %293)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i185.i350, %class.object.2* dereferenceable(1) %a3.i.i189.i354)
          to label %invoke.cont7.i.i194.i359 unwind label %lpad4.i.i204.i369

invoke.cont7.i.i194.i359:                         ; preds = %det.achd.i.i192.i357
  %call.i.i193.i358 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i188.i353, %class.object.2* %agg.tmp.i.i185.i350)
          to label %invoke.cont9.i.i195.i360 unwind label %lpad8.i.i205.i370

invoke.cont9.i.i195.i360:                         ; preds = %invoke.cont7.i.i194.i359
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i350) #7
  reattach within %syncreg.i.i175.i340, label %det.cont.i.i197.i362

det.cont.i.i197.i362:                             ; preds = %invoke.cont9.i.i195.i360, %invoke.cont.i.i184.i349
  %295 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i336, align 8
  %b21.i.i196.i361 = getelementptr inbounds %class.object.1, %class.object.1* %295, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i174.i339, %class.object.2* dereferenceable(1) %b21.i.i196.i361)
          to label %invoke.cont22.i.i200.i365 unwind label %lpad19.i.i216.i381

invoke.cont22.i.i200.i365:                        ; preds = %det.cont.i.i197.i362
  %b23.i.i198.i363 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i344, i32 0, i32 1
  %call26.i.i199.i364 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i198.i363, %class.object.2* %agg.tmp20.i.i174.i339)
          to label %invoke.cont25.i.i201.i366 unwind label %lpad24.i.i217.i382

invoke.cont25.i.i201.i366:                        ; preds = %invoke.cont22.i.i200.i365
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i339) #7
  sync within %syncreg.i.i175.i340, label %sync.continue.i.i202.i367

sync.continue.i.i202.i367:                        ; preds = %invoke.cont25.i.i201.i366
  invoke void @llvm.sync.unwind(token %syncreg.i.i175.i340)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i392 unwind label %lpad4.i343.i508

lpad.i.i203.i368:                                 ; preds = %.noexc.i183.i348
  %296 = landingpad { i8*, i32 }
          cleanup
  %297 = extractvalue { i8*, i32 } %296, 0
  store i8* %297, i8** %exn.slot.i.i172.i337, align 8
  %298 = extractvalue { i8*, i32 } %296, 1
  store i32 %298, i32* %ehselector.slot.i.i173.i338, align 4
  br label %ehcleanup29.i.i223.i388

lpad4.i.i204.i369:                                ; preds = %det.achd.i.i192.i357
  %299 = landingpad { i8*, i32 }
          cleanup
  %300 = extractvalue { i8*, i32 } %299, 0
  store i8* %300, i8** %exn.slot5.i.i190.i355, align 8
  %301 = extractvalue { i8*, i32 } %299, 1
  store i32 %301, i32* %ehselector.slot6.i.i191.i356, align 4
  br label %ehcleanup.i.i210.i375

lpad8.i.i205.i370:                                ; preds = %invoke.cont7.i.i194.i359
  %302 = landingpad { i8*, i32 }
          cleanup
  %303 = extractvalue { i8*, i32 } %302, 0
  store i8* %303, i8** %exn.slot5.i.i190.i355, align 8
  %304 = extractvalue { i8*, i32 } %302, 1
  store i32 %304, i32* %ehselector.slot6.i.i191.i356, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i350) #7
  br label %ehcleanup.i.i210.i375

ehcleanup.i.i210.i375:                            ; preds = %lpad8.i.i205.i370, %lpad4.i.i204.i369
  %exn.i.i206.i371 = load i8*, i8** %exn.slot5.i.i190.i355, align 8
  %sel.i.i207.i372 = load i32, i32* %ehselector.slot6.i.i191.i356, align 4
  %lpad.val.i.i208.i373 = insertvalue { i8*, i32 } undef, i8* %exn.i.i206.i371, 0
  %lpad.val10.i.i209.i374 = insertvalue { i8*, i32 } %lpad.val.i.i208.i373, i32 %sel.i.i207.i372, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i175.i340, { i8*, i32 } %lpad.val10.i.i209.i374)
          to label %unreachable.i.i224.i389 unwind label %lpad11.i.i215.i380

lpad11.i.i215.i380:                               ; preds = %ehcleanup.i.i210.i375, %invoke.cont.i.i184.i349
  %305 = landingpad { i8*, i32 }
          cleanup
  %306 = extractvalue { i8*, i32 } %305, 0
  store i8* %306, i8** %exn.slot12.i.i186.i351, align 8
  %307 = extractvalue { i8*, i32 } %305, 1
  store i32 %307, i32* %ehselector.slot13.i.i187.i352, align 4
  %exn15.i.i211.i376 = load i8*, i8** %exn.slot12.i.i186.i351, align 8
  %sel16.i.i212.i377 = load i32, i32* %ehselector.slot13.i.i187.i352, align 4
  %lpad.val17.i.i213.i378 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i211.i376, 0
  %lpad.val18.i.i214.i379 = insertvalue { i8*, i32 } %lpad.val17.i.i213.i378, i32 %sel16.i.i212.i377, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %293, { i8*, i32 } %lpad.val18.i.i214.i379)
          to label %unreachable.i.i224.i389 unwind label %lpad19.i.i216.i381

lpad19.i.i216.i381:                               ; preds = %lpad11.i.i215.i380, %det.cont.i.i197.i362
  %308 = landingpad { i8*, i32 }
          cleanup
  %309 = extractvalue { i8*, i32 } %308, 0
  store i8* %309, i8** %exn.slot.i.i172.i337, align 8
  %310 = extractvalue { i8*, i32 } %308, 1
  store i32 %310, i32* %ehselector.slot.i.i173.i338, align 4
  br label %ehcleanup28.i.i218.i383

lpad24.i.i217.i382:                               ; preds = %invoke.cont22.i.i200.i365
  %311 = landingpad { i8*, i32 }
          cleanup
  %312 = extractvalue { i8*, i32 } %311, 0
  store i8* %312, i8** %exn.slot.i.i172.i337, align 8
  %313 = extractvalue { i8*, i32 } %311, 1
  store i32 %313, i32* %ehselector.slot.i.i173.i338, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i339) #7
  br label %ehcleanup28.i.i218.i383

ehcleanup28.i.i218.i383:                          ; preds = %lpad24.i.i217.i382, %lpad19.i.i216.i381
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i182.i347) #7
  br label %ehcleanup29.i.i223.i388

ehcleanup29.i.i223.i388:                          ; preds = %ehcleanup28.i.i218.i383, %lpad.i.i203.i368
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i180.i345) #7
  %exn30.i.i219.i384 = load i8*, i8** %exn.slot.i.i172.i337, align 8
  %sel31.i.i220.i385 = load i32, i32* %ehselector.slot.i.i173.i338, align 4
  %lpad.val32.i.i221.i386 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i219.i384, 0
  %lpad.val33.i.i222.i387 = insertvalue { i8*, i32 } %lpad.val32.i.i221.i386, i32 %sel31.i.i220.i385, 1
  br label %lpad4.body.i345.i510

unreachable.i.i224.i389:                          ; preds = %lpad11.i.i215.i380, %ehcleanup.i.i210.i375
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i225.i392:          ; preds = %sync.continue.i.i202.i367
  call void @llvm.stackrestore(i8* %savedstack.i178.i343)
  %savedstack61.i226.i390 = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i160.i325, %class.object.1** %this.addr.i36.i162.i327, align 8
  %this1.i40.i227.i391 = load %class.object.1*, %class.object.1** %this.addr.i36.i162.i327, align 8
  %314 = call token @llvm.taskframe.create()
  %a.i44.i228.i393 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i391, i32 0, i32 0
  %a2.i45.i229.i394 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i322, i32 0, i32 0
  detach within %syncreg.i37.i169.i334, label %det.achd.i49.i233.i398, label %det.cont.i52.i236.i401 unwind label %lpad4.i58.i250.i415

det.achd.i49.i233.i398:                           ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i392
  %exn.slot.i46.i230.i395 = alloca i8*
  %ehselector.slot.i47.i231.i396 = alloca i32
  call void @llvm.taskframe.use(token %314)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i166.i331, %class.object.2* dereferenceable(1) %a2.i45.i229.i394)
  %call.i48.i232.i397 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i228.i393, %class.object.2* %agg.tmp.i41.i166.i331)
          to label %invoke.cont.i50.i234.i399 unwind label %lpad.i56.i245.i410

invoke.cont.i50.i234.i399:                        ; preds = %det.achd.i49.i233.i398
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i331) #7
  reattach within %syncreg.i37.i169.i334, label %det.cont.i52.i236.i401

det.cont.i52.i236.i401:                           ; preds = %invoke.cont.i50.i234.i399, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i392
  %b.i51.i235.i400 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i322, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i165.i330, %class.object.2* dereferenceable(1) %b.i51.i235.i400)
          to label %.noexc63.i239.i404 unwind label %lpad8.i346.i511

.noexc63.i239.i404:                               ; preds = %det.cont.i52.i236.i401
  %b15.i.i237.i402 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i391, i32 0, i32 1
  %call18.i.i238.i403 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i237.i402, %class.object.2* %agg.tmp14.i.i165.i330)
          to label %invoke.cont17.i.i240.i405 unwind label %lpad16.i.i252.i417

invoke.cont17.i.i240.i405:                        ; preds = %.noexc63.i239.i404
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i330) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i245.i410:                               ; preds = %det.achd.i49.i233.i398
  %315 = landingpad { i8*, i32 }
          cleanup
  %316 = extractvalue { i8*, i32 } %315, 0
  store i8* %316, i8** %exn.slot.i46.i230.i395, align 8
  %317 = extractvalue { i8*, i32 } %315, 1
  store i32 %317, i32* %ehselector.slot.i47.i231.i396, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i331) #7
  %exn.i53.i241.i406 = load i8*, i8** %exn.slot.i46.i230.i395, align 8
  %sel.i54.i242.i407 = load i32, i32* %ehselector.slot.i47.i231.i396, align 4
  %lpad.val.i55.i243.i408 = insertvalue { i8*, i32 } undef, i8* %exn.i53.i241.i406, 0
  %lpad.val3.i.i244.i409 = insertvalue { i8*, i32 } %lpad.val.i55.i243.i408, i32 %sel.i54.i242.i407, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i169.i334, { i8*, i32 } %lpad.val3.i.i244.i409)
          to label %unreachable.i60.i258.i423 unwind label %lpad4.i58.i250.i415

lpad4.i58.i250.i415:                              ; preds = %lpad.i56.i245.i410, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i392
  %318 = landingpad { i8*, i32 }
          cleanup
  %319 = extractvalue { i8*, i32 } %318, 0
  store i8* %319, i8** %exn.slot5.i42.i167.i332, align 8
  %320 = extractvalue { i8*, i32 } %318, 1
  store i32 %320, i32* %ehselector.slot6.i43.i168.i333, align 4
  %exn7.i.i246.i411 = load i8*, i8** %exn.slot5.i42.i167.i332, align 8
  %sel8.i.i247.i412 = load i32, i32* %ehselector.slot6.i43.i168.i333, align 4
  %lpad.val9.i.i248.i413 = insertvalue { i8*, i32 } undef, i8* %exn7.i.i246.i411, 0
  %lpad.val10.i57.i249.i414 = insertvalue { i8*, i32 } %lpad.val9.i.i248.i413, i32 %sel8.i.i247.i412, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %314, { i8*, i32 } %lpad.val10.i57.i249.i414)
          to label %unreachable.i60.i258.i423 unwind label %lpad11.i59.i251.i416

lpad11.i59.i251.i416:                             ; preds = %lpad4.i58.i250.i415
  %321 = landingpad { i8*, i32 }
          cleanup
  %322 = extractvalue { i8*, i32 } %321, 0
  store i8* %322, i8** %exn.slot12.i38.i163.i328, align 8
  %323 = extractvalue { i8*, i32 } %321, 1
  store i32 %323, i32* %ehselector.slot13.i39.i164.i329, align 4
  br label %eh.resume.i.i257.i422

lpad16.i.i252.i417:                               ; preds = %.noexc63.i239.i404
  %324 = landingpad { i8*, i32 }
          cleanup
  %325 = extractvalue { i8*, i32 } %324, 0
  store i8* %325, i8** %exn.slot12.i38.i163.i328, align 8
  %326 = extractvalue { i8*, i32 } %324, 1
  store i32 %326, i32* %ehselector.slot13.i39.i164.i329, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i330) #7
  br label %eh.resume.i.i257.i422

eh.resume.i.i257.i422:                            ; preds = %lpad16.i.i252.i417, %lpad11.i59.i251.i416
  %exn19.i.i253.i418 = load i8*, i8** %exn.slot12.i38.i163.i328, align 8
  %sel20.i.i254.i419 = load i32, i32* %ehselector.slot13.i39.i164.i329, align 4
  %lpad.val21.i.i255.i420 = insertvalue { i8*, i32 } undef, i8* %exn19.i.i253.i418, 0
  %lpad.val22.i.i256.i421 = insertvalue { i8*, i32 } %lpad.val21.i.i255.i420, i32 %sel20.i.i254.i419, 1
  br label %lpad8.body.i348.i513

unreachable.i60.i258.i423:                        ; preds = %lpad4.i58.i250.i415, %lpad.i56.i245.i410
  unreachable

det.cont.i263.i428:                               ; preds = %invoke.cont.i156.i321
  %327 = load %class.object.0*, %class.object.0** %other.addr.i148.i45, align 8
  %b21.i259.i424 = getelementptr inbounds %class.object.0, %class.object.0* %327, i32 0, i32 1
  %savedstack116.i260.i425 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i152.i48, %class.object.1** %this.addr.i65.i141.i39, align 8
  store %class.object.1* %b21.i259.i424, %class.object.1** %other.addr.i66.i142.i40, align 8
  %this1.i71.i261.i426 = load %class.object.1*, %class.object.1** %this.addr.i65.i141.i39, align 8
  %a.i72.i262.i427 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i426, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i262.i427)
          to label %.noexc117.i265.i430 unwind label %lpad19.i359.i524

.noexc117.i265.i430:                              ; preds = %det.cont.i263.i428
  %b.i73.i264.i429 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i426, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i264.i429)
          to label %invoke.cont.i79.i266.i431 unwind label %lpad.i93.i285.i450

invoke.cont.i79.i266.i431:                        ; preds = %.noexc117.i265.i430
  %328 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i267.i432 = alloca %class.object.2, align 1
  %exn.slot12.i75.i268.i433 = alloca i8*
  %ehselector.slot13.i76.i269.i434 = alloca i32
  %a2.i77.i270.i435 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i426, i32 0, i32 0
  %329 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i40, align 8
  %a3.i78.i271.i436 = getelementptr inbounds %class.object.1, %class.object.1* %329, i32 0, i32 0
  detach within %syncreg.i69.i146.i50, label %det.achd.i82.i274.i439, label %det.cont.i87.i279.i444 unwind label %lpad11.i101.i297.i462

det.achd.i82.i274.i439:                           ; preds = %invoke.cont.i79.i266.i431
  %exn.slot5.i80.i272.i437 = alloca i8*
  %ehselector.slot6.i81.i273.i438 = alloca i32
  call void @llvm.taskframe.use(token %328)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i267.i432, %class.object.2* dereferenceable(1) %a3.i78.i271.i436)
          to label %invoke.cont7.i84.i276.i441 unwind label %lpad4.i94.i286.i451

invoke.cont7.i84.i276.i441:                       ; preds = %det.achd.i82.i274.i439
  %call.i83.i275.i440 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i270.i435, %class.object.2* %agg.tmp.i74.i267.i432)
          to label %invoke.cont9.i85.i277.i442 unwind label %lpad8.i95.i287.i452

invoke.cont9.i85.i277.i442:                       ; preds = %invoke.cont7.i84.i276.i441
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i432) #7
  reattach within %syncreg.i69.i146.i50, label %det.cont.i87.i279.i444

det.cont.i87.i279.i444:                           ; preds = %invoke.cont9.i85.i277.i442, %invoke.cont.i79.i266.i431
  %330 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i40, align 8
  %b21.i86.i278.i443 = getelementptr inbounds %class.object.1, %class.object.1* %330, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i145.i43, %class.object.2* dereferenceable(1) %b21.i86.i278.i443)
          to label %invoke.cont22.i90.i282.i447 unwind label %lpad19.i106.i298.i463

invoke.cont22.i90.i282.i447:                      ; preds = %det.cont.i87.i279.i444
  %b23.i88.i280.i445 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i426, i32 0, i32 1
  %call26.i89.i281.i446 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i280.i445, %class.object.2* %agg.tmp20.i70.i145.i43)
          to label %invoke.cont25.i91.i283.i448 unwind label %lpad24.i107.i299.i464

invoke.cont25.i91.i283.i448:                      ; preds = %invoke.cont22.i90.i282.i447
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i43) #7
  sync within %syncreg.i69.i146.i50, label %sync.continue.i92.i284.i449

sync.continue.i92.i284.i449:                      ; preds = %invoke.cont25.i91.i283.i448
  invoke void @llvm.sync.unwind(token %syncreg.i69.i146.i50)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i475 unwind label %lpad19.i359.i524

lpad.i93.i285.i450:                               ; preds = %.noexc117.i265.i430
  %331 = landingpad { i8*, i32 }
          cleanup
  %332 = extractvalue { i8*, i32 } %331, 0
  store i8* %332, i8** %exn.slot.i67.i143.i41, align 8
  %333 = extractvalue { i8*, i32 } %331, 1
  store i32 %333, i32* %ehselector.slot.i68.i144.i42, align 4
  br label %ehcleanup29.i109.i305.i470

lpad4.i94.i286.i451:                              ; preds = %det.achd.i82.i274.i439
  %334 = landingpad { i8*, i32 }
          cleanup
  %335 = extractvalue { i8*, i32 } %334, 0
  store i8* %335, i8** %exn.slot5.i80.i272.i437, align 8
  %336 = extractvalue { i8*, i32 } %334, 1
  store i32 %336, i32* %ehselector.slot6.i81.i273.i438, align 4
  br label %ehcleanup.i100.i292.i457

lpad8.i95.i287.i452:                              ; preds = %invoke.cont7.i84.i276.i441
  %337 = landingpad { i8*, i32 }
          cleanup
  %338 = extractvalue { i8*, i32 } %337, 0
  store i8* %338, i8** %exn.slot5.i80.i272.i437, align 8
  %339 = extractvalue { i8*, i32 } %337, 1
  store i32 %339, i32* %ehselector.slot6.i81.i273.i438, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i432) #7
  br label %ehcleanup.i100.i292.i457

ehcleanup.i100.i292.i457:                         ; preds = %lpad8.i95.i287.i452, %lpad4.i94.i286.i451
  %exn.i96.i288.i453 = load i8*, i8** %exn.slot5.i80.i272.i437, align 8
  %sel.i97.i289.i454 = load i32, i32* %ehselector.slot6.i81.i273.i438, align 4
  %lpad.val.i98.i290.i455 = insertvalue { i8*, i32 } undef, i8* %exn.i96.i288.i453, 0
  %lpad.val10.i99.i291.i456 = insertvalue { i8*, i32 } %lpad.val.i98.i290.i455, i32 %sel.i97.i289.i454, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i146.i50, { i8*, i32 } %lpad.val10.i99.i291.i456)
          to label %unreachable.i115.i306.i471 unwind label %lpad11.i101.i297.i462

lpad11.i101.i297.i462:                            ; preds = %ehcleanup.i100.i292.i457, %invoke.cont.i79.i266.i431
  %340 = landingpad { i8*, i32 }
          cleanup
  %341 = extractvalue { i8*, i32 } %340, 0
  store i8* %341, i8** %exn.slot12.i75.i268.i433, align 8
  %342 = extractvalue { i8*, i32 } %340, 1
  store i32 %342, i32* %ehselector.slot13.i76.i269.i434, align 4
  %exn15.i102.i293.i458 = load i8*, i8** %exn.slot12.i75.i268.i433, align 8
  %sel16.i103.i294.i459 = load i32, i32* %ehselector.slot13.i76.i269.i434, align 4
  %lpad.val17.i104.i295.i460 = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i293.i458, 0
  %lpad.val18.i105.i296.i461 = insertvalue { i8*, i32 } %lpad.val17.i104.i295.i460, i32 %sel16.i103.i294.i459, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %328, { i8*, i32 } %lpad.val18.i105.i296.i461)
          to label %unreachable.i115.i306.i471 unwind label %lpad19.i106.i298.i463

lpad19.i106.i298.i463:                            ; preds = %lpad11.i101.i297.i462, %det.cont.i87.i279.i444
  %343 = landingpad { i8*, i32 }
          cleanup
  %344 = extractvalue { i8*, i32 } %343, 0
  store i8* %344, i8** %exn.slot.i67.i143.i41, align 8
  %345 = extractvalue { i8*, i32 } %343, 1
  store i32 %345, i32* %ehselector.slot.i68.i144.i42, align 4
  br label %ehcleanup28.i108.i300.i465

lpad24.i107.i299.i464:                            ; preds = %invoke.cont22.i90.i282.i447
  %346 = landingpad { i8*, i32 }
          cleanup
  %347 = extractvalue { i8*, i32 } %346, 0
  store i8* %347, i8** %exn.slot.i67.i143.i41, align 8
  %348 = extractvalue { i8*, i32 } %346, 1
  store i32 %348, i32* %ehselector.slot.i68.i144.i42, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i43) #7
  br label %ehcleanup28.i108.i300.i465

ehcleanup28.i108.i300.i465:                       ; preds = %lpad24.i107.i299.i464, %lpad19.i106.i298.i463
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i264.i429) #7
  br label %ehcleanup29.i109.i305.i470

ehcleanup29.i109.i305.i470:                       ; preds = %ehcleanup28.i108.i300.i465, %lpad.i93.i285.i450
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i262.i427) #7
  %exn30.i110.i301.i466 = load i8*, i8** %exn.slot.i67.i143.i41, align 8
  %sel31.i111.i302.i467 = load i32, i32* %ehselector.slot.i68.i144.i42, align 4
  %lpad.val32.i112.i303.i468 = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i301.i466, 0
  %lpad.val33.i113.i304.i469 = insertvalue { i8*, i32 } %lpad.val32.i112.i303.i468, i32 %sel31.i111.i302.i467, 1
  br label %lpad19.body.i361.i526

unreachable.i115.i306.i471:                       ; preds = %lpad11.i101.i297.i462, %ehcleanup.i100.i292.i457
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i475:       ; preds = %sync.continue.i92.i284.i449
  call void @llvm.stackrestore(i8* %savedstack116.i260.i425)
  %b23.i308.i472 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i316, i32 0, i32 1
  %savedstack161.i309.i473 = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i308.i472, %class.object.1** %this.addr.i122.i133.i32, align 8
  %this1.i127.i310.i474 = load %class.object.1*, %class.object.1** %this.addr.i122.i133.i32, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i475.split

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i475.split: ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i475
  %349 = call token @llvm.taskframe.create()
  %a.i131.i311.i476 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i474, i32 0, i32 0
  %a2.i132.i312.i477 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i48, i32 0, i32 0
  detach within %syncreg.i123.i140.i49, label %det.achd.i136.i316.i481, label %det.cont.i141.i319.i484 unwind label %lpad4.i152.i333.i498

det.achd.i136.i316.i481:                          ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i475.split
  %exn.slot.i133.i313.i478 = alloca i8*
  %ehselector.slot.i134.i314.i479 = alloca i32
  call void @llvm.taskframe.use(token %349)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i137.i36, %class.object.2* dereferenceable(1) %a2.i132.i312.i477)
  %call.i135.i315.i480 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i311.i476, %class.object.2* %agg.tmp.i128.i137.i36)
          to label %invoke.cont.i137.i317.i482 unwind label %lpad.i147.i328.i493

invoke.cont.i137.i317.i482:                       ; preds = %det.achd.i136.i316.i481
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i36) #7
  reattach within %syncreg.i123.i140.i49, label %det.cont.i141.i319.i484

det.cont.i141.i319.i484:                          ; preds = %invoke.cont.i137.i317.i482, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i475.split
  %b.i138.i318.i483 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i48, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i136.i35, %class.object.2* dereferenceable(1) %b.i138.i318.i483)
          to label %.noexc164.i322.i487 unwind label %lpad24.i362.i527

.noexc164.i322.i487:                              ; preds = %det.cont.i141.i319.i484
  %b15.i139.i320.i485 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i474, i32 0, i32 1
  %call18.i140.i321.i486 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i320.i485, %class.object.2* %agg.tmp14.i126.i136.i35)
          to label %invoke.cont17.i142.i323.i488 unwind label %lpad16.i154.i335.i500

invoke.cont17.i142.i323.i488:                     ; preds = %.noexc164.i322.i487
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i35) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i328.i493:                              ; preds = %det.achd.i136.i316.i481
  %350 = landingpad { i8*, i32 }
          cleanup
  %351 = extractvalue { i8*, i32 } %350, 0
  store i8* %351, i8** %exn.slot.i133.i313.i478, align 8
  %352 = extractvalue { i8*, i32 } %350, 1
  store i32 %352, i32* %ehselector.slot.i134.i314.i479, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i36) #7
  %exn.i143.i324.i489 = load i8*, i8** %exn.slot.i133.i313.i478, align 8
  %sel.i144.i325.i490 = load i32, i32* %ehselector.slot.i134.i314.i479, align 4
  %lpad.val.i145.i326.i491 = insertvalue { i8*, i32 } undef, i8* %exn.i143.i324.i489, 0
  %lpad.val3.i146.i327.i492 = insertvalue { i8*, i32 } %lpad.val.i145.i326.i491, i32 %sel.i144.i325.i490, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i140.i49, { i8*, i32 } %lpad.val3.i146.i327.i492)
          to label %unreachable.i160.i341.i506 unwind label %lpad4.i152.i333.i498

lpad4.i152.i333.i498:                             ; preds = %lpad.i147.i328.i493, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i475.split
  %353 = landingpad { i8*, i32 }
          cleanup
  %354 = extractvalue { i8*, i32 } %353, 0
  store i8* %354, i8** %exn.slot5.i129.i138.i37, align 8
  %355 = extractvalue { i8*, i32 } %353, 1
  store i32 %355, i32* %ehselector.slot6.i130.i139.i38, align 4
  %exn7.i148.i329.i494 = load i8*, i8** %exn.slot5.i129.i138.i37, align 8
  %sel8.i149.i330.i495 = load i32, i32* %ehselector.slot6.i130.i139.i38, align 4
  %lpad.val9.i150.i331.i496 = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i329.i494, 0
  %lpad.val10.i151.i332.i497 = insertvalue { i8*, i32 } %lpad.val9.i150.i331.i496, i32 %sel8.i149.i330.i495, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %349, { i8*, i32 } %lpad.val10.i151.i332.i497)
          to label %unreachable.i160.i341.i506 unwind label %lpad11.i153.i334.i499

lpad11.i153.i334.i499:                            ; preds = %lpad4.i152.i333.i498
  %356 = landingpad { i8*, i32 }
          cleanup
  %357 = extractvalue { i8*, i32 } %356, 0
  store i8* %357, i8** %exn.slot12.i124.i134.i33, align 8
  %358 = extractvalue { i8*, i32 } %356, 1
  store i32 %358, i32* %ehselector.slot13.i125.i135.i34, align 4
  br label %eh.resume.i159.i340.i505

lpad16.i154.i335.i500:                            ; preds = %.noexc164.i322.i487
  %359 = landingpad { i8*, i32 }
          cleanup
  %360 = extractvalue { i8*, i32 } %359, 0
  store i8* %360, i8** %exn.slot12.i124.i134.i33, align 8
  %361 = extractvalue { i8*, i32 } %359, 1
  store i32 %361, i32* %ehselector.slot13.i125.i135.i34, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i35) #7
  br label %eh.resume.i159.i340.i505

eh.resume.i159.i340.i505:                         ; preds = %lpad16.i154.i335.i500, %lpad11.i153.i334.i499
  %exn19.i155.i336.i501 = load i8*, i8** %exn.slot12.i124.i134.i33, align 8
  %sel20.i156.i337.i502 = load i32, i32* %ehselector.slot13.i125.i135.i34, align 4
  %lpad.val21.i157.i338.i503 = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i336.i501, 0
  %lpad.val22.i158.i339.i504 = insertvalue { i8*, i32 } %lpad.val21.i157.i338.i503, i32 %sel20.i156.i337.i502, 1
  br label %lpad24.body.i364.i529

unreachable.i160.i341.i506:                       ; preds = %lpad4.i152.i333.i498, %lpad.i147.i328.i493
  unreachable

lpad.i342.i507:                                   ; preds = %.noexc374.i320
  %362 = landingpad { i8*, i32 }
          cleanup
  %363 = extractvalue { i8*, i32 } %362, 0
  store i8* %363, i8** %exn.slot.i149.i46, align 8
  %364 = extractvalue { i8*, i32 } %362, 1
  store i32 %364, i32* %ehselector.slot.i150.i47, align 4
  br label %ehcleanup29.i366.i535

lpad4.i343.i508:                                  ; preds = %sync.continue.i.i202.i367, %det.achd.i181.i346
  %365 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i345.i510

lpad4.body.i345.i510:                             ; preds = %lpad4.i343.i508, %ehcleanup29.i.i223.i388
  %eh.lpad-body.i344.i509 = phi { i8*, i32 } [ %365, %lpad4.i343.i508 ], [ %lpad.val33.i.i222.i387, %ehcleanup29.i.i223.i388 ]
  %366 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i509, 0
  store i8* %366, i8** %exn.slot5.i176.i341, align 8
  %367 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i509, 1
  store i32 %367, i32* %ehselector.slot6.i177.i342, align 4
  br label %ehcleanup.i353.i518

lpad8.i346.i511:                                  ; preds = %det.cont.i52.i236.i401
  %368 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i348.i513

lpad8.body.i348.i513:                             ; preds = %lpad8.i346.i511, %eh.resume.i.i257.i422
  %eh.lpad-body64.i347.i512 = phi { i8*, i32 } [ %368, %lpad8.i346.i511 ], [ %lpad.val22.i.i256.i421, %eh.resume.i.i257.i422 ]
  %369 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i512, 0
  store i8* %369, i8** %exn.slot5.i176.i341, align 8
  %370 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i512, 1
  store i32 %370, i32* %ehselector.slot6.i177.i342, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i157.i322) #7
  br label %ehcleanup.i353.i518

ehcleanup.i353.i518:                              ; preds = %lpad8.body.i348.i513, %lpad4.body.i345.i510
  %exn.i349.i514 = load i8*, i8** %exn.slot5.i176.i341, align 8
  %sel.i350.i515 = load i32, i32* %ehselector.slot6.i177.i342, align 4
  %lpad.val.i351.i516 = insertvalue { i8*, i32 } undef, i8* %exn.i349.i514, 0
  %lpad.val10.i352.i517 = insertvalue { i8*, i32 } %lpad.val.i351.i516, i32 %sel.i350.i515, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i151.i51, { i8*, i32 } %lpad.val10.i352.i517)
          to label %unreachable.i372.i536 unwind label %lpad11.i354.i523

lpad11.i354.i523:                                 ; preds = %ehcleanup.i353.i518, %invoke.cont.i156.i321
  %371 = landingpad { i8*, i32 }
          cleanup
  %372 = extractvalue { i8*, i32 } %371, 0
  store i8* %372, i8** %exn.slot12.i158.i323, align 8
  %373 = extractvalue { i8*, i32 } %371, 1
  store i32 %373, i32* %ehselector.slot13.i159.i324, align 4
  %exn15.i355.i519 = load i8*, i8** %exn.slot12.i158.i323, align 8
  %sel16.i356.i520 = load i32, i32* %ehselector.slot13.i159.i324, align 4
  %lpad.val17.i357.i521 = insertvalue { i8*, i32 } undef, i8* %exn15.i355.i519, 0
  %lpad.val18.i358.i522 = insertvalue { i8*, i32 } %lpad.val17.i357.i521, i32 %sel16.i356.i520, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %291, { i8*, i32 } %lpad.val18.i358.i522)
          to label %unreachable.i372.i536 unwind label %lpad19.i359.i524

lpad19.i359.i524:                                 ; preds = %lpad11.i354.i523, %sync.continue.i92.i284.i449, %det.cont.i263.i428
  %374 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i361.i526

lpad19.body.i361.i526:                            ; preds = %lpad19.i359.i524, %ehcleanup29.i109.i305.i470
  %eh.lpad-body118.i360.i525 = phi { i8*, i32 } [ %374, %lpad19.i359.i524 ], [ %lpad.val33.i113.i304.i469, %ehcleanup29.i109.i305.i470 ]
  %375 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i525, 0
  store i8* %375, i8** %exn.slot.i149.i46, align 8
  %376 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i525, 1
  store i32 %376, i32* %ehselector.slot.i150.i47, align 4
  br label %ehcleanup28.i365.i530

lpad24.i362.i527:                                 ; preds = %det.cont.i141.i319.i484
  %377 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i364.i529

lpad24.body.i364.i529:                            ; preds = %lpad24.i362.i527, %eh.resume.i159.i340.i505
  %eh.lpad-body165.i363.i528 = phi { i8*, i32 } [ %377, %lpad24.i362.i527 ], [ %lpad.val22.i158.i339.i504, %eh.resume.i159.i340.i505 ]
  %378 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i528, 0
  store i8* %378, i8** %exn.slot.i149.i46, align 8
  %379 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i528, 1
  store i32 %379, i32* %ehselector.slot.i150.i47, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i152.i48) #7
  br label %ehcleanup28.i365.i530

ehcleanup28.i365.i530:                            ; preds = %lpad24.body.i364.i529, %lpad19.body.i361.i526
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i155.i319) #7
  br label %ehcleanup29.i366.i535

ehcleanup29.i366.i535:                            ; preds = %ehcleanup28.i365.i530, %lpad.i342.i507
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i154.i317) #7
  %exn30.i367.i531 = load i8*, i8** %exn.slot.i149.i46, align 8
  %sel31.i368.i532 = load i32, i32* %ehselector.slot.i150.i47, align 4
  %lpad.val32.i369.i533 = insertvalue { i8*, i32 } undef, i8* %exn30.i367.i531, 0
  %lpad.val33.i370.i534 = insertvalue { i8*, i32 } %lpad.val32.i369.i533, i32 %sel31.i368.i532, 1
  br label %lpad19.body.i552

unreachable.i372.i536:                            ; preds = %lpad11.i354.i523, %ehcleanup.i353.i518
  unreachable

lpad.i537:                                        ; preds = %.noexc560
  %380 = landingpad { i8*, i32 }
          cleanup
  %381 = extractvalue { i8*, i32 } %380, 0
  store i8* %381, i8** %exn.slot.i57, align 8
  %382 = extractvalue { i8*, i32 } %380, 1
  store i32 %382, i32* %ehselector.slot.i58, align 4
  br label %ehcleanup29.i553

lpad4.i538:                                       ; preds = %det.achd.i95
  %383 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i540

lpad4.body.i540:                                  ; preds = %lpad4.i538, %ehcleanup29.i.i312
  %eh.lpad-body.i539 = phi { i8*, i32 } [ %383, %lpad4.i538 ], [ %lpad.val33.i.i311, %ehcleanup29.i.i312 ]
  %384 = extractvalue { i8*, i32 } %eh.lpad-body.i539, 0
  store i8* %384, i8** %exn.slot5.i90, align 8
  %385 = extractvalue { i8*, i32 } %eh.lpad-body.i539, 1
  store i32 %385, i32* %ehselector.slot6.i91, align 4
  %exn.i541 = load i8*, i8** %exn.slot5.i90, align 8
  %sel.i542 = load i32, i32* %ehselector.slot6.i91, align 4
  %lpad.val.i543 = insertvalue { i8*, i32 } undef, i8* %exn.i541, 0
  %lpad.val10.i544 = insertvalue { i8*, i32 } %lpad.val.i543, i32 %sel.i542, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i59, { i8*, i32 } %lpad.val10.i544)
          to label %unreachable.i558 unwind label %lpad11.i545

lpad11.i545:                                      ; preds = %lpad4.body.i540, %invoke.cont.i64
  %386 = landingpad { i8*, i32 }
          cleanup
  %387 = extractvalue { i8*, i32 } %386, 0
  store i8* %387, i8** %exn.slot12.i66, align 8
  %388 = extractvalue { i8*, i32 } %386, 1
  store i32 %388, i32* %ehselector.slot13.i67, align 4
  %exn15.i546 = load i8*, i8** %exn.slot12.i66, align 8
  %sel16.i547 = load i32, i32* %ehselector.slot13.i67, align 4
  %lpad.val17.i548 = insertvalue { i8*, i32 } undef, i8* %exn15.i546, 0
  %lpad.val18.i549 = insertvalue { i8*, i32 } %lpad.val17.i548, i32 %sel16.i547, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %199, { i8*, i32 } %lpad.val18.i549)
          to label %unreachable.i558 unwind label %lpad19.i550

lpad19.i550:                                      ; preds = %lpad11.i545, %det.cont.i318
  %389 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i552

lpad19.body.i552:                                 ; preds = %lpad19.i550, %ehcleanup29.i366.i535
  %eh.lpad-body375.i551 = phi { i8*, i32 } [ %389, %lpad19.i550 ], [ %lpad.val33.i370.i534, %ehcleanup29.i366.i535 ]
  %390 = extractvalue { i8*, i32 } %eh.lpad-body375.i551, 0
  store i8* %390, i8** %exn.slot.i57, align 8
  %391 = extractvalue { i8*, i32 } %eh.lpad-body375.i551, 1
  store i32 %391, i32* %ehselector.slot.i58, align 4
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %b.i63) #7
  br label %ehcleanup29.i553

ehcleanup29.i553:                                 ; preds = %lpad19.body.i552, %lpad.i537
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %a.i62) #7
  %exn30.i554 = load i8*, i8** %exn.slot.i57, align 8
  %sel31.i555 = load i32, i32* %ehselector.slot.i58, align 4
  %lpad.val32.i556 = insertvalue { i8*, i32 } undef, i8* %exn30.i554, 0
  %lpad.val33.i557 = insertvalue { i8*, i32 } %lpad.val32.i556, i32 %sel31.i555, 1
  br label %lpad1.body

unreachable.i558:                                 ; preds = %lpad11.i545, %lpad4.body.i540
  unreachable

_ZN6objectILi3EEC2ERKS0_.exit566:                 ; No predecessors!
  br label %invoke.cont4

invoke.cont4:                                     ; preds = %_ZN6objectILi3EEC2ERKS0_.exit566
  detach within %syncreg, label %det.achd, label %det.cont unwind label %lpad

det.achd:                                         ; preds = %invoke.cont4
  %exn.slot6 = alloca i8*
  %ehselector.slot7 = alloca i32
  call void @llvm.taskframe.use(token %1)
  invoke void @_Z6child2ILi3EEv6objectIXT_EEllS1_(%class.object* %agg.tmp, i64 %add, i64 %call, %class.object* %agg.tmp3)
          to label %invoke.cont8 unwind label %lpad5

invoke.cont8:                                     ; preds = %det.achd
  call void @_ZN6objectILi3EED1Ev(%class.object* %agg.tmp3) #7
  call void @_ZN6objectILi3EED1Ev(%class.object* %agg.tmp) #7
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %invoke.cont4, %invoke.cont8
  invoke void @_ZN6objectILi3EE6updateEv(%class.object* %obj)
          to label %invoke.cont17 unwind label %lpad14

invoke.cont17:                                    ; preds = %det.cont
  br label %for.inc

for.inc:                                          ; preds = %invoke.cont17
  %392 = load i64, i64* %i, align 8
  %inc = add nsw i64 %392, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

lpad:                                             ; preds = %for.body.split, %invoke.cont4, %lpad5
  %393 = landingpad { i8*, i32 }
          cleanup
  br label %lpad.body

lpad.body:                                        ; preds = %ehcleanup29.i, %lpad
  %eh.lpad-body = phi { i8*, i32 } [ %393, %lpad ], [ %lpad.val33.i, %ehcleanup29.i ]
  %394 = extractvalue { i8*, i32 } %eh.lpad-body, 0
  store i8* %394, i8** %exn.slot, align 8
  %395 = extractvalue { i8*, i32 } %eh.lpad-body, 1
  store i32 %395, i32* %ehselector.slot, align 4
  br label %ehcleanup

lpad1:                                            ; preds = %invoke.cont2, %invoke.cont
  %396 = landingpad { i8*, i32 }
          cleanup
  br label %lpad1.body

lpad1.body:                                       ; preds = %ehcleanup29.i553, %lpad1
  %eh.lpad-body561 = phi { i8*, i32 } [ %396, %lpad1 ], [ %lpad.val33.i557, %ehcleanup29.i553 ]
  %397 = extractvalue { i8*, i32 } %eh.lpad-body561, 0
  store i8* %397, i8** %exn.slot, align 8
  %398 = extractvalue { i8*, i32 } %eh.lpad-body561, 1
  store i32 %398, i32* %ehselector.slot, align 4
  call void @_ZN6objectILi3EED1Ev(%class.object* %agg.tmp) #7
  br label %ehcleanup

lpad5:                                            ; preds = %det.achd
  %399 = landingpad { i8*, i32 }
          cleanup
  %400 = extractvalue { i8*, i32 } %399, 0
  store i8* %400, i8** %exn.slot6, align 8
  %401 = extractvalue { i8*, i32 } %399, 1
  store i32 %401, i32* %ehselector.slot7, align 4
  call void @_ZN6objectILi3EED1Ev(%class.object* %agg.tmp3) #7
  call void @_ZN6objectILi3EED1Ev(%class.object* %agg.tmp) #7
  %exn = load i8*, i8** %exn.slot6, align 8
  %sel = load i32, i32* %ehselector.slot7, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val9 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %lpad.val9)
          to label %unreachable unwind label %lpad

ehcleanup:                                        ; preds = %lpad1.body, %lpad.body
  %exn10 = load i8*, i8** %exn.slot, align 8
  %sel11 = load i32, i32* %ehselector.slot, align 4
  %lpad.val12 = insertvalue { i8*, i32 } undef, i8* %exn10, 0
  %lpad.val13 = insertvalue { i8*, i32 } %lpad.val12, i32 %sel11, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %1, { i8*, i32 } %lpad.val13)
          to label %unreachable unwind label %lpad14

lpad14:                                           ; preds = %sync.continue, %det.cont, %ehcleanup
  %402 = landingpad { i8*, i32 }
          cleanup
  %403 = extractvalue { i8*, i32 } %402, 0
  store i8* %403, i8** %exn.slot15, align 8
  %404 = extractvalue { i8*, i32 } %402, 1
  store i32 %404, i32* %ehselector.slot16, align 4
  call void @_ZN6objectILi3EED1Ev(%class.object* %obj) #7
  br label %eh.resume

for.end:                                          ; preds = %for.cond
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %for.end
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %invoke.cont18 unwind label %lpad14

invoke.cont18:                                    ; preds = %sync.continue
  sync within %syncreg, label %sync.continue19

sync.continue19:                                  ; preds = %invoke.cont18
  call void @llvm.sync.unwind(token %syncreg)
  call void @_ZN6objectILi3EED1Ev(%class.object* %obj) #7
  ret void

eh.resume:                                        ; preds = %lpad14
  %exn21 = load i8*, i8** %exn.slot15, align 8
  %sel22 = load i32, i32* %ehselector.slot16, align 4
  %lpad.val23 = insertvalue { i8*, i32 } undef, i8* %exn21, 0
  %lpad.val24 = insertvalue { i8*, i32 } %lpad.val23, i32 %sel22, 1
  resume { i8*, i32 } %lpad.val24

unreachable:                                      ; preds = %ehcleanup, %lpad5
  unreachable
}

declare dso_local void @_ZN6objectILi3EEC1Ev(%class.object*) unnamed_addr #2

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #3

; Function Attrs: argmemonly nounwind
declare token @llvm.taskframe.create() #3

declare dso_local void @_Z6child2ILi3EEv6objectIXT_EEllS1_(%class.object*, i64, i64, %class.object*) #2

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind
declare dso_local void @_ZN6objectILi3EED1Ev(%class.object*) unnamed_addr #4

; Function Attrs: argmemonly nounwind
declare void @llvm.taskframe.use(token) #3

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #5

; Function Attrs: argmemonly
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #5

declare dso_local void @_ZN6objectILi3EE6updateEv(%class.object*) #2

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #5

; Function Attrs: noinline uwtable
define dso_local void @_Z14parent_nospawnl(i64 %x) #1 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define dso_local void @_Z14parent_nospawnl(i64
; CHECK: %[[SYNCREG:.+]] = {{.*}}call token @llvm.syncregion.start()
; CHECK-NOT: call token @llvm.syncregion.start()
; CHECK: call token @llvm.taskframe.create()
; CHECK: detach within %[[SYNCREG]]
; CHECK-NOTFSIMPLIFY: call token @llvm.taskframe.create()
; CHECK-TFSIMPLIFY-NOT: call token @llvm.taskframe.create()
; CHECK: detach within %[[SYNCREG]]
entry:
  %this.addr.i122.i133.i305.i27 = alloca %class.object.1*, align 8
  %exn.slot12.i124.i134.i306.i28 = alloca i8*
  %ehselector.slot13.i125.i135.i307.i29 = alloca i32
  %agg.tmp14.i126.i136.i308.i30 = alloca %class.object.2, align 1
  %agg.tmp.i128.i137.i309.i31 = alloca %class.object.2, align 1
  %exn.slot5.i129.i138.i310.i32 = alloca i8*
  %ehselector.slot6.i130.i139.i311.i33 = alloca i32
  %this.addr.i65.i141.i312.i34 = alloca %class.object.1*, align 8
  %other.addr.i66.i142.i313.i35 = alloca %class.object.1*, align 8
  %exn.slot.i67.i143.i314.i36 = alloca i8*
  %ehselector.slot.i68.i144.i315.i37 = alloca i32
  %agg.tmp20.i70.i145.i316.i38 = alloca %class.object.2, align 1
  %this.addr.i147.i317.i39 = alloca %class.object.0*, align 8
  %other.addr.i148.i318.i40 = alloca %class.object.0*, align 8
  %exn.slot.i149.i319.i41 = alloca i8*
  %ehselector.slot.i150.i320.i42 = alloca i32
  %agg.tmp20.i152.i321.i43 = alloca %class.object.1, align 1
  %this.addr.i328.i44 = alloca %class.object*, align 8
  %other.addr.i329.i45 = alloca %class.object*, align 8
  %exn.slot.i330.i46 = alloca i8*
  %ehselector.slot.i331.i47 = alloca i32
  %agg.tmp20.i333.i48 = alloca %class.object.0, align 1
  %this.addr.i69 = alloca %class.object.3*, align 8
  %other.addr.i70 = alloca %class.object.3*, align 8
  %exn.slot.i71 = alloca i8*
  %ehselector.slot.i72 = alloca i32
  %agg.tmp20.i74 = alloca %class.object, align 1
  %syncreg.i105.i368.i840.i17 = call token @llvm.syncregion.start()
  %syncreg.i56.i374.i841.i18 = call token @llvm.syncregion.start()
  %syncreg.i376.i842.i19 = call token @llvm.syncregion.start()
  %syncreg.i123.i126.i860.i20 = call token @llvm.syncregion.start()
  %syncreg.i69.i132.i861.i21 = call token @llvm.syncregion.start()
  %syncreg.i137.i862.i22 = call token @llvm.syncregion.start()
  %syncreg.i105.i.i863.i23 = call token @llvm.syncregion.start()
  %syncreg.i56.i.i864.i24 = call token @llvm.syncregion.start()
  %syncreg.i26.i865.i25 = call token @llvm.syncregion.start()
  %syncreg.i867.i26 = call token @llvm.syncregion.start()
  %syncreg.i105.i387.i302.i49 = call token @llvm.syncregion.start()
  %syncreg.i56.i393.i303.i50 = call token @llvm.syncregion.start()
  %syncreg.i395.i304.i51 = call token @llvm.syncregion.start()
  %syncreg.i123.i140.i322.i52 = call token @llvm.syncregion.start()
  %syncreg.i69.i146.i323.i53 = call token @llvm.syncregion.start()
  %syncreg.i151.i324.i54 = call token @llvm.syncregion.start()
  %syncreg.i105.i.i325.i55 = call token @llvm.syncregion.start()
  %syncreg.i56.i.i326.i56 = call token @llvm.syncregion.start()
  %syncreg.i38.i327.i57 = call token @llvm.syncregion.start()
  %syncreg.i332.i58 = call token @llvm.syncregion.start()
  %syncreg.i105.i368.i.i59 = call token @llvm.syncregion.start()
  %syncreg.i56.i374.i.i60 = call token @llvm.syncregion.start()
  %syncreg.i376.i.i61 = call token @llvm.syncregion.start()
  %syncreg.i123.i126.i.i62 = call token @llvm.syncregion.start()
  %syncreg.i69.i132.i.i63 = call token @llvm.syncregion.start()
  %syncreg.i137.i.i64 = call token @llvm.syncregion.start()
  %syncreg.i105.i.i38.i65 = call token @llvm.syncregion.start()
  %syncreg.i56.i.i39.i66 = call token @llvm.syncregion.start()
  %syncreg.i26.i.i67 = call token @llvm.syncregion.start()
  %syncreg.i41.i68 = call token @llvm.syncregion.start()
  %syncreg.i73 = call token @llvm.syncregion.start()
  %this.addr.i122.i133.i305.i = alloca %class.object.1*, align 8
  %exn.slot12.i124.i134.i306.i = alloca i8*
  %ehselector.slot13.i125.i135.i307.i = alloca i32
  %agg.tmp14.i126.i136.i308.i = alloca %class.object.2, align 1
  %agg.tmp.i128.i137.i309.i = alloca %class.object.2, align 1
  %exn.slot5.i129.i138.i310.i = alloca i8*
  %ehselector.slot6.i130.i139.i311.i = alloca i32
  %this.addr.i65.i141.i312.i = alloca %class.object.1*, align 8
  %other.addr.i66.i142.i313.i = alloca %class.object.1*, align 8
  %exn.slot.i67.i143.i314.i = alloca i8*
  %ehselector.slot.i68.i144.i315.i = alloca i32
  %agg.tmp20.i70.i145.i316.i = alloca %class.object.2, align 1
  %this.addr.i147.i317.i = alloca %class.object.0*, align 8
  %other.addr.i148.i318.i = alloca %class.object.0*, align 8
  %exn.slot.i149.i319.i = alloca i8*
  %ehselector.slot.i150.i320.i = alloca i32
  %agg.tmp20.i152.i321.i = alloca %class.object.1, align 1
  %this.addr.i328.i = alloca %class.object*, align 8
  %other.addr.i329.i = alloca %class.object*, align 8
  %exn.slot.i330.i = alloca i8*
  %ehselector.slot.i331.i = alloca i32
  %agg.tmp20.i333.i = alloca %class.object.0, align 1
  %this.addr.i = alloca %class.object.3*, align 8
  %other.addr.i = alloca %class.object.3*, align 8
  %exn.slot.i = alloca i8*
  %ehselector.slot.i = alloca i32
  %agg.tmp20.i = alloca %class.object, align 1
  %syncreg.i105.i368.i840.i = call token @llvm.syncregion.start()
  %syncreg.i56.i374.i841.i = call token @llvm.syncregion.start()
  %syncreg.i376.i842.i = call token @llvm.syncregion.start()
  %syncreg.i123.i126.i860.i = call token @llvm.syncregion.start()
  %syncreg.i69.i132.i861.i = call token @llvm.syncregion.start()
  %syncreg.i137.i862.i = call token @llvm.syncregion.start()
  %syncreg.i105.i.i863.i = call token @llvm.syncregion.start()
  %syncreg.i56.i.i864.i = call token @llvm.syncregion.start()
  %syncreg.i26.i865.i = call token @llvm.syncregion.start()
  %syncreg.i867.i = call token @llvm.syncregion.start()
  %syncreg.i105.i387.i302.i = call token @llvm.syncregion.start()
  %syncreg.i56.i393.i303.i = call token @llvm.syncregion.start()
  %syncreg.i395.i304.i = call token @llvm.syncregion.start()
  %syncreg.i123.i140.i322.i = call token @llvm.syncregion.start()
  %syncreg.i69.i146.i323.i = call token @llvm.syncregion.start()
  %syncreg.i151.i324.i = call token @llvm.syncregion.start()
  %syncreg.i105.i.i325.i = call token @llvm.syncregion.start()
  %syncreg.i56.i.i326.i = call token @llvm.syncregion.start()
  %syncreg.i38.i327.i = call token @llvm.syncregion.start()
  %syncreg.i332.i = call token @llvm.syncregion.start()
  %syncreg.i105.i368.i.i = call token @llvm.syncregion.start()
  %syncreg.i56.i374.i.i = call token @llvm.syncregion.start()
  %syncreg.i376.i.i = call token @llvm.syncregion.start()
  %syncreg.i123.i126.i.i = call token @llvm.syncregion.start()
  %syncreg.i69.i132.i.i = call token @llvm.syncregion.start()
  %syncreg.i137.i.i = call token @llvm.syncregion.start()
  %syncreg.i105.i.i38.i = call token @llvm.syncregion.start()
  %syncreg.i56.i.i39.i = call token @llvm.syncregion.start()
  %syncreg.i26.i.i = call token @llvm.syncregion.start()
  %syncreg.i41.i = call token @llvm.syncregion.start()
  %syncreg.i = call token @llvm.syncregion.start()
  %x.addr = alloca i64, align 8
  %obj = alloca %class.object.3, align 1
  %i = alloca i64, align 8
  %agg.tmp = alloca %class.object.3, align 1
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  %agg.tmp3 = alloca %class.object.3, align 1
  %syncreg = call token @llvm.syncregion.start()
  store i64 %x, i64* %x.addr, align 8
  call void @_ZN6objectILi4EEC1Ev(%class.object.3* %obj)
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i64, i64* %i, align 8
  %cmp = icmp slt i64 %0, 100
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %savedstack = call i8* @llvm.stacksave()
  store %class.object.3* %agg.tmp, %class.object.3** %this.addr.i, align 8
  store %class.object.3* %obj, %class.object.3** %other.addr.i, align 8
  %this1.i = load %class.object.3*, %class.object.3** %this.addr.i, align 8
  %a.i = getelementptr inbounds %class.object.3, %class.object.3* %this1.i, i32 0, i32 0
  invoke void @_ZN6objectILi3EEC1Ev(%class.object* %a.i)
          to label %.noexc unwind label %lpad

.noexc:                                           ; preds = %for.body
  %b.i = getelementptr inbounds %class.object.3, %class.object.3* %this1.i, i32 0, i32 1
  invoke void @_ZN6objectILi3EEC1Ev(%class.object* %b.i)
          to label %invoke.cont.i unwind label %lpad.i

invoke.cont.i:                                    ; preds = %.noexc
  br label %invoke.cont.i.split

invoke.cont.i.split:                              ; preds = %invoke.cont.i
  %1 = call token @llvm.taskframe.create()
  %agg.tmp.i = alloca %class.object, align 1
  %exn.slot12.i = alloca i8*
  %ehselector.slot13.i = alloca i32
  %a2.i = getelementptr inbounds %class.object.3, %class.object.3* %this1.i, i32 0, i32 0
  %2 = load %class.object.3*, %class.object.3** %other.addr.i, align 8
  %a3.i = getelementptr inbounds %class.object.3, %class.object.3* %2, i32 0, i32 0
  detach within %syncreg.i, label %det.achd.i, label %det.cont.i unwind label %lpad11.i

det.achd.i:                                       ; preds = %invoke.cont.i.split
  %this.addr.i122.i133.i.i = alloca %class.object.1*, align 8
  %exn.slot12.i124.i134.i.i = alloca i8*
  %ehselector.slot13.i125.i135.i.i = alloca i32
  %agg.tmp14.i126.i136.i.i = alloca %class.object.2, align 1
  %agg.tmp.i128.i137.i.i = alloca %class.object.2, align 1
  %exn.slot5.i129.i138.i.i = alloca i8*
  %ehselector.slot6.i130.i139.i.i = alloca i32
  %this.addr.i65.i141.i.i = alloca %class.object.1*, align 8
  %other.addr.i66.i142.i.i = alloca %class.object.1*, align 8
  %exn.slot.i67.i143.i.i = alloca i8*
  %ehselector.slot.i68.i144.i.i = alloca i32
  %agg.tmp20.i70.i145.i.i = alloca %class.object.2, align 1
  %this.addr.i147.i.i = alloca %class.object.0*, align 8
  %other.addr.i148.i.i = alloca %class.object.0*, align 8
  %exn.slot.i149.i.i = alloca i8*
  %ehselector.slot.i150.i.i = alloca i32
  %agg.tmp20.i152.i.i = alloca %class.object.1, align 1
  %this.addr.i.i = alloca %class.object*, align 8
  %other.addr.i.i = alloca %class.object*, align 8
  %exn.slot.i.i = alloca i8*
  %ehselector.slot.i.i = alloca i32
  %agg.tmp20.i.i = alloca %class.object.0, align 1
  %syncreg.i105.i387.i.i = call token @llvm.syncregion.start()
  %syncreg.i56.i393.i.i = call token @llvm.syncregion.start()
  %syncreg.i395.i.i = call token @llvm.syncregion.start()
  %syncreg.i123.i140.i.i = call token @llvm.syncregion.start()
  %syncreg.i69.i146.i.i = call token @llvm.syncregion.start()
  %syncreg.i151.i.i = call token @llvm.syncregion.start()
  %syncreg.i105.i.i.i = call token @llvm.syncregion.start()
  %syncreg.i56.i.i.i = call token @llvm.syncregion.start()
  %syncreg.i38.i.i = call token @llvm.syncregion.start()
  %syncreg.i.i = call token @llvm.syncregion.start()
  %exn.slot5.i = alloca i8*
  %ehselector.slot6.i = alloca i32
  call void @llvm.taskframe.use(token %1)
  %savedstack.i = call i8* @llvm.stacksave()
  store %class.object* %agg.tmp.i, %class.object** %this.addr.i.i, align 8
  store %class.object* %a3.i, %class.object** %other.addr.i.i, align 8
  %this1.i.i = load %class.object*, %class.object** %this.addr.i.i, align 8
  %a.i.i = getelementptr inbounds %class.object, %class.object* %this1.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %a.i.i)
          to label %.noexc.i unwind label %lpad4.i

.noexc.i:                                         ; preds = %det.achd.i
  %b.i.i = getelementptr inbounds %class.object, %class.object* %this1.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %b.i.i)
          to label %invoke.cont.i.i unwind label %lpad.i.i

invoke.cont.i.i:                                  ; preds = %.noexc.i
  br label %invoke.cont.i.i.split

invoke.cont.i.i.split:                            ; preds = %invoke.cont.i.i
  %3 = call token @llvm.taskframe.create()
  %agg.tmp.i.i = alloca %class.object.0, align 1
  %exn.slot12.i.i = alloca i8*
  %ehselector.slot13.i.i = alloca i32
  %a2.i.i = getelementptr inbounds %class.object, %class.object* %this1.i.i, i32 0, i32 0
  %4 = load %class.object*, %class.object** %other.addr.i.i, align 8
  %a3.i.i = getelementptr inbounds %class.object, %class.object* %4, i32 0, i32 0
  detach within %syncreg.i.i, label %det.achd.i.i, label %det.cont.i.i unwind label %lpad11.i.i

det.achd.i.i:                                     ; preds = %invoke.cont.i.i.split
  %this.addr.i122.i.i.i = alloca %class.object.1*, align 8
  %exn.slot12.i124.i.i.i = alloca i8*
  %ehselector.slot13.i125.i.i.i = alloca i32
  %agg.tmp14.i126.i.i.i = alloca %class.object.2, align 1
  %agg.tmp.i128.i.i.i = alloca %class.object.2, align 1
  %exn.slot5.i129.i.i.i = alloca i8*
  %ehselector.slot6.i130.i.i.i = alloca i32
  %this.addr.i65.i.i.i = alloca %class.object.1*, align 8
  %other.addr.i66.i.i.i = alloca %class.object.1*, align 8
  %exn.slot.i67.i.i.i = alloca i8*
  %ehselector.slot.i68.i.i.i = alloca i32
  %agg.tmp20.i70.i.i.i = alloca %class.object.2, align 1
  %this.addr.i.i.i = alloca %class.object.0*, align 8
  %other.addr.i.i.i = alloca %class.object.0*, align 8
  %exn.slot.i.i.i = alloca i8*
  %ehselector.slot.i.i.i = alloca i32
  %agg.tmp20.i.i.i = alloca %class.object.1, align 1
  %syncreg.i123.i.i.i = call token @llvm.syncregion.start()
  %syncreg.i69.i.i.i = call token @llvm.syncregion.start()
  %syncreg.i.i.i = call token @llvm.syncregion.start()
  %exn.slot5.i.i = alloca i8*
  %ehselector.slot6.i.i = alloca i32
  call void @llvm.taskframe.use(token %3)
  %savedstack.i.i = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp.i.i, %class.object.0** %this.addr.i.i.i, align 8
  store %class.object.0* %a3.i.i, %class.object.0** %other.addr.i.i.i, align 8
  %this1.i.i.i = load %class.object.0*, %class.object.0** %this.addr.i.i.i, align 8
  %a.i.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i.i.i)
          to label %.noexc.i.i unwind label %lpad4.i.i

.noexc.i.i:                                       ; preds = %det.achd.i.i
  %b.i.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i.i.i)
          to label %invoke.cont.i.i.i unwind label %lpad.i.i.i

invoke.cont.i.i.i:                                ; preds = %.noexc.i.i
  br label %invoke.cont.i.i.i.split

invoke.cont.i.i.i.split:                          ; preds = %invoke.cont.i.i.i
  %5 = call token @llvm.taskframe.create()
  %agg.tmp.i.i.i = alloca %class.object.1, align 1
  %exn.slot12.i.i.i = alloca i8*
  %ehselector.slot13.i.i.i = alloca i32
  %a2.i.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i.i, i32 0, i32 0
  %6 = load %class.object.0*, %class.object.0** %other.addr.i.i.i, align 8
  %a3.i.i.i = getelementptr inbounds %class.object.0, %class.object.0* %6, i32 0, i32 0
  detach within %syncreg.i.i.i, label %det.achd.i.i.i, label %det.cont.i.i.i unwind label %lpad11.i.i.i

det.achd.i.i.i:                                   ; preds = %invoke.cont.i.i.i.split
  %this.addr.i36.i.i.i = alloca %class.object.1*, align 8
  %exn.slot12.i38.i.i.i = alloca i8*
  %ehselector.slot13.i39.i.i.i = alloca i32
  %agg.tmp14.i.i.i.i = alloca %class.object.2, align 1
  %agg.tmp.i41.i.i.i = alloca %class.object.2, align 1
  %exn.slot5.i42.i.i.i = alloca i8*
  %ehselector.slot6.i43.i.i.i = alloca i32
  %syncreg.i37.i.i.i = call token @llvm.syncregion.start()
  %this.addr.i.i.i.i = alloca %class.object.1*, align 8
  %other.addr.i.i.i.i = alloca %class.object.1*, align 8
  %exn.slot.i.i.i.i = alloca i8*
  %ehselector.slot.i.i.i.i = alloca i32
  %agg.tmp20.i.i.i.i = alloca %class.object.2, align 1
  %syncreg.i.i.i.i = call token @llvm.syncregion.start()
  %exn.slot5.i.i.i = alloca i8*
  %ehselector.slot6.i.i.i = alloca i32
  call void @llvm.taskframe.use(token %5)
  %savedstack.i.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i.i.i, %class.object.1** %this.addr.i.i.i.i, align 8
  store %class.object.1* %a3.i.i.i, %class.object.1** %other.addr.i.i.i.i, align 8
  %this1.i.i.i.i = load %class.object.1*, %class.object.1** %this.addr.i.i.i.i, align 8
  %a.i.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i.i.i)
          to label %.noexc.i.i.i unwind label %lpad4.i.i.i

.noexc.i.i.i:                                     ; preds = %det.achd.i.i.i
  %b.i.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i.i.i)
          to label %invoke.cont.i.i.i.i unwind label %lpad.i.i.i.i

invoke.cont.i.i.i.i:                              ; preds = %.noexc.i.i.i
  br label %invoke.cont.i.i.i.i.split

invoke.cont.i.i.i.i.split:                        ; preds = %invoke.cont.i.i.i.i
  %7 = call token @llvm.taskframe.create()
  %agg.tmp.i.i.i.i = alloca %class.object.2, align 1
  %exn.slot12.i.i.i.i = alloca i8*
  %ehselector.slot13.i.i.i.i = alloca i32
  %a2.i.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i.i, i32 0, i32 0
  %8 = load %class.object.1*, %class.object.1** %other.addr.i.i.i.i, align 8
  %a3.i.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %8, i32 0, i32 0
  detach within %syncreg.i.i.i.i, label %det.achd.i.i.i.i, label %det.cont.i.i.i.i unwind label %lpad11.i.i.i.i

det.achd.i.i.i.i:                                 ; preds = %invoke.cont.i.i.i.i.split
  %exn.slot5.i.i.i.i = alloca i8*
  %ehselector.slot6.i.i.i.i = alloca i32
  call void @llvm.taskframe.use(token %7)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i.i.i, %class.object.2* dereferenceable(1) %a3.i.i.i.i)
          to label %invoke.cont7.i.i.i.i unwind label %lpad4.i.i.i.i

invoke.cont7.i.i.i.i:                             ; preds = %det.achd.i.i.i.i
  %call.i.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i.i.i, %class.object.2* %agg.tmp.i.i.i.i)
          to label %invoke.cont9.i.i.i.i unwind label %lpad8.i.i.i.i

invoke.cont9.i.i.i.i:                             ; preds = %invoke.cont7.i.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i.i) #7
  reattach within %syncreg.i.i.i.i, label %det.cont.i.i.i.i

det.cont.i.i.i.i:                                 ; preds = %invoke.cont9.i.i.i.i, %invoke.cont.i.i.i.i.split
  %9 = load %class.object.1*, %class.object.1** %other.addr.i.i.i.i, align 8
  %b21.i.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %9, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i.i.i, %class.object.2* dereferenceable(1) %b21.i.i.i.i)
          to label %invoke.cont22.i.i.i.i unwind label %lpad19.i.i.i.i

invoke.cont22.i.i.i.i:                            ; preds = %det.cont.i.i.i.i
  %b23.i.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i.i, i32 0, i32 1
  %call26.i.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i.i.i, %class.object.2* %agg.tmp20.i.i.i.i)
          to label %invoke.cont25.i.i.i.i unwind label %lpad24.i.i.i.i

invoke.cont25.i.i.i.i:                            ; preds = %invoke.cont22.i.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i.i) #7
  sync within %syncreg.i.i.i.i, label %sync.continue.i.i.i.i

sync.continue.i.i.i.i:                            ; preds = %invoke.cont25.i.i.i.i
  invoke void @llvm.sync.unwind(token %syncreg.i.i.i.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i unwind label %lpad4.i.i.i

lpad.i.i.i.i:                                     ; preds = %.noexc.i.i.i
  %10 = landingpad { i8*, i32 }
          cleanup
  %11 = extractvalue { i8*, i32 } %10, 0
  store i8* %11, i8** %exn.slot.i.i.i.i, align 8
  %12 = extractvalue { i8*, i32 } %10, 1
  store i32 %12, i32* %ehselector.slot.i.i.i.i, align 4
  br label %ehcleanup29.i.i.i.i

lpad4.i.i.i.i:                                    ; preds = %det.achd.i.i.i.i
  %13 = landingpad { i8*, i32 }
          cleanup
  %14 = extractvalue { i8*, i32 } %13, 0
  store i8* %14, i8** %exn.slot5.i.i.i.i, align 8
  %15 = extractvalue { i8*, i32 } %13, 1
  store i32 %15, i32* %ehselector.slot6.i.i.i.i, align 4
  br label %ehcleanup.i.i.i.i

lpad8.i.i.i.i:                                    ; preds = %invoke.cont7.i.i.i.i
  %16 = landingpad { i8*, i32 }
          cleanup
  %17 = extractvalue { i8*, i32 } %16, 0
  store i8* %17, i8** %exn.slot5.i.i.i.i, align 8
  %18 = extractvalue { i8*, i32 } %16, 1
  store i32 %18, i32* %ehselector.slot6.i.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i.i) #7
  br label %ehcleanup.i.i.i.i

ehcleanup.i.i.i.i:                                ; preds = %lpad8.i.i.i.i, %lpad4.i.i.i.i
  %exn.i.i.i.i = load i8*, i8** %exn.slot5.i.i.i.i, align 8
  %sel.i.i.i.i = load i32, i32* %ehselector.slot6.i.i.i.i, align 4
  %lpad.val.i.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i.i.i, 0
  %lpad.val10.i.i.i.i = insertvalue { i8*, i32 } %lpad.val.i.i.i.i, i32 %sel.i.i.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i.i.i, { i8*, i32 } %lpad.val10.i.i.i.i)
          to label %unreachable.i.i.i.i unwind label %lpad11.i.i.i.i

lpad11.i.i.i.i:                                   ; preds = %ehcleanup.i.i.i.i, %invoke.cont.i.i.i.i.split
  %19 = landingpad { i8*, i32 }
          cleanup
  %20 = extractvalue { i8*, i32 } %19, 0
  store i8* %20, i8** %exn.slot12.i.i.i.i, align 8
  %21 = extractvalue { i8*, i32 } %19, 1
  store i32 %21, i32* %ehselector.slot13.i.i.i.i, align 4
  %exn15.i.i.i.i = load i8*, i8** %exn.slot12.i.i.i.i, align 8
  %sel16.i.i.i.i = load i32, i32* %ehselector.slot13.i.i.i.i, align 4
  %lpad.val17.i.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i.i.i, 0
  %lpad.val18.i.i.i.i = insertvalue { i8*, i32 } %lpad.val17.i.i.i.i, i32 %sel16.i.i.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %7, { i8*, i32 } %lpad.val18.i.i.i.i)
          to label %unreachable.i.i.i.i unwind label %lpad19.i.i.i.i

lpad19.i.i.i.i:                                   ; preds = %lpad11.i.i.i.i, %det.cont.i.i.i.i
  %22 = landingpad { i8*, i32 }
          cleanup
  %23 = extractvalue { i8*, i32 } %22, 0
  store i8* %23, i8** %exn.slot.i.i.i.i, align 8
  %24 = extractvalue { i8*, i32 } %22, 1
  store i32 %24, i32* %ehselector.slot.i.i.i.i, align 4
  br label %ehcleanup28.i.i.i.i

lpad24.i.i.i.i:                                   ; preds = %invoke.cont22.i.i.i.i
  %25 = landingpad { i8*, i32 }
          cleanup
  %26 = extractvalue { i8*, i32 } %25, 0
  store i8* %26, i8** %exn.slot.i.i.i.i, align 8
  %27 = extractvalue { i8*, i32 } %25, 1
  store i32 %27, i32* %ehselector.slot.i.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i.i) #7
  br label %ehcleanup28.i.i.i.i

ehcleanup28.i.i.i.i:                              ; preds = %lpad24.i.i.i.i, %lpad19.i.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i.i.i) #7
  br label %ehcleanup29.i.i.i.i

ehcleanup29.i.i.i.i:                              ; preds = %ehcleanup28.i.i.i.i, %lpad.i.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i.i.i) #7
  %exn30.i.i.i.i = load i8*, i8** %exn.slot.i.i.i.i, align 8
  %sel31.i.i.i.i = load i32, i32* %ehselector.slot.i.i.i.i, align 4
  %lpad.val32.i.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i.i.i, 0
  %lpad.val33.i.i.i.i = insertvalue { i8*, i32 } %lpad.val32.i.i.i.i, i32 %sel31.i.i.i.i, 1
  br label %lpad4.body.i.i.i

unreachable.i.i.i.i:                              ; preds = %lpad11.i.i.i.i, %ehcleanup.i.i.i.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i.i.i:              ; preds = %sync.continue.i.i.i.i
  call void @llvm.stackrestore(i8* %savedstack.i.i.i)
  %savedstack61.i.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i.i.i, %class.object.1** %this.addr.i36.i.i.i, align 8
  %this1.i40.i.i.i = load %class.object.1*, %class.object.1** %this.addr.i36.i.i.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i.split

_ZN6objectILi1EEC2ERKS0_.exit.i.i.i.split:        ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i
  %28 = call token @llvm.taskframe.create()
  %a.i44.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i.i, i32 0, i32 0
  %a2.i45.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i.i, i32 0, i32 0
  detach within %syncreg.i37.i.i.i, label %det.achd.i49.i.i.i, label %det.cont.i52.i.i.i unwind label %lpad4.i58.i.i.i

det.achd.i49.i.i.i:                               ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i.split
  %exn.slot.i46.i.i.i = alloca i8*
  %ehselector.slot.i47.i.i.i = alloca i32
  call void @llvm.taskframe.use(token %28)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i.i.i, %class.object.2* dereferenceable(1) %a2.i45.i.i.i)
  %call.i48.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i.i.i, %class.object.2* %agg.tmp.i41.i.i.i)
          to label %invoke.cont.i50.i.i.i unwind label %lpad.i56.i.i.i

invoke.cont.i50.i.i.i:                            ; preds = %det.achd.i49.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i.i) #7
  reattach within %syncreg.i37.i.i.i, label %det.cont.i52.i.i.i

det.cont.i52.i.i.i:                               ; preds = %invoke.cont.i50.i.i.i, %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i.split
  %b.i51.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i.i.i, %class.object.2* dereferenceable(1) %b.i51.i.i.i)
          to label %.noexc63.i.i.i unwind label %lpad8.i.i.i

.noexc63.i.i.i:                                   ; preds = %det.cont.i52.i.i.i
  %b15.i.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i.i, i32 0, i32 1
  %call18.i.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i.i.i, %class.object.2* %agg.tmp14.i.i.i.i)
          to label %invoke.cont17.i.i.i.i unwind label %lpad16.i.i.i.i

invoke.cont17.i.i.i.i:                            ; preds = %.noexc63.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i.i) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i.i.i:                                   ; preds = %det.achd.i49.i.i.i
  %29 = landingpad { i8*, i32 }
          cleanup
  %30 = extractvalue { i8*, i32 } %29, 0
  store i8* %30, i8** %exn.slot.i46.i.i.i, align 8
  %31 = extractvalue { i8*, i32 } %29, 1
  store i32 %31, i32* %ehselector.slot.i47.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i.i) #7
  %exn.i53.i.i.i = load i8*, i8** %exn.slot.i46.i.i.i, align 8
  %sel.i54.i.i.i = load i32, i32* %ehselector.slot.i47.i.i.i, align 4
  %lpad.val.i55.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i53.i.i.i, 0
  %lpad.val3.i.i.i.i = insertvalue { i8*, i32 } %lpad.val.i55.i.i.i, i32 %sel.i54.i.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i.i.i, { i8*, i32 } %lpad.val3.i.i.i.i)
          to label %unreachable.i60.i.i.i unwind label %lpad4.i58.i.i.i

lpad4.i58.i.i.i:                                  ; preds = %lpad.i56.i.i.i, %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i.split
  %32 = landingpad { i8*, i32 }
          cleanup
  %33 = extractvalue { i8*, i32 } %32, 0
  store i8* %33, i8** %exn.slot5.i42.i.i.i, align 8
  %34 = extractvalue { i8*, i32 } %32, 1
  store i32 %34, i32* %ehselector.slot6.i43.i.i.i, align 4
  %exn7.i.i.i.i = load i8*, i8** %exn.slot5.i42.i.i.i, align 8
  %sel8.i.i.i.i = load i32, i32* %ehselector.slot6.i43.i.i.i, align 4
  %lpad.val9.i.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn7.i.i.i.i, 0
  %lpad.val10.i57.i.i.i = insertvalue { i8*, i32 } %lpad.val9.i.i.i.i, i32 %sel8.i.i.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %28, { i8*, i32 } %lpad.val10.i57.i.i.i)
          to label %unreachable.i60.i.i.i unwind label %lpad11.i59.i.i.i

lpad11.i59.i.i.i:                                 ; preds = %lpad4.i58.i.i.i
  %35 = landingpad { i8*, i32 }
          cleanup
  %36 = extractvalue { i8*, i32 } %35, 0
  store i8* %36, i8** %exn.slot12.i38.i.i.i, align 8
  %37 = extractvalue { i8*, i32 } %35, 1
  store i32 %37, i32* %ehselector.slot13.i39.i.i.i, align 4
  br label %eh.resume.i.i.i.i

lpad16.i.i.i.i:                                   ; preds = %.noexc63.i.i.i
  %38 = landingpad { i8*, i32 }
          cleanup
  %39 = extractvalue { i8*, i32 } %38, 0
  store i8* %39, i8** %exn.slot12.i38.i.i.i, align 8
  %40 = extractvalue { i8*, i32 } %38, 1
  store i32 %40, i32* %ehselector.slot13.i39.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i.i) #7
  br label %eh.resume.i.i.i.i

eh.resume.i.i.i.i:                                ; preds = %lpad16.i.i.i.i, %lpad11.i59.i.i.i
  %exn19.i.i.i.i = load i8*, i8** %exn.slot12.i38.i.i.i, align 8
  %sel20.i.i.i.i = load i32, i32* %ehselector.slot13.i39.i.i.i, align 4
  %lpad.val21.i.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn19.i.i.i.i, 0
  %lpad.val22.i.i.i.i = insertvalue { i8*, i32 } %lpad.val21.i.i.i.i, i32 %sel20.i.i.i.i, 1
  br label %lpad8.body.i.i.i

unreachable.i60.i.i.i:                            ; preds = %lpad4.i58.i.i.i, %lpad.i56.i.i.i
  unreachable

det.cont.i.i.i:                                   ; preds = %invoke.cont.i.i.i.split
  %41 = load %class.object.0*, %class.object.0** %other.addr.i.i.i, align 8
  %b21.i.i.i = getelementptr inbounds %class.object.0, %class.object.0* %41, i32 0, i32 1
  %savedstack116.i.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i.i.i, %class.object.1** %this.addr.i65.i.i.i, align 8
  store %class.object.1* %b21.i.i.i, %class.object.1** %other.addr.i66.i.i.i, align 8
  %this1.i71.i.i.i = load %class.object.1*, %class.object.1** %this.addr.i65.i.i.i, align 8
  %a.i72.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i.i.i)
          to label %.noexc117.i.i.i unwind label %lpad19.i.i.i

.noexc117.i.i.i:                                  ; preds = %det.cont.i.i.i
  %b.i73.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i.i.i)
          to label %invoke.cont.i79.i.i.i unwind label %lpad.i93.i.i.i

invoke.cont.i79.i.i.i:                            ; preds = %.noexc117.i.i.i
  br label %invoke.cont.i79.i.i.i.split

invoke.cont.i79.i.i.i.split:                      ; preds = %invoke.cont.i79.i.i.i
  %42 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i.i.i = alloca %class.object.2, align 1
  %exn.slot12.i75.i.i.i = alloca i8*
  %ehselector.slot13.i76.i.i.i = alloca i32
  %a2.i77.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i.i, i32 0, i32 0
  %43 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i.i, align 8
  %a3.i78.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %43, i32 0, i32 0
  detach within %syncreg.i69.i.i.i, label %det.achd.i82.i.i.i, label %det.cont.i87.i.i.i unwind label %lpad11.i101.i.i.i

det.achd.i82.i.i.i:                               ; preds = %invoke.cont.i79.i.i.i.split
  %exn.slot5.i80.i.i.i = alloca i8*
  %ehselector.slot6.i81.i.i.i = alloca i32
  call void @llvm.taskframe.use(token %42)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i.i.i, %class.object.2* dereferenceable(1) %a3.i78.i.i.i)
          to label %invoke.cont7.i84.i.i.i unwind label %lpad4.i94.i.i.i

invoke.cont7.i84.i.i.i:                           ; preds = %det.achd.i82.i.i.i
  %call.i83.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i.i.i, %class.object.2* %agg.tmp.i74.i.i.i)
          to label %invoke.cont9.i85.i.i.i unwind label %lpad8.i95.i.i.i

invoke.cont9.i85.i.i.i:                           ; preds = %invoke.cont7.i84.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i.i) #7
  reattach within %syncreg.i69.i.i.i, label %det.cont.i87.i.i.i

det.cont.i87.i.i.i:                               ; preds = %invoke.cont9.i85.i.i.i, %invoke.cont.i79.i.i.i.split
  %44 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i.i, align 8
  %b21.i86.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %44, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i.i.i, %class.object.2* dereferenceable(1) %b21.i86.i.i.i)
          to label %invoke.cont22.i90.i.i.i unwind label %lpad19.i106.i.i.i

invoke.cont22.i90.i.i.i:                          ; preds = %det.cont.i87.i.i.i
  %b23.i88.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i.i, i32 0, i32 1
  %call26.i89.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i.i.i, %class.object.2* %agg.tmp20.i70.i.i.i)
          to label %invoke.cont25.i91.i.i.i unwind label %lpad24.i107.i.i.i

invoke.cont25.i91.i.i.i:                          ; preds = %invoke.cont22.i90.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i.i) #7
  sync within %syncreg.i69.i.i.i, label %sync.continue.i92.i.i.i

sync.continue.i92.i.i.i:                          ; preds = %invoke.cont25.i91.i.i.i
  invoke void @llvm.sync.unwind(token %syncreg.i69.i.i.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i unwind label %lpad19.i.i.i

lpad.i93.i.i.i:                                   ; preds = %.noexc117.i.i.i
  %45 = landingpad { i8*, i32 }
          cleanup
  %46 = extractvalue { i8*, i32 } %45, 0
  store i8* %46, i8** %exn.slot.i67.i.i.i, align 8
  %47 = extractvalue { i8*, i32 } %45, 1
  store i32 %47, i32* %ehselector.slot.i68.i.i.i, align 4
  br label %ehcleanup29.i109.i.i.i

lpad4.i94.i.i.i:                                  ; preds = %det.achd.i82.i.i.i
  %48 = landingpad { i8*, i32 }
          cleanup
  %49 = extractvalue { i8*, i32 } %48, 0
  store i8* %49, i8** %exn.slot5.i80.i.i.i, align 8
  %50 = extractvalue { i8*, i32 } %48, 1
  store i32 %50, i32* %ehselector.slot6.i81.i.i.i, align 4
  br label %ehcleanup.i100.i.i.i

lpad8.i95.i.i.i:                                  ; preds = %invoke.cont7.i84.i.i.i
  %51 = landingpad { i8*, i32 }
          cleanup
  %52 = extractvalue { i8*, i32 } %51, 0
  store i8* %52, i8** %exn.slot5.i80.i.i.i, align 8
  %53 = extractvalue { i8*, i32 } %51, 1
  store i32 %53, i32* %ehselector.slot6.i81.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i.i) #7
  br label %ehcleanup.i100.i.i.i

ehcleanup.i100.i.i.i:                             ; preds = %lpad8.i95.i.i.i, %lpad4.i94.i.i.i
  %exn.i96.i.i.i = load i8*, i8** %exn.slot5.i80.i.i.i, align 8
  %sel.i97.i.i.i = load i32, i32* %ehselector.slot6.i81.i.i.i, align 4
  %lpad.val.i98.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i96.i.i.i, 0
  %lpad.val10.i99.i.i.i = insertvalue { i8*, i32 } %lpad.val.i98.i.i.i, i32 %sel.i97.i.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i.i.i, { i8*, i32 } %lpad.val10.i99.i.i.i)
          to label %unreachable.i115.i.i.i unwind label %lpad11.i101.i.i.i

lpad11.i101.i.i.i:                                ; preds = %ehcleanup.i100.i.i.i, %invoke.cont.i79.i.i.i.split
  %54 = landingpad { i8*, i32 }
          cleanup
  %55 = extractvalue { i8*, i32 } %54, 0
  store i8* %55, i8** %exn.slot12.i75.i.i.i, align 8
  %56 = extractvalue { i8*, i32 } %54, 1
  store i32 %56, i32* %ehselector.slot13.i76.i.i.i, align 4
  %exn15.i102.i.i.i = load i8*, i8** %exn.slot12.i75.i.i.i, align 8
  %sel16.i103.i.i.i = load i32, i32* %ehselector.slot13.i76.i.i.i, align 4
  %lpad.val17.i104.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i.i.i, 0
  %lpad.val18.i105.i.i.i = insertvalue { i8*, i32 } %lpad.val17.i104.i.i.i, i32 %sel16.i103.i.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %42, { i8*, i32 } %lpad.val18.i105.i.i.i)
          to label %unreachable.i115.i.i.i unwind label %lpad19.i106.i.i.i

lpad19.i106.i.i.i:                                ; preds = %lpad11.i101.i.i.i, %det.cont.i87.i.i.i
  %57 = landingpad { i8*, i32 }
          cleanup
  %58 = extractvalue { i8*, i32 } %57, 0
  store i8* %58, i8** %exn.slot.i67.i.i.i, align 8
  %59 = extractvalue { i8*, i32 } %57, 1
  store i32 %59, i32* %ehselector.slot.i68.i.i.i, align 4
  br label %ehcleanup28.i108.i.i.i

lpad24.i107.i.i.i:                                ; preds = %invoke.cont22.i90.i.i.i
  %60 = landingpad { i8*, i32 }
          cleanup
  %61 = extractvalue { i8*, i32 } %60, 0
  store i8* %61, i8** %exn.slot.i67.i.i.i, align 8
  %62 = extractvalue { i8*, i32 } %60, 1
  store i32 %62, i32* %ehselector.slot.i68.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i.i) #7
  br label %ehcleanup28.i108.i.i.i

ehcleanup28.i108.i.i.i:                           ; preds = %lpad24.i107.i.i.i, %lpad19.i106.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i.i.i) #7
  br label %ehcleanup29.i109.i.i.i

ehcleanup29.i109.i.i.i:                           ; preds = %ehcleanup28.i108.i.i.i, %lpad.i93.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i.i.i) #7
  %exn30.i110.i.i.i = load i8*, i8** %exn.slot.i67.i.i.i, align 8
  %sel31.i111.i.i.i = load i32, i32* %ehselector.slot.i68.i.i.i, align 4
  %lpad.val32.i112.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i.i.i, 0
  %lpad.val33.i113.i.i.i = insertvalue { i8*, i32 } %lpad.val32.i112.i.i.i, i32 %sel31.i111.i.i.i, 1
  br label %lpad19.body.i.i.i

unreachable.i115.i.i.i:                           ; preds = %lpad11.i101.i.i.i, %ehcleanup.i100.i.i.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i:           ; preds = %sync.continue.i92.i.i.i
  call void @llvm.stackrestore(i8* %savedstack116.i.i.i)
  %b23.i.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i.i, i32 0, i32 1
  %savedstack161.i.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i.i.i, %class.object.1** %this.addr.i122.i.i.i, align 8
  %this1.i127.i.i.i = load %class.object.1*, %class.object.1** %this.addr.i122.i.i.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i.split

_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i.split:     ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i
  %63 = call token @llvm.taskframe.create()
  %a.i131.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i.i, i32 0, i32 0
  %a2.i132.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i.i, i32 0, i32 0
  detach within %syncreg.i123.i.i.i, label %det.achd.i136.i.i.i, label %det.cont.i141.i.i.i unwind label %lpad4.i152.i.i.i

det.achd.i136.i.i.i:                              ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i.split
  %exn.slot.i133.i.i.i = alloca i8*
  %ehselector.slot.i134.i.i.i = alloca i32
  call void @llvm.taskframe.use(token %63)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i.i.i, %class.object.2* dereferenceable(1) %a2.i132.i.i.i)
  %call.i135.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i.i.i, %class.object.2* %agg.tmp.i128.i.i.i)
          to label %invoke.cont.i137.i.i.i unwind label %lpad.i147.i.i.i

invoke.cont.i137.i.i.i:                           ; preds = %det.achd.i136.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i.i) #7
  reattach within %syncreg.i123.i.i.i, label %det.cont.i141.i.i.i

det.cont.i141.i.i.i:                              ; preds = %invoke.cont.i137.i.i.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i.split
  %b.i138.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i.i.i, %class.object.2* dereferenceable(1) %b.i138.i.i.i)
          to label %.noexc164.i.i.i unwind label %lpad24.i.i.i

.noexc164.i.i.i:                                  ; preds = %det.cont.i141.i.i.i
  %b15.i139.i.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i.i, i32 0, i32 1
  %call18.i140.i.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i.i.i, %class.object.2* %agg.tmp14.i126.i.i.i)
          to label %invoke.cont17.i142.i.i.i unwind label %lpad16.i154.i.i.i

invoke.cont17.i142.i.i.i:                         ; preds = %.noexc164.i.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i.i) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i.i.i:                                  ; preds = %det.achd.i136.i.i.i
  %64 = landingpad { i8*, i32 }
          cleanup
  %65 = extractvalue { i8*, i32 } %64, 0
  store i8* %65, i8** %exn.slot.i133.i.i.i, align 8
  %66 = extractvalue { i8*, i32 } %64, 1
  store i32 %66, i32* %ehselector.slot.i134.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i.i) #7
  %exn.i143.i.i.i = load i8*, i8** %exn.slot.i133.i.i.i, align 8
  %sel.i144.i.i.i = load i32, i32* %ehselector.slot.i134.i.i.i, align 4
  %lpad.val.i145.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i143.i.i.i, 0
  %lpad.val3.i146.i.i.i = insertvalue { i8*, i32 } %lpad.val.i145.i.i.i, i32 %sel.i144.i.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i.i.i, { i8*, i32 } %lpad.val3.i146.i.i.i)
          to label %unreachable.i160.i.i.i unwind label %lpad4.i152.i.i.i

lpad4.i152.i.i.i:                                 ; preds = %lpad.i147.i.i.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i.split
  %67 = landingpad { i8*, i32 }
          cleanup
  %68 = extractvalue { i8*, i32 } %67, 0
  store i8* %68, i8** %exn.slot5.i129.i.i.i, align 8
  %69 = extractvalue { i8*, i32 } %67, 1
  store i32 %69, i32* %ehselector.slot6.i130.i.i.i, align 4
  %exn7.i148.i.i.i = load i8*, i8** %exn.slot5.i129.i.i.i, align 8
  %sel8.i149.i.i.i = load i32, i32* %ehselector.slot6.i130.i.i.i, align 4
  %lpad.val9.i150.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i.i.i, 0
  %lpad.val10.i151.i.i.i = insertvalue { i8*, i32 } %lpad.val9.i150.i.i.i, i32 %sel8.i149.i.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %63, { i8*, i32 } %lpad.val10.i151.i.i.i)
          to label %unreachable.i160.i.i.i unwind label %lpad11.i153.i.i.i

lpad11.i153.i.i.i:                                ; preds = %lpad4.i152.i.i.i
  %70 = landingpad { i8*, i32 }
          cleanup
  %71 = extractvalue { i8*, i32 } %70, 0
  store i8* %71, i8** %exn.slot12.i124.i.i.i, align 8
  %72 = extractvalue { i8*, i32 } %70, 1
  store i32 %72, i32* %ehselector.slot13.i125.i.i.i, align 4
  br label %eh.resume.i159.i.i.i

lpad16.i154.i.i.i:                                ; preds = %.noexc164.i.i.i
  %73 = landingpad { i8*, i32 }
          cleanup
  %74 = extractvalue { i8*, i32 } %73, 0
  store i8* %74, i8** %exn.slot12.i124.i.i.i, align 8
  %75 = extractvalue { i8*, i32 } %73, 1
  store i32 %75, i32* %ehselector.slot13.i125.i.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i.i) #7
  br label %eh.resume.i159.i.i.i

eh.resume.i159.i.i.i:                             ; preds = %lpad16.i154.i.i.i, %lpad11.i153.i.i.i
  %exn19.i155.i.i.i = load i8*, i8** %exn.slot12.i124.i.i.i, align 8
  %sel20.i156.i.i.i = load i32, i32* %ehselector.slot13.i125.i.i.i, align 4
  %lpad.val21.i157.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i.i.i, 0
  %lpad.val22.i158.i.i.i = insertvalue { i8*, i32 } %lpad.val21.i157.i.i.i, i32 %sel20.i156.i.i.i, 1
  br label %lpad24.body.i.i.i

unreachable.i160.i.i.i:                           ; preds = %lpad4.i152.i.i.i, %lpad.i147.i.i.i
  unreachable

lpad.i.i.i:                                       ; preds = %.noexc.i.i
  %76 = landingpad { i8*, i32 }
          cleanup
  %77 = extractvalue { i8*, i32 } %76, 0
  store i8* %77, i8** %exn.slot.i.i.i, align 8
  %78 = extractvalue { i8*, i32 } %76, 1
  store i32 %78, i32* %ehselector.slot.i.i.i, align 4
  br label %ehcleanup29.i.i.i

lpad4.i.i.i:                                      ; preds = %sync.continue.i.i.i.i, %det.achd.i.i.i
  %79 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i.i.i

lpad4.body.i.i.i:                                 ; preds = %lpad4.i.i.i, %ehcleanup29.i.i.i.i
  %eh.lpad-body.i.i.i = phi { i8*, i32 } [ %79, %lpad4.i.i.i ], [ %lpad.val33.i.i.i.i, %ehcleanup29.i.i.i.i ]
  %80 = extractvalue { i8*, i32 } %eh.lpad-body.i.i.i, 0
  store i8* %80, i8** %exn.slot5.i.i.i, align 8
  %81 = extractvalue { i8*, i32 } %eh.lpad-body.i.i.i, 1
  store i32 %81, i32* %ehselector.slot6.i.i.i, align 4
  br label %ehcleanup.i.i.i

lpad8.i.i.i:                                      ; preds = %det.cont.i52.i.i.i
  %82 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i.i.i

lpad8.body.i.i.i:                                 ; preds = %lpad8.i.i.i, %eh.resume.i.i.i.i
  %eh.lpad-body64.i.i.i = phi { i8*, i32 } [ %82, %lpad8.i.i.i ], [ %lpad.val22.i.i.i.i, %eh.resume.i.i.i.i ]
  %83 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i.i, 0
  store i8* %83, i8** %exn.slot5.i.i.i, align 8
  %84 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i.i, 1
  store i32 %84, i32* %ehselector.slot6.i.i.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i.i.i) #7
  br label %ehcleanup.i.i.i

ehcleanup.i.i.i:                                  ; preds = %lpad8.body.i.i.i, %lpad4.body.i.i.i
  %exn.i.i.i = load i8*, i8** %exn.slot5.i.i.i, align 8
  %sel.i.i.i = load i32, i32* %ehselector.slot6.i.i.i, align 4
  %lpad.val.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i.i, 0
  %lpad.val10.i.i.i = insertvalue { i8*, i32 } %lpad.val.i.i.i, i32 %sel.i.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i.i, { i8*, i32 } %lpad.val10.i.i.i)
          to label %unreachable.i.i.i unwind label %lpad11.i.i.i

lpad11.i.i.i:                                     ; preds = %ehcleanup.i.i.i, %invoke.cont.i.i.i.split
  %85 = landingpad { i8*, i32 }
          cleanup
  %86 = extractvalue { i8*, i32 } %85, 0
  store i8* %86, i8** %exn.slot12.i.i.i, align 8
  %87 = extractvalue { i8*, i32 } %85, 1
  store i32 %87, i32* %ehselector.slot13.i.i.i, align 4
  %exn15.i.i.i = load i8*, i8** %exn.slot12.i.i.i, align 8
  %sel16.i.i.i = load i32, i32* %ehselector.slot13.i.i.i, align 4
  %lpad.val17.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i.i, 0
  %lpad.val18.i.i.i = insertvalue { i8*, i32 } %lpad.val17.i.i.i, i32 %sel16.i.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %5, { i8*, i32 } %lpad.val18.i.i.i)
          to label %unreachable.i.i.i unwind label %lpad19.i.i.i

lpad19.i.i.i:                                     ; preds = %lpad11.i.i.i, %sync.continue.i92.i.i.i, %det.cont.i.i.i
  %88 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i.i.i

lpad19.body.i.i.i:                                ; preds = %lpad19.i.i.i, %ehcleanup29.i109.i.i.i
  %eh.lpad-body118.i.i.i = phi { i8*, i32 } [ %88, %lpad19.i.i.i ], [ %lpad.val33.i113.i.i.i, %ehcleanup29.i109.i.i.i ]
  %89 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i.i, 0
  store i8* %89, i8** %exn.slot.i.i.i, align 8
  %90 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i.i, 1
  store i32 %90, i32* %ehselector.slot.i.i.i, align 4
  br label %ehcleanup28.i.i.i

lpad24.i.i.i:                                     ; preds = %det.cont.i141.i.i.i
  %91 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i.i.i

lpad24.body.i.i.i:                                ; preds = %lpad24.i.i.i, %eh.resume.i159.i.i.i
  %eh.lpad-body165.i.i.i = phi { i8*, i32 } [ %91, %lpad24.i.i.i ], [ %lpad.val22.i158.i.i.i, %eh.resume.i159.i.i.i ]
  %92 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i.i, 0
  store i8* %92, i8** %exn.slot.i.i.i, align 8
  %93 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i.i, 1
  store i32 %93, i32* %ehselector.slot.i.i.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i.i.i) #7
  br label %ehcleanup28.i.i.i

ehcleanup28.i.i.i:                                ; preds = %lpad24.body.i.i.i, %lpad19.body.i.i.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i.i.i) #7
  br label %ehcleanup29.i.i.i

ehcleanup29.i.i.i:                                ; preds = %ehcleanup28.i.i.i, %lpad.i.i.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i.i.i) #7
  %exn30.i.i.i = load i8*, i8** %exn.slot.i.i.i, align 8
  %sel31.i.i.i = load i32, i32* %ehselector.slot.i.i.i, align 4
  %lpad.val32.i.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i.i, 0
  %lpad.val33.i.i.i = insertvalue { i8*, i32 } %lpad.val32.i.i.i, i32 %sel31.i.i.i, 1
  br label %lpad4.body.i.i

unreachable.i.i.i:                                ; preds = %lpad11.i.i.i, %ehcleanup.i.i.i
  unreachable

det.cont.i.i:                                     ; preds = %invoke.cont.i.i.split
  %94 = load %class.object*, %class.object** %other.addr.i.i, align 8
  %b21.i.i = getelementptr inbounds %class.object, %class.object* %94, i32 0, i32 1
  %savedstack373.i.i = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp20.i.i, %class.object.0** %this.addr.i147.i.i, align 8
  store %class.object.0* %b21.i.i, %class.object.0** %other.addr.i148.i.i, align 8
  %this1.i153.i.i = load %class.object.0*, %class.object.0** %this.addr.i147.i.i, align 8
  %a.i154.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i154.i.i)
          to label %.noexc374.i.i unwind label %lpad19.i.i

.noexc374.i.i:                                    ; preds = %det.cont.i.i
  %b.i155.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i155.i.i)
          to label %invoke.cont.i156.i.i unwind label %lpad.i342.i.i

invoke.cont.i156.i.i:                             ; preds = %.noexc374.i.i
  br label %invoke.cont.i156.i.i.split

invoke.cont.i156.i.i.split:                       ; preds = %invoke.cont.i156.i.i
  %95 = call token @llvm.taskframe.create()
  %agg.tmp.i157.i.i = alloca %class.object.1, align 1
  %exn.slot12.i158.i.i = alloca i8*
  %ehselector.slot13.i159.i.i = alloca i32
  %a2.i160.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i.i, i32 0, i32 0
  %96 = load %class.object.0*, %class.object.0** %other.addr.i148.i.i, align 8
  %a3.i161.i.i = getelementptr inbounds %class.object.0, %class.object.0* %96, i32 0, i32 0
  detach within %syncreg.i151.i.i, label %det.achd.i181.i.i, label %det.cont.i263.i.i unwind label %lpad11.i354.i.i

det.achd.i181.i.i:                                ; preds = %invoke.cont.i156.i.i.split
  %this.addr.i36.i162.i.i = alloca %class.object.1*, align 8
  %exn.slot12.i38.i163.i.i = alloca i8*
  %ehselector.slot13.i39.i164.i.i = alloca i32
  %agg.tmp14.i.i165.i.i = alloca %class.object.2, align 1
  %agg.tmp.i41.i166.i.i = alloca %class.object.2, align 1
  %exn.slot5.i42.i167.i.i = alloca i8*
  %ehselector.slot6.i43.i168.i.i = alloca i32
  %syncreg.i37.i169.i.i = call token @llvm.syncregion.start()
  %this.addr.i.i170.i.i = alloca %class.object.1*, align 8
  %other.addr.i.i171.i.i = alloca %class.object.1*, align 8
  %exn.slot.i.i172.i.i = alloca i8*
  %ehselector.slot.i.i173.i.i = alloca i32
  %agg.tmp20.i.i174.i.i = alloca %class.object.2, align 1
  %syncreg.i.i175.i.i = call token @llvm.syncregion.start()
  %exn.slot5.i176.i.i = alloca i8*
  %ehselector.slot6.i177.i.i = alloca i32
  call void @llvm.taskframe.use(token %95)
  %savedstack.i178.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i157.i.i, %class.object.1** %this.addr.i.i170.i.i, align 8
  store %class.object.1* %a3.i161.i.i, %class.object.1** %other.addr.i.i171.i.i, align 8
  %this1.i.i179.i.i = load %class.object.1*, %class.object.1** %this.addr.i.i170.i.i, align 8
  %a.i.i180.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i180.i.i)
          to label %.noexc.i183.i.i unwind label %lpad4.i343.i.i

.noexc.i183.i.i:                                  ; preds = %det.achd.i181.i.i
  %b.i.i182.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i182.i.i)
          to label %invoke.cont.i.i184.i.i unwind label %lpad.i.i203.i.i

invoke.cont.i.i184.i.i:                           ; preds = %.noexc.i183.i.i
  br label %invoke.cont.i.i184.i.i.split

invoke.cont.i.i184.i.i.split:                     ; preds = %invoke.cont.i.i184.i.i
  %97 = call token @llvm.taskframe.create()
  %agg.tmp.i.i185.i.i = alloca %class.object.2, align 1
  %exn.slot12.i.i186.i.i = alloca i8*
  %ehselector.slot13.i.i187.i.i = alloca i32
  %a2.i.i188.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i.i, i32 0, i32 0
  %98 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i.i, align 8
  %a3.i.i189.i.i = getelementptr inbounds %class.object.1, %class.object.1* %98, i32 0, i32 0
  detach within %syncreg.i.i175.i.i, label %det.achd.i.i192.i.i, label %det.cont.i.i197.i.i unwind label %lpad11.i.i215.i.i

det.achd.i.i192.i.i:                              ; preds = %invoke.cont.i.i184.i.i.split
  %exn.slot5.i.i190.i.i = alloca i8*
  %ehselector.slot6.i.i191.i.i = alloca i32
  call void @llvm.taskframe.use(token %97)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i185.i.i, %class.object.2* dereferenceable(1) %a3.i.i189.i.i)
          to label %invoke.cont7.i.i194.i.i unwind label %lpad4.i.i204.i.i

invoke.cont7.i.i194.i.i:                          ; preds = %det.achd.i.i192.i.i
  %call.i.i193.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i188.i.i, %class.object.2* %agg.tmp.i.i185.i.i)
          to label %invoke.cont9.i.i195.i.i unwind label %lpad8.i.i205.i.i

invoke.cont9.i.i195.i.i:                          ; preds = %invoke.cont7.i.i194.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i.i) #7
  reattach within %syncreg.i.i175.i.i, label %det.cont.i.i197.i.i

det.cont.i.i197.i.i:                              ; preds = %invoke.cont9.i.i195.i.i, %invoke.cont.i.i184.i.i.split
  %99 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i.i, align 8
  %b21.i.i196.i.i = getelementptr inbounds %class.object.1, %class.object.1* %99, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i174.i.i, %class.object.2* dereferenceable(1) %b21.i.i196.i.i)
          to label %invoke.cont22.i.i200.i.i unwind label %lpad19.i.i216.i.i

invoke.cont22.i.i200.i.i:                         ; preds = %det.cont.i.i197.i.i
  %b23.i.i198.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i.i, i32 0, i32 1
  %call26.i.i199.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i198.i.i, %class.object.2* %agg.tmp20.i.i174.i.i)
          to label %invoke.cont25.i.i201.i.i unwind label %lpad24.i.i217.i.i

invoke.cont25.i.i201.i.i:                         ; preds = %invoke.cont22.i.i200.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i.i) #7
  sync within %syncreg.i.i175.i.i, label %sync.continue.i.i202.i.i

sync.continue.i.i202.i.i:                         ; preds = %invoke.cont25.i.i201.i.i
  invoke void @llvm.sync.unwind(token %syncreg.i.i175.i.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i unwind label %lpad4.i343.i.i

lpad.i.i203.i.i:                                  ; preds = %.noexc.i183.i.i
  %100 = landingpad { i8*, i32 }
          cleanup
  %101 = extractvalue { i8*, i32 } %100, 0
  store i8* %101, i8** %exn.slot.i.i172.i.i, align 8
  %102 = extractvalue { i8*, i32 } %100, 1
  store i32 %102, i32* %ehselector.slot.i.i173.i.i, align 4
  br label %ehcleanup29.i.i223.i.i

lpad4.i.i204.i.i:                                 ; preds = %det.achd.i.i192.i.i
  %103 = landingpad { i8*, i32 }
          cleanup
  %104 = extractvalue { i8*, i32 } %103, 0
  store i8* %104, i8** %exn.slot5.i.i190.i.i, align 8
  %105 = extractvalue { i8*, i32 } %103, 1
  store i32 %105, i32* %ehselector.slot6.i.i191.i.i, align 4
  br label %ehcleanup.i.i210.i.i

lpad8.i.i205.i.i:                                 ; preds = %invoke.cont7.i.i194.i.i
  %106 = landingpad { i8*, i32 }
          cleanup
  %107 = extractvalue { i8*, i32 } %106, 0
  store i8* %107, i8** %exn.slot5.i.i190.i.i, align 8
  %108 = extractvalue { i8*, i32 } %106, 1
  store i32 %108, i32* %ehselector.slot6.i.i191.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i.i) #7
  br label %ehcleanup.i.i210.i.i

ehcleanup.i.i210.i.i:                             ; preds = %lpad8.i.i205.i.i, %lpad4.i.i204.i.i
  %exn.i.i206.i.i = load i8*, i8** %exn.slot5.i.i190.i.i, align 8
  %sel.i.i207.i.i = load i32, i32* %ehselector.slot6.i.i191.i.i, align 4
  %lpad.val.i.i208.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i206.i.i, 0
  %lpad.val10.i.i209.i.i = insertvalue { i8*, i32 } %lpad.val.i.i208.i.i, i32 %sel.i.i207.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i175.i.i, { i8*, i32 } %lpad.val10.i.i209.i.i)
          to label %unreachable.i.i224.i.i unwind label %lpad11.i.i215.i.i

lpad11.i.i215.i.i:                                ; preds = %ehcleanup.i.i210.i.i, %invoke.cont.i.i184.i.i.split
  %109 = landingpad { i8*, i32 }
          cleanup
  %110 = extractvalue { i8*, i32 } %109, 0
  store i8* %110, i8** %exn.slot12.i.i186.i.i, align 8
  %111 = extractvalue { i8*, i32 } %109, 1
  store i32 %111, i32* %ehselector.slot13.i.i187.i.i, align 4
  %exn15.i.i211.i.i = load i8*, i8** %exn.slot12.i.i186.i.i, align 8
  %sel16.i.i212.i.i = load i32, i32* %ehselector.slot13.i.i187.i.i, align 4
  %lpad.val17.i.i213.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i211.i.i, 0
  %lpad.val18.i.i214.i.i = insertvalue { i8*, i32 } %lpad.val17.i.i213.i.i, i32 %sel16.i.i212.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %97, { i8*, i32 } %lpad.val18.i.i214.i.i)
          to label %unreachable.i.i224.i.i unwind label %lpad19.i.i216.i.i

lpad19.i.i216.i.i:                                ; preds = %lpad11.i.i215.i.i, %det.cont.i.i197.i.i
  %112 = landingpad { i8*, i32 }
          cleanup
  %113 = extractvalue { i8*, i32 } %112, 0
  store i8* %113, i8** %exn.slot.i.i172.i.i, align 8
  %114 = extractvalue { i8*, i32 } %112, 1
  store i32 %114, i32* %ehselector.slot.i.i173.i.i, align 4
  br label %ehcleanup28.i.i218.i.i

lpad24.i.i217.i.i:                                ; preds = %invoke.cont22.i.i200.i.i
  %115 = landingpad { i8*, i32 }
          cleanup
  %116 = extractvalue { i8*, i32 } %115, 0
  store i8* %116, i8** %exn.slot.i.i172.i.i, align 8
  %117 = extractvalue { i8*, i32 } %115, 1
  store i32 %117, i32* %ehselector.slot.i.i173.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i.i) #7
  br label %ehcleanup28.i.i218.i.i

ehcleanup28.i.i218.i.i:                           ; preds = %lpad24.i.i217.i.i, %lpad19.i.i216.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i182.i.i) #7
  br label %ehcleanup29.i.i223.i.i

ehcleanup29.i.i223.i.i:                           ; preds = %ehcleanup28.i.i218.i.i, %lpad.i.i203.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i180.i.i) #7
  %exn30.i.i219.i.i = load i8*, i8** %exn.slot.i.i172.i.i, align 8
  %sel31.i.i220.i.i = load i32, i32* %ehselector.slot.i.i173.i.i, align 4
  %lpad.val32.i.i221.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i219.i.i, 0
  %lpad.val33.i.i222.i.i = insertvalue { i8*, i32 } %lpad.val32.i.i221.i.i, i32 %sel31.i.i220.i.i, 1
  br label %lpad4.body.i345.i.i

unreachable.i.i224.i.i:                           ; preds = %lpad11.i.i215.i.i, %ehcleanup.i.i210.i.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i:           ; preds = %sync.continue.i.i202.i.i
  call void @llvm.stackrestore(i8* %savedstack.i178.i.i)
  %savedstack61.i226.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i160.i.i, %class.object.1** %this.addr.i36.i162.i.i, align 8
  %this1.i40.i227.i.i = load %class.object.1*, %class.object.1** %this.addr.i36.i162.i.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i.split

_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i.split:     ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i
  %118 = call token @llvm.taskframe.create()
  %a.i44.i228.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i.i, i32 0, i32 0
  %a2.i45.i229.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i.i, i32 0, i32 0
  detach within %syncreg.i37.i169.i.i, label %det.achd.i49.i233.i.i, label %det.cont.i52.i236.i.i unwind label %lpad4.i58.i250.i.i

det.achd.i49.i233.i.i:                            ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i.split
  %exn.slot.i46.i230.i.i = alloca i8*
  %ehselector.slot.i47.i231.i.i = alloca i32
  call void @llvm.taskframe.use(token %118)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i166.i.i, %class.object.2* dereferenceable(1) %a2.i45.i229.i.i)
  %call.i48.i232.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i228.i.i, %class.object.2* %agg.tmp.i41.i166.i.i)
          to label %invoke.cont.i50.i234.i.i unwind label %lpad.i56.i245.i.i

invoke.cont.i50.i234.i.i:                         ; preds = %det.achd.i49.i233.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i.i) #7
  reattach within %syncreg.i37.i169.i.i, label %det.cont.i52.i236.i.i

det.cont.i52.i236.i.i:                            ; preds = %invoke.cont.i50.i234.i.i, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i.split
  %b.i51.i235.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i165.i.i, %class.object.2* dereferenceable(1) %b.i51.i235.i.i)
          to label %.noexc63.i239.i.i unwind label %lpad8.i346.i.i

.noexc63.i239.i.i:                                ; preds = %det.cont.i52.i236.i.i
  %b15.i.i237.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i.i, i32 0, i32 1
  %call18.i.i238.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i237.i.i, %class.object.2* %agg.tmp14.i.i165.i.i)
          to label %invoke.cont17.i.i240.i.i unwind label %lpad16.i.i252.i.i

invoke.cont17.i.i240.i.i:                         ; preds = %.noexc63.i239.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i.i) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i245.i.i:                                ; preds = %det.achd.i49.i233.i.i
  %119 = landingpad { i8*, i32 }
          cleanup
  %120 = extractvalue { i8*, i32 } %119, 0
  store i8* %120, i8** %exn.slot.i46.i230.i.i, align 8
  %121 = extractvalue { i8*, i32 } %119, 1
  store i32 %121, i32* %ehselector.slot.i47.i231.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i.i) #7
  %exn.i53.i241.i.i = load i8*, i8** %exn.slot.i46.i230.i.i, align 8
  %sel.i54.i242.i.i = load i32, i32* %ehselector.slot.i47.i231.i.i, align 4
  %lpad.val.i55.i243.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i53.i241.i.i, 0
  %lpad.val3.i.i244.i.i = insertvalue { i8*, i32 } %lpad.val.i55.i243.i.i, i32 %sel.i54.i242.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i169.i.i, { i8*, i32 } %lpad.val3.i.i244.i.i)
          to label %unreachable.i60.i258.i.i unwind label %lpad4.i58.i250.i.i

lpad4.i58.i250.i.i:                               ; preds = %lpad.i56.i245.i.i, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i.split
  %122 = landingpad { i8*, i32 }
          cleanup
  %123 = extractvalue { i8*, i32 } %122, 0
  store i8* %123, i8** %exn.slot5.i42.i167.i.i, align 8
  %124 = extractvalue { i8*, i32 } %122, 1
  store i32 %124, i32* %ehselector.slot6.i43.i168.i.i, align 4
  %exn7.i.i246.i.i = load i8*, i8** %exn.slot5.i42.i167.i.i, align 8
  %sel8.i.i247.i.i = load i32, i32* %ehselector.slot6.i43.i168.i.i, align 4
  %lpad.val9.i.i248.i.i = insertvalue { i8*, i32 } undef, i8* %exn7.i.i246.i.i, 0
  %lpad.val10.i57.i249.i.i = insertvalue { i8*, i32 } %lpad.val9.i.i248.i.i, i32 %sel8.i.i247.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %118, { i8*, i32 } %lpad.val10.i57.i249.i.i)
          to label %unreachable.i60.i258.i.i unwind label %lpad11.i59.i251.i.i

lpad11.i59.i251.i.i:                              ; preds = %lpad4.i58.i250.i.i
  %125 = landingpad { i8*, i32 }
          cleanup
  %126 = extractvalue { i8*, i32 } %125, 0
  store i8* %126, i8** %exn.slot12.i38.i163.i.i, align 8
  %127 = extractvalue { i8*, i32 } %125, 1
  store i32 %127, i32* %ehselector.slot13.i39.i164.i.i, align 4
  br label %eh.resume.i.i257.i.i

lpad16.i.i252.i.i:                                ; preds = %.noexc63.i239.i.i
  %128 = landingpad { i8*, i32 }
          cleanup
  %129 = extractvalue { i8*, i32 } %128, 0
  store i8* %129, i8** %exn.slot12.i38.i163.i.i, align 8
  %130 = extractvalue { i8*, i32 } %128, 1
  store i32 %130, i32* %ehselector.slot13.i39.i164.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i.i) #7
  br label %eh.resume.i.i257.i.i

eh.resume.i.i257.i.i:                             ; preds = %lpad16.i.i252.i.i, %lpad11.i59.i251.i.i
  %exn19.i.i253.i.i = load i8*, i8** %exn.slot12.i38.i163.i.i, align 8
  %sel20.i.i254.i.i = load i32, i32* %ehselector.slot13.i39.i164.i.i, align 4
  %lpad.val21.i.i255.i.i = insertvalue { i8*, i32 } undef, i8* %exn19.i.i253.i.i, 0
  %lpad.val22.i.i256.i.i = insertvalue { i8*, i32 } %lpad.val21.i.i255.i.i, i32 %sel20.i.i254.i.i, 1
  br label %lpad8.body.i348.i.i

unreachable.i60.i258.i.i:                         ; preds = %lpad4.i58.i250.i.i, %lpad.i56.i245.i.i
  unreachable

det.cont.i263.i.i:                                ; preds = %invoke.cont.i156.i.i.split
  %131 = load %class.object.0*, %class.object.0** %other.addr.i148.i.i, align 8
  %b21.i259.i.i = getelementptr inbounds %class.object.0, %class.object.0* %131, i32 0, i32 1
  %savedstack116.i260.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i152.i.i, %class.object.1** %this.addr.i65.i141.i.i, align 8
  store %class.object.1* %b21.i259.i.i, %class.object.1** %other.addr.i66.i142.i.i, align 8
  %this1.i71.i261.i.i = load %class.object.1*, %class.object.1** %this.addr.i65.i141.i.i, align 8
  %a.i72.i262.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i262.i.i)
          to label %.noexc117.i265.i.i unwind label %lpad19.i359.i.i

.noexc117.i265.i.i:                               ; preds = %det.cont.i263.i.i
  %b.i73.i264.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i264.i.i)
          to label %invoke.cont.i79.i266.i.i unwind label %lpad.i93.i285.i.i

invoke.cont.i79.i266.i.i:                         ; preds = %.noexc117.i265.i.i
  br label %invoke.cont.i79.i266.i.i.split

invoke.cont.i79.i266.i.i.split:                   ; preds = %invoke.cont.i79.i266.i.i
  %132 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i267.i.i = alloca %class.object.2, align 1
  %exn.slot12.i75.i268.i.i = alloca i8*
  %ehselector.slot13.i76.i269.i.i = alloca i32
  %a2.i77.i270.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i.i, i32 0, i32 0
  %133 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i.i, align 8
  %a3.i78.i271.i.i = getelementptr inbounds %class.object.1, %class.object.1* %133, i32 0, i32 0
  detach within %syncreg.i69.i146.i.i, label %det.achd.i82.i274.i.i, label %det.cont.i87.i279.i.i unwind label %lpad11.i101.i297.i.i

det.achd.i82.i274.i.i:                            ; preds = %invoke.cont.i79.i266.i.i.split
  %exn.slot5.i80.i272.i.i = alloca i8*
  %ehselector.slot6.i81.i273.i.i = alloca i32
  call void @llvm.taskframe.use(token %132)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i267.i.i, %class.object.2* dereferenceable(1) %a3.i78.i271.i.i)
          to label %invoke.cont7.i84.i276.i.i unwind label %lpad4.i94.i286.i.i

invoke.cont7.i84.i276.i.i:                        ; preds = %det.achd.i82.i274.i.i
  %call.i83.i275.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i270.i.i, %class.object.2* %agg.tmp.i74.i267.i.i)
          to label %invoke.cont9.i85.i277.i.i unwind label %lpad8.i95.i287.i.i

invoke.cont9.i85.i277.i.i:                        ; preds = %invoke.cont7.i84.i276.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i.i) #7
  reattach within %syncreg.i69.i146.i.i, label %det.cont.i87.i279.i.i

det.cont.i87.i279.i.i:                            ; preds = %invoke.cont9.i85.i277.i.i, %invoke.cont.i79.i266.i.i.split
  %134 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i.i, align 8
  %b21.i86.i278.i.i = getelementptr inbounds %class.object.1, %class.object.1* %134, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i145.i.i, %class.object.2* dereferenceable(1) %b21.i86.i278.i.i)
          to label %invoke.cont22.i90.i282.i.i unwind label %lpad19.i106.i298.i.i

invoke.cont22.i90.i282.i.i:                       ; preds = %det.cont.i87.i279.i.i
  %b23.i88.i280.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i.i, i32 0, i32 1
  %call26.i89.i281.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i280.i.i, %class.object.2* %agg.tmp20.i70.i145.i.i)
          to label %invoke.cont25.i91.i283.i.i unwind label %lpad24.i107.i299.i.i

invoke.cont25.i91.i283.i.i:                       ; preds = %invoke.cont22.i90.i282.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i.i) #7
  sync within %syncreg.i69.i146.i.i, label %sync.continue.i92.i284.i.i

sync.continue.i92.i284.i.i:                       ; preds = %invoke.cont25.i91.i283.i.i
  invoke void @llvm.sync.unwind(token %syncreg.i69.i146.i.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i unwind label %lpad19.i359.i.i

lpad.i93.i285.i.i:                                ; preds = %.noexc117.i265.i.i
  %135 = landingpad { i8*, i32 }
          cleanup
  %136 = extractvalue { i8*, i32 } %135, 0
  store i8* %136, i8** %exn.slot.i67.i143.i.i, align 8
  %137 = extractvalue { i8*, i32 } %135, 1
  store i32 %137, i32* %ehselector.slot.i68.i144.i.i, align 4
  br label %ehcleanup29.i109.i305.i.i

lpad4.i94.i286.i.i:                               ; preds = %det.achd.i82.i274.i.i
  %138 = landingpad { i8*, i32 }
          cleanup
  %139 = extractvalue { i8*, i32 } %138, 0
  store i8* %139, i8** %exn.slot5.i80.i272.i.i, align 8
  %140 = extractvalue { i8*, i32 } %138, 1
  store i32 %140, i32* %ehselector.slot6.i81.i273.i.i, align 4
  br label %ehcleanup.i100.i292.i.i

lpad8.i95.i287.i.i:                               ; preds = %invoke.cont7.i84.i276.i.i
  %141 = landingpad { i8*, i32 }
          cleanup
  %142 = extractvalue { i8*, i32 } %141, 0
  store i8* %142, i8** %exn.slot5.i80.i272.i.i, align 8
  %143 = extractvalue { i8*, i32 } %141, 1
  store i32 %143, i32* %ehselector.slot6.i81.i273.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i.i) #7
  br label %ehcleanup.i100.i292.i.i

ehcleanup.i100.i292.i.i:                          ; preds = %lpad8.i95.i287.i.i, %lpad4.i94.i286.i.i
  %exn.i96.i288.i.i = load i8*, i8** %exn.slot5.i80.i272.i.i, align 8
  %sel.i97.i289.i.i = load i32, i32* %ehselector.slot6.i81.i273.i.i, align 4
  %lpad.val.i98.i290.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i96.i288.i.i, 0
  %lpad.val10.i99.i291.i.i = insertvalue { i8*, i32 } %lpad.val.i98.i290.i.i, i32 %sel.i97.i289.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i146.i.i, { i8*, i32 } %lpad.val10.i99.i291.i.i)
          to label %unreachable.i115.i306.i.i unwind label %lpad11.i101.i297.i.i

lpad11.i101.i297.i.i:                             ; preds = %ehcleanup.i100.i292.i.i, %invoke.cont.i79.i266.i.i.split
  %144 = landingpad { i8*, i32 }
          cleanup
  %145 = extractvalue { i8*, i32 } %144, 0
  store i8* %145, i8** %exn.slot12.i75.i268.i.i, align 8
  %146 = extractvalue { i8*, i32 } %144, 1
  store i32 %146, i32* %ehselector.slot13.i76.i269.i.i, align 4
  %exn15.i102.i293.i.i = load i8*, i8** %exn.slot12.i75.i268.i.i, align 8
  %sel16.i103.i294.i.i = load i32, i32* %ehselector.slot13.i76.i269.i.i, align 4
  %lpad.val17.i104.i295.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i293.i.i, 0
  %lpad.val18.i105.i296.i.i = insertvalue { i8*, i32 } %lpad.val17.i104.i295.i.i, i32 %sel16.i103.i294.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %132, { i8*, i32 } %lpad.val18.i105.i296.i.i)
          to label %unreachable.i115.i306.i.i unwind label %lpad19.i106.i298.i.i

lpad19.i106.i298.i.i:                             ; preds = %lpad11.i101.i297.i.i, %det.cont.i87.i279.i.i
  %147 = landingpad { i8*, i32 }
          cleanup
  %148 = extractvalue { i8*, i32 } %147, 0
  store i8* %148, i8** %exn.slot.i67.i143.i.i, align 8
  %149 = extractvalue { i8*, i32 } %147, 1
  store i32 %149, i32* %ehselector.slot.i68.i144.i.i, align 4
  br label %ehcleanup28.i108.i300.i.i

lpad24.i107.i299.i.i:                             ; preds = %invoke.cont22.i90.i282.i.i
  %150 = landingpad { i8*, i32 }
          cleanup
  %151 = extractvalue { i8*, i32 } %150, 0
  store i8* %151, i8** %exn.slot.i67.i143.i.i, align 8
  %152 = extractvalue { i8*, i32 } %150, 1
  store i32 %152, i32* %ehselector.slot.i68.i144.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i.i) #7
  br label %ehcleanup28.i108.i300.i.i

ehcleanup28.i108.i300.i.i:                        ; preds = %lpad24.i107.i299.i.i, %lpad19.i106.i298.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i264.i.i) #7
  br label %ehcleanup29.i109.i305.i.i

ehcleanup29.i109.i305.i.i:                        ; preds = %ehcleanup28.i108.i300.i.i, %lpad.i93.i285.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i262.i.i) #7
  %exn30.i110.i301.i.i = load i8*, i8** %exn.slot.i67.i143.i.i, align 8
  %sel31.i111.i302.i.i = load i32, i32* %ehselector.slot.i68.i144.i.i, align 4
  %lpad.val32.i112.i303.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i301.i.i, 0
  %lpad.val33.i113.i304.i.i = insertvalue { i8*, i32 } %lpad.val32.i112.i303.i.i, i32 %sel31.i111.i302.i.i, 1
  br label %lpad19.body.i361.i.i

unreachable.i115.i306.i.i:                        ; preds = %lpad11.i101.i297.i.i, %ehcleanup.i100.i292.i.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i:        ; preds = %sync.continue.i92.i284.i.i
  call void @llvm.stackrestore(i8* %savedstack116.i260.i.i)
  %b23.i308.i.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i.i, i32 0, i32 1
  %savedstack161.i309.i.i = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i308.i.i, %class.object.1** %this.addr.i122.i133.i.i, align 8
  %this1.i127.i310.i.i = load %class.object.1*, %class.object.1** %this.addr.i122.i133.i.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i.split

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i.split:  ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i
  %153 = call token @llvm.taskframe.create()
  %a.i131.i311.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i.i, i32 0, i32 0
  %a2.i132.i312.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i.i, i32 0, i32 0
  detach within %syncreg.i123.i140.i.i, label %det.achd.i136.i316.i.i, label %det.cont.i141.i319.i.i unwind label %lpad4.i152.i333.i.i

det.achd.i136.i316.i.i:                           ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i.split
  %exn.slot.i133.i313.i.i = alloca i8*
  %ehselector.slot.i134.i314.i.i = alloca i32
  call void @llvm.taskframe.use(token %153)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i137.i.i, %class.object.2* dereferenceable(1) %a2.i132.i312.i.i)
  %call.i135.i315.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i311.i.i, %class.object.2* %agg.tmp.i128.i137.i.i)
          to label %invoke.cont.i137.i317.i.i unwind label %lpad.i147.i328.i.i

invoke.cont.i137.i317.i.i:                        ; preds = %det.achd.i136.i316.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i.i) #7
  reattach within %syncreg.i123.i140.i.i, label %det.cont.i141.i319.i.i

det.cont.i141.i319.i.i:                           ; preds = %invoke.cont.i137.i317.i.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i.split
  %b.i138.i318.i.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i136.i.i, %class.object.2* dereferenceable(1) %b.i138.i318.i.i)
          to label %.noexc164.i322.i.i unwind label %lpad24.i362.i.i

.noexc164.i322.i.i:                               ; preds = %det.cont.i141.i319.i.i
  %b15.i139.i320.i.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i.i, i32 0, i32 1
  %call18.i140.i321.i.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i320.i.i, %class.object.2* %agg.tmp14.i126.i136.i.i)
          to label %invoke.cont17.i142.i323.i.i unwind label %lpad16.i154.i335.i.i

invoke.cont17.i142.i323.i.i:                      ; preds = %.noexc164.i322.i.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i.i) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i328.i.i:                               ; preds = %det.achd.i136.i316.i.i
  %154 = landingpad { i8*, i32 }
          cleanup
  %155 = extractvalue { i8*, i32 } %154, 0
  store i8* %155, i8** %exn.slot.i133.i313.i.i, align 8
  %156 = extractvalue { i8*, i32 } %154, 1
  store i32 %156, i32* %ehselector.slot.i134.i314.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i.i) #7
  %exn.i143.i324.i.i = load i8*, i8** %exn.slot.i133.i313.i.i, align 8
  %sel.i144.i325.i.i = load i32, i32* %ehselector.slot.i134.i314.i.i, align 4
  %lpad.val.i145.i326.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i143.i324.i.i, 0
  %lpad.val3.i146.i327.i.i = insertvalue { i8*, i32 } %lpad.val.i145.i326.i.i, i32 %sel.i144.i325.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i140.i.i, { i8*, i32 } %lpad.val3.i146.i327.i.i)
          to label %unreachable.i160.i341.i.i unwind label %lpad4.i152.i333.i.i

lpad4.i152.i333.i.i:                              ; preds = %lpad.i147.i328.i.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i.split
  %157 = landingpad { i8*, i32 }
          cleanup
  %158 = extractvalue { i8*, i32 } %157, 0
  store i8* %158, i8** %exn.slot5.i129.i138.i.i, align 8
  %159 = extractvalue { i8*, i32 } %157, 1
  store i32 %159, i32* %ehselector.slot6.i130.i139.i.i, align 4
  %exn7.i148.i329.i.i = load i8*, i8** %exn.slot5.i129.i138.i.i, align 8
  %sel8.i149.i330.i.i = load i32, i32* %ehselector.slot6.i130.i139.i.i, align 4
  %lpad.val9.i150.i331.i.i = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i329.i.i, 0
  %lpad.val10.i151.i332.i.i = insertvalue { i8*, i32 } %lpad.val9.i150.i331.i.i, i32 %sel8.i149.i330.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %153, { i8*, i32 } %lpad.val10.i151.i332.i.i)
          to label %unreachable.i160.i341.i.i unwind label %lpad11.i153.i334.i.i

lpad11.i153.i334.i.i:                             ; preds = %lpad4.i152.i333.i.i
  %160 = landingpad { i8*, i32 }
          cleanup
  %161 = extractvalue { i8*, i32 } %160, 0
  store i8* %161, i8** %exn.slot12.i124.i134.i.i, align 8
  %162 = extractvalue { i8*, i32 } %160, 1
  store i32 %162, i32* %ehselector.slot13.i125.i135.i.i, align 4
  br label %eh.resume.i159.i340.i.i

lpad16.i154.i335.i.i:                             ; preds = %.noexc164.i322.i.i
  %163 = landingpad { i8*, i32 }
          cleanup
  %164 = extractvalue { i8*, i32 } %163, 0
  store i8* %164, i8** %exn.slot12.i124.i134.i.i, align 8
  %165 = extractvalue { i8*, i32 } %163, 1
  store i32 %165, i32* %ehselector.slot13.i125.i135.i.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i.i) #7
  br label %eh.resume.i159.i340.i.i

eh.resume.i159.i340.i.i:                          ; preds = %lpad16.i154.i335.i.i, %lpad11.i153.i334.i.i
  %exn19.i155.i336.i.i = load i8*, i8** %exn.slot12.i124.i134.i.i, align 8
  %sel20.i156.i337.i.i = load i32, i32* %ehselector.slot13.i125.i135.i.i, align 4
  %lpad.val21.i157.i338.i.i = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i336.i.i, 0
  %lpad.val22.i158.i339.i.i = insertvalue { i8*, i32 } %lpad.val21.i157.i338.i.i, i32 %sel20.i156.i337.i.i, 1
  br label %lpad24.body.i364.i.i

unreachable.i160.i341.i.i:                        ; preds = %lpad4.i152.i333.i.i, %lpad.i147.i328.i.i
  unreachable

lpad.i342.i.i:                                    ; preds = %.noexc374.i.i
  %166 = landingpad { i8*, i32 }
          cleanup
  %167 = extractvalue { i8*, i32 } %166, 0
  store i8* %167, i8** %exn.slot.i149.i.i, align 8
  %168 = extractvalue { i8*, i32 } %166, 1
  store i32 %168, i32* %ehselector.slot.i150.i.i, align 4
  br label %ehcleanup29.i366.i.i

lpad4.i343.i.i:                                   ; preds = %sync.continue.i.i202.i.i, %det.achd.i181.i.i
  %169 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i345.i.i

lpad4.body.i345.i.i:                              ; preds = %lpad4.i343.i.i, %ehcleanup29.i.i223.i.i
  %eh.lpad-body.i344.i.i = phi { i8*, i32 } [ %169, %lpad4.i343.i.i ], [ %lpad.val33.i.i222.i.i, %ehcleanup29.i.i223.i.i ]
  %170 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i.i, 0
  store i8* %170, i8** %exn.slot5.i176.i.i, align 8
  %171 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i.i, 1
  store i32 %171, i32* %ehselector.slot6.i177.i.i, align 4
  br label %ehcleanup.i353.i.i

lpad8.i346.i.i:                                   ; preds = %det.cont.i52.i236.i.i
  %172 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i348.i.i

lpad8.body.i348.i.i:                              ; preds = %lpad8.i346.i.i, %eh.resume.i.i257.i.i
  %eh.lpad-body64.i347.i.i = phi { i8*, i32 } [ %172, %lpad8.i346.i.i ], [ %lpad.val22.i.i256.i.i, %eh.resume.i.i257.i.i ]
  %173 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i.i, 0
  store i8* %173, i8** %exn.slot5.i176.i.i, align 8
  %174 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i.i, 1
  store i32 %174, i32* %ehselector.slot6.i177.i.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i157.i.i) #7
  br label %ehcleanup.i353.i.i

ehcleanup.i353.i.i:                               ; preds = %lpad8.body.i348.i.i, %lpad4.body.i345.i.i
  %exn.i349.i.i = load i8*, i8** %exn.slot5.i176.i.i, align 8
  %sel.i350.i.i = load i32, i32* %ehselector.slot6.i177.i.i, align 4
  %lpad.val.i351.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i349.i.i, 0
  %lpad.val10.i352.i.i = insertvalue { i8*, i32 } %lpad.val.i351.i.i, i32 %sel.i350.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i151.i.i, { i8*, i32 } %lpad.val10.i352.i.i)
          to label %unreachable.i372.i.i unwind label %lpad11.i354.i.i

lpad11.i354.i.i:                                  ; preds = %ehcleanup.i353.i.i, %invoke.cont.i156.i.i.split
  %175 = landingpad { i8*, i32 }
          cleanup
  %176 = extractvalue { i8*, i32 } %175, 0
  store i8* %176, i8** %exn.slot12.i158.i.i, align 8
  %177 = extractvalue { i8*, i32 } %175, 1
  store i32 %177, i32* %ehselector.slot13.i159.i.i, align 4
  %exn15.i355.i.i = load i8*, i8** %exn.slot12.i158.i.i, align 8
  %sel16.i356.i.i = load i32, i32* %ehselector.slot13.i159.i.i, align 4
  %lpad.val17.i357.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i355.i.i, 0
  %lpad.val18.i358.i.i = insertvalue { i8*, i32 } %lpad.val17.i357.i.i, i32 %sel16.i356.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %95, { i8*, i32 } %lpad.val18.i358.i.i)
          to label %unreachable.i372.i.i unwind label %lpad19.i359.i.i

lpad19.i359.i.i:                                  ; preds = %lpad11.i354.i.i, %sync.continue.i92.i284.i.i, %det.cont.i263.i.i
  %178 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i361.i.i

lpad19.body.i361.i.i:                             ; preds = %lpad19.i359.i.i, %ehcleanup29.i109.i305.i.i
  %eh.lpad-body118.i360.i.i = phi { i8*, i32 } [ %178, %lpad19.i359.i.i ], [ %lpad.val33.i113.i304.i.i, %ehcleanup29.i109.i305.i.i ]
  %179 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i.i, 0
  store i8* %179, i8** %exn.slot.i149.i.i, align 8
  %180 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i.i, 1
  store i32 %180, i32* %ehselector.slot.i150.i.i, align 4
  br label %ehcleanup28.i365.i.i

lpad24.i362.i.i:                                  ; preds = %det.cont.i141.i319.i.i
  %181 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i364.i.i

lpad24.body.i364.i.i:                             ; preds = %lpad24.i362.i.i, %eh.resume.i159.i340.i.i
  %eh.lpad-body165.i363.i.i = phi { i8*, i32 } [ %181, %lpad24.i362.i.i ], [ %lpad.val22.i158.i339.i.i, %eh.resume.i159.i340.i.i ]
  %182 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i.i, 0
  store i8* %182, i8** %exn.slot.i149.i.i, align 8
  %183 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i.i, 1
  store i32 %183, i32* %ehselector.slot.i150.i.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i152.i.i) #7
  br label %ehcleanup28.i365.i.i

ehcleanup28.i365.i.i:                             ; preds = %lpad24.body.i364.i.i, %lpad19.body.i361.i.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i155.i.i) #7
  br label %ehcleanup29.i366.i.i

ehcleanup29.i366.i.i:                             ; preds = %ehcleanup28.i365.i.i, %lpad.i342.i.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i154.i.i) #7
  %exn30.i367.i.i = load i8*, i8** %exn.slot.i149.i.i, align 8
  %sel31.i368.i.i = load i32, i32* %ehselector.slot.i150.i.i, align 4
  %lpad.val32.i369.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i367.i.i, 0
  %lpad.val33.i370.i.i = insertvalue { i8*, i32 } %lpad.val32.i369.i.i, i32 %sel31.i368.i.i, 1
  br label %lpad19.body.i.i

unreachable.i372.i.i:                             ; preds = %lpad11.i354.i.i, %ehcleanup.i353.i.i
  unreachable

lpad.i.i:                                         ; preds = %.noexc.i
  %184 = landingpad { i8*, i32 }
          cleanup
  %185 = extractvalue { i8*, i32 } %184, 0
  store i8* %185, i8** %exn.slot.i.i, align 8
  %186 = extractvalue { i8*, i32 } %184, 1
  store i32 %186, i32* %ehselector.slot.i.i, align 4
  br label %ehcleanup29.i.i

lpad4.i.i:                                        ; preds = %det.achd.i.i
  %187 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i.i

lpad4.body.i.i:                                   ; preds = %lpad4.i.i, %ehcleanup29.i.i.i
  %eh.lpad-body.i.i = phi { i8*, i32 } [ %187, %lpad4.i.i ], [ %lpad.val33.i.i.i, %ehcleanup29.i.i.i ]
  %188 = extractvalue { i8*, i32 } %eh.lpad-body.i.i, 0
  store i8* %188, i8** %exn.slot5.i.i, align 8
  %189 = extractvalue { i8*, i32 } %eh.lpad-body.i.i, 1
  store i32 %189, i32* %ehselector.slot6.i.i, align 4
  %exn.i.i = load i8*, i8** %exn.slot5.i.i, align 8
  %sel.i.i = load i32, i32* %ehselector.slot6.i.i, align 4
  %lpad.val.i.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i, 0
  %lpad.val10.i.i = insertvalue { i8*, i32 } %lpad.val.i.i, i32 %sel.i.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i, { i8*, i32 } %lpad.val10.i.i)
          to label %unreachable.i.i unwind label %lpad11.i.i

lpad11.i.i:                                       ; preds = %lpad4.body.i.i, %invoke.cont.i.i.split
  %190 = landingpad { i8*, i32 }
          cleanup
  %191 = extractvalue { i8*, i32 } %190, 0
  store i8* %191, i8** %exn.slot12.i.i, align 8
  %192 = extractvalue { i8*, i32 } %190, 1
  store i32 %192, i32* %ehselector.slot13.i.i, align 4
  %exn15.i.i = load i8*, i8** %exn.slot12.i.i, align 8
  %sel16.i.i = load i32, i32* %ehselector.slot13.i.i, align 4
  %lpad.val17.i.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i, 0
  %lpad.val18.i.i = insertvalue { i8*, i32 } %lpad.val17.i.i, i32 %sel16.i.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %3, { i8*, i32 } %lpad.val18.i.i)
          to label %unreachable.i.i unwind label %lpad19.i.i

lpad19.i.i:                                       ; preds = %lpad11.i.i, %det.cont.i.i
  %193 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i.i

lpad19.body.i.i:                                  ; preds = %lpad19.i.i, %ehcleanup29.i366.i.i
  %eh.lpad-body375.i.i = phi { i8*, i32 } [ %193, %lpad19.i.i ], [ %lpad.val33.i370.i.i, %ehcleanup29.i366.i.i ]
  %194 = extractvalue { i8*, i32 } %eh.lpad-body375.i.i, 0
  store i8* %194, i8** %exn.slot.i.i, align 8
  %195 = extractvalue { i8*, i32 } %eh.lpad-body375.i.i, 1
  store i32 %195, i32* %ehselector.slot.i.i, align 4
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %b.i.i) #7
  br label %ehcleanup29.i.i

ehcleanup29.i.i:                                  ; preds = %lpad19.body.i.i, %lpad.i.i
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %a.i.i) #7
  %exn30.i.i = load i8*, i8** %exn.slot.i.i, align 8
  %sel31.i.i = load i32, i32* %ehselector.slot.i.i, align 4
  %lpad.val32.i.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i, 0
  %lpad.val33.i.i = insertvalue { i8*, i32 } %lpad.val32.i.i, i32 %sel31.i.i, 1
  br label %lpad4.body.i

unreachable.i.i:                                  ; preds = %lpad11.i.i, %lpad4.body.i.i
  unreachable

det.cont.i:                                       ; preds = %invoke.cont.i.split
  %196 = load %class.object.3*, %class.object.3** %other.addr.i, align 8
  %b21.i = getelementptr inbounds %class.object.3, %class.object.3* %196, i32 0, i32 1
  %savedstack832.i = call i8* @llvm.stacksave()
  store %class.object* %agg.tmp20.i, %class.object** %this.addr.i328.i, align 8
  store %class.object* %b21.i, %class.object** %other.addr.i329.i, align 8
  %this1.i334.i = load %class.object*, %class.object** %this.addr.i328.i, align 8
  %a.i335.i = getelementptr inbounds %class.object, %class.object* %this1.i334.i, i32 0, i32 0
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %a.i335.i)
          to label %.noexc833.i unwind label %lpad19.i

.noexc833.i:                                      ; preds = %det.cont.i
  %b.i336.i = getelementptr inbounds %class.object, %class.object* %this1.i334.i, i32 0, i32 1
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %b.i336.i)
          to label %invoke.cont.i337.i unwind label %lpad.i810.i

invoke.cont.i337.i:                               ; preds = %.noexc833.i
  br label %invoke.cont.i337.i.split

invoke.cont.i337.i.split:                         ; preds = %invoke.cont.i337.i
  %197 = call token @llvm.taskframe.create()
  %agg.tmp.i338.i = alloca %class.object.0, align 1
  %exn.slot12.i339.i = alloca i8*
  %ehselector.slot13.i340.i = alloca i32
  %a2.i341.i = getelementptr inbounds %class.object, %class.object* %this1.i334.i, i32 0, i32 0
  %198 = load %class.object*, %class.object** %other.addr.i329.i, align 8
  %a3.i342.i = getelementptr inbounds %class.object, %class.object* %198, i32 0, i32 0
  detach within %syncreg.i332.i, label %det.achd.i368.i, label %det.cont.i591.i unwind label %lpad11.i818.i

det.achd.i368.i:                                  ; preds = %invoke.cont.i337.i.split
  %this.addr.i122.i.i343.i = alloca %class.object.1*, align 8
  %exn.slot12.i124.i.i344.i = alloca i8*
  %ehselector.slot13.i125.i.i345.i = alloca i32
  %agg.tmp14.i126.i.i346.i = alloca %class.object.2, align 1
  %agg.tmp.i128.i.i347.i = alloca %class.object.2, align 1
  %exn.slot5.i129.i.i348.i = alloca i8*
  %ehselector.slot6.i130.i.i349.i = alloca i32
  %this.addr.i65.i.i350.i = alloca %class.object.1*, align 8
  %other.addr.i66.i.i351.i = alloca %class.object.1*, align 8
  %exn.slot.i67.i.i352.i = alloca i8*
  %ehselector.slot.i68.i.i353.i = alloca i32
  %agg.tmp20.i70.i.i354.i = alloca %class.object.2, align 1
  %this.addr.i.i355.i = alloca %class.object.0*, align 8
  %other.addr.i.i356.i = alloca %class.object.0*, align 8
  %exn.slot.i.i357.i = alloca i8*
  %ehselector.slot.i.i358.i = alloca i32
  %agg.tmp20.i.i359.i = alloca %class.object.1, align 1
  %syncreg.i123.i.i360.i = call token @llvm.syncregion.start()
  %syncreg.i69.i.i361.i = call token @llvm.syncregion.start()
  %syncreg.i.i362.i = call token @llvm.syncregion.start()
  %exn.slot5.i363.i = alloca i8*
  %ehselector.slot6.i364.i = alloca i32
  call void @llvm.taskframe.use(token %197)
  %savedstack.i365.i = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp.i338.i, %class.object.0** %this.addr.i.i355.i, align 8
  store %class.object.0* %a3.i342.i, %class.object.0** %other.addr.i.i356.i, align 8
  %this1.i.i366.i = load %class.object.0*, %class.object.0** %this.addr.i.i355.i, align 8
  %a.i.i367.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i366.i, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i.i367.i)
          to label %.noexc.i370.i unwind label %lpad4.i811.i

.noexc.i370.i:                                    ; preds = %det.achd.i368.i
  %b.i.i369.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i366.i, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i.i369.i)
          to label %invoke.cont.i.i371.i unwind label %lpad.i.i557.i

invoke.cont.i.i371.i:                             ; preds = %.noexc.i370.i
  br label %invoke.cont.i.i371.i.split

invoke.cont.i.i371.i.split:                       ; preds = %invoke.cont.i.i371.i
  %199 = call token @llvm.taskframe.create()
  %agg.tmp.i.i372.i = alloca %class.object.1, align 1
  %exn.slot12.i.i373.i = alloca i8*
  %ehselector.slot13.i.i374.i = alloca i32
  %a2.i.i375.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i366.i, i32 0, i32 0
  %200 = load %class.object.0*, %class.object.0** %other.addr.i.i356.i, align 8
  %a3.i.i376.i = getelementptr inbounds %class.object.0, %class.object.0* %200, i32 0, i32 0
  detach within %syncreg.i.i362.i, label %det.achd.i.i396.i, label %det.cont.i.i478.i unwind label %lpad11.i.i573.i

det.achd.i.i396.i:                                ; preds = %invoke.cont.i.i371.i.split
  %this.addr.i36.i.i377.i = alloca %class.object.1*, align 8
  %exn.slot12.i38.i.i378.i = alloca i8*
  %ehselector.slot13.i39.i.i379.i = alloca i32
  %agg.tmp14.i.i.i380.i = alloca %class.object.2, align 1
  %agg.tmp.i41.i.i381.i = alloca %class.object.2, align 1
  %exn.slot5.i42.i.i382.i = alloca i8*
  %ehselector.slot6.i43.i.i383.i = alloca i32
  %syncreg.i37.i.i384.i = call token @llvm.syncregion.start()
  %this.addr.i.i.i385.i = alloca %class.object.1*, align 8
  %other.addr.i.i.i386.i = alloca %class.object.1*, align 8
  %exn.slot.i.i.i387.i = alloca i8*
  %ehselector.slot.i.i.i388.i = alloca i32
  %agg.tmp20.i.i.i389.i = alloca %class.object.2, align 1
  %syncreg.i.i.i390.i = call token @llvm.syncregion.start()
  %exn.slot5.i.i391.i = alloca i8*
  %ehselector.slot6.i.i392.i = alloca i32
  call void @llvm.taskframe.use(token %199)
  %savedstack.i.i393.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i.i372.i, %class.object.1** %this.addr.i.i.i385.i, align 8
  store %class.object.1* %a3.i.i376.i, %class.object.1** %other.addr.i.i.i386.i, align 8
  %this1.i.i.i394.i = load %class.object.1*, %class.object.1** %this.addr.i.i.i385.i, align 8
  %a.i.i.i395.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i394.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i.i395.i)
          to label %.noexc.i.i398.i unwind label %lpad4.i.i558.i

.noexc.i.i398.i:                                  ; preds = %det.achd.i.i396.i
  %b.i.i.i397.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i394.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i.i397.i)
          to label %invoke.cont.i.i.i399.i unwind label %lpad.i.i.i418.i

invoke.cont.i.i.i399.i:                           ; preds = %.noexc.i.i398.i
  br label %invoke.cont.i.i.i399.i.split

invoke.cont.i.i.i399.i.split:                     ; preds = %invoke.cont.i.i.i399.i
  %201 = call token @llvm.taskframe.create()
  %agg.tmp.i.i.i400.i = alloca %class.object.2, align 1
  %exn.slot12.i.i.i401.i = alloca i8*
  %ehselector.slot13.i.i.i402.i = alloca i32
  %a2.i.i.i403.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i394.i, i32 0, i32 0
  %202 = load %class.object.1*, %class.object.1** %other.addr.i.i.i386.i, align 8
  %a3.i.i.i404.i = getelementptr inbounds %class.object.1, %class.object.1* %202, i32 0, i32 0
  detach within %syncreg.i.i.i390.i, label %det.achd.i.i.i407.i, label %det.cont.i.i.i412.i unwind label %lpad11.i.i.i430.i

det.achd.i.i.i407.i:                              ; preds = %invoke.cont.i.i.i399.i.split
  %exn.slot5.i.i.i405.i = alloca i8*
  %ehselector.slot6.i.i.i406.i = alloca i32
  call void @llvm.taskframe.use(token %201)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i.i400.i, %class.object.2* dereferenceable(1) %a3.i.i.i404.i)
          to label %invoke.cont7.i.i.i409.i unwind label %lpad4.i.i.i419.i

invoke.cont7.i.i.i409.i:                          ; preds = %det.achd.i.i.i407.i
  %call.i.i.i408.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i.i403.i, %class.object.2* %agg.tmp.i.i.i400.i)
          to label %invoke.cont9.i.i.i410.i unwind label %lpad8.i.i.i420.i

invoke.cont9.i.i.i410.i:                          ; preds = %invoke.cont7.i.i.i409.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i400.i) #7
  reattach within %syncreg.i.i.i390.i, label %det.cont.i.i.i412.i

det.cont.i.i.i412.i:                              ; preds = %invoke.cont9.i.i.i410.i, %invoke.cont.i.i.i399.i.split
  %203 = load %class.object.1*, %class.object.1** %other.addr.i.i.i386.i, align 8
  %b21.i.i.i411.i = getelementptr inbounds %class.object.1, %class.object.1* %203, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i.i389.i, %class.object.2* dereferenceable(1) %b21.i.i.i411.i)
          to label %invoke.cont22.i.i.i415.i unwind label %lpad19.i.i.i431.i

invoke.cont22.i.i.i415.i:                         ; preds = %det.cont.i.i.i412.i
  %b23.i.i.i413.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i394.i, i32 0, i32 1
  %call26.i.i.i414.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i.i413.i, %class.object.2* %agg.tmp20.i.i.i389.i)
          to label %invoke.cont25.i.i.i416.i unwind label %lpad24.i.i.i432.i

invoke.cont25.i.i.i416.i:                         ; preds = %invoke.cont22.i.i.i415.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i389.i) #7
  sync within %syncreg.i.i.i390.i, label %sync.continue.i.i.i417.i

sync.continue.i.i.i417.i:                         ; preds = %invoke.cont25.i.i.i416.i
  invoke void @llvm.sync.unwind(token %syncreg.i.i.i390.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i unwind label %lpad4.i.i558.i

lpad.i.i.i418.i:                                  ; preds = %.noexc.i.i398.i
  %204 = landingpad { i8*, i32 }
          cleanup
  %205 = extractvalue { i8*, i32 } %204, 0
  store i8* %205, i8** %exn.slot.i.i.i387.i, align 8
  %206 = extractvalue { i8*, i32 } %204, 1
  store i32 %206, i32* %ehselector.slot.i.i.i388.i, align 4
  br label %ehcleanup29.i.i.i438.i

lpad4.i.i.i419.i:                                 ; preds = %det.achd.i.i.i407.i
  %207 = landingpad { i8*, i32 }
          cleanup
  %208 = extractvalue { i8*, i32 } %207, 0
  store i8* %208, i8** %exn.slot5.i.i.i405.i, align 8
  %209 = extractvalue { i8*, i32 } %207, 1
  store i32 %209, i32* %ehselector.slot6.i.i.i406.i, align 4
  br label %ehcleanup.i.i.i425.i

lpad8.i.i.i420.i:                                 ; preds = %invoke.cont7.i.i.i409.i
  %210 = landingpad { i8*, i32 }
          cleanup
  %211 = extractvalue { i8*, i32 } %210, 0
  store i8* %211, i8** %exn.slot5.i.i.i405.i, align 8
  %212 = extractvalue { i8*, i32 } %210, 1
  store i32 %212, i32* %ehselector.slot6.i.i.i406.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i400.i) #7
  br label %ehcleanup.i.i.i425.i

ehcleanup.i.i.i425.i:                             ; preds = %lpad8.i.i.i420.i, %lpad4.i.i.i419.i
  %exn.i.i.i421.i = load i8*, i8** %exn.slot5.i.i.i405.i, align 8
  %sel.i.i.i422.i = load i32, i32* %ehselector.slot6.i.i.i406.i, align 4
  %lpad.val.i.i.i423.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i.i421.i, 0
  %lpad.val10.i.i.i424.i = insertvalue { i8*, i32 } %lpad.val.i.i.i423.i, i32 %sel.i.i.i422.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i.i390.i, { i8*, i32 } %lpad.val10.i.i.i424.i)
          to label %unreachable.i.i.i439.i unwind label %lpad11.i.i.i430.i

lpad11.i.i.i430.i:                                ; preds = %ehcleanup.i.i.i425.i, %invoke.cont.i.i.i399.i.split
  %213 = landingpad { i8*, i32 }
          cleanup
  %214 = extractvalue { i8*, i32 } %213, 0
  store i8* %214, i8** %exn.slot12.i.i.i401.i, align 8
  %215 = extractvalue { i8*, i32 } %213, 1
  store i32 %215, i32* %ehselector.slot13.i.i.i402.i, align 4
  %exn15.i.i.i426.i = load i8*, i8** %exn.slot12.i.i.i401.i, align 8
  %sel16.i.i.i427.i = load i32, i32* %ehselector.slot13.i.i.i402.i, align 4
  %lpad.val17.i.i.i428.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i.i426.i, 0
  %lpad.val18.i.i.i429.i = insertvalue { i8*, i32 } %lpad.val17.i.i.i428.i, i32 %sel16.i.i.i427.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %201, { i8*, i32 } %lpad.val18.i.i.i429.i)
          to label %unreachable.i.i.i439.i unwind label %lpad19.i.i.i431.i

lpad19.i.i.i431.i:                                ; preds = %lpad11.i.i.i430.i, %det.cont.i.i.i412.i
  %216 = landingpad { i8*, i32 }
          cleanup
  %217 = extractvalue { i8*, i32 } %216, 0
  store i8* %217, i8** %exn.slot.i.i.i387.i, align 8
  %218 = extractvalue { i8*, i32 } %216, 1
  store i32 %218, i32* %ehselector.slot.i.i.i388.i, align 4
  br label %ehcleanup28.i.i.i433.i

lpad24.i.i.i432.i:                                ; preds = %invoke.cont22.i.i.i415.i
  %219 = landingpad { i8*, i32 }
          cleanup
  %220 = extractvalue { i8*, i32 } %219, 0
  store i8* %220, i8** %exn.slot.i.i.i387.i, align 8
  %221 = extractvalue { i8*, i32 } %219, 1
  store i32 %221, i32* %ehselector.slot.i.i.i388.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i389.i) #7
  br label %ehcleanup28.i.i.i433.i

ehcleanup28.i.i.i433.i:                           ; preds = %lpad24.i.i.i432.i, %lpad19.i.i.i431.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i.i397.i) #7
  br label %ehcleanup29.i.i.i438.i

ehcleanup29.i.i.i438.i:                           ; preds = %ehcleanup28.i.i.i433.i, %lpad.i.i.i418.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i.i395.i) #7
  %exn30.i.i.i434.i = load i8*, i8** %exn.slot.i.i.i387.i, align 8
  %sel31.i.i.i435.i = load i32, i32* %ehselector.slot.i.i.i388.i, align 4
  %lpad.val32.i.i.i436.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i.i434.i, 0
  %lpad.val33.i.i.i437.i = insertvalue { i8*, i32 } %lpad.val32.i.i.i436.i, i32 %sel31.i.i.i435.i, 1
  br label %lpad4.body.i.i560.i

unreachable.i.i.i439.i:                           ; preds = %lpad11.i.i.i430.i, %ehcleanup.i.i.i425.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i:           ; preds = %sync.continue.i.i.i417.i
  call void @llvm.stackrestore(i8* %savedstack.i.i393.i)
  %savedstack61.i.i440.i = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i.i375.i, %class.object.1** %this.addr.i36.i.i377.i, align 8
  %this1.i40.i.i441.i = load %class.object.1*, %class.object.1** %this.addr.i36.i.i377.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i.split

_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i.split:     ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i
  %222 = call token @llvm.taskframe.create()
  %a.i44.i.i443.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i441.i, i32 0, i32 0
  %a2.i45.i.i444.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i372.i, i32 0, i32 0
  detach within %syncreg.i37.i.i384.i, label %det.achd.i49.i.i448.i, label %det.cont.i52.i.i451.i unwind label %lpad4.i58.i.i465.i

det.achd.i49.i.i448.i:                            ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i.split
  %exn.slot.i46.i.i445.i = alloca i8*
  %ehselector.slot.i47.i.i446.i = alloca i32
  call void @llvm.taskframe.use(token %222)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i.i381.i, %class.object.2* dereferenceable(1) %a2.i45.i.i444.i)
  %call.i48.i.i447.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i.i443.i, %class.object.2* %agg.tmp.i41.i.i381.i)
          to label %invoke.cont.i50.i.i449.i unwind label %lpad.i56.i.i460.i

invoke.cont.i50.i.i449.i:                         ; preds = %det.achd.i49.i.i448.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i381.i) #7
  reattach within %syncreg.i37.i.i384.i, label %det.cont.i52.i.i451.i

det.cont.i52.i.i451.i:                            ; preds = %invoke.cont.i50.i.i449.i, %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i.split
  %b.i51.i.i450.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i372.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i.i380.i, %class.object.2* dereferenceable(1) %b.i51.i.i450.i)
          to label %.noexc63.i.i454.i unwind label %lpad8.i.i561.i

.noexc63.i.i454.i:                                ; preds = %det.cont.i52.i.i451.i
  %b15.i.i.i452.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i441.i, i32 0, i32 1
  %call18.i.i.i453.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i.i452.i, %class.object.2* %agg.tmp14.i.i.i380.i)
          to label %invoke.cont17.i.i.i455.i unwind label %lpad16.i.i.i467.i

invoke.cont17.i.i.i455.i:                         ; preds = %.noexc63.i.i454.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i380.i) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i.i460.i:                                ; preds = %det.achd.i49.i.i448.i
  %223 = landingpad { i8*, i32 }
          cleanup
  %224 = extractvalue { i8*, i32 } %223, 0
  store i8* %224, i8** %exn.slot.i46.i.i445.i, align 8
  %225 = extractvalue { i8*, i32 } %223, 1
  store i32 %225, i32* %ehselector.slot.i47.i.i446.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i381.i) #7
  %exn.i53.i.i456.i = load i8*, i8** %exn.slot.i46.i.i445.i, align 8
  %sel.i54.i.i457.i = load i32, i32* %ehselector.slot.i47.i.i446.i, align 4
  %lpad.val.i55.i.i458.i = insertvalue { i8*, i32 } undef, i8* %exn.i53.i.i456.i, 0
  %lpad.val3.i.i.i459.i = insertvalue { i8*, i32 } %lpad.val.i55.i.i458.i, i32 %sel.i54.i.i457.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i.i384.i, { i8*, i32 } %lpad.val3.i.i.i459.i)
          to label %unreachable.i60.i.i473.i unwind label %lpad4.i58.i.i465.i

lpad4.i58.i.i465.i:                               ; preds = %lpad.i56.i.i460.i, %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i.split
  %226 = landingpad { i8*, i32 }
          cleanup
  %227 = extractvalue { i8*, i32 } %226, 0
  store i8* %227, i8** %exn.slot5.i42.i.i382.i, align 8
  %228 = extractvalue { i8*, i32 } %226, 1
  store i32 %228, i32* %ehselector.slot6.i43.i.i383.i, align 4
  %exn7.i.i.i461.i = load i8*, i8** %exn.slot5.i42.i.i382.i, align 8
  %sel8.i.i.i462.i = load i32, i32* %ehselector.slot6.i43.i.i383.i, align 4
  %lpad.val9.i.i.i463.i = insertvalue { i8*, i32 } undef, i8* %exn7.i.i.i461.i, 0
  %lpad.val10.i57.i.i464.i = insertvalue { i8*, i32 } %lpad.val9.i.i.i463.i, i32 %sel8.i.i.i462.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %222, { i8*, i32 } %lpad.val10.i57.i.i464.i)
          to label %unreachable.i60.i.i473.i unwind label %lpad11.i59.i.i466.i

lpad11.i59.i.i466.i:                              ; preds = %lpad4.i58.i.i465.i
  %229 = landingpad { i8*, i32 }
          cleanup
  %230 = extractvalue { i8*, i32 } %229, 0
  store i8* %230, i8** %exn.slot12.i38.i.i378.i, align 8
  %231 = extractvalue { i8*, i32 } %229, 1
  store i32 %231, i32* %ehselector.slot13.i39.i.i379.i, align 4
  br label %eh.resume.i.i.i472.i

lpad16.i.i.i467.i:                                ; preds = %.noexc63.i.i454.i
  %232 = landingpad { i8*, i32 }
          cleanup
  %233 = extractvalue { i8*, i32 } %232, 0
  store i8* %233, i8** %exn.slot12.i38.i.i378.i, align 8
  %234 = extractvalue { i8*, i32 } %232, 1
  store i32 %234, i32* %ehselector.slot13.i39.i.i379.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i380.i) #7
  br label %eh.resume.i.i.i472.i

eh.resume.i.i.i472.i:                             ; preds = %lpad16.i.i.i467.i, %lpad11.i59.i.i466.i
  %exn19.i.i.i468.i = load i8*, i8** %exn.slot12.i38.i.i378.i, align 8
  %sel20.i.i.i469.i = load i32, i32* %ehselector.slot13.i39.i.i379.i, align 4
  %lpad.val21.i.i.i470.i = insertvalue { i8*, i32 } undef, i8* %exn19.i.i.i468.i, 0
  %lpad.val22.i.i.i471.i = insertvalue { i8*, i32 } %lpad.val21.i.i.i470.i, i32 %sel20.i.i.i469.i, 1
  br label %lpad8.body.i.i563.i

unreachable.i60.i.i473.i:                         ; preds = %lpad4.i58.i.i465.i, %lpad.i56.i.i460.i
  unreachable

det.cont.i.i478.i:                                ; preds = %invoke.cont.i.i371.i.split
  %235 = load %class.object.0*, %class.object.0** %other.addr.i.i356.i, align 8
  %b21.i.i474.i = getelementptr inbounds %class.object.0, %class.object.0* %235, i32 0, i32 1
  %savedstack116.i.i475.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i.i359.i, %class.object.1** %this.addr.i65.i.i350.i, align 8
  store %class.object.1* %b21.i.i474.i, %class.object.1** %other.addr.i66.i.i351.i, align 8
  %this1.i71.i.i476.i = load %class.object.1*, %class.object.1** %this.addr.i65.i.i350.i, align 8
  %a.i72.i.i477.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i476.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i.i477.i)
          to label %.noexc117.i.i480.i unwind label %lpad19.i.i574.i

.noexc117.i.i480.i:                               ; preds = %det.cont.i.i478.i
  %b.i73.i.i479.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i476.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i.i479.i)
          to label %invoke.cont.i79.i.i481.i unwind label %lpad.i93.i.i500.i

invoke.cont.i79.i.i481.i:                         ; preds = %.noexc117.i.i480.i
  br label %invoke.cont.i79.i.i481.i.split

invoke.cont.i79.i.i481.i.split:                   ; preds = %invoke.cont.i79.i.i481.i
  %236 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i.i482.i = alloca %class.object.2, align 1
  %exn.slot12.i75.i.i483.i = alloca i8*
  %ehselector.slot13.i76.i.i484.i = alloca i32
  %a2.i77.i.i485.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i476.i, i32 0, i32 0
  %237 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i351.i, align 8
  %a3.i78.i.i486.i = getelementptr inbounds %class.object.1, %class.object.1* %237, i32 0, i32 0
  detach within %syncreg.i69.i.i361.i, label %det.achd.i82.i.i489.i, label %det.cont.i87.i.i494.i unwind label %lpad11.i101.i.i512.i

det.achd.i82.i.i489.i:                            ; preds = %invoke.cont.i79.i.i481.i.split
  %exn.slot5.i80.i.i487.i = alloca i8*
  %ehselector.slot6.i81.i.i488.i = alloca i32
  call void @llvm.taskframe.use(token %236)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i.i482.i, %class.object.2* dereferenceable(1) %a3.i78.i.i486.i)
          to label %invoke.cont7.i84.i.i491.i unwind label %lpad4.i94.i.i501.i

invoke.cont7.i84.i.i491.i:                        ; preds = %det.achd.i82.i.i489.i
  %call.i83.i.i490.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i.i485.i, %class.object.2* %agg.tmp.i74.i.i482.i)
          to label %invoke.cont9.i85.i.i492.i unwind label %lpad8.i95.i.i502.i

invoke.cont9.i85.i.i492.i:                        ; preds = %invoke.cont7.i84.i.i491.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i482.i) #7
  reattach within %syncreg.i69.i.i361.i, label %det.cont.i87.i.i494.i

det.cont.i87.i.i494.i:                            ; preds = %invoke.cont9.i85.i.i492.i, %invoke.cont.i79.i.i481.i.split
  %238 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i351.i, align 8
  %b21.i86.i.i493.i = getelementptr inbounds %class.object.1, %class.object.1* %238, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i.i354.i, %class.object.2* dereferenceable(1) %b21.i86.i.i493.i)
          to label %invoke.cont22.i90.i.i497.i unwind label %lpad19.i106.i.i513.i

invoke.cont22.i90.i.i497.i:                       ; preds = %det.cont.i87.i.i494.i
  %b23.i88.i.i495.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i476.i, i32 0, i32 1
  %call26.i89.i.i496.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i.i495.i, %class.object.2* %agg.tmp20.i70.i.i354.i)
          to label %invoke.cont25.i91.i.i498.i unwind label %lpad24.i107.i.i514.i

invoke.cont25.i91.i.i498.i:                       ; preds = %invoke.cont22.i90.i.i497.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i354.i) #7
  sync within %syncreg.i69.i.i361.i, label %sync.continue.i92.i.i499.i

sync.continue.i92.i.i499.i:                       ; preds = %invoke.cont25.i91.i.i498.i
  invoke void @llvm.sync.unwind(token %syncreg.i69.i.i361.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i unwind label %lpad19.i.i574.i

lpad.i93.i.i500.i:                                ; preds = %.noexc117.i.i480.i
  %239 = landingpad { i8*, i32 }
          cleanup
  %240 = extractvalue { i8*, i32 } %239, 0
  store i8* %240, i8** %exn.slot.i67.i.i352.i, align 8
  %241 = extractvalue { i8*, i32 } %239, 1
  store i32 %241, i32* %ehselector.slot.i68.i.i353.i, align 4
  br label %ehcleanup29.i109.i.i520.i

lpad4.i94.i.i501.i:                               ; preds = %det.achd.i82.i.i489.i
  %242 = landingpad { i8*, i32 }
          cleanup
  %243 = extractvalue { i8*, i32 } %242, 0
  store i8* %243, i8** %exn.slot5.i80.i.i487.i, align 8
  %244 = extractvalue { i8*, i32 } %242, 1
  store i32 %244, i32* %ehselector.slot6.i81.i.i488.i, align 4
  br label %ehcleanup.i100.i.i507.i

lpad8.i95.i.i502.i:                               ; preds = %invoke.cont7.i84.i.i491.i
  %245 = landingpad { i8*, i32 }
          cleanup
  %246 = extractvalue { i8*, i32 } %245, 0
  store i8* %246, i8** %exn.slot5.i80.i.i487.i, align 8
  %247 = extractvalue { i8*, i32 } %245, 1
  store i32 %247, i32* %ehselector.slot6.i81.i.i488.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i482.i) #7
  br label %ehcleanup.i100.i.i507.i

ehcleanup.i100.i.i507.i:                          ; preds = %lpad8.i95.i.i502.i, %lpad4.i94.i.i501.i
  %exn.i96.i.i503.i = load i8*, i8** %exn.slot5.i80.i.i487.i, align 8
  %sel.i97.i.i504.i = load i32, i32* %ehselector.slot6.i81.i.i488.i, align 4
  %lpad.val.i98.i.i505.i = insertvalue { i8*, i32 } undef, i8* %exn.i96.i.i503.i, 0
  %lpad.val10.i99.i.i506.i = insertvalue { i8*, i32 } %lpad.val.i98.i.i505.i, i32 %sel.i97.i.i504.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i.i361.i, { i8*, i32 } %lpad.val10.i99.i.i506.i)
          to label %unreachable.i115.i.i521.i unwind label %lpad11.i101.i.i512.i

lpad11.i101.i.i512.i:                             ; preds = %ehcleanup.i100.i.i507.i, %invoke.cont.i79.i.i481.i.split
  %248 = landingpad { i8*, i32 }
          cleanup
  %249 = extractvalue { i8*, i32 } %248, 0
  store i8* %249, i8** %exn.slot12.i75.i.i483.i, align 8
  %250 = extractvalue { i8*, i32 } %248, 1
  store i32 %250, i32* %ehselector.slot13.i76.i.i484.i, align 4
  %exn15.i102.i.i508.i = load i8*, i8** %exn.slot12.i75.i.i483.i, align 8
  %sel16.i103.i.i509.i = load i32, i32* %ehselector.slot13.i76.i.i484.i, align 4
  %lpad.val17.i104.i.i510.i = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i.i508.i, 0
  %lpad.val18.i105.i.i511.i = insertvalue { i8*, i32 } %lpad.val17.i104.i.i510.i, i32 %sel16.i103.i.i509.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %236, { i8*, i32 } %lpad.val18.i105.i.i511.i)
          to label %unreachable.i115.i.i521.i unwind label %lpad19.i106.i.i513.i

lpad19.i106.i.i513.i:                             ; preds = %lpad11.i101.i.i512.i, %det.cont.i87.i.i494.i
  %251 = landingpad { i8*, i32 }
          cleanup
  %252 = extractvalue { i8*, i32 } %251, 0
  store i8* %252, i8** %exn.slot.i67.i.i352.i, align 8
  %253 = extractvalue { i8*, i32 } %251, 1
  store i32 %253, i32* %ehselector.slot.i68.i.i353.i, align 4
  br label %ehcleanup28.i108.i.i515.i

lpad24.i107.i.i514.i:                             ; preds = %invoke.cont22.i90.i.i497.i
  %254 = landingpad { i8*, i32 }
          cleanup
  %255 = extractvalue { i8*, i32 } %254, 0
  store i8* %255, i8** %exn.slot.i67.i.i352.i, align 8
  %256 = extractvalue { i8*, i32 } %254, 1
  store i32 %256, i32* %ehselector.slot.i68.i.i353.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i354.i) #7
  br label %ehcleanup28.i108.i.i515.i

ehcleanup28.i108.i.i515.i:                        ; preds = %lpad24.i107.i.i514.i, %lpad19.i106.i.i513.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i.i479.i) #7
  br label %ehcleanup29.i109.i.i520.i

ehcleanup29.i109.i.i520.i:                        ; preds = %ehcleanup28.i108.i.i515.i, %lpad.i93.i.i500.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i.i477.i) #7
  %exn30.i110.i.i516.i = load i8*, i8** %exn.slot.i67.i.i352.i, align 8
  %sel31.i111.i.i517.i = load i32, i32* %ehselector.slot.i68.i.i353.i, align 4
  %lpad.val32.i112.i.i518.i = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i.i516.i, 0
  %lpad.val33.i113.i.i519.i = insertvalue { i8*, i32 } %lpad.val32.i112.i.i518.i, i32 %sel31.i111.i.i517.i, 1
  br label %lpad19.body.i.i576.i

unreachable.i115.i.i521.i:                        ; preds = %lpad11.i101.i.i512.i, %ehcleanup.i100.i.i507.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i:        ; preds = %sync.continue.i92.i.i499.i
  call void @llvm.stackrestore(i8* %savedstack116.i.i475.i)
  %b23.i.i522.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i366.i, i32 0, i32 1
  %savedstack161.i.i523.i = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i.i522.i, %class.object.1** %this.addr.i122.i.i343.i, align 8
  %this1.i127.i.i524.i = load %class.object.1*, %class.object.1** %this.addr.i122.i.i343.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i.split

_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i.split:  ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i
  %257 = call token @llvm.taskframe.create()
  %a.i131.i.i526.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i524.i, i32 0, i32 0
  %a2.i132.i.i527.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i359.i, i32 0, i32 0
  detach within %syncreg.i123.i.i360.i, label %det.achd.i136.i.i531.i, label %det.cont.i141.i.i534.i unwind label %lpad4.i152.i.i548.i

det.achd.i136.i.i531.i:                           ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i.split
  %exn.slot.i133.i.i528.i = alloca i8*
  %ehselector.slot.i134.i.i529.i = alloca i32
  call void @llvm.taskframe.use(token %257)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i.i347.i, %class.object.2* dereferenceable(1) %a2.i132.i.i527.i)
  %call.i135.i.i530.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i.i526.i, %class.object.2* %agg.tmp.i128.i.i347.i)
          to label %invoke.cont.i137.i.i532.i unwind label %lpad.i147.i.i543.i

invoke.cont.i137.i.i532.i:                        ; preds = %det.achd.i136.i.i531.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i347.i) #7
  reattach within %syncreg.i123.i.i360.i, label %det.cont.i141.i.i534.i

det.cont.i141.i.i534.i:                           ; preds = %invoke.cont.i137.i.i532.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i.split
  %b.i138.i.i533.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i359.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i.i346.i, %class.object.2* dereferenceable(1) %b.i138.i.i533.i)
          to label %.noexc164.i.i537.i unwind label %lpad24.i.i577.i

.noexc164.i.i537.i:                               ; preds = %det.cont.i141.i.i534.i
  %b15.i139.i.i535.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i524.i, i32 0, i32 1
  %call18.i140.i.i536.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i.i535.i, %class.object.2* %agg.tmp14.i126.i.i346.i)
          to label %invoke.cont17.i142.i.i538.i unwind label %lpad16.i154.i.i550.i

invoke.cont17.i142.i.i538.i:                      ; preds = %.noexc164.i.i537.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i346.i) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i.i543.i:                               ; preds = %det.achd.i136.i.i531.i
  %258 = landingpad { i8*, i32 }
          cleanup
  %259 = extractvalue { i8*, i32 } %258, 0
  store i8* %259, i8** %exn.slot.i133.i.i528.i, align 8
  %260 = extractvalue { i8*, i32 } %258, 1
  store i32 %260, i32* %ehselector.slot.i134.i.i529.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i347.i) #7
  %exn.i143.i.i539.i = load i8*, i8** %exn.slot.i133.i.i528.i, align 8
  %sel.i144.i.i540.i = load i32, i32* %ehselector.slot.i134.i.i529.i, align 4
  %lpad.val.i145.i.i541.i = insertvalue { i8*, i32 } undef, i8* %exn.i143.i.i539.i, 0
  %lpad.val3.i146.i.i542.i = insertvalue { i8*, i32 } %lpad.val.i145.i.i541.i, i32 %sel.i144.i.i540.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i.i360.i, { i8*, i32 } %lpad.val3.i146.i.i542.i)
          to label %unreachable.i160.i.i556.i unwind label %lpad4.i152.i.i548.i

lpad4.i152.i.i548.i:                              ; preds = %lpad.i147.i.i543.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i.split
  %261 = landingpad { i8*, i32 }
          cleanup
  %262 = extractvalue { i8*, i32 } %261, 0
  store i8* %262, i8** %exn.slot5.i129.i.i348.i, align 8
  %263 = extractvalue { i8*, i32 } %261, 1
  store i32 %263, i32* %ehselector.slot6.i130.i.i349.i, align 4
  %exn7.i148.i.i544.i = load i8*, i8** %exn.slot5.i129.i.i348.i, align 8
  %sel8.i149.i.i545.i = load i32, i32* %ehselector.slot6.i130.i.i349.i, align 4
  %lpad.val9.i150.i.i546.i = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i.i544.i, 0
  %lpad.val10.i151.i.i547.i = insertvalue { i8*, i32 } %lpad.val9.i150.i.i546.i, i32 %sel8.i149.i.i545.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %257, { i8*, i32 } %lpad.val10.i151.i.i547.i)
          to label %unreachable.i160.i.i556.i unwind label %lpad11.i153.i.i549.i

lpad11.i153.i.i549.i:                             ; preds = %lpad4.i152.i.i548.i
  %264 = landingpad { i8*, i32 }
          cleanup
  %265 = extractvalue { i8*, i32 } %264, 0
  store i8* %265, i8** %exn.slot12.i124.i.i344.i, align 8
  %266 = extractvalue { i8*, i32 } %264, 1
  store i32 %266, i32* %ehselector.slot13.i125.i.i345.i, align 4
  br label %eh.resume.i159.i.i555.i

lpad16.i154.i.i550.i:                             ; preds = %.noexc164.i.i537.i
  %267 = landingpad { i8*, i32 }
          cleanup
  %268 = extractvalue { i8*, i32 } %267, 0
  store i8* %268, i8** %exn.slot12.i124.i.i344.i, align 8
  %269 = extractvalue { i8*, i32 } %267, 1
  store i32 %269, i32* %ehselector.slot13.i125.i.i345.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i346.i) #7
  br label %eh.resume.i159.i.i555.i

eh.resume.i159.i.i555.i:                          ; preds = %lpad16.i154.i.i550.i, %lpad11.i153.i.i549.i
  %exn19.i155.i.i551.i = load i8*, i8** %exn.slot12.i124.i.i344.i, align 8
  %sel20.i156.i.i552.i = load i32, i32* %ehselector.slot13.i125.i.i345.i, align 4
  %lpad.val21.i157.i.i553.i = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i.i551.i, 0
  %lpad.val22.i158.i.i554.i = insertvalue { i8*, i32 } %lpad.val21.i157.i.i553.i, i32 %sel20.i156.i.i552.i, 1
  br label %lpad24.body.i.i579.i

unreachable.i160.i.i556.i:                        ; preds = %lpad4.i152.i.i548.i, %lpad.i147.i.i543.i
  unreachable

lpad.i.i557.i:                                    ; preds = %.noexc.i370.i
  %270 = landingpad { i8*, i32 }
          cleanup
  %271 = extractvalue { i8*, i32 } %270, 0
  store i8* %271, i8** %exn.slot.i.i357.i, align 8
  %272 = extractvalue { i8*, i32 } %270, 1
  store i32 %272, i32* %ehselector.slot.i.i358.i, align 4
  br label %ehcleanup29.i.i585.i

lpad4.i.i558.i:                                   ; preds = %sync.continue.i.i.i417.i, %det.achd.i.i396.i
  %273 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i.i560.i

lpad4.body.i.i560.i:                              ; preds = %lpad4.i.i558.i, %ehcleanup29.i.i.i438.i
  %eh.lpad-body.i.i559.i = phi { i8*, i32 } [ %273, %lpad4.i.i558.i ], [ %lpad.val33.i.i.i437.i, %ehcleanup29.i.i.i438.i ]
  %274 = extractvalue { i8*, i32 } %eh.lpad-body.i.i559.i, 0
  store i8* %274, i8** %exn.slot5.i.i391.i, align 8
  %275 = extractvalue { i8*, i32 } %eh.lpad-body.i.i559.i, 1
  store i32 %275, i32* %ehselector.slot6.i.i392.i, align 4
  br label %ehcleanup.i.i568.i

lpad8.i.i561.i:                                   ; preds = %det.cont.i52.i.i451.i
  %276 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i.i563.i

lpad8.body.i.i563.i:                              ; preds = %lpad8.i.i561.i, %eh.resume.i.i.i472.i
  %eh.lpad-body64.i.i562.i = phi { i8*, i32 } [ %276, %lpad8.i.i561.i ], [ %lpad.val22.i.i.i471.i, %eh.resume.i.i.i472.i ]
  %277 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i562.i, 0
  store i8* %277, i8** %exn.slot5.i.i391.i, align 8
  %278 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i562.i, 1
  store i32 %278, i32* %ehselector.slot6.i.i392.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i.i372.i) #7
  br label %ehcleanup.i.i568.i

ehcleanup.i.i568.i:                               ; preds = %lpad8.body.i.i563.i, %lpad4.body.i.i560.i
  %exn.i.i564.i = load i8*, i8** %exn.slot5.i.i391.i, align 8
  %sel.i.i565.i = load i32, i32* %ehselector.slot6.i.i392.i, align 4
  %lpad.val.i.i566.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i564.i, 0
  %lpad.val10.i.i567.i = insertvalue { i8*, i32 } %lpad.val.i.i566.i, i32 %sel.i.i565.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i362.i, { i8*, i32 } %lpad.val10.i.i567.i)
          to label %unreachable.i.i586.i unwind label %lpad11.i.i573.i

lpad11.i.i573.i:                                  ; preds = %ehcleanup.i.i568.i, %invoke.cont.i.i371.i.split
  %279 = landingpad { i8*, i32 }
          cleanup
  %280 = extractvalue { i8*, i32 } %279, 0
  store i8* %280, i8** %exn.slot12.i.i373.i, align 8
  %281 = extractvalue { i8*, i32 } %279, 1
  store i32 %281, i32* %ehselector.slot13.i.i374.i, align 4
  %exn15.i.i569.i = load i8*, i8** %exn.slot12.i.i373.i, align 8
  %sel16.i.i570.i = load i32, i32* %ehselector.slot13.i.i374.i, align 4
  %lpad.val17.i.i571.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i569.i, 0
  %lpad.val18.i.i572.i = insertvalue { i8*, i32 } %lpad.val17.i.i571.i, i32 %sel16.i.i570.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %199, { i8*, i32 } %lpad.val18.i.i572.i)
          to label %unreachable.i.i586.i unwind label %lpad19.i.i574.i

lpad19.i.i574.i:                                  ; preds = %lpad11.i.i573.i, %sync.continue.i92.i.i499.i, %det.cont.i.i478.i
  %282 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i.i576.i

lpad19.body.i.i576.i:                             ; preds = %lpad19.i.i574.i, %ehcleanup29.i109.i.i520.i
  %eh.lpad-body118.i.i575.i = phi { i8*, i32 } [ %282, %lpad19.i.i574.i ], [ %lpad.val33.i113.i.i519.i, %ehcleanup29.i109.i.i520.i ]
  %283 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i575.i, 0
  store i8* %283, i8** %exn.slot.i.i357.i, align 8
  %284 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i575.i, 1
  store i32 %284, i32* %ehselector.slot.i.i358.i, align 4
  br label %ehcleanup28.i.i580.i

lpad24.i.i577.i:                                  ; preds = %det.cont.i141.i.i534.i
  %285 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i.i579.i

lpad24.body.i.i579.i:                             ; preds = %lpad24.i.i577.i, %eh.resume.i159.i.i555.i
  %eh.lpad-body165.i.i578.i = phi { i8*, i32 } [ %285, %lpad24.i.i577.i ], [ %lpad.val22.i158.i.i554.i, %eh.resume.i159.i.i555.i ]
  %286 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i578.i, 0
  store i8* %286, i8** %exn.slot.i.i357.i, align 8
  %287 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i578.i, 1
  store i32 %287, i32* %ehselector.slot.i.i358.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i.i359.i) #7
  br label %ehcleanup28.i.i580.i

ehcleanup28.i.i580.i:                             ; preds = %lpad24.body.i.i579.i, %lpad19.body.i.i576.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i.i369.i) #7
  br label %ehcleanup29.i.i585.i

ehcleanup29.i.i585.i:                             ; preds = %ehcleanup28.i.i580.i, %lpad.i.i557.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i.i367.i) #7
  %exn30.i.i581.i = load i8*, i8** %exn.slot.i.i357.i, align 8
  %sel31.i.i582.i = load i32, i32* %ehselector.slot.i.i358.i, align 4
  %lpad.val32.i.i583.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i581.i, 0
  %lpad.val33.i.i584.i = insertvalue { i8*, i32 } %lpad.val32.i.i583.i, i32 %sel31.i.i582.i, 1
  br label %lpad4.body.i813.i

unreachable.i.i586.i:                             ; preds = %lpad11.i.i573.i, %ehcleanup.i.i568.i
  unreachable

det.cont.i591.i:                                  ; preds = %invoke.cont.i337.i.split
  %288 = load %class.object*, %class.object** %other.addr.i329.i, align 8
  %b21.i587.i = getelementptr inbounds %class.object, %class.object* %288, i32 0, i32 1
  %savedstack373.i588.i = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp20.i333.i, %class.object.0** %this.addr.i147.i317.i, align 8
  store %class.object.0* %b21.i587.i, %class.object.0** %other.addr.i148.i318.i, align 8
  %this1.i153.i589.i = load %class.object.0*, %class.object.0** %this.addr.i147.i317.i, align 8
  %a.i154.i590.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i589.i, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i154.i590.i)
          to label %.noexc374.i593.i unwind label %lpad19.i823.i

.noexc374.i593.i:                                 ; preds = %det.cont.i591.i
  %b.i155.i592.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i589.i, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i155.i592.i)
          to label %invoke.cont.i156.i594.i unwind label %lpad.i342.i780.i

invoke.cont.i156.i594.i:                          ; preds = %.noexc374.i593.i
  br label %invoke.cont.i156.i594.i.split

invoke.cont.i156.i594.i.split:                    ; preds = %invoke.cont.i156.i594.i
  %289 = call token @llvm.taskframe.create()
  %agg.tmp.i157.i595.i = alloca %class.object.1, align 1
  %exn.slot12.i158.i596.i = alloca i8*
  %ehselector.slot13.i159.i597.i = alloca i32
  %a2.i160.i598.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i589.i, i32 0, i32 0
  %290 = load %class.object.0*, %class.object.0** %other.addr.i148.i318.i, align 8
  %a3.i161.i599.i = getelementptr inbounds %class.object.0, %class.object.0* %290, i32 0, i32 0
  detach within %syncreg.i151.i324.i, label %det.achd.i181.i619.i, label %det.cont.i263.i701.i unwind label %lpad11.i354.i796.i

det.achd.i181.i619.i:                             ; preds = %invoke.cont.i156.i594.i.split
  %this.addr.i36.i162.i600.i = alloca %class.object.1*, align 8
  %exn.slot12.i38.i163.i601.i = alloca i8*
  %ehselector.slot13.i39.i164.i602.i = alloca i32
  %agg.tmp14.i.i165.i603.i = alloca %class.object.2, align 1
  %agg.tmp.i41.i166.i604.i = alloca %class.object.2, align 1
  %exn.slot5.i42.i167.i605.i = alloca i8*
  %ehselector.slot6.i43.i168.i606.i = alloca i32
  %syncreg.i37.i169.i607.i = call token @llvm.syncregion.start()
  %this.addr.i.i170.i608.i = alloca %class.object.1*, align 8
  %other.addr.i.i171.i609.i = alloca %class.object.1*, align 8
  %exn.slot.i.i172.i610.i = alloca i8*
  %ehselector.slot.i.i173.i611.i = alloca i32
  %agg.tmp20.i.i174.i612.i = alloca %class.object.2, align 1
  %syncreg.i.i175.i613.i = call token @llvm.syncregion.start()
  %exn.slot5.i176.i614.i = alloca i8*
  %ehselector.slot6.i177.i615.i = alloca i32
  call void @llvm.taskframe.use(token %289)
  %savedstack.i178.i616.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i157.i595.i, %class.object.1** %this.addr.i.i170.i608.i, align 8
  store %class.object.1* %a3.i161.i599.i, %class.object.1** %other.addr.i.i171.i609.i, align 8
  %this1.i.i179.i617.i = load %class.object.1*, %class.object.1** %this.addr.i.i170.i608.i, align 8
  %a.i.i180.i618.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i617.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i180.i618.i)
          to label %.noexc.i183.i621.i unwind label %lpad4.i343.i781.i

.noexc.i183.i621.i:                               ; preds = %det.achd.i181.i619.i
  %b.i.i182.i620.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i617.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i182.i620.i)
          to label %invoke.cont.i.i184.i622.i unwind label %lpad.i.i203.i641.i

invoke.cont.i.i184.i622.i:                        ; preds = %.noexc.i183.i621.i
  br label %invoke.cont.i.i184.i622.i.split

invoke.cont.i.i184.i622.i.split:                  ; preds = %invoke.cont.i.i184.i622.i
  %291 = call token @llvm.taskframe.create()
  %agg.tmp.i.i185.i623.i = alloca %class.object.2, align 1
  %exn.slot12.i.i186.i624.i = alloca i8*
  %ehselector.slot13.i.i187.i625.i = alloca i32
  %a2.i.i188.i626.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i617.i, i32 0, i32 0
  %292 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i609.i, align 8
  %a3.i.i189.i627.i = getelementptr inbounds %class.object.1, %class.object.1* %292, i32 0, i32 0
  detach within %syncreg.i.i175.i613.i, label %det.achd.i.i192.i630.i, label %det.cont.i.i197.i635.i unwind label %lpad11.i.i215.i653.i

det.achd.i.i192.i630.i:                           ; preds = %invoke.cont.i.i184.i622.i.split
  %exn.slot5.i.i190.i628.i = alloca i8*
  %ehselector.slot6.i.i191.i629.i = alloca i32
  call void @llvm.taskframe.use(token %291)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i185.i623.i, %class.object.2* dereferenceable(1) %a3.i.i189.i627.i)
          to label %invoke.cont7.i.i194.i632.i unwind label %lpad4.i.i204.i642.i

invoke.cont7.i.i194.i632.i:                       ; preds = %det.achd.i.i192.i630.i
  %call.i.i193.i631.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i188.i626.i, %class.object.2* %agg.tmp.i.i185.i623.i)
          to label %invoke.cont9.i.i195.i633.i unwind label %lpad8.i.i205.i643.i

invoke.cont9.i.i195.i633.i:                       ; preds = %invoke.cont7.i.i194.i632.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i623.i) #7
  reattach within %syncreg.i.i175.i613.i, label %det.cont.i.i197.i635.i

det.cont.i.i197.i635.i:                           ; preds = %invoke.cont9.i.i195.i633.i, %invoke.cont.i.i184.i622.i.split
  %293 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i609.i, align 8
  %b21.i.i196.i634.i = getelementptr inbounds %class.object.1, %class.object.1* %293, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i174.i612.i, %class.object.2* dereferenceable(1) %b21.i.i196.i634.i)
          to label %invoke.cont22.i.i200.i638.i unwind label %lpad19.i.i216.i654.i

invoke.cont22.i.i200.i638.i:                      ; preds = %det.cont.i.i197.i635.i
  %b23.i.i198.i636.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i617.i, i32 0, i32 1
  %call26.i.i199.i637.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i198.i636.i, %class.object.2* %agg.tmp20.i.i174.i612.i)
          to label %invoke.cont25.i.i201.i639.i unwind label %lpad24.i.i217.i655.i

invoke.cont25.i.i201.i639.i:                      ; preds = %invoke.cont22.i.i200.i638.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i612.i) #7
  sync within %syncreg.i.i175.i613.i, label %sync.continue.i.i202.i640.i

sync.continue.i.i202.i640.i:                      ; preds = %invoke.cont25.i.i201.i639.i
  invoke void @llvm.sync.unwind(token %syncreg.i.i175.i613.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i unwind label %lpad4.i343.i781.i

lpad.i.i203.i641.i:                               ; preds = %.noexc.i183.i621.i
  %294 = landingpad { i8*, i32 }
          cleanup
  %295 = extractvalue { i8*, i32 } %294, 0
  store i8* %295, i8** %exn.slot.i.i172.i610.i, align 8
  %296 = extractvalue { i8*, i32 } %294, 1
  store i32 %296, i32* %ehselector.slot.i.i173.i611.i, align 4
  br label %ehcleanup29.i.i223.i661.i

lpad4.i.i204.i642.i:                              ; preds = %det.achd.i.i192.i630.i
  %297 = landingpad { i8*, i32 }
          cleanup
  %298 = extractvalue { i8*, i32 } %297, 0
  store i8* %298, i8** %exn.slot5.i.i190.i628.i, align 8
  %299 = extractvalue { i8*, i32 } %297, 1
  store i32 %299, i32* %ehselector.slot6.i.i191.i629.i, align 4
  br label %ehcleanup.i.i210.i648.i

lpad8.i.i205.i643.i:                              ; preds = %invoke.cont7.i.i194.i632.i
  %300 = landingpad { i8*, i32 }
          cleanup
  %301 = extractvalue { i8*, i32 } %300, 0
  store i8* %301, i8** %exn.slot5.i.i190.i628.i, align 8
  %302 = extractvalue { i8*, i32 } %300, 1
  store i32 %302, i32* %ehselector.slot6.i.i191.i629.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i623.i) #7
  br label %ehcleanup.i.i210.i648.i

ehcleanup.i.i210.i648.i:                          ; preds = %lpad8.i.i205.i643.i, %lpad4.i.i204.i642.i
  %exn.i.i206.i644.i = load i8*, i8** %exn.slot5.i.i190.i628.i, align 8
  %sel.i.i207.i645.i = load i32, i32* %ehselector.slot6.i.i191.i629.i, align 4
  %lpad.val.i.i208.i646.i = insertvalue { i8*, i32 } undef, i8* %exn.i.i206.i644.i, 0
  %lpad.val10.i.i209.i647.i = insertvalue { i8*, i32 } %lpad.val.i.i208.i646.i, i32 %sel.i.i207.i645.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i175.i613.i, { i8*, i32 } %lpad.val10.i.i209.i647.i)
          to label %unreachable.i.i224.i662.i unwind label %lpad11.i.i215.i653.i

lpad11.i.i215.i653.i:                             ; preds = %ehcleanup.i.i210.i648.i, %invoke.cont.i.i184.i622.i.split
  %303 = landingpad { i8*, i32 }
          cleanup
  %304 = extractvalue { i8*, i32 } %303, 0
  store i8* %304, i8** %exn.slot12.i.i186.i624.i, align 8
  %305 = extractvalue { i8*, i32 } %303, 1
  store i32 %305, i32* %ehselector.slot13.i.i187.i625.i, align 4
  %exn15.i.i211.i649.i = load i8*, i8** %exn.slot12.i.i186.i624.i, align 8
  %sel16.i.i212.i650.i = load i32, i32* %ehselector.slot13.i.i187.i625.i, align 4
  %lpad.val17.i.i213.i651.i = insertvalue { i8*, i32 } undef, i8* %exn15.i.i211.i649.i, 0
  %lpad.val18.i.i214.i652.i = insertvalue { i8*, i32 } %lpad.val17.i.i213.i651.i, i32 %sel16.i.i212.i650.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %291, { i8*, i32 } %lpad.val18.i.i214.i652.i)
          to label %unreachable.i.i224.i662.i unwind label %lpad19.i.i216.i654.i

lpad19.i.i216.i654.i:                             ; preds = %lpad11.i.i215.i653.i, %det.cont.i.i197.i635.i
  %306 = landingpad { i8*, i32 }
          cleanup
  %307 = extractvalue { i8*, i32 } %306, 0
  store i8* %307, i8** %exn.slot.i.i172.i610.i, align 8
  %308 = extractvalue { i8*, i32 } %306, 1
  store i32 %308, i32* %ehselector.slot.i.i173.i611.i, align 4
  br label %ehcleanup28.i.i218.i656.i

lpad24.i.i217.i655.i:                             ; preds = %invoke.cont22.i.i200.i638.i
  %309 = landingpad { i8*, i32 }
          cleanup
  %310 = extractvalue { i8*, i32 } %309, 0
  store i8* %310, i8** %exn.slot.i.i172.i610.i, align 8
  %311 = extractvalue { i8*, i32 } %309, 1
  store i32 %311, i32* %ehselector.slot.i.i173.i611.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i612.i) #7
  br label %ehcleanup28.i.i218.i656.i

ehcleanup28.i.i218.i656.i:                        ; preds = %lpad24.i.i217.i655.i, %lpad19.i.i216.i654.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i182.i620.i) #7
  br label %ehcleanup29.i.i223.i661.i

ehcleanup29.i.i223.i661.i:                        ; preds = %ehcleanup28.i.i218.i656.i, %lpad.i.i203.i641.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i180.i618.i) #7
  %exn30.i.i219.i657.i = load i8*, i8** %exn.slot.i.i172.i610.i, align 8
  %sel31.i.i220.i658.i = load i32, i32* %ehselector.slot.i.i173.i611.i, align 4
  %lpad.val32.i.i221.i659.i = insertvalue { i8*, i32 } undef, i8* %exn30.i.i219.i657.i, 0
  %lpad.val33.i.i222.i660.i = insertvalue { i8*, i32 } %lpad.val32.i.i221.i659.i, i32 %sel31.i.i220.i658.i, 1
  br label %lpad4.body.i345.i783.i

unreachable.i.i224.i662.i:                        ; preds = %lpad11.i.i215.i653.i, %ehcleanup.i.i210.i648.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i:        ; preds = %sync.continue.i.i202.i640.i
  call void @llvm.stackrestore(i8* %savedstack.i178.i616.i)
  %savedstack61.i226.i663.i = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i160.i598.i, %class.object.1** %this.addr.i36.i162.i600.i, align 8
  %this1.i40.i227.i664.i = load %class.object.1*, %class.object.1** %this.addr.i36.i162.i600.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i.split

_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i.split:  ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i
  %312 = call token @llvm.taskframe.create()
  %a.i44.i228.i666.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i664.i, i32 0, i32 0
  %a2.i45.i229.i667.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i595.i, i32 0, i32 0
  detach within %syncreg.i37.i169.i607.i, label %det.achd.i49.i233.i671.i, label %det.cont.i52.i236.i674.i unwind label %lpad4.i58.i250.i688.i

det.achd.i49.i233.i671.i:                         ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i.split
  %exn.slot.i46.i230.i668.i = alloca i8*
  %ehselector.slot.i47.i231.i669.i = alloca i32
  call void @llvm.taskframe.use(token %312)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i166.i604.i, %class.object.2* dereferenceable(1) %a2.i45.i229.i667.i)
  %call.i48.i232.i670.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i228.i666.i, %class.object.2* %agg.tmp.i41.i166.i604.i)
          to label %invoke.cont.i50.i234.i672.i unwind label %lpad.i56.i245.i683.i

invoke.cont.i50.i234.i672.i:                      ; preds = %det.achd.i49.i233.i671.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i604.i) #7
  reattach within %syncreg.i37.i169.i607.i, label %det.cont.i52.i236.i674.i

det.cont.i52.i236.i674.i:                         ; preds = %invoke.cont.i50.i234.i672.i, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i.split
  %b.i51.i235.i673.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i595.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i165.i603.i, %class.object.2* dereferenceable(1) %b.i51.i235.i673.i)
          to label %.noexc63.i239.i677.i unwind label %lpad8.i346.i784.i

.noexc63.i239.i677.i:                             ; preds = %det.cont.i52.i236.i674.i
  %b15.i.i237.i675.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i664.i, i32 0, i32 1
  %call18.i.i238.i676.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i237.i675.i, %class.object.2* %agg.tmp14.i.i165.i603.i)
          to label %invoke.cont17.i.i240.i678.i unwind label %lpad16.i.i252.i690.i

invoke.cont17.i.i240.i678.i:                      ; preds = %.noexc63.i239.i677.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i603.i) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i245.i683.i:                             ; preds = %det.achd.i49.i233.i671.i
  %313 = landingpad { i8*, i32 }
          cleanup
  %314 = extractvalue { i8*, i32 } %313, 0
  store i8* %314, i8** %exn.slot.i46.i230.i668.i, align 8
  %315 = extractvalue { i8*, i32 } %313, 1
  store i32 %315, i32* %ehselector.slot.i47.i231.i669.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i604.i) #7
  %exn.i53.i241.i679.i = load i8*, i8** %exn.slot.i46.i230.i668.i, align 8
  %sel.i54.i242.i680.i = load i32, i32* %ehselector.slot.i47.i231.i669.i, align 4
  %lpad.val.i55.i243.i681.i = insertvalue { i8*, i32 } undef, i8* %exn.i53.i241.i679.i, 0
  %lpad.val3.i.i244.i682.i = insertvalue { i8*, i32 } %lpad.val.i55.i243.i681.i, i32 %sel.i54.i242.i680.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i169.i607.i, { i8*, i32 } %lpad.val3.i.i244.i682.i)
          to label %unreachable.i60.i258.i696.i unwind label %lpad4.i58.i250.i688.i

lpad4.i58.i250.i688.i:                            ; preds = %lpad.i56.i245.i683.i, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i.split
  %316 = landingpad { i8*, i32 }
          cleanup
  %317 = extractvalue { i8*, i32 } %316, 0
  store i8* %317, i8** %exn.slot5.i42.i167.i605.i, align 8
  %318 = extractvalue { i8*, i32 } %316, 1
  store i32 %318, i32* %ehselector.slot6.i43.i168.i606.i, align 4
  %exn7.i.i246.i684.i = load i8*, i8** %exn.slot5.i42.i167.i605.i, align 8
  %sel8.i.i247.i685.i = load i32, i32* %ehselector.slot6.i43.i168.i606.i, align 4
  %lpad.val9.i.i248.i686.i = insertvalue { i8*, i32 } undef, i8* %exn7.i.i246.i684.i, 0
  %lpad.val10.i57.i249.i687.i = insertvalue { i8*, i32 } %lpad.val9.i.i248.i686.i, i32 %sel8.i.i247.i685.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %312, { i8*, i32 } %lpad.val10.i57.i249.i687.i)
          to label %unreachable.i60.i258.i696.i unwind label %lpad11.i59.i251.i689.i

lpad11.i59.i251.i689.i:                           ; preds = %lpad4.i58.i250.i688.i
  %319 = landingpad { i8*, i32 }
          cleanup
  %320 = extractvalue { i8*, i32 } %319, 0
  store i8* %320, i8** %exn.slot12.i38.i163.i601.i, align 8
  %321 = extractvalue { i8*, i32 } %319, 1
  store i32 %321, i32* %ehselector.slot13.i39.i164.i602.i, align 4
  br label %eh.resume.i.i257.i695.i

lpad16.i.i252.i690.i:                             ; preds = %.noexc63.i239.i677.i
  %322 = landingpad { i8*, i32 }
          cleanup
  %323 = extractvalue { i8*, i32 } %322, 0
  store i8* %323, i8** %exn.slot12.i38.i163.i601.i, align 8
  %324 = extractvalue { i8*, i32 } %322, 1
  store i32 %324, i32* %ehselector.slot13.i39.i164.i602.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i603.i) #7
  br label %eh.resume.i.i257.i695.i

eh.resume.i.i257.i695.i:                          ; preds = %lpad16.i.i252.i690.i, %lpad11.i59.i251.i689.i
  %exn19.i.i253.i691.i = load i8*, i8** %exn.slot12.i38.i163.i601.i, align 8
  %sel20.i.i254.i692.i = load i32, i32* %ehselector.slot13.i39.i164.i602.i, align 4
  %lpad.val21.i.i255.i693.i = insertvalue { i8*, i32 } undef, i8* %exn19.i.i253.i691.i, 0
  %lpad.val22.i.i256.i694.i = insertvalue { i8*, i32 } %lpad.val21.i.i255.i693.i, i32 %sel20.i.i254.i692.i, 1
  br label %lpad8.body.i348.i786.i

unreachable.i60.i258.i696.i:                      ; preds = %lpad4.i58.i250.i688.i, %lpad.i56.i245.i683.i
  unreachable

det.cont.i263.i701.i:                             ; preds = %invoke.cont.i156.i594.i.split
  %325 = load %class.object.0*, %class.object.0** %other.addr.i148.i318.i, align 8
  %b21.i259.i697.i = getelementptr inbounds %class.object.0, %class.object.0* %325, i32 0, i32 1
  %savedstack116.i260.i698.i = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i152.i321.i, %class.object.1** %this.addr.i65.i141.i312.i, align 8
  store %class.object.1* %b21.i259.i697.i, %class.object.1** %other.addr.i66.i142.i313.i, align 8
  %this1.i71.i261.i699.i = load %class.object.1*, %class.object.1** %this.addr.i65.i141.i312.i, align 8
  %a.i72.i262.i700.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i699.i, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i262.i700.i)
          to label %.noexc117.i265.i703.i unwind label %lpad19.i359.i797.i

.noexc117.i265.i703.i:                            ; preds = %det.cont.i263.i701.i
  %b.i73.i264.i702.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i699.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i264.i702.i)
          to label %invoke.cont.i79.i266.i704.i unwind label %lpad.i93.i285.i723.i

invoke.cont.i79.i266.i704.i:                      ; preds = %.noexc117.i265.i703.i
  br label %invoke.cont.i79.i266.i704.i.split

invoke.cont.i79.i266.i704.i.split:                ; preds = %invoke.cont.i79.i266.i704.i
  %326 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i267.i705.i = alloca %class.object.2, align 1
  %exn.slot12.i75.i268.i706.i = alloca i8*
  %ehselector.slot13.i76.i269.i707.i = alloca i32
  %a2.i77.i270.i708.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i699.i, i32 0, i32 0
  %327 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i313.i, align 8
  %a3.i78.i271.i709.i = getelementptr inbounds %class.object.1, %class.object.1* %327, i32 0, i32 0
  detach within %syncreg.i69.i146.i323.i, label %det.achd.i82.i274.i712.i, label %det.cont.i87.i279.i717.i unwind label %lpad11.i101.i297.i735.i

det.achd.i82.i274.i712.i:                         ; preds = %invoke.cont.i79.i266.i704.i.split
  %exn.slot5.i80.i272.i710.i = alloca i8*
  %ehselector.slot6.i81.i273.i711.i = alloca i32
  call void @llvm.taskframe.use(token %326)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i267.i705.i, %class.object.2* dereferenceable(1) %a3.i78.i271.i709.i)
          to label %invoke.cont7.i84.i276.i714.i unwind label %lpad4.i94.i286.i724.i

invoke.cont7.i84.i276.i714.i:                     ; preds = %det.achd.i82.i274.i712.i
  %call.i83.i275.i713.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i270.i708.i, %class.object.2* %agg.tmp.i74.i267.i705.i)
          to label %invoke.cont9.i85.i277.i715.i unwind label %lpad8.i95.i287.i725.i

invoke.cont9.i85.i277.i715.i:                     ; preds = %invoke.cont7.i84.i276.i714.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i705.i) #7
  reattach within %syncreg.i69.i146.i323.i, label %det.cont.i87.i279.i717.i

det.cont.i87.i279.i717.i:                         ; preds = %invoke.cont9.i85.i277.i715.i, %invoke.cont.i79.i266.i704.i.split
  %328 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i313.i, align 8
  %b21.i86.i278.i716.i = getelementptr inbounds %class.object.1, %class.object.1* %328, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i145.i316.i, %class.object.2* dereferenceable(1) %b21.i86.i278.i716.i)
          to label %invoke.cont22.i90.i282.i720.i unwind label %lpad19.i106.i298.i736.i

invoke.cont22.i90.i282.i720.i:                    ; preds = %det.cont.i87.i279.i717.i
  %b23.i88.i280.i718.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i699.i, i32 0, i32 1
  %call26.i89.i281.i719.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i280.i718.i, %class.object.2* %agg.tmp20.i70.i145.i316.i)
          to label %invoke.cont25.i91.i283.i721.i unwind label %lpad24.i107.i299.i737.i

invoke.cont25.i91.i283.i721.i:                    ; preds = %invoke.cont22.i90.i282.i720.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i316.i) #7
  sync within %syncreg.i69.i146.i323.i, label %sync.continue.i92.i284.i722.i

sync.continue.i92.i284.i722.i:                    ; preds = %invoke.cont25.i91.i283.i721.i
  invoke void @llvm.sync.unwind(token %syncreg.i69.i146.i323.i)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i unwind label %lpad19.i359.i797.i

lpad.i93.i285.i723.i:                             ; preds = %.noexc117.i265.i703.i
  %329 = landingpad { i8*, i32 }
          cleanup
  %330 = extractvalue { i8*, i32 } %329, 0
  store i8* %330, i8** %exn.slot.i67.i143.i314.i, align 8
  %331 = extractvalue { i8*, i32 } %329, 1
  store i32 %331, i32* %ehselector.slot.i68.i144.i315.i, align 4
  br label %ehcleanup29.i109.i305.i743.i

lpad4.i94.i286.i724.i:                            ; preds = %det.achd.i82.i274.i712.i
  %332 = landingpad { i8*, i32 }
          cleanup
  %333 = extractvalue { i8*, i32 } %332, 0
  store i8* %333, i8** %exn.slot5.i80.i272.i710.i, align 8
  %334 = extractvalue { i8*, i32 } %332, 1
  store i32 %334, i32* %ehselector.slot6.i81.i273.i711.i, align 4
  br label %ehcleanup.i100.i292.i730.i

lpad8.i95.i287.i725.i:                            ; preds = %invoke.cont7.i84.i276.i714.i
  %335 = landingpad { i8*, i32 }
          cleanup
  %336 = extractvalue { i8*, i32 } %335, 0
  store i8* %336, i8** %exn.slot5.i80.i272.i710.i, align 8
  %337 = extractvalue { i8*, i32 } %335, 1
  store i32 %337, i32* %ehselector.slot6.i81.i273.i711.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i705.i) #7
  br label %ehcleanup.i100.i292.i730.i

ehcleanup.i100.i292.i730.i:                       ; preds = %lpad8.i95.i287.i725.i, %lpad4.i94.i286.i724.i
  %exn.i96.i288.i726.i = load i8*, i8** %exn.slot5.i80.i272.i710.i, align 8
  %sel.i97.i289.i727.i = load i32, i32* %ehselector.slot6.i81.i273.i711.i, align 4
  %lpad.val.i98.i290.i728.i = insertvalue { i8*, i32 } undef, i8* %exn.i96.i288.i726.i, 0
  %lpad.val10.i99.i291.i729.i = insertvalue { i8*, i32 } %lpad.val.i98.i290.i728.i, i32 %sel.i97.i289.i727.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i146.i323.i, { i8*, i32 } %lpad.val10.i99.i291.i729.i)
          to label %unreachable.i115.i306.i744.i unwind label %lpad11.i101.i297.i735.i

lpad11.i101.i297.i735.i:                          ; preds = %ehcleanup.i100.i292.i730.i, %invoke.cont.i79.i266.i704.i.split
  %338 = landingpad { i8*, i32 }
          cleanup
  %339 = extractvalue { i8*, i32 } %338, 0
  store i8* %339, i8** %exn.slot12.i75.i268.i706.i, align 8
  %340 = extractvalue { i8*, i32 } %338, 1
  store i32 %340, i32* %ehselector.slot13.i76.i269.i707.i, align 4
  %exn15.i102.i293.i731.i = load i8*, i8** %exn.slot12.i75.i268.i706.i, align 8
  %sel16.i103.i294.i732.i = load i32, i32* %ehselector.slot13.i76.i269.i707.i, align 4
  %lpad.val17.i104.i295.i733.i = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i293.i731.i, 0
  %lpad.val18.i105.i296.i734.i = insertvalue { i8*, i32 } %lpad.val17.i104.i295.i733.i, i32 %sel16.i103.i294.i732.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %326, { i8*, i32 } %lpad.val18.i105.i296.i734.i)
          to label %unreachable.i115.i306.i744.i unwind label %lpad19.i106.i298.i736.i

lpad19.i106.i298.i736.i:                          ; preds = %lpad11.i101.i297.i735.i, %det.cont.i87.i279.i717.i
  %341 = landingpad { i8*, i32 }
          cleanup
  %342 = extractvalue { i8*, i32 } %341, 0
  store i8* %342, i8** %exn.slot.i67.i143.i314.i, align 8
  %343 = extractvalue { i8*, i32 } %341, 1
  store i32 %343, i32* %ehselector.slot.i68.i144.i315.i, align 4
  br label %ehcleanup28.i108.i300.i738.i

lpad24.i107.i299.i737.i:                          ; preds = %invoke.cont22.i90.i282.i720.i
  %344 = landingpad { i8*, i32 }
          cleanup
  %345 = extractvalue { i8*, i32 } %344, 0
  store i8* %345, i8** %exn.slot.i67.i143.i314.i, align 8
  %346 = extractvalue { i8*, i32 } %344, 1
  store i32 %346, i32* %ehselector.slot.i68.i144.i315.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i316.i) #7
  br label %ehcleanup28.i108.i300.i738.i

ehcleanup28.i108.i300.i738.i:                     ; preds = %lpad24.i107.i299.i737.i, %lpad19.i106.i298.i736.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i264.i702.i) #7
  br label %ehcleanup29.i109.i305.i743.i

ehcleanup29.i109.i305.i743.i:                     ; preds = %ehcleanup28.i108.i300.i738.i, %lpad.i93.i285.i723.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i262.i700.i) #7
  %exn30.i110.i301.i739.i = load i8*, i8** %exn.slot.i67.i143.i314.i, align 8
  %sel31.i111.i302.i740.i = load i32, i32* %ehselector.slot.i68.i144.i315.i, align 4
  %lpad.val32.i112.i303.i741.i = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i301.i739.i, 0
  %lpad.val33.i113.i304.i742.i = insertvalue { i8*, i32 } %lpad.val32.i112.i303.i741.i, i32 %sel31.i111.i302.i740.i, 1
  br label %lpad19.body.i361.i799.i

unreachable.i115.i306.i744.i:                     ; preds = %lpad11.i101.i297.i735.i, %ehcleanup.i100.i292.i730.i
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i:     ; preds = %sync.continue.i92.i284.i722.i
  call void @llvm.stackrestore(i8* %savedstack116.i260.i698.i)
  %b23.i308.i745.i = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i589.i, i32 0, i32 1
  %savedstack161.i309.i746.i = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i308.i745.i, %class.object.1** %this.addr.i122.i133.i305.i, align 8
  %this1.i127.i310.i747.i = load %class.object.1*, %class.object.1** %this.addr.i122.i133.i305.i, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i.split

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i.split: ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i
  %347 = call token @llvm.taskframe.create()
  %a.i131.i311.i749.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i747.i, i32 0, i32 0
  %a2.i132.i312.i750.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i321.i, i32 0, i32 0
  detach within %syncreg.i123.i140.i322.i, label %det.achd.i136.i316.i754.i, label %det.cont.i141.i319.i757.i unwind label %lpad4.i152.i333.i771.i

det.achd.i136.i316.i754.i:                        ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i.split
  %exn.slot.i133.i313.i751.i = alloca i8*
  %ehselector.slot.i134.i314.i752.i = alloca i32
  call void @llvm.taskframe.use(token %347)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i137.i309.i, %class.object.2* dereferenceable(1) %a2.i132.i312.i750.i)
  %call.i135.i315.i753.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i311.i749.i, %class.object.2* %agg.tmp.i128.i137.i309.i)
          to label %invoke.cont.i137.i317.i755.i unwind label %lpad.i147.i328.i766.i

invoke.cont.i137.i317.i755.i:                     ; preds = %det.achd.i136.i316.i754.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i309.i) #7
  reattach within %syncreg.i123.i140.i322.i, label %det.cont.i141.i319.i757.i

det.cont.i141.i319.i757.i:                        ; preds = %invoke.cont.i137.i317.i755.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i.split
  %b.i138.i318.i756.i = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i321.i, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i136.i308.i, %class.object.2* dereferenceable(1) %b.i138.i318.i756.i)
          to label %.noexc164.i322.i760.i unwind label %lpad24.i362.i800.i

.noexc164.i322.i760.i:                            ; preds = %det.cont.i141.i319.i757.i
  %b15.i139.i320.i758.i = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i747.i, i32 0, i32 1
  %call18.i140.i321.i759.i = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i320.i758.i, %class.object.2* %agg.tmp14.i126.i136.i308.i)
          to label %invoke.cont17.i142.i323.i761.i unwind label %lpad16.i154.i335.i773.i

invoke.cont17.i142.i323.i761.i:                   ; preds = %.noexc164.i322.i760.i
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i308.i) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i328.i766.i:                            ; preds = %det.achd.i136.i316.i754.i
  %348 = landingpad { i8*, i32 }
          cleanup
  %349 = extractvalue { i8*, i32 } %348, 0
  store i8* %349, i8** %exn.slot.i133.i313.i751.i, align 8
  %350 = extractvalue { i8*, i32 } %348, 1
  store i32 %350, i32* %ehselector.slot.i134.i314.i752.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i309.i) #7
  %exn.i143.i324.i762.i = load i8*, i8** %exn.slot.i133.i313.i751.i, align 8
  %sel.i144.i325.i763.i = load i32, i32* %ehselector.slot.i134.i314.i752.i, align 4
  %lpad.val.i145.i326.i764.i = insertvalue { i8*, i32 } undef, i8* %exn.i143.i324.i762.i, 0
  %lpad.val3.i146.i327.i765.i = insertvalue { i8*, i32 } %lpad.val.i145.i326.i764.i, i32 %sel.i144.i325.i763.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i140.i322.i, { i8*, i32 } %lpad.val3.i146.i327.i765.i)
          to label %unreachable.i160.i341.i779.i unwind label %lpad4.i152.i333.i771.i

lpad4.i152.i333.i771.i:                           ; preds = %lpad.i147.i328.i766.i, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i.split
  %351 = landingpad { i8*, i32 }
          cleanup
  %352 = extractvalue { i8*, i32 } %351, 0
  store i8* %352, i8** %exn.slot5.i129.i138.i310.i, align 8
  %353 = extractvalue { i8*, i32 } %351, 1
  store i32 %353, i32* %ehselector.slot6.i130.i139.i311.i, align 4
  %exn7.i148.i329.i767.i = load i8*, i8** %exn.slot5.i129.i138.i310.i, align 8
  %sel8.i149.i330.i768.i = load i32, i32* %ehselector.slot6.i130.i139.i311.i, align 4
  %lpad.val9.i150.i331.i769.i = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i329.i767.i, 0
  %lpad.val10.i151.i332.i770.i = insertvalue { i8*, i32 } %lpad.val9.i150.i331.i769.i, i32 %sel8.i149.i330.i768.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %347, { i8*, i32 } %lpad.val10.i151.i332.i770.i)
          to label %unreachable.i160.i341.i779.i unwind label %lpad11.i153.i334.i772.i

lpad11.i153.i334.i772.i:                          ; preds = %lpad4.i152.i333.i771.i
  %354 = landingpad { i8*, i32 }
          cleanup
  %355 = extractvalue { i8*, i32 } %354, 0
  store i8* %355, i8** %exn.slot12.i124.i134.i306.i, align 8
  %356 = extractvalue { i8*, i32 } %354, 1
  store i32 %356, i32* %ehselector.slot13.i125.i135.i307.i, align 4
  br label %eh.resume.i159.i340.i778.i

lpad16.i154.i335.i773.i:                          ; preds = %.noexc164.i322.i760.i
  %357 = landingpad { i8*, i32 }
          cleanup
  %358 = extractvalue { i8*, i32 } %357, 0
  store i8* %358, i8** %exn.slot12.i124.i134.i306.i, align 8
  %359 = extractvalue { i8*, i32 } %357, 1
  store i32 %359, i32* %ehselector.slot13.i125.i135.i307.i, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i308.i) #7
  br label %eh.resume.i159.i340.i778.i

eh.resume.i159.i340.i778.i:                       ; preds = %lpad16.i154.i335.i773.i, %lpad11.i153.i334.i772.i
  %exn19.i155.i336.i774.i = load i8*, i8** %exn.slot12.i124.i134.i306.i, align 8
  %sel20.i156.i337.i775.i = load i32, i32* %ehselector.slot13.i125.i135.i307.i, align 4
  %lpad.val21.i157.i338.i776.i = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i336.i774.i, 0
  %lpad.val22.i158.i339.i777.i = insertvalue { i8*, i32 } %lpad.val21.i157.i338.i776.i, i32 %sel20.i156.i337.i775.i, 1
  br label %lpad24.body.i364.i802.i

unreachable.i160.i341.i779.i:                     ; preds = %lpad4.i152.i333.i771.i, %lpad.i147.i328.i766.i
  unreachable

lpad.i342.i780.i:                                 ; preds = %.noexc374.i593.i
  %360 = landingpad { i8*, i32 }
          cleanup
  %361 = extractvalue { i8*, i32 } %360, 0
  store i8* %361, i8** %exn.slot.i149.i319.i, align 8
  %362 = extractvalue { i8*, i32 } %360, 1
  store i32 %362, i32* %ehselector.slot.i150.i320.i, align 4
  br label %ehcleanup29.i366.i808.i

lpad4.i343.i781.i:                                ; preds = %sync.continue.i.i202.i640.i, %det.achd.i181.i619.i
  %363 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i345.i783.i

lpad4.body.i345.i783.i:                           ; preds = %lpad4.i343.i781.i, %ehcleanup29.i.i223.i661.i
  %eh.lpad-body.i344.i782.i = phi { i8*, i32 } [ %363, %lpad4.i343.i781.i ], [ %lpad.val33.i.i222.i660.i, %ehcleanup29.i.i223.i661.i ]
  %364 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i782.i, 0
  store i8* %364, i8** %exn.slot5.i176.i614.i, align 8
  %365 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i782.i, 1
  store i32 %365, i32* %ehselector.slot6.i177.i615.i, align 4
  br label %ehcleanup.i353.i791.i

lpad8.i346.i784.i:                                ; preds = %det.cont.i52.i236.i674.i
  %366 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i348.i786.i

lpad8.body.i348.i786.i:                           ; preds = %lpad8.i346.i784.i, %eh.resume.i.i257.i695.i
  %eh.lpad-body64.i347.i785.i = phi { i8*, i32 } [ %366, %lpad8.i346.i784.i ], [ %lpad.val22.i.i256.i694.i, %eh.resume.i.i257.i695.i ]
  %367 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i785.i, 0
  store i8* %367, i8** %exn.slot5.i176.i614.i, align 8
  %368 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i785.i, 1
  store i32 %368, i32* %ehselector.slot6.i177.i615.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i157.i595.i) #7
  br label %ehcleanup.i353.i791.i

ehcleanup.i353.i791.i:                            ; preds = %lpad8.body.i348.i786.i, %lpad4.body.i345.i783.i
  %exn.i349.i787.i = load i8*, i8** %exn.slot5.i176.i614.i, align 8
  %sel.i350.i788.i = load i32, i32* %ehselector.slot6.i177.i615.i, align 4
  %lpad.val.i351.i789.i = insertvalue { i8*, i32 } undef, i8* %exn.i349.i787.i, 0
  %lpad.val10.i352.i790.i = insertvalue { i8*, i32 } %lpad.val.i351.i789.i, i32 %sel.i350.i788.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i151.i324.i, { i8*, i32 } %lpad.val10.i352.i790.i)
          to label %unreachable.i372.i809.i unwind label %lpad11.i354.i796.i

lpad11.i354.i796.i:                               ; preds = %ehcleanup.i353.i791.i, %invoke.cont.i156.i594.i.split
  %369 = landingpad { i8*, i32 }
          cleanup
  %370 = extractvalue { i8*, i32 } %369, 0
  store i8* %370, i8** %exn.slot12.i158.i596.i, align 8
  %371 = extractvalue { i8*, i32 } %369, 1
  store i32 %371, i32* %ehselector.slot13.i159.i597.i, align 4
  %exn15.i355.i792.i = load i8*, i8** %exn.slot12.i158.i596.i, align 8
  %sel16.i356.i793.i = load i32, i32* %ehselector.slot13.i159.i597.i, align 4
  %lpad.val17.i357.i794.i = insertvalue { i8*, i32 } undef, i8* %exn15.i355.i792.i, 0
  %lpad.val18.i358.i795.i = insertvalue { i8*, i32 } %lpad.val17.i357.i794.i, i32 %sel16.i356.i793.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %289, { i8*, i32 } %lpad.val18.i358.i795.i)
          to label %unreachable.i372.i809.i unwind label %lpad19.i359.i797.i

lpad19.i359.i797.i:                               ; preds = %lpad11.i354.i796.i, %sync.continue.i92.i284.i722.i, %det.cont.i263.i701.i
  %372 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i361.i799.i

lpad19.body.i361.i799.i:                          ; preds = %lpad19.i359.i797.i, %ehcleanup29.i109.i305.i743.i
  %eh.lpad-body118.i360.i798.i = phi { i8*, i32 } [ %372, %lpad19.i359.i797.i ], [ %lpad.val33.i113.i304.i742.i, %ehcleanup29.i109.i305.i743.i ]
  %373 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i798.i, 0
  store i8* %373, i8** %exn.slot.i149.i319.i, align 8
  %374 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i798.i, 1
  store i32 %374, i32* %ehselector.slot.i150.i320.i, align 4
  br label %ehcleanup28.i365.i803.i

lpad24.i362.i800.i:                               ; preds = %det.cont.i141.i319.i757.i
  %375 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i364.i802.i

lpad24.body.i364.i802.i:                          ; preds = %lpad24.i362.i800.i, %eh.resume.i159.i340.i778.i
  %eh.lpad-body165.i363.i801.i = phi { i8*, i32 } [ %375, %lpad24.i362.i800.i ], [ %lpad.val22.i158.i339.i777.i, %eh.resume.i159.i340.i778.i ]
  %376 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i801.i, 0
  store i8* %376, i8** %exn.slot.i149.i319.i, align 8
  %377 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i801.i, 1
  store i32 %377, i32* %ehselector.slot.i150.i320.i, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i152.i321.i) #7
  br label %ehcleanup28.i365.i803.i

ehcleanup28.i365.i803.i:                          ; preds = %lpad24.body.i364.i802.i, %lpad19.body.i361.i799.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i155.i592.i) #7
  br label %ehcleanup29.i366.i808.i

ehcleanup29.i366.i808.i:                          ; preds = %ehcleanup28.i365.i803.i, %lpad.i342.i780.i
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i154.i590.i) #7
  %exn30.i367.i804.i = load i8*, i8** %exn.slot.i149.i319.i, align 8
  %sel31.i368.i805.i = load i32, i32* %ehselector.slot.i150.i320.i, align 4
  %lpad.val32.i369.i806.i = insertvalue { i8*, i32 } undef, i8* %exn30.i367.i804.i, 0
  %lpad.val33.i370.i807.i = insertvalue { i8*, i32 } %lpad.val32.i369.i806.i, i32 %sel31.i368.i805.i, 1
  br label %lpad19.body.i825.i

unreachable.i372.i809.i:                          ; preds = %lpad11.i354.i796.i, %ehcleanup.i353.i791.i
  unreachable

lpad.i810.i:                                      ; preds = %.noexc833.i
  %378 = landingpad { i8*, i32 }
          cleanup
  %379 = extractvalue { i8*, i32 } %378, 0
  store i8* %379, i8** %exn.slot.i330.i, align 8
  %380 = extractvalue { i8*, i32 } %378, 1
  store i32 %380, i32* %ehselector.slot.i331.i, align 4
  br label %ehcleanup29.i826.i

lpad4.i811.i:                                     ; preds = %det.achd.i368.i
  %381 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i813.i

lpad4.body.i813.i:                                ; preds = %lpad4.i811.i, %ehcleanup29.i.i585.i
  %eh.lpad-body.i812.i = phi { i8*, i32 } [ %381, %lpad4.i811.i ], [ %lpad.val33.i.i584.i, %ehcleanup29.i.i585.i ]
  %382 = extractvalue { i8*, i32 } %eh.lpad-body.i812.i, 0
  store i8* %382, i8** %exn.slot5.i363.i, align 8
  %383 = extractvalue { i8*, i32 } %eh.lpad-body.i812.i, 1
  store i32 %383, i32* %ehselector.slot6.i364.i, align 4
  %exn.i814.i = load i8*, i8** %exn.slot5.i363.i, align 8
  %sel.i815.i = load i32, i32* %ehselector.slot6.i364.i, align 4
  %lpad.val.i816.i = insertvalue { i8*, i32 } undef, i8* %exn.i814.i, 0
  %lpad.val10.i817.i = insertvalue { i8*, i32 } %lpad.val.i816.i, i32 %sel.i815.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i332.i, { i8*, i32 } %lpad.val10.i817.i)
          to label %unreachable.i831.i unwind label %lpad11.i818.i

lpad11.i818.i:                                    ; preds = %lpad4.body.i813.i, %invoke.cont.i337.i.split
  %384 = landingpad { i8*, i32 }
          cleanup
  %385 = extractvalue { i8*, i32 } %384, 0
  store i8* %385, i8** %exn.slot12.i339.i, align 8
  %386 = extractvalue { i8*, i32 } %384, 1
  store i32 %386, i32* %ehselector.slot13.i340.i, align 4
  %exn15.i819.i = load i8*, i8** %exn.slot12.i339.i, align 8
  %sel16.i820.i = load i32, i32* %ehselector.slot13.i340.i, align 4
  %lpad.val17.i821.i = insertvalue { i8*, i32 } undef, i8* %exn15.i819.i, 0
  %lpad.val18.i822.i = insertvalue { i8*, i32 } %lpad.val17.i821.i, i32 %sel16.i820.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %197, { i8*, i32 } %lpad.val18.i822.i)
          to label %unreachable.i831.i unwind label %lpad19.i823.i

lpad19.i823.i:                                    ; preds = %lpad11.i818.i, %det.cont.i591.i
  %387 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i825.i

lpad19.body.i825.i:                               ; preds = %lpad19.i823.i, %ehcleanup29.i366.i808.i
  %eh.lpad-body375.i824.i = phi { i8*, i32 } [ %387, %lpad19.i823.i ], [ %lpad.val33.i370.i807.i, %ehcleanup29.i366.i808.i ]
  %388 = extractvalue { i8*, i32 } %eh.lpad-body375.i824.i, 0
  store i8* %388, i8** %exn.slot.i330.i, align 8
  %389 = extractvalue { i8*, i32 } %eh.lpad-body375.i824.i, 1
  store i32 %389, i32* %ehselector.slot.i331.i, align 4
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %b.i336.i) #7
  br label %ehcleanup29.i826.i

ehcleanup29.i826.i:                               ; preds = %lpad19.body.i825.i, %lpad.i810.i
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %a.i335.i) #7
  %exn30.i827.i = load i8*, i8** %exn.slot.i330.i, align 8
  %sel31.i828.i = load i32, i32* %ehselector.slot.i331.i, align 4
  %lpad.val32.i829.i = insertvalue { i8*, i32 } undef, i8* %exn30.i827.i, 0
  %lpad.val33.i830.i = insertvalue { i8*, i32 } %lpad.val32.i829.i, i32 %sel31.i828.i, 1
  br label %lpad19.body.i

unreachable.i831.i:                               ; preds = %lpad11.i818.i, %lpad4.body.i813.i
  unreachable

lpad.i:                                           ; preds = %.noexc
  %390 = landingpad { i8*, i32 }
          cleanup
  %391 = extractvalue { i8*, i32 } %390, 0
  store i8* %391, i8** %exn.slot.i, align 8
  %392 = extractvalue { i8*, i32 } %390, 1
  store i32 %392, i32* %ehselector.slot.i, align 4
  br label %ehcleanup29.i

lpad4.i:                                          ; preds = %det.achd.i
  %393 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i

lpad4.body.i:                                     ; preds = %lpad4.i, %ehcleanup29.i.i
  %eh.lpad-body.i = phi { i8*, i32 } [ %393, %lpad4.i ], [ %lpad.val33.i.i, %ehcleanup29.i.i ]
  %394 = extractvalue { i8*, i32 } %eh.lpad-body.i, 0
  store i8* %394, i8** %exn.slot5.i, align 8
  %395 = extractvalue { i8*, i32 } %eh.lpad-body.i, 1
  store i32 %395, i32* %ehselector.slot6.i, align 4
  %exn.i = load i8*, i8** %exn.slot5.i, align 8
  %sel.i = load i32, i32* %ehselector.slot6.i, align 4
  %lpad.val.i = insertvalue { i8*, i32 } undef, i8* %exn.i, 0
  %lpad.val10.i = insertvalue { i8*, i32 } %lpad.val.i, i32 %sel.i, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i, { i8*, i32 } %lpad.val10.i)
          to label %unreachable.i unwind label %lpad11.i

lpad11.i:                                         ; preds = %lpad4.body.i, %invoke.cont.i.split
  %396 = landingpad { i8*, i32 }
          cleanup
  %397 = extractvalue { i8*, i32 } %396, 0
  store i8* %397, i8** %exn.slot12.i, align 8
  %398 = extractvalue { i8*, i32 } %396, 1
  store i32 %398, i32* %ehselector.slot13.i, align 4
  %exn15.i = load i8*, i8** %exn.slot12.i, align 8
  %sel16.i = load i32, i32* %ehselector.slot13.i, align 4
  %lpad.val17.i = insertvalue { i8*, i32 } undef, i8* %exn15.i, 0
  %lpad.val18.i = insertvalue { i8*, i32 } %lpad.val17.i, i32 %sel16.i, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %1, { i8*, i32 } %lpad.val18.i)
          to label %unreachable.i unwind label %lpad19.i

lpad19.i:                                         ; preds = %lpad11.i, %det.cont.i
  %399 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i

lpad19.body.i:                                    ; preds = %lpad19.i, %ehcleanup29.i826.i
  %eh.lpad-body834.i = phi { i8*, i32 } [ %399, %lpad19.i ], [ %lpad.val33.i830.i, %ehcleanup29.i826.i ]
  %400 = extractvalue { i8*, i32 } %eh.lpad-body834.i, 0
  store i8* %400, i8** %exn.slot.i, align 8
  %401 = extractvalue { i8*, i32 } %eh.lpad-body834.i, 1
  store i32 %401, i32* %ehselector.slot.i, align 4
  call void @_ZN6objectILi3EED1Ev(%class.object* %b.i) #7
  br label %ehcleanup29.i

ehcleanup29.i:                                    ; preds = %lpad19.body.i, %lpad.i
  call void @_ZN6objectILi3EED1Ev(%class.object* %a.i) #7
  %exn30.i = load i8*, i8** %exn.slot.i, align 8
  %sel31.i = load i32, i32* %ehselector.slot.i, align 4
  %lpad.val32.i = insertvalue { i8*, i32 } undef, i8* %exn30.i, 0
  %lpad.val33.i = insertvalue { i8*, i32 } %lpad.val32.i, i32 %sel31.i, 1
  br label %lpad.body

unreachable.i:                                    ; preds = %lpad11.i, %lpad4.body.i
  unreachable

_ZN6objectILi4EEC2ERKS0_.exit:                    ; No predecessors!
  br label %invoke.cont

invoke.cont:                                      ; preds = %_ZN6objectILi4EEC2ERKS0_.exit
  %402 = load i64, i64* %x.addr, align 8
  %403 = load i64, i64* %i, align 8
  %add = add nsw i64 %402, %403
  %404 = load i64, i64* %x.addr, align 8
  %405 = load i64, i64* %i, align 8
  %call = invoke i64 @_Z3addll(i64 %404, i64 %405)
          to label %invoke.cont2 unwind label %lpad1

invoke.cont2:                                     ; preds = %invoke.cont
  %savedstack1143 = call i8* @llvm.stacksave()
  store %class.object.3* %agg.tmp3, %class.object.3** %this.addr.i69, align 8
  store %class.object.3* %obj, %class.object.3** %other.addr.i70, align 8
  %this1.i75 = load %class.object.3*, %class.object.3** %this.addr.i69, align 8
  %a.i76 = getelementptr inbounds %class.object.3, %class.object.3* %this1.i75, i32 0, i32 0
  invoke void @_ZN6objectILi3EEC1Ev(%class.object* %a.i76)
          to label %.noexc1144 unwind label %lpad1

.noexc1144:                                       ; preds = %invoke.cont2
  %b.i77 = getelementptr inbounds %class.object.3, %class.object.3* %this1.i75, i32 0, i32 1
  invoke void @_ZN6objectILi3EEC1Ev(%class.object* %b.i77)
          to label %invoke.cont.i78 unwind label %lpad.i1121

invoke.cont.i78:                                  ; preds = %.noexc1144
  %406 = call token @llvm.taskframe.create()
  %agg.tmp.i79 = alloca %class.object, align 1
  %exn.slot12.i80 = alloca i8*
  %ehselector.slot13.i81 = alloca i32
  %a2.i82 = getelementptr inbounds %class.object.3, %class.object.3* %this1.i75, i32 0, i32 0
  %407 = load %class.object.3*, %class.object.3** %other.addr.i70, align 8
  %a3.i83 = getelementptr inbounds %class.object.3, %class.object.3* %407, i32 0, i32 0
  detach within %syncreg.i73, label %det.achd.i121, label %det.cont.i623 unwind label %lpad11.i1129

det.achd.i121:                                    ; preds = %invoke.cont.i78
  %this.addr.i122.i133.i.i84 = alloca %class.object.1*, align 8
  %exn.slot12.i124.i134.i.i85 = alloca i8*
  %ehselector.slot13.i125.i135.i.i86 = alloca i32
  %agg.tmp14.i126.i136.i.i87 = alloca %class.object.2, align 1
  %agg.tmp.i128.i137.i.i88 = alloca %class.object.2, align 1
  %exn.slot5.i129.i138.i.i89 = alloca i8*
  %ehselector.slot6.i130.i139.i.i90 = alloca i32
  %this.addr.i65.i141.i.i91 = alloca %class.object.1*, align 8
  %other.addr.i66.i142.i.i92 = alloca %class.object.1*, align 8
  %exn.slot.i67.i143.i.i93 = alloca i8*
  %ehselector.slot.i68.i144.i.i94 = alloca i32
  %agg.tmp20.i70.i145.i.i95 = alloca %class.object.2, align 1
  %this.addr.i147.i.i96 = alloca %class.object.0*, align 8
  %other.addr.i148.i.i97 = alloca %class.object.0*, align 8
  %exn.slot.i149.i.i98 = alloca i8*
  %ehselector.slot.i150.i.i99 = alloca i32
  %agg.tmp20.i152.i.i100 = alloca %class.object.1, align 1
  %this.addr.i.i101 = alloca %class.object*, align 8
  %other.addr.i.i102 = alloca %class.object*, align 8
  %exn.slot.i.i103 = alloca i8*
  %ehselector.slot.i.i104 = alloca i32
  %agg.tmp20.i.i105 = alloca %class.object.0, align 1
  %syncreg.i105.i387.i.i106 = call token @llvm.syncregion.start()
  %syncreg.i56.i393.i.i107 = call token @llvm.syncregion.start()
  %syncreg.i395.i.i108 = call token @llvm.syncregion.start()
  %syncreg.i123.i140.i.i109 = call token @llvm.syncregion.start()
  %syncreg.i69.i146.i.i110 = call token @llvm.syncregion.start()
  %syncreg.i151.i.i111 = call token @llvm.syncregion.start()
  %syncreg.i105.i.i.i112 = call token @llvm.syncregion.start()
  %syncreg.i56.i.i.i113 = call token @llvm.syncregion.start()
  %syncreg.i38.i.i114 = call token @llvm.syncregion.start()
  %syncreg.i.i115 = call token @llvm.syncregion.start()
  %exn.slot5.i116 = alloca i8*
  %ehselector.slot6.i117 = alloca i32
  call void @llvm.taskframe.use(token %406)
  %savedstack.i118 = call i8* @llvm.stacksave()
  store %class.object* %agg.tmp.i79, %class.object** %this.addr.i.i101, align 8
  store %class.object* %a3.i83, %class.object** %other.addr.i.i102, align 8
  %this1.i.i119 = load %class.object*, %class.object** %this.addr.i.i101, align 8
  %a.i.i120 = getelementptr inbounds %class.object, %class.object* %this1.i.i119, i32 0, i32 0
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %a.i.i120)
          to label %.noexc.i123 unwind label %lpad4.i1122

.noexc.i123:                                      ; preds = %det.achd.i121
  %b.i.i122 = getelementptr inbounds %class.object, %class.object* %this1.i.i119, i32 0, i32 1
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %b.i.i122)
          to label %invoke.cont.i.i124 unwind label %lpad.i.i597

invoke.cont.i.i124:                               ; preds = %.noexc.i123
  %408 = call token @llvm.taskframe.create()
  %agg.tmp.i.i125 = alloca %class.object.0, align 1
  %exn.slot12.i.i126 = alloca i8*
  %ehselector.slot13.i.i127 = alloca i32
  %a2.i.i128 = getelementptr inbounds %class.object, %class.object* %this1.i.i119, i32 0, i32 0
  %409 = load %class.object*, %class.object** %other.addr.i.i102, align 8
  %a3.i.i129 = getelementptr inbounds %class.object, %class.object* %409, i32 0, i32 0
  detach within %syncreg.i.i115, label %det.achd.i.i155, label %det.cont.i.i378 unwind label %lpad11.i.i609

det.achd.i.i155:                                  ; preds = %invoke.cont.i.i124
  %this.addr.i122.i.i.i130 = alloca %class.object.1*, align 8
  %exn.slot12.i124.i.i.i131 = alloca i8*
  %ehselector.slot13.i125.i.i.i132 = alloca i32
  %agg.tmp14.i126.i.i.i133 = alloca %class.object.2, align 1
  %agg.tmp.i128.i.i.i134 = alloca %class.object.2, align 1
  %exn.slot5.i129.i.i.i135 = alloca i8*
  %ehselector.slot6.i130.i.i.i136 = alloca i32
  %this.addr.i65.i.i.i137 = alloca %class.object.1*, align 8
  %other.addr.i66.i.i.i138 = alloca %class.object.1*, align 8
  %exn.slot.i67.i.i.i139 = alloca i8*
  %ehselector.slot.i68.i.i.i140 = alloca i32
  %agg.tmp20.i70.i.i.i141 = alloca %class.object.2, align 1
  %this.addr.i.i.i142 = alloca %class.object.0*, align 8
  %other.addr.i.i.i143 = alloca %class.object.0*, align 8
  %exn.slot.i.i.i144 = alloca i8*
  %ehselector.slot.i.i.i145 = alloca i32
  %agg.tmp20.i.i.i146 = alloca %class.object.1, align 1
  %syncreg.i123.i.i.i147 = call token @llvm.syncregion.start()
  %syncreg.i69.i.i.i148 = call token @llvm.syncregion.start()
  %syncreg.i.i.i149 = call token @llvm.syncregion.start()
  %exn.slot5.i.i150 = alloca i8*
  %ehselector.slot6.i.i151 = alloca i32
  call void @llvm.taskframe.use(token %408)
  %savedstack.i.i152 = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp.i.i125, %class.object.0** %this.addr.i.i.i142, align 8
  store %class.object.0* %a3.i.i129, %class.object.0** %other.addr.i.i.i143, align 8
  %this1.i.i.i153 = load %class.object.0*, %class.object.0** %this.addr.i.i.i142, align 8
  %a.i.i.i154 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i.i153, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i.i.i154)
          to label %.noexc.i.i157 unwind label %lpad4.i.i598

.noexc.i.i157:                                    ; preds = %det.achd.i.i155
  %b.i.i.i156 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i.i153, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i.i.i156)
          to label %invoke.cont.i.i.i158 unwind label %lpad.i.i.i344

invoke.cont.i.i.i158:                             ; preds = %.noexc.i.i157
  %410 = call token @llvm.taskframe.create()
  %agg.tmp.i.i.i159 = alloca %class.object.1, align 1
  %exn.slot12.i.i.i160 = alloca i8*
  %ehselector.slot13.i.i.i161 = alloca i32
  %a2.i.i.i162 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i.i153, i32 0, i32 0
  %411 = load %class.object.0*, %class.object.0** %other.addr.i.i.i143, align 8
  %a3.i.i.i163 = getelementptr inbounds %class.object.0, %class.object.0* %411, i32 0, i32 0
  detach within %syncreg.i.i.i149, label %det.achd.i.i.i183, label %det.cont.i.i.i265 unwind label %lpad11.i.i.i360

det.achd.i.i.i183:                                ; preds = %invoke.cont.i.i.i158
  %this.addr.i36.i.i.i164 = alloca %class.object.1*, align 8
  %exn.slot12.i38.i.i.i165 = alloca i8*
  %ehselector.slot13.i39.i.i.i166 = alloca i32
  %agg.tmp14.i.i.i.i167 = alloca %class.object.2, align 1
  %agg.tmp.i41.i.i.i168 = alloca %class.object.2, align 1
  %exn.slot5.i42.i.i.i169 = alloca i8*
  %ehselector.slot6.i43.i.i.i170 = alloca i32
  %syncreg.i37.i.i.i171 = call token @llvm.syncregion.start()
  %this.addr.i.i.i.i172 = alloca %class.object.1*, align 8
  %other.addr.i.i.i.i173 = alloca %class.object.1*, align 8
  %exn.slot.i.i.i.i174 = alloca i8*
  %ehselector.slot.i.i.i.i175 = alloca i32
  %agg.tmp20.i.i.i.i176 = alloca %class.object.2, align 1
  %syncreg.i.i.i.i177 = call token @llvm.syncregion.start()
  %exn.slot5.i.i.i178 = alloca i8*
  %ehselector.slot6.i.i.i179 = alloca i32
  call void @llvm.taskframe.use(token %410)
  %savedstack.i.i.i180 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i.i.i159, %class.object.1** %this.addr.i.i.i.i172, align 8
  store %class.object.1* %a3.i.i.i163, %class.object.1** %other.addr.i.i.i.i173, align 8
  %this1.i.i.i.i181 = load %class.object.1*, %class.object.1** %this.addr.i.i.i.i172, align 8
  %a.i.i.i.i182 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i.i181, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i.i.i182)
          to label %.noexc.i.i.i185 unwind label %lpad4.i.i.i345

.noexc.i.i.i185:                                  ; preds = %det.achd.i.i.i183
  %b.i.i.i.i184 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i.i181, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i.i.i184)
          to label %invoke.cont.i.i.i.i186 unwind label %lpad.i.i.i.i205

invoke.cont.i.i.i.i186:                           ; preds = %.noexc.i.i.i185
  %412 = call token @llvm.taskframe.create()
  %agg.tmp.i.i.i.i187 = alloca %class.object.2, align 1
  %exn.slot12.i.i.i.i188 = alloca i8*
  %ehselector.slot13.i.i.i.i189 = alloca i32
  %a2.i.i.i.i190 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i.i181, i32 0, i32 0
  %413 = load %class.object.1*, %class.object.1** %other.addr.i.i.i.i173, align 8
  %a3.i.i.i.i191 = getelementptr inbounds %class.object.1, %class.object.1* %413, i32 0, i32 0
  detach within %syncreg.i.i.i.i177, label %det.achd.i.i.i.i194, label %det.cont.i.i.i.i199 unwind label %lpad11.i.i.i.i217

det.achd.i.i.i.i194:                              ; preds = %invoke.cont.i.i.i.i186
  %exn.slot5.i.i.i.i192 = alloca i8*
  %ehselector.slot6.i.i.i.i193 = alloca i32
  call void @llvm.taskframe.use(token %412)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i.i.i187, %class.object.2* dereferenceable(1) %a3.i.i.i.i191)
          to label %invoke.cont7.i.i.i.i196 unwind label %lpad4.i.i.i.i206

invoke.cont7.i.i.i.i196:                          ; preds = %det.achd.i.i.i.i194
  %call.i.i.i.i195 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i.i.i190, %class.object.2* %agg.tmp.i.i.i.i187)
          to label %invoke.cont9.i.i.i.i197 unwind label %lpad8.i.i.i.i207

invoke.cont9.i.i.i.i197:                          ; preds = %invoke.cont7.i.i.i.i196
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i.i187) #7
  reattach within %syncreg.i.i.i.i177, label %det.cont.i.i.i.i199

det.cont.i.i.i.i199:                              ; preds = %invoke.cont9.i.i.i.i197, %invoke.cont.i.i.i.i186
  %414 = load %class.object.1*, %class.object.1** %other.addr.i.i.i.i173, align 8
  %b21.i.i.i.i198 = getelementptr inbounds %class.object.1, %class.object.1* %414, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i.i.i176, %class.object.2* dereferenceable(1) %b21.i.i.i.i198)
          to label %invoke.cont22.i.i.i.i202 unwind label %lpad19.i.i.i.i218

invoke.cont22.i.i.i.i202:                         ; preds = %det.cont.i.i.i.i199
  %b23.i.i.i.i200 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i.i181, i32 0, i32 1
  %call26.i.i.i.i201 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i.i.i200, %class.object.2* %agg.tmp20.i.i.i.i176)
          to label %invoke.cont25.i.i.i.i203 unwind label %lpad24.i.i.i.i219

invoke.cont25.i.i.i.i203:                         ; preds = %invoke.cont22.i.i.i.i202
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i.i176) #7
  sync within %syncreg.i.i.i.i177, label %sync.continue.i.i.i.i204

sync.continue.i.i.i.i204:                         ; preds = %invoke.cont25.i.i.i.i203
  invoke void @llvm.sync.unwind(token %syncreg.i.i.i.i177)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i229 unwind label %lpad4.i.i.i345

lpad.i.i.i.i205:                                  ; preds = %.noexc.i.i.i185
  %415 = landingpad { i8*, i32 }
          cleanup
  %416 = extractvalue { i8*, i32 } %415, 0
  store i8* %416, i8** %exn.slot.i.i.i.i174, align 8
  %417 = extractvalue { i8*, i32 } %415, 1
  store i32 %417, i32* %ehselector.slot.i.i.i.i175, align 4
  br label %ehcleanup29.i.i.i.i225

lpad4.i.i.i.i206:                                 ; preds = %det.achd.i.i.i.i194
  %418 = landingpad { i8*, i32 }
          cleanup
  %419 = extractvalue { i8*, i32 } %418, 0
  store i8* %419, i8** %exn.slot5.i.i.i.i192, align 8
  %420 = extractvalue { i8*, i32 } %418, 1
  store i32 %420, i32* %ehselector.slot6.i.i.i.i193, align 4
  br label %ehcleanup.i.i.i.i212

lpad8.i.i.i.i207:                                 ; preds = %invoke.cont7.i.i.i.i196
  %421 = landingpad { i8*, i32 }
          cleanup
  %422 = extractvalue { i8*, i32 } %421, 0
  store i8* %422, i8** %exn.slot5.i.i.i.i192, align 8
  %423 = extractvalue { i8*, i32 } %421, 1
  store i32 %423, i32* %ehselector.slot6.i.i.i.i193, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i.i187) #7
  br label %ehcleanup.i.i.i.i212

ehcleanup.i.i.i.i212:                             ; preds = %lpad8.i.i.i.i207, %lpad4.i.i.i.i206
  %exn.i.i.i.i208 = load i8*, i8** %exn.slot5.i.i.i.i192, align 8
  %sel.i.i.i.i209 = load i32, i32* %ehselector.slot6.i.i.i.i193, align 4
  %lpad.val.i.i.i.i210 = insertvalue { i8*, i32 } undef, i8* %exn.i.i.i.i208, 0
  %lpad.val10.i.i.i.i211 = insertvalue { i8*, i32 } %lpad.val.i.i.i.i210, i32 %sel.i.i.i.i209, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i.i.i177, { i8*, i32 } %lpad.val10.i.i.i.i211)
          to label %unreachable.i.i.i.i226 unwind label %lpad11.i.i.i.i217

lpad11.i.i.i.i217:                                ; preds = %ehcleanup.i.i.i.i212, %invoke.cont.i.i.i.i186
  %424 = landingpad { i8*, i32 }
          cleanup
  %425 = extractvalue { i8*, i32 } %424, 0
  store i8* %425, i8** %exn.slot12.i.i.i.i188, align 8
  %426 = extractvalue { i8*, i32 } %424, 1
  store i32 %426, i32* %ehselector.slot13.i.i.i.i189, align 4
  %exn15.i.i.i.i213 = load i8*, i8** %exn.slot12.i.i.i.i188, align 8
  %sel16.i.i.i.i214 = load i32, i32* %ehselector.slot13.i.i.i.i189, align 4
  %lpad.val17.i.i.i.i215 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i.i.i213, 0
  %lpad.val18.i.i.i.i216 = insertvalue { i8*, i32 } %lpad.val17.i.i.i.i215, i32 %sel16.i.i.i.i214, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %412, { i8*, i32 } %lpad.val18.i.i.i.i216)
          to label %unreachable.i.i.i.i226 unwind label %lpad19.i.i.i.i218

lpad19.i.i.i.i218:                                ; preds = %lpad11.i.i.i.i217, %det.cont.i.i.i.i199
  %427 = landingpad { i8*, i32 }
          cleanup
  %428 = extractvalue { i8*, i32 } %427, 0
  store i8* %428, i8** %exn.slot.i.i.i.i174, align 8
  %429 = extractvalue { i8*, i32 } %427, 1
  store i32 %429, i32* %ehselector.slot.i.i.i.i175, align 4
  br label %ehcleanup28.i.i.i.i220

lpad24.i.i.i.i219:                                ; preds = %invoke.cont22.i.i.i.i202
  %430 = landingpad { i8*, i32 }
          cleanup
  %431 = extractvalue { i8*, i32 } %430, 0
  store i8* %431, i8** %exn.slot.i.i.i.i174, align 8
  %432 = extractvalue { i8*, i32 } %430, 1
  store i32 %432, i32* %ehselector.slot.i.i.i.i175, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i.i176) #7
  br label %ehcleanup28.i.i.i.i220

ehcleanup28.i.i.i.i220:                           ; preds = %lpad24.i.i.i.i219, %lpad19.i.i.i.i218
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i.i.i184) #7
  br label %ehcleanup29.i.i.i.i225

ehcleanup29.i.i.i.i225:                           ; preds = %ehcleanup28.i.i.i.i220, %lpad.i.i.i.i205
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i.i.i182) #7
  %exn30.i.i.i.i221 = load i8*, i8** %exn.slot.i.i.i.i174, align 8
  %sel31.i.i.i.i222 = load i32, i32* %ehselector.slot.i.i.i.i175, align 4
  %lpad.val32.i.i.i.i223 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i.i.i221, 0
  %lpad.val33.i.i.i.i224 = insertvalue { i8*, i32 } %lpad.val32.i.i.i.i223, i32 %sel31.i.i.i.i222, 1
  br label %lpad4.body.i.i.i347

unreachable.i.i.i.i226:                           ; preds = %lpad11.i.i.i.i217, %ehcleanup.i.i.i.i212
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i.i.i229:           ; preds = %sync.continue.i.i.i.i204
  call void @llvm.stackrestore(i8* %savedstack.i.i.i180)
  %savedstack61.i.i.i227 = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i.i.i162, %class.object.1** %this.addr.i36.i.i.i164, align 8
  %this1.i40.i.i.i228 = load %class.object.1*, %class.object.1** %this.addr.i36.i.i.i164, align 8
  %433 = call token @llvm.taskframe.create()
  %a.i44.i.i.i230 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i.i228, i32 0, i32 0
  %a2.i45.i.i.i231 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i.i159, i32 0, i32 0
  detach within %syncreg.i37.i.i.i171, label %det.achd.i49.i.i.i235, label %det.cont.i52.i.i.i238 unwind label %lpad4.i58.i.i.i252

det.achd.i49.i.i.i235:                            ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i229
  %exn.slot.i46.i.i.i232 = alloca i8*
  %ehselector.slot.i47.i.i.i233 = alloca i32
  call void @llvm.taskframe.use(token %433)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i.i.i168, %class.object.2* dereferenceable(1) %a2.i45.i.i.i231)
  %call.i48.i.i.i234 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i.i.i230, %class.object.2* %agg.tmp.i41.i.i.i168)
          to label %invoke.cont.i50.i.i.i236 unwind label %lpad.i56.i.i.i247

invoke.cont.i50.i.i.i236:                         ; preds = %det.achd.i49.i.i.i235
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i.i168) #7
  reattach within %syncreg.i37.i.i.i171, label %det.cont.i52.i.i.i238

det.cont.i52.i.i.i238:                            ; preds = %invoke.cont.i50.i.i.i236, %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i229
  %b.i51.i.i.i237 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i.i159, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i.i.i167, %class.object.2* dereferenceable(1) %b.i51.i.i.i237)
          to label %.noexc63.i.i.i241 unwind label %lpad8.i.i.i348

.noexc63.i.i.i241:                                ; preds = %det.cont.i52.i.i.i238
  %b15.i.i.i.i239 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i.i228, i32 0, i32 1
  %call18.i.i.i.i240 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i.i.i239, %class.object.2* %agg.tmp14.i.i.i.i167)
          to label %invoke.cont17.i.i.i.i242 unwind label %lpad16.i.i.i.i254

invoke.cont17.i.i.i.i242:                         ; preds = %.noexc63.i.i.i241
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i.i167) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i.i.i247:                                ; preds = %det.achd.i49.i.i.i235
  %434 = landingpad { i8*, i32 }
          cleanup
  %435 = extractvalue { i8*, i32 } %434, 0
  store i8* %435, i8** %exn.slot.i46.i.i.i232, align 8
  %436 = extractvalue { i8*, i32 } %434, 1
  store i32 %436, i32* %ehselector.slot.i47.i.i.i233, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i.i168) #7
  %exn.i53.i.i.i243 = load i8*, i8** %exn.slot.i46.i.i.i232, align 8
  %sel.i54.i.i.i244 = load i32, i32* %ehselector.slot.i47.i.i.i233, align 4
  %lpad.val.i55.i.i.i245 = insertvalue { i8*, i32 } undef, i8* %exn.i53.i.i.i243, 0
  %lpad.val3.i.i.i.i246 = insertvalue { i8*, i32 } %lpad.val.i55.i.i.i245, i32 %sel.i54.i.i.i244, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i.i.i171, { i8*, i32 } %lpad.val3.i.i.i.i246)
          to label %unreachable.i60.i.i.i260 unwind label %lpad4.i58.i.i.i252

lpad4.i58.i.i.i252:                               ; preds = %lpad.i56.i.i.i247, %_ZN6objectILi1EEC2ERKS0_.exit.i.i.i229
  %437 = landingpad { i8*, i32 }
          cleanup
  %438 = extractvalue { i8*, i32 } %437, 0
  store i8* %438, i8** %exn.slot5.i42.i.i.i169, align 8
  %439 = extractvalue { i8*, i32 } %437, 1
  store i32 %439, i32* %ehselector.slot6.i43.i.i.i170, align 4
  %exn7.i.i.i.i248 = load i8*, i8** %exn.slot5.i42.i.i.i169, align 8
  %sel8.i.i.i.i249 = load i32, i32* %ehselector.slot6.i43.i.i.i170, align 4
  %lpad.val9.i.i.i.i250 = insertvalue { i8*, i32 } undef, i8* %exn7.i.i.i.i248, 0
  %lpad.val10.i57.i.i.i251 = insertvalue { i8*, i32 } %lpad.val9.i.i.i.i250, i32 %sel8.i.i.i.i249, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %433, { i8*, i32 } %lpad.val10.i57.i.i.i251)
          to label %unreachable.i60.i.i.i260 unwind label %lpad11.i59.i.i.i253

lpad11.i59.i.i.i253:                              ; preds = %lpad4.i58.i.i.i252
  %440 = landingpad { i8*, i32 }
          cleanup
  %441 = extractvalue { i8*, i32 } %440, 0
  store i8* %441, i8** %exn.slot12.i38.i.i.i165, align 8
  %442 = extractvalue { i8*, i32 } %440, 1
  store i32 %442, i32* %ehselector.slot13.i39.i.i.i166, align 4
  br label %eh.resume.i.i.i.i259

lpad16.i.i.i.i254:                                ; preds = %.noexc63.i.i.i241
  %443 = landingpad { i8*, i32 }
          cleanup
  %444 = extractvalue { i8*, i32 } %443, 0
  store i8* %444, i8** %exn.slot12.i38.i.i.i165, align 8
  %445 = extractvalue { i8*, i32 } %443, 1
  store i32 %445, i32* %ehselector.slot13.i39.i.i.i166, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i.i167) #7
  br label %eh.resume.i.i.i.i259

eh.resume.i.i.i.i259:                             ; preds = %lpad16.i.i.i.i254, %lpad11.i59.i.i.i253
  %exn19.i.i.i.i255 = load i8*, i8** %exn.slot12.i38.i.i.i165, align 8
  %sel20.i.i.i.i256 = load i32, i32* %ehselector.slot13.i39.i.i.i166, align 4
  %lpad.val21.i.i.i.i257 = insertvalue { i8*, i32 } undef, i8* %exn19.i.i.i.i255, 0
  %lpad.val22.i.i.i.i258 = insertvalue { i8*, i32 } %lpad.val21.i.i.i.i257, i32 %sel20.i.i.i.i256, 1
  br label %lpad8.body.i.i.i350

unreachable.i60.i.i.i260:                         ; preds = %lpad4.i58.i.i.i252, %lpad.i56.i.i.i247
  unreachable

det.cont.i.i.i265:                                ; preds = %invoke.cont.i.i.i158
  %446 = load %class.object.0*, %class.object.0** %other.addr.i.i.i143, align 8
  %b21.i.i.i261 = getelementptr inbounds %class.object.0, %class.object.0* %446, i32 0, i32 1
  %savedstack116.i.i.i262 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i.i.i146, %class.object.1** %this.addr.i65.i.i.i137, align 8
  store %class.object.1* %b21.i.i.i261, %class.object.1** %other.addr.i66.i.i.i138, align 8
  %this1.i71.i.i.i263 = load %class.object.1*, %class.object.1** %this.addr.i65.i.i.i137, align 8
  %a.i72.i.i.i264 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i.i263, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i.i.i264)
          to label %.noexc117.i.i.i267 unwind label %lpad19.i.i.i361

.noexc117.i.i.i267:                               ; preds = %det.cont.i.i.i265
  %b.i73.i.i.i266 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i.i263, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i.i.i266)
          to label %invoke.cont.i79.i.i.i268 unwind label %lpad.i93.i.i.i287

invoke.cont.i79.i.i.i268:                         ; preds = %.noexc117.i.i.i267
  %447 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i.i.i269 = alloca %class.object.2, align 1
  %exn.slot12.i75.i.i.i270 = alloca i8*
  %ehselector.slot13.i76.i.i.i271 = alloca i32
  %a2.i77.i.i.i272 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i.i263, i32 0, i32 0
  %448 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i.i138, align 8
  %a3.i78.i.i.i273 = getelementptr inbounds %class.object.1, %class.object.1* %448, i32 0, i32 0
  detach within %syncreg.i69.i.i.i148, label %det.achd.i82.i.i.i276, label %det.cont.i87.i.i.i281 unwind label %lpad11.i101.i.i.i299

det.achd.i82.i.i.i276:                            ; preds = %invoke.cont.i79.i.i.i268
  %exn.slot5.i80.i.i.i274 = alloca i8*
  %ehselector.slot6.i81.i.i.i275 = alloca i32
  call void @llvm.taskframe.use(token %447)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i.i.i269, %class.object.2* dereferenceable(1) %a3.i78.i.i.i273)
          to label %invoke.cont7.i84.i.i.i278 unwind label %lpad4.i94.i.i.i288

invoke.cont7.i84.i.i.i278:                        ; preds = %det.achd.i82.i.i.i276
  %call.i83.i.i.i277 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i.i.i272, %class.object.2* %agg.tmp.i74.i.i.i269)
          to label %invoke.cont9.i85.i.i.i279 unwind label %lpad8.i95.i.i.i289

invoke.cont9.i85.i.i.i279:                        ; preds = %invoke.cont7.i84.i.i.i278
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i.i269) #7
  reattach within %syncreg.i69.i.i.i148, label %det.cont.i87.i.i.i281

det.cont.i87.i.i.i281:                            ; preds = %invoke.cont9.i85.i.i.i279, %invoke.cont.i79.i.i.i268
  %449 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i.i138, align 8
  %b21.i86.i.i.i280 = getelementptr inbounds %class.object.1, %class.object.1* %449, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i.i.i141, %class.object.2* dereferenceable(1) %b21.i86.i.i.i280)
          to label %invoke.cont22.i90.i.i.i284 unwind label %lpad19.i106.i.i.i300

invoke.cont22.i90.i.i.i284:                       ; preds = %det.cont.i87.i.i.i281
  %b23.i88.i.i.i282 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i.i263, i32 0, i32 1
  %call26.i89.i.i.i283 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i.i.i282, %class.object.2* %agg.tmp20.i70.i.i.i141)
          to label %invoke.cont25.i91.i.i.i285 unwind label %lpad24.i107.i.i.i301

invoke.cont25.i91.i.i.i285:                       ; preds = %invoke.cont22.i90.i.i.i284
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i.i141) #7
  sync within %syncreg.i69.i.i.i148, label %sync.continue.i92.i.i.i286

sync.continue.i92.i.i.i286:                       ; preds = %invoke.cont25.i91.i.i.i285
  invoke void @llvm.sync.unwind(token %syncreg.i69.i.i.i148)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i312 unwind label %lpad19.i.i.i361

lpad.i93.i.i.i287:                                ; preds = %.noexc117.i.i.i267
  %450 = landingpad { i8*, i32 }
          cleanup
  %451 = extractvalue { i8*, i32 } %450, 0
  store i8* %451, i8** %exn.slot.i67.i.i.i139, align 8
  %452 = extractvalue { i8*, i32 } %450, 1
  store i32 %452, i32* %ehselector.slot.i68.i.i.i140, align 4
  br label %ehcleanup29.i109.i.i.i307

lpad4.i94.i.i.i288:                               ; preds = %det.achd.i82.i.i.i276
  %453 = landingpad { i8*, i32 }
          cleanup
  %454 = extractvalue { i8*, i32 } %453, 0
  store i8* %454, i8** %exn.slot5.i80.i.i.i274, align 8
  %455 = extractvalue { i8*, i32 } %453, 1
  store i32 %455, i32* %ehselector.slot6.i81.i.i.i275, align 4
  br label %ehcleanup.i100.i.i.i294

lpad8.i95.i.i.i289:                               ; preds = %invoke.cont7.i84.i.i.i278
  %456 = landingpad { i8*, i32 }
          cleanup
  %457 = extractvalue { i8*, i32 } %456, 0
  store i8* %457, i8** %exn.slot5.i80.i.i.i274, align 8
  %458 = extractvalue { i8*, i32 } %456, 1
  store i32 %458, i32* %ehselector.slot6.i81.i.i.i275, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i.i269) #7
  br label %ehcleanup.i100.i.i.i294

ehcleanup.i100.i.i.i294:                          ; preds = %lpad8.i95.i.i.i289, %lpad4.i94.i.i.i288
  %exn.i96.i.i.i290 = load i8*, i8** %exn.slot5.i80.i.i.i274, align 8
  %sel.i97.i.i.i291 = load i32, i32* %ehselector.slot6.i81.i.i.i275, align 4
  %lpad.val.i98.i.i.i292 = insertvalue { i8*, i32 } undef, i8* %exn.i96.i.i.i290, 0
  %lpad.val10.i99.i.i.i293 = insertvalue { i8*, i32 } %lpad.val.i98.i.i.i292, i32 %sel.i97.i.i.i291, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i.i.i148, { i8*, i32 } %lpad.val10.i99.i.i.i293)
          to label %unreachable.i115.i.i.i308 unwind label %lpad11.i101.i.i.i299

lpad11.i101.i.i.i299:                             ; preds = %ehcleanup.i100.i.i.i294, %invoke.cont.i79.i.i.i268
  %459 = landingpad { i8*, i32 }
          cleanup
  %460 = extractvalue { i8*, i32 } %459, 0
  store i8* %460, i8** %exn.slot12.i75.i.i.i270, align 8
  %461 = extractvalue { i8*, i32 } %459, 1
  store i32 %461, i32* %ehselector.slot13.i76.i.i.i271, align 4
  %exn15.i102.i.i.i295 = load i8*, i8** %exn.slot12.i75.i.i.i270, align 8
  %sel16.i103.i.i.i296 = load i32, i32* %ehselector.slot13.i76.i.i.i271, align 4
  %lpad.val17.i104.i.i.i297 = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i.i.i295, 0
  %lpad.val18.i105.i.i.i298 = insertvalue { i8*, i32 } %lpad.val17.i104.i.i.i297, i32 %sel16.i103.i.i.i296, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %447, { i8*, i32 } %lpad.val18.i105.i.i.i298)
          to label %unreachable.i115.i.i.i308 unwind label %lpad19.i106.i.i.i300

lpad19.i106.i.i.i300:                             ; preds = %lpad11.i101.i.i.i299, %det.cont.i87.i.i.i281
  %462 = landingpad { i8*, i32 }
          cleanup
  %463 = extractvalue { i8*, i32 } %462, 0
  store i8* %463, i8** %exn.slot.i67.i.i.i139, align 8
  %464 = extractvalue { i8*, i32 } %462, 1
  store i32 %464, i32* %ehselector.slot.i68.i.i.i140, align 4
  br label %ehcleanup28.i108.i.i.i302

lpad24.i107.i.i.i301:                             ; preds = %invoke.cont22.i90.i.i.i284
  %465 = landingpad { i8*, i32 }
          cleanup
  %466 = extractvalue { i8*, i32 } %465, 0
  store i8* %466, i8** %exn.slot.i67.i.i.i139, align 8
  %467 = extractvalue { i8*, i32 } %465, 1
  store i32 %467, i32* %ehselector.slot.i68.i.i.i140, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i.i141) #7
  br label %ehcleanup28.i108.i.i.i302

ehcleanup28.i108.i.i.i302:                        ; preds = %lpad24.i107.i.i.i301, %lpad19.i106.i.i.i300
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i.i.i266) #7
  br label %ehcleanup29.i109.i.i.i307

ehcleanup29.i109.i.i.i307:                        ; preds = %ehcleanup28.i108.i.i.i302, %lpad.i93.i.i.i287
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i.i.i264) #7
  %exn30.i110.i.i.i303 = load i8*, i8** %exn.slot.i67.i.i.i139, align 8
  %sel31.i111.i.i.i304 = load i32, i32* %ehselector.slot.i68.i.i.i140, align 4
  %lpad.val32.i112.i.i.i305 = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i.i.i303, 0
  %lpad.val33.i113.i.i.i306 = insertvalue { i8*, i32 } %lpad.val32.i112.i.i.i305, i32 %sel31.i111.i.i.i304, 1
  br label %lpad19.body.i.i.i363

unreachable.i115.i.i.i308:                        ; preds = %lpad11.i101.i.i.i299, %ehcleanup.i100.i.i.i294
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i312:        ; preds = %sync.continue.i92.i.i.i286
  call void @llvm.stackrestore(i8* %savedstack116.i.i.i262)
  %b23.i.i.i309 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i.i153, i32 0, i32 1
  %savedstack161.i.i.i310 = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i.i.i309, %class.object.1** %this.addr.i122.i.i.i130, align 8
  %this1.i127.i.i.i311 = load %class.object.1*, %class.object.1** %this.addr.i122.i.i.i130, align 8
  %468 = call token @llvm.taskframe.create()
  %a.i131.i.i.i313 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i.i311, i32 0, i32 0
  %a2.i132.i.i.i314 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i.i146, i32 0, i32 0
  detach within %syncreg.i123.i.i.i147, label %det.achd.i136.i.i.i318, label %det.cont.i141.i.i.i321 unwind label %lpad4.i152.i.i.i335

det.achd.i136.i.i.i318:                           ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i312
  %exn.slot.i133.i.i.i315 = alloca i8*
  %ehselector.slot.i134.i.i.i316 = alloca i32
  call void @llvm.taskframe.use(token %468)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i.i.i134, %class.object.2* dereferenceable(1) %a2.i132.i.i.i314)
  %call.i135.i.i.i317 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i.i.i313, %class.object.2* %agg.tmp.i128.i.i.i134)
          to label %invoke.cont.i137.i.i.i319 unwind label %lpad.i147.i.i.i330

invoke.cont.i137.i.i.i319:                        ; preds = %det.achd.i136.i.i.i318
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i.i134) #7
  reattach within %syncreg.i123.i.i.i147, label %det.cont.i141.i.i.i321

det.cont.i141.i.i.i321:                           ; preds = %invoke.cont.i137.i.i.i319, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i312
  %b.i138.i.i.i320 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i.i146, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i.i.i133, %class.object.2* dereferenceable(1) %b.i138.i.i.i320)
          to label %.noexc164.i.i.i324 unwind label %lpad24.i.i.i364

.noexc164.i.i.i324:                               ; preds = %det.cont.i141.i.i.i321
  %b15.i139.i.i.i322 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i.i311, i32 0, i32 1
  %call18.i140.i.i.i323 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i.i.i322, %class.object.2* %agg.tmp14.i126.i.i.i133)
          to label %invoke.cont17.i142.i.i.i325 unwind label %lpad16.i154.i.i.i337

invoke.cont17.i142.i.i.i325:                      ; preds = %.noexc164.i.i.i324
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i.i133) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i.i.i330:                               ; preds = %det.achd.i136.i.i.i318
  %469 = landingpad { i8*, i32 }
          cleanup
  %470 = extractvalue { i8*, i32 } %469, 0
  store i8* %470, i8** %exn.slot.i133.i.i.i315, align 8
  %471 = extractvalue { i8*, i32 } %469, 1
  store i32 %471, i32* %ehselector.slot.i134.i.i.i316, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i.i134) #7
  %exn.i143.i.i.i326 = load i8*, i8** %exn.slot.i133.i.i.i315, align 8
  %sel.i144.i.i.i327 = load i32, i32* %ehselector.slot.i134.i.i.i316, align 4
  %lpad.val.i145.i.i.i328 = insertvalue { i8*, i32 } undef, i8* %exn.i143.i.i.i326, 0
  %lpad.val3.i146.i.i.i329 = insertvalue { i8*, i32 } %lpad.val.i145.i.i.i328, i32 %sel.i144.i.i.i327, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i.i.i147, { i8*, i32 } %lpad.val3.i146.i.i.i329)
          to label %unreachable.i160.i.i.i343 unwind label %lpad4.i152.i.i.i335

lpad4.i152.i.i.i335:                              ; preds = %lpad.i147.i.i.i330, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i.i312
  %472 = landingpad { i8*, i32 }
          cleanup
  %473 = extractvalue { i8*, i32 } %472, 0
  store i8* %473, i8** %exn.slot5.i129.i.i.i135, align 8
  %474 = extractvalue { i8*, i32 } %472, 1
  store i32 %474, i32* %ehselector.slot6.i130.i.i.i136, align 4
  %exn7.i148.i.i.i331 = load i8*, i8** %exn.slot5.i129.i.i.i135, align 8
  %sel8.i149.i.i.i332 = load i32, i32* %ehselector.slot6.i130.i.i.i136, align 4
  %lpad.val9.i150.i.i.i333 = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i.i.i331, 0
  %lpad.val10.i151.i.i.i334 = insertvalue { i8*, i32 } %lpad.val9.i150.i.i.i333, i32 %sel8.i149.i.i.i332, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %468, { i8*, i32 } %lpad.val10.i151.i.i.i334)
          to label %unreachable.i160.i.i.i343 unwind label %lpad11.i153.i.i.i336

lpad11.i153.i.i.i336:                             ; preds = %lpad4.i152.i.i.i335
  %475 = landingpad { i8*, i32 }
          cleanup
  %476 = extractvalue { i8*, i32 } %475, 0
  store i8* %476, i8** %exn.slot12.i124.i.i.i131, align 8
  %477 = extractvalue { i8*, i32 } %475, 1
  store i32 %477, i32* %ehselector.slot13.i125.i.i.i132, align 4
  br label %eh.resume.i159.i.i.i342

lpad16.i154.i.i.i337:                             ; preds = %.noexc164.i.i.i324
  %478 = landingpad { i8*, i32 }
          cleanup
  %479 = extractvalue { i8*, i32 } %478, 0
  store i8* %479, i8** %exn.slot12.i124.i.i.i131, align 8
  %480 = extractvalue { i8*, i32 } %478, 1
  store i32 %480, i32* %ehselector.slot13.i125.i.i.i132, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i.i133) #7
  br label %eh.resume.i159.i.i.i342

eh.resume.i159.i.i.i342:                          ; preds = %lpad16.i154.i.i.i337, %lpad11.i153.i.i.i336
  %exn19.i155.i.i.i338 = load i8*, i8** %exn.slot12.i124.i.i.i131, align 8
  %sel20.i156.i.i.i339 = load i32, i32* %ehselector.slot13.i125.i.i.i132, align 4
  %lpad.val21.i157.i.i.i340 = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i.i.i338, 0
  %lpad.val22.i158.i.i.i341 = insertvalue { i8*, i32 } %lpad.val21.i157.i.i.i340, i32 %sel20.i156.i.i.i339, 1
  br label %lpad24.body.i.i.i366

unreachable.i160.i.i.i343:                        ; preds = %lpad4.i152.i.i.i335, %lpad.i147.i.i.i330
  unreachable

lpad.i.i.i344:                                    ; preds = %.noexc.i.i157
  %481 = landingpad { i8*, i32 }
          cleanup
  %482 = extractvalue { i8*, i32 } %481, 0
  store i8* %482, i8** %exn.slot.i.i.i144, align 8
  %483 = extractvalue { i8*, i32 } %481, 1
  store i32 %483, i32* %ehselector.slot.i.i.i145, align 4
  br label %ehcleanup29.i.i.i372

lpad4.i.i.i345:                                   ; preds = %sync.continue.i.i.i.i204, %det.achd.i.i.i183
  %484 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i.i.i347

lpad4.body.i.i.i347:                              ; preds = %lpad4.i.i.i345, %ehcleanup29.i.i.i.i225
  %eh.lpad-body.i.i.i346 = phi { i8*, i32 } [ %484, %lpad4.i.i.i345 ], [ %lpad.val33.i.i.i.i224, %ehcleanup29.i.i.i.i225 ]
  %485 = extractvalue { i8*, i32 } %eh.lpad-body.i.i.i346, 0
  store i8* %485, i8** %exn.slot5.i.i.i178, align 8
  %486 = extractvalue { i8*, i32 } %eh.lpad-body.i.i.i346, 1
  store i32 %486, i32* %ehselector.slot6.i.i.i179, align 4
  br label %ehcleanup.i.i.i355

lpad8.i.i.i348:                                   ; preds = %det.cont.i52.i.i.i238
  %487 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i.i.i350

lpad8.body.i.i.i350:                              ; preds = %lpad8.i.i.i348, %eh.resume.i.i.i.i259
  %eh.lpad-body64.i.i.i349 = phi { i8*, i32 } [ %487, %lpad8.i.i.i348 ], [ %lpad.val22.i.i.i.i258, %eh.resume.i.i.i.i259 ]
  %488 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i.i349, 0
  store i8* %488, i8** %exn.slot5.i.i.i178, align 8
  %489 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i.i349, 1
  store i32 %489, i32* %ehselector.slot6.i.i.i179, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i.i.i159) #7
  br label %ehcleanup.i.i.i355

ehcleanup.i.i.i355:                               ; preds = %lpad8.body.i.i.i350, %lpad4.body.i.i.i347
  %exn.i.i.i351 = load i8*, i8** %exn.slot5.i.i.i178, align 8
  %sel.i.i.i352 = load i32, i32* %ehselector.slot6.i.i.i179, align 4
  %lpad.val.i.i.i353 = insertvalue { i8*, i32 } undef, i8* %exn.i.i.i351, 0
  %lpad.val10.i.i.i354 = insertvalue { i8*, i32 } %lpad.val.i.i.i353, i32 %sel.i.i.i352, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i.i149, { i8*, i32 } %lpad.val10.i.i.i354)
          to label %unreachable.i.i.i373 unwind label %lpad11.i.i.i360

lpad11.i.i.i360:                                  ; preds = %ehcleanup.i.i.i355, %invoke.cont.i.i.i158
  %490 = landingpad { i8*, i32 }
          cleanup
  %491 = extractvalue { i8*, i32 } %490, 0
  store i8* %491, i8** %exn.slot12.i.i.i160, align 8
  %492 = extractvalue { i8*, i32 } %490, 1
  store i32 %492, i32* %ehselector.slot13.i.i.i161, align 4
  %exn15.i.i.i356 = load i8*, i8** %exn.slot12.i.i.i160, align 8
  %sel16.i.i.i357 = load i32, i32* %ehselector.slot13.i.i.i161, align 4
  %lpad.val17.i.i.i358 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i.i356, 0
  %lpad.val18.i.i.i359 = insertvalue { i8*, i32 } %lpad.val17.i.i.i358, i32 %sel16.i.i.i357, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %410, { i8*, i32 } %lpad.val18.i.i.i359)
          to label %unreachable.i.i.i373 unwind label %lpad19.i.i.i361

lpad19.i.i.i361:                                  ; preds = %lpad11.i.i.i360, %sync.continue.i92.i.i.i286, %det.cont.i.i.i265
  %493 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i.i.i363

lpad19.body.i.i.i363:                             ; preds = %lpad19.i.i.i361, %ehcleanup29.i109.i.i.i307
  %eh.lpad-body118.i.i.i362 = phi { i8*, i32 } [ %493, %lpad19.i.i.i361 ], [ %lpad.val33.i113.i.i.i306, %ehcleanup29.i109.i.i.i307 ]
  %494 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i.i362, 0
  store i8* %494, i8** %exn.slot.i.i.i144, align 8
  %495 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i.i362, 1
  store i32 %495, i32* %ehselector.slot.i.i.i145, align 4
  br label %ehcleanup28.i.i.i367

lpad24.i.i.i364:                                  ; preds = %det.cont.i141.i.i.i321
  %496 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i.i.i366

lpad24.body.i.i.i366:                             ; preds = %lpad24.i.i.i364, %eh.resume.i159.i.i.i342
  %eh.lpad-body165.i.i.i365 = phi { i8*, i32 } [ %496, %lpad24.i.i.i364 ], [ %lpad.val22.i158.i.i.i341, %eh.resume.i159.i.i.i342 ]
  %497 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i.i365, 0
  store i8* %497, i8** %exn.slot.i.i.i144, align 8
  %498 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i.i365, 1
  store i32 %498, i32* %ehselector.slot.i.i.i145, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i.i.i146) #7
  br label %ehcleanup28.i.i.i367

ehcleanup28.i.i.i367:                             ; preds = %lpad24.body.i.i.i366, %lpad19.body.i.i.i363
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i.i.i156) #7
  br label %ehcleanup29.i.i.i372

ehcleanup29.i.i.i372:                             ; preds = %ehcleanup28.i.i.i367, %lpad.i.i.i344
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i.i.i154) #7
  %exn30.i.i.i368 = load i8*, i8** %exn.slot.i.i.i144, align 8
  %sel31.i.i.i369 = load i32, i32* %ehselector.slot.i.i.i145, align 4
  %lpad.val32.i.i.i370 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i.i368, 0
  %lpad.val33.i.i.i371 = insertvalue { i8*, i32 } %lpad.val32.i.i.i370, i32 %sel31.i.i.i369, 1
  br label %lpad4.body.i.i604

unreachable.i.i.i373:                             ; preds = %lpad11.i.i.i360, %ehcleanup.i.i.i355
  unreachable

det.cont.i.i378:                                  ; preds = %invoke.cont.i.i124
  %499 = load %class.object*, %class.object** %other.addr.i.i102, align 8
  %b21.i.i374 = getelementptr inbounds %class.object, %class.object* %499, i32 0, i32 1
  %savedstack373.i.i375 = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp20.i.i105, %class.object.0** %this.addr.i147.i.i96, align 8
  store %class.object.0* %b21.i.i374, %class.object.0** %other.addr.i148.i.i97, align 8
  %this1.i153.i.i376 = load %class.object.0*, %class.object.0** %this.addr.i147.i.i96, align 8
  %a.i154.i.i377 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i.i376, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i154.i.i377)
          to label %.noexc374.i.i380 unwind label %lpad19.i.i610

.noexc374.i.i380:                                 ; preds = %det.cont.i.i378
  %b.i155.i.i379 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i.i376, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i155.i.i379)
          to label %invoke.cont.i156.i.i381 unwind label %lpad.i342.i.i567

invoke.cont.i156.i.i381:                          ; preds = %.noexc374.i.i380
  %500 = call token @llvm.taskframe.create()
  %agg.tmp.i157.i.i382 = alloca %class.object.1, align 1
  %exn.slot12.i158.i.i383 = alloca i8*
  %ehselector.slot13.i159.i.i384 = alloca i32
  %a2.i160.i.i385 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i.i376, i32 0, i32 0
  %501 = load %class.object.0*, %class.object.0** %other.addr.i148.i.i97, align 8
  %a3.i161.i.i386 = getelementptr inbounds %class.object.0, %class.object.0* %501, i32 0, i32 0
  detach within %syncreg.i151.i.i111, label %det.achd.i181.i.i406, label %det.cont.i263.i.i488 unwind label %lpad11.i354.i.i583

det.achd.i181.i.i406:                             ; preds = %invoke.cont.i156.i.i381
  %this.addr.i36.i162.i.i387 = alloca %class.object.1*, align 8
  %exn.slot12.i38.i163.i.i388 = alloca i8*
  %ehselector.slot13.i39.i164.i.i389 = alloca i32
  %agg.tmp14.i.i165.i.i390 = alloca %class.object.2, align 1
  %agg.tmp.i41.i166.i.i391 = alloca %class.object.2, align 1
  %exn.slot5.i42.i167.i.i392 = alloca i8*
  %ehselector.slot6.i43.i168.i.i393 = alloca i32
  %syncreg.i37.i169.i.i394 = call token @llvm.syncregion.start()
  %this.addr.i.i170.i.i395 = alloca %class.object.1*, align 8
  %other.addr.i.i171.i.i396 = alloca %class.object.1*, align 8
  %exn.slot.i.i172.i.i397 = alloca i8*
  %ehselector.slot.i.i173.i.i398 = alloca i32
  %agg.tmp20.i.i174.i.i399 = alloca %class.object.2, align 1
  %syncreg.i.i175.i.i400 = call token @llvm.syncregion.start()
  %exn.slot5.i176.i.i401 = alloca i8*
  %ehselector.slot6.i177.i.i402 = alloca i32
  call void @llvm.taskframe.use(token %500)
  %savedstack.i178.i.i403 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i157.i.i382, %class.object.1** %this.addr.i.i170.i.i395, align 8
  store %class.object.1* %a3.i161.i.i386, %class.object.1** %other.addr.i.i171.i.i396, align 8
  %this1.i.i179.i.i404 = load %class.object.1*, %class.object.1** %this.addr.i.i170.i.i395, align 8
  %a.i.i180.i.i405 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i.i404, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i180.i.i405)
          to label %.noexc.i183.i.i408 unwind label %lpad4.i343.i.i568

.noexc.i183.i.i408:                               ; preds = %det.achd.i181.i.i406
  %b.i.i182.i.i407 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i.i404, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i182.i.i407)
          to label %invoke.cont.i.i184.i.i409 unwind label %lpad.i.i203.i.i428

invoke.cont.i.i184.i.i409:                        ; preds = %.noexc.i183.i.i408
  %502 = call token @llvm.taskframe.create()
  %agg.tmp.i.i185.i.i410 = alloca %class.object.2, align 1
  %exn.slot12.i.i186.i.i411 = alloca i8*
  %ehselector.slot13.i.i187.i.i412 = alloca i32
  %a2.i.i188.i.i413 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i.i404, i32 0, i32 0
  %503 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i.i396, align 8
  %a3.i.i189.i.i414 = getelementptr inbounds %class.object.1, %class.object.1* %503, i32 0, i32 0
  detach within %syncreg.i.i175.i.i400, label %det.achd.i.i192.i.i417, label %det.cont.i.i197.i.i422 unwind label %lpad11.i.i215.i.i440

det.achd.i.i192.i.i417:                           ; preds = %invoke.cont.i.i184.i.i409
  %exn.slot5.i.i190.i.i415 = alloca i8*
  %ehselector.slot6.i.i191.i.i416 = alloca i32
  call void @llvm.taskframe.use(token %502)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i185.i.i410, %class.object.2* dereferenceable(1) %a3.i.i189.i.i414)
          to label %invoke.cont7.i.i194.i.i419 unwind label %lpad4.i.i204.i.i429

invoke.cont7.i.i194.i.i419:                       ; preds = %det.achd.i.i192.i.i417
  %call.i.i193.i.i418 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i188.i.i413, %class.object.2* %agg.tmp.i.i185.i.i410)
          to label %invoke.cont9.i.i195.i.i420 unwind label %lpad8.i.i205.i.i430

invoke.cont9.i.i195.i.i420:                       ; preds = %invoke.cont7.i.i194.i.i419
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i.i410) #7
  reattach within %syncreg.i.i175.i.i400, label %det.cont.i.i197.i.i422

det.cont.i.i197.i.i422:                           ; preds = %invoke.cont9.i.i195.i.i420, %invoke.cont.i.i184.i.i409
  %504 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i.i396, align 8
  %b21.i.i196.i.i421 = getelementptr inbounds %class.object.1, %class.object.1* %504, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i174.i.i399, %class.object.2* dereferenceable(1) %b21.i.i196.i.i421)
          to label %invoke.cont22.i.i200.i.i425 unwind label %lpad19.i.i216.i.i441

invoke.cont22.i.i200.i.i425:                      ; preds = %det.cont.i.i197.i.i422
  %b23.i.i198.i.i423 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i.i404, i32 0, i32 1
  %call26.i.i199.i.i424 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i198.i.i423, %class.object.2* %agg.tmp20.i.i174.i.i399)
          to label %invoke.cont25.i.i201.i.i426 unwind label %lpad24.i.i217.i.i442

invoke.cont25.i.i201.i.i426:                      ; preds = %invoke.cont22.i.i200.i.i425
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i.i399) #7
  sync within %syncreg.i.i175.i.i400, label %sync.continue.i.i202.i.i427

sync.continue.i.i202.i.i427:                      ; preds = %invoke.cont25.i.i201.i.i426
  invoke void @llvm.sync.unwind(token %syncreg.i.i175.i.i400)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i452 unwind label %lpad4.i343.i.i568

lpad.i.i203.i.i428:                               ; preds = %.noexc.i183.i.i408
  %505 = landingpad { i8*, i32 }
          cleanup
  %506 = extractvalue { i8*, i32 } %505, 0
  store i8* %506, i8** %exn.slot.i.i172.i.i397, align 8
  %507 = extractvalue { i8*, i32 } %505, 1
  store i32 %507, i32* %ehselector.slot.i.i173.i.i398, align 4
  br label %ehcleanup29.i.i223.i.i448

lpad4.i.i204.i.i429:                              ; preds = %det.achd.i.i192.i.i417
  %508 = landingpad { i8*, i32 }
          cleanup
  %509 = extractvalue { i8*, i32 } %508, 0
  store i8* %509, i8** %exn.slot5.i.i190.i.i415, align 8
  %510 = extractvalue { i8*, i32 } %508, 1
  store i32 %510, i32* %ehselector.slot6.i.i191.i.i416, align 4
  br label %ehcleanup.i.i210.i.i435

lpad8.i.i205.i.i430:                              ; preds = %invoke.cont7.i.i194.i.i419
  %511 = landingpad { i8*, i32 }
          cleanup
  %512 = extractvalue { i8*, i32 } %511, 0
  store i8* %512, i8** %exn.slot5.i.i190.i.i415, align 8
  %513 = extractvalue { i8*, i32 } %511, 1
  store i32 %513, i32* %ehselector.slot6.i.i191.i.i416, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i.i410) #7
  br label %ehcleanup.i.i210.i.i435

ehcleanup.i.i210.i.i435:                          ; preds = %lpad8.i.i205.i.i430, %lpad4.i.i204.i.i429
  %exn.i.i206.i.i431 = load i8*, i8** %exn.slot5.i.i190.i.i415, align 8
  %sel.i.i207.i.i432 = load i32, i32* %ehselector.slot6.i.i191.i.i416, align 4
  %lpad.val.i.i208.i.i433 = insertvalue { i8*, i32 } undef, i8* %exn.i.i206.i.i431, 0
  %lpad.val10.i.i209.i.i434 = insertvalue { i8*, i32 } %lpad.val.i.i208.i.i433, i32 %sel.i.i207.i.i432, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i175.i.i400, { i8*, i32 } %lpad.val10.i.i209.i.i434)
          to label %unreachable.i.i224.i.i449 unwind label %lpad11.i.i215.i.i440

lpad11.i.i215.i.i440:                             ; preds = %ehcleanup.i.i210.i.i435, %invoke.cont.i.i184.i.i409
  %514 = landingpad { i8*, i32 }
          cleanup
  %515 = extractvalue { i8*, i32 } %514, 0
  store i8* %515, i8** %exn.slot12.i.i186.i.i411, align 8
  %516 = extractvalue { i8*, i32 } %514, 1
  store i32 %516, i32* %ehselector.slot13.i.i187.i.i412, align 4
  %exn15.i.i211.i.i436 = load i8*, i8** %exn.slot12.i.i186.i.i411, align 8
  %sel16.i.i212.i.i437 = load i32, i32* %ehselector.slot13.i.i187.i.i412, align 4
  %lpad.val17.i.i213.i.i438 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i211.i.i436, 0
  %lpad.val18.i.i214.i.i439 = insertvalue { i8*, i32 } %lpad.val17.i.i213.i.i438, i32 %sel16.i.i212.i.i437, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %502, { i8*, i32 } %lpad.val18.i.i214.i.i439)
          to label %unreachable.i.i224.i.i449 unwind label %lpad19.i.i216.i.i441

lpad19.i.i216.i.i441:                             ; preds = %lpad11.i.i215.i.i440, %det.cont.i.i197.i.i422
  %517 = landingpad { i8*, i32 }
          cleanup
  %518 = extractvalue { i8*, i32 } %517, 0
  store i8* %518, i8** %exn.slot.i.i172.i.i397, align 8
  %519 = extractvalue { i8*, i32 } %517, 1
  store i32 %519, i32* %ehselector.slot.i.i173.i.i398, align 4
  br label %ehcleanup28.i.i218.i.i443

lpad24.i.i217.i.i442:                             ; preds = %invoke.cont22.i.i200.i.i425
  %520 = landingpad { i8*, i32 }
          cleanup
  %521 = extractvalue { i8*, i32 } %520, 0
  store i8* %521, i8** %exn.slot.i.i172.i.i397, align 8
  %522 = extractvalue { i8*, i32 } %520, 1
  store i32 %522, i32* %ehselector.slot.i.i173.i.i398, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i.i399) #7
  br label %ehcleanup28.i.i218.i.i443

ehcleanup28.i.i218.i.i443:                        ; preds = %lpad24.i.i217.i.i442, %lpad19.i.i216.i.i441
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i182.i.i407) #7
  br label %ehcleanup29.i.i223.i.i448

ehcleanup29.i.i223.i.i448:                        ; preds = %ehcleanup28.i.i218.i.i443, %lpad.i.i203.i.i428
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i180.i.i405) #7
  %exn30.i.i219.i.i444 = load i8*, i8** %exn.slot.i.i172.i.i397, align 8
  %sel31.i.i220.i.i445 = load i32, i32* %ehselector.slot.i.i173.i.i398, align 4
  %lpad.val32.i.i221.i.i446 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i219.i.i444, 0
  %lpad.val33.i.i222.i.i447 = insertvalue { i8*, i32 } %lpad.val32.i.i221.i.i446, i32 %sel31.i.i220.i.i445, 1
  br label %lpad4.body.i345.i.i570

unreachable.i.i224.i.i449:                        ; preds = %lpad11.i.i215.i.i440, %ehcleanup.i.i210.i.i435
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i452:        ; preds = %sync.continue.i.i202.i.i427
  call void @llvm.stackrestore(i8* %savedstack.i178.i.i403)
  %savedstack61.i226.i.i450 = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i160.i.i385, %class.object.1** %this.addr.i36.i162.i.i387, align 8
  %this1.i40.i227.i.i451 = load %class.object.1*, %class.object.1** %this.addr.i36.i162.i.i387, align 8
  %523 = call token @llvm.taskframe.create()
  %a.i44.i228.i.i453 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i.i451, i32 0, i32 0
  %a2.i45.i229.i.i454 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i.i382, i32 0, i32 0
  detach within %syncreg.i37.i169.i.i394, label %det.achd.i49.i233.i.i458, label %det.cont.i52.i236.i.i461 unwind label %lpad4.i58.i250.i.i475

det.achd.i49.i233.i.i458:                         ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i452
  %exn.slot.i46.i230.i.i455 = alloca i8*
  %ehselector.slot.i47.i231.i.i456 = alloca i32
  call void @llvm.taskframe.use(token %523)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i166.i.i391, %class.object.2* dereferenceable(1) %a2.i45.i229.i.i454)
  %call.i48.i232.i.i457 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i228.i.i453, %class.object.2* %agg.tmp.i41.i166.i.i391)
          to label %invoke.cont.i50.i234.i.i459 unwind label %lpad.i56.i245.i.i470

invoke.cont.i50.i234.i.i459:                      ; preds = %det.achd.i49.i233.i.i458
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i.i391) #7
  reattach within %syncreg.i37.i169.i.i394, label %det.cont.i52.i236.i.i461

det.cont.i52.i236.i.i461:                         ; preds = %invoke.cont.i50.i234.i.i459, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i452
  %b.i51.i235.i.i460 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i.i382, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i165.i.i390, %class.object.2* dereferenceable(1) %b.i51.i235.i.i460)
          to label %.noexc63.i239.i.i464 unwind label %lpad8.i346.i.i571

.noexc63.i239.i.i464:                             ; preds = %det.cont.i52.i236.i.i461
  %b15.i.i237.i.i462 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i.i451, i32 0, i32 1
  %call18.i.i238.i.i463 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i237.i.i462, %class.object.2* %agg.tmp14.i.i165.i.i390)
          to label %invoke.cont17.i.i240.i.i465 unwind label %lpad16.i.i252.i.i477

invoke.cont17.i.i240.i.i465:                      ; preds = %.noexc63.i239.i.i464
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i.i390) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i245.i.i470:                             ; preds = %det.achd.i49.i233.i.i458
  %524 = landingpad { i8*, i32 }
          cleanup
  %525 = extractvalue { i8*, i32 } %524, 0
  store i8* %525, i8** %exn.slot.i46.i230.i.i455, align 8
  %526 = extractvalue { i8*, i32 } %524, 1
  store i32 %526, i32* %ehselector.slot.i47.i231.i.i456, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i.i391) #7
  %exn.i53.i241.i.i466 = load i8*, i8** %exn.slot.i46.i230.i.i455, align 8
  %sel.i54.i242.i.i467 = load i32, i32* %ehselector.slot.i47.i231.i.i456, align 4
  %lpad.val.i55.i243.i.i468 = insertvalue { i8*, i32 } undef, i8* %exn.i53.i241.i.i466, 0
  %lpad.val3.i.i244.i.i469 = insertvalue { i8*, i32 } %lpad.val.i55.i243.i.i468, i32 %sel.i54.i242.i.i467, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i169.i.i394, { i8*, i32 } %lpad.val3.i.i244.i.i469)
          to label %unreachable.i60.i258.i.i483 unwind label %lpad4.i58.i250.i.i475

lpad4.i58.i250.i.i475:                            ; preds = %lpad.i56.i245.i.i470, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i.i452
  %527 = landingpad { i8*, i32 }
          cleanup
  %528 = extractvalue { i8*, i32 } %527, 0
  store i8* %528, i8** %exn.slot5.i42.i167.i.i392, align 8
  %529 = extractvalue { i8*, i32 } %527, 1
  store i32 %529, i32* %ehselector.slot6.i43.i168.i.i393, align 4
  %exn7.i.i246.i.i471 = load i8*, i8** %exn.slot5.i42.i167.i.i392, align 8
  %sel8.i.i247.i.i472 = load i32, i32* %ehselector.slot6.i43.i168.i.i393, align 4
  %lpad.val9.i.i248.i.i473 = insertvalue { i8*, i32 } undef, i8* %exn7.i.i246.i.i471, 0
  %lpad.val10.i57.i249.i.i474 = insertvalue { i8*, i32 } %lpad.val9.i.i248.i.i473, i32 %sel8.i.i247.i.i472, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %523, { i8*, i32 } %lpad.val10.i57.i249.i.i474)
          to label %unreachable.i60.i258.i.i483 unwind label %lpad11.i59.i251.i.i476

lpad11.i59.i251.i.i476:                           ; preds = %lpad4.i58.i250.i.i475
  %530 = landingpad { i8*, i32 }
          cleanup
  %531 = extractvalue { i8*, i32 } %530, 0
  store i8* %531, i8** %exn.slot12.i38.i163.i.i388, align 8
  %532 = extractvalue { i8*, i32 } %530, 1
  store i32 %532, i32* %ehselector.slot13.i39.i164.i.i389, align 4
  br label %eh.resume.i.i257.i.i482

lpad16.i.i252.i.i477:                             ; preds = %.noexc63.i239.i.i464
  %533 = landingpad { i8*, i32 }
          cleanup
  %534 = extractvalue { i8*, i32 } %533, 0
  store i8* %534, i8** %exn.slot12.i38.i163.i.i388, align 8
  %535 = extractvalue { i8*, i32 } %533, 1
  store i32 %535, i32* %ehselector.slot13.i39.i164.i.i389, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i.i390) #7
  br label %eh.resume.i.i257.i.i482

eh.resume.i.i257.i.i482:                          ; preds = %lpad16.i.i252.i.i477, %lpad11.i59.i251.i.i476
  %exn19.i.i253.i.i478 = load i8*, i8** %exn.slot12.i38.i163.i.i388, align 8
  %sel20.i.i254.i.i479 = load i32, i32* %ehselector.slot13.i39.i164.i.i389, align 4
  %lpad.val21.i.i255.i.i480 = insertvalue { i8*, i32 } undef, i8* %exn19.i.i253.i.i478, 0
  %lpad.val22.i.i256.i.i481 = insertvalue { i8*, i32 } %lpad.val21.i.i255.i.i480, i32 %sel20.i.i254.i.i479, 1
  br label %lpad8.body.i348.i.i573

unreachable.i60.i258.i.i483:                      ; preds = %lpad4.i58.i250.i.i475, %lpad.i56.i245.i.i470
  unreachable

det.cont.i263.i.i488:                             ; preds = %invoke.cont.i156.i.i381
  %536 = load %class.object.0*, %class.object.0** %other.addr.i148.i.i97, align 8
  %b21.i259.i.i484 = getelementptr inbounds %class.object.0, %class.object.0* %536, i32 0, i32 1
  %savedstack116.i260.i.i485 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i152.i.i100, %class.object.1** %this.addr.i65.i141.i.i91, align 8
  store %class.object.1* %b21.i259.i.i484, %class.object.1** %other.addr.i66.i142.i.i92, align 8
  %this1.i71.i261.i.i486 = load %class.object.1*, %class.object.1** %this.addr.i65.i141.i.i91, align 8
  %a.i72.i262.i.i487 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i.i486, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i262.i.i487)
          to label %.noexc117.i265.i.i490 unwind label %lpad19.i359.i.i584

.noexc117.i265.i.i490:                            ; preds = %det.cont.i263.i.i488
  %b.i73.i264.i.i489 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i.i486, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i264.i.i489)
          to label %invoke.cont.i79.i266.i.i491 unwind label %lpad.i93.i285.i.i510

invoke.cont.i79.i266.i.i491:                      ; preds = %.noexc117.i265.i.i490
  %537 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i267.i.i492 = alloca %class.object.2, align 1
  %exn.slot12.i75.i268.i.i493 = alloca i8*
  %ehselector.slot13.i76.i269.i.i494 = alloca i32
  %a2.i77.i270.i.i495 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i.i486, i32 0, i32 0
  %538 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i.i92, align 8
  %a3.i78.i271.i.i496 = getelementptr inbounds %class.object.1, %class.object.1* %538, i32 0, i32 0
  detach within %syncreg.i69.i146.i.i110, label %det.achd.i82.i274.i.i499, label %det.cont.i87.i279.i.i504 unwind label %lpad11.i101.i297.i.i522

det.achd.i82.i274.i.i499:                         ; preds = %invoke.cont.i79.i266.i.i491
  %exn.slot5.i80.i272.i.i497 = alloca i8*
  %ehselector.slot6.i81.i273.i.i498 = alloca i32
  call void @llvm.taskframe.use(token %537)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i267.i.i492, %class.object.2* dereferenceable(1) %a3.i78.i271.i.i496)
          to label %invoke.cont7.i84.i276.i.i501 unwind label %lpad4.i94.i286.i.i511

invoke.cont7.i84.i276.i.i501:                     ; preds = %det.achd.i82.i274.i.i499
  %call.i83.i275.i.i500 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i270.i.i495, %class.object.2* %agg.tmp.i74.i267.i.i492)
          to label %invoke.cont9.i85.i277.i.i502 unwind label %lpad8.i95.i287.i.i512

invoke.cont9.i85.i277.i.i502:                     ; preds = %invoke.cont7.i84.i276.i.i501
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i.i492) #7
  reattach within %syncreg.i69.i146.i.i110, label %det.cont.i87.i279.i.i504

det.cont.i87.i279.i.i504:                         ; preds = %invoke.cont9.i85.i277.i.i502, %invoke.cont.i79.i266.i.i491
  %539 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i.i92, align 8
  %b21.i86.i278.i.i503 = getelementptr inbounds %class.object.1, %class.object.1* %539, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i145.i.i95, %class.object.2* dereferenceable(1) %b21.i86.i278.i.i503)
          to label %invoke.cont22.i90.i282.i.i507 unwind label %lpad19.i106.i298.i.i523

invoke.cont22.i90.i282.i.i507:                    ; preds = %det.cont.i87.i279.i.i504
  %b23.i88.i280.i.i505 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i.i486, i32 0, i32 1
  %call26.i89.i281.i.i506 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i280.i.i505, %class.object.2* %agg.tmp20.i70.i145.i.i95)
          to label %invoke.cont25.i91.i283.i.i508 unwind label %lpad24.i107.i299.i.i524

invoke.cont25.i91.i283.i.i508:                    ; preds = %invoke.cont22.i90.i282.i.i507
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i.i95) #7
  sync within %syncreg.i69.i146.i.i110, label %sync.continue.i92.i284.i.i509

sync.continue.i92.i284.i.i509:                    ; preds = %invoke.cont25.i91.i283.i.i508
  invoke void @llvm.sync.unwind(token %syncreg.i69.i146.i.i110)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i535 unwind label %lpad19.i359.i.i584

lpad.i93.i285.i.i510:                             ; preds = %.noexc117.i265.i.i490
  %540 = landingpad { i8*, i32 }
          cleanup
  %541 = extractvalue { i8*, i32 } %540, 0
  store i8* %541, i8** %exn.slot.i67.i143.i.i93, align 8
  %542 = extractvalue { i8*, i32 } %540, 1
  store i32 %542, i32* %ehselector.slot.i68.i144.i.i94, align 4
  br label %ehcleanup29.i109.i305.i.i530

lpad4.i94.i286.i.i511:                            ; preds = %det.achd.i82.i274.i.i499
  %543 = landingpad { i8*, i32 }
          cleanup
  %544 = extractvalue { i8*, i32 } %543, 0
  store i8* %544, i8** %exn.slot5.i80.i272.i.i497, align 8
  %545 = extractvalue { i8*, i32 } %543, 1
  store i32 %545, i32* %ehselector.slot6.i81.i273.i.i498, align 4
  br label %ehcleanup.i100.i292.i.i517

lpad8.i95.i287.i.i512:                            ; preds = %invoke.cont7.i84.i276.i.i501
  %546 = landingpad { i8*, i32 }
          cleanup
  %547 = extractvalue { i8*, i32 } %546, 0
  store i8* %547, i8** %exn.slot5.i80.i272.i.i497, align 8
  %548 = extractvalue { i8*, i32 } %546, 1
  store i32 %548, i32* %ehselector.slot6.i81.i273.i.i498, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i.i492) #7
  br label %ehcleanup.i100.i292.i.i517

ehcleanup.i100.i292.i.i517:                       ; preds = %lpad8.i95.i287.i.i512, %lpad4.i94.i286.i.i511
  %exn.i96.i288.i.i513 = load i8*, i8** %exn.slot5.i80.i272.i.i497, align 8
  %sel.i97.i289.i.i514 = load i32, i32* %ehselector.slot6.i81.i273.i.i498, align 4
  %lpad.val.i98.i290.i.i515 = insertvalue { i8*, i32 } undef, i8* %exn.i96.i288.i.i513, 0
  %lpad.val10.i99.i291.i.i516 = insertvalue { i8*, i32 } %lpad.val.i98.i290.i.i515, i32 %sel.i97.i289.i.i514, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i146.i.i110, { i8*, i32 } %lpad.val10.i99.i291.i.i516)
          to label %unreachable.i115.i306.i.i531 unwind label %lpad11.i101.i297.i.i522

lpad11.i101.i297.i.i522:                          ; preds = %ehcleanup.i100.i292.i.i517, %invoke.cont.i79.i266.i.i491
  %549 = landingpad { i8*, i32 }
          cleanup
  %550 = extractvalue { i8*, i32 } %549, 0
  store i8* %550, i8** %exn.slot12.i75.i268.i.i493, align 8
  %551 = extractvalue { i8*, i32 } %549, 1
  store i32 %551, i32* %ehselector.slot13.i76.i269.i.i494, align 4
  %exn15.i102.i293.i.i518 = load i8*, i8** %exn.slot12.i75.i268.i.i493, align 8
  %sel16.i103.i294.i.i519 = load i32, i32* %ehselector.slot13.i76.i269.i.i494, align 4
  %lpad.val17.i104.i295.i.i520 = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i293.i.i518, 0
  %lpad.val18.i105.i296.i.i521 = insertvalue { i8*, i32 } %lpad.val17.i104.i295.i.i520, i32 %sel16.i103.i294.i.i519, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %537, { i8*, i32 } %lpad.val18.i105.i296.i.i521)
          to label %unreachable.i115.i306.i.i531 unwind label %lpad19.i106.i298.i.i523

lpad19.i106.i298.i.i523:                          ; preds = %lpad11.i101.i297.i.i522, %det.cont.i87.i279.i.i504
  %552 = landingpad { i8*, i32 }
          cleanup
  %553 = extractvalue { i8*, i32 } %552, 0
  store i8* %553, i8** %exn.slot.i67.i143.i.i93, align 8
  %554 = extractvalue { i8*, i32 } %552, 1
  store i32 %554, i32* %ehselector.slot.i68.i144.i.i94, align 4
  br label %ehcleanup28.i108.i300.i.i525

lpad24.i107.i299.i.i524:                          ; preds = %invoke.cont22.i90.i282.i.i507
  %555 = landingpad { i8*, i32 }
          cleanup
  %556 = extractvalue { i8*, i32 } %555, 0
  store i8* %556, i8** %exn.slot.i67.i143.i.i93, align 8
  %557 = extractvalue { i8*, i32 } %555, 1
  store i32 %557, i32* %ehselector.slot.i68.i144.i.i94, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i.i95) #7
  br label %ehcleanup28.i108.i300.i.i525

ehcleanup28.i108.i300.i.i525:                     ; preds = %lpad24.i107.i299.i.i524, %lpad19.i106.i298.i.i523
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i264.i.i489) #7
  br label %ehcleanup29.i109.i305.i.i530

ehcleanup29.i109.i305.i.i530:                     ; preds = %ehcleanup28.i108.i300.i.i525, %lpad.i93.i285.i.i510
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i262.i.i487) #7
  %exn30.i110.i301.i.i526 = load i8*, i8** %exn.slot.i67.i143.i.i93, align 8
  %sel31.i111.i302.i.i527 = load i32, i32* %ehselector.slot.i68.i144.i.i94, align 4
  %lpad.val32.i112.i303.i.i528 = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i301.i.i526, 0
  %lpad.val33.i113.i304.i.i529 = insertvalue { i8*, i32 } %lpad.val32.i112.i303.i.i528, i32 %sel31.i111.i302.i.i527, 1
  br label %lpad19.body.i361.i.i586

unreachable.i115.i306.i.i531:                     ; preds = %lpad11.i101.i297.i.i522, %ehcleanup.i100.i292.i.i517
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i535:     ; preds = %sync.continue.i92.i284.i.i509
  call void @llvm.stackrestore(i8* %savedstack116.i260.i.i485)
  %b23.i308.i.i532 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i.i376, i32 0, i32 1
  %savedstack161.i309.i.i533 = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i308.i.i532, %class.object.1** %this.addr.i122.i133.i.i84, align 8
  %this1.i127.i310.i.i534 = load %class.object.1*, %class.object.1** %this.addr.i122.i133.i.i84, align 8
  %558 = call token @llvm.taskframe.create()
  %a.i131.i311.i.i536 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i.i534, i32 0, i32 0
  %a2.i132.i312.i.i537 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i.i100, i32 0, i32 0
  detach within %syncreg.i123.i140.i.i109, label %det.achd.i136.i316.i.i541, label %det.cont.i141.i319.i.i544 unwind label %lpad4.i152.i333.i.i558

det.achd.i136.i316.i.i541:                        ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i535
  %exn.slot.i133.i313.i.i538 = alloca i8*
  %ehselector.slot.i134.i314.i.i539 = alloca i32
  call void @llvm.taskframe.use(token %558)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i137.i.i88, %class.object.2* dereferenceable(1) %a2.i132.i312.i.i537)
  %call.i135.i315.i.i540 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i311.i.i536, %class.object.2* %agg.tmp.i128.i137.i.i88)
          to label %invoke.cont.i137.i317.i.i542 unwind label %lpad.i147.i328.i.i553

invoke.cont.i137.i317.i.i542:                     ; preds = %det.achd.i136.i316.i.i541
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i.i88) #7
  reattach within %syncreg.i123.i140.i.i109, label %det.cont.i141.i319.i.i544

det.cont.i141.i319.i.i544:                        ; preds = %invoke.cont.i137.i317.i.i542, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i535
  %b.i138.i318.i.i543 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i.i100, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i136.i.i87, %class.object.2* dereferenceable(1) %b.i138.i318.i.i543)
          to label %.noexc164.i322.i.i547 unwind label %lpad24.i362.i.i587

.noexc164.i322.i.i547:                            ; preds = %det.cont.i141.i319.i.i544
  %b15.i139.i320.i.i545 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i.i534, i32 0, i32 1
  %call18.i140.i321.i.i546 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i320.i.i545, %class.object.2* %agg.tmp14.i126.i136.i.i87)
          to label %invoke.cont17.i142.i323.i.i548 unwind label %lpad16.i154.i335.i.i560

invoke.cont17.i142.i323.i.i548:                   ; preds = %.noexc164.i322.i.i547
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i.i87) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i328.i.i553:                            ; preds = %det.achd.i136.i316.i.i541
  %559 = landingpad { i8*, i32 }
          cleanup
  %560 = extractvalue { i8*, i32 } %559, 0
  store i8* %560, i8** %exn.slot.i133.i313.i.i538, align 8
  %561 = extractvalue { i8*, i32 } %559, 1
  store i32 %561, i32* %ehselector.slot.i134.i314.i.i539, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i.i88) #7
  %exn.i143.i324.i.i549 = load i8*, i8** %exn.slot.i133.i313.i.i538, align 8
  %sel.i144.i325.i.i550 = load i32, i32* %ehselector.slot.i134.i314.i.i539, align 4
  %lpad.val.i145.i326.i.i551 = insertvalue { i8*, i32 } undef, i8* %exn.i143.i324.i.i549, 0
  %lpad.val3.i146.i327.i.i552 = insertvalue { i8*, i32 } %lpad.val.i145.i326.i.i551, i32 %sel.i144.i325.i.i550, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i140.i.i109, { i8*, i32 } %lpad.val3.i146.i327.i.i552)
          to label %unreachable.i160.i341.i.i566 unwind label %lpad4.i152.i333.i.i558

lpad4.i152.i333.i.i558:                           ; preds = %lpad.i147.i328.i.i553, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i.i535
  %562 = landingpad { i8*, i32 }
          cleanup
  %563 = extractvalue { i8*, i32 } %562, 0
  store i8* %563, i8** %exn.slot5.i129.i138.i.i89, align 8
  %564 = extractvalue { i8*, i32 } %562, 1
  store i32 %564, i32* %ehselector.slot6.i130.i139.i.i90, align 4
  %exn7.i148.i329.i.i554 = load i8*, i8** %exn.slot5.i129.i138.i.i89, align 8
  %sel8.i149.i330.i.i555 = load i32, i32* %ehselector.slot6.i130.i139.i.i90, align 4
  %lpad.val9.i150.i331.i.i556 = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i329.i.i554, 0
  %lpad.val10.i151.i332.i.i557 = insertvalue { i8*, i32 } %lpad.val9.i150.i331.i.i556, i32 %sel8.i149.i330.i.i555, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %558, { i8*, i32 } %lpad.val10.i151.i332.i.i557)
          to label %unreachable.i160.i341.i.i566 unwind label %lpad11.i153.i334.i.i559

lpad11.i153.i334.i.i559:                          ; preds = %lpad4.i152.i333.i.i558
  %565 = landingpad { i8*, i32 }
          cleanup
  %566 = extractvalue { i8*, i32 } %565, 0
  store i8* %566, i8** %exn.slot12.i124.i134.i.i85, align 8
  %567 = extractvalue { i8*, i32 } %565, 1
  store i32 %567, i32* %ehselector.slot13.i125.i135.i.i86, align 4
  br label %eh.resume.i159.i340.i.i565

lpad16.i154.i335.i.i560:                          ; preds = %.noexc164.i322.i.i547
  %568 = landingpad { i8*, i32 }
          cleanup
  %569 = extractvalue { i8*, i32 } %568, 0
  store i8* %569, i8** %exn.slot12.i124.i134.i.i85, align 8
  %570 = extractvalue { i8*, i32 } %568, 1
  store i32 %570, i32* %ehselector.slot13.i125.i135.i.i86, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i.i87) #7
  br label %eh.resume.i159.i340.i.i565

eh.resume.i159.i340.i.i565:                       ; preds = %lpad16.i154.i335.i.i560, %lpad11.i153.i334.i.i559
  %exn19.i155.i336.i.i561 = load i8*, i8** %exn.slot12.i124.i134.i.i85, align 8
  %sel20.i156.i337.i.i562 = load i32, i32* %ehselector.slot13.i125.i135.i.i86, align 4
  %lpad.val21.i157.i338.i.i563 = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i336.i.i561, 0
  %lpad.val22.i158.i339.i.i564 = insertvalue { i8*, i32 } %lpad.val21.i157.i338.i.i563, i32 %sel20.i156.i337.i.i562, 1
  br label %lpad24.body.i364.i.i589

unreachable.i160.i341.i.i566:                     ; preds = %lpad4.i152.i333.i.i558, %lpad.i147.i328.i.i553
  unreachable

lpad.i342.i.i567:                                 ; preds = %.noexc374.i.i380
  %571 = landingpad { i8*, i32 }
          cleanup
  %572 = extractvalue { i8*, i32 } %571, 0
  store i8* %572, i8** %exn.slot.i149.i.i98, align 8
  %573 = extractvalue { i8*, i32 } %571, 1
  store i32 %573, i32* %ehselector.slot.i150.i.i99, align 4
  br label %ehcleanup29.i366.i.i595

lpad4.i343.i.i568:                                ; preds = %sync.continue.i.i202.i.i427, %det.achd.i181.i.i406
  %574 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i345.i.i570

lpad4.body.i345.i.i570:                           ; preds = %lpad4.i343.i.i568, %ehcleanup29.i.i223.i.i448
  %eh.lpad-body.i344.i.i569 = phi { i8*, i32 } [ %574, %lpad4.i343.i.i568 ], [ %lpad.val33.i.i222.i.i447, %ehcleanup29.i.i223.i.i448 ]
  %575 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i.i569, 0
  store i8* %575, i8** %exn.slot5.i176.i.i401, align 8
  %576 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i.i569, 1
  store i32 %576, i32* %ehselector.slot6.i177.i.i402, align 4
  br label %ehcleanup.i353.i.i578

lpad8.i346.i.i571:                                ; preds = %det.cont.i52.i236.i.i461
  %577 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i348.i.i573

lpad8.body.i348.i.i573:                           ; preds = %lpad8.i346.i.i571, %eh.resume.i.i257.i.i482
  %eh.lpad-body64.i347.i.i572 = phi { i8*, i32 } [ %577, %lpad8.i346.i.i571 ], [ %lpad.val22.i.i256.i.i481, %eh.resume.i.i257.i.i482 ]
  %578 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i.i572, 0
  store i8* %578, i8** %exn.slot5.i176.i.i401, align 8
  %579 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i.i572, 1
  store i32 %579, i32* %ehselector.slot6.i177.i.i402, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i157.i.i382) #7
  br label %ehcleanup.i353.i.i578

ehcleanup.i353.i.i578:                            ; preds = %lpad8.body.i348.i.i573, %lpad4.body.i345.i.i570
  %exn.i349.i.i574 = load i8*, i8** %exn.slot5.i176.i.i401, align 8
  %sel.i350.i.i575 = load i32, i32* %ehselector.slot6.i177.i.i402, align 4
  %lpad.val.i351.i.i576 = insertvalue { i8*, i32 } undef, i8* %exn.i349.i.i574, 0
  %lpad.val10.i352.i.i577 = insertvalue { i8*, i32 } %lpad.val.i351.i.i576, i32 %sel.i350.i.i575, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i151.i.i111, { i8*, i32 } %lpad.val10.i352.i.i577)
          to label %unreachable.i372.i.i596 unwind label %lpad11.i354.i.i583

lpad11.i354.i.i583:                               ; preds = %ehcleanup.i353.i.i578, %invoke.cont.i156.i.i381
  %580 = landingpad { i8*, i32 }
          cleanup
  %581 = extractvalue { i8*, i32 } %580, 0
  store i8* %581, i8** %exn.slot12.i158.i.i383, align 8
  %582 = extractvalue { i8*, i32 } %580, 1
  store i32 %582, i32* %ehselector.slot13.i159.i.i384, align 4
  %exn15.i355.i.i579 = load i8*, i8** %exn.slot12.i158.i.i383, align 8
  %sel16.i356.i.i580 = load i32, i32* %ehselector.slot13.i159.i.i384, align 4
  %lpad.val17.i357.i.i581 = insertvalue { i8*, i32 } undef, i8* %exn15.i355.i.i579, 0
  %lpad.val18.i358.i.i582 = insertvalue { i8*, i32 } %lpad.val17.i357.i.i581, i32 %sel16.i356.i.i580, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %500, { i8*, i32 } %lpad.val18.i358.i.i582)
          to label %unreachable.i372.i.i596 unwind label %lpad19.i359.i.i584

lpad19.i359.i.i584:                               ; preds = %lpad11.i354.i.i583, %sync.continue.i92.i284.i.i509, %det.cont.i263.i.i488
  %583 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i361.i.i586

lpad19.body.i361.i.i586:                          ; preds = %lpad19.i359.i.i584, %ehcleanup29.i109.i305.i.i530
  %eh.lpad-body118.i360.i.i585 = phi { i8*, i32 } [ %583, %lpad19.i359.i.i584 ], [ %lpad.val33.i113.i304.i.i529, %ehcleanup29.i109.i305.i.i530 ]
  %584 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i.i585, 0
  store i8* %584, i8** %exn.slot.i149.i.i98, align 8
  %585 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i.i585, 1
  store i32 %585, i32* %ehselector.slot.i150.i.i99, align 4
  br label %ehcleanup28.i365.i.i590

lpad24.i362.i.i587:                               ; preds = %det.cont.i141.i319.i.i544
  %586 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i364.i.i589

lpad24.body.i364.i.i589:                          ; preds = %lpad24.i362.i.i587, %eh.resume.i159.i340.i.i565
  %eh.lpad-body165.i363.i.i588 = phi { i8*, i32 } [ %586, %lpad24.i362.i.i587 ], [ %lpad.val22.i158.i339.i.i564, %eh.resume.i159.i340.i.i565 ]
  %587 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i.i588, 0
  store i8* %587, i8** %exn.slot.i149.i.i98, align 8
  %588 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i.i588, 1
  store i32 %588, i32* %ehselector.slot.i150.i.i99, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i152.i.i100) #7
  br label %ehcleanup28.i365.i.i590

ehcleanup28.i365.i.i590:                          ; preds = %lpad24.body.i364.i.i589, %lpad19.body.i361.i.i586
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i155.i.i379) #7
  br label %ehcleanup29.i366.i.i595

ehcleanup29.i366.i.i595:                          ; preds = %ehcleanup28.i365.i.i590, %lpad.i342.i.i567
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i154.i.i377) #7
  %exn30.i367.i.i591 = load i8*, i8** %exn.slot.i149.i.i98, align 8
  %sel31.i368.i.i592 = load i32, i32* %ehselector.slot.i150.i.i99, align 4
  %lpad.val32.i369.i.i593 = insertvalue { i8*, i32 } undef, i8* %exn30.i367.i.i591, 0
  %lpad.val33.i370.i.i594 = insertvalue { i8*, i32 } %lpad.val32.i369.i.i593, i32 %sel31.i368.i.i592, 1
  br label %lpad19.body.i.i612

unreachable.i372.i.i596:                          ; preds = %lpad11.i354.i.i583, %ehcleanup.i353.i.i578
  unreachable

lpad.i.i597:                                      ; preds = %.noexc.i123
  %589 = landingpad { i8*, i32 }
          cleanup
  %590 = extractvalue { i8*, i32 } %589, 0
  store i8* %590, i8** %exn.slot.i.i103, align 8
  %591 = extractvalue { i8*, i32 } %589, 1
  store i32 %591, i32* %ehselector.slot.i.i104, align 4
  br label %ehcleanup29.i.i617

lpad4.i.i598:                                     ; preds = %det.achd.i.i155
  %592 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i.i604

lpad4.body.i.i604:                                ; preds = %lpad4.i.i598, %ehcleanup29.i.i.i372
  %eh.lpad-body.i.i599 = phi { i8*, i32 } [ %592, %lpad4.i.i598 ], [ %lpad.val33.i.i.i371, %ehcleanup29.i.i.i372 ]
  %593 = extractvalue { i8*, i32 } %eh.lpad-body.i.i599, 0
  store i8* %593, i8** %exn.slot5.i.i150, align 8
  %594 = extractvalue { i8*, i32 } %eh.lpad-body.i.i599, 1
  store i32 %594, i32* %ehselector.slot6.i.i151, align 4
  %exn.i.i600 = load i8*, i8** %exn.slot5.i.i150, align 8
  %sel.i.i601 = load i32, i32* %ehselector.slot6.i.i151, align 4
  %lpad.val.i.i602 = insertvalue { i8*, i32 } undef, i8* %exn.i.i600, 0
  %lpad.val10.i.i603 = insertvalue { i8*, i32 } %lpad.val.i.i602, i32 %sel.i.i601, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i115, { i8*, i32 } %lpad.val10.i.i603)
          to label %unreachable.i.i618 unwind label %lpad11.i.i609

lpad11.i.i609:                                    ; preds = %lpad4.body.i.i604, %invoke.cont.i.i124
  %595 = landingpad { i8*, i32 }
          cleanup
  %596 = extractvalue { i8*, i32 } %595, 0
  store i8* %596, i8** %exn.slot12.i.i126, align 8
  %597 = extractvalue { i8*, i32 } %595, 1
  store i32 %597, i32* %ehselector.slot13.i.i127, align 4
  %exn15.i.i605 = load i8*, i8** %exn.slot12.i.i126, align 8
  %sel16.i.i606 = load i32, i32* %ehselector.slot13.i.i127, align 4
  %lpad.val17.i.i607 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i605, 0
  %lpad.val18.i.i608 = insertvalue { i8*, i32 } %lpad.val17.i.i607, i32 %sel16.i.i606, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %408, { i8*, i32 } %lpad.val18.i.i608)
          to label %unreachable.i.i618 unwind label %lpad19.i.i610

lpad19.i.i610:                                    ; preds = %lpad11.i.i609, %det.cont.i.i378
  %598 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i.i612

lpad19.body.i.i612:                               ; preds = %lpad19.i.i610, %ehcleanup29.i366.i.i595
  %eh.lpad-body375.i.i611 = phi { i8*, i32 } [ %598, %lpad19.i.i610 ], [ %lpad.val33.i370.i.i594, %ehcleanup29.i366.i.i595 ]
  %599 = extractvalue { i8*, i32 } %eh.lpad-body375.i.i611, 0
  store i8* %599, i8** %exn.slot.i.i103, align 8
  %600 = extractvalue { i8*, i32 } %eh.lpad-body375.i.i611, 1
  store i32 %600, i32* %ehselector.slot.i.i104, align 4
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %b.i.i122) #7
  br label %ehcleanup29.i.i617

ehcleanup29.i.i617:                               ; preds = %lpad19.body.i.i612, %lpad.i.i597
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %a.i.i120) #7
  %exn30.i.i613 = load i8*, i8** %exn.slot.i.i103, align 8
  %sel31.i.i614 = load i32, i32* %ehselector.slot.i.i104, align 4
  %lpad.val32.i.i615 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i613, 0
  %lpad.val33.i.i616 = insertvalue { i8*, i32 } %lpad.val32.i.i615, i32 %sel31.i.i614, 1
  br label %lpad4.body.i1124

unreachable.i.i618:                               ; preds = %lpad11.i.i609, %lpad4.body.i.i604
  unreachable

det.cont.i623:                                    ; preds = %invoke.cont.i78
  %601 = load %class.object.3*, %class.object.3** %other.addr.i70, align 8
  %b21.i619 = getelementptr inbounds %class.object.3, %class.object.3* %601, i32 0, i32 1
  %savedstack832.i620 = call i8* @llvm.stacksave()
  store %class.object* %agg.tmp20.i74, %class.object** %this.addr.i328.i44, align 8
  store %class.object* %b21.i619, %class.object** %other.addr.i329.i45, align 8
  %this1.i334.i621 = load %class.object*, %class.object** %this.addr.i328.i44, align 8
  %a.i335.i622 = getelementptr inbounds %class.object, %class.object* %this1.i334.i621, i32 0, i32 0
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %a.i335.i622)
          to label %.noexc833.i625 unwind label %lpad19.i1134

.noexc833.i625:                                   ; preds = %det.cont.i623
  %b.i336.i624 = getelementptr inbounds %class.object, %class.object* %this1.i334.i621, i32 0, i32 1
  invoke void @_ZN6objectILi2EEC1Ev(%class.object.0* %b.i336.i624)
          to label %invoke.cont.i337.i626 unwind label %lpad.i810.i1099

invoke.cont.i337.i626:                            ; preds = %.noexc833.i625
  %602 = call token @llvm.taskframe.create()
  %agg.tmp.i338.i627 = alloca %class.object.0, align 1
  %exn.slot12.i339.i628 = alloca i8*
  %ehselector.slot13.i340.i629 = alloca i32
  %a2.i341.i630 = getelementptr inbounds %class.object, %class.object* %this1.i334.i621, i32 0, i32 0
  %603 = load %class.object*, %class.object** %other.addr.i329.i45, align 8
  %a3.i342.i631 = getelementptr inbounds %class.object, %class.object* %603, i32 0, i32 0
  detach within %syncreg.i332.i58, label %det.achd.i368.i657, label %det.cont.i591.i880 unwind label %lpad11.i818.i1111

det.achd.i368.i657:                               ; preds = %invoke.cont.i337.i626
  %this.addr.i122.i.i343.i632 = alloca %class.object.1*, align 8
  %exn.slot12.i124.i.i344.i633 = alloca i8*
  %ehselector.slot13.i125.i.i345.i634 = alloca i32
  %agg.tmp14.i126.i.i346.i635 = alloca %class.object.2, align 1
  %agg.tmp.i128.i.i347.i636 = alloca %class.object.2, align 1
  %exn.slot5.i129.i.i348.i637 = alloca i8*
  %ehselector.slot6.i130.i.i349.i638 = alloca i32
  %this.addr.i65.i.i350.i639 = alloca %class.object.1*, align 8
  %other.addr.i66.i.i351.i640 = alloca %class.object.1*, align 8
  %exn.slot.i67.i.i352.i641 = alloca i8*
  %ehselector.slot.i68.i.i353.i642 = alloca i32
  %agg.tmp20.i70.i.i354.i643 = alloca %class.object.2, align 1
  %this.addr.i.i355.i644 = alloca %class.object.0*, align 8
  %other.addr.i.i356.i645 = alloca %class.object.0*, align 8
  %exn.slot.i.i357.i646 = alloca i8*
  %ehselector.slot.i.i358.i647 = alloca i32
  %agg.tmp20.i.i359.i648 = alloca %class.object.1, align 1
  %syncreg.i123.i.i360.i649 = call token @llvm.syncregion.start()
  %syncreg.i69.i.i361.i650 = call token @llvm.syncregion.start()
  %syncreg.i.i362.i651 = call token @llvm.syncregion.start()
  %exn.slot5.i363.i652 = alloca i8*
  %ehselector.slot6.i364.i653 = alloca i32
  call void @llvm.taskframe.use(token %602)
  %savedstack.i365.i654 = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp.i338.i627, %class.object.0** %this.addr.i.i355.i644, align 8
  store %class.object.0* %a3.i342.i631, %class.object.0** %other.addr.i.i356.i645, align 8
  %this1.i.i366.i655 = load %class.object.0*, %class.object.0** %this.addr.i.i355.i644, align 8
  %a.i.i367.i656 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i366.i655, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i.i367.i656)
          to label %.noexc.i370.i659 unwind label %lpad4.i811.i1100

.noexc.i370.i659:                                 ; preds = %det.achd.i368.i657
  %b.i.i369.i658 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i366.i655, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i.i369.i658)
          to label %invoke.cont.i.i371.i660 unwind label %lpad.i.i557.i846

invoke.cont.i.i371.i660:                          ; preds = %.noexc.i370.i659
  %604 = call token @llvm.taskframe.create()
  %agg.tmp.i.i372.i661 = alloca %class.object.1, align 1
  %exn.slot12.i.i373.i662 = alloca i8*
  %ehselector.slot13.i.i374.i663 = alloca i32
  %a2.i.i375.i664 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i366.i655, i32 0, i32 0
  %605 = load %class.object.0*, %class.object.0** %other.addr.i.i356.i645, align 8
  %a3.i.i376.i665 = getelementptr inbounds %class.object.0, %class.object.0* %605, i32 0, i32 0
  detach within %syncreg.i.i362.i651, label %det.achd.i.i396.i685, label %det.cont.i.i478.i767 unwind label %lpad11.i.i573.i862

det.achd.i.i396.i685:                             ; preds = %invoke.cont.i.i371.i660
  %this.addr.i36.i.i377.i666 = alloca %class.object.1*, align 8
  %exn.slot12.i38.i.i378.i667 = alloca i8*
  %ehselector.slot13.i39.i.i379.i668 = alloca i32
  %agg.tmp14.i.i.i380.i669 = alloca %class.object.2, align 1
  %agg.tmp.i41.i.i381.i670 = alloca %class.object.2, align 1
  %exn.slot5.i42.i.i382.i671 = alloca i8*
  %ehselector.slot6.i43.i.i383.i672 = alloca i32
  %syncreg.i37.i.i384.i673 = call token @llvm.syncregion.start()
  %this.addr.i.i.i385.i674 = alloca %class.object.1*, align 8
  %other.addr.i.i.i386.i675 = alloca %class.object.1*, align 8
  %exn.slot.i.i.i387.i676 = alloca i8*
  %ehselector.slot.i.i.i388.i677 = alloca i32
  %agg.tmp20.i.i.i389.i678 = alloca %class.object.2, align 1
  %syncreg.i.i.i390.i679 = call token @llvm.syncregion.start()
  %exn.slot5.i.i391.i680 = alloca i8*
  %ehselector.slot6.i.i392.i681 = alloca i32
  call void @llvm.taskframe.use(token %604)
  %savedstack.i.i393.i682 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i.i372.i661, %class.object.1** %this.addr.i.i.i385.i674, align 8
  store %class.object.1* %a3.i.i376.i665, %class.object.1** %other.addr.i.i.i386.i675, align 8
  %this1.i.i.i394.i683 = load %class.object.1*, %class.object.1** %this.addr.i.i.i385.i674, align 8
  %a.i.i.i395.i684 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i394.i683, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i.i395.i684)
          to label %.noexc.i.i398.i687 unwind label %lpad4.i.i558.i847

.noexc.i.i398.i687:                               ; preds = %det.achd.i.i396.i685
  %b.i.i.i397.i686 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i394.i683, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i.i397.i686)
          to label %invoke.cont.i.i.i399.i688 unwind label %lpad.i.i.i418.i707

invoke.cont.i.i.i399.i688:                        ; preds = %.noexc.i.i398.i687
  %606 = call token @llvm.taskframe.create()
  %agg.tmp.i.i.i400.i689 = alloca %class.object.2, align 1
  %exn.slot12.i.i.i401.i690 = alloca i8*
  %ehselector.slot13.i.i.i402.i691 = alloca i32
  %a2.i.i.i403.i692 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i394.i683, i32 0, i32 0
  %607 = load %class.object.1*, %class.object.1** %other.addr.i.i.i386.i675, align 8
  %a3.i.i.i404.i693 = getelementptr inbounds %class.object.1, %class.object.1* %607, i32 0, i32 0
  detach within %syncreg.i.i.i390.i679, label %det.achd.i.i.i407.i696, label %det.cont.i.i.i412.i701 unwind label %lpad11.i.i.i430.i719

det.achd.i.i.i407.i696:                           ; preds = %invoke.cont.i.i.i399.i688
  %exn.slot5.i.i.i405.i694 = alloca i8*
  %ehselector.slot6.i.i.i406.i695 = alloca i32
  call void @llvm.taskframe.use(token %606)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i.i400.i689, %class.object.2* dereferenceable(1) %a3.i.i.i404.i693)
          to label %invoke.cont7.i.i.i409.i698 unwind label %lpad4.i.i.i419.i708

invoke.cont7.i.i.i409.i698:                       ; preds = %det.achd.i.i.i407.i696
  %call.i.i.i408.i697 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i.i403.i692, %class.object.2* %agg.tmp.i.i.i400.i689)
          to label %invoke.cont9.i.i.i410.i699 unwind label %lpad8.i.i.i420.i709

invoke.cont9.i.i.i410.i699:                       ; preds = %invoke.cont7.i.i.i409.i698
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i400.i689) #7
  reattach within %syncreg.i.i.i390.i679, label %det.cont.i.i.i412.i701

det.cont.i.i.i412.i701:                           ; preds = %invoke.cont9.i.i.i410.i699, %invoke.cont.i.i.i399.i688
  %608 = load %class.object.1*, %class.object.1** %other.addr.i.i.i386.i675, align 8
  %b21.i.i.i411.i700 = getelementptr inbounds %class.object.1, %class.object.1* %608, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i.i389.i678, %class.object.2* dereferenceable(1) %b21.i.i.i411.i700)
          to label %invoke.cont22.i.i.i415.i704 unwind label %lpad19.i.i.i431.i720

invoke.cont22.i.i.i415.i704:                      ; preds = %det.cont.i.i.i412.i701
  %b23.i.i.i413.i702 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i.i394.i683, i32 0, i32 1
  %call26.i.i.i414.i703 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i.i413.i702, %class.object.2* %agg.tmp20.i.i.i389.i678)
          to label %invoke.cont25.i.i.i416.i705 unwind label %lpad24.i.i.i432.i721

invoke.cont25.i.i.i416.i705:                      ; preds = %invoke.cont22.i.i.i415.i704
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i389.i678) #7
  sync within %syncreg.i.i.i390.i679, label %sync.continue.i.i.i417.i706

sync.continue.i.i.i417.i706:                      ; preds = %invoke.cont25.i.i.i416.i705
  invoke void @llvm.sync.unwind(token %syncreg.i.i.i390.i679)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i731 unwind label %lpad4.i.i558.i847

lpad.i.i.i418.i707:                               ; preds = %.noexc.i.i398.i687
  %609 = landingpad { i8*, i32 }
          cleanup
  %610 = extractvalue { i8*, i32 } %609, 0
  store i8* %610, i8** %exn.slot.i.i.i387.i676, align 8
  %611 = extractvalue { i8*, i32 } %609, 1
  store i32 %611, i32* %ehselector.slot.i.i.i388.i677, align 4
  br label %ehcleanup29.i.i.i438.i727

lpad4.i.i.i419.i708:                              ; preds = %det.achd.i.i.i407.i696
  %612 = landingpad { i8*, i32 }
          cleanup
  %613 = extractvalue { i8*, i32 } %612, 0
  store i8* %613, i8** %exn.slot5.i.i.i405.i694, align 8
  %614 = extractvalue { i8*, i32 } %612, 1
  store i32 %614, i32* %ehselector.slot6.i.i.i406.i695, align 4
  br label %ehcleanup.i.i.i425.i714

lpad8.i.i.i420.i709:                              ; preds = %invoke.cont7.i.i.i409.i698
  %615 = landingpad { i8*, i32 }
          cleanup
  %616 = extractvalue { i8*, i32 } %615, 0
  store i8* %616, i8** %exn.slot5.i.i.i405.i694, align 8
  %617 = extractvalue { i8*, i32 } %615, 1
  store i32 %617, i32* %ehselector.slot6.i.i.i406.i695, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i.i400.i689) #7
  br label %ehcleanup.i.i.i425.i714

ehcleanup.i.i.i425.i714:                          ; preds = %lpad8.i.i.i420.i709, %lpad4.i.i.i419.i708
  %exn.i.i.i421.i710 = load i8*, i8** %exn.slot5.i.i.i405.i694, align 8
  %sel.i.i.i422.i711 = load i32, i32* %ehselector.slot6.i.i.i406.i695, align 4
  %lpad.val.i.i.i423.i712 = insertvalue { i8*, i32 } undef, i8* %exn.i.i.i421.i710, 0
  %lpad.val10.i.i.i424.i713 = insertvalue { i8*, i32 } %lpad.val.i.i.i423.i712, i32 %sel.i.i.i422.i711, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i.i390.i679, { i8*, i32 } %lpad.val10.i.i.i424.i713)
          to label %unreachable.i.i.i439.i728 unwind label %lpad11.i.i.i430.i719

lpad11.i.i.i430.i719:                             ; preds = %ehcleanup.i.i.i425.i714, %invoke.cont.i.i.i399.i688
  %618 = landingpad { i8*, i32 }
          cleanup
  %619 = extractvalue { i8*, i32 } %618, 0
  store i8* %619, i8** %exn.slot12.i.i.i401.i690, align 8
  %620 = extractvalue { i8*, i32 } %618, 1
  store i32 %620, i32* %ehselector.slot13.i.i.i402.i691, align 4
  %exn15.i.i.i426.i715 = load i8*, i8** %exn.slot12.i.i.i401.i690, align 8
  %sel16.i.i.i427.i716 = load i32, i32* %ehselector.slot13.i.i.i402.i691, align 4
  %lpad.val17.i.i.i428.i717 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i.i426.i715, 0
  %lpad.val18.i.i.i429.i718 = insertvalue { i8*, i32 } %lpad.val17.i.i.i428.i717, i32 %sel16.i.i.i427.i716, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %606, { i8*, i32 } %lpad.val18.i.i.i429.i718)
          to label %unreachable.i.i.i439.i728 unwind label %lpad19.i.i.i431.i720

lpad19.i.i.i431.i720:                             ; preds = %lpad11.i.i.i430.i719, %det.cont.i.i.i412.i701
  %621 = landingpad { i8*, i32 }
          cleanup
  %622 = extractvalue { i8*, i32 } %621, 0
  store i8* %622, i8** %exn.slot.i.i.i387.i676, align 8
  %623 = extractvalue { i8*, i32 } %621, 1
  store i32 %623, i32* %ehselector.slot.i.i.i388.i677, align 4
  br label %ehcleanup28.i.i.i433.i722

lpad24.i.i.i432.i721:                             ; preds = %invoke.cont22.i.i.i415.i704
  %624 = landingpad { i8*, i32 }
          cleanup
  %625 = extractvalue { i8*, i32 } %624, 0
  store i8* %625, i8** %exn.slot.i.i.i387.i676, align 8
  %626 = extractvalue { i8*, i32 } %624, 1
  store i32 %626, i32* %ehselector.slot.i.i.i388.i677, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i.i389.i678) #7
  br label %ehcleanup28.i.i.i433.i722

ehcleanup28.i.i.i433.i722:                        ; preds = %lpad24.i.i.i432.i721, %lpad19.i.i.i431.i720
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i.i397.i686) #7
  br label %ehcleanup29.i.i.i438.i727

ehcleanup29.i.i.i438.i727:                        ; preds = %ehcleanup28.i.i.i433.i722, %lpad.i.i.i418.i707
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i.i395.i684) #7
  %exn30.i.i.i434.i723 = load i8*, i8** %exn.slot.i.i.i387.i676, align 8
  %sel31.i.i.i435.i724 = load i32, i32* %ehselector.slot.i.i.i388.i677, align 4
  %lpad.val32.i.i.i436.i725 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i.i434.i723, 0
  %lpad.val33.i.i.i437.i726 = insertvalue { i8*, i32 } %lpad.val32.i.i.i436.i725, i32 %sel31.i.i.i435.i724, 1
  br label %lpad4.body.i.i560.i849

unreachable.i.i.i439.i728:                        ; preds = %lpad11.i.i.i430.i719, %ehcleanup.i.i.i425.i714
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i731:        ; preds = %sync.continue.i.i.i417.i706
  call void @llvm.stackrestore(i8* %savedstack.i.i393.i682)
  %savedstack61.i.i440.i729 = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i.i375.i664, %class.object.1** %this.addr.i36.i.i377.i666, align 8
  %this1.i40.i.i441.i730 = load %class.object.1*, %class.object.1** %this.addr.i36.i.i377.i666, align 8
  %627 = call token @llvm.taskframe.create()
  %a.i44.i.i443.i732 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i441.i730, i32 0, i32 0
  %a2.i45.i.i444.i733 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i372.i661, i32 0, i32 0
  detach within %syncreg.i37.i.i384.i673, label %det.achd.i49.i.i448.i737, label %det.cont.i52.i.i451.i740 unwind label %lpad4.i58.i.i465.i754

det.achd.i49.i.i448.i737:                         ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i731
  %exn.slot.i46.i.i445.i734 = alloca i8*
  %ehselector.slot.i47.i.i446.i735 = alloca i32
  call void @llvm.taskframe.use(token %627)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i.i381.i670, %class.object.2* dereferenceable(1) %a2.i45.i.i444.i733)
  %call.i48.i.i447.i736 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i.i443.i732, %class.object.2* %agg.tmp.i41.i.i381.i670)
          to label %invoke.cont.i50.i.i449.i738 unwind label %lpad.i56.i.i460.i749

invoke.cont.i50.i.i449.i738:                      ; preds = %det.achd.i49.i.i448.i737
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i381.i670) #7
  reattach within %syncreg.i37.i.i384.i673, label %det.cont.i52.i.i451.i740

det.cont.i52.i.i451.i740:                         ; preds = %invoke.cont.i50.i.i449.i738, %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i731
  %b.i51.i.i450.i739 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i.i372.i661, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i.i380.i669, %class.object.2* dereferenceable(1) %b.i51.i.i450.i739)
          to label %.noexc63.i.i454.i743 unwind label %lpad8.i.i561.i850

.noexc63.i.i454.i743:                             ; preds = %det.cont.i52.i.i451.i740
  %b15.i.i.i452.i741 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i.i441.i730, i32 0, i32 1
  %call18.i.i.i453.i742 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i.i452.i741, %class.object.2* %agg.tmp14.i.i.i380.i669)
          to label %invoke.cont17.i.i.i455.i744 unwind label %lpad16.i.i.i467.i756

invoke.cont17.i.i.i455.i744:                      ; preds = %.noexc63.i.i454.i743
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i380.i669) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i.i460.i749:                             ; preds = %det.achd.i49.i.i448.i737
  %628 = landingpad { i8*, i32 }
          cleanup
  %629 = extractvalue { i8*, i32 } %628, 0
  store i8* %629, i8** %exn.slot.i46.i.i445.i734, align 8
  %630 = extractvalue { i8*, i32 } %628, 1
  store i32 %630, i32* %ehselector.slot.i47.i.i446.i735, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i.i381.i670) #7
  %exn.i53.i.i456.i745 = load i8*, i8** %exn.slot.i46.i.i445.i734, align 8
  %sel.i54.i.i457.i746 = load i32, i32* %ehselector.slot.i47.i.i446.i735, align 4
  %lpad.val.i55.i.i458.i747 = insertvalue { i8*, i32 } undef, i8* %exn.i53.i.i456.i745, 0
  %lpad.val3.i.i.i459.i748 = insertvalue { i8*, i32 } %lpad.val.i55.i.i458.i747, i32 %sel.i54.i.i457.i746, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i.i384.i673, { i8*, i32 } %lpad.val3.i.i.i459.i748)
          to label %unreachable.i60.i.i473.i762 unwind label %lpad4.i58.i.i465.i754

lpad4.i58.i.i465.i754:                            ; preds = %lpad.i56.i.i460.i749, %_ZN6objectILi1EEC2ERKS0_.exit.i.i442.i731
  %631 = landingpad { i8*, i32 }
          cleanup
  %632 = extractvalue { i8*, i32 } %631, 0
  store i8* %632, i8** %exn.slot5.i42.i.i382.i671, align 8
  %633 = extractvalue { i8*, i32 } %631, 1
  store i32 %633, i32* %ehselector.slot6.i43.i.i383.i672, align 4
  %exn7.i.i.i461.i750 = load i8*, i8** %exn.slot5.i42.i.i382.i671, align 8
  %sel8.i.i.i462.i751 = load i32, i32* %ehselector.slot6.i43.i.i383.i672, align 4
  %lpad.val9.i.i.i463.i752 = insertvalue { i8*, i32 } undef, i8* %exn7.i.i.i461.i750, 0
  %lpad.val10.i57.i.i464.i753 = insertvalue { i8*, i32 } %lpad.val9.i.i.i463.i752, i32 %sel8.i.i.i462.i751, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %627, { i8*, i32 } %lpad.val10.i57.i.i464.i753)
          to label %unreachable.i60.i.i473.i762 unwind label %lpad11.i59.i.i466.i755

lpad11.i59.i.i466.i755:                           ; preds = %lpad4.i58.i.i465.i754
  %634 = landingpad { i8*, i32 }
          cleanup
  %635 = extractvalue { i8*, i32 } %634, 0
  store i8* %635, i8** %exn.slot12.i38.i.i378.i667, align 8
  %636 = extractvalue { i8*, i32 } %634, 1
  store i32 %636, i32* %ehselector.slot13.i39.i.i379.i668, align 4
  br label %eh.resume.i.i.i472.i761

lpad16.i.i.i467.i756:                             ; preds = %.noexc63.i.i454.i743
  %637 = landingpad { i8*, i32 }
          cleanup
  %638 = extractvalue { i8*, i32 } %637, 0
  store i8* %638, i8** %exn.slot12.i38.i.i378.i667, align 8
  %639 = extractvalue { i8*, i32 } %637, 1
  store i32 %639, i32* %ehselector.slot13.i39.i.i379.i668, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i.i380.i669) #7
  br label %eh.resume.i.i.i472.i761

eh.resume.i.i.i472.i761:                          ; preds = %lpad16.i.i.i467.i756, %lpad11.i59.i.i466.i755
  %exn19.i.i.i468.i757 = load i8*, i8** %exn.slot12.i38.i.i378.i667, align 8
  %sel20.i.i.i469.i758 = load i32, i32* %ehselector.slot13.i39.i.i379.i668, align 4
  %lpad.val21.i.i.i470.i759 = insertvalue { i8*, i32 } undef, i8* %exn19.i.i.i468.i757, 0
  %lpad.val22.i.i.i471.i760 = insertvalue { i8*, i32 } %lpad.val21.i.i.i470.i759, i32 %sel20.i.i.i469.i758, 1
  br label %lpad8.body.i.i563.i852

unreachable.i60.i.i473.i762:                      ; preds = %lpad4.i58.i.i465.i754, %lpad.i56.i.i460.i749
  unreachable

det.cont.i.i478.i767:                             ; preds = %invoke.cont.i.i371.i660
  %640 = load %class.object.0*, %class.object.0** %other.addr.i.i356.i645, align 8
  %b21.i.i474.i763 = getelementptr inbounds %class.object.0, %class.object.0* %640, i32 0, i32 1
  %savedstack116.i.i475.i764 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i.i359.i648, %class.object.1** %this.addr.i65.i.i350.i639, align 8
  store %class.object.1* %b21.i.i474.i763, %class.object.1** %other.addr.i66.i.i351.i640, align 8
  %this1.i71.i.i476.i765 = load %class.object.1*, %class.object.1** %this.addr.i65.i.i350.i639, align 8
  %a.i72.i.i477.i766 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i476.i765, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i.i477.i766)
          to label %.noexc117.i.i480.i769 unwind label %lpad19.i.i574.i863

.noexc117.i.i480.i769:                            ; preds = %det.cont.i.i478.i767
  %b.i73.i.i479.i768 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i476.i765, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i.i479.i768)
          to label %invoke.cont.i79.i.i481.i770 unwind label %lpad.i93.i.i500.i789

invoke.cont.i79.i.i481.i770:                      ; preds = %.noexc117.i.i480.i769
  %641 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i.i482.i771 = alloca %class.object.2, align 1
  %exn.slot12.i75.i.i483.i772 = alloca i8*
  %ehselector.slot13.i76.i.i484.i773 = alloca i32
  %a2.i77.i.i485.i774 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i476.i765, i32 0, i32 0
  %642 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i351.i640, align 8
  %a3.i78.i.i486.i775 = getelementptr inbounds %class.object.1, %class.object.1* %642, i32 0, i32 0
  detach within %syncreg.i69.i.i361.i650, label %det.achd.i82.i.i489.i778, label %det.cont.i87.i.i494.i783 unwind label %lpad11.i101.i.i512.i801

det.achd.i82.i.i489.i778:                         ; preds = %invoke.cont.i79.i.i481.i770
  %exn.slot5.i80.i.i487.i776 = alloca i8*
  %ehselector.slot6.i81.i.i488.i777 = alloca i32
  call void @llvm.taskframe.use(token %641)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i.i482.i771, %class.object.2* dereferenceable(1) %a3.i78.i.i486.i775)
          to label %invoke.cont7.i84.i.i491.i780 unwind label %lpad4.i94.i.i501.i790

invoke.cont7.i84.i.i491.i780:                     ; preds = %det.achd.i82.i.i489.i778
  %call.i83.i.i490.i779 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i.i485.i774, %class.object.2* %agg.tmp.i74.i.i482.i771)
          to label %invoke.cont9.i85.i.i492.i781 unwind label %lpad8.i95.i.i502.i791

invoke.cont9.i85.i.i492.i781:                     ; preds = %invoke.cont7.i84.i.i491.i780
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i482.i771) #7
  reattach within %syncreg.i69.i.i361.i650, label %det.cont.i87.i.i494.i783

det.cont.i87.i.i494.i783:                         ; preds = %invoke.cont9.i85.i.i492.i781, %invoke.cont.i79.i.i481.i770
  %643 = load %class.object.1*, %class.object.1** %other.addr.i66.i.i351.i640, align 8
  %b21.i86.i.i493.i782 = getelementptr inbounds %class.object.1, %class.object.1* %643, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i.i354.i643, %class.object.2* dereferenceable(1) %b21.i86.i.i493.i782)
          to label %invoke.cont22.i90.i.i497.i786 unwind label %lpad19.i106.i.i513.i802

invoke.cont22.i90.i.i497.i786:                    ; preds = %det.cont.i87.i.i494.i783
  %b23.i88.i.i495.i784 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i.i476.i765, i32 0, i32 1
  %call26.i89.i.i496.i785 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i.i495.i784, %class.object.2* %agg.tmp20.i70.i.i354.i643)
          to label %invoke.cont25.i91.i.i498.i787 unwind label %lpad24.i107.i.i514.i803

invoke.cont25.i91.i.i498.i787:                    ; preds = %invoke.cont22.i90.i.i497.i786
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i354.i643) #7
  sync within %syncreg.i69.i.i361.i650, label %sync.continue.i92.i.i499.i788

sync.continue.i92.i.i499.i788:                    ; preds = %invoke.cont25.i91.i.i498.i787
  invoke void @llvm.sync.unwind(token %syncreg.i69.i.i361.i650)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i814 unwind label %lpad19.i.i574.i863

lpad.i93.i.i500.i789:                             ; preds = %.noexc117.i.i480.i769
  %644 = landingpad { i8*, i32 }
          cleanup
  %645 = extractvalue { i8*, i32 } %644, 0
  store i8* %645, i8** %exn.slot.i67.i.i352.i641, align 8
  %646 = extractvalue { i8*, i32 } %644, 1
  store i32 %646, i32* %ehselector.slot.i68.i.i353.i642, align 4
  br label %ehcleanup29.i109.i.i520.i809

lpad4.i94.i.i501.i790:                            ; preds = %det.achd.i82.i.i489.i778
  %647 = landingpad { i8*, i32 }
          cleanup
  %648 = extractvalue { i8*, i32 } %647, 0
  store i8* %648, i8** %exn.slot5.i80.i.i487.i776, align 8
  %649 = extractvalue { i8*, i32 } %647, 1
  store i32 %649, i32* %ehselector.slot6.i81.i.i488.i777, align 4
  br label %ehcleanup.i100.i.i507.i796

lpad8.i95.i.i502.i791:                            ; preds = %invoke.cont7.i84.i.i491.i780
  %650 = landingpad { i8*, i32 }
          cleanup
  %651 = extractvalue { i8*, i32 } %650, 0
  store i8* %651, i8** %exn.slot5.i80.i.i487.i776, align 8
  %652 = extractvalue { i8*, i32 } %650, 1
  store i32 %652, i32* %ehselector.slot6.i81.i.i488.i777, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i.i482.i771) #7
  br label %ehcleanup.i100.i.i507.i796

ehcleanup.i100.i.i507.i796:                       ; preds = %lpad8.i95.i.i502.i791, %lpad4.i94.i.i501.i790
  %exn.i96.i.i503.i792 = load i8*, i8** %exn.slot5.i80.i.i487.i776, align 8
  %sel.i97.i.i504.i793 = load i32, i32* %ehselector.slot6.i81.i.i488.i777, align 4
  %lpad.val.i98.i.i505.i794 = insertvalue { i8*, i32 } undef, i8* %exn.i96.i.i503.i792, 0
  %lpad.val10.i99.i.i506.i795 = insertvalue { i8*, i32 } %lpad.val.i98.i.i505.i794, i32 %sel.i97.i.i504.i793, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i.i361.i650, { i8*, i32 } %lpad.val10.i99.i.i506.i795)
          to label %unreachable.i115.i.i521.i810 unwind label %lpad11.i101.i.i512.i801

lpad11.i101.i.i512.i801:                          ; preds = %ehcleanup.i100.i.i507.i796, %invoke.cont.i79.i.i481.i770
  %653 = landingpad { i8*, i32 }
          cleanup
  %654 = extractvalue { i8*, i32 } %653, 0
  store i8* %654, i8** %exn.slot12.i75.i.i483.i772, align 8
  %655 = extractvalue { i8*, i32 } %653, 1
  store i32 %655, i32* %ehselector.slot13.i76.i.i484.i773, align 4
  %exn15.i102.i.i508.i797 = load i8*, i8** %exn.slot12.i75.i.i483.i772, align 8
  %sel16.i103.i.i509.i798 = load i32, i32* %ehselector.slot13.i76.i.i484.i773, align 4
  %lpad.val17.i104.i.i510.i799 = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i.i508.i797, 0
  %lpad.val18.i105.i.i511.i800 = insertvalue { i8*, i32 } %lpad.val17.i104.i.i510.i799, i32 %sel16.i103.i.i509.i798, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %641, { i8*, i32 } %lpad.val18.i105.i.i511.i800)
          to label %unreachable.i115.i.i521.i810 unwind label %lpad19.i106.i.i513.i802

lpad19.i106.i.i513.i802:                          ; preds = %lpad11.i101.i.i512.i801, %det.cont.i87.i.i494.i783
  %656 = landingpad { i8*, i32 }
          cleanup
  %657 = extractvalue { i8*, i32 } %656, 0
  store i8* %657, i8** %exn.slot.i67.i.i352.i641, align 8
  %658 = extractvalue { i8*, i32 } %656, 1
  store i32 %658, i32* %ehselector.slot.i68.i.i353.i642, align 4
  br label %ehcleanup28.i108.i.i515.i804

lpad24.i107.i.i514.i803:                          ; preds = %invoke.cont22.i90.i.i497.i786
  %659 = landingpad { i8*, i32 }
          cleanup
  %660 = extractvalue { i8*, i32 } %659, 0
  store i8* %660, i8** %exn.slot.i67.i.i352.i641, align 8
  %661 = extractvalue { i8*, i32 } %659, 1
  store i32 %661, i32* %ehselector.slot.i68.i.i353.i642, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i.i354.i643) #7
  br label %ehcleanup28.i108.i.i515.i804

ehcleanup28.i108.i.i515.i804:                     ; preds = %lpad24.i107.i.i514.i803, %lpad19.i106.i.i513.i802
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i.i479.i768) #7
  br label %ehcleanup29.i109.i.i520.i809

ehcleanup29.i109.i.i520.i809:                     ; preds = %ehcleanup28.i108.i.i515.i804, %lpad.i93.i.i500.i789
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i.i477.i766) #7
  %exn30.i110.i.i516.i805 = load i8*, i8** %exn.slot.i67.i.i352.i641, align 8
  %sel31.i111.i.i517.i806 = load i32, i32* %ehselector.slot.i68.i.i353.i642, align 4
  %lpad.val32.i112.i.i518.i807 = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i.i516.i805, 0
  %lpad.val33.i113.i.i519.i808 = insertvalue { i8*, i32 } %lpad.val32.i112.i.i518.i807, i32 %sel31.i111.i.i517.i806, 1
  br label %lpad19.body.i.i576.i865

unreachable.i115.i.i521.i810:                     ; preds = %lpad11.i101.i.i512.i801, %ehcleanup.i100.i.i507.i796
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i814:     ; preds = %sync.continue.i92.i.i499.i788
  call void @llvm.stackrestore(i8* %savedstack116.i.i475.i764)
  %b23.i.i522.i811 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i.i366.i655, i32 0, i32 1
  %savedstack161.i.i523.i812 = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i.i522.i811, %class.object.1** %this.addr.i122.i.i343.i632, align 8
  %this1.i127.i.i524.i813 = load %class.object.1*, %class.object.1** %this.addr.i122.i.i343.i632, align 8
  %662 = call token @llvm.taskframe.create()
  %a.i131.i.i526.i815 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i524.i813, i32 0, i32 0
  %a2.i132.i.i527.i816 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i359.i648, i32 0, i32 0
  detach within %syncreg.i123.i.i360.i649, label %det.achd.i136.i.i531.i820, label %det.cont.i141.i.i534.i823 unwind label %lpad4.i152.i.i548.i837

det.achd.i136.i.i531.i820:                        ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i814
  %exn.slot.i133.i.i528.i817 = alloca i8*
  %ehselector.slot.i134.i.i529.i818 = alloca i32
  call void @llvm.taskframe.use(token %662)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i.i347.i636, %class.object.2* dereferenceable(1) %a2.i132.i.i527.i816)
  %call.i135.i.i530.i819 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i.i526.i815, %class.object.2* %agg.tmp.i128.i.i347.i636)
          to label %invoke.cont.i137.i.i532.i821 unwind label %lpad.i147.i.i543.i832

invoke.cont.i137.i.i532.i821:                     ; preds = %det.achd.i136.i.i531.i820
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i347.i636) #7
  reattach within %syncreg.i123.i.i360.i649, label %det.cont.i141.i.i534.i823

det.cont.i141.i.i534.i823:                        ; preds = %invoke.cont.i137.i.i532.i821, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i814
  %b.i138.i.i533.i822 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i.i359.i648, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i.i346.i635, %class.object.2* dereferenceable(1) %b.i138.i.i533.i822)
          to label %.noexc164.i.i537.i826 unwind label %lpad24.i.i577.i866

.noexc164.i.i537.i826:                            ; preds = %det.cont.i141.i.i534.i823
  %b15.i139.i.i535.i824 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i.i524.i813, i32 0, i32 1
  %call18.i140.i.i536.i825 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i.i535.i824, %class.object.2* %agg.tmp14.i126.i.i346.i635)
          to label %invoke.cont17.i142.i.i538.i827 unwind label %lpad16.i154.i.i550.i839

invoke.cont17.i142.i.i538.i827:                   ; preds = %.noexc164.i.i537.i826
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i346.i635) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i.i543.i832:                            ; preds = %det.achd.i136.i.i531.i820
  %663 = landingpad { i8*, i32 }
          cleanup
  %664 = extractvalue { i8*, i32 } %663, 0
  store i8* %664, i8** %exn.slot.i133.i.i528.i817, align 8
  %665 = extractvalue { i8*, i32 } %663, 1
  store i32 %665, i32* %ehselector.slot.i134.i.i529.i818, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i.i347.i636) #7
  %exn.i143.i.i539.i828 = load i8*, i8** %exn.slot.i133.i.i528.i817, align 8
  %sel.i144.i.i540.i829 = load i32, i32* %ehselector.slot.i134.i.i529.i818, align 4
  %lpad.val.i145.i.i541.i830 = insertvalue { i8*, i32 } undef, i8* %exn.i143.i.i539.i828, 0
  %lpad.val3.i146.i.i542.i831 = insertvalue { i8*, i32 } %lpad.val.i145.i.i541.i830, i32 %sel.i144.i.i540.i829, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i.i360.i649, { i8*, i32 } %lpad.val3.i146.i.i542.i831)
          to label %unreachable.i160.i.i556.i845 unwind label %lpad4.i152.i.i548.i837

lpad4.i152.i.i548.i837:                           ; preds = %lpad.i147.i.i543.i832, %_ZN6objectILi1EEC2ERKS0_.exit121.i.i525.i814
  %666 = landingpad { i8*, i32 }
          cleanup
  %667 = extractvalue { i8*, i32 } %666, 0
  store i8* %667, i8** %exn.slot5.i129.i.i348.i637, align 8
  %668 = extractvalue { i8*, i32 } %666, 1
  store i32 %668, i32* %ehselector.slot6.i130.i.i349.i638, align 4
  %exn7.i148.i.i544.i833 = load i8*, i8** %exn.slot5.i129.i.i348.i637, align 8
  %sel8.i149.i.i545.i834 = load i32, i32* %ehselector.slot6.i130.i.i349.i638, align 4
  %lpad.val9.i150.i.i546.i835 = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i.i544.i833, 0
  %lpad.val10.i151.i.i547.i836 = insertvalue { i8*, i32 } %lpad.val9.i150.i.i546.i835, i32 %sel8.i149.i.i545.i834, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %662, { i8*, i32 } %lpad.val10.i151.i.i547.i836)
          to label %unreachable.i160.i.i556.i845 unwind label %lpad11.i153.i.i549.i838

lpad11.i153.i.i549.i838:                          ; preds = %lpad4.i152.i.i548.i837
  %669 = landingpad { i8*, i32 }
          cleanup
  %670 = extractvalue { i8*, i32 } %669, 0
  store i8* %670, i8** %exn.slot12.i124.i.i344.i633, align 8
  %671 = extractvalue { i8*, i32 } %669, 1
  store i32 %671, i32* %ehselector.slot13.i125.i.i345.i634, align 4
  br label %eh.resume.i159.i.i555.i844

lpad16.i154.i.i550.i839:                          ; preds = %.noexc164.i.i537.i826
  %672 = landingpad { i8*, i32 }
          cleanup
  %673 = extractvalue { i8*, i32 } %672, 0
  store i8* %673, i8** %exn.slot12.i124.i.i344.i633, align 8
  %674 = extractvalue { i8*, i32 } %672, 1
  store i32 %674, i32* %ehselector.slot13.i125.i.i345.i634, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i.i346.i635) #7
  br label %eh.resume.i159.i.i555.i844

eh.resume.i159.i.i555.i844:                       ; preds = %lpad16.i154.i.i550.i839, %lpad11.i153.i.i549.i838
  %exn19.i155.i.i551.i840 = load i8*, i8** %exn.slot12.i124.i.i344.i633, align 8
  %sel20.i156.i.i552.i841 = load i32, i32* %ehselector.slot13.i125.i.i345.i634, align 4
  %lpad.val21.i157.i.i553.i842 = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i.i551.i840, 0
  %lpad.val22.i158.i.i554.i843 = insertvalue { i8*, i32 } %lpad.val21.i157.i.i553.i842, i32 %sel20.i156.i.i552.i841, 1
  br label %lpad24.body.i.i579.i868

unreachable.i160.i.i556.i845:                     ; preds = %lpad4.i152.i.i548.i837, %lpad.i147.i.i543.i832
  unreachable

lpad.i.i557.i846:                                 ; preds = %.noexc.i370.i659
  %675 = landingpad { i8*, i32 }
          cleanup
  %676 = extractvalue { i8*, i32 } %675, 0
  store i8* %676, i8** %exn.slot.i.i357.i646, align 8
  %677 = extractvalue { i8*, i32 } %675, 1
  store i32 %677, i32* %ehselector.slot.i.i358.i647, align 4
  br label %ehcleanup29.i.i585.i874

lpad4.i.i558.i847:                                ; preds = %sync.continue.i.i.i417.i706, %det.achd.i.i396.i685
  %678 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i.i560.i849

lpad4.body.i.i560.i849:                           ; preds = %lpad4.i.i558.i847, %ehcleanup29.i.i.i438.i727
  %eh.lpad-body.i.i559.i848 = phi { i8*, i32 } [ %678, %lpad4.i.i558.i847 ], [ %lpad.val33.i.i.i437.i726, %ehcleanup29.i.i.i438.i727 ]
  %679 = extractvalue { i8*, i32 } %eh.lpad-body.i.i559.i848, 0
  store i8* %679, i8** %exn.slot5.i.i391.i680, align 8
  %680 = extractvalue { i8*, i32 } %eh.lpad-body.i.i559.i848, 1
  store i32 %680, i32* %ehselector.slot6.i.i392.i681, align 4
  br label %ehcleanup.i.i568.i857

lpad8.i.i561.i850:                                ; preds = %det.cont.i52.i.i451.i740
  %681 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i.i563.i852

lpad8.body.i.i563.i852:                           ; preds = %lpad8.i.i561.i850, %eh.resume.i.i.i472.i761
  %eh.lpad-body64.i.i562.i851 = phi { i8*, i32 } [ %681, %lpad8.i.i561.i850 ], [ %lpad.val22.i.i.i471.i760, %eh.resume.i.i.i472.i761 ]
  %682 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i562.i851, 0
  store i8* %682, i8** %exn.slot5.i.i391.i680, align 8
  %683 = extractvalue { i8*, i32 } %eh.lpad-body64.i.i562.i851, 1
  store i32 %683, i32* %ehselector.slot6.i.i392.i681, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i.i372.i661) #7
  br label %ehcleanup.i.i568.i857

ehcleanup.i.i568.i857:                            ; preds = %lpad8.body.i.i563.i852, %lpad4.body.i.i560.i849
  %exn.i.i564.i853 = load i8*, i8** %exn.slot5.i.i391.i680, align 8
  %sel.i.i565.i854 = load i32, i32* %ehselector.slot6.i.i392.i681, align 4
  %lpad.val.i.i566.i855 = insertvalue { i8*, i32 } undef, i8* %exn.i.i564.i853, 0
  %lpad.val10.i.i567.i856 = insertvalue { i8*, i32 } %lpad.val.i.i566.i855, i32 %sel.i.i565.i854, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i362.i651, { i8*, i32 } %lpad.val10.i.i567.i856)
          to label %unreachable.i.i586.i875 unwind label %lpad11.i.i573.i862

lpad11.i.i573.i862:                               ; preds = %ehcleanup.i.i568.i857, %invoke.cont.i.i371.i660
  %684 = landingpad { i8*, i32 }
          cleanup
  %685 = extractvalue { i8*, i32 } %684, 0
  store i8* %685, i8** %exn.slot12.i.i373.i662, align 8
  %686 = extractvalue { i8*, i32 } %684, 1
  store i32 %686, i32* %ehselector.slot13.i.i374.i663, align 4
  %exn15.i.i569.i858 = load i8*, i8** %exn.slot12.i.i373.i662, align 8
  %sel16.i.i570.i859 = load i32, i32* %ehselector.slot13.i.i374.i663, align 4
  %lpad.val17.i.i571.i860 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i569.i858, 0
  %lpad.val18.i.i572.i861 = insertvalue { i8*, i32 } %lpad.val17.i.i571.i860, i32 %sel16.i.i570.i859, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %604, { i8*, i32 } %lpad.val18.i.i572.i861)
          to label %unreachable.i.i586.i875 unwind label %lpad19.i.i574.i863

lpad19.i.i574.i863:                               ; preds = %lpad11.i.i573.i862, %sync.continue.i92.i.i499.i788, %det.cont.i.i478.i767
  %687 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i.i576.i865

lpad19.body.i.i576.i865:                          ; preds = %lpad19.i.i574.i863, %ehcleanup29.i109.i.i520.i809
  %eh.lpad-body118.i.i575.i864 = phi { i8*, i32 } [ %687, %lpad19.i.i574.i863 ], [ %lpad.val33.i113.i.i519.i808, %ehcleanup29.i109.i.i520.i809 ]
  %688 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i575.i864, 0
  store i8* %688, i8** %exn.slot.i.i357.i646, align 8
  %689 = extractvalue { i8*, i32 } %eh.lpad-body118.i.i575.i864, 1
  store i32 %689, i32* %ehselector.slot.i.i358.i647, align 4
  br label %ehcleanup28.i.i580.i869

lpad24.i.i577.i866:                               ; preds = %det.cont.i141.i.i534.i823
  %690 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i.i579.i868

lpad24.body.i.i579.i868:                          ; preds = %lpad24.i.i577.i866, %eh.resume.i159.i.i555.i844
  %eh.lpad-body165.i.i578.i867 = phi { i8*, i32 } [ %690, %lpad24.i.i577.i866 ], [ %lpad.val22.i158.i.i554.i843, %eh.resume.i159.i.i555.i844 ]
  %691 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i578.i867, 0
  store i8* %691, i8** %exn.slot.i.i357.i646, align 8
  %692 = extractvalue { i8*, i32 } %eh.lpad-body165.i.i578.i867, 1
  store i32 %692, i32* %ehselector.slot.i.i358.i647, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i.i359.i648) #7
  br label %ehcleanup28.i.i580.i869

ehcleanup28.i.i580.i869:                          ; preds = %lpad24.body.i.i579.i868, %lpad19.body.i.i576.i865
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i.i369.i658) #7
  br label %ehcleanup29.i.i585.i874

ehcleanup29.i.i585.i874:                          ; preds = %ehcleanup28.i.i580.i869, %lpad.i.i557.i846
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i.i367.i656) #7
  %exn30.i.i581.i870 = load i8*, i8** %exn.slot.i.i357.i646, align 8
  %sel31.i.i582.i871 = load i32, i32* %ehselector.slot.i.i358.i647, align 4
  %lpad.val32.i.i583.i872 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i581.i870, 0
  %lpad.val33.i.i584.i873 = insertvalue { i8*, i32 } %lpad.val32.i.i583.i872, i32 %sel31.i.i582.i871, 1
  br label %lpad4.body.i813.i1106

unreachable.i.i586.i875:                          ; preds = %lpad11.i.i573.i862, %ehcleanup.i.i568.i857
  unreachable

det.cont.i591.i880:                               ; preds = %invoke.cont.i337.i626
  %693 = load %class.object*, %class.object** %other.addr.i329.i45, align 8
  %b21.i587.i876 = getelementptr inbounds %class.object, %class.object* %693, i32 0, i32 1
  %savedstack373.i588.i877 = call i8* @llvm.stacksave()
  store %class.object.0* %agg.tmp20.i333.i48, %class.object.0** %this.addr.i147.i317.i39, align 8
  store %class.object.0* %b21.i587.i876, %class.object.0** %other.addr.i148.i318.i40, align 8
  %this1.i153.i589.i878 = load %class.object.0*, %class.object.0** %this.addr.i147.i317.i39, align 8
  %a.i154.i590.i879 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i589.i878, i32 0, i32 0
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %a.i154.i590.i879)
          to label %.noexc374.i593.i882 unwind label %lpad19.i823.i1112

.noexc374.i593.i882:                              ; preds = %det.cont.i591.i880
  %b.i155.i592.i881 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i589.i878, i32 0, i32 1
  invoke void @_ZN6objectILi1EEC1Ev(%class.object.1* %b.i155.i592.i881)
          to label %invoke.cont.i156.i594.i883 unwind label %lpad.i342.i780.i1069

invoke.cont.i156.i594.i883:                       ; preds = %.noexc374.i593.i882
  %694 = call token @llvm.taskframe.create()
  %agg.tmp.i157.i595.i884 = alloca %class.object.1, align 1
  %exn.slot12.i158.i596.i885 = alloca i8*
  %ehselector.slot13.i159.i597.i886 = alloca i32
  %a2.i160.i598.i887 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i589.i878, i32 0, i32 0
  %695 = load %class.object.0*, %class.object.0** %other.addr.i148.i318.i40, align 8
  %a3.i161.i599.i888 = getelementptr inbounds %class.object.0, %class.object.0* %695, i32 0, i32 0
  detach within %syncreg.i151.i324.i54, label %det.achd.i181.i619.i908, label %det.cont.i263.i701.i990 unwind label %lpad11.i354.i796.i1085

det.achd.i181.i619.i908:                          ; preds = %invoke.cont.i156.i594.i883
  %this.addr.i36.i162.i600.i889 = alloca %class.object.1*, align 8
  %exn.slot12.i38.i163.i601.i890 = alloca i8*
  %ehselector.slot13.i39.i164.i602.i891 = alloca i32
  %agg.tmp14.i.i165.i603.i892 = alloca %class.object.2, align 1
  %agg.tmp.i41.i166.i604.i893 = alloca %class.object.2, align 1
  %exn.slot5.i42.i167.i605.i894 = alloca i8*
  %ehselector.slot6.i43.i168.i606.i895 = alloca i32
  %syncreg.i37.i169.i607.i896 = call token @llvm.syncregion.start()
  %this.addr.i.i170.i608.i897 = alloca %class.object.1*, align 8
  %other.addr.i.i171.i609.i898 = alloca %class.object.1*, align 8
  %exn.slot.i.i172.i610.i899 = alloca i8*
  %ehselector.slot.i.i173.i611.i900 = alloca i32
  %agg.tmp20.i.i174.i612.i901 = alloca %class.object.2, align 1
  %syncreg.i.i175.i613.i902 = call token @llvm.syncregion.start()
  %exn.slot5.i176.i614.i903 = alloca i8*
  %ehselector.slot6.i177.i615.i904 = alloca i32
  call void @llvm.taskframe.use(token %694)
  %savedstack.i178.i616.i905 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp.i157.i595.i884, %class.object.1** %this.addr.i.i170.i608.i897, align 8
  store %class.object.1* %a3.i161.i599.i888, %class.object.1** %other.addr.i.i171.i609.i898, align 8
  %this1.i.i179.i617.i906 = load %class.object.1*, %class.object.1** %this.addr.i.i170.i608.i897, align 8
  %a.i.i180.i618.i907 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i617.i906, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i.i180.i618.i907)
          to label %.noexc.i183.i621.i910 unwind label %lpad4.i343.i781.i1070

.noexc.i183.i621.i910:                            ; preds = %det.achd.i181.i619.i908
  %b.i.i182.i620.i909 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i617.i906, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i.i182.i620.i909)
          to label %invoke.cont.i.i184.i622.i911 unwind label %lpad.i.i203.i641.i930

invoke.cont.i.i184.i622.i911:                     ; preds = %.noexc.i183.i621.i910
  %696 = call token @llvm.taskframe.create()
  %agg.tmp.i.i185.i623.i912 = alloca %class.object.2, align 1
  %exn.slot12.i.i186.i624.i913 = alloca i8*
  %ehselector.slot13.i.i187.i625.i914 = alloca i32
  %a2.i.i188.i626.i915 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i617.i906, i32 0, i32 0
  %697 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i609.i898, align 8
  %a3.i.i189.i627.i916 = getelementptr inbounds %class.object.1, %class.object.1* %697, i32 0, i32 0
  detach within %syncreg.i.i175.i613.i902, label %det.achd.i.i192.i630.i919, label %det.cont.i.i197.i635.i924 unwind label %lpad11.i.i215.i653.i942

det.achd.i.i192.i630.i919:                        ; preds = %invoke.cont.i.i184.i622.i911
  %exn.slot5.i.i190.i628.i917 = alloca i8*
  %ehselector.slot6.i.i191.i629.i918 = alloca i32
  call void @llvm.taskframe.use(token %696)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i.i185.i623.i912, %class.object.2* dereferenceable(1) %a3.i.i189.i627.i916)
          to label %invoke.cont7.i.i194.i632.i921 unwind label %lpad4.i.i204.i642.i931

invoke.cont7.i.i194.i632.i921:                    ; preds = %det.achd.i.i192.i630.i919
  %call.i.i193.i631.i920 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i.i188.i626.i915, %class.object.2* %agg.tmp.i.i185.i623.i912)
          to label %invoke.cont9.i.i195.i633.i922 unwind label %lpad8.i.i205.i643.i932

invoke.cont9.i.i195.i633.i922:                    ; preds = %invoke.cont7.i.i194.i632.i921
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i623.i912) #7
  reattach within %syncreg.i.i175.i613.i902, label %det.cont.i.i197.i635.i924

det.cont.i.i197.i635.i924:                        ; preds = %invoke.cont9.i.i195.i633.i922, %invoke.cont.i.i184.i622.i911
  %698 = load %class.object.1*, %class.object.1** %other.addr.i.i171.i609.i898, align 8
  %b21.i.i196.i634.i923 = getelementptr inbounds %class.object.1, %class.object.1* %698, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i.i174.i612.i901, %class.object.2* dereferenceable(1) %b21.i.i196.i634.i923)
          to label %invoke.cont22.i.i200.i638.i927 unwind label %lpad19.i.i216.i654.i943

invoke.cont22.i.i200.i638.i927:                   ; preds = %det.cont.i.i197.i635.i924
  %b23.i.i198.i636.i925 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i.i179.i617.i906, i32 0, i32 1
  %call26.i.i199.i637.i926 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i.i198.i636.i925, %class.object.2* %agg.tmp20.i.i174.i612.i901)
          to label %invoke.cont25.i.i201.i639.i928 unwind label %lpad24.i.i217.i655.i944

invoke.cont25.i.i201.i639.i928:                   ; preds = %invoke.cont22.i.i200.i638.i927
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i612.i901) #7
  sync within %syncreg.i.i175.i613.i902, label %sync.continue.i.i202.i640.i929

sync.continue.i.i202.i640.i929:                   ; preds = %invoke.cont25.i.i201.i639.i928
  invoke void @llvm.sync.unwind(token %syncreg.i.i175.i613.i902)
          to label %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i954 unwind label %lpad4.i343.i781.i1070

lpad.i.i203.i641.i930:                            ; preds = %.noexc.i183.i621.i910
  %699 = landingpad { i8*, i32 }
          cleanup
  %700 = extractvalue { i8*, i32 } %699, 0
  store i8* %700, i8** %exn.slot.i.i172.i610.i899, align 8
  %701 = extractvalue { i8*, i32 } %699, 1
  store i32 %701, i32* %ehselector.slot.i.i173.i611.i900, align 4
  br label %ehcleanup29.i.i223.i661.i950

lpad4.i.i204.i642.i931:                           ; preds = %det.achd.i.i192.i630.i919
  %702 = landingpad { i8*, i32 }
          cleanup
  %703 = extractvalue { i8*, i32 } %702, 0
  store i8* %703, i8** %exn.slot5.i.i190.i628.i917, align 8
  %704 = extractvalue { i8*, i32 } %702, 1
  store i32 %704, i32* %ehselector.slot6.i.i191.i629.i918, align 4
  br label %ehcleanup.i.i210.i648.i937

lpad8.i.i205.i643.i932:                           ; preds = %invoke.cont7.i.i194.i632.i921
  %705 = landingpad { i8*, i32 }
          cleanup
  %706 = extractvalue { i8*, i32 } %705, 0
  store i8* %706, i8** %exn.slot5.i.i190.i628.i917, align 8
  %707 = extractvalue { i8*, i32 } %705, 1
  store i32 %707, i32* %ehselector.slot6.i.i191.i629.i918, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i.i185.i623.i912) #7
  br label %ehcleanup.i.i210.i648.i937

ehcleanup.i.i210.i648.i937:                       ; preds = %lpad8.i.i205.i643.i932, %lpad4.i.i204.i642.i931
  %exn.i.i206.i644.i933 = load i8*, i8** %exn.slot5.i.i190.i628.i917, align 8
  %sel.i.i207.i645.i934 = load i32, i32* %ehselector.slot6.i.i191.i629.i918, align 4
  %lpad.val.i.i208.i646.i935 = insertvalue { i8*, i32 } undef, i8* %exn.i.i206.i644.i933, 0
  %lpad.val10.i.i209.i647.i936 = insertvalue { i8*, i32 } %lpad.val.i.i208.i646.i935, i32 %sel.i.i207.i645.i934, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i175.i613.i902, { i8*, i32 } %lpad.val10.i.i209.i647.i936)
          to label %unreachable.i.i224.i662.i951 unwind label %lpad11.i.i215.i653.i942

lpad11.i.i215.i653.i942:                          ; preds = %ehcleanup.i.i210.i648.i937, %invoke.cont.i.i184.i622.i911
  %708 = landingpad { i8*, i32 }
          cleanup
  %709 = extractvalue { i8*, i32 } %708, 0
  store i8* %709, i8** %exn.slot12.i.i186.i624.i913, align 8
  %710 = extractvalue { i8*, i32 } %708, 1
  store i32 %710, i32* %ehselector.slot13.i.i187.i625.i914, align 4
  %exn15.i.i211.i649.i938 = load i8*, i8** %exn.slot12.i.i186.i624.i913, align 8
  %sel16.i.i212.i650.i939 = load i32, i32* %ehselector.slot13.i.i187.i625.i914, align 4
  %lpad.val17.i.i213.i651.i940 = insertvalue { i8*, i32 } undef, i8* %exn15.i.i211.i649.i938, 0
  %lpad.val18.i.i214.i652.i941 = insertvalue { i8*, i32 } %lpad.val17.i.i213.i651.i940, i32 %sel16.i.i212.i650.i939, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %696, { i8*, i32 } %lpad.val18.i.i214.i652.i941)
          to label %unreachable.i.i224.i662.i951 unwind label %lpad19.i.i216.i654.i943

lpad19.i.i216.i654.i943:                          ; preds = %lpad11.i.i215.i653.i942, %det.cont.i.i197.i635.i924
  %711 = landingpad { i8*, i32 }
          cleanup
  %712 = extractvalue { i8*, i32 } %711, 0
  store i8* %712, i8** %exn.slot.i.i172.i610.i899, align 8
  %713 = extractvalue { i8*, i32 } %711, 1
  store i32 %713, i32* %ehselector.slot.i.i173.i611.i900, align 4
  br label %ehcleanup28.i.i218.i656.i945

lpad24.i.i217.i655.i944:                          ; preds = %invoke.cont22.i.i200.i638.i927
  %714 = landingpad { i8*, i32 }
          cleanup
  %715 = extractvalue { i8*, i32 } %714, 0
  store i8* %715, i8** %exn.slot.i.i172.i610.i899, align 8
  %716 = extractvalue { i8*, i32 } %714, 1
  store i32 %716, i32* %ehselector.slot.i.i173.i611.i900, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i.i174.i612.i901) #7
  br label %ehcleanup28.i.i218.i656.i945

ehcleanup28.i.i218.i656.i945:                     ; preds = %lpad24.i.i217.i655.i944, %lpad19.i.i216.i654.i943
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i.i182.i620.i909) #7
  br label %ehcleanup29.i.i223.i661.i950

ehcleanup29.i.i223.i661.i950:                     ; preds = %ehcleanup28.i.i218.i656.i945, %lpad.i.i203.i641.i930
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i.i180.i618.i907) #7
  %exn30.i.i219.i657.i946 = load i8*, i8** %exn.slot.i.i172.i610.i899, align 8
  %sel31.i.i220.i658.i947 = load i32, i32* %ehselector.slot.i.i173.i611.i900, align 4
  %lpad.val32.i.i221.i659.i948 = insertvalue { i8*, i32 } undef, i8* %exn30.i.i219.i657.i946, 0
  %lpad.val33.i.i222.i660.i949 = insertvalue { i8*, i32 } %lpad.val32.i.i221.i659.i948, i32 %sel31.i.i220.i658.i947, 1
  br label %lpad4.body.i345.i783.i1072

unreachable.i.i224.i662.i951:                     ; preds = %lpad11.i.i215.i653.i942, %ehcleanup.i.i210.i648.i937
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i954:     ; preds = %sync.continue.i.i202.i640.i929
  call void @llvm.stackrestore(i8* %savedstack.i178.i616.i905)
  %savedstack61.i226.i663.i952 = call i8* @llvm.stacksave()
  store %class.object.1* %a2.i160.i598.i887, %class.object.1** %this.addr.i36.i162.i600.i889, align 8
  %this1.i40.i227.i664.i953 = load %class.object.1*, %class.object.1** %this.addr.i36.i162.i600.i889, align 8
  %717 = call token @llvm.taskframe.create()
  %a.i44.i228.i666.i955 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i664.i953, i32 0, i32 0
  %a2.i45.i229.i667.i956 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i595.i884, i32 0, i32 0
  detach within %syncreg.i37.i169.i607.i896, label %det.achd.i49.i233.i671.i960, label %det.cont.i52.i236.i674.i963 unwind label %lpad4.i58.i250.i688.i977

det.achd.i49.i233.i671.i960:                      ; preds = %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i954
  %exn.slot.i46.i230.i668.i957 = alloca i8*
  %ehselector.slot.i47.i231.i669.i958 = alloca i32
  call void @llvm.taskframe.use(token %717)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i41.i166.i604.i893, %class.object.2* dereferenceable(1) %a2.i45.i229.i667.i956)
  %call.i48.i232.i670.i959 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i44.i228.i666.i955, %class.object.2* %agg.tmp.i41.i166.i604.i893)
          to label %invoke.cont.i50.i234.i672.i961 unwind label %lpad.i56.i245.i683.i972

invoke.cont.i50.i234.i672.i961:                   ; preds = %det.achd.i49.i233.i671.i960
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i604.i893) #7
  reattach within %syncreg.i37.i169.i607.i896, label %det.cont.i52.i236.i674.i963

det.cont.i52.i236.i674.i963:                      ; preds = %invoke.cont.i50.i234.i672.i961, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i954
  %b.i51.i235.i673.i962 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp.i157.i595.i884, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i.i165.i603.i892, %class.object.2* dereferenceable(1) %b.i51.i235.i673.i962)
          to label %.noexc63.i239.i677.i966 unwind label %lpad8.i346.i784.i1073

.noexc63.i239.i677.i966:                          ; preds = %det.cont.i52.i236.i674.i963
  %b15.i.i237.i675.i964 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i40.i227.i664.i953, i32 0, i32 1
  %call18.i.i238.i676.i965 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i.i237.i675.i964, %class.object.2* %agg.tmp14.i.i165.i603.i892)
          to label %invoke.cont17.i.i240.i678.i967 unwind label %lpad16.i.i252.i690.i979

invoke.cont17.i.i240.i678.i967:                   ; preds = %.noexc63.i239.i677.i966
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i603.i892) #7
  call void @llvm.trap()
  unreachable

lpad.i56.i245.i683.i972:                          ; preds = %det.achd.i49.i233.i671.i960
  %718 = landingpad { i8*, i32 }
          cleanup
  %719 = extractvalue { i8*, i32 } %718, 0
  store i8* %719, i8** %exn.slot.i46.i230.i668.i957, align 8
  %720 = extractvalue { i8*, i32 } %718, 1
  store i32 %720, i32* %ehselector.slot.i47.i231.i669.i958, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i41.i166.i604.i893) #7
  %exn.i53.i241.i679.i968 = load i8*, i8** %exn.slot.i46.i230.i668.i957, align 8
  %sel.i54.i242.i680.i969 = load i32, i32* %ehselector.slot.i47.i231.i669.i958, align 4
  %lpad.val.i55.i243.i681.i970 = insertvalue { i8*, i32 } undef, i8* %exn.i53.i241.i679.i968, 0
  %lpad.val3.i.i244.i682.i971 = insertvalue { i8*, i32 } %lpad.val.i55.i243.i681.i970, i32 %sel.i54.i242.i680.i969, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i37.i169.i607.i896, { i8*, i32 } %lpad.val3.i.i244.i682.i971)
          to label %unreachable.i60.i258.i696.i985 unwind label %lpad4.i58.i250.i688.i977

lpad4.i58.i250.i688.i977:                         ; preds = %lpad.i56.i245.i683.i972, %_ZN6objectILi1EEC2ERKS0_.exit.i225.i665.i954
  %721 = landingpad { i8*, i32 }
          cleanup
  %722 = extractvalue { i8*, i32 } %721, 0
  store i8* %722, i8** %exn.slot5.i42.i167.i605.i894, align 8
  %723 = extractvalue { i8*, i32 } %721, 1
  store i32 %723, i32* %ehselector.slot6.i43.i168.i606.i895, align 4
  %exn7.i.i246.i684.i973 = load i8*, i8** %exn.slot5.i42.i167.i605.i894, align 8
  %sel8.i.i247.i685.i974 = load i32, i32* %ehselector.slot6.i43.i168.i606.i895, align 4
  %lpad.val9.i.i248.i686.i975 = insertvalue { i8*, i32 } undef, i8* %exn7.i.i246.i684.i973, 0
  %lpad.val10.i57.i249.i687.i976 = insertvalue { i8*, i32 } %lpad.val9.i.i248.i686.i975, i32 %sel8.i.i247.i685.i974, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %717, { i8*, i32 } %lpad.val10.i57.i249.i687.i976)
          to label %unreachable.i60.i258.i696.i985 unwind label %lpad11.i59.i251.i689.i978

lpad11.i59.i251.i689.i978:                        ; preds = %lpad4.i58.i250.i688.i977
  %724 = landingpad { i8*, i32 }
          cleanup
  %725 = extractvalue { i8*, i32 } %724, 0
  store i8* %725, i8** %exn.slot12.i38.i163.i601.i890, align 8
  %726 = extractvalue { i8*, i32 } %724, 1
  store i32 %726, i32* %ehselector.slot13.i39.i164.i602.i891, align 4
  br label %eh.resume.i.i257.i695.i984

lpad16.i.i252.i690.i979:                          ; preds = %.noexc63.i239.i677.i966
  %727 = landingpad { i8*, i32 }
          cleanup
  %728 = extractvalue { i8*, i32 } %727, 0
  store i8* %728, i8** %exn.slot12.i38.i163.i601.i890, align 8
  %729 = extractvalue { i8*, i32 } %727, 1
  store i32 %729, i32* %ehselector.slot13.i39.i164.i602.i891, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i.i165.i603.i892) #7
  br label %eh.resume.i.i257.i695.i984

eh.resume.i.i257.i695.i984:                       ; preds = %lpad16.i.i252.i690.i979, %lpad11.i59.i251.i689.i978
  %exn19.i.i253.i691.i980 = load i8*, i8** %exn.slot12.i38.i163.i601.i890, align 8
  %sel20.i.i254.i692.i981 = load i32, i32* %ehselector.slot13.i39.i164.i602.i891, align 4
  %lpad.val21.i.i255.i693.i982 = insertvalue { i8*, i32 } undef, i8* %exn19.i.i253.i691.i980, 0
  %lpad.val22.i.i256.i694.i983 = insertvalue { i8*, i32 } %lpad.val21.i.i255.i693.i982, i32 %sel20.i.i254.i692.i981, 1
  br label %lpad8.body.i348.i786.i1075

unreachable.i60.i258.i696.i985:                   ; preds = %lpad4.i58.i250.i688.i977, %lpad.i56.i245.i683.i972
  unreachable

det.cont.i263.i701.i990:                          ; preds = %invoke.cont.i156.i594.i883
  %730 = load %class.object.0*, %class.object.0** %other.addr.i148.i318.i40, align 8
  %b21.i259.i697.i986 = getelementptr inbounds %class.object.0, %class.object.0* %730, i32 0, i32 1
  %savedstack116.i260.i698.i987 = call i8* @llvm.stacksave()
  store %class.object.1* %agg.tmp20.i152.i321.i43, %class.object.1** %this.addr.i65.i141.i312.i34, align 8
  store %class.object.1* %b21.i259.i697.i986, %class.object.1** %other.addr.i66.i142.i313.i35, align 8
  %this1.i71.i261.i699.i988 = load %class.object.1*, %class.object.1** %this.addr.i65.i141.i312.i34, align 8
  %a.i72.i262.i700.i989 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i699.i988, i32 0, i32 0
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %a.i72.i262.i700.i989)
          to label %.noexc117.i265.i703.i992 unwind label %lpad19.i359.i797.i1086

.noexc117.i265.i703.i992:                         ; preds = %det.cont.i263.i701.i990
  %b.i73.i264.i702.i991 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i699.i988, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1Ev(%class.object.2* %b.i73.i264.i702.i991)
          to label %invoke.cont.i79.i266.i704.i993 unwind label %lpad.i93.i285.i723.i1012

invoke.cont.i79.i266.i704.i993:                   ; preds = %.noexc117.i265.i703.i992
  %731 = call token @llvm.taskframe.create()
  %agg.tmp.i74.i267.i705.i994 = alloca %class.object.2, align 1
  %exn.slot12.i75.i268.i706.i995 = alloca i8*
  %ehselector.slot13.i76.i269.i707.i996 = alloca i32
  %a2.i77.i270.i708.i997 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i699.i988, i32 0, i32 0
  %732 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i313.i35, align 8
  %a3.i78.i271.i709.i998 = getelementptr inbounds %class.object.1, %class.object.1* %732, i32 0, i32 0
  detach within %syncreg.i69.i146.i323.i53, label %det.achd.i82.i274.i712.i1001, label %det.cont.i87.i279.i717.i1006 unwind label %lpad11.i101.i297.i735.i1024

det.achd.i82.i274.i712.i1001:                     ; preds = %invoke.cont.i79.i266.i704.i993
  %exn.slot5.i80.i272.i710.i999 = alloca i8*
  %ehselector.slot6.i81.i273.i711.i1000 = alloca i32
  call void @llvm.taskframe.use(token %731)
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i74.i267.i705.i994, %class.object.2* dereferenceable(1) %a3.i78.i271.i709.i998)
          to label %invoke.cont7.i84.i276.i714.i1003 unwind label %lpad4.i94.i286.i724.i1013

invoke.cont7.i84.i276.i714.i1003:                 ; preds = %det.achd.i82.i274.i712.i1001
  %call.i83.i275.i713.i1002 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a2.i77.i270.i708.i997, %class.object.2* %agg.tmp.i74.i267.i705.i994)
          to label %invoke.cont9.i85.i277.i715.i1004 unwind label %lpad8.i95.i287.i725.i1014

invoke.cont9.i85.i277.i715.i1004:                 ; preds = %invoke.cont7.i84.i276.i714.i1003
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i705.i994) #7
  reattach within %syncreg.i69.i146.i323.i53, label %det.cont.i87.i279.i717.i1006

det.cont.i87.i279.i717.i1006:                     ; preds = %invoke.cont9.i85.i277.i715.i1004, %invoke.cont.i79.i266.i704.i993
  %733 = load %class.object.1*, %class.object.1** %other.addr.i66.i142.i313.i35, align 8
  %b21.i86.i278.i716.i1005 = getelementptr inbounds %class.object.1, %class.object.1* %733, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp20.i70.i145.i316.i38, %class.object.2* dereferenceable(1) %b21.i86.i278.i716.i1005)
          to label %invoke.cont22.i90.i282.i720.i1009 unwind label %lpad19.i106.i298.i736.i1025

invoke.cont22.i90.i282.i720.i1009:                ; preds = %det.cont.i87.i279.i717.i1006
  %b23.i88.i280.i718.i1007 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i71.i261.i699.i988, i32 0, i32 1
  %call26.i89.i281.i719.i1008 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b23.i88.i280.i718.i1007, %class.object.2* %agg.tmp20.i70.i145.i316.i38)
          to label %invoke.cont25.i91.i283.i721.i1010 unwind label %lpad24.i107.i299.i737.i1026

invoke.cont25.i91.i283.i721.i1010:                ; preds = %invoke.cont22.i90.i282.i720.i1009
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i316.i38) #7
  sync within %syncreg.i69.i146.i323.i53, label %sync.continue.i92.i284.i722.i1011

sync.continue.i92.i284.i722.i1011:                ; preds = %invoke.cont25.i91.i283.i721.i1010
  invoke void @llvm.sync.unwind(token %syncreg.i69.i146.i323.i53)
          to label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i1037 unwind label %lpad19.i359.i797.i1086

lpad.i93.i285.i723.i1012:                         ; preds = %.noexc117.i265.i703.i992
  %734 = landingpad { i8*, i32 }
          cleanup
  %735 = extractvalue { i8*, i32 } %734, 0
  store i8* %735, i8** %exn.slot.i67.i143.i314.i36, align 8
  %736 = extractvalue { i8*, i32 } %734, 1
  store i32 %736, i32* %ehselector.slot.i68.i144.i315.i37, align 4
  br label %ehcleanup29.i109.i305.i743.i1032

lpad4.i94.i286.i724.i1013:                        ; preds = %det.achd.i82.i274.i712.i1001
  %737 = landingpad { i8*, i32 }
          cleanup
  %738 = extractvalue { i8*, i32 } %737, 0
  store i8* %738, i8** %exn.slot5.i80.i272.i710.i999, align 8
  %739 = extractvalue { i8*, i32 } %737, 1
  store i32 %739, i32* %ehselector.slot6.i81.i273.i711.i1000, align 4
  br label %ehcleanup.i100.i292.i730.i1019

lpad8.i95.i287.i725.i1014:                        ; preds = %invoke.cont7.i84.i276.i714.i1003
  %740 = landingpad { i8*, i32 }
          cleanup
  %741 = extractvalue { i8*, i32 } %740, 0
  store i8* %741, i8** %exn.slot5.i80.i272.i710.i999, align 8
  %742 = extractvalue { i8*, i32 } %740, 1
  store i32 %742, i32* %ehselector.slot6.i81.i273.i711.i1000, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i74.i267.i705.i994) #7
  br label %ehcleanup.i100.i292.i730.i1019

ehcleanup.i100.i292.i730.i1019:                   ; preds = %lpad8.i95.i287.i725.i1014, %lpad4.i94.i286.i724.i1013
  %exn.i96.i288.i726.i1015 = load i8*, i8** %exn.slot5.i80.i272.i710.i999, align 8
  %sel.i97.i289.i727.i1016 = load i32, i32* %ehselector.slot6.i81.i273.i711.i1000, align 4
  %lpad.val.i98.i290.i728.i1017 = insertvalue { i8*, i32 } undef, i8* %exn.i96.i288.i726.i1015, 0
  %lpad.val10.i99.i291.i729.i1018 = insertvalue { i8*, i32 } %lpad.val.i98.i290.i728.i1017, i32 %sel.i97.i289.i727.i1016, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i69.i146.i323.i53, { i8*, i32 } %lpad.val10.i99.i291.i729.i1018)
          to label %unreachable.i115.i306.i744.i1033 unwind label %lpad11.i101.i297.i735.i1024

lpad11.i101.i297.i735.i1024:                      ; preds = %ehcleanup.i100.i292.i730.i1019, %invoke.cont.i79.i266.i704.i993
  %743 = landingpad { i8*, i32 }
          cleanup
  %744 = extractvalue { i8*, i32 } %743, 0
  store i8* %744, i8** %exn.slot12.i75.i268.i706.i995, align 8
  %745 = extractvalue { i8*, i32 } %743, 1
  store i32 %745, i32* %ehselector.slot13.i76.i269.i707.i996, align 4
  %exn15.i102.i293.i731.i1020 = load i8*, i8** %exn.slot12.i75.i268.i706.i995, align 8
  %sel16.i103.i294.i732.i1021 = load i32, i32* %ehselector.slot13.i76.i269.i707.i996, align 4
  %lpad.val17.i104.i295.i733.i1022 = insertvalue { i8*, i32 } undef, i8* %exn15.i102.i293.i731.i1020, 0
  %lpad.val18.i105.i296.i734.i1023 = insertvalue { i8*, i32 } %lpad.val17.i104.i295.i733.i1022, i32 %sel16.i103.i294.i732.i1021, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %731, { i8*, i32 } %lpad.val18.i105.i296.i734.i1023)
          to label %unreachable.i115.i306.i744.i1033 unwind label %lpad19.i106.i298.i736.i1025

lpad19.i106.i298.i736.i1025:                      ; preds = %lpad11.i101.i297.i735.i1024, %det.cont.i87.i279.i717.i1006
  %746 = landingpad { i8*, i32 }
          cleanup
  %747 = extractvalue { i8*, i32 } %746, 0
  store i8* %747, i8** %exn.slot.i67.i143.i314.i36, align 8
  %748 = extractvalue { i8*, i32 } %746, 1
  store i32 %748, i32* %ehselector.slot.i68.i144.i315.i37, align 4
  br label %ehcleanup28.i108.i300.i738.i1027

lpad24.i107.i299.i737.i1026:                      ; preds = %invoke.cont22.i90.i282.i720.i1009
  %749 = landingpad { i8*, i32 }
          cleanup
  %750 = extractvalue { i8*, i32 } %749, 0
  store i8* %750, i8** %exn.slot.i67.i143.i314.i36, align 8
  %751 = extractvalue { i8*, i32 } %749, 1
  store i32 %751, i32* %ehselector.slot.i68.i144.i315.i37, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp20.i70.i145.i316.i38) #7
  br label %ehcleanup28.i108.i300.i738.i1027

ehcleanup28.i108.i300.i738.i1027:                 ; preds = %lpad24.i107.i299.i737.i1026, %lpad19.i106.i298.i736.i1025
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %b.i73.i264.i702.i991) #7
  br label %ehcleanup29.i109.i305.i743.i1032

ehcleanup29.i109.i305.i743.i1032:                 ; preds = %ehcleanup28.i108.i300.i738.i1027, %lpad.i93.i285.i723.i1012
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %a.i72.i262.i700.i989) #7
  %exn30.i110.i301.i739.i1028 = load i8*, i8** %exn.slot.i67.i143.i314.i36, align 8
  %sel31.i111.i302.i740.i1029 = load i32, i32* %ehselector.slot.i68.i144.i315.i37, align 4
  %lpad.val32.i112.i303.i741.i1030 = insertvalue { i8*, i32 } undef, i8* %exn30.i110.i301.i739.i1028, 0
  %lpad.val33.i113.i304.i742.i1031 = insertvalue { i8*, i32 } %lpad.val32.i112.i303.i741.i1030, i32 %sel31.i111.i302.i740.i1029, 1
  br label %lpad19.body.i361.i799.i1088

unreachable.i115.i306.i744.i1033:                 ; preds = %lpad11.i101.i297.i735.i1024, %ehcleanup.i100.i292.i730.i1019
  unreachable

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i1037: ; preds = %sync.continue.i92.i284.i722.i1011
  call void @llvm.stackrestore(i8* %savedstack116.i260.i698.i987)
  %b23.i308.i745.i1034 = getelementptr inbounds %class.object.0, %class.object.0* %this1.i153.i589.i878, i32 0, i32 1
  %savedstack161.i309.i746.i1035 = call i8* @llvm.stacksave()
  store %class.object.1* %b23.i308.i745.i1034, %class.object.1** %this.addr.i122.i133.i305.i27, align 8
  %this1.i127.i310.i747.i1036 = load %class.object.1*, %class.object.1** %this.addr.i122.i133.i305.i27, align 8
  br label %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i1037.split

_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i1037.split: ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i1037
  %752 = call token @llvm.taskframe.create()
  %a.i131.i311.i749.i1038 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i747.i1036, i32 0, i32 0
  %a2.i132.i312.i750.i1039 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i321.i43, i32 0, i32 0
  detach within %syncreg.i123.i140.i322.i52, label %det.achd.i136.i316.i754.i1043, label %det.cont.i141.i319.i757.i1046 unwind label %lpad4.i152.i333.i771.i1060

det.achd.i136.i316.i754.i1043:                    ; preds = %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i1037.split
  %exn.slot.i133.i313.i751.i1040 = alloca i8*
  %ehselector.slot.i134.i314.i752.i1041 = alloca i32
  call void @llvm.taskframe.use(token %752)
  call void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp.i128.i137.i309.i31, %class.object.2* dereferenceable(1) %a2.i132.i312.i750.i1039)
  %call.i135.i315.i753.i1042 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %a.i131.i311.i749.i1038, %class.object.2* %agg.tmp.i128.i137.i309.i31)
          to label %invoke.cont.i137.i317.i755.i1044 unwind label %lpad.i147.i328.i766.i1055

invoke.cont.i137.i317.i755.i1044:                 ; preds = %det.achd.i136.i316.i754.i1043
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i309.i31) #7
  reattach within %syncreg.i123.i140.i322.i52, label %det.cont.i141.i319.i757.i1046

det.cont.i141.i319.i757.i1046:                    ; preds = %invoke.cont.i137.i317.i755.i1044, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i1037.split
  %b.i138.i318.i756.i1045 = getelementptr inbounds %class.object.1, %class.object.1* %agg.tmp20.i152.i321.i43, i32 0, i32 1
  invoke void @_ZN6objectILi0EEC1ERKS0_(%class.object.2* %agg.tmp14.i126.i136.i308.i30, %class.object.2* dereferenceable(1) %b.i138.i318.i756.i1045)
          to label %.noexc164.i322.i760.i1049 unwind label %lpad24.i362.i800.i1089

.noexc164.i322.i760.i1049:                        ; preds = %det.cont.i141.i319.i757.i1046
  %b15.i139.i320.i758.i1047 = getelementptr inbounds %class.object.1, %class.object.1* %this1.i127.i310.i747.i1036, i32 0, i32 1
  %call18.i140.i321.i759.i1048 = invoke dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2* %b15.i139.i320.i758.i1047, %class.object.2* %agg.tmp14.i126.i136.i308.i30)
          to label %invoke.cont17.i142.i323.i761.i1050 unwind label %lpad16.i154.i335.i773.i1062

invoke.cont17.i142.i323.i761.i1050:               ; preds = %.noexc164.i322.i760.i1049
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i308.i30) #7
  call void @llvm.trap()
  unreachable

lpad.i147.i328.i766.i1055:                        ; preds = %det.achd.i136.i316.i754.i1043
  %753 = landingpad { i8*, i32 }
          cleanup
  %754 = extractvalue { i8*, i32 } %753, 0
  store i8* %754, i8** %exn.slot.i133.i313.i751.i1040, align 8
  %755 = extractvalue { i8*, i32 } %753, 1
  store i32 %755, i32* %ehselector.slot.i134.i314.i752.i1041, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp.i128.i137.i309.i31) #7
  %exn.i143.i324.i762.i1051 = load i8*, i8** %exn.slot.i133.i313.i751.i1040, align 8
  %sel.i144.i325.i763.i1052 = load i32, i32* %ehselector.slot.i134.i314.i752.i1041, align 4
  %lpad.val.i145.i326.i764.i1053 = insertvalue { i8*, i32 } undef, i8* %exn.i143.i324.i762.i1051, 0
  %lpad.val3.i146.i327.i765.i1054 = insertvalue { i8*, i32 } %lpad.val.i145.i326.i764.i1053, i32 %sel.i144.i325.i763.i1052, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i123.i140.i322.i52, { i8*, i32 } %lpad.val3.i146.i327.i765.i1054)
          to label %unreachable.i160.i341.i779.i1068 unwind label %lpad4.i152.i333.i771.i1060

lpad4.i152.i333.i771.i1060:                       ; preds = %lpad.i147.i328.i766.i1055, %_ZN6objectILi1EEC2ERKS0_.exit121.i307.i748.i1037.split
  %756 = landingpad { i8*, i32 }
          cleanup
  %757 = extractvalue { i8*, i32 } %756, 0
  store i8* %757, i8** %exn.slot5.i129.i138.i310.i32, align 8
  %758 = extractvalue { i8*, i32 } %756, 1
  store i32 %758, i32* %ehselector.slot6.i130.i139.i311.i33, align 4
  %exn7.i148.i329.i767.i1056 = load i8*, i8** %exn.slot5.i129.i138.i310.i32, align 8
  %sel8.i149.i330.i768.i1057 = load i32, i32* %ehselector.slot6.i130.i139.i311.i33, align 4
  %lpad.val9.i150.i331.i769.i1058 = insertvalue { i8*, i32 } undef, i8* %exn7.i148.i329.i767.i1056, 0
  %lpad.val10.i151.i332.i770.i1059 = insertvalue { i8*, i32 } %lpad.val9.i150.i331.i769.i1058, i32 %sel8.i149.i330.i768.i1057, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %752, { i8*, i32 } %lpad.val10.i151.i332.i770.i1059)
          to label %unreachable.i160.i341.i779.i1068 unwind label %lpad11.i153.i334.i772.i1061

lpad11.i153.i334.i772.i1061:                      ; preds = %lpad4.i152.i333.i771.i1060
  %759 = landingpad { i8*, i32 }
          cleanup
  %760 = extractvalue { i8*, i32 } %759, 0
  store i8* %760, i8** %exn.slot12.i124.i134.i306.i28, align 8
  %761 = extractvalue { i8*, i32 } %759, 1
  store i32 %761, i32* %ehselector.slot13.i125.i135.i307.i29, align 4
  br label %eh.resume.i159.i340.i778.i1067

lpad16.i154.i335.i773.i1062:                      ; preds = %.noexc164.i322.i760.i1049
  %762 = landingpad { i8*, i32 }
          cleanup
  %763 = extractvalue { i8*, i32 } %762, 0
  store i8* %763, i8** %exn.slot12.i124.i134.i306.i28, align 8
  %764 = extractvalue { i8*, i32 } %762, 1
  store i32 %764, i32* %ehselector.slot13.i125.i135.i307.i29, align 4
  call void @_ZN6objectILi0EED1Ev(%class.object.2* %agg.tmp14.i126.i136.i308.i30) #7
  br label %eh.resume.i159.i340.i778.i1067

eh.resume.i159.i340.i778.i1067:                   ; preds = %lpad16.i154.i335.i773.i1062, %lpad11.i153.i334.i772.i1061
  %exn19.i155.i336.i774.i1063 = load i8*, i8** %exn.slot12.i124.i134.i306.i28, align 8
  %sel20.i156.i337.i775.i1064 = load i32, i32* %ehselector.slot13.i125.i135.i307.i29, align 4
  %lpad.val21.i157.i338.i776.i1065 = insertvalue { i8*, i32 } undef, i8* %exn19.i155.i336.i774.i1063, 0
  %lpad.val22.i158.i339.i777.i1066 = insertvalue { i8*, i32 } %lpad.val21.i157.i338.i776.i1065, i32 %sel20.i156.i337.i775.i1064, 1
  br label %lpad24.body.i364.i802.i1091

unreachable.i160.i341.i779.i1068:                 ; preds = %lpad4.i152.i333.i771.i1060, %lpad.i147.i328.i766.i1055
  unreachable

lpad.i342.i780.i1069:                             ; preds = %.noexc374.i593.i882
  %765 = landingpad { i8*, i32 }
          cleanup
  %766 = extractvalue { i8*, i32 } %765, 0
  store i8* %766, i8** %exn.slot.i149.i319.i41, align 8
  %767 = extractvalue { i8*, i32 } %765, 1
  store i32 %767, i32* %ehselector.slot.i150.i320.i42, align 4
  br label %ehcleanup29.i366.i808.i1097

lpad4.i343.i781.i1070:                            ; preds = %sync.continue.i.i202.i640.i929, %det.achd.i181.i619.i908
  %768 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i345.i783.i1072

lpad4.body.i345.i783.i1072:                       ; preds = %lpad4.i343.i781.i1070, %ehcleanup29.i.i223.i661.i950
  %eh.lpad-body.i344.i782.i1071 = phi { i8*, i32 } [ %768, %lpad4.i343.i781.i1070 ], [ %lpad.val33.i.i222.i660.i949, %ehcleanup29.i.i223.i661.i950 ]
  %769 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i782.i1071, 0
  store i8* %769, i8** %exn.slot5.i176.i614.i903, align 8
  %770 = extractvalue { i8*, i32 } %eh.lpad-body.i344.i782.i1071, 1
  store i32 %770, i32* %ehselector.slot6.i177.i615.i904, align 4
  br label %ehcleanup.i353.i791.i1080

lpad8.i346.i784.i1073:                            ; preds = %det.cont.i52.i236.i674.i963
  %771 = landingpad { i8*, i32 }
          cleanup
  br label %lpad8.body.i348.i786.i1075

lpad8.body.i348.i786.i1075:                       ; preds = %lpad8.i346.i784.i1073, %eh.resume.i.i257.i695.i984
  %eh.lpad-body64.i347.i785.i1074 = phi { i8*, i32 } [ %771, %lpad8.i346.i784.i1073 ], [ %lpad.val22.i.i256.i694.i983, %eh.resume.i.i257.i695.i984 ]
  %772 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i785.i1074, 0
  store i8* %772, i8** %exn.slot5.i176.i614.i903, align 8
  %773 = extractvalue { i8*, i32 } %eh.lpad-body64.i347.i785.i1074, 1
  store i32 %773, i32* %ehselector.slot6.i177.i615.i904, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp.i157.i595.i884) #7
  br label %ehcleanup.i353.i791.i1080

ehcleanup.i353.i791.i1080:                        ; preds = %lpad8.body.i348.i786.i1075, %lpad4.body.i345.i783.i1072
  %exn.i349.i787.i1076 = load i8*, i8** %exn.slot5.i176.i614.i903, align 8
  %sel.i350.i788.i1077 = load i32, i32* %ehselector.slot6.i177.i615.i904, align 4
  %lpad.val.i351.i789.i1078 = insertvalue { i8*, i32 } undef, i8* %exn.i349.i787.i1076, 0
  %lpad.val10.i352.i790.i1079 = insertvalue { i8*, i32 } %lpad.val.i351.i789.i1078, i32 %sel.i350.i788.i1077, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i151.i324.i54, { i8*, i32 } %lpad.val10.i352.i790.i1079)
          to label %unreachable.i372.i809.i1098 unwind label %lpad11.i354.i796.i1085

lpad11.i354.i796.i1085:                           ; preds = %ehcleanup.i353.i791.i1080, %invoke.cont.i156.i594.i883
  %774 = landingpad { i8*, i32 }
          cleanup
  %775 = extractvalue { i8*, i32 } %774, 0
  store i8* %775, i8** %exn.slot12.i158.i596.i885, align 8
  %776 = extractvalue { i8*, i32 } %774, 1
  store i32 %776, i32* %ehselector.slot13.i159.i597.i886, align 4
  %exn15.i355.i792.i1081 = load i8*, i8** %exn.slot12.i158.i596.i885, align 8
  %sel16.i356.i793.i1082 = load i32, i32* %ehselector.slot13.i159.i597.i886, align 4
  %lpad.val17.i357.i794.i1083 = insertvalue { i8*, i32 } undef, i8* %exn15.i355.i792.i1081, 0
  %lpad.val18.i358.i795.i1084 = insertvalue { i8*, i32 } %lpad.val17.i357.i794.i1083, i32 %sel16.i356.i793.i1082, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %694, { i8*, i32 } %lpad.val18.i358.i795.i1084)
          to label %unreachable.i372.i809.i1098 unwind label %lpad19.i359.i797.i1086

lpad19.i359.i797.i1086:                           ; preds = %lpad11.i354.i796.i1085, %sync.continue.i92.i284.i722.i1011, %det.cont.i263.i701.i990
  %777 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i361.i799.i1088

lpad19.body.i361.i799.i1088:                      ; preds = %lpad19.i359.i797.i1086, %ehcleanup29.i109.i305.i743.i1032
  %eh.lpad-body118.i360.i798.i1087 = phi { i8*, i32 } [ %777, %lpad19.i359.i797.i1086 ], [ %lpad.val33.i113.i304.i742.i1031, %ehcleanup29.i109.i305.i743.i1032 ]
  %778 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i798.i1087, 0
  store i8* %778, i8** %exn.slot.i149.i319.i41, align 8
  %779 = extractvalue { i8*, i32 } %eh.lpad-body118.i360.i798.i1087, 1
  store i32 %779, i32* %ehselector.slot.i150.i320.i42, align 4
  br label %ehcleanup28.i365.i803.i1092

lpad24.i362.i800.i1089:                           ; preds = %det.cont.i141.i319.i757.i1046
  %780 = landingpad { i8*, i32 }
          cleanup
  br label %lpad24.body.i364.i802.i1091

lpad24.body.i364.i802.i1091:                      ; preds = %lpad24.i362.i800.i1089, %eh.resume.i159.i340.i778.i1067
  %eh.lpad-body165.i363.i801.i1090 = phi { i8*, i32 } [ %780, %lpad24.i362.i800.i1089 ], [ %lpad.val22.i158.i339.i777.i1066, %eh.resume.i159.i340.i778.i1067 ]
  %781 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i801.i1090, 0
  store i8* %781, i8** %exn.slot.i149.i319.i41, align 8
  %782 = extractvalue { i8*, i32 } %eh.lpad-body165.i363.i801.i1090, 1
  store i32 %782, i32* %ehselector.slot.i150.i320.i42, align 4
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %agg.tmp20.i152.i321.i43) #7
  br label %ehcleanup28.i365.i803.i1092

ehcleanup28.i365.i803.i1092:                      ; preds = %lpad24.body.i364.i802.i1091, %lpad19.body.i361.i799.i1088
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %b.i155.i592.i881) #7
  br label %ehcleanup29.i366.i808.i1097

ehcleanup29.i366.i808.i1097:                      ; preds = %ehcleanup28.i365.i803.i1092, %lpad.i342.i780.i1069
  call void @_ZN6objectILi1EED1Ev(%class.object.1* %a.i154.i590.i879) #7
  %exn30.i367.i804.i1093 = load i8*, i8** %exn.slot.i149.i319.i41, align 8
  %sel31.i368.i805.i1094 = load i32, i32* %ehselector.slot.i150.i320.i42, align 4
  %lpad.val32.i369.i806.i1095 = insertvalue { i8*, i32 } undef, i8* %exn30.i367.i804.i1093, 0
  %lpad.val33.i370.i807.i1096 = insertvalue { i8*, i32 } %lpad.val32.i369.i806.i1095, i32 %sel31.i368.i805.i1094, 1
  br label %lpad19.body.i825.i1114

unreachable.i372.i809.i1098:                      ; preds = %lpad11.i354.i796.i1085, %ehcleanup.i353.i791.i1080
  unreachable

lpad.i810.i1099:                                  ; preds = %.noexc833.i625
  %783 = landingpad { i8*, i32 }
          cleanup
  %784 = extractvalue { i8*, i32 } %783, 0
  store i8* %784, i8** %exn.slot.i330.i46, align 8
  %785 = extractvalue { i8*, i32 } %783, 1
  store i32 %785, i32* %ehselector.slot.i331.i47, align 4
  br label %ehcleanup29.i826.i1119

lpad4.i811.i1100:                                 ; preds = %det.achd.i368.i657
  %786 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i813.i1106

lpad4.body.i813.i1106:                            ; preds = %lpad4.i811.i1100, %ehcleanup29.i.i585.i874
  %eh.lpad-body.i812.i1101 = phi { i8*, i32 } [ %786, %lpad4.i811.i1100 ], [ %lpad.val33.i.i584.i873, %ehcleanup29.i.i585.i874 ]
  %787 = extractvalue { i8*, i32 } %eh.lpad-body.i812.i1101, 0
  store i8* %787, i8** %exn.slot5.i363.i652, align 8
  %788 = extractvalue { i8*, i32 } %eh.lpad-body.i812.i1101, 1
  store i32 %788, i32* %ehselector.slot6.i364.i653, align 4
  %exn.i814.i1102 = load i8*, i8** %exn.slot5.i363.i652, align 8
  %sel.i815.i1103 = load i32, i32* %ehselector.slot6.i364.i653, align 4
  %lpad.val.i816.i1104 = insertvalue { i8*, i32 } undef, i8* %exn.i814.i1102, 0
  %lpad.val10.i817.i1105 = insertvalue { i8*, i32 } %lpad.val.i816.i1104, i32 %sel.i815.i1103, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i332.i58, { i8*, i32 } %lpad.val10.i817.i1105)
          to label %unreachable.i831.i1120 unwind label %lpad11.i818.i1111

lpad11.i818.i1111:                                ; preds = %lpad4.body.i813.i1106, %invoke.cont.i337.i626
  %789 = landingpad { i8*, i32 }
          cleanup
  %790 = extractvalue { i8*, i32 } %789, 0
  store i8* %790, i8** %exn.slot12.i339.i628, align 8
  %791 = extractvalue { i8*, i32 } %789, 1
  store i32 %791, i32* %ehselector.slot13.i340.i629, align 4
  %exn15.i819.i1107 = load i8*, i8** %exn.slot12.i339.i628, align 8
  %sel16.i820.i1108 = load i32, i32* %ehselector.slot13.i340.i629, align 4
  %lpad.val17.i821.i1109 = insertvalue { i8*, i32 } undef, i8* %exn15.i819.i1107, 0
  %lpad.val18.i822.i1110 = insertvalue { i8*, i32 } %lpad.val17.i821.i1109, i32 %sel16.i820.i1108, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %602, { i8*, i32 } %lpad.val18.i822.i1110)
          to label %unreachable.i831.i1120 unwind label %lpad19.i823.i1112

lpad19.i823.i1112:                                ; preds = %lpad11.i818.i1111, %det.cont.i591.i880
  %792 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i825.i1114

lpad19.body.i825.i1114:                           ; preds = %lpad19.i823.i1112, %ehcleanup29.i366.i808.i1097
  %eh.lpad-body375.i824.i1113 = phi { i8*, i32 } [ %792, %lpad19.i823.i1112 ], [ %lpad.val33.i370.i807.i1096, %ehcleanup29.i366.i808.i1097 ]
  %793 = extractvalue { i8*, i32 } %eh.lpad-body375.i824.i1113, 0
  store i8* %793, i8** %exn.slot.i330.i46, align 8
  %794 = extractvalue { i8*, i32 } %eh.lpad-body375.i824.i1113, 1
  store i32 %794, i32* %ehselector.slot.i331.i47, align 4
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %b.i336.i624) #7
  br label %ehcleanup29.i826.i1119

ehcleanup29.i826.i1119:                           ; preds = %lpad19.body.i825.i1114, %lpad.i810.i1099
  call void @_ZN6objectILi2EED1Ev(%class.object.0* %a.i335.i622) #7
  %exn30.i827.i1115 = load i8*, i8** %exn.slot.i330.i46, align 8
  %sel31.i828.i1116 = load i32, i32* %ehselector.slot.i331.i47, align 4
  %lpad.val32.i829.i1117 = insertvalue { i8*, i32 } undef, i8* %exn30.i827.i1115, 0
  %lpad.val33.i830.i1118 = insertvalue { i8*, i32 } %lpad.val32.i829.i1117, i32 %sel31.i828.i1116, 1
  br label %lpad19.body.i1136

unreachable.i831.i1120:                           ; preds = %lpad11.i818.i1111, %lpad4.body.i813.i1106
  unreachable

lpad.i1121:                                       ; preds = %.noexc1144
  %795 = landingpad { i8*, i32 }
          cleanup
  %796 = extractvalue { i8*, i32 } %795, 0
  store i8* %796, i8** %exn.slot.i71, align 8
  %797 = extractvalue { i8*, i32 } %795, 1
  store i32 %797, i32* %ehselector.slot.i72, align 4
  br label %ehcleanup29.i1137

lpad4.i1122:                                      ; preds = %det.achd.i121
  %798 = landingpad { i8*, i32 }
          cleanup
  br label %lpad4.body.i1124

lpad4.body.i1124:                                 ; preds = %lpad4.i1122, %ehcleanup29.i.i617
  %eh.lpad-body.i1123 = phi { i8*, i32 } [ %798, %lpad4.i1122 ], [ %lpad.val33.i.i616, %ehcleanup29.i.i617 ]
  %799 = extractvalue { i8*, i32 } %eh.lpad-body.i1123, 0
  store i8* %799, i8** %exn.slot5.i116, align 8
  %800 = extractvalue { i8*, i32 } %eh.lpad-body.i1123, 1
  store i32 %800, i32* %ehselector.slot6.i117, align 4
  %exn.i1125 = load i8*, i8** %exn.slot5.i116, align 8
  %sel.i1126 = load i32, i32* %ehselector.slot6.i117, align 4
  %lpad.val.i1127 = insertvalue { i8*, i32 } undef, i8* %exn.i1125, 0
  %lpad.val10.i1128 = insertvalue { i8*, i32 } %lpad.val.i1127, i32 %sel.i1126, 1
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i73, { i8*, i32 } %lpad.val10.i1128)
          to label %unreachable.i1142 unwind label %lpad11.i1129

lpad11.i1129:                                     ; preds = %lpad4.body.i1124, %invoke.cont.i78
  %801 = landingpad { i8*, i32 }
          cleanup
  %802 = extractvalue { i8*, i32 } %801, 0
  store i8* %802, i8** %exn.slot12.i80, align 8
  %803 = extractvalue { i8*, i32 } %801, 1
  store i32 %803, i32* %ehselector.slot13.i81, align 4
  %exn15.i1130 = load i8*, i8** %exn.slot12.i80, align 8
  %sel16.i1131 = load i32, i32* %ehselector.slot13.i81, align 4
  %lpad.val17.i1132 = insertvalue { i8*, i32 } undef, i8* %exn15.i1130, 0
  %lpad.val18.i1133 = insertvalue { i8*, i32 } %lpad.val17.i1132, i32 %sel16.i1131, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %406, { i8*, i32 } %lpad.val18.i1133)
          to label %unreachable.i1142 unwind label %lpad19.i1134

lpad19.i1134:                                     ; preds = %lpad11.i1129, %det.cont.i623
  %804 = landingpad { i8*, i32 }
          cleanup
  br label %lpad19.body.i1136

lpad19.body.i1136:                                ; preds = %lpad19.i1134, %ehcleanup29.i826.i1119
  %eh.lpad-body834.i1135 = phi { i8*, i32 } [ %804, %lpad19.i1134 ], [ %lpad.val33.i830.i1118, %ehcleanup29.i826.i1119 ]
  %805 = extractvalue { i8*, i32 } %eh.lpad-body834.i1135, 0
  store i8* %805, i8** %exn.slot.i71, align 8
  %806 = extractvalue { i8*, i32 } %eh.lpad-body834.i1135, 1
  store i32 %806, i32* %ehselector.slot.i72, align 4
  call void @_ZN6objectILi3EED1Ev(%class.object* %b.i77) #7
  br label %ehcleanup29.i1137

ehcleanup29.i1137:                                ; preds = %lpad19.body.i1136, %lpad.i1121
  call void @_ZN6objectILi3EED1Ev(%class.object* %a.i76) #7
  %exn30.i1138 = load i8*, i8** %exn.slot.i71, align 8
  %sel31.i1139 = load i32, i32* %ehselector.slot.i72, align 4
  %lpad.val32.i1140 = insertvalue { i8*, i32 } undef, i8* %exn30.i1138, 0
  %lpad.val33.i1141 = insertvalue { i8*, i32 } %lpad.val32.i1140, i32 %sel31.i1139, 1
  br label %lpad1.body

unreachable.i1142:                                ; preds = %lpad11.i1129, %lpad4.body.i1124
  unreachable

_ZN6objectILi4EEC2ERKS0_.exit1151:                ; No predecessors!
  br label %invoke.cont4

invoke.cont4:                                     ; preds = %_ZN6objectILi4EEC2ERKS0_.exit1151
  invoke void @_Z6child2ILi4EEv6objectIXT_EEllS1_(%class.object.3* %agg.tmp, i64 %add, i64 %call, %class.object.3* %agg.tmp3)
          to label %invoke.cont6 unwind label %lpad5

invoke.cont6:                                     ; preds = %invoke.cont4
  call void @_ZN6objectILi4EED1Ev(%class.object.3* %agg.tmp3) #7
  call void @_ZN6objectILi4EED1Ev(%class.object.3* %agg.tmp) #7
  invoke void @_ZN6objectILi4EE6updateEv(%class.object.3* %obj)
          to label %invoke.cont7 unwind label %lpad

invoke.cont7:                                     ; preds = %invoke.cont6
  br label %for.inc

for.inc:                                          ; preds = %invoke.cont7
  %807 = load i64, i64* %i, align 8
  %inc = add nsw i64 %807, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

lpad:                                             ; preds = %for.body, %sync.continue, %invoke.cont6
  %808 = landingpad { i8*, i32 }
          cleanup
  br label %lpad.body

lpad.body:                                        ; preds = %ehcleanup29.i, %lpad
  %eh.lpad-body = phi { i8*, i32 } [ %808, %lpad ], [ %lpad.val33.i, %ehcleanup29.i ]
  %809 = extractvalue { i8*, i32 } %eh.lpad-body, 0
  store i8* %809, i8** %exn.slot, align 8
  %810 = extractvalue { i8*, i32 } %eh.lpad-body, 1
  store i32 %810, i32* %ehselector.slot, align 4
  br label %ehcleanup10

lpad1:                                            ; preds = %invoke.cont2, %invoke.cont
  %811 = landingpad { i8*, i32 }
          cleanup
  br label %lpad1.body

lpad1.body:                                       ; preds = %ehcleanup29.i1137, %lpad1
  %eh.lpad-body1145 = phi { i8*, i32 } [ %811, %lpad1 ], [ %lpad.val33.i1141, %ehcleanup29.i1137 ]
  %812 = extractvalue { i8*, i32 } %eh.lpad-body1145, 0
  store i8* %812, i8** %exn.slot, align 8
  %813 = extractvalue { i8*, i32 } %eh.lpad-body1145, 1
  store i32 %813, i32* %ehselector.slot, align 4
  br label %ehcleanup

lpad5:                                            ; preds = %invoke.cont4
  %814 = landingpad { i8*, i32 }
          cleanup
  %815 = extractvalue { i8*, i32 } %814, 0
  store i8* %815, i8** %exn.slot, align 8
  %816 = extractvalue { i8*, i32 } %814, 1
  store i32 %816, i32* %ehselector.slot, align 4
  call void @_ZN6objectILi4EED1Ev(%class.object.3* %agg.tmp3) #7
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad5, %lpad1.body
  call void @_ZN6objectILi4EED1Ev(%class.object.3* %agg.tmp) #7
  br label %ehcleanup10

for.end:                                          ; preds = %for.cond
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %for.end
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %invoke.cont8 unwind label %lpad

invoke.cont8:                                     ; preds = %sync.continue
  sync within %syncreg, label %sync.continue9

sync.continue9:                                   ; preds = %invoke.cont8
  call void @llvm.sync.unwind(token %syncreg)
  call void @_ZN6objectILi4EED1Ev(%class.object.3* %obj) #7
  ret void

ehcleanup10:                                      ; preds = %ehcleanup, %lpad.body
  call void @_ZN6objectILi4EED1Ev(%class.object.3* %obj) #7
  br label %eh.resume

eh.resume:                                        ; preds = %ehcleanup10
  %exn = load i8*, i8** %exn.slot, align 8
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val11 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val11
}

declare dso_local void @_ZN6objectILi4EEC1Ev(%class.object.3*) unnamed_addr #2

declare dso_local void @_Z6child2ILi4EEv6objectIXT_EEllS1_(%class.object.3*, i64, i64, %class.object.3*) #2

; Function Attrs: nounwind
declare dso_local void @_ZN6objectILi4EED1Ev(%class.object.3*) unnamed_addr #4

declare dso_local void @_ZN6objectILi4EE6updateEv(%class.object.3*) #2

declare dso_local void @_ZN6objectILi2EEC1Ev(%class.object.0*) unnamed_addr #2

; Function Attrs: nounwind
declare dso_local void @_ZN6objectILi2EED1Ev(%class.object.0*) unnamed_addr #4

; Function Attrs: nounwind
declare dso_local void @_ZN6objectILi1EED1Ev(%class.object.1*) unnamed_addr #4

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #6

declare dso_local dereferenceable(1) %class.object.2* @_ZN6objectILi0EEaSES0_(%class.object.2*, %class.object.2*) #2

declare dso_local void @_ZN6objectILi0EEC1ERKS0_(%class.object.2*, %class.object.2* dereferenceable(1)) unnamed_addr #2

; Function Attrs: nounwind
declare dso_local void @_ZN6objectILi0EED1Ev(%class.object.2*) unnamed_addr #4

declare dso_local void @_ZN6objectILi0EEC1Ev(%class.object.2*) unnamed_addr #2

declare dso_local void @_ZN6objectILi1EEC1Ev(%class.object.1*) unnamed_addr #2

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #7

; Function Attrs: nounwind
declare void @llvm.stackrestore(i8*) #7

attributes #0 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind }
attributes #4 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { argmemonly }
attributes #6 = { cold noreturn nounwind }
attributes #7 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git 454a63d749f3cfa91fc95835257cd3737d3b43ec)"}
