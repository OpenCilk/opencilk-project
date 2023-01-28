// RUN: %clang_cc1 %s -fopencilk -verify -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

template<typename T> struct S { T member; };
S<long> _Hyperobject S_long;

// CHECK-LABEL: @_Z1fv
// CHECK: %0 = call i8* @llvm.hyper.lookup.i64(i8* bitcast (%struct.S* @S_long to i8*), i64 8, i8* null, i8* null)
// CHECK-NOT: call i8* @llvm.hyper.lookup
// CHECK: getelementptr
// CHECK: %[[RET:.+]] = load i64
// CHECK: ret i64 %[[RET]]
long f() { return S_long.member; }

// CHECK-LABEL: _Z1gPH1SIsE
// CHECK: call i8* @llvm.hyper.lookup
// CHECK-NOT: call i8* @llvm.hyper.lookup
// CHECK: getelementptr
// CHECK: load i16
long g(S<short> _Hyperobject *p) { return p->member; }
