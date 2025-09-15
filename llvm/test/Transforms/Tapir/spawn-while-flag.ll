; Check that a spawned task can spin on an atomic flag that is set in the continuation.
;
; Optimizing away this loop and the continuation are technically allowed by the serial projection,
; but it's convenient to allow this use of atomics.
;
; RUN: opt < %s -passes="default<O1>" -S | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"struct.std::__atomic_base" = type { i8 }
%class.anon = type { i8 }

$_ZNSt6atomicIbE5storeEbSt12memory_order = comdat any

$_ZNKSt6atomicIbE4loadESt12memory_order = comdat any

$_ZNKSt13__atomic_baseIbE4loadESt12memory_order = comdat any

$_ZStanSt12memory_orderSt23__memory_order_modifier = comdat any

$_ZNSt13__atomic_baseIbE5storeEbSt12memory_order = comdat any

; Function Attrs: mustprogress uwtable
define dso_local void @_Z3foov() #0 {
entry:
  %done_flag = alloca %"struct.std::atomic", align 1
  %syncreg = call token @llvm.syncregion.start()
  call void @llvm.lifetime.start.p0(i64 1, ptr %done_flag) #9
  call void @llvm.memset.p0.i64(ptr align 1 %done_flag, i8 0, i64 1, i1 false)
  %0 = call token @llvm.taskframe.create()
  %ref.tmp = alloca %class.anon, align 1
  call void @llvm.lifetime.start.p0(i64 1, ptr %ref.tmp) #9
  detach within %syncreg, label %det.achd, label %det.cont

det.achd:                                         ; preds = %entry
  call void @llvm.taskframe.use(token %0)
  call void @"_ZZ3foovENK3$_0clERSt6atomicIbE"(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp, ptr noundef nonnull align 1 dereferenceable(1) %done_flag)
  call void @llvm.lifetime.end.p0(i64 1, ptr %ref.tmp) #9
  reattach within %syncreg, label %det.cont

det.cont:                                         ; preds = %det.achd, %entry
  call void @_Z3bazv()
  call void @_ZNSt6atomicIbE5storeEbSt12memory_order(ptr noundef nonnull align 1 dereferenceable(1) %done_flag, i1 noundef zeroext true, i32 noundef 3) #9
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %det.cont
  call void @llvm.sync.unwind(token %syncreg)
  call void @llvm.lifetime.end.p0(i64 1, ptr %done_flag) #9
  ret void
}

; CHECK: define {{.*}}void @_Z3foov()
; CHECK: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]
; CHECK: [[DETACHED]]:
; CHECK: call void @_Z3barv()
; CHECK: reattach within %[[SYNCREG]], label %[[CONTINUE]]
; CHECK: [[CONTINUE]]:
; CHECK: call void @_Z3bazv()
; CHECK: sync within %[[SYNCREG]],

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #3

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #3

; Function Attrs: inlinehint mustprogress uwtable
define internal void @"_ZZ3foovENK3$_0clERSt6atomicIbE"(ptr noundef nonnull align 1 dereferenceable(1) %this, ptr noundef nonnull align 1 dereferenceable(1) %flag) #4 align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %flag.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  store ptr %flag, ptr %flag.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load ptr, ptr %flag.addr, align 8, !tbaa !5
  %call = call noundef zeroext i1 @_ZNKSt6atomicIbE4loadESt12memory_order(ptr noundef nonnull align 1 dereferenceable(1) %0, i32 noundef 2) #9
  %lnot = xor i1 %call, true
  br i1 %lnot, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  call void @_Z3barv()
  br label %while.cond, !llvm.loop !9

while.end:                                        ; preds = %while.cond
  ret void
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare void @llvm.taskframe.use(token) #3

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

declare void @_Z3bazv() #5

; Function Attrs: mustprogress nounwind uwtable
define linkonce_odr dso_local void @_ZNSt6atomicIbE5storeEbSt12memory_order(ptr noundef nonnull align 1 dereferenceable(1) %this, i1 noundef zeroext %__i, i32 noundef %__m) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %__i.addr = alloca i8, align 1
  %__m.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %storedv = zext i1 %__i to i8
  store i8 %storedv, ptr %__i.addr, align 1, !tbaa !12
  store i32 %__m, ptr %__m.addr, align 4, !tbaa !14
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_base = getelementptr inbounds %"struct.std::atomic", ptr %this1, i32 0, i32 0
  %0 = load i8, ptr %__i.addr, align 1, !tbaa !12, !range !16, !noundef !17
  %loadedv = trunc i8 %0 to i1
  %1 = load i32, ptr %__m.addr, align 4, !tbaa !14
  call void @_ZNSt13__atomic_baseIbE5storeEbSt12memory_order(ptr noundef nonnull align 1 dereferenceable(1) %_M_base, i1 noundef zeroext %loadedv, i32 noundef %1) #9
  ret void
}

