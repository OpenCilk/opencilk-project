; RUN: opt < %s -passes="function(tsan)" -S | FileCheck %s

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fmuladd.f64(double, double, double) #0

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #3

define void @_Z21walk_bicut_pbc_helperiiP9AtomGraphRSt3mapIiS1_ISt5tupleIJiiiEESt3setIiSt4lessIiESaIiEES5_IS3_ESaISt4pairIKS3_S8_EEES6_SaISA_IKiSE_EEE4cutsRK14base_case_args() personality i32 (...)* undef {
entry:
  %syncreg = call token @llvm.syncregion.start()
  ret void

if.then48.tf:                                     ; No predecessors!
  detach within none, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.then48.tf
  call void @_Z21walk_bicut_pbc_helperiiP9AtomGraphRSt3mapIiS1_ISt5tupleIJiiiEESt3setIiSt4lessIiESaIiEES5_IS3_ESaISt4pairIKS3_S8_EEES6_SaISA_IKiSE_EEE4cutsRK14base_case_args()
  reattach within none, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.then48.tf
  ret void
}

; CHECK: if.then48.tf:
; CHECK-NEXT: detach within none, label %det.achd, label %det.cont unwind label %[[TSAN_CLEANUP:.+]]

; CHECK: det.achd:
; CHECK-NEXT: invoke void @_Z21walk_bicut_pbc_helperiiP9AtomGraphRSt3mapIiS1_ISt5tupleIJiiiEESt3setIiSt4lessIiESaIiEES5_IS3_ESaISt4pairIKS3_S8_EEES6_SaISA_IKiSE_EEE4cutsRK14base_case_args()
; CHECK-NEXT: to label %{{.+}} unwind label %[[TSAN_CLEANUP1:.+]]

; CHECK: [[TSAN_CLEANUP]]:
; CHECK: call void @__tsan_func_exit()
; CHECK-NEXT: resume

; CHECK: [[TSAN_CLEANUP1]]:
; CHECK: invoke void @llvm.detached.rethrow
; CHECK-NEXT: to label %{{.+}} unwind label %[[TSAN_CLEANUP]]

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #2

; Function Attrs: nofree nosync nounwind willreturn
declare i8* @llvm.stacksave() #4

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #0

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #5

; Function Attrs: nounwind
declare i32 @llvm.eh.sjlj.setjmp(i8*) #6

attributes #0 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #1 = { argmemonly nofree nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly willreturn }
attributes #4 = { nofree nosync nounwind willreturn }
attributes #5 = { nofree nosync nounwind readnone willreturn }
attributes #6 = { nounwind }
