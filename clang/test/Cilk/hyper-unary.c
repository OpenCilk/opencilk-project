// RUN: %clang_cc1 %s -x c -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// This does not pass in C++ because hyperobject expression statements
// without side effects are not emitted.  Unclear if this is a bug or a feature.
// expected-no-diagnostics

extern int _Hyperobject x;
extern int _Hyperobject *xp;

// CHECK-LABEL: function1
void function1()
{
  // CHECK: store i32 1, i32* %[[Y:.+]],
  int _Hyperobject y = 1;
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* bitcast (i32* @x to i8*), i64 4, i8* null, i8* null)
  // CHECK: load i32
  // CHECK: %[[Y1:.+]] = bitcast i32* %[[Y]] to i8*
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* %[[Y1]], i64 4, i8* null, i8* null)
  // CHECK: load i32
  (void)x; (void)y;
}

// CHECK-LABEL: function2
void function2()
{
  // CHECK: store i32 1, i32* %[[Y:.+]],
  int _Hyperobject y = 1;
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* bitcast (i32* @x to i8*), i64 4, i8* null, i8* null)
  // CHECK: load i32
  // CHECK: %[[Y2:.+]] = bitcast i32* %[[Y]] to i8*
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* %[[Y2]], i64 4, i8* null, i8* null)
  // CHECK: load i32
  (void)!x; (void)!y;
}

// CHECK-LABEL: function3
void function3()
{
  // CHECK: store i32 1, i32* %[[Y:.+]],
  int _Hyperobject y = 1;
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* bitcast (i32* @x to i8*), i64 4, i8* null, i8* null)
  // CHECK: load i32
  // CHECK: %[[Y3:.+]] = bitcast i32* %[[Y]] to i8*
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* %[[Y3]], i64 4, i8* null, i8* null)
  // CHECK: load i32
  (void)-x; (void)-y;
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* bitcast (i32* @x to i8*), i64 4, i8* null, i8* null)
  // CHECK: load i32
  // CHECK: %[[Y4:.+]] = bitcast i32* %[[Y]] to i8*
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* %[[Y4]], i64 4, i8* null, i8* null)
  // CHECK: load i32
  (void)~x; (void)~y;
  // CHECK: %[[XP:.+]] = load i32*, i32** @xp
  // CHECK: %[[XP1:.+]] = bitcast i32* %[[XP]] to i8*
  // CHECK: call i8* @llvm.hyper.lookup.i64(i8* %[[XP1]], i64 4, i8* null, i8* null)
  // CHECK: load i32
  (void)*xp;
}
