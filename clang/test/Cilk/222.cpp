// RUN: %clang_cc1 %s -x c++ -fopencilk -emit-llvm -verify -mllvm -use-opencilk-runtime-bc=false -mllvm -debug-abi-calls -o /dev/null
// expected-no-diagnostics
#define DEPTH 3
template<int N> struct R {
  static void identity(void *);
  static void reduce(void *, void *);
  int get(int depth) { return depth <= 0 ? i : field.get(depth - 1); }
public:
  R<N - 1> field;
  int _Hyperobject(identity, reduce) i;
};

template<> struct R<0> { int field; int get(int) { return field; } };

extern R<DEPTH> r;

int f() { return r.get(DEPTH / 2); }
