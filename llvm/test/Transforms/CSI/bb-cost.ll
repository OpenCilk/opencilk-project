; RUN: opt < %s -csi -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.timespec = type { i64, i64 }

@.str = private unnamed_addr constant [14 x i8] c"fib(%d) = %d\0A\00", align 1
@.str.1 = private unnamed_addr constant [11 x i8] c"Time = %f\0A\00", align 1

; CHECK: @__csi_unit_size_tables = internal global [1 x { i64, { i32, i32 }* }] [{ i64, { i32, i32 }* } { i64 44, { i32, i32 }* getelementptr inbounds ([44 x { i32, i32 }], [44 x { i32, i32 }]* @__csi_unit_size_table, i32 0, i32 0) }]

; Function Attrs: alwaysinline nounwind uwtable
define dso_local i32 @fib_base(i32 %n) #0 !dbg !7 {
entry:
  %retval = alloca i32, align 4
  %n.addr = alloca i32, align 4
  %x0 = alloca i32, align 4
  %x1 = alloca i32, align 4
  %i = alloca i32, align 4
  %tmp = alloca i32, align 4
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
  call void @llvm.dbg.declare(metadata i32* %x0, metadata !20, metadata !DIExpression()), !dbg !21
  store i32 0, i32* %x0, align 4, !dbg !21
  call void @llvm.dbg.declare(metadata i32* %x1, metadata !22, metadata !DIExpression()), !dbg !23
  store i32 1, i32* %x1, align 4, !dbg !23
  call void @llvm.dbg.declare(metadata i32* %i, metadata !24, metadata !DIExpression()), !dbg !26
  store i32 2, i32* %i, align 4, !dbg !26
  br label %for.cond, !dbg !27

for.cond:                                         ; preds = %for.inc, %if.end
  %2 = load i32, i32* %i, align 4, !dbg !28
  %3 = load i32, i32* %n.addr, align 4, !dbg !30
  %cmp1 = icmp slt i32 %2, %3, !dbg !31
  br i1 %cmp1, label %for.body, label %for.end, !dbg !32

for.body:                                         ; preds = %for.cond
  call void @llvm.dbg.declare(metadata i32* %tmp, metadata !33, metadata !DIExpression()), !dbg !35
  %4 = load i32, i32* %x0, align 4, !dbg !36
  store i32 %4, i32* %tmp, align 4, !dbg !35
  %5 = load i32, i32* %x1, align 4, !dbg !37
  store i32 %5, i32* %x0, align 4, !dbg !38
  %6 = load i32, i32* %tmp, align 4, !dbg !39
  %7 = load i32, i32* %x1, align 4, !dbg !40
  %add = add nsw i32 %7, %6, !dbg !40
  store i32 %add, i32* %x1, align 4, !dbg !40
  br label %for.inc, !dbg !41

for.inc:                                          ; preds = %for.body
  %8 = load i32, i32* %i, align 4, !dbg !42
  %inc = add nsw i32 %8, 1, !dbg !42
  store i32 %inc, i32* %i, align 4, !dbg !42
  br label %for.cond, !dbg !43, !llvm.loop !44

for.end:                                          ; preds = %for.cond
  %9 = load i32, i32* %x0, align 4, !dbg !46
  %10 = load i32, i32* %x1, align 4, !dbg !47
  %add2 = add nsw i32 %9, %10, !dbg !48
  store i32 %add2, i32* %retval, align 4, !dbg !49
  br label %return, !dbg !49

return:                                           ; preds = %for.end, %if.then
  %11 = load i32, i32* %retval, align 4, !dbg !50
  ret i32 %11, !dbg !50
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @fib(i32 %n, i32 %base) #2 !dbg !51 {
entry:
  %retval.i = alloca i32, align 4
  %n.addr.i = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %n.addr.i, metadata !12, metadata !DIExpression()), !dbg !54
  %x0.i = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %x0.i, metadata !20, metadata !DIExpression()), !dbg !57
  %x1.i = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %x1.i, metadata !22, metadata !DIExpression()), !dbg !58
  %i.i = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %i.i, metadata !24, metadata !DIExpression()), !dbg !59
  %tmp.i = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %tmp.i, metadata !33, metadata !DIExpression()), !dbg !60
  %retval = alloca i32, align 4
  %n.addr = alloca i32, align 4
  %base.addr = alloca i32, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %n.addr, metadata !61, metadata !DIExpression()), !dbg !62
  store i32 %base, i32* %base.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %base.addr, metadata !63, metadata !DIExpression()), !dbg !64
  %0 = load i32, i32* %n.addr, align 4, !dbg !65
  %1 = load i32, i32* %base.addr, align 4, !dbg !66
  %cmp = icmp slt i32 %0, %1, !dbg !67
  br i1 %cmp, label %if.then, label %if.end, !dbg !68

