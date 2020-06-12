#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// Ensure that __cilkscale__ is defined, so we can provide a nontrivial
// definition of getworkspan().
#ifndef __cilkscale__
#define __cilkscale__
#endif

#include "cilkscale_timer.h"
#include <csi/csi.h>
#include <iostream>
#include <fstream>

#define CILKTOOL_API extern "C" __attribute__((visibility("default")))

#ifndef SERIAL_TOOL
#define SERIAL_TOOL 1
#endif

#ifndef TRACE_CALLS
#define TRACE_CALLS 0
#endif

#if !SERIAL_TOOL
#include <cilk/cilk_api.h>
#include <cilk/reducer.h>
#include <cilk/reducer_ostream.h>
#endif

///////////////////////////////////////////////////////////////////////////
// Data structures for timing.

#if !SERIAL_TOOL
// Simple reducer for a cilkscale_timer.
//
// This reducer ensures that each stolen subcomputation gets a separate
// cilkscale_timer object for probing the computation.
class cilkscale_timer_monoid : public cilk::monoid_base<cilkscale_timer_t> {
public:
  static void reduce(cilkscale_timer_t *left, cilkscale_timer_t *right) {
    // Nothing to do
  }
};

class cilkscale_timer_reducer {
private:
  cilk::reducer<cilkscale_timer_monoid> m_imp;
  inline const cilk::reducer<cilkscale_timer_monoid> *get_m_imp() const {
    return &m_imp;
  }
  inline cilk::reducer<cilkscale_timer_monoid> *get_m_imp() {
    return &m_imp;
  }
public:
  cilkscale_timer_reducer() : m_imp() {}
  cilkscale_timer_reducer(const cilkscale_timer_t &timer) : m_imp(timer) {}

  cilkscale_timer_t &get_view() { return m_imp(); }
  const cilkscale_timer_t &get_view() const { return m_imp(); }

  void gettime() { m_imp().gettime(); }
  duration_t readtime() { return m_imp().readtime(); }
};
#endif

// Top-level class to manage the state of the global benchmarking tool.  This
// class interface allows the tool to initialize data structures, such as a
// std::ostream and a std::ofstream, only after the standard libraries they rely
// on have been initialized, and to destroy those structures before those
// libraries are deinitialized.
class BenchmarkImpl_t {
public:
  // Timer for tracking execution time.
  cilkscale_timer_t start, stop;
  cilkscale_timer_t timer;
#if !SERIAL_TOOL
  cilkscale_timer_reducer *timer_red = nullptr;
#endif

  std::ostream &outs = std::cout;
  std::ofstream outf;
#if !SERIAL_TOOL
  cilk::reducer<cilk::op_ostream> *outf_red = nullptr;
#endif

  BenchmarkImpl_t();
  ~BenchmarkImpl_t();

  // Callbacks run for initializing and deinitializing the tool state when the
  // OpenCilk runtime starts up and shuts down.
  void cilkify(void);
  void uncilkify(void);
};

// Top-level benchmarking tool.
static BenchmarkImpl_t tool;

// Macro to access the correct timer, based on the initialized state of the
// tool.
#if SERIAL_TOOL
#define TIMER (tool.timer)
#else
#define TIMER ((tool.timer_red) ? (tool.timer_red->get_view()) : (tool.timer))
#endif

// Macro to access the correct output stream, based on the initialized state of
// the tool.
#if SERIAL_TOOL
#define OUTPUT ((tool.outf.is_open()) ? (tool.outf) : (tool.outs))
#else
#define OUTPUT ((tool.outf_red) ? (**(tool.outf_red)) :                 \
                ((tool.outf.is_open()) ? (tool.outf) : (tool.outs)))
#endif

static bool TOOL_INITIALIZED = false;

///////////////////////////////////////////////////////////////////////////
// Routines to results

// Ensure that a proper header has been emitted to OS.
template<class Out>
static void ensure_header(Out &OS) {
  static bool PRINT_STARTED = false;
  if (PRINT_STARTED)
    return;

  OS << "tag,time (" << cilk_time_t::units << ")\n";

  PRINT_STARTED = true;
}

