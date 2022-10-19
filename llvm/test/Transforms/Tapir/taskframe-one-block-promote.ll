; Check that promoting calls to invokes properly ignores instructions
; outside of a taskframe, even when the start and end of that
; taskframe are within the same function.
;
; RUN: opt < %s -passes="csi-setup" -S | FileCheck %s

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx12.0.0"

%struct.THPDevice = type <{ %struct._object, %"struct.c10::Device", [6 x i8] }>
%struct._object = type { i64, %struct._typeobject* }
%struct._typeobject = type { %struct.PyVarObject, i8*, i64, i64, void (%struct._object*)*, i64, %struct._object* (%struct._object*, i8*)*, i32 (%struct._object*, i8*, %struct._object*)*, %struct.PyAsyncMethods*, %struct._object* (%struct._object*)*, %struct.PyNumberMethods*, %struct.PySequenceMethods*, %struct.PyMappingMethods*, i64 (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*, %struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, i32 (%struct._object*, %struct._object*, %struct._object*)*, %struct.PyBufferProcs*, i64, i8*, i32 (%struct._object*, i32 (%struct._object*, i8*)*, i8*)*, i32 (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*, i32)*, i64, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*)*, %struct.PyMethodDef*, %struct.PyMemberDef*, %struct.PyGetSetDef*, %struct._typeobject*, %struct._object*, %struct._object* (%struct._object*, %struct._object*, %struct._object*)*, i32 (%struct._object*, %struct._object*, %struct._object*)*, i64, i32 (%struct._object*, %struct._object*, %struct._object*)*, %struct._object* (%struct._typeobject*, i64)*, %struct._object* (%struct._typeobject*, %struct._object*, %struct._object*)*, void (i8*)*, i32 (%struct._object*)*, %struct._object*, %struct._object*, %struct._object*, %struct._object*, %struct._object*, void (%struct._object*)*, i32, void (%struct._object*)*, %struct._object* (%struct._object*, %struct._object**, i64, %struct._object*)*, i32 (%struct._object*, %struct.__sFILE*, i32)* }
%struct.PyVarObject = type { %struct._object, i64 }
%struct.PyAsyncMethods = type { %struct._object* (%struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*)* }
%struct.PyNumberMethods = type { %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*, %struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*)*, i32 (%struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*)*, i8*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)* }
%struct.PySequenceMethods = type { i64 (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, i64)*, %struct._object* (%struct._object*, i64)*, i8*, i32 (%struct._object*, i64, %struct._object*)*, i8*, i32 (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, i64)* }
%struct.PyMappingMethods = type { i64 (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, i32 (%struct._object*, %struct._object*, %struct._object*)* }
%struct.PyBufferProcs = type { i32 (%struct._object*, %struct.bufferinfo*, i32)*, void (%struct._object*, %struct.bufferinfo*)* }
%struct.bufferinfo = type { i8*, %struct._object*, i64, i64, i32, i32, i8*, i64*, i64*, i64*, i8* }
%struct.PyMethodDef = type { i8*, %struct._object* (%struct._object*, %struct._object*)*, i32, i8* }
%struct.PyMemberDef = type { i8*, i32, i64, i32, i8* }
%struct.PyGetSetDef = type { i8*, %struct._object* (%struct._object*, i8*)*, i32 (%struct._object*, %struct._object*, i8*)*, i8*, i8* }
%struct.__sFILE = type { i8*, i32, i32, i16, i16, %struct.__sbuf, i32, i8*, i32 (i8*)*, i32 (i8*, i8*, i32)*, i64 (i8*, i64, i32)*, i32 (i8*, i8*, i32)*, %struct.__sbuf, %struct.__sFILEX*, i32, [3 x i8], [1 x i8], %struct.__sbuf, i32, i64 }
%struct.__sFILEX = type opaque
%struct.__sbuf = type { i8*, i32 }
%"struct.c10::Device" = type { i8, i8 }
%"struct.torch::PyWarningHandler" = type <{ %"struct.torch::PyWarningHandler::InternalHandler", %"class.c10::WarningHandler"*, i8, [7 x i8] }>
%"struct.torch::PyWarningHandler::InternalHandler" = type { %"class.c10::WarningHandler", %"class.std::__1::vector.466" }
%"class.c10::WarningHandler" = type { i32 (...)** }
%"class.std::__1::vector.466" = type { %"struct.torch::WarningMeta"*, %"struct.torch::WarningMeta"*, %"class.std::__1::__compressed_pair.467" }
%"struct.torch::WarningMeta" = type <{ %"struct.c10::SourceLocation", %"class.std::__1::basic_string", i8, [7 x i8] }>
%"struct.c10::SourceLocation" = type { i8*, i8*, i32 }
%"class.std::__1::basic_string" = type { %"class.std::__1::__compressed_pair" }
%"class.std::__1::__compressed_pair" = type { %"struct.std::__1::__compressed_pair_elem" }
%"struct.std::__1::__compressed_pair_elem" = type { %"struct.std::__1::basic_string<char>::__rep" }
%"struct.std::__1::basic_string<char>::__rep" = type { %union.anon }
%union.anon = type { %"struct.std::__1::basic_string<char>::__long" }
%"struct.std::__1::basic_string<char>::__long" = type { i8*, i64, i64 }
%"class.std::__1::__compressed_pair.467" = type { %"struct.std::__1::__compressed_pair_elem.468" }
%"struct.std::__1::__compressed_pair_elem.468" = type { %"struct.torch::WarningMeta"* }
%"class.std::exception" = type { i32 (...)** }
%"class.std::exception_ptr" = type { i8* }
%"struct.std::__1::hash.617" = type { i8 }

@_ZTISt9exception = external constant i8*

; Function Attrs: mustprogress noinline optnone sanitize_cilk sanitize_thread ssp uwtable
define noundef i64 @_ZL14THPDevice_hashP9THPDevice(%struct.THPDevice* noundef %self) #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %retval = alloca i64, align 8
  %self.addr = alloca %struct.THPDevice*, align 8
  %__enforce_warning_buffer = alloca %"struct.torch::PyWarningHandler", align 8
  %exn.slot = alloca i8*, align 8
  %ehselector.slot = alloca i32, align 4
  %e = alloca %"class.std::exception"*, align 8
  %ref.tmp5 = alloca %"class.std::exception_ptr", align 8
  store %struct.THPDevice* %self, %struct.THPDevice** %self.addr, align 8
  %call = call noundef %"struct.torch::PyWarningHandler"* @_ZN5torch16PyWarningHandlerC1Ev(%"struct.torch::PyWarningHandler"* noundef nonnull align 8 dereferenceable(41) %__enforce_warning_buffer) #9
  %0 = call token @llvm.taskframe.create()
  %ref.tmp = alloca %"struct.std::__1::hash.617", align 1
  %agg.tmp = alloca %"struct.c10::Device", align 1
  %agg.tmp.coerce = alloca i64, align 8
  %cleanup.dest.slot = alloca i32, align 4
  %1 = load %struct.THPDevice*, %struct.THPDevice** %self.addr, align 8
  %device = getelementptr inbounds %struct.THPDevice, %struct.THPDevice* %1, i32 0, i32 1
  %2 = bitcast %"struct.c10::Device"* %agg.tmp to i8*
  %3 = bitcast %"struct.c10::Device"* %device to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %2, i8* align 8 %3, i64 2, i1 false), !tbaa.struct !0
  %4 = bitcast i64* %agg.tmp.coerce to i8*
  %5 = bitcast %"struct.c10::Device"* %agg.tmp to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %4, i8* align 1 %5, i64 2, i1 false)
  %6 = load i64, i64* %agg.tmp.coerce, align 8
  %call1 = call noundef i64 @_ZNKSt3__14hashIN3c106DeviceEEclES2_(%"struct.std::__1::hash.617"* noundef nonnull align 1 dereferenceable(1) %ref.tmp, i64 %6) #9
  %call2 = call noundef i64 @_ZNSt3__114numeric_limitsIlE3maxEv() #9
  %rem = urem i64 %call1, %call2
  store i64 %rem, i64* %retval, align 8
  store i32 1, i32* %cleanup.dest.slot, align 4
  call void @llvm.taskframe.end(token %0)
  %call3 = invoke noundef %"struct.torch::PyWarningHandler"* @_ZN5torch16PyWarningHandlerD1Ev(%"struct.torch::PyWarningHandler"* noundef nonnull align 8 dereferenceable(41) %__enforce_warning_buffer)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  br label %return