; Function Attrs: willreturn memory(argmem: readwrite)
declare void @llvm.sync.unwind(token) #7

; Function Attrs: mustprogress nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt6atomicIbE4loadESt12memory_order(ptr noundef nonnull align 1 dereferenceable(1) %this, i32 noundef %__m) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %__m.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  store i32 %__m, ptr %__m.addr, align 4, !tbaa !14
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_base = getelementptr inbounds %"struct.std::atomic", ptr %this1, i32 0, i32 0
  %0 = load i32, ptr %__m.addr, align 4, !tbaa !14
  %call = call noundef zeroext i1 @_ZNKSt13__atomic_baseIbE4loadESt12memory_order(ptr noundef nonnull align 1 dereferenceable(1) %_M_base, i32 noundef %0) #9
  ret i1 %call
}

declare void @_Z3barv() #5

; Function Attrs: alwaysinline mustprogress nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt13__atomic_baseIbE4loadESt12memory_order(ptr noundef nonnull align 1 dereferenceable(1) %this, i32 noundef %__m) #8 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %__m.addr = alloca i32, align 4
  %__b = alloca i32, align 4
  %atomic-temp = alloca i8, align 1
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  store i32 %__m, ptr %__m.addr, align 4, !tbaa !14
  %this1 = load ptr, ptr %this.addr, align 8
  call void @llvm.lifetime.start.p0(i64 4, ptr %__b) #9
  %0 = load i32, ptr %__m.addr, align 4, !tbaa !14
  %call = call noundef i32 @_ZStanSt12memory_orderSt23__memory_order_modifier(i32 noundef %0, i32 noundef 65535) #9
  store i32 %call, ptr %__b, align 4, !tbaa !14
  br label %do.body

do.body:                                          ; preds = %entry
  br label %do.cond

do.cond:                                          ; preds = %do.body
  br label %do.end

do.end:                                           ; preds = %do.cond
  br label %do.body2

do.body2:                                         ; preds = %do.end
  br label %do.cond3

do.cond3:                                         ; preds = %do.body2
  br label %do.end4

do.end4:                                          ; preds = %do.cond3
  %_M_i = getelementptr inbounds %"struct.std::__atomic_base", ptr %this1, i32 0, i32 0
  %1 = load i32, ptr %__m.addr, align 4, !tbaa !14
  switch i32 %1, label %monotonic [
    i32 1, label %acquire
    i32 2, label %acquire
    i32 5, label %seqcst
  ]

monotonic:                                        ; preds = %do.end4
  %2 = load atomic i8, ptr %_M_i monotonic, align 1
  store i8 %2, ptr %atomic-temp, align 1
  br label %atomic.continue

acquire:                                          ; preds = %do.end4, %do.end4
  %3 = load atomic i8, ptr %_M_i acquire, align 1
  store i8 %3, ptr %atomic-temp, align 1
  br label %atomic.continue

seqcst:                                           ; preds = %do.end4
  %4 = load atomic i8, ptr %_M_i seq_cst, align 1
  store i8 %4, ptr %atomic-temp, align 1
  br label %atomic.continue

atomic.continue:                                  ; preds = %seqcst, %acquire, %monotonic
  %5 = load i8, ptr %atomic-temp, align 1, !tbaa !12, !range !16, !noundef !17
  %loadedv = trunc i8 %5 to i1
  call void @llvm.lifetime.end.p0(i64 4, ptr %__b) #9
  ret i1 %loadedv
}

; Function Attrs: mustprogress nounwind uwtable
define linkonce_odr dso_local noundef i32 @_ZStanSt12memory_orderSt23__memory_order_modifier(i32 noundef %__m, i32 noundef %__mod) #6 comdat {
entry:
  %__m.addr = alloca i32, align 4
  %__mod.addr = alloca i32, align 4
  store i32 %__m, ptr %__m.addr, align 4, !tbaa !14
  store i32 %__mod, ptr %__mod.addr, align 4, !tbaa !18
  %0 = load i32, ptr %__m.addr, align 4, !tbaa !14
  %1 = load i32, ptr %__mod.addr, align 4, !tbaa !18
  %and = and i32 %0, %1
  ret i32 %and
}

