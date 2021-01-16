; RUN: llc < %s -mtriple=x86_64-freebsd | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-freebsd13.0"

; Function Attrs: nounwind uwtable
define dso_local void @test_function() local_unnamed_addr #0 {
entry:
; LABEL: test_function
  %b = alloca [5 x i8*], align 16
  %0 = bitcast [5 x i8*]* %b to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %0) #3
  %arraydecay = getelementptr inbounds [5 x i8*], [5 x i8*]* %b, i64 0, i64 0
  %1 = call i8* @llvm.frameaddress.p0i8(i32 0)
  store i8* %1, i8** %arraydecay, align 16
  %2 = call i8* @llvm.stacksave()
  %3 = getelementptr inbounds [5 x i8*], [5 x i8*]* %b, i64 0, i64 2
  store i8* %2, i8** %3, align 16
; setjmp should be followed by a call and an unconditional branch
; CHECK: EH_SjLj_Setup
; CHECK-NOT: test
; CHECK-NOT: xor
; CHECK: jmp
  %4 = call i32 @llvm.eh.sjlj.setjmp(i8* nonnull %0)
  %tobool.not = icmp eq i32 %4, 0
  br i1 %tobool.not, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  call void (...) @g() #3
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
