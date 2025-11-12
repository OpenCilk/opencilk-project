// RUN: %clang_cc1 %s -x c -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

#ifdef __cplusplus
extern "C"
#endif
void identity(void *), reduce(void *, void *);
// use both spellings of keyword
extern long _Hyperobject(identity, reduce) x, cilk_reducer(identity, reduce) y;

long chain_assign()
{
  // CHECK: %[[Y1RAW:.+]] = call ptr @llvm.hyper.lookup.2.i64(ptr @y, i64 8, ptr @identity, ptr @reduce)
  // CHECK: %[[Y1VAL:.+]] = load i64, ptr %[[Y1RAW]]
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @x, i64 8, ptr @identity, ptr @reduce)
  // CHECK: store i64 %[[Y1VAL]]
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @y, i64 8, ptr @identity, ptr @reduce)
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @x, i64 8, ptr @identity, ptr @reduce)
  return x = y = x = y;
}

long simple_assign(long val)
{
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @x, i64 8, ptr @identity, ptr @reduce)
  // CHECK-NOT: call ptr @llvm.hyper.lookup
  // CHECK: store i64
  return x = val;
}

long subtract()
{
  // The order is not fixed here.
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @y, i64 8, ptr @identity, ptr @reduce)
  // CHECK: load i64
  // CHECK: add nsw i64 %[[Y:.+]], 1
  // CHECK: store i64
  // CHECK: call ptr @llvm.hyper.lookup.2.i64(ptr @x, i64 8, ptr @identity, ptr @reduce)
  // CHECK: load i64
  // CHECK: sub nsw
  // CHECK: store i64
  return x -= y++;
}
