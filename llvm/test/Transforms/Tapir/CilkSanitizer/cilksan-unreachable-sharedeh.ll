; Check that CilkSanitizer and CSI do not insert hooks for phi nodes
; at placeholder destinations of task exits.
;
; RUN: opt < %s -csan -S | FileCheck %s
; RUN: opt < %s -passes='cilksan' -S | FileCheck %s
; RUN: opt < %s -csi -S | FileCheck %s
; RUN: opt < %s -passes='csi' -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: sanitize_cilk
define dso_local i32 @compute() #0 {
entry:
  %syncreg59 = call token @llvm.syncregion.start()
  %syncreg123 = call token @llvm.syncregion.start()
  br label %lor.lhs.false

lor.lhs.false:                                    ; preds = %entry
  br label %lor.lhs.false6

lor.lhs.false6:                                   ; preds = %lor.lhs.false
  br label %lor.lhs.false8

lor.lhs.false8:                                   ; preds = %lor.lhs.false6
  br label %if.end

if.end:                                           ; preds = %lor.lhs.false8
  br label %pfor.end

pfor.end:                                         ; preds = %if.end
  br label %lor.lhs.false48

lor.lhs.false48:                                  ; preds = %pfor.end
  br label %lor.lhs.false50

lor.lhs.false50:                                  ; preds = %lor.lhs.false48
  br label %lor.lhs.false52

lor.lhs.false52:                                  ; preds = %lor.lhs.false50
  br label %lor.lhs.false54

lor.lhs.false54:                                  ; preds = %lor.lhs.false52
  br label %if.end58

if.end58:                                         ; preds = %lor.lhs.false54
  br i1 undef, label %pfor.ph63, label %pfor.end112

pfor.ph63:                                        ; preds = %if.end58
  br label %pfor.cond70

pfor.cond70:                                      ; preds = %pfor.inc107, %pfor.ph63
  br label %pfor.detach71

pfor.detach71:                                    ; preds = %pfor.cond70
  detach within %syncreg59, label %pfor.body.entry74, label %pfor.inc107

pfor.body.entry74:                                ; preds = %pfor.detach71
  br label %pfor.body76

pfor.body76:                                      ; preds = %pfor.body.entry74
  %call77 = call i32 undef()
  br label %pfor.preattach106

pfor.preattach106:                                ; preds = %pfor.body76
  reattach within %syncreg59, label %pfor.inc107

pfor.inc107:                                      ; preds = %pfor.preattach106, %pfor.detach71
  br label %pfor.cond70

pfor.end112:                                      ; preds = %if.end58
  br label %lor.lhs.false118

lor.lhs.false118:                                 ; preds = %pfor.end112
  br label %if.end122

if.end122:                                        ; preds = %lor.lhs.false118
  br label %pfor.ph127

pfor.ph127:                                       ; preds = %if.end122
  br label %pfor.cond134

pfor.cond134:                                     ; preds = %pfor.inc173, %pfor.ph127
  br label %pfor.detach135

pfor.detach135:                                   ; preds = %pfor.cond134
  detach within %syncreg123, label %pfor.body.entry138, label %pfor.inc173

pfor.body.entry138:                               ; preds = %pfor.detach135
  br label %pfor.body140

pfor.body140:                                     ; preds = %pfor.body.entry138
  %call142 = call i32 undef()
  br label %if.end168

if.end168:                                        ; preds = %pfor.body140
  br label %pfor.preattach172

pfor.preattach172:                                ; preds = %if.end168
  reattach within %syncreg123, label %pfor.inc173

pfor.inc173:                                      ; preds = %pfor.preattach172, %pfor.detach135
  br label %pfor.cond134
}

; CHECK: detach within %syncreg59, label %pfor.body.entry74, label %pfor.inc107 unwind label %{{.+}}
; CHECK: invoke i32
; CHECK-NEXT: to label %{{.+}} unwind label %[[CSI_CLEANUP_TASK:.+]]

; CHECK: detach within %syncreg123, label %pfor.body.entry138, label %pfor.inc173 unwind label %{{.+}}
; CHECK: invoke i32
; CHECK-NEXT: to label %{{.+}} unwind label %[[CSI_CLEANUP_TASK2:.+]]

; CHECK: csi.cleanup.unreachable:
; CHECK-NOT: phi
; CHECK: unreachable

; CHECK: [[CSI_CLEANUP_TASK2]]:
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(
; CHECK-NEXT: to label %csi.cleanup.unreachable unwind label %{{.+}}

; CHECK: [[CSI_CLEANUP_TASK]]:
; CHECK: invoke void @llvm.detached.rethrow.sl_p0i8i32s(
; CHECK-NEXT: to label %csi.cleanup.unreachable unwind label %{{.+}}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #2

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #3

attributes #0 = { sanitize_cilk }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly willreturn }
attributes #3 = { argmemonly nofree nosync nounwind willreturn }
