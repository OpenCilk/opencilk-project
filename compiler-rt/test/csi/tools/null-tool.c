#include "csi.h"

#define INLINE __attribute__((always_inline))

WEAK void __csi_init() {}

INLINE
WEAK void __csi_unit_init(const char * const file_name,
                          const instrumentation_counts_t counts) {}

///-----------------------------------------------------------------------------
/// Hooks for loads and stores
INLINE
WEAK void __csi_before_load(const csi_id_t load_id,
                            const void *addr,
                            const int32_t num_bytes,
                            const csi_ir_variable_category_t obj_operand_cat,
                            const csi_id_t obj_operand_id,
                            const load_prop_t prop) {}

INLINE
WEAK void __csi_after_load(const csi_id_t load_id,
                           const void *addr,
                           const int32_t num_bytes,
                           const csi_ir_variable_category_t obj_operand_cat,
                           const csi_id_t obj_operand_id,
                           const load_prop_t prop) {}

INLINE
WEAK void __csi_before_store(const csi_id_t store_id,
                             const void *addr,
                             const int32_t num_bytes,
                             const csi_ir_variable_category_t operand_cat,
                             const csi_id_t operand_id,
                             const csi_ir_variable_category_t obj_operand_cat,
                             const csi_id_t obj_operand_id,
                             const store_prop_t prop) {}

INLINE
WEAK void __csi_after_store(const csi_id_t store_id,
                            const void *addr,
                            const int32_t num_bytes,
                            const csi_ir_variable_category_t operand_cat,
                            const csi_id_t operand_id,
                            const csi_ir_variable_category_t obj_operand_cat,
                            const csi_id_t obj_operand_id,
                            const store_prop_t prop) {}

