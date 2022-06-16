// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
template<typename VIEW>
struct reducer
{
  static void reduce(VIEW *, VIEW *);
  static void identity(VIEW *);
  char pad;
  // Registration of structure members is not implemented.
  VIEW _Hyperobject(identity, reduce) value; // expected-warning{{reducer callbacks not implemented}}
  reducer();
  ~reducer();
};

// CHECK: call void @_ZN7reducerIsEC1Ev
// CHECK: @_ZN7reducerIsED1Ev
reducer<short> r; // expected-note{{in instantiation}}

// CHECK-LABEL: _Z1fv
// CHECK: call i8* @llvm.hyper.lookup
// CHECK: load i16
// CHECK: sext i16
// CHECK: ret i32
int f() { return r.value; }
