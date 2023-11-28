#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <sstream>
#include <unordered_map>
#include <vector>

#include <execinfo.h>
#include <inttypes.h>

#include "cilksan_internal.h"
#include "debug_util.h"
#include "disjointset.h"
#include "frame_data.h"
#include "mem_access.h"
#include "race_detect_update.h"
#include "shadow_mem.h"
#include "spbag.h"
#include "stack.h"

#if CILKSAN_DEBUG
enum EventType_t last_event = NONE;
#endif

static bool CILKSAN_INITIALIZED = false;

// declared in driver.cpp
extern FILE *err_io;
// declared in print_addr.cpp
extern uintptr_t *load_pc;
extern uintptr_t *store_pc;

// --------------------- stuff from racedetector ---------------------------

// -------------------------------------------------------------------------
//  Analysis data structures and fields
// -------------------------------------------------------------------------

// List used for the disjoint set data structure's find_set operation.
List_t disjoint_set_list;

#if CILKSAN_DEBUG
template<>
long DisjointSet_t<SPBagInterface *>::debug_count = 0;

long SBag_t::debug_count = 0;
long PBag_t::debug_count = 0;
#endif

void free_bag(DisjointSet_t<SPBagInterface *> *ptr) {
  // TODO(ddoucet): ......
  // delete ptr->get_node();
  // TODO(denizokt): temporary fix, but introduces memory leak
  delete ptr->get_my_set_node();
}

template<>
void (*DisjointSet_t<SPBagInterface *>::dtor_callback)(DisjointSet_t *) =
  &free_bag;

// Free list for disjoint-set nodes
template<>
DisjointSet_t<SPBagInterface *> *
DisjointSet_t<SPBagInterface *>::free_list = nullptr;

// Free lists for SBags and PBags
SBag_t::FreeNode_t *SBag_t::free_list = nullptr;
PBag_t::FreeNode_t *PBag_t::free_list = nullptr;

// Code to handle references to the stack.
// range of stack used by the process
uint64_t stack_low_addr = 0;
uint64_t stack_high_addr = 0;

// small helper functions
static inline bool is_on_stack(uintptr_t addr) {
  cilksan_assert(stack_high_addr != stack_low_addr);
  return (addr <= stack_high_addr && addr >= stack_low_addr);
}

// ANGE: Each function that causes a Disjoint set to be created has a
// unique ID (i.e., Cilk function and spawned C function).
// If a spawned function is also a Cilk function, a Disjoint Set is created
// for code between the point where detach finishes and the point the Cilk
// function calls enter_frame, which may be unnecessary in some case.
// (But potentially necessary in the case where the base case is executed.)
static uint64_t frame_id = 0;

// Data associated with the stack of Cilk frames or spawned C frames.
// head contains the SP bags for the function we are currently processing
static Stack_t<FrameData_t> frame_stack;
call_stack_t call_stack;
Stack_t<uintptr_t> sp_stack;

// Free list for call-stack nodes
call_stack_node_t *call_stack_node_t::free_list = nullptr;

// Shadow memory, or the unordered hashmap that maps a memory address to its
// last reader and writer
Shadow_Memory shadow_memory;

// extern functions, defined in print_addr.cpp
extern void print_race_report();
extern int get_num_races_found();


////////////////////////////////////////////////////////////////////////
// Events functions
////////////////////////////////////////////////////////////////////////

