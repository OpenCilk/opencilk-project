// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
struct __reducer_callbacks { int a, b, c; };

extern "C" void *__hyper_lookup_internal_1(void *, const __reducer_callbacks &)
  __attribute__((nonnull, returns_nonnull));

extern struct __reducer_callbacks *C;

extern __reducer_callbacks &cb();

struct S { };

void f()
{
  int cilk_reducer(nullptr) x;
  // expected-error@-1{{reference to type 'const __reducer_callbacks' could not bind to an rvalue of type 'std::nullptr_t'}}
  int cilk_reducer(C) y;
  // expected-error@-1{{reference to type 'const __reducer_callbacks' could not bind to an lvalue of type 'struct __reducer_callbacks *'}}
  int cilk_reducer(1) z;
  // expected-error@-1{{reference to type 'const __reducer_callbacks' could not bind to an rvalue of type 'int'}}
  int cilk_reducer b;
  // expected-error@-1{{view type must be a class when hyperobject has no callbacks}}
  S cilk_reducer c;
  // expected-warning@-1{{requires inclusion of the header <cilk/reducer>}}
  int cilk_reducer(cb()) d;
  // expected-warning@-1{{reducer callback has side effects}}
}

struct view { int field; };

extern "C" view *__hyper_lookup_class(view *)
  __attribute__((nonnull, returns_nonnull));

void g()
{
  int cilk_reducer a;
  // expected-error@-1{{view type must be a class when hyperobject has no callbacks}}
  S cilk_reducer b;
  // expected-error@-1{{cannot initialize a parameter of type 'view *' with an lvalue of type 'S *'}}
}
