; RUN: opt < %s -inline -S -o - | FileCheck %s
; RUN: opt < %s -passes='inline' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC2ESt16initializer_listIS3_E = comdat any

$_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEE16initialize_rangeIPKS3_EEvT_S9_St26random_access_iterator_tag = comdat any

$_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEE16initialize_rangeIPKS4_EEvT_SA_St26random_access_iterator_tagEUlmE_EEvmmSA_mb = comdat any

$_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE16copy_granularityEm = comdat any

$_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEE18initialize_defaultEmEUlmE_EEvmmT_mb = comdat any

declare dso_local i32 @__gxx_personality_v0(...)

define dso_local void @_Z21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPc() local_unnamed_addr #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_ZN6parlay8to_charsEc()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  invoke fastcc void @"_ZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_m"()
          to label %invoke.cont3 unwind label %lpad2

invoke.cont3:                                     ; preds = %invoke.cont
  unreachable

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } undef

lpad2:                                            ; preds = %invoke.cont
  %1 = landingpad { i8*, i32 }
          cleanup
  unreachable
}

declare dso_local void @_ZN6parlay8to_charsEc() local_unnamed_addr #0

declare dso_local void @_ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_() local_unnamed_addr #0

define dso_local fastcc void @"_ZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_m"() unnamed_addr #0 {
entry:
  call fastcc void @"_ZN6parlay8internal8tabulateIZNS_3mapIRKNS_8sequenceISt4pairINS3_IcNS_9allocatorIcEEEEmENS5_IS8_EEEEZ21writeHistogramsToFileSA_PcE3$_1EEDaOT_OT0_mEUlmE_EEDamSG_m"()
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #1

declare dso_local void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl4dataEv() local_unnamed_addr #0 align 2

define dso_local fastcc void @"_ZN6parlay8internal8tabulateIZNS_3mapIRKNS_8sequenceISt4pairINS3_IcNS_9allocatorIcEEEEmENS5_IS8_EEEEZ21writeHistogramsToFileSA_PcE3$_1EEDaOT_OT0_mEUlmE_EEDamSG_m"() unnamed_addr #0 {
entry:
  call fastcc void @"_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEE13from_functionIRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EES5_mSH_m"()
  ret void
}

define dso_local fastcc void @"_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEE13from_functionIRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EES5_mSH_m"() unnamed_addr #0 align 2 {
entry:
  call fastcc void @"_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC2IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEm"()
  ret void
}

define dso_local fastcc void @"_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC2IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEm"() unnamed_addr #0 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  invoke void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl8set_sizeEm()
          to label %invoke.cont3 unwind label %lpad

invoke.cont3:                                     ; preds = %invoke.cont
  invoke void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl4dataEv()
          to label %invoke.cont6 unwind label %lpad5

invoke.cont6:                                     ; preds = %invoke.cont3
  invoke fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb"()
          to label %invoke.cont7 unwind label %lpad5

invoke.cont7:                                     ; preds = %invoke.cont6
  ret void

lpad:                                             ; preds = %invoke.cont, %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } undef

lpad5:                                            ; preds = %invoke.cont6, %invoke.cont3
  %1 = landingpad { i8*, i32 }
          cleanup
  unreachable
}

declare dso_local void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm() local_unnamed_addr #0 align 2

declare dso_local void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl8set_sizeEm() local_unnamed_addr #0 align 2

define dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb"() unnamed_addr #2 {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg19 = call token @llvm.syncregion.start()
  br i1 undef, label %sync.continue23, label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %entry
  detach within %syncreg, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  call fastcc void @"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm"()
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  br label %pfor.cond

sync.continue23:                                  ; preds = %entry
  ret void
}

define dso_local fastcc void @"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm"() unnamed_addr #0 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  call fastcc void @"_ZZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_mENKUlmE_clEm"()
  ret void
}

; CHECK: define dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb"()

; CHECK: pfor.body:
; CHECK: %[[TASKFRAME:.+]] = call token @llvm.taskframe.create()
; CHECK: invoke void @_ZN6parlay8sequenceIcNS_9allocatorIcEEEC2ERKS3_()
; CHECK-NEXT: to label %invoke.cont.i.i unwind label %lpad.i.i

; CHECK: lpad.i.i:
; CHECK: landingpad { i8*, i32 }
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TASKFRAME]], { i8*, i32 } undef)
; CHECK-NEXT: to label %{{.+}} unwind label %lpad.i.i.split

