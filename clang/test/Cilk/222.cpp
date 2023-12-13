// RUN: %clang_cc1 %s -x c++ -fopencilk -emit-llvm -verify -mllvm -use-opencilk-runtime-bc=false -mllvm -debug-abi-calls -o /dev/null
#define DEPTH 3
template<int N> struct R {
  static void identity(void *);
  static void reduce(void *, void *);
  int get(int depth) { return depth <= 0 ? i : field.get(depth - 1); }
public:
  R<N - 1> field;
  // expected-note@-1{{in instantiation}}
  // expected-note@-2{{in instantiation}}
  // expected-note@-3{{in instantiation}}
  int _Hyperobject(identity, reduce) i;
  // expected-warning@-1{{reducer callbacks not implemented for structure members}}
  // expected-warning@-2{{reducer callbacks not implemented for structure members}}
  // expected-warning@-3{{reducer callbacks not implemented for structure members}}
};

template<> struct R<0> { int field; int get(int) { return field; } };

extern R<DEPTH> r;

int f() { return r.get(DEPTH / 2); }
// expected-note@-1{{in instantiation}}
// expected-note@-2{{in instantiation}}
// expected-note@-3{{in instantiation}}