///-----------------------------------------------------------------------------
/// Masked vector loads, stores, scatters, gathers
INLINE
WEAK void __csi_before_masked_load_v4float(
    const csi_id_t load_id, const v4float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_load_v4float(
    const csi_id_t load_id, const v4float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_load_v8float(
    const csi_id_t load_id, const v8float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_load_v8float(
    const csi_id_t load_id, const v8float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_load_v16float(
    const csi_id_t load_id, const v16float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v16float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_load_v16float(
    const csi_id_t load_id, const v16float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v16float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_load_v2double(
    const csi_id_t load_id, const v2double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v2double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_load_v2double(
    const csi_id_t load_id, const v2double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v2double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_load_v4double(
    const csi_id_t load_id, const v4double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_load_v4double(
    const csi_id_t load_id, const v4double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_load_v8double(
    const csi_id_t load_id, const v8double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_load_v8double(
    const csi_id_t load_id, const v8double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_gather_v4float(
    const csi_id_t load_id, const v4floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_gather_v4float(
    const csi_id_t load_id, const v4floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_gather_v8float(
    const csi_id_t load_id, const v8floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_gather_v8float(
    const csi_id_t load_id, const v8floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_gather_v16float(
    const csi_id_t load_id, const v16floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v16float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_gather_v16float(
    const csi_id_t load_id, const v16floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v16float passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_gather_v2double(
    const csi_id_t load_id, const v2doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v2double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_gather_v2double(
    const csi_id_t load_id, const v2doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v2double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_gather_v4double(
    const csi_id_t load_id, const v4doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_gather_v4double(
    const csi_id_t load_id, const v4doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_gather_v8double(
    const csi_id_t load_id, const v8doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_gather_v8double(
    const csi_id_t load_id, const v8doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8double passthru,
    const load_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_store_v4float(
    const csi_id_t store_id, const v4float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_store_v4float(
    const csi_id_t store_id, const v4float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_store_v8float(
    const csi_id_t store_id, const v8float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_store_v8float(
    const csi_id_t store_id, const v8float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_store_v16float(
    const csi_id_t store_id, const v16float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v16float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_store_v16float(
    const csi_id_t store_id, const v16float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v16float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_store_v2double(
    const csi_id_t store_id, const v2double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v2double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_store_v2double(
    const csi_id_t store_id, const v2double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v2double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_store_v4double(
    const csi_id_t store_id, const v4double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_store_v4double(
    const csi_id_t store_id, const v4double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_store_v8double(
    const csi_id_t store_id, const v8double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_store_v8double(
    const csi_id_t store_id, const v8double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_scatter_v4float(
    const csi_id_t store_id, const v4floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_scatter_v4float(
    const csi_id_t store_id, const v4floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_scatter_v8float(
    const csi_id_t store_id, const v8floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_scatter_v8float(
    const csi_id_t store_id, const v8floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_scatter_v16float(
    const csi_id_t store_id, const v16floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v16float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_scatter_v16float(
    const csi_id_t store_id, const v16floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v16float operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_scatter_v2double(
    const csi_id_t store_id, const v2doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v2double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_scatter_v2double(
    const csi_id_t store_id, const v2doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v2double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_scatter_v4double(
    const csi_id_t store_id, const v4doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_scatter_v4double(
    const csi_id_t store_id, const v4doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_before_masked_scatter_v8double(
    const csi_id_t store_id, const v8doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8double operand,
    const store_prop_t prop) {}

INLINE
WEAK void __csi_after_masked_scatter_v8double(
    const csi_id_t store_id, const v8doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8double operand,
    const store_prop_t prop) {}

///-----------------------------------------------------------------------------
/// Function entry/exit
INLINE
WEAK void __csi_func_entry(const csi_id_t func_id,
                           const csi_id_t first_param_id, int32_t num_params,
                           const func_prop_t prop) {}

INLINE
WEAK void __csi_func_exit(const csi_id_t func_exit_id,
                          const csi_id_t func_id,
                          const func_exit_prop_t prop) {}

///-----------------------------------------------------------------------------
/// Loop hooks.
INLINE
WEAK void __csi_before_loop(const csi_id_t loop_id, const uint64_t trip_count,
                            const loop_prop_t prop) {}
INLINE
WEAK void __csi_after_loop(const csi_id_t loop_id, const loop_prop_t prop) {}
INLINE
WEAK void __csi_loopbody_entry(const csi_id_t loop_id, const loop_prop_t prop)
{}
INLINE
WEAK void __csi_loopbody_exit(const csi_id_t loop_exit_id,
                              const csi_id_t loop_id,
                              const loop_exit_prop_t prop) {}

///-----------------------------------------------------------------------------
/// Basic block entry/exit.  The bb_entry hook comes after any PHI hooks in that
/// basic block.  The bb_exit hook comes before any hooks for terminators, e.g.,
/// for invoke instructions.
INLINE
WEAK void __csi_bb_entry(const csi_id_t bb_id, const csi_id_t pred_bb_id,
                         const bb_prop_t prop) {}

INLINE
WEAK void __csi_bb_exit(const csi_id_t bb_id, const bb_prop_t prop) {}


///-----------------------------------------------------------------------------
/// Callsite hooks
INLINE
WEAK void __csi_before_call(csi_id_t callsite_id, csi_id_t parent_bb_id,
                            csi_id_t func_id, const call_prop_t prop) {}

INLINE
WEAK void __csi_after_call(csi_id_t callsite_id, csi_id_t func_id,
                           const call_prop_t prop) {}

///-----------------------------------------------------------------------------
/// Hooks for Tapir control flow.
INLINE
WEAK void __csi_detach(const csi_id_t detach_id, const int32_t *has_spawned) {}

INLINE
WEAK void __csi_task(const csi_id_t task_id, const csi_id_t detach_id) {}

INLINE
WEAK void __csi_task_exit(const csi_id_t task_exit_id,
                          const csi_id_t task_id,
                          const csi_id_t detach_id) {}

INLINE
WEAK void __csi_detach_continue(const csi_id_t detach_continue_id,
                                const csi_id_t detach_id) {}

INLINE
WEAK void __csi_before_sync(const csi_id_t sync_id, const int32_t *has_spawned)
{}

INLINE
WEAK void __csi_after_sync(const csi_id_t sync_id, const int32_t *has_spawned)
{}

///-----------------------------------------------------------------------------
/// Hooks for memory allocation
INLINE
WEAK void __csi_before_alloca(const csi_id_t alloca_id,
                              uint64_t num_bytes,
                              const alloca_prop_t prop) {}

INLINE
WEAK void __csi_after_alloca(const csi_id_t alloca_id,
                             const void *addr,
                             uint64_t num_bytes,
                             const alloca_prop_t prop) {}

INLINE
WEAK void __csi_before_allocfn(const csi_id_t allocfn_id,
                               uint64_t size, uint64_t num, uint64_t alignment,
                               const void *oldaddr, const allocfn_prop_t prop) {}

INLINE
WEAK void __csi_after_allocfn(const csi_id_t allocfn_id, const void *addr,
                              uint64_t size, uint64_t num, uint64_t alignment,
                              const void *oldaddr, const allocfn_prop_t prop)
{}

INLINE
WEAK void __csi_before_free(const csi_id_t free_id,
                            const void *ptr,
                            const free_prop_t prop) {}

INLINE
WEAK void __csi_after_free(const csi_id_t free_id,
                           const void *ptr,
                           const free_prop_t prop) {}

///-----------------------------------------------------------------------------
/// Simple arithmetic ops.

/* INLINE WEAK void __csi_before_arithmetic_half( */
/*     const csi_id_t arith_id, const csi_opcode_t opcode, */
/*     const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id, */
/*     const _Float16 operand0, const csi_ir_variable_category_t operand1_cat, */
/*     const csi_id_t operand1_id, const _Float16 operand1, */
/*     const arithmetic_flags_t flags) {} */

INLINE WEAK void __csi_before_arithmetic_float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_i8(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint8_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint8_t operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_i16(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint16_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint16_t operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_i32(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint32_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint32_t operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_i64(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint64_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint64_t operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_i128(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const __uint128_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const __uint128_t operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_v4float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v4float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4float operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_v8float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v8float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8float operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_v16float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v16float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v16float operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_v2double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v2double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v2double operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_v4double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v4double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4double operand1,
    const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_arithmetic_v8double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v8double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8double operand1,
    const arithmetic_flags_t flags) {}

// Floating-point extension and truncation
/* INLINE WEAK void __csi_before_extend_half_float( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_extend_half_double( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

INLINE WEAK void __csi_before_extend_float_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_truncate_double_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

/* INLINE WEAK void __csi_before_truncate_double_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_truncate_float_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {} */

// Conversion from floating-point to unsigned integer
/* INLINE WEAK void __csi_before_convert_half_unsigned_i8( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_half_unsigned_i16( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_half_unsigned_i32( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_half_unsigned_i64( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_half_unsigned_i128( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

INLINE WEAK void __csi_before_convert_float_unsigned_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_float_unsigned_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_float_unsigned_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_float_unsigned_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_float_unsigned_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_unsigned_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_unsigned_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_unsigned_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_unsigned_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_unsigned_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

// Conversion from floating-point to signed integer
/* INLINE WEAK void __csi_before_convert_half_signed_i8( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_half_signed_i16( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_half_signed_i32( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_half_signed_i64( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_half_signed_i128( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

INLINE WEAK void __csi_before_convert_float_signed_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_float_signed_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_float_signed_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_float_signed_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_float_signed_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_signed_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_signed_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_signed_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_signed_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_double_signed_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

// Conversion from unsigned integer to floating-point
/* INLINE WEAK void __csi_before_convert_unsigned_i8_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_unsigned_i16_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_unsigned_i32_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_unsigned_i64_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_unsigned_i128_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags) {} */

INLINE WEAK void __csi_before_convert_unsigned_i8_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i16_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i32_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i64_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i128_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i8_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i16_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i32_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i64_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i128_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags) {}


// Floating-point vector versions
INLINE WEAK void __csi_before_convert_unsigned_i8_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i16_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i32_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i64_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i128_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i8_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i16_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i32_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i64_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i8_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i16_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i32_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}


INLINE WEAK void __csi_before_convert_unsigned_i8_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i16_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i32_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i64_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i128_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i8_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i16_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i32_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i64_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i128_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i8_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i16_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i32_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_unsigned_i64_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {}

// Conversion from signed integer to floating-point
/* INLINE WEAK void __csi_before_convert_signed_i8_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_signed_i16_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_signed_i32_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_signed_i64_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags) {} */

/* INLINE WEAK void __csi_before_convert_signed_i128_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags) {} */

INLINE WEAK void __csi_before_convert_signed_i8_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i16_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i32_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i64_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i128_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i8_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i16_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i32_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i64_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i128_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags) {}


// Floating-point vector versions
INLINE WEAK void __csi_before_convert_signed_i8_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i16_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i32_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i64_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i128_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i8_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i16_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i32_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i64_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i8_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i16_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i32_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {}


INLINE WEAK void __csi_before_convert_signed_i8_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i16_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i32_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i64_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i128_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i8_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i16_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i32_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i64_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i128_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i8_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i16_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i32_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i64_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_before_convert_signed_i128_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags) {}

///-----------------------------------------------------------------------------
/// Vector operations
INLINE
WEAK void __csi_before_extract_element_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_extract_element_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_extract_element_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_extract_element_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_extract_element_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_extract_element_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_insert_element_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_insert_element_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_insert_element_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_insert_element_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_insert_element_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_insert_element_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v4float_v4float_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4float operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v4float_v4float_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8float operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v4float_v4float_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v16float operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v8float_v8float_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4float operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v8float_v8float_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8float operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v8float_v8float_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v16float operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v16float_v16float_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v16float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4float operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v16float_v16float_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v16float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8float operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v16float_v16float_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v16float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v16float operand2, const arithmetic_flags_t flags) {}


INLINE
WEAK void __csi_before_shuffle_v2double_v2double_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v2double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v2double operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v2double_v2double_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v2double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4double operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v2double_v2double_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v2double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8double operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v4double_v4double_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v2double operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v4double_v4double_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4double operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v4double_v4double_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8double operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v8double_v8double_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v2double operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v8double_v8double_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4double operand2, const arithmetic_flags_t flags) {}

INLINE
WEAK void __csi_before_shuffle_v8double_v8double_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8double operand2, const arithmetic_flags_t flags) {}

///-----------------------------------------------------------------------------
/// PHI node hooks

// Integer types
INLINE WEAK void __csi_phi_i8(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_i16(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_i32(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_i64(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_i128(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags) {}

// Floating-point types
/* INLINE WEAK void __csi_phi_half( */
/*     const csi_id_t arith_id, const csi_id_t parent_bb_id, */
/*     const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags) {} */

INLINE WEAK void __csi_phi_float(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_double(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags) {}

// Pointer types
//
// For consistency with other hooks, pointer arguments are always passed as
// void*.
INLINE WEAK void __csi_phi_pi8(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_pi32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand, const arithmetic_flags_t flags) {}

// Vector types
INLINE WEAK void __csi_phi_v4float(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v4float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_v8float(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v8float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_v16float(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v16float operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_v2double(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v2double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_v4double(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v4double operand, const arithmetic_flags_t flags) {}

INLINE WEAK void __csi_phi_v8double(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v8double operand, const arithmetic_flags_t flags) {}


///-----------------------------------------------------------------------------
/// Hooks for builtin functions
INLINE WEAK void __csi_before_memset(
    const csi_id_t call_id, const void *addr, const size_t num_bytes,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand) {}

INLINE WEAK void __csi_after_memset(
    const csi_id_t call_id, const void *addr, const size_t num_bytes,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand) {}

INLINE WEAK void __csi_before_memcpy(
    const csi_id_t call_id, const void *dst, const void *src,
    const size_t num_bytes) {}

INLINE WEAK void __csi_after_memcpy(
    const csi_id_t call_id, const void *dst, const void *src,
    const size_t num_bytes) {}

INLINE WEAK void __csi_before_memmove(
    const csi_id_t call_id, const void *dst, const void *src,
    const size_t num_bytes) {}

INLINE WEAK void __csi_after_memmove(
    const csi_id_t call_id, const void *dst, const void *src,
    const size_t num_bytes) {}

// Floating-point builtins
INLINE WEAK
void __csi_before_builtin_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const call_prop_t prop) {}

INLINE WEAK
void __csi_after_builtin_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const call_prop_t prop) {}

INLINE WEAK
void __csi_before_builtin_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const call_prop_t prop) {}

INLINE WEAK
void __csi_after_builtin_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const call_prop_t prop) {}

INLINE WEAK
void __csi_before_builtin_float_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1, const call_prop_t prop) {}

INLINE WEAK
void __csi_after_builtin_float_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1, const call_prop_t prop) {}

INLINE WEAK
void __csi_before_builtin_float_float_i32(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const call_prop_t prop) {}

INLINE WEAK
void __csi_after_builtin_float_float_i32(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const call_prop_t prop) {}

INLINE WEAK
void __csi_before_builtin_double_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1, const call_prop_t prop) {}

INLINE WEAK
void __csi_after_builtin_double_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1, const call_prop_t prop) {}

INLINE WEAK
void __csi_before_builtin_double_double_i32(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const call_prop_t prop) {}

INLINE WEAK
void __csi_after_builtin_double_double_i32(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const call_prop_t prop) {}

INLINE WEAK
void __csi_before_builtin_float_float_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const float operand2, const call_prop_t prop) {}

INLINE WEAK
void __csi_after_builtin_float_float_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const float operand2, const call_prop_t prop) {}

INLINE WEAK
void __csi_before_builtin_double_double_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const double operand2, const call_prop_t prop) {}

INLINE WEAK
void __csi_after_builtin_double_double_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const double operand2, const call_prop_t prop) {}
