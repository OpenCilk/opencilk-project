; Verify that simplifycfg does not remove the unwind destination of a
; detach when it is shared with another detach instruction but is
; unused with the other detach instruction.
;
; RUN: opt < %s -simplifycfg -S | FileCheck %s
; RUN: opt < %s -enable-new-pm=0 -simplifycfg -S | FileCheck %s

; ModuleID = 'simplifycfg-test.ll'
source_filename = "KCore-0917ee.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.gbbs::vertexSubsetData.40" = type { i64, i64, %"class.parlay::sequence.41", %"class.parlay::sequence.48", i8, i64 }
%"class.parlay::sequence.41" = type { %"struct.parlay::sequence_internal::sequence_base.42" }
%"struct.parlay::sequence_internal::sequence_base.42" = type { %"struct.parlay::sequence_internal::sequence_base<std::tuple<unsigned int, unsigned int>, std::allocator<std::tuple<unsigned int, unsigned int>>, false>::storage_impl" }
%"struct.parlay::sequence_internal::sequence_base<std::tuple<unsigned int, unsigned int>, std::allocator<std::tuple<unsigned int, unsigned int>>, false>::storage_impl" = type { %"struct.parlay::sequence_internal::sequence_base<std::tuple<unsigned int, unsigned int>, std::allocator<std::tuple<unsigned int, unsigned int>>, false>::storage_impl::_data_impl" }
%"struct.parlay::sequence_internal::sequence_base<std::tuple<unsigned int, unsigned int>, std::allocator<std::tuple<unsigned int, unsigned int>>, false>::storage_impl::_data_impl" = type { %union.anon.46, i8 }
%union.anon.46 = type <{ i8*, [6 x i8] }>
%"class.parlay::sequence.48" = type { %"struct.parlay::sequence_internal::sequence_base.49" }
%"struct.parlay::sequence_internal::sequence_base.49" = type { %"struct.parlay::sequence_internal::sequence_base<std::tuple<bool, unsigned int>, std::allocator<std::tuple<bool, unsigned int>>, false>::storage_impl" }
%"struct.parlay::sequence_internal::sequence_base<std::tuple<bool, unsigned int>, std::allocator<std::tuple<bool, unsigned int>>, false>::storage_impl" = type { %"struct.parlay::sequence_internal::sequence_base<std::tuple<bool, unsigned int>, std::allocator<std::tuple<bool, unsigned int>>, false>::storage_impl::_data_impl" }
%"struct.parlay::sequence_internal::sequence_base<std::tuple<bool, unsigned int>, std::allocator<std::tuple<bool, unsigned int>>, false>::storage_impl::_data_impl" = type { %union.anon.53, i8 }
%union.anon.53 = type <{ i8*, [6 x i8] }>
%"class.std::tuple.147" = type { %"struct.std::_Tuple_impl.base", [3 x i8] }
%"struct.std::_Tuple_impl.base" = type <{ %"struct.std::_Tuple_impl.59", %"struct.std::_Head_base.149" }>
%"struct.std::_Tuple_impl.59" = type { %"struct.std::_Head_base.60" }
%"struct.std::_Head_base.60" = type { i32 }
%"struct.std::_Head_base.149" = type { i8 }
%"struct.parlay::sequence_internal::sequence_base<std::tuple<bool, unsigned int>, std::allocator<std::tuple<bool, unsigned int>>, false>::storage_impl::capacitated_buffer" = type { %"struct.parlay::sequence_internal::sequence_base<std::tuple<bool, unsigned int>, std::allocator<std::tuple<bool, unsigned int>>, false>::storage_impl::capacitated_buffer::header"* }
%"struct.parlay::sequence_internal::sequence_base<std::tuple<bool, unsigned int>, std::allocator<std::tuple<bool, unsigned int>>, false>::storage_impl::capacitated_buffer::header" = type <{ i64, %union.anon.54, [4 x i8] }>
%union.anon.54 = type { [1 x i8], [3 x i8] }

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

