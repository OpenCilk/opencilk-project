; Check that inlining a function call inside of a spawned task with a
; byval argument inserts the necessary alloca within the spawned task,
; not at the entry of the function.
;
; RUN: opt < %s -passes="inline" -S | FileCheck %s

%"class.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::const_iterator" = type <{ %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"*, i16, [6 x i8] }>
%"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode" = type { %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::node", %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"*, %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"*, [32 x i64] }
%"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::node" = type { i16, i16 }
%"class.std::vector.0" = type { %"struct.std::_Vector_base.1" }
%"struct.std::_Vector_base.1" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long>>::_Vector_impl" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long>>::_Vector_impl" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long>>::_Vector_impl_data" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long>>::_Vector_impl_data" = type { i64*, i64*, i64* }

$_ZSt5mergeIN3tlx5BTreeImmNS0_9btree_setImSt4lessImENS0_20btree_default_traitsImmEESaImEE12key_of_valueES4_S6_Lb0ES7_E14const_iteratorESB_St20back_insert_iteratorISt6vectorImS7_EEET1_T_SH_T0_SI_SG_ = comdat any

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #0

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #0

define dso_local void @_Z24test_parallel_merge_map1mRSt8seed_seq(%"class.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::const_iterator"* %agg.tmp59) personality i8* undef {
entry:
  %syncreg = call token @llvm.syncregion.start()
  ret void

; CHECK: define dso_local void @_Z24test_parallel_merge_map1mRSt8seed_seq(
; CHECK-NEXT: entry:
; CHECK-NOT: %agg.tmp
; CHECK: detach within
; CHECK: %agg.tmp
; CHECK-NOT: invoke %"class.std::vector.0"* @_ZSt5mergeIN3tlx5BTreeImmNS0_9btree_setImSt4lessImENS0_20btree_default_traitsImmEESaImEE12key_of_valueES4_S6_Lb0ES7_E14const_iteratorESB_St20back_insert_iteratorISt6vectorImS7_EEET1_T_SH_T0_SI_SG_
; CHECK: reattach within

pfor.cond:                                        ; preds = %pfor.inc
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc unwind label %lpad79

pfor.body.entry:                                  ; preds = %pfor.cond
  %agg.tmp591 = alloca %"class.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::const_iterator", i32 0, align 8
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  br label %cond.true

cond.true:                                        ; preds = %pfor.body
  br label %cond.end

cond.end:                                         ; preds = %cond.true
  br label %invoke.cont38

invoke.cont38:                                    ; preds = %cond.end
  br label %invoke.cont43

invoke.cont43:                                    ; preds = %invoke.cont38
  br label %invoke.cont48

invoke.cont48:                                    ; preds = %invoke.cont43
  br label %invoke.cont53

invoke.cont53:                                    ; preds = %invoke.cont48
  %call63 = invoke %"class.std::vector.0"* undef(%"class.std::vector.0"* null)
          to label %invoke.cont62 unwind label %lpad61

invoke.cont62:                                    ; preds = %invoke.cont53
  %call67 = invoke %"class.std::vector.0"* @_ZSt5mergeIN3tlx5BTreeImmNS0_9btree_setImSt4lessImENS0_20btree_default_traitsImmEESaImEE12key_of_valueES4_S6_Lb0ES7_E14const_iteratorESB_St20back_insert_iteratorISt6vectorImS7_EEET1_T_SH_T0_SI_SG_(%"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"* null, i16 0, %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"* null, i16 0, %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"* null, i16 0, %"class.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::const_iterator"* byval(%"class.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::const_iterator") %agg.tmp59, i64 0)
          to label %invoke.cont66 unwind label %lpad61

invoke.cont66:                                    ; preds = %invoke.cont62
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %invoke.cont66, %pfor.cond
  br label %pfor.cond

lpad61:                                           ; preds = %invoke.cont62, %invoke.cont53
  %0 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad61
  br label %ehcleanup69

ehcleanup69:                                      ; preds = %ehcleanup
  br label %ehcleanup70

ehcleanup70:                                      ; preds = %ehcleanup69
  br label %ehcleanup71

ehcleanup71:                                      ; preds = %ehcleanup70
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } zeroinitializer)
          to label %unreachable unwind label %lpad79

lpad79:                                           ; preds = %ehcleanup71, %pfor.cond
  %1 = landingpad { i8*, i32 }
          cleanup
  ret void

unreachable:                                      ; preds = %ehcleanup71
  unreachable
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

define linkonce_odr %"class.std::vector.0"* @_ZSt5mergeIN3tlx5BTreeImmNS0_9btree_setImSt4lessImENS0_20btree_default_traitsImmEESaImEE12key_of_valueES4_S6_Lb0ES7_E14const_iteratorESB_St20back_insert_iteratorISt6vectorImS7_EEET1_T_SH_T0_SI_SG_(%"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"* %__first1.coerce0, i16 %__first1.coerce1, %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"* %__last1.coerce0, i16 %__last1.coerce1, %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::LeafNode"* %__first2.coerce0, i16 %__first2.coerce1, %"class.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false>::const_iterator"* %__last2, i64 %__result.coerce) comdat {
entry:
  ret %"class.std::vector.0"* null
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #3

attributes #0 = { argmemonly nofree nosync nounwind willreturn }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nofree nounwind willreturn }
attributes #3 = { argmemonly willreturn }
