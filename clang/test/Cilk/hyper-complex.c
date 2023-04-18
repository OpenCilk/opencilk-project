// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern __complex__ float _Hyperobject c;

// CHECK-LABEL: get_real 
float get_real()
{
  // CHECK: %[[RAW1:.+]] = call ptr @llvm.hyper.lookup.i64(ptr @c, i64 8, ptr null, ptr null)
  // CHECK: %[[FIELD1:.+]] = getelementptr inbounds { float, float }, ptr %[[RAW1]], i32 0, i32 0
  // CHECK: %[[RET1:.+]] = load float, ptr %[[FIELD1]]
  // CHECK: ret float %[[RET1]]
  return __real__(c);
}
// CHECK-LABEL: get_imag
float get_imag()
{
  // CHECK: %[[RAW2:.+]] = call ptr @llvm.hyper.lookup.i64(ptr @c, i64 8, ptr null, ptr null)
  // CHECK: %[[FIELD2:.+]] = getelementptr inbounds { float, float }, ptr %[[RAW2]], i32 0, i32 1
  // CHECK: load float, ptr %[[FIELD2]]
  // CHECK: ret float
  return __imag__(c);
}

// CHECK-LABEL: get_abs
float get_abs()
{
  // Only one call to llvm.hyper.lookup.
  // CHECK: @llvm.hyper.lookup.i64(ptr @c, i64 8, ptr null, ptr null)
  // CHECK-NOT: @llvm.hyper.lookup
  // CHECK: call float @cabsf
  // CHECK: ret float
  return __builtin_cabsf(c);
}
