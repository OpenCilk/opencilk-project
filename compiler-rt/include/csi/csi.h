#pragma once 

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
#define EXTERN_C extern "C" {
#define EXTERN_C_END }
#else
#define EXTERN_C
#define EXTERN_C_END
#include <stdbool.h> // for C99 bool type
#endif

#define WEAK __attribute__((weak))

// API function signatures
EXTERN_C

typedef float  v4float  __attribute__((__vector_size__(16)));
typedef float  v8float  __attribute__((__vector_size__(32)));
typedef float  v16float  __attribute__((__vector_size__(64)));
typedef double v2double __attribute__((__vector_size__(16)));
typedef double v4double __attribute__((__vector_size__(32)));
typedef double v8double __attribute__((__vector_size__(64)));

typedef int8_t  v2int8_t  __attribute__((__vector_size__(2)));
typedef int8_t  v4int8_t  __attribute__((__vector_size__(4)));
typedef int8_t  v8int8_t  __attribute__((__vector_size__(8)));
typedef int8_t  v16int8_t  __attribute__((__vector_size__(16)));

// TODO: Verify that these struct definitions are suitable for the relevant
// hooks.
typedef struct { float *addr[4]; }  v4floatptr __attribute__((aligned(8)));
typedef struct { float *addr[8]; }  v8floatptr __attribute__((aligned(8)));
typedef struct { float *addr[16]; } v16floatptr __attribute__((aligned(8)));
typedef struct { double *addr[2]; } v2doubleptr __attribute__((aligned(8)));
typedef struct { double *addr[4]; } v4doubleptr __attribute__((aligned(8)));
typedef struct { double *addr[8]; } v8doubleptr __attribute__((aligned(8)));

/**
 * Unless a type requires bitwise operations (e.g., property lists), we use
 * signed integers. We don't need the extra bit of data, and using unsigned
 * integers can lead to subtle bugs. See
 * http://www.soundsoftware.ac.uk/c-pitfall-unsigned
 */

typedef int64_t csi_id_t;

enum CSI_IR_variable_category
  {
   None = 0, // Used for cases where no operand is present, e.g., returns from
             // functions that return void.
   Constant,
   Parameter,
   Global,
   Callsite,
   Load,
   Alloca,
   AllocFn,
   Arithmetic
  };
typedef int8_t csi_ir_variable_category_t;

enum CSITerminatorTy
  {
   UnconditionalBr = 0,
   ConditionalBr,
   Switch,
   Call,
   Invoke,
   Return,
   EHReturn,
   Unreachable,
   Detach,
   Reattach,
   Sync,
   IndirectBr,
  };

enum CSI_arithmetic_opcode
  {
   Add = 0,
   FAdd,
   Sub,
   FSub,
   Mul,
   FMul,
   UDiv,
   SDiv,
   FDiv,
   URem,
   SRem,
   FRem,
   Shl,
   LShr,
   AShr,
   And,
   Or,
   Xor,
   ICmp_EQ,
   ICmp_NE,
   ICmp_UGT,
   ICmp_UGE,
   ICmp_ULT,
   ICmp_ULE,
   ICmp_SGT,
   ICmp_SGE,
   ICmp_SLT,
   ICmp_SLE,
   FCmp_False,
   FCmp_OEQ,
   FCmp_OGT,
   FCmp_OGE,
   FCmp_OLT,
   FCmp_OLE,
   FCmp_ONE,
   FCmp_ORD,
   FCmp_UNO,
   FCmp_UEQ,
   FCmp_UGT,
   FCmp_UGE,
   FCmp_ULT,
   FCmp_ULE,
   FCmp_UNE,
   FCmp_True,
  };
typedef int8_t csi_opcode_t;

enum CSI_builtin_func_op
  {
   F_Fma = 0,
   F_Sqrt,
   F_Cbrt,
   F_Sin,
   F_Cos,
   F_Tan,
   F_SinPi,
   F_CosPi,
   F_SinCosPi,
   F_ASin,
   F_ACos,
   F_ATan,
   F_ATan2,
   F_Sinh,
   F_Cosh,
   F_Tanh,
   F_ASinh,
   F_ACosh,
   F_ATanh,
   F_Log,
   F_Log2,
   F_Log10,
   F_Logb,
   F_Log1p,
   F_Exp,
   F_Exp2,
   F_Exp10,
   F_Expm1,
   F_Fabs,
   F_Floor,
   F_Ceil,
   F_Fmod,
   F_Trunc,
   F_Rint,
   F_NearbyInt,
   F_Round,
   F_Canonicalize,
   F_Pow,
   F_CopySign,
   F_MinNum,  // Same as FMin
   F_MaxNum,  // Same as FMax
   F_Ldexp,
  };