lpad:                                             ; preds = %entry
  %7 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTISt9exception to i8*)
  %8 = extractvalue { i8*, i32 } %7, 0
  store i8* %8, i8** %exn.slot, align 8
  %9 = extractvalue { i8*, i32 } %7, 1
  store i32 %9, i32* %ehselector.slot, align 4
  br label %catch.dispatch

catch.dispatch:                                   ; preds = %lpad
  %sel = load i32, i32* %ehselector.slot, align 4
  %10 = call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTISt9exception to i8*)) #9
  %matches = icmp eq i32 %sel, %10
  br i1 %matches, label %catch, label %eh.resume

catch:                                            ; preds = %catch.dispatch
  %exn = load i8*, i8** %exn.slot, align 8
  %11 = call i8* @__cxa_begin_catch(i8* %exn) #9
  %exn.byref = bitcast i8* %11 to %"class.std::exception"*
  store %"class.std::exception"* %exn.byref, %"class.std::exception"** %e, align 8
  call void @_ZSt17current_exceptionv(%"class.std::exception_ptr"* sret(%"class.std::exception_ptr") align 8 %ref.tmp5) #9
  invoke void @_ZN5torch29translate_exception_to_pythonERKSt13exception_ptr(%"class.std::exception_ptr"* noundef nonnull align 8 dereferenceable(8) %ref.tmp5)
          to label %invoke.cont7 unwind label %lpad6

