; RUN: opt < %s -loop-unswitch -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.NeighborIterator.0.7.11.15 = type { i8 }
%"struct.std::_Vector_base.3.10.14.18" = type { %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl.2.9.13.17" }
%"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl.2.9.13.17" = type { %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data.1.8.12.16" }
%"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data.1.8.12.16" = type { i32*, i32*, i32* }

$_ZNSt12_Vector_baseIiSaIiEED2Ev = comdat any

$__clang_call_terminate = comdat any

@.str = private unnamed_addr constant [49 x i8] c"cannot create std::vector larger than max_size()\00", align 1

; Function Attrs: noreturn uwtable
define dso_local void @_Z4funci(i32 %x) local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp = icmp sgt i32 %x, 0
  br label %_ZNSt6vectorIiSaIiEE17_S_check_init_lenEmRKS0_.exit.i

_ZNSt6vectorIiSaIiEE17_S_check_init_lenEmRKS0_.exit.i: ; preds = %entry, %_ZNSt6vectorIiSaIiEED2Ev.exit
  %call2.i.i.i.i1.i.i = invoke i8* @_Znwm(i64 32)
          to label %call2.i.i.i.i.noexc.i.i unwind label %lpad.body

call2.i.i.i.i.noexc.i.i:                          ; preds = %_ZNSt6vectorIiSaIiEE17_S_check_init_lenEmRKS0_.exit.i
  %0 = bitcast i8* %call2.i.i.i.i1.i.i to i32*
  br label %for.body.i.i.i.i.i.i.i

for.body.i.i.i.i.i.i.i:                           ; preds = %for.body.i.i.i.i.i.i.i, %call2.i.i.i.i.noexc.i.i
  %__niter.08.i.i.i.i.i.i.i = phi i64 [ %dec.i.i.i.i.i.i.i, %for.body.i.i.i.i.i.i.i ], [ 8, %call2.i.i.i.i.noexc.i.i ]
  %__first.addr.07.i.i.i.i.i.i.i = phi i32* [ %incdec.ptr.i.i.i.i.i.i.i, %for.body.i.i.i.i.i.i.i ], [ %0, %call2.i.i.i.i.noexc.i.i ]
  store i32 0, i32* %__first.addr.07.i.i.i.i.i.i.i, align 4, !tbaa !2
  %dec.i.i.i.i.i.i.i = add i64 %__niter.08.i.i.i.i.i.i.i, -1
  %incdec.ptr.i.i.i.i.i.i.i = getelementptr inbounds i32, i32* %__first.addr.07.i.i.i.i.i.i.i, i64 1
  %cmp.i.i.i.i.i.i.i = icmp eq i64 %dec.i.i.i.i.i.i.i, 0
  br i1 %cmp.i.i.i.i.i.i.i, label %invoke.cont, label %for.body.i.i.i.i.i.i.i

invoke.cont:                                      ; preds = %for.body.i.i.i.i.i.i.i
  br i1 %cmp, label %pfor.cond.preheader, label %_ZNSt6vectorIiSaIiEED2Ev.exit

pfor.cond.preheader:                              ; preds = %invoke.cont
  br label %pfor.cond

lpad.body:                                        ; preds = %_ZNSt6vectorIiSaIiEE17_S_check_init_lenEmRKS0_.exit.i
  %1 = landingpad { i8*, i32 }
          cleanup
  %2 = extractvalue { i8*, i32 } %1, 0
  %3 = extractvalue { i8*, i32 } %1, 1
  br label %ehcleanup18

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc
  %__begin.0 = phi i32 [ %inc, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  detach within %syncreg, label %pfor.body, label %pfor.inc unwind label %lpad10.loopexit

pfor.body:                                        ; preds = %pfor.cond
  %it = alloca %class.NeighborIterator.0.7.11.15, align 1
  %4 = getelementptr inbounds %class.NeighborIterator.0.7.11.15, %class.NeighborIterator.0.7.11.15* %it, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %4) #10
  invoke void @_ZN16NeighborIteratorC1Ei(%class.NeighborIterator.0.7.11.15* nonnull %it, i32 %__begin.0)
          to label %invoke.cont7 unwind label %lpad4

invoke.cont7:                                     ; preds = %pfor.body
  %call = invoke zeroext i1 @_ZNK16NeighborIterator4doneEv(%class.NeighborIterator.0.7.11.15* nonnull %it)
          to label %invoke.cont8 unwind label %lpad4

invoke.cont8:                                     ; preds = %invoke.cont7
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %4) #10
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %invoke.cont8, %pfor.cond
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond = icmp eq i32 %inc, %x
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %sync.continue

lpad4:                                            ; preds = %invoke.cont7, %pfor.body
  %call2.i.i.i.i1.i.i.lcssa1 = phi i8* [ %call2.i.i.i.i1.i.i, %invoke.cont7 ], [ %call2.i.i.i.i1.i.i, %pfor.body ]
  %.lcssa = phi i8* [ %4, %invoke.cont7 ], [ %4, %pfor.body ]
  %5 = landingpad { i8*, i32 }
          cleanup
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %.lcssa) #10
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %5)
          to label %unreachable unwind label %lpad10.loopexit

