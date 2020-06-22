// RUN: %clang_cc1 -fsyntax-only -verify %s

extern int g(int);
extern int h(int, int, int, int, int);

void f(int x)
{
  h(g(x), _Cilk_spawn g(x), _Cilk_spawn g(x), g(x), g(x)); // expected-error{{multiple spawns among call arguments}}
  h(g(x), _Cilk_spawn g(x), _Cilk_spawn g(x), g(x), _Cilk_spawn g(x)); // expected-error{{multiple spawns among call arguments}} expected-note{{another spawn here}}
}