// Emit the given results to OS.
template<class Out>
static void print_results(Out &OS, const char *tag, cilk_time_t time) {
  OS << tag << "," << time << "\n";
}

// Emit the results from the overall program execution to the proper output
// stream.
static void print_analysis(void) {
  assert(TOOL_INITIALIZED);

  ensure_header(OUTPUT);
  print_results(OUTPUT, "", elapsed_time(&tool.stop, &tool.start));
}

///////////////////////////////////////////////////////////////////////////
// Startup and shutdown the tool

BenchmarkImpl_t::BenchmarkImpl_t() {
  const char *envstr = getenv("CILKSCALE_OUT");
  if (envstr)
    outf.open(envstr);

  TOOL_INITIALIZED = true;
  start.gettime();
}

BenchmarkImpl_t::~BenchmarkImpl_t() {
  stop.gettime();
  print_analysis();
  
  if (outf.is_open())
    outf.close();

  TOOL_INITIALIZED = false;
}

// Initialize tool state that depends on the Cilk runtime system.
void BenchmarkImpl_t::cilkify(void) {
#if TRACE_CALLS
  fprintf(stderr, "benchmark_cilkify\n");
#endif

#if !SERIAL_TOOL
  timer_red = new cilkscale_timer_reducer();
  outf_red = new cilk::reducer<cilk::op_ostream>(OUTPUT);
#endif
}

// Deinitialize tool state that depends on the Cilk runtime system.
void BenchmarkImpl_t::uncilkify(void) {
#if TRACE_CALLS
  fprintf(stderr, "benchmark_uncilkify\n");
#endif

#if !SERIAL_TOOL
  delete timer_red;
  timer_red = nullptr;
  delete outf_red;
  outf_red = nullptr;
#endif
}

///////////////////////////////////////////////////////////////////////////
// Hooks for operating the tool.

// Callback to initialze Cilk-runtime-dependent tool state when the Cilk runtime
// system starts.
void benchmark_cilkify(void) { tool.cilkify(); }

// Callback to deinitialze Cilk-runtime-dependent tool state when the Cilk
// runtime system stops.
void benchmark_uncilkify(void) { tool.uncilkify(); }

CILKTOOL_API void __csi_init() {
#if TRACE_CALLS
  fprintf(stderr, "__csi_init()\n");
#endif

#if !SERIAL_TOOL
  __cilkrts_atinit(benchmark_cilkify);
  __cilkrts_atexit(benchmark_uncilkify);
#endif
}

CILKTOOL_API void __csi_unit_init(const char *const file_name,
                                  const instrumentation_counts_t counts) {
  return;
}

///////////////////////////////////////////////////////////////////////////
// Probes and associated routines

CILKSCALE_EXTERN_C wsp_t getworkspan() CILKSCALE_NOTHROW {
  TIMER.gettime();
  duration_t time_since_start = elapsed_time(&TIMER, &tool.start);
  wsp_t result = { cilk_time_t(time_since_start).get_raw_duration(), 0, 0 };

  return result;
}

wsp_t operator+(wsp_t lhs, const wsp_t &rhs) {
  return { lhs.work + rhs.work, 0, 0 };
}

wsp_t operator-(wsp_t lhs, const wsp_t &rhs) {
  return { lhs.work - rhs.work, 0, 0 };
}

std::ostream &operator<<(std::ostream &OS, const wsp_t &pt) {
  OS << cilk_time_t(pt.work);
  return OS;
}

CILKSCALE_EXTERN_C wsp_t add(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW {
  lhs.work += rhs.work;
  return lhs;
}

CILKSCALE_EXTERN_C wsp_t sub(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW {
  lhs.work -= rhs.work;
  return lhs;
}

CILKSCALE_EXTERN_C void dump(wsp_t wsp, const char *tag) {
  ensure_header(OUTPUT);
  print_results(OUTPUT, tag, cilk_time_t(wsp.work));
}