; CHECK: lpad4:
; CHECK-NEXT: %call2.i.i.i.i1.i.i.lcssa1 = phi i8*
; CHECK-NEXT: %.lcssa = phi
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(
; CHECK: to label %{{.+}} unwind label %[[DRDEST:.+]]

; CHECK: [[DRDEST]]:
; CHECK-DAG: phi i8* [ %call2.i.i.i.i1.i.i.lcssa1, %lpad4 ]

; CHECK: _ZNSt6vectorIiSaIiEED2Ev.exit11:
; CHECK-NOT: %call2.i.i.i.i1.i.i.lcssa1,
; CHECK: unreachable

lpad10.loopexit:                                  ; preds = %pfor.cond
  %call2.i.i.i.i1.i.i.lcssa = phi i8* [ %call2.i.i.i.i1.i.i, %pfor.cond ], [ %call2.i.i.i.i1.i.i.lcssa1, %lpad4 ]
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  br label %_ZNSt6vectorIiSaIiEED2Ev.exit11

lpad10.loopexit.split-lp.loopexit:                ; preds = %sync.continue
  %call2.i.i.i.i1.i.i.lcssa2 = phi i8* [ %call2.i.i.i.i1.i.i, %sync.continue ]
  %lpad.loopexit38 = landingpad { i8*, i32 }
          cleanup
  br label %_ZNSt6vectorIiSaIiEED2Ev.exit11

_ZNSt6vectorIiSaIiEED2Ev.exit11:                  ; preds = %lpad10.loopexit.split-lp.loopexit.split-lp, %lpad10.loopexit.split-lp.loopexit, %lpad10.loopexit
  %call2.i.i.i.i1.i.i3 = phi i8* [ %call2.i.i.i.i1.i.i.lcssa, %lpad10.loopexit ], [ %call2.i.i.i.i1.i.i.lcssa2, %lpad10.loopexit.split-lp.loopexit ]
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad10.loopexit ], [ %lpad.loopexit38, %lpad10.loopexit.split-lp.loopexit ]
  %6 = extractvalue { i8*, i32 } %lpad.phi, 0
  %7 = extractvalue { i8*, i32 } %lpad.phi, 1
  call void @_ZdlPv(i8* nonnull %call2.i.i.i.i1.i.i3) #10
  br label %ehcleanup18

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %_ZNSt6vectorIiSaIiEED2Ev.exit unwind label %lpad10.loopexit.split-lp.loopexit

_ZNSt6vectorIiSaIiEED2Ev.exit:                    ; preds = %sync.continue, %invoke.cont
  call void @_ZdlPv(i8* nonnull %call2.i.i.i.i1.i.i) #10
  br label %_ZNSt6vectorIiSaIiEE17_S_check_init_lenEmRKS0_.exit.i

ehcleanup18:                                      ; preds = %_ZNSt6vectorIiSaIiEED2Ev.exit11, %lpad.body
  %ehselector.slot.0 = phi i32 [ %7, %_ZNSt6vectorIiSaIiEED2Ev.exit11 ], [ %3, %lpad.body ]
  %exn.slot.0 = phi i8* [ %6, %_ZNSt6vectorIiSaIiEED2Ev.exit11 ], [ %2, %lpad.body ]
  %lpad.val21 = insertvalue { i8*, i32 } undef, i8* %exn.slot.0, 0
  %lpad.val22 = insertvalue { i8*, i32 } %lpad.val21, i32 %ehselector.slot.0, 1
  resume { i8*, i32 } %lpad.val22

unreachable:                                      ; preds = %lpad4
  unreachable
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #1

declare dso_local void @_ZN16NeighborIteratorC1Ei(%class.NeighborIterator.0.7.11.15*, i32) unnamed_addr #2

declare dso_local zeroext i1 @_ZNK16NeighborIterator4doneEv(%class.NeighborIterator.0.7.11.15*) local_unnamed_addr #2

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #3

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #3

; Function Attrs: norecurse nounwind readnone uwtable
define dso_local i32 @main(i32 %argc, i8** nocapture readnone %argv) local_unnamed_addr #4 {
entry:
  ret i32 0
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZNSt12_Vector_baseIiSaIiEED2Ev(%"struct.std::_Vector_base.3.10.14.18"* %this) unnamed_addr #5 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %_M_start = getelementptr inbounds %"struct.std::_Vector_base.3.10.14.18", %"struct.std::_Vector_base.3.10.14.18"* %this, i64 0, i32 0, i32 0, i32 0
  %0 = load i32*, i32** %_M_start, align 8, !tbaa !8
  %tobool.i = icmp eq i32* %0, null
  br i1 %tobool.i, label %invoke.cont, label %if.then.i

if.then.i:                                        ; preds = %entry
  %1 = bitcast i32* %0 to i8*
  tail call void @_ZdlPv(i8* nonnull %1) #10
  br label %invoke.cont

invoke.cont:                                      ; preds = %if.then.i, %entry
  ret void
}

; Function Attrs: noreturn
declare dso_local void @_ZSt20__throw_length_errorPKc(i8*) local_unnamed_addr #6

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8*) local_unnamed_addr #7 comdat {
  %2 = tail call i8* @__cxa_begin_catch(i8* %0) #10
  tail call void @_ZSt9terminatev() #11
  unreachable
}

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: noreturn
declare dso_local void @_ZSt17__throw_bad_allocv() local_unnamed_addr #6

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #8

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #9

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #1

attributes #0 = { noreturn uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly }
attributes #4 = { norecurse nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { noinline noreturn nounwind }
attributes #8 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nounwind }
attributes #11 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git ddab609986e32dc869acfe34ea0380df6dcc082e)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = distinct !{!6, !7}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
!8 = !{!9, !10, i64 0}
!9 = !{!"_ZTSNSt12_Vector_baseIiSaIiEE17_Vector_impl_dataE", !10, i64 0, !10, i64 8, !10, i64 16}
!10 = !{!"any pointer", !4, i64 0}
