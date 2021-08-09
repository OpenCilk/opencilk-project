; RUN: opt < %s -loop-stripmine -require-parallel-epilog -S | FileCheck %s --check-prefixes=CHECK,CHECK-OLD
; RUN: opt < %s -passes='loop-stripmine' -require-parallel-epilog -S | FileCheck %s --check-prefixes=CHECK,CHECK-NEW

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.CFVertexData.23.185.333.483.633.1389.2145.3117.4089.5061.6465.7005.7977.9165.10137.10677.11001.11757.12513.13269.13809.14565.14889.15861.16617.17373.18129.19101.19641.20181.21477.21585.22125.22233.22341.22449.22773.23529.23853.23961.24177.24933.25149.25473.26985.27951.29673.30535.31506.31614.33989.34421.35499.36363.37011.39603.56140 = type { [2 x double] }
%class.CFGlobalInfo.69.230.378.528.678.1434.2190.3162.4134.5106.6510.7050.8022.9210.10182.10722.11046.11802.12558.13314.13854.14610.14934.15906.16662.17418.18174.19146.19686.20226.21522.21630.22170.22278.22386.22494.22818.23574.23898.24006.24222.24978.25194.25518.27030.27996.29718.30580.31551.31659.34034.34466.35544.36408.37056.39648.56141 = type <{ i32, [4 x i8], [4 x double], double, double, i8, [7 x i8], i64, i8*, i32, [4 x i8] }>

$_ZN22GraphBoltEngineComplexI16asymmetricVertex23CFVertexAggregationData12CFVertexData12CFGlobalInfoE12deltaComputeER9edgeArrayS6_ = comdat any

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #0

define dso_local void @_ZN22GraphBoltEngineComplexI16asymmetricVertex23CFVertexAggregationData12CFVertexData12CFGlobalInfoE12deltaComputeER9edgeArrayS6_() unnamed_addr #1 comdat align 2 {
entry:
  %syncreg.i = tail call token @llvm.syncregion.start()
  detach within %syncreg.i, label %pfor.body61, label %pfor.inc182

pfor.body61:                                      ; preds = %entry
  br label %cond.true.i.i

cond.true.i.i:                                    ; preds = %pfor.body61
  unreachable

pfor.inc182:                                      ; preds = %entry
  sync within %syncreg.i, label %sync.continue187

sync.continue187:                                 ; preds = %pfor.inc182
  br label %cleanup190

cleanup190:                                       ; preds = %sync.continue187
  br i1 undef, label %pfor.cond206.preheader, label %cleanup352

pfor.cond206.preheader:                           ; preds = %cleanup190
  detach within %syncreg.i, label %pfor.body212, label %pfor.inc344

pfor.body212:                                     ; preds = %pfor.cond206.preheader
  br label %cond.true.i.i444

cond.true.i.i444:                                 ; preds = %pfor.body212
  unreachable

pfor.inc344:                                      ; preds = %pfor.cond206.preheader
  sync within %syncreg.i, label %sync.continue349

sync.continue349:                                 ; preds = %pfor.inc344
  unreachable

cleanup352:                                       ; preds = %cleanup190
  br label %if.end361

if.end361:                                        ; preds = %cleanup352
  br label %if.end369

if.end369:                                        ; preds = %if.end361
  br i1 undef, label %cleanup427.thread, label %if.then380

if.then380:                                       ; preds = %if.end369
  br label %_ZN5timer4nextEv.exit684

cleanup427.thread:                                ; preds = %if.end369
  br label %cleanup1350

_ZN5timer4nextEv.exit684:                         ; preds = %if.then380
  br i1 undef, label %if.then434, label %if.end492

if.then434:                                       ; preds = %_ZN5timer4nextEv.exit684
  unreachable

if.end492:                                        ; preds = %_ZN5timer4nextEv.exit684
  br label %cleanup843

cleanup843:                                       ; preds = %if.end492
  br label %_ZN5timer4nextEv.exit871

