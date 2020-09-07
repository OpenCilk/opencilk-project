#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>

// Ensure that __cilkscale__ is defined, so we can provide a nontrivial
// definition of getworkspan().
#ifndef __cilkscale__
#define __cilkscale__
#endif

#include "shadow_stack.h"
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
#include "shadow_stack_reducer.h"
#include <cilk/cilk_api.h>
#include <cilk/reducer.h>
#include <cilk/reducer_ostream.h>
#endif

///////////////////////////////////////////////////////////////////////////
// Data structures for tracking work and span.

// Top-level class to manage the state of the global Cilkscale tool.  This class
// interface allows the tool to initialize data structures, such as a
// std::ostream and a std::ofstream, only after the standard libraries they rely
// on have been initialized, and to destroy those structures before those
// libraries are deinitialized.
class CilkscaleImpl_t {
public:
  // Shadow-stack data structure, for managing work-span variables.
  shadow_stack_t *shadow_stack = nullptr;
#if !SERIAL_TOOL
  shadow_stack_reducer *shadow_stack_red = nullptr;
#endif

  // Output stream for printing results.
  std::ostream &outs = std::cout;
  std::ofstream outf;
#if !SERIAL_TOOL
  cilk::reducer<cilk::op_ostream> *outf_red = nullptr;
#endif

  CilkscaleImpl_t();
  ~CilkscaleImpl_t();

  // Callbacks run for initializing and deinitializing the tool state when the
  // OpenCilk runtime starts up and shuts down.
  void cilkify(void);
  void uncilkify(void);
};

// Top-level Cilkscale tool.
static CilkscaleImpl_t tool;

// Macro to access the correct shadow-stack data structure, based on the
// initialized state of the tool.
#if SERIAL_TOOL
#define STACK (*tool.shadow_stack)
#else
#define STACK ((tool.shadow_stack_red) ?                                \
               (tool.shadow_stack_red->get_view()) : (*tool.shadow_stack))
#endif

// Macro to use the correct output stream, based on the initialized state of the
// tool.
#if SERIAL_TOOL
#define OUTPUT ((tool.outf.is_open()) ? (tool.outf) : (tool.outs))
#else
#define OUTPUT ((tool.outf_red) ? (**(tool.outf_red)) :                 \
                ((tool.outf.is_open()) ? (tool.outf) : (tool.outs)))
#endif

static bool TOOL_INITIALIZED = false;

///////////////////////////////////////////////////////////////////////////
// Utilities for printing analysis results

// Ensure that a proper header has been emitted to OS.
template<class Out>
static void ensure_header(Out &OS) {
  static bool PRINT_STARTED = false;
  if (PRINT_STARTED)
    return;

  OS << "tag,work (" << cilk_time_t::units << ")"
     << ",span (" << cilk_time_t::units << ")"
     << ",parallelism"
     << ",burdened_span (" << cilk_time_t::units << ")"
     << ",burdened_parallelism\n";

  PRINT_STARTED = true;
}

// Emit the given results to OS.
template<class Out>
static void print_results(Out &OS, const char *tag, cilk_time_t work,
                          cilk_time_t span, cilk_time_t bspan) {
  OS << tag
     << "," << work << "," << span << "," << work.get_val_d() / span.get_val_d()
     << "," << bspan << "," << work.get_val_d() / bspan.get_val_d() << "\n";
}

// Emit the results from the overall program execution to the proper output
// stream.
static void print_analysis(void) {
  assert(TOOL_INITIALIZED);
  shadow_stack_frame_t &bottom = STACK.peek_bot();

  assert(frame_type::NONE != bottom.type);

  cilk_time_t work = bottom.contin_work;
  cilk_time_t span = bottom.contin_span;
  cilk_time_t bspan = bottom.contin_bspan;

  ensure_header(OUTPUT);
  print_results(OUTPUT, "", work, span, bspan);
}

///////////////////////////////////////////////////////////////////////////
// Tool startup and shutdown

#if SERIAL_TOOL
// Ensure that this tool is run serially
static inline void ensure_serial_tool(void) {
  // assert(1 == __cilkrts_get_nworkers());
  fprintf(stderr, "Forcing CILK_NWORKERS=1.\n");
  char *e = getenv("CILK_NWORKERS");
  if (!e || 0 != strcmp(e, "1")) {
    // fprintf(err_io, "Setting CILK_NWORKERS to be 1\n");
    if (setenv("CILK_NWORKERS", "1", 1)) {
      fprintf(stderr, "Error setting CILK_NWORKERS to be 1\n");
      exit(1);
    }
  }
}
#endif

