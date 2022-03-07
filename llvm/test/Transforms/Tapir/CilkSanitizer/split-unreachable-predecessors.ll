; Check that CilkSanitizer and CSI maintain invariants on the CFG
; structure for detached.rethrow terminators, specifically, that the
; normal destinations of those terminators are terminated by
; unreachable.
;
; RUN: opt < %s -enable-new-pm=0 -csan -S | FileCheck %s
; RUN: opt < %s -enable-new-pm=0 -csi -S | FileCheck %s
; RUN: opt < %s -passes='cilksan' -S | FileCheck %s
; RUN: opt < %s -passes='csi' -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str.26 = external dso_local unnamed_addr constant [21 x i8], align 1
@.str.96 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.106 = external dso_local unnamed_addr constant [33 x i8], align 1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #1

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #1

declare dso_local void @printf(i8*, ...) #2

declare dso_local void @fopen() #2

declare dso_local void @_ZN13SparseMatrixV17insert_batch_sortEP9_pair_elsm() #2 align 2

declare dso_local i32 @_ZNK13SparseMatrixV8get_rowsEv() #2 align 2

; Function Attrs: sanitize_cilk
define dso_local void @_Z13make_ER_graphjdbNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE() #3 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %entry
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc unwind label %lpad9

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  invoke void @_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EEC2Em()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %pfor.body
  unreachable

lpad:                                             ; preds = %pfor.body
  %0 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } undef)
          to label %unreachable unwind label %lpad9

; CHECK: lpad:
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg,
; CHECK-NEXT: to label %[[DR_UNREACHABLE:.+]] unwind label %[[DR_LPAD:.+]]

pfor.inc:                                         ; preds = %pfor.cond
  sync within %syncreg, label %sync.continue

; CHECK: [[DR_LPAD]]:
; CHECK: call void @__{{csi|csan}}_detach_continue(

lpad9:                                            ; preds = %invoke.cont45, %invoke.cont50, %invoke.cont47, %invoke.cont54, %sync.continue, %lpad, %pfor.cond
  %1 = landingpad { i8*, i32 }
          cleanup
  unreachable

sync.continue:                                    ; preds = %pfor.inc
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %invoke.cont14 unwind label %lpad9

invoke.cont14:                                    ; preds = %sync.continue
  invoke void @_ZN13SparseMatrixV17insert_batch_sortEP9_pair_elsm()
          to label %invoke.cont45 unwind label %lpad20

lpad20:                                           ; preds = %invoke.cont14
  %2 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } undef

invoke.cont45:                                    ; preds = %invoke.cont14
  %call48 = invoke i32 @_ZNK13SparseMatrixV8get_rowsEv()
          to label %invoke.cont47 unwind label %lpad9

invoke.cont47:                                    ; preds = %invoke.cont45
  invoke void (i8*, ...) @printf(i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.106, i64 0, i64 0), i32 %call48, i64 undef)
          to label %invoke.cont50 unwind label %lpad9

invoke.cont50:                                    ; preds = %invoke.cont47
  invoke void @fopen()
          to label %invoke.cont54 unwind label %lpad9

invoke.cont54:                                    ; preds = %invoke.cont50
  invoke void (i8*, ...) @printf(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.26, i64 0, i64 0))
          to label %invoke.cont58 unwind label %lpad9

invoke.cont58:                                    ; preds = %invoke.cont54
  br label %cleanup

cleanup:                                          ; preds = %invoke.cont58
  switch i32 undef, label %unreachable [
    i32 0, label %cleanup.cont
    i32 1, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup, %cleanup
  ret void

unreachable:                                      ; preds = %cleanup, %lpad
  unreachable

; CHECK: [[DR_UNREACHABLE]]:
; CHECK-NEXT: unreachable

; CHECK: unreachable:
; CHECK: unreachable
}

declare dso_local void @_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EEC2Em() unnamed_addr #2 align 2

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { argmemonly willreturn }
attributes #2 = { "use-soft-float"="false" }
attributes #3 = { sanitize_cilk }

!llvm.ident = !{!0}

!0 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 4d80e6a7a90c31e586bba77b4331ffc6cab1c232)"}
