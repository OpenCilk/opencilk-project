; RUN: opt < %s -simplifycfg -S -o - | FileCheck %s
; RUN: opt < %s -task-simplify -S -o - | FileCheck %s
; RUN: opt < %s -passes='simplify-cfg' -S -o - | FileCheck %s
; RUN: opt < %s -passes='task-simplify' -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@_ZTIi = external dso_local constant i8*
@_ZTIPKc = external dso_local constant i8*
@.str.1 = private unnamed_addr constant [2 x i8] c"a\00", align 1
@.str.2 = private unnamed_addr constant [21 x i8] c"foo inner caught %d\0A\00", align 1
@.str.3 = private unnamed_addr constant [17 x i8] c"foo caught \22%s\22\0A\00", align 1
@.str.4 = private unnamed_addr constant [16 x i8] c"main caught %d\0A\00", align 1
@str = private unnamed_addr constant [3 x i8] c"Hi\00", align 1

; Function Attrs: noreturn uwtable
define dso_local void @_Z7pitcheri(i32 %x) local_unnamed_addr #0 {
entry:
  %exception = tail call i8* @__cxa_allocate_exception(i64 4) #8
  %0 = bitcast i8* %exception to i32*
  store i32 %x, i32* %0, align 16, !tbaa !2
  tail call void @__cxa_throw(i8* %exception, i8* bitcast (i8** @_ZTIi to i8*), i8* null) #9
  unreachable
}

declare dso_local i8* @__cxa_allocate_exception(i64) local_unnamed_addr

declare dso_local void @__cxa_throw(i8*, i8*, i8*) local_unnamed_addr

; Function Attrs: noreturn uwtable
define dso_local void @_Z7pitcherPKc(i8* %x) local_unnamed_addr #0 {
entry:
  %exception = tail call i8* @__cxa_allocate_exception(i64 8) #8
  %0 = bitcast i8* %exception to i8**
  store i8* %x, i8** %0, align 16, !tbaa !6
  tail call void @__cxa_throw(i8* %exception, i8* bitcast (i8** @_ZTIPKc to i8*), i8* null) #9
  unreachable
}

; Function Attrs: uwtable
define dso_local void @_Z3foov() local_unnamed_addr #1 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define {{.*}}void @_Z3foov()
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  detach within %syncreg, label %det.achd, label %det.cont.tf.tf.tf.tf.tf

det.achd:                                         ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str, i64 0, i64 0))
  reattach within %syncreg, label %det.cont.tf.tf.tf.tf.tf

det.cont.tf.tf.tf.tf.tf:                          ; preds = %entry, %det.achd
  br label %det.cont.tf.tf.tf.tf.tf.tf

det.cont.tf.tf.tf.tf.tf.tf:                       ; preds = %det.cont.tf.tf.tf.tf.tf
  %0 = tail call token @llvm.taskframe.create()
  %syncreg1 = tail call token @llvm.syncregion.start()
  detach within %syncreg1, label %det.achd2, label %det.cont7.tf.tf.tf.tf.tf unwind label %lpad4

det.achd2:                                        ; preds = %det.cont.tf.tf.tf.tf.tf.tf
  invoke void @_Z7pitcheri(i32 1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %det.achd2
  reattach within %syncreg1, label %det.cont7.tf.tf.tf.tf.tf

det.cont7.tf.tf.tf.tf.tf:                         ; preds = %invoke.cont, %det.cont.tf.tf.tf.tf.tf.tf
  br label %det.cont7.tf.tf.tf.tf.tf.tf

det.cont7.tf.tf.tf.tf.tf.tf:                      ; preds = %det.cont7.tf.tf.tf.tf.tf
  %1 = tail call token @llvm.taskframe.create()
  invoke void @_Z7pitcherPKc(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.1, i64 0, i64 0))
          to label %try.cont.tfend unwind label %lpad15

lpad:                                             ; preds = %det.achd2
  %2 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg1, { i8*, i32 } %2)
          to label %unreachable unwind label %lpad4

lpad4:                                            ; preds = %det.cont.tf.tf.tf.tf.tf.tf, %lpad
  %3 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIPKc to i8*)
  br label %lpad12.body

lpad12:                                           ; preds = %sync.continue, %ehcleanup26
  %4 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIPKc to i8*)
  br label %lpad12.body

lpad12.body:                                      ; preds = %lpad4, %lpad12
  %eh.lpad-body = phi { i8*, i32 } [ %4, %lpad12 ], [ %3, %lpad4 ]
  %5 = extractvalue { i8*, i32 } %eh.lpad-body, 1
  %6 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIPKc to i8*)) #8
  %matches34 = icmp eq i32 %5, %6
  br i1 %matches34, label %catch35, label %ehcleanup44

; CHECK: lpad12:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIPKc to i8*)
; CHECK:   br i1 %matches34, label %catch35, label %ehcleanup44

catch35:                                          ; preds = %lpad12.body
  %7 = extractvalue { i8*, i32 } %eh.lpad-body, 0
  %8 = tail call i8* @__cxa_begin_catch(i8* %7) #8
  %call40 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.3, i64 0, i64 0), i8* %8)
  tail call void @__cxa_end_catch() #8
  br label %try.cont43.tfend