CilkscaleImpl_t::CilkscaleImpl_t() {
  shadow_stack = new shadow_stack_t(frame_type::MAIN);

  const char *envstr = getenv("CILKSCALE_OUT");
  if (envstr)
    outf.open(envstr);

  TOOL_INITIALIZED = true;

  shadow_stack->push(frame_type::SPAWNER);
  shadow_stack->start.gettime();
}

CilkscaleImpl_t::~CilkscaleImpl_t() {
  shadow_stack->stop.gettime();
  shadow_stack_frame_t &bottom = shadow_stack->peek_bot();

  duration_t strand_time = elapsed_time(&(shadow_stack->stop),
                                        &(shadow_stack->start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  print_analysis();

  if (outf.is_open())
    outf.close();
  delete shadow_stack;

  TOOL_INITIALIZED = false;
}

// Initialize tool state that depends on the Cilk runtime system.
void CilkscaleImpl_t::cilkify(void) {
#if TRACE_CALLS
  fprintf(stderr, "cilkscale_cilkify\n");
#endif

#if !SERIAL_TOOL
  shadow_stack->stop.gettime();
  shadow_stack_frame_t &bottom = shadow_stack->peek_bot();

  duration_t strand_time = elapsed_time(&(shadow_stack->stop),
                                        &(shadow_stack->start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  shadow_stack_red = new shadow_stack_reducer(cilk::move_in(*shadow_stack));
  shadow_stack_red->get_view().start.gettime();

  outf_red = new cilk::reducer<cilk::op_ostream>(OUTPUT);
#endif
}

// Deinitialize tool state that depends on the Cilk runtime system.
void CilkscaleImpl_t::uncilkify(void) {
#if TRACE_CALLS
  fprintf(stderr, "cilkscale_uncilkify\n");
#endif

#if !SERIAL_TOOL
  STACK.stop.gettime();
  shadow_stack_frame_t &bottom = STACK.peek_bot();

  duration_t strand_time = elapsed_time(&(STACK.stop),
                                        &(STACK.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  // shadow_stack_red->move_out(*shadow_stack);
  shadow_stack->move_in(std::move(shadow_stack_red->get_view()));
  delete shadow_stack_red;
  shadow_stack_red = nullptr;

  delete outf_red;
  outf_red = nullptr;

  shadow_stack->start.gettime();
#endif
}

///////////////////////////////////////////////////////////////////////////
// Hooks for operating the tool.

// Callback to initialze Cilk-runtime-dependent tool state when the Cilk runtime
// system starts.
void cilkscale_cilkify(void) { tool.cilkify(); }

// Callback to deinitialze Cilk-runtime-dependent tool state when the Cilk
// runtime system stops.
void cilkscale_uncilkify(void) { tool.uncilkify(); }

CILKTOOL_API void __csi_init() {
#if TRACE_CALLS
  fprintf(stderr, "__csi_init()\n");
#endif

#if SERIAL_TOOL
  ensure_serial_tool();
#else
  __cilkrts_atinit(cilkscale_cilkify);
  __cilkrts_atexit(cilkscale_uncilkify);
#endif
}

CILKTOOL_API void __csi_unit_init(const char *const file_name,
                                  const instrumentation_counts_t counts) {
  return;
}

CILKTOOL_API
void __csi_bb_entry(const csi_id_t bb_id, const bb_prop_t prop) {
  if (!TOOL_INITIALIZED)
    return;

  shadow_stack_t &stack = STACK;

  shadow_stack_frame_t &bottom = stack.peek_bot();
  get_bb_time(&bottom.contin_work, &bottom.contin_span, &bottom.contin_bspan,
              bb_id);
  return;
}

CILKTOOL_API
void __csi_bb_exit(const csi_id_t bb_id, const bb_prop_t prop) { return; }

CILKTOOL_API
void __csi_func_entry(const csi_id_t func_id, const func_prop_t prop) {
  if (!TOOL_INITIALIZED)
    return;
  if (!prop.may_spawn)
    return;

  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

#if TRACE_CALLS
  fprintf(stderr, "func_entry(%ld)\n", func_id);
#endif

  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  shadow_stack_frame_t &p_bottom = stack.peek_bot();
  // Push new frame onto the stack
  shadow_stack_frame_t &c_bottom = stack.push(frame_type::SPAWNER);
  c_bottom.contin_work = p_bottom.contin_work;
  c_bottom.contin_span = p_bottom.contin_span;
  c_bottom.contin_bspan = p_bottom.contin_bspan;

  // stack.start.gettime();
  // Because of the high overhead of calling gettime(), especially compared to
  // the running time of the operations in this hook, the work and span
  // measurements appear more stable if we simply use the recorded time as the
  // new start time.
  stack.start = stack.stop;
}

CILKTOOL_API
void __csi_func_exit(const csi_id_t func_exit_id, const csi_id_t func_id,
                     const func_exit_prop_t prop) {
  if (!TOOL_INITIALIZED)
    return;
  if (!prop.may_spawn)
    return;

  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

#if TRACE_CALLS
  fprintf(stderr, "func_exit(%ld)\n", func_id);
#endif

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;

  assert(cilk_time_t::zero() == stack.peek_bot().lchild_span);

  // Pop the stack
  shadow_stack_frame_t &c_bottom = stack.pop();
  shadow_stack_frame_t &p_bottom = stack.peek_bot();

  p_bottom.contin_work = c_bottom.contin_work + strand_time;
  p_bottom.contin_span = c_bottom.contin_span + strand_time;
  p_bottom.contin_bspan = c_bottom.contin_bspan + strand_time;

  // stack.start.gettime();
  // Because of the high overhead of calling gettime(), especially compared to
  // the running time of the operations in this hook, the work and span
  // measurements appear more stable if we simply use the recorded time as the
  // new start time.
  stack.start = stack.stop;
}

CILKTOOL_API
void __csi_detach(const csi_id_t detach_id, const int32_t *has_spawned) {
  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

#if TRACE_CALLS
  fprintf(stderr, "[W%d] detach(%ld)\n", __cilkrts_get_worker_number(), detach_id);
#endif

  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;
}

CILKTOOL_API
void __csi_task(const csi_id_t task_id, const csi_id_t detach_id,
                const task_prop_t prop) {
  shadow_stack_t &stack = STACK;

#if TRACE_CALLS
  fprintf(stderr, "task(%ld, %ld)\n", task_id, detach_id);
#endif

  shadow_stack_frame_t &p_bottom = stack.peek_bot();
  // Push new frame onto the stack.
  shadow_stack_frame_t &c_bottom = stack.push(frame_type::HELPER);
  c_bottom.contin_work = p_bottom.contin_work;
  c_bottom.contin_span = p_bottom.contin_span;
  c_bottom.contin_bspan = p_bottom.contin_bspan;

  stack.start.gettime();
}

CILKTOOL_API
void __csi_task_exit(const csi_id_t task_exit_id, const csi_id_t task_id,
                     const csi_id_t detach_id, const task_exit_prop_t prop) {
  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

#if TRACE_CALLS
  fprintf(stderr, "task_exit(%ld, %ld, %ld)\n", task_exit_id, task_id,
          detach_id);
#endif

  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;

  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  assert(cilk_time_t::zero() == bottom.lchild_span);

  // Pop the stack
  shadow_stack_frame_t &c_bottom = stack.pop();
  shadow_stack_frame_t &p_bottom = stack.peek_bot();
  p_bottom.achild_work += c_bottom.contin_work - p_bottom.contin_work;
  // Check if the span of c_bottom exceeds that of the previous longest child.
  if (c_bottom.contin_span > p_bottom.lchild_span)
    p_bottom.lchild_span = c_bottom.contin_span;
  if (c_bottom.contin_bspan + cilkscale_timer_t::burden
      > p_bottom.lchild_bspan)
    p_bottom.lchild_bspan = c_bottom.contin_bspan + cilkscale_timer_t::burden;
}

CILKTOOL_API
void __csi_detach_continue(const csi_id_t detach_continue_id,
                           const csi_id_t detach_id,
                           const detach_continue_prop_t prop) {
  // In the continuation
  shadow_stack_t &stack = STACK;

#if TRACE_CALLS
  fprintf(stderr, "detach_continue(%ld, %ld, %ld)\n", detach_continue_id,
          detach_id, prop);
#endif

  shadow_stack_frame_t &bottom = stack.peek_bot();

  if (prop.is_unwind) {
    // In opencilk, upon reaching the unwind destination of a detach, all
    // spawned child computations have been synced.  Hence we replicate the
    // logic from after_sync here to compute work and span.

    // Add achild_work to contin_work, and reset contin_work.
    bottom.contin_work += bottom.achild_work;
    bottom.achild_work = cilk_time_t::zero();

    // Select the largest of lchild_span and contin_span, and then reset
    // lchild_span.
    if (bottom.lchild_span > bottom.contin_span)
      bottom.contin_span = bottom.lchild_span;
    bottom.lchild_span = cilk_time_t::zero();

    if (bottom.lchild_bspan > bottom.contin_bspan)
      bottom.contin_bspan = bottom.lchild_bspan;
    bottom.lchild_bspan = cilk_time_t::zero();
  } else {
    bottom.contin_bspan += cilkscale_timer_t::burden;
  }

  stack.start.gettime();
}

CILKTOOL_API
void __csi_before_sync(const csi_id_t sync_id, const int32_t *has_spawned) {
  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

#if TRACE_CALLS
  fprintf(stderr, "before_sync(%ld)\n", sync_id);
#endif

  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;
}

CILKTOOL_API
void __csi_after_sync(const csi_id_t sync_id, const int32_t *has_spawned) {
  shadow_stack_t &stack = STACK;

#if TRACE_CALLS
  fprintf(stderr, "after_sync(%ld)\n", sync_id);
#endif

  shadow_stack_frame_t &bottom = stack.peek_bot();
  // Update the work and span recorded for the bottom-most frame on the stack.

  // Add achild_work to contin_work, and reset contin_work.
  bottom.contin_work += bottom.achild_work;
  bottom.achild_work = cilk_time_t::zero();

  // Select the largest of lchild_span and contin_span, and then reset
  // lchild_span.
  if (bottom.lchild_span > bottom.contin_span)
    bottom.contin_span = bottom.lchild_span;
  bottom.lchild_span = cilk_time_t::zero();

  if (bottom.lchild_bspan > bottom.contin_bspan)
    bottom.contin_bspan = bottom.lchild_bspan;
  bottom.lchild_bspan = cilk_time_t::zero();

  stack.start.gettime();
}

///////////////////////////////////////////////////////////////////////////
// Probes and associated routines

CILKSCALE_EXTERN_C wsp_t wsp_getworkspan() CILKSCALE_NOTHROW {
  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

#if TRACE_CALLS
  fprintf(stderr, "getworkspan()\n");
#endif
  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  wsp_t result = { stack.peek_bot().contin_work.get_raw_duration(),
                   stack.peek_bot().contin_span.get_raw_duration(),
                   stack.peek_bot().contin_bspan.get_raw_duration() };

  // Because of the high overhead of calling gettime(), especially compared to
  // the running time of the operations in this hook, the work and span
  // measurements appear more stable if we simply use the recorded time as the
  // new start time.
  stack.start = stack.stop;

  return result;
}

wsp_t operator+(wsp_t lhs, const wsp_t &rhs) {
  return { lhs.work + rhs.work, lhs.span + rhs.span, lhs.bspan + rhs.bspan };
}

wsp_t operator-(wsp_t lhs, const wsp_t &rhs) {
  return { lhs.work - rhs.work, lhs.span - rhs.span, lhs.bspan - rhs.bspan };
}

std::ostream &operator<<(std::ostream &OS, const wsp_t &pt) {
  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  cilk_time_t work = cilk_time_t(pt.work);
  cilk_time_t span = cilk_time_t(pt.span);
  cilk_time_t bspan = cilk_time_t(pt.bspan);
  OS << work << ", " << span << ", " << work.get_val_d() / span.get_val_d()
     << ", " << bspan << ", " << work.get_val_d() / bspan.get_val_d();

  stack.start.gettime();
  return OS;
}

std::ofstream &operator<<(std::ofstream &OS, const wsp_t &pt) {
  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  cilk_time_t work = cilk_time_t(pt.work);
  cilk_time_t span = cilk_time_t(pt.span);
  cilk_time_t bspan = cilk_time_t(pt.bspan);
  OS << work << ", " << span << ", " << work.get_val_d() / span.get_val_d()
     << ", " << bspan << ", " << work.get_val_d() / bspan.get_val_d();

  stack.start.gettime();
  return OS;
}

CILKSCALE_EXTERN_C wsp_t wsp_add(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW {
  lhs.work += rhs.work;
  lhs.span += rhs.span;
  lhs.bspan += rhs.bspan;
  return lhs;
}

CILKSCALE_EXTERN_C wsp_t wsp_sub(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW {
  lhs.work -= rhs.work;
  lhs.span -= rhs.span;
  lhs.bspan -= rhs.bspan;
  return lhs;
}

CILKSCALE_EXTERN_C void wsp_dump(wsp_t wsp, const char *tag) {
  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  ensure_header(OUTPUT);
  print_results(OUTPUT, tag, cilk_time_t(wsp.work), cilk_time_t(wsp.span),
                cilk_time_t(wsp.bspan));

  stack.start.gettime();
}
