; Test that llvm-reduce can remove uninteresting Basic Blocks with Tapir instructions (i.e., DetachInst and ReattachInst) without producing invalid LLVM IR.
;
; RUN: llvm-reduce -abort-on-invalid-reduction --delta-passes=basic-blocks --test FileCheck --test-arg --check-prefix=CHECK-INTERESTINGNESS --test-arg %s --test-arg --input-file %s -o %t

; CHECK-INTERESTINGNESS: pfor.cond:
; CHECK-INTERESTINGNESS-NEXT: phi

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

module asm ".globl _ZSt21ios_base_library_initv"

%struct.timer = type <{ double, double, double, %struct.wsp_t, %struct.wsp_t, i8, [3 x i8], %struct.timezone, [4 x i8] }>
%struct.wsp_t = type { i64, i64, i64 }
%struct.timezone = type { i32, i32 }
%"class.std::basic_ostream" = type { ptr, %"class.std::basic_ios" }
%"class.std::basic_ios" = type { %"class.std::ios_base", ptr, i8, i8, ptr, ptr, ptr, ptr }
%"class.std::ios_base" = type { ptr, i64, i64, i32, i32, i32, ptr, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, ptr, %"class.std::locale" }
%"struct.std::ios_base::_Words" = type { ptr, i64 }
%"class.std::locale" = type { ptr }
%class._point3d = type { double, double, double }
%"struct.sequence::getA.15" = type { ptr }
%"struct.sequence::getAF" = type <{ ptr, %struct.ppairF, [7 x i8] }>
%struct.ppairF = type { i8 }
%"struct.std::pair.10" = type { %class._point3d, %class._point3d }

@_ZL3_tm = internal global %struct.timer zeroinitializer, align 8
@TRglobal = dso_local local_unnamed_addr global ptr null, align 8
@.str = private unnamed_addr constant [11 x i8] c"build tree\00", align 1
@.str.4 = private unnamed_addr constant [9 x i8] c"up sweep\00", align 1
@.str.5 = private unnamed_addr constant [13 x i8] c"interactions\00", align 1
@.str.6 = private unnamed_addr constant [12 x i8] c"do Indirect\00", align 1
@.str.7 = private unnamed_addr constant [11 x i8] c"down sweep\00", align 1
@.str.8 = private unnamed_addr constant [10 x i8] c"do Direct\00", align 1
@_ZSt4cout = external global %"class.std::basic_ostream", align 8
@.str.9 = private unnamed_addr constant [10 x i8] c"Direct = \00", align 1
@.str.10 = private unnamed_addr constant [13 x i8] c" Indirect = \00", align 1
@.str.11 = private unnamed_addr constant [10 x i8] c" Boxes = \00", align 1
@.str.12 = private unnamed_addr constant [34 x i8] c"this is a fix for broken cilkplus\00", align 1
@.str.13 = private unnamed_addr constant [4 x i8] c" : \00", align 1
@.str.14 = private unnamed_addr constant [12 x i8] c"PBBS-time: \00", align 1
@.str.15 = private unnamed_addr constant [26 x i8] c"vector::_M_realloc_insert\00", align 1
@.str.16 = private unnamed_addr constant [50 x i8] c"basic_string: construction from null is not valid\00", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr null, ptr null }]

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #0

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #1

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #3

