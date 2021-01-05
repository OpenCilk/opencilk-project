; RUN: opt < %s -tapir2target -tapir-target=opencilk -opencilk-runtime-bc-path=%S/libopencilk-abi.bc -S -o - | FileCheck %s
; RUN: opt < %s -passes='tapir2target' -tapir-target=opencilk -opencilk-runtime-bc-path=%S/libopencilk-abi.bc -S -o - | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [14 x i8] c"fib(%d) = %d\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @fib(i32 %n) #0 !dbg !7 {
entry:
  %retval = alloca i32, align 4
  %n.addr = alloca i32, align 4
  %x = alloca i32, align 4
  %syncreg = call token @llvm.syncregion.start(), !dbg !11
  %y = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %n.addr, metadata !12, metadata !DIExpression()), !dbg !13
  %0 = load i32, i32* %n.addr, align 4, !dbg !14
  %cmp = icmp slt i32 %0, 2, !dbg !16
  br i1 %cmp, label %if.then, label %if.end, !dbg !17

if.then:                                          ; preds = %entry
  %1 = load i32, i32* %n.addr, align 4, !dbg !18
  store i32 %1, i32* %retval, align 4, !dbg !19
  br label %return, !dbg !19

if.end:                                           ; preds = %entry
  call void @llvm.dbg.declare(metadata i32* %x, metadata !20, metadata !DIExpression()), !dbg !21
  %2 = call token @llvm.taskframe.create(), !dbg !22
  %3 = load i32, i32* %n.addr, align 4, !dbg !23
  %sub = sub nsw i32 %3, 1, !dbg !24
  detach within %syncreg, label %det.achd, label %det.cont, !dbg !22

det.achd:                                         ; preds = %if.end
  call void @llvm.taskframe.use(token %2), !dbg !22
  %call = call i32 @fib(i32 %sub), !dbg !22
  store i32 %call, i32* %x, align 4, !dbg !22
  reattach within %syncreg, label %det.cont, !dbg !22

det.cont:                                         ; preds = %det.achd, %if.end
  call void @llvm.dbg.declare(metadata i32* %y, metadata !25, metadata !DIExpression()), !dbg !26
  %4 = load i32, i32* %n.addr, align 4, !dbg !27
  %sub1 = sub nsw i32 %4, 2, !dbg !28
  %call2 = call i32 @fib(i32 %sub1), !dbg !29
  store i32 %call2, i32* %y, align 4, !dbg !26
  sync within %syncreg, label %sync.continue, !dbg !11

sync.continue:                                    ; preds = %det.cont
  sync within %syncreg, label %sync.continue3, !dbg !30

sync.continue3:                                   ; preds = %sync.continue
  %5 = load i32, i32* %x, align 4, !dbg !31
  %6 = load i32, i32* %y, align 4, !dbg !32
  %add = add nsw i32 %5, %6, !dbg !33
  store i32 %add, i32* %retval, align 4, !dbg !30
  br label %return, !dbg !30

return:                                           ; preds = %sync.continue3, %if.then
  sync within %syncreg, label %sync.continue4, !dbg !34

sync.continue4:                                   ; preds = %return
  %7 = load i32, i32* %retval, align 4, !dbg !34
  ret i32 %7, !dbg !34
}

; CHECK-LABEL: define {{.*}}void @fib.outline_if.end.tf.otd1(
; CHECK: call token @llvm.syncregion.start(), !dbg !{{[0-9]+}}
; CHECK-NEXT: br label %if.end.tf.otd1

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #2

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) #0 !dbg !35 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %n = alloca i32, align 4
  %r = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 %argc, i32* %argc.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %argc.addr, metadata !41, metadata !DIExpression()), !dbg !42
  store i8** %argv, i8*** %argv.addr, align 8
  call void @llvm.dbg.declare(metadata i8*** %argv.addr, metadata !43, metadata !DIExpression()), !dbg !44
  call void @llvm.dbg.declare(metadata i32* %n, metadata !45, metadata !DIExpression()), !dbg !46
  store i32 10, i32* %n, align 4, !dbg !46
  %0 = load i32, i32* %argc.addr, align 4, !dbg !47
  %cmp = icmp sgt i32 %0, 1, !dbg !49
  br i1 %cmp, label %if.then, label %if.end, !dbg !50

if.then:                                          ; preds = %entry
  %1 = load i8**, i8*** %argv.addr, align 8, !dbg !51
  %arrayidx = getelementptr inbounds i8*, i8** %1, i64 1, !dbg !51
  %2 = load i8*, i8** %arrayidx, align 8, !dbg !51
  %call = call i32 @atoi(i8* %2) #5, !dbg !52
  store i32 %call, i32* %n, align 4, !dbg !53
  br label %if.end, !dbg !54