/// Helper function for merging returning child's bag into parent's
static inline void merge_bag_from_returning_child(bool returning_from_detach) {
  FrameData_t *parent = frame_stack.ancestor(1);
  FrameData_t *child = frame_stack.head();
  cilksan_assert(parent->Sbag);
  cilksan_assert(child->Sbag);
  // cilksan_assert(!child->Pbag);

  if (returning_from_detach) {
    // We are returning from a detach.  Merge the child S- and P-bags
    // into the parent P-bag.
    DBG_TRACE(DEBUG_BAGS,
        "Merge S-bag from detached child %ld to P-bag from parent %ld.\n",
        child->Sbag->get_set_node()->get_func_id(),
        parent->Sbag->get_set_node()->get_func_id());

    // Get the parent P-bag.
    DisjointSet_t<SPBagInterface *> *parent_pbag = parent->Pbag;
    if (!parent_pbag) { // lazily create PBag when needed
      DBG_TRACE(DEBUG_BAGS,
		"frame %ld creates a PBag ",
		parent->Sbag->get_set_node()->get_func_id());
      parent_pbag =
	new DisjointSet_t<SPBagInterface *>(new PBag_t(parent->Sbag->get_node()));
      parent->set_pbag(parent_pbag);
      DBG_TRACE(DEBUG_BAGS, "%p\n", parent_pbag);
    }

    cilksan_assert(parent_pbag && parent_pbag->get_set_node()->is_PBag());
    // Combine child S-bag into parent P-bag.
    cilksan_assert(child->Sbag->get_set_node()->is_SBag());
    parent_pbag->combine(child->Sbag);
    // Combine might destroy child->Sbag
    cilksan_assert(child->Sbag->get_set_node()->is_PBag());

    // Combine child P-bag into parent P-bag.
    if (child->Pbag) {
      DBG_TRACE(DEBUG_BAGS,
		"Merge P-bag from spawned child %ld to P-bag from parent %ld.\n",
		child->Sbag->get_set_node()->get_func_id(),
		parent->Sbag->get_set_node()->get_func_id());
      cilksan_assert(child->Pbag->get_set_node()->is_PBag());
      parent_pbag->combine(child->Pbag);
      cilksan_assert(child->Pbag->get_set_node()->is_PBag());
    }

  } else {
    // We are returning from a call.  Merge the child S-bag into the
    // parent S-bag, and merge the child P-bag into the parent P-bag.
    DBG_TRACE(DEBUG_BAGS, "Merge S-bag from called child %ld to S-bag from parent %ld.\n",
              child->Sbag->get_set_node()->get_func_id(),
              parent->Sbag->get_set_node()->get_func_id());
    // fprintf(stderr, "parent->Sbag = %p, child->Sbag = %p\n",
    // 	    parent->Sbag, child->Sbag);
    cilksan_assert(parent->Sbag->get_set_node()->is_SBag());
    parent->Sbag->combine(child->Sbag);

    // fprintf(stderr, "parent->Pbag = %p, child->Pbag = %p\n",
    // 	    parent->Pbag, child->Pbag);
    // Combine child P-bag into parent P-bag.
    if (child->Pbag) {
      // Get the parent P-bag.
      DisjointSet_t<SPBagInterface *> *parent_pbag = parent->Pbag;
      if (!parent_pbag) { // lazily create PBag when needed
	DBG_TRACE(DEBUG_BAGS,
		  "frame %ld creates a PBag ",
		  parent->Sbag->get_set_node()->get_func_id());
	parent_pbag =
	  new DisjointSet_t<SPBagInterface *>(new PBag_t(parent->Sbag->get_node()));
	parent->set_pbag(parent_pbag);
	DBG_TRACE(DEBUG_BAGS, "%p\n", parent_pbag);
      }

      DBG_TRACE(DEBUG_BAGS, "Merge P-bag from called child %ld to P-bag from parent %ld.\n",
		child->frame_data.frame_id,
		parent->Sbag->get_set_node()->get_func_id());
      cilksan_assert(parent_pbag && parent_pbag->get_set_node()->is_PBag());
      // Combine child P-bag into parent P-bag.
      cilksan_assert(child->Pbag->get_set_node()->is_PBag());
      parent_pbag->combine(child->Pbag);
      cilksan_assert(child->Pbag->get_set_node()->is_PBag());
    }
  }
  DBG_TRACE(DEBUG_BAGS, "After merge, parent set node func id: %ld.\n",
            parent->Sbag->get_set_node()->get_func_id());
  cilksan_assert(parent->Sbag->get_node()->get_func_id() ==
                 parent->Sbag->get_set_node()->get_func_id());

  child->set_sbag(NULL);
  child->set_pbag(NULL);
}

