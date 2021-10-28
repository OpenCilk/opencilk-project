; Check static race detection with calls to bitcast functions in
; blocks terminated by unreachable.
;
; RUN: opt < %s -analyze -tapir-race-detect 2>&1 | FileCheck %s
; RUN: opt < %s -passes='print<race-detect>' -disable-output 2>&1 | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: sanitize_cilk
define dso_local void @setup() local_unnamed_addr #0 {
entry:
  tail call void (i32, ...) bitcast (void (...)* @bpnn_initialize to void (i32, ...)*)(i32 7) #2
  unreachable
}

; CHECK: tail call void (i32, ...) bitcast (void (...)* @bpnn_initialize to void (i32, ...)*)(i32 7)
; CHECK: Opaque
; CHECK: Opaque racer

declare dso_local void @bpnn_initialize(...) local_unnamed_addr #1

attributes #0 = { sanitize_cilk }
attributes #1 = { "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 33ec1ef302b9173b44ffda58e6ad9447b803598a)"}
