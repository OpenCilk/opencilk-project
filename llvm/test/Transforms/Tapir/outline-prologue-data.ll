; Check that prologue data attached to a function with Tapir
; instructions does not get copied to a generated helper function.
;
; RUN: opt < %s -tapir2target -tapir-target=opencilk -opencilk-runtime-bc-path=%S/libopencilk-abi.bc -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.object = type { i8 }
%class.anon = type { i8 }

$_ZN6object4funcEv = comdat any

$_Z12parallel_forIZN6object4funcEvEUliE_EviiT_ = comdat any

$_ZZN6object4funcEvENKUliE_clEi = comdat any

$_ZTSFvvE = comdat any

$_ZTIFvvE = comdat any

$_ZTSFivE = comdat any

$_ZTIFivE = comdat any

$_ZTSFviiZN6object4funcEvEUliE_E = comdat any

$_ZTIFviiZN6object4funcEvEUliE_E = comdat any

@_ZTVN10__cxxabiv120__function_type_infoE = external dso_local global i8*
@_ZTSFvvE = linkonce_odr dso_local constant [5 x i8] c"FvvE\00", comdat, align 1
@_ZTIFvvE = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__function_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([5 x i8], [5 x i8]* @_ZTSFvvE, i32 0, i32 0) }, comdat, align 8
@0 = private constant i8* bitcast ({ i8*, i8* }* @_ZTIFvvE to i8*)
@_ZTSFivE = linkonce_odr dso_local constant [5 x i8] c"FivE\00", comdat, align 1
@_ZTIFivE = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__function_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([5 x i8], [5 x i8]* @_ZTSFivE, i32 0, i32 0) }, comdat, align 8
@1 = private constant i8* bitcast ({ i8*, i8* }* @_ZTIFivE to i8*)
@.src = private unnamed_addr constant [17 x i8] c"bug-20220610.cpp\00", align 1
@2 = private unnamed_addr constant { i16, i16, [11 x i8] } { i16 -1, i16 0, [11 x i8] c"'object *'\00" }
@3 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [11 x i8] }*, i8, i8 } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 11, i32 8 }, { i16, i16, [11 x i8] }* @2, i8 0, i8 4 }
@_ZTSFviiZN6object4funcEvEUliE_E = linkonce_odr dso_local constant [28 x i8] c"FviiZN6object4funcEvEUliE_E\00", comdat, align 1
@_ZTIFviiZN6object4funcEvEUliE_E = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__function_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([28 x i8], [28 x i8]* @_ZTSFviiZN6object4funcEvEUliE_E, i32 0, i32 0) }, comdat, align 8
@4 = private constant i8* bitcast ({ i8*, i8* }* @_ZTIFviiZN6object4funcEvEUliE_E to i8*)
@5 = private unnamed_addr constant { i16, i16, [6 x i8] } { i16 0, i16 11, [6 x i8] c"'int'\00" }
@6 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 4, i32 29 }, { i16, i16, [6 x i8] }* @5 }
@7 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 4, i32 29 }, { i16, i16, [6 x i8] }* @5 }
@8 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 4, i32 29 }, { i16, i16, [6 x i8] }* @5 }
@9 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 4, i32 29 }, { i16, i16, [6 x i8] }* @5 }
@10 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 4, i32 12 }, { i16, i16, [6 x i8] }* @5 }
@11 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 4, i32 12 }, { i16, i16, [6 x i8] }* @5 }
@12 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 4, i32 37 }, { i16, i16, [6 x i8] }* @5 }
@13 = private unnamed_addr constant { i16, i16, [45 x i8] } { i16 -1, i16 0, [45 x i8] c"'const (lambda at bug-20220610.cpp:12:26) *'\00" }
@14 = private unnamed_addr global { { [17 x i8]*, i32, i32 }, { i16, i16, [45 x i8] }*, i8, i8 } { { [17 x i8]*, i32, i32 } { [17 x i8]* @.src, i32 12, i32 26 }, { i16, i16, [45 x i8] }* @13, i8 0, i8 4 }

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define dso_local void @_Z3addv() #0 prologue <{ i32, i32 }> <{ i32 846595819, i32 trunc (i64 sub (i64 ptrtoint (i8** @0 to i64), i64 ptrtoint (void ()* @_Z3addv to i64)) to i32) }> {
entry:
  ret void
}

