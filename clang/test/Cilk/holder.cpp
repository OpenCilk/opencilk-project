// RUN: %clang_cc1 %s -x c++ -triple aarch64-freebsd -fopencilk -verify -emit-llvm -disable-llvm-passes -o /dev/null
// if it doesn't crash, the test passes
// expected-no-diagnostics
namespace cilk {
template <typename A> static void holder_init_fn(void *view) { new (view) A; }
template <typename A> static void holder_reduce_fn(void *left, void *right) { }
template <typename A>
using holder = A cilk_reducer(holder_init_fn<A>, holder_reduce_fn<A>);
} // namespace cilk

struct IsStolen {
  bool flag = false;
  IsStolen(bool _flag = true);
};

template <class A>
void foo() {
  // Flag to detect when a steal occurs.
  cilk::holder<IsStolen> is_stolen = false;
}

int main() {
    foo<int>();
    return 0;
}