_ZN5timer4nextEv.exit871:                         ; preds = %cleanup843
  br i1 undef, label %cleanup1057, label %pfor.cond864.preheader

pfor.cond864.preheader:                           ; preds = %_ZN5timer4nextEv.exit871
  br i1 undef, label %pfor.cond864.us.preheader, label %pfor.cond864.preheader1564

pfor.cond864.preheader1564:                       ; preds = %pfor.cond864.preheader
  br label %pfor.cond864

; CHECK: pfor.cond864.preheader1564:
; CHECK-NEXT: br i1 {{.+}}, label %pfor.cond.cleanup1052.[[LOOPEXIT:[a-z0-9]+]].strpm-lcssa, label %pfor.cond864.preheader1564.new

; CHECK: pfor.cond864.preheader1564.new:
; CHECK-NEXT: br label %pfor.cond864.preheader1564.new.strpm.detachloop

; CHECK: pfor.cond864.preheader1564.new.strpm.detachloop:
; CHECK-NEXT: detach within %syncreg.i, label %pfor.cond864.strpm.detachloop.entry, label %pfor.cond.cleanup1052.[[LOOPEXIT]].strpm-lcssa.loopexit

pfor.cond864.us.preheader:                        ; preds = %pfor.cond864.preheader
  br label %pfor.cond864.us

; CHECK: pfor.cond864.us.preheader:
; CHECK-NEXT: br i1 {{.+}}, label %pfor.cond.cleanup1052.[[LOOPEXIT_US:[a-z0-9]+]].strpm-lcssa, label %pfor.cond864.us.preheader.new

; CHECK: pfor.cond864.us.preheader.new:
; CHECK-NEXT: br label %pfor.cond864.us.preheader.new.strpm.detachloop

; CHECK: pfor.cond864.us.preheader.new.strpm.detachloop:
; CHECK-NEXT: detach within %syncreg.i, label %pfor.cond864.us.strpm.detachloop.entry, label %pfor.cond.cleanup1052.[[LOOPEXIT_US]].strpm-lcssa.loopexit

; CHECK: pfor.cond864.us.strpm.detachloop.entry:
; CHECK-NEXT: %[[SYNCREG_US_DETLOOP:.+]] = call token @llvm.syncregion.start()
; CHECK-NEXT: br label %pfor.cond864.us.strpm.outer

; CHECK: pfor.cond864.us.strpm.outer:
; CHECK-NEXT: %[[NITER_US:.+]] = phi i64
; CHECK-NEXT: detach within %[[SYNCREG_US_DETLOOP]], label %pfor.body870.us.strpm.outer, label %pfor.inc1049.us.strpm.outer

; CHECK: pfor.body870.us.strpm.outer:
; CHECK-NEXT: %inverse_component_with_lamda.i.us = alloca [4 x double]
; CHECK-NEXT: %inverse_component_final.i.us = alloca [4 x double]
; CHECK-NEXT: %new_value.us = alloca
; CHECK-NEXT: mul i64 {{[0-9]+}}, %[[NITER_US]]
; CHECK-NEXT: br label %pfor.cond864.us

pfor.cond864.us:                                  ; preds = %pfor.inc1049.us, %pfor.cond864.us.preheader
  %indvars.iv1734 = phi i64 [ 0, %pfor.cond864.us.preheader ], [ %indvars.iv.next1735, %pfor.inc1049.us ]
  %indvars.iv.next1735 = add nuw nsw i64 %indvars.iv1734, 1
  detach within %syncreg.i, label %pfor.body870.us, label %pfor.inc1049.us

; CHECK: pfor.cond864.us:
; CHECK-NEXT: %indvars.iv1734 = phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: %indvars.iv.next1735 = add nuw nsw i64 %indvars.iv1734, 1
; CHECK-NOT: detach
; CHECK-NEXT: br label %pfor.body870.us

