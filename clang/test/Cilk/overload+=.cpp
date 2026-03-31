// RUN: %clang_cc1 %s -x c++ --std=c++14 -fopencilk -verify -fsyntax-only
// RUN: %clang_cc1 %s -x c++ --std=c++23 -fopencilk -verify -fsyntax-only
// expected-no-diagnostics
typedef unsigned long size_t;

struct reducer_base {
  reducer_base();
  virtual ~reducer_base();
};

extern "C" reducer_base *__hyper_lookup_class(const reducer_base *)
  __attribute__((nonnull, returns_nonnull));

struct wsp_t;
// This delaration was causing an error later on for no obvious reason.
wsp_t &operator+=(wsp_t &lhs, const wsp_t &rhs) noexcept;

template <typename T> struct opadd_hyper : public reducer_base {
  T value = 0;
  opadd_hyper(T value = 0);
  ~opadd_hyper() = default;
  opadd_hyper &operator+=(T v);
  operator T() const;
};

template <typename T>
T vecsum(const T &in) {
    extern opadd_hyper<T> cilk_reducer sum;
    sum += 1.0;
    return *&sum; // also a bug
}

void f() {
    (void)vecsum(1.9);
}
