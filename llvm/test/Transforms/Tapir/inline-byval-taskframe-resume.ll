; Check that function inlining properly handles byval arguments around taskframes and resumes.
;
; RUN: opt < %s -passes="always-inline" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.in_imap = type { %class.anon, i64, i64 }
%class.anon = type { ptr }
%class.anon.6 = type { ptr, ptr, ptr }
%struct.array_imap = type <{ ptr, ptr, i8, [7 x i8] }>

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

define void @_Z7ComputeI25compressedSymmetricVertexEvR5graphIT_E11commandLine(ptr %GA, i1 %cmp2) local_unnamed_addr {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %pfor.detach

pfor.detach:                                      ; preds = %pfor.inc, %entry
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.detach
  store i8 0, ptr %GA, align 1
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body.entry, %pfor.detach
  br i1 %cmp2, label %pfor.detach, label %pfor.cond.cleanup

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg, label %while.cond

while.cond:                                       ; preds = %while.cond, %pfor.cond.cleanup
  call void @_Z12vertexFilterI14Deg_LessThan_KI25compressedSymmetricVertexEE16vertexSubsetDataIN4pbbs5emptyEES6_T_()
  br label %while.cond
}

; CHECK: define {{.*}}void @_Z7ComputeI25compressedSymmetricVertexEvR5graphIT_E11commandLine(
; CHECK: while.cond:
; CHECK-NEXT: br label %[[WHILE_COND_TF:.+]]

; CHECK: [[WHILE_COND_TF]]:
; CHECK-NEXT: %[[TF_I:.+]] = call token @llvm.taskframe.create()
; CHECK-NEXT: alloca
; CHECK-NEXT: alloca
; CHECK-NEXT: alloca
; CHECK-NEXT: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()

; CHECK: br i1 %{{.+}}, label %[[PFOR_DETACH:.+]], label %[[EXIT:.+]]
; CHECK: [[PFOR_DETACH]]:
; CHECK: detach within %[[SYNCREG]], label %{{.+}}, label %[[PFOR_INC:.+]]
; CHECK: reattach within %[[SYNCREG]]
; CHECK: [[PFOR_INC]]:
; CHECK: br label %[[PFOR_DETACH]]

; CHECK: [[EXIT]]:
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.memcpy
; CHECK: invoke void @_ZN4pbbs10sliced_forIZNS_6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPbEUlmE_EZNS5_C1ElS6_EUlmmE_EENT_1TESA_RKT0_jEUlmmmE_EEvmmRKSA_
; CHECK-NEXT: to label %[[INVOKE_CONT:.+]] unwind label %[[LPAD_I:.+]]

; CHECK: [[LPAD_I]]:
; CHECK-NEXT: landingpad { ptr, i32 }
; CHECK-NEXT: cleanup
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF_I]],
; CHECK-NEXT: to label %{{.+}} unwind label %[[LPAD_SPLIT:.+]]

; CHECK: [[LPAD_SPLIT]]:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: resume

; CHECK: [[INVOKE_CONT]]:
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK-NEXT: call void @llvm.taskframe.end(token %[[TF_I]])
; CHECK: br label %while.cond

; Function Attrs: alwaysinline
define void @_Z12vertexFilterI14Deg_LessThan_KI25compressedSymmetricVertexEE16vertexSubsetDataIN4pbbs5emptyEES6_T_() local_unnamed_addr #1 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %call = load volatile i64, ptr null, align 8
  %cmp = icmp sgt i64 %call, 0
  br i1 %cmp, label %pfor.detach, label %pfor.initcond.cleanup

pfor.initcond.cleanup:                            ; preds = %entry
  call void @_ZN16vertexSubsetDataIN4pbbs5emptyEEC2ElPb()
  ret void

pfor.detach:                                      ; preds = %pfor.inc, %entry
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %entry ]
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.detach
  %arrayidx = getelementptr i8, ptr null, i64 %__begin.0
  store i8 poison, ptr %arrayidx, align 1
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body.entry, %pfor.detach
  %inc = add i64 %__begin.0, 1
  br label %pfor.detach
}

; Function Attrs: alwaysinline
define void @_ZN16vertexSubsetDataIN4pbbs5emptyEEC2ElPb() local_unnamed_addr #1 {
entry:
  %call = call i64 @_ZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPbEUlmE_EZNS4_C1ElS5_EUlmmE_EENT_1TES9_RKT0_j(ptr null)
  ret void
}

; Function Attrs: alwaysinline
define i64 @_ZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPbEUlmE_EZNS4_C1ElS5_EUlmmE_EENT_1TES9_RKT0_j(ptr byval(%struct.in_imap) %A) local_unnamed_addr #1 personality ptr null {
entry:
  %ref.tmp1111 = alloca [0 x [0 x [0 x [0 x %class.anon.6]]]], align 8
  %Sums = alloca %struct.array_imap, align 8
  %call = call i64 @_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPbEUlmE_E4sizeEv()
  %call1 = call i64 @_ZN4pbbs10num_blocksEmm()
  call void @_ZN10array_imapImEC2Em()
  store ptr %Sums, ptr %ref.tmp1111, align 8
  invoke void @_ZN4pbbs10sliced_forIZNS_6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPbEUlmE_EZNS5_C1ElS6_EUlmmE_EENT_1TESA_RKT0_jEUlmmmE_EEvmmRKSA_(i64 0, i64 0, ptr nonnull %ref.tmp1111)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  call void @_ZN10array_imapImEC2ERKS0_()
  %call8 = call i64 @_ZN4pbbs13reduce_serialI10array_imapImEZN16vertexSubsetDataINS_5emptyEEC1ElPbEUlmmE_EENT_1TES8_RKT0_()
  call void @_ZN10array_imapImED2Ev()
  call void @_ZN10array_imapImED2Ev()
  ret i64 0

lpad:                                             ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  call void @_ZN10array_imapImED2Ev()
  resume { ptr, i32 } zeroinitializer
}

declare i64 @_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPbEUlmE_E4sizeEv() local_unnamed_addr

declare i64 @_ZN4pbbs10num_blocksEmm() local_unnamed_addr

declare void @_ZN10array_imapImEC2Em() local_unnamed_addr

declare void @_ZN4pbbs10sliced_forIZNS_6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPbEUlmE_EZNS5_C1ElS6_EUlmmE_EENT_1TESA_RKT0_jEUlmmmE_EEvmmRKSA_(i64, i64, ptr) local_unnamed_addr

declare i64 @_ZN4pbbs13reduce_serialI10array_imapImEZN16vertexSubsetDataINS_5emptyEEC1ElPbEUlmmE_EENT_1TES8_RKT0_() local_unnamed_addr

declare void @_ZN10array_imapImEC2ERKS0_() local_unnamed_addr

declare void @_ZN10array_imapImED2Ev() local_unnamed_addr

attributes #0 = { mustprogress nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { alwaysinline }