/// Helper function for handling the start of a new function.  This
/// function can be a spawned or called Cilk function or a spawned C
/// function.  A called C function is treated as inlined.
static inline void start_new_function() {
  frame_id++;
  frame_stack.push();

  DBG_TRACE(DEBUG_CALLBACK, "Enter frame %ld, ", frame_id);

  // Get the parent pointer after we push, because once pused, the
  // pointer may no longer be valid due to resize.
  FrameData_t *parent = frame_stack.ancestor(1);
  DBG_TRACE(DEBUG_CALLBACK, "parent frame %ld.\n", parent->frame_data.frame_id);
  DisjointSet_t<SPBagInterface *> *child_sbag, *parent_sbag = parent->Sbag;

  FrameData_t *child = frame_stack.head();
  cilksan_assert(child->Sbag == NULL);
  cilksan_assert(child->Pbag == NULL);

  child_sbag =
    new DisjointSet_t<SPBagInterface *>(new SBag_t(frame_id,
						   parent_sbag->get_node()));

  child->init_new_function(child_sbag);

  // We do the assertion after the init so that ref_count is 1.
  cilksan_assert(child_sbag->get_set_node()->is_SBag());

  WHEN_CILKSAN_DEBUG(frame_stack.head()->frame_data.frame_id = frame_id);

  DBG_TRACE(DEBUG_CALLBACK, "Enter function id %ld\n", frame_id);
}

/// Helper function for exiting a function; counterpart of
/// start_new_function.
static inline void exit_function() {
  // Popping doesn't actually destruct the object so we need to
  // manually dec the ref counts here.
  frame_stack.head()->reset();
  frame_stack.pop();
}

/// Action performed on entering a Cilk function (excluding spawn
/// helper).
static inline void enter_cilk_function() {
  DBG_TRACE(DEBUG_CALLBACK, "entering a Cilk function, push frame_stack\n");
  start_new_function();
}

/// Action performed on leaving a Cilk function (excluding spawn
/// helper).
static inline void leave_cilk_function() {
  DBG_TRACE(DEBUG_CALLBACK,
            "leaving a Cilk function (spawner or helper), pop frame_stack\n");

  /* param: not returning from a spawn */
  merge_bag_from_returning_child(0);
  exit_function();
}

/// Action performed on entering a spawned child.
/// (That is, right after detach.)
static inline void enter_detach_child() {
  DBG_TRACE(DEBUG_CALLBACK, "done detach, push frame_stack\n");
  start_new_function();
  // Copy the rsp from the parent.
  FrameData_t *detached = frame_stack.head();
  FrameData_t *parent = frame_stack.ancestor(1);
  detached->Sbag->get_node()->set_rsp(parent->Sbag->get_node()->get_rsp());
  // Set the frame data.
  frame_stack.head()->frame_data.entry_type = DETACHER;
  frame_stack.head()->frame_data.frame_type = SHADOW_FRAME;
  DBG_TRACE(DEBUG_CALLBACK, "new detach frame started\n");
}

/// Action performed when returning from a spawned child.
/// (That is, returning from a spawn helper.)
static inline void return_from_detach() {

  DBG_TRACE(DEBUG_CALLBACK, "return from detach, pop frame_stack\n");
  cilksan_assert(DETACHER == frame_stack.head()->frame_data.entry_type);
  /* param: we are returning from a spawn */
  merge_bag_from_returning_child(1);
  exit_function();
  // Detacher frames do not have separate leave calls from the helpers
  // containing them, so we manually call leave_cilk_function again.
  leave_cilk_function();
}

/// Action performed immediately after passing a sync.
static void complete_sync() {
  FrameData_t *f = frame_stack.head();
  DBG_TRACE(DEBUG_CALLBACK, "frame %d done sync\n",
            f->Sbag->get_node()->get_func_id());

  cilksan_assert(f->Sbag->get_set_node()->is_SBag());
  // Pbag could be NULL if we encounter a sync without any spawn (i.e., any Cilk
  // function that executes the base case)
  if (f->Pbag) {
    cilksan_assert(f->Pbag->get_set_node()->is_PBag());
    f->Sbag->combine(f->Pbag);
    cilksan_assert(f->Pbag->get_set_node()->is_SBag());
    cilksan_assert(f->Sbag->get_node()->get_func_id() ==
		   f->Sbag->get_set_node()->get_func_id());
    f->set_pbag(NULL);
  }
}

//---------------------------------------------------------------
// Callback functions
//---------------------------------------------------------------
void cilksan_do_enter_begin() {
  cilksan_assert(CILKSAN_INITIALIZED);
  cilksan_assert(last_event == NONE);
  WHEN_CILKSAN_DEBUG(last_event = ENTER_FRAME);
  DBG_TRACE(DEBUG_CALLBACK, "frame %ld cilk_enter_frame_begin, stack depth %d\n",
            frame_id+1, frame_stack.size());

/*
  if (entry_stack.size() == 1) {
    // we are entering the top-level Cilk function; everything we did
    // before can be cleared, since we can't possibly be racing with
    // anything old at this point
    shadow_mem.clear();
  }
*/
  // entry_stack.push();
  // entry_stack.head()->entry_type = SPAWNER;
  // entry_stack.head()->frame_type = SHADOW_FRAME;
  // entry_stack always gets pushed slightly before frame_id gets incremented
  // WHEN_CILKSAN_DEBUG(entry_stack.head()->frame_id = frame_id+1);
  enter_cilk_function();
  frame_stack.head()->frame_data.entry_type = SPAWNER;
  frame_stack.head()->frame_data.frame_type = SHADOW_FRAME;
}

