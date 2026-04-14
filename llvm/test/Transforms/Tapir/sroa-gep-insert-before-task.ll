; Check that SROA unfolds gep(phi) appropriately when the gep is inside a task and the phi is outside of the task.
;
; RUN: opt < %s -passes="cgscc(devirt<4>(function<eager-inv;no-rerun>(sroa<modify-cfg>)))" -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.cv::Mat" = type { i32, i32, i32, i32, ptr, ptr, ptr, ptr, ptr, ptr, %"struct.cv::MatSize", %"struct.cv::MatStep" }
%"struct.cv::MatSize" = type { ptr }
%"struct.cv::MatStep" = type { ptr, [2 x i64] }

define { ptr, i32 } @_ZN2cv5remapERKNS_11_InputArrayERKNS_12_OutputArrayES2_S2_iiRKNS_7Scalar_IdEE() personality ptr null {
entry:
  %map1 = alloca %"class.cv::Mat", align 8
  %syncreg = call token @llvm.syncregion.start()
  call void null(ptr %map1, ptr null)
  br label %if.end451

; CHECK: entry:
; CHECK: %[[SROA_GEP:.+]] = getelementptr i8, ptr %map1, i64 16
; CHECK: br label %if.end451

if.end451:                                        ; preds = %entry
  %0 = phi ptr [ %map1, %entry ]
  br label %pfor.cond

; CHECK: if.end451:
; CHECK: %[[SROA_PHI:.+]] = phi ptr [ %[[SROA_GEP]], %entry ]
; CHECK: br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.cond, %if.end451
  detach within %syncreg, label %pfor.body.entry, label %pfor.cond unwind label %lpad889

; CHECK: pfor.cond:
; CHECK-NEXT: detach within %syncreg, label %pfor.body.entry,

pfor.body.entry:                                  ; preds = %pfor.cond
  %data.i466 = getelementptr i8, ptr %0, i64 16
  br label %for.cond716

; CHECK: pfor.body.entry:
; CHECK-NOT: getelementptr
; CHECK-NEXT: br label %for.cond716

for.cond716:                                      ; preds = %for.cond716, %pfor.body.entry
  br label %for.cond716

lpad889:                                          ; preds = %pfor.cond
  %1 = landingpad { ptr, i32 }
          cleanup
  ret { ptr, i32 } %1
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
