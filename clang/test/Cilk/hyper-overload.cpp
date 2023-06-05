// RUN: %clang_cc1 %s -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics
struct S { int operator&(); };
extern int operator+(S &, int);

// Behavior without hyperobjects
// CHECK-LABEL: f1
// CHECK-NOT: @llvm.hyper.lookup
// CHECK: @_ZN1SadEv
int f1(struct S*sp) { return &*sp; }
// Lookup view then call S::operator &().
// CHECK-LABEL: f2
// CHECK: @llvm.hyper.lookup
// CHECK: @_ZN1SadEv
int f2(struct S _Hyperobject*sp) { return &*sp; }
// Lookup view then call operator+(S &, int);
// CHECK-LABEL: f3
// CHECK: @llvm.hyper.lookup
// CHECK: @_ZplR1Si
int f3(struct S _Hyperobject*sp) { return *sp + 1; }
