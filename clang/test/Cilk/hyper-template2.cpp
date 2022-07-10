// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
template<typename VIEW>
struct reducer
{
  static void identity(void *);
  static void reduce(void *, void *);
  char pad;
  // Registration of structure members is not implemented.
  VIEW _Hyperobject(identity, reduce) value;
  // expected-warning@-1{{reducer callbacks not implemented}}
  reducer();
  ~reducer();
};

// CHECK: call {{.+}} @_ZN7reducerIsEC1Ev
// CHECK: @_ZN7reducerIsED1Ev
reducer<short> r; // expected-note{{in instantiation}}

// CHECK-LABEL: _Z1fv
// CHECK: call i8* @llvm.hyper.lookup
// CHECK-NOT: call i8* @llvm.hyper.lookup
// CHECK: load i16
// CHECK: sext i16
// CHECK: ret i32
int f() { return r.value; }