if.then:                                          ; preds = %entry
  %2 = load i32, i32* %n.addr, align 4, !dbg !69
  store i32 %2, i32* %n.addr.i, align 4
  %3 = load i32, i32* %n.addr.i, align 4, !dbg !70
  %cmp.i = icmp slt i32 %3, 2, !dbg !71
  br i1 %cmp.i, label %if.then.i, label %if.end.i, !dbg !72

if.then.i:                                        ; preds = %if.then
  %4 = load i32, i32* %n.addr.i, align 4, !dbg !73
  store i32 %4, i32* %retval.i, align 4, !dbg !74
  br label %fib_base.exit, !dbg !74

if.end.i:                                         ; preds = %if.then
  store i32 0, i32* %x0.i, align 4, !dbg !57
  store i32 1, i32* %x1.i, align 4, !dbg !58
  store i32 2, i32* %i.i, align 4, !dbg !59
  br label %for.cond.i, !dbg !75

for.cond.i:                                       ; preds = %for.body.i, %if.end.i
  %5 = load i32, i32* %i.i, align 4, !dbg !76
  %6 = load i32, i32* %n.addr.i, align 4, !dbg !77
  %cmp1.i = icmp slt i32 %5, %6, !dbg !78
  br i1 %cmp1.i, label %for.body.i, label %for.end.i, !dbg !79

for.body.i:                                       ; preds = %for.cond.i
  %7 = load i32, i32* %x0.i, align 4, !dbg !80
  store i32 %7, i32* %tmp.i, align 4, !dbg !60
  %8 = load i32, i32* %x1.i, align 4, !dbg !81
  store i32 %8, i32* %x0.i, align 4, !dbg !82
  %9 = load i32, i32* %tmp.i, align 4, !dbg !83
  %10 = load i32, i32* %x1.i, align 4, !dbg !84
  %add.i = add nsw i32 %10, %9, !dbg !84
  store i32 %add.i, i32* %x1.i, align 4, !dbg !84
  %11 = load i32, i32* %i.i, align 4, !dbg !85
  %inc.i = add nsw i32 %11, 1, !dbg !85
  store i32 %inc.i, i32* %i.i, align 4, !dbg !85
  br label %for.cond.i, !dbg !86, !llvm.loop !87

for.end.i:                                        ; preds = %for.cond.i
  %12 = load i32, i32* %x0.i, align 4, !dbg !89
  %13 = load i32, i32* %x1.i, align 4, !dbg !90
  %add2.i = add nsw i32 %12, %13, !dbg !91
  store i32 %add2.i, i32* %retval.i, align 4, !dbg !92
  br label %fib_base.exit, !dbg !92

fib_base.exit:                                    ; preds = %if.then.i, %for.end.i
  %14 = load i32, i32* %retval.i, align 4, !dbg !93
  store i32 %14, i32* %retval, align 4, !dbg !94
  br label %return, !dbg !94

if.end:                                           ; preds = %entry
  call void @llvm.dbg.declare(metadata i32* %x, metadata !95, metadata !DIExpression()), !dbg !96
  call void @llvm.dbg.declare(metadata i32* %y, metadata !97, metadata !DIExpression()), !dbg !98
  %15 = load i32, i32* %n.addr, align 4, !dbg !99
  %sub = sub nsw i32 %15, 1, !dbg !100
  %16 = load i32, i32* %base.addr, align 4, !dbg !101
  %call1 = call i32 @fib(i32 %sub, i32 %16), !dbg !102
  store i32 %call1, i32* %x, align 4, !dbg !103
  %17 = load i32, i32* %n.addr, align 4, !dbg !104
  %sub2 = sub nsw i32 %17, 2, !dbg !105
  %18 = load i32, i32* %base.addr, align 4, !dbg !106
  %call3 = call i32 @fib(i32 %sub2, i32 %18), !dbg !107
  store i32 %call3, i32* %y, align 4, !dbg !108
  %19 = load i32, i32* %x, align 4, !dbg !109
  %20 = load i32, i32* %y, align 4, !dbg !110
  %add = add nsw i32 %19, %20, !dbg !111
  store i32 %add, i32* %retval, align 4, !dbg !112
  br label %return, !dbg !112