pfor.body870.us:                                  ; preds = %pfor.cond864.us
  %inverse_component_with_lamda.i.us = alloca [4 x double], align 16
  %inverse_component_final.i.us = alloca [4 x double], align 16
  %new_value.us = alloca %class.CFVertexData.23.185.333.483.633.1389.2145.3117.4089.5061.6465.7005.7977.9165.10137.10677.11001.11757.12513.13269.13809.14565.14889.15861.16617.17373.18129.19101.19641.20181.21477.21585.22125.22233.22341.22449.22773.23529.23853.23961.24177.24933.25149.25473.26985.27951.29673.30535.31506.31614.33989.34421.35499.36363.37011.39603.56140, align 8
  %cmp873.not.us = icmp sgt i64 undef, %indvars.iv1734
  br i1 %cmp873.not.us, label %if.end888.us, label %land.lhs.true874.us

; CHECK: pfor.body870.us:
; CHECK-NOT: alloca
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: br i1 {{.+}}, label %if.end888.us, label %land.lhs.true874.us

land.lhs.true874.us:                              ; preds = %pfor.body870.us
  %0 = load i8*, i8** undef, align 8
  %arrayidx877.us = getelementptr inbounds i8, i8* %0, i64 %indvars.iv1734
  %1 = load i8, i8* %arrayidx877.us, align 1
  %cmp880.us = icmp eq i8 %1, 0
  br label %if.then881.us

if.then881.us:                                    ; preds = %land.lhs.true874.us
  %2 = load %class.CFGlobalInfo.69.230.378.528.678.1434.2190.3162.4134.5106.6510.7050.8022.9210.10182.10722.11046.11802.12558.13314.13854.14610.14934.15906.16662.17418.18174.19146.19686.20226.21522.21630.22170.22278.22386.22494.22818.23574.23898.24006.24222.24978.25194.25518.27030.27996.29718.30580.31551.31659.34034.34466.35544.36408.37056.39648.56141*, %class.CFGlobalInfo.69.230.378.528.678.1434.2190.3162.4134.5106.6510.7050.8022.9210.10182.10722.11046.11802.12558.13314.13854.14610.14934.15906.16662.17418.18174.19146.19686.20226.21522.21630.22170.22278.22386.22494.22818.23574.23898.24006.24222.24978.25194.25518.27030.27996.29718.30580.31551.31659.34034.34466.35544.36408.37056.39648.56141** undef, align 8
  %3 = load i32, i32* undef, align 8
  %cmp.i.i830.us = icmp ult i64 %indvars.iv1734, undef
  br i1 %cmp.i.i830.us, label %cond.true.i.i835.us, label %cond.false.i.i837.us

cond.false.i.i837.us:                             ; preds = %if.then881.us
  %rem.i.i836.us = and i32 undef, 1
  br label %_ZNK12CFGlobalInfo19belongsToPartition1Ej.exit.i840.us

cond.true.i.i835.us:                              ; preds = %if.then881.us
  %4 = load i8*, i8** undef, align 8
  %5 = zext i8 undef to i32
  br label %_ZNK12CFGlobalInfo19belongsToPartition1Ej.exit.i840.us

_ZNK12CFGlobalInfo19belongsToPartition1Ej.exit.i840.us: ; preds = %cond.true.i.i835.us, %cond.false.i.i837.us
  %tobool2.i.not.i839.us = icmp ne i32 undef, 0
  %spec.select = zext i1 %tobool2.i.not.i839.us to i8
  store i8 %spec.select, i8* %arrayidx877.us, align 1
  br label %if.end888.us

if.end888.us:                                     ; preds = %_ZNK12CFGlobalInfo19belongsToPartition1Ej.exit.i840.us, %pfor.body870.us
  %6 = load i8, i8* undef, align 1
  %tobool892.not.us = icmp eq i8 %6, 0
  br i1 %tobool892.not.us, label %pfor.preattach1048.us, label %if.then893

