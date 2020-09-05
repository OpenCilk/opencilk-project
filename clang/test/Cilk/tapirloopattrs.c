// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fcilkplus -ftapir=none -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

void parfor_novec(double *restrict y, double *restrict x, double a, int n) {
  #pragma clang loop vectorize(disable)
  _Cilk_for (int i = 0; i < n; ++i)
    y[i] += a * x[i];
}

void parfor_unroll_vec(double *restrict y, double *restrict x, double a, int n) {
  #pragma clang loop unroll_count(4)
  #pragma clang loop vectorize_width(4)
  for (int i = 0; i < n; ++i)
    y[i] += a * x[i];

  #pragma clang loop unroll_count(4)
  #pragma clang loop vectorize_width(4)
  _Cilk_for (int i = 0; i < n; ++i)
    y[i] += a * x[i];
}

// CHECK: define {{.*}}void @parfor_novec(double* noalias %y, double* noalias %x, double %a, i32 %n)
// CHECK: !llvm.loop [[LOOPID1:![0-9]+]]

// CHECK: define {{.*}}void @parfor_unroll_vec(double* noalias %y, double* noalias %x, double %a, i32 %n)
// CHECK: !llvm.loop [[LOOPID2:![0-9]+]]
// CHECK: !llvm.loop [[LOOPID3:![0-9]+]]

// CHECK: [[LOOPID1]] = distinct !{[[LOOPID1]], [[TAPIR_SPAWN_STRATEGY:![0-9]+]], [[NOVEC:![0-9]+]]}
// CHECK: [[TAPIR_SPAWN_STRATEGY]] = !{!"tapir.loop.spawn.strategy", i32 1}
// CHECK: [[NOVEC]] = !{!"llvm.loop.vectorize.width", i32 1}

// CHECK: [[LOOPID2]] = distinct !{[[LOOPID2]], [[VECATTRS:!.+]], [[VECFOLLOWALL1:![0-9]+]]}
// CHECK: [[VECFOLLOWALL1]] = !{!"llvm.loop.vectorize.followup_all", [[VECFOLLOW1:![0-9]+]]}
// CHECK: [[VECFOLLOW1]] = distinct !{[[VECFOLLOW1]], [[VECFOLLOWATTRS:!.+]]}

// CHECK: [[LOOPID3]] = distinct !{[[LOOPID3]], [[TAPIR_SPAWN_STRATEGY]], [[VECATTRS]], [[VECFOLLOWALL2:![0-9]+]]}
// CHECK: [[VECFOLLOWALL2]] = !{!"llvm.loop.vectorize.followup_all", [[VECFOLLOW2:![0-9]+]]}
// CHECK: [[VECFOLLOW2]] = distinct !{[[VECFOLLOW2]], [[TAPIR_SPAWN_STRATEGY]], [[VECFOLLOWATTRS]]}
