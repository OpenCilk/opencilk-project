; Check that loop spawning can handle a Tapir loop with an unusual comparison test for its backedge.
;
; RUN: opt < %s -loop-spawning-ti -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: uwtable
define dso_local void @_Z10learn_lstmb(i1 zeroext %parallel) local_unnamed_addr #0 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  br label %pfor.cond.preheader

pfor.cond.preheader:                              ; preds = %sync.continue69, %entry
  %iter.0116 = phi i32 [ 0, %entry ], [ %inc75, %sync.continue69 ]
  br label %pfor.cond

for.cond.cleanup:                                 ; preds = %sync.continue69
  ret void

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc64
  %__begin.0 = phi i32 [ %inc65, %pfor.inc64 ], [ 0, %pfor.cond.preheader ]
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc64

pfor.body.entry:                                  ; preds = %pfor.cond
  %syncreg26 = call token @llvm.syncregion.start()
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  %call = call dereferenceable(80) i8* @_Znam(i64 80) #6
  %0 = bitcast i8* %call to double*
  br label %pfor.cond17

pfor.cond17:                                      ; preds = %pfor.inc, %pfor.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %pfor.inc ], [ 0, %pfor.body ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  detach within %syncreg26, label %pfor.body.entry21, label %pfor.inc

pfor.body.entry21:                                ; preds = %pfor.cond17
  br label %pfor.body22

pfor.body22:                                      ; preds = %pfor.body.entry21
  %1 = trunc i64 %indvars.iv to i32
  %conv = sitofp i32 %1 to double
  %arrayidx = getelementptr inbounds double, double* %0, i64 %indvars.iv
  store double %conv, double* %arrayidx, align 8, !tbaa !2
  reattach within %syncreg26, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body22, %pfor.cond17
  %exitcond = icmp eq i64 %indvars.iv.next, 9
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond17, !llvm.loop !6

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg26, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  call void @llvm.sync.unwind(token %syncreg26)
  br label %pfor.cond38

pfor.cond38:                                      ; preds = %pfor.inc52, %sync.continue
  %indvars.iv117 = phi i64 [ %indvars.iv.next118, %pfor.inc52 ], [ 0, %sync.continue ]
  %indvars.iv.next118 = add nuw nsw i64 %indvars.iv117, 1
  detach within %syncreg26, label %pfor.body.entry42, label %pfor.inc52

pfor.body.entry42:                                ; preds = %pfor.cond38
  br label %pfor.body44

pfor.body44:                                      ; preds = %pfor.body.entry42
  %2 = trunc i64 %indvars.iv117 to i32
  %conv45 = sitofp i32 %2 to double
  %arrayidx47 = getelementptr inbounds double, double* %0, i64 %indvars.iv117
  %3 = load double, double* %arrayidx47, align 8, !tbaa !2
  %mul48 = fmul double %3, %conv45
  store double %mul48, double* %arrayidx47, align 8, !tbaa !2
  reattach within %syncreg26, label %pfor.inc52

pfor.inc52:                                       ; preds = %pfor.body44, %pfor.cond38
  %exitcond119 = icmp eq i64 %indvars.iv.next118, 9
  br i1 %exitcond119, label %pfor.cond.cleanup55, label %pfor.cond38, !llvm.loop !8

pfor.cond.cleanup55:                              ; preds = %pfor.inc52
  sync within %syncreg26, label %sync.continue57

sync.continue57:                                  ; preds = %pfor.cond.cleanup55
  call void @llvm.sync.unwind(token %syncreg26)
  call void @_ZdaPv(i8* %call) #7
  reattach within %syncreg, label %pfor.inc64

pfor.inc64:                                       ; preds = %sync.continue57, %pfor.cond
  %inc65 = add nuw nsw i32 %__begin.0, 1
  %cmp66 = icmp eq i32 %__begin.0, 0
  br i1 %cmp66, label %pfor.cond, label %pfor.cond.cleanup67, !llvm.loop !9

pfor.cond.cleanup67:                              ; preds = %pfor.inc64
  sync within %syncreg, label %sync.continue69

sync.continue69:                                  ; preds = %pfor.cond.cleanup67
  call void @llvm.sync.unwind(token %syncreg)
  %inc75 = add nuw nsw i32 %iter.0116, 1
  %exitcond120 = icmp eq i32 %inc75, 1000
  br i1 %exitcond120, label %for.cond.cleanup, label %pfor.cond.preheader
}

; CHECK-LABEL: define {{.*}}void @_Z10learn_lstmb.outline_pfor.cond.ls2(
; CHECK: i32 {{.*}},
; CHECK: i32 %[[END:.+]],

; CHECK: pfor.cond.ls2:
; CHECK: %[[IV:.+]] = phi i32

; CHECK: pfor.inc64.ls2:
; CHECK: %[[INC:.+]] = add {{.*}}i32 %[[IV]], 1
; CHECK: %[[CMP:.+]] = icmp ne i32 %[[INC]], %[[END]]
; CHECK: br i1 %[[CMP]], label %pfor.cond.ls2, label

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znam(i64) local_unnamed_addr #2

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #3

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdaPv(i8*) local_unnamed_addr #4

; Function Attrs: norecurse uwtable
define dso_local i32 @main(i32 %argc, i8** nocapture readnone %argv) local_unnamed_addr #5 {
entry:
  call void @_Z10learn_lstmb(i1 zeroext undef)
  ret i32 0
}

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly willreturn }
attributes #4 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { norecurse uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { builtin }
attributes #7 = { builtin nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:neboat/opencilk-project.git 2c7e581b441a9ae5682f02090613d00aaa26460d)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"double", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = distinct !{!6, !7}
!7 = !{!"tapir.loop.spawn.strategy", i32 1}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
