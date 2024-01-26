// RUN: %clang_cc1 %s -x c -O1 -fopencilk -mllvm -use-opencilk-runtime-bc=false -mllvm -debug-abi-calls=true -verify -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

// CHECK-LABEL: zero
int zero()
{
  return __tapir_frame() != 0;
  // CHECK: ret i32 0
}

// CHECK-LABEL: one
int one()
{
  extern void f(int);
  _Cilk_spawn f(0);
  _Cilk_spawn f(1);
  // CHECK: ret i32 1
  return __tapir_frame() != 0;
}

// CHECK-LABEL: function3
int function3()
{
  extern void f(int);
  extern int g(void *);
  _Cilk_spawn f(0);
  // CHECK: call i32 @g(ptr noundef nonnull %__cilkrts_sf)
  return g(__tapir_frame());
}