return:                                           ; preds = %if.end, %fib_base.exit
  %21 = load i32, i32* %retval, align 4, !dbg !113
  ret i32 %21, !dbg !113
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) #2 !dbg !114 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %n = alloca i32, align 4
  %base = alloca i32, align 4
  %best_time = alloca double, align 8
  %r = alloca i32, align 4
  %i = alloca i32, align 4
  %init = alloca %struct.timespec, align 8
  %end = alloca %struct.timespec, align 8
  %timediff = alloca double, align 8
  store i32 0, i32* %retval, align 4
  store i32 %argc, i32* %argc.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %argc.addr, metadata !120, metadata !DIExpression()), !dbg !121
  store i8** %argv, i8*** %argv.addr, align 8
  call void @llvm.dbg.declare(metadata i8*** %argv.addr, metadata !122, metadata !DIExpression()), !dbg !123
  call void @llvm.dbg.declare(metadata i32* %n, metadata !124, metadata !DIExpression()), !dbg !125
  store i32 35, i32* %n, align 4, !dbg !125
  call void @llvm.dbg.declare(metadata i32* %base, metadata !126, metadata !DIExpression()), !dbg !127
  store i32 2, i32* %base, align 4, !dbg !127
  %0 = load i32, i32* %argc.addr, align 4, !dbg !128
  %cmp = icmp sgt i32 %0, 1, !dbg !130
  br i1 %cmp, label %if.then, label %if.end, !dbg !131

if.then:                                          ; preds = %entry
  %1 = load i8**, i8*** %argv.addr, align 8, !dbg !132
  %arrayidx = getelementptr inbounds i8*, i8** %1, i64 1, !dbg !132
  %2 = load i8*, i8** %arrayidx, align 8, !dbg !132
  %call = call i32 @atoi(i8* %2) #6, !dbg !133
  store i32 %call, i32* %n, align 4, !dbg !134
  br label %if.end, !dbg !135

if.end:                                           ; preds = %if.then, %entry
  %3 = load i32, i32* %argc.addr, align 4, !dbg !136
  %cmp1 = icmp sgt i32 %3, 2, !dbg !138
  br i1 %cmp1, label %if.then2, label %if.end5, !dbg !139

if.then2:                                         ; preds = %if.end
  %4 = load i8**, i8*** %argv.addr, align 8, !dbg !140
  %arrayidx3 = getelementptr inbounds i8*, i8** %4, i64 2, !dbg !140
  %5 = load i8*, i8** %arrayidx3, align 8, !dbg !140
  %call4 = call i32 @atoi(i8* %5) #6, !dbg !141
  store i32 %call4, i32* %base, align 4, !dbg !142
  br label %if.end5, !dbg !143

if.end5:                                          ; preds = %if.then2, %if.end
  call void @llvm.dbg.declare(metadata double* %best_time, metadata !144, metadata !DIExpression()), !dbg !146
  store double 1.000000e+07, double* %best_time, align 8, !dbg !146
  call void @llvm.dbg.declare(metadata i32* %r, metadata !147, metadata !DIExpression()), !dbg !148
  call void @llvm.dbg.declare(metadata i32* %i, metadata !149, metadata !DIExpression()), !dbg !151
  store i32 0, i32* %i, align 4, !dbg !151
  br label %for.cond, !dbg !152

for.cond:                                         ; preds = %for.inc, %if.end5
  %6 = load i32, i32* %i, align 4, !dbg !153
  %cmp6 = icmp slt i32 %6, 100, !dbg !155
  br i1 %cmp6, label %for.body, label %for.end, !dbg !156

for.body:                                         ; preds = %for.cond
  call void @llvm.dbg.declare(metadata %struct.timespec* %init, metadata !157, metadata !DIExpression()), !dbg !170
  %call7 = call { i64, i64 } @gettime(), !dbg !171
  %7 = bitcast %struct.timespec* %init to { i64, i64 }*, !dbg !171
  %8 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %7, i32 0, i32 0, !dbg !171
  %9 = extractvalue { i64, i64 } %call7, 0, !dbg !171
  store i64 %9, i64* %8, align 8, !dbg !171
  %10 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %7, i32 0, i32 1, !dbg !171
  %11 = extractvalue { i64, i64 } %call7, 1, !dbg !171
  store i64 %11, i64* %10, align 8, !dbg !171
  %12 = load i32, i32* %n, align 4, !dbg !172
  %13 = load i32, i32* %base, align 4, !dbg !173
  %call8 = call i32 @fib(i32 %12, i32 %13), !dbg !174
  store i32 %call8, i32* %r, align 4, !dbg !175
  call void @llvm.dbg.declare(metadata %struct.timespec* %end, metadata !176, metadata !DIExpression()), !dbg !177
  %call9 = call { i64, i64 } @gettime(), !dbg !178
  %14 = bitcast %struct.timespec* %end to { i64, i64 }*, !dbg !178
  %15 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %14, i32 0, i32 0, !dbg !178
  %16 = extractvalue { i64, i64 } %call9, 0, !dbg !178
  store i64 %16, i64* %15, align 8, !dbg !178
  %17 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %14, i32 0, i32 1, !dbg !178
  %18 = extractvalue { i64, i64 } %call9, 1, !dbg !178
  store i64 %18, i64* %17, align 8, !dbg !178
  call void @llvm.dbg.declare(metadata double* %timediff, metadata !179, metadata !DIExpression()), !dbg !180
  %19 = bitcast %struct.timespec* %init to { i64, i64 }*, !dbg !181
  %20 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %19, i32 0, i32 0, !dbg !181
  %21 = load i64, i64* %20, align 8, !dbg !181
  %22 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %19, i32 0, i32 1, !dbg !181
  %23 = load i64, i64* %22, align 8, !dbg !181
  %24 = bitcast %struct.timespec* %end to { i64, i64 }*, !dbg !181
  %25 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %24, i32 0, i32 0, !dbg !181
  %26 = load i64, i64* %25, align 8, !dbg !181
  %27 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %24, i32 0, i32 1, !dbg !181
  %28 = load i64, i64* %27, align 8, !dbg !181
  %call10 = call double @tdiff_sec(i64 %21, i64 %23, i64 %26, i64 %28), !dbg !181
  store double %call10, double* %timediff, align 8, !dbg !180
  %29 = load double, double* %timediff, align 8, !dbg !182
  %30 = load double, double* %best_time, align 8, !dbg !183
  %cmp11 = fcmp olt double %29, %30, !dbg !184
  br i1 %cmp11, label %cond.true, label %cond.false, !dbg !185

