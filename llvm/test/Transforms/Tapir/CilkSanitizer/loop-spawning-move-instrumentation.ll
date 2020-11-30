; RUN: opt < %s -loop-spawning-ti -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt*, %struct._IO_wide_data*, %struct._IO_FILE*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type opaque
%struct._IO_codecvt = type opaque
%struct._IO_wide_data = type opaque
%struct.wsp_t = type { i64, i64, i64 }
%"class.std::basic_ostream" = type { i32 (...)**, %"class.std::basic_ios" }
%"class.std::basic_ios" = type { %"class.std::ios_base", %"class.std::basic_ostream"*, i8, i8, %"class.std::basic_streambuf"*, %"class.std::ctype"*, %"class.std::num_put"*, %"class.std::num_get"* }
%"class.std::ios_base" = type { i32 (...)**, i64, i64, i32, i32, i32, %"struct.std::ios_base::_Callback_list"*, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, %"struct.std::ios_base::_Words"*, %"class.std::locale" }
%"struct.std::ios_base::_Callback_list" = type { %"struct.std::ios_base::_Callback_list"*, void (i32, %"class.std::ios_base"*, i32)*, i32, i32 }
%"struct.std::ios_base::_Words" = type { i8*, i64 }
%"class.std::locale" = type { %"class.std::locale::_Impl"* }
%"class.std::locale::_Impl" = type { i32, %"class.std::locale::facet"**, i64, %"class.std::locale::facet"**, i8** }
%"class.std::locale::facet" = type <{ i32 (...)**, i32, [4 x i8] }>
%"class.std::basic_streambuf" = type { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, %"class.std::locale" }
%"class.std::ctype" = type <{ %"class.std::locale::facet.base", [4 x i8], %struct.__locale_struct*, i8, [7 x i8], i32*, i32*, i16*, i8, [256 x i8], [256 x i8], i8, [6 x i8] }>
%"class.std::locale::facet.base" = type <{ i32 (...)**, i32 }>
%struct.__locale_struct = type { [13 x %struct.__locale_data*], i16*, i32*, i32*, [13 x i8*] }
%struct.__locale_data = type opaque
%"class.std::num_put" = type { %"class.std::locale::facet.base", [4 x i8] }
%"class.std::num_get" = type { %"class.std::locale::facet.base", [4 x i8] }
%"class.std::basic_ofstream" = type { %"class.std::basic_ostream.base", %"class.std::basic_filebuf", %"class.std::basic_ios" }
%"class.std::basic_ostream.base" = type { i32 (...)** }
%"class.std::basic_filebuf" = type { %"class.std::basic_streambuf", %union.pthread_mutex_t, %"class.std::__basic_file", i32, %struct.__mbstate_t, %struct.__mbstate_t, %struct.__mbstate_t, i8*, i64, i8, i8, i8, i8, i8*, i8*, i8, %"class.std::codecvt"*, i8*, i64, i8*, i8* }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%"class.std::__basic_file" = type <{ %struct._IO_FILE*, i8, [7 x i8] }>
%struct.__mbstate_t = type { i32, %union.anon }
%union.anon = type { i32 }
%"class.std::codecvt" = type { %"class.std::__codecvt_abstract_base.base", %struct.__locale_struct* }
%"class.std::__codecvt_abstract_base.base" = type { %"class.std::locale::facet.base" }
%"class.cilk::reducer_opadd" = type { %"class.cilk::reducer.base", [56 x i8] }
%"class.cilk::reducer.base" = type { %"class.cilk::internal::reducer_content.base" }
%"class.cilk::internal::reducer_content.base" = type { %"class.cilk::internal::reducer_base", [48 x i8], [8 x i8] }
%"class.cilk::internal::reducer_base" = type { %struct.__cilkrts_hyperobject_base, %"class.cilk::internal::storage_for_object", i8* }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i64, i64, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (i8*, i64)*, void (i8*, i8*)* }
%"class.cilk::internal::storage_for_object" = type { %"class.cilk::internal::aligned_storage" }
%"class.cilk::internal::aligned_storage" = type { [1 x i8] }
%"class.cilk::reducer" = type { %"class.cilk::internal::reducer_content.base", [56 x i8] }
%union.pthread_mutexattr_t = type { i32 }
%"class.cilk::op_add_view" = type { %"class.cilk::scalar_view" }
%"class.cilk::scalar_view" = type { i64 }
%"struct.cilk::op_add" = type { i8 }
%"class.cilk::internal::reducer_content" = type { %"class.cilk::internal::reducer_base", [48 x i8], [8 x i8], [56 x i8] }
%"class.cilk::provisional_guard" = type { %"struct.cilk::op_add"* }
%"class.cilk::monoid_with_view" = type { i8 }
%"class.cilk::monoid_base" = type { i8 }

$_ZN4cilk13reducer_opaddIxEC2ERKx = comdat any

$_ZN4cilk13reducer_opaddIxEdeEv = comdat any

$_ZN4cilk13reducer_opaddIxEpLERKx = comdat any

$_ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv = comdat any

$_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev = comdat any

$__clang_call_terminate = comdat any

$_ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv = comdat any

$_ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_ = comdat any

$_ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev = comdat any

$_ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc = comdat any

$_ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_ = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_ = comdat any

$_ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_ = comdat any

$_ZN4cilk11op_add_viewIxE6reduceEPS1_ = comdat any

$_ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_ = comdat any

$_ZN4cilk11op_add_viewIxEC2Ev = comdat any

$_ZN4cilk11scalar_viewIxEC2Ev = comdat any

$_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_ = comdat any

$_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm = comdat any

$_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv = comdat any

$_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_ = comdat any

$_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_ = comdat any

$_ZN4cilk11op_add_viewIxEC2ERKx = comdat any

$_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev = comdat any

$_ZN4cilk11scalar_viewIxEC2ERKx = comdat any

$_ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv = comdat any

$_ZN4cilk11op_add_viewIxEpLERKx = comdat any

$_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv = comdat any

$_ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_ = comdat any

$_ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv = comdat any

$_ZNK4cilk11scalar_viewIxE14view_get_valueEv = comdat any

