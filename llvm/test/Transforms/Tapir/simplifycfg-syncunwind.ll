; RUN: opt < %s -simplifycfg -S -o - | FileCheck %s
; RUN: opt < %s -passes="simplify-cfg" -S -o - | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline uwtable
define dso_local void @_Z3fool(i64 %n) #0 {
entry:
  %n.addr = alloca i64, align 8
  %syncreg = call token @llvm.syncregion.start()
  store i64 %n, i64* %n.addr, align 8
  %0 = load i64, i64* %n.addr, align 8
  %cmp = icmp slt i64 %0, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  %1 = call token @llvm.taskframe.create()
  %2 = load i64, i64* %n.addr, align 8
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.end
  call void @llvm.taskframe.use(token %1)
  call void @_Z3barl(i64 %2)
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.end
  %3 = load i64, i64* %n.addr, align 8
  %sub = sub nsw i64 %3, 1
  call void @_Z3fool(i64 %sub)
  sync within %syncreg, label %sync.continue
; CHECK: det.cont:
; CHECK: sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  call void @llvm.sync.unwind(token %syncreg)
  sync within %syncreg, label %sync.continue1
; CHECK: sync.continue:
; CHECK-NEXT: call void @llvm.sync.unwind(token %syncreg)
; CHECK-NEXT: br label %[[RETURN:.+]]
; CHECK-NOT: sync within %syncreg
; CHECK-NOT: @llvm.sync.unwind
sync.continue1:                                   ; preds = %sync.continue
  call void @llvm.sync.unwind(token %syncreg)
  br label %return

return:                                           ; preds = %sync.continue1, %if.then
  ret void
; CHECK: [[RETURN]]:
; CHECK-NEXT: ret void
}

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #1

; Function Attrs: argmemonly nounwind
declare token @llvm.taskframe.create() #1

declare dso_local void @_Z3barl(i64) #2

; Function Attrs: argmemonly nounwind
declare void @llvm.taskframe.use(token) #1

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #3

attributes #0 = { noinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git db639dcfae4e150d77c4bd4e70dd936bc908834a)"}
