// RUN: %clang_cc1 %s -std=c++20 -fopencilk -disable-llvm-passes -S -emit-llvm -o - | FileCheck %s

template <class index_t> void foo() {
  _Cilk_for(index_t row = 0; row < 1024; row++) { void; }
}

int main() { foo<int>(); }

// CHECK-LABEL: define {{.*}}void @_Z3fooIiEvv()
// CHECK: entry:
// CHECK: %[[INIT_LOAD:.+]] = load i32, ptr %__init
// CHECK-NEXT: %[[LIMIT_LOAD:.+]] = load i32, ptr %__limit
// CHECK-NEXT: %[[CMP:.+]] = icmp slt i32 %[[INIT_LOAD]], %[[LIMIT_LOAD]]
// CHECK-NEXT: br i1 %[[CMP]], label %pfor.ph, label %pfor.end

// CHECK: pfor.ph:
// CHECK: store i32 0, ptr %__begin
// CHECK-NEXT: %[[LIMIT_LOAD2:.+]] = load i32, ptr %__limit
// CHECK-NEXT: %[[INIT_LOAD2:.+]] = load i32, ptr %__init
// CHECK-NEXT: %[[SUB:.+]] = sub nsw i32 %[[LIMIT_LOAD2]], %[[INIT_LOAD2]]
// CHECK-NEXT: store i32 %[[SUB]], ptr %__end
// CHECK-NEXT: br label %pfor.cond

// CHECK: pfor.detach:
// CHECK-NEXT: %[[INIT_LOAD3:.+]] = load i32, ptr %__init
// CHECK-NEXT: %[[BEGIN_LOAD:.+]] = load i32, ptr %__begin
// CHECK-NEXT: %[[ADD:.+]] = add nsw i32 %[[INIT_LOAD3]], %[[BEGIN_LOAD]]
// CHECK-NEXT: detach within %{{.+}}, label %pfor.body.entry, label %pfor.inc

// CHECK: pfor.body.entry:
// CHECK-NEXT: %[[ROW:.+]] = alloca i32
// CHECK-NEXT: store i32 %[[ADD]], ptr %[[ROW]]
// CHECK-NEXT: br label %pfor.body
