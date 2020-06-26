#include "csi.h"

WEAK void __csi_init() {}

__attribute__((always_inline))
WEAK void __csi_unit_init(const char * const file_name,
                          const instrumentation_counts_t counts) {}

__attribute__((always_inline))
WEAK void __csi_before_load(const csi_id_t load_id,
                            const void *addr,
                            const int32_t num_bytes,
                            const load_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_load(const csi_id_t load_id,
                           const void *addr,
                           const int32_t num_bytes,
                           const load_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_before_store(const csi_id_t store_id,
                             const void *addr,
                             const int32_t num_bytes,
                             const store_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_store(const csi_id_t store_id,
                            const void *addr,
                            const int32_t num_bytes,
                            const store_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_func_entry(const csi_id_t func_id, const func_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_func_exit(const csi_id_t func_exit_id,
                          const csi_id_t func_id, const func_exit_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_before_loop(const csi_id_t loop_id, const int64_t trip_count,
                            const loop_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_loop(const csi_id_t loop_id, const loop_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_loopbody_entry(const csi_id_t loop_id, const loop_prop_t prop)
{}

__attribute__((always_inline))
WEAK void __csi_loopbody_exit(const csi_id_t loop_exit_id,
                              const csi_id_t loop_id,
                              const loop_exit_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_bb_entry(const csi_id_t bb_id, const bb_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_bb_exit(const csi_id_t bb_id, const bb_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_before_call(csi_id_t callsite_id, csi_id_t func_id,
                            const call_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_call(csi_id_t callsite_id, csi_id_t func_id,
                           const call_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_detach(const csi_id_t detach_id, const int32_t *has_spawned) {}

__attribute__((always_inline))
WEAK void __csi_task(const csi_id_t task_id, const csi_id_t detach_id,
                     const task_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_task_exit(const csi_id_t task_exit_id, const csi_id_t task_id,
                          const csi_id_t detach_id,
                          const task_exit_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_detach_continue(const csi_id_t detach_continue_id,
                                const csi_id_t detach_id,
                                const detach_continue_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_before_sync(const csi_id_t sync_id, const int32_t *has_spawned)
{}

__attribute__((always_inline))
WEAK void __csi_after_sync(const csi_id_t sync_id, const int32_t *has_spawned)
{}

__attribute__((always_inline))
WEAK void __csi_before_alloca(const csi_id_t alloca_id,
                              size_t num_bytes,
                              const alloca_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_alloca(const csi_id_t alloca_id,
                             const void *addr,
                             size_t num_bytes,
                             const alloca_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_before_allocfn(const csi_id_t allocfn_id,
                               size_t size, size_t num, size_t alignment,
                               const void *oldaddr, const allocfn_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_allocfn(const csi_id_t allocfn_id, const void *addr,
                              size_t size, size_t num, size_t alignment,
                              const void *oldaddr, const allocfn_prop_t prop)
{}

__attribute__((always_inline))
WEAK void __csi_before_free(const csi_id_t free_id,
                            const void *ptr,
                            const free_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_free(const csi_id_t free_id,
                           const void *ptr,
                           const free_prop_t prop) {}

