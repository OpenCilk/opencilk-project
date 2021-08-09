; RUN: opt < %s -gvn -S | FileCheck %s
; RUN: opt < %s -passes='gvn' -S | FileCheck %s

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
; target triple = "arm64-apple-macosx11.0.0"

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

define dso_local fastcc void @walk_dp_t(i32 %t0, i32 %t1) unnamed_addr #1 {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %sub = sub nsw i32 %t1, %t0
  %0 = icmp ult i32 0, 5
  br i1 %0, label %for.cond.preheader, label %if.else.lr.ph.lr.ph

; CHECK: entry:
; CHECK: br i1 {{.+}}, label %for.cond.preheader, label %if.else.lr.ph.lr.ph

if.else.lr.ph.lr.ph:                              ; preds = %entry
  br label %if.else.lr.ph

if.else.lr.ph:                                    ; preds = %if.else.lr.ph.lr.ph
  br i1 %0, label %if.then7.us, label %if.else.preheader

if.else.preheader:                                ; preds = %if.else.lr.ph
  unreachable

if.then7.us:                                      ; preds = %if.else.lr.ph
  detach within %syncreg, label %det.achd36.us, label %for.cond.preheader

; CHECK: if.then7.us:
; CHECK-NEXT: detach within %syncreg, label %det.achd36.us, label %for.cond.preheader

det.achd36.us:                                    ; preds = %if.then7.us
  unreachable

for.cond.preheader:                               ; preds = %if.then7.us, %entry
  unreachable
}

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 12.0.0 (git@github.com:neboat/opencilk-project.git 6c500f6f6ddef869753764c479379f29c6a129b5)"}
