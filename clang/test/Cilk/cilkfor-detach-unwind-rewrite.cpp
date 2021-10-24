// Check that detaches with unwind destinations are properly inserted
// during CodeGen.
//
// RUN: %clang_cc1 %s -fopencilk -fsanitize=signed-integer-overflow,unsigned-integer-overflow -fcxx-exceptions -fexceptions -emit-llvm -fsanitize-recover=signed-integer-overflow,unsigned-integer-overflow -disable-llvm-passes -o - | FileCheck %s

unsigned __cilkrts_get_nworkers(void);

template <class T> class Reducer_sum {
public:
  Reducer_sum(long num_workers);
  ~Reducer_sum();
  void add(T new_value);
  T get() const;
};

int main() {
  Reducer_sum<long> total_red(__cilkrts_get_nworkers());
  _Cilk_for(long i = 0; i < 100; i++) { total_red.add(5); }
  return total_red.get();
}

// CHECK: define {{.*}}i32 @main()
// CHECK: br i1 %{{.*}}, label %[[PFOR_PH:.+]], label %[[PFOR_END:[a-z0-9._]+]]

// CHECK: [[PFOR_PH]]:
// CHECK: call void @__ubsan_handle_sub_overflow
// CHECK: call void @__ubsan_handle_sub_overflow
// CHECK: call void @__ubsan_handle_divrem_overflow
// CHECK: call void @__ubsan_handle_add_overflow

// Check contents of the detach block
// CHECK: load i64, i64* %[[INIT:.+]]
// CHECK: load i64, i64* %[[BEGIN:.+]]
// CHECK: call { i64, i1 } @llvm.smul.with.overflow.i64(
// CHECK: br i1 %{{.*}}, label %[[CONT5:.+]], label %[[HANDLE_MUL_OVERFLOW:[a-z0-9._]+]],

// CHECK: [[HANDLE_MUL_OVERFLOW]]:
// CHECK: call void @__ubsan_handle_mul_overflow

// CHECK: [[CONT5]]:
// CHECK: call { i64, i1 } @llvm.sadd.with.overflow.i64(
// CHECK: br i1 %{{.*}}, label %[[CONT7:.+]], label %[[HANDLE_ADD_OVERFLOW:[a-z0-9._]+]],

// CHECK: [[HANDLE_ADD_OVERFLOW]]:
// CHECK: call void @__ubsan_handle_add_overflow

// Check that the detach ends up after the loop-variable init expression.

// CHECK: [[CONT7]]:
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[PFOR_BODY_ENTRY:.+]], label %[[PFOR_INC:.+]] unwind label %[[LPAD9:.+]]
