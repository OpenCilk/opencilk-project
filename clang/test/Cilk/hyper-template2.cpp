// RUN: %clang_cc1 %s -x c++ -fopencilk -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
template<typename VIEW>
struct reducer
{
  static void identity(void *);
  static void reduce(void *, void *);
  char pad;
  VIEW _Hyperobject(identity, reduce) value;
  reducer();
  ~reducer();
};

// CHECK: call {{.+}} @_ZN7reducerIsEC1Ev
// CHECK: @_ZN7reducerIsED1Ev
reducer<short> r;

// CHECK-LABEL: _Z1fv
// CHECK: call ptr @llvm.hyper.lookup
// CHECK-NOT: call ptr @llvm.hyper.lookup
// CHECK: load i16
// CHECK: sext i16
// CHECK: ret i32
int f() { return r.value; }
