// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -disable-llvm-passes -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics
template <typename T>
struct Inner
{
  static void identity(void *);
  static void reduce(void *, void *);
  Inner();
  ~Inner() noexcept { }
};

struct Outer {
  Inner<char> _Hyperobject(&Inner<char>::identity, &Inner<char>::reduce) member;
  Outer();
  ~Outer();
};

// Make sure the appropriate variant of ~Inner() is emitted.
// CHECK: {{^}}define{{.*}} {{void|ptr}} @_ZN5OuterD2Ev
// CHECK: call{{.*}} {{void|ptr}} @_ZN5InnerIcED2Ev
// CHECK: {{^}}define linkonce_odr{{.*}} {{void|ptr}} @_ZN5InnerIcED2Ev

Outer::~Outer() { }