; CHECK: if.end888.us:
; CHECK: br i1 %tobool892.not.us, label %pfor.preattach1048.us, label %if.then893.loopexit

pfor.preattach1048.us:                            ; preds = %if.end888.us
  reattach within %syncreg.i, label %pfor.inc1049.us

; CHECK: pfor.preattach1048.us:
; CHECK-NOT: reattach
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: br label %pfor.inc1049.us

pfor.inc1049.us:                                  ; preds = %pfor.preattach1048.us, %pfor.cond864.us
  %exitcond1737.not = icmp eq i64 %indvars.iv.next1735, undef
  br i1 %exitcond1737.not, label %pfor.cond.cleanup1052, label %pfor.cond864.us

; CHECK: pfor.inc1049.us:
; CHECK: br i1 %{{.+}}, label %[[PFOR_INC1049_US_REATTACH:.+]], label %pfor.cond864.us

; CHECK: [[PFOR_INC1049_US_REATTACH]]:
; CHECK-NEXT: reattach within %[[SYNCREG_US_DETLOOP]], label %pfor.inc1049.us.strpm.outer

; CHECK: pfor.inc1049.us.strpm.outer:
; CHECK-NEXT: add nuw nsw i64 %[[NITER_US]], 1
; CHECK: br i1 {{.+}}, label %pfor.cond864.us.strpm.detachloop.sync, label %pfor.cond864.us.strpm.outer

; CHECK: pfor.cond864.us.strpm.detachloop.sync:
; CHECK: sync within %[[SYNCREG_US_DETLOOP]], label %pfor.cond864.us.strpm.detachloop.reattach.split

; CHECK: pfor.cond864.us.strpm.detachloop.reattach.split:
; CHECK: reattach within %syncreg.i, label %pfor.cond.cleanup1052.[[LOOPEXIT_US]].strpm-lcssa.loopexit


; CHECK: pfor.cond864.strpm.detachloop.entry:
; CHECK-NEXT: %[[SYNCREG_DETLOOP:.+]] = call token @llvm.syncregion.start()
; CHECK-NEXT: br label %pfor.cond864.strpm.outer

; CHECK: pfor.cond864.strpm.outer:
; CHECK-NEXT: %[[NITER:.+]] = phi i64
; CHECK-NEXT: detach within %[[SYNCREG_DETLOOP]], label %pfor.body870.strpm.outer, label %pfor.inc1049.strpm.outer

; CHECK: pfor.body870.strpm.outer:
; CHECK-NEXT: %inverse_component_with_lamda.i = alloca [4 x double]
; CHECK-NEXT: %inverse_component_final.i = alloca [4 x double]
; CHECK-NEXT: %new_value = alloca
; CHECK-NEXT: mul i64 {{[0-9]+}}, %[[NITER]]
; CHECK-NEXT: br label %pfor.cond864

pfor.cond864:                                     ; preds = %pfor.inc1049, %pfor.cond864.preheader1564
  %indvars.iv1730 = phi i64 [ 0, %pfor.cond864.preheader1564 ], [ %indvars.iv.next1731, %pfor.inc1049 ]
  %indvars.iv.next1731 = add nuw nsw i64 %indvars.iv1730, 1
  detach within %syncreg.i, label %pfor.body870, label %pfor.inc1049

; CHECK: pfor.cond864:
; CHECK-NEXT: %indvars.iv1730 = phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: %indvars.iv.next1731 = add nuw nsw i64 %indvars.iv1730, 1
; CHECK-NEXT: br label %pfor.body870

pfor.body870:                                     ; preds = %pfor.cond864
  %inverse_component_with_lamda.i = alloca [4 x double], align 16
  %inverse_component_final.i = alloca [4 x double], align 16
  %new_value = alloca %class.CFVertexData.23.185.333.483.633.1389.2145.3117.4089.5061.6465.7005.7977.9165.10137.10677.11001.11757.12513.13269.13809.14565.14889.15861.16617.17373.18129.19101.19641.20181.21477.21585.22125.22233.22341.22449.22773.23529.23853.23961.24177.24933.25149.25473.26985.27951.29673.30535.31506.31614.33989.34421.35499.36363.37011.39603.56140, align 8
  %cmp873.not = icmp sgt i64 undef, %indvars.iv1730
  br i1 %cmp873.not, label %if.end888, label %land.lhs.true874

