// RUN: %clang_cc1 %s -x c++ -O1 -fopencilk -verify -fsyntax-only
// expected-no-diagnostics

# 1 "/usr/obj/Cilk/16/lib/clang/16/include/cilk/opadd_reducer.h" 1 3





namespace cilk {

template <typename T> static void zero(void *v) {
    *static_cast<T *>(v) = static_cast<T>(0);
}

template <typename T> static void plus(void *l, void *r) {
    *static_cast<T *>(l) += *static_cast<T *>(r);
}

template <typename T> using opadd_reducer = T _Hyperobject(zero<T>, plus<T>);

}
# 4 "../reducer-tests/addressof-test.cpp" 2



template <class scalar_t>
scalar_t reduce_test() {
  cilk::opadd_reducer<scalar_t> res = 0;
  return *&res;
}



int foo(long var) {
  long *t = __builtin_addressof(*&var);
  return 0;
}
