// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -emit-llvm -disable-llvm-passes -mllvm -use-opencilk-runtime-bc=false -mllvm -debug-abi-calls -o - | FileCheck %s
// expected-no-diagnostics
extern void identity(void *), reduce(void *, void *);

struct S { int a,b,c; };
typedef struct S cilk_reducer(identity, reduce) sh;
extern sh *s;

// CHECK-LABEL: @lookuper()
int lookuper()
{
  // CHECK: entry:
  // CHECK: load ptr, ptr @s
  // CHECK: call ptr @llvm.hyper.lookup.2
  // CHECK: load i32,
  return s->c;
  // CHECK: ret i32
}