typedef int8_t csi_builtin_func_op_t;

#define UNKNOWN_CSI_ID ((csi_id_t)-1)

typedef struct {
  csi_id_t num_func;
  csi_id_t num_func_exit;
  csi_id_t num_loop;
  csi_id_t num_loop_exit;
  csi_id_t num_bb;
  csi_id_t num_callsite;
  csi_id_t num_load;
  csi_id_t num_store;
  csi_id_t num_detach;
  csi_id_t num_task;
  csi_id_t num_task_exit;
  csi_id_t num_detach_continue;
  csi_id_t num_sync;
  csi_id_t num_alloca;
  csi_id_t num_allocfn;
  csi_id_t num_free;
  csi_id_t num_arithmetic;
  csi_id_t num_parameter;
  csi_id_t num_global;
} instrumentation_counts_t;

// Property bitfields.

typedef struct {
  // The function might spawn.
  unsigned may_spawn : 1;
  // Pad struct to 64 total bits.
  uint64_t _padding : 63;
} func_prop_t;

typedef struct {
  // The function might have spawned.
  unsigned may_spawn : 1;
  // This function exit returns an exception.
  unsigned eh_return : 1;
  // Pad struct to 64 total bits.
  uint64_t _padding : 62;
} func_exit_prop_t;

typedef struct {
  // The basic block is a landingpad.
  unsigned is_landingpad : 1;
  // The basic block is an exception-handling pad.
  unsigned is_ehpad : 1;
  // The basic block, excluding its PHIs and terminator, contains no
  // instructions that perform real computation.
  unsigned is_empty : 1;
  // The basic block, excluding its PHIs and terminator, contains no
  // instructions that are instrumented.
  unsigned no_instrumented_content : 1;
  // The type of terminator instruction at the end of this basic block.
  unsigned terminator_ty : 4;
  // Pad struct to 64 total bits.
  uint64_t _padding : 56;
} bb_prop_t;

typedef struct {
  // The loop is a Tapir loop
  unsigned is_tapir_loop : 1;
  // The loop has one exiting block: the latch.
  unsigned has_one_exiting_block : 1;
  uint64_t _padding : 62;
} loop_prop_t;

typedef struct {
  // This exiting block of the loop is a latch.
  unsigned is_latch : 1;
  uint64_t _padding : 63;
} loop_exit_prop_t;

typedef struct {
  // The call is indirect.
  unsigned is_indirect : 1;
  // The call's return value has one use.
  unsigned has_one_use : 1;
  // Value produced is only used in the same BB.
  unsigned bb_local_uses_only : 1;
  // Pad struct to 64 total bits.
  uint64_t _padding : 61;
} call_prop_t;

typedef struct {
  // The alignment of the load.
  unsigned alignment : 8;
  // The loaded address is in a vtable.
  unsigned is_vtable_access : 1;
  // The loaded address points to constant data.
  unsigned is_constant : 1;
  // The loaded address is on the stack.
  unsigned is_on_stack : 1;
  // The loaded address can be captured.
  unsigned may_be_captured : 1;
  // The load is volatile.
  unsigned is_volatile : 1;
  // The loaded address is read before it is written in the same basic block.
  unsigned is_read_before_write_in_bb : 1;
  // The loaded value has one use.
  unsigned has_one_use : 1;
  // Value produced is only used in the same BB.
  unsigned bb_local_uses_only : 1;
  // Pad struct to 64 total bits.
  uint64_t _padding : 48;
} load_prop_t;

typedef struct {
  // The alignment of the store.
  unsigned alignment : 8;
  // The stored address is in a vtable.
  unsigned is_vtable_access : 1;
  // The stored address points to constant data.
  unsigned is_constant : 1;
  // The stored address is on the stack.
  unsigned is_on_stack : 1;
  // The stored address cannot be captured.
  unsigned may_be_captured : 1;
  // The store is volatile.
  unsigned is_volatile : 1;
  // Pad struct to 64 total bits.
  uint64_t _padding : 51;
} store_prop_t;

typedef struct {
  // The alloca is static.
  unsigned is_static : 1;
  // The alloca'd address can be captured.
  unsigned may_be_captured : 1;
  // TODO? Add bb_local_uses_only property
  // Pad struct to 64 total bits.
  uint64_t _padding : 62;
} alloca_prop_t;

