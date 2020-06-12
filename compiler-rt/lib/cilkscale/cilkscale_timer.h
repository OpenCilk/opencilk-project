// -*- C++ -*-
#ifndef INCLUDED_CILKSCALE_TIMER_H
#define INCLUDED_CILKSCALE_TIMER_H

// #include <cilk/cilk_time.h>
#include <cilk/cilkscale.h>
#include <csi/csi.h>
#include <iostream>
#include <fstream>

#define RDTSC 1
#define CLOCK 2
// This timer is used by the cilkscale-instructions tool.
#define INST 3

#ifndef CSCALETIMER
// Valid cilkscale timer values are RDTSC, CLOCK, and INST
#define CSCALETIMER CLOCK
#endif

#if CSCALETIMER == RDTSC
#elif CSCALETIMER == CLOCK
#include <chrono>
#endif

///////////////////////////////////////////////////////////////////////////
// Data structures and helper methods for time of user strands.
#if CSCALETIMER == RDTSC || CSCALETIMER == INST
using duration_t = raw_duration_t;
#else // CSCALETIMER == CLOCK
using duration_t = std::chrono::nanoseconds;
#endif
static_assert(sizeof(duration_t) == sizeof(raw_duration_t),
              "Mistmatched sizes for time values.");

class cilk_time_t {
  duration_t val;

public:
  cilk_time_t(duration_t val) : val(val) {}
#if CSCALETIMER == CLOCK
  cilk_time_t(raw_duration_t val) : val(static_cast<duration_t>(val)) {}
#endif // CSCALETIMER
  ~cilk_time_t() = default;

  static cilk_time_t zero() {
#if CSCALETIMER == RDTSC || CSCALETIMER == INST
    return cilk_time_t(0);
#else // CSCALETIMER == CLOCK
    return cilk_time_t(duration_t::zero());
#endif // CSCALETIMER
  }

  friend bool operator==(const cilk_time_t &lhs, const duration_t &rhs) {
    return lhs.val == rhs;
  }
  friend bool operator>(const cilk_time_t &lhs, const duration_t &rhs) {
    return lhs.val > rhs;
  }
  friend cilk_time_t operator+(cilk_time_t lhs, const duration_t &rhs) {
    lhs.val += rhs;
    return lhs;
  }
  friend cilk_time_t operator-(cilk_time_t lhs, const duration_t &rhs) {
    lhs.val -= rhs;
    return lhs;
  }
  cilk_time_t &operator+=(const duration_t &rhs) {
    val += rhs;
    return *this;
  }
  cilk_time_t &operator-=(const duration_t &rhs) {
    val -= rhs;
    return *this;
  }

  friend bool operator==(const cilk_time_t &lhs, const cilk_time_t &rhs) {
    return lhs.val == rhs.val;
  }
  friend bool operator>(const cilk_time_t &lhs, const cilk_time_t &rhs) {
    return lhs.val > rhs.val;
  }

  friend cilk_time_t operator+(cilk_time_t lhs, const cilk_time_t &rhs) {
    lhs.val += rhs.val;
    return lhs;
  }
  friend cilk_time_t operator-(cilk_time_t lhs, const cilk_time_t &rhs) {
    lhs.val -= rhs.val;
    return lhs;
  }
  cilk_time_t &operator+=(const cilk_time_t &rhs) {
    val += rhs.val;
    return *this;
  }
  cilk_time_t &operator-=(const cilk_time_t &rhs) {
    val -= rhs.val;
    return *this;
  }

  raw_duration_t get_raw_duration() const {
#if CSCALETIMER == CLOCK
    return val.count();
#else // CSCALETIMER == RDTSC || CSCALETIMER == INST
    return val;
#endif // CSCALETIMER
  }

  double get_val_d() const {
#if CSCALETIMER == CLOCK
    using fraction_seconds = std::chrono::duration<double, std::ratio<1>>;
    return fraction_seconds(val).count();
#elif CSCALETIMER == RDTSC
    return (double)val;
#else // CSCALETIMER == INST
    return (double)val;
#endif // CSCALETIMER
  }

  static const double scale_factor;
  static const char *units;

  double get_scaled_val() const {
#if CSCALETIMER == CLOCK
    return get_val_d();
#else // CSCALETIMER == RDTSC || CSCALETIMER == INST
    return get_val_d() / scale_factor;
#endif // CSCALETIMER
  }

  friend std::ostream &operator<<(std::ostream &OS, const cilk_time_t &time) {
    OS << time.get_scaled_val();
    return OS;
  }
  friend std::ofstream &operator<<(std::ofstream &OS, const cilk_time_t &time) {
    OS << time.get_scaled_val();
    return OS;
  }
};

const char *cilk_time_t::units =
#if CSCALETIMER == RDTSC
    "Gcycles"
#elif CSCALETIMER == INST
    "Minstructions"
#else // CSCALETIMER == CLOCK
    "seconds"
#endif // CSCALETIMER
    ;

const double cilk_time_t::scale_factor =
#if CSCALETIMER == CLOCK
    1.0
#elif CSCALETIMER == RDTSC
    1000000000.0
#else // CSCALETIMER == INST
    1000000.0
#endif // CSCALETIMER
    ;

struct cilkscale_timer_t {
#if CSCALETIMER == RDTSC
  using timer_t = int64_t;
  using time_point_t = int64_t;
#elif CSCALETIMER == CLOCK
  using timer_t = std::chrono::steady_clock;
  using time_point_t = timer_t::time_point;
#else // CSCALETIMER == INST
  using timer_t = int64_t;
  using time_point_t = int64_t;
#endif // CSCALETIMER

  time_point_t time;

  cilkscale_timer_t() {}
  cilkscale_timer_t(const cilkscale_timer_t &copy) : time(copy.time) {}

  void gettime() {
#if CSCALETIMER == RDTSC
    time = __rdtsc();
#elif CSCALETIMER == CLOCK
    time = timer_t::now();
#else // CSCALETIMER == INST
    time = 0;
#endif // CSCALETIMER
  }

  duration_t readtime() {
#if CSCALETIMER == INST
  return time;
#elif CSCALETIMER == CLOCK
  return std::chrono::duration_cast<duration_t>(time.time_since_epoch());
#else
  return time;
#endif
  }

  static duration_t burden;
};

duration_t cilkscale_timer_t::burden =
#if CSCALETIMER == RDTSC
      15000
#elif CSCALETIMER == CLOCK
      std::chrono::nanoseconds(6250)
#else // CSCALETIMER == INST
      6250
#endif // CSCALETIMER
      ;

static duration_t elapsed_time(const cilkscale_timer_t *stop,
                               const cilkscale_timer_t *start) {
#if CSCALETIMER == INST
  return 0;
#elif CSCALETIMER == CLOCK
  return std::chrono::duration_cast<duration_t>(stop->time - start->time);
#else
  return stop->time - start->time;
#endif
}

static inline void get_bb_time(cilk_time_t *work, cilk_time_t *span,
                               cilk_time_t *bspan, const csi_id_t bb_id) {
#if CSCALETIMER == INST
  duration_t inst_count = static_cast<duration_t>(
      __csi_get_bb_sizeinfo(bb_id)->ir_cost);
  *work += inst_count;
  *span += inst_count;
  *bspan += inst_count;
#endif
}

#endif // INCLUDED_CILKSCALE_TIMER_H
