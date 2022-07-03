// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
template <typename T>
struct Constructed {
  Constructed();
  ~Constructed();
  //static void identity(Constructed<T> *);
  //static void reduce(Constructed<T> *left, Constructed<T> *right);
  static void identity(void *);
  static void reduce(void *left, void *right);
};

// Make sure hyperobjects pass through (template using) unharmed.
template<typename T>
using Alias =
  Constructed<T> _Hyperobject(Constructed<T>::identity, Constructed<T>::reduce);

void f()
{
  // CHECK: call void @_ZN11ConstructedIiEC1Ev
  // CHECK: call void @llvm.reducer.register
  Alias<int> local;
  // CHECK: call void @llvm.reducer.unregister
  // CHECK: call void @_ZN11ConstructedIiED1Ev
}
