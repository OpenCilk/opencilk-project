// Make sure that hyperobject lookups are properly handled in a complex
// dependent context.
//
// Based on bug encountered with reducers in parlaylib.
//
// RUN: %clang_cc1 --std=c++20 %s -x c++ -O1 -fopencilk -verify -fsyntax-only
namespace std {
typedef __typeof__(sizeof(int)) size_t;
template <class T> struct remove_reference {
  typedef T type;
};
template <class T> struct remove_reference<T &> {
  typedef T type;
};
template <class T> struct remove_reference<T &&> {
  typedef T type;
};
template <typename T> typename remove_reference<T>::type &&move(T &&a);

/**
 *  @brief  Forward an lvalue.
 *  @return The parameter cast to the specified type.
 *
 *  This function is used to implement "perfect forwarding".
 */
template <typename _Tp>
constexpr _Tp &&
forward(typename std::remove_reference<_Tp>::type &__t) noexcept {
  return static_cast<_Tp &&>(__t);
}

/**
 *  @brief  Forward an rvalue.
 *  @return The parameter cast to the specified type.
 *
 *  This function is used to implement "perfect forwarding".
 */
template <typename _Tp>
constexpr _Tp &&
forward(typename std::remove_reference<_Tp>::type &&__t) noexcept {
  //   static_assert(!std::is_lvalue_reference<_Tp>::value,
  // "std::forward must not be used to convert an rvalue to an lvalue");
  return static_cast<_Tp &&>(__t);
}

template <class T>
using remove_reference_t = typename remove_reference<T>::type;

struct __is_transparent; // undefined

template <typename _Tp = void> struct plus;

template <typename _Tp> struct plus {
  /// Returns the sum
  constexpr _Tp operator()(const _Tp &__x, const _Tp &__y) const {
    return __x + __y;
  }
};

template <> struct plus<void> {
  template <typename _Tp, typename _Up>
  constexpr auto operator()(_Tp &&__t, _Up &&__u) const
      noexcept(noexcept(std::forward<_Tp>(__t) + std::forward<_Up>(__u)))
          -> decltype(std::forward<_Tp>(__t) + std::forward<_Up>(__u)) {
    return std::forward<_Tp>(__t) + std::forward<_Up>(__u);
  }

  typedef __is_transparent is_transparent;
};
} // namespace std

// Random-access iterable structure
struct C {
  C();
  struct It {
    int value;
    int operator-(It &);
    It operator+(int);
    It operator++();
    It operator--();
    int &operator*();
    bool operator!=(It &);
  };
  It begin() const;
  It end() const;
};

// Provides the member type T
template <typename T> struct type_identity {
  using type = T;
};

// Type trait for detecting the value type of a Monoid, denoted by the type of
// "identity"
template <typename Monoid_>
using monoid_value_type =
    type_identity<decltype(std::remove_reference_t<Monoid_>::identity)>;

// Returns the value type of the given Monoid, denoted by the type of "identity"
template <typename Monoid_>
using monoid_value_type_t = typename monoid_value_type<Monoid_>::type;

namespace cilk {
// Templated reducer class.
template <typename C, typename T> class reducer {
public:
  static void identity(void *v) = delete;
  static void reduce(void *l, void *r) = delete;
};

// Specialization for std::plus.
template <typename T> class reducer<std::plus<>, T> {
public:
  static void identity(void *v) { /*new (v) T{0};*/ }
  static void reduce(void *l, void *r) {
    *static_cast<T *>(l) =
        std::plus<>{}(*static_cast<T *>(l), *static_cast<T *>(r));
  }
};
} // namespace cilk

// Monoid definitions, based on parlaylib.
template <typename F, typename TT, typename = void> struct monoid {
  using T = TT;
  F f;
  T identity;
  monoid(F f, T id) : f(std::move(f)), identity(std::move(id)) {}
  template <typename T1, typename T2>
  decltype(auto) operator()(T1 &&x, T2 &&y) {
    return f(std::forward<T1>(x), std::forward<T2>(y));
  }
  using cilk_monoid = cilk::reducer<F, T>;
};

template <typename F, typename T> monoid<F, T> binary_op(F f, T id) {
  return monoid<F, T>(std::move(f), std::move(id));
}

// Reduce-like function, based on parlaylib, that performs a reduction on a
// container.
template <typename Seq, typename Monoid> auto foo(Seq const &A, Monoid &&m) {
  using T = monoid_value_type_t<Monoid>;
  using cilk_monoid = typename Monoid::cilk_monoid;
  T cilk_reducer(cilk_monoid::identity, cilk_monoid::reduce) r = m.identity;
  cilk_for(auto &x : A) { // expected-warning {{'cilk_for' support for for-range loops is currently experimental}}
    r = m(std::move(r), x);
  }
  return *&r;
}

int bar() {
  auto s = C();
  return foo(s, binary_op(std::plus<>{}, 0));
}
