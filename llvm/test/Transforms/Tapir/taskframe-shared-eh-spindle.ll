; Check that Tapir lowering properly handles shared EH spindles when
; computing taskframe inputs.
;
; RUN: opt < %s -tapir2target -use-opencilk-runtime-bc=false -S -o - | FileCheck %s
; RUN: opt < %s -passes='tapir2target' -use-opencilk-runtime-bc=false -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i64, %union.anon.1 }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider" = type { i8* }
%union.anon.1 = type { i64, [8 x i8] }
%"class.parlay::sequence" = type { %"struct.parlay::_sequence_base" }
%"struct.parlay::_sequence_base" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::_data_impl" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::_data_impl" = type { %union.anon, i8 }
%union.anon = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::long_seq" }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::long_seq" = type <{ %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer", [6 x i8] }>
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer" = type { %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* }
%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header" = type <{ i64, %union.anon.29, [7 x i8] }>
%union.anon.29 = type { [1 x i8] }
%"struct.std::pair.7" = type { i32, i32 }
%class.anon.332 = type { %"class.parlay::sequence"*, i8**, i8** }
%class.anon.413 = type { %"class.std::__cxx11::basic_string"* }
%"class.parlay::sequence.2" = type { %"struct.parlay::_sequence_base.3" }
%"struct.parlay::_sequence_base.3" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::_data_impl" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::_data_impl" = type { %union.anon.6, i8 }
%union.anon.6 = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::long_seq" }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::long_seq" = type <{ %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer", [6 x i8] }>
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer" = type { %"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer::header"* }
%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl::capacitated_buffer::header" = type <{ i64, %union.anon.30, [7 x i8] }>
%union.anon.30 = type { [1 x i8] }
%"struct.parlay::pool_allocator" = type { i64, i64, i64, i64, %"struct.std::atomic", %"struct.std::atomic", %"class.std::unique_ptr", %"struct.parlay::block_allocator"*, %"class.std::vector", i64 }
%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"struct.std::__atomic_base" = type { i64 }
%"class.std::unique_ptr" = type { %"struct.std::__uniq_ptr_data" }
%"struct.std::__uniq_ptr_data" = type { %"class.std::__uniq_ptr_impl" }
%"class.std::__uniq_ptr_impl" = type { %"class.std::tuple" }
%"class.std::tuple" = type { %"struct.std::_Tuple_impl" }
%"struct.std::_Tuple_impl" = type { %"struct.std::_Head_base.34" }
%"struct.std::_Head_base.34" = type { %"class.parlay::concurrent_stack"* }
%"class.parlay::concurrent_stack" = type { %"class.parlay::concurrent_stack<void *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<void *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<void *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<void *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<void *>::Node" = type { i8*, %"struct.parlay::concurrent_stack<void *>::Node"*, i64 }
%"class.std::mutex" = type { %"class.std::__mutex_base" }
%"class.std::__mutex_base" = type { %union.pthread_mutex_t }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%"struct.parlay::block_allocator" = type { i8, [63 x i8], %"class.parlay::concurrent_stack.35", %"class.parlay::concurrent_stack.36", %"struct.parlay::block_allocator::thread_list"*, i64, i64, i64, %"struct.std::atomic", i64, [16 x i8] }
%"class.parlay::concurrent_stack.35" = type { %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<char *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<char *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<char *>::Node" = type { i8*, %"struct.parlay::concurrent_stack<char *>::Node"*, i64 }
%"class.parlay::concurrent_stack.36" = type { %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack", %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack" }
%"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack" = type { %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node"*, %"class.std::mutex", [16 x i8] }
%"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node" = type { %"struct.parlay::block_allocator::block"*, %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node"*, i64 }
%"struct.parlay::block_allocator::block" = type { %"struct.parlay::block_allocator::block"* }
%"struct.parlay::block_allocator::thread_list" = type { i64, %"struct.parlay::block_allocator::block"*, %"struct.parlay::block_allocator::block"*, [256 x i8], [40 x i8] }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl_data" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl_data" = type { i64*, i64*, i64* }

$_ZN6parlay8to_charsIjjEENS_8sequenceIcNS_9allocatorIcEEEERKSt4pairIT_T0_E = comdat any

@_ZN7benchIO11intHeaderIOB5cxx11E = dso_local global %"class.std::__cxx11::basic_string" zeroinitializer, align 8
@.str.29 = private unnamed_addr constant [4 x i8] c"%lu\00", align 1
@__csi_unit_func_base_id = internal global i64 0
@__csi_unit_func_exit_base_id = internal global i64 0
@__csi_unit_callsite_base_id = internal global i64 0
@__csi_unit_load_base_id = internal global i64 0
@__csi_unit_store_base_id = internal global i64 0
@__csi_unit_alloca_base_id = internal global i64 0
@__csi_unit_detach_base_id = internal global i64 0
@__csi_unit_task_base_id = internal global i64 0
@__csi_unit_task_exit_base_id = internal global i64 0
@__csi_unit_detach_continue_base_id = internal global i64 0
@__csi_unit_sync_base_id = internal global i64 0
@__csi_unit_free_base_id = internal global i64 0
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
@__csi_func_id__ZN6parlay14pool_allocator14allocate_largeEm = weak global i64 -1
@__csi_func_id___cilkrts_get_worker_number = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE3popEv = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE15initialize_fillEmRKcEUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPvE4pushES1_ = weak global i64 -1
@__csi_func_id__ZN6parlay8internal21get_default_allocatorEv = weak global i64 -1
@__csi_func_id__ZN6parlay14pool_allocator8allocateEm = weak global i64 -1
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
@__csi_func_id__ZN6parlay8sequenceImNS_9allocatorImEEEC2Em = weak global i64 -1
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
@__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIlNS_9allocatorIlEEEENS2_IS4_EEED2Ev = weak global i64 -1
@__csi_func_id__ZN6parlay8internal5timer4nextENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = weak global i64 -1
@__csi_func_id__ZN6parlay8internal4scanINS_8sequenceImNS_9allocatorImEEEENS_4addmImEEEESt4pairINS2_INT_10value_typeENS3_ISA_EEEESA_ERKS9_T0_j = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseImNS_9allocatorImEEE14_sequence_implC2ERKS4_ = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEC1IRZNS_14map_tokens_oldIRKNS_8file_mapEZNS_6tokensIS9_N7benchIO3$_0EEES6_RKT_T0_EUlSF_E_SE_EEDaOSF_SI_T1_EUlmE0_EEmSK_NS6_18_from_function_tagEmEUlmE_EEvmmSF_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev = weak global i64 -1
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
@__csi_func_id_bcmp = weak global i64 -1
@__csi_func_id__ZN11commandLine9getOptionENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC1ERKS5_EUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE7compareEPKc = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_ = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIjNS_9allocatorIjEEEC1IRZN7benchIO13parseElementsIjNS_5sliceIPNS1_IcNS2_IcEEEESB_EEEENSt9enable_ifIXsr3std7is_sameIT_jEE5valueES4_E4typeERKT0_EUllE_EEmOSE_NS4_18_from_function_tagEmEUlmE_EEvmmSE_mb = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal10merge_intoINS_26uninitialized_relocate_tagEPjS3_S3_Z4mainE3$_1EEvNS_5sliceIT0_S6_EENS5_IT1_S8_EENS5_IT2_SA_EERKT3_b" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal11merge_sort_IPjS2_Z4mainE3$_1EEvNS_5sliceIT_S5_EENS4_IT0_S7_EERKT1_b" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal6split3IPjZ4mainE3$_1EESt5tupleIJT_S5_bEES5_mRKT0_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal16quicksort_serialIPjZ4mainE3$_1EEvT_mRKT0_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal9quicksortIPjZ4mainE3$_1EEvT_mRKT0_" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_26uninitialized_relocate_n_aIPjS2_SaIjEEEvT_T0_mRT1_EUlmE_EEvmmS4_mb = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal6split3IPmZNS0_11get_bucketsIPjZ4mainE3$_1EEbNS_5sliceIT_S7_EEPhT0_mEUlmmE_EESt5tupleIJS7_S7_bEES7_mRKSA_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal16quicksort_serialIPmZNS0_11get_bucketsIPjZ4mainE3$_1EEbNS_5sliceIT_S7_EEPhT0_mEUlmmE_EEvS7_mRKSA_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal9quicksortIPmZNS0_11get_bucketsIPjZ4mainE3$_1EEbNS_5sliceIT_S7_EEPhT0_mEUlmmE_EEvS7_mRKSA_" = weak global i64 -1
@__csi_func_id__ZN6parlay8internal16to_balanced_treeINS_15copy_assign_tagEPmS3_EEvT0_T1_mmm = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal13bucket_sort_rIPjS2_Z4mainE3$_1EEvNS_5sliceIT_S5_EENS4_IT0_S7_EET1_bb" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal13bucket_sort_rIPjS3_Z4mainE3$_1EEvNS_5sliceIT_S6_EENS5_IT0_S8_EET1_bbEUlmE_EEvmmS6_mb" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal16seq_sort_inplaceIPjZ4mainE3$_1EEvNS_5sliceIT_S5_EERKT0_b" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_12sample_sort_IjPKjPjZ4mainE3$_1EEvNS_5sliceIT0_S9_EENS8_IT1_SB_EERKT2_bEUlmmmE_EEvmmRKT_jEUlmE_EEvmmSH_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIjNS_9allocatorIjEEEC1IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS9_jEENS1_ImNS2_ImEEEET0_T1_RNS1_IT2_NS2_ISE_EEEEmmmmEUlmE_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSK_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIjNS_9allocatorIjEEE18initialize_defaultEmEUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPjS5_EES6_NS_4addmIjEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE_EEvmmSC_jEUlmE_EEvmmS9_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPjS5_EES6_NS_4addmIjEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE0_EEvmmSC_jEUlmE_EEvmmS9_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceIjNS_9allocatorIjEEEC2Em = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS4_jEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNS5_IT2_NS6_ISB_EEEEmmmmEUlmE0_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8internal9transposeINS_26uninitialized_relocate_tagEPjE6transREmmmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal10blockTransINS_26uninitialized_relocate_tagEPjS3_S3_S3_E6transREmmmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS9_jEES4_T0_T1_RNS1_IT2_NS2_ISC_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSH_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceIjNS_9allocatorIjEEEC2IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS8_jEENS0_ImNS1_ImEEEET0_T1_RNS0_IT2_NS1_ISD_EEEEmmmmEUlmE_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal5scan_INS_5sliceIPjS3_EES4_NS_4addmIjEEEENT_10value_typeERKS7_T0_RKT1_jb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceImNS_9allocatorImEEEC2IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS8_jEES3_T0_T1_RNS0_IT2_NS1_ISB_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal12sample_sort_IjPKjPjZ4mainE3$_1EEvNS_5sliceIT0_S8_EENS7_IT1_SA_EERKT2_bEUlmE1_EEvmmT_mb" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_12sample_sort_ImPKjPjZ4mainE3$_1EEvNS_5sliceIT0_S9_EENS8_IT1_SB_EERKT2_bEUlmmmE_EEvmmRKT_jEUlmE_EEvmmSH_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS9_mEES4_T0_T1_RNS1_IT2_NS2_ISC_EEEEmmmmEUlmE_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSI_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPmS5_EES6_NS_4addmImEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE_EEvmmSC_jEUlmE_EEvmmS9_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPmS5_EES6_NS_4addmImEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE0_EEvmmSC_jEUlmE_EEvmmS9_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS4_mEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNS5_IT2_NS6_ISB_EEEEmmmmEUlmE0_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8internal9transposeINS_26uninitialized_relocate_tagEPmE6transREmmmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal10blockTransINS_26uninitialized_relocate_tagEPjS3_PmS4_E6transREmmmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS9_mEES4_T0_T1_RNS1_IT2_NS2_ISC_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSH_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceImNS_9allocatorImEEEC2IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS8_mEES3_T0_T1_RNS0_IT2_NS1_ISB_EEEEmmmmEUlmE_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal5scan_INS_5sliceIPmS3_EES4_NS_4addmImEEEENT_10value_typeERKS7_T0_RKT1_jb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceImNS_9allocatorImEEEC2IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS8_mEES3_T0_T1_RNS0_IT2_NS1_ISB_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal12sample_sort_ImPKjPjZ4mainE3$_1EEvNS_5sliceIT0_S8_EENS7_IT1_SA_EERKT2_bEUlmE1_EEvmmT_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb = weak global i64 -1
@__csi_func_id__ZZN7benchIO13parseElementsISt4pairIjjEN6parlay5sliceIPNS3_8sequenceIcNS3_9allocatorIcEEEES9_EEEENSt9enable_ifIXsr3std7is_sameIT_S2_EE5valueENS5_IS2_NS6_IS2_EEEEE4typeERKT0_ENKUllE_clEl = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceISt4pairIjjENS_9allocatorIS3_EEEC1IRZN7benchIO13parseElementsIS3_NS_5sliceIPNS1_IcNS4_IcEEEESD_EEEENSt9enable_ifIXsr3std7is_sameIT_S3_EE5valueES6_E4typeERKT0_EUllE_EEmOSG_NS6_18_from_function_tagEmEUlmE_EEvmmSG_mb = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal10merge_intoINS_26uninitialized_relocate_tagEPSt4pairIjjES5_S5_Z4mainE3$_2EEvNS_5sliceIT0_S8_EENS7_IT1_SA_EENS7_IT2_SC_EERKT3_b" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal11merge_sort_IPSt4pairIjjES4_Z4mainE3$_2EEvNS_5sliceIT_S7_EENS6_IT0_S9_EERKT1_b" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal6split3IPSt4pairIjjEZ4mainE3$_2EESt5tupleIJT_S7_bEES7_mRKT0_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal16quicksort_serialIPSt4pairIjjEZ4mainE3$_2EEvT_mRKT0_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal9quicksortIPSt4pairIjjEZ4mainE3$_2EEvT_mRKT0_" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_26uninitialized_relocate_n_aIPSt4pairIjjES4_SaIS3_EEEvT_T0_mRT1_EUlmE_EEvmmS6_mb = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal6split3IPmZNS0_11get_bucketsIPSt4pairIjjEZ4mainE3$_2EEbNS_5sliceIT_S9_EEPhT0_mEUlmmE_EESt5tupleIJS9_S9_bEES9_mRKSC_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal16quicksort_serialIPmZNS0_11get_bucketsIPSt4pairIjjEZ4mainE3$_2EEbNS_5sliceIT_S9_EEPhT0_mEUlmmE_EEvS9_mRKSC_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal9quicksortIPmZNS0_11get_bucketsIPSt4pairIjjEZ4mainE3$_2EEbNS_5sliceIT_S9_EEPhT0_mEUlmmE_EEvS9_mRKSC_" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal13bucket_sort_rIPSt4pairIjjES4_Z4mainE3$_2EEvNS_5sliceIT_S7_EENS6_IT0_S9_EET1_bb" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal13bucket_sort_rIPSt4pairIjjES5_Z4mainE3$_2EEvNS_5sliceIT_S8_EENS7_IT0_SA_EET1_bbEUlmE_EEvmmS8_mb" = weak global i64 -1
@"__csi_func_id__ZN6parlay8internal16seq_sort_inplaceIPSt4pairIjjEZ4mainE3$_2EEvNS_5sliceIT_S7_EERKT0_b" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_12sample_sort_IjPKSt4pairIjjEPS5_Z4mainE3$_2EEvNS_5sliceIT0_SB_EENSA_IT1_SD_EERKT2_bEUlmmmE_EEvmmRKT_jEUlmE_EEvmmSJ_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIjNS_9allocatorIjEEEC1IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjESB_jEENS1_ImNS2_ImEEEET0_T1_RNS1_IT2_NS2_ISG_EEEEmmmmEUlmE_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSM_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjES6_jEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNS7_IT2_NS8_ISD_EEEEmmmmEUlmE0_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8internal10blockTransINS_26uninitialized_relocate_tagEPSt4pairIjjES5_PjS6_E6transREmmmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjESB_jEES4_T0_T1_RNS1_IT2_NS2_ISE_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSJ_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceIjNS_9allocatorIjEEEC2IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjESA_jEENS0_ImNS1_ImEEEET0_T1_RNS0_IT2_NS1_ISF_EEEEmmmmEUlmE_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceImNS_9allocatorImEEEC2IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjESA_jEES3_T0_T1_RNS0_IT2_NS1_ISD_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal12sample_sort_IjPKSt4pairIjjEPS4_Z4mainE3$_2EEvNS_5sliceIT0_SA_EENS9_IT1_SC_EERKT2_bEUlmE1_EEvmmT_mb" = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_12sample_sort_ImPKSt4pairIjjEPS5_Z4mainE3$_2EEvNS_5sliceIT0_SB_EENSA_IT1_SD_EERKT2_bEUlmmmE_EEvmmRKT_jEUlmE_EEvmmSJ_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjESB_mEES4_T0_T1_RNS1_IT2_NS2_ISE_EEEEmmmmEUlmE_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSK_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjES6_mEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNS7_IT2_NS8_ISD_EEEEmmmmEUlmE0_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8internal10blockTransINS_26uninitialized_relocate_tagEPSt4pairIjjES5_PmS6_E6transREmmmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjESB_mEES4_T0_T1_RNS1_IT2_NS2_ISE_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSJ_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceImNS_9allocatorImEEEC2IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjESA_mEES3_T0_T1_RNS0_IT2_NS1_ISD_EEEEmmmmEUlmE_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceImNS_9allocatorImEEEC2IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjESA_mEES3_T0_T1_RNS0_IT2_NS1_ISD_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@"__csi_func_id__ZN6parlay12parallel_forIZNS_8internal12sample_sort_ImPKSt4pairIjjEPS4_Z4mainE3$_2EEvNS_5sliceIT0_SA_EENS9_IT1_SC_EERKT2_bEUlmE1_EEvmmT_mb" = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEEC1IRZNS_8to_charsERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEEUlmE_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSG_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIlNS_9allocatorIlEEEC1IRZNS_7flattenINS1_INS1_IcNS2_IcEEEENS2_IS8_EEEEEEDaRKT_EUlmE_EEmOSB_NS4_18_from_function_tagEmEUlmE_EEvmmSB_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIlNS_9allocatorIlEEE18initialize_defaultEmEUlmE_EEvmmT_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPlS5_EES6_NS_4addmImEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE_EEvmmSC_jEUlmE_EEvmmS9_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPlS5_EES6_NS_4addmImEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE0_EEvmmSC_jEUlmE_EEvmmS9_mb = weak global i64 -1
@__csi_func_id__ZN6parlay12parallel_forIZZNS_7flattenINS_8sequenceINS2_IcNS_9allocatorIcEEEENS3_IS5_EEEEEEDaRKT_ENKUlmE0_clEmEUlmE_EEvmmS8_mb = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceIlNS_9allocatorIlEEEC2IRZNS_7flattenINS0_INS0_IcNS1_IcEEEENS1_IS7_EEEEEEDaRKT_EUlmE_EEmOSA_NS3_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal5scan_INS_5sliceIPlS3_EES4_NS_4addmImEEEENT_10value_typeERKS7_T0_RKT1_jb = weak global i64 -1
@__csi_func_id_snprintf = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceIcNS_9allocatorIcEEEC2IRZNS_8to_charsERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEEUlmE_EEmOT_NS3_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_ = weak global i64 -1
@__csi_func_id_sqrt = weak global i64 -1
@__csi_func_id__ZN11commandLineC2EiPPcNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = weak global i64 -1
@__csi_func_id__ZN7benchIO10get_tokensEPKc = weak global i64 -1
@__csi_func_id__ZN7benchIO21elementTypeFromHeaderIN6parlay8sequenceIcNS1_9allocatorIcEEEEEENS_11elementTypeET_ = weak global i64 -1
@__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implC2ERKS7_ = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceIjNS_9allocatorIjEEEC2IRZN7benchIO13parseElementsIjNS_5sliceIPNS0_IcNS1_IcEEEESA_EEEENSt9enable_ifIXsr3std7is_sameIT_jEE5valueES3_E4typeERKT0_EUllE_EEmOSD_NS3_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS3_jEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNS4_IT2_NS5_ISA_EEEEmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPjS3_mEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNS4_IT2_NS5_ISA_EEEEmmmm = weak global i64 -1
@__csi_func_id__ZNSo9_M_insertImEERSoT_ = weak global i64 -1
@__csi_func_id__ZNSo5writeEPKcl = weak global i64 -1
@__csi_func_id__ZN6parlay8sequenceISt4pairIjjENS_9allocatorIS2_EEEC2IRZN7benchIO13parseElementsIS2_NS_5sliceIPNS0_IcNS3_IcEEEESC_EEEENSt9enable_ifIXsr3std7is_sameIT_S2_EE5valueES5_E4typeERKT0_EUllE_EEmOSF_NS5_18_from_function_tagEm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjES5_jEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNS6_IT2_NS7_ISC_EEEEmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairIjjES5_mEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNS6_IT2_NS7_ISC_EEEEmmmm = weak global i64 -1
@__csi_func_id__ZN6parlay8to_charsIjjEENS_8sequenceIcNS_9allocatorIcEEEERKSt4pairIT_T0_E = weak global i64 -1
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
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIjjE = weak global i64 -1
@__csi_func_id_main = weak global i64 -1
@__csi_func_id__ZN7benchIO18readStringFromFileEPKc = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIN6parlay8sequenceIcNS1_9allocatorIcEEEElE = weak global i64 -1
@__csi_func_id__ZN6parlay16concurrent_stackIPcED2Ev = weak global i64 -1
@__csi_func_id__ZN7benchIO8dataTypeESt4pairIjiE = weak global i64 -1
@__csi_func_id__ZNSt10unique_ptrIA_N6parlay16concurrent_stackIPvEESt14default_deleteIS4_EED2Ev = weak global i64 -1
@__csi_func_id__ZNSt6vectorImSaImEED2Ev = weak global i64 -1

; Function Attrs: uwtable
define dso_local void @_ZN6parlay8to_charsIjjEENS_8sequenceIcNS_9allocatorIcEEEERKSt4pairIT_T0_E(%"class.parlay::sequence"* noalias sret %agg.result, %"struct.std::pair.7"* dereferenceable(8) %P) local_unnamed_addr #0 comdat personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i:
  %0 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !2
  %1 = add i64 %0, 159
  %2 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !2
  %3 = add i64 %2, 159
  %4 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !2
  %5 = add i64 %4, 227
  %6 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !2
  %7 = add i64 %6, 227
  %8 = add i64 %6, 223
  %9 = add i64 %0, 158
  %10 = add i64 %2, 158
  %11 = add i64 %4, 226
  %12 = add i64 %6, 226
  %13 = add i64 %0, 157
  %14 = add i64 %2, 157
  %15 = add i64 %4, 225
  %16 = add i64 %6, 225
  %17 = add i64 %0, 156
  %18 = add i64 %2, 156
  %19 = add i64 %4, 224
  %20 = add i64 %6, 224
  %21 = add i64 %0, 155
  %22 = add i64 %2, 155
  %23 = add i64 %4, 222
  %24 = add i64 %6, 222
  %25 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !2
  %26 = add i64 %25, 158
  %27 = call i8* @llvm.frameaddress.p0i8(i32 0)
  %28 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %26, i8* %27, i8* %28, i64 257)
  %29 = alloca i8, align 1
  call void @__csan_get_MAAP(i8* nonnull %29, i64 %26, i8 0)
  %30 = load i8, i8* %29, align 1
  %31 = or i8 %30, 4
  store i8 %31, i8* %29, align 1
  %32 = alloca i8, align 1
  call void @__csan_get_MAAP(i8* nonnull %32, i64 %26, i8 1)
  %33 = load i8, i8* %32, align 1
  %syncreg19.i.i = tail call token @llvm.syncregion.start()
  %34 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !2
  %35 = add i64 %34, 370
  %first.addr.i70 = alloca i8*, align 8
  %36 = bitcast i8** %first.addr.i70 to i8*
  call void @__csi_after_alloca(i64 %35, i8* nonnull %36, i64 8, i64 1)
  %37 = add i64 %34, 365
  %buffer.i71 = alloca i8*, align 8
  %38 = bitcast i8** %buffer.i71 to i8*
  call void @__csi_after_alloca(i64 %37, i8* nonnull %38, i64 8, i64 1)
  %39 = add i64 %34, 369
  %agg.tmp.i72 = alloca %class.anon.332, align 8
  %40 = bitcast %class.anon.332* %agg.tmp.i72 to i8*
  call void @__csi_after_alloca(i64 %39, i8* nonnull %40, i64 24, i64 1)
  %41 = add i64 %34, 366
  %ref.tmp.i = alloca %class.anon.413, align 8
  %42 = bitcast %class.anon.413* %ref.tmp.i to i8*
  call void @__csi_after_alloca(i64 %41, i8* nonnull %42, i64 8, i64 1)
  %43 = add i64 %34, 364
  %first.addr.i = alloca i8*, align 8
  %44 = bitcast i8** %first.addr.i to i8*
  call void @__csi_after_alloca(i64 %43, i8* nonnull %44, i64 8, i64 1)
  %45 = add i64 %34, 371
  %buffer.i = alloca i8*, align 8
  %46 = bitcast i8** %buffer.i to i8*
  call void @__csi_after_alloca(i64 %45, i8* nonnull %46, i64 8, i64 1)
  %47 = add i64 %34, 372
  %agg.tmp.i = alloca %class.anon.332, align 8
  %48 = bitcast %class.anon.332* %agg.tmp.i to i8*
  call void @__csi_after_alloca(i64 %47, i8* nonnull %48, i64 24, i64 1)
  %49 = add i64 %34, 373
  %s.i.i = alloca [22 x i8], align 16
  %50 = getelementptr inbounds [22 x i8], [22 x i8]* %s.i.i, i64 0, i64 0
  call void @__csi_after_alloca(i64 %49, i8* nonnull %50, i64 22, i64 1)
  %51 = add i64 %34, 368
  %s = alloca %"class.parlay::sequence.2", align 8
  %52 = bitcast %"class.parlay::sequence.2"* %s to i8*
  call void @__csi_after_alloca(i64 %51, i8* nonnull %52, i64 15, i64 1)
  %53 = add i64 %34, 363
  %ref.tmp = alloca [5 x %"class.parlay::sequence"], align 8
  %54 = bitcast [5 x %"class.parlay::sequence"]* %ref.tmp to i8*
  call void @__csi_after_alloca(i64 %53, i8* nonnull %54, i64 75, i64 1)
  %55 = add i64 %34, 367
  %ref.tmp3 = alloca %"class.std::__cxx11::basic_string", align 8
  %56 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp3 to i8*
  call void @__csi_after_alloca(i64 %55, i8* nonnull %56, i64 32, i64 1)
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %52) #10
  call void @llvm.lifetime.start.p0i8(i64 75, i8* nonnull %54) #10
  %small_n.i.i.i.i = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 40, i8* %54, align 8, !tbaa !3
  %arrayinit.begin = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 0
  store i8 1, i8* %small_n.i.i.i.i, align 2
  %arrayinit.element.ptr = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 1
  %first = getelementptr inbounds %"struct.std::pair.7", %"struct.std::pair.7"* %P, i64 0, i32 0
  %57 = and i8 %33, 1
  %58 = icmp eq i8 %57, 0
  br i1 %58, label %63, label %59

59:                                               ; preds = %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i
  %60 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %61 = add i64 %60, 2697
  %62 = bitcast %"struct.std::pair.7"* %P to i8*
  call void @__csan_load(i64 %61, i8* nonnull %62, i32 4, i64 4)
  br label %63

63:                                               ; preds = %59, %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i
  %64 = load i32, i32* %first, align 4, !tbaa !6
  %conv.i = zext i32 %64 to i64
  call void @llvm.lifetime.start.p0i8(i64 22, i8* nonnull %50) #10, !noalias !9
  %65 = load i64, i64* @__csi_func_id_snprintf, align 8
  call void @__csan_set_MAAP(i8 4, i64 %65)
  call void @__csan_set_MAAP(i8 4, i64 %65)
  %66 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !invariant.load !2
  %67 = add i64 %66, 824
  %call.i.i = call i32 (i8*, i64, i8*, ...) @snprintf(i8* nonnull %50, i64 21, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.29, i64 0, i64 0), i64 %conv.i) #10, !noalias !9
  call void (i64, i64, i8, i64, i32, i8*, i64, i8*, ...) @__csan_snprintf(i64 %67, i64 %65, i8 2, i64 0, i32 %call.i.i, i8* nonnull %50, i64 21, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.29, i64 0, i64 0), i64 %conv.i)
  %cmp.i.i.i = icmp slt i32 %call.i.i, 20
  %.sroa.speculated.i.i = select i1 %cmp.i.i.i, i32 %call.i.i, i32 20
  %idx.ext.i.i = sext i32 %.sroa.speculated.i.i to i64
  %small_n.i.i.i.i.i.i = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 1, i32 0, i32 0, i32 0, i32 1
  store i8 0, i8* %small_n.i.i.i.i.i.i, align 1, !alias.scope !9
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %44)
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %48)
  store i8* %50, i8** %first.addr.i, align 8, !tbaa !14
  %cmp.i.i = icmp ugt i32 %.sroa.speculated.i.i, 13
  br i1 %cmp.i.i, label %if.then.i11.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread: ; preds = %63
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %46) #10
  br label %if.then.i15.i

if.then.i11.i:                                    ; preds = %63
  store i8 -128, i8* %small_n.i.i.i.i.i.i, align 1
  %68 = add i64 %66, 826
  %69 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %68, i64 %69, i8 0, i64 0)
  %call.i.i.i.i.i.i43 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.i.noexc unwind label %lpad.i.i.i38

call.i.i.i.i.i.i.noexc:                           ; preds = %if.then.i11.i
  call void @__csan_after_call(i64 %68, i64 %69, i8 0, i64 0)
  %add.i.i.i.i = add nsw i64 %idx.ext.i.i, 8
  %70 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator8allocateEm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %70)
  %71 = add i64 %66, 827
  call void @__csan_before_call(i64 %71, i64 %70, i8 1, i64 0)
  %call2.i.i.i.i.i.i44 = invoke i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i.i43, i64 %add.i.i.i.i)
          to label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i unwind label %lpad.i.i.i38

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i: ; preds = %call.i.i.i.i.i.i.noexc
  call void @__csan_after_call(i64 %71, i64 %70, i8 1, i64 0)
  %capacity.i.i.i5.i.i = bitcast i8* %call2.i.i.i.i.i.i44 to i64*
  %72 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %73 = add i64 %72, 1265
  call void @__csan_store(i64 %73, i8* %call2.i.i.i.i.i.i44, i32 8, i64 8)
  store i64 %idx.ext.i.i, i64* %capacity.i.i.i5.i.i, align 8, !tbaa !16
  %74 = bitcast %"class.parlay::sequence"* %arrayinit.element.ptr to i8**
  store i8* %call2.i.i.i.i.i.i44, i8** %74, align 1, !tbaa.struct !19
  %ref.tmp.sroa.4.0..sroa_idx7.i.i = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast8.i.i = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx7.i.i to i48*
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast8.i.i, align 1, !tbaa.struct !19
  %bf.load.i.i13.pre.i = load i8, i8* %small_n.i.i.i.i.i.i, align 1
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %46) #10
  %cmp.i.i14.i = icmp sgt i8 %bf.load.i.i13.pre.i, -1
  br i1 %cmp.i.i14.i, label %if.then.i15.i, label %if.else.i16.i

if.then.i15.i:                                    ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i.thread
  %75 = bitcast %"class.parlay::sequence"* %arrayinit.element.ptr to i8*
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i

if.else.i16.i:                                    ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i
  %76 = getelementptr inbounds i8, i8* %call2.i.i.i.i.i.i44, i64 8
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i: ; preds = %if.else.i16.i, %if.then.i15.i
  %retval.0.i.i = phi i8* [ %75, %if.then.i15.i ], [ %76, %if.else.i16.i ]
  store i8* %retval.0.i.i, i8** %buffer.i, align 8, !tbaa !14
  %77 = getelementptr inbounds %class.anon.332, %class.anon.332* %agg.tmp.i, i64 0, i32 0
  store %"class.parlay::sequence"* %arrayinit.element.ptr, %"class.parlay::sequence"** %77, align 8, !tbaa !21
  %78 = getelementptr inbounds %class.anon.332, %class.anon.332* %agg.tmp.i, i64 0, i32 1
  store i8** %buffer.i, i8*** %78, align 8, !tbaa !14
  %79 = getelementptr inbounds %class.anon.332, %class.anon.332* %agg.tmp.i, i64 0, i32 2
  store i8** %first.addr.i, i8*** %79, align 8, !tbaa !14
  %80 = load i64, i64* @__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb, align 8
  call void @__csan_set_MAAP(i8 4, i64 %80)
  %81 = add i64 %66, 828
  call void @__csan_before_call(i64 %81, i64 %80, i8 1, i64 0)
  invoke void @_ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb(i64 0, i64 %idx.ext.i.i, %class.anon.332* nonnull byval(%class.anon.332) align 8 %agg.tmp.i, i64 8193, i1 zeroext false)
          to label %.noexc unwind label %lpad.i.i.i38

.noexc:                                           ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i
  call void @__csan_after_call(i64 %81, i64 %80, i8 1, i64 0)
  %bf.load.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i, align 1
  %cmp.i.i.i42 = icmp sgt i8 %bf.load.i.i.i, -1
  br i1 %cmp.i.i.i42, label %if.then.i.i, label %if.else.i.i

if.then.i.i:                                      ; preds = %.noexc
  %conv.i.i = trunc i32 %.sroa.speculated.i.i to i8
  %bf.value.i.i = and i8 %conv.i.i, 127
  %bf.clear.i.i = and i8 %bf.load.i.i.i, -128
  %bf.set.i.i = or i8 %bf.clear.i.i, %bf.value.i.i
  store i8 %bf.set.i.i, i8* %small_n.i.i.i.i.i.i, align 1
  br label %invoke.cont1

if.else.i.i:                                      ; preds = %.noexc
  %n.i.i.i = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %82 = bitcast [6 x i8]* %n.i.i.i to i48*
  %83 = sext i32 %.sroa.speculated.i.i to i48
  store i48 %83, i48* %82, align 1
  br label %invoke.cont1

lpad.i.i.i38:                                     ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i, %call.i.i.i.i.i.i.noexc, %if.then.i11.i
  %84 = phi i64 [ %81, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i ], [ %71, %call.i.i.i.i.i.i.noexc ], [ %68, %if.then.i11.i ]
  %85 = phi i64 [ %80, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i ], [ %70, %call.i.i.i.i.i.i.noexc ], [ %69, %if.then.i11.i ]
  %86 = phi i8 [ 1, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i ], [ 1, %call.i.i.i.i.i.i.noexc ], [ 0, %if.then.i11.i ]
  %87 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %84, i64 %85, i8 %86, i64 0)
  %bf.load.i.i.i.i.i.i.i = load i8, i8* %small_n.i.i.i.i.i.i, align 1, !alias.scope !9
  %cmp.i.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i.i, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i, label %if.then.i.i.i.i.i.i

if.then.i.i.i.i.i.i:                              ; preds = %lpad.i.i.i38
  %buffer.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arrayinit.element.ptr, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %88 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i, align 1, !tbaa !23, !alias.scope !9
  %capacity.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %88, i64 0, i32 0
  %89 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %90 = add i64 %89, 2684
  %91 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %88 to i8*
  call void @__csan_load(i64 %90, i8* %91, i32 8, i64 8)
  %92 = load i64, i64* %capacity.i.i.i.i.i.i.i.i, align 8, !tbaa !16
  %93 = add i64 %66, 829
  %94 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %93, i64 %94, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i.i.i unwind label %lpad.i.i.i.i.i

call.i.i.i.i.i.noexc.i.i.i.i.i:                   ; preds = %if.then.i.i.i.i.i.i
  call void @__csan_after_call(i64 %93, i64 %94, i8 0, i64 0)
  %add.i.i.i.i.i.i.i.i = add i64 %92, 8
  %95 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %95)
  call void @__csan_set_MAAP(i8 3, i64 %95)
  %96 = add i64 %66, 830
  call void @__csan_before_call(i64 %96, i64 %95, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i.i.i.i, i8* %91, i64 %add.i.i.i.i.i.i.i.i)
          to label %.noexc.i.i.i.i.i unwind label %lpad.i.i.i.i.i

.noexc.i.i.i.i.i:                                 ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i
  call void @__csan_after_call(i64 %96, i64 %95, i8 2, i64 0)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i, align 1, !tbaa !23, !alias.scope !9
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i

lpad.i.i.i.i.i:                                   ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i, %if.then.i.i.i.i.i.i
  %97 = phi i64 [ %96, %call.i.i.i.i.i.noexc.i.i.i.i.i ], [ %93, %if.then.i.i.i.i.i.i ]
  %98 = phi i64 [ %95, %call.i.i.i.i.i.noexc.i.i.i.i.i ], [ %94, %if.then.i.i.i.i.i.i ]
  %99 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i.i.i.i ], [ 0, %if.then.i.i.i.i.i.i ]
  %100 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %97, i64 %98, i8 %99, i64 0)
  %101 = extractvalue { i8*, i32 } %100, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %101) #12
  unreachable

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i: ; preds = %.noexc.i.i.i.i.i, %lpad.i.i.i38
  store i8 0, i8* %small_n.i.i.i.i.i.i, align 1, !alias.scope !9
  %102 = extractvalue { i8*, i32 } %87, 0
  %103 = extractvalue { i8*, i32 } %87, 1
  br label %cleanup.action

invoke.cont1:                                     ; preds = %if.else.i.i, %if.then.i.i
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %46) #10
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %44)
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %48)
  call void @llvm.lifetime.end.p0i8(i64 22, i8* nonnull %50) #10, !noalias !9
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %56) #10
  %104 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp3, i64 0, i32 2
  %105 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp3 to %union.anon.1**
  store %union.anon.1* %104, %union.anon.1** %105, align 8, !tbaa !25
  %106 = bitcast %union.anon.1* %104 to i8*
  %_M_p.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp3, i64 0, i32 0, i32 0
  %107 = bitcast %union.anon.1* %104 to i16*
  store i16 8236, i16* %107, align 8
  %_M_string_length.i.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp3, i64 0, i32 1
  store i64 2, i64* %_M_string_length.i.i.i.i.i.i, align 8, !tbaa !27
  %arrayidx.i.i.i.i.i = getelementptr inbounds i8, i8* %106, i64 2
  store i8 0, i8* %arrayidx.i.i.i.i.i, align 2, !tbaa !3
  %arrayinit.element2.ptr = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 2
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %42) #10, !noalias !29
  %108 = getelementptr inbounds %class.anon.413, %class.anon.413* %ref.tmp.i, i64 0, i32 0
  store %"class.std::__cxx11::basic_string"* %ref.tmp3, %"class.std::__cxx11::basic_string"** %108, align 8, !tbaa !14, !noalias !29
  %109 = load i64, i64* @__csi_func_id__ZN6parlay8sequenceIcNS_9allocatorIcEEEC2IRZNS_8to_charsERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEEUlmE_EEmOT_NS3_18_from_function_tagEm, align 8
  call void @__csan_set_MAAP(i8 4, i64 %109)
  call void @__csan_set_MAAP(i8 4, i64 %109)
  %110 = add i64 %66, 831
  call void @__csan_before_call(i64 %110, i64 %109, i8 2, i64 0)
  invoke void @_ZN6parlay8sequenceIcNS_9allocatorIcEEEC2IRZNS_8to_charsERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEEUlmE_EEmOT_NS3_18_from_function_tagEm(%"class.parlay::sequence"* nonnull %arrayinit.element2.ptr, i64 2, %class.anon.413* nonnull dereferenceable(8) %ref.tmp.i, i64 0)
          to label %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i84 unwind label %lpad7

_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i84: ; preds = %invoke.cont1
  call void @__csan_after_call(i64 %110, i64 %109, i8 2, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %42) #10, !noalias !29
  %arrayinit.element9.ptr = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 3
  %second = getelementptr inbounds %"struct.std::pair.7", %"struct.std::pair.7"* %P, i64 0, i32 1
  br i1 %58, label %115, label %111

111:                                              ; preds = %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i84
  %112 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %113 = add i64 %112, 2698
  %114 = bitcast i32* %second to i8*
  call void @__csan_load(i64 %113, i8* nonnull %114, i32 4, i64 4)
  br label %115

115:                                              ; preds = %111, %_ZNK6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl8capacityEv.exit.i.i84
  %116 = load i32, i32* %second, align 4, !tbaa !32
  %conv.i49 = zext i32 %116 to i64
  call void @llvm.lifetime.start.p0i8(i64 22, i8* nonnull %50) #10, !noalias !33
  %117 = load i64, i64* @__csi_func_id_snprintf, align 8
  call void @__csan_set_MAAP(i8 4, i64 %117)
  call void @__csan_set_MAAP(i8 4, i64 %117)
  %118 = add i64 %66, 825
  %call.i.i50 = call i32 (i8*, i64, i8*, ...) @snprintf(i8* nonnull %50, i64 21, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.29, i64 0, i64 0), i64 %conv.i49) #10, !noalias !33
  call void (i64, i64, i8, i64, i32, i8*, i64, i8*, ...) @__csan_snprintf(i64 %118, i64 %117, i8 2, i64 0, i32 %call.i.i50, i8* nonnull %50, i64 21, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.29, i64 0, i64 0), i64 %conv.i49)
  %cmp.i.i.i51 = icmp slt i32 %call.i.i50, 20
  %.sroa.speculated.i.i52 = select i1 %cmp.i.i.i51, i32 %call.i.i50, i32 20
  %idx.ext.i.i53 = sext i32 %.sroa.speculated.i.i52 to i64
  %small_n.i.i.i.i.i.i55 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 3, i32 0, i32 0, i32 0, i32 1
  store i8 0, i8* %small_n.i.i.i.i.i.i55, align 1, !alias.scope !33
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %36)
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %40)
  store i8* %50, i8** %first.addr.i70, align 8, !tbaa !14
  %cmp.i.i83 = icmp ugt i32 %.sroa.speculated.i.i52, 13
  br i1 %cmp.i.i83, label %if.then.i11.i91, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i94.thread

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i94.thread: ; preds = %115
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %38) #10
  br label %if.then.i15.i95

if.then.i11.i91:                                  ; preds = %115
  store i8 -128, i8* %small_n.i.i.i.i.i.i55, align 1
  %119 = add i64 %66, 832
  %120 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %119, i64 %120, i8 0, i64 0)
  %call.i.i.i.i.i.i110 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.i.noexc109 unwind label %lpad.i.i.i58

call.i.i.i.i.i.i.noexc109:                        ; preds = %if.then.i11.i91
  call void @__csan_after_call(i64 %119, i64 %120, i8 0, i64 0)
  %add.i.i.i.i86 = add nsw i64 %idx.ext.i.i53, 8
  %121 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator8allocateEm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %121)
  %122 = add i64 %66, 833
  call void @__csan_before_call(i64 %122, i64 %121, i8 1, i64 0)
  %call2.i.i.i.i.i.i112 = invoke i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i.i110, i64 %add.i.i.i.i86)
          to label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i94 unwind label %lpad.i.i.i58

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i94: ; preds = %call.i.i.i.i.i.i.noexc109
  call void @__csan_after_call(i64 %122, i64 %121, i8 1, i64 0)
  %capacity.i.i.i5.i.i87 = bitcast i8* %call2.i.i.i.i.i.i112 to i64*
  %123 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %124 = add i64 %123, 1266
  call void @__csan_store(i64 %124, i8* %call2.i.i.i.i.i.i112, i32 8, i64 8)
  store i64 %idx.ext.i.i53, i64* %capacity.i.i.i5.i.i87, align 8, !tbaa !16
  %125 = bitcast %"class.parlay::sequence"* %arrayinit.element9.ptr to i8**
  store i8* %call2.i.i.i.i.i.i112, i8** %125, align 1, !tbaa.struct !19
  %ref.tmp.sroa.4.0..sroa_idx7.i.i88 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast8.i.i89 = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx7.i.i88 to i48*
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast8.i.i89, align 1, !tbaa.struct !19
  %bf.load.i.i13.pre.i90 = load i8, i8* %small_n.i.i.i.i.i.i55, align 1
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %38) #10
  %cmp.i.i14.i93 = icmp sgt i8 %bf.load.i.i13.pre.i90, -1
  br i1 %cmp.i.i14.i93, label %if.then.i15.i95, label %if.else.i16.i97

if.then.i15.i95:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i94, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i94.thread
  %126 = bitcast %"class.parlay::sequence"* %arrayinit.element9.ptr to i8*
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i101

if.else.i16.i97:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl19initialize_capacityEm.exit.i94
  %127 = getelementptr inbounds i8, i8* %call2.i.i.i.i.i.i112, i64 8
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i101

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i101: ; preds = %if.else.i16.i97, %if.then.i15.i95
  %retval.0.i.i98 = phi i8* [ %126, %if.then.i15.i95 ], [ %127, %if.else.i16.i97 ]
  store i8* %retval.0.i.i98, i8** %buffer.i71, align 8, !tbaa !14
  %128 = getelementptr inbounds %class.anon.332, %class.anon.332* %agg.tmp.i72, i64 0, i32 0
  store %"class.parlay::sequence"* %arrayinit.element9.ptr, %"class.parlay::sequence"** %128, align 8, !tbaa !21
  %129 = getelementptr inbounds %class.anon.332, %class.anon.332* %agg.tmp.i72, i64 0, i32 1
  store i8** %buffer.i71, i8*** %129, align 8, !tbaa !14
  %130 = getelementptr inbounds %class.anon.332, %class.anon.332* %agg.tmp.i72, i64 0, i32 2
  store i8** %first.addr.i70, i8*** %130, align 8, !tbaa !14
  %131 = load i64, i64* @__csi_func_id__ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb, align 8
  call void @__csan_set_MAAP(i8 4, i64 %131)
  %132 = add i64 %66, 834
  call void @__csan_before_call(i64 %132, i64 %131, i8 1, i64 0)
  invoke void @_ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb(i64 0, i64 %idx.ext.i.i53, %class.anon.332* nonnull byval(%class.anon.332) align 8 %agg.tmp.i72, i64 8193, i1 zeroext false)
          to label %.noexc113 unwind label %lpad.i.i.i58

.noexc113:                                        ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i101
  call void @__csan_after_call(i64 %132, i64 %131, i8 1, i64 0)
  %bf.load.i.i.i99 = load i8, i8* %small_n.i.i.i.i.i.i55, align 1
  %cmp.i.i.i100 = icmp sgt i8 %bf.load.i.i.i99, -1
  br i1 %cmp.i.i.i100, label %if.then.i.i106, label %if.else.i.i108

if.then.i.i106:                                   ; preds = %.noexc113
  %conv.i.i102 = trunc i32 %.sroa.speculated.i.i52 to i8
  %bf.value.i.i103 = and i8 %conv.i.i102, 127
  %bf.clear.i.i104 = and i8 %bf.load.i.i.i99, -128
  %bf.set.i.i105 = or i8 %bf.clear.i.i104, %bf.value.i.i103
  store i8 %bf.set.i.i105, i8* %small_n.i.i.i.i.i.i55, align 1
  br label %if.then.i11.i164

if.else.i.i108:                                   ; preds = %.noexc113
  %n.i.i.i107 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %133 = bitcast [6 x i8]* %n.i.i.i107 to i48*
  %134 = sext i32 %.sroa.speculated.i.i52 to i48
  store i48 %134, i48* %133, align 1
  br label %if.then.i11.i164

lpad.i.i.i58:                                     ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i101, %call.i.i.i.i.i.i.noexc109, %if.then.i11.i91
  %135 = phi i64 [ %132, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i101 ], [ %122, %call.i.i.i.i.i.i.noexc109 ], [ %119, %if.then.i11.i91 ]
  %136 = phi i64 [ %131, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i101 ], [ %121, %call.i.i.i.i.i.i.noexc109 ], [ %120, %if.then.i11.i91 ]
  %137 = phi i8 [ 1, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl4dataEv.exit.i101 ], [ 1, %call.i.i.i.i.i.i.noexc109 ], [ 0, %if.then.i11.i91 ]
  %138 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %135, i64 %136, i8 %137, i64 0)
  %bf.load.i.i.i.i.i.i.i56 = load i8, i8* %small_n.i.i.i.i.i.i55, align 1, !alias.scope !33
  %cmp.i.i.i.i.i.i.i57 = icmp sgt i8 %bf.load.i.i.i.i.i.i.i56, -1
  br i1 %cmp.i.i.i.i.i.i.i57, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i67, label %if.then.i.i.i.i.i.i62

if.then.i.i.i.i.i.i62:                            ; preds = %lpad.i.i.i58
  %buffer.i.i.i.i.i.i.i59 = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arrayinit.element9.ptr, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %139 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i59, align 1, !tbaa !23, !alias.scope !33
  %capacity.i.i.i.i.i.i.i.i60 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %139, i64 0, i32 0
  %140 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %141 = add i64 %140, 2685
  %142 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %139 to i8*
  call void @__csan_load(i64 %141, i8* %142, i32 8, i64 8)
  %143 = load i64, i64* %capacity.i.i.i.i.i.i.i.i60, align 8, !tbaa !16
  %144 = add i64 %66, 835
  %145 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %144, i64 %145, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i.i.i.i61 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i.i.i64 unwind label %lpad.i.i.i.i.i66

call.i.i.i.i.i.noexc.i.i.i.i.i64:                 ; preds = %if.then.i.i.i.i.i.i62
  call void @__csan_after_call(i64 %144, i64 %145, i8 0, i64 0)
  %add.i.i.i.i.i.i.i.i63 = add i64 %143, 8
  %146 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %146)
  call void @__csan_set_MAAP(i8 3, i64 %146)
  %147 = add i64 %66, 836
  call void @__csan_before_call(i64 %147, i64 %146, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i.i.i.i61, i8* %142, i64 %add.i.i.i.i.i.i.i.i63)
          to label %.noexc.i.i.i.i.i65 unwind label %lpad.i.i.i.i.i66

.noexc.i.i.i.i.i65:                               ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i64
  call void @__csan_after_call(i64 %147, i64 %146, i8 2, i64 0)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i.i.i.i59, align 1, !tbaa !23, !alias.scope !33
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i67

lpad.i.i.i.i.i66:                                 ; preds = %call.i.i.i.i.i.noexc.i.i.i.i.i64, %if.then.i.i.i.i.i.i62
  %148 = phi i64 [ %147, %call.i.i.i.i.i.noexc.i.i.i.i.i64 ], [ %144, %if.then.i.i.i.i.i.i62 ]
  %149 = phi i64 [ %146, %call.i.i.i.i.i.noexc.i.i.i.i.i64 ], [ %145, %if.then.i.i.i.i.i.i62 ]
  %150 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i.i.i.i64 ], [ 0, %if.then.i.i.i.i.i.i62 ]
  %151 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %148, i64 %149, i8 %150, i64 0)
  %152 = extractvalue { i8*, i32 } %151, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %152) #12
  unreachable

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i67: ; preds = %.noexc.i.i.i.i.i65, %lpad.i.i.i58
  store i8 0, i8* %small_n.i.i.i.i.i.i55, align 1, !alias.scope !33
  br label %lpad7.body

if.then.i11.i164:                                 ; preds = %if.else.i.i108, %if.then.i.i106
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %38) #10
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %36)
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %40)
  call void @llvm.lifetime.end.p0i8(i64 22, i8* nonnull %50) #10, !noalias !33
  %arrayinit.element11.ptr = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 4
  %small_n.i.i.i.i120 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 4, i32 0, i32 0, i32 0, i32 1
  %153 = bitcast %"class.parlay::sequence"* %arrayinit.element11.ptr to i8*
  store i8 41, i8* %153, align 4, !tbaa !3
  store i8 1, i8* %small_n.i.i.i.i120, align 2
  %small_n.i.i.i.i146 = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 -128, i8* %small_n.i.i.i.i146, align 2
  %154 = add i64 %66, 837
  %155 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %154, i64 %155, i8 0, i64 0)
  %call.i.i.i.i.i.i182 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.i.noexc181 unwind label %lpad.i147.loopexit.split-lp.csi-split

call.i.i.i.i.i.i.noexc181:                        ; preds = %if.then.i11.i164
  call void @__csan_after_call(i64 %154, i64 %155, i8 0, i64 0)
  %156 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator8allocateEm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %156)
  %157 = add i64 %66, 838
  call void @__csan_before_call(i64 %157, i64 %156, i8 1, i64 0)
  %call2.i.i.i.i.i.i184 = invoke i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i.i182, i64 83)
          to label %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i unwind label %lpad.i147.loopexit.split-lp.csi-split

_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i: ; preds = %call.i.i.i.i.i.i.noexc181
  call void @__csan_after_call(i64 %157, i64 %156, i8 1, i64 0)
  %capacity.i.i.i5.i.i160 = bitcast i8* %call2.i.i.i.i.i.i184 to i64*
  %158 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %159 = add i64 %158, 1267
  call void @__csan_store(i64 %159, i8* %call2.i.i.i.i.i.i184, i32 8, i64 8)
  store i64 5, i64* %capacity.i.i.i5.i.i160, align 8, !tbaa !38
  %160 = bitcast %"class.parlay::sequence.2"* %s to i8**
  store i8* %call2.i.i.i.i.i.i184, i8** %160, align 8, !tbaa.struct !19
  %ref.tmp.sroa.4.0..sroa_idx7.i.i161 = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast8.i.i162 = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx7.i.i161 to i48*
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast8.i.i162, align 8, !tbaa.struct !19
  %bf.load.i.i13.pre.i163 = load i8, i8* %small_n.i.i.i.i146, align 2
  %cmp.i.i14.i166 = icmp sgt i8 %bf.load.i.i13.pre.i163, -1
  %161 = bitcast %"class.parlay::sequence.2"* %s to %"class.parlay::sequence"*
  %data.i.i.i.i.i = getelementptr inbounds i8, i8* %call2.i.i.i.i.i.i184, i64 8
  %162 = bitcast i8* %data.i.i.i.i.i to %"class.parlay::sequence"*
  %retval.0.i.i170 = select i1 %cmp.i.i14.i166, %"class.parlay::sequence"* %161, %"class.parlay::sequence"* %162
  call void @__csan_detach(i64 %21, i8 0)
  detach within %syncreg19.i.i, label %pfor.body.i.i, label %pfor.inc.i.i unwind label %lpad.i147.loopexit

pfor.body.i.i:                                    ; preds = %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i
  %163 = call i8* @llvm.task.frameaddress(i32 0)
  %164 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %22, i64 %21, i8* %163, i8* %164, i64 0)
  %impl.i.i.i.i.i.i.i = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 0, i32 0, i32 0
  %impl.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i170, i64 0, i32 0, i32 0
  %165 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %165)
  call void @__csan_set_MAAP(i8 3, i64 %165)
  %166 = add i64 %66, 839
  call void @__csan_before_call(i64 %166, i64 %165, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i.i.i)
          to label %.noexc179 unwind label %lpad.i147178

.noexc179:                                        ; preds = %pfor.body.i.i
  call void @__csan_after_call(i64 %166, i64 %165, i8 2, i64 0)
  call void @__csan_task_exit(i64 %23, i64 %22, i64 %21, i8 0, i64 0)
  reattach within %syncreg19.i.i, label %pfor.inc.i.i

pfor.inc.i.i:                                     ; preds = %.noexc179, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i
  call void @__csan_detach_continue(i64 %24, i64 %21)
  call void @__csan_detach(i64 %17, i8 0)
  detach within %syncreg19.i.i, label %pfor.body.i.i.1, label %pfor.inc.i.i.1 unwind label %lpad.i147.loopexit

sync.continue.i.i:                                ; preds = %pfor.inc.i.i.4
  invoke void @llvm.sync.unwind(token %syncreg19.i.i)
          to label %.noexc180 unwind label %lpad.i147.loopexit.split-lp.csi-split-lp

.noexc180:                                        ; preds = %sync.continue.i.i
  %bf.load.i.i.i171 = load i8, i8* %small_n.i.i.i.i146, align 2
  %cmp.i.i.i172 = icmp sgt i8 %bf.load.i.i.i171, -1
  br i1 %cmp.i.i.i172, label %if.then.i.i175, label %if.else.i.i177

if.then.i.i175:                                   ; preds = %.noexc180
  %bf.clear.i.i173 = and i8 %bf.load.i.i.i171, -128
  %bf.set.i.i174 = or i8 %bf.clear.i.i173, 5
  store i8 %bf.set.i.i174, i8* %small_n.i.i.i.i146, align 2
  br label %invoke.cont14

if.else.i.i177:                                   ; preds = %.noexc180
  store i48 5, i48* %ref.tmp.sroa.4.0..sroa_cast8.i.i162, align 8
  br label %invoke.cont14

lpad.i147.unreachable:                            ; preds = %lpad.i147178
  unreachable

lpad.i147178:                                     ; preds = %pfor.body.i.i.4, %pfor.body.i.i.3, %pfor.body.i.i.2, %pfor.body.i.i.1, %pfor.body.i.i
  %167 = phi i64 [ %3, %pfor.body.i.i.4 ], [ %10, %pfor.body.i.i.3 ], [ %14, %pfor.body.i.i.2 ], [ %18, %pfor.body.i.i.1 ], [ %22, %pfor.body.i.i ]
  %168 = phi i64 [ %1, %pfor.body.i.i.4 ], [ %9, %pfor.body.i.i.3 ], [ %13, %pfor.body.i.i.2 ], [ %17, %pfor.body.i.i.1 ], [ %21, %pfor.body.i.i ]
  %169 = phi i64 [ %382, %pfor.body.i.i.4 ], [ %378, %pfor.body.i.i.3 ], [ %374, %pfor.body.i.i.2 ], [ %370, %pfor.body.i.i.1 ], [ %166, %pfor.body.i.i ]
  %170 = phi i64 [ %381, %pfor.body.i.i.4 ], [ %377, %pfor.body.i.i.3 ], [ %373, %pfor.body.i.i.2 ], [ %369, %pfor.body.i.i.1 ], [ %165, %pfor.body.i.i ]
  %171 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %169, i64 %170, i8 2, i64 0)
  %172 = add i64 %4, 223
  call void @__csan_task_exit(i64 %172, i64 %167, i64 %168, i8 0, i64 0)
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg19.i.i, { i8*, i32 } %171)
          to label %lpad.i147.unreachable unwind label %lpad.i147.loopexit

lpad.i147.loopexit:                               ; preds = %pfor.inc.i.i.3, %pfor.inc.i.i.2, %pfor.inc.i.i.1, %lpad.i147178, %pfor.inc.i.i, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i
  %173 = phi i64 [ %1, %pfor.inc.i.i.3 ], [ %9, %pfor.inc.i.i.2 ], [ %13, %pfor.inc.i.i.1 ], [ %17, %pfor.inc.i.i ], [ %1, %lpad.i147178 ], [ %21, %_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl19initialize_capacityEm.exit.i ]
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  call void @__csan_detach_continue(i64 %8, i64 %173)
  br label %177

lpad.i147.loopexit.split-lp.csi-split-lp:         ; preds = %sync.continue.i.i
  %lpad.csi-split-lp = landingpad { i8*, i32 }
          cleanup
  br label %177

lpad.i147.loopexit.split-lp.csi-split:            ; preds = %call.i.i.i.i.i.i.noexc181, %if.then.i11.i164
  %174 = phi i64 [ %157, %call.i.i.i.i.i.i.noexc181 ], [ %154, %if.then.i11.i164 ]
  %175 = phi i64 [ %156, %call.i.i.i.i.i.i.noexc181 ], [ %155, %if.then.i11.i164 ]
  %176 = phi i8 [ 1, %call.i.i.i.i.i.i.noexc181 ], [ 0, %if.then.i11.i164 ]
  %lpad.csi-split = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %174, i64 %175, i8 %176, i64 0)
  br label %177

177:                                              ; preds = %lpad.i147.loopexit.split-lp.csi-split, %lpad.i147.loopexit.split-lp.csi-split-lp, %lpad.i147.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad.i147.loopexit ], [ %lpad.csi-split-lp, %lpad.i147.loopexit.split-lp.csi-split-lp ], [ %lpad.csi-split, %lpad.i147.loopexit.split-lp.csi-split ]
  %impl.i.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s, i64 0, i32 0, i32 0
  %178 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev, align 8
  call void @__csan_set_MAAP(i8 7, i64 %178)
  %179 = add i64 %66, 840
  call void @__csan_before_call(i64 %179, i64 %178, i8 1, i64 0)
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev(%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl"* nonnull %impl.i.i) #10
  call void @__csan_after_call(i64 %179, i64 %178, i8 1, i64 0)
  %180 = extractvalue { i8*, i32 } %lpad.phi, 0
  %181 = extractvalue { i8*, i32 } %lpad.phi, 1
  %182 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %183 = add i64 %182, 2699
  call void @__csan_load(i64 %183, i8* nonnull %small_n.i.i.i.i120, i32 1, i64 2)
  %bf.load.i.i.i.i193 = load i8, i8* %small_n.i.i.i.i120, align 2
  %cmp.i.i.i.i194 = icmp sgt i8 %bf.load.i.i.i.i193, -1
  br i1 %cmp.i.i.i.i194, label %._crit_edge, label %211

._crit_edge:                                      ; preds = %177
  %.pre = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  br label %230

invoke.cont14:                                    ; preds = %if.else.i.i177, %if.then.i.i175
  %bf.load.i.i.i.i186 = load i8, i8* %small_n.i.i.i.i120, align 2
  %cmp.i.i.i.i187 = icmp sgt i8 %bf.load.i.i.i.i186, -1
  br i1 %cmp.i.i.i.i187, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %invoke.cont14
  %buffer.i.i.i.i188 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 4, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %184 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188, align 4, !tbaa !23
  %capacity.i.i.i.i.i189 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %184, i64 0, i32 0
  %185 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %186 = add i64 %185, 2686
  %187 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %184 to i8*
  call void @__csan_load(i64 %186, i8* %187, i32 8, i64 8)
  %188 = load i64, i64* %capacity.i.i.i.i.i189, align 8, !tbaa !16
  %189 = add i64 %66, 841
  %190 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %189, i64 %190, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i unwind label %lpad.i.i

call.i.i.i.i.i.noexc.i.i:                         ; preds = %if.then.i.i.i
  call void @__csan_after_call(i64 %189, i64 %190, i8 0, i64 0)
  %add.i.i.i.i.i = add i64 %188, 8
  %191 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %191)
  call void @__csan_set_MAAP(i8 3, i64 %191)
  %192 = add i64 %66, 842
  call void @__csan_before_call(i64 %192, i64 %191, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i, i8* %187, i64 %add.i.i.i.i.i)
          to label %.noexc.i.i unwind label %lpad.i.i

.noexc.i.i:                                       ; preds = %call.i.i.i.i.i.noexc.i.i
  call void @__csan_after_call(i64 %192, i64 %191, i8 2, i64 0)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188, align 4, !tbaa !23
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit

lpad.i.i:                                         ; preds = %call.i.i.i.i.i.noexc.i.i.4, %if.then.i.i.i.4, %call.i.i.i.i.i.noexc.i.i.3, %if.then.i.i.i.3, %call.i.i.i.i.i.noexc.i.i.2, %if.then.i.i.i.2, %call.i.i.i.i.i.noexc.i.i.1, %if.then.i.i.i.1, %call.i.i.i.i.i.noexc.i.i, %if.then.i.i.i
  %193 = phi i64 [ %303, %call.i.i.i.i.i.noexc.i.i.4 ], [ %300, %if.then.i.i.i.4 ], [ %294, %call.i.i.i.i.i.noexc.i.i.3 ], [ %291, %if.then.i.i.i.3 ], [ %285, %call.i.i.i.i.i.noexc.i.i.2 ], [ %282, %if.then.i.i.i.2 ], [ %276, %call.i.i.i.i.i.noexc.i.i.1 ], [ %273, %if.then.i.i.i.1 ], [ %192, %call.i.i.i.i.i.noexc.i.i ], [ %189, %if.then.i.i.i ]
  %194 = phi i64 [ %302, %call.i.i.i.i.i.noexc.i.i.4 ], [ %301, %if.then.i.i.i.4 ], [ %293, %call.i.i.i.i.i.noexc.i.i.3 ], [ %292, %if.then.i.i.i.3 ], [ %284, %call.i.i.i.i.i.noexc.i.i.2 ], [ %283, %if.then.i.i.i.2 ], [ %275, %call.i.i.i.i.i.noexc.i.i.1 ], [ %274, %if.then.i.i.i.1 ], [ %191, %call.i.i.i.i.i.noexc.i.i ], [ %190, %if.then.i.i.i ]
  %195 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i.4 ], [ 0, %if.then.i.i.i.4 ], [ 2, %call.i.i.i.i.i.noexc.i.i.3 ], [ 0, %if.then.i.i.i.3 ], [ 2, %call.i.i.i.i.i.noexc.i.i.2 ], [ 0, %if.then.i.i.i.2 ], [ 2, %call.i.i.i.i.i.noexc.i.i.1 ], [ 0, %if.then.i.i.i.1 ], [ 2, %call.i.i.i.i.i.noexc.i.i ], [ 0, %if.then.i.i.i ]
  %196 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %193, i64 %194, i8 %195, i64 0)
  %197 = extractvalue { i8*, i32 } %196, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %197) #12
  unreachable

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit: ; preds = %.noexc.i.i, %invoke.cont14
  store i8 0, i8* %small_n.i.i.i.i120, align 2
  %bf.load.i.i.i.i186.1 = load i8, i8* %small_n.i.i.i.i.i.i55, align 1
  %cmp.i.i.i.i187.1 = icmp sgt i8 %bf.load.i.i.i.i186.1, -1
  br i1 %cmp.i.i.i.i187.1, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1, label %if.then.i.i.i.1

if.then.i.i191:                                   ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.4
  %198 = load i64, i64* @__csi_unit_free_base_id, align 8, !invariant.load !2
  %199 = add i64 %198, 33
  call void @_ZdlPv(i8* %304) #10
  call void @__csan_after_free(i64 %199, i8* %304, i64 1)
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit: ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.4, %if.then.i.i191
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %56) #10
  call void @llvm.lifetime.end.p0i8(i64 75, i8* nonnull %54) #10
  %200 = and i8 %30, 3
  %201 = or i8 %200, 4
  %202 = load i64, i64* @__csi_func_id__ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_, align 8
  call void @__csan_set_MAAP(i8 4, i64 %202)
  call void @__csan_set_MAAP(i8 %201, i64 %202)
  %203 = add i64 %66, 843
  call void @__csan_before_call(i64 %203, i64 %202, i8 2, i64 0)
  invoke void @_ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_(%"class.parlay::sequence"* sret %agg.result, %"class.parlay::sequence.2"* nonnull dereferenceable(15) %s)
          to label %invoke.cont33 unwind label %lpad32

invoke.cont33:                                    ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
  call void @__csan_after_call(i64 %203, i64 %202, i8 2, i64 0)
  %impl.i = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s, i64 0, i32 0, i32 0
  %204 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev, align 8
  call void @__csan_set_MAAP(i8 4, i64 %204)
  %205 = add i64 %66, 844
  call void @__csan_before_call(i64 %205, i64 %204, i8 1, i64 0)
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev(%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl"* nonnull %impl.i) #10
  call void @__csan_after_call(i64 %205, i64 %204, i8 1, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %52) #10
  %206 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %207 = add i64 %206, 292
  call void @__csan_func_exit(i64 %207, i64 %26, i64 1)
  ret void

lpad7:                                            ; preds = %invoke.cont1
  %208 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %110, i64 %109, i8 2, i64 0)
  br label %lpad7.body

lpad7.body:                                       ; preds = %lpad7, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i67
  %arrayinit.endOfInit.1.idx.lpad-body = phi i64 [ 3, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i67 ], [ 2, %lpad7 ]
  %eh.lpad-body68 = phi { i8*, i32 } [ %138, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i67 ], [ %208, %lpad7 ]
  %209 = extractvalue { i8*, i32 } %eh.lpad-body68, 0
  %210 = extractvalue { i8*, i32 } %eh.lpad-body68, 1
  br label %ehcleanup

211:                                              ; preds = %177
  %buffer.i.i.i.i195 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 4, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %212 = add i64 %182, 2700
  %213 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195 to i8*
  call void @__csan_load(i64 %212, i8* nonnull %213, i32 8, i64 4)
  %214 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195, align 4, !tbaa !23
  %capacity.i.i.i.i.i196 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %214, i64 0, i32 0
  %215 = add i64 %182, 2687
  %216 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %214 to i8*
  call void @__csan_load(i64 %215, i8* %216, i32 8, i64 8)
  %217 = load i64, i64* %capacity.i.i.i.i.i196, align 8, !tbaa !16
  %218 = add i64 %66, 845
  %219 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %218, i64 %219, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i197 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i200 unwind label %lpad.i.i202

call.i.i.i.i.i.noexc.i.i200:                      ; preds = %211
  call void @__csan_after_call(i64 %218, i64 %219, i8 0, i64 0)
  %add.i.i.i.i.i199 = add i64 %217, 8
  %220 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %220)
  call void @__csan_set_MAAP(i8 3, i64 %220)
  %221 = add i64 %66, 846
  call void @__csan_before_call(i64 %221, i64 %220, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i197, i8* %216, i64 %add.i.i.i.i.i199)
          to label %222 unwind label %lpad.i.i202

222:                                              ; preds = %call.i.i.i.i.i.noexc.i.i200
  call void @__csan_after_call(i64 %221, i64 %220, i8 2, i64 0)
  %223 = load i64, i64* @__csi_unit_store_base_id, align 8, !invariant.load !2
  %224 = add i64 %223, 1268
  call void @__csan_store(i64 %224, i8* nonnull %213, i32 8, i64 4)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195, align 4, !tbaa !23
  br label %230

lpad.i.i202:                                      ; preds = %call.i.i.i.i.i.noexc.i.i200.4, %353, %call.i.i.i.i.i.noexc.i.i200.3, %337, %call.i.i.i.i.i.noexc.i.i200.2, %321, %call.i.i.i.i.i.noexc.i.i200.1, %305, %call.i.i.i.i.i.noexc.i.i200, %211
  %225 = phi i64 [ %362, %call.i.i.i.i.i.noexc.i.i200.4 ], [ %359, %353 ], [ %347, %call.i.i.i.i.i.noexc.i.i200.3 ], [ %344, %337 ], [ %331, %call.i.i.i.i.i.noexc.i.i200.2 ], [ %328, %321 ], [ %315, %call.i.i.i.i.i.noexc.i.i200.1 ], [ %312, %305 ], [ %221, %call.i.i.i.i.i.noexc.i.i200 ], [ %218, %211 ]
  %226 = phi i64 [ %361, %call.i.i.i.i.i.noexc.i.i200.4 ], [ %360, %353 ], [ %346, %call.i.i.i.i.i.noexc.i.i200.3 ], [ %345, %337 ], [ %330, %call.i.i.i.i.i.noexc.i.i200.2 ], [ %329, %321 ], [ %314, %call.i.i.i.i.i.noexc.i.i200.1 ], [ %313, %305 ], [ %220, %call.i.i.i.i.i.noexc.i.i200 ], [ %219, %211 ]
  %227 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i200.4 ], [ 0, %353 ], [ 2, %call.i.i.i.i.i.noexc.i.i200.3 ], [ 0, %337 ], [ 2, %call.i.i.i.i.i.noexc.i.i200.2 ], [ 0, %321 ], [ 2, %call.i.i.i.i.i.noexc.i.i200.1 ], [ 0, %305 ], [ 2, %call.i.i.i.i.i.noexc.i.i200 ], [ 0, %211 ]
  %228 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %225, i64 %226, i8 %227, i64 0)
  %229 = extractvalue { i8*, i32 } %228, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %229) #12
  unreachable

230:                                              ; preds = %222, %._crit_edge
  %231 = phi i64 [ %.pre, %._crit_edge ], [ %223, %222 ]
  %232 = add i64 %231, 1269
  call void @__csan_store(i64 %232, i8* nonnull %small_n.i.i.i.i120, i32 1, i64 2)
  store i8 0, i8* %small_n.i.i.i.i120, align 2
  %233 = add i64 %182, 2701
  call void @__csan_load(i64 %233, i8* nonnull %small_n.i.i.i.i.i.i55, i32 1, i64 1)
  %bf.load.i.i.i.i193.1 = load i8, i8* %small_n.i.i.i.i.i.i55, align 1
  %cmp.i.i.i.i194.1 = icmp sgt i8 %bf.load.i.i.i.i193.1, -1
  br i1 %cmp.i.i.i.i194.1, label %318, label %305

ehcleanup:                                        ; preds = %365, %lpad7.body
  %arrayinit.endOfInit.2.idx = phi i64 [ %arrayinit.endOfInit.1.idx.lpad-body, %lpad7.body ], [ 4, %365 ]
  %exn.slot.0 = phi i8* [ %209, %lpad7.body ], [ %180, %365 ]
  %ehselector.slot.0 = phi i32 [ %210, %lpad7.body ], [ %181, %365 ]
  %cleanup.isactive.0 = phi i1 [ true, %lpad7.body ], [ false, %365 ]
  %234 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !40
  %cmp.i.i.i206 = icmp eq i8* %234, %106
  br i1 %cmp.i.i.i206, label %ehcleanup25, label %if.then.i.i207

if.then.i.i207:                                   ; preds = %ehcleanup
  %235 = load i64, i64* @__csi_unit_free_base_id, align 8, !invariant.load !2
  %236 = add i64 %235, 34
  call void @_ZdlPv(i8* %234) #10
  call void @__csan_after_free(i64 %236, i8* %234, i64 1)
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %56) #10
  br i1 %cleanup.isactive.0, label %cleanup.action, label %cleanup.done

ehcleanup25:                                      ; preds = %ehcleanup
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %56) #10
  br i1 %cleanup.isactive.0, label %cleanup.action, label %cleanup.done

cleanup.action:                                   ; preds = %ehcleanup25, %if.then.i.i207, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i
  %ehselector.slot.2261 = phi i32 [ %103, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i ], [ %ehselector.slot.0, %ehcleanup25 ], [ %ehselector.slot.0, %if.then.i.i207 ]
  %exn.slot.2259 = phi i8* [ %102, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i ], [ %exn.slot.0, %ehcleanup25 ], [ %exn.slot.0, %if.then.i.i207 ]
  %arrayinit.endOfInit.4.idx257 = phi i64 [ 1, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.i.i.i ], [ %arrayinit.endOfInit.2.idx, %ehcleanup25 ], [ %arrayinit.endOfInit.2.idx, %if.then.i.i207 ]
  %arrayinit.endOfInit.4.ptr = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 %arrayinit.endOfInit.4.idx257
  %237 = load i64, i64* @__csi_unit_load_base_id, align 8
  %238 = add i64 %237, 2702
  %239 = add i64 %237, 2703
  %240 = add i64 %237, 2688
  %241 = add i64 %66, 847
  %242 = add i64 %66, 848
  %243 = load i64, i64* @__csi_unit_store_base_id, align 8
  %244 = add i64 %243, 1270
  %245 = add i64 %243, 1271
  br label %246

246:                                              ; preds = %260, %cleanup.action
  %arraydestroy.elementPast27 = phi %"class.parlay::sequence"* [ %arrayinit.endOfInit.4.ptr, %cleanup.action ], [ %arraydestroy.element28, %260 ]
  %arraydestroy.element28 = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.elementPast27, i64 -1
  %flag.i.i.i.i209 = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.elementPast27, i64 -1, i32 0, i32 0, i32 0, i32 1
  call void @__csan_load(i64 %238, i8* nonnull %flag.i.i.i.i209, i32 1, i64 1)
  %bf.load.i.i.i.i210 = load i8, i8* %flag.i.i.i.i209, align 1
  %cmp.i.i.i.i211 = icmp sgt i8 %bf.load.i.i.i.i210, -1
  br i1 %cmp.i.i.i.i211, label %260, label %247

247:                                              ; preds = %246
  %buffer.i.i.i.i212 = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %arraydestroy.element28, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %248 = bitcast %"class.parlay::sequence"* %arraydestroy.element28 to i8*
  call void @__csan_load(i64 %239, i8* nonnull %248, i32 8, i64 1)
  %249 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i212, align 1, !tbaa !23
  %capacity.i.i.i.i.i213 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %249, i64 0, i32 0
  %250 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %249 to i8*
  call void @__csan_load(i64 %240, i8* %250, i32 8, i64 8)
  %251 = load i64, i64* %capacity.i.i.i.i.i213, align 8, !tbaa !16
  %252 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %241, i64 %252, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i214 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i217 unwind label %lpad.i.i219

call.i.i.i.i.i.noexc.i.i217:                      ; preds = %247
  call void @__csan_after_call(i64 %241, i64 %252, i8 0, i64 0)
  %add.i.i.i.i.i216 = add i64 %251, 8
  %253 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %253)
  call void @__csan_set_MAAP(i8 3, i64 %253)
  call void @__csan_before_call(i64 %242, i64 %253, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i214, i8* %250, i64 %add.i.i.i.i.i216)
          to label %254 unwind label %lpad.i.i219

254:                                              ; preds = %call.i.i.i.i.i.noexc.i.i217
  call void @__csan_after_call(i64 %242, i64 %253, i8 2, i64 0)
  call void @__csan_store(i64 %244, i8* nonnull %248, i32 8, i64 1)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i212, align 1, !tbaa !23
  br label %260

lpad.i.i219:                                      ; preds = %call.i.i.i.i.i.noexc.i.i217, %247
  %255 = phi i64 [ %242, %call.i.i.i.i.i.noexc.i.i217 ], [ %241, %247 ]
  %256 = phi i64 [ %253, %call.i.i.i.i.i.noexc.i.i217 ], [ %252, %247 ]
  %257 = phi i8 [ 2, %call.i.i.i.i.i.noexc.i.i217 ], [ 0, %247 ]
  %258 = landingpad { i8*, i32 }
          catch i8* null
  call void @__csan_after_call(i64 %255, i64 %256, i8 %257, i64 0)
  %259 = extractvalue { i8*, i32 } %258, 0
  call void @__cilksan_disable_checking()
  call void @__clang_call_terminate(i8* %259) #12
  unreachable

260:                                              ; preds = %254, %246
  call void @__csan_store(i64 %245, i8* nonnull %flag.i.i.i.i209, i32 1, i64 1)
  store i8 0, i8* %flag.i.i.i.i209, align 1
  %arraydestroy.done29 = icmp eq %"class.parlay::sequence"* %arraydestroy.element28, %arrayinit.begin
  br i1 %arraydestroy.done29, label %cleanup.done, label %246

cleanup.done:                                     ; preds = %260, %ehcleanup25, %if.then.i.i207
  %ehselector.slot.2260 = phi i32 [ %ehselector.slot.0, %ehcleanup25 ], [ %ehselector.slot.0, %if.then.i.i207 ], [ %ehselector.slot.2261, %260 ]
  %exn.slot.2258 = phi i8* [ %exn.slot.0, %ehcleanup25 ], [ %exn.slot.0, %if.then.i.i207 ], [ %exn.slot.2259, %260 ]
  call void @llvm.lifetime.end.p0i8(i64 75, i8* nonnull %54) #10
  br label %ehcleanup35

lpad32:                                           ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
  %261 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %203, i64 %202, i8 2, i64 0)
  %262 = extractvalue { i8*, i32 } %261, 0
  %263 = extractvalue { i8*, i32 } %261, 1
  %impl.i221 = getelementptr inbounds %"class.parlay::sequence.2", %"class.parlay::sequence.2"* %s, i64 0, i32 0, i32 0
  %264 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev, align 8
  call void @__csan_set_MAAP(i8 4, i64 %264)
  %265 = add i64 %66, 849
  call void @__csan_before_call(i64 %265, i64 %264, i8 1, i64 0)
  call void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev(%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl"* nonnull %impl.i221) #10
  call void @__csan_after_call(i64 %265, i64 %264, i8 1, i64 0)
  br label %ehcleanup35

ehcleanup35:                                      ; preds = %lpad32, %cleanup.done
  %exn.slot.3 = phi i8* [ %262, %lpad32 ], [ %exn.slot.2258, %cleanup.done ]
  %ehselector.slot.3 = phi i32 [ %263, %lpad32 ], [ %ehselector.slot.2260, %cleanup.done ]
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %52) #10
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.3, 0
  %lpad.val36 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.3, 1
  %266 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !2
  %267 = add i64 %266, 293
  call void @__csan_func_exit(i64 %267, i64 %26, i64 3)
  resume { i8*, i32 } %lpad.val36

if.then.i.i.i.1:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit
  %buffer.i.i.i.i188.1 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %268 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188.1, align 1, !tbaa !23
  %capacity.i.i.i.i.i189.1 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %268, i64 0, i32 0
  %269 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %270 = add i64 %269, 2689
  %271 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %268 to i8*
  call void @__csan_load(i64 %270, i8* %271, i32 8, i64 8)
  %272 = load i64, i64* %capacity.i.i.i.i.i189.1, align 8, !tbaa !16
  %273 = add i64 %66, 850
  %274 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %273, i64 %274, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i.1 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.1 unwind label %lpad.i.i

call.i.i.i.i.i.noexc.i.i.1:                       ; preds = %if.then.i.i.i.1
  call void @__csan_after_call(i64 %273, i64 %274, i8 0, i64 0)
  %add.i.i.i.i.i.1 = add i64 %272, 8
  %275 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %275)
  call void @__csan_set_MAAP(i8 3, i64 %275)
  %276 = add i64 %66, 851
  call void @__csan_before_call(i64 %276, i64 %275, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i.1, i8* %271, i64 %add.i.i.i.i.i.1)
          to label %.noexc.i.i.1 unwind label %lpad.i.i

.noexc.i.i.1:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.1
  call void @__csan_after_call(i64 %276, i64 %275, i8 2, i64 0)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188.1, align 1, !tbaa !23
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1: ; preds = %.noexc.i.i.1, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit
  store i8 0, i8* %small_n.i.i.i.i.i.i55, align 1
  %flag.i.i.i.i185.2 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 2, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i186.2 = load i8, i8* %flag.i.i.i.i185.2, align 2
  %cmp.i.i.i.i187.2 = icmp sgt i8 %bf.load.i.i.i.i186.2, -1
  br i1 %cmp.i.i.i.i187.2, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2, label %if.then.i.i.i.2

if.then.i.i.i.2:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1
  %buffer.i.i.i.i188.2 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %277 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188.2, align 2, !tbaa !23
  %capacity.i.i.i.i.i189.2 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %277, i64 0, i32 0
  %278 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %279 = add i64 %278, 2690
  %280 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %277 to i8*
  call void @__csan_load(i64 %279, i8* %280, i32 8, i64 8)
  %281 = load i64, i64* %capacity.i.i.i.i.i189.2, align 8, !tbaa !16
  %282 = add i64 %66, 852
  %283 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %282, i64 %283, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i.2 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.2 unwind label %lpad.i.i

call.i.i.i.i.i.noexc.i.i.2:                       ; preds = %if.then.i.i.i.2
  call void @__csan_after_call(i64 %282, i64 %283, i8 0, i64 0)
  %add.i.i.i.i.i.2 = add i64 %281, 8
  %284 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %284)
  call void @__csan_set_MAAP(i8 3, i64 %284)
  %285 = add i64 %66, 853
  call void @__csan_before_call(i64 %285, i64 %284, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i.2, i8* %280, i64 %add.i.i.i.i.i.2)
          to label %.noexc.i.i.2 unwind label %lpad.i.i

.noexc.i.i.2:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.2
  call void @__csan_after_call(i64 %285, i64 %284, i8 2, i64 0)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188.2, align 2, !tbaa !23
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2: ; preds = %.noexc.i.i.2, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.1
  store i8 0, i8* %flag.i.i.i.i185.2, align 2
  %bf.load.i.i.i.i186.3 = load i8, i8* %small_n.i.i.i.i.i.i, align 1
  %cmp.i.i.i.i187.3 = icmp sgt i8 %bf.load.i.i.i.i186.3, -1
  br i1 %cmp.i.i.i.i187.3, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3, label %if.then.i.i.i.3

if.then.i.i.i.3:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2
  %buffer.i.i.i.i188.3 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %286 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188.3, align 1, !tbaa !23
  %capacity.i.i.i.i.i189.3 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %286, i64 0, i32 0
  %287 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %288 = add i64 %287, 2691
  %289 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %286 to i8*
  call void @__csan_load(i64 %288, i8* %289, i32 8, i64 8)
  %290 = load i64, i64* %capacity.i.i.i.i.i189.3, align 8, !tbaa !16
  %291 = add i64 %66, 854
  %292 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %291, i64 %292, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i.3 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.3 unwind label %lpad.i.i

call.i.i.i.i.i.noexc.i.i.3:                       ; preds = %if.then.i.i.i.3
  call void @__csan_after_call(i64 %291, i64 %292, i8 0, i64 0)
  %add.i.i.i.i.i.3 = add i64 %290, 8
  %293 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %293)
  call void @__csan_set_MAAP(i8 3, i64 %293)
  %294 = add i64 %66, 855
  call void @__csan_before_call(i64 %294, i64 %293, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i.3, i8* %289, i64 %add.i.i.i.i.i.3)
          to label %.noexc.i.i.3 unwind label %lpad.i.i

.noexc.i.i.3:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.3
  call void @__csan_after_call(i64 %294, i64 %293, i8 2, i64 0)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188.3, align 1, !tbaa !23
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3: ; preds = %.noexc.i.i.3, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.2
  store i8 0, i8* %small_n.i.i.i.i.i.i, align 1
  %bf.load.i.i.i.i186.4 = load i8, i8* %small_n.i.i.i.i, align 2
  %cmp.i.i.i.i187.4 = icmp sgt i8 %bf.load.i.i.i.i186.4, -1
  br i1 %cmp.i.i.i.i187.4, label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.4, label %if.then.i.i.i.4

if.then.i.i.i.4:                                  ; preds = %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3
  %buffer.i.i.i.i188.4 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %295 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188.4, align 8, !tbaa !23
  %capacity.i.i.i.i.i189.4 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %295, i64 0, i32 0
  %296 = load i64, i64* @__csi_unit_load_base_id, align 8, !invariant.load !2
  %297 = add i64 %296, 2692
  %298 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %295 to i8*
  call void @__csan_load(i64 %297, i8* %298, i32 8, i64 8)
  %299 = load i64, i64* %capacity.i.i.i.i.i189.4, align 8, !tbaa !16
  %300 = add i64 %66, 856
  %301 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %300, i64 %301, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i.4 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.4 unwind label %lpad.i.i

call.i.i.i.i.i.noexc.i.i.4:                       ; preds = %if.then.i.i.i.4
  call void @__csan_after_call(i64 %300, i64 %301, i8 0, i64 0)
  %add.i.i.i.i.i.4 = add i64 %299, 8
  %302 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %302)
  call void @__csan_set_MAAP(i8 3, i64 %302)
  %303 = add i64 %66, 857
  call void @__csan_before_call(i64 %303, i64 %302, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i.4, i8* %298, i64 %add.i.i.i.i.i.4)
          to label %.noexc.i.i.4 unwind label %lpad.i.i

.noexc.i.i.4:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.4
  call void @__csan_after_call(i64 %303, i64 %302, i8 2, i64 0)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i188.4, align 8, !tbaa !23
  br label %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.4

_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.4: ; preds = %.noexc.i.i.4, %_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEED2Ev.exit.3
  store i8 0, i8* %small_n.i.i.i.i, align 2
  %304 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !40
  %cmp.i.i.i190 = icmp eq i8* %304, %106
  br i1 %cmp.i.i.i190, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit, label %if.then.i.i191

305:                                              ; preds = %230
  %buffer.i.i.i.i195.1 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %306 = add i64 %182, 2704
  %307 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.1 to i8*
  call void @__csan_load(i64 %306, i8* nonnull %307, i32 8, i64 1)
  %308 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.1, align 1, !tbaa !23
  %capacity.i.i.i.i.i196.1 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %308, i64 0, i32 0
  %309 = add i64 %182, 2693
  %310 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %308 to i8*
  call void @__csan_load(i64 %309, i8* %310, i32 8, i64 8)
  %311 = load i64, i64* %capacity.i.i.i.i.i196.1, align 8, !tbaa !16
  %312 = add i64 %66, 858
  %313 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %312, i64 %313, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i197.1 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i200.1 unwind label %lpad.i.i202

call.i.i.i.i.i.noexc.i.i200.1:                    ; preds = %305
  call void @__csan_after_call(i64 %312, i64 %313, i8 0, i64 0)
  %add.i.i.i.i.i199.1 = add i64 %311, 8
  %314 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %314)
  call void @__csan_set_MAAP(i8 3, i64 %314)
  %315 = add i64 %66, 859
  call void @__csan_before_call(i64 %315, i64 %314, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i197.1, i8* %310, i64 %add.i.i.i.i.i199.1)
          to label %316 unwind label %lpad.i.i202

316:                                              ; preds = %call.i.i.i.i.i.noexc.i.i200.1
  call void @__csan_after_call(i64 %315, i64 %314, i8 2, i64 0)
  %317 = add i64 %231, 1272
  call void @__csan_store(i64 %317, i8* nonnull %307, i32 8, i64 1)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.1, align 1, !tbaa !23
  br label %318

318:                                              ; preds = %316, %230
  %319 = add i64 %231, 1273
  call void @__csan_store(i64 %319, i8* nonnull %small_n.i.i.i.i.i.i55, i32 1, i64 1)
  store i8 0, i8* %small_n.i.i.i.i.i.i55, align 1
  %flag.i.i.i.i192.2 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 2, i32 0, i32 0, i32 0, i32 1
  %320 = add i64 %182, 2705
  call void @__csan_load(i64 %320, i8* nonnull %flag.i.i.i.i192.2, i32 1, i64 2)
  %bf.load.i.i.i.i193.2 = load i8, i8* %flag.i.i.i.i192.2, align 2
  %cmp.i.i.i.i194.2 = icmp sgt i8 %bf.load.i.i.i.i193.2, -1
  br i1 %cmp.i.i.i.i194.2, label %334, label %321

321:                                              ; preds = %318
  %buffer.i.i.i.i195.2 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %322 = add i64 %182, 2706
  %323 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.2 to i8*
  call void @__csan_load(i64 %322, i8* nonnull %323, i32 8, i64 2)
  %324 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.2, align 2, !tbaa !23
  %capacity.i.i.i.i.i196.2 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %324, i64 0, i32 0
  %325 = add i64 %182, 2694
  %326 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %324 to i8*
  call void @__csan_load(i64 %325, i8* %326, i32 8, i64 8)
  %327 = load i64, i64* %capacity.i.i.i.i.i196.2, align 8, !tbaa !16
  %328 = add i64 %66, 860
  %329 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %328, i64 %329, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i197.2 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i200.2 unwind label %lpad.i.i202

call.i.i.i.i.i.noexc.i.i200.2:                    ; preds = %321
  call void @__csan_after_call(i64 %328, i64 %329, i8 0, i64 0)
  %add.i.i.i.i.i199.2 = add i64 %327, 8
  %330 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %330)
  call void @__csan_set_MAAP(i8 3, i64 %330)
  %331 = add i64 %66, 861
  call void @__csan_before_call(i64 %331, i64 %330, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i197.2, i8* %326, i64 %add.i.i.i.i.i199.2)
          to label %332 unwind label %lpad.i.i202

332:                                              ; preds = %call.i.i.i.i.i.noexc.i.i200.2
  call void @__csan_after_call(i64 %331, i64 %330, i8 2, i64 0)
  %333 = add i64 %231, 1274
  call void @__csan_store(i64 %333, i8* nonnull %323, i32 8, i64 2)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.2, align 2, !tbaa !23
  br label %334

334:                                              ; preds = %332, %318
  %335 = add i64 %231, 1275
  call void @__csan_store(i64 %335, i8* nonnull %flag.i.i.i.i192.2, i32 1, i64 2)
  store i8 0, i8* %flag.i.i.i.i192.2, align 2
  %336 = add i64 %182, 2707
  call void @__csan_load(i64 %336, i8* nonnull %small_n.i.i.i.i.i.i, i32 1, i64 1)
  %bf.load.i.i.i.i193.3 = load i8, i8* %small_n.i.i.i.i.i.i, align 1
  %cmp.i.i.i.i194.3 = icmp sgt i8 %bf.load.i.i.i.i193.3, -1
  br i1 %cmp.i.i.i.i194.3, label %350, label %337

337:                                              ; preds = %334
  %buffer.i.i.i.i195.3 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %338 = add i64 %182, 2708
  %339 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.3 to i8*
  call void @__csan_load(i64 %338, i8* nonnull %339, i32 8, i64 1)
  %340 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.3, align 1, !tbaa !23
  %capacity.i.i.i.i.i196.3 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %340, i64 0, i32 0
  %341 = add i64 %182, 2695
  %342 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %340 to i8*
  call void @__csan_load(i64 %341, i8* %342, i32 8, i64 8)
  %343 = load i64, i64* %capacity.i.i.i.i.i196.3, align 8, !tbaa !16
  %344 = add i64 %66, 862
  %345 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %344, i64 %345, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i197.3 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i200.3 unwind label %lpad.i.i202

call.i.i.i.i.i.noexc.i.i200.3:                    ; preds = %337
  call void @__csan_after_call(i64 %344, i64 %345, i8 0, i64 0)
  %add.i.i.i.i.i199.3 = add i64 %343, 8
  %346 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %346)
  call void @__csan_set_MAAP(i8 3, i64 %346)
  %347 = add i64 %66, 863
  call void @__csan_before_call(i64 %347, i64 %346, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i197.3, i8* %342, i64 %add.i.i.i.i.i199.3)
          to label %348 unwind label %lpad.i.i202

348:                                              ; preds = %call.i.i.i.i.i.noexc.i.i200.3
  call void @__csan_after_call(i64 %347, i64 %346, i8 2, i64 0)
  %349 = add i64 %231, 1276
  call void @__csan_store(i64 %349, i8* nonnull %339, i32 8, i64 1)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.3, align 1, !tbaa !23
  br label %350

350:                                              ; preds = %348, %334
  %351 = add i64 %231, 1277
  call void @__csan_store(i64 %351, i8* nonnull %small_n.i.i.i.i.i.i, i32 1, i64 1)
  store i8 0, i8* %small_n.i.i.i.i.i.i, align 1
  %352 = add i64 %182, 2709
  call void @__csan_load(i64 %352, i8* nonnull %small_n.i.i.i.i, i32 1, i64 2)
  %bf.load.i.i.i.i193.4 = load i8, i8* %small_n.i.i.i.i, align 2
  %cmp.i.i.i.i194.4 = icmp sgt i8 %bf.load.i.i.i.i193.4, -1
  br i1 %cmp.i.i.i.i194.4, label %365, label %353

353:                                              ; preds = %350
  %buffer.i.i.i.i195.4 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %354 = add i64 %182, 2710
  call void @__csan_load(i64 %354, i8* nonnull %54, i32 8, i64 8)
  %355 = load %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.4, align 8, !tbaa !23
  %capacity.i.i.i.i.i196.4 = getelementptr inbounds %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header", %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %355, i64 0, i32 0
  %356 = add i64 %182, 2696
  %357 = bitcast %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* %355 to i8*
  call void @__csan_load(i64 %356, i8* %357, i32 8, i64 8)
  %358 = load i64, i64* %capacity.i.i.i.i.i196.4, align 8, !tbaa !16
  %359 = add i64 %66, 864
  %360 = load i64, i64* @__csi_func_id__ZN6parlay8internal21get_default_allocatorEv, align 8
  call void @__csan_before_call(i64 %359, i64 %360, i8 0, i64 0)
  %call.i.i.i.i.i3.i.i197.4 = invoke dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i200.4 unwind label %lpad.i.i202

call.i.i.i.i.i.noexc.i.i200.4:                    ; preds = %353
  call void @__csan_after_call(i64 %359, i64 %360, i8 0, i64 0)
  %add.i.i.i.i.i199.4 = add i64 %358, 8
  %361 = load i64, i64* @__csi_func_id__ZN6parlay14pool_allocator10deallocateEPvm, align 8
  call void @__csan_set_MAAP(i8 3, i64 %361)
  call void @__csan_set_MAAP(i8 3, i64 %361)
  %362 = add i64 %66, 865
  call void @__csan_before_call(i64 %362, i64 %361, i8 2, i64 0)
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"* nonnull %call.i.i.i.i.i3.i.i197.4, i8* %357, i64 %add.i.i.i.i.i199.4)
          to label %363 unwind label %lpad.i.i202

363:                                              ; preds = %call.i.i.i.i.i.noexc.i.i200.4
  call void @__csan_after_call(i64 %362, i64 %361, i8 2, i64 0)
  %364 = add i64 %231, 1278
  call void @__csan_store(i64 %364, i8* nonnull %54, i32 8, i64 8)
  store %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"* null, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl::capacitated_buffer::header"** %buffer.i.i.i.i195.4, align 8, !tbaa !23
  br label %365

365:                                              ; preds = %363, %350
  %366 = add i64 %231, 1279
  call void @__csan_store(i64 %366, i8* nonnull %small_n.i.i.i.i, i32 1, i64 2)
  store i8 0, i8* %small_n.i.i.i.i, align 2
  br label %ehcleanup

pfor.body.i.i.1:                                  ; preds = %pfor.inc.i.i
  %367 = call i8* @llvm.task.frameaddress(i32 0)
  %368 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %18, i64 %17, i8* %367, i8* %368, i64 0)
  %impl.i.i.i.i.i.i.i.1 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 1, i32 0, i32 0
  %impl.i.i.i.i.i.i.i.i.1 = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i170, i64 1, i32 0, i32 0
  %369 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %369)
  call void @__csan_set_MAAP(i8 3, i64 %369)
  %370 = add i64 %66, 866
  call void @__csan_before_call(i64 %370, i64 %369, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.1, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i.i.i.1)
          to label %.noexc179.1 unwind label %lpad.i147178

.noexc179.1:                                      ; preds = %pfor.body.i.i.1
  call void @__csan_after_call(i64 %370, i64 %369, i8 2, i64 0)
  call void @__csan_task_exit(i64 %19, i64 %18, i64 %17, i8 0, i64 0)
  reattach within %syncreg19.i.i, label %pfor.inc.i.i.1

pfor.inc.i.i.1:                                   ; preds = %.noexc179.1, %pfor.inc.i.i
  call void @__csan_detach_continue(i64 %20, i64 %17)
  call void @__csan_detach(i64 %13, i8 0)
  detach within %syncreg19.i.i, label %pfor.body.i.i.2, label %pfor.inc.i.i.2 unwind label %lpad.i147.loopexit

pfor.body.i.i.2:                                  ; preds = %pfor.inc.i.i.1
  %371 = call i8* @llvm.task.frameaddress(i32 0)
  %372 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %14, i64 %13, i8* %371, i8* %372, i64 0)
  %impl.i.i.i.i.i.i.i.2 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 2, i32 0, i32 0
  %impl.i.i.i.i.i.i.i.i.2 = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i170, i64 2, i32 0, i32 0
  %373 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %373)
  call void @__csan_set_MAAP(i8 3, i64 %373)
  %374 = add i64 %66, 867
  call void @__csan_before_call(i64 %374, i64 %373, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.2, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i.i.i.2)
          to label %.noexc179.2 unwind label %lpad.i147178

.noexc179.2:                                      ; preds = %pfor.body.i.i.2
  call void @__csan_after_call(i64 %374, i64 %373, i8 2, i64 0)
  call void @__csan_task_exit(i64 %15, i64 %14, i64 %13, i8 0, i64 0)
  reattach within %syncreg19.i.i, label %pfor.inc.i.i.2

