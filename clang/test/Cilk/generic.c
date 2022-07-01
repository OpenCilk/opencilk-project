// A comment line.
// RUN: %clang_cc1 %s -std=c11 -O1 -fopencilk -ftapir=none -verify -S -emit-llvm -o - | FileCheck %s
// XFAIL: *

#define ADD(SFX, T) \
  static void add_##SFX(void *l, void *r) { *(T *)l += *(T *)r; }
#define ZERO(SFX, T) \
  static void zero_##SFX(void *v) { *(T *)v = (T)0; }

ADD(sc, signed char)      ZERO(sc, signed char)
ADD(uc, unsigned char)    ZERO(uc, unsigned char)
ADD(ss, short)            ZERO(ss, short)
ADD(us, unsigned short)   ZERO(us, unsigned short)
ADD(si, int)              ZERO(si, int)
ADD(ui, unsigned int)     ZERO(ui, unsigned int)
ADD(sl, long)             ZERO(sl, long)
ADD(ul, unsigned long)    ZERO(ul, unsigned long)

ADD(f, float)             ZERO(f, float)
ADD(d, double)            ZERO(d, double)
ADD(ld, long double)      ZERO(ld, long double)

#define SELECT(PFX, T) \
  _Generic((T)0,              \
    signed char    : PFX##sc, \
    unsigned char  : PFX##uc, \
    short          : PFX##ss, \
    unsigned short : PFX##us, \
    int            : PFX##si,  \
    unsigned int   : PFX##ui,  \
    long           : PFX##sl,  \
    unsigned long  : PFX##ul,  \
    float          : PFX##f,  \
    double         : PFX##d,  \
    long double    : PFX##ld   \
)

#define ADD_REDUCER(T) \
  T _Hyperobject(SELECT(zero_, T), SELECT(add_, T))

// CHECK-LABEL: define_int_reducer
void define_int_reducer(long *out)
{
  // CHECK: call void @llvm.reducer.register.i64
  // CHECK: bitcast (void (i8*)* @zero_sl to i8*)
  // CHECK: bitcast (void (i8*, i8*)* @add_sl to i8*
  ADD_REDUCER(long) sum;
  _Cilk_for (int i = 0; i < 3900; ++i)
    sum += i;
  *out = sum;
  // CHECK: llvm.reducer.unregister
  // CHECK-NOT: llvm.reducer.unregister
}

// CHECK-LABEL: define_float_reducer
void define_float_reducer(float *out)
{
  // CHECK: call void @llvm.reducer.register.i64
  // CHECK: bitcast (void (i8*)* @zero_f to i8*)
  // CHECK: bitcast (void (i8*, i8*)* @add_f to i8*
  ADD_REDUCER(float) sum;
  _Cilk_for (int i = 0; i < 3900; ++i)
    sum += i;
  *out = sum;
  // CHECK: llvm.reducer.unregister
  // CHECK-NOT: llvm.reducer.unregister
}
