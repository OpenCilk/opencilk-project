// RUN: %clang_cc1 %s -x c -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern long _Hyperobject x, _Hyperobject y;

long chain_assign()
{
  // CHECK: %[[Y1RAW:.+]] = call ptr @llvm.hyper.lookup.i64(ptr @y, i64 8, ptr null, ptr null)
  // CHECK: %[[Y1VAL:.+]] = load i64, ptr %[[Y1RAW]]
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @x, i64 8, ptr null, ptr null)
  // CHECK: store i64 %[[Y1VAL]]
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @y, i64 8, ptr null, ptr null)
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @x, i64 8, ptr null, ptr null)
  return x = y = x = y;
}

long simple_assign(long val)
{
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @x, i64 8, ptr null, ptr null)
  // CHECK-NOT: call ptr @llvm.hyper.lookup
  // CHECK: store i64
  return x = val;
}

long subtract()
{
  // The order is not fixed here.
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @y, i64 8, ptr null, ptr null)
  // CHECK: load i64
  // CHECK: add nsw i64 %[[Y:.+]], 1
  // CHECK: store i64
  // CHECK: call ptr @llvm.hyper.lookup.i64(ptr @x, i64 8, ptr null, ptr null)
  // CHECK: load i64
  // CHECK: sub nsw
  // CHECK: store i64
  return x -= y++;
}
