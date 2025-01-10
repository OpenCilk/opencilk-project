// RUN: %clang_cc1 %s -std=c++20 -triple x86_64-unknown-linux-gnu -fopencilk -fsyntax-only -verify

template<class Datum>
struct Iterator {
  void *data;
  Iterator operator+(long);
  bool operator!=(const Iterator &) const;
  Iterator &operator++();
  Datum &operator*();
  Datum *operator->();
};

struct S {
  int data;
  struct I : public Iterator<S> {
    float operator-(const I &) const;
  };
  I begin(), end();
};

struct T {
  int data;
  struct I : public Iterator<T> {
    long operator-(const I &) const;
  };
  I begin(), end();
};

void sum(S &s, T &t) {
  _Cilk_for (auto i : s) { // expected-warning{{experimental}}
    // expected-error@-1{{cannot determine length}}
  }
  _Cilk_for (auto i : _Cilk_spawn t) { // expected-warning{{experimental}}
    // expected-error@-1{{'cilk_spawn' not allowed in this scope}}
  }
}
