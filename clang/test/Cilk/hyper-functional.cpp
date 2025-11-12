// RUN: %clang_cc1 %s -xc++ -fopencilk -verify -fsyntax-only
// expected-no-diagnostics

struct __reducer_base { int a, b, c; };
struct __reducer_callbacks { int d, e, f; };

extern "C" __reducer_base *__hyper_lookup_class(__reducer_base *);
extern "C" void *__hyper_lookup_internal_1(void *, const __reducer_callbacks &);

struct Extra { int d; };

// Callback at nonzero offset
struct C1 : Extra, __reducer_callbacks { int e; };
//
struct C2 : Extra, virtual __reducer_callbacks { int f; };

extern C1 C1;
extern C2 *C2;

void f()
{
  int cilk_reducer(C1) x;
  int cilk_reducer(*C2) y2;
  int cilk_reducer(__reducer_callbacks{0,1,2}) a;
}