cond.true:                                        ; preds = %for.body
  %31 = load double, double* %timediff, align 8, !dbg !186
  br label %cond.end, !dbg !185

cond.false:                                       ; preds = %for.body
  %32 = load double, double* %best_time, align 8, !dbg !187
  br label %cond.end, !dbg !185

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi double [ %31, %cond.true ], [ %32, %cond.false ], !dbg !185
  store double %cond, double* %best_time, align 8, !dbg !188
  br label %for.inc, !dbg !189

for.inc:                                          ; preds = %cond.end
  %33 = load i32, i32* %i, align 4, !dbg !190
  %inc = add nsw i32 %33, 1, !dbg !190
  store i32 %inc, i32* %i, align 4, !dbg !190
  br label %for.cond, !dbg !191, !llvm.loop !192

for.end:                                          ; preds = %for.cond
  %34 = load i32, i32* %n, align 4, !dbg !194
  %35 = load i32, i32* %r, align 4, !dbg !195
  %call12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), i32 %34, i32 %35), !dbg !196
  %36 = load double, double* %best_time, align 8, !dbg !197
  %call13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.1, i64 0, i64 0), double %36), !dbg !198
  ret i32 0, !dbg !199
}

; Function Attrs: nounwind readonly
declare dso_local i32 @atoi(i8*) #3

; Function Attrs: noinline nounwind optnone uwtable
define internal { i64, i64 } @gettime() #2 !dbg !200 {
entry:
  %retval = alloca %struct.timespec, align 8
  %r = alloca i32, align 4
  call void @llvm.dbg.declare(metadata %struct.timespec* %retval, metadata !203, metadata !DIExpression()), !dbg !204
  call void @llvm.dbg.declare(metadata i32* %r, metadata !205, metadata !DIExpression()), !dbg !206
  %call = call i32 @clock_gettime(i32 1, %struct.timespec* %retval) #7, !dbg !207
  store i32 %call, i32* %r, align 4, !dbg !208
  %0 = bitcast %struct.timespec* %retval to { i64, i64 }*, !dbg !209
  %1 = load { i64, i64 }, { i64, i64 }* %0, align 8, !dbg !209
  ret { i64, i64 } %1, !dbg !209
}