; Function Attrs: mustprogress noinline norecurse optnone uwtable
define dso_local noundef i32 @main() #1 prologue <{ i32, i32 }> <{ i32 846595819, i32 trunc (i64 sub (i64 ptrtoint (i8** @1 to i64), i64 ptrtoint (i32 ()* @main to i64)) to i32) }> {
entry:
  %retval = alloca i32, align 4
  %foo = alloca %class.object, align 1
  store i32 0, i32* %retval, align 4
  call void @_ZN6object4funcEv(%class.object* noundef nonnull align 1 dereferenceable(1) %foo)
  ret i32 0
}

; Function Attrs: mustprogress noinline optnone uwtable
define linkonce_odr dso_local void @_ZN6object4funcEv(%class.object* noundef nonnull align 1 dereferenceable(1) %this) #2 comdat align 2 {
entry:
  %this.addr = alloca %class.object*, align 8
  %agg.tmp = alloca %class.anon, align 1
  store %class.object* %this, %class.object** %this.addr, align 8
  %this1 = load %class.object*, %class.object** %this.addr, align 8
  %0 = icmp ne %class.object* %this1, null, !nosanitize !4
  br i1 %0, label %cont, label %handler.type_mismatch, !prof !5, !nosanitize !4

handler.type_mismatch:                            ; preds = %entry
  %1 = ptrtoint %class.object* %this1 to i64, !nosanitize !4
  call void @__ubsan_handle_type_mismatch_v1(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [11 x i8] }*, i8, i8 }* @3 to i8*), i64 %1) #7, !nosanitize !4
  br label %cont, !nosanitize !4

cont:                                             ; preds = %handler.type_mismatch, %entry
  call void @_Z12parallel_forIZN6object4funcEvEUliE_EviiT_(i32 noundef 0, i32 noundef 111)
  ret void
}

; Function Attrs: uwtable
declare dso_local void @__ubsan_handle_type_mismatch_v1(i8*, i64) #3

; Function Attrs: mustprogress noinline optnone uwtable
define linkonce_odr dso_local void @_Z12parallel_forIZN6object4funcEvEUliE_EviiT_(i32 noundef %start, i32 noundef %end) #2 comdat prologue <{ i32, i32 }> <{ i32 846595819, i32 trunc (i64 sub (i64 ptrtoint (i8** @4 to i64), i64 ptrtoint (void (i32, i32)* @_Z12parallel_forIZN6object4funcEvEUliE_EviiT_ to i64)) to i32) }> {
entry:
  %f = alloca %class.anon, align 1
  %start.addr = alloca i32, align 4
  %end.addr = alloca i32, align 4
  %syncreg = call token @llvm.syncregion.start()
  %__init = alloca i32, align 4
  %__limit = alloca i32, align 4
  %__begin = alloca i32, align 4
  %__end = alloca i32, align 4
  store i32 %start, i32* %start.addr, align 4
  store i32 %end, i32* %end.addr, align 4
  %0 = load i32, i32* %start.addr, align 4
  store i32 %0, i32* %__init, align 4
  %1 = load i32, i32* %end.addr, align 4
  store i32 %1, i32* %__limit, align 4
  %2 = load i32, i32* %__init, align 4
  %3 = load i32, i32* %__limit, align 4
  %cmp = icmp slt i32 %2, %3
  br i1 %cmp, label %pfor.ph, label %pfor.end

pfor.ph:                                          ; preds = %entry
  store i32 0, i32* %__begin, align 4
  %4 = load i32, i32* %__limit, align 4
  %5 = load i32, i32* %__init, align 4
  %6 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %4, i32 %5), !nosanitize !4
  %7 = extractvalue { i32, i1 } %6, 0, !nosanitize !4
  %8 = extractvalue { i32, i1 } %6, 1, !nosanitize !4
  %9 = xor i1 %8, true, !nosanitize !4
  br i1 %9, label %cont, label %handler.sub_overflow, !prof !5, !nosanitize !4

handler.sub_overflow:                             ; preds = %pfor.ph
  %10 = zext i32 %4 to i64, !nosanitize !4
  %11 = zext i32 %5 to i64, !nosanitize !4
  call void @__ubsan_handle_sub_overflow(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @6 to i8*), i64 %10, i64 %11) #7, !nosanitize !4
  br label %cont, !nosanitize !4

