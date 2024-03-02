// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
// expected-no-diagnostics

typedef long long int64_t;

template <bool transpose>
__attribute__((always_inline)) static int64_t a_index(int64_t ii, int64_t m,
                                                      int64_t jj, int64_t n) {
  return transpose ? ((jj * m) + ii) : ((ii * n) + jj);
}

#define ARG_INDEX(arg, ii, m, jj, n, transpose)                                \
  (arg[a_index<transpose>(ii, m, jj, n)])

template <typename F>
void matmul_ploops(F *__restrict__ out, const F *__restrict__ lhs,
		   const F *__restrict__ rhs, int64_t m, int64_t n,
		   int64_t k) {
  _Cilk_for(int64_t i = 0; i < m; ++i) {
    _Cilk_for(int64_t j = 0; j < n; ++j) {
      out[j * m + i] = 0.0;
      for (int64_t l = 0; l < k; ++l)
	out[j * m + i] += ARG_INDEX(lhs, l, k, i, m, true) *
	  ARG_INDEX(rhs, j, n, l, k, true);
    }
  }
}

template void matmul_ploops<float>(float *__restrict__ out,
                                   const float *__restrict__ lhs,
                                   const float *__restrict__ rhs, int64_t m,
                                   int64_t n, int64_t k);
