// -*- C++ -*-
#ifndef INCLUDED_CILK_CILKSAN_H
#define INCLUDED_CILK_CILKSAN_H

#ifdef __cplusplus

#define CILKSAN_EXTERN_C extern "C"
#define CILKSAN_NOTHROW noexcept

#else // #ifdef __cplusplus

#include <stdbool.h>

#define CILKSAN_EXTERN_C
#define CILKSAN_NOTHROW __attribute__((nothrow))

#endif // #ifdef __cplusplus


#ifdef __cilksan__

CILKSAN_EXTERN_C void __cilksan_enable_checking(void) CILKSAN_NOTHROW;
CILKSAN_EXTERN_C void __cilksan_disable_checking(void) CILKSAN_NOTHROW;
CILKSAN_EXTERN_C bool __cilksan_is_checking_enabled(void) CILKSAN_NOTHROW;

#else // #ifdef __cilksan__

CILKSAN_EXTERN_C void __cilksan_enable_checking(void) CILKSAN_NOTHROW {}
CILKSAN_EXTERN_C void __cilksan_disable_checking(void) CILKSAN_NOTHROW {}
CILKSAN_EXTERN_C bool __cilksan_is_checking_enabled(void) { return false; }

#endif // #ifdef __cilksan__

#endif // INCLUDED_CILK_CILKSAN_H
