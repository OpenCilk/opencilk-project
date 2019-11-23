// RUN: %clang_csi_toolc %tooldir/null-tool.c -o %t-null-tool.o
// RUN: %clang_csi_toolc %tooldir/unknown-function-call-count-tool.c -o %t-tool.o
// RUN: %link_csi %t-tool.o %t-null-tool.o -o %t-tool.o
// RUN: %clang_csi_c %s -o %t.o
// RUN: %clang_csi %t.o %t-tool.o -o %t
// RUN: %run %t | FileCheck %s

#include <stdio.h>

static void foo() {
    printf("In foo.\n");
}

int main(int argc, char **argv) {
  printf("One call.\n");
  printf("Two calls.\n");
  foo();
  // CHECK: num_function_calls = 4
  // CHECK: num_unknown_function_calls = 3
  return 0;
}