void cilksan_do_enter_helper_begin() {
  cilksan_assert(CILKSAN_INITIALIZED);
  DBG_TRACE(DEBUG_CALLBACK, "frame %ld cilk_enter_helper_begin\n", frame_id+1);
  cilksan_assert(last_event == NONE);
  WHEN_CILKSAN_DEBUG(last_event = ENTER_HELPER;);

  // entry_stack.push();
  // entry_stack.head()->entry_type = HELPER;
  // entry_stack.head()->frame_type = SHADOW_FRAME;
  // entry_stack always gets pushed slightly before frame_id gets incremented
  // WHEN_CILKSAN_DEBUG(entry_stack.head()->frame_id = frame_id+1;);
  // WHEN_CILKSAN_DEBUG(update_deque_for_entering_helper(););
  enter_cilk_function();
  frame_stack.head()->frame_data.entry_type = HELPER;
  frame_stack.head()->frame_data.frame_type = SHADOW_FRAME;
}

void cilksan_do_enter_end(uintptr_t stack_ptr) {
  cilksan_assert(CILKSAN_INITIALIZED);
  FrameData_t *cilk_func = frame_stack.head();
  cilk_func->Sbag->get_node()->set_rsp(stack_ptr);
  cilksan_assert(last_event == ENTER_FRAME || last_event == ENTER_HELPER);
  WHEN_CILKSAN_DEBUG(last_event = NONE);
  DBG_TRACE(DEBUG_CALLBACK, "cilk_enter_end, frame stack ptr: %p\n", stack_ptr);
}

void cilksan_do_detach_begin() {
  cilksan_assert(CILKSAN_INITIALIZED);
  cilksan_assert(last_event == NONE);
  WHEN_CILKSAN_DEBUG(last_event = DETACH);
}

void cilksan_do_detach_end() {
  cilksan_assert(CILKSAN_INITIALIZED);
  DBG_TRACE(DEBUG_CALLBACK, "cilk_detach\n");

  // cilksan_assert(frame_stack.head()->frame_data.entry_type == HELPER);
  cilksan_assert(last_event == DETACH);
  WHEN_CILKSAN_DEBUG(last_event = NONE);

  // At this point, the frame_stack.head is still the parent (spawning) frame
  FrameData_t *parent = frame_stack.head();

  DBG_TRACE(DEBUG_CALLBACK,
	    "frame %ld about to spawn.\n",
	    parent->Sbag->get_node()->get_func_id());

  // if (!parent->Pbag) { // lazily create PBag when needed
  //   DBG_TRACE(DEBUG_BAGS,
  // 	      "frame %ld creates a PBag.\n",
  // 	      parent->Sbag->get_set_node()->get_func_id());
  //   DisjointSet_t<SPBagInterface *> *parent_pbag =
  //     new DisjointSet_t<SPBagInterface *>(new PBag_t(parent->Sbag->get_node()));
  //   parent->set_pbag(parent_pbag);
  // }
  enter_detach_child();
}

void cilksan_do_sync_begin() {
  cilksan_assert(CILKSAN_INITIALIZED);
  DBG_TRACE(DEBUG_CALLBACK, "frame %ld cilk_sync_begin\n",
            frame_stack.head()->Sbag->get_node()->get_func_id());
  cilksan_assert(last_event == NONE);
  WHEN_CILKSAN_DEBUG(last_event = CILK_SYNC);
}

void cilksan_do_sync_end() {
  cilksan_assert(CILKSAN_INITIALIZED);
  DBG_TRACE(DEBUG_CALLBACK, "cilk_sync_end\n");
  cilksan_assert(last_event == CILK_SYNC);
  WHEN_CILKSAN_DEBUG(last_event = NONE);
  complete_sync();
}

