// RUN: %clang_cc1 %s -x c++ --std=c++20 -fopencilk -verify -fsyntax-only
// expected-no-diagnostics
template<typename Data> class vector {
  using size_type = unsigned long;

  using pointer = Data *;

  pointer __begin_ = nullptr;

public:
  constexpr  explicit vector(size_type __n) {
    if (__n > 0) {
      __vallocate(__n);
    }
  }
  constexpr void __vallocate(size_type __n) {
    __begin_ = nullptr;
  }
  constexpr ~vector() { }
};

extern "C" void identity(void *);
extern "C" void reduce(void *, void *);

int main() {
  static vector<double> cilk_reducer(identity, reduce) foo(3);
  return 0;
}