; CHECK: pfor.body870:
; CHECK-NOT: alloca
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: br i1 {{.+}}, label %if.end888, label %land.lhs.true874

land.lhs.true874:                                 ; preds = %pfor.body870
  %7 = load i8*, i8** undef, align 8
  %arrayidx877 = getelementptr inbounds i8, i8* %7, i64 %indvars.iv1730
  %8 = load i8, i8* %arrayidx877, align 1
  %cmp880 = icmp eq i8 %8, 0
  %9 = load %class.CFGlobalInfo.69.230.378.528.678.1434.2190.3162.4134.5106.6510.7050.8022.9210.10182.10722.11046.11802.12558.13314.13854.14610.14934.15906.16662.17418.18174.19146.19686.20226.21522.21630.22170.22278.22386.22494.22818.23574.23898.24006.24222.24978.25194.25518.27030.27996.29718.30580.31551.31659.34034.34466.35544.36408.37056.39648.56141*, %class.CFGlobalInfo.69.230.378.528.678.1434.2190.3162.4134.5106.6510.7050.8022.9210.10182.10722.11046.11802.12558.13314.13854.14610.14934.15906.16662.17418.18174.19146.19686.20226.21522.21630.22170.22278.22386.22494.22818.23574.23898.24006.24222.24978.25194.25518.27030.27996.29718.30580.31551.31659.34034.34466.35544.36408.37056.39648.56141** undef, align 8
  br label %land.lhs.true2.i843

land.lhs.true2.i843:                              ; preds = %land.lhs.true874
  %10 = load i32, i32* undef, align 8
  %cmp.i5.i842 = icmp ult i64 %indvars.iv1730, undef
  br i1 %cmp.i5.i842, label %cond.true.i9.i848, label %_ZNK12CFGlobalInfo19belongsToPartition2Ej.exit.i851

cond.true.i9.i848:                                ; preds = %land.lhs.true2.i843
  %11 = load i8*, i8** undef, align 8
  %12 = load i8, i8* undef, align 1
  %tobool.not.i.i847 = icmp eq i8 %12, 0
  br label %_Z30forceComputeVertexForIterationI12CFGlobalInfoEbRKjiRKT_.exit

_ZNK12CFGlobalInfo19belongsToPartition2Ej.exit.i851: ; preds = %land.lhs.true2.i843
  %rem.i10.i8497 = and i64 %indvars.iv1730, 1
  %tobool2.not.i.i850 = icmp eq i64 %rem.i10.i8497, 0
  br label %_Z30forceComputeVertexForIterationI12CFGlobalInfoEbRKjiRKT_.exit

_Z30forceComputeVertexForIterationI12CFGlobalInfoEbRKjiRKT_.exit: ; preds = %_ZNK12CFGlobalInfo19belongsToPartition2Ej.exit.i851, %cond.true.i9.i848
  store i8 1, i8* %arrayidx877, align 1
  br label %if.end888

if.end888:                                        ; preds = %_Z30forceComputeVertexForIterationI12CFGlobalInfoEbRKjiRKT_.exit, %pfor.body870
  %13 = load i8, i8* undef, align 1
  %tobool892.not = icmp eq i8 %13, 0
  br i1 %tobool892.not, label %pfor.preattach1048, label %if.then893.loopexit1565

if.then893.loopexit1565:                          ; preds = %if.end888
  br label %if.then893

; CHECK: if.then893.loopexit1565:
; CHECK-NEXT: br label %{{if.then893|if.then893.strpm}}

