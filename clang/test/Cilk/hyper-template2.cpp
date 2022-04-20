// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
template<typename VIEW>
struct reducer
{
  static void reduce(void *, VIEW *, VIEW *);
  static void identity(void *, VIEW *);
  char pad;
  _Hyperobject VIEW value __attribute__((reducer(reduce, identity))); // expected-warning{{'reducer' attribute only applies to}}
  reducer();
  ~reducer();
};

// CHECK: call void @_ZN7reducerIsEC1Ev
// CHECK: @_ZN7reducerIsED1Ev
reducer<short> r;

// CHECK-LABEL: _Z1fv
// CHECK: call i8* @llvm.hyper.lookup
// CHECK: load i16
// CHECK: sext i16
// CHECK: ret i32
int f() { return r.value; }
