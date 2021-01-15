; RUN: opt < %s -csan -S -o - | FileCheck %s
; RUN: opt < %s -passes='cilksan' -S -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [12 x i8] c"fib(%d)=%d\0A\00", align 1

; Function Attrs: noinline nounwind optnone sanitize_cilk uwtable
define dso_local i32 @fib(i32 %n) #0 {
; CHECK-LABEL: define dso_local i32 @fib(i32 %n)
entry:
  %retval = alloca i32, align 4
  %n.addr = alloca i32, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %syncreg = call token @llvm.syncregion.start()
  store i32 %n, i32* %n.addr, align 4
  %0 = load i32, i32* %n.addr, align 4
  %cmp = icmp slt i32 %0, 2
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %1 = load i32, i32* %n.addr, align 4
  store i32 %1, i32* %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %2 = call token @llvm.taskframe.create()
  %3 = load i32, i32* %n.addr, align 4
  %sub = sub nsw i32 %3, 1
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.end
  call void @llvm.taskframe.use(token %2)
  %call = call i32 @fib(i32 %sub)
  store i32 %call, i32* %x, align 4
  reattach within %syncreg, label %det.cont

;; Check that instrumentation in the detached block appears after the
;; call to llvm.taskframe.use.

; CHECK: det.achd:
; CHECK: call void @llvm.taskframe.use(
; CHECK: call void @__csan_task(

; CHECK: call void @__csan_task_exit(
; CHECK: reattach within %syncreg,

det.cont:                                         ; preds = %det.achd, %if.end
  %4 = load i32, i32* %n.addr, align 4
  %sub1 = sub nsw i32 %4, 2
  %call2 = call i32 @fib(i32 %sub1)
  store i32 %call2, i32* %y, align 4
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  sync within %syncreg, label %sync.continue3

sync.continue3:                                   ; preds = %sync.continue
  %5 = load i32, i32* %x, align 4
  %6 = load i32, i32* %y, align 4
  %add = add nsw i32 %5, %6
  store i32 %add, i32* %retval, align 4
  br label %return

return:                                           ; preds = %sync.continue3, %if.then
  sync within %syncreg, label %sync.continue4

sync.continue4:                                   ; preds = %return
  %7 = load i32, i32* %retval, align 4
  ret i32 %7
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #1

; Function Attrs: noinline nounwind optnone sanitize_cilk uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %n = alloca i32, align 4
  %result = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 10, i32* %n, align 4
  %0 = load i32, i32* %argc.addr, align 4
  %cmp = icmp sgt i32 %0, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %1 = load i8**, i8*** %argv.addr, align 8
  %arrayidx = getelementptr inbounds i8*, i8** %1, i64 1
  %2 = load i8*, i8** %arrayidx, align 8
  %call = call i32 @atoi(i8* %2) #4
  store i32 %call, i32* %n, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %3 = load i32, i32* %n, align 4
  %call1 = call i32 @fib(i32 %3)
  store i32 %call1, i32* %result, align 4
  %4 = load i32, i32* %n, align 4
  %5 = load i32, i32* %result, align 4
  %call2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), i32 %4, i32 %5)
  ret i32 0
}

; Function Attrs: nounwind readonly
declare dso_local i32 @atoi(i8*) #2

declare dso_local i32 @printf(i8*, ...) #3

attributes #0 = { noinline nounwind optnone sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind readonly }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 3e22cbe3a78cbb88b9a5814fcb6216c4c75bd965)"}
