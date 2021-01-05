; RUN: opt < %s -loop-spawning-ti -S -o - | FileCheck %s
; RUN: opt < %s -passes='loop-spawning' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%struct.timer = type <{ double, double, double, i8, [3 x i8], %struct.timezone, [4 x i8] }>
%struct.timezone = type { i32, i32 }
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
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt*, %struct._IO_wide_data*, %struct._IO_FILE*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type opaque
%struct._IO_codecvt = type opaque
%struct._IO_wide_data = type opaque
%"struct.std::pair" = type { i32, i32 }
%"class.std::basic_ifstream" = type { %"class.std::basic_istream.base", %"class.std::basic_filebuf", %"class.std::basic_ios" }
%"class.std::basic_istream.base" = type { i32 (...)**, i64 }
%"class.std::basic_filebuf" = type { %"class.std::basic_streambuf", %union.pthread_mutex_t, %"class.std::__basic_file", i32, %struct.__mbstate_t, %struct.__mbstate_t, %struct.__mbstate_t, i8*, i64, i8, i8, i8, i8, i8*, i8*, i8, %"class.std::codecvt"*, i8*, i64, i8*, i8* }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%"class.std::__basic_file" = type <{ %struct._IO_FILE*, i8, [7 x i8] }>
%struct.__mbstate_t = type { i32, %union.anon }
%union.anon = type { i32 }
%"class.std::codecvt" = type { %"class.std::__codecvt_abstract_base.base", %struct.__locale_struct* }
%"class.std::__codecvt_abstract_base.base" = type { %"class.std::locale::facet.base" }
%"class.std::basic_istream" = type { i32 (...)**, i64, %"class.std::basic_ios" }
%struct.words = type { i64, i8*, i64, i8** }
%struct.commandLine = type { i32, i8**, %"class.std::__cxx11::basic_string" }
%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i64, %union.anon.1 }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider" = type { i8* }
%union.anon.1 = type { i64, [8 x i8] }
%struct.graph = type { %struct.compressedSymmetricVertex*, i64, i64, i8, i32*, %struct.Deletable* }
%struct.compressedSymmetricVertex = type { i8*, i32 }
%struct.Deletable = type { i32 (...)** }
%struct.graph.2 = type { %struct.compressedAsymmetricVertex*, i64, i64, i8, i32*, %struct.Deletable* }
%struct.compressedAsymmetricVertex = type { i8*, i8*, i32, i32 }
%struct.graph.3 = type { %struct.symmetricVertex*, i64, i64, i8, i32*, %struct.Deletable* }
%struct.symmetricVertex = type <{ i32*, i32, [4 x i8] }>
%struct.graph.4 = type { %struct.asymmetricVertex*, i64, i64, i8, i32*, %struct.Deletable* }
%struct.asymmetricVertex = type { i32*, i32*, i32, i32 }
%struct.stat = type { i64, i64, i64, i32, i32, i32, i32, i64, i64, i64, i64, %struct.timespec, %struct.timespec, %struct.timespec, [3 x i64] }
%struct.timespec = type { i64, i64 }
%struct.timeval = type { i64, i64 }
%struct.Compressed_Mem = type { %struct.Deletable, %struct.compressedSymmetricVertex*, i8* }
%struct.vertexSubsetData = type <{ i32*, i8*, i64, i64, i8, [7 x i8] }>
%struct.BFS_F = type { i32* }
%struct.array_imap = type <{ i32*, i32*, i8, [7 x i8] }>
%struct.in_imap.6 = type { %class.anon.5, i64, i64 }
%class.anon.5 = type { i8 }
%struct.in_imap = type { %class.anon, i64, i64 }
%class.anon = type { i8** }
%struct.array_imap.7 = type <{ i64*, i64*, i8, [7 x i8] }>
%class.anon.11 = type { i8 }
%class.anon.14 = type { %struct.array_imap.7*, %struct.array_imap.7*, %class.anon.11*, %struct.array_imap.7*, i32* }
%"class.std::tuple" = type { %"struct.std::_Tuple_impl" }
%"struct.std::_Tuple_impl" = type { %"struct.std::_Head_base.18" }
%"struct.std::_Head_base.18" = type { i8 }
%struct.in_imap.25 = type { %class.anon.26, i64, i64 }
%class.anon.26 = type { %"class.std::tuple"** }
%class.anon.27 = type { i8 }
%"struct.decode_compressed::denseT" = type { %struct.vertexSubsetData, %struct.BFS_F, %class.anon.31 }
%class.anon.31 = type { %"class.std::tuple"* }
%"struct.decode_compressed::denseT.34" = type <{ %struct.vertexSubsetData, %struct.BFS_F, %class.anon.32, [7 x i8] }>
%class.anon.32 = type { i8 }
%"class.std::tuple.35" = type { %"struct.std::_Tuple_impl.36" }
%"struct.std::_Tuple_impl.36" = type { %"struct.std::_Head_base.37" }
%"struct.std::_Head_base.37" = type { i32 }
%"struct.decode_compressed::sparseTSeq" = type { i32, i32, %struct.BFS_F, %class.anon.38, i64* }
%class.anon.38 = type { %"class.std::tuple.35"* }
%"struct.decode_compressed::sparseT" = type { i32, i32, %struct.BFS_F, %class.anon.48 }
%class.anon.48 = type { %"class.std::tuple.35"* }
%"struct.decode_compressed::sparseT.54" = type <{ i32, i32, %struct.BFS_F, %class.anon.49, [7 x i8] }>
%class.anon.49 = type { i8 }
%struct.Compressed_Mem.55 = type { %struct.Deletable, %struct.compressedAsymmetricVertex*, i8* }
%"struct.std::pair.66" = type { i32, i32 }
%"struct.intSort::eBits" = type { %struct.getFirst, i64, i64 }
%struct.getFirst = type { i8 }
%struct.transpose = type { i32*, i32* }
%struct.blockTrans = type { %"struct.std::pair.66"*, %"struct.std::pair.66"*, i32*, i32*, i32* }
%struct.transpose.71 = type { i64*, i64* }
%struct.blockTrans.73 = type { %"struct.std::pair.66"*, %"struct.std::pair.66"*, i64*, i64*, i64* }
%struct.Uncompressed_Mem = type { %struct.Deletable, %struct.symmetricVertex*, i64, i64, i8*, i8* }
%struct.Uncompressed_Mem.87 = type { %struct.Deletable, %struct.asymmetricVertex*, i64, i64, i8*, i8* }
%class.anon.19 = type { %"class.std::tuple"* }
%"class.std::tuple.22" = type { %"struct.std::_Tuple_impl.23" }
%"struct.std::_Tuple_impl.23" = type { %"struct.std::_Head_base.24" }
%"struct.std::_Head_base.24" = type { i32 }
%class.anon.20 = type { i8 }

$_Z19edgeMapDenseForwardIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = comdat any

@_ZStL8__ioinit = external dso_local global %"class.std::ios_base::Init", align 1
@__dso_handle = external hidden global i8
@_ZL3_tm = external dso_local global %struct.timer, align 8
@_ZSt4cout = external dso_local global %"class.std::basic_ostream", align 8
@.str = external dso_local unnamed_addr constant [32 x i8], align 1
@.str.4 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.5 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.6 = external dso_local unnamed_addr constant [28 x i8], align 1
@.str.7 = external dso_local unnamed_addr constant [24 x i8], align 1
@.str.8 = external dso_local unnamed_addr constant [36 x i8], align 1
@.str.9 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.10 = external dso_local unnamed_addr constant [5 x i8], align 1
@.str.11 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.12 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.13 = external dso_local unnamed_addr constant [5 x i8], align 1
@.str.14 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.15 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.16 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.21 = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.22 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.23 = external dso_local unnamed_addr constant [42 x i8], align 1
@.str.24 = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.25 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.26 = external dso_local unnamed_addr constant [4 x i8], align 1
@_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE = external unnamed_addr constant [4 x i8*], align 8
@.str.27 = external dso_local unnamed_addr constant [7 x i8], align 1
@.str.28 = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.29 = external dso_local unnamed_addr constant [5 x i8], align 1
@.str.30 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.31 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.32 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.33 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.34 = external dso_local unnamed_addr constant [18 x i8], align 1
@_ZTV14Compressed_MemI25compressedSymmetricVertexE = external dso_local unnamed_addr constant { [3 x i8*] }, align 8
@_ZTVN10__cxxabiv120__si_class_type_infoE = external dso_local global i8*
@_ZTS14Compressed_MemI25compressedSymmetricVertexE = external dso_local constant [46 x i8], align 1
@_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global i8*
@_ZTS9Deletable = external dso_local constant [11 x i8], align 1
@_ZTI9Deletable = external dso_local constant { i8*, i8* }, align 8
@_ZTI14Compressed_MemI25compressedSymmetricVertexE = external dso_local constant { i8*, i8*, i8* }, align 8
@.str.36 = external dso_local unnamed_addr constant [27 x i8], align 1
@.str.37 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.38 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.39 = external dso_local unnamed_addr constant [6 x i8], align 1
@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE*, align 8
@.str.40 = external dso_local unnamed_addr constant [22 x i8], align 1
@_ZTV14Compressed_MemI26compressedAsymmetricVertexE = external dso_local unnamed_addr constant { [3 x i8*] }, align 8
@_ZTS14Compressed_MemI26compressedAsymmetricVertexE = external dso_local constant [47 x i8], align 1
@_ZTI14Compressed_MemI26compressedAsymmetricVertexE = external dso_local constant { i8*, i8*, i8* }, align 8
@.str.42 = external dso_local unnamed_addr constant [5 x i8], align 1
@.str.43 = external dso_local unnamed_addr constant [5 x i8], align 1
@.str.44 = external dso_local unnamed_addr constant [17 x i8], align 1
@_ZTV16Uncompressed_MemI15symmetricVertexE = external dso_local unnamed_addr constant { [3 x i8*] }, align 8
@_ZTS16Uncompressed_MemI15symmetricVertexE = external dso_local constant [38 x i8], align 1
@_ZTI16Uncompressed_MemI15symmetricVertexE = external dso_local constant { i8*, i8*, i8* }, align 8
@.str.45 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.46 = external dso_local unnamed_addr constant [15 x i8], align 1
@_ZTV16Uncompressed_MemI16asymmetricVertexE = external dso_local unnamed_addr constant { [3 x i8*] }, align 8
@_ZTS16Uncompressed_MemI16asymmetricVertexE = external dso_local constant [39 x i8], align 1
@_ZTI16Uncompressed_MemI16asymmetricVertexE = external dso_local constant { i8*, i8*, i8* }, align 8
@__csi_unit_func_base_id = external dso_local global i64
@__csi_unit_func_exit_base_id = external dso_local global i64
@__csi_unit_loop_base_id = external dso_local global i64
@__csi_unit_loop_exit_base_id = external dso_local global i64
@__csi_unit_bb_base_id = external dso_local global i64
@__csi_unit_callsite_base_id = external dso_local global i64
@__csi_unit_load_base_id = external dso_local global i64
@__csi_unit_store_base_id = external dso_local global i64
@__csi_unit_alloca_base_id = external dso_local global i64
@__csi_unit_detach_base_id = external dso_local global i64
@__csi_unit_task_base_id = external dso_local global i64
@__csi_unit_task_exit_base_id = external dso_local global i64
@__csi_unit_detach_continue_base_id = external dso_local global i64
@__csi_unit_sync_base_id = external dso_local global i64
@__csi_unit_allocfn_base_id = external dso_local global i64
@__csi_unit_free_base_id = external dso_local global i64
@__csi_func_id__ZN8sequence4scanIll4addFIlENS_4getAIllEEEET_PS5_T0_S7_T1_T2_S5_bb = external global i64
@__csi_func_id__ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l = external global i64
@__csi_func_id__ZNSo9_M_insertIlEERSoT_ = external global i64
@__csi_func_id__ZSt16__throw_bad_castv = external global i64
@__csi_func_id__ZNKSt5ctypeIcE13_M_widen_initEv = external global i64
@__csi_func_id__ZNSo3putEc = external global i64
@__csi_func_id__ZNSo5flushEv = external global i64
@__csi_func_id__Z25sequentialCompressEdgeSetPhljjPj = external global i64
@__csi_func_id__ZNSo9_M_insertIdEERSoT_ = external global i64
@__csi_func_id__Z33sequentialCompressWeightedEdgeSetPhljjPSt4pairIjiE = external global i64
@__csi_func_id_open = external global i64
@__csi_func_id___fxstat = external global i64
@__csi_func_id_mmap = external global i64
@__csi_func_id_close = external global i64
@__csi_func_id__ZNSt14basic_ifstreamIcSt11char_traitsIcEEC1EPKcSt13_Ios_Openmode = external global i64
@__csi_func_id__ZNKSt12__basic_fileIcE7is_openEv = external global i64
@__csi_func_id__ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate = external global i64
@__csi_func_id_strlen = external global i64
@__csi_func_id__ZNSi5tellgEv = external global i64
@__csi_func_id__ZNSi5seekgElSt12_Ios_Seekdir = external global i64
@__csi_func_id__ZNSi4readEPcl = external global i64
@__csi_func_id__ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv = external global i64
@__csi_func_id__ZNSt13basic_filebufIcSt11char_traitsIcEED2Ev = external global i64
@__csi_func_id__ZNSt8ios_baseD2Ev = external global i64
@__csi_func_id__ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_ = external global i64
@__csi_func_id__ZN8sequence4packIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_ = external global i64
@__csi_func_id__ZSt19__throw_logic_errorPKc = external global i64
@__csi_func_id__ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm = external global i64
@__csi_func_id_bcmp = external global i64
@__csi_func_id__ZdlPv = external global i64
@__csi_func_id_strtol = external global i64
@__csi_func_id__Z18mmapStringFromFilePKc = external global i64
@__csi_func_id_munmap = external global i64
@__csi_func_id__ZNSi5seekgESt4fposI11__mbstate_tE = external global i64
@__csi_func_id__ZN4pbbs10sliced_forIZNS_4scanI10array_imapImES3_ZNS_8scan_addIS3_S3_EENT_1TES5_T0_jEUlmmE_EES6_S5_S7_RKT1_S6_jEUlmmmE0_EEvmmRKS5_ = external global i64
@__csi_func_id__ZN4pbbs4scanI10array_imapImES2_ZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_S6_RKT1_S5_j = external global i64
@__csi_func_id__ZN4pbbs8scan_addI10array_imapImES2_EENT_1TES3_T0_j = external global i64
@__csi_func_id__ZN4pbbs4packI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_j = external global i64
@__csi_func_id__ZNSo9_M_insertImEERSoT_ = external global i64
@__csi_func_id__ZN8sequence6reduceIjl4addFIjENS_4getAIjlEEEET_T0_S6_T1_T2_ = external global i64
@__csi_func_id__Z6decodeIN17decode_compressed13denseForwardTI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEEvS7_PhRKjSE_b = external global i64
@__csi_func_id__ZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS3_EEEUlmE_EZNS4_C1ElS7_EUlmmE_EENT_1TESB_RKT0_j = external global i64
@__csi_func_id__Z6decodeIN17decode_compressed13denseForwardTI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEEvT_PhRKjSB_b = external global i64
@__csi_func_id__Z6decodeIN17decode_compressed6denseTI5BFS_FZ15get_emdense_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_16vertexSubsetDataIS5_EEEEvS7_PhRKjSG_b = external global i64
@__csi_func_id__Z6decodeIN17decode_compressed6denseTI5BFS_FZ24get_emdense_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_16vertexSubsetDataIS5_EEEEvT_PhRKjSD_b = external global i64
@__csi_func_id__ZN8sequence4scanIjj4addFIjENS_4getAIjjEEEET_PS5_T0_S7_T1_T2_S5_bb = external global i64
@__csi_func_id__ZN8sequence4scanIjm4addFIjENS_4getAIjmEEEET_PS5_T0_S7_T1_T2_S5_bb = external global i64
@__csi_func_id__Z6decodeIN17decode_compressed10sparseTSeqI5BFS_FZ26get_emsparse_no_filter_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_EEEvS7_PhRKjSE_b = external global i64
@__csi_func_id__ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_ = external global i64
@__csi_func_id__Z6decodeIN17decode_compressed7sparseTI5BFS_FZ16get_emsparse_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_EEEvS7_PhRKjSE_b = external global i64
@__csi_func_id__Z6decodeIN17decode_compressed7sparseTI5BFS_FZ25get_emsparse_nooutput_genIN4pbbs5emptyELi0EEDavEUljjbE_EEEvT_PhRKjSB_b = external global i64
@__csi_func_id__ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_ = external global i64
@__csi_func_id__ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc = external global i64
@__csi_func_id__ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_ = external global i64
@__csi_func_id__ZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEv = external global i64
@__csi_func_id__Z19edgeMapDenseForwardIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = external global i64
@__csi_func_id__Z12edgeMapDenseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = external global i64
@__csi_func_id__Z23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j = external global i64
@__csi_func_id__Z13edgeMapSparseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j = external global i64
@__csi_func_id__ZN11commandLine18getOptionLongValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEl = external global i64
@__csi_func_id__Z11edgeMapDataIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj = external global i64
@__csi_func_id__ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_ = external global i64
@__csi_func_id__ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_ = external global i64
@__csi_func_id__Z19edgeMapDenseForwardIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = external global i64
@__csi_func_id__Z12edgeMapDenseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = external global i64
@__csi_func_id__Z23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j = external global i64
@__csi_func_id__Z13edgeMapSparseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j = external global i64
@__csi_func_id__Z11edgeMapDataIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj = external global i64
@__csi_func_id__ZN9transposeIjjE6transREjjjjjj = external global i64
@__csi_func_id__ZN8sequence4scanIjl4addFIjENS_4getAIjlEEEET_PS5_T0_S7_T1_T2_S5_bb = external global i64
@__csi_func_id__ZN10blockTransISt4pairIjjEjE6transREjjjjjj = external global i64
@__csi_func_id__ZN7intSort9radixStepISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEjEEvPT_S8_PhPA256_T1_lllbT0_ = external global i64
@__csi_func_id__ZN7intSort16radixLoopTopDownISt4pairIjjE8getFirstIjEjEEvPT_S6_PhPA256_T1_lllT0_ = external global i64
@__csi_func_id__ZN9transposeImmE6transREmmmmmm = external global i64
@__csi_func_id__ZN8sequence4scanIml4addFImENS_4getAImlEEEET_PS5_T0_S7_T1_T2_S5_bb = external global i64
@__csi_func_id__ZN10blockTransISt4pairIjjEmE6transREmmmmmm = external global i64
@__csi_func_id__ZN7intSort9radixStepISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEmEEvPT_S8_PhPA256_T1_lllbT0_ = external global i64
@__csi_func_id__ZN7intSort16radixLoopTopDownISt4pairIjjE8getFirstIjEmEEvPT_S6_PhPA256_T1_lllT0_ = external global i64
@__csi_func_id__ZN8sequence4scanIjl4minFIjENS_4getAIjlEEEET_PS5_T0_S7_T1_T2_S5_bb = external global i64
@__csi_func_id_strcat = external global i64
@__csi_func_id__ZNSi10_M_extractIlEERSiRT_ = external global i64
@__csi_func_id__ZN7intSort5iSortISt4pairIjjE8getFirstIjEEEvPT_llT0_ = external global i64
@__csi_func_id__Z13stringToWordsPcl = external global i64
@__csi_func_id__Z18readStringFromFilePc = external global i64
@__csi_func_id__ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE7compareEPKc = external global i64
@__csi_func_id__ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_ = external global i64
@__csi_func_id__ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_ = external global i64
@__csi_func_id__Z19edgeMapDenseForwardIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = external global i64
@__csi_func_id__Z12edgeMapDenseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = external global i64
@__csi_func_id__Z23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j = external global i64
@__csi_func_id__Z13edgeMapSparseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j = external global i64
@__csi_func_id__Z11edgeMapDataIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj = external global i64
@__csi_func_id__ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_ = external global i64
@__csi_func_id__ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_ = external global i64
@__csi_func_id__Z19edgeMapDenseForwardIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = external global i64
@__csi_func_id__Z12edgeMapDenseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j = external global i64
@__csi_func_id__Z23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j = external global i64
@__csi_func_id__Z13edgeMapSparseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j = external global i64
@__csi_func_id__Z11edgeMapDataIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj = external global i64
@__csi_func_id__ZN11commandLine14getOptionValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE = external global i64
@__csi_func_id__Z19readCompressedGraphI25compressedSymmetricVertexE5graphIT_EPcbb = external global i64
@__csi_func_id__Z7ComputeI25compressedSymmetricVertexEvR5graphIT_E11commandLine = external global i64
@__csi_func_id_gettimeofday = external global i64
@__csi_func_id__ZN5timer7reportTEd = external global i64
@__csi_func_id__Z19readCompressedGraphI26compressedAsymmetricVertexE5graphIT_EPcbb = external global i64
@__csi_func_id__Z7ComputeI26compressedAsymmetricVertexEvR5graphIT_E11commandLine = external global i64
@__csi_func_id__Z19readGraphFromBinaryI15symmetricVertexE5graphIT_EPcb = external global i64
@__csi_func_id__Z17readGraphFromFileI15symmetricVertexE5graphIT_EPcbb = external global i64
@__csi_func_id__Z7ComputeI15symmetricVertexEvR5graphIT_E11commandLine = external global i64
@__csi_func_id__Z19readGraphFromBinaryI16asymmetricVertexE5graphIT_EPcb = external global i64
@__csi_func_id__Z17readGraphFromFileI16asymmetricVertexE5graphIT_EPcbb = external global i64
@__csi_func_id__Z7ComputeI16asymmetricVertexEvR5graphIT_E11commandLine = external global i64
@__csi_func_id__ZNSt8ios_base4InitC1Ev = external global i64
@__csi_func_id___cxa_atexit = external global i64
@__csi_func_id_mallopt = external global i64
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./utils.h" = external dso_local unnamed_addr constant [43 x i8]
@__csi_unit_function_name_hash32 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_function_name_hash64 = external dso_local unnamed_addr constant [7 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./byteRLE.h" = external dso_local unnamed_addr constant [45 x i8]
@__csi_unit_function_name_compressFirstEdge = external dso_local unnamed_addr constant [18 x i8]
@__csi_unit_function_name_compressEdges = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_function_name_sequentialCompressEdgeSet = external dso_local unnamed_addr constant [26 x i8]
@"__csi_unit_function_name_scan<long, long, addF<long>, sequence::getA<long, long> >" = external dso_local unnamed_addr constant [58 x i8]
@__csi_unit_function_name_parallelCompressEdges = external dso_local unnamed_addr constant [22 x i8]
@__csi_unit_function_name_numBytesSigned = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_function_name_compressWeightedEdges = external dso_local unnamed_addr constant [22 x i8]
@__csi_unit_function_name_sequentialCompressWeightedEdgeSet = external dso_local unnamed_addr constant [34 x i8]
@__csi_unit_function_name_parallelCompressWeightedEdges = external dso_local unnamed_addr constant [30 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./IO.h" = external dso_local unnamed_addr constant [40 x i8]
@__csi_unit_function_name_mmapStringFromFile = external dso_local unnamed_addr constant [19 x i8]
@__csi_unit_function_name_readStringFromFile = external dso_local unnamed_addr constant [19 x i8]
@"__csi_unit_function_name_packSerial<long, long, identityF<long> >" = external dso_local unnamed_addr constant [41 x i8]
@"__csi_unit_function_name_pack<long, long, identityF<long> >" = external dso_local unnamed_addr constant [35 x i8]
@__csi_unit_function_name_stringToWords = external dso_local unnamed_addr constant [14 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./parseCommandLine.h" = external dso_local unnamed_addr constant [54 x i8]
@__csi_unit_function_name_getOptionValue = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_function_name_getOptionLongValue = external dso_local unnamed_addr constant [19 x i8]
@"__csi_unit_function_name_readCompressedGraph<compressedSymmetricVertex>" = external dso_local unnamed_addr constant [47 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./sequence.h" = external dso_local unnamed_addr constant [46 x i8]
@"__csi_unit_function_name_sliced_for<(lambda at ./sequence.h:139:17)>" = external dso_local unnamed_addr constant [44 x i8]
@"__csi_unit_function_name_scan<array_imap<unsigned long>, array_imap<unsigned long>, (lambda at ./sequence.h:149:16)>" = external dso_local unnamed_addr constant [92 x i8]
@"__csi_unit_function_name_scan_add<array_imap<unsigned long>, array_imap<unsigned long> >" = external dso_local unnamed_addr constant [64 x i8]
@"__csi_unit_function_name_pack<in_imap<unsigned int, (lambda at ./sequence.h:205:21)>, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >" = external dso_local unnamed_addr constant [114 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./vertexSubset.h" = external dso_local unnamed_addr constant [50 x i8]
@__csi_unit_function_name_toSparse = external dso_local unnamed_addr constant [9 x i8]
@"__csi_unit_function_name_reduce<unsigned int, long, addF<unsigned int>, sequence::getA<unsigned int, long> >" = external dso_local unnamed_addr constant [84 x i8]
@"__csi_unit_function_name_decode<decode_compressed::denseForwardT<BFS_F, (lambda at ./edgeMap_utils.h:30:10)> >" = external dso_local unnamed_addr constant [86 x i8]
@"__csi_unit_function_name_reduce<in_imap<unsigned long, (lambda at ./vertexSubset.h:151:42)>, (lambda at ./vertexSubset.h:152:14)>" = external dso_local unnamed_addr constant [105 x i8]
@"__csi_unit_function_name_decode<decode_compressed::denseForwardT<BFS_F, (lambda at ./edgeMap_utils.h:124:10)> >" = external dso_local unnamed_addr constant [87 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./ligra.h" = external dso_local unnamed_addr constant [43 x i8]
@"__csi_unit_function_name_edgeMapDenseForward<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [98 x i8]
@"__csi_unit_function_name_decode<decode_compressed::denseT<BFS_F, (lambda at ./edgeMap_utils.h:15:10), vertexSubsetData<pbbs::empty> > >" = external dso_local unnamed_addr constant [111 x i8]
@"__csi_unit_function_name_decode<decode_compressed::denseT<BFS_F, (lambda at ./edgeMap_utils.h:112:10), vertexSubsetData<pbbs::empty> > >" = external dso_local unnamed_addr constant [112 x i8]
@"__csi_unit_function_name_edgeMapDense<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [91 x i8]
@"__csi_unit_function_name_scan<unsigned int, unsigned int, addF<unsigned int>, sequence::getA<unsigned int, unsigned int> >" = external dso_local unnamed_addr constant [98 x i8]
@"__csi_unit_function_name_decode<decode_compressed::sparseTSeq<BFS_F, (lambda at ./edgeMap_utils.h:72:10)> >" = external dso_local unnamed_addr constant [83 x i8]
@"__csi_unit_function_name_scan<unsigned int, unsigned long, addF<unsigned int>, sequence::getA<unsigned int, unsigned long> >" = external dso_local unnamed_addr constant [100 x i8]
@"__csi_unit_function_name_filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>" = external dso_local unnamed_addr constant [77 x i8]
@"__csi_unit_function_name_edgeMapSparse_no_filter<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [102 x i8]
@"__csi_unit_function_name_decode<decode_compressed::sparseT<BFS_F, (lambda at ./edgeMap_utils.h:45:10)> >" = external dso_local unnamed_addr constant [80 x i8]
@"__csi_unit_function_name_decode<decode_compressed::sparseT<BFS_F, (lambda at ./edgeMap_utils.h:100:10)> >" = external dso_local unnamed_addr constant [81 x i8]
@"__csi_unit_function_name_filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>" = external dso_local unnamed_addr constant [77 x i8]
@"__csi_unit_function_name_edgeMapSparse<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [92 x i8]
@"__csi_unit_function_name_edgeMapData<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [90 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/BFS.C" = external dso_local unnamed_addr constant [39 x i8]
@"__csi_unit_function_name_Compute<compressedSymmetricVertex>" = external dso_local unnamed_addr constant [35 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./gettime.h" = external dso_local unnamed_addr constant [45 x i8]
@__csi_unit_function_name_reportT = external dso_local unnamed_addr constant [8 x i8]
@"__csi_unit_function_name_readCompressedGraph<compressedAsymmetricVertex>" = external dso_local unnamed_addr constant [48 x i8]
@"__csi_unit_function_name_edgeMapDenseForward<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [99 x i8]
@"__csi_unit_function_name_edgeMapDense<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [92 x i8]
@"__csi_unit_function_name_edgeMapSparse_no_filter<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [103 x i8]
@"__csi_unit_function_name_edgeMapSparse<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [93 x i8]
@"__csi_unit_function_name_edgeMapData<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [91 x i8]
@"__csi_unit_function_name_Compute<compressedAsymmetricVertex>" = external dso_local unnamed_addr constant [36 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./transpose.h" = external dso_local unnamed_addr constant [47 x i8]
@__csi_unit_function_name_transR = external dso_local unnamed_addr constant [7 x i8]
@"__csi_unit_function_name_scan<unsigned int, long, addF<unsigned int>, sequence::getA<unsigned int, long> >" = external dso_local unnamed_addr constant [82 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./blockRadixSort.h" = external dso_local unnamed_addr constant [52 x i8]
@"__csi_unit_function_name_radixStep<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned int>" = external dso_local unnamed_addr constant [143 x i8]
@"__csi_unit_function_name_radixLoopTopDown<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned int>" = external dso_local unnamed_addr constant [94 x i8]
@"__csi_unit_function_name_scan<unsigned long, long, addF<unsigned long>, sequence::getA<unsigned long, long> >" = external dso_local unnamed_addr constant [85 x i8]
@"__csi_unit_function_name_radixStep<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned long>" = external dso_local unnamed_addr constant [144 x i8]
@"__csi_unit_function_name_radixLoopTopDown<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>" = external dso_local unnamed_addr constant [95 x i8]
@"__csi_unit_function_name_iSort<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >" = external dso_local unnamed_addr constant [70 x i8]
@"__csi_unit_function_name_scan<unsigned int, long, minF<unsigned int>, sequence::getA<unsigned int, long> >" = external dso_local unnamed_addr constant [82 x i8]
@"__csi_unit_function_name_readGraphFromBinary<symmetricVertex>" = external dso_local unnamed_addr constant [37 x i8]
@"__csi_unit_function_name_readGraphFromFile<symmetricVertex>" = external dso_local unnamed_addr constant [35 x i8]
@"__csi_unit_function_name_edgeMapDenseForward<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [88 x i8]
@"__csi_unit_function_name_edgeMapDense<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [81 x i8]
@"__csi_unit_function_name_edgeMapSparse_no_filter<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [92 x i8]
@"__csi_unit_function_name_edgeMapSparse<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [82 x i8]
@"__csi_unit_function_name_edgeMapData<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [80 x i8]
@"__csi_unit_function_name_Compute<symmetricVertex>" = external dso_local unnamed_addr constant [25 x i8]
@"__csi_unit_function_name_readGraphFromBinary<asymmetricVertex>" = external dso_local unnamed_addr constant [38 x i8]
@"__csi_unit_function_name_readGraphFromFile<asymmetricVertex>" = external dso_local unnamed_addr constant [36 x i8]
@"__csi_unit_function_name_edgeMapDenseForward<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [89 x i8]
@"__csi_unit_function_name_edgeMapDense<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [82 x i8]
@"__csi_unit_function_name_edgeMapSparse_no_filter<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [93 x i8]
@"__csi_unit_function_name_edgeMapSparse<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [83 x i8]
@"__csi_unit_function_name_edgeMapData<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [81 x i8]
@"__csi_unit_function_name_Compute<asymmetricVertex>" = external dso_local unnamed_addr constant [26 x i8]
@__csi_unit_function_name_main = external dso_local unnamed_addr constant [5 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./graph.h" = external dso_local unnamed_addr constant [43 x i8]
@__csi_unit_function_name_del = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_fed_table__csi_unit_func_base_id = external dso_local global [91 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_func_exit_base_id = external dso_local global [178 x { i8*, i32, i32, i8* }]
@"__csi_unit_function_name_sliced_for<(lambda at ./sequence.h:135:17)>" = external dso_local unnamed_addr constant [44 x i8]
@"__csi_unit_function_name_sliced_for<(lambda at ./sequence.h:191:17)>" = external dso_local unnamed_addr constant [44 x i8]
@"__csi_unit_function_name_sliced_for<(lambda at ./sequence.h:196:17)>" = external dso_local unnamed_addr constant [44 x i8]
@"__csi_unit_function_name_sliced_for<(lambda at ./sequence.h:78:17)>" = external dso_local unnamed_addr constant [43 x i8]
@"__csi_unit_function_name_remDuplicates<(lambda at ./ligra.h:222:20)>" = external dso_local unnamed_addr constant [44 x i8]
@"__csi_unit_function_name_remDuplicates<(lambda at ./ligra.h:144:22)>" = external dso_local unnamed_addr constant [44 x i8]
@__csi_unit_function_name_toDense = external dso_local unnamed_addr constant [8 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./vertex.h" = external dso_local unnamed_addr constant [44 x i8]
@"__csi_unit_function_name_decodeOutNgh<symmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:30:10)>" = external dso_local unnamed_addr constant [74 x i8]
@"__csi_unit_function_name_decodeOutNgh<symmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:124:10)>" = external dso_local unnamed_addr constant [75 x i8]
@"__csi_unit_function_name_decodeInNghBreakEarly<symmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:15:10), vertexSubsetData<pbbs::empty> >" = external dso_local unnamed_addr constant [115 x i8]
@"__csi_unit_function_name_decodeInNghBreakEarly<symmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:112:10), vertexSubsetData<pbbs::empty> >" = external dso_local unnamed_addr constant [116 x i8]
@"__csi_unit_function_name_decodeOutNghSparse<symmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:100:10)>" = external dso_local unnamed_addr constant [81 x i8]
@"__csi_unit_function_name_decodeOutNghSparse<symmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:45:10)>" = external dso_local unnamed_addr constant [80 x i8]
@"__csi_unit_function_name_decodeOutNgh<asymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:30:10)>" = external dso_local unnamed_addr constant [75 x i8]
@"__csi_unit_function_name_decodeOutNgh<asymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:124:10)>" = external dso_local unnamed_addr constant [76 x i8]
@"__csi_unit_function_name_decodeInNghBreakEarly<asymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:15:10), vertexSubsetData<pbbs::empty> >" = external dso_local unnamed_addr constant [116 x i8]
@"__csi_unit_function_name_decodeInNghBreakEarly<asymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:112:10), vertexSubsetData<pbbs::empty> >" = external dso_local unnamed_addr constant [117 x i8]
@"__csi_unit_function_name_decodeOutNghSparse<asymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:100:10)>" = external dso_local unnamed_addr constant [82 x i8]
@"__csi_unit_function_name_decodeOutNghSparse<asymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:45:10)>" = external dso_local unnamed_addr constant [81 x i8]
@__csi_unit_function_name_transpose = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_fed_table__csi_unit_loop_base_id = external dso_local global [140 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_loop_exit_base_id = external dso_local global [0 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_bb_base_id = external dso_local global [0 x { i8*, i32, i32, i8* }]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/ostream" = external dso_local unnamed_addr constant [71 x i8]
@"__csi_unit_function_name_operator<<<std::char_traits<char> >" = external dso_local unnamed_addr constant [36 x i8]
@"__csi_unit_function_name_operator<<" = external dso_local unnamed_addr constant [11 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/basic_ios.h" = external dso_local unnamed_addr constant [80 x i8]
@"__csi_unit_function_name___check_facet<std::ctype<char> >" = external dso_local unnamed_addr constant [33 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/locale_facets.h" = external dso_local unnamed_addr constant [84 x i8]
@__csi_unit_function_name_widen = external dso_local unnamed_addr constant [6 x i8]
@"__csi_unit_function_name_endl<char, std::char_traits<char> >" = external dso_local unnamed_addr constant [36 x i8]
@"__csi_unit_function_name_flush<char, std::char_traits<char> >" = external dso_local unnamed_addr constant [37 x i8]
@"__csi_unit_function_name_plusScan<long, long>" = external dso_local unnamed_addr constant [21 x i8]
@"__csi_unit_filename_/usr/include/sys/stat.h" = external dso_local unnamed_addr constant [24 x i8]
@__csi_unit_function_name_fstat = external dso_local unnamed_addr constant [6 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/fstream" = external dso_local unnamed_addr constant [71 x i8]
@__csi_unit_function_name_is_open = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_function_name_setstate = external dso_local unnamed_addr constant [9 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/char_traits.h" = external dso_local unnamed_addr constant [82 x i8]
@__csi_unit_function_name_length = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_function_name_close = external dso_local unnamed_addr constant [6 x i8]
@"__csi_unit_function_name_~basic_ifstream" = external dso_local unnamed_addr constant [16 x i8]
@"__csi_unit_function_name_~basic_ios" = external dso_local unnamed_addr constant [11 x i8]
@"__csi_unit_function_name_packIndex<long>" = external dso_local unnamed_addr constant [16 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/basic_string.tcc" = external dso_local unnamed_addr constant [85 x i8]
@"__csi_unit_function_name__M_construct<const char *>" = external dso_local unnamed_addr constant [27 x i8]
@__csi_unit_function_name_compare = external dso_local unnamed_addr constant [8 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/ext/new_allocator.h" = external dso_local unnamed_addr constant [83 x i8]
@__csi_unit_function_name_deallocate = external dso_local unnamed_addr constant [11 x i8]
@"__csi_unit_filename_/usr/include/stdlib.h" = external dso_local unnamed_addr constant [22 x i8]
@__csi_unit_function_name_atol = external dso_local unnamed_addr constant [5 x i8]
@"__csi_unit_function_name_pack_index<unsigned int, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >" = external dso_local unnamed_addr constant [78 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./compressedVertex.h" = external dso_local unnamed_addr constant [54 x i8]
@"__csi_unit_function_name_decodeOutNgh<compressedSymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:30:10)>" = external dso_local unnamed_addr constant [84 x i8]
@__csi_unit_function_name_vertexSubsetData = external dso_local unnamed_addr constant [17 x i8]
@"__csi_unit_function_name_decodeOutNgh<compressedSymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:124:10)>" = external dso_local unnamed_addr constant [85 x i8]
@"__csi_unit_function_name_decodeInNghBreakEarly<compressedSymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:15:10), vertexSubsetData<pbbs::empty> >" = external dso_local unnamed_addr constant [125 x i8]
@"__csi_unit_function_name_decodeInNghBreakEarly<compressedSymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:112:10), vertexSubsetData<pbbs::empty> >" = external dso_local unnamed_addr constant [126 x i8]
@"__csi_unit_function_name_plusScan<unsigned int, unsigned int>" = external dso_local unnamed_addr constant [37 x i8]
@"__csi_unit_function_name_decodeOutNghSparseSeq<compressedSymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:72:10)>" = external dso_local unnamed_addr constant [93 x i8]
@"__csi_unit_function_name_plusScan<unsigned int, unsigned long>" = external dso_local unnamed_addr constant [38 x i8]
@"__csi_unit_function_name_decodeOutNghSparse<compressedSymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:45:10)>" = external dso_local unnamed_addr constant [90 x i8]
@"__csi_unit_function_name_decodeOutNghSparse<compressedSymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:100:10)>" = external dso_local unnamed_addr constant [91 x i8]
@"__csi_unit_function_name_plusReduce<unsigned int, long>" = external dso_local unnamed_addr constant [31 x i8]
@"__csi_unit_function_name_edgeMap<compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [73 x i8]
@"__csi_unit_function_name_decodeOutNgh<compressedAsymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:30:10)>" = external dso_local unnamed_addr constant [85 x i8]
@"__csi_unit_function_name_decodeOutNgh<compressedAsymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:124:10)>" = external dso_local unnamed_addr constant [86 x i8]
@"__csi_unit_function_name_decodeInNghBreakEarly<compressedAsymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:15:10), vertexSubsetData<pbbs::empty> >" = external dso_local unnamed_addr constant [126 x i8]
@"__csi_unit_function_name_decodeInNghBreakEarly<compressedAsymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:112:10), vertexSubsetData<pbbs::empty> >" = external dso_local unnamed_addr constant [127 x i8]
@"__csi_unit_function_name_decodeOutNghSparseSeq<compressedAsymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:72:10)>" = external dso_local unnamed_addr constant [94 x i8]
@"__csi_unit_function_name_decodeOutNghSparse<compressedAsymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:45:10)>" = external dso_local unnamed_addr constant [91 x i8]
@"__csi_unit_function_name_decodeOutNghSparse<compressedAsymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:100:10)>" = external dso_local unnamed_addr constant [92 x i8]
@"__csi_unit_function_name_edgeMap<compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [74 x i8]
@__csi_unit_function_name_trans = external dso_local unnamed_addr constant [6 x i8]
@"__csi_unit_function_name_scan<unsigned int, long, addF<unsigned int> >" = external dso_local unnamed_addr constant [46 x i8]
@"__csi_unit_function_name_radixLoopBottomUp<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned int>" = external dso_local unnamed_addr constant [95 x i8]
@"__csi_unit_function_name_scan<unsigned long, long, addF<unsigned long> >" = external dso_local unnamed_addr constant [48 x i8]
@"__csi_unit_function_name_radixLoopBottomUp<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>" = external dso_local unnamed_addr constant [96 x i8]
@"__csi_unit_function_name_iSortX<unsigned int, std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>" = external dso_local unnamed_addr constant [99 x i8]
@"__csi_unit_function_name_iSortX<unsigned long, std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>" = external dso_local unnamed_addr constant [100 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/istream" = external dso_local unnamed_addr constant [71 x i8]
@"__csi_unit_function_name_operator>>" = external dso_local unnamed_addr constant [11 x i8]
@"__csi_unit_function_name_scanIBack<unsigned int, long, minF<unsigned int> >" = external dso_local unnamed_addr constant [51 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/basic_string.h" = external dso_local unnamed_addr constant [83 x i8]
@"__csi_unit_function_name_operator==<char, std::char_traits<char>, std::allocator<char> >" = external dso_local unnamed_addr constant [64 x i8]
@"__csi_unit_function_name_edgeMap<symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [63 x i8]
@"__csi_unit_function_name_edgeMap<asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>" = external dso_local unnamed_addr constant [64 x i8]
@"__csi_unit_function_name_operator<<<char, std::char_traits<char>, std::allocator<char> >" = external dso_local unnamed_addr constant [64 x i8]
@"__csi_unit_function_name__M_construct<char *>" = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_function_name_getTime = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_function_name_reportTime = external dso_local unnamed_addr constant [11 x i8]
@"__csi_unit_function_name_readGraph<symmetricVertex>" = external dso_local unnamed_addr constant [27 x i8]
@"__csi_unit_function_name_readGraph<asymmetricVertex>" = external dso_local unnamed_addr constant [28 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/iostream" = external dso_local unnamed_addr constant [72 x i8]
@__csi_unit_function_name___cxx_global_var_init = external dso_local unnamed_addr constant [22 x i8]
@__csi_unit_function_name___cxx_global_var_init.2 = external dso_local unnamed_addr constant [24 x i8]
@__csi_unit_function_name___cxx_global_var_init.3 = external dso_local unnamed_addr constant [24 x i8]
@__csi_unit_fed_table__csi_unit_callsite_base_id = external dso_local global [594 x { i8*, i32, i32, i8* }]
@"__csi_unit_function_name_operator()" = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_function_name_rdstate = external dso_local unnamed_addr constant [8 x i8]
@"__csi_unit_function_name_~basic_istream" = external dso_local unnamed_addr constant [15 x i8]
@"__csi_unit_function_name_sumFlagsSerial<long>" = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_function_name_assign = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_function_name_copy = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_function_name_size = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_function_name__M_data = external dso_local unnamed_addr constant [8 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./index_map.h" = external dso_local unnamed_addr constant [47 x i8]
@__csi_unit_function_name_cut = external dso_local unnamed_addr constant [4 x i8]
@"__csi_unit_function_name_operator[]" = external dso_local unnamed_addr constant [11 x i8]
@"__csi_unit_function_name_scan_serial<array_imap<unsigned long>, array_imap<unsigned long>, (lambda at ./sequence.h:149:16)>" = external dso_local unnamed_addr constant [99 x i8]
@"__csi_unit_function_name_new_array_no_init<unsigned long>" = external dso_local unnamed_addr constant [33 x i8]
@"__csi_unit_function_name_reduce_serial<array_imap<unsigned long>, (lambda at ./sequence.h:149:16)>" = external dso_local unnamed_addr constant [74 x i8]
@__csi_unit_function_name_array_imap = external dso_local unnamed_addr constant [11 x i8]
@"__csi_unit_function_name_new_array_no_init<unsigned int>" = external dso_local unnamed_addr constant [32 x i8]
@__csi_unit_function_name_eatFirstEdge = external dso_local unnamed_addr constant [13 x i8]
@__csi_unit_function_name_cond = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_function_name_srcTarg = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_function_name_isIn = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_function_name_getOutNeighbors = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_function_name_getOutDegree = external dso_local unnamed_addr constant [13 x i8]
@__csi_unit_function_name_denseForwardT = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_function_name_update = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_function_name_getInNeighbors = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_function_name_getInDegree = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_function_name_denseT = external dso_local unnamed_addr constant [7 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/tuple" = external dso_local unnamed_addr constant [69 x i8]
@"__csi_unit_function_name__M_assign<unsigned int, pbbs::empty>" = external dso_local unnamed_addr constant [37 x i8]
@__csi_unit_function_name_vtx = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_function_name_sparseTSeq = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_function_name_sparseT = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_function_name_numNonzeros = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_function_name_numRows = external dso_local unnamed_addr constant [8 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/iomanip" = external dso_local unnamed_addr constant [71 x i8]
@"__csi_unit_function_name_operator<<<char, std::char_traits<char> >" = external dso_local unnamed_addr constant [42 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/stl_pair.h" = external dso_local unnamed_addr constant [79 x i8]
@"__csi_unit_function_name_operator=" = external dso_local unnamed_addr constant [10 x i8]
@"__csi_unit_function_name_radixBlock<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned int>" = external dso_local unnamed_addr constant [144 x i8]
@"__csi_unit_function_name_radixBlock<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned long>" = external dso_local unnamed_addr constant [145 x i8]
@__csi_unit_function_name_getOutNeighbor = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_function_name_getInNeighbor = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_function_name_updateAtomic = external dso_local unnamed_addr constant [13 x i8]
@__csi_unit_function_name_badArgument = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_function_name_next = external dso_local unnamed_addr constant [5 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/move.h" = external dso_local unnamed_addr constant [75 x i8]
@"__csi_unit_function_name_swap<unsigned char *>" = external dso_local unnamed_addr constant [22 x i8]
@"__csi_unit_function_name_swap<unsigned int>" = external dso_local unnamed_addr constant [19 x i8]
@"__csi_unit_function_name_swap<unsigned int *>" = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_function_name_getArgument = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_fed_table__csi_unit_load_base_id = external dso_local global [1171 x { i8*, i32, i32, i8* }]
@"__csi_unit_function_name_scanSerial<long, long, addF<long>, sequence::getA<long, long> >" = external dso_local unnamed_addr constant [64 x i8]
@__csi_unit_function_name_words = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_function_name_graph = external dso_local unnamed_addr constant [6 x i8]
@"__csi_unit_function_name_pack_serial_at<in_imap<unsigned int, (lambda at ./sequence.h:205:21)>, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >" = external dso_local unnamed_addr constant [124 x i8]
@"__csi_unit_function_name__M_assign<int, pbbs::empty>" = external dso_local unnamed_addr constant [28 x i8]
@"__csi_unit_function_name_CAS<unsigned int>" = external dso_local unnamed_addr constant [18 x i8]
@"__csi_unit_function_name_scanSerial<unsigned int, unsigned int, addF<unsigned int>, sequence::getA<unsigned int, unsigned int> >" = external dso_local unnamed_addr constant [104 x i8]
@"__csi_unit_function_name_scanSerial<unsigned int, unsigned long, addF<unsigned int>, sequence::getA<unsigned int, unsigned long> >" = external dso_local unnamed_addr constant [106 x i8]
@"__csi_unit_filename_/data/compilers/tests/ligra/apps/./edgeMap_utils.h" = external dso_local unnamed_addr constant [51 x i8]
@"__csi_unit_filename_/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/ios_base.h" = external dso_local unnamed_addr constant [79 x i8]
@__csi_unit_function_name_precision = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_function_name_setInDegree = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_function_name_setInNeighbors = external dso_local unnamed_addr constant [15 x i8]
@"__csi_unit_function_name_scanSerial<unsigned int, long, addF<unsigned int>, sequence::getA<unsigned int, long> >" = external dso_local unnamed_addr constant [88 x i8]
@"__csi_unit_function_name_scanSerial<unsigned long, long, addF<unsigned long>, sequence::getA<unsigned long, long> >" = external dso_local unnamed_addr constant [91 x i8]
@"__csi_unit_function_name_scanSerial<unsigned int, long, minF<unsigned int>, sequence::getA<unsigned int, long> >" = external dso_local unnamed_addr constant [88 x i8]
@"__csi_unit_function_name_operator=<unsigned int, int>" = external dso_local unnamed_addr constant [29 x i8]
@"__csi_unit_function_name_operator=<unsigned int, long>" = external dso_local unnamed_addr constant [30 x i8]
@__csi_unit_function_name_start = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_function_name_timer = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_fed_table__csi_unit_store_base_id = external dso_local global [693 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_detach_base_id = external dso_local global [153 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_task_base_id = external dso_local global [153 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_task_exit_base_id = external dso_local global [195 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_detach_continue_base_id = external dso_local global [195 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_sync_base_id = external dso_local global [149 x { i8*, i32, i32, i8* }]
@__csi_unit_fed_table__csi_unit_alloca_base_id = external dso_local global [183 x { i8*, i32, i32, i8* }]
@"__csi_unit_function_name_iSort<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>" = external dso_local unnamed_addr constant [84 x i8]
@__csi_unit_fed_table__csi_unit_allocfn_base_id = external dso_local global [135 x { i8*, i32, i32, i8* }]
@"__csi_unit_function_name_~array_imap" = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_fed_table__csi_unit_free_base_id = external dso_local global [161 x { i8*, i32, i32, i8* }]
@__csi_unit_object_name_savedEdges = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_g = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name___os = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_vtable.i = external dso_local unnamed_addr constant [9 x i8]
@__csi_unit_object_name_this = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_vtable.i240 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i252 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i263 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i274 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_Degrees = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_offsets = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_vtable.i239 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i264 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i288 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i312 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name__ZSt4cout = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_vtable.i49 = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_vtable.i62 = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_vtable.cast.i.i71 = external dso_local unnamed_addr constant [18 x i8]
@__csi_unit_object_name_vtable.cast.i.i.i76 = external dso_local unnamed_addr constant [20 x i8]
@__csi_unit_object_name_vtable.cast.i.i = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_object_name_vtable.cast.i.i.i = external dso_local unnamed_addr constant [18 x i8]
@__csi_unit_object_name_IFl = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_Fl = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_C = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name___beg = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_S = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_vtable.i251 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i275 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.cast.i.i281 = external dso_local unnamed_addr constant [19 x i8]
@__csi_unit_object_name_vtable.cast.i.i.i286 = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_object_name_vtable.i299 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i323 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i348 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_.pre76 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_.pre79 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_.pre77 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_stderr = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_b = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_agg.tmp.sroa.0.0.copyload4.i11.i40.i = external dso_local unnamed_addr constant [37 x i8]
@__csi_unit_object_name_agg.tmp.sroa.0.0.copyload4.i11.i.i = external dso_local unnamed_addr constant [35 x i8]
@__csi_unit_object_name_agg.tmp.sroa.0.0.copyload4.i24.i45.i = external dso_local unnamed_addr constant [37 x i8]
@__csi_unit_object_name_agg.tmp.sroa.0.0.copyload4.i24.i.i = external dso_local unnamed_addr constant [35 x i8]
@__csi_unit_object_name_r = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_vtable.i71 = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_degree = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_src = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_edgeStart = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_t = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_A = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_agg.tmp.sroa.0.0.copyload4.i10.i.i.pre = external dso_local unnamed_addr constant [39 x i8]
@__csi_unit_object_name_.pre = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_G = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name__f = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_.pre19.i257 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_.pre.i253 = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name__vs = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_In = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_flags = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_frontierVertices = external dso_local unnamed_addr constant [17 x i8]
@__csi_unit_object_name__k = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_GA = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_out = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_outEdges.0211 = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_object_name_Out = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_fl = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_vtable.i6 = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_vtable.i308 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i332 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.cast.i.i338 = external dso_local unnamed_addr constant [19 x i8]
@__csi_unit_object_name_vtable.cast.i.i.i343 = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_object_name_vtable.i356 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i380 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i405 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_inOffsets = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_inDegrees = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_outEdges.0215 = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_object_name_pa = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_BB = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_buckets = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_Tmp = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_B = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_BK = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_vtable.i616 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.i641 = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_vtable.cast.i.i685 = external dso_local unnamed_addr constant [19 x i8]
@__csi_unit_object_name_vtable.cast.i.i.i690 = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_object_name_vtable.cast.i.i652 = external dso_local unnamed_addr constant [19 x i8]
@__csi_unit_object_name_vtable.cast.i.i.i657 = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_object_name_vtable.cast.i.i628 = external dso_local unnamed_addr constant [19 x i8]
@__csi_unit_object_name_vtable.cast.i.i.i633 = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_object_name_W = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_vert = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_outEdges.0235 = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_object_name_vtable.cast.i.i683 = external dso_local unnamed_addr constant [19 x i8]
@__csi_unit_object_name_vtable.cast.i.i.i688 = external dso_local unnamed_addr constant [21 x i8]
@__csi_unit_object_name_outEdges.0237 = external dso_local unnamed_addr constant [14 x i8]
@__csi_unit_object_name___c2 = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name__tm = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name__v = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_obj_table = external dso_local global [1171 x { i8*, i32, i8* }]
@__csi_unit_object_name_saveStart = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_start = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_finalArr = external dso_local unnamed_addr constant [9 x i8]
@__csi_unit_object_name_call2 = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_call51 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name___c1 = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_bytes = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_.pre78 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_call.i = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_ref.tmp.i.i140 = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_object_name_ref.tmp2.i.i141 = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_object_name_ref.tmp.i.i = external dso_local unnamed_addr constant [12 x i8]
@__csi_unit_object_name_ref.tmp2.i.i = external dso_local unnamed_addr constant [13 x i8]
@__csi_unit_object_name_next = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_ref.tmp.i.i101 = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_object_name_ref.tmp2.i.i102 = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_object_name_arrayidx34.i._M_head_impl.i.i.i.i.i92.i = external dso_local unnamed_addr constant [40 x i8]
@__csi_unit_object_name_call6 = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_ref.tmp.i.i181 = external dso_local unnamed_addr constant [15 x i8]
@__csi_unit_object_name_ref.tmp2.i.i182 = external dso_local unnamed_addr constant [16 x i8]
@__csi_unit_object_name_call14 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_call16 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_call.i135 = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_call79 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_pb = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_call139 = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_call99 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_agg.result = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_call55 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_call218 = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_call184 = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_outEdges = external dso_local unnamed_addr constant [9 x i8]
@__csi_unit_obj_table.47 = external dso_local global [693 x { i8*, i32, i8* }]
@__csi_unit_object_name_sb = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_file = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name___dnew = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_in = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_fl.addr = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_Sums = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_ref.tmp20 = external dso_local unnamed_addr constant [10 x i8]
@__csi_unit_object_name_add = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_f_in = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_d_map = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_f = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_agg.tmp3.i = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_Frontier = external dso_local unnamed_addr constant [9 x i8]
@__csi_unit_object_name_output = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name___n = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_in2 = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_in3 = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_configFile = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_adjFile = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_idxFile = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name__cl = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_str = external dso_local unnamed_addr constant [4 x i8]
@__csi_unit_object_name_P = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_obj_table.48 = external dso_local global [183 x { i8*, i32, i8* }]
@__csi_unit_object_name_iEdges = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_s = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name__V = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name__D = external dso_local unnamed_addr constant [3 x i8]
@__csi_unit_object_name_call158 = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_indices = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_call63 = external dso_local unnamed_addr constant [7 x i8]
@__csi_unit_object_name_tmpSpace = external dso_local unnamed_addr constant [9 x i8]
@__csi_unit_object_name_edges = external dso_local unnamed_addr constant [6 x i8]
@__csi_unit_object_name_v = external dso_local unnamed_addr constant [2 x i8]
@__csi_unit_object_name_temp = external dso_local unnamed_addr constant [5 x i8]
@__csi_unit_object_name_inEdges = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_call356 = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_call373 = external dso_local unnamed_addr constant [8 x i8]
@__csi_unit_object_name_call390706 = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_call218670 = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_call218668 = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_object_name_call390704 = external dso_local unnamed_addr constant [11 x i8]
@__csi_unit_obj_table.49 = external dso_local global [135 x { i8*, i32, i8* }]
@__csi_func_id__Z17compressFirstEdgePhljj = external global i64
@__csi_func_id__Z29parallelCompressWeightedEdgesPSt4pairIjiEPjllS2_ = external global i64
@__csi_func_id__ZN4pbbs6hash64Em = external global i64
@__csi_func_id__Z14numBytesSignedi = external global i64
@__csi_func_id__GLOBAL__sub_I_BFS.C = external global i64
@__csi_func_id_main = external global i64
@__csi_func_id__Z21parallelCompressEdgesPjS_llS_ = external global i64
@__csi_func_id__ZN14Compressed_MemI25compressedSymmetricVertexE3delEv = external global i64
@__csi_func_id__ZN14Compressed_MemI26compressedAsymmetricVertexE3delEv = external global i64
@__csi_func_id__ZN16Uncompressed_MemI16asymmetricVertexE3delEv = external global i64
@__csi_func_id__ZN16Uncompressed_MemI15symmetricVertexE3delEv = external global i64
@__csi_func_id__ZN4pbbs6hash32Ej = external global i64
@__csi_func_id__Z13compressEdgesPhlPjjij = external global i64
@__csi_func_id__Z21compressWeightedEdgesPhlPSt4pairIjiEjiij = external global i64
@__csi_unit_fed_tables = external dso_local global [16 x { i64, i8*, { i8*, i32, i32, i8* }* }]
@__csi_unit_obj_tables = external dso_local global [4 x { i64, { i8*, i32, i8* }* }]
@0 = external dso_local unnamed_addr constant [6 x i8], align 1
@llvm.global_ctors = external global [2 x { i32, void ()*, i8* }]

declare dso_local void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"*) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init"*) unnamed_addr #1

; Function Attrs: nofree nounwind
declare dso_local i32 @__cxa_atexit(void (i8*)*, i8*, i8*) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local i32 @mallopt(i32, i32) local_unnamed_addr #1

; Function Attrs: norecurse nounwind readnone sanitize_cilk uwtable
declare dso_local i32 @_ZN4pbbs6hash32Ej(i32) local_unnamed_addr #3

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #4

; Function Attrs: norecurse nounwind readnone sanitize_cilk uwtable
declare dso_local i64 @_ZN4pbbs6hash64Em(i64) local_unnamed_addr #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #5

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #5

; Function Attrs: nofree norecurse nounwind uwtable writeonly
declare dso_local i64 @_Z17compressFirstEdgePhljj(i8* nocapture, i64, i32, i32) local_unnamed_addr #6

; Function Attrs: nofree norecurse nounwind uwtable
declare dso_local i64 @_Z13compressEdgesPhlPjjij(i8* nocapture, i64, i32* nocapture readonly, i32, i32, i32) local_unnamed_addr #7

; Function Attrs: nofree norecurse nounwind uwtable
declare dso_local i64 @_Z25sequentialCompressEdgeSetPhljjPj(i8* nocapture, i64, i32, i32, i32* nocapture readonly) local_unnamed_addr #7

; Function Attrs: uwtable
declare dso_local noalias i32* @_Z21parallelCompressEdgesPjS_llS_(i32* nocapture readonly, i32* nocapture, i64, i64, i32* nocapture readonly) local_unnamed_addr #8

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* dereferenceable(272), i8*) local_unnamed_addr #9

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_(%"class.std::basic_ostream"* dereferenceable(272)) local_unnamed_addr #9

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @malloc(i64) local_unnamed_addr #10

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #5

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #11

; Function Attrs: nounwind
declare dso_local void @free(i8* nocapture) local_unnamed_addr #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #5

; Function Attrs: norecurse nounwind readnone sanitize_cilk uwtable
declare dso_local i32 @_Z14numBytesSignedi(i32) local_unnamed_addr #3

; Function Attrs: nofree norecurse nounwind uwtable
declare dso_local i64 @_Z21compressWeightedEdgesPhlPSt4pairIjiEjiij(i8* nocapture, i64, %"struct.std::pair"* nocapture readonly, i32, i32, i32, i32) local_unnamed_addr #7

; Function Attrs: nofree norecurse nounwind uwtable
declare dso_local i64 @_Z33sequentialCompressWeightedEdgeSetPhljjPSt4pairIjiE(i8*, i64, i32, i32, %"struct.std::pair"* readonly) local_unnamed_addr #7

; Function Attrs: uwtable
declare dso_local noalias i8* @_Z29parallelCompressWeightedEdgesPSt4pairIjiEPjllS2_(%"struct.std::pair"*, i32* nocapture, i64, i64, i32* nocapture readonly) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local { i8*, i64 } @_Z18mmapStringFromFilePKc(i8* nocapture readonly) local_unnamed_addr #8

; Function Attrs: nofree
declare dso_local i32 @open(i8* nocapture readonly, i32, ...) local_unnamed_addr #12

; Function Attrs: nofree nounwind
declare dso_local void @perror(i8* nocapture readonly) local_unnamed_addr #10

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) local_unnamed_addr #13

; Function Attrs: nounwind
declare dso_local i8* @mmap(i8*, i64, i32, i32, i32, i64) local_unnamed_addr #1

declare dso_local i32 @close(i32) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local { i8*, i64 } @_Z18readStringFromFilePc(i8*) local_unnamed_addr #8

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZNSt14basic_ifstreamIcSt11char_traitsIcEEC1EPKcSt13_Ios_Openmode(%"class.std::basic_ifstream"*, i8*, i32) unnamed_addr #14 align 2

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: noreturn nounwind
declare dso_local void @abort() local_unnamed_addr #13

declare dso_local { i64, i64 } @_ZNSi5tellgEv(%"class.std::basic_istream"*) local_unnamed_addr #0

declare dso_local dereferenceable(280) %"class.std::basic_istream"* @_ZNSi5seekgElSt12_Ios_Seekdir(%"class.std::basic_istream"*, i64, i32) local_unnamed_addr #0

declare dso_local dereferenceable(280) %"class.std::basic_istream"* @_ZNSi4readEPcl(%"class.std::basic_istream"*, i8*, i64) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_Z13stringToWordsPcl(%struct.words* noalias nocapture sret, i8*, i64) local_unnamed_addr #8

; Function Attrs: norecurse uwtable
declare dso_local i32 @main(i32, i8**) local_unnamed_addr #15

; Function Attrs: uwtable
declare dso_local i8* @_ZN11commandLine14getOptionValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%struct.commandLine*, %"class.std::__cxx11::basic_string"*) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i64 @_ZN11commandLine18getOptionLongValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEl(%struct.commandLine*, %"class.std::__cxx11::basic_string"*, i64) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_Z19readCompressedGraphI25compressedSymmetricVertexE5graphIT_EPcbb(%struct.graph* noalias sret, i8*, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z7ComputeI25compressedSymmetricVertexEvR5graphIT_E11commandLine(%struct.graph* dereferenceable(48), %struct.commandLine*) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z19readCompressedGraphI26compressedAsymmetricVertexE5graphIT_EPcbb(%struct.graph.2* noalias sret, i8*, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z7ComputeI26compressedAsymmetricVertexEvR5graphIT_E11commandLine(%struct.graph.2* dereferenceable(48), %struct.commandLine*) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z7ComputeI15symmetricVertexEvR5graphIT_E11commandLine(%struct.graph.3* dereferenceable(48), %struct.commandLine*) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z7ComputeI16asymmetricVertexEvR5graphIT_E11commandLine(%struct.graph.4* dereferenceable(48), %struct.commandLine*) local_unnamed_addr #8

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #5

; Function Attrs: nounwind
declare dso_local i32 @__fxstat(i32, i32, %struct.stat*) local_unnamed_addr #1

; Function Attrs: noreturn
declare dso_local void @_ZSt19__throw_logic_errorPKc(i8*) local_unnamed_addr #16

declare dso_local i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"*, i64* dereferenceable(8), i64) local_unnamed_addr #0

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #17

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* dereferenceable(272), i8*, i64) local_unnamed_addr #0

; Function Attrs: nofree nounwind
declare dso_local i64 @strtol(i8* readonly, i8** nocapture, i32) local_unnamed_addr #10

; Function Attrs: nofree nounwind
declare dso_local i32 @gettimeofday(%struct.timeval* nocapture, i8* nocapture) local_unnamed_addr #10

; Function Attrs: uwtable
declare dso_local void @_ZN5timer7reportTEd(%struct.timer*, double) local_unnamed_addr #8 align 2

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"*, double) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"*, i8 signext) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"*) local_unnamed_addr #0

; Function Attrs: noreturn
declare dso_local void @_ZSt16__throw_bad_castv() local_unnamed_addr #16

declare dso_local void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"*) local_unnamed_addr #0

declare dso_local void @_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate(%"class.std::basic_ios"*, i32) local_unnamed_addr #0

; Function Attrs: argmemonly nofree nounwind readonly
declare dso_local i64 @strlen(i8* nocapture) local_unnamed_addr #18

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIlEERSoT_(%"class.std::basic_ostream"*, i64) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local i64 @_ZN8sequence4scanIll4addFIlENS_4getAIllEEEET_PS5_T0_S7_T1_T2_S5_bb(i64*, i64, i64, i64*, i64, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZNSt13basic_filebufIcSt11char_traitsIcEED2Ev(%"class.std::basic_filebuf"*) unnamed_addr #19 align 2

declare dso_local %"class.std::basic_filebuf"* @_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv(%"class.std::basic_filebuf"*) local_unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_baseD2Ev(%"class.std::ios_base"*) unnamed_addr #1

; Function Attrs: nounwind readonly
declare dso_local zeroext i1 @_ZNKSt12__basic_fileIcE7is_openEv(%"class.std::__basic_file"*) local_unnamed_addr #20

; Function Attrs: uwtable
declare dso_local { i64*, i64 } @_ZN8sequence4packIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_(i64*, i8*, i64, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local { i64*, i64 } @_ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_(i64*, i8*, i64, i64) local_unnamed_addr #8

; Function Attrs: nounwind
declare dso_local i32 @munmap(i8*, i64) local_unnamed_addr #1

declare dso_local dereferenceable(280) %"class.std::basic_istream"* @_ZNSi5seekgESt4fposI11__mbstate_tE(%"class.std::basic_istream"*, i64, i64) local_unnamed_addr #0

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #21

; Function Attrs: nounwind uwtable
declare dso_local void @_ZN14Compressed_MemI25compressedSymmetricVertexE3delEv(%struct.Compressed_Mem*) unnamed_addr #22 align 2

; Function Attrs: uwtable
declare dso_local void @_Z11edgeMapDataIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj(%struct.vertexSubsetData* noalias sret, %struct.graph* dereferenceable(48), %struct.vertexSubsetData* dereferenceable(40), i32*, i32, i32* dereferenceable(4)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEv(%struct.vertexSubsetData*) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_Z19edgeMapDenseForwardIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph* byval(%struct.graph) align 8, %struct.vertexSubsetData* dereferenceable(40), %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z12edgeMapDenseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph* byval(%struct.graph) align 8, %struct.vertexSubsetData* dereferenceable(40), %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph* dereferenceable(48), %struct.compressedSymmetricVertex*, %struct.vertexSubsetData* dereferenceable(40), i32*, i32, %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z13edgeMapSparseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph* dereferenceable(48), %struct.compressedSymmetricVertex*, %struct.vertexSubsetData* dereferenceable(40), i32*, i32, %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN4pbbs4packI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_j(%struct.array_imap* noalias sret, %struct.in_imap.6* byval(%struct.in_imap.6) align 8, %struct.in_imap* byval(%struct.in_imap) align 8, i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs8scan_addI10array_imapImES2_EENT_1TES3_T0_j(%struct.array_imap.7*, %struct.array_imap.7*, i32) local_unnamed_addr #8

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @aligned_alloc(i64, i64) local_unnamed_addr #10

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #5

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs4scanI10array_imapImES2_ZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_S6_RKT1_S5_j(%struct.array_imap.7*, %struct.array_imap.7*, %class.anon.11* dereferenceable(1), i64, i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN4pbbs10sliced_forIZNS_4scanI10array_imapImES3_ZNS_8scan_addIS3_S3_EENT_1TES5_T0_jEUlmmE_EES6_S5_S7_RKT1_S6_jEUlmmmE0_EEvmmRKS5_(i64, i64, %class.anon.14* dereferenceable(40)) local_unnamed_addr #8

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream"*, i64) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local i32 @_ZN8sequence6reduceIjl4addFIjENS_4getAIjlEEEET_T0_S6_T1_T2_(i64, i64, i32*) local_unnamed_addr #8

; Function Attrs: inlinehint uwtable
declare dso_local void @_Z6decodeIN17decode_compressed13denseForwardTI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEEvS7_PhRKjSE_b(i32*, %"class.std::tuple"*, i8*, i32* dereferenceable(4), i32* dereferenceable(4), i1 zeroext) local_unnamed_addr #23

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS3_EEEUlmE_EZNS4_C1ElS7_EUlmmE_EENT_1TESB_RKT0_j(%struct.in_imap.25* byval(%struct.in_imap.25) align 8, %class.anon.27* dereferenceable(1), i32) local_unnamed_addr #8

; Function Attrs: inlinehint uwtable
declare dso_local void @_Z6decodeIN17decode_compressed13denseForwardTI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEEvT_PhRKjSB_b(i32*, i8*, i32* dereferenceable(4), i32* dereferenceable(4), i1 zeroext) local_unnamed_addr #23

; Function Attrs: inlinehint uwtable
declare dso_local void @_Z6decodeIN17decode_compressed6denseTI5BFS_FZ15get_emdense_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_16vertexSubsetDataIS5_EEEEvS7_PhRKjSG_b(%"struct.decode_compressed::denseT"* byval(%"struct.decode_compressed::denseT") align 8, i8*, i32* dereferenceable(4), i32* dereferenceable(4), i1 zeroext) local_unnamed_addr #23

; Function Attrs: inlinehint uwtable
declare dso_local void @_Z6decodeIN17decode_compressed6denseTI5BFS_FZ24get_emdense_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_16vertexSubsetDataIS5_EEEEvT_PhRKjSD_b(%"struct.decode_compressed::denseT.34"* byval(%"struct.decode_compressed::denseT.34") align 8, i8*, i32* dereferenceable(4), i32* dereferenceable(4), i1 zeroext) local_unnamed_addr #23

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_(%"class.std::tuple.35"*, %"class.std::tuple.35"*, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i32 @_ZN8sequence4scanIjj4addFIjENS_4getAIjjEEEET_PS5_T0_S7_T1_T2_S5_bb(i32*, i32, i32, i32*, i32, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: inlinehint uwtable
declare dso_local void @_Z6decodeIN17decode_compressed10sparseTSeqI5BFS_FZ26get_emsparse_no_filter_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_EEEvS7_PhRKjSE_b(%"struct.decode_compressed::sparseTSeq"* byval(%"struct.decode_compressed::sparseTSeq") align 8, i8*, i32* dereferenceable(4), i32* dereferenceable(4), i1 zeroext) local_unnamed_addr #23

; Function Attrs: uwtable
declare dso_local i32 @_ZN8sequence4scanIjm4addFIjENS_4getAIjmEEEET_PS5_T0_S7_T1_T2_S5_bb(i32*, i64, i64, i32*, i32, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_(%"class.std::tuple.35"*, %"class.std::tuple.35"*, i64) local_unnamed_addr #8

; Function Attrs: inlinehint uwtable
declare dso_local void @_Z6decodeIN17decode_compressed7sparseTI5BFS_FZ16get_emsparse_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_EEEvS7_PhRKjSE_b(%"struct.decode_compressed::sparseT"* byval(%"struct.decode_compressed::sparseT") align 8, i8*, i32* dereferenceable(4), i32* dereferenceable(4), i1 zeroext) local_unnamed_addr #23

; Function Attrs: inlinehint uwtable
declare dso_local void @_Z6decodeIN17decode_compressed7sparseTI5BFS_FZ25get_emsparse_nooutput_genIN4pbbs5emptyELi0EEDavEUljjbE_EEEvT_PhRKjSB_b(%"struct.decode_compressed::sparseT.54"* byval(%"struct.decode_compressed::sparseT.54") align 8, i8*, i32* dereferenceable(4), i32* dereferenceable(4), i1 zeroext) local_unnamed_addr #23

; Function Attrs: nounwind uwtable
declare dso_local void @_ZN14Compressed_MemI26compressedAsymmetricVertexE3delEv(%struct.Compressed_Mem.55*) unnamed_addr #22 align 2

; Function Attrs: uwtable
declare dso_local void @_Z11edgeMapDataIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj(%struct.vertexSubsetData* noalias sret, %struct.graph.2* dereferenceable(48), %struct.vertexSubsetData* dereferenceable(40), i32*, i32, i32* dereferenceable(4)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z19edgeMapDenseForwardIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.2* byval(%struct.graph.2) align 8, %struct.vertexSubsetData* dereferenceable(40), %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z12edgeMapDenseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.2* byval(%struct.graph.2) align 8, %struct.vertexSubsetData* dereferenceable(40), %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.2* dereferenceable(48), %struct.compressedAsymmetricVertex*, %struct.vertexSubsetData* dereferenceable(40), i32*, i32, %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z13edgeMapSparseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.2* dereferenceable(48), %struct.compressedAsymmetricVertex*, %struct.vertexSubsetData* dereferenceable(40), i32*, i32, %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_(%"class.std::tuple.35"*, %"class.std::tuple.35"*, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_(%"class.std::tuple.35"*, %"class.std::tuple.35"*, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z19readGraphFromBinaryI15symmetricVertexE5graphIT_EPcb(%struct.graph.3* noalias sret, i8*, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z17readGraphFromFileI15symmetricVertexE5graphIT_EPcbb(%struct.graph.3* noalias sret, i8*, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: nofree nounwind
declare dso_local i8* @strcat(i8* returned, i8* nocapture readonly) local_unnamed_addr #10

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #11

; Function Attrs: uwtable
declare dso_local void @_ZN7intSort5iSortISt4pairIjjE8getFirstIjEEEvPT_llT0_(%"struct.std::pair.66"*, i64, i64) local_unnamed_addr #8

declare dso_local dereferenceable(280) %"class.std::basic_istream"* @_ZNSi10_M_extractIlEERSiRT_(%"class.std::basic_istream"*, i64* dereferenceable(8)) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN7intSort9radixStepISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEjEEvPT_S8_PhPA256_T1_lllbT0_(%"struct.std::pair.66"*, %"struct.std::pair.66"*, i8*, [256 x i32]*, i64, i64, i64, i1 zeroext, %"struct.intSort::eBits"* byval(%"struct.intSort::eBits") align 8) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN7intSort16radixLoopTopDownISt4pairIjjE8getFirstIjEjEEvPT_S6_PhPA256_T1_lllT0_(%"struct.std::pair.66"*, %"struct.std::pair.66"*, i8*, [256 x i32]*, i64, i64, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN9transposeIjjE6transREjjjjjj(%struct.transpose*, i32, i32, i32, i32, i32, i32) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i32 @_ZN8sequence4scanIjl4addFIjENS_4getAIjlEEEET_PS5_T0_S7_T1_T2_S5_bb(i32*, i64, i64, i32*, i32, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN10blockTransISt4pairIjjEjE6transREjjjjjj(%struct.blockTrans*, i32, i32, i32, i32, i32, i32) local_unnamed_addr #8 align 2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.floor.f32(float) #4

; Function Attrs: uwtable
declare dso_local void @_ZN7intSort9radixStepISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEmEEvPT_S8_PhPA256_T1_lllbT0_(%"struct.std::pair.66"*, %"struct.std::pair.66"*, i8*, [256 x i64]*, i64, i64, i64, i1 zeroext, %"struct.intSort::eBits"* byval(%"struct.intSort::eBits") align 8) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN7intSort16radixLoopTopDownISt4pairIjjE8getFirstIjEmEEvPT_S6_PhPA256_T1_lllT0_(%"struct.std::pair.66"*, %"struct.std::pair.66"*, i8*, [256 x i64]*, i64, i64, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN9transposeImmE6transREmmmmmm(%struct.transpose.71*, i64, i64, i64, i64, i64, i64) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i64 @_ZN8sequence4scanIml4addFImENS_4getAImlEEEET_PS5_T0_S7_T1_T2_S5_bb(i64*, i64, i64, i64*, i64, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN10blockTransISt4pairIjjEmE6transREmmmmmm(%struct.blockTrans.73*, i64, i64, i64, i64, i64, i64) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i32 @_ZN8sequence4scanIjl4minFIjENS_4getAIjlEEEET_PS5_T0_S7_T1_T2_S5_bb(i32*, i64, i64, i32*, i32, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN16Uncompressed_MemI15symmetricVertexE3delEv(%struct.Uncompressed_Mem*) unnamed_addr #8 align 2

; Function Attrs: nounwind
declare dso_local i32 @_ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE7compareEPKc(%"class.std::__cxx11::basic_string"*, i8*) local_unnamed_addr #1

; Function Attrs: uwtable
declare dso_local void @_Z11edgeMapDataIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj(%struct.vertexSubsetData* noalias sret, %struct.graph.3* dereferenceable(48), %struct.vertexSubsetData* dereferenceable(40), i32*, i32, i32* dereferenceable(4)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z19edgeMapDenseForwardIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.3* byval(%struct.graph.3) align 8, %struct.vertexSubsetData* dereferenceable(40), %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z12edgeMapDenseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.3* byval(%struct.graph.3) align 8, %struct.vertexSubsetData* dereferenceable(40), %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.3* dereferenceable(48), %struct.symmetricVertex*, %struct.vertexSubsetData* dereferenceable(40), i32*, i32, %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z13edgeMapSparseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.3* dereferenceable(48), %struct.symmetricVertex*, %struct.vertexSubsetData* dereferenceable(40), i32*, i32, %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_(%"class.std::tuple.35"*, %"class.std::tuple.35"*, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_(%"class.std::tuple.35"*, %"class.std::tuple.35"*, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z19readGraphFromBinaryI16asymmetricVertexE5graphIT_EPcb(%struct.graph.4* noalias sret, i8*, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z17readGraphFromFileI16asymmetricVertexE5graphIT_EPcbb(%struct.graph.4* noalias sret, i8*, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN16Uncompressed_MemI16asymmetricVertexE3delEv(%struct.Uncompressed_Mem.87*) unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_Z11edgeMapDataIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj(%struct.vertexSubsetData* noalias sret, %struct.graph.4* dereferenceable(48), %struct.vertexSubsetData* dereferenceable(40), i32*, i32, i32* dereferenceable(4)) local_unnamed_addr #8

; Function Attrs: uwtable
define linkonce_odr dso_local void @_Z19edgeMapDenseForwardIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j(%struct.vertexSubsetData* noalias sret %agg.result, %struct.graph.4* byval(%struct.graph.4) align 8 %GA, %struct.vertexSubsetData* dereferenceable(40) %vertexSubset, %struct.BFS_F* dereferenceable(8) %f, i32 %fl) local_unnamed_addr #8 comdat personality i32 (...)* @__gxx_personality_v0 !dbg !2998 {
entry:
  %0 = load i64, i64* @__csi_unit_detach_base_id, align 8, !invariant.load !45
  %1 = add i64 %0, 126
  %2 = load i64, i64* @__csi_unit_task_base_id, align 8, !invariant.load !45
  %3 = add i64 %2, 126
  %4 = load i64, i64* @__csi_unit_task_exit_base_id, align 8, !invariant.load !45
  %5 = add i64 %4, 163
  %6 = add i64 %4, 164
  %7 = load i64, i64* @__csi_unit_detach_continue_base_id, align 8, !invariant.load !45
  %8 = add i64 %7, 163
  %9 = add i64 %7, 164
  %10 = add i64 %0, 124
  %11 = add i64 %2, 124
  %12 = add i64 %4, 160
  %13 = add i64 %4, 161
  %14 = add i64 %7, 160
  %15 = add i64 %7, 161
  %16 = load i64, i64* @__csi_unit_func_base_id, align 8, !invariant.load !45
  %17 = add i64 %16, 77
  %18 = call i8* @llvm.frameaddress.p0i8(i32 0)
  %19 = call i8* @llvm.stacksave()
  call void @__csan_func_entry(i64 %17, i8* %18, i8* %19, i64 257), !dbg !4816
  %20 = load i64, i64* @__csi_unit_alloca_base_id, align 8, !invariant.load !45
  %21 = add i64 %20, 136
  %_d.addr.i = alloca %"class.std::tuple"*, align 8
  %22 = bitcast %"class.std::tuple"** %_d.addr.i to i8*
  call void @__csi_after_alloca(i64 %21, i8* nonnull %22, i64 8, i64 1), !dbg !4816
  %23 = add i64 %20, 137
  %f.i = alloca %class.anon.27, align 1
  %24 = getelementptr inbounds %class.anon.27, %class.anon.27* %f.i, i64 0, i32 0, !dbg !4817
  call void @__csi_after_alloca(i64 %23, i8* nonnull %24, i64 1, i64 1), !dbg !4817
  call void @llvm.dbg.declare(metadata %class.anon.27* %f.i, metadata !4822, metadata !DIExpression()), !dbg !4817
  %25 = add i64 %20, 138
  %agg.tmp3.i = alloca %struct.in_imap.25, align 8
  %26 = bitcast %struct.in_imap.25* %agg.tmp3.i to i8*
  call void @__csi_after_alloca(i64 %25, i8* nonnull %26, i64 24, i64 1), !dbg !4816
  %syncreg47 = tail call token @llvm.syncregion.start()
  call void @llvm.dbg.declare(metadata %struct.graph.4* %GA, metadata !3002, metadata !DIExpression()), !dbg !4823
  call void @llvm.dbg.value(metadata %struct.vertexSubsetData* %vertexSubset, metadata !3003, metadata !DIExpression()), !dbg !4816
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !3004, metadata !DIExpression()), !dbg !4816
  call void @llvm.dbg.value(metadata i32 %fl, metadata !3005, metadata !DIExpression()), !dbg !4816
  %n1 = getelementptr inbounds %struct.graph.4, %struct.graph.4* %GA, i64 0, i32 1, !dbg !4824
  %27 = load i64, i64* %n1, align 8, !dbg !4824, !tbaa !4825
  call void @llvm.dbg.value(metadata i64 %27, metadata !3006, metadata !DIExpression()), !dbg !4816
  %V = getelementptr inbounds %struct.graph.4, %struct.graph.4* %GA, i64 0, i32 0, !dbg !4832
  %28 = load %struct.asymmetricVertex*, %struct.asymmetricVertex** %V, align 8, !dbg !4832, !tbaa !4833
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* %28, metadata !3007, metadata !DIExpression()), !dbg !4816
  %and.i = and i32 %fl, 1, !dbg !4834
  %tobool.i = icmp eq i32 %and.i, 0, !dbg !4842
  br i1 %tobool.i, label %if.then, label %if.else, !dbg !4843

if.then:                                          ; preds = %entry
  %29 = load i64, i64* @__csi_unit_allocfn_base_id, align 8, !dbg !4844, !invariant.load !45
  %30 = add i64 %29, 118, !dbg !4844
  %call2 = tail call noalias i8* @malloc(i64 %27) #28, !dbg !4844
  call void @__csan_after_allocfn(i64 %30, i8* %call2, i64 %27, i64 1, i64 0, i8* null, i64 0), !dbg !4844
  %31 = bitcast i8* %call2 to %"class.std::tuple"*, !dbg !4844
  call void @llvm.dbg.value(metadata %"class.std::tuple"* %31, metadata !4845, metadata !DIExpression()), !dbg !4846
  call void @llvm.dbg.value(metadata %"class.std::tuple"* %31, metadata !4847, metadata !DIExpression()), !dbg !4846
  call void @llvm.dbg.value(metadata i64 0, metadata !4848, metadata !DIExpression()), !dbg !4850
  call void @llvm.dbg.value(metadata i64 %27, metadata !4851, metadata !DIExpression()), !dbg !4850
  %cmp = icmp sgt i64 %27, 0, !dbg !4852
  br i1 %cmp, label %pfor.cond, label %cleanup41, !dbg !4853

pfor.cond:                                        ; preds = %pfor.inc, %if.then
  %__begin.0 = phi i64 [ %inc, %pfor.inc ], [ 0, %if.then ], !dbg !4850
  call void @llvm.dbg.value(metadata i64 %__begin.0, metadata !4854, metadata !DIExpression()), !dbg !4850
  detach within %syncreg47, label %pfor.body, label %pfor.inc, !dbg !4855

pfor.body:                                        ; preds = %pfor.cond
  call void @llvm.dbg.value(metadata i64 %__begin.0, metadata !4856, metadata !DIExpression()), !dbg !4858
  %arrayidx134 = getelementptr inbounds i8, i8* %call2, i64 %__begin.0, !dbg !4859
  call void @llvm.dbg.value(metadata i8* %arrayidx134, metadata !4861, metadata !DIExpression()), !dbg !4864
  call void @llvm.dbg.value(metadata i8* %arrayidx134, metadata !4888, metadata !DIExpression()), !dbg !4891
  store i8 0, i8* %arrayidx134, align 1, !dbg !4893, !tbaa !4894
  reattach within %syncreg47, label %pfor.inc, !dbg !4895

pfor.inc:                                         ; preds = %pfor.body, %pfor.cond
  %inc = add nuw nsw i64 %__begin.0, 1, !dbg !4896
  call void @llvm.dbg.value(metadata i64 %inc, metadata !4854, metadata !DIExpression()), !dbg !4850
  %exitcond174 = icmp eq i64 %inc, %27, !dbg !4897
  br i1 %exitcond174, label %pfor.cond.cleanup, label %pfor.cond, !dbg !4898, !llvm.loop !4899

pfor.cond.cleanup:                                ; preds = %pfor.inc
  sync within %syncreg47, label %pfor.cond22.preheader, !dbg !4898

pfor.cond22.preheader:                            ; preds = %pfor.cond.cleanup
  invoke void @llvm.sync.unwind(token %syncreg47)
          to label %.noexc186 unwind label %csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split-lp, !dbg !4898

.noexc186:                                        ; preds = %pfor.cond22.preheader
  call void @llvm.dbg.value(metadata i64 0, metadata !4902, metadata !DIExpression()), !dbg !4904
  call void @llvm.dbg.value(metadata i64 %27, metadata !4905, metadata !DIExpression()), !dbg !4904
  %d.i166 = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %vertexSubset, i64 0, i32 1, !dbg !4906
  %Parents.i59.i.i = getelementptr inbounds %struct.BFS_F, %struct.BFS_F* %f, i64 0, i32 0, !dbg !4916
  %32 = load i64, i64* @__csi_unit_loop_base_id, align 8, !dbg !4987, !invariant.load !45
  %33 = add i64 %32, 111, !dbg !4987
  call void @__csan_before_loop(i64 %33, i64 -1, i64 1), !dbg !4987
  %34 = add i64 %0, 125, !dbg !4988
  %35 = add i64 %2, 125, !dbg !4988
  %36 = add i64 %4, 162, !dbg !4988
  %37 = add i64 %7, 162, !dbg !4988
  %38 = load i64, i64* @__csi_unit_load_base_id, align 8, !dbg !4906
  %39 = add i64 %38, 994, !dbg !4906
  %40 = bitcast i8** %d.i166 to i8*, !dbg !4906
  %41 = add i64 %38, 978, !dbg !4906
  %42 = add i64 %38, 979, !dbg !4989
  %43 = add i64 %38, 983, !dbg !4995
  %44 = add i64 %38, 984, !dbg !4995
  %45 = add i64 %38, 996, !dbg !4916
  %46 = bitcast %struct.BFS_F* %f to i8*, !dbg !4916
  %47 = add i64 %38, 985, !dbg !4916
  %48 = add i64 %32, 112, !dbg !5001
  %49 = add i64 %38, 980, !dbg !5005
  %50 = add i64 %38, 981, !dbg !5005
  %51 = add i64 %38, 995, !dbg !5010
  %52 = add i64 %38, 982, !dbg !5010
  %53 = load i64, i64* @__csi_unit_sync_base_id, align 8, !dbg !5013
  %54 = add i64 %53, 120, !dbg !5013
  br label %pfor.cond22, !dbg !4987

pfor.cond22:                                      ; preds = %pfor.inc33, %.noexc186
  %__begin16.0 = phi i64 [ %inc34, %pfor.inc33 ], [ 0, %.noexc186 ], !dbg !4904
  call void @llvm.dbg.value(metadata i64 %__begin16.0, metadata !5014, metadata !DIExpression()), !dbg !4904
  call void @__csan_detach(i64 %10, i8 0), !dbg !4987
  detach within %syncreg47, label %pfor.body28, label %pfor.inc33 unwind label %csi.cleanup.loopexit, !dbg !4987

pfor.body28:                                      ; preds = %pfor.cond22
  %55 = call i8* @llvm.task.frameaddress(i32 0), !dbg !4988
  %56 = call i8* @llvm.stacksave(), !dbg !4988
  call void @__csan_task(i64 %11, i64 %10, i8* %55, i8* %56, i64 3), !dbg !4988
  call void @llvm.dbg.value(metadata i64 %__begin16.0, metadata !5015, metadata !DIExpression()), !dbg !4988
  %conv = trunc i64 %__begin16.0 to i32, !dbg !5016
  call void @llvm.dbg.value(metadata %struct.vertexSubsetData* %vertexSubset, metadata !4909, metadata !DIExpression()), !dbg !4906
  call void @__csan_load(i64 %39, i8* nonnull %40, i32 8, i64 8), !dbg !5017
  %57 = load i8*, i8** %d.i166, align 8, !dbg !5017, !tbaa !5018
  %idxprom.i167 = and i64 %__begin16.0, 4294967295, !dbg !5017
  %arrayidx.i168 = getelementptr inbounds i8, i8* %57, i64 %idxprom.i167, !dbg !5017
  call void @__csan_load(i64 %41, i8* %arrayidx.i168, i32 1, i64 1), !dbg !5017
  %58 = load i8, i8* %arrayidx.i168, align 1, !dbg !5017, !tbaa !4894, !range !5020
  %tobool.i169 = icmp eq i8 %58, 0, !dbg !5017
  br i1 %tobool.i169, label %pfor.preattach32, label %if.then30.tf.split, !dbg !5021

if.then30.tf.split:                               ; preds = %pfor.body28
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !4981, metadata !DIExpression()), !dbg !5022
  call void @llvm.dbg.value(metadata i64 %__begin16.0, metadata !4982, metadata !DIExpression()), !dbg !5022
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !4983, metadata !DIExpression()), !dbg !5022
  call void @llvm.dbg.value(metadata %class.anon.19* undef, metadata !4984, metadata !DIExpression()), !dbg !5022
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !4938, metadata !DIExpression()), !dbg !5023
  call void @llvm.dbg.value(metadata i64 %__begin16.0, metadata !4939, metadata !DIExpression()), !dbg !5023
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !4940, metadata !DIExpression()), !dbg !5023
  call void @llvm.dbg.value(metadata %class.anon.19* undef, metadata !4941, metadata !DIExpression()), !dbg !5023
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !4992, metadata !DIExpression()), !dbg !4989
  %outDegree.i.i.i141 = getelementptr inbounds %struct.asymmetricVertex, %struct.asymmetricVertex* %28, i64 %__begin16.0, i32 2, !dbg !5024
  %59 = bitcast i32* %outDegree.i.i.i141 to i8*, !dbg !5024
  call void @__csan_load(i64 %42, i8* nonnull %59, i32 4, i64 8), !dbg !5024
  %60 = load i32, i32* %outDegree.i.i.i141, align 8, !dbg !5024, !tbaa !5025
  call void @llvm.dbg.value(metadata i32 %60, metadata !4942, metadata !DIExpression()), !dbg !5023
  %conv.i.i143 = zext i32 %60 to i64, !dbg !5028
  %cmp.i.i142 = icmp ugt i32 %60, 1000, !dbg !5029
  %tf.i165 = tail call token @llvm.taskframe.create(), !dbg !5030
  %syncreg.i.i140 = tail call token @llvm.syncregion.start()
  br i1 %cmp.i.i142, label %if.then.i.i149, label %for.cond.preheader.i.i144, !dbg !5031

for.cond.preheader.i.i144:                        ; preds = %if.then30.tf.split
  call void @llvm.dbg.value(metadata i64 0, metadata !5032, metadata !DIExpression()), !dbg !5033
  %cmp1478.i.i = icmp eq i32 %60, 0, !dbg !5034
  br i1 %cmp1478.i.i, label %_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEvlRS6_RT0_.exit.tfend, label %for.body.lr.ph.i.i147, !dbg !5035

for.body.lr.ph.i.i147:                            ; preds = %for.cond.preheader.i.i144
  %outNeighbors.i.i.i145 = getelementptr inbounds %struct.asymmetricVertex, %struct.asymmetricVertex* %28, i64 %__begin16.0, i32 1, !dbg !4995
  %61 = bitcast i32** %outNeighbors.i.i.i145 to i8*, !dbg !4995
  %62 = load i64, i64* @__csi_unit_store_base_id, align 8, !dbg !5036
  %63 = add i64 %62, 553, !dbg !5036
  %64 = add i64 %62, 557, !dbg !5056
  br label %for.body.i.i161, !dbg !5035

if.then.i.i149:                                   ; preds = %if.then30.tf.split
  call void @llvm.dbg.value(metadata i64 0, metadata !5211, metadata !DIExpression()), !dbg !5001
  call void @llvm.dbg.value(metadata i64 %conv.i.i143, metadata !5212, metadata !DIExpression()), !dbg !5001
  call void @llvm.dbg.value(metadata i64 0, metadata !5213, metadata !DIExpression()), !dbg !5001
  call void @llvm.dbg.value(metadata i64 %conv.i.i143, metadata !5214, metadata !DIExpression()), !dbg !5001
  %outNeighbors.i75.i.i = getelementptr inbounds %struct.asymmetricVertex, %struct.asymmetricVertex* %28, i64 %__begin16.0, i32 1, !dbg !5005
  call void @__csan_before_loop(i64 %48, i64 -1, i64 3), !dbg !5215
  %65 = bitcast i32** %outNeighbors.i75.i.i to i8*, !dbg !5005
  %66 = load i64, i64* @__csi_unit_store_base_id, align 8, !dbg !5216
  %67 = add i64 %66, 552, !dbg !5216
  %68 = add i64 %66, 556, !dbg !5220
  br label %pfor.cond.i.i151, !dbg !5215

pfor.cond.i.i151:                                 ; preds = %pfor.inc.i.i157, %if.then.i.i149
  %__begin.0.i.i150 = phi i64 [ 0, %if.then.i.i149 ], [ %inc.i.i155, %pfor.inc.i.i157 ], !dbg !5001
  call void @llvm.dbg.value(metadata i64 %__begin.0.i.i150, metadata !5213, metadata !DIExpression()), !dbg !5001
  call void @__csan_detach(i64 %34, i8 0), !dbg !5215
  detach within %syncreg.i.i140, label %pfor.body.i.i152, label %pfor.inc.i.i157, !dbg !5215

pfor.body.i.i152:                                 ; preds = %pfor.cond.i.i151
  %69 = call i8* @llvm.task.frameaddress(i32 0), !dbg !5013
  %70 = call i8* @llvm.stacksave(), !dbg !5013
  call void @__csan_task(i64 %35, i64 %34, i8* %69, i8* %70, i64 1), !dbg !5013
  call void @llvm.dbg.value(metadata i64 %__begin.0.i.i150, metadata !5224, metadata !DIExpression()), !dbg !5013
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !4998, metadata !DIExpression()), !dbg !5005
  call void @llvm.dbg.value(metadata i64 %__begin.0.i.i150, metadata !4999, metadata !DIExpression(DW_OP_LLVM_convert, 64, DW_ATE_unsigned, DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !5005
  call void @__csan_load(i64 %49, i8* nonnull %65, i32 8, i64 8), !dbg !5225
  %71 = load i32*, i32** %outNeighbors.i75.i.i, align 8, !dbg !5225, !tbaa !5226
  %arrayidx.i77.i.i = getelementptr inbounds i32, i32* %71, i64 %__begin.0.i.i150, !dbg !5225
  %72 = bitcast i32* %arrayidx.i77.i.i to i8*, !dbg !5225
  call void @__csan_load(i64 %50, i8* %72, i32 4, i64 4), !dbg !5225
  %73 = load i32, i32* %arrayidx.i77.i.i, align 4, !dbg !5225, !tbaa !5227
  call void @llvm.dbg.value(metadata i32 %73, metadata !5228, metadata !DIExpression()), !dbg !5229
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !4919, metadata !DIExpression()), !dbg !5010
  call void @llvm.dbg.value(metadata i32 %73, metadata !4921, metadata !DIExpression()), !dbg !5010
  call void @__csan_load(i64 %51, i8* nonnull %46, i32 8, i64 8), !dbg !5230
  %74 = load i32*, i32** %Parents.i59.i.i, align 8, !dbg !5230, !tbaa !5231
  %idxprom.i72.i.i = zext i32 %73 to i64, !dbg !5230
  %arrayidx.i73.i.i = getelementptr inbounds i32, i32* %74, i64 %idxprom.i72.i.i, !dbg !5230
  %75 = bitcast i32* %arrayidx.i73.i.i to i8*, !dbg !5230
  call void @__csan_load(i64 %52, i8* %75, i32 4, i64 4), !dbg !5230
  %76 = load i32, i32* %arrayidx.i73.i.i, align 4, !dbg !5230, !tbaa !5227
  %cmp.i74.i.i = icmp eq i32 %76, -1, !dbg !5233
  br i1 %cmp.i74.i.i, label %if.then7.i.i153, label %if.end.i.i154, !dbg !5234

if.then7.i.i153:                                  ; preds = %pfor.body.i.i152
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !5051, metadata !DIExpression()), !dbg !5235
  call void @llvm.dbg.value(metadata i32 %conv, metadata !5052, metadata !DIExpression()), !dbg !5235
  call void @llvm.dbg.value(metadata i32 %73, metadata !5053, metadata !DIExpression()), !dbg !5235
  call void @llvm.dbg.value(metadata i32* %arrayidx.i73.i.i, metadata !5044, metadata !DIExpression()), !dbg !5236
  call void @llvm.dbg.value(metadata i32 -1, metadata !5045, metadata !DIExpression()), !dbg !5236
  call void @llvm.dbg.value(metadata i32 %conv, metadata !5046, metadata !DIExpression()), !dbg !5236
  call void @__csan_store(i64 %67, i8* nonnull %75, i32 4, i64 0), !dbg !5237
  %77 = cmpxchg i32* %arrayidx.i73.i.i, i32 -1, i32 %conv seq_cst seq_cst, !dbg !5237
  %78 = extractvalue { i32, i1 } %77, 1, !dbg !5237
  call void @llvm.dbg.value(metadata i1 %78, metadata !5238, metadata !DIExpression()), !dbg !5239
  call void @llvm.dbg.value(metadata %class.anon.19* undef, metadata !5206, metadata !DIExpression()), !dbg !5240
  call void @llvm.dbg.value(metadata i32 %73, metadata !5208, metadata !DIExpression()), !dbg !5240
  call void @llvm.dbg.value(metadata i1 %78, metadata !5209, metadata !DIExpression()), !dbg !5240
  br i1 %78, label %if.then.i66.i.i, label %if.end.i.i154, !dbg !5241

if.then.i66.i.i:                                  ; preds = %if.then7.i.i153
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !5195, metadata !DIExpression()), !dbg !5242
  call void @llvm.dbg.value(metadata %"class.std::tuple.22"* undef, metadata !5196, metadata !DIExpression()), !dbg !5242
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !5146, metadata !DIExpression()), !dbg !5220
  call void @llvm.dbg.value(metadata %"class.std::tuple.22"* undef, metadata !5148, metadata !DIExpression()), !dbg !5220
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !4861, metadata !DIExpression()), !dbg !5243
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !4888, metadata !DIExpression()), !dbg !5245
  %_M_head_impl.i.i8.i.i.i65.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %31, i64 %idxprom.i72.i.i, i32 0, i32 0, i32 0, !dbg !5247
  call void @__csan_store(i64 %68, i8* %_M_head_impl.i.i8.i.i.i65.i.i, i32 1, i64 1), !dbg !5248
  store i8 1, i8* %_M_head_impl.i.i8.i.i.i65.i.i, align 1, !dbg !5248, !tbaa !4894
  br label %if.end.i.i154, !dbg !5249

if.end.i.i154:                                    ; preds = %if.then.i66.i.i, %if.then7.i.i153, %pfor.body.i.i152
  call void @__csan_task_exit(i64 %36, i64 %35, i64 %34, i8 0, i64 1), !dbg !5250
  reattach within %syncreg.i.i140, label %pfor.inc.i.i157, !dbg !5250

pfor.inc.i.i157:                                  ; preds = %if.end.i.i154, %pfor.cond.i.i151
  call void @__csan_detach_continue(i64 %37, i64 %34), !dbg !5251
  %inc.i.i155 = add nuw nsw i64 %__begin.0.i.i150, 1, !dbg !5251
  call void @llvm.dbg.value(metadata i64 %inc.i.i155, metadata !5213, metadata !DIExpression()), !dbg !5001
  %exitcond.i.i156 = icmp eq i64 %inc.i.i155, %conv.i.i143, !dbg !5251
  br i1 %exitcond.i.i156, label %pfor.cond.cleanup.i.i158, label %pfor.cond.i.i151, !dbg !5251, !llvm.loop !5252

pfor.cond.cleanup.i.i158:                         ; preds = %pfor.inc.i.i157
  call void @__csan_after_loop(i64 %48, i8 0, i64 3), !dbg !5251
  call void @__csan_sync(i64 %54, i8 0), !dbg !5251
  sync within %syncreg.i.i140, label %sync.continue.i.i159, !dbg !5251

sync.continue.i.i159:                             ; preds = %pfor.cond.cleanup.i.i158
  invoke void @llvm.sync.unwind(token %syncreg.i.i140)
          to label %_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEvlRS6_RT0_.exit.tfend unwind label %csi.cleanup187189, !dbg !5251

for.body.i.i161:                                  ; preds = %if.end25.i.i164, %for.body.lr.ph.i.i147
  %j12.079.i.i = phi i64 [ 0, %for.body.lr.ph.i.i147 ], [ %inc26.i.i163, %if.end25.i.i164 ]
  call void @llvm.dbg.value(metadata i64 %j12.079.i.i, metadata !5032, metadata !DIExpression()), !dbg !5033
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !4998, metadata !DIExpression()), !dbg !4995
  call void @llvm.dbg.value(metadata i64 %j12.079.i.i, metadata !4999, metadata !DIExpression(DW_OP_LLVM_convert, 64, DW_ATE_unsigned, DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !4995
  call void @__csan_load(i64 %43, i8* nonnull %61, i32 8, i64 8), !dbg !5253
  %79 = load i32*, i32** %outNeighbors.i.i.i145, align 8, !dbg !5253, !tbaa !5226
  %arrayidx.i63.i.i = getelementptr inbounds i32, i32* %79, i64 %j12.079.i.i, !dbg !5253
  %80 = bitcast i32* %arrayidx.i63.i.i to i8*, !dbg !5253
  call void @__csan_load(i64 %44, i8* %80, i32 4, i64 4), !dbg !5253
  %81 = load i32, i32* %arrayidx.i63.i.i, align 4, !dbg !5253, !tbaa !5227
  call void @llvm.dbg.value(metadata i32 %81, metadata !5254, metadata !DIExpression()), !dbg !5255
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !4919, metadata !DIExpression()), !dbg !4916
  call void @llvm.dbg.value(metadata i32 %81, metadata !4921, metadata !DIExpression()), !dbg !4916
  call void @__csan_load(i64 %45, i8* nonnull %46, i32 8, i64 8), !dbg !5256
  %82 = load i32*, i32** %Parents.i59.i.i, align 8, !dbg !5256, !tbaa !5231
  %idxprom.i60.i.i = zext i32 %81 to i64, !dbg !5256
  %arrayidx.i61.i.i = getelementptr inbounds i32, i32* %82, i64 %idxprom.i60.i.i, !dbg !5256
  %83 = bitcast i32* %arrayidx.i61.i.i to i8*, !dbg !5256
  call void @__csan_load(i64 %47, i8* %83, i32 4, i64 4), !dbg !5256
  %84 = load i32, i32* %arrayidx.i61.i.i, align 4, !dbg !5256, !tbaa !5227
  %cmp.i.i.i160 = icmp eq i32 %84, -1, !dbg !5257
  br i1 %cmp.i.i.i160, label %if.then19.i.i162, label %if.end25.i.i164, !dbg !5258

if.then19.i.i162:                                 ; preds = %for.body.i.i161
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !5051, metadata !DIExpression()), !dbg !5259
  call void @llvm.dbg.value(metadata i32 %conv, metadata !5052, metadata !DIExpression()), !dbg !5259
  call void @llvm.dbg.value(metadata i32 %81, metadata !5053, metadata !DIExpression()), !dbg !5259
  call void @llvm.dbg.value(metadata i32* %arrayidx.i61.i.i, metadata !5044, metadata !DIExpression()), !dbg !5260
  call void @llvm.dbg.value(metadata i32 -1, metadata !5045, metadata !DIExpression()), !dbg !5260
  call void @llvm.dbg.value(metadata i32 %conv, metadata !5046, metadata !DIExpression()), !dbg !5260
  call void @__csan_store(i64 %63, i8* nonnull %83, i32 4, i64 0), !dbg !5261
  %85 = cmpxchg i32* %arrayidx.i61.i.i, i32 -1, i32 %conv seq_cst seq_cst, !dbg !5261
  %86 = extractvalue { i32, i1 } %85, 1, !dbg !5261
  call void @llvm.dbg.value(metadata i1 %86, metadata !5262, metadata !DIExpression()), !dbg !5263
  call void @llvm.dbg.value(metadata %class.anon.19* undef, metadata !5206, metadata !DIExpression()), !dbg !5264
  call void @llvm.dbg.value(metadata i32 %81, metadata !5208, metadata !DIExpression()), !dbg !5264
  call void @llvm.dbg.value(metadata i1 %86, metadata !5209, metadata !DIExpression()), !dbg !5264
  br i1 %86, label %if.then.i.i.i, label %if.end25.i.i164, !dbg !5265

if.then.i.i.i:                                    ; preds = %if.then19.i.i162
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !5195, metadata !DIExpression()), !dbg !5266
  call void @llvm.dbg.value(metadata %"class.std::tuple.22"* undef, metadata !5196, metadata !DIExpression()), !dbg !5266
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !5146, metadata !DIExpression()), !dbg !5056
  call void @llvm.dbg.value(metadata %"class.std::tuple.22"* undef, metadata !5148, metadata !DIExpression()), !dbg !5056
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !4861, metadata !DIExpression()), !dbg !5267
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !4888, metadata !DIExpression()), !dbg !5269
  %_M_head_impl.i.i8.i.i.i.i.i = getelementptr inbounds %"class.std::tuple", %"class.std::tuple"* %31, i64 %idxprom.i60.i.i, i32 0, i32 0, i32 0, !dbg !5271
  call void @__csan_store(i64 %64, i8* %_M_head_impl.i.i8.i.i.i.i.i, i32 1, i64 1), !dbg !5272
  store i8 1, i8* %_M_head_impl.i.i8.i.i.i.i.i, align 1, !dbg !5272, !tbaa !4894
  br label %if.end25.i.i164, !dbg !5273

if.end25.i.i164:                                  ; preds = %if.then.i.i.i, %if.then19.i.i162, %for.body.i.i161
  %inc26.i.i163 = add nuw nsw i64 %j12.079.i.i, 1, !dbg !5034
  call void @llvm.dbg.value(metadata i64 %inc26.i.i163, metadata !5032, metadata !DIExpression()), !dbg !5033
  %exitcond80.i.i = icmp eq i64 %inc26.i.i163, %conv.i.i143, !dbg !5034
  br i1 %exitcond80.i.i, label %_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEvlRS6_RT0_.exit.tfend, label %for.body.i.i161, !dbg !5035, !llvm.loop !5274

_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEvlRS6_RT0_.exit.tfend: ; preds = %if.end25.i.i164, %sync.continue.i.i159, %for.cond.preheader.i.i144
  tail call void @llvm.taskframe.end(token %tf.i165), !dbg !5030
  br label %pfor.preattach32, !dbg !5275

pfor.preattach32:                                 ; preds = %_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEvlRS6_RT0_.exit.tfend, %pfor.body28
  call void @__csan_task_exit(i64 %12, i64 %11, i64 %10, i8 0, i64 1), !dbg !5276
  reattach within %syncreg47, label %pfor.inc33, !dbg !5276

pfor.inc33:                                       ; preds = %pfor.preattach32, %pfor.cond22
  call void @__csan_detach_continue(i64 %14, i64 %10), !dbg !5277
  %inc34 = add nuw nsw i64 %__begin16.0, 1, !dbg !5277
  call void @llvm.dbg.value(metadata i64 %inc34, metadata !5014, metadata !DIExpression()), !dbg !4904
  %exitcond = icmp eq i64 %inc34, %27, !dbg !5278
  br i1 %exitcond, label %pfor.cond.cleanup36, label %pfor.cond22, !dbg !5279, !llvm.loop !5280

pfor.cond.cleanup36:                              ; preds = %pfor.inc33
  call void @__csan_after_loop(i64 %33, i8 0, i64 1), !dbg !5279
  %87 = add i64 %53, 121, !dbg !5279
  call void @__csan_sync(i64 %87, i8 0), !dbg !5279
  sync within %syncreg47, label %sync.continue38, !dbg !5279

sync.continue38:                                  ; preds = %pfor.cond.cleanup36
  invoke void @llvm.sync.unwind(token %syncreg47)
          to label %cleanup41 unwind label %csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split-lp, !dbg !5279

cleanup41:                                        ; preds = %sync.continue38, %if.then
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %22), !dbg !5282
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %26), !dbg !5282
  call void @llvm.dbg.value(metadata %struct.vertexSubsetData* %agg.result, metadata !1590, metadata !DIExpression()), !dbg !5282
  call void @llvm.dbg.value(metadata i64 %27, metadata !1591, metadata !DIExpression()), !dbg !5282
  call void @llvm.dbg.value(metadata %"class.std::tuple"* %31, metadata !1592, metadata !DIExpression()), !dbg !5282
  %88 = bitcast %"class.std::tuple"** %_d.addr.i to i8**
  store i8* %call2, i8** %88, align 8, !tbaa !5283
  %s.i = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %agg.result, i64 0, i32 0, !dbg !5284
  %89 = load i64, i64* @__csi_unit_store_base_id, align 8, !dbg !5284, !invariant.load !45
  %90 = add i64 %89, 558, !dbg !5284
  %91 = bitcast %struct.vertexSubsetData* %agg.result to i8*, !dbg !5284
  call void @__csan_store(i64 %90, i8* %91, i32 8, i64 8), !dbg !5284
  store i32* null, i32** %s.i, align 8, !dbg !5284, !tbaa !5285
  %d.i136 = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %agg.result, i64 0, i32 1, !dbg !5286
  %.cast.i = ptrtoint i8* %call2 to i64, !dbg !5287
  call void @llvm.dbg.value(metadata %"class.std::tuple"* undef, metadata !1592, metadata !DIExpression()), !dbg !5282
  %92 = bitcast i8** %d.i136 to i64*, !dbg !5286
  %93 = add i64 %89, 559, !dbg !5286
  %94 = bitcast i8** %d.i136 to i8*, !dbg !5286
  call void @__csan_store(i64 %93, i8* nonnull %94, i32 8, i64 8), !dbg !5286
  store i64 %.cast.i, i64* %92, align 8, !dbg !5286, !tbaa !5018
  %n.i137 = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %agg.result, i64 0, i32 2, !dbg !5288
  %95 = add i64 %89, 560, !dbg !5288
  %96 = bitcast i64* %n.i137 to i8*, !dbg !5288
  call void @__csan_store(i64 %95, i8* nonnull %96, i32 8, i64 8), !dbg !5288
  store i64 %27, i64* %n.i137, align 8, !dbg !5288, !tbaa !5289
  %isDense.i138 = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %agg.result, i64 0, i32 4, !dbg !5290
  %97 = add i64 %89, 561, !dbg !5290
  call void @__csan_store(i64 %97, i8* nonnull %isDense.i138, i32 1, i64 8), !dbg !5290
  store i8 1, i8* %isDense.i138, align 8, !dbg !5290, !tbaa !5291
  call void @llvm.dbg.value(metadata %"class.std::tuple"** %_d.addr.i, metadata !1592, metadata !DIExpression(DW_OP_deref)), !dbg !5282
  call void @llvm.dbg.value(metadata %"class.std::tuple"** %_d.addr.i, metadata !5292, metadata !DIExpression(DW_OP_LLVM_fragment, 0, 64)), !dbg !5293
  call void @llvm.dbg.value(metadata i64 0, metadata !5292, metadata !DIExpression(DW_OP_LLVM_fragment, 64, 64)), !dbg !5293
  call void @llvm.dbg.value(metadata i64 %27, metadata !5292, metadata !DIExpression(DW_OP_LLVM_fragment, 128, 64)), !dbg !5293
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %24) #28, !dbg !5294
  %d_map.sroa.0.0..sroa_idx.i = getelementptr inbounds %struct.in_imap.25, %struct.in_imap.25* %agg.tmp3.i, i64 0, i32 0, i32 0, !dbg !5295
  store %"class.std::tuple"** %_d.addr.i, %"class.std::tuple"*** %d_map.sroa.0.0..sroa_idx.i, align 8, !dbg !5295, !tbaa.struct !5296
  %d_map.sroa.4.0..sroa_idx5.i = getelementptr inbounds %struct.in_imap.25, %struct.in_imap.25* %agg.tmp3.i, i64 0, i32 1, !dbg !5295
  store i64 0, i64* %d_map.sroa.4.0..sroa_idx5.i, align 8, !dbg !5295, !tbaa.struct !5296
  %d_map.sroa.5.0..sroa_idx7.i = getelementptr inbounds %struct.in_imap.25, %struct.in_imap.25* %agg.tmp3.i, i64 0, i32 2, !dbg !5295
  store i64 %27, i64* %d_map.sroa.5.0..sroa_idx7.i, align 8, !dbg !5295, !tbaa.struct !5296
  %98 = load i64, i64* @__csi_unit_callsite_base_id, align 8, !dbg !5298, !invariant.load !45
  %99 = add i64 %98, 467, !dbg !5298
  %100 = load i64, i64* @__csi_func_id__ZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS3_EEEUlmE_EZNS4_C1ElS7_EUlmmE_EENT_1TESB_RKT0_j, align 8, !dbg !5298
  call void @__csan_before_call(i64 %99, i64 %100, i8 0, i64 0), !dbg !5298
  %call.i183 = invoke i64 @_ZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS3_EEEUlmE_EZNS4_C1ElS7_EUlmmE_EENT_1TESB_RKT0_j(%struct.in_imap.25* nonnull byval(%struct.in_imap.25) align 8 %agg.tmp3.i, %class.anon.27* nonnull dereferenceable(1) %f.i, i32 0)
          to label %call.i.noexc unwind label %csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split, !dbg !5298

call.i.noexc:                                     ; preds = %cleanup41
  call void @__csan_after_call(i64 %99, i64 %100, i8 0, i64 0), !dbg !5299
  %m.i139 = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %agg.result, i64 0, i32 3, !dbg !5299
  %101 = add i64 %89, 562, !dbg !5300
  %102 = bitcast i64* %m.i139 to i8*, !dbg !5300
  call void @__csan_store(i64 %101, i8* nonnull %102, i32 8, i64 8), !dbg !5300
  store i64 %call.i183, i64* %m.i139, align 8, !dbg !5300, !tbaa !5301
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %24) #28, !dbg !5302
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %22), !dbg !5302
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %26), !dbg !5302
  br label %cleanup85

if.else:                                          ; preds = %entry
  call void @llvm.dbg.value(metadata i64 0, metadata !5303, metadata !DIExpression()), !dbg !5306
  call void @llvm.dbg.value(metadata i64 %27, metadata !5307, metadata !DIExpression()), !dbg !5306
  %cmp50 = icmp sgt i64 %27, 0, !dbg !5308
  br i1 %cmp50, label %pfor.cond59.preheader, label %cleanup81, !dbg !5309

pfor.cond59.preheader:                            ; preds = %if.else
  %d.i = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %vertexSubset, i64 0, i32 1, !dbg !5310
  %Parents.i58.i.i = getelementptr inbounds %struct.BFS_F, %struct.BFS_F* %f, i64 0, i32 0, !dbg !5315
  %103 = load i64, i64* @__csi_unit_loop_base_id, align 8, !dbg !5379, !invariant.load !45
  %104 = add i64 %103, 113, !dbg !5379
  call void @__csan_before_loop(i64 %104, i64 -1, i64 1), !dbg !5379
  %105 = add i64 %0, 127, !dbg !5380
  %106 = add i64 %2, 127, !dbg !5380
  %107 = add i64 %4, 165, !dbg !5380
  %108 = add i64 %7, 165, !dbg !5380
  %109 = load i64, i64* @__csi_unit_load_base_id, align 8, !dbg !5310
  %110 = add i64 %109, 997, !dbg !5310
  %111 = bitcast i8** %d.i to i8*, !dbg !5310
  %112 = add i64 %109, 986, !dbg !5310
  %113 = add i64 %109, 987, !dbg !5381
  %114 = add i64 %109, 991, !dbg !5383
  %115 = add i64 %109, 992, !dbg !5383
  %116 = add i64 %109, 999, !dbg !5315
  %117 = bitcast %struct.BFS_F* %f to i8*, !dbg !5315
  %118 = add i64 %109, 993, !dbg !5315
  %119 = add i64 %103, 114, !dbg !5385
  %120 = add i64 %109, 988, !dbg !5389
  %121 = add i64 %109, 989, !dbg !5389
  %122 = add i64 %109, 998, !dbg !5394
  %123 = add i64 %109, 990, !dbg !5394
  %124 = load i64, i64* @__csi_unit_sync_base_id, align 8, !dbg !5397
  %125 = add i64 %124, 122, !dbg !5397
  br label %pfor.cond59, !dbg !5379

pfor.cond59:                                      ; preds = %pfor.inc73, %pfor.cond59.preheader
  %__begin53.0 = phi i64 [ %inc74, %pfor.inc73 ], [ 0, %pfor.cond59.preheader ], !dbg !5306
  call void @llvm.dbg.value(metadata i64 %__begin53.0, metadata !5398, metadata !DIExpression()), !dbg !5306
  call void @__csan_detach(i64 %1, i8 0), !dbg !5379
  detach within %syncreg47, label %pfor.body65, label %pfor.inc73 unwind label %csi.cleanup.loopexit.split-lp.loopexit, !dbg !5379

pfor.body65:                                      ; preds = %pfor.cond59
  %126 = call i8* @llvm.task.frameaddress(i32 0), !dbg !5380
  %127 = call i8* @llvm.stacksave(), !dbg !5380
  call void @__csan_task(i64 %3, i64 %1, i8* %126, i8* %127, i64 3), !dbg !5380
  call void @llvm.dbg.value(metadata i64 %__begin53.0, metadata !5399, metadata !DIExpression()), !dbg !5380
  %conv67 = trunc i64 %__begin53.0 to i32, !dbg !5400
  call void @llvm.dbg.value(metadata %struct.vertexSubsetData* %vertexSubset, metadata !4909, metadata !DIExpression()), !dbg !5310
  call void @__csan_load(i64 %110, i8* nonnull %111, i32 8, i64 8), !dbg !5401
  %128 = load i8*, i8** %d.i, align 8, !dbg !5401, !tbaa !5018
  %idxprom.i = and i64 %__begin53.0, 4294967295, !dbg !5401
  %arrayidx.i = getelementptr inbounds i8, i8* %128, i64 %idxprom.i, !dbg !5401
  call void @__csan_load(i64 %112, i8* %arrayidx.i, i32 1, i64 1), !dbg !5401
  %129 = load i8, i8* %arrayidx.i, align 1, !dbg !5401, !tbaa !4894, !range !5020
  %tobool.i135 = icmp eq i8 %129, 0, !dbg !5401
  br i1 %tobool.i135, label %pfor.preattach72, label %if.then69.tf.split, !dbg !5402

if.then69.tf.split:                               ; preds = %pfor.body65
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !5373, metadata !DIExpression()), !dbg !5403
  call void @llvm.dbg.value(metadata i64 %__begin53.0, metadata !5374, metadata !DIExpression()), !dbg !5403
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !5375, metadata !DIExpression()), !dbg !5403
  call void @llvm.dbg.value(metadata %class.anon.20* undef, metadata !5376, metadata !DIExpression()), !dbg !5403
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !5331, metadata !DIExpression()), !dbg !5404
  call void @llvm.dbg.value(metadata i64 %__begin53.0, metadata !5332, metadata !DIExpression()), !dbg !5404
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !5333, metadata !DIExpression()), !dbg !5404
  call void @llvm.dbg.value(metadata %class.anon.20* undef, metadata !5334, metadata !DIExpression()), !dbg !5404
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !4992, metadata !DIExpression()), !dbg !5381
  %outDegree.i.i.i = getelementptr inbounds %struct.asymmetricVertex, %struct.asymmetricVertex* %28, i64 %__begin53.0, i32 2, !dbg !5405
  %130 = bitcast i32* %outDegree.i.i.i to i8*, !dbg !5405
  call void @__csan_load(i64 %113, i8* nonnull %130, i32 4, i64 8), !dbg !5405
  %131 = load i32, i32* %outDegree.i.i.i, align 8, !dbg !5405, !tbaa !5025
  call void @llvm.dbg.value(metadata i32 %131, metadata !5335, metadata !DIExpression()), !dbg !5404
  %conv.i.i = zext i32 %131 to i64, !dbg !5406
  %cmp.i.i = icmp ugt i32 %131, 1000, !dbg !5407
  %tf.i = tail call token @llvm.taskframe.create(), !dbg !5408
  %syncreg.i.i = tail call token @llvm.syncregion.start()
  br i1 %cmp.i.i, label %if.then.i.i, label %for.cond.preheader.i.i, !dbg !5409

for.cond.preheader.i.i:                           ; preds = %if.then69.tf.split
  call void @llvm.dbg.value(metadata i64 0, metadata !5410, metadata !DIExpression()), !dbg !5411
  %cmp1473.i.i = icmp eq i32 %131, 0, !dbg !5412
  br i1 %cmp1473.i.i, label %_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEvlRT_RT0_.exit.tfend, label %for.body.lr.ph.i.i, !dbg !5413

for.body.lr.ph.i.i:                               ; preds = %for.cond.preheader.i.i
  %outNeighbors.i.i.i = getelementptr inbounds %struct.asymmetricVertex, %struct.asymmetricVertex* %28, i64 %__begin53.0, i32 1, !dbg !5383
  %132 = bitcast i32** %outNeighbors.i.i.i to i8*, !dbg !5383
  %133 = load i64, i64* @__csi_unit_store_base_id, align 8, !dbg !5414
  %134 = add i64 %133, 555, !dbg !5414
  br label %for.body.i.i, !dbg !5413

if.then.i.i:                                      ; preds = %if.then69.tf.split
  call void @llvm.dbg.value(metadata i64 0, metadata !5418, metadata !DIExpression()), !dbg !5385
  call void @llvm.dbg.value(metadata i64 %conv.i.i, metadata !5419, metadata !DIExpression()), !dbg !5385
  call void @llvm.dbg.value(metadata i64 0, metadata !5420, metadata !DIExpression()), !dbg !5385
  call void @llvm.dbg.value(metadata i64 %conv.i.i, metadata !5421, metadata !DIExpression()), !dbg !5385
  %outNeighbors.i70.i.i = getelementptr inbounds %struct.asymmetricVertex, %struct.asymmetricVertex* %28, i64 %__begin53.0, i32 1, !dbg !5389
  call void @__csan_before_loop(i64 %119, i64 -1, i64 3), !dbg !5422
  %135 = bitcast i32** %outNeighbors.i70.i.i to i8*, !dbg !5389
  %136 = load i64, i64* @__csi_unit_store_base_id, align 8, !dbg !5423
  %137 = add i64 %136, 554, !dbg !5423
  br label %pfor.cond.i.i, !dbg !5422

pfor.cond.i.i:                                    ; preds = %pfor.inc.i.i, %if.then.i.i
  %__begin.0.i.i = phi i64 [ 0, %if.then.i.i ], [ %inc.i.i, %pfor.inc.i.i ], !dbg !5385
  call void @llvm.dbg.value(metadata i64 %__begin.0.i.i, metadata !5420, metadata !DIExpression()), !dbg !5385
  call void @__csan_detach(i64 %105, i8 0), !dbg !5422
  detach within %syncreg.i.i, label %pfor.body.i.i, label %pfor.inc.i.i, !dbg !5422

pfor.body.i.i:                                    ; preds = %pfor.cond.i.i
  %138 = call i8* @llvm.task.frameaddress(i32 0), !dbg !5397
  %139 = call i8* @llvm.stacksave(), !dbg !5397
  call void @__csan_task(i64 %106, i64 %105, i8* %138, i8* %139, i64 1), !dbg !5397
  call void @llvm.dbg.value(metadata i64 %__begin.0.i.i, metadata !5427, metadata !DIExpression()), !dbg !5397
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !4998, metadata !DIExpression()), !dbg !5389
  call void @llvm.dbg.value(metadata i64 %__begin.0.i.i, metadata !4999, metadata !DIExpression(DW_OP_LLVM_convert, 64, DW_ATE_unsigned, DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !5389
  call void @__csan_load(i64 %120, i8* nonnull %135, i32 8, i64 8), !dbg !5428
  %140 = load i32*, i32** %outNeighbors.i70.i.i, align 8, !dbg !5428, !tbaa !5226
  %arrayidx.i72.i.i = getelementptr inbounds i32, i32* %140, i64 %__begin.0.i.i, !dbg !5428
  %141 = bitcast i32* %arrayidx.i72.i.i to i8*, !dbg !5428
  call void @__csan_load(i64 %121, i8* %141, i32 4, i64 4), !dbg !5428
  %142 = load i32, i32* %arrayidx.i72.i.i, align 4, !dbg !5428, !tbaa !5227
  call void @llvm.dbg.value(metadata i32 %142, metadata !5429, metadata !DIExpression()), !dbg !5430
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !4919, metadata !DIExpression()), !dbg !5394
  call void @llvm.dbg.value(metadata i32 %142, metadata !4921, metadata !DIExpression()), !dbg !5394
  call void @__csan_load(i64 %122, i8* nonnull %117, i32 8, i64 8), !dbg !5431
  %143 = load i32*, i32** %Parents.i58.i.i, align 8, !dbg !5431, !tbaa !5231
  %idxprom.i67.i.i = zext i32 %142 to i64, !dbg !5431
  %arrayidx.i68.i.i = getelementptr inbounds i32, i32* %143, i64 %idxprom.i67.i.i, !dbg !5431
  %144 = bitcast i32* %arrayidx.i68.i.i to i8*, !dbg !5431
  call void @__csan_load(i64 %123, i8* %144, i32 4, i64 4), !dbg !5431
  %145 = load i32, i32* %arrayidx.i68.i.i, align 4, !dbg !5431, !tbaa !5227
  %cmp.i69.i.i = icmp eq i32 %145, -1, !dbg !5432
  br i1 %cmp.i69.i.i, label %if.then7.i.i, label %if.end.i.i, !dbg !5433

if.then7.i.i:                                     ; preds = %pfor.body.i.i
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !5051, metadata !DIExpression()), !dbg !5434
  call void @llvm.dbg.value(metadata i32 %conv67, metadata !5052, metadata !DIExpression()), !dbg !5434
  call void @llvm.dbg.value(metadata i32 %142, metadata !5053, metadata !DIExpression()), !dbg !5434
  call void @llvm.dbg.value(metadata i32* %arrayidx.i68.i.i, metadata !5044, metadata !DIExpression()), !dbg !5435
  call void @llvm.dbg.value(metadata i32 -1, metadata !5045, metadata !DIExpression()), !dbg !5435
  call void @llvm.dbg.value(metadata i32 %conv67, metadata !5046, metadata !DIExpression()), !dbg !5435
  call void @__csan_store(i64 %137, i8* nonnull %144, i32 4, i64 0), !dbg !5436
  %146 = cmpxchg i32* %arrayidx.i68.i.i, i32 -1, i32 %conv67 seq_cst seq_cst, !dbg !5436
  br label %if.end.i.i, !dbg !5437

if.end.i.i:                                       ; preds = %if.then7.i.i, %pfor.body.i.i
  call void @__csan_task_exit(i64 %107, i64 %106, i64 %105, i8 0, i64 1), !dbg !5438
  reattach within %syncreg.i.i, label %pfor.inc.i.i, !dbg !5438

pfor.inc.i.i:                                     ; preds = %if.end.i.i, %pfor.cond.i.i
  call void @__csan_detach_continue(i64 %108, i64 %105), !dbg !5439
  %inc.i.i = add nuw nsw i64 %__begin.0.i.i, 1, !dbg !5439
  call void @llvm.dbg.value(metadata i64 %inc.i.i, metadata !5420, metadata !DIExpression()), !dbg !5385
  %exitcond.i.i = icmp eq i64 %inc.i.i, %conv.i.i, !dbg !5439
  br i1 %exitcond.i.i, label %pfor.cond.cleanup.i.i, label %pfor.cond.i.i, !dbg !5439, !llvm.loop !5440

pfor.cond.cleanup.i.i:                            ; preds = %pfor.inc.i.i
  call void @__csan_after_loop(i64 %119, i8 0, i64 3), !dbg !5439
  call void @__csan_sync(i64 %125, i8 0), !dbg !5439
  sync within %syncreg.i.i, label %sync.continue.i.i, !dbg !5439

sync.continue.i.i:                                ; preds = %pfor.cond.cleanup.i.i
  invoke void @llvm.sync.unwind(token %syncreg.i.i)
          to label %_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEvlRT_RT0_.exit.tfend unwind label %csi.cleanup176178, !dbg !5439

for.body.i.i:                                     ; preds = %if.end25.i.i, %for.body.lr.ph.i.i
  %j12.074.i.i = phi i64 [ 0, %for.body.lr.ph.i.i ], [ %inc26.i.i, %if.end25.i.i ]
  call void @llvm.dbg.value(metadata i64 %j12.074.i.i, metadata !5410, metadata !DIExpression()), !dbg !5411
  call void @llvm.dbg.value(metadata %struct.asymmetricVertex* undef, metadata !4998, metadata !DIExpression()), !dbg !5383
  call void @llvm.dbg.value(metadata i64 %j12.074.i.i, metadata !4999, metadata !DIExpression(DW_OP_LLVM_convert, 64, DW_ATE_unsigned, DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !5383
  call void @__csan_load(i64 %114, i8* nonnull %132, i32 8, i64 8), !dbg !5441
  %147 = load i32*, i32** %outNeighbors.i.i.i, align 8, !dbg !5441, !tbaa !5226
  %arrayidx.i62.i.i = getelementptr inbounds i32, i32* %147, i64 %j12.074.i.i, !dbg !5441
  %148 = bitcast i32* %arrayidx.i62.i.i to i8*, !dbg !5441
  call void @__csan_load(i64 %115, i8* %148, i32 4, i64 4), !dbg !5441
  %149 = load i32, i32* %arrayidx.i62.i.i, align 4, !dbg !5441, !tbaa !5227
  call void @llvm.dbg.value(metadata i32 %149, metadata !5442, metadata !DIExpression()), !dbg !5443
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !4919, metadata !DIExpression()), !dbg !5315
  call void @llvm.dbg.value(metadata i32 %149, metadata !4921, metadata !DIExpression()), !dbg !5315
  call void @__csan_load(i64 %116, i8* nonnull %117, i32 8, i64 8), !dbg !5444
  %150 = load i32*, i32** %Parents.i58.i.i, align 8, !dbg !5444, !tbaa !5231
  %idxprom.i59.i.i = zext i32 %149 to i64, !dbg !5444
  %arrayidx.i60.i.i = getelementptr inbounds i32, i32* %150, i64 %idxprom.i59.i.i, !dbg !5444
  %151 = bitcast i32* %arrayidx.i60.i.i to i8*, !dbg !5444
  call void @__csan_load(i64 %118, i8* %151, i32 4, i64 4), !dbg !5444
  %152 = load i32, i32* %arrayidx.i60.i.i, align 4, !dbg !5444, !tbaa !5227
  %cmp.i.i.i = icmp eq i32 %152, -1, !dbg !5445
  br i1 %cmp.i.i.i, label %if.then19.i.i, label %if.end25.i.i, !dbg !5446

if.then19.i.i:                                    ; preds = %for.body.i.i
  call void @llvm.dbg.value(metadata %struct.BFS_F* %f, metadata !5051, metadata !DIExpression()), !dbg !5447
  call void @llvm.dbg.value(metadata i32 %conv67, metadata !5052, metadata !DIExpression()), !dbg !5447
  call void @llvm.dbg.value(metadata i32 %149, metadata !5053, metadata !DIExpression()), !dbg !5447
  call void @llvm.dbg.value(metadata i32* %arrayidx.i60.i.i, metadata !5044, metadata !DIExpression()), !dbg !5448
  call void @llvm.dbg.value(metadata i32 -1, metadata !5045, metadata !DIExpression()), !dbg !5448
  call void @llvm.dbg.value(metadata i32 %conv67, metadata !5046, metadata !DIExpression()), !dbg !5448
  call void @__csan_store(i64 %134, i8* nonnull %151, i32 4, i64 0), !dbg !5449
  %153 = cmpxchg i32* %arrayidx.i60.i.i, i32 -1, i32 %conv67 seq_cst seq_cst, !dbg !5449
  br label %if.end25.i.i, !dbg !5450

if.end25.i.i:                                     ; preds = %if.then19.i.i, %for.body.i.i
  %inc26.i.i = add nuw nsw i64 %j12.074.i.i, 1, !dbg !5412
  call void @llvm.dbg.value(metadata i64 %inc26.i.i, metadata !5410, metadata !DIExpression()), !dbg !5411
  %exitcond75.i.i = icmp eq i64 %inc26.i.i, %conv.i.i, !dbg !5412
  br i1 %exitcond75.i.i, label %_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEvlRT_RT0_.exit.tfend, label %for.body.i.i, !dbg !5413, !llvm.loop !5451

_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEvlRT_RT0_.exit.tfend: ; preds = %if.end25.i.i, %sync.continue.i.i, %for.cond.preheader.i.i
  tail call void @llvm.taskframe.end(token %tf.i), !dbg !5408
  br label %pfor.preattach72, !dbg !5452

pfor.preattach72:                                 ; preds = %_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEvlRT_RT0_.exit.tfend, %pfor.body65
  call void @__csan_task_exit(i64 %5, i64 %3, i64 %1, i8 0, i64 1), !dbg !5453
  reattach within %syncreg47, label %pfor.inc73, !dbg !5453

pfor.inc73:                                       ; preds = %pfor.preattach72, %pfor.cond59
  call void @__csan_detach_continue(i64 %8, i64 %1), !dbg !5454
  %inc74 = add nuw nsw i64 %__begin53.0, 1, !dbg !5454
  call void @llvm.dbg.value(metadata i64 %inc74, metadata !5398, metadata !DIExpression()), !dbg !5306
  %exitcond175 = icmp eq i64 %inc74, %27, !dbg !5455
  br i1 %exitcond175, label %pfor.cond.cleanup76, label %pfor.cond59, !dbg !5456, !llvm.loop !5457

pfor.cond.cleanup76:                              ; preds = %pfor.inc73
  call void @__csan_after_loop(i64 %104, i8 0, i64 1), !dbg !5456
  %154 = add i64 %124, 123, !dbg !5456
  call void @__csan_sync(i64 %154, i8 0), !dbg !5456
  sync within %syncreg47, label %sync.continue78, !dbg !5456

sync.continue78:                                  ; preds = %pfor.cond.cleanup76
  invoke void @llvm.sync.unwind(token %syncreg47)
          to label %cleanup81 unwind label %csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split-lp, !dbg !5456

cleanup81:                                        ; preds = %sync.continue78, %if.else
  call void @llvm.dbg.value(metadata %struct.vertexSubsetData* %agg.result, metadata !5459, metadata !DIExpression()) #28, !dbg !5463
  call void @llvm.dbg.value(metadata i64 %27, metadata !5462, metadata !DIExpression()) #28, !dbg !5463
  %n.i = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %agg.result, i64 0, i32 2, !dbg !5465
  %155 = bitcast %struct.vertexSubsetData* %agg.result to i8*, !dbg !5465
  %156 = load i64, i64* @__csi_unit_store_base_id, align 8, !dbg !5466, !invariant.load !45
  %157 = add i64 %156, 566, !dbg !5466
  call void @__csan_large_store(i64 %157, i8* %155, i64 16, i64 8), !dbg !5466
  tail call void @llvm.memset.p0i8.i64(i8* nonnull align 8 dereferenceable(16) %155, i8 0, i64 16, i1 false) #28, !dbg !5466
  %158 = add i64 %156, 563, !dbg !5465
  %159 = bitcast i64* %n.i to i8*, !dbg !5465
  call void @__csan_store(i64 %158, i8* nonnull %159, i32 8, i64 8), !dbg !5465
  store i64 %27, i64* %n.i, align 8, !dbg !5465, !tbaa !5289
  %m.i = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %agg.result, i64 0, i32 3, !dbg !5467
  %160 = add i64 %156, 564, !dbg !5467
  %161 = bitcast i64* %m.i to i8*, !dbg !5467
  call void @__csan_store(i64 %160, i8* nonnull %161, i32 8, i64 8), !dbg !5467
  store i64 0, i64* %m.i, align 8, !dbg !5467, !tbaa !5301
  %isDense.i = getelementptr inbounds %struct.vertexSubsetData, %struct.vertexSubsetData* %agg.result, i64 0, i32 4, !dbg !5468
  %162 = add i64 %156, 565, !dbg !5468
  call void @__csan_store(i64 %162, i8* nonnull %isDense.i, i32 1, i64 8), !dbg !5468
  store i8 0, i8* %isDense.i, align 8, !dbg !5468, !tbaa !5291
  br label %cleanup85

cleanup85:                                        ; preds = %cleanup81, %call.i.noexc
  %163 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !dbg !5469, !invariant.load !45
  %164 = add i64 %163, 151, !dbg !5469
  call void @__csan_func_exit(i64 %164, i64 %17, i64 1), !dbg !4816
  ret void, !dbg !5469

csi.cleanup.loopexit:                             ; preds = %csi.cleanup187, %pfor.cond22
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_loop(i64 %33, i8 0, i64 1), !dbg !4816
  call void @__csan_detach_continue(i64 %15, i64 %10), !dbg !4816
  br label %csi.cleanup

csi.cleanup.loopexit.split-lp.loopexit:           ; preds = %csi.cleanup176, %pfor.cond59
  %lpad.loopexit195 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_loop(i64 %104, i8 0, i64 1), !dbg !4816
  call void @__csan_detach_continue(i64 %9, i64 %1), !dbg !4816
  br label %csi.cleanup

csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split-lp: ; preds = %sync.continue78, %sync.continue38, %pfor.cond22.preheader
  %lpad.csi-split-lp = landingpad { i8*, i32 }
          cleanup
  br label %csi.cleanup

csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split: ; preds = %cleanup41
  %lpad.csi-split = landingpad { i8*, i32 }
          cleanup
  call void @__csan_after_call(i64 %99, i64 %100, i8 0, i64 0), !dbg !4816
  br label %csi.cleanup

csi.cleanup:                                      ; preds = %csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split, %csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split-lp, %csi.cleanup.loopexit.split-lp.loopexit, %csi.cleanup.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %csi.cleanup.loopexit ], [ %lpad.loopexit195, %csi.cleanup.loopexit.split-lp.loopexit ], [ %lpad.csi-split-lp, %csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split-lp ], [ %lpad.csi-split, %csi.cleanup.loopexit.split-lp.loopexit.split-lp.csi-split ]
  %165 = load i64, i64* @__csi_unit_func_exit_base_id, align 8, !invariant.load !45
  %166 = add i64 %165, 152
  call void @__csan_func_exit(i64 %166, i64 %17, i64 3), !dbg !4816
  resume { i8*, i32 } %lpad.phi

csi.cleanup.unreachable:                          ; preds = %csi.cleanup187189, %csi.cleanup187, %csi.cleanup176178, %csi.cleanup176
  unreachable

csi.cleanup176:                                   ; preds = %csi.cleanup176178
  %csi.cleanup.lpad177 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_task_exit(i64 %6, i64 %3, i64 %1, i8 0, i64 1)
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg47, { i8*, i32 } %csi.cleanup.lpad177)
          to label %csi.cleanup.unreachable unwind label %csi.cleanup.loopexit.split-lp.loopexit

csi.cleanup176178:                                ; preds = %sync.continue.i.i
  %csi.cleanup.lpad177179 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %tf.i, { i8*, i32 } %csi.cleanup.lpad177179)
          to label %csi.cleanup.unreachable unwind label %csi.cleanup176

csi.cleanup187:                                   ; preds = %csi.cleanup187189
  %csi.cleanup.lpad188 = landingpad { i8*, i32 }
          cleanup
  call void @__csan_task_exit(i64 %13, i64 %11, i64 %10, i8 0, i64 1)
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg47, { i8*, i32 } %csi.cleanup.lpad188)
          to label %csi.cleanup.unreachable unwind label %csi.cleanup.loopexit

csi.cleanup187189:                                ; preds = %sync.continue.i.i159
  %csi.cleanup.lpad188190 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %tf.i165, { i8*, i32 } %csi.cleanup.lpad188190)
          to label %csi.cleanup.unreachable unwind label %csi.cleanup187
}

; CHECK-LABEL: define {{.*}}void @_Z19edgeMapDenseForwardIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j.outline_pfor.cond59.ls1(

; CHECK: if.then69.tf.split.ls1:
; CHECK: %[[TF:.+]] = tail call token @llvm.taskframe.create()

; CHECK: csi.cleanup176178.ls1:
; CHECK: invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %[[TF]],
; CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %csi.cleanup176.ls1

; CHECK: [[UNREACHABLE]]:
; CHECK-NEXT: unreachable

; Function Attrs: uwtable
declare dso_local void @_Z12edgeMapDenseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.4* byval(%struct.graph.4) align 8, %struct.vertexSubsetData* dereferenceable(40), %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.4* dereferenceable(48), %struct.asymmetricVertex*, %struct.vertexSubsetData* dereferenceable(40), i32*, i32, %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z13edgeMapSparseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j(%struct.vertexSubsetData* noalias sret, %struct.graph.4* dereferenceable(48), %struct.asymmetricVertex*, %struct.vertexSubsetData* dereferenceable(40), i32*, i32, %struct.BFS_F* dereferenceable(8), i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_(%"class.std::tuple.35"*, %"class.std::tuple.35"*, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_(%"class.std::tuple.35"*, %"class.std::tuple.35"*, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_GLOBAL__sub_I_BFS.C() #8 section ".text.startup"

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #4

; Function Attrs: nofree nounwind
declare i64 @fwrite(i8* nocapture, i64, i64, %struct._IO_FILE* nocapture) local_unnamed_addr #2

; Function Attrs: nofree nounwind readonly
declare i32 @bcmp(i8* nocapture, i8* nocapture, i64) local_unnamed_addr #24

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #5

declare i32 @__gcc_personality_v0(...)

; Function Attrs: argmemonly willreturn
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #11

declare void @__csi_func_entry(i64, i64)

declare void @__csi_func_exit(i64, i64, i64)

declare void @__csi_before_loop(i64, i64, i64)

declare void @__csi_after_loop(i64, i64)

declare void @__csi_loopbody_entry(i64, i64)

declare void @__csi_loopbody_exit(i64, i64, i64)

declare void @__csi_before_alloca(i64, i64, i64)

; Function Attrs: inaccessiblememonly
declare void @__csi_after_alloca(i64, i8* nocapture readnone, i64, i64) #25

declare void @__csi_before_allocfn(i64, i64, i64, i64, i8*, i64)

declare void @__csi_after_allocfn(i64, i8*, i64, i64, i64, i8*, i64)

declare void @__csi_before_free(i64, i8*, i64)

declare void @__csi_after_free(i64, i8*, i64)

declare dso_local void @__csi_init_callsite_to_function()

; Function Attrs: inaccessiblememonly
declare void @__csan_func_entry(i64, i8* nocapture readnone, i8* nocapture readnone, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_func_exit(i64, i64, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_load(i64, i8* nocapture readnone, i32, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_store(i64, i8* nocapture readnone, i32, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_large_load(i64, i8* nocapture readnone, i64, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_large_store(i64, i8* nocapture readnone, i64, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_before_call(i64, i64, i8, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_after_call(i64, i64, i8, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_detach(i64, i8) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_task(i64, i64, i8* nocapture readnone, i8* nocapture readnone, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_task_exit(i64, i64, i64, i8, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_detach_continue(i64, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_sync(i64, i8) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_after_allocfn(i64, i8* nocapture readnone, i64, i64, i64, i8* nocapture readnone, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_after_free(i64, i8* nocapture readnone, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__cilksan_disable_checking() #25

; Function Attrs: inaccessiblememonly
declare void @__cilksan_enable_checking() #25

; Function Attrs: inaccessiblemem_or_argmemonly
declare void @__csan_get_MAAP(i64* nocapture, i64, i8) #26

; Function Attrs: inaccessiblememonly
declare void @__csan_set_MAAP(i64, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_before_loop(i64, i64, i64) #25

; Function Attrs: inaccessiblememonly
declare void @__csan_after_loop(i64, i8, i64) #25

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress.p0i8(i32 immarg) #27

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #28

; Function Attrs: nounwind willreturn
declare i8* @llvm.task.frameaddress(i32) #29

declare dso_local void @csirt.unit_ctor()

declare void @__csirt_unit_init(i8*, { i64, i8*, { i8*, i32, i32, i8* }* }*, { i64, { i8*, i32, i8* }* }*, void ()*)

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nofree nounwind }
attributes #3 = { norecurse nounwind readnone sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind readnone speculatable willreturn }
attributes #5 = { argmemonly nounwind willreturn }
attributes #6 = { nofree norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { inlinehint sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { argmemonly willreturn }
attributes #12 = { nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #13 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #14 = { sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { norecurse uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #17 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #18 = { argmemonly nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #19 = { nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #20 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #21 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #22 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #23 = { inlinehint uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #24 = { nofree nounwind readonly }
attributes #25 = { inaccessiblememonly }
attributes #26 = { inaccessiblemem_or_argmemonly }
attributes #27 = { nounwind readnone }
attributes #28 = { nounwind }
attributes #29 = { nounwind willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!4812, !4813, !4814}
!llvm.ident = !{!4815}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 46cdea0e962f3423b2fffa5746650aef824098f1)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !40, globals: !3295, imports: !3385, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "BFS.C", directory: "/data/compilers/tests/ligra/apps")
!2 = !{!3, !17, !24, !31}
!3 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "_Ios_Openmode", scope: !5, file: !4, line: 111, baseType: !6, size: 32, elements: !7, identifier: "_ZTSSt13_Ios_Openmode")
!4 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/ios_base.h", directory: "")
!5 = !DINamespace(name: "std", scope: null)
!6 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!7 = !{!8, !9, !10, !11, !12, !13, !14, !15, !16}
!8 = !DIEnumerator(name: "_S_app", value: 1)
!9 = !DIEnumerator(name: "_S_ate", value: 2)
!10 = !DIEnumerator(name: "_S_bin", value: 4)
!11 = !DIEnumerator(name: "_S_in", value: 8)
!12 = !DIEnumerator(name: "_S_out", value: 16)
!13 = !DIEnumerator(name: "_S_trunc", value: 32)
!14 = !DIEnumerator(name: "_S_ios_openmode_end", value: 65536)
!15 = !DIEnumerator(name: "_S_ios_openmode_max", value: 2147483647)
!16 = !DIEnumerator(name: "_S_ios_openmode_min", value: -2147483648)
!17 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "_Ios_Seekdir", scope: !5, file: !4, line: 193, baseType: !18, size: 32, elements: !19, identifier: "_ZTSSt12_Ios_Seekdir")
!18 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!19 = !{!20, !21, !22, !23}
!20 = !DIEnumerator(name: "_S_beg", value: 0, isUnsigned: true)
!21 = !DIEnumerator(name: "_S_cur", value: 1, isUnsigned: true)
!22 = !DIEnumerator(name: "_S_end", value: 2, isUnsigned: true)
!23 = !DIEnumerator(name: "_S_ios_seekdir_end", value: 65536, isUnsigned: true)
!24 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, scope: !26, file: !25, line: 169, baseType: !18, size: 32, elements: !29, identifier: "_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEUt_E")
!25 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/basic_string.h", directory: "")
!26 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "basic_string<char, std::char_traits<char>, std::allocator<char> >", scope: !28, file: !27, line: 1610, flags: DIFlagFwdDecl, identifier: "_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE")
!27 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/basic_string.tcc", directory: "")
!28 = !DINamespace(name: "__cxx11", scope: !5, exportSymbols: true)
!29 = !{!30}
!30 = !DIEnumerator(name: "_S_local_capacity", value: 15, isUnsigned: true)
!31 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "_Ios_Iostate", scope: !5, file: !4, line: 153, baseType: !6, size: 32, elements: !32, identifier: "_ZTSSt12_Ios_Iostate")
!32 = !{!33, !34, !35, !36, !37, !38, !39}
!33 = !DIEnumerator(name: "_S_goodbit", value: 0)
!34 = !DIEnumerator(name: "_S_badbit", value: 1)
!35 = !DIEnumerator(name: "_S_eofbit", value: 2)
!36 = !DIEnumerator(name: "_S_failbit", value: 4)
!37 = !DIEnumerator(name: "_S_ios_iostate_end", value: 65536)
!38 = !DIEnumerator(name: "_S_ios_iostate_max", value: 2147483647)
!39 = !DIEnumerator(name: "_S_ios_iostate_min", value: -2147483648)
!40 = !{!41, !46, !48, !51, !53, !49, !61, !65, !69, !70, !77, !81, !82, !68, !87, !91, !93, !111, !112, !191, !359, !421, !425, !495, !499, !568, !3, !6, !572, !631, !683, !202, !685, !358, !64, !698, !31, !52, !701, !711, !728, !729, !734, !745, !746, !749, !750, !753, !120, !754, !768, !1168, !771, !1172, !1178, !1182, !1183, !1186, !1187, !1270, !1277, !1318, !1323, !1326, !1394, !1400, !1403, !1418, !1421, !18, !1426, !1345, !1429, !1433, !1444, !1451, !1452, !1478, !1493, !1175, !1498, !1501, !1513, !1526, !1527, !1573, !1578, !50, !1581, !1623, !1631, !1634, !1659, !1663, !1697, !1700, !1703, !1708, !1838, !1732, !1841, !1844, !1853, !1858, !1864, !1870, !1880, !1885, !1886, !1890, !86, !1891, !1901, !1906, !1907, !1911, !1912, !1984, !1987, !1990, !1996, !2001, !365, !2002, !2006, !2010, !2013, !2014, !2017, !2018, !2057, !2087, !2212, !2215, !2223, !2229, !2234, !2235, !2236, !2304, !2310, !2315, !2316, !2319, !431, !2322, !2379, !126, !2394, !2406, !2412, !2416, !2419, !2422, !2384, !2425, !2444, !2481, !2501, !2505, !2508, !2521, !2524, !2527, !2531, !2532, !2536, !2537, !2548, !2553, !2554, !2559, !2611, !2616, !2620, !2623, !2626, !2629, !2641, !2642, !2646, !2647, !2651, !2655, !2656, !2660, !2664, !2668, !2671, !2672, !2675, !2676, !2715, !2745, !2870, !2873, !2881, !2887, !2892, !2893, !2894, !2962, !2968, !2973, !2974, !2977, !505, !2980, !2984, !2988, !2991, !2992, !2995, !2996, !3035, !3065, !3190, !3193, !3201, !3207, !3212, !3213, !3214, !3282, !3288, !3293, !3294, !26}
!41 = !DISubprogram(name: "mallopt", scope: !42, file: !42, line: 128, type: !43, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!42 = !DIFile(filename: "/usr/include/malloc.h", directory: "")
!43 = !DISubroutineType(types: !44)
!44 = !{!6, !6, !6}
!45 = !{}
!46 = !DIDerivedType(tag: DW_TAG_typedef, name: "intE", file: !47, line: 123, baseType: !6)
!47 = !DIFile(filename: "./parallel.h", directory: "/data/compilers/tests/ligra/apps")
!48 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !49, size: 64)
!49 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !50, size: 64)
!50 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintE", file: !47, line: 124, baseType: !18)
!51 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !52, size: 64)
!52 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!53 = !DISubprogram(name: "plusScan<long, long>", linkageName: "_ZN8sequence8plusScanIllEET_PS1_S2_T0_", scope: !55, file: !54, line: 229, type: !56, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !58, retainedNodes: !45)
!54 = !DIFile(filename: "./utils.h", directory: "/data/compilers/tests/ligra/apps")
!55 = !DINamespace(name: "sequence", scope: null)
!56 = !DISubroutineType(types: !57)
!57 = !{!52, !51, !51, !52}
!58 = !{!59, !60}
!59 = !DITemplateTypeParameter(name: "ET", type: !52)
!60 = !DITemplateTypeParameter(name: "intT", type: !52)
!61 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !62, size: 64)
!62 = !DIDerivedType(tag: DW_TAG_typedef, name: "uchar", file: !63, line: 27, baseType: !64)
!63 = !DIFile(filename: "./byteRLE.h", directory: "/data/compilers/tests/ligra/apps")
!64 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!65 = !DISubprogram(name: "free", scope: !42, file: !42, line: 62, type: !66, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!66 = !DISubroutineType(types: !67)
!67 = !{null, !68}
!68 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!69 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!70 = !DISubprogram(name: "open", scope: !71, file: !71, line: 196, type: !72, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!71 = !DIFile(filename: "/usr/include/fcntl.h", directory: "")
!72 = !DISubroutineType(types: !73)
!73 = !{!6, !74, !6, null}
!74 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !75, size: 64)
!75 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !76)
!76 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!77 = !DISubprogram(name: "perror", scope: !78, file: !78, line: 775, type: !79, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!78 = !DIFile(filename: "/usr/include/stdio.h", directory: "")
!79 = !DISubroutineType(types: !80)
!80 = !{null, !74}
!81 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !76, size: 64)
!82 = !DISubprogram(name: "mmap", scope: !83, file: !83, line: 57, type: !84, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!83 = !DIFile(filename: "/usr/include/sys/mman.h", directory: "")
!84 = !DISubroutineType(types: !85)
!85 = !{!68, !68, !86, !6, !6, !6, !52}
!86 = !DIBasicType(name: "long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!87 = !DISubprogram(name: "close", scope: !88, file: !88, line: 353, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!88 = !DIFile(filename: "/usr/include/unistd.h", directory: "")
!89 = !DISubroutineType(types: !90)
!90 = !{!6, !6}
!91 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !92, size: 64)
!92 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!93 = !DISubprogram(name: "packIndex<long>", linkageName: "_ZN8sequence9packIndexIlEE4_seqIT_EPbS2_", scope: !55, file: !54, line: 283, type: !94, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !110, retainedNodes: !45)
!94 = !DISubroutineType(types: !95)
!95 = !{!96, !91, !52}
!96 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_seq<long>", file: !54, line: 81, size: 128, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !97, templateParams: !108, identifier: "_ZTS4_seqIlE")
!97 = !{!98, !99, !100, !104, !107}
!98 = !DIDerivedType(tag: DW_TAG_member, name: "A", scope: !96, file: !54, line: 82, baseType: !51, size: 64)
!99 = !DIDerivedType(tag: DW_TAG_member, name: "n", scope: !96, file: !54, line: 83, baseType: !52, size: 64, offset: 64)
!100 = !DISubprogram(name: "_seq", scope: !96, file: !54, line: 84, type: !101, scopeLine: 84, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!101 = !DISubroutineType(types: !102)
!102 = !{null, !103}
!103 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !96, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!104 = !DISubprogram(name: "_seq", scope: !96, file: !54, line: 85, type: !105, scopeLine: 85, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!105 = !DISubroutineType(types: !106)
!106 = !{null, !103, !51, !52}
!107 = !DISubprogram(name: "del", linkageName: "_ZN4_seqIlE3delEv", scope: !96, file: !54, line: 86, type: !101, scopeLine: 86, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!108 = !{!109}
!109 = !DITemplateTypeParameter(name: "T", type: !52)
!110 = !{!60}
!111 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !81, size: 64)
!112 = !DISubprogram(name: "readCompressedGraph<compressedSymmetricVertex>", linkageName: "_Z19readCompressedGraphI25compressedSymmetricVertexE5graphIT_EPcbb", scope: !113, file: !113, line: 476, type: !114, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !189, retainedNodes: !45)
!113 = !DIFile(filename: "./IO.h", directory: "/data/compilers/tests/ligra/apps")
!114 = !DISubroutineType(types: !115)
!115 = !{!116, !81, !92, !92}
!116 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "graph<compressedSymmetricVertex>", file: !117, line: 58, size: 384, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !118, templateParams: !189, identifier: "_ZTS5graphI25compressedSymmetricVertexE")
!117 = !DIFile(filename: "./graph.h", directory: "/data/compilers/tests/ligra/apps")
!118 = !{!119, !161, !162, !163, !164, !165, !178, !182, !185, !188}
!119 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !116, file: !117, line: 59, baseType: !120, size: 64)
!120 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !121, size: 64)
!121 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "compressedSymmetricVertex", file: !122, line: 261, size: 128, flags: DIFlagTypePassByValue, elements: !123, identifier: "_ZTS25compressedSymmetricVertex")
!122 = !DIFile(filename: "./compressedVertex.h", directory: "/data/compilers/tests/ligra/apps")
!123 = !{!124, !125, !127, !131, !138, !139, !140, !144, !145, !148, !149, !152, !153, !156, !157, !160}
!124 = !DIDerivedType(tag: DW_TAG_member, name: "neighbors", scope: !121, file: !122, line: 262, baseType: !61, size: 64)
!125 = !DIDerivedType(tag: DW_TAG_member, name: "degree", scope: !121, file: !122, line: 263, baseType: !126, size: 32, offset: 64)
!126 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintT", file: !47, line: 111, baseType: !18)
!127 = !DISubprogram(name: "getInNeighbors", linkageName: "_ZN25compressedSymmetricVertex14getInNeighborsEv", scope: !121, file: !122, line: 264, type: !128, scopeLine: 264, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!128 = !DISubroutineType(types: !129)
!129 = !{!61, !130}
!130 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !121, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!131 = !DISubprogram(name: "getInNeighbors", linkageName: "_ZNK25compressedSymmetricVertex14getInNeighborsEv", scope: !121, file: !122, line: 265, type: !132, scopeLine: 265, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!132 = !DISubroutineType(types: !133)
!133 = !{!134, !136}
!134 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !135, size: 64)
!135 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !62)
!136 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !137, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!137 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !121)
!138 = !DISubprogram(name: "getOutNeighbors", linkageName: "_ZN25compressedSymmetricVertex15getOutNeighborsEv", scope: !121, file: !122, line: 266, type: !128, scopeLine: 266, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!139 = !DISubprogram(name: "getOutNeighbors", linkageName: "_ZNK25compressedSymmetricVertex15getOutNeighborsEv", scope: !121, file: !122, line: 267, type: !132, scopeLine: 267, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!140 = !DISubprogram(name: "getInNeighbor", linkageName: "_ZNK25compressedSymmetricVertex13getInNeighborEi", scope: !121, file: !122, line: 268, type: !141, scopeLine: 268, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!141 = !DISubroutineType(types: !142)
!142 = !{!143, !136, !143}
!143 = !DIDerivedType(tag: DW_TAG_typedef, name: "intT", file: !47, line: 110, baseType: !6)
!144 = !DISubprogram(name: "getOutNeighbor", linkageName: "_ZNK25compressedSymmetricVertex14getOutNeighborEi", scope: !121, file: !122, line: 269, type: !141, scopeLine: 269, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!145 = !DISubprogram(name: "getInDegree", linkageName: "_ZNK25compressedSymmetricVertex11getInDegreeEv", scope: !121, file: !122, line: 270, type: !146, scopeLine: 270, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!146 = !DISubroutineType(types: !147)
!147 = !{!126, !136}
!148 = !DISubprogram(name: "getOutDegree", linkageName: "_ZNK25compressedSymmetricVertex12getOutDegreeEv", scope: !121, file: !122, line: 271, type: !146, scopeLine: 271, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!149 = !DISubprogram(name: "setInNeighbors", linkageName: "_ZN25compressedSymmetricVertex14setInNeighborsEPh", scope: !121, file: !122, line: 272, type: !150, scopeLine: 272, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!150 = !DISubroutineType(types: !151)
!151 = !{null, !130, !61}
!152 = !DISubprogram(name: "setOutNeighbors", linkageName: "_ZN25compressedSymmetricVertex15setOutNeighborsEPh", scope: !121, file: !122, line: 273, type: !150, scopeLine: 273, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!153 = !DISubprogram(name: "setInDegree", linkageName: "_ZN25compressedSymmetricVertex11setInDegreeEj", scope: !121, file: !122, line: 274, type: !154, scopeLine: 274, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!154 = !DISubroutineType(types: !155)
!155 = !{null, !130, !126}
!156 = !DISubprogram(name: "setOutDegree", linkageName: "_ZN25compressedSymmetricVertex12setOutDegreeEj", scope: !121, file: !122, line: 275, type: !154, scopeLine: 275, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!157 = !DISubprogram(name: "flipEdges", linkageName: "_ZN25compressedSymmetricVertex9flipEdgesEv", scope: !121, file: !122, line: 276, type: !158, scopeLine: 276, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!158 = !DISubroutineType(types: !159)
!159 = !{null, !130}
!160 = !DISubprogram(name: "del", linkageName: "_ZN25compressedSymmetricVertex3delEv", scope: !121, file: !122, line: 277, type: !158, scopeLine: 277, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "n", scope: !116, file: !117, line: 60, baseType: !52, size: 64, offset: 64)
!162 = !DIDerivedType(tag: DW_TAG_member, name: "m", scope: !116, file: !117, line: 61, baseType: !52, size: 64, offset: 128)
!163 = !DIDerivedType(tag: DW_TAG_member, name: "transposed", scope: !116, file: !117, line: 62, baseType: !92, size: 8, offset: 192)
!164 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !116, file: !117, line: 63, baseType: !49, size: 64, offset: 256)
!165 = !DIDerivedType(tag: DW_TAG_member, name: "D", scope: !116, file: !117, line: 64, baseType: !166, size: 64, offset: 320)
!166 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !167, size: 64)
!167 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "Deletable", file: !117, line: 17, size: 64, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !168, vtableHolder: !167, identifier: "_ZTS9Deletable")
!168 = !{!169, !174}
!169 = !DIDerivedType(tag: DW_TAG_member, name: "_vptr$Deletable", scope: !117, file: !117, baseType: !170, size: 64, flags: DIFlagArtificial)
!170 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !171, size: 64)
!171 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "__vtbl_ptr_type", baseType: !172, size: 64)
!172 = !DISubroutineType(types: !173)
!173 = !{!6}
!174 = !DISubprogram(name: "del", linkageName: "_ZN9Deletable3delEv", scope: !167, file: !117, line: 19, type: !175, scopeLine: 19, containingType: !167, virtualIndex: 0, flags: DIFlagPrototyped, spFlags: DISPFlagPureVirtual | DISPFlagOptimized)
!175 = !DISubroutineType(types: !176)
!176 = !{null, !177}
!177 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !167, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!178 = !DISubprogram(name: "graph", scope: !116, file: !117, line: 66, type: !179, scopeLine: 66, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!179 = !DISubroutineType(types: !180)
!180 = !{null, !181, !120, !52, !52, !166}
!181 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !116, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!182 = !DISubprogram(name: "graph", scope: !116, file: !117, line: 69, type: !183, scopeLine: 69, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!183 = !DISubroutineType(types: !184)
!184 = !{null, !181, !120, !52, !52, !166, !49}
!185 = !DISubprogram(name: "del", linkageName: "_ZN5graphI25compressedSymmetricVertexE3delEv", scope: !116, file: !117, line: 72, type: !186, scopeLine: 72, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!186 = !DISubroutineType(types: !187)
!187 = !{null, !181}
!188 = !DISubprogram(name: "transpose", linkageName: "_ZN5graphI25compressedSymmetricVertexE9transposeEv", scope: !116, file: !117, line: 78, type: !186, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!189 = !{!190}
!190 = !DITemplateTypeParameter(name: "vertex", type: !121)
!191 = !DISubprogram(name: "Compute<compressedSymmetricVertex>", linkageName: "_Z7ComputeI25compressedSymmetricVertexEvR5graphIT_E11commandLine", scope: !192, file: !192, line: 467, type: !193, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !189, retainedNodes: !45)
!192 = !DIFile(filename: "./ligra.h", directory: "/data/compilers/tests/ligra/apps")
!193 = !DISubroutineType(types: !194)
!194 = !{null, !195, !196}
!195 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !116, size: 64)
!196 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "commandLine", file: !197, line: 33, size: 384, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !198, identifier: "_ZTS11commandLine")
!197 = !DIFile(filename: "./parseCommandLine.h", directory: "/data/compilers/tests/ligra/apps")
!198 = !{!199, !200, !201, !204, !208, !211, !214, !217, !284, !340, !343, !346, !349, !352, !355}
!199 = !DIDerivedType(tag: DW_TAG_member, name: "argc", scope: !196, file: !197, line: 34, baseType: !6, size: 32)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "argv", scope: !196, file: !197, line: 35, baseType: !111, size: 64, offset: 64)
!201 = !DIDerivedType(tag: DW_TAG_member, name: "comLine", scope: !196, file: !197, line: 36, baseType: !202, size: 256, offset: 128)
!202 = !DIDerivedType(tag: DW_TAG_typedef, name: "string", scope: !5, file: !203, line: 79, baseType: !26)
!203 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/stringfwd.h", directory: "")
!204 = !DISubprogram(name: "commandLine", scope: !196, file: !197, line: 37, type: !205, scopeLine: 37, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!205 = !DISubroutineType(types: !206)
!206 = !{null, !207, !6, !111, !202}
!207 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !196, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!208 = !DISubprogram(name: "commandLine", scope: !196, file: !197, line: 40, type: !209, scopeLine: 40, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!209 = !DISubroutineType(types: !210)
!210 = !{null, !207, !6, !111}
!211 = !DISubprogram(name: "badArgument", linkageName: "_ZN11commandLine11badArgumentEv", scope: !196, file: !197, line: 43, type: !212, scopeLine: 43, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!212 = !DISubroutineType(types: !213)
!213 = !{null, !207}
!214 = !DISubprogram(name: "getArgument", linkageName: "_ZN11commandLine11getArgumentEi", scope: !196, file: !197, line: 50, type: !215, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!215 = !DISubroutineType(types: !216)
!216 = !{!81, !207, !6}
!217 = !DISubprogram(name: "IOFileNames", linkageName: "_ZN11commandLine11IOFileNamesEv", scope: !196, file: !197, line: 56, type: !218, scopeLine: 56, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!218 = !DISubroutineType(types: !219)
!219 = !{!220, !207}
!220 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "pair<char *, char *>", scope: !5, file: !221, line: 211, size: 128, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !222, templateParams: !281, identifier: "_ZTSSt4pairIPcS0_E")
!221 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/stl_pair.h", directory: "")
!222 = !{!223, !243, !244, !245, !251, !255, !269, !278}
!223 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !220, baseType: !224, flags: DIFlagPrivate, extraData: i32 0)
!224 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "__pair_base<char *, char *>", scope: !5, file: !221, line: 189, size: 8, flags: DIFlagTypePassByValue, elements: !225, templateParams: !240, identifier: "_ZTSSt11__pair_baseIPcS0_E")
!225 = !{!226, !230, !231, !236}
!226 = !DISubprogram(name: "__pair_base", scope: !224, file: !221, line: 193, type: !227, scopeLine: 193, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!227 = !DISubroutineType(types: !228)
!228 = !{null, !229}
!229 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !224, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!230 = !DISubprogram(name: "~__pair_base", scope: !224, file: !221, line: 194, type: !227, scopeLine: 194, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!231 = !DISubprogram(name: "__pair_base", scope: !224, file: !221, line: 195, type: !232, scopeLine: 195, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!232 = !DISubroutineType(types: !233)
!233 = !{null, !229, !234}
!234 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !235, size: 64)
!235 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !224)
!236 = !DISubprogram(name: "operator=", linkageName: "_ZNSt11__pair_baseIPcS0_EaSERKS1_", scope: !224, file: !221, line: 196, type: !237, scopeLine: 196, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized | DISPFlagDeleted)
!237 = !DISubroutineType(types: !238)
!238 = !{!239, !229, !234}
!239 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !224, size: 64)
!240 = !{!241, !242}
!241 = !DITemplateTypeParameter(name: "_U1", type: !81)
!242 = !DITemplateTypeParameter(name: "_U2", type: !81)
!243 = !DIDerivedType(tag: DW_TAG_member, name: "first", scope: !220, file: !221, line: 217, baseType: !81, size: 64)
!244 = !DIDerivedType(tag: DW_TAG_member, name: "second", scope: !220, file: !221, line: 218, baseType: !81, size: 64, offset: 64)
!245 = !DISubprogram(name: "pair", scope: !220, file: !221, line: 314, type: !246, scopeLine: 314, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!246 = !DISubroutineType(types: !247)
!247 = !{null, !248, !249}
!248 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !220, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!249 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !250, size: 64)
!250 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !220)
!251 = !DISubprogram(name: "pair", scope: !220, file: !221, line: 315, type: !252, scopeLine: 315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!252 = !DISubroutineType(types: !253)
!253 = !{null, !248, !254}
!254 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !220, size: 64)
!255 = !DISubprogram(name: "operator=", linkageName: "_ZNSt4pairIPcS0_EaSERKS1_", scope: !220, file: !221, line: 390, type: !256, scopeLine: 390, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!256 = !DISubroutineType(types: !257)
!257 = !{!258, !248, !259}
!258 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !220, size: 64)
!259 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !261, file: !260, line: 2201, baseType: !249)
!260 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/type_traits", directory: "")
!261 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, const std::pair<char *, char *> &, const std::__nonesuch &>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !262, identifier: "_ZTSSt11conditionalILb1ERKSt4pairIPcS1_ERKSt10__nonesuchE")
!262 = !{!263, !264, !265}
!263 = !DITemplateValueParameter(name: "_Cond", type: !92, value: i8 1)
!264 = !DITemplateTypeParameter(name: "_Iftrue", type: !249)
!265 = !DITemplateTypeParameter(name: "_Iffalse", type: !266)
!266 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !267, size: 64)
!267 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !268)
!268 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "__nonesuch", scope: !5, file: !260, line: 2939, flags: DIFlagFwdDecl, identifier: "_ZTSSt10__nonesuch")
!269 = !DISubprogram(name: "operator=", linkageName: "_ZNSt4pairIPcS0_EaSEOS1_", scope: !220, file: !221, line: 401, type: !270, scopeLine: 401, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!270 = !DISubroutineType(types: !271)
!271 = !{!258, !248, !272}
!272 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !273, file: !260, line: 2201, baseType: !254)
!273 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, std::pair<char *, char *> &&, std::__nonesuch &&>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !274, identifier: "_ZTSSt11conditionalILb1EOSt4pairIPcS1_EOSt10__nonesuchE")
!274 = !{!263, !275, !276}
!275 = !DITemplateTypeParameter(name: "_Iftrue", type: !254)
!276 = !DITemplateTypeParameter(name: "_Iffalse", type: !277)
!277 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !268, size: 64)
!278 = !DISubprogram(name: "swap", linkageName: "_ZNSt4pairIPcS0_E4swapERS1_", scope: !220, file: !221, line: 439, type: !279, scopeLine: 439, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!279 = !DISubroutineType(types: !280)
!280 = !{null, !248, !258}
!281 = !{!282, !283}
!282 = !DITemplateTypeParameter(name: "_T1", type: !81)
!283 = !DITemplateTypeParameter(name: "_T2", type: !81)
!284 = !DISubprogram(name: "sizeAndFileName", linkageName: "_ZN11commandLine15sizeAndFileNameEv", scope: !196, file: !197, line: 61, type: !285, scopeLine: 61, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!285 = !DISubroutineType(types: !286)
!286 = !{!287, !207}
!287 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "pair<int, char *>", scope: !5, file: !221, line: 211, size: 128, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !288, templateParams: !338, identifier: "_ZTSSt4pairIiPcE")
!288 = !{!289, !308, !309, !310, !316, !320, !328, !335}
!289 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !287, baseType: !290, flags: DIFlagPrivate, extraData: i32 0)
!290 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "__pair_base<int, char *>", scope: !5, file: !221, line: 189, size: 8, flags: DIFlagTypePassByValue, elements: !291, templateParams: !306, identifier: "_ZTSSt11__pair_baseIiPcE")
!291 = !{!292, !296, !297, !302}
!292 = !DISubprogram(name: "__pair_base", scope: !290, file: !221, line: 193, type: !293, scopeLine: 193, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!293 = !DISubroutineType(types: !294)
!294 = !{null, !295}
!295 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !290, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!296 = !DISubprogram(name: "~__pair_base", scope: !290, file: !221, line: 194, type: !293, scopeLine: 194, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!297 = !DISubprogram(name: "__pair_base", scope: !290, file: !221, line: 195, type: !298, scopeLine: 195, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!298 = !DISubroutineType(types: !299)
!299 = !{null, !295, !300}
!300 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !301, size: 64)
!301 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !290)
!302 = !DISubprogram(name: "operator=", linkageName: "_ZNSt11__pair_baseIiPcEaSERKS1_", scope: !290, file: !221, line: 196, type: !303, scopeLine: 196, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized | DISPFlagDeleted)
!303 = !DISubroutineType(types: !304)
!304 = !{!305, !295, !300}
!305 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !290, size: 64)
!306 = !{!307, !242}
!307 = !DITemplateTypeParameter(name: "_U1", type: !6)
!308 = !DIDerivedType(tag: DW_TAG_member, name: "first", scope: !287, file: !221, line: 217, baseType: !6, size: 32)
!309 = !DIDerivedType(tag: DW_TAG_member, name: "second", scope: !287, file: !221, line: 218, baseType: !81, size: 64, offset: 64)
!310 = !DISubprogram(name: "pair", scope: !287, file: !221, line: 314, type: !311, scopeLine: 314, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!311 = !DISubroutineType(types: !312)
!312 = !{null, !313, !314}
!313 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !287, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!314 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !315, size: 64)
!315 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !287)
!316 = !DISubprogram(name: "pair", scope: !287, file: !221, line: 315, type: !317, scopeLine: 315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!317 = !DISubroutineType(types: !318)
!318 = !{null, !313, !319}
!319 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !287, size: 64)
!320 = !DISubprogram(name: "operator=", linkageName: "_ZNSt4pairIiPcEaSERKS1_", scope: !287, file: !221, line: 390, type: !321, scopeLine: 390, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!321 = !DISubroutineType(types: !322)
!322 = !{!323, !313, !324}
!323 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !287, size: 64)
!324 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !325, file: !260, line: 2201, baseType: !314)
!325 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, const std::pair<int, char *> &, const std::__nonesuch &>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !326, identifier: "_ZTSSt11conditionalILb1ERKSt4pairIiPcERKSt10__nonesuchE")
!326 = !{!263, !327, !265}
!327 = !DITemplateTypeParameter(name: "_Iftrue", type: !314)
!328 = !DISubprogram(name: "operator=", linkageName: "_ZNSt4pairIiPcEaSEOS1_", scope: !287, file: !221, line: 401, type: !329, scopeLine: 401, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!329 = !DISubroutineType(types: !330)
!330 = !{!323, !313, !331}
!331 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !332, file: !260, line: 2201, baseType: !319)
!332 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, std::pair<int, char *> &&, std::__nonesuch &&>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !333, identifier: "_ZTSSt11conditionalILb1EOSt4pairIiPcEOSt10__nonesuchE")
!333 = !{!263, !334, !276}
!334 = !DITemplateTypeParameter(name: "_Iftrue", type: !319)
!335 = !DISubprogram(name: "swap", linkageName: "_ZNSt4pairIiPcE4swapERS1_", scope: !287, file: !221, line: 439, type: !336, scopeLine: 439, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!336 = !DISubroutineType(types: !337)
!337 = !{null, !313, !323}
!338 = !{!339, !283}
!339 = !DITemplateTypeParameter(name: "_T1", type: !6)
!340 = !DISubprogram(name: "getOption", linkageName: "_ZN11commandLine9getOptionENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", scope: !196, file: !197, line: 66, type: !341, scopeLine: 66, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!341 = !DISubroutineType(types: !342)
!342 = !{!92, !207, !202}
!343 = !DISubprogram(name: "getOptionValue", linkageName: "_ZN11commandLine14getOptionValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", scope: !196, file: !197, line: 72, type: !344, scopeLine: 72, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!344 = !DISubroutineType(types: !345)
!345 = !{!81, !207, !202}
!346 = !DISubprogram(name: "getOptionValue", linkageName: "_ZN11commandLine14getOptionValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES5_", scope: !196, file: !197, line: 78, type: !347, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!347 = !DISubroutineType(types: !348)
!348 = !{!202, !207, !202, !202}
!349 = !DISubprogram(name: "getOptionIntValue", linkageName: "_ZN11commandLine17getOptionIntValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEi", scope: !196, file: !197, line: 84, type: !350, scopeLine: 84, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!350 = !DISubroutineType(types: !351)
!351 = !{!6, !207, !202, !6}
!352 = !DISubprogram(name: "getOptionLongValue", linkageName: "_ZN11commandLine18getOptionLongValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEl", scope: !196, file: !197, line: 93, type: !353, scopeLine: 93, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!353 = !DISubroutineType(types: !354)
!354 = !{!52, !207, !202, !52}
!355 = !DISubprogram(name: "getOptionDoubleValue", linkageName: "_ZN11commandLine20getOptionDoubleValueENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd", scope: !196, file: !197, line: 102, type: !356, scopeLine: 102, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!356 = !DISubroutineType(types: !357)
!357 = !{!358, !207, !202, !358}
!358 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!359 = !DISubprogram(name: "readCompressedGraph<compressedAsymmetricVertex>", linkageName: "_Z19readCompressedGraphI26compressedAsymmetricVertexE5graphIT_EPcbb", scope: !113, file: !113, line: 476, type: !360, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !419, retainedNodes: !45)
!360 = !DISubroutineType(types: !361)
!361 = !{!362, !81, !92, !92}
!362 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "graph<compressedAsymmetricVertex>", file: !117, line: 58, size: 384, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !363, templateParams: !419, identifier: "_ZTS5graphI26compressedAsymmetricVertexE")
!363 = !{!364, !403, !404, !405, !406, !407, !408, !412, !415, !418}
!364 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !362, file: !117, line: 59, baseType: !365, size: 64)
!365 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !366, size: 64)
!366 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "compressedAsymmetricVertex", file: !122, line: 317, size: 192, flags: DIFlagTypePassByValue, elements: !367, identifier: "_ZTS26compressedAsymmetricVertex")
!367 = !{!368, !369, !370, !371, !372, !376, !381, !382, !383, !386, !387, !390, !391, !394, !395, !398, !399, !402}
!368 = !DIDerivedType(tag: DW_TAG_member, name: "inNeighbors", scope: !366, file: !122, line: 318, baseType: !61, size: 64)
!369 = !DIDerivedType(tag: DW_TAG_member, name: "outNeighbors", scope: !366, file: !122, line: 319, baseType: !61, size: 64, offset: 64)
!370 = !DIDerivedType(tag: DW_TAG_member, name: "outDegree", scope: !366, file: !122, line: 320, baseType: !126, size: 32, offset: 128)
!371 = !DIDerivedType(tag: DW_TAG_member, name: "inDegree", scope: !366, file: !122, line: 321, baseType: !126, size: 32, offset: 160)
!372 = !DISubprogram(name: "getInNeighbors", linkageName: "_ZN26compressedAsymmetricVertex14getInNeighborsEv", scope: !366, file: !122, line: 322, type: !373, scopeLine: 322, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!373 = !DISubroutineType(types: !374)
!374 = !{!61, !375}
!375 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !366, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!376 = !DISubprogram(name: "getInNeighbors", linkageName: "_ZNK26compressedAsymmetricVertex14getInNeighborsEv", scope: !366, file: !122, line: 323, type: !377, scopeLine: 323, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!377 = !DISubroutineType(types: !378)
!378 = !{!134, !379}
!379 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !380, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!380 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !366)
!381 = !DISubprogram(name: "getOutNeighbors", linkageName: "_ZN26compressedAsymmetricVertex15getOutNeighborsEv", scope: !366, file: !122, line: 324, type: !373, scopeLine: 324, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!382 = !DISubprogram(name: "getOutNeighbors", linkageName: "_ZNK26compressedAsymmetricVertex15getOutNeighborsEv", scope: !366, file: !122, line: 325, type: !377, scopeLine: 325, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!383 = !DISubprogram(name: "getInNeighbor", linkageName: "_ZNK26compressedAsymmetricVertex13getInNeighborEi", scope: !366, file: !122, line: 326, type: !384, scopeLine: 326, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!384 = !DISubroutineType(types: !385)
!385 = !{!143, !379, !143}
!386 = !DISubprogram(name: "getOutNeighbor", linkageName: "_ZNK26compressedAsymmetricVertex14getOutNeighborEi", scope: !366, file: !122, line: 327, type: !384, scopeLine: 327, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!387 = !DISubprogram(name: "getInDegree", linkageName: "_ZNK26compressedAsymmetricVertex11getInDegreeEv", scope: !366, file: !122, line: 328, type: !388, scopeLine: 328, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!388 = !DISubroutineType(types: !389)
!389 = !{!126, !379}
!390 = !DISubprogram(name: "getOutDegree", linkageName: "_ZNK26compressedAsymmetricVertex12getOutDegreeEv", scope: !366, file: !122, line: 329, type: !388, scopeLine: 329, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!391 = !DISubprogram(name: "setInNeighbors", linkageName: "_ZN26compressedAsymmetricVertex14setInNeighborsEPh", scope: !366, file: !122, line: 330, type: !392, scopeLine: 330, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!392 = !DISubroutineType(types: !393)
!393 = !{null, !375, !61}
!394 = !DISubprogram(name: "setOutNeighbors", linkageName: "_ZN26compressedAsymmetricVertex15setOutNeighborsEPh", scope: !366, file: !122, line: 331, type: !392, scopeLine: 331, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!395 = !DISubprogram(name: "setInDegree", linkageName: "_ZN26compressedAsymmetricVertex11setInDegreeEj", scope: !366, file: !122, line: 332, type: !396, scopeLine: 332, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!396 = !DISubroutineType(types: !397)
!397 = !{null, !375, !126}
!398 = !DISubprogram(name: "setOutDegree", linkageName: "_ZN26compressedAsymmetricVertex12setOutDegreeEj", scope: !366, file: !122, line: 333, type: !396, scopeLine: 333, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!399 = !DISubprogram(name: "flipEdges", linkageName: "_ZN26compressedAsymmetricVertex9flipEdgesEv", scope: !366, file: !122, line: 334, type: !400, scopeLine: 334, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!400 = !DISubroutineType(types: !401)
!401 = !{null, !375}
!402 = !DISubprogram(name: "del", linkageName: "_ZN26compressedAsymmetricVertex3delEv", scope: !366, file: !122, line: 336, type: !400, scopeLine: 336, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!403 = !DIDerivedType(tag: DW_TAG_member, name: "n", scope: !362, file: !117, line: 60, baseType: !52, size: 64, offset: 64)
!404 = !DIDerivedType(tag: DW_TAG_member, name: "m", scope: !362, file: !117, line: 61, baseType: !52, size: 64, offset: 128)
!405 = !DIDerivedType(tag: DW_TAG_member, name: "transposed", scope: !362, file: !117, line: 62, baseType: !92, size: 8, offset: 192)
!406 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !362, file: !117, line: 63, baseType: !49, size: 64, offset: 256)
!407 = !DIDerivedType(tag: DW_TAG_member, name: "D", scope: !362, file: !117, line: 64, baseType: !166, size: 64, offset: 320)
!408 = !DISubprogram(name: "graph", scope: !362, file: !117, line: 66, type: !409, scopeLine: 66, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!409 = !DISubroutineType(types: !410)
!410 = !{null, !411, !365, !52, !52, !166}
!411 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !362, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!412 = !DISubprogram(name: "graph", scope: !362, file: !117, line: 69, type: !413, scopeLine: 69, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!413 = !DISubroutineType(types: !414)
!414 = !{null, !411, !365, !52, !52, !166, !49}
!415 = !DISubprogram(name: "del", linkageName: "_ZN5graphI26compressedAsymmetricVertexE3delEv", scope: !362, file: !117, line: 72, type: !416, scopeLine: 72, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!416 = !DISubroutineType(types: !417)
!417 = !{null, !411}
!418 = !DISubprogram(name: "transpose", linkageName: "_ZN5graphI26compressedAsymmetricVertexE9transposeEv", scope: !362, file: !117, line: 78, type: !416, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!419 = !{!420}
!420 = !DITemplateTypeParameter(name: "vertex", type: !366)
!421 = !DISubprogram(name: "Compute<compressedAsymmetricVertex>", linkageName: "_Z7ComputeI26compressedAsymmetricVertexEvR5graphIT_E11commandLine", scope: !192, file: !192, line: 467, type: !422, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !419, retainedNodes: !45)
!422 = !DISubroutineType(types: !423)
!423 = !{null, !424, !196}
!424 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !362, size: 64)
!425 = !DISubprogram(name: "readGraph<symmetricVertex>", linkageName: "_Z9readGraphI15symmetricVertexE5graphIT_EPcbbbb", scope: !113, file: !113, line: 470, type: !426, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !493, retainedNodes: !45)
!426 = !DISubroutineType(types: !427)
!427 = !{!428, !81, !92, !92, !92, !92}
!428 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "graph<symmetricVertex>", file: !117, line: 58, size: 384, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !429, templateParams: !493, identifier: "_ZTS5graphI15symmetricVertexE")
!429 = !{!430, !477, !478, !479, !480, !481, !482, !486, !489, !492}
!430 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !428, file: !117, line: 59, baseType: !431, size: 64)
!431 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !432, size: 64)
!432 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "symmetricVertex", file: !433, line: 188, size: 128, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !434, identifier: "_ZTS15symmetricVertex")
!433 = !DIFile(filename: "./vertex.h", directory: "/data/compilers/tests/ligra/apps")
!434 = !{!435, !436, !437, !441, !444, !447, !454, !455, !456, !459, !460, !463, !464, !467, !468, !471, !472, !475, !476}
!435 = !DIDerivedType(tag: DW_TAG_member, name: "neighbors", scope: !432, file: !433, line: 190, baseType: !49, size: 64)
!436 = !DIDerivedType(tag: DW_TAG_member, name: "degree", scope: !432, file: !433, line: 194, baseType: !126, size: 32, offset: 64)
!437 = !DISubprogram(name: "del", linkageName: "_ZN15symmetricVertex3delEv", scope: !432, file: !433, line: 195, type: !438, scopeLine: 195, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!438 = !DISubroutineType(types: !439)
!439 = !{null, !440}
!440 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !432, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!441 = !DISubprogram(name: "symmetricVertex", scope: !432, file: !433, line: 197, type: !442, scopeLine: 197, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!442 = !DISubroutineType(types: !443)
!443 = !{null, !440, !49, !126}
!444 = !DISubprogram(name: "getInNeighbors", linkageName: "_ZN15symmetricVertex14getInNeighborsEv", scope: !432, file: !433, line: 203, type: !445, scopeLine: 203, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!445 = !DISubroutineType(types: !446)
!446 = !{!49, !440}
!447 = !DISubprogram(name: "getInNeighbors", linkageName: "_ZNK15symmetricVertex14getInNeighborsEv", scope: !432, file: !433, line: 204, type: !448, scopeLine: 204, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!448 = !DISubroutineType(types: !449)
!449 = !{!450, !452}
!450 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !451, size: 64)
!451 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !50)
!452 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !453, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!453 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !432)
!454 = !DISubprogram(name: "getOutNeighbors", linkageName: "_ZN15symmetricVertex15getOutNeighborsEv", scope: !432, file: !433, line: 205, type: !445, scopeLine: 205, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!455 = !DISubprogram(name: "getOutNeighbors", linkageName: "_ZNK15symmetricVertex15getOutNeighborsEv", scope: !432, file: !433, line: 206, type: !448, scopeLine: 206, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!456 = !DISubprogram(name: "getInNeighbor", linkageName: "_ZNK15symmetricVertex13getInNeighborEj", scope: !432, file: !433, line: 207, type: !457, scopeLine: 207, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!457 = !DISubroutineType(types: !458)
!458 = !{!50, !452, !126}
!459 = !DISubprogram(name: "getOutNeighbor", linkageName: "_ZNK15symmetricVertex14getOutNeighborEj", scope: !432, file: !433, line: 208, type: !457, scopeLine: 208, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!460 = !DISubprogram(name: "setInNeighbor", linkageName: "_ZN15symmetricVertex13setInNeighborEjj", scope: !432, file: !433, line: 210, type: !461, scopeLine: 210, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!461 = !DISubroutineType(types: !462)
!462 = !{null, !440, !126, !50}
!463 = !DISubprogram(name: "setOutNeighbor", linkageName: "_ZN15symmetricVertex14setOutNeighborEjj", scope: !432, file: !433, line: 211, type: !461, scopeLine: 211, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!464 = !DISubprogram(name: "setInNeighbors", linkageName: "_ZN15symmetricVertex14setInNeighborsEPj", scope: !432, file: !433, line: 212, type: !465, scopeLine: 212, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!465 = !DISubroutineType(types: !466)
!466 = !{null, !440, !49}
!467 = !DISubprogram(name: "setOutNeighbors", linkageName: "_ZN15symmetricVertex15setOutNeighborsEPj", scope: !432, file: !433, line: 213, type: !465, scopeLine: 213, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!468 = !DISubprogram(name: "getInDegree", linkageName: "_ZNK15symmetricVertex11getInDegreeEv", scope: !432, file: !433, line: 233, type: !469, scopeLine: 233, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!469 = !DISubroutineType(types: !470)
!470 = !{!126, !452}
!471 = !DISubprogram(name: "getOutDegree", linkageName: "_ZNK15symmetricVertex12getOutDegreeEv", scope: !432, file: !433, line: 234, type: !469, scopeLine: 234, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!472 = !DISubprogram(name: "setInDegree", linkageName: "_ZN15symmetricVertex11setInDegreeEj", scope: !432, file: !433, line: 235, type: !473, scopeLine: 235, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!473 = !DISubroutineType(types: !474)
!474 = !{null, !440, !126}
!475 = !DISubprogram(name: "setOutDegree", linkageName: "_ZN15symmetricVertex12setOutDegreeEj", scope: !432, file: !433, line: 236, type: !473, scopeLine: 236, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!476 = !DISubprogram(name: "flipEdges", linkageName: "_ZN15symmetricVertex9flipEdgesEv", scope: !432, file: !433, line: 237, type: !438, scopeLine: 237, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!477 = !DIDerivedType(tag: DW_TAG_member, name: "n", scope: !428, file: !117, line: 60, baseType: !52, size: 64, offset: 64)
!478 = !DIDerivedType(tag: DW_TAG_member, name: "m", scope: !428, file: !117, line: 61, baseType: !52, size: 64, offset: 128)
!479 = !DIDerivedType(tag: DW_TAG_member, name: "transposed", scope: !428, file: !117, line: 62, baseType: !92, size: 8, offset: 192)
!480 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !428, file: !117, line: 63, baseType: !49, size: 64, offset: 256)
!481 = !DIDerivedType(tag: DW_TAG_member, name: "D", scope: !428, file: !117, line: 64, baseType: !166, size: 64, offset: 320)
!482 = !DISubprogram(name: "graph", scope: !428, file: !117, line: 66, type: !483, scopeLine: 66, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!483 = !DISubroutineType(types: !484)
!484 = !{null, !485, !431, !52, !52, !166}
!485 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !428, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!486 = !DISubprogram(name: "graph", scope: !428, file: !117, line: 69, type: !487, scopeLine: 69, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!487 = !DISubroutineType(types: !488)
!488 = !{null, !485, !431, !52, !52, !166, !49}
!489 = !DISubprogram(name: "del", linkageName: "_ZN5graphI15symmetricVertexE3delEv", scope: !428, file: !117, line: 72, type: !490, scopeLine: 72, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!490 = !DISubroutineType(types: !491)
!491 = !{null, !485}
!492 = !DISubprogram(name: "transpose", linkageName: "_ZN5graphI15symmetricVertexE9transposeEv", scope: !428, file: !117, line: 78, type: !490, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!493 = !{!494}
!494 = !DITemplateTypeParameter(name: "vertex", type: !432)
!495 = !DISubprogram(name: "Compute<symmetricVertex>", linkageName: "_Z7ComputeI15symmetricVertexEvR5graphIT_E11commandLine", scope: !192, file: !192, line: 467, type: !496, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !493, retainedNodes: !45)
!496 = !DISubroutineType(types: !497)
!497 = !{null, !498, !196}
!498 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !428, size: 64)
!499 = !DISubprogram(name: "readGraph<asymmetricVertex>", linkageName: "_Z9readGraphI16asymmetricVertexE5graphIT_EPcbbbb", scope: !113, file: !113, line: 470, type: !500, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !566, retainedNodes: !45)
!500 = !DISubroutineType(types: !501)
!501 = !{!502, !81, !92, !92, !92, !92}
!502 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "graph<asymmetricVertex>", file: !117, line: 58, size: 384, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !503, templateParams: !566, identifier: "_ZTS5graphI16asymmetricVertexE")
!503 = !{!504, !550, !551, !552, !553, !554, !555, !559, !562, !565}
!504 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !502, file: !117, line: 59, baseType: !505, size: 64)
!505 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !506, size: 64)
!506 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "asymmetricVertex", file: !433, line: 276, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !507, identifier: "_ZTS16asymmetricVertex")
!507 = !{!508, !509, !510, !511, !512, !516, !519, !522, !527, !528, !529, !532, !533, !536, !537, !540, !541, !544, !545, !548, !549}
!508 = !DIDerivedType(tag: DW_TAG_member, name: "inNeighbors", scope: !506, file: !433, line: 278, baseType: !49, size: 64)
!509 = !DIDerivedType(tag: DW_TAG_member, name: "outNeighbors", scope: !506, file: !433, line: 278, baseType: !49, size: 64, offset: 64)
!510 = !DIDerivedType(tag: DW_TAG_member, name: "outDegree", scope: !506, file: !433, line: 282, baseType: !126, size: 32, offset: 128)
!511 = !DIDerivedType(tag: DW_TAG_member, name: "inDegree", scope: !506, file: !433, line: 283, baseType: !126, size: 32, offset: 160)
!512 = !DISubprogram(name: "del", linkageName: "_ZN16asymmetricVertex3delEv", scope: !506, file: !433, line: 284, type: !513, scopeLine: 284, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!513 = !DISubroutineType(types: !514)
!514 = !{null, !515}
!515 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !506, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!516 = !DISubprogram(name: "asymmetricVertex", scope: !506, file: !433, line: 286, type: !517, scopeLine: 286, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!517 = !DISubroutineType(types: !518)
!518 = !{null, !515, !49, !49, !126, !126}
!519 = !DISubprogram(name: "getInNeighbors", linkageName: "_ZN16asymmetricVertex14getInNeighborsEv", scope: !506, file: !433, line: 292, type: !520, scopeLine: 292, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!520 = !DISubroutineType(types: !521)
!521 = !{!49, !515}
!522 = !DISubprogram(name: "getInNeighbors", linkageName: "_ZNK16asymmetricVertex14getInNeighborsEv", scope: !506, file: !433, line: 293, type: !523, scopeLine: 293, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!523 = !DISubroutineType(types: !524)
!524 = !{!450, !525}
!525 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !526, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!526 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !506)
!527 = !DISubprogram(name: "getOutNeighbors", linkageName: "_ZN16asymmetricVertex15getOutNeighborsEv", scope: !506, file: !433, line: 294, type: !520, scopeLine: 294, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!528 = !DISubprogram(name: "getOutNeighbors", linkageName: "_ZNK16asymmetricVertex15getOutNeighborsEv", scope: !506, file: !433, line: 295, type: !523, scopeLine: 295, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!529 = !DISubprogram(name: "getInNeighbor", linkageName: "_ZNK16asymmetricVertex13getInNeighborEj", scope: !506, file: !433, line: 296, type: !530, scopeLine: 296, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!530 = !DISubroutineType(types: !531)
!531 = !{!50, !525, !126}
!532 = !DISubprogram(name: "getOutNeighbor", linkageName: "_ZNK16asymmetricVertex14getOutNeighborEj", scope: !506, file: !433, line: 297, type: !530, scopeLine: 297, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!533 = !DISubprogram(name: "setInNeighbor", linkageName: "_ZN16asymmetricVertex13setInNeighborEjj", scope: !506, file: !433, line: 298, type: !534, scopeLine: 298, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!534 = !DISubroutineType(types: !535)
!535 = !{null, !515, !126, !50}
!536 = !DISubprogram(name: "setOutNeighbor", linkageName: "_ZN16asymmetricVertex14setOutNeighborEjj", scope: !506, file: !433, line: 299, type: !534, scopeLine: 299, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!537 = !DISubprogram(name: "setInNeighbors", linkageName: "_ZN16asymmetricVertex14setInNeighborsEPj", scope: !506, file: !433, line: 300, type: !538, scopeLine: 300, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!538 = !DISubroutineType(types: !539)
!539 = !{null, !515, !49}
!540 = !DISubprogram(name: "setOutNeighbors", linkageName: "_ZN16asymmetricVertex15setOutNeighborsEPj", scope: !506, file: !433, line: 301, type: !538, scopeLine: 301, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!541 = !DISubprogram(name: "getInDegree", linkageName: "_ZNK16asymmetricVertex11getInDegreeEv", scope: !506, file: !433, line: 319, type: !542, scopeLine: 319, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!542 = !DISubroutineType(types: !543)
!543 = !{!126, !525}
!544 = !DISubprogram(name: "getOutDegree", linkageName: "_ZNK16asymmetricVertex12getOutDegreeEv", scope: !506, file: !433, line: 320, type: !542, scopeLine: 320, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!545 = !DISubprogram(name: "setInDegree", linkageName: "_ZN16asymmetricVertex11setInDegreeEj", scope: !506, file: !433, line: 321, type: !546, scopeLine: 321, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!546 = !DISubroutineType(types: !547)
!547 = !{null, !515, !126}
!548 = !DISubprogram(name: "setOutDegree", linkageName: "_ZN16asymmetricVertex12setOutDegreeEj", scope: !506, file: !433, line: 322, type: !546, scopeLine: 322, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!549 = !DISubprogram(name: "flipEdges", linkageName: "_ZN16asymmetricVertex9flipEdgesEv", scope: !506, file: !433, line: 323, type: !513, scopeLine: 323, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!550 = !DIDerivedType(tag: DW_TAG_member, name: "n", scope: !502, file: !117, line: 60, baseType: !52, size: 64, offset: 64)
!551 = !DIDerivedType(tag: DW_TAG_member, name: "m", scope: !502, file: !117, line: 61, baseType: !52, size: 64, offset: 128)
!552 = !DIDerivedType(tag: DW_TAG_member, name: "transposed", scope: !502, file: !117, line: 62, baseType: !92, size: 8, offset: 192)
!553 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !502, file: !117, line: 63, baseType: !49, size: 64, offset: 256)
!554 = !DIDerivedType(tag: DW_TAG_member, name: "D", scope: !502, file: !117, line: 64, baseType: !166, size: 64, offset: 320)
!555 = !DISubprogram(name: "graph", scope: !502, file: !117, line: 66, type: !556, scopeLine: 66, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!556 = !DISubroutineType(types: !557)
!557 = !{null, !558, !505, !52, !52, !166}
!558 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !502, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!559 = !DISubprogram(name: "graph", scope: !502, file: !117, line: 69, type: !560, scopeLine: 69, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!560 = !DISubroutineType(types: !561)
!561 = !{null, !558, !505, !52, !52, !166, !49}
!562 = !DISubprogram(name: "del", linkageName: "_ZN5graphI16asymmetricVertexE3delEv", scope: !502, file: !117, line: 72, type: !563, scopeLine: 72, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!563 = !DISubroutineType(types: !564)
!564 = !{null, !558}
!565 = !DISubprogram(name: "transpose", linkageName: "_ZN5graphI16asymmetricVertexE9transposeEv", scope: !502, file: !117, line: 78, type: !563, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!566 = !{!567}
!567 = !DITemplateTypeParameter(name: "vertex", type: !506)
!568 = !DISubprogram(name: "Compute<asymmetricVertex>", linkageName: "_Z7ComputeI16asymmetricVertexEvR5graphIT_E11commandLine", scope: !192, file: !192, line: 467, type: !569, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !566, retainedNodes: !45)
!569 = !DISubroutineType(types: !570)
!570 = !{null, !571, !196}
!571 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !502, size: 64)
!572 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_type", scope: !26, file: !25, line: 88, baseType: !573)
!573 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_type", scope: !575, file: !574, line: 59, baseType: !605)
!574 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/ext/alloc_traits.h", directory: "")
!575 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "__alloc_traits<std::allocator<char>, char>", scope: !576, file: !574, line: 48, size: 8, flags: DIFlagTypePassByValue, elements: !577, templateParams: !629, identifier: "_ZTSN9__gnu_cxx14__alloc_traitsISaIcEcEE")
!576 = !DINamespace(name: "__gnu_cxx", scope: null)
!577 = !{!578, !613, !618, !622, !625, !626, !627, !628}
!578 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !575, baseType: !579, extraData: i32 0)
!579 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "allocator_traits<std::allocator<char> >", scope: !5, file: !580, line: 407, size: 8, flags: DIFlagTypePassByValue, elements: !581, templateParams: !611, identifier: "_ZTSSt16allocator_traitsISaIcEE")
!580 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/alloc_traits.h", directory: "")
!581 = !{!582, !593, !599, !602, !608}
!582 = !DISubprogram(name: "allocate", linkageName: "_ZNSt16allocator_traitsISaIcEE8allocateERS0_m", scope: !579, file: !580, line: 459, type: !583, scopeLine: 459, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!583 = !DISubroutineType(types: !584)
!584 = !{!585, !586, !590}
!585 = !DIDerivedType(tag: DW_TAG_typedef, name: "pointer", scope: !579, file: !580, line: 416, baseType: !81)
!586 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !587, size: 64)
!587 = !DIDerivedType(tag: DW_TAG_typedef, name: "allocator_type", scope: !579, file: !580, line: 410, baseType: !588)
!588 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "allocator<char>", scope: !5, file: !589, line: 249, flags: DIFlagFwdDecl, identifier: "_ZTSSaIcE")
!589 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/allocator.h", directory: "")
!590 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_type", file: !580, line: 431, baseType: !591)
!591 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", scope: !5, file: !592, line: 2363, baseType: !86)
!592 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/x86_64-redhat-linux/bits/c++config.h", directory: "")
!593 = !DISubprogram(name: "allocate", linkageName: "_ZNSt16allocator_traitsISaIcEE8allocateERS0_mPKv", scope: !579, file: !580, line: 473, type: !594, scopeLine: 473, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!594 = !DISubroutineType(types: !595)
!595 = !{!585, !586, !590, !596}
!596 = !DIDerivedType(tag: DW_TAG_typedef, name: "const_void_pointer", file: !580, line: 425, baseType: !597)
!597 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !598, size: 64)
!598 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!599 = !DISubprogram(name: "deallocate", linkageName: "_ZNSt16allocator_traitsISaIcEE10deallocateERS0_Pcm", scope: !579, file: !580, line: 491, type: !600, scopeLine: 491, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!600 = !DISubroutineType(types: !601)
!601 = !{null, !586, !585, !590}
!602 = !DISubprogram(name: "max_size", linkageName: "_ZNSt16allocator_traitsISaIcEE8max_sizeERKS0_", scope: !579, file: !580, line: 543, type: !603, scopeLine: 543, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!603 = !DISubroutineType(types: !604)
!604 = !{!605, !606}
!605 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_type", scope: !579, file: !580, line: 431, baseType: !591)
!606 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !607, size: 64)
!607 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !587)
!608 = !DISubprogram(name: "select_on_container_copy_construction", linkageName: "_ZNSt16allocator_traitsISaIcEE37select_on_container_copy_constructionERKS0_", scope: !579, file: !580, line: 558, type: !609, scopeLine: 558, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!609 = !DISubroutineType(types: !610)
!610 = !{!587, !606}
!611 = !{!612}
!612 = !DITemplateTypeParameter(name: "_Alloc", type: !588)
!613 = !DISubprogram(name: "_S_select_on_copy", linkageName: "_ZN9__gnu_cxx14__alloc_traitsISaIcEcE17_S_select_on_copyERKS1_", scope: !575, file: !574, line: 97, type: !614, scopeLine: 97, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!614 = !DISubroutineType(types: !615)
!615 = !{!588, !616}
!616 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !617, size: 64)
!617 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !588)
!618 = !DISubprogram(name: "_S_on_swap", linkageName: "_ZN9__gnu_cxx14__alloc_traitsISaIcEcE10_S_on_swapERS1_S3_", scope: !575, file: !574, line: 100, type: !619, scopeLine: 100, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!619 = !DISubroutineType(types: !620)
!620 = !{null, !621, !621}
!621 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !588, size: 64)
!622 = !DISubprogram(name: "_S_propagate_on_copy_assign", linkageName: "_ZN9__gnu_cxx14__alloc_traitsISaIcEcE27_S_propagate_on_copy_assignEv", scope: !575, file: !574, line: 103, type: !623, scopeLine: 103, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!623 = !DISubroutineType(types: !624)
!624 = !{!92}
!625 = !DISubprogram(name: "_S_propagate_on_move_assign", linkageName: "_ZN9__gnu_cxx14__alloc_traitsISaIcEcE27_S_propagate_on_move_assignEv", scope: !575, file: !574, line: 106, type: !623, scopeLine: 106, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!626 = !DISubprogram(name: "_S_propagate_on_swap", linkageName: "_ZN9__gnu_cxx14__alloc_traitsISaIcEcE20_S_propagate_on_swapEv", scope: !575, file: !574, line: 109, type: !623, scopeLine: 109, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!627 = !DISubprogram(name: "_S_always_equal", linkageName: "_ZN9__gnu_cxx14__alloc_traitsISaIcEcE15_S_always_equalEv", scope: !575, file: !574, line: 112, type: !623, scopeLine: 112, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!628 = !DISubprogram(name: "_S_nothrow_move", linkageName: "_ZN9__gnu_cxx14__alloc_traitsISaIcEcE15_S_nothrow_moveEv", scope: !575, file: !574, line: 115, type: !623, scopeLine: 115, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!629 = !{!612, !630}
!630 = !DITemplateTypeParameter(type: !76)
!631 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !632, size: 64)
!632 = !DIDerivedType(tag: DW_TAG_typedef, name: "char_type", scope: !634, file: !633, line: 318, baseType: !76)
!633 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/char_traits.h", directory: "")
!634 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "char_traits<char>", scope: !5, file: !633, line: 316, size: 8, flags: DIFlagTypePassByValue, elements: !635, templateParams: !681, identifier: "_ZTSSt11char_traitsIcE")
!635 = !{!636, !642, !645, !646, !650, !653, !656, !659, !660, !663, !669, !672, !675, !678}
!636 = !DISubprogram(name: "assign", linkageName: "_ZNSt11char_traitsIcE6assignERcRKc", scope: !634, file: !633, line: 328, type: !637, scopeLine: 328, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!637 = !DISubroutineType(types: !638)
!638 = !{null, !639, !640}
!639 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !632, size: 64)
!640 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !641, size: 64)
!641 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !632)
!642 = !DISubprogram(name: "eq", linkageName: "_ZNSt11char_traitsIcE2eqERKcS2_", scope: !634, file: !633, line: 332, type: !643, scopeLine: 332, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!643 = !DISubroutineType(types: !644)
!644 = !{!92, !640, !640}
!645 = !DISubprogram(name: "lt", linkageName: "_ZNSt11char_traitsIcE2ltERKcS2_", scope: !634, file: !633, line: 336, type: !643, scopeLine: 336, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!646 = !DISubprogram(name: "compare", linkageName: "_ZNSt11char_traitsIcE7compareEPKcS2_m", scope: !634, file: !633, line: 344, type: !647, scopeLine: 344, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!647 = !DISubroutineType(types: !648)
!648 = !{!6, !649, !649, !591}
!649 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !641, size: 64)
!650 = !DISubprogram(name: "length", linkageName: "_ZNSt11char_traitsIcE6lengthEPKc", scope: !634, file: !633, line: 358, type: !651, scopeLine: 358, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!651 = !DISubroutineType(types: !652)
!652 = !{!591, !649}
!653 = !DISubprogram(name: "find", linkageName: "_ZNSt11char_traitsIcE4findEPKcmRS1_", scope: !634, file: !633, line: 368, type: !654, scopeLine: 368, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!654 = !DISubroutineType(types: !655)
!655 = !{!649, !649, !591, !640}
!656 = !DISubprogram(name: "move", linkageName: "_ZNSt11char_traitsIcE4moveEPcPKcm", scope: !634, file: !633, line: 382, type: !657, scopeLine: 382, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!657 = !DISubroutineType(types: !658)
!658 = !{!631, !631, !649, !591}
!659 = !DISubprogram(name: "copy", linkageName: "_ZNSt11char_traitsIcE4copyEPcPKcm", scope: !634, file: !633, line: 394, type: !657, scopeLine: 394, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!660 = !DISubprogram(name: "assign", linkageName: "_ZNSt11char_traitsIcE6assignEPcmc", scope: !634, file: !633, line: 406, type: !661, scopeLine: 406, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!661 = !DISubroutineType(types: !662)
!662 = !{!631, !631, !591, !632}
!663 = !DISubprogram(name: "to_char_type", linkageName: "_ZNSt11char_traitsIcE12to_char_typeERKi", scope: !634, file: !633, line: 418, type: !664, scopeLine: 418, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!664 = !DISubroutineType(types: !665)
!665 = !{!632, !666}
!666 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !667, size: 64)
!667 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !668)
!668 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_type", scope: !634, file: !633, line: 319, baseType: !6)
!669 = !DISubprogram(name: "to_int_type", linkageName: "_ZNSt11char_traitsIcE11to_int_typeERKc", scope: !634, file: !633, line: 424, type: !670, scopeLine: 424, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!670 = !DISubroutineType(types: !671)
!671 = !{!668, !640}
!672 = !DISubprogram(name: "eq_int_type", linkageName: "_ZNSt11char_traitsIcE11eq_int_typeERKiS2_", scope: !634, file: !633, line: 428, type: !673, scopeLine: 428, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!673 = !DISubroutineType(types: !674)
!674 = !{!92, !666, !666}
!675 = !DISubprogram(name: "eof", linkageName: "_ZNSt11char_traitsIcE3eofEv", scope: !634, file: !633, line: 432, type: !676, scopeLine: 432, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!676 = !DISubroutineType(types: !677)
!677 = !{!668}
!678 = !DISubprogram(name: "not_eof", linkageName: "_ZNSt11char_traitsIcE7not_eofERKi", scope: !634, file: !633, line: 436, type: !679, scopeLine: 436, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!679 = !DISubroutineType(types: !680)
!680 = !{!668, !666}
!681 = !{!682}
!682 = !DITemplateTypeParameter(name: "_CharT", type: !76)
!683 = !DISubprogram(name: "operator delete", linkageName: "_ZdlPv", scope: !684, file: !684, line: 130, type: !66, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!684 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/new", directory: "")
!685 = !DISubprogram(name: "gettimeofday", scope: !686, file: !686, line: 66, type: !687, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!686 = !DIFile(filename: "/usr/include/sys/time.h", directory: "")
!687 = !DISubroutineType(types: !688)
!688 = !{!6, !689, !68}
!689 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !690, size: 64)
!690 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timeval", file: !691, line: 8, size: 128, flags: DIFlagTypePassByValue, elements: !692, identifier: "_ZTS7timeval")
!691 = !DIFile(filename: "/usr/include/bits/types/struct_timeval.h", directory: "")
!692 = !{!693, !696}
!693 = !DIDerivedType(tag: DW_TAG_member, name: "tv_sec", scope: !690, file: !691, line: 10, baseType: !694, size: 64)
!694 = !DIDerivedType(tag: DW_TAG_typedef, name: "__time_t", file: !695, line: 160, baseType: !52)
!695 = !DIFile(filename: "/usr/include/bits/types.h", directory: "")
!696 = !DIDerivedType(tag: DW_TAG_member, name: "tv_usec", scope: !690, file: !691, line: 11, baseType: !697, size: 64, offset: 64)
!697 = !DIDerivedType(tag: DW_TAG_typedef, name: "__suseconds_t", file: !695, line: 162, baseType: !52)
!698 = !DIDerivedType(tag: DW_TAG_typedef, name: "streamsize", scope: !5, file: !699, line: 98, baseType: !700)
!699 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/postypes.h", directory: "")
!700 = !DIDerivedType(tag: DW_TAG_typedef, name: "ptrdiff_t", scope: !5, file: !592, line: 2364, baseType: !52)
!701 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getA<long, long>", scope: !55, file: !54, line: 98, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !702, templateParams: !58, identifier: "_ZTSN8sequence4getAIllEE")
!702 = !{!703, !704, !708}
!703 = !DIDerivedType(tag: DW_TAG_member, name: "A", scope: !701, file: !54, line: 99, baseType: !51, size: 64)
!704 = !DISubprogram(name: "getA", scope: !701, file: !54, line: 100, type: !705, scopeLine: 100, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!705 = !DISubroutineType(types: !706)
!706 = !{null, !707, !51}
!707 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !701, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!708 = !DISubprogram(name: "operator()", linkageName: "_ZN8sequence4getAIllEclEl", scope: !701, file: !54, line: 101, type: !709, scopeLine: 101, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!709 = !DISubroutineType(types: !710)
!710 = !{!52, !707, !52}
!711 = !DISubprogram(name: "scan<long, long, addF<long>, sequence::getA<long, long> >", linkageName: "_ZN8sequence4scanIll4addFIlENS_4getAIllEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 198, type: !712, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !725, retainedNodes: !45)
!712 = !DISubroutineType(types: !713)
!713 = !{!52, !51, !52, !52, !714, !701, !52, !92, !92}
!714 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "addF<long>", file: !54, line: 51, size: 8, flags: DIFlagTypePassByValue, elements: !715, templateParams: !723, identifier: "_ZTS4addFIlE")
!715 = !{!716}
!716 = !DISubprogram(name: "operator()", linkageName: "_ZNK4addFIlEclERKlS2_", scope: !714, file: !54, line: 51, type: !717, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!717 = !DISubroutineType(types: !718)
!718 = !{!52, !719, !721, !721}
!719 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !720, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!720 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !714)
!721 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !722, size: 64)
!722 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !52)
!723 = !{!724}
!724 = !DITemplateTypeParameter(name: "E", type: !52)
!725 = !{!59, !60, !726, !727}
!726 = !DITemplateTypeParameter(name: "F", type: !714)
!727 = !DITemplateTypeParameter(name: "G", type: !701)
!728 = !DISubprogram(name: "scanSerial<long, long, addF<long>, sequence::getA<long, long> >", linkageName: "_ZN8sequence10scanSerialIll4addFIlENS_4getAIllEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 169, type: !712, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !725, retainedNodes: !45)
!729 = !DISubprogram(name: "reduceSerial<long, long, addF<long>, sequence::getA<long, long> >", linkageName: "_ZN8sequence12reduceSerialIll4addFIlENS_4getAIllEEEET_T0_S6_T1_T2_", scope: !55, file: !54, line: 127, type: !730, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !732, retainedNodes: !45)
!730 = !DISubroutineType(types: !731)
!731 = !{!52, !52, !52, !714, !701}
!732 = !{!733, !60, !726, !727}
!733 = !DITemplateTypeParameter(name: "OT", type: !52)
!734 = !DISubprogram(name: "pack<long, long, identityF<long> >", linkageName: "_ZN8sequence4packIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_", scope: !55, file: !54, line: 266, type: !735, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !743, retainedNodes: !45)
!735 = !DISubroutineType(types: !736)
!736 = !{!96, !51, !91, !52, !52, !737}
!737 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "identityF<long>", file: !54, line: 48, size: 8, flags: DIFlagTypePassByValue, elements: !738, templateParams: !723, identifier: "_ZTS9identityFIlE")
!738 = !{!739}
!739 = !DISubprogram(name: "operator()", linkageName: "_ZN9identityFIlEclERKl", scope: !737, file: !54, line: 48, type: !740, scopeLine: 48, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!740 = !DISubroutineType(types: !741)
!741 = !{!52, !742, !721}
!742 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !737, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!743 = !{!59, !60, !744}
!744 = !DITemplateTypeParameter(name: "F", type: !737)
!745 = !DISubprogram(name: "packSerial<long, long, identityF<long> >", linkageName: "_ZN8sequence10packSerialIll9identityFIlEEE4_seqIT_EPS4_PbT0_S8_T1_", scope: !55, file: !54, line: 255, type: !735, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !743, retainedNodes: !45)
!746 = !DISubprogram(name: "sumFlagsSerial<long>", linkageName: "_ZN8sequence14sumFlagsSerialIlEET_PbS1_", scope: !55, file: !54, line: 240, type: !747, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !110, retainedNodes: !45)
!747 = !DISubroutineType(types: !748)
!748 = !{!52, !91, !52}
!749 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !6, size: 64)
!750 = !DISubprogram(name: "munmap", scope: !83, file: !83, line: 76, type: !751, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!751 = !DISubroutineType(types: !752)
!752 = !{!6, !68, !86}
!753 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !126, size: 64)
!754 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "BFS_F", file: !1, line: 26, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !755, identifier: "_ZTS5BFS_F")
!755 = !{!756, !757, !761, !764, !765}
!756 = !DIDerivedType(tag: DW_TAG_member, name: "Parents", scope: !754, file: !1, line: 27, baseType: !49, size: 64)
!757 = !DISubprogram(name: "BFS_F", scope: !754, file: !1, line: 28, type: !758, scopeLine: 28, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!758 = !DISubroutineType(types: !759)
!759 = !{null, !760, !49}
!760 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !754, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!761 = !DISubprogram(name: "update", linkageName: "_ZN5BFS_F6updateEjj", scope: !754, file: !1, line: 29, type: !762, scopeLine: 29, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!762 = !DISubroutineType(types: !763)
!763 = !{!92, !760, !50, !50}
!764 = !DISubprogram(name: "updateAtomic", linkageName: "_ZN5BFS_F12updateAtomicEjj", scope: !754, file: !1, line: 33, type: !762, scopeLine: 33, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!765 = !DISubprogram(name: "cond", linkageName: "_ZN5BFS_F4condEj", scope: !754, file: !1, line: 37, type: !766, scopeLine: 37, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!766 = !DISubroutineType(types: !767)
!767 = !{!92, !760, !50}
!768 = !DISubprogram(name: "edgeMap<compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z7edgeMapI25compressedSymmetricVertex16vertexSubsetDataIN4pbbs5emptyEE5BFS_FES4_5graphIT_ERT0_T1_iRKj", scope: !192, file: !192, line: 280, type: !769, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1165, retainedNodes: !45)
!769 = !DISubroutineType(types: !770)
!770 = !{!771, !116, !1164, !754, !6, !907}
!771 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "vertexSubsetData<pbbs::empty>", file: !772, line: 113, size: 320, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !773, templateParams: !1162, identifier: "_ZTS16vertexSubsetDataIN4pbbs5emptyEE")
!772 = !DIFile(filename: "./vertexSubset.h", directory: "/data/compilers/tests/ligra/apps")
!773 = !{!774, !777, !778, !781, !782, !783, !787, !790, !793, !1006, !1009, !1012, !1130, !1133, !1140, !1143, !1146, !1149, !1150, !1153, !1154, !1155, !1156, !1159, !1160, !1161}
!774 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !771, file: !772, line: 223, baseType: !775, size: 64)
!775 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !776, size: 64)
!776 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !771, file: !772, line: 114, baseType: !50)
!777 = !DIDerivedType(tag: DW_TAG_member, name: "d", scope: !771, file: !772, line: 224, baseType: !91, size: 64, offset: 64)
!778 = !DIDerivedType(tag: DW_TAG_member, name: "n", scope: !771, file: !772, line: 225, baseType: !779, size: 64, offset: 128)
!779 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !780, line: 46, baseType: !86)
!780 = !DIFile(filename: "animals/opencilk/build-test/lib/clang/10.0.1/include/stddef.h", directory: "/data")
!781 = !DIDerivedType(tag: DW_TAG_member, name: "m", scope: !771, file: !772, line: 225, baseType: !779, size: 64, offset: 192)
!782 = !DIDerivedType(tag: DW_TAG_member, name: "isDense", scope: !771, file: !772, line: 226, baseType: !92, size: 8, offset: 256)
!783 = !DISubprogram(name: "vertexSubsetData", scope: !771, file: !772, line: 117, type: !784, scopeLine: 117, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!784 = !DISubroutineType(types: !785)
!785 = !{null, !786, !779}
!786 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !771, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!787 = !DISubprogram(name: "vertexSubsetData", scope: !771, file: !772, line: 120, type: !788, scopeLine: 120, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!788 = !DISubroutineType(types: !789)
!789 = !{null, !786, !52, !50}
!790 = !DISubprogram(name: "vertexSubsetData", scope: !771, file: !772, line: 127, type: !791, scopeLine: 127, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!791 = !DISubroutineType(types: !792)
!792 = !{null, !786, !52, !52, !775}
!793 = !DISubprogram(name: "vertexSubsetData", scope: !771, file: !772, line: 131, type: !794, scopeLine: 131, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!794 = !DISubroutineType(types: !795)
!795 = !{null, !786, !52, !52, !796}
!796 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !797, size: 64)
!797 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "tuple<unsigned int, pbbs::empty>", scope: !5, file: !798, line: 887, size: 32, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !799, templateParams: !1005, identifier: "_ZTSSt5tupleIJjN4pbbs5emptyEEE")
!798 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/tuple", directory: "")
!799 = !{!800, !976, !977, !983, !987, !995, !1002}
!800 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !797, baseType: !801, flags: DIFlagPublic, extraData: i32 0)
!801 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Tuple_impl<0, unsigned int, pbbs::empty>", scope: !5, file: !798, line: 191, size: 32, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !802, templateParams: !972, identifier: "_ZTSSt11_Tuple_implILm0EJjN4pbbs5emptyEEE")
!802 = !{!803, !896, !933, !937, !942, !947, !952, !956, !959, !962, !965, !969}
!803 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !801, baseType: !804, extraData: i32 0)
!804 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Tuple_impl<1, pbbs::empty>", scope: !5, file: !798, line: 341, size: 8, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !805, templateParams: !892, identifier: "_ZTSSt11_Tuple_implILm1EJN4pbbs5emptyEEE")
!805 = !{!806, !863, !867, !872, !876, !879, !882, !885, !889}
!806 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !804, baseType: !807, flags: DIFlagPrivate, extraData: i32 0)
!807 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Head_base<1, pbbs::empty, true>", scope: !5, file: !798, line: 77, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !808, templateParams: !859, identifier: "_ZTSSt10_Head_baseILm1EN4pbbs5emptyELb1EE")
!808 = !{!809, !812, !816, !821, !826, !830, !851, !856}
!809 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !807, baseType: !810, extraData: i32 0)
!810 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "empty", scope: !811, file: !54, line: 393, size: 8, flags: DIFlagTypePassByValue, elements: !45, identifier: "_ZTSN4pbbs5emptyE")
!811 = !DINamespace(name: "pbbs", scope: null)
!812 = !DISubprogram(name: "_Head_base", scope: !807, file: !798, line: 80, type: !813, scopeLine: 80, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!813 = !DISubroutineType(types: !814)
!814 = !{null, !815}
!815 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !807, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!816 = !DISubprogram(name: "_Head_base", scope: !807, file: !798, line: 83, type: !817, scopeLine: 83, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!817 = !DISubroutineType(types: !818)
!818 = !{null, !815, !819}
!819 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !820, size: 64)
!820 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !810)
!821 = !DISubprogram(name: "_Head_base", scope: !807, file: !798, line: 86, type: !822, scopeLine: 86, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!822 = !DISubroutineType(types: !823)
!823 = !{null, !815, !824}
!824 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !825, size: 64)
!825 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !807)
!826 = !DISubprogram(name: "_Head_base", scope: !807, file: !798, line: 87, type: !827, scopeLine: 87, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!827 = !DISubroutineType(types: !828)
!828 = !{null, !815, !829}
!829 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !807, size: 64)
!830 = !DISubprogram(name: "_Head_base", scope: !807, file: !798, line: 93, type: !831, scopeLine: 93, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!831 = !DISubroutineType(types: !832)
!832 = !{null, !815, !833, !840}
!833 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "allocator_arg_t", scope: !5, file: !834, line: 50, size: 8, flags: DIFlagTypePassByValue, elements: !835, identifier: "_ZTSSt15allocator_arg_t")
!834 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/uses_allocator.h", directory: "")
!835 = !{!836}
!836 = !DISubprogram(name: "allocator_arg_t", scope: !833, file: !834, line: 50, type: !837, scopeLine: 50, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!837 = !DISubroutineType(types: !838)
!838 = !{null, !839}
!839 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !833, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!840 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "__uses_alloc0", scope: !5, file: !834, line: 73, size: 8, flags: DIFlagTypePassByValue, elements: !841, identifier: "_ZTSSt13__uses_alloc0")
!841 = !{!842, !844}
!842 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !840, baseType: !843, extraData: i32 0)
!843 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "__uses_alloc_base", scope: !5, file: !834, line: 71, size: 8, flags: DIFlagTypePassByValue, elements: !45, identifier: "_ZTSSt17__uses_alloc_base")
!844 = !DIDerivedType(tag: DW_TAG_member, name: "_M_a", scope: !840, file: !834, line: 75, baseType: !845, size: 8)
!845 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Sink", scope: !840, file: !834, line: 75, size: 8, flags: DIFlagTypePassByValue, elements: !846, identifier: "_ZTSNSt13__uses_alloc05_SinkE")
!846 = !{!847}
!847 = !DISubprogram(name: "operator=", linkageName: "_ZNSt13__uses_alloc05_SinkaSEPKv", scope: !845, file: !834, line: 75, type: !848, scopeLine: 75, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!848 = !DISubroutineType(types: !849)
!849 = !{null, !850, !597}
!850 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !845, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!851 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm1EN4pbbs5emptyELb1EE7_M_headERS2_", scope: !807, file: !798, line: 117, type: !852, scopeLine: 117, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!852 = !DISubroutineType(types: !853)
!853 = !{!854, !855}
!854 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !810, size: 64)
!855 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !807, size: 64)
!856 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm1EN4pbbs5emptyELb1EE7_M_headERKS2_", scope: !807, file: !798, line: 120, type: !857, scopeLine: 120, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!857 = !DISubroutineType(types: !858)
!858 = !{!819, !824}
!859 = !{!860, !861, !862}
!860 = !DITemplateValueParameter(name: "_Idx", type: !86, value: i64 1)
!861 = !DITemplateTypeParameter(name: "_Head", type: !810)
!862 = !DITemplateValueParameter(type: !92, value: i8 1)
!863 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm1EJN4pbbs5emptyEEE7_M_headERS2_", scope: !804, file: !798, line: 349, type: !864, scopeLine: 349, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!864 = !DISubroutineType(types: !865)
!865 = !{!854, !866}
!866 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !804, size: 64)
!867 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm1EJN4pbbs5emptyEEE7_M_headERKS2_", scope: !804, file: !798, line: 352, type: !868, scopeLine: 352, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!868 = !DISubroutineType(types: !869)
!869 = !{!819, !870}
!870 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !871, size: 64)
!871 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !804)
!872 = !DISubprogram(name: "_Tuple_impl", scope: !804, file: !798, line: 354, type: !873, scopeLine: 354, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!873 = !DISubroutineType(types: !874)
!874 = !{null, !875}
!875 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !804, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!876 = !DISubprogram(name: "_Tuple_impl", scope: !804, file: !798, line: 358, type: !877, scopeLine: 358, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!877 = !DISubroutineType(types: !878)
!878 = !{null, !875, !819}
!879 = !DISubprogram(name: "_Tuple_impl", scope: !804, file: !798, line: 366, type: !880, scopeLine: 366, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!880 = !DISubroutineType(types: !881)
!881 = !{null, !875, !870}
!882 = !DISubprogram(name: "operator=", linkageName: "_ZNSt11_Tuple_implILm1EJN4pbbs5emptyEEEaSERKS2_", scope: !804, file: !798, line: 370, type: !883, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized | DISPFlagDeleted)
!883 = !DISubroutineType(types: !884)
!884 = !{!866, !875, !870}
!885 = !DISubprogram(name: "_Tuple_impl", scope: !804, file: !798, line: 373, type: !886, scopeLine: 373, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!886 = !DISubroutineType(types: !887)
!887 = !{null, !875, !888}
!888 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !804, size: 64)
!889 = !DISubprogram(name: "_M_swap", linkageName: "_ZNSt11_Tuple_implILm1EJN4pbbs5emptyEEE7_M_swapERS2_", scope: !804, file: !798, line: 451, type: !890, scopeLine: 451, flags: DIFlagProtected | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!890 = !DISubroutineType(types: !891)
!891 = !{null, !875, !866}
!892 = !{!860, !893}
!893 = !DITemplateValueParameter(tag: DW_TAG_GNU_template_parameter_pack, name: "_Elements", value: !894)
!894 = !{!895}
!895 = !DITemplateTypeParameter(type: !810)
!896 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !801, baseType: !897, flags: DIFlagPrivate, extraData: i32 0)
!897 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Head_base<0, unsigned int, false>", scope: !5, file: !798, line: 124, size: 32, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !898, templateParams: !929, identifier: "_ZTSSt10_Head_baseILm0EjLb0EE")
!898 = !{!899, !900, !904, !909, !914, !918, !921, !926}
!899 = !DIDerivedType(tag: DW_TAG_member, name: "_M_head_impl", scope: !897, file: !798, line: 171, baseType: !18, size: 32)
!900 = !DISubprogram(name: "_Head_base", scope: !897, file: !798, line: 126, type: !901, scopeLine: 126, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!901 = !DISubroutineType(types: !902)
!902 = !{null, !903}
!903 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !897, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!904 = !DISubprogram(name: "_Head_base", scope: !897, file: !798, line: 129, type: !905, scopeLine: 129, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!905 = !DISubroutineType(types: !906)
!906 = !{null, !903, !907}
!907 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !908, size: 64)
!908 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !18)
!909 = !DISubprogram(name: "_Head_base", scope: !897, file: !798, line: 132, type: !910, scopeLine: 132, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!910 = !DISubroutineType(types: !911)
!911 = !{null, !903, !912}
!912 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !913, size: 64)
!913 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !897)
!914 = !DISubprogram(name: "_Head_base", scope: !897, file: !798, line: 133, type: !915, scopeLine: 133, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!915 = !DISubroutineType(types: !916)
!916 = !{null, !903, !917}
!917 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !897, size: 64)
!918 = !DISubprogram(name: "_Head_base", scope: !897, file: !798, line: 140, type: !919, scopeLine: 140, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!919 = !DISubroutineType(types: !920)
!920 = !{null, !903, !833, !840}
!921 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm0EjLb0EE7_M_headERS0_", scope: !897, file: !798, line: 166, type: !922, scopeLine: 166, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!922 = !DISubroutineType(types: !923)
!923 = !{!924, !925}
!924 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !18, size: 64)
!925 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !897, size: 64)
!926 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm0EjLb0EE7_M_headERKS0_", scope: !897, file: !798, line: 169, type: !927, scopeLine: 169, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!927 = !DISubroutineType(types: !928)
!928 = !{!907, !912}
!929 = !{!930, !931, !932}
!930 = !DITemplateValueParameter(name: "_Idx", type: !86, value: i64 0)
!931 = !DITemplateTypeParameter(name: "_Head", type: !18)
!932 = !DITemplateValueParameter(type: !92, value: i8 0)
!933 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm0EJjN4pbbs5emptyEEE7_M_headERS2_", scope: !801, file: !798, line: 201, type: !934, scopeLine: 201, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!934 = !DISubroutineType(types: !935)
!935 = !{!924, !936}
!936 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !801, size: 64)
!937 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm0EJjN4pbbs5emptyEEE7_M_headERKS2_", scope: !801, file: !798, line: 204, type: !938, scopeLine: 204, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!938 = !DISubroutineType(types: !939)
!939 = !{!907, !940}
!940 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !941, size: 64)
!941 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !801)
!942 = !DISubprogram(name: "_M_tail", linkageName: "_ZNSt11_Tuple_implILm0EJjN4pbbs5emptyEEE7_M_tailERS2_", scope: !801, file: !798, line: 207, type: !943, scopeLine: 207, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!943 = !DISubroutineType(types: !944)
!944 = !{!945, !936}
!945 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !946, size: 64)
!946 = !DIDerivedType(tag: DW_TAG_typedef, name: "_Inherited", scope: !801, file: !798, line: 197, baseType: !804)
!947 = !DISubprogram(name: "_M_tail", linkageName: "_ZNSt11_Tuple_implILm0EJjN4pbbs5emptyEEE7_M_tailERKS2_", scope: !801, file: !798, line: 210, type: !948, scopeLine: 210, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!948 = !DISubroutineType(types: !949)
!949 = !{!950, !940}
!950 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !951, size: 64)
!951 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !946)
!952 = !DISubprogram(name: "_Tuple_impl", scope: !801, file: !798, line: 212, type: !953, scopeLine: 212, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!953 = !DISubroutineType(types: !954)
!954 = !{null, !955}
!955 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !801, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!956 = !DISubprogram(name: "_Tuple_impl", scope: !801, file: !798, line: 216, type: !957, scopeLine: 216, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!957 = !DISubroutineType(types: !958)
!958 = !{null, !955, !907, !819}
!959 = !DISubprogram(name: "_Tuple_impl", scope: !801, file: !798, line: 226, type: !960, scopeLine: 226, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!960 = !DISubroutineType(types: !961)
!961 = !{null, !955, !940}
!962 = !DISubprogram(name: "operator=", linkageName: "_ZNSt11_Tuple_implILm0EJjN4pbbs5emptyEEEaSERKS2_", scope: !801, file: !798, line: 230, type: !963, scopeLine: 230, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized | DISPFlagDeleted)
!963 = !DISubroutineType(types: !964)
!964 = !{!936, !955, !940}
!965 = !DISubprogram(name: "_Tuple_impl", scope: !801, file: !798, line: 233, type: !966, scopeLine: 233, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!966 = !DISubroutineType(types: !967)
!967 = !{null, !955, !968}
!968 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !801, size: 64)
!969 = !DISubprogram(name: "_M_swap", linkageName: "_ZNSt11_Tuple_implILm0EJjN4pbbs5emptyEEE7_M_swapERS2_", scope: !801, file: !798, line: 331, type: !970, scopeLine: 331, flags: DIFlagProtected | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!970 = !DISubroutineType(types: !971)
!971 = !{null, !955, !936}
!972 = !{!930, !973}
!973 = !DITemplateValueParameter(tag: DW_TAG_GNU_template_parameter_pack, name: "_Elements", value: !974)
!974 = !{!975, !895}
!975 = !DITemplateTypeParameter(type: !18)
!976 = !DISubprogram(name: "__nothrow_default_constructible", linkageName: "_ZNSt5tupleIJjN4pbbs5emptyEEE31__nothrow_default_constructibleEv", scope: !797, file: !798, line: 941, type: !623, scopeLine: 941, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!977 = !DISubprogram(name: "tuple", scope: !797, file: !798, line: 994, type: !978, scopeLine: 994, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!978 = !DISubroutineType(types: !979)
!979 = !{null, !980, !981}
!980 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !797, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!981 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !982, size: 64)
!982 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !797)
!983 = !DISubprogram(name: "tuple", scope: !797, file: !798, line: 996, type: !984, scopeLine: 996, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!984 = !DISubroutineType(types: !985)
!985 = !{null, !980, !986}
!986 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !797, size: 64)
!987 = !DISubprogram(name: "operator=", linkageName: "_ZNSt5tupleIJjN4pbbs5emptyEEEaSERKS2_", scope: !797, file: !798, line: 1173, type: !988, scopeLine: 1173, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!988 = !DISubroutineType(types: !989)
!989 = !{!990, !980, !991}
!990 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !797, size: 64)
!991 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !992, file: !260, line: 2201, baseType: !981)
!992 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, const std::tuple<unsigned int, pbbs::empty> &, const std::__nonesuch &>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !993, identifier: "_ZTSSt11conditionalILb1ERKSt5tupleIJjN4pbbs5emptyEEERKSt10__nonesuchE")
!993 = !{!263, !994, !265}
!994 = !DITemplateTypeParameter(name: "_Iftrue", type: !981)
!995 = !DISubprogram(name: "operator=", linkageName: "_ZNSt5tupleIJjN4pbbs5emptyEEEaSEOS2_", scope: !797, file: !798, line: 1184, type: !996, scopeLine: 1184, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!996 = !DISubroutineType(types: !997)
!997 = !{!990, !980, !998}
!998 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !999, file: !260, line: 2201, baseType: !986)
!999 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, std::tuple<unsigned int, pbbs::empty> &&, std::__nonesuch &&>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !1000, identifier: "_ZTSSt11conditionalILb1EOSt5tupleIJjN4pbbs5emptyEEEOSt10__nonesuchE")
!1000 = !{!263, !1001, !276}
!1001 = !DITemplateTypeParameter(name: "_Iftrue", type: !986)
!1002 = !DISubprogram(name: "swap", linkageName: "_ZNSt5tupleIJjN4pbbs5emptyEEE4swapERS2_", scope: !797, file: !798, line: 1237, type: !1003, scopeLine: 1237, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1003 = !DISubroutineType(types: !1004)
!1004 = !{null, !980, !990}
!1005 = !{!973}
!1006 = !DISubprogram(name: "vertexSubsetData", scope: !771, file: !772, line: 135, type: !1007, scopeLine: 135, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1007 = !DISubroutineType(types: !1008)
!1008 = !{null, !786, !52, !52, !91}
!1009 = !DISubprogram(name: "vertexSubsetData", scope: !771, file: !772, line: 140, type: !1010, scopeLine: 140, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1010 = !DISubroutineType(types: !1011)
!1011 = !{null, !786, !52, !91}
!1012 = !DISubprogram(name: "vertexSubsetData", scope: !771, file: !772, line: 149, type: !1013, scopeLine: 149, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1013 = !DISubroutineType(types: !1014)
!1014 = !{null, !786, !52, !1015}
!1015 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1016, size: 64)
!1016 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "tuple<bool, pbbs::empty>", scope: !5, file: !798, line: 887, size: 8, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !1017, templateParams: !1129, identifier: "_ZTSSt5tupleIJbN4pbbs5emptyEEE")
!1017 = !{!1018, !1100, !1101, !1107, !1111, !1119, !1126}
!1018 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1016, baseType: !1019, flags: DIFlagPublic, extraData: i32 0)
!1019 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Tuple_impl<0, bool, pbbs::empty>", scope: !5, file: !798, line: 191, size: 8, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !1020, templateParams: !1096, identifier: "_ZTSSt11_Tuple_implILm0EJbN4pbbs5emptyEEE")
!1020 = !{!1021, !1022, !1057, !1061, !1066, !1071, !1076, !1080, !1083, !1086, !1089, !1093}
!1021 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1019, baseType: !804, extraData: i32 0)
!1022 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1019, baseType: !1023, flags: DIFlagPrivate, extraData: i32 0)
!1023 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Head_base<0, bool, false>", scope: !5, file: !798, line: 124, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1024, templateParams: !1055, identifier: "_ZTSSt10_Head_baseILm0EbLb0EE")
!1024 = !{!1025, !1026, !1030, !1035, !1040, !1044, !1047, !1052}
!1025 = !DIDerivedType(tag: DW_TAG_member, name: "_M_head_impl", scope: !1023, file: !798, line: 171, baseType: !92, size: 8)
!1026 = !DISubprogram(name: "_Head_base", scope: !1023, file: !798, line: 126, type: !1027, scopeLine: 126, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1027 = !DISubroutineType(types: !1028)
!1028 = !{null, !1029}
!1029 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1023, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1030 = !DISubprogram(name: "_Head_base", scope: !1023, file: !798, line: 129, type: !1031, scopeLine: 129, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1031 = !DISubroutineType(types: !1032)
!1032 = !{null, !1029, !1033}
!1033 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1034, size: 64)
!1034 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !92)
!1035 = !DISubprogram(name: "_Head_base", scope: !1023, file: !798, line: 132, type: !1036, scopeLine: 132, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1036 = !DISubroutineType(types: !1037)
!1037 = !{null, !1029, !1038}
!1038 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1039, size: 64)
!1039 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1023)
!1040 = !DISubprogram(name: "_Head_base", scope: !1023, file: !798, line: 133, type: !1041, scopeLine: 133, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1041 = !DISubroutineType(types: !1042)
!1042 = !{null, !1029, !1043}
!1043 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !1023, size: 64)
!1044 = !DISubprogram(name: "_Head_base", scope: !1023, file: !798, line: 140, type: !1045, scopeLine: 140, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1045 = !DISubroutineType(types: !1046)
!1046 = !{null, !1029, !833, !840}
!1047 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm0EbLb0EE7_M_headERS0_", scope: !1023, file: !798, line: 166, type: !1048, scopeLine: 166, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!1048 = !DISubroutineType(types: !1049)
!1049 = !{!1050, !1051}
!1050 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !92, size: 64)
!1051 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1023, size: 64)
!1052 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm0EbLb0EE7_M_headERKS0_", scope: !1023, file: !798, line: 169, type: !1053, scopeLine: 169, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!1053 = !DISubroutineType(types: !1054)
!1054 = !{!1033, !1038}
!1055 = !{!930, !1056, !932}
!1056 = !DITemplateTypeParameter(name: "_Head", type: !92)
!1057 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEE7_M_headERS2_", scope: !1019, file: !798, line: 201, type: !1058, scopeLine: 201, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!1058 = !DISubroutineType(types: !1059)
!1059 = !{!1050, !1060}
!1060 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1019, size: 64)
!1061 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEE7_M_headERKS2_", scope: !1019, file: !798, line: 204, type: !1062, scopeLine: 204, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!1062 = !DISubroutineType(types: !1063)
!1063 = !{!1033, !1064}
!1064 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1065, size: 64)
!1065 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1019)
!1066 = !DISubprogram(name: "_M_tail", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEE7_M_tailERS2_", scope: !1019, file: !798, line: 207, type: !1067, scopeLine: 207, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!1067 = !DISubroutineType(types: !1068)
!1068 = !{!1069, !1060}
!1069 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1070, size: 64)
!1070 = !DIDerivedType(tag: DW_TAG_typedef, name: "_Inherited", scope: !1019, file: !798, line: 197, baseType: !804)
!1071 = !DISubprogram(name: "_M_tail", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEE7_M_tailERKS2_", scope: !1019, file: !798, line: 210, type: !1072, scopeLine: 210, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!1072 = !DISubroutineType(types: !1073)
!1073 = !{!1074, !1064}
!1074 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1075, size: 64)
!1075 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1070)
!1076 = !DISubprogram(name: "_Tuple_impl", scope: !1019, file: !798, line: 212, type: !1077, scopeLine: 212, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1077 = !DISubroutineType(types: !1078)
!1078 = !{null, !1079}
!1079 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1019, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1080 = !DISubprogram(name: "_Tuple_impl", scope: !1019, file: !798, line: 216, type: !1081, scopeLine: 216, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1081 = !DISubroutineType(types: !1082)
!1082 = !{null, !1079, !1033, !819}
!1083 = !DISubprogram(name: "_Tuple_impl", scope: !1019, file: !798, line: 226, type: !1084, scopeLine: 226, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1084 = !DISubroutineType(types: !1085)
!1085 = !{null, !1079, !1064}
!1086 = !DISubprogram(name: "operator=", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEEaSERKS2_", scope: !1019, file: !798, line: 230, type: !1087, scopeLine: 230, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized | DISPFlagDeleted)
!1087 = !DISubroutineType(types: !1088)
!1088 = !{!1060, !1079, !1064}
!1089 = !DISubprogram(name: "_Tuple_impl", scope: !1019, file: !798, line: 233, type: !1090, scopeLine: 233, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1090 = !DISubroutineType(types: !1091)
!1091 = !{null, !1079, !1092}
!1092 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !1019, size: 64)
!1093 = !DISubprogram(name: "_M_swap", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEE7_M_swapERS2_", scope: !1019, file: !798, line: 331, type: !1094, scopeLine: 331, flags: DIFlagProtected | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1094 = !DISubroutineType(types: !1095)
!1095 = !{null, !1079, !1060}
!1096 = !{!930, !1097}
!1097 = !DITemplateValueParameter(tag: DW_TAG_GNU_template_parameter_pack, name: "_Elements", value: !1098)
!1098 = !{!1099, !895}
!1099 = !DITemplateTypeParameter(type: !92)
!1100 = !DISubprogram(name: "__nothrow_default_constructible", linkageName: "_ZNSt5tupleIJbN4pbbs5emptyEEE31__nothrow_default_constructibleEv", scope: !1016, file: !798, line: 941, type: !623, scopeLine: 941, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!1101 = !DISubprogram(name: "tuple", scope: !1016, file: !798, line: 994, type: !1102, scopeLine: 994, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1102 = !DISubroutineType(types: !1103)
!1103 = !{null, !1104, !1105}
!1104 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1016, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1105 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1106, size: 64)
!1106 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1016)
!1107 = !DISubprogram(name: "tuple", scope: !1016, file: !798, line: 996, type: !1108, scopeLine: 996, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1108 = !DISubroutineType(types: !1109)
!1109 = !{null, !1104, !1110}
!1110 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !1016, size: 64)
!1111 = !DISubprogram(name: "operator=", linkageName: "_ZNSt5tupleIJbN4pbbs5emptyEEEaSERKS2_", scope: !1016, file: !798, line: 1173, type: !1112, scopeLine: 1173, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1112 = !DISubroutineType(types: !1113)
!1113 = !{!1114, !1104, !1115}
!1114 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1016, size: 64)
!1115 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !1116, file: !260, line: 2201, baseType: !1105)
!1116 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, const std::tuple<bool, pbbs::empty> &, const std::__nonesuch &>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !1117, identifier: "_ZTSSt11conditionalILb1ERKSt5tupleIJbN4pbbs5emptyEEERKSt10__nonesuchE")
!1117 = !{!263, !1118, !265}
!1118 = !DITemplateTypeParameter(name: "_Iftrue", type: !1105)
!1119 = !DISubprogram(name: "operator=", linkageName: "_ZNSt5tupleIJbN4pbbs5emptyEEEaSEOS2_", scope: !1016, file: !798, line: 1184, type: !1120, scopeLine: 1184, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1120 = !DISubroutineType(types: !1121)
!1121 = !{!1114, !1104, !1122}
!1122 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !1123, file: !260, line: 2201, baseType: !1110)
!1123 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, std::tuple<bool, pbbs::empty> &&, std::__nonesuch &&>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !1124, identifier: "_ZTSSt11conditionalILb1EOSt5tupleIJbN4pbbs5emptyEEEOSt10__nonesuchE")
!1124 = !{!263, !1125, !276}
!1125 = !DITemplateTypeParameter(name: "_Iftrue", type: !1110)
!1126 = !DISubprogram(name: "swap", linkageName: "_ZNSt5tupleIJbN4pbbs5emptyEEE4swapERS2_", scope: !1016, file: !798, line: 1237, type: !1127, scopeLine: 1237, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1127 = !DISubroutineType(types: !1128)
!1128 = !{null, !1104, !1114}
!1129 = !{!1097}
!1130 = !DISubprogram(name: "del", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE3delEv", scope: !771, file: !772, line: 156, type: !1131, scopeLine: 156, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1131 = !DISubroutineType(types: !1132)
!1132 = !{null, !786}
!1133 = !DISubprogram(name: "vtx", linkageName: "_ZNK16vertexSubsetDataIN4pbbs5emptyEE3vtxERKj", scope: !771, file: !772, line: 162, type: !1134, scopeLine: 162, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1134 = !DISubroutineType(types: !1135)
!1135 = !{!1136, !1137, !1139}
!1136 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !50, size: 64)
!1137 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1138, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1138 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !771)
!1139 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !451, size: 64)
!1140 = !DISubprogram(name: "vtxData", linkageName: "_ZNK16vertexSubsetDataIN4pbbs5emptyEE7vtxDataERKj", scope: !771, file: !772, line: 163, type: !1141, scopeLine: 163, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1141 = !DISubroutineType(types: !1142)
!1142 = !{!810, !1137, !1139}
!1143 = !DISubprogram(name: "vtxAndData", linkageName: "_ZNK16vertexSubsetDataIN4pbbs5emptyEE10vtxAndDataERKj", scope: !771, file: !772, line: 164, type: !1144, scopeLine: 164, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1144 = !DISubroutineType(types: !1145)
!1145 = !{!797, !1137, !1139}
!1146 = !DISubprogram(name: "isIn", linkageName: "_ZNK16vertexSubsetDataIN4pbbs5emptyEE4isInERKj", scope: !771, file: !772, line: 167, type: !1147, scopeLine: 167, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1147 = !DISubroutineType(types: !1148)
!1148 = !{!92, !1137, !1139}
!1149 = !DISubprogram(name: "ithData", linkageName: "_ZNK16vertexSubsetDataIN4pbbs5emptyEE7ithDataERKj", scope: !771, file: !772, line: 168, type: !1141, scopeLine: 168, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1150 = !DISubprogram(name: "size", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE4sizeEv", scope: !771, file: !772, line: 187, type: !1151, scopeLine: 187, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1151 = !DISubroutineType(types: !1152)
!1152 = !{!52, !786}
!1153 = !DISubprogram(name: "numVertices", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE11numVerticesEv", scope: !771, file: !772, line: 188, type: !1151, scopeLine: 188, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1154 = !DISubprogram(name: "numRows", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE7numRowsEv", scope: !771, file: !772, line: 190, type: !1151, scopeLine: 190, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1155 = !DISubprogram(name: "numNonzeros", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE11numNonzerosEv", scope: !771, file: !772, line: 191, type: !1151, scopeLine: 191, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1156 = !DISubprogram(name: "isEmpty", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE7isEmptyEv", scope: !771, file: !772, line: 193, type: !1157, scopeLine: 193, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1157 = !DISubroutineType(types: !1158)
!1158 = !{!92, !786}
!1159 = !DISubprogram(name: "dense", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE5denseEv", scope: !771, file: !772, line: 194, type: !1157, scopeLine: 194, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1160 = !DISubprogram(name: "toSparse", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEv", scope: !771, file: !772, line: 196, type: !1131, scopeLine: 196, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1161 = !DISubprogram(name: "toDense", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE7toDenseEv", scope: !771, file: !772, line: 214, type: !1131, scopeLine: 214, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1162 = !{!1163}
!1163 = !DITemplateTypeParameter(name: "data", type: !810)
!1164 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !771, size: 64)
!1165 = !{!190, !1166, !1167}
!1166 = !DITemplateTypeParameter(name: "VS", type: !771)
!1167 = !DITemplateTypeParameter(name: "F", type: !754)
!1168 = !DISubprogram(name: "edgeMapData<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z11edgeMapDataIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj", scope: !192, file: !192, line: 235, type: !1169, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1171, retainedNodes: !45)
!1169 = !DISubroutineType(types: !1170)
!1170 = !{!771, !195, !1164, !754, !6, !907}
!1171 = !{!1163, !190, !1166, !1167}
!1172 = !DISubprogram(name: "plusReduce<unsigned int, long>", linkageName: "_ZN8sequence10plusReduceIjlEET_PS1_T0_", scope: !55, file: !54, line: 151, type: !1173, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1176, retainedNodes: !45)
!1173 = !DISubroutineType(types: !1174)
!1174 = !{!18, !1175, !52}
!1175 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !18, size: 64)
!1176 = !{!1177, !60}
!1177 = !DITemplateTypeParameter(name: "OT", type: !18)
!1178 = !DISubprogram(name: "edgeMapDenseForward<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z19edgeMapDenseForwardIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 85, type: !1179, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1171, retainedNodes: !45)
!1179 = !DISubroutineType(types: !1180)
!1180 = !{!771, !116, !1164, !1181, !18}
!1181 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !754, size: 64)
!1182 = !DISubprogram(name: "edgeMapDense<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z12edgeMapDenseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 59, type: !1179, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1171, retainedNodes: !45)
!1183 = !DISubprogram(name: "edgeMapSparse_no_filter<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 157, type: !1184, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1171, retainedNodes: !45)
!1184 = !DISubroutineType(types: !1185)
!1185 = !{!771, !195, !120, !1164, !1175, !18, !1181, !18}
!1186 = !DISubprogram(name: "edgeMapSparse<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z13edgeMapSparseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 111, type: !1184, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1171, retainedNodes: !45)
!1187 = !DISubprogram(name: "make_in_imap<bool, (lambda at ./vertexSubset.h:199:16)>", linkageName: "_Z12make_in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E7in_imapIT_T0_EmS7_", scope: !1188, file: !1188, line: 59, type: !1189, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1267, retainedNodes: !45)
!1188 = !DIFile(filename: "./index_map.h", directory: "/data/compilers/tests/ligra/apps")
!1189 = !DISubroutineType(types: !1190)
!1190 = !{!1191, !86, !1194}
!1191 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_imap<bool, (lambda at ./vertexSubset.h:199:16)>", file: !1188, line: 44, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1192, templateParams: !1267, identifier: "_ZTS7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E")
!1192 = !{!1193, !1246, !1247, !1248, !1252, !1255, !1259, !1260, !1263, !1264}
!1193 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !1191, file: !1188, line: 46, baseType: !1194, size: 64)
!1194 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1195, file: !772, line: 199, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1243, identifier: "_ZTSZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_")
!1195 = distinct !DISubprogram(name: "toSparse", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEv", scope: !771, file: !772, line: 196, type: !1131, scopeLine: 196, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !1160, retainedNodes: !1196)
!1196 = !{!1197, !1199, !1202, !1203, !1204}
!1197 = !DILocalVariable(name: "this", arg: 1, scope: !1195, type: !1198, flags: DIFlagArtificial | DIFlagObjectPointer)
!1198 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !771, size: 64)
!1199 = !DILocalVariable(name: "_d", scope: !1200, file: !772, line: 198, type: !91)
!1200 = distinct !DILexicalBlock(scope: !1201, file: !772, line: 197, column: 29)
!1201 = distinct !DILexicalBlock(scope: !1195, file: !772, line: 197, column: 9)
!1202 = !DILocalVariable(name: "f", scope: !1200, file: !772, line: 199, type: !1194)
!1203 = !DILocalVariable(name: "f_in", scope: !1200, file: !772, line: 200, type: !1191)
!1204 = !DILocalVariable(name: "out", scope: !1200, file: !772, line: 201, type: !1205)
!1205 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "array_imap<unsigned int>", file: !1188, line: 103, size: 192, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !1206, templateParams: !1241, identifier: "_ZTS10array_imapIjE")
!1206 = !{!1207, !1208, !1209, !1210, !1216, !1219, !1222, !1226, !1227, !1231, !1232, !1235, !1238}
!1207 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !1205, file: !1188, line: 105, baseType: !1175, size: 64)
!1208 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !1205, file: !1188, line: 105, baseType: !1175, size: 64, offset: 64)
!1209 = !DIDerivedType(tag: DW_TAG_member, name: "alloc", scope: !1205, file: !1188, line: 106, baseType: !92, size: 8, offset: 128)
!1210 = !DISubprogram(name: "array_imap", scope: !1205, file: !1188, line: 107, type: !1211, scopeLine: 107, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1211 = !DISubroutineType(types: !1212)
!1212 = !{null, !1213, !1214}
!1213 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1205, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1214 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1215, size: 64)
!1215 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1205)
!1216 = !DISubprogram(name: "array_imap", scope: !1205, file: !1188, line: 108, type: !1217, scopeLine: 108, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1217 = !DISubroutineType(types: !1218)
!1218 = !{null, !1213}
!1219 = !DISubprogram(name: "array_imap", scope: !1205, file: !1188, line: 109, type: !1220, scopeLine: 109, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1220 = !DISubroutineType(types: !1221)
!1221 = !{null, !1213, !1175, !779, !92}
!1222 = !DISubprogram(name: "array_imap", scope: !1205, file: !1188, line: 111, type: !1223, scopeLine: 111, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1223 = !DISubroutineType(types: !1224)
!1224 = !{null, !1213, !1225}
!1225 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !779)
!1226 = !DISubprogram(name: "~array_imap", scope: !1205, file: !1188, line: 116, type: !1217, scopeLine: 116, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1227 = !DISubprogram(name: "operator[]", linkageName: "_ZNK10array_imapIjEixEm", scope: !1205, file: !1188, line: 117, type: !1228, scopeLine: 117, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1228 = !DISubroutineType(types: !1229)
!1229 = !{!924, !1230, !1225}
!1230 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1215, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1231 = !DISubprogram(name: "operator()", linkageName: "_ZNK10array_imapIjEclEm", scope: !1205, file: !1188, line: 118, type: !1228, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1232 = !DISubprogram(name: "cut", linkageName: "_ZN10array_imapIjE3cutEmm", scope: !1205, file: !1188, line: 119, type: !1233, scopeLine: 119, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1233 = !DISubroutineType(types: !1234)
!1234 = !{!1205, !1213, !779, !779}
!1235 = !DISubprogram(name: "update", linkageName: "_ZN10array_imapIjE6updateEmRKj", scope: !1205, file: !1188, line: 121, type: !1236, scopeLine: 121, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1236 = !DISubroutineType(types: !1237)
!1237 = !{null, !1213, !779, !907}
!1238 = !DISubprogram(name: "size", linkageName: "_ZN10array_imapIjE4sizeEv", scope: !1205, file: !1188, line: 123, type: !1239, scopeLine: 123, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1239 = !DISubroutineType(types: !1240)
!1240 = !{!779, !1213}
!1241 = !{!1242}
!1242 = !DITemplateTypeParameter(name: "E", type: !18)
!1243 = !{!1244}
!1244 = !DIDerivedType(tag: DW_TAG_member, name: "_d", scope: !1194, file: !772, line: 199, baseType: !1245, size: 64)
!1245 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !91, size: 64)
!1246 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !1191, file: !1188, line: 47, baseType: !779, size: 64, offset: 64)
!1247 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !1191, file: !1188, line: 47, baseType: !779, size: 64, offset: 128)
!1248 = !DISubprogram(name: "in_imap", scope: !1191, file: !1188, line: 48, type: !1249, scopeLine: 48, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1249 = !DISubroutineType(types: !1250)
!1250 = !{null, !1251, !779, !1194}
!1251 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1191, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1252 = !DISubprogram(name: "in_imap", scope: !1191, file: !1188, line: 49, type: !1253, scopeLine: 49, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1253 = !DISubroutineType(types: !1254)
!1254 = !{null, !1251, !779, !779, !1194}
!1255 = !DISubprogram(name: "operator[]", linkageName: "_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_EixEm", scope: !1191, file: !1188, line: 50, type: !1256, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1256 = !DISubroutineType(types: !1257)
!1257 = !{!1258, !1251, !1225}
!1258 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1191, file: !1188, line: 45, baseType: !92)
!1259 = !DISubprogram(name: "operator()", linkageName: "_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_EclEm", scope: !1191, file: !1188, line: 51, type: !1256, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1260 = !DISubprogram(name: "cut", linkageName: "_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E3cutEmm", scope: !1191, file: !1188, line: 52, type: !1261, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1261 = !DISubroutineType(types: !1262)
!1262 = !{!1191, !1251, !779, !779}
!1263 = !DISubprogram(name: "slice", linkageName: "_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E5sliceEmm", scope: !1191, file: !1188, line: 53, type: !1261, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1264 = !DISubprogram(name: "size", linkageName: "_ZN7in_imapIbZN16vertexSubsetDataIN4pbbs5emptyEE8toSparseEvEUlmE_E4sizeEv", scope: !1191, file: !1188, line: 54, type: !1265, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1265 = !DISubroutineType(types: !1266)
!1266 = !{!779, !1251}
!1267 = !{!1268, !1269}
!1268 = !DITemplateTypeParameter(name: "E", type: !92)
!1269 = !DITemplateTypeParameter(name: "F", type: !1194)
!1270 = !DISubprogram(name: "pack_index<unsigned int, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >", linkageName: "_ZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_j", scope: !811, file: !1271, line: 204, type: !1272, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1274, retainedNodes: !45)
!1271 = !DIFile(filename: "./sequence.h", directory: "/data/compilers/tests/ligra/apps")
!1272 = !DISubroutineType(types: !1273)
!1273 = !{!1205, !1191, !18}
!1274 = !{!1275, !1276}
!1275 = !DITemplateTypeParameter(name: "Idx_Type", type: !18)
!1276 = !DITemplateTypeParameter(name: "Imap_Fl", type: !1191)
!1277 = !DISubprogram(name: "make_in_imap<unsigned int, (lambda at ./sequence.h:205:21)>", linkageName: "_Z12make_in_imapIjZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES2_IS9_SB_EmSB_", scope: !1188, file: !1188, line: 59, type: !1278, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1316, retainedNodes: !45)
!1278 = !DISubroutineType(types: !1279)
!1279 = !{!1280, !86, !1283}
!1280 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_imap<unsigned int, (lambda at ./sequence.h:205:21)>", file: !1188, line: 44, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1281, templateParams: !1316, identifier: "_ZTS7in_imapIjZN4pbbs10pack_indexIjS_IbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_E")
!1281 = !{!1282, !1295, !1296, !1297, !1301, !1304, !1308, !1309, !1312, !1313}
!1282 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !1280, file: !1188, line: 46, baseType: !1283, size: 8)
!1283 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1284, file: !1271, line: 205, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_")
!1284 = distinct !DISubprogram(name: "pack_index<unsigned int, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >", linkageName: "_ZN4pbbs10pack_indexIj7in_imapIbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_j", scope: !811, file: !1271, line: 204, type: !1285, scopeLine: 204, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1274, retainedNodes: !1291)
!1285 = !DISubroutineType(types: !1286)
!1286 = !{!1205, !1191, !1287}
!1287 = !DIDerivedType(tag: DW_TAG_typedef, name: "flags", scope: !811, file: !54, line: 395, baseType: !1288)
!1288 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !1289, line: 26, baseType: !1290)
!1289 = !DIFile(filename: "/usr/include/bits/stdint-uintn.h", directory: "")
!1290 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !695, line: 42, baseType: !18)
!1291 = !{!1292, !1293, !1294}
!1292 = !DILocalVariable(name: "Fl", arg: 1, scope: !1284, file: !1271, line: 204, type: !1191)
!1293 = !DILocalVariable(name: "fl", arg: 2, scope: !1284, file: !1271, line: 204, type: !1287)
!1294 = !DILocalVariable(name: "identity", scope: !1284, file: !1271, line: 205, type: !1283)
!1295 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !1280, file: !1188, line: 47, baseType: !779, size: 64, offset: 64)
!1296 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !1280, file: !1188, line: 47, baseType: !779, size: 64, offset: 128)
!1297 = !DISubprogram(name: "in_imap", scope: !1280, file: !1188, line: 48, type: !1298, scopeLine: 48, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1298 = !DISubroutineType(types: !1299)
!1299 = !{null, !1300, !779, !1283}
!1300 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1280, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1301 = !DISubprogram(name: "in_imap", scope: !1280, file: !1188, line: 49, type: !1302, scopeLine: 49, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1302 = !DISubroutineType(types: !1303)
!1303 = !{null, !1300, !779, !779, !1283}
!1304 = !DISubprogram(name: "operator[]", linkageName: "_ZN7in_imapIjZN4pbbs10pack_indexIjS_IbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_EixEm", scope: !1280, file: !1188, line: 50, type: !1305, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1305 = !DISubroutineType(types: !1306)
!1306 = !{!1307, !1300, !1225}
!1307 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1280, file: !1188, line: 45, baseType: !18)
!1308 = !DISubprogram(name: "operator()", linkageName: "_ZN7in_imapIjZN4pbbs10pack_indexIjS_IbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_EclEm", scope: !1280, file: !1188, line: 51, type: !1305, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1309 = !DISubprogram(name: "cut", linkageName: "_ZN7in_imapIjZN4pbbs10pack_indexIjS_IbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_E3cutEmm", scope: !1280, file: !1188, line: 52, type: !1310, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1310 = !DISubroutineType(types: !1311)
!1311 = !{!1280, !1300, !779, !779}
!1312 = !DISubprogram(name: "slice", linkageName: "_ZN7in_imapIjZN4pbbs10pack_indexIjS_IbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_E5sliceEmm", scope: !1280, file: !1188, line: 53, type: !1310, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1313 = !DISubprogram(name: "size", linkageName: "_ZN7in_imapIjZN4pbbs10pack_indexIjS_IbZN16vertexSubsetDataINS0_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_E4sizeEv", scope: !1280, file: !1188, line: 54, type: !1314, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1314 = !DISubroutineType(types: !1315)
!1315 = !{!779, !1300}
!1316 = !{!1242, !1317}
!1317 = !DITemplateTypeParameter(name: "F", type: !1283)
!1318 = !DISubprogram(name: "pack<in_imap<unsigned int, (lambda at ./sequence.h:205:21)>, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >", linkageName: "_ZN4pbbs4packI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_j", scope: !811, file: !1271, line: 181, type: !1319, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1321, retainedNodes: !45)
!1319 = !DISubroutineType(types: !1320)
!1320 = !{!1205, !1280, !1191, !18}
!1321 = !{!1322, !1276}
!1322 = !DITemplateTypeParameter(name: "Imap_In", type: !1280)
!1323 = !DISubprogram(name: "pack_serial<in_imap<unsigned int, (lambda at ./sequence.h:205:21)>, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >", linkageName: "_ZN4pbbs11pack_serialI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_", scope: !811, file: !1271, line: 161, type: !1324, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1321, retainedNodes: !45)
!1324 = !DISubroutineType(types: !1325)
!1325 = !{!1205, !1280, !1191}
!1326 = !DISubprogram(name: "sliced_for<(lambda at ./sequence.h:191:17)>", linkageName: "_ZN4pbbs10sliced_forIZNS_4packI7in_imapIjZNS_10pack_indexIjS2_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES8_EES9_INSA_1TEESA_SC_jEUlmmmE_EEvmmRKSA_", scope: !811, file: !1271, line: 40, type: !1327, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1392, retainedNodes: !45)
!1327 = !DISubroutineType(types: !1328)
!1328 = !{null, !86, !86, !1329}
!1329 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1330, size: 64)
!1330 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1331)
!1331 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1332, file: !1271, line: 191, size: 128, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1387, identifier: "_ZTSZN4pbbs4packI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_jEUlmmmE_")
!1332 = distinct !DISubprogram(name: "pack<in_imap<unsigned int, (lambda at ./sequence.h:205:21)>, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >", linkageName: "_ZN4pbbs4packI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_j", scope: !811, file: !1271, line: 181, type: !1333, scopeLine: 183, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1321, retainedNodes: !1335)
!1333 = !DISubroutineType(types: !1334)
!1334 = !{!1205, !1280, !1191, !1287}
!1335 = !{!1336, !1337, !1338, !1339, !1340, !1341, !1383, !1384}
!1336 = !DILocalVariable(name: "In", arg: 1, scope: !1332, file: !1271, line: 181, type: !1280)
!1337 = !DILocalVariable(name: "Fl", arg: 2, scope: !1332, file: !1271, line: 181, type: !1191)
!1338 = !DILocalVariable(name: "fl", arg: 3, scope: !1332, file: !1271, line: 181, type: !1287)
!1339 = !DILocalVariable(name: "n", scope: !1332, file: !1271, line: 185, type: !779)
!1340 = !DILocalVariable(name: "l", scope: !1332, file: !1271, line: 186, type: !779)
!1341 = !DILocalVariable(name: "Sums", scope: !1332, file: !1271, line: 189, type: !1342)
!1342 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "array_imap<unsigned long>", file: !1188, line: 103, size: 192, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !1343, templateParams: !1381, identifier: "_ZTS10array_imapImE")
!1343 = !{!1344, !1346, !1347, !1348, !1354, !1357, !1360, !1363, !1364, !1369, !1370, !1373, !1378}
!1344 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !1342, file: !1188, line: 105, baseType: !1345, size: 64)
!1345 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !86, size: 64)
!1346 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !1342, file: !1188, line: 105, baseType: !1345, size: 64, offset: 64)
!1347 = !DIDerivedType(tag: DW_TAG_member, name: "alloc", scope: !1342, file: !1188, line: 106, baseType: !92, size: 8, offset: 128)
!1348 = !DISubprogram(name: "array_imap", scope: !1342, file: !1188, line: 107, type: !1349, scopeLine: 107, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1349 = !DISubroutineType(types: !1350)
!1350 = !{null, !1351, !1352}
!1351 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1342, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1352 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1353, size: 64)
!1353 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1342)
!1354 = !DISubprogram(name: "array_imap", scope: !1342, file: !1188, line: 108, type: !1355, scopeLine: 108, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1355 = !DISubroutineType(types: !1356)
!1356 = !{null, !1351}
!1357 = !DISubprogram(name: "array_imap", scope: !1342, file: !1188, line: 109, type: !1358, scopeLine: 109, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1358 = !DISubroutineType(types: !1359)
!1359 = !{null, !1351, !1345, !779, !92}
!1360 = !DISubprogram(name: "array_imap", scope: !1342, file: !1188, line: 111, type: !1361, scopeLine: 111, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1361 = !DISubroutineType(types: !1362)
!1362 = !{null, !1351, !1225}
!1363 = !DISubprogram(name: "~array_imap", scope: !1342, file: !1188, line: 116, type: !1355, scopeLine: 116, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1364 = !DISubprogram(name: "operator[]", linkageName: "_ZNK10array_imapImEixEm", scope: !1342, file: !1188, line: 117, type: !1365, scopeLine: 117, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1365 = !DISubroutineType(types: !1366)
!1366 = !{!1367, !1368, !1225}
!1367 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !86, size: 64)
!1368 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1353, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1369 = !DISubprogram(name: "operator()", linkageName: "_ZNK10array_imapImEclEm", scope: !1342, file: !1188, line: 118, type: !1365, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1370 = !DISubprogram(name: "cut", linkageName: "_ZN10array_imapImE3cutEmm", scope: !1342, file: !1188, line: 119, type: !1371, scopeLine: 119, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1371 = !DISubroutineType(types: !1372)
!1372 = !{!1342, !1351, !779, !779}
!1373 = !DISubprogram(name: "update", linkageName: "_ZN10array_imapImE6updateEmRKm", scope: !1342, file: !1188, line: 121, type: !1374, scopeLine: 121, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1374 = !DISubroutineType(types: !1375)
!1375 = !{null, !1351, !779, !1376}
!1376 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1377, size: 64)
!1377 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !86)
!1378 = !DISubprogram(name: "size", linkageName: "_ZN10array_imapImE4sizeEv", scope: !1342, file: !1188, line: 123, type: !1379, scopeLine: 123, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1379 = !DISubroutineType(types: !1380)
!1380 = !{!779, !1351}
!1381 = !{!1382}
!1382 = !DITemplateTypeParameter(name: "E", type: !86)
!1383 = !DILocalVariable(name: "m", scope: !1332, file: !1271, line: 193, type: !779)
!1384 = !DILocalVariable(name: "Out", scope: !1332, file: !1271, line: 194, type: !1385)
!1385 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1386, size: 64)
!1386 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1332, file: !1271, line: 184, baseType: !1307)
!1387 = !{!1388, !1390}
!1388 = !DIDerivedType(tag: DW_TAG_member, name: "Sums", scope: !1331, file: !1271, line: 192, baseType: !1389, size: 64)
!1389 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1342, size: 64)
!1390 = !DIDerivedType(tag: DW_TAG_member, name: "Fl", scope: !1331, file: !1271, line: 192, baseType: !1391, size: 64, offset: 64)
!1391 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1191, size: 64)
!1392 = !{!1393}
!1393 = !DITemplateTypeParameter(name: "F", type: !1331)
!1394 = !DISubprogram(name: "scan_add<array_imap<unsigned long>, array_imap<unsigned long> >", linkageName: "_ZN4pbbs8scan_addI10array_imapImES2_EENT_1TES3_T0_j", scope: !811, file: !1271, line: 145, type: !1395, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1397, retainedNodes: !45)
!1395 = !DISubroutineType(types: !1396)
!1396 = !{!86, !1342, !1342, !18}
!1397 = !{!1398, !1399}
!1398 = !DITemplateTypeParameter(name: "Imap_In", type: !1342)
!1399 = !DITemplateTypeParameter(name: "Imap_Out", type: !1342)
!1400 = !DISubprogram(name: "new_array_no_init<unsigned int>", linkageName: "_ZN4pbbs17new_array_no_initIjEEPT_mb", scope: !811, file: !54, line: 438, type: !1401, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1241, retainedNodes: !45)
!1401 = !DISubroutineType(types: !1402)
!1402 = !{!1175, !86, !92}
!1403 = !DISubprogram(name: "sliced_for<(lambda at ./sequence.h:196:17)>", linkageName: "_ZN4pbbs10sliced_forIZNS_4packI7in_imapIjZNS_10pack_indexIjS2_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES8_EES9_INSA_1TEESA_SC_jEUlmmmE0_EEvmmRKSA_", scope: !811, file: !1271, line: 40, type: !1404, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1416, retainedNodes: !45)
!1404 = !DISubroutineType(types: !1405)
!1405 = !{null, !86, !86, !1406}
!1406 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1407, size: 64)
!1407 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1408)
!1408 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1332, file: !1271, line: 196, size: 256, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1409, identifier: "_ZTSZN4pbbs4packI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EES8_INS9_1TEES9_SB_jEUlmmmE0_")
!1409 = !{!1410, !1412, !1414, !1415}
!1410 = !DIDerivedType(tag: DW_TAG_member, name: "In", scope: !1408, file: !1271, line: 197, baseType: !1411, size: 64)
!1411 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1280, size: 64)
!1412 = !DIDerivedType(tag: DW_TAG_member, name: "Out", scope: !1408, file: !1271, line: 198, baseType: !1413, size: 64, offset: 64)
!1413 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1385, size: 64)
!1414 = !DIDerivedType(tag: DW_TAG_member, name: "Sums", scope: !1408, file: !1271, line: 198, baseType: !1389, size: 64, offset: 128)
!1415 = !DIDerivedType(tag: DW_TAG_member, name: "Fl", scope: !1408, file: !1271, line: 199, baseType: !1391, size: 64, offset: 192)
!1416 = !{!1417}
!1417 = !DITemplateTypeParameter(name: "F", type: !1408)
!1418 = !DISubprogram(name: "make_array_imap<unsigned int>", linkageName: "_Z15make_array_imapIjE10array_imapIT_EPS1_m", scope: !1188, file: !1188, line: 128, type: !1419, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1241, retainedNodes: !45)
!1419 = !DISubroutineType(types: !1420)
!1420 = !{!1205, !1175, !86}
!1421 = !DISubprogram(name: "sum_flags_serial<in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >", linkageName: "_ZN4pbbs16sum_flags_serialI7in_imapIbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEEmT_", scope: !811, file: !1271, line: 154, type: !1422, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1424, retainedNodes: !45)
!1422 = !DISubroutineType(types: !1423)
!1423 = !{!86, !1191}
!1424 = !{!1425}
!1425 = !DITemplateTypeParameter(name: "Index_Map", type: !1191)
!1426 = !DISubprogram(name: "new_array_no_init<unsigned long>", linkageName: "_ZN4pbbs17new_array_no_initImEEPT_mb", scope: !811, file: !54, line: 438, type: !1427, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1381, retainedNodes: !45)
!1427 = !DISubroutineType(types: !1428)
!1428 = !{!1345, !86, !92}
!1429 = !DISubprogram(name: "aligned_alloc", scope: !1430, file: !1430, line: 586, type: !1431, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !45)
!1430 = !DIFile(filename: "/usr/include/stdlib.h", directory: "")
!1431 = !DISubroutineType(types: !1432)
!1432 = !{!68, !86, !86}
!1433 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1434, file: !1271, line: 148, baseType: !1437)
!1434 = distinct !DISubprogram(name: "scan_add<array_imap<unsigned long>, array_imap<unsigned long> >", linkageName: "_ZN4pbbs8scan_addI10array_imapImES2_EENT_1TES3_T0_j", scope: !811, file: !1271, line: 145, type: !1435, scopeLine: 147, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1397, retainedNodes: !1438)
!1435 = !DISubroutineType(types: !1436)
!1436 = !{!1437, !1342, !1342, !1287}
!1437 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1342, file: !1188, line: 104, baseType: !86)
!1438 = !{!1439, !1440, !1441, !1442}
!1439 = !DILocalVariable(name: "In", arg: 1, scope: !1434, file: !1271, line: 145, type: !1342)
!1440 = !DILocalVariable(name: "Out", arg: 2, scope: !1434, file: !1271, line: 145, type: !1342)
!1441 = !DILocalVariable(name: "fl", arg: 3, scope: !1434, file: !1271, line: 145, type: !1287)
!1442 = !DILocalVariable(name: "add", scope: !1434, file: !1271, line: 149, type: !1443)
!1443 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1434, file: !1271, line: 149, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZN4pbbs8scan_addI10array_imapImES2_EENT_1TES3_T0_jEUlmmE_")
!1444 = !DISubprogram(name: "scan<array_imap<unsigned long>, array_imap<unsigned long>, (lambda at ./sequence.h:149:16)>", linkageName: "_ZN4pbbs4scanI10array_imapImES2_ZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_S6_RKT1_S5_j", scope: !811, file: !1271, line: 124, type: !1445, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1449, retainedNodes: !45)
!1445 = !DISubroutineType(types: !1446)
!1446 = !{!86, !1342, !1342, !1447, !86, !18}
!1447 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1448, size: 64)
!1448 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1443)
!1449 = !{!1398, !1399, !1450}
!1450 = !DITemplateTypeParameter(name: "F", type: !1443)
!1451 = !DISubprogram(name: "scan_serial<array_imap<unsigned long>, array_imap<unsigned long>, (lambda at ./sequence.h:149:16)>", linkageName: "_ZN4pbbs11scan_serialI10array_imapImES2_ZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_S6_RKT1_S5_j", scope: !811, file: !1271, line: 99, type: !1445, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1449, retainedNodes: !45)
!1452 = !DISubprogram(name: "sliced_for<(lambda at ./sequence.h:135:17)>", linkageName: "_ZN4pbbs10sliced_forIZNS_4scanI10array_imapImES3_ZNS_8scan_addIS3_S3_EENT_1TES5_T0_jEUlmmE_EES6_S5_S7_RKT1_S6_jEUlmmmE_EEvmmRKS5_", scope: !811, file: !1271, line: 40, type: !1453, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1476, retainedNodes: !45)
!1453 = !DISubroutineType(types: !1454)
!1454 = !{null, !86, !86, !1455}
!1455 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1456, size: 64)
!1456 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1457)
!1457 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1458, file: !1271, line: 135, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1472, identifier: "_ZTSZN4pbbs4scanI10array_imapImES2_ZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_S6_RKT1_S5_jEUlmmmE_")
!1458 = distinct !DISubprogram(name: "scan<array_imap<unsigned long>, array_imap<unsigned long>, (lambda at ./sequence.h:149:16)>", linkageName: "_ZN4pbbs4scanI10array_imapImES2_ZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_S6_RKT1_S5_j", scope: !811, file: !1271, line: 124, type: !1459, scopeLine: 127, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1449, retainedNodes: !1461)
!1459 = !DISubroutineType(types: !1460)
!1460 = !{!1437, !1342, !1342, !1447, !1437, !1287}
!1461 = !{!1462, !1463, !1464, !1465, !1466, !1467, !1468, !1469, !1470}
!1462 = !DILocalVariable(name: "In", arg: 1, scope: !1458, file: !1271, line: 124, type: !1342)
!1463 = !DILocalVariable(name: "Out", arg: 2, scope: !1458, file: !1271, line: 124, type: !1342)
!1464 = !DILocalVariable(name: "f", arg: 3, scope: !1458, file: !1271, line: 125, type: !1447)
!1465 = !DILocalVariable(name: "zero", arg: 4, scope: !1458, file: !1271, line: 125, type: !1437)
!1466 = !DILocalVariable(name: "fl", arg: 5, scope: !1458, file: !1271, line: 126, type: !1287)
!1467 = !DILocalVariable(name: "n", scope: !1458, file: !1271, line: 129, type: !779)
!1468 = !DILocalVariable(name: "l", scope: !1458, file: !1271, line: 130, type: !779)
!1469 = !DILocalVariable(name: "Sums", scope: !1458, file: !1271, line: 133, type: !1342)
!1470 = !DILocalVariable(name: "total", scope: !1458, file: !1271, line: 137, type: !1471)
!1471 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1458, file: !1271, line: 128, baseType: !1437)
!1472 = !{!1473, !1474, !1475}
!1473 = !DIDerivedType(tag: DW_TAG_member, name: "Sums", scope: !1457, file: !1271, line: 136, baseType: !1389, size: 64)
!1474 = !DIDerivedType(tag: DW_TAG_member, name: "In", scope: !1457, file: !1271, line: 136, baseType: !1389, size: 64, offset: 64)
!1475 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !1457, file: !1271, line: 136, baseType: !1447, size: 64, offset: 128)
!1476 = !{!1477}
!1477 = !DITemplateTypeParameter(name: "F", type: !1457)
!1478 = !DISubprogram(name: "sliced_for<(lambda at ./sequence.h:139:17)>", linkageName: "_ZN4pbbs10sliced_forIZNS_4scanI10array_imapImES3_ZNS_8scan_addIS3_S3_EENT_1TES5_T0_jEUlmmE_EES6_S5_S7_RKT1_S6_jEUlmmmE0_EEvmmRKS5_", scope: !811, file: !1271, line: 40, type: !1479, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1491, retainedNodes: !45)
!1479 = !DISubroutineType(types: !1480)
!1480 = !{null, !86, !86, !1481}
!1481 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1482, size: 64)
!1482 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1483)
!1483 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1458, file: !1271, line: 139, size: 320, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1484, identifier: "_ZTSZN4pbbs4scanI10array_imapImES2_ZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_S6_RKT1_S5_jEUlmmmE0_")
!1484 = !{!1485, !1486, !1487, !1488, !1489}
!1485 = !DIDerivedType(tag: DW_TAG_member, name: "In", scope: !1483, file: !1271, line: 140, baseType: !1389, size: 64)
!1486 = !DIDerivedType(tag: DW_TAG_member, name: "Out", scope: !1483, file: !1271, line: 140, baseType: !1389, size: 64, offset: 64)
!1487 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !1483, file: !1271, line: 140, baseType: !1447, size: 64, offset: 128)
!1488 = !DIDerivedType(tag: DW_TAG_member, name: "Sums", scope: !1483, file: !1271, line: 140, baseType: !1389, size: 64, offset: 192)
!1489 = !DIDerivedType(tag: DW_TAG_member, name: "fl", scope: !1483, file: !1271, line: 140, baseType: !1490, size: 64, offset: 256)
!1490 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1287, size: 64)
!1491 = !{!1492}
!1492 = !DITemplateTypeParameter(name: "F", type: !1483)
!1493 = !DISubprogram(name: "reduce_serial<array_imap<unsigned long>, (lambda at ./sequence.h:149:16)>", linkageName: "_ZN4pbbs13reduce_serialI10array_imapImEZNS_8scan_addIS2_S2_EENT_1TES4_T0_jEUlmmE_EES5_S4_RKS6_", scope: !811, file: !1271, line: 59, type: !1494, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1496, retainedNodes: !45)
!1494 = !DISubroutineType(types: !1495)
!1495 = !{!86, !1342, !1447}
!1496 = !{!1497, !1450}
!1497 = !DITemplateTypeParameter(name: "Index_Map", type: !1342)
!1498 = !DISubprogram(name: "pack_serial_at<in_imap<unsigned int, (lambda at ./sequence.h:205:21)>, in_imap<bool, (lambda at ./vertexSubset.h:199:16)> >", linkageName: "_ZN4pbbs14pack_serial_atI7in_imapIjZNS_10pack_indexIjS1_IbZN16vertexSubsetDataINS_5emptyEE8toSparseEvEUlmE_EEE10array_imapIT_ET0_jEUlmE_ES7_EEvS9_PNS9_1TESB_", scope: !811, file: !1271, line: 174, type: !1499, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1321, retainedNodes: !45)
!1499 = !DISubroutineType(types: !1500)
!1500 = !{null, !1280, !1175, !1191}
!1501 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getA<unsigned int, long>", scope: !55, file: !54, line: 98, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1502, templateParams: !1511, identifier: "_ZTSN8sequence4getAIjlEE")
!1502 = !{!1503, !1504, !1508}
!1503 = !DIDerivedType(tag: DW_TAG_member, name: "A", scope: !1501, file: !54, line: 99, baseType: !1175, size: 64)
!1504 = !DISubprogram(name: "getA", scope: !1501, file: !54, line: 100, type: !1505, scopeLine: 100, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1505 = !DISubroutineType(types: !1506)
!1506 = !{null, !1507, !1175}
!1507 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1501, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1508 = !DISubprogram(name: "operator()", linkageName: "_ZN8sequence4getAIjlEclEl", scope: !1501, file: !54, line: 101, type: !1509, scopeLine: 101, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1509 = !DISubroutineType(types: !1510)
!1510 = !{!18, !1507, !52}
!1511 = !{!1512, !60}
!1512 = !DITemplateTypeParameter(name: "ET", type: !18)
!1513 = !DISubprogram(name: "reduce<unsigned int, long, addF<unsigned int>, sequence::getA<unsigned int, long> >", linkageName: "_ZN8sequence6reduceIjl4addFIjENS_4getAIjlEEEET_T0_S6_T1_T2_", scope: !55, file: !54, line: 134, type: !1514, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1523, retainedNodes: !45)
!1514 = !DISubroutineType(types: !1515)
!1515 = !{!18, !52, !52, !1516, !1501}
!1516 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "addF<unsigned int>", file: !54, line: 51, size: 8, flags: DIFlagTypePassByValue, elements: !1517, templateParams: !1241, identifier: "_ZTS4addFIjE")
!1517 = !{!1518}
!1518 = !DISubprogram(name: "operator()", linkageName: "_ZNK4addFIjEclERKjS2_", scope: !1516, file: !54, line: 51, type: !1519, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1519 = !DISubroutineType(types: !1520)
!1520 = !{!18, !1521, !907, !907}
!1521 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1522, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1522 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1516)
!1523 = !{!1177, !60, !1524, !1525}
!1524 = !DITemplateTypeParameter(name: "F", type: !1516)
!1525 = !DITemplateTypeParameter(name: "G", type: !1501)
!1526 = !DISubprogram(name: "reduceSerial<unsigned int, long, addF<unsigned int>, sequence::getA<unsigned int, long> >", linkageName: "_ZN8sequence12reduceSerialIjl4addFIjENS_4getAIjlEEEET_T0_S6_T1_T2_", scope: !55, file: !54, line: 127, type: !1514, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1523, retainedNodes: !45)
!1527 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1528, size: 64)
!1528 = !DIDerivedType(tag: DW_TAG_typedef, name: "D", scope: !1529, file: !192, line: 86, baseType: !1016)
!1529 = distinct !DISubprogram(name: "edgeMapDenseForward<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z19edgeMapDenseForwardIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 85, type: !1530, scopeLine: 85, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1171, retainedNodes: !1534)
!1530 = !DISubroutineType(types: !1531)
!1531 = !{!771, !116, !1164, !1181, !1532}
!1532 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1533)
!1533 = !DIDerivedType(tag: DW_TAG_typedef, name: "flags", file: !192, line: 48, baseType: !1288)
!1534 = !{!1535, !1536, !1537, !1538, !1539, !1540, !1541, !1544, !1549, !1551, !1552, !1553, !1554, !1556, !1558, !1559, !1560, !1561, !1563, !1566, !1568, !1569, !1570, !1571}
!1535 = !DILocalVariable(name: "GA", arg: 1, scope: !1529, file: !192, line: 85, type: !116)
!1536 = !DILocalVariable(name: "vertexSubset", arg: 2, scope: !1529, file: !192, line: 85, type: !1164)
!1537 = !DILocalVariable(name: "f", arg: 3, scope: !1529, file: !192, line: 85, type: !1181)
!1538 = !DILocalVariable(name: "fl", arg: 4, scope: !1529, file: !192, line: 85, type: !1532)
!1539 = !DILocalVariable(name: "n", scope: !1529, file: !192, line: 87, type: !52)
!1540 = !DILocalVariable(name: "G", scope: !1529, file: !192, line: 88, type: !120)
!1541 = !DILocalVariable(name: "next", scope: !1542, file: !192, line: 90, type: !1527)
!1542 = distinct !DILexicalBlock(scope: !1543, file: !192, line: 89, column: 26)
!1543 = distinct !DILexicalBlock(scope: !1529, file: !192, line: 89, column: 7)
!1544 = !DILocalVariable(name: "g", scope: !1542, file: !192, line: 91, type: !1545)
!1545 = distinct !DICompositeType(tag: DW_TAG_class_type, file: !1546, line: 30, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1547, identifier: "_ZTSZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_")
!1546 = !DIFile(filename: "./edgeMap_utils.h", directory: "/data/compilers/tests/ligra/apps")
!1547 = !{!1548}
!1548 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !1545, file: !1546, line: 30, baseType: !1015, size: 64)
!1549 = !DILocalVariable(name: "__init", scope: !1550, type: !52, flags: DIFlagArtificial)
!1550 = distinct !DILexicalBlock(scope: !1542, file: !192, line: 92, column: 5)
!1551 = !DILocalVariable(name: "__limit", scope: !1550, type: !52, flags: DIFlagArtificial)
!1552 = !DILocalVariable(name: "__begin", scope: !1550, type: !52, flags: DIFlagArtificial)
!1553 = !DILocalVariable(name: "__end", scope: !1550, type: !52, flags: DIFlagArtificial)
!1554 = !DILocalVariable(name: "i", scope: !1555, file: !192, line: 92, type: !52)
!1555 = distinct !DILexicalBlock(scope: !1550, file: !192, line: 92, column: 5)
!1556 = !DILocalVariable(name: "__init", scope: !1557, type: !52, flags: DIFlagArtificial)
!1557 = distinct !DILexicalBlock(scope: !1542, file: !192, line: 93, column: 5)
!1558 = !DILocalVariable(name: "__limit", scope: !1557, type: !52, flags: DIFlagArtificial)
!1559 = !DILocalVariable(name: "__begin", scope: !1557, type: !52, flags: DIFlagArtificial)
!1560 = !DILocalVariable(name: "__end", scope: !1557, type: !52, flags: DIFlagArtificial)
!1561 = !DILocalVariable(name: "i", scope: !1562, file: !192, line: 93, type: !52)
!1562 = distinct !DILexicalBlock(scope: !1557, file: !192, line: 93, column: 5)
!1563 = !DILocalVariable(name: "g", scope: !1564, file: !192, line: 100, type: !1565)
!1564 = distinct !DILexicalBlock(scope: !1543, file: !192, line: 99, column: 10)
!1565 = distinct !DICompositeType(tag: DW_TAG_class_type, file: !1546, line: 124, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_")
!1566 = !DILocalVariable(name: "__init", scope: !1567, type: !52, flags: DIFlagArtificial)
!1567 = distinct !DILexicalBlock(scope: !1564, file: !192, line: 101, column: 5)
!1568 = !DILocalVariable(name: "__limit", scope: !1567, type: !52, flags: DIFlagArtificial)
!1569 = !DILocalVariable(name: "__begin", scope: !1567, type: !52, flags: DIFlagArtificial)
!1570 = !DILocalVariable(name: "__end", scope: !1567, type: !52, flags: DIFlagArtificial)
!1571 = !DILocalVariable(name: "i", scope: !1572, file: !192, line: 101, type: !52)
!1572 = distinct !DILexicalBlock(scope: !1567, file: !192, line: 101, column: 5)
!1573 = !DISubprogram(name: "get_emdense_forward_gen<pbbs::empty, 0>", linkageName: "_Z23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EE", scope: !1546, file: !1546, line: 29, type: !1574, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1576, retainedNodes: !45)
!1574 = !DISubroutineType(types: !1575)
!1575 = !{!1545, !1015}
!1576 = !{!1163, !1577}
!1577 = !DITemplateValueParameter(type: !6, value: i32 0)
!1578 = !DISubprogram(name: "get_emdense_forward_nooutput_gen<pbbs::empty, 0>", linkageName: "_Z32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDav", scope: !1546, file: !1546, line: 123, type: !1579, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1576, retainedNodes: !45)
!1579 = !DISubroutineType(types: !1580)
!1580 = !{!1565}
!1581 = !DISubprogram(name: "make_in_imap<unsigned long, (lambda at ./vertexSubset.h:151:42)>", linkageName: "_Z12make_in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_E7in_imapIT_T0_EmSA_", scope: !1188, file: !1188, line: 59, type: !1582, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1621, retainedNodes: !45)
!1582 = !DISubroutineType(types: !1583)
!1583 = !{!1584, !86, !1587}
!1584 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_imap<unsigned long, (lambda at ./vertexSubset.h:151:42)>", file: !1188, line: 44, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1585, templateParams: !1621, identifier: "_ZTS7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_E")
!1585 = !{!1586, !1600, !1601, !1602, !1606, !1609, !1613, !1614, !1617, !1618}
!1586 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !1584, file: !1188, line: 46, baseType: !1587, size: 64)
!1587 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1588, file: !772, line: 151, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1597, identifier: "_ZTSZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS1_EEEUlmE_")
!1588 = distinct !DISubprogram(name: "vertexSubsetData", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEEC2ElPSt5tupleIJbS1_EE", scope: !771, file: !772, line: 149, type: !1013, scopeLine: 150, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !1012, retainedNodes: !1589)
!1589 = !{!1590, !1591, !1592, !1593, !1595}
!1590 = !DILocalVariable(name: "this", arg: 1, scope: !1588, type: !1198, flags: DIFlagArtificial | DIFlagObjectPointer)
!1591 = !DILocalVariable(name: "_n", arg: 2, scope: !1588, file: !772, line: 149, type: !52)
!1592 = !DILocalVariable(name: "_d", arg: 3, scope: !1588, file: !772, line: 149, type: !1015)
!1593 = !DILocalVariable(name: "d_map", scope: !1594, file: !772, line: 151, type: !1584)
!1594 = distinct !DILexicalBlock(scope: !1588, file: !772, line: 150, column: 47)
!1595 = !DILocalVariable(name: "f", scope: !1594, file: !772, line: 152, type: !1596)
!1596 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1588, file: !772, line: 152, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS1_EEEUlmmE_")
!1597 = !{!1598}
!1598 = !DIDerivedType(tag: DW_TAG_member, name: "_d", scope: !1587, file: !772, line: 151, baseType: !1599, size: 64)
!1599 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1015, size: 64)
!1600 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !1584, file: !1188, line: 47, baseType: !779, size: 64, offset: 64)
!1601 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !1584, file: !1188, line: 47, baseType: !779, size: 64, offset: 128)
!1602 = !DISubprogram(name: "in_imap", scope: !1584, file: !1188, line: 48, type: !1603, scopeLine: 48, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1603 = !DISubroutineType(types: !1604)
!1604 = !{null, !1605, !779, !1587}
!1605 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1584, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1606 = !DISubprogram(name: "in_imap", scope: !1584, file: !1188, line: 49, type: !1607, scopeLine: 49, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1607 = !DISubroutineType(types: !1608)
!1608 = !{null, !1605, !779, !779, !1587}
!1609 = !DISubprogram(name: "operator[]", linkageName: "_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_EixEm", scope: !1584, file: !1188, line: 50, type: !1610, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1610 = !DISubroutineType(types: !1611)
!1611 = !{!1612, !1605, !1225}
!1612 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1584, file: !1188, line: 45, baseType: !86)
!1613 = !DISubprogram(name: "operator()", linkageName: "_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_EclEm", scope: !1584, file: !1188, line: 51, type: !1610, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1614 = !DISubprogram(name: "cut", linkageName: "_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_E3cutEmm", scope: !1584, file: !1188, line: 52, type: !1615, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1615 = !DISubroutineType(types: !1616)
!1616 = !{!1584, !1605, !779, !779}
!1617 = !DISubprogram(name: "slice", linkageName: "_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_E5sliceEmm", scope: !1584, file: !1188, line: 53, type: !1615, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1618 = !DISubprogram(name: "size", linkageName: "_ZN7in_imapImZN16vertexSubsetDataIN4pbbs5emptyEEC1ElPSt5tupleIJbS2_EEEUlmE_E4sizeEv", scope: !1584, file: !1188, line: 54, type: !1619, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1619 = !DISubroutineType(types: !1620)
!1620 = !{!779, !1605}
!1621 = !{!1382, !1622}
!1622 = !DITemplateTypeParameter(name: "F", type: !1587)
!1623 = !DISubprogram(name: "reduce<in_imap<unsigned long, (lambda at ./vertexSubset.h:151:42)>, (lambda at ./vertexSubset.h:152:14)>", linkageName: "_ZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS3_EEEUlmE_EZNS4_C1ElS7_EUlmmE_EENT_1TESB_RKT0_j", scope: !811, file: !1271, line: 68, type: !1624, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1628, retainedNodes: !45)
!1624 = !DISubroutineType(types: !1625)
!1625 = !{!86, !1584, !1626, !18}
!1626 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1627, size: 64)
!1627 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1596)
!1628 = !{!1629, !1630}
!1629 = !DITemplateTypeParameter(name: "Index_Map", type: !1584)
!1630 = !DITemplateTypeParameter(name: "F", type: !1596)
!1631 = !DISubprogram(name: "reduce_serial<in_imap<unsigned long, (lambda at ./vertexSubset.h:151:42)>, (lambda at ./vertexSubset.h:152:14)>", linkageName: "_ZN4pbbs13reduce_serialI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS3_EEEUlmE_EZNS4_C1ElS7_EUlmmE_EENT_1TESB_RKT0_", scope: !811, file: !1271, line: 59, type: !1632, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1628, retainedNodes: !45)
!1632 = !DISubroutineType(types: !1633)
!1633 = !{!86, !1584, !1626}
!1634 = !DISubprogram(name: "sliced_for<(lambda at ./sequence.h:78:17)>", linkageName: "_ZN4pbbs10sliced_forIZNS_6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS4_EEEUlmE_EZNS5_C1ElS8_EUlmmE_EENT_1TESC_RKT0_jEUlmmmE_EEvmmRKSC_", scope: !811, file: !1271, line: 40, type: !1635, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1657, retainedNodes: !45)
!1635 = !DISubroutineType(types: !1636)
!1636 = !{null, !86, !86, !1637}
!1637 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1638, size: 64)
!1638 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1639)
!1639 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1640, file: !1271, line: 78, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1652, identifier: "_ZTSZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS3_EEEUlmE_EZNS4_C1ElS7_EUlmmE_EENT_1TESB_RKT0_jEUlmmmE_")
!1640 = distinct !DISubprogram(name: "reduce<in_imap<unsigned long, (lambda at ./vertexSubset.h:151:42)>, (lambda at ./vertexSubset.h:152:14)>", linkageName: "_ZN4pbbs6reduceI7in_imapImZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS3_EEEUlmE_EZNS4_C1ElS7_EUlmmE_EENT_1TESB_RKT0_j", scope: !811, file: !1271, line: 68, type: !1641, scopeLine: 70, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1628, retainedNodes: !1643)
!1641 = !DISubroutineType(types: !1642)
!1642 = !{!1612, !1584, !1626, !1287}
!1643 = !{!1644, !1645, !1646, !1647, !1648, !1649, !1650}
!1644 = !DILocalVariable(name: "A", arg: 1, scope: !1640, file: !1271, line: 68, type: !1584)
!1645 = !DILocalVariable(name: "f", arg: 2, scope: !1640, file: !1271, line: 68, type: !1626)
!1646 = !DILocalVariable(name: "fl", arg: 3, scope: !1640, file: !1271, line: 68, type: !1287)
!1647 = !DILocalVariable(name: "n", scope: !1640, file: !1271, line: 72, type: !779)
!1648 = !DILocalVariable(name: "l", scope: !1640, file: !1271, line: 73, type: !779)
!1649 = !DILocalVariable(name: "Sums", scope: !1640, file: !1271, line: 76, type: !1342)
!1650 = !DILocalVariable(name: "r", scope: !1640, file: !1271, line: 80, type: !1651)
!1651 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1640, file: !1271, line: 71, baseType: !1612)
!1652 = !{!1653, !1654, !1656}
!1653 = !DIDerivedType(tag: DW_TAG_member, name: "Sums", scope: !1639, file: !1271, line: 79, baseType: !1389, size: 64)
!1654 = !DIDerivedType(tag: DW_TAG_member, name: "A", scope: !1639, file: !1271, line: 79, baseType: !1655, size: 64, offset: 64)
!1655 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1584, size: 64)
!1656 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !1639, file: !1271, line: 79, baseType: !1626, size: 64, offset: 128)
!1657 = !{!1658}
!1658 = !DITemplateTypeParameter(name: "F", type: !1639)
!1659 = !DISubprogram(name: "reduce_serial<array_imap<unsigned long>, (lambda at ./vertexSubset.h:152:14)>", linkageName: "_ZN4pbbs13reduce_serialI10array_imapImEZN16vertexSubsetDataINS_5emptyEEC1ElPSt5tupleIJbS4_EEEUlmmE_EENT_1TESA_RKT0_", scope: !811, file: !1271, line: 59, type: !1660, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1662, retainedNodes: !45)
!1660 = !DISubroutineType(types: !1661)
!1661 = !{!86, !1342, !1626}
!1662 = !{!1497, !1630}
!1663 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1664, size: 64)
!1664 = !DIDerivedType(tag: DW_TAG_typedef, name: "D", scope: !1665, file: !192, line: 60, baseType: !1016)
!1665 = distinct !DISubprogram(name: "edgeMapDense<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z12edgeMapDenseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 59, type: !1530, scopeLine: 59, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1171, retainedNodes: !1666)
!1666 = !{!1667, !1668, !1669, !1670, !1671, !1672, !1673, !1676, !1680, !1682, !1683, !1684, !1685, !1687, !1690, !1692, !1693, !1694, !1695}
!1667 = !DILocalVariable(name: "GA", arg: 1, scope: !1665, file: !192, line: 59, type: !116)
!1668 = !DILocalVariable(name: "vertexSubset", arg: 2, scope: !1665, file: !192, line: 59, type: !1164)
!1669 = !DILocalVariable(name: "f", arg: 3, scope: !1665, file: !192, line: 59, type: !1181)
!1670 = !DILocalVariable(name: "fl", arg: 4, scope: !1665, file: !192, line: 59, type: !1532)
!1671 = !DILocalVariable(name: "n", scope: !1665, file: !192, line: 61, type: !52)
!1672 = !DILocalVariable(name: "G", scope: !1665, file: !192, line: 62, type: !120)
!1673 = !DILocalVariable(name: "next", scope: !1674, file: !192, line: 64, type: !1663)
!1674 = distinct !DILexicalBlock(scope: !1675, file: !192, line: 63, column: 26)
!1675 = distinct !DILexicalBlock(scope: !1665, file: !192, line: 63, column: 7)
!1676 = !DILocalVariable(name: "g", scope: !1674, file: !192, line: 65, type: !1677)
!1677 = distinct !DICompositeType(tag: DW_TAG_class_type, file: !1546, line: 15, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1678, identifier: "_ZTSZ15get_emdense_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_")
!1678 = !{!1679}
!1679 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !1677, file: !1546, line: 15, baseType: !1015, size: 64)
!1680 = !DILocalVariable(name: "__init", scope: !1681, type: !52, flags: DIFlagArtificial)
!1681 = distinct !DILexicalBlock(scope: !1674, file: !192, line: 66, column: 5)
!1682 = !DILocalVariable(name: "__limit", scope: !1681, type: !52, flags: DIFlagArtificial)
!1683 = !DILocalVariable(name: "__begin", scope: !1681, type: !52, flags: DIFlagArtificial)
!1684 = !DILocalVariable(name: "__end", scope: !1681, type: !52, flags: DIFlagArtificial)
!1685 = !DILocalVariable(name: "v", scope: !1686, file: !192, line: 66, type: !52)
!1686 = distinct !DILexicalBlock(scope: !1681, file: !192, line: 66, column: 5)
!1687 = !DILocalVariable(name: "g", scope: !1688, file: !192, line: 74, type: !1689)
!1688 = distinct !DILexicalBlock(scope: !1675, file: !192, line: 73, column: 10)
!1689 = distinct !DICompositeType(tag: DW_TAG_class_type, file: !1546, line: 112, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ24get_emdense_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_")
!1690 = !DILocalVariable(name: "__init", scope: !1691, type: !52, flags: DIFlagArtificial)
!1691 = distinct !DILexicalBlock(scope: !1688, file: !192, line: 75, column: 5)
!1692 = !DILocalVariable(name: "__limit", scope: !1691, type: !52, flags: DIFlagArtificial)
!1693 = !DILocalVariable(name: "__begin", scope: !1691, type: !52, flags: DIFlagArtificial)
!1694 = !DILocalVariable(name: "__end", scope: !1691, type: !52, flags: DIFlagArtificial)
!1695 = !DILocalVariable(name: "v", scope: !1696, file: !192, line: 75, type: !52)
!1696 = distinct !DILexicalBlock(scope: !1691, file: !192, line: 75, column: 5)
!1697 = !DISubprogram(name: "get_emdense_gen<pbbs::empty, 0>", linkageName: "_Z15get_emdense_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EE", scope: !1546, file: !1546, line: 14, type: !1698, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1576, retainedNodes: !45)
!1698 = !DISubroutineType(types: !1699)
!1699 = !{!1677, !1015}
!1700 = !DISubprogram(name: "get_emdense_nooutput_gen<pbbs::empty, 0>", linkageName: "_Z24get_emdense_nooutput_genIN4pbbs5emptyELi0EEDav", scope: !1546, file: !1546, line: 111, type: !1701, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1576, retainedNodes: !45)
!1701 = !DISubroutineType(types: !1702)
!1702 = !{!1689}
!1703 = !DISubprogram(name: "plusScan<unsigned int, unsigned int>", linkageName: "_ZN8sequence8plusScanIjjEET_PS1_S2_T0_", scope: !55, file: !54, line: 229, type: !1704, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1706, retainedNodes: !45)
!1704 = !DISubroutineType(types: !1705)
!1705 = !{!18, !1175, !1175, !18}
!1706 = !{!1512, !1707}
!1707 = !DITemplateTypeParameter(name: "intT", type: !18)
!1708 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1709, size: 64)
!1709 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !1710, file: !192, line: 160, baseType: !797)
!1710 = distinct !DISubprogram(name: "edgeMapSparse_no_filter<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 157, type: !1711, scopeLine: 159, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1171, retainedNodes: !1713)
!1711 = !DISubroutineType(types: !1712)
!1712 = !{!771, !195, !120, !1164, !753, !126, !1181, !1532}
!1713 = !{!1714, !1715, !1716, !1717, !1718, !1719, !1720, !1721, !1722, !1723, !1724, !1728, !1729, !1730, !1731, !1733, !1764, !1766, !1768, !1769, !1770, !1771, !1773, !1775, !1777, !1778, !1779, !1780, !1782, !1786, !1787, !1788, !1789, !1791, !1794, !1795, !1796, !1797, !1799, !1800, !1801, !1802, !1804, !1808, !1809, !1810, !1811, !1813, !1819, !1820, !1821, !1822, !1824, !1834, !1835, !1837}
!1714 = !DILocalVariable(name: "GA", arg: 1, scope: !1710, file: !192, line: 157, type: !195)
!1715 = !DILocalVariable(name: "frontierVertices", arg: 2, scope: !1710, file: !192, line: 158, type: !120)
!1716 = !DILocalVariable(name: "indices", arg: 3, scope: !1710, file: !192, line: 158, type: !1164)
!1717 = !DILocalVariable(name: "offsets", arg: 4, scope: !1710, file: !192, line: 158, type: !753)
!1718 = !DILocalVariable(name: "m", arg: 5, scope: !1710, file: !192, line: 158, type: !126)
!1719 = !DILocalVariable(name: "f", arg: 6, scope: !1710, file: !192, line: 158, type: !1181)
!1720 = !DILocalVariable(name: "fl", arg: 7, scope: !1710, file: !192, line: 159, type: !1532)
!1721 = !DILocalVariable(name: "n", scope: !1710, file: !192, line: 161, type: !52)
!1722 = !DILocalVariable(name: "outEdgeCount", scope: !1710, file: !192, line: 162, type: !52)
!1723 = !DILocalVariable(name: "outEdges", scope: !1710, file: !192, line: 163, type: !1708)
!1724 = !DILocalVariable(name: "g", scope: !1710, file: !192, line: 165, type: !1725)
!1725 = distinct !DICompositeType(tag: DW_TAG_class_type, file: !1546, line: 72, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1726, identifier: "_ZTSZ26get_emsparse_no_filter_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_")
!1726 = !{!1727}
!1727 = !DIDerivedType(tag: DW_TAG_member, name: "outEdges", scope: !1725, file: !1546, line: 72, baseType: !796, size: 64)
!1728 = !DILocalVariable(name: "b_size", scope: !1710, file: !192, line: 168, type: !779)
!1729 = !DILocalVariable(name: "n_blocks", scope: !1710, file: !192, line: 169, type: !779)
!1730 = !DILocalVariable(name: "cts", scope: !1710, file: !192, line: 171, type: !49)
!1731 = !DILocalVariable(name: "block_offs", scope: !1710, file: !192, line: 172, type: !1732)
!1732 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !779, size: 64)
!1733 = !DILocalVariable(name: "offsets_m", scope: !1710, file: !192, line: 174, type: !1734)
!1734 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_imap<unsigned int, (lambda at ./ligra.h:174:43)>", file: !1188, line: 44, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1735, templateParams: !1762, identifier: "_ZTS7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E")
!1735 = !{!1736, !1741, !1742, !1743, !1747, !1750, !1754, !1755, !1758, !1759}
!1736 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !1734, file: !1188, line: 46, baseType: !1737, size: 64)
!1737 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1710, file: !192, line: 174, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1738, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE_")
!1738 = !{!1739}
!1739 = !DIDerivedType(tag: DW_TAG_member, name: "offsets", scope: !1737, file: !192, line: 174, baseType: !1740, size: 64)
!1740 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !753, size: 64)
!1741 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !1734, file: !1188, line: 47, baseType: !779, size: 64, offset: 64)
!1742 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !1734, file: !1188, line: 47, baseType: !779, size: 64, offset: 128)
!1743 = !DISubprogram(name: "in_imap", scope: !1734, file: !1188, line: 48, type: !1744, scopeLine: 48, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1744 = !DISubroutineType(types: !1745)
!1745 = !{null, !1746, !779, !1737}
!1746 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1734, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1747 = !DISubprogram(name: "in_imap", scope: !1734, file: !1188, line: 49, type: !1748, scopeLine: 49, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1748 = !DISubroutineType(types: !1749)
!1749 = !{null, !1746, !779, !779, !1737}
!1750 = !DISubprogram(name: "operator[]", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EixEm", scope: !1734, file: !1188, line: 50, type: !1751, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1751 = !DISubroutineType(types: !1752)
!1752 = !{!1753, !1746, !1225}
!1753 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !1734, file: !1188, line: 45, baseType: !18)
!1754 = !DISubprogram(name: "operator()", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EclEm", scope: !1734, file: !1188, line: 51, type: !1751, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1755 = !DISubprogram(name: "cut", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E3cutEmm", scope: !1734, file: !1188, line: 52, type: !1756, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1756 = !DISubroutineType(types: !1757)
!1757 = !{!1734, !1746, !779, !779}
!1758 = !DISubprogram(name: "slice", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E5sliceEmm", scope: !1734, file: !1188, line: 53, type: !1756, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1759 = !DISubprogram(name: "size", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E4sizeEv", scope: !1734, file: !1188, line: 54, type: !1760, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1760 = !DISubroutineType(types: !1761)
!1761 = !{!779, !1746}
!1762 = !{!1242, !1763}
!1763 = !DITemplateTypeParameter(name: "F", type: !1737)
!1764 = !DILocalVariable(name: "lt", scope: !1710, file: !192, line: 175, type: !1765)
!1765 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1710, file: !192, line: 175, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRKjSJ_E_")
!1766 = !DILocalVariable(name: "__init", scope: !1767, type: !779, flags: DIFlagArtificial)
!1767 = distinct !DILexicalBlock(scope: !1710, file: !192, line: 176, column: 3)
!1768 = !DILocalVariable(name: "__limit", scope: !1767, type: !779, flags: DIFlagArtificial)
!1769 = !DILocalVariable(name: "__begin", scope: !1767, type: !779, flags: DIFlagArtificial)
!1770 = !DILocalVariable(name: "__end", scope: !1767, type: !779, flags: DIFlagArtificial)
!1771 = !DILocalVariable(name: "i", scope: !1772, file: !192, line: 176, type: !779)
!1772 = distinct !DILexicalBlock(scope: !1767, file: !192, line: 176, column: 3)
!1773 = !DILocalVariable(name: "s_val", scope: !1774, file: !192, line: 177, type: !779)
!1774 = distinct !DILexicalBlock(scope: !1772, file: !192, line: 176, column: 45)
!1775 = !DILocalVariable(name: "__init", scope: !1776, type: !779, flags: DIFlagArtificial)
!1776 = distinct !DILexicalBlock(scope: !1710, file: !192, line: 181, column: 3)
!1777 = !DILocalVariable(name: "__limit", scope: !1776, type: !779, flags: DIFlagArtificial)
!1778 = !DILocalVariable(name: "__begin", scope: !1776, type: !779, flags: DIFlagArtificial)
!1779 = !DILocalVariable(name: "__end", scope: !1776, type: !779, flags: DIFlagArtificial)
!1780 = !DILocalVariable(name: "i", scope: !1781, file: !192, line: 181, type: !779)
!1781 = distinct !DILexicalBlock(scope: !1776, file: !192, line: 181, column: 3)
!1782 = !DILocalVariable(name: "start", scope: !1783, file: !192, line: 184, type: !779)
!1783 = distinct !DILexicalBlock(scope: !1784, file: !192, line: 182, column: 64)
!1784 = distinct !DILexicalBlock(scope: !1785, file: !192, line: 182, column: 9)
!1785 = distinct !DILexicalBlock(scope: !1781, file: !192, line: 181, column: 46)
!1786 = !DILocalVariable(name: "end", scope: !1783, file: !192, line: 185, type: !779)
!1787 = !DILocalVariable(name: "start_o", scope: !1783, file: !192, line: 186, type: !126)
!1788 = !DILocalVariable(name: "k", scope: !1783, file: !192, line: 187, type: !126)
!1789 = !DILocalVariable(name: "j", scope: !1790, file: !192, line: 188, type: !779)
!1790 = distinct !DILexicalBlock(scope: !1783, file: !192, line: 188, column: 7)
!1791 = !DILocalVariable(name: "v", scope: !1792, file: !192, line: 189, type: !50)
!1792 = distinct !DILexicalBlock(scope: !1793, file: !192, line: 188, column: 40)
!1793 = distinct !DILexicalBlock(scope: !1790, file: !192, line: 188, column: 7)
!1794 = !DILocalVariable(name: "num_in", scope: !1792, file: !192, line: 190, type: !779)
!1795 = !DILocalVariable(name: "outSize", scope: !1710, file: !192, line: 199, type: !52)
!1796 = !DILocalVariable(name: "out", scope: !1710, file: !192, line: 202, type: !1708)
!1797 = !DILocalVariable(name: "__init", scope: !1798, type: !779, flags: DIFlagArtificial)
!1798 = distinct !DILexicalBlock(scope: !1710, file: !192, line: 204, column: 3)
!1799 = !DILocalVariable(name: "__limit", scope: !1798, type: !779, flags: DIFlagArtificial)
!1800 = !DILocalVariable(name: "__begin", scope: !1798, type: !779, flags: DIFlagArtificial)
!1801 = !DILocalVariable(name: "__end", scope: !1798, type: !779, flags: DIFlagArtificial)
!1802 = !DILocalVariable(name: "i", scope: !1803, file: !192, line: 204, type: !779)
!1803 = distinct !DILexicalBlock(scope: !1798, file: !192, line: 204, column: 3)
!1804 = !DILocalVariable(name: "start", scope: !1805, file: !192, line: 206, type: !779)
!1805 = distinct !DILexicalBlock(scope: !1806, file: !192, line: 205, column: 64)
!1806 = distinct !DILexicalBlock(scope: !1807, file: !192, line: 205, column: 9)
!1807 = distinct !DILexicalBlock(scope: !1803, file: !192, line: 204, column: 46)
!1808 = !DILocalVariable(name: "start_o", scope: !1805, file: !192, line: 207, type: !779)
!1809 = !DILocalVariable(name: "out_off", scope: !1805, file: !192, line: 208, type: !779)
!1810 = !DILocalVariable(name: "block_size", scope: !1805, file: !192, line: 209, type: !779)
!1811 = !DILocalVariable(name: "j", scope: !1812, file: !192, line: 210, type: !779)
!1812 = distinct !DILexicalBlock(scope: !1805, file: !192, line: 210, column: 7)
!1813 = !DILocalVariable(name: "__init", scope: !1814, type: !779, flags: DIFlagArtificial)
!1814 = distinct !DILexicalBlock(scope: !1815, file: !192, line: 220, column: 7)
!1815 = distinct !DILexicalBlock(scope: !1816, file: !192, line: 218, column: 27)
!1816 = distinct !DILexicalBlock(scope: !1817, file: !192, line: 218, column: 9)
!1817 = distinct !DILexicalBlock(scope: !1818, file: !192, line: 217, column: 31)
!1818 = distinct !DILexicalBlock(scope: !1710, file: !192, line: 217, column: 7)
!1819 = !DILocalVariable(name: "__limit", scope: !1814, type: !779, flags: DIFlagArtificial)
!1820 = !DILocalVariable(name: "__begin", scope: !1814, type: !779, flags: DIFlagArtificial)
!1821 = !DILocalVariable(name: "__end", scope: !1814, type: !779, flags: DIFlagArtificial)
!1822 = !DILocalVariable(name: "i", scope: !1823, file: !192, line: 220, type: !779)
!1823 = distinct !DILexicalBlock(scope: !1814, file: !192, line: 220, column: 7)
!1824 = !DILocalVariable(name: "get_key", scope: !1817, file: !192, line: 222, type: !1825)
!1825 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1710, file: !192, line: 222, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1826, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE0_")
!1826 = !{!1827, !1829}
!1827 = !DIDerivedType(tag: DW_TAG_member, name: "out", scope: !1825, file: !192, line: 222, baseType: !1828, size: 64)
!1828 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1708, size: 64)
!1829 = !DISubprogram(name: "operator()", scope: !1825, file: !192, line: 222, type: !1830, scopeLine: 222, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1830 = !DISubroutineType(types: !1831)
!1831 = !{!1136, !1832, !779}
!1832 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1833, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1833 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1825)
!1834 = !DILocalVariable(name: "nextIndices", scope: !1817, file: !192, line: 224, type: !1708)
!1835 = !DILocalVariable(name: "p", scope: !1817, file: !192, line: 225, type: !1836)
!1836 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1710, file: !192, line: 225, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRSt5tupleIJjS1_EEE_")
!1837 = !DILocalVariable(name: "nextM", scope: !1817, file: !192, line: 226, type: !779)
!1838 = !DISubprogram(name: "get_emsparse_no_filter_gen<pbbs::empty, 0>", linkageName: "_Z26get_emsparse_no_filter_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EE", scope: !1546, file: !1546, line: 71, type: !1839, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1576, retainedNodes: !45)
!1839 = !DISubroutineType(types: !1840)
!1840 = !{!1725, !796}
!1841 = !DISubprogram(name: "make_in_imap<unsigned int, (lambda at ./ligra.h:174:43)>", linkageName: "_Z12make_in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E7in_imapIS7_SA_EmSA_", scope: !1188, file: !1188, line: 59, type: !1842, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1762, retainedNodes: !45)
!1842 = !DISubroutineType(types: !1843)
!1843 = !{!1734, !86, !1737}
!1844 = !DISubprogram(name: "binary_search<in_imap<unsigned int, (lambda at ./ligra.h:174:43)>, (lambda at ./ligra.h:175:13)>", linkageName: "_ZN4pbbs13binary_searchI7in_imapIjZ23edgeMapSparse_no_filterINS_5emptyE25compressedSymmetricVertex16vertexSubsetDataIS3_E5BFS_FES5_IT_ER5graphIT0_EPSB_RT1_PjjRT2_jEUlmE_EZS2_IS3_S4_S6_S7_ES9_SD_SE_SG_SH_jSJ_jEUlRKjSN_E_EEmS8_NS8_1TERKSB_", scope: !811, file: !1845, line: 18, type: !1846, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1850, retainedNodes: !45)
!1845 = !DIFile(filename: "./binary_search.h", directory: "/data/compilers/tests/ligra/apps")
!1846 = !DISubroutineType(types: !1847)
!1847 = !{!86, !1734, !18, !1848}
!1848 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1849, size: 64)
!1849 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1765)
!1850 = !{!1851, !1852}
!1851 = !DITemplateTypeParameter(name: "Sequence", type: !1734)
!1852 = !DITemplateTypeParameter(name: "F", type: !1765)
!1853 = !DISubprogram(name: "plusScan<unsigned int, unsigned long>", linkageName: "_ZN8sequence8plusScanIjmEET_PS1_S2_T0_", scope: !55, file: !54, line: 229, type: !1854, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1856, retainedNodes: !45)
!1854 = !DISubroutineType(types: !1855)
!1855 = !{!18, !1175, !1175, !86}
!1856 = !{!1512, !1857}
!1857 = !DITemplateTypeParameter(name: "intT", type: !86)
!1858 = !DISubprogram(name: "remDuplicates<(lambda at ./ligra.h:222:20)>", linkageName: "_Z13remDuplicatesIZ23edgeMapSparse_no_filterIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE0_EvRS7_SG_ll", scope: !54, file: !54, line: 359, type: !1859, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1862, retainedNodes: !45)
!1859 = !DISubroutineType(types: !1860)
!1860 = !{null, !1861, !1175, !52, !52}
!1861 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1825, size: 64)
!1862 = !{!1863}
!1863 = !DITemplateTypeParameter(name: "G", type: !1825)
!1864 = !DISubprogram(name: "filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>", linkageName: "_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 270, type: !1865, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1867, retainedNodes: !45)
!1865 = !DISubroutineType(types: !1866)
!1866 = !{!86, !796, !796, !86, !1836}
!1867 = !{!1868, !1869}
!1868 = !DITemplateTypeParameter(name: "T", type: !797)
!1869 = !DITemplateTypeParameter(name: "PRED", type: !1836)
!1870 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getA<unsigned int, unsigned int>", scope: !55, file: !54, line: 98, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1871, templateParams: !1706, identifier: "_ZTSN8sequence4getAIjjEE")
!1871 = !{!1872, !1873, !1877}
!1872 = !DIDerivedType(tag: DW_TAG_member, name: "A", scope: !1870, file: !54, line: 99, baseType: !1175, size: 64)
!1873 = !DISubprogram(name: "getA", scope: !1870, file: !54, line: 100, type: !1874, scopeLine: 100, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1874 = !DISubroutineType(types: !1875)
!1875 = !{null, !1876, !1175}
!1876 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1870, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1877 = !DISubprogram(name: "operator()", linkageName: "_ZN8sequence4getAIjjEclEj", scope: !1870, file: !54, line: 101, type: !1878, scopeLine: 101, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1878 = !DISubroutineType(types: !1879)
!1879 = !{!18, !1876, !18}
!1880 = !DISubprogram(name: "scan<unsigned int, unsigned int, addF<unsigned int>, sequence::getA<unsigned int, unsigned int> >", linkageName: "_ZN8sequence4scanIjj4addFIjENS_4getAIjjEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 198, type: !1881, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1883, retainedNodes: !45)
!1881 = !DISubroutineType(types: !1882)
!1882 = !{!18, !1175, !18, !18, !1516, !1870, !18, !92, !92}
!1883 = !{!1512, !1707, !1524, !1884}
!1884 = !DITemplateTypeParameter(name: "G", type: !1870)
!1885 = !DISubprogram(name: "scanSerial<unsigned int, unsigned int, addF<unsigned int>, sequence::getA<unsigned int, unsigned int> >", linkageName: "_ZN8sequence10scanSerialIjj4addFIjENS_4getAIjjEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 169, type: !1881, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1883, retainedNodes: !45)
!1886 = !DISubprogram(name: "reduceSerial<unsigned int, unsigned int, addF<unsigned int>, sequence::getA<unsigned int, unsigned int> >", linkageName: "_ZN8sequence12reduceSerialIjj4addFIjENS_4getAIjjEEEET_T0_S6_T1_T2_", scope: !55, file: !54, line: 127, type: !1887, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1889, retainedNodes: !45)
!1887 = !DISubroutineType(types: !1888)
!1888 = !{!18, !18, !18, !1516, !1870}
!1889 = !{!1177, !1707, !1524, !1884}
!1890 = !DISubprogram(name: "linear_search<in_imap<unsigned int, (lambda at ./ligra.h:174:43)>, (lambda at ./ligra.h:175:13)>", linkageName: "_ZN4pbbs13linear_searchI7in_imapIjZ23edgeMapSparse_no_filterINS_5emptyE25compressedSymmetricVertex16vertexSubsetDataIS3_E5BFS_FES5_IT_ER5graphIT0_EPSB_RT1_PjjRT2_jEUlmE_EZS2_IS3_S4_S6_S7_ES9_SD_SE_SG_SH_jSJ_jEUlRKjSN_E_EEmS8_NS8_1TERKSB_", scope: !811, file: !1845, line: 10, type: !1846, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1850, retainedNodes: !45)
!1891 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getA<unsigned int, unsigned long>", scope: !55, file: !54, line: 98, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1892, templateParams: !1856, identifier: "_ZTSN8sequence4getAIjmEE")
!1892 = !{!1893, !1894, !1898}
!1893 = !DIDerivedType(tag: DW_TAG_member, name: "A", scope: !1891, file: !54, line: 99, baseType: !1175, size: 64)
!1894 = !DISubprogram(name: "getA", scope: !1891, file: !54, line: 100, type: !1895, scopeLine: 100, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1895 = !DISubroutineType(types: !1896)
!1896 = !{null, !1897, !1175}
!1897 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1891, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1898 = !DISubprogram(name: "operator()", linkageName: "_ZN8sequence4getAIjmEclEm", scope: !1891, file: !54, line: 101, type: !1899, scopeLine: 101, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1899 = !DISubroutineType(types: !1900)
!1900 = !{!18, !1897, !86}
!1901 = !DISubprogram(name: "scan<unsigned int, unsigned long, addF<unsigned int>, sequence::getA<unsigned int, unsigned long> >", linkageName: "_ZN8sequence4scanIjm4addFIjENS_4getAIjmEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 198, type: !1902, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1904, retainedNodes: !45)
!1902 = !DISubroutineType(types: !1903)
!1903 = !{!18, !1175, !86, !86, !1516, !1891, !18, !92, !92}
!1904 = !{!1512, !1857, !1524, !1905}
!1905 = !DITemplateTypeParameter(name: "G", type: !1891)
!1906 = !DISubprogram(name: "scanSerial<unsigned int, unsigned long, addF<unsigned int>, sequence::getA<unsigned int, unsigned long> >", linkageName: "_ZN8sequence10scanSerialIjm4addFIjENS_4getAIjmEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 169, type: !1902, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1904, retainedNodes: !45)
!1907 = !DISubprogram(name: "reduceSerial<unsigned int, unsigned long, addF<unsigned int>, sequence::getA<unsigned int, unsigned long> >", linkageName: "_ZN8sequence12reduceSerialIjm4addFIjENS_4getAIjmEEEET_T0_S6_T1_T2_", scope: !55, file: !54, line: 127, type: !1908, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1910, retainedNodes: !45)
!1908 = !DISubroutineType(types: !1909)
!1909 = !{!18, !86, !86, !1516, !1891}
!1910 = !{!1177, !1857, !1524, !1905}
!1911 = !DISubprogram(name: "filter_serial<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>", linkageName: "_ZN4pbbs13filter_serialISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 217, type: !1865, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1867, retainedNodes: !45)
!1912 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1913, size: 64)
!1913 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !1914, file: !192, line: 113, baseType: !797)
!1914 = distinct !DISubprogram(name: "edgeMapSparse<pbbs::empty, compressedSymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z13edgeMapSparseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 111, type: !1711, scopeLine: 112, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !1171, retainedNodes: !1915)
!1915 = !{!1916, !1917, !1918, !1919, !1920, !1921, !1922, !1923, !1924, !1925, !1926, !1929, !1933, !1935, !1936, !1937, !1938, !1940, !1942, !1943, !1944, !1947, !1949, !1950, !1951, !1952, !1954, !1956, !1957, !1960, !1966, !1967, !1968, !1969, !1971, !1981, !1983}
!1916 = !DILocalVariable(name: "GA", arg: 1, scope: !1914, file: !192, line: 111, type: !195)
!1917 = !DILocalVariable(name: "frontierVertices", arg: 2, scope: !1914, file: !192, line: 111, type: !120)
!1918 = !DILocalVariable(name: "indices", arg: 3, scope: !1914, file: !192, line: 111, type: !1164)
!1919 = !DILocalVariable(name: "degrees", arg: 4, scope: !1914, file: !192, line: 112, type: !753)
!1920 = !DILocalVariable(name: "m", arg: 5, scope: !1914, file: !192, line: 112, type: !126)
!1921 = !DILocalVariable(name: "f", arg: 6, scope: !1914, file: !192, line: 112, type: !1181)
!1922 = !DILocalVariable(name: "fl", arg: 7, scope: !1914, file: !192, line: 112, type: !1532)
!1923 = !DILocalVariable(name: "n", scope: !1914, file: !192, line: 114, type: !52)
!1924 = !DILocalVariable(name: "outEdges", scope: !1914, file: !192, line: 115, type: !1912)
!1925 = !DILocalVariable(name: "outEdgeCount", scope: !1914, file: !192, line: 116, type: !52)
!1926 = !DILocalVariable(name: "offsets", scope: !1927, file: !192, line: 119, type: !753)
!1927 = distinct !DILexicalBlock(scope: !1928, file: !192, line: 118, column: 26)
!1928 = distinct !DILexicalBlock(scope: !1914, file: !192, line: 118, column: 7)
!1929 = !DILocalVariable(name: "g", scope: !1927, file: !192, line: 122, type: !1930)
!1930 = distinct !DICompositeType(tag: DW_TAG_class_type, file: !1546, line: 45, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1931, identifier: "_ZTSZ16get_emsparse_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EEEUljjbE_")
!1931 = !{!1932}
!1932 = !DIDerivedType(tag: DW_TAG_member, name: "outEdges", scope: !1930, file: !1546, line: 45, baseType: !796, size: 64)
!1933 = !DILocalVariable(name: "__init", scope: !1934, type: !779, flags: DIFlagArtificial)
!1934 = distinct !DILexicalBlock(scope: !1927, file: !192, line: 123, column: 5)
!1935 = !DILocalVariable(name: "__limit", scope: !1934, type: !779, flags: DIFlagArtificial)
!1936 = !DILocalVariable(name: "__begin", scope: !1934, type: !779, flags: DIFlagArtificial)
!1937 = !DILocalVariable(name: "__end", scope: !1934, type: !779, flags: DIFlagArtificial)
!1938 = !DILocalVariable(name: "i", scope: !1939, file: !192, line: 123, type: !779)
!1939 = distinct !DILexicalBlock(scope: !1934, file: !192, line: 123, column: 5)
!1940 = !DILocalVariable(name: "v", scope: !1941, file: !192, line: 124, type: !126)
!1941 = distinct !DILexicalBlock(scope: !1939, file: !192, line: 123, column: 45)
!1942 = !DILocalVariable(name: "o", scope: !1941, file: !192, line: 124, type: !126)
!1943 = !DILocalVariable(name: "vert", scope: !1941, file: !192, line: 125, type: !121)
!1944 = !DILocalVariable(name: "g", scope: !1945, file: !192, line: 129, type: !1946)
!1945 = distinct !DILexicalBlock(scope: !1928, file: !192, line: 128, column: 10)
!1946 = distinct !DICompositeType(tag: DW_TAG_class_type, file: !1546, line: 100, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ25get_emsparse_nooutput_genIN4pbbs5emptyELi0EEDavEUljjbE_")
!1947 = !DILocalVariable(name: "__init", scope: !1948, type: !779, flags: DIFlagArtificial)
!1948 = distinct !DILexicalBlock(scope: !1945, file: !192, line: 130, column: 5)
!1949 = !DILocalVariable(name: "__limit", scope: !1948, type: !779, flags: DIFlagArtificial)
!1950 = !DILocalVariable(name: "__begin", scope: !1948, type: !779, flags: DIFlagArtificial)
!1951 = !DILocalVariable(name: "__end", scope: !1948, type: !779, flags: DIFlagArtificial)
!1952 = !DILocalVariable(name: "i", scope: !1953, file: !192, line: 130, type: !779)
!1953 = distinct !DILexicalBlock(scope: !1948, file: !192, line: 130, column: 5)
!1954 = !DILocalVariable(name: "v", scope: !1955, file: !192, line: 131, type: !126)
!1955 = distinct !DILexicalBlock(scope: !1953, file: !192, line: 130, column: 45)
!1956 = !DILocalVariable(name: "vert", scope: !1955, file: !192, line: 132, type: !121)
!1957 = !DILocalVariable(name: "nextIndices", scope: !1958, file: !192, line: 138, type: !1912)
!1958 = distinct !DILexicalBlock(scope: !1959, file: !192, line: 137, column: 26)
!1959 = distinct !DILexicalBlock(scope: !1914, file: !192, line: 137, column: 7)
!1960 = !DILocalVariable(name: "__init", scope: !1961, type: !52, flags: DIFlagArtificial)
!1961 = distinct !DILexicalBlock(scope: !1962, file: !192, line: 142, column: 9)
!1962 = distinct !DILexicalBlock(scope: !1963, file: !192, line: 140, column: 29)
!1963 = distinct !DILexicalBlock(scope: !1964, file: !192, line: 140, column: 11)
!1964 = distinct !DILexicalBlock(scope: !1965, file: !192, line: 139, column: 33)
!1965 = distinct !DILexicalBlock(scope: !1958, file: !192, line: 139, column: 9)
!1966 = !DILocalVariable(name: "__limit", scope: !1961, type: !52, flags: DIFlagArtificial)
!1967 = !DILocalVariable(name: "__begin", scope: !1961, type: !52, flags: DIFlagArtificial)
!1968 = !DILocalVariable(name: "__end", scope: !1961, type: !52, flags: DIFlagArtificial)
!1969 = !DILocalVariable(name: "i", scope: !1970, file: !192, line: 142, type: !52)
!1970 = distinct !DILexicalBlock(scope: !1961, file: !192, line: 142, column: 9)
!1971 = !DILocalVariable(name: "get_key", scope: !1964, file: !192, line: 144, type: !1972)
!1972 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1914, file: !192, line: 144, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !1973, identifier: "_ZTSZ13edgeMapSparseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE_")
!1973 = !{!1974, !1976}
!1974 = !DIDerivedType(tag: DW_TAG_member, name: "outEdges", scope: !1972, file: !192, line: 144, baseType: !1975, size: 64)
!1975 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1912, size: 64)
!1976 = !DISubprogram(name: "operator()", scope: !1972, file: !192, line: 144, type: !1977, scopeLine: 144, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!1977 = !DISubroutineType(types: !1978)
!1978 = !{!1136, !1979, !779}
!1979 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1980, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1980 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1972)
!1981 = !DILocalVariable(name: "p", scope: !1958, file: !192, line: 147, type: !1982)
!1982 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !1914, file: !192, line: 147, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ13edgeMapSparseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRSt5tupleIJjS1_EEE_")
!1983 = !DILocalVariable(name: "nextM", scope: !1958, file: !192, line: 148, type: !779)
!1984 = !DISubprogram(name: "get_emsparse_gen<pbbs::empty, 0>", linkageName: "_Z16get_emsparse_genIN4pbbs5emptyELi0EEDaPSt5tupleIJjT_EE", scope: !1546, file: !1546, line: 44, type: !1985, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1576, retainedNodes: !45)
!1985 = !DISubroutineType(types: !1986)
!1986 = !{!1930, !796}
!1987 = !DISubprogram(name: "get_emsparse_nooutput_gen<pbbs::empty, 0>", linkageName: "_Z25get_emsparse_nooutput_genIN4pbbs5emptyELi0EEDav", scope: !1546, file: !1546, line: 99, type: !1988, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1576, retainedNodes: !45)
!1988 = !DISubroutineType(types: !1989)
!1989 = !{!1946}
!1990 = !DISubprogram(name: "remDuplicates<(lambda at ./ligra.h:144:22)>", linkageName: "_Z13remDuplicatesIZ13edgeMapSparseIN4pbbs5emptyE25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EvRS7_SG_ll", scope: !54, file: !54, line: 359, type: !1991, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1994, retainedNodes: !45)
!1991 = !DISubroutineType(types: !1992)
!1992 = !{null, !1993, !1175, !52, !52}
!1993 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1972, size: 64)
!1994 = !{!1995}
!1995 = !DITemplateTypeParameter(name: "G", type: !1972)
!1996 = !DISubprogram(name: "filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>", linkageName: "_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 270, type: !1997, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1999, retainedNodes: !45)
!1997 = !DISubroutineType(types: !1998)
!1998 = !{!86, !796, !796, !86, !1982}
!1999 = !{!1868, !2000}
!2000 = !DITemplateTypeParameter(name: "PRED", type: !1982)
!2001 = !DISubprogram(name: "filter_serial<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>", linkageName: "_ZN4pbbs13filter_serialISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_25compressedSymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 217, type: !1997, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !1999, retainedNodes: !45)
!2002 = !DISubprogram(name: "edgeMap<compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z7edgeMapI26compressedAsymmetricVertex16vertexSubsetDataIN4pbbs5emptyEE5BFS_FES4_5graphIT_ERT0_T1_iRKj", scope: !192, file: !192, line: 280, type: !2003, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2005, retainedNodes: !45)
!2003 = !DISubroutineType(types: !2004)
!2004 = !{!771, !362, !1164, !754, !6, !907}
!2005 = !{!420, !1166, !1167}
!2006 = !DISubprogram(name: "edgeMapData<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z11edgeMapDataIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj", scope: !192, file: !192, line: 235, type: !2007, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2009, retainedNodes: !45)
!2007 = !DISubroutineType(types: !2008)
!2008 = !{!771, !424, !1164, !754, !6, !907}
!2009 = !{!1163, !420, !1166, !1167}
!2010 = !DISubprogram(name: "edgeMapDenseForward<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z19edgeMapDenseForwardIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 85, type: !2011, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2009, retainedNodes: !45)
!2011 = !DISubroutineType(types: !2012)
!2012 = !{!771, !362, !1164, !1181, !18}
!2013 = !DISubprogram(name: "edgeMapDense<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z12edgeMapDenseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 59, type: !2011, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2009, retainedNodes: !45)
!2014 = !DISubprogram(name: "edgeMapSparse_no_filter<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 157, type: !2015, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2009, retainedNodes: !45)
!2015 = !DISubroutineType(types: !2016)
!2016 = !{!771, !424, !365, !1164, !1175, !18, !1181, !18}
!2017 = !DISubprogram(name: "edgeMapSparse<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z13edgeMapSparseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 111, type: !2015, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2009, retainedNodes: !45)
!2018 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2019, size: 64)
!2019 = !DIDerivedType(tag: DW_TAG_typedef, name: "D", scope: !2020, file: !192, line: 86, baseType: !1016)
!2020 = distinct !DISubprogram(name: "edgeMapDenseForward<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z19edgeMapDenseForwardIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 85, type: !2021, scopeLine: 85, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2009, retainedNodes: !2023)
!2021 = !DISubroutineType(types: !2022)
!2022 = !{!771, !362, !1164, !1181, !1532}
!2023 = !{!2024, !2025, !2026, !2027, !2028, !2029, !2030, !2033, !2034, !2036, !2037, !2038, !2039, !2041, !2043, !2044, !2045, !2046, !2048, !2050, !2052, !2053, !2054, !2055}
!2024 = !DILocalVariable(name: "GA", arg: 1, scope: !2020, file: !192, line: 85, type: !362)
!2025 = !DILocalVariable(name: "vertexSubset", arg: 2, scope: !2020, file: !192, line: 85, type: !1164)
!2026 = !DILocalVariable(name: "f", arg: 3, scope: !2020, file: !192, line: 85, type: !1181)
!2027 = !DILocalVariable(name: "fl", arg: 4, scope: !2020, file: !192, line: 85, type: !1532)
!2028 = !DILocalVariable(name: "n", scope: !2020, file: !192, line: 87, type: !52)
!2029 = !DILocalVariable(name: "G", scope: !2020, file: !192, line: 88, type: !365)
!2030 = !DILocalVariable(name: "next", scope: !2031, file: !192, line: 90, type: !2018)
!2031 = distinct !DILexicalBlock(scope: !2032, file: !192, line: 89, column: 26)
!2032 = distinct !DILexicalBlock(scope: !2020, file: !192, line: 89, column: 7)
!2033 = !DILocalVariable(name: "g", scope: !2031, file: !192, line: 91, type: !1545)
!2034 = !DILocalVariable(name: "__init", scope: !2035, type: !52, flags: DIFlagArtificial)
!2035 = distinct !DILexicalBlock(scope: !2031, file: !192, line: 92, column: 5)
!2036 = !DILocalVariable(name: "__limit", scope: !2035, type: !52, flags: DIFlagArtificial)
!2037 = !DILocalVariable(name: "__begin", scope: !2035, type: !52, flags: DIFlagArtificial)
!2038 = !DILocalVariable(name: "__end", scope: !2035, type: !52, flags: DIFlagArtificial)
!2039 = !DILocalVariable(name: "i", scope: !2040, file: !192, line: 92, type: !52)
!2040 = distinct !DILexicalBlock(scope: !2035, file: !192, line: 92, column: 5)
!2041 = !DILocalVariable(name: "__init", scope: !2042, type: !52, flags: DIFlagArtificial)
!2042 = distinct !DILexicalBlock(scope: !2031, file: !192, line: 93, column: 5)
!2043 = !DILocalVariable(name: "__limit", scope: !2042, type: !52, flags: DIFlagArtificial)
!2044 = !DILocalVariable(name: "__begin", scope: !2042, type: !52, flags: DIFlagArtificial)
!2045 = !DILocalVariable(name: "__end", scope: !2042, type: !52, flags: DIFlagArtificial)
!2046 = !DILocalVariable(name: "i", scope: !2047, file: !192, line: 93, type: !52)
!2047 = distinct !DILexicalBlock(scope: !2042, file: !192, line: 93, column: 5)
!2048 = !DILocalVariable(name: "g", scope: !2049, file: !192, line: 100, type: !1565)
!2049 = distinct !DILexicalBlock(scope: !2032, file: !192, line: 99, column: 10)
!2050 = !DILocalVariable(name: "__init", scope: !2051, type: !52, flags: DIFlagArtificial)
!2051 = distinct !DILexicalBlock(scope: !2049, file: !192, line: 101, column: 5)
!2052 = !DILocalVariable(name: "__limit", scope: !2051, type: !52, flags: DIFlagArtificial)
!2053 = !DILocalVariable(name: "__begin", scope: !2051, type: !52, flags: DIFlagArtificial)
!2054 = !DILocalVariable(name: "__end", scope: !2051, type: !52, flags: DIFlagArtificial)
!2055 = !DILocalVariable(name: "i", scope: !2056, file: !192, line: 101, type: !52)
!2056 = distinct !DILexicalBlock(scope: !2051, file: !192, line: 101, column: 5)
!2057 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2058, size: 64)
!2058 = !DIDerivedType(tag: DW_TAG_typedef, name: "D", scope: !2059, file: !192, line: 60, baseType: !1016)
!2059 = distinct !DISubprogram(name: "edgeMapDense<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z12edgeMapDenseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 59, type: !2021, scopeLine: 59, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2009, retainedNodes: !2060)
!2060 = !{!2061, !2062, !2063, !2064, !2065, !2066, !2067, !2070, !2071, !2073, !2074, !2075, !2076, !2078, !2080, !2082, !2083, !2084, !2085}
!2061 = !DILocalVariable(name: "GA", arg: 1, scope: !2059, file: !192, line: 59, type: !362)
!2062 = !DILocalVariable(name: "vertexSubset", arg: 2, scope: !2059, file: !192, line: 59, type: !1164)
!2063 = !DILocalVariable(name: "f", arg: 3, scope: !2059, file: !192, line: 59, type: !1181)
!2064 = !DILocalVariable(name: "fl", arg: 4, scope: !2059, file: !192, line: 59, type: !1532)
!2065 = !DILocalVariable(name: "n", scope: !2059, file: !192, line: 61, type: !52)
!2066 = !DILocalVariable(name: "G", scope: !2059, file: !192, line: 62, type: !365)
!2067 = !DILocalVariable(name: "next", scope: !2068, file: !192, line: 64, type: !2057)
!2068 = distinct !DILexicalBlock(scope: !2069, file: !192, line: 63, column: 26)
!2069 = distinct !DILexicalBlock(scope: !2059, file: !192, line: 63, column: 7)
!2070 = !DILocalVariable(name: "g", scope: !2068, file: !192, line: 65, type: !1677)
!2071 = !DILocalVariable(name: "__init", scope: !2072, type: !52, flags: DIFlagArtificial)
!2072 = distinct !DILexicalBlock(scope: !2068, file: !192, line: 66, column: 5)
!2073 = !DILocalVariable(name: "__limit", scope: !2072, type: !52, flags: DIFlagArtificial)
!2074 = !DILocalVariable(name: "__begin", scope: !2072, type: !52, flags: DIFlagArtificial)
!2075 = !DILocalVariable(name: "__end", scope: !2072, type: !52, flags: DIFlagArtificial)
!2076 = !DILocalVariable(name: "v", scope: !2077, file: !192, line: 66, type: !52)
!2077 = distinct !DILexicalBlock(scope: !2072, file: !192, line: 66, column: 5)
!2078 = !DILocalVariable(name: "g", scope: !2079, file: !192, line: 74, type: !1689)
!2079 = distinct !DILexicalBlock(scope: !2069, file: !192, line: 73, column: 10)
!2080 = !DILocalVariable(name: "__init", scope: !2081, type: !52, flags: DIFlagArtificial)
!2081 = distinct !DILexicalBlock(scope: !2079, file: !192, line: 75, column: 5)
!2082 = !DILocalVariable(name: "__limit", scope: !2081, type: !52, flags: DIFlagArtificial)
!2083 = !DILocalVariable(name: "__begin", scope: !2081, type: !52, flags: DIFlagArtificial)
!2084 = !DILocalVariable(name: "__end", scope: !2081, type: !52, flags: DIFlagArtificial)
!2085 = !DILocalVariable(name: "v", scope: !2086, file: !192, line: 75, type: !52)
!2086 = distinct !DILexicalBlock(scope: !2081, file: !192, line: 75, column: 5)
!2087 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2088, size: 64)
!2088 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !2089, file: !192, line: 160, baseType: !797)
!2089 = distinct !DISubprogram(name: "edgeMapSparse_no_filter<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 157, type: !2090, scopeLine: 159, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2009, retainedNodes: !2092)
!2090 = !DISubroutineType(types: !2091)
!2091 = !{!771, !424, !365, !1164, !753, !126, !1181, !1532}
!2092 = !{!2093, !2094, !2095, !2096, !2097, !2098, !2099, !2100, !2101, !2102, !2103, !2104, !2105, !2106, !2107, !2108, !2138, !2140, !2142, !2143, !2144, !2145, !2147, !2149, !2151, !2152, !2153, !2154, !2156, !2160, !2161, !2162, !2163, !2165, !2168, !2169, !2170, !2171, !2173, !2174, !2175, !2176, !2178, !2182, !2183, !2184, !2185, !2187, !2193, !2194, !2195, !2196, !2198, !2208, !2209, !2211}
!2093 = !DILocalVariable(name: "GA", arg: 1, scope: !2089, file: !192, line: 157, type: !424)
!2094 = !DILocalVariable(name: "frontierVertices", arg: 2, scope: !2089, file: !192, line: 158, type: !365)
!2095 = !DILocalVariable(name: "indices", arg: 3, scope: !2089, file: !192, line: 158, type: !1164)
!2096 = !DILocalVariable(name: "offsets", arg: 4, scope: !2089, file: !192, line: 158, type: !753)
!2097 = !DILocalVariable(name: "m", arg: 5, scope: !2089, file: !192, line: 158, type: !126)
!2098 = !DILocalVariable(name: "f", arg: 6, scope: !2089, file: !192, line: 158, type: !1181)
!2099 = !DILocalVariable(name: "fl", arg: 7, scope: !2089, file: !192, line: 159, type: !1532)
!2100 = !DILocalVariable(name: "n", scope: !2089, file: !192, line: 161, type: !52)
!2101 = !DILocalVariable(name: "outEdgeCount", scope: !2089, file: !192, line: 162, type: !52)
!2102 = !DILocalVariable(name: "outEdges", scope: !2089, file: !192, line: 163, type: !2087)
!2103 = !DILocalVariable(name: "g", scope: !2089, file: !192, line: 165, type: !1725)
!2104 = !DILocalVariable(name: "b_size", scope: !2089, file: !192, line: 168, type: !779)
!2105 = !DILocalVariable(name: "n_blocks", scope: !2089, file: !192, line: 169, type: !779)
!2106 = !DILocalVariable(name: "cts", scope: !2089, file: !192, line: 171, type: !49)
!2107 = !DILocalVariable(name: "block_offs", scope: !2089, file: !192, line: 172, type: !1732)
!2108 = !DILocalVariable(name: "offsets_m", scope: !2089, file: !192, line: 174, type: !2109)
!2109 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_imap<unsigned int, (lambda at ./ligra.h:174:43)>", file: !1188, line: 44, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2110, templateParams: !2136, identifier: "_ZTS7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E")
!2110 = !{!2111, !2115, !2116, !2117, !2121, !2124, !2128, !2129, !2132, !2133}
!2111 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !2109, file: !1188, line: 46, baseType: !2112, size: 64)
!2112 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2089, file: !192, line: 174, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2113, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE_")
!2113 = !{!2114}
!2114 = !DIDerivedType(tag: DW_TAG_member, name: "offsets", scope: !2112, file: !192, line: 174, baseType: !1740, size: 64)
!2115 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !2109, file: !1188, line: 47, baseType: !779, size: 64, offset: 64)
!2116 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !2109, file: !1188, line: 47, baseType: !779, size: 64, offset: 128)
!2117 = !DISubprogram(name: "in_imap", scope: !2109, file: !1188, line: 48, type: !2118, scopeLine: 48, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2118 = !DISubroutineType(types: !2119)
!2119 = !{null, !2120, !779, !2112}
!2120 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2109, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2121 = !DISubprogram(name: "in_imap", scope: !2109, file: !1188, line: 49, type: !2122, scopeLine: 49, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2122 = !DISubroutineType(types: !2123)
!2123 = !{null, !2120, !779, !779, !2112}
!2124 = !DISubprogram(name: "operator[]", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EixEm", scope: !2109, file: !1188, line: 50, type: !2125, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2125 = !DISubroutineType(types: !2126)
!2126 = !{!2127, !2120, !1225}
!2127 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !2109, file: !1188, line: 45, baseType: !18)
!2128 = !DISubprogram(name: "operator()", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EclEm", scope: !2109, file: !1188, line: 51, type: !2125, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2129 = !DISubprogram(name: "cut", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E3cutEmm", scope: !2109, file: !1188, line: 52, type: !2130, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2130 = !DISubroutineType(types: !2131)
!2131 = !{!2109, !2120, !779, !779}
!2132 = !DISubprogram(name: "slice", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E5sliceEmm", scope: !2109, file: !1188, line: 53, type: !2130, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2133 = !DISubprogram(name: "size", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E4sizeEv", scope: !2109, file: !1188, line: 54, type: !2134, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2134 = !DISubroutineType(types: !2135)
!2135 = !{!779, !2120}
!2136 = !{!1242, !2137}
!2137 = !DITemplateTypeParameter(name: "F", type: !2112)
!2138 = !DILocalVariable(name: "lt", scope: !2089, file: !192, line: 175, type: !2139)
!2139 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2089, file: !192, line: 175, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRKjSJ_E_")
!2140 = !DILocalVariable(name: "__init", scope: !2141, type: !779, flags: DIFlagArtificial)
!2141 = distinct !DILexicalBlock(scope: !2089, file: !192, line: 176, column: 3)
!2142 = !DILocalVariable(name: "__limit", scope: !2141, type: !779, flags: DIFlagArtificial)
!2143 = !DILocalVariable(name: "__begin", scope: !2141, type: !779, flags: DIFlagArtificial)
!2144 = !DILocalVariable(name: "__end", scope: !2141, type: !779, flags: DIFlagArtificial)
!2145 = !DILocalVariable(name: "i", scope: !2146, file: !192, line: 176, type: !779)
!2146 = distinct !DILexicalBlock(scope: !2141, file: !192, line: 176, column: 3)
!2147 = !DILocalVariable(name: "s_val", scope: !2148, file: !192, line: 177, type: !779)
!2148 = distinct !DILexicalBlock(scope: !2146, file: !192, line: 176, column: 45)
!2149 = !DILocalVariable(name: "__init", scope: !2150, type: !779, flags: DIFlagArtificial)
!2150 = distinct !DILexicalBlock(scope: !2089, file: !192, line: 181, column: 3)
!2151 = !DILocalVariable(name: "__limit", scope: !2150, type: !779, flags: DIFlagArtificial)
!2152 = !DILocalVariable(name: "__begin", scope: !2150, type: !779, flags: DIFlagArtificial)
!2153 = !DILocalVariable(name: "__end", scope: !2150, type: !779, flags: DIFlagArtificial)
!2154 = !DILocalVariable(name: "i", scope: !2155, file: !192, line: 181, type: !779)
!2155 = distinct !DILexicalBlock(scope: !2150, file: !192, line: 181, column: 3)
!2156 = !DILocalVariable(name: "start", scope: !2157, file: !192, line: 184, type: !779)
!2157 = distinct !DILexicalBlock(scope: !2158, file: !192, line: 182, column: 64)
!2158 = distinct !DILexicalBlock(scope: !2159, file: !192, line: 182, column: 9)
!2159 = distinct !DILexicalBlock(scope: !2155, file: !192, line: 181, column: 46)
!2160 = !DILocalVariable(name: "end", scope: !2157, file: !192, line: 185, type: !779)
!2161 = !DILocalVariable(name: "start_o", scope: !2157, file: !192, line: 186, type: !126)
!2162 = !DILocalVariable(name: "k", scope: !2157, file: !192, line: 187, type: !126)
!2163 = !DILocalVariable(name: "j", scope: !2164, file: !192, line: 188, type: !779)
!2164 = distinct !DILexicalBlock(scope: !2157, file: !192, line: 188, column: 7)
!2165 = !DILocalVariable(name: "v", scope: !2166, file: !192, line: 189, type: !50)
!2166 = distinct !DILexicalBlock(scope: !2167, file: !192, line: 188, column: 40)
!2167 = distinct !DILexicalBlock(scope: !2164, file: !192, line: 188, column: 7)
!2168 = !DILocalVariable(name: "num_in", scope: !2166, file: !192, line: 190, type: !779)
!2169 = !DILocalVariable(name: "outSize", scope: !2089, file: !192, line: 199, type: !52)
!2170 = !DILocalVariable(name: "out", scope: !2089, file: !192, line: 202, type: !2087)
!2171 = !DILocalVariable(name: "__init", scope: !2172, type: !779, flags: DIFlagArtificial)
!2172 = distinct !DILexicalBlock(scope: !2089, file: !192, line: 204, column: 3)
!2173 = !DILocalVariable(name: "__limit", scope: !2172, type: !779, flags: DIFlagArtificial)
!2174 = !DILocalVariable(name: "__begin", scope: !2172, type: !779, flags: DIFlagArtificial)
!2175 = !DILocalVariable(name: "__end", scope: !2172, type: !779, flags: DIFlagArtificial)
!2176 = !DILocalVariable(name: "i", scope: !2177, file: !192, line: 204, type: !779)
!2177 = distinct !DILexicalBlock(scope: !2172, file: !192, line: 204, column: 3)
!2178 = !DILocalVariable(name: "start", scope: !2179, file: !192, line: 206, type: !779)
!2179 = distinct !DILexicalBlock(scope: !2180, file: !192, line: 205, column: 64)
!2180 = distinct !DILexicalBlock(scope: !2181, file: !192, line: 205, column: 9)
!2181 = distinct !DILexicalBlock(scope: !2177, file: !192, line: 204, column: 46)
!2182 = !DILocalVariable(name: "start_o", scope: !2179, file: !192, line: 207, type: !779)
!2183 = !DILocalVariable(name: "out_off", scope: !2179, file: !192, line: 208, type: !779)
!2184 = !DILocalVariable(name: "block_size", scope: !2179, file: !192, line: 209, type: !779)
!2185 = !DILocalVariable(name: "j", scope: !2186, file: !192, line: 210, type: !779)
!2186 = distinct !DILexicalBlock(scope: !2179, file: !192, line: 210, column: 7)
!2187 = !DILocalVariable(name: "__init", scope: !2188, type: !779, flags: DIFlagArtificial)
!2188 = distinct !DILexicalBlock(scope: !2189, file: !192, line: 220, column: 7)
!2189 = distinct !DILexicalBlock(scope: !2190, file: !192, line: 218, column: 27)
!2190 = distinct !DILexicalBlock(scope: !2191, file: !192, line: 218, column: 9)
!2191 = distinct !DILexicalBlock(scope: !2192, file: !192, line: 217, column: 31)
!2192 = distinct !DILexicalBlock(scope: !2089, file: !192, line: 217, column: 7)
!2193 = !DILocalVariable(name: "__limit", scope: !2188, type: !779, flags: DIFlagArtificial)
!2194 = !DILocalVariable(name: "__begin", scope: !2188, type: !779, flags: DIFlagArtificial)
!2195 = !DILocalVariable(name: "__end", scope: !2188, type: !779, flags: DIFlagArtificial)
!2196 = !DILocalVariable(name: "i", scope: !2197, file: !192, line: 220, type: !779)
!2197 = distinct !DILexicalBlock(scope: !2188, file: !192, line: 220, column: 7)
!2198 = !DILocalVariable(name: "get_key", scope: !2191, file: !192, line: 222, type: !2199)
!2199 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2089, file: !192, line: 222, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2200, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE0_")
!2200 = !{!2201, !2203}
!2201 = !DIDerivedType(tag: DW_TAG_member, name: "out", scope: !2199, file: !192, line: 222, baseType: !2202, size: 64)
!2202 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2087, size: 64)
!2203 = !DISubprogram(name: "operator()", scope: !2199, file: !192, line: 222, type: !2204, scopeLine: 222, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2204 = !DISubroutineType(types: !2205)
!2205 = !{!1136, !2206, !779}
!2206 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2207, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2207 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2199)
!2208 = !DILocalVariable(name: "nextIndices", scope: !2191, file: !192, line: 224, type: !2087)
!2209 = !DILocalVariable(name: "p", scope: !2191, file: !192, line: 225, type: !2210)
!2210 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2089, file: !192, line: 225, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRSt5tupleIJjS1_EEE_")
!2211 = !DILocalVariable(name: "nextM", scope: !2191, file: !192, line: 226, type: !779)
!2212 = !DISubprogram(name: "make_in_imap<unsigned int, (lambda at ./ligra.h:174:43)>", linkageName: "_Z12make_in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E7in_imapIS7_SA_EmSA_", scope: !1188, file: !1188, line: 59, type: !2213, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2136, retainedNodes: !45)
!2213 = !DISubroutineType(types: !2214)
!2214 = !{!2109, !86, !2112}
!2215 = !DISubprogram(name: "binary_search<in_imap<unsigned int, (lambda at ./ligra.h:174:43)>, (lambda at ./ligra.h:175:13)>", linkageName: "_ZN4pbbs13binary_searchI7in_imapIjZ23edgeMapSparse_no_filterINS_5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS3_E5BFS_FES5_IT_ER5graphIT0_EPSB_RT1_PjjRT2_jEUlmE_EZS2_IS3_S4_S6_S7_ES9_SD_SE_SG_SH_jSJ_jEUlRKjSN_E_EEmS8_NS8_1TERKSB_", scope: !811, file: !1845, line: 18, type: !2216, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2220, retainedNodes: !45)
!2216 = !DISubroutineType(types: !2217)
!2217 = !{!86, !2109, !18, !2218}
!2218 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2219, size: 64)
!2219 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2139)
!2220 = !{!2221, !2222}
!2221 = !DITemplateTypeParameter(name: "Sequence", type: !2109)
!2222 = !DITemplateTypeParameter(name: "F", type: !2139)
!2223 = !DISubprogram(name: "remDuplicates<(lambda at ./ligra.h:222:20)>", linkageName: "_Z13remDuplicatesIZ23edgeMapSparse_no_filterIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE0_EvRS7_SG_ll", scope: !54, file: !54, line: 359, type: !2224, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2227, retainedNodes: !45)
!2224 = !DISubroutineType(types: !2225)
!2225 = !{null, !2226, !1175, !52, !52}
!2226 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2199, size: 64)
!2227 = !{!2228}
!2228 = !DITemplateTypeParameter(name: "G", type: !2199)
!2229 = !DISubprogram(name: "filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>", linkageName: "_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 270, type: !2230, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2232, retainedNodes: !45)
!2230 = !DISubroutineType(types: !2231)
!2231 = !{!86, !796, !796, !86, !2210}
!2232 = !{!1868, !2233}
!2233 = !DITemplateTypeParameter(name: "PRED", type: !2210)
!2234 = !DISubprogram(name: "linear_search<in_imap<unsigned int, (lambda at ./ligra.h:174:43)>, (lambda at ./ligra.h:175:13)>", linkageName: "_ZN4pbbs13linear_searchI7in_imapIjZ23edgeMapSparse_no_filterINS_5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS3_E5BFS_FES5_IT_ER5graphIT0_EPSB_RT1_PjjRT2_jEUlmE_EZS2_IS3_S4_S6_S7_ES9_SD_SE_SG_SH_jSJ_jEUlRKjSN_E_EEmS8_NS8_1TERKSB_", scope: !811, file: !1845, line: 10, type: !2216, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2220, retainedNodes: !45)
!2235 = !DISubprogram(name: "filter_serial<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>", linkageName: "_ZN4pbbs13filter_serialISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 217, type: !2230, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2232, retainedNodes: !45)
!2236 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2237, size: 64)
!2237 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !2238, file: !192, line: 113, baseType: !797)
!2238 = distinct !DISubprogram(name: "edgeMapSparse<pbbs::empty, compressedAsymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z13edgeMapSparseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 111, type: !2090, scopeLine: 112, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2009, retainedNodes: !2239)
!2239 = !{!2240, !2241, !2242, !2243, !2244, !2245, !2246, !2247, !2248, !2249, !2250, !2253, !2254, !2256, !2257, !2258, !2259, !2261, !2263, !2264, !2265, !2267, !2269, !2270, !2271, !2272, !2274, !2276, !2277, !2280, !2286, !2287, !2288, !2289, !2291, !2301, !2303}
!2240 = !DILocalVariable(name: "GA", arg: 1, scope: !2238, file: !192, line: 111, type: !424)
!2241 = !DILocalVariable(name: "frontierVertices", arg: 2, scope: !2238, file: !192, line: 111, type: !365)
!2242 = !DILocalVariable(name: "indices", arg: 3, scope: !2238, file: !192, line: 111, type: !1164)
!2243 = !DILocalVariable(name: "degrees", arg: 4, scope: !2238, file: !192, line: 112, type: !753)
!2244 = !DILocalVariable(name: "m", arg: 5, scope: !2238, file: !192, line: 112, type: !126)
!2245 = !DILocalVariable(name: "f", arg: 6, scope: !2238, file: !192, line: 112, type: !1181)
!2246 = !DILocalVariable(name: "fl", arg: 7, scope: !2238, file: !192, line: 112, type: !1532)
!2247 = !DILocalVariable(name: "n", scope: !2238, file: !192, line: 114, type: !52)
!2248 = !DILocalVariable(name: "outEdges", scope: !2238, file: !192, line: 115, type: !2236)
!2249 = !DILocalVariable(name: "outEdgeCount", scope: !2238, file: !192, line: 116, type: !52)
!2250 = !DILocalVariable(name: "offsets", scope: !2251, file: !192, line: 119, type: !753)
!2251 = distinct !DILexicalBlock(scope: !2252, file: !192, line: 118, column: 26)
!2252 = distinct !DILexicalBlock(scope: !2238, file: !192, line: 118, column: 7)
!2253 = !DILocalVariable(name: "g", scope: !2251, file: !192, line: 122, type: !1930)
!2254 = !DILocalVariable(name: "__init", scope: !2255, type: !779, flags: DIFlagArtificial)
!2255 = distinct !DILexicalBlock(scope: !2251, file: !192, line: 123, column: 5)
!2256 = !DILocalVariable(name: "__limit", scope: !2255, type: !779, flags: DIFlagArtificial)
!2257 = !DILocalVariable(name: "__begin", scope: !2255, type: !779, flags: DIFlagArtificial)
!2258 = !DILocalVariable(name: "__end", scope: !2255, type: !779, flags: DIFlagArtificial)
!2259 = !DILocalVariable(name: "i", scope: !2260, file: !192, line: 123, type: !779)
!2260 = distinct !DILexicalBlock(scope: !2255, file: !192, line: 123, column: 5)
!2261 = !DILocalVariable(name: "v", scope: !2262, file: !192, line: 124, type: !126)
!2262 = distinct !DILexicalBlock(scope: !2260, file: !192, line: 123, column: 45)
!2263 = !DILocalVariable(name: "o", scope: !2262, file: !192, line: 124, type: !126)
!2264 = !DILocalVariable(name: "vert", scope: !2262, file: !192, line: 125, type: !366)
!2265 = !DILocalVariable(name: "g", scope: !2266, file: !192, line: 129, type: !1946)
!2266 = distinct !DILexicalBlock(scope: !2252, file: !192, line: 128, column: 10)
!2267 = !DILocalVariable(name: "__init", scope: !2268, type: !779, flags: DIFlagArtificial)
!2268 = distinct !DILexicalBlock(scope: !2266, file: !192, line: 130, column: 5)
!2269 = !DILocalVariable(name: "__limit", scope: !2268, type: !779, flags: DIFlagArtificial)
!2270 = !DILocalVariable(name: "__begin", scope: !2268, type: !779, flags: DIFlagArtificial)
!2271 = !DILocalVariable(name: "__end", scope: !2268, type: !779, flags: DIFlagArtificial)
!2272 = !DILocalVariable(name: "i", scope: !2273, file: !192, line: 130, type: !779)
!2273 = distinct !DILexicalBlock(scope: !2268, file: !192, line: 130, column: 5)
!2274 = !DILocalVariable(name: "v", scope: !2275, file: !192, line: 131, type: !126)
!2275 = distinct !DILexicalBlock(scope: !2273, file: !192, line: 130, column: 45)
!2276 = !DILocalVariable(name: "vert", scope: !2275, file: !192, line: 132, type: !366)
!2277 = !DILocalVariable(name: "nextIndices", scope: !2278, file: !192, line: 138, type: !2236)
!2278 = distinct !DILexicalBlock(scope: !2279, file: !192, line: 137, column: 26)
!2279 = distinct !DILexicalBlock(scope: !2238, file: !192, line: 137, column: 7)
!2280 = !DILocalVariable(name: "__init", scope: !2281, type: !52, flags: DIFlagArtificial)
!2281 = distinct !DILexicalBlock(scope: !2282, file: !192, line: 142, column: 9)
!2282 = distinct !DILexicalBlock(scope: !2283, file: !192, line: 140, column: 29)
!2283 = distinct !DILexicalBlock(scope: !2284, file: !192, line: 140, column: 11)
!2284 = distinct !DILexicalBlock(scope: !2285, file: !192, line: 139, column: 33)
!2285 = distinct !DILexicalBlock(scope: !2278, file: !192, line: 139, column: 9)
!2286 = !DILocalVariable(name: "__limit", scope: !2281, type: !52, flags: DIFlagArtificial)
!2287 = !DILocalVariable(name: "__begin", scope: !2281, type: !52, flags: DIFlagArtificial)
!2288 = !DILocalVariable(name: "__end", scope: !2281, type: !52, flags: DIFlagArtificial)
!2289 = !DILocalVariable(name: "i", scope: !2290, file: !192, line: 142, type: !52)
!2290 = distinct !DILexicalBlock(scope: !2281, file: !192, line: 142, column: 9)
!2291 = !DILocalVariable(name: "get_key", scope: !2284, file: !192, line: 144, type: !2292)
!2292 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2238, file: !192, line: 144, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2293, identifier: "_ZTSZ13edgeMapSparseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE_")
!2293 = !{!2294, !2296}
!2294 = !DIDerivedType(tag: DW_TAG_member, name: "outEdges", scope: !2292, file: !192, line: 144, baseType: !2295, size: 64)
!2295 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2236, size: 64)
!2296 = !DISubprogram(name: "operator()", scope: !2292, file: !192, line: 144, type: !2297, scopeLine: 144, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2297 = !DISubroutineType(types: !2298)
!2298 = !{!1136, !2299, !779}
!2299 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2300, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2300 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2292)
!2301 = !DILocalVariable(name: "p", scope: !2278, file: !192, line: 147, type: !2302)
!2302 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2238, file: !192, line: 147, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ13edgeMapSparseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRSt5tupleIJjS1_EEE_")
!2303 = !DILocalVariable(name: "nextM", scope: !2278, file: !192, line: 148, type: !779)
!2304 = !DISubprogram(name: "remDuplicates<(lambda at ./ligra.h:144:22)>", linkageName: "_Z13remDuplicatesIZ13edgeMapSparseIN4pbbs5emptyE26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EvRS7_SG_ll", scope: !54, file: !54, line: 359, type: !2305, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2308, retainedNodes: !45)
!2305 = !DISubroutineType(types: !2306)
!2306 = !{null, !2307, !1175, !52, !52}
!2307 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2292, size: 64)
!2308 = !{!2309}
!2309 = !DITemplateTypeParameter(name: "G", type: !2292)
!2310 = !DISubprogram(name: "filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>", linkageName: "_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 270, type: !2311, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2313, retainedNodes: !45)
!2311 = !DISubroutineType(types: !2312)
!2312 = !{!86, !796, !796, !86, !2302}
!2313 = !{!1868, !2314}
!2314 = !DITemplateTypeParameter(name: "PRED", type: !2302)
!2315 = !DISubprogram(name: "filter_serial<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>", linkageName: "_ZN4pbbs13filter_serialISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_26compressedAsymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 217, type: !2311, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2313, retainedNodes: !45)
!2316 = !DISubprogram(name: "readGraphFromBinary<symmetricVertex>", linkageName: "_Z19readGraphFromBinaryI15symmetricVertexE5graphIT_EPcb", scope: !113, file: !113, line: 319, type: !2317, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !493, retainedNodes: !45)
!2317 = !DISubroutineType(types: !2318)
!2318 = !{!428, !81, !92}
!2319 = !DISubprogram(name: "readGraphFromFile<symmetricVertex>", linkageName: "_Z17readGraphFromFileI15symmetricVertexE5graphIT_EPcbb", scope: !113, file: !113, line: 164, type: !2320, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !493, retainedNodes: !45)
!2320 = !DISubroutineType(types: !2321)
!2321 = !{!428, !81, !92, !92}
!2322 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2323, size: 64)
!2323 = !DIDerivedType(tag: DW_TAG_typedef, name: "intPair", file: !113, line: 42, baseType: !2324)
!2324 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "pair<unsigned int, unsigned int>", scope: !5, file: !221, line: 211, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2325, templateParams: !2376, identifier: "_ZTSSt4pairIjjE")
!2325 = !{!2326, !2346, !2347, !2348, !2354, !2358, !2366, !2373}
!2326 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2324, baseType: !2327, flags: DIFlagPrivate, extraData: i32 0)
!2327 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "__pair_base<unsigned int, unsigned int>", scope: !5, file: !221, line: 189, size: 8, flags: DIFlagTypePassByValue, elements: !2328, templateParams: !2343, identifier: "_ZTSSt11__pair_baseIjjE")
!2328 = !{!2329, !2333, !2334, !2339}
!2329 = !DISubprogram(name: "__pair_base", scope: !2327, file: !221, line: 193, type: !2330, scopeLine: 193, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2330 = !DISubroutineType(types: !2331)
!2331 = !{null, !2332}
!2332 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2327, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2333 = !DISubprogram(name: "~__pair_base", scope: !2327, file: !221, line: 194, type: !2330, scopeLine: 194, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2334 = !DISubprogram(name: "__pair_base", scope: !2327, file: !221, line: 195, type: !2335, scopeLine: 195, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2335 = !DISubroutineType(types: !2336)
!2336 = !{null, !2332, !2337}
!2337 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2338, size: 64)
!2338 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2327)
!2339 = !DISubprogram(name: "operator=", linkageName: "_ZNSt11__pair_baseIjjEaSERKS0_", scope: !2327, file: !221, line: 196, type: !2340, scopeLine: 196, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized | DISPFlagDeleted)
!2340 = !DISubroutineType(types: !2341)
!2341 = !{!2342, !2332, !2337}
!2342 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2327, size: 64)
!2343 = !{!2344, !2345}
!2344 = !DITemplateTypeParameter(name: "_U1", type: !18)
!2345 = !DITemplateTypeParameter(name: "_U2", type: !18)
!2346 = !DIDerivedType(tag: DW_TAG_member, name: "first", scope: !2324, file: !221, line: 217, baseType: !18, size: 32)
!2347 = !DIDerivedType(tag: DW_TAG_member, name: "second", scope: !2324, file: !221, line: 218, baseType: !18, size: 32, offset: 32)
!2348 = !DISubprogram(name: "pair", scope: !2324, file: !221, line: 314, type: !2349, scopeLine: 314, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2349 = !DISubroutineType(types: !2350)
!2350 = !{null, !2351, !2352}
!2351 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2324, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2352 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2353, size: 64)
!2353 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2324)
!2354 = !DISubprogram(name: "pair", scope: !2324, file: !221, line: 315, type: !2355, scopeLine: 315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2355 = !DISubroutineType(types: !2356)
!2356 = !{null, !2351, !2357}
!2357 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !2324, size: 64)
!2358 = !DISubprogram(name: "operator=", linkageName: "_ZNSt4pairIjjEaSERKS0_", scope: !2324, file: !221, line: 390, type: !2359, scopeLine: 390, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2359 = !DISubroutineType(types: !2360)
!2360 = !{!2361, !2351, !2362}
!2361 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2324, size: 64)
!2362 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !2363, file: !260, line: 2201, baseType: !2352)
!2363 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, const std::pair<unsigned int, unsigned int> &, const std::__nonesuch &>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !2364, identifier: "_ZTSSt11conditionalILb1ERKSt4pairIjjERKSt10__nonesuchE")
!2364 = !{!263, !2365, !265}
!2365 = !DITemplateTypeParameter(name: "_Iftrue", type: !2352)
!2366 = !DISubprogram(name: "operator=", linkageName: "_ZNSt4pairIjjEaSEOS0_", scope: !2324, file: !221, line: 401, type: !2367, scopeLine: 401, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2367 = !DISubroutineType(types: !2368)
!2368 = !{!2361, !2351, !2369}
!2369 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !2370, file: !260, line: 2201, baseType: !2357)
!2370 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, std::pair<unsigned int, unsigned int> &&, std::__nonesuch &&>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !2371, identifier: "_ZTSSt11conditionalILb1EOSt4pairIjjEOSt10__nonesuchE")
!2371 = !{!263, !2372, !276}
!2372 = !DITemplateTypeParameter(name: "_Iftrue", type: !2357)
!2373 = !DISubprogram(name: "swap", linkageName: "_ZNSt4pairIjjE4swapERS0_", scope: !2324, file: !221, line: 439, type: !2374, scopeLine: 439, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2374 = !DISubroutineType(types: !2375)
!2375 = !{null, !2351, !2361}
!2376 = !{!2377, !2378}
!2377 = !DITemplateTypeParameter(name: "_T1", type: !18)
!2378 = !DITemplateTypeParameter(name: "_T2", type: !18)
!2379 = !DISubprogram(name: "iSort<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >", linkageName: "_ZN7intSort5iSortISt4pairIjjE8getFirstIjEEEvPT_llT0_", scope: !2381, file: !2380, line: 265, type: !2382, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2391, retainedNodes: !45)
!2380 = !DIFile(filename: "./blockRadixSort.h", directory: "/data/compilers/tests/ligra/apps")
!2381 = !DINamespace(name: "intSort", scope: null)
!2382 = !DISubroutineType(types: !2383)
!2383 = !{null, !2384, !52, !52, !2385}
!2384 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2324, size: 64)
!2385 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getFirst<unsigned int>", file: !113, line: 52, size: 8, flags: DIFlagTypePassByValue, elements: !2386, templateParams: !1241, identifier: "_ZTS8getFirstIjE")
!2386 = !{!2387}
!2387 = !DISubprogram(name: "operator()", linkageName: "_ZN8getFirstIjEclESt4pairIjjE", scope: !2385, file: !113, line: 52, type: !2388, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2388 = !DISubroutineType(types: !2389)
!2389 = !{!50, !2390, !2324}
!2390 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2385, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2391 = !{!2392, !2393}
!2392 = !DITemplateTypeParameter(name: "E", type: !2324)
!2393 = !DITemplateTypeParameter(name: "Func", type: !2385)
!2394 = !DISubprogram(name: "scanIBack<unsigned int, long, minF<unsigned int> >", linkageName: "_ZN8sequence9scanIBackIjl4minFIjEEET_PS3_S4_T0_T1_S3_", scope: !55, file: !54, line: 225, type: !2395, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2404, retainedNodes: !45)
!2395 = !DISubroutineType(types: !2396)
!2396 = !{!18, !1175, !1175, !52, !2397, !18}
!2397 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "minF<unsigned int>", file: !54, line: 54, size: 8, flags: DIFlagTypePassByValue, elements: !2398, templateParams: !1241, identifier: "_ZTS4minFIjE")
!2398 = !{!2399}
!2399 = !DISubprogram(name: "operator()", linkageName: "_ZNK4minFIjEclERKjS2_", scope: !2397, file: !54, line: 54, type: !2400, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2400 = !DISubroutineType(types: !2401)
!2401 = !{!18, !2402, !907, !907}
!2402 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2403, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2403 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2397)
!2404 = !{!1512, !60, !2405}
!2405 = !DITemplateTypeParameter(name: "F", type: !2397)
!2406 = !DISubprogram(name: "iSort<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>", linkageName: "_ZN7intSort5iSortISt4pairIjjE8getFirstIjEmEEvPT_PT1_llbT0_", scope: !2381, file: !2380, line: 252, type: !2407, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2409, retainedNodes: !45)
!2407 = !DISubroutineType(types: !2408)
!2408 = !{null, !2384, !1345, !52, !52, !92, !2385}
!2409 = !{!2392, !2410, !2411}
!2410 = !DITemplateTypeParameter(name: "F", type: !2385)
!2411 = !DITemplateTypeParameter(name: "oint", type: !86)
!2412 = !DISubprogram(name: "iSortSpace<std::pair<unsigned int, unsigned int> >", linkageName: "_ZN7intSort10iSortSpaceISt4pairIjjEEEll", scope: !2381, file: !2380, line: 184, type: !2413, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2415, retainedNodes: !45)
!2413 = !DISubroutineType(types: !2414)
!2414 = !{!52, !52}
!2415 = !{!2392}
!2416 = !DISubprogram(name: "iSort<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>", linkageName: "_ZN7intSort5iSortISt4pairIjjE8getFirstIjEmEEvPT_PT1_llbPcT0_", scope: !2381, file: !2380, line: 239, type: !2417, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2409, retainedNodes: !45)
!2417 = !DISubroutineType(types: !2418)
!2418 = !{null, !2384, !1345, !52, !52, !92, !81, !2385}
!2419 = !DISubprogram(name: "iSortX<unsigned int, std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>", linkageName: "_ZN7intSort6iSortXIjSt4pairIjjE8getFirstIjEmEEvPT0_PT2_llbPcT1_", scope: !2381, file: !2380, line: 197, type: !2417, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2420, retainedNodes: !45)
!2420 = !{!2421, !2392, !2410, !2411}
!2421 = !DITemplateTypeParameter(name: "bint", type: !18)
!2422 = !DISubprogram(name: "iSortX<unsigned long, std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>", linkageName: "_ZN7intSort6iSortXImSt4pairIjjE8getFirstIjEmEEvPT0_PT2_llbPcT1_", scope: !2381, file: !2380, line: 197, type: !2417, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2423, retainedNodes: !45)
!2423 = !{!2424, !2392, !2410, !2411}
!2424 = !DITemplateTypeParameter(name: "bint", type: !86)
!2425 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2426, size: 64)
!2426 = !DIDerivedType(tag: DW_TAG_typedef, name: "bucketsT", scope: !2427, file: !2380, line: 199, baseType: !2478)
!2427 = distinct !DISubprogram(name: "iSortX<unsigned int, std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>", linkageName: "_ZN7intSort6iSortXIjSt4pairIjjE8getFirstIjEmEEvPT0_PT2_llbPcT1_", scope: !2381, file: !2380, line: 197, type: !2417, scopeLine: 198, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2420, retainedNodes: !2428)
!2428 = !{!2429, !2430, !2431, !2432, !2433, !2434, !2435, !2436, !2437, !2438, !2439, !2440, !2441, !2442, !2443, !2446, !2452, !2453, !2454, !2455, !2457, !2462, !2463, !2464, !2465, !2467, !2470, !2471, !2472, !2473, !2475, !2477}
!2429 = !DILocalVariable(name: "A", arg: 1, scope: !2427, file: !2380, line: 197, type: !2384)
!2430 = !DILocalVariable(name: "bucketOffsets", arg: 2, scope: !2427, file: !2380, line: 197, type: !1345)
!2431 = !DILocalVariable(name: "n", arg: 3, scope: !2427, file: !2380, line: 197, type: !52)
!2432 = !DILocalVariable(name: "m", arg: 4, scope: !2427, file: !2380, line: 197, type: !52)
!2433 = !DILocalVariable(name: "bottomUp", arg: 5, scope: !2427, file: !2380, line: 197, type: !92)
!2434 = !DILocalVariable(name: "tmpSpace", arg: 6, scope: !2427, file: !2380, line: 198, type: !81)
!2435 = !DILocalVariable(name: "f", arg: 7, scope: !2427, file: !2380, line: 198, type: !2385)
!2436 = !DILocalVariable(name: "esize", scope: !2427, file: !2380, line: 200, type: !52)
!2437 = !DILocalVariable(name: "bits", scope: !2427, file: !2380, line: 202, type: !52)
!2438 = !DILocalVariable(name: "numBK", scope: !2427, file: !2380, line: 203, type: !52)
!2439 = !DILocalVariable(name: "B", scope: !2427, file: !2380, line: 206, type: !2384)
!2440 = !DILocalVariable(name: "Bsize", scope: !2427, file: !2380, line: 207, type: !52)
!2441 = !DILocalVariable(name: "BK", scope: !2427, file: !2380, line: 209, type: !2425)
!2442 = !DILocalVariable(name: "BKsize", scope: !2427, file: !2380, line: 210, type: !52)
!2443 = !DILocalVariable(name: "Tmp", scope: !2427, file: !2380, line: 211, type: !2444)
!2444 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2445, size: 64)
!2445 = !DIDerivedType(tag: DW_TAG_typedef, name: "bIndexT", scope: !2381, file: !2380, line: 51, baseType: !64)
!2446 = !DILocalVariable(name: "__init", scope: !2447, type: !52, flags: DIFlagArtificial)
!2447 = distinct !DILexicalBlock(scope: !2448, file: !2380, line: 217, column: 2)
!2448 = distinct !DILexicalBlock(scope: !2449, file: !2380, line: 216, column: 34)
!2449 = distinct !DILexicalBlock(scope: !2450, file: !2380, line: 216, column: 11)
!2450 = distinct !DILexicalBlock(scope: !2451, file: !2380, line: 213, column: 28)
!2451 = distinct !DILexicalBlock(scope: !2427, file: !2380, line: 213, column: 9)
!2452 = !DILocalVariable(name: "__limit", scope: !2447, type: !52, flags: DIFlagArtificial)
!2453 = !DILocalVariable(name: "__begin", scope: !2447, type: !52, flags: DIFlagArtificial)
!2454 = !DILocalVariable(name: "__end", scope: !2447, type: !52, flags: DIFlagArtificial)
!2455 = !DILocalVariable(name: "i", scope: !2456, file: !2380, line: 217, type: !52)
!2456 = distinct !DILexicalBlock(scope: !2447, file: !2380, line: 217, column: 2)
!2457 = !DILocalVariable(name: "__init", scope: !2458, type: !52, flags: DIFlagArtificial)
!2458 = distinct !DILexicalBlock(scope: !2459, file: !2380, line: 226, column: 8)
!2459 = distinct !DILexicalBlock(scope: !2460, file: !2380, line: 226, column: 7)
!2460 = distinct !DILexicalBlock(scope: !2461, file: !2380, line: 225, column: 32)
!2461 = distinct !DILexicalBlock(scope: !2427, file: !2380, line: 225, column: 9)
!2462 = !DILocalVariable(name: "__limit", scope: !2458, type: !52, flags: DIFlagArtificial)
!2463 = !DILocalVariable(name: "__begin", scope: !2458, type: !52, flags: DIFlagArtificial)
!2464 = !DILocalVariable(name: "__end", scope: !2458, type: !52, flags: DIFlagArtificial)
!2465 = !DILocalVariable(name: "i", scope: !2466, file: !2380, line: 226, type: !52)
!2466 = distinct !DILexicalBlock(scope: !2458, file: !2380, line: 226, column: 8)
!2467 = !DILocalVariable(name: "__init", scope: !2468, type: !52, flags: DIFlagArtificial)
!2468 = distinct !DILexicalBlock(scope: !2469, file: !2380, line: 227, column: 8)
!2469 = distinct !DILexicalBlock(scope: !2460, file: !2380, line: 227, column: 7)
!2470 = !DILocalVariable(name: "__limit", scope: !2468, type: !52, flags: DIFlagArtificial)
!2471 = !DILocalVariable(name: "__begin", scope: !2468, type: !52, flags: DIFlagArtificial)
!2472 = !DILocalVariable(name: "__end", scope: !2468, type: !52, flags: DIFlagArtificial)
!2473 = !DILocalVariable(name: "i", scope: !2474, file: !2380, line: 227, type: !52)
!2474 = distinct !DILexicalBlock(scope: !2468, file: !2380, line: 227, column: 8)
!2475 = !DILocalVariable(name: "v", scope: !2476, file: !2380, line: 228, type: !52)
!2476 = distinct !DILexicalBlock(scope: !2474, file: !2380, line: 227, column: 46)
!2477 = !DILocalVariable(name: "vn", scope: !2476, file: !2380, line: 229, type: !52)
!2478 = !DICompositeType(tag: DW_TAG_array_type, baseType: !18, size: 8192, elements: !2479)
!2479 = !{!2480}
!2480 = !DISubrange(count: 256)
!2481 = !DISubprogram(name: "radixStep<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned int>", linkageName: "_ZN7intSort9radixStepISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEjEEvPT_S8_PhPA256_T1_lllbT0_", scope: !2381, file: !2380, line: 93, type: !2482, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2499, retainedNodes: !45)
!2482 = !DISubroutineType(types: !2483)
!2483 = !{null, !2384, !2384, !2484, !2485, !52, !52, !52, !92, !2486}
!2484 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !64, size: 64)
!2485 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2478, size: 64)
!2486 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >", scope: !2381, file: !2380, line: 131, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2487, templateParams: !2498, identifier: "_ZTSN7intSort5eBitsISt4pairIjjE8getFirstIjEEE")
!2487 = !{!2488, !2489, !2490, !2491, !2495}
!2488 = !DIDerivedType(tag: DW_TAG_member, name: "_f", scope: !2486, file: !2380, line: 132, baseType: !2385, size: 8)
!2489 = !DIDerivedType(tag: DW_TAG_member, name: "_mask", scope: !2486, file: !2380, line: 132, baseType: !52, size: 64, offset: 64)
!2490 = !DIDerivedType(tag: DW_TAG_member, name: "_offset", scope: !2486, file: !2380, line: 132, baseType: !52, size: 64, offset: 128)
!2491 = !DISubprogram(name: "eBits", scope: !2486, file: !2380, line: 133, type: !2492, scopeLine: 133, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2492 = !DISubroutineType(types: !2493)
!2493 = !{null, !2494, !52, !52, !2385}
!2494 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2486, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2495 = !DISubprogram(name: "operator()", linkageName: "_ZN7intSort5eBitsISt4pairIjjE8getFirstIjEEclES2_", scope: !2486, file: !2380, line: 135, type: !2496, scopeLine: 135, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2496 = !DISubroutineType(types: !2497)
!2497 = !{!52, !2494, !2324}
!2498 = !{!2392, !2410}
!2499 = !{!2392, !2500, !2421}
!2500 = !DITemplateTypeParameter(name: "F", type: !2486)
!2501 = !DISubprogram(name: "radixLoopBottomUp<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned int>", linkageName: "_ZN7intSort17radixLoopBottomUpISt4pairIjjE8getFirstIjEjEEvPT_S6_PhPA256_T1_lllbT0_", scope: !2381, file: !2380, line: 140, type: !2502, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2504, retainedNodes: !45)
!2502 = !DISubroutineType(types: !2503)
!2503 = !{null, !2384, !2384, !2484, !2485, !52, !52, !52, !92, !2385}
!2504 = !{!2392, !2410, !2421}
!2505 = !DISubprogram(name: "radixLoopTopDown<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned int>", linkageName: "_ZN7intSort16radixLoopTopDownISt4pairIjjE8getFirstIjEjEEvPT_S6_PhPA256_T1_lllT0_", scope: !2381, file: !2380, line: 155, type: !2506, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2504, retainedNodes: !45)
!2506 = !DISubroutineType(types: !2507)
!2507 = !{null, !2384, !2384, !2484, !2485, !52, !52, !52, !2385}
!2508 = !DISubprogram(name: "scanIBack<unsigned long, long, minF<unsigned long> >", linkageName: "_ZN8sequence9scanIBackIml4minFImEEET_PS3_S4_T0_T1_S3_", scope: !55, file: !54, line: 225, type: !2509, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2518, retainedNodes: !45)
!2509 = !DISubroutineType(types: !2510)
!2510 = !{!86, !1345, !1345, !52, !2511, !86}
!2511 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "minF<unsigned long>", file: !54, line: 54, size: 8, flags: DIFlagTypePassByValue, elements: !2512, templateParams: !1381, identifier: "_ZTS4minFImE")
!2512 = !{!2513}
!2513 = !DISubprogram(name: "operator()", linkageName: "_ZNK4minFImEclERKmS2_", scope: !2511, file: !54, line: 54, type: !2514, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2514 = !DISubroutineType(types: !2515)
!2515 = !{!86, !2516, !1376, !1376}
!2516 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2517, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2517 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2511)
!2518 = !{!2519, !60, !2520}
!2519 = !DITemplateTypeParameter(name: "ET", type: !86)
!2520 = !DITemplateTypeParameter(name: "F", type: !2511)
!2521 = !DISubprogram(name: "radixStepSerial<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned int>", linkageName: "_ZN7intSort15radixStepSerialISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEjEEvPT_S8_PhPT1_llT0_", scope: !2381, file: !2380, line: 75, type: !2522, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2499, retainedNodes: !45)
!2522 = !DISubroutineType(types: !2523)
!2523 = !{null, !2384, !2384, !2484, !1175, !52, !52, !2486}
!2524 = !DISubprogram(name: "radixBlock<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned int>", linkageName: "_ZN7intSort10radixBlockISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEjEEvPT_S8_PhPT1_SB_SA_llT0_", scope: !2381, file: !2380, line: 54, type: !2525, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2499, retainedNodes: !45)
!2525 = !DISubroutineType(types: !2526)
!2526 = !{null, !2384, !2384, !2484, !1175, !1175, !18, !52, !52, !2486}
!2527 = !DISubprogram(name: "scan<unsigned int, long, addF<unsigned int> >", linkageName: "_ZN8sequence4scanIjl4addFIjEEET_PS3_S4_T0_T1_S3_", scope: !55, file: !54, line: 213, type: !2528, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2530, retainedNodes: !45)
!2528 = !DISubroutineType(types: !2529)
!2529 = !{!18, !1175, !1175, !52, !1516, !18}
!2530 = !{!1512, !60, !1524}
!2531 = !DISubprogram(name: "scanSerial<unsigned int, long, addF<unsigned int> >", linkageName: "_ZN8sequence10scanSerialIjl4addFIjEEET_PS3_S4_T0_T1_S3_", scope: !55, file: !54, line: 192, type: !2528, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2530, retainedNodes: !45)
!2532 = !DISubprogram(name: "scan<unsigned int, long, addF<unsigned int>, sequence::getA<unsigned int, long> >", linkageName: "_ZN8sequence4scanIjl4addFIjENS_4getAIjlEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 198, type: !2533, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2535, retainedNodes: !45)
!2533 = !DISubroutineType(types: !2534)
!2534 = !{!18, !1175, !52, !52, !1516, !1501, !18, !92, !92}
!2535 = !{!1512, !60, !1524, !1525}
!2536 = !DISubprogram(name: "scanSerial<unsigned int, long, addF<unsigned int>, sequence::getA<unsigned int, long> >", linkageName: "_ZN8sequence10scanSerialIjl4addFIjENS_4getAIjlEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 169, type: !2533, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2535, retainedNodes: !45)
!2537 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getA<unsigned long, long>", scope: !55, file: !54, line: 98, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2538, templateParams: !2547, identifier: "_ZTSN8sequence4getAImlEE")
!2538 = !{!2539, !2540, !2544}
!2539 = !DIDerivedType(tag: DW_TAG_member, name: "A", scope: !2537, file: !54, line: 99, baseType: !1345, size: 64)
!2540 = !DISubprogram(name: "getA", scope: !2537, file: !54, line: 100, type: !2541, scopeLine: 100, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2541 = !DISubroutineType(types: !2542)
!2542 = !{null, !2543, !1345}
!2543 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2537, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2544 = !DISubprogram(name: "operator()", linkageName: "_ZN8sequence4getAImlEclEl", scope: !2537, file: !54, line: 101, type: !2545, scopeLine: 101, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2545 = !DISubroutineType(types: !2546)
!2546 = !{!86, !2543, !52}
!2547 = !{!2519, !60}
!2548 = !DISubprogram(name: "scan<unsigned long, long, minF<unsigned long>, sequence::getA<unsigned long, long> >", linkageName: "_ZN8sequence4scanIml4minFImENS_4getAImlEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 198, type: !2549, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2551, retainedNodes: !45)
!2549 = !DISubroutineType(types: !2550)
!2550 = !{!86, !1345, !52, !52, !2511, !2537, !86, !92, !92}
!2551 = !{!2519, !60, !2520, !2552}
!2552 = !DITemplateTypeParameter(name: "G", type: !2537)
!2553 = !DISubprogram(name: "scanSerial<unsigned long, long, minF<unsigned long>, sequence::getA<unsigned long, long> >", linkageName: "_ZN8sequence10scanSerialIml4minFImENS_4getAImlEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 169, type: !2549, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2551, retainedNodes: !45)
!2554 = !DISubprogram(name: "reduceSerial<unsigned long, long, minF<unsigned long>, sequence::getA<unsigned long, long> >", linkageName: "_ZN8sequence12reduceSerialIml4minFImENS_4getAImlEEEET_T0_S6_T1_T2_", scope: !55, file: !54, line: 127, type: !2555, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2557, retainedNodes: !45)
!2555 = !DISubroutineType(types: !2556)
!2556 = !{!86, !52, !52, !2511, !2537}
!2557 = !{!2558, !60, !2520, !2552}
!2558 = !DITemplateTypeParameter(name: "OT", type: !86)
!2559 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2560, size: 64)
!2560 = !DIDerivedType(tag: DW_TAG_typedef, name: "bucketsT", scope: !2561, file: !2380, line: 199, baseType: !2610)
!2561 = distinct !DISubprogram(name: "iSortX<unsigned long, std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>", linkageName: "_ZN7intSort6iSortXImSt4pairIjjE8getFirstIjEmEEvPT0_PT2_llbPcT1_", scope: !2381, file: !2380, line: 197, type: !2417, scopeLine: 198, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2423, retainedNodes: !2562)
!2562 = !{!2563, !2564, !2565, !2566, !2567, !2568, !2569, !2570, !2571, !2572, !2573, !2574, !2575, !2576, !2577, !2578, !2584, !2585, !2586, !2587, !2589, !2594, !2595, !2596, !2597, !2599, !2602, !2603, !2604, !2605, !2607, !2609}
!2563 = !DILocalVariable(name: "A", arg: 1, scope: !2561, file: !2380, line: 197, type: !2384)
!2564 = !DILocalVariable(name: "bucketOffsets", arg: 2, scope: !2561, file: !2380, line: 197, type: !1345)
!2565 = !DILocalVariable(name: "n", arg: 3, scope: !2561, file: !2380, line: 197, type: !52)
!2566 = !DILocalVariable(name: "m", arg: 4, scope: !2561, file: !2380, line: 197, type: !52)
!2567 = !DILocalVariable(name: "bottomUp", arg: 5, scope: !2561, file: !2380, line: 197, type: !92)
!2568 = !DILocalVariable(name: "tmpSpace", arg: 6, scope: !2561, file: !2380, line: 198, type: !81)
!2569 = !DILocalVariable(name: "f", arg: 7, scope: !2561, file: !2380, line: 198, type: !2385)
!2570 = !DILocalVariable(name: "esize", scope: !2561, file: !2380, line: 200, type: !52)
!2571 = !DILocalVariable(name: "bits", scope: !2561, file: !2380, line: 202, type: !52)
!2572 = !DILocalVariable(name: "numBK", scope: !2561, file: !2380, line: 203, type: !52)
!2573 = !DILocalVariable(name: "B", scope: !2561, file: !2380, line: 206, type: !2384)
!2574 = !DILocalVariable(name: "Bsize", scope: !2561, file: !2380, line: 207, type: !52)
!2575 = !DILocalVariable(name: "BK", scope: !2561, file: !2380, line: 209, type: !2559)
!2576 = !DILocalVariable(name: "BKsize", scope: !2561, file: !2380, line: 210, type: !52)
!2577 = !DILocalVariable(name: "Tmp", scope: !2561, file: !2380, line: 211, type: !2444)
!2578 = !DILocalVariable(name: "__init", scope: !2579, type: !52, flags: DIFlagArtificial)
!2579 = distinct !DILexicalBlock(scope: !2580, file: !2380, line: 217, column: 2)
!2580 = distinct !DILexicalBlock(scope: !2581, file: !2380, line: 216, column: 34)
!2581 = distinct !DILexicalBlock(scope: !2582, file: !2380, line: 216, column: 11)
!2582 = distinct !DILexicalBlock(scope: !2583, file: !2380, line: 213, column: 28)
!2583 = distinct !DILexicalBlock(scope: !2561, file: !2380, line: 213, column: 9)
!2584 = !DILocalVariable(name: "__limit", scope: !2579, type: !52, flags: DIFlagArtificial)
!2585 = !DILocalVariable(name: "__begin", scope: !2579, type: !52, flags: DIFlagArtificial)
!2586 = !DILocalVariable(name: "__end", scope: !2579, type: !52, flags: DIFlagArtificial)
!2587 = !DILocalVariable(name: "i", scope: !2588, file: !2380, line: 217, type: !52)
!2588 = distinct !DILexicalBlock(scope: !2579, file: !2380, line: 217, column: 2)
!2589 = !DILocalVariable(name: "__init", scope: !2590, type: !52, flags: DIFlagArtificial)
!2590 = distinct !DILexicalBlock(scope: !2591, file: !2380, line: 226, column: 8)
!2591 = distinct !DILexicalBlock(scope: !2592, file: !2380, line: 226, column: 7)
!2592 = distinct !DILexicalBlock(scope: !2593, file: !2380, line: 225, column: 32)
!2593 = distinct !DILexicalBlock(scope: !2561, file: !2380, line: 225, column: 9)
!2594 = !DILocalVariable(name: "__limit", scope: !2590, type: !52, flags: DIFlagArtificial)
!2595 = !DILocalVariable(name: "__begin", scope: !2590, type: !52, flags: DIFlagArtificial)
!2596 = !DILocalVariable(name: "__end", scope: !2590, type: !52, flags: DIFlagArtificial)
!2597 = !DILocalVariable(name: "i", scope: !2598, file: !2380, line: 226, type: !52)
!2598 = distinct !DILexicalBlock(scope: !2590, file: !2380, line: 226, column: 8)
!2599 = !DILocalVariable(name: "__init", scope: !2600, type: !52, flags: DIFlagArtificial)
!2600 = distinct !DILexicalBlock(scope: !2601, file: !2380, line: 227, column: 8)
!2601 = distinct !DILexicalBlock(scope: !2592, file: !2380, line: 227, column: 7)
!2602 = !DILocalVariable(name: "__limit", scope: !2600, type: !52, flags: DIFlagArtificial)
!2603 = !DILocalVariable(name: "__begin", scope: !2600, type: !52, flags: DIFlagArtificial)
!2604 = !DILocalVariable(name: "__end", scope: !2600, type: !52, flags: DIFlagArtificial)
!2605 = !DILocalVariable(name: "i", scope: !2606, file: !2380, line: 227, type: !52)
!2606 = distinct !DILexicalBlock(scope: !2600, file: !2380, line: 227, column: 8)
!2607 = !DILocalVariable(name: "v", scope: !2608, file: !2380, line: 228, type: !52)
!2608 = distinct !DILexicalBlock(scope: !2606, file: !2380, line: 227, column: 46)
!2609 = !DILocalVariable(name: "vn", scope: !2608, file: !2380, line: 229, type: !52)
!2610 = !DICompositeType(tag: DW_TAG_array_type, baseType: !86, size: 16384, elements: !2479)
!2611 = !DISubprogram(name: "radixStep<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned long>", linkageName: "_ZN7intSort9radixStepISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEmEEvPT_S8_PhPA256_T1_lllbT0_", scope: !2381, file: !2380, line: 93, type: !2612, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2615, retainedNodes: !45)
!2612 = !DISubroutineType(types: !2613)
!2613 = !{null, !2384, !2384, !2484, !2614, !52, !52, !52, !92, !2486}
!2614 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2610, size: 64)
!2615 = !{!2392, !2500, !2424}
!2616 = !DISubprogram(name: "radixLoopBottomUp<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>", linkageName: "_ZN7intSort17radixLoopBottomUpISt4pairIjjE8getFirstIjEmEEvPT_S6_PhPA256_T1_lllbT0_", scope: !2381, file: !2380, line: 140, type: !2617, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2619, retainedNodes: !45)
!2617 = !DISubroutineType(types: !2618)
!2618 = !{null, !2384, !2384, !2484, !2614, !52, !52, !52, !92, !2385}
!2619 = !{!2392, !2410, !2424}
!2620 = !DISubprogram(name: "radixLoopTopDown<std::pair<unsigned int, unsigned int>, getFirst<unsigned int>, unsigned long>", linkageName: "_ZN7intSort16radixLoopTopDownISt4pairIjjE8getFirstIjEmEEvPT_S6_PhPA256_T1_lllT0_", scope: !2381, file: !2380, line: 155, type: !2621, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2619, retainedNodes: !45)
!2621 = !DISubroutineType(types: !2622)
!2622 = !{null, !2384, !2384, !2484, !2614, !52, !52, !52, !2385}
!2623 = !DISubprogram(name: "radixStepSerial<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned long>", linkageName: "_ZN7intSort15radixStepSerialISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEmEEvPT_S8_PhPT1_llT0_", scope: !2381, file: !2380, line: 75, type: !2624, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2615, retainedNodes: !45)
!2624 = !DISubroutineType(types: !2625)
!2625 = !{null, !2384, !2384, !2484, !1345, !52, !52, !2486}
!2626 = !DISubprogram(name: "radixBlock<std::pair<unsigned int, unsigned int>, intSort::eBits<std::pair<unsigned int, unsigned int>, getFirst<unsigned int> >, unsigned long>", linkageName: "_ZN7intSort10radixBlockISt4pairIjjENS_5eBitsIS2_8getFirstIjEEEmEEvPT_S8_PhPT1_SB_SA_llT0_", scope: !2381, file: !2380, line: 54, type: !2627, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2615, retainedNodes: !45)
!2627 = !DISubroutineType(types: !2628)
!2628 = !{null, !2384, !2384, !2484, !1345, !1345, !86, !52, !52, !2486}
!2629 = !DISubprogram(name: "scan<unsigned long, long, addF<unsigned long> >", linkageName: "_ZN8sequence4scanIml4addFImEEET_PS3_S4_T0_T1_S3_", scope: !55, file: !54, line: 213, type: !2630, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2639, retainedNodes: !45)
!2630 = !DISubroutineType(types: !2631)
!2631 = !{!86, !1345, !1345, !52, !2632, !86}
!2632 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "addF<unsigned long>", file: !54, line: 51, size: 8, flags: DIFlagTypePassByValue, elements: !2633, templateParams: !1381, identifier: "_ZTS4addFImE")
!2633 = !{!2634}
!2634 = !DISubprogram(name: "operator()", linkageName: "_ZNK4addFImEclERKmS2_", scope: !2632, file: !54, line: 51, type: !2635, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2635 = !DISubroutineType(types: !2636)
!2636 = !{!86, !2637, !1376, !1376}
!2637 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2638, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2638 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2632)
!2639 = !{!2519, !60, !2640}
!2640 = !DITemplateTypeParameter(name: "F", type: !2632)
!2641 = !DISubprogram(name: "scanSerial<unsigned long, long, addF<unsigned long> >", linkageName: "_ZN8sequence10scanSerialIml4addFImEEET_PS3_S4_T0_T1_S3_", scope: !55, file: !54, line: 192, type: !2630, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2639, retainedNodes: !45)
!2642 = !DISubprogram(name: "scan<unsigned long, long, addF<unsigned long>, sequence::getA<unsigned long, long> >", linkageName: "_ZN8sequence4scanIml4addFImENS_4getAImlEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 198, type: !2643, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2645, retainedNodes: !45)
!2643 = !DISubroutineType(types: !2644)
!2644 = !{!86, !1345, !52, !52, !2632, !2537, !86, !92, !92}
!2645 = !{!2519, !60, !2640, !2552}
!2646 = !DISubprogram(name: "scanSerial<unsigned long, long, addF<unsigned long>, sequence::getA<unsigned long, long> >", linkageName: "_ZN8sequence10scanSerialIml4addFImENS_4getAImlEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 169, type: !2643, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2645, retainedNodes: !45)
!2647 = !DISubprogram(name: "reduceSerial<unsigned long, long, addF<unsigned long>, sequence::getA<unsigned long, long> >", linkageName: "_ZN8sequence12reduceSerialIml4addFImENS_4getAImlEEEET_T0_S6_T1_T2_", scope: !55, file: !54, line: 127, type: !2648, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2650, retainedNodes: !45)
!2648 = !DISubroutineType(types: !2649)
!2649 = !{!86, !52, !52, !2632, !2537}
!2650 = !{!2558, !60, !2640, !2552}
!2651 = !DISubprogram(name: "scan<unsigned int, long, minF<unsigned int>, sequence::getA<unsigned int, long> >", linkageName: "_ZN8sequence4scanIjl4minFIjENS_4getAIjlEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 198, type: !2652, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2654, retainedNodes: !45)
!2652 = !DISubroutineType(types: !2653)
!2653 = !{!18, !1175, !52, !52, !2397, !1501, !18, !92, !92}
!2654 = !{!1512, !60, !2405, !1525}
!2655 = !DISubprogram(name: "scanSerial<unsigned int, long, minF<unsigned int>, sequence::getA<unsigned int, long> >", linkageName: "_ZN8sequence10scanSerialIjl4minFIjENS_4getAIjlEEEET_PS5_T0_S7_T1_T2_S5_bb", scope: !55, file: !54, line: 169, type: !2652, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2654, retainedNodes: !45)
!2656 = !DISubprogram(name: "reduceSerial<unsigned int, long, minF<unsigned int>, sequence::getA<unsigned int, long> >", linkageName: "_ZN8sequence12reduceSerialIjl4minFIjENS_4getAIjlEEEET_T0_S6_T1_T2_", scope: !55, file: !54, line: 127, type: !2657, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2659, retainedNodes: !45)
!2657 = !DISubroutineType(types: !2658)
!2658 = !{!18, !52, !52, !2397, !1501}
!2659 = !{!1177, !60, !2405, !1525}
!2660 = !DISubprogram(name: "edgeMap<symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z7edgeMapI15symmetricVertex16vertexSubsetDataIN4pbbs5emptyEE5BFS_FES4_5graphIT_ERT0_T1_iRKj", scope: !192, file: !192, line: 280, type: !2661, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2663, retainedNodes: !45)
!2661 = !DISubroutineType(types: !2662)
!2662 = !{!771, !428, !1164, !754, !6, !907}
!2663 = !{!494, !1166, !1167}
!2664 = !DISubprogram(name: "edgeMapData<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z11edgeMapDataIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj", scope: !192, file: !192, line: 235, type: !2665, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2667, retainedNodes: !45)
!2665 = !DISubroutineType(types: !2666)
!2666 = !{!771, !498, !1164, !754, !6, !907}
!2667 = !{!1163, !494, !1166, !1167}
!2668 = !DISubprogram(name: "edgeMapDenseForward<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z19edgeMapDenseForwardIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 85, type: !2669, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2667, retainedNodes: !45)
!2669 = !DISubroutineType(types: !2670)
!2670 = !{!771, !428, !1164, !1181, !18}
!2671 = !DISubprogram(name: "edgeMapDense<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z12edgeMapDenseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 59, type: !2669, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2667, retainedNodes: !45)
!2672 = !DISubprogram(name: "edgeMapSparse_no_filter<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 157, type: !2673, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2667, retainedNodes: !45)
!2673 = !DISubroutineType(types: !2674)
!2674 = !{!771, !498, !431, !1164, !1175, !18, !1181, !18}
!2675 = !DISubprogram(name: "edgeMapSparse<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z13edgeMapSparseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 111, type: !2673, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2667, retainedNodes: !45)
!2676 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2677, size: 64)
!2677 = !DIDerivedType(tag: DW_TAG_typedef, name: "D", scope: !2678, file: !192, line: 86, baseType: !1016)
!2678 = distinct !DISubprogram(name: "edgeMapDenseForward<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z19edgeMapDenseForwardIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 85, type: !2679, scopeLine: 85, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2667, retainedNodes: !2681)
!2679 = !DISubroutineType(types: !2680)
!2680 = !{!771, !428, !1164, !1181, !1532}
!2681 = !{!2682, !2683, !2684, !2685, !2686, !2687, !2688, !2691, !2692, !2694, !2695, !2696, !2697, !2699, !2701, !2702, !2703, !2704, !2706, !2708, !2710, !2711, !2712, !2713}
!2682 = !DILocalVariable(name: "GA", arg: 1, scope: !2678, file: !192, line: 85, type: !428)
!2683 = !DILocalVariable(name: "vertexSubset", arg: 2, scope: !2678, file: !192, line: 85, type: !1164)
!2684 = !DILocalVariable(name: "f", arg: 3, scope: !2678, file: !192, line: 85, type: !1181)
!2685 = !DILocalVariable(name: "fl", arg: 4, scope: !2678, file: !192, line: 85, type: !1532)
!2686 = !DILocalVariable(name: "n", scope: !2678, file: !192, line: 87, type: !52)
!2687 = !DILocalVariable(name: "G", scope: !2678, file: !192, line: 88, type: !431)
!2688 = !DILocalVariable(name: "next", scope: !2689, file: !192, line: 90, type: !2676)
!2689 = distinct !DILexicalBlock(scope: !2690, file: !192, line: 89, column: 26)
!2690 = distinct !DILexicalBlock(scope: !2678, file: !192, line: 89, column: 7)
!2691 = !DILocalVariable(name: "g", scope: !2689, file: !192, line: 91, type: !1545)
!2692 = !DILocalVariable(name: "__init", scope: !2693, type: !52, flags: DIFlagArtificial)
!2693 = distinct !DILexicalBlock(scope: !2689, file: !192, line: 92, column: 5)
!2694 = !DILocalVariable(name: "__limit", scope: !2693, type: !52, flags: DIFlagArtificial)
!2695 = !DILocalVariable(name: "__begin", scope: !2693, type: !52, flags: DIFlagArtificial)
!2696 = !DILocalVariable(name: "__end", scope: !2693, type: !52, flags: DIFlagArtificial)
!2697 = !DILocalVariable(name: "i", scope: !2698, file: !192, line: 92, type: !52)
!2698 = distinct !DILexicalBlock(scope: !2693, file: !192, line: 92, column: 5)
!2699 = !DILocalVariable(name: "__init", scope: !2700, type: !52, flags: DIFlagArtificial)
!2700 = distinct !DILexicalBlock(scope: !2689, file: !192, line: 93, column: 5)
!2701 = !DILocalVariable(name: "__limit", scope: !2700, type: !52, flags: DIFlagArtificial)
!2702 = !DILocalVariable(name: "__begin", scope: !2700, type: !52, flags: DIFlagArtificial)
!2703 = !DILocalVariable(name: "__end", scope: !2700, type: !52, flags: DIFlagArtificial)
!2704 = !DILocalVariable(name: "i", scope: !2705, file: !192, line: 93, type: !52)
!2705 = distinct !DILexicalBlock(scope: !2700, file: !192, line: 93, column: 5)
!2706 = !DILocalVariable(name: "g", scope: !2707, file: !192, line: 100, type: !1565)
!2707 = distinct !DILexicalBlock(scope: !2690, file: !192, line: 99, column: 10)
!2708 = !DILocalVariable(name: "__init", scope: !2709, type: !52, flags: DIFlagArtificial)
!2709 = distinct !DILexicalBlock(scope: !2707, file: !192, line: 101, column: 5)
!2710 = !DILocalVariable(name: "__limit", scope: !2709, type: !52, flags: DIFlagArtificial)
!2711 = !DILocalVariable(name: "__begin", scope: !2709, type: !52, flags: DIFlagArtificial)
!2712 = !DILocalVariable(name: "__end", scope: !2709, type: !52, flags: DIFlagArtificial)
!2713 = !DILocalVariable(name: "i", scope: !2714, file: !192, line: 101, type: !52)
!2714 = distinct !DILexicalBlock(scope: !2709, file: !192, line: 101, column: 5)
!2715 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2716, size: 64)
!2716 = !DIDerivedType(tag: DW_TAG_typedef, name: "D", scope: !2717, file: !192, line: 60, baseType: !1016)
!2717 = distinct !DISubprogram(name: "edgeMapDense<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z12edgeMapDenseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 59, type: !2679, scopeLine: 59, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2667, retainedNodes: !2718)
!2718 = !{!2719, !2720, !2721, !2722, !2723, !2724, !2725, !2728, !2729, !2731, !2732, !2733, !2734, !2736, !2738, !2740, !2741, !2742, !2743}
!2719 = !DILocalVariable(name: "GA", arg: 1, scope: !2717, file: !192, line: 59, type: !428)
!2720 = !DILocalVariable(name: "vertexSubset", arg: 2, scope: !2717, file: !192, line: 59, type: !1164)
!2721 = !DILocalVariable(name: "f", arg: 3, scope: !2717, file: !192, line: 59, type: !1181)
!2722 = !DILocalVariable(name: "fl", arg: 4, scope: !2717, file: !192, line: 59, type: !1532)
!2723 = !DILocalVariable(name: "n", scope: !2717, file: !192, line: 61, type: !52)
!2724 = !DILocalVariable(name: "G", scope: !2717, file: !192, line: 62, type: !431)
!2725 = !DILocalVariable(name: "next", scope: !2726, file: !192, line: 64, type: !2715)
!2726 = distinct !DILexicalBlock(scope: !2727, file: !192, line: 63, column: 26)
!2727 = distinct !DILexicalBlock(scope: !2717, file: !192, line: 63, column: 7)
!2728 = !DILocalVariable(name: "g", scope: !2726, file: !192, line: 65, type: !1677)
!2729 = !DILocalVariable(name: "__init", scope: !2730, type: !52, flags: DIFlagArtificial)
!2730 = distinct !DILexicalBlock(scope: !2726, file: !192, line: 66, column: 5)
!2731 = !DILocalVariable(name: "__limit", scope: !2730, type: !52, flags: DIFlagArtificial)
!2732 = !DILocalVariable(name: "__begin", scope: !2730, type: !52, flags: DIFlagArtificial)
!2733 = !DILocalVariable(name: "__end", scope: !2730, type: !52, flags: DIFlagArtificial)
!2734 = !DILocalVariable(name: "v", scope: !2735, file: !192, line: 66, type: !52)
!2735 = distinct !DILexicalBlock(scope: !2730, file: !192, line: 66, column: 5)
!2736 = !DILocalVariable(name: "g", scope: !2737, file: !192, line: 74, type: !1689)
!2737 = distinct !DILexicalBlock(scope: !2727, file: !192, line: 73, column: 10)
!2738 = !DILocalVariable(name: "__init", scope: !2739, type: !52, flags: DIFlagArtificial)
!2739 = distinct !DILexicalBlock(scope: !2737, file: !192, line: 75, column: 5)
!2740 = !DILocalVariable(name: "__limit", scope: !2739, type: !52, flags: DIFlagArtificial)
!2741 = !DILocalVariable(name: "__begin", scope: !2739, type: !52, flags: DIFlagArtificial)
!2742 = !DILocalVariable(name: "__end", scope: !2739, type: !52, flags: DIFlagArtificial)
!2743 = !DILocalVariable(name: "v", scope: !2744, file: !192, line: 75, type: !52)
!2744 = distinct !DILexicalBlock(scope: !2739, file: !192, line: 75, column: 5)
!2745 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2746, size: 64)
!2746 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !2747, file: !192, line: 160, baseType: !797)
!2747 = distinct !DISubprogram(name: "edgeMapSparse_no_filter<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 157, type: !2748, scopeLine: 159, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2667, retainedNodes: !2750)
!2748 = !DISubroutineType(types: !2749)
!2749 = !{!771, !498, !431, !1164, !753, !126, !1181, !1532}
!2750 = !{!2751, !2752, !2753, !2754, !2755, !2756, !2757, !2758, !2759, !2760, !2761, !2762, !2763, !2764, !2765, !2766, !2796, !2798, !2800, !2801, !2802, !2803, !2805, !2807, !2809, !2810, !2811, !2812, !2814, !2818, !2819, !2820, !2821, !2823, !2826, !2827, !2828, !2829, !2831, !2832, !2833, !2834, !2836, !2840, !2841, !2842, !2843, !2845, !2851, !2852, !2853, !2854, !2856, !2866, !2867, !2869}
!2751 = !DILocalVariable(name: "GA", arg: 1, scope: !2747, file: !192, line: 157, type: !498)
!2752 = !DILocalVariable(name: "frontierVertices", arg: 2, scope: !2747, file: !192, line: 158, type: !431)
!2753 = !DILocalVariable(name: "indices", arg: 3, scope: !2747, file: !192, line: 158, type: !1164)
!2754 = !DILocalVariable(name: "offsets", arg: 4, scope: !2747, file: !192, line: 158, type: !753)
!2755 = !DILocalVariable(name: "m", arg: 5, scope: !2747, file: !192, line: 158, type: !126)
!2756 = !DILocalVariable(name: "f", arg: 6, scope: !2747, file: !192, line: 158, type: !1181)
!2757 = !DILocalVariable(name: "fl", arg: 7, scope: !2747, file: !192, line: 159, type: !1532)
!2758 = !DILocalVariable(name: "n", scope: !2747, file: !192, line: 161, type: !52)
!2759 = !DILocalVariable(name: "outEdgeCount", scope: !2747, file: !192, line: 162, type: !52)
!2760 = !DILocalVariable(name: "outEdges", scope: !2747, file: !192, line: 163, type: !2745)
!2761 = !DILocalVariable(name: "g", scope: !2747, file: !192, line: 165, type: !1725)
!2762 = !DILocalVariable(name: "b_size", scope: !2747, file: !192, line: 168, type: !779)
!2763 = !DILocalVariable(name: "n_blocks", scope: !2747, file: !192, line: 169, type: !779)
!2764 = !DILocalVariable(name: "cts", scope: !2747, file: !192, line: 171, type: !49)
!2765 = !DILocalVariable(name: "block_offs", scope: !2747, file: !192, line: 172, type: !1732)
!2766 = !DILocalVariable(name: "offsets_m", scope: !2747, file: !192, line: 174, type: !2767)
!2767 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_imap<unsigned int, (lambda at ./ligra.h:174:43)>", file: !1188, line: 44, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2768, templateParams: !2794, identifier: "_ZTS7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E")
!2768 = !{!2769, !2773, !2774, !2775, !2779, !2782, !2786, !2787, !2790, !2791}
!2769 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !2767, file: !1188, line: 46, baseType: !2770, size: 64)
!2770 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2747, file: !192, line: 174, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2771, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE_")
!2771 = !{!2772}
!2772 = !DIDerivedType(tag: DW_TAG_member, name: "offsets", scope: !2770, file: !192, line: 174, baseType: !1740, size: 64)
!2773 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !2767, file: !1188, line: 47, baseType: !779, size: 64, offset: 64)
!2774 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !2767, file: !1188, line: 47, baseType: !779, size: 64, offset: 128)
!2775 = !DISubprogram(name: "in_imap", scope: !2767, file: !1188, line: 48, type: !2776, scopeLine: 48, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2776 = !DISubroutineType(types: !2777)
!2777 = !{null, !2778, !779, !2770}
!2778 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2767, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2779 = !DISubprogram(name: "in_imap", scope: !2767, file: !1188, line: 49, type: !2780, scopeLine: 49, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2780 = !DISubroutineType(types: !2781)
!2781 = !{null, !2778, !779, !779, !2770}
!2782 = !DISubprogram(name: "operator[]", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EixEm", scope: !2767, file: !1188, line: 50, type: !2783, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2783 = !DISubroutineType(types: !2784)
!2784 = !{!2785, !2778, !1225}
!2785 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !2767, file: !1188, line: 45, baseType: !18)
!2786 = !DISubprogram(name: "operator()", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EclEm", scope: !2767, file: !1188, line: 51, type: !2783, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2787 = !DISubprogram(name: "cut", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E3cutEmm", scope: !2767, file: !1188, line: 52, type: !2788, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2788 = !DISubroutineType(types: !2789)
!2789 = !{!2767, !2778, !779, !779}
!2790 = !DISubprogram(name: "slice", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E5sliceEmm", scope: !2767, file: !1188, line: 53, type: !2788, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2791 = !DISubprogram(name: "size", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E4sizeEv", scope: !2767, file: !1188, line: 54, type: !2792, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2792 = !DISubroutineType(types: !2793)
!2793 = !{!779, !2778}
!2794 = !{!1242, !2795}
!2795 = !DITemplateTypeParameter(name: "F", type: !2770)
!2796 = !DILocalVariable(name: "lt", scope: !2747, file: !192, line: 175, type: !2797)
!2797 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2747, file: !192, line: 175, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRKjSJ_E_")
!2798 = !DILocalVariable(name: "__init", scope: !2799, type: !779, flags: DIFlagArtificial)
!2799 = distinct !DILexicalBlock(scope: !2747, file: !192, line: 176, column: 3)
!2800 = !DILocalVariable(name: "__limit", scope: !2799, type: !779, flags: DIFlagArtificial)
!2801 = !DILocalVariable(name: "__begin", scope: !2799, type: !779, flags: DIFlagArtificial)
!2802 = !DILocalVariable(name: "__end", scope: !2799, type: !779, flags: DIFlagArtificial)
!2803 = !DILocalVariable(name: "i", scope: !2804, file: !192, line: 176, type: !779)
!2804 = distinct !DILexicalBlock(scope: !2799, file: !192, line: 176, column: 3)
!2805 = !DILocalVariable(name: "s_val", scope: !2806, file: !192, line: 177, type: !779)
!2806 = distinct !DILexicalBlock(scope: !2804, file: !192, line: 176, column: 45)
!2807 = !DILocalVariable(name: "__init", scope: !2808, type: !779, flags: DIFlagArtificial)
!2808 = distinct !DILexicalBlock(scope: !2747, file: !192, line: 181, column: 3)
!2809 = !DILocalVariable(name: "__limit", scope: !2808, type: !779, flags: DIFlagArtificial)
!2810 = !DILocalVariable(name: "__begin", scope: !2808, type: !779, flags: DIFlagArtificial)
!2811 = !DILocalVariable(name: "__end", scope: !2808, type: !779, flags: DIFlagArtificial)
!2812 = !DILocalVariable(name: "i", scope: !2813, file: !192, line: 181, type: !779)
!2813 = distinct !DILexicalBlock(scope: !2808, file: !192, line: 181, column: 3)
!2814 = !DILocalVariable(name: "start", scope: !2815, file: !192, line: 184, type: !779)
!2815 = distinct !DILexicalBlock(scope: !2816, file: !192, line: 182, column: 64)
!2816 = distinct !DILexicalBlock(scope: !2817, file: !192, line: 182, column: 9)
!2817 = distinct !DILexicalBlock(scope: !2813, file: !192, line: 181, column: 46)
!2818 = !DILocalVariable(name: "end", scope: !2815, file: !192, line: 185, type: !779)
!2819 = !DILocalVariable(name: "start_o", scope: !2815, file: !192, line: 186, type: !126)
!2820 = !DILocalVariable(name: "k", scope: !2815, file: !192, line: 187, type: !126)
!2821 = !DILocalVariable(name: "j", scope: !2822, file: !192, line: 188, type: !779)
!2822 = distinct !DILexicalBlock(scope: !2815, file: !192, line: 188, column: 7)
!2823 = !DILocalVariable(name: "v", scope: !2824, file: !192, line: 189, type: !50)
!2824 = distinct !DILexicalBlock(scope: !2825, file: !192, line: 188, column: 40)
!2825 = distinct !DILexicalBlock(scope: !2822, file: !192, line: 188, column: 7)
!2826 = !DILocalVariable(name: "num_in", scope: !2824, file: !192, line: 190, type: !779)
!2827 = !DILocalVariable(name: "outSize", scope: !2747, file: !192, line: 199, type: !52)
!2828 = !DILocalVariable(name: "out", scope: !2747, file: !192, line: 202, type: !2745)
!2829 = !DILocalVariable(name: "__init", scope: !2830, type: !779, flags: DIFlagArtificial)
!2830 = distinct !DILexicalBlock(scope: !2747, file: !192, line: 204, column: 3)
!2831 = !DILocalVariable(name: "__limit", scope: !2830, type: !779, flags: DIFlagArtificial)
!2832 = !DILocalVariable(name: "__begin", scope: !2830, type: !779, flags: DIFlagArtificial)
!2833 = !DILocalVariable(name: "__end", scope: !2830, type: !779, flags: DIFlagArtificial)
!2834 = !DILocalVariable(name: "i", scope: !2835, file: !192, line: 204, type: !779)
!2835 = distinct !DILexicalBlock(scope: !2830, file: !192, line: 204, column: 3)
!2836 = !DILocalVariable(name: "start", scope: !2837, file: !192, line: 206, type: !779)
!2837 = distinct !DILexicalBlock(scope: !2838, file: !192, line: 205, column: 64)
!2838 = distinct !DILexicalBlock(scope: !2839, file: !192, line: 205, column: 9)
!2839 = distinct !DILexicalBlock(scope: !2835, file: !192, line: 204, column: 46)
!2840 = !DILocalVariable(name: "start_o", scope: !2837, file: !192, line: 207, type: !779)
!2841 = !DILocalVariable(name: "out_off", scope: !2837, file: !192, line: 208, type: !779)
!2842 = !DILocalVariable(name: "block_size", scope: !2837, file: !192, line: 209, type: !779)
!2843 = !DILocalVariable(name: "j", scope: !2844, file: !192, line: 210, type: !779)
!2844 = distinct !DILexicalBlock(scope: !2837, file: !192, line: 210, column: 7)
!2845 = !DILocalVariable(name: "__init", scope: !2846, type: !779, flags: DIFlagArtificial)
!2846 = distinct !DILexicalBlock(scope: !2847, file: !192, line: 220, column: 7)
!2847 = distinct !DILexicalBlock(scope: !2848, file: !192, line: 218, column: 27)
!2848 = distinct !DILexicalBlock(scope: !2849, file: !192, line: 218, column: 9)
!2849 = distinct !DILexicalBlock(scope: !2850, file: !192, line: 217, column: 31)
!2850 = distinct !DILexicalBlock(scope: !2747, file: !192, line: 217, column: 7)
!2851 = !DILocalVariable(name: "__limit", scope: !2846, type: !779, flags: DIFlagArtificial)
!2852 = !DILocalVariable(name: "__begin", scope: !2846, type: !779, flags: DIFlagArtificial)
!2853 = !DILocalVariable(name: "__end", scope: !2846, type: !779, flags: DIFlagArtificial)
!2854 = !DILocalVariable(name: "i", scope: !2855, file: !192, line: 220, type: !779)
!2855 = distinct !DILexicalBlock(scope: !2846, file: !192, line: 220, column: 7)
!2856 = !DILocalVariable(name: "get_key", scope: !2849, file: !192, line: 222, type: !2857)
!2857 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2747, file: !192, line: 222, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2858, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE0_")
!2858 = !{!2859, !2861}
!2859 = !DIDerivedType(tag: DW_TAG_member, name: "out", scope: !2857, file: !192, line: 222, baseType: !2860, size: 64)
!2860 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2745, size: 64)
!2861 = !DISubprogram(name: "operator()", scope: !2857, file: !192, line: 222, type: !2862, scopeLine: 222, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2862 = !DISubroutineType(types: !2863)
!2863 = !{!1136, !2864, !779}
!2864 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2865, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2865 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2857)
!2866 = !DILocalVariable(name: "nextIndices", scope: !2849, file: !192, line: 224, type: !2745)
!2867 = !DILocalVariable(name: "p", scope: !2849, file: !192, line: 225, type: !2868)
!2868 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2747, file: !192, line: 225, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRSt5tupleIJjS1_EEE_")
!2869 = !DILocalVariable(name: "nextM", scope: !2849, file: !192, line: 226, type: !779)
!2870 = !DISubprogram(name: "make_in_imap<unsigned int, (lambda at ./ligra.h:174:43)>", linkageName: "_Z12make_in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E7in_imapIS7_SA_EmSA_", scope: !1188, file: !1188, line: 59, type: !2871, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2794, retainedNodes: !45)
!2871 = !DISubroutineType(types: !2872)
!2872 = !{!2767, !86, !2770}
!2873 = !DISubprogram(name: "binary_search<in_imap<unsigned int, (lambda at ./ligra.h:174:43)>, (lambda at ./ligra.h:175:13)>", linkageName: "_ZN4pbbs13binary_searchI7in_imapIjZ23edgeMapSparse_no_filterINS_5emptyE15symmetricVertex16vertexSubsetDataIS3_E5BFS_FES5_IT_ER5graphIT0_EPSB_RT1_PjjRT2_jEUlmE_EZS2_IS3_S4_S6_S7_ES9_SD_SE_SG_SH_jSJ_jEUlRKjSN_E_EEmS8_NS8_1TERKSB_", scope: !811, file: !1845, line: 18, type: !2874, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2878, retainedNodes: !45)
!2874 = !DISubroutineType(types: !2875)
!2875 = !{!86, !2767, !18, !2876}
!2876 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2877, size: 64)
!2877 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2797)
!2878 = !{!2879, !2880}
!2879 = !DITemplateTypeParameter(name: "Sequence", type: !2767)
!2880 = !DITemplateTypeParameter(name: "F", type: !2797)
!2881 = !DISubprogram(name: "remDuplicates<(lambda at ./ligra.h:222:20)>", linkageName: "_Z13remDuplicatesIZ23edgeMapSparse_no_filterIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE0_EvRS7_SG_ll", scope: !54, file: !54, line: 359, type: !2882, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2885, retainedNodes: !45)
!2882 = !DISubroutineType(types: !2883)
!2883 = !{null, !2884, !1175, !52, !52}
!2884 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2857, size: 64)
!2885 = !{!2886}
!2886 = !DITemplateTypeParameter(name: "G", type: !2857)
!2887 = !DISubprogram(name: "filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>", linkageName: "_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 270, type: !2888, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2890, retainedNodes: !45)
!2888 = !DISubroutineType(types: !2889)
!2889 = !{!86, !796, !796, !86, !2868}
!2890 = !{!1868, !2891}
!2891 = !DITemplateTypeParameter(name: "PRED", type: !2868)
!2892 = !DISubprogram(name: "linear_search<in_imap<unsigned int, (lambda at ./ligra.h:174:43)>, (lambda at ./ligra.h:175:13)>", linkageName: "_ZN4pbbs13linear_searchI7in_imapIjZ23edgeMapSparse_no_filterINS_5emptyE15symmetricVertex16vertexSubsetDataIS3_E5BFS_FES5_IT_ER5graphIT0_EPSB_RT1_PjjRT2_jEUlmE_EZS2_IS3_S4_S6_S7_ES9_SD_SE_SG_SH_jSJ_jEUlRKjSN_E_EEmS8_NS8_1TERKSB_", scope: !811, file: !1845, line: 10, type: !2874, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2878, retainedNodes: !45)
!2893 = !DISubprogram(name: "filter_serial<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>", linkageName: "_ZN4pbbs13filter_serialISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 217, type: !2888, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2890, retainedNodes: !45)
!2894 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2895, size: 64)
!2895 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !2896, file: !192, line: 113, baseType: !797)
!2896 = distinct !DISubprogram(name: "edgeMapSparse<pbbs::empty, symmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z13edgeMapSparseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 111, type: !2748, scopeLine: 112, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2667, retainedNodes: !2897)
!2897 = !{!2898, !2899, !2900, !2901, !2902, !2903, !2904, !2905, !2906, !2907, !2908, !2911, !2912, !2914, !2915, !2916, !2917, !2919, !2921, !2922, !2923, !2925, !2927, !2928, !2929, !2930, !2932, !2934, !2935, !2938, !2944, !2945, !2946, !2947, !2949, !2959, !2961}
!2898 = !DILocalVariable(name: "GA", arg: 1, scope: !2896, file: !192, line: 111, type: !498)
!2899 = !DILocalVariable(name: "frontierVertices", arg: 2, scope: !2896, file: !192, line: 111, type: !431)
!2900 = !DILocalVariable(name: "indices", arg: 3, scope: !2896, file: !192, line: 111, type: !1164)
!2901 = !DILocalVariable(name: "degrees", arg: 4, scope: !2896, file: !192, line: 112, type: !753)
!2902 = !DILocalVariable(name: "m", arg: 5, scope: !2896, file: !192, line: 112, type: !126)
!2903 = !DILocalVariable(name: "f", arg: 6, scope: !2896, file: !192, line: 112, type: !1181)
!2904 = !DILocalVariable(name: "fl", arg: 7, scope: !2896, file: !192, line: 112, type: !1532)
!2905 = !DILocalVariable(name: "n", scope: !2896, file: !192, line: 114, type: !52)
!2906 = !DILocalVariable(name: "outEdges", scope: !2896, file: !192, line: 115, type: !2894)
!2907 = !DILocalVariable(name: "outEdgeCount", scope: !2896, file: !192, line: 116, type: !52)
!2908 = !DILocalVariable(name: "offsets", scope: !2909, file: !192, line: 119, type: !753)
!2909 = distinct !DILexicalBlock(scope: !2910, file: !192, line: 118, column: 26)
!2910 = distinct !DILexicalBlock(scope: !2896, file: !192, line: 118, column: 7)
!2911 = !DILocalVariable(name: "g", scope: !2909, file: !192, line: 122, type: !1930)
!2912 = !DILocalVariable(name: "__init", scope: !2913, type: !779, flags: DIFlagArtificial)
!2913 = distinct !DILexicalBlock(scope: !2909, file: !192, line: 123, column: 5)
!2914 = !DILocalVariable(name: "__limit", scope: !2913, type: !779, flags: DIFlagArtificial)
!2915 = !DILocalVariable(name: "__begin", scope: !2913, type: !779, flags: DIFlagArtificial)
!2916 = !DILocalVariable(name: "__end", scope: !2913, type: !779, flags: DIFlagArtificial)
!2917 = !DILocalVariable(name: "i", scope: !2918, file: !192, line: 123, type: !779)
!2918 = distinct !DILexicalBlock(scope: !2913, file: !192, line: 123, column: 5)
!2919 = !DILocalVariable(name: "v", scope: !2920, file: !192, line: 124, type: !126)
!2920 = distinct !DILexicalBlock(scope: !2918, file: !192, line: 123, column: 45)
!2921 = !DILocalVariable(name: "o", scope: !2920, file: !192, line: 124, type: !126)
!2922 = !DILocalVariable(name: "vert", scope: !2920, file: !192, line: 125, type: !432)
!2923 = !DILocalVariable(name: "g", scope: !2924, file: !192, line: 129, type: !1946)
!2924 = distinct !DILexicalBlock(scope: !2910, file: !192, line: 128, column: 10)
!2925 = !DILocalVariable(name: "__init", scope: !2926, type: !779, flags: DIFlagArtificial)
!2926 = distinct !DILexicalBlock(scope: !2924, file: !192, line: 130, column: 5)
!2927 = !DILocalVariable(name: "__limit", scope: !2926, type: !779, flags: DIFlagArtificial)
!2928 = !DILocalVariable(name: "__begin", scope: !2926, type: !779, flags: DIFlagArtificial)
!2929 = !DILocalVariable(name: "__end", scope: !2926, type: !779, flags: DIFlagArtificial)
!2930 = !DILocalVariable(name: "i", scope: !2931, file: !192, line: 130, type: !779)
!2931 = distinct !DILexicalBlock(scope: !2926, file: !192, line: 130, column: 5)
!2932 = !DILocalVariable(name: "v", scope: !2933, file: !192, line: 131, type: !126)
!2933 = distinct !DILexicalBlock(scope: !2931, file: !192, line: 130, column: 45)
!2934 = !DILocalVariable(name: "vert", scope: !2933, file: !192, line: 132, type: !432)
!2935 = !DILocalVariable(name: "nextIndices", scope: !2936, file: !192, line: 138, type: !2894)
!2936 = distinct !DILexicalBlock(scope: !2937, file: !192, line: 137, column: 26)
!2937 = distinct !DILexicalBlock(scope: !2896, file: !192, line: 137, column: 7)
!2938 = !DILocalVariable(name: "__init", scope: !2939, type: !52, flags: DIFlagArtificial)
!2939 = distinct !DILexicalBlock(scope: !2940, file: !192, line: 142, column: 9)
!2940 = distinct !DILexicalBlock(scope: !2941, file: !192, line: 140, column: 29)
!2941 = distinct !DILexicalBlock(scope: !2942, file: !192, line: 140, column: 11)
!2942 = distinct !DILexicalBlock(scope: !2943, file: !192, line: 139, column: 33)
!2943 = distinct !DILexicalBlock(scope: !2936, file: !192, line: 139, column: 9)
!2944 = !DILocalVariable(name: "__limit", scope: !2939, type: !52, flags: DIFlagArtificial)
!2945 = !DILocalVariable(name: "__begin", scope: !2939, type: !52, flags: DIFlagArtificial)
!2946 = !DILocalVariable(name: "__end", scope: !2939, type: !52, flags: DIFlagArtificial)
!2947 = !DILocalVariable(name: "i", scope: !2948, file: !192, line: 142, type: !52)
!2948 = distinct !DILexicalBlock(scope: !2939, file: !192, line: 142, column: 9)
!2949 = !DILocalVariable(name: "get_key", scope: !2942, file: !192, line: 144, type: !2950)
!2950 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2896, file: !192, line: 144, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2951, identifier: "_ZTSZ13edgeMapSparseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE_")
!2951 = !{!2952, !2954}
!2952 = !DIDerivedType(tag: DW_TAG_member, name: "outEdges", scope: !2950, file: !192, line: 144, baseType: !2953, size: 64)
!2953 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2894, size: 64)
!2954 = !DISubprogram(name: "operator()", scope: !2950, file: !192, line: 144, type: !2955, scopeLine: 144, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!2955 = !DISubroutineType(types: !2956)
!2956 = !{!1136, !2957, !779}
!2957 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2958, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2958 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2950)
!2959 = !DILocalVariable(name: "p", scope: !2936, file: !192, line: 147, type: !2960)
!2960 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !2896, file: !192, line: 147, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ13edgeMapSparseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRSt5tupleIJjS1_EEE_")
!2961 = !DILocalVariable(name: "nextM", scope: !2936, file: !192, line: 148, type: !779)
!2962 = !DISubprogram(name: "remDuplicates<(lambda at ./ligra.h:144:22)>", linkageName: "_Z13remDuplicatesIZ13edgeMapSparseIN4pbbs5emptyE15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EvRS7_SG_ll", scope: !54, file: !54, line: 359, type: !2963, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2966, retainedNodes: !45)
!2963 = !DISubroutineType(types: !2964)
!2964 = !{null, !2965, !1175, !52, !52}
!2965 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2950, size: 64)
!2966 = !{!2967}
!2967 = !DITemplateTypeParameter(name: "G", type: !2950)
!2968 = !DISubprogram(name: "filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>", linkageName: "_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 270, type: !2969, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2971, retainedNodes: !45)
!2969 = !DISubroutineType(types: !2970)
!2970 = !{!86, !796, !796, !86, !2960}
!2971 = !{!1868, !2972}
!2972 = !DITemplateTypeParameter(name: "PRED", type: !2960)
!2973 = !DISubprogram(name: "filter_serial<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>", linkageName: "_ZN4pbbs13filter_serialISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_15symmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 217, type: !2969, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2971, retainedNodes: !45)
!2974 = !DISubprogram(name: "readGraphFromBinary<asymmetricVertex>", linkageName: "_Z19readGraphFromBinaryI16asymmetricVertexE5graphIT_EPcb", scope: !113, file: !113, line: 319, type: !2975, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !566, retainedNodes: !45)
!2975 = !DISubroutineType(types: !2976)
!2976 = !{!502, !81, !92}
!2977 = !DISubprogram(name: "readGraphFromFile<asymmetricVertex>", linkageName: "_Z17readGraphFromFileI16asymmetricVertexE5graphIT_EPcbb", scope: !113, file: !113, line: 164, type: !2978, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !566, retainedNodes: !45)
!2978 = !DISubroutineType(types: !2979)
!2979 = !{!502, !81, !92, !92}
!2980 = !DISubprogram(name: "edgeMap<asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z7edgeMapI16asymmetricVertex16vertexSubsetDataIN4pbbs5emptyEE5BFS_FES4_5graphIT_ERT0_T1_iRKj", scope: !192, file: !192, line: 280, type: !2981, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2983, retainedNodes: !45)
!2981 = !DISubroutineType(types: !2982)
!2982 = !{!771, !502, !1164, !754, !6, !907}
!2983 = !{!567, !1166, !1167}
!2984 = !DISubprogram(name: "edgeMapData<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z11edgeMapDataIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_ERT1_T2_iRKj", scope: !192, file: !192, line: 235, type: !2985, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2987, retainedNodes: !45)
!2985 = !DISubroutineType(types: !2986)
!2986 = !{!771, !571, !1164, !754, !6, !907}
!2987 = !{!1163, !567, !1166, !1167}
!2988 = !DISubprogram(name: "edgeMapDenseForward<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z19edgeMapDenseForwardIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 85, type: !2989, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2987, retainedNodes: !45)
!2989 = !DISubroutineType(types: !2990)
!2990 = !{!771, !502, !1164, !1181, !18}
!2991 = !DISubprogram(name: "edgeMapDense<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z12edgeMapDenseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 59, type: !2989, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2987, retainedNodes: !45)
!2992 = !DISubprogram(name: "edgeMapSparse_no_filter<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 157, type: !2993, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2987, retainedNodes: !45)
!2993 = !DISubroutineType(types: !2994)
!2994 = !{!771, !571, !505, !1164, !1175, !18, !1181, !18}
!2995 = !DISubprogram(name: "edgeMapSparse<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z13edgeMapSparseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 111, type: !2993, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !2987, retainedNodes: !45)
!2996 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2997, size: 64)
!2997 = !DIDerivedType(tag: DW_TAG_typedef, name: "D", scope: !2998, file: !192, line: 86, baseType: !1016)
!2998 = distinct !DISubprogram(name: "edgeMapDenseForward<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z19edgeMapDenseForwardIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 85, type: !2999, scopeLine: 85, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2987, retainedNodes: !3001)
!2999 = !DISubroutineType(types: !3000)
!3000 = !{!771, !502, !1164, !1181, !1532}
!3001 = !{!3002, !3003, !3004, !3005, !3006, !3007, !3008, !3011, !3012, !3014, !3015, !3016, !3017, !3019, !3021, !3022, !3023, !3024, !3026, !3028, !3030, !3031, !3032, !3033}
!3002 = !DILocalVariable(name: "GA", arg: 1, scope: !2998, file: !192, line: 85, type: !502)
!3003 = !DILocalVariable(name: "vertexSubset", arg: 2, scope: !2998, file: !192, line: 85, type: !1164)
!3004 = !DILocalVariable(name: "f", arg: 3, scope: !2998, file: !192, line: 85, type: !1181)
!3005 = !DILocalVariable(name: "fl", arg: 4, scope: !2998, file: !192, line: 85, type: !1532)
!3006 = !DILocalVariable(name: "n", scope: !2998, file: !192, line: 87, type: !52)
!3007 = !DILocalVariable(name: "G", scope: !2998, file: !192, line: 88, type: !505)
!3008 = !DILocalVariable(name: "next", scope: !3009, file: !192, line: 90, type: !2996)
!3009 = distinct !DILexicalBlock(scope: !3010, file: !192, line: 89, column: 26)
!3010 = distinct !DILexicalBlock(scope: !2998, file: !192, line: 89, column: 7)
!3011 = !DILocalVariable(name: "g", scope: !3009, file: !192, line: 91, type: !1545)
!3012 = !DILocalVariable(name: "__init", scope: !3013, type: !52, flags: DIFlagArtificial)
!3013 = distinct !DILexicalBlock(scope: !3009, file: !192, line: 92, column: 5)
!3014 = !DILocalVariable(name: "__limit", scope: !3013, type: !52, flags: DIFlagArtificial)
!3015 = !DILocalVariable(name: "__begin", scope: !3013, type: !52, flags: DIFlagArtificial)
!3016 = !DILocalVariable(name: "__end", scope: !3013, type: !52, flags: DIFlagArtificial)
!3017 = !DILocalVariable(name: "i", scope: !3018, file: !192, line: 92, type: !52)
!3018 = distinct !DILexicalBlock(scope: !3013, file: !192, line: 92, column: 5)
!3019 = !DILocalVariable(name: "__init", scope: !3020, type: !52, flags: DIFlagArtificial)
!3020 = distinct !DILexicalBlock(scope: !3009, file: !192, line: 93, column: 5)
!3021 = !DILocalVariable(name: "__limit", scope: !3020, type: !52, flags: DIFlagArtificial)
!3022 = !DILocalVariable(name: "__begin", scope: !3020, type: !52, flags: DIFlagArtificial)
!3023 = !DILocalVariable(name: "__end", scope: !3020, type: !52, flags: DIFlagArtificial)
!3024 = !DILocalVariable(name: "i", scope: !3025, file: !192, line: 93, type: !52)
!3025 = distinct !DILexicalBlock(scope: !3020, file: !192, line: 93, column: 5)
!3026 = !DILocalVariable(name: "g", scope: !3027, file: !192, line: 100, type: !1565)
!3027 = distinct !DILexicalBlock(scope: !3010, file: !192, line: 99, column: 10)
!3028 = !DILocalVariable(name: "__init", scope: !3029, type: !52, flags: DIFlagArtificial)
!3029 = distinct !DILexicalBlock(scope: !3027, file: !192, line: 101, column: 5)
!3030 = !DILocalVariable(name: "__limit", scope: !3029, type: !52, flags: DIFlagArtificial)
!3031 = !DILocalVariable(name: "__begin", scope: !3029, type: !52, flags: DIFlagArtificial)
!3032 = !DILocalVariable(name: "__end", scope: !3029, type: !52, flags: DIFlagArtificial)
!3033 = !DILocalVariable(name: "i", scope: !3034, file: !192, line: 101, type: !52)
!3034 = distinct !DILexicalBlock(scope: !3029, file: !192, line: 101, column: 5)
!3035 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3036, size: 64)
!3036 = !DIDerivedType(tag: DW_TAG_typedef, name: "D", scope: !3037, file: !192, line: 60, baseType: !1016)
!3037 = distinct !DISubprogram(name: "edgeMapDense<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z12edgeMapDenseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_E5graphIT0_ERT1_RT2_j", scope: !192, file: !192, line: 59, type: !2999, scopeLine: 59, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2987, retainedNodes: !3038)
!3038 = !{!3039, !3040, !3041, !3042, !3043, !3044, !3045, !3048, !3049, !3051, !3052, !3053, !3054, !3056, !3058, !3060, !3061, !3062, !3063}
!3039 = !DILocalVariable(name: "GA", arg: 1, scope: !3037, file: !192, line: 59, type: !502)
!3040 = !DILocalVariable(name: "vertexSubset", arg: 2, scope: !3037, file: !192, line: 59, type: !1164)
!3041 = !DILocalVariable(name: "f", arg: 3, scope: !3037, file: !192, line: 59, type: !1181)
!3042 = !DILocalVariable(name: "fl", arg: 4, scope: !3037, file: !192, line: 59, type: !1532)
!3043 = !DILocalVariable(name: "n", scope: !3037, file: !192, line: 61, type: !52)
!3044 = !DILocalVariable(name: "G", scope: !3037, file: !192, line: 62, type: !505)
!3045 = !DILocalVariable(name: "next", scope: !3046, file: !192, line: 64, type: !3035)
!3046 = distinct !DILexicalBlock(scope: !3047, file: !192, line: 63, column: 26)
!3047 = distinct !DILexicalBlock(scope: !3037, file: !192, line: 63, column: 7)
!3048 = !DILocalVariable(name: "g", scope: !3046, file: !192, line: 65, type: !1677)
!3049 = !DILocalVariable(name: "__init", scope: !3050, type: !52, flags: DIFlagArtificial)
!3050 = distinct !DILexicalBlock(scope: !3046, file: !192, line: 66, column: 5)
!3051 = !DILocalVariable(name: "__limit", scope: !3050, type: !52, flags: DIFlagArtificial)
!3052 = !DILocalVariable(name: "__begin", scope: !3050, type: !52, flags: DIFlagArtificial)
!3053 = !DILocalVariable(name: "__end", scope: !3050, type: !52, flags: DIFlagArtificial)
!3054 = !DILocalVariable(name: "v", scope: !3055, file: !192, line: 66, type: !52)
!3055 = distinct !DILexicalBlock(scope: !3050, file: !192, line: 66, column: 5)
!3056 = !DILocalVariable(name: "g", scope: !3057, file: !192, line: 74, type: !1689)
!3057 = distinct !DILexicalBlock(scope: !3047, file: !192, line: 73, column: 10)
!3058 = !DILocalVariable(name: "__init", scope: !3059, type: !52, flags: DIFlagArtificial)
!3059 = distinct !DILexicalBlock(scope: !3057, file: !192, line: 75, column: 5)
!3060 = !DILocalVariable(name: "__limit", scope: !3059, type: !52, flags: DIFlagArtificial)
!3061 = !DILocalVariable(name: "__begin", scope: !3059, type: !52, flags: DIFlagArtificial)
!3062 = !DILocalVariable(name: "__end", scope: !3059, type: !52, flags: DIFlagArtificial)
!3063 = !DILocalVariable(name: "v", scope: !3064, file: !192, line: 75, type: !52)
!3064 = distinct !DILexicalBlock(scope: !3059, file: !192, line: 75, column: 5)
!3065 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3066, size: 64)
!3066 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !3067, file: !192, line: 160, baseType: !797)
!3067 = distinct !DISubprogram(name: "edgeMapSparse_no_filter<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 157, type: !3068, scopeLine: 159, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2987, retainedNodes: !3070)
!3068 = !DISubroutineType(types: !3069)
!3069 = !{!771, !571, !505, !1164, !753, !126, !1181, !1532}
!3070 = !{!3071, !3072, !3073, !3074, !3075, !3076, !3077, !3078, !3079, !3080, !3081, !3082, !3083, !3084, !3085, !3086, !3116, !3118, !3120, !3121, !3122, !3123, !3125, !3127, !3129, !3130, !3131, !3132, !3134, !3138, !3139, !3140, !3141, !3143, !3146, !3147, !3148, !3149, !3151, !3152, !3153, !3154, !3156, !3160, !3161, !3162, !3163, !3165, !3171, !3172, !3173, !3174, !3176, !3186, !3187, !3189}
!3071 = !DILocalVariable(name: "GA", arg: 1, scope: !3067, file: !192, line: 157, type: !571)
!3072 = !DILocalVariable(name: "frontierVertices", arg: 2, scope: !3067, file: !192, line: 158, type: !505)
!3073 = !DILocalVariable(name: "indices", arg: 3, scope: !3067, file: !192, line: 158, type: !1164)
!3074 = !DILocalVariable(name: "offsets", arg: 4, scope: !3067, file: !192, line: 158, type: !753)
!3075 = !DILocalVariable(name: "m", arg: 5, scope: !3067, file: !192, line: 158, type: !126)
!3076 = !DILocalVariable(name: "f", arg: 6, scope: !3067, file: !192, line: 158, type: !1181)
!3077 = !DILocalVariable(name: "fl", arg: 7, scope: !3067, file: !192, line: 159, type: !1532)
!3078 = !DILocalVariable(name: "n", scope: !3067, file: !192, line: 161, type: !52)
!3079 = !DILocalVariable(name: "outEdgeCount", scope: !3067, file: !192, line: 162, type: !52)
!3080 = !DILocalVariable(name: "outEdges", scope: !3067, file: !192, line: 163, type: !3065)
!3081 = !DILocalVariable(name: "g", scope: !3067, file: !192, line: 165, type: !1725)
!3082 = !DILocalVariable(name: "b_size", scope: !3067, file: !192, line: 168, type: !779)
!3083 = !DILocalVariable(name: "n_blocks", scope: !3067, file: !192, line: 169, type: !779)
!3084 = !DILocalVariable(name: "cts", scope: !3067, file: !192, line: 171, type: !49)
!3085 = !DILocalVariable(name: "block_offs", scope: !3067, file: !192, line: 172, type: !1732)
!3086 = !DILocalVariable(name: "offsets_m", scope: !3067, file: !192, line: 174, type: !3087)
!3087 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_imap<unsigned int, (lambda at ./ligra.h:174:43)>", file: !1188, line: 44, size: 192, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !3088, templateParams: !3114, identifier: "_ZTS7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E")
!3088 = !{!3089, !3093, !3094, !3095, !3099, !3102, !3106, !3107, !3110, !3111}
!3089 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !3087, file: !1188, line: 46, baseType: !3090, size: 64)
!3090 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !3067, file: !192, line: 174, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !3091, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE_")
!3091 = !{!3092}
!3092 = !DIDerivedType(tag: DW_TAG_member, name: "offsets", scope: !3090, file: !192, line: 174, baseType: !1740, size: 64)
!3093 = !DIDerivedType(tag: DW_TAG_member, name: "s", scope: !3087, file: !1188, line: 47, baseType: !779, size: 64, offset: 64)
!3094 = !DIDerivedType(tag: DW_TAG_member, name: "e", scope: !3087, file: !1188, line: 47, baseType: !779, size: 64, offset: 128)
!3095 = !DISubprogram(name: "in_imap", scope: !3087, file: !1188, line: 48, type: !3096, scopeLine: 48, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3096 = !DISubroutineType(types: !3097)
!3097 = !{null, !3098, !779, !3090}
!3098 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3087, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!3099 = !DISubprogram(name: "in_imap", scope: !3087, file: !1188, line: 49, type: !3100, scopeLine: 49, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3100 = !DISubroutineType(types: !3101)
!3101 = !{null, !3098, !779, !779, !3090}
!3102 = !DISubprogram(name: "operator[]", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EixEm", scope: !3087, file: !1188, line: 50, type: !3103, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3103 = !DISubroutineType(types: !3104)
!3104 = !{!3105, !3098, !1225}
!3105 = !DIDerivedType(tag: DW_TAG_typedef, name: "T", scope: !3087, file: !1188, line: 45, baseType: !18)
!3106 = !DISubprogram(name: "operator()", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EclEm", scope: !3087, file: !1188, line: 51, type: !3103, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3107 = !DISubprogram(name: "cut", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E3cutEmm", scope: !3087, file: !1188, line: 52, type: !3108, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3108 = !DISubroutineType(types: !3109)
!3109 = !{!3087, !3098, !779, !779}
!3110 = !DISubprogram(name: "slice", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E5sliceEmm", scope: !3087, file: !1188, line: 53, type: !3108, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3111 = !DISubprogram(name: "size", linkageName: "_ZN7in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E4sizeEv", scope: !3087, file: !1188, line: 54, type: !3112, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3112 = !DISubroutineType(types: !3113)
!3113 = !{!779, !3098}
!3114 = !{!1242, !3115}
!3115 = !DITemplateTypeParameter(name: "F", type: !3090)
!3116 = !DILocalVariable(name: "lt", scope: !3067, file: !192, line: 175, type: !3117)
!3117 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !3067, file: !192, line: 175, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRKjSJ_E_")
!3118 = !DILocalVariable(name: "__init", scope: !3119, type: !779, flags: DIFlagArtificial)
!3119 = distinct !DILexicalBlock(scope: !3067, file: !192, line: 176, column: 3)
!3120 = !DILocalVariable(name: "__limit", scope: !3119, type: !779, flags: DIFlagArtificial)
!3121 = !DILocalVariable(name: "__begin", scope: !3119, type: !779, flags: DIFlagArtificial)
!3122 = !DILocalVariable(name: "__end", scope: !3119, type: !779, flags: DIFlagArtificial)
!3123 = !DILocalVariable(name: "i", scope: !3124, file: !192, line: 176, type: !779)
!3124 = distinct !DILexicalBlock(scope: !3119, file: !192, line: 176, column: 3)
!3125 = !DILocalVariable(name: "s_val", scope: !3126, file: !192, line: 177, type: !779)
!3126 = distinct !DILexicalBlock(scope: !3124, file: !192, line: 176, column: 45)
!3127 = !DILocalVariable(name: "__init", scope: !3128, type: !779, flags: DIFlagArtificial)
!3128 = distinct !DILexicalBlock(scope: !3067, file: !192, line: 181, column: 3)
!3129 = !DILocalVariable(name: "__limit", scope: !3128, type: !779, flags: DIFlagArtificial)
!3130 = !DILocalVariable(name: "__begin", scope: !3128, type: !779, flags: DIFlagArtificial)
!3131 = !DILocalVariable(name: "__end", scope: !3128, type: !779, flags: DIFlagArtificial)
!3132 = !DILocalVariable(name: "i", scope: !3133, file: !192, line: 181, type: !779)
!3133 = distinct !DILexicalBlock(scope: !3128, file: !192, line: 181, column: 3)
!3134 = !DILocalVariable(name: "start", scope: !3135, file: !192, line: 184, type: !779)
!3135 = distinct !DILexicalBlock(scope: !3136, file: !192, line: 182, column: 64)
!3136 = distinct !DILexicalBlock(scope: !3137, file: !192, line: 182, column: 9)
!3137 = distinct !DILexicalBlock(scope: !3133, file: !192, line: 181, column: 46)
!3138 = !DILocalVariable(name: "end", scope: !3135, file: !192, line: 185, type: !779)
!3139 = !DILocalVariable(name: "start_o", scope: !3135, file: !192, line: 186, type: !126)
!3140 = !DILocalVariable(name: "k", scope: !3135, file: !192, line: 187, type: !126)
!3141 = !DILocalVariable(name: "j", scope: !3142, file: !192, line: 188, type: !779)
!3142 = distinct !DILexicalBlock(scope: !3135, file: !192, line: 188, column: 7)
!3143 = !DILocalVariable(name: "v", scope: !3144, file: !192, line: 189, type: !50)
!3144 = distinct !DILexicalBlock(scope: !3145, file: !192, line: 188, column: 40)
!3145 = distinct !DILexicalBlock(scope: !3142, file: !192, line: 188, column: 7)
!3146 = !DILocalVariable(name: "num_in", scope: !3144, file: !192, line: 190, type: !779)
!3147 = !DILocalVariable(name: "outSize", scope: !3067, file: !192, line: 199, type: !52)
!3148 = !DILocalVariable(name: "out", scope: !3067, file: !192, line: 202, type: !3065)
!3149 = !DILocalVariable(name: "__init", scope: !3150, type: !779, flags: DIFlagArtificial)
!3150 = distinct !DILexicalBlock(scope: !3067, file: !192, line: 204, column: 3)
!3151 = !DILocalVariable(name: "__limit", scope: !3150, type: !779, flags: DIFlagArtificial)
!3152 = !DILocalVariable(name: "__begin", scope: !3150, type: !779, flags: DIFlagArtificial)
!3153 = !DILocalVariable(name: "__end", scope: !3150, type: !779, flags: DIFlagArtificial)
!3154 = !DILocalVariable(name: "i", scope: !3155, file: !192, line: 204, type: !779)
!3155 = distinct !DILexicalBlock(scope: !3150, file: !192, line: 204, column: 3)
!3156 = !DILocalVariable(name: "start", scope: !3157, file: !192, line: 206, type: !779)
!3157 = distinct !DILexicalBlock(scope: !3158, file: !192, line: 205, column: 64)
!3158 = distinct !DILexicalBlock(scope: !3159, file: !192, line: 205, column: 9)
!3159 = distinct !DILexicalBlock(scope: !3155, file: !192, line: 204, column: 46)
!3160 = !DILocalVariable(name: "start_o", scope: !3157, file: !192, line: 207, type: !779)
!3161 = !DILocalVariable(name: "out_off", scope: !3157, file: !192, line: 208, type: !779)
!3162 = !DILocalVariable(name: "block_size", scope: !3157, file: !192, line: 209, type: !779)
!3163 = !DILocalVariable(name: "j", scope: !3164, file: !192, line: 210, type: !779)
!3164 = distinct !DILexicalBlock(scope: !3157, file: !192, line: 210, column: 7)
!3165 = !DILocalVariable(name: "__init", scope: !3166, type: !779, flags: DIFlagArtificial)
!3166 = distinct !DILexicalBlock(scope: !3167, file: !192, line: 220, column: 7)
!3167 = distinct !DILexicalBlock(scope: !3168, file: !192, line: 218, column: 27)
!3168 = distinct !DILexicalBlock(scope: !3169, file: !192, line: 218, column: 9)
!3169 = distinct !DILexicalBlock(scope: !3170, file: !192, line: 217, column: 31)
!3170 = distinct !DILexicalBlock(scope: !3067, file: !192, line: 217, column: 7)
!3171 = !DILocalVariable(name: "__limit", scope: !3166, type: !779, flags: DIFlagArtificial)
!3172 = !DILocalVariable(name: "__begin", scope: !3166, type: !779, flags: DIFlagArtificial)
!3173 = !DILocalVariable(name: "__end", scope: !3166, type: !779, flags: DIFlagArtificial)
!3174 = !DILocalVariable(name: "i", scope: !3175, file: !192, line: 220, type: !779)
!3175 = distinct !DILexicalBlock(scope: !3166, file: !192, line: 220, column: 7)
!3176 = !DILocalVariable(name: "get_key", scope: !3169, file: !192, line: 222, type: !3177)
!3177 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !3067, file: !192, line: 222, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !3178, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE0_")
!3178 = !{!3179, !3181}
!3179 = !DIDerivedType(tag: DW_TAG_member, name: "out", scope: !3177, file: !192, line: 222, baseType: !3180, size: 64)
!3180 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3065, size: 64)
!3181 = !DISubprogram(name: "operator()", scope: !3177, file: !192, line: 222, type: !3182, scopeLine: 222, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3182 = !DISubroutineType(types: !3183)
!3183 = !{!1136, !3184, !779}
!3184 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3185, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!3185 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3177)
!3186 = !DILocalVariable(name: "nextIndices", scope: !3169, file: !192, line: 224, type: !3065)
!3187 = !DILocalVariable(name: "p", scope: !3169, file: !192, line: 225, type: !3188)
!3188 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !3067, file: !192, line: 225, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRSt5tupleIJjS1_EEE_")
!3189 = !DILocalVariable(name: "nextM", scope: !3169, file: !192, line: 226, type: !779)
!3190 = !DISubprogram(name: "make_in_imap<unsigned int, (lambda at ./ligra.h:174:43)>", linkageName: "_Z12make_in_imapIjZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_E7in_imapIS7_SA_EmSA_", scope: !1188, file: !1188, line: 59, type: !3191, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3114, retainedNodes: !45)
!3191 = !DISubroutineType(types: !3192)
!3192 = !{!3087, !86, !3090}
!3193 = !DISubprogram(name: "binary_search<in_imap<unsigned int, (lambda at ./ligra.h:174:43)>, (lambda at ./ligra.h:175:13)>", linkageName: "_ZN4pbbs13binary_searchI7in_imapIjZ23edgeMapSparse_no_filterINS_5emptyE16asymmetricVertex16vertexSubsetDataIS3_E5BFS_FES5_IT_ER5graphIT0_EPSB_RT1_PjjRT2_jEUlmE_EZS2_IS3_S4_S6_S7_ES9_SD_SE_SG_SH_jSJ_jEUlRKjSN_E_EEmS8_NS8_1TERKSB_", scope: !811, file: !1845, line: 18, type: !3194, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3198, retainedNodes: !45)
!3194 = !DISubroutineType(types: !3195)
!3195 = !{!86, !3087, !18, !3196}
!3196 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3197, size: 64)
!3197 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3117)
!3198 = !{!3199, !3200}
!3199 = !DITemplateTypeParameter(name: "Sequence", type: !3087)
!3200 = !DITemplateTypeParameter(name: "F", type: !3117)
!3201 = !DISubprogram(name: "remDuplicates<(lambda at ./ligra.h:222:20)>", linkageName: "_Z13remDuplicatesIZ23edgeMapSparse_no_filterIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE0_EvRS7_SG_ll", scope: !54, file: !54, line: 359, type: !3202, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3205, retainedNodes: !45)
!3202 = !DISubroutineType(types: !3203)
!3203 = !{null, !3204, !1175, !52, !52}
!3204 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3177, size: 64)
!3205 = !{!3206}
!3206 = !DITemplateTypeParameter(name: "G", type: !3177)
!3207 = !DISubprogram(name: "filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>", linkageName: "_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 270, type: !3208, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3210, retainedNodes: !45)
!3208 = !DISubroutineType(types: !3209)
!3209 = !{!86, !796, !796, !86, !3188}
!3210 = !{!1868, !3211}
!3211 = !DITemplateTypeParameter(name: "PRED", type: !3188)
!3212 = !DISubprogram(name: "linear_search<in_imap<unsigned int, (lambda at ./ligra.h:174:43)>, (lambda at ./ligra.h:175:13)>", linkageName: "_ZN4pbbs13linear_searchI7in_imapIjZ23edgeMapSparse_no_filterINS_5emptyE16asymmetricVertex16vertexSubsetDataIS3_E5BFS_FES5_IT_ER5graphIT0_EPSB_RT1_PjjRT2_jEUlmE_EZS2_IS3_S4_S6_S7_ES9_SD_SE_SG_SH_jSJ_jEUlRKjSN_E_EEmS8_NS8_1TERKSB_", scope: !811, file: !1845, line: 10, type: !3194, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3198, retainedNodes: !45)
!3213 = !DISubprogram(name: "filter_serial<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:225:14)>", linkageName: "_ZN4pbbs13filter_serialISt5tupleIJjNS_5emptyEEEZ23edgeMapSparse_no_filterIS2_16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 217, type: !3208, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3210, retainedNodes: !45)
!3214 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3215, size: 64)
!3215 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", scope: !3216, file: !192, line: 113, baseType: !797)
!3216 = distinct !DISubprogram(name: "edgeMapSparse<pbbs::empty, asymmetricVertex, vertexSubsetData<pbbs::empty>, BFS_F>", linkageName: "_Z13edgeMapSparseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_j", scope: !192, file: !192, line: 111, type: !3068, scopeLine: 112, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !2987, retainedNodes: !3217)
!3217 = !{!3218, !3219, !3220, !3221, !3222, !3223, !3224, !3225, !3226, !3227, !3228, !3231, !3232, !3234, !3235, !3236, !3237, !3239, !3241, !3242, !3243, !3245, !3247, !3248, !3249, !3250, !3252, !3254, !3255, !3258, !3264, !3265, !3266, !3267, !3269, !3279, !3281}
!3218 = !DILocalVariable(name: "GA", arg: 1, scope: !3216, file: !192, line: 111, type: !571)
!3219 = !DILocalVariable(name: "frontierVertices", arg: 2, scope: !3216, file: !192, line: 111, type: !505)
!3220 = !DILocalVariable(name: "indices", arg: 3, scope: !3216, file: !192, line: 111, type: !1164)
!3221 = !DILocalVariable(name: "degrees", arg: 4, scope: !3216, file: !192, line: 112, type: !753)
!3222 = !DILocalVariable(name: "m", arg: 5, scope: !3216, file: !192, line: 112, type: !126)
!3223 = !DILocalVariable(name: "f", arg: 6, scope: !3216, file: !192, line: 112, type: !1181)
!3224 = !DILocalVariable(name: "fl", arg: 7, scope: !3216, file: !192, line: 112, type: !1532)
!3225 = !DILocalVariable(name: "n", scope: !3216, file: !192, line: 114, type: !52)
!3226 = !DILocalVariable(name: "outEdges", scope: !3216, file: !192, line: 115, type: !3214)
!3227 = !DILocalVariable(name: "outEdgeCount", scope: !3216, file: !192, line: 116, type: !52)
!3228 = !DILocalVariable(name: "offsets", scope: !3229, file: !192, line: 119, type: !753)
!3229 = distinct !DILexicalBlock(scope: !3230, file: !192, line: 118, column: 26)
!3230 = distinct !DILexicalBlock(scope: !3216, file: !192, line: 118, column: 7)
!3231 = !DILocalVariable(name: "g", scope: !3229, file: !192, line: 122, type: !1930)
!3232 = !DILocalVariable(name: "__init", scope: !3233, type: !779, flags: DIFlagArtificial)
!3233 = distinct !DILexicalBlock(scope: !3229, file: !192, line: 123, column: 5)
!3234 = !DILocalVariable(name: "__limit", scope: !3233, type: !779, flags: DIFlagArtificial)
!3235 = !DILocalVariable(name: "__begin", scope: !3233, type: !779, flags: DIFlagArtificial)
!3236 = !DILocalVariable(name: "__end", scope: !3233, type: !779, flags: DIFlagArtificial)
!3237 = !DILocalVariable(name: "i", scope: !3238, file: !192, line: 123, type: !779)
!3238 = distinct !DILexicalBlock(scope: !3233, file: !192, line: 123, column: 5)
!3239 = !DILocalVariable(name: "v", scope: !3240, file: !192, line: 124, type: !126)
!3240 = distinct !DILexicalBlock(scope: !3238, file: !192, line: 123, column: 45)
!3241 = !DILocalVariable(name: "o", scope: !3240, file: !192, line: 124, type: !126)
!3242 = !DILocalVariable(name: "vert", scope: !3240, file: !192, line: 125, type: !506)
!3243 = !DILocalVariable(name: "g", scope: !3244, file: !192, line: 129, type: !1946)
!3244 = distinct !DILexicalBlock(scope: !3230, file: !192, line: 128, column: 10)
!3245 = !DILocalVariable(name: "__init", scope: !3246, type: !779, flags: DIFlagArtificial)
!3246 = distinct !DILexicalBlock(scope: !3244, file: !192, line: 130, column: 5)
!3247 = !DILocalVariable(name: "__limit", scope: !3246, type: !779, flags: DIFlagArtificial)
!3248 = !DILocalVariable(name: "__begin", scope: !3246, type: !779, flags: DIFlagArtificial)
!3249 = !DILocalVariable(name: "__end", scope: !3246, type: !779, flags: DIFlagArtificial)
!3250 = !DILocalVariable(name: "i", scope: !3251, file: !192, line: 130, type: !779)
!3251 = distinct !DILexicalBlock(scope: !3246, file: !192, line: 130, column: 5)
!3252 = !DILocalVariable(name: "v", scope: !3253, file: !192, line: 131, type: !126)
!3253 = distinct !DILexicalBlock(scope: !3251, file: !192, line: 130, column: 45)
!3254 = !DILocalVariable(name: "vert", scope: !3253, file: !192, line: 132, type: !506)
!3255 = !DILocalVariable(name: "nextIndices", scope: !3256, file: !192, line: 138, type: !3214)
!3256 = distinct !DILexicalBlock(scope: !3257, file: !192, line: 137, column: 26)
!3257 = distinct !DILexicalBlock(scope: !3216, file: !192, line: 137, column: 7)
!3258 = !DILocalVariable(name: "__init", scope: !3259, type: !52, flags: DIFlagArtificial)
!3259 = distinct !DILexicalBlock(scope: !3260, file: !192, line: 142, column: 9)
!3260 = distinct !DILexicalBlock(scope: !3261, file: !192, line: 140, column: 29)
!3261 = distinct !DILexicalBlock(scope: !3262, file: !192, line: 140, column: 11)
!3262 = distinct !DILexicalBlock(scope: !3263, file: !192, line: 139, column: 33)
!3263 = distinct !DILexicalBlock(scope: !3256, file: !192, line: 139, column: 9)
!3264 = !DILocalVariable(name: "__limit", scope: !3259, type: !52, flags: DIFlagArtificial)
!3265 = !DILocalVariable(name: "__begin", scope: !3259, type: !52, flags: DIFlagArtificial)
!3266 = !DILocalVariable(name: "__end", scope: !3259, type: !52, flags: DIFlagArtificial)
!3267 = !DILocalVariable(name: "i", scope: !3268, file: !192, line: 142, type: !52)
!3268 = distinct !DILexicalBlock(scope: !3259, file: !192, line: 142, column: 9)
!3269 = !DILocalVariable(name: "get_key", scope: !3262, file: !192, line: 144, type: !3270)
!3270 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !3216, file: !192, line: 144, size: 64, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !3271, identifier: "_ZTSZ13edgeMapSparseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlmE_")
!3271 = !{!3272, !3274}
!3272 = !DIDerivedType(tag: DW_TAG_member, name: "outEdges", scope: !3270, file: !192, line: 144, baseType: !3273, size: 64)
!3273 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3214, size: 64)
!3274 = !DISubprogram(name: "operator()", scope: !3270, file: !192, line: 144, type: !3275, scopeLine: 144, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3275 = !DISubroutineType(types: !3276)
!3276 = !{!1136, !3277, !779}
!3277 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3278, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!3278 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3270)
!3279 = !DILocalVariable(name: "p", scope: !3256, file: !192, line: 147, type: !3280)
!3280 = distinct !DICompositeType(tag: DW_TAG_class_type, scope: !3216, file: !192, line: 147, size: 8, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !45, identifier: "_ZTSZ13edgeMapSparseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS1_E5BFS_FES3_IT_ER5graphIT0_EPS9_RT1_PjjRT2_jEUlRSt5tupleIJjS1_EEE_")
!3281 = !DILocalVariable(name: "nextM", scope: !3256, file: !192, line: 148, type: !779)
!3282 = !DISubprogram(name: "remDuplicates<(lambda at ./ligra.h:144:22)>", linkageName: "_Z13remDuplicatesIZ13edgeMapSparseIN4pbbs5emptyE16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES4_IT_ER5graphIT0_EPSA_RT1_PjjRT2_jEUlmE_EvRS7_SG_ll", scope: !54, file: !54, line: 359, type: !3283, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3286, retainedNodes: !45)
!3283 = !DISubroutineType(types: !3284)
!3284 = !{null, !3285, !1175, !52, !52}
!3285 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3270, size: 64)
!3286 = !{!3287}
!3287 = !DITemplateTypeParameter(name: "G", type: !3270)
!3288 = !DISubprogram(name: "filterf<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>", linkageName: "_ZN4pbbs7filterfISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 270, type: !3289, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3291, retainedNodes: !45)
!3289 = !DISubroutineType(types: !3290)
!3290 = !{!86, !796, !796, !86, !3280}
!3291 = !{!1868, !3292}
!3292 = !DITemplateTypeParameter(name: "PRED", type: !3280)
!3293 = !DISubprogram(name: "filter_serial<std::tuple<unsigned int, pbbs::empty>, (lambda at ./ligra.h:147:14)>", linkageName: "_ZN4pbbs13filter_serialISt5tupleIJjNS_5emptyEEEZ13edgeMapSparseIS2_16asymmetricVertex16vertexSubsetDataIS2_E5BFS_FES6_IT_ER5graphIT0_EPSC_RT1_PjjRT2_jEUlRS3_E_EEmPS9_SN_mSC_", scope: !811, file: !1271, line: 217, type: !3289, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !3291, retainedNodes: !45)
!3294 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "ios_base", scope: !5, file: !4, line: 228, flags: DIFlagFwdDecl, identifier: "_ZTSSt8ios_base")
!3295 = !{!3296, !3319, !3360, !3362, !3364, !3366, !3368, !3370, !3372, !3375, !3377, !3379, !3381, !3383}
!3296 = !DIGlobalVariableExpression(var: !3297, expr: !DIExpression())
!3297 = distinct !DIGlobalVariable(name: "__ioinit", linkageName: "_ZStL8__ioinit", scope: !5, file: !3298, line: 74, type: !3299, isLocal: true, isDefinition: true)
!3298 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/iostream", directory: "")
!3299 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "Init", scope: !3294, file: !4, line: 626, size: 8, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !3300, identifier: "_ZTSNSt8ios_base4InitE")
!3300 = !{!3301, !3304, !3305, !3309, !3310, !3315}
!3301 = !DIDerivedType(tag: DW_TAG_member, name: "_S_refcount", scope: !3299, file: !4, line: 639, baseType: !3302, flags: DIFlagStaticMember)
!3302 = !DIDerivedType(tag: DW_TAG_typedef, name: "_Atomic_word", file: !3303, line: 32, baseType: !6)
!3303 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/x86_64-redhat-linux/bits/atomic_word.h", directory: "")
!3304 = !DIDerivedType(tag: DW_TAG_member, name: "_S_synced_with_stdio", scope: !3299, file: !4, line: 640, baseType: !92, flags: DIFlagStaticMember)
!3305 = !DISubprogram(name: "Init", scope: !3299, file: !4, line: 630, type: !3306, scopeLine: 630, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3306 = !DISubroutineType(types: !3307)
!3307 = !{null, !3308}
!3308 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3299, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!3309 = !DISubprogram(name: "~Init", scope: !3299, file: !4, line: 631, type: !3306, scopeLine: 631, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3310 = !DISubprogram(name: "Init", scope: !3299, file: !4, line: 634, type: !3311, scopeLine: 634, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3311 = !DISubroutineType(types: !3312)
!3312 = !{null, !3308, !3313}
!3313 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3314, size: 64)
!3314 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3299)
!3315 = !DISubprogram(name: "operator=", linkageName: "_ZNSt8ios_base4InitaSERKS0_", scope: !3299, file: !4, line: 635, type: !3316, scopeLine: 635, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3316 = !DISubroutineType(types: !3317)
!3317 = !{!3318, !3308, !3313}
!3318 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3299, size: 64)
!3319 = !DIGlobalVariableExpression(var: !3320, expr: !DIExpression())
!3320 = distinct !DIGlobalVariable(name: "_tm", linkageName: "_ZL3_tm", scope: !0, file: !3321, line: 107, type: !3322, isLocal: true, isDefinition: true)
!3321 = !DIFile(filename: "./gettime.h", directory: "/data/compilers/tests/ligra/apps")
!3322 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timer", file: !3321, line: 30, size: 320, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !3323, identifier: "_ZTS5timer")
!3323 = !{!3324, !3325, !3326, !3327, !3328, !3333, !3337, !3340, !3341, !3342, !3345, !3346, !3347, !3350, !3351, !3354, !3355, !3358, !3359}
!3324 = !DIDerivedType(tag: DW_TAG_member, name: "totalTime", scope: !3322, file: !3321, line: 31, baseType: !358, size: 64)
!3325 = !DIDerivedType(tag: DW_TAG_member, name: "lastTime", scope: !3322, file: !3321, line: 32, baseType: !358, size: 64, offset: 64)
!3326 = !DIDerivedType(tag: DW_TAG_member, name: "totalWeight", scope: !3322, file: !3321, line: 33, baseType: !358, size: 64, offset: 128)
!3327 = !DIDerivedType(tag: DW_TAG_member, name: "on", scope: !3322, file: !3321, line: 34, baseType: !92, size: 8, offset: 192)
!3328 = !DIDerivedType(tag: DW_TAG_member, name: "tzp", scope: !3322, file: !3321, line: 35, baseType: !3329, size: 64, offset: 224)
!3329 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timezone", file: !686, line: 52, size: 64, flags: DIFlagTypePassByValue, elements: !3330, identifier: "_ZTS8timezone")
!3330 = !{!3331, !3332}
!3331 = !DIDerivedType(tag: DW_TAG_member, name: "tz_minuteswest", scope: !3329, file: !686, line: 54, baseType: !6, size: 32)
!3332 = !DIDerivedType(tag: DW_TAG_member, name: "tz_dsttime", scope: !3329, file: !686, line: 55, baseType: !6, size: 32, offset: 32)
!3333 = !DISubprogram(name: "timer", scope: !3322, file: !3321, line: 36, type: !3334, scopeLine: 36, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3334 = !DISubroutineType(types: !3335)
!3335 = !{null, !3336}
!3336 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3322, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!3337 = !DISubprogram(name: "getTime", linkageName: "_ZN5timer7getTimeEv", scope: !3322, file: !3321, line: 41, type: !3338, scopeLine: 41, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3338 = !DISubroutineType(types: !3339)
!3339 = !{!358, !3336}
!3340 = !DISubprogram(name: "start", linkageName: "_ZN5timer5startEv", scope: !3322, file: !3321, line: 46, type: !3334, scopeLine: 46, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3341 = !DISubprogram(name: "stop", linkageName: "_ZN5timer4stopEv", scope: !3322, file: !3321, line: 50, type: !3338, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3342 = !DISubprogram(name: "stop", linkageName: "_ZN5timer4stopEd", scope: !3322, file: !3321, line: 56, type: !3343, scopeLine: 56, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3343 = !DISubroutineType(types: !3344)
!3344 = !{!358, !3336, !358}
!3345 = !DISubprogram(name: "total", linkageName: "_ZN5timer5totalEv", scope: !3322, file: !3321, line: 64, type: !3338, scopeLine: 64, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3346 = !DISubprogram(name: "next", linkageName: "_ZN5timer4nextEv", scope: !3322, file: !3321, line: 69, type: !3338, scopeLine: 69, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3347 = !DISubprogram(name: "reportT", linkageName: "_ZN5timer7reportTEd", scope: !3322, file: !3321, line: 78, type: !3348, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3348 = !DISubroutineType(types: !3349)
!3349 = !{null, !3336, !358}
!3350 = !DISubprogram(name: "reportTime", linkageName: "_ZN5timer10reportTimeEd", scope: !3322, file: !3321, line: 82, type: !3348, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3351 = !DISubprogram(name: "reportStop", linkageName: "_ZN5timer10reportStopEdNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", scope: !3322, file: !3321, line: 86, type: !3352, scopeLine: 86, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3352 = !DISubroutineType(types: !3353)
!3353 = !{null, !3336, !358, !202}
!3354 = !DISubprogram(name: "reportTotal", linkageName: "_ZN5timer11reportTotalEv", scope: !3322, file: !3321, line: 91, type: !3334, scopeLine: 91, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3355 = !DISubprogram(name: "reportTotal", linkageName: "_ZN5timer11reportTotalENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", scope: !3322, file: !3321, line: 98, type: !3356, scopeLine: 98, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3356 = !DISubroutineType(types: !3357)
!3357 = !{null, !3336, !202}
!3358 = !DISubprogram(name: "reportNext", linkageName: "_ZN5timer10reportNextEv", scope: !3322, file: !3321, line: 102, type: !3334, scopeLine: 102, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3359 = !DISubprogram(name: "reportNext", linkageName: "_ZN5timer10reportNextENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", scope: !3322, file: !3321, line: 104, type: !3356, scopeLine: 104, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3360 = !DIGlobalVariableExpression(var: !3361, expr: !DIExpression())
!3361 = distinct !DIGlobalVariable(name: "__ii", linkageName: "_ZL4__ii", scope: !0, file: !54, line: 38, type: !6, isLocal: true, isDefinition: true)
!3362 = !DIGlobalVariableExpression(var: !3363, expr: !DIExpression())
!3363 = distinct !DIGlobalVariable(name: "__jj", linkageName: "_ZL4__jj", scope: !0, file: !54, line: 39, type: !6, isLocal: true, isDefinition: true)
!3364 = !DIGlobalVariableExpression(var: !3365, expr: !DIExpression(DW_OP_constu, 64, DW_OP_stack_value))
!3365 = distinct !DIGlobalVariable(name: "no_dense", scope: !0, file: !192, line: 55, type: !1532, isLocal: true, isDefinition: true)
!3366 = !DIGlobalVariableExpression(var: !3367, expr: !DIExpression(DW_OP_constu, 8, DW_OP_stack_value))
!3367 = distinct !DIGlobalVariable(name: "dense_forward", scope: !0, file: !192, line: 52, type: !1532, isLocal: true, isDefinition: true)
!3368 = !DIGlobalVariableExpression(var: !3369, expr: !DIExpression(DW_OP_constu, 4, DW_OP_stack_value))
!3369 = distinct !DIGlobalVariable(name: "sparse_no_filter", scope: !0, file: !192, line: 51, type: !1532, isLocal: true, isDefinition: true)
!3370 = !DIGlobalVariableExpression(var: !3371, expr: !DIExpression(DW_OP_constu, 4096, DW_OP_stack_value))
!3371 = distinct !DIGlobalVariable(name: "_block_size", scope: !811, file: !1271, line: 34, type: !1225, isLocal: true, isDefinition: true)
!3372 = !DIGlobalVariableExpression(var: !3373, expr: !DIExpression(DW_OP_constu, 1, DW_OP_stack_value))
!3373 = distinct !DIGlobalVariable(name: "fl_sequential", scope: !811, file: !54, line: 397, type: !3374, isLocal: true, isDefinition: true)
!3374 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1287)
!3375 = !DIGlobalVariableExpression(var: !3376, expr: !DIExpression(DW_OP_constu, 16, DW_OP_stack_value))
!3376 = distinct !DIGlobalVariable(name: "fl_scan_inclusive", scope: !811, file: !1271, line: 94, type: !3374, isLocal: true, isDefinition: true)
!3377 = !DIGlobalVariableExpression(var: !3378, expr: !DIExpression(DW_OP_constu, 16, DW_OP_stack_value))
!3378 = distinct !DIGlobalVariable(name: "dense_parallel", scope: !0, file: !192, line: 53, type: !1532, isLocal: true, isDefinition: true)
!3379 = !DIGlobalVariableExpression(var: !3380, expr: !DIExpression(DW_OP_constu, 1, DW_OP_stack_value))
!3380 = distinct !DIGlobalVariable(name: "no_output", scope: !0, file: !192, line: 49, type: !1532, isLocal: true, isDefinition: true)
!3381 = !DIGlobalVariableExpression(var: !3382, expr: !DIExpression(DW_OP_constu, 32, DW_OP_stack_value))
!3382 = distinct !DIGlobalVariable(name: "remove_duplicates", scope: !0, file: !192, line: 54, type: !1532, isLocal: true, isDefinition: true)
!3383 = !DIGlobalVariableExpression(var: !3384, expr: !DIExpression(DW_OP_constu, 16, DW_OP_stack_value))
!3384 = distinct !DIGlobalVariable(name: "_binary_search_base", scope: !811, file: !1845, line: 7, type: !1225, isLocal: true, isDefinition: true)
!3385 = !{!3386, !3403, !3406, !3411, !3469, !3477, !3481, !3488, !3492, !3496, !3498, !3500, !3504, !3511, !3515, !3521, !3527, !3529, !3533, !3537, !3541, !3545, !3556, !3558, !3562, !3566, !3570, !3572, !3577, !3581, !3585, !3587, !3589, !3593, !3614, !3618, !3622, !3626, !3628, !3634, !3636, !3642, !3646, !3650, !3654, !3658, !3662, !3666, !3668, !3670, !3674, !3678, !3682, !3684, !3688, !3692, !3694, !3696, !3700, !3705, !3710, !3715, !3716, !3717, !3718, !3719, !3720, !3721, !3722, !3723, !3724, !3725, !3779, !3783, !3787, !3792, !3796, !3799, !3802, !3805, !3807, !3809, !3811, !3814, !3817, !3820, !3823, !3826, !3828, !3831, !3834, !3835, !3838, !3840, !3842, !3844, !3846, !3849, !3852, !3855, !3858, !3861, !3863, !3867, !3871, !3876, !3880, !3882, !3884, !3886, !3888, !3890, !3892, !3894, !3896, !3898, !3900, !3902, !3904, !3906, !3909, !3913, !3919, !3923, !3928, !3930, !3935, !3939, !3945, !3954, !3958, !3962, !3966, !3968, !3972, !3974, !3978, !3982, !3986, !3990, !3994, !3998, !4000, !4002, !4006, !4010, !4015, !4019, !4023, !4025, !4029, !4033, !4039, !4041, !4045, !4049, !4053, !4057, !4061, !4065, !4069, !4070, !4071, !4072, !4074, !4075, !4076, !4077, !4078, !4079, !4080, !4084, !4089, !4094, !4098, !4100, !4102, !4104, !4106, !4113, !4117, !4121, !4125, !4129, !4133, !4138, !4142, !4144, !4148, !4154, !4158, !4163, !4165, !4168, !4170, !4174, !4176, !4178, !4180, !4182, !4186, !4188, !4190, !4194, !4198, !4202, !4206, !4210, !4214, !4216, !4220, !4224, !4228, !4232, !4234, !4236, !4240, !4244, !4245, !4246, !4247, !4248, !4249, !4255, !4258, !4259, !4261, !4263, !4265, !4267, !4271, !4273, !4275, !4277, !4279, !4281, !4283, !4285, !4287, !4291, !4295, !4297, !4301, !4305, !4307, !4308, !4309, !4310, !4311, !4312, !4313, !4317, !4318, !4319, !4320, !4321, !4322, !4323, !4324, !4325, !4326, !4327, !4328, !4329, !4330, !4331, !4332, !4333, !4334, !4335, !4336, !4337, !4338, !4339, !4340, !4341, !4347, !4351, !4355, !4359, !4363, !4367, !4369, !4371, !4373, !4377, !4381, !4385, !4389, !4393, !4395, !4397, !4399, !4403, !4407, !4411, !4413, !4415, !4420, !4423, !4424, !4429, !4433, !4438, !4443, !4447, !4453, !4457, !4459, !4463, !4464, !4466, !4467, !4468, !4469, !4475, !4477, !4479, !4483, !4485, !4487, !4489, !4491, !4493, !4495, !4497, !4501, !4505, !4507, !4509, !4514, !4516, !4518, !4520, !4522, !4524, !4526, !4529, !4531, !4533, !4537, !4539, !4541, !4543, !4545, !4547, !4549, !4551, !4553, !4555, !4557, !4559, !4563, !4567, !4569, !4571, !4573, !4575, !4577, !4579, !4581, !4583, !4585, !4587, !4589, !4591, !4593, !4595, !4597, !4601, !4605, !4609, !4611, !4613, !4615, !4617, !4619, !4621, !4623, !4625, !4627, !4631, !4635, !4639, !4641, !4643, !4645, !4649, !4653, !4657, !4659, !4661, !4663, !4665, !4667, !4669, !4671, !4673, !4675, !4677, !4679, !4681, !4685, !4689, !4693, !4695, !4697, !4699, !4701, !4705, !4709, !4711, !4713, !4715, !4717, !4719, !4721, !4725, !4729, !4731, !4733, !4735, !4737, !4741, !4745, !4749, !4751, !4753, !4755, !4757, !4759, !4761, !4765, !4769, !4773, !4775, !4779, !4783, !4785, !4787, !4789, !4791, !4793, !4795, !4796, !4798, !4803, !4804, !4805, !4806, !4811}
!3386 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3387, file: !3402, line: 64)
!3387 = !DIDerivedType(tag: DW_TAG_typedef, name: "mbstate_t", file: !3388, line: 6, baseType: !3389)
!3388 = !DIFile(filename: "/usr/include/bits/types/mbstate_t.h", directory: "")
!3389 = !DIDerivedType(tag: DW_TAG_typedef, name: "__mbstate_t", file: !3390, line: 21, baseType: !3391)
!3390 = !DIFile(filename: "/usr/include/bits/types/__mbstate_t.h", directory: "")
!3391 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3390, line: 13, size: 64, flags: DIFlagTypePassByValue, elements: !3392, identifier: "_ZTS11__mbstate_t")
!3392 = !{!3393, !3394}
!3393 = !DIDerivedType(tag: DW_TAG_member, name: "__count", scope: !3391, file: !3390, line: 15, baseType: !6, size: 32)
!3394 = !DIDerivedType(tag: DW_TAG_member, name: "__value", scope: !3391, file: !3390, line: 20, baseType: !3395, size: 32, offset: 32)
!3395 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !3391, file: !3390, line: 16, size: 32, flags: DIFlagTypePassByValue, elements: !3396, identifier: "_ZTSN11__mbstate_tUt_E")
!3396 = !{!3397, !3398}
!3397 = !DIDerivedType(tag: DW_TAG_member, name: "__wch", scope: !3395, file: !3390, line: 18, baseType: !18, size: 32)
!3398 = !DIDerivedType(tag: DW_TAG_member, name: "__wchb", scope: !3395, file: !3390, line: 19, baseType: !3399, size: 32)
!3399 = !DICompositeType(tag: DW_TAG_array_type, baseType: !76, size: 32, elements: !3400)
!3400 = !{!3401}
!3401 = !DISubrange(count: 4)
!3402 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cwchar", directory: "")
!3403 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3404, file: !3402, line: 141)
!3404 = !DIDerivedType(tag: DW_TAG_typedef, name: "wint_t", file: !3405, line: 20, baseType: !18)
!3405 = !DIFile(filename: "/usr/include/bits/types/wint_t.h", directory: "")
!3406 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3407, file: !3402, line: 143)
!3407 = !DISubprogram(name: "btowc", scope: !3408, file: !3408, line: 318, type: !3409, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3408 = !DIFile(filename: "/usr/include/wchar.h", directory: "")
!3409 = !DISubroutineType(types: !3410)
!3410 = !{!3404, !6}
!3411 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3412, file: !3402, line: 144)
!3412 = !DISubprogram(name: "fgetwc", scope: !3408, file: !3408, line: 726, type: !3413, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3413 = !DISubroutineType(types: !3414)
!3414 = !{!3404, !3415}
!3415 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3416, size: 64)
!3416 = !DIDerivedType(tag: DW_TAG_typedef, name: "__FILE", file: !3417, line: 5, baseType: !3418)
!3417 = !DIFile(filename: "/usr/include/bits/types/__FILE.h", directory: "")
!3418 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !3419, line: 49, size: 1728, flags: DIFlagTypePassByValue, elements: !3420, identifier: "_ZTS8_IO_FILE")
!3419 = !DIFile(filename: "/usr/include/bits/types/struct_FILE.h", directory: "")
!3420 = !{!3421, !3422, !3423, !3424, !3425, !3426, !3427, !3428, !3429, !3430, !3431, !3432, !3433, !3436, !3438, !3439, !3440, !3442, !3444, !3446, !3450, !3453, !3455, !3458, !3461, !3462, !3463, !3464, !3465}
!3421 = !DIDerivedType(tag: DW_TAG_member, name: "_flags", scope: !3418, file: !3419, line: 51, baseType: !6, size: 32)
!3422 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_ptr", scope: !3418, file: !3419, line: 54, baseType: !81, size: 64, offset: 64)
!3423 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_end", scope: !3418, file: !3419, line: 55, baseType: !81, size: 64, offset: 128)
!3424 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_base", scope: !3418, file: !3419, line: 56, baseType: !81, size: 64, offset: 192)
!3425 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_base", scope: !3418, file: !3419, line: 57, baseType: !81, size: 64, offset: 256)
!3426 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_ptr", scope: !3418, file: !3419, line: 58, baseType: !81, size: 64, offset: 320)
!3427 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_end", scope: !3418, file: !3419, line: 59, baseType: !81, size: 64, offset: 384)
!3428 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_base", scope: !3418, file: !3419, line: 60, baseType: !81, size: 64, offset: 448)
!3429 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_end", scope: !3418, file: !3419, line: 61, baseType: !81, size: 64, offset: 512)
!3430 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_base", scope: !3418, file: !3419, line: 64, baseType: !81, size: 64, offset: 576)
!3431 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_backup_base", scope: !3418, file: !3419, line: 65, baseType: !81, size: 64, offset: 640)
!3432 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_end", scope: !3418, file: !3419, line: 66, baseType: !81, size: 64, offset: 704)
!3433 = !DIDerivedType(tag: DW_TAG_member, name: "_markers", scope: !3418, file: !3419, line: 68, baseType: !3434, size: 64, offset: 768)
!3434 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3435, size: 64)
!3435 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_marker", file: !3419, line: 36, flags: DIFlagFwdDecl, identifier: "_ZTS10_IO_marker")
!3436 = !DIDerivedType(tag: DW_TAG_member, name: "_chain", scope: !3418, file: !3419, line: 70, baseType: !3437, size: 64, offset: 832)
!3437 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3418, size: 64)
!3438 = !DIDerivedType(tag: DW_TAG_member, name: "_fileno", scope: !3418, file: !3419, line: 72, baseType: !6, size: 32, offset: 896)
!3439 = !DIDerivedType(tag: DW_TAG_member, name: "_flags2", scope: !3418, file: !3419, line: 73, baseType: !6, size: 32, offset: 928)
!3440 = !DIDerivedType(tag: DW_TAG_member, name: "_old_offset", scope: !3418, file: !3419, line: 74, baseType: !3441, size: 64, offset: 960)
!3441 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off_t", file: !695, line: 152, baseType: !52)
!3442 = !DIDerivedType(tag: DW_TAG_member, name: "_cur_column", scope: !3418, file: !3419, line: 77, baseType: !3443, size: 16, offset: 1024)
!3443 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!3444 = !DIDerivedType(tag: DW_TAG_member, name: "_vtable_offset", scope: !3418, file: !3419, line: 78, baseType: !3445, size: 8, offset: 1040)
!3445 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!3446 = !DIDerivedType(tag: DW_TAG_member, name: "_shortbuf", scope: !3418, file: !3419, line: 79, baseType: !3447, size: 8, offset: 1048)
!3447 = !DICompositeType(tag: DW_TAG_array_type, baseType: !76, size: 8, elements: !3448)
!3448 = !{!3449}
!3449 = !DISubrange(count: 1)
!3450 = !DIDerivedType(tag: DW_TAG_member, name: "_lock", scope: !3418, file: !3419, line: 81, baseType: !3451, size: 64, offset: 1088)
!3451 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3452, size: 64)
!3452 = !DIDerivedType(tag: DW_TAG_typedef, name: "_IO_lock_t", file: !3419, line: 43, baseType: null)
!3453 = !DIDerivedType(tag: DW_TAG_member, name: "_offset", scope: !3418, file: !3419, line: 89, baseType: !3454, size: 64, offset: 1152)
!3454 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off64_t", file: !695, line: 153, baseType: !52)
!3455 = !DIDerivedType(tag: DW_TAG_member, name: "_codecvt", scope: !3418, file: !3419, line: 91, baseType: !3456, size: 64, offset: 1216)
!3456 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3457, size: 64)
!3457 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_codecvt", file: !3419, line: 37, flags: DIFlagFwdDecl, identifier: "_ZTS11_IO_codecvt")
!3458 = !DIDerivedType(tag: DW_TAG_member, name: "_wide_data", scope: !3418, file: !3419, line: 92, baseType: !3459, size: 64, offset: 1280)
!3459 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3460, size: 64)
!3460 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_wide_data", file: !3419, line: 38, flags: DIFlagFwdDecl, identifier: "_ZTS13_IO_wide_data")
!3461 = !DIDerivedType(tag: DW_TAG_member, name: "_freeres_list", scope: !3418, file: !3419, line: 93, baseType: !3437, size: 64, offset: 1344)
!3462 = !DIDerivedType(tag: DW_TAG_member, name: "_freeres_buf", scope: !3418, file: !3419, line: 94, baseType: !68, size: 64, offset: 1408)
!3463 = !DIDerivedType(tag: DW_TAG_member, name: "__pad5", scope: !3418, file: !3419, line: 95, baseType: !779, size: 64, offset: 1472)
!3464 = !DIDerivedType(tag: DW_TAG_member, name: "_mode", scope: !3418, file: !3419, line: 96, baseType: !6, size: 32, offset: 1536)
!3465 = !DIDerivedType(tag: DW_TAG_member, name: "_unused2", scope: !3418, file: !3419, line: 98, baseType: !3466, size: 160, offset: 1568)
!3466 = !DICompositeType(tag: DW_TAG_array_type, baseType: !76, size: 160, elements: !3467)
!3467 = !{!3468}
!3468 = !DISubrange(count: 20)
!3469 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3470, file: !3402, line: 145)
!3470 = !DISubprogram(name: "fgetws", scope: !3408, file: !3408, line: 755, type: !3471, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3471 = !DISubroutineType(types: !3472)
!3472 = !{!3473, !3475, !6, !3476}
!3473 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3474, size: 64)
!3474 = !DIBasicType(name: "wchar_t", size: 32, encoding: DW_ATE_signed)
!3475 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3473)
!3476 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3415)
!3477 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3478, file: !3402, line: 146)
!3478 = !DISubprogram(name: "fputwc", scope: !3408, file: !3408, line: 740, type: !3479, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3479 = !DISubroutineType(types: !3480)
!3480 = !{!3404, !3474, !3415}
!3481 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3482, file: !3402, line: 147)
!3482 = !DISubprogram(name: "fputws", scope: !3408, file: !3408, line: 762, type: !3483, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3483 = !DISubroutineType(types: !3484)
!3484 = !{!6, !3485, !3476}
!3485 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3486)
!3486 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3487, size: 64)
!3487 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3474)
!3488 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3489, file: !3402, line: 148)
!3489 = !DISubprogram(name: "fwide", scope: !3408, file: !3408, line: 573, type: !3490, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3490 = !DISubroutineType(types: !3491)
!3491 = !{!6, !3415, !6}
!3492 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3493, file: !3402, line: 149)
!3493 = !DISubprogram(name: "fwprintf", scope: !3408, file: !3408, line: 580, type: !3494, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3494 = !DISubroutineType(types: !3495)
!3495 = !{!6, !3476, !3485, null}
!3496 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3497, file: !3402, line: 150)
!3497 = !DISubprogram(name: "fwscanf", linkageName: "__isoc99_fwscanf", scope: !3408, file: !3408, line: 640, type: !3494, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3498 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3499, file: !3402, line: 151)
!3499 = !DISubprogram(name: "getwc", scope: !3408, file: !3408, line: 727, type: !3413, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3500 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3501, file: !3402, line: 152)
!3501 = !DISubprogram(name: "getwchar", scope: !3408, file: !3408, line: 733, type: !3502, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3502 = !DISubroutineType(types: !3503)
!3503 = !{!3404}
!3504 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3505, file: !3402, line: 153)
!3505 = !DISubprogram(name: "mbrlen", scope: !3408, file: !3408, line: 329, type: !3506, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3506 = !DISubroutineType(types: !3507)
!3507 = !{!779, !3508, !779, !3509}
!3508 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !74)
!3509 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3510)
!3510 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3387, size: 64)
!3511 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3512, file: !3402, line: 154)
!3512 = !DISubprogram(name: "mbrtowc", scope: !3408, file: !3408, line: 296, type: !3513, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3513 = !DISubroutineType(types: !3514)
!3514 = !{!779, !3475, !3508, !779, !3509}
!3515 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3516, file: !3402, line: 155)
!3516 = !DISubprogram(name: "mbsinit", scope: !3408, file: !3408, line: 292, type: !3517, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3517 = !DISubroutineType(types: !3518)
!3518 = !{!6, !3519}
!3519 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3520, size: 64)
!3520 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3387)
!3521 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3522, file: !3402, line: 156)
!3522 = !DISubprogram(name: "mbsrtowcs", scope: !3408, file: !3408, line: 337, type: !3523, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3523 = !DISubroutineType(types: !3524)
!3524 = !{!779, !3475, !3525, !779, !3509}
!3525 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3526)
!3526 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !74, size: 64)
!3527 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3528, file: !3402, line: 157)
!3528 = !DISubprogram(name: "putwc", scope: !3408, file: !3408, line: 741, type: !3479, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3529 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3530, file: !3402, line: 158)
!3530 = !DISubprogram(name: "putwchar", scope: !3408, file: !3408, line: 747, type: !3531, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3531 = !DISubroutineType(types: !3532)
!3532 = !{!3404, !3474}
!3533 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3534, file: !3402, line: 160)
!3534 = !DISubprogram(name: "swprintf", scope: !3408, file: !3408, line: 590, type: !3535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3535 = !DISubroutineType(types: !3536)
!3536 = !{!6, !3475, !779, !3485, null}
!3537 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3538, file: !3402, line: 162)
!3538 = !DISubprogram(name: "swscanf", linkageName: "__isoc99_swscanf", scope: !3408, file: !3408, line: 647, type: !3539, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3539 = !DISubroutineType(types: !3540)
!3540 = !{!6, !3485, !3485, null}
!3541 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3542, file: !3402, line: 163)
!3542 = !DISubprogram(name: "ungetwc", scope: !3408, file: !3408, line: 770, type: !3543, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3543 = !DISubroutineType(types: !3544)
!3544 = !{!3404, !3404, !3415}
!3545 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3546, file: !3402, line: 164)
!3546 = !DISubprogram(name: "vfwprintf", scope: !3408, file: !3408, line: 598, type: !3547, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3547 = !DISubroutineType(types: !3548)
!3548 = !{!6, !3476, !3485, !3549}
!3549 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3550, size: 64)
!3550 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "__va_list_tag", file: !1, size: 192, flags: DIFlagTypePassByValue, elements: !3551, identifier: "_ZTS13__va_list_tag")
!3551 = !{!3552, !3553, !3554, !3555}
!3552 = !DIDerivedType(tag: DW_TAG_member, name: "gp_offset", scope: !3550, file: !1, baseType: !18, size: 32)
!3553 = !DIDerivedType(tag: DW_TAG_member, name: "fp_offset", scope: !3550, file: !1, baseType: !18, size: 32, offset: 32)
!3554 = !DIDerivedType(tag: DW_TAG_member, name: "overflow_arg_area", scope: !3550, file: !1, baseType: !68, size: 64, offset: 64)
!3555 = !DIDerivedType(tag: DW_TAG_member, name: "reg_save_area", scope: !3550, file: !1, baseType: !68, size: 64, offset: 128)
!3556 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3557, file: !3402, line: 166)
!3557 = !DISubprogram(name: "vfwscanf", linkageName: "__isoc99_vfwscanf", scope: !3408, file: !3408, line: 693, type: !3547, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3558 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3559, file: !3402, line: 169)
!3559 = !DISubprogram(name: "vswprintf", scope: !3408, file: !3408, line: 611, type: !3560, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3560 = !DISubroutineType(types: !3561)
!3561 = !{!6, !3475, !779, !3485, !3549}
!3562 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3563, file: !3402, line: 172)
!3563 = !DISubprogram(name: "vswscanf", linkageName: "__isoc99_vswscanf", scope: !3408, file: !3408, line: 700, type: !3564, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3564 = !DISubroutineType(types: !3565)
!3565 = !{!6, !3485, !3485, !3549}
!3566 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3567, file: !3402, line: 174)
!3567 = !DISubprogram(name: "vwprintf", scope: !3408, file: !3408, line: 606, type: !3568, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3568 = !DISubroutineType(types: !3569)
!3569 = !{!6, !3485, !3549}
!3570 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3571, file: !3402, line: 176)
!3571 = !DISubprogram(name: "vwscanf", linkageName: "__isoc99_vwscanf", scope: !3408, file: !3408, line: 697, type: !3568, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3572 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3573, file: !3402, line: 178)
!3573 = !DISubprogram(name: "wcrtomb", scope: !3408, file: !3408, line: 301, type: !3574, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3574 = !DISubroutineType(types: !3575)
!3575 = !{!779, !3576, !3474, !3509}
!3576 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !81)
!3577 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3578, file: !3402, line: 179)
!3578 = !DISubprogram(name: "wcscat", scope: !3408, file: !3408, line: 97, type: !3579, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3579 = !DISubroutineType(types: !3580)
!3580 = !{!3473, !3475, !3485}
!3581 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3582, file: !3402, line: 180)
!3582 = !DISubprogram(name: "wcscmp", scope: !3408, file: !3408, line: 106, type: !3583, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3583 = !DISubroutineType(types: !3584)
!3584 = !{!6, !3486, !3486}
!3585 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3586, file: !3402, line: 181)
!3586 = !DISubprogram(name: "wcscoll", scope: !3408, file: !3408, line: 131, type: !3583, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3587 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3588, file: !3402, line: 182)
!3588 = !DISubprogram(name: "wcscpy", scope: !3408, file: !3408, line: 87, type: !3579, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3589 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3590, file: !3402, line: 183)
!3590 = !DISubprogram(name: "wcscspn", scope: !3408, file: !3408, line: 187, type: !3591, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3591 = !DISubroutineType(types: !3592)
!3592 = !{!779, !3486, !3486}
!3593 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3594, file: !3402, line: 184)
!3594 = !DISubprogram(name: "wcsftime", scope: !3408, file: !3408, line: 834, type: !3595, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3595 = !DISubroutineType(types: !3596)
!3596 = !{!779, !3475, !779, !3485, !3597}
!3597 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3598)
!3598 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3599, size: 64)
!3599 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3600)
!3600 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tm", file: !3601, line: 7, size: 448, flags: DIFlagTypePassByValue, elements: !3602, identifier: "_ZTS2tm")
!3601 = !DIFile(filename: "/usr/include/bits/types/struct_tm.h", directory: "")
!3602 = !{!3603, !3604, !3605, !3606, !3607, !3608, !3609, !3610, !3611, !3612, !3613}
!3603 = !DIDerivedType(tag: DW_TAG_member, name: "tm_sec", scope: !3600, file: !3601, line: 9, baseType: !6, size: 32)
!3604 = !DIDerivedType(tag: DW_TAG_member, name: "tm_min", scope: !3600, file: !3601, line: 10, baseType: !6, size: 32, offset: 32)
!3605 = !DIDerivedType(tag: DW_TAG_member, name: "tm_hour", scope: !3600, file: !3601, line: 11, baseType: !6, size: 32, offset: 64)
!3606 = !DIDerivedType(tag: DW_TAG_member, name: "tm_mday", scope: !3600, file: !3601, line: 12, baseType: !6, size: 32, offset: 96)
!3607 = !DIDerivedType(tag: DW_TAG_member, name: "tm_mon", scope: !3600, file: !3601, line: 13, baseType: !6, size: 32, offset: 128)
!3608 = !DIDerivedType(tag: DW_TAG_member, name: "tm_year", scope: !3600, file: !3601, line: 14, baseType: !6, size: 32, offset: 160)
!3609 = !DIDerivedType(tag: DW_TAG_member, name: "tm_wday", scope: !3600, file: !3601, line: 15, baseType: !6, size: 32, offset: 192)
!3610 = !DIDerivedType(tag: DW_TAG_member, name: "tm_yday", scope: !3600, file: !3601, line: 16, baseType: !6, size: 32, offset: 224)
!3611 = !DIDerivedType(tag: DW_TAG_member, name: "tm_isdst", scope: !3600, file: !3601, line: 17, baseType: !6, size: 32, offset: 256)
!3612 = !DIDerivedType(tag: DW_TAG_member, name: "tm_gmtoff", scope: !3600, file: !3601, line: 20, baseType: !52, size: 64, offset: 320)
!3613 = !DIDerivedType(tag: DW_TAG_member, name: "tm_zone", scope: !3600, file: !3601, line: 21, baseType: !74, size: 64, offset: 384)
!3614 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3615, file: !3402, line: 185)
!3615 = !DISubprogram(name: "wcslen", scope: !3408, file: !3408, line: 222, type: !3616, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3616 = !DISubroutineType(types: !3617)
!3617 = !{!779, !3486}
!3618 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3619, file: !3402, line: 186)
!3619 = !DISubprogram(name: "wcsncat", scope: !3408, file: !3408, line: 101, type: !3620, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3620 = !DISubroutineType(types: !3621)
!3621 = !{!3473, !3475, !3485, !779}
!3622 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3623, file: !3402, line: 187)
!3623 = !DISubprogram(name: "wcsncmp", scope: !3408, file: !3408, line: 109, type: !3624, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3624 = !DISubroutineType(types: !3625)
!3625 = !{!6, !3486, !3486, !779}
!3626 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3627, file: !3402, line: 188)
!3627 = !DISubprogram(name: "wcsncpy", scope: !3408, file: !3408, line: 92, type: !3620, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3628 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3629, file: !3402, line: 189)
!3629 = !DISubprogram(name: "wcsrtombs", scope: !3408, file: !3408, line: 343, type: !3630, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3630 = !DISubroutineType(types: !3631)
!3631 = !{!779, !3576, !3632, !779, !3509}
!3632 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3633)
!3633 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3486, size: 64)
!3634 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3635, file: !3402, line: 190)
!3635 = !DISubprogram(name: "wcsspn", scope: !3408, file: !3408, line: 191, type: !3591, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3636 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3637, file: !3402, line: 191)
!3637 = !DISubprogram(name: "wcstod", scope: !3408, file: !3408, line: 377, type: !3638, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3638 = !DISubroutineType(types: !3639)
!3639 = !{!358, !3485, !3640}
!3640 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3641)
!3641 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3473, size: 64)
!3642 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3643, file: !3402, line: 193)
!3643 = !DISubprogram(name: "wcstof", scope: !3408, file: !3408, line: 382, type: !3644, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3644 = !DISubroutineType(types: !3645)
!3645 = !{!69, !3485, !3640}
!3646 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3647, file: !3402, line: 195)
!3647 = !DISubprogram(name: "wcstok", scope: !3408, file: !3408, line: 217, type: !3648, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3648 = !DISubroutineType(types: !3649)
!3649 = !{!3473, !3475, !3485, !3640}
!3650 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3651, file: !3402, line: 196)
!3651 = !DISubprogram(name: "wcstol", scope: !3408, file: !3408, line: 428, type: !3652, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3652 = !DISubroutineType(types: !3653)
!3653 = !{!52, !3485, !3640, !6}
!3654 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3655, file: !3402, line: 197)
!3655 = !DISubprogram(name: "wcstoul", scope: !3408, file: !3408, line: 433, type: !3656, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3656 = !DISubroutineType(types: !3657)
!3657 = !{!86, !3485, !3640, !6}
!3658 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3659, file: !3402, line: 198)
!3659 = !DISubprogram(name: "wcsxfrm", scope: !3408, file: !3408, line: 135, type: !3660, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3660 = !DISubroutineType(types: !3661)
!3661 = !{!779, !3475, !3485, !779}
!3662 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3663, file: !3402, line: 199)
!3663 = !DISubprogram(name: "wctob", scope: !3408, file: !3408, line: 324, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3664 = !DISubroutineType(types: !3665)
!3665 = !{!6, !3404}
!3666 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3667, file: !3402, line: 200)
!3667 = !DISubprogram(name: "wmemcmp", scope: !3408, file: !3408, line: 258, type: !3624, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3668 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3669, file: !3402, line: 201)
!3669 = !DISubprogram(name: "wmemcpy", scope: !3408, file: !3408, line: 262, type: !3620, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3670 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3671, file: !3402, line: 202)
!3671 = !DISubprogram(name: "wmemmove", scope: !3408, file: !3408, line: 267, type: !3672, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3672 = !DISubroutineType(types: !3673)
!3673 = !{!3473, !3473, !3486, !779}
!3674 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3675, file: !3402, line: 203)
!3675 = !DISubprogram(name: "wmemset", scope: !3408, file: !3408, line: 271, type: !3676, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3676 = !DISubroutineType(types: !3677)
!3677 = !{!3473, !3473, !3474, !779}
!3678 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3679, file: !3402, line: 204)
!3679 = !DISubprogram(name: "wprintf", scope: !3408, file: !3408, line: 587, type: !3680, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3680 = !DISubroutineType(types: !3681)
!3681 = !{!6, !3485, null}
!3682 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3683, file: !3402, line: 205)
!3683 = !DISubprogram(name: "wscanf", linkageName: "__isoc99_wscanf", scope: !3408, file: !3408, line: 644, type: !3680, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3684 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3685, file: !3402, line: 206)
!3685 = !DISubprogram(name: "wcschr", scope: !3408, file: !3408, line: 164, type: !3686, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3686 = !DISubroutineType(types: !3687)
!3687 = !{!3473, !3486, !3474}
!3688 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3689, file: !3402, line: 207)
!3689 = !DISubprogram(name: "wcspbrk", scope: !3408, file: !3408, line: 201, type: !3690, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3690 = !DISubroutineType(types: !3691)
!3691 = !{!3473, !3486, !3486}
!3692 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3693, file: !3402, line: 208)
!3693 = !DISubprogram(name: "wcsrchr", scope: !3408, file: !3408, line: 174, type: !3686, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3694 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3695, file: !3402, line: 209)
!3695 = !DISubprogram(name: "wcsstr", scope: !3408, file: !3408, line: 212, type: !3690, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3696 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3697, file: !3402, line: 210)
!3697 = !DISubprogram(name: "wmemchr", scope: !3408, file: !3408, line: 253, type: !3698, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3698 = !DISubroutineType(types: !3699)
!3699 = !{!3473, !3486, !3474, !779}
!3700 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !3701, file: !3402, line: 251)
!3701 = !DISubprogram(name: "wcstold", scope: !3408, file: !3408, line: 384, type: !3702, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3702 = !DISubroutineType(types: !3703)
!3703 = !{!3704, !3485, !3640}
!3704 = !DIBasicType(name: "long double", size: 128, encoding: DW_ATE_float)
!3705 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !3706, file: !3402, line: 260)
!3706 = !DISubprogram(name: "wcstoll", scope: !3408, file: !3408, line: 441, type: !3707, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3707 = !DISubroutineType(types: !3708)
!3708 = !{!3709, !3485, !3640, !6}
!3709 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!3710 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !3711, file: !3402, line: 261)
!3711 = !DISubprogram(name: "wcstoull", scope: !3408, file: !3408, line: 448, type: !3712, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3712 = !DISubroutineType(types: !3713)
!3713 = !{!3714, !3485, !3640, !6}
!3714 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!3715 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3701, file: !3402, line: 267)
!3716 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3706, file: !3402, line: 268)
!3717 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3711, file: !3402, line: 269)
!3718 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3643, file: !3402, line: 283)
!3719 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3557, file: !3402, line: 286)
!3720 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3563, file: !3402, line: 289)
!3721 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3571, file: !3402, line: 292)
!3722 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3701, file: !3402, line: 296)
!3723 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3706, file: !3402, line: 297)
!3724 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3711, file: !3402, line: 298)
!3725 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3726, file: !3727, line: 58)
!3726 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "exception_ptr", scope: !3728, file: !3727, line: 80, size: 64, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !3729, identifier: "_ZTSNSt15__exception_ptr13exception_ptrE")
!3727 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/exception_ptr.h", directory: "")
!3728 = !DINamespace(name: "__exception_ptr", scope: !5)
!3729 = !{!3730, !3731, !3735, !3738, !3739, !3744, !3745, !3749, !3754, !3758, !3762, !3765, !3766, !3769, !3772}
!3730 = !DIDerivedType(tag: DW_TAG_member, name: "_M_exception_object", scope: !3726, file: !3727, line: 82, baseType: !68, size: 64)
!3731 = !DISubprogram(name: "exception_ptr", scope: !3726, file: !3727, line: 84, type: !3732, scopeLine: 84, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3732 = !DISubroutineType(types: !3733)
!3733 = !{null, !3734, !68}
!3734 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3726, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!3735 = !DISubprogram(name: "_M_addref", linkageName: "_ZNSt15__exception_ptr13exception_ptr9_M_addrefEv", scope: !3726, file: !3727, line: 86, type: !3736, scopeLine: 86, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3736 = !DISubroutineType(types: !3737)
!3737 = !{null, !3734}
!3738 = !DISubprogram(name: "_M_release", linkageName: "_ZNSt15__exception_ptr13exception_ptr10_M_releaseEv", scope: !3726, file: !3727, line: 87, type: !3736, scopeLine: 87, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3739 = !DISubprogram(name: "_M_get", linkageName: "_ZNKSt15__exception_ptr13exception_ptr6_M_getEv", scope: !3726, file: !3727, line: 89, type: !3740, scopeLine: 89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3740 = !DISubroutineType(types: !3741)
!3741 = !{!68, !3742}
!3742 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3743, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!3743 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3726)
!3744 = !DISubprogram(name: "exception_ptr", scope: !3726, file: !3727, line: 97, type: !3736, scopeLine: 97, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3745 = !DISubprogram(name: "exception_ptr", scope: !3726, file: !3727, line: 99, type: !3746, scopeLine: 99, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3746 = !DISubroutineType(types: !3747)
!3747 = !{null, !3734, !3748}
!3748 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3743, size: 64)
!3749 = !DISubprogram(name: "exception_ptr", scope: !3726, file: !3727, line: 102, type: !3750, scopeLine: 102, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3750 = !DISubroutineType(types: !3751)
!3751 = !{null, !3734, !3752}
!3752 = !DIDerivedType(tag: DW_TAG_typedef, name: "nullptr_t", scope: !5, file: !592, line: 2367, baseType: !3753)
!3753 = !DIBasicType(tag: DW_TAG_unspecified_type, name: "decltype(nullptr)")
!3754 = !DISubprogram(name: "exception_ptr", scope: !3726, file: !3727, line: 106, type: !3755, scopeLine: 106, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3755 = !DISubroutineType(types: !3756)
!3756 = !{null, !3734, !3757}
!3757 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !3726, size: 64)
!3758 = !DISubprogram(name: "operator=", linkageName: "_ZNSt15__exception_ptr13exception_ptraSERKS0_", scope: !3726, file: !3727, line: 119, type: !3759, scopeLine: 119, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3759 = !DISubroutineType(types: !3760)
!3760 = !{!3761, !3734, !3748}
!3761 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !3726, size: 64)
!3762 = !DISubprogram(name: "operator=", linkageName: "_ZNSt15__exception_ptr13exception_ptraSEOS0_", scope: !3726, file: !3727, line: 123, type: !3763, scopeLine: 123, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3763 = !DISubroutineType(types: !3764)
!3764 = !{!3761, !3734, !3757}
!3765 = !DISubprogram(name: "~exception_ptr", scope: !3726, file: !3727, line: 130, type: !3736, scopeLine: 130, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3766 = !DISubprogram(name: "swap", linkageName: "_ZNSt15__exception_ptr13exception_ptr4swapERS0_", scope: !3726, file: !3727, line: 133, type: !3767, scopeLine: 133, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3767 = !DISubroutineType(types: !3768)
!3768 = !{null, !3734, !3761}
!3769 = !DISubprogram(name: "operator bool", linkageName: "_ZNKSt15__exception_ptr13exception_ptrcvbEv", scope: !3726, file: !3727, line: 145, type: !3770, scopeLine: 145, flags: DIFlagPublic | DIFlagExplicit | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3770 = !DISubroutineType(types: !3771)
!3771 = !{!92, !3742}
!3772 = !DISubprogram(name: "__cxa_exception_type", linkageName: "_ZNKSt15__exception_ptr13exception_ptr20__cxa_exception_typeEv", scope: !3726, file: !3727, line: 154, type: !3773, scopeLine: 154, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3773 = !DISubroutineType(types: !3774)
!3774 = !{!3775, !3742}
!3775 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3776, size: 64)
!3776 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3777)
!3777 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "type_info", scope: !5, file: !3778, line: 88, flags: DIFlagFwdDecl, identifier: "_ZTSSt9type_info")
!3778 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/typeinfo", directory: "")
!3779 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !3728, entity: !3780, file: !3727, line: 74)
!3780 = !DISubprogram(name: "rethrow_exception", linkageName: "_ZSt17rethrow_exceptionNSt15__exception_ptr13exception_ptrE", scope: !5, file: !3727, line: 70, type: !3781, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: DISPFlagOptimized)
!3781 = !DISubroutineType(types: !3782)
!3782 = !{null, !3726}
!3783 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !3784, entity: !3785, file: !3786, line: 58)
!3784 = !DINamespace(name: "__gnu_debug", scope: null)
!3785 = !DINamespace(name: "__debug", scope: !5)
!3786 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/debug/debug.h", directory: "")
!3787 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3788, file: !3791, line: 47)
!3788 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !3789, line: 24, baseType: !3790)
!3789 = !DIFile(filename: "/usr/include/bits/stdint-intn.h", directory: "")
!3790 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int8_t", file: !695, line: 37, baseType: !3445)
!3791 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cstdint", directory: "")
!3792 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3793, file: !3791, line: 48)
!3793 = !DIDerivedType(tag: DW_TAG_typedef, name: "int16_t", file: !3789, line: 25, baseType: !3794)
!3794 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int16_t", file: !695, line: 39, baseType: !3795)
!3795 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!3796 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3797, file: !3791, line: 49)
!3797 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !3789, line: 26, baseType: !3798)
!3798 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int32_t", file: !695, line: 41, baseType: !6)
!3799 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3800, file: !3791, line: 50)
!3800 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !3789, line: 27, baseType: !3801)
!3801 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int64_t", file: !695, line: 44, baseType: !52)
!3802 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3803, file: !3791, line: 52)
!3803 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast8_t", file: !3804, line: 58, baseType: !3445)
!3804 = !DIFile(filename: "/usr/include/stdint.h", directory: "")
!3805 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3806, file: !3791, line: 53)
!3806 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast16_t", file: !3804, line: 60, baseType: !52)
!3807 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3808, file: !3791, line: 54)
!3808 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast32_t", file: !3804, line: 61, baseType: !52)
!3809 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3810, file: !3791, line: 55)
!3810 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast64_t", file: !3804, line: 62, baseType: !52)
!3811 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3812, file: !3791, line: 57)
!3812 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least8_t", file: !3804, line: 43, baseType: !3813)
!3813 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least8_t", file: !695, line: 52, baseType: !3790)
!3814 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3815, file: !3791, line: 58)
!3815 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least16_t", file: !3804, line: 44, baseType: !3816)
!3816 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least16_t", file: !695, line: 54, baseType: !3794)
!3817 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3818, file: !3791, line: 59)
!3818 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least32_t", file: !3804, line: 45, baseType: !3819)
!3819 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least32_t", file: !695, line: 56, baseType: !3798)
!3820 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3821, file: !3791, line: 60)
!3821 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least64_t", file: !3804, line: 46, baseType: !3822)
!3822 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least64_t", file: !695, line: 58, baseType: !3801)
!3823 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3824, file: !3791, line: 62)
!3824 = !DIDerivedType(tag: DW_TAG_typedef, name: "intmax_t", file: !3804, line: 101, baseType: !3825)
!3825 = !DIDerivedType(tag: DW_TAG_typedef, name: "__intmax_t", file: !695, line: 72, baseType: !52)
!3826 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3827, file: !3791, line: 63)
!3827 = !DIDerivedType(tag: DW_TAG_typedef, name: "intptr_t", file: !3804, line: 87, baseType: !52)
!3828 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3829, file: !3791, line: 65)
!3829 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !1289, line: 24, baseType: !3830)
!3830 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !695, line: 38, baseType: !64)
!3831 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3832, file: !3791, line: 66)
!3832 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !1289, line: 25, baseType: !3833)
!3833 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !695, line: 40, baseType: !3443)
!3834 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !1288, file: !3791, line: 67)
!3835 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3836, file: !3791, line: 68)
!3836 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !1289, line: 27, baseType: !3837)
!3837 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint64_t", file: !695, line: 45, baseType: !86)
!3838 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3839, file: !3791, line: 70)
!3839 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast8_t", file: !3804, line: 71, baseType: !64)
!3840 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3841, file: !3791, line: 71)
!3841 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast16_t", file: !3804, line: 73, baseType: !86)
!3842 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3843, file: !3791, line: 72)
!3843 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast32_t", file: !3804, line: 74, baseType: !86)
!3844 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3845, file: !3791, line: 73)
!3845 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast64_t", file: !3804, line: 75, baseType: !86)
!3846 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3847, file: !3791, line: 75)
!3847 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least8_t", file: !3804, line: 49, baseType: !3848)
!3848 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least8_t", file: !695, line: 53, baseType: !3830)
!3849 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3850, file: !3791, line: 76)
!3850 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least16_t", file: !3804, line: 50, baseType: !3851)
!3851 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least16_t", file: !695, line: 55, baseType: !3833)
!3852 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3853, file: !3791, line: 77)
!3853 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least32_t", file: !3804, line: 51, baseType: !3854)
!3854 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least32_t", file: !695, line: 57, baseType: !1290)
!3855 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3856, file: !3791, line: 78)
!3856 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least64_t", file: !3804, line: 52, baseType: !3857)
!3857 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least64_t", file: !695, line: 59, baseType: !3837)
!3858 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3859, file: !3791, line: 80)
!3859 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintmax_t", file: !3804, line: 102, baseType: !3860)
!3860 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uintmax_t", file: !695, line: 73, baseType: !86)
!3861 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3862, file: !3791, line: 81)
!3862 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !3804, line: 90, baseType: !86)
!3863 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3864, file: !3866, line: 53)
!3864 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "lconv", file: !3865, line: 51, flags: DIFlagFwdDecl, identifier: "_ZTS5lconv")
!3865 = !DIFile(filename: "/usr/include/locale.h", directory: "")
!3866 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/clocale", directory: "")
!3867 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3868, file: !3866, line: 54)
!3868 = !DISubprogram(name: "setlocale", scope: !3865, file: !3865, line: 122, type: !3869, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3869 = !DISubroutineType(types: !3870)
!3870 = !{!81, !6, !74}
!3871 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3872, file: !3866, line: 55)
!3872 = !DISubprogram(name: "localeconv", scope: !3865, file: !3865, line: 125, type: !3873, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3873 = !DISubroutineType(types: !3874)
!3874 = !{!3875}
!3875 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3864, size: 64)
!3876 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3877, file: !3879, line: 64)
!3877 = !DISubprogram(name: "isalnum", scope: !3878, file: !3878, line: 108, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3878 = !DIFile(filename: "/usr/include/ctype.h", directory: "")
!3879 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cctype", directory: "")
!3880 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3881, file: !3879, line: 65)
!3881 = !DISubprogram(name: "isalpha", scope: !3878, file: !3878, line: 109, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3882 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3883, file: !3879, line: 66)
!3883 = !DISubprogram(name: "iscntrl", scope: !3878, file: !3878, line: 110, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3884 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3885, file: !3879, line: 67)
!3885 = !DISubprogram(name: "isdigit", scope: !3878, file: !3878, line: 111, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3886 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3887, file: !3879, line: 68)
!3887 = !DISubprogram(name: "isgraph", scope: !3878, file: !3878, line: 113, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3888 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3889, file: !3879, line: 69)
!3889 = !DISubprogram(name: "islower", scope: !3878, file: !3878, line: 112, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3890 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3891, file: !3879, line: 70)
!3891 = !DISubprogram(name: "isprint", scope: !3878, file: !3878, line: 114, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3892 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3893, file: !3879, line: 71)
!3893 = !DISubprogram(name: "ispunct", scope: !3878, file: !3878, line: 115, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3894 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3895, file: !3879, line: 72)
!3895 = !DISubprogram(name: "isspace", scope: !3878, file: !3878, line: 116, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3896 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3897, file: !3879, line: 73)
!3897 = !DISubprogram(name: "isupper", scope: !3878, file: !3878, line: 117, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3898 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3899, file: !3879, line: 74)
!3899 = !DISubprogram(name: "isxdigit", scope: !3878, file: !3878, line: 118, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3900 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3901, file: !3879, line: 75)
!3901 = !DISubprogram(name: "tolower", scope: !3878, file: !3878, line: 122, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3902 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3903, file: !3879, line: 76)
!3903 = !DISubprogram(name: "toupper", scope: !3878, file: !3878, line: 125, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3904 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3905, file: !3879, line: 87)
!3905 = !DISubprogram(name: "isblank", scope: !3878, file: !3878, line: 130, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3906 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3907, file: !3908, line: 52)
!3907 = !DISubprogram(name: "abs", scope: !1430, file: !1430, line: 840, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3908 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/std_abs.h", directory: "")
!3909 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3910, file: !3912, line: 127)
!3910 = !DIDerivedType(tag: DW_TAG_typedef, name: "div_t", file: !1430, line: 62, baseType: !3911)
!3911 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !1430, line: 58, flags: DIFlagFwdDecl, identifier: "_ZTS5div_t")
!3912 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cstdlib", directory: "")
!3913 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3914, file: !3912, line: 128)
!3914 = !DIDerivedType(tag: DW_TAG_typedef, name: "ldiv_t", file: !1430, line: 70, baseType: !3915)
!3915 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !1430, line: 66, size: 128, flags: DIFlagTypePassByValue, elements: !3916, identifier: "_ZTS6ldiv_t")
!3916 = !{!3917, !3918}
!3917 = !DIDerivedType(tag: DW_TAG_member, name: "quot", scope: !3915, file: !1430, line: 68, baseType: !52, size: 64)
!3918 = !DIDerivedType(tag: DW_TAG_member, name: "rem", scope: !3915, file: !1430, line: 69, baseType: !52, size: 64, offset: 64)
!3919 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3920, file: !3912, line: 130)
!3920 = !DISubprogram(name: "abort", scope: !1430, file: !1430, line: 591, type: !3921, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: DISPFlagOptimized)
!3921 = !DISubroutineType(types: !3922)
!3922 = !{null}
!3923 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3924, file: !3912, line: 134)
!3924 = !DISubprogram(name: "atexit", scope: !1430, file: !1430, line: 595, type: !3925, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3925 = !DISubroutineType(types: !3926)
!3926 = !{!6, !3927}
!3927 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3921, size: 64)
!3928 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3929, file: !3912, line: 137)
!3929 = !DISubprogram(name: "at_quick_exit", scope: !1430, file: !1430, line: 600, type: !3925, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3930 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3931, file: !3912, line: 140)
!3931 = !DISubprogram(name: "atof", scope: !3932, file: !3932, line: 25, type: !3933, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3932 = !DIFile(filename: "/usr/include/bits/stdlib-float.h", directory: "")
!3933 = !DISubroutineType(types: !3934)
!3934 = !{!358, !74}
!3935 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3936, file: !3912, line: 141)
!3936 = !DISubprogram(name: "atoi", scope: !1430, file: !1430, line: 361, type: !3937, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3937 = !DISubroutineType(types: !3938)
!3938 = !{!6, !74}
!3939 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3940, file: !3912, line: 142)
!3940 = distinct !DISubprogram(name: "atol", scope: !1430, file: !1430, line: 366, type: !3941, scopeLine: 367, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !3943)
!3941 = !DISubroutineType(types: !3942)
!3942 = !{!52, !74}
!3943 = !{!3944}
!3944 = !DILocalVariable(name: "__nptr", arg: 1, scope: !3940, file: !1430, line: 366, type: !74)
!3945 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3946, file: !3912, line: 143)
!3946 = !DISubprogram(name: "bsearch", scope: !3947, file: !3947, line: 20, type: !3948, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3947 = !DIFile(filename: "/usr/include/bits/stdlib-bsearch.h", directory: "")
!3948 = !DISubroutineType(types: !3949)
!3949 = !{!68, !597, !597, !779, !779, !3950}
!3950 = !DIDerivedType(tag: DW_TAG_typedef, name: "__compar_fn_t", file: !1430, line: 808, baseType: !3951)
!3951 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3952, size: 64)
!3952 = !DISubroutineType(types: !3953)
!3953 = !{!6, !597, !597}
!3954 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3955, file: !3912, line: 144)
!3955 = !DISubprogram(name: "calloc", scope: !1430, file: !1430, line: 542, type: !3956, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3956 = !DISubroutineType(types: !3957)
!3957 = !{!68, !779, !779}
!3958 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3959, file: !3912, line: 145)
!3959 = !DISubprogram(name: "div", scope: !1430, file: !1430, line: 852, type: !3960, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3960 = !DISubroutineType(types: !3961)
!3961 = !{!3910, !6, !6}
!3962 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3963, file: !3912, line: 146)
!3963 = !DISubprogram(name: "exit", scope: !1430, file: !1430, line: 617, type: !3964, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: DISPFlagOptimized)
!3964 = !DISubroutineType(types: !3965)
!3965 = !{null, !6}
!3966 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3967, file: !3912, line: 147)
!3967 = !DISubprogram(name: "free", scope: !1430, file: !1430, line: 565, type: !66, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3968 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3969, file: !3912, line: 148)
!3969 = !DISubprogram(name: "getenv", scope: !1430, file: !1430, line: 634, type: !3970, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3970 = !DISubroutineType(types: !3971)
!3971 = !{!81, !74}
!3972 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3973, file: !3912, line: 149)
!3973 = !DISubprogram(name: "labs", scope: !1430, file: !1430, line: 841, type: !2413, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3974 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3975, file: !3912, line: 150)
!3975 = !DISubprogram(name: "ldiv", scope: !1430, file: !1430, line: 854, type: !3976, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3976 = !DISubroutineType(types: !3977)
!3977 = !{!3914, !52, !52}
!3978 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3979, file: !3912, line: 151)
!3979 = !DISubprogram(name: "malloc", scope: !1430, file: !1430, line: 539, type: !3980, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3980 = !DISubroutineType(types: !3981)
!3981 = !{!68, !779}
!3982 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3983, file: !3912, line: 153)
!3983 = !DISubprogram(name: "mblen", scope: !1430, file: !1430, line: 922, type: !3984, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3984 = !DISubroutineType(types: !3985)
!3985 = !{!6, !74, !779}
!3986 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3987, file: !3912, line: 154)
!3987 = !DISubprogram(name: "mbstowcs", scope: !1430, file: !1430, line: 933, type: !3988, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3988 = !DISubroutineType(types: !3989)
!3989 = !{!779, !3475, !3508, !779}
!3990 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3991, file: !3912, line: 155)
!3991 = !DISubprogram(name: "mbtowc", scope: !1430, file: !1430, line: 925, type: !3992, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3992 = !DISubroutineType(types: !3993)
!3993 = !{!6, !3475, !3508, !779}
!3994 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3995, file: !3912, line: 157)
!3995 = !DISubprogram(name: "qsort", scope: !1430, file: !1430, line: 830, type: !3996, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!3996 = !DISubroutineType(types: !3997)
!3997 = !{null, !68, !779, !779, !3950}
!3998 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3999, file: !3912, line: 160)
!3999 = !DISubprogram(name: "quick_exit", scope: !1430, file: !1430, line: 623, type: !3964, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: DISPFlagOptimized)
!4000 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4001, file: !3912, line: 163)
!4001 = !DISubprogram(name: "rand", scope: !1430, file: !1430, line: 453, type: !172, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4002 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4003, file: !3912, line: 164)
!4003 = !DISubprogram(name: "realloc", scope: !1430, file: !1430, line: 550, type: !4004, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4004 = !DISubroutineType(types: !4005)
!4005 = !{!68, !68, !779}
!4006 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4007, file: !3912, line: 165)
!4007 = !DISubprogram(name: "srand", scope: !1430, file: !1430, line: 455, type: !4008, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4008 = !DISubroutineType(types: !4009)
!4009 = !{null, !18}
!4010 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4011, file: !3912, line: 166)
!4011 = !DISubprogram(name: "strtod", scope: !1430, file: !1430, line: 117, type: !4012, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4012 = !DISubroutineType(types: !4013)
!4013 = !{!358, !3508, !4014}
!4014 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !111)
!4015 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4016, file: !3912, line: 167)
!4016 = !DISubprogram(name: "strtol", scope: !1430, file: !1430, line: 176, type: !4017, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4017 = !DISubroutineType(types: !4018)
!4018 = !{!52, !3508, !4014, !6}
!4019 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4020, file: !3912, line: 168)
!4020 = !DISubprogram(name: "strtoul", scope: !1430, file: !1430, line: 180, type: !4021, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4021 = !DISubroutineType(types: !4022)
!4022 = !{!86, !3508, !4014, !6}
!4023 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4024, file: !3912, line: 169)
!4024 = !DISubprogram(name: "system", scope: !1430, file: !1430, line: 784, type: !3937, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4025 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4026, file: !3912, line: 171)
!4026 = !DISubprogram(name: "wcstombs", scope: !1430, file: !1430, line: 936, type: !4027, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4027 = !DISubroutineType(types: !4028)
!4028 = !{!779, !3576, !3485, !779}
!4029 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4030, file: !3912, line: 172)
!4030 = !DISubprogram(name: "wctomb", scope: !1430, file: !1430, line: 929, type: !4031, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4031 = !DISubroutineType(types: !4032)
!4032 = !{!6, !81, !3474}
!4033 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4034, file: !3912, line: 200)
!4034 = !DIDerivedType(tag: DW_TAG_typedef, name: "lldiv_t", file: !1430, line: 80, baseType: !4035)
!4035 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !1430, line: 76, size: 128, flags: DIFlagTypePassByValue, elements: !4036, identifier: "_ZTS7lldiv_t")
!4036 = !{!4037, !4038}
!4037 = !DIDerivedType(tag: DW_TAG_member, name: "quot", scope: !4035, file: !1430, line: 78, baseType: !3709, size: 64)
!4038 = !DIDerivedType(tag: DW_TAG_member, name: "rem", scope: !4035, file: !1430, line: 79, baseType: !3709, size: 64, offset: 64)
!4039 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4040, file: !3912, line: 206)
!4040 = !DISubprogram(name: "_Exit", scope: !1430, file: !1430, line: 629, type: !3964, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: DISPFlagOptimized)
!4041 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4042, file: !3912, line: 210)
!4042 = !DISubprogram(name: "llabs", scope: !1430, file: !1430, line: 844, type: !4043, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4043 = !DISubroutineType(types: !4044)
!4044 = !{!3709, !3709}
!4045 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4046, file: !3912, line: 216)
!4046 = !DISubprogram(name: "lldiv", scope: !1430, file: !1430, line: 858, type: !4047, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4047 = !DISubroutineType(types: !4048)
!4048 = !{!4034, !3709, !3709}
!4049 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4050, file: !3912, line: 227)
!4050 = !DISubprogram(name: "atoll", scope: !1430, file: !1430, line: 373, type: !4051, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4051 = !DISubroutineType(types: !4052)
!4052 = !{!3709, !74}
!4053 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4054, file: !3912, line: 228)
!4054 = !DISubprogram(name: "strtoll", scope: !1430, file: !1430, line: 200, type: !4055, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4055 = !DISubroutineType(types: !4056)
!4056 = !{!3709, !3508, !4014, !6}
!4057 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4058, file: !3912, line: 229)
!4058 = !DISubprogram(name: "strtoull", scope: !1430, file: !1430, line: 205, type: !4059, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4059 = !DISubroutineType(types: !4060)
!4060 = !{!3714, !3508, !4014, !6}
!4061 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4062, file: !3912, line: 231)
!4062 = !DISubprogram(name: "strtof", scope: !1430, file: !1430, line: 123, type: !4063, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4063 = !DISubroutineType(types: !4064)
!4064 = !{!69, !3508, !4014}
!4065 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4066, file: !3912, line: 232)
!4066 = !DISubprogram(name: "strtold", scope: !1430, file: !1430, line: 126, type: !4067, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4067 = !DISubroutineType(types: !4068)
!4068 = !{!3704, !3508, !4014}
!4069 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4034, file: !3912, line: 240)
!4070 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4040, file: !3912, line: 242)
!4071 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4042, file: !3912, line: 244)
!4072 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4073, file: !3912, line: 245)
!4073 = !DISubprogram(name: "div", linkageName: "_ZN9__gnu_cxx3divExx", scope: !576, file: !3912, line: 213, type: !4047, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4074 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4046, file: !3912, line: 246)
!4075 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4050, file: !3912, line: 248)
!4076 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4062, file: !3912, line: 249)
!4077 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4054, file: !3912, line: 250)
!4078 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4058, file: !3912, line: 251)
!4079 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4066, file: !3912, line: 252)
!4080 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4081, file: !4083, line: 98)
!4081 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !4082, line: 7, baseType: !3418)
!4082 = !DIFile(filename: "/usr/include/bits/types/FILE.h", directory: "")
!4083 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cstdio", directory: "")
!4084 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4085, file: !4083, line: 99)
!4085 = !DIDerivedType(tag: DW_TAG_typedef, name: "fpos_t", file: !78, line: 84, baseType: !4086)
!4086 = !DIDerivedType(tag: DW_TAG_typedef, name: "__fpos_t", file: !4087, line: 14, baseType: !4088)
!4087 = !DIFile(filename: "/usr/include/bits/types/__fpos_t.h", directory: "")
!4088 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_G_fpos_t", file: !4087, line: 10, flags: DIFlagFwdDecl, identifier: "_ZTS9_G_fpos_t")
!4089 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4090, file: !4083, line: 101)
!4090 = !DISubprogram(name: "clearerr", scope: !78, file: !78, line: 757, type: !4091, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4091 = !DISubroutineType(types: !4092)
!4092 = !{null, !4093}
!4093 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4081, size: 64)
!4094 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4095, file: !4083, line: 102)
!4095 = !DISubprogram(name: "fclose", scope: !78, file: !78, line: 213, type: !4096, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4096 = !DISubroutineType(types: !4097)
!4097 = !{!6, !4093}
!4098 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4099, file: !4083, line: 103)
!4099 = !DISubprogram(name: "feof", scope: !78, file: !78, line: 759, type: !4096, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4100 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4101, file: !4083, line: 104)
!4101 = !DISubprogram(name: "ferror", scope: !78, file: !78, line: 761, type: !4096, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4102 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4103, file: !4083, line: 105)
!4103 = !DISubprogram(name: "fflush", scope: !78, file: !78, line: 218, type: !4096, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4104 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4105, file: !4083, line: 106)
!4105 = !DISubprogram(name: "fgetc", scope: !78, file: !78, line: 485, type: !4096, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4106 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4107, file: !4083, line: 107)
!4107 = !DISubprogram(name: "fgetpos", scope: !78, file: !78, line: 731, type: !4108, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4108 = !DISubroutineType(types: !4109)
!4109 = !{!6, !4110, !4111}
!4110 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !4093)
!4111 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !4112)
!4112 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4085, size: 64)
!4113 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4114, file: !4083, line: 108)
!4114 = !DISubprogram(name: "fgets", scope: !78, file: !78, line: 564, type: !4115, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4115 = !DISubroutineType(types: !4116)
!4116 = !{!81, !3576, !6, !4110}
!4117 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4118, file: !4083, line: 109)
!4118 = !DISubprogram(name: "fopen", scope: !78, file: !78, line: 246, type: !4119, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4119 = !DISubroutineType(types: !4120)
!4120 = !{!4093, !3508, !3508}
!4121 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4122, file: !4083, line: 110)
!4122 = !DISubprogram(name: "fprintf", scope: !78, file: !78, line: 326, type: !4123, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4123 = !DISubroutineType(types: !4124)
!4124 = !{!6, !4110, !3508, null}
!4125 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4126, file: !4083, line: 111)
!4126 = !DISubprogram(name: "fputc", scope: !78, file: !78, line: 521, type: !4127, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4127 = !DISubroutineType(types: !4128)
!4128 = !{!6, !6, !4093}
!4129 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4130, file: !4083, line: 112)
!4130 = !DISubprogram(name: "fputs", scope: !78, file: !78, line: 626, type: !4131, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4131 = !DISubroutineType(types: !4132)
!4132 = !{!6, !3508, !4110}
!4133 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4134, file: !4083, line: 113)
!4134 = !DISubprogram(name: "fread", scope: !78, file: !78, line: 646, type: !4135, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4135 = !DISubroutineType(types: !4136)
!4136 = !{!779, !4137, !779, !779, !4110}
!4137 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !68)
!4138 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4139, file: !4083, line: 114)
!4139 = !DISubprogram(name: "freopen", scope: !78, file: !78, line: 252, type: !4140, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4140 = !DISubroutineType(types: !4141)
!4141 = !{!4093, !3508, !3508, !4110}
!4142 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4143, file: !4083, line: 115)
!4143 = !DISubprogram(name: "fscanf", linkageName: "__isoc99_fscanf", scope: !78, file: !78, line: 407, type: !4123, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4144 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4145, file: !4083, line: 116)
!4145 = !DISubprogram(name: "fseek", scope: !78, file: !78, line: 684, type: !4146, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4146 = !DISubroutineType(types: !4147)
!4147 = !{!6, !4093, !52, !6}
!4148 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4149, file: !4083, line: 117)
!4149 = !DISubprogram(name: "fsetpos", scope: !78, file: !78, line: 736, type: !4150, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4150 = !DISubroutineType(types: !4151)
!4151 = !{!6, !4093, !4152}
!4152 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4153, size: 64)
!4153 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4085)
!4154 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4155, file: !4083, line: 118)
!4155 = !DISubprogram(name: "ftell", scope: !78, file: !78, line: 689, type: !4156, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4156 = !DISubroutineType(types: !4157)
!4157 = !{!52, !4093}
!4158 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4159, file: !4083, line: 119)
!4159 = !DISubprogram(name: "fwrite", scope: !78, file: !78, line: 652, type: !4160, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4160 = !DISubroutineType(types: !4161)
!4161 = !{!779, !4162, !779, !779, !4110}
!4162 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !597)
!4163 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4164, file: !4083, line: 120)
!4164 = !DISubprogram(name: "getc", scope: !78, file: !78, line: 486, type: !4096, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4165 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4166, file: !4083, line: 121)
!4166 = !DISubprogram(name: "getchar", scope: !4167, file: !4167, line: 47, type: !172, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4167 = !DIFile(filename: "/usr/include/bits/stdio.h", directory: "")
!4168 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4169, file: !4083, line: 126)
!4169 = !DISubprogram(name: "perror", scope: !78, file: !78, line: 775, type: !79, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4170 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4171, file: !4083, line: 127)
!4171 = !DISubprogram(name: "printf", scope: !78, file: !78, line: 332, type: !4172, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4172 = !DISubroutineType(types: !4173)
!4173 = !{!6, !3508, null}
!4174 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4175, file: !4083, line: 128)
!4175 = !DISubprogram(name: "putc", scope: !78, file: !78, line: 522, type: !4127, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4176 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4177, file: !4083, line: 129)
!4177 = !DISubprogram(name: "putchar", scope: !4167, file: !4167, line: 82, type: !89, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4178 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4179, file: !4083, line: 130)
!4179 = !DISubprogram(name: "puts", scope: !78, file: !78, line: 632, type: !3937, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4180 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4181, file: !4083, line: 131)
!4181 = !DISubprogram(name: "remove", scope: !78, file: !78, line: 146, type: !3937, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4182 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4183, file: !4083, line: 132)
!4183 = !DISubprogram(name: "rename", scope: !78, file: !78, line: 148, type: !4184, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4184 = !DISubroutineType(types: !4185)
!4185 = !{!6, !74, !74}
!4186 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4187, file: !4083, line: 133)
!4187 = !DISubprogram(name: "rewind", scope: !78, file: !78, line: 694, type: !4091, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4188 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4189, file: !4083, line: 134)
!4189 = !DISubprogram(name: "scanf", linkageName: "__isoc99_scanf", scope: !78, file: !78, line: 410, type: !4172, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4190 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4191, file: !4083, line: 135)
!4191 = !DISubprogram(name: "setbuf", scope: !78, file: !78, line: 304, type: !4192, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4192 = !DISubroutineType(types: !4193)
!4193 = !{null, !4110, !3576}
!4194 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4195, file: !4083, line: 136)
!4195 = !DISubprogram(name: "setvbuf", scope: !78, file: !78, line: 308, type: !4196, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4196 = !DISubroutineType(types: !4197)
!4197 = !{!6, !4110, !3576, !6, !779}
!4198 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4199, file: !4083, line: 137)
!4199 = !DISubprogram(name: "sprintf", scope: !78, file: !78, line: 334, type: !4200, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4200 = !DISubroutineType(types: !4201)
!4201 = !{!6, !3576, !3508, null}
!4202 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4203, file: !4083, line: 138)
!4203 = !DISubprogram(name: "sscanf", linkageName: "__isoc99_sscanf", scope: !78, file: !78, line: 412, type: !4204, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4204 = !DISubroutineType(types: !4205)
!4205 = !{!6, !3508, !3508, null}
!4206 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4207, file: !4083, line: 139)
!4207 = !DISubprogram(name: "tmpfile", scope: !78, file: !78, line: 173, type: !4208, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4208 = !DISubroutineType(types: !4209)
!4209 = !{!4093}
!4210 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4211, file: !4083, line: 141)
!4211 = !DISubprogram(name: "tmpnam", scope: !78, file: !78, line: 187, type: !4212, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4212 = !DISubroutineType(types: !4213)
!4213 = !{!81, !81}
!4214 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4215, file: !4083, line: 143)
!4215 = !DISubprogram(name: "ungetc", scope: !78, file: !78, line: 639, type: !4127, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4216 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4217, file: !4083, line: 144)
!4217 = !DISubprogram(name: "vfprintf", scope: !78, file: !78, line: 341, type: !4218, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4218 = !DISubroutineType(types: !4219)
!4219 = !{!6, !4110, !3508, !3549}
!4220 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4221, file: !4083, line: 145)
!4221 = !DISubprogram(name: "vprintf", scope: !4167, file: !4167, line: 39, type: !4222, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4222 = !DISubroutineType(types: !4223)
!4223 = !{!6, !3508, !3549}
!4224 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4225, file: !4083, line: 146)
!4225 = !DISubprogram(name: "vsprintf", scope: !78, file: !78, line: 349, type: !4226, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4226 = !DISubroutineType(types: !4227)
!4227 = !{!6, !3576, !3508, !3549}
!4228 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4229, file: !4083, line: 175)
!4229 = !DISubprogram(name: "snprintf", scope: !78, file: !78, line: 354, type: !4230, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4230 = !DISubroutineType(types: !4231)
!4231 = !{!6, !3576, !779, !3508, null}
!4232 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4233, file: !4083, line: 176)
!4233 = !DISubprogram(name: "vfscanf", linkageName: "__isoc99_vfscanf", scope: !78, file: !78, line: 451, type: !4218, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4234 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4235, file: !4083, line: 177)
!4235 = !DISubprogram(name: "vscanf", linkageName: "__isoc99_vscanf", scope: !78, file: !78, line: 456, type: !4222, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4236 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4237, file: !4083, line: 178)
!4237 = !DISubprogram(name: "vsnprintf", scope: !78, file: !78, line: 358, type: !4238, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4238 = !DISubroutineType(types: !4239)
!4239 = !{!6, !3576, !779, !3508, !3549}
!4240 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !576, entity: !4241, file: !4083, line: 179)
!4241 = !DISubprogram(name: "vsscanf", linkageName: "__isoc99_vsscanf", scope: !78, file: !78, line: 459, type: !4242, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4242 = !DISubroutineType(types: !4243)
!4243 = !{!6, !3508, !3508, !3549}
!4244 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4229, file: !4083, line: 185)
!4245 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4233, file: !4083, line: 186)
!4246 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4235, file: !4083, line: 187)
!4247 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4237, file: !4083, line: 188)
!4248 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4241, file: !4083, line: 189)
!4249 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4250, file: !4254, line: 82)
!4250 = !DIDerivedType(tag: DW_TAG_typedef, name: "wctrans_t", file: !4251, line: 48, baseType: !4252)
!4251 = !DIFile(filename: "/usr/include/wctype.h", directory: "")
!4252 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4253, size: 64)
!4253 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3798)
!4254 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cwctype", directory: "")
!4255 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4256, file: !4254, line: 83)
!4256 = !DIDerivedType(tag: DW_TAG_typedef, name: "wctype_t", file: !4257, line: 38, baseType: !86)
!4257 = !DIFile(filename: "/usr/include/bits/wctype-wchar.h", directory: "")
!4258 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3404, file: !4254, line: 84)
!4259 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4260, file: !4254, line: 86)
!4260 = !DISubprogram(name: "iswalnum", scope: !4257, file: !4257, line: 95, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4261 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4262, file: !4254, line: 87)
!4262 = !DISubprogram(name: "iswalpha", scope: !4257, file: !4257, line: 101, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4263 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4264, file: !4254, line: 89)
!4264 = !DISubprogram(name: "iswblank", scope: !4257, file: !4257, line: 146, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4265 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4266, file: !4254, line: 91)
!4266 = !DISubprogram(name: "iswcntrl", scope: !4257, file: !4257, line: 104, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4267 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4268, file: !4254, line: 92)
!4268 = !DISubprogram(name: "iswctype", scope: !4257, file: !4257, line: 159, type: !4269, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4269 = !DISubroutineType(types: !4270)
!4270 = !{!6, !3404, !4256}
!4271 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4272, file: !4254, line: 93)
!4272 = !DISubprogram(name: "iswdigit", scope: !4257, file: !4257, line: 108, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4273 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4274, file: !4254, line: 94)
!4274 = !DISubprogram(name: "iswgraph", scope: !4257, file: !4257, line: 112, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4275 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4276, file: !4254, line: 95)
!4276 = !DISubprogram(name: "iswlower", scope: !4257, file: !4257, line: 117, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4277 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4278, file: !4254, line: 96)
!4278 = !DISubprogram(name: "iswprint", scope: !4257, file: !4257, line: 120, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4279 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4280, file: !4254, line: 97)
!4280 = !DISubprogram(name: "iswpunct", scope: !4257, file: !4257, line: 125, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4281 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4282, file: !4254, line: 98)
!4282 = !DISubprogram(name: "iswspace", scope: !4257, file: !4257, line: 130, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4283 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4284, file: !4254, line: 99)
!4284 = !DISubprogram(name: "iswupper", scope: !4257, file: !4257, line: 135, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4285 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4286, file: !4254, line: 100)
!4286 = !DISubprogram(name: "iswxdigit", scope: !4257, file: !4257, line: 140, type: !3664, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4287 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4288, file: !4254, line: 101)
!4288 = !DISubprogram(name: "towctrans", scope: !4251, file: !4251, line: 55, type: !4289, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4289 = !DISubroutineType(types: !4290)
!4290 = !{!3404, !3404, !4250}
!4291 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4292, file: !4254, line: 102)
!4292 = !DISubprogram(name: "towlower", scope: !4257, file: !4257, line: 166, type: !4293, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4293 = !DISubroutineType(types: !4294)
!4294 = !{!3404, !3404}
!4295 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4296, file: !4254, line: 103)
!4296 = !DISubprogram(name: "towupper", scope: !4257, file: !4257, line: 169, type: !4293, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4297 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4298, file: !4254, line: 104)
!4298 = !DISubprogram(name: "wctrans", scope: !4251, file: !4251, line: 52, type: !4299, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4299 = !DISubroutineType(types: !4300)
!4300 = !{!4250, !74}
!4301 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4302, file: !4254, line: 105)
!4302 = !DISubprogram(name: "wctype", scope: !4257, file: !4257, line: 155, type: !4303, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4303 = !DISubroutineType(types: !4304)
!4304 = !{!4256, !74}
!4305 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3920, file: !4306, line: 38)
!4306 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/stdlib.h", directory: "")
!4307 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3924, file: !4306, line: 39)
!4308 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3963, file: !4306, line: 40)
!4309 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3929, file: !4306, line: 43)
!4310 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3999, file: !4306, line: 46)
!4311 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3910, file: !4306, line: 51)
!4312 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3914, file: !4306, line: 52)
!4313 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4314, file: !4306, line: 54)
!4314 = !DISubprogram(name: "abs", linkageName: "_ZSt3abse", scope: !5, file: !3908, line: 79, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4315 = !DISubroutineType(types: !4316)
!4316 = !{!3704, !3704}
!4317 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3931, file: !4306, line: 55)
!4318 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3936, file: !4306, line: 56)
!4319 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3940, file: !4306, line: 57)
!4320 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3946, file: !4306, line: 58)
!4321 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3955, file: !4306, line: 59)
!4322 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4073, file: !4306, line: 60)
!4323 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3967, file: !4306, line: 61)
!4324 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3969, file: !4306, line: 62)
!4325 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3973, file: !4306, line: 63)
!4326 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3975, file: !4306, line: 64)
!4327 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3979, file: !4306, line: 65)
!4328 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3983, file: !4306, line: 67)
!4329 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3987, file: !4306, line: 68)
!4330 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3991, file: !4306, line: 69)
!4331 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !3995, file: !4306, line: 71)
!4332 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4001, file: !4306, line: 72)
!4333 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4003, file: !4306, line: 73)
!4334 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4007, file: !4306, line: 74)
!4335 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4011, file: !4306, line: 75)
!4336 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4016, file: !4306, line: 76)
!4337 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4020, file: !4306, line: 77)
!4338 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4024, file: !4306, line: 78)
!4339 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4026, file: !4306, line: 80)
!4340 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4030, file: !4306, line: 81)
!4341 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4342, file: !4346, line: 77)
!4342 = !DISubprogram(name: "memchr", scope: !4343, file: !4343, line: 84, type: !4344, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4343 = !DIFile(filename: "/usr/include/string.h", directory: "")
!4344 = !DISubroutineType(types: !4345)
!4345 = !{!597, !597, !6, !779}
!4346 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cstring", directory: "")
!4347 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4348, file: !4346, line: 78)
!4348 = !DISubprogram(name: "memcmp", scope: !4343, file: !4343, line: 64, type: !4349, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4349 = !DISubroutineType(types: !4350)
!4350 = !{!6, !597, !597, !779}
!4351 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4352, file: !4346, line: 79)
!4352 = !DISubprogram(name: "memcpy", scope: !4343, file: !4343, line: 43, type: !4353, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4353 = !DISubroutineType(types: !4354)
!4354 = !{!68, !4137, !4162, !779}
!4355 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4356, file: !4346, line: 80)
!4356 = !DISubprogram(name: "memmove", scope: !4343, file: !4343, line: 47, type: !4357, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4357 = !DISubroutineType(types: !4358)
!4358 = !{!68, !68, !597, !779}
!4359 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4360, file: !4346, line: 81)
!4360 = !DISubprogram(name: "memset", scope: !4343, file: !4343, line: 61, type: !4361, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4361 = !DISubroutineType(types: !4362)
!4362 = !{!68, !68, !6, !779}
!4363 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4364, file: !4346, line: 82)
!4364 = !DISubprogram(name: "strcat", scope: !4343, file: !4343, line: 130, type: !4365, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4365 = !DISubroutineType(types: !4366)
!4366 = !{!81, !3576, !3508}
!4367 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4368, file: !4346, line: 83)
!4368 = !DISubprogram(name: "strcmp", scope: !4343, file: !4343, line: 137, type: !4184, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4369 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4370, file: !4346, line: 84)
!4370 = !DISubprogram(name: "strcoll", scope: !4343, file: !4343, line: 144, type: !4184, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4371 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4372, file: !4346, line: 85)
!4372 = !DISubprogram(name: "strcpy", scope: !4343, file: !4343, line: 122, type: !4365, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4373 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4374, file: !4346, line: 86)
!4374 = !DISubprogram(name: "strcspn", scope: !4343, file: !4343, line: 273, type: !4375, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4375 = !DISubroutineType(types: !4376)
!4376 = !{!779, !74, !74}
!4377 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4378, file: !4346, line: 87)
!4378 = !DISubprogram(name: "strerror", scope: !4343, file: !4343, line: 397, type: !4379, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4379 = !DISubroutineType(types: !4380)
!4380 = !{!81, !6}
!4381 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4382, file: !4346, line: 88)
!4382 = !DISubprogram(name: "strlen", scope: !4343, file: !4343, line: 385, type: !4383, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4383 = !DISubroutineType(types: !4384)
!4384 = !{!779, !74}
!4385 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4386, file: !4346, line: 89)
!4386 = !DISubprogram(name: "strncat", scope: !4343, file: !4343, line: 133, type: !4387, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4387 = !DISubroutineType(types: !4388)
!4388 = !{!81, !3576, !3508, !779}
!4389 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4390, file: !4346, line: 90)
!4390 = !DISubprogram(name: "strncmp", scope: !4343, file: !4343, line: 140, type: !4391, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4391 = !DISubroutineType(types: !4392)
!4392 = !{!6, !74, !74, !779}
!4393 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4394, file: !4346, line: 91)
!4394 = !DISubprogram(name: "strncpy", scope: !4343, file: !4343, line: 125, type: !4387, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4395 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4396, file: !4346, line: 92)
!4396 = !DISubprogram(name: "strspn", scope: !4343, file: !4343, line: 277, type: !4375, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4397 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4398, file: !4346, line: 93)
!4398 = !DISubprogram(name: "strtok", scope: !4343, file: !4343, line: 336, type: !4365, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4399 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4400, file: !4346, line: 94)
!4400 = !DISubprogram(name: "strxfrm", scope: !4343, file: !4343, line: 147, type: !4401, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4401 = !DISubroutineType(types: !4402)
!4402 = !{!779, !3576, !3508, !779}
!4403 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4404, file: !4346, line: 95)
!4404 = !DISubprogram(name: "strchr", scope: !4343, file: !4343, line: 219, type: !4405, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4405 = !DISubroutineType(types: !4406)
!4406 = !{!74, !74, !6}
!4407 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4408, file: !4346, line: 96)
!4408 = !DISubprogram(name: "strpbrk", scope: !4343, file: !4343, line: 296, type: !4409, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4409 = !DISubroutineType(types: !4410)
!4410 = !{!74, !74, !74}
!4411 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4412, file: !4346, line: 97)
!4412 = !DISubprogram(name: "strrchr", scope: !4343, file: !4343, line: 246, type: !4405, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4413 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4414, file: !4346, line: 98)
!4414 = !DISubprogram(name: "strstr", scope: !4343, file: !4343, line: 323, type: !4409, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4415 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4416, file: !4419, line: 60)
!4416 = !DIDerivedType(tag: DW_TAG_typedef, name: "clock_t", file: !4417, line: 7, baseType: !4418)
!4417 = !DIFile(filename: "/usr/include/bits/types/clock_t.h", directory: "")
!4418 = !DIDerivedType(tag: DW_TAG_typedef, name: "__clock_t", file: !695, line: 156, baseType: !52)
!4419 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/ctime", directory: "")
!4420 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4421, file: !4419, line: 61)
!4421 = !DIDerivedType(tag: DW_TAG_typedef, name: "time_t", file: !4422, line: 7, baseType: !694)
!4422 = !DIFile(filename: "/usr/include/bits/types/time_t.h", directory: "")
!4423 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !3600, file: !4419, line: 62)
!4424 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4425, file: !4419, line: 64)
!4425 = !DISubprogram(name: "clock", scope: !4426, file: !4426, line: 72, type: !4427, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4426 = !DIFile(filename: "/usr/include/time.h", directory: "")
!4427 = !DISubroutineType(types: !4428)
!4428 = !{!4416}
!4429 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4430, file: !4419, line: 65)
!4430 = !DISubprogram(name: "difftime", scope: !4426, file: !4426, line: 78, type: !4431, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4431 = !DISubroutineType(types: !4432)
!4432 = !{!358, !4421, !4421}
!4433 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4434, file: !4419, line: 66)
!4434 = !DISubprogram(name: "mktime", scope: !4426, file: !4426, line: 82, type: !4435, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4435 = !DISubroutineType(types: !4436)
!4436 = !{!4421, !4437}
!4437 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3600, size: 64)
!4438 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4439, file: !4419, line: 67)
!4439 = !DISubprogram(name: "time", scope: !4426, file: !4426, line: 75, type: !4440, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4440 = !DISubroutineType(types: !4441)
!4441 = !{!4421, !4442}
!4442 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4421, size: 64)
!4443 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4444, file: !4419, line: 68)
!4444 = !DISubprogram(name: "asctime", scope: !4426, file: !4426, line: 139, type: !4445, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4445 = !DISubroutineType(types: !4446)
!4446 = !{!81, !3598}
!4447 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4448, file: !4419, line: 69)
!4448 = !DISubprogram(name: "ctime", scope: !4426, file: !4426, line: 142, type: !4449, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4449 = !DISubroutineType(types: !4450)
!4450 = !{!81, !4451}
!4451 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4452, size: 64)
!4452 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4421)
!4453 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4454, file: !4419, line: 70)
!4454 = !DISubprogram(name: "gmtime", scope: !4426, file: !4426, line: 119, type: !4455, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4455 = !DISubroutineType(types: !4456)
!4456 = !{!4437, !4451}
!4457 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4458, file: !4419, line: 71)
!4458 = !DISubprogram(name: "localtime", scope: !4426, file: !4426, line: 123, type: !4455, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4459 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4460, file: !4419, line: 72)
!4460 = !DISubprogram(name: "strftime", scope: !4426, file: !4426, line: 88, type: !4461, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4461 = !DISubroutineType(types: !4462)
!4462 = !{!779, !3576, !779, !3508, !3597}
!4463 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !54, line: 30)
!4464 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !4465, line: 5)
!4465 = !DIFile(filename: "./maybe.h", directory: "/data/compilers/tests/ligra/apps")
!4466 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !811, entity: !5, file: !1271, line: 31)
!4467 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !772, line: 10)
!4468 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !433, line: 4)
!4469 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4470, file: !4474, line: 83)
!4470 = !DISubprogram(name: "acos", scope: !4471, file: !4471, line: 53, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4471 = !DIFile(filename: "/usr/include/bits/mathcalls.h", directory: "")
!4472 = !DISubroutineType(types: !4473)
!4473 = !{!358, !358}
!4474 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cmath", directory: "")
!4475 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4476, file: !4474, line: 102)
!4476 = !DISubprogram(name: "asin", scope: !4471, file: !4471, line: 55, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4477 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4478, file: !4474, line: 121)
!4478 = !DISubprogram(name: "atan", scope: !4471, file: !4471, line: 57, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4479 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4480, file: !4474, line: 140)
!4480 = !DISubprogram(name: "atan2", scope: !4471, file: !4471, line: 59, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4481 = !DISubroutineType(types: !4482)
!4482 = !{!358, !358, !358}
!4483 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4484, file: !4474, line: 161)
!4484 = !DISubprogram(name: "ceil", scope: !4471, file: !4471, line: 159, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4485 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4486, file: !4474, line: 180)
!4486 = !DISubprogram(name: "cos", scope: !4471, file: !4471, line: 62, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4487 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4488, file: !4474, line: 199)
!4488 = !DISubprogram(name: "cosh", scope: !4471, file: !4471, line: 71, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4489 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4490, file: !4474, line: 218)
!4490 = !DISubprogram(name: "exp", scope: !4471, file: !4471, line: 95, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4491 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4492, file: !4474, line: 237)
!4492 = !DISubprogram(name: "fabs", scope: !4471, file: !4471, line: 162, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4493 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4494, file: !4474, line: 256)
!4494 = !DISubprogram(name: "floor", scope: !4471, file: !4471, line: 165, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4495 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4496, file: !4474, line: 275)
!4496 = !DISubprogram(name: "fmod", scope: !4471, file: !4471, line: 168, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4497 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4498, file: !4474, line: 296)
!4498 = !DISubprogram(name: "frexp", scope: !4471, file: !4471, line: 98, type: !4499, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4499 = !DISubroutineType(types: !4500)
!4500 = !{!358, !358, !749}
!4501 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4502, file: !4474, line: 315)
!4502 = !DISubprogram(name: "ldexp", scope: !4471, file: !4471, line: 101, type: !4503, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4503 = !DISubroutineType(types: !4504)
!4504 = !{!358, !358, !6}
!4505 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4506, file: !4474, line: 334)
!4506 = !DISubprogram(name: "log", scope: !4471, file: !4471, line: 104, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4507 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4508, file: !4474, line: 353)
!4508 = !DISubprogram(name: "log10", scope: !4471, file: !4471, line: 107, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4509 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4510, file: !4474, line: 372)
!4510 = !DISubprogram(name: "modf", scope: !4471, file: !4471, line: 110, type: !4511, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4511 = !DISubroutineType(types: !4512)
!4512 = !{!358, !358, !4513}
!4513 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !358, size: 64)
!4514 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4515, file: !4474, line: 384)
!4515 = !DISubprogram(name: "pow", scope: !4471, file: !4471, line: 140, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4516 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4517, file: !4474, line: 421)
!4517 = !DISubprogram(name: "sin", scope: !4471, file: !4471, line: 64, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4518 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4519, file: !4474, line: 440)
!4519 = !DISubprogram(name: "sinh", scope: !4471, file: !4471, line: 73, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4520 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4521, file: !4474, line: 459)
!4521 = !DISubprogram(name: "sqrt", scope: !4471, file: !4471, line: 143, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4522 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4523, file: !4474, line: 478)
!4523 = !DISubprogram(name: "tan", scope: !4471, file: !4471, line: 66, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4524 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4525, file: !4474, line: 497)
!4525 = !DISubprogram(name: "tanh", scope: !4471, file: !4471, line: 75, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4526 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4527, file: !4474, line: 1065)
!4527 = !DIDerivedType(tag: DW_TAG_typedef, name: "double_t", file: !4528, line: 150, baseType: !358)
!4528 = !DIFile(filename: "/usr/include/math.h", directory: "")
!4529 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4530, file: !4474, line: 1066)
!4530 = !DIDerivedType(tag: DW_TAG_typedef, name: "float_t", file: !4528, line: 149, baseType: !69)
!4531 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4532, file: !4474, line: 1069)
!4532 = !DISubprogram(name: "acosh", scope: !4471, file: !4471, line: 85, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4533 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4534, file: !4474, line: 1070)
!4534 = !DISubprogram(name: "acoshf", scope: !4471, file: !4471, line: 85, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4535 = !DISubroutineType(types: !4536)
!4536 = !{!69, !69}
!4537 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4538, file: !4474, line: 1071)
!4538 = !DISubprogram(name: "acoshl", scope: !4471, file: !4471, line: 85, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4539 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4540, file: !4474, line: 1073)
!4540 = !DISubprogram(name: "asinh", scope: !4471, file: !4471, line: 87, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4541 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4542, file: !4474, line: 1074)
!4542 = !DISubprogram(name: "asinhf", scope: !4471, file: !4471, line: 87, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4543 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4544, file: !4474, line: 1075)
!4544 = !DISubprogram(name: "asinhl", scope: !4471, file: !4471, line: 87, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4545 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4546, file: !4474, line: 1077)
!4546 = !DISubprogram(name: "atanh", scope: !4471, file: !4471, line: 89, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4547 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4548, file: !4474, line: 1078)
!4548 = !DISubprogram(name: "atanhf", scope: !4471, file: !4471, line: 89, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4549 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4550, file: !4474, line: 1079)
!4550 = !DISubprogram(name: "atanhl", scope: !4471, file: !4471, line: 89, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4551 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4552, file: !4474, line: 1081)
!4552 = !DISubprogram(name: "cbrt", scope: !4471, file: !4471, line: 152, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4553 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4554, file: !4474, line: 1082)
!4554 = !DISubprogram(name: "cbrtf", scope: !4471, file: !4471, line: 152, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4555 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4556, file: !4474, line: 1083)
!4556 = !DISubprogram(name: "cbrtl", scope: !4471, file: !4471, line: 152, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4557 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4558, file: !4474, line: 1085)
!4558 = !DISubprogram(name: "copysign", scope: !4471, file: !4471, line: 196, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4559 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4560, file: !4474, line: 1086)
!4560 = !DISubprogram(name: "copysignf", scope: !4471, file: !4471, line: 196, type: !4561, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4561 = !DISubroutineType(types: !4562)
!4562 = !{!69, !69, !69}
!4563 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4564, file: !4474, line: 1087)
!4564 = !DISubprogram(name: "copysignl", scope: !4471, file: !4471, line: 196, type: !4565, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4565 = !DISubroutineType(types: !4566)
!4566 = !{!3704, !3704, !3704}
!4567 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4568, file: !4474, line: 1089)
!4568 = !DISubprogram(name: "erf", scope: !4471, file: !4471, line: 228, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4569 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4570, file: !4474, line: 1090)
!4570 = !DISubprogram(name: "erff", scope: !4471, file: !4471, line: 228, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4571 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4572, file: !4474, line: 1091)
!4572 = !DISubprogram(name: "erfl", scope: !4471, file: !4471, line: 228, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4573 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4574, file: !4474, line: 1093)
!4574 = !DISubprogram(name: "erfc", scope: !4471, file: !4471, line: 229, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4575 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4576, file: !4474, line: 1094)
!4576 = !DISubprogram(name: "erfcf", scope: !4471, file: !4471, line: 229, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4577 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4578, file: !4474, line: 1095)
!4578 = !DISubprogram(name: "erfcl", scope: !4471, file: !4471, line: 229, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4579 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4580, file: !4474, line: 1097)
!4580 = !DISubprogram(name: "exp2", scope: !4471, file: !4471, line: 130, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4581 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4582, file: !4474, line: 1098)
!4582 = !DISubprogram(name: "exp2f", scope: !4471, file: !4471, line: 130, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4583 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4584, file: !4474, line: 1099)
!4584 = !DISubprogram(name: "exp2l", scope: !4471, file: !4471, line: 130, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4585 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4586, file: !4474, line: 1101)
!4586 = !DISubprogram(name: "expm1", scope: !4471, file: !4471, line: 119, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4587 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4588, file: !4474, line: 1102)
!4588 = !DISubprogram(name: "expm1f", scope: !4471, file: !4471, line: 119, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4589 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4590, file: !4474, line: 1103)
!4590 = !DISubprogram(name: "expm1l", scope: !4471, file: !4471, line: 119, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4591 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4592, file: !4474, line: 1105)
!4592 = !DISubprogram(name: "fdim", scope: !4471, file: !4471, line: 326, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4593 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4594, file: !4474, line: 1106)
!4594 = !DISubprogram(name: "fdimf", scope: !4471, file: !4471, line: 326, type: !4561, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4595 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4596, file: !4474, line: 1107)
!4596 = !DISubprogram(name: "fdiml", scope: !4471, file: !4471, line: 326, type: !4565, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4597 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4598, file: !4474, line: 1109)
!4598 = !DISubprogram(name: "fma", scope: !4471, file: !4471, line: 335, type: !4599, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4599 = !DISubroutineType(types: !4600)
!4600 = !{!358, !358, !358, !358}
!4601 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4602, file: !4474, line: 1110)
!4602 = !DISubprogram(name: "fmaf", scope: !4471, file: !4471, line: 335, type: !4603, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4603 = !DISubroutineType(types: !4604)
!4604 = !{!69, !69, !69, !69}
!4605 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4606, file: !4474, line: 1111)
!4606 = !DISubprogram(name: "fmal", scope: !4471, file: !4471, line: 335, type: !4607, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4607 = !DISubroutineType(types: !4608)
!4608 = !{!3704, !3704, !3704, !3704}
!4609 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4610, file: !4474, line: 1113)
!4610 = !DISubprogram(name: "fmax", scope: !4471, file: !4471, line: 329, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4611 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4612, file: !4474, line: 1114)
!4612 = !DISubprogram(name: "fmaxf", scope: !4471, file: !4471, line: 329, type: !4561, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4613 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4614, file: !4474, line: 1115)
!4614 = !DISubprogram(name: "fmaxl", scope: !4471, file: !4471, line: 329, type: !4565, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4615 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4616, file: !4474, line: 1117)
!4616 = !DISubprogram(name: "fmin", scope: !4471, file: !4471, line: 332, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4617 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4618, file: !4474, line: 1118)
!4618 = !DISubprogram(name: "fminf", scope: !4471, file: !4471, line: 332, type: !4561, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4619 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4620, file: !4474, line: 1119)
!4620 = !DISubprogram(name: "fminl", scope: !4471, file: !4471, line: 332, type: !4565, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4621 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4622, file: !4474, line: 1121)
!4622 = !DISubprogram(name: "hypot", scope: !4471, file: !4471, line: 147, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4623 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4624, file: !4474, line: 1122)
!4624 = !DISubprogram(name: "hypotf", scope: !4471, file: !4471, line: 147, type: !4561, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4625 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4626, file: !4474, line: 1123)
!4626 = !DISubprogram(name: "hypotl", scope: !4471, file: !4471, line: 147, type: !4565, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4627 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4628, file: !4474, line: 1125)
!4628 = !DISubprogram(name: "ilogb", scope: !4471, file: !4471, line: 280, type: !4629, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4629 = !DISubroutineType(types: !4630)
!4630 = !{!6, !358}
!4631 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4632, file: !4474, line: 1126)
!4632 = !DISubprogram(name: "ilogbf", scope: !4471, file: !4471, line: 280, type: !4633, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4633 = !DISubroutineType(types: !4634)
!4634 = !{!6, !69}
!4635 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4636, file: !4474, line: 1127)
!4636 = !DISubprogram(name: "ilogbl", scope: !4471, file: !4471, line: 280, type: !4637, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4637 = !DISubroutineType(types: !4638)
!4638 = !{!6, !3704}
!4639 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4640, file: !4474, line: 1129)
!4640 = !DISubprogram(name: "lgamma", scope: !4471, file: !4471, line: 230, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4641 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4642, file: !4474, line: 1130)
!4642 = !DISubprogram(name: "lgammaf", scope: !4471, file: !4471, line: 230, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4643 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4644, file: !4474, line: 1131)
!4644 = !DISubprogram(name: "lgammal", scope: !4471, file: !4471, line: 230, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4645 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4646, file: !4474, line: 1134)
!4646 = !DISubprogram(name: "llrint", scope: !4471, file: !4471, line: 316, type: !4647, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4647 = !DISubroutineType(types: !4648)
!4648 = !{!3709, !358}
!4649 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4650, file: !4474, line: 1135)
!4650 = !DISubprogram(name: "llrintf", scope: !4471, file: !4471, line: 316, type: !4651, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4651 = !DISubroutineType(types: !4652)
!4652 = !{!3709, !69}
!4653 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4654, file: !4474, line: 1136)
!4654 = !DISubprogram(name: "llrintl", scope: !4471, file: !4471, line: 316, type: !4655, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4655 = !DISubroutineType(types: !4656)
!4656 = !{!3709, !3704}
!4657 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4658, file: !4474, line: 1138)
!4658 = !DISubprogram(name: "llround", scope: !4471, file: !4471, line: 322, type: !4647, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4659 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4660, file: !4474, line: 1139)
!4660 = !DISubprogram(name: "llroundf", scope: !4471, file: !4471, line: 322, type: !4651, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4661 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4662, file: !4474, line: 1140)
!4662 = !DISubprogram(name: "llroundl", scope: !4471, file: !4471, line: 322, type: !4655, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4663 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4664, file: !4474, line: 1143)
!4664 = !DISubprogram(name: "log1p", scope: !4471, file: !4471, line: 122, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4665 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4666, file: !4474, line: 1144)
!4666 = !DISubprogram(name: "log1pf", scope: !4471, file: !4471, line: 122, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4667 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4668, file: !4474, line: 1145)
!4668 = !DISubprogram(name: "log1pl", scope: !4471, file: !4471, line: 122, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4669 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4670, file: !4474, line: 1147)
!4670 = !DISubprogram(name: "log2", scope: !4471, file: !4471, line: 133, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4671 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4672, file: !4474, line: 1148)
!4672 = !DISubprogram(name: "log2f", scope: !4471, file: !4471, line: 133, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4673 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4674, file: !4474, line: 1149)
!4674 = !DISubprogram(name: "log2l", scope: !4471, file: !4471, line: 133, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4675 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4676, file: !4474, line: 1151)
!4676 = !DISubprogram(name: "logb", scope: !4471, file: !4471, line: 125, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4677 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4678, file: !4474, line: 1152)
!4678 = !DISubprogram(name: "logbf", scope: !4471, file: !4471, line: 125, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4679 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4680, file: !4474, line: 1153)
!4680 = !DISubprogram(name: "logbl", scope: !4471, file: !4471, line: 125, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4681 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4682, file: !4474, line: 1155)
!4682 = !DISubprogram(name: "lrint", scope: !4471, file: !4471, line: 314, type: !4683, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4683 = !DISubroutineType(types: !4684)
!4684 = !{!52, !358}
!4685 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4686, file: !4474, line: 1156)
!4686 = !DISubprogram(name: "lrintf", scope: !4471, file: !4471, line: 314, type: !4687, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4687 = !DISubroutineType(types: !4688)
!4688 = !{!52, !69}
!4689 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4690, file: !4474, line: 1157)
!4690 = !DISubprogram(name: "lrintl", scope: !4471, file: !4471, line: 314, type: !4691, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4691 = !DISubroutineType(types: !4692)
!4692 = !{!52, !3704}
!4693 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4694, file: !4474, line: 1159)
!4694 = !DISubprogram(name: "lround", scope: !4471, file: !4471, line: 320, type: !4683, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4695 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4696, file: !4474, line: 1160)
!4696 = !DISubprogram(name: "lroundf", scope: !4471, file: !4471, line: 320, type: !4687, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4697 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4698, file: !4474, line: 1161)
!4698 = !DISubprogram(name: "lroundl", scope: !4471, file: !4471, line: 320, type: !4691, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4699 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4700, file: !4474, line: 1163)
!4700 = !DISubprogram(name: "nan", scope: !4471, file: !4471, line: 201, type: !3933, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4701 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4702, file: !4474, line: 1164)
!4702 = !DISubprogram(name: "nanf", scope: !4471, file: !4471, line: 201, type: !4703, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4703 = !DISubroutineType(types: !4704)
!4704 = !{!69, !74}
!4705 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4706, file: !4474, line: 1165)
!4706 = !DISubprogram(name: "nanl", scope: !4471, file: !4471, line: 201, type: !4707, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4707 = !DISubroutineType(types: !4708)
!4708 = !{!3704, !74}
!4709 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4710, file: !4474, line: 1167)
!4710 = !DISubprogram(name: "nearbyint", scope: !4471, file: !4471, line: 294, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4711 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4712, file: !4474, line: 1168)
!4712 = !DISubprogram(name: "nearbyintf", scope: !4471, file: !4471, line: 294, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4713 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4714, file: !4474, line: 1169)
!4714 = !DISubprogram(name: "nearbyintl", scope: !4471, file: !4471, line: 294, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4715 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4716, file: !4474, line: 1171)
!4716 = !DISubprogram(name: "nextafter", scope: !4471, file: !4471, line: 259, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4717 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4718, file: !4474, line: 1172)
!4718 = !DISubprogram(name: "nextafterf", scope: !4471, file: !4471, line: 259, type: !4561, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4719 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4720, file: !4474, line: 1173)
!4720 = !DISubprogram(name: "nextafterl", scope: !4471, file: !4471, line: 259, type: !4565, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4721 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4722, file: !4474, line: 1175)
!4722 = !DISubprogram(name: "nexttoward", scope: !4471, file: !4471, line: 261, type: !4723, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4723 = !DISubroutineType(types: !4724)
!4724 = !{!358, !358, !3704}
!4725 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4726, file: !4474, line: 1176)
!4726 = !DISubprogram(name: "nexttowardf", scope: !4471, file: !4471, line: 261, type: !4727, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4727 = !DISubroutineType(types: !4728)
!4728 = !{!69, !69, !3704}
!4729 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4730, file: !4474, line: 1177)
!4730 = !DISubprogram(name: "nexttowardl", scope: !4471, file: !4471, line: 261, type: !4565, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4731 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4732, file: !4474, line: 1179)
!4732 = !DISubprogram(name: "remainder", scope: !4471, file: !4471, line: 272, type: !4481, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4733 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4734, file: !4474, line: 1180)
!4734 = !DISubprogram(name: "remainderf", scope: !4471, file: !4471, line: 272, type: !4561, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4735 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4736, file: !4474, line: 1181)
!4736 = !DISubprogram(name: "remainderl", scope: !4471, file: !4471, line: 272, type: !4565, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4737 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4738, file: !4474, line: 1183)
!4738 = !DISubprogram(name: "remquo", scope: !4471, file: !4471, line: 307, type: !4739, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4739 = !DISubroutineType(types: !4740)
!4740 = !{!358, !358, !358, !749}
!4741 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4742, file: !4474, line: 1184)
!4742 = !DISubprogram(name: "remquof", scope: !4471, file: !4471, line: 307, type: !4743, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4743 = !DISubroutineType(types: !4744)
!4744 = !{!69, !69, !69, !749}
!4745 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4746, file: !4474, line: 1185)
!4746 = !DISubprogram(name: "remquol", scope: !4471, file: !4471, line: 307, type: !4747, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4747 = !DISubroutineType(types: !4748)
!4748 = !{!3704, !3704, !3704, !749}
!4749 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4750, file: !4474, line: 1187)
!4750 = !DISubprogram(name: "rint", scope: !4471, file: !4471, line: 256, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4751 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4752, file: !4474, line: 1188)
!4752 = !DISubprogram(name: "rintf", scope: !4471, file: !4471, line: 256, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4753 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4754, file: !4474, line: 1189)
!4754 = !DISubprogram(name: "rintl", scope: !4471, file: !4471, line: 256, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4755 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4756, file: !4474, line: 1191)
!4756 = !DISubprogram(name: "round", scope: !4471, file: !4471, line: 298, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4757 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4758, file: !4474, line: 1192)
!4758 = !DISubprogram(name: "roundf", scope: !4471, file: !4471, line: 298, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4759 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4760, file: !4474, line: 1193)
!4760 = !DISubprogram(name: "roundl", scope: !4471, file: !4471, line: 298, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4761 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4762, file: !4474, line: 1195)
!4762 = !DISubprogram(name: "scalbln", scope: !4471, file: !4471, line: 290, type: !4763, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4763 = !DISubroutineType(types: !4764)
!4764 = !{!358, !358, !52}
!4765 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4766, file: !4474, line: 1196)
!4766 = !DISubprogram(name: "scalblnf", scope: !4471, file: !4471, line: 290, type: !4767, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4767 = !DISubroutineType(types: !4768)
!4768 = !{!69, !69, !52}
!4769 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4770, file: !4474, line: 1197)
!4770 = !DISubprogram(name: "scalblnl", scope: !4471, file: !4471, line: 290, type: !4771, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4771 = !DISubroutineType(types: !4772)
!4772 = !{!3704, !3704, !52}
!4773 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4774, file: !4474, line: 1199)
!4774 = !DISubprogram(name: "scalbn", scope: !4471, file: !4471, line: 276, type: !4503, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4775 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4776, file: !4474, line: 1200)
!4776 = !DISubprogram(name: "scalbnf", scope: !4471, file: !4471, line: 276, type: !4777, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4777 = !DISubroutineType(types: !4778)
!4778 = !{!69, !69, !6}
!4779 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4780, file: !4474, line: 1201)
!4780 = !DISubprogram(name: "scalbnl", scope: !4471, file: !4471, line: 276, type: !4781, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4781 = !DISubroutineType(types: !4782)
!4782 = !{!3704, !3704, !6}
!4783 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4784, file: !4474, line: 1203)
!4784 = !DISubprogram(name: "tgamma", scope: !4471, file: !4471, line: 235, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4785 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4786, file: !4474, line: 1204)
!4786 = !DISubprogram(name: "tgammaf", scope: !4471, file: !4471, line: 235, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4787 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4788, file: !4474, line: 1205)
!4788 = !DISubprogram(name: "tgammal", scope: !4471, file: !4471, line: 235, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4789 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4790, file: !4474, line: 1207)
!4790 = !DISubprogram(name: "trunc", scope: !4471, file: !4471, line: 302, type: !4472, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4791 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4792, file: !4474, line: 1208)
!4792 = !DISubprogram(name: "truncf", scope: !4471, file: !4471, line: 302, type: !4535, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4793 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4794, file: !4474, line: 1209)
!4794 = !DISubprogram(name: "truncl", scope: !4471, file: !4471, line: 302, type: !4315, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4795 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !117, line: 9)
!4796 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4314, file: !4797, line: 38)
!4797 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/math.h", directory: "")
!4798 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !0, entity: !4799, file: !4797, line: 54)
!4799 = !DISubprogram(name: "modf", linkageName: "_ZSt4modfePe", scope: !5, file: !4474, line: 380, type: !4800, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!4800 = !DISubroutineType(types: !4801)
!4801 = !{!3704, !3704, !4802}
!4802 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3704, size: 64)
!4803 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !2380, line: 31)
!4804 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !113, line: 40)
!4805 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !197, line: 31)
!4806 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !5, entity: !4807, file: !4810, line: 58)
!4807 = !DIDerivedType(tag: DW_TAG_typedef, name: "max_align_t", file: !4808, line: 24, baseType: !4809)
!4808 = !DIFile(filename: "animals/opencilk/build-test/lib/clang/10.0.1/include/__stddef_max_align_t.h", directory: "/data")
!4809 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !4808, line: 19, flags: DIFlagFwdDecl, identifier: "_ZTS11max_align_t")
!4810 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/cstddef", directory: "")
!4811 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !0, entity: !5, file: !192, line: 44)
!4812 = !{i32 7, !"Dwarf Version", i32 4}
!4813 = !{i32 2, !"Debug Info Version", i32 3}
!4814 = !{i32 1, !"wchar_size", i32 4}
!4815 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git 46cdea0e962f3423b2fffa5746650aef824098f1)"}
!4816 = !DILocation(line: 0, scope: !2998)
!4817 = !DILocation(line: 152, column: 10, scope: !4818, inlinedAt: !4819)
!4818 = distinct !DILexicalBlock(scope: !1588, file: !772, line: 150, column: 47)
!4819 = distinct !DILocation(line: 98, column: 12, scope: !4820)
!4820 = distinct !DILexicalBlock(scope: !4821, file: !192, line: 89, column: 26)
!4821 = distinct !DILexicalBlock(scope: !2998, file: !192, line: 89, column: 7)
!4822 = !DILocalVariable(name: "f", scope: !4818, file: !772, line: 152, type: !1596)
!4823 = !DILocation(line: 85, column: 58, scope: !2998)
!4824 = !DILocation(line: 87, column: 15, scope: !2998)
!4825 = !{!4826, !4830, i64 8}
!4826 = !{!"_ZTS5graphI16asymmetricVertexE", !4827, i64 0, !4830, i64 8, !4830, i64 16, !4831, i64 24, !4827, i64 32, !4827, i64 40}
!4827 = !{!"any pointer", !4828, i64 0}
!4828 = !{!"omnipotent char", !4829, i64 0}
!4829 = !{!"Simple C++ TBAA"}
!4830 = !{!"long", !4828, i64 0}
!4831 = !{!"bool", !4828, i64 0}
!4832 = !DILocation(line: 88, column: 18, scope: !2998)
!4833 = !{!4826, !4827, i64 0}
!4834 = !DILocation(line: 56, column: 58, scope: !4835, inlinedAt: !4841)
!4835 = distinct !DISubprogram(name: "should_output", linkageName: "_Z13should_outputRKj", scope: !192, file: !192, line: 56, type: !4836, scopeLine: 56, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !4839)
!4836 = !DISubroutineType(types: !4837)
!4837 = !{!92, !4838}
!4838 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1532, size: 64)
!4839 = !{!4840}
!4840 = !DILocalVariable(name: "fl", arg: 1, scope: !4835, file: !192, line: 56, type: !4838)
!4841 = distinct !DILocation(line: 89, column: 7, scope: !4821)
!4842 = !DILocation(line: 56, column: 54, scope: !4835, inlinedAt: !4841)
!4843 = !DILocation(line: 89, column: 7, scope: !2998)
!4844 = !DILocation(line: 90, column: 15, scope: !4820)
!4845 = !DILocalVariable(name: "next", scope: !4820, file: !192, line: 90, type: !2996)
!4846 = !DILocation(line: 0, scope: !4820)
!4847 = !DILocalVariable(name: "g", scope: !4820, file: !192, line: 91, type: !1545)
!4848 = !DILocalVariable(name: "__init", scope: !4849, type: !52, flags: DIFlagArtificial)
!4849 = distinct !DILexicalBlock(scope: !4820, file: !192, line: 92, column: 5)
!4850 = !DILocation(line: 0, scope: !4849)
!4851 = !DILocalVariable(name: "__limit", scope: !4849, type: !52, flags: DIFlagArtificial)
!4852 = !DILocation(line: 92, column: 28, scope: !4849)
!4853 = !DILocation(line: 92, column: 29, scope: !4849)
!4854 = !DILocalVariable(name: "__begin", scope: !4849, type: !52, flags: DIFlagArtificial)
!4855 = !DILocation(line: 92, column: 5, scope: !4849)
!4856 = !DILocalVariable(name: "i", scope: !4857, file: !192, line: 92, type: !52)
!4857 = distinct !DILexicalBlock(scope: !4849, file: !192, line: 92, column: 5)
!4858 = !DILocation(line: 0, scope: !4857)
!4859 = !DILocation(line: 92, column: 50, scope: !4860)
!4860 = distinct !DILexicalBlock(scope: !4857, file: !192, line: 92, column: 36)
!4861 = !DILocalVariable(name: "__t", arg: 1, scope: !4862, file: !798, line: 201, type: !1060)
!4862 = distinct !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEE7_M_headERS2_", scope: !1019, file: !798, line: 201, type: !1058, scopeLine: 201, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !1057, retainedNodes: !4863)
!4863 = !{!4861}
!4864 = !DILocation(line: 0, scope: !4862, inlinedAt: !4865)
!4865 = distinct !DILocation(line: 1284, column: 14, scope: !4866, inlinedAt: !4872)
!4866 = distinct !DISubprogram(name: "__get_helper<0, bool, pbbs::empty>", linkageName: "_ZSt12__get_helperILm0EbJN4pbbs5emptyEEERT0_RSt11_Tuple_implIXT_EJS2_DpT1_EE", scope: !5, file: !798, line: 1283, type: !1058, scopeLine: 1284, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !4869, retainedNodes: !4867)
!4867 = !{!4868}
!4868 = !DILocalVariable(name: "__t", arg: 1, scope: !4866, file: !798, line: 1283, type: !1060)
!4869 = !{!4870, !1056, !4871}
!4870 = !DITemplateValueParameter(name: "__i", type: !86, value: i64 0)
!4871 = !DITemplateValueParameter(tag: DW_TAG_GNU_template_parameter_pack, name: "_Tail", value: !894)
!4872 = distinct !DILocation(line: 1295, column: 14, scope: !4873, inlinedAt: !4887)
!4873 = distinct !DISubprogram(name: "get<0, bool, pbbs::empty>", linkageName: "_ZSt3getILm0EJbN4pbbs5emptyEEERNSt13tuple_elementIXT_ESt5tupleIJDpT0_EEE4typeERS6_", scope: !5, file: !798, line: 1294, type: !4874, scopeLine: 1295, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !4886, retainedNodes: !4884)
!4874 = !DISubroutineType(types: !4875)
!4875 = !{!4876, !1114}
!4876 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4877, size: 64)
!4877 = !DIDerivedType(tag: DW_TAG_typedef, name: "__tuple_element_t<0UL, tuple<bool, pbbs::empty> >", scope: !5, file: !4878, line: 118, baseType: !4879)
!4878 = !DIFile(filename: "/usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/utility", directory: "")
!4879 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !4880, file: !798, line: 1268, baseType: !92)
!4880 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tuple_element<0, std::tuple<bool, pbbs::empty> >", scope: !5, file: !798, line: 1266, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !4881, identifier: "_ZTSSt13tuple_elementILm0ESt5tupleIJbN4pbbs5emptyEEEE")
!4881 = !{!4882, !4883}
!4882 = !DITemplateValueParameter(name: "_Int", type: !86, value: i64 0)
!4883 = !DITemplateTypeParameter(name: "_Tp", type: !1016)
!4884 = !{!4885}
!4885 = !DILocalVariable(name: "__t", arg: 1, scope: !4873, file: !798, line: 1294, type: !1114)
!4886 = !{!4870, !1097}
!4887 = distinct !DILocation(line: 92, column: 38, scope: !4860)
!4888 = !DILocalVariable(name: "__b", arg: 1, scope: !4889, file: !798, line: 166, type: !1051)
!4889 = distinct !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm0EbLb0EE7_M_headERS0_", scope: !1023, file: !798, line: 166, type: !1048, scopeLine: 166, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !1047, retainedNodes: !4890)
!4890 = !{!4888}
!4891 = !DILocation(line: 0, scope: !4889, inlinedAt: !4892)
!4892 = distinct !DILocation(line: 201, column: 51, scope: !4862, inlinedAt: !4865)
!4893 = !DILocation(line: 92, column: 59, scope: !4860)
!4894 = !{!4831, !4831, i64 0}
!4895 = !DILocation(line: 92, column: 64, scope: !4860)
!4896 = !DILocation(line: 92, column: 32, scope: !4857)
!4897 = !DILocation(line: 92, column: 28, scope: !4857)
!4898 = !DILocation(line: 92, column: 5, scope: !4857)
!4899 = distinct !{!4899, !4855, !4900, !4901}
!4900 = !DILocation(line: 92, column: 64, scope: !4849)
!4901 = !{!"tapir.loop.spawn.strategy", i32 1}
!4902 = !DILocalVariable(name: "__init", scope: !4903, type: !52, flags: DIFlagArtificial)
!4903 = distinct !DILexicalBlock(scope: !4820, file: !192, line: 93, column: 5)
!4904 = !DILocation(line: 0, scope: !4903)
!4905 = !DILocalVariable(name: "__limit", scope: !4903, type: !52, flags: DIFlagArtificial)
!4906 = !DILocation(line: 0, scope: !4907, inlinedAt: !4912)
!4907 = distinct !DISubprogram(name: "isIn", linkageName: "_ZNK16vertexSubsetDataIN4pbbs5emptyEE4isInERKj", scope: !771, file: !772, line: 167, type: !1147, scopeLine: 167, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !1146, retainedNodes: !4908)
!4908 = !{!4909, !4911}
!4909 = !DILocalVariable(name: "this", arg: 1, scope: !4907, type: !4910, flags: DIFlagArtificial | DIFlagObjectPointer)
!4910 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1138, size: 64)
!4911 = !DILocalVariable(name: "v", arg: 2, scope: !4907, file: !772, line: 167, type: !1139)
!4912 = distinct !DILocation(line: 94, column: 24, scope: !4913)
!4913 = distinct !DILexicalBlock(scope: !4914, file: !192, line: 94, column: 11)
!4914 = distinct !DILexicalBlock(scope: !4915, file: !192, line: 93, column: 39)
!4915 = distinct !DILexicalBlock(scope: !4903, file: !192, line: 93, column: 5)
!4916 = !DILocation(line: 0, scope: !4917, inlinedAt: !4922)
!4917 = distinct !DISubprogram(name: "cond", linkageName: "_ZN5BFS_F4condEj", scope: !754, file: !1, line: 37, type: !766, scopeLine: 37, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !765, retainedNodes: !4918)
!4918 = !{!4919, !4921}
!4919 = !DILocalVariable(name: "this", arg: 1, scope: !4917, type: !4920, flags: DIFlagArtificial | DIFlagObjectPointer)
!4920 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !754, size: 64)
!4921 = !DILocalVariable(name: "d", arg: 2, scope: !4917, file: !1, line: 37, type: !50)
!4922 = distinct !DILocation(line: 48, column: 5, scope: !4923, inlinedAt: !4974)
!4923 = distinct !DILexicalBlock(scope: !4924, file: !433, line: 48, column: 5)
!4924 = distinct !DILexicalBlock(scope: !4925, file: !433, line: 48, column: 5)
!4925 = distinct !DILexicalBlock(scope: !4926, file: !433, line: 48, column: 5)
!4926 = distinct !DILexicalBlock(scope: !4927, file: !433, line: 48, column: 5)
!4927 = distinct !DILexicalBlock(scope: !4928, file: !433, line: 48, column: 5)
!4928 = distinct !DILexicalBlock(scope: !4929, file: !433, line: 48, column: 5)
!4929 = distinct !DILexicalBlock(scope: !4930, file: !433, line: 48, column: 5)
!4930 = distinct !DILexicalBlock(scope: !4931, file: !433, line: 48, column: 5)
!4931 = distinct !DILexicalBlock(scope: !4932, file: !433, line: 48, column: 5)
!4932 = distinct !DISubprogram(name: "decodeOutNgh<asymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:30:10)>", linkageName: "_ZN19decode_uncompressed12decodeOutNghI16asymmetricVertex5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEvPS7_lRT0_RT1_", scope: !4933, file: !433, line: 46, type: !4934, scopeLine: 46, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !4971, retainedNodes: !4937)
!4933 = !DINamespace(name: "decode_uncompressed", scope: null)
!4934 = !DISubroutineType(types: !4935)
!4935 = !{null, !505, !52, !1181, !4936}
!4936 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1545, size: 64)
!4937 = !{!4938, !4939, !4940, !4941, !4942, !4943, !4949, !4950, !4951, !4952, !4954, !4957, !4960, !4964, !4968}
!4938 = !DILocalVariable(name: "v", arg: 1, scope: !4932, file: !433, line: 46, type: !505)
!4939 = !DILocalVariable(name: "i", arg: 2, scope: !4932, file: !433, line: 46, type: !52)
!4940 = !DILocalVariable(name: "f", arg: 3, scope: !4932, file: !433, line: 46, type: !1181)
!4941 = !DILocalVariable(name: "g", arg: 4, scope: !4932, file: !433, line: 46, type: !4936)
!4942 = !DILocalVariable(name: "d", scope: !4932, file: !433, line: 47, type: !50)
!4943 = !DILocalVariable(name: "__init", scope: !4944, type: !779, flags: DIFlagArtificial)
!4944 = distinct !DILexicalBlock(scope: !4945, file: !433, line: 48, column: 5)
!4945 = distinct !DILexicalBlock(scope: !4946, file: !433, line: 48, column: 5)
!4946 = distinct !DILexicalBlock(scope: !4947, file: !433, line: 48, column: 5)
!4947 = distinct !DILexicalBlock(scope: !4948, file: !433, line: 48, column: 5)
!4948 = distinct !DILexicalBlock(scope: !4932, file: !433, line: 48, column: 5)
!4949 = !DILocalVariable(name: "__limit", scope: !4944, type: !779, flags: DIFlagArtificial)
!4950 = !DILocalVariable(name: "__begin", scope: !4944, type: !779, flags: DIFlagArtificial)
!4951 = !DILocalVariable(name: "__end", scope: !4944, type: !779, flags: DIFlagArtificial)
!4952 = !DILocalVariable(name: "j", scope: !4953, file: !433, line: 48, type: !779)
!4953 = distinct !DILexicalBlock(scope: !4944, file: !433, line: 48, column: 5)
!4954 = !DILocalVariable(name: "ngh", scope: !4955, file: !433, line: 48, type: !50)
!4955 = distinct !DILexicalBlock(scope: !4956, file: !433, line: 48, column: 5)
!4956 = distinct !DILexicalBlock(scope: !4953, file: !433, line: 48, column: 5)
!4957 = !DILocalVariable(name: "m", scope: !4958, file: !433, line: 48, type: !92)
!4958 = distinct !DILexicalBlock(scope: !4959, file: !433, line: 48, column: 5)
!4959 = distinct !DILexicalBlock(scope: !4955, file: !433, line: 48, column: 5)
!4960 = !DILocalVariable(name: "j", scope: !4961, file: !433, line: 48, type: !779)
!4961 = distinct !DILexicalBlock(scope: !4962, file: !433, line: 48, column: 5)
!4962 = distinct !DILexicalBlock(scope: !4963, file: !433, line: 48, column: 5)
!4963 = distinct !DILexicalBlock(scope: !4947, file: !433, line: 48, column: 5)
!4964 = !DILocalVariable(name: "ngh", scope: !4965, file: !433, line: 48, type: !50)
!4965 = distinct !DILexicalBlock(scope: !4966, file: !433, line: 48, column: 5)
!4966 = distinct !DILexicalBlock(scope: !4967, file: !433, line: 48, column: 5)
!4967 = distinct !DILexicalBlock(scope: !4961, file: !433, line: 48, column: 5)
!4968 = !DILocalVariable(name: "m", scope: !4969, file: !433, line: 48, type: !92)
!4969 = distinct !DILexicalBlock(scope: !4970, file: !433, line: 48, column: 5)
!4970 = distinct !DILexicalBlock(scope: !4965, file: !433, line: 48, column: 5)
!4971 = !{!4972, !1167, !4973}
!4972 = !DITemplateTypeParameter(name: "V", type: !506)
!4973 = !DITemplateTypeParameter(name: "G", type: !1545)
!4974 = distinct !DILocation(line: 332, column: 5, scope: !4975, inlinedAt: !4985)
!4975 = distinct !DISubprogram(name: "decodeOutNgh<BFS_F, (lambda at ./edgeMap_utils.h:30:10)>", linkageName: "_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEvlRS6_RT0_", scope: !506, file: !433, line: 331, type: !4976, scopeLine: 331, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !4979, declaration: !4978, retainedNodes: !4980)
!4976 = !DISubroutineType(types: !4977)
!4977 = !{null, !515, !52, !1181, !4936}
!4978 = !DISubprogram(name: "decodeOutNgh<BFS_F, (lambda at ./edgeMap_utils.h:30:10)>", linkageName: "_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEEUljbE_EEvlRS6_RT0_", scope: !506, file: !433, line: 331, type: !4976, scopeLine: 331, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !4979)
!4979 = !{!1167, !4973}
!4980 = !{!4981, !4982, !4983, !4984}
!4981 = !DILocalVariable(name: "this", arg: 1, scope: !4975, type: !505, flags: DIFlagArtificial | DIFlagObjectPointer)
!4982 = !DILocalVariable(name: "i", arg: 2, scope: !4975, file: !433, line: 331, type: !52)
!4983 = !DILocalVariable(name: "f", arg: 3, scope: !4975, file: !433, line: 331, type: !1181)
!4984 = !DILocalVariable(name: "g", arg: 4, scope: !4975, file: !433, line: 331, type: !4936)
!4985 = distinct !DILocation(line: 95, column: 14, scope: !4986)
!4986 = distinct !DILexicalBlock(scope: !4913, file: !192, line: 94, column: 33)
!4987 = !DILocation(line: 93, column: 5, scope: !4903)
!4988 = !DILocation(line: 0, scope: !4915)
!4989 = !DILocation(line: 0, scope: !4990, inlinedAt: !4994)
!4990 = distinct !DISubprogram(name: "getOutDegree", linkageName: "_ZNK16asymmetricVertex12getOutDegreeEv", scope: !506, file: !433, line: 320, type: !542, scopeLine: 320, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !544, retainedNodes: !4991)
!4991 = !{!4992}
!4992 = !DILocalVariable(name: "this", arg: 1, scope: !4990, type: !4993, flags: DIFlagArtificial | DIFlagObjectPointer)
!4993 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !526, size: 64)
!4994 = distinct !DILocation(line: 47, column: 18, scope: !4932, inlinedAt: !4974)
!4995 = !DILocation(line: 0, scope: !4996, inlinedAt: !5000)
!4996 = distinct !DISubprogram(name: "getOutNeighbor", linkageName: "_ZNK16asymmetricVertex14getOutNeighborEj", scope: !506, file: !433, line: 297, type: !530, scopeLine: 297, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !532, retainedNodes: !4997)
!4997 = !{!4998, !4999}
!4998 = !DILocalVariable(name: "this", arg: 1, scope: !4996, type: !4993, flags: DIFlagArtificial | DIFlagObjectPointer)
!4999 = !DILocalVariable(name: "j", arg: 2, scope: !4996, file: !433, line: 297, type: !126)
!5000 = distinct !DILocation(line: 48, column: 5, scope: !4924, inlinedAt: !4974)
!5001 = !DILocation(line: 0, scope: !5002, inlinedAt: !4974)
!5002 = distinct !DILexicalBlock(scope: !5003, file: !433, line: 48, column: 5)
!5003 = distinct !DILexicalBlock(scope: !5004, file: !433, line: 48, column: 5)
!5004 = distinct !DILexicalBlock(scope: !4930, file: !433, line: 48, column: 5)
!5005 = !DILocation(line: 0, scope: !4996, inlinedAt: !5006)
!5006 = distinct !DILocation(line: 48, column: 5, scope: !5007, inlinedAt: !4974)
!5007 = distinct !DILexicalBlock(scope: !5008, file: !433, line: 48, column: 5)
!5008 = distinct !DILexicalBlock(scope: !5009, file: !433, line: 48, column: 5)
!5009 = distinct !DILexicalBlock(scope: !5002, file: !433, line: 48, column: 5)
!5010 = !DILocation(line: 0, scope: !4917, inlinedAt: !5011)
!5011 = distinct !DILocation(line: 48, column: 5, scope: !5012, inlinedAt: !4974)
!5012 = distinct !DILexicalBlock(scope: !5007, file: !433, line: 48, column: 5)
!5013 = !DILocation(line: 0, scope: !5009, inlinedAt: !4974)
!5014 = !DILocalVariable(name: "__begin", scope: !4903, type: !52, flags: DIFlagArtificial)
!5015 = !DILocalVariable(name: "i", scope: !4915, file: !192, line: 93, type: !52)
!5016 = !DILocation(line: 94, column: 29, scope: !4913)
!5017 = !DILocation(line: 167, column: 51, scope: !4907, inlinedAt: !4912)
!5018 = !{!5019, !4827, i64 8}
!5019 = !{!"_ZTS16vertexSubsetDataIN4pbbs5emptyEE", !4827, i64 0, !4827, i64 8, !4830, i64 16, !4830, i64 24, !4831, i64 32}
!5020 = !{i8 0, i8 2}
!5021 = !DILocation(line: 94, column: 11, scope: !4914)
!5022 = !DILocation(line: 0, scope: !4975, inlinedAt: !4985)
!5023 = !DILocation(line: 0, scope: !4932, inlinedAt: !4974)
!5024 = !DILocation(line: 320, column: 39, scope: !4990, inlinedAt: !4994)
!5025 = !{!5026, !5027, i64 16}
!5026 = !{!"_ZTS16asymmetricVertex", !4827, i64 0, !4827, i64 8, !5027, i64 16, !5027, i64 20}
!5027 = !{!"int", !4828, i64 0}
!5028 = !DILocation(line: 0, scope: !4930, inlinedAt: !4974)
!5029 = !DILocation(line: 48, column: 5, scope: !4930, inlinedAt: !4974)
!5030 = !DILocation(line: 95, column: 14, scope: !4986)
!5031 = !DILocation(line: 48, column: 5, scope: !4931, inlinedAt: !4974)
!5032 = !DILocalVariable(name: "j", scope: !4927, file: !433, line: 48, type: !779)
!5033 = !DILocation(line: 0, scope: !4927, inlinedAt: !4974)
!5034 = !DILocation(line: 48, column: 5, scope: !4926, inlinedAt: !4974)
!5035 = !DILocation(line: 48, column: 5, scope: !4927, inlinedAt: !4974)
!5036 = !DILocation(line: 0, scope: !5037, inlinedAt: !5048)
!5037 = distinct !DILexicalBlock(scope: !5038, file: !54, line: 308, column: 31)
!5038 = distinct !DILexicalBlock(scope: !5039, file: !54, line: 308, column: 14)
!5039 = distinct !DILexicalBlock(scope: !5040, file: !54, line: 306, column: 7)
!5040 = distinct !DISubprogram(name: "CAS<unsigned int>", linkageName: "_Z3CASIjEbPT_S0_S0_", scope: !54, file: !54, line: 305, type: !5041, scopeLine: 305, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !5047, retainedNodes: !5043)
!5041 = !DISubroutineType(types: !5042)
!5042 = !{!92, !1175, !18, !18}
!5043 = !{!5044, !5045, !5046}
!5044 = !DILocalVariable(name: "ptr", arg: 1, scope: !5040, file: !54, line: 305, type: !1175)
!5045 = !DILocalVariable(name: "oldv", arg: 2, scope: !5040, file: !54, line: 305, type: !18)
!5046 = !DILocalVariable(name: "newv", arg: 3, scope: !5040, file: !54, line: 305, type: !18)
!5047 = !{!1512}
!5048 = distinct !DILocation(line: 34, column: 13, scope: !5049, inlinedAt: !5054)
!5049 = distinct !DISubprogram(name: "updateAtomic", linkageName: "_ZN5BFS_F12updateAtomicEjj", scope: !754, file: !1, line: 33, type: !762, scopeLine: 33, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !764, retainedNodes: !5050)
!5050 = !{!5051, !5052, !5053}
!5051 = !DILocalVariable(name: "this", arg: 1, scope: !5049, type: !4920, flags: DIFlagArtificial | DIFlagObjectPointer)
!5052 = !DILocalVariable(name: "s", arg: 2, scope: !5049, file: !1, line: 33, type: !50)
!5053 = !DILocalVariable(name: "d", arg: 3, scope: !5049, file: !1, line: 33, type: !50)
!5054 = distinct !DILocation(line: 48, column: 5, scope: !5055, inlinedAt: !4974)
!5055 = distinct !DILexicalBlock(scope: !4923, file: !433, line: 48, column: 5)
!5056 = !DILocation(line: 0, scope: !5057, inlinedAt: !5149)
!5057 = distinct !DISubprogram(name: "_M_assign<int, pbbs::empty>", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEE9_M_assignIiJS1_EEEvOS_ILm0EJT_DpT0_EE", scope: !1019, file: !798, line: 320, type: !5058, scopeLine: 321, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !5142, declaration: !5141, retainedNodes: !5145)
!5058 = !DISubroutineType(types: !5059)
!5059 = !{null, !1079, !5060}
!5060 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !5061, size: 64)
!5061 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Tuple_impl<0, int, pbbs::empty>", scope: !5, file: !798, line: 191, size: 32, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !5062, templateParams: !5137, identifier: "_ZTSSt11_Tuple_implILm0EJiN4pbbs5emptyEEE")
!5062 = !{!5063, !5064, !5099, !5103, !5108, !5113, !5118, !5122, !5125, !5128, !5131, !5134}
!5063 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !5061, baseType: !804, extraData: i32 0)
!5064 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !5061, baseType: !5065, flags: DIFlagPrivate, extraData: i32 0)
!5065 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_Head_base<0, int, false>", scope: !5, file: !798, line: 124, size: 32, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !5066, templateParams: !5097, identifier: "_ZTSSt10_Head_baseILm0EiLb0EE")
!5066 = !{!5067, !5068, !5072, !5077, !5082, !5086, !5089, !5094}
!5067 = !DIDerivedType(tag: DW_TAG_member, name: "_M_head_impl", scope: !5065, file: !798, line: 171, baseType: !6, size: 32)
!5068 = !DISubprogram(name: "_Head_base", scope: !5065, file: !798, line: 126, type: !5069, scopeLine: 126, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5069 = !DISubroutineType(types: !5070)
!5070 = !{null, !5071}
!5071 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !5065, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!5072 = !DISubprogram(name: "_Head_base", scope: !5065, file: !798, line: 129, type: !5073, scopeLine: 129, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5073 = !DISubroutineType(types: !5074)
!5074 = !{null, !5071, !5075}
!5075 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5076, size: 64)
!5076 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !6)
!5077 = !DISubprogram(name: "_Head_base", scope: !5065, file: !798, line: 132, type: !5078, scopeLine: 132, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5078 = !DISubroutineType(types: !5079)
!5079 = !{null, !5071, !5080}
!5080 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5081, size: 64)
!5081 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !5065)
!5082 = !DISubprogram(name: "_Head_base", scope: !5065, file: !798, line: 133, type: !5083, scopeLine: 133, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5083 = !DISubroutineType(types: !5084)
!5084 = !{null, !5071, !5085}
!5085 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !5065, size: 64)
!5086 = !DISubprogram(name: "_Head_base", scope: !5065, file: !798, line: 140, type: !5087, scopeLine: 140, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5087 = !DISubroutineType(types: !5088)
!5088 = !{null, !5071, !833, !840}
!5089 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm0EiLb0EE7_M_headERS0_", scope: !5065, file: !798, line: 166, type: !5090, scopeLine: 166, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!5090 = !DISubroutineType(types: !5091)
!5091 = !{!5092, !5093}
!5092 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !6, size: 64)
!5093 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5065, size: 64)
!5094 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt10_Head_baseILm0EiLb0EE7_M_headERKS0_", scope: !5065, file: !798, line: 169, type: !5095, scopeLine: 169, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!5095 = !DISubroutineType(types: !5096)
!5096 = !{!5075, !5080}
!5097 = !{!930, !5098, !932}
!5098 = !DITemplateTypeParameter(name: "_Head", type: !6)
!5099 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm0EJiN4pbbs5emptyEEE7_M_headERS2_", scope: !5061, file: !798, line: 201, type: !5100, scopeLine: 201, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!5100 = !DISubroutineType(types: !5101)
!5101 = !{!5092, !5102}
!5102 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5061, size: 64)
!5103 = !DISubprogram(name: "_M_head", linkageName: "_ZNSt11_Tuple_implILm0EJiN4pbbs5emptyEEE7_M_headERKS2_", scope: !5061, file: !798, line: 204, type: !5104, scopeLine: 204, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!5104 = !DISubroutineType(types: !5105)
!5105 = !{!5075, !5106}
!5106 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5107, size: 64)
!5107 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !5061)
!5108 = !DISubprogram(name: "_M_tail", linkageName: "_ZNSt11_Tuple_implILm0EJiN4pbbs5emptyEEE7_M_tailERS2_", scope: !5061, file: !798, line: 207, type: !5109, scopeLine: 207, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!5109 = !DISubroutineType(types: !5110)
!5110 = !{!5111, !5102}
!5111 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5112, size: 64)
!5112 = !DIDerivedType(tag: DW_TAG_typedef, name: "_Inherited", scope: !5061, file: !798, line: 197, baseType: !804)
!5113 = !DISubprogram(name: "_M_tail", linkageName: "_ZNSt11_Tuple_implILm0EJiN4pbbs5emptyEEE7_M_tailERKS2_", scope: !5061, file: !798, line: 210, type: !5114, scopeLine: 210, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!5114 = !DISubroutineType(types: !5115)
!5115 = !{!5116, !5106}
!5116 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5117, size: 64)
!5117 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !5112)
!5118 = !DISubprogram(name: "_Tuple_impl", scope: !5061, file: !798, line: 212, type: !5119, scopeLine: 212, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5119 = !DISubroutineType(types: !5120)
!5120 = !{null, !5121}
!5121 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !5061, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!5122 = !DISubprogram(name: "_Tuple_impl", scope: !5061, file: !798, line: 216, type: !5123, scopeLine: 216, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5123 = !DISubroutineType(types: !5124)
!5124 = !{null, !5121, !5075, !819}
!5125 = !DISubprogram(name: "_Tuple_impl", scope: !5061, file: !798, line: 226, type: !5126, scopeLine: 226, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5126 = !DISubroutineType(types: !5127)
!5127 = !{null, !5121, !5106}
!5128 = !DISubprogram(name: "operator=", linkageName: "_ZNSt11_Tuple_implILm0EJiN4pbbs5emptyEEEaSERKS2_", scope: !5061, file: !798, line: 230, type: !5129, scopeLine: 230, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized | DISPFlagDeleted)
!5129 = !DISubroutineType(types: !5130)
!5130 = !{!5102, !5121, !5106}
!5131 = !DISubprogram(name: "_Tuple_impl", scope: !5061, file: !798, line: 233, type: !5132, scopeLine: 233, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5132 = !DISubroutineType(types: !5133)
!5133 = !{null, !5121, !5060}
!5134 = !DISubprogram(name: "_M_swap", linkageName: "_ZNSt11_Tuple_implILm0EJiN4pbbs5emptyEEE7_M_swapERS2_", scope: !5061, file: !798, line: 331, type: !5135, scopeLine: 331, flags: DIFlagProtected | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5135 = !DISubroutineType(types: !5136)
!5136 = !{null, !5121, !5102}
!5137 = !{!930, !5138}
!5138 = !DITemplateValueParameter(tag: DW_TAG_GNU_template_parameter_pack, name: "_Elements", value: !5139)
!5139 = !{!5140, !895}
!5140 = !DITemplateTypeParameter(type: !6)
!5141 = !DISubprogram(name: "_M_assign<int, pbbs::empty>", linkageName: "_ZNSt11_Tuple_implILm0EJbN4pbbs5emptyEEE9_M_assignIiJS1_EEEvOS_ILm0EJT_DpT0_EE", scope: !1019, file: !798, line: 320, type: !5058, scopeLine: 320, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !5142)
!5142 = !{!5143, !5144}
!5143 = !DITemplateTypeParameter(name: "_UHead", type: !6)
!5144 = !DITemplateValueParameter(tag: DW_TAG_GNU_template_parameter_pack, name: "_UTails", value: !894)
!5145 = !{!5146, !5148}
!5146 = !DILocalVariable(name: "this", arg: 1, scope: !5057, type: !5147, flags: DIFlagArtificial | DIFlagObjectPointer)
!5147 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1019, size: 64)
!5148 = !DILocalVariable(name: "__in", arg: 2, scope: !5057, file: !798, line: 320, type: !5060)
!5149 = distinct !DILocation(line: 1209, column: 10, scope: !5150, inlinedAt: !5197)
!5150 = distinct !DISubprogram(name: "operator=<int, pbbs::empty>", linkageName: "_ZNSt5tupleIJbN4pbbs5emptyEEEaSIiS1_EENSt9enable_ifIXcl12__assignableIT_T0_EEERS2_E4typeEOS_IJS5_S6_EE", scope: !1016, file: !798, line: 1206, type: !5151, scopeLine: 1208, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !5192, declaration: !5191, retainedNodes: !5194)
!5151 = !DISubroutineType(types: !5152)
!5152 = !{!5153, !1104, !5158}
!5153 = !DIDerivedType(tag: DW_TAG_typedef, name: "__enable_if_t<__assignable<int, pbbs::empty>(), std::tuple<bool, pbbs::empty> &>", scope: !5, file: !260, line: 2192, baseType: !5154)
!5154 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !5155, file: !260, line: 2188, baseType: !1114)
!5155 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "enable_if<true, std::tuple<bool, pbbs::empty> &>", scope: !5, file: !260, line: 2187, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !5156, identifier: "_ZTSSt9enable_ifILb1ERSt5tupleIJbN4pbbs5emptyEEEE")
!5156 = !{!862, !5157}
!5157 = !DITemplateTypeParameter(name: "_Tp", type: !1114)
!5158 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !5159, size: 64)
!5159 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "tuple<int, pbbs::empty>", scope: !5, file: !798, line: 887, size: 32, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !5160, templateParams: !5190, identifier: "_ZTSSt5tupleIJiN4pbbs5emptyEEE")
!5160 = !{!5161, !5162, !5163, !5169, !5172, !5180, !5187}
!5161 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !5159, baseType: !5061, flags: DIFlagPublic, extraData: i32 0)
!5162 = !DISubprogram(name: "__nothrow_default_constructible", linkageName: "_ZNSt5tupleIJiN4pbbs5emptyEEE31__nothrow_default_constructibleEv", scope: !5159, file: !798, line: 941, type: !623, scopeLine: 941, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagOptimized)
!5163 = !DISubprogram(name: "tuple", scope: !5159, file: !798, line: 994, type: !5164, scopeLine: 994, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5164 = !DISubroutineType(types: !5165)
!5165 = !{null, !5166, !5167}
!5166 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !5159, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!5167 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5168, size: 64)
!5168 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !5159)
!5169 = !DISubprogram(name: "tuple", scope: !5159, file: !798, line: 996, type: !5170, scopeLine: 996, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5170 = !DISubroutineType(types: !5171)
!5171 = !{null, !5166, !5158}
!5172 = !DISubprogram(name: "operator=", linkageName: "_ZNSt5tupleIJiN4pbbs5emptyEEEaSERKS2_", scope: !5159, file: !798, line: 1173, type: !5173, scopeLine: 1173, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5173 = !DISubroutineType(types: !5174)
!5174 = !{!5175, !5166, !5176}
!5175 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5159, size: 64)
!5176 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !5177, file: !260, line: 2201, baseType: !5167)
!5177 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, const std::tuple<int, pbbs::empty> &, const std::__nonesuch &>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !5178, identifier: "_ZTSSt11conditionalILb1ERKSt5tupleIJiN4pbbs5emptyEEERKSt10__nonesuchE")
!5178 = !{!263, !5179, !265}
!5179 = !DITemplateTypeParameter(name: "_Iftrue", type: !5167)
!5180 = !DISubprogram(name: "operator=", linkageName: "_ZNSt5tupleIJiN4pbbs5emptyEEEaSEOS2_", scope: !5159, file: !798, line: 1184, type: !5181, scopeLine: 1184, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5181 = !DISubroutineType(types: !5182)
!5182 = !{!5175, !5166, !5183}
!5183 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !5184, file: !260, line: 2201, baseType: !5158)
!5184 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "conditional<true, std::tuple<int, pbbs::empty> &&, std::__nonesuch &&>", scope: !5, file: !260, line: 2200, size: 8, flags: DIFlagTypePassByValue, elements: !45, templateParams: !5185, identifier: "_ZTSSt11conditionalILb1EOSt5tupleIJiN4pbbs5emptyEEEOSt10__nonesuchE")
!5185 = !{!263, !5186, !276}
!5186 = !DITemplateTypeParameter(name: "_Iftrue", type: !5158)
!5187 = !DISubprogram(name: "swap", linkageName: "_ZNSt5tupleIJiN4pbbs5emptyEEE4swapERS2_", scope: !5159, file: !798, line: 1237, type: !5188, scopeLine: 1237, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5188 = !DISubroutineType(types: !5189)
!5189 = !{null, !5166, !5175}
!5190 = !{!5138}
!5191 = !DISubprogram(name: "operator=<int, pbbs::empty>", linkageName: "_ZNSt5tupleIJbN4pbbs5emptyEEEaSIiS1_EENSt9enable_ifIXcl12__assignableIT_T0_EEERS2_E4typeEOS_IJS5_S6_EE", scope: !1016, file: !798, line: 1206, type: !5151, scopeLine: 1206, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !5192)
!5192 = !{!307, !5193}
!5193 = !DITemplateTypeParameter(name: "_U2", type: !810)
!5194 = !{!5195, !5196}
!5195 = !DILocalVariable(name: "this", arg: 1, scope: !5150, type: !1015, flags: DIFlagArtificial | DIFlagObjectPointer)
!5196 = !DILocalVariable(name: "__in", arg: 2, scope: !5150, file: !798, line: 1206, type: !5158)
!5197 = distinct !DILocation(line: 31, column: 22, scope: !5198, inlinedAt: !5210)
!5198 = distinct !DILexicalBlock(scope: !5199, file: !1546, line: 31, column: 9)
!5199 = distinct !DISubprogram(name: "operator()", linkageName: "_ZZ23get_emdense_forward_genIN4pbbs5emptyELi0EEDaPSt5tupleIJbT_EEENKUljbE_clEjb", scope: !1545, file: !1546, line: 30, type: !5200, scopeLine: 30, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !5204, retainedNodes: !5205)
!5200 = !DISubroutineType(types: !5201)
!5201 = !{null, !5202, !50, !92}
!5202 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !5203, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!5203 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1545)
!5204 = !DISubprogram(name: "operator()", scope: !1545, file: !1546, line: 30, type: !5200, scopeLine: 30, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!5205 = !{!5206, !5208, !5209}
!5206 = !DILocalVariable(name: "this", arg: 1, scope: !5199, type: !5207, flags: DIFlagArtificial | DIFlagObjectPointer)
!5207 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !5203, size: 64)
!5208 = !DILocalVariable(name: "ngh", arg: 2, scope: !5199, file: !1546, line: 30, type: !50)
!5209 = !DILocalVariable(name: "m", arg: 3, scope: !5199, file: !1546, line: 30, type: !92)
!5210 = distinct !DILocation(line: 48, column: 5, scope: !5055, inlinedAt: !4974)
!5211 = !DILocalVariable(name: "__init", scope: !5002, type: !779, flags: DIFlagArtificial)
!5212 = !DILocalVariable(name: "__limit", scope: !5002, type: !779, flags: DIFlagArtificial)
!5213 = !DILocalVariable(name: "__begin", scope: !5002, type: !779, flags: DIFlagArtificial)
!5214 = !DILocalVariable(name: "__end", scope: !5002, type: !779, flags: DIFlagArtificial)
!5215 = !DILocation(line: 48, column: 5, scope: !5002, inlinedAt: !4974)
!5216 = !DILocation(line: 0, scope: !5037, inlinedAt: !5217)
!5217 = distinct !DILocation(line: 34, column: 13, scope: !5049, inlinedAt: !5218)
!5218 = distinct !DILocation(line: 48, column: 5, scope: !5219, inlinedAt: !4974)
!5219 = distinct !DILexicalBlock(scope: !5012, file: !433, line: 48, column: 5)
!5220 = !DILocation(line: 0, scope: !5057, inlinedAt: !5221)
!5221 = distinct !DILocation(line: 1209, column: 10, scope: !5150, inlinedAt: !5222)
!5222 = distinct !DILocation(line: 31, column: 22, scope: !5198, inlinedAt: !5223)
!5223 = distinct !DILocation(line: 48, column: 5, scope: !5219, inlinedAt: !4974)
!5224 = !DILocalVariable(name: "j", scope: !5009, file: !433, line: 48, type: !779)
!5225 = !DILocation(line: 297, column: 48, scope: !4996, inlinedAt: !5006)
!5226 = !{!5026, !4827, i64 8}
!5227 = !{!5027, !5027, i64 0}
!5228 = !DILocalVariable(name: "ngh", scope: !5007, file: !433, line: 48, type: !50)
!5229 = !DILocation(line: 0, scope: !5007, inlinedAt: !4974)
!5230 = !DILocation(line: 37, column: 40, scope: !4917, inlinedAt: !5011)
!5231 = !{!5232, !4827, i64 0}
!5232 = !{!"_ZTS5BFS_F", !4827, i64 0}
!5233 = !DILocation(line: 37, column: 51, scope: !4917, inlinedAt: !5011)
!5234 = !DILocation(line: 48, column: 5, scope: !5007, inlinedAt: !4974)
!5235 = !DILocation(line: 0, scope: !5049, inlinedAt: !5218)
!5236 = !DILocation(line: 0, scope: !5040, inlinedAt: !5217)
!5237 = !DILocation(line: 309, column: 12, scope: !5037, inlinedAt: !5217)
!5238 = !DILocalVariable(name: "m", scope: !5219, file: !433, line: 48, type: !92)
!5239 = !DILocation(line: 0, scope: !5219, inlinedAt: !4974)
!5240 = !DILocation(line: 0, scope: !5199, inlinedAt: !5223)
!5241 = !DILocation(line: 31, column: 9, scope: !5199, inlinedAt: !5223)
!5242 = !DILocation(line: 0, scope: !5150, inlinedAt: !5222)
!5243 = !DILocation(line: 0, scope: !4862, inlinedAt: !5244)
!5244 = distinct !DILocation(line: 322, column: 4, scope: !5057, inlinedAt: !5221)
!5245 = !DILocation(line: 0, scope: !4889, inlinedAt: !5246)
!5246 = distinct !DILocation(line: 201, column: 51, scope: !4862, inlinedAt: !5244)
!5247 = !DILocation(line: 166, column: 54, scope: !4889, inlinedAt: !5246)
!5248 = !DILocation(line: 322, column: 19, scope: !5057, inlinedAt: !5221)
!5249 = !DILocation(line: 31, column: 12, scope: !5198, inlinedAt: !5223)
!5250 = !DILocation(line: 48, column: 5, scope: !5008, inlinedAt: !4974)
!5251 = !DILocation(line: 48, column: 5, scope: !5009, inlinedAt: !4974)
!5252 = distinct !{!5252, !5215, !5215, !4901}
!5253 = !DILocation(line: 297, column: 48, scope: !4996, inlinedAt: !5000)
!5254 = !DILocalVariable(name: "ngh", scope: !4924, file: !433, line: 48, type: !50)
!5255 = !DILocation(line: 0, scope: !4924, inlinedAt: !4974)
!5256 = !DILocation(line: 37, column: 40, scope: !4917, inlinedAt: !4922)
!5257 = !DILocation(line: 37, column: 51, scope: !4917, inlinedAt: !4922)
!5258 = !DILocation(line: 48, column: 5, scope: !4924, inlinedAt: !4974)
!5259 = !DILocation(line: 0, scope: !5049, inlinedAt: !5054)
!5260 = !DILocation(line: 0, scope: !5040, inlinedAt: !5048)
!5261 = !DILocation(line: 309, column: 12, scope: !5037, inlinedAt: !5048)
!5262 = !DILocalVariable(name: "m", scope: !5055, file: !433, line: 48, type: !92)
!5263 = !DILocation(line: 0, scope: !5055, inlinedAt: !4974)
!5264 = !DILocation(line: 0, scope: !5199, inlinedAt: !5210)
!5265 = !DILocation(line: 31, column: 9, scope: !5199, inlinedAt: !5210)
!5266 = !DILocation(line: 0, scope: !5150, inlinedAt: !5197)
!5267 = !DILocation(line: 0, scope: !4862, inlinedAt: !5268)
!5268 = distinct !DILocation(line: 322, column: 4, scope: !5057, inlinedAt: !5149)
!5269 = !DILocation(line: 0, scope: !4889, inlinedAt: !5270)
!5270 = distinct !DILocation(line: 201, column: 51, scope: !4862, inlinedAt: !5268)
!5271 = !DILocation(line: 166, column: 54, scope: !4889, inlinedAt: !5270)
!5272 = !DILocation(line: 322, column: 19, scope: !5057, inlinedAt: !5149)
!5273 = !DILocation(line: 31, column: 12, scope: !5198, inlinedAt: !5210)
!5274 = distinct !{!5274, !5035, !5035}
!5275 = !DILocation(line: 96, column: 7, scope: !4986)
!5276 = !DILocation(line: 97, column: 5, scope: !4914)
!5277 = !DILocation(line: 93, column: 35, scope: !4915)
!5278 = !DILocation(line: 93, column: 30, scope: !4915)
!5279 = !DILocation(line: 93, column: 5, scope: !4915)
!5280 = distinct !{!5280, !4987, !5281, !4901}
!5281 = !DILocation(line: 97, column: 5, scope: !4903)
!5282 = !DILocation(line: 0, scope: !1588, inlinedAt: !4819)
!5283 = !{!4827, !4827, i64 0}
!5284 = !DILocation(line: 150, column: 12, scope: !1588, inlinedAt: !4819)
!5285 = !{!5019, !4827, i64 0}
!5286 = !DILocation(line: 150, column: 21, scope: !1588, inlinedAt: !4819)
!5287 = !DILocation(line: 150, column: 30, scope: !1588, inlinedAt: !4819)
!5288 = !DILocation(line: 150, column: 5, scope: !1588, inlinedAt: !4819)
!5289 = !{!5019, !4830, i64 16}
!5290 = !DILocation(line: 150, column: 35, scope: !1588, inlinedAt: !4819)
!5291 = !{!5019, !4831, i64 32}
!5292 = !DILocalVariable(name: "d_map", scope: !4818, file: !772, line: 151, type: !1584)
!5293 = !DILocation(line: 0, scope: !4818, inlinedAt: !4819)
!5294 = !DILocation(line: 152, column: 5, scope: !4818, inlinedAt: !4819)
!5295 = !DILocation(line: 153, column: 22, scope: !4818, inlinedAt: !4819)
!5296 = !{i64 0, i64 8, !5283, i64 8, i64 8, !5297, i64 16, i64 8, !5297}
!5297 = !{!4830, !4830, i64 0}
!5298 = !DILocation(line: 153, column: 9, scope: !4818, inlinedAt: !4819)
!5299 = !DILocation(line: 153, column: 5, scope: !4818, inlinedAt: !4819)
!5300 = !DILocation(line: 153, column: 7, scope: !4818, inlinedAt: !4819)
!5301 = !{!5019, !4830, i64 24}
!5302 = !DILocation(line: 154, column: 3, scope: !1588, inlinedAt: !4819)
!5303 = !DILocalVariable(name: "__init", scope: !5304, type: !52, flags: DIFlagArtificial)
!5304 = distinct !DILexicalBlock(scope: !5305, file: !192, line: 101, column: 5)
!5305 = distinct !DILexicalBlock(scope: !4821, file: !192, line: 99, column: 10)
!5306 = !DILocation(line: 0, scope: !5304)
!5307 = !DILocalVariable(name: "__limit", scope: !5304, type: !52, flags: DIFlagArtificial)
!5308 = !DILocation(line: 101, column: 30, scope: !5304)
!5309 = !DILocation(line: 101, column: 31, scope: !5304)
!5310 = !DILocation(line: 0, scope: !4907, inlinedAt: !5311)
!5311 = distinct !DILocation(line: 102, column: 24, scope: !5312)
!5312 = distinct !DILexicalBlock(scope: !5313, file: !192, line: 102, column: 11)
!5313 = distinct !DILexicalBlock(scope: !5314, file: !192, line: 101, column: 39)
!5314 = distinct !DILexicalBlock(scope: !5304, file: !192, line: 101, column: 5)
!5315 = !DILocation(line: 0, scope: !4917, inlinedAt: !5316)
!5316 = distinct !DILocation(line: 48, column: 5, scope: !5317, inlinedAt: !5366)
!5317 = distinct !DILexicalBlock(scope: !5318, file: !433, line: 48, column: 5)
!5318 = distinct !DILexicalBlock(scope: !5319, file: !433, line: 48, column: 5)
!5319 = distinct !DILexicalBlock(scope: !5320, file: !433, line: 48, column: 5)
!5320 = distinct !DILexicalBlock(scope: !5321, file: !433, line: 48, column: 5)
!5321 = distinct !DILexicalBlock(scope: !5322, file: !433, line: 48, column: 5)
!5322 = distinct !DILexicalBlock(scope: !5323, file: !433, line: 48, column: 5)
!5323 = distinct !DILexicalBlock(scope: !5324, file: !433, line: 48, column: 5)
!5324 = distinct !DILexicalBlock(scope: !5325, file: !433, line: 48, column: 5)
!5325 = distinct !DILexicalBlock(scope: !5326, file: !433, line: 48, column: 5)
!5326 = distinct !DISubprogram(name: "decodeOutNgh<asymmetricVertex, BFS_F, (lambda at ./edgeMap_utils.h:124:10)>", linkageName: "_ZN19decode_uncompressed12decodeOutNghI16asymmetricVertex5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEvPT_lRT0_RT1_", scope: !4933, file: !433, line: 46, type: !5327, scopeLine: 46, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !5364, retainedNodes: !5330)
!5327 = !DISubroutineType(types: !5328)
!5328 = !{null, !505, !52, !1181, !5329}
!5329 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1565, size: 64)
!5330 = !{!5331, !5332, !5333, !5334, !5335, !5336, !5342, !5343, !5344, !5345, !5347, !5350, !5353, !5357, !5361}
!5331 = !DILocalVariable(name: "v", arg: 1, scope: !5326, file: !433, line: 46, type: !505)
!5332 = !DILocalVariable(name: "i", arg: 2, scope: !5326, file: !433, line: 46, type: !52)
!5333 = !DILocalVariable(name: "f", arg: 3, scope: !5326, file: !433, line: 46, type: !1181)
!5334 = !DILocalVariable(name: "g", arg: 4, scope: !5326, file: !433, line: 46, type: !5329)
!5335 = !DILocalVariable(name: "d", scope: !5326, file: !433, line: 47, type: !50)
!5336 = !DILocalVariable(name: "__init", scope: !5337, type: !779, flags: DIFlagArtificial)
!5337 = distinct !DILexicalBlock(scope: !5338, file: !433, line: 48, column: 5)
!5338 = distinct !DILexicalBlock(scope: !5339, file: !433, line: 48, column: 5)
!5339 = distinct !DILexicalBlock(scope: !5340, file: !433, line: 48, column: 5)
!5340 = distinct !DILexicalBlock(scope: !5341, file: !433, line: 48, column: 5)
!5341 = distinct !DILexicalBlock(scope: !5326, file: !433, line: 48, column: 5)
!5342 = !DILocalVariable(name: "__limit", scope: !5337, type: !779, flags: DIFlagArtificial)
!5343 = !DILocalVariable(name: "__begin", scope: !5337, type: !779, flags: DIFlagArtificial)
!5344 = !DILocalVariable(name: "__end", scope: !5337, type: !779, flags: DIFlagArtificial)
!5345 = !DILocalVariable(name: "j", scope: !5346, file: !433, line: 48, type: !779)
!5346 = distinct !DILexicalBlock(scope: !5337, file: !433, line: 48, column: 5)
!5347 = !DILocalVariable(name: "ngh", scope: !5348, file: !433, line: 48, type: !50)
!5348 = distinct !DILexicalBlock(scope: !5349, file: !433, line: 48, column: 5)
!5349 = distinct !DILexicalBlock(scope: !5346, file: !433, line: 48, column: 5)
!5350 = !DILocalVariable(name: "m", scope: !5351, file: !433, line: 48, type: !92)
!5351 = distinct !DILexicalBlock(scope: !5352, file: !433, line: 48, column: 5)
!5352 = distinct !DILexicalBlock(scope: !5348, file: !433, line: 48, column: 5)
!5353 = !DILocalVariable(name: "j", scope: !5354, file: !433, line: 48, type: !779)
!5354 = distinct !DILexicalBlock(scope: !5355, file: !433, line: 48, column: 5)
!5355 = distinct !DILexicalBlock(scope: !5356, file: !433, line: 48, column: 5)
!5356 = distinct !DILexicalBlock(scope: !5340, file: !433, line: 48, column: 5)
!5357 = !DILocalVariable(name: "ngh", scope: !5358, file: !433, line: 48, type: !50)
!5358 = distinct !DILexicalBlock(scope: !5359, file: !433, line: 48, column: 5)
!5359 = distinct !DILexicalBlock(scope: !5360, file: !433, line: 48, column: 5)
!5360 = distinct !DILexicalBlock(scope: !5354, file: !433, line: 48, column: 5)
!5361 = !DILocalVariable(name: "m", scope: !5362, file: !433, line: 48, type: !92)
!5362 = distinct !DILexicalBlock(scope: !5363, file: !433, line: 48, column: 5)
!5363 = distinct !DILexicalBlock(scope: !5358, file: !433, line: 48, column: 5)
!5364 = !{!4972, !1167, !5365}
!5365 = !DITemplateTypeParameter(name: "G", type: !1565)
!5366 = distinct !DILocation(line: 332, column: 5, scope: !5367, inlinedAt: !5377)
!5367 = distinct !DISubprogram(name: "decodeOutNgh<BFS_F, (lambda at ./edgeMap_utils.h:124:10)>", linkageName: "_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEvlRT_RT0_", scope: !506, file: !433, line: 331, type: !5368, scopeLine: 331, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, templateParams: !5371, declaration: !5370, retainedNodes: !5372)
!5368 = !DISubroutineType(types: !5369)
!5369 = !{null, !515, !52, !1181, !5329}
!5370 = !DISubprogram(name: "decodeOutNgh<BFS_F, (lambda at ./edgeMap_utils.h:124:10)>", linkageName: "_ZN16asymmetricVertex12decodeOutNghI5BFS_FZ32get_emdense_forward_nooutput_genIN4pbbs5emptyELi0EEDavEUljbE_EEvlRT_RT0_", scope: !506, file: !433, line: 331, type: !5368, scopeLine: 331, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !5371)
!5371 = !{!1167, !5365}
!5372 = !{!5373, !5374, !5375, !5376}
!5373 = !DILocalVariable(name: "this", arg: 1, scope: !5367, type: !505, flags: DIFlagArtificial | DIFlagObjectPointer)
!5374 = !DILocalVariable(name: "i", arg: 2, scope: !5367, file: !433, line: 331, type: !52)
!5375 = !DILocalVariable(name: "f", arg: 3, scope: !5367, file: !433, line: 331, type: !1181)
!5376 = !DILocalVariable(name: "g", arg: 4, scope: !5367, file: !433, line: 331, type: !5329)
!5377 = distinct !DILocation(line: 103, column: 14, scope: !5378)
!5378 = distinct !DILexicalBlock(scope: !5312, file: !192, line: 102, column: 33)
!5379 = !DILocation(line: 101, column: 5, scope: !5304)
!5380 = !DILocation(line: 0, scope: !5314)
!5381 = !DILocation(line: 0, scope: !4990, inlinedAt: !5382)
!5382 = distinct !DILocation(line: 47, column: 18, scope: !5326, inlinedAt: !5366)
!5383 = !DILocation(line: 0, scope: !4996, inlinedAt: !5384)
!5384 = distinct !DILocation(line: 48, column: 5, scope: !5318, inlinedAt: !5366)
!5385 = !DILocation(line: 0, scope: !5386, inlinedAt: !5366)
!5386 = distinct !DILexicalBlock(scope: !5387, file: !433, line: 48, column: 5)
!5387 = distinct !DILexicalBlock(scope: !5388, file: !433, line: 48, column: 5)
!5388 = distinct !DILexicalBlock(scope: !5324, file: !433, line: 48, column: 5)
!5389 = !DILocation(line: 0, scope: !4996, inlinedAt: !5390)
!5390 = distinct !DILocation(line: 48, column: 5, scope: !5391, inlinedAt: !5366)
!5391 = distinct !DILexicalBlock(scope: !5392, file: !433, line: 48, column: 5)
!5392 = distinct !DILexicalBlock(scope: !5393, file: !433, line: 48, column: 5)
!5393 = distinct !DILexicalBlock(scope: !5386, file: !433, line: 48, column: 5)
!5394 = !DILocation(line: 0, scope: !4917, inlinedAt: !5395)
!5395 = distinct !DILocation(line: 48, column: 5, scope: !5396, inlinedAt: !5366)
!5396 = distinct !DILexicalBlock(scope: !5391, file: !433, line: 48, column: 5)
!5397 = !DILocation(line: 0, scope: !5393, inlinedAt: !5366)
!5398 = !DILocalVariable(name: "__begin", scope: !5304, type: !52, flags: DIFlagArtificial)
!5399 = !DILocalVariable(name: "i", scope: !5314, file: !192, line: 101, type: !52)
!5400 = !DILocation(line: 102, column: 29, scope: !5312)
!5401 = !DILocation(line: 167, column: 51, scope: !4907, inlinedAt: !5311)
!5402 = !DILocation(line: 102, column: 11, scope: !5313)
!5403 = !DILocation(line: 0, scope: !5367, inlinedAt: !5377)
!5404 = !DILocation(line: 0, scope: !5326, inlinedAt: !5366)
!5405 = !DILocation(line: 320, column: 39, scope: !4990, inlinedAt: !5382)
!5406 = !DILocation(line: 0, scope: !5324, inlinedAt: !5366)
!5407 = !DILocation(line: 48, column: 5, scope: !5324, inlinedAt: !5366)
!5408 = !DILocation(line: 103, column: 14, scope: !5378)
!5409 = !DILocation(line: 48, column: 5, scope: !5325, inlinedAt: !5366)
!5410 = !DILocalVariable(name: "j", scope: !5321, file: !433, line: 48, type: !779)
!5411 = !DILocation(line: 0, scope: !5321, inlinedAt: !5366)
!5412 = !DILocation(line: 48, column: 5, scope: !5320, inlinedAt: !5366)
!5413 = !DILocation(line: 48, column: 5, scope: !5321, inlinedAt: !5366)
!5414 = !DILocation(line: 0, scope: !5037, inlinedAt: !5415)
!5415 = distinct !DILocation(line: 34, column: 13, scope: !5049, inlinedAt: !5416)
!5416 = distinct !DILocation(line: 48, column: 5, scope: !5417, inlinedAt: !5366)
!5417 = distinct !DILexicalBlock(scope: !5317, file: !433, line: 48, column: 5)
!5418 = !DILocalVariable(name: "__init", scope: !5386, type: !779, flags: DIFlagArtificial)
!5419 = !DILocalVariable(name: "__limit", scope: !5386, type: !779, flags: DIFlagArtificial)
!5420 = !DILocalVariable(name: "__begin", scope: !5386, type: !779, flags: DIFlagArtificial)
!5421 = !DILocalVariable(name: "__end", scope: !5386, type: !779, flags: DIFlagArtificial)
!5422 = !DILocation(line: 48, column: 5, scope: !5386, inlinedAt: !5366)
!5423 = !DILocation(line: 0, scope: !5037, inlinedAt: !5424)
!5424 = distinct !DILocation(line: 34, column: 13, scope: !5049, inlinedAt: !5425)
!5425 = distinct !DILocation(line: 48, column: 5, scope: !5426, inlinedAt: !5366)
!5426 = distinct !DILexicalBlock(scope: !5396, file: !433, line: 48, column: 5)
!5427 = !DILocalVariable(name: "j", scope: !5393, file: !433, line: 48, type: !779)
!5428 = !DILocation(line: 297, column: 48, scope: !4996, inlinedAt: !5390)
!5429 = !DILocalVariable(name: "ngh", scope: !5391, file: !433, line: 48, type: !50)
!5430 = !DILocation(line: 0, scope: !5391, inlinedAt: !5366)
!5431 = !DILocation(line: 37, column: 40, scope: !4917, inlinedAt: !5395)
!5432 = !DILocation(line: 37, column: 51, scope: !4917, inlinedAt: !5395)
!5433 = !DILocation(line: 48, column: 5, scope: !5391, inlinedAt: !5366)
!5434 = !DILocation(line: 0, scope: !5049, inlinedAt: !5425)
!5435 = !DILocation(line: 0, scope: !5040, inlinedAt: !5424)
!5436 = !DILocation(line: 309, column: 12, scope: !5037, inlinedAt: !5424)
!5437 = !DILocation(line: 48, column: 5, scope: !5426, inlinedAt: !5366)
!5438 = !DILocation(line: 48, column: 5, scope: !5392, inlinedAt: !5366)
!5439 = !DILocation(line: 48, column: 5, scope: !5393, inlinedAt: !5366)
!5440 = distinct !{!5440, !5422, !5422, !4901}
!5441 = !DILocation(line: 297, column: 48, scope: !4996, inlinedAt: !5384)
!5442 = !DILocalVariable(name: "ngh", scope: !5318, file: !433, line: 48, type: !50)
!5443 = !DILocation(line: 0, scope: !5318, inlinedAt: !5366)
!5444 = !DILocation(line: 37, column: 40, scope: !4917, inlinedAt: !5316)
!5445 = !DILocation(line: 37, column: 51, scope: !4917, inlinedAt: !5316)
!5446 = !DILocation(line: 48, column: 5, scope: !5318, inlinedAt: !5366)
!5447 = !DILocation(line: 0, scope: !5049, inlinedAt: !5416)
!5448 = !DILocation(line: 0, scope: !5040, inlinedAt: !5415)
!5449 = !DILocation(line: 309, column: 12, scope: !5037, inlinedAt: !5415)
!5450 = !DILocation(line: 48, column: 5, scope: !5417, inlinedAt: !5366)
!5451 = distinct !{!5451, !5413, !5413}
!5452 = !DILocation(line: 104, column: 7, scope: !5378)
!5453 = !DILocation(line: 105, column: 5, scope: !5313)
!5454 = !DILocation(line: 101, column: 35, scope: !5314)
!5455 = !DILocation(line: 101, column: 30, scope: !5314)
!5456 = !DILocation(line: 101, column: 5, scope: !5314)
!5457 = distinct !{!5457, !5379, !5458, !4901}
!5458 = !DILocation(line: 105, column: 5, scope: !5304)
!5459 = !DILocalVariable(name: "this", arg: 1, scope: !5460, type: !1198, flags: DIFlagArtificial | DIFlagObjectPointer)
!5460 = distinct !DISubprogram(name: "vertexSubsetData", linkageName: "_ZN16vertexSubsetDataIN4pbbs5emptyEEC2Em", scope: !771, file: !772, line: 117, type: !784, scopeLine: 117, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, declaration: !783, retainedNodes: !5461)
!5461 = !{!5459, !5462}
!5462 = !DILocalVariable(name: "_n", arg: 2, scope: !5460, file: !772, line: 117, type: !779)
!5463 = !DILocation(line: 0, scope: !5460, inlinedAt: !5464)
!5464 = distinct !DILocation(line: 106, column: 12, scope: !5305)
!5465 = !DILocation(line: 117, column: 46, scope: !5460, inlinedAt: !5464)
!5466 = !DILocation(line: 117, column: 59, scope: !5460, inlinedAt: !5464)
!5467 = !DILocation(line: 117, column: 53, scope: !5460, inlinedAt: !5464)
!5468 = !DILocation(line: 117, column: 77, scope: !5460, inlinedAt: !5464)
!5469 = !DILocation(line: 108, column: 1, scope: !2998)