void cilksan_do_leave_begin() {
  cilksan_assert(CILKSAN_INITIALIZED);
  cilksan_assert(last_event == NONE);
  WHEN_CILKSAN_DEBUG(last_event = LEAVE_FRAME_OR_HELPER);
  DBG_TRACE(DEBUG_CALLBACK, "frame %ld cilk_leave_begin\n",
            frame_stack.head()->frame_data.frame_id);
  cilksan_assert(frame_stack.size() > 1);

  switch(frame_stack.head()->frame_data.entry_type) {
  case SPAWNER:
    DBG_TRACE(DEBUG_CALLBACK, "cilk_leave_frame_begin\n");
    break;
  case HELPER:
    DBG_TRACE(DEBUG_CALLBACK, "cilk_leave_helper_begin\n");
    break;
  case DETACHER:
    DBG_TRACE(DEBUG_CALLBACK, "cilk_leave_begin from detach\n");
    break;
  }

  if (DETACHER == frame_stack.head()->frame_data.entry_type)
    return_from_detach();
  else
    leave_cilk_function();
}

void cilksan_do_leave_end() {
  cilksan_assert(CILKSAN_INITIALIZED);
  // DBG_TRACE(DEBUG_CALLBACK, "frame %ld cilk_leave_end\n",
  //           frame_stack.head()->frame_data.frame_id);
  DBG_TRACE(DEBUG_CALLBACK, "cilk_leave_end\n");
  cilksan_assert(last_event == LEAVE_FRAME_OR_HELPER);
  WHEN_CILKSAN_DEBUG(last_event = NONE);
  // cilksan_assert(frame_stack.size() > 1);
}

// called by record_memory_read/write, with the access broken down into 64-byte
// aligned memory accesses
static void record_mem_helper(bool is_read, const csi_id_t acc_id,
                              uintptr_t addr,
                              size_t mem_size, bool on_stack) {
  FrameData_t *f = frame_stack.head();
  bool is_in_shadow_memory =
    shadow_memory.does_access_exists(is_read, addr, mem_size);

  if (is_in_shadow_memory == false)
    shadow_memory.insert_access(is_read, acc_id, addr, mem_size, f,
                                call_stack);
  else
    check_races_and_update(is_read, acc_id, addr, mem_size, on_stack,
                           f, call_stack, shadow_memory);
}

void cilksan_do_read(const csi_id_t load_id,
                     uintptr_t addr, size_t mem_size) {
  cilksan_assert(CILKSAN_INITIALIZED);
  DBG_TRACE(DEBUG_MEMORY, "record read %lu: %lu bytes at addr %p and rip %p.\n",
            load_id, mem_size, addr, load_pc[load_id]);

  // for now we assume the stack doesn't change
  bool on_stack = is_on_stack(addr);
  if (on_stack)
    if (addr < *sp_stack.head())
      *sp_stack.head() = addr;
  // handle the prefix
  uintptr_t next_addr = ALIGN_BY_NEXT_MAX_GRAIN_SIZE(addr);
  size_t prefix_size = next_addr - addr;
  cilksan_assert(prefix_size >= 0 && prefix_size < MAX_GRAIN_SIZE);

  if (prefix_size >= mem_size) { // access falls within a max grain sized block
    record_mem_helper(true, load_id, addr, mem_size, on_stack);
  } else {
    cilksan_assert( prefix_size <= mem_size );
    if (prefix_size) { // do the prefix first
      record_mem_helper(true, load_id, addr, prefix_size, on_stack);
      mem_size -= prefix_size;
    }
    addr = next_addr;
    // then do the rest of the max-grain size aligned blocks
    uint32_t i = 0;
    for (i = 0; (i + MAX_GRAIN_SIZE) < mem_size; i += MAX_GRAIN_SIZE) {
      record_mem_helper(true, load_id, addr + i, MAX_GRAIN_SIZE,
                        on_stack);
    }
    // trailing bytes
    record_mem_helper(true, load_id, addr+i, mem_size-i, on_stack);
  }
}