; Function Attrs: uwtable
define dso_local noalias noundef nonnull ptr @_Z9buildTreePP8particleS1_Pbii(ptr noundef %particles, ptr noundef %Tmp, ptr noundef %Tflags, i32 noundef %n, i32 noundef %depth) local_unnamed_addr #4 personality ptr null {
entry:
  %agg.tmp120103 = alloca %class._point3d, align 8
  %agg.tmp119102 = alloca %class._point3d, align 8
  %f.i98 = alloca %"struct.sequence::getA.15", align 8
  %f.i = alloca %"struct.sequence::getA.15", align 8
  %agg.tmp561 = alloca %class._point3d, align 8
  %agg.tmp460 = alloca %class._point3d, align 8
  %agg.tmp2.i = alloca %"struct.sequence::getAF", align 8
  %R = alloca %"struct.std::pair.10", align 8
  %minPt = alloca %class._point3d, align 8
  %maxPt = alloca %class._point3d, align 8
  %agg.tmp4 = alloca %class._point3d, align 8
  %agg.tmp5 = alloca %class._point3d, align 8
  %syncreg = call token @llvm.syncregion.start()
  %syncreg33 = call token @llvm.syncregion.start()
  %syncreg70 = call token @llvm.syncregion.start()
  %a = alloca ptr, align 8
  %syncreg105 = call token @llvm.syncregion.start()
  %agg.tmp119 = alloca %class._point3d, align 8
  %agg.tmp120 = alloca %class._point3d, align 8
  %cmp = icmp sgt i32 %depth, 100
  call void @llvm.lifetime.start.p0(i64 48, ptr nonnull %R) #6
  call void @llvm.experimental.noalias.scope.decl(metadata !5)
  call void @llvm.lifetime.start.p0(i64 16, ptr %agg.tmp2.i)
  store ptr %particles, ptr %agg.tmp2.i, align 8, !tbaa !8, !noalias !5
  %0 = load ptr, ptr %agg.tmp2.i, align 8, !noalias !5
  call void null(ptr sret(%"struct.std::pair.10") align 8 %R, i32 noundef 0, i32 noundef %n, ptr %0)
  call void @llvm.lifetime.end.p0(i64 16, ptr %agg.tmp2.i)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %minPt) #6
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %minPt, ptr noundef nonnull align 8 dereferenceable(24) %R, i64 24, i1 false), !tbaa.struct !14
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %maxPt) #6
  %second = getelementptr inbounds %"struct.std::pair.10", ptr %R, i64 0, i32 1
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %maxPt, ptr noundef nonnull align 8 dereferenceable(24) %second, i64 24, i1 false), !tbaa.struct !14
  %cmp2 = icmp slt i32 %n, 130
  br label %for.cond

for.cond:                                         ; preds = %entry
  %cmp7 = icmp ult i32 0, 3
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  %cmp.i = icmp eq i32 0, 0
  %cmp2.i = icmp eq i32 0, 1
  %y.i = getelementptr inbounds %class._point3d, ptr %maxPt, i64 0, i32 1
  %z.i = getelementptr inbounds %class._point3d, ptr %maxPt, i64 0, i32 2
  %cond-lvalue.i = select i1 %cmp2.i, ptr %y.i, ptr %z.i
  %cond-lvalue6.i = select i1 %cmp.i, ptr %maxPt, ptr %cond-lvalue.i
  %1 = load double, ptr %cond-lvalue6.i, align 8, !tbaa !15
  %cmp.i62 = icmp eq i32 0, 0
  %cmp2.i63 = icmp eq i32 0, 1
  %y.i64 = getelementptr inbounds %class._point3d, ptr %minPt, i64 0, i32 1
  %z.i65 = getelementptr inbounds %class._point3d, ptr %minPt, i64 0, i32 2
  %cond-lvalue.i66 = select i1 %cmp2.i63, ptr %y.i64, ptr %z.i65
  %cond-lvalue6.i67 = select i1 %cmp.i62, ptr %minPt, ptr %cond-lvalue.i66
  %2 = load double, ptr %cond-lvalue6.i67, align 8, !tbaa !15
  %add = fadd double %1, %2
  %div = fmul double %add, 5.000000e-01
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %for.cond.cleanup
  %__begin.0 = phi i32 [ 0, %for.cond.cleanup ], [ %inc29, %pfor.inc ]
  detach within %syncreg105, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  %idxprom = zext i32 %__begin.0 to i64
  %arrayidx = getelementptr inbounds ptr, ptr %particles, i64 %idxprom
  %3 = load ptr, ptr %arrayidx, align 8, !tbaa !17
  %cmp.i92 = icmp eq i32 0, 0
  %cmp2.i93 = icmp eq i32 0, 1
  %y.i94 = getelementptr inbounds %class._point3d, ptr %3, i64 0, i32 1
  %z.i95 = getelementptr inbounds %class._point3d, ptr %3, i64 0, i32 2
  %cond-lvalue.i96 = select i1 %cmp2.i93, ptr %y.i94, ptr %z.i95
  %cond-lvalue6.i97 = select i1 %cmp.i92, ptr %3, ptr %cond-lvalue.i96
  %4 = load double, ptr %cond-lvalue6.i97, align 8, !tbaa !15
  %cmp26 = fcmp olt double %4, %div
  %arrayidx28 = getelementptr inbounds i8, ptr %Tflags, i64 %idxprom
  %frombool = zext i1 %cmp26 to i8
  store i8 %frombool, ptr %arrayidx28, align 1, !tbaa !18
  reattach within %syncreg105, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body.entry, %pfor.cond
  %inc29 = add nuw nsw i32 %__begin.0, 1
  %cmp30 = icmp slt i32 %inc29, %n
  br label %pfor.cond, !llvm.loop !20
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.experimental.noalias.scope.decl(metadata) #5