if.end:                                           ; preds = %if.then, %entry
  call void @llvm.dbg.declare(metadata i32* %r, metadata !55, metadata !DIExpression()), !dbg !56
  %3 = load i32, i32* %n, align 4, !dbg !57
  %call1 = call i32 @fib(i32 %3), !dbg !58
  store i32 %call1, i32* %r, align 4, !dbg !56
  %4 = load i32, i32* %n, align 4, !dbg !59
  %5 = load i32, i32* %r, align 4, !dbg !60
  %call2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), i32 %4, i32 %5), !dbg !61
  ret i32 0, !dbg !62
}

; Function Attrs: nounwind readonly
declare dso_local i32 @atoi(i8*) #3

declare dso_local i32 @printf(i8*, ...) #4

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind readonly }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 88928d5f5d9e0cfd092c65c3ed05ec01e8c840c7)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "fib.c", directory: "/data/compilers/tests/adhoc")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 88928d5f5d9e0cfd092c65c3ed05ec01e8c840c7)"}
!7 = distinct !DISubprogram(name: "fib", scope: !1, file: !1, line: 6, type: !8, scopeLine: 6, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !9)
!9 = !{!10, !10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DILocation(line: 12, column: 3, scope: !7)
!12 = !DILocalVariable(name: "n", arg: 1, scope: !7, file: !1, line: 6, type: !10)
!13 = !DILocation(line: 6, column: 13, scope: !7)
!14 = !DILocation(line: 7, column: 7, scope: !15)
!15 = distinct !DILexicalBlock(scope: !7, file: !1, line: 7, column: 7)
!16 = !DILocation(line: 7, column: 9, scope: !15)
!17 = !DILocation(line: 7, column: 7, scope: !7)
!18 = !DILocation(line: 7, column: 21, scope: !15)
!19 = !DILocation(line: 7, column: 14, scope: !15)
!20 = !DILocalVariable(name: "x", scope: !7, file: !1, line: 9, type: !10)
!21 = !DILocation(line: 9, column: 7, scope: !7)
!22 = !DILocation(line: 9, column: 22, scope: !7)
!23 = !DILocation(line: 9, column: 26, scope: !7)
!24 = !DILocation(line: 9, column: 27, scope: !7)
!25 = !DILocalVariable(name: "y", scope: !7, file: !1, line: 10, type: !10)
!26 = !DILocation(line: 10, column: 7, scope: !7)
!27 = !DILocation(line: 10, column: 15, scope: !7)
!28 = !DILocation(line: 10, column: 17, scope: !7)
!29 = !DILocation(line: 10, column: 11, scope: !7)
!30 = !DILocation(line: 13, column: 3, scope: !7)
!31 = !DILocation(line: 13, column: 11, scope: !7)
!32 = !DILocation(line: 13, column: 15, scope: !7)
!33 = !DILocation(line: 13, column: 13, scope: !7)
!34 = !DILocation(line: 14, column: 1, scope: !7)
!35 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 16, type: !36, scopeLine: 16, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!36 = !DISubroutineType(types: !37)
!37 = !{!10, !10, !38}
!38 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !39, size: 64)
!39 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !40, size: 64)
!40 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!41 = !DILocalVariable(name: "argc", arg: 1, scope: !35, file: !1, line: 16, type: !10)
!42 = !DILocation(line: 16, column: 14, scope: !35)
!43 = !DILocalVariable(name: "argv", arg: 2, scope: !35, file: !1, line: 16, type: !38)
!44 = !DILocation(line: 16, column: 26, scope: !35)
!45 = !DILocalVariable(name: "n", scope: !35, file: !1, line: 17, type: !10)
!46 = !DILocation(line: 17, column: 7, scope: !35)
!47 = !DILocation(line: 18, column: 7, scope: !48)
!48 = distinct !DILexicalBlock(scope: !35, file: !1, line: 18, column: 7)
!49 = !DILocation(line: 18, column: 12, scope: !48)
!50 = !DILocation(line: 18, column: 7, scope: !35)
!51 = !DILocation(line: 19, column: 14, scope: !48)
!52 = !DILocation(line: 19, column: 9, scope: !48)
!53 = !DILocation(line: 19, column: 7, scope: !48)
!54 = !DILocation(line: 19, column: 5, scope: !48)
!55 = !DILocalVariable(name: "r", scope: !35, file: !1, line: 21, type: !10)
!56 = !DILocation(line: 21, column: 7, scope: !35)
!57 = !DILocation(line: 21, column: 15, scope: !35)
!58 = !DILocation(line: 21, column: 11, scope: !35)
!59 = !DILocation(line: 22, column: 28, scope: !35)
!60 = !DILocation(line: 22, column: 31, scope: !35)
!61 = !DILocation(line: 22, column: 3, scope: !35)
!62 = !DILocation(line: 23, column: 3, scope: !35)