; Function Attrs: noinline nounwind optnone uwtable
define internal double @tdiff_sec(i64 %start.coerce0, i64 %start.coerce1, i64 %stop.coerce0, i64 %stop.coerce1) #2 !dbg !210 {
entry:
  %start = alloca %struct.timespec, align 8
  %stop = alloca %struct.timespec, align 8
  %0 = bitcast %struct.timespec* %start to { i64, i64 }*
  %1 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %0, i32 0, i32 0
  store i64 %start.coerce0, i64* %1, align 8
  %2 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %0, i32 0, i32 1
  store i64 %start.coerce1, i64* %2, align 8
  %3 = bitcast %struct.timespec* %stop to { i64, i64 }*
  %4 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %3, i32 0, i32 0
  store i64 %stop.coerce0, i64* %4, align 8
  %5 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %3, i32 0, i32 1
  store i64 %stop.coerce1, i64* %5, align 8
  call void @llvm.dbg.declare(metadata %struct.timespec* %start, metadata !214, metadata !DIExpression()), !dbg !215
  call void @llvm.dbg.declare(metadata %struct.timespec* %stop, metadata !216, metadata !DIExpression()), !dbg !217
  %tv_sec = getelementptr inbounds %struct.timespec, %struct.timespec* %stop, i32 0, i32 0, !dbg !218
  %6 = load i64, i64* %tv_sec, align 8, !dbg !218
  %tv_sec1 = getelementptr inbounds %struct.timespec, %struct.timespec* %start, i32 0, i32 0, !dbg !219
  %7 = load i64, i64* %tv_sec1, align 8, !dbg !219
  %sub = sub nsw i64 %6, %7, !dbg !220
  %conv = sitofp i64 %sub to double, !dbg !221
  %tv_nsec = getelementptr inbounds %struct.timespec, %struct.timespec* %stop, i32 0, i32 1, !dbg !222
  %8 = load i64, i64* %tv_nsec, align 8, !dbg !222
  %tv_nsec2 = getelementptr inbounds %struct.timespec, %struct.timespec* %start, i32 0, i32 1, !dbg !223
  %9 = load i64, i64* %tv_nsec2, align 8, !dbg !223
  %sub3 = sub nsw i64 %8, %9, !dbg !224
  %conv4 = sitofp i64 %sub3 to double, !dbg !225
  %mul = fmul double 1.000000e-09, %conv4, !dbg !226
  %add = fadd double %conv, %mul, !dbg !227
  ret double %add, !dbg !228
}

declare dso_local i32 @printf(i8*, ...) #4

; Function Attrs: nounwind
declare dso_local i32 @clock_gettime(i32, %struct.timespec*) #5

