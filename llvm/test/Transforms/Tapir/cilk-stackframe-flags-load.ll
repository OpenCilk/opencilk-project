; Check that the flags in a __cilkrts_stack_frame are reloaded after a
; call to a spawning function.
;
; RUN: opt < %s -enable-new-pm=0 -tapir2target -tapir-target=opencilk -opencilk-runtime-bc-path=%S/libopencilk-abi.bc -simplifycfg -function-attrs -always-inline -gvn -S | FileCheck %s
; RUN: opt < %s -passes='tapir2target,function(simplifycfg),cgscc(function-attrs),always-inline,function(gvn)' -tapir-target=opencilk -opencilk-runtime-bc-path=%S/libopencilk-abi.bc -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt*, %struct._IO_wide_data*, %struct._IO_FILE*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type opaque
%struct._IO_codecvt = type opaque
%struct._IO_wide_data = type opaque
%struct.COMPLEX = type { float, float }

@.str = private unnamed_addr constant [15 x i8] c"n=%d error=%e\0A\00", align 1
@.str.2 = private unnamed_addr constant [10 x i8] c"%f + %fi\0A\00", align 1
@.str.4 = private unnamed_addr constant [9 x i8] c"n=%d ok\0A\00", align 1
@.str.6 = private unnamed_addr constant [41 x i8] c"options:  number of elements   n = %ld\0A\0A\00", align 1
@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE*, align 8
@.str.7 = private unnamed_addr constant [48 x i8] c"\0Ausage: fft [<cilk-options>] [-n #] [-c] [-h]\0A\0A\00", align 1
@.str.8 = private unnamed_addr constant [61 x i8] c"this program is a highly optimized version of the classical\0A\00", align 1
@.str.9 = private unnamed_addr constant [72 x i8] c"cooley-tukey fast fourier transform algorithm.  some documentation can\0A\00", align 1
@.str.10 = private unnamed_addr constant [68 x i8] c"be found in the source code. the program is optimized for an exact\0A\00", align 1
@.str.11 = private unnamed_addr constant [57 x i8] c"power of 2.  to test for correctness use parameter -c.\0A\0A\00", align 1
@.str.12 = private unnamed_addr constant [3 x i8] c"-n\00", align 1
@.str.13 = private unnamed_addr constant [3 x i8] c"-c\00", align 1
@.str.14 = private unnamed_addr constant [3 x i8] c"-h\00", align 1
@specifiers = dso_local global [4 x i8*] [i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.12, i32 0, i32 0), i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.13, i32 0, i32 0), i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.14, i32 0, i32 0), i8* null], align 16
@opt_types = dso_local global [4 x i32] [i32 3, i32 4, i32 4, i32 0], align 16
@.str.15 = private unnamed_addr constant [17 x i8] c"Testing cos: %f\0A\00", align 1
@str = private unnamed_addr constant [4 x i8] c"ct:\00", align 1
@str.16 = private unnamed_addr constant [5 x i8] c"seq:\00", align 1
@str.17 = private unnamed_addr constant [19 x i8] c"\0Acilk example: fft\00", align 1

; Function Attrs: nounwind uwtable
define dso_local void @cilk_fft(i32 %n, %struct.COMPLEX* %in, %struct.COMPLEX* %out) local_unnamed_addr #0 {
entry:
  %factors = alloca [40 x i32], align 16
  %syncreg = tail call token @llvm.syncregion.start()
  %0 = bitcast [40 x i32]* %factors to i8*
  call void @llvm.lifetime.start.p0i8(i64 160, i8* nonnull %0) #11
  %arraydecay = getelementptr inbounds [40 x i32], [40 x i32]* %factors, i64 0, i64 0
  %add = add nsw i32 %n, 1
  %conv = sext i32 %add to i64
  %mul = shl nsw i64 %conv, 3
  %call = tail call noalias i8* @malloc(i64 %mul) #11
  %1 = bitcast i8* %call to %struct.COMPLEX*
  detach within %syncreg, label %det.achd, label %do.body.preheader

det.achd:                                         ; preds = %entry
  %div = sdiv i32 %n, 2
  tail call fastcc void @compute_w_coefficients(i32 %n, i32 0, i32 %div, %struct.COMPLEX* %1)
  reattach within %syncreg, label %do.body.preheader

do.body.preheader:                                ; preds = %det.achd, %entry
  br label %do.body

do.body:                                          ; preds = %do.body.preheader, %factor.exit
  %l.0 = phi i32 [ %div2, %factor.exit ], [ %n, %do.body.preheader ]
  %p.0 = phi i32* [ %incdec.ptr, %factor.exit ], [ %arraydecay, %do.body.preheader ]
  %cmp.i = icmp slt i32 %l.0, 2
  br i1 %cmp.i, label %factor.exit, label %if.end.i

if.end.i:                                         ; preds = %do.body
  switch i32 %l.0, label %if.end12.i [
    i32 4096, label %factor.exit
    i32 2048, label %factor.exit
    i32 1024, label %factor.exit
    i32 256, label %factor.exit
    i32 128, label %factor.exit
    i32 64, label %factor.exit
  ]

if.end12.i:                                       ; preds = %if.end.i
  %and.i = and i32 %l.0, 15
  %cmp13.i = icmp eq i32 %and.i, 0
  br i1 %cmp13.i, label %factor.exit, label %if.end15.i

if.end15.i:                                       ; preds = %if.end12.i
  %and16.i = and i32 %l.0, 7
  %cmp17.i = icmp eq i32 %and16.i, 0
  br i1 %cmp17.i, label %factor.exit, label %if.end19.i

if.end19.i:                                       ; preds = %if.end15.i
  %and20.i = and i32 %l.0, 3
  %cmp21.i = icmp eq i32 %and20.i, 0
  br i1 %cmp21.i, label %factor.exit, label %if.end23.i

if.end23.i:                                       ; preds = %if.end19.i
  %and24.i = and i32 %l.0, 1
  %cmp25.i = icmp eq i32 %and24.i, 0
  br i1 %cmp25.i, label %factor.exit, label %for.cond.preheader.i

for.cond.preheader.i:                             ; preds = %if.end23.i
  %cmp2853.i = icmp sgt i32 %l.0, 3
  br i1 %cmp2853.i, label %for.body.i, label %factor.exit

for.body.i:                                       ; preds = %for.cond.preheader.i, %for.inc.i
  %r.054.i = phi i32 [ %add.i, %for.inc.i ], [ 3, %for.cond.preheader.i ]
  %rem.i = srem i32 %l.0, %r.054.i
  %cmp29.i = icmp eq i32 %rem.i, 0
  br i1 %cmp29.i, label %factor.exit, label %for.inc.i

for.inc.i:                                        ; preds = %for.body.i
  %add.i = add nuw nsw i32 %r.054.i, 2
  %cmp28.i = icmp slt i32 %add.i, %l.0
  br i1 %cmp28.i, label %for.body.i, label %factor.exit, !llvm.loop !2

factor.exit:                                      ; preds = %for.body.i, %for.inc.i, %do.body, %if.end.i, %if.end.i, %if.end.i, %if.end.i, %if.end.i, %if.end.i, %if.end12.i, %if.end15.i, %if.end19.i, %if.end23.i, %for.cond.preheader.i
  %retval.0.i = phi i32 [ 1, %do.body ], [ 8, %if.end.i ], [ 8, %if.end.i ], [ 8, %if.end.i ], [ 8, %if.end.i ], [ 8, %if.end.i ], [ 8, %if.end.i ], [ 16, %if.end12.i ], [ 8, %if.end15.i ], [ 4, %if.end19.i ], [ 2, %if.end23.i ], [ %l.0, %for.cond.preheader.i ], [ %r.054.i, %for.body.i ], [ %l.0, %for.inc.i ]
  %incdec.ptr = getelementptr inbounds i32, i32* %p.0, i64 1
  store i32 %retval.0.i, i32* %p.0, align 4, !tbaa !4
  %div2 = sdiv i32 %l.0, %retval.0.i
  %cmp = icmp sgt i32 %div2, 1
  br i1 %cmp, label %do.body, label %do.end, !llvm.loop !8

do.end:                                           ; preds = %factor.exit
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %do.end
  call fastcc void @fft_aux(i32 %n, %struct.COMPLEX* %in, %struct.COMPLEX* %out, i32* nonnull %arraydecay, %struct.COMPLEX* %1, i32 %n)
  tail call void @free(i8* %call) #11
  call void @llvm.lifetime.end.p0i8(i64 160, i8* nonnull %0) #11
  ret void
}

