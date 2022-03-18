; Check that task-exit blocks of a loop are cloned by loop unrolling.
;
; Thanks to Helen Xu and Amanda Li for the original source for this issue.
;
; RUN: opt < %s -loop-unroll -S | FileCheck %s
; RUN: opt < %s -passes='loop-unroll' -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::seed_seq.4.9.14.19.24.29.39.44.49.54" = type { %"class.std::vector.3.8.13.18.23.28.38.43.48.53" }
%"class.std::vector.3.8.13.18.23.28.38.43.48.53" = type { %"struct.std::_Vector_base.2.7.12.17.22.27.37.42.47.52" }
%"struct.std::_Vector_base.2.7.12.17.22.27.37.42.47.52" = type { %"struct.std::_Vector_base<unsigned int, std::allocator<unsigned int>>::_Vector_impl.1.6.11.16.21.26.36.41.46.51" }
%"struct.std::_Vector_base<unsigned int, std::allocator<unsigned int>>::_Vector_impl.1.6.11.16.21.26.36.41.46.51" = type { %"struct.std::_Vector_base<unsigned int, std::allocator<unsigned int>>::_Vector_impl_data.0.5.10.15.20.25.35.40.45.50" }
%"struct.std::_Vector_base<unsigned int, std::allocator<unsigned int>>::_Vector_impl_data.0.5.10.15.20.25.35.40.45.50" = type { i32*, i32*, i32* }

; Function Attrs: nounwind
define dso_local i32 @main() local_unnamed_addr #0 personality i8* undef {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %entry
  %__begin.0 = phi i32 [ 0, %entry ], [ %inc, %pfor.inc ]
  detach within %syncreg, label %pfor.body, label %pfor.inc unwind label %lpad23

pfor.body:                                        ; preds = %pfor.cond
  %times = alloca [4 x i64], align 16
  %arraydecay = getelementptr inbounds [4 x i64], [4 x i64]* %times, i64 0, i64 0
  invoke void bitcast (void ()* @_Z27test_btree_unordered_insertImEvmRSt8seed_seqPm to void (i64, %"class.std::seed_seq.4.9.14.19.24.29.39.44.49.54"*, i64*)*)(i64 100000000, %"class.std::seed_seq.4.9.14.19.24.29.39.44.49.54"* undef, i64* nonnull %arraydecay)
          to label %pfor.preattach unwind label %lpad8

pfor.preattach:                                   ; preds = %pfor.body
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %pfor.cond
  %inc = add nuw nsw i32 %__begin.0, 1
  %exitcond = icmp ne i32 %inc, 4
  br i1 %exitcond, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !0

; CHECK: pfor.body:
; CHECK: %times = alloca [4 x i64]
; CHECK: invoke void bitcast (void ()* @_Z27test_btree_unordered_insertImEvmRSt8seed_seqPm to void
; CHECK-NEXT: to label %pfor.preattach unwind label %lpad8

; CHECK: pfor.inc:
; CHECK-NEXT: detach within %syncreg, label %pfor.body.1, label %pfor.inc.1 unwind label %lpad23

; CHECK: pfor.body.1:
; CHECK: %times.1 = alloca [4 x i64]
; CHECK: invoke void bitcast (void ()* @_Z27test_btree_unordered_insertImEvmRSt8seed_seqPm to void
; CHECK-NEXT: to label %pfor.preattach.1 unwind label %lpad8.1

; CHECK: pfor.inc.1:
; CHECK-NEXT: detach within %syncreg, label %pfor.body.2, label %pfor.inc.2 unwind label %lpad23

; CHECK: lpad8.1:
; CHECK: bitcast [4 x i64]* %times.1
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } undef)
; CHECK-NEXT: to label %unreachable unwind label %lpad23

; CHECK: pfor.body.2:
; CHECK: %times.2 = alloca [4 x i64]
; CHECK: invoke void bitcast (void ()* @_Z27test_btree_unordered_insertImEvmRSt8seed_seqPm to void
; CHECK-NEXT: to label %pfor.preattach.2 unwind label %lpad8.2

; CHECK: pfor.inc.2:
; CHECK-NEXT: detach within %syncreg, label %pfor.body.3, label %pfor.inc.3 unwind label %lpad23

; CHECK: lpad8.2:
; CHECK: bitcast [4 x i64]* %times.2
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } undef)
; CHECK-NEXT: to label %unreachable unwind label %lpad23

; CHECK: pfor.body.3:
; CHECK: %times.3 = alloca [4 x i64]
; CHECK: invoke void bitcast (void ()* @_Z27test_btree_unordered_insertImEvmRSt8seed_seqPm to void
; CHECK-NEXT: to label %pfor.preattach.3 unwind label %lpad8.3

; CHECK: pfor.inc.3:
; CHECK-NEXT: ret i32 undef

; CHECK: lpad8.3:
; CHECK: bitcast [4 x i64]* %times.3
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } undef)
; CHECK-NEXT: to label %unreachable unwind label %lpad23


pfor.cond.cleanup:                                ; preds = %pfor.inc
  ret i32 undef

lpad8:                                            ; preds = %pfor.body
  %0 = landingpad { i8*, i32 }
          cleanup
  %1 = bitcast [4 x i64]* %times to i8*
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1)
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } undef)
          to label %unreachable unwind label %lpad23

lpad23:                                           ; preds = %lpad8, %pfor.cond
  %2 = landingpad { i8*, i32 }
          cleanup
  ret i32 undef

unreachable:                                      ; preds = %lpad8
  unreachable
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

declare dso_local void @_Z27test_btree_unordered_insertImEvmRSt8seed_seqPm() local_unnamed_addr

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #3

attributes #0 = { nounwind }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly willreturn }

!0 = distinct !{!0, !1}
!1 = !{!"tapir.loop.spawn.strategy", i32 1}