; uselistorder directives
uselistorder ptr null, { 1, 3, 4, 0, 6, 5, 2 }
uselistorder i32 0, { 5, 7, 4, 8, 3, 9, 2, 1, 10, 0, 6, 11 }

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { willreturn memory(argmem: readwrite) }
attributes #4 = { uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cascadelake" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+avx512vnni,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-fp16,-amx-int8,-amx-tile,-avx512bf16,-avx512bitalg,-avx512er,-avx512fp16,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vp2intersect,-avx512vpopcntdq,-avxifma,-avxneconvert,-avxvnni,-avxvnniint8,-cldemote,-clzero,-cmpccxadd,-enqcmd,-fma4,-gfni,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchi,-prefetchwt1,-ptwrite,-raoint,-rdpid,-rdpru,-rtm,-serialize,-sgx,-sha,-shstk,-sse4a,-tbm,-tsxldtrk,-uintr,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-widekl,-xop" }
attributes #5 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
attributes #6 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 16.0.6 (git@github.com:neboat/opencilk-project.git 773b1febeb76d8d2a8f647022da481f20f38e862)"}
!5 = !{!6}
!6 = distinct !{!6, !7, !"_ZN8sequence9mapReduceISt4pairI8_point3dIdES3_EP8particlei8minmaxpt6ppairFEET_PT0_T1_T2_T3_: %agg.result"}
!7 = distinct !{!7, !"_ZN8sequence9mapReduceISt4pairI8_point3dIdES3_EP8particlei8minmaxpt6ppairFEET_PT0_T1_T2_T3_"}
!8 = !{!9, !10, i64 0}
!9 = !{!"_ZTSN8sequence5getAFIP8particleSt4pairI8_point3dIdES5_Ei6ppairFEE", !10, i64 0, !13, i64 8}
!10 = !{!"any pointer", !11, i64 0}
!11 = !{!"omnipotent char", !12, i64 0}
!12 = !{!"Simple C++ TBAA"}
!13 = !{!"_ZTS6ppairF"}
!14 = !{i64 0, i64 8, !15, i64 8, i64 8, !15, i64 16, i64 8, !15}
!15 = !{!16, !16, i64 0}
!16 = !{!"double", !11, i64 0}
!17 = !{!10, !10, i64 0}
!18 = !{!19, !19, i64 0}
!19 = !{!"bool", !11, i64 0}
!20 = distinct !{!20, !21}
!21 = !{!"tapir.loop.spawn.strategy", i32 1}
