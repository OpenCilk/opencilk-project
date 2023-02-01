; Check how Tapir-lowering handles a taskframe with an unusual
; shared-exiting spindle.
;
; RUN: opt < %s -passes="loop-spawning,tapir2target" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s

%"struct.miniFE::CSRMatrix" = type { i8, %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.26", i32, %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.26", %"class.std::vector" }
%"class.std::vector.21" = type { %"struct.std::_Vector_base.22" }
%"struct.std::_Vector_base.22" = type { %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl" }
%"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl" = type { %"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data" }
%"struct.std::_Vector_base<int, std::allocator<int>>::_Vector_impl_data" = type { i32*, i32*, i32* }
%"class.std::vector.26" = type { %"struct.std::_Vector_base.27" }
%"struct.std::_Vector_base.27" = type { %"struct.std::_Vector_base<double, std::allocator<double>>::_Vector_impl" }
%"struct.std::_Vector_base<double, std::allocator<double>>::_Vector_impl" = type { %"struct.std::_Vector_base<double, std::allocator<double>>::_Vector_impl_data" }
%"struct.std::_Vector_base<double, std::allocator<double>>::_Vector_impl_data" = type { double*, double*, double* }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *>>::_Vector_impl" }
%"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *>>::_Vector_impl" = type { %"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *>>::_Vector_impl_data" }
%"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *>>::_Vector_impl_data" = type { %struct.ompi_request_t**, %struct.ompi_request_t**, %struct.ompi_request_t** }
%struct.ompi_request_t = type opaque
%"class.std::__cxx11::basic_ostringstream" = type { %"class.std::basic_ostream.base", %"class.std::__cxx11::basic_stringbuf", %"class.std::basic_ios" }
%"class.std::basic_ostream.base" = type { i32 (...)** }
%"class.std::__cxx11::basic_stringbuf" = type { %"class.std::basic_streambuf", i32, %"class.std::__cxx11::basic_string" }
%"class.std::basic_streambuf" = type { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, %"class.std::locale" }
%"class.std::locale" = type { %"class.std::locale::_Impl"* }
%"class.std::locale::_Impl" = type { i32, %"class.std::locale::facet"**, i64, %"class.std::locale::facet"**, i8** }
%"class.std::locale::facet" = type <{ i32 (...)**, i32, [4 x i8] }>
%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char>::_Alloc_hider", i64, %union.anon }
%"struct.std::__cxx11::basic_string<char>::_Alloc_hider" = type { i8* }
%union.anon = type { i64, [8 x i8] }
%"class.std::basic_ios" = type { %"class.std::ios_base", %"class.std::basic_ostream"*, i8, i8, %"class.std::basic_streambuf"*, %"class.std::ctype"*, %"class.std::num_put"*, %"class.std::num_get"* }
%"class.std::ios_base" = type { i32 (...)**, i64, i64, i32, i32, i32, %"struct.std::ios_base::_Callback_list"*, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, %"struct.std::ios_base::_Words"*, %"class.std::locale" }
%"struct.std::ios_base::_Callback_list" = type { %"struct.std::ios_base::_Callback_list"*, void (i32, %"class.std::ios_base"*, i32)*, i32, i32 }
%"struct.std::ios_base::_Words" = type { i8*, i64 }
%"class.std::basic_ostream" = type { i32 (...)**, %"class.std::basic_ios" }
%"class.std::ctype" = type <{ %"class.std::locale::facet.base", [4 x i8], %struct.__locale_struct*, i8, [7 x i8], i32*, i32*, i16*, i8, [256 x i8], [256 x i8], i8, [6 x i8] }>
%"class.std::locale::facet.base" = type <{ i32 (...)**, i32 }>
%struct.__locale_struct = type { [13 x %struct.__locale_data*], i16*, i32*, i32*, [13 x i8*] }
%struct.__locale_data = type opaque
%"class.std::num_put" = type { %"class.std::locale::facet.base", [4 x i8] }
%"class.std::num_get" = type { %"class.std::locale::facet.base", [4 x i8] }

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

define linkonce_odr i32 @_ZN6miniFE25generate_matrix_structureINS_9CSRMatrixIdiiEEEEiRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERS4_() personality i8* undef {
  br label %for.body.i

for.body.i:                                       ; preds = %2, %0
  br label %1

1:                                                ; preds = %for.body.i
  br label %2

2:                                                ; preds = %1
  br i1 false, label %_ZN6miniFE8copy_boxERK3BoxRS0_.exit, label %for.body.i

_ZN6miniFE8copy_boxERK3BoxRS0_.exit:              ; preds = %2
  br label %if.end

if.end:                                           ; preds = %_ZN6miniFE8copy_boxERK3BoxRS0_.exit
  ; br label %if.end38
  invoke void undef(%"struct.miniFE::CSRMatrix"* null, i32 0, i32 0)
          to label %if.end38 unwind label %lpad218  

if.end38:                                         ; preds = %if.end
  br label %if.end55.split

if.end55.split:                                   ; preds = %if.end38
  %3 = call token @llvm.taskframe.create()
  invoke void undef(%"struct.miniFE::CSRMatrix"* null, i32 0, i32 0)
          to label %try.cont.split unwind label %lpad58.split

lpad58.split:                                     ; preds = %if.end55.split
  %4 = landingpad { i8*, i32 }
          cleanup
          catch i8* null
  br label %catch.split

catch.split:                                      ; preds = %lpad58.split
  invoke void undef(%"class.std::__cxx11::basic_ostringstream"* null)
          to label %invoke.cont63 unwind label %lpad62

invoke.cont63:                                    ; preds = %catch.split
  br label %try.cont.split

lpad62:                                           ; preds = %catch.split
  %5 = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup81

ehcleanup81:                                      ; preds = %lpad62
  invoke void undef()
          to label %invoke.cont83 unwind label %terminate.lpad

invoke.cont83:                                    ; preds = %ehcleanup81
  br label %try.cont.split

try.cont.split:                                   ; preds = %if.end55.split
  call void @llvm.taskframe.end(token %3)
  ret i32 0

pfor.body.entry.i:                                ; No predecessors!
  %6 = call i8* @llvm.task.frameaddress(i32 0)
  ret i32 0

lpad218:                                          ; No predecessors!
  %test = landingpad { i8*, i32 }
          cleanup
  invoke void undef()
          to label %invoke.cont228 unwind label %terminate.lpad

invoke.cont228:                                   ; preds = %lpad218
  ret i32 0

terminate.lpad:                                   ; preds = %lpad218, %ehcleanup81
  %7 = phi i64 [ 0, %lpad218 ], [ 0, %ehcleanup81 ]
  %8 = landingpad { i8*, i32 }
          catch i8* null
  unreachable
}

; CHECK-LABEL: define {{.*}}i32 @_ZN6miniFE25generate_matrix_structureINS_9CSRMatrixIdiiEEEEiRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERS4_(
; CHECK: if.end38:
; CHECK-NEXT: call {{.*}}void @_ZN6miniFE25generate_matrix_structureINS_9CSRMatrixIdiiEEEEiRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERS4_.outline_if.end55.split.otf0
; CHECK-NEXT: br label %try.cont.split.tfend

; CHECK-LABEL: define {{.*}}void @_ZN6miniFE25generate_matrix_structureINS_9CSRMatrixIdiiEEEEiRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERS4_.outline_if.end55.split.otf0(

; CHECK: ehcleanup81.otf0:
; CHECK-NEXT: invoke void undef()
; CHECK-NEXT: to label %invoke.cont83.otf0 unwind label %terminate.lpad.otf0

; CHECK: terminate.lpad.otf0:
; CHECK-NEXT: phi i64 [ 0, %ehcleanup81.otf0 ]
; CHECK-NOT: [
; CHECK-NEXT: landingpad
; CHECK-NEXT: catch
; CHECK-NEXT: unreachable

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #3

; Function Attrs: nounwind readnone
declare i32 @llvm.eh.typeid.for(i8*) #4

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #5

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #5

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #0

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #5

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #6

; Function Attrs: nofree nosync nounwind willreturn
declare i8* @llvm.stacksave() #7

; Function Attrs: nounwind willreturn
declare i8* @llvm.task.frameaddress(i32) #8

attributes #0 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { argmemonly nofree nounwind willreturn writeonly }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { nounwind readnone }
attributes #5 = { argmemonly willreturn }
attributes #6 = { nofree nosync nounwind readnone willreturn }
attributes #7 = { nofree nosync nounwind willreturn }
attributes #8 = { nounwind willreturn }
