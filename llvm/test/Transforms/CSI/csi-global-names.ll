; Check that CSI names the globals it generates, particularly for the
; name of the module.  This resolves an issue in with -flto, which
; expects all global variables to have a proper name.
;
; RUN: opt < %s -passes="csi" -S | FileCheck %s
source_filename = "hello.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@str = private unnamed_addr constant [6 x i8] c"hello\00", align 1

; CHECK: @__csi
; CHECK-NOT: @0
; CHECK: define dso_local i32 @main()

; Function Attrs: nofree nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #0 !dbg !7 {
entry:
  %puts = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @str, i64 0, i64 0)), !dbg !12
  ret i32 0, !dbg !13
}

; Function Attrs: nofree nounwind
declare noundef i32 @puts(i8* nocapture noundef readonly) local_unnamed_addr #1

attributes #0 = { nofree nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git 3199eb59ebe7dbff5db9d6e941c8a0f8ecb6e9c7)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "hello.c", directory: "/home/neboat/bugreports/issue149", checksumkind: CSK_MD5, checksum: "e1657460247ba20794abe54a8eaaddc2")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{i32 7, !"uwtable", i32 1}
!6 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git 3199eb59ebe7dbff5db9d6e941c8a0f8ecb6e9c7)"}
!7 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 3, type: !8, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !11)
!8 = !DISubroutineType(types: !9)
!9 = !{!10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !{}
!12 = !DILocation(line: 4, column: 3, scope: !7)
!13 = !DILocation(line: 5, column: 3, scope: !7)