$_ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv = comdat any

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE*, align 8
@.str = private unnamed_addr constant [15 x i8] c"Usage: %s [N]\0A\00", align 1
@.str.1 = private unnamed_addr constant [37 x i8] c"Could not allocate memory for 'vals'\00", align 1
@.str.2 = private unnamed_addr constant [31 x i8] c"Calculate sum of %ld integers\0A\00", align 1
@.str.3 = private unnamed_addr constant [6 x i8] c"wrong\00", align 1
@.str.4 = private unnamed_addr constant [8 x i8] c"reducer\00", align 1
@.str.5 = private unnamed_addr constant [10 x i8] c"...%s...\0A\00", align 1
@.str.6 = private unnamed_addr constant [9 x i8] c"   - %s\0A\00", align 1
@.str.7 = private unnamed_addr constant [5 x i8] c"PASS\00", align 1
@.str.8 = private unnamed_addr constant [5 x i8] c"FAIL\00", align 1
@.str.10 = private unnamed_addr constant [140 x i8] c"reducer_is_cache_aligned() && \22Reducer should be cache aligned. Please see comments following \22 \22this assertion for explanation and fixes.\22\00", align 1
@.str.11 = private unnamed_addr constant [72 x i8] c"/data/animals/opencilk/build-dbg/lib/clang/9.0.1/include/cilk/reducer.h\00", align 1
@__PRETTY_FUNCTION__._ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev = private unnamed_addr constant [145 x i8] c"cilk::internal::reducer_content<cilk::op_add<long long, true>, true>::reducer_content() [Monoid = cilk::op_add<long long, true>, Aligned = true]\00", align 1
@__csi_unit_func_base_id = internal global i64 0
@__csi_unit_func_exit_base_id = internal global i64 0
@__csi_unit_loop_base_id = internal global i64 0
@__csi_unit_loop_exit_base_id = internal global i64 0
@__csi_unit_bb_base_id = internal global i64 0
@__csi_unit_callsite_base_id = internal global i64 0
@__csi_unit_load_base_id = internal global i64 0
@__csi_unit_store_base_id = internal global i64 0
@__csi_unit_alloca_base_id = internal global i64 0
@__csi_unit_detach_base_id = internal global i64 0
@__csi_unit_task_base_id = internal global i64 0
@__csi_unit_task_exit_base_id = internal global i64 0
@__csi_unit_detach_continue_base_id = internal global i64 0
@__csi_unit_sync_base_id = internal global i64 0
@__csi_unit_allocfn_base_id = internal global i64 0
@__csi_unit_free_base_id = internal global i64 0
@__csi_func_id_strtol = weak global i64 -1
@__csi_func_id_printf = weak global i64 -1
@__csi_func_id_atoi = weak global i64 -1
@__csi_func_id_fprintf = weak global i64 -1
@__csi_func_id_fwrite = weak global i64 -1
@__csi_func_id__Z9run_accumPFxPKllES0_lxPKc = weak global i64 -1
@__csi_func_id_rand = weak global i64 -1
@__csi_func_id___cilkrts_hyper_create = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc = weak global i64 -1
@__csi_func_id__ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv = weak global i64 -1
@__csi_func_id__ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv = weak global i64 -1
@__csi_func_id__ZN4cilk11scalar_viewIxEC2ERKx = weak global i64 -1
@__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_ = weak global i64 -1
@__csi_func_id__ZN4cilk11op_add_viewIxEC2ERKx = weak global i64 -1
@__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_ = weak global i64 -1
@__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev = weak global i64 -1
@__csi_func_id___cilkrts_hyper_destroy = weak global i64 -1
@__csi_func_id__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv = weak global i64 -1
@__csi_func_id__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_ = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev = weak global i64 -1
@__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_ = weak global i64 -1
@__csi_func_id___cilkrts_hyper_lookup = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv = weak global i64 -1
@__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv = weak global i64 -1
@__csi_func_id__ZN4cilk11op_add_viewIxEpLERKx = weak global i64 -1
@__csi_func_id__ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv = weak global i64 -1
@__csi_func_id__ZNK4cilk11scalar_viewIxE14view_get_valueEv = weak global i64 -1
@__csi_func_id__ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv = weak global i64 -1
@__csi_func_id__ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_ = weak global i64 -1
@__csi_func_id__ZN4cilk13reducer_opaddIxEC2ERKx = weak global i64 -1
@__csi_func_id__ZN4cilk13reducer_opaddIxEdeEv = weak global i64 -1
@__csi_func_id__ZN4cilk13reducer_opaddIxEpLERKx = weak global i64 -1
@__csi_func_id__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv = weak global i64 -1
@__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev = weak global i64 -1
@__csi_func_id_pthread_mutex_init = weak global i64 -1
@__csi_func_id_pthread_mutex_lock = weak global i64 -1
@__csi_func_id_pthread_mutex_unlock = weak global i64 -1
@__csi_func_id__Z11accum_spawnPKll = weak global i64 -1
@__csi_func_id__ZN4cilk11op_add_viewIxE6reduceEPS1_ = weak global i64 -1
@__csi_func_id__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_ = weak global i64 -1
@__csi_func_id__ZN4cilk11scalar_viewIxEC2Ev = weak global i64 -1
@__csi_func_id__ZN4cilk11op_add_viewIxEC2Ev = weak global i64 -1
@__csi_func_id__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_ = weak global i64 -1
@__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_ = weak global i64 -1
@__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm = weak global i64 -1
@__csi_func_id__ZdlPv = weak global i64 -1
@__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv = weak global i64 -1
@__csi_func_id__ZNSt8ios_base4InitC1Ev = weak global i64 -1
@__csi_func_id___cxa_atexit = weak global i64 -1
@__csi_func_id___cxx_global_var_init = weak global i64 -1
@__csi_unit_filename_sum-vector-int.cpp = private unnamed_addr constant [19 x i8] c"sum-vector-int.cpp\00"
@__csi_unit_function_name__Zpl5wsp_tRKS_ = private unnamed_addr constant [15 x i8] c"_Zpl5wsp_tRKS_\00"
@__csi_unit_function_name__Zmi5wsp_tRKS_ = private unnamed_addr constant [15 x i8] c"_Zmi5wsp_tRKS_\00"
@__csi_unit_function_name__ZlsRSoRK5wsp_t = private unnamed_addr constant [16 x i8] c"_ZlsRSoRK5wsp_t\00"
@__csi_unit_function_name__ZlsRSt14basic_ofstreamIcSt11char_traitsIcEERK5wsp_t = private unnamed_addr constant [53 x i8] c"_ZlsRSt14basic_ofstreamIcSt11char_traitsIcEERK5wsp_t\00"
@__csi_unit_function_name_wsp_getworkspan = private unnamed_addr constant [16 x i8] c"wsp_getworkspan\00"
@__csi_unit_function_name_wsp_add = private unnamed_addr constant [8 x i8] c"wsp_add\00"
@__csi_unit_function_name_wsp_sub = private unnamed_addr constant [8 x i8] c"wsp_sub\00"
@__csi_unit_function_name_wsp_dump = private unnamed_addr constant [9 x i8] c"wsp_dump\00"
@__csi_unit_function_name_atoi = private unnamed_addr constant [5 x i8] c"atoi\00"
@__csi_unit_function_name__Z10accum_truePKll = private unnamed_addr constant [19 x i8] c"_Z10accum_truePKll\00"
@__csi_unit_function_name__Z9run_accumPFxPKllES0_lxPKc = private unnamed_addr constant [29 x i8] c"_Z9run_accumPFxPKllES0_lxPKc\00"
@__csi_unit_function_name_main = private unnamed_addr constant [5 x i8] c"main\00"
@__csi_unit_function_name__Z11accum_wrongPKll = private unnamed_addr constant [20 x i8] c"_Z11accum_wrongPKll\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc = private unnamed_addr constant [57 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc\00"
@__csi_unit_function_name__ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv = private unnamed_addr constant [88 x i8] c"_ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv\00"
@__csi_unit_function_name__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev = private unnamed_addr constant [63 x i8] c"_ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev\00"
@__csi_unit_function_name__ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv = private unnamed_addr constant [67 x i8] c"_ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv = private unnamed_addr constant [66 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv = private unnamed_addr constant [68 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv\00"
@__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_ = private unnamed_addr constant [55 x i8] c"_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_\00"
@__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2ERKx = private unnamed_addr constant [31 x i8] c"_ZN4cilk11scalar_viewIxEC2ERKx\00"
@__csi_unit_function_name__ZN4cilk11op_add_viewIxEC2ERKx = private unnamed_addr constant [31 x i8] c"_ZN4cilk11op_add_viewIxEC2ERKx\00"
@__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_ = private unnamed_addr constant [89 x i8] c"_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_\00"
@__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev = private unnamed_addr constant [52 x i8] c"_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev\00"
@__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_ = private unnamed_addr constant [90 x i8] c"_ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev = private unnamed_addr constant [56 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev\00"
@__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_ = private unnamed_addr constant [47 x i8] c"_ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_\00"
@__csi_unit_function_name__ZN4cilk13reducer_opaddIxEC2ERKx = private unnamed_addr constant [33 x i8] c"_ZN4cilk13reducer_opaddIxEC2ERKx\00"
@__csi_unit_function_name__ZN4cilk13reducer_opaddIxEdeEv = private unnamed_addr constant [31 x i8] c"_ZN4cilk13reducer_opaddIxEdeEv\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv = private unnamed_addr constant [59 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv\00"
@__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv = private unnamed_addr constant [44 x i8] c"_ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv\00"
@__csi_unit_function_name__ZN4cilk11op_add_viewIxEpLERKx = private unnamed_addr constant [31 x i8] c"_ZN4cilk11op_add_viewIxEpLERKx\00"
@__csi_unit_function_name__ZN4cilk13reducer_opaddIxEpLERKx = private unnamed_addr constant [33 x i8] c"_ZN4cilk13reducer_opaddIxEpLERKx\00"
@__csi_unit_function_name__ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv = private unnamed_addr constant [60 x i8] c"_ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv\00"
@__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv = private unnamed_addr constant [45 x i8] c"_ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv\00"
@__csi_unit_function_name__ZNK4cilk11scalar_viewIxE14view_get_valueEv = private unnamed_addr constant [44 x i8] c"_ZNK4cilk11scalar_viewIxE14view_get_valueEv\00"
@__csi_unit_function_name__ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_ = private unnamed_addr constant [74 x i8] c"_ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_\00"
@__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv = private unnamed_addr constant [50 x i8] c"_ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv\00"
@__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev = private unnamed_addr constant [41 x i8] c"_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev\00"
@__csi_unit_function_name__Z13accum_reducerPKll = private unnamed_addr constant [22 x i8] c"_Z13accum_reducerPKll\00"
@__csi_unit_function_name__Z10accum_lockPKll = private unnamed_addr constant [19 x i8] c"_Z10accum_lockPKll\00"
@__csi_unit_function_name__Z11accum_spawnPKll = private unnamed_addr constant [20 x i8] c"_Z11accum_spawnPKll\00"
@__csi_unit_function_name__Z18accum_spawn_coarsePKll = private unnamed_addr constant [27 x i8] c"_Z18accum_spawn_coarsePKll\00"
@__csi_unit_function_name__ZN4cilk11op_add_viewIxE6reduceEPS1_ = private unnamed_addr constant [37 x i8] c"_ZN4cilk11op_add_viewIxE6reduceEPS1_\00"
@__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_ = private unnamed_addr constant [69 x i8] c"_ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_ = private unnamed_addr constant [77 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_\00"
@__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2Ev = private unnamed_addr constant [29 x i8] c"_ZN4cilk11scalar_viewIxEC2Ev\00"
@__csi_unit_function_name__ZN4cilk11op_add_viewIxEC2Ev = private unnamed_addr constant [29 x i8] c"_ZN4cilk11op_add_viewIxEC2Ev\00"
@__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_ = private unnamed_addr constant [68 x i8] c"_ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_ = private unnamed_addr constant [76 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_\00"
@__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_ = private unnamed_addr constant [59 x i8] c"_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_ = private unnamed_addr constant [75 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_\00"
@__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm = private unnamed_addr constant [57 x i8] c"_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm = private unnamed_addr constant [74 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm\00"
@__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv = private unnamed_addr constant [61 x i8] c"_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv\00"
@__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_ = private unnamed_addr constant [78 x i8] c"_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_\00"
@__csi_unit_function_name___cxx_global_var_init = private unnamed_addr constant [22 x i8] c"__cxx_global_var_init\00"
@__csi_unit_function_name__GLOBAL__sub_I_sum_vector_int.cpp = private unnamed_addr constant [34 x i8] c"_GLOBAL__sub_I_sum_vector_int.cpp\00"
@__csi_unit_fed_table__csi_unit_func_base_id = internal global [58 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([15 x i8], [15 x i8]* @__csi_unit_function_name__Zpl5wsp_tRKS_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([15 x i8], [15 x i8]* @__csi_unit_function_name__Zmi5wsp_tRKS_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([16 x i8], [16 x i8]* @__csi_unit_function_name__ZlsRSoRK5wsp_t, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([53 x i8], [53 x i8]* @__csi_unit_function_name__ZlsRSt14basic_ofstreamIcSt11char_traitsIcEERK5wsp_t, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([16 x i8], [16 x i8]* @__csi_unit_function_name_wsp_getworkspan, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_function_name_wsp_add, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_function_name_wsp_sub, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @__csi_unit_function_name_wsp_dump, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_atoi, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_truePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__Z9run_accumPFxPKllES0_lxPKc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([88 x i8], [88 x i8]* @__csi_unit_function_name__ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([63 x i8], [63 x i8]* @__csi_unit_function_name__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([67 x i8], [67 x i8]* @__csi_unit_function_name__ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([66 x i8], [66 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([68 x i8], [68 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([55 x i8], [55 x i8]* @__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([89 x i8], [89 x i8]* @__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([52 x i8], [52 x i8]* @__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([56 x i8], [56 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEdeEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([59 x i8], [59 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([44 x i8], [44 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([60 x i8], [60 x i8]* @__csi_unit_function_name__ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([45 x i8], [45 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([44 x i8], [44 x i8]* @__csi_unit_function_name__ZNK4cilk11scalar_viewIxE14view_get_valueEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([74 x i8], [74 x i8]* @__csi_unit_function_name__ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([50 x i8], [50 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([41 x i8], [41 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([27 x i8], [27 x i8]* @__csi_unit_function_name__Z18accum_spawn_coarsePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([37 x i8], [37 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxE6reduceEPS1_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([69 x i8], [69 x i8]* @__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([77 x i8], [77 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([68 x i8], [68 x i8]* @__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([76 x i8], [76 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([59 x i8], [59 x i8]* @__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([75 x i8], [75 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([74 x i8], [74 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([61 x i8], [61 x i8]* @__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([78 x i8], [78 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name___cxx_global_var_init, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([34 x i8], [34 x i8]* @__csi_unit_function_name__GLOBAL__sub_I_sum_vector_int.cpp, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_func_exit_base_id = internal global [74 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([15 x i8], [15 x i8]* @__csi_unit_function_name__Zpl5wsp_tRKS_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([15 x i8], [15 x i8]* @__csi_unit_function_name__Zmi5wsp_tRKS_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([16 x i8], [16 x i8]* @__csi_unit_function_name_wsp_getworkspan, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_function_name_wsp_add, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_function_name_wsp_sub, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_atoi, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_truePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__Z9run_accumPFxPKllES0_lxPKc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__Z9run_accumPFxPKllES0_lxPKc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([63 x i8], [63 x i8]* @__csi_unit_function_name__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([63 x i8], [63 x i8]* @__csi_unit_function_name__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([66 x i8], [66 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([68 x i8], [68 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([55 x i8], [55 x i8]* @__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([89 x i8], [89 x i8]* @__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([56 x i8], [56 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([59 x i8], [59 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([59 x i8], [59 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([44 x i8], [44 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([44 x i8], [44 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([60 x i8], [60 x i8]* @__csi_unit_function_name__ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([60 x i8], [60 x i8]* @__csi_unit_function_name__ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([45 x i8], [45 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([45 x i8], [45 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([74 x i8], [74 x i8]* @__csi_unit_function_name__ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([50 x i8], [50 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([50 x i8], [50 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([41 x i8], [41 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([27 x i8], [27 x i8]* @__csi_unit_function_name__Z18accum_spawn_coarsePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([37 x i8], [37 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxE6reduceEPS1_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([69 x i8], [69 x i8]* @__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([77 x i8], [77 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([77 x i8], [77 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([68 x i8], [68 x i8]* @__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([68 x i8], [68 x i8]* @__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([76 x i8], [76 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([76 x i8], [76 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([75 x i8], [75 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([75 x i8], [75 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([74 x i8], [74 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([74 x i8], [74 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([61 x i8], [61 x i8]* @__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([78 x i8], [78 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([78 x i8], [78 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name___cxx_global_var_init, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name___cxx_global_var_init, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([34 x i8], [34 x i8]* @__csi_unit_function_name__GLOBAL__sub_I_sum_vector_int.cpp, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([34 x i8], [34 x i8]* @__csi_unit_function_name__GLOBAL__sub_I_sum_vector_int.cpp, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_loop_base_id = internal global [3 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_loop_exit_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_fed_table__csi_unit_bb_base_id = internal global [0 x { i8*, i32, i32, i8* }] zeroinitializer
@__csi_unit_fed_table__csi_unit_callsite_base_id = internal global [70 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_atoi, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__Z9run_accumPFxPKllES0_lxPKc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__Z9run_accumPFxPKllES0_lxPKc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__Z9run_accumPFxPKllES0_lxPKc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([63 x i8], [63 x i8]* @__csi_unit_function_name__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([63 x i8], [63 x i8]* @__csi_unit_function_name__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([66 x i8], [66 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([56 x i8], [56 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([47 x i8], [47 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([59 x i8], [59 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([44 x i8], [44 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([33 x i8], [33 x i8]* @__csi_unit_function_name__ZN4cilk13reducer_opaddIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([60 x i8], [60 x i8]* @__csi_unit_function_name__ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([45 x i8], [45 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([74 x i8], [74 x i8]* @__csi_unit_function_name__ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([50 x i8], [50 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([50 x i8], [50 x i8]* @__csi_unit_function_name__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([41 x i8], [41 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([41 x i8], [41 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([41 x i8], [41 x i8]* @__csi_unit_function_name__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([27 x i8], [27 x i8]* @__csi_unit_function_name__Z18accum_spawn_coarsePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([27 x i8], [27 x i8]* @__csi_unit_function_name__Z18accum_spawn_coarsePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([69 x i8], [69 x i8]* @__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([77 x i8], [77 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([77 x i8], [77 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([68 x i8], [68 x i8]* @__csi_unit_function_name__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([76 x i8], [76 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([76 x i8], [76 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([75 x i8], [75 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([75 x i8], [75 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([74 x i8], [74 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([74 x i8], [74 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([61 x i8], [61 x i8]* @__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([78 x i8], [78 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([78 x i8], [78 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name___cxx_global_var_init, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name___cxx_global_var_init, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([34 x i8], [34 x i8]* @__csi_unit_function_name__GLOBAL__sub_I_sum_vector_int.cpp, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_load_base_id = internal global [17 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_truePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([68 x i8], [68 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([27 x i8], [27 x i8]* @__csi_unit_function_name__Z18accum_spawn_coarsePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([37 x i8], [37 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxE6reduceEPS1_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_store_base_id = internal global [23 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([15 x i8], [15 x i8]* @__csi_unit_function_name__Zpl5wsp_tRKS_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([15 x i8], [15 x i8]* @__csi_unit_function_name__Zmi5wsp_tRKS_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([16 x i8], [16 x i8]* @__csi_unit_function_name_wsp_getworkspan, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_function_name_wsp_add, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_function_name_wsp_sub, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([55 x i8], [55 x i8]* @__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2ERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([89 x i8], [89 x i8]* @__csi_unit_function_name__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([31 x i8], [31 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxEpLERKx, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([37 x i8], [37 x i8]* @__csi_unit_function_name__ZN4cilk11op_add_viewIxE6reduceEPS1_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([29 x i8], [29 x i8]* @__csi_unit_function_name__ZN4cilk11scalar_viewIxEC2Ev, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_detach_base_id = internal global [5 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([27 x i8], [27 x i8]* @__csi_unit_function_name__Z18accum_spawn_coarsePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_task_base_id = internal global [5 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }]
@__csi_unit_fed_table__csi_unit_task_exit_base_id = internal global [6 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([27 x i8], [27 x i8]* @__csi_unit_function_name__Z18accum_spawn_coarsePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_detach_continue_base_id = internal global [6 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }, { i8*, i32, i32, i8* } { i8* null, i32 -1, i32 -1, i8* null }]
@__csi_unit_fed_table__csi_unit_sync_base_id = internal global [5 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_spawnPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([27 x i8], [27 x i8]* @__csi_unit_function_name__Z18accum_spawn_coarsePKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_alloca_base_id = internal global [7 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([20 x i8], [20 x i8]* @__csi_unit_function_name__Z11accum_wrongPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([90 x i8], [90 x i8]* @__csi_unit_function_name__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([22 x i8], [22 x i8]* @__csi_unit_function_name__Z13accum_reducerPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_function_name__Z10accum_lockPKll, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_allocfn_base_id = internal global [2 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }, { i8*, i32, i32, i8* } { i8* getelementptr inbounds ([57 x i8], [57 x i8]* @__csi_unit_function_name__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_fed_table__csi_unit_free_base_id = internal global [1 x { i8*, i32, i32, i8* }] [{ i8*, i32, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_function_name_main, i32 0, i32 0), i32 -1, i32 -1, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @__csi_unit_filename_sum-vector-int.cpp, i32 0, i32 0) }]
@__csi_unit_object_name_vals = private unnamed_addr constant [5 x i8] c"vals\00"
@__csi_unit_object_name_stderr = private unnamed_addr constant [7 x i8] c"stderr\00"
@__csi_unit_object_name_argv = private unnamed_addr constant [5 x i8] c"argv\00"
@__csi_unit_object_name_this = private unnamed_addr constant [5 x i8] c"this\00"
@__csi_unit_object_name_v = private unnamed_addr constant [2 x i8] c"v\00"
@__csi_unit_object_name_x = private unnamed_addr constant [2 x i8] c"x\00"
@__csi_unit_object_name_call18 = private unnamed_addr constant [7 x i8] c"call18\00"
@__csi_unit_object_name_right = private unnamed_addr constant [6 x i8] c"right\00"
@__csi_unit_obj_table = internal global [17 x { i8*, i32, i8* }] [{ i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_vals, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_object_name_stderr, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_object_name_stderr, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_argv, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_argv, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_vals, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([2 x i8], [2 x i8]* @__csi_unit_object_name_v, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([2 x i8], [2 x i8]* @__csi_unit_object_name_x, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @__csi_unit_object_name_call18, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_vals, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_vals, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_vals, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_vals, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_vals, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_vals, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_right, i32 0, i32 0), i32 -1, i8* null }]
@__csi_unit_object_name_agg.result = private unnamed_addr constant [11 x i8] c"agg.result\00"
@__csi_unit_object_name_sum = private unnamed_addr constant [4 x i8] c"sum\00"
@__csi_unit_object_name_ref.tmp3 = private unnamed_addr constant [9 x i8] c"ref.tmp3\00"
@__csi_unit_obj_table.12 = internal global [23 x { i8*, i32, i8* }] [{ i8*, i32, i8* } { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @__csi_unit_object_name_agg.result, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @__csi_unit_object_name_agg.result, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @__csi_unit_object_name_agg.result, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @__csi_unit_object_name_agg.result, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @__csi_unit_object_name_agg.result, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_sum, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @__csi_unit_object_name_ref.tmp3, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_sum, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__csi_unit_object_name_this, i32 0, i32 0), i32 -1, i8* null }]
@__csi_unit_object_name_guard = private unnamed_addr constant [6 x i8] c"guard\00"
@__csi_unit_object_name_accum = private unnamed_addr constant [6 x i8] c"accum\00"
@__csi_unit_object_name_ref.tmp = private unnamed_addr constant [8 x i8] c"ref.tmp\00"
@__csi_unit_object_name_mutex = private unnamed_addr constant [6 x i8] c"mutex\00"
@__csi_unit_obj_table.13 = internal global [7 x { i8*, i32, i8* }] [{ i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_sum, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_guard, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_accum, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__csi_unit_object_name_ref.tmp, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @__csi_unit_object_name_ref.tmp3, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_mutex, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @__csi_unit_object_name_sum, i32 0, i32 0), i32 -1, i8* null }]
@__csi_unit_object_name_call4 = private unnamed_addr constant [6 x i8] c"call4\00"
@__csi_unit_object_name_call2 = private unnamed_addr constant [6 x i8] c"call2\00"
@__csi_unit_obj_table.14 = internal global [2 x { i8*, i32, i8* }] [{ i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_call4, i32 0, i32 0), i32 -1, i8* null }, { i8*, i32, i8* } { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @__csi_unit_object_name_call2, i32 0, i32 0), i32 -1, i8* null }]
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_ = weak global i64 -1
@__csi_func_id__ZlsRSt14basic_ofstreamIcSt11char_traitsIcEERK5wsp_t = weak global i64 -1
@__csi_func_id_wsp_getworkspan = weak global i64 -1
@__csi_func_id__Z18accum_spawn_coarsePKll = weak global i64 -1
@__csi_func_id_main = weak global i64 -1
@__csi_func_id_wsp_sub = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_ = weak global i64 -1
@__csi_func_id__Zpl5wsp_tRKS_ = weak global i64 -1
@__csi_func_id__Z10accum_truePKll = weak global i64 -1
@__csi_func_id_wsp_dump = weak global i64 -1
@__csi_func_id_wsp_add = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_ = weak global i64 -1
@__csi_func_id__Z11accum_wrongPKll = weak global i64 -1
@__csi_func_id__ZlsRSoRK5wsp_t = weak global i64 -1
@__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_ = weak global i64 -1
@__csi_func_id__Z13accum_reducerPKll = weak global i64 -1
@__csi_func_id__GLOBAL__sub_I_sum_vector_int.cpp = weak global i64 -1
@__csi_func_id__Z10accum_lockPKll = weak global i64 -1
@__csi_func_id__Zmi5wsp_tRKS_ = weak global i64 -1
@__csi_unit_fed_tables = internal global [16 x { i64, i8*, { i8*, i32, i32, i8* }* }] [{ i64, i8*, { i8*, i32, i32, i8* }* } { i64 58, i8* bitcast (i64* @__csi_unit_func_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([58 x { i8*, i32, i32, i8* }], [58 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_func_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 74, i8* bitcast (i64* @__csi_unit_func_exit_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([74 x { i8*, i32, i32, i8* }], [74 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_func_exit_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 3, i8* bitcast (i64* @__csi_unit_loop_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([3 x { i8*, i32, i32, i8* }], [3 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_loop_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_loop_exit_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_loop_exit_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 0, i8* bitcast (i64* @__csi_unit_bb_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([0 x { i8*, i32, i32, i8* }], [0 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_bb_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 70, i8* bitcast (i64* @__csi_unit_callsite_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([70 x { i8*, i32, i32, i8* }], [70 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_callsite_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 17, i8* bitcast (i64* @__csi_unit_load_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([17 x { i8*, i32, i32, i8* }], [17 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_load_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 23, i8* bitcast (i64* @__csi_unit_store_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([23 x { i8*, i32, i32, i8* }], [23 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_store_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 5, i8* bitcast (i64* @__csi_unit_detach_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([5 x { i8*, i32, i32, i8* }], [5 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_detach_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 5, i8* bitcast (i64* @__csi_unit_task_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([5 x { i8*, i32, i32, i8* }], [5 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_task_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 6, i8* bitcast (i64* @__csi_unit_task_exit_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([6 x { i8*, i32, i32, i8* }], [6 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_task_exit_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 6, i8* bitcast (i64* @__csi_unit_detach_continue_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([6 x { i8*, i32, i32, i8* }], [6 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_detach_continue_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 5, i8* bitcast (i64* @__csi_unit_sync_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([5 x { i8*, i32, i32, i8* }], [5 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_sync_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 7, i8* bitcast (i64* @__csi_unit_alloca_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([7 x { i8*, i32, i32, i8* }], [7 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_alloca_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 2, i8* bitcast (i64* @__csi_unit_allocfn_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([2 x { i8*, i32, i32, i8* }], [2 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_allocfn_base_id, i32 0, i32 0) }, { i64, i8*, { i8*, i32, i32, i8* }* } { i64 1, i8* bitcast (i64* @__csi_unit_free_base_id to i8*), { i8*, i32, i32, i8* }* getelementptr inbounds ([1 x { i8*, i32, i32, i8* }], [1 x { i8*, i32, i32, i8* }]* @__csi_unit_fed_table__csi_unit_free_base_id, i32 0, i32 0) }]
@__csi_unit_obj_tables = internal global [4 x { i64, { i8*, i32, i8* }* }] [{ i64, { i8*, i32, i8* }* } { i64 17, { i8*, i32, i8* }* getelementptr inbounds ([17 x { i8*, i32, i8* }], [17 x { i8*, i32, i8* }]* @__csi_unit_obj_table, i32 0, i32 0) }, { i64, { i8*, i32, i8* }* } { i64 23, { i8*, i32, i8* }* getelementptr inbounds ([23 x { i8*, i32, i8* }], [23 x { i8*, i32, i8* }]* @__csi_unit_obj_table.12, i32 0, i32 0) }, { i64, { i8*, i32, i8* }* } { i64 7, { i8*, i32, i8* }* getelementptr inbounds ([7 x { i8*, i32, i8* }], [7 x { i8*, i32, i8* }]* @__csi_unit_obj_table.13, i32 0, i32 0) }, { i64, { i8*, i32, i8* }* } { i64 2, { i8*, i32, i8* }* getelementptr inbounds ([2 x { i8*, i32, i8* }], [2 x { i8*, i32, i8* }]* @__csi_unit_obj_table.14, i32 0, i32 0) }]
@0 = private unnamed_addr constant [19 x i8] c"sum-vector-int.cpp\00", align 1

; Function Attrs: norecurse nounwind uwtable
define dso_local i64 @_Z11accum_wrongPKll(i64* nocapture readonly %vals, i64 %n) #10 {
entry:
  %0 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %1 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %2 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %3 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %4 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %5 = add i64 %4, 12
  %6 = call i8* @llvm.frameaddress(i32 0)
  %7 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %5, i8* %6, i8* %7, i64 3) #20
  %8 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %8, i64 %5, i8 0) #20
  %9 = load i64, i64* %8, align 8
  %10 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %sum = alloca i64, align 8
  %11 = bitcast i64* %sum to i8*
  call void @__csi_after_alloca(i64 %10, i8* nonnull %11, i64 8, i64 1) #20
  %syncreg = tail call token @llvm.syncregion.start()
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %11)
  store i64 0, i64* %sum, align 8, !tbaa !9
  %cmp = icmp sgt i64 %n, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %entry
  %12 = load i64, i64* @__csi_unit_loop_base_id, align 8, !invariant.load !2
  call void @__csan_before_loop(i64 %12, i64 -1, i64 3) #20
  %13 = and i64 %9, 1
  %14 = icmp eq i64 %13, 0
  %15 = load i64, i64* @__csi_unit_load_base_id, align 8
  %16 = add i64 %15, 5
  %17 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %18 = add i64 %17, 5
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  call void @__csan_detach(i64 %0, i8 0) #20
  detach within %syncreg, label %pfor.body, label %pfor.inc

pfor.body:                                        ; preds = %pfor.cond
  %19 = call i8* @llvm.task.frameaddress(i32 0)
  %20 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %1, i64 %0, i8* %19, i8* %20, i64 1) #20
  %arrayidx = getelementptr inbounds i64, i64* %vals, i64 %__begin.0
  br i1 %14, label %23, label %21

21:                                               ; preds = %pfor.body
  %22 = bitcast i64* %arrayidx to i8*
  call void @__csan_load(i64 %16, i8* %22, i32 8, i64 8) #20
  br label %23

23:                                               ; preds = %pfor.body, %21
  %24 = load i64, i64* %arrayidx, align 8, !tbaa !7
  %sum.0.load20 = load i64, i64* %sum, align 8
  %add3 = add nsw i64 %sum.0.load20, %24
  call void @__csan_store(i64 %18, i8* nonnull %11, i32 8, i64 8) #20
  store i64 %add3, i64* %sum, align 8, !tbaa !9
  call void @__csan_task_exit(i64 %2, i64 %1, i64 %0, i8 0, i64 1) #20
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %23, %pfor.cond
  call void @__csan_detach_continue(i64 %3, i64 %0) #20
  %inc = add nuw nsw i64 %__begin.0, 1
  %exitcond = icmp eq i64 %inc, %n
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !11

pfor.cond.cleanup:                                ; preds = %pfor.inc
  call void @__csan_after_loop(i64 %12, i8 0, i64 3) #20
  %25 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !2
  call void @__csan_sync(i64 %25, i8 0) #20
  sync within %syncreg, label %cleanup

cleanup:                                          ; preds = %pfor.cond.cleanup, %entry
  %sum.0.load21 = load i64, i64* %sum, align 8
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %11)
  %26 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %27 = add i64 %26, 11
  call void @__csan_func_exit(i64 %27, i64 %5, i64 1) #20
  ret i64 %sum.0.load21
}

; CHECK-LABEL: define private fastcc void @_Z11accum_wrongPKll.outline_pfor.cond.ls1(

; CHECK: call void @__csan_detach(
; CHECK: call void @__csan_task(
; CHECK: br label %pfor.cond.ls1

; CHECK: pfor.inc.ls1:
; CHECK: call void @__csan_task_exit(
; CHECK: call void @__csan_detach_continue(
; CHECK: sync within

; CHECK: ret void

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #5

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #5

; Function Attrs: uwtable
define dso_local i64 @_Z13accum_reducerPKll(i64* nocapture readonly %vals, i64 %n) #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %0 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 1
  %2 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %3 = add i64 %2, 1
  %4 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %5 = add i64 %4, 1
  %6 = add i64 %4, 2
  %7 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %8 = add i64 %7, 1
  %9 = add i64 %7, 2
  %10 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %11 = add i64 %10, 39
  %12 = call i8* @llvm.frameaddress(i32 0)
  %13 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %11, i8* %12, i8* %13, i64 3)
  %14 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %14, i64 %11, i8 0)
  %15 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %16 = add i64 %15, 2
  %accum = alloca %"class.cilk::reducer_opadd", align 64
  %17 = bitcast %"class.cilk::reducer_opadd"* %accum to i8*
  call void @__csi_after_alloca(i64 %16, i8* nonnull %17, i64 192, i64 1)
  %18 = add i64 %15, 3
  %ref.tmp = alloca i64, align 8
  %19 = bitcast i64* %ref.tmp to i8*
  call void @__csi_after_alloca(i64 %18, i8* nonnull %19, i64 8, i64 1)
  %syncreg = tail call token @llvm.syncregion.start()
  call void @llvm.lifetime.start.p0i8(i64 192, i8* nonnull %17) #20
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %19) #20
  store i64 0, i64* %ref.tmp, align 8, !tbaa !9
  %20 = load i64, i64* @__csi_func_id__ZN4cilk13reducer_opaddIxEC2ERKx, align 8
  call void @__csan_set_suppression_flag(i64 4, i64 %20)
  call void @__csan_set_suppression_flag(i64 4, i64 %20)
  %21 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %22 = add i64 %21, 40
  call void @__csan_before_call(i64 %22, i64 %20, i8 2, i64 0)
  invoke void @_ZN4cilk13reducer_opaddIxEC2ERKx(%"class.cilk::reducer_opadd"* nonnull %accum, i64* nonnull dereferenceable(8) %ref.tmp)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %entry
  call void @__csan_after_call(i64 %22, i64 %20, i8 2, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %19) #20
  %cmp = icmp sgt i64 %n, 0
  br i1 %cmp, label %pfor.cond.preheader, label %cleanup

pfor.cond.preheader:                              ; preds = %.noexc
  %23 = load i64, i64* @__csi_unit_loop_base_id, align 8, !invariant.load !2
  %24 = add i64 %23, 1
  call void @__csan_before_loop(i64 %24, i64 -1, i64 1)
  %25 = add i64 %15, 4
  %26 = load i64, i64* @__csi_unit_load_base_id, align 8
  %27 = add i64 %26, 10
  %28 = load i64, i64* @__csi_unit_store_base_id, align 8
  %29 = add i64 %28, 19
  %30 = add i64 %21, 41
  %31 = add i64 %21, 42
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.cond.preheader, %pfor.inc
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  call void @__csan_detach(i64 %1, i8 0)
  detach within %syncreg, label %32, label %pfor.inc unwind label %lpad7.loopexit

32:                                               ; preds = %pfor.cond
  %33 = call i8* @llvm.task.frameaddress(i32 0)
  %34 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %3, i64 %1, i8* %33, i8* %34, i64 1)
  %ref.tmp3 = alloca i64, align 8
  %35 = bitcast i64* %ref.tmp3 to i8*
  call void @__csi_after_alloca(i64 %25, i8* nonnull %35, i64 8, i64 0)
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %35) #20
  %arrayidx = getelementptr inbounds i64, i64* %vals, i64 %__begin.0
  %36 = bitcast i64* %arrayidx to i8*
  call void @__csan_load(i64 %27, i8* %36, i32 8, i64 8)
  %37 = load i64, i64* %arrayidx, align 8, !tbaa !7
  call void @__csan_store(i64 %29, i8* nonnull %35, i32 8, i64 8)
  store i64 %37, i64* %ref.tmp3, align 8, !tbaa !9
  %38 = load i64, i64* @__csi_func_id__ZN4cilk13reducer_opaddIxEdeEv, align 8
  call void @__csan_set_suppression_flag(i64 7, i64 %38)
  call void @__csan_before_call(i64 %30, i64 %38, i8 1, i64 0)
  %call = call dereferenceable(192) %"class.cilk::reducer_opadd"* @_ZN4cilk13reducer_opaddIxEdeEv(%"class.cilk::reducer_opadd"* nonnull %accum)
  call void @__csan_after_call(i64 %30, i64 %38, i8 1, i64 0)
  %39 = load i64, i64* @__csi_func_id__ZN4cilk13reducer_opaddIxEpLERKx, align 8
  call void @__csan_set_suppression_flag(i64 3, i64 %39)
  call void @__csan_set_suppression_flag(i64 3, i64 %39)
  call void @__csan_before_call(i64 %31, i64 %39, i8 2, i64 0)
  %call5 = invoke dereferenceable(192) %"class.cilk::reducer_opadd"* @_ZN4cilk13reducer_opaddIxEpLERKx(%"class.cilk::reducer_opadd"* nonnull %call, i64* nonnull dereferenceable(8) %ref.tmp3)
          to label %invoke.cont4 unwind label %lpad

invoke.cont4:                                     ; preds = %32
  call void @__csan_after_call(i64 %31, i64 %39, i8 2, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %35) #20
  call void @__csan_task_exit(i64 %5, i64 %3, i64 %1, i8 0, i64 1)
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %pfor.cond, %invoke.cont4
  call void @__csan_detach_continue(i64 %8, i64 %1)
  %inc = add nuw nsw i64 %__begin.0, 1
  %exitcond = icmp eq i64 %inc, %n
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !13

pfor.cond.cleanup:                                ; preds = %pfor.inc
  call void @__csan_after_loop(i64 %24, i8 0, i64 1)
  %40 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !2
  %41 = add i64 %40, 1
  call void @__csan_sync(i64 %41, i8 0)
  sync within %syncreg, label %sync.continue

lpad:                                             ; preds = %32
  %42 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %31, i64 %39, i8 2, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %35) #20
  call void @__csan_task_exit(i64 %6, i64 %3, i64 %1, i8 0, i64 1)
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg, { i8*, i32 } %42)
          to label %unreachable unwind label %lpad7.loopexit

lpad7.loopexit:                                   ; preds = %pfor.cond, %lpad
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_loop(i64 %24, i8 0, i64 1)
  call void @__csan_detach_continue(i64 %9, i64 %1)
  br label %ehcleanup20

lpad7.loopexit.split-lp.csi-split-lp:             ; preds = %sync.continue
  %lpad.csi-split-lp = landingpad { i8*, i32 }
          cleanup
  br label %ehcleanup20

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %cleanup unwind label %lpad7.loopexit.split-lp.csi-split-lp

cleanup:                                          ; preds = %sync.continue, %.noexc
  %43 = bitcast %"class.cilk::reducer_opadd"* %accum to %"class.cilk::reducer"*
  %44 = load i64, i64* @__csi_func_id__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv, align 8
  call void @__csan_set_suppression_flag(i64 4, i64 %44)
  %45 = add i64 %21, 43
  call void @__csan_before_call(i64 %45, i64 %44, i8 1, i64 0)
  %call18 = invoke dereferenceable(8) i64* @_ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv(%"class.cilk::reducer"* nonnull %43)
          to label %invoke.cont17 unwind label %lpad16

invoke.cont17:                                    ; preds = %cleanup
  call void @__csan_after_call(i64 %45, i64 %44, i8 1, i64 0)
  %46 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %47 = add i64 %46, 9
  %48 = bitcast i64* %call18 to i8*
  call void @__csan_load(i64 %47, i8* nonnull %48, i32 8, i64 8)
  %49 = load i64, i64* %call18, align 8, !tbaa !9
  %50 = load i64, i64* @__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev, align 8
  call void @__csan_set_suppression_flag(i64 4, i64 %50)
  %51 = add i64 %21, 44
  call void @__csan_before_call(i64 %51, i64 %50, i8 1, i64 0)
  call void @_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev(%"class.cilk::reducer"* nonnull %43) #20
  call void @__csan_after_call(i64 %51, i64 %50, i8 1, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %17) #20
  %52 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %53 = add i64 %52, 45
  call void @__csan_func_exit(i64 %53, i64 %11, i64 1)
  ret i64 %49

lpad16:                                           ; preds = %cleanup
  %54 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %45, i64 %44, i8 1, i64 0)
  br label %ehcleanup20

ehcleanup20:                                      ; preds = %lpad7.loopexit.split-lp.csi-split-lp, %lpad7.loopexit, %lpad16
  %.sink42 = phi { i8*, i32 } [ %54, %lpad16 ], [ %lpad.loopexit, %lpad7.loopexit ], [ %lpad.csi-split-lp, %lpad7.loopexit.split-lp.csi-split-lp ]
  %55 = bitcast %"class.cilk::reducer_opadd"* %accum to %"class.cilk::reducer"*
  %56 = load i64, i64* @__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev, align 8
  call void @__csan_set_suppression_flag(i64 7, i64 %56)
  %57 = add i64 %21, 45
  call void @__csan_before_call(i64 %57, i64 %56, i8 1, i64 0)
  call void @_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev(%"class.cilk::reducer"* nonnull %55) #20
  call void @__csan_after_call(i64 %57, i64 %56, i8 1, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %17) #20
  %58 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %59 = add i64 %58, 46
  call void @__csan_func_exit(i64 %59, i64 %11, i64 3)
  resume { i8*, i32 } %.sink42

unreachable:                                      ; preds = %lpad
  unreachable

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %22, i64 %20, i8 2, i64 0)
  %60 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %61 = add i64 %60, 47
  call void @__csan_func_exit(i64 %61, i64 %11, i64 3)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; CHECK-LABEL: define private fastcc void @_Z13accum_reducerPKll.outline_pfor.cond.ls1(

; CHECK: call void @__csan_detach(
; CHECK: call void @__csan_task(
; CHECK: br label %pfor.cond.ls1

; CHECK: pfor.inc.ls1:
; CHECK: call void @__csan_task_exit(
; CHECK: call void @__csan_detach_continue(
; CHECK: sync within

; CHECK: ret void

; Function Attrs: nounwind
declare dso_local void @free(i8* nocapture) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #5

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #11

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk13reducer_opaddIxEC2ERKx(%"class.cilk::reducer_opadd"* %this, i64* dereferenceable(8) %initial_value) unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 27
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = bitcast %"class.cilk::reducer_opadd"* %this to %"class.cilk::reducer"*
  %9 = and i64 %5, 3
  %10 = and i64 %5, 4
  %11 = or i64 %7, %5
  %12 = and i64 %11, 4
  %13 = icmp eq i64 %12, 0
  %14 = and i64 %7, 3
  %15 = select i1 %13, i64 %14, i64 0
  %16 = and i64 %10, %7
  %17 = or i64 %16, %9
  %18 = or i64 %17, %15
  %19 = select i1 %13, i64 %9, i64 0
  %20 = or i64 %16, %14
  %21 = or i64 %20, %19
  %22 = load i64, i64* @__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, align 8
  call void @__csan_set_suppression_flag(i64 %21, i64 %22)
  call void @__csan_set_suppression_flag(i64 %18, i64 %22)
  %23 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %24 = add i64 %23, 27
  call void @__csan_before_call(i64 %24, i64 %22, i8 2, i64 0)
  invoke void @_ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_(%"class.cilk::reducer"* %8, i64* nonnull dereferenceable(8) %initial_value)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %entry
  call void @__csan_after_call(i64 %24, i64 %22, i8 2, i64 0)
  %25 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %26 = add i64 %25, 28
  call void @__csan_func_exit(i64 %26, i64 %1, i64 0)
  ret void

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %24, i64 %22, i8 2, i64 0)
  %27 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %28 = add i64 %27, 29
  call void @__csan_func_exit(i64 %28, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local dereferenceable(192) %"class.cilk::reducer_opadd"* @_ZN4cilk13reducer_opaddIxEdeEv(%"class.cilk::reducer_opadd"* %this) local_unnamed_addr #12 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 28
  %2 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %2, i64 %1, i8 0) #20
  ret %"class.cilk::reducer_opadd"* %this
}

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: uwtable
define linkonce_odr dso_local dereferenceable(192) %"class.cilk::reducer_opadd"* @_ZN4cilk13reducer_opaddIxEpLERKx(%"class.cilk::reducer_opadd"* %this, i64* dereferenceable(8) %x) local_unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 32
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = bitcast %"class.cilk::reducer_opadd"* %this to %"class.cilk::reducer"*
  %9 = or i64 %7, %5
  %10 = and i64 %9, 4
  %11 = icmp eq i64 %10, 0
  %12 = and i64 %7, 3
  %13 = select i1 %11, i64 %12, i64 0
  %14 = and i64 %5, 7
  %15 = or i64 %14, %13
  %16 = load i64, i64* @__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, align 8
  call void @__csan_set_suppression_flag(i64 %15, i64 %16)
  %17 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %18 = add i64 %17, 30
  call void @__csan_before_call(i64 %18, i64 %16, i8 1, i64 0)
  %call3 = invoke dereferenceable(8) %"class.cilk::op_add_view"* @_ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::reducer"* %8)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  %19 = and i64 %5, 3
  call void @__csan_after_call(i64 %18, i64 %16, i8 1, i64 0)
  %20 = select i1 %11, i64 %19, i64 0
  %21 = or i64 %20, %12
  %22 = load i64, i64* @__csi_func_id__ZN4cilk11op_add_viewIxEpLERKx, align 8
  call void @__csan_set_suppression_flag(i64 %21, i64 %22)
  call void @__csan_set_suppression_flag(i64 3, i64 %22)
  %23 = add i64 %17, 31
  call void @__csan_before_call(i64 %23, i64 %22, i8 2, i64 0)
  %call2 = tail call dereferenceable(8) %"class.cilk::op_add_view"* @_ZN4cilk11op_add_viewIxEpLERKx(%"class.cilk::op_add_view"* nonnull %call3, i64* nonnull dereferenceable(8) %x)
  call void @__csan_after_call(i64 %23, i64 %22, i8 2, i64 0)
  %24 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %25 = add i64 %24, 35
  call void @__csan_func_exit(i64 %25, i64 %1, i64 0)
  ret %"class.cilk::reducer_opadd"* %this

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %18, i64 %16, i8 1, i64 0)
  %26 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %27 = add i64 %26, 36
  call void @__csan_func_exit(i64 %27, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #11

; Function Attrs: uwtable
define linkonce_odr dso_local dereferenceable(8) i64* @_ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv(%"class.cilk::reducer"* %this) local_unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 37
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = and i64 %5, 7
  %7 = load i64, i64* @__csi_func_id__ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, align 8
  call void @__csan_set_suppression_flag(i64 %6, i64 %7)
  %8 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %9 = add i64 %8, 35
  call void @__csan_before_call(i64 %9, i64 %7, i8 1, i64 0)
  %call3 = invoke dereferenceable(8) %"class.cilk::op_add_view"* @_ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::reducer"* %this)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  call void @__csan_after_call(i64 %9, i64 %7, i8 1, i64 0)
  %10 = load i64, i64* @__csi_func_id__ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_, align 8
  call void @__csan_set_suppression_flag(i64 3, i64 %10)
  %11 = add i64 %8, 36
  call void @__csan_before_call(i64 %11, i64 %10, i8 1, i64 0)
  %call24 = invoke dereferenceable(8) i64* @_ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_(%"class.cilk::op_add_view"* nonnull dereferenceable(8) %call3)
          to label %call2.noexc unwind label %csi.cleanup

call2.noexc:                                      ; preds = %call.noexc
  call void @__csan_after_call(i64 %11, i64 %10, i8 1, i64 0)
  %12 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %13 = add i64 %12, 42
  call void @__csan_func_exit(i64 %13, i64 %1, i64 0)
  ret i64* %call24

csi.cleanup:                                      ; preds = %call.noexc, %entry
  %14 = phi i64 [ %11, %call.noexc ], [ %9, %entry ]
  %15 = phi i64 [ %10, %call.noexc ], [ %7, %entry ]
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %14, i64 %15, i8 1, i64 0)
  %16 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %17 = add i64 %16, 43
  call void @__csan_func_exit(i64 %17, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev(%"class.cilk::reducer"* %this) unnamed_addr #4 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 38
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %6 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %this, i64 0, i32 0, i32 0
  %7 = and i64 %5, 7
  %8 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %7, i64 %8) #20
  %9 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %10 = add i64 %9, 37
  call void @__csan_before_call(i64 %10, i64 %8, i8 1, i64 0) #20
  %call = tail call %"class.cilk::op_add_view"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv(%"class.cilk::internal::reducer_base"* %6)
  call void @__csan_after_call(i64 %10, i64 %8, i8 1, i64 0) #20
  %11 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %7, i64 %11) #20
  %12 = add i64 %9, 38
  call void @__csan_before_call(i64 %12, i64 %11, i8 1, i64 0) #20
  %call3 = invoke %"struct.cilk::op_add"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv(%"class.cilk::internal::reducer_base"* %6)
          to label %invoke.cont2 unwind label %lpad

invoke.cont2:                                     ; preds = %entry
  call void @__csan_after_call(i64 %12, i64 %11, i8 1, i64 0) #20
  %13 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev, align 8
  call void @__csan_set_suppression_flag(i64 %7, i64 %13) #20
  %14 = add i64 %9, 39
  call void @__csan_before_call(i64 %14, i64 %13, i8 1, i64 0) #20
  tail call void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev(%"class.cilk::internal::reducer_base"* %6) #20
  call void @__csan_after_call(i64 %14, i64 %13, i8 1, i64 0) #20
  %15 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %16 = add i64 %15, 44
  call void @__csan_func_exit(i64 %16, i64 %1, i64 0) #20
  ret void

lpad:                                             ; preds = %entry
  %17 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %12, i64 %11, i8 1, i64 0) #20
  %18 = extractvalue { i8*, i32 } %17, 0
  call void @__cilksan_disable_checking() #20
  tail call void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev(%"class.cilk::internal::reducer_base"* %6) #20
  call void @__cilksan_enable_checking() #20
  call void @__cilksan_disable_checking() #20
  tail call void @__clang_call_terminate(i8* %18) #23
  unreachable
}

; Function Attrs: nofree nounwind
declare dso_local i64 @strtol(i8* readonly, i8** nocapture, i32) local_unnamed_addr #9

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local %"class.cilk::op_add_view"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv(%"class.cilk::internal::reducer_base"* %this) local_unnamed_addr #4 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 18
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %6 = bitcast %"class.cilk::internal::reducer_base"* %this to i8*
  %__view_offset = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 2
  %7 = and i64 %5, 1
  %8 = icmp eq i64 %7, 0
  br i1 %8, label %13, label %9

9:                                                ; preds = %entry
  %10 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %11 = add i64 %10, 6
  %12 = bitcast i64* %__view_offset to i8*
  call void @__csan_load(i64 %11, i8* nonnull %12, i32 8, i64 8) #20
  br label %13

13:                                               ; preds = %entry, %9
  %14 = load i64, i64* %__view_offset, align 8, !tbaa !16
  %add.ptr = getelementptr inbounds i8, i8* %6, i64 %14
  %15 = bitcast i8* %add.ptr to %"class.cilk::op_add_view"*
  %16 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %17 = add i64 %16, 17
  call void @__csan_func_exit(i64 %17, i64 %1, i64 0) #20
  ret %"class.cilk::op_add_view"* %15
}

; Function Attrs: uwtable
define linkonce_odr dso_local %"struct.cilk::op_add"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv(%"class.cilk::internal::reducer_base"* %this) local_unnamed_addr #0 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 17
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %m_monoid = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 1
  %6 = and i64 %5, 7
  %7 = load i64, i64* @__csi_func_id__ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv, align 8
  call void @__csan_set_suppression_flag(i64 %6, i64 %7)
  %8 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %9 = add i64 %8, 14
  call void @__csan_before_call(i64 %9, i64 %7, i8 1, i64 0)
  %call = tail call dereferenceable(1) %"struct.cilk::op_add"* @_ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv(%"class.cilk::internal::storage_for_object"* nonnull %m_monoid)
  call void @__csan_after_call(i64 %9, i64 %7, i8 1, i64 0)
  %10 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %11 = add i64 %10, 16
  call void @__csan_func_exit(i64 %11, i64 %1, i64 0)
  ret %"struct.cilk::op_add"* %call
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev(%"class.cilk::internal::reducer_base"* %this) unnamed_addr #4 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 25
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %m_base = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0
  %6 = and i64 %5, 7
  %7 = load i64, i64* @__csi_func_id___cilkrts_hyper_destroy, align 8
  call void @__csan_set_suppression_flag(i64 %6, i64 %7) #20
  %8 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %9 = add i64 %8, 21
  call void @__csan_before_call(i64 %9, i64 %7, i8 1, i64 0) #20
  invoke void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base* %m_base)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %entry
  call void @__csan_after_call(i64 %9, i64 %7, i8 1, i64 0) #20
  %10 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %11 = add i64 %10, 24
  call void @__csan_func_exit(i64 %11, i64 %1, i64 0) #20
  ret void

terminate.lpad:                                   ; preds = %entry
  %12 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %9, i64 %7, i8 1, i64 0) #20
  %13 = extractvalue { i8*, i32 } %12, 0
  call void @__cilksan_disable_checking() #20
  tail call void @__clang_call_terminate(i8* %13) #23
  unreachable
}

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8*) local_unnamed_addr #13 comdat {
  %2 = tail call i8* @__cxa_begin_catch(i8* %0) #20
  tail call void @_ZSt9terminatev() #23
  unreachable
}

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local dereferenceable(1) %"struct.cilk::op_add"* @_ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv(%"class.cilk::internal::storage_for_object"* %this) local_unnamed_addr #12 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 16
  %2 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %2, i64 %1, i8 0) #20
  %3 = bitcast %"class.cilk::internal::storage_for_object"* %this to %"struct.cilk::op_add"*
  ret %"struct.cilk::op_add"* %3
}

declare dso_local void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #1

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_(%"class.cilk::reducer"* %this, i64* dereferenceable(8) %x1) unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 26
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = bitcast %"class.cilk::reducer"* %this to %"class.cilk::internal::reducer_content"*
  %9 = and i64 %5, 3
  %10 = or i64 %7, %5
  %11 = and i64 %10, 4
  %12 = icmp eq i64 %11, 0
  %13 = and i64 %7, 3
  %14 = select i1 %12, i64 %13, i64 0
  %15 = and i64 %5, 7
  %16 = or i64 %15, %14
  %17 = load i64, i64* @__csi_func_id__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev, align 8
  call void @__csan_set_suppression_flag(i64 %16, i64 %17)
  %18 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 22
  call void @__csan_before_call(i64 %19, i64 %17, i8 1, i64 0)
  invoke void @_ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev(%"class.cilk::internal::reducer_content"* %8)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %entry
  call void @__csan_after_call(i64 %19, i64 %17, i8 1, i64 0)
  %20 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %this, i64 0, i32 0, i32 0
  %21 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %16, i64 %21)
  %22 = add i64 %18, 23
  call void @__csan_before_call(i64 %22, i64 %21, i8 1, i64 0)
  %call = invoke %"struct.cilk::op_add"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv(%"class.cilk::internal::reducer_base"* %20)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %.noexc
  call void @__csan_after_call(i64 %22, i64 %21, i8 1, i64 0)
  %23 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %16, i64 %23)
  %24 = add i64 %18, 24
  call void @__csan_before_call(i64 %24, i64 %23, i8 1, i64 0)
  %call3 = tail call %"class.cilk::op_add_view"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv(%"class.cilk::internal::reducer_base"* %20)
  call void @__csan_after_call(i64 %24, i64 %23, i8 1, i64 0)
  %25 = select i1 %12, i64 %9, i64 0
  %26 = or i64 %25, %13
  %27 = load i64, i64* @__csi_func_id__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, align 8
  call void @__csan_set_suppression_flag(i64 %26, i64 %27)
  call void @__csan_set_suppression_flag(i64 3, i64 %27)
  call void @__csan_set_suppression_flag(i64 3, i64 %27)
  %28 = add i64 %18, 25
  call void @__csan_before_call(i64 %28, i64 %27, i8 3, i64 0)
  invoke void @_ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_(%"struct.cilk::op_add"* %call, %"class.cilk::op_add_view"* %call3, i64* nonnull dereferenceable(8) %x1)
          to label %invoke.cont4 unwind label %lpad

invoke.cont4:                                     ; preds = %invoke.cont
  call void @__csan_after_call(i64 %28, i64 %27, i8 3, i64 0)
  %29 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %30 = add i64 %29, 25
  call void @__csan_func_exit(i64 %30, i64 %1, i64 0)
  ret void

lpad:                                             ; preds = %invoke.cont, %.noexc
  %31 = phi i64 [ %28, %invoke.cont ], [ %22, %.noexc ]
  %32 = phi i64 [ %27, %invoke.cont ], [ %21, %.noexc ]
  %33 = phi i8 [ 3, %invoke.cont ], [ 1, %.noexc ]
  %34 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %31, i64 %32, i8 %33, i64 0)
  %35 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev, align 8
  call void @__csan_set_suppression_flag(i64 %16, i64 %35)
  %36 = add i64 %18, 26
  call void @__csan_before_call(i64 %36, i64 %35, i8 1, i64 0)
  tail call void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev(%"class.cilk::internal::reducer_base"* %20) #20
  call void @__csan_after_call(i64 %36, i64 %35, i8 1, i64 0)
  %37 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %38 = add i64 %37, 26
  call void @__csan_func_exit(i64 %38, i64 %1, i64 2)
  resume { i8*, i32 } %34

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %19, i64 %17, i8 1, i64 0)
  %39 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %40 = add i64 %39, 27
  call void @__csan_func_exit(i64 %40, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev(%"class.cilk::internal::reducer_content"* %this) unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 15
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = getelementptr inbounds %"class.cilk::internal::reducer_content", %"class.cilk::internal::reducer_content"* %this, i64 0, i32 0
  %7 = getelementptr inbounds %"class.cilk::internal::reducer_content", %"class.cilk::internal::reducer_content"* %this, i64 0, i32 2, i64 0
  %8 = and i64 %5, 3
  %9 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, align 8
  call void @__csan_set_suppression_flag(i64 %8, i64 %9)
  call void @__csan_set_suppression_flag(i64 %8, i64 %9)
  %10 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %11 = add i64 %10, 12
  call void @__csan_before_call(i64 %11, i64 %9, i8 2, i64 0)
  invoke void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc(%"class.cilk::internal::reducer_base"* %6, i8* nonnull %7)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %entry
  call void @__csan_after_call(i64 %11, i64 %9, i8 2, i64 0)
  %12 = and i64 %5, 7
  %13 = load i64, i64* @__csi_func_id__ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv, align 8
  call void @__csan_set_suppression_flag(i64 %12, i64 %13)
  %14 = add i64 %10, 13
  call void @__csan_before_call(i64 %14, i64 %13, i8 1, i64 0)
  %call = tail call zeroext i1 @_ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv(%"class.cilk::internal::reducer_content"* %this)
  call void @__csan_after_call(i64 %14, i64 %13, i8 1, i64 0)
  br i1 %call, label %cond.end, label %cond.false

cond.false:                                       ; preds = %.noexc
  call void @__cilksan_disable_checking()
  tail call void @__assert_fail(i8* getelementptr inbounds ([140 x i8], [140 x i8]* @.str.10, i64 0, i64 0), i8* getelementptr inbounds ([72 x i8], [72 x i8]* @.str.11, i64 0, i64 0), i32 1019, i8* getelementptr inbounds ([145 x i8], [145 x i8]* @__PRETTY_FUNCTION__._ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev, i64 0, i64 0)) #23
  unreachable

cond.end:                                         ; preds = %.noexc
  %15 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %16 = add i64 %15, 14
  call void @__csan_func_exit(i64 %16, i64 %1, i64 0)
  ret void

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %11, i64 %9, i8 2, i64 0)
  %17 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %18 = add i64 %17, 15
  call void @__csan_func_exit(i64 %18, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_(%"struct.cilk::op_add"* %monoid, %"class.cilk::op_add_view"* %view, i64* dereferenceable(8) %x1) local_unnamed_addr #0 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 24
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %8, i64 %1, i8 2)
  %9 = load i64, i64* %8, align 8
  %10 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %11 = add i64 %10, 1
  %guard = alloca %"class.cilk::provisional_guard", align 8
  %12 = bitcast %"class.cilk::provisional_guard"* %guard to i8*
  call void @__csi_after_alloca(i64 %11, i8* nonnull %12, i64 8, i64 1)
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %12) #20
  %13 = and i64 %5, 3
  %14 = or i64 %7, %5
  %15 = and i64 %14, 4
  %16 = icmp eq i64 %15, 0
  %17 = and i64 %7, 3
  %18 = select i1 %16, i64 %17, i64 0
  %19 = or i64 %9, %5
  %20 = and i64 %19, 4
  %21 = icmp eq i64 %20, 0
  %22 = and i64 %9, 3
  %23 = select i1 %21, i64 %22, i64 0
  %24 = and i64 %5, 7
  %25 = or i64 %24, %18
  %26 = or i64 %25, %23
  %27 = load i64, i64* @__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_, align 8
  call void @__csan_set_suppression_flag(i64 %26, i64 %27)
  call void @__csan_set_suppression_flag(i64 4, i64 %27)
  %28 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %29 = add i64 %28, 16
  call void @__csan_before_call(i64 %29, i64 %27, i8 2, i64 0)
  call void @_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_(%"class.cilk::provisional_guard"* nonnull %guard, %"struct.cilk::op_add"* %monoid)
  call void @__csan_after_call(i64 %29, i64 %27, i8 2, i64 0)
  %30 = and i64 %7, 4
  %31 = select i1 %16, i64 %13, i64 0
  %32 = or i64 %31, %17
  %33 = or i64 %9, %7
  %34 = and i64 %33, 4
  %35 = icmp eq i64 %34, 0
  %36 = select i1 %35, i64 %22, i64 0
  %37 = or i64 %32, %36
  %38 = and i64 %9, %30
  %39 = or i64 %37, %38
  %40 = select i1 %21, i64 %13, i64 0
  %41 = select i1 %35, i64 %17, i64 0
  %42 = or i64 %38, %22
  %43 = or i64 %42, %40
  %44 = or i64 %43, %41
  %45 = load i64, i64* @__csi_func_id__ZN4cilk11op_add_viewIxEC2ERKx, align 8
  call void @__csan_set_suppression_flag(i64 %44, i64 %45)
  call void @__csan_set_suppression_flag(i64 %39, i64 %45)
  %46 = add i64 %28, 17
  call void @__csan_before_call(i64 %46, i64 %45, i8 2, i64 0)
  invoke void @_ZN4cilk11op_add_viewIxEC2ERKx(%"class.cilk::op_add_view"* %view, i64* nonnull dereferenceable(8) %x1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  call void @__csan_after_call(i64 %46, i64 %45, i8 2, i64 0)
  %47 = or i64 %37, %30
  %48 = load i64, i64* @__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_, align 8
  call void @__csan_set_suppression_flag(i64 %47, i64 %48)
  call void @__csan_set_suppression_flag(i64 4, i64 %48)
  %49 = add i64 %28, 18
  call void @__csan_before_call(i64 %49, i64 %48, i8 2, i64 0)
  %call = call %"class.cilk::op_add_view"* @_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_(%"class.cilk::provisional_guard"* nonnull %guard, %"class.cilk::op_add_view"* %view)
  call void @__csan_after_call(i64 %49, i64 %48, i8 2, i64 0)
  %50 = load i64, i64* @__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev, align 8
  call void @__csan_set_suppression_flag(i64 4, i64 %50)
  %51 = add i64 %28, 19
  call void @__csan_before_call(i64 %51, i64 %50, i8 1, i64 0)
  call void @_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev(%"class.cilk::provisional_guard"* nonnull %guard) #20
  call void @__csan_after_call(i64 %51, i64 %50, i8 1, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %12) #20
  %52 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %53 = add i64 %52, 22
  call void @__csan_func_exit(i64 %53, i64 %1, i64 0)
  ret void

lpad:                                             ; preds = %entry
  %54 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %46, i64 %45, i8 2, i64 0)
  %55 = load i64, i64* @__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev, align 8
  call void @__csan_set_suppression_flag(i64 4, i64 %55)
  %56 = add i64 %28, 20
  call void @__csan_before_call(i64 %56, i64 %55, i8 1, i64 0)
  call void @_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev(%"class.cilk::provisional_guard"* nonnull %guard) #20
  call void @__csan_after_call(i64 %56, i64 %55, i8 1, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %12) #20
  %57 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %58 = add i64 %57, 23
  call void @__csan_func_exit(i64 %58, i64 %1, i64 2)
  resume { i8*, i32 } %54
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc(%"class.cilk::internal::reducer_base"* %this, i8* %leftmost) unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 13
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %m_base = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0
  %reduce_fn = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 0
  %8 = and i64 %5, 3
  %9 = icmp eq i64 %8, 0
  %10 = and i64 %7, 3
  %11 = or i64 %7, %5
  %12 = and i64 %11, 4
  %13 = icmp ne i64 %12, 0
  %14 = icmp eq i64 %10, 0
  %15 = or i1 %14, %13
  %16 = and i1 %9, %15
  br i1 %16, label %.thread34, label %17

.thread34:                                        ; preds = %entry
  store void (i8*, i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, void (i8*, i8*, i8*)** %reduce_fn, align 8, !tbaa !21
  %identity_fn3 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 1
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, void (i8*, i8*)** %identity_fn3, align 8, !tbaa !22
  %destroy_fn7 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 2
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, void (i8*, i8*)** %destroy_fn7, align 8, !tbaa !23
  %allocate_fn11 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 3
  store i8* (i8*, i64)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i8* (i8*, i64)** %allocate_fn11, align 8, !tbaa !24
  %deallocate_fn15 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 4
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, void (i8*, i8*)** %deallocate_fn15, align 8, !tbaa !25
  %__flags19 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 1
  store i64 0, i64* %__flags19, align 8, !tbaa !26
  %__view_offset23 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 2
  %sub.ptr.lhs.cast24 = ptrtoint i8* %leftmost to i64
  %sub.ptr.rhs.cast25 = ptrtoint %"class.cilk::internal::reducer_base"* %this to i64
  %sub.ptr.sub26 = sub i64 %sub.ptr.lhs.cast24, %sub.ptr.rhs.cast25
  store i64 %sub.ptr.sub26, i64* %__view_offset23, align 8, !tbaa !27
  %__view_size32 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 3
  store i64 8, i64* %__view_size32, align 8, !tbaa !28
  %m_initialThis36 = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 2
  br label %37

17:                                               ; preds = %entry
  %18 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 14
  %20 = bitcast %"class.cilk::internal::reducer_base"* %this to i8*
  call void @__csan_store(i64 %19, i8* %20, i32 8, i64 8)
  store void (i8*, i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, void (i8*, i8*, i8*)** %reduce_fn, align 8, !tbaa !21
  %identity_fn = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 1
  %21 = add i64 %18, 13
  %22 = bitcast void (i8*, i8*)** %identity_fn to i8*
  call void @__csan_store(i64 %21, i8* nonnull %22, i32 8, i64 8)
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, void (i8*, i8*)** %identity_fn, align 8, !tbaa !22
  %destroy_fn = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 2
  %23 = add i64 %18, 12
  %24 = bitcast void (i8*, i8*)** %destroy_fn to i8*
  call void @__csan_store(i64 %23, i8* nonnull %24, i32 8, i64 8)
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, void (i8*, i8*)** %destroy_fn, align 8, !tbaa !23
  %allocate_fn = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 3
  %25 = add i64 %18, 11
  %26 = bitcast i8* (i8*, i64)** %allocate_fn to i8*
  call void @__csan_store(i64 %25, i8* nonnull %26, i32 8, i64 8)
  store i8* (i8*, i64)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, i8* (i8*, i64)** %allocate_fn, align 8, !tbaa !24
  %deallocate_fn = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 0, i32 4
  %27 = add i64 %18, 10
  %28 = bitcast void (i8*, i8*)** %deallocate_fn to i8*
  call void @__csan_store(i64 %27, i8* nonnull %28, i32 8, i64 8)
  store void (i8*, i8*)* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, void (i8*, i8*)** %deallocate_fn, align 8, !tbaa !25
  %__flags = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 1
  %29 = add i64 %18, 9
  %30 = bitcast i64* %__flags to i8*
  call void @__csan_store(i64 %29, i8* nonnull %30, i32 8, i64 8)
  store i64 0, i64* %__flags, align 8, !tbaa !26
  %__view_offset = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 2
  %sub.ptr.lhs.cast = ptrtoint i8* %leftmost to i64
  %sub.ptr.rhs.cast = ptrtoint %"class.cilk::internal::reducer_base"* %this to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %31 = add i64 %18, 8
  %32 = bitcast i64* %__view_offset to i8*
  call void @__csan_store(i64 %31, i8* nonnull %32, i32 8, i64 8)
  store i64 %sub.ptr.sub, i64* %__view_offset, align 8, !tbaa !27
  %__view_size = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0, i32 3
  %33 = add i64 %18, 7
  %34 = bitcast i64* %__view_size to i8*
  call void @__csan_store(i64 %33, i8* nonnull %34, i32 8, i64 8)
  store i64 8, i64* %__view_size, align 8, !tbaa !28
  %m_initialThis = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 2
  %35 = add i64 %18, 6
  %36 = bitcast i8** %m_initialThis to i8*
  call void @__csan_store(i64 %35, i8* nonnull %36, i32 8, i64 8)
  br label %37

37:                                               ; preds = %.thread34, %17
  %.in = phi i8** [ %m_initialThis36, %.thread34 ], [ %m_initialThis, %17 ]
  %38 = bitcast i8** %.in to %"class.cilk::internal::reducer_base"**
  store %"class.cilk::internal::reducer_base"* %this, %"class.cilk::internal::reducer_base"** %38, align 8, !tbaa !29
  %39 = icmp eq i64 %12, 0
  %40 = select i1 %39, i64 %10, i64 0
  %41 = and i64 %5, 7
  %42 = or i64 %41, %40
  %43 = load i64, i64* @__csi_func_id___cilkrts_hyper_create, align 8
  call void @__csan_set_suppression_flag(i64 %42, i64 %43)
  %44 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %45 = add i64 %44, 11
  call void @__csan_before_call(i64 %45, i64 %43, i8 1, i64 0)
  invoke void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base* nonnull %m_base)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %37
  call void @__csan_after_call(i64 %45, i64 %43, i8 1, i64 0)
  %46 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %47 = add i64 %46, 12
  call void @__csan_func_exit(i64 %47, i64 %1, i64 0)
  ret void

csi.cleanup:                                      ; preds = %37
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %45, i64 %43, i8 1, i64 0)
  %48 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %49 = add i64 %48, 13
  call void @__csan_func_exit(i64 %49, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local zeroext i1 @_ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv(%"class.cilk::internal::reducer_content"* %this) local_unnamed_addr #12 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 14
  %2 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %2, i64 %1, i8 0) #20
  %3 = ptrtoint %"class.cilk::internal::reducer_content"* %this to i64
  %and = and i64 %3, 63
  %cmp = icmp eq i64 %and, 0
  ret i1 %cmp
}

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #14

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_(i8* %r, i8* %lhs, i8* %rhs) #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 45
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %8, i64 %1, i8 2)
  %9 = load i64, i64* %8, align 8
  %10 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %11 = and i64 %5, 3
  %12 = or i64 %7, %5
  %13 = and i64 %12, 4
  %14 = icmp eq i64 %13, 0
  %15 = and i64 %7, 3
  %16 = select i1 %14, i64 %15, i64 0
  %17 = or i64 %9, %5
  %18 = and i64 %17, 4
  %19 = icmp eq i64 %18, 0
  %20 = and i64 %9, 3
  %21 = select i1 %19, i64 %20, i64 0
  %22 = and i64 %5, 7
  %23 = or i64 %22, %16
  %24 = or i64 %23, %21
  %25 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %24, i64 %25)
  %26 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %27 = add i64 %26, 54
  call void @__csan_before_call(i64 %27, i64 %25, i8 1, i64 0)
  %call2 = invoke %"struct.cilk::op_add"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv(%"class.cilk::internal::reducer_base"* %10)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  call void @__csan_after_call(i64 %27, i64 %25, i8 1, i64 0)
  %28 = bitcast %"struct.cilk::op_add"* %call2 to %"class.cilk::monoid_with_view"*
  %29 = bitcast i8* %lhs to %"class.cilk::op_add_view"*
  %30 = bitcast i8* %rhs to %"class.cilk::op_add_view"*
  %31 = select i1 %14, i64 %11, i64 0
  %32 = or i64 %31, %15
  %33 = or i64 %9, %7
  %34 = and i64 %33, 4
  %35 = icmp eq i64 %34, 0
  %36 = select i1 %35, i64 %20, i64 0
  %37 = or i64 %32, %36
  %38 = select i1 %19, i64 %11, i64 0
  %39 = or i64 %38, %20
  %40 = select i1 %35, i64 %15, i64 0
  %41 = or i64 %39, %40
  %42 = load i64, i64* @__csi_func_id__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_, align 8
  call void @__csan_set_suppression_flag(i64 %41, i64 %42)
  call void @__csan_set_suppression_flag(i64 %37, i64 %42)
  call void @__csan_set_suppression_flag(i64 3, i64 %42)
  %43 = add i64 %26, 55
  call void @__csan_before_call(i64 %43, i64 %42, i8 3, i64 0)
  invoke void @_ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_(%"class.cilk::monoid_with_view"* %28, %"class.cilk::op_add_view"* %29, %"class.cilk::op_add_view"* %30)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %call.noexc
  call void @__csan_after_call(i64 %43, i64 %42, i8 3, i64 0)
  %44 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %45 = add i64 %44, 53
  call void @__csan_func_exit(i64 %45, i64 %1, i64 0)
  ret void

csi.cleanup:                                      ; preds = %call.noexc, %entry
  %46 = phi i64 [ %43, %call.noexc ], [ %27, %entry ]
  %47 = phi i64 [ %42, %call.noexc ], [ %25, %entry ]
  %48 = phi i8 [ 3, %call.noexc ], [ 1, %entry ]
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %46, i64 %47, i8 %48, i64 0)
  %49 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %50 = add i64 %49, 54
  call void @__csan_func_exit(i64 %50, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_(i8* %r, i8* %view) #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 49
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %9 = or i64 %7, %5
  %10 = and i64 %9, 4
  %11 = icmp eq i64 %10, 0
  %12 = and i64 %7, 3
  %13 = select i1 %11, i64 %12, i64 0
  %14 = and i64 %5, 7
  %15 = or i64 %14, %13
  %16 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %15, i64 %16)
  %17 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %18 = add i64 %17, 58
  call void @__csan_before_call(i64 %18, i64 %16, i8 1, i64 0)
  %call2 = invoke %"struct.cilk::op_add"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv(%"class.cilk::internal::reducer_base"* %8)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  %19 = and i64 %5, 3
  call void @__csan_after_call(i64 %18, i64 %16, i8 1, i64 0)
  %20 = bitcast %"struct.cilk::op_add"* %call2 to %"class.cilk::monoid_with_view"*
  %21 = bitcast i8* %view to %"class.cilk::op_add_view"*
  %22 = select i1 %11, i64 %19, i64 0
  %23 = or i64 %22, %12
  %24 = load i64, i64* @__csi_func_id__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_, align 8
  call void @__csan_set_suppression_flag(i64 %23, i64 %24)
  call void @__csan_set_suppression_flag(i64 3, i64 %24)
  %25 = add i64 %17, 59
  call void @__csan_before_call(i64 %25, i64 %24, i8 2, i64 0)
  invoke void @_ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_(%"class.cilk::monoid_with_view"* %20, %"class.cilk::op_add_view"* %21)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %call.noexc
  call void @__csan_after_call(i64 %25, i64 %24, i8 2, i64 0)
  %26 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %27 = add i64 %26, 59
  call void @__csan_func_exit(i64 %27, i64 %1, i64 0)
  ret void

csi.cleanup:                                      ; preds = %call.noexc, %entry
  %28 = phi i64 [ %25, %call.noexc ], [ %18, %entry ]
  %29 = phi i64 [ %24, %call.noexc ], [ %16, %entry ]
  %30 = phi i8 [ 2, %call.noexc ], [ 1, %entry ]
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %28, i64 %29, i8 %30, i64 0)
  %31 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %32 = add i64 %31, 60
  call void @__csan_func_exit(i64 %32, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_(i8* %r, i8* %view) #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 51
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %9 = or i64 %7, %5
  %10 = and i64 %9, 4
  %11 = icmp eq i64 %10, 0
  %12 = and i64 %7, 3
  %13 = select i1 %11, i64 %12, i64 0
  %14 = and i64 %5, 7
  %15 = or i64 %14, %13
  %16 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %15, i64 %16)
  %17 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %18 = add i64 %17, 60
  call void @__csan_before_call(i64 %18, i64 %16, i8 1, i64 0)
  %call2 = invoke %"struct.cilk::op_add"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv(%"class.cilk::internal::reducer_base"* %8)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  %19 = and i64 %5, 3
  call void @__csan_after_call(i64 %18, i64 %16, i8 1, i64 0)
  %20 = bitcast %"struct.cilk::op_add"* %call2 to %"class.cilk::monoid_base"*
  %21 = bitcast i8* %view to %"class.cilk::op_add_view"*
  %22 = select i1 %11, i64 %19, i64 0
  %23 = or i64 %22, %12
  %24 = load i64, i64* @__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_, align 8
  call void @__csan_set_suppression_flag(i64 %23, i64 %24)
  call void @__csan_set_suppression_flag(i64 3, i64 %24)
  %25 = add i64 %17, 61
  call void @__csan_before_call(i64 %25, i64 %24, i8 2, i64 0)
  tail call void @_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_(%"class.cilk::monoid_base"* %20, %"class.cilk::op_add_view"* %21)
  call void @__csan_after_call(i64 %25, i64 %24, i8 2, i64 0)
  %26 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %27 = add i64 %26, 61
  call void @__csan_func_exit(i64 %27, i64 %1, i64 0)
  ret void

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %18, i64 %16, i8 1, i64 0)
  %28 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %29 = add i64 %28, 62
  call void @__csan_func_exit(i64 %29, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: uwtable
define linkonce_odr dso_local i8* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm(i8* %r, i64 %bytes) #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 53
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %7 = and i64 %5, 7
  %8 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %7, i64 %8)
  %9 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %10 = add i64 %9, 62
  call void @__csan_before_call(i64 %10, i64 %8, i8 1, i64 0)
  %call3 = invoke %"struct.cilk::op_add"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv(%"class.cilk::internal::reducer_base"* %6)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  call void @__csan_after_call(i64 %10, i64 %8, i8 1, i64 0)
  %11 = bitcast %"struct.cilk::op_add"* %call3 to %"class.cilk::monoid_base"*
  %12 = load i64, i64* @__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm, align 8
  call void @__csan_set_suppression_flag(i64 3, i64 %12)
  %13 = add i64 %9, 63
  call void @__csan_before_call(i64 %13, i64 %12, i8 1, i64 0)
  %call14 = invoke i8* @_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm(%"class.cilk::monoid_base"* %11, i64 %bytes)
          to label %call1.noexc unwind label %csi.cleanup

call1.noexc:                                      ; preds = %call.noexc
  call void @__csan_after_call(i64 %13, i64 %12, i8 1, i64 0)
  %14 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %15 = add i64 %14, 65
  call void @__csan_func_exit(i64 %15, i64 %1, i64 0)
  ret i8* %call14

csi.cleanup:                                      ; preds = %call.noexc, %entry
  %16 = phi i64 [ %13, %call.noexc ], [ %10, %entry ]
  %17 = phi i64 [ %12, %call.noexc ], [ %8, %entry ]
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %16, i64 %17, i8 1, i64 0)
  %18 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 66
  call void @__csan_func_exit(i64 %19, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_(i8* %r, i8* %view) #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 55
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = bitcast i8* %r to %"class.cilk::internal::reducer_base"*
  %9 = or i64 %7, %5
  %10 = and i64 %9, 4
  %11 = icmp eq i64 %10, 0
  %12 = and i64 %7, 3
  %13 = select i1 %11, i64 %12, i64 0
  %14 = and i64 %5, 7
  %15 = or i64 %14, %13
  %16 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, align 8
  call void @__csan_set_suppression_flag(i64 %15, i64 %16)
  %17 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %18 = add i64 %17, 65
  call void @__csan_before_call(i64 %18, i64 %16, i8 1, i64 0)
  %call2 = invoke %"struct.cilk::op_add"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv(%"class.cilk::internal::reducer_base"* %8)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  %19 = and i64 %5, 3
  call void @__csan_after_call(i64 %18, i64 %16, i8 1, i64 0)
  %20 = bitcast %"struct.cilk::op_add"* %call2 to %"class.cilk::monoid_base"*
  %21 = select i1 %11, i64 %19, i64 0
  %22 = or i64 %21, %12
  %23 = load i64, i64* @__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv, align 8
  call void @__csan_set_suppression_flag(i64 %22, i64 %23)
  call void @__csan_set_suppression_flag(i64 3, i64 %23)
  %24 = add i64 %17, 66
  call void @__csan_before_call(i64 %24, i64 %23, i8 2, i64 0)
  tail call void @_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv(%"class.cilk::monoid_base"* %20, i8* %view)
  call void @__csan_after_call(i64 %24, i64 %23, i8 2, i64 0)
  %25 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %26 = add i64 %25, 68
  call void @__csan_func_exit(i64 %26, i64 %1, i64 0)
  ret void

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %18, i64 %16, i8 1, i64 0)
  %27 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %28 = add i64 %27, 69
  call void @__csan_func_exit(i64 %28, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

declare dso_local void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #1

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_(%"class.cilk::monoid_with_view"* %this, %"class.cilk::op_add_view"* %left, %"class.cilk::op_add_view"* %right) local_unnamed_addr #0 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 44
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %8, i64 %1, i8 2)
  %9 = load i64, i64* %8, align 8
  %10 = and i64 %7, 3
  %11 = and i64 %7, 4
  %12 = or i64 %7, %5
  %13 = and i64 %12, 4
  %14 = icmp eq i64 %13, 0
  %15 = and i64 %5, 3
  %16 = select i1 %14, i64 %15, i64 0
  %17 = or i64 %16, %10
  %18 = or i64 %9, %7
  %19 = and i64 %18, 4
  %20 = icmp eq i64 %19, 0
  %21 = and i64 %9, 3
  %22 = select i1 %20, i64 %21, i64 0
  %23 = and i64 %11, %9
  %24 = or i64 %17, %23
  %25 = or i64 %24, %22
  %26 = or i64 %9, %5
  %27 = and i64 %26, 4
  %28 = icmp eq i64 %27, 0
  %29 = select i1 %28, i64 %15, i64 0
  %30 = select i1 %20, i64 %10, i64 0
  %31 = or i64 %23, %21
  %32 = or i64 %31, %29
  %33 = or i64 %32, %30
  %34 = load i64, i64* @__csi_func_id__ZN4cilk11op_add_viewIxE6reduceEPS1_, align 8
  call void @__csan_set_suppression_flag(i64 %33, i64 %34)
  call void @__csan_set_suppression_flag(i64 %25, i64 %34)
  %35 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %36 = add i64 %35, 53
  call void @__csan_before_call(i64 %36, i64 %34, i8 2, i64 0)
  tail call void @_ZN4cilk11op_add_viewIxE6reduceEPS1_(%"class.cilk::op_add_view"* %left, %"class.cilk::op_add_view"* %right)
  call void @__csan_after_call(i64 %36, i64 %34, i8 2, i64 0)
  %37 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %38 = add i64 %37, 52
  call void @__csan_func_exit(i64 %38, i64 %1, i64 0)
  ret void
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN4cilk11op_add_viewIxE6reduceEPS1_(%"class.cilk::op_add_view"* %this, %"class.cilk::op_add_view"* %right) local_unnamed_addr #4 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 43
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1) #20
  %7 = load i64, i64* %6, align 8
  %m_value = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %right, i64 0, i32 0, i32 0
  %8 = and i64 %7, 1
  %9 = icmp eq i64 %8, 0
  %10 = and i64 %5, 1
  %11 = or i64 %7, %5
  %12 = and i64 %11, 4
  %13 = icmp ne i64 %12, 0
  %14 = icmp eq i64 %10, 0
  %15 = or i1 %14, %13
  %16 = and i1 %9, %15
  br i1 %16, label %21, label %17

17:                                               ; preds = %entry
  %18 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 16
  %20 = bitcast %"class.cilk::op_add_view"* %right to i8*
  call void @__csan_load(i64 %19, i8* %20, i32 8, i64 8) #20
  br label %21

21:                                               ; preds = %entry, %17
  %22 = load i64, i64* %m_value, align 8, !tbaa !30
  %m_value2 = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %this, i64 0, i32 0, i32 0
  %23 = load i64, i64* %m_value2, align 8, !tbaa !30
  %add = add nsw i64 %23, %22
  %24 = and i64 %5, 3
  %25 = icmp eq i64 %24, 0
  %26 = and i64 %7, 3
  %27 = icmp eq i64 %26, 0
  %28 = or i1 %27, %13
  %29 = and i1 %25, %28
  br i1 %29, label %34, label %30

30:                                               ; preds = %21
  %31 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %32 = add i64 %31, 21
  %33 = bitcast %"class.cilk::op_add_view"* %this to i8*
  call void @__csan_store(i64 %32, i8* %33, i32 8, i64 8) #20
  br label %34

34:                                               ; preds = %21, %30
  store i64 %add, i64* %m_value2, align 8, !tbaa !30
  %35 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %36 = add i64 %35, 51
  call void @__csan_func_exit(i64 %36, i64 %1, i64 0) #20
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_(%"class.cilk::monoid_with_view"* %this, %"class.cilk::op_add_view"* %p) local_unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 48
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = or i64 %7, %5
  %9 = and i64 %8, 4
  %10 = icmp eq i64 %9, 0
  %11 = and i64 %5, 3
  %12 = select i1 %10, i64 %11, i64 0
  %13 = and i64 %7, 7
  %14 = or i64 %13, %12
  %15 = load i64, i64* @__csi_func_id__ZN4cilk11op_add_viewIxEC2Ev, align 8
  call void @__csan_set_suppression_flag(i64 %14, i64 %15)
  %16 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %17 = add i64 %16, 57
  call void @__csan_before_call(i64 %17, i64 %15, i8 1, i64 0)
  invoke void @_ZN4cilk11op_add_viewIxEC2Ev(%"class.cilk::op_add_view"* %p)
          to label %.noexc unwind label %csi.cleanup

.noexc:                                           ; preds = %entry
  call void @__csan_after_call(i64 %17, i64 %15, i8 1, i64 0)
  %18 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 57
  call void @__csan_func_exit(i64 %19, i64 %1, i64 0)
  ret void

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %17, i64 %15, i8 1, i64 0)
  %20 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %21 = add i64 %20, 58
  call void @__csan_func_exit(i64 %21, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk11op_add_viewIxEC2Ev(%"class.cilk::op_add_view"* %this) unnamed_addr #0 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 47
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %this, i64 0, i32 0
  %7 = and i64 %5, 7
  %8 = load i64, i64* @__csi_func_id__ZN4cilk11scalar_viewIxEC2Ev, align 8
  call void @__csan_set_suppression_flag(i64 %7, i64 %8)
  %9 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %10 = add i64 %9, 56
  call void @__csan_before_call(i64 %10, i64 %8, i8 1, i64 0)
  tail call void @_ZN4cilk11scalar_viewIxEC2Ev(%"class.cilk::scalar_view"* %6)
  call void @__csan_after_call(i64 %10, i64 %8, i8 1, i64 0)
  %11 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %12 = add i64 %11, 56
  call void @__csan_func_exit(i64 %12, i64 %1, i64 0)
  ret void
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN4cilk11scalar_viewIxEC2Ev(%"class.cilk::scalar_view"* %this) unnamed_addr #4 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 46
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %m_value = getelementptr inbounds %"class.cilk::scalar_view", %"class.cilk::scalar_view"* %this, i64 0, i32 0
  %6 = and i64 %5, 3
  %7 = icmp eq i64 %6, 0
  br i1 %7, label %12, label %8

8:                                                ; preds = %entry
  %9 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %10 = add i64 %9, 22
  %11 = bitcast %"class.cilk::scalar_view"* %this to i8*
  call void @__csan_store(i64 %10, i8* %11, i32 8, i64 8) #20
  br label %12

12:                                               ; preds = %entry, %8
  store i64 0, i64* %m_value, align 8, !tbaa !30
  %13 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %14 = add i64 %13, 55
  call void @__csan_func_exit(i64 %14, i64 %1, i64 0) #20
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_(%"class.cilk::monoid_base"* %this, %"class.cilk::op_add_view"* %p) local_unnamed_addr #12 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 50
  %2 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %2, i64 %1, i8 0) #20
  %3 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %3, i64 %1, i8 1) #20
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local i8* @_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm(%"class.cilk::monoid_base"* %this, i64 %s) local_unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 52
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* @__csi_unit_allocfn_base_id, align 8, !invariant.load !2
  %6 = add i64 %5, 1
  %call2 = invoke i8* @_Znwm(i64 %s)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  call void @__csan_after_allocfn(i64 %6, i8* nonnull %call2, i64 %s, i64 1, i64 0, i8* null, i64 8)
  %7 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %8 = add i64 %7, 63
  call void @__csan_func_exit(i64 %8, i64 %1, i64 0)
  ret i8* %call2

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_allocfn(i64 %6, i8* null, i64 %s, i64 1, i64 0, i8* null, i64 8)
  %9 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %10 = add i64 %9, 64
  call void @__csan_func_exit(i64 %10, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #15

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv(%"class.cilk::monoid_base"* %this, i8* %p) local_unnamed_addr #4 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 54
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1) #20
  %7 = load i64, i64* %6, align 8
  %8 = or i64 %7, %5
  %9 = and i64 %8, 4
  %10 = icmp eq i64 %9, 0
  %11 = and i64 %5, 3
  %12 = select i1 %10, i64 %11, i64 0
  %13 = and i64 %7, 7
  %14 = or i64 %13, %12
  %15 = load i64, i64* @__csi_func_id__ZdlPv, align 8
  call void @__csan_set_suppression_flag(i64 %14, i64 %15) #20
  %16 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %17 = add i64 %16, 64
  call void @__csan_before_call(i64 %17, i64 %15, i8 1, i64 0) #20
  tail call void @_ZdlPv(i8* %p) #20
  call void @__csan_after_call(i64 %17, i64 %15, i8 1, i64 0) #20
  %18 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 67
  call void @__csan_func_exit(i64 %19, i64 %1, i64 0) #20
  ret void
}

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #16

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_(%"class.cilk::provisional_guard"* %this, %"struct.cilk::op_add"* %ptr) unnamed_addr #4 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 19
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1) #20
  %7 = load i64, i64* %6, align 8
  %m_ptr = getelementptr inbounds %"class.cilk::provisional_guard", %"class.cilk::provisional_guard"* %this, i64 0, i32 0
  %8 = and i64 %5, 3
  %9 = icmp eq i64 %8, 0
  %10 = and i64 %7, 3
  %11 = or i64 %7, %5
  %12 = and i64 %11, 4
  %13 = icmp ne i64 %12, 0
  %14 = icmp eq i64 %10, 0
  %15 = or i1 %14, %13
  %16 = and i1 %9, %15
  br i1 %16, label %21, label %17

17:                                               ; preds = %entry
  %18 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 15
  %20 = bitcast %"class.cilk::provisional_guard"* %this to i8*
  call void @__csan_store(i64 %19, i8* %20, i32 8, i64 8) #20
  br label %21

21:                                               ; preds = %entry, %17
  store %"struct.cilk::op_add"* %ptr, %"struct.cilk::op_add"** %m_ptr, align 8, !tbaa !32
  %22 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %23 = add i64 %22, 18
  call void @__csan_func_exit(i64 %23, i64 %1, i64 0) #20
  ret void
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local %"class.cilk::op_add_view"* @_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_(%"class.cilk::provisional_guard"* %this, %"class.cilk::op_add_view"* %cond) local_unnamed_addr #4 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 22
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1) #20
  %7 = load i64, i64* %6, align 8
  %tobool = icmp eq %"class.cilk::op_add_view"* %cond, null
  br i1 %tobool, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %m_ptr = getelementptr inbounds %"class.cilk::provisional_guard", %"class.cilk::provisional_guard"* %this, i64 0, i32 0
  %8 = and i64 %5, 3
  %9 = icmp eq i64 %8, 0
  %10 = and i64 %7, 3
  %11 = or i64 %7, %5
  %12 = and i64 %11, 4
  %13 = icmp ne i64 %12, 0
  %14 = icmp eq i64 %10, 0
  %15 = or i1 %14, %13
  %16 = and i1 %9, %15
  br i1 %16, label %21, label %17

17:                                               ; preds = %if.then
  %18 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 17
  %20 = bitcast %"class.cilk::provisional_guard"* %this to i8*
  call void @__csan_store(i64 %19, i8* %20, i32 8, i64 8) #20
  br label %21

21:                                               ; preds = %if.then, %17
  store %"struct.cilk::op_add"* null, %"struct.cilk::op_add"** %m_ptr, align 8, !tbaa !32
  br label %if.end

if.end:                                           ; preds = %entry, %21
  %22 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %23 = add i64 %22, 21
  call void @__csan_func_exit(i64 %23, i64 %1, i64 0) #20
  ret %"class.cilk::op_add_view"* %cond
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN4cilk11op_add_viewIxEC2ERKx(%"class.cilk::op_add_view"* %this, i64* dereferenceable(8) %v) unnamed_addr #0 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 21
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1)
  %7 = load i64, i64* %6, align 8
  %8 = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %this, i64 0, i32 0
  %9 = and i64 %5, 3
  %10 = and i64 %5, 4
  %11 = or i64 %7, %5
  %12 = and i64 %11, 4
  %13 = icmp eq i64 %12, 0
  %14 = and i64 %7, 3
  %15 = select i1 %13, i64 %14, i64 0
  %16 = and i64 %10, %7
  %17 = or i64 %16, %9
  %18 = or i64 %17, %15
  %19 = select i1 %13, i64 %9, i64 0
  %20 = or i64 %16, %14
  %21 = or i64 %20, %19
  %22 = load i64, i64* @__csi_func_id__ZN4cilk11scalar_viewIxEC2ERKx, align 8
  call void @__csan_set_suppression_flag(i64 %21, i64 %22)
  call void @__csan_set_suppression_flag(i64 %18, i64 %22)
  %23 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %24 = add i64 %23, 15
  call void @__csan_before_call(i64 %24, i64 %22, i8 2, i64 0)
  tail call void @_ZN4cilk11scalar_viewIxEC2ERKx(%"class.cilk::scalar_view"* %8, i64* nonnull dereferenceable(8) %v)
  call void @__csan_after_call(i64 %24, i64 %22, i8 2, i64 0)
  %25 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %26 = add i64 %25, 20
  call void @__csan_func_exit(i64 %26, i64 %1, i64 0)
  ret void
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev(%"class.cilk::provisional_guard"* %this) unnamed_addr #12 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 23
  %2 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %2, i64 %1, i8 0) #20
  ret void
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local void @_ZN4cilk11scalar_viewIxEC2ERKx(%"class.cilk::scalar_view"* %this, i64* dereferenceable(8) %v) unnamed_addr #4 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 20
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1) #20
  %7 = load i64, i64* %6, align 8
  %m_value = getelementptr inbounds %"class.cilk::scalar_view", %"class.cilk::scalar_view"* %this, i64 0, i32 0
  %8 = and i64 %7, 1
  %9 = icmp eq i64 %8, 0
  %10 = and i64 %5, 1
  %11 = or i64 %7, %5
  %12 = and i64 %11, 4
  %13 = icmp ne i64 %12, 0
  %14 = icmp eq i64 %10, 0
  %15 = or i1 %14, %13
  %16 = and i1 %9, %15
  br i1 %16, label %21, label %17

17:                                               ; preds = %entry
  %18 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 7
  %20 = bitcast i64* %v to i8*
  call void @__csan_load(i64 %19, i8* nonnull %20, i32 8, i64 8) #20
  br label %21

21:                                               ; preds = %entry, %17
  %22 = load i64, i64* %v, align 8, !tbaa !9
  %23 = and i64 %5, 3
  %24 = icmp eq i64 %23, 0
  %25 = and i64 %7, 3
  %26 = icmp eq i64 %25, 0
  %27 = or i1 %26, %13
  %28 = and i1 %24, %27
  br i1 %28, label %33, label %29

29:                                               ; preds = %21
  %30 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %31 = add i64 %30, 16
  %32 = bitcast %"class.cilk::scalar_view"* %this to i8*
  call void @__csan_store(i64 %31, i8* %32, i32 8, i64 8) #20
  br label %33

33:                                               ; preds = %21, %29
  store i64 %22, i64* %m_value, align 8, !tbaa !30
  %34 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %35 = add i64 %34, 19
  call void @__csan_func_exit(i64 %35, i64 %1, i64 0) #20
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local dereferenceable(8) %"class.cilk::op_add_view"* @_ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::reducer"* %this) local_unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 30
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %this, i64 0, i32 0, i32 0
  %7 = and i64 %5, 7
  %8 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, align 8
  call void @__csan_set_suppression_flag(i64 %7, i64 %8)
  %9 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %10 = add i64 %9, 29
  call void @__csan_before_call(i64 %10, i64 %8, i8 1, i64 0)
  %call2 = invoke dereferenceable(8) %"class.cilk::op_add_view"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::internal::reducer_base"* %6)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  call void @__csan_after_call(i64 %10, i64 %8, i8 1, i64 0)
  %11 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %12 = add i64 %11, 32
  call void @__csan_func_exit(i64 %12, i64 %1, i64 0)
  ret %"class.cilk::op_add_view"* %call2

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %10, i64 %8, i8 1, i64 0)
  %13 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %14 = add i64 %13, 33
  call void @__csan_func_exit(i64 %14, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: nounwind uwtable
define linkonce_odr dso_local dereferenceable(8) %"class.cilk::op_add_view"* @_ZN4cilk11op_add_viewIxEpLERKx(%"class.cilk::op_add_view"* %this, i64* dereferenceable(8) %x) local_unnamed_addr #4 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 31
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0) #20
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0) #20
  %5 = load i64, i64* %4, align 8
  %6 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %6, i64 %1, i8 1) #20
  %7 = load i64, i64* %6, align 8
  %8 = and i64 %7, 1
  %9 = icmp eq i64 %8, 0
  %10 = and i64 %5, 1
  %11 = or i64 %7, %5
  %12 = and i64 %11, 4
  %13 = icmp ne i64 %12, 0
  %14 = icmp eq i64 %10, 0
  %15 = or i1 %14, %13
  %16 = and i1 %9, %15
  br i1 %16, label %21, label %17

17:                                               ; preds = %entry
  %18 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 8
  %20 = bitcast i64* %x to i8*
  call void @__csan_load(i64 %19, i8* nonnull %20, i32 8, i64 8) #20
  br label %21

21:                                               ; preds = %entry, %17
  %22 = load i64, i64* %x, align 8, !tbaa !9
  %m_value = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %this, i64 0, i32 0, i32 0
  %23 = load i64, i64* %m_value, align 8, !tbaa !30
  %add = add nsw i64 %23, %22
  %24 = and i64 %5, 3
  %25 = icmp eq i64 %24, 0
  %26 = and i64 %7, 3
  %27 = icmp eq i64 %26, 0
  %28 = or i1 %27, %13
  %29 = and i1 %25, %28
  br i1 %29, label %34, label %30

30:                                               ; preds = %21
  %31 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %32 = add i64 %31, 18
  %33 = bitcast %"class.cilk::op_add_view"* %this to i8*
  call void @__csan_store(i64 %32, i8* %33, i32 8, i64 8) #20
  br label %34

34:                                               ; preds = %21, %30
  store i64 %add, i64* %m_value, align 8, !tbaa !30
  %35 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %36 = add i64 %35, 34
  call void @__csan_func_exit(i64 %36, i64 %1, i64 0) #20
  ret %"class.cilk::op_add_view"* %this
}

; Function Attrs: uwtable
define linkonce_odr dso_local dereferenceable(8) %"class.cilk::op_add_view"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::internal::reducer_base"* %this) local_unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 29
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %m_base = getelementptr inbounds %"class.cilk::internal::reducer_base", %"class.cilk::internal::reducer_base"* %this, i64 0, i32 0
  %6 = and i64 %5, 7
  %7 = load i64, i64* @__csi_func_id___cilkrts_hyper_lookup, align 8
  call void @__csan_set_suppression_flag(i64 %6, i64 %7)
  %8 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %9 = add i64 %8, 28
  call void @__csan_before_call(i64 %9, i64 %7, i8 1, i64 0)
  %call2 = invoke i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base* %m_base)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  call void @__csan_after_call(i64 %9, i64 %7, i8 1, i64 0)
  %10 = bitcast i8* %call2 to %"class.cilk::op_add_view"*
  %11 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %12 = add i64 %11, 30
  call void @__csan_func_exit(i64 %12, i64 %1, i64 0)
  ret %"class.cilk::op_add_view"* %10

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %9, i64 %7, i8 1, i64 0)
  %13 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %14 = add i64 %13, 31
  call void @__csan_func_exit(i64 %14, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

declare dso_local i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #1

; Function Attrs: uwtable
define linkonce_odr dso_local dereferenceable(8) i64* @_ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_(%"class.cilk::op_add_view"* dereferenceable(8) %view) local_unnamed_addr #0 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 36
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = getelementptr inbounds %"class.cilk::op_add_view", %"class.cilk::op_add_view"* %view, i64 0, i32 0
  %7 = and i64 %5, 7
  %8 = load i64, i64* @__csi_func_id__ZNK4cilk11scalar_viewIxE14view_get_valueEv, align 8
  call void @__csan_set_suppression_flag(i64 %7, i64 %8)
  %9 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %10 = add i64 %9, 34
  call void @__csan_before_call(i64 %10, i64 %8, i8 1, i64 0)
  %call = tail call dereferenceable(8) i64* @_ZNK4cilk11scalar_viewIxE14view_get_valueEv(%"class.cilk::scalar_view"* nonnull %6)
  call void @__csan_after_call(i64 %10, i64 %8, i8 1, i64 0)
  %11 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %12 = add i64 %11, 41
  call void @__csan_func_exit(i64 %12, i64 %1, i64 0)
  ret i64* %call
}

; Function Attrs: uwtable
define linkonce_odr dso_local dereferenceable(8) %"class.cilk::op_add_view"* @_ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::reducer"* %this) local_unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 34
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = getelementptr inbounds %"class.cilk::reducer", %"class.cilk::reducer"* %this, i64 0, i32 0, i32 0
  %7 = and i64 %5, 7
  %8 = load i64, i64* @__csi_func_id__ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, align 8
  call void @__csan_set_suppression_flag(i64 %7, i64 %8)
  %9 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %10 = add i64 %9, 33
  call void @__csan_before_call(i64 %10, i64 %8, i8 1, i64 0)
  %call2 = invoke dereferenceable(8) %"class.cilk::op_add_view"* @_ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::internal::reducer_base"* %6)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  call void @__csan_after_call(i64 %10, i64 %8, i8 1, i64 0)
  %11 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %12 = add i64 %11, 39
  call void @__csan_func_exit(i64 %12, i64 %1, i64 0)
  ret %"class.cilk::op_add_view"* %call2

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %10, i64 %8, i8 1, i64 0)
  %13 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %14 = add i64 %13, 40
  call void @__csan_func_exit(i64 %14, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local dereferenceable(8) i64* @_ZNK4cilk11scalar_viewIxE14view_get_valueEv(%"class.cilk::scalar_view"* %this) local_unnamed_addr #12 comdat align 2 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 35
  %2 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %2, i64 %1, i8 0) #20
  %m_value = getelementptr inbounds %"class.cilk::scalar_view", %"class.cilk::scalar_view"* %this, i64 0, i32 0
  ret i64* %m_value
}

; Function Attrs: uwtable
define linkonce_odr dso_local dereferenceable(8) %"class.cilk::op_add_view"* @_ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::internal::reducer_base"* %this) local_unnamed_addr #0 comdat align 2 personality i32 (...)* @__gcc_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 33
  %2 = call i8* @llvm.frameaddress(i32 0)
  %3 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %1, i8* %2, i8* %3, i64 0)
  %4 = alloca i64, align 8
  call void @__csan_get_suppression_flag(i64* nonnull %4, i64 %1, i8 0)
  %5 = load i64, i64* %4, align 8
  %6 = and i64 %5, 7
  %7 = load i64, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, align 8
  call void @__csan_set_suppression_flag(i64 %6, i64 %7)
  %8 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %9 = add i64 %8, 32
  call void @__csan_before_call(i64 %9, i64 %7, i8 1, i64 0)
  %call2 = invoke dereferenceable(8) %"class.cilk::op_add_view"* @_ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv(%"class.cilk::internal::reducer_base"* %this)
          to label %call.noexc unwind label %csi.cleanup

call.noexc:                                       ; preds = %entry
  call void @__csan_after_call(i64 %9, i64 %7, i8 1, i64 0)
  %10 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %11 = add i64 %10, 37
  call void @__csan_func_exit(i64 %11, i64 %1, i64 0)
  ret %"class.cilk::op_add_view"* %call2

csi.cleanup:                                      ; preds = %entry
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %9, i64 %7, i8 1, i64 0)
  %12 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %13 = add i64 %12, 38
  call void @__csan_func_exit(i64 %13, i64 %1, i64 2)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; Function Attrs: nofree nounwind
declare i64 @fwrite(i8* nocapture, i64, i64, %struct._IO_FILE* nocapture) local_unnamed_addr #3

declare void @__csi_func_entry(i64, i64)

declare void @__csi_func_exit(i64, i64, i64)

declare void @__csi_before_loop(i64, i64, i64)

declare void @__csi_after_loop(i64, i64)

declare void @__csi_loopbody_entry(i64, i64)

declare void @__csi_loopbody_exit(i64, i64, i64)

declare void @__csi_before_alloca(i64, i64, i64)

; Function Attrs: inaccessiblememonly
declare void @__csi_after_alloca(i64, i8* nocapture readnone, i64, i64) #17

declare void @__csi_before_allocfn(i64, i64, i64, i64, i8*, i64)

declare void @__csi_after_allocfn(i64, i8*, i64, i64, i64, i8*, i64)

declare void @__csi_before_free(i64, i8*, i64)

declare void @__csi_after_free(i64, i8*, i64)

define internal void @__csi_init_callsite_to_function() {
  %1 = load i64, i64* @__csi_unit_func_base_id, align 8
  %2 = add i64 %1, 30
  store i64 %2, i64* @__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, align 8
  %3 = add i64 %1, 23
  store i64 %3, i64* @__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEED2Ev, align 8
  %4 = add i64 %1, 25
  store i64 %4, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEED2Ev, align 8
  %5 = add i64 %1, 51
  store i64 %5, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE15destroy_wrapperEPvS5_, align 8
  %6 = add i64 %1, 3
  store i64 %6, i64* @__csi_func_id__ZlsRSt14basic_ofstreamIcSt11char_traitsIcEERK5wsp_t, align 8
  %7 = add i64 %1, 4
  store i64 %7, i64* @__csi_func_id_wsp_getworkspan, align 8
  %8 = add i64 %1, 54
  store i64 %8, i64* @__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE10deallocateEPv, align 8
  %9 = add i64 %1, 50
  store i64 %9, i64* @__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE7destroyEPS2_, align 8
  %10 = add i64 %1, 42
  store i64 %10, i64* @__csi_func_id__Z18accum_spawn_coarsePKll, align 8
  %11 = add i64 %1, 52
  store i64 %11, i64* @__csi_func_id__ZNK4cilk11monoid_baseIxNS_11op_add_viewIxEEE8allocateEm, align 8
  %12 = add i64 %1, 35
  store i64 %12, i64* @__csi_func_id__ZNK4cilk11scalar_viewIxE14view_get_valueEv, align 8
  %13 = add i64 %1, 11
  store i64 %13, i64* @__csi_func_id_main, align 8
  %14 = add i64 %1, 13
  store i64 %14, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEC2EPc, align 8
  %15 = add i64 %1, 6
  store i64 %15, i64* @__csi_func_id_wsp_sub, align 8
  %16 = add i64 %1, 41
  store i64 %16, i64* @__csi_func_id__Z11accum_spawnPKll, align 8
  %17 = add i64 %1, 38
  store i64 %17, i64* @__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEED2Ev, align 8
  %18 = add i64 %1, 44
  store i64 %18, i64* @__csi_func_id__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE6reduceEPS2_S4_, align 8
  %19 = add i64 %1, 47
  store i64 %19, i64* @__csi_func_id__ZN4cilk11op_add_viewIxEC2Ev, align 8
  %20 = add i64 %1, 19
  store i64 %20, i64* @__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEEC2EPS2_, align 8
  %21 = add i64 %1, 55
  store i64 %21, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE18deallocate_wrapperEPvS5_, align 8
  %22 = add i64 %1, 32
  store i64 %22, i64* @__csi_func_id__ZN4cilk13reducer_opaddIxEpLERKx, align 8
  %23 = add i64 %1, 56
  store i64 %23, i64* @__csi_func_id___cxx_global_var_init, align 8
  %24 = add i64 %1, 22
  store i64 %24, i64* @__csi_func_id__ZN4cilk17provisional_guardINS_6op_addIxLb1EEEE10confirm_ifINS_11op_add_viewIxEEEEPT_S8_, align 8
  %25 = add i64 %1, 17
  store i64 %25, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE10monoid_ptrEv, align 8
  %26 = add i64 %1, 33
  store i64 %26, i64* @__csi_func_id__ZNK4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, align 8
  %27 = add i64 %1, 26
  store i64 %27, i64* @__csi_func_id__ZN4cilk7reducerINS_6op_addIxLb1EEEEC2IxEERKT_, align 8
  %28 = add i64 %1, 48
  store i64 %28, i64* @__csi_func_id__ZNK4cilk16monoid_with_viewINS_11op_add_viewIxEELb1EE8identityEPS2_, align 8
  store i64 %1, i64* @__csi_func_id__Zpl5wsp_tRKS_, align 8
  %29 = add i64 %1, 36
  store i64 %29, i64* @__csi_func_id__ZN4cilk8internal15reducer_set_getIxNS_11op_add_viewIxEEE9get_valueERKS3_, align 8
  %30 = add i64 %1, 31
  store i64 %30, i64* @__csi_func_id__ZN4cilk11op_add_viewIxEpLERKx, align 8
  %31 = add i64 %1, 9
  store i64 %31, i64* @__csi_func_id__Z10accum_truePKll, align 8
  %32 = add i64 %1, 21
  store i64 %32, i64* @__csi_func_id__ZN4cilk11op_add_viewIxEC2ERKx, align 8
  %33 = add i64 %1, 14
  store i64 %33, i64* @__csi_func_id__ZNK4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EE24reducer_is_cache_alignedEv, align 8
  %34 = add i64 %1, 24
  store i64 %34, i64* @__csi_func_id__ZN4cilk11monoid_baseIxNS_11op_add_viewIxEEE9constructINS_6op_addIxLb1EEExEEvPT_PS2_RKT0_, align 8
  %35 = add i64 %1, 37
  store i64 %35, i64* @__csi_func_id__ZNK4cilk7reducerINS_6op_addIxLb1EEEE9get_valueEv, align 8
  %36 = add i64 %1, 7
  store i64 %36, i64* @__csi_func_id_wsp_dump, align 8
  %37 = add i64 %1, 5
  store i64 %37, i64* @__csi_func_id_wsp_add, align 8
  %38 = add i64 %1, 8
  store i64 %38, i64* @__csi_func_id_atoi, align 8
  %39 = add i64 %1, 18
  store i64 %39, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE12leftmost_ptrEv, align 8
  %40 = add i64 %1, 53
  store i64 %40, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16allocate_wrapperEPvm, align 8
  %41 = add i64 %1, 34
  store i64 %41, i64* @__csi_func_id__ZNK4cilk7reducerINS_6op_addIxLb1EEEE4viewEv, align 8
  %42 = add i64 %1, 49
  store i64 %42, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE16identity_wrapperEPvS5_, align 8
  %43 = add i64 %1, 27
  store i64 %43, i64* @__csi_func_id__ZN4cilk13reducer_opaddIxEC2ERKx, align 8
  %44 = add i64 %1, 43
  store i64 %44, i64* @__csi_func_id__ZN4cilk11op_add_viewIxE6reduceEPS1_, align 8
  %45 = add i64 %1, 29
  store i64 %45, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE4viewEv, align 8
  %46 = add i64 %1, 12
  store i64 %46, i64* @__csi_func_id__Z11accum_wrongPKll, align 8
  %47 = add i64 %1, 2
  store i64 %47, i64* @__csi_func_id__ZlsRSoRK5wsp_t, align 8
  %48 = add i64 %1, 15
  store i64 %48, i64* @__csi_func_id__ZN4cilk8internal15reducer_contentINS_6op_addIxLb1EEELb1EEC2Ev, align 8
  %49 = add i64 %1, 46
  store i64 %49, i64* @__csi_func_id__ZN4cilk11scalar_viewIxEC2Ev, align 8
  %50 = add i64 %1, 45
  store i64 %50, i64* @__csi_func_id__ZN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEE14reduce_wrapperEPvS5_S5_, align 8
  %51 = add i64 %1, 20
  store i64 %51, i64* @__csi_func_id__ZN4cilk11scalar_viewIxEC2ERKx, align 8
  %52 = add i64 %1, 10
  store i64 %52, i64* @__csi_func_id__Z9run_accumPFxPKllES0_lxPKc, align 8
  %53 = add i64 %1, 39
  store i64 %53, i64* @__csi_func_id__Z13accum_reducerPKll, align 8
  %54 = add i64 %1, 57
  store i64 %54, i64* @__csi_func_id__GLOBAL__sub_I_sum_vector_int.cpp, align 8
  %55 = add i64 %1, 40
  store i64 %55, i64* @__csi_func_id__Z10accum_lockPKll, align 8
  %56 = add i64 %1, 28
  store i64 %56, i64* @__csi_func_id__ZN4cilk13reducer_opaddIxEdeEv, align 8
  %57 = add i64 %1, 16
  store i64 %57, i64* @__csi_func_id__ZN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEE6objectEv, align 8
  %58 = add i64 %1, 1
  store i64 %58, i64* @__csi_func_id__Zmi5wsp_tRKS_, align 8
  ret void
}

; Function Attrs: inaccessiblememonly
declare void @__csan_func_entry(i64, i8* nocapture readnone, i8* nocapture readnone, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_func_exit(i64, i64, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_load(i64, i8* nocapture readnone, i32, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_store(i64, i8* nocapture readnone, i32, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_large_load(i64, i8* nocapture readnone, i64, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_large_store(i64, i8* nocapture readnone, i64, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_before_call(i64, i64, i8, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_after_call(i64, i64, i8, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_detach(i64, i8) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_task(i64, i64, i8* nocapture readnone, i8* nocapture readnone, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_task_exit(i64, i64, i64, i8, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_detach_continue(i64, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_sync(i64, i8) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_after_allocfn(i64, i8* nocapture readnone, i64, i64, i64, i8* nocapture readnone, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_after_free(i64, i8* nocapture readnone, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__cilksan_disable_checking() #17

; Function Attrs: inaccessiblememonly
declare void @__cilksan_enable_checking() #17

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_get_suppression_flag(i64* nocapture, i64, i8) #18

; Function Attrs: inaccessiblememonly
declare void @__csan_set_suppression_flag(i64, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_before_loop(i64, i64, i64) #17

; Function Attrs: inaccessiblememonly
declare void @__csan_after_loop(i64, i8, i64) #17

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress(i32 immarg) #19

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #20

declare i32 @__gcc_personality_v0(...)

; Function Attrs: nounwind
declare i8* @llvm.task.frameaddress(i32) #20

define internal void @csirt.unit_ctor() {
  call void @__csirt_unit_init(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @0, i64 0, i64 0), { i64, i8*, { i8*, i32, i32, i8* }* }* getelementptr inbounds ([16 x { i64, i8*, { i8*, i32, i32, i8* }* }], [16 x { i64, i8*, { i8*, i32, i32, i8* }* }]* @__csi_unit_fed_tables, i64 0, i64 0), { i64, { i8*, i32, i8* }* }* getelementptr inbounds ([4 x { i64, { i8*, i32, i8* }* }], [4 x { i64, { i8*, i32, i8* }* }]* @__csi_unit_obj_tables, i64 0, i64 0), void ()* nonnull @__csi_init_callsite_to_function)
  ret void
}

declare void @__csirt_unit_init(i8*, { i64, i8*, { i8*, i32, i32, i8* }* }*, { i64, { i8*, i32, i8* }* }*, void ()*)

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nofree nounwind }
attributes #4 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { argmemonly nounwind }
attributes #6 = { norecurse nounwind readnone sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { norecurse uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { inlinehint nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { argmemonly }
attributes #12 = { nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #13 = { noinline noreturn nounwind }
attributes #14 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #17 = { inaccessiblememonly }
attributes #18 = { inaccessiblemem_or_argmemonly }
attributes #19 = { nounwind readnone }
attributes #20 = { nounwind }
attributes #21 = { nounwind readonly }
attributes #22 = { cold }
attributes #23 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git 84b6f35b85d69af111adaff237196aaded1a60d6)"}
!2 = !{}
!3 = !{!4, !4, i64 0}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!8, !8, i64 0}
!8 = !{!"long", !5, i64 0}
!9 = !{!10, !10, i64 0}
!10 = !{!"long long", !5, i64 0}
!11 = distinct !{!11, !12}
!12 = !{!"tapir.loop.spawn.strategy", i32 1}
!13 = distinct !{!13, !12, !14}
!14 = !{!"tapir.loop.grainsize", i32 2048}
!15 = distinct !{!15, !12}
!16 = !{!17, !8, i64 48}
!17 = !{!"_ZTSN4cilk8internal12reducer_baseINS_6op_addIxLb1EEEEE", !18, i64 0, !20, i64 64, !4, i64 72}
!18 = !{!"_ZTS26__cilkrts_hyperobject_base", !19, i64 0, !10, i64 40, !8, i64 48, !8, i64 56}
!19 = !{!"_ZTS13cilk_c_monoid", !4, i64 0, !4, i64 8, !4, i64 16, !4, i64 24, !4, i64 32}
!20 = !{!"_ZTSN4cilk8internal18storage_for_objectINS_6op_addIxLb1EEEEE"}
!21 = !{!19, !4, i64 0}
!22 = !{!19, !4, i64 8}
!23 = !{!19, !4, i64 16}
!24 = !{!19, !4, i64 24}
!25 = !{!19, !4, i64 32}
!26 = !{!18, !10, i64 40}
!27 = !{!18, !8, i64 48}
!28 = !{!18, !8, i64 56}
!29 = !{!17, !4, i64 72}
!30 = !{!31, !10, i64 0}
!31 = !{!"_ZTSN4cilk11scalar_viewIxEE", !10, i64 0}
!32 = !{!33, !4, i64 0}
!33 = !{!"_ZTSN4cilk17provisional_guardINS_6op_addIxLb1EEEEE", !4, i64 0}
