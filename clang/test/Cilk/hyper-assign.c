// RUN: %clang_cc1 %s -x c -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern long _Hyperobject x, _Hyperobject y;

long chain_assign()
{
  // CHECK: %[[Y1RAW:.+]] = call i8* @llvm.hyper.lookup(i8* bitcast (i64* @y to i8*))
  // CHECK: %[[Y1PTR:.+]] = bitcast i8* %[[Y1RAW]] to i64*
  // CHECK: %[[Y1VAL:.+]] = load i64, i64* %[[Y1PTR]]
  // CHECK: call i8* @llvm.hyper.lookup(i8* bitcast (i64* @x to i8*))
  // CHECK: store i64 %[[Y1VAL]]
  // CHECK: call i8* @llvm.hyper.lookup(i8* bitcast (i64* @y to i8*))
  // CHECK: call i8* @llvm.hyper.lookup(i8* bitcast (i64* @x to i8*))
  return x = y = x = y;
}

long simple_assign(long val)
{
  // CHECK: call i8* @llvm.hyper.lookup(i8* bitcast (i64* @x to i8*))
  // CHECK: store i64
  return x = val;
}

long subtract()
{
  // The order is not fixed here.
  // CHECK: call i8* @llvm.hyper.lookup(i8* bitcast (i64* @y to i8*))
  // CHECK: load i64
  // CHECK: add nsw i64 %[[Y:.+]], 1
  // CHECK: store i64
  // CHECK: call i8* @llvm.hyper.lookup(i8* bitcast (i64* @x to i8*))
  // CHECK: load i64
  // CHECK: sub nsw
  // CHECK: store i64
  return x -= y++;
}
