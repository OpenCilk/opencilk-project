; Check the compiler's ability to inline one function into another
; when their personality functions do not match.
;
; TODO: We have a workaround to allow inlining one function into
; another when the caller's personality function is simply the
; default.  Revisit this test if the workaround is replaced.
;
; RUN: opt < %s -passes="always-inline" -S | FileCheck %s

%"class.std::__1::basic_string" = type { %"class.std::__1::__compressed_pair" }
%"class.std::__1::__compressed_pair" = type { %"struct.std::__1::__compressed_pair_elem" }
%"struct.std::__1::__compressed_pair_elem" = type { %"struct.std::__1::basic_string<char>::__rep" }
%"struct.std::__1::basic_string<char>::__rep" = type { %union.anon }
%union.anon = type { %"struct.std::__1::basic_string<char>::__long" }
%"struct.std::__1::basic_string<char>::__long" = type { i8*, i64, i64 }
%"class.google::protobuf::Arena" = type { %"class.google::protobuf::internal::ArenaImpl", void (%"class.std::type_info"*, i64, i8*)*, void (%"class.google::protobuf::Arena"*, i8*, i64)*, void (%"class.google::protobuf::Arena"*, i8*, i64)*, i8* }
%"class.google::protobuf::internal::ArenaImpl" = type { %"struct.std::__1::atomic", %"struct.std::__1::atomic", %"struct.std::__1::atomic.1", %"class.google::protobuf::internal::ArenaImpl::Block"*, i64, %"struct.google::protobuf::internal::ArenaImpl::Options" }
%"struct.std::__1::atomic" = type { %"struct.std::__1::__atomic_base" }
%"struct.std::__1::__atomic_base" = type { %"struct.std::__1::__cxx_atomic_impl" }
%"struct.std::__1::__cxx_atomic_impl" = type { %"struct.std::__1::__cxx_atomic_base_impl" }
%"struct.std::__1::__cxx_atomic_base_impl" = type { %"class.google::protobuf::internal::ArenaImpl::SerialArena"* }
%"class.google::protobuf::internal::ArenaImpl::SerialArena" = type { %"class.google::protobuf::internal::ArenaImpl"*, i8*, %"class.google::protobuf::internal::ArenaImpl::Block"*, %"struct.google::protobuf::internal::ArenaImpl::CleanupChunk"*, %"class.google::protobuf::internal::ArenaImpl::SerialArena"*, i8*, i8*, %"struct.google::protobuf::internal::ArenaImpl::CleanupNode"*, %"struct.google::protobuf::internal::ArenaImpl::CleanupNode"* }
%"struct.google::protobuf::internal::ArenaImpl::CleanupChunk" = type { i64, %"struct.google::protobuf::internal::ArenaImpl::CleanupChunk"*, [1 x %"struct.google::protobuf::internal::ArenaImpl::CleanupNode"] }
%"struct.google::protobuf::internal::ArenaImpl::CleanupNode" = type { i8*, void (i8*)* }
%"struct.std::__1::atomic.1" = type { %"struct.std::__1::__atomic_base.2" }
%"struct.std::__1::__atomic_base.2" = type { %"struct.std::__1::__atomic_base.3" }
%"struct.std::__1::__atomic_base.3" = type { %"struct.std::__1::__cxx_atomic_impl.4" }
%"struct.std::__1::__cxx_atomic_impl.4" = type { %"struct.std::__1::__cxx_atomic_base_impl.5" }
%"struct.std::__1::__cxx_atomic_base_impl.5" = type { i64 }
%"class.google::protobuf::internal::ArenaImpl::Block" = type { %"class.google::protobuf::internal::ArenaImpl::Block"*, i64, i64 }
%"struct.google::protobuf::internal::ArenaImpl::Options" = type { i64, i64, i8*, i64, i8* (i64)*, void (i8*, i64)* }
%"class.std::type_info" = type { i32 (...)**, i64 }

define linkonce_odr %"class.std::__1::basic_string"* @_ZN6google8protobuf5Arena20DoCreateMaybeMessageINSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEJRKS9_EEEPT_PS1_NS3_17integral_constantIbLb0EEEDpOT0_() personality i32 (...)* @__gcc_personality_v0 {
entry:
  %call11 = invoke %"class.std::__1::basic_string"* @_ZN6google8protobuf5Arena14CreateInternalINSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEJRKS9_EEEPT_PS1_DpOT0_(%"class.google::protobuf::Arena"* null, %"class.std::__1::basic_string"* null)
          to label %call1.noexc unwind label %csi.cleanup

call1.noexc:                                      ; preds = %entry
  ret %"class.std::__1::basic_string"* null

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } zeroinitializer
}

; CHECK: define linkonce_odr ptr @_ZN6google8protobuf5Arena20DoCreateMaybeMessageINSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEJRKS9_EEEPT_PS1_NS3_17integral_constantIbLb0EEEDpOT0_() personality ptr @__gxx_personality_v0 {
; CHECK: entry:
; CHECK-NEXT: br label %call1.noexc
; CHECK: call1.noexc:
; CHECK-NEXT: ret ptr null

; Function Attrs: alwaysinline
define linkonce_odr %"class.std::__1::basic_string"* @_ZN6google8protobuf5Arena14CreateInternalINSt3__112basic_stringIcNS3_11char_traitsIcEENS3_9allocatorIcEEEEJRKS9_EEEPT_PS1_DpOT0_(%"class.google::protobuf::Arena"* %arena, %"class.std::__1::basic_string"* %args) #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  ret %"class.std::__1::basic_string"* null
}

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #1

; Function Attrs: nofree nosync nounwind willreturn
declare i8* @llvm.stacksave() #2

declare i32 @__gxx_personality_v0(...)

declare i32 @__gcc_personality_v0(...)

attributes #0 = { alwaysinline }
attributes #1 = { nofree nosync nounwind readnone willreturn }
attributes #2 = { nofree nosync nounwind willreturn }
