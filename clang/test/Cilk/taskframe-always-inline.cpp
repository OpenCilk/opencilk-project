// Check that -O0 compilation handles always_inline functions before Tapir
// lowering.
//
// RUN: %clang_cc1 -fcxx-exceptions -fexceptions -fopencilk -triple x86_64-unknown-linux-gnu -emit-llvm -mllvm -debug-abi-calls -mllvm -use-opencilk-runtime-bc=false %s -o- | FileCheck %s

void print(const char *s, ...);

void bar(int x);
void foo(int x);

__attribute__((always_inline))
void top(int x) {
  _Cilk_spawn foo(1);
  try {
    _Cilk_spawn bar(1);
    bar(2);
  } catch (int e) {
    print("top caught exception: %d\n", e);
  }
}

int main(int argc, char *argv[]) {
  print("main");
  try {
    _Cilk_spawn top(1);
    top(2);
  } catch (char e) {
    print("main caught exception %c\n", e);
  }
  print("main done");

  return 0;
}

// CHECK: define {{.*}}i32 @main(

// CHECK: invoke {{.*}}void @main.outline
// CHECK-NEXT: to label %[[DET_CONT:.+]] unwind

// CHECK: [[DET_CONT]]:
// CHECK: invoke {{.*}}void [[MAIN_TOP2_OTF0:@main\.outline.+.otf0]](
// CHECK-NEXT: to label %[[INVOKE_CONT:.+]] unwind

// CHECK: [[INVOKE_CONT]]:
// CHECK: invoke void @__cilk_sync(


// CHECK: define {{.*}}void [[MAIN_TOP2_OTF0]](
// CHECK: call void @__cilkrts_enter_frame(
// CHECK: call i32 @__cilk_prepare_spawn(

