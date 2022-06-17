// Test autoincrement operations on hyperobjects.
// RUN: %clang_cc1 %s -x c -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
extern void identity(void * value);
extern void reduce(void* left, void* right);

typedef long _Hyperobject *long_hp;
typedef long _Hyperobject long_h;
extern int _Hyperobject x, _Hyperobject y;
// CHECK_LABEL: extern1
void extern1()
{
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: load i32,
  // Only one call for a read-modify-write operation.
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  // CHECK: store i32
  // CHECK: ret void
  ++x;
}

// CHECK_LABEL: extern2
int extern2()
{
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: load i32,
  // Only one call for a read-modify-write operation.
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  // CHECK: store i32
  // CHECK: ret i32
  return 1 + --x;
}

// CHECK_LABEL: ptr_with_direct_typedef
long ptr_with_direct_typedef(long_hp ptr)
{
  // CHECK-NOT: ret i64
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: ret i64
  return ++*ptr;
}

// CHECK_LABEL: ptr_with_indirect_typedef_1
long ptr_with_indirect_typedef_1(long_h *ptr)
{
  // CHECK-NOT: ret i64
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK-NOT: store i64
  // CHECK: ret i64
  return *ptr++; // this increments the pointer, a dead store
}

// CHECK_LABEL: ptr_with_indirect_typedef_2
long ptr_with_indirect_typedef_2(long_h *ptr)
{
  // CHECK-NOT: ret i64
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK-NOT: store i64
  // CHECK: ret i64
  return *++ptr; // again, the increment is dead
}

// CHECK_LABEL: ptr_with_indirect_typedef_3
long ptr_with_indirect_typedef_3(long_h *ptr)
{
  // CHECK-NOT: ret i64
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: load i64
  // CHECK-NOT: call i8* @llvm.hyper.lookup
  // CHECK: store i64
  // CHECK: ret i64
  return ptr[0]++;
}

// CHECK_LABEL: direct_typedef_1
long direct_typedef_1()
{
  extern long_h z;
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: load i64,
  // CHECK: store i64
  // CHECK: ret i64
  return ++z;
}

// CHECK_LABEL: local_reducer_1
double local_reducer_1()
{
  // Initialization precedes registration
  // CHECK: store double 0.0
  // CHECK: call void @llvm.reducer.register
  double _Hyperobject(identity, reduce) x = 0.0;
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: load double
  // CHECK: fadd double
  // CHECK: store double
  x += 1.0f;
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: load double
  // CHECK: call void @llvm.reducer.unregister
  // CHECK: ret double
  return x;
}

// CHECK_LABEL: two_increments
long two_increments()
{
  // It would also be correct for evaluation of operands of + to be interleaved.
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: load i32
  // CHECK: store i32
  // CHECK: call i8* @llvm.hyper.lookup
  // CHECK: load i32
  // CHECK: store i32
  // CHECK: ret i64
  return ++x + y++;
}

