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
                             const csi_ir_variable_category_t operand_cat,
                             const csi_id_t operand_id,
                             const store_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_store(const csi_id_t store_id,
                            const void *addr,
                            const int32_t num_bytes,
                            const csi_ir_variable_category_t operand_cat,
                            const csi_id_t operand_id,
                            const store_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_func_entry(const csi_id_t func_id,
                           const csi_id_t first_param_id, int32_t num_params,
                           const func_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_func_exit(const csi_id_t func_exit_id,
                          const csi_id_t func_id,
                          const csi_ir_variable_category_t return_cat,
                          const csi_id_t return_id,
                          const func_exit_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_bb_entry(const csi_id_t bb_id, const bb_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_bb_exit(const csi_id_t bb_id, const bb_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_before_call(csi_id_t callsite_id, csi_id_t func_id,
                            const operand_id_t *operand_ids,
                            int32_t num_operands,
                            const call_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_call(csi_id_t callsite_id, csi_id_t func_id,
                           const call_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_detach(const csi_id_t detach_id, const int32_t *has_spawned) {}

__attribute__((always_inline))
WEAK void __csi_task(const csi_id_t task_id, const csi_id_t detach_id)
{}

__attribute__((always_inline))
WEAK void __csi_task_exit(const csi_id_t task_exit_id,
                          const csi_id_t task_id,
                          const csi_id_t detach_id) {}

__attribute__((always_inline))
WEAK void __csi_detach_continue(const csi_id_t detach_continue_id,
                                const csi_id_t detach_id) {}

__attribute__((always_inline))
WEAK void __csi_before_sync(const csi_id_t sync_id, const int32_t *has_spawned)
{}

__attribute__((always_inline))
WEAK void __csi_after_sync(const csi_id_t sync_id, const int32_t *has_spawned)
{}

__attribute__((always_inline))
WEAK void __csi_before_alloca(const csi_id_t alloca_id,
                              uint64_t num_bytes,
                              const alloca_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_alloca(const csi_id_t alloca_id,
                             const void *addr,
                             uint64_t num_bytes,
                             const alloca_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_before_allocfn(const csi_id_t allocfn_id,
                               uint64_t size, uint64_t num, uint64_t alignment,
                               const void *oldaddr, const allocfn_prop_t prop) {}

__attribute__((always_inline))
WEAK void __csi_after_allocfn(const csi_id_t allocfn_id, const void *addr,
                              uint64_t size, uint64_t num, uint64_t alignment,
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

// Simple arithmetic ops.
/* __attribute__((always_inline)) WEAK void __csi_before_arithmetic_half( */
/*     const csi_id_t arith_id, const csi_opcode_t opcode, */
/*     const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id, */
/*     const _Float16 operand0, const csi_ir_variable_category_t operand1_cat, */
/*     const csi_id_t operand1_id, const _Float16 operand1, */
/*     const arithmetic_flags_t flags) {} */

__attribute__((always_inline)) WEAK void __csi_before_arithmetic_float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1,
    const arithmetic_flags_t flags) {}

__attribute__((always_inline)) WEAK void __csi_before_arithmetic_double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1,
    const arithmetic_flags_t flags) {}

__attribute__((always_inline)) WEAK void __csi_before_arithmetic_i8(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint8_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint8_t operand1,
    const arithmetic_flags_t flags) {}

__attribute__((always_inline)) WEAK void __csi_before_arithmetic_i16(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint16_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint16_t operand1,
    const arithmetic_flags_t flags) {}

__attribute__((always_inline)) WEAK void __csi_before_arithmetic_i32(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint32_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint32_t operand1,
    const arithmetic_flags_t flags) {}

__attribute__((always_inline)) WEAK void __csi_before_arithmetic_i64(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint64_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint64_t operand1,
    const arithmetic_flags_t flags) {}

__attribute__((always_inline)) WEAK void __csi_before_arithmetic_i128(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const __uint128_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const __uint128_t operand1,
    const arithmetic_flags_t flags) {}

// Floating-point extension and truncation
/* __attribute__((always_inline)) WEAK void __csi_before_extend_half_float( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_extend_half_double( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

__attribute__((always_inline)) WEAK void __csi_before_extend_float_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_truncate_double_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

/* __attribute__((always_inline)) WEAK void __csi_before_truncate_double_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const double operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_truncate_float_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const float operand) {} */

// Conversion from floating-point to unsigned integer
/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_unsigned_i8( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_unsigned_i16( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_unsigned_i32( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_unsigned_i64( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_unsigned_i128( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

__attribute__((always_inline)) WEAK void __csi_before_convert_float_unsigned_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_float_unsigned_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_float_unsigned_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_float_unsigned_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_float_unsigned_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_unsigned_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_unsigned_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_unsigned_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_unsigned_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_unsigned_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

// Conversion from floating-point to signed integer
/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_signed_i8( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_signed_i16( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_signed_i32( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_signed_i64( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_half_signed_i128( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

__attribute__((always_inline)) WEAK void __csi_before_convert_float_signed_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_float_signed_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_float_signed_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_float_signed_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_float_signed_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_signed_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_signed_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_signed_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_signed_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_double_signed_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}

// Conversion from unsigned integer to floating-point
/* __attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i8_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint8_t operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i16_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint16_t operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i32_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint32_t operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i64_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint64_t operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i128_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const __uint128_t operand) {} */

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i8_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i16_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i32_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i64_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i128_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i8_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i16_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i32_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i64_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_unsigned_i128_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand) {}

// Conversion from signed integer to floating-point
/* __attribute__((always_inline)) WEAK void __csi_before_convert_signed_i8_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int8_t operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_signed_i16_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int16_t operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_signed_i32_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int32_t operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_signed_i64_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int64_t operand) {} */

/* __attribute__((always_inline)) WEAK void __csi_before_convert_signed_i128_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const __int128_t operand) {} */

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i8_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i16_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i32_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i64_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i128_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i8_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i16_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i32_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i64_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand) {}

__attribute__((always_inline)) WEAK void __csi_before_convert_signed_i128_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand) {}

// PHI node hooks
__attribute__((always_inline)) WEAK void __csi_phi_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand) {}

__attribute__((always_inline)) WEAK void __csi_phi_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand) {}

__attribute__((always_inline)) WEAK void __csi_phi_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand) {}

__attribute__((always_inline)) WEAK void __csi_phi_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand) {}

__attribute__((always_inline)) WEAK void __csi_phi_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand) {}

/* __attribute__((always_inline)) WEAK void __csi_phi_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand) {} */

__attribute__((always_inline)) WEAK void __csi_phi_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand) {}

__attribute__((always_inline)) WEAK void __csi_phi_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand) {}
