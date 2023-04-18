// RUN: %clang_cc1 %s -x c -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// This does not pass in C++ because hyperobject expression statements
// without side effects are not emitted.  Unclear if this is a bug or a feature.
// expected-no-diagnostics

extern int _Hyperobject x;
extern int _Hyperobject *xp;

// CHECK-LABEL: function1
void function1()
{
  // CHECK: store i32 1, ptr %[[Y:.+]],
  int _Hyperobject y = 1;
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @x, i64 4, ptr null, ptr null)
  // CHECK: load i32
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr %[[Y]], i64 4, ptr null, ptr null)
  // CHECK: load i32
  (void)x; (void)y;
}

// CHECK-LABEL: function2
void function2()
{
  // CHECK: store i32 1, ptr %[[Y:.+]],
  int _Hyperobject y = 1;
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @x, i64 4, ptr null, ptr null)
  // CHECK: load i32
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr %[[Y]], i64 4, ptr null, ptr null)
  // CHECK: load i32
  (void)!x; (void)!y;
}

// CHECK-LABEL: function3
void function3()
{
  // CHECK: store i32 1, ptr %[[Y:.+]],
  int _Hyperobject y = 1;
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @x, i64 4, ptr null, ptr null)
  // CHECK: load i32
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr %[[Y]], i64 4, ptr null, ptr null)
  // CHECK: load i32
  (void)-x; (void)-y;
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @x, i64 4, ptr null, ptr null)
  // CHECK: load i32
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr %[[Y]], i64 4, ptr null, ptr null)
  // CHECK: load i32
  (void)~x; (void)~y;
  // CHECK: %[[XP:.+]] = load ptr, ptr @xp
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr %[[XP]], i64 4, ptr null, ptr null)
  // CHECK: load i32
  (void)*xp;
}