try.cont43.tfend:                                 ; preds = %catch35, %sync.continue
  tail call void @llvm.taskframe.end(token %0)
  br label %try.cont43.tfend.tfend

try.cont43.tfend.tfend:                           ; preds = %try.cont43.tfend
  sync within %syncreg, label %sync.continue52

sync.continue52:                                  ; preds = %try.cont43.tfend.tfend
  tail call void @llvm.sync.unwind(token %syncreg)
  ret void

lpad15:                                           ; preds = %det.cont7.tf.tf.tf.tf.tf.tf
  %9 = landingpad { i8*, i32 }
          cleanup
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %10 = extractvalue { i8*, i32 } %9, 1
  %11 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #8
  %matches = icmp eq i32 %10, %11
  br i1 %matches, label %catch, label %ehcleanup26

catch:                                            ; preds = %lpad15
  %12 = extractvalue { i8*, i32 } %9, 0
  %13 = tail call i8* @__cxa_begin_catch(i8* %12) #8
  %14 = bitcast i8* %13 to i32*
  %15 = load i32, i32* %14, align 4, !tbaa !2
  %call23 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.2, i64 0, i64 0), i32 %15)
  tail call void @__cxa_end_catch() #8
  br label %try.cont.tfend

try.cont.tfend:                                   ; preds = %catch, %det.cont7.tf.tf.tf.tf.tf.tf
  tail call void @llvm.taskframe.end(token %1)
  br label %try.cont.tfend.tfend

try.cont.tfend.tfend:                             ; preds = %try.cont.tfend
  sync within %syncreg1, label %sync.continue

sync.continue:                                    ; preds = %try.cont.tfend.tfend
  invoke void @llvm.sync.unwind(token %syncreg1)
          to label %try.cont43.tfend unwind label %lpad12

ehcleanup26:                                      ; preds = %lpad15
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %1, { i8*, i32 } %9)
          to label %unreachable unwind label %lpad12

ehcleanup44:                                      ; preds = %lpad12.body
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %0, { i8*, i32 } %eh.lpad-body)
          to label %unreachable unwind label %lpad49

; CHECK: ehcleanup44:
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(
; CHECK-NEXT: to label %unreachable unwind label %lpad49

lpad49:                                           ; preds = %ehcleanup44
  %16 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } %16

; CHECK: lpad49:
; CHECK-NEXT: landingpad
; CHECK-NEXT: cleanup
; CHECK-NEXT: resume

unreachable:                                      ; preds = %ehcleanup44, %ehcleanup26, %lpad
  unreachable
}

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly nounwind
declare token @llvm.taskframe.create() #2

; Function Attrs: nofree nounwind
declare dso_local i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #3

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #4

; Function Attrs: argmemonly
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #4

; Function Attrs: nounwind readnone
declare i32 @llvm.eh.typeid.for(i8*) #5

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @__cxa_end_catch() local_unnamed_addr

; Function Attrs: argmemonly nounwind
declare void @llvm.taskframe.end(token) #2

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #4

; Function Attrs: norecurse uwtable
define dso_local i32 @main(i32 %argc, i8** nocapture readnone %argv) local_unnamed_addr #6 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: define {{.*}}i32 @main(
entry:
  invoke void @_Z3foov()
          to label %try.cont unwind label %lpad
; CHECK: invoke void @_Z3foov()
; CHECK: to label %try.cont unwind label %lpad

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          catch i8* bitcast (i8** @_ZTIi to i8*)
  %1 = extractvalue { i8*, i32 } %0, 1
  %2 = tail call i32 @llvm.eh.typeid.for(i8* bitcast (i8** @_ZTIi to i8*)) #8
  %matches = icmp eq i32 %1, %2
  br i1 %matches, label %catch, label %eh.resume

; CHECK: lpad:
; CHECK-NEXT: landingpad
; CHECK-NEXT: catch i8* bitcast (i8** @_ZTIi to i8*)

catch:                                            ; preds = %lpad
  %3 = extractvalue { i8*, i32 } %0, 0
  %4 = tail call i8* @__cxa_begin_catch(i8* %3) #8
  %5 = bitcast i8* %4 to i32*
  %6 = load i32, i32* %5, align 4, !tbaa !2
  %call = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.4, i64 0, i64 0), i32 %6)
  tail call void @__cxa_end_catch() #8
  br label %try.cont

try.cont:                                         ; preds = %entry, %catch
  ret i32 0

eh.resume:                                        ; preds = %lpad
  resume { i8*, i32 } %0

; CHECK: ret i32
; CHECK: resume
}

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #7

attributes #0 = { noreturn uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind }
attributes #3 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { argmemonly }
attributes #5 = { nounwind readnone }
attributes #6 = { norecurse uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree nounwind }
attributes #8 = { nounwind }
attributes #9 = { noreturn }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git c0a9e1b4a715a1859790af0a448a1eb4cc2ed13f)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"any pointer", !4, i64 0}