typedef struct {
  // Type of the allocation function (e.g., malloc, calloc, new).
  unsigned allocfn_ty : 8;
  // The allocated address can be captured.
  unsigned may_be_captured : 1;
  // TODO? Add bb_local_uses_only property
  // Pad struct to 64 total bits.
  uint64_t _padding : 55;
} allocfn_prop_t;

typedef struct {
  // Type of the free function (e.g., free, delete).
  unsigned free_ty : 8;
  // Pad struct to 64 total bits.
  uint64_t _padding : 56;
} free_prop_t;

typedef struct {
  // Flags for arithmetic ops
  unsigned no_signed_wrap : 1;
  unsigned no_unsigned_wrap : 1;
  unsigned is_exact : 1;
  unsigned allow_reassoc : 1;
  unsigned no_NaNs : 1;
  unsigned no_infs : 1;
  unsigned no_signed_zeros : 1;
  unsigned allow_reciprocal : 1;
  unsigned allow_contract : 1;
  unsigned approx_func : 1;
  unsigned is_in_bounds : 1;
  unsigned has_one_use : 1;
  // Value produced is only used in the same BB.
  unsigned bb_local_uses_only : 1;
  // Pad struct to 64 total bits.
  uint64_t _padding : 51;
} arithmetic_flags_t;

typedef struct {
  const csi_ir_variable_category_t operand_cat;
  const csi_id_t operand_id;
  const int64_t index_operand;
} index_id_t;

WEAK void __csi_init();

WEAK void __csi_unit_init(const char *const file_name,
                          const instrumentation_counts_t counts);

///-----------------------------------------------------------------------------
/// Function entry/exit
WEAK void __csi_func_entry(const csi_id_t func_id,
                           const csi_id_t first_param_id, int32_t num_params,
                           const func_prop_t prop);

WEAK void __csi_func_exit(const csi_id_t func_exit_id, const csi_id_t func_id,
                          const func_exit_prop_t prop);

///-----------------------------------------------------------------------------
/// Loop hooks.  The before_loop hook occurs just before the loop begins
/// execution, i.e., in a loop preheader block.  The loopbody_entry hook
/// executes at the beginning of each loop iteration.  The loopbody_exit hook
/// executes at the end of each iteration.  The after_loop hook occurs just
/// after the loop completes execution, i.e., in each dedicated exit from the
/// loop.  Loops are transformed into a canonical form before instrumentation is
/// inserted to ensure that before_loop and after_loop hooks are encountered as
/// a pair.
///
/// TODO: Pass loop IVs to the loopbody_entry hook?
WEAK void __csi_before_loop(const csi_id_t loop_id, const uint64_t trip_count,
                            const loop_prop_t prop);
WEAK void __csi_after_loop(const csi_id_t loop_id, const loop_prop_t prop);
WEAK void __csi_loopbody_entry(const csi_id_t loop_id, const loop_prop_t prop);
WEAK void __csi_loopbody_exit(const csi_id_t loop_exit_id,
                              const csi_id_t loop_id,
                              const loop_exit_prop_t prop);

///-----------------------------------------------------------------------------
/// Basic block entry/exit.  The bb_entry hook comes after any PHI hooks in that
/// basic block.  The bb_exit hook comes before any hooks for terminators, e.g.,
/// for invoke instructions.
WEAK void __csi_bb_entry(const csi_id_t bb_id, const csi_id_t pred_bb_id,
                         const bb_prop_t prop);

WEAK void __csi_bb_exit(const csi_id_t bb_id, const bb_prop_t prop);

///-----------------------------------------------------------------------------
/// Callsite hooks
WEAK void __csi_before_call(const csi_id_t call_id, const csi_id_t parent_bb_id,
                            const csi_id_t func_id, const call_prop_t prop);

WEAK void __csi_after_call(const csi_id_t call_id, const csi_id_t func_id,
                           const call_prop_t prop);

///-----------------------------------------------------------------------------
/// Hooks for loads and stores
WEAK void __csi_before_load(const csi_id_t load_id, const void *addr,
                            const int32_t num_bytes,
                            const csi_ir_variable_category_t obj_operand_cat,
                            const csi_id_t obj_operand_id,
                            const load_prop_t prop);

WEAK void __csi_after_load(const csi_id_t load_id, const void *addr,
                           const int32_t num_bytes,
                           const csi_ir_variable_category_t obj_operand_cat,
                           const csi_id_t obj_operand_id,
                           const load_prop_t prop);

