; Check that the OpenCilk Tapir target properly handles invalid
; bitcode files.
;
; RUN: not opt < %s -passes='tapir2target' -tapir-target=opencilk -use-opencilk-runtime-bc -opencilk-runtime-bc-path=fake 2>&1 | FileCheck %s

; CHECK: error: OpenCilkABI: Failed to parse bitcode ABI file: fake

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree nosync nounwind readnone uwtable
define dso_local i32 @fib(i32 noundef %n) local_unnamed_addr #0 {
entry:
  %x = alloca i32, align 4
  %syncreg = call token @llvm.syncregion.start()
  %cmp = icmp slt i32 %n, 2
  br i1 %cmp, label %return, label %if.end

if.end:                                           ; preds = %entry
  %x.0.x.0.x.0..sroa_cast = bitcast i32* %x to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %x.0.x.0.x.0..sroa_cast)
  %0 = call token @llvm.tapir.runtime.start()
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.end
  %sub = add nsw i32 %n, -1
  %call = call i32 @fib(i32 noundef %sub)
  store i32 %call, i32* %x, align 4, !tbaa !3
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.end
  %sub1 = add nsw i32 %n, -2
  %call2 = call i32 @fib(i32 noundef %sub1)
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  call void @llvm.tapir.runtime.end(token %0)
  %x.0.load = load i32, i32* %x, align 4
  %add = add nsw i32 %x.0.load, %call2
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %x.0.x.0.x.0..sroa_cast)
  br label %return

return:                                           ; preds = %entry, %sync.continue
  %retval.0 = phi i32 [ %add, %sync.continue ], [ %n, %entry ]
  ret i32 %retval.0
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.tapir.runtime.start() #2

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare void @llvm.tapir.runtime.end(token) #2

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nofree nosync nounwind readnone uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { argmemonly mustprogress nounwind willreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git da551ae29c1fa35c06c4994d821fa1fec76eece9)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
