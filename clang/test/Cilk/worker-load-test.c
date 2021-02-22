// RUN: %clang_cc1 %s -fopencilk -mllvm -use-opencilk-runtime-bc=true -mllvm -opencilk-runtime-bc-path=%S/Inputs/libopencilk-abi.bc -O2 -S -emit-llvm -o - | FileCheck %s

typedef int int32_t;
typedef unsigned char uint8_t;

#define QT_IGNORE_HEIGHT 3

#define MAX_NODES 100

/*
 * Find the begining of the parent section in the lines array
 * l_ and r_ are the left and right boundaries for the search
 * h is the height of the parent node should be
 */
int32_t bsearch_parents(int32_t l_, int32_t r_, uint8_t h);

/*
 * Find the begining of the child section representing quadrant q (0, 1, 2, 3)
 * l_ and r_ are the left and right boundaries for the search
 * h is the height of the parent node should be
 */
int32_t bsearch_quadrant(int32_t l_, int32_t r_, uint8_t h, uint8_t q);

/*
 * Check possible collisions among lines in lines[l...r]
 */
void detectCollisionsSlow(int l, int r);

/*
 * Check possible collisions between lines in lines[l1...r1] and lines[l2...r2]
 */
void detectCollisionsSlow2(int l1, int r1, int l2, int r2);

/*
 * Detect collisions in the subtree of the quadtree represeted by lines[l...r]
 * and at the height of h
 */
void detectLocalizedCollisions(int32_t l, int32_t r, uint8_t h) {
  if (l >= r || l < 0 || r < 0) {
    return;
  }

  if (h <= QT_IGNORE_HEIGHT || r - l + 1 <= MAX_NODES) {
    return detectCollisionsSlow(l, r);
  }

  int32_t m[] = {l, -1, -1, -1, -1, r+1};
  m[4] = bsearch_parents(l, r, h);
  m[1] = bsearch_quadrant(l, m[4]-1, h, 1);
  m[2] = bsearch_quadrant(l, m[4]-1, h, 2);
  m[3] = bsearch_quadrant(l, m[4]-1, h, 3);

  int i, j;
  for (i = 0, j = 1; j < 5; j++) {
    if (m[j] != -1) {
      _Cilk_spawn detectLocalizedCollisions(m[i], m[j]-1, h-1);
      i = j;
    }
  }
  _Cilk_spawn detectCollisionsSlow(m[4], r);

  if (l > m[4]-1 || m[4] > r) return;

  detectCollisionsSlow2(l, m[4]-1, m[4], r);
  _Cilk_sync;
}

// CHECK-LABEL: define {{.*}}void @detectLocalizedCollisions(
// CHECK: %[[CILKRTS_SF:.+]] = alloca %struct.__cilkrts_stack_frame
// CHECK: %[[WORKER_CALL:.+]] = call %struct.__cilkrts_worker* @__cilkrts_get_tls_worker()
// CHECK: %[[WORKER_PHI:.+]] = phi %struct.__cilkrts_worker*
// CHECK: %[[WORKER_PTR:.+]] = getelementptr inbounds %struct.__cilkrts_stack_frame, %struct.__cilkrts_stack_frame* %[[CILKRTS_SF]], i64 0, i32 3
// CHECK: %[[WORKER_CALL_VAL:.+]] = ptrtoint %struct.__cilkrts_worker* %[[WORKER_PHI]] to [[WORKER_INT_TY:i[0-9]+]]
// CHECK: %[[WORKER_PTR_CST:.+]] = bitcast %struct.__cilkrts_worker** %[[WORKER_PTR]] to [[WORKER_INT_TY]]*
// CHECK: store atomic [[WORKER_INT_TY]] %[[WORKER_CALL_VAL]], [[WORKER_INT_TY]]* %[[WORKER_PTR_CST]]
// CHECK: icmp
// CHECK-NEXT: or
// CHECK-NEXT: icmp
// CHECK-NEXT: %[[CMP1:.+]] = or i1
// CHECK-NEXT: br i1 %[[CMP1]], label %{{.+}}, label %[[IF_END:.+]]

// CHECK: [[IF_END]]:
// CHECK-NEXT: icmp
// CHECK-NEXT: sub
// CHECK-NEXT: icmp
// CHECK-NEXT: %[[CMP2:.+]] = or i1
// CHECK-NEXT: br i1 %[[CMP2]], label %[[IF_THEN:.+]], label %[[IF_END2:.+]]

// CHECK: [[IF_THEN]]:
// CHECK: call void @detectCollisionsSlow(
// CHECK-NEXT: br label %[[CLEANUP_CONT:.+]]

// CHECK: [[CLEANUP_CONT]]:
// CHECK: load atomic [[WORKER_INT_TY]], [[WORKER_INT_TY]]* %[[WORKER_PTR_CST]]
// CHECK: call void @__cilkrts_leave_frame(
// CHECK: ret void

// CHECK-LABEL: define {{.*}}void @detectLocalizedCollisions.outline_det.achd.otd1(

// CHECK-LABEL: define {{.*}}void @detectLocalizedCollisions.outline_det.achd44.otd1(
