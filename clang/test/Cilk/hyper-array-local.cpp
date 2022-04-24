// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
extern void identity_long(void *, long *);
extern void reduce_long(void *, long *, long *);

typedef _Hyperobject long __attribute__((reducer(reduce_long, identity_long), aligned(16))) rlong;

// CHECK_LABEL: local_array_of_hyper
long local_array_of_hyper(unsigned int x)
{
  // CHECK: %x.addr = alloca
  // CHECK: %[[ARRAY:.+]] = alloca [10 x i64]
  // The outermost variable is not a hyperobject, and registration of
  // hyperobject array elements is not implemented.
  // CHECK-NOT: call void @llvm.reducer.register
  rlong array[10];
  // CHECK: getelementptr inbounds [[JUNK:.+]] %[[ARRAY]]
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: %[[VIEW:.+]] = bitcast
  // CHECK: %[[VAL:.+]] = load i64, i64* %[[VIEW]]
  return array[x];
  // CHECK-NOT: call void @llvm.reducer.unregister
  // CHECK ret i64 [[VAL]]
}

// CHECK_LABEL: local_hyper_of_array
long local_hyper_of_array(unsigned int x)
{
  // CHECK: %x.addr = alloca
  // CHECK: %[[ARRAY:.+]] = alloca [10 x i64]
  // A hyperobject without reducer attribute should not be registered.
  // CHECK-NOT: call void @llvm.reducer.register
  typedef long Array[10];
  _Hyperobject Array array;
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: %[[VIEW:.+]] = bitcast
  // CHECK: %[[ELEMENT:.+]] = getelementptr inbounds [[JUNK:.+]] %[[VIEW]]
  // CHECK: %[[VAL:.+]] = load i64, i64* %[[ELEMENT]]
  return array[x];
  // CHECK-NOT: call void @llvm.reducer.unregister
  // CHECK ret i64 [[VAL]]
}

