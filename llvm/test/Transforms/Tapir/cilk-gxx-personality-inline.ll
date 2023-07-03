; Check that function inlining works when the caller/callee use the
; Cilk and GXX personality functions.
;
; RUN: opt < %s -passes='always-inline' -S | FileCheck %s

; Function Attrs: alwaysinline
define weak_odr void @_Z12conv2d_loopsIfEvPT_PKS0_S3_llllllllllllllllllll() #0 personality i32 (...)* @__cilk_personality_v0 {
pfor.end326:
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #2

; Function Attrs: alwaysinline
define void @conv2d_f32(float* %out, float* %lhs, float* %rhs, i64 %input_batch, i64 %input_rows, i64 %input_cols, i64 %input_channels, i64 %kernel_rows, i64 %kernel_cols, i64 %kernel_channels, i64 %kernel_filters, i64 %output_rows, i64 %output_cols, i64 %row_stride, i64 %col_stride, i64 %padding_top, i64 %padding_bottom, i64 %padding_left, i64 %padding_right, i64 %lhs_row_dilation, i64 %lhs_col_dilation, i64 %rhs_row_dilation, i64 %rhs_col_dilation) #0 {
entry:
  call void @_Z12conv2d_loopsIfEvPT_PKS0_S3_llllllllllllllllllll()
  ret void
}

define void @_Z15conv2d_f32_wrapN5boost6python5numpy7ndarrayES2_NS0_5tupleES3_S3_NS0_4listES4_S4_() personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
invoke.cont266:
  invoke void @conv2d_f32(float* null, float* null, float* null, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0)
          to label %invoke.cont268 unwind label %lpad265

invoke.cont268:                                   ; preds = %invoke.cont266
  ret void

lpad265:                                          ; preds = %invoke.cont266
  %0 = landingpad { i8*, i32 }
          cleanup
  ret void
}

; CHECK: define weak_odr void @_Z12conv2d_loopsIfEvPT_PKS0_S3_llllllllllllllllllll()

; CHECK: define void @conv2d_f32(
; CHECK: personality ptr @__cilk_personality_v0 {
; CHECK: ret void

; CHECK: define void @_Z15conv2d_f32_wrapN5boost6python5numpy7ndarrayES2_NS0_5tupleES3_S3_NS0_4listES4_S4_()
; CHECK: personality ptr @__cilk_personality_v0 {

; Function Attrs: nofree nosync nounwind willreturn
declare i8* @llvm.stacksave() #3

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #4

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #5

; Function Attrs: nounwind
declare i32 @llvm.eh.sjlj.setjmp(i8*) #6

declare i32 @__cilk_personality_v0(...)

declare i32 @__gxx_personality_v0(...)

attributes #0 = { alwaysinline }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly willreturn }
attributes #3 = { nofree nosync nounwind willreturn }
attributes #4 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #5 = { nofree nosync nounwind readnone willreturn }
attributes #6 = { nounwind }
