; Check that function inlining properly splits taskframe intrinsics in the callee.
;
; RUN: opt < %s -inline -S | FileCheck %s

%struct.edgeArray = type <{ %struct.timezone*, i32, i32, i32, [4 x i8] }>
%struct.timezone = type { i32, i32 }

declare i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare dso_local noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #7

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare dso_local void @free(i8* nocapture noundef) local_unnamed_addr #8

define internal fastcc void @_Z12timeMatching9edgeArrayIiEiPc(%struct.edgeArray* %0, i32 %1, i8* %2) personality i32 (...)* @__gxx_personality_v0 {
  br label %4

4:                                                ; preds = %34, %3
  br label %5

5:                                                ; preds = %4
  br label %6

6:                                                ; preds = %5
  br label %7

7:                                                ; preds = %6
  %8 = call token @llvm.taskframe.create()
  %9 = tail call token @llvm.syncregion.start()
  br label %10

10:                                               ; preds = %7
  br label %11

11:                                               ; preds = %10
  br label %12

12:                                               ; preds = %11
  %x = call noalias i8* @malloc(i64 100)
  br label %13

13:                                               ; preds = %16, %12
  detach within none, label %14, label %16

14:                                               ; preds = %13
  br label %15

15:                                               ; preds = %15, %14
  br label %15

16:                                               ; preds = %13
  br i1 true, label %17, label %13

17:                                               ; preds = %16
  br label %18

18:                                               ; preds = %17
  sync within none, label %19

19:                                               ; preds = %18
  br label %20

20:                                               ; preds = %19
  %21 = call token @llvm.taskframe.create()
  br label %22

22:                                               ; preds = %20
  %y = call noalias i8* @malloc(i64 100)
  br label %23

23:                                               ; preds = %22, %26
  detach within none, label %24, label %26

24:                                               ; preds = %23
  br label %25

25:                                               ; preds = %24, %25
  br label %25

26:                                               ; preds = %25
  br i1 true, label %27, label %23

27:                                               ; preds = %26
  br label %28

28:                                               ; preds = %27
  sync within none, label %29

29:                                               ; preds = %28
  br label %30

30:                                               ; preds = %29
  br label %31

31:                                               ; preds = %30
  call void @free(i8* noundef %y)
  call void @llvm.taskframe.end(token %21)
  call void @free(i8* noundef %x)
  br label %32

32:                                               ; preds = %31
  br label %33

33:                                               ; preds = %32
  br label %34

34:                                               ; preds = %33
  br label %4
}

define i32 @main() personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  invoke fastcc void @_Z12timeMatching9edgeArrayIiEiPc(%struct.edgeArray* null, i32 0, i8* null)
          to label %1 unwind label %2

1:                                                ; preds = %0
  ret i32 0

2:                                                ; preds = %0
  %3 = landingpad { i8*, i32 }
          cleanup
  ret i32 0
}

; CHECK: define i32 @main()
; CHECK: br label %[[START:.+]]

; CHECK: [[START]]:
; CHECK: %[[TF1:.+]] = call token @llvm.taskframe.create()
; CHECK: %[[X:.+]] = call noalias i8* @malloc(

; CHECK: %[[TF2:.+]] = call token @llvm.taskframe.create()
; CHECK: %[[Y:.+]] = call noalias i8* @malloc(

; CHECK: call void @free(i8* noundef %[[Y]])
; CHECK: call void @llvm.taskframe.end(token %[[TF2]])
; CHECK-NEXT: br label %[[TFEND:.+]]

; CHECK: [[TFEND]]:
; CHECK: call void @free(i8* noundef %[[X]])
; CHECK: br label %[[START]]

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #4

; uselistorder directives
uselistorder token ()* @llvm.taskframe.create, { 1, 0 }

attributes #0 = { argmemonly nofree nounwind willreturn writeonly }
attributes #1 = { argmemonly nofree nounwind willreturn }
attributes #2 = { argmemonly nofree nosync nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { argmemonly willreturn }
attributes #5 = { nofree nosync nounwind readnone willreturn }
attributes #6 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { inaccessiblememonly mustprogress nofree nounwind willreturn }
attributes #8 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn }
