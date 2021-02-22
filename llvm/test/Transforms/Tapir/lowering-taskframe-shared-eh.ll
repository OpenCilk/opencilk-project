; Check that Tapir lowering properly handles PHI nodes in shared-EH
; spindles when outlining taskframes.
;
; RUN: opt < %s -tapir2target -S -o - -use-opencilk-runtime-bc=false | FileCheck %s
; RUN: opt < %s -passes='tapir2target' -S -o - -use-opencilk-runtime-bc=false | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i64, %union.anon.1 }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider" = type { i8* }
%union.anon.1 = type { i64, [8 x i8] }
%class.anon.90 = type { %"class.parlay::sequence.2"*, %"class.parlay::sequence"**, %class.anon.86* }
%"class.parlay::sequence.2" = type { %"struct.parlay::_sequence_base.3" }
%"struct.parlay::_sequence_base.3" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::_data_impl" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::_data_impl" = type { %union.anon.6, i8 }
%union.anon.6 = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::long_seq" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::long_seq" = type <{ %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer", [6 x i8] }>
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer::header"* }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer::header" = type <{ i64, %union.anon.33, [7 x i8] }>
%union.anon.33 = type { [1 x i8] }
%"class.parlay::sequence" = type { %"struct.parlay::_sequence_base" }
%"struct.parlay::_sequence_base" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::_data_impl" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::_data_impl" = type { %union.anon, i8 }
%union.anon = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::long_seq" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::long_seq" = type <{ %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer", [6 x i8] }>
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header" = type <{ i64, %union.anon.32, [7 x i8] }>
%union.anon.32 = type { [1 x i8] }
%class.anon.86 = type { %class.anon.27*, %"struct.std::pair.87"* }
%class.anon.27 = type { %"class.parlay::sequence"*, %"class.parlay::sequence"* }
%"struct.std::pair.87" = type { %"class.parlay::sequence", i64 }
%"struct.parlay::allocator.35" = type { i8 }
%class.anon.92 = type { %"class.parlay::sequence"*, i8**, i8** }
%"struct.parlay::pool_allocator" = type { i64, i64, i64, i64, %"struct.std::atomic", %"struct.std::atomic", %"class.std::unique_ptr", %"struct.parlay::block_allocator"*, %"class.std::vector", i64 }
%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"struct.std::__atomic_base" = type { i64 }
%"class.std::unique_ptr" = type { %"struct.std::__uniq_ptr_data" }
%"struct.std::__uniq_ptr_data" = type { %"class.std::__uniq_ptr_impl" }
%"class.std::__uniq_ptr_impl" = type { %"class.std::tuple" }
%"class.std::tuple" = type { %"struct.std::_Tuple_impl" }
%"struct.std::_Tuple_impl" = type { %"struct.std::_Head_base.38" }
%"struct.std::_Head_base.38" = type { %"class.parlay::concurrent_stack"* }
%"class.parlay::concurrent_stack" = type { %"class.parlay::concurrent_stack<void *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<void *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<void *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<void *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<void *>::Node" = type { i8*, %"struct.parlay::concurrent_stack<void *>::Node"*, i64 }
%"class.std::mutex" = type { %"class.std::__mutex_base" }
%"class.std::__mutex_base" = type { %union.pthread_mutex_t }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%"struct.parlay::block_allocator" = type { i8, [63 x i8], %"class.parlay::concurrent_stack.39", %"class.parlay::concurrent_stack.40", %"struct.parlay::block_allocator::thread_list"*, i64, i64, i64, %"struct.std::atomic", i64, [16 x i8] }
%"class.parlay::concurrent_stack.39" = type { %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<char *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<char *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<char *>::Node" = type { i8*, %"struct.parlay::concurrent_stack<char *>::Node"*, i64 }
%"class.parlay::concurrent_stack.40" = type { %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node" = type { %"struct.parlay::block_allocator::block"*, %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node"*, i64 }
%"struct.parlay::block_allocator::block" = type { %"struct.parlay::block_allocator::block"* }
%"struct.parlay::block_allocator::thread_list" = type { i64, %"struct.parlay::block_allocator::block"*, %"struct.parlay::block_allocator::block"*, [256 x i8], [40 x i8] }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl_data" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl_data" = type { i64*, i64*, i64* }

@_ZN7benchIO11intHeaderIOB5cxx11E = dso_local global %"class.std::__cxx11::basic_string" zeroinitializer, align 8
@.str.18 = private unnamed_addr constant [4 x i8] c"%lu\00", align 1
@__csi_unit_func_base_id = internal global i64 0
@__csi_unit_func_exit_base_id = internal global i64 0
@__csi_unit_loop_base_id = internal global i64 0
@__csi_unit_callsite_base_id = internal global i64 0
@__csi_unit_load_base_id = internal global i64 0
@__csi_unit_store_base_id = internal global i64 0
@__csi_unit_alloca_base_id = internal global i64 0
@__csi_unit_detach_base_id = internal global i64 0
@__csi_unit_task_base_id = internal global i64 0
@__csi_unit_task_exit_base_id = internal global i64 0
@__csi_unit_detach_continue_base_id = internal global i64 0
@__csi_unit_sync_base_id = internal global i64 0
@__csi_func_id_sysconf = weak global i64 -1
@__csi_func_id__ZSt20__throw_length_errorPKc = weak global i64 -1
@__csi_func_id__ZSt20__throw_system_errori = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE4pushES3_ = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_15block_allocator7reserveEmEUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id___cilkrts_get_nworkers = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE5clearEv = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPcE4pushES1_ = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPcE5clearEv = weak global i64 -1
@__csi_func_id__ZSt17__throw_bad_allocv = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPvE5clearEv = weak global i64 -1
@__csi_func_id___cxa_allocate_exception = weak global i64 -1
@__csi_func_id__ZNSt16invalid_argumentC1EPKc = weak global i64 -1
@__csi_func_id___cxa_throw = weak global i64 -1
@__csi_func_id___cxa_free_exception = weak global i64 -1
@__csi_func_id__ZN6parlay15block_allocatorC2Emmmm = weak global i64 -1
@__csi_func_id___cxa_guard_acquire = weak global i64 -1
@__csi_func_id___cxa_atexit = weak global i64 -1
@__csi_func_id___cxa_guard_release = weak global i64 -1
@__csi_func_id___cxa_guard_abort = weak global i64 -1
@__csi_func_id__ZN6parlay13default_sizesEv = weak global i64 -1
@__csi_func_id__ZN6parlay14pool_allocatorC2ERKSt6vectorImSaImEE = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPvE3popEv = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE3popEv = weak global i64 -1
@__csi_func_id__ZN6parlay8internal21get_default_allocatorEv = weak global i64 -1
@__csi_func_id__ZN6parlay14pool_allocator14allocate_largeEm = weak global i64 -1
@__csi_func_id___cilkrts_get_worker_number = weak global i64 -1
@__csi_func_id__ZN6parlay15block_allocator8get_listEv = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE15initialize_fillEmRKcEUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPvE4pushES1_ = weak global i64 -1
@__csi_func_id__ZN6parlay9allocatorISt4byteE8allocateEm = weak global i64 -1
@__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm = weak global i64 -1
@__csi_func_id_strlen = weak global i64 -1
@__csi_func_id__ZNSt14basic_ifstreamIcSt11char_traitsIcEEC1EPKcSt13_Ios_Openmode = weak global i64 -1
@__csi_func_id__ZNKSt12__basic_fileIcE7is_openEv = weak global i64 -1
@__csi_func_id__ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l = weak global i64 -1
@__csi_func_id__ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate = weak global i64 -1
@__csi_func_id__ZSt16__throw_bad_castv = weak global i64 -1
@__csi_func_id__ZNKSt5ctypeIcE13_M_widen_initEv = weak global i64 -1
@__csi_func_id__ZNSo3putEc = weak global i64 -1
@__csi_func_id__ZNSo5flushEv = weak global i64 -1
@__csi_func_id__ZNSi5tellgEv = weak global i64 -1
@__csi_func_id__ZNSi5seekgElSt12_Ios_Seekdir = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceIcNS_9allocatorIcEEEC2EmRKc = weak global i64 -1
@__csi_func_id__ZNSi4readEPcl = weak global i64 -1
@__csi_func_id__ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv = weak global i64 -1
@__csi_func_id__ZNSt13basic_filebufIcSt11char_traitsIcEED2Ev = weak global i64 -1
@__csi_func_id__ZNSt8ios_baseD2Ev = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS_5sliceINS_16delayed_sequenceIlZNS_4iotaIlEEDaT_EUlmE_E8iteratorES8_EENS_9allocatorIS9_EEEC1IRZNS_13block_delayed14make_iteratorsIS7_EEDaRKS5_EUlmE_EEmOS5_NSC_18_from_function_tagEmEUlmE_EEvmmS5_mb = weak global i64 -1
@__csi_func_id__ZN6parlay9allocatorIlE8allocateEm = weak global i64 -1
@"__csi_func_id__ZN6parlay14stream_delayed10filter_mapINS_5sliceINS_16delayed_sequenceIlZNS_4iotaIlEEDaT_EUlmE_E8iteratorES8_EEZNS_14map_tokens_oldIRKNS_8file_mapEZNS_6tokensISB_N7benchIO3$_0EEENS_8sequenceINSH_IcNS_9allocatorIcEEEENSI_ISK_EEEERKS5_T0_EUlS5_E_SG_EEDaOS5_SP_T1_EUlmE_ZNS_13block_delayed6filterIS7_ST_EEDaS5_SP_EUlS5_E_EEDaSO_SP_SS_" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS1_IlNS_9allocatorIlEEEENS2_IS4_EEEC1IRZNS_13block_delayed10filter_mapINS_16delayed_sequenceIlZNS_4iotaIlEEDaT_EUlmE_EEZNS_14map_tokens_oldIRKNS_8file_mapEZNS_6tokensISG_N7benchIO3$_0EEENS1_INS1_IcNS2_IcEEEENS2_ISN_EEEERKSC_T0_EUlSC_E_SL_EEDaOSC_SS_T1_EUlmE_ZNS8_6filterISE_SW_EEDaSC_SS_EUlSC_E_EEDaSC_SS_SV_EUlmE_EEmSU_NS6_18_from_function_tagEmEUlmE_EEvmmSC_mb" = weak global i64 -1
@__csi_func_id__ZNSo9_M_insertIdEERSoT_ = weak global i64 -1
@__csi_func_id__ZNSt6chrono3_V212system_clock3nowEv = weak global i64 -1
@__csi_func_id__ZSt19__throw_logic_errorPKc = weak global i64 -1
@__csi_func_id__ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal5timer6reportEdNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEE18initialize_defaultEmEUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_8sequenceImNS_9allocatorImEEEENS_5sliceIPmS9_EENS_4addmImEEEENT_10value_typeERKSD_T0_RKT1_jbEUlmmmE_EEvmmSG_jEUlmE_EEvmmSD_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_8sequenceImNS_9allocatorImEEEENS_5sliceIPmS9_EENS_4addmImEEEENT_10value_typeERKSD_T0_RKT1_jbEUlmmmE0_EEvmmSG_jEUlmE_EEvmmSD_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8internal5scan_INS_8sequenceImNS_9allocatorImEEEENS_5sliceIPmS7_EENS_4addmImEEEENT_10value_typeERKSB_T0_RKT1_jb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_14_sequence_baseImNS_9allocatorImEEE14_sequence_implC1ERKS5_EUlmE_EEvmmT_mb = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_13block_delayed10filter_mapINS_16delayed_sequenceIlZNS_4iotaIlEEDaT_EUlmE_EEZNS_14map_tokens_oldIRKNS_8file_mapEZNS_6tokensIS9_N7benchIO3$_0EEENS_8sequenceINSF_IcNS_9allocatorIcEEEENSG_ISI_EEEERKS5_T0_EUlS5_E_SE_EEDaOS5_SN_T1_EUlmE_ZNS1_6filterIS7_SR_EEDaS5_SN_EUlS5_E_EEDaS5_SN_SQ_EUlmE0_EEvmmS5_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPKcEEvT_S8_St26random_access_iterator_tagEUlmE_EEvmmS8_mb = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS_5sliceINS_16delayed_sequenceISt4pairIllEZNS_10map_tokensIRKNS_8file_mapEZNS_6tokensIS7_N7benchIO3$_0EEENS1_INS1_IcNS_9allocatorIcEEEENSD_ISF_EEEERKT_T0_EUlSI_E0_SC_EEDaOSI_SL_T1_EUlmE1_E8iteratorESR_EENSD_ISS_EEEC1IRZNS_13block_delayed14make_iteratorsISQ_EEDaSK_EUlmE_EEmSN_NSU_18_from_function_tagEmEUlmE_EEvmmSI_mb" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_8sequenceISt4pairIllENS_9allocatorIS6_EEEENS_5sliceIPS6_SB_EENS_6monoidIZNS_10map_tokensIRKNS_8file_mapEZNS_6tokensISF_N7benchIO3$_0EEENS4_INS4_IcNS7_IcEEEENS7_ISM_EEEERKT_T0_EUlSP_E0_SK_EEDaOSP_SS_T1_EUlS6_S6_E_S6_EEEENSP_10value_typeESR_SS_RKSV_jbEUlmmmE_EEvmmSR_jEUlmE_EEvmmSP_mb" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_8sequenceISt4pairIllENS_9allocatorIS6_EEEENS_5sliceIPS6_SB_EENS_6monoidIZNS_10map_tokensIRKNS_8file_mapEZNS_6tokensISF_N7benchIO3$_0EEENS4_INS4_IcNS7_IcEEEENS7_ISM_EEEERKT_T0_EUlSP_E0_SK_EEDaOSP_SS_T1_EUlS6_S6_E_S6_EEEENSP_10value_typeESR_SS_RKSV_jbEUlmmmE0_EEvmmSR_jEUlmE_EEvmmSP_mb" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS_14stream_delayed24forward_delayed_sequenceIZNS2_4scanISt4pairIllEZNS_10map_tokensIRKNS_8file_mapEZNS_6tokensIS8_N7benchIO3$_0EEENS1_INS1_IcNS_9allocatorIcEEEENSE_ISG_EEEERKT_T0_EUlSJ_E0_SD_EEDaOSJ_SM_T1_EUlS6_S6_E_NS_5sliceINS_16delayed_sequenceIS6_ZNS7_ISA_SN_SD_EEDaSO_SM_SP_EUlmE1_E8iteratorESV_EEEEDaSM_SL_RKSP_bE4iterEENSE_IS10_EEEC1IRZNS_13block_delayed5scan_ISU_NS_6monoidISQ_S6_EEEEDaSL_RKSM_bEUlmE_EEmSO_NS12_18_from_function_tagEmEUlmE_EEvmmSJ_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS_5sliceINS_16delayed_sequenceImZNS_4iotaImEEDaT_EUlmE_E8iteratorES8_EENS_9allocatorIS9_EEEC1IRZNS_13block_delayed14make_iteratorsIS7_EEDaRKS5_EUlmE_EEmOS5_NSC_18_from_function_tagEmEUlmE_EEvmmS5_mb = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS_14stream_delayed24forward_delayed_sequenceIZNS2_8zip_withINS3_IZNS2_4scanISt4pairIllEZNS_10map_tokensIRKNS_8file_mapEZNS_6tokensIS9_N7benchIO3$_0EEENS1_INS1_IcNS_9allocatorIcEEEENSF_ISH_EEEERKT_T0_EUlSK_E0_SE_EEDaOSK_SN_T1_EUlS7_S7_E_NS_5sliceINS_16delayed_sequenceIS7_ZNS8_ISB_SO_SE_EEDaSP_SN_SQ_EUlmE1_E8iteratorESW_EEEEDaSN_SM_RKSQ_bE4iterEENSS_INST_ImZNS_4iotaImEEDaSK_EUlmE_E8iteratorES15_EEZNS2_3zipIS11_S16_EEDaRSK_RSN_EUlSK_SN_E_EEDaS18_S19_SQ_E4iterEENSF_IS1C_EEEC1IRZNS_13block_delayed3zipINS1G_22block_delayed_sequenceIS11_EES14_EEDaSM_RKSN_EUlmE_EEmSP_NS1E_18_from_function_tagEmEUlmE_EEvmmSK_mb" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_13block_delayed5applyINS_14stream_delayed24forward_delayed_sequenceIZNS3_8zip_withINS4_IZNS3_4scanISt4pairIllEZNS_10map_tokensIRKNS_8file_mapEZNS_6tokensISA_N7benchIO3$_0EEENS_8sequenceINSG_IcNS_9allocatorIcEEEENSH_ISJ_EEEERKT_T0_EUlSM_E0_SF_EEDaOSM_SP_T1_EUlS8_S8_E_NS_5sliceINS_16delayed_sequenceIS8_ZNS9_ISC_SQ_SF_EEDaSR_SP_SS_EUlmE1_E8iteratorESY_EEEEDaSP_SO_RKSS_bE4iterEENSU_INSV_ImZNS_4iotaImEEDaSM_EUlmE_E8iteratorES17_EEZNS3_3zipIS13_S18_EEDaRSM_RSP_EUlSM_SP_E_EEDaS1A_S1B_SS_E4iterEEZNS9_ISC_SQ_SF_EEDaSR_SP_SS_EUlSM_E_EEvNS1_22block_delayed_sequenceISM_EESP_EUlmE_EEvmmSM_mb" = weak global i64 -1
@__csi_func_id_open = weak global i64 -1
@__csi_func_id___fxstat = weak global i64 -1
@__csi_func_id_mmap = weak global i64 -1
@__csi_func_id_close = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceINS_5sliceINS_16delayed_sequenceIlZNS_4iotaIlEEDaT_EUlmE_E8iteratorES7_EENS_9allocatorIS8_EEEC2IRZNS_13block_delayed14make_iteratorsIS6_EEDaRKS4_EUlmE_EEmOS4_NSB_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIlNS_9allocatorIlEEEENS2_IS4_EEE14_sequence_impl5clearEv = weak global i64 -1
@__csi_func_id__ZN6parlay8internal5timer4nextENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = weak global i64 -1
@__csi_func_id__ZN6parlay8internal4scanINS_8sequenceImNS_9allocatorImEEEENS_4addmImEEEESt4pairINS2_INT_10value_typeENS3_ISA_EEEESA_ERKS9_T0_j = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseImNS_9allocatorImEEE14_sequence_implC2ERKS4_ = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_14map_tokens_oldIRKNS_8file_mapEZNS_6tokensIS9_N7benchIO3$_0EEES6_RKT_T0_EUlSF_E_SE_EEDaOSF_SI_T1_EUlmE0_EEmSK_NS6_18_from_function_tagEmEUlmE_EEvmmSF_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEED2Ev = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceISt4pairIllENS_9allocatorIS2_EEEC2Em = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceINS_5sliceINS_16delayed_sequenceImZNS_4iotaImEEDaT_EUlmE_E8iteratorES7_EENS_9allocatorIS8_EEEC2IRZNS_13block_delayed14make_iteratorsIS6_EEDaRKS4_EUlmE_EEmOS4_NSB_18_from_function_tagEm = weak global i64 -1
@__csi_func_id_munmap = weak global i64 -1
@__csi_func_id__ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc = weak global i64 -1
@__csi_func_id__ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_ = weak global i64 -1
@__csi_func_id_strtod = weak global i64 -1
@__csi_func_id__ZSt24__throw_invalid_argumentPKc = weak global i64 -1
@__csi_func_id__ZSt20__throw_out_of_rangePKc = weak global i64 -1
@__csi_func_id_isspace = weak global i64 -1
@__csi_func_id__ZZN6parlay15chars_to_doubleERKNS_8sequenceIcNS_9allocatorIcEEEEENKUlRKT_E_clIS3_EEDaS8_ = weak global i64 -1
@__csi_func_id__ZN6parlay8internal16chars_to_float_tIdLm18ELl22ELl53EZNS_15chars_to_doubleERKNS_8sequenceIcNS_9allocatorIcEEEEEUlRKT_E_EES8_S7_T3_ = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC1ERKS5_EUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIlNS_9allocatorIlEEEC1IRZNS_7flattenINS1_INS1_IcNS2_IcEEEENS2_IS8_EEEEEEDaRKT_EUlmE_EEmOSB_NS4_18_from_function_tagEmEUlmE_EEvmmSB_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIlNS_9allocatorIlEEE18initialize_defaultEmEUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPlS5_EES6_NS_4addmImEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE_EEvmmSC_jEUlmE_EEvmmS9_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPlS5_EES6_NS_4addmImEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE0_EEvmmSC_jEUlmE_EEvmmS9_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZZNS_7flattenINS_8sequenceINS2_IcNS_9allocatorIcEEEENS3_IS5_EEEEEEDaRKT_ENKUlmE0_clEmEUlmE_EEvmmS8_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceIlNS_9allocatorIlEEEC2IRZNS_7flattenINS0_INS0_IcNS1_IcEEEENS1_IS7_EEEEEEDaRKT_EUlmE_EEmOSA_NS3_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal5scan_INS_5sliceIPlS3_EES4_NS_4addmImEEEENT_10value_typeERKS7_T0_RKT1_jb = weak global i64 -1
@__csi_func_id_snprintf = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_ = weak global i64 -1
@__csi_func_id__ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_ = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb" = weak global i64 -1
@__csi_func_id__ZNSt14basic_ofstreamIcSt11char_traitsIcEEC1ERKNSt7__cxx1112basic_stringIcS1_SaIcEEESt13_Ios_Openmode = weak global i64 -1
@__csi_func_id__ZNSo5writeEPKcl = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseISt4pairINS_8sequenceIcNS_9allocatorIcEEEEmENS3_IS6_EEE14_sequence_impl5clearEv = weak global i64 -1
@__csi_func_id__Z10wordCountsRKN6parlay8sequenceIcNS_9allocatorIcEEEEb = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseISt4pairINS_8sequenceIcNS_9allocatorIcEEEEmENS3_IS6_EEE14_sequence_implC2ERKS9_ = weak global i64 -1
@__csi_func_id__Z21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPc = weak global i64 -1
@__csi_func_id_bcmp = weak global i64 -1
@__csi_func_id__ZN11commandLine9getOptionENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = weak global i64 -1
@__csi_func_id_strtol = weak global i64 -1
@__csi_func_id__ZStlsIcSt11char_traitsIcESaIcEERSt13basic_ostreamIT_T0_ES7_RKNSt7__cxx1112basic_stringIS4_S5_T1_EE = weak global i64 -1
@__csi_func_id__ZN11commandLineC2EiPPcNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = weak global i64 -1
@__csi_func_id__ZN11commandLine14getOptionValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = weak global i64 -1
@__csi_func_id__ZN11commandLine17getOptionIntValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEi = weak global i64 -1
@__csi_func_id__Z14timeWordCountsRKN6parlay8sequenceIcNS_9allocatorIcEEEEibPc = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPcE3popEv = weak global i64 -1
@__csi_func_id__ZN6parlay15block_allocator5clearEv = weak global i64 -1
@__csi_func_id__ZN6parlay15block_allocatorD2Ev = weak global i64 -1
@__csi_func_id__ZN7benchIO11read_doubleERKN6parlay8sequenceIcNS0_9allocatorIcEEEE = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIiiE = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEED2Ev = weak global i64 -1
@__csi_func_id__ZN7benchIO9read_longERKN6parlay8sequenceIcNS0_9allocatorIcEEEE = weak global i64 -1
@__csi_func_id__ZN6parlay14pool_allocatorD2Ev = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeEi = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIllE = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeEN6parlay8sequenceIcNS0_9allocatorIcEEEE = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeEl = weak global i64 -1
@__csi_func_id__ZN7benchIO9seqHeaderB5cxx11ENS_11elementTypeE = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIddE = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeEPc = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeEj = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeEd = weak global i64 -1
@__csi_func_id_main = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIjjE = weak global i64 -1
@__csi_func_id__ZN7benchIO10get_tokensEPKc = weak global i64 -1
@__csi_func_id__ZN7benchIO18readStringFromFileEPKc = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIN6parlay8sequenceIcNS1_9allocatorIcEEEElE = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPcED2Ev = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIjiE = weak global i64 -1
@__csi_func_id__ZNSt6vectorImSaImEED2Ev = weak global i64 -1
@__csi_func_id__ZNSt10unique_ptrIA_N6parlay16concurrent_stackIPvEESt14default_deleteIS4_EED2Ev = weak global i64 -1

; Function Attrs: inlinehint uwtable
define fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb"(i64 %end, %class.anon.90* nocapture readonly byval(%class.anon.90) align 8 %f) unnamed_addr #0 personality i32 (...)* @__gxx_personality_v0 {
entry:
  %0 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 57
  %2 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %3 = add i64 %2, 57
  %4 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %5 = add i64 %4, 78
  %6 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %7 = add i64 %6, 78
  %8 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %9 = add i64 %8, 78
  %10 = call i8* @llvm.frameaddress.p0i8(i32 0)
  %11 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %9, i8* %10, i8* %11, i64 257)
  %12 = alloca i8, align 1
  call void @__csan_get_MAAP(i8* nonnull %12, i64 %9, i8 0)
  %13 = load i8, i8* %12, align 1
  %syncreg = tail call token @llvm.syncregion.start()
  %cmp1 = icmp eq i64 %end, 0
  br i1 %cmp1, label %sync.continue23, label %pfor.cond.preheader

pfor.cond.preheader:                              ; preds = %entry
  %14 = getelementptr inbounds %class.anon.90, %class.anon.90* %f, i64 0, i32 1
  %15 = getelementptr inbounds %class.anon.90, %class.anon.90* %f, i64 0, i32 2
  %16 = load i64, i64* @__csi_unit_loop_base_id, align 8, !invariant.load !2
  %17 = add i64 %16, 32
  call void @__csan_before_loop(i64 %17, i64 -1, i64 1)
  br label %pfor.cond

pfor.cond:                                        ; preds = %pfor.inc, %pfor.cond.preheader
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %pfor.cond.preheader ]
  call void @__csan_detach(i64 %1, i8 0)
  detach within %syncreg, label %pfor.body.tf.tf, label %pfor.inc

pfor.body.tf.tf:                                  ; preds = %pfor.cond
  %18 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %19 = add i64 %18, 61
  %20 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %21 = add i64 %20, 61
  %22 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %23 = add i64 %22, 83
  %24 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %25 = add i64 %24, 83
  %26 = add i64 %24, 80
  %27 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %28 = add i64 %27, 60
  %29 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %30 = add i64 %29, 60
  %31 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %32 = add i64 %31, 82
  %33 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %34 = add i64 %33, 82
  %35 = add i64 %33, 80
  %36 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %37 = add i64 %36, 59
  %38 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %39 = add i64 %38, 59
  %40 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %41 = add i64 %40, 81
  %42 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %43 = add i64 %42, 81
  %44 = add i64 %42, 80
  %45 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %46 = add i64 %45, 58
  %47 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %48 = add i64 %47, 58
  %49 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %50 = add i64 %49, 79
  %51 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %52 = add i64 %51, 79
  %53 = add i64 %51, 80
  %54 = call i8* @llvm.task.frameaddress(i32 0)
  %55 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %3, i64 %1, i8* %54, i8* %55, i64 3)
  %56 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %57 = add i64 %56, 185
  %alloc.i.i42.i.i.i = alloca %"struct.parlay::allocator.35", align 1
  %58 = getelementptr inbounds %"struct.parlay::allocator.35", %"struct.parlay::allocator.35"* %alloc.i.i42.i.i.i, i64 0, i32 0
  call void @__csi_after_alloca(i64 %57, i8* nonnull %58, i64 1, i64 0)
  %59 = add i64 %56, 192
  %first.addr.i.i.i.i = alloca i8*, align 8
  %60 = bitcast i8** %first.addr.i.i.i.i to i8*
  call void @__csi_after_alloca(i64 %59, i8* nonnull %60, i64 8, i64 0)
  %61 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %62 = add i64 %61, 189
  %buffer.i.i.i.i = alloca i8*, align 8
  %63 = bitcast i8** %buffer.i.i.i.i to i8*
  call void @__csi_after_alloca(i64 %62, i8* nonnull %63, i64 8, i64 0)
  %64 = add i64 %61, 191
  %agg.tmp.i.i.i.i = alloca %class.anon.92, align 8
  %65 = bitcast %class.anon.92* %agg.tmp.i.i.i.i to i8*
  call void @__csi_after_alloca(i64 %64, i8* nonnull %65, i64 24, i64 0)
  %66 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %67 = add i64 %66, 190
  %alloc.i.i.i.i.i = alloca %"struct.parlay::allocator.35", align 1
  %68 = getelementptr inbounds %"struct.parlay::allocator.35", %"struct.parlay::allocator.35"* %alloc.i.i.i.i.i, i64 0, i32 0
  call void @__csi_after_alloca(i64 %67, i8* nonnull %68, i64 1, i64 0)
  %69 = add i64 %66, 186
  %s.i.i.i.i = alloca [22 x i8], align 16
  %70 = getelementptr inbounds [22 x i8], [22 x i8]* %s.i.i.i.i, i64 0, i64 0
  call void @__csi_after_alloca(i64 %69, i8* nonnull %70, i64 22, i64 0)
  %71 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %72 = add i64 %71, 188
  %s.i.i.i = alloca %"class.parlay::sequence.2", align 8
  %73 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  call void @__csi_after_alloca(i64 %72, i8* nonnull %73, i64 15, i64 0)
  %74 = add i64 %71, 187
  %ref.tmp.i.i.i = alloca [4 x %"class.parlay::sequence"], align 8
  %75 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  call void @__csi_after_alloca(i64 %74, i8* nonnull %75, i64 60, i64 0)
  %76 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %77 = add i64 %76, 184
  %agg.tmp.i.i = alloca %"struct.std::pair.87", align 8
  %78 = bitcast %"struct.std::pair.87"* %agg.tmp.i.i to i8*
  call void @__csi_after_alloca(i64 %77, i8* nonnull %78, i64 24, i64 0)
  %79 = add i64 %76, 183
  %ref.tmp.i = alloca %"class.parlay::sequence", align 8
  %80 = bitcast %"class.parlay::sequence"* %ref.tmp.i to i8*
  call void @__csi_after_alloca(i64 %79, i8* nonnull %80, i64 15, i64 0)
  %81 = and i8 %13, 1
  %82 = icmp eq i8 %81, 0
  br i1 %82, label %87, label %83

83:                                               ; preds = %pfor.body.tf.tf
  %84 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %85 = add i64 %84, 1022
  %86 = bitcast %"class.parlay::sequence"*** %14 to i8*
  call void @__csan_load(i64 %85, i8* nonnull %86, i32 8, i64 8)
  br label %87

87:                                               ; preds = %83, %pfor.body.tf.tf
  %88 = load %"class.parlay::sequence"**, %"class.parlay::sequence"*** %14, align 8, !tbaa !3
  %89 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %90 = add i64 %89, 1004
  %91 = bitcast %"class.parlay::sequence"** %88 to i8*
  call void @__csan_load(i64 %90, i8* %91, i32 8, i64 8)
  %92 = load %"class.parlay::sequence"*, %"class.parlay::sequence"** %88, align 8, !tbaa !8
  %arrayidx.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %92, i64 %__begin.0
  %93 = bitcast %"class.parlay::sequence"* %ref.tmp.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %93) #10
  %94 = and i8 %13, 1
  %95 = icmp eq i8 %94, 0
  br i1 %95, label %pfor.body.tf.tf.tf, label %96

