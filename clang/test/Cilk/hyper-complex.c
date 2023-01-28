// RUN: %clang_cc1 %s -x c -triple aarch64-freebsd -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern __complex__ float _Hyperobject c;

// CHECK-LABEL: get_real 
float get_real()
{
  // CHECK: %[[RAW1:.+]] = call i8* @llvm.hyper.lookup.i64(i8* bitcast ({ float, float }* @c to i8*), i64 8, i8* null, i8* null)
  // CHECK: %[[VIEW1:.+]] = bitcast i8* %[[RAW1]] to { float, float }*
  // CHECK: %[[FIELD1:.+]] = getelementptr inbounds { float, float }, { float, float }* %[[VIEW1]], i32 0, i32 0
  // CHECK: %[[RET1:.+]] = load float, float* %[[FIELD1]]
  // CHECK: ret float %[[RET1]]
  return __real__(c);
}
// CHECK-LABEL: get_imag
float get_imag()
{
  // CHECK: %[[RAW2:.+]] = call i8* @llvm.hyper.lookup.i64(i8* bitcast ({ float, float }* @c to i8*), i64 8, i8* null, i8* null)
  // CHECK: %[[VIEW2:.+]] = bitcast i8* %[[RAW2]] to { float, float }*
  // CHECK: %[[FIELD2:.+]] = getelementptr inbounds { float, float }, { float, float }* %[[VIEW2]], i32 0, i32 1
  // CHECK: load float, float* %[[FIELD2]]
  // CHECK: ret float
  return __imag__(c);
}

// CHECK-LABEL: get_abs
float get_abs()
{
  // Only one call to llvm.hyper.lookup.
  // CHECK: @llvm.hyper.lookup.i64(i8* bitcast ({ float, float }* @c to i8*), i64 8, i8* null, i8* null)
  // CHECK-NOT: @llvm.hyper.lookup
  // CHECK: call float @cabsf
  // CHECK: ret float
  return __builtin_cabsf(c);
}
