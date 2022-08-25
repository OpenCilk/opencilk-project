; Check the compiler's ability to inline one function into another
; when their personality functions do not match.
;
; TODO: We have a workaround to allow inlining one function into
; another when the callee's personality function is simply the
; default.  Revisit this test if the workaround is replaced.
;
; RUN: opt < %s -passes="always-inline" -S | FileCheck %s

source_filename = "inlining-personality.ll"

%"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode" = type { %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::node", %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"*, %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"*, %class.Lock, [128 x i64] }
%"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::node" = type { i16, i16 }
%class.Lock = type { %"struct.std::atomic.10" }
%"struct.std::atomic.10" = type { %"struct.std::__atomic_base.11" }
%"struct.std::__atomic_base.11" = type { i8 }
%"class.std::allocator.36" = type { i8 }

$_ZNSaIN3tlx5BTreeImmNS_9btree_setImSt4lessImENS_20btree_default_traitsImmEESaImELb0EE12key_of_valueES3_S5_Lb0ES6_Lb0EE8LeafNodeEE8allocateEm = comdat any

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare i32 @__gxx_personality_v0(...)

declare i32 @__gcc_personality_v0(...)

define linkonce_odr %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"* @_ZN3tlx5BTreeImmNS_9btree_setImSt4lessImENS_20btree_default_traitsImmEESaImELb0EE12key_of_valueES3_S5_Lb0ES6_Lb0EE13allocate_leafEv() personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %call = invoke %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"* @_ZNSaIN3tlx5BTreeImmNS_9btree_setImSt4lessImENS_20btree_default_traitsImmEESaImELb0EE12key_of_valueES3_S5_Lb0ES6_Lb0EE8LeafNodeEE8allocateEm(%"class.std::allocator.36"* null, i64 0)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  ret %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"* null

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  ret %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"* null
}

; Function Attrs: alwaysinline
define linkonce_odr %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"* @_ZNSaIN3tlx5BTreeImmNS_9btree_setImSt4lessImENS_20btree_default_traitsImmEESaImELb0EE12key_of_valueES3_S5_Lb0ES6_Lb0EE8LeafNodeEE8allocateEm(%"class.std::allocator.36"* %this, i64 %__n) #2 comdat personality i32 (...)* @__gcc_personality_v0 {
entry:
  ret %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"* null
}

; CHECK: define linkonce_odr %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"* @_ZN3tlx5BTreeImmNS_9btree_setImSt4lessImENS_20btree_default_traitsImmEESaImELb0EE12key_of_valueES3_S5_Lb0ES6_Lb0EE13allocate_leafEv() personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK: entry:
; CHECK-NEXT: br label %invoke.cont
; CHECK: invoke.cont:
; CHECK-NEXT: ret %"struct.tlx::BTree<unsigned long, unsigned long, tlx::btree_set<unsigned long, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, std::allocator<unsigned long>, false>::key_of_value, std::less<unsigned long>, tlx::btree_default_traits<unsigned long, unsigned long>, false, std::allocator<unsigned long>, false>::LeafNode"* null

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #4

; Function Attrs: nofree nosync nounwind willreturn
declare i8* @llvm.stacksave() #5

attributes #0 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { alwaysinline }
attributes #3 = { argmemonly nofree nounwind willreturn writeonly }
attributes #4 = { nofree nosync nounwind readnone willreturn }
attributes #5 = { nofree nosync nounwind willreturn }