attributes #0 = { alwaysinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind readonly }
attributes #7 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git af592c078a4129622f80fbbe0288dc984e63ff40)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "fib_serial-406081.c", directory: "/data/compilers/tests/6172F20/homework6")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git af592c078a4129622f80fbbe0288dc984e63ff40)"}
!7 = distinct !DISubprogram(name: "fib_base", scope: !8, file: !8, line: 10, type: !9, scopeLine: 10, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!8 = !DIFile(filename: "fib_serial.c", directory: "/data/compilers/tests/6172F20/homework6")
!9 = !DISubroutineType(types: !10)
!10 = !{!11, !11}
!11 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!12 = !DILocalVariable(name: "n", arg: 1, scope: !7, file: !8, line: 10, type: !11)
!13 = !DILocation(line: 10, column: 18, scope: !7)
!14 = !DILocation(line: 11, column: 7, scope: !15)
!15 = distinct !DILexicalBlock(scope: !7, file: !8, line: 11, column: 7)
!16 = !DILocation(line: 11, column: 9, scope: !15)
!17 = !DILocation(line: 11, column: 7, scope: !7)
!18 = !DILocation(line: 11, column: 21, scope: !15)
!19 = !DILocation(line: 11, column: 14, scope: !15)
!20 = !DILocalVariable(name: "x0", scope: !7, file: !8, line: 12, type: !11)
!21 = !DILocation(line: 12, column: 7, scope: !7)
!22 = !DILocalVariable(name: "x1", scope: !7, file: !8, line: 12, type: !11)
!23 = !DILocation(line: 12, column: 15, scope: !7)
!24 = !DILocalVariable(name: "i", scope: !25, file: !8, line: 13, type: !11)
!25 = distinct !DILexicalBlock(scope: !7, file: !8, line: 13, column: 3)
!26 = !DILocation(line: 13, column: 12, scope: !25)
!27 = !DILocation(line: 13, column: 8, scope: !25)
!28 = !DILocation(line: 13, column: 19, scope: !29)
!29 = distinct !DILexicalBlock(scope: !25, file: !8, line: 13, column: 3)
!30 = !DILocation(line: 13, column: 23, scope: !29)
!31 = !DILocation(line: 13, column: 21, scope: !29)
!32 = !DILocation(line: 13, column: 3, scope: !25)
!33 = !DILocalVariable(name: "tmp", scope: !34, file: !8, line: 14, type: !11)
!34 = distinct !DILexicalBlock(scope: !29, file: !8, line: 13, column: 31)
!35 = !DILocation(line: 14, column: 9, scope: !34)
!36 = !DILocation(line: 14, column: 15, scope: !34)
!37 = !DILocation(line: 15, column: 10, scope: !34)
!38 = !DILocation(line: 15, column: 8, scope: !34)
!39 = !DILocation(line: 16, column: 11, scope: !34)
!40 = !DILocation(line: 16, column: 8, scope: !34)
!41 = !DILocation(line: 17, column: 3, scope: !34)
!42 = !DILocation(line: 13, column: 26, scope: !29)
!43 = !DILocation(line: 13, column: 3, scope: !29)
!44 = distinct !{!44, !32, !45}
!45 = !DILocation(line: 17, column: 3, scope: !25)
!46 = !DILocation(line: 18, column: 10, scope: !7)
!47 = !DILocation(line: 18, column: 15, scope: !7)
!48 = !DILocation(line: 18, column: 13, scope: !7)
!49 = !DILocation(line: 18, column: 3, scope: !7)
!50 = !DILocation(line: 19, column: 1, scope: !7)
!51 = distinct !DISubprogram(name: "fib", scope: !8, file: !8, line: 24, type: !52, scopeLine: 24, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!52 = !DISubroutineType(types: !53)
!53 = !{!11, !11, !11}
!54 = !DILocation(line: 10, column: 18, scope: !7, inlinedAt: !55)
!55 = distinct !DILocation(line: 25, column: 24, scope: !56)
!56 = distinct !DILexicalBlock(scope: !51, file: !8, line: 25, column: 7)
!57 = !DILocation(line: 12, column: 7, scope: !7, inlinedAt: !55)
!58 = !DILocation(line: 12, column: 15, scope: !7, inlinedAt: !55)
!59 = !DILocation(line: 13, column: 12, scope: !25, inlinedAt: !55)
!60 = !DILocation(line: 14, column: 9, scope: !34, inlinedAt: !55)
!61 = !DILocalVariable(name: "n", arg: 1, scope: !51, file: !8, line: 24, type: !11)
!62 = !DILocation(line: 24, column: 13, scope: !51)
!63 = !DILocalVariable(name: "base", arg: 2, scope: !51, file: !8, line: 24, type: !11)
!64 = !DILocation(line: 24, column: 20, scope: !51)
!65 = !DILocation(line: 25, column: 7, scope: !56)
!66 = !DILocation(line: 25, column: 11, scope: !56)
!67 = !DILocation(line: 25, column: 9, scope: !56)
!68 = !DILocation(line: 25, column: 7, scope: !51)
!69 = !DILocation(line: 25, column: 33, scope: !56)
!70 = !DILocation(line: 11, column: 7, scope: !15, inlinedAt: !55)
!71 = !DILocation(line: 11, column: 9, scope: !15, inlinedAt: !55)
!72 = !DILocation(line: 11, column: 7, scope: !7, inlinedAt: !55)
!73 = !DILocation(line: 11, column: 21, scope: !15, inlinedAt: !55)
!74 = !DILocation(line: 11, column: 14, scope: !15, inlinedAt: !55)
!75 = !DILocation(line: 13, column: 8, scope: !25, inlinedAt: !55)
!76 = !DILocation(line: 13, column: 19, scope: !29, inlinedAt: !55)
!77 = !DILocation(line: 13, column: 23, scope: !29, inlinedAt: !55)
!78 = !DILocation(line: 13, column: 21, scope: !29, inlinedAt: !55)
!79 = !DILocation(line: 13, column: 3, scope: !25, inlinedAt: !55)
!80 = !DILocation(line: 14, column: 15, scope: !34, inlinedAt: !55)
!81 = !DILocation(line: 15, column: 10, scope: !34, inlinedAt: !55)
!82 = !DILocation(line: 15, column: 8, scope: !34, inlinedAt: !55)
!83 = !DILocation(line: 16, column: 11, scope: !34, inlinedAt: !55)
!84 = !DILocation(line: 16, column: 8, scope: !34, inlinedAt: !55)
!85 = !DILocation(line: 13, column: 26, scope: !29, inlinedAt: !55)
!86 = !DILocation(line: 13, column: 3, scope: !29, inlinedAt: !55)
!87 = distinct !{!87, !79, !88}
!88 = !DILocation(line: 17, column: 3, scope: !25, inlinedAt: !55)
!89 = !DILocation(line: 18, column: 10, scope: !7, inlinedAt: !55)
!90 = !DILocation(line: 18, column: 15, scope: !7, inlinedAt: !55)
!91 = !DILocation(line: 18, column: 13, scope: !7, inlinedAt: !55)
!92 = !DILocation(line: 18, column: 3, scope: !7, inlinedAt: !55)
!93 = !DILocation(line: 19, column: 1, scope: !7, inlinedAt: !55)
!94 = !DILocation(line: 25, column: 17, scope: !56)
!95 = !DILocalVariable(name: "x", scope: !51, file: !8, line: 26, type: !11)
!96 = !DILocation(line: 26, column: 7, scope: !51)
!97 = !DILocalVariable(name: "y", scope: !51, file: !8, line: 26, type: !11)
!98 = !DILocation(line: 26, column: 10, scope: !51)
!99 = !DILocation(line: 27, column: 11, scope: !51)
!100 = !DILocation(line: 27, column: 13, scope: !51)
!101 = !DILocation(line: 27, column: 18, scope: !51)
!102 = !DILocation(line: 27, column: 7, scope: !51)
!103 = !DILocation(line: 27, column: 5, scope: !51)
!104 = !DILocation(line: 28, column: 11, scope: !51)
!105 = !DILocation(line: 28, column: 13, scope: !51)
!106 = !DILocation(line: 28, column: 18, scope: !51)
!107 = !DILocation(line: 28, column: 7, scope: !51)
!108 = !DILocation(line: 28, column: 5, scope: !51)
!109 = !DILocation(line: 29, column: 11, scope: !51)
!110 = !DILocation(line: 29, column: 15, scope: !51)
!111 = !DILocation(line: 29, column: 13, scope: !51)
!112 = !DILocation(line: 29, column: 3, scope: !51)
!113 = !DILocation(line: 30, column: 1, scope: !51)
!114 = distinct !DISubprogram(name: "main", scope: !8, file: !8, line: 32, type: !115, scopeLine: 32, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!115 = !DISubroutineType(types: !116)
!116 = !{!11, !11, !117}
!117 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !118, size: 64)
!118 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !119, size: 64)
!119 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!120 = !DILocalVariable(name: "argc", arg: 1, scope: !114, file: !8, line: 32, type: !11)
!121 = !DILocation(line: 32, column: 14, scope: !114)
!122 = !DILocalVariable(name: "argv", arg: 2, scope: !114, file: !8, line: 32, type: !117)
!123 = !DILocation(line: 32, column: 26, scope: !114)
!124 = !DILocalVariable(name: "n", scope: !114, file: !8, line: 33, type: !11)
!125 = !DILocation(line: 33, column: 7, scope: !114)
!126 = !DILocalVariable(name: "base", scope: !114, file: !8, line: 34, type: !11)
!127 = !DILocation(line: 34, column: 7, scope: !114)
!128 = !DILocation(line: 38, column: 7, scope: !129)
!129 = distinct !DILexicalBlock(scope: !114, file: !8, line: 38, column: 7)
!130 = !DILocation(line: 38, column: 12, scope: !129)
!131 = !DILocation(line: 38, column: 7, scope: !114)
!132 = !DILocation(line: 39, column: 14, scope: !129)
!133 = !DILocation(line: 39, column: 9, scope: !129)
!134 = !DILocation(line: 39, column: 7, scope: !129)
!135 = !DILocation(line: 39, column: 5, scope: !129)
!136 = !DILocation(line: 42, column: 7, scope: !137)
!137 = distinct !DILexicalBlock(scope: !114, file: !8, line: 42, column: 7)
!138 = !DILocation(line: 42, column: 12, scope: !137)
!139 = !DILocation(line: 42, column: 7, scope: !114)
!140 = !DILocation(line: 43, column: 17, scope: !137)
!141 = !DILocation(line: 43, column: 12, scope: !137)
!142 = !DILocation(line: 43, column: 10, scope: !137)
!143 = !DILocation(line: 43, column: 5, scope: !137)
!144 = !DILocalVariable(name: "best_time", scope: !114, file: !8, line: 45, type: !145)
!145 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!146 = !DILocation(line: 45, column: 10, scope: !114)
!147 = !DILocalVariable(name: "r", scope: !114, file: !8, line: 46, type: !11)
!148 = !DILocation(line: 46, column: 7, scope: !114)
!149 = !DILocalVariable(name: "i", scope: !150, file: !8, line: 48, type: !11)
!150 = distinct !DILexicalBlock(scope: !114, file: !8, line: 48, column: 5)
!151 = !DILocation(line: 48, column: 14, scope: !150)
!152 = !DILocation(line: 48, column: 10, scope: !150)
!153 = !DILocation(line: 48, column: 21, scope: !154)
!154 = distinct !DILexicalBlock(scope: !150, file: !8, line: 48, column: 5)
!155 = !DILocation(line: 48, column: 23, scope: !154)
!156 = !DILocation(line: 48, column: 5, scope: !150)
!157 = !DILocalVariable(name: "init", scope: !158, file: !8, line: 49, type: !159)
!158 = distinct !DILexicalBlock(scope: !154, file: !8, line: 48, column: 35)
!159 = !DIDerivedType(tag: DW_TAG_typedef, name: "fasttime_t", file: !160, line: 60, baseType: !161)
!160 = !DIFile(filename: "./fasttime.h", directory: "/data/compilers/tests/6172F20/homework6")
!161 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timespec", file: !162, line: 8, size: 128, elements: !163)
!162 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/struct_timespec.h", directory: "")
!163 = !{!164, !168}
!164 = !DIDerivedType(tag: DW_TAG_member, name: "tv_sec", scope: !161, file: !162, line: 10, baseType: !165, size: 64)
!165 = !DIDerivedType(tag: DW_TAG_typedef, name: "__time_t", file: !166, line: 148, baseType: !167)
!166 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "")
!167 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!168 = !DIDerivedType(tag: DW_TAG_member, name: "tv_nsec", scope: !161, file: !162, line: 11, baseType: !169, size: 64, offset: 64)
!169 = !DIDerivedType(tag: DW_TAG_typedef, name: "__syscall_slong_t", file: !166, line: 184, baseType: !167)
!170 = !DILocation(line: 49, column: 18, scope: !158)
!171 = !DILocation(line: 49, column: 25, scope: !158)
!172 = !DILocation(line: 50, column: 15, scope: !158)
!173 = !DILocation(line: 50, column: 18, scope: !158)
!174 = !DILocation(line: 50, column: 11, scope: !158)
!175 = !DILocation(line: 50, column: 9, scope: !158)
!176 = !DILocalVariable(name: "end", scope: !158, file: !8, line: 51, type: !159)
!177 = !DILocation(line: 51, column: 18, scope: !158)
!178 = !DILocation(line: 51, column: 24, scope: !158)
!179 = !DILocalVariable(name: "timediff", scope: !158, file: !8, line: 52, type: !145)
!180 = !DILocation(line: 52, column: 14, scope: !158)
!181 = !DILocation(line: 52, column: 25, scope: !158)
!182 = !DILocation(line: 53, column: 20, scope: !158)
!183 = !DILocation(line: 53, column: 31, scope: !158)
!184 = !DILocation(line: 53, column: 29, scope: !158)
!185 = !DILocation(line: 53, column: 19, scope: !158)
!186 = !DILocation(line: 53, column: 44, scope: !158)
!187 = !DILocation(line: 53, column: 55, scope: !158)
!188 = !DILocation(line: 53, column: 17, scope: !158)
!189 = !DILocation(line: 54, column: 5, scope: !158)
!190 = !DILocation(line: 48, column: 31, scope: !154)
!191 = !DILocation(line: 48, column: 5, scope: !154)
!192 = distinct !{!192, !156, !193}
!193 = !DILocation(line: 54, column: 5, scope: !150)
!194 = !DILocation(line: 59, column: 28, scope: !114)
!195 = !DILocation(line: 59, column: 31, scope: !114)
!196 = !DILocation(line: 59, column: 3, scope: !114)
!197 = !DILocation(line: 60, column: 25, scope: !114)
!198 = !DILocation(line: 60, column: 3, scope: !114)
!199 = !DILocation(line: 61, column: 3, scope: !114)
!200 = distinct !DISubprogram(name: "gettime", scope: !160, file: !160, line: 63, type: !201, scopeLine: 63, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !2)
!201 = !DISubroutineType(types: !202)
!202 = !{!159}
!203 = !DILocalVariable(name: "s", scope: !200, file: !160, line: 64, type: !161)
!204 = !DILocation(line: 64, column: 19, scope: !200)
!205 = !DILocalVariable(name: "r", scope: !200, file: !160, line: 65, type: !11)
!206 = !DILocation(line: 65, column: 7, scope: !200)
!207 = !DILocation(line: 66, column: 7, scope: !200)
!208 = !DILocation(line: 66, column: 5, scope: !200)
!209 = !DILocation(line: 67, column: 3, scope: !200)
!210 = distinct !DISubprogram(name: "tdiff_sec", scope: !160, file: !160, line: 72, type: !211, scopeLine: 72, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !2)
!211 = !DISubroutineType(types: !212)
!212 = !{!145, !213, !213}
!213 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !159)
!214 = !DILocalVariable(name: "start", arg: 1, scope: !210, file: !160, line: 72, type: !213)
!215 = !DILocation(line: 72, column: 49, scope: !210)
!216 = !DILocalVariable(name: "stop", arg: 2, scope: !210, file: !160, line: 72, type: !213)
!217 = !DILocation(line: 72, column: 73, scope: !210)
!218 = !DILocation(line: 73, column: 16, scope: !210)
!219 = !DILocation(line: 73, column: 31, scope: !210)
!220 = !DILocation(line: 73, column: 23, scope: !210)
!221 = !DILocation(line: 73, column: 10, scope: !210)
!222 = !DILocation(line: 73, column: 54, scope: !210)
!223 = !DILocation(line: 73, column: 70, scope: !210)
!224 = !DILocation(line: 73, column: 62, scope: !210)
!225 = !DILocation(line: 73, column: 48, scope: !210)
!226 = !DILocation(line: 73, column: 46, scope: !210)
!227 = !DILocation(line: 73, column: 39, scope: !210)
!228 = !DILocation(line: 73, column: 3, scope: !210)