void cilksan_do_write(const csi_id_t store_id,
                      uintptr_t addr, size_t mem_size) {
  cilksan_assert(CILKSAN_INITIALIZED);
  DBG_TRACE(DEBUG_MEMORY, "record write %ld: %lu bytes at addr %p and rip %p.\n",
            store_id, mem_size, addr, store_pc[store_id]);

  bool on_stack = is_on_stack(addr);
  if (on_stack)
    if (addr < *sp_stack.head())
      *sp_stack.head() = addr;
  // handle the prefix
  uintptr_t next_addr = ALIGN_BY_NEXT_MAX_GRAIN_SIZE(addr);
  size_t prefix_size = next_addr - addr;
  cilksan_assert(prefix_size >= 0 && prefix_size < MAX_GRAIN_SIZE);

  if (prefix_size >= mem_size) { // access falls within a max grain sized block
    record_mem_helper(false, store_id, addr, mem_size, on_stack);
  } else {
    cilksan_assert(prefix_size <= mem_size);
    if (prefix_size) { // do the prefix first
      record_mem_helper(false, store_id, addr, prefix_size,
                        on_stack);
      mem_size -= prefix_size;
    }
    addr = next_addr;
    // then do the rest of the max-grain size aligned blocks
    uint32_t i = 0;
    for(i = 0; (i + MAX_GRAIN_SIZE) < mem_size; i += MAX_GRAIN_SIZE) {
      record_mem_helper(false, store_id, addr + i, MAX_GRAIN_SIZE,
                        on_stack);
    }
    // trailing bytes
    record_mem_helper(false, store_id, addr+i, mem_size-i, on_stack);
  }
}

// clear the memory block at [start,start+size) (end is exclusive).
void cilksan_clear_shadow_memory(size_t start, size_t size) {
  DBG_TRACE(DEBUG_MEMORY, "cilksan_clear_shadow_memory(%p, %ld)\n",
            start, size);
  shadow_memory.clear(start,size);
}

static void print_cilksan_stat() {
  // std::cout << "max sync block size seen: "
  //           << accounted_max_sync_block_size
  //           << "    (from user input: " << max_sync_block_size << ", average: "
  //           << ( (float)accum_sync_block_size / num_of_sync_blocks ) << ")"
  //           << std::endl;
  // std::cout << "max continuation depth seen: "
  //           << accounted_max_cont_depth << std::endl;
}

void cilksan_deinit() {
  static bool deinit = false;
  // XXX: kind of a hack, but somehow this gets called twice.
  if (!deinit) deinit = true;
  else return; /* deinit-ed already */

  print_race_report();
  print_cilksan_stat();

  cilksan_assert(frame_stack.size() == 1);
  // cilksan_assert(entry_stack.size() == 1);

  shadow_memory.destruct();

  // Remove references to the disjoint set nodes so they can be freed.
  frame_stack.head()->reset();
  frame_stack.pop();

  WHEN_CILKSAN_DEBUG({
      if (DisjointSet_t<SPBagInterface *>::debug_count != 0)
        fprintf(stderr, "DisjointSet_t<SPBagInterface *>::debug_count = %ld\n",
                DisjointSet_t<SPBagInterface *>::debug_count);
      if (SBag_t::debug_count != 0)
        fprintf(stderr, "SBag_t::debug_count = %ld\n",
                SBag_t::debug_count);
      if (PBag_t::debug_count != 0)
        fprintf(stderr, "PBag_t::debug_count = %ld\n",
                PBag_t::debug_count);
      // cilksan_assert(DisjointSet_t<SPBagInterface *>::debug_count == 0);
      // cilksan_assert(SBag_t::debug_count == 0);
      // cilksan_assert(PBag_t::debug_count == 0);
    });

  // Free the call-stack nodes in the free list.
  call_stack_node_t::cleanup_freelist();

  // Free the disjoint-set nodes in the free list.
  DisjointSet_t<SPBagInterface *>::cleanup_freelist();

  // Free the free lists for SBags and PBags.
  SBag_t::cleanup_freelist();
  PBag_t::cleanup_freelist();

  disjoint_set_list.free_list();

  // if(first_error != 0) exit(first_error);
}

void cilksan_init() {
  DBG_TRACE(DEBUG_CALLBACK, "cilksan_init()\n");
  std::cout<< "cilksan_init() version 19\n";

  cilksan_assert(stack_high_addr != 0 && stack_low_addr != 0);

  // these are true upon creation of the stack
  cilksan_assert(frame_stack.size() == 1);
  // cilksan_assert(entry_stack.size() == 1);
  // // actually only used for debugging of reducer race detection
  // WHEN_CILKSAN_DEBUG(rts_deque_begin = rts_deque_end = 1);

  shadow_memory.init();

  // for the main function before we enter the first Cilk context
  DisjointSet_t<SPBagInterface *> *sbag;
  sbag = new DisjointSet_t<SPBagInterface *>(new SBag_t(frame_id, NULL));
  cilksan_assert(sbag->get_set_node()->is_SBag());
  frame_stack.head()->set_sbag(sbag);
  WHEN_CILKSAN_DEBUG(frame_stack.head()->frame_data.frame_type = FULL_FRAME);

#if CILKSAN_DEBUG
  CILKSAN_INITIALIZED = true;
#endif
}