WEAK void __csi_before_store(const csi_id_t store_id, const void *addr,
                             const int32_t num_bytes,
                             const csi_ir_variable_category_t operand_cat,
                             const csi_id_t operand_id,
                             const csi_ir_variable_category_t obj_operand_cat,
                             const csi_id_t obj_operand_id,
                             const store_prop_t prop);

WEAK void __csi_after_store(const csi_id_t store_id, const void *addr,
                            const int32_t num_bytes,
                            const csi_ir_variable_category_t operand_cat,
                            const csi_id_t operand_id,
                            const csi_ir_variable_category_t obj_operand_cat,
                            const csi_id_t obj_operand_id,
                            const store_prop_t prop);

///-----------------------------------------------------------------------------
/// Masked vector loads, stores, scatters, gathers
WEAK void __csi_before_masked_load_v4float(
    const csi_id_t load_id, const v4float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4float passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_load_v4float(
    const csi_id_t load_id, const v4float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4float passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_load_v8float(
    const csi_id_t load_id, const v8float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8float passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_load_v8float(
    const csi_id_t load_id, const v8float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8float passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_load_v16float(
    const csi_id_t load_id, const v16float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v16float passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_load_v16float(
    const csi_id_t load_id, const v16float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v16float passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_load_v2double(
    const csi_id_t load_id, const v2double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v2double passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_load_v2double(
    const csi_id_t load_id, const v2double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v2double passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_load_v4double(
    const csi_id_t load_id, const v4double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4double passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_load_v4double(
    const csi_id_t load_id, const v4double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4double passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_load_v8double(
    const csi_id_t load_id, const v8double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8double passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_load_v8double(
    const csi_id_t load_id, const v8double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8double passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_gather_v4float(
    const csi_id_t load_id, const v4floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4float passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_gather_v4float(
    const csi_id_t load_id, const v4floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4float passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_gather_v8float(
    const csi_id_t load_id, const v8floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8float passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_gather_v8float(
    const csi_id_t load_id, const v8floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8float passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_gather_v16float(
    const csi_id_t load_id, const v16floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v16float passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_gather_v16float(
    const csi_id_t load_id, const v16floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v16float passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_gather_v2double(
    const csi_id_t load_id, const v2doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v2double passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_gather_v2double(
    const csi_id_t load_id, const v2doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v2double passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_gather_v4double(
    const csi_id_t load_id, const v4doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4double passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_gather_v4double(
    const csi_id_t load_id, const v4doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v4double passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_gather_v8double(
    const csi_id_t load_id, const v8doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8double passthru,
    const load_prop_t prop);

WEAK void __csi_after_masked_gather_v8double(
    const csi_id_t load_id, const v8doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t passthru_cat,
    const csi_id_t passthru_id, v8double passthru,
    const load_prop_t prop);

WEAK void __csi_before_masked_store_v4float(
    const csi_id_t store_id, const v4float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4float operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_store_v4float(
    const csi_id_t store_id, const v4float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4float operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_store_v8float(
    const csi_id_t store_id, const v8float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8float operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_store_v8float(
    const csi_id_t store_id, const v8float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8float operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_store_v16float(
    const csi_id_t store_id, const v16float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v16float operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_store_v16float(
    const csi_id_t store_id, const v16float *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v16float operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_store_v2double(
    const csi_id_t store_id, const v2double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v2double operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_store_v2double(
    const csi_id_t store_id, const v2double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v2double operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_store_v4double(
    const csi_id_t store_id, const v4double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4double operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_store_v4double(
    const csi_id_t store_id, const v4double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4double operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_store_v8double(
    const csi_id_t store_id, const v8double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8double operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_store_v8double(
    const csi_id_t store_id, const v8double *addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8double operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_scatter_v4float(
    const csi_id_t store_id, const v4floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4float operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_scatter_v4float(
    const csi_id_t store_id, const v4floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4float operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_scatter_v8float(
    const csi_id_t store_id, const v8floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8float operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_scatter_v8float(
    const csi_id_t store_id, const v8floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8float operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_scatter_v16float(
    const csi_id_t store_id, const v16floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v16float operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_scatter_v16float(
    const csi_id_t store_id, const v16floatptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v16int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v16float operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_scatter_v2double(
    const csi_id_t store_id, const v2doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v2double operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_scatter_v2double(
    const csi_id_t store_id, const v2doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v2int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v2double operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_scatter_v4double(
    const csi_id_t store_id, const v4doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4double operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_scatter_v4double(
    const csi_id_t store_id, const v4doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v4int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v4double operand,
    const store_prop_t prop);

WEAK void __csi_before_masked_scatter_v8double(
    const csi_id_t store_id, const v8doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8double operand,
    const store_prop_t prop);

WEAK void __csi_after_masked_scatter_v8double(
    const csi_id_t store_id, const v8doubleptr addr,
    const csi_ir_variable_category_t mask_cat,
    const csi_id_t mask_id, v8int8_t mask,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, v8double operand,
    const store_prop_t prop);

///-----------------------------------------------------------------------------
/// Hooks for Tapir control flow.
WEAK void __csi_detach(const csi_id_t detach_id, const int32_t *has_spawned);

WEAK void __csi_task(const csi_id_t task_id, const csi_id_t detach_id);

WEAK void __csi_task_exit(const csi_id_t task_exit_id, const csi_id_t task_id,
                          const csi_id_t detach_id);

WEAK void __csi_detach_continue(const csi_id_t detach_continue_id,
                                const csi_id_t detach_id);

WEAK void __csi_before_sync(const csi_id_t sync_id, const int32_t *has_spawned);
WEAK void __csi_after_sync(const csi_id_t sync_id, const int32_t *has_spawned);

///-----------------------------------------------------------------------------
/// Hooks for memory allocation
WEAK void __csi_before_alloca(const csi_id_t alloca_id, uint64_t num_bytes,
                              const alloca_prop_t prop);

WEAK void __csi_after_alloca(const csi_id_t alloca_id, const void *addr,
                             uint64_t num_bytes, const alloca_prop_t prop);

WEAK void __csi_before_allocfn(const csi_id_t allocfn_id, uint64_t size,
                               uint64_t num, uint64_t alignment,
                               const void *oldaddr, const allocfn_prop_t prop);

WEAK void __csi_after_allocfn(const csi_id_t alloca_id, const void *addr,
                              uint64_t size, uint64_t num, uint64_t alignment,
                              const void *oldaddr, const allocfn_prop_t prop);

WEAK void __csi_before_free(const csi_id_t free_id, const void *ptr,
                            const free_prop_t prop);

WEAK void __csi_after_free(const csi_id_t free_id, const void *ptr,
                           const free_prop_t prop);

///-----------------------------------------------------------------------------
/// Simple arithmetic ops.

// Floating point
/* WEAK void __csi_before_arithmetic_half( */
/*     const csi_id_t arith_id, const csi_opcode_t opcode, */
/*     const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id, */
/*     const _Float16 operand0, const csi_ir_variable_category_t operand1_cat, */
/*     const csi_id_t operand1_id, const _Float16 operand1, */
/*     const arithmetic_flags_t flags); */

WEAK void __csi_before_arithmetic_float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1,
    const arithmetic_flags_t flags);

// Integer
WEAK void __csi_before_arithmetic_i8(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint8_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint8_t operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_i16(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint16_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint16_t operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_i32(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint32_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint32_t operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_i64(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint64_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint64_t operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_i128(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const __uint128_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const __uint128_t operand1,
    const arithmetic_flags_t flags);

// Vector
WEAK void __csi_before_arithmetic_v4float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v4float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4float operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_v8float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v8float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8float operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_v16float(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v16float operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v16float operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_v2double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v2double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v2double operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_v4double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v4double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4double operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_arithmetic_v8double(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const v8double operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8double operand1,
    const arithmetic_flags_t flags);

// Pointer operations
//
// For consistency with other hooks, pointer arguments are always passed as
// void*.
WEAK void __csi_before_bitcast_pi32_pi8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand, const arithmetic_flags_t flags);

WEAK void __csi_before_bitcast_pi8_pi32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand, const arithmetic_flags_t flags);

WEAK void __csi_before_getelementptr_pi8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand,
    const index_id_t *indices, int32_t num_indices,
    const arithmetic_flags_t flags);

WEAK void __csi_before_getelementptr_pi32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand,
    const index_id_t *indices, int32_t num_indices,
    const arithmetic_flags_t flags);

WEAK void __csi_before_getelementptr_pi64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand,
    const index_id_t *indices, int32_t num_indices,
    const arithmetic_flags_t flags);

WEAK void __csi_before_getelementptr_pfloat(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand,
    const index_id_t *indices, int32_t num_indices,
    const arithmetic_flags_t flags);

WEAK void __csi_before_getelementptr_pdouble(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand,
    const index_id_t *indices, int32_t num_indices,
    const arithmetic_flags_t flags);

WEAK void __csi_before_inttoptr_i64_pi32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand,
    const arithmetic_flags_t flags);

WEAK void __csi_before_ptrtoint_pi32_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand,
    const arithmetic_flags_t flags);

// Floating-point extension and truncation
/* WEAK void __csi_before_extend_half_float( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_extend_half_double( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

WEAK void __csi_before_extend_float_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_truncate_double_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

/* WEAK void __csi_before_truncate_double_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_truncate_float_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags); */

// Conversion from floating-point to unsigned integer
/* WEAK void __csi_before_convert_half_unsigned_i8( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_half_unsigned_i16( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_half_unsigned_i32( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_half_unsigned_i64( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_half_unsigned_i128( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

// Floating-point-integer conversions
WEAK void __csi_before_convert_float_unsigned_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_float_unsigned_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_float_unsigned_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_float_unsigned_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_float_unsigned_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_unsigned_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_unsigned_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_unsigned_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_unsigned_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_unsigned_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

// Conversion from floating-point to signed integer
/* WEAK void __csi_before_convert_half_signed_i8( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_half_signed_i16( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_half_signed_i32( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_half_signed_i64( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_half_signed_i128( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

WEAK void __csi_before_convert_float_signed_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_float_signed_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_float_signed_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_float_signed_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_float_signed_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_signed_i8(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_signed_i16(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_signed_i32(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_signed_i64(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_double_signed_i128(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

// Conversion from unsigned integer to floating-point
/* WEAK void __csi_before_convert_unsigned_i8_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_unsigned_i16_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_unsigned_i32_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_unsigned_i64_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_unsigned_i128_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags); */

WEAK void __csi_before_convert_unsigned_i8_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i16_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i32_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i64_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i128_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i8_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i16_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i32_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i64_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i128_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags);

// Vector versions for floating point
WEAK void __csi_before_convert_unsigned_i8_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i16_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i32_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i64_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i128_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i8_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i16_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i32_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i64_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i8_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i16_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i32_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);


WEAK void __csi_before_convert_unsigned_i8_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i16_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i32_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i64_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i128_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i8_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i16_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i32_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i64_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i128_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i8_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i16_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i32_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_unsigned_i64_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags);

// Conversion from signed integer to floating-point
/* WEAK void __csi_before_convert_signed_i8_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_signed_i16_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_signed_i32_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_signed_i64_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags); */

/* WEAK void __csi_before_convert_signed_i128_half( */
/*     const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags); */

WEAK void __csi_before_convert_signed_i8_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i16_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i32_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i64_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i128_float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i8_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i16_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i32_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i64_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i128_double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags);

// Vector versions for floating point
WEAK void __csi_before_convert_signed_i8_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i16_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i32_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i64_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i128_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i8_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i16_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i32_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i64_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i8_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i16_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i32_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags);


WEAK void __csi_before_convert_signed_i8_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i16_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i32_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i64_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i128_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i8_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i16_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i32_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i64_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i128_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i8_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i16_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i32_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i64_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const int64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_before_convert_signed_i128_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __int128_t operand, const arithmetic_flags_t flags);

// Vector operations
WEAK void __csi_before_extract_element_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_extract_element_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_extract_element_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_extract_element_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_extract_element_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_extract_element_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_insert_element_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_insert_element_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_insert_element_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_insert_element_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_insert_element_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_insert_element_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v4float_v4float_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4float operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v4float_v4float_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8float operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v4float_v4float_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v16float operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v8float_v8float_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4float operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v8float_v8float_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8float operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v8float_v8float_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v16float operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v16float_v16float_v4float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v16float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4float operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v16float_v16float_v8float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v16float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8float operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v16float_v16float_v16float(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v16float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v16float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v16float operand2, const arithmetic_flags_t flags);


WEAK void __csi_before_shuffle_v2double_v2double_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v2double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v2double operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v2double_v2double_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v2double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4double operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v2double_v2double_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v2double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v2double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8double operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v4double_v4double_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v2double operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v4double_v4double_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4double operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v4double_v4double_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v4double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v4double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8double operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v8double_v8double_v2double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v2double operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v8double_v8double_v4double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v4double operand2, const arithmetic_flags_t flags);

WEAK void __csi_before_shuffle_v8double_v8double_v8double(
    const csi_id_t arith_id, const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const v8double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const v8double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const v8double operand2, const arithmetic_flags_t flags);

// PHI node hooks
// Integer types
WEAK void __csi_phi_i8(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_i16(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint16_t operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_i32(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint32_t operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_i64(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint64_t operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_i128(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const __uint128_t operand, const arithmetic_flags_t flags);

// Floating-point types
/* WEAK void __csi_phi_half( */
/*     const csi_id_t arith_id, const csi_id_t parent_bb_id, */
/*     const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat, */
/*     const csi_id_t operand_id, const _Float16 operand, const arithmetic_flags_t flags); */

WEAK void __csi_phi_float(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_double(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const arithmetic_flags_t flags);

// Pointer types
//
// For consistency with other hooks, pointer arguments are always passed as
// void*.
WEAK void __csi_phi_pi8(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_pi32(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const void *operand, const arithmetic_flags_t flags);

// Vector types
WEAK void __csi_phi_v4float(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v4float operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_v8float(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v8float operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_v16float(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v16float operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_v2double(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v2double operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_v4double(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v4double operand, const arithmetic_flags_t flags);

WEAK void __csi_phi_v8double(
    const csi_id_t arith_id, const csi_id_t parent_bb_id,
    const csi_id_t predecessor_bb_id, const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const v8double operand, const arithmetic_flags_t flags);


WEAK void __csi_before_cmp_i32(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint32_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint32_t operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_cmp_i64(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const uint64_t operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const uint64_t operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_cmp_pi32(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const void *operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const void *operand1,
    const arithmetic_flags_t flags);

WEAK void __csi_before_cmp_pi64(
    const csi_id_t arith_id, const csi_opcode_t opcode,
    const csi_ir_variable_category_t operand0_cat, const csi_id_t operand0_id,
    const void *operand0, const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const void *operand1,
    const arithmetic_flags_t flags);

///-----------------------------------------------------------------------------
/// Hooks for builtin functions
WEAK void __csi_before_memset(
    const csi_id_t call_id, const void *addr, const size_t num_bytes,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand);

WEAK void __csi_after_memset(
    const csi_id_t call_id, const void *addr, const size_t num_bytes,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const uint8_t operand);

WEAK void __csi_before_memcpy(
    const csi_id_t call_id, const void *dst, const void *src,
    const size_t num_bytes);

WEAK void __csi_after_memcpy(
    const csi_id_t call_id, const void *dst, const void *src,
    const size_t num_bytes);

WEAK void __csi_before_memmove(
    const csi_id_t call_id, const void *dst, const void *src,
    const size_t num_bytes);

WEAK void __csi_after_memmove(
    const csi_id_t call_id, const void *dst, const void *src,
    const size_t num_bytes);

// Floating-point builtins
WEAK void __csi_before_builtin_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const call_prop_t prop);

WEAK void __csi_after_builtin_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const float operand, const call_prop_t prop);

WEAK void __csi_before_builtin_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const call_prop_t prop);

WEAK void __csi_after_builtin_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand_cat,
    const csi_id_t operand_id, const double operand, const call_prop_t prop);

WEAK void __csi_before_builtin_float_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1, const call_prop_t prop);

WEAK void __csi_after_builtin_float_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1, const call_prop_t prop);

WEAK void __csi_before_builtin_float_float_i32(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const call_prop_t prop);

WEAK void __csi_after_builtin_float_float_i32(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const call_prop_t prop);

WEAK void __csi_before_builtin_double_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1, const call_prop_t prop);

WEAK void __csi_after_builtin_double_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1, const call_prop_t prop);

WEAK void __csi_before_builtin_double_double_i32(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const call_prop_t prop);

WEAK void __csi_after_builtin_double_double_i32(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const int32_t operand1, const call_prop_t prop);

WEAK void __csi_before_builtin_float_float_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const float operand2, const call_prop_t prop);

WEAK void __csi_after_builtin_float_float_float_float(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const float operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const float operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const float operand2, const call_prop_t prop);

WEAK void __csi_before_builtin_double_double_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const double operand2, const call_prop_t prop);

WEAK void __csi_after_builtin_double_double_double_double(
    const csi_id_t call_id, const csi_builtin_func_op_t func_op,
    const csi_ir_variable_category_t operand0_cat,
    const csi_id_t operand0_id, const double operand0,
    const csi_ir_variable_category_t operand1_cat,
    const csi_id_t operand1_id, const double operand1,
    const csi_ir_variable_category_t operand2_cat,
    const csi_id_t operand2_id, const double operand2, const call_prop_t prop);

// CSI provides additional typed hooks:
//
// void __csi_bb_input_TYPE(
//     const csi_id_t bb_id, const csi_ir_variable_category_t operand_cat,
//     const csi_id_t operand_id, CTYPE operand_value,
//     const arithmetic_flags_t flags);
//
// void __csi_call_input_TYPE(
//     const csi_id_t call_id, const csi_ir_variable_category_t operand_cat,
//     const csi_id_t operand_id, CTYPE operand_value,
//     const arithmetic_flags_t flags);
//
// void __csi_loop_input_TYPE(
//     const csi_id_t loop_id, const csi_ir_variable_category_t operand_cat,
//     const csi_id_t operand_id, CTYPE operand_value,
//     const arithmetic_flags_t flags);
//
// void __csi_task_input_TYPE(
//     const csi_id_t task_id, const csi_ir_variable_category_t operand_cat,
//     const csi_id_t operand_id, CTYPE operand_value,
//     const arithmetic_flags_t flags);
//
// In these hooks, TYPE corresponds to the type of the variable in the IR, and
// CTYPE is the type in C that most closely corresponds to TYPE.
//
// Because these input hooks do not correspond to proper IR objects, they are
// not assigned their own CSI IDs.
//
// TODO? Assign proper CSI IDs to input hooks.


// This struct is mirrored in ComprehensiveStaticInstrumentation.cpp,
// FrontEndDataTable::getSourceLocStructType.
typedef struct {
  char *name;
  // TODO(ddoucet): Why is this 32 bits?
  int32_t line_number;
  int32_t column_number;
  char *filename;
} source_loc_t;

typedef struct {
  int32_t full_ir_size;
  int32_t non_empty_size;
} sizeinfo_t;

// Front-end data (FED) table accessors.  All such accessors should look like
// accesses to constant data.
__attribute__((const))
const source_loc_t *__csi_get_func_source_loc(const csi_id_t func_id);
__attribute__((const))
const source_loc_t *__csi_get_func_exit_source_loc(const csi_id_t func_exit_id);
__attribute__((const))
const source_loc_t *__csi_get_loop_source_loc(const csi_id_t loop_id);
__attribute__((const))
const source_loc_t *__csi_get_loop_exit_source_loc(const csi_id_t loop_exit_id);
__attribute__((const))
const source_loc_t *__csi_get_bb_source_loc(const csi_id_t bb_id);
__attribute__((const))
const source_loc_t *__csi_get_callsite_source_loc(const csi_id_t call_id);
__attribute__((const))
const source_loc_t *__csi_get_load_source_loc(const csi_id_t load_id);
__attribute__((const))
const source_loc_t *__csi_get_store_source_loc(const csi_id_t store_id);
__attribute__((const))
const source_loc_t *__csi_get_detach_source_loc(const csi_id_t detach_id);
__attribute__((const))
const source_loc_t *__csi_get_task_source_loc(const csi_id_t task_id);
__attribute__((const))
const source_loc_t *__csi_get_task_exit_source_loc(const csi_id_t task_exit_id);
__attribute__((const))
const source_loc_t *
__csi_get_detach_continue_source_loc(const csi_id_t detach_continue_id);
__attribute__((const))
const source_loc_t *__csi_get_sync_source_loc(const csi_id_t sync_id);
__attribute__((const))
const source_loc_t *__csi_get_alloca_source_loc(const csi_id_t alloca_id);
__attribute__((const))
const source_loc_t *__csi_get_allocfn_source_loc(const csi_id_t allocfn_id);
__attribute__((const))
const source_loc_t *__csi_get_free_source_loc(const csi_id_t free_id);
__attribute__((const))
const source_loc_t *__csi_get_arithmetic_source_loc(const csi_id_t arith_id);
__attribute__((const))
const source_loc_t *__csi_get_parameter_source_loc(const csi_id_t param_id);
__attribute__((const))
const source_loc_t *__csi_get_global_source_loc(const csi_id_t global_id);
__attribute__((const))
const sizeinfo_t *__csi_get_bb_sizeinfo(const csi_id_t bb_id);

__attribute__((const))
const char *__csan_get_allocfn_str(const allocfn_prop_t prop);
__attribute__((const))
const char *__csan_get_free_str(const free_prop_t prop);

EXTERN_C_END