pfor.inc.i.i.2:                                   ; preds = %.noexc179.2, %pfor.inc.i.i.1
  call void @__csan_detach_continue(i64 %16, i64 %13)
  call void @__csan_detach(i64 %9, i8 0)
  detach within %syncreg19.i.i, label %pfor.body.i.i.3, label %pfor.inc.i.i.3 unwind label %lpad.i147.loopexit

pfor.body.i.i.3:                                  ; preds = %pfor.inc.i.i.2
  %375 = call i8* @llvm.task.frameaddress(i32 0)
  %376 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %10, i64 %9, i8* %375, i8* %376, i64 0)
  %impl.i.i.i.i.i.i.i.3 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 3, i32 0, i32 0
  %impl.i.i.i.i.i.i.i.i.3 = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i170, i64 3, i32 0, i32 0
  %377 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %377)
  call void @__csan_set_MAAP(i8 3, i64 %377)
  %378 = add i64 %66, 868
  call void @__csan_before_call(i64 %378, i64 %377, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.3, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i.i.i.3)
          to label %.noexc179.3 unwind label %lpad.i147178

.noexc179.3:                                      ; preds = %pfor.body.i.i.3
  call void @__csan_after_call(i64 %378, i64 %377, i8 2, i64 0)
  call void @__csan_task_exit(i64 %11, i64 %10, i64 %9, i8 0, i64 0)
  reattach within %syncreg19.i.i, label %pfor.inc.i.i.3

pfor.inc.i.i.3:                                   ; preds = %.noexc179.3, %pfor.inc.i.i.2
  call void @__csan_detach_continue(i64 %12, i64 %9)
  call void @__csan_detach(i64 %1, i8 0)
  detach within %syncreg19.i.i, label %pfor.body.i.i.4, label %pfor.inc.i.i.4 unwind label %lpad.i147.loopexit

pfor.body.i.i.4:                                  ; preds = %pfor.inc.i.i.3
  %379 = call i8* @llvm.task.frameaddress(i32 0)
  %380 = call i8* @llvm.stacksave()
  call void @__csan_task(i64 %3, i64 %1, i8* %379, i8* %380, i64 0)
  %impl.i.i.i.i.i.i.i.4 = getelementptr inbounds [5 x %"class.parlay::sequence"], [5 x %"class.parlay::sequence"]* %ref.tmp, i64 0, i64 4, i32 0, i32 0
  %impl.i.i.i.i.i.i.i.i.4 = getelementptr inbounds %"class.parlay::sequence", %"class.parlay::sequence"* %retval.0.i.i170, i64 4, i32 0, i32 0
  %381 = load i64, i64* @__csi_func_id__ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_, align 8
  call void @__csan_set_MAAP(i8 3, i64 %381)
  call void @__csan_set_MAAP(i8 3, i64 %381)
  %382 = add i64 %66, 869
  call void @__csan_before_call(i64 %382, i64 %381, i8 2, i64 0)
  invoke void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull %impl.i.i.i.i.i.i.i.i.4, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* nonnull dereferenceable(15) %impl.i.i.i.i.i.i.i.4)
          to label %.noexc179.4 unwind label %lpad.i147178

.noexc179.4:                                      ; preds = %pfor.body.i.i.4
  call void @__csan_after_call(i64 %382, i64 %381, i8 2, i64 0)
  call void @__csan_task_exit(i64 %5, i64 %3, i64 %1, i8 0, i64 0)
  reattach within %syncreg19.i.i, label %pfor.inc.i.i.4

pfor.inc.i.i.4:                                   ; preds = %.noexc179.4, %pfor.inc.i.i.3
  call void @__csan_detach_continue(i64 %7, i64 %1)
  %383 = load i64, i64* @__csi_unit_sync_base_id, align 8, !invariant.load !2
  %384 = add i64 %383, 146
  call void @__csan_sync(i64 %384, i8 0)
  sync within %syncreg19.i.i, label %sync.continue.i.i
}

; CHECK-LABEL: define {{.*}}void @_ZN6parlay8to_charsIjjEENS_8sequenceIcNS_9allocatorIcEEEERKSt4pairIT_T0_E.outline_pfor.body.i.i.4.otd1(
; CHECK: i64 %[[ARG1:[a-zA-Z0-9._]+]],
; CHECK: i64 %[[ARG2:[a-zA-Z0-9._]+]],
; CHECK: [5 x %"class.parlay::sequence"]*

; CHECK: pfor.body.i.i.4.otd1:
; CHECK: call void @__csan_task(i64 %[[ARG1]], i64 %[[ARG2]]

; CHECK: lpad.i147178.otd1:
; CHECK: %[[SHARED_TASK_EXIT_ARG1:.+]] = phi i64 [ %[[ARG1]], %pfor.body.i.i.4.otd1 ]
; CHECK: %[[SHARED_TASK_EXIT_ARG2:.+]] = phi i64 [ %[[ARG2]], %pfor.body.i.i.4.otd1 ]
; CHECK: call void @__csan_task_exit(i64 %{{.+}}, i64 %[[SHARED_TASK_EXIT_ARG1]], i64 %[[SHARED_TASK_EXIT_ARG2]],


; CHECK-LABEL: define {{.*}}void @_ZN6parlay8to_charsIjjEENS_8sequenceIcNS_9allocatorIcEEEERKSt4pairIT_T0_E.outline_pfor.body.i.i.3.otd1(
; CHECK: i64 %[[ARG1:[a-zA-Z0-9._]+]],
; CHECK: i64 %[[ARG2:[a-zA-Z0-9._]+]],
; CHECK: [5 x %"class.parlay::sequence"]*

; CHECK: pfor.body.i.i.3.otd1:
; CHECK: call void @__csan_task(i64 %[[ARG1]], i64 %[[ARG2]]

; CHECK: lpad.i147178.otd1:
; CHECK: %[[SHARED_TASK_EXIT_ARG1:.+]] = phi i64 [ %[[ARG1]], %pfor.body.i.i.3.otd1 ]
; CHECK: %[[SHARED_TASK_EXIT_ARG2:.+]] = phi i64 [ %[[ARG2]], %pfor.body.i.i.3.otd1 ]
; CHECK: call void @__csan_task_exit(i64 %{{.+}}, i64 %[[SHARED_TASK_EXIT_ARG1]], i64 %[[SHARED_TASK_EXIT_ARG2]],


; CHECK-LABEL: define {{.*}}void @_ZN6parlay8to_charsIjjEENS_8sequenceIcNS_9allocatorIcEEEERKSt4pairIT_T0_E.outline_pfor.body.i.i.2.otd1(
; CHECK: i64 %[[ARG1:[a-zA-Z0-9._]+]],
; CHECK: i64 %[[ARG2:[a-zA-Z0-9._]+]],
; CHECK: [5 x %"class.parlay::sequence"]*

; CHECK: pfor.body.i.i.2.otd1:
; CHECK: call void @__csan_task(i64 %[[ARG1]], i64 %[[ARG2]]

; CHECK: lpad.i147178.otd1:
; CHECK: %[[SHARED_TASK_EXIT_ARG1:.+]] = phi i64 [ %[[ARG1]], %pfor.body.i.i.2.otd1 ]
; CHECK: %[[SHARED_TASK_EXIT_ARG2:.+]] = phi i64 [ %[[ARG2]], %pfor.body.i.i.2.otd1 ]
; CHECK: call void @__csan_task_exit(i64 %{{.+}}, i64 %[[SHARED_TASK_EXIT_ARG1]], i64 %[[SHARED_TASK_EXIT_ARG2]],


; CHECK-LABEL: define {{.*}}void @_ZN6parlay8to_charsIjjEENS_8sequenceIcNS_9allocatorIcEEEERKSt4pairIT_T0_E.outline_pfor.body.i.i.otd1(
; CHECK: i64 %[[ARG1:[a-zA-Z0-9._]+]],
; CHECK: i64 %[[ARG2:[a-zA-Z0-9._]+]],
; CHECK: [5 x %"class.parlay::sequence"]*

; CHECK: pfor.body.i.i.otd1:
; CHECK: call void @__csan_task(i64 %[[ARG1]], i64 %[[ARG2]]

; CHECK: lpad.i147178.otd1:
; CHECK: %[[SHARED_TASK_EXIT_ARG1:.+]] = phi i64 [ %[[ARG1]], %pfor.body.i.i.otd1 ]
; CHECK: %[[SHARED_TASK_EXIT_ARG2:.+]] = phi i64 [ %[[ARG2]], %pfor.body.i.i.otd1 ]
; CHECK: call void @__csan_task_exit(i64 %{{.+}}, i64 %[[SHARED_TASK_EXIT_ARG1]], i64 %[[SHARED_TASK_EXIT_ARG2]],

; Function Attrs: inlinehint uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S7_St26random_access_iterator_tagEUlmE_EEvmmS7_mb(i64, i64, %class.anon.332* byval(%class.anon.332) align 8, i64, i1 zeroext) local_unnamed_addr #1

; Function Attrs: nounwind uwtable
declare dso_local void @_ZN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_implD2Ev(%"struct.parlay::_sequence_base<parlay::sequence<char, parlay::allocator<char> >, parlay::allocator<parlay::sequence<char, parlay::allocator<char> > > >::_sequence_impl"*) unnamed_addr #2

; Function Attrs: uwtable
declare dso_local void @_ZN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_implC2ERKS4_(%"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"*, %"struct.parlay::_sequence_base<char, parlay::allocator<char> >::_sequence_impl"* dereferenceable(15)) unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator"*, i8*, i64) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator"*, i64) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN6parlay7flattenINS_8sequenceINS1_IcNS_9allocatorIcEEEENS2_IS4_EEEEEEDaRKT_(%"class.parlay::sequence"* noalias sret, %"class.parlay::sequence.2"* dereferenceable(15)) local_unnamed_addr #0

; Function Attrs: inlinehint uwtable
declare dso_local dereferenceable(96) %"struct.parlay::pool_allocator"* @_ZN6parlay8internal21get_default_allocatorEv() local_unnamed_addr #1

; Function Attrs: uwtable
declare dso_local void @_ZN6parlay8sequenceIcNS_9allocatorIcEEEC2IRZNS_8to_charsERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEEUlmE_EEmOT_NS3_18_from_function_tagEm(%"class.parlay::sequence"*, i64, %class.anon.413* dereferenceable(8), i64) unnamed_addr #0

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #3

; Function Attrs: noinline noreturn nounwind
declare void @__clang_call_terminate(i8*) local_unnamed_addr #4

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #5

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #5

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #5

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #6

; Function Attrs: nofree nounwind
declare dso_local i32 @snprintf(i8* noalias nocapture, i64, i8* nocapture readonly, ...) local_unnamed_addr #7

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #6

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
declare void @__csan_after_free(i64, i8* nocapture readnone, i64) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__cilksan_disable_checking() #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_get_MAAP(i8* nocapture, i64, i8) #8

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_set_MAAP(i8, i64) #8

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #9

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #10

; Function Attrs: nounwind willreturn
declare i8* @llvm.task.frameaddress(i32) #11

; Function Attrs: inaccessiblemem_or_argmemonly nounwind
declare void @__csan_snprintf(i64, i64, i8, i64, i32, i8*, i64, i8*, ...) #8

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { inlinehint uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noinline noreturn nounwind }
attributes #5 = { argmemonly nounwind willreturn }
attributes #6 = { argmemonly willreturn }
attributes #7 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { inaccessiblemem_or_argmemonly nounwind }
attributes #9 = { nounwind readnone }
attributes #10 = { nounwind }
attributes #11 = { nounwind willreturn }
attributes #12 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git fffc5516029927e6f93460fb66ad35b34f9b0b9b)"}
!2 = !{}
!3 = !{!4, !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !8, i64 0}
!7 = !{!"_ZTSSt4pairIjjE", !8, i64 0, !8, i64 4}
!8 = !{!"int", !4, i64 0}
!9 = !{!10, !12}
!10 = distinct !{!10, !11, !"_ZN6parlay8to_charsEm: %agg.result"}
!11 = distinct !{!11, !"_ZN6parlay8to_charsEm"}
!12 = distinct !{!12, !13, !"_ZN6parlay8to_charsEj: %agg.result"}
!13 = distinct !{!13, !"_ZN6parlay8to_charsEj"}
!14 = !{!15, !15, i64 0}
!15 = !{!"any pointer", !4, i64 0}
!16 = !{!17, !18, i64 0}
!17 = !{!"_ZTSN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl18capacitated_buffer6headerE", !18, i64 0, !4, i64 8}
!18 = !{!"long", !4, i64 0}
!19 = !{i64 0, i64 8, !14, i64 8, i64 8, !20}
!20 = !{!18, !18, i64 0}
!21 = !{!22, !15, i64 0}
!22 = !{!"_ZTSZN6parlay8sequenceIcNS_9allocatorIcEEE16initialize_rangeIPcEEvT_S6_St26random_access_iterator_tagEUlmE_", !15, i64 0, !15, i64 8, !15, i64 16}
!23 = !{!24, !15, i64 0}
!24 = !{!"_ZTSN6parlay14_sequence_baseIcNS_9allocatorIcEEE14_sequence_impl18capacitated_bufferE", !15, i64 0}
!25 = !{!26, !15, i64 0}
!26 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_Alloc_hiderE", !15, i64 0}
!27 = !{!28, !18, i64 8}
!28 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", !26, i64 0, !18, i64 8, !4, i64 16}
!29 = !{!30}
!30 = distinct !{!30, !31, !"_ZN6parlay8to_charsERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE: %agg.result"}
!31 = distinct !{!31, !"_ZN6parlay8to_charsERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE"}
!32 = !{!7, !8, i64 4}
!33 = !{!34, !36}
!34 = distinct !{!34, !35, !"_ZN6parlay8to_charsEm: %agg.result"}
!35 = distinct !{!35, !"_ZN6parlay8to_charsEm"}
!36 = distinct !{!36, !37, !"_ZN6parlay8to_charsEj: %agg.result"}
!37 = distinct !{!37, !"_ZN6parlay8to_charsEj"}
!38 = !{!39, !18, i64 0}
!39 = !{!"_ZTSN6parlay14_sequence_baseINS_8sequenceIcNS_9allocatorIcEEEENS2_IS4_EEE14_sequence_impl18capacitated_buffer6headerE", !18, i64 0, !4, i64 8}
!40 = !{!28, !15, i64 0}
