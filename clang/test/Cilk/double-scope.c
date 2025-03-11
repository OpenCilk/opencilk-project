// RUN: %clang_cc1 -emit-llvm -fopencilk -mllvm -use-opencilk-runtime-bc=false -mllvm -debug-abi-calls -O0 -x c %s -o /dev/null
// RUN: %clang_cc1 -emit-llvm -fopencilk -mllvm -use-opencilk-runtime-bc=false -mllvm -debug-abi-calls -O1 -x c %s -o /dev/null
// If the compiler doesn't crash the bug is fixed.

void ccc()
{
  extern void ddd(void);
  cilk_scope { cilk_scope cilk_spawn { ddd(); } }
}