extern "C" int __cilksan_error_count() {
  return get_num_races_found();
}

// This funciton parse the input supplied to the user program and get the params
// meant for cilksan (everything after "--").  It return the index in which it
// found "--" so the user program knows when to stop parsing inputs.
extern "C" int __cilksan_parse_input(int argc, char *argv[]) {
  int i = 0;
  // uint32_t seed = 0;
  int stop = 0;

  while(i < argc) {
    if(!strncmp(argv[i], "--", strlen("--")+1)) {
      stop = i++;
      break;
    }
    i++;
  }

  while(i < argc) {
    char *arg = argv[i];
    // if(!strncmp(arg, "-cr", strlen("-cr")+1)) {
    //   i++;
    //   check_reduce = true;
    //   continue;

    // } else if(!strncmp(arg, "-update", strlen("-update")+1)) {
    //   i++;
    //   cont_depth_to_check = (uint64_t) atol(argv[i++]);
    //   continue;

    // } else if(!strncmp(arg, "-sb_size", strlen("-sb_size")+1)) {
    //   i++;
    //   max_sync_block_size = (uint32_t) atoi(argv[i++]);
    //   continue;

    // } else if(!strncmp(arg, "-s", strlen("-s")+1)) {
    //   i++;
    //   seed = (uint32_t) atoi(argv[i++]);
    //   continue;

    // } else if(!strncmp(arg, "-steal", strlen("-steal")+1)) {
    //   i++;
    //   cilksan_assert(steal_point1 < steal_point2
    //               && steal_point2 < steal_point3);
    //   check_reduce = true;
    //   continue;

    // } else {
      i++;
      std::cout << "Unrecognized input " << arg << ", ignore and continue."
                << std::endl;
    // }
  }

  // std::cout << "==============================================================="
  //           << std::endl;
  // if(cont_depth_to_check != 0) {
  //   check_reduce = false;
  //   std::cout << "This run will check updates for races with " << std::endl
  //             << "steals at continuation depth " << cont_depth_to_check;
  // } else if(check_reduce) {
  //   std::cout << "This run will check reduce functions for races " << std::endl
  //             << "with simulated steals ";
  //   if(max_sync_block_size > 1) {
  //     std::cout << "at randomly chosen continuation points \n"
  //               << "(assume block size "
  //               << max_sync_block_size << ")";
  //     if(seed) {
  //       std::cout << ", chosen using seed " << seed;
  //       srand(seed);
  //     } else {
  //       // srand(time(NULL));
  //     }
  //   } else {
  //     if(steal_point1 != steal_point2 && steal_point2 != steal_point3) {
  //       std::cout << "at steal points: " << steal_point1 << ", "
  //                 << steal_point2 << ", " << steal_point3 << ".";
  //     } else {
  //       simulate_all_steals = true;
  //       check_reduce = false;
  //       std::cout << "at every continuation point.";
  //     }
  //   }
  // } else {
  //   // cont_depth_to_check == 0 and check_reduce = false
  //   std::cout << "This run will check for races without simulated steals.";
  // }
  // std::cout << std::endl;
  // std::cout << "==============================================================="
  //           << std::endl;

  // cilksan_assert(!check_reduce || cont_depth_to_check == 0);
  // cilksan_assert(!check_reduce || max_sync_block_size > 1 || steal_point1 != steal_point2);

  return (stop == 0 ? argc : stop);
}

// XXX: Should really be in print_addr.cpp, but this will do for now
void print_current_function_info() {
  FrameData_t *f = frame_stack.head();
  // std::cout << "steal points: " << f->steal_points[0] << ", "
  //           << f->steal_points[1] << ", " << f->steal_points[2] << std::endl;
  // std::cout << "curr sync block size: " << f->current_sync_block_size << std::endl;
  std::cout << "frame id: " << f->Sbag->get_node()->get_func_id() << std::endl;
}