cont:                                             ; preds = %handler.sub_overflow, %pfor.ph
  %12 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %7, i32 1), !nosanitize !4
  %13 = extractvalue { i32, i1 } %12, 0, !nosanitize !4
  %14 = extractvalue { i32, i1 } %12, 1, !nosanitize !4
  %15 = xor i1 %14, true, !nosanitize !4
  br i1 %15, label %cont2, label %handler.sub_overflow1, !prof !5, !nosanitize !4

handler.sub_overflow1:                            ; preds = %cont
  %16 = zext i32 %7 to i64, !nosanitize !4
  call void @__ubsan_handle_sub_overflow(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @7 to i8*), i64 %16, i64 1) #7, !nosanitize !4
  br label %cont2, !nosanitize !4

cont2:                                            ; preds = %handler.sub_overflow1, %cont
  %17 = icmp ne i32 %13, -2147483648, !nosanitize !4
  %or = or i1 %17, true, !nosanitize !4
  %18 = and i1 true, %or, !nosanitize !4
  br i1 %18, label %cont3, label %handler.divrem_overflow, !prof !5, !nosanitize !4

handler.divrem_overflow:                          ; preds = %cont2
  %19 = zext i32 %13 to i64, !nosanitize !4
  call void @__ubsan_handle_divrem_overflow(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @8 to i8*), i64 %19, i64 1) #7, !nosanitize !4
  br label %cont3, !nosanitize !4

cont3:                                            ; preds = %handler.divrem_overflow, %cont2
  %div = sdiv i32 %13, 1
  %20 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %div, i32 1), !nosanitize !4
  %21 = extractvalue { i32, i1 } %20, 0, !nosanitize !4
  %22 = extractvalue { i32, i1 } %20, 1, !nosanitize !4
  %23 = xor i1 %22, true, !nosanitize !4
  br i1 %23, label %cont4, label %handler.add_overflow, !prof !5, !nosanitize !4

handler.add_overflow:                             ; preds = %cont3
  %24 = zext i32 %div to i64, !nosanitize !4
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @9 to i8*), i64 %24, i64 1) #7, !nosanitize !4
  br label %cont4, !nosanitize !4

cont4:                                            ; preds = %handler.add_overflow, %cont3
  store i32 %21, i32* %__end, align 4
  br label %pfor.cond

pfor.cond:                                        ; preds = %cont9, %cont4
  br label %pfor.detach

pfor.detach:                                      ; preds = %pfor.cond
  %25 = load i32, i32* %__init, align 4
  %26 = load i32, i32* %__begin, align 4
  %27 = call { i32, i1 } @llvm.smul.with.overflow.i32(i32 %26, i32 1), !nosanitize !4
  %28 = extractvalue { i32, i1 } %27, 0, !nosanitize !4
  %29 = extractvalue { i32, i1 } %27, 1, !nosanitize !4
  %30 = xor i1 %29, true, !nosanitize !4
  br i1 %30, label %cont5, label %handler.mul_overflow, !prof !5, !nosanitize !4

handler.mul_overflow:                             ; preds = %pfor.detach
  %31 = zext i32 %26 to i64, !nosanitize !4
  call void @__ubsan_handle_mul_overflow(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @10 to i8*), i64 %31, i64 1) #7, !nosanitize !4
  br label %cont5, !nosanitize !4

cont5:                                            ; preds = %handler.mul_overflow, %pfor.detach
  %32 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %25, i32 %28), !nosanitize !4
  %33 = extractvalue { i32, i1 } %32, 0, !nosanitize !4
  %34 = extractvalue { i32, i1 } %32, 1, !nosanitize !4
  %35 = xor i1 %34, true, !nosanitize !4
  br i1 %35, label %cont7, label %handler.add_overflow6, !prof !5, !nosanitize !4

handler.add_overflow6:                            ; preds = %cont5
  %36 = zext i32 %25 to i64, !nosanitize !4
  %37 = zext i32 %28 to i64, !nosanitize !4
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @11 to i8*), i64 %36, i64 %37) #7, !nosanitize !4
  br label %cont7, !nosanitize !4

