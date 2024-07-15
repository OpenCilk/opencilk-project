; Check that the OpenCilk back end marks the spawner with the correct memory effects.
;
; RUN: opt < %s -passes="tapir-lowering<O2>" -tapir-target=opencilk -use-opencilk-runtime-bc=false -debug-abi-calls -S | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.syncregion.start() #0

; Function Attrs: mustprogress
define ptr @_Z12generateNodePP5rangePP5eventS0_ii(ptr noundef %boxes, ptr noundef readonly %events, ptr %B, i32 %n, i32 %maxDepth) #1 personality ptr null {
entry:
  %syncreg = tail call token @llvm.syncregion.start()
  %leftEvents = alloca [3 x ptr], align 16
  %0 = tail call token @llvm.taskframe.create()
  store i32 0, ptr %events, align 4
  %1 = load ptr, ptr %boxes, align 16
  store ptr %1, ptr %leftEvents, align 16
  detach within %syncreg, label %det.achd190, label %det.cont192

det.achd190:                                      ; preds = %entry
  %call191 = call noundef ptr @_Z12generateNodePP5rangePP5eventS0_ii(ptr noundef %boxes, ptr noundef nonnull %leftEvents, ptr null, i32 0, i32 0)
  reattach within %syncreg, label %det.cont192

det.cont192:                                      ; preds = %det.achd190, %entry
  ret ptr null
}

; CHECK-LABEL: define {{.*}}ptr @_Z12generateNodePP5rangePP5eventS0_ii(
; CHECK: #[[SPAWNER_ATTRS:[0-9]+]]
; CHECK: %leftEvents = alloca [3 x ptr]
; CHECK: store ptr %{{.+}}, ptr %leftEvents
; CHECK: call fastcc void @_Z12generateNodePP5rangePP5eventS0_ii.outline_det.achd190.otd1(ptr nonnull %boxes, ptr nonnull %leftEvents

; CHECK: define internal fastcc void @_Z12generateNodePP5rangePP5eventS0_ii.outline_det.achd190.otd1(ptr {{.*}}%boxes.otd1, ptr
; CHECK-NOT: readnone
; CHECK: %leftEvents.otd1

; Function Attrs: nounwind willreturn memory(argmem: readwrite)
declare token @llvm.taskframe.create() #0

; uselistorder directives
uselistorder ptr null, { 1, 2, 3, 4, 0 }

attributes #0 = { nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { mustprogress }

; CHECK: attributes #[[SPAWNER_ATTRS]] = {
; CHECK-NOT: argmem: none
; CHECK: }
