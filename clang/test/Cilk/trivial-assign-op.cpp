// RUN: %clang_cc1 -fcxx-exceptions -fexceptions -fcilkplus -ftapir=none -triple x86_64-unknown-linux-gnu -std=c++11 -emit-llvm %s -o - | FileCheck %s
// expected-no-diagnostics

struct event {
  float v;
  long p;
  event(float value, long index, bool type) 
    : v(value), p((index << 1) + type) {}
  event() {}
};

struct range {
  float min;
  float max;
  range(float _min, float _max) : min(_min), max(_max) {}
  range() {}
};

typedef range* Boxes[3];
typedef event* Events[3];
typedef range BoundingBox[3];

struct cutInfo {
  float cost;
  float cutOff;
  long numLeft;
  long numRight;
cutInfo(float _cost, float _cutOff, long nl, long nr) 
: cost(_cost), cutOff(_cutOff), numLeft(nl), numRight(nr) {}
  cutInfo() {}
};

cutInfo bestCut(event* E, range r, range r1, range r2, long n);

void generateNode(Boxes boxes, Events events, BoundingBox B,  long n,
                  int maxDepth) {
  cutInfo cuts[3];
  cuts[0] = _Cilk_spawn bestCut(events[0], B[0], B[(0+1)%3], B[(0+2)%3], n);
  cuts[1] = _Cilk_spawn bestCut(events[1], B[1], B[(1+1)%3], B[(1+2)%3], n);
  cuts[2] = _Cilk_spawn bestCut(events[2], B[2], B[(2+1)%3], B[(2+2)%3], n);
  _Cilk_sync;
}

// CHECK: define void @_Z12generateNodePP5rangePP5eventS0_li(
// CHECK: getelementptr inbounds [3 x %struct.cutInfo], [3 x %struct.cutInfo]* %cuts, i64 0, i64 0
// CHECK-NOT: call void @_Z7bestCutP5event5rangeS1_S1_l(
// CHECK: detach
// CHECK: call void @_Z7bestCutP5event5rangeS1_S1_l(
// CHECK: call void @llvm.memcpy
// CHECK: reattach
// CHECK: getelementptr inbounds [3 x %struct.cutInfo], [3 x %struct.cutInfo]* %cuts, i64 0, i64 1
// CHECK-NOT: call void @_Z7bestCutP5event5rangeS1_S1_l(
// CHECK: detach
// CHECK: call void @_Z7bestCutP5event5rangeS1_S1_l(
// CHECK: call void @llvm.memcpy
// CHECK: reattach
// CHECK: getelementptr inbounds [3 x %struct.cutInfo], [3 x %struct.cutInfo]* %cuts, i64 0, i64 2
// CHECK-NOT: call void @_Z7bestCutP5event5rangeS1_S1_l(
// CHECK: detach
// CHECK: call void @_Z7bestCutP5event5rangeS1_S1_l(
// CHECK: call void @llvm.memcpy
// CHECK: reattach
// CHECK: sync