define linkonce_odr hidden void @_ZN4gbbs8KCore_FAINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIjSaIjELb0EEERT_m() local_unnamed_addr personality i8* undef {
entry:
  %syncreg.i.i = call token @llvm.syncregion.start()
  %call.i1 = invoke i64 bitcast (i64 ()* @_ZNK4gbbs16vertexSubsetDataIjE7numRowsEv to i64 (%"struct.gbbs::vertexSubsetData.40"*)*)(%"struct.gbbs::vertexSubsetData.40"* undef)
          to label %call.i.noexc unwind label %lpad25

call.i.noexc:                                     ; preds = %entry
  %call2.i2 = invoke i1 bitcast (i1 ()* @_ZNK4gbbs16vertexSubsetDataIjE5denseEv to i1 (%"struct.gbbs::vertexSubsetData.40"*)*)(%"struct.gbbs::vertexSubsetData.40"* undef)
          to label %call2.i.noexc unwind label %lpad25

call2.i.noexc:                                    ; preds = %call.i.noexc
  br i1 %call2.i2, label %if.then.i, label %pfor.cond.i.i

if.then.i:                                        ; preds = %call2.i.noexc
  br label %pfor.cond.i

pfor.cond.i:                                      ; preds = %pfor.inc.i, %if.then.i
  detach within %syncreg.i.i, label %pfor.body.entry.i, label %pfor.inc.i unwind label %lpad25

pfor.body.entry.i:                                ; preds = %pfor.cond.i
  %call.i.i.i.i.i.i.i = call %"class.std::tuple.147"* undef(%"struct.parlay::sequence_internal::sequence_base<std::tuple<bool, unsigned int>, std::allocator<std::tuple<bool, unsigned int>>, false>::storage_impl::capacitated_buffer"* undef)
  br label %_ZZN4gbbs9vertexMapIZNS_8KCore_FAINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIjSaIjELb0EEERT_mEUljRjE_NS_16vertexSubsetDataIjEELi0EEEvRT0_SA_mENKUlmE_clEm.exit.i

_ZZN4gbbs9vertexMapIZNS_8KCore_FAINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIjSaIjELb0EEERT_mEUljRjE_NS_16vertexSubsetDataIjEELi0EEEvRT0_SA_mENKUlmE_clEm.exit.i: ; preds = %pfor.body.entry.i
  reattach within %syncreg.i.i, label %pfor.inc.i

pfor.inc.i:                                       ; preds = %_ZZN4gbbs9vertexMapIZNS_8KCore_FAINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIjSaIjELb0EEERT_mEUljRjE_NS_16vertexSubsetDataIjEELi0EEEvRT0_SA_mENKUlmE_clEm.exit.i, %pfor.cond.i
  br label %pfor.cond.i

pfor.cond.i.i:                                    ; preds = %pfor.inc.i.i, %call2.i.noexc
  detach within %syncreg.i.i, label %pfor.body.entry.i.i, label %pfor.inc.i.i unwind label %lpad25

pfor.body.entry.i.i:                              ; preds = %pfor.cond.i.i
  invoke void @_ZZN4gbbs9vertexMapIZNS_8KCore_FAINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIjSaIjELb0EEERT_mEUljRjE_NS_16vertexSubsetDataIjEELi0EEEvRT0_SA_mENKUlmE0_clEm()
          to label %.noexc unwind label %lpad253

.noexc:                                           ; preds = %pfor.body.entry.i.i
  reattach within %syncreg.i.i, label %pfor.inc.i.i

pfor.inc.i.i:                                     ; preds = %.noexc, %pfor.cond.i.i
  br label %pfor.cond.i.i

lpad25.unreachable:                               ; preds = %lpad253
  unreachable

lpad253:                                          ; preds = %pfor.body.entry.i.i
  %0 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i, { i8*, i32 } %0)
          to label %lpad25.unreachable unwind label %lpad25

lpad25:                                           ; preds = %lpad253, %pfor.cond.i.i, %pfor.cond.i, %call.i.noexc, %entry
  %1 = landingpad { i8*, i32 }
          cleanup
  ret void
}

; CHECK: define linkonce_odr hidden void @_ZN4gbbs8KCore_FAINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIjSaIjELb0EEERT_m()
; CHECK: detach within %syncreg.i.i, label %pfor.body.entry.i.i, label %pfor.inc.i.i unwind label %lpad25

; CHECK: pfor.body.entry.i.i:
; CHECK-NEXT: invoke void @_ZZN4gbbs9vertexMapIZNS_8KCore_FAINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIjSaIjELb0EEERT_mEUljRjE_NS_16vertexSubsetDataIjEELi0EEEvRT0_SA_mENKUlmE0_clEm()
; CHECK-NEXT: to label %.noexc unwind label %lpad253

; CHECK: lpad253:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i,
; CHECK-NEXT: to label %lpad25.unreachable unwind label %lpad25

; CHECK: lpad25:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: ret void

declare hidden i1 @_ZNK4gbbs16vertexSubsetDataIjE5denseEv() local_unnamed_addr align 2

declare hidden i64 @_ZNK4gbbs16vertexSubsetDataIjE7numRowsEv() local_unnamed_addr align 2

declare hidden void @_ZZN4gbbs9vertexMapIZNS_8KCore_FAINS_15symmetric_graphINS_20csv_bytepd_amortizedENS_5emptyEEEEEN6parlay8sequenceIjSaIjELb0EEERT_mEUljRjE_NS_16vertexSubsetDataIjEELi0EEEvRT0_SA_mENKUlmE0_clEm() local_unnamed_addr align 2

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { argmemonly willreturn }
attributes #2 = { argmemonly nofree nosync nounwind willreturn }