; CHECK: define dso_local void @cilk_fft(

; CHECK: entry:
; CHECK: %[[CILK_SF:.+]] = alloca %struct.__cilkrts_stack_frame
; CHECK: %[[FLAGS:.+]] = getelementptr {{.*}}%struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %[[CILK_SF]], i64 0, i32 0

; CHECK: sync.continue:
; CHECK: call {{.*}}void @fft_aux(
; CHECK: %[[FLAG_LOAD:.+]] = load i32, i32* %[[FLAGS]]
; CHECK: %[[TRUNC:.+]] = trunc i32 %[[FLAG_LOAD]] to i8
; CHECK-NEXT: %[[CMP:.+]] = icmp sgt i8 %[[TRUNC]], -1
; CHECK-NEXT: br i1 %[[CMP]], label %[[TRUE:.+]], label %[[FALSE:.[a-zA-Z0-9_\.]+]]

; CHECK: [[FALSE]]:
; CHECK: call i32 @llvm.eh.sjlj.setjmp(

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: inaccessiblememonly nofree nounwind willreturn
declare dso_local noalias noundef i8* @malloc(i64) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: nounwind uwtable
declare fastcc void @compute_w_coefficients(i32 %n, i32 %a, i32 %b, %struct.COMPLEX* %W) unnamed_addr #0

; Function Attrs: argmemonly nounwind uwtable
 define internal fastcc void @fft_aux(i32 %n, %struct.COMPLEX* %in, %struct.COMPLEX* %out, i32* nocapture readonly %factors, %struct.COMPLEX* readonly %W, i32 %nW) unnamed_addr #4 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  switch i32 %n, label %if.end12 [
    i32 32, label %if.then
    i32 16, label %if.then2
    i32 8, label %if.then5
    i32 4, label %if.then8
    i32 2, label %if.then11
  ]

if.then:                                          ; preds = %entry
  %0 = bitcast %struct.COMPLEX* %in to <2 x float>*
  %1 = load <2 x float>, <2 x float>* %0, align 4, !tbaa !16
  %shuffle = shufflevector <2 x float> %1, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %re3.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 16, i32 0
  %2 = bitcast float* %re3.i to <2 x float>*
  %3 = load <2 x float>, <2 x float>* %2, align 4, !tbaa !16
  %shuffle448 = shufflevector <2 x float> %3, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %4 = fadd <4 x float> %shuffle, %shuffle448
  %5 = fsub <4 x float> %shuffle, %shuffle448
  %6 = shufflevector <4 x float> %4, <4 x float> %5, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %re9.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 8, i32 0
  %7 = bitcast float* %re9.i to <2 x float>*
  %8 = load <2 x float>, <2 x float>* %7, align 4, !tbaa !16
  %shuffle449 = shufflevector <2 x float> %8, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %re13.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 24, i32 0
  %9 = bitcast float* %re13.i to <2 x float>*
  %10 = load <2 x float>, <2 x float>* %9, align 4, !tbaa !16
  %shuffle450 = shufflevector <2 x float> %10, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %11 = fadd <4 x float> %shuffle449, %shuffle450
  %12 = fsub <4 x float> %shuffle449, %shuffle450
  %13 = shufflevector <4 x float> %11, <4 x float> %12, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %14 = fadd <4 x float> %6, %13
  %15 = fsub <4 x float> %6, %13
  %16 = shufflevector <4 x float> %14, <4 x float> %15, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %17 = fsub <4 x float> %6, %13
  %18 = fadd <4 x float> %6, %13
  %19 = shufflevector <4 x float> %17, <4 x float> %18, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %re29.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 4, i32 0
  %20 = bitcast float* %re29.i to <2 x float>*
  %21 = load <2 x float>, <2 x float>* %20, align 4, !tbaa !16
  %reorder_shuffle470 = shufflevector <2 x float> %21, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %re33.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 20, i32 0
  %22 = bitcast float* %re33.i to <2 x float>*
  %23 = load <2 x float>, <2 x float>* %22, align 4, !tbaa !16
  %reorder_shuffle471 = shufflevector <2 x float> %23, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %24 = fadd <2 x float> %reorder_shuffle470, %reorder_shuffle471
  %25 = fsub <2 x float> %reorder_shuffle470, %reorder_shuffle471
  %sub38.i = extractelement <2 x float> %25, i32 1
  %26 = fsub <2 x float> %reorder_shuffle470, %reorder_shuffle471
  %sub39.i = extractelement <2 x float> %26, i32 0
  %re41.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 12, i32 0
  %27 = bitcast float* %re41.i to <2 x float>*
  %28 = load <2 x float>, <2 x float>* %27, align 4, !tbaa !16
  %reorder_shuffle472 = shufflevector <2 x float> %28, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %re45.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 28, i32 0
  %29 = bitcast float* %re45.i to <2 x float>*
  %30 = load <2 x float>, <2 x float>* %29, align 4, !tbaa !16
  %reorder_shuffle473 = shufflevector <2 x float> %30, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %31 = fadd <2 x float> %reorder_shuffle472, %reorder_shuffle473
  %32 = fsub <2 x float> %reorder_shuffle472, %reorder_shuffle473
  %sub50.i = extractelement <2 x float> %32, i32 1
  %33 = fsub <2 x float> %reorder_shuffle472, %reorder_shuffle473
  %sub51.i = extractelement <2 x float> %33, i32 0
  %34 = fadd <2 x float> %24, %31
  %35 = fsub <2 x float> %24, %31
  %add56.i = fadd float %sub38.i, %sub51.i
  %sub57.i = fsub float %sub39.i, %sub50.i
  %sub58.i = fsub float %sub38.i, %sub51.i
  %add59.i = fadd float %sub39.i, %sub50.i
  %add64.i = fadd float %sub57.i, %add56.i
  %conv.i = fpext float %add64.i to double
  %mul.i = fmul double %conv.i, 0x3FE6A09E667F4BB8
  %conv65.i = fptrunc double %mul.i to float
  %sub66.i = fsub float %sub57.i, %add56.i
  %conv67.i = fpext float %sub66.i to double
  %mul68.i = fmul double %conv67.i, 0x3FE6A09E667F4BB8
  %conv69.i = fptrunc double %mul68.i to float
  %36 = extractelement <2 x float> %34, i32 1
  %37 = insertelement <4 x float> poison, float %36, i32 0
  %38 = extractelement <2 x float> %34, i32 0
  %39 = insertelement <4 x float> %37, float %38, i32 1
  %40 = insertelement <4 x float> %39, float %conv65.i, i32 2
  %41 = insertelement <4 x float> %40, float %conv69.i, i32 3
  %42 = fadd <4 x float> %16, %41
  %43 = fsub <4 x float> %16, %41
  %sub78.i = fsub float %add59.i, %sub58.i
  %conv79.i = fpext float %sub78.i to double
  %mul80.i = fmul double %conv79.i, 0x3FE6A09E667F4BB8
  %conv81.i = fptrunc double %mul80.i to float
  %add82.i = fadd float %add59.i, %sub58.i
  %conv83.i = fpext float %add82.i to double
  %mul84.i = fmul double %conv83.i, 0x3FE6A09E667F4BB8
  %conv85.i = fptrunc double %mul84.i to float
  %44 = extractelement <2 x float> %35, i32 0
  %45 = insertelement <4 x float> poison, float %44, i32 0
  %46 = extractelement <2 x float> %35, i32 1
  %47 = insertelement <4 x float> %45, float %46, i32 1
  %48 = insertelement <4 x float> %47, float %conv81.i, i32 2
  %49 = insertelement <4 x float> %48, float %conv85.i, i32 3
  %50 = fadd <4 x float> %19, %49
  %51 = fsub <4 x float> %19, %49
  %52 = shufflevector <4 x float> %50, <4 x float> %51, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %53 = fsub <4 x float> %19, %49
  %54 = fadd <4 x float> %19, %49
  %55 = shufflevector <4 x float> %53, <4 x float> %54, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %re91.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 2, i32 0
  %56 = bitcast float* %re91.i to <2 x float>*
  %57 = load <2 x float>, <2 x float>* %56, align 4, !tbaa !16
  %reorder_shuffle460 = shufflevector <2 x float> %57, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %re95.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 18, i32 0
  %58 = bitcast float* %re95.i to <2 x float>*
  %59 = load <2 x float>, <2 x float>* %58, align 4, !tbaa !16
  %reorder_shuffle461 = shufflevector <2 x float> %59, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %60 = fadd <2 x float> %reorder_shuffle460, %reorder_shuffle461
  %61 = fsub <2 x float> %reorder_shuffle460, %reorder_shuffle461
  %re103.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 10, i32 0
  %62 = bitcast float* %re103.i to <2 x float>*
  %63 = load <2 x float>, <2 x float>* %62, align 4, !tbaa !16
  %re107.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 26, i32 0
  %64 = bitcast float* %re107.i to <2 x float>*
  %65 = load <2 x float>, <2 x float>* %64, align 4, !tbaa !16
  %66 = fadd <2 x float> %63, %65
  %67 = shufflevector <2 x float> %66, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %68 = fsub <2 x float> %63, %65
  %69 = fadd <2 x float> %60, %67
  %70 = fsub <2 x float> %60, %67
  %sub116.i = extractelement <2 x float> %70, i32 1
  %71 = fsub <2 x float> %60, %67
  %sub117.i = extractelement <2 x float> %71, i32 0
  %72 = fsub <2 x float> %61, %68
  %73 = fadd <2 x float> %61, %68
  %74 = shufflevector <2 x float> %72, <2 x float> %73, <2 x i32> <i32 0, i32 3>
  %75 = fsub <2 x float> %61, %68
  %sub120.i = extractelement <2 x float> %75, i32 1
  %76 = fadd <2 x float> %61, %68
  %add121.i = extractelement <2 x float> %76, i32 0
  %re123.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 6, i32 0
  %77 = bitcast float* %re123.i to <2 x float>*
  %78 = load <2 x float>, <2 x float>* %77, align 4, !tbaa !16
  %reorder_shuffle464 = shufflevector <2 x float> %78, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %re127.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 22, i32 0
  %79 = bitcast float* %re127.i to <2 x float>*
  %80 = load <2 x float>, <2 x float>* %79, align 4, !tbaa !16
  %reorder_shuffle465 = shufflevector <2 x float> %80, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %81 = fadd <2 x float> %reorder_shuffle464, %reorder_shuffle465
  %82 = fsub <2 x float> %reorder_shuffle464, %reorder_shuffle465
  %sub132.i = extractelement <2 x float> %82, i32 1
  %83 = fsub <2 x float> %reorder_shuffle464, %reorder_shuffle465
  %sub133.i = extractelement <2 x float> %83, i32 0
  %re135.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 14, i32 0
  %84 = bitcast float* %re135.i to <2 x float>*
  %85 = load <2 x float>, <2 x float>* %84, align 4, !tbaa !16
  %reorder_shuffle466 = shufflevector <2 x float> %85, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %re139.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 30, i32 0
  %86 = bitcast float* %re139.i to <2 x float>*
  %87 = load <2 x float>, <2 x float>* %86, align 4, !tbaa !16
  %reorder_shuffle467 = shufflevector <2 x float> %87, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %88 = fadd <2 x float> %reorder_shuffle466, %reorder_shuffle467
  %89 = fsub <2 x float> %reorder_shuffle466, %reorder_shuffle467
  %sub144.i = extractelement <2 x float> %89, i32 1
  %90 = fsub <2 x float> %reorder_shuffle466, %reorder_shuffle467
  %sub145.i = extractelement <2 x float> %90, i32 0
  %91 = fadd <2 x float> %81, %88
  %92 = fsub <2 x float> %81, %88
  %sub148.i = extractelement <2 x float> %92, i32 1
  %93 = fsub <2 x float> %81, %88
  %sub149.i = extractelement <2 x float> %93, i32 0
  %add150.i = fadd float %sub132.i, %sub145.i
  %sub151.i = fsub float %sub133.i, %sub144.i
  %sub152.i = fsub float %sub132.i, %sub145.i
  %add153.i = fadd float %sub133.i, %sub144.i
  %94 = fadd <2 x float> %69, %91
  %95 = fsub <2 x float> %69, %91
  %96 = insertelement <2 x float> poison, float %sub151.i, i32 0
  %97 = shufflevector <2 x float> %96, <2 x float> undef, <2 x i32> zeroinitializer
  %98 = insertelement <2 x float> poison, float %add150.i, i32 0
  %99 = shufflevector <2 x float> %98, <2 x float> undef, <2 x i32> zeroinitializer
  %100 = fsub <2 x float> %97, %99
  %101 = fadd <2 x float> %97, %99
  %102 = shufflevector <2 x float> %100, <2 x float> %101, <2 x i32> <i32 0, i32 3>
  %103 = fpext <2 x float> %102 to <2 x double>
  %104 = fmul <2 x double> %103, <double 0x3FE6A09E667F4BB8, double 0x3FE6A09E667F4BB8>
  %105 = fptrunc <2 x double> %104 to <2 x float>
  %106 = fadd <2 x float> %74, %105
  %add166.i = extractelement <2 x float> %106, i32 1
  %107 = fadd <2 x float> %74, %105
  %add167.i = extractelement <2 x float> %107, i32 0
  %108 = fsub <2 x float> %74, %105
  %add170.i = fadd float %sub116.i, %sub149.i
  %sub171.i = fsub float %sub117.i, %sub148.i
  %sub172.i = fsub float %sub116.i, %sub149.i
  %add173.i = fadd float %sub117.i, %sub148.i
  %sub174.i = fsub float %add153.i, %sub152.i
  %conv175.i = fpext float %sub174.i to double
  %mul176.i = fmul double %conv175.i, 0x3FE6A09E667F4BB8
  %conv177.i = fptrunc double %mul176.i to float
  %add178.i = fadd float %add153.i, %sub152.i
  %conv179.i = fpext float %add178.i to double
  %mul180.i = fmul double %conv179.i, 0x3FE6A09E667F4BB8
  %conv181.i = fptrunc double %mul180.i to float
  %add182.i = fadd float %sub120.i, %conv177.i
  %sub183.i = fsub float %add121.i, %conv181.i
  %sub184.i = fsub float %sub120.i, %conv177.i
  %add185.i = fadd float %add121.i, %conv181.i
  %conv190.i = fpext float %add166.i to double
  %mul191.i = fmul double %conv190.i, 0x3FED906BCF32832F
  %conv192.i = fpext float %add167.i to double
  %mul193.i = fmul double %conv192.i, 0x3FD87DE2A6AEA312
  %add194.i = fadd double %mul191.i, %mul193.i
  %conv195.i = fptrunc double %add194.i to float
  %mul197.i = fmul double %conv192.i, 0x3FED906BCF32832F
  %mul199.i = fmul double %conv190.i, 0x3FD87DE2A6AEA312
  %sub200.i = fsub double %mul197.i, %mul199.i
  %conv201.i = fptrunc double %sub200.i to float
  %109 = extractelement <2 x float> %94, i32 1
  %110 = insertelement <4 x float> poison, float %109, i32 0
  %111 = extractelement <2 x float> %94, i32 0
  %112 = insertelement <4 x float> %110, float %111, i32 1
  %113 = insertelement <4 x float> %112, float %conv195.i, i32 2
  %114 = insertelement <4 x float> %113, float %conv201.i, i32 3
  %115 = fadd <4 x float> %42, %114
  %116 = fsub <4 x float> %42, %114
  %add206.i = fadd float %sub171.i, %add170.i
  %conv207.i = fpext float %add206.i to double
  %mul208.i = fmul double %conv207.i, 0x3FE6A09E667F4BB8
  %sub210.i = fsub float %sub171.i, %add170.i
  %conv211.i = fpext float %sub210.i to double
  %mul212.i = fmul double %conv211.i, 0x3FE6A09E667F4BB8
  %conv218.i = fpext float %add182.i to double
  %mul219.i = fmul double %conv218.i, 0x3FD87DE2A6AEA312
  %conv220.i = fpext float %sub183.i to double
  %mul221.i = fmul double %conv220.i, 0x3FED906BCF32832F
  %add222.i = fadd double %mul219.i, %mul221.i
  %mul225.i = fmul double %conv220.i, 0x3FD87DE2A6AEA312
  %mul227.i = fmul double %conv218.i, 0x3FED906BCF32832F
  %sub228.i = fsub double %mul225.i, %mul227.i
  %117 = insertelement <4 x double> poison, double %mul208.i, i32 0
  %118 = insertelement <4 x double> %117, double %mul212.i, i32 1
  %119 = insertelement <4 x double> %118, double %add222.i, i32 2
  %120 = insertelement <4 x double> %119, double %sub228.i, i32 3
  %121 = fptrunc <4 x double> %120 to <4 x float>
  %122 = fadd <4 x float> %52, %121
  %123 = fsub <4 x float> %52, %121
  %124 = extractelement <4 x float> %43, i32 0
  %125 = extractelement <2 x float> %95, i32 0
  %sub236.i = fsub float %124, %125
  %126 = extractelement <4 x float> %43, i32 1
  %127 = extractelement <2 x float> %95, i32 1
  %add237.i = fadd float %126, %127
  %128 = fpext <2 x float> %108 to <2 x double>
  %129 = fmul <2 x double> %128, <double 0x3FED906BCF32832F, double 0x3FED906BCF32832F>
  %130 = fmul <2 x double> %128, <double 0x3FD87DE2A6AEA312, double 0x3FD87DE2A6AEA312>
  %131 = shufflevector <2 x double> %130, <2 x double> undef, <2 x i32> <i32 1, i32 0>
  %132 = fsub <2 x double> %129, %131
  %133 = fadd <2 x double> %129, %131
  %134 = shufflevector <2 x double> %132, <2 x double> %133, <2 x i32> <i32 0, i32 3>
  %135 = fptrunc <2 x double> %134 to <2 x float>
  %136 = shufflevector <2 x float> %95, <2 x float> %135, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %137 = fadd <4 x float> %43, %136
  %138 = fsub <4 x float> %43, %136
  %139 = shufflevector <4 x float> %137, <4 x float> %138, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %sub254.i = fsub float %add173.i, %sub172.i
  %conv255.i = fpext float %sub254.i to double
  %mul256.i = fmul double %conv255.i, 0x3FE6A09E667F4BB8
  %add258.i = fadd float %add173.i, %sub172.i
  %conv259.i = fpext float %add258.i to double
  %mul260.i = fmul double %conv259.i, 0x3FE6A09E667F4BB8
  %conv266.i = fpext float %add185.i to double
  %mul267.i = fmul double %conv266.i, 0x3FD87DE2A6AEA312
  %conv268.i = fpext float %sub184.i to double
  %mul269.i = fmul double %conv268.i, 0x3FED906BCF32832F
  %sub270.i = fsub double %mul267.i, %mul269.i
  %mul273.i = fmul double %conv268.i, 0x3FD87DE2A6AEA312
  %mul275.i = fmul double %conv266.i, 0x3FED906BCF32832F
  %add276.i = fadd double %mul273.i, %mul275.i
  %140 = insertelement <4 x double> poison, double %mul256.i, i32 0
  %141 = insertelement <4 x double> %140, double %mul260.i, i32 1
  %142 = insertelement <4 x double> %141, double %sub270.i, i32 2
  %143 = insertelement <4 x double> %142, double %add276.i, i32 3
  %144 = fptrunc <4 x double> %143 to <4 x float>
  %145 = shufflevector <4 x float> %43, <4 x float> %53, <4 x i32> <i32 2, i32 3, i32 4, i32 undef>
  %146 = shufflevector <4 x float> %145, <4 x float> %54, <4 x i32> <i32 0, i32 1, i32 2, i32 5>
  %147 = shufflevector <2 x float> %135, <2 x float> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  %148 = shufflevector <4 x float> %147, <4 x float> %144, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  %149 = fsub <4 x float> %146, %148
  %150 = fadd <4 x float> %146, %148
  %151 = shufflevector <4 x float> %149, <4 x float> %150, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %152 = fadd <4 x float> %55, %144
  %153 = fsub <4 x float> %55, %144
  %154 = shufflevector <4 x float> %152, <4 x float> %153, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %155 = fsub <4 x float> %55, %144
  %sub280.i = extractelement <4 x float> %155, i32 2
  %156 = fadd <4 x float> %55, %144
  %add281.i = extractelement <4 x float> %156, i32 3
  %re283.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 1, i32 0
  %157 = bitcast float* %re283.i to <2 x float>*
  %158 = load <2 x float>, <2 x float>* %157, align 4, !tbaa !16
  %shuffle451 = shufflevector <2 x float> %158, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %re287.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 17, i32 0
  %159 = bitcast float* %re287.i to <2 x float>*
  %160 = load <2 x float>, <2 x float>* %159, align 4, !tbaa !16
  %shuffle452 = shufflevector <2 x float> %160, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %161 = fadd <4 x float> %shuffle451, %shuffle452
  %162 = fsub <4 x float> %shuffle451, %shuffle452
  %163 = shufflevector <4 x float> %161, <4 x float> %162, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %re295.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 9, i32 0
  %164 = bitcast float* %re295.i to <2 x float>*
  %165 = load <2 x float>, <2 x float>* %164, align 4, !tbaa !16
  %shuffle453 = shufflevector <2 x float> %165, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %re299.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 25, i32 0
  %166 = bitcast float* %re299.i to <2 x float>*
  %167 = load <2 x float>, <2 x float>* %166, align 4, !tbaa !16
  %shuffle454 = shufflevector <2 x float> %167, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %168 = fadd <4 x float> %shuffle453, %shuffle454
  %169 = fsub <4 x float> %shuffle453, %shuffle454
  %170 = shufflevector <4 x float> %168, <4 x float> %169, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %171 = fadd <4 x float> %161, %168
  %172 = shufflevector <4 x float> %171, <4 x float> undef, <2 x i32> <i32 0, i32 1>
  %173 = shufflevector <4 x float> %162, <4 x float> undef, <2 x i32> <i32 3, i32 2>
  %174 = shufflevector <4 x float> %169, <4 x float> undef, <2 x i32> <i32 3, i32 2>
  %175 = fsub <2 x float> %173, %174
  %176 = fadd <2 x float> %173, %174
  %177 = shufflevector <2 x float> %175, <2 x float> %176, <2 x i32> <i32 0, i32 3>
  %178 = fsub <4 x float> %163, %170
  %179 = fadd <4 x float> %163, %170
  %180 = shufflevector <4 x float> %178, <4 x float> %179, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %re315.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 5, i32 0
  %181 = bitcast float* %re315.i to <2 x float>*
  %182 = load <2 x float>, <2 x float>* %181, align 4, !tbaa !16
  %re319.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 21, i32 0
  %183 = bitcast float* %re319.i to <2 x float>*
  %184 = load <2 x float>, <2 x float>* %183, align 4, !tbaa !16
  %185 = fadd <2 x float> %182, %184
  %186 = fsub <2 x float> %182, %184
  %sub324.i = extractelement <2 x float> %186, i32 0
  %187 = fsub <2 x float> %182, %184
  %sub325.i = extractelement <2 x float> %187, i32 1
  %re327.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 13, i32 0
  %188 = bitcast float* %re327.i to <2 x float>*
  %189 = load <2 x float>, <2 x float>* %188, align 4, !tbaa !16
  %re331.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 29, i32 0
  %190 = bitcast float* %re331.i to <2 x float>*
  %191 = load <2 x float>, <2 x float>* %190, align 4, !tbaa !16
  %192 = fadd <2 x float> %189, %191
  %193 = fsub <2 x float> %189, %191
  %sub336.i = extractelement <2 x float> %193, i32 0
  %194 = fsub <2 x float> %189, %191
  %sub337.i = extractelement <2 x float> %194, i32 1
  %195 = fadd <2 x float> %185, %192
  %196 = fsub <2 x float> %185, %192
  %add342.i = fadd float %sub324.i, %sub337.i
  %sub343.i = fsub float %sub325.i, %sub336.i
  %sub344.i = fsub float %sub324.i, %sub337.i
  %add345.i = fadd float %sub325.i, %sub336.i
  %197 = fadd <2 x float> %172, %195
  %198 = fsub <2 x float> %172, %195
  %sub348.i = extractelement <2 x float> %198, i32 0
  %199 = fsub <2 x float> %172, %195
  %sub349.i = extractelement <2 x float> %199, i32 1
  %200 = insertelement <2 x float> poison, float %sub343.i, i32 0
  %201 = shufflevector <2 x float> %200, <2 x float> undef, <2 x i32> zeroinitializer
  %202 = insertelement <2 x float> poison, float %add342.i, i32 0
  %203 = shufflevector <2 x float> %202, <2 x float> undef, <2 x i32> zeroinitializer
  %204 = fsub <2 x float> %201, %203
  %205 = fadd <2 x float> %201, %203
  %206 = shufflevector <2 x float> %204, <2 x float> %205, <2 x i32> <i32 0, i32 3>
  %207 = fpext <2 x float> %206 to <2 x double>
  %208 = fmul <2 x double> %207, <double 0x3FE6A09E667F4BB8, double 0x3FE6A09E667F4BB8>
  %209 = fptrunc <2 x double> %208 to <2 x float>
  %210 = fadd <2 x float> %177, %209
  %add358.i = extractelement <2 x float> %210, i32 1
  %211 = fadd <2 x float> %177, %209
  %add359.i = extractelement <2 x float> %211, i32 0
  %212 = fsub <2 x float> %177, %209
  %sub366.i = fsub float %add345.i, %sub344.i
  %conv367.i = fpext float %sub366.i to double
  %mul368.i = fmul double %conv367.i, 0x3FE6A09E667F4BB8
  %conv369.i = fptrunc double %mul368.i to float
  %add370.i = fadd float %add345.i, %sub344.i
  %conv371.i = fpext float %add370.i to double
  %mul372.i = fmul double %conv371.i, 0x3FE6A09E667F4BB8
  %conv373.i = fptrunc double %mul372.i to float
  %213 = extractelement <2 x float> %196, i32 1
  %214 = insertelement <4 x float> poison, float %213, i32 0
  %215 = extractelement <2 x float> %196, i32 0
  %216 = insertelement <4 x float> %214, float %215, i32 1
  %217 = insertelement <4 x float> %216, float %conv369.i, i32 2
  %218 = insertelement <4 x float> %217, float %conv373.i, i32 3
  %219 = fadd <4 x float> %180, %218
  %220 = fsub <4 x float> %180, %218
  %221 = shufflevector <4 x float> %219, <4 x float> %220, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %222 = fsub <4 x float> %180, %218
  %223 = fadd <4 x float> %180, %218
  %224 = shufflevector <4 x float> %222, <4 x float> %223, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %re379.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 3, i32 0
  %225 = bitcast float* %re379.i to <2 x float>*
  %226 = load <2 x float>, <2 x float>* %225, align 4, !tbaa !16
  %re383.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 19, i32 0
  %227 = bitcast float* %re383.i to <2 x float>*
  %228 = load <2 x float>, <2 x float>* %227, align 4, !tbaa !16
  %229 = fadd <2 x float> %226, %228
  %230 = fsub <2 x float> %226, %228
  %re391.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 11, i32 0
  %231 = bitcast float* %re391.i to <2 x float>*
  %232 = load <2 x float>, <2 x float>* %231, align 4, !tbaa !16
  %re395.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 27, i32 0
  %233 = bitcast float* %re395.i to <2 x float>*
  %234 = load <2 x float>, <2 x float>* %233, align 4, !tbaa !16
  %235 = fadd <2 x float> %232, %234
  %236 = fsub <2 x float> %232, %234
  %237 = shufflevector <2 x float> %236, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %238 = fadd <2 x float> %229, %235
  %239 = fsub <2 x float> %229, %235
  %sub404.i = extractelement <2 x float> %239, i32 0
  %240 = fsub <2 x float> %229, %235
  %sub405.i = extractelement <2 x float> %240, i32 1
  %241 = fadd <2 x float> %230, %237
  %242 = fsub <2 x float> %230, %237
  %243 = shufflevector <2 x float> %241, <2 x float> %242, <2 x i32> <i32 0, i32 3>
  %244 = fsub <2 x float> %230, %237
  %sub408.i = extractelement <2 x float> %244, i32 0
  %245 = fadd <2 x float> %230, %237
  %add409.i = extractelement <2 x float> %245, i32 1
  %re411.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 7, i32 0
  %246 = bitcast float* %re411.i to <2 x float>*
  %247 = load <2 x float>, <2 x float>* %246, align 4, !tbaa !16
  %re415.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 23, i32 0
  %248 = bitcast float* %re415.i to <2 x float>*
  %249 = load <2 x float>, <2 x float>* %248, align 4, !tbaa !16
  %250 = fadd <2 x float> %247, %249
  %251 = fsub <2 x float> %247, %249
  %sub420.i = extractelement <2 x float> %251, i32 0
  %252 = fsub <2 x float> %247, %249
  %sub421.i = extractelement <2 x float> %252, i32 1
  %re423.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 15, i32 0
  %253 = bitcast float* %re423.i to <2 x float>*
  %254 = load <2 x float>, <2 x float>* %253, align 4, !tbaa !16
  %re427.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 31, i32 0
  %255 = bitcast float* %re427.i to <2 x float>*
  %256 = load <2 x float>, <2 x float>* %255, align 4, !tbaa !16
  %257 = fadd <2 x float> %254, %256
  %258 = fsub <2 x float> %254, %256
  %sub432.i = extractelement <2 x float> %258, i32 0
  %259 = fsub <2 x float> %254, %256
  %sub433.i = extractelement <2 x float> %259, i32 1
  %260 = fadd <2 x float> %250, %257
  %261 = fsub <2 x float> %250, %257
  %sub436.i = extractelement <2 x float> %261, i32 0
  %262 = fsub <2 x float> %250, %257
  %sub437.i = extractelement <2 x float> %262, i32 1
  %add438.i = fadd float %sub420.i, %sub433.i
  %sub439.i = fsub float %sub421.i, %sub432.i
  %sub440.i = fsub float %sub420.i, %sub433.i
  %add441.i = fadd float %sub421.i, %sub432.i
  %263 = fadd <2 x float> %238, %260
  %264 = fsub <2 x float> %238, %260
  %sub444.i = extractelement <2 x float> %264, i32 0
  %265 = fsub <2 x float> %238, %260
  %sub445.i = extractelement <2 x float> %265, i32 1
  %266 = insertelement <2 x float> poison, float %sub439.i, i32 0
  %267 = shufflevector <2 x float> %266, <2 x float> undef, <2 x i32> zeroinitializer
  %268 = insertelement <2 x float> poison, float %add438.i, i32 0
  %269 = shufflevector <2 x float> %268, <2 x float> undef, <2 x i32> zeroinitializer
  %270 = fadd <2 x float> %267, %269
  %271 = fsub <2 x float> %267, %269
  %272 = shufflevector <2 x float> %270, <2 x float> %271, <2 x i32> <i32 0, i32 3>
  %273 = fpext <2 x float> %272 to <2 x double>
  %274 = fmul <2 x double> %273, <double 0x3FE6A09E667F4BB8, double 0x3FE6A09E667F4BB8>
  %275 = fptrunc <2 x double> %274 to <2 x float>
  %276 = fadd <2 x float> %243, %275
  %add454.i = extractelement <2 x float> %276, i32 0
  %277 = fadd <2 x float> %243, %275
  %add455.i = extractelement <2 x float> %277, i32 1
  %278 = fsub <2 x float> %243, %275
  %add458.i = fadd float %sub404.i, %sub437.i
  %sub459.i = fsub float %sub405.i, %sub436.i
  %sub460.i = fsub float %sub404.i, %sub437.i
  %add461.i = fadd float %sub405.i, %sub436.i
  %sub462.i = fsub float %add441.i, %sub440.i
  %conv463.i = fpext float %sub462.i to double
  %mul464.i = fmul double %conv463.i, 0x3FE6A09E667F4BB8
  %conv465.i = fptrunc double %mul464.i to float
  %add466.i = fadd float %add441.i, %sub440.i
  %conv467.i = fpext float %add466.i to double
  %mul468.i = fmul double %conv467.i, 0x3FE6A09E667F4BB8
  %conv469.i = fptrunc double %mul468.i to float
  %add470.i = fadd float %sub408.i, %conv465.i
  %sub471.i = fsub float %add409.i, %conv469.i
  %sub472.i = fsub float %sub408.i, %conv465.i
  %add473.i = fadd float %add409.i, %conv469.i
  %279 = fadd <2 x float> %197, %263
  %280 = fsub <2 x float> %197, %263
  %conv478.i = fpext float %add454.i to double
  %mul479.i = fmul double %conv478.i, 0x3FED906BCF32832F
  %conv480.i = fpext float %add455.i to double
  %mul481.i = fmul double %conv480.i, 0x3FD87DE2A6AEA312
  %add482.i = fadd double %mul479.i, %mul481.i
  %conv483.i = fptrunc double %add482.i to float
  %mul485.i = fmul double %conv480.i, 0x3FED906BCF32832F
  %mul487.i = fmul double %conv478.i, 0x3FD87DE2A6AEA312
  %sub488.i = fsub double %mul485.i, %mul487.i
  %conv489.i = fptrunc double %sub488.i to float
  %add490.i = fadd float %add358.i, %conv483.i
  %add491.i = fadd float %add359.i, %conv489.i
  %sub492.i = fsub float %add358.i, %conv483.i
  %sub493.i = fsub float %add359.i, %conv489.i
  %add494.i = fadd float %sub459.i, %add458.i
  %conv495.i = fpext float %add494.i to double
  %mul496.i = fmul double %conv495.i, 0x3FE6A09E667F4BB8
  %sub498.i = fsub float %sub459.i, %add458.i
  %conv499.i = fpext float %sub498.i to double
  %mul500.i = fmul double %conv499.i, 0x3FE6A09E667F4BB8
  %conv506.i = fpext float %add470.i to double
  %mul507.i = fmul double %conv506.i, 0x3FD87DE2A6AEA312
  %conv508.i = fpext float %sub471.i to double
  %mul509.i = fmul double %conv508.i, 0x3FED906BCF32832F
  %add510.i = fadd double %mul507.i, %mul509.i
  %mul513.i = fmul double %conv508.i, 0x3FD87DE2A6AEA312
  %mul515.i = fmul double %conv506.i, 0x3FED906BCF32832F
  %sub516.i = fsub double %mul513.i, %mul515.i
  %281 = insertelement <4 x double> poison, double %mul496.i, i32 0
  %282 = insertelement <4 x double> %281, double %mul500.i, i32 1
  %283 = insertelement <4 x double> %282, double %add510.i, i32 2
  %284 = insertelement <4 x double> %283, double %sub516.i, i32 3
  %285 = fptrunc <4 x double> %284 to <4 x float>
  %286 = fadd <4 x float> %221, %285
  %287 = fsub <4 x float> %221, %285
  %288 = shufflevector <4 x float> %287, <4 x float> undef, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  %add522.i = fadd float %sub348.i, %sub445.i
  %sub523.i = fsub float %sub349.i, %sub444.i
  %sub524.i = fsub float %sub348.i, %sub445.i
  %add525.i = fadd float %sub349.i, %sub444.i
  %289 = fpext <2 x float> %278 to <2 x double>
  %290 = fmul <2 x double> %289, <double 0x3FED906BCF32832F, double 0x3FED906BCF32832F>
  %291 = fmul <2 x double> %289, <double 0x3FD87DE2A6AEA312, double 0x3FD87DE2A6AEA312>
  %292 = shufflevector <2 x double> %291, <2 x double> undef, <2 x i32> <i32 1, i32 0>
  %293 = fadd <2 x double> %290, %292
  %294 = fsub <2 x double> %290, %292
  %295 = shufflevector <2 x double> %293, <2 x double> %294, <2 x i32> <i32 0, i32 3>
  %296 = fptrunc <2 x double> %295 to <2 x float>
  %297 = extractelement <2 x float> %296, i32 1
  %298 = extractelement <2 x float> %212, i32 1
  %add538.i = fadd float %298, %297
  %299 = fsub <2 x float> %212, %296
  %sub539.i = extractelement <2 x float> %299, i32 0
  %sub542.i = fsub float %add461.i, %sub460.i
  %conv543.i = fpext float %sub542.i to double
  %mul544.i = fmul double %conv543.i, 0x3FE6A09E667F4BB8
  %add546.i = fadd float %add461.i, %sub460.i
  %conv547.i = fpext float %add546.i to double
  %mul548.i = fmul double %conv547.i, 0x3FE6A09E667F4BB8
  %conv554.i = fpext float %add473.i to double
  %mul555.i = fmul double %conv554.i, 0x3FD87DE2A6AEA312
  %conv556.i = fpext float %sub472.i to double
  %mul557.i = fmul double %conv556.i, 0x3FED906BCF32832F
  %sub558.i = fsub double %mul555.i, %mul557.i
  %mul561.i = fmul double %conv556.i, 0x3FD87DE2A6AEA312
  %mul563.i = fmul double %conv554.i, 0x3FED906BCF32832F
  %add564.i = fadd double %mul561.i, %mul563.i
  %300 = insertelement <4 x double> poison, double %mul544.i, i32 0
  %301 = insertelement <4 x double> %300, double %mul548.i, i32 1
  %302 = insertelement <4 x double> %301, double %sub558.i, i32 2
  %303 = insertelement <4 x double> %302, double %add564.i, i32 3
  %304 = fptrunc <4 x double> %303 to <4 x float>
  %305 = shufflevector <2 x float> %212, <2 x float> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  %306 = shufflevector <4 x float> %305, <4 x float> %223, <4 x i32> <i32 0, i32 1, i32 5, i32 undef>
  %307 = shufflevector <4 x float> %306, <4 x float> %222, <4 x i32> <i32 0, i32 1, i32 2, i32 4>
  %308 = shufflevector <2 x float> %296, <2 x float> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  %309 = shufflevector <4 x float> %308, <4 x float> %304, <4 x i32> <i32 0, i32 1, i32 5, i32 4>
  %310 = fadd <4 x float> %307, %309
  %311 = fsub <4 x float> %307, %309
  %312 = shufflevector <4 x float> %310, <4 x float> %311, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %313 = fadd <4 x float> %224, %304
  %314 = fsub <4 x float> %224, %304
  %315 = shufflevector <4 x float> %313, <4 x float> %314, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %316 = fsub <4 x float> %224, %304
  %sub568.i = extractelement <4 x float> %316, i32 2
  %317 = fadd <4 x float> %224, %304
  %add569.i = extractelement <4 x float> %317, i32 3
  %re578.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 16, i32 0
  %conv582.i = fpext float %add490.i to double
  %mul583.i = fmul double %conv582.i, 0x3FEF6297CFF75494
  %conv584.i = fpext float %add491.i to double
  %mul585.i = fmul double %conv584.i, 0x3FC8F8B83C6993FD
  %add586.i = fadd double %mul583.i, %mul585.i
  %conv587.i = fptrunc double %add586.i to float
  %mul589.i = fmul double %conv584.i, 0x3FEF6297CFF75494
  %mul591.i = fmul double %conv582.i, 0x3FC8F8B83C6993FD
  %sub592.i = fsub double %mul589.i, %mul591.i
  %conv593.i = fptrunc double %sub592.i to float
  %318 = extractelement <2 x float> %279, i32 0
  %319 = insertelement <4 x float> poison, float %318, i32 0
  %320 = extractelement <2 x float> %279, i32 1
  %321 = insertelement <4 x float> %319, float %320, i32 1
  %322 = insertelement <4 x float> %321, float %conv587.i, i32 2
  %323 = insertelement <4 x float> %322, float %conv593.i, i32 3
  %324 = fadd <4 x float> %115, %323
  %325 = bitcast %struct.COMPLEX* %out to <4 x float>*
  store <4 x float> %324, <4 x float>* %325, align 4, !tbaa !16
  %326 = fsub <4 x float> %115, %323
  %327 = bitcast float* %re578.i to <4 x float>*
  store <4 x float> %326, <4 x float>* %327, align 4, !tbaa !16
  %328 = fpext <4 x float> %286 to <4 x double>
  %329 = fmul <4 x double> %328, <double 0x3FED906BCF32832F, double 0x3FED906BCF32832F, double 0x3FEA9B66290EB1A3, double 0x3FEA9B66290EB1A3>
  %330 = fmul <4 x double> %328, <double 0x3FD87DE2A6AEA312, double 0x3FD87DE2A6AEA312, double 0x3FE1C73B39AE76C7, double 0x3FE1C73B39AE76C7>
  %331 = shufflevector <4 x double> %330, <4 x double> undef, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  %332 = fadd <4 x double> %329, %331
  %333 = fsub <4 x double> %329, %331
  %334 = shufflevector <4 x double> %332, <4 x double> %333, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %335 = fptrunc <4 x double> %334 to <4 x float>
  %re620.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 2, i32 0
  %re626.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 18, i32 0
  %336 = fadd <4 x float> %122, %335
  %337 = bitcast float* %re620.i to <4 x float>*
  store <4 x float> %336, <4 x float>* %337, align 4, !tbaa !16
  %338 = fsub <4 x float> %122, %335
  %339 = bitcast float* %re626.i to <4 x float>*
  store <4 x float> %338, <4 x float>* %339, align 4, !tbaa !16
  %add654.i = fadd float %sub523.i, %add522.i
  %conv655.i = fpext float %add654.i to double
  %mul656.i = fmul double %conv655.i, 0x3FE6A09E667F4BB8
  %sub658.i = fsub float %sub523.i, %add522.i
  %conv659.i = fpext float %sub658.i to double
  %mul660.i = fmul double %conv659.i, 0x3FE6A09E667F4BB8
  %conv674.i = fpext float %add538.i to double
  %mul675.i = fmul double %conv674.i, 0x3FE1C73B39AE76C7
  %conv676.i = fpext float %sub539.i to double
  %mul677.i = fmul double %conv676.i, 0x3FEA9B66290EB1A3
  %add678.i = fadd double %mul675.i, %mul677.i
  %mul681.i = fmul double %conv676.i, 0x3FE1C73B39AE76C7
  %mul683.i = fmul double %conv674.i, 0x3FEA9B66290EB1A3
  %sub684.i = fsub double %mul681.i, %mul683.i
  %340 = insertelement <4 x double> poison, double %mul656.i, i32 0
  %341 = insertelement <4 x double> %340, double %mul660.i, i32 1
  %342 = insertelement <4 x double> %341, double %add678.i, i32 2
  %343 = insertelement <4 x double> %342, double %sub684.i, i32 3
  %344 = fptrunc <4 x double> %343 to <4 x float>
  %re664.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 4, i32 0
  %re670.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 20, i32 0
  %345 = fadd <4 x float> %139, %344
  %346 = bitcast float* %re664.i to <4 x float>*
  store <4 x float> %345, <4 x float>* %346, align 4, !tbaa !16
  %347 = fsub <4 x float> %139, %344
  %348 = bitcast float* %re670.i to <4 x float>*
  store <4 x float> %347, <4 x float>* %348, align 4, !tbaa !16
  %349 = fpext <4 x float> %315 to <4 x double>
  %350 = fmul <4 x double> %349, <double 0x3FD87DE2A6AEA312, double 0x3FD87DE2A6AEA312, double 0x3FC8F8B83C6993FD, double 0x3FC8F8B83C6993FD>
  %351 = fmul <4 x double> %349, <double 0x3FED906BCF32832F, double 0x3FED906BCF32832F, double 0x3FEF6297CFF75494, double 0x3FEF6297CFF75494>
  %352 = shufflevector <4 x double> %351, <4 x double> undef, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  %353 = fadd <4 x double> %350, %352
  %354 = fsub <4 x double> %350, %352
  %355 = shufflevector <4 x double> %353, <4 x double> %354, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %356 = fptrunc <4 x double> %355 to <4 x float>
  %re712.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 6, i32 0
  %re718.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 22, i32 0
  %357 = fadd <4 x float> %154, %356
  %358 = bitcast float* %re712.i to <4 x float>*
  store <4 x float> %357, <4 x float>* %358, align 4, !tbaa !16
  %359 = fsub <4 x float> %154, %356
  %360 = bitcast float* %re718.i to <4 x float>*
  store <4 x float> %359, <4 x float>* %360, align 4, !tbaa !16
  %re748.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 8, i32 0
  %re754.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 24, i32 0
  %conv758.i = fpext float %sub493.i to double
  %mul759.i = fmul double %conv758.i, 0x3FEF6297CFF75494
  %conv760.i = fpext float %sub492.i to double
  %mul761.i = fmul double %conv760.i, 0x3FC8F8B83C6993FD
  %sub762.i = fsub double %mul759.i, %mul761.i
  %conv763.i = fptrunc double %sub762.i to float
  %mul765.i = fmul double %conv760.i, 0x3FEF6297CFF75494
  %mul767.i = fmul double %conv758.i, 0x3FC8F8B83C6993FD
  %add768.i = fadd double %mul765.i, %mul767.i
  %conv769.i = fptrunc double %add768.i to float
  %361 = extractelement <2 x float> %280, i32 1
  %362 = insertelement <4 x float> poison, float %361, i32 0
  %363 = extractelement <2 x float> %280, i32 0
  %364 = insertelement <4 x float> %362, float %363, i32 1
  %365 = insertelement <4 x float> %364, float %conv763.i, i32 2
  %366 = insertelement <4 x float> %365, float %conv769.i, i32 3
  %367 = fadd <4 x float> %116, %366
  %368 = fsub <4 x float> %116, %366
  %369 = shufflevector <4 x float> %367, <4 x float> %368, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %370 = bitcast float* %re748.i to <4 x float>*
  store <4 x float> %369, <4 x float>* %370, align 4, !tbaa !16
  %371 = fsub <4 x float> %116, %366
  %372 = fadd <4 x float> %116, %366
  %373 = shufflevector <4 x float> %371, <4 x float> %372, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %374 = bitcast float* %re754.i to <4 x float>*
  store <4 x float> %373, <4 x float>* %374, align 4, !tbaa !16
  %375 = fpext <4 x float> %288 to <4 x double>
  %376 = fmul <4 x double> %375, <double 0x3FED906BCF32832F, double 0x3FED906BCF32832F, double 0x3FEA9B66290EB1A3, double 0x3FEA9B66290EB1A3>
  %377 = fmul <4 x double> %375, <double 0x3FD87DE2A6AEA312, double 0x3FD87DE2A6AEA312, double 0x3FE1C73B39AE76C7, double 0x3FE1C73B39AE76C7>
  %378 = shufflevector <4 x double> %377, <4 x double> undef, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  %379 = fsub <4 x double> %376, %378
  %380 = fadd <4 x double> %376, %378
  %381 = shufflevector <4 x double> %379, <4 x double> %380, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %382 = fptrunc <4 x double> %381 to <4 x float>
  %re796.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 10, i32 0
  %re802.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 26, i32 0
  %383 = fadd <4 x float> %123, %382
  %384 = fsub <4 x float> %123, %382
  %385 = shufflevector <4 x float> %383, <4 x float> %384, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %386 = bitcast float* %re796.i to <4 x float>*
  store <4 x float> %385, <4 x float>* %386, align 4, !tbaa !16
  %387 = fsub <4 x float> %123, %382
  %388 = fadd <4 x float> %123, %382
  %389 = shufflevector <4 x float> %387, <4 x float> %388, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %390 = bitcast float* %re802.i to <4 x float>*
  store <4 x float> %389, <4 x float>* %390, align 4, !tbaa !16
  %sub830.i = fsub float %add525.i, %sub524.i
  %conv831.i = fpext float %sub830.i to double
  %mul832.i = fmul double %conv831.i, 0x3FE6A09E667F4BB8
  %conv833.i = fptrunc double %mul832.i to float
  %add834.i = fadd float %add525.i, %sub524.i
  %conv835.i = fpext float %add834.i to double
  %mul836.i = fmul double %conv835.i, 0x3FE6A09E667F4BB8
  %conv837.i = fptrunc double %mul836.i to float
  %add838.i = fadd float %sub236.i, %conv833.i
  %re840.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 12, i32 0
  store float %add838.i, float* %re840.i, align 4, !tbaa !9
  %sub841.i = fsub float %add237.i, %conv837.i
  %im843.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 12, i32 1
  store float %sub841.i, float* %im843.i, align 4, !tbaa !12
  %sub844.i = fsub float %sub236.i, %conv833.i
  %re846.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 28, i32 0
  store float %sub844.i, float* %re846.i, align 4, !tbaa !9
  %add847.i = fadd float %add237.i, %conv837.i
  %im849.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 28, i32 1
  store float %add847.i, float* %im849.i, align 4, !tbaa !12
  %391 = fpext <4 x float> %312 to <4 x double>
  %392 = fmul <4 x double> %391, <double 0x3FE1C73B39AE76C7, double 0x3FE1C73B39AE76C7, double 0x3FD87DE2A6AEA312, double 0x3FD87DE2A6AEA312>
  %393 = fmul <4 x double> %391, <double 0x3FEA9B66290EB1A3, double 0x3FEA9B66290EB1A3, double 0x3FED906BCF32832F, double 0x3FED906BCF32832F>
  %394 = shufflevector <4 x double> %393, <4 x double> undef, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  %395 = fsub <4 x double> %392, %394
  %396 = fadd <4 x double> %392, %394
  %397 = shufflevector <4 x double> %395, <4 x double> %396, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %398 = fptrunc <4 x double> %397 to <4 x float>
  %re864.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 13, i32 0
  %re870.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 29, i32 0
  %399 = fadd <4 x float> %151, %398
  %400 = fsub <4 x float> %151, %398
  %401 = shufflevector <4 x float> %399, <4 x float> %400, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %402 = bitcast float* %re864.i to <4 x float>*
  store <4 x float> %401, <4 x float>* %402, align 4, !tbaa !16
  %403 = fsub <4 x float> %151, %398
  %404 = fadd <4 x float> %151, %398
  %405 = shufflevector <4 x float> %403, <4 x float> %404, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %406 = bitcast float* %re870.i to <4 x float>*
  store <4 x float> %405, <4 x float>* %406, align 4, !tbaa !16
  %conv898.i = fpext float %add569.i to double
  %mul899.i = fmul double %conv898.i, 0x3FC8F8B83C6993FD
  %conv900.i = fpext float %sub568.i to double
  %mul901.i = fmul double %conv900.i, 0x3FEF6297CFF75494
  %sub902.i = fsub double %mul899.i, %mul901.i
  %conv903.i = fptrunc double %sub902.i to float
  %mul905.i = fmul double %conv900.i, 0x3FC8F8B83C6993FD
  %mul907.i = fmul double %conv898.i, 0x3FEF6297CFF75494
  %add908.i = fadd double %mul905.i, %mul907.i
  %conv909.i = fptrunc double %add908.i to float
  %add910.i = fadd float %sub280.i, %conv903.i
  %re912.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 15, i32 0
  store float %add910.i, float* %re912.i, align 4, !tbaa !9
  %sub913.i = fsub float %add281.i, %conv909.i
  %im915.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 15, i32 1
  store float %sub913.i, float* %im915.i, align 4, !tbaa !12
  %sub916.i = fsub float %sub280.i, %conv903.i
  %re918.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 31, i32 0
  store float %sub916.i, float* %re918.i, align 4, !tbaa !9
  %add919.i = fadd float %add281.i, %conv909.i
  %im921.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 31, i32 1
  store float %add919.i, float* %im921.i, align 4, !tbaa !12
  br label %cleanup

if.then2:                                         ; preds = %entry
  %407 = bitcast %struct.COMPLEX* %in to <2 x float>*
  %408 = load <2 x float>, <2 x float>* %407, align 4, !tbaa !16
  %shuffle478 = shufflevector <2 x float> %408, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %re3.i181 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 8, i32 0
  %409 = bitcast float* %re3.i181 to <2 x float>*
  %410 = load <2 x float>, <2 x float>* %409, align 4, !tbaa !16
  %shuffle479 = shufflevector <2 x float> %410, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %411 = fadd <4 x float> %shuffle478, %shuffle479
  %412 = fsub <4 x float> %shuffle478, %shuffle479
  %413 = shufflevector <4 x float> %411, <4 x float> %412, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %re9.i187 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 4, i32 0
  %414 = bitcast float* %re9.i187 to <2 x float>*
  %415 = load <2 x float>, <2 x float>* %414, align 4, !tbaa !16
  %shuffle480 = shufflevector <2 x float> %415, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %re13.i189 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 12, i32 0
  %416 = bitcast float* %re13.i189 to <2 x float>*
  %417 = load <2 x float>, <2 x float>* %416, align 4, !tbaa !16
  %shuffle481 = shufflevector <2 x float> %417, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %418 = fadd <4 x float> %shuffle480, %shuffle481
  %419 = fsub <4 x float> %shuffle480, %shuffle481
  %420 = shufflevector <4 x float> %418, <4 x float> %419, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %421 = fadd <4 x float> %413, %420
  %422 = fsub <4 x float> %413, %420
  %423 = shufflevector <4 x float> %421, <4 x float> %422, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %424 = fsub <4 x float> %413, %420
  %425 = fadd <4 x float> %413, %420
  %426 = shufflevector <4 x float> %424, <4 x float> %425, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %re29.i203 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 2, i32 0
  %427 = bitcast float* %re29.i203 to <2 x float>*
  %428 = load <2 x float>, <2 x float>* %427, align 4, !tbaa !16
  %reorder_shuffle482 = shufflevector <2 x float> %428, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %re33.i205 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 10, i32 0
  %429 = bitcast float* %re33.i205 to <2 x float>*
  %430 = load <2 x float>, <2 x float>* %429, align 4, !tbaa !16
  %reorder_shuffle483 = shufflevector <2 x float> %430, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %431 = fadd <2 x float> %reorder_shuffle482, %reorder_shuffle483
  %432 = fsub <2 x float> %reorder_shuffle482, %reorder_shuffle483
  %sub38.i209 = extractelement <2 x float> %432, i32 1
  %433 = fsub <2 x float> %reorder_shuffle482, %reorder_shuffle483
  %sub39.i210 = extractelement <2 x float> %433, i32 0
  %re41.i211 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 6, i32 0
  %434 = bitcast float* %re41.i211 to <2 x float>*
  %435 = load <2 x float>, <2 x float>* %434, align 4, !tbaa !16
  %reorder_shuffle484 = shufflevector <2 x float> %435, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %re45.i213 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 14, i32 0
  %436 = bitcast float* %re45.i213 to <2 x float>*
  %437 = load <2 x float>, <2 x float>* %436, align 4, !tbaa !16
  %reorder_shuffle485 = shufflevector <2 x float> %437, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  %438 = fadd <2 x float> %reorder_shuffle484, %reorder_shuffle485
  %439 = fsub <2 x float> %reorder_shuffle484, %reorder_shuffle485
  %sub50.i217 = extractelement <2 x float> %439, i32 1
  %440 = fsub <2 x float> %reorder_shuffle484, %reorder_shuffle485
  %sub51.i218 = extractelement <2 x float> %440, i32 0
  %441 = fadd <2 x float> %431, %438
  %442 = fsub <2 x float> %431, %438
  %add56.i223 = fadd float %sub38.i209, %sub51.i218
  %sub57.i224 = fsub float %sub39.i210, %sub50.i217
  %sub58.i225 = fsub float %sub38.i209, %sub51.i218
  %add59.i226 = fadd float %sub39.i210, %sub50.i217
  %add64.i231 = fadd float %sub57.i224, %add56.i223
  %conv.i232 = fpext float %add64.i231 to double
  %mul.i233 = fmul double %conv.i232, 0x3FE6A09E667F4BB8
  %conv65.i234 = fptrunc double %mul.i233 to float
  %sub66.i235 = fsub float %sub57.i224, %add56.i223
  %conv67.i236 = fpext float %sub66.i235 to double
  %mul68.i237 = fmul double %conv67.i236, 0x3FE6A09E667F4BB8
  %conv69.i238 = fptrunc double %mul68.i237 to float
  %443 = extractelement <2 x float> %441, i32 1
  %444 = insertelement <4 x float> poison, float %443, i32 0
  %445 = extractelement <2 x float> %441, i32 0
  %446 = insertelement <4 x float> %444, float %445, i32 1
  %447 = insertelement <4 x float> %446, float %conv65.i234, i32 2
  %448 = insertelement <4 x float> %447, float %conv69.i238, i32 3
  %449 = fadd <4 x float> %423, %448
  %450 = fsub <4 x float> %423, %448
  %451 = extractelement <4 x float> %424, i32 0
  %452 = extractelement <2 x float> %442, i32 0
  %sub76.i245 = fsub float %451, %452
  %453 = extractelement <4 x float> %424, i32 1
  %454 = extractelement <2 x float> %442, i32 1
  %add77.i246 = fadd float %453, %454
  %sub78.i247 = fsub float %add59.i226, %sub58.i225
  %conv79.i248 = fpext float %sub78.i247 to double
  %mul80.i249 = fmul double %conv79.i248, 0x3FE6A09E667F4BB8
  %conv81.i250 = fptrunc double %mul80.i249 to float
  %add82.i251 = fadd float %add59.i226, %sub58.i225
  %conv83.i252 = fpext float %add82.i251 to double
  %mul84.i253 = fmul double %conv83.i252, 0x3FE6A09E667F4BB8
  %conv85.i254 = fptrunc double %mul84.i253 to float
  %455 = insertelement <4 x float> poison, float %452, i32 0
  %456 = insertelement <4 x float> %455, float %454, i32 1
  %457 = insertelement <4 x float> %456, float %conv81.i250, i32 2
  %458 = insertelement <4 x float> %457, float %conv85.i254, i32 3
  %459 = fadd <4 x float> %426, %458
  %460 = fsub <4 x float> %426, %458
  %461 = shufflevector <4 x float> %459, <4 x float> %460, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %462 = extractelement <4 x float> %424, i32 2
  %sub88.i257 = fsub float %462, %conv81.i250
  %463 = extractelement <4 x float> %425, i32 3
  %add89.i258 = fadd float %463, %conv85.i254
  %re91.i259 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 1, i32 0
  %464 = bitcast float* %re91.i259 to <2 x float>*
  %465 = load <2 x float>, <2 x float>* %464, align 4, !tbaa !16
  %re95.i261 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 9, i32 0
  %466 = bitcast float* %re95.i261 to <2 x float>*
  %467 = load <2 x float>, <2 x float>* %466, align 4, !tbaa !16
  %468 = fadd <2 x float> %465, %467
  %469 = fsub <2 x float> %465, %467
  %sub100.i265 = extractelement <2 x float> %469, i32 0
  %470 = fsub <2 x float> %465, %467
  %sub101.i266 = extractelement <2 x float> %470, i32 1
  %re103.i267 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 5, i32 0
  %471 = bitcast float* %re103.i267 to <2 x float>*
  %472 = load <2 x float>, <2 x float>* %471, align 4, !tbaa !16
  %re107.i269 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 13, i32 0
  %473 = bitcast float* %re107.i269 to <2 x float>*
  %474 = load <2 x float>, <2 x float>* %473, align 4, !tbaa !16
  %475 = fadd <2 x float> %472, %474
  %476 = fsub <2 x float> %472, %474
  %sub112.i273 = extractelement <2 x float> %476, i32 0
  %477 = fsub <2 x float> %472, %474
  %sub113.i274 = extractelement <2 x float> %477, i32 1
  %478 = fadd <2 x float> %468, %475
  %479 = fsub <2 x float> %468, %475
  %sub116.i277 = extractelement <2 x float> %479, i32 0
  %480 = fsub <2 x float> %468, %475
  %sub117.i278 = extractelement <2 x float> %480, i32 1
  %add118.i279 = fadd float %sub100.i265, %sub113.i274
  %sub119.i280 = fsub float %sub101.i266, %sub112.i273
  %sub120.i281 = fsub float %sub100.i265, %sub113.i274
  %add121.i282 = fadd float %sub101.i266, %sub112.i273
  %re123.i283 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 3, i32 0
  %481 = bitcast float* %re123.i283 to <2 x float>*
  %482 = load <2 x float>, <2 x float>* %481, align 4, !tbaa !16
  %re127.i285 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 11, i32 0
  %483 = bitcast float* %re127.i285 to <2 x float>*
  %484 = load <2 x float>, <2 x float>* %483, align 4, !tbaa !16
  %485 = fadd <2 x float> %482, %484
  %486 = fsub <2 x float> %482, %484
  %sub132.i289 = extractelement <2 x float> %486, i32 0
  %487 = fsub <2 x float> %482, %484
  %sub133.i290 = extractelement <2 x float> %487, i32 1
  %re135.i291 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 7, i32 0
  %488 = bitcast float* %re135.i291 to <2 x float>*
  %489 = load <2 x float>, <2 x float>* %488, align 4, !tbaa !16
  %re139.i293 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 15, i32 0
  %490 = bitcast float* %re139.i293 to <2 x float>*
  %491 = load <2 x float>, <2 x float>* %490, align 4, !tbaa !16
  %492 = fadd <2 x float> %489, %491
  %493 = fsub <2 x float> %489, %491
  %sub144.i297 = extractelement <2 x float> %493, i32 0
  %494 = fsub <2 x float> %489, %491
  %sub145.i298 = extractelement <2 x float> %494, i32 1
  %495 = fadd <2 x float> %485, %492
  %496 = fsub <2 x float> %485, %492
  %sub148.i301 = extractelement <2 x float> %496, i32 0
  %497 = fsub <2 x float> %485, %492
  %sub149.i302 = extractelement <2 x float> %497, i32 1
  %add150.i303 = fadd float %sub132.i289, %sub145.i298
  %sub151.i304 = fsub float %sub133.i290, %sub144.i297
  %sub152.i305 = fsub float %sub132.i289, %sub145.i298
  %add153.i306 = fadd float %sub133.i290, %sub144.i297
  %498 = fadd <2 x float> %478, %495
  %499 = fsub <2 x float> %478, %495
  %add158.i311 = fadd float %sub151.i304, %add150.i303
  %conv159.i312 = fpext float %add158.i311 to double
  %mul160.i313 = fmul double %conv159.i312, 0x3FE6A09E667F4BB8
  %conv161.i314 = fptrunc double %mul160.i313 to float
  %sub162.i315 = fsub float %sub151.i304, %add150.i303
  %conv163.i316 = fpext float %sub162.i315 to double
  %mul164.i317 = fmul double %conv163.i316, 0x3FE6A09E667F4BB8
  %conv165.i318 = fptrunc double %mul164.i317 to float
  %add166.i319 = fadd float %add118.i279, %conv161.i314
  %add167.i320 = fadd float %sub119.i280, %conv165.i318
  %sub168.i321 = fsub float %add118.i279, %conv161.i314
  %sub169.i322 = fsub float %sub119.i280, %conv165.i318
  %add170.i323 = fadd float %sub116.i277, %sub149.i302
  %sub171.i324 = fsub float %sub117.i278, %sub148.i301
  %sub172.i325 = fsub float %sub116.i277, %sub149.i302
  %add173.i326 = fadd float %sub117.i278, %sub148.i301
  %sub174.i327 = fsub float %add153.i306, %sub152.i305
  %conv175.i328 = fpext float %sub174.i327 to double
  %mul176.i329 = fmul double %conv175.i328, 0x3FE6A09E667F4BB8
  %conv177.i330 = fptrunc double %mul176.i329 to float
  %add178.i331 = fadd float %add153.i306, %sub152.i305
  %conv179.i332 = fpext float %add178.i331 to double
  %mul180.i333 = fmul double %conv179.i332, 0x3FE6A09E667F4BB8
  %conv181.i334 = fptrunc double %mul180.i333 to float
  %add182.i335 = fadd float %sub120.i281, %conv177.i330
  %sub183.i336 = fsub float %add121.i282, %conv181.i334
  %sub184.i337 = fsub float %sub120.i281, %conv177.i330
  %add185.i338 = fadd float %add121.i282, %conv181.i334
  %conv198.i = fpext float %add166.i319 to double
  %mul199.i340 = fmul double %conv198.i, 0x3FED906BCF32832F
  %conv200.i = fpext float %add167.i320 to double
  %mul201.i = fmul double %conv200.i, 0x3FD87DE2A6AEA312
  %add202.i341 = fadd double %mul199.i340, %mul201.i
  %conv203.i = fptrunc double %add202.i341 to float
  %mul205.i = fmul double %conv200.i, 0x3FED906BCF32832F
  %mul207.i = fmul double %conv198.i, 0x3FD87DE2A6AEA312
  %sub208.i = fsub double %mul205.i, %mul207.i
  %conv209.i342 = fptrunc double %sub208.i to float
  %500 = extractelement <2 x float> %498, i32 0
  %501 = insertelement <4 x float> poison, float %500, i32 0
  %502 = extractelement <2 x float> %498, i32 1
  %503 = insertelement <4 x float> %501, float %502, i32 1
  %504 = insertelement <4 x float> %503, float %conv203.i, i32 2
  %505 = insertelement <4 x float> %504, float %conv209.i342, i32 3
  %506 = fadd <4 x float> %449, %505
  %507 = bitcast %struct.COMPLEX* %out to <4 x float>*
  store <4 x float> %506, <4 x float>* %507, align 4, !tbaa !16
  %im221.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 9, i32 1
  %add222.i344 = fadd float %sub171.i324, %add170.i323
  %conv223.i345 = fpext float %add222.i344 to double
  %mul224.i = fmul double %conv223.i345, 0x3FE6A09E667F4BB8
  %sub226.i = fsub float %sub171.i324, %add170.i323
  %conv227.i = fpext float %sub226.i to double
  %mul228.i = fmul double %conv227.i, 0x3FE6A09E667F4BB8
  %re232.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 2, i32 0
  %conv242.i = fpext float %add182.i335 to double
  %mul243.i = fmul double %conv242.i, 0x3FD87DE2A6AEA312
  %conv244.i = fpext float %sub183.i336 to double
  %mul245.i349 = fmul double %conv244.i, 0x3FED906BCF32832F
  %add246.i = fadd double %mul243.i, %mul245.i349
  %mul249.i = fmul double %conv244.i, 0x3FD87DE2A6AEA312
  %mul251.i = fmul double %conv242.i, 0x3FED906BCF32832F
  %sub252.i350 = fsub double %mul249.i, %mul251.i
  %508 = insertelement <4 x double> poison, double %mul224.i, i32 0
  %509 = insertelement <4 x double> %508, double %mul228.i, i32 1
  %510 = insertelement <4 x double> %509, double %add246.i, i32 2
  %511 = insertelement <4 x double> %510, double %sub252.i350, i32 3
  %512 = fptrunc <4 x double> %511 to <4 x float>
  %513 = fadd <4 x float> %461, %512
  %514 = bitcast float* %re232.i to <4 x float>*
  store <4 x float> %513, <4 x float>* %514, align 4, !tbaa !16
  %515 = shufflevector <4 x float> %449, <4 x float> %459, <4 x i32> <i32 3, i32 4, i32 undef, i32 undef>
  %516 = shufflevector <4 x float> %515, <4 x float> %460, <4 x i32> <i32 0, i32 1, i32 5, i32 undef>
  %517 = shufflevector <4 x float> %516, <4 x float> %459, <4 x i32> <i32 0, i32 1, i32 2, i32 6>
  %518 = insertelement <4 x float> poison, float %conv209.i342, i32 0
  %519 = shufflevector <4 x float> %518, <4 x float> %512, <4 x i32> <i32 0, i32 4, i32 5, i32 6>
  %520 = fsub <4 x float> %517, %519
  %521 = bitcast float* %im221.i to <4 x float>*
  store <4 x float> %520, <4 x float>* %521, align 4, !tbaa !16
  %522 = extractelement <4 x float> %512, i32 3
  %im265.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 11, i32 1
  %re268.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 4, i32 0
  %conv278.i = fpext float %sub169.i322 to double
  %mul279.i = fmul double %conv278.i, 0x3FED906BCF32832F
  %conv280.i = fpext float %sub168.i321 to double
  %mul281.i = fmul double %conv280.i, 0x3FD87DE2A6AEA312
  %sub282.i = fsub double %mul279.i, %mul281.i
  %conv283.i = fptrunc double %sub282.i to float
  %mul285.i = fmul double %conv280.i, 0x3FED906BCF32832F
  %mul287.i = fmul double %conv278.i, 0x3FD87DE2A6AEA312
  %add288.i = fadd double %mul285.i, %mul287.i
  %conv289.i = fptrunc double %add288.i to float
  %523 = extractelement <2 x float> %499, i32 1
  %524 = insertelement <4 x float> poison, float %523, i32 0
  %525 = extractelement <2 x float> %499, i32 0
  %526 = insertelement <4 x float> %524, float %525, i32 1
  %527 = insertelement <4 x float> %526, float %conv283.i, i32 2
  %528 = insertelement <4 x float> %527, float %conv289.i, i32 3
  %529 = fadd <4 x float> %450, %528
  %530 = fsub <4 x float> %450, %528
  %531 = shufflevector <4 x float> %529, <4 x float> %530, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %532 = bitcast float* %re268.i to <4 x float>*
  store <4 x float> %531, <4 x float>* %532, align 4, !tbaa !16
  %533 = shufflevector <4 x float> %460, <4 x float> %450, <4 x i32> <i32 3, i32 4, i32 5, i32 6>
  %534 = insertelement <4 x float> poison, float %522, i32 0
  %535 = insertelement <4 x float> %534, float %523, i32 1
  %536 = insertelement <4 x float> %535, float %525, i32 2
  %537 = insertelement <4 x float> %536, float %conv283.i, i32 3
  %538 = fsub <4 x float> %533, %537
  %539 = fadd <4 x float> %533, %537
  %540 = shufflevector <4 x float> %538, <4 x float> %539, <4 x i32> <i32 0, i32 1, i32 6, i32 3>
  %541 = bitcast float* %im265.i to <4 x float>*
  store <4 x float> %540, <4 x float>* %541, align 4, !tbaa !16
  %542 = extractelement <4 x float> %450, i32 3
  %add299.i = fadd float %542, %conv289.i
  %im301.i354 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 13, i32 1
  store float %add299.i, float* %im301.i354, align 4, !tbaa !12
  %sub302.i = fsub float %add173.i326, %sub172.i325
  %conv303.i = fpext float %sub302.i to double
  %mul304.i = fmul double %conv303.i, 0x3FE6A09E667F4BB8
  %conv305.i = fptrunc double %mul304.i to float
  %add306.i355 = fadd float %add173.i326, %sub172.i325
  %conv307.i = fpext float %add306.i355 to double
  %mul308.i = fmul double %conv307.i, 0x3FE6A09E667F4BB8
  %conv309.i = fptrunc double %mul308.i to float
  %add310.i356 = fadd float %sub76.i245, %conv305.i
  %re312.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 6, i32 0
  store float %add310.i356, float* %re312.i, align 4, !tbaa !9
  %sub313.i = fsub float %add77.i246, %conv309.i
  %im315.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 6, i32 1
  store float %sub313.i, float* %im315.i, align 4, !tbaa !12
  %sub316.i = fsub float %sub76.i245, %conv305.i
  %re318.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 14, i32 0
  store float %sub316.i, float* %re318.i, align 4, !tbaa !9
  %add319.i = fadd float %add77.i246, %conv309.i
  %im321.i357 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 14, i32 1
  store float %add319.i, float* %im321.i357, align 4, !tbaa !12
  %conv322.i = fpext float %add185.i338 to double
  %mul323.i = fmul double %conv322.i, 0x3FD87DE2A6AEA312
  %conv324.i = fpext float %sub184.i337 to double
  %mul325.i = fmul double %conv324.i, 0x3FED906BCF32832F
  %sub326.i = fsub double %mul323.i, %mul325.i
  %conv327.i = fptrunc double %sub326.i to float
  %mul329.i = fmul double %conv324.i, 0x3FD87DE2A6AEA312
  %mul331.i = fmul double %conv322.i, 0x3FED906BCF32832F
  %add332.i = fadd double %mul329.i, %mul331.i
  %conv333.i = fptrunc double %add332.i to float
  %add334.i358 = fadd float %sub88.i257, %conv327.i
  %re336.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 7, i32 0
  store float %add334.i358, float* %re336.i, align 4, !tbaa !9
  %543 = insertelement <4 x float> poison, float %add89.i258, i32 0
  %544 = shufflevector <4 x float> %543, <4 x float> %449, <4 x i32> <i32 0, i32 4, i32 5, i32 6>
  %545 = insertelement <4 x float> poison, float %conv333.i, i32 0
  %546 = insertelement <4 x float> %545, float %500, i32 1
  %547 = insertelement <4 x float> %546, float %502, i32 2
  %548 = insertelement <4 x float> %547, float %conv203.i, i32 3
  %549 = fsub <4 x float> %544, %548
  %im339.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 7, i32 1
  %550 = bitcast float* %im339.i to <4 x float>*
  store <4 x float> %549, <4 x float>* %550, align 4, !tbaa !16
  %sub340.i360 = fsub float %sub88.i257, %conv327.i
  %re342.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 15, i32 0
  store float %sub340.i360, float* %re342.i, align 4, !tbaa !9
  %add343.i = fadd float %add89.i258, %conv333.i
  %im345.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 15, i32 1
  store float %add343.i, float* %im345.i, align 4, !tbaa !12
  br label %cleanup

if.then5:                                         ; preds = %entry
  %551 = bitcast %struct.COMPLEX* %in to <2 x float>*
  %552 = load <2 x float>, <2 x float>* %551, align 4, !tbaa !16
  %shuffle490 = shufflevector <2 x float> %552, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %re3.i363 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 4, i32 0
  %553 = bitcast float* %re3.i363 to <2 x float>*
  %554 = load <2 x float>, <2 x float>* %553, align 4, !tbaa !16
  %shuffle491 = shufflevector <2 x float> %554, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %555 = fadd <4 x float> %shuffle490, %shuffle491
  %556 = fsub <4 x float> %shuffle490, %shuffle491
  %557 = shufflevector <4 x float> %555, <4 x float> %556, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %re9.i369 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 2, i32 0
  %558 = bitcast float* %re9.i369 to <2 x float>*
  %559 = load <2 x float>, <2 x float>* %558, align 4, !tbaa !16
  %shuffle492 = shufflevector <2 x float> %559, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %re13.i371 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 6, i32 0
  %560 = bitcast float* %re13.i371 to <2 x float>*
  %561 = load <2 x float>, <2 x float>* %560, align 4, !tbaa !16
  %shuffle493 = shufflevector <2 x float> %561, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %562 = fadd <4 x float> %shuffle492, %shuffle493
  %563 = fsub <4 x float> %shuffle492, %shuffle493
  %564 = shufflevector <4 x float> %562, <4 x float> %563, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %565 = fadd <4 x float> %557, %564
  %566 = fsub <4 x float> %557, %564
  %567 = shufflevector <4 x float> %565, <4 x float> %566, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %568 = fsub <4 x float> %557, %564
  %569 = fadd <4 x float> %557, %564
  %570 = shufflevector <4 x float> %568, <4 x float> %569, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %re29.i385 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 1, i32 0
  %571 = bitcast float* %re29.i385 to <2 x float>*
  %572 = load <2 x float>, <2 x float>* %571, align 4, !tbaa !16
  %re33.i387 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 5, i32 0
  %573 = bitcast float* %re33.i387 to <2 x float>*
  %574 = load <2 x float>, <2 x float>* %573, align 4, !tbaa !16
  %575 = fadd <2 x float> %572, %574
  %576 = fsub <2 x float> %572, %574
  %sub38.i391 = extractelement <2 x float> %576, i32 0
  %577 = fsub <2 x float> %572, %574
  %sub39.i392 = extractelement <2 x float> %577, i32 1
  %re41.i393 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 3, i32 0
  %578 = bitcast float* %re41.i393 to <2 x float>*
  %579 = load <2 x float>, <2 x float>* %578, align 4, !tbaa !16
  %re45.i395 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 7, i32 0
  %580 = bitcast float* %re45.i395 to <2 x float>*
  %581 = load <2 x float>, <2 x float>* %580, align 4, !tbaa !16
  %582 = fadd <2 x float> %579, %581
  %583 = fsub <2 x float> %579, %581
  %sub50.i399 = extractelement <2 x float> %583, i32 0
  %584 = fsub <2 x float> %579, %581
  %sub51.i400 = extractelement <2 x float> %584, i32 1
  %585 = fadd <2 x float> %575, %582
  %586 = fsub <2 x float> %575, %582
  %add56.i405 = fadd float %sub38.i391, %sub51.i400
  %sub57.i406 = fsub float %sub39.i392, %sub50.i399
  %sub58.i407 = fsub float %sub38.i391, %sub51.i400
  %add59.i408 = fadd float %sub39.i392, %sub50.i399
  %re68.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 4, i32 0
  %add72.i = fadd float %sub57.i406, %add56.i405
  %conv.i411 = fpext float %add72.i to double
  %mul.i412 = fmul double %conv.i411, 0x3FE6A09E667F4BB8
  %conv73.i = fptrunc double %mul.i412 to float
  %sub74.i = fsub float %sub57.i406, %add56.i405
  %conv75.i = fpext float %sub74.i to double
  %mul76.i = fmul double %conv75.i, 0x3FE6A09E667F4BB8
  %conv77.i = fptrunc double %mul76.i to float
  %587 = extractelement <2 x float> %585, i32 0
  %588 = insertelement <4 x float> poison, float %587, i32 0
  %589 = extractelement <2 x float> %585, i32 1
  %590 = insertelement <4 x float> %588, float %589, i32 1
  %591 = insertelement <4 x float> %590, float %conv73.i, i32 2
  %592 = insertelement <4 x float> %591, float %conv77.i, i32 3
  %593 = fadd <4 x float> %567, %592
  %594 = bitcast %struct.COMPLEX* %out to <4 x float>*
  store <4 x float> %593, <4 x float>* %594, align 4, !tbaa !16
  %595 = fsub <4 x float> %567, %592
  %596 = bitcast float* %re68.i to <4 x float>*
  store <4 x float> %595, <4 x float>* %596, align 4, !tbaa !16
  %re92.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 2, i32 0
  %re98.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 6, i32 0
  %sub102.i = fsub float %add59.i408, %sub58.i407
  %conv103.i = fpext float %sub102.i to double
  %mul104.i = fmul double %conv103.i, 0x3FE6A09E667F4BB8
  %conv105.i = fptrunc double %mul104.i to float
  %add106.i = fadd float %add59.i408, %sub58.i407
  %conv107.i = fpext float %add106.i to double
  %mul108.i = fmul double %conv107.i, 0x3FE6A09E667F4BB8
  %conv109.i = fptrunc double %mul108.i to float
  %597 = extractelement <2 x float> %586, i32 1
  %598 = insertelement <4 x float> poison, float %597, i32 0
  %599 = extractelement <2 x float> %586, i32 0
  %600 = insertelement <4 x float> %598, float %599, i32 1
  %601 = insertelement <4 x float> %600, float %conv105.i, i32 2
  %602 = insertelement <4 x float> %601, float %conv109.i, i32 3
  %603 = fadd <4 x float> %570, %602
  %604 = fsub <4 x float> %570, %602
  %605 = shufflevector <4 x float> %603, <4 x float> %604, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %606 = bitcast float* %re92.i to <4 x float>*
  store <4 x float> %605, <4 x float>* %606, align 4, !tbaa !16
  %607 = fsub <4 x float> %570, %602
  %608 = fadd <4 x float> %570, %602
  %609 = shufflevector <4 x float> %607, <4 x float> %608, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  %610 = bitcast float* %re98.i to <4 x float>*
  store <4 x float> %609, <4 x float>* %610, align 4, !tbaa !16
  br label %cleanup

if.then8:                                         ; preds = %entry
  %611 = bitcast %struct.COMPLEX* %in to <2 x float>*
  %612 = load <2 x float>, <2 x float>* %611, align 4, !tbaa !16
  %shuffle496 = shufflevector <2 x float> %612, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %re3.i420 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 2, i32 0
  %613 = bitcast float* %re3.i420 to <2 x float>*
  %614 = load <2 x float>, <2 x float>* %613, align 4, !tbaa !16
  %shuffle497 = shufflevector <2 x float> %614, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %615 = fadd <4 x float> %shuffle496, %shuffle497
  %616 = fsub <4 x float> %shuffle496, %shuffle497
  %617 = shufflevector <4 x float> %615, <4 x float> %616, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %re9.i426 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 1, i32 0
  %618 = bitcast float* %re9.i426 to <2 x float>*
  %619 = load <2 x float>, <2 x float>* %618, align 4, !tbaa !16
  %shuffle498 = shufflevector <2 x float> %619, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %re13.i428 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 3, i32 0
  %620 = bitcast float* %re13.i428 to <2 x float>*
  %621 = load <2 x float>, <2 x float>* %620, align 4, !tbaa !16
  %shuffle499 = shufflevector <2 x float> %621, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  %622 = fadd <4 x float> %shuffle498, %shuffle499
  %623 = fsub <4 x float> %shuffle498, %shuffle499
  %624 = shufflevector <4 x float> %622, <4 x float> %623, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %re28.i = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 2, i32 0
  %625 = fadd <4 x float> %617, %624
  %626 = fsub <4 x float> %617, %624
  %627 = shufflevector <4 x float> %625, <4 x float> %626, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %628 = bitcast %struct.COMPLEX* %out to <4 x float>*
  store <4 x float> %627, <4 x float>* %628, align 4, !tbaa !16
  %629 = fsub <4 x float> %617, %624
  %630 = fadd <4 x float> %617, %624
  %631 = shufflevector <4 x float> %629, <4 x float> %630, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %632 = bitcast float* %re28.i to <4 x float>*
  store <4 x float> %631, <4 x float>* %632, align 4, !tbaa !16
  br label %cleanup

if.then11:                                        ; preds = %entry
  %633 = bitcast %struct.COMPLEX* %in to <4 x float>*
  %634 = load <4 x float>, <4 x float>* %633, align 4, !tbaa !16
  %reorder_shuffle500 = shufflevector <4 x float> %634, <4 x float> poison, <4 x i32> <i32 2, i32 3, i32 0, i32 1>
  %635 = fadd <4 x float> %reorder_shuffle500, %634
  %636 = fsub <4 x float> %reorder_shuffle500, %634
  %637 = shufflevector <4 x float> %635, <4 x float> %636, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %638 = bitcast %struct.COMPLEX* %out to <4 x float>*
  store <4 x float> %637, <4 x float>* %638, align 4, !tbaa !16
  br label %cleanup

if.end12:                                         ; preds = %entry
  %639 = load i32, i32* %factors, align 4, !tbaa !4
  %div = sdiv i32 %n, %639
  %cmp13 = icmp slt i32 %639, %n
  br i1 %cmp13, label %if.then14, label %if.end38

if.then14:                                        ; preds = %if.end12
  switch i32 %639, label %if.else28 [
    i32 32, label %if.then16
    i32 16, label %if.then18
    i32 8, label %if.then21
    i32 4, label %if.then24
    i32 2, label %if.then27
  ]

if.then16:                                        ; preds = %if.then14
  tail call fastcc void @fft_unshuffle_32(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, i32 %div)
  br label %if.end33

if.then18:                                        ; preds = %if.then14
  tail call fastcc void @fft_unshuffle_16(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, i32 %div)
  br label %if.end33

if.then21:                                        ; preds = %if.then14
  tail call fastcc void @fft_unshuffle_8(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, i32 %div)
  br label %if.end33

if.then24:                                        ; preds = %if.then14
  tail call fastcc void @fft_unshuffle_4(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, i32 %div)
  br label %if.end33

if.then27:                                        ; preds = %if.then14
  tail call fastcc void @fft_unshuffle_2(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, i32 %div)
  br label %if.end33

if.else28:                                        ; preds = %if.then14
  tail call fastcc void @unshuffle(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, i32 %639, i32 %div)
  br label %if.end33

if.end33:                                         ; preds = %if.then18, %if.then24, %if.else28, %if.then27, %if.then21, %if.then16
  %cmp34446 = icmp sgt i32 %n, 0
  br i1 %cmp34446, label %for.body.tf.lr.ph, label %for.end

for.body.tf.lr.ph:                                ; preds = %if.end33
  %add.ptr37 = getelementptr inbounds i32, i32* %factors, i64 1
  %640 = sext i32 %div to i64
  %641 = zext i32 %n to i64
  br label %for.body.tf

for.body.tf:                                      ; preds = %for.body.tf.lr.ph, %for.inc
  %indvars.iv = phi i64 [ 0, %for.body.tf.lr.ph ], [ %indvars.iv.next, %for.inc ]
  detach within %syncreg, label %det.achd, label %for.inc

det.achd:                                         ; preds = %for.body.tf
  %add.ptr36 = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %in, i64 %indvars.iv
  %add.ptr = getelementptr inbounds %struct.COMPLEX, %struct.COMPLEX* %out, i64 %indvars.iv
  tail call fastcc void @fft_aux(i32 %div, %struct.COMPLEX* %add.ptr, %struct.COMPLEX* %add.ptr36, i32* nonnull %add.ptr37, %struct.COMPLEX* %W, i32 %nW)
  reattach within %syncreg, label %for.inc

for.inc:                                          ; preds = %for.body.tf, %det.achd
  %indvars.iv.next = add i64 %indvars.iv, %640
  %cmp34 = icmp slt i64 %indvars.iv.next, %641
  br i1 %cmp34, label %for.body.tf, label %for.end, !llvm.loop !17

for.end:                                          ; preds = %for.inc, %if.end33
  sync within %syncreg, label %if.end38

if.end38:                                         ; preds = %for.end, %if.end12
  switch i32 %639, label %if.else58 [
    i32 2, label %if.then40
    i32 4, label %if.then44
    i32 8, label %if.then48
    i32 16, label %if.then52
    i32 32, label %if.then56
  ]

if.then40:                                        ; preds = %if.end38
  %div41 = sdiv i32 %nW, %n
  tail call fastcc void @fft_twiddle_2(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, %struct.COMPLEX* %W, i32 %div41, i32 %div)
  br label %cleanup

if.then44:                                        ; preds = %if.end38
  %div45 = sdiv i32 %nW, %n
  tail call fastcc void @fft_twiddle_4(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, %struct.COMPLEX* %W, i32 %div45, i32 %div)
  br label %cleanup

if.then48:                                        ; preds = %if.end38
  %div49 = sdiv i32 %nW, %n
  tail call fastcc void @fft_twiddle_8(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, %struct.COMPLEX* %W, i32 %div49, i32 %div)
  br label %cleanup

if.then52:                                        ; preds = %if.end38
  %div53 = sdiv i32 %nW, %n
  tail call fastcc void @fft_twiddle_16(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, %struct.COMPLEX* %W, i32 %div53, i32 %div)
  br label %cleanup

if.then56:                                        ; preds = %if.end38
  %div57 = sdiv i32 %nW, %n
  tail call fastcc void @fft_twiddle_32(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, %struct.COMPLEX* %W, i32 %div57, i32 %div)
  br label %cleanup

if.else58:                                        ; preds = %if.end38
  %div59 = sdiv i32 %nW, %n
  tail call fastcc void @fft_twiddle_gen(i32 0, i32 %div, %struct.COMPLEX* %in, %struct.COMPLEX* %out, %struct.COMPLEX* %W, i32 %nW, i32 %div59, i32 %639, i32 %div)
  br label %cleanup

cleanup:                                          ; preds = %if.then40, %if.then48, %if.then56, %if.else58, %if.then52, %if.then44, %if.then11, %if.then8, %if.then5, %if.then2, %if.then
  ret void
}

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_unshuffle_32(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_unshuffle_16(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_unshuffle_8(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_unshuffle_4(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_unshuffle_2(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @unshuffle(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, i32 %r, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_twiddle_2(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, %struct.COMPLEX* readonly %W, i32 %nWdn, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_twiddle_4(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, %struct.COMPLEX* readonly %W, i32 %nWdn, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_twiddle_8(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, %struct.COMPLEX* readonly %W, i32 %nWdn, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_twiddle_16(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, %struct.COMPLEX* readonly %W, i32 %nWdn, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_twiddle_32(i32 %a, i32 %b, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, %struct.COMPLEX* readonly %W, i32 %nWdn, i32 %m) unnamed_addr #4

; Function Attrs: argmemonly nounwind uwtable
declare fastcc void @fft_twiddle_gen(i32 %i, i32 %i1, %struct.COMPLEX* readonly %in, %struct.COMPLEX* %out, %struct.COMPLEX* readonly %W, i32 %nW, i32 %nWdn, i32 %r, i32 %m) unnamed_addr #4

; Function Attrs: inaccessiblemem_or_argmemonly nounwind willreturn
declare dso_local void @free(i8* nocapture noundef) local_unnamed_addr #5

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { inaccessiblememonly nofree nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { argmemonly nounwind uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { inaccessiblemem_or_argmemonly nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nofree nounwind uwtable "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nofree nounwind "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nofree nounwind }
attributes #11 = { nounwind }
attributes #12 = { cold }
attributes #13 = { cold nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 6483c891d59b7ee269d7dbde7cbf3dd36b83dd69)"}
!2 = distinct !{!2, !3}
!3 = !{!"llvm.loop.mustprogress"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = distinct !{!8, !3}
!9 = !{!10, !11, i64 0}
!10 = !{!"", !11, i64 0, !11, i64 4}
!11 = !{!"float", !6, i64 0}
!12 = !{!10, !11, i64 4}
!13 = distinct !{!13, !3}
!14 = distinct !{!14, !15}
!15 = !{!"tapir.loop.grainsize", i32 1}
!16 = !{!11, !11, i64 0}
!17 = distinct !{!17, !3, !15}
!18 = distinct !{!18, !3}
!19 = !{i64 0, i64 4, !16, i64 4, i64 4, !16}
!20 = !{i64 0, i64 4, !16}
!21 = distinct !{!21, !3}
!22 = distinct !{!22, !3}
!23 = distinct !{!23, !3}
!24 = distinct !{!24, !3}
!25 = distinct !{!25, !3}
!26 = distinct !{!26, !3}
!27 = !{!28, !28, i64 0}
!28 = !{!"long", !6, i64 0}
!29 = distinct !{!29, !3}
!30 = distinct !{!30, !31}
!31 = !{!"llvm.loop.unroll.disable"}
!32 = distinct !{!32, !31}
!33 = distinct !{!33, !31}
!34 = !{!35, !35, i64 0}
!35 = !{!"any pointer", !6, i64 0}
!36 = distinct !{!36, !3}
!37 = distinct !{!37, !15}
!38 = distinct !{!38, !3}
!39 = distinct !{!39, !15}
!40 = distinct !{!40, !3}
!41 = distinct !{!41, !15}
!42 = distinct !{!42, !3}
!43 = distinct !{!43, !15}
!44 = distinct !{!44, !31}
!45 = distinct !{!45, !3}
!46 = distinct !{!46, !15}
!47 = distinct !{!47, !3}
!48 = distinct !{!48, !3}
!49 = distinct !{!49, !3}
!50 = distinct !{!50, !31}
!51 = distinct !{!51, !31}
!52 = distinct !{!52, !15}
!53 = distinct !{!53, !3}
!54 = distinct !{!54, !15}
!55 = distinct !{!55, !3}
!56 = distinct !{!56, !15}
!57 = distinct !{!57, !3}
!58 = distinct !{!58, !15}
!59 = distinct !{!59, !3}
!60 = distinct !{!60, !15}
!61 = distinct !{!61, !3}
!62 = distinct !{!62, !15}
!63 = distinct !{!63, !3}
!64 = distinct !{!64, !3}
!65 = distinct !{!65, !15}