cont7:                                            ; preds = %handler.add_overflow6, %cont5
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %cont7
  %i = alloca i32, align 4
  store i32 %33, i32* %i, align 4
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %38 = load i32, i32* %i, align 4
  call void @_ZZN6object4funcEvENKUliE_clEi(%class.anon* noundef nonnull align 1 dereferenceable(1) %f, i32 noundef %38)
  br label %pfor.preattach

pfor.preattach:                                   ; preds = %pfor.body
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.preattach, %cont7
  %39 = load i32, i32* %__begin, align 4
  %40 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %39, i32 1), !nosanitize !4
  %41 = extractvalue { i32, i1 } %40, 0, !nosanitize !4
  %42 = extractvalue { i32, i1 } %40, 1, !nosanitize !4
  %43 = xor i1 %42, true, !nosanitize !4
  br i1 %43, label %cont9, label %handler.add_overflow8, !prof !5, !nosanitize !4

handler.add_overflow8:                            ; preds = %pfor.inc
  %44 = zext i32 %39 to i64, !nosanitize !4
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @12 to i8*), i64 %44, i64 1) #7, !nosanitize !4
  br label %cont9, !nosanitize !4

cont9:                                            ; preds = %handler.add_overflow8, %pfor.inc
  store i32 %41, i32* %__begin, align 4
  %45 = load i32, i32* %__begin, align 4
  %46 = load i32, i32* %__end, align 4
  %cmp10 = icmp slt i32 %45, %46
  br i1 %cmp10, label %pfor.cond, label %pfor.cond.cleanup, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %cont9
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg)
  br label %pfor.end

pfor.end:                                         ; preds = %sync.continue, %entry
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #4

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32) #5

; Function Attrs: uwtable
declare dso_local void @__ubsan_handle_sub_overflow(i8*, i64, i64) #3

; Function Attrs: uwtable
declare dso_local void @__ubsan_handle_divrem_overflow(i8*, i64, i64) #3

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #5

; Function Attrs: uwtable
declare dso_local void @__ubsan_handle_add_overflow(i8*, i64, i64) #3

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare { i32, i1 } @llvm.smul.with.overflow.i32(i32, i32) #5

; Function Attrs: uwtable
declare dso_local void @__ubsan_handle_mul_overflow(i8*, i64, i64) #3

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZZN6object4funcEvENKUliE_clEi(%class.anon* noundef nonnull align 1 dereferenceable(1) %this, i32 noundef %i) #0 comdat align 2 {
entry:
  %this.addr = alloca %class.anon*, align 8
  %i.addr = alloca i32, align 4
  store %class.anon* %this, %class.anon** %this.addr, align 8
  store i32 %i, i32* %i.addr, align 4
  %this1 = load %class.anon*, %class.anon** %this.addr, align 8
  %0 = icmp ne %class.anon* %this1, null, !nosanitize !4
  br i1 %0, label %cont, label %handler.type_mismatch, !prof !5, !nosanitize !4

handler.type_mismatch:                            ; preds = %entry
  %1 = ptrtoint %class.anon* %this1 to i64, !nosanitize !4
  call void @__ubsan_handle_type_mismatch_v1(i8* bitcast ({ { [17 x i8]*, i32, i32 }, { i16, i16, [45 x i8] }*, i8, i8 }* @14 to i8*), i64 %1) #7, !nosanitize !4
  br label %cont, !nosanitize !4

cont:                                             ; preds = %handler.type_mismatch, %entry
  call void @_Z3addv()
  ret void
}

; CHECK: define internal fastcc void @_Z12parallel_forIZN6object4funcEvEUliE_EviiT_.outline_pfor.body.entry.otd1(
; CHECK-NOT: prologue
; CHECK {

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #6

attributes #0 = { mustprogress noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress noinline norecurse optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { mustprogress noinline optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { uwtable }
attributes #4 = { argmemonly nounwind willreturn }
attributes #5 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #6 = { argmemonly willreturn }
attributes #7 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{!"clang version 14.0.4 (git@github.com:OpenCilk/opencilk-project.git bb40f6253a942b78bd0be7d50945fed88960a60e)"}
!4 = !{}
!5 = !{!"branch_weights", i32 1048575, i32 1}
!6 = distinct !{!6, !7}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
