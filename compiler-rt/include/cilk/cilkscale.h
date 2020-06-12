// -*- C++ -*-
#ifndef INCLUDED_CILK_CILKSCALE_H
#define INCLUDED_CILK_CILKSCALE_H

#ifdef __cplusplus
#include <cstdint>
#else // __cplusplus
#include <stdint.h>
#endif // __cplusplus

typedef int64_t raw_duration_t;
typedef struct wsp_t {
  raw_duration_t work;
  raw_duration_t span;
  raw_duration_t bspan;
} wsp_t;

#ifdef __cplusplus

#include <iostream>

#define CILKSCALE_EXTERN_C extern "C"
#define CILKSCALE_NOTHROW noexcept

wsp_t operator+(wsp_t lhs, const wsp_t &rhs) noexcept;
wsp_t operator-(wsp_t lhs, const wsp_t &rhs) noexcept;
std::ostream &operator<<(std::ostream &os, const wsp_t &pt);

#ifndef __cilkscale__
// Default implementations when the program is not compiled with Cilkscale.
wsp_t operator+(wsp_t lhs, const wsp_t &rhs) noexcept {
  wsp_t res = {0, 0, 0};
  return res;
}

wsp_t operator-(wsp_t lhs, const wsp_t &rhs) noexcept {
  wsp_t res = {0, 0, 0};
  return res;
}

std::ostream &operator<<(std::ostream &os, const wsp_t &pt) {
  return os;
}
#endif // #ifndef __cilkscale__

#else // #ifdef __cplusplus

#define CILKSCALE_EXTERN_C
#define CILKSCALE_NOTHROW __attribute__((nothrow))

#endif // #ifdef __cplusplus

CILKSCALE_EXTERN_C
wsp_t add(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW;

CILKSCALE_EXTERN_C
wsp_t sub(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW;

CILKSCALE_EXTERN_C
void dump(wsp_t wsp, const char *tag);

#ifndef __cilkscale__

// Default implementations when the program is not compiled with Cilkscale.
CILKSCALE_EXTERN_C wsp_t getworkspan() CILKSCALE_NOTHROW {
  wsp_t res = {0, 0};
  return res;
}

CILKSCALE_EXTERN_C
wsp_t add(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW {
  wsp_t res = {0, 0, 0};
  return res;
}

CILKSCALE_EXTERN_C
wsp_t sub(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW {
  wsp_t res = {0, 0, 0};
  return res;
}

CILKSCALE_EXTERN_C
void dump(wsp_t wsp, const char *tag) {
  return;
}
#else
CILKSCALE_EXTERN_C wsp_t getworkspan() CILKSCALE_NOTHROW;
#endif // #ifndef __cilkscale__

#endif // INCLUDED_CILK_CILKSCALE_H