; CHECK: if.then893.loopexit:
; CHECK-NEXT: br label %{{if.then893|if.then893.strpm}}

if.then893:                                       ; preds = %if.then893.loopexit1565, %if.end888.us
  switch i32 undef, label %if.end936 [
    i32 0, label %land.lhs.true.i784
    i32 1, label %land.lhs.true2.i795
  ]

land.lhs.true.i784:                               ; preds = %if.then893
  unreachable

land.lhs.true2.i795:                              ; preds = %if.then893
  unreachable

if.end936:                                        ; preds = %if.then893
  br label %for.cond.i767

for.cond.i767:                                    ; preds = %for.cond.i767, %if.end936
  br label %for.cond.i767

pfor.preattach1048:                               ; preds = %if.end888
  reattach within %syncreg.i, label %pfor.inc1049

; CHECK: pfor.preattach1048:
; CHECK-NOT: reattach
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: br label %pfor.inc1049

pfor.inc1049:                                     ; preds = %pfor.preattach1048, %pfor.cond864
  %exitcond1733.not = icmp eq i64 %indvars.iv.next1731, undef
  br i1 %exitcond1733.not, label %pfor.cond.cleanup1052, label %pfor.cond864

; CHECK: pfor.inc1049:
; CHECK: br i1 {{.+}}, label %[[PFOR_INC1049_REATTACH:.+]], label %pfor.cond864

; CHECK: [[PFOR_INC1049_REATTACH]]:
; CHECK-NEXT: reattach within %[[SYNCREG_DETLOOP]], label %pfor.inc1049.strpm.outer

; CHECK: pfor.inc1049.strpm.outer:
; CHECK-NEXT: add nuw nsw i64 %[[NITER]], 1
; CHECK: br i1 {{.+}}, label %pfor.cond864.strpm.detachloop.sync, label %pfor.cond864.strpm.outer

; CHECK: pfor.cond864.strpm.detachloop.sync:
; CHECK-NEXT: sync within %[[SYNCREG_DETLOOP]], label %pfor.cond864.strpm.detachloop.reattach.split

; CHECK: pfor.cond864.strpm.detachloop.reattach.split:
; CHECK-NEXT: reattach within %syncreg.i, label %pfor.cond.cleanup1052.[[LOOPEXIT]].strpm-lcssa.loopexit


; CHECK: pfor.cond.cleanup1052.[[LOOPEXIT_US]].strpm-lcssa.loopexit
; CHECK-NEXT: br label %pfor.cond.cleanup1052.[[LOOPEXIT_US]].strpm-lcssa

; CHECK: pfor.cond.cleanup1052.[[LOOPEXIT_US]].strpm-lcssa
; CHECK-NEXT: br i1 {{.+}}, label %pfor.cond864.us.epil.preheader, label %pfor.cond.cleanup1052.[[LOOPEXIT_US]]

; CHECK: pfor.cond864.us.epil.preheader:
; CHECK-NEXT: br label %pfor.cond864.us.epil

; CHECK: pfor.cond864.us.epil:
; CHECK-NEXT: %indvars.iv1734.epil = phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: %indvars.iv.next1735.epil = add nuw nsw i64 %indvars.iv1734.epil, 1
; CHECK: br label %pfor.body870.us.epil

; CHECK: pfor.body870.us.epil:
; CHECK-NOT: alloca
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: br i1 {{.+}}, label %if.end888.us.epil, label %land.lhs.true874.us.epil

; CHECK: if.end888.us.epil:
; CHECK: br i1 {{.+}}, label %pfor.preattach1048.us.epil, label %if.then893.loopexit.epil

; CHECK: pfor.preattach1048.us.epil:
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: br label %pfor.inc1049.us.epil

; CHECK: pfor.inc1049.us.epil:
; CHECK: br i1 {{.+}}, label %pfor.cond864.us.epil, label %pfor.cond.cleanup1052.[[LOOPEXIT_US]].epilog-lcssa

