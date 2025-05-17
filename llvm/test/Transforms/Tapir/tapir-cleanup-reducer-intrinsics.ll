; Check that codegen properly handles reducer intrinsics.
;
; RUN: llc < %s -o - 2>&1 | FileCheck %s
; REQUIRES: x86-registered-target
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @_ZNK5Graph4pbfsEiPj() personality ptr null {
entry:
  %syncreg13 = tail call token @llvm.syncregion.start()
  %syncreg13.strpm.detachloop = call token @llvm.syncregion.start()
  call void @llvm.reducer.register.i64(ptr null, i64 0, ptr null, ptr null)
  %0 = call ptr @llvm.hyper.lookup.i64(ptr null, i64 0, ptr null, ptr null)
  store i32 0, ptr %0, align 8
  call void @llvm.reducer.unregister(ptr null)
  ret i32 0
}

; CHECK: .globl  _ZNK5Graph4pbfsEiPj
; CHECK: _ZNK5Graph4pbfsEiPj:
; CHECK: movl $0, 0
; CHECK-NEXT: xorl %eax, %eax
; CHECK-NEXT: retq

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: mustprogress nounwind reducer_register willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.reducer.register.i64(ptr, i64, ptr, ptr) #2

; Function Attrs: hyper_view injective nounwind strand_pure willreturn memory(inaccessiblemem: read)
declare ptr @llvm.hyper.lookup.i64(ptr, i64, ptr, ptr) #1

; Function Attrs: mustprogress nounwind reducer_unregister willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.reducer.unregister(ptr) #3

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }
uselistorder ptr @llvm.syncregion.start, { 1, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { hyper_view injective nounwind strand_pure willreturn memory(inaccessiblemem: read) }
attributes #2 = { mustprogress nounwind reducer_register willreturn memory(inaccessiblemem: readwrite) }
attributes #3 = { mustprogress nounwind reducer_unregister willreturn memory(inaccessiblemem: readwrite) }
