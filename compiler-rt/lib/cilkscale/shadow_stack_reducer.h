// -*- C++ -*-
#ifndef INCLUDED_SHADOW_STACK_REDUCER_H
#define INCLUDED_SHADOW_STACK_REDUCER_H

#include <cassert>
#include <cstdlib>

#include <cilk/cilk.h>
#include <cilk/reducer.h>

#include "shadow_stack.h"

#ifndef TRACE_CALLS
#define TRACE_CALLS 0
#endif

class shadow_stack_monoid : public cilk::monoid_base<shadow_stack_t> {
public:
  static void identity(shadow_stack_t *view) {
    ::new((void*) view) shadow_stack_t(frame_type::SPAWNER);
  }

  static void reduce(shadow_stack_t *left, shadow_stack_t *right) {
    shadow_stack_frame_t &l_bot = left->peek_bot();
    shadow_stack_frame_t &r_bot = right->peek_bot();

    assert(frame_type::SPAWNER == r_bot.type);
    assert(0 == right->bot_index());

#if TRACE_CALLS
    fprintf(stderr, "left contin_work = %ld\nleft achild_work = %ld\n"
            "right contin_work = %ld\nright achild_work = %ld\n",
            l_bot.contin_work, l_bot.achild_work,
            r_bot.contin_work, r_bot.achild_work);
    fprintf(stderr, "left contin = %ld\nleft child = %ld\n"
            "\nright child = %ld\nright contin = %ld\n",
            l_bot.contin_span, l_bot.lchild_span,
            r_bot.lchild_span, r_bot.contin_span);
    fprintf(stderr, "left contin bspan = %ld\nleft child bspan = %ld\n"
            "\nright child bspan = %ld\nright contin bspan = %ld\n",
            l_bot.contin_bspan, l_bot.lchild_bspan,
            r_bot.lchild_bspan, r_bot.contin_bspan);
#endif

    // Add the work variables from the right stack into the left.
    l_bot.contin_work += r_bot.contin_work;
    l_bot.achild_work += r_bot.achild_work;

    // Add the continuation span from the right stack into the left.
    l_bot.contin_span += r_bot.contin_span;
    // If the left stack has a longer path from the root to the end of its
    // longest child, set this new span in keft.
    if (l_bot.contin_span + r_bot.lchild_span > l_bot.lchild_span) {
      l_bot.lchild_span = l_bot.contin_span + r_bot.lchild_span;
    }

    // Add the continuation span from the right stack into the left.
    l_bot.contin_bspan += r_bot.contin_bspan;
    // If the left stack has a longer path from the root to the end of its
    // longest child, set this new span in keft.
    if (l_bot.contin_bspan + r_bot.lchild_bspan > l_bot.lchild_bspan) {
      l_bot.lchild_bspan = l_bot.contin_bspan + r_bot.lchild_bspan;
    }
  }
};

class shadow_stack_reducer {
private:
  cilk::reducer<shadow_stack_monoid> m_imp;
  inline const cilk::reducer<shadow_stack_monoid> *get_m_imp() const {
    return &m_imp;
  }
  inline cilk::reducer<shadow_stack_monoid> *get_m_imp() {
    return &m_imp;
  }
public:
  shadow_stack_reducer() : m_imp() {}
  // shadow_stack_reducer(shadow_stack_t &&init) : m_imp(init) {}
  shadow_stack_reducer(cilk::move_in_wrapper<shadow_stack_t> w) : m_imp(w) {}

  shadow_stack_t &get_view() { return m_imp(); }
  const shadow_stack_t &get_view() const { return m_imp(); }

  void move_out(shadow_stack_t &obj) { obj.move_in(std::move(m_imp())); }

  shadow_stack_frame_t &peek_bot() const { return m_imp().peek_bot(); }
  shadow_stack_frame_t &push(frame_type type) { return m_imp().push(type); }
  shadow_stack_frame_t &pop() { return m_imp().pop(); }
};

#endif