; CHECK: if.then893.loopexit.epil:
; CHECK-NEXT: br label %if.then893.[[EPIL_US_SHAREDEH:.[a-z0-9.]+]]


; CHECK-NEW: if.then893.epil4:
; CHECK-NEW-NEXT: switch i32 {{.+}}, label %if.end936.epil7 [
; CHECK-NEW-NEXT: i32 0, label %land.lhs.true.i784.epil6
; CHECK-NEW-NEXT: i32 1, label %land.lhs.true2.i795.epil5
; CHECK-NEW-NEXT: ]

; CHECK-NEW: if.end936.epil7:
; CHECK-NEW-NEXT: br label %for.cond.i767.epil8

; CHECK-NEW: for.cond.i767.epil8:
; CHECK-NEW-NEXT: br label %for.cond.i767.epil8

; CHECK-OLD: if.then893.epil:
; CHECK-OLD-NEXT: switch i32 {{.+}}, label %if.end936.epil [
; CHECK-OLD-NEXT: i32 0, label %land.lhs.true.i784.epil
; CHECK-OLD-NEXT: i32 1, label %land.lhs.true2.i795.epil
; CHECK-OLD-NEXT: ]

; CHECK-OLD: if.end936.epil:
; CHECK-OLD-NEXT: br label %for.cond.i767.epil

; CHECK-OLD: for.cond.i767.epil:
; CHECK-OLD-NEXT: br label %for.cond.i767.epil


; CHECK: pfor.cond.cleanup1052.[[LOOPEXIT_US]].epilog-lcssa:
; CHECK-NEXT: br label %pfor.cond.cleanup1052.[[LOOPEXIT_US]]

; CHECK: pfor.cond.cleanup1052.[[LOOPEXIT_US]]:
; CHECK-NEXT: br label %pfor.cond.cleanup1052


; CHECK: pfor.cond.cleanup1052.[[LOOPEXIT]].strpm-lcssa.loopexit:
; CHECK-NEXT: br label %pfor.cond.cleanup1052.[[LOOPEXIT]].strpm-lcssa

; CHECK: pfor.cond.cleanup1052.[[LOOPEXIT]].strpm-lcssa:
; CHECK-NEXT: br i1 {{.+}}, label %pfor.cond864.epil.preheader, label %pfor.cond.cleanup1052.[[LOOPEXIT]]

; CHECK: pfor.cond864.epil.preheader:
; CHECK-NEXT: br label %pfor.cond864.epil

; CHECK: pfor.cond864.epil:
; CHECK-NEXT: %indvars.iv1730.epil = phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: %indvars.iv.next1731.epil = add nuw nsw i64 %indvars.iv1730.epil, 1
; CHECK-NEXT: br label %pfor.body870.epil

; CHECK: pfor.body870.epil:
; CHECK-NOT: alloca
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: call void @llvm.lifetime.start
; CHECK: br i1 {{.+}}, label %if.end888.epil, label %land.lhs.true874.epil

; CHECK: if.end888.epil:
; CHECK: br i1 {{.+}}, label %pfor.preattach1048.epil, label %if.then893.loopexit1565.epil

; CHECK: pfor.preattach1048.epil:
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: call void @llvm.lifetime.end
; CHECK: br label %pfor.inc1049.epil

; CHECK: pfor.inc1049.epil:
; CHECK: br i1 {{.+}}, label %pfor.cond864.epil, label %pfor.cond.cleanup1052.[[LOOPEXIT]].epilog-lcssa

; CHECK: if.then893.loopexit1565.epil:
; CHECK-NEXT: br label %if.then893.[[EPIL_SHAREDEH:.[a-z0-9.]+]]


; CHECK-NEW: if.then893.epil:
; CHECK-NEW-NEXT: switch i32 {{.+}}, label %if.end936.epil [
; CHECK-NEW-NEXT: i32 0, label %land.lhs.true.i784.epil
; CHECK-NEW-NEXT: i32 1, label %land.lhs.true2.i795.epil
; CHECK-NEW-NEXT: ]