96:                                               ; preds = %87
  %97 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %98 = add i64 %97, 1023
  %99 = bitcast %class.anon.86** %15 to i8*
  call void @__csan_load(i64 %98, i8* nonnull %99, i32 8, i64 8)
  br label %pfor.body.tf.tf.tf

pfor.body.tf.tf.tf:                               ; preds = %96, %87
  %100 = load %class.anon.86*, %class.anon.86** %15, align 8, !tbaa !9
  %101 = bitcast %"struct.std::pair.87"* %agg.tmp.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %101)
  %102 = getelementptr inbounds %class.anon.86, %class.anon.86* %100, i64 0, i32 0
  %103 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %104 = add i64 %103, 1005
  %105 = bitcast %class.anon.86* %100 to i8*
  call void @__csan_load(i64 %104, i8* %105, i32 8, i64 8)
  %106 = load %class.anon.27*, %class.anon.27** %102, align 8, !tbaa !10, !noalias !12
  %107 = getelementptr inbounds %class.anon.86, %class.anon.86* %100, i64 0, i32 1
  %108 = add i64 %103, 1006
  %109 = bitcast %"struct.std::pair.87"** %107 to i8*
  call void @__csan_load(i64 %108, i8* nonnull %109, i32 8, i64 8)
  %110 = load %"struct.std::pair.87"*, %"struct.std::pair.87"** %107, align 8, !tbaa !15, !noalias !12
  %impl.i.i.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0
  %second.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 1
  %second3.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %110, i64 %__begin.0, i32 1
  %111 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %112 = add i64 %111, 1007
  %113 = bitcast i64* %second3.i.i.i to i8*
  call void @__csan_load(i64 %112, i8* nonnull %113, i32 8, i64 8)
  %114 = load i64, i64* %second3.i.i.i, align 8, !tbaa !16, !noalias !12
  store i64 %114, i64* %second.i.i.i, align 8, !tbaa !16, !noalias !12
  %115 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %115) #10, !noalias !20
  %116 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 60, i8* nonnull %116) #10, !noalias !20
  %impl.i.i.i2.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0
  %impl.i.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %110, i64 %__begin.0, i32 0, i32 0, i32 0
  %tf.i = call token @llvm.taskframe.create()
  %syncreg19.i.i.i.i.i = call token @llvm.syncregion.start(), !noalias !20
  %117 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %117)
  call void @__csan_set_MAAP(i8 3, i64 %117)
  %118 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %119 = add i64 %118, 395
  call void @__csan_before_call(i64 %119, i64 %117, i8 2, i64 0)
  call void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i), !noalias !12
  call void @__csan_after_call(i64 %119, i64 %117, i8 2, i64 0)
  %120 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 7, i64 %120)
  call void @__csan_set_MAAP(i8 7, i64 %120)
  %121 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %122 = add i64 %121, 396
  call void @__csan_before_call(i64 %122, i64 %120, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i2.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i)
          to label %invoke.cont.i.i.i unwind label %lpad.body.i.i.i, !noalias !20

invoke.cont.i.i.i:                                ; preds = %pfor.body.tf.tf.tf
  call void @__csan_after_call(i64 %122, i64 %120, i8 2, i64 0)
  %123 = getelementptr inbounds %class.anon.27, %class.anon.27* %106, i64 0, i32 0
  %124 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %125 = add i64 %124, 1008
  %126 = bitcast %class.anon.27* %106 to i8*
  call void @__csan_load(i64 %125, i8* %126, i32 8, i64 8)
  %127 = load %"class.parlay::sequence"*, %"class.parlay::sequence"** %123, align 8, !tbaa !23, !noalias !20
  %impl.i1.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %127, i64 0, i32 0, i32 0
  %impl.i.i2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0
  %128 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %128)
  call void @__csan_set_MAAP(i8 3, i64 %128)
  %129 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %130 = add i64 %129, 397
  call void @__csan_before_call(i64 %130, i64 %128, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i2.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i1.i.i.i)
          to label %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i.i.i.i unwind label %lpad.body.thread84.i.i.i, !noalias !20

_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i.i.i.i: ; preds = %invoke.cont.i.i.i
  call void @__csan_after_call(i64 %130, i64 %128, i8 2, i64 0)
  %arrayinit.element3.ptr.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2
  %131 = load i64, i64* %second.i.i.i, align 8, !tbaa !16, !noalias !20
  %132 = getelementptr inbounds [22 x i8], [22 x i8]* %s.i.i.i.i, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 22, i8* nonnull %132) #10, !noalias !25
  %133 = load i64, i64* @__csi_func_id_snprintf, align 8
  call void @__csan_set_MAAP(i8 4, i64 %133)
  call void @__csan_set_MAAP(i8 7, i64 %133)
  %134 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %135 = add i64 %134, 394
  %call.i.i.i.i = call i32 (i8*, i64, i8*, ...) @snprintf(i8* nonnull %132, i64 21, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.18, i64 0, i64 0), i64 %131) #10, !noalias !25
  call void (i64, i64, i8, i64, i32, i8*, i64, i8*, ...) @__csan_snprintf(i64 %135, i64 %133, i8 2, i64 0, i32 %call.i.i.i.i, i8* nonnull %132, i64 21, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.18, i64 0, i64 0), i64 %131)
  %cmp.i.i.i.i.i = icmp slt i32 %call.i.i.i.i, 20
  %.sroa.speculated.i.i.i.i = select i1 %cmp.i.i.i.i.i, i32 %call.i.i.i.i, i32 20
  %idx.ext.i.i.i.i = sext i32 %.sroa.speculated.i.i.i.i to i64
  %small_n.i.i.i.i.i.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 1
  %136 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %137 = add i64 %136, 566
  call void @__csan_store(i64 %137, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  store i8 0, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !alias.scope !28, !noalias !20
  %138 = bitcast i8** %first.addr.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %138), !noalias !20
  %139 = bitcast %class.anon.92* %agg.tmp.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %139), !noalias !20
  %140 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %141 = add i64 %140, 567
  %142 = bitcast i8** %first.addr.i.i.i.i to i8*
  call void @__csan_store(i64 %141, i8* nonnull %142, i32 8, i64 8)
  store i8* %132, i8** %first.addr.i.i.i.i, align 8, !tbaa !8, !noalias !20
  %cmp.i.i52.i.i.i = icmp ugt i32 %.sroa.speculated.i.i.i.i, 13
  br i1 %cmp.i.i52.i.i.i, label %if.then.i6.i58.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread.i.i.i: ; preds = %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i.i.i.i
  %143 = bitcast i8** %buffer.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %143) #10, !noalias !20
  br label %if.then.i10.i61.i.i.i

if.then.i6.i58.i.i.i:                             ; preds = %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i.i.i.i
  %144 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %145 = add i64 %144, 568
  call void @__csan_store(i64 %145, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  store i8 -128, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !20
  %146 = getelementptr inbounds %"struct.parlay::allocator.35", %"struct.parlay::allocator.35"* %alloc.i.i42.i.i.i, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %146) #10, !noalias !20
  %add.i.i.i.i.i.i.i = add nsw i64 %idx.ext.i.i.i.i, 8
  %147 = load i64, i64* @__csi_func_id__ZN6parlay9allocatorISt4byteE8allocateEm, align 8
  call void @__csan_set_MAAP(i8 7, i64 %147)
  %148 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %149 = add i64 %148, 398
  call void @__csan_before_call(i64 %149, i64 %147, i8 1, i64 0)
  %call.i.i.i.i.i73.i.i.i = invoke i8* @_ZN6parlay9allocatorISt4byteE8allocateEm(%"struct.parlay::allocator.35"* nonnull %alloc.i.i42.i.i.i, i64 %add.i.i.i.i.i.i.i)
          to label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i unwind label %lpad.i.i.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i: ; preds = %if.then.i6.i58.i.i.i
  call void @__csan_after_call(i64 %149, i64 %147, i8 1, i64 0)
  %capacity.i.i.i3.i.i54.i.i.i = bitcast i8* %call.i.i.i.i.i73.i.i.i to i64*
  %150 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %151 = add i64 %150, 562
  call void @__csan_store(i64 %151, i8* %call.i.i.i.i.i73.i.i.i, i32 8, i64 8)
  store i64 %idx.ext.i.i.i.i, i64* %capacity.i.i.i3.i.i54.i.i.i, align 8, !tbaa !29
  %152 = bitcast %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i to i8**
  %153 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %154 = add i64 %153, 569
  %155 = bitcast %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i to i8*
  call void @__csan_store(i64 %154, i8* nonnull %155, i32 8, i64 2)
  store i8* %call.i.i.i.i.i73.i.i.i, i8** %152, align 2, !tbaa.struct !31, !noalias !20
  %ref.tmp.sroa.4.0..sroa_idx5.i.i55.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast6.i.i56.i.i.i = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i55.i.i.i to i48*
  %156 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %157 = add i64 %156, 570
  %158 = getelementptr [6 x i8], [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i55.i.i.i, i64 0, i64 0
  call void @__csan_store(i64 %157, i8* %158, i32 6, i64 2)
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i56.i.i.i, align 2, !tbaa.struct !31, !noalias !20
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %146) #10, !noalias !20
  %159 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %160 = add i64 %159, 1024
  call void @__csan_load(i64 %160, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  %bf.load.i.i8.pre.i57.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !20
  %161 = bitcast i8** %buffer.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %161) #10, !noalias !20
  %cmp.i.i9.i60.i.i.i = icmp sgt i8 %bf.load.i.i8.pre.i57.i.i.i, -1
  br i1 %cmp.i.i9.i60.i.i.i, label %if.then.i10.i61.i.i.i, label %if.else.i11.i63.i.i.i

if.then.i10.i61.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread.i.i.i
  %162 = phi i8* [ %143, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread.i.i.i ], [ %161, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i ]
  %163 = bitcast %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i to i8*
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i

if.else.i11.i63.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i
  %164 = getelementptr inbounds i8, i8* %call.i.i.i.i.i73.i.i.i, i64 8
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i: ; preds = %if.else.i11.i63.i.i.i, %if.then.i10.i61.i.i.i
  %165 = phi i8* [ %162, %if.then.i10.i61.i.i.i ], [ %161, %if.else.i11.i63.i.i.i ]
  %retval.0.i.i64.i.i.i = phi i8* [ %163, %if.then.i10.i61.i.i.i ], [ %164, %if.else.i11.i63.i.i.i ]
  %166 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %167 = add i64 %166, 571
  %168 = bitcast i8** %buffer.i.i.i.i to i8*
  call void @__csan_store(i64 %167, i8* nonnull %168, i32 8, i64 8)
  store i8* %retval.0.i.i64.i.i.i, i8** %buffer.i.i.i.i, align 8, !tbaa !8, !noalias !20
  %169 = getelementptr inbounds %class.anon.92, %class.anon.92* %agg.tmp.i.i.i.i, i64 0, i32 0
  store %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i, %"class.parlay::sequence"** %169, align 8, !tbaa !33, !noalias !20
  %170 = getelementptr inbounds %class.anon.92, %class.anon.92* %agg.tmp.i.i.i.i, i64 0, i32 1
  store i8** %buffer.i.i.i.i, i8*** %170, align 8, !tbaa !8, !noalias !20
  %171 = getelementptr inbounds %class.anon.92, %class.anon.92* %agg.tmp.i.i.i.i, i64 0, i32 2
  store i8** %first.addr.i.i.i.i, i8*** %171, align 8, !tbaa !8, !noalias !20
  %172 = load i64, i64* @__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb, align 8
  call void @__csan_set_MAAP(i8 7, i64 %172)
  %173 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %174 = add i64 %173, 399
  call void @__csan_before_call(i64 %174, i64 %172, i8 1, i64 0)
  invoke void @_ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb(i64 0, i64 %idx.ext.i.i.i.i, %class.anon.92* nonnull byval(%class.anon.92) align 8 %agg.tmp.i.i.i.i, i64 8193, i1 zeroext false)
          to label %.noexc74.i.i.i unwind label %lpad.i.i.i.i.i, !noalias !20

.noexc74.i.i.i:                                   ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i
  call void @__csan_after_call(i64 %174, i64 %172, i8 1, i64 0)
  %175 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %176 = add i64 %175, 1025
  call void @__csan_load(i64 %176, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  %bf.load.i.i.i65.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !20
  %cmp.i.i.i66.i.i.i = icmp sgt i8 %bf.load.i.i.i65.i.i.i, -1
  br i1 %cmp.i.i.i66.i.i.i, label %if.then.i.i69.i.i.i, label %if.else.i.i71.i.i.i

if.then.i.i69.i.i.i:                              ; preds = %.noexc74.i.i.i
  %conv.i.i.i.i.i = trunc i32 %.sroa.speculated.i.i.i.i to i8
  %bf.value.i.i.i.i.i = and i8 %conv.i.i.i.i.i, 127
  %bf.clear.i.i67.i.i.i = and i8 %bf.load.i.i.i65.i.i.i, -128
  %bf.set.i.i68.i.i.i = or i8 %bf.clear.i.i67.i.i.i, %bf.value.i.i.i.i.i
  %177 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %178 = add i64 %177, 572
  call void @__csan_store(i64 %178, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  store i8 %bf.set.i.i68.i.i.i, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !20
  br label %invoke.cont4.i.i.i

if.else.i.i71.i.i.i:                              ; preds = %.noexc74.i.i.i
  %n.i.i.i70.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %179 = bitcast [6 x i8]* %n.i.i.i70.i.i.i to i48*
  %180 = sext i32 %.sroa.speculated.i.i.i.i to i48
  %181 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %182 = add i64 %181, 573
  %183 = getelementptr [6 x i8], [6 x i8]* %n.i.i.i70.i.i.i, i64 0, i64 0
  call void @__csan_store(i64 %182, i8* %183, i32 6, i64 2)
  store i48 %180, i48* %179, align 2, !noalias !20
  br label %invoke.cont4.i.i.i

lpad.i.i.i.i.i:                                   ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i, %if.then.i6.i58.i.i.i
  %184 = phi i64 [ %174, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i ], [ %149, %if.then.i6.i58.i.i.i ]
  %185 = phi i64 [ %172, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i.i.i.i ], [ %147, %if.then.i6.i58.i.i.i ]
  %186 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %184, i64 %185, i8 1, i64 0)
  %arrayinit.begin.i.i.i.le = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0
  %187 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %188 = add i64 %187, 1026
  call void @__csan_load(i64 %188, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  %bf.load.i.i.i.i.i.i.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !alias.scope !28, !noalias !20
  %cmp.i.i.i.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i.i.i.i, label %lpad.body.thread.i.i.i, label %if.then.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i:                          ; preds = %lpad.i.i.i.i.i
  %buffer.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %189 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %190 = add i64 %189, 1027
  %191 = bitcast %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i to i8*
  call void @__csan_load(i64 %190, i8* nonnull %191, i32 8, i64 2)
  %192 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i.i.i, align 2, !tbaa !35, !alias.scope !28, !noalias !20
  %capacity.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %192, i64 0, i32 0
  %193 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %194 = add i64 %193, 1009
  %195 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %192 to i8*
  call void @__csan_load(i64 %194, i8* %195, i32 8, i64 8)
  %196 = load i64, i64* %capacity.i.i.i.i.i.i.i.i.i.i, align 8, !tbaa !29
  %197 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %198 = add i64 %197, 400
  %199 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %198, i64 %199, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i.i.i.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i unwind label %lpad.i.i.i.i.i.i.i

call.i.i.i.i.i.noexc.i.i.i.i.i.i.i:               ; preds = %if.then.i.i.i.i.i.i.i.i
  call void @__csan_after_call(i64 %198, i64 %199, i8 0, i64 0)
  %200 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %192 to i8*
  %add.i.i.i.i.i.i.i.i.i.i = add i64 %196, 8
  %201 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %201)
  call void @__csan_set_MAAP(i8 3, i64 %201)
  %202 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %203 = add i64 %202, 401
  call void @__csan_before_call(i64 %203, i64 %201, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.i.i.i.i.i, i8* %200, i64 %add.i.i.i.i.i.i.i.i.i.i)
          to label %.noexc.i.i.i.i.i.i.i unwind label %lpad.i.i.i.i.i.i.i

.noexc.i.i.i.i.i.i.i:                             ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i
  call void @__csan_after_call(i64 %203, i64 %201, i8 2, i64 0)
  %204 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %205 = add i64 %204, 574
  %206 = bitcast %"class.parlay::sequence"* %arrayinit.element3.ptr.i.i.i to i8*
  call void @__csan_store(i64 %205, i8* nonnull %206, i32 8, i64 2)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i.i.i, align 2, !tbaa !35, !alias.scope !28, !noalias !20
  br label %lpad.body.thread.i.i.i

lpad.i.i.i.i.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i, %if.then.i.i.i.i.i.i.i.i
  %207 = phi i64 [ %203, %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i ], [ %198, %if.then.i.i.i.i.i.i.i.i ]
  %208 = phi i64 [ %201, %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i ], [ %199, %if.then.i.i.i.i.i.i.i.i ]
  %209 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i.i.i.i.i.i ], [ 0, %if.then.i.i.i.i.i.i.i.i ]
  %210 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %207, i64 %208, i8 %209, i64 0)
  %211 = extractvalue { i8*, i32 } %210, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %211) #11
  unreachable

lpad.body.thread.i.i.i:                           ; preds = %.noexc.i.i.i.i.i.i.i, %lpad.i.i.i.i.i
  %212 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %213 = add i64 %212, 575
  call void @__csan_store(i64 %213, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  store i8 0, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !alias.scope !28, !noalias !20
  br label %arraydestroy.body.preheader.i.i.i

invoke.cont4.i.i.i:                               ; preds = %if.else.i.i71.i.i.i, %if.then.i.i69.i.i.i
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %165) #10, !noalias !20
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %138), !noalias !20
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %139), !noalias !20
  call void @llvm.lifetime.end.p0i8(i64 22, i8* nonnull %132) #10, !noalias !25
  %214 = getelementptr inbounds %class.anon.27, %class.anon.27* %106, i64 0, i32 1
  %215 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %216 = add i64 %215, 1010
  %217 = bitcast %"class.parlay::sequence"** %214 to i8*
  call void @__csan_load(i64 %216, i8* nonnull %217, i32 8, i64 8)
  %218 = load %"class.parlay::sequence"*, %"class.parlay::sequence"** %214, align 8, !tbaa !37, !noalias !20
  %impl.i4.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %218, i64 0, i32 0, i32 0
  %impl.i.i5.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0
  %219 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %219)
  call void @__csan_set_MAAP(i8 3, i64 %219)
  %220 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %221 = add i64 %220, 402
  call void @__csan_before_call(i64 %221, i64 %219, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i5.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i4.i.i.i)
          to label %if.then.i6.i.i.i.i unwind label %lpad.body.thread84.i.i.i, !noalias !20

if.then.i6.i.i.i.i:                               ; preds = %invoke.cont4.i.i.i
  call void @__csan_after_call(i64 %221, i64 %219, i8 2, i64 0)
  %small_n.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 1
  %222 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %223 = add i64 %222, 576
  call void @__csan_store(i64 %223, i8* nonnull %small_n.i.i.i.i.i.i.i, i32 1, i64 2)
  store i8 -128, i8* %small_n.i.i.i.i.i.i.i, align 2, !noalias !20
  %224 = getelementptr inbounds %"struct.parlay::allocator.35", %"struct.parlay::allocator.35"* %alloc.i.i.i.i.i, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %224) #10, !noalias !20
  %225 = load i64, i64* @__csi_func_id__ZN6parlay9allocatorISt4byteE8allocateEm, align 8
  call void @__csan_set_MAAP(i8 7, i64 %225)
  %226 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %227 = add i64 %226, 403
  call void @__csan_before_call(i64 %227, i64 %225, i8 1, i64 0)
  %call.i.i.i.i.i11.i.i.i = invoke i8* @_ZN6parlay9allocatorISt4byteE8allocateEm(%"struct.parlay::allocator.35"* nonnull %alloc.i.i.i.i.i, i64 68)
          to label %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split-lp, !noalias !20

_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i: ; preds = %if.then.i6.i.i.i.i
  call void @__csan_after_call(i64 %227, i64 %225, i8 1, i64 0)
  %capacity.i.i.i3.i.i.i.i.i = bitcast i8* %call.i.i.i.i.i11.i.i.i to i64*
  %228 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %229 = add i64 %228, 563
  call void @__csan_store(i64 %229, i8* %call.i.i.i.i.i11.i.i.i, i32 8, i64 8)
  store i64 4, i64* %capacity.i.i.i3.i.i.i.i.i, align 8, !tbaa !38, !noalias !20
  %230 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8**
  %231 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %232 = add i64 %231, 577
  %233 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  call void @__csan_store(i64 %232, i8* nonnull %233, i32 8, i64 8)
  store i8* %call.i.i.i.i.i11.i.i.i, i8** %230, align 8, !tbaa.struct !31, !noalias !20
  %ref.tmp.sroa.4.0..sroa_idx5.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i.i = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i.i.i.i to i48*
  %234 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %235 = add i64 %234, 578
  %236 = getelementptr [6 x i8], [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i.i.i.i, i64 0, i64 0
  call void @__csan_store(i64 %235, i8* %236, i32 6, i64 8)
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i.i, align 8, !tbaa.struct !31, !noalias !20
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %224) #10, !noalias !20
  %237 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %238 = add i64 %237, 1028
  call void @__csan_load(i64 %238, i8* nonnull %small_n.i.i.i.i.i.i.i, i32 1, i64 2)
  %bf.load.i.i8.pre.i.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i, align 2, !noalias !20
  %cmp.i.i9.i.i.i.i = icmp sgt i8 %bf.load.i.i8.pre.i.i.i.i, -1
  %239 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to %"class.parlay::sequence"*
  %data.i.i.i.i.i.i.i.i = getelementptr inbounds i8, i8* %call.i.i.i.i.i11.i.i.i, i64 8
  %240 = bitcast i8* %data.i.i.i.i.i.i.i.i to %"class.parlay::sequence"*
  %retval.0.i.i.i.i.i = select i1 %cmp.i.i9.i.i.i.i, %"class.parlay::sequence"* %239, %"class.parlay::sequence"* %240
  call void @__csan_detach(i64 %46, i8 0)
  detach within %syncreg19.i.i.i.i.i, label %pfor.body.i.i.i.i.i, label %pfor.inc.i.i.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split

pfor.body.i.i.i.i.i:                              ; preds = %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i
  %241 = call i8* @llvm.task.frameaddress(i32 0)
  %242 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %48, i64 %46, i8* %241, i8* %242, i64 0)
  %impl.i.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i.i.i.i, i64 0, i32 0, i32 0
  %243 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %243)
  call void @__csan_set_MAAP(i8 3, i64 %243)
  %244 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %245 = add i64 %244, 404
  call void @__csan_before_call(i64 %245, i64 %243, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i2.i.i)
          to label %.noexc.i.i.i unwind label %lpad.i9.i.i.i

.noexc.i.i.i:                                     ; preds = %pfor.body.i.i.i.i.i
  call void @__csan_after_call(i64 %245, i64 %243, i8 2, i64 0)
  call void @__csan_task_exit(i64 %50, i64 %48, i64 %46, i8 0, i64 0)
  reattach within %syncreg19.i.i.i.i.i, label %pfor.inc.i.i.i.i.i

pfor.inc.i.i.i.i.i:                               ; preds = %.noexc.i.i.i, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i
  call void @__csan_detach_continue(i64 %52, i64 %46)
  call void @__csan_detach(i64 %37, i8 0)
  detach within %syncreg19.i.i.i.i.i, label %pfor.body.i.i.1.i.i.i, label %pfor.inc.i.i.1.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split

sync.continue.i.i.i.i.i:                          ; preds = %pfor.inc.i.i.3.i.i.i
  invoke void @llvm.sync.unwind(token %syncreg19.i.i.i.i.i)
          to label %.noexc10.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i.csi-split-lp, !noalias !20

.noexc10.i.i.i:                                   ; preds = %sync.continue.i.i.i.i.i
  %246 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %247 = add i64 %246, 1029
  call void @__csan_load(i64 %247, i8* nonnull %small_n.i.i.i.i.i.i.i, i32 1, i64 2)
  %bf.load.i.i.i.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i, align 2, !noalias !20
  %cmp.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i, label %if.then.i.i.i.i.i, label %if.else.i.i.i.i.i

if.then.i.i.i.i.i:                                ; preds = %.noexc10.i.i.i
  %bf.clear.i.i.i.i.i = and i8 %bf.load.i.i.i.i.i.i, -128
  %bf.set.i.i.i.i.i = or i8 %bf.clear.i.i.i.i.i, 4
  %248 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %249 = add i64 %248, 579
  call void @__csan_store(i64 %249, i8* nonnull %small_n.i.i.i.i.i.i.i, i32 1, i64 2)
  store i8 %bf.set.i.i.i.i.i, i8* %small_n.i.i.i.i.i.i.i, align 2, !noalias !20
  br label %invoke.cont9.i.i.i

if.else.i.i.i.i.i:                                ; preds = %.noexc10.i.i.i
  %250 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %251 = add i64 %250, 580
  %252 = getelementptr [6 x i8], [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i.i.i.i, i64 0, i64 0
  call void @__csan_store(i64 %251, i8* %252, i32 6, i64 8)
  store i48 4, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i.i, align 8, !noalias !20
  br label %invoke.cont9.i.i.i

lpad.i.unreachable.i.i.i:                         ; preds = %lpad.i9.i.i.i
  unreachable

lpad.i9.i.i.i:                                    ; preds = %pfor.body.i.i.3.i.i.i, %pfor.body.i.i.2.i.i.i, %pfor.body.i.i.1.i.i.i, %pfor.body.i.i.i.i.i
  %253 = phi i64 [ %21, %pfor.body.i.i.3.i.i.i ], [ %30, %pfor.body.i.i.2.i.i.i ], [ %39, %pfor.body.i.i.1.i.i.i ], [ %48, %pfor.body.i.i.i.i.i ]
  %254 = phi i64 [ %19, %pfor.body.i.i.3.i.i.i ], [ %28, %pfor.body.i.i.2.i.i.i ], [ %37, %pfor.body.i.i.1.i.i.i ], [ %46, %pfor.body.i.i.i.i.i ]
  %255 = phi i64 [ %511, %pfor.body.i.i.3.i.i.i ], [ %506, %pfor.body.i.i.2.i.i.i ], [ %501, %pfor.body.i.i.1.i.i.i ], [ %245, %pfor.body.i.i.i.i.i ]
  %256 = phi i64 [ %509, %pfor.body.i.i.3.i.i.i ], [ %504, %pfor.body.i.i.2.i.i.i ], [ %499, %pfor.body.i.i.1.i.i.i ], [ %243, %pfor.body.i.i.i.i.i ]
  %257 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %255, i64 %256, i8 2, i64 0)
  %258 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %259 = add i64 %258, 80
  call void @__csan_task_exit(i64 %259, i64 %253, i64 %254, i8 0, i64 0)
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg19.i.i.i.i.i, { i8*, i32 } %257)
          to label %lpad.i.unreachable.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split, !noalias !20

lpad.i.loopexit.split-lp.i.i.i.csi-split-lp:      ; preds = %sync.continue.i.i.i.i.i
  %lpad.csi-split-lp = landingpad { i8*, i32 }
          cleanup
  br label %lpad.i.loopexit.split-lp.i.i.i

lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split-lp: ; preds = %if.then.i6.i.i.i.i
  %lpad.csi-split-lp5 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %227, i64 %225, i8 1, i64 0)
  br label %lpad.i.loopexit.split-lp.i.i.i

lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split: ; preds = %pfor.inc.i.i.2.i.i.i, %pfor.inc.i.i.1.i.i.i, %lpad.i9.i.i.i, %pfor.inc.i.i.i.i.i, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i
  %260 = phi i64 [ %26, %pfor.inc.i.i.2.i.i.i ], [ %35, %pfor.inc.i.i.1.i.i.i ], [ %26, %lpad.i9.i.i.i ], [ %44, %pfor.inc.i.i.i.i.i ], [ %53, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i ]
  %261 = phi i64 [ %19, %pfor.inc.i.i.2.i.i.i ], [ %28, %pfor.inc.i.i.1.i.i.i ], [ %19, %lpad.i9.i.i.i ], [ %37, %pfor.inc.i.i.i.i.i ], [ %46, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i ]
  %lpad.csi-split6 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_detach_continue(i64 %260, i64 %261)
  br label %lpad.i.loopexit.split-lp.i.i.i

lpad.i.loopexit.split-lp.i.i.i:                   ; preds = %lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split, %lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split-lp, %lpad.i.loopexit.split-lp.i.i.i.csi-split-lp
  %262 = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0
  %263 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEED2Ev, align 8
  call void @__csan_set_MAAP(i8 7, i64 %263)
  %264 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %265 = add i64 %264, 405
  call void @__csan_before_call(i64 %265, i64 %263, i8 1, i64 0)
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEED2Ev(%"struct.parlay::_sequence_base.3"* nonnull %262) #10
  call void @__csan_after_call(i64 %265, i64 %263, i8 1, i64 0)
  %flag.i.i.i.i30.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0, i32 0, i32 1
  %266 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %267 = add i64 %266, 1030
  call void @__csan_load(i64 %267, i8* nonnull %flag.i.i.i.i30.i.i.i, i32 1, i64 1)
  %bf.load.i.i.i.i31.i.i.i = load i8, i8* %flag.i.i.i.i30.i.i.i, align 1, !noalias !20
  %cmp.i.i.i.i32.i.i.i = icmp sgt i8 %bf.load.i.i.i.i31.i.i.i, -1
  br i1 %cmp.i.i.i.i32.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.i.i.i, label %if.then.i.i.i36.i.i.i

invoke.cont9.i.i.i:                               ; preds = %if.else.i.i.i.i.i, %if.then.i.i.i.i.i
  %flag.i.i.i.i12.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0, i32 0, i32 1
  %268 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %269 = add i64 %268, 1031
  call void @__csan_load(i64 %269, i8* nonnull %flag.i.i.i.i12.i.i.i, i32 1, i64 1)
  %bf.load.i.i.i.i13.i.i.i = load i8, i8* %flag.i.i.i.i12.i.i.i, align 1, !noalias !20
  %cmp.i.i.i.i14.i.i.i = icmp sgt i8 %bf.load.i.i.i.i13.i.i.i, -1
  br i1 %cmp.i.i.i.i14.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i, label %if.then.i.i.i.i.i.i

if.then.i.i.i.i.i.i:                              ; preds = %invoke.cont9.i.i.i
  %buffer.i.i.i.i15.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %270 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %271 = add i64 %270, 1032
  %272 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.i.i.i to i8*
  call void @__csan_load(i64 %271, i8* nonnull %272, i32 8, i64 1)
  %273 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.i.i.i, align 1, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i16.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %273, i64 0, i32 0
  %274 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %275 = add i64 %274, 1011
  %276 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %273 to i8*
  call void @__csan_load(i64 %275, i8* %276, i32 8, i64 8)
  %277 = load i64, i64* %capacity.i.i.i.i.i16.i.i.i, align 8, !tbaa !29
  %278 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %279 = add i64 %278, 406
  %280 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %279, i64 %280, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i.i.i unwind label %lpad.i.i17.i.i.i

call.i.i.i.i.i.noexc.i.i.i.i.i:                   ; preds = %if.then.i.i.i.i.i.i
  call void @__csan_after_call(i64 %279, i64 %280, i8 0, i64 0)
  %281 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %273 to i8*
  %add.i.i.i.i.i.i.i.i = add i64 %277, 8
  %282 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %282)
  call void @__csan_set_MAAP(i8 3, i64 %282)
  %283 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %284 = add i64 %283, 407
  call void @__csan_before_call(i64 %284, i64 %282, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.i.i.i, i8* %281, i64 %add.i.i.i.i.i.i.i.i)
          to label %.noexc.i.i.i.i.i unwind label %lpad.i.i17.i.i.i

.noexc.i.i.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i
  call void @__csan_after_call(i64 %284, i64 %282, i8 2, i64 0)
  %285 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %286 = add i64 %285, 581
  %287 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.i.i.i to i8*
  call void @__csan_store(i64 %286, i8* nonnull %287, i32 8, i64 1)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.i.i.i, align 1, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i

lpad.i.i17.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i.3.i.i.i, %if.then.i.i.i.3.i.i.i, %call.i.i.i.i.i.noexc.i.i.2.i.i.i, %if.then.i.i.i.2.i.i.i, %call.i.i.i.i.i.noexc.i.i.1.i.i.i, %if.then.i.i.i.1.i.i.i, %call.i.i.i.i.i.noexc.i.i.i.i.i, %if.then.i.i.i.i.i.i
  %288 = phi i64 [ %426, %call.i.i.i.i.i.noexc.i.i.3.i.i.i ], [ %421, %if.then.i.i.i.3.i.i.i ], [ %404, %call.i.i.i.i.i.noexc.i.i.2.i.i.i ], [ %399, %if.then.i.i.i.2.i.i.i ], [ %382, %call.i.i.i.i.i.noexc.i.i.1.i.i.i ], [ %377, %if.then.i.i.i.1.i.i.i ], [ %284, %call.i.i.i.i.i.noexc.i.i.i.i.i ], [ %279, %if.then.i.i.i.i.i.i ]
  %289 = phi i64 [ %424, %call.i.i.i.i.i.noexc.i.i.3.i.i.i ], [ %422, %if.then.i.i.i.3.i.i.i ], [ %402, %call.i.i.i.i.i.noexc.i.i.2.i.i.i ], [ %400, %if.then.i.i.i.2.i.i.i ], [ %380, %call.i.i.i.i.i.noexc.i.i.1.i.i.i ], [ %378, %if.then.i.i.i.1.i.i.i ], [ %282, %call.i.i.i.i.i.noexc.i.i.i.i.i ], [ %280, %if.then.i.i.i.i.i.i ]
  %290 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i.3.i.i.i ], [ 0, %if.then.i.i.i.3.i.i.i ], [ 2, %call.i.i.i.i.i.noexc.i.i.2.i.i.i ], [ 0, %if.then.i.i.i.2.i.i.i ], [ 2, %call.i.i.i.i.i.noexc.i.i.1.i.i.i ], [ 0, %if.then.i.i.i.1.i.i.i ], [ 2, %call.i.i.i.i.i.noexc.i.i.i.i.i ], [ 0, %if.then.i.i.i.i.i.i ]
  %291 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %288, i64 %289, i8 %290, i64 0)
  %292 = extractvalue { i8*, i32 } %291, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %292) #11
  unreachable

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i: ; preds = %.noexc.i.i.i.i.i, %invoke.cont9.i.i.i
  %293 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %294 = add i64 %293, 582
  call void @__csan_store(i64 %294, i8* nonnull %flag.i.i.i.i12.i.i.i, i32 1, i64 1)
  store i8 0, i8* %flag.i.i.i.i12.i.i.i, align 1, !noalias !20
  %295 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %296 = add i64 %295, 1033
  call void @__csan_load(i64 %296, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  %bf.load.i.i.i.i13.1.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !20
  %cmp.i.i.i.i14.1.i.i.i = icmp sgt i8 %bf.load.i.i.i.i13.1.i.i.i, -1
  br i1 %cmp.i.i.i.i14.1.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i, label %if.then.i.i.i.1.i.i.i

lpad.body.thread84.i.i.i:                         ; preds = %invoke.cont4.i.i.i, %invoke.cont.i.i.i
  %297 = phi i64 [ %221, %invoke.cont4.i.i.i ], [ %130, %invoke.cont.i.i.i ]
  %298 = phi i64 [ %219, %invoke.cont4.i.i.i ], [ %128, %invoke.cont.i.i.i ]
  %arrayinit.endOfInit.0.idx.ph.i.i.i = phi i64 [ 3, %invoke.cont4.i.i.i ], [ 1, %invoke.cont.i.i.i ]
  %lpad.thr_comm.i.i.i = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %297, i64 %298, i8 2, i64 0)
  %arrayinit.begin.i.i.i.le53 = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0
  br label %arraydestroy.body.preheader.i.i.i

lpad.body.i.i.i:                                  ; preds = %pfor.body.tf.tf.tf
  %lpad.thr_comm.split-lp.i.i.i = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %122, i64 %120, i8 2, i64 0)
  br label %ehcleanup.i.i.i

arraydestroy.body.preheader.i.i.i:                ; preds = %lpad.body.thread84.i.i.i, %lpad.body.thread.i.i.i
  %arrayinit.begin.i.i.i31 = phi %"class.parlay::sequence"* [ %arrayinit.begin.i.i.i.le, %lpad.body.thread.i.i.i ], [ %arrayinit.begin.i.i.i.le53, %lpad.body.thread84.i.i.i ]
  %arrayinit.endOfInit.0.idx.lpad-body82.i.i.i = phi i64 [ 2, %lpad.body.thread.i.i.i ], [ %arrayinit.endOfInit.0.idx.ph.i.i.i, %lpad.body.thread84.i.i.i ]
  %arrayinit.endOfInit.0.ptr.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 %arrayinit.endOfInit.0.idx.lpad-body82.i.i.i
  br label %arraydestroy.body.i.i.i

arraydestroy.body.i.i.i:                          ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit29.i.i.i, %arraydestroy.body.preheader.i.i.i
  %arraydestroy.elementPast.i.i.i = phi %"class.parlay::sequence"* [ %arraydestroy.element.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit29.i.i.i ], [ %arrayinit.endOfInit.0.ptr.i.i.i, %arraydestroy.body.preheader.i.i.i ]
  %arraydestroy.element.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.elementPast.i.i.i, i64 -1
  %flag.i.i.i.i18.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.elementPast.i.i.i, i64 -1, i32 0, i32 0, i32 0, i32 1
  %299 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %300 = add i64 %299, 1034
  call void @__csan_load(i64 %300, i8* nonnull %flag.i.i.i.i18.i.i.i, i32 1, i64 1)
  %bf.load.i.i.i.i19.i.i.i = load i8, i8* %flag.i.i.i.i18.i.i.i, align 1, !noalias !20
  %cmp.i.i.i.i20.i.i.i = icmp sgt i8 %bf.load.i.i.i.i19.i.i.i, -1
  br i1 %cmp.i.i.i.i20.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit29.i.i.i, label %if.then.i.i.i24.i.i.i

if.then.i.i.i24.i.i.i:                            ; preds = %arraydestroy.body.i.i.i
  %buffer.i.i.i.i21.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.element.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %301 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %302 = add i64 %301, 1035
  %303 = bitcast %"class.parlay::sequence"* %arraydestroy.element.i.i.i to i8*
  call void @__csan_load(i64 %302, i8* nonnull %303, i32 8, i64 1)
  %304 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i21.i.i.i, align 1, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i22.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %304, i64 0, i32 0
  %305 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %306 = add i64 %305, 1012
  %307 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %304 to i8*
  call void @__csan_load(i64 %306, i8* %307, i32 8, i64 8)
  %308 = load i64, i64* %capacity.i.i.i.i.i22.i.i.i, align 8, !tbaa !29
  %309 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %310 = add i64 %309, 408
  %311 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %310, i64 %311, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i23.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i26.i.i.i unwind label %lpad.i.i28.i.i.i

call.i.i.i.i.i.noexc.i.i26.i.i.i:                 ; preds = %if.then.i.i.i24.i.i.i
  call void @__csan_after_call(i64 %310, i64 %311, i8 0, i64 0)
  %312 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %304 to i8*
  %add.i.i.i.i.i25.i.i.i = add i64 %308, 8
  %313 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %313)
  call void @__csan_set_MAAP(i8 3, i64 %313)
  %314 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %315 = add i64 %314, 409
  call void @__csan_before_call(i64 %315, i64 %313, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i23.i.i.i, i8* %312, i64 %add.i.i.i.i.i25.i.i.i)
          to label %.noexc.i.i27.i.i.i unwind label %lpad.i.i28.i.i.i

.noexc.i.i27.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i26.i.i.i
  call void @__csan_after_call(i64 %315, i64 %313, i8 2, i64 0)
  %316 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %317 = add i64 %316, 583
  %318 = bitcast %"class.parlay::sequence"* %arraydestroy.element.i.i.i to i8*
  call void @__csan_store(i64 %317, i8* nonnull %318, i32 8, i64 1)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i21.i.i.i, align 1, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit29.i.i.i

lpad.i.i28.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i26.i.i.i, %if.then.i.i.i24.i.i.i
  %319 = phi i64 [ %315, %call.i.i.i.i.i.noexc.i.i26.i.i.i ], [ %310, %if.then.i.i.i24.i.i.i ]
  %320 = phi i64 [ %313, %call.i.i.i.i.i.noexc.i.i26.i.i.i ], [ %311, %if.then.i.i.i24.i.i.i ]
  %321 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i26.i.i.i ], [ 0, %if.then.i.i.i24.i.i.i ]
  %322 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %319, i64 %320, i8 %321, i64 0)
  %323 = extractvalue { i8*, i32 } %322, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %323) #11
  unreachable

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit29.i.i.i: ; preds = %.noexc.i.i27.i.i.i, %arraydestroy.body.i.i.i
  %324 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %325 = add i64 %324, 584
  call void @__csan_store(i64 %325, i8* nonnull %flag.i.i.i.i18.i.i.i, i32 1, i64 1)
  store i8 0, i8* %flag.i.i.i.i18.i.i.i, align 1, !noalias !20
  %arraydestroy.done.i.i.i = icmp eq %"class.parlay::sequence"* %arraydestroy.element.i.i.i, %arrayinit.begin.i.i.i31
  br i1 %arraydestroy.done.i.i.i, label %ehcleanup.i.i.i, label %arraydestroy.body.i.i.i

if.then.i.i.i36.i.i.i:                            ; preds = %lpad.i.loopexit.split-lp.i.i.i
  %buffer.i.i.i.i33.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %326 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %327 = add i64 %326, 1036
  %328 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.i.i.i to i8*
  call void @__csan_load(i64 %327, i8* nonnull %328, i32 8, i64 1)
  %329 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.i.i.i, align 1, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i34.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %329, i64 0, i32 0
  %330 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %331 = add i64 %330, 1013
  %332 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %329 to i8*
  call void @__csan_load(i64 %331, i8* %332, i32 8, i64 8)
  %333 = load i64, i64* %capacity.i.i.i.i.i34.i.i.i, align 8, !tbaa !29
  %334 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %335 = add i64 %334, 410
  %336 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %335, i64 %336, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i35.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i38.i.i.i unwind label %lpad.i.i40.i.i.i

call.i.i.i.i.i.noexc.i.i38.i.i.i:                 ; preds = %if.then.i.i.i36.i.i.i
  call void @__csan_after_call(i64 %335, i64 %336, i8 0, i64 0)
  %337 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %329 to i8*
  %add.i.i.i.i.i37.i.i.i = add i64 %333, 8
  %338 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %338)
  call void @__csan_set_MAAP(i8 3, i64 %338)
  %339 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %340 = add i64 %339, 411
  call void @__csan_before_call(i64 %340, i64 %338, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i35.i.i.i, i8* %337, i64 %add.i.i.i.i.i37.i.i.i)
          to label %.noexc.i.i39.i.i.i unwind label %lpad.i.i40.i.i.i

.noexc.i.i39.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i38.i.i.i
  call void @__csan_after_call(i64 %340, i64 %338, i8 2, i64 0)
  %341 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %342 = add i64 %341, 585
  %343 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.i.i.i to i8*
  call void @__csan_store(i64 %342, i8* nonnull %343, i32 8, i64 1)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.i.i.i, align 1, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.i.i.i

lpad.i.i40.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i38.3.i.i.i, %if.then.i.i.i36.3.i.i.i, %call.i.i.i.i.i.noexc.i.i38.2.i.i.i, %if.then.i.i.i36.2.i.i.i, %call.i.i.i.i.i.noexc.i.i38.1.i.i.i, %if.then.i.i.i36.1.i.i.i, %call.i.i.i.i.i.noexc.i.i38.i.i.i, %if.then.i.i.i36.i.i.i
  %344 = phi i64 [ %491, %call.i.i.i.i.i.noexc.i.i38.3.i.i.i ], [ %486, %if.then.i.i.i36.3.i.i.i ], [ %469, %call.i.i.i.i.i.noexc.i.i38.2.i.i.i ], [ %464, %if.then.i.i.i36.2.i.i.i ], [ %447, %call.i.i.i.i.i.noexc.i.i38.1.i.i.i ], [ %442, %if.then.i.i.i36.1.i.i.i ], [ %340, %call.i.i.i.i.i.noexc.i.i38.i.i.i ], [ %335, %if.then.i.i.i36.i.i.i ]
  %345 = phi i64 [ %489, %call.i.i.i.i.i.noexc.i.i38.3.i.i.i ], [ %487, %if.then.i.i.i36.3.i.i.i ], [ %467, %call.i.i.i.i.i.noexc.i.i38.2.i.i.i ], [ %465, %if.then.i.i.i36.2.i.i.i ], [ %445, %call.i.i.i.i.i.noexc.i.i38.1.i.i.i ], [ %443, %if.then.i.i.i36.1.i.i.i ], [ %338, %call.i.i.i.i.i.noexc.i.i38.i.i.i ], [ %336, %if.then.i.i.i36.i.i.i ]
  %346 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i38.3.i.i.i ], [ 0, %if.then.i.i.i36.3.i.i.i ], [ 2, %call.i.i.i.i.i.noexc.i.i38.2.i.i.i ], [ 0, %if.then.i.i.i36.2.i.i.i ], [ 2, %call.i.i.i.i.i.noexc.i.i38.1.i.i.i ], [ 0, %if.then.i.i.i36.1.i.i.i ], [ 2, %call.i.i.i.i.i.noexc.i.i38.i.i.i ], [ 0, %if.then.i.i.i36.i.i.i ]
  %347 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %344, i64 %345, i8 %346, i64 0)
  %348 = extractvalue { i8*, i32 } %347, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %348) #11
  unreachable

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.i.i.i: ; preds = %.noexc.i.i39.i.i.i, %lpad.i.loopexit.split-lp.i.i.i
  %349 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %350 = add i64 %349, 586
  call void @__csan_store(i64 %350, i8* nonnull %flag.i.i.i.i30.i.i.i, i32 1, i64 1)
  store i8 0, i8* %flag.i.i.i.i30.i.i.i, align 1, !noalias !20
  %351 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %352 = add i64 %351, 1037
  call void @__csan_load(i64 %352, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  %bf.load.i.i.i.i31.1.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !20
  %cmp.i.i.i.i32.1.i.i.i = icmp sgt i8 %bf.load.i.i.i.i31.1.i.i.i, -1
  br i1 %cmp.i.i.i.i32.1.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.1.i.i.i, label %if.then.i.i.i36.1.i.i.i

ehcleanup.i.i.i:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.3.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit29.i.i.i, %lpad.body.i.i.i
  %353 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  call void @llvm.lifetime.end.p0i8(i64 60, i8* nonnull %353) #10, !noalias !20
  br label %ehcleanup24.i.i.i

lpad21.i.i.i:                                     ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i
  %354 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %432, i64 %430, i8 2, i64 0)
  %355 = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0
  %356 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEED2Ev, align 8
  call void @__csan_set_MAAP(i8 7, i64 %356)
  %357 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %358 = add i64 %357, 412
  call void @__csan_before_call(i64 %358, i64 %356, i8 1, i64 0)
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEED2Ev(%"struct.parlay::_sequence_base.3"* nonnull %355) #10
  call void @__csan_after_call(i64 %358, i64 %356, i8 1, i64 0)
  br label %ehcleanup24.i.i.i

ehcleanup24.i.i.i:                                ; preds = %lpad21.i.i.i, %ehcleanup.i.i.i
  %359 = bitcast %"class.parlay::sequence.2"* %s.i.i.i to i8*
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %359) #10, !noalias !20
  %flag.i.i.i.i.i11.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i12.i.i = load i8, i8* %flag.i.i.i.i.i11.i.i, align 2, !noalias !12
  %cmp.i.i.i.i.i13.i.i = icmp slt i8 %bf.load.i.i.i.i.i12.i.i, 0
  call void @llvm.assume(i1 %cmp.i.i.i.i.i13.i.i)
  %buffer.i.i.i.i.i14.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %360 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i14.i.i, align 8, !tbaa !35, !noalias !12
  %capacity.i.i.i.i.i.i15.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %360, i64 0, i32 0
  %361 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %362 = add i64 %361, 1014
  %363 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %360 to i8*
  call void @__csan_load(i64 %362, i8* %363, i32 8, i64 8)
  %364 = load i64, i64* %capacity.i.i.i.i.i.i15.i.i, align 8, !tbaa !29
  %365 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %366 = add i64 %365, 413
  %367 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %366, i64 %367, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i.i16.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i19.i.i unwind label %lpad.i.i.i21.i.i

if.then.i.i.i.1.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i
  %buffer.i.i.i.i15.1.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %368 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %369 = add i64 %368, 1038
  %370 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.1.i.i.i to i8*
  call void @__csan_load(i64 %369, i8* nonnull %370, i32 8, i64 2)
  %371 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.1.i.i.i, align 2, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i16.1.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %371, i64 0, i32 0
  %372 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %373 = add i64 %372, 1015
  %374 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %371 to i8*
  call void @__csan_load(i64 %373, i8* %374, i32 8, i64 8)
  %375 = load i64, i64* %capacity.i.i.i.i.i16.1.i.i.i, align 8, !tbaa !29
  %376 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %377 = add i64 %376, 414
  %378 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %377, i64 %378, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i.1.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.1.i.i.i unwind label %lpad.i.i17.i.i.i

call.i.i.i.i.i.noexc.i.i.1.i.i.i:                 ; preds = %if.then.i.i.i.1.i.i.i
  call void @__csan_after_call(i64 %377, i64 %378, i8 0, i64 0)
  %379 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %371 to i8*
  %add.i.i.i.i.i.1.i.i.i = add i64 %375, 8
  %380 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %380)
  call void @__csan_set_MAAP(i8 3, i64 %380)
  %381 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %382 = add i64 %381, 415
  call void @__csan_before_call(i64 %382, i64 %380, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.1.i.i.i, i8* %379, i64 %add.i.i.i.i.i.1.i.i.i)
          to label %.noexc.i.i.1.i.i.i unwind label %lpad.i.i17.i.i.i

.noexc.i.i.1.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.1.i.i.i
  call void @__csan_after_call(i64 %382, i64 %380, i8 2, i64 0)
  %383 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %384 = add i64 %383, 587
  %385 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.1.i.i.i to i8*
  call void @__csan_store(i64 %384, i8* nonnull %385, i32 8, i64 2)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.1.i.i.i, align 2, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i: ; preds = %.noexc.i.i.1.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i
  %386 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %387 = add i64 %386, 588
  call void @__csan_store(i64 %387, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  store i8 0, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !20
  %flag.i.i.i.i12.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0, i32 0, i32 1
  %388 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %389 = add i64 %388, 1039
  call void @__csan_load(i64 %389, i8* nonnull %flag.i.i.i.i12.2.i.i.i, i32 1, i64 1)
  %bf.load.i.i.i.i13.2.i.i.i = load i8, i8* %flag.i.i.i.i12.2.i.i.i, align 1, !noalias !20
  %cmp.i.i.i.i14.2.i.i.i = icmp sgt i8 %bf.load.i.i.i.i13.2.i.i.i, -1
  br i1 %cmp.i.i.i.i14.2.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i, label %if.then.i.i.i.2.i.i.i

if.then.i.i.i.2.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i
  %buffer.i.i.i.i15.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %390 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %391 = add i64 %390, 1040
  %392 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.2.i.i.i to i8*
  call void @__csan_load(i64 %391, i8* nonnull %392, i32 8, i64 1)
  %393 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.2.i.i.i, align 1, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i16.2.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %393, i64 0, i32 0
  %394 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %395 = add i64 %394, 1016
  %396 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %393 to i8*
  call void @__csan_load(i64 %395, i8* %396, i32 8, i64 8)
  %397 = load i64, i64* %capacity.i.i.i.i.i16.2.i.i.i, align 8, !tbaa !29
  %398 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %399 = add i64 %398, 416
  %400 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %399, i64 %400, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i.2.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.2.i.i.i unwind label %lpad.i.i17.i.i.i

call.i.i.i.i.i.noexc.i.i.2.i.i.i:                 ; preds = %if.then.i.i.i.2.i.i.i
  call void @__csan_after_call(i64 %399, i64 %400, i8 0, i64 0)
  %401 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %393 to i8*
  %add.i.i.i.i.i.2.i.i.i = add i64 %397, 8
  %402 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %402)
  call void @__csan_set_MAAP(i8 3, i64 %402)
  %403 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %404 = add i64 %403, 417
  call void @__csan_before_call(i64 %404, i64 %402, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.2.i.i.i, i8* %401, i64 %add.i.i.i.i.i.2.i.i.i)
          to label %.noexc.i.i.2.i.i.i unwind label %lpad.i.i17.i.i.i

.noexc.i.i.2.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.2.i.i.i
  call void @__csan_after_call(i64 %404, i64 %402, i8 2, i64 0)
  %405 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %406 = add i64 %405, 589
  %407 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.2.i.i.i to i8*
  call void @__csan_store(i64 %406, i8* nonnull %407, i32 8, i64 1)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.2.i.i.i, align 1, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i: ; preds = %.noexc.i.i.2.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1.i.i.i
  %408 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %409 = add i64 %408, 590
  call void @__csan_store(i64 %409, i8* nonnull %flag.i.i.i.i12.2.i.i.i, i32 1, i64 1)
  store i8 0, i8* %flag.i.i.i.i12.2.i.i.i, align 1, !noalias !20
  %flag.i.i.i.i12.3.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0, i32 0, i32 1
  %410 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %411 = add i64 %410, 1041
  call void @__csan_load(i64 %411, i8* nonnull %flag.i.i.i.i12.3.i.i.i, i32 1, i64 2)
  %bf.load.i.i.i.i13.3.i.i.i = load i8, i8* %flag.i.i.i.i12.3.i.i.i, align 2, !noalias !20
  %cmp.i.i.i.i14.3.i.i.i = icmp sgt i8 %bf.load.i.i.i.i13.3.i.i.i, -1
  br i1 %cmp.i.i.i.i14.3.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i, label %if.then.i.i.i.3.i.i.i

if.then.i.i.i.3.i.i.i:                            ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i
  %buffer.i.i.i.i15.3.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %412 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %413 = add i64 %412, 1042
  %414 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  call void @__csan_load(i64 %413, i8* nonnull %414, i32 8, i64 8)
  %415 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.3.i.i.i, align 8, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i16.3.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %415, i64 0, i32 0
  %416 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %417 = add i64 %416, 1017
  %418 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %415 to i8*
  call void @__csan_load(i64 %417, i8* %418, i32 8, i64 8)
  %419 = load i64, i64* %capacity.i.i.i.i.i16.3.i.i.i, align 8, !tbaa !29
  %420 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %421 = add i64 %420, 418
  %422 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %421, i64 %422, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i.3.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.3.i.i.i unwind label %lpad.i.i17.i.i.i

call.i.i.i.i.i.noexc.i.i.3.i.i.i:                 ; preds = %if.then.i.i.i.3.i.i.i
  call void @__csan_after_call(i64 %421, i64 %422, i8 0, i64 0)
  %423 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %415 to i8*
  %add.i.i.i.i.i.3.i.i.i = add i64 %419, 8
  %424 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %424)
  call void @__csan_set_MAAP(i8 3, i64 %424)
  %425 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %426 = add i64 %425, 419
  call void @__csan_before_call(i64 %426, i64 %424, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.3.i.i.i, i8* %423, i64 %add.i.i.i.i.i.3.i.i.i)
          to label %.noexc.i.i.3.i.i.i unwind label %lpad.i.i17.i.i.i

.noexc.i.i.3.i.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.3.i.i.i
  call void @__csan_after_call(i64 %426, i64 %424, i8 2, i64 0)
  %427 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %428 = add i64 %427, 591
  %429 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  call void @__csan_store(i64 %428, i8* nonnull %429, i32 8, i64 8)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i15.3.i.i.i, align 8, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i: ; preds = %.noexc.i.i.3.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2.i.i.i
  call void @llvm.lifetime.end.p0i8(i64 60, i8* nonnull %116) #10, !noalias !20
  %430 = load i64, i64* @__csi_func_id__ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_, align 8
  call void @__csan_set_MAAP(i8 7, i64 %430)
  call void @__csan_set_MAAP(i8 7, i64 %430)
  %431 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %432 = add i64 %431, 420
  call void @__csan_before_call(i64 %432, i64 %430, i8 2, i64 0)
  invoke void @_ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_(%"class.parlay::sequence"* nonnull sret %ref.tmp.i, %"class.parlay::sequence.2"* nonnull dereferenceable(15) %s.i.i.i)
          to label %invoke.cont.i.i unwind label %lpad21.i.i.i

if.then.i.i.i36.1.i.i.i:                          ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.i.i.i
  %buffer.i.i.i.i33.1.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %433 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %434 = add i64 %433, 1043
  %435 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.1.i.i.i to i8*
  call void @__csan_load(i64 %434, i8* nonnull %435, i32 8, i64 2)
  %436 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.1.i.i.i, align 2, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i34.1.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %436, i64 0, i32 0
  %437 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %438 = add i64 %437, 1018
  %439 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %436 to i8*
  call void @__csan_load(i64 %438, i8* %439, i32 8, i64 8)
  %440 = load i64, i64* %capacity.i.i.i.i.i34.1.i.i.i, align 8, !tbaa !29
  %441 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %442 = add i64 %441, 421
  %443 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %442, i64 %443, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i35.1.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i38.1.i.i.i unwind label %lpad.i.i40.i.i.i

call.i.i.i.i.i.noexc.i.i38.1.i.i.i:               ; preds = %if.then.i.i.i36.1.i.i.i
  call void @__csan_after_call(i64 %442, i64 %443, i8 0, i64 0)
  %444 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %436 to i8*
  %add.i.i.i.i.i37.1.i.i.i = add i64 %440, 8
  %445 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %445)
  call void @__csan_set_MAAP(i8 3, i64 %445)
  %446 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %447 = add i64 %446, 422
  call void @__csan_before_call(i64 %447, i64 %445, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i35.1.i.i.i, i8* %444, i64 %add.i.i.i.i.i37.1.i.i.i)
          to label %.noexc.i.i39.1.i.i.i unwind label %lpad.i.i40.i.i.i

.noexc.i.i39.1.i.i.i:                             ; preds = %call.i.i.i.i.i.noexc.i.i38.1.i.i.i
  call void @__csan_after_call(i64 %447, i64 %445, i8 2, i64 0)
  %448 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %449 = add i64 %448, 592
  %450 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.1.i.i.i to i8*
  call void @__csan_store(i64 %449, i8* nonnull %450, i32 8, i64 2)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.1.i.i.i, align 2, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.1.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.1.i.i.i: ; preds = %.noexc.i.i39.1.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.i.i.i
  %451 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %452 = add i64 %451, 593
  call void @__csan_store(i64 %452, i8* nonnull %small_n.i.i.i.i.i.i.i.i, i32 1, i64 2)
  store i8 0, i8* %small_n.i.i.i.i.i.i.i.i, align 2, !noalias !20
  %flag.i.i.i.i30.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0, i32 0, i32 1
  %453 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %454 = add i64 %453, 1044
  call void @__csan_load(i64 %454, i8* nonnull %flag.i.i.i.i30.2.i.i.i, i32 1, i64 1)
  %bf.load.i.i.i.i31.2.i.i.i = load i8, i8* %flag.i.i.i.i30.2.i.i.i, align 1, !noalias !20
  %cmp.i.i.i.i32.2.i.i.i = icmp sgt i8 %bf.load.i.i.i.i31.2.i.i.i, -1
  br i1 %cmp.i.i.i.i32.2.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.2.i.i.i, label %if.then.i.i.i36.2.i.i.i

if.then.i.i.i36.2.i.i.i:                          ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.1.i.i.i
  %buffer.i.i.i.i33.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %455 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %456 = add i64 %455, 1045
  %457 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.2.i.i.i to i8*
  call void @__csan_load(i64 %456, i8* nonnull %457, i32 8, i64 1)
  %458 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.2.i.i.i, align 1, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i34.2.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %458, i64 0, i32 0
  %459 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %460 = add i64 %459, 1019
  %461 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %458 to i8*
  call void @__csan_load(i64 %460, i8* %461, i32 8, i64 8)
  %462 = load i64, i64* %capacity.i.i.i.i.i34.2.i.i.i, align 8, !tbaa !29
  %463 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %464 = add i64 %463, 423
  %465 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %464, i64 %465, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i35.2.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i38.2.i.i.i unwind label %lpad.i.i40.i.i.i

call.i.i.i.i.i.noexc.i.i38.2.i.i.i:               ; preds = %if.then.i.i.i36.2.i.i.i
  call void @__csan_after_call(i64 %464, i64 %465, i8 0, i64 0)
  %466 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %458 to i8*
  %add.i.i.i.i.i37.2.i.i.i = add i64 %462, 8
  %467 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %467)
  call void @__csan_set_MAAP(i8 3, i64 %467)
  %468 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %469 = add i64 %468, 424
  call void @__csan_before_call(i64 %469, i64 %467, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i35.2.i.i.i, i8* %466, i64 %add.i.i.i.i.i37.2.i.i.i)
          to label %.noexc.i.i39.2.i.i.i unwind label %lpad.i.i40.i.i.i

.noexc.i.i39.2.i.i.i:                             ; preds = %call.i.i.i.i.i.noexc.i.i38.2.i.i.i
  call void @__csan_after_call(i64 %469, i64 %467, i8 2, i64 0)
  %470 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %471 = add i64 %470, 594
  %472 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.2.i.i.i to i8*
  call void @__csan_store(i64 %471, i8* nonnull %472, i32 8, i64 1)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.2.i.i.i, align 1, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.2.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.2.i.i.i: ; preds = %.noexc.i.i39.2.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.1.i.i.i
  %473 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %474 = add i64 %473, 595
  call void @__csan_store(i64 %474, i8* nonnull %flag.i.i.i.i30.2.i.i.i, i32 1, i64 1)
  store i8 0, i8* %flag.i.i.i.i30.2.i.i.i, align 1, !noalias !20
  %flag.i.i.i.i30.3.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0, i32 0, i32 1
  %475 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %476 = add i64 %475, 1046
  call void @__csan_load(i64 %476, i8* nonnull %flag.i.i.i.i30.3.i.i.i, i32 1, i64 2)
  %bf.load.i.i.i.i31.3.i.i.i = load i8, i8* %flag.i.i.i.i30.3.i.i.i, align 2, !noalias !20
  %cmp.i.i.i.i32.3.i.i.i = icmp sgt i8 %bf.load.i.i.i.i31.3.i.i.i, -1
  br i1 %cmp.i.i.i.i32.3.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.3.i.i.i, label %if.then.i.i.i36.3.i.i.i

if.then.i.i.i36.3.i.i.i:                          ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.2.i.i.i
  %buffer.i.i.i.i33.3.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %477 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %478 = add i64 %477, 1047
  %479 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  call void @__csan_load(i64 %478, i8* nonnull %479, i32 8, i64 8)
  %480 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.3.i.i.i, align 8, !tbaa !35, !noalias !20
  %capacity.i.i.i.i.i34.3.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %480, i64 0, i32 0
  %481 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %482 = add i64 %481, 1020
  %483 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %480 to i8*
  call void @__csan_load(i64 %482, i8* %483, i32 8, i64 8)
  %484 = load i64, i64* %capacity.i.i.i.i.i34.3.i.i.i, align 8, !tbaa !29
  %485 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %486 = add i64 %485, 425
  %487 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %486, i64 %487, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i35.3.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i38.3.i.i.i unwind label %lpad.i.i40.i.i.i

call.i.i.i.i.i.noexc.i.i38.3.i.i.i:               ; preds = %if.then.i.i.i36.3.i.i.i
  call void @__csan_after_call(i64 %486, i64 %487, i8 0, i64 0)
  %488 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %480 to i8*
  %add.i.i.i.i.i37.3.i.i.i = add i64 %484, 8
  %489 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %489)
  call void @__csan_set_MAAP(i8 3, i64 %489)
  %490 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %491 = add i64 %490, 426
  call void @__csan_before_call(i64 %491, i64 %489, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i35.3.i.i.i, i8* %488, i64 %add.i.i.i.i.i37.3.i.i.i)
          to label %.noexc.i.i39.3.i.i.i unwind label %lpad.i.i40.i.i.i

.noexc.i.i39.3.i.i.i:                             ; preds = %call.i.i.i.i.i.noexc.i.i38.3.i.i.i
  call void @__csan_after_call(i64 %491, i64 %489, i8 2, i64 0)
  %492 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %493 = add i64 %492, 596
  %494 = bitcast [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i to i8*
  call void @__csan_store(i64 %493, i8* nonnull %494, i32 8, i64 8)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i33.3.i.i.i, align 8, !tbaa !35, !noalias !20
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.3.i.i.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.3.i.i.i: ; preds = %.noexc.i.i39.3.i.i.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit41.2.i.i.i
  %495 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %496 = add i64 %495, 597
  call void @__csan_store(i64 %496, i8* nonnull %flag.i.i.i.i30.3.i.i.i, i32 1, i64 2)
  store i8 0, i8* %flag.i.i.i.i30.3.i.i.i, align 2, !noalias !20
  br label %ehcleanup.i.i.i

pfor.body.i.i.1.i.i.i:                            ; preds = %pfor.inc.i.i.i.i.i
  %497 = call i8* @llvm.task.frameaddress(i32 0)
  %498 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %39, i64 %37, i8* %497, i8* %498, i64 0)
  %impl.i.i.i.i.i.i.i.i.1.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i.i.i.i, i64 1, i32 0, i32 0
  %499 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %499)
  call void @__csan_set_MAAP(i8 3, i64 %499)
  %500 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %501 = add i64 %500, 427
  call void @__csan_before_call(i64 %501, i64 %499, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.1.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i2.i.i.i)
          to label %.noexc.1.i.i.i unwind label %lpad.i9.i.i.i

.noexc.1.i.i.i:                                   ; preds = %pfor.body.i.i.1.i.i.i
  call void @__csan_after_call(i64 %501, i64 %499, i8 2, i64 0)
  call void @__csan_task_exit(i64 %41, i64 %39, i64 %37, i8 0, i64 0)
  reattach within %syncreg19.i.i.i.i.i, label %pfor.inc.i.i.1.i.i.i

pfor.inc.i.i.1.i.i.i:                             ; preds = %.noexc.1.i.i.i, %pfor.inc.i.i.i.i.i
  call void @__csan_detach_continue(i64 %43, i64 %37)
  call void @__csan_detach(i64 %28, i8 0)
  detach within %syncreg19.i.i.i.i.i, label %pfor.body.i.i.2.i.i.i, label %pfor.inc.i.i.2.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split

pfor.body.i.i.2.i.i.i:                            ; preds = %pfor.inc.i.i.1.i.i.i
  %502 = call i8* @llvm.task.frameaddress(i32 0)
  %503 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %30, i64 %28, i8* %502, i8* %503, i64 0)
  %impl.i.i.i.i.i.i.i.2.i.i.i = getelementptr inbounds [4 x %"class.parlay::sequence"], [4 x %"class.parlay::sequence"]* %ref.tmp.i.i.i, i64 0, i64 2, i32 0, i32 0
  %impl.i.i.i.i.i.i.i.i.2.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i.i.i.i, i64 2, i32 0, i32 0
  %504 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %504)
  call void @__csan_set_MAAP(i8 3, i64 %504)
  %505 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %506 = add i64 %505, 428
  call void @__csan_before_call(i64 %506, i64 %504, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.2.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i.i.i.2.i.i.i)
          to label %.noexc.2.i.i.i unwind label %lpad.i9.i.i.i

.noexc.2.i.i.i:                                   ; preds = %pfor.body.i.i.2.i.i.i
  call void @__csan_after_call(i64 %506, i64 %504, i8 2, i64 0)
  call void @__csan_task_exit(i64 %32, i64 %30, i64 %28, i8 0, i64 0)
  reattach within %syncreg19.i.i.i.i.i, label %pfor.inc.i.i.2.i.i.i

pfor.inc.i.i.2.i.i.i:                             ; preds = %.noexc.2.i.i.i, %pfor.inc.i.i.1.i.i.i
  call void @__csan_detach_continue(i64 %34, i64 %28)
  call void @__csan_detach(i64 %19, i8 0)
  detach within %syncreg19.i.i.i.i.i, label %pfor.body.i.i.3.i.i.i, label %pfor.inc.i.i.3.i.i.i unwind label %lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split

pfor.body.i.i.3.i.i.i:                            ; preds = %pfor.inc.i.i.2.i.i.i
  %507 = call i8* @llvm.task.frameaddress(i32 0)
  %508 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %21, i64 %19, i8* %507, i8* %508, i64 0)
  %impl.i.i.i.i.i.i.i.i.3.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i.i.i.i, i64 3, i32 0, i32 0
  %509 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %509)
  call void @__csan_set_MAAP(i8 3, i64 %509)
  %510 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %511 = add i64 %510, 429
  call void @__csan_before_call(i64 %511, i64 %509, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.3.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i5.i.i.i)
          to label %.noexc.3.i.i.i unwind label %lpad.i9.i.i.i

.noexc.3.i.i.i:                                   ; preds = %pfor.body.i.i.3.i.i.i
  call void @__csan_after_call(i64 %511, i64 %509, i8 2, i64 0)
  call void @__csan_task_exit(i64 %23, i64 %21, i64 %19, i8 0, i64 0)
  reattach within %syncreg19.i.i.i.i.i, label %pfor.inc.i.i.3.i.i.i

pfor.inc.i.i.3.i.i.i:                             ; preds = %.noexc.3.i.i.i, %pfor.inc.i.i.2.i.i.i
  call void @__csan_detach_continue(i64 %25, i64 %19)
  %512 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !2
  %513 = add i64 %512, 57
  call void @__csan_sync(i64 %513, i8 0)
  sync within %syncreg19.i.i.i.i.i, label %sync.continue.i.i.i.i.i

invoke.cont.i.i:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3.i.i.i
  call void @__csan_after_call(i64 %432, i64 %430, i8 2, i64 0)
  %514 = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s.i.i.i, i64 0, i32 0
  %515 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEED2Ev, align 8
  call void @__csan_set_MAAP(i8 7, i64 %515)
  %516 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %517 = add i64 %516, 430
  call void @__csan_before_call(i64 %517, i64 %515, i8 1, i64 0)
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEED2Ev(%"struct.parlay::_sequence_base.3"* nonnull %514) #10
  call void @__csan_after_call(i64 %517, i64 %515, i8 1, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %115) #10, !noalias !20
  %flag.i.i.i.i.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i.i.i = load i8, i8* %flag.i.i.i.i.i.i.i, align 2, !noalias !12
  %cmp.i.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i.i, label %"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm.exit", label %if.then.i.i.i.i5.i.i

if.then.i.i.i.i5.i.i:                             ; preds = %invoke.cont.i.i
  %buffer.i.i.i.i.i.i.i = getelementptr inbounds %"struct.std::pair.87", %"struct.std::pair.87"* %agg.tmp.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %518 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i, align 8, !tbaa !35, !noalias !12
  %capacity.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %518, i64 0, i32 0
  %519 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %520 = add i64 %519, 1021
  %521 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %518 to i8*
  call void @__csan_load(i64 %520, i8* %521, i32 8, i64 8)
  %522 = load i64, i64* %capacity.i.i.i.i.i.i.i.i, align 8, !tbaa !29
  %523 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %524 = add i64 %523, 431
  %525 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %524, i64 %525, i8 0, i64 0)
  %call.i.i.i.i.i1.i.i.i4.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i7.i.i unwind label %lpad.i.i.i9.i.i

call.i.i.i.i.i.noexc.i.i.i7.i.i:                  ; preds = %if.then.i.i.i.i5.i.i
  call void @__csan_after_call(i64 %524, i64 %525, i8 0, i64 0)
  %526 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %518 to i8*
  %add.i.i.i.i.i.i6.i.i = add i64 %522, 8
  %527 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %527)
  call void @__csan_set_MAAP(i8 3, i64 %527)
  %528 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %529 = add i64 %528, 432
  call void @__csan_before_call(i64 %529, i64 %527, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.i4.i.i, i8* %526, i64 %add.i.i.i.i.i.i6.i.i)
          to label %.noexc.i.i.i8.i.i unwind label %lpad.i.i.i9.i.i

.noexc.i.i.i8.i.i:                                ; preds = %call.i.i.i.i.i.noexc.i.i.i7.i.i
  call void @__csan_after_call(i64 %529, i64 %527, i8 2, i64 0)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i, align 8, !tbaa !35, !noalias !12
  br label %"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm.exit"

lpad.i.i.i9.i.i:                                  ; preds = %call.i.i.i.i.i.noexc.i.i.i7.i.i, %if.then.i.i.i.i5.i.i
  %530 = phi i64 [ %529, %call.i.i.i.i.i.noexc.i.i.i7.i.i ], [ %524, %if.then.i.i.i.i5.i.i ]
  %531 = phi i64 [ %527, %call.i.i.i.i.i.noexc.i.i.i7.i.i ], [ %525, %if.then.i.i.i.i5.i.i ]
  %532 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i.i7.i.i ], [ 0, %if.then.i.i.i.i5.i.i ]
  %533 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %530, i64 %531, i8 %532, i64 0)
  %534 = extractvalue { i8*, i32 } %533, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %534) #11
  unreachable

call.i.i.i.i.i.noexc.i.i.i19.i.i:                 ; preds = %ehcleanup24.i.i.i
  call void @__csan_after_call(i64 %366, i64 %367, i8 0, i64 0)
  %535 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %360 to i8*
  %add.i.i.i.i.i.i18.i.i = add i64 %364, 8
  %536 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %536)
  call void @__csan_set_MAAP(i8 3, i64 %536)
  %537 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %538 = add i64 %537, 433
  call void @__csan_before_call(i64 %538, i64 %536, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i1.i.i.i16.i.i, i8* %535, i64 %add.i.i.i.i.i.i18.i.i)
          to label %.noexc.i.i.i20.i.i unwind label %lpad.i.i.i21.i.i

.noexc.i.i.i20.i.i:                               ; preds = %call.i.i.i.i.i.noexc.i.i.i19.i.i
  call void @__csan_after_call(i64 %538, i64 %536, i8 2, i64 0)
  unreachable

lpad.i.i.i21.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i.i19.i.i, %ehcleanup24.i.i.i
  %539 = phi i64 [ %538, %call.i.i.i.i.i.noexc.i.i.i19.i.i ], [ %366, %ehcleanup24.i.i.i ]
  %540 = phi i64 [ %536, %call.i.i.i.i.i.noexc.i.i.i19.i.i ], [ %367, %ehcleanup24.i.i.i ]
  %541 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i.i19.i.i ], [ 0, %ehcleanup24.i.i.i ]
  %542 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %539, i64 %540, i8 %541, i64 0)
  %543 = extractvalue { i8*, i32 } %542, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %543) #11
  unreachable

"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm.exit": ; preds = %.noexc.i.i.i8.i.i, %invoke.cont.i.i
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %101)
  %small_n.i.i.i.i.i.i.i2.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %92, i64 %__begin.0, i32 0, i32 0, i32 0, i32 1
  %544 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %545 = add i64 %544, 564
  call void @__csan_store(i64 %545, i8* nonnull %small_n.i.i.i.i.i.i.i2.i, i32 1, i64 1)
  store i8 0, i8* %small_n.i.i.i.i.i.i.i2.i, align 1
  %546 = bitcast %"class.parlay::sequence"* %arrayidx.i to i8*
  %547 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %548 = add i64 %547, 565
  %549 = bitcast %"class.parlay::sequence"* %arrayidx.i to i8*
  call void @__csan_large_store(i64 %548, i8* %549, i64 15, i64 1)
  %550 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %551 = add i64 %550, 1048
  %552 = bitcast %"class.parlay::sequence"* %ref.tmp.i to i8*
  call void @__csan_large_load(i64 %551, i8* nonnull %552, i64 15, i64 8)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(15) %546, i8* nonnull align 8 dereferenceable(15) %93, i64 15, i1 false) #10
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %93) #10
  call void @llvm.taskframe.end(token %tf.i)
  call void @__csan_task_exit(i64 %5, i64 %3, i64 %1, i8 0, i64 1)
  reattach within %syncreg, label %pfor.inc

pfor.inc:                                         ; preds = %"_ZZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmENKUlmE_clEm.exit", %pfor.cond
  call void @__csan_detach_continue(i64 %7, i64 %1)
  %inc = add nuw i64 %__begin.0, 1
  %exitcond = icmp eq i64 %inc, %end
  br i1 %exitcond, label %pfor.cond.cleanup, label %pfor.cond, !llvm.loop !40

pfor.cond.cleanup:                                ; preds = %pfor.inc
  call void @__csan_after_loop(i64 %17, i8 0, i64 1)
  %553 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !2
  %554 = add i64 %553, 58
  call void @__csan_sync(i64 %554, i8 0)
  sync within %syncreg, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg)
          to label %sync.continue23 unwind label %csi.cleanup

sync.continue23:                                  ; preds = %sync.continue, %entry
  %555 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %556 = add i64 %555, 136
  call void @__csan_func_exit(i64 %556, i64 %9, i64 1)
  ret void

csi.cleanup:                                      ; preds = %sync.continue
  %csi.cleanup.lpad = landingpad { i8*, i32 }
          cleanup
  %557 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %558 = add i64 %557, 137
  call void @__csan_func_exit(i64 %558, i64 %9, i64 3)
  resume { i8*, i32 } %csi.cleanup.lpad
}

; CHECK-LABEL: define {{.*}}void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb.outline_pfor.body.i.i.i.i.i.otd2"(
; CHECK: lpad.i9.i.i.i.otd2:
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: landingpad


; CHECK-LABEL: define {{.*}}void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb.outline_pfor.body.i.i.1.i.i.i.otd2"(
; CHECK: lpad.i9.i.i.i.otd2:
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: landingpad


; CHECK-LABEL: define {{.*}}void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb.outline_pfor.body.i.i.2.i.i.i.otd2"(
; CHECK: lpad.i9.i.i.i.otd2:
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: landingpad


; CHECK-LABEL: define {{.*}}void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb.outline_pfor.body.i.i.3.i.i.i.otd2"(
; CHECK: lpad.i9.i.i.i.otd2:
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: phi i64
; CHECK-NEXT: landingpad


; CHECK-LABEL: define {{.*}}void @"_ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_3mapIRKNS1_ISt4pairIS4_mENS2_ISA_EEEEZ21writeHistogramsToFileSC_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSI_NS6_18_from_function_tagEmEUlmE_EEvmmSH_mb.outline_pfor.body.tf.tf.tf.tf.otf1"(
; CHECK: lpad.i.loopexit.split-lp.i.i.i.csi-split.csi-split.otf1:
; CHECK-NEXT: %[[DETCONT_ID:.+]] = phi i64 [ %{{.+}}, %pfor.inc.i.i.2.i.i.i.otf1.split ], [ %{{.+}}, %pfor.inc.i.i.1.i.i.i.otf1.split ], [ %{{.+}}, %pfor.inc.i.i.i.i.i.otf1.split ], [ %{{.+}}, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i.otf1.split ]
; CHECK-NEXT: %[[DETACH_ID:.+]] = phi i64 [ %{{.+}}, %pfor.inc.i.i.2.i.i.i.otf1.split ], [ %{{.+}}, %pfor.inc.i.i.1.i.i.i.otf1.split ], [ %{{.+}}, %pfor.inc.i.i.i.i.i.otf1.split ], [ %{{.+}}, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.i.i.i.otf1.split ]
; CHECK-NEXT: landingpad

; CHECK: @__csan_detach_continue(i64 %[[DETCONT_ID]], i64 %[[DETACH_ID]]

; Function Attrs: inlinehint uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb(i64, i64, %class.anon.92* byval(%class.anon.92) align 8, i64, i1 zeroext) local_unnamed_addr #0

; Function Attrs: nounwind uwtable
declare dso_local void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEED2Ev(%"struct.parlay::_sequence_base.3"*) unnamed_addr #1

; Function Attrs: uwtable
declare dso_local void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* dereferenceable(15)) unnamed_addr #2

; Function Attrs: uwtable
declare dso_local void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"*, i8*, i64) local_unnamed_addr #2

; Function Attrs: uwtable
declare dso_local void @_ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_(%"class.parlay::sequence"* noalias sret, %"class.parlay::sequence.2"* dereferenceable(15)) local_unnamed_addr #2

; Function Attrs: inlinehint uwtable
declare dso_local dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv() local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local i8* @_ZN6parlay9allocatorISt4byteE8allocateEm(%"struct.parlay::allocator.35"*, i64) local_unnamed_addr #2

; Function Attrs: noinline noreturn nounwind
declare hidden void @__clang_call_terminate(i8*) local_unnamed_addr #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #4

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #4

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #4

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #4

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #5

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #4

; Function Attrs: nofree nounwind
declare dso_local i32 @snprintf(i8* noalias nocapture, i64, i8* nocapture readonly, ...) local_unnamed_addr #6

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #5

; Function Attrs: nounwind willreturn
declare void @llvm.assume(i1) #7

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #4

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csi_after_alloca(i64, i8* nocapture readnone, i64, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_func_entry(i64, i8* nocapture readnone, i8* nocapture readnone, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_func_exit(i64, i64, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_load(i64, i8* nocapture readnone, i32, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_store(i64, i8* nocapture readnone, i32, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_large_load(i64, i8* nocapture readnone, i64, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_large_store(i64, i8* nocapture readnone, i64, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_before_call(i64, i64, i8, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_after_call(i64, i64, i8, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_detach(i64, i8) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_task(i64, i64, i8* nocapture readnone, i8* nocapture readnone, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_task_exit(i64, i64, i64, i8, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_detach_continue(i64, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_sync(i64, i8) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__cilksan_disable_checking() #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_get_MAAP(i8* nocapture, i64, i8) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_set_MAAP(i8, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_before_loop(i64, i64, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_after_loop(i64, i8, i64) #8

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #9

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #10

; Function Attrs: nounwind willreturn
declare i8* @llvm.task.frameaddress(i32) #7

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_snprintf(i64, i64, i8, i64, i32, i8*, i64, i8*, ...) #8

attributes #0 = { inlinehint uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline noreturn nounwind }
attributes #4 = { argmemonly nounwind willreturn }
attributes #5 = { argmemonly willreturn }
attributes #6 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nounwind willreturn }
attributes #8 = { inaccessiblemem_or_argmemonly nounwind }
attributes #9 = { nounwind readnone }
attributes #10 = { nounwind }
attributes #11 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git fffc5516029927e6f93460fb66ad35b34f9b0b9b)"}
!2 = !{}
!3 = !{!4, !5, i64 8}
!4 = !{!"_ZTSZN6parlay8sequenceINS0_IcNS_9allocatorIcEEEENS1_IS3_EEEC1IRZNS_3mapIRKNS0_ISt4pairIS3_mENS1_IS9_EEEEZ21writeHistogramsToFileSB_PcE3$_1EEDaOT_OT0_mEUlmE_EEmSH_NS5_18_from_function_tagEmEUlmE_", !5, i64 0, !5, i64 8, !5, i64 16}
!5 = !{!"any pointer", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
!8 = !{!5, !5, i64 0}
!9 = !{!4, !5, i64 16}
!10 = !{!11, !5, i64 0}
!11 = !{!"_ZTSZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_mEUlmE_", !5, i64 0, !5, i64 8}
!12 = !{!13}
!13 = distinct !{!13, !14, !"_ZZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_mENKUlmE_clEm: %agg.result"}
!14 = distinct !{!14, !"_ZZN6parlay3mapIRKNS_8sequenceISt4pairINS1_IcNS_9allocatorIcEEEEmENS3_IS6_EEEEZ21writeHistogramsToFileS8_PcE3$_1EEDaOT_OT0_mENKUlmE_clEm"}
!15 = !{!11, !5, i64 8}
!16 = !{!17, !19, i64 16}
!17 = !{!"_ZTSSt4pairIN6parlay8sequenceIcNS0_9allocatorIcEEEEmE", !18, i64 0, !19, i64 16}
!18 = !{!"_ZTSN6parlay8sequenceIcNS_9allocatorIcEEEE"}
!19 = !{!"long", !6, i64 0}
!20 = !{!21, !13}
!21 = distinct !{!21, !22, !"_ZZ21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPcENK3$_1clES5_: %agg.result"}
!22 = distinct !{!22, !"_ZZ21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPcENK3$_1clES5_"}
!23 = !{!24, !5, i64 0}
!24 = !{!"_ZTSZ21writeHistogramsToFileN6parlay8sequenceISt4pairINS0_IcNS_9allocatorIcEEEEmENS2_IS5_EEEEPcE3$_1", !5, i64 0, !5, i64 8}
!25 = !{!26, !21, !13}
!26 = distinct !{!26, !27, !"_ZN6parlay8to_charsEm: %agg.result"}
!27 = distinct !{!27, !"_ZN6parlay8to_charsEm"}
!28 = !{!26}
!29 = !{!30, !19, i64 0}
!30 = !{!"_ZTSN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl18capacitated_buffer6headerE", !19, i64 0, !6, i64 8}
!31 = !{i64 0, i64 8, !8, i64 8, i64 8, !32}
!32 = !{!19, !19, i64 0}
!33 = !{!34, !5, i64 0}
!34 = !{!"_ZTSZN6parlay8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S6_St26random_access_iterator_tagEUlmE_", !5, i64 0, !5, i64 8, !5, i64 16}
!35 = !{!36, !5, i64 0}
!36 = !{!"_ZTSN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl18capacitated_bufferE", !5, i64 0}
!37 = !{!24, !5, i64 8}
!38 = !{!39, !19, i64 0}
!39 = !{!"_ZTSN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl18capacitated_buffer6headerE", !19, i64 0, !6, i64 8}
!40 = distinct !{!40, !41}
!41 = !{!"tapir.loop.spawn.strategy", i32 1}
