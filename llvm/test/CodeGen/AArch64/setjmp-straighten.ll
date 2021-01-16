; RUN: llc < %s -mtriple=aarch64-freebsd | FileCheck %s

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-freebsd13.0"

; Function Attrs: nounwind uwtable
define dso_local void @f() local_unnamed_addr #0 {
entry:
  %b = alloca [5 x i8*], align 8
  %0 = bitcast [5 x i8*]* %b to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %0) #3
  %arraydecay = getelementptr inbounds [5 x i8*], [5 x i8*]* %b, i64 0, i64 0
  %1 = call i8* @llvm.frameaddress.p0i8(i32 0)
  store i8* %1, i8** %arraydecay, align 8
  %2 = call i8* @llvm.stacksave()
  %3 = getelementptr inbounds [5 x i8*], [5 x i8*]* %b, i64 0, i64 2
  store i8* %2, i8** %3, align 8
; setjmp should be followed by a call and an unconditional branch
; CHECK: EH_SjLj_Setup .LBB0_2
; CHECK-NEXT: .LBB0_1
; CHECK-NEXT: x0, sp
; CHECK-NEXT: bl h
; CHECK-NEXT: b .LBB
  %4 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %0)
  %tobool = icmp eq i32 %4, 0
  br i1 %tobool, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  call void bitcast (void (...)* @g to void ()*)() #3
  br label %if.end

if.else:                                          ; preds = %entry
  call void @h(i8** nonnull %arraydecay) #3
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %0) #3
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #2

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #3

; Function Attrs: nounwind
declare i32 @llvm.eh.sjlj.setjmp(i8*) #3

declare dso_local void @g(...) local_unnamed_addr #4

declare dso_local void @h(i8**) local_unnamed_addr #4

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1
