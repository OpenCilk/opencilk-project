; Check that Tapir lowering always ignores empty functions, even main.
;
; RUN: opt < %s -tapir2target -tapir-target=opencilk -use-opencilk-runtime-bc -opencilk-runtime-bc-path=%S/libopencilk-abi.bc -S -o - | FileCheck %s
; RUN: opt < %s -passes='tapir2target' -tapir-target=opencilk -use-opencilk-runtime-bc -opencilk-runtime-bc-path=%S/libopencilk-abi.bc -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
declare dso_local i32 @main() #0

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 11.1.0 (git@github.com:OpenCilk/opencilk-project.git a64c17613c8e15c431484644b758f036b071e92d)"}

; CHECK-NOT: define {{.*}}@__cilkrts_enter_frame(
; CHECK-NOT: define {{.*}}@__cilkrts_enter_frame_fast(
; CHECK-NOT: define {{.*}}@__cilkrts_detach(
; CHECK-NOT: define {{.*}}@__cilkrts_save_fp_ctrl_state(
; CHECK-NOT: define {{.*}}@__cilkrts_pop_frame(
