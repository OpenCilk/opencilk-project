// RUN: %clang_cc1 %s -x c -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
// This does not pass in C++ because hyperobject expression statements
// without side effects are not emitted.  Unclear if this is a bug or a feature.

extern void identity(void *), reduce(void *, void *);

extern int _Hyperobject(identity, reduce) x;
extern int _Hyperobject(identity, reduce) *xp;

// CHECK-LABEL: function1
void function1()
{
  // CHECK: store i32 1, ptr %[[Y:.+]],
  int _Hyperobject(identity, reduce) y = 1;
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @x, i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr %[[Y]], i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  (void)x; (void)y;
}

// CHECK-LABEL: function2
void function2()
{
  // CHECK: store i32 1, ptr %[[Y:.+]],
  int _Hyperobject(identity, reduce) y = 1;
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @x, i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr %[[Y]], i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  (void)!x; (void)!y;
}

// CHECK-LABEL: function3
void function3()
{
  // CHECK: store i32 1, ptr %[[Y:.+]],
  int _Hyperobject(identity, reduce) y = 1;
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @x, i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr %[[Y]], i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  (void)-x; (void)-y;
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @x, i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr %[[Y]], i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  (void)~x; (void)~y;
  // CHECK: %[[XP:.+]] = load ptr, ptr @xp
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr %[[XP]], i64 4, ptr @identity, ptr @reduce)
  // CHECK: load i32
  (void)*xp;
}