invoke.cont7:                                     ; preds = %catch
  %call8 = call noundef %"class.std::exception_ptr"* @_ZNSt13exception_ptrD1Ev(%"class.std::exception_ptr"* noundef nonnull align 8 dereferenceable(8) %ref.tmp5) #9
  store i64 -1, i64* %retval, align 8
  call void @__cxa_end_catch()
  br label %return

lpad6:                                            ; preds = %catch
  %12 = landingpad { i8*, i32 }
          cleanup
  %13 = extractvalue { i8*, i32 } %12, 0
  store i8* %13, i8** %exn.slot, align 8
  %14 = extractvalue { i8*, i32 } %12, 1
  store i32 %14, i32* %ehselector.slot, align 4
  %call9 = call noundef %"class.std::exception_ptr"* @_ZNSt13exception_ptrD1Ev(%"class.std::exception_ptr"* noundef nonnull align 8 dereferenceable(8) %ref.tmp5) #9
  invoke void @__cxa_end_catch()
          to label %invoke.cont10 unwind label %terminate.lpad

invoke.cont10:                                    ; preds = %lpad6
  br label %eh.resume

try.cont:                                         ; No predecessors!
  call void @llvm.trap()
  unreachable

return:                                           ; preds = %invoke.cont7, %invoke.cont
  %15 = load i64, i64* %retval, align 8
  ret i64 %15

eh.resume:                                        ; preds = %invoke.cont10, %catch.dispatch
  %exn11 = load i8*, i8** %exn.slot, align 8
  %sel12 = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn11, 0
  %lpad.val13 = insertvalue { i8*, i32 } %lpad.val, i32 %sel12, 1
  resume { i8*, i32 } %lpad.val13

terminate.lpad:                                   ; preds = %lpad6
  %16 = landingpad { i8*, i32 }
          catch i8* null
  %17 = extractvalue { i8*, i32 } %16, 0
  call void @__clang_call_terminate(i8* %17) #10
  unreachable
}

; CHECK: define noundef i64 @_ZL14THPDevice_hashP9THPDevice(
; CHECK-NOT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8* %0) #1 {
  %2 = call i8* @__cxa_begin_catch(i8* %0) #9
  call void @_ZSt9terminatev() #10
  unreachable
}

declare i8* @__cxa_begin_catch(i8*)

declare void @__cxa_end_catch()

declare void @_ZSt9terminatev()

declare i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind readnone
declare i32 @llvm.eh.typeid.for(i8*) #2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #3

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #4

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #5

; Function Attrs: nounwind
declare noundef %"struct.torch::PyWarningHandler"* @_ZN5torch16PyWarningHandlerC1Ev(%"struct.torch::PyWarningHandler"* noundef nonnull returned align 8 dereferenceable(41)) unnamed_addr #6

declare noundef %"struct.torch::PyWarningHandler"* @_ZN5torch16PyWarningHandlerD1Ev(%"struct.torch::PyWarningHandler"* noundef nonnull returned align 8 dereferenceable(41)) unnamed_addr #7

declare void @_ZN5torch29translate_exception_to_pythonERKSt13exception_ptr(%"class.std::exception_ptr"* noundef nonnull align 8 dereferenceable(8)) #7

; Function Attrs: mustprogress noinline nounwind optnone sanitize_cilk sanitize_thread ssp uwtable
declare noundef i64 @_ZNKSt3__14hashIN3c106DeviceEEclES2_(%"struct.std::__1::hash.617"* noundef nonnull align 1 dereferenceable(1), i64) #8

; Function Attrs: nounwind
declare noundef %"class.std::exception_ptr"* @_ZNSt13exception_ptrD1Ev(%"class.std::exception_ptr"* noundef nonnull returned align 8 dereferenceable(8)) unnamed_addr #6

; Function Attrs: mustprogress noinline nounwind optnone sanitize_cilk sanitize_thread ssp uwtable
declare noundef i64 @_ZNSt3__114numeric_limitsIlE3maxEv() #8

; Function Attrs: nounwind
declare void @_ZSt17current_exceptionv(%"class.std::exception_ptr"* sret(%"class.std::exception_ptr") align 8) #6

attributes #0 = { mustprogress noinline optnone sanitize_cilk sanitize_thread ssp uwtable "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+v8.5a,+zcm,+zcz" }
attributes #1 = { noinline noreturn nounwind }
attributes #2 = { nounwind readnone }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { argmemonly nofree nounwind willreturn }
attributes #5 = { cold noreturn nounwind }
attributes #6 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+v8.5a,+zcm,+zcz" }
attributes #7 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+v8.5a,+zcm,+zcz" }
attributes #8 = { mustprogress noinline nounwind optnone sanitize_cilk sanitize_thread ssp uwtable "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+v8.5a,+zcm,+zcz" }
attributes #9 = { nounwind }
attributes #10 = { noreturn nounwind }

!0 = !{i64 0, i64 1, null, i64 1, i64 1, null}