; Function Attrs: alwaysinline mustprogress nounwind uwtable
define linkonce_odr dso_local void @_ZNSt13__atomic_baseIbE5storeEbSt12memory_order(ptr noundef nonnull align 1 dereferenceable(1) %this, i1 noundef zeroext %__i, i32 noundef %__m) #8 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %__i.addr = alloca i8, align 1
  %__m.addr = alloca i32, align 4
  %__b = alloca i32, align 4
  %.atomictmp = alloca i8, align 1
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %storedv = zext i1 %__i to i8
  store i8 %storedv, ptr %__i.addr, align 1, !tbaa !12
  store i32 %__m, ptr %__m.addr, align 4, !tbaa !14
  %this1 = load ptr, ptr %this.addr, align 8
  call void @llvm.lifetime.start.p0(i64 4, ptr %__b) #9
  %0 = load i32, ptr %__m.addr, align 4, !tbaa !14
  %call = call noundef i32 @_ZStanSt12memory_orderSt23__memory_order_modifier(i32 noundef %0, i32 noundef 65535) #9
  store i32 %call, ptr %__b, align 4, !tbaa !14
  br label %do.body

do.body:                                          ; preds = %entry
  br label %do.cond

do.cond:                                          ; preds = %do.body
  br label %do.end

do.end:                                           ; preds = %do.cond
  br label %do.body2

do.body2:                                         ; preds = %do.end
  br label %do.cond3

do.cond3:                                         ; preds = %do.body2
  br label %do.end4

do.end4:                                          ; preds = %do.cond3
  br label %do.body5

do.body5:                                         ; preds = %do.end4
  br label %do.cond6

do.cond6:                                         ; preds = %do.body5
  br label %do.end7

do.end7:                                          ; preds = %do.cond6
  %_M_i = getelementptr inbounds %"struct.std::__atomic_base", ptr %this1, i32 0, i32 0
  %1 = load i32, ptr %__m.addr, align 4, !tbaa !14
  %2 = load i8, ptr %__i.addr, align 1, !tbaa !12, !range !16, !noundef !17
  %loadedv = trunc i8 %2 to i1
  %storedv8 = zext i1 %loadedv to i8
  store i8 %storedv8, ptr %.atomictmp, align 1, !tbaa !12
  switch i32 %1, label %monotonic [
    i32 3, label %release
    i32 5, label %seqcst
  ]

monotonic:                                        ; preds = %do.end7
  %3 = load i8, ptr %.atomictmp, align 1
  store atomic i8 %3, ptr %_M_i monotonic, align 1
  br label %atomic.continue

release:                                          ; preds = %do.end7
  %4 = load i8, ptr %.atomictmp, align 1
  store atomic i8 %4, ptr %_M_i release, align 1
  br label %atomic.continue

seqcst:                                           ; preds = %do.end7
  %5 = load i8, ptr %.atomictmp, align 1
  store atomic i8 %5, ptr %_M_i seq_cst, align 1
  br label %atomic.continue

atomic.continue:                                  ; preds = %seqcst, %release, %monotonic
  call void @llvm.lifetime.end.p0(i64 4, ptr %__b) #9
  ret void
}

attributes #0 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #3 = { nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { inlinehint mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { mustprogress nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { willreturn memory(argmem: readwrite) }
attributes #8 = { alwaysinline mustprogress nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 19.1.7 (git@github.com:neboat/opencilk-project.git 5190d883dcdd73d55187685cb6013a7c01f3a7a8)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"any pointer", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = distinct !{!9, !10, !11}
!10 = !{!"llvm.loop.mustprogress"}
!11 = !{!"llvm.loop.unroll.disable"}
!12 = !{!13, !13, i64 0}
!13 = !{!"bool", !7, i64 0}
!14 = !{!15, !15, i64 0}
!15 = !{!"_ZTSSt12memory_order", !7, i64 0}
!16 = !{i8 0, i8 2}
!17 = !{}
!18 = !{!19, !19, i64 0}
!19 = !{!"_ZTSSt23__memory_order_modifier", !7, i64 0}