; CHECK: lpad.i.i.split:
; CHECK: %[[LPAD:.+]] = landingpad { i8*, i32 }
; CHECK-NEXT: cleanup
; CHECK-NEXT: invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %[[LPAD]])
; CHECK-NEXT: to label %{{.+}} unwind label %lpad.i.i.split.split

; CHECK: lpad.i.i.split.split:
; CHECK: %[[LPAD2:.+]] = landingpad { i8*, i32 }
; CHECK-NEXT: cleanup
; CHECK-NEXT: resume { i8*, i32 } %[[LPAD2]]

define dso_local fastcc void @"_ZZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_mENKUlmE_clEm"() unnamed_addr #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke fastcc void @"_ZZ21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPcENK3$_1clES5_"()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  ret void

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } %0
}

define dso_local fastcc void @"_ZZ21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPcENK3$_1clES5_"() unnamed_addr #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_ZN6parlay8sequenceIcNS_9allocatorIcEEEC2ERKS3_()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  invoke void @_ZN6parlay8sequenceIcNS_9allocatorIcEEEC2ERKS3_()
          to label %invoke.cont2 unwind label %lpad

invoke.cont2:                                     ; preds = %invoke.cont
  invoke void @_ZN6parlay8to_charsEm()
          to label %invoke.cont4 unwind label %lpad

invoke.cont4:                                     ; preds = %invoke.cont2
  invoke void @_ZN6parlay8sequenceIcNS_9allocatorIcEEEC2ERKS3_()
          to label %invoke.cont6 unwind label %lpad

invoke.cont6:                                     ; preds = %invoke.cont4
  invoke void @_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC2ESt16initializer_listIS3_E()
          to label %invoke.cont9 unwind label %lpad8

invoke.cont9:                                     ; preds = %invoke.cont6
  invoke void @_ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_()
          to label %invoke.cont22 unwind label %lpad21

invoke.cont22:                                    ; preds = %invoke.cont9
  ret void

lpad:                                             ; preds = %invoke.cont2, %entry, %invoke.cont, %invoke.cont4
  %0 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } undef

lpad8:                                            ; preds = %invoke.cont6
  %1 = landingpad { i8*, i32 }
          cleanup
  unreachable

lpad21:                                           ; preds = %invoke.cont9
  %2 = landingpad { i8*, i32 }
          cleanup
  unreachable
}

declare dso_local void @_ZN6parlay8sequenceIcNS_9allocatorIcEEEC2ERKS3_() unnamed_addr #0 align 2

declare dso_local void @_ZN6parlay8to_charsEm() local_unnamed_addr #0

define dso_local void @_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC2ESt16initializer_listIS3_E() unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  invoke void @_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEE16initialize_rangeIPKS3_EEvT_S9_St26random_access_iterator_tag()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  ret void

lpad:                                             ; preds = %entry
  %0 = landingpad { i8*, i32 }
          cleanup
  resume { i8*, i32 } %0
}

define dso_local void @_ZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEE16initialize_rangeIPKS3_EEvT_S9_St26random_access_iterator_tag() local_unnamed_addr #0 comdat align 2 {
entry:
  call void @_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEE16initialize_rangeIPKS4_EEvT_SA_St26random_access_iterator_tagEUlmE_EEvmmSA_mb()
  ret void
}

define dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEE16initialize_rangeIPKS4_EEvT_SA_St26random_access_iterator_tagEUlmE_EEvmmSA_mb() local_unnamed_addr #0 comdat {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg19 = call token @llvm.syncregion.start()
  br label %pfor.cond

pfor.cond:                                        ; preds = %entry
  detach within %syncreg19, label %pfor.body.entry, label %pfor.inc

pfor.body.entry:                                  ; preds = %pfor.cond
  br label %pfor.body

pfor.body:                                        ; preds = %pfor.body.entry
  unreachable

pfor.inc:                                         ; preds = %pfor.cond
  unreachable
}

define dso_local void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE16copy_granularityEm() local_unnamed_addr #0 comdat align 2 {
entry:
  ret void
}

define dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEE18initialize_defaultEmEUlmE_EEvmmT_mb() local_unnamed_addr #0 comdat {
entry:
  %syncreg = call token @llvm.syncregion.start()
  %syncreg19 = call token @llvm.syncregion.start()
  unreachable
}

attributes #0 = { "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "target-cpu"="x86-64" }

!llvm.ident = !{!0}

!0 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git fffc5516029927e6f93460fb66ad35b34f9b0b9b)"}
