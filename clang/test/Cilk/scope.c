// RUN: %clang_cc1 -emit-llvm -fopencilk -disable-llvm-passes -O1 -x c %s -o - | FileCheck %s

extern void bbb(void);

// CHECK-LABEL: @aaa
int aaa(int argc, char *argv[])
{
// CHECK: call token @llvm.tapir.runtime.start()
  cilk_scope
    for (int i = 0; i < argc; ++i)
// CHECK: detach within
// CHECK: call void @bbb
// CHECK-NEXT: reattach within
// sync must precede runtime end
// CHECK: sync within
// CHECK: call void @llvm.tapir.runtime.end
      cilk_spawn { bbb(); }
  return 0;
}