; CHECK-NEW: if.end936.epil:
; CHECK-NEW-NEXT: br label %for.cond.i767.epil

; CHECK-NEW: for.cond.i767.epil:
; CHECK-NEW-NEXT: br label %for.cond.i767.epil

; CHECK-OLD: if.then893.epil4:
; CHECK-OLD-NEXT: switch i32 {{.+}}, label %if.end936.epil7 [
; CHECK-OLD-NEXT: i32 0, label %land.lhs.true.i784.epil6
; CHECK-OLD-NEXT: i32 1, label %land.lhs.true2.i795.epil5
; CHECK-OLD-NEXT: ]

; CHECK-OLD: if.end936.epil7:
; CHECK-OLD-NEXT: br label %for.cond.i767.epil8

; CHECK-OLD: for.cond.i767.epil8:
; CHECK-OLD-NEXT: br label %for.cond.i767.epil8


; CHECK: pfor.cond.cleanup1052.[[LOOPEXIT]].epilog-lcssa:
; CHECK-NEXT: br label %pfor.cond.cleanup1052.[[LOOPEXIT]]

; CHECK: pfor.cond.cleanup1052.[[LOOPEXIT]]:
; CHECK-NEXT: br label %pfor.cond.cleanup1052

pfor.cond.cleanup1052:                            ; preds = %pfor.inc1049, %pfor.inc1049.us
  sync within %syncreg.i, label %sync.continue1054

sync.continue1054:                                ; preds = %pfor.cond.cleanup1052
  unreachable

cleanup1057:                                      ; preds = %_ZN5timer4nextEv.exit871
  detach within %syncreg.i, label %pfor.body1080, label %pfor.inc1173

pfor.body1080:                                    ; preds = %cleanup1057
  br label %if.then1101

if.then1101:                                      ; preds = %pfor.body1080
  unreachable

pfor.inc1173:                                     ; preds = %cleanup1057
  sync within %syncreg.i, label %sync.continue1178

sync.continue1178:                                ; preds = %pfor.inc1173
  detach within %syncreg.i, label %pfor.body1203, label %pfor.inc1297

pfor.body1203:                                    ; preds = %sync.continue1178
  br label %if.then1224

if.then1224:                                      ; preds = %pfor.body1203
  unreachable

pfor.inc1297:                                     ; preds = %sync.continue1178
  sync within %syncreg.i, label %sync.continue1302

sync.continue1302:                                ; preds = %pfor.inc1297
  unreachable

cleanup1350:                                      ; preds = %cleanup427.thread
  ret void

; CHECK: if.then893.epil.sd:
; CHECK-NEXT: switch i32 {{.+}}, label %if.end936.epil.sd [
; CHECK-NEXT: i32 0, label %land.lhs.true.i784.epil.sd
; CHECK-NEXT: i32 1, label %land.lhs.true2.i795.epil.sd
; CHECK-NEXT: ]

; CHECK: if.end936.epil.sd:
; CHECK-NEXT: br label %for.cond.i767.epil.sd

; CHECK: for.cond.i767.epil.sd:
; CHECK-NEXT: br label %for.cond.i767.epil.sd

; CHECK: if.then893.strpm:
; CHECK-NEXT: switch i32 {{.+}}, label %if.end936.strpm [
; CHECK-NEXT: i32 0, label %land.lhs.true.i784.strpm
; CHECK-NEXT: i32 1, label %land.lhs.true2.i795.strpm
; CHECK-NEXT: ]

; CHECK: if.end936.strpm:
; CHECK-NEXT: br label %for.cond.i767.strpm

; CHECK: for.cond.i767.strpm:
; CHECK-NEXT: br label %for.cond.i767.strpm
}

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 12.0.0 (git@github.com:OpenCilk/opencilk-project.git 31ad596bd7126d79fa36fd82538084e8a8f4d913)"}
