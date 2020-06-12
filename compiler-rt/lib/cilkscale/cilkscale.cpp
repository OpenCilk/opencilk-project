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

// #include "cilkscale_internal.h"
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

extern int __cilkrts_get_worker_number(void);

///////////////////////////////////////////////////////////////////////////
// Data structures for tracking work and span.

class CilkscaleImpl_t {
public:
  shadow_stack_t *shadow_stack = nullptr;
#if !SERIAL_TOOL
  shadow_stack_reducer *shadow_stack_red = nullptr;
#endif

  std::ostream &outs = std::cout;
  std::ofstream outf;
#if !SERIAL_TOOL
  cilk::reducer<cilk::op_ostream> *outf_red = nullptr;
#endif

  CilkscaleImpl_t();
  ~CilkscaleImpl_t();

  void cilkify(void);
  void uncilkify(void);
};

CilkscaleImpl_t tool;

#if SERIAL_TOOL
#define STACK (*tool.shadow_stack)
#else
#define STACK ((tool.shadow_stack_red) ?                                \
               (tool.shadow_stack_red->get_view()) : (*tool.shadow_stack))
#endif

#if SERIAL_TOOL
#define OUTPUT ((tool.outf.is_open()) ? (tool.outf) : (tool.outs))
#else
#define OUTPUT ((tool.outf_red) ? (**(tool.outf_red)) :                 \
                ((tool.outf.is_open()) ? (tool.outf) : (tool.outs)))
#endif

bool TOOL_INITIALIZED = false;

///////////////////////////////////////////////////////////////////////////
// Utilities for printing analysis results

template<class Out>
void ensure_header(Out &OS) {
  static bool PRINT_STARTED = false;
  if (PRINT_STARTED)
    return;

  OS << "work (" << cilk_time_t::units << ")"
     << ", span (" << cilk_time_t::units << ")"
     << ", parallelism"
     << ", burdened_span (" << cilk_time_t::units << ")"
     << ", burdened_parallelism\n";

  PRINT_STARTED = true;
}

template<class Out>
void print_results(Out &OS, cilk_time_t work, cilk_time_t span,
                   cilk_time_t bspan) {
  OS << work << ", " << span << ", " << work.get_val_d() / span.get_val_d()
     << ", " << bspan << ", " << work.get_val_d() / bspan.get_val_d() << "\n";
}

void print_analysis(void) {
  assert(TOOL_INITIALIZED);
  shadow_stack_frame_t &bottom = STACK.peek_bot();

  assert(frame_type::NONE != bottom.type);

  cilk_time_t work = bottom.contin_work;
  cilk_time_t span = bottom.contin_span;
  cilk_time_t bspan = bottom.contin_bspan;

  ensure_header(OUTPUT);
  print_results(OUTPUT, work, span, bspan);
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

void cilkscale_cilkify(void) {
  tool.cilkify();
}

void cilkscale_uncilkify(void) {
  tool.uncilkify();
}

///////////////////////////////////////////////////////////////////////////
// CSI hooks for measuring work and span.

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
                           const csi_id_t detach_id) {
  // In the continuation
  shadow_stack_t &stack = STACK;

#if TRACE_CALLS
  fprintf(stderr, "detach_continue(%ld, %ld)\n", detach_continue_id, detach_id);
#endif

  shadow_stack_frame_t &bottom = stack.peek_bot();
  bottom.contin_bspan += cilkscale_timer_t::burden;

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

wsp_t getworkspan() CILKSCALE_NOTHROW {
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
     << ", " << bspan << ", " << work.get_val_d() / bspan.get_val_d() << "\n";

  stack.start.gettime();
  return OS;
}

CILKSCALE_EXTERN_C
wsp_t add(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW {
  lhs.work += rhs.work;
  lhs.span += rhs.span;
  lhs.bspan += rhs.bspan;
  return lhs;
}

CILKSCALE_EXTERN_C
wsp_t sub(wsp_t lhs, wsp_t rhs) CILKSCALE_NOTHROW {
  lhs.work -= rhs.work;
  lhs.span -= rhs.span;
  lhs.bspan -= rhs.bspan;
  return lhs;
}

CILKSCALE_EXTERN_C
void dump(wsp_t wsp) {
  shadow_stack_t &stack = STACK;

  stack.stop.gettime();

  shadow_stack_frame_t &bottom = stack.peek_bot();

  duration_t strand_time = elapsed_time(&(stack.stop), &(stack.start));
  // stack->running_work += strand_time;
  bottom.contin_work += strand_time;
  bottom.contin_span += strand_time;
  bottom.contin_bspan += strand_time;

  ensure_header(OUTPUT);
  print_results(OUTPUT, cilk_time_t(wsp.work), cilk_time_t(wsp.span),
                cilk_time_t(wsp.bspan));

  stack.start.gettime();
}
