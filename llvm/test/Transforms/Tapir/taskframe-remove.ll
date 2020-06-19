; RUN: opt < %s -task-simplify -S -o - | FileCheck %s
; RUN: opt < %s -passes='task-simplify' -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *> >::_Vector_impl" }
%"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *> >::_Vector_impl" = type { %"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *> >::_Vector_impl_data" }
%"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *> >::_Vector_impl_data" = type { %struct.ompi_request_t**, %struct.ompi_request_t**, %struct.ompi_request_t** }
%struct.ompi_request_t = type opaque
%struct.ompi_predefined_communicator_t = type opaque
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
%struct.ompi_predefined_datatype_t = type opaque
%struct.ompi_predefined_op_t = type opaque
%"struct.std::piecewise_construct_t" = type { i8 }
%struct.ompi_status_public_t = type { i32, i32, i32, i32, i64 }
%struct.ompi_datatype_t = type opaque
%struct.ompi_communicator_t = type opaque
%struct.Box = type { [6 x i32] }
%"struct.miniFE::Parameters" = type <{ i32, i32, i32, i32, i32, i32, float, [4 x i8], %"class.std::__cxx11::basic_string", i32, i32, i32, i32, i32, i32, i32, [4 x i8] }>
%"class.std::__cxx11::basic_string" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", i64, %union.anon }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider" = type { i8* }
%union.anon = type { i64, [8 x i8] }
%"class.std::__cxx11::basic_ostringstream" = type { %"class.std::basic_ostream.base", %"class.std::__cxx11::basic_stringbuf", %"class.std::basic_ios" }
%"class.std::basic_ostream.base" = type { i32 (...)** }
%"class.std::__cxx11::basic_stringbuf" = type { %"class.std::basic_streambuf", i32, %"class.std::__cxx11::basic_string" }
%class.YAML_Doc = type { %class.YAML_Element, %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string" }
%class.YAML_Element = type { %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string", %"class.std::vector.8" }
%"class.std::vector.8" = type { %"struct.std::_Vector_base.9" }
%"struct.std::_Vector_base.9" = type { %"struct.std::_Vector_base<YAML_Element *, std::allocator<YAML_Element *> >::_Vector_impl" }
%"struct.std::_Vector_base<YAML_Element *, std::allocator<YAML_Element *> >::_Vector_impl" = type { %"struct.std::_Vector_base<YAML_Element *, std::allocator<YAML_Element *> >::_Vector_impl_data" }
%"struct.std::_Vector_base<YAML_Element *, std::allocator<YAML_Element *> >::_Vector_impl_data" = type { %class.YAML_Element**, %class.YAML_Element**, %class.YAML_Element** }
%"class.std::allocator.28" = type { i8 }
%"class.miniFE::simple_mesh_description" = type { %"class.std::set", %"class.std::set", %"class.std::map", %struct.Box, %struct.Box }
%"class.std::set" = type { %"class.std::_Rb_tree" }
%"class.std::_Rb_tree" = type { %"struct.std::_Rb_tree<int, int, std::_Identity<int>, std::less<int>, std::allocator<int> >::_Rb_tree_impl" }
%"struct.std::_Rb_tree<int, int, std::_Identity<int>, std::less<int>, std::allocator<int> >::_Rb_tree_impl" = type { %"struct.std::_Rb_tree_key_compare", %"struct.std::_Rb_tree_header" }
%"struct.std::_Rb_tree_key_compare" = type { %"struct.std::less" }
%"struct.std::less" = type { i8 }
%"struct.std::_Rb_tree_header" = type { %"struct.std::_Rb_tree_node_base", i64 }
%"struct.std::_Rb_tree_node_base" = type { i32, %"struct.std::_Rb_tree_node_base"*, %"struct.std::_Rb_tree_node_base"*, %"struct.std::_Rb_tree_node_base"* }
%"class.std::map" = type { %"class.std::_Rb_tree.17" }
%"class.std::_Rb_tree.17" = type { %"struct.std::_Rb_tree<int, std::pair<const int, int>, std::_Select1st<std::pair<const int, int> >, std::less<int>, std::allocator<std::pair<const int, int> > >::_Rb_tree_impl" }
%"struct.std::_Rb_tree<int, std::pair<const int, int>, std::_Select1st<std::pair<const int, int> >, std::less<int>, std::allocator<std::pair<const int, int> > >::_Rb_tree_impl" = type { %"struct.std::_Rb_tree_key_compare", %"struct.std::_Rb_tree_header" }
%"struct.miniFE::CSRMatrix" = type { i8, %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.26", i32, %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.21", %"class.std::vector.26", %"class.std::vector" }
%"class.std::vector.21" = type { %"struct.std::_Vector_base.22" }
%"struct.std::_Vector_base.22" = type { %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl" }
%"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl" = type { %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data" }
%"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data" = type { i32*, i32*, i32* }
%"class.std::vector.26" = type { %"struct.std::_Vector_base.27" }
%"struct.std::_Vector_base.27" = type { %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl" }
%"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl" = type { %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl_data" }
%"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl_data" = type { double*, double*, double* }
%"struct.miniFE::Vector" = type { i32, i32, %"class.std::vector.26" }
%"class.std::allocator.0" = type { i8 }
%"class.std::allocator.23" = type { i8 }
%"class.__gnu_cxx::new_allocator.24" = type { i8 }
%"class.__gnu_cxx::new_allocator.29" = type { i8 }
%"class.std::allocator" = type { i8 }
%"class.__gnu_cxx::new_allocator" = type { i8 }
%"class.__gnu_cxx::new_allocator.1" = type { i8 }
%"struct.std::_Rb_tree_node" = type { %"struct.std::_Rb_tree_node_base", %"struct.__gnu_cxx::__aligned_membuf" }
%"struct.__gnu_cxx::__aligned_membuf" = type { [8 x i8] }
%"class.__gnu_cxx::new_allocator.19" = type { i8 }
%"struct.std::_Rb_tree_node.60" = type <{ %"struct.std::_Rb_tree_node_base", %"struct.__gnu_cxx::__aligned_membuf.61", [4 x i8] }>
%"struct.__gnu_cxx::__aligned_membuf.61" = type { [4 x i8] }
%"class.__gnu_cxx::new_allocator.15" = type { i8 }
%struct.tm = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i64, i8* }
%struct.ompi_op_t = type opaque
%"class.std::vector.32" = type { %"struct.std::_Vector_base.33" }
%"struct.std::_Vector_base.33" = type { %"struct.std::_Vector_base<float, std::allocator<float> >::_Vector_impl" }
%"struct.std::_Vector_base<float, std::allocator<float> >::_Vector_impl" = type { %"struct.std::_Vector_base<float, std::allocator<float> >::_Vector_impl_data" }
%"struct.std::_Vector_base<float, std::allocator<float> >::_Vector_impl_data" = type { float*, float*, float* }
%"class.std::allocator.34" = type { i8 }
%"struct.std::pair" = type { i32, i32 }
%"struct.std::pair.44" = type { i32, i64 }
%"class.std::runtime_error" = type { %"class.std::exception", %"struct.std::__cow_string" }
%"class.std::exception" = type { i32 (...)** }
%"struct.std::__cow_string" = type { %union.anon.63 }
%union.anon.63 = type { i8* }
%struct.MatrixInitOp = type { i32*, i32*, i32*, i32, i32, i32, i32, i32*, i32*, i32*, double*, i32, %"class.miniFE::simple_mesh_description"* }
%"struct.__gnu_cxx::__ops::_Iter_less_iter" = type { i8 }
%"class.std::tuple" = type { %"struct.std::_Tuple_impl" }
%"struct.std::_Tuple_impl" = type { %"struct.std::_Head_base" }
%"struct.std::_Head_base" = type { i32* }
%"class.std::tuple.64" = type { i8 }
%"struct.miniFE::matvec_overlap" = type { i8 }
%struct.__cilkrts_hyperobject_base = type { %struct.cilk_c_monoid, i32, i64, i64 }
%struct.cilk_c_monoid = type { void (i8*, i8*, i8*)*, void (i8*, i8*)*, void (i8*, i8*)*, i8* (i8*, i64)*, void (i8*, i8*)* }

$_ZN6miniFE6driverIdiiEEvRK3BoxRS1_RNS_10ParametersER8YAML_Doc = comdat any

@_ZStL8__ioinit = external dso_local global %"class.std::ios_base::Init", align 1
@__dso_handle = external hidden global i8
@_ZN6miniFEL17exch_ext_requestsE = external dso_local global %"class.std::vector", align 8
@_ZN6miniFEL4NONEE = external dso_local constant i32, align 4
@_ZN6miniFEL5UPPERE = external dso_local constant i32, align 4
@.str = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.2 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.3 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.4 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.5 = external dso_local unnamed_addr constant [1 x i8], align 1
@.str.6 = external dso_local unnamed_addr constant [7 x i8], align 1
@.str.7 = external dso_local unnamed_addr constant [4 x i8], align 1
@.str.8 = external dso_local unnamed_addr constant [19 x i8], align 1
@.str.9 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.10 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.11 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.12 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.13 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.14 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.15 = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.16 = external dso_local unnamed_addr constant [21 x i8], align 1
@.str.17 = external dso_local unnamed_addr constant [7 x i8], align 1
@.str.18 = external dso_local unnamed_addr constant [21 x i8], align 1
@.str.19 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.20 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.21 = external dso_local unnamed_addr constant [29 x i8], align 1
@.str.22 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.23 = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.24 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.25 = external dso_local unnamed_addr constant [24 x i8], align 1
@.str.26 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.27 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.28 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.29 = external dso_local unnamed_addr constant [4 x i8], align 1
@.str.30 = external dso_local unnamed_addr constant [32 x i8], align 1
@.str.31 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.32 = external dso_local unnamed_addr constant [110 x i8], align 1
@.str.33 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.34 = external dso_local unnamed_addr constant [25 x i8], align 1
@.str.35 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.36 = external dso_local unnamed_addr constant [4 x i8], align 1
@.str.37 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.38 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.39 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.40 = external dso_local unnamed_addr constant [14 x i8], align 1
@_ZTVNSt7__cxx1119basic_ostringstreamIcSt11char_traitsIcESaIcEEE = external dso_local unnamed_addr constant { [5 x i8*], [5 x i8*] }, align 8
@_ZTTNSt7__cxx1119basic_ostringstreamIcSt11char_traitsIcESaIcEEE = external unnamed_addr constant [4 x i8*], align 8
@_ZTVSt9basic_iosIcSt11char_traitsIcEE = external dso_local unnamed_addr constant { [4 x i8*] }, align 8
@_ZTVNSt7__cxx1115basic_stringbufIcSt11char_traitsIcESaIcEEE = external dso_local unnamed_addr constant { [16 x i8*] }, align 8
@_ZTVSt15basic_streambufIcSt11char_traitsIcEE = external dso_local unnamed_addr constant { [16 x i8*] }, align 8
@.str.41 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.42 = external dso_local unnamed_addr constant [55 x i8], align 1
@.str.43 = external dso_local unnamed_addr constant [49 x i8], align 1
@.str.44 = external dso_local unnamed_addr constant [42 x i8], align 1
@ompi_mpi_comm_world = external dso_local global %struct.ompi_predefined_communicator_t, align 1
@_ZSt4cout = external dso_local global %"class.std::basic_ostream", align 8
@.str.45 = external dso_local unnamed_addr constant [25 x i8], align 1
@.str.46 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.47 = external dso_local unnamed_addr constant [31 x i8], align 1
@.str.48 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.49 = external dso_local unnamed_addr constant [28 x i8], align 1
@.str.50 = external dso_local unnamed_addr constant [19 x i8], align 1
@.str.51 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.52 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.53 = external dso_local unnamed_addr constant [25 x i8], align 1
@.str.54 = external dso_local unnamed_addr constant [31 x i8], align 1
@.str.55 = external dso_local unnamed_addr constant [24 x i8], align 1
@.str.56 = external dso_local unnamed_addr constant [19 x i8], align 1
@.str.58 = external dso_local unnamed_addr constant [44 x i8], align 1
@.str.59 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.60 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.61 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.62 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.63 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.64 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.65 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.66 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.67 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.68 = external dso_local unnamed_addr constant [4 x i8], align 1
@.str.69 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.70 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.71 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.72 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.73 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.74 = external dso_local unnamed_addr constant [14 x i8], align 1
@.str.75 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.76 = external dso_local unnamed_addr constant [14 x i8], align 1
@.str.77 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.78 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.79 = external dso_local unnamed_addr constant [19 x i8], align 1
@ompi_mpi_int = external dso_local global %struct.ompi_predefined_datatype_t, align 1
@ompi_mpi_op_sum = external dso_local global %struct.ompi_predefined_op_t, align 1
@ompi_mpi_op_max = external dso_local global %struct.ompi_predefined_op_t, align 1
@.str.80 = external dso_local unnamed_addr constant [29 x i8], align 1
@.str.81 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.82 = external dso_local unnamed_addr constant [12 x i8], align 1
@ompi_mpi_float = external dso_local global %struct.ompi_predefined_datatype_t, align 1
@.str.83 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.84 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.85 = external dso_local unnamed_addr constant [31 x i8], align 1
@.str.86 = external dso_local unnamed_addr constant [14 x i8], align 1
@.str.87 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.88 = external dso_local unnamed_addr constant [26 x i8], align 1
@.str.89 = external dso_local unnamed_addr constant [26 x i8], align 1
@.str.90 = external dso_local unnamed_addr constant [32 x i8], align 1
@.str.91 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.92 = external dso_local unnamed_addr constant [24 x i8], align 1
@.str.93 = external dso_local unnamed_addr constant [50 x i8], align 1
@_ZTISt9exception = external dso_local constant i8*
@.str.94 = external dso_local unnamed_addr constant [100 x i8], align 1
@.str.95 = external dso_local unnamed_addr constant [3 x i8], align 1
@_ZTISt13runtime_error = external dso_local constant i8*
@.str.96 = external dso_local unnamed_addr constant [54 x i8], align 1
@.str.97 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.98 = external dso_local unnamed_addr constant [89 x i8], align 1
@.str.99 = external dso_local unnamed_addr constant [32 x i8], align 1
@.str.100 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.101 = external dso_local unnamed_addr constant [24 x i8], align 1
@.str.102 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.103 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.104 = external dso_local unnamed_addr constant [49 x i8], align 1
@_ZSt4cerr = external dso_local global %"class.std::basic_ostream", align 8
@.str.105 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.106 = external dso_local unnamed_addr constant [38 x i8], align 1
@.str.107 = external dso_local unnamed_addr constant [24 x i8], align 1
@__PRETTY_FUNCTION__._ZN6miniFE17make_local_matrixINS_9CSRMatrixIdiiEEEEvRT_ = external dso_local unnamed_addr constant [96 x i8], align 1
@_ZStL19piecewise_construct = external dso_local constant %"struct.std::piecewise_construct_t", align 1
@.str.108 = external dso_local unnamed_addr constant [23 x i8], align 1
@.str.109 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.110 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.111 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.112 = external dso_local unnamed_addr constant [19 x i8], align 1
@.str.113 = external dso_local unnamed_addr constant [25 x i8], align 1
@.str.114 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.115 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.116 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.117 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.118 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.119 = external dso_local unnamed_addr constant [17 x i8], align 1
@ompi_mpi_double = external dso_local global %struct.ompi_predefined_datatype_t, align 1
@.str.120 = external dso_local unnamed_addr constant [93 x i8], align 1
@.str.121 = external dso_local unnamed_addr constant [79 x i8], align 1
@.str.122 = external dso_local unnamed_addr constant [20 x i8], align 1
@.str.123 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.124 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.125 = external dso_local unnamed_addr constant [45 x i8], align 1
@.str.127 = external dso_local unnamed_addr constant [140 x i8], align 1
@.str.128 = external dso_local unnamed_addr constant [82 x i8], align 1
@__PRETTY_FUNCTION__._ZN4cilk8internal15reducer_contentINS_6op_addIdLb1EEELb1EEC2Ev = external dso_local unnamed_addr constant [139 x i8], align 1
@.str.129 = external dso_local unnamed_addr constant [23 x i8], align 1
@.str.130 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.131 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.132 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.133 = external dso_local unnamed_addr constant [4 x i8], align 1
@.str.134 = external dso_local unnamed_addr constant [23 x i8], align 1
@.str.135 = external dso_local unnamed_addr constant [23 x i8], align 1
@.str.136 = external dso_local unnamed_addr constant [46 x i8], align 1
@.str.137 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.138 = external dso_local unnamed_addr constant [7 x i8], align 1
@.str.139 = external dso_local unnamed_addr constant [4 x i8], align 1
@llvm.global_ctors = external global [1 x { i32, void ()*, i8* }]

declare dso_local void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"*) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init"*) unnamed_addr #1

; Function Attrs: nofree nounwind
declare dso_local i32 @__cxa_atexit(void (i8*)*, i8*, i8*) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

declare dso_local i32 @MPI_Wait(%struct.ompi_request_t**, %struct.ompi_status_public_t*) local_unnamed_addr #0

declare dso_local i32 @MPI_Send(i8*, i32, %struct.ompi_datatype_t*, i32, i32, %struct.ompi_communicator_t*) local_unnamed_addr #0

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #4

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #5

; Function Attrs: nounwind uwtable
declare dso_local zeroext i1 @_ZN6miniFE11is_neighborERK3BoxS2_(%struct.Box* dereferenceable(24), %struct.Box* dereferenceable(24)) local_unnamed_addr #6

; Function Attrs: nounwind uwtable
declare dso_local void @_ZNSt6vectorIP14ompi_request_tSaIS1_EED2Ev(%"class.std::vector"*) unnamed_addr #6 align 2

; Function Attrs: nounwind uwtable
declare dso_local i64 @_ZN6miniFE18decide_how_to_growERK3BoxS2_(%struct.Box* dereferenceable(24), %struct.Box* dereferenceable(24)) local_unnamed_addr #6

; Function Attrs: nounwind uwtable
declare dso_local i64 @_ZN6miniFE20decide_how_to_shrinkERK3BoxS2_(%struct.Box* dereferenceable(24), %struct.Box* dereferenceable(24)) local_unnamed_addr #6

; Function Attrs: norecurse uwtable
declare dso_local i32 @main(i32, i8**) local_unnamed_addr #7

declare dso_local void @_ZN6miniFE14get_parametersEiPPcRNS_10ParametersE(i32, i8**, %"struct.miniFE::Parameters"* dereferenceable(96)) local_unnamed_addr #0

declare dso_local void @_ZN6miniFE14initialize_mpiEiPPcRiS2_(i32, i8**, i32* dereferenceable(4), i32* dereferenceable(4)) local_unnamed_addr #0

declare dso_local double @_ZN6miniFE7mytimerEv() local_unnamed_addr #0

declare dso_local void @_ZN6miniFE20broadcast_parametersERNS_10ParametersE(%"struct.miniFE::Parameters"* dereferenceable(96)) local_unnamed_addr #0

declare dso_local void @_Z13box_partitioniiiRK3BoxPS_(i32, i32, i32, %struct.Box* dereferenceable(24), %struct.Box*) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZNSt7__cxx1119basic_ostringstreamIcSt11char_traitsIcESaIcEEC1Ev(%"class.std::__cxx11::basic_ostringstream"*) unnamed_addr #8 align 2

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSolsEi(%"class.std::basic_ostream"*, i32) local_unnamed_addr #0

declare dso_local void @_ZN8YAML_DocC1ERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_S7_S7_(%class.YAML_Doc*, %"class.std::__cxx11::basic_string"* dereferenceable(32), %"class.std::__cxx11::basic_string"* dereferenceable(32), %"class.std::__cxx11::basic_string"* dereferenceable(32), %"class.std::__cxx11::basic_string"* dereferenceable(32)) unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_Z18add_params_to_yamlR8YAML_DocRN6miniFE10ParametersE(%class.YAML_Doc* dereferenceable(216), %"struct.miniFE::Parameters"* nocapture readonly dereferenceable(96)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z25add_configuration_to_yamlR8YAML_Docii(%class.YAML_Doc* dereferenceable(216), i32, i32) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_Z22add_timestring_to_yamlR8YAML_Doc(%class.YAML_Doc* dereferenceable(216)) local_unnamed_addr #8

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN6miniFE6driverIdiiEEvRK3BoxRS1_RNS_10ParametersER8YAML_Doc(%struct.Box* dereferenceable(24) %global_box, %struct.Box* dereferenceable(24) %my_box, %"struct.miniFE::Parameters"* dereferenceable(96) %params, %class.YAML_Doc* dereferenceable(216) %ydoc) local_unnamed_addr #8 comdat personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK: define {{.*}}void @_ZN6miniFE6driverIdiiEEvRK3BoxRS1_RNS_10ParametersER8YAML_Doc
; CHECK-NOT: call token @llvm.taskframe.create()
; CHECK-NOT: invoke void @llvm.taskframe.resume.sl_p0i8i32s
entry:
  %__first.addr.i.i.i.i.i2582 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2583 = alloca i8, align 1
  %__dnew.i.i.i.i2584 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2553 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2554 = alloca i8, align 1
  %__dnew.i.i.i.i2555 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2488 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2489 = alloca i8, align 1
  %__dnew.i.i.i.i2490 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2459 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2460 = alloca i8, align 1
  %__dnew.i.i.i.i2461 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2403 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2404 = alloca i8, align 1
  %__dnew.i.i.i.i2405 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2374 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2375 = alloca i8, align 1
  %__dnew.i.i.i.i2376 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2345 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2346 = alloca i8, align 1
  %__dnew.i.i.i.i2347 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2298 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2299 = alloca i8, align 1
  %__dnew.i.i.i.i2300 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2269 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2270 = alloca i8, align 1
  %__dnew.i.i.i.i2271 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2240 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2241 = alloca i8, align 1
  %__dnew.i.i.i.i2242 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2202 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2203 = alloca i8, align 1
  %__dnew.i.i.i.i2204 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2137 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2138 = alloca i8, align 1
  %__dnew.i.i.i.i2139 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2108 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2109 = alloca i8, align 1
  %__dnew.i.i.i.i2110 = alloca i64, align 8
  %__first.addr.i.i.i.i.i2025 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i2026 = alloca i8, align 1
  %__dnew.i.i.i.i2027 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1978 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1979 = alloca i8, align 1
  %__dnew.i.i.i.i1980 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1931 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1932 = alloca i8, align 1
  %__dnew.i.i.i.i1933 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1902 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1903 = alloca i8, align 1
  %__dnew.i.i.i.i1904 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1819 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1820 = alloca i8, align 1
  %__dnew.i.i.i.i1821 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1790 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1791 = alloca i8, align 1
  %__dnew.i.i.i.i1792 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1701 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1702 = alloca i8, align 1
  %__dnew.i.i.i.i1703 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1663 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1664 = alloca i8, align 1
  %__dnew.i.i.i.i1665 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1625 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1626 = alloca i8, align 1
  %__dnew.i.i.i.i1627 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1560 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1561 = alloca i8, align 1
  %__dnew.i.i.i.i1562 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1531 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1532 = alloca i8, align 1
  %__dnew.i.i.i.i1533 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1439 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1440 = alloca i8, align 1
  %__dnew.i.i.i.i1441 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1390 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1391 = alloca i8, align 1
  %__dnew.i.i.i.i1392 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1352 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1353 = alloca i8, align 1
  %__dnew.i.i.i.i1354 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1172 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1173 = alloca i8, align 1
  %__dnew.i.i.i.i1174 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1117 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1118 = alloca i8, align 1
  %__dnew.i.i.i.i1119 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1079 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1080 = alloca i8, align 1
  %__dnew.i.i.i.i1081 = alloca i64, align 8
  %__first.addr.i.i.i.i.i1006 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i1007 = alloca i8, align 1
  %__dnew.i.i.i.i1008 = alloca i64, align 8
  %__first.addr.i.i.i.i.i977 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i978 = alloca i8, align 1
  %__dnew.i.i.i.i979 = alloca i64, align 8
  %__first.addr.i.i.i.i.i948 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i949 = alloca i8, align 1
  %__dnew.i.i.i.i950 = alloca i64, align 8
  %__first.addr.i.i.i.i.i892 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i893 = alloca i8, align 1
  %__dnew.i.i.i.i894 = alloca i64, align 8
  %__first.addr.i.i.i.i.i846 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i847 = alloca i8, align 1
  %__dnew.i.i.i.i848 = alloca i64, align 8
  %__first.addr.i.i.i.i.i817 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i818 = alloca i8, align 1
  %__dnew.i.i.i.i819 = alloca i64, align 8
  %__first.addr.i.i.i.i.i761 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i762 = alloca i8, align 1
  %__dnew.i.i.i.i763 = alloca i64, align 8
  %__first.addr.i.i.i.i.i732 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i733 = alloca i8, align 1
  %__dnew.i.i.i.i734 = alloca i64, align 8
  %__first.addr.i.i.i.i.i703 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i704 = alloca i8, align 1
  %__dnew.i.i.i.i705 = alloca i64, align 8
  %__first.addr.i.i.i.i.i657 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i658 = alloca i8, align 1
  %__dnew.i.i.i.i659 = alloca i64, align 8
  %__first.addr.i.i.i.i.i382 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i383 = alloca i8, align 1
  %__dnew.i.i.i.i384 = alloca i64, align 8
  %__first.addr.i.i.i.i.i353 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i354 = alloca i8, align 1
  %__dnew.i.i.i.i355 = alloca i64, align 8
  %__first.addr.i.i.i.i.i306 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i307 = alloca i8, align 1
  %__dnew.i.i.i.i308 = alloca i64, align 8
  %__first.addr.i.i.i.i.i277 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i278 = alloca i8, align 1
  %__dnew.i.i.i.i279 = alloca i64, align 8
  %__first.addr.i.i.i.i.i230 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i231 = alloca i8, align 1
  %__dnew.i.i.i.i232 = alloca i64, align 8
  %__first.addr.i.i.i.i.i201 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i202 = alloca i8, align 1
  %__dnew.i.i.i.i203 = alloca i64, align 8
  %__first.addr.i.i.i.i.i144 = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i145 = alloca i8, align 1
  %__dnew.i.i.i.i146 = alloca i64, align 8
  %__first.addr.i.i.i.i.i = alloca i8*, align 8
  %ref.tmp.i.i.i.i.i = alloca i8, align 1
  %__dnew.i.i.i.i = alloca i64, align 8
  %ref.tmp.i68 = alloca %"class.std::allocator.28", align 1
  %ref.tmp.i = alloca %"class.std::allocator.28", align 1
  %syncreg.i = tail call token @llvm.syncregion.start()
  %numprocs = alloca i32, align 4
  %myproc = alloca i32, align 4
  %largest_imbalance = alloca float, align 4
  %std_dev = alloca float, align 4
  %mesh = alloca %"class.miniFE::simple_mesh_description", align 8
  %A = alloca %"struct.miniFE::CSRMatrix", align 8
  %b = alloca %"struct.miniFE::Vector", align 8
  %x = alloca %"struct.miniFE::Vector", align 8
  %ref.tmp = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp111 = alloca %"class.std::allocator.0", align 1
  %ref.tmp114 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp115 = alloca %"class.std::allocator.0", align 1
  %ref.tmp127 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp128 = alloca %"class.std::allocator.0", align 1
  %ref.tmp134 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp135 = alloca %"class.std::allocator.0", align 1
  %ref.tmp149 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp150 = alloca %"class.std::allocator.0", align 1
  %ref.tmp153 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp154 = alloca %"class.std::allocator.0", align 1
  %ref.tmp168 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp169 = alloca %"class.std::allocator.0", align 1
  %ref.tmp175 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp176 = alloca %"class.std::allocator.0", align 1
  %num_iters = alloca i32, align 4
  %rnorm = alloca double, align 8
  %tol = alloca double, align 8
  %cg_times = alloca [5 x double], align 16
  %title = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp358 = alloca %"class.std::allocator.0", align 1
  %ref.tmp365 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp366 = alloca %"class.std::allocator.0", align 1
  %ref.tmp372 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp373 = alloca %"class.std::allocator.0", align 1
  %ref.tmp376 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp380 = alloca %"class.std::allocator.0", align 1
  %ref.tmp398 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp399 = alloca %"class.std::allocator.0", align 1
  %ref.tmp405 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp406 = alloca %"class.std::allocator.0", align 1
  %ref.tmp409 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp413 = alloca %"class.std::allocator.0", align 1
  %ref.tmp431 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp432 = alloca %"class.std::allocator.0", align 1
  %ref.tmp438 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp439 = alloca %"class.std::allocator.0", align 1
  %ref.tmp442 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp446 = alloca %"class.std::allocator.0", align 1
  %ref.tmp464 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp465 = alloca %"class.std::allocator.0", align 1
  %ref.tmp478 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp479 = alloca %"class.std::allocator.0", align 1
  %ref.tmp491 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp492 = alloca %"class.std::allocator.0", align 1
  %ref.tmp551 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp552 = alloca %"class.std::allocator.0", align 1
  %ref.tmp565 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp566 = alloca %"class.std::allocator.0", align 1
  %ref.tmp580 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp581 = alloca %"class.std::allocator.0", align 1
  %ref.tmp594 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp595 = alloca %"class.std::allocator.0", align 1
  %ref.tmp598 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp599 = alloca %"class.std::allocator.0", align 1
  %ref.tmp616 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp617 = alloca %"class.std::allocator.0", align 1
  %ref.tmp630 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp631 = alloca %"class.std::allocator.0", align 1
  %ref.tmp645 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp646 = alloca %"class.std::allocator.0", align 1
  %ref.tmp659 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp660 = alloca %"class.std::allocator.0", align 1
  %ref.tmp663 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp664 = alloca %"class.std::allocator.0", align 1
  %ref.tmp681 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp682 = alloca %"class.std::allocator.0", align 1
  %ref.tmp695 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp696 = alloca %"class.std::allocator.0", align 1
  %ref.tmp710 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp711 = alloca %"class.std::allocator.0", align 1
  %ref.tmp724 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp725 = alloca %"class.std::allocator.0", align 1
  %ref.tmp728 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp729 = alloca %"class.std::allocator.0", align 1
  %ref.tmp746 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp747 = alloca %"class.std::allocator.0", align 1
  %ref.tmp750 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp751 = alloca %"class.std::allocator.0", align 1
  %ref.tmp767 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp768 = alloca %"class.std::allocator.0", align 1
  %ref.tmp774 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp775 = alloca %"class.std::allocator.0", align 1
  %ref.tmp792 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp793 = alloca %"class.std::allocator.0", align 1
  %ref.tmp799 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp800 = alloca %"class.std::allocator.0", align 1
  %ref.tmp818 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp819 = alloca %"class.std::allocator.0", align 1
  %ref.tmp825 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp826 = alloca %"class.std::allocator.0", align 1
  %ref.tmp843 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp844 = alloca %"class.std::allocator.0", align 1
  %ref.tmp850 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp851 = alloca %"class.std::allocator.0", align 1
  %ref.tmp854 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp855 = alloca %"class.std::allocator.0", align 1
  %ref.tmp876 = alloca %"class.std::__cxx11::basic_string", align 8
  %ref.tmp877 = alloca %"class.std::allocator.0", align 1
  %arrayidx.i = getelementptr inbounds %struct.Box, %struct.Box* %global_box, i64 0, i32 0, i64 0
  %arrayidx = getelementptr inbounds i32, i32* %arrayidx.i, i64 1
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !2
  %arrayidx.i1 = getelementptr inbounds %struct.Box, %struct.Box* %global_box, i64 0, i32 0, i64 2
  %arrayidx2 = getelementptr inbounds i32, i32* %arrayidx.i1, i64 1
  %1 = load i32, i32* %arrayidx2, align 4, !tbaa !2
  %arrayidx.i2 = getelementptr inbounds %struct.Box, %struct.Box* %global_box, i64 0, i32 0, i64 4
  %arrayidx4 = getelementptr inbounds i32, i32* %arrayidx.i2, i64 1
  %2 = load i32, i32* %arrayidx4, align 4, !tbaa !2
  %3 = bitcast i32* %numprocs to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #19
  store i32 1, i32* %numprocs, align 4, !tbaa !2
  %4 = bitcast i32* %myproc to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %4) #19
  store i32 0, i32* %myproc, align 4, !tbaa !2
  %call5 = call i32 @MPI_Comm_size(%struct.ompi_communicator_t* bitcast (%struct.ompi_predefined_communicator_t* @ompi_mpi_comm_world to %struct.ompi_communicator_t*), i32* nonnull %numprocs)
  %call6 = call i32 @MPI_Comm_rank(%struct.ompi_communicator_t* bitcast (%struct.ompi_predefined_communicator_t* @ompi_mpi_comm_world to %struct.ompi_communicator_t*), i32* nonnull %myproc)
  %load_imbalance = getelementptr inbounds %"struct.miniFE::Parameters", %"struct.miniFE::Parameters"* %params, i64 0, i32 6
  %5 = load float, float* %load_imbalance, align 8, !tbaa !6
  %cmp = fcmp ogt float %5, 0.000000e+00
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @_ZN6miniFE13add_imbalanceIiEEvRK3BoxRS1_fR8YAML_Doc(%struct.Box* nonnull dereferenceable(24) %global_box, %struct.Box* nonnull dereferenceable(24) %my_box, float %5, %class.YAML_Doc* nonnull dereferenceable(216) %ydoc)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %6 = bitcast float* %largest_imbalance to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %6) #19
  store float 0.000000e+00, float* %largest_imbalance, align 4, !tbaa !13
  %7 = bitcast float* %std_dev to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %7) #19
  store float 0.000000e+00, float* %std_dev, align 4, !tbaa !13
  call void @_ZN6miniFE17compute_imbalanceIiEEvRK3BoxS3_RfS4_R8YAML_Docb(%struct.Box* nonnull dereferenceable(24) %global_box, %struct.Box* nonnull dereferenceable(24) %my_box, float* nonnull dereferenceable(4) %largest_imbalance, float* nonnull dereferenceable(4) %std_dev, %class.YAML_Doc* nonnull dereferenceable(216) %ydoc, i1 zeroext true)
  %8 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp8 = icmp eq i32 %8, 0
  br i1 %cmp8, label %if.then9, label %if.end13

if.then9:                                         ; preds = %if.end
  %vtable = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8**), align 8, !tbaa !14
  %vbase.offset.ptr = getelementptr i8, i8* %vtable, i64 -24
  %9 = bitcast i8* %vbase.offset.ptr to i64*
  %vbase.offset = load i64, i64* %9, align 8
  %add.ptr = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8*), i64 %vbase.offset
  %10 = bitcast i8* %add.ptr to %"class.std::ios_base"*
  %_M_width.i = getelementptr inbounds %"class.std::ios_base", %"class.std::ios_base"* %10, i64 0, i32 2
  %11 = load i64, i64* %_M_width.i, align 8, !tbaa !16
  store i64 30, i64* %_M_width.i, align 8, !tbaa !16
  %call.i.i = call i64 @strlen(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.45, i64 0, i64 0)) #19
  %call1.i = call dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([25 x i8], [25 x i8]* @.str.45, i64 0, i64 0), i64 %call.i.i)
  %call12 = call dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull @_ZSt4cout)
  br label %if.end13

if.end13:                                         ; preds = %if.then9, %if.end
  %call14 = call double @_ZN6miniFE7mytimerEv()
  %call15 = call double @_ZN6miniFE7mytimerEv()
  %12 = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 192, i8* nonnull %12) #19
  call void @_ZN6miniFE23simple_mesh_descriptionIiEC2ERK3BoxS4_(%"class.miniFE::simple_mesh_description"* nonnull %mesh, %struct.Box* nonnull dereferenceable(24) %global_box, %struct.Box* nonnull dereferenceable(24) %my_box)
  %call16 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %if.end13
  %sub = fsub double %call16, %call15
  %call19 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont18 unwind label %lpad17

invoke.cont18:                                    ; preds = %invoke.cont
  %sub20 = fsub double %call19, %call14
  %13 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp21 = icmp eq i32 %13, 0
  br i1 %cmp21, label %if.then22, label %if.end31

if.then22:                                        ; preds = %invoke.cont18
  %call.i3 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* @_ZSt4cout, double %sub)
          to label %invoke.cont23 unwind label %lpad17

invoke.cont23:                                    ; preds = %if.then22
  %call.i.i4 = call i64 @strlen(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0)) #19
  %call1.i56 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i3, i8* nonnull getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0), i64 %call.i.i4)
          to label %invoke.cont25 unwind label %lpad17

invoke.cont25:                                    ; preds = %invoke.cont23
  %call.i7 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* %call.i3, double %sub20)
          to label %invoke.cont27 unwind label %lpad17

invoke.cont27:                                    ; preds = %invoke.cont25
  %14 = bitcast %"class.std::basic_ostream"* %call.i7 to i8**
  %vtable.i = load i8*, i8** %14, align 8, !tbaa !14
  %vbase.offset.ptr.i = getelementptr i8, i8* %vtable.i, i64 -24
  %15 = bitcast i8* %vbase.offset.ptr.i to i64*
  %vbase.offset.i = load i64, i64* %15, align 8
  %16 = bitcast %"class.std::basic_ostream"* %call.i7 to i8*
  %add.ptr.i = getelementptr inbounds i8, i8* %16, i64 %vbase.offset.i
  %17 = bitcast i8* %add.ptr.i to %"class.std::basic_ios"*
  %_M_ctype.i = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %17, i64 0, i32 5
  %18 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i, align 8, !tbaa !22
  %tobool.i.i = icmp eq %"class.std::ctype"* %18, null
  br i1 %tobool.i.i, label %if.then.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i

if.then.i.i:                                      ; preds = %invoke.cont27
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc unwind label %lpad17

.noexc:                                           ; preds = %if.then.i.i
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i:  ; preds = %invoke.cont27
  %_M_widen_ok.i.i = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %18, i64 0, i32 8
  %19 = load i8, i8* %_M_widen_ok.i.i, align 8, !tbaa !25
  %tobool.i1.i = icmp eq i8 %19, 0
  br i1 %tobool.i1.i, label %if.end.i.i, label %if.then.i2.i

if.then.i2.i:                                     ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i
  %arrayidx.i.i = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %18, i64 0, i32 9, i64 10
  %20 = load i8, i8* %arrayidx.i.i, align 1, !tbaa !27
  br label %call.i.noexc

if.end.i.i:                                       ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %18)
          to label %.noexc18 unwind label %lpad17

.noexc18:                                         ; preds = %if.end.i.i
  %21 = bitcast %"class.std::ctype"* %18 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %21, align 8, !tbaa !14
  %vfn.i.i = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i, i64 6
  %22 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i, align 8
  %call.i.i1719 = invoke signext i8 %22(%"class.std::ctype"* nonnull %18, i8 signext 10)
          to label %call.i.noexc unwind label %lpad17

call.i.noexc:                                     ; preds = %.noexc18, %if.then.i2.i
  %retval.0.i.i = phi i8 [ %20, %if.then.i2.i ], [ %call.i.i1719, %.noexc18 ]
  %call1.i1012 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i7, i8 signext %retval.0.i.i)
          to label %call1.i10.noexc unwind label %lpad17

call1.i10.noexc:                                  ; preds = %call.i.noexc
  %call.i15 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i1012)
          to label %if.end31 unwind label %lpad17

lpad:                                             ; preds = %if.end13
  %23 = landingpad { i8*, i32 }
          cleanup
  %24 = extractvalue { i8*, i32 } %23, 0
  %25 = extractvalue { i8*, i32 } %23, 1
  br label %ehcleanup922

lpad17:                                           ; preds = %call1.i10.noexc, %call.i.noexc, %.noexc18, %if.end.i.i, %if.then.i.i, %invoke.cont25, %invoke.cont23, %if.then22, %invoke.cont
  %26 = landingpad { i8*, i32 }
          cleanup
  %27 = extractvalue { i8*, i32 } %26, 0
  %28 = extractvalue { i8*, i32 } %26, 1
  br label %ehcleanup922

if.end31:                                         ; preds = %call1.i10.noexc, %invoke.cont18
  %29 = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 328, i8* nonnull %29) #19
  %has_local_indices.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 0
  store i8 0, i8* %has_local_indices.i, align 8, !tbaa !28
  %rows.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 1
  %30 = bitcast %"class.std::vector.21"* %rows.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %30, i8 0, i64 24, i1 false) #19
  %31 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %rows.i, i64 0, i32 0
  %_M_impl.i.i.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %31, i64 0, i32 0
  %32 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i.i to %"class.std::allocator.23"*
  %33 = bitcast %"class.std::allocator.23"* %32 to %"class.__gnu_cxx::new_allocator.24"*
  %34 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i.i, i64 0, i32 0
  %35 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %34 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %35, i8 0, i64 24, i1 false) #19
  %row_offsets.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 2
  %36 = bitcast %"class.std::vector.21"* %row_offsets.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %36, i8 0, i64 24, i1 false) #19
  %37 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %row_offsets.i, i64 0, i32 0
  %_M_impl.i.i12.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %37, i64 0, i32 0
  %38 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i12.i to %"class.std::allocator.23"*
  %39 = bitcast %"class.std::allocator.23"* %38 to %"class.__gnu_cxx::new_allocator.24"*
  %40 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i12.i, i64 0, i32 0
  %41 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %40 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %41, i8 0, i64 24, i1 false) #19
  %row_offsets_external.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 3
  %42 = bitcast %"class.std::vector.21"* %row_offsets_external.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %42, i8 0, i64 24, i1 false) #19
  %43 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %row_offsets_external.i, i64 0, i32 0
  %_M_impl.i.i11.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %43, i64 0, i32 0
  %44 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i11.i to %"class.std::allocator.23"*
  %45 = bitcast %"class.std::allocator.23"* %44 to %"class.__gnu_cxx::new_allocator.24"*
  %46 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i11.i, i64 0, i32 0
  %47 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %46 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %47, i8 0, i64 24, i1 false) #19
  %packed_cols.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 4
  %48 = bitcast %"class.std::vector.21"* %packed_cols.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %48, i8 0, i64 24, i1 false) #19
  %49 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %packed_cols.i, i64 0, i32 0
  %_M_impl.i.i10.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %49, i64 0, i32 0
  %50 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i10.i to %"class.std::allocator.23"*
  %51 = bitcast %"class.std::allocator.23"* %50 to %"class.__gnu_cxx::new_allocator.24"*
  %52 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i10.i, i64 0, i32 0
  %53 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %52 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %53, i8 0, i64 24, i1 false) #19
  %packed_coefs.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 5
  %54 = bitcast %"class.std::vector.26"* %packed_coefs.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %54, i8 0, i64 24, i1 false) #19
  %55 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %packed_coefs.i, i64 0, i32 0
  %_M_impl.i.i9.i = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %55, i64 0, i32 0
  %56 = bitcast %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl"* %_M_impl.i.i9.i to %"class.std::allocator.28"*
  %57 = bitcast %"class.std::allocator.28"* %56 to %"class.__gnu_cxx::new_allocator.29"*
  %58 = getelementptr inbounds %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl", %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl"* %_M_impl.i.i9.i, i64 0, i32 0
  %59 = bitcast %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl_data"* %58 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %59, i8 0, i64 24, i1 false) #19
  %num_cols.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 6
  store i32 0, i32* %num_cols.i, align 8, !tbaa !33
  %external_index.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 7
  %60 = bitcast %"class.std::vector.21"* %external_index.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %60, i8 0, i64 24, i1 false) #19
  %61 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %external_index.i, i64 0, i32 0
  %_M_impl.i.i8.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %61, i64 0, i32 0
  %62 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i8.i to %"class.std::allocator.23"*
  %63 = bitcast %"class.std::allocator.23"* %62 to %"class.__gnu_cxx::new_allocator.24"*
  %64 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i8.i, i64 0, i32 0
  %65 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %64 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %65, i8 0, i64 24, i1 false) #19
  %external_local_index.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 8
  %66 = bitcast %"class.std::vector.21"* %external_local_index.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %66, i8 0, i64 24, i1 false) #19
  %67 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %external_local_index.i, i64 0, i32 0
  %_M_impl.i.i7.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %67, i64 0, i32 0
  %68 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i7.i to %"class.std::allocator.23"*
  %69 = bitcast %"class.std::allocator.23"* %68 to %"class.__gnu_cxx::new_allocator.24"*
  %70 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i7.i, i64 0, i32 0
  %71 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %70 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %71, i8 0, i64 24, i1 false) #19
  %elements_to_send.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 9
  %72 = bitcast %"class.std::vector.21"* %elements_to_send.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %72, i8 0, i64 24, i1 false) #19
  %73 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %elements_to_send.i, i64 0, i32 0
  %_M_impl.i.i6.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %73, i64 0, i32 0
  %74 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i6.i to %"class.std::allocator.23"*
  %75 = bitcast %"class.std::allocator.23"* %74 to %"class.__gnu_cxx::new_allocator.24"*
  %76 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i6.i, i64 0, i32 0
  %77 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %76 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %77, i8 0, i64 24, i1 false) #19
  %neighbors.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 10
  %78 = bitcast %"class.std::vector.21"* %neighbors.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %78, i8 0, i64 24, i1 false) #19
  %79 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %neighbors.i, i64 0, i32 0
  %_M_impl.i.i5.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %79, i64 0, i32 0
  %80 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i5.i to %"class.std::allocator.23"*
  %81 = bitcast %"class.std::allocator.23"* %80 to %"class.__gnu_cxx::new_allocator.24"*
  %82 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i5.i, i64 0, i32 0
  %83 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %82 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %83, i8 0, i64 24, i1 false) #19
  %recv_length.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 11
  %84 = bitcast %"class.std::vector.21"* %recv_length.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %84, i8 0, i64 24, i1 false) #19
  %85 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %recv_length.i, i64 0, i32 0
  %_M_impl.i.i4.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %85, i64 0, i32 0
  %86 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i4.i to %"class.std::allocator.23"*
  %87 = bitcast %"class.std::allocator.23"* %86 to %"class.__gnu_cxx::new_allocator.24"*
  %88 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i4.i, i64 0, i32 0
  %89 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %88 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %89, i8 0, i64 24, i1 false) #19
  %send_length.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 12
  %90 = bitcast %"class.std::vector.21"* %send_length.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %90, i8 0, i64 24, i1 false) #19
  %91 = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %send_length.i, i64 0, i32 0
  %_M_impl.i.i3.i = getelementptr inbounds %"struct.std::_Vector_base.22", %"struct.std::_Vector_base.22"* %91, i64 0, i32 0
  %92 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i3.i to %"class.std::allocator.23"*
  %93 = bitcast %"class.std::allocator.23"* %92 to %"class.__gnu_cxx::new_allocator.24"*
  %94 = getelementptr inbounds %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl", %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl"* %_M_impl.i.i3.i, i64 0, i32 0
  %95 = bitcast %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl_data"* %94 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %95, i8 0, i64 24, i1 false) #19
  %send_buffer.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 13
  %96 = bitcast %"class.std::vector.26"* %send_buffer.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %96, i8 0, i64 24, i1 false) #19
  %97 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %send_buffer.i, i64 0, i32 0
  %_M_impl.i.i2.i = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %97, i64 0, i32 0
  %98 = bitcast %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl"* %_M_impl.i.i2.i to %"class.std::allocator.28"*
  %99 = bitcast %"class.std::allocator.28"* %98 to %"class.__gnu_cxx::new_allocator.29"*
  %100 = getelementptr inbounds %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl", %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl"* %_M_impl.i.i2.i, i64 0, i32 0
  %101 = bitcast %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl_data"* %100 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %101, i8 0, i64 24, i1 false) #19
  %request.i = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 14
  %102 = bitcast %"class.std::vector"* %request.i to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %102, i8 0, i64 24, i1 false) #19
  %103 = getelementptr inbounds %"class.std::vector", %"class.std::vector"* %request.i, i64 0, i32 0
  %_M_impl.i.i1.i = getelementptr inbounds %"struct.std::_Vector_base", %"struct.std::_Vector_base"* %103, i64 0, i32 0
  %104 = bitcast %"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *> >::_Vector_impl"* %_M_impl.i.i1.i to %"class.std::allocator"*
  %105 = bitcast %"class.std::allocator"* %104 to %"class.__gnu_cxx::new_allocator"*
  %106 = getelementptr inbounds %"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *> >::_Vector_impl", %"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *> >::_Vector_impl"* %_M_impl.i.i1.i, i64 0, i32 0
  %107 = bitcast %"struct.std::_Vector_base<ompi_request_t *, std::allocator<ompi_request_t *> >::_Vector_impl_data"* %106 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %107, i8 0, i64 24, i1 false) #19
  %108 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp34 = icmp eq i32 %108, 0
  br i1 %cmp34, label %if.then35, label %if.end47

if.then35:                                        ; preds = %if.end31
  %vtable36 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8**), align 8, !tbaa !14
  %vbase.offset.ptr37 = getelementptr i8, i8* %vtable36, i64 -24
  %109 = bitcast i8* %vbase.offset.ptr37 to i64*
  %vbase.offset38 = load i64, i64* %109, align 8
  %add.ptr39 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8*), i64 %vbase.offset38
  %110 = bitcast i8* %add.ptr39 to %"class.std::ios_base"*
  %_M_width.i16 = getelementptr inbounds %"class.std::ios_base", %"class.std::ios_base"* %110, i64 0, i32 2
  %111 = load i64, i64* %_M_width.i16, align 8, !tbaa !16
  store i64 30, i64* %_M_width.i16, align 8, !tbaa !16
  %call.i.i20 = call i64 @strlen(i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.47, i64 0, i64 0)) #19
  %call1.i2122 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([31 x i8], [31 x i8]* @.str.47, i64 0, i64 0), i64 %call.i.i20)
          to label %invoke.cont43 unwind label %lpad40

invoke.cont43:                                    ; preds = %if.then35
  %call46 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull @_ZSt4cout)
          to label %if.end47 unwind label %lpad40

lpad40:                                           ; preds = %invoke.cont43, %if.then35
  %112 = landingpad { i8*, i32 }
          cleanup
  %113 = extractvalue { i8*, i32 } %112, 0
  %114 = extractvalue { i8*, i32 } %112, 1
  br label %ehcleanup918

if.end47:                                         ; preds = %invoke.cont43, %if.end31
  %call50 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont49 unwind label %lpad48

invoke.cont49:                                    ; preds = %if.end47
  %call52 = invoke i32 @_ZN6miniFE25generate_matrix_structureINS_9CSRMatrixIdiiEEEEiRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERS4_(%"class.miniFE::simple_mesh_description"* nonnull dereferenceable(192) %mesh, %"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A)
          to label %invoke.cont51 unwind label %lpad48

invoke.cont51:                                    ; preds = %invoke.cont49
  %call54 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont53 unwind label %lpad48

invoke.cont53:                                    ; preds = %invoke.cont51
  %sub55 = fsub double %call54, %call50
  %add = fadd double %sub20, %sub55
  %115 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp56 = icmp eq i32 %115, 0
  br i1 %cmp56, label %if.then57, label %if.end66

if.then57:                                        ; preds = %invoke.cont53
  %call.i25 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* @_ZSt4cout, double %sub55)
          to label %invoke.cont58 unwind label %lpad48

invoke.cont58:                                    ; preds = %if.then57
  %call.i.i27 = call i64 @strlen(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0)) #19
  %call1.i2829 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i25, i8* nonnull getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0), i64 %call.i.i27)
          to label %invoke.cont60 unwind label %lpad48

invoke.cont60:                                    ; preds = %invoke.cont58
  %call.i32 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* %call.i25, double %add)
          to label %invoke.cont62 unwind label %lpad48

invoke.cont62:                                    ; preds = %invoke.cont60
  %116 = bitcast %"class.std::basic_ostream"* %call.i32 to i8**
  %vtable.i37 = load i8*, i8** %116, align 8, !tbaa !14
  %vbase.offset.ptr.i38 = getelementptr i8, i8* %vtable.i37, i64 -24
  %117 = bitcast i8* %vbase.offset.ptr.i38 to i64*
  %vbase.offset.i39 = load i64, i64* %117, align 8
  %118 = bitcast %"class.std::basic_ostream"* %call.i32 to i8*
  %add.ptr.i40 = getelementptr inbounds i8, i8* %118, i64 %vbase.offset.i39
  %119 = bitcast i8* %add.ptr.i40 to %"class.std::basic_ios"*
  %_M_ctype.i50 = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %119, i64 0, i32 5
  %120 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i50, align 8, !tbaa !22
  %tobool.i.i51 = icmp eq %"class.std::ctype"* %120, null
  br i1 %tobool.i.i51, label %if.then.i.i52, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i55

if.then.i.i52:                                    ; preds = %invoke.cont62
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc63 unwind label %lpad48

.noexc63:                                         ; preds = %if.then.i.i52
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i55: ; preds = %invoke.cont62
  %_M_widen_ok.i.i53 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %120, i64 0, i32 8
  %121 = load i8, i8* %_M_widen_ok.i.i53, align 8, !tbaa !25
  %tobool.i1.i54 = icmp eq i8 %121, 0
  br i1 %tobool.i1.i54, label %if.end.i.i61, label %if.then.i2.i57

if.then.i2.i57:                                   ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i55
  %arrayidx.i.i56 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %120, i64 0, i32 9, i64 10
  %122 = load i8, i8* %arrayidx.i.i56, align 1, !tbaa !27
  br label %call.i.noexc42

if.end.i.i61:                                     ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i55
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %120)
          to label %.noexc64 unwind label %lpad48

.noexc64:                                         ; preds = %if.end.i.i61
  %123 = bitcast %"class.std::ctype"* %120 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i58 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %123, align 8, !tbaa !14
  %vfn.i.i59 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i58, i64 6
  %124 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i59, align 8
  %call.i.i6065 = invoke signext i8 %124(%"class.std::ctype"* nonnull %120, i8 signext 10)
          to label %call.i.noexc42 unwind label %lpad48

call.i.noexc42:                                   ; preds = %.noexc64, %if.then.i2.i57
  %retval.0.i.i62 = phi i8 [ %122, %if.then.i2.i57 ], [ %call.i.i6065, %.noexc64 ]
  %call1.i4144 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i32, i8 signext %retval.0.i.i62)
          to label %call1.i41.noexc unwind label %lpad48

call1.i41.noexc:                                  ; preds = %call.i.noexc42
  %call.i48 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i4144)
          to label %if.end66 unwind label %lpad48

lpad48:                                           ; preds = %call1.i41.noexc, %call.i.noexc42, %.noexc64, %if.end.i.i61, %if.then.i.i52, %invoke.cont60, %invoke.cont58, %if.then57, %invoke.cont51, %invoke.cont49, %if.end47
  %125 = landingpad { i8*, i32 }
          cleanup
  %126 = extractvalue { i8*, i32 } %125, 0
  %127 = extractvalue { i8*, i32 } %125, 1
  br label %ehcleanup918

if.end66:                                         ; preds = %call1.i41.noexc, %invoke.cont53
  %rows = getelementptr inbounds %"struct.miniFE::CSRMatrix", %"struct.miniFE::CSRMatrix"* %A, i64 0, i32 1
  %_M_finish.i = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %rows, i64 0, i32 0, i32 0, i32 0, i32 1
  %128 = bitcast i32** %_M_finish.i to i64*
  %129 = load i64, i64* %128, align 8, !tbaa !34
  %130 = bitcast %"class.std::vector.21"* %rows to i64*
  %131 = load i64, i64* %130, align 8, !tbaa !36
  %sub.ptr.sub.i = sub i64 %129, %131
  %sub.ptr.div.i = ashr exact i64 %sub.ptr.sub.i, 2
  %conv = trunc i64 %sub.ptr.div.i to i32
  %cmp68 = icmp sgt i32 %conv, 0
  br i1 %cmp68, label %cond.true, label %cond.end

cond.true:                                        ; preds = %if.end66
  %_M_start.i = getelementptr inbounds %"class.std::vector.21", %"class.std::vector.21"* %rows, i64 0, i32 0, i32 0, i32 0, i32 0
  %132 = load i32*, i32** %_M_start.i, align 8, !tbaa !36
  %133 = load i32, i32* %132, align 4, !tbaa !2
  br label %cond.end

cond.end:                                         ; preds = %cond.true, %if.end66
  %cond = phi i32 [ %133, %cond.true ], [ -1, %if.end66 ]
  %134 = bitcast %"struct.miniFE::Vector"* %b to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %134) #19
  %startIndex.i = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %b, i64 0, i32 0
  store i32 %cond, i32* %startIndex.i, align 8, !tbaa !37
  %local_size.i = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %b, i64 0, i32 1
  store i32 %conv, i32* %local_size.i, align 4, !tbaa !39
  %coefs.i = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %b, i64 0, i32 2
  %conv.i = sext i32 %conv to i64
  %135 = getelementptr inbounds %"class.std::allocator.28", %"class.std::allocator.28"* %ref.tmp.i, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %135) #19
  %136 = bitcast %"class.std::allocator.28"* %ref.tmp.i to %"class.__gnu_cxx::new_allocator.29"*
  invoke void @_ZNSt6vectorIdSaIdEEC2EmRKS0_(%"class.std::vector.26"* nonnull %coefs.i, i64 %conv.i, %"class.std::allocator.28"* nonnull dereferenceable(1) %ref.tmp.i)
          to label %invoke.cont.i unwind label %lpad.i

invoke.cont.i:                                    ; preds = %cond.end
  %137 = bitcast %"class.std::allocator.28"* %ref.tmp.i to %"class.__gnu_cxx::new_allocator.29"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %135) #19
  %138 = load i32, i32* %local_size.i, align 4, !tbaa !39
  %cmp.i = icmp sgt i32 %138, 0
  br i1 %cmp.i, label %pfor.cond.preheader.i, label %invoke.cont72

pfor.cond.preheader.i:                            ; preds = %invoke.cont.i
  %wide.trip.count.i = zext i32 %138 to i64
  br label %pfor.cond.i

lpad.i:                                           ; preds = %cond.end
  %139 = landingpad { i8*, i32 }
          cleanup
  %140 = extractvalue { i8*, i32 } %139, 0
  %141 = extractvalue { i8*, i32 } %139, 1
  %142 = bitcast %"class.std::allocator.28"* %ref.tmp.i to %"class.__gnu_cxx::new_allocator.29"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %135) #19
  br label %eh.resume.i

pfor.cond.i:                                      ; preds = %pfor.inc.i, %pfor.cond.preheader.i
  %indvars.iv.i = phi i64 [ 0, %pfor.cond.preheader.i ], [ %indvars.iv.next.i, %pfor.inc.i ]
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  detach within %syncreg.i, label %pfor.body.i, label %pfor.inc.i

pfor.body.i:                                      ; preds = %pfor.cond.i
  %_M_start.i1.i = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %143 = load double*, double** %_M_start.i1.i, align 8, !tbaa !40
  %add.ptr.i.i = getelementptr inbounds double, double* %143, i64 %indvars.iv.i
  store double 0.000000e+00, double* %add.ptr.i.i, align 8, !tbaa !42
  reattach within %syncreg.i, label %pfor.inc.i

pfor.inc.i:                                       ; preds = %pfor.body.i, %pfor.cond.i
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, %wide.trip.count.i
  br i1 %exitcond.i, label %pfor.cond.cleanup.i, label %pfor.cond.i, !llvm.loop !44

pfor.cond.cleanup.i:                              ; preds = %pfor.inc.i
  sync within %syncreg.i, label %sync.continue.i

sync.continue.i:                                  ; preds = %pfor.cond.cleanup.i
  invoke void @llvm.sync.unwind(token %syncreg.i)
          to label %invoke.cont72 unwind label %lpad9.i

lpad9.i:                                          ; preds = %sync.continue.i
  %144 = landingpad { i8*, i32 }
          cleanup
  %145 = extractvalue { i8*, i32 } %144, 0
  %146 = extractvalue { i8*, i32 } %144, 1
  %147 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i, i64 0, i32 0
  %_M_start.i.i = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %148 = load double*, double** %_M_start.i.i, align 8, !tbaa !40
  %_M_finish.i.i = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i, i64 0, i32 0, i32 0, i32 0, i32 1
  %149 = load double*, double** %_M_finish.i.i, align 8, !tbaa !46
  %150 = bitcast %"struct.std::_Vector_base.27"* %147 to %"class.std::allocator.28"*
  %_M_start.i.i.i = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %147, i64 0, i32 0, i32 0, i32 0
  %151 = load double*, double** %_M_start.i.i.i, align 8, !tbaa !40
  %_M_end_of_storage.i.i.i = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %147, i64 0, i32 0, i32 0, i32 2
  %152 = bitcast double** %_M_end_of_storage.i.i.i to i64*
  %153 = load i64, i64* %152, align 8, !tbaa !47
  %sub.ptr.rhs.cast.i.i.i = ptrtoint double* %151 to i64
  %sub.ptr.sub.i.i.i = sub i64 %153, %sub.ptr.rhs.cast.i.i.i
  %sub.ptr.div.i.i.i = ashr exact i64 %sub.ptr.sub.i.i.i, 3
  %tobool.i.i.i.i = icmp eq double* %151, null
  br i1 %tobool.i.i.i.i, label %_ZNSt6vectorIdSaIdEED2Ev.exit.i, label %if.then.i.i.i.i

if.then.i.i.i.i:                                  ; preds = %lpad9.i
  %154 = bitcast %"struct.std::_Vector_base.27"* %147 to %"class.std::allocator.28"*
  %155 = bitcast %"class.std::allocator.28"* %154 to %"class.__gnu_cxx::new_allocator.29"*
  %156 = bitcast double* %151 to i8*
  call void @_ZdlPv(i8* %156) #19
  br label %_ZNSt6vectorIdSaIdEED2Ev.exit.i

_ZNSt6vectorIdSaIdEED2Ev.exit.i:                  ; preds = %if.then.i.i.i.i, %lpad9.i
  %157 = bitcast %"struct.std::_Vector_base.27"* %147 to %"class.__gnu_cxx::new_allocator.29"*
  br label %eh.resume.i

eh.resume.i:                                      ; preds = %_ZNSt6vectorIdSaIdEED2Ev.exit.i, %lpad.i
  %ehselector.slot.0.i = phi i32 [ %146, %_ZNSt6vectorIdSaIdEED2Ev.exit.i ], [ %141, %lpad.i ]
  %exn.slot.0.i = phi i8* [ %145, %_ZNSt6vectorIdSaIdEED2Ev.exit.i ], [ %140, %lpad.i ]
  %lpad.val.i = insertvalue { i8*, i32 } undef, i8* %exn.slot.0.i, 0
  %lpad.val12.i = insertvalue { i8*, i32 } %lpad.val.i, i32 %ehselector.slot.0.i, 1
  %158 = extractvalue { i8*, i32 } %lpad.val12.i, 0
  %159 = extractvalue { i8*, i32 } %lpad.val12.i, 1
  br label %ehcleanup915

invoke.cont72:                                    ; preds = %sync.continue.i, %invoke.cont.i
  %160 = bitcast %"struct.miniFE::Vector"* %x to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %160) #19
  %tf.i = call token @llvm.taskframe.create()
  %syncreg.i69 = call token @llvm.syncregion.start()
  %startIndex.i70 = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %x, i64 0, i32 0
  store i32 %cond, i32* %startIndex.i70, align 8, !tbaa !37
  %local_size.i71 = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %x, i64 0, i32 1
  store i32 %conv, i32* %local_size.i71, align 4, !tbaa !39
  %coefs.i72 = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %x, i64 0, i32 2
  %conv.i73 = sext i32 %conv to i64
  %161 = getelementptr inbounds %"class.std::allocator.28", %"class.std::allocator.28"* %ref.tmp.i68, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %161) #19
  %162 = bitcast %"class.std::allocator.28"* %ref.tmp.i68 to %"class.__gnu_cxx::new_allocator.29"*
  invoke void @_ZNSt6vectorIdSaIdEEC2EmRKS0_(%"class.std::vector.26"* nonnull %coefs.i72, i64 %conv.i73, %"class.std::allocator.28"* nonnull dereferenceable(1) %ref.tmp.i68)
          to label %invoke.cont.i75 unwind label %lpad.i78

invoke.cont.i75:                                  ; preds = %invoke.cont72
  %163 = bitcast %"class.std::allocator.28"* %ref.tmp.i68 to %"class.__gnu_cxx::new_allocator.29"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %161) #19
  %164 = load i32, i32* %local_size.i71, align 4, !tbaa !39
  %cmp.i74 = icmp sgt i32 %164, 0
  br i1 %cmp.i74, label %pfor.cond.preheader.i77, label %_ZN6miniFE6VectorIdiiEC2Eii.exit108

pfor.cond.preheader.i77:                          ; preds = %invoke.cont.i75
  %wide.trip.count.i76 = zext i32 %164 to i64
  br label %pfor.cond.i81

lpad.i78:                                         ; preds = %invoke.cont72
  %165 = landingpad { i8*, i32 }
          cleanup
  %166 = extractvalue { i8*, i32 } %165, 0
  %167 = extractvalue { i8*, i32 } %165, 1
  %168 = bitcast %"class.std::allocator.28"* %ref.tmp.i68 to %"class.__gnu_cxx::new_allocator.29"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %161) #19
  br label %eh.resume.i104

pfor.cond.i81:                                    ; preds = %pfor.inc.i86, %pfor.cond.preheader.i77
  %indvars.iv.i79 = phi i64 [ 0, %pfor.cond.preheader.i77 ], [ %indvars.iv.next.i80, %pfor.inc.i86 ]
  %indvars.iv.next.i80 = add nuw nsw i64 %indvars.iv.i79, 1
  detach within %syncreg.i69, label %pfor.body.i84, label %pfor.inc.i86

pfor.body.i84:                                    ; preds = %pfor.cond.i81
  %_M_start.i1.i82 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i72, i64 0, i32 0, i32 0, i32 0, i32 0
  %169 = load double*, double** %_M_start.i1.i82, align 8, !tbaa !40
  %add.ptr.i.i83 = getelementptr inbounds double, double* %169, i64 %indvars.iv.i79
  store double 0.000000e+00, double* %add.ptr.i.i83, align 8, !tbaa !42
  reattach within %syncreg.i69, label %pfor.inc.i86

pfor.inc.i86:                                     ; preds = %pfor.body.i84, %pfor.cond.i81
  %exitcond.i85 = icmp eq i64 %indvars.iv.next.i80, %wide.trip.count.i76
  br i1 %exitcond.i85, label %pfor.cond.cleanup.i87, label %pfor.cond.i81, !llvm.loop !44

pfor.cond.cleanup.i87:                            ; preds = %pfor.inc.i86
  sync within %syncreg.i69, label %sync.continue.i88

sync.continue.i88:                                ; preds = %pfor.cond.cleanup.i87
  invoke void @llvm.sync.unwind(token %syncreg.i69)
          to label %_ZN6miniFE6VectorIdiiEC2Eii.exit108 unwind label %lpad9.i97

lpad9.i97:                                        ; preds = %sync.continue.i88
  %170 = landingpad { i8*, i32 }
          cleanup
  %171 = extractvalue { i8*, i32 } %170, 0
  %172 = extractvalue { i8*, i32 } %170, 1
  %173 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i72, i64 0, i32 0
  %_M_start.i.i89 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i72, i64 0, i32 0, i32 0, i32 0, i32 0
  %174 = load double*, double** %_M_start.i.i89, align 8, !tbaa !40
  %_M_finish.i.i90 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i72, i64 0, i32 0, i32 0, i32 0, i32 1
  %175 = load double*, double** %_M_finish.i.i90, align 8, !tbaa !46
  %176 = bitcast %"struct.std::_Vector_base.27"* %173 to %"class.std::allocator.28"*
  %_M_start.i.i.i91 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %173, i64 0, i32 0, i32 0, i32 0
  %177 = load double*, double** %_M_start.i.i.i91, align 8, !tbaa !40
  %_M_end_of_storage.i.i.i92 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %173, i64 0, i32 0, i32 0, i32 2
  %178 = bitcast double** %_M_end_of_storage.i.i.i92 to i64*
  %179 = load i64, i64* %178, align 8, !tbaa !47
  %sub.ptr.rhs.cast.i.i.i93 = ptrtoint double* %177 to i64
  %sub.ptr.sub.i.i.i94 = sub i64 %179, %sub.ptr.rhs.cast.i.i.i93
  %sub.ptr.div.i.i.i95 = ashr exact i64 %sub.ptr.sub.i.i.i94, 3
  %tobool.i.i.i.i96 = icmp eq double* %177, null
  br i1 %tobool.i.i.i.i96, label %_ZNSt6vectorIdSaIdEED2Ev.exit.i99, label %if.then.i.i.i.i98

if.then.i.i.i.i98:                                ; preds = %lpad9.i97
  %180 = bitcast %"struct.std::_Vector_base.27"* %173 to %"class.std::allocator.28"*
  %181 = bitcast %"class.std::allocator.28"* %180 to %"class.__gnu_cxx::new_allocator.29"*
  %182 = bitcast double* %177 to i8*
  call void @_ZdlPv(i8* %182) #19
  br label %_ZNSt6vectorIdSaIdEED2Ev.exit.i99

_ZNSt6vectorIdSaIdEED2Ev.exit.i99:                ; preds = %if.then.i.i.i.i98, %lpad9.i97
  %183 = bitcast %"struct.std::_Vector_base.27"* %173 to %"class.__gnu_cxx::new_allocator.29"*
  br label %eh.resume.i104

eh.resume.i104:                                   ; preds = %_ZNSt6vectorIdSaIdEED2Ev.exit.i99, %lpad.i78
  %ehselector.slot.0.i100 = phi i32 [ %172, %_ZNSt6vectorIdSaIdEED2Ev.exit.i99 ], [ %167, %lpad.i78 ]
  %exn.slot.0.i101 = phi i8* [ %171, %_ZNSt6vectorIdSaIdEED2Ev.exit.i99 ], [ %166, %lpad.i78 ]
  %lpad.val.i102 = insertvalue { i8*, i32 } undef, i8* %exn.slot.0.i101, 0
  %lpad.val12.i103 = insertvalue { i8*, i32 } %lpad.val.i102, i32 %ehselector.slot.0.i100, 1
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %tf.i, { i8*, i32 } %lpad.val12.i103)
          to label %lpad73.unreachable unwind label %lpad73

lpad73.unreachable:                               ; preds = %eh.resume.i104
  unreachable

_ZN6miniFE6VectorIdiiEC2Eii.exit108:              ; preds = %sync.continue.i88, %invoke.cont.i75
  call void @llvm.taskframe.end(token %tf.i)
  %184 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp75 = icmp eq i32 %184, 0
  br i1 %cmp75, label %if.then76, label %if.end88

if.then76:                                        ; preds = %_ZN6miniFE6VectorIdiiEC2Eii.exit108
  %vtable77 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8**), align 8, !tbaa !14
  %vbase.offset.ptr78 = getelementptr i8, i8* %vtable77, i64 -24
  %185 = bitcast i8* %vbase.offset.ptr78 to i64*
  %vbase.offset79 = load i64, i64* %185, align 8
  %add.ptr80 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8*), i64 %vbase.offset79
  %186 = bitcast i8* %add.ptr80 to %"class.std::ios_base"*
  %_M_width.i109 = getelementptr inbounds %"class.std::ios_base", %"class.std::ios_base"* %186, i64 0, i32 2
  %187 = load i64, i64* %_M_width.i109, align 8, !tbaa !16
  store i64 30, i64* %_M_width.i109, align 8, !tbaa !16
  %call.i.i110 = call i64 @strlen(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.48, i64 0, i64 0)) #19
  %call1.i111112 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([22 x i8], [22 x i8]* @.str.48, i64 0, i64 0), i64 %call.i.i110)
          to label %invoke.cont84 unwind label %lpad81

invoke.cont84:                                    ; preds = %if.then76
  %call87 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull @_ZSt4cout)
          to label %if.end88 unwind label %lpad81

lpad73:                                           ; preds = %eh.resume.i104
  %188 = landingpad { i8*, i32 }
          cleanup
  %189 = extractvalue { i8*, i32 } %188, 0
  %190 = extractvalue { i8*, i32 } %188, 1
  br label %ehcleanup913

lpad81:                                           ; preds = %invoke.cont84, %if.then76
  %191 = landingpad { i8*, i32 }
          cleanup
  %192 = extractvalue { i8*, i32 } %191, 0
  %193 = extractvalue { i8*, i32 } %191, 1
  br label %ehcleanup911

if.end88:                                         ; preds = %invoke.cont84, %_ZN6miniFE6VectorIdiiEC2Eii.exit108
  %call92 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont91 unwind label %lpad90

invoke.cont91:                                    ; preds = %if.end88
  invoke void @_ZN6miniFE16assemble_FE_dataINS_9CSRMatrixIdiiEENS_6VectorIdiiEEEEvRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERS6_RT0_RNS_10ParametersE(%"class.miniFE::simple_mesh_description"* nonnull dereferenceable(192) %mesh, %"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A, %"struct.miniFE::Vector"* nonnull dereferenceable(32) %b, %"struct.miniFE::Parameters"* nonnull dereferenceable(96) %params)
          to label %invoke.cont93 unwind label %lpad90

invoke.cont93:                                    ; preds = %invoke.cont91
  %call95 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont94 unwind label %lpad90

invoke.cont94:                                    ; preds = %invoke.cont93
  %sub96 = fsub double %call95, %call92
  %add97 = fadd double %add, %sub96
  %194 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp98 = icmp eq i32 %194, 0
  br i1 %cmp98, label %if.then99, label %if.end204

if.then99:                                        ; preds = %invoke.cont94
  %call.i115 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* @_ZSt4cout, double %sub96)
          to label %invoke.cont100 unwind label %lpad90

invoke.cont100:                                   ; preds = %if.then99
  %call.i.i117 = call i64 @strlen(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0)) #19
  %call1.i118119 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i115, i8* nonnull getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0), i64 %call.i.i117)
          to label %invoke.cont102 unwind label %lpad90

invoke.cont102:                                   ; preds = %invoke.cont100
  %call.i122 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* %call.i115, double %add97)
          to label %invoke.cont104 unwind label %lpad90

invoke.cont104:                                   ; preds = %invoke.cont102
  %195 = bitcast %"class.std::basic_ostream"* %call.i122 to i8**
  %vtable.i127 = load i8*, i8** %195, align 8, !tbaa !14
  %vbase.offset.ptr.i128 = getelementptr i8, i8* %vtable.i127, i64 -24
  %196 = bitcast i8* %vbase.offset.ptr.i128 to i64*
  %vbase.offset.i129 = load i64, i64* %196, align 8
  %197 = bitcast %"class.std::basic_ostream"* %call.i122 to i8*
  %add.ptr.i130 = getelementptr inbounds i8, i8* %197, i64 %vbase.offset.i129
  %198 = bitcast i8* %add.ptr.i130 to %"class.std::basic_ios"*
  %_M_ctype.i184 = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %198, i64 0, i32 5
  %199 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i184, align 8, !tbaa !22
  %tobool.i.i185 = icmp eq %"class.std::ctype"* %199, null
  br i1 %tobool.i.i185, label %if.then.i.i186, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i189

if.then.i.i186:                                   ; preds = %invoke.cont104
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc197 unwind label %lpad90

.noexc197:                                        ; preds = %if.then.i.i186
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i189: ; preds = %invoke.cont104
  %_M_widen_ok.i.i187 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %199, i64 0, i32 8
  %200 = load i8, i8* %_M_widen_ok.i.i187, align 8, !tbaa !25
  %tobool.i1.i188 = icmp eq i8 %200, 0
  br i1 %tobool.i1.i188, label %if.end.i.i195, label %if.then.i2.i191

if.then.i2.i191:                                  ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i189
  %arrayidx.i.i190 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %199, i64 0, i32 9, i64 10
  %201 = load i8, i8* %arrayidx.i.i190, align 1, !tbaa !27
  br label %call.i.noexc132

if.end.i.i195:                                    ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i189
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %199)
          to label %.noexc198 unwind label %lpad90

.noexc198:                                        ; preds = %if.end.i.i195
  %202 = bitcast %"class.std::ctype"* %199 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i192 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %202, align 8, !tbaa !14
  %vfn.i.i193 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i192, i64 6
  %203 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i193, align 8
  %call.i.i194199 = invoke signext i8 %203(%"class.std::ctype"* nonnull %199, i8 signext 10)
          to label %call.i.noexc132 unwind label %lpad90

call.i.noexc132:                                  ; preds = %.noexc198, %if.then.i2.i191
  %retval.0.i.i196 = phi i8 [ %201, %if.then.i2.i191 ], [ %call.i.i194199, %.noexc198 ]
  %call1.i131134 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i122, i8 signext %retval.0.i.i196)
          to label %call1.i131.noexc unwind label %lpad90

call1.i131.noexc:                                 ; preds = %call.i.noexc132
  %call.i138 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i131134)
          to label %if.end108 unwind label %lpad90

lpad90:                                           ; preds = %call1.i131.noexc, %call.i.noexc132, %.noexc198, %if.end.i.i195, %if.then.i.i186, %invoke.cont102, %invoke.cont100, %if.then99, %invoke.cont93, %invoke.cont91, %if.end88
  %204 = landingpad { i8*, i32 }
          cleanup
  %205 = extractvalue { i8*, i32 } %204, 0
  %206 = extractvalue { i8*, i32 } %204, 1
  br label %ehcleanup911

if.end108:                                        ; preds = %call1.i131.noexc
  %.pr = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp109 = icmp eq i32 %.pr, 0
  br i1 %cmp109, label %if.then110, label %if.end204

if.then110:                                       ; preds = %if.end108
  %207 = getelementptr inbounds %class.YAML_Doc, %class.YAML_Doc* %ydoc, i64 0, i32 0
  %208 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %208) #19
  %209 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp111, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %209) #19
  %210 = bitcast %"class.std::allocator.0"* %ref.tmp111 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 0
  %211 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 2
  %arraydecay.i.i = bitcast %union.anon* %211 to i8*
  %212 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i to %"class.std::allocator.0"*
  %213 = bitcast %"class.std::allocator.0"* %212 to %"class.__gnu_cxx::new_allocator.1"*
  %214 = bitcast %"class.std::allocator.0"* %ref.tmp111 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i, i64 0, i32 0
  store i8* %arraydecay.i.i, i8** %_M_p.i.i, align 8, !tbaa !48
  %call.i.i140 = call i64 @strlen(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0)) #19
  %add.ptr.i141 = getelementptr inbounds i8, i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0), i64 %call.i.i140
  %cmp.i.i.i.i = icmp eq i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0), %add.ptr.i141
  %215 = bitcast i64* %__dnew.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %215) #19
  %216 = bitcast i8** %__first.addr.i.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %216)
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i = ptrtoint i8* %add.ptr.i141 to i64
  %sub.ptr.sub.i.i.i.i.i.i = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i, ptrtoint ([28 x i8]* @.str.49 to i64)
  %217 = bitcast i8** %__first.addr.i.i.i.i.i to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %217)
  store i64 %sub.ptr.sub.i.i.i.i.i.i, i64* %__dnew.i.i.i.i, align 8, !tbaa !50
  %cmp3.i.i.i.i = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i, 15
  br i1 %cmp3.i.i.i.i, label %if.then4.i.i.i.i, label %if.end6.i.i.i.i

if.then4.i.i.i.i:                                 ; preds = %if.then110
  %call5.i.i.i1.i = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i, i64 0)
          to label %call5.i.i.i.noexc.i unwind label %lpad.i142

call5.i.i.i.noexc.i:                              ; preds = %if.then4.i.i.i.i
  %_M_p.i1.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i, i8** %_M_p.i1.i.i.i.i, align 8, !tbaa !51
  %218 = load i64, i64* %__dnew.i.i.i.i, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 2, i32 0
  store i64 %218, i64* %_M_allocated_capacity.i.i.i.i.i, align 8, !tbaa !27
  br label %if.end6.i.i.i.i

if.end6.i.i.i.i:                                  ; preds = %call5.i.i.i.noexc.i, %if.then110
  %_M_p.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 0, i32 0
  %219 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i = ptrtoint i8* %add.ptr.i141 to i64
  %sub.ptr.sub.i.i.i.i.i = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i, ptrtoint ([28 x i8]* @.str.49 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i, label %if.end.i.i.i.i.i.i.i [
    i64 1, label %if.then.i.i.i.i.i.i
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit
  ]

if.then.i.i.i.i.i.i:                              ; preds = %if.end6.i.i.i.i
  store i8 77, i8* %219, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit

if.end.i.i.i.i.i.i.i:                             ; preds = %if.end6.i.i.i.i
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %219, i8* align 1 getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit

lpad.i142:                                        ; preds = %if.then4.i.i.i.i
  %220 = landingpad { i8*, i32 }
          cleanup
  %221 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp to %"class.std::allocator.0"*
  %222 = bitcast %"class.std::allocator.0"* %221 to %"class.__gnu_cxx::new_allocator.1"*
  %223 = extractvalue { i8*, i32 } %220, 0
  %224 = extractvalue { i8*, i32 } %220, 1
  br label %ehcleanup124

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit: ; preds = %if.end.i.i.i.i.i.i.i, %if.then.i.i.i.i.i.i, %if.end6.i.i.i.i
  %225 = load i64, i64* %__dnew.i.i.i.i, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 1
  store i64 %225, i64* %_M_string_length.i.i.i.i.i.i, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 0, i32 0
  %226 = load i8*, i8** %_M_p.i.i.i.i.i.i, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i = getelementptr inbounds i8, i8* %226, i64 %225
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i, align 1, !tbaa !27
  %227 = load i8, i8* %ref.tmp.i.i.i.i.i, align 1, !tbaa !27
  store i8 %227, i8* %arrayidx.i.i.i.i.i, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %215) #19
  %228 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp114 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %228) #19
  %229 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp115, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %229) #19
  %230 = bitcast %"class.std::allocator.0"* %ref.tmp115 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i147 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 0
  %231 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 2
  %arraydecay.i.i148 = bitcast %union.anon* %231 to i8*
  %232 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i147 to %"class.std::allocator.0"*
  %233 = bitcast %"class.std::allocator.0"* %232 to %"class.__gnu_cxx::new_allocator.1"*
  %234 = bitcast %"class.std::allocator.0"* %ref.tmp115 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i149 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i147, i64 0, i32 0
  store i8* %arraydecay.i.i148, i8** %_M_p.i.i149, align 8, !tbaa !48
  %call.i.i150 = call i64 @strlen(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0)) #19
  %add.ptr.i151 = getelementptr inbounds i8, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i64 %call.i.i150
  %cmp.i.i.i.i152 = icmp eq i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), %add.ptr.i151
  %235 = bitcast i64* %__dnew.i.i.i.i146 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %235) #19
  %236 = bitcast i8** %__first.addr.i.i.i.i.i144 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %236)
  store i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i144, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i153 = ptrtoint i8* %add.ptr.i151 to i64
  %sub.ptr.sub.i.i.i.i.i.i154 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i153, ptrtoint ([1 x i8]* @.str.5 to i64)
  %237 = bitcast i8** %__first.addr.i.i.i.i.i144 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %237)
  store i64 %sub.ptr.sub.i.i.i.i.i.i154, i64* %__dnew.i.i.i.i146, align 8, !tbaa !50
  %cmp3.i.i.i.i155 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i154, 15
  br i1 %cmp3.i.i.i.i155, label %if.then4.i.i.i.i157, label %if.end6.i.i.i.i164

if.then4.i.i.i.i157:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit
  %call5.i.i.i1.i156 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp114, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i146, i64 0)
          to label %call5.i.i.i.noexc.i160 unwind label %lpad.i170

call5.i.i.i.noexc.i160:                           ; preds = %if.then4.i.i.i.i157
  %_M_p.i1.i.i.i.i158 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i156, i8** %_M_p.i1.i.i.i.i158, align 8, !tbaa !51
  %238 = load i64, i64* %__dnew.i.i.i.i146, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i159 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 2, i32 0
  store i64 %238, i64* %_M_allocated_capacity.i.i.i.i.i159, align 8, !tbaa !27
  br label %if.end6.i.i.i.i164

if.end6.i.i.i.i164:                               ; preds = %call5.i.i.i.noexc.i160, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit
  %_M_p.i.i.i.i.i161 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 0, i32 0
  %239 = load i8*, i8** %_M_p.i.i.i.i.i161, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i162 = ptrtoint i8* %add.ptr.i151 to i64
  %sub.ptr.sub.i.i.i.i.i163 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i162, ptrtoint ([1 x i8]* @.str.5 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i163, label %if.end.i.i.i.i.i.i.i166 [
    i64 1, label %if.then.i.i.i.i.i.i165
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit172
  ]

if.then.i.i.i.i.i.i165:                           ; preds = %if.end6.i.i.i.i164
  store i8 0, i8* %239, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit172

if.end.i.i.i.i.i.i.i166:                          ; preds = %if.end6.i.i.i.i164
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %239, i8* align 1 getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i163, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit172

lpad.i170:                                        ; preds = %if.then4.i.i.i.i157
  %240 = landingpad { i8*, i32 }
          cleanup
  %241 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp114 to %"class.std::allocator.0"*
  %242 = bitcast %"class.std::allocator.0"* %241 to %"class.__gnu_cxx::new_allocator.1"*
  %243 = extractvalue { i8*, i32 } %240, 0
  %244 = extractvalue { i8*, i32 } %240, 1
  br label %ehcleanup

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit172: ; preds = %if.end.i.i.i.i.i.i.i166, %if.then.i.i.i.i.i.i165, %if.end6.i.i.i.i164
  %245 = load i64, i64* %__dnew.i.i.i.i146, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i167 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 1
  store i64 %245, i64* %_M_string_length.i.i.i.i.i.i167, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i168 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 0, i32 0
  %246 = load i8*, i8** %_M_p.i.i.i.i.i.i168, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i169 = getelementptr inbounds i8, i8* %246, i64 %245
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i145) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i145, align 1, !tbaa !27
  %247 = load i8, i8* %ref.tmp.i.i.i.i.i145, align 1, !tbaa !27
  store i8 %247, i8* %arrayidx.i.i.i.i.i169, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i145) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %235) #19
  %call120 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* nonnull %207, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp114)
          to label %invoke.cont119 unwind label %lpad118

invoke.cont119:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit172
  %_M_p.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 0, i32 0
  %248 = load i8*, i8** %_M_p.i.i.i.i, align 8, !tbaa !51
  %249 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 2
  %arraydecay.i.i.i.i = bitcast %union.anon* %249 to i8*
  %cmp.i.i.i = icmp eq i8* %248, %arraydecay.i.i.i.i
  br i1 %cmp.i.i.i, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit, label %if.then.i.i173

if.then.i.i173:                                   ; preds = %invoke.cont119
  %_M_allocated_capacity.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 2, i32 0
  %250 = load i64, i64* %_M_allocated_capacity.i.i, align 8, !tbaa !27
  %251 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp114 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 0, i32 0
  %252 = load i8*, i8** %_M_p.i.i1.i.i, align 8, !tbaa !51
  %add.i.i.i = add i64 %250, 1
  %253 = bitcast %"class.std::allocator.0"* %251 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %252) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit: ; preds = %if.then.i.i173, %invoke.cont119
  %254 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp114 to %"class.std::allocator.0"*
  %255 = bitcast %"class.std::allocator.0"* %254 to %"class.__gnu_cxx::new_allocator.1"*
  %256 = bitcast %"class.std::allocator.0"* %ref.tmp115 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %229) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %228) #19
  %_M_p.i.i.i.i175 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 0, i32 0
  %257 = load i8*, i8** %_M_p.i.i.i.i175, align 8, !tbaa !51
  %258 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 2
  %arraydecay.i.i.i.i176 = bitcast %union.anon* %258 to i8*
  %cmp.i.i.i177 = icmp eq i8* %257, %arraydecay.i.i.i.i176
  br i1 %cmp.i.i.i177, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit183, label %if.then.i.i181

if.then.i.i181:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
  %_M_allocated_capacity.i.i178 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 2, i32 0
  %259 = load i64, i64* %_M_allocated_capacity.i.i178, align 8, !tbaa !27
  %260 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i179 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 0, i32 0
  %261 = load i8*, i8** %_M_p.i.i1.i.i179, align 8, !tbaa !51
  %add.i.i.i180 = add i64 %259, 1
  %262 = bitcast %"class.std::allocator.0"* %260 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %261) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit183

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit183: ; preds = %if.then.i.i181, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
  %263 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp to %"class.std::allocator.0"*
  %264 = bitcast %"class.std::allocator.0"* %263 to %"class.__gnu_cxx::new_allocator.1"*
  %265 = bitcast %"class.std::allocator.0"* %ref.tmp111 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %209) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %208) #19
  %266 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp127 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %266) #19
  %267 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp128, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %267) #19
  %268 = bitcast %"class.std::allocator.0"* %ref.tmp128 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i204 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 0
  %269 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 2
  %arraydecay.i.i205 = bitcast %union.anon* %269 to i8*
  %270 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i204 to %"class.std::allocator.0"*
  %271 = bitcast %"class.std::allocator.0"* %270 to %"class.__gnu_cxx::new_allocator.1"*
  %272 = bitcast %"class.std::allocator.0"* %ref.tmp128 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i206 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i204, i64 0, i32 0
  store i8* %arraydecay.i.i205, i8** %_M_p.i.i206, align 8, !tbaa !48
  %call.i.i207 = call i64 @strlen(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0)) #19
  %add.ptr.i208 = getelementptr inbounds i8, i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0), i64 %call.i.i207
  %cmp.i.i.i.i209 = icmp eq i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0), %add.ptr.i208
  %273 = bitcast i64* %__dnew.i.i.i.i203 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %273) #19
  %274 = bitcast i8** %__first.addr.i.i.i.i.i201 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %274)
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i201, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i210 = ptrtoint i8* %add.ptr.i208 to i64
  %sub.ptr.sub.i.i.i.i.i.i211 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i210, ptrtoint ([28 x i8]* @.str.49 to i64)
  %275 = bitcast i8** %__first.addr.i.i.i.i.i201 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %275)
  store i64 %sub.ptr.sub.i.i.i.i.i.i211, i64* %__dnew.i.i.i.i203, align 8, !tbaa !50
  %cmp3.i.i.i.i212 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i211, 15
  br i1 %cmp3.i.i.i.i212, label %if.then4.i.i.i.i214, label %if.end6.i.i.i.i221

if.then4.i.i.i.i214:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit183
  %call5.i.i.i1.i213 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp127, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i203, i64 0)
          to label %call5.i.i.i.noexc.i217 unwind label %lpad.i227

call5.i.i.i.noexc.i217:                           ; preds = %if.then4.i.i.i.i214
  %_M_p.i1.i.i.i.i215 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i213, i8** %_M_p.i1.i.i.i.i215, align 8, !tbaa !51
  %276 = load i64, i64* %__dnew.i.i.i.i203, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i216 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 2, i32 0
  store i64 %276, i64* %_M_allocated_capacity.i.i.i.i.i216, align 8, !tbaa !27
  br label %if.end6.i.i.i.i221

if.end6.i.i.i.i221:                               ; preds = %call5.i.i.i.noexc.i217, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit183
  %_M_p.i.i.i.i.i218 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 0, i32 0
  %277 = load i8*, i8** %_M_p.i.i.i.i.i218, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i219 = ptrtoint i8* %add.ptr.i208 to i64
  %sub.ptr.sub.i.i.i.i.i220 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i219, ptrtoint ([28 x i8]* @.str.49 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i220, label %if.end.i.i.i.i.i.i.i223 [
    i64 1, label %if.then.i.i.i.i.i.i222
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit229
  ]

if.then.i.i.i.i.i.i222:                           ; preds = %if.end6.i.i.i.i221
  store i8 77, i8* %277, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit229

if.end.i.i.i.i.i.i.i223:                          ; preds = %if.end6.i.i.i.i221
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %277, i8* align 1 getelementptr inbounds ([28 x i8], [28 x i8]* @.str.49, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i220, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit229

lpad.i227:                                        ; preds = %if.then4.i.i.i.i214
  %278 = landingpad { i8*, i32 }
          cleanup
  %279 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp127 to %"class.std::allocator.0"*
  %280 = bitcast %"class.std::allocator.0"* %279 to %"class.__gnu_cxx::new_allocator.1"*
  %281 = extractvalue { i8*, i32 } %278, 0
  %282 = extractvalue { i8*, i32 } %278, 1
  br label %ehcleanup146

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit229: ; preds = %if.end.i.i.i.i.i.i.i223, %if.then.i.i.i.i.i.i222, %if.end6.i.i.i.i221
  %283 = load i64, i64* %__dnew.i.i.i.i203, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i224 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 1
  store i64 %283, i64* %_M_string_length.i.i.i.i.i.i224, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i225 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 0, i32 0
  %284 = load i8*, i8** %_M_p.i.i.i.i.i.i225, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i226 = getelementptr inbounds i8, i8* %284, i64 %283
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i202) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i202, align 1, !tbaa !27
  %285 = load i8, i8* %ref.tmp.i.i.i.i.i202, align 1, !tbaa !27
  store i8 %285, i8* %arrayidx.i.i.i.i.i226, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i202) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %273) #19
  %call133 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %207, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp127)
          to label %invoke.cont132 unwind label %lpad131

invoke.cont132:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit229
  %286 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp134 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %286) #19
  %287 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp135, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %287) #19
  %288 = bitcast %"class.std::allocator.0"* %ref.tmp135 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i233 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 0
  %289 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 2
  %arraydecay.i.i234 = bitcast %union.anon* %289 to i8*
  %290 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i233 to %"class.std::allocator.0"*
  %291 = bitcast %"class.std::allocator.0"* %290 to %"class.__gnu_cxx::new_allocator.1"*
  %292 = bitcast %"class.std::allocator.0"* %ref.tmp135 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i235 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i233, i64 0, i32 0
  store i8* %arraydecay.i.i234, i8** %_M_p.i.i235, align 8, !tbaa !48
  %call.i.i236 = call i64 @strlen(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.50, i64 0, i64 0)) #19
  %add.ptr.i237 = getelementptr inbounds i8, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.50, i64 0, i64 0), i64 %call.i.i236
  %cmp.i.i.i.i238 = icmp eq i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.50, i64 0, i64 0), %add.ptr.i237
  %293 = bitcast i64* %__dnew.i.i.i.i232 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %293) #19
  %294 = bitcast i8** %__first.addr.i.i.i.i.i230 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %294)
  store i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.50, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i230, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i239 = ptrtoint i8* %add.ptr.i237 to i64
  %sub.ptr.sub.i.i.i.i.i.i240 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i239, ptrtoint ([19 x i8]* @.str.50 to i64)
  %295 = bitcast i8** %__first.addr.i.i.i.i.i230 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %295)
  store i64 %sub.ptr.sub.i.i.i.i.i.i240, i64* %__dnew.i.i.i.i232, align 8, !tbaa !50
  %cmp3.i.i.i.i241 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i240, 15
  br i1 %cmp3.i.i.i.i241, label %if.then4.i.i.i.i243, label %if.end6.i.i.i.i250

if.then4.i.i.i.i243:                              ; preds = %invoke.cont132
  %call5.i.i.i1.i242 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp134, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i232, i64 0)
          to label %call5.i.i.i.noexc.i246 unwind label %lpad.i256

call5.i.i.i.noexc.i246:                           ; preds = %if.then4.i.i.i.i243
  %_M_p.i1.i.i.i.i244 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i242, i8** %_M_p.i1.i.i.i.i244, align 8, !tbaa !51
  %296 = load i64, i64* %__dnew.i.i.i.i232, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i245 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 2, i32 0
  store i64 %296, i64* %_M_allocated_capacity.i.i.i.i.i245, align 8, !tbaa !27
  br label %if.end6.i.i.i.i250

if.end6.i.i.i.i250:                               ; preds = %call5.i.i.i.noexc.i246, %invoke.cont132
  %_M_p.i.i.i.i.i247 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 0, i32 0
  %297 = load i8*, i8** %_M_p.i.i.i.i.i247, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i248 = ptrtoint i8* %add.ptr.i237 to i64
  %sub.ptr.sub.i.i.i.i.i249 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i248, ptrtoint ([19 x i8]* @.str.50 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i249, label %if.end.i.i.i.i.i.i.i252 [
    i64 1, label %if.then.i.i.i.i.i.i251
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit258
  ]

if.then.i.i.i.i.i.i251:                           ; preds = %if.end6.i.i.i.i250
  store i8 77, i8* %297, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit258

if.end.i.i.i.i.i.i.i252:                          ; preds = %if.end6.i.i.i.i250
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %297, i8* align 1 getelementptr inbounds ([19 x i8], [19 x i8]* @.str.50, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i249, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit258

lpad.i256:                                        ; preds = %if.then4.i.i.i.i243
  %298 = landingpad { i8*, i32 }
          cleanup
  %299 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp134 to %"class.std::allocator.0"*
  %300 = bitcast %"class.std::allocator.0"* %299 to %"class.__gnu_cxx::new_allocator.1"*
  %301 = extractvalue { i8*, i32 } %298, 0
  %302 = extractvalue { i8*, i32 } %298, 1
  br label %ehcleanup142

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit258: ; preds = %if.end.i.i.i.i.i.i.i252, %if.then.i.i.i.i.i.i251, %if.end6.i.i.i.i250
  %303 = load i64, i64* %__dnew.i.i.i.i232, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i253 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 1
  store i64 %303, i64* %_M_string_length.i.i.i.i.i.i253, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i254 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 0, i32 0
  %304 = load i8*, i8** %_M_p.i.i.i.i.i.i254, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i255 = getelementptr inbounds i8, i8* %304, i64 %303
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i231) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i231, align 1, !tbaa !27
  %305 = load i8, i8* %ref.tmp.i.i.i.i.i231, align 1, !tbaa !27
  store i8 %305, i8* %arrayidx.i.i.i.i.i255, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i231) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %293) #19
  %call140 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call133, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp134, double %sub55)
          to label %invoke.cont139 unwind label %lpad138

invoke.cont139:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit258
  %_M_p.i.i.i.i259 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 0, i32 0
  %306 = load i8*, i8** %_M_p.i.i.i.i259, align 8, !tbaa !51
  %307 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 2
  %arraydecay.i.i.i.i260 = bitcast %union.anon* %307 to i8*
  %cmp.i.i.i261 = icmp eq i8* %306, %arraydecay.i.i.i.i260
  br i1 %cmp.i.i.i261, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit267, label %if.then.i.i265

if.then.i.i265:                                   ; preds = %invoke.cont139
  %_M_allocated_capacity.i.i262 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 2, i32 0
  %308 = load i64, i64* %_M_allocated_capacity.i.i262, align 8, !tbaa !27
  %309 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp134 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i263 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 0, i32 0
  %310 = load i8*, i8** %_M_p.i.i1.i.i263, align 8, !tbaa !51
  %add.i.i.i264 = add i64 %308, 1
  %311 = bitcast %"class.std::allocator.0"* %309 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %310) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit267

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit267: ; preds = %if.then.i.i265, %invoke.cont139
  %312 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp134 to %"class.std::allocator.0"*
  %313 = bitcast %"class.std::allocator.0"* %312 to %"class.__gnu_cxx::new_allocator.1"*
  %314 = bitcast %"class.std::allocator.0"* %ref.tmp135 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %287) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %286) #19
  %_M_p.i.i.i.i268 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 0, i32 0
  %315 = load i8*, i8** %_M_p.i.i.i.i268, align 8, !tbaa !51
  %316 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 2
  %arraydecay.i.i.i.i269 = bitcast %union.anon* %316 to i8*
  %cmp.i.i.i270 = icmp eq i8* %315, %arraydecay.i.i.i.i269
  br i1 %cmp.i.i.i270, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit276, label %if.then.i.i274

if.then.i.i274:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit267
  %_M_allocated_capacity.i.i271 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 2, i32 0
  %317 = load i64, i64* %_M_allocated_capacity.i.i271, align 8, !tbaa !27
  %318 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp127 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i272 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 0, i32 0
  %319 = load i8*, i8** %_M_p.i.i1.i.i272, align 8, !tbaa !51
  %add.i.i.i273 = add i64 %317, 1
  %320 = bitcast %"class.std::allocator.0"* %318 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %319) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit276

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit276: ; preds = %if.then.i.i274, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit267
  %321 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp127 to %"class.std::allocator.0"*
  %322 = bitcast %"class.std::allocator.0"* %321 to %"class.__gnu_cxx::new_allocator.1"*
  %323 = bitcast %"class.std::allocator.0"* %ref.tmp128 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %267) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %266) #19
  %324 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp149 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %324) #19
  %325 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp150, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %325) #19
  %326 = bitcast %"class.std::allocator.0"* %ref.tmp150 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i280 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 0
  %327 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 2
  %arraydecay.i.i281 = bitcast %union.anon* %327 to i8*
  %328 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i280 to %"class.std::allocator.0"*
  %329 = bitcast %"class.std::allocator.0"* %328 to %"class.__gnu_cxx::new_allocator.1"*
  %330 = bitcast %"class.std::allocator.0"* %ref.tmp150 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i282 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i280, i64 0, i32 0
  store i8* %arraydecay.i.i281, i8** %_M_p.i.i282, align 8, !tbaa !48
  %call.i.i283 = call i64 @strlen(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0)) #19
  %add.ptr.i284 = getelementptr inbounds i8, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0), i64 %call.i.i283
  %cmp.i.i.i.i285 = icmp eq i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0), %add.ptr.i284
  %331 = bitcast i64* %__dnew.i.i.i.i279 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %331) #19
  %332 = bitcast i8** %__first.addr.i.i.i.i.i277 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %332)
  store i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i277, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i286 = ptrtoint i8* %add.ptr.i284 to i64
  %sub.ptr.sub.i.i.i.i.i.i287 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i286, ptrtoint ([12 x i8]* @.str.51 to i64)
  %333 = bitcast i8** %__first.addr.i.i.i.i.i277 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %333)
  store i64 %sub.ptr.sub.i.i.i.i.i.i287, i64* %__dnew.i.i.i.i279, align 8, !tbaa !50
  %cmp3.i.i.i.i288 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i287, 15
  br i1 %cmp3.i.i.i.i288, label %if.then4.i.i.i.i290, label %if.end6.i.i.i.i297

if.then4.i.i.i.i290:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit276
  %call5.i.i.i1.i289 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp149, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i279, i64 0)
          to label %call5.i.i.i.noexc.i293 unwind label %lpad.i303

call5.i.i.i.noexc.i293:                           ; preds = %if.then4.i.i.i.i290
  %_M_p.i1.i.i.i.i291 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i289, i8** %_M_p.i1.i.i.i.i291, align 8, !tbaa !51
  %334 = load i64, i64* %__dnew.i.i.i.i279, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i292 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 2, i32 0
  store i64 %334, i64* %_M_allocated_capacity.i.i.i.i.i292, align 8, !tbaa !27
  br label %if.end6.i.i.i.i297

if.end6.i.i.i.i297:                               ; preds = %call5.i.i.i.noexc.i293, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit276
  %_M_p.i.i.i.i.i294 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 0, i32 0
  %335 = load i8*, i8** %_M_p.i.i.i.i.i294, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i295 = ptrtoint i8* %add.ptr.i284 to i64
  %sub.ptr.sub.i.i.i.i.i296 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i295, ptrtoint ([12 x i8]* @.str.51 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i296, label %if.end.i.i.i.i.i.i.i299 [
    i64 1, label %if.then.i.i.i.i.i.i298
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit305
  ]

if.then.i.i.i.i.i.i298:                           ; preds = %if.end6.i.i.i.i297
  store i8 70, i8* %335, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit305

if.end.i.i.i.i.i.i.i299:                          ; preds = %if.end6.i.i.i.i297
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %335, i8* align 1 getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i296, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit305

lpad.i303:                                        ; preds = %if.then4.i.i.i.i290
  %336 = landingpad { i8*, i32 }
          cleanup
  %337 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp149 to %"class.std::allocator.0"*
  %338 = bitcast %"class.std::allocator.0"* %337 to %"class.__gnu_cxx::new_allocator.1"*
  %339 = extractvalue { i8*, i32 } %336, 0
  %340 = extractvalue { i8*, i32 } %336, 1
  br label %ehcleanup165

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit305: ; preds = %if.end.i.i.i.i.i.i.i299, %if.then.i.i.i.i.i.i298, %if.end6.i.i.i.i297
  %341 = load i64, i64* %__dnew.i.i.i.i279, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i300 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 1
  store i64 %341, i64* %_M_string_length.i.i.i.i.i.i300, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i301 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 0, i32 0
  %342 = load i8*, i8** %_M_p.i.i.i.i.i.i301, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i302 = getelementptr inbounds i8, i8* %342, i64 %341
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i278) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i278, align 1, !tbaa !27
  %343 = load i8, i8* %ref.tmp.i.i.i.i.i278, align 1, !tbaa !27
  store i8 %343, i8* %arrayidx.i.i.i.i.i302, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i278) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %331) #19
  %344 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp153 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %344) #19
  %345 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp154, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %345) #19
  %346 = bitcast %"class.std::allocator.0"* %ref.tmp154 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i309 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 0
  %347 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 2
  %arraydecay.i.i310 = bitcast %union.anon* %347 to i8*
  %348 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i309 to %"class.std::allocator.0"*
  %349 = bitcast %"class.std::allocator.0"* %348 to %"class.__gnu_cxx::new_allocator.1"*
  %350 = bitcast %"class.std::allocator.0"* %ref.tmp154 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i311 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i309, i64 0, i32 0
  store i8* %arraydecay.i.i310, i8** %_M_p.i.i311, align 8, !tbaa !48
  %call.i.i312 = call i64 @strlen(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0)) #19
  %add.ptr.i313 = getelementptr inbounds i8, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i64 %call.i.i312
  %cmp.i.i.i.i314 = icmp eq i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), %add.ptr.i313
  %351 = bitcast i64* %__dnew.i.i.i.i308 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %351) #19
  %352 = bitcast i8** %__first.addr.i.i.i.i.i306 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %352)
  store i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i306, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i315 = ptrtoint i8* %add.ptr.i313 to i64
  %sub.ptr.sub.i.i.i.i.i.i316 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i315, ptrtoint ([1 x i8]* @.str.5 to i64)
  %353 = bitcast i8** %__first.addr.i.i.i.i.i306 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %353)
  store i64 %sub.ptr.sub.i.i.i.i.i.i316, i64* %__dnew.i.i.i.i308, align 8, !tbaa !50
  %cmp3.i.i.i.i317 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i316, 15
  br i1 %cmp3.i.i.i.i317, label %if.then4.i.i.i.i319, label %if.end6.i.i.i.i326

if.then4.i.i.i.i319:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit305
  %call5.i.i.i1.i318 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp153, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i308, i64 0)
          to label %call5.i.i.i.noexc.i322 unwind label %lpad.i332

call5.i.i.i.noexc.i322:                           ; preds = %if.then4.i.i.i.i319
  %_M_p.i1.i.i.i.i320 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i318, i8** %_M_p.i1.i.i.i.i320, align 8, !tbaa !51
  %354 = load i64, i64* %__dnew.i.i.i.i308, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i321 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 2, i32 0
  store i64 %354, i64* %_M_allocated_capacity.i.i.i.i.i321, align 8, !tbaa !27
  br label %if.end6.i.i.i.i326

if.end6.i.i.i.i326:                               ; preds = %call5.i.i.i.noexc.i322, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit305
  %_M_p.i.i.i.i.i323 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 0, i32 0
  %355 = load i8*, i8** %_M_p.i.i.i.i.i323, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i324 = ptrtoint i8* %add.ptr.i313 to i64
  %sub.ptr.sub.i.i.i.i.i325 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i324, ptrtoint ([1 x i8]* @.str.5 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i325, label %if.end.i.i.i.i.i.i.i328 [
    i64 1, label %if.then.i.i.i.i.i.i327
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit334
  ]

if.then.i.i.i.i.i.i327:                           ; preds = %if.end6.i.i.i.i326
  store i8 0, i8* %355, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit334

if.end.i.i.i.i.i.i.i328:                          ; preds = %if.end6.i.i.i.i326
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %355, i8* align 1 getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i325, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit334

lpad.i332:                                        ; preds = %if.then4.i.i.i.i319
  %356 = landingpad { i8*, i32 }
          cleanup
  %357 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp153 to %"class.std::allocator.0"*
  %358 = bitcast %"class.std::allocator.0"* %357 to %"class.__gnu_cxx::new_allocator.1"*
  %359 = extractvalue { i8*, i32 } %356, 0
  %360 = extractvalue { i8*, i32 } %356, 1
  br label %ehcleanup161

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit334: ; preds = %if.end.i.i.i.i.i.i.i328, %if.then.i.i.i.i.i.i327, %if.end6.i.i.i.i326
  %361 = load i64, i64* %__dnew.i.i.i.i308, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i329 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 1
  store i64 %361, i64* %_M_string_length.i.i.i.i.i.i329, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i330 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 0, i32 0
  %362 = load i8*, i8** %_M_p.i.i.i.i.i.i330, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i331 = getelementptr inbounds i8, i8* %362, i64 %361
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i307) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i307, align 1, !tbaa !27
  %363 = load i8, i8* %ref.tmp.i.i.i.i.i307, align 1, !tbaa !27
  store i8 %363, i8* %arrayidx.i.i.i.i.i331, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i307) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %351) #19
  %call159 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* nonnull %207, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp149, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp153)
          to label %invoke.cont158 unwind label %lpad157

invoke.cont158:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit334
  %_M_p.i.i.i.i335 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 0, i32 0
  %364 = load i8*, i8** %_M_p.i.i.i.i335, align 8, !tbaa !51
  %365 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 2
  %arraydecay.i.i.i.i336 = bitcast %union.anon* %365 to i8*
  %cmp.i.i.i337 = icmp eq i8* %364, %arraydecay.i.i.i.i336
  br i1 %cmp.i.i.i337, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit343, label %if.then.i.i341

if.then.i.i341:                                   ; preds = %invoke.cont158
  %_M_allocated_capacity.i.i338 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 2, i32 0
  %366 = load i64, i64* %_M_allocated_capacity.i.i338, align 8, !tbaa !27
  %367 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp153 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i339 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 0, i32 0
  %368 = load i8*, i8** %_M_p.i.i1.i.i339, align 8, !tbaa !51
  %add.i.i.i340 = add i64 %366, 1
  %369 = bitcast %"class.std::allocator.0"* %367 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %368) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit343

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit343: ; preds = %if.then.i.i341, %invoke.cont158
  %370 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp153 to %"class.std::allocator.0"*
  %371 = bitcast %"class.std::allocator.0"* %370 to %"class.__gnu_cxx::new_allocator.1"*
  %372 = bitcast %"class.std::allocator.0"* %ref.tmp154 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %345) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %344) #19
  %_M_p.i.i.i.i344 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 0, i32 0
  %373 = load i8*, i8** %_M_p.i.i.i.i344, align 8, !tbaa !51
  %374 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 2
  %arraydecay.i.i.i.i345 = bitcast %union.anon* %374 to i8*
  %cmp.i.i.i346 = icmp eq i8* %373, %arraydecay.i.i.i.i345
  br i1 %cmp.i.i.i346, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit352, label %if.then.i.i350

if.then.i.i350:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit343
  %_M_allocated_capacity.i.i347 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 2, i32 0
  %375 = load i64, i64* %_M_allocated_capacity.i.i347, align 8, !tbaa !27
  %376 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp149 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i348 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 0, i32 0
  %377 = load i8*, i8** %_M_p.i.i1.i.i348, align 8, !tbaa !51
  %add.i.i.i349 = add i64 %375, 1
  %378 = bitcast %"class.std::allocator.0"* %376 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %377) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit352

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit352: ; preds = %if.then.i.i350, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit343
  %379 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp149 to %"class.std::allocator.0"*
  %380 = bitcast %"class.std::allocator.0"* %379 to %"class.__gnu_cxx::new_allocator.1"*
  %381 = bitcast %"class.std::allocator.0"* %ref.tmp150 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %325) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %324) #19
  %382 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp168 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %382) #19
  %383 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp169, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %383) #19
  %384 = bitcast %"class.std::allocator.0"* %ref.tmp169 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i356 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 0
  %385 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 2
  %arraydecay.i.i357 = bitcast %union.anon* %385 to i8*
  %386 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i356 to %"class.std::allocator.0"*
  %387 = bitcast %"class.std::allocator.0"* %386 to %"class.__gnu_cxx::new_allocator.1"*
  %388 = bitcast %"class.std::allocator.0"* %ref.tmp169 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i358 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i356, i64 0, i32 0
  store i8* %arraydecay.i.i357, i8** %_M_p.i.i358, align 8, !tbaa !48
  %call.i.i359 = call i64 @strlen(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0)) #19
  %add.ptr.i360 = getelementptr inbounds i8, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0), i64 %call.i.i359
  %cmp.i.i.i.i361 = icmp eq i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0), %add.ptr.i360
  %389 = bitcast i64* %__dnew.i.i.i.i355 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %389) #19
  %390 = bitcast i8** %__first.addr.i.i.i.i.i353 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %390)
  store i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i353, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i362 = ptrtoint i8* %add.ptr.i360 to i64
  %sub.ptr.sub.i.i.i.i.i.i363 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i362, ptrtoint ([12 x i8]* @.str.51 to i64)
  %391 = bitcast i8** %__first.addr.i.i.i.i.i353 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %391)
  store i64 %sub.ptr.sub.i.i.i.i.i.i363, i64* %__dnew.i.i.i.i355, align 8, !tbaa !50
  %cmp3.i.i.i.i364 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i363, 15
  br i1 %cmp3.i.i.i.i364, label %if.then4.i.i.i.i366, label %if.end6.i.i.i.i373

if.then4.i.i.i.i366:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit352
  %call5.i.i.i1.i365 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp168, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i355, i64 0)
          to label %call5.i.i.i.noexc.i369 unwind label %lpad.i379

call5.i.i.i.noexc.i369:                           ; preds = %if.then4.i.i.i.i366
  %_M_p.i1.i.i.i.i367 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i365, i8** %_M_p.i1.i.i.i.i367, align 8, !tbaa !51
  %392 = load i64, i64* %__dnew.i.i.i.i355, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i368 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 2, i32 0
  store i64 %392, i64* %_M_allocated_capacity.i.i.i.i.i368, align 8, !tbaa !27
  br label %if.end6.i.i.i.i373

if.end6.i.i.i.i373:                               ; preds = %call5.i.i.i.noexc.i369, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit352
  %_M_p.i.i.i.i.i370 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 0, i32 0
  %393 = load i8*, i8** %_M_p.i.i.i.i.i370, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i371 = ptrtoint i8* %add.ptr.i360 to i64
  %sub.ptr.sub.i.i.i.i.i372 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i371, ptrtoint ([12 x i8]* @.str.51 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i372, label %if.end.i.i.i.i.i.i.i375 [
    i64 1, label %if.then.i.i.i.i.i.i374
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit381
  ]

if.then.i.i.i.i.i.i374:                           ; preds = %if.end6.i.i.i.i373
  store i8 70, i8* %393, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit381

if.end.i.i.i.i.i.i.i375:                          ; preds = %if.end6.i.i.i.i373
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %393, i8* align 1 getelementptr inbounds ([12 x i8], [12 x i8]* @.str.51, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i372, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit381

lpad.i379:                                        ; preds = %if.then4.i.i.i.i366
  %394 = landingpad { i8*, i32 }
          cleanup
  %395 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp168 to %"class.std::allocator.0"*
  %396 = bitcast %"class.std::allocator.0"* %395 to %"class.__gnu_cxx::new_allocator.1"*
  %397 = extractvalue { i8*, i32 } %394, 0
  %398 = extractvalue { i8*, i32 } %394, 1
  br label %ehcleanup187

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit381: ; preds = %if.end.i.i.i.i.i.i.i375, %if.then.i.i.i.i.i.i374, %if.end6.i.i.i.i373
  %399 = load i64, i64* %__dnew.i.i.i.i355, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i376 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 1
  store i64 %399, i64* %_M_string_length.i.i.i.i.i.i376, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i377 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 0, i32 0
  %400 = load i8*, i8** %_M_p.i.i.i.i.i.i377, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i378 = getelementptr inbounds i8, i8* %400, i64 %399
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i354) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i354, align 1, !tbaa !27
  %401 = load i8, i8* %ref.tmp.i.i.i.i.i354, align 1, !tbaa !27
  store i8 %401, i8* %arrayidx.i.i.i.i.i378, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i354) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %389) #19
  %call174 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %207, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp168)
          to label %invoke.cont173 unwind label %lpad172

invoke.cont173:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit381
  %402 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp175 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %402) #19
  %403 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp176, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %403) #19
  %404 = bitcast %"class.std::allocator.0"* %ref.tmp176 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i385 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 0
  %405 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 2
  %arraydecay.i.i386 = bitcast %union.anon* %405 to i8*
  %406 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i385 to %"class.std::allocator.0"*
  %407 = bitcast %"class.std::allocator.0"* %406 to %"class.__gnu_cxx::new_allocator.1"*
  %408 = bitcast %"class.std::allocator.0"* %ref.tmp176 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i387 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i385, i64 0, i32 0
  store i8* %arraydecay.i.i386, i8** %_M_p.i.i387, align 8, !tbaa !48
  %call.i.i388 = call i64 @strlen(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.52, i64 0, i64 0)) #19
  %add.ptr.i389 = getelementptr inbounds i8, i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.52, i64 0, i64 0), i64 %call.i.i388
  %cmp.i.i.i.i390 = icmp eq i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.52, i64 0, i64 0), %add.ptr.i389
  %409 = bitcast i64* %__dnew.i.i.i.i384 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %409) #19
  %410 = bitcast i8** %__first.addr.i.i.i.i.i382 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %410)
  store i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.52, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i382, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i391 = ptrtoint i8* %add.ptr.i389 to i64
  %sub.ptr.sub.i.i.i.i.i.i392 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i391, ptrtoint ([17 x i8]* @.str.52 to i64)
  %411 = bitcast i8** %__first.addr.i.i.i.i.i382 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %411)
  store i64 %sub.ptr.sub.i.i.i.i.i.i392, i64* %__dnew.i.i.i.i384, align 8, !tbaa !50
  %cmp3.i.i.i.i393 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i392, 15
  br i1 %cmp3.i.i.i.i393, label %if.then4.i.i.i.i395, label %if.end6.i.i.i.i402

if.then4.i.i.i.i395:                              ; preds = %invoke.cont173
  %call5.i.i.i1.i394 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp175, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i384, i64 0)
          to label %call5.i.i.i.noexc.i398 unwind label %lpad.i408

call5.i.i.i.noexc.i398:                           ; preds = %if.then4.i.i.i.i395
  %_M_p.i1.i.i.i.i396 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i394, i8** %_M_p.i1.i.i.i.i396, align 8, !tbaa !51
  %412 = load i64, i64* %__dnew.i.i.i.i384, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i397 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 2, i32 0
  store i64 %412, i64* %_M_allocated_capacity.i.i.i.i.i397, align 8, !tbaa !27
  br label %if.end6.i.i.i.i402

if.end6.i.i.i.i402:                               ; preds = %call5.i.i.i.noexc.i398, %invoke.cont173
  %_M_p.i.i.i.i.i399 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 0, i32 0
  %413 = load i8*, i8** %_M_p.i.i.i.i.i399, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i400 = ptrtoint i8* %add.ptr.i389 to i64
  %sub.ptr.sub.i.i.i.i.i401 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i400, ptrtoint ([17 x i8]* @.str.52 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i401, label %if.end.i.i.i.i.i.i.i404 [
    i64 1, label %if.then.i.i.i.i.i.i403
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit410
  ]

if.then.i.i.i.i.i.i403:                           ; preds = %if.end6.i.i.i.i402
  store i8 70, i8* %413, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit410

if.end.i.i.i.i.i.i.i404:                          ; preds = %if.end6.i.i.i.i402
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %413, i8* align 1 getelementptr inbounds ([17 x i8], [17 x i8]* @.str.52, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i401, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit410

lpad.i408:                                        ; preds = %if.then4.i.i.i.i395
  %414 = landingpad { i8*, i32 }
          cleanup
  %415 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp175 to %"class.std::allocator.0"*
  %416 = bitcast %"class.std::allocator.0"* %415 to %"class.__gnu_cxx::new_allocator.1"*
  %417 = extractvalue { i8*, i32 } %414, 0
  %418 = extractvalue { i8*, i32 } %414, 1
  br label %ehcleanup183

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit410: ; preds = %if.end.i.i.i.i.i.i.i404, %if.then.i.i.i.i.i.i403, %if.end6.i.i.i.i402
  %419 = load i64, i64* %__dnew.i.i.i.i384, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i405 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 1
  store i64 %419, i64* %_M_string_length.i.i.i.i.i.i405, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i406 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 0, i32 0
  %420 = load i8*, i8** %_M_p.i.i.i.i.i.i406, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i407 = getelementptr inbounds i8, i8* %420, i64 %419
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i383) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i383, align 1, !tbaa !27
  %421 = load i8, i8* %ref.tmp.i.i.i.i.i383, align 1, !tbaa !27
  store i8 %421, i8* %arrayidx.i.i.i.i.i407, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i383) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %409) #19
  %call181 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call174, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp175, double %sub96)
          to label %if.end190 unwind label %lpad179

lpad118:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit172
  %422 = landingpad { i8*, i32 }
          cleanup
  %423 = extractvalue { i8*, i32 } %422, 0
  %424 = extractvalue { i8*, i32 } %422, 1
  %_M_p.i.i.i.i411 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 0, i32 0
  %425 = load i8*, i8** %_M_p.i.i.i.i411, align 8, !tbaa !51
  %426 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 2
  %arraydecay.i.i.i.i412 = bitcast %union.anon* %426 to i8*
  %cmp.i.i.i413 = icmp eq i8* %425, %arraydecay.i.i.i.i412
  br i1 %cmp.i.i.i413, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit419, label %if.then.i.i417

if.then.i.i417:                                   ; preds = %lpad118
  %_M_allocated_capacity.i.i414 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 2, i32 0
  %427 = load i64, i64* %_M_allocated_capacity.i.i414, align 8, !tbaa !27
  %428 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp114 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i415 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp114, i64 0, i32 0, i32 0
  %429 = load i8*, i8** %_M_p.i.i1.i.i415, align 8, !tbaa !51
  %add.i.i.i416 = add i64 %427, 1
  %430 = bitcast %"class.std::allocator.0"* %428 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %429) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit419

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit419: ; preds = %if.then.i.i417, %lpad118
  %431 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp114 to %"class.std::allocator.0"*
  %432 = bitcast %"class.std::allocator.0"* %431 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup

ehcleanup:                                        ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit419, %lpad.i170
  %ehselector.slot.0 = phi i32 [ %424, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit419 ], [ %244, %lpad.i170 ]
  %exn.slot.0 = phi i8* [ %423, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit419 ], [ %243, %lpad.i170 ]
  %433 = bitcast %"class.std::allocator.0"* %ref.tmp115 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %229) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %228) #19
  %_M_p.i.i.i.i420 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 0, i32 0
  %434 = load i8*, i8** %_M_p.i.i.i.i420, align 8, !tbaa !51
  %435 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 2
  %arraydecay.i.i.i.i421 = bitcast %union.anon* %435 to i8*
  %cmp.i.i.i422 = icmp eq i8* %434, %arraydecay.i.i.i.i421
  br i1 %cmp.i.i.i422, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit428, label %if.then.i.i426

if.then.i.i426:                                   ; preds = %ehcleanup
  %_M_allocated_capacity.i.i423 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 2, i32 0
  %436 = load i64, i64* %_M_allocated_capacity.i.i423, align 8, !tbaa !27
  %437 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i424 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp, i64 0, i32 0, i32 0
  %438 = load i8*, i8** %_M_p.i.i1.i.i424, align 8, !tbaa !51
  %add.i.i.i425 = add i64 %436, 1
  %439 = bitcast %"class.std::allocator.0"* %437 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %438) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit428

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit428: ; preds = %if.then.i.i426, %ehcleanup
  %440 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp to %"class.std::allocator.0"*
  %441 = bitcast %"class.std::allocator.0"* %440 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup124

ehcleanup124:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit428, %lpad.i142
  %ehselector.slot.1 = phi i32 [ %ehselector.slot.0, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit428 ], [ %224, %lpad.i142 ]
  %exn.slot.1 = phi i8* [ %exn.slot.0, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit428 ], [ %223, %lpad.i142 ]
  %442 = bitcast %"class.std::allocator.0"* %ref.tmp111 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %209) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %208) #19
  br label %ehcleanup911

lpad131:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit229
  %443 = landingpad { i8*, i32 }
          cleanup
  %444 = extractvalue { i8*, i32 } %443, 0
  %445 = extractvalue { i8*, i32 } %443, 1
  br label %ehcleanup145

lpad138:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit258
  %446 = landingpad { i8*, i32 }
          cleanup
  %447 = extractvalue { i8*, i32 } %446, 0
  %448 = extractvalue { i8*, i32 } %446, 1
  %_M_p.i.i.i.i429 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 0, i32 0
  %449 = load i8*, i8** %_M_p.i.i.i.i429, align 8, !tbaa !51
  %450 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 2
  %arraydecay.i.i.i.i430 = bitcast %union.anon* %450 to i8*
  %cmp.i.i.i431 = icmp eq i8* %449, %arraydecay.i.i.i.i430
  br i1 %cmp.i.i.i431, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit437, label %if.then.i.i435

if.then.i.i435:                                   ; preds = %lpad138
  %_M_allocated_capacity.i.i432 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 2, i32 0
  %451 = load i64, i64* %_M_allocated_capacity.i.i432, align 8, !tbaa !27
  %452 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp134 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i433 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp134, i64 0, i32 0, i32 0
  %453 = load i8*, i8** %_M_p.i.i1.i.i433, align 8, !tbaa !51
  %add.i.i.i434 = add i64 %451, 1
  %454 = bitcast %"class.std::allocator.0"* %452 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %453) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit437

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit437: ; preds = %if.then.i.i435, %lpad138
  %455 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp134 to %"class.std::allocator.0"*
  %456 = bitcast %"class.std::allocator.0"* %455 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup142

ehcleanup142:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit437, %lpad.i256
  %ehselector.slot.2 = phi i32 [ %448, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit437 ], [ %302, %lpad.i256 ]
  %exn.slot.2 = phi i8* [ %447, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit437 ], [ %301, %lpad.i256 ]
  %457 = bitcast %"class.std::allocator.0"* %ref.tmp135 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %287) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %286) #19
  br label %ehcleanup145

ehcleanup145:                                     ; preds = %ehcleanup142, %lpad131
  %ehselector.slot.3 = phi i32 [ %ehselector.slot.2, %ehcleanup142 ], [ %445, %lpad131 ]
  %exn.slot.3 = phi i8* [ %exn.slot.2, %ehcleanup142 ], [ %444, %lpad131 ]
  %_M_p.i.i.i.i438 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 0, i32 0
  %458 = load i8*, i8** %_M_p.i.i.i.i438, align 8, !tbaa !51
  %459 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 2
  %arraydecay.i.i.i.i439 = bitcast %union.anon* %459 to i8*
  %cmp.i.i.i440 = icmp eq i8* %458, %arraydecay.i.i.i.i439
  br i1 %cmp.i.i.i440, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit446, label %if.then.i.i444

if.then.i.i444:                                   ; preds = %ehcleanup145
  %_M_allocated_capacity.i.i441 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 2, i32 0
  %460 = load i64, i64* %_M_allocated_capacity.i.i441, align 8, !tbaa !27
  %461 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp127 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i442 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp127, i64 0, i32 0, i32 0
  %462 = load i8*, i8** %_M_p.i.i1.i.i442, align 8, !tbaa !51
  %add.i.i.i443 = add i64 %460, 1
  %463 = bitcast %"class.std::allocator.0"* %461 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %462) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit446

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit446: ; preds = %if.then.i.i444, %ehcleanup145
  %464 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp127 to %"class.std::allocator.0"*
  %465 = bitcast %"class.std::allocator.0"* %464 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup146

ehcleanup146:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit446, %lpad.i227
  %ehselector.slot.4 = phi i32 [ %ehselector.slot.3, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit446 ], [ %282, %lpad.i227 ]
  %exn.slot.4 = phi i8* [ %exn.slot.3, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit446 ], [ %281, %lpad.i227 ]
  %466 = bitcast %"class.std::allocator.0"* %ref.tmp128 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %267) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %266) #19
  br label %ehcleanup911

lpad157:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit334
  %467 = landingpad { i8*, i32 }
          cleanup
  %468 = extractvalue { i8*, i32 } %467, 0
  %469 = extractvalue { i8*, i32 } %467, 1
  %_M_p.i.i.i.i447 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 0, i32 0
  %470 = load i8*, i8** %_M_p.i.i.i.i447, align 8, !tbaa !51
  %471 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 2
  %arraydecay.i.i.i.i448 = bitcast %union.anon* %471 to i8*
  %cmp.i.i.i449 = icmp eq i8* %470, %arraydecay.i.i.i.i448
  br i1 %cmp.i.i.i449, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit455, label %if.then.i.i453

if.then.i.i453:                                   ; preds = %lpad157
  %_M_allocated_capacity.i.i450 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 2, i32 0
  %472 = load i64, i64* %_M_allocated_capacity.i.i450, align 8, !tbaa !27
  %473 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp153 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i451 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp153, i64 0, i32 0, i32 0
  %474 = load i8*, i8** %_M_p.i.i1.i.i451, align 8, !tbaa !51
  %add.i.i.i452 = add i64 %472, 1
  %475 = bitcast %"class.std::allocator.0"* %473 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %474) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit455

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit455: ; preds = %if.then.i.i453, %lpad157
  %476 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp153 to %"class.std::allocator.0"*
  %477 = bitcast %"class.std::allocator.0"* %476 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup161

ehcleanup161:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit455, %lpad.i332
  %ehselector.slot.5 = phi i32 [ %469, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit455 ], [ %360, %lpad.i332 ]
  %exn.slot.5 = phi i8* [ %468, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit455 ], [ %359, %lpad.i332 ]
  %478 = bitcast %"class.std::allocator.0"* %ref.tmp154 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %345) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %344) #19
  %_M_p.i.i.i.i456 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 0, i32 0
  %479 = load i8*, i8** %_M_p.i.i.i.i456, align 8, !tbaa !51
  %480 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 2
  %arraydecay.i.i.i.i457 = bitcast %union.anon* %480 to i8*
  %cmp.i.i.i458 = icmp eq i8* %479, %arraydecay.i.i.i.i457
  br i1 %cmp.i.i.i458, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit464, label %if.then.i.i462

if.then.i.i462:                                   ; preds = %ehcleanup161
  %_M_allocated_capacity.i.i459 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 2, i32 0
  %481 = load i64, i64* %_M_allocated_capacity.i.i459, align 8, !tbaa !27
  %482 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp149 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i460 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp149, i64 0, i32 0, i32 0
  %483 = load i8*, i8** %_M_p.i.i1.i.i460, align 8, !tbaa !51
  %add.i.i.i461 = add i64 %481, 1
  %484 = bitcast %"class.std::allocator.0"* %482 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %483) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit464

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit464: ; preds = %if.then.i.i462, %ehcleanup161
  %485 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp149 to %"class.std::allocator.0"*
  %486 = bitcast %"class.std::allocator.0"* %485 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup165

ehcleanup165:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit464, %lpad.i303
  %ehselector.slot.6 = phi i32 [ %ehselector.slot.5, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit464 ], [ %340, %lpad.i303 ]
  %exn.slot.6 = phi i8* [ %exn.slot.5, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit464 ], [ %339, %lpad.i303 ]
  %487 = bitcast %"class.std::allocator.0"* %ref.tmp150 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %325) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %324) #19
  br label %ehcleanup911

lpad172:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit381
  %488 = landingpad { i8*, i32 }
          cleanup
  %489 = extractvalue { i8*, i32 } %488, 0
  %490 = extractvalue { i8*, i32 } %488, 1
  br label %ehcleanup186

lpad179:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit410
  %491 = landingpad { i8*, i32 }
          cleanup
  %492 = extractvalue { i8*, i32 } %491, 0
  %493 = extractvalue { i8*, i32 } %491, 1
  %_M_p.i.i.i.i465 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 0, i32 0
  %494 = load i8*, i8** %_M_p.i.i.i.i465, align 8, !tbaa !51
  %495 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 2
  %arraydecay.i.i.i.i466 = bitcast %union.anon* %495 to i8*
  %cmp.i.i.i467 = icmp eq i8* %494, %arraydecay.i.i.i.i466
  br i1 %cmp.i.i.i467, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit473, label %if.then.i.i471

if.then.i.i471:                                   ; preds = %lpad179
  %_M_allocated_capacity.i.i468 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 2, i32 0
  %496 = load i64, i64* %_M_allocated_capacity.i.i468, align 8, !tbaa !27
  %497 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp175 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i469 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 0, i32 0
  %498 = load i8*, i8** %_M_p.i.i1.i.i469, align 8, !tbaa !51
  %add.i.i.i470 = add i64 %496, 1
  %499 = bitcast %"class.std::allocator.0"* %497 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %498) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit473

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit473: ; preds = %if.then.i.i471, %lpad179
  %500 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp175 to %"class.std::allocator.0"*
  %501 = bitcast %"class.std::allocator.0"* %500 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup183

ehcleanup183:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit473, %lpad.i408
  %ehselector.slot.7 = phi i32 [ %493, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit473 ], [ %418, %lpad.i408 ]
  %exn.slot.7 = phi i8* [ %492, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit473 ], [ %417, %lpad.i408 ]
  %502 = bitcast %"class.std::allocator.0"* %ref.tmp176 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %403) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %402) #19
  br label %ehcleanup186

ehcleanup186:                                     ; preds = %ehcleanup183, %lpad172
  %ehselector.slot.8 = phi i32 [ %ehselector.slot.7, %ehcleanup183 ], [ %490, %lpad172 ]
  %exn.slot.8 = phi i8* [ %exn.slot.7, %ehcleanup183 ], [ %489, %lpad172 ]
  %_M_p.i.i.i.i474 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 0, i32 0
  %503 = load i8*, i8** %_M_p.i.i.i.i474, align 8, !tbaa !51
  %504 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 2
  %arraydecay.i.i.i.i475 = bitcast %union.anon* %504 to i8*
  %cmp.i.i.i476 = icmp eq i8* %503, %arraydecay.i.i.i.i475
  br i1 %cmp.i.i.i476, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit482, label %if.then.i.i480

if.then.i.i480:                                   ; preds = %ehcleanup186
  %_M_allocated_capacity.i.i477 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 2, i32 0
  %505 = load i64, i64* %_M_allocated_capacity.i.i477, align 8, !tbaa !27
  %506 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp168 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i478 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 0, i32 0
  %507 = load i8*, i8** %_M_p.i.i1.i.i478, align 8, !tbaa !51
  %add.i.i.i479 = add i64 %505, 1
  %508 = bitcast %"class.std::allocator.0"* %506 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %507) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit482

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit482: ; preds = %if.then.i.i480, %ehcleanup186
  %509 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp168 to %"class.std::allocator.0"*
  %510 = bitcast %"class.std::allocator.0"* %509 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup187

ehcleanup187:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit482, %lpad.i379
  %ehselector.slot.9 = phi i32 [ %ehselector.slot.8, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit482 ], [ %398, %lpad.i379 ]
  %exn.slot.9 = phi i8* [ %exn.slot.8, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit482 ], [ %397, %lpad.i379 ]
  %511 = bitcast %"class.std::allocator.0"* %ref.tmp169 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %383) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %382) #19
  br label %ehcleanup911

if.end190:                                        ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit410
  %_M_p.i.i.i.i483 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 0, i32 0
  %512 = load i8*, i8** %_M_p.i.i.i.i483, align 8, !tbaa !51
  %513 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 2
  %arraydecay.i.i.i.i484 = bitcast %union.anon* %513 to i8*
  %cmp.i.i.i485 = icmp eq i8* %512, %arraydecay.i.i.i.i484
  br i1 %cmp.i.i.i485, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit491, label %if.then.i.i489

if.then.i.i489:                                   ; preds = %if.end190
  %_M_allocated_capacity.i.i486 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 2, i32 0
  %514 = load i64, i64* %_M_allocated_capacity.i.i486, align 8, !tbaa !27
  %515 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp175 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i487 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp175, i64 0, i32 0, i32 0
  %516 = load i8*, i8** %_M_p.i.i1.i.i487, align 8, !tbaa !51
  %add.i.i.i488 = add i64 %514, 1
  %517 = bitcast %"class.std::allocator.0"* %515 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %516) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit491

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit491: ; preds = %if.then.i.i489, %if.end190
  %518 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp175 to %"class.std::allocator.0"*
  %519 = bitcast %"class.std::allocator.0"* %518 to %"class.__gnu_cxx::new_allocator.1"*
  %520 = bitcast %"class.std::allocator.0"* %ref.tmp176 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %403) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %402) #19
  %_M_p.i.i.i.i492 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 0, i32 0
  %521 = load i8*, i8** %_M_p.i.i.i.i492, align 8, !tbaa !51
  %522 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 2
  %arraydecay.i.i.i.i493 = bitcast %union.anon* %522 to i8*
  %cmp.i.i.i494 = icmp eq i8* %521, %arraydecay.i.i.i.i493
  br i1 %cmp.i.i.i494, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit500, label %if.then.i.i498

if.then.i.i498:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit491
  %_M_allocated_capacity.i.i495 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 2, i32 0
  %523 = load i64, i64* %_M_allocated_capacity.i.i495, align 8, !tbaa !27
  %524 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp168 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i496 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp168, i64 0, i32 0, i32 0
  %525 = load i8*, i8** %_M_p.i.i1.i.i496, align 8, !tbaa !51
  %add.i.i.i497 = add i64 %523, 1
  %526 = bitcast %"class.std::allocator.0"* %524 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %525) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit500

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit500: ; preds = %if.then.i.i498, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit491
  %527 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp168 to %"class.std::allocator.0"*
  %528 = bitcast %"class.std::allocator.0"* %527 to %"class.__gnu_cxx::new_allocator.1"*
  %529 = bitcast %"class.std::allocator.0"* %ref.tmp169 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %383) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %382) #19
  %.pr1083 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp191 = icmp eq i32 %.pr1083, 0
  br i1 %cmp191, label %if.then192, label %if.end204

if.then192:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit500
  %vtable193 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8**), align 8, !tbaa !14
  %vbase.offset.ptr194 = getelementptr i8, i8* %vtable193, i64 -24
  %530 = bitcast i8* %vbase.offset.ptr194 to i64*
  %vbase.offset195 = load i64, i64* %530, align 8
  %add.ptr196 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8*), i64 %vbase.offset195
  %531 = bitcast i8* %add.ptr196 to %"class.std::ios_base"*
  %_M_width.i501 = getelementptr inbounds %"class.std::ios_base", %"class.std::ios_base"* %531, i64 0, i32 2
  %532 = load i64, i64* %_M_width.i501, align 8, !tbaa !16
  store i64 30, i64* %_M_width.i501, align 8, !tbaa !16
  %call.i.i502 = call i64 @strlen(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.53, i64 0, i64 0)) #19
  %call1.i503504 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([25 x i8], [25 x i8]* @.str.53, i64 0, i64 0), i64 %call.i.i502)
          to label %invoke.cont200 unwind label %lpad197

invoke.cont200:                                   ; preds = %if.then192
  %call203 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull @_ZSt4cout)
          to label %if.end204 unwind label %lpad197

lpad197:                                          ; preds = %invoke.cont237, %if.then230, %invoke.cont200, %if.then192
  %533 = landingpad { i8*, i32 }
          cleanup
  %534 = extractvalue { i8*, i32 } %533, 0
  %535 = extractvalue { i8*, i32 } %533, 1
  br label %ehcleanup911

if.end204:                                        ; preds = %invoke.cont200, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit500, %if.end108, %invoke.cont94
  %call208 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont207 unwind label %lpad206

invoke.cont207:                                   ; preds = %if.end204
  %add209 = add nsw i32 %0, 1
  %add210 = add nsw i32 %1, 1
  %add211 = add nsw i32 %2, 1
  %bc_rows_0 = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 0
  invoke void @_ZN6miniFE16impose_dirichletINS_9CSRMatrixIdiiEENS_6VectorIdiiEEEEvNT_10ScalarTypeERS5_RT0_iiiRKSt3setINS5_17GlobalOrdinalTypeESt4lessISB_ESaISB_EE(double 0.000000e+00, %"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A, %"struct.miniFE::Vector"* nonnull dereferenceable(32) %b, i32 %add209, i32 %add210, i32 %add211, %"class.std::set"* nonnull dereferenceable(48) %bc_rows_0)
          to label %invoke.cont212 unwind label %lpad206

invoke.cont212:                                   ; preds = %invoke.cont207
  %call214 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont213 unwind label %lpad206

invoke.cont213:                                   ; preds = %invoke.cont212
  %sub215 = fsub double %call214, %call208
  %add216 = fadd double %add97, %sub215
  %536 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp217 = icmp eq i32 %536, 0
  br i1 %cmp217, label %if.then218, label %if.end241

if.then218:                                       ; preds = %invoke.cont213
  %call.i507 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* @_ZSt4cout, double %sub215)
          to label %invoke.cont219 unwind label %lpad206

invoke.cont219:                                   ; preds = %if.then218
  %call.i.i509 = call i64 @strlen(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0)) #19
  %call1.i510511 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i507, i8* nonnull getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0), i64 %call.i.i509)
          to label %invoke.cont221 unwind label %lpad206

invoke.cont221:                                   ; preds = %invoke.cont219
  %call.i514 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* %call.i507, double %add216)
          to label %invoke.cont223 unwind label %lpad206

invoke.cont223:                                   ; preds = %invoke.cont221
  %537 = bitcast %"class.std::basic_ostream"* %call.i514 to i8**
  %vtable.i519 = load i8*, i8** %537, align 8, !tbaa !14
  %vbase.offset.ptr.i520 = getelementptr i8, i8* %vtable.i519, i64 -24
  %538 = bitcast i8* %vbase.offset.ptr.i520 to i64*
  %vbase.offset.i521 = load i64, i64* %538, align 8
  %539 = bitcast %"class.std::basic_ostream"* %call.i514 to i8*
  %add.ptr.i522 = getelementptr inbounds i8, i8* %539, i64 %vbase.offset.i521
  %540 = bitcast i8* %add.ptr.i522 to %"class.std::basic_ios"*
  %_M_ctype.i1308 = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %540, i64 0, i32 5
  %541 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i1308, align 8, !tbaa !22
  %tobool.i.i1309 = icmp eq %"class.std::ctype"* %541, null
  br i1 %tobool.i.i1309, label %if.then.i.i1310, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1313

if.then.i.i1310:                                  ; preds = %invoke.cont223
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc1321 unwind label %lpad206

.noexc1321:                                       ; preds = %if.then.i.i1310
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1313: ; preds = %invoke.cont223
  %_M_widen_ok.i.i1311 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %541, i64 0, i32 8
  %542 = load i8, i8* %_M_widen_ok.i.i1311, align 8, !tbaa !25
  %tobool.i1.i1312 = icmp eq i8 %542, 0
  br i1 %tobool.i1.i1312, label %if.end.i.i1319, label %if.then.i2.i1315

if.then.i2.i1315:                                 ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1313
  %arrayidx.i.i1314 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %541, i64 0, i32 9, i64 10
  %543 = load i8, i8* %arrayidx.i.i1314, align 1, !tbaa !27
  br label %call.i.noexc524

if.end.i.i1319:                                   ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1313
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %541)
          to label %.noexc1322 unwind label %lpad206

.noexc1322:                                       ; preds = %if.end.i.i1319
  %544 = bitcast %"class.std::ctype"* %541 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i1316 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %544, align 8, !tbaa !14
  %vfn.i.i1317 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i1316, i64 6
  %545 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i1317, align 8
  %call.i.i13181323 = invoke signext i8 %545(%"class.std::ctype"* nonnull %541, i8 signext 10)
          to label %call.i.noexc524 unwind label %lpad206

call.i.noexc524:                                  ; preds = %.noexc1322, %if.then.i2.i1315
  %retval.0.i.i1320 = phi i8 [ %543, %if.then.i2.i1315 ], [ %call.i.i13181323, %.noexc1322 ]
  %call1.i523526 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i514, i8 signext %retval.0.i.i1320)
          to label %call1.i523.noexc unwind label %lpad206

call1.i523.noexc:                                 ; preds = %call.i.noexc524
  %call.i530 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i523526)
          to label %if.end227 unwind label %lpad206

lpad206:                                          ; preds = %call1.i523.noexc, %call.i.noexc524, %.noexc1322, %if.end.i.i1319, %if.then.i.i1310, %invoke.cont221, %invoke.cont219, %if.then218, %invoke.cont212, %invoke.cont207, %if.end204
  %546 = landingpad { i8*, i32 }
          cleanup
  %547 = extractvalue { i8*, i32 } %546, 0
  %548 = extractvalue { i8*, i32 } %546, 1
  br label %ehcleanup911

if.end227:                                        ; preds = %call1.i523.noexc
  %.pr1085 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp229 = icmp eq i32 %.pr1085, 0
  br i1 %cmp229, label %if.then230, label %if.end241

if.then230:                                       ; preds = %if.end227
  %vtable231 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8**), align 8, !tbaa !14
  %vbase.offset.ptr232 = getelementptr i8, i8* %vtable231, i64 -24
  %549 = bitcast i8* %vbase.offset.ptr232 to i64*
  %vbase.offset233 = load i64, i64* %549, align 8
  %add.ptr234 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8*), i64 %vbase.offset233
  %550 = bitcast i8* %add.ptr234 to %"class.std::ios_base"*
  %_M_width.i532 = getelementptr inbounds %"class.std::ios_base", %"class.std::ios_base"* %550, i64 0, i32 2
  %551 = load i64, i64* %_M_width.i532, align 8, !tbaa !16
  store i64 30, i64* %_M_width.i532, align 8, !tbaa !16
  %call.i.i533 = call i64 @strlen(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.53, i64 0, i64 0)) #19
  %call1.i534535 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([25 x i8], [25 x i8]* @.str.53, i64 0, i64 0), i64 %call.i.i533)
          to label %invoke.cont237 unwind label %lpad197

invoke.cont237:                                   ; preds = %if.then230
  %call240 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull @_ZSt4cout)
          to label %if.end241 unwind label %lpad197

if.end241:                                        ; preds = %invoke.cont237, %if.end227, %invoke.cont213
  %call245 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont244 unwind label %lpad243

invoke.cont244:                                   ; preds = %if.end241
  %bc_rows_1 = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 1
  invoke void @_ZN6miniFE16impose_dirichletINS_9CSRMatrixIdiiEENS_6VectorIdiiEEEEvNT_10ScalarTypeERS5_RT0_iiiRKSt3setINS5_17GlobalOrdinalTypeESt4lessISB_ESaISB_EE(double 1.000000e+00, %"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A, %"struct.miniFE::Vector"* nonnull dereferenceable(32) %b, i32 %add209, i32 %add210, i32 %add211, %"class.std::set"* nonnull dereferenceable(48) %bc_rows_1)
          to label %invoke.cont249 unwind label %lpad243

invoke.cont249:                                   ; preds = %invoke.cont244
  %call251 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont250 unwind label %lpad243

invoke.cont250:                                   ; preds = %invoke.cont249
  %sub252 = fsub double %call251, %call245
  %add253 = fadd double %add216, %sub252
  %552 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp254 = icmp eq i32 %552, 0
  br i1 %cmp254, label %if.then255, label %if.end279

if.then255:                                       ; preds = %invoke.cont250
  %call.i538 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* @_ZSt4cout, double %sub252)
          to label %invoke.cont256 unwind label %lpad243

invoke.cont256:                                   ; preds = %if.then255
  %call.i.i540 = call i64 @strlen(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0)) #19
  %call1.i541542 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i538, i8* nonnull getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0), i64 %call.i.i540)
          to label %invoke.cont258 unwind label %lpad243

invoke.cont258:                                   ; preds = %invoke.cont256
  %call.i545 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* %call.i538, double %add253)
          to label %invoke.cont260 unwind label %lpad243

invoke.cont260:                                   ; preds = %invoke.cont258
  %553 = bitcast %"class.std::basic_ostream"* %call.i545 to i8**
  %vtable.i550 = load i8*, i8** %553, align 8, !tbaa !14
  %vbase.offset.ptr.i551 = getelementptr i8, i8* %vtable.i550, i64 -24
  %554 = bitcast i8* %vbase.offset.ptr.i551 to i64*
  %vbase.offset.i552 = load i64, i64* %554, align 8
  %555 = bitcast %"class.std::basic_ostream"* %call.i545 to i8*
  %add.ptr.i553 = getelementptr inbounds i8, i8* %555, i64 %vbase.offset.i552
  %556 = bitcast i8* %add.ptr.i553 to %"class.std::basic_ios"*
  %_M_ctype.i1246 = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %556, i64 0, i32 5
  %557 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i1246, align 8, !tbaa !22
  %tobool.i.i1247 = icmp eq %"class.std::ctype"* %557, null
  br i1 %tobool.i.i1247, label %if.then.i.i1248, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1251

if.then.i.i1248:                                  ; preds = %invoke.cont260
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc1259 unwind label %lpad243

.noexc1259:                                       ; preds = %if.then.i.i1248
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1251: ; preds = %invoke.cont260
  %_M_widen_ok.i.i1249 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %557, i64 0, i32 8
  %558 = load i8, i8* %_M_widen_ok.i.i1249, align 8, !tbaa !25
  %tobool.i1.i1250 = icmp eq i8 %558, 0
  br i1 %tobool.i1.i1250, label %if.end.i.i1257, label %if.then.i2.i1253

if.then.i2.i1253:                                 ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1251
  %arrayidx.i.i1252 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %557, i64 0, i32 9, i64 10
  %559 = load i8, i8* %arrayidx.i.i1252, align 1, !tbaa !27
  br label %call.i.noexc555

if.end.i.i1257:                                   ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1251
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %557)
          to label %.noexc1260 unwind label %lpad243

.noexc1260:                                       ; preds = %if.end.i.i1257
  %560 = bitcast %"class.std::ctype"* %557 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i1254 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %560, align 8, !tbaa !14
  %vfn.i.i1255 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i1254, i64 6
  %561 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i1255, align 8
  %call.i.i12561261 = invoke signext i8 %561(%"class.std::ctype"* nonnull %557, i8 signext 10)
          to label %call.i.noexc555 unwind label %lpad243

call.i.noexc555:                                  ; preds = %.noexc1260, %if.then.i2.i1253
  %retval.0.i.i1258 = phi i8 [ %559, %if.then.i2.i1253 ], [ %call.i.i12561261, %.noexc1260 ]
  %call1.i554557 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i545, i8 signext %retval.0.i.i1258)
          to label %call1.i554.noexc unwind label %lpad243

call1.i554.noexc:                                 ; preds = %call.i.noexc555
  %call.i561 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i554557)
          to label %if.end264 unwind label %lpad243

lpad243:                                          ; preds = %call1.i554.noexc, %call.i.noexc555, %.noexc1260, %if.end.i.i1257, %if.then.i.i1248, %invoke.cont258, %invoke.cont256, %if.then255, %invoke.cont249, %invoke.cont244, %if.end241
  %562 = landingpad { i8*, i32 }
          cleanup
  %563 = extractvalue { i8*, i32 } %562, 0
  %564 = extractvalue { i8*, i32 } %562, 1
  br label %ehcleanup911

if.end264:                                        ; preds = %call1.i554.noexc
  %.pr1087 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp266 = icmp eq i32 %.pr1087, 0
  br i1 %cmp266, label %if.then267, label %if.end279

if.then267:                                       ; preds = %if.end264
  %vtable268 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8**), align 8, !tbaa !14
  %vbase.offset.ptr269 = getelementptr i8, i8* %vtable268, i64 -24
  %565 = bitcast i8* %vbase.offset.ptr269 to i64*
  %vbase.offset270 = load i64, i64* %565, align 8
  %add.ptr271 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8*), i64 %vbase.offset270
  %566 = bitcast i8* %add.ptr271 to %"class.std::ios_base"*
  %_M_width.i563 = getelementptr inbounds %"class.std::ios_base", %"class.std::ios_base"* %566, i64 0, i32 2
  %567 = load i64, i64* %_M_width.i563, align 8, !tbaa !16
  store i64 30, i64* %_M_width.i563, align 8, !tbaa !16
  %call.i.i564 = call i64 @strlen(i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.54, i64 0, i64 0)) #19
  %call1.i565566 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([31 x i8], [31 x i8]* @.str.54, i64 0, i64 0), i64 %call.i.i564)
          to label %invoke.cont275 unwind label %lpad272

invoke.cont275:                                   ; preds = %if.then267
  %call278 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull @_ZSt4cout)
          to label %if.end279 unwind label %lpad272

lpad272:                                          ; preds = %invoke.cont275, %if.then267
  %568 = landingpad { i8*, i32 }
          cleanup
  %569 = extractvalue { i8*, i32 } %568, 0
  %570 = extractvalue { i8*, i32 } %568, 1
  br label %ehcleanup911

if.end279:                                        ; preds = %invoke.cont275, %if.end264, %invoke.cont250
  %call283 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont282 unwind label %lpad281

invoke.cont282:                                   ; preds = %if.end279
  invoke void @_ZN6miniFE17make_local_matrixINS_9CSRMatrixIdiiEEEEvRT_(%"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A)
          to label %invoke.cont284 unwind label %lpad281

invoke.cont284:                                   ; preds = %invoke.cont282
  %call286 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont285 unwind label %lpad281

invoke.cont285:                                   ; preds = %invoke.cont284
  %sub287 = fsub double %call286, %call283
  %add288 = fadd double %add253, %sub287
  %571 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp289 = icmp eq i32 %571, 0
  br i1 %cmp289, label %if.then290, label %if.end299

if.then290:                                       ; preds = %invoke.cont285
  %call.i569 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* @_ZSt4cout, double %sub287)
          to label %invoke.cont291 unwind label %lpad281

invoke.cont291:                                   ; preds = %if.then290
  %call.i.i571 = call i64 @strlen(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0)) #19
  %call1.i572573 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) %call.i569, i8* nonnull getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0), i64 %call.i.i571)
          to label %invoke.cont293 unwind label %lpad281

invoke.cont293:                                   ; preds = %invoke.cont291
  %call.i576 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* %call.i569, double %add288)
          to label %invoke.cont295 unwind label %lpad281

invoke.cont295:                                   ; preds = %invoke.cont293
  %572 = bitcast %"class.std::basic_ostream"* %call.i576 to i8**
  %vtable.i581 = load i8*, i8** %572, align 8, !tbaa !14
  %vbase.offset.ptr.i582 = getelementptr i8, i8* %vtable.i581, i64 -24
  %573 = bitcast i8* %vbase.offset.ptr.i582 to i64*
  %vbase.offset.i583 = load i64, i64* %573, align 8
  %574 = bitcast %"class.std::basic_ostream"* %call.i576 to i8*
  %add.ptr.i584 = getelementptr inbounds i8, i8* %574, i64 %vbase.offset.i583
  %575 = bitcast i8* %add.ptr.i584 to %"class.std::basic_ios"*
  %_M_ctype.i1155 = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %575, i64 0, i32 5
  %576 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i1155, align 8, !tbaa !22
  %tobool.i.i1156 = icmp eq %"class.std::ctype"* %576, null
  br i1 %tobool.i.i1156, label %if.then.i.i1157, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1160

if.then.i.i1157:                                  ; preds = %invoke.cont295
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc1168 unwind label %lpad281

.noexc1168:                                       ; preds = %if.then.i.i1157
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1160: ; preds = %invoke.cont295
  %_M_widen_ok.i.i1158 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %576, i64 0, i32 8
  %577 = load i8, i8* %_M_widen_ok.i.i1158, align 8, !tbaa !25
  %tobool.i1.i1159 = icmp eq i8 %577, 0
  br i1 %tobool.i1.i1159, label %if.end.i.i1166, label %if.then.i2.i1162

if.then.i2.i1162:                                 ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1160
  %arrayidx.i.i1161 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %576, i64 0, i32 9, i64 10
  %578 = load i8, i8* %arrayidx.i.i1161, align 1, !tbaa !27
  br label %call.i.noexc586

if.end.i.i1166:                                   ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1160
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %576)
          to label %.noexc1169 unwind label %lpad281

.noexc1169:                                       ; preds = %if.end.i.i1166
  %579 = bitcast %"class.std::ctype"* %576 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i1163 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %579, align 8, !tbaa !14
  %vfn.i.i1164 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i1163, i64 6
  %580 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i1164, align 8
  %call.i.i11651170 = invoke signext i8 %580(%"class.std::ctype"* nonnull %576, i8 signext 10)
          to label %call.i.noexc586 unwind label %lpad281

call.i.noexc586:                                  ; preds = %.noexc1169, %if.then.i2.i1162
  %retval.0.i.i1167 = phi i8 [ %578, %if.then.i2.i1162 ], [ %call.i.i11651170, %.noexc1169 ]
  %call1.i585588 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i576, i8 signext %retval.0.i.i1167)
          to label %call1.i585.noexc unwind label %lpad281

call1.i585.noexc:                                 ; preds = %call.i.noexc586
  %call.i592 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i585588)
          to label %if.end299 unwind label %lpad281

lpad281:                                          ; preds = %call1.i585.noexc, %call.i.noexc586, %.noexc1169, %if.end.i.i1166, %if.then.i.i1157, %invoke.cont293, %invoke.cont291, %if.then290, %invoke.cont284, %invoke.cont282, %if.end279
  %581 = landingpad { i8*, i32 }
          cleanup
  %582 = extractvalue { i8*, i32 } %581, 0
  %583 = extractvalue { i8*, i32 } %581, 1
  br label %ehcleanup911

if.end299:                                        ; preds = %call1.i585.noexc, %invoke.cont285
  %584 = load i32, i32* %myproc, align 4, !tbaa !2
  %585 = load i32, i32* %numprocs, align 4, !tbaa !2
  %call303 = invoke i64 @_ZN6miniFE20compute_matrix_statsINS_9CSRMatrixIdiiEEEEmRKT_iiR8YAML_Doc(%"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A, i32 %584, i32 %585, %class.YAML_Doc* nonnull dereferenceable(216) %ydoc)
          to label %invoke.cont302 unwind label %lpad301

invoke.cont302:                                   ; preds = %if.end299
  %586 = bitcast i32* %num_iters to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %586) #19
  store i32 0, i32* %num_iters, align 4, !tbaa !2
  %587 = bitcast double* %rnorm to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %587) #19
  store double 0.000000e+00, double* %rnorm, align 8, !tbaa !42
  %588 = bitcast double* %tol to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %588) #19
  store double 0x3CB0000000000000, double* %tol, align 8, !tbaa !42
  %589 = bitcast [5 x double]* %cg_times to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %589) #19
  %call307 = invoke double @_ZN6miniFE7mytimerEv()
          to label %invoke.cont306 unwind label %lpad305

invoke.cont306:                                   ; preds = %invoke.cont302
  %mv_overlap_comm_comp = getelementptr inbounds %"struct.miniFE::Parameters", %"struct.miniFE::Parameters"* %params, i64 0, i32 4
  %590 = load i32, i32* %mv_overlap_comm_comp, align 8, !tbaa !53
  %cmp309 = icmp eq i32 %590, 1
  %591 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp310 = icmp eq i32 %591, 0
  br i1 %cmp310, label %if.then311, label %if.end317

if.then311:                                       ; preds = %invoke.cont306
  %call.i.i594 = call i64 @strlen(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.55, i64 0, i64 0)) #19
  %call1.i595596 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([24 x i8], [24 x i8]* @.str.55, i64 0, i64 0), i64 %call.i.i594)
          to label %invoke.cont313 unwind label %lpad312

invoke.cont313:                                   ; preds = %if.then311
  %vtable.i601 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8**), align 8, !tbaa !14
  %vbase.offset.ptr.i602 = getelementptr i8, i8* %vtable.i601, i64 -24
  %592 = bitcast i8* %vbase.offset.ptr.i602 to i64*
  %vbase.offset.i603 = load i64, i64* %592, align 8
  %add.ptr.i604 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8*), i64 %vbase.offset.i603
  %593 = bitcast i8* %add.ptr.i604 to %"class.std::basic_ios"*
  %_M_ctype.i1053 = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %593, i64 0, i32 5
  %594 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i1053, align 8, !tbaa !22
  %tobool.i.i1054 = icmp eq %"class.std::ctype"* %594, null
  br i1 %tobool.i.i1054, label %if.then.i.i1055, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1058

if.then.i.i1055:                                  ; preds = %invoke.cont313
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc1066 unwind label %lpad312

.noexc1066:                                       ; preds = %if.then.i.i1055
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1058: ; preds = %invoke.cont313
  %_M_widen_ok.i.i1056 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %594, i64 0, i32 8
  %595 = load i8, i8* %_M_widen_ok.i.i1056, align 8, !tbaa !25
  %tobool.i1.i1057 = icmp eq i8 %595, 0
  br i1 %tobool.i1.i1057, label %if.end.i.i1064, label %if.then.i2.i1060

if.then.i2.i1060:                                 ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1058
  %arrayidx.i.i1059 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %594, i64 0, i32 9, i64 10
  %596 = load i8, i8* %arrayidx.i.i1059, align 1, !tbaa !27
  br label %call.i.noexc606

if.end.i.i1064:                                   ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i1058
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %594)
          to label %.noexc1067 unwind label %lpad312

.noexc1067:                                       ; preds = %if.end.i.i1064
  %597 = bitcast %"class.std::ctype"* %594 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i1061 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %597, align 8, !tbaa !14
  %vfn.i.i1062 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i1061, i64 6
  %598 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i1062, align 8
  %call.i.i10631068 = invoke signext i8 %598(%"class.std::ctype"* nonnull %594, i8 signext 10)
          to label %call.i.noexc606 unwind label %lpad312

call.i.noexc606:                                  ; preds = %.noexc1067, %if.then.i2.i1060
  %retval.0.i.i1065 = phi i8 [ %596, %if.then.i2.i1060 ], [ %call.i.i10631068, %.noexc1067 ]
  %call1.i605608 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull @_ZSt4cout, i8 signext %retval.0.i.i1065)
          to label %call1.i605.noexc unwind label %lpad312

call1.i605.noexc:                                 ; preds = %call.i.noexc606
  %call.i612 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i605608)
          to label %if.end317 unwind label %lpad312

lpad301:                                          ; preds = %if.end299
  %599 = landingpad { i8*, i32 }
          cleanup
  %600 = extractvalue { i8*, i32 } %599, 0
  %601 = extractvalue { i8*, i32 } %599, 1
  br label %ehcleanup911

lpad305:                                          ; preds = %invoke.cont302
  %602 = landingpad { i8*, i32 }
          cleanup
  %603 = extractvalue { i8*, i32 } %602, 0
  %604 = extractvalue { i8*, i32 } %602, 1
  br label %ehcleanup903

lpad312:                                          ; preds = %call1.i628.noexc, %call.i.noexc629, %.noexc889, %if.end.i.i886, %if.then.i.i877, %invoke.cont326, %if.then325, %if.else, %invoke.cont319, %if.then318, %call1.i605.noexc, %call.i.noexc606, %.noexc1067, %if.end.i.i1064, %if.then.i.i1055, %if.then311
  %605 = landingpad { i8*, i32 }
          cleanup
  %606 = extractvalue { i8*, i32 } %605, 0
  %607 = extractvalue { i8*, i32 } %605, 1
  br label %ehcleanup903

if.end317:                                        ; preds = %call1.i605.noexc, %invoke.cont306
  br i1 %cmp309, label %if.then318, label %if.else

if.then318:                                       ; preds = %if.end317
  invoke void @_ZN6miniFE31rearrange_matrix_local_externalINS_9CSRMatrixIdiiEEEEvRT_(%"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A)
          to label %invoke.cont319 unwind label %lpad312

invoke.cont319:                                   ; preds = %if.then318
  %arraydecay = getelementptr inbounds [5 x double], [5 x double]* %cg_times, i64 0, i64 0
  invoke void @_ZN6miniFE8cg_solveINS_9CSRMatrixIdiiEENS_6VectorIdiiEENS_14matvec_overlapIS2_S4_EEEEvRT_RKT0_RS9_T1_NS7_16LocalOrdinalTypeERNS_10TypeTraitsINS7_10ScalarTypeEE14magnitude_typeERSE_SJ_Pd(%"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A, %"struct.miniFE::Vector"* nonnull dereferenceable(32) %b, %"struct.miniFE::Vector"* nonnull dereferenceable(32) %x, i32 200, double* nonnull dereferenceable(8) %tol, i32* nonnull dereferenceable(4) %num_iters, double* nonnull dereferenceable(8) %rnorm, double* nonnull %arraydecay)
          to label %if.end357 unwind label %lpad312

if.else:                                          ; preds = %if.end317
  %arraydecay322 = getelementptr inbounds [5 x double], [5 x double]* %cg_times, i64 0, i64 0
  invoke void @_ZN6miniFE8cg_solveINS_9CSRMatrixIdiiEENS_6VectorIdiiEENS_10matvec_stdIS2_S4_EEEEvRT_RKT0_RS9_T1_NS7_16LocalOrdinalTypeERNS_10TypeTraitsINS7_10ScalarTypeEE14magnitude_typeERSE_SJ_Pd(%"struct.miniFE::CSRMatrix"* nonnull dereferenceable(328) %A, %"struct.miniFE::Vector"* nonnull dereferenceable(32) %b, %"struct.miniFE::Vector"* nonnull dereferenceable(32) %x, i32 200, double* nonnull dereferenceable(8) %tol, i32* nonnull dereferenceable(4) %num_iters, double* nonnull dereferenceable(8) %rnorm, double* nonnull %arraydecay322)
          to label %invoke.cont323 unwind label %lpad312

invoke.cont323:                                   ; preds = %if.else
  %608 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp324 = icmp eq i32 %608, 0
  br i1 %cmp324, label %if.then325, label %if.end332

if.then325:                                       ; preds = %invoke.cont323
  %call.i.i614 = call i64 @strlen(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.56, i64 0, i64 0)) #19
  %call1.i615616 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([19 x i8], [19 x i8]* @.str.56, i64 0, i64 0), i64 %call.i.i614)
          to label %invoke.cont326 unwind label %lpad312

invoke.cont326:                                   ; preds = %if.then325
  %609 = load double, double* %rnorm, align 8, !tbaa !42
  %call.i619 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"* @_ZSt4cout, double %609)
          to label %invoke.cont328 unwind label %lpad312

invoke.cont328:                                   ; preds = %invoke.cont326
  %610 = bitcast %"class.std::basic_ostream"* %call.i619 to i8**
  %vtable.i624 = load i8*, i8** %610, align 8, !tbaa !14
  %vbase.offset.ptr.i625 = getelementptr i8, i8* %vtable.i624, i64 -24
  %611 = bitcast i8* %vbase.offset.ptr.i625 to i64*
  %vbase.offset.i626 = load i64, i64* %611, align 8
  %612 = bitcast %"class.std::basic_ostream"* %call.i619 to i8*
  %add.ptr.i627 = getelementptr inbounds i8, i8* %612, i64 %vbase.offset.i626
  %613 = bitcast i8* %add.ptr.i627 to %"class.std::basic_ios"*
  %_M_ctype.i875 = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %613, i64 0, i32 5
  %614 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i875, align 8, !tbaa !22
  %tobool.i.i876 = icmp eq %"class.std::ctype"* %614, null
  br i1 %tobool.i.i876, label %if.then.i.i877, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i880

if.then.i.i877:                                   ; preds = %invoke.cont328
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc888 unwind label %lpad312

.noexc888:                                        ; preds = %if.then.i.i877
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i880: ; preds = %invoke.cont328
  %_M_widen_ok.i.i878 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %614, i64 0, i32 8
  %615 = load i8, i8* %_M_widen_ok.i.i878, align 8, !tbaa !25
  %tobool.i1.i879 = icmp eq i8 %615, 0
  br i1 %tobool.i1.i879, label %if.end.i.i886, label %if.then.i2.i882

if.then.i2.i882:                                  ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i880
  %arrayidx.i.i881 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %614, i64 0, i32 9, i64 10
  %616 = load i8, i8* %arrayidx.i.i881, align 1, !tbaa !27
  br label %call.i.noexc629

if.end.i.i886:                                    ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i880
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %614)
          to label %.noexc889 unwind label %lpad312

.noexc889:                                        ; preds = %if.end.i.i886
  %617 = bitcast %"class.std::ctype"* %614 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i883 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %617, align 8, !tbaa !14
  %vfn.i.i884 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i883, i64 6
  %618 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i884, align 8
  %call.i.i885890 = invoke signext i8 %618(%"class.std::ctype"* nonnull %614, i8 signext 10)
          to label %call.i.noexc629 unwind label %lpad312

call.i.noexc629:                                  ; preds = %.noexc889, %if.then.i2.i882
  %retval.0.i.i887 = phi i8 [ %616, %if.then.i2.i882 ], [ %call.i.i885890, %.noexc889 ]
  %call1.i628631 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull %call.i619, i8 signext %retval.0.i.i887)
          to label %call1.i628.noexc unwind label %lpad312

call1.i628.noexc:                                 ; preds = %call.i.noexc629
  %call.i635 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i628631)
          to label %if.end332 unwind label %lpad312

if.end332:                                        ; preds = %call1.i628.noexc, %invoke.cont323
  %verify_solution = getelementptr inbounds %"struct.miniFE::Parameters", %"struct.miniFE::Parameters"* %params, i64 0, i32 11
  %619 = load i32, i32* %verify_solution, align 8, !tbaa !54
  %cmp333 = icmp sgt i32 %619, 0
  br i1 %cmp333, label %if.then334, label %if.end357

if.then334:                                       ; preds = %if.end332
  %620 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp335 = icmp eq i32 %620, 0
  br i1 %cmp335, label %if.else344, label %if.end350

lpad339:                                          ; preds = %if.end350, %call1.i648.noexc, %call.i.noexc649, %.noexc700, %if.end.i.i697, %if.then.i.i688, %if.else344
  %621 = landingpad { i8*, i32 }
          cleanup
  %622 = extractvalue { i8*, i32 } %621, 0
  %623 = extractvalue { i8*, i32 } %621, 1
  br label %ehcleanup903

if.else344:                                       ; preds = %if.then334
  %call.i.i637 = call i64 @strlen(i8* getelementptr inbounds ([44 x i8], [44 x i8]* @.str.58, i64 0, i64 0)) #19
  %call1.i638639 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([44 x i8], [44 x i8]* @.str.58, i64 0, i64 0), i64 %call.i.i637)
          to label %invoke.cont345 unwind label %lpad339

invoke.cont345:                                   ; preds = %if.else344
  %vtable.i644 = load i8*, i8** bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8**), align 8, !tbaa !14
  %vbase.offset.ptr.i645 = getelementptr i8, i8* %vtable.i644, i64 -24
  %624 = bitcast i8* %vbase.offset.ptr.i645 to i64*
  %vbase.offset.i646 = load i64, i64* %624, align 8
  %add.ptr.i647 = getelementptr inbounds i8, i8* bitcast (%"class.std::basic_ostream"* @_ZSt4cout to i8*), i64 %vbase.offset.i646
  %625 = bitcast i8* %add.ptr.i647 to %"class.std::basic_ios"*
  %_M_ctype.i686 = getelementptr inbounds %"class.std::basic_ios", %"class.std::basic_ios"* %625, i64 0, i32 5
  %626 = load %"class.std::ctype"*, %"class.std::ctype"** %_M_ctype.i686, align 8, !tbaa !22
  %tobool.i.i687 = icmp eq %"class.std::ctype"* %626, null
  br i1 %tobool.i.i687, label %if.then.i.i688, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i691

if.then.i.i688:                                   ; preds = %invoke.cont345
  invoke void @_ZSt16__throw_bad_castv() #20
          to label %.noexc699 unwind label %lpad339

.noexc699:                                        ; preds = %if.then.i.i688
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i691: ; preds = %invoke.cont345
  %_M_widen_ok.i.i689 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %626, i64 0, i32 8
  %627 = load i8, i8* %_M_widen_ok.i.i689, align 8, !tbaa !25
  %tobool.i1.i690 = icmp eq i8 %627, 0
  br i1 %tobool.i1.i690, label %if.end.i.i697, label %if.then.i2.i693

if.then.i2.i693:                                  ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i691
  %arrayidx.i.i692 = getelementptr inbounds %"class.std::ctype", %"class.std::ctype"* %626, i64 0, i32 9, i64 10
  %628 = load i8, i8* %arrayidx.i.i692, align 1, !tbaa !27
  br label %call.i.noexc649

if.end.i.i697:                                    ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i691
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"* nonnull %626)
          to label %.noexc700 unwind label %lpad339

.noexc700:                                        ; preds = %if.end.i.i697
  %629 = bitcast %"class.std::ctype"* %626 to i8 (%"class.std::ctype"*, i8)***
  %vtable.i.i694 = load i8 (%"class.std::ctype"*, i8)**, i8 (%"class.std::ctype"*, i8)*** %629, align 8, !tbaa !14
  %vfn.i.i695 = getelementptr inbounds i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vtable.i.i694, i64 6
  %630 = load i8 (%"class.std::ctype"*, i8)*, i8 (%"class.std::ctype"*, i8)** %vfn.i.i695, align 8
  %call.i.i696701 = invoke signext i8 %630(%"class.std::ctype"* nonnull %626, i8 signext 10)
          to label %call.i.noexc649 unwind label %lpad339

call.i.noexc649:                                  ; preds = %.noexc700, %if.then.i2.i693
  %retval.0.i.i698 = phi i8 [ %628, %if.then.i2.i693 ], [ %call.i.i696701, %.noexc700 ]
  %call1.i648651 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"* nonnull @_ZSt4cout, i8 signext %retval.0.i.i698)
          to label %call1.i648.noexc unwind label %lpad339

call1.i648.noexc:                                 ; preds = %call.i.noexc649
  %call.i655 = invoke dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"* nonnull %call1.i648651)
          to label %if.end350 unwind label %lpad339

if.end350:                                        ; preds = %call1.i648.noexc, %if.then334
  %call353 = invoke i32 @_ZN6miniFE15verify_solutionINS_6VectorIdiiEEEEiRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERKS4_db(%"class.miniFE::simple_mesh_description"* nonnull dereferenceable(192) %mesh, %"struct.miniFE::Vector"* nonnull dereferenceable(32) %x, double 6.000000e-03, i1 zeroext false)
          to label %if.end357 unwind label %lpad339

if.end357:                                        ; preds = %if.end350, %if.end332, %invoke.cont319
  %631 = bitcast %"class.std::__cxx11::basic_string"* %title to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %631) #19
  %632 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp358, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %632) #19
  %633 = bitcast %"class.std::allocator.0"* %ref.tmp358 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i660 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 0
  %634 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 2
  %arraydecay.i.i661 = bitcast %union.anon* %634 to i8*
  %635 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i660 to %"class.std::allocator.0"*
  %636 = bitcast %"class.std::allocator.0"* %635 to %"class.__gnu_cxx::new_allocator.1"*
  %637 = bitcast %"class.std::allocator.0"* %ref.tmp358 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i662 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i660, i64 0, i32 0
  store i8* %arraydecay.i.i661, i8** %_M_p.i.i662, align 8, !tbaa !48
  %call.i.i663 = call i64 @strlen(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.59, i64 0, i64 0)) #19
  %add.ptr.i664 = getelementptr inbounds i8, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.59, i64 0, i64 0), i64 %call.i.i663
  %cmp.i.i.i.i665 = icmp eq i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.59, i64 0, i64 0), %add.ptr.i664
  %638 = bitcast i64* %__dnew.i.i.i.i659 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %638) #19
  %639 = bitcast i8** %__first.addr.i.i.i.i.i657 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %639)
  store i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.59, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i657, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i666 = ptrtoint i8* %add.ptr.i664 to i64
  %sub.ptr.sub.i.i.i.i.i.i667 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i666, ptrtoint ([9 x i8]* @.str.59 to i64)
  %640 = bitcast i8** %__first.addr.i.i.i.i.i657 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %640)
  store i64 %sub.ptr.sub.i.i.i.i.i.i667, i64* %__dnew.i.i.i.i659, align 8, !tbaa !50
  %cmp3.i.i.i.i668 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i667, 15
  br i1 %cmp3.i.i.i.i668, label %if.then4.i.i.i.i670, label %if.end6.i.i.i.i677

if.then4.i.i.i.i670:                              ; preds = %if.end357
  %call5.i.i.i1.i669 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %title, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i659, i64 0)
          to label %call5.i.i.i.noexc.i673 unwind label %lpad.i683

call5.i.i.i.noexc.i673:                           ; preds = %if.then4.i.i.i.i670
  %_M_p.i1.i.i.i.i671 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i669, i8** %_M_p.i1.i.i.i.i671, align 8, !tbaa !51
  %641 = load i64, i64* %__dnew.i.i.i.i659, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i672 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 2, i32 0
  store i64 %641, i64* %_M_allocated_capacity.i.i.i.i.i672, align 8, !tbaa !27
  br label %if.end6.i.i.i.i677

if.end6.i.i.i.i677:                               ; preds = %call5.i.i.i.noexc.i673, %if.end357
  %_M_p.i.i.i.i.i674 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 0, i32 0
  %642 = load i8*, i8** %_M_p.i.i.i.i.i674, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i675 = ptrtoint i8* %add.ptr.i664 to i64
  %sub.ptr.sub.i.i.i.i.i676 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i675, ptrtoint ([9 x i8]* @.str.59 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i676, label %if.end.i.i.i.i.i.i.i679 [
    i64 1, label %if.then.i.i.i.i.i.i678
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit685
  ]

if.then.i.i.i.i.i.i678:                           ; preds = %if.end6.i.i.i.i677
  store i8 67, i8* %642, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit685

if.end.i.i.i.i.i.i.i679:                          ; preds = %if.end6.i.i.i.i677
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %642, i8* align 1 getelementptr inbounds ([9 x i8], [9 x i8]* @.str.59, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i676, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit685

lpad.i683:                                        ; preds = %if.then4.i.i.i.i670
  %643 = landingpad { i8*, i32 }
          cleanup
  %644 = bitcast %"class.std::__cxx11::basic_string"* %title to %"class.std::allocator.0"*
  %645 = bitcast %"class.std::allocator.0"* %644 to %"class.__gnu_cxx::new_allocator.1"*
  %646 = extractvalue { i8*, i32 } %643, 0
  %647 = extractvalue { i8*, i32 } %643, 1
  %648 = bitcast %"class.std::allocator.0"* %ref.tmp358 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %632) #19
  br label %ehcleanup901

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit685: ; preds = %if.end.i.i.i.i.i.i.i679, %if.then.i.i.i.i.i.i678, %if.end6.i.i.i.i677
  %649 = load i64, i64* %__dnew.i.i.i.i659, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i680 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 1
  store i64 %649, i64* %_M_string_length.i.i.i.i.i.i680, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i681 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 0, i32 0
  %650 = load i8*, i8** %_M_p.i.i.i.i.i.i681, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i682 = getelementptr inbounds i8, i8* %650, i64 %649
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i658) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i658, align 1, !tbaa !27
  %651 = load i8, i8* %ref.tmp.i.i.i.i.i658, align 1, !tbaa !27
  store i8 %651, i8* %arrayidx.i.i.i.i.i682, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i658) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %638) #19
  %652 = bitcast %"class.std::allocator.0"* %ref.tmp358 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %632) #19
  %653 = load i32, i32* %myproc, align 4, !tbaa !2
  %cmp363 = icmp eq i32 %653, 0
  br i1 %cmp363, label %if.then364, label %if.end899

if.then364:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit685
  %654 = getelementptr inbounds %class.YAML_Doc, %class.YAML_Doc* %ydoc, i64 0, i32 0
  %655 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp365 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %655) #19
  %656 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp366, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %656) #19
  %657 = bitcast %"class.std::allocator.0"* %ref.tmp366 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i706 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 0
  %658 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 2
  %arraydecay.i.i707 = bitcast %union.anon* %658 to i8*
  %659 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i706 to %"class.std::allocator.0"*
  %660 = bitcast %"class.std::allocator.0"* %659 to %"class.__gnu_cxx::new_allocator.1"*
  %661 = bitcast %"class.std::allocator.0"* %ref.tmp366 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i708 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i706, i64 0, i32 0
  store i8* %arraydecay.i.i707, i8** %_M_p.i.i708, align 8, !tbaa !48
  %call.i.i709 = call i64 @strlen(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0)) #19
  %add.ptr.i710 = getelementptr inbounds i8, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i64 %call.i.i709
  %cmp.i.i.i.i711 = icmp eq i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), %add.ptr.i710
  %662 = bitcast i64* %__dnew.i.i.i.i705 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %662) #19
  %663 = bitcast i8** %__first.addr.i.i.i.i.i703 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %663)
  store i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i703, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i712 = ptrtoint i8* %add.ptr.i710 to i64
  %sub.ptr.sub.i.i.i.i.i.i713 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i712, ptrtoint ([22 x i8]* @.str.9 to i64)
  %664 = bitcast i8** %__first.addr.i.i.i.i.i703 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %664)
  store i64 %sub.ptr.sub.i.i.i.i.i.i713, i64* %__dnew.i.i.i.i705, align 8, !tbaa !50
  %cmp3.i.i.i.i714 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i713, 15
  br i1 %cmp3.i.i.i.i714, label %if.then4.i.i.i.i716, label %if.end6.i.i.i.i723

if.then4.i.i.i.i716:                              ; preds = %if.then364
  %call5.i.i.i1.i715 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp365, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i705, i64 0)
          to label %call5.i.i.i.noexc.i719 unwind label %lpad.i729

call5.i.i.i.noexc.i719:                           ; preds = %if.then4.i.i.i.i716
  %_M_p.i1.i.i.i.i717 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i715, i8** %_M_p.i1.i.i.i.i717, align 8, !tbaa !51
  %665 = load i64, i64* %__dnew.i.i.i.i705, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i718 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 2, i32 0
  store i64 %665, i64* %_M_allocated_capacity.i.i.i.i.i718, align 8, !tbaa !27
  br label %if.end6.i.i.i.i723

if.end6.i.i.i.i723:                               ; preds = %call5.i.i.i.noexc.i719, %if.then364
  %_M_p.i.i.i.i.i720 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 0, i32 0
  %666 = load i8*, i8** %_M_p.i.i.i.i.i720, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i721 = ptrtoint i8* %add.ptr.i710 to i64
  %sub.ptr.sub.i.i.i.i.i722 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i721, ptrtoint ([22 x i8]* @.str.9 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i722, label %if.end.i.i.i.i.i.i.i725 [
    i64 1, label %if.then.i.i.i.i.i.i724
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit731
  ]

if.then.i.i.i.i.i.i724:                           ; preds = %if.end6.i.i.i.i723
  store i8 71, i8* %666, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit731

if.end.i.i.i.i.i.i.i725:                          ; preds = %if.end6.i.i.i.i723
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %666, i8* align 1 getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i722, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit731

lpad.i729:                                        ; preds = %if.then4.i.i.i.i716
  %667 = landingpad { i8*, i32 }
          cleanup
  %668 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp365 to %"class.std::allocator.0"*
  %669 = bitcast %"class.std::allocator.0"* %668 to %"class.__gnu_cxx::new_allocator.1"*
  %670 = extractvalue { i8*, i32 } %667, 0
  %671 = extractvalue { i8*, i32 } %667, 1
  br label %ehcleanup395

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit731: ; preds = %if.end.i.i.i.i.i.i.i725, %if.then.i.i.i.i.i.i724, %if.end6.i.i.i.i723
  %672 = load i64, i64* %__dnew.i.i.i.i705, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i726 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 1
  store i64 %672, i64* %_M_string_length.i.i.i.i.i.i726, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i727 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 0, i32 0
  %673 = load i8*, i8** %_M_p.i.i.i.i.i.i727, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i728 = getelementptr inbounds i8, i8* %673, i64 %672
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i704) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i704, align 1, !tbaa !27
  %674 = load i8, i8* %ref.tmp.i.i.i.i.i704, align 1, !tbaa !27
  store i8 %674, i8* %arrayidx.i.i.i.i.i728, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i704) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %662) #19
  %call371 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp365)
          to label %invoke.cont370 unwind label %lpad369

invoke.cont370:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit731
  %675 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp372 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %675) #19
  %676 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp373, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %676) #19
  %677 = bitcast %"class.std::allocator.0"* %ref.tmp373 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i735 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 0
  %678 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 2
  %arraydecay.i.i736 = bitcast %union.anon* %678 to i8*
  %679 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i735 to %"class.std::allocator.0"*
  %680 = bitcast %"class.std::allocator.0"* %679 to %"class.__gnu_cxx::new_allocator.1"*
  %681 = bitcast %"class.std::allocator.0"* %ref.tmp373 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i737 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i735, i64 0, i32 0
  store i8* %arraydecay.i.i736, i8** %_M_p.i.i737, align 8, !tbaa !48
  %call.i.i738 = call i64 @strlen(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.60, i64 0, i64 0)) #19
  %add.ptr.i739 = getelementptr inbounds i8, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.60, i64 0, i64 0), i64 %call.i.i738
  %cmp.i.i.i.i740 = icmp eq i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.60, i64 0, i64 0), %add.ptr.i739
  %682 = bitcast i64* %__dnew.i.i.i.i734 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %682) #19
  %683 = bitcast i8** %__first.addr.i.i.i.i.i732 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %683)
  store i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.60, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i732, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i741 = ptrtoint i8* %add.ptr.i739 to i64
  %sub.ptr.sub.i.i.i.i.i.i742 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i741, ptrtoint ([11 x i8]* @.str.60 to i64)
  %684 = bitcast i8** %__first.addr.i.i.i.i.i732 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %684)
  store i64 %sub.ptr.sub.i.i.i.i.i.i742, i64* %__dnew.i.i.i.i734, align 8, !tbaa !50
  %cmp3.i.i.i.i743 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i742, 15
  br i1 %cmp3.i.i.i.i743, label %if.then4.i.i.i.i745, label %if.end6.i.i.i.i752

if.then4.i.i.i.i745:                              ; preds = %invoke.cont370
  %call5.i.i.i1.i744 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp372, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i734, i64 0)
          to label %call5.i.i.i.noexc.i748 unwind label %lpad.i758

call5.i.i.i.noexc.i748:                           ; preds = %if.then4.i.i.i.i745
  %_M_p.i1.i.i.i.i746 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i744, i8** %_M_p.i1.i.i.i.i746, align 8, !tbaa !51
  %685 = load i64, i64* %__dnew.i.i.i.i734, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i747 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 2, i32 0
  store i64 %685, i64* %_M_allocated_capacity.i.i.i.i.i747, align 8, !tbaa !27
  br label %if.end6.i.i.i.i752

if.end6.i.i.i.i752:                               ; preds = %call5.i.i.i.noexc.i748, %invoke.cont370
  %_M_p.i.i.i.i.i749 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 0, i32 0
  %686 = load i8*, i8** %_M_p.i.i.i.i.i749, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i750 = ptrtoint i8* %add.ptr.i739 to i64
  %sub.ptr.sub.i.i.i.i.i751 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i750, ptrtoint ([11 x i8]* @.str.60 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i751, label %if.end.i.i.i.i.i.i.i754 [
    i64 1, label %if.then.i.i.i.i.i.i753
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit760
  ]

if.then.i.i.i.i.i.i753:                           ; preds = %if.end6.i.i.i.i752
  store i8 83, i8* %686, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit760

if.end.i.i.i.i.i.i.i754:                          ; preds = %if.end6.i.i.i.i752
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %686, i8* align 1 getelementptr inbounds ([11 x i8], [11 x i8]* @.str.60, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i751, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit760

lpad.i758:                                        ; preds = %if.then4.i.i.i.i745
  %687 = landingpad { i8*, i32 }
          cleanup
  %688 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp372 to %"class.std::allocator.0"*
  %689 = bitcast %"class.std::allocator.0"* %688 to %"class.__gnu_cxx::new_allocator.1"*
  %690 = extractvalue { i8*, i32 } %687, 0
  %691 = extractvalue { i8*, i32 } %687, 1
  br label %ehcleanup391

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit760: ; preds = %if.end.i.i.i.i.i.i.i754, %if.then.i.i.i.i.i.i753, %if.end6.i.i.i.i752
  %692 = load i64, i64* %__dnew.i.i.i.i734, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i755 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 1
  store i64 %692, i64* %_M_string_length.i.i.i.i.i.i755, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i756 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 0, i32 0
  %693 = load i8*, i8** %_M_p.i.i.i.i.i.i756, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i757 = getelementptr inbounds i8, i8* %693, i64 %692
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i733) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i733, align 1, !tbaa !27
  %694 = load i8, i8* %ref.tmp.i.i.i.i.i733, align 1, !tbaa !27
  store i8 %694, i8* %arrayidx.i.i.i.i.i757, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i733) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %682) #19
  %695 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp376 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %695) #19
  %696 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp380, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %696) #19
  %697 = bitcast %"class.std::allocator.0"* %ref.tmp380 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i764 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 0
  %698 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 2
  %arraydecay.i.i765 = bitcast %union.anon* %698 to i8*
  %699 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i764 to %"class.std::allocator.0"*
  %700 = bitcast %"class.std::allocator.0"* %699 to %"class.__gnu_cxx::new_allocator.1"*
  %701 = bitcast %"class.std::allocator.0"* %ref.tmp380 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i766 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i764, i64 0, i32 0
  store i8* %arraydecay.i.i765, i8** %_M_p.i.i766, align 8, !tbaa !48
  %call.i.i767 = call i64 @strlen(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.138, i64 0, i64 0)) #19
  %add.ptr.i768 = getelementptr inbounds i8, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.138, i64 0, i64 0), i64 %call.i.i767
  %cmp.i.i.i.i769 = icmp eq i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.138, i64 0, i64 0), %add.ptr.i768
  %702 = bitcast i64* %__dnew.i.i.i.i763 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %702) #19
  %703 = bitcast i8** %__first.addr.i.i.i.i.i761 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %703)
  store i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.138, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i761, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i770 = ptrtoint i8* %add.ptr.i768 to i64
  %sub.ptr.sub.i.i.i.i.i.i771 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i770, ptrtoint ([7 x i8]* @.str.138 to i64)
  %704 = bitcast i8** %__first.addr.i.i.i.i.i761 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %704)
  store i64 %sub.ptr.sub.i.i.i.i.i.i771, i64* %__dnew.i.i.i.i763, align 8, !tbaa !50
  %cmp3.i.i.i.i772 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i771, 15
  br i1 %cmp3.i.i.i.i772, label %if.then4.i.i.i.i774, label %if.end6.i.i.i.i781

if.then4.i.i.i.i774:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit760
  %call5.i.i.i1.i773 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp376, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i763, i64 0)
          to label %call5.i.i.i.noexc.i777 unwind label %lpad.i787

call5.i.i.i.noexc.i777:                           ; preds = %if.then4.i.i.i.i774
  %_M_p.i1.i.i.i.i775 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i773, i8** %_M_p.i1.i.i.i.i775, align 8, !tbaa !51
  %705 = load i64, i64* %__dnew.i.i.i.i763, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i776 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 2, i32 0
  store i64 %705, i64* %_M_allocated_capacity.i.i.i.i.i776, align 8, !tbaa !27
  br label %if.end6.i.i.i.i781

if.end6.i.i.i.i781:                               ; preds = %call5.i.i.i.noexc.i777, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit760
  %_M_p.i.i.i.i.i778 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 0, i32 0
  %706 = load i8*, i8** %_M_p.i.i.i.i.i778, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i779 = ptrtoint i8* %add.ptr.i768 to i64
  %sub.ptr.sub.i.i.i.i.i780 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i779, ptrtoint ([7 x i8]* @.str.138 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i780, label %if.end.i.i.i.i.i.i.i783 [
    i64 1, label %if.then.i.i.i.i.i.i782
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit789
  ]

if.then.i.i.i.i.i.i782:                           ; preds = %if.end6.i.i.i.i781
  store i8 100, i8* %706, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit789

if.end.i.i.i.i.i.i.i783:                          ; preds = %if.end6.i.i.i.i781
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %706, i8* align 1 getelementptr inbounds ([7 x i8], [7 x i8]* @.str.138, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i780, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit789

lpad.i787:                                        ; preds = %if.then4.i.i.i.i774
  %707 = landingpad { i8*, i32 }
          cleanup
  %708 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp376 to %"class.std::allocator.0"*
  %709 = bitcast %"class.std::allocator.0"* %708 to %"class.__gnu_cxx::new_allocator.1"*
  %710 = extractvalue { i8*, i32 } %707, 0
  %711 = extractvalue { i8*, i32 } %707, 1
  br label %ehcleanup387

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit789: ; preds = %if.end.i.i.i.i.i.i.i783, %if.then.i.i.i.i.i.i782, %if.end6.i.i.i.i781
  %712 = load i64, i64* %__dnew.i.i.i.i763, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i784 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 1
  store i64 %712, i64* %_M_string_length.i.i.i.i.i.i784, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i785 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 0, i32 0
  %713 = load i8*, i8** %_M_p.i.i.i.i.i.i785, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i786 = getelementptr inbounds i8, i8* %713, i64 %712
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i762) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i762, align 1, !tbaa !27
  %714 = load i8, i8* %ref.tmp.i.i.i.i.i762, align 1, !tbaa !27
  store i8 %714, i8* %arrayidx.i.i.i.i.i786, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i762) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %702) #19
  %call385 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* %call371, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp372, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp376)
          to label %invoke.cont384 unwind label %lpad383

invoke.cont384:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit789
  %_M_p.i.i.i.i790 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 0, i32 0
  %715 = load i8*, i8** %_M_p.i.i.i.i790, align 8, !tbaa !51
  %716 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 2
  %arraydecay.i.i.i.i791 = bitcast %union.anon* %716 to i8*
  %cmp.i.i.i792 = icmp eq i8* %715, %arraydecay.i.i.i.i791
  br i1 %cmp.i.i.i792, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit798, label %if.then.i.i796

if.then.i.i796:                                   ; preds = %invoke.cont384
  %_M_allocated_capacity.i.i793 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 2, i32 0
  %717 = load i64, i64* %_M_allocated_capacity.i.i793, align 8, !tbaa !27
  %718 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp376 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i794 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 0, i32 0
  %719 = load i8*, i8** %_M_p.i.i1.i.i794, align 8, !tbaa !51
  %add.i.i.i795 = add i64 %717, 1
  %720 = bitcast %"class.std::allocator.0"* %718 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %719) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit798

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit798: ; preds = %if.then.i.i796, %invoke.cont384
  %721 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp376 to %"class.std::allocator.0"*
  %722 = bitcast %"class.std::allocator.0"* %721 to %"class.__gnu_cxx::new_allocator.1"*
  %723 = bitcast %"class.std::allocator.0"* %ref.tmp380 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %696) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %695) #19
  %_M_p.i.i.i.i799 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 0, i32 0
  %724 = load i8*, i8** %_M_p.i.i.i.i799, align 8, !tbaa !51
  %725 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 2
  %arraydecay.i.i.i.i800 = bitcast %union.anon* %725 to i8*
  %cmp.i.i.i801 = icmp eq i8* %724, %arraydecay.i.i.i.i800
  br i1 %cmp.i.i.i801, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit807, label %if.then.i.i805

if.then.i.i805:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit798
  %_M_allocated_capacity.i.i802 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 2, i32 0
  %726 = load i64, i64* %_M_allocated_capacity.i.i802, align 8, !tbaa !27
  %727 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp372 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i803 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 0, i32 0
  %728 = load i8*, i8** %_M_p.i.i1.i.i803, align 8, !tbaa !51
  %add.i.i.i804 = add i64 %726, 1
  %729 = bitcast %"class.std::allocator.0"* %727 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %728) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit807

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit807: ; preds = %if.then.i.i805, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit798
  %730 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp372 to %"class.std::allocator.0"*
  %731 = bitcast %"class.std::allocator.0"* %730 to %"class.__gnu_cxx::new_allocator.1"*
  %732 = bitcast %"class.std::allocator.0"* %ref.tmp373 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %676) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %675) #19
  %_M_p.i.i.i.i808 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 0, i32 0
  %733 = load i8*, i8** %_M_p.i.i.i.i808, align 8, !tbaa !51
  %734 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 2
  %arraydecay.i.i.i.i809 = bitcast %union.anon* %734 to i8*
  %cmp.i.i.i810 = icmp eq i8* %733, %arraydecay.i.i.i.i809
  br i1 %cmp.i.i.i810, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit816, label %if.then.i.i814

if.then.i.i814:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit807
  %_M_allocated_capacity.i.i811 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 2, i32 0
  %735 = load i64, i64* %_M_allocated_capacity.i.i811, align 8, !tbaa !27
  %736 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp365 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i812 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 0, i32 0
  %737 = load i8*, i8** %_M_p.i.i1.i.i812, align 8, !tbaa !51
  %add.i.i.i813 = add i64 %735, 1
  %738 = bitcast %"class.std::allocator.0"* %736 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %737) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit816

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit816: ; preds = %if.then.i.i814, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit807
  %739 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp365 to %"class.std::allocator.0"*
  %740 = bitcast %"class.std::allocator.0"* %739 to %"class.__gnu_cxx::new_allocator.1"*
  %741 = bitcast %"class.std::allocator.0"* %ref.tmp366 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %656) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %655) #19
  %742 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp398 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %742) #19
  %743 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp399, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %743) #19
  %744 = bitcast %"class.std::allocator.0"* %ref.tmp399 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i820 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 0
  %745 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 2
  %arraydecay.i.i821 = bitcast %union.anon* %745 to i8*
  %746 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i820 to %"class.std::allocator.0"*
  %747 = bitcast %"class.std::allocator.0"* %746 to %"class.__gnu_cxx::new_allocator.1"*
  %748 = bitcast %"class.std::allocator.0"* %ref.tmp399 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i822 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i820, i64 0, i32 0
  store i8* %arraydecay.i.i821, i8** %_M_p.i.i822, align 8, !tbaa !48
  %call.i.i823 = call i64 @strlen(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0)) #19
  %add.ptr.i824 = getelementptr inbounds i8, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i64 %call.i.i823
  %cmp.i.i.i.i825 = icmp eq i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), %add.ptr.i824
  %749 = bitcast i64* %__dnew.i.i.i.i819 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %749) #19
  %750 = bitcast i8** %__first.addr.i.i.i.i.i817 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %750)
  store i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i817, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i826 = ptrtoint i8* %add.ptr.i824 to i64
  %sub.ptr.sub.i.i.i.i.i.i827 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i826, ptrtoint ([22 x i8]* @.str.9 to i64)
  %751 = bitcast i8** %__first.addr.i.i.i.i.i817 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %751)
  store i64 %sub.ptr.sub.i.i.i.i.i.i827, i64* %__dnew.i.i.i.i819, align 8, !tbaa !50
  %cmp3.i.i.i.i828 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i827, 15
  br i1 %cmp3.i.i.i.i828, label %if.then4.i.i.i.i830, label %if.end6.i.i.i.i837

if.then4.i.i.i.i830:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit816
  %call5.i.i.i1.i829 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp398, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i819, i64 0)
          to label %call5.i.i.i.noexc.i833 unwind label %lpad.i843

call5.i.i.i.noexc.i833:                           ; preds = %if.then4.i.i.i.i830
  %_M_p.i1.i.i.i.i831 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i829, i8** %_M_p.i1.i.i.i.i831, align 8, !tbaa !51
  %752 = load i64, i64* %__dnew.i.i.i.i819, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i832 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 2, i32 0
  store i64 %752, i64* %_M_allocated_capacity.i.i.i.i.i832, align 8, !tbaa !27
  br label %if.end6.i.i.i.i837

if.end6.i.i.i.i837:                               ; preds = %call5.i.i.i.noexc.i833, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit816
  %_M_p.i.i.i.i.i834 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 0, i32 0
  %753 = load i8*, i8** %_M_p.i.i.i.i.i834, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i835 = ptrtoint i8* %add.ptr.i824 to i64
  %sub.ptr.sub.i.i.i.i.i836 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i835, ptrtoint ([22 x i8]* @.str.9 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i836, label %if.end.i.i.i.i.i.i.i839 [
    i64 1, label %if.then.i.i.i.i.i.i838
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit845
  ]

if.then.i.i.i.i.i.i838:                           ; preds = %if.end6.i.i.i.i837
  store i8 71, i8* %753, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit845

if.end.i.i.i.i.i.i.i839:                          ; preds = %if.end6.i.i.i.i837
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %753, i8* align 1 getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i836, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit845

lpad.i843:                                        ; preds = %if.then4.i.i.i.i830
  %754 = landingpad { i8*, i32 }
          cleanup
  %755 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp398 to %"class.std::allocator.0"*
  %756 = bitcast %"class.std::allocator.0"* %755 to %"class.__gnu_cxx::new_allocator.1"*
  %757 = extractvalue { i8*, i32 } %754, 0
  %758 = extractvalue { i8*, i32 } %754, 1
  br label %ehcleanup428

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit845: ; preds = %if.end.i.i.i.i.i.i.i839, %if.then.i.i.i.i.i.i838, %if.end6.i.i.i.i837
  %759 = load i64, i64* %__dnew.i.i.i.i819, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i840 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 1
  store i64 %759, i64* %_M_string_length.i.i.i.i.i.i840, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i841 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 0, i32 0
  %760 = load i8*, i8** %_M_p.i.i.i.i.i.i841, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i842 = getelementptr inbounds i8, i8* %760, i64 %759
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i818) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i818, align 1, !tbaa !27
  %761 = load i8, i8* %ref.tmp.i.i.i.i.i818, align 1, !tbaa !27
  store i8 %761, i8* %arrayidx.i.i.i.i.i842, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i818) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %749) #19
  %call404 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp398)
          to label %invoke.cont403 unwind label %lpad402

invoke.cont403:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit845
  %762 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp405 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %762) #19
  %763 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp406, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %763) #19
  %764 = bitcast %"class.std::allocator.0"* %ref.tmp406 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i849 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 0
  %765 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 2
  %arraydecay.i.i850 = bitcast %union.anon* %765 to i8*
  %766 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i849 to %"class.std::allocator.0"*
  %767 = bitcast %"class.std::allocator.0"* %766 to %"class.__gnu_cxx::new_allocator.1"*
  %768 = bitcast %"class.std::allocator.0"* %ref.tmp406 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i851 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i849, i64 0, i32 0
  store i8* %arraydecay.i.i850, i8** %_M_p.i.i851, align 8, !tbaa !48
  %call.i.i852 = call i64 @strlen(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.61, i64 0, i64 0)) #19
  %add.ptr.i853 = getelementptr inbounds i8, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.61, i64 0, i64 0), i64 %call.i.i852
  %cmp.i.i.i.i854 = icmp eq i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.61, i64 0, i64 0), %add.ptr.i853
  %769 = bitcast i64* %__dnew.i.i.i.i848 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %769) #19
  %770 = bitcast i8** %__first.addr.i.i.i.i.i846 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %770)
  store i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.61, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i846, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i855 = ptrtoint i8* %add.ptr.i853 to i64
  %sub.ptr.sub.i.i.i.i.i.i856 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i855, ptrtoint ([18 x i8]* @.str.61 to i64)
  %771 = bitcast i8** %__first.addr.i.i.i.i.i846 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %771)
  store i64 %sub.ptr.sub.i.i.i.i.i.i856, i64* %__dnew.i.i.i.i848, align 8, !tbaa !50
  %cmp3.i.i.i.i857 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i856, 15
  br i1 %cmp3.i.i.i.i857, label %if.then4.i.i.i.i859, label %if.end6.i.i.i.i866

if.then4.i.i.i.i859:                              ; preds = %invoke.cont403
  %call5.i.i.i1.i858 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp405, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i848, i64 0)
          to label %call5.i.i.i.noexc.i862 unwind label %lpad.i872

call5.i.i.i.noexc.i862:                           ; preds = %if.then4.i.i.i.i859
  %_M_p.i1.i.i.i.i860 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i858, i8** %_M_p.i1.i.i.i.i860, align 8, !tbaa !51
  %772 = load i64, i64* %__dnew.i.i.i.i848, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i861 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 2, i32 0
  store i64 %772, i64* %_M_allocated_capacity.i.i.i.i.i861, align 8, !tbaa !27
  br label %if.end6.i.i.i.i866

if.end6.i.i.i.i866:                               ; preds = %call5.i.i.i.noexc.i862, %invoke.cont403
  %_M_p.i.i.i.i.i863 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 0, i32 0
  %773 = load i8*, i8** %_M_p.i.i.i.i.i863, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i864 = ptrtoint i8* %add.ptr.i853 to i64
  %sub.ptr.sub.i.i.i.i.i865 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i864, ptrtoint ([18 x i8]* @.str.61 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i865, label %if.end.i.i.i.i.i.i.i868 [
    i64 1, label %if.then.i.i.i.i.i.i867
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit874
  ]

if.then.i.i.i.i.i.i867:                           ; preds = %if.end6.i.i.i.i866
  store i8 71, i8* %773, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit874

if.end.i.i.i.i.i.i.i868:                          ; preds = %if.end6.i.i.i.i866
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %773, i8* align 1 getelementptr inbounds ([18 x i8], [18 x i8]* @.str.61, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i865, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit874

lpad.i872:                                        ; preds = %if.then4.i.i.i.i859
  %774 = landingpad { i8*, i32 }
          cleanup
  %775 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp405 to %"class.std::allocator.0"*
  %776 = bitcast %"class.std::allocator.0"* %775 to %"class.__gnu_cxx::new_allocator.1"*
  %777 = extractvalue { i8*, i32 } %774, 0
  %778 = extractvalue { i8*, i32 } %774, 1
  br label %ehcleanup424

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit874: ; preds = %if.end.i.i.i.i.i.i.i868, %if.then.i.i.i.i.i.i867, %if.end6.i.i.i.i866
  %779 = load i64, i64* %__dnew.i.i.i.i848, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i869 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 1
  store i64 %779, i64* %_M_string_length.i.i.i.i.i.i869, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i870 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 0, i32 0
  %780 = load i8*, i8** %_M_p.i.i.i.i.i.i870, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i871 = getelementptr inbounds i8, i8* %780, i64 %779
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i847) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i847, align 1, !tbaa !27
  %781 = load i8, i8* %ref.tmp.i.i.i.i.i847, align 1, !tbaa !27
  store i8 %781, i8* %arrayidx.i.i.i.i.i871, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i847) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %769) #19
  %782 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp409 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %782) #19
  %783 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp413, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %783) #19
  %784 = bitcast %"class.std::allocator.0"* %ref.tmp413 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i895 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 0
  %785 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 2
  %arraydecay.i.i896 = bitcast %union.anon* %785 to i8*
  %786 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i895 to %"class.std::allocator.0"*
  %787 = bitcast %"class.std::allocator.0"* %786 to %"class.__gnu_cxx::new_allocator.1"*
  %788 = bitcast %"class.std::allocator.0"* %ref.tmp413 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i897 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i895, i64 0, i32 0
  store i8* %arraydecay.i.i896, i8** %_M_p.i.i897, align 8, !tbaa !48
  %call.i.i898 = call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0)) #19
  %add.ptr.i899 = getelementptr inbounds i8, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0), i64 %call.i.i898
  %cmp.i.i.i.i900 = icmp eq i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0), %add.ptr.i899
  %789 = bitcast i64* %__dnew.i.i.i.i894 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %789) #19
  %790 = bitcast i8** %__first.addr.i.i.i.i.i892 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %790)
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i892, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i901 = ptrtoint i8* %add.ptr.i899 to i64
  %sub.ptr.sub.i.i.i.i.i.i902 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i901, ptrtoint ([4 x i8]* @.str.139 to i64)
  %791 = bitcast i8** %__first.addr.i.i.i.i.i892 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %791)
  store i64 %sub.ptr.sub.i.i.i.i.i.i902, i64* %__dnew.i.i.i.i894, align 8, !tbaa !50
  %cmp3.i.i.i.i903 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i902, 15
  br i1 %cmp3.i.i.i.i903, label %if.then4.i.i.i.i905, label %if.end6.i.i.i.i912

if.then4.i.i.i.i905:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit874
  %call5.i.i.i1.i904 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp409, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i894, i64 0)
          to label %call5.i.i.i.noexc.i908 unwind label %lpad.i918

call5.i.i.i.noexc.i908:                           ; preds = %if.then4.i.i.i.i905
  %_M_p.i1.i.i.i.i906 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i904, i8** %_M_p.i1.i.i.i.i906, align 8, !tbaa !51
  %792 = load i64, i64* %__dnew.i.i.i.i894, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i907 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 2, i32 0
  store i64 %792, i64* %_M_allocated_capacity.i.i.i.i.i907, align 8, !tbaa !27
  br label %if.end6.i.i.i.i912

if.end6.i.i.i.i912:                               ; preds = %call5.i.i.i.noexc.i908, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit874
  %_M_p.i.i.i.i.i909 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 0, i32 0
  %793 = load i8*, i8** %_M_p.i.i.i.i.i909, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i910 = ptrtoint i8* %add.ptr.i899 to i64
  %sub.ptr.sub.i.i.i.i.i911 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i910, ptrtoint ([4 x i8]* @.str.139 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i911, label %if.end.i.i.i.i.i.i.i914 [
    i64 1, label %if.then.i.i.i.i.i.i913
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit920
  ]

if.then.i.i.i.i.i.i913:                           ; preds = %if.end6.i.i.i.i912
  store i8 105, i8* %793, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit920

if.end.i.i.i.i.i.i.i914:                          ; preds = %if.end6.i.i.i.i912
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %793, i8* align 1 getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i911, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit920

lpad.i918:                                        ; preds = %if.then4.i.i.i.i905
  %794 = landingpad { i8*, i32 }
          cleanup
  %795 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp409 to %"class.std::allocator.0"*
  %796 = bitcast %"class.std::allocator.0"* %795 to %"class.__gnu_cxx::new_allocator.1"*
  %797 = extractvalue { i8*, i32 } %794, 0
  %798 = extractvalue { i8*, i32 } %794, 1
  br label %ehcleanup420

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit920: ; preds = %if.end.i.i.i.i.i.i.i914, %if.then.i.i.i.i.i.i913, %if.end6.i.i.i.i912
  %799 = load i64, i64* %__dnew.i.i.i.i894, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i915 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 1
  store i64 %799, i64* %_M_string_length.i.i.i.i.i.i915, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i916 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 0, i32 0
  %800 = load i8*, i8** %_M_p.i.i.i.i.i.i916, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i917 = getelementptr inbounds i8, i8* %800, i64 %799
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i893) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i893, align 1, !tbaa !27
  %801 = load i8, i8* %ref.tmp.i.i.i.i.i893, align 1, !tbaa !27
  store i8 %801, i8* %arrayidx.i.i.i.i.i917, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i893) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %789) #19
  %call418 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* %call404, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp405, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp409)
          to label %invoke.cont417 unwind label %lpad416

invoke.cont417:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit920
  %_M_p.i.i.i.i921 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 0, i32 0
  %802 = load i8*, i8** %_M_p.i.i.i.i921, align 8, !tbaa !51
  %803 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 2
  %arraydecay.i.i.i.i922 = bitcast %union.anon* %803 to i8*
  %cmp.i.i.i923 = icmp eq i8* %802, %arraydecay.i.i.i.i922
  br i1 %cmp.i.i.i923, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit929, label %if.then.i.i927

if.then.i.i927:                                   ; preds = %invoke.cont417
  %_M_allocated_capacity.i.i924 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 2, i32 0
  %804 = load i64, i64* %_M_allocated_capacity.i.i924, align 8, !tbaa !27
  %805 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp409 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i925 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 0, i32 0
  %806 = load i8*, i8** %_M_p.i.i1.i.i925, align 8, !tbaa !51
  %add.i.i.i926 = add i64 %804, 1
  %807 = bitcast %"class.std::allocator.0"* %805 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %806) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit929

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit929: ; preds = %if.then.i.i927, %invoke.cont417
  %808 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp409 to %"class.std::allocator.0"*
  %809 = bitcast %"class.std::allocator.0"* %808 to %"class.__gnu_cxx::new_allocator.1"*
  %810 = bitcast %"class.std::allocator.0"* %ref.tmp413 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %783) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %782) #19
  %_M_p.i.i.i.i930 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 0, i32 0
  %811 = load i8*, i8** %_M_p.i.i.i.i930, align 8, !tbaa !51
  %812 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 2
  %arraydecay.i.i.i.i931 = bitcast %union.anon* %812 to i8*
  %cmp.i.i.i932 = icmp eq i8* %811, %arraydecay.i.i.i.i931
  br i1 %cmp.i.i.i932, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit938, label %if.then.i.i936

if.then.i.i936:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit929
  %_M_allocated_capacity.i.i933 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 2, i32 0
  %813 = load i64, i64* %_M_allocated_capacity.i.i933, align 8, !tbaa !27
  %814 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp405 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i934 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 0, i32 0
  %815 = load i8*, i8** %_M_p.i.i1.i.i934, align 8, !tbaa !51
  %add.i.i.i935 = add i64 %813, 1
  %816 = bitcast %"class.std::allocator.0"* %814 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %815) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit938

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit938: ; preds = %if.then.i.i936, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit929
  %817 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp405 to %"class.std::allocator.0"*
  %818 = bitcast %"class.std::allocator.0"* %817 to %"class.__gnu_cxx::new_allocator.1"*
  %819 = bitcast %"class.std::allocator.0"* %ref.tmp406 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %763) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %762) #19
  %_M_p.i.i.i.i939 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 0, i32 0
  %820 = load i8*, i8** %_M_p.i.i.i.i939, align 8, !tbaa !51
  %821 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 2
  %arraydecay.i.i.i.i940 = bitcast %union.anon* %821 to i8*
  %cmp.i.i.i941 = icmp eq i8* %820, %arraydecay.i.i.i.i940
  br i1 %cmp.i.i.i941, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit947, label %if.then.i.i945

if.then.i.i945:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit938
  %_M_allocated_capacity.i.i942 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 2, i32 0
  %822 = load i64, i64* %_M_allocated_capacity.i.i942, align 8, !tbaa !27
  %823 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp398 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i943 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 0, i32 0
  %824 = load i8*, i8** %_M_p.i.i1.i.i943, align 8, !tbaa !51
  %add.i.i.i944 = add i64 %822, 1
  %825 = bitcast %"class.std::allocator.0"* %823 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %824) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit947

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit947: ; preds = %if.then.i.i945, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit938
  %826 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp398 to %"class.std::allocator.0"*
  %827 = bitcast %"class.std::allocator.0"* %826 to %"class.__gnu_cxx::new_allocator.1"*
  %828 = bitcast %"class.std::allocator.0"* %ref.tmp399 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %743) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %742) #19
  %829 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp431 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %829) #19
  %830 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp432, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %830) #19
  %831 = bitcast %"class.std::allocator.0"* %ref.tmp432 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i951 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 0
  %832 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 2
  %arraydecay.i.i952 = bitcast %union.anon* %832 to i8*
  %833 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i951 to %"class.std::allocator.0"*
  %834 = bitcast %"class.std::allocator.0"* %833 to %"class.__gnu_cxx::new_allocator.1"*
  %835 = bitcast %"class.std::allocator.0"* %ref.tmp432 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i953 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i951, i64 0, i32 0
  store i8* %arraydecay.i.i952, i8** %_M_p.i.i953, align 8, !tbaa !48
  %call.i.i954 = call i64 @strlen(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0)) #19
  %add.ptr.i955 = getelementptr inbounds i8, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i64 %call.i.i954
  %cmp.i.i.i.i956 = icmp eq i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), %add.ptr.i955
  %836 = bitcast i64* %__dnew.i.i.i.i950 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %836) #19
  %837 = bitcast i8** %__first.addr.i.i.i.i.i948 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %837)
  store i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i948, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i957 = ptrtoint i8* %add.ptr.i955 to i64
  %sub.ptr.sub.i.i.i.i.i.i958 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i957, ptrtoint ([22 x i8]* @.str.9 to i64)
  %838 = bitcast i8** %__first.addr.i.i.i.i.i948 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %838)
  store i64 %sub.ptr.sub.i.i.i.i.i.i958, i64* %__dnew.i.i.i.i950, align 8, !tbaa !50
  %cmp3.i.i.i.i959 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i958, 15
  br i1 %cmp3.i.i.i.i959, label %if.then4.i.i.i.i961, label %if.end6.i.i.i.i968

if.then4.i.i.i.i961:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit947
  %call5.i.i.i1.i960 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp431, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i950, i64 0)
          to label %call5.i.i.i.noexc.i964 unwind label %lpad.i974

call5.i.i.i.noexc.i964:                           ; preds = %if.then4.i.i.i.i961
  %_M_p.i1.i.i.i.i962 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i960, i8** %_M_p.i1.i.i.i.i962, align 8, !tbaa !51
  %839 = load i64, i64* %__dnew.i.i.i.i950, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i963 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 2, i32 0
  store i64 %839, i64* %_M_allocated_capacity.i.i.i.i.i963, align 8, !tbaa !27
  br label %if.end6.i.i.i.i968

if.end6.i.i.i.i968:                               ; preds = %call5.i.i.i.noexc.i964, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit947
  %_M_p.i.i.i.i.i965 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 0, i32 0
  %840 = load i8*, i8** %_M_p.i.i.i.i.i965, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i966 = ptrtoint i8* %add.ptr.i955 to i64
  %sub.ptr.sub.i.i.i.i.i967 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i966, ptrtoint ([22 x i8]* @.str.9 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i967, label %if.end.i.i.i.i.i.i.i970 [
    i64 1, label %if.then.i.i.i.i.i.i969
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit976
  ]

if.then.i.i.i.i.i.i969:                           ; preds = %if.end6.i.i.i.i968
  store i8 71, i8* %840, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit976

if.end.i.i.i.i.i.i.i970:                          ; preds = %if.end6.i.i.i.i968
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %840, i8* align 1 getelementptr inbounds ([22 x i8], [22 x i8]* @.str.9, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i967, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit976

lpad.i974:                                        ; preds = %if.then4.i.i.i.i961
  %841 = landingpad { i8*, i32 }
          cleanup
  %842 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp431 to %"class.std::allocator.0"*
  %843 = bitcast %"class.std::allocator.0"* %842 to %"class.__gnu_cxx::new_allocator.1"*
  %844 = extractvalue { i8*, i32 } %841, 0
  %845 = extractvalue { i8*, i32 } %841, 1
  br label %ehcleanup461

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit976: ; preds = %if.end.i.i.i.i.i.i.i970, %if.then.i.i.i.i.i.i969, %if.end6.i.i.i.i968
  %846 = load i64, i64* %__dnew.i.i.i.i950, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i971 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 1
  store i64 %846, i64* %_M_string_length.i.i.i.i.i.i971, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i972 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 0, i32 0
  %847 = load i8*, i8** %_M_p.i.i.i.i.i.i972, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i973 = getelementptr inbounds i8, i8* %847, i64 %846
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i949) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i949, align 1, !tbaa !27
  %848 = load i8, i8* %ref.tmp.i.i.i.i.i949, align 1, !tbaa !27
  store i8 %848, i8* %arrayidx.i.i.i.i.i973, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i949) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %836) #19
  %call437 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp431)
          to label %invoke.cont436 unwind label %lpad435

invoke.cont436:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit976
  %849 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp438 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %849) #19
  %850 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp439, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %850) #19
  %851 = bitcast %"class.std::allocator.0"* %ref.tmp439 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i980 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 0
  %852 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 2
  %arraydecay.i.i981 = bitcast %union.anon* %852 to i8*
  %853 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i980 to %"class.std::allocator.0"*
  %854 = bitcast %"class.std::allocator.0"* %853 to %"class.__gnu_cxx::new_allocator.1"*
  %855 = bitcast %"class.std::allocator.0"* %ref.tmp439 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i982 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i980, i64 0, i32 0
  store i8* %arraydecay.i.i981, i8** %_M_p.i.i982, align 8, !tbaa !48
  %call.i.i983 = call i64 @strlen(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.62, i64 0, i64 0)) #19
  %add.ptr.i984 = getelementptr inbounds i8, i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.62, i64 0, i64 0), i64 %call.i.i983
  %cmp.i.i.i.i985 = icmp eq i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.62, i64 0, i64 0), %add.ptr.i984
  %856 = bitcast i64* %__dnew.i.i.i.i979 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %856) #19
  %857 = bitcast i8** %__first.addr.i.i.i.i.i977 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %857)
  store i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.62, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i977, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i986 = ptrtoint i8* %add.ptr.i984 to i64
  %sub.ptr.sub.i.i.i.i.i.i987 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i986, ptrtoint ([17 x i8]* @.str.62 to i64)
  %858 = bitcast i8** %__first.addr.i.i.i.i.i977 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %858)
  store i64 %sub.ptr.sub.i.i.i.i.i.i987, i64* %__dnew.i.i.i.i979, align 8, !tbaa !50
  %cmp3.i.i.i.i988 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i987, 15
  br i1 %cmp3.i.i.i.i988, label %if.then4.i.i.i.i990, label %if.end6.i.i.i.i997

if.then4.i.i.i.i990:                              ; preds = %invoke.cont436
  %call5.i.i.i1.i989 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp438, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i979, i64 0)
          to label %call5.i.i.i.noexc.i993 unwind label %lpad.i1003

call5.i.i.i.noexc.i993:                           ; preds = %if.then4.i.i.i.i990
  %_M_p.i1.i.i.i.i991 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i989, i8** %_M_p.i1.i.i.i.i991, align 8, !tbaa !51
  %859 = load i64, i64* %__dnew.i.i.i.i979, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i992 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 2, i32 0
  store i64 %859, i64* %_M_allocated_capacity.i.i.i.i.i992, align 8, !tbaa !27
  br label %if.end6.i.i.i.i997

if.end6.i.i.i.i997:                               ; preds = %call5.i.i.i.noexc.i993, %invoke.cont436
  %_M_p.i.i.i.i.i994 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 0, i32 0
  %860 = load i8*, i8** %_M_p.i.i.i.i.i994, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i995 = ptrtoint i8* %add.ptr.i984 to i64
  %sub.ptr.sub.i.i.i.i.i996 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i995, ptrtoint ([17 x i8]* @.str.62 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i996, label %if.end.i.i.i.i.i.i.i999 [
    i64 1, label %if.then.i.i.i.i.i.i998
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1005
  ]

if.then.i.i.i.i.i.i998:                           ; preds = %if.end6.i.i.i.i997
  store i8 76, i8* %860, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1005

if.end.i.i.i.i.i.i.i999:                          ; preds = %if.end6.i.i.i.i997
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %860, i8* align 1 getelementptr inbounds ([17 x i8], [17 x i8]* @.str.62, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i996, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1005

lpad.i1003:                                       ; preds = %if.then4.i.i.i.i990
  %861 = landingpad { i8*, i32 }
          cleanup
  %862 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp438 to %"class.std::allocator.0"*
  %863 = bitcast %"class.std::allocator.0"* %862 to %"class.__gnu_cxx::new_allocator.1"*
  %864 = extractvalue { i8*, i32 } %861, 0
  %865 = extractvalue { i8*, i32 } %861, 1
  br label %ehcleanup457

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1005: ; preds = %if.end.i.i.i.i.i.i.i999, %if.then.i.i.i.i.i.i998, %if.end6.i.i.i.i997
  %866 = load i64, i64* %__dnew.i.i.i.i979, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1000 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 1
  store i64 %866, i64* %_M_string_length.i.i.i.i.i.i1000, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1001 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 0, i32 0
  %867 = load i8*, i8** %_M_p.i.i.i.i.i.i1001, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1002 = getelementptr inbounds i8, i8* %867, i64 %866
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i978) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i978, align 1, !tbaa !27
  %868 = load i8, i8* %ref.tmp.i.i.i.i.i978, align 1, !tbaa !27
  store i8 %868, i8* %arrayidx.i.i.i.i.i1002, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i978) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %856) #19
  %869 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp442 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %869) #19
  %870 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp446, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %870) #19
  %871 = bitcast %"class.std::allocator.0"* %ref.tmp446 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1009 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 0
  %872 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 2
  %arraydecay.i.i1010 = bitcast %union.anon* %872 to i8*
  %873 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1009 to %"class.std::allocator.0"*
  %874 = bitcast %"class.std::allocator.0"* %873 to %"class.__gnu_cxx::new_allocator.1"*
  %875 = bitcast %"class.std::allocator.0"* %ref.tmp446 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1011 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1009, i64 0, i32 0
  store i8* %arraydecay.i.i1010, i8** %_M_p.i.i1011, align 8, !tbaa !48
  %call.i.i1012 = call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0)) #19
  %add.ptr.i1013 = getelementptr inbounds i8, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0), i64 %call.i.i1012
  %cmp.i.i.i.i1014 = icmp eq i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0), %add.ptr.i1013
  %876 = bitcast i64* %__dnew.i.i.i.i1008 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %876) #19
  %877 = bitcast i8** %__first.addr.i.i.i.i.i1006 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %877)
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1006, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1015 = ptrtoint i8* %add.ptr.i1013 to i64
  %sub.ptr.sub.i.i.i.i.i.i1016 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1015, ptrtoint ([4 x i8]* @.str.139 to i64)
  %878 = bitcast i8** %__first.addr.i.i.i.i.i1006 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %878)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1016, i64* %__dnew.i.i.i.i1008, align 8, !tbaa !50
  %cmp3.i.i.i.i1017 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1016, 15
  br i1 %cmp3.i.i.i.i1017, label %if.then4.i.i.i.i1019, label %if.end6.i.i.i.i1026

if.then4.i.i.i.i1019:                             ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1005
  %call5.i.i.i1.i1018 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp442, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1008, i64 0)
          to label %call5.i.i.i.noexc.i1022 unwind label %lpad.i1032

call5.i.i.i.noexc.i1022:                          ; preds = %if.then4.i.i.i.i1019
  %_M_p.i1.i.i.i.i1020 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1018, i8** %_M_p.i1.i.i.i.i1020, align 8, !tbaa !51
  %879 = load i64, i64* %__dnew.i.i.i.i1008, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1021 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 2, i32 0
  store i64 %879, i64* %_M_allocated_capacity.i.i.i.i.i1021, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1026

if.end6.i.i.i.i1026:                              ; preds = %call5.i.i.i.noexc.i1022, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1005
  %_M_p.i.i.i.i.i1023 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 0, i32 0
  %880 = load i8*, i8** %_M_p.i.i.i.i.i1023, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1024 = ptrtoint i8* %add.ptr.i1013 to i64
  %sub.ptr.sub.i.i.i.i.i1025 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1024, ptrtoint ([4 x i8]* @.str.139 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1025, label %if.end.i.i.i.i.i.i.i1028 [
    i64 1, label %if.then.i.i.i.i.i.i1027
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1034
  ]

if.then.i.i.i.i.i.i1027:                          ; preds = %if.end6.i.i.i.i1026
  store i8 105, i8* %880, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1034

if.end.i.i.i.i.i.i.i1028:                         ; preds = %if.end6.i.i.i.i1026
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %880, i8* align 1 getelementptr inbounds ([4 x i8], [4 x i8]* @.str.139, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1025, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1034

lpad.i1032:                                       ; preds = %if.then4.i.i.i.i1019
  %881 = landingpad { i8*, i32 }
          cleanup
  %882 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp442 to %"class.std::allocator.0"*
  %883 = bitcast %"class.std::allocator.0"* %882 to %"class.__gnu_cxx::new_allocator.1"*
  %884 = extractvalue { i8*, i32 } %881, 0
  %885 = extractvalue { i8*, i32 } %881, 1
  br label %ehcleanup453

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1034: ; preds = %if.end.i.i.i.i.i.i.i1028, %if.then.i.i.i.i.i.i1027, %if.end6.i.i.i.i1026
  %886 = load i64, i64* %__dnew.i.i.i.i1008, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1029 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 1
  store i64 %886, i64* %_M_string_length.i.i.i.i.i.i1029, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1030 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 0, i32 0
  %887 = load i8*, i8** %_M_p.i.i.i.i.i.i1030, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1031 = getelementptr inbounds i8, i8* %887, i64 %886
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1007) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1007, align 1, !tbaa !27
  %888 = load i8, i8* %ref.tmp.i.i.i.i.i1007, align 1, !tbaa !27
  store i8 %888, i8* %arrayidx.i.i.i.i.i1031, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1007) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %876) #19
  %call451 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* %call437, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp438, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp442)
          to label %invoke.cont450 unwind label %lpad449

invoke.cont450:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1034
  %_M_p.i.i.i.i1035 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 0, i32 0
  %889 = load i8*, i8** %_M_p.i.i.i.i1035, align 8, !tbaa !51
  %890 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 2
  %arraydecay.i.i.i.i1036 = bitcast %union.anon* %890 to i8*
  %cmp.i.i.i1037 = icmp eq i8* %889, %arraydecay.i.i.i.i1036
  br i1 %cmp.i.i.i1037, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1043, label %if.then.i.i1041

if.then.i.i1041:                                  ; preds = %invoke.cont450
  %_M_allocated_capacity.i.i1038 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 2, i32 0
  %891 = load i64, i64* %_M_allocated_capacity.i.i1038, align 8, !tbaa !27
  %892 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp442 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1039 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 0, i32 0
  %893 = load i8*, i8** %_M_p.i.i1.i.i1039, align 8, !tbaa !51
  %add.i.i.i1040 = add i64 %891, 1
  %894 = bitcast %"class.std::allocator.0"* %892 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %893) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1043

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1043: ; preds = %if.then.i.i1041, %invoke.cont450
  %895 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp442 to %"class.std::allocator.0"*
  %896 = bitcast %"class.std::allocator.0"* %895 to %"class.__gnu_cxx::new_allocator.1"*
  %897 = bitcast %"class.std::allocator.0"* %ref.tmp446 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %870) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %869) #19
  %_M_p.i.i.i.i1044 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 0, i32 0
  %898 = load i8*, i8** %_M_p.i.i.i.i1044, align 8, !tbaa !51
  %899 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 2
  %arraydecay.i.i.i.i1045 = bitcast %union.anon* %899 to i8*
  %cmp.i.i.i1046 = icmp eq i8* %898, %arraydecay.i.i.i.i1045
  br i1 %cmp.i.i.i1046, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1052, label %if.then.i.i1050

if.then.i.i1050:                                  ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1043
  %_M_allocated_capacity.i.i1047 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 2, i32 0
  %900 = load i64, i64* %_M_allocated_capacity.i.i1047, align 8, !tbaa !27
  %901 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp438 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1048 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 0, i32 0
  %902 = load i8*, i8** %_M_p.i.i1.i.i1048, align 8, !tbaa !51
  %add.i.i.i1049 = add i64 %900, 1
  %903 = bitcast %"class.std::allocator.0"* %901 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %902) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1052

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1052: ; preds = %if.then.i.i1050, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1043
  %904 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp438 to %"class.std::allocator.0"*
  %905 = bitcast %"class.std::allocator.0"* %904 to %"class.__gnu_cxx::new_allocator.1"*
  %906 = bitcast %"class.std::allocator.0"* %ref.tmp439 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %850) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %849) #19
  %_M_p.i.i.i.i1070 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 0, i32 0
  %907 = load i8*, i8** %_M_p.i.i.i.i1070, align 8, !tbaa !51
  %908 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 2
  %arraydecay.i.i.i.i1071 = bitcast %union.anon* %908 to i8*
  %cmp.i.i.i1072 = icmp eq i8* %907, %arraydecay.i.i.i.i1071
  br i1 %cmp.i.i.i1072, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1078, label %if.then.i.i1076

if.then.i.i1076:                                  ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1052
  %_M_allocated_capacity.i.i1073 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 2, i32 0
  %909 = load i64, i64* %_M_allocated_capacity.i.i1073, align 8, !tbaa !27
  %910 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp431 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1074 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 0, i32 0
  %911 = load i8*, i8** %_M_p.i.i1.i.i1074, align 8, !tbaa !51
  %add.i.i.i1075 = add i64 %909, 1
  %912 = bitcast %"class.std::allocator.0"* %910 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %911) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1078

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1078: ; preds = %if.then.i.i1076, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1052
  %913 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp431 to %"class.std::allocator.0"*
  %914 = bitcast %"class.std::allocator.0"* %913 to %"class.__gnu_cxx::new_allocator.1"*
  %915 = bitcast %"class.std::allocator.0"* %ref.tmp432 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %830) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %829) #19
  %916 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp464 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %916) #19
  %917 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp465, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %917) #19
  %918 = bitcast %"class.std::allocator.0"* %ref.tmp465 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1082 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 0
  %919 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 2
  %arraydecay.i.i1083 = bitcast %union.anon* %919 to i8*
  %920 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1082 to %"class.std::allocator.0"*
  %921 = bitcast %"class.std::allocator.0"* %920 to %"class.__gnu_cxx::new_allocator.1"*
  %922 = bitcast %"class.std::allocator.0"* %ref.tmp465 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1084 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1082, i64 0, i32 0
  store i8* %arraydecay.i.i1083, i8** %_M_p.i.i1084, align 8, !tbaa !48
  %call.i.i1085 = call i64 @strlen(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0)) #19
  %add.ptr.i1086 = getelementptr inbounds i8, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i64 %call.i.i1085
  %cmp.i.i.i.i1087 = icmp eq i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), %add.ptr.i1086
  %923 = bitcast i64* %__dnew.i.i.i.i1081 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %923) #19
  %924 = bitcast i8** %__first.addr.i.i.i.i.i1079 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %924)
  store i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1079, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1088 = ptrtoint i8* %add.ptr.i1086 to i64
  %sub.ptr.sub.i.i.i.i.i.i1089 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1088, ptrtoint ([1 x i8]* @.str.5 to i64)
  %925 = bitcast i8** %__first.addr.i.i.i.i.i1079 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %925)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1089, i64* %__dnew.i.i.i.i1081, align 8, !tbaa !50
  %cmp3.i.i.i.i1090 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1089, 15
  br i1 %cmp3.i.i.i.i1090, label %if.then4.i.i.i.i1092, label %if.end6.i.i.i.i1099

if.then4.i.i.i.i1092:                             ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1078
  %call5.i.i.i1.i1091 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp464, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1081, i64 0)
          to label %call5.i.i.i.noexc.i1095 unwind label %lpad.i1105

call5.i.i.i.noexc.i1095:                          ; preds = %if.then4.i.i.i.i1092
  %_M_p.i1.i.i.i.i1093 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1091, i8** %_M_p.i1.i.i.i.i1093, align 8, !tbaa !51
  %926 = load i64, i64* %__dnew.i.i.i.i1081, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1094 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 2, i32 0
  store i64 %926, i64* %_M_allocated_capacity.i.i.i.i.i1094, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1099

if.end6.i.i.i.i1099:                              ; preds = %call5.i.i.i.noexc.i1095, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1078
  %_M_p.i.i.i.i.i1096 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 0, i32 0
  %927 = load i8*, i8** %_M_p.i.i.i.i.i1096, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1097 = ptrtoint i8* %add.ptr.i1086 to i64
  %sub.ptr.sub.i.i.i.i.i1098 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1097, ptrtoint ([1 x i8]* @.str.5 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1098, label %if.end.i.i.i.i.i.i.i1101 [
    i64 1, label %if.then.i.i.i.i.i.i1100
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1107
  ]

if.then.i.i.i.i.i.i1100:                          ; preds = %if.end6.i.i.i.i1099
  store i8 0, i8* %927, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1107

if.end.i.i.i.i.i.i.i1101:                         ; preds = %if.end6.i.i.i.i1099
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %927, i8* align 1 getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1098, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1107

lpad.i1105:                                       ; preds = %if.then4.i.i.i.i1092
  %928 = landingpad { i8*, i32 }
          cleanup
  %929 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp464 to %"class.std::allocator.0"*
  %930 = bitcast %"class.std::allocator.0"* %929 to %"class.__gnu_cxx::new_allocator.1"*
  %931 = extractvalue { i8*, i32 } %928, 0
  %932 = extractvalue { i8*, i32 } %928, 1
  br label %ehcleanup472

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1107: ; preds = %if.end.i.i.i.i.i.i.i1101, %if.then.i.i.i.i.i.i1100, %if.end6.i.i.i.i1099
  %933 = load i64, i64* %__dnew.i.i.i.i1081, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1102 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 1
  store i64 %933, i64* %_M_string_length.i.i.i.i.i.i1102, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1103 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 0, i32 0
  %934 = load i8*, i8** %_M_p.i.i.i.i.i.i1103, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1104 = getelementptr inbounds i8, i8* %934, i64 %933
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1080) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1080, align 1, !tbaa !27
  %935 = load i8, i8* %ref.tmp.i.i.i.i.i1080, align 1, !tbaa !27
  store i8 %935, i8* %arrayidx.i.i.i.i.i1104, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1080) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %923) #19
  %call470 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp464)
          to label %invoke.cont469 unwind label %lpad468

invoke.cont469:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1107
  %_M_p.i.i.i.i1108 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 0, i32 0
  %936 = load i8*, i8** %_M_p.i.i.i.i1108, align 8, !tbaa !51
  %937 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 2
  %arraydecay.i.i.i.i1109 = bitcast %union.anon* %937 to i8*
  %cmp.i.i.i1110 = icmp eq i8* %936, %arraydecay.i.i.i.i1109
  br i1 %cmp.i.i.i1110, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1116, label %if.then.i.i1114

if.then.i.i1114:                                  ; preds = %invoke.cont469
  %_M_allocated_capacity.i.i1111 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 2, i32 0
  %938 = load i64, i64* %_M_allocated_capacity.i.i1111, align 8, !tbaa !27
  %939 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp464 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1112 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 0, i32 0
  %940 = load i8*, i8** %_M_p.i.i1.i.i1112, align 8, !tbaa !51
  %add.i.i.i1113 = add i64 %938, 1
  %941 = bitcast %"class.std::allocator.0"* %939 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %940) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1116

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1116: ; preds = %if.then.i.i1114, %invoke.cont469
  %942 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp464 to %"class.std::allocator.0"*
  %943 = bitcast %"class.std::allocator.0"* %942 to %"class.__gnu_cxx::new_allocator.1"*
  %944 = bitcast %"class.std::allocator.0"* %ref.tmp465 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %917) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %916) #19
  %call477 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont476 unwind label %lpad475

invoke.cont476:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1116
  %945 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp478 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %945) #19
  %946 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp479, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %946) #19
  %947 = bitcast %"class.std::allocator.0"* %ref.tmp479 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1120 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 0
  %948 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 2
  %arraydecay.i.i1121 = bitcast %union.anon* %948 to i8*
  %949 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1120 to %"class.std::allocator.0"*
  %950 = bitcast %"class.std::allocator.0"* %949 to %"class.__gnu_cxx::new_allocator.1"*
  %951 = bitcast %"class.std::allocator.0"* %ref.tmp479 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1122 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1120, i64 0, i32 0
  store i8* %arraydecay.i.i1121, i8** %_M_p.i.i1122, align 8, !tbaa !48
  %call.i.i1123 = call i64 @strlen(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.63, i64 0, i64 0)) #19
  %add.ptr.i1124 = getelementptr inbounds i8, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.63, i64 0, i64 0), i64 %call.i.i1123
  %cmp.i.i.i.i1125 = icmp eq i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.63, i64 0, i64 0), %add.ptr.i1124
  %952 = bitcast i64* %__dnew.i.i.i.i1119 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %952) #19
  %953 = bitcast i8** %__first.addr.i.i.i.i.i1117 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %953)
  store i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.63, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1117, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1126 = ptrtoint i8* %add.ptr.i1124 to i64
  %sub.ptr.sub.i.i.i.i.i.i1127 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1126, ptrtoint ([11 x i8]* @.str.63 to i64)
  %954 = bitcast i8** %__first.addr.i.i.i.i.i1117 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %954)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1127, i64* %__dnew.i.i.i.i1119, align 8, !tbaa !50
  %cmp3.i.i.i.i1128 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1127, 15
  br i1 %cmp3.i.i.i.i1128, label %if.then4.i.i.i.i1130, label %if.end6.i.i.i.i1137

if.then4.i.i.i.i1130:                             ; preds = %invoke.cont476
  %call5.i.i.i1.i1129 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp478, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1119, i64 0)
          to label %call5.i.i.i.noexc.i1133 unwind label %lpad.i1143

call5.i.i.i.noexc.i1133:                          ; preds = %if.then4.i.i.i.i1130
  %_M_p.i1.i.i.i.i1131 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1129, i8** %_M_p.i1.i.i.i.i1131, align 8, !tbaa !51
  %955 = load i64, i64* %__dnew.i.i.i.i1119, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1132 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 2, i32 0
  store i64 %955, i64* %_M_allocated_capacity.i.i.i.i.i1132, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1137

if.end6.i.i.i.i1137:                              ; preds = %call5.i.i.i.noexc.i1133, %invoke.cont476
  %_M_p.i.i.i.i.i1134 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 0, i32 0
  %956 = load i8*, i8** %_M_p.i.i.i.i.i1134, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1135 = ptrtoint i8* %add.ptr.i1124 to i64
  %sub.ptr.sub.i.i.i.i.i1136 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1135, ptrtoint ([11 x i8]* @.str.63 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1136, label %if.end.i.i.i.i.i.i.i1139 [
    i64 1, label %if.then.i.i.i.i.i.i1138
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1145
  ]

if.then.i.i.i.i.i.i1138:                          ; preds = %if.end6.i.i.i.i1137
  store i8 73, i8* %956, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1145

if.end.i.i.i.i.i.i.i1139:                         ; preds = %if.end6.i.i.i.i1137
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %956, i8* align 1 getelementptr inbounds ([11 x i8], [11 x i8]* @.str.63, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1136, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1145

lpad.i1143:                                       ; preds = %if.then4.i.i.i.i1130
  %957 = landingpad { i8*, i32 }
          cleanup
  %958 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp478 to %"class.std::allocator.0"*
  %959 = bitcast %"class.std::allocator.0"* %958 to %"class.__gnu_cxx::new_allocator.1"*
  %960 = extractvalue { i8*, i32 } %957, 0
  %961 = extractvalue { i8*, i32 } %957, 1
  br label %ehcleanup486

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1145: ; preds = %if.end.i.i.i.i.i.i.i1139, %if.then.i.i.i.i.i.i1138, %if.end6.i.i.i.i1137
  %962 = load i64, i64* %__dnew.i.i.i.i1119, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1140 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 1
  store i64 %962, i64* %_M_string_length.i.i.i.i.i.i1140, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1141 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 0, i32 0
  %963 = load i8*, i8** %_M_p.i.i.i.i.i.i1141, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1142 = getelementptr inbounds i8, i8* %963, i64 %962
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1118) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1118, align 1, !tbaa !27
  %964 = load i8, i8* %ref.tmp.i.i.i.i.i1118, align 1, !tbaa !27
  store i8 %964, i8* %arrayidx.i.i.i.i.i1142, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1118) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %952) #19
  %965 = load i32, i32* %num_iters, align 4, !tbaa !2
  %call484 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEi(%class.YAML_Element* %call477, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp478, i32 %965)
          to label %invoke.cont483 unwind label %lpad482

invoke.cont483:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1145
  %_M_p.i.i.i.i1146 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 0, i32 0
  %966 = load i8*, i8** %_M_p.i.i.i.i1146, align 8, !tbaa !51
  %967 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 2
  %arraydecay.i.i.i.i1147 = bitcast %union.anon* %967 to i8*
  %cmp.i.i.i1148 = icmp eq i8* %966, %arraydecay.i.i.i.i1147
  br i1 %cmp.i.i.i1148, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1154, label %if.then.i.i1152

if.then.i.i1152:                                  ; preds = %invoke.cont483
  %_M_allocated_capacity.i.i1149 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 2, i32 0
  %968 = load i64, i64* %_M_allocated_capacity.i.i1149, align 8, !tbaa !27
  %969 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp478 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1150 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 0, i32 0
  %970 = load i8*, i8** %_M_p.i.i1.i.i1150, align 8, !tbaa !51
  %add.i.i.i1151 = add i64 %968, 1
  %971 = bitcast %"class.std::allocator.0"* %969 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %970) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1154

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1154: ; preds = %if.then.i.i1152, %invoke.cont483
  %972 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp478 to %"class.std::allocator.0"*
  %973 = bitcast %"class.std::allocator.0"* %972 to %"class.__gnu_cxx::new_allocator.1"*
  %974 = bitcast %"class.std::allocator.0"* %ref.tmp479 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %946) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %945) #19
  %call490 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont489 unwind label %lpad475

invoke.cont489:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1154
  %975 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp491 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %975) #19
  %976 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp492, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %976) #19
  %977 = bitcast %"class.std::allocator.0"* %ref.tmp492 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1175 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 0
  %978 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 2
  %arraydecay.i.i1176 = bitcast %union.anon* %978 to i8*
  %979 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1175 to %"class.std::allocator.0"*
  %980 = bitcast %"class.std::allocator.0"* %979 to %"class.__gnu_cxx::new_allocator.1"*
  %981 = bitcast %"class.std::allocator.0"* %ref.tmp492 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1177 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1175, i64 0, i32 0
  store i8* %arraydecay.i.i1176, i8** %_M_p.i.i1177, align 8, !tbaa !48
  %call.i.i1178 = call i64 @strlen(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.64, i64 0, i64 0)) #19
  %add.ptr.i1179 = getelementptr inbounds i8, i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.64, i64 0, i64 0), i64 %call.i.i1178
  %cmp.i.i.i.i1180 = icmp eq i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.64, i64 0, i64 0), %add.ptr.i1179
  %982 = bitcast i64* %__dnew.i.i.i.i1174 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %982) #19
  %983 = bitcast i8** %__first.addr.i.i.i.i.i1172 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %983)
  store i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.64, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1172, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1181 = ptrtoint i8* %add.ptr.i1179 to i64
  %sub.ptr.sub.i.i.i.i.i.i1182 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1181, ptrtoint ([17 x i8]* @.str.64 to i64)
  %984 = bitcast i8** %__first.addr.i.i.i.i.i1172 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %984)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1182, i64* %__dnew.i.i.i.i1174, align 8, !tbaa !50
  %cmp3.i.i.i.i1183 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1182, 15
  br i1 %cmp3.i.i.i.i1183, label %if.then4.i.i.i.i1185, label %if.end6.i.i.i.i1192

if.then4.i.i.i.i1185:                             ; preds = %invoke.cont489
  %call5.i.i.i1.i1184 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp491, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1174, i64 0)
          to label %call5.i.i.i.noexc.i1188 unwind label %lpad.i1198

call5.i.i.i.noexc.i1188:                          ; preds = %if.then4.i.i.i.i1185
  %_M_p.i1.i.i.i.i1186 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1184, i8** %_M_p.i1.i.i.i.i1186, align 8, !tbaa !51
  %985 = load i64, i64* %__dnew.i.i.i.i1174, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1187 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 2, i32 0
  store i64 %985, i64* %_M_allocated_capacity.i.i.i.i.i1187, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1192

if.end6.i.i.i.i1192:                              ; preds = %call5.i.i.i.noexc.i1188, %invoke.cont489
  %_M_p.i.i.i.i.i1189 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 0, i32 0
  %986 = load i8*, i8** %_M_p.i.i.i.i.i1189, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1190 = ptrtoint i8* %add.ptr.i1179 to i64
  %sub.ptr.sub.i.i.i.i.i1191 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1190, ptrtoint ([17 x i8]* @.str.64 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1191, label %if.end.i.i.i.i.i.i.i1194 [
    i64 1, label %if.then.i.i.i.i.i.i1193
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1200
  ]

if.then.i.i.i.i.i.i1193:                          ; preds = %if.end6.i.i.i.i1192
  store i8 70, i8* %986, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1200

if.end.i.i.i.i.i.i.i1194:                         ; preds = %if.end6.i.i.i.i1192
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %986, i8* align 1 getelementptr inbounds ([17 x i8], [17 x i8]* @.str.64, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1191, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1200

lpad.i1198:                                       ; preds = %if.then4.i.i.i.i1185
  %987 = landingpad { i8*, i32 }
          cleanup
  %988 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp491 to %"class.std::allocator.0"*
  %989 = bitcast %"class.std::allocator.0"* %988 to %"class.__gnu_cxx::new_allocator.1"*
  %990 = extractvalue { i8*, i32 } %987, 0
  %991 = extractvalue { i8*, i32 } %987, 1
  br label %ehcleanup499

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1200: ; preds = %if.end.i.i.i.i.i.i.i1194, %if.then.i.i.i.i.i.i1193, %if.end6.i.i.i.i1192
  %992 = load i64, i64* %__dnew.i.i.i.i1174, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1195 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 1
  store i64 %992, i64* %_M_string_length.i.i.i.i.i.i1195, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1196 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 0, i32 0
  %993 = load i8*, i8** %_M_p.i.i.i.i.i.i1196, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1197 = getelementptr inbounds i8, i8* %993, i64 %992
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1173) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1173, align 1, !tbaa !27
  %994 = load i8, i8* %ref.tmp.i.i.i.i.i1173, align 1, !tbaa !27
  store i8 %994, i8* %arrayidx.i.i.i.i.i1197, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1173) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %982) #19
  %995 = load double, double* %rnorm, align 8, !tbaa !42
  %call497 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call490, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp491, double %995)
          to label %invoke.cont496 unwind label %lpad495

invoke.cont496:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1200
  %_M_p.i.i.i.i1201 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 0, i32 0
  %996 = load i8*, i8** %_M_p.i.i.i.i1201, align 8, !tbaa !51
  %997 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 2
  %arraydecay.i.i.i.i1202 = bitcast %union.anon* %997 to i8*
  %cmp.i.i.i1203 = icmp eq i8* %996, %arraydecay.i.i.i.i1202
  br i1 %cmp.i.i.i1203, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1209, label %if.then.i.i1207

if.then.i.i1207:                                  ; preds = %invoke.cont496
  %_M_allocated_capacity.i.i1204 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 2, i32 0
  %998 = load i64, i64* %_M_allocated_capacity.i.i1204, align 8, !tbaa !27
  %999 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp491 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1205 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 0, i32 0
  %1000 = load i8*, i8** %_M_p.i.i1.i.i1205, align 8, !tbaa !51
  %add.i.i.i1206 = add i64 %998, 1
  %1001 = bitcast %"class.std::allocator.0"* %999 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1000) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1209

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1209: ; preds = %if.then.i.i1207, %invoke.cont496
  %1002 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp491 to %"class.std::allocator.0"*
  %1003 = bitcast %"class.std::allocator.0"* %1002 to %"class.__gnu_cxx::new_allocator.1"*
  %1004 = bitcast %"class.std::allocator.0"* %ref.tmp492 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %976) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %975) #19
  %mul = mul i32 %1, %0
  %mul502 = mul i32 %mul, %2
  %conv503 = uitofp i64 %call303 to double
  %mul504 = fmul double %conv503, 2.000000e+00
  %conv505 = sitofp i32 %mul502 to double
  %mul506 = fmul double %conv505, 2.000000e+00
  %mul508 = fmul double %conv505, 3.000000e+00
  %1005 = load i32, i32* %num_iters, align 4, !tbaa !2
  %add509 = add nsw i32 %1005, 1
  %conv510 = sitofp i32 %add509 to double
  %mul511 = fmul double %mul504, %conv510
  %mul512 = shl nsw i32 %1005, 1
  %conv513 = sitofp i32 %mul512 to double
  %mul514 = fmul double %mul506, %conv513
  %mul515 = mul nsw i32 %1005, 3
  %add516 = add nsw i32 %mul515, 2
  %conv517 = sitofp i32 %add516 to double
  %mul518 = fmul double %mul508, %conv517
  %add519 = fadd double %mul511, %mul514
  %add520 = fadd double %add519, %mul518
  %arrayidx521 = getelementptr inbounds [5 x double], [5 x double]* %cg_times, i64 0, i64 2
  %1006 = load double, double* %arrayidx521, align 16, !tbaa !42
  %cmp522 = fcmp ogt double %1006, 1.000000e-04
  br i1 %cmp522, label %if.then523, label %if.end526

if.then523:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1209
  %div = fdiv double %mul511, %1006
  %mul525 = fmul double %div, 0x3EB0C6F7A0B5ED8D
  br label %if.end526

lpad369:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit731
  %1007 = landingpad { i8*, i32 }
          cleanup
  %1008 = extractvalue { i8*, i32 } %1007, 0
  %1009 = extractvalue { i8*, i32 } %1007, 1
  br label %ehcleanup394

lpad383:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit789
  %1010 = landingpad { i8*, i32 }
          cleanup
  %1011 = extractvalue { i8*, i32 } %1010, 0
  %1012 = extractvalue { i8*, i32 } %1010, 1
  %_M_p.i.i.i.i1210 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 0, i32 0
  %1013 = load i8*, i8** %_M_p.i.i.i.i1210, align 8, !tbaa !51
  %1014 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 2
  %arraydecay.i.i.i.i1211 = bitcast %union.anon* %1014 to i8*
  %cmp.i.i.i1212 = icmp eq i8* %1013, %arraydecay.i.i.i.i1211
  br i1 %cmp.i.i.i1212, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1218, label %if.then.i.i1216

if.then.i.i1216:                                  ; preds = %lpad383
  %_M_allocated_capacity.i.i1213 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 2, i32 0
  %1015 = load i64, i64* %_M_allocated_capacity.i.i1213, align 8, !tbaa !27
  %1016 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp376 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1214 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp376, i64 0, i32 0, i32 0
  %1017 = load i8*, i8** %_M_p.i.i1.i.i1214, align 8, !tbaa !51
  %add.i.i.i1215 = add i64 %1015, 1
  %1018 = bitcast %"class.std::allocator.0"* %1016 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1017) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1218

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1218: ; preds = %if.then.i.i1216, %lpad383
  %1019 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp376 to %"class.std::allocator.0"*
  %1020 = bitcast %"class.std::allocator.0"* %1019 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup387

ehcleanup387:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1218, %lpad.i787
  %ehselector.slot.10 = phi i32 [ %1012, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1218 ], [ %711, %lpad.i787 ]
  %exn.slot.10 = phi i8* [ %1011, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1218 ], [ %710, %lpad.i787 ]
  %1021 = bitcast %"class.std::allocator.0"* %ref.tmp380 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %696) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %695) #19
  %_M_p.i.i.i.i1219 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 0, i32 0
  %1022 = load i8*, i8** %_M_p.i.i.i.i1219, align 8, !tbaa !51
  %1023 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 2
  %arraydecay.i.i.i.i1220 = bitcast %union.anon* %1023 to i8*
  %cmp.i.i.i1221 = icmp eq i8* %1022, %arraydecay.i.i.i.i1220
  br i1 %cmp.i.i.i1221, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1227, label %if.then.i.i1225

if.then.i.i1225:                                  ; preds = %ehcleanup387
  %_M_allocated_capacity.i.i1222 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 2, i32 0
  %1024 = load i64, i64* %_M_allocated_capacity.i.i1222, align 8, !tbaa !27
  %1025 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp372 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1223 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp372, i64 0, i32 0, i32 0
  %1026 = load i8*, i8** %_M_p.i.i1.i.i1223, align 8, !tbaa !51
  %add.i.i.i1224 = add i64 %1024, 1
  %1027 = bitcast %"class.std::allocator.0"* %1025 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1026) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1227

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1227: ; preds = %if.then.i.i1225, %ehcleanup387
  %1028 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp372 to %"class.std::allocator.0"*
  %1029 = bitcast %"class.std::allocator.0"* %1028 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup391

ehcleanup391:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1227, %lpad.i758
  %ehselector.slot.11 = phi i32 [ %ehselector.slot.10, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1227 ], [ %691, %lpad.i758 ]
  %exn.slot.11 = phi i8* [ %exn.slot.10, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1227 ], [ %690, %lpad.i758 ]
  %1030 = bitcast %"class.std::allocator.0"* %ref.tmp373 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %676) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %675) #19
  br label %ehcleanup394

ehcleanup394:                                     ; preds = %ehcleanup391, %lpad369
  %ehselector.slot.12 = phi i32 [ %ehselector.slot.11, %ehcleanup391 ], [ %1009, %lpad369 ]
  %exn.slot.12 = phi i8* [ %exn.slot.11, %ehcleanup391 ], [ %1008, %lpad369 ]
  %_M_p.i.i.i.i1228 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 0, i32 0
  %1031 = load i8*, i8** %_M_p.i.i.i.i1228, align 8, !tbaa !51
  %1032 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 2
  %arraydecay.i.i.i.i1229 = bitcast %union.anon* %1032 to i8*
  %cmp.i.i.i1230 = icmp eq i8* %1031, %arraydecay.i.i.i.i1229
  br i1 %cmp.i.i.i1230, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1236, label %if.then.i.i1234

if.then.i.i1234:                                  ; preds = %ehcleanup394
  %_M_allocated_capacity.i.i1231 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 2, i32 0
  %1033 = load i64, i64* %_M_allocated_capacity.i.i1231, align 8, !tbaa !27
  %1034 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp365 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1232 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp365, i64 0, i32 0, i32 0
  %1035 = load i8*, i8** %_M_p.i.i1.i.i1232, align 8, !tbaa !51
  %add.i.i.i1233 = add i64 %1033, 1
  %1036 = bitcast %"class.std::allocator.0"* %1034 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1035) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1236

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1236: ; preds = %if.then.i.i1234, %ehcleanup394
  %1037 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp365 to %"class.std::allocator.0"*
  %1038 = bitcast %"class.std::allocator.0"* %1037 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup395

ehcleanup395:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1236, %lpad.i729
  %ehselector.slot.13 = phi i32 [ %ehselector.slot.12, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1236 ], [ %671, %lpad.i729 ]
  %exn.slot.13 = phi i8* [ %exn.slot.12, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1236 ], [ %670, %lpad.i729 ]
  %1039 = bitcast %"class.std::allocator.0"* %ref.tmp366 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %656) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %655) #19
  br label %ehcleanup900

lpad402:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit845
  %1040 = landingpad { i8*, i32 }
          cleanup
  %1041 = extractvalue { i8*, i32 } %1040, 0
  %1042 = extractvalue { i8*, i32 } %1040, 1
  br label %ehcleanup427

lpad416:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit920
  %1043 = landingpad { i8*, i32 }
          cleanup
  %1044 = extractvalue { i8*, i32 } %1043, 0
  %1045 = extractvalue { i8*, i32 } %1043, 1
  %_M_p.i.i.i.i1237 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 0, i32 0
  %1046 = load i8*, i8** %_M_p.i.i.i.i1237, align 8, !tbaa !51
  %1047 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 2
  %arraydecay.i.i.i.i1238 = bitcast %union.anon* %1047 to i8*
  %cmp.i.i.i1239 = icmp eq i8* %1046, %arraydecay.i.i.i.i1238
  br i1 %cmp.i.i.i1239, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1245, label %if.then.i.i1243

if.then.i.i1243:                                  ; preds = %lpad416
  %_M_allocated_capacity.i.i1240 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 2, i32 0
  %1048 = load i64, i64* %_M_allocated_capacity.i.i1240, align 8, !tbaa !27
  %1049 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp409 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1241 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp409, i64 0, i32 0, i32 0
  %1050 = load i8*, i8** %_M_p.i.i1.i.i1241, align 8, !tbaa !51
  %add.i.i.i1242 = add i64 %1048, 1
  %1051 = bitcast %"class.std::allocator.0"* %1049 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1050) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1245

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1245: ; preds = %if.then.i.i1243, %lpad416
  %1052 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp409 to %"class.std::allocator.0"*
  %1053 = bitcast %"class.std::allocator.0"* %1052 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup420

ehcleanup420:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1245, %lpad.i918
  %ehselector.slot.14 = phi i32 [ %1045, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1245 ], [ %798, %lpad.i918 ]
  %exn.slot.14 = phi i8* [ %1044, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1245 ], [ %797, %lpad.i918 ]
  %1054 = bitcast %"class.std::allocator.0"* %ref.tmp413 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %783) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %782) #19
  %_M_p.i.i.i.i1263 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 0, i32 0
  %1055 = load i8*, i8** %_M_p.i.i.i.i1263, align 8, !tbaa !51
  %1056 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 2
  %arraydecay.i.i.i.i1264 = bitcast %union.anon* %1056 to i8*
  %cmp.i.i.i1265 = icmp eq i8* %1055, %arraydecay.i.i.i.i1264
  br i1 %cmp.i.i.i1265, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1271, label %if.then.i.i1269

if.then.i.i1269:                                  ; preds = %ehcleanup420
  %_M_allocated_capacity.i.i1266 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 2, i32 0
  %1057 = load i64, i64* %_M_allocated_capacity.i.i1266, align 8, !tbaa !27
  %1058 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp405 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1267 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp405, i64 0, i32 0, i32 0
  %1059 = load i8*, i8** %_M_p.i.i1.i.i1267, align 8, !tbaa !51
  %add.i.i.i1268 = add i64 %1057, 1
  %1060 = bitcast %"class.std::allocator.0"* %1058 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1059) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1271

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1271: ; preds = %if.then.i.i1269, %ehcleanup420
  %1061 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp405 to %"class.std::allocator.0"*
  %1062 = bitcast %"class.std::allocator.0"* %1061 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup424

ehcleanup424:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1271, %lpad.i872
  %ehselector.slot.15 = phi i32 [ %ehselector.slot.14, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1271 ], [ %778, %lpad.i872 ]
  %exn.slot.15 = phi i8* [ %exn.slot.14, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1271 ], [ %777, %lpad.i872 ]
  %1063 = bitcast %"class.std::allocator.0"* %ref.tmp406 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %763) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %762) #19
  br label %ehcleanup427

ehcleanup427:                                     ; preds = %ehcleanup424, %lpad402
  %ehselector.slot.16 = phi i32 [ %ehselector.slot.15, %ehcleanup424 ], [ %1042, %lpad402 ]
  %exn.slot.16 = phi i8* [ %exn.slot.15, %ehcleanup424 ], [ %1041, %lpad402 ]
  %_M_p.i.i.i.i1272 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 0, i32 0
  %1064 = load i8*, i8** %_M_p.i.i.i.i1272, align 8, !tbaa !51
  %1065 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 2
  %arraydecay.i.i.i.i1273 = bitcast %union.anon* %1065 to i8*
  %cmp.i.i.i1274 = icmp eq i8* %1064, %arraydecay.i.i.i.i1273
  br i1 %cmp.i.i.i1274, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1280, label %if.then.i.i1278

if.then.i.i1278:                                  ; preds = %ehcleanup427
  %_M_allocated_capacity.i.i1275 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 2, i32 0
  %1066 = load i64, i64* %_M_allocated_capacity.i.i1275, align 8, !tbaa !27
  %1067 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp398 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1276 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp398, i64 0, i32 0, i32 0
  %1068 = load i8*, i8** %_M_p.i.i1.i.i1276, align 8, !tbaa !51
  %add.i.i.i1277 = add i64 %1066, 1
  %1069 = bitcast %"class.std::allocator.0"* %1067 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1068) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1280

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1280: ; preds = %if.then.i.i1278, %ehcleanup427
  %1070 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp398 to %"class.std::allocator.0"*
  %1071 = bitcast %"class.std::allocator.0"* %1070 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup428

ehcleanup428:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1280, %lpad.i843
  %ehselector.slot.17 = phi i32 [ %ehselector.slot.16, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1280 ], [ %758, %lpad.i843 ]
  %exn.slot.17 = phi i8* [ %exn.slot.16, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1280 ], [ %757, %lpad.i843 ]
  %1072 = bitcast %"class.std::allocator.0"* %ref.tmp399 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %743) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %742) #19
  br label %ehcleanup900

lpad435:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit976
  %1073 = landingpad { i8*, i32 }
          cleanup
  %1074 = extractvalue { i8*, i32 } %1073, 0
  %1075 = extractvalue { i8*, i32 } %1073, 1
  br label %ehcleanup460

lpad449:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1034
  %1076 = landingpad { i8*, i32 }
          cleanup
  %1077 = extractvalue { i8*, i32 } %1076, 0
  %1078 = extractvalue { i8*, i32 } %1076, 1
  %_M_p.i.i.i.i1281 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 0, i32 0
  %1079 = load i8*, i8** %_M_p.i.i.i.i1281, align 8, !tbaa !51
  %1080 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 2
  %arraydecay.i.i.i.i1282 = bitcast %union.anon* %1080 to i8*
  %cmp.i.i.i1283 = icmp eq i8* %1079, %arraydecay.i.i.i.i1282
  br i1 %cmp.i.i.i1283, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1289, label %if.then.i.i1287

if.then.i.i1287:                                  ; preds = %lpad449
  %_M_allocated_capacity.i.i1284 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 2, i32 0
  %1081 = load i64, i64* %_M_allocated_capacity.i.i1284, align 8, !tbaa !27
  %1082 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp442 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1285 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp442, i64 0, i32 0, i32 0
  %1083 = load i8*, i8** %_M_p.i.i1.i.i1285, align 8, !tbaa !51
  %add.i.i.i1286 = add i64 %1081, 1
  %1084 = bitcast %"class.std::allocator.0"* %1082 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1083) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1289

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1289: ; preds = %if.then.i.i1287, %lpad449
  %1085 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp442 to %"class.std::allocator.0"*
  %1086 = bitcast %"class.std::allocator.0"* %1085 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup453

ehcleanup453:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1289, %lpad.i1032
  %ehselector.slot.18 = phi i32 [ %1078, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1289 ], [ %885, %lpad.i1032 ]
  %exn.slot.18 = phi i8* [ %1077, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1289 ], [ %884, %lpad.i1032 ]
  %1087 = bitcast %"class.std::allocator.0"* %ref.tmp446 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %870) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %869) #19
  %_M_p.i.i.i.i1290 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 0, i32 0
  %1088 = load i8*, i8** %_M_p.i.i.i.i1290, align 8, !tbaa !51
  %1089 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 2
  %arraydecay.i.i.i.i1291 = bitcast %union.anon* %1089 to i8*
  %cmp.i.i.i1292 = icmp eq i8* %1088, %arraydecay.i.i.i.i1291
  br i1 %cmp.i.i.i1292, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1298, label %if.then.i.i1296

if.then.i.i1296:                                  ; preds = %ehcleanup453
  %_M_allocated_capacity.i.i1293 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 2, i32 0
  %1090 = load i64, i64* %_M_allocated_capacity.i.i1293, align 8, !tbaa !27
  %1091 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp438 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1294 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp438, i64 0, i32 0, i32 0
  %1092 = load i8*, i8** %_M_p.i.i1.i.i1294, align 8, !tbaa !51
  %add.i.i.i1295 = add i64 %1090, 1
  %1093 = bitcast %"class.std::allocator.0"* %1091 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1092) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1298

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1298: ; preds = %if.then.i.i1296, %ehcleanup453
  %1094 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp438 to %"class.std::allocator.0"*
  %1095 = bitcast %"class.std::allocator.0"* %1094 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup457

ehcleanup457:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1298, %lpad.i1003
  %ehselector.slot.19 = phi i32 [ %ehselector.slot.18, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1298 ], [ %865, %lpad.i1003 ]
  %exn.slot.19 = phi i8* [ %exn.slot.18, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1298 ], [ %864, %lpad.i1003 ]
  %1096 = bitcast %"class.std::allocator.0"* %ref.tmp439 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %850) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %849) #19
  br label %ehcleanup460

ehcleanup460:                                     ; preds = %ehcleanup457, %lpad435
  %ehselector.slot.20 = phi i32 [ %ehselector.slot.19, %ehcleanup457 ], [ %1075, %lpad435 ]
  %exn.slot.20 = phi i8* [ %exn.slot.19, %ehcleanup457 ], [ %1074, %lpad435 ]
  %_M_p.i.i.i.i1299 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 0, i32 0
  %1097 = load i8*, i8** %_M_p.i.i.i.i1299, align 8, !tbaa !51
  %1098 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 2
  %arraydecay.i.i.i.i1300 = bitcast %union.anon* %1098 to i8*
  %cmp.i.i.i1301 = icmp eq i8* %1097, %arraydecay.i.i.i.i1300
  br i1 %cmp.i.i.i1301, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1307, label %if.then.i.i1305

if.then.i.i1305:                                  ; preds = %ehcleanup460
  %_M_allocated_capacity.i.i1302 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 2, i32 0
  %1099 = load i64, i64* %_M_allocated_capacity.i.i1302, align 8, !tbaa !27
  %1100 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp431 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1303 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp431, i64 0, i32 0, i32 0
  %1101 = load i8*, i8** %_M_p.i.i1.i.i1303, align 8, !tbaa !51
  %add.i.i.i1304 = add i64 %1099, 1
  %1102 = bitcast %"class.std::allocator.0"* %1100 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1101) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1307

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1307: ; preds = %if.then.i.i1305, %ehcleanup460
  %1103 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp431 to %"class.std::allocator.0"*
  %1104 = bitcast %"class.std::allocator.0"* %1103 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup461

ehcleanup461:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1307, %lpad.i974
  %ehselector.slot.21 = phi i32 [ %ehselector.slot.20, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1307 ], [ %845, %lpad.i974 ]
  %exn.slot.21 = phi i8* [ %exn.slot.20, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1307 ], [ %844, %lpad.i974 ]
  %1105 = bitcast %"class.std::allocator.0"* %ref.tmp432 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %830) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %829) #19
  br label %ehcleanup900

lpad468:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1107
  %1106 = landingpad { i8*, i32 }
          cleanup
  %1107 = extractvalue { i8*, i32 } %1106, 0
  %1108 = extractvalue { i8*, i32 } %1106, 1
  %_M_p.i.i.i.i1325 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 0, i32 0
  %1109 = load i8*, i8** %_M_p.i.i.i.i1325, align 8, !tbaa !51
  %1110 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 2
  %arraydecay.i.i.i.i1326 = bitcast %union.anon* %1110 to i8*
  %cmp.i.i.i1327 = icmp eq i8* %1109, %arraydecay.i.i.i.i1326
  br i1 %cmp.i.i.i1327, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1333, label %if.then.i.i1331

if.then.i.i1331:                                  ; preds = %lpad468
  %_M_allocated_capacity.i.i1328 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 2, i32 0
  %1111 = load i64, i64* %_M_allocated_capacity.i.i1328, align 8, !tbaa !27
  %1112 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp464 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1329 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp464, i64 0, i32 0, i32 0
  %1113 = load i8*, i8** %_M_p.i.i1.i.i1329, align 8, !tbaa !51
  %add.i.i.i1330 = add i64 %1111, 1
  %1114 = bitcast %"class.std::allocator.0"* %1112 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1113) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1333

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1333: ; preds = %if.then.i.i1331, %lpad468
  %1115 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp464 to %"class.std::allocator.0"*
  %1116 = bitcast %"class.std::allocator.0"* %1115 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup472

ehcleanup472:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1333, %lpad.i1105
  %ehselector.slot.22 = phi i32 [ %1108, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1333 ], [ %932, %lpad.i1105 ]
  %exn.slot.22 = phi i8* [ %1107, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1333 ], [ %931, %lpad.i1105 ]
  %1117 = bitcast %"class.std::allocator.0"* %ref.tmp465 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %917) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %916) #19
  br label %ehcleanup900

lpad475:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1154, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1116
  %1118 = landingpad { i8*, i32 }
          cleanup
  %1119 = extractvalue { i8*, i32 } %1118, 0
  %1120 = extractvalue { i8*, i32 } %1118, 1
  br label %ehcleanup900

lpad482:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1145
  %1121 = landingpad { i8*, i32 }
          cleanup
  %1122 = extractvalue { i8*, i32 } %1121, 0
  %1123 = extractvalue { i8*, i32 } %1121, 1
  %_M_p.i.i.i.i1334 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 0, i32 0
  %1124 = load i8*, i8** %_M_p.i.i.i.i1334, align 8, !tbaa !51
  %1125 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 2
  %arraydecay.i.i.i.i1335 = bitcast %union.anon* %1125 to i8*
  %cmp.i.i.i1336 = icmp eq i8* %1124, %arraydecay.i.i.i.i1335
  br i1 %cmp.i.i.i1336, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1342, label %if.then.i.i1340

if.then.i.i1340:                                  ; preds = %lpad482
  %_M_allocated_capacity.i.i1337 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 2, i32 0
  %1126 = load i64, i64* %_M_allocated_capacity.i.i1337, align 8, !tbaa !27
  %1127 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp478 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1338 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp478, i64 0, i32 0, i32 0
  %1128 = load i8*, i8** %_M_p.i.i1.i.i1338, align 8, !tbaa !51
  %add.i.i.i1339 = add i64 %1126, 1
  %1129 = bitcast %"class.std::allocator.0"* %1127 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1128) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1342

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1342: ; preds = %if.then.i.i1340, %lpad482
  %1130 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp478 to %"class.std::allocator.0"*
  %1131 = bitcast %"class.std::allocator.0"* %1130 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup486

ehcleanup486:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1342, %lpad.i1143
  %ehselector.slot.23 = phi i32 [ %1123, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1342 ], [ %961, %lpad.i1143 ]
  %exn.slot.23 = phi i8* [ %1122, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1342 ], [ %960, %lpad.i1143 ]
  %1132 = bitcast %"class.std::allocator.0"* %ref.tmp479 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %946) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %945) #19
  br label %ehcleanup900

lpad495:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1200
  %1133 = landingpad { i8*, i32 }
          cleanup
  %1134 = extractvalue { i8*, i32 } %1133, 0
  %1135 = extractvalue { i8*, i32 } %1133, 1
  %_M_p.i.i.i.i1343 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 0, i32 0
  %1136 = load i8*, i8** %_M_p.i.i.i.i1343, align 8, !tbaa !51
  %1137 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 2
  %arraydecay.i.i.i.i1344 = bitcast %union.anon* %1137 to i8*
  %cmp.i.i.i1345 = icmp eq i8* %1136, %arraydecay.i.i.i.i1344
  br i1 %cmp.i.i.i1345, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1351, label %if.then.i.i1349

if.then.i.i1349:                                  ; preds = %lpad495
  %_M_allocated_capacity.i.i1346 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 2, i32 0
  %1138 = load i64, i64* %_M_allocated_capacity.i.i1346, align 8, !tbaa !27
  %1139 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp491 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1347 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp491, i64 0, i32 0, i32 0
  %1140 = load i8*, i8** %_M_p.i.i1.i.i1347, align 8, !tbaa !51
  %add.i.i.i1348 = add i64 %1138, 1
  %1141 = bitcast %"class.std::allocator.0"* %1139 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1140) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1351

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1351: ; preds = %if.then.i.i1349, %lpad495
  %1142 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp491 to %"class.std::allocator.0"*
  %1143 = bitcast %"class.std::allocator.0"* %1142 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup499

ehcleanup499:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1351, %lpad.i1198
  %ehselector.slot.24 = phi i32 [ %1135, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1351 ], [ %991, %lpad.i1198 ]
  %exn.slot.24 = phi i8* [ %1134, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1351 ], [ %990, %lpad.i1198 ]
  %1144 = bitcast %"class.std::allocator.0"* %ref.tmp492 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %976) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %975) #19
  br label %ehcleanup900

if.end526:                                        ; preds = %if.then523, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1209
  %mv_mflops.0 = phi double [ %mul525, %if.then523 ], [ -1.000000e+00, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1209 ]
  %arrayidx527 = getelementptr inbounds [5 x double], [5 x double]* %cg_times, i64 0, i64 1
  %1145 = load double, double* %arrayidx527, align 8, !tbaa !42
  %cmp528 = fcmp ogt double %1145, 1.000000e-04
  br i1 %cmp528, label %if.then529, label %if.end533

if.then529:                                       ; preds = %if.end526
  %div531 = fdiv double %mul514, %1145
  %mul532 = fmul double %div531, 0x3EB0C6F7A0B5ED8D
  br label %if.end533

if.end533:                                        ; preds = %if.then529, %if.end526
  %dot_mflops.0 = phi double [ %mul532, %if.then529 ], [ -1.000000e+00, %if.end526 ]
  %arrayidx534 = getelementptr inbounds [5 x double], [5 x double]* %cg_times, i64 0, i64 0
  %1146 = load double, double* %arrayidx534, align 16, !tbaa !42
  %cmp535 = fcmp ogt double %1146, 1.000000e-04
  br i1 %cmp535, label %if.then536, label %if.end540

if.then536:                                       ; preds = %if.end533
  %div538 = fdiv double %mul518, %1146
  %mul539 = fmul double %div538, 0x3EB0C6F7A0B5ED8D
  br label %if.end540

if.end540:                                        ; preds = %if.then536, %if.end533
  %waxpy_mflops.0 = phi double [ %mul539, %if.then536 ], [ -1.000000e+00, %if.end533 ]
  %arrayidx541 = getelementptr inbounds [5 x double], [5 x double]* %cg_times, i64 0, i64 4
  %1147 = load double, double* %arrayidx541, align 16, !tbaa !42
  %cmp542 = fcmp ogt double %1147, 1.000000e-04
  br i1 %cmp542, label %if.then543, label %if.end547

if.then543:                                       ; preds = %if.end540
  %div545 = fdiv double %add520, %1147
  %mul546 = fmul double %div545, 0x3EB0C6F7A0B5ED8D
  br label %if.end547

if.end547:                                        ; preds = %if.then543, %if.end540
  %total_mflops.0 = phi double [ %mul546, %if.then543 ], [ -1.000000e+00, %if.end540 ]
  %call550 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont549 unwind label %lpad548

invoke.cont549:                                   ; preds = %if.end547
  %1148 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp551 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1148) #19
  %1149 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp552, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1149) #19
  %1150 = bitcast %"class.std::allocator.0"* %ref.tmp552 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1355 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 0
  %1151 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 2
  %arraydecay.i.i1356 = bitcast %union.anon* %1151 to i8*
  %1152 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1355 to %"class.std::allocator.0"*
  %1153 = bitcast %"class.std::allocator.0"* %1152 to %"class.__gnu_cxx::new_allocator.1"*
  %1154 = bitcast %"class.std::allocator.0"* %ref.tmp552 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1357 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1355, i64 0, i32 0
  store i8* %arraydecay.i.i1356, i8** %_M_p.i.i1357, align 8, !tbaa !48
  %call.i.i1358 = call i64 @strlen(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.65, i64 0, i64 0)) #19
  %add.ptr.i1359 = getelementptr inbounds i8, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.65, i64 0, i64 0), i64 %call.i.i1358
  %cmp.i.i.i.i1360 = icmp eq i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.65, i64 0, i64 0), %add.ptr.i1359
  %1155 = bitcast i64* %__dnew.i.i.i.i1354 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1155) #19
  %1156 = bitcast i8** %__first.addr.i.i.i.i.i1352 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1156)
  store i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.65, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1352, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1361 = ptrtoint i8* %add.ptr.i1359 to i64
  %sub.ptr.sub.i.i.i.i.i.i1362 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1361, ptrtoint ([11 x i8]* @.str.65 to i64)
  %1157 = bitcast i8** %__first.addr.i.i.i.i.i1352 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1157)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1362, i64* %__dnew.i.i.i.i1354, align 8, !tbaa !50
  %cmp3.i.i.i.i1363 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1362, 15
  br i1 %cmp3.i.i.i.i1363, label %if.then4.i.i.i.i1365, label %if.end6.i.i.i.i1372

if.then4.i.i.i.i1365:                             ; preds = %invoke.cont549
  %call5.i.i.i1.i1364 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp551, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1354, i64 0)
          to label %call5.i.i.i.noexc.i1368 unwind label %lpad.i1378

call5.i.i.i.noexc.i1368:                          ; preds = %if.then4.i.i.i.i1365
  %_M_p.i1.i.i.i.i1366 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1364, i8** %_M_p.i1.i.i.i.i1366, align 8, !tbaa !51
  %1158 = load i64, i64* %__dnew.i.i.i.i1354, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1367 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 2, i32 0
  store i64 %1158, i64* %_M_allocated_capacity.i.i.i.i.i1367, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1372

if.end6.i.i.i.i1372:                              ; preds = %call5.i.i.i.noexc.i1368, %invoke.cont549
  %_M_p.i.i.i.i.i1369 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 0, i32 0
  %1159 = load i8*, i8** %_M_p.i.i.i.i.i1369, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1370 = ptrtoint i8* %add.ptr.i1359 to i64
  %sub.ptr.sub.i.i.i.i.i1371 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1370, ptrtoint ([11 x i8]* @.str.65 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1371, label %if.end.i.i.i.i.i.i.i1374 [
    i64 1, label %if.then.i.i.i.i.i.i1373
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1380
  ]

if.then.i.i.i.i.i.i1373:                          ; preds = %if.end6.i.i.i.i1372
  store i8 87, i8* %1159, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1380

if.end.i.i.i.i.i.i.i1374:                         ; preds = %if.end6.i.i.i.i1372
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1159, i8* align 1 getelementptr inbounds ([11 x i8], [11 x i8]* @.str.65, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1371, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1380

lpad.i1378:                                       ; preds = %if.then4.i.i.i.i1365
  %1160 = landingpad { i8*, i32 }
          cleanup
  %1161 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp551 to %"class.std::allocator.0"*
  %1162 = bitcast %"class.std::allocator.0"* %1161 to %"class.__gnu_cxx::new_allocator.1"*
  %1163 = extractvalue { i8*, i32 } %1160, 0
  %1164 = extractvalue { i8*, i32 } %1160, 1
  br label %ehcleanup560

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1380: ; preds = %if.end.i.i.i.i.i.i.i1374, %if.then.i.i.i.i.i.i1373, %if.end6.i.i.i.i1372
  %1165 = load i64, i64* %__dnew.i.i.i.i1354, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1375 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 1
  store i64 %1165, i64* %_M_string_length.i.i.i.i.i.i1375, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1376 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 0, i32 0
  %1166 = load i8*, i8** %_M_p.i.i.i.i.i.i1376, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1377 = getelementptr inbounds i8, i8* %1166, i64 %1165
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1353) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1353, align 1, !tbaa !27
  %1167 = load i8, i8* %ref.tmp.i.i.i.i.i1353, align 1, !tbaa !27
  store i8 %1167, i8* %arrayidx.i.i.i.i.i1377, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1353) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1155) #19
  %1168 = load double, double* %arrayidx534, align 16, !tbaa !42
  %call558 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call550, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp551, double %1168)
          to label %invoke.cont557 unwind label %lpad556

invoke.cont557:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1380
  %_M_p.i.i.i.i1381 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 0, i32 0
  %1169 = load i8*, i8** %_M_p.i.i.i.i1381, align 8, !tbaa !51
  %1170 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 2
  %arraydecay.i.i.i.i1382 = bitcast %union.anon* %1170 to i8*
  %cmp.i.i.i1383 = icmp eq i8* %1169, %arraydecay.i.i.i.i1382
  br i1 %cmp.i.i.i1383, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1389, label %if.then.i.i1387

if.then.i.i1387:                                  ; preds = %invoke.cont557
  %_M_allocated_capacity.i.i1384 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 2, i32 0
  %1171 = load i64, i64* %_M_allocated_capacity.i.i1384, align 8, !tbaa !27
  %1172 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp551 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1385 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 0, i32 0
  %1173 = load i8*, i8** %_M_p.i.i1.i.i1385, align 8, !tbaa !51
  %add.i.i.i1386 = add i64 %1171, 1
  %1174 = bitcast %"class.std::allocator.0"* %1172 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1173) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1389

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1389: ; preds = %if.then.i.i1387, %invoke.cont557
  %1175 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp551 to %"class.std::allocator.0"*
  %1176 = bitcast %"class.std::allocator.0"* %1175 to %"class.__gnu_cxx::new_allocator.1"*
  %1177 = bitcast %"class.std::allocator.0"* %ref.tmp552 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1149) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1148) #19
  %call564 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont563 unwind label %lpad548

invoke.cont563:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1389
  %1178 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp565 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1178) #19
  %1179 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp566, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1179) #19
  %1180 = bitcast %"class.std::allocator.0"* %ref.tmp566 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1393 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 0
  %1181 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 2
  %arraydecay.i.i1394 = bitcast %union.anon* %1181 to i8*
  %1182 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1393 to %"class.std::allocator.0"*
  %1183 = bitcast %"class.std::allocator.0"* %1182 to %"class.__gnu_cxx::new_allocator.1"*
  %1184 = bitcast %"class.std::allocator.0"* %ref.tmp566 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1395 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1393, i64 0, i32 0
  store i8* %arraydecay.i.i1394, i8** %_M_p.i.i1395, align 8, !tbaa !48
  %call.i.i1396 = call i64 @strlen(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.66, i64 0, i64 0)) #19
  %add.ptr.i1397 = getelementptr inbounds i8, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.66, i64 0, i64 0), i64 %call.i.i1396
  %cmp.i.i.i.i1398 = icmp eq i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.66, i64 0, i64 0), %add.ptr.i1397
  %1185 = bitcast i64* %__dnew.i.i.i.i1392 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1185) #19
  %1186 = bitcast i8** %__first.addr.i.i.i.i.i1390 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1186)
  store i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.66, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1390, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1399 = ptrtoint i8* %add.ptr.i1397 to i64
  %sub.ptr.sub.i.i.i.i.i.i1400 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1399, ptrtoint ([12 x i8]* @.str.66 to i64)
  %1187 = bitcast i8** %__first.addr.i.i.i.i.i1390 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1187)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1400, i64* %__dnew.i.i.i.i1392, align 8, !tbaa !50
  %cmp3.i.i.i.i1401 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1400, 15
  br i1 %cmp3.i.i.i.i1401, label %if.then4.i.i.i.i1403, label %if.end6.i.i.i.i1410

if.then4.i.i.i.i1403:                             ; preds = %invoke.cont563
  %call5.i.i.i1.i1402 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp565, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1392, i64 0)
          to label %call5.i.i.i.noexc.i1406 unwind label %lpad.i1416

call5.i.i.i.noexc.i1406:                          ; preds = %if.then4.i.i.i.i1403
  %_M_p.i1.i.i.i.i1404 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1402, i8** %_M_p.i1.i.i.i.i1404, align 8, !tbaa !51
  %1188 = load i64, i64* %__dnew.i.i.i.i1392, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1405 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 2, i32 0
  store i64 %1188, i64* %_M_allocated_capacity.i.i.i.i.i1405, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1410

if.end6.i.i.i.i1410:                              ; preds = %call5.i.i.i.noexc.i1406, %invoke.cont563
  %_M_p.i.i.i.i.i1407 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 0, i32 0
  %1189 = load i8*, i8** %_M_p.i.i.i.i.i1407, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1408 = ptrtoint i8* %add.ptr.i1397 to i64
  %sub.ptr.sub.i.i.i.i.i1409 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1408, ptrtoint ([12 x i8]* @.str.66 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1409, label %if.end.i.i.i.i.i.i.i1412 [
    i64 1, label %if.then.i.i.i.i.i.i1411
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1418
  ]

if.then.i.i.i.i.i.i1411:                          ; preds = %if.end6.i.i.i.i1410
  store i8 87, i8* %1189, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1418

if.end.i.i.i.i.i.i.i1412:                         ; preds = %if.end6.i.i.i.i1410
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1189, i8* align 1 getelementptr inbounds ([12 x i8], [12 x i8]* @.str.66, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1409, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1418

lpad.i1416:                                       ; preds = %if.then4.i.i.i.i1403
  %1190 = landingpad { i8*, i32 }
          cleanup
  %1191 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp565 to %"class.std::allocator.0"*
  %1192 = bitcast %"class.std::allocator.0"* %1191 to %"class.__gnu_cxx::new_allocator.1"*
  %1193 = extractvalue { i8*, i32 } %1190, 0
  %1194 = extractvalue { i8*, i32 } %1190, 1
  br label %ehcleanup573

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1418: ; preds = %if.end.i.i.i.i.i.i.i1412, %if.then.i.i.i.i.i.i1411, %if.end6.i.i.i.i1410
  %1195 = load i64, i64* %__dnew.i.i.i.i1392, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1413 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 1
  store i64 %1195, i64* %_M_string_length.i.i.i.i.i.i1413, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1414 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 0, i32 0
  %1196 = load i8*, i8** %_M_p.i.i.i.i.i.i1414, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1415 = getelementptr inbounds i8, i8* %1196, i64 %1195
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1391) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1391, align 1, !tbaa !27
  %1197 = load i8, i8* %ref.tmp.i.i.i.i.i1391, align 1, !tbaa !27
  store i8 %1197, i8* %arrayidx.i.i.i.i.i1415, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1391) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1185) #19
  %call571 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call564, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp565, double %mul518)
          to label %invoke.cont570 unwind label %lpad569

invoke.cont570:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1418
  %_M_p.i.i.i.i1419 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 0, i32 0
  %1198 = load i8*, i8** %_M_p.i.i.i.i1419, align 8, !tbaa !51
  %1199 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 2
  %arraydecay.i.i.i.i1420 = bitcast %union.anon* %1199 to i8*
  %cmp.i.i.i1421 = icmp eq i8* %1198, %arraydecay.i.i.i.i1420
  br i1 %cmp.i.i.i1421, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1427, label %if.then.i.i1425

if.then.i.i1425:                                  ; preds = %invoke.cont570
  %_M_allocated_capacity.i.i1422 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 2, i32 0
  %1200 = load i64, i64* %_M_allocated_capacity.i.i1422, align 8, !tbaa !27
  %1201 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp565 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1423 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 0, i32 0
  %1202 = load i8*, i8** %_M_p.i.i1.i.i1423, align 8, !tbaa !51
  %add.i.i.i1424 = add i64 %1200, 1
  %1203 = bitcast %"class.std::allocator.0"* %1201 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1202) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1427

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1427: ; preds = %if.then.i.i1425, %invoke.cont570
  %1204 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp565 to %"class.std::allocator.0"*
  %1205 = bitcast %"class.std::allocator.0"* %1204 to %"class.__gnu_cxx::new_allocator.1"*
  %1206 = bitcast %"class.std::allocator.0"* %ref.tmp566 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1179) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1178) #19
  %cmp576 = fcmp ult double %waxpy_mflops.0, 0.000000e+00
  br i1 %cmp576, label %if.else591, label %if.then577

if.then577:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1427
  %call579 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont578 unwind label %lpad548

invoke.cont578:                                   ; preds = %if.then577
  %1207 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp580 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1207) #19
  %1208 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp581, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1208) #19
  %1209 = bitcast %"class.std::allocator.0"* %ref.tmp581 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1442 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 0
  %1210 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 2
  %arraydecay.i.i1443 = bitcast %union.anon* %1210 to i8*
  %1211 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1442 to %"class.std::allocator.0"*
  %1212 = bitcast %"class.std::allocator.0"* %1211 to %"class.__gnu_cxx::new_allocator.1"*
  %1213 = bitcast %"class.std::allocator.0"* %ref.tmp581 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1444 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1442, i64 0, i32 0
  store i8* %arraydecay.i.i1443, i8** %_M_p.i.i1444, align 8, !tbaa !48
  %call.i.i1445 = call i64 @strlen(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0)) #19
  %add.ptr.i1446 = getelementptr inbounds i8, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0), i64 %call.i.i1445
  %cmp.i.i.i.i1447 = icmp eq i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0), %add.ptr.i1446
  %1214 = bitcast i64* %__dnew.i.i.i.i1441 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1214) #19
  %1215 = bitcast i8** %__first.addr.i.i.i.i.i1439 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1215)
  store i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1439, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1448 = ptrtoint i8* %add.ptr.i1446 to i64
  %sub.ptr.sub.i.i.i.i.i.i1449 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1448, ptrtoint ([13 x i8]* @.str.67 to i64)
  %1216 = bitcast i8** %__first.addr.i.i.i.i.i1439 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1216)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1449, i64* %__dnew.i.i.i.i1441, align 8, !tbaa !50
  %cmp3.i.i.i.i1450 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1449, 15
  br i1 %cmp3.i.i.i.i1450, label %if.then4.i.i.i.i1452, label %if.end6.i.i.i.i1459

if.then4.i.i.i.i1452:                             ; preds = %invoke.cont578
  %call5.i.i.i1.i1451 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp580, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1441, i64 0)
          to label %call5.i.i.i.noexc.i1455 unwind label %lpad.i1465

call5.i.i.i.noexc.i1455:                          ; preds = %if.then4.i.i.i.i1452
  %_M_p.i1.i.i.i.i1453 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1451, i8** %_M_p.i1.i.i.i.i1453, align 8, !tbaa !51
  %1217 = load i64, i64* %__dnew.i.i.i.i1441, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1454 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 2, i32 0
  store i64 %1217, i64* %_M_allocated_capacity.i.i.i.i.i1454, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1459

if.end6.i.i.i.i1459:                              ; preds = %call5.i.i.i.noexc.i1455, %invoke.cont578
  %_M_p.i.i.i.i.i1456 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 0, i32 0
  %1218 = load i8*, i8** %_M_p.i.i.i.i.i1456, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1457 = ptrtoint i8* %add.ptr.i1446 to i64
  %sub.ptr.sub.i.i.i.i.i1458 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1457, ptrtoint ([13 x i8]* @.str.67 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1458, label %if.end.i.i.i.i.i.i.i1461 [
    i64 1, label %if.then.i.i.i.i.i.i1460
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467
  ]

if.then.i.i.i.i.i.i1460:                          ; preds = %if.end6.i.i.i.i1459
  store i8 87, i8* %1218, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467

if.end.i.i.i.i.i.i.i1461:                         ; preds = %if.end6.i.i.i.i1459
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1218, i8* align 1 getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1458, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467

lpad.i1465:                                       ; preds = %if.then4.i.i.i.i1452
  %1219 = landingpad { i8*, i32 }
          cleanup
  %1220 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp580 to %"class.std::allocator.0"*
  %1221 = bitcast %"class.std::allocator.0"* %1220 to %"class.__gnu_cxx::new_allocator.1"*
  %1222 = extractvalue { i8*, i32 } %1219, 0
  %1223 = extractvalue { i8*, i32 } %1219, 1
  br label %ehcleanup588

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467: ; preds = %if.end.i.i.i.i.i.i.i1461, %if.then.i.i.i.i.i.i1460, %if.end6.i.i.i.i1459
  %1224 = load i64, i64* %__dnew.i.i.i.i1441, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1462 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 1
  store i64 %1224, i64* %_M_string_length.i.i.i.i.i.i1462, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1463 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 0, i32 0
  %1225 = load i8*, i8** %_M_p.i.i.i.i.i.i1463, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1464 = getelementptr inbounds i8, i8* %1225, i64 %1224
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1440) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1440, align 1, !tbaa !27
  %1226 = load i8, i8* %ref.tmp.i.i.i.i.i1440, align 1, !tbaa !27
  store i8 %1226, i8* %arrayidx.i.i.i.i.i1464, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1440) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1214) #19
  %call586 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call579, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp580, double %waxpy_mflops.0)
          to label %if.end613 unwind label %lpad584

lpad548:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1977, %if.else840, %if.then815, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2449, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2344, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2239, %if.else721, %if.then707, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1968, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1901, %if.else656, %if.then642, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1662, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1624, %if.else591, %if.then577, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1389, %if.end547
  %1227 = landingpad { i8*, i32 }
          cleanup
  %1228 = extractvalue { i8*, i32 } %1227, 0
  %1229 = extractvalue { i8*, i32 } %1227, 1
  br label %ehcleanup900

lpad556:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1380
  %1230 = landingpad { i8*, i32 }
          cleanup
  %1231 = extractvalue { i8*, i32 } %1230, 0
  %1232 = extractvalue { i8*, i32 } %1230, 1
  %_M_p.i.i.i.i1468 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 0, i32 0
  %1233 = load i8*, i8** %_M_p.i.i.i.i1468, align 8, !tbaa !51
  %1234 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 2
  %arraydecay.i.i.i.i1469 = bitcast %union.anon* %1234 to i8*
  %cmp.i.i.i1470 = icmp eq i8* %1233, %arraydecay.i.i.i.i1469
  br i1 %cmp.i.i.i1470, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1476, label %if.then.i.i1474

if.then.i.i1474:                                  ; preds = %lpad556
  %_M_allocated_capacity.i.i1471 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 2, i32 0
  %1235 = load i64, i64* %_M_allocated_capacity.i.i1471, align 8, !tbaa !27
  %1236 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp551 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1472 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp551, i64 0, i32 0, i32 0
  %1237 = load i8*, i8** %_M_p.i.i1.i.i1472, align 8, !tbaa !51
  %add.i.i.i1473 = add i64 %1235, 1
  %1238 = bitcast %"class.std::allocator.0"* %1236 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1237) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1476

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1476: ; preds = %if.then.i.i1474, %lpad556
  %1239 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp551 to %"class.std::allocator.0"*
  %1240 = bitcast %"class.std::allocator.0"* %1239 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup560

ehcleanup560:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1476, %lpad.i1378
  %ehselector.slot.25 = phi i32 [ %1232, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1476 ], [ %1164, %lpad.i1378 ]
  %exn.slot.25 = phi i8* [ %1231, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1476 ], [ %1163, %lpad.i1378 ]
  %1241 = bitcast %"class.std::allocator.0"* %ref.tmp552 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1149) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1148) #19
  br label %ehcleanup900

lpad569:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1418
  %1242 = landingpad { i8*, i32 }
          cleanup
  %1243 = extractvalue { i8*, i32 } %1242, 0
  %1244 = extractvalue { i8*, i32 } %1242, 1
  %_M_p.i.i.i.i1477 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 0, i32 0
  %1245 = load i8*, i8** %_M_p.i.i.i.i1477, align 8, !tbaa !51
  %1246 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 2
  %arraydecay.i.i.i.i1478 = bitcast %union.anon* %1246 to i8*
  %cmp.i.i.i1479 = icmp eq i8* %1245, %arraydecay.i.i.i.i1478
  br i1 %cmp.i.i.i1479, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1485, label %if.then.i.i1483

if.then.i.i1483:                                  ; preds = %lpad569
  %_M_allocated_capacity.i.i1480 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 2, i32 0
  %1247 = load i64, i64* %_M_allocated_capacity.i.i1480, align 8, !tbaa !27
  %1248 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp565 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1481 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp565, i64 0, i32 0, i32 0
  %1249 = load i8*, i8** %_M_p.i.i1.i.i1481, align 8, !tbaa !51
  %add.i.i.i1482 = add i64 %1247, 1
  %1250 = bitcast %"class.std::allocator.0"* %1248 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1249) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1485

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1485: ; preds = %if.then.i.i1483, %lpad569
  %1251 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp565 to %"class.std::allocator.0"*
  %1252 = bitcast %"class.std::allocator.0"* %1251 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup573

ehcleanup573:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1485, %lpad.i1416
  %ehselector.slot.26 = phi i32 [ %1244, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1485 ], [ %1194, %lpad.i1416 ]
  %exn.slot.26 = phi i8* [ %1243, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1485 ], [ %1193, %lpad.i1416 ]
  %1253 = bitcast %"class.std::allocator.0"* %ref.tmp566 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1179) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1178) #19
  br label %ehcleanup900

lpad584:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467
  %1254 = landingpad { i8*, i32 }
          cleanup
  %1255 = extractvalue { i8*, i32 } %1254, 0
  %1256 = extractvalue { i8*, i32 } %1254, 1
  %_M_p.i.i.i.i1498 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 0, i32 0
  %1257 = load i8*, i8** %_M_p.i.i.i.i1498, align 8, !tbaa !51
  %1258 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 2
  %arraydecay.i.i.i.i1499 = bitcast %union.anon* %1258 to i8*
  %cmp.i.i.i1500 = icmp eq i8* %1257, %arraydecay.i.i.i.i1499
  br i1 %cmp.i.i.i1500, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1506, label %if.then.i.i1504

if.then.i.i1504:                                  ; preds = %lpad584
  %_M_allocated_capacity.i.i1501 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 2, i32 0
  %1259 = load i64, i64* %_M_allocated_capacity.i.i1501, align 8, !tbaa !27
  %1260 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp580 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1502 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp580, i64 0, i32 0, i32 0
  %1261 = load i8*, i8** %_M_p.i.i1.i.i1502, align 8, !tbaa !51
  %add.i.i.i1503 = add i64 %1259, 1
  %1262 = bitcast %"class.std::allocator.0"* %1260 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1261) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1506

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1506: ; preds = %if.then.i.i1504, %lpad584
  %1263 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp580 to %"class.std::allocator.0"*
  %1264 = bitcast %"class.std::allocator.0"* %1263 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup588

ehcleanup588:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1506, %lpad.i1465
  %ehselector.slot.27 = phi i32 [ %1256, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1506 ], [ %1223, %lpad.i1465 ]
  %exn.slot.27 = phi i8* [ %1255, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1506 ], [ %1222, %lpad.i1465 ]
  %1265 = bitcast %"class.std::allocator.0"* %ref.tmp581 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1208) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1207) #19
  br label %ehcleanup900

if.else591:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1427
  %call593 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont592 unwind label %lpad548

invoke.cont592:                                   ; preds = %if.else591
  %1266 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp594 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1266) #19
  %1267 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp595, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1267) #19
  %1268 = bitcast %"class.std::allocator.0"* %ref.tmp595 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1534 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 0
  %1269 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 2
  %arraydecay.i.i1535 = bitcast %union.anon* %1269 to i8*
  %1270 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1534 to %"class.std::allocator.0"*
  %1271 = bitcast %"class.std::allocator.0"* %1270 to %"class.__gnu_cxx::new_allocator.1"*
  %1272 = bitcast %"class.std::allocator.0"* %ref.tmp595 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1536 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1534, i64 0, i32 0
  store i8* %arraydecay.i.i1535, i8** %_M_p.i.i1536, align 8, !tbaa !48
  %call.i.i1537 = call i64 @strlen(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0)) #19
  %add.ptr.i1538 = getelementptr inbounds i8, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0), i64 %call.i.i1537
  %cmp.i.i.i.i1539 = icmp eq i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0), %add.ptr.i1538
  %1273 = bitcast i64* %__dnew.i.i.i.i1533 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1273) #19
  %1274 = bitcast i8** %__first.addr.i.i.i.i.i1531 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1274)
  store i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1531, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1540 = ptrtoint i8* %add.ptr.i1538 to i64
  %sub.ptr.sub.i.i.i.i.i.i1541 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1540, ptrtoint ([13 x i8]* @.str.67 to i64)
  %1275 = bitcast i8** %__first.addr.i.i.i.i.i1531 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1275)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1541, i64* %__dnew.i.i.i.i1533, align 8, !tbaa !50
  %cmp3.i.i.i.i1542 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1541, 15
  br i1 %cmp3.i.i.i.i1542, label %if.then4.i.i.i.i1544, label %if.end6.i.i.i.i1551

if.then4.i.i.i.i1544:                             ; preds = %invoke.cont592
  %call5.i.i.i1.i1543 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp594, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1533, i64 0)
          to label %call5.i.i.i.noexc.i1547 unwind label %lpad.i1557

call5.i.i.i.noexc.i1547:                          ; preds = %if.then4.i.i.i.i1544
  %_M_p.i1.i.i.i.i1545 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1543, i8** %_M_p.i1.i.i.i.i1545, align 8, !tbaa !51
  %1276 = load i64, i64* %__dnew.i.i.i.i1533, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1546 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 2, i32 0
  store i64 %1276, i64* %_M_allocated_capacity.i.i.i.i.i1546, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1551

if.end6.i.i.i.i1551:                              ; preds = %call5.i.i.i.noexc.i1547, %invoke.cont592
  %_M_p.i.i.i.i.i1548 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 0, i32 0
  %1277 = load i8*, i8** %_M_p.i.i.i.i.i1548, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1549 = ptrtoint i8* %add.ptr.i1538 to i64
  %sub.ptr.sub.i.i.i.i.i1550 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1549, ptrtoint ([13 x i8]* @.str.67 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1550, label %if.end.i.i.i.i.i.i.i1553 [
    i64 1, label %if.then.i.i.i.i.i.i1552
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1559
  ]

if.then.i.i.i.i.i.i1552:                          ; preds = %if.end6.i.i.i.i1551
  store i8 87, i8* %1277, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1559

if.end.i.i.i.i.i.i.i1553:                         ; preds = %if.end6.i.i.i.i1551
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1277, i8* align 1 getelementptr inbounds ([13 x i8], [13 x i8]* @.str.67, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1550, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1559

lpad.i1557:                                       ; preds = %if.then4.i.i.i.i1544
  %1278 = landingpad { i8*, i32 }
          cleanup
  %1279 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp594 to %"class.std::allocator.0"*
  %1280 = bitcast %"class.std::allocator.0"* %1279 to %"class.__gnu_cxx::new_allocator.1"*
  %1281 = extractvalue { i8*, i32 } %1278, 0
  %1282 = extractvalue { i8*, i32 } %1278, 1
  br label %ehcleanup610

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1559: ; preds = %if.end.i.i.i.i.i.i.i1553, %if.then.i.i.i.i.i.i1552, %if.end6.i.i.i.i1551
  %1283 = load i64, i64* %__dnew.i.i.i.i1533, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1554 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 1
  store i64 %1283, i64* %_M_string_length.i.i.i.i.i.i1554, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1555 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 0, i32 0
  %1284 = load i8*, i8** %_M_p.i.i.i.i.i.i1555, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1556 = getelementptr inbounds i8, i8* %1284, i64 %1283
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1532) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1532, align 1, !tbaa !27
  %1285 = load i8, i8* %ref.tmp.i.i.i.i.i1532, align 1, !tbaa !27
  store i8 %1285, i8* %arrayidx.i.i.i.i.i1556, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1532) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1273) #19
  %1286 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp598 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1286) #19
  %1287 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp599, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1287) #19
  %1288 = bitcast %"class.std::allocator.0"* %ref.tmp599 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1563 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 0
  %1289 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 2
  %arraydecay.i.i1564 = bitcast %union.anon* %1289 to i8*
  %1290 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1563 to %"class.std::allocator.0"*
  %1291 = bitcast %"class.std::allocator.0"* %1290 to %"class.__gnu_cxx::new_allocator.1"*
  %1292 = bitcast %"class.std::allocator.0"* %ref.tmp599 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1565 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1563, i64 0, i32 0
  store i8* %arraydecay.i.i1564, i8** %_M_p.i.i1565, align 8, !tbaa !48
  %call.i.i1566 = call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0)) #19
  %add.ptr.i1567 = getelementptr inbounds i8, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i64 %call.i.i1566
  %cmp.i.i.i.i1568 = icmp eq i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), %add.ptr.i1567
  %1293 = bitcast i64* %__dnew.i.i.i.i1562 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1293) #19
  %1294 = bitcast i8** %__first.addr.i.i.i.i.i1560 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1294)
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1560, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1569 = ptrtoint i8* %add.ptr.i1567 to i64
  %sub.ptr.sub.i.i.i.i.i.i1570 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1569, ptrtoint ([4 x i8]* @.str.68 to i64)
  %1295 = bitcast i8** %__first.addr.i.i.i.i.i1560 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1295)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1570, i64* %__dnew.i.i.i.i1562, align 8, !tbaa !50
  %cmp3.i.i.i.i1571 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1570, 15
  br i1 %cmp3.i.i.i.i1571, label %if.then4.i.i.i.i1573, label %if.end6.i.i.i.i1580

if.then4.i.i.i.i1573:                             ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1559
  %call5.i.i.i1.i1572 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp598, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1562, i64 0)
          to label %call5.i.i.i.noexc.i1576 unwind label %lpad.i1586

call5.i.i.i.noexc.i1576:                          ; preds = %if.then4.i.i.i.i1573
  %_M_p.i1.i.i.i.i1574 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1572, i8** %_M_p.i1.i.i.i.i1574, align 8, !tbaa !51
  %1296 = load i64, i64* %__dnew.i.i.i.i1562, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1575 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 2, i32 0
  store i64 %1296, i64* %_M_allocated_capacity.i.i.i.i.i1575, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1580

if.end6.i.i.i.i1580:                              ; preds = %call5.i.i.i.noexc.i1576, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1559
  %_M_p.i.i.i.i.i1577 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 0, i32 0
  %1297 = load i8*, i8** %_M_p.i.i.i.i.i1577, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1578 = ptrtoint i8* %add.ptr.i1567 to i64
  %sub.ptr.sub.i.i.i.i.i1579 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1578, ptrtoint ([4 x i8]* @.str.68 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1579, label %if.end.i.i.i.i.i.i.i1582 [
    i64 1, label %if.then.i.i.i.i.i.i1581
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1588
  ]

if.then.i.i.i.i.i.i1581:                          ; preds = %if.end6.i.i.i.i1580
  store i8 105, i8* %1297, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1588

if.end.i.i.i.i.i.i.i1582:                         ; preds = %if.end6.i.i.i.i1580
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1297, i8* align 1 getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1579, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1588

lpad.i1586:                                       ; preds = %if.then4.i.i.i.i1573
  %1298 = landingpad { i8*, i32 }
          cleanup
  %1299 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp598 to %"class.std::allocator.0"*
  %1300 = bitcast %"class.std::allocator.0"* %1299 to %"class.__gnu_cxx::new_allocator.1"*
  %1301 = extractvalue { i8*, i32 } %1298, 0
  %1302 = extractvalue { i8*, i32 } %1298, 1
  br label %ehcleanup606

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1588: ; preds = %if.end.i.i.i.i.i.i.i1582, %if.then.i.i.i.i.i.i1581, %if.end6.i.i.i.i1580
  %1303 = load i64, i64* %__dnew.i.i.i.i1562, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1583 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 1
  store i64 %1303, i64* %_M_string_length.i.i.i.i.i.i1583, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1584 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 0, i32 0
  %1304 = load i8*, i8** %_M_p.i.i.i.i.i.i1584, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1585 = getelementptr inbounds i8, i8* %1304, i64 %1303
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1561) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1561, align 1, !tbaa !27
  %1305 = load i8, i8* %ref.tmp.i.i.i.i.i1561, align 1, !tbaa !27
  store i8 %1305, i8* %arrayidx.i.i.i.i.i1585, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1561) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1293) #19
  %call604 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* %call593, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp594, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp598)
          to label %invoke.cont603 unwind label %lpad602

invoke.cont603:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1588
  %_M_p.i.i.i.i1589 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 0, i32 0
  %1306 = load i8*, i8** %_M_p.i.i.i.i1589, align 8, !tbaa !51
  %1307 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 2
  %arraydecay.i.i.i.i1590 = bitcast %union.anon* %1307 to i8*
  %cmp.i.i.i1591 = icmp eq i8* %1306, %arraydecay.i.i.i.i1590
  br i1 %cmp.i.i.i1591, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1597, label %if.then.i.i1595

if.then.i.i1595:                                  ; preds = %invoke.cont603
  %_M_allocated_capacity.i.i1592 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 2, i32 0
  %1308 = load i64, i64* %_M_allocated_capacity.i.i1592, align 8, !tbaa !27
  %1309 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp598 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1593 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 0, i32 0
  %1310 = load i8*, i8** %_M_p.i.i1.i.i1593, align 8, !tbaa !51
  %add.i.i.i1594 = add i64 %1308, 1
  %1311 = bitcast %"class.std::allocator.0"* %1309 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1310) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1597

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1597: ; preds = %if.then.i.i1595, %invoke.cont603
  %1312 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp598 to %"class.std::allocator.0"*
  %1313 = bitcast %"class.std::allocator.0"* %1312 to %"class.__gnu_cxx::new_allocator.1"*
  %1314 = bitcast %"class.std::allocator.0"* %ref.tmp599 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1287) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1286) #19
  br label %if.end613

lpad602:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1588
  %1315 = landingpad { i8*, i32 }
          cleanup
  %1316 = extractvalue { i8*, i32 } %1315, 0
  %1317 = extractvalue { i8*, i32 } %1315, 1
  %_M_p.i.i.i.i1598 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 0, i32 0
  %1318 = load i8*, i8** %_M_p.i.i.i.i1598, align 8, !tbaa !51
  %1319 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 2
  %arraydecay.i.i.i.i1599 = bitcast %union.anon* %1319 to i8*
  %cmp.i.i.i1600 = icmp eq i8* %1318, %arraydecay.i.i.i.i1599
  br i1 %cmp.i.i.i1600, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1606, label %if.then.i.i1604

if.then.i.i1604:                                  ; preds = %lpad602
  %_M_allocated_capacity.i.i1601 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 2, i32 0
  %1320 = load i64, i64* %_M_allocated_capacity.i.i1601, align 8, !tbaa !27
  %1321 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp598 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1602 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp598, i64 0, i32 0, i32 0
  %1322 = load i8*, i8** %_M_p.i.i1.i.i1602, align 8, !tbaa !51
  %add.i.i.i1603 = add i64 %1320, 1
  %1323 = bitcast %"class.std::allocator.0"* %1321 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1322) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1606

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1606: ; preds = %if.then.i.i1604, %lpad602
  %1324 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp598 to %"class.std::allocator.0"*
  %1325 = bitcast %"class.std::allocator.0"* %1324 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup606

ehcleanup606:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1606, %lpad.i1586
  %ehselector.slot.28 = phi i32 [ %1317, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1606 ], [ %1302, %lpad.i1586 ]
  %exn.slot.28 = phi i8* [ %1316, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1606 ], [ %1301, %lpad.i1586 ]
  %1326 = bitcast %"class.std::allocator.0"* %ref.tmp599 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1287) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1286) #19
  %_M_p.i.i.i.i1607 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 0, i32 0
  %1327 = load i8*, i8** %_M_p.i.i.i.i1607, align 8, !tbaa !51
  %1328 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 2
  %arraydecay.i.i.i.i1608 = bitcast %union.anon* %1328 to i8*
  %cmp.i.i.i1609 = icmp eq i8* %1327, %arraydecay.i.i.i.i1608
  br i1 %cmp.i.i.i1609, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1615, label %if.then.i.i1613

if.then.i.i1613:                                  ; preds = %ehcleanup606
  %_M_allocated_capacity.i.i1610 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 2, i32 0
  %1329 = load i64, i64* %_M_allocated_capacity.i.i1610, align 8, !tbaa !27
  %1330 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp594 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1611 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594, i64 0, i32 0, i32 0
  %1331 = load i8*, i8** %_M_p.i.i1.i.i1611, align 8, !tbaa !51
  %add.i.i.i1612 = add i64 %1329, 1
  %1332 = bitcast %"class.std::allocator.0"* %1330 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1331) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1615

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1615: ; preds = %if.then.i.i1613, %ehcleanup606
  %1333 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp594 to %"class.std::allocator.0"*
  %1334 = bitcast %"class.std::allocator.0"* %1333 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup610

ehcleanup610:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1615, %lpad.i1557
  %ehselector.slot.29 = phi i32 [ %ehselector.slot.28, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1615 ], [ %1282, %lpad.i1557 ]
  %exn.slot.29 = phi i8* [ %exn.slot.28, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1615 ], [ %1281, %lpad.i1557 ]
  %1335 = bitcast %"class.std::allocator.0"* %ref.tmp595 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1267) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1266) #19
  br label %ehcleanup900

if.end613:                                        ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1597, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467
  %ref.tmp594.sink = phi %"class.std::__cxx11::basic_string"* [ %ref.tmp594, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1597 ], [ %ref.tmp580, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467 ]
  %ref.tmp595.sink = phi %"class.std::allocator.0"* [ %ref.tmp595, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1597 ], [ %ref.tmp581, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467 ]
  %.sink1089 = phi i8* [ %1267, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1597 ], [ %1208, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467 ]
  %.sink = phi i8* [ %1266, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1597 ], [ %1207, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1467 ]
  %_M_p.i.i.i.i1616 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594.sink, i64 0, i32 0, i32 0
  %1336 = load i8*, i8** %_M_p.i.i.i.i1616, align 8, !tbaa !51
  %1337 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594.sink, i64 0, i32 2
  %arraydecay.i.i.i.i1617 = bitcast %union.anon* %1337 to i8*
  %cmp.i.i.i1618 = icmp eq i8* %1336, %arraydecay.i.i.i.i1617
  br i1 %cmp.i.i.i1618, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1624, label %if.then.i.i1622

if.then.i.i1622:                                  ; preds = %if.end613
  %_M_allocated_capacity.i.i1619 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594.sink, i64 0, i32 2, i32 0
  %1338 = load i64, i64* %_M_allocated_capacity.i.i1619, align 8, !tbaa !27
  %1339 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp594.sink to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1620 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp594.sink, i64 0, i32 0, i32 0
  %1340 = load i8*, i8** %_M_p.i.i1.i.i1620, align 8, !tbaa !51
  %add.i.i.i1621 = add i64 %1338, 1
  %1341 = bitcast %"class.std::allocator.0"* %1339 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1340) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1624

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1624: ; preds = %if.then.i.i1622, %if.end613
  %1342 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp594.sink to %"class.std::allocator.0"*
  %1343 = bitcast %"class.std::allocator.0"* %1342 to %"class.__gnu_cxx::new_allocator.1"*
  %1344 = bitcast %"class.std::allocator.0"* %ref.tmp595.sink to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %.sink1089) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.sink) #19
  %call615 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont614 unwind label %lpad548

invoke.cont614:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1624
  %1345 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp616 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1345) #19
  %1346 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp617, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1346) #19
  %1347 = bitcast %"class.std::allocator.0"* %ref.tmp617 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1628 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 0
  %1348 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 2
  %arraydecay.i.i1629 = bitcast %union.anon* %1348 to i8*
  %1349 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1628 to %"class.std::allocator.0"*
  %1350 = bitcast %"class.std::allocator.0"* %1349 to %"class.__gnu_cxx::new_allocator.1"*
  %1351 = bitcast %"class.std::allocator.0"* %ref.tmp617 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1630 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1628, i64 0, i32 0
  store i8* %arraydecay.i.i1629, i8** %_M_p.i.i1630, align 8, !tbaa !48
  %call.i.i1631 = call i64 @strlen(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.69, i64 0, i64 0)) #19
  %add.ptr.i1632 = getelementptr inbounds i8, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.69, i64 0, i64 0), i64 %call.i.i1631
  %cmp.i.i.i.i1633 = icmp eq i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.69, i64 0, i64 0), %add.ptr.i1632
  %1352 = bitcast i64* %__dnew.i.i.i.i1627 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1352) #19
  %1353 = bitcast i8** %__first.addr.i.i.i.i.i1625 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1353)
  store i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.69, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1625, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1634 = ptrtoint i8* %add.ptr.i1632 to i64
  %sub.ptr.sub.i.i.i.i.i.i1635 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1634, ptrtoint ([9 x i8]* @.str.69 to i64)
  %1354 = bitcast i8** %__first.addr.i.i.i.i.i1625 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1354)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1635, i64* %__dnew.i.i.i.i1627, align 8, !tbaa !50
  %cmp3.i.i.i.i1636 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1635, 15
  br i1 %cmp3.i.i.i.i1636, label %if.then4.i.i.i.i1638, label %if.end6.i.i.i.i1645

if.then4.i.i.i.i1638:                             ; preds = %invoke.cont614
  %call5.i.i.i1.i1637 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp616, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1627, i64 0)
          to label %call5.i.i.i.noexc.i1641 unwind label %lpad.i1651

call5.i.i.i.noexc.i1641:                          ; preds = %if.then4.i.i.i.i1638
  %_M_p.i1.i.i.i.i1639 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1637, i8** %_M_p.i1.i.i.i.i1639, align 8, !tbaa !51
  %1355 = load i64, i64* %__dnew.i.i.i.i1627, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1640 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 2, i32 0
  store i64 %1355, i64* %_M_allocated_capacity.i.i.i.i.i1640, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1645

if.end6.i.i.i.i1645:                              ; preds = %call5.i.i.i.noexc.i1641, %invoke.cont614
  %_M_p.i.i.i.i.i1642 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 0, i32 0
  %1356 = load i8*, i8** %_M_p.i.i.i.i.i1642, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1643 = ptrtoint i8* %add.ptr.i1632 to i64
  %sub.ptr.sub.i.i.i.i.i1644 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1643, ptrtoint ([9 x i8]* @.str.69 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1644, label %if.end.i.i.i.i.i.i.i1647 [
    i64 1, label %if.then.i.i.i.i.i.i1646
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1653
  ]

if.then.i.i.i.i.i.i1646:                          ; preds = %if.end6.i.i.i.i1645
  store i8 68, i8* %1356, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1653

if.end.i.i.i.i.i.i.i1647:                         ; preds = %if.end6.i.i.i.i1645
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1356, i8* align 1 getelementptr inbounds ([9 x i8], [9 x i8]* @.str.69, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1644, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1653

lpad.i1651:                                       ; preds = %if.then4.i.i.i.i1638
  %1357 = landingpad { i8*, i32 }
          cleanup
  %1358 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp616 to %"class.std::allocator.0"*
  %1359 = bitcast %"class.std::allocator.0"* %1358 to %"class.__gnu_cxx::new_allocator.1"*
  %1360 = extractvalue { i8*, i32 } %1357, 0
  %1361 = extractvalue { i8*, i32 } %1357, 1
  br label %ehcleanup625

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1653: ; preds = %if.end.i.i.i.i.i.i.i1647, %if.then.i.i.i.i.i.i1646, %if.end6.i.i.i.i1645
  %1362 = load i64, i64* %__dnew.i.i.i.i1627, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1648 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 1
  store i64 %1362, i64* %_M_string_length.i.i.i.i.i.i1648, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1649 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 0, i32 0
  %1363 = load i8*, i8** %_M_p.i.i.i.i.i.i1649, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1650 = getelementptr inbounds i8, i8* %1363, i64 %1362
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1626) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1626, align 1, !tbaa !27
  %1364 = load i8, i8* %ref.tmp.i.i.i.i.i1626, align 1, !tbaa !27
  store i8 %1364, i8* %arrayidx.i.i.i.i.i1650, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1626) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1352) #19
  %1365 = load double, double* %arrayidx527, align 8, !tbaa !42
  %call623 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call615, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp616, double %1365)
          to label %invoke.cont622 unwind label %lpad621

invoke.cont622:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1653
  %_M_p.i.i.i.i1654 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 0, i32 0
  %1366 = load i8*, i8** %_M_p.i.i.i.i1654, align 8, !tbaa !51
  %1367 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 2
  %arraydecay.i.i.i.i1655 = bitcast %union.anon* %1367 to i8*
  %cmp.i.i.i1656 = icmp eq i8* %1366, %arraydecay.i.i.i.i1655
  br i1 %cmp.i.i.i1656, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1662, label %if.then.i.i1660

if.then.i.i1660:                                  ; preds = %invoke.cont622
  %_M_allocated_capacity.i.i1657 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 2, i32 0
  %1368 = load i64, i64* %_M_allocated_capacity.i.i1657, align 8, !tbaa !27
  %1369 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp616 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1658 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 0, i32 0
  %1370 = load i8*, i8** %_M_p.i.i1.i.i1658, align 8, !tbaa !51
  %add.i.i.i1659 = add i64 %1368, 1
  %1371 = bitcast %"class.std::allocator.0"* %1369 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1370) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1662

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1662: ; preds = %if.then.i.i1660, %invoke.cont622
  %1372 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp616 to %"class.std::allocator.0"*
  %1373 = bitcast %"class.std::allocator.0"* %1372 to %"class.__gnu_cxx::new_allocator.1"*
  %1374 = bitcast %"class.std::allocator.0"* %ref.tmp617 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1346) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1345) #19
  %call629 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont628 unwind label %lpad548

invoke.cont628:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1662
  %1375 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp630 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1375) #19
  %1376 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp631, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1376) #19
  %1377 = bitcast %"class.std::allocator.0"* %ref.tmp631 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1666 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 0
  %1378 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 2
  %arraydecay.i.i1667 = bitcast %union.anon* %1378 to i8*
  %1379 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1666 to %"class.std::allocator.0"*
  %1380 = bitcast %"class.std::allocator.0"* %1379 to %"class.__gnu_cxx::new_allocator.1"*
  %1381 = bitcast %"class.std::allocator.0"* %ref.tmp631 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1668 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1666, i64 0, i32 0
  store i8* %arraydecay.i.i1667, i8** %_M_p.i.i1668, align 8, !tbaa !48
  %call.i.i1669 = call i64 @strlen(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.70, i64 0, i64 0)) #19
  %add.ptr.i1670 = getelementptr inbounds i8, i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.70, i64 0, i64 0), i64 %call.i.i1669
  %cmp.i.i.i.i1671 = icmp eq i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.70, i64 0, i64 0), %add.ptr.i1670
  %1382 = bitcast i64* %__dnew.i.i.i.i1665 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1382) #19
  %1383 = bitcast i8** %__first.addr.i.i.i.i.i1663 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1383)
  store i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.70, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1663, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1672 = ptrtoint i8* %add.ptr.i1670 to i64
  %sub.ptr.sub.i.i.i.i.i.i1673 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1672, ptrtoint ([10 x i8]* @.str.70 to i64)
  %1384 = bitcast i8** %__first.addr.i.i.i.i.i1663 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1384)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1673, i64* %__dnew.i.i.i.i1665, align 8, !tbaa !50
  %cmp3.i.i.i.i1674 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1673, 15
  br i1 %cmp3.i.i.i.i1674, label %if.then4.i.i.i.i1676, label %if.end6.i.i.i.i1683

if.then4.i.i.i.i1676:                             ; preds = %invoke.cont628
  %call5.i.i.i1.i1675 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp630, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1665, i64 0)
          to label %call5.i.i.i.noexc.i1679 unwind label %lpad.i1689

call5.i.i.i.noexc.i1679:                          ; preds = %if.then4.i.i.i.i1676
  %_M_p.i1.i.i.i.i1677 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1675, i8** %_M_p.i1.i.i.i.i1677, align 8, !tbaa !51
  %1385 = load i64, i64* %__dnew.i.i.i.i1665, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1678 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 2, i32 0
  store i64 %1385, i64* %_M_allocated_capacity.i.i.i.i.i1678, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1683

if.end6.i.i.i.i1683:                              ; preds = %call5.i.i.i.noexc.i1679, %invoke.cont628
  %_M_p.i.i.i.i.i1680 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 0, i32 0
  %1386 = load i8*, i8** %_M_p.i.i.i.i.i1680, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1681 = ptrtoint i8* %add.ptr.i1670 to i64
  %sub.ptr.sub.i.i.i.i.i1682 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1681, ptrtoint ([10 x i8]* @.str.70 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1682, label %if.end.i.i.i.i.i.i.i1685 [
    i64 1, label %if.then.i.i.i.i.i.i1684
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1691
  ]

if.then.i.i.i.i.i.i1684:                          ; preds = %if.end6.i.i.i.i1683
  store i8 68, i8* %1386, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1691

if.end.i.i.i.i.i.i.i1685:                         ; preds = %if.end6.i.i.i.i1683
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1386, i8* align 1 getelementptr inbounds ([10 x i8], [10 x i8]* @.str.70, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1682, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1691

lpad.i1689:                                       ; preds = %if.then4.i.i.i.i1676
  %1387 = landingpad { i8*, i32 }
          cleanup
  %1388 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp630 to %"class.std::allocator.0"*
  %1389 = bitcast %"class.std::allocator.0"* %1388 to %"class.__gnu_cxx::new_allocator.1"*
  %1390 = extractvalue { i8*, i32 } %1387, 0
  %1391 = extractvalue { i8*, i32 } %1387, 1
  br label %ehcleanup638

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1691: ; preds = %if.end.i.i.i.i.i.i.i1685, %if.then.i.i.i.i.i.i1684, %if.end6.i.i.i.i1683
  %1392 = load i64, i64* %__dnew.i.i.i.i1665, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1686 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 1
  store i64 %1392, i64* %_M_string_length.i.i.i.i.i.i1686, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1687 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 0, i32 0
  %1393 = load i8*, i8** %_M_p.i.i.i.i.i.i1687, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1688 = getelementptr inbounds i8, i8* %1393, i64 %1392
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1664) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1664, align 1, !tbaa !27
  %1394 = load i8, i8* %ref.tmp.i.i.i.i.i1664, align 1, !tbaa !27
  store i8 %1394, i8* %arrayidx.i.i.i.i.i1688, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1664) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1382) #19
  %call636 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call629, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp630, double %mul514)
          to label %invoke.cont635 unwind label %lpad634

invoke.cont635:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1691
  %_M_p.i.i.i.i1692 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 0, i32 0
  %1395 = load i8*, i8** %_M_p.i.i.i.i1692, align 8, !tbaa !51
  %1396 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 2
  %arraydecay.i.i.i.i1693 = bitcast %union.anon* %1396 to i8*
  %cmp.i.i.i1694 = icmp eq i8* %1395, %arraydecay.i.i.i.i1693
  br i1 %cmp.i.i.i1694, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1700, label %if.then.i.i1698

if.then.i.i1698:                                  ; preds = %invoke.cont635
  %_M_allocated_capacity.i.i1695 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 2, i32 0
  %1397 = load i64, i64* %_M_allocated_capacity.i.i1695, align 8, !tbaa !27
  %1398 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp630 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1696 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 0, i32 0
  %1399 = load i8*, i8** %_M_p.i.i1.i.i1696, align 8, !tbaa !51
  %add.i.i.i1697 = add i64 %1397, 1
  %1400 = bitcast %"class.std::allocator.0"* %1398 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1399) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1700

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1700: ; preds = %if.then.i.i1698, %invoke.cont635
  %1401 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp630 to %"class.std::allocator.0"*
  %1402 = bitcast %"class.std::allocator.0"* %1401 to %"class.__gnu_cxx::new_allocator.1"*
  %1403 = bitcast %"class.std::allocator.0"* %ref.tmp631 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1376) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1375) #19
  %cmp641 = fcmp ult double %dot_mflops.0, 0.000000e+00
  br i1 %cmp641, label %if.else656, label %if.then642

if.then642:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1700
  %call644 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont643 unwind label %lpad548

invoke.cont643:                                   ; preds = %if.then642
  %1404 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp645 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1404) #19
  %1405 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp646, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1405) #19
  %1406 = bitcast %"class.std::allocator.0"* %ref.tmp646 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1704 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 0
  %1407 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 2
  %arraydecay.i.i1705 = bitcast %union.anon* %1407 to i8*
  %1408 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1704 to %"class.std::allocator.0"*
  %1409 = bitcast %"class.std::allocator.0"* %1408 to %"class.__gnu_cxx::new_allocator.1"*
  %1410 = bitcast %"class.std::allocator.0"* %ref.tmp646 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1706 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1704, i64 0, i32 0
  store i8* %arraydecay.i.i1705, i8** %_M_p.i.i1706, align 8, !tbaa !48
  %call.i.i1707 = call i64 @strlen(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0)) #19
  %add.ptr.i1708 = getelementptr inbounds i8, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0), i64 %call.i.i1707
  %cmp.i.i.i.i1709 = icmp eq i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0), %add.ptr.i1708
  %1411 = bitcast i64* %__dnew.i.i.i.i1703 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1411) #19
  %1412 = bitcast i8** %__first.addr.i.i.i.i.i1701 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1412)
  store i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1701, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1710 = ptrtoint i8* %add.ptr.i1708 to i64
  %sub.ptr.sub.i.i.i.i.i.i1711 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1710, ptrtoint ([11 x i8]* @.str.71 to i64)
  %1413 = bitcast i8** %__first.addr.i.i.i.i.i1701 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1413)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1711, i64* %__dnew.i.i.i.i1703, align 8, !tbaa !50
  %cmp3.i.i.i.i1712 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1711, 15
  br i1 %cmp3.i.i.i.i1712, label %if.then4.i.i.i.i1714, label %if.end6.i.i.i.i1721

if.then4.i.i.i.i1714:                             ; preds = %invoke.cont643
  %call5.i.i.i1.i1713 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp645, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1703, i64 0)
          to label %call5.i.i.i.noexc.i1717 unwind label %lpad.i1727

call5.i.i.i.noexc.i1717:                          ; preds = %if.then4.i.i.i.i1714
  %_M_p.i1.i.i.i.i1715 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1713, i8** %_M_p.i1.i.i.i.i1715, align 8, !tbaa !51
  %1414 = load i64, i64* %__dnew.i.i.i.i1703, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1716 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 2, i32 0
  store i64 %1414, i64* %_M_allocated_capacity.i.i.i.i.i1716, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1721

if.end6.i.i.i.i1721:                              ; preds = %call5.i.i.i.noexc.i1717, %invoke.cont643
  %_M_p.i.i.i.i.i1718 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 0, i32 0
  %1415 = load i8*, i8** %_M_p.i.i.i.i.i1718, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1719 = ptrtoint i8* %add.ptr.i1708 to i64
  %sub.ptr.sub.i.i.i.i.i1720 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1719, ptrtoint ([11 x i8]* @.str.71 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1720, label %if.end.i.i.i.i.i.i.i1723 [
    i64 1, label %if.then.i.i.i.i.i.i1722
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729
  ]

if.then.i.i.i.i.i.i1722:                          ; preds = %if.end6.i.i.i.i1721
  store i8 68, i8* %1415, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729

if.end.i.i.i.i.i.i.i1723:                         ; preds = %if.end6.i.i.i.i1721
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1415, i8* align 1 getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1720, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729

lpad.i1727:                                       ; preds = %if.then4.i.i.i.i1714
  %1416 = landingpad { i8*, i32 }
          cleanup
  %1417 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp645 to %"class.std::allocator.0"*
  %1418 = bitcast %"class.std::allocator.0"* %1417 to %"class.__gnu_cxx::new_allocator.1"*
  %1419 = extractvalue { i8*, i32 } %1416, 0
  %1420 = extractvalue { i8*, i32 } %1416, 1
  br label %ehcleanup653

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729: ; preds = %if.end.i.i.i.i.i.i.i1723, %if.then.i.i.i.i.i.i1722, %if.end6.i.i.i.i1721
  %1421 = load i64, i64* %__dnew.i.i.i.i1703, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1724 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 1
  store i64 %1421, i64* %_M_string_length.i.i.i.i.i.i1724, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1725 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 0, i32 0
  %1422 = load i8*, i8** %_M_p.i.i.i.i.i.i1725, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1726 = getelementptr inbounds i8, i8* %1422, i64 %1421
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1702) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1702, align 1, !tbaa !27
  %1423 = load i8, i8* %ref.tmp.i.i.i.i.i1702, align 1, !tbaa !27
  store i8 %1423, i8* %arrayidx.i.i.i.i.i1726, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1702) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1411) #19
  %call651 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call644, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp645, double %dot_mflops.0)
          to label %if.end678 unwind label %lpad649

lpad621:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1653
  %1424 = landingpad { i8*, i32 }
          cleanup
  %1425 = extractvalue { i8*, i32 } %1424, 0
  %1426 = extractvalue { i8*, i32 } %1424, 1
  %_M_p.i.i.i.i1730 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 0, i32 0
  %1427 = load i8*, i8** %_M_p.i.i.i.i1730, align 8, !tbaa !51
  %1428 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 2
  %arraydecay.i.i.i.i1731 = bitcast %union.anon* %1428 to i8*
  %cmp.i.i.i1732 = icmp eq i8* %1427, %arraydecay.i.i.i.i1731
  br i1 %cmp.i.i.i1732, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1738, label %if.then.i.i1736

if.then.i.i1736:                                  ; preds = %lpad621
  %_M_allocated_capacity.i.i1733 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 2, i32 0
  %1429 = load i64, i64* %_M_allocated_capacity.i.i1733, align 8, !tbaa !27
  %1430 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp616 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1734 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp616, i64 0, i32 0, i32 0
  %1431 = load i8*, i8** %_M_p.i.i1.i.i1734, align 8, !tbaa !51
  %add.i.i.i1735 = add i64 %1429, 1
  %1432 = bitcast %"class.std::allocator.0"* %1430 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1431) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1738

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1738: ; preds = %if.then.i.i1736, %lpad621
  %1433 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp616 to %"class.std::allocator.0"*
  %1434 = bitcast %"class.std::allocator.0"* %1433 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup625

ehcleanup625:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1738, %lpad.i1651
  %ehselector.slot.30 = phi i32 [ %1426, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1738 ], [ %1361, %lpad.i1651 ]
  %exn.slot.30 = phi i8* [ %1425, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1738 ], [ %1360, %lpad.i1651 ]
  %1435 = bitcast %"class.std::allocator.0"* %ref.tmp617 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1346) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1345) #19
  br label %ehcleanup900

lpad634:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1691
  %1436 = landingpad { i8*, i32 }
          cleanup
  %1437 = extractvalue { i8*, i32 } %1436, 0
  %1438 = extractvalue { i8*, i32 } %1436, 1
  %_M_p.i.i.i.i1739 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 0, i32 0
  %1439 = load i8*, i8** %_M_p.i.i.i.i1739, align 8, !tbaa !51
  %1440 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 2
  %arraydecay.i.i.i.i1740 = bitcast %union.anon* %1440 to i8*
  %cmp.i.i.i1741 = icmp eq i8* %1439, %arraydecay.i.i.i.i1740
  br i1 %cmp.i.i.i1741, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1747, label %if.then.i.i1745

if.then.i.i1745:                                  ; preds = %lpad634
  %_M_allocated_capacity.i.i1742 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 2, i32 0
  %1441 = load i64, i64* %_M_allocated_capacity.i.i1742, align 8, !tbaa !27
  %1442 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp630 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1743 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp630, i64 0, i32 0, i32 0
  %1443 = load i8*, i8** %_M_p.i.i1.i.i1743, align 8, !tbaa !51
  %add.i.i.i1744 = add i64 %1441, 1
  %1444 = bitcast %"class.std::allocator.0"* %1442 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1443) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1747

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1747: ; preds = %if.then.i.i1745, %lpad634
  %1445 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp630 to %"class.std::allocator.0"*
  %1446 = bitcast %"class.std::allocator.0"* %1445 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup638

ehcleanup638:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1747, %lpad.i1689
  %ehselector.slot.31 = phi i32 [ %1438, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1747 ], [ %1391, %lpad.i1689 ]
  %exn.slot.31 = phi i8* [ %1437, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1747 ], [ %1390, %lpad.i1689 ]
  %1447 = bitcast %"class.std::allocator.0"* %ref.tmp631 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1376) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1375) #19
  br label %ehcleanup900

lpad649:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729
  %1448 = landingpad { i8*, i32 }
          cleanup
  %1449 = extractvalue { i8*, i32 } %1448, 0
  %1450 = extractvalue { i8*, i32 } %1448, 1
  %_M_p.i.i.i.i1760 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 0, i32 0
  %1451 = load i8*, i8** %_M_p.i.i.i.i1760, align 8, !tbaa !51
  %1452 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 2
  %arraydecay.i.i.i.i1761 = bitcast %union.anon* %1452 to i8*
  %cmp.i.i.i1762 = icmp eq i8* %1451, %arraydecay.i.i.i.i1761
  br i1 %cmp.i.i.i1762, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1768, label %if.then.i.i1766

if.then.i.i1766:                                  ; preds = %lpad649
  %_M_allocated_capacity.i.i1763 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 2, i32 0
  %1453 = load i64, i64* %_M_allocated_capacity.i.i1763, align 8, !tbaa !27
  %1454 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp645 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1764 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp645, i64 0, i32 0, i32 0
  %1455 = load i8*, i8** %_M_p.i.i1.i.i1764, align 8, !tbaa !51
  %add.i.i.i1765 = add i64 %1453, 1
  %1456 = bitcast %"class.std::allocator.0"* %1454 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1455) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1768

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1768: ; preds = %if.then.i.i1766, %lpad649
  %1457 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp645 to %"class.std::allocator.0"*
  %1458 = bitcast %"class.std::allocator.0"* %1457 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup653

ehcleanup653:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1768, %lpad.i1727
  %ehselector.slot.32 = phi i32 [ %1450, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1768 ], [ %1420, %lpad.i1727 ]
  %exn.slot.32 = phi i8* [ %1449, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1768 ], [ %1419, %lpad.i1727 ]
  %1459 = bitcast %"class.std::allocator.0"* %ref.tmp646 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1405) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1404) #19
  br label %ehcleanup900

if.else656:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1700
  %call658 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont657 unwind label %lpad548

invoke.cont657:                                   ; preds = %if.else656
  %1460 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp659 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1460) #19
  %1461 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp660, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1461) #19
  %1462 = bitcast %"class.std::allocator.0"* %ref.tmp660 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1793 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 0
  %1463 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 2
  %arraydecay.i.i1794 = bitcast %union.anon* %1463 to i8*
  %1464 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1793 to %"class.std::allocator.0"*
  %1465 = bitcast %"class.std::allocator.0"* %1464 to %"class.__gnu_cxx::new_allocator.1"*
  %1466 = bitcast %"class.std::allocator.0"* %ref.tmp660 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1795 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1793, i64 0, i32 0
  store i8* %arraydecay.i.i1794, i8** %_M_p.i.i1795, align 8, !tbaa !48
  %call.i.i1796 = call i64 @strlen(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0)) #19
  %add.ptr.i1797 = getelementptr inbounds i8, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0), i64 %call.i.i1796
  %cmp.i.i.i.i1798 = icmp eq i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0), %add.ptr.i1797
  %1467 = bitcast i64* %__dnew.i.i.i.i1792 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1467) #19
  %1468 = bitcast i8** %__first.addr.i.i.i.i.i1790 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1468)
  store i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1790, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1799 = ptrtoint i8* %add.ptr.i1797 to i64
  %sub.ptr.sub.i.i.i.i.i.i1800 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1799, ptrtoint ([11 x i8]* @.str.71 to i64)
  %1469 = bitcast i8** %__first.addr.i.i.i.i.i1790 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1469)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1800, i64* %__dnew.i.i.i.i1792, align 8, !tbaa !50
  %cmp3.i.i.i.i1801 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1800, 15
  br i1 %cmp3.i.i.i.i1801, label %if.then4.i.i.i.i1803, label %if.end6.i.i.i.i1810

if.then4.i.i.i.i1803:                             ; preds = %invoke.cont657
  %call5.i.i.i1.i1802 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp659, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1792, i64 0)
          to label %call5.i.i.i.noexc.i1806 unwind label %lpad.i1816

call5.i.i.i.noexc.i1806:                          ; preds = %if.then4.i.i.i.i1803
  %_M_p.i1.i.i.i.i1804 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1802, i8** %_M_p.i1.i.i.i.i1804, align 8, !tbaa !51
  %1470 = load i64, i64* %__dnew.i.i.i.i1792, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1805 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 2, i32 0
  store i64 %1470, i64* %_M_allocated_capacity.i.i.i.i.i1805, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1810

if.end6.i.i.i.i1810:                              ; preds = %call5.i.i.i.noexc.i1806, %invoke.cont657
  %_M_p.i.i.i.i.i1807 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 0, i32 0
  %1471 = load i8*, i8** %_M_p.i.i.i.i.i1807, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1808 = ptrtoint i8* %add.ptr.i1797 to i64
  %sub.ptr.sub.i.i.i.i.i1809 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1808, ptrtoint ([11 x i8]* @.str.71 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1809, label %if.end.i.i.i.i.i.i.i1812 [
    i64 1, label %if.then.i.i.i.i.i.i1811
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1818
  ]

if.then.i.i.i.i.i.i1811:                          ; preds = %if.end6.i.i.i.i1810
  store i8 68, i8* %1471, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1818

if.end.i.i.i.i.i.i.i1812:                         ; preds = %if.end6.i.i.i.i1810
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1471, i8* align 1 getelementptr inbounds ([11 x i8], [11 x i8]* @.str.71, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1809, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1818

lpad.i1816:                                       ; preds = %if.then4.i.i.i.i1803
  %1472 = landingpad { i8*, i32 }
          cleanup
  %1473 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp659 to %"class.std::allocator.0"*
  %1474 = bitcast %"class.std::allocator.0"* %1473 to %"class.__gnu_cxx::new_allocator.1"*
  %1475 = extractvalue { i8*, i32 } %1472, 0
  %1476 = extractvalue { i8*, i32 } %1472, 1
  br label %ehcleanup675

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1818: ; preds = %if.end.i.i.i.i.i.i.i1812, %if.then.i.i.i.i.i.i1811, %if.end6.i.i.i.i1810
  %1477 = load i64, i64* %__dnew.i.i.i.i1792, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1813 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 1
  store i64 %1477, i64* %_M_string_length.i.i.i.i.i.i1813, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1814 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 0, i32 0
  %1478 = load i8*, i8** %_M_p.i.i.i.i.i.i1814, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1815 = getelementptr inbounds i8, i8* %1478, i64 %1477
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1791) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1791, align 1, !tbaa !27
  %1479 = load i8, i8* %ref.tmp.i.i.i.i.i1791, align 1, !tbaa !27
  store i8 %1479, i8* %arrayidx.i.i.i.i.i1815, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1791) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1467) #19
  %1480 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp663 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1480) #19
  %1481 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp664, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1481) #19
  %1482 = bitcast %"class.std::allocator.0"* %ref.tmp664 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1822 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 0
  %1483 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 2
  %arraydecay.i.i1823 = bitcast %union.anon* %1483 to i8*
  %1484 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1822 to %"class.std::allocator.0"*
  %1485 = bitcast %"class.std::allocator.0"* %1484 to %"class.__gnu_cxx::new_allocator.1"*
  %1486 = bitcast %"class.std::allocator.0"* %ref.tmp664 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1824 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1822, i64 0, i32 0
  store i8* %arraydecay.i.i1823, i8** %_M_p.i.i1824, align 8, !tbaa !48
  %call.i.i1825 = call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0)) #19
  %add.ptr.i1826 = getelementptr inbounds i8, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i64 %call.i.i1825
  %cmp.i.i.i.i1827 = icmp eq i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), %add.ptr.i1826
  %1487 = bitcast i64* %__dnew.i.i.i.i1821 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1487) #19
  %1488 = bitcast i8** %__first.addr.i.i.i.i.i1819 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1488)
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1819, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1828 = ptrtoint i8* %add.ptr.i1826 to i64
  %sub.ptr.sub.i.i.i.i.i.i1829 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1828, ptrtoint ([4 x i8]* @.str.68 to i64)
  %1489 = bitcast i8** %__first.addr.i.i.i.i.i1819 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1489)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1829, i64* %__dnew.i.i.i.i1821, align 8, !tbaa !50
  %cmp3.i.i.i.i1830 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1829, 15
  br i1 %cmp3.i.i.i.i1830, label %if.then4.i.i.i.i1832, label %if.end6.i.i.i.i1839

if.then4.i.i.i.i1832:                             ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1818
  %call5.i.i.i1.i1831 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp663, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1821, i64 0)
          to label %call5.i.i.i.noexc.i1835 unwind label %lpad.i1845

call5.i.i.i.noexc.i1835:                          ; preds = %if.then4.i.i.i.i1832
  %_M_p.i1.i.i.i.i1833 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1831, i8** %_M_p.i1.i.i.i.i1833, align 8, !tbaa !51
  %1490 = load i64, i64* %__dnew.i.i.i.i1821, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1834 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 2, i32 0
  store i64 %1490, i64* %_M_allocated_capacity.i.i.i.i.i1834, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1839

if.end6.i.i.i.i1839:                              ; preds = %call5.i.i.i.noexc.i1835, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1818
  %_M_p.i.i.i.i.i1836 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 0, i32 0
  %1491 = load i8*, i8** %_M_p.i.i.i.i.i1836, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1837 = ptrtoint i8* %add.ptr.i1826 to i64
  %sub.ptr.sub.i.i.i.i.i1838 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1837, ptrtoint ([4 x i8]* @.str.68 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1838, label %if.end.i.i.i.i.i.i.i1841 [
    i64 1, label %if.then.i.i.i.i.i.i1840
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1847
  ]

if.then.i.i.i.i.i.i1840:                          ; preds = %if.end6.i.i.i.i1839
  store i8 105, i8* %1491, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1847

if.end.i.i.i.i.i.i.i1841:                         ; preds = %if.end6.i.i.i.i1839
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1491, i8* align 1 getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1838, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1847

lpad.i1845:                                       ; preds = %if.then4.i.i.i.i1832
  %1492 = landingpad { i8*, i32 }
          cleanup
  %1493 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp663 to %"class.std::allocator.0"*
  %1494 = bitcast %"class.std::allocator.0"* %1493 to %"class.__gnu_cxx::new_allocator.1"*
  %1495 = extractvalue { i8*, i32 } %1492, 0
  %1496 = extractvalue { i8*, i32 } %1492, 1
  br label %ehcleanup671

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1847: ; preds = %if.end.i.i.i.i.i.i.i1841, %if.then.i.i.i.i.i.i1840, %if.end6.i.i.i.i1839
  %1497 = load i64, i64* %__dnew.i.i.i.i1821, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1842 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 1
  store i64 %1497, i64* %_M_string_length.i.i.i.i.i.i1842, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1843 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 0, i32 0
  %1498 = load i8*, i8** %_M_p.i.i.i.i.i.i1843, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1844 = getelementptr inbounds i8, i8* %1498, i64 %1497
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1820) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1820, align 1, !tbaa !27
  %1499 = load i8, i8* %ref.tmp.i.i.i.i.i1820, align 1, !tbaa !27
  store i8 %1499, i8* %arrayidx.i.i.i.i.i1844, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1820) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1487) #19
  %call669 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* %call658, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp659, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp663)
          to label %invoke.cont668 unwind label %lpad667

invoke.cont668:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1847
  %_M_p.i.i.i.i1848 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 0, i32 0
  %1500 = load i8*, i8** %_M_p.i.i.i.i1848, align 8, !tbaa !51
  %1501 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 2
  %arraydecay.i.i.i.i1849 = bitcast %union.anon* %1501 to i8*
  %cmp.i.i.i1850 = icmp eq i8* %1500, %arraydecay.i.i.i.i1849
  br i1 %cmp.i.i.i1850, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1856, label %if.then.i.i1854

if.then.i.i1854:                                  ; preds = %invoke.cont668
  %_M_allocated_capacity.i.i1851 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 2, i32 0
  %1502 = load i64, i64* %_M_allocated_capacity.i.i1851, align 8, !tbaa !27
  %1503 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp663 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1852 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 0, i32 0
  %1504 = load i8*, i8** %_M_p.i.i1.i.i1852, align 8, !tbaa !51
  %add.i.i.i1853 = add i64 %1502, 1
  %1505 = bitcast %"class.std::allocator.0"* %1503 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1504) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1856

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1856: ; preds = %if.then.i.i1854, %invoke.cont668
  %1506 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp663 to %"class.std::allocator.0"*
  %1507 = bitcast %"class.std::allocator.0"* %1506 to %"class.__gnu_cxx::new_allocator.1"*
  %1508 = bitcast %"class.std::allocator.0"* %ref.tmp664 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1481) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1480) #19
  br label %if.end678

lpad667:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1847
  %1509 = landingpad { i8*, i32 }
          cleanup
  %1510 = extractvalue { i8*, i32 } %1509, 0
  %1511 = extractvalue { i8*, i32 } %1509, 1
  %_M_p.i.i.i.i1857 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 0, i32 0
  %1512 = load i8*, i8** %_M_p.i.i.i.i1857, align 8, !tbaa !51
  %1513 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 2
  %arraydecay.i.i.i.i1858 = bitcast %union.anon* %1513 to i8*
  %cmp.i.i.i1859 = icmp eq i8* %1512, %arraydecay.i.i.i.i1858
  br i1 %cmp.i.i.i1859, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1865, label %if.then.i.i1863

if.then.i.i1863:                                  ; preds = %lpad667
  %_M_allocated_capacity.i.i1860 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 2, i32 0
  %1514 = load i64, i64* %_M_allocated_capacity.i.i1860, align 8, !tbaa !27
  %1515 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp663 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1861 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp663, i64 0, i32 0, i32 0
  %1516 = load i8*, i8** %_M_p.i.i1.i.i1861, align 8, !tbaa !51
  %add.i.i.i1862 = add i64 %1514, 1
  %1517 = bitcast %"class.std::allocator.0"* %1515 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1516) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1865

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1865: ; preds = %if.then.i.i1863, %lpad667
  %1518 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp663 to %"class.std::allocator.0"*
  %1519 = bitcast %"class.std::allocator.0"* %1518 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup671

ehcleanup671:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1865, %lpad.i1845
  %ehselector.slot.33 = phi i32 [ %1511, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1865 ], [ %1496, %lpad.i1845 ]
  %exn.slot.33 = phi i8* [ %1510, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1865 ], [ %1495, %lpad.i1845 ]
  %1520 = bitcast %"class.std::allocator.0"* %ref.tmp664 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1481) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1480) #19
  %_M_p.i.i.i.i1875 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 0, i32 0
  %1521 = load i8*, i8** %_M_p.i.i.i.i1875, align 8, !tbaa !51
  %1522 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 2
  %arraydecay.i.i.i.i1876 = bitcast %union.anon* %1522 to i8*
  %cmp.i.i.i1877 = icmp eq i8* %1521, %arraydecay.i.i.i.i1876
  br i1 %cmp.i.i.i1877, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1883, label %if.then.i.i1881

if.then.i.i1881:                                  ; preds = %ehcleanup671
  %_M_allocated_capacity.i.i1878 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 2, i32 0
  %1523 = load i64, i64* %_M_allocated_capacity.i.i1878, align 8, !tbaa !27
  %1524 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp659 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1879 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659, i64 0, i32 0, i32 0
  %1525 = load i8*, i8** %_M_p.i.i1.i.i1879, align 8, !tbaa !51
  %add.i.i.i1880 = add i64 %1523, 1
  %1526 = bitcast %"class.std::allocator.0"* %1524 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1525) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1883

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1883: ; preds = %if.then.i.i1881, %ehcleanup671
  %1527 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp659 to %"class.std::allocator.0"*
  %1528 = bitcast %"class.std::allocator.0"* %1527 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup675

ehcleanup675:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1883, %lpad.i1816
  %ehselector.slot.34 = phi i32 [ %ehselector.slot.33, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1883 ], [ %1476, %lpad.i1816 ]
  %exn.slot.34 = phi i8* [ %exn.slot.33, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1883 ], [ %1475, %lpad.i1816 ]
  %1529 = bitcast %"class.std::allocator.0"* %ref.tmp660 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1461) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1460) #19
  br label %ehcleanup900

if.end678:                                        ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1856, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729
  %ref.tmp659.sink = phi %"class.std::__cxx11::basic_string"* [ %ref.tmp659, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1856 ], [ %ref.tmp645, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729 ]
  %ref.tmp660.sink = phi %"class.std::allocator.0"* [ %ref.tmp660, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1856 ], [ %ref.tmp646, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729 ]
  %.sink1091 = phi i8* [ %1461, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1856 ], [ %1405, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729 ]
  %.sink1090 = phi i8* [ %1460, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1856 ], [ %1404, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1729 ]
  %_M_p.i.i.i.i1893 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659.sink, i64 0, i32 0, i32 0
  %1530 = load i8*, i8** %_M_p.i.i.i.i1893, align 8, !tbaa !51
  %1531 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659.sink, i64 0, i32 2
  %arraydecay.i.i.i.i1894 = bitcast %union.anon* %1531 to i8*
  %cmp.i.i.i1895 = icmp eq i8* %1530, %arraydecay.i.i.i.i1894
  br i1 %cmp.i.i.i1895, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1901, label %if.then.i.i1899

if.then.i.i1899:                                  ; preds = %if.end678
  %_M_allocated_capacity.i.i1896 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659.sink, i64 0, i32 2, i32 0
  %1532 = load i64, i64* %_M_allocated_capacity.i.i1896, align 8, !tbaa !27
  %1533 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp659.sink to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1897 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp659.sink, i64 0, i32 0, i32 0
  %1534 = load i8*, i8** %_M_p.i.i1.i.i1897, align 8, !tbaa !51
  %add.i.i.i1898 = add i64 %1532, 1
  %1535 = bitcast %"class.std::allocator.0"* %1533 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1534) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1901

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1901: ; preds = %if.then.i.i1899, %if.end678
  %1536 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp659.sink to %"class.std::allocator.0"*
  %1537 = bitcast %"class.std::allocator.0"* %1536 to %"class.__gnu_cxx::new_allocator.1"*
  %1538 = bitcast %"class.std::allocator.0"* %ref.tmp660.sink to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %.sink1091) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.sink1090) #19
  %call680 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont679 unwind label %lpad548

invoke.cont679:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1901
  %1539 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp681 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1539) #19
  %1540 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp682, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1540) #19
  %1541 = bitcast %"class.std::allocator.0"* %ref.tmp682 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1934 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 0
  %1542 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 2
  %arraydecay.i.i1935 = bitcast %union.anon* %1542 to i8*
  %1543 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1934 to %"class.std::allocator.0"*
  %1544 = bitcast %"class.std::allocator.0"* %1543 to %"class.__gnu_cxx::new_allocator.1"*
  %1545 = bitcast %"class.std::allocator.0"* %ref.tmp682 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1936 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1934, i64 0, i32 0
  store i8* %arraydecay.i.i1935, i8** %_M_p.i.i1936, align 8, !tbaa !48
  %call.i.i1937 = call i64 @strlen(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.72, i64 0, i64 0)) #19
  %add.ptr.i1938 = getelementptr inbounds i8, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.72, i64 0, i64 0), i64 %call.i.i1937
  %cmp.i.i.i.i1939 = icmp eq i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.72, i64 0, i64 0), %add.ptr.i1938
  %1546 = bitcast i64* %__dnew.i.i.i.i1933 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1546) #19
  %1547 = bitcast i8** %__first.addr.i.i.i.i.i1931 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1547)
  store i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.72, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1931, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1940 = ptrtoint i8* %add.ptr.i1938 to i64
  %sub.ptr.sub.i.i.i.i.i.i1941 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1940, ptrtoint ([12 x i8]* @.str.72 to i64)
  %1548 = bitcast i8** %__first.addr.i.i.i.i.i1931 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1548)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1941, i64* %__dnew.i.i.i.i1933, align 8, !tbaa !50
  %cmp3.i.i.i.i1942 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1941, 15
  br i1 %cmp3.i.i.i.i1942, label %if.then4.i.i.i.i1944, label %if.end6.i.i.i.i1951

if.then4.i.i.i.i1944:                             ; preds = %invoke.cont679
  %call5.i.i.i1.i1943 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp681, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1933, i64 0)
          to label %call5.i.i.i.noexc.i1947 unwind label %lpad.i1957

call5.i.i.i.noexc.i1947:                          ; preds = %if.then4.i.i.i.i1944
  %_M_p.i1.i.i.i.i1945 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1943, i8** %_M_p.i1.i.i.i.i1945, align 8, !tbaa !51
  %1549 = load i64, i64* %__dnew.i.i.i.i1933, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1946 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 2, i32 0
  store i64 %1549, i64* %_M_allocated_capacity.i.i.i.i.i1946, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1951

if.end6.i.i.i.i1951:                              ; preds = %call5.i.i.i.noexc.i1947, %invoke.cont679
  %_M_p.i.i.i.i.i1948 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 0, i32 0
  %1550 = load i8*, i8** %_M_p.i.i.i.i.i1948, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1949 = ptrtoint i8* %add.ptr.i1938 to i64
  %sub.ptr.sub.i.i.i.i.i1950 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1949, ptrtoint ([12 x i8]* @.str.72 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1950, label %if.end.i.i.i.i.i.i.i1953 [
    i64 1, label %if.then.i.i.i.i.i.i1952
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1959
  ]

if.then.i.i.i.i.i.i1952:                          ; preds = %if.end6.i.i.i.i1951
  store i8 77, i8* %1550, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1959

if.end.i.i.i.i.i.i.i1953:                         ; preds = %if.end6.i.i.i.i1951
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1550, i8* align 1 getelementptr inbounds ([12 x i8], [12 x i8]* @.str.72, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1950, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1959

lpad.i1957:                                       ; preds = %if.then4.i.i.i.i1944
  %1551 = landingpad { i8*, i32 }
          cleanup
  %1552 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp681 to %"class.std::allocator.0"*
  %1553 = bitcast %"class.std::allocator.0"* %1552 to %"class.__gnu_cxx::new_allocator.1"*
  %1554 = extractvalue { i8*, i32 } %1551, 0
  %1555 = extractvalue { i8*, i32 } %1551, 1
  br label %ehcleanup690

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1959: ; preds = %if.end.i.i.i.i.i.i.i1953, %if.then.i.i.i.i.i.i1952, %if.end6.i.i.i.i1951
  %1556 = load i64, i64* %__dnew.i.i.i.i1933, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1954 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 1
  store i64 %1556, i64* %_M_string_length.i.i.i.i.i.i1954, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1955 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 0, i32 0
  %1557 = load i8*, i8** %_M_p.i.i.i.i.i.i1955, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1956 = getelementptr inbounds i8, i8* %1557, i64 %1556
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1932) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1932, align 1, !tbaa !27
  %1558 = load i8, i8* %ref.tmp.i.i.i.i.i1932, align 1, !tbaa !27
  store i8 %1558, i8* %arrayidx.i.i.i.i.i1956, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1932) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1546) #19
  %1559 = load double, double* %arrayidx521, align 16, !tbaa !42
  %call688 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call680, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp681, double %1559)
          to label %invoke.cont687 unwind label %lpad686

invoke.cont687:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1959
  %_M_p.i.i.i.i1960 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 0, i32 0
  %1560 = load i8*, i8** %_M_p.i.i.i.i1960, align 8, !tbaa !51
  %1561 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 2
  %arraydecay.i.i.i.i1961 = bitcast %union.anon* %1561 to i8*
  %cmp.i.i.i1962 = icmp eq i8* %1560, %arraydecay.i.i.i.i1961
  br i1 %cmp.i.i.i1962, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1968, label %if.then.i.i1966

if.then.i.i1966:                                  ; preds = %invoke.cont687
  %_M_allocated_capacity.i.i1963 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 2, i32 0
  %1562 = load i64, i64* %_M_allocated_capacity.i.i1963, align 8, !tbaa !27
  %1563 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp681 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1964 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 0, i32 0
  %1564 = load i8*, i8** %_M_p.i.i1.i.i1964, align 8, !tbaa !51
  %add.i.i.i1965 = add i64 %1562, 1
  %1565 = bitcast %"class.std::allocator.0"* %1563 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1564) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1968

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1968: ; preds = %if.then.i.i1966, %invoke.cont687
  %1566 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp681 to %"class.std::allocator.0"*
  %1567 = bitcast %"class.std::allocator.0"* %1566 to %"class.__gnu_cxx::new_allocator.1"*
  %1568 = bitcast %"class.std::allocator.0"* %ref.tmp682 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1540) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1539) #19
  %call694 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont693 unwind label %lpad548

invoke.cont693:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1968
  %1569 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp695 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1569) #19
  %1570 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp696, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1570) #19
  %1571 = bitcast %"class.std::allocator.0"* %ref.tmp696 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1981 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 0
  %1572 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 2
  %arraydecay.i.i1982 = bitcast %union.anon* %1572 to i8*
  %1573 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1981 to %"class.std::allocator.0"*
  %1574 = bitcast %"class.std::allocator.0"* %1573 to %"class.__gnu_cxx::new_allocator.1"*
  %1575 = bitcast %"class.std::allocator.0"* %ref.tmp696 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1983 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1981, i64 0, i32 0
  store i8* %arraydecay.i.i1982, i8** %_M_p.i.i1983, align 8, !tbaa !48
  %call.i.i1984 = call i64 @strlen(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.73, i64 0, i64 0)) #19
  %add.ptr.i1985 = getelementptr inbounds i8, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.73, i64 0, i64 0), i64 %call.i.i1984
  %cmp.i.i.i.i1986 = icmp eq i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.73, i64 0, i64 0), %add.ptr.i1985
  %1576 = bitcast i64* %__dnew.i.i.i.i1980 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1576) #19
  %1577 = bitcast i8** %__first.addr.i.i.i.i.i1978 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1577)
  store i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.73, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1978, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1987 = ptrtoint i8* %add.ptr.i1985 to i64
  %sub.ptr.sub.i.i.i.i.i.i1988 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1987, ptrtoint ([13 x i8]* @.str.73 to i64)
  %1578 = bitcast i8** %__first.addr.i.i.i.i.i1978 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1578)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1988, i64* %__dnew.i.i.i.i1980, align 8, !tbaa !50
  %cmp3.i.i.i.i1989 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1988, 15
  br i1 %cmp3.i.i.i.i1989, label %if.then4.i.i.i.i1991, label %if.end6.i.i.i.i1998

if.then4.i.i.i.i1991:                             ; preds = %invoke.cont693
  %call5.i.i.i1.i1990 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp695, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1980, i64 0)
          to label %call5.i.i.i.noexc.i1994 unwind label %lpad.i2004

call5.i.i.i.noexc.i1994:                          ; preds = %if.then4.i.i.i.i1991
  %_M_p.i1.i.i.i.i1992 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1990, i8** %_M_p.i1.i.i.i.i1992, align 8, !tbaa !51
  %1579 = load i64, i64* %__dnew.i.i.i.i1980, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1993 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 2, i32 0
  store i64 %1579, i64* %_M_allocated_capacity.i.i.i.i.i1993, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1998

if.end6.i.i.i.i1998:                              ; preds = %call5.i.i.i.noexc.i1994, %invoke.cont693
  %_M_p.i.i.i.i.i1995 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 0, i32 0
  %1580 = load i8*, i8** %_M_p.i.i.i.i.i1995, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1996 = ptrtoint i8* %add.ptr.i1985 to i64
  %sub.ptr.sub.i.i.i.i.i1997 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1996, ptrtoint ([13 x i8]* @.str.73 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1997, label %if.end.i.i.i.i.i.i.i2000 [
    i64 1, label %if.then.i.i.i.i.i.i1999
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2006
  ]

if.then.i.i.i.i.i.i1999:                          ; preds = %if.end6.i.i.i.i1998
  store i8 77, i8* %1580, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2006

if.end.i.i.i.i.i.i.i2000:                         ; preds = %if.end6.i.i.i.i1998
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1580, i8* align 1 getelementptr inbounds ([13 x i8], [13 x i8]* @.str.73, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1997, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2006

lpad.i2004:                                       ; preds = %if.then4.i.i.i.i1991
  %1581 = landingpad { i8*, i32 }
          cleanup
  %1582 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp695 to %"class.std::allocator.0"*
  %1583 = bitcast %"class.std::allocator.0"* %1582 to %"class.__gnu_cxx::new_allocator.1"*
  %1584 = extractvalue { i8*, i32 } %1581, 0
  %1585 = extractvalue { i8*, i32 } %1581, 1
  br label %ehcleanup703

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2006: ; preds = %if.end.i.i.i.i.i.i.i2000, %if.then.i.i.i.i.i.i1999, %if.end6.i.i.i.i1998
  %1586 = load i64, i64* %__dnew.i.i.i.i1980, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2001 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 1
  store i64 %1586, i64* %_M_string_length.i.i.i.i.i.i2001, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2002 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 0, i32 0
  %1587 = load i8*, i8** %_M_p.i.i.i.i.i.i2002, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2003 = getelementptr inbounds i8, i8* %1587, i64 %1586
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1979) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1979, align 1, !tbaa !27
  %1588 = load i8, i8* %ref.tmp.i.i.i.i.i1979, align 1, !tbaa !27
  store i8 %1588, i8* %arrayidx.i.i.i.i.i2003, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1979) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1576) #19
  %call701 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call694, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp695, double %mul511)
          to label %invoke.cont700 unwind label %lpad699

invoke.cont700:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2006
  %_M_p.i.i.i.i2007 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 0, i32 0
  %1589 = load i8*, i8** %_M_p.i.i.i.i2007, align 8, !tbaa !51
  %1590 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 2
  %arraydecay.i.i.i.i2008 = bitcast %union.anon* %1590 to i8*
  %cmp.i.i.i2009 = icmp eq i8* %1589, %arraydecay.i.i.i.i2008
  br i1 %cmp.i.i.i2009, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2015, label %if.then.i.i2013

if.then.i.i2013:                                  ; preds = %invoke.cont700
  %_M_allocated_capacity.i.i2010 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 2, i32 0
  %1591 = load i64, i64* %_M_allocated_capacity.i.i2010, align 8, !tbaa !27
  %1592 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp695 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2011 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 0, i32 0
  %1593 = load i8*, i8** %_M_p.i.i1.i.i2011, align 8, !tbaa !51
  %add.i.i.i2012 = add i64 %1591, 1
  %1594 = bitcast %"class.std::allocator.0"* %1592 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1593) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2015

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2015: ; preds = %if.then.i.i2013, %invoke.cont700
  %1595 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp695 to %"class.std::allocator.0"*
  %1596 = bitcast %"class.std::allocator.0"* %1595 to %"class.__gnu_cxx::new_allocator.1"*
  %1597 = bitcast %"class.std::allocator.0"* %ref.tmp696 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1570) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1569) #19
  %cmp706 = fcmp ult double %mv_mflops.0, 0.000000e+00
  br i1 %cmp706, label %if.else721, label %if.then707

if.then707:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2015
  %call709 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont708 unwind label %lpad548

invoke.cont708:                                   ; preds = %if.then707
  %1598 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp710 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1598) #19
  %1599 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp711, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1599) #19
  %1600 = bitcast %"class.std::allocator.0"* %ref.tmp711 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2028 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 0
  %1601 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 2
  %arraydecay.i.i2029 = bitcast %union.anon* %1601 to i8*
  %1602 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2028 to %"class.std::allocator.0"*
  %1603 = bitcast %"class.std::allocator.0"* %1602 to %"class.__gnu_cxx::new_allocator.1"*
  %1604 = bitcast %"class.std::allocator.0"* %ref.tmp711 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2030 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2028, i64 0, i32 0
  store i8* %arraydecay.i.i2029, i8** %_M_p.i.i2030, align 8, !tbaa !48
  %call.i.i2031 = call i64 @strlen(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0)) #19
  %add.ptr.i2032 = getelementptr inbounds i8, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0), i64 %call.i.i2031
  %cmp.i.i.i.i2033 = icmp eq i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0), %add.ptr.i2032
  %1605 = bitcast i64* %__dnew.i.i.i.i2027 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1605) #19
  %1606 = bitcast i8** %__first.addr.i.i.i.i.i2025 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1606)
  store i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2025, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2034 = ptrtoint i8* %add.ptr.i2032 to i64
  %sub.ptr.sub.i.i.i.i.i.i2035 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2034, ptrtoint ([14 x i8]* @.str.74 to i64)
  %1607 = bitcast i8** %__first.addr.i.i.i.i.i2025 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1607)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2035, i64* %__dnew.i.i.i.i2027, align 8, !tbaa !50
  %cmp3.i.i.i.i2036 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2035, 15
  br i1 %cmp3.i.i.i.i2036, label %if.then4.i.i.i.i2038, label %if.end6.i.i.i.i2045

if.then4.i.i.i.i2038:                             ; preds = %invoke.cont708
  %call5.i.i.i1.i2037 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp710, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2027, i64 0)
          to label %call5.i.i.i.noexc.i2041 unwind label %lpad.i2051

call5.i.i.i.noexc.i2041:                          ; preds = %if.then4.i.i.i.i2038
  %_M_p.i1.i.i.i.i2039 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2037, i8** %_M_p.i1.i.i.i.i2039, align 8, !tbaa !51
  %1608 = load i64, i64* %__dnew.i.i.i.i2027, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2040 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 2, i32 0
  store i64 %1608, i64* %_M_allocated_capacity.i.i.i.i.i2040, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2045

if.end6.i.i.i.i2045:                              ; preds = %call5.i.i.i.noexc.i2041, %invoke.cont708
  %_M_p.i.i.i.i.i2042 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 0, i32 0
  %1609 = load i8*, i8** %_M_p.i.i.i.i.i2042, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2043 = ptrtoint i8* %add.ptr.i2032 to i64
  %sub.ptr.sub.i.i.i.i.i2044 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2043, ptrtoint ([14 x i8]* @.str.74 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2044, label %if.end.i.i.i.i.i.i.i2047 [
    i64 1, label %if.then.i.i.i.i.i.i2046
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053
  ]

if.then.i.i.i.i.i.i2046:                          ; preds = %if.end6.i.i.i.i2045
  store i8 77, i8* %1609, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053

if.end.i.i.i.i.i.i.i2047:                         ; preds = %if.end6.i.i.i.i2045
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1609, i8* align 1 getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2044, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053

lpad.i2051:                                       ; preds = %if.then4.i.i.i.i2038
  %1610 = landingpad { i8*, i32 }
          cleanup
  %1611 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp710 to %"class.std::allocator.0"*
  %1612 = bitcast %"class.std::allocator.0"* %1611 to %"class.__gnu_cxx::new_allocator.1"*
  %1613 = extractvalue { i8*, i32 } %1610, 0
  %1614 = extractvalue { i8*, i32 } %1610, 1
  br label %ehcleanup718

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053: ; preds = %if.end.i.i.i.i.i.i.i2047, %if.then.i.i.i.i.i.i2046, %if.end6.i.i.i.i2045
  %1615 = load i64, i64* %__dnew.i.i.i.i2027, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2048 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 1
  store i64 %1615, i64* %_M_string_length.i.i.i.i.i.i2048, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2049 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 0, i32 0
  %1616 = load i8*, i8** %_M_p.i.i.i.i.i.i2049, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2050 = getelementptr inbounds i8, i8* %1616, i64 %1615
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2026) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2026, align 1, !tbaa !27
  %1617 = load i8, i8* %ref.tmp.i.i.i.i.i2026, align 1, !tbaa !27
  store i8 %1617, i8* %arrayidx.i.i.i.i.i2050, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2026) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1605) #19
  %call716 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call709, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp710, double %mv_mflops.0)
          to label %if.end743 unwind label %lpad714

lpad686:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1959
  %1618 = landingpad { i8*, i32 }
          cleanup
  %1619 = extractvalue { i8*, i32 } %1618, 0
  %1620 = extractvalue { i8*, i32 } %1618, 1
  %_M_p.i.i.i.i2054 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 0, i32 0
  %1621 = load i8*, i8** %_M_p.i.i.i.i2054, align 8, !tbaa !51
  %1622 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 2
  %arraydecay.i.i.i.i2055 = bitcast %union.anon* %1622 to i8*
  %cmp.i.i.i2056 = icmp eq i8* %1621, %arraydecay.i.i.i.i2055
  br i1 %cmp.i.i.i2056, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2062, label %if.then.i.i2060

if.then.i.i2060:                                  ; preds = %lpad686
  %_M_allocated_capacity.i.i2057 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 2, i32 0
  %1623 = load i64, i64* %_M_allocated_capacity.i.i2057, align 8, !tbaa !27
  %1624 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp681 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2058 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp681, i64 0, i32 0, i32 0
  %1625 = load i8*, i8** %_M_p.i.i1.i.i2058, align 8, !tbaa !51
  %add.i.i.i2059 = add i64 %1623, 1
  %1626 = bitcast %"class.std::allocator.0"* %1624 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1625) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2062

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2062: ; preds = %if.then.i.i2060, %lpad686
  %1627 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp681 to %"class.std::allocator.0"*
  %1628 = bitcast %"class.std::allocator.0"* %1627 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup690

ehcleanup690:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2062, %lpad.i1957
  %ehselector.slot.35 = phi i32 [ %1620, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2062 ], [ %1555, %lpad.i1957 ]
  %exn.slot.35 = phi i8* [ %1619, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2062 ], [ %1554, %lpad.i1957 ]
  %1629 = bitcast %"class.std::allocator.0"* %ref.tmp682 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1540) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1539) #19
  br label %ehcleanup900

lpad699:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2006
  %1630 = landingpad { i8*, i32 }
          cleanup
  %1631 = extractvalue { i8*, i32 } %1630, 0
  %1632 = extractvalue { i8*, i32 } %1630, 1
  %_M_p.i.i.i.i2063 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 0, i32 0
  %1633 = load i8*, i8** %_M_p.i.i.i.i2063, align 8, !tbaa !51
  %1634 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 2
  %arraydecay.i.i.i.i2064 = bitcast %union.anon* %1634 to i8*
  %cmp.i.i.i2065 = icmp eq i8* %1633, %arraydecay.i.i.i.i2064
  br i1 %cmp.i.i.i2065, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2071, label %if.then.i.i2069

if.then.i.i2069:                                  ; preds = %lpad699
  %_M_allocated_capacity.i.i2066 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 2, i32 0
  %1635 = load i64, i64* %_M_allocated_capacity.i.i2066, align 8, !tbaa !27
  %1636 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp695 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2067 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp695, i64 0, i32 0, i32 0
  %1637 = load i8*, i8** %_M_p.i.i1.i.i2067, align 8, !tbaa !51
  %add.i.i.i2068 = add i64 %1635, 1
  %1638 = bitcast %"class.std::allocator.0"* %1636 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1637) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2071

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2071: ; preds = %if.then.i.i2069, %lpad699
  %1639 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp695 to %"class.std::allocator.0"*
  %1640 = bitcast %"class.std::allocator.0"* %1639 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup703

ehcleanup703:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2071, %lpad.i2004
  %ehselector.slot.36 = phi i32 [ %1632, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2071 ], [ %1585, %lpad.i2004 ]
  %exn.slot.36 = phi i8* [ %1631, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2071 ], [ %1584, %lpad.i2004 ]
  %1641 = bitcast %"class.std::allocator.0"* %ref.tmp696 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1570) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1569) #19
  br label %ehcleanup900

lpad714:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053
  %1642 = landingpad { i8*, i32 }
          cleanup
  %1643 = extractvalue { i8*, i32 } %1642, 0
  %1644 = extractvalue { i8*, i32 } %1642, 1
  %_M_p.i.i.i.i2081 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 0, i32 0
  %1645 = load i8*, i8** %_M_p.i.i.i.i2081, align 8, !tbaa !51
  %1646 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 2
  %arraydecay.i.i.i.i2082 = bitcast %union.anon* %1646 to i8*
  %cmp.i.i.i2083 = icmp eq i8* %1645, %arraydecay.i.i.i.i2082
  br i1 %cmp.i.i.i2083, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2089, label %if.then.i.i2087

if.then.i.i2087:                                  ; preds = %lpad714
  %_M_allocated_capacity.i.i2084 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 2, i32 0
  %1647 = load i64, i64* %_M_allocated_capacity.i.i2084, align 8, !tbaa !27
  %1648 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp710 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2085 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp710, i64 0, i32 0, i32 0
  %1649 = load i8*, i8** %_M_p.i.i1.i.i2085, align 8, !tbaa !51
  %add.i.i.i2086 = add i64 %1647, 1
  %1650 = bitcast %"class.std::allocator.0"* %1648 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1649) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2089

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2089: ; preds = %if.then.i.i2087, %lpad714
  %1651 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp710 to %"class.std::allocator.0"*
  %1652 = bitcast %"class.std::allocator.0"* %1651 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup718

ehcleanup718:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2089, %lpad.i2051
  %ehselector.slot.37 = phi i32 [ %1644, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2089 ], [ %1614, %lpad.i2051 ]
  %exn.slot.37 = phi i8* [ %1643, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2089 ], [ %1613, %lpad.i2051 ]
  %1653 = bitcast %"class.std::allocator.0"* %ref.tmp711 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1599) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1598) #19
  br label %ehcleanup900

if.else721:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2015
  %call723 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont722 unwind label %lpad548

invoke.cont722:                                   ; preds = %if.else721
  %1654 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp724 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1654) #19
  %1655 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp725, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1655) #19
  %1656 = bitcast %"class.std::allocator.0"* %ref.tmp725 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2111 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 0
  %1657 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 2
  %arraydecay.i.i2112 = bitcast %union.anon* %1657 to i8*
  %1658 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2111 to %"class.std::allocator.0"*
  %1659 = bitcast %"class.std::allocator.0"* %1658 to %"class.__gnu_cxx::new_allocator.1"*
  %1660 = bitcast %"class.std::allocator.0"* %ref.tmp725 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2113 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2111, i64 0, i32 0
  store i8* %arraydecay.i.i2112, i8** %_M_p.i.i2113, align 8, !tbaa !48
  %call.i.i2114 = call i64 @strlen(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0)) #19
  %add.ptr.i2115 = getelementptr inbounds i8, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0), i64 %call.i.i2114
  %cmp.i.i.i.i2116 = icmp eq i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0), %add.ptr.i2115
  %1661 = bitcast i64* %__dnew.i.i.i.i2110 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1661) #19
  %1662 = bitcast i8** %__first.addr.i.i.i.i.i2108 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1662)
  store i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2108, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2117 = ptrtoint i8* %add.ptr.i2115 to i64
  %sub.ptr.sub.i.i.i.i.i.i2118 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2117, ptrtoint ([14 x i8]* @.str.74 to i64)
  %1663 = bitcast i8** %__first.addr.i.i.i.i.i2108 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1663)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2118, i64* %__dnew.i.i.i.i2110, align 8, !tbaa !50
  %cmp3.i.i.i.i2119 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2118, 15
  br i1 %cmp3.i.i.i.i2119, label %if.then4.i.i.i.i2121, label %if.end6.i.i.i.i2128

if.then4.i.i.i.i2121:                             ; preds = %invoke.cont722
  %call5.i.i.i1.i2120 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp724, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2110, i64 0)
          to label %call5.i.i.i.noexc.i2124 unwind label %lpad.i2134

call5.i.i.i.noexc.i2124:                          ; preds = %if.then4.i.i.i.i2121
  %_M_p.i1.i.i.i.i2122 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2120, i8** %_M_p.i1.i.i.i.i2122, align 8, !tbaa !51
  %1664 = load i64, i64* %__dnew.i.i.i.i2110, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2123 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 2, i32 0
  store i64 %1664, i64* %_M_allocated_capacity.i.i.i.i.i2123, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2128

if.end6.i.i.i.i2128:                              ; preds = %call5.i.i.i.noexc.i2124, %invoke.cont722
  %_M_p.i.i.i.i.i2125 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 0, i32 0
  %1665 = load i8*, i8** %_M_p.i.i.i.i.i2125, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2126 = ptrtoint i8* %add.ptr.i2115 to i64
  %sub.ptr.sub.i.i.i.i.i2127 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2126, ptrtoint ([14 x i8]* @.str.74 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2127, label %if.end.i.i.i.i.i.i.i2130 [
    i64 1, label %if.then.i.i.i.i.i.i2129
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2136
  ]

if.then.i.i.i.i.i.i2129:                          ; preds = %if.end6.i.i.i.i2128
  store i8 77, i8* %1665, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2136

if.end.i.i.i.i.i.i.i2130:                         ; preds = %if.end6.i.i.i.i2128
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1665, i8* align 1 getelementptr inbounds ([14 x i8], [14 x i8]* @.str.74, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2127, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2136

lpad.i2134:                                       ; preds = %if.then4.i.i.i.i2121
  %1666 = landingpad { i8*, i32 }
          cleanup
  %1667 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp724 to %"class.std::allocator.0"*
  %1668 = bitcast %"class.std::allocator.0"* %1667 to %"class.__gnu_cxx::new_allocator.1"*
  %1669 = extractvalue { i8*, i32 } %1666, 0
  %1670 = extractvalue { i8*, i32 } %1666, 1
  br label %ehcleanup740

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2136: ; preds = %if.end.i.i.i.i.i.i.i2130, %if.then.i.i.i.i.i.i2129, %if.end6.i.i.i.i2128
  %1671 = load i64, i64* %__dnew.i.i.i.i2110, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2131 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 1
  store i64 %1671, i64* %_M_string_length.i.i.i.i.i.i2131, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2132 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 0, i32 0
  %1672 = load i8*, i8** %_M_p.i.i.i.i.i.i2132, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2133 = getelementptr inbounds i8, i8* %1672, i64 %1671
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2109) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2109, align 1, !tbaa !27
  %1673 = load i8, i8* %ref.tmp.i.i.i.i.i2109, align 1, !tbaa !27
  store i8 %1673, i8* %arrayidx.i.i.i.i.i2133, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2109) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1661) #19
  %1674 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp728 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1674) #19
  %1675 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp729, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1675) #19
  %1676 = bitcast %"class.std::allocator.0"* %ref.tmp729 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2140 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 0
  %1677 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 2
  %arraydecay.i.i2141 = bitcast %union.anon* %1677 to i8*
  %1678 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2140 to %"class.std::allocator.0"*
  %1679 = bitcast %"class.std::allocator.0"* %1678 to %"class.__gnu_cxx::new_allocator.1"*
  %1680 = bitcast %"class.std::allocator.0"* %ref.tmp729 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2142 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2140, i64 0, i32 0
  store i8* %arraydecay.i.i2141, i8** %_M_p.i.i2142, align 8, !tbaa !48
  %call.i.i2143 = call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0)) #19
  %add.ptr.i2144 = getelementptr inbounds i8, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i64 %call.i.i2143
  %cmp.i.i.i.i2145 = icmp eq i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), %add.ptr.i2144
  %1681 = bitcast i64* %__dnew.i.i.i.i2139 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1681) #19
  %1682 = bitcast i8** %__first.addr.i.i.i.i.i2137 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1682)
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2137, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2146 = ptrtoint i8* %add.ptr.i2144 to i64
  %sub.ptr.sub.i.i.i.i.i.i2147 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2146, ptrtoint ([4 x i8]* @.str.68 to i64)
  %1683 = bitcast i8** %__first.addr.i.i.i.i.i2137 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1683)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2147, i64* %__dnew.i.i.i.i2139, align 8, !tbaa !50
  %cmp3.i.i.i.i2148 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2147, 15
  br i1 %cmp3.i.i.i.i2148, label %if.then4.i.i.i.i2150, label %if.end6.i.i.i.i2157

if.then4.i.i.i.i2150:                             ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2136
  %call5.i.i.i1.i2149 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp728, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2139, i64 0)
          to label %call5.i.i.i.noexc.i2153 unwind label %lpad.i2163

call5.i.i.i.noexc.i2153:                          ; preds = %if.then4.i.i.i.i2150
  %_M_p.i1.i.i.i.i2151 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2149, i8** %_M_p.i1.i.i.i.i2151, align 8, !tbaa !51
  %1684 = load i64, i64* %__dnew.i.i.i.i2139, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2152 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 2, i32 0
  store i64 %1684, i64* %_M_allocated_capacity.i.i.i.i.i2152, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2157

if.end6.i.i.i.i2157:                              ; preds = %call5.i.i.i.noexc.i2153, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2136
  %_M_p.i.i.i.i.i2154 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 0, i32 0
  %1685 = load i8*, i8** %_M_p.i.i.i.i.i2154, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2155 = ptrtoint i8* %add.ptr.i2144 to i64
  %sub.ptr.sub.i.i.i.i.i2156 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2155, ptrtoint ([4 x i8]* @.str.68 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2156, label %if.end.i.i.i.i.i.i.i2159 [
    i64 1, label %if.then.i.i.i.i.i.i2158
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2165
  ]

if.then.i.i.i.i.i.i2158:                          ; preds = %if.end6.i.i.i.i2157
  store i8 105, i8* %1685, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2165

if.end.i.i.i.i.i.i.i2159:                         ; preds = %if.end6.i.i.i.i2157
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1685, i8* align 1 getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2156, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2165

lpad.i2163:                                       ; preds = %if.then4.i.i.i.i2150
  %1686 = landingpad { i8*, i32 }
          cleanup
  %1687 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp728 to %"class.std::allocator.0"*
  %1688 = bitcast %"class.std::allocator.0"* %1687 to %"class.__gnu_cxx::new_allocator.1"*
  %1689 = extractvalue { i8*, i32 } %1686, 0
  %1690 = extractvalue { i8*, i32 } %1686, 1
  br label %ehcleanup736

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2165: ; preds = %if.end.i.i.i.i.i.i.i2159, %if.then.i.i.i.i.i.i2158, %if.end6.i.i.i.i2157
  %1691 = load i64, i64* %__dnew.i.i.i.i2139, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2160 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 1
  store i64 %1691, i64* %_M_string_length.i.i.i.i.i.i2160, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2161 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 0, i32 0
  %1692 = load i8*, i8** %_M_p.i.i.i.i.i.i2161, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2162 = getelementptr inbounds i8, i8* %1692, i64 %1691
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2138) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2138, align 1, !tbaa !27
  %1693 = load i8, i8* %ref.tmp.i.i.i.i.i2138, align 1, !tbaa !27
  store i8 %1693, i8* %arrayidx.i.i.i.i.i2162, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2138) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1681) #19
  %call734 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* %call723, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp724, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp728)
          to label %invoke.cont733 unwind label %lpad732

invoke.cont733:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2165
  %_M_p.i.i.i.i2166 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 0, i32 0
  %1694 = load i8*, i8** %_M_p.i.i.i.i2166, align 8, !tbaa !51
  %1695 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 2
  %arraydecay.i.i.i.i2167 = bitcast %union.anon* %1695 to i8*
  %cmp.i.i.i2168 = icmp eq i8* %1694, %arraydecay.i.i.i.i2167
  br i1 %cmp.i.i.i2168, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2174, label %if.then.i.i2172

if.then.i.i2172:                                  ; preds = %invoke.cont733
  %_M_allocated_capacity.i.i2169 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 2, i32 0
  %1696 = load i64, i64* %_M_allocated_capacity.i.i2169, align 8, !tbaa !27
  %1697 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp728 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2170 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 0, i32 0
  %1698 = load i8*, i8** %_M_p.i.i1.i.i2170, align 8, !tbaa !51
  %add.i.i.i2171 = add i64 %1696, 1
  %1699 = bitcast %"class.std::allocator.0"* %1697 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1698) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2174

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2174: ; preds = %if.then.i.i2172, %invoke.cont733
  %1700 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp728 to %"class.std::allocator.0"*
  %1701 = bitcast %"class.std::allocator.0"* %1700 to %"class.__gnu_cxx::new_allocator.1"*
  %1702 = bitcast %"class.std::allocator.0"* %ref.tmp729 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1675) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1674) #19
  br label %if.end743

lpad732:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2165
  %1703 = landingpad { i8*, i32 }
          cleanup
  %1704 = extractvalue { i8*, i32 } %1703, 0
  %1705 = extractvalue { i8*, i32 } %1703, 1
  %_M_p.i.i.i.i2175 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 0, i32 0
  %1706 = load i8*, i8** %_M_p.i.i.i.i2175, align 8, !tbaa !51
  %1707 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 2
  %arraydecay.i.i.i.i2176 = bitcast %union.anon* %1707 to i8*
  %cmp.i.i.i2177 = icmp eq i8* %1706, %arraydecay.i.i.i.i2176
  br i1 %cmp.i.i.i2177, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2183, label %if.then.i.i2181

if.then.i.i2181:                                  ; preds = %lpad732
  %_M_allocated_capacity.i.i2178 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 2, i32 0
  %1708 = load i64, i64* %_M_allocated_capacity.i.i2178, align 8, !tbaa !27
  %1709 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp728 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2179 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp728, i64 0, i32 0, i32 0
  %1710 = load i8*, i8** %_M_p.i.i1.i.i2179, align 8, !tbaa !51
  %add.i.i.i2180 = add i64 %1708, 1
  %1711 = bitcast %"class.std::allocator.0"* %1709 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1710) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2183

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2183: ; preds = %if.then.i.i2181, %lpad732
  %1712 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp728 to %"class.std::allocator.0"*
  %1713 = bitcast %"class.std::allocator.0"* %1712 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup736

ehcleanup736:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2183, %lpad.i2163
  %ehselector.slot.38 = phi i32 [ %1705, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2183 ], [ %1690, %lpad.i2163 ]
  %exn.slot.38 = phi i8* [ %1704, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2183 ], [ %1689, %lpad.i2163 ]
  %1714 = bitcast %"class.std::allocator.0"* %ref.tmp729 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1675) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1674) #19
  %_M_p.i.i.i.i2193 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 0, i32 0
  %1715 = load i8*, i8** %_M_p.i.i.i.i2193, align 8, !tbaa !51
  %1716 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 2
  %arraydecay.i.i.i.i2194 = bitcast %union.anon* %1716 to i8*
  %cmp.i.i.i2195 = icmp eq i8* %1715, %arraydecay.i.i.i.i2194
  br i1 %cmp.i.i.i2195, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2201, label %if.then.i.i2199

if.then.i.i2199:                                  ; preds = %ehcleanup736
  %_M_allocated_capacity.i.i2196 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 2, i32 0
  %1717 = load i64, i64* %_M_allocated_capacity.i.i2196, align 8, !tbaa !27
  %1718 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp724 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2197 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724, i64 0, i32 0, i32 0
  %1719 = load i8*, i8** %_M_p.i.i1.i.i2197, align 8, !tbaa !51
  %add.i.i.i2198 = add i64 %1717, 1
  %1720 = bitcast %"class.std::allocator.0"* %1718 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1719) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2201

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2201: ; preds = %if.then.i.i2199, %ehcleanup736
  %1721 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp724 to %"class.std::allocator.0"*
  %1722 = bitcast %"class.std::allocator.0"* %1721 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup740

ehcleanup740:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2201, %lpad.i2134
  %ehselector.slot.39 = phi i32 [ %ehselector.slot.38, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2201 ], [ %1670, %lpad.i2134 ]
  %exn.slot.39 = phi i8* [ %exn.slot.38, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2201 ], [ %1669, %lpad.i2134 ]
  %1723 = bitcast %"class.std::allocator.0"* %ref.tmp725 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1655) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1654) #19
  br label %ehcleanup900

if.end743:                                        ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2174, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053
  %ref.tmp724.sink = phi %"class.std::__cxx11::basic_string"* [ %ref.tmp724, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2174 ], [ %ref.tmp710, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053 ]
  %ref.tmp725.sink = phi %"class.std::allocator.0"* [ %ref.tmp725, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2174 ], [ %ref.tmp711, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053 ]
  %.sink1093 = phi i8* [ %1655, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2174 ], [ %1599, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053 ]
  %.sink1092 = phi i8* [ %1654, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2174 ], [ %1598, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2053 ]
  %_M_p.i.i.i.i2231 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724.sink, i64 0, i32 0, i32 0
  %1724 = load i8*, i8** %_M_p.i.i.i.i2231, align 8, !tbaa !51
  %1725 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724.sink, i64 0, i32 2
  %arraydecay.i.i.i.i2232 = bitcast %union.anon* %1725 to i8*
  %cmp.i.i.i2233 = icmp eq i8* %1724, %arraydecay.i.i.i.i2232
  br i1 %cmp.i.i.i2233, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2239, label %if.then.i.i2237

if.then.i.i2237:                                  ; preds = %if.end743
  %_M_allocated_capacity.i.i2234 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724.sink, i64 0, i32 2, i32 0
  %1726 = load i64, i64* %_M_allocated_capacity.i.i2234, align 8, !tbaa !27
  %1727 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp724.sink to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2235 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp724.sink, i64 0, i32 0, i32 0
  %1728 = load i8*, i8** %_M_p.i.i1.i.i2235, align 8, !tbaa !51
  %add.i.i.i2236 = add i64 %1726, 1
  %1729 = bitcast %"class.std::allocator.0"* %1727 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1728) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2239

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2239: ; preds = %if.then.i.i2237, %if.end743
  %1730 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp724.sink to %"class.std::allocator.0"*
  %1731 = bitcast %"class.std::allocator.0"* %1730 to %"class.__gnu_cxx::new_allocator.1"*
  %1732 = bitcast %"class.std::allocator.0"* %ref.tmp725.sink to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %.sink1093) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.sink1092) #19
  %call745 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont744 unwind label %lpad548

invoke.cont744:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2239
  %1733 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp746 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1733) #19
  %1734 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp747, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1734) #19
  %1735 = bitcast %"class.std::allocator.0"* %ref.tmp747 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2272 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 0
  %1736 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 2
  %arraydecay.i.i2273 = bitcast %union.anon* %1736 to i8*
  %1737 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2272 to %"class.std::allocator.0"*
  %1738 = bitcast %"class.std::allocator.0"* %1737 to %"class.__gnu_cxx::new_allocator.1"*
  %1739 = bitcast %"class.std::allocator.0"* %ref.tmp747 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2274 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2272, i64 0, i32 0
  store i8* %arraydecay.i.i2273, i8** %_M_p.i.i2274, align 8, !tbaa !48
  %call.i.i2275 = call i64 @strlen(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0)) #19
  %add.ptr.i2276 = getelementptr inbounds i8, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %call.i.i2275
  %cmp.i.i.i.i2277 = icmp eq i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), %add.ptr.i2276
  %1740 = bitcast i64* %__dnew.i.i.i.i2271 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1740) #19
  %1741 = bitcast i8** %__first.addr.i.i.i.i.i2269 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1741)
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2269, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2278 = ptrtoint i8* %add.ptr.i2276 to i64
  %sub.ptr.sub.i.i.i.i.i.i2279 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2278, ptrtoint ([6 x i8]* @.str.75 to i64)
  %1742 = bitcast i8** %__first.addr.i.i.i.i.i2269 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1742)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2279, i64* %__dnew.i.i.i.i2271, align 8, !tbaa !50
  %cmp3.i.i.i.i2280 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2279, 15
  br i1 %cmp3.i.i.i.i2280, label %if.then4.i.i.i.i2282, label %if.end6.i.i.i.i2289

if.then4.i.i.i.i2282:                             ; preds = %invoke.cont744
  %call5.i.i.i1.i2281 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp746, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2271, i64 0)
          to label %call5.i.i.i.noexc.i2285 unwind label %lpad.i2295

call5.i.i.i.noexc.i2285:                          ; preds = %if.then4.i.i.i.i2282
  %_M_p.i1.i.i.i.i2283 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2281, i8** %_M_p.i1.i.i.i.i2283, align 8, !tbaa !51
  %1743 = load i64, i64* %__dnew.i.i.i.i2271, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2284 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 2, i32 0
  store i64 %1743, i64* %_M_allocated_capacity.i.i.i.i.i2284, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2289

if.end6.i.i.i.i2289:                              ; preds = %call5.i.i.i.noexc.i2285, %invoke.cont744
  %_M_p.i.i.i.i.i2286 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 0, i32 0
  %1744 = load i8*, i8** %_M_p.i.i.i.i.i2286, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2287 = ptrtoint i8* %add.ptr.i2276 to i64
  %sub.ptr.sub.i.i.i.i.i2288 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2287, ptrtoint ([6 x i8]* @.str.75 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2288, label %if.end.i.i.i.i.i.i.i2291 [
    i64 1, label %if.then.i.i.i.i.i.i2290
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2297
  ]

if.then.i.i.i.i.i.i2290:                          ; preds = %if.end6.i.i.i.i2289
  store i8 84, i8* %1744, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2297

if.end.i.i.i.i.i.i.i2291:                         ; preds = %if.end6.i.i.i.i2289
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1744, i8* align 1 getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2288, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2297

lpad.i2295:                                       ; preds = %if.then4.i.i.i.i2282
  %1745 = landingpad { i8*, i32 }
          cleanup
  %1746 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp746 to %"class.std::allocator.0"*
  %1747 = bitcast %"class.std::allocator.0"* %1746 to %"class.__gnu_cxx::new_allocator.1"*
  %1748 = extractvalue { i8*, i32 } %1745, 0
  %1749 = extractvalue { i8*, i32 } %1745, 1
  br label %ehcleanup762

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2297: ; preds = %if.end.i.i.i.i.i.i.i2291, %if.then.i.i.i.i.i.i2290, %if.end6.i.i.i.i2289
  %1750 = load i64, i64* %__dnew.i.i.i.i2271, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2292 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 1
  store i64 %1750, i64* %_M_string_length.i.i.i.i.i.i2292, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2293 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 0, i32 0
  %1751 = load i8*, i8** %_M_p.i.i.i.i.i.i2293, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2294 = getelementptr inbounds i8, i8* %1751, i64 %1750
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2270) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2270, align 1, !tbaa !27
  %1752 = load i8, i8* %ref.tmp.i.i.i.i.i2270, align 1, !tbaa !27
  store i8 %1752, i8* %arrayidx.i.i.i.i.i2294, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2270) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1740) #19
  %1753 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp750 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1753) #19
  %1754 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp751, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1754) #19
  %1755 = bitcast %"class.std::allocator.0"* %ref.tmp751 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2301 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 0
  %1756 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 2
  %arraydecay.i.i2302 = bitcast %union.anon* %1756 to i8*
  %1757 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2301 to %"class.std::allocator.0"*
  %1758 = bitcast %"class.std::allocator.0"* %1757 to %"class.__gnu_cxx::new_allocator.1"*
  %1759 = bitcast %"class.std::allocator.0"* %ref.tmp751 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2303 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2301, i64 0, i32 0
  store i8* %arraydecay.i.i2302, i8** %_M_p.i.i2303, align 8, !tbaa !48
  %call.i.i2304 = call i64 @strlen(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0)) #19
  %add.ptr.i2305 = getelementptr inbounds i8, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i64 %call.i.i2304
  %cmp.i.i.i.i2306 = icmp eq i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), %add.ptr.i2305
  %1760 = bitcast i64* %__dnew.i.i.i.i2300 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1760) #19
  %1761 = bitcast i8** %__first.addr.i.i.i.i.i2298 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1761)
  store i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2298, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2307 = ptrtoint i8* %add.ptr.i2305 to i64
  %sub.ptr.sub.i.i.i.i.i.i2308 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2307, ptrtoint ([1 x i8]* @.str.5 to i64)
  %1762 = bitcast i8** %__first.addr.i.i.i.i.i2298 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1762)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2308, i64* %__dnew.i.i.i.i2300, align 8, !tbaa !50
  %cmp3.i.i.i.i2309 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2308, 15
  br i1 %cmp3.i.i.i.i2309, label %if.then4.i.i.i.i2311, label %if.end6.i.i.i.i2318

if.then4.i.i.i.i2311:                             ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2297
  %call5.i.i.i1.i2310 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp750, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2300, i64 0)
          to label %call5.i.i.i.noexc.i2314 unwind label %lpad.i2324

call5.i.i.i.noexc.i2314:                          ; preds = %if.then4.i.i.i.i2311
  %_M_p.i1.i.i.i.i2312 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2310, i8** %_M_p.i1.i.i.i.i2312, align 8, !tbaa !51
  %1763 = load i64, i64* %__dnew.i.i.i.i2300, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2313 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 2, i32 0
  store i64 %1763, i64* %_M_allocated_capacity.i.i.i.i.i2313, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2318

if.end6.i.i.i.i2318:                              ; preds = %call5.i.i.i.noexc.i2314, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2297
  %_M_p.i.i.i.i.i2315 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 0, i32 0
  %1764 = load i8*, i8** %_M_p.i.i.i.i.i2315, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2316 = ptrtoint i8* %add.ptr.i2305 to i64
  %sub.ptr.sub.i.i.i.i.i2317 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2316, ptrtoint ([1 x i8]* @.str.5 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2317, label %if.end.i.i.i.i.i.i.i2320 [
    i64 1, label %if.then.i.i.i.i.i.i2319
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2326
  ]

if.then.i.i.i.i.i.i2319:                          ; preds = %if.end6.i.i.i.i2318
  store i8 0, i8* %1764, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2326

if.end.i.i.i.i.i.i.i2320:                         ; preds = %if.end6.i.i.i.i2318
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1764, i8* align 1 getelementptr inbounds ([1 x i8], [1 x i8]* @.str.5, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2317, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2326

lpad.i2324:                                       ; preds = %if.then4.i.i.i.i2311
  %1765 = landingpad { i8*, i32 }
          cleanup
  %1766 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp750 to %"class.std::allocator.0"*
  %1767 = bitcast %"class.std::allocator.0"* %1766 to %"class.__gnu_cxx::new_allocator.1"*
  %1768 = extractvalue { i8*, i32 } %1765, 0
  %1769 = extractvalue { i8*, i32 } %1765, 1
  br label %ehcleanup758

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2326: ; preds = %if.end.i.i.i.i.i.i.i2320, %if.then.i.i.i.i.i.i2319, %if.end6.i.i.i.i2318
  %1770 = load i64, i64* %__dnew.i.i.i.i2300, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2321 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 1
  store i64 %1770, i64* %_M_string_length.i.i.i.i.i.i2321, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2322 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 0, i32 0
  %1771 = load i8*, i8** %_M_p.i.i.i.i.i.i2322, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2323 = getelementptr inbounds i8, i8* %1771, i64 %1770
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2299) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2299, align 1, !tbaa !27
  %1772 = load i8, i8* %ref.tmp.i.i.i.i.i2299, align 1, !tbaa !27
  store i8 %1772, i8* %arrayidx.i.i.i.i.i2323, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2299) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1760) #19
  %call756 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* %call745, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp746, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp750)
          to label %invoke.cont755 unwind label %lpad754

invoke.cont755:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2326
  %_M_p.i.i.i.i2327 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 0, i32 0
  %1773 = load i8*, i8** %_M_p.i.i.i.i2327, align 8, !tbaa !51
  %1774 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 2
  %arraydecay.i.i.i.i2328 = bitcast %union.anon* %1774 to i8*
  %cmp.i.i.i2329 = icmp eq i8* %1773, %arraydecay.i.i.i.i2328
  br i1 %cmp.i.i.i2329, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2335, label %if.then.i.i2333

if.then.i.i2333:                                  ; preds = %invoke.cont755
  %_M_allocated_capacity.i.i2330 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 2, i32 0
  %1775 = load i64, i64* %_M_allocated_capacity.i.i2330, align 8, !tbaa !27
  %1776 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp750 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2331 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 0, i32 0
  %1777 = load i8*, i8** %_M_p.i.i1.i.i2331, align 8, !tbaa !51
  %add.i.i.i2332 = add i64 %1775, 1
  %1778 = bitcast %"class.std::allocator.0"* %1776 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1777) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2335

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2335: ; preds = %if.then.i.i2333, %invoke.cont755
  %1779 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp750 to %"class.std::allocator.0"*
  %1780 = bitcast %"class.std::allocator.0"* %1779 to %"class.__gnu_cxx::new_allocator.1"*
  %1781 = bitcast %"class.std::allocator.0"* %ref.tmp751 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1754) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1753) #19
  %_M_p.i.i.i.i2336 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 0, i32 0
  %1782 = load i8*, i8** %_M_p.i.i.i.i2336, align 8, !tbaa !51
  %1783 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 2
  %arraydecay.i.i.i.i2337 = bitcast %union.anon* %1783 to i8*
  %cmp.i.i.i2338 = icmp eq i8* %1782, %arraydecay.i.i.i.i2337
  br i1 %cmp.i.i.i2338, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2344, label %if.then.i.i2342

if.then.i.i2342:                                  ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2335
  %_M_allocated_capacity.i.i2339 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 2, i32 0
  %1784 = load i64, i64* %_M_allocated_capacity.i.i2339, align 8, !tbaa !27
  %1785 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp746 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2340 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 0, i32 0
  %1786 = load i8*, i8** %_M_p.i.i1.i.i2340, align 8, !tbaa !51
  %add.i.i.i2341 = add i64 %1784, 1
  %1787 = bitcast %"class.std::allocator.0"* %1785 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1786) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2344

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2344: ; preds = %if.then.i.i2342, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2335
  %1788 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp746 to %"class.std::allocator.0"*
  %1789 = bitcast %"class.std::allocator.0"* %1788 to %"class.__gnu_cxx::new_allocator.1"*
  %1790 = bitcast %"class.std::allocator.0"* %ref.tmp747 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1734) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1733) #19
  %call766 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont765 unwind label %lpad548

invoke.cont765:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2344
  %1791 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp767 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1791) #19
  %1792 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp768, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1792) #19
  %1793 = bitcast %"class.std::allocator.0"* %ref.tmp768 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2377 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 0
  %1794 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 2
  %arraydecay.i.i2378 = bitcast %union.anon* %1794 to i8*
  %1795 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2377 to %"class.std::allocator.0"*
  %1796 = bitcast %"class.std::allocator.0"* %1795 to %"class.__gnu_cxx::new_allocator.1"*
  %1797 = bitcast %"class.std::allocator.0"* %ref.tmp768 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2379 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2377, i64 0, i32 0
  store i8* %arraydecay.i.i2378, i8** %_M_p.i.i2379, align 8, !tbaa !48
  %call.i.i2380 = call i64 @strlen(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0)) #19
  %add.ptr.i2381 = getelementptr inbounds i8, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %call.i.i2380
  %cmp.i.i.i.i2382 = icmp eq i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), %add.ptr.i2381
  %1798 = bitcast i64* %__dnew.i.i.i.i2376 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1798) #19
  %1799 = bitcast i8** %__first.addr.i.i.i.i.i2374 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1799)
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2374, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2383 = ptrtoint i8* %add.ptr.i2381 to i64
  %sub.ptr.sub.i.i.i.i.i.i2384 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2383, ptrtoint ([6 x i8]* @.str.75 to i64)
  %1800 = bitcast i8** %__first.addr.i.i.i.i.i2374 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1800)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2384, i64* %__dnew.i.i.i.i2376, align 8, !tbaa !50
  %cmp3.i.i.i.i2385 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2384, 15
  br i1 %cmp3.i.i.i.i2385, label %if.then4.i.i.i.i2387, label %if.end6.i.i.i.i2394

if.then4.i.i.i.i2387:                             ; preds = %invoke.cont765
  %call5.i.i.i1.i2386 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp767, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2376, i64 0)
          to label %call5.i.i.i.noexc.i2390 unwind label %lpad.i2400

call5.i.i.i.noexc.i2390:                          ; preds = %if.then4.i.i.i.i2387
  %_M_p.i1.i.i.i.i2388 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2386, i8** %_M_p.i1.i.i.i.i2388, align 8, !tbaa !51
  %1801 = load i64, i64* %__dnew.i.i.i.i2376, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2389 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 2, i32 0
  store i64 %1801, i64* %_M_allocated_capacity.i.i.i.i.i2389, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2394

if.end6.i.i.i.i2394:                              ; preds = %call5.i.i.i.noexc.i2390, %invoke.cont765
  %_M_p.i.i.i.i.i2391 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 0, i32 0
  %1802 = load i8*, i8** %_M_p.i.i.i.i.i2391, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2392 = ptrtoint i8* %add.ptr.i2381 to i64
  %sub.ptr.sub.i.i.i.i.i2393 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2392, ptrtoint ([6 x i8]* @.str.75 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2393, label %if.end.i.i.i.i.i.i.i2396 [
    i64 1, label %if.then.i.i.i.i.i.i2395
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2402
  ]

if.then.i.i.i.i.i.i2395:                          ; preds = %if.end6.i.i.i.i2394
  store i8 84, i8* %1802, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2402

if.end.i.i.i.i.i.i.i2396:                         ; preds = %if.end6.i.i.i.i2394
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1802, i8* align 1 getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2393, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2402

lpad.i2400:                                       ; preds = %if.then4.i.i.i.i2387
  %1803 = landingpad { i8*, i32 }
          cleanup
  %1804 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp767 to %"class.std::allocator.0"*
  %1805 = bitcast %"class.std::allocator.0"* %1804 to %"class.__gnu_cxx::new_allocator.1"*
  %1806 = extractvalue { i8*, i32 } %1803, 0
  %1807 = extractvalue { i8*, i32 } %1803, 1
  br label %ehcleanup787

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2402: ; preds = %if.end.i.i.i.i.i.i.i2396, %if.then.i.i.i.i.i.i2395, %if.end6.i.i.i.i2394
  %1808 = load i64, i64* %__dnew.i.i.i.i2376, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2397 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 1
  store i64 %1808, i64* %_M_string_length.i.i.i.i.i.i2397, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2398 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 0, i32 0
  %1809 = load i8*, i8** %_M_p.i.i.i.i.i.i2398, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2399 = getelementptr inbounds i8, i8* %1809, i64 %1808
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2375) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2375, align 1, !tbaa !27
  %1810 = load i8, i8* %ref.tmp.i.i.i.i.i2375, align 1, !tbaa !27
  store i8 %1810, i8* %arrayidx.i.i.i.i.i2399, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2375) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1798) #19
  %call773 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* %call766, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp767)
          to label %invoke.cont772 unwind label %lpad771

invoke.cont772:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2402
  %1811 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp774 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1811) #19
  %1812 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp775, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1812) #19
  %1813 = bitcast %"class.std::allocator.0"* %ref.tmp775 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2406 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 0
  %1814 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 2
  %arraydecay.i.i2407 = bitcast %union.anon* %1814 to i8*
  %1815 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2406 to %"class.std::allocator.0"*
  %1816 = bitcast %"class.std::allocator.0"* %1815 to %"class.__gnu_cxx::new_allocator.1"*
  %1817 = bitcast %"class.std::allocator.0"* %ref.tmp775 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2408 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2406, i64 0, i32 0
  store i8* %arraydecay.i.i2407, i8** %_M_p.i.i2408, align 8, !tbaa !48
  %call.i.i2409 = call i64 @strlen(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.76, i64 0, i64 0)) #19
  %add.ptr.i2410 = getelementptr inbounds i8, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.76, i64 0, i64 0), i64 %call.i.i2409
  %cmp.i.i.i.i2411 = icmp eq i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.76, i64 0, i64 0), %add.ptr.i2410
  %1818 = bitcast i64* %__dnew.i.i.i.i2405 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1818) #19
  %1819 = bitcast i8** %__first.addr.i.i.i.i.i2403 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1819)
  store i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.76, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2403, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2412 = ptrtoint i8* %add.ptr.i2410 to i64
  %sub.ptr.sub.i.i.i.i.i.i2413 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2412, ptrtoint ([14 x i8]* @.str.76 to i64)
  %1820 = bitcast i8** %__first.addr.i.i.i.i.i2403 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1820)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2413, i64* %__dnew.i.i.i.i2405, align 8, !tbaa !50
  %cmp3.i.i.i.i2414 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2413, 15
  br i1 %cmp3.i.i.i.i2414, label %if.then4.i.i.i.i2416, label %if.end6.i.i.i.i2423

if.then4.i.i.i.i2416:                             ; preds = %invoke.cont772
  %call5.i.i.i1.i2415 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp774, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2405, i64 0)
          to label %call5.i.i.i.noexc.i2419 unwind label %lpad.i2429

call5.i.i.i.noexc.i2419:                          ; preds = %if.then4.i.i.i.i2416
  %_M_p.i1.i.i.i.i2417 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2415, i8** %_M_p.i1.i.i.i.i2417, align 8, !tbaa !51
  %1821 = load i64, i64* %__dnew.i.i.i.i2405, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2418 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 2, i32 0
  store i64 %1821, i64* %_M_allocated_capacity.i.i.i.i.i2418, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2423

if.end6.i.i.i.i2423:                              ; preds = %call5.i.i.i.noexc.i2419, %invoke.cont772
  %_M_p.i.i.i.i.i2420 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 0, i32 0
  %1822 = load i8*, i8** %_M_p.i.i.i.i.i2420, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2421 = ptrtoint i8* %add.ptr.i2410 to i64
  %sub.ptr.sub.i.i.i.i.i2422 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2421, ptrtoint ([14 x i8]* @.str.76 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2422, label %if.end.i.i.i.i.i.i.i2425 [
    i64 1, label %if.then.i.i.i.i.i.i2424
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2431
  ]

if.then.i.i.i.i.i.i2424:                          ; preds = %if.end6.i.i.i.i2423
  store i8 84, i8* %1822, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2431

if.end.i.i.i.i.i.i.i2425:                         ; preds = %if.end6.i.i.i.i2423
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1822, i8* align 1 getelementptr inbounds ([14 x i8], [14 x i8]* @.str.76, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2422, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2431

lpad.i2429:                                       ; preds = %if.then4.i.i.i.i2416
  %1823 = landingpad { i8*, i32 }
          cleanup
  %1824 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp774 to %"class.std::allocator.0"*
  %1825 = bitcast %"class.std::allocator.0"* %1824 to %"class.__gnu_cxx::new_allocator.1"*
  %1826 = extractvalue { i8*, i32 } %1823, 0
  %1827 = extractvalue { i8*, i32 } %1823, 1
  br label %ehcleanup783

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2431: ; preds = %if.end.i.i.i.i.i.i.i2425, %if.then.i.i.i.i.i.i2424, %if.end6.i.i.i.i2423
  %1828 = load i64, i64* %__dnew.i.i.i.i2405, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2426 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 1
  store i64 %1828, i64* %_M_string_length.i.i.i.i.i.i2426, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2427 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 0, i32 0
  %1829 = load i8*, i8** %_M_p.i.i.i.i.i.i2427, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2428 = getelementptr inbounds i8, i8* %1829, i64 %1828
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2404) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2404, align 1, !tbaa !27
  %1830 = load i8, i8* %ref.tmp.i.i.i.i.i2404, align 1, !tbaa !27
  store i8 %1830, i8* %arrayidx.i.i.i.i.i2428, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2404) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1818) #19
  %1831 = load double, double* %arrayidx541, align 16, !tbaa !42
  %call781 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call773, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp774, double %1831)
          to label %invoke.cont780 unwind label %lpad779

invoke.cont780:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2431
  %_M_p.i.i.i.i2432 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 0, i32 0
  %1832 = load i8*, i8** %_M_p.i.i.i.i2432, align 8, !tbaa !51
  %1833 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 2
  %arraydecay.i.i.i.i2433 = bitcast %union.anon* %1833 to i8*
  %cmp.i.i.i2434 = icmp eq i8* %1832, %arraydecay.i.i.i.i2433
  br i1 %cmp.i.i.i2434, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2440, label %if.then.i.i2438

if.then.i.i2438:                                  ; preds = %invoke.cont780
  %_M_allocated_capacity.i.i2435 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 2, i32 0
  %1834 = load i64, i64* %_M_allocated_capacity.i.i2435, align 8, !tbaa !27
  %1835 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp774 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2436 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 0, i32 0
  %1836 = load i8*, i8** %_M_p.i.i1.i.i2436, align 8, !tbaa !51
  %add.i.i.i2437 = add i64 %1834, 1
  %1837 = bitcast %"class.std::allocator.0"* %1835 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1836) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2440

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2440: ; preds = %if.then.i.i2438, %invoke.cont780
  %1838 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp774 to %"class.std::allocator.0"*
  %1839 = bitcast %"class.std::allocator.0"* %1838 to %"class.__gnu_cxx::new_allocator.1"*
  %1840 = bitcast %"class.std::allocator.0"* %ref.tmp775 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1812) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1811) #19
  %_M_p.i.i.i.i2441 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 0, i32 0
  %1841 = load i8*, i8** %_M_p.i.i.i.i2441, align 8, !tbaa !51
  %1842 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 2
  %arraydecay.i.i.i.i2442 = bitcast %union.anon* %1842 to i8*
  %cmp.i.i.i2443 = icmp eq i8* %1841, %arraydecay.i.i.i.i2442
  br i1 %cmp.i.i.i2443, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2449, label %if.then.i.i2447

if.then.i.i2447:                                  ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2440
  %_M_allocated_capacity.i.i2444 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 2, i32 0
  %1843 = load i64, i64* %_M_allocated_capacity.i.i2444, align 8, !tbaa !27
  %1844 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp767 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2445 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 0, i32 0
  %1845 = load i8*, i8** %_M_p.i.i1.i.i2445, align 8, !tbaa !51
  %add.i.i.i2446 = add i64 %1843, 1
  %1846 = bitcast %"class.std::allocator.0"* %1844 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1845) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2449

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2449: ; preds = %if.then.i.i2447, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2440
  %1847 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp767 to %"class.std::allocator.0"*
  %1848 = bitcast %"class.std::allocator.0"* %1847 to %"class.__gnu_cxx::new_allocator.1"*
  %1849 = bitcast %"class.std::allocator.0"* %ref.tmp768 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1792) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1791) #19
  %call791 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont790 unwind label %lpad548

invoke.cont790:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2449
  %1850 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp792 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1850) #19
  %1851 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp793, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1851) #19
  %1852 = bitcast %"class.std::allocator.0"* %ref.tmp793 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2462 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 0
  %1853 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 2
  %arraydecay.i.i2463 = bitcast %union.anon* %1853 to i8*
  %1854 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2462 to %"class.std::allocator.0"*
  %1855 = bitcast %"class.std::allocator.0"* %1854 to %"class.__gnu_cxx::new_allocator.1"*
  %1856 = bitcast %"class.std::allocator.0"* %ref.tmp793 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2464 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2462, i64 0, i32 0
  store i8* %arraydecay.i.i2463, i8** %_M_p.i.i2464, align 8, !tbaa !48
  %call.i.i2465 = call i64 @strlen(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0)) #19
  %add.ptr.i2466 = getelementptr inbounds i8, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %call.i.i2465
  %cmp.i.i.i.i2467 = icmp eq i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), %add.ptr.i2466
  %1857 = bitcast i64* %__dnew.i.i.i.i2461 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1857) #19
  %1858 = bitcast i8** %__first.addr.i.i.i.i.i2459 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1858)
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2459, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2468 = ptrtoint i8* %add.ptr.i2466 to i64
  %sub.ptr.sub.i.i.i.i.i.i2469 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2468, ptrtoint ([6 x i8]* @.str.75 to i64)
  %1859 = bitcast i8** %__first.addr.i.i.i.i.i2459 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1859)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2469, i64* %__dnew.i.i.i.i2461, align 8, !tbaa !50
  %cmp3.i.i.i.i2470 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2469, 15
  br i1 %cmp3.i.i.i.i2470, label %if.then4.i.i.i.i2472, label %if.end6.i.i.i.i2479

if.then4.i.i.i.i2472:                             ; preds = %invoke.cont790
  %call5.i.i.i1.i2471 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp792, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2461, i64 0)
          to label %call5.i.i.i.noexc.i2475 unwind label %lpad.i2485

call5.i.i.i.noexc.i2475:                          ; preds = %if.then4.i.i.i.i2472
  %_M_p.i1.i.i.i.i2473 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2471, i8** %_M_p.i1.i.i.i.i2473, align 8, !tbaa !51
  %1860 = load i64, i64* %__dnew.i.i.i.i2461, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2474 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 2, i32 0
  store i64 %1860, i64* %_M_allocated_capacity.i.i.i.i.i2474, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2479

if.end6.i.i.i.i2479:                              ; preds = %call5.i.i.i.noexc.i2475, %invoke.cont790
  %_M_p.i.i.i.i.i2476 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 0, i32 0
  %1861 = load i8*, i8** %_M_p.i.i.i.i.i2476, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2477 = ptrtoint i8* %add.ptr.i2466 to i64
  %sub.ptr.sub.i.i.i.i.i2478 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2477, ptrtoint ([6 x i8]* @.str.75 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2478, label %if.end.i.i.i.i.i.i.i2481 [
    i64 1, label %if.then.i.i.i.i.i.i2480
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2487
  ]

if.then.i.i.i.i.i.i2480:                          ; preds = %if.end6.i.i.i.i2479
  store i8 84, i8* %1861, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2487

if.end.i.i.i.i.i.i.i2481:                         ; preds = %if.end6.i.i.i.i2479
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1861, i8* align 1 getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2478, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2487

lpad.i2485:                                       ; preds = %if.then4.i.i.i.i2472
  %1862 = landingpad { i8*, i32 }
          cleanup
  %1863 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp792 to %"class.std::allocator.0"*
  %1864 = bitcast %"class.std::allocator.0"* %1863 to %"class.__gnu_cxx::new_allocator.1"*
  %1865 = extractvalue { i8*, i32 } %1862, 0
  %1866 = extractvalue { i8*, i32 } %1862, 1
  br label %ehcleanup811

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2487: ; preds = %if.end.i.i.i.i.i.i.i2481, %if.then.i.i.i.i.i.i2480, %if.end6.i.i.i.i2479
  %1867 = load i64, i64* %__dnew.i.i.i.i2461, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2482 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 1
  store i64 %1867, i64* %_M_string_length.i.i.i.i.i.i2482, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2483 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 0, i32 0
  %1868 = load i8*, i8** %_M_p.i.i.i.i.i.i2483, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2484 = getelementptr inbounds i8, i8* %1868, i64 %1867
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2460) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2460, align 1, !tbaa !27
  %1869 = load i8, i8* %ref.tmp.i.i.i.i.i2460, align 1, !tbaa !27
  store i8 %1869, i8* %arrayidx.i.i.i.i.i2484, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2460) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1857) #19
  %call798 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* %call791, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp792)
          to label %invoke.cont797 unwind label %lpad796

invoke.cont797:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2487
  %1870 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp799 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1870) #19
  %1871 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp800, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1871) #19
  %1872 = bitcast %"class.std::allocator.0"* %ref.tmp800 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2491 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 0
  %1873 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 2
  %arraydecay.i.i2492 = bitcast %union.anon* %1873 to i8*
  %1874 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2491 to %"class.std::allocator.0"*
  %1875 = bitcast %"class.std::allocator.0"* %1874 to %"class.__gnu_cxx::new_allocator.1"*
  %1876 = bitcast %"class.std::allocator.0"* %ref.tmp800 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2493 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2491, i64 0, i32 0
  store i8* %arraydecay.i.i2492, i8** %_M_p.i.i2493, align 8, !tbaa !48
  %call.i.i2494 = call i64 @strlen(i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.77, i64 0, i64 0)) #19
  %add.ptr.i2495 = getelementptr inbounds i8, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.77, i64 0, i64 0), i64 %call.i.i2494
  %cmp.i.i.i.i2496 = icmp eq i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.77, i64 0, i64 0), %add.ptr.i2495
  %1877 = bitcast i64* %__dnew.i.i.i.i2490 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1877) #19
  %1878 = bitcast i8** %__first.addr.i.i.i.i.i2488 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1878)
  store i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.77, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2488, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2497 = ptrtoint i8* %add.ptr.i2495 to i64
  %sub.ptr.sub.i.i.i.i.i.i2498 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2497, ptrtoint ([15 x i8]* @.str.77 to i64)
  %1879 = bitcast i8** %__first.addr.i.i.i.i.i2488 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1879)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2498, i64* %__dnew.i.i.i.i2490, align 8, !tbaa !50
  %cmp3.i.i.i.i2499 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2498, 15
  br i1 %cmp3.i.i.i.i2499, label %if.then4.i.i.i.i2501, label %if.end6.i.i.i.i2508

if.then4.i.i.i.i2501:                             ; preds = %invoke.cont797
  %call5.i.i.i1.i2500 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp799, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2490, i64 0)
          to label %call5.i.i.i.noexc.i2504 unwind label %lpad.i2514

call5.i.i.i.noexc.i2504:                          ; preds = %if.then4.i.i.i.i2501
  %_M_p.i1.i.i.i.i2502 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2500, i8** %_M_p.i1.i.i.i.i2502, align 8, !tbaa !51
  %1880 = load i64, i64* %__dnew.i.i.i.i2490, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2503 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 2, i32 0
  store i64 %1880, i64* %_M_allocated_capacity.i.i.i.i.i2503, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2508

if.end6.i.i.i.i2508:                              ; preds = %call5.i.i.i.noexc.i2504, %invoke.cont797
  %_M_p.i.i.i.i.i2505 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 0, i32 0
  %1881 = load i8*, i8** %_M_p.i.i.i.i.i2505, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2506 = ptrtoint i8* %add.ptr.i2495 to i64
  %sub.ptr.sub.i.i.i.i.i2507 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2506, ptrtoint ([15 x i8]* @.str.77 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2507, label %if.end.i.i.i.i.i.i.i2510 [
    i64 1, label %if.then.i.i.i.i.i.i2509
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2516
  ]

if.then.i.i.i.i.i.i2509:                          ; preds = %if.end6.i.i.i.i2508
  store i8 84, i8* %1881, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2516

if.end.i.i.i.i.i.i.i2510:                         ; preds = %if.end6.i.i.i.i2508
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1881, i8* align 1 getelementptr inbounds ([15 x i8], [15 x i8]* @.str.77, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2507, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2516

lpad.i2514:                                       ; preds = %if.then4.i.i.i.i2501
  %1882 = landingpad { i8*, i32 }
          cleanup
  %1883 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp799 to %"class.std::allocator.0"*
  %1884 = bitcast %"class.std::allocator.0"* %1883 to %"class.__gnu_cxx::new_allocator.1"*
  %1885 = extractvalue { i8*, i32 } %1882, 0
  %1886 = extractvalue { i8*, i32 } %1882, 1
  br label %ehcleanup807

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2516: ; preds = %if.end.i.i.i.i.i.i.i2510, %if.then.i.i.i.i.i.i2509, %if.end6.i.i.i.i2508
  %1887 = load i64, i64* %__dnew.i.i.i.i2490, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2511 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 1
  store i64 %1887, i64* %_M_string_length.i.i.i.i.i.i2511, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2512 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 0, i32 0
  %1888 = load i8*, i8** %_M_p.i.i.i.i.i.i2512, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2513 = getelementptr inbounds i8, i8* %1888, i64 %1887
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2489) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2489, align 1, !tbaa !27
  %1889 = load i8, i8* %ref.tmp.i.i.i.i.i2489, align 1, !tbaa !27
  store i8 %1889, i8* %arrayidx.i.i.i.i.i2513, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2489) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1877) #19
  %call805 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call798, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp799, double %add520)
          to label %invoke.cont804 unwind label %lpad803

invoke.cont804:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2516
  %_M_p.i.i.i.i2517 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 0, i32 0
  %1890 = load i8*, i8** %_M_p.i.i.i.i2517, align 8, !tbaa !51
  %1891 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 2
  %arraydecay.i.i.i.i2518 = bitcast %union.anon* %1891 to i8*
  %cmp.i.i.i2519 = icmp eq i8* %1890, %arraydecay.i.i.i.i2518
  br i1 %cmp.i.i.i2519, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2525, label %if.then.i.i2523

if.then.i.i2523:                                  ; preds = %invoke.cont804
  %_M_allocated_capacity.i.i2520 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 2, i32 0
  %1892 = load i64, i64* %_M_allocated_capacity.i.i2520, align 8, !tbaa !27
  %1893 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp799 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2521 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 0, i32 0
  %1894 = load i8*, i8** %_M_p.i.i1.i.i2521, align 8, !tbaa !51
  %add.i.i.i2522 = add i64 %1892, 1
  %1895 = bitcast %"class.std::allocator.0"* %1893 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1894) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2525

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2525: ; preds = %if.then.i.i2523, %invoke.cont804
  %1896 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp799 to %"class.std::allocator.0"*
  %1897 = bitcast %"class.std::allocator.0"* %1896 to %"class.__gnu_cxx::new_allocator.1"*
  %1898 = bitcast %"class.std::allocator.0"* %ref.tmp800 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1871) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1870) #19
  %_M_p.i.i.i.i2526 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 0, i32 0
  %1899 = load i8*, i8** %_M_p.i.i.i.i2526, align 8, !tbaa !51
  %1900 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 2
  %arraydecay.i.i.i.i2527 = bitcast %union.anon* %1900 to i8*
  %cmp.i.i.i2528 = icmp eq i8* %1899, %arraydecay.i.i.i.i2527
  br i1 %cmp.i.i.i2528, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2534, label %if.then.i.i2532

if.then.i.i2532:                                  ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2525
  %_M_allocated_capacity.i.i2529 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 2, i32 0
  %1901 = load i64, i64* %_M_allocated_capacity.i.i2529, align 8, !tbaa !27
  %1902 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp792 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2530 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 0, i32 0
  %1903 = load i8*, i8** %_M_p.i.i1.i.i2530, align 8, !tbaa !51
  %add.i.i.i2531 = add i64 %1901, 1
  %1904 = bitcast %"class.std::allocator.0"* %1902 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1903) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2534

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2534: ; preds = %if.then.i.i2532, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2525
  %1905 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp792 to %"class.std::allocator.0"*
  %1906 = bitcast %"class.std::allocator.0"* %1905 to %"class.__gnu_cxx::new_allocator.1"*
  %1907 = bitcast %"class.std::allocator.0"* %ref.tmp793 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1851) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1850) #19
  %cmp814 = fcmp ult double %total_mflops.0, 0.000000e+00
  br i1 %cmp814, label %if.else840, label %if.then815

if.then815:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2534
  %call817 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont816 unwind label %lpad548

invoke.cont816:                                   ; preds = %if.then815
  %1908 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp818 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1908) #19
  %1909 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp819, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1909) #19
  %1910 = bitcast %"class.std::allocator.0"* %ref.tmp819 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2556 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 0
  %1911 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 2
  %arraydecay.i.i2557 = bitcast %union.anon* %1911 to i8*
  %1912 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2556 to %"class.std::allocator.0"*
  %1913 = bitcast %"class.std::allocator.0"* %1912 to %"class.__gnu_cxx::new_allocator.1"*
  %1914 = bitcast %"class.std::allocator.0"* %ref.tmp819 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2558 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2556, i64 0, i32 0
  store i8* %arraydecay.i.i2557, i8** %_M_p.i.i2558, align 8, !tbaa !48
  %call.i.i2559 = call i64 @strlen(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0)) #19
  %add.ptr.i2560 = getelementptr inbounds i8, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %call.i.i2559
  %cmp.i.i.i.i2561 = icmp eq i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), %add.ptr.i2560
  %1915 = bitcast i64* %__dnew.i.i.i.i2555 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1915) #19
  %1916 = bitcast i8** %__first.addr.i.i.i.i.i2553 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1916)
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2553, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2562 = ptrtoint i8* %add.ptr.i2560 to i64
  %sub.ptr.sub.i.i.i.i.i.i2563 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2562, ptrtoint ([6 x i8]* @.str.75 to i64)
  %1917 = bitcast i8** %__first.addr.i.i.i.i.i2553 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1917)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2563, i64* %__dnew.i.i.i.i2555, align 8, !tbaa !50
  %cmp3.i.i.i.i2564 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2563, 15
  br i1 %cmp3.i.i.i.i2564, label %if.then4.i.i.i.i2566, label %if.end6.i.i.i.i2573

if.then4.i.i.i.i2566:                             ; preds = %invoke.cont816
  %call5.i.i.i1.i2565 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp818, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2555, i64 0)
          to label %call5.i.i.i.noexc.i2569 unwind label %lpad.i2579

call5.i.i.i.noexc.i2569:                          ; preds = %if.then4.i.i.i.i2566
  %_M_p.i1.i.i.i.i2567 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2565, i8** %_M_p.i1.i.i.i.i2567, align 8, !tbaa !51
  %1918 = load i64, i64* %__dnew.i.i.i.i2555, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2568 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 2, i32 0
  store i64 %1918, i64* %_M_allocated_capacity.i.i.i.i.i2568, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2573

if.end6.i.i.i.i2573:                              ; preds = %call5.i.i.i.noexc.i2569, %invoke.cont816
  %_M_p.i.i.i.i.i2570 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 0, i32 0
  %1919 = load i8*, i8** %_M_p.i.i.i.i.i2570, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2571 = ptrtoint i8* %add.ptr.i2560 to i64
  %sub.ptr.sub.i.i.i.i.i2572 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2571, ptrtoint ([6 x i8]* @.str.75 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2572, label %if.end.i.i.i.i.i.i.i2575 [
    i64 1, label %if.then.i.i.i.i.i.i2574
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2581
  ]

if.then.i.i.i.i.i.i2574:                          ; preds = %if.end6.i.i.i.i2573
  store i8 84, i8* %1919, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2581

if.end.i.i.i.i.i.i.i2575:                         ; preds = %if.end6.i.i.i.i2573
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1919, i8* align 1 getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2572, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2581

lpad.i2579:                                       ; preds = %if.then4.i.i.i.i2566
  %1920 = landingpad { i8*, i32 }
          cleanup
  %1921 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp818 to %"class.std::allocator.0"*
  %1922 = bitcast %"class.std::allocator.0"* %1921 to %"class.__gnu_cxx::new_allocator.1"*
  %1923 = extractvalue { i8*, i32 } %1920, 0
  %1924 = extractvalue { i8*, i32 } %1920, 1
  br label %ehcleanup837

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2581: ; preds = %if.end.i.i.i.i.i.i.i2575, %if.then.i.i.i.i.i.i2574, %if.end6.i.i.i.i2573
  %1925 = load i64, i64* %__dnew.i.i.i.i2555, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2576 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 1
  store i64 %1925, i64* %_M_string_length.i.i.i.i.i.i2576, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2577 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 0, i32 0
  %1926 = load i8*, i8** %_M_p.i.i.i.i.i.i2577, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2578 = getelementptr inbounds i8, i8* %1926, i64 %1925
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2554) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2554, align 1, !tbaa !27
  %1927 = load i8, i8* %ref.tmp.i.i.i.i.i2554, align 1, !tbaa !27
  store i8 %1927, i8* %arrayidx.i.i.i.i.i2578, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2554) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1915) #19
  %call824 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* %call817, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp818)
          to label %invoke.cont823 unwind label %lpad822

invoke.cont823:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2581
  %1928 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp825 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %1928) #19
  %1929 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp826, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %1929) #19
  %1930 = bitcast %"class.std::allocator.0"* %ref.tmp826 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2585 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 0
  %1931 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 2
  %arraydecay.i.i2586 = bitcast %union.anon* %1931 to i8*
  %1932 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2585 to %"class.std::allocator.0"*
  %1933 = bitcast %"class.std::allocator.0"* %1932 to %"class.__gnu_cxx::new_allocator.1"*
  %1934 = bitcast %"class.std::allocator.0"* %ref.tmp826 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2587 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2585, i64 0, i32 0
  store i8* %arraydecay.i.i2586, i8** %_M_p.i.i2587, align 8, !tbaa !48
  %call.i.i2588 = call i64 @strlen(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0)) #19
  %add.ptr.i2589 = getelementptr inbounds i8, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0), i64 %call.i.i2588
  %cmp.i.i.i.i2590 = icmp eq i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0), %add.ptr.i2589
  %1935 = bitcast i64* %__dnew.i.i.i.i2584 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1935) #19
  %1936 = bitcast i8** %__first.addr.i.i.i.i.i2582 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1936)
  store i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2582, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2591 = ptrtoint i8* %add.ptr.i2589 to i64
  %sub.ptr.sub.i.i.i.i.i.i2592 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2591, ptrtoint ([16 x i8]* @.str.78 to i64)
  %1937 = bitcast i8** %__first.addr.i.i.i.i.i2582 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %1937)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2592, i64* %__dnew.i.i.i.i2584, align 8, !tbaa !50
  %cmp3.i.i.i.i2593 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2592, 15
  br i1 %cmp3.i.i.i.i2593, label %if.then4.i.i.i.i2595, label %if.end6.i.i.i.i2602

if.then4.i.i.i.i2595:                             ; preds = %invoke.cont823
  %call5.i.i.i1.i2594 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp825, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2584, i64 0)
          to label %call5.i.i.i.noexc.i2598 unwind label %lpad.i2608

call5.i.i.i.noexc.i2598:                          ; preds = %if.then4.i.i.i.i2595
  %_M_p.i1.i.i.i.i2596 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2594, i8** %_M_p.i1.i.i.i.i2596, align 8, !tbaa !51
  %1938 = load i64, i64* %__dnew.i.i.i.i2584, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2597 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 2, i32 0
  store i64 %1938, i64* %_M_allocated_capacity.i.i.i.i.i2597, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2602

if.end6.i.i.i.i2602:                              ; preds = %call5.i.i.i.noexc.i2598, %invoke.cont823
  %_M_p.i.i.i.i.i2599 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 0, i32 0
  %1939 = load i8*, i8** %_M_p.i.i.i.i.i2599, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2600 = ptrtoint i8* %add.ptr.i2589 to i64
  %sub.ptr.sub.i.i.i.i.i2601 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2600, ptrtoint ([16 x i8]* @.str.78 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2601, label %if.end.i.i.i.i.i.i.i2604 [
    i64 1, label %if.then.i.i.i.i.i.i2603
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610
  ]

if.then.i.i.i.i.i.i2603:                          ; preds = %if.end6.i.i.i.i2602
  store i8 84, i8* %1939, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610

if.end.i.i.i.i.i.i.i2604:                         ; preds = %if.end6.i.i.i.i2602
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %1939, i8* align 1 getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2601, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610

lpad.i2608:                                       ; preds = %if.then4.i.i.i.i2595
  %1940 = landingpad { i8*, i32 }
          cleanup
  %1941 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp825 to %"class.std::allocator.0"*
  %1942 = bitcast %"class.std::allocator.0"* %1941 to %"class.__gnu_cxx::new_allocator.1"*
  %1943 = extractvalue { i8*, i32 } %1940, 0
  %1944 = extractvalue { i8*, i32 } %1940, 1
  br label %ehcleanup833

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610: ; preds = %if.end.i.i.i.i.i.i.i2604, %if.then.i.i.i.i.i.i2603, %if.end6.i.i.i.i2602
  %1945 = load i64, i64* %__dnew.i.i.i.i2584, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2605 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 1
  store i64 %1945, i64* %_M_string_length.i.i.i.i.i.i2605, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2606 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 0, i32 0
  %1946 = load i8*, i8** %_M_p.i.i.i.i.i.i2606, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2607 = getelementptr inbounds i8, i8* %1946, i64 %1945
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2583) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2583, align 1, !tbaa !27
  %1947 = load i8, i8* %ref.tmp.i.i.i.i.i2583, align 1, !tbaa !27
  store i8 %1947, i8* %arrayidx.i.i.i.i.i2607, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2583) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1935) #19
  %call831 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call824, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp825, double %total_mflops.0)
          to label %if.end873 unwind label %lpad829

lpad754:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2326
  %1948 = landingpad { i8*, i32 }
          cleanup
  %1949 = extractvalue { i8*, i32 } %1948, 0
  %1950 = extractvalue { i8*, i32 } %1948, 1
  %_M_p.i.i.i.i2611 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 0, i32 0
  %1951 = load i8*, i8** %_M_p.i.i.i.i2611, align 8, !tbaa !51
  %1952 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 2
  %arraydecay.i.i.i.i2612 = bitcast %union.anon* %1952 to i8*
  %cmp.i.i.i2613 = icmp eq i8* %1951, %arraydecay.i.i.i.i2612
  br i1 %cmp.i.i.i2613, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2619, label %if.then.i.i2617

if.then.i.i2617:                                  ; preds = %lpad754
  %_M_allocated_capacity.i.i2614 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 2, i32 0
  %1953 = load i64, i64* %_M_allocated_capacity.i.i2614, align 8, !tbaa !27
  %1954 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp750 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2615 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp750, i64 0, i32 0, i32 0
  %1955 = load i8*, i8** %_M_p.i.i1.i.i2615, align 8, !tbaa !51
  %add.i.i.i2616 = add i64 %1953, 1
  %1956 = bitcast %"class.std::allocator.0"* %1954 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1955) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2619

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2619: ; preds = %if.then.i.i2617, %lpad754
  %1957 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp750 to %"class.std::allocator.0"*
  %1958 = bitcast %"class.std::allocator.0"* %1957 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup758

ehcleanup758:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2619, %lpad.i2324
  %ehselector.slot.40 = phi i32 [ %1950, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2619 ], [ %1769, %lpad.i2324 ]
  %exn.slot.40 = phi i8* [ %1949, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2619 ], [ %1768, %lpad.i2324 ]
  %1959 = bitcast %"class.std::allocator.0"* %ref.tmp751 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1754) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1753) #19
  %_M_p.i.i.i.i2620 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 0, i32 0
  %1960 = load i8*, i8** %_M_p.i.i.i.i2620, align 8, !tbaa !51
  %1961 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 2
  %arraydecay.i.i.i.i2621 = bitcast %union.anon* %1961 to i8*
  %cmp.i.i.i2622 = icmp eq i8* %1960, %arraydecay.i.i.i.i2621
  br i1 %cmp.i.i.i2622, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2628, label %if.then.i.i2626

if.then.i.i2626:                                  ; preds = %ehcleanup758
  %_M_allocated_capacity.i.i2623 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 2, i32 0
  %1962 = load i64, i64* %_M_allocated_capacity.i.i2623, align 8, !tbaa !27
  %1963 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp746 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2624 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp746, i64 0, i32 0, i32 0
  %1964 = load i8*, i8** %_M_p.i.i1.i.i2624, align 8, !tbaa !51
  %add.i.i.i2625 = add i64 %1962, 1
  %1965 = bitcast %"class.std::allocator.0"* %1963 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1964) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2628

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2628: ; preds = %if.then.i.i2626, %ehcleanup758
  %1966 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp746 to %"class.std::allocator.0"*
  %1967 = bitcast %"class.std::allocator.0"* %1966 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup762

ehcleanup762:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2628, %lpad.i2295
  %ehselector.slot.41 = phi i32 [ %ehselector.slot.40, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2628 ], [ %1749, %lpad.i2295 ]
  %exn.slot.41 = phi i8* [ %exn.slot.40, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2628 ], [ %1748, %lpad.i2295 ]
  %1968 = bitcast %"class.std::allocator.0"* %ref.tmp747 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1734) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1733) #19
  br label %ehcleanup900

lpad771:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2402
  %1969 = landingpad { i8*, i32 }
          cleanup
  %1970 = extractvalue { i8*, i32 } %1969, 0
  %1971 = extractvalue { i8*, i32 } %1969, 1
  br label %ehcleanup786

lpad779:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2431
  %1972 = landingpad { i8*, i32 }
          cleanup
  %1973 = extractvalue { i8*, i32 } %1972, 0
  %1974 = extractvalue { i8*, i32 } %1972, 1
  %_M_p.i.i.i.i2638 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 0, i32 0
  %1975 = load i8*, i8** %_M_p.i.i.i.i2638, align 8, !tbaa !51
  %1976 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 2
  %arraydecay.i.i.i.i2639 = bitcast %union.anon* %1976 to i8*
  %cmp.i.i.i2640 = icmp eq i8* %1975, %arraydecay.i.i.i.i2639
  br i1 %cmp.i.i.i2640, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2646, label %if.then.i.i2644

if.then.i.i2644:                                  ; preds = %lpad779
  %_M_allocated_capacity.i.i2641 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 2, i32 0
  %1977 = load i64, i64* %_M_allocated_capacity.i.i2641, align 8, !tbaa !27
  %1978 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp774 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2642 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp774, i64 0, i32 0, i32 0
  %1979 = load i8*, i8** %_M_p.i.i1.i.i2642, align 8, !tbaa !51
  %add.i.i.i2643 = add i64 %1977, 1
  %1980 = bitcast %"class.std::allocator.0"* %1978 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1979) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2646

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2646: ; preds = %if.then.i.i2644, %lpad779
  %1981 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp774 to %"class.std::allocator.0"*
  %1982 = bitcast %"class.std::allocator.0"* %1981 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup783

ehcleanup783:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2646, %lpad.i2429
  %ehselector.slot.42 = phi i32 [ %1974, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2646 ], [ %1827, %lpad.i2429 ]
  %exn.slot.42 = phi i8* [ %1973, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2646 ], [ %1826, %lpad.i2429 ]
  %1983 = bitcast %"class.std::allocator.0"* %ref.tmp775 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1812) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1811) #19
  br label %ehcleanup786

ehcleanup786:                                     ; preds = %ehcleanup783, %lpad771
  %ehselector.slot.43 = phi i32 [ %ehselector.slot.42, %ehcleanup783 ], [ %1971, %lpad771 ]
  %exn.slot.43 = phi i8* [ %exn.slot.42, %ehcleanup783 ], [ %1970, %lpad771 ]
  %_M_p.i.i.i.i2647 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 0, i32 0
  %1984 = load i8*, i8** %_M_p.i.i.i.i2647, align 8, !tbaa !51
  %1985 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 2
  %arraydecay.i.i.i.i2648 = bitcast %union.anon* %1985 to i8*
  %cmp.i.i.i2649 = icmp eq i8* %1984, %arraydecay.i.i.i.i2648
  br i1 %cmp.i.i.i2649, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2655, label %if.then.i.i2653

if.then.i.i2653:                                  ; preds = %ehcleanup786
  %_M_allocated_capacity.i.i2650 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 2, i32 0
  %1986 = load i64, i64* %_M_allocated_capacity.i.i2650, align 8, !tbaa !27
  %1987 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp767 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2651 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp767, i64 0, i32 0, i32 0
  %1988 = load i8*, i8** %_M_p.i.i1.i.i2651, align 8, !tbaa !51
  %add.i.i.i2652 = add i64 %1986, 1
  %1989 = bitcast %"class.std::allocator.0"* %1987 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %1988) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2655

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2655: ; preds = %if.then.i.i2653, %ehcleanup786
  %1990 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp767 to %"class.std::allocator.0"*
  %1991 = bitcast %"class.std::allocator.0"* %1990 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup787

ehcleanup787:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2655, %lpad.i2400
  %ehselector.slot.44 = phi i32 [ %ehselector.slot.43, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2655 ], [ %1807, %lpad.i2400 ]
  %exn.slot.44 = phi i8* [ %exn.slot.43, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2655 ], [ %1806, %lpad.i2400 ]
  %1992 = bitcast %"class.std::allocator.0"* %ref.tmp768 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1792) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1791) #19
  br label %ehcleanup900

lpad796:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2487
  %1993 = landingpad { i8*, i32 }
          cleanup
  %1994 = extractvalue { i8*, i32 } %1993, 0
  %1995 = extractvalue { i8*, i32 } %1993, 1
  br label %ehcleanup810

lpad803:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2516
  %1996 = landingpad { i8*, i32 }
          cleanup
  %1997 = extractvalue { i8*, i32 } %1996, 0
  %1998 = extractvalue { i8*, i32 } %1996, 1
  %_M_p.i.i.i.i2629 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 0, i32 0
  %1999 = load i8*, i8** %_M_p.i.i.i.i2629, align 8, !tbaa !51
  %2000 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 2
  %arraydecay.i.i.i.i2630 = bitcast %union.anon* %2000 to i8*
  %cmp.i.i.i2631 = icmp eq i8* %1999, %arraydecay.i.i.i.i2630
  br i1 %cmp.i.i.i2631, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2637, label %if.then.i.i2635

if.then.i.i2635:                                  ; preds = %lpad803
  %_M_allocated_capacity.i.i2632 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 2, i32 0
  %2001 = load i64, i64* %_M_allocated_capacity.i.i2632, align 8, !tbaa !27
  %2002 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp799 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2633 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp799, i64 0, i32 0, i32 0
  %2003 = load i8*, i8** %_M_p.i.i1.i.i2633, align 8, !tbaa !51
  %add.i.i.i2634 = add i64 %2001, 1
  %2004 = bitcast %"class.std::allocator.0"* %2002 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2003) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2637

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2637: ; preds = %if.then.i.i2635, %lpad803
  %2005 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp799 to %"class.std::allocator.0"*
  %2006 = bitcast %"class.std::allocator.0"* %2005 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup807

ehcleanup807:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2637, %lpad.i2514
  %ehselector.slot.45 = phi i32 [ %1998, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2637 ], [ %1886, %lpad.i2514 ]
  %exn.slot.45 = phi i8* [ %1997, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2637 ], [ %1885, %lpad.i2514 ]
  %2007 = bitcast %"class.std::allocator.0"* %ref.tmp800 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1871) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1870) #19
  br label %ehcleanup810

ehcleanup810:                                     ; preds = %ehcleanup807, %lpad796
  %ehselector.slot.46 = phi i32 [ %ehselector.slot.45, %ehcleanup807 ], [ %1995, %lpad796 ]
  %exn.slot.46 = phi i8* [ %exn.slot.45, %ehcleanup807 ], [ %1994, %lpad796 ]
  %_M_p.i.i.i.i2544 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 0, i32 0
  %2008 = load i8*, i8** %_M_p.i.i.i.i2544, align 8, !tbaa !51
  %2009 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 2
  %arraydecay.i.i.i.i2545 = bitcast %union.anon* %2009 to i8*
  %cmp.i.i.i2546 = icmp eq i8* %2008, %arraydecay.i.i.i.i2545
  br i1 %cmp.i.i.i2546, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2552, label %if.then.i.i2550

if.then.i.i2550:                                  ; preds = %ehcleanup810
  %_M_allocated_capacity.i.i2547 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 2, i32 0
  %2010 = load i64, i64* %_M_allocated_capacity.i.i2547, align 8, !tbaa !27
  %2011 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp792 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2548 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp792, i64 0, i32 0, i32 0
  %2012 = load i8*, i8** %_M_p.i.i1.i.i2548, align 8, !tbaa !51
  %add.i.i.i2549 = add i64 %2010, 1
  %2013 = bitcast %"class.std::allocator.0"* %2011 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2012) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2552

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2552: ; preds = %if.then.i.i2550, %ehcleanup810
  %2014 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp792 to %"class.std::allocator.0"*
  %2015 = bitcast %"class.std::allocator.0"* %2014 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup811

ehcleanup811:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2552, %lpad.i2485
  %ehselector.slot.47 = phi i32 [ %ehselector.slot.46, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2552 ], [ %1866, %lpad.i2485 ]
  %exn.slot.47 = phi i8* [ %exn.slot.46, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2552 ], [ %1865, %lpad.i2485 ]
  %2016 = bitcast %"class.std::allocator.0"* %ref.tmp793 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1851) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1850) #19
  br label %ehcleanup900

lpad822:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2581
  %2017 = landingpad { i8*, i32 }
          cleanup
  %2018 = extractvalue { i8*, i32 } %2017, 0
  %2019 = extractvalue { i8*, i32 } %2017, 1
  br label %ehcleanup836

lpad829:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610
  %2020 = landingpad { i8*, i32 }
          cleanup
  %2021 = extractvalue { i8*, i32 } %2020, 0
  %2022 = extractvalue { i8*, i32 } %2020, 1
  %_M_p.i.i.i.i2535 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 0, i32 0
  %2023 = load i8*, i8** %_M_p.i.i.i.i2535, align 8, !tbaa !51
  %2024 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 2
  %arraydecay.i.i.i.i2536 = bitcast %union.anon* %2024 to i8*
  %cmp.i.i.i2537 = icmp eq i8* %2023, %arraydecay.i.i.i.i2536
  br i1 %cmp.i.i.i2537, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2543, label %if.then.i.i2541

if.then.i.i2541:                                  ; preds = %lpad829
  %_M_allocated_capacity.i.i2538 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 2, i32 0
  %2025 = load i64, i64* %_M_allocated_capacity.i.i2538, align 8, !tbaa !27
  %2026 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp825 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2539 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp825, i64 0, i32 0, i32 0
  %2027 = load i8*, i8** %_M_p.i.i1.i.i2539, align 8, !tbaa !51
  %add.i.i.i2540 = add i64 %2025, 1
  %2028 = bitcast %"class.std::allocator.0"* %2026 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2027) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2543

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2543: ; preds = %if.then.i.i2541, %lpad829
  %2029 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp825 to %"class.std::allocator.0"*
  %2030 = bitcast %"class.std::allocator.0"* %2029 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup833

ehcleanup833:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2543, %lpad.i2608
  %ehselector.slot.48 = phi i32 [ %2022, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2543 ], [ %1944, %lpad.i2608 ]
  %exn.slot.48 = phi i8* [ %2021, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2543 ], [ %1943, %lpad.i2608 ]
  %2031 = bitcast %"class.std::allocator.0"* %ref.tmp826 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1929) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1928) #19
  br label %ehcleanup836

ehcleanup836:                                     ; preds = %ehcleanup833, %lpad822
  %ehselector.slot.49 = phi i32 [ %ehselector.slot.48, %ehcleanup833 ], [ %2019, %lpad822 ]
  %exn.slot.49 = phi i8* [ %exn.slot.48, %ehcleanup833 ], [ %2018, %lpad822 ]
  %_M_p.i.i.i.i2450 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 0, i32 0
  %2032 = load i8*, i8** %_M_p.i.i.i.i2450, align 8, !tbaa !51
  %2033 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 2
  %arraydecay.i.i.i.i2451 = bitcast %union.anon* %2033 to i8*
  %cmp.i.i.i2452 = icmp eq i8* %2032, %arraydecay.i.i.i.i2451
  br i1 %cmp.i.i.i2452, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2458, label %if.then.i.i2456

if.then.i.i2456:                                  ; preds = %ehcleanup836
  %_M_allocated_capacity.i.i2453 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 2, i32 0
  %2034 = load i64, i64* %_M_allocated_capacity.i.i2453, align 8, !tbaa !27
  %2035 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp818 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2454 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp818, i64 0, i32 0, i32 0
  %2036 = load i8*, i8** %_M_p.i.i1.i.i2454, align 8, !tbaa !51
  %add.i.i.i2455 = add i64 %2034, 1
  %2037 = bitcast %"class.std::allocator.0"* %2035 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2036) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2458

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2458: ; preds = %if.then.i.i2456, %ehcleanup836
  %2038 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp818 to %"class.std::allocator.0"*
  %2039 = bitcast %"class.std::allocator.0"* %2038 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup837

ehcleanup837:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2458, %lpad.i2579
  %ehselector.slot.50 = phi i32 [ %ehselector.slot.49, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2458 ], [ %1924, %lpad.i2579 ]
  %exn.slot.50 = phi i8* [ %exn.slot.49, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2458 ], [ %1923, %lpad.i2579 ]
  %2040 = bitcast %"class.std::allocator.0"* %ref.tmp819 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %1909) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %1908) #19
  br label %ehcleanup900

if.else840:                                       ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2534
  %call842 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont841 unwind label %lpad548

invoke.cont841:                                   ; preds = %if.else840
  %2041 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp843 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %2041) #19
  %2042 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp844, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %2042) #19
  %2043 = bitcast %"class.std::allocator.0"* %ref.tmp844 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2348 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 0
  %2044 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 2
  %arraydecay.i.i2349 = bitcast %union.anon* %2044 to i8*
  %2045 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2348 to %"class.std::allocator.0"*
  %2046 = bitcast %"class.std::allocator.0"* %2045 to %"class.__gnu_cxx::new_allocator.1"*
  %2047 = bitcast %"class.std::allocator.0"* %ref.tmp844 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2350 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2348, i64 0, i32 0
  store i8* %arraydecay.i.i2349, i8** %_M_p.i.i2350, align 8, !tbaa !48
  %call.i.i2351 = call i64 @strlen(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0)) #19
  %add.ptr.i2352 = getelementptr inbounds i8, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %call.i.i2351
  %cmp.i.i.i.i2353 = icmp eq i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), %add.ptr.i2352
  %2048 = bitcast i64* %__dnew.i.i.i.i2347 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %2048) #19
  %2049 = bitcast i8** %__first.addr.i.i.i.i.i2345 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2049)
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2345, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2354 = ptrtoint i8* %add.ptr.i2352 to i64
  %sub.ptr.sub.i.i.i.i.i.i2355 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2354, ptrtoint ([6 x i8]* @.str.75 to i64)
  %2050 = bitcast i8** %__first.addr.i.i.i.i.i2345 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %2050)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2355, i64* %__dnew.i.i.i.i2347, align 8, !tbaa !50
  %cmp3.i.i.i.i2356 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2355, 15
  br i1 %cmp3.i.i.i.i2356, label %if.then4.i.i.i.i2358, label %if.end6.i.i.i.i2365

if.then4.i.i.i.i2358:                             ; preds = %invoke.cont841
  %call5.i.i.i1.i2357 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp843, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2347, i64 0)
          to label %call5.i.i.i.noexc.i2361 unwind label %lpad.i2371

call5.i.i.i.noexc.i2361:                          ; preds = %if.then4.i.i.i.i2358
  %_M_p.i1.i.i.i.i2359 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2357, i8** %_M_p.i1.i.i.i.i2359, align 8, !tbaa !51
  %2051 = load i64, i64* %__dnew.i.i.i.i2347, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2360 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 2, i32 0
  store i64 %2051, i64* %_M_allocated_capacity.i.i.i.i.i2360, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2365

if.end6.i.i.i.i2365:                              ; preds = %call5.i.i.i.noexc.i2361, %invoke.cont841
  %_M_p.i.i.i.i.i2362 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 0, i32 0
  %2052 = load i8*, i8** %_M_p.i.i.i.i.i2362, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2363 = ptrtoint i8* %add.ptr.i2352 to i64
  %sub.ptr.sub.i.i.i.i.i2364 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2363, ptrtoint ([6 x i8]* @.str.75 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2364, label %if.end.i.i.i.i.i.i.i2367 [
    i64 1, label %if.then.i.i.i.i.i.i2366
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2373
  ]

if.then.i.i.i.i.i.i2366:                          ; preds = %if.end6.i.i.i.i2365
  store i8 84, i8* %2052, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2373

if.end.i.i.i.i.i.i.i2367:                         ; preds = %if.end6.i.i.i.i2365
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %2052, i8* align 1 getelementptr inbounds ([6 x i8], [6 x i8]* @.str.75, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2364, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2373

lpad.i2371:                                       ; preds = %if.then4.i.i.i.i2358
  %2053 = landingpad { i8*, i32 }
          cleanup
  %2054 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp843 to %"class.std::allocator.0"*
  %2055 = bitcast %"class.std::allocator.0"* %2054 to %"class.__gnu_cxx::new_allocator.1"*
  %2056 = extractvalue { i8*, i32 } %2053, 0
  %2057 = extractvalue { i8*, i32 } %2053, 1
  br label %ehcleanup870

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2373: ; preds = %if.end.i.i.i.i.i.i.i2367, %if.then.i.i.i.i.i.i2366, %if.end6.i.i.i.i2365
  %2058 = load i64, i64* %__dnew.i.i.i.i2347, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2368 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 1
  store i64 %2058, i64* %_M_string_length.i.i.i.i.i.i2368, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2369 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 0, i32 0
  %2059 = load i8*, i8** %_M_p.i.i.i.i.i.i2369, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2370 = getelementptr inbounds i8, i8* %2059, i64 %2058
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2346) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2346, align 1, !tbaa !27
  %2060 = load i8, i8* %ref.tmp.i.i.i.i.i2346, align 1, !tbaa !27
  store i8 %2060, i8* %arrayidx.i.i.i.i.i2370, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2346) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %2048) #19
  %call849 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* %call842, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp843)
          to label %invoke.cont848 unwind label %lpad847

invoke.cont848:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2373
  %2061 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp850 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %2061) #19
  %2062 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp851, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %2062) #19
  %2063 = bitcast %"class.std::allocator.0"* %ref.tmp851 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2243 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 0
  %2064 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 2
  %arraydecay.i.i2244 = bitcast %union.anon* %2064 to i8*
  %2065 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2243 to %"class.std::allocator.0"*
  %2066 = bitcast %"class.std::allocator.0"* %2065 to %"class.__gnu_cxx::new_allocator.1"*
  %2067 = bitcast %"class.std::allocator.0"* %ref.tmp851 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2245 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2243, i64 0, i32 0
  store i8* %arraydecay.i.i2244, i8** %_M_p.i.i2245, align 8, !tbaa !48
  %call.i.i2246 = call i64 @strlen(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0)) #19
  %add.ptr.i2247 = getelementptr inbounds i8, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0), i64 %call.i.i2246
  %cmp.i.i.i.i2248 = icmp eq i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0), %add.ptr.i2247
  %2068 = bitcast i64* %__dnew.i.i.i.i2242 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %2068) #19
  %2069 = bitcast i8** %__first.addr.i.i.i.i.i2240 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2069)
  store i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2240, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2249 = ptrtoint i8* %add.ptr.i2247 to i64
  %sub.ptr.sub.i.i.i.i.i.i2250 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2249, ptrtoint ([16 x i8]* @.str.78 to i64)
  %2070 = bitcast i8** %__first.addr.i.i.i.i.i2240 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %2070)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2250, i64* %__dnew.i.i.i.i2242, align 8, !tbaa !50
  %cmp3.i.i.i.i2251 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2250, 15
  br i1 %cmp3.i.i.i.i2251, label %if.then4.i.i.i.i2253, label %if.end6.i.i.i.i2260

if.then4.i.i.i.i2253:                             ; preds = %invoke.cont848
  %call5.i.i.i1.i2252 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp850, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2242, i64 0)
          to label %call5.i.i.i.noexc.i2256 unwind label %lpad.i2266

call5.i.i.i.noexc.i2256:                          ; preds = %if.then4.i.i.i.i2253
  %_M_p.i1.i.i.i.i2254 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2252, i8** %_M_p.i1.i.i.i.i2254, align 8, !tbaa !51
  %2071 = load i64, i64* %__dnew.i.i.i.i2242, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2255 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 2, i32 0
  store i64 %2071, i64* %_M_allocated_capacity.i.i.i.i.i2255, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2260

if.end6.i.i.i.i2260:                              ; preds = %call5.i.i.i.noexc.i2256, %invoke.cont848
  %_M_p.i.i.i.i.i2257 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 0, i32 0
  %2072 = load i8*, i8** %_M_p.i.i.i.i.i2257, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2258 = ptrtoint i8* %add.ptr.i2247 to i64
  %sub.ptr.sub.i.i.i.i.i2259 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2258, ptrtoint ([16 x i8]* @.str.78 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2259, label %if.end.i.i.i.i.i.i.i2262 [
    i64 1, label %if.then.i.i.i.i.i.i2261
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2268
  ]

if.then.i.i.i.i.i.i2261:                          ; preds = %if.end6.i.i.i.i2260
  store i8 84, i8* %2072, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2268

if.end.i.i.i.i.i.i.i2262:                         ; preds = %if.end6.i.i.i.i2260
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %2072, i8* align 1 getelementptr inbounds ([16 x i8], [16 x i8]* @.str.78, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2259, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2268

lpad.i2266:                                       ; preds = %if.then4.i.i.i.i2253
  %2073 = landingpad { i8*, i32 }
          cleanup
  %2074 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp850 to %"class.std::allocator.0"*
  %2075 = bitcast %"class.std::allocator.0"* %2074 to %"class.__gnu_cxx::new_allocator.1"*
  %2076 = extractvalue { i8*, i32 } %2073, 0
  %2077 = extractvalue { i8*, i32 } %2073, 1
  br label %ehcleanup866

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2268: ; preds = %if.end.i.i.i.i.i.i.i2262, %if.then.i.i.i.i.i.i2261, %if.end6.i.i.i.i2260
  %2078 = load i64, i64* %__dnew.i.i.i.i2242, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2263 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 1
  store i64 %2078, i64* %_M_string_length.i.i.i.i.i.i2263, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2264 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 0, i32 0
  %2079 = load i8*, i8** %_M_p.i.i.i.i.i.i2264, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2265 = getelementptr inbounds i8, i8* %2079, i64 %2078
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2241) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2241, align 1, !tbaa !27
  %2080 = load i8, i8* %ref.tmp.i.i.i.i.i2241, align 1, !tbaa !27
  store i8 %2080, i8* %arrayidx.i.i.i.i.i2265, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2241) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %2068) #19
  %2081 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp854 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %2081) #19
  %2082 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp855, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %2082) #19
  %2083 = bitcast %"class.std::allocator.0"* %ref.tmp855 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i2205 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 0
  %2084 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 2
  %arraydecay.i.i2206 = bitcast %union.anon* %2084 to i8*
  %2085 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2205 to %"class.std::allocator.0"*
  %2086 = bitcast %"class.std::allocator.0"* %2085 to %"class.__gnu_cxx::new_allocator.1"*
  %2087 = bitcast %"class.std::allocator.0"* %ref.tmp855 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i2207 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i2205, i64 0, i32 0
  store i8* %arraydecay.i.i2206, i8** %_M_p.i.i2207, align 8, !tbaa !48
  %call.i.i2208 = call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0)) #19
  %add.ptr.i2209 = getelementptr inbounds i8, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i64 %call.i.i2208
  %cmp.i.i.i.i2210 = icmp eq i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), %add.ptr.i2209
  %2088 = bitcast i64* %__dnew.i.i.i.i2204 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %2088) #19
  %2089 = bitcast i8** %__first.addr.i.i.i.i.i2202 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2089)
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i2202, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i2211 = ptrtoint i8* %add.ptr.i2209 to i64
  %sub.ptr.sub.i.i.i.i.i.i2212 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i2211, ptrtoint ([4 x i8]* @.str.68 to i64)
  %2090 = bitcast i8** %__first.addr.i.i.i.i.i2202 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %2090)
  store i64 %sub.ptr.sub.i.i.i.i.i.i2212, i64* %__dnew.i.i.i.i2204, align 8, !tbaa !50
  %cmp3.i.i.i.i2213 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i2212, 15
  br i1 %cmp3.i.i.i.i2213, label %if.then4.i.i.i.i2215, label %if.end6.i.i.i.i2222

if.then4.i.i.i.i2215:                             ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2268
  %call5.i.i.i1.i2214 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp854, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i2204, i64 0)
          to label %call5.i.i.i.noexc.i2218 unwind label %lpad.i2228

call5.i.i.i.noexc.i2218:                          ; preds = %if.then4.i.i.i.i2215
  %_M_p.i1.i.i.i.i2216 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i2214, i8** %_M_p.i1.i.i.i.i2216, align 8, !tbaa !51
  %2091 = load i64, i64* %__dnew.i.i.i.i2204, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i2217 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 2, i32 0
  store i64 %2091, i64* %_M_allocated_capacity.i.i.i.i.i2217, align 8, !tbaa !27
  br label %if.end6.i.i.i.i2222

if.end6.i.i.i.i2222:                              ; preds = %call5.i.i.i.noexc.i2218, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2268
  %_M_p.i.i.i.i.i2219 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 0, i32 0
  %2092 = load i8*, i8** %_M_p.i.i.i.i.i2219, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i2220 = ptrtoint i8* %add.ptr.i2209 to i64
  %sub.ptr.sub.i.i.i.i.i2221 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i2220, ptrtoint ([4 x i8]* @.str.68 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i2221, label %if.end.i.i.i.i.i.i.i2224 [
    i64 1, label %if.then.i.i.i.i.i.i2223
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2230
  ]

if.then.i.i.i.i.i.i2223:                          ; preds = %if.end6.i.i.i.i2222
  store i8 105, i8* %2092, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2230

if.end.i.i.i.i.i.i.i2224:                         ; preds = %if.end6.i.i.i.i2222
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %2092, i8* align 1 getelementptr inbounds ([4 x i8], [4 x i8]* @.str.68, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i2221, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2230

lpad.i2228:                                       ; preds = %if.then4.i.i.i.i2215
  %2093 = landingpad { i8*, i32 }
          cleanup
  %2094 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp854 to %"class.std::allocator.0"*
  %2095 = bitcast %"class.std::allocator.0"* %2094 to %"class.__gnu_cxx::new_allocator.1"*
  %2096 = extractvalue { i8*, i32 } %2093, 0
  %2097 = extractvalue { i8*, i32 } %2093, 1
  br label %ehcleanup862

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2230: ; preds = %if.end.i.i.i.i.i.i.i2224, %if.then.i.i.i.i.i.i2223, %if.end6.i.i.i.i2222
  %2098 = load i64, i64* %__dnew.i.i.i.i2204, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i2225 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 1
  store i64 %2098, i64* %_M_string_length.i.i.i.i.i.i2225, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i2226 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 0, i32 0
  %2099 = load i8*, i8** %_M_p.i.i.i.i.i.i2226, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i2227 = getelementptr inbounds i8, i8* %2099, i64 %2098
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2203) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i2203, align 1, !tbaa !27
  %2100 = load i8, i8* %ref.tmp.i.i.i.i.i2203, align 1, !tbaa !27
  store i8 %2100, i8* %arrayidx.i.i.i.i.i2227, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i2203) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %2088) #19
  %call860 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element* %call849, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp850, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp854)
          to label %invoke.cont859 unwind label %lpad858

invoke.cont859:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2230
  %_M_p.i.i.i.i2184 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 0, i32 0
  %2101 = load i8*, i8** %_M_p.i.i.i.i2184, align 8, !tbaa !51
  %2102 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 2
  %arraydecay.i.i.i.i2185 = bitcast %union.anon* %2102 to i8*
  %cmp.i.i.i2186 = icmp eq i8* %2101, %arraydecay.i.i.i.i2185
  br i1 %cmp.i.i.i2186, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192, label %if.then.i.i2190

if.then.i.i2190:                                  ; preds = %invoke.cont859
  %_M_allocated_capacity.i.i2187 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 2, i32 0
  %2103 = load i64, i64* %_M_allocated_capacity.i.i2187, align 8, !tbaa !27
  %2104 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp854 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2188 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 0, i32 0
  %2105 = load i8*, i8** %_M_p.i.i1.i.i2188, align 8, !tbaa !51
  %add.i.i.i2189 = add i64 %2103, 1
  %2106 = bitcast %"class.std::allocator.0"* %2104 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2105) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192: ; preds = %if.then.i.i2190, %invoke.cont859
  %2107 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp854 to %"class.std::allocator.0"*
  %2108 = bitcast %"class.std::allocator.0"* %2107 to %"class.__gnu_cxx::new_allocator.1"*
  %2109 = bitcast %"class.std::allocator.0"* %ref.tmp855 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %2082) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %2081) #19
  br label %if.end873

lpad847:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2373
  %2110 = landingpad { i8*, i32 }
          cleanup
  %2111 = extractvalue { i8*, i32 } %2110, 0
  %2112 = extractvalue { i8*, i32 } %2110, 1
  br label %ehcleanup869

lpad858:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2230
  %2113 = landingpad { i8*, i32 }
          cleanup
  %2114 = extractvalue { i8*, i32 } %2113, 0
  %2115 = extractvalue { i8*, i32 } %2113, 1
  %_M_p.i.i.i.i2099 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 0, i32 0
  %2116 = load i8*, i8** %_M_p.i.i.i.i2099, align 8, !tbaa !51
  %2117 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 2
  %arraydecay.i.i.i.i2100 = bitcast %union.anon* %2117 to i8*
  %cmp.i.i.i2101 = icmp eq i8* %2116, %arraydecay.i.i.i.i2100
  br i1 %cmp.i.i.i2101, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2107, label %if.then.i.i2105

if.then.i.i2105:                                  ; preds = %lpad858
  %_M_allocated_capacity.i.i2102 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 2, i32 0
  %2118 = load i64, i64* %_M_allocated_capacity.i.i2102, align 8, !tbaa !27
  %2119 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp854 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2103 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp854, i64 0, i32 0, i32 0
  %2120 = load i8*, i8** %_M_p.i.i1.i.i2103, align 8, !tbaa !51
  %add.i.i.i2104 = add i64 %2118, 1
  %2121 = bitcast %"class.std::allocator.0"* %2119 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2120) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2107

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2107: ; preds = %if.then.i.i2105, %lpad858
  %2122 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp854 to %"class.std::allocator.0"*
  %2123 = bitcast %"class.std::allocator.0"* %2122 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup862

ehcleanup862:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2107, %lpad.i2228
  %ehselector.slot.51 = phi i32 [ %2115, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2107 ], [ %2097, %lpad.i2228 ]
  %exn.slot.51 = phi i8* [ %2114, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2107 ], [ %2096, %lpad.i2228 ]
  %2124 = bitcast %"class.std::allocator.0"* %ref.tmp855 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %2082) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %2081) #19
  %_M_p.i.i.i.i2090 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 0, i32 0
  %2125 = load i8*, i8** %_M_p.i.i.i.i2090, align 8, !tbaa !51
  %2126 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 2
  %arraydecay.i.i.i.i2091 = bitcast %union.anon* %2126 to i8*
  %cmp.i.i.i2092 = icmp eq i8* %2125, %arraydecay.i.i.i.i2091
  br i1 %cmp.i.i.i2092, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2098, label %if.then.i.i2096

if.then.i.i2096:                                  ; preds = %ehcleanup862
  %_M_allocated_capacity.i.i2093 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 2, i32 0
  %2127 = load i64, i64* %_M_allocated_capacity.i.i2093, align 8, !tbaa !27
  %2128 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp850 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2094 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850, i64 0, i32 0, i32 0
  %2129 = load i8*, i8** %_M_p.i.i1.i.i2094, align 8, !tbaa !51
  %add.i.i.i2095 = add i64 %2127, 1
  %2130 = bitcast %"class.std::allocator.0"* %2128 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2129) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2098

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2098: ; preds = %if.then.i.i2096, %ehcleanup862
  %2131 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp850 to %"class.std::allocator.0"*
  %2132 = bitcast %"class.std::allocator.0"* %2131 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup866

ehcleanup866:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2098, %lpad.i2266
  %ehselector.slot.52 = phi i32 [ %ehselector.slot.51, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2098 ], [ %2077, %lpad.i2266 ]
  %exn.slot.52 = phi i8* [ %exn.slot.51, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2098 ], [ %2076, %lpad.i2266 ]
  %2133 = bitcast %"class.std::allocator.0"* %ref.tmp851 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %2062) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %2061) #19
  br label %ehcleanup869

ehcleanup869:                                     ; preds = %ehcleanup866, %lpad847
  %ehselector.slot.53 = phi i32 [ %ehselector.slot.52, %ehcleanup866 ], [ %2112, %lpad847 ]
  %exn.slot.53 = phi i8* [ %exn.slot.52, %ehcleanup866 ], [ %2111, %lpad847 ]
  %_M_p.i.i.i.i2072 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 0, i32 0
  %2134 = load i8*, i8** %_M_p.i.i.i.i2072, align 8, !tbaa !51
  %2135 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 2
  %arraydecay.i.i.i.i2073 = bitcast %union.anon* %2135 to i8*
  %cmp.i.i.i2074 = icmp eq i8* %2134, %arraydecay.i.i.i.i2073
  br i1 %cmp.i.i.i2074, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2080, label %if.then.i.i2078

if.then.i.i2078:                                  ; preds = %ehcleanup869
  %_M_allocated_capacity.i.i2075 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 2, i32 0
  %2136 = load i64, i64* %_M_allocated_capacity.i.i2075, align 8, !tbaa !27
  %2137 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp843 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2076 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843, i64 0, i32 0, i32 0
  %2138 = load i8*, i8** %_M_p.i.i1.i.i2076, align 8, !tbaa !51
  %add.i.i.i2077 = add i64 %2136, 1
  %2139 = bitcast %"class.std::allocator.0"* %2137 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2138) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2080

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2080: ; preds = %if.then.i.i2078, %ehcleanup869
  %2140 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp843 to %"class.std::allocator.0"*
  %2141 = bitcast %"class.std::allocator.0"* %2140 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup870

ehcleanup870:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2080, %lpad.i2371
  %ehselector.slot.54 = phi i32 [ %ehselector.slot.53, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2080 ], [ %2057, %lpad.i2371 ]
  %exn.slot.54 = phi i8* [ %exn.slot.53, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2080 ], [ %2056, %lpad.i2371 ]
  %2142 = bitcast %"class.std::allocator.0"* %ref.tmp844 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %2042) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %2041) #19
  br label %ehcleanup900

if.end873:                                        ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610
  %ref.tmp850.sink = phi %"class.std::__cxx11::basic_string"* [ %ref.tmp850, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192 ], [ %ref.tmp825, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610 ]
  %ref.tmp851.sink = phi %"class.std::allocator.0"* [ %ref.tmp851, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192 ], [ %ref.tmp826, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610 ]
  %.sink1097 = phi i8* [ %2062, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192 ], [ %1929, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610 ]
  %.sink1096 = phi i8* [ %2061, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192 ], [ %1928, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610 ]
  %ref.tmp843.sink = phi %"class.std::__cxx11::basic_string"* [ %ref.tmp843, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192 ], [ %ref.tmp818, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610 ]
  %ref.tmp844.sink = phi %"class.std::allocator.0"* [ %ref.tmp844, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192 ], [ %ref.tmp819, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610 ]
  %.sink1095 = phi i8* [ %2042, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192 ], [ %1909, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610 ]
  %.sink1094 = phi i8* [ %2041, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2192 ], [ %1908, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit2610 ]
  %_M_p.i.i.i.i2016 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850.sink, i64 0, i32 0, i32 0
  %2143 = load i8*, i8** %_M_p.i.i.i.i2016, align 8, !tbaa !51
  %2144 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850.sink, i64 0, i32 2
  %arraydecay.i.i.i.i2017 = bitcast %union.anon* %2144 to i8*
  %cmp.i.i.i2018 = icmp eq i8* %2143, %arraydecay.i.i.i.i2017
  br i1 %cmp.i.i.i2018, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2024, label %if.then.i.i2022

if.then.i.i2022:                                  ; preds = %if.end873
  %_M_allocated_capacity.i.i2019 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850.sink, i64 0, i32 2, i32 0
  %2145 = load i64, i64* %_M_allocated_capacity.i.i2019, align 8, !tbaa !27
  %2146 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp850.sink to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i2020 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp850.sink, i64 0, i32 0, i32 0
  %2147 = load i8*, i8** %_M_p.i.i1.i.i2020, align 8, !tbaa !51
  %add.i.i.i2021 = add i64 %2145, 1
  %2148 = bitcast %"class.std::allocator.0"* %2146 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2147) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2024

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2024: ; preds = %if.then.i.i2022, %if.end873
  %2149 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp850.sink to %"class.std::allocator.0"*
  %2150 = bitcast %"class.std::allocator.0"* %2149 to %"class.__gnu_cxx::new_allocator.1"*
  %2151 = bitcast %"class.std::allocator.0"* %ref.tmp851.sink to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %.sink1097) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.sink1096) #19
  %_M_p.i.i.i.i1969 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843.sink, i64 0, i32 0, i32 0
  %2152 = load i8*, i8** %_M_p.i.i.i.i1969, align 8, !tbaa !51
  %2153 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843.sink, i64 0, i32 2
  %arraydecay.i.i.i.i1970 = bitcast %union.anon* %2153 to i8*
  %cmp.i.i.i1971 = icmp eq i8* %2152, %arraydecay.i.i.i.i1970
  br i1 %cmp.i.i.i1971, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1977, label %if.then.i.i1975

if.then.i.i1975:                                  ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2024
  %_M_allocated_capacity.i.i1972 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843.sink, i64 0, i32 2, i32 0
  %2154 = load i64, i64* %_M_allocated_capacity.i.i1972, align 8, !tbaa !27
  %2155 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp843.sink to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1973 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp843.sink, i64 0, i32 0, i32 0
  %2156 = load i8*, i8** %_M_p.i.i1.i.i1973, align 8, !tbaa !51
  %add.i.i.i1974 = add i64 %2154, 1
  %2157 = bitcast %"class.std::allocator.0"* %2155 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2156) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1977

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1977: ; preds = %if.then.i.i1975, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit2024
  %2158 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp843.sink to %"class.std::allocator.0"*
  %2159 = bitcast %"class.std::allocator.0"* %2158 to %"class.__gnu_cxx::new_allocator.1"*
  %2160 = bitcast %"class.std::allocator.0"* %ref.tmp844.sink to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %.sink1095) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.sink1094) #19
  %call875 = invoke %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element* nonnull %654, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %title)
          to label %invoke.cont874 unwind label %lpad548

invoke.cont874:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1977
  %2161 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp876 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %2161) #19
  %2162 = getelementptr inbounds %"class.std::allocator.0", %"class.std::allocator.0"* %ref.tmp877, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %2162) #19
  %2163 = bitcast %"class.std::allocator.0"* %ref.tmp877 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_dataplus.i1905 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 0
  %2164 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 2
  %arraydecay.i.i1906 = bitcast %union.anon* %2164 to i8*
  %2165 = bitcast %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1905 to %"class.std::allocator.0"*
  %2166 = bitcast %"class.std::allocator.0"* %2165 to %"class.__gnu_cxx::new_allocator.1"*
  %2167 = bitcast %"class.std::allocator.0"* %ref.tmp877 to %"class.__gnu_cxx::new_allocator.1"*
  %_M_p.i.i1907 = getelementptr inbounds %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider", %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider"* %_M_dataplus.i1905, i64 0, i32 0
  store i8* %arraydecay.i.i1906, i8** %_M_p.i.i1907, align 8, !tbaa !48
  %call.i.i1908 = call i64 @strlen(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.79, i64 0, i64 0)) #19
  %add.ptr.i1909 = getelementptr inbounds i8, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.79, i64 0, i64 0), i64 %call.i.i1908
  %cmp.i.i.i.i1910 = icmp eq i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.79, i64 0, i64 0), %add.ptr.i1909
  %2168 = bitcast i64* %__dnew.i.i.i.i1904 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %2168) #19
  %2169 = bitcast i8** %__first.addr.i.i.i.i.i1902 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2169)
  store i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.79, i64 0, i64 0), i8** %__first.addr.i.i.i.i.i1902, align 8, !tbaa !49
  %sub.ptr.lhs.cast.i.i.i.i.i.i1911 = ptrtoint i8* %add.ptr.i1909 to i64
  %sub.ptr.sub.i.i.i.i.i.i1912 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i.i1911, ptrtoint ([19 x i8]* @.str.79 to i64)
  %2170 = bitcast i8** %__first.addr.i.i.i.i.i1902 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %2170)
  store i64 %sub.ptr.sub.i.i.i.i.i.i1912, i64* %__dnew.i.i.i.i1904, align 8, !tbaa !50
  %cmp3.i.i.i.i1913 = icmp ugt i64 %sub.ptr.sub.i.i.i.i.i.i1912, 15
  br i1 %cmp3.i.i.i.i1913, label %if.then4.i.i.i.i1915, label %if.end6.i.i.i.i1922

if.then4.i.i.i.i1915:                             ; preds = %invoke.cont874
  %call5.i.i.i1.i1914 = invoke i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"* %ref.tmp876, i64* nonnull dereferenceable(8) %__dnew.i.i.i.i1904, i64 0)
          to label %call5.i.i.i.noexc.i1918 unwind label %lpad.i1928

call5.i.i.i.noexc.i1918:                          ; preds = %if.then4.i.i.i.i1915
  %_M_p.i1.i.i.i.i1916 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 0, i32 0
  store i8* %call5.i.i.i1.i1914, i8** %_M_p.i1.i.i.i.i1916, align 8, !tbaa !51
  %2171 = load i64, i64* %__dnew.i.i.i.i1904, align 8, !tbaa !50
  %_M_allocated_capacity.i.i.i.i.i1917 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 2, i32 0
  store i64 %2171, i64* %_M_allocated_capacity.i.i.i.i.i1917, align 8, !tbaa !27
  br label %if.end6.i.i.i.i1922

if.end6.i.i.i.i1922:                              ; preds = %call5.i.i.i.noexc.i1918, %invoke.cont874
  %_M_p.i.i.i.i.i1919 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 0, i32 0
  %2172 = load i8*, i8** %_M_p.i.i.i.i.i1919, align 8, !tbaa !51
  %sub.ptr.lhs.cast.i.i.i.i.i1920 = ptrtoint i8* %add.ptr.i1909 to i64
  %sub.ptr.sub.i.i.i.i.i1921 = sub i64 %sub.ptr.lhs.cast.i.i.i.i.i1920, ptrtoint ([19 x i8]* @.str.79 to i64)
  switch i64 %sub.ptr.sub.i.i.i.i.i1921, label %if.end.i.i.i.i.i.i.i1924 [
    i64 1, label %if.then.i.i.i.i.i.i1923
    i64 0, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1930
  ]

if.then.i.i.i.i.i.i1923:                          ; preds = %if.end6.i.i.i.i1922
  store i8 84, i8* %2172, align 1, !tbaa !27
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1930

if.end.i.i.i.i.i.i.i1924:                         ; preds = %if.end6.i.i.i.i1922
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %2172, i8* align 1 getelementptr inbounds ([19 x i8], [19 x i8]* @.str.79, i64 0, i64 0), i64 %sub.ptr.sub.i.i.i.i.i1921, i1 false) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1930

lpad.i1928:                                       ; preds = %if.then4.i.i.i.i1915
  %2173 = landingpad { i8*, i32 }
          cleanup
  %2174 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp876 to %"class.std::allocator.0"*
  %2175 = bitcast %"class.std::allocator.0"* %2174 to %"class.__gnu_cxx::new_allocator.1"*
  %2176 = extractvalue { i8*, i32 } %2173, 0
  %2177 = extractvalue { i8*, i32 } %2173, 1
  br label %ehcleanup887

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1930: ; preds = %if.end.i.i.i.i.i.i.i1924, %if.then.i.i.i.i.i.i1923, %if.end6.i.i.i.i1922
  %2178 = load i64, i64* %__dnew.i.i.i.i1904, align 8, !tbaa !50
  %_M_string_length.i.i.i.i.i.i1925 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 1
  store i64 %2178, i64* %_M_string_length.i.i.i.i.i.i1925, align 8, !tbaa !52
  %_M_p.i.i.i.i.i.i1926 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 0, i32 0
  %2179 = load i8*, i8** %_M_p.i.i.i.i.i.i1926, align 8, !tbaa !51
  %arrayidx.i.i.i.i.i1927 = getelementptr inbounds i8, i8* %2179, i64 %2178
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1903) #19
  store i8 0, i8* %ref.tmp.i.i.i.i.i1903, align 1, !tbaa !27
  %2180 = load i8, i8* %ref.tmp.i.i.i.i.i1903, align 1, !tbaa !27
  store i8 %2180, i8* %arrayidx.i.i.i.i.i1927, align 1, !tbaa !27
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %ref.tmp.i.i.i.i.i1903) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %2168) #19
  %2181 = load double, double* %arrayidx541, align 16, !tbaa !42
  %2182 = load i32, i32* %num_iters, align 4, !tbaa !2
  %conv881 = sitofp i32 %2182 to double
  %div882 = fdiv double %2181, %conv881
  %call885 = invoke %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element* %call875, %"class.std::__cxx11::basic_string"* nonnull dereferenceable(32) %ref.tmp876, double %div882)
          to label %invoke.cont884 unwind label %lpad883

invoke.cont884:                                   ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1930
  %_M_p.i.i.i.i1884 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 0, i32 0
  %2183 = load i8*, i8** %_M_p.i.i.i.i1884, align 8, !tbaa !51
  %2184 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 2
  %arraydecay.i.i.i.i1885 = bitcast %union.anon* %2184 to i8*
  %cmp.i.i.i1886 = icmp eq i8* %2183, %arraydecay.i.i.i.i1885
  br i1 %cmp.i.i.i1886, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1892, label %if.then.i.i1890

if.then.i.i1890:                                  ; preds = %invoke.cont884
  %_M_allocated_capacity.i.i1887 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 2, i32 0
  %2185 = load i64, i64* %_M_allocated_capacity.i.i1887, align 8, !tbaa !27
  %2186 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp876 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1888 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 0, i32 0
  %2187 = load i8*, i8** %_M_p.i.i1.i.i1888, align 8, !tbaa !51
  %add.i.i.i1889 = add i64 %2185, 1
  %2188 = bitcast %"class.std::allocator.0"* %2186 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2187) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1892

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1892: ; preds = %if.then.i.i1890, %invoke.cont884
  %2189 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp876 to %"class.std::allocator.0"*
  %2190 = bitcast %"class.std::allocator.0"* %2189 to %"class.__gnu_cxx::new_allocator.1"*
  %2191 = bitcast %"class.std::allocator.0"* %ref.tmp877 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %2162) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %2161) #19
  br label %if.end899

lpad883:                                          ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit1930
  %2192 = landingpad { i8*, i32 }
          cleanup
  %2193 = extractvalue { i8*, i32 } %2192, 0
  %2194 = extractvalue { i8*, i32 } %2192, 1
  %_M_p.i.i.i.i1866 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 0, i32 0
  %2195 = load i8*, i8** %_M_p.i.i.i.i1866, align 8, !tbaa !51
  %2196 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 2
  %arraydecay.i.i.i.i1867 = bitcast %union.anon* %2196 to i8*
  %cmp.i.i.i1868 = icmp eq i8* %2195, %arraydecay.i.i.i.i1867
  br i1 %cmp.i.i.i1868, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1874, label %if.then.i.i1872

if.then.i.i1872:                                  ; preds = %lpad883
  %_M_allocated_capacity.i.i1869 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 2, i32 0
  %2197 = load i64, i64* %_M_allocated_capacity.i.i1869, align 8, !tbaa !27
  %2198 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp876 to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1870 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %ref.tmp876, i64 0, i32 0, i32 0
  %2199 = load i8*, i8** %_M_p.i.i1.i.i1870, align 8, !tbaa !51
  %add.i.i.i1871 = add i64 %2197, 1
  %2200 = bitcast %"class.std::allocator.0"* %2198 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2199) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1874

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1874: ; preds = %if.then.i.i1872, %lpad883
  %2201 = bitcast %"class.std::__cxx11::basic_string"* %ref.tmp876 to %"class.std::allocator.0"*
  %2202 = bitcast %"class.std::allocator.0"* %2201 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup887

ehcleanup887:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1874, %lpad.i1928
  %ehselector.slot.55 = phi i32 [ %2194, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1874 ], [ %2177, %lpad.i1928 ]
  %exn.slot.55 = phi i8* [ %2193, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1874 ], [ %2176, %lpad.i1928 ]
  %2203 = bitcast %"class.std::allocator.0"* %ref.tmp877 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %2162) #19
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %2161) #19
  br label %ehcleanup900

if.end899:                                        ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1892, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2EPKcRKS3_.exit685
  %_M_p.i.i.i.i1781 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 0, i32 0
  %2204 = load i8*, i8** %_M_p.i.i.i.i1781, align 8, !tbaa !51
  %2205 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 2
  %arraydecay.i.i.i.i1782 = bitcast %union.anon* %2205 to i8*
  %cmp.i.i.i1783 = icmp eq i8* %2204, %arraydecay.i.i.i.i1782
  br i1 %cmp.i.i.i1783, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1789, label %if.then.i.i1787

if.then.i.i1787:                                  ; preds = %if.end899
  %_M_allocated_capacity.i.i1784 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 2, i32 0
  %2206 = load i64, i64* %_M_allocated_capacity.i.i1784, align 8, !tbaa !27
  %2207 = bitcast %"class.std::__cxx11::basic_string"* %title to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1785 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 0, i32 0
  %2208 = load i8*, i8** %_M_p.i.i1.i.i1785, align 8, !tbaa !51
  %add.i.i.i1786 = add i64 %2206, 1
  %2209 = bitcast %"class.std::allocator.0"* %2207 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2208) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1789

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1789: ; preds = %if.then.i.i1787, %if.end899
  %2210 = bitcast %"class.std::__cxx11::basic_string"* %title to %"class.std::allocator.0"*
  %2211 = bitcast %"class.std::allocator.0"* %2210 to %"class.__gnu_cxx::new_allocator.1"*
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %631) #19
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %589) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %588) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %587) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %586) #19
  %coefs.i1769 = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %x, i64 0, i32 2
  %2212 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1769, i64 0, i32 0
  %_M_start.i.i1770 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1769, i64 0, i32 0, i32 0, i32 0, i32 0
  %2213 = load double*, double** %_M_start.i.i1770, align 8, !tbaa !40
  %_M_finish.i.i1771 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1769, i64 0, i32 0, i32 0, i32 0, i32 1
  %2214 = load double*, double** %_M_finish.i.i1771, align 8, !tbaa !46
  %2215 = bitcast %"struct.std::_Vector_base.27"* %2212 to %"class.std::allocator.28"*
  %_M_start.i.i.i1772 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %2212, i64 0, i32 0, i32 0, i32 0
  %2216 = load double*, double** %_M_start.i.i.i1772, align 8, !tbaa !40
  %_M_end_of_storage.i.i.i1773 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %2212, i64 0, i32 0, i32 0, i32 2
  %2217 = bitcast double** %_M_end_of_storage.i.i.i1773 to i64*
  %2218 = load i64, i64* %2217, align 8, !tbaa !47
  %sub.ptr.rhs.cast.i.i.i1774 = ptrtoint double* %2216 to i64
  %sub.ptr.sub.i.i.i1775 = sub i64 %2218, %sub.ptr.rhs.cast.i.i.i1774
  %sub.ptr.div.i.i.i1776 = ashr exact i64 %sub.ptr.sub.i.i.i1775, 3
  %tobool.i.i.i.i1777 = icmp eq double* %2216, null
  br i1 %tobool.i.i.i.i1777, label %_ZN6miniFE6VectorIdiiED2Ev.exit1780, label %if.then.i.i.i.i1778

if.then.i.i.i.i1778:                              ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1789
  %2219 = bitcast %"struct.std::_Vector_base.27"* %2212 to %"class.std::allocator.28"*
  %2220 = bitcast %"class.std::allocator.28"* %2219 to %"class.__gnu_cxx::new_allocator.29"*
  %2221 = bitcast double* %2216 to i8*
  call void @_ZdlPv(i8* %2221) #19
  br label %_ZN6miniFE6VectorIdiiED2Ev.exit1780

_ZN6miniFE6VectorIdiiED2Ev.exit1780:              ; preds = %if.then.i.i.i.i1778, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1789
  %2222 = bitcast %"struct.std::_Vector_base.27"* %2212 to %"class.__gnu_cxx::new_allocator.29"*
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %160) #19
  %coefs.i1748 = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %b, i64 0, i32 2
  %2223 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1748, i64 0, i32 0
  %_M_start.i.i1749 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1748, i64 0, i32 0, i32 0, i32 0, i32 0
  %2224 = load double*, double** %_M_start.i.i1749, align 8, !tbaa !40
  %_M_finish.i.i1750 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1748, i64 0, i32 0, i32 0, i32 0, i32 1
  %2225 = load double*, double** %_M_finish.i.i1750, align 8, !tbaa !46
  %2226 = bitcast %"struct.std::_Vector_base.27"* %2223 to %"class.std::allocator.28"*
  %_M_start.i.i.i1751 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %2223, i64 0, i32 0, i32 0, i32 0
  %2227 = load double*, double** %_M_start.i.i.i1751, align 8, !tbaa !40
  %_M_end_of_storage.i.i.i1752 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %2223, i64 0, i32 0, i32 0, i32 2
  %2228 = bitcast double** %_M_end_of_storage.i.i.i1752 to i64*
  %2229 = load i64, i64* %2228, align 8, !tbaa !47
  %sub.ptr.rhs.cast.i.i.i1753 = ptrtoint double* %2227 to i64
  %sub.ptr.sub.i.i.i1754 = sub i64 %2229, %sub.ptr.rhs.cast.i.i.i1753
  %sub.ptr.div.i.i.i1755 = ashr exact i64 %sub.ptr.sub.i.i.i1754, 3
  %tobool.i.i.i.i1756 = icmp eq double* %2227, null
  br i1 %tobool.i.i.i.i1756, label %_ZN6miniFE6VectorIdiiED2Ev.exit1759, label %if.then.i.i.i.i1757

if.then.i.i.i.i1757:                              ; preds = %_ZN6miniFE6VectorIdiiED2Ev.exit1780
  %2230 = bitcast %"struct.std::_Vector_base.27"* %2223 to %"class.std::allocator.28"*
  %2231 = bitcast %"class.std::allocator.28"* %2230 to %"class.__gnu_cxx::new_allocator.29"*
  %2232 = bitcast double* %2227 to i8*
  call void @_ZdlPv(i8* %2232) #19
  br label %_ZN6miniFE6VectorIdiiED2Ev.exit1759

_ZN6miniFE6VectorIdiiED2Ev.exit1759:              ; preds = %if.then.i.i.i.i1757, %_ZN6miniFE6VectorIdiiED2Ev.exit1780
  %2233 = bitcast %"struct.std::_Vector_base.27"* %2223 to %"class.__gnu_cxx::new_allocator.29"*
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %134) #19
  call void @_ZN6miniFE9CSRMatrixIdiiED2Ev(%"struct.miniFE::CSRMatrix"* nonnull %A) #19
  call void @llvm.lifetime.end.p0i8(i64 328, i8* nonnull %29) #19
  %map_ids_to_rows.i1516 = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 2
  %_M_t.i.i1517 = getelementptr inbounds %"class.std::map", %"class.std::map"* %map_ids_to_rows.i1516, i64 0, i32 0
  %2234 = getelementptr inbounds %"class.std::_Rb_tree.17", %"class.std::_Rb_tree.17"* %_M_t.i.i1517, i64 0, i32 0, i32 0, i32 0, i32 0
  %_M_parent.i.i.i.i1518 = getelementptr inbounds i8, i8* %2234, i64 16
  %2235 = bitcast i8* %_M_parent.i.i.i.i1518 to %"struct.std::_Rb_tree_node"**
  %2236 = load %"struct.std::_Rb_tree_node"*, %"struct.std::_Rb_tree_node"** %2235, align 8, !tbaa !55
  invoke void @_ZNSt8_Rb_treeIiSt4pairIKiiESt10_Select1stIS2_ESt4lessIiESaIS2_EE8_M_eraseEPSt13_Rb_tree_nodeIS2_E(%"class.std::_Rb_tree.17"* %_M_t.i.i1517, %"struct.std::_Rb_tree_node"* %2236)
          to label %_ZNSt3mapIiiSt4lessIiESaISt4pairIKiiEEED2Ev.exit.i1523 unwind label %lpad.i.i.i1519

lpad.i.i.i1519:                                   ; preds = %_ZN6miniFE6VectorIdiiED2Ev.exit1759
  %2237 = landingpad { i8*, i32 }
          catch i8* null
  %2238 = extractvalue { i8*, i32 } %2237, 0
  %2239 = bitcast %"class.std::_Rb_tree.17"* %_M_t.i.i1517 to %"class.__gnu_cxx::new_allocator.19"*
  call void @__clang_call_terminate(i8* %2238) #21
  unreachable

_ZNSt3mapIiiSt4lessIiESaISt4pairIKiiEEED2Ev.exit.i1523: ; preds = %_ZN6miniFE6VectorIdiiED2Ev.exit1759
  %2240 = bitcast %"class.std::_Rb_tree.17"* %_M_t.i.i1517 to %"class.__gnu_cxx::new_allocator.19"*
  %bc_rows_1.i1520 = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 1
  %_M_t.i1.i1521 = getelementptr inbounds %"class.std::set", %"class.std::set"* %bc_rows_1.i1520, i64 0, i32 0
  %2241 = getelementptr inbounds %"class.std::_Rb_tree", %"class.std::_Rb_tree"* %_M_t.i1.i1521, i64 0, i32 0, i32 0, i32 0, i32 0
  %_M_parent.i.i.i2.i1522 = getelementptr inbounds i8, i8* %2241, i64 16
  %2242 = bitcast i8* %_M_parent.i.i.i2.i1522 to %"struct.std::_Rb_tree_node.60"**
  %2243 = load %"struct.std::_Rb_tree_node.60"*, %"struct.std::_Rb_tree_node.60"** %2242, align 8, !tbaa !55
  invoke void @_ZNSt8_Rb_treeIiiSt9_IdentityIiESt4lessIiESaIiEE8_M_eraseEPSt13_Rb_tree_nodeIiE(%"class.std::_Rb_tree"* %_M_t.i1.i1521, %"struct.std::_Rb_tree_node.60"* %2243)
          to label %_ZNSt3setIiSt4lessIiESaIiEED2Ev.exit.i1528 unwind label %lpad.i.i3.i1524

lpad.i.i3.i1524:                                  ; preds = %_ZNSt3mapIiiSt4lessIiESaISt4pairIKiiEEED2Ev.exit.i1523
  %2244 = landingpad { i8*, i32 }
          catch i8* null
  %2245 = extractvalue { i8*, i32 } %2244, 0
  %2246 = bitcast %"class.std::_Rb_tree"* %_M_t.i1.i1521 to %"class.__gnu_cxx::new_allocator.15"*
  call void @__clang_call_terminate(i8* %2245) #21
  unreachable

_ZNSt3setIiSt4lessIiESaIiEED2Ev.exit.i1528:       ; preds = %_ZNSt3mapIiiSt4lessIiESaISt4pairIKiiEEED2Ev.exit.i1523
  %2247 = bitcast %"class.std::_Rb_tree"* %_M_t.i1.i1521 to %"class.__gnu_cxx::new_allocator.15"*
  %bc_rows_0.i1525 = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 0
  %_M_t.i4.i1526 = getelementptr inbounds %"class.std::set", %"class.std::set"* %bc_rows_0.i1525, i64 0, i32 0
  %2248 = getelementptr inbounds %"class.std::_Rb_tree", %"class.std::_Rb_tree"* %_M_t.i4.i1526, i64 0, i32 0, i32 0, i32 0, i32 0
  %_M_parent.i.i.i5.i1527 = getelementptr inbounds i8, i8* %2248, i64 16
  %2249 = bitcast i8* %_M_parent.i.i.i5.i1527 to %"struct.std::_Rb_tree_node.60"**
  %2250 = load %"struct.std::_Rb_tree_node.60"*, %"struct.std::_Rb_tree_node.60"** %2249, align 8, !tbaa !55
  invoke void @_ZNSt8_Rb_treeIiiSt9_IdentityIiESt4lessIiESaIiEE8_M_eraseEPSt13_Rb_tree_nodeIiE(%"class.std::_Rb_tree"* %_M_t.i4.i1526, %"struct.std::_Rb_tree_node.60"* %2250)
          to label %_ZN6miniFE23simple_mesh_descriptionIiED2Ev.exit1530 unwind label %lpad.i.i6.i1529

lpad.i.i6.i1529:                                  ; preds = %_ZNSt3setIiSt4lessIiESaIiEED2Ev.exit.i1528
  %2251 = landingpad { i8*, i32 }
          catch i8* null
  %2252 = extractvalue { i8*, i32 } %2251, 0
  %2253 = bitcast %"class.std::_Rb_tree"* %_M_t.i4.i1526 to %"class.__gnu_cxx::new_allocator.15"*
  call void @__clang_call_terminate(i8* %2252) #21
  unreachable

_ZN6miniFE23simple_mesh_descriptionIiED2Ev.exit1530: ; preds = %_ZNSt3setIiSt4lessIiESaIiEED2Ev.exit.i1528
  %2254 = bitcast %"class.std::_Rb_tree"* %_M_t.i4.i1526 to %"class.__gnu_cxx::new_allocator.15"*
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %12) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %7) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %6) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %4) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #19
  ret void

ehcleanup900:                                     ; preds = %ehcleanup887, %ehcleanup870, %ehcleanup837, %ehcleanup811, %ehcleanup787, %ehcleanup762, %ehcleanup740, %ehcleanup718, %ehcleanup703, %ehcleanup690, %ehcleanup675, %ehcleanup653, %ehcleanup638, %ehcleanup625, %ehcleanup610, %ehcleanup588, %ehcleanup573, %ehcleanup560, %lpad548, %ehcleanup499, %ehcleanup486, %lpad475, %ehcleanup472, %ehcleanup461, %ehcleanup428, %ehcleanup395
  %ehselector.slot.57 = phi i32 [ %ehselector.slot.24, %ehcleanup499 ], [ %1120, %lpad475 ], [ %ehselector.slot.23, %ehcleanup486 ], [ %ehselector.slot.22, %ehcleanup472 ], [ %ehselector.slot.21, %ehcleanup461 ], [ %ehselector.slot.17, %ehcleanup428 ], [ %ehselector.slot.13, %ehcleanup395 ], [ %ehselector.slot.55, %ehcleanup887 ], [ %1229, %lpad548 ], [ %ehselector.slot.50, %ehcleanup837 ], [ %ehselector.slot.54, %ehcleanup870 ], [ %ehselector.slot.47, %ehcleanup811 ], [ %ehselector.slot.44, %ehcleanup787 ], [ %ehselector.slot.41, %ehcleanup762 ], [ %ehselector.slot.37, %ehcleanup718 ], [ %ehselector.slot.39, %ehcleanup740 ], [ %ehselector.slot.36, %ehcleanup703 ], [ %ehselector.slot.35, %ehcleanup690 ], [ %ehselector.slot.32, %ehcleanup653 ], [ %ehselector.slot.34, %ehcleanup675 ], [ %ehselector.slot.31, %ehcleanup638 ], [ %ehselector.slot.30, %ehcleanup625 ], [ %ehselector.slot.27, %ehcleanup588 ], [ %ehselector.slot.29, %ehcleanup610 ], [ %ehselector.slot.26, %ehcleanup573 ], [ %ehselector.slot.25, %ehcleanup560 ]
  %exn.slot.57 = phi i8* [ %exn.slot.24, %ehcleanup499 ], [ %1119, %lpad475 ], [ %exn.slot.23, %ehcleanup486 ], [ %exn.slot.22, %ehcleanup472 ], [ %exn.slot.21, %ehcleanup461 ], [ %exn.slot.17, %ehcleanup428 ], [ %exn.slot.13, %ehcleanup395 ], [ %exn.slot.55, %ehcleanup887 ], [ %1228, %lpad548 ], [ %exn.slot.50, %ehcleanup837 ], [ %exn.slot.54, %ehcleanup870 ], [ %exn.slot.47, %ehcleanup811 ], [ %exn.slot.44, %ehcleanup787 ], [ %exn.slot.41, %ehcleanup762 ], [ %exn.slot.37, %ehcleanup718 ], [ %exn.slot.39, %ehcleanup740 ], [ %exn.slot.36, %ehcleanup703 ], [ %exn.slot.35, %ehcleanup690 ], [ %exn.slot.32, %ehcleanup653 ], [ %exn.slot.34, %ehcleanup675 ], [ %exn.slot.31, %ehcleanup638 ], [ %exn.slot.30, %ehcleanup625 ], [ %exn.slot.27, %ehcleanup588 ], [ %exn.slot.29, %ehcleanup610 ], [ %exn.slot.26, %ehcleanup573 ], [ %exn.slot.25, %ehcleanup560 ]
  %_M_p.i.i.i.i1507 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 0, i32 0
  %2255 = load i8*, i8** %_M_p.i.i.i.i1507, align 8, !tbaa !51
  %2256 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 2
  %arraydecay.i.i.i.i1508 = bitcast %union.anon* %2256 to i8*
  %cmp.i.i.i1509 = icmp eq i8* %2255, %arraydecay.i.i.i.i1508
  br i1 %cmp.i.i.i1509, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1515, label %if.then.i.i1513

if.then.i.i1513:                                  ; preds = %ehcleanup900
  %_M_allocated_capacity.i.i1510 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 2, i32 0
  %2257 = load i64, i64* %_M_allocated_capacity.i.i1510, align 8, !tbaa !27
  %2258 = bitcast %"class.std::__cxx11::basic_string"* %title to %"class.std::allocator.0"*
  %_M_p.i.i1.i.i1511 = getelementptr inbounds %"class.std::__cxx11::basic_string", %"class.std::__cxx11::basic_string"* %title, i64 0, i32 0, i32 0
  %2259 = load i8*, i8** %_M_p.i.i1.i.i1511, align 8, !tbaa !51
  %add.i.i.i1512 = add i64 %2257, 1
  %2260 = bitcast %"class.std::allocator.0"* %2258 to %"class.__gnu_cxx::new_allocator.1"*
  call void @_ZdlPv(i8* %2259) #19
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1515

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1515: ; preds = %if.then.i.i1513, %ehcleanup900
  %2261 = bitcast %"class.std::__cxx11::basic_string"* %title to %"class.std::allocator.0"*
  %2262 = bitcast %"class.std::allocator.0"* %2261 to %"class.__gnu_cxx::new_allocator.1"*
  br label %ehcleanup901

ehcleanup901:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1515, %lpad.i683
  %ehselector.slot.58 = phi i32 [ %ehselector.slot.57, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1515 ], [ %647, %lpad.i683 ]
  %exn.slot.58 = phi i8* [ %exn.slot.57, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit1515 ], [ %646, %lpad.i683 ]
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %631) #19
  br label %ehcleanup903

ehcleanup903:                                     ; preds = %ehcleanup901, %lpad339, %lpad312, %lpad305
  %ehselector.slot.60 = phi i32 [ %604, %lpad305 ], [ %ehselector.slot.58, %ehcleanup901 ], [ %607, %lpad312 ], [ %623, %lpad339 ]
  %exn.slot.60 = phi i8* [ %603, %lpad305 ], [ %exn.slot.58, %ehcleanup901 ], [ %606, %lpad312 ], [ %622, %lpad339 ]
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %589) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %588) #19
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %587) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %586) #19
  br label %ehcleanup911

ehcleanup911:                                     ; preds = %ehcleanup903, %lpad301, %lpad281, %lpad272, %lpad243, %lpad206, %lpad197, %ehcleanup187, %ehcleanup165, %ehcleanup146, %ehcleanup124, %lpad90, %lpad81
  %ehselector.slot.64 = phi i32 [ %ehselector.slot.9, %ehcleanup187 ], [ %ehselector.slot.6, %ehcleanup165 ], [ %ehselector.slot.4, %ehcleanup146 ], [ %ehselector.slot.1, %ehcleanup124 ], [ %206, %lpad90 ], [ %193, %lpad81 ], [ %564, %lpad243 ], [ %535, %lpad197 ], [ %548, %lpad206 ], [ %583, %lpad281 ], [ %570, %lpad272 ], [ %ehselector.slot.60, %ehcleanup903 ], [ %601, %lpad301 ]
  %exn.slot.64 = phi i8* [ %exn.slot.9, %ehcleanup187 ], [ %exn.slot.6, %ehcleanup165 ], [ %exn.slot.4, %ehcleanup146 ], [ %exn.slot.1, %ehcleanup124 ], [ %205, %lpad90 ], [ %192, %lpad81 ], [ %563, %lpad243 ], [ %534, %lpad197 ], [ %547, %lpad206 ], [ %582, %lpad281 ], [ %569, %lpad272 ], [ %exn.slot.60, %ehcleanup903 ], [ %600, %lpad301 ]
  %coefs.i1486 = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %x, i64 0, i32 2
  %2263 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1486, i64 0, i32 0
  %_M_start.i.i1487 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1486, i64 0, i32 0, i32 0, i32 0, i32 0
  %2264 = load double*, double** %_M_start.i.i1487, align 8, !tbaa !40
  %_M_finish.i.i1488 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1486, i64 0, i32 0, i32 0, i32 0, i32 1
  %2265 = load double*, double** %_M_finish.i.i1488, align 8, !tbaa !46
  %2266 = bitcast %"struct.std::_Vector_base.27"* %2263 to %"class.std::allocator.28"*
  %_M_start.i.i.i1489 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %2263, i64 0, i32 0, i32 0, i32 0
  %2267 = load double*, double** %_M_start.i.i.i1489, align 8, !tbaa !40
  %_M_end_of_storage.i.i.i1490 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %2263, i64 0, i32 0, i32 0, i32 2
  %2268 = bitcast double** %_M_end_of_storage.i.i.i1490 to i64*
  %2269 = load i64, i64* %2268, align 8, !tbaa !47
  %sub.ptr.rhs.cast.i.i.i1491 = ptrtoint double* %2267 to i64
  %sub.ptr.sub.i.i.i1492 = sub i64 %2269, %sub.ptr.rhs.cast.i.i.i1491
  %sub.ptr.div.i.i.i1493 = ashr exact i64 %sub.ptr.sub.i.i.i1492, 3
  %tobool.i.i.i.i1494 = icmp eq double* %2267, null
  br i1 %tobool.i.i.i.i1494, label %_ZN6miniFE6VectorIdiiED2Ev.exit1497, label %if.then.i.i.i.i1495

if.then.i.i.i.i1495:                              ; preds = %ehcleanup911
  %2270 = bitcast %"struct.std::_Vector_base.27"* %2263 to %"class.std::allocator.28"*
  %2271 = bitcast %"class.std::allocator.28"* %2270 to %"class.__gnu_cxx::new_allocator.29"*
  %2272 = bitcast double* %2267 to i8*
  call void @_ZdlPv(i8* %2272) #19
  br label %_ZN6miniFE6VectorIdiiED2Ev.exit1497

_ZN6miniFE6VectorIdiiED2Ev.exit1497:              ; preds = %if.then.i.i.i.i1495, %ehcleanup911
  %2273 = bitcast %"struct.std::_Vector_base.27"* %2263 to %"class.__gnu_cxx::new_allocator.29"*
  br label %ehcleanup913

ehcleanup913:                                     ; preds = %_ZN6miniFE6VectorIdiiED2Ev.exit1497, %lpad73
  %ehselector.slot.65 = phi i32 [ %ehselector.slot.64, %_ZN6miniFE6VectorIdiiED2Ev.exit1497 ], [ %190, %lpad73 ]
  %exn.slot.65 = phi i8* [ %exn.slot.64, %_ZN6miniFE6VectorIdiiED2Ev.exit1497 ], [ %189, %lpad73 ]
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %160) #19
  %coefs.i1428 = getelementptr inbounds %"struct.miniFE::Vector", %"struct.miniFE::Vector"* %b, i64 0, i32 2
  %2274 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1428, i64 0, i32 0
  %_M_start.i.i1429 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1428, i64 0, i32 0, i32 0, i32 0, i32 0
  %2275 = load double*, double** %_M_start.i.i1429, align 8, !tbaa !40
  %_M_finish.i.i1430 = getelementptr inbounds %"class.std::vector.26", %"class.std::vector.26"* %coefs.i1428, i64 0, i32 0, i32 0, i32 0, i32 1
  %2276 = load double*, double** %_M_finish.i.i1430, align 8, !tbaa !46
  %2277 = bitcast %"struct.std::_Vector_base.27"* %2274 to %"class.std::allocator.28"*
  %_M_start.i.i.i1431 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %2274, i64 0, i32 0, i32 0, i32 0
  %2278 = load double*, double** %_M_start.i.i.i1431, align 8, !tbaa !40
  %_M_end_of_storage.i.i.i1432 = getelementptr inbounds %"struct.std::_Vector_base.27", %"struct.std::_Vector_base.27"* %2274, i64 0, i32 0, i32 0, i32 2
  %2279 = bitcast double** %_M_end_of_storage.i.i.i1432 to i64*
  %2280 = load i64, i64* %2279, align 8, !tbaa !47
  %sub.ptr.rhs.cast.i.i.i1433 = ptrtoint double* %2278 to i64
  %sub.ptr.sub.i.i.i1434 = sub i64 %2280, %sub.ptr.rhs.cast.i.i.i1433
  %sub.ptr.div.i.i.i1435 = ashr exact i64 %sub.ptr.sub.i.i.i1434, 3
  %tobool.i.i.i.i1436 = icmp eq double* %2278, null
  br i1 %tobool.i.i.i.i1436, label %_ZN6miniFE6VectorIdiiED2Ev.exit, label %if.then.i.i.i.i1437

if.then.i.i.i.i1437:                              ; preds = %ehcleanup913
  %2281 = bitcast %"struct.std::_Vector_base.27"* %2274 to %"class.std::allocator.28"*
  %2282 = bitcast %"class.std::allocator.28"* %2281 to %"class.__gnu_cxx::new_allocator.29"*
  %2283 = bitcast double* %2278 to i8*
  call void @_ZdlPv(i8* %2283) #19
  br label %_ZN6miniFE6VectorIdiiED2Ev.exit

_ZN6miniFE6VectorIdiiED2Ev.exit:                  ; preds = %if.then.i.i.i.i1437, %ehcleanup913
  %2284 = bitcast %"struct.std::_Vector_base.27"* %2274 to %"class.__gnu_cxx::new_allocator.29"*
  br label %ehcleanup915

ehcleanup915:                                     ; preds = %_ZN6miniFE6VectorIdiiED2Ev.exit, %eh.resume.i
  %ehselector.slot.66 = phi i32 [ %ehselector.slot.65, %_ZN6miniFE6VectorIdiiED2Ev.exit ], [ %159, %eh.resume.i ]
  %exn.slot.66 = phi i8* [ %exn.slot.65, %_ZN6miniFE6VectorIdiiED2Ev.exit ], [ %158, %eh.resume.i ]
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %134) #19
  br label %ehcleanup918

ehcleanup918:                                     ; preds = %ehcleanup915, %lpad48, %lpad40
  %ehselector.slot.67 = phi i32 [ %ehselector.slot.66, %ehcleanup915 ], [ %127, %lpad48 ], [ %114, %lpad40 ]
  %exn.slot.67 = phi i8* [ %exn.slot.66, %ehcleanup915 ], [ %126, %lpad48 ], [ %113, %lpad40 ]
  call void @_ZN6miniFE9CSRMatrixIdiiED2Ev(%"struct.miniFE::CSRMatrix"* nonnull %A) #19
  call void @llvm.lifetime.end.p0i8(i64 328, i8* nonnull %29) #19
  br label %ehcleanup922

ehcleanup922:                                     ; preds = %ehcleanup918, %lpad17, %lpad
  %ehselector.slot.69 = phi i32 [ %25, %lpad ], [ %ehselector.slot.67, %ehcleanup918 ], [ %28, %lpad17 ]
  %exn.slot.69 = phi i8* [ %24, %lpad ], [ %exn.slot.67, %ehcleanup918 ], [ %27, %lpad17 ]
  %map_ids_to_rows.i = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 2
  %_M_t.i.i = getelementptr inbounds %"class.std::map", %"class.std::map"* %map_ids_to_rows.i, i64 0, i32 0
  %2285 = getelementptr inbounds %"class.std::_Rb_tree.17", %"class.std::_Rb_tree.17"* %_M_t.i.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %_M_parent.i.i.i.i = getelementptr inbounds i8, i8* %2285, i64 16
  %2286 = bitcast i8* %_M_parent.i.i.i.i to %"struct.std::_Rb_tree_node"**
  %2287 = load %"struct.std::_Rb_tree_node"*, %"struct.std::_Rb_tree_node"** %2286, align 8, !tbaa !55
  invoke void @_ZNSt8_Rb_treeIiSt4pairIKiiESt10_Select1stIS2_ESt4lessIiESaIS2_EE8_M_eraseEPSt13_Rb_tree_nodeIS2_E(%"class.std::_Rb_tree.17"* %_M_t.i.i, %"struct.std::_Rb_tree_node"* %2287)
          to label %_ZNSt3mapIiiSt4lessIiESaISt4pairIKiiEEED2Ev.exit.i unwind label %lpad.i.i.i

lpad.i.i.i:                                       ; preds = %ehcleanup922
  %2288 = landingpad { i8*, i32 }
          catch i8* null
  %2289 = extractvalue { i8*, i32 } %2288, 0
  %2290 = bitcast %"class.std::_Rb_tree.17"* %_M_t.i.i to %"class.__gnu_cxx::new_allocator.19"*
  call void @__clang_call_terminate(i8* %2289) #21
  unreachable

_ZNSt3mapIiiSt4lessIiESaISt4pairIKiiEEED2Ev.exit.i: ; preds = %ehcleanup922
  %2291 = bitcast %"class.std::_Rb_tree.17"* %_M_t.i.i to %"class.__gnu_cxx::new_allocator.19"*
  %bc_rows_1.i = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 1
  %_M_t.i1.i = getelementptr inbounds %"class.std::set", %"class.std::set"* %bc_rows_1.i, i64 0, i32 0
  %2292 = getelementptr inbounds %"class.std::_Rb_tree", %"class.std::_Rb_tree"* %_M_t.i1.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %_M_parent.i.i.i2.i = getelementptr inbounds i8, i8* %2292, i64 16
  %2293 = bitcast i8* %_M_parent.i.i.i2.i to %"struct.std::_Rb_tree_node.60"**
  %2294 = load %"struct.std::_Rb_tree_node.60"*, %"struct.std::_Rb_tree_node.60"** %2293, align 8, !tbaa !55
  invoke void @_ZNSt8_Rb_treeIiiSt9_IdentityIiESt4lessIiESaIiEE8_M_eraseEPSt13_Rb_tree_nodeIiE(%"class.std::_Rb_tree"* %_M_t.i1.i, %"struct.std::_Rb_tree_node.60"* %2294)
          to label %_ZNSt3setIiSt4lessIiESaIiEED2Ev.exit.i unwind label %lpad.i.i3.i

lpad.i.i3.i:                                      ; preds = %_ZNSt3mapIiiSt4lessIiESaISt4pairIKiiEEED2Ev.exit.i
  %2295 = landingpad { i8*, i32 }
          catch i8* null
  %2296 = extractvalue { i8*, i32 } %2295, 0
  %2297 = bitcast %"class.std::_Rb_tree"* %_M_t.i1.i to %"class.__gnu_cxx::new_allocator.15"*
  call void @__clang_call_terminate(i8* %2296) #21
  unreachable

_ZNSt3setIiSt4lessIiESaIiEED2Ev.exit.i:           ; preds = %_ZNSt3mapIiiSt4lessIiESaISt4pairIKiiEEED2Ev.exit.i
  %2298 = bitcast %"class.std::_Rb_tree"* %_M_t.i1.i to %"class.__gnu_cxx::new_allocator.15"*
  %bc_rows_0.i = getelementptr inbounds %"class.miniFE::simple_mesh_description", %"class.miniFE::simple_mesh_description"* %mesh, i64 0, i32 0
  %_M_t.i4.i = getelementptr inbounds %"class.std::set", %"class.std::set"* %bc_rows_0.i, i64 0, i32 0
  %2299 = getelementptr inbounds %"class.std::_Rb_tree", %"class.std::_Rb_tree"* %_M_t.i4.i, i64 0, i32 0, i32 0, i32 0, i32 0
  %_M_parent.i.i.i5.i = getelementptr inbounds i8, i8* %2299, i64 16
  %2300 = bitcast i8* %_M_parent.i.i.i5.i to %"struct.std::_Rb_tree_node.60"**
  %2301 = load %"struct.std::_Rb_tree_node.60"*, %"struct.std::_Rb_tree_node.60"** %2300, align 8, !tbaa !55
  invoke void @_ZNSt8_Rb_treeIiiSt9_IdentityIiESt4lessIiESaIiEE8_M_eraseEPSt13_Rb_tree_nodeIiE(%"class.std::_Rb_tree"* %_M_t.i4.i, %"struct.std::_Rb_tree_node.60"* %2301)
          to label %_ZN6miniFE23simple_mesh_descriptionIiED2Ev.exit unwind label %lpad.i.i6.i

lpad.i.i6.i:                                      ; preds = %_ZNSt3setIiSt4lessIiESaIiEED2Ev.exit.i
  %2302 = landingpad { i8*, i32 }
          catch i8* null
  %2303 = extractvalue { i8*, i32 } %2302, 0
  %2304 = bitcast %"class.std::_Rb_tree"* %_M_t.i4.i to %"class.__gnu_cxx::new_allocator.15"*
  call void @__clang_call_terminate(i8* %2303) #21
  unreachable

_ZN6miniFE23simple_mesh_descriptionIiED2Ev.exit:  ; preds = %_ZNSt3setIiSt4lessIiESaIiEED2Ev.exit.i
  %2305 = bitcast %"class.std::_Rb_tree"* %_M_t.i4.i to %"class.__gnu_cxx::new_allocator.15"*
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %12) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %7) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %6) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %4) #19
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #19
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.69, 0
  %lpad.val934 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.69, 1
  resume { i8*, i32 } %lpad.val934
}

declare dso_local %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%class.YAML_Element*, %"class.std::__cxx11::basic_string"* dereferenceable(32), double) local_unnamed_addr #0

declare dso_local void @_ZN8YAML_Doc12generateYAMLB5cxx11Ev(%"class.std::__cxx11::basic_string"* sret, %class.YAML_Doc*) local_unnamed_addr #0

declare dso_local void @_ZN6miniFE12finalize_mpiEv() local_unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZN8YAML_DocD1Ev(%class.YAML_Doc*) unnamed_addr #1

declare dso_local %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_(%class.YAML_Element*, %"class.std::__cxx11::basic_string"* dereferenceable(32), %"class.std::__cxx11::basic_string"* dereferenceable(32)) local_unnamed_addr #0

declare dso_local %class.YAML_Element* @_ZN12YAML_Element3getERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%class.YAML_Element*, %"class.std::__cxx11::basic_string"* dereferenceable(32)) local_unnamed_addr #0

declare dso_local %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEi(%class.YAML_Element*, %"class.std::__cxx11::basic_string"* dereferenceable(32), i32) local_unnamed_addr #0

; Function Attrs: nounwind
declare dso_local i64 @time(i64*) local_unnamed_addr #1

; Function Attrs: nounwind
declare dso_local %struct.tm* @localtime(i64*) local_unnamed_addr #1

; Function Attrs: noinline noreturn nounwind
declare hidden void @__clang_call_terminate(i8*) local_unnamed_addr #9

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1 immarg) #3

declare dso_local i32 @MPI_Irecv(i8*, i32, %struct.ompi_datatype_t*, i32, i32, %struct.ompi_communicator_t*, %struct.ompi_request_t**) local_unnamed_addr #0

declare dso_local i32 @MPI_Comm_size(%struct.ompi_communicator_t*, i32*) local_unnamed_addr #0

declare dso_local i32 @MPI_Comm_rank(%struct.ompi_communicator_t*, i32*) local_unnamed_addr #0

declare dso_local i32 @MPI_Bcast(i8*, i32, %struct.ompi_datatype_t*, i32, %struct.ompi_communicator_t*) local_unnamed_addr #0

declare dso_local i32 @MPI_Allgather(i8*, i32, %struct.ompi_datatype_t*, i8*, i32, %struct.ompi_datatype_t*, %struct.ompi_communicator_t*) local_unnamed_addr #0

declare dso_local i32 @MPI_Allreduce(i8*, i8*, i32, %struct.ompi_datatype_t*, %struct.ompi_op_t*, %struct.ompi_communicator_t*) local_unnamed_addr #0

declare dso_local i32 @MPI_Abort(%struct.ompi_communicator_t*, i32) local_unnamed_addr #0

declare dso_local void @__cxa_call_unexpected(i8*) local_unnamed_addr

declare dso_local void @_ZNSt9basic_iosIcSt11char_traitsIcEE4initEPSt15basic_streambufIcS1_E(%"class.std::basic_ios"*, %"class.std::basic_streambuf"*) local_unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_baseC2Ev(%"class.std::ios_base"*) unnamed_addr #1

; Function Attrs: nounwind
declare dso_local void @_ZNSt6localeC1Ev(%"class.std::locale"*) unnamed_addr #1

; Function Attrs: nounwind
declare dso_local void @_ZNSt6localeD1Ev(%"class.std::locale"*) unnamed_addr #1

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_baseD2Ev(%"class.std::ios_base"*) unnamed_addr #1

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream"* dereferenceable(272), i8*, i64) local_unnamed_addr #0

declare dso_local void @_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate(%"class.std::basic_ios"*, i32) local_unnamed_addr #0

; Function Attrs: argmemonly nofree nounwind readonly
declare dso_local i64 @strlen(i8* nocapture) local_unnamed_addr #10

; Function Attrs: uwtable
declare dso_local void @_ZNKSt7__cxx1115basic_stringbufIcSt11char_traitsIcESaIcEE3strEv(%"class.std::__cxx11::basic_string"* noalias sret, %"class.std::__cxx11::basic_stringbuf"*) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local dereferenceable(32) %"class.std::__cxx11::basic_string"* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6assignIPcvEERS4_T_S8_(%"class.std::__cxx11::basic_string"*, i8*, i8*) local_unnamed_addr #8 align 2

declare dso_local dereferenceable(32) %"class.std::__cxx11::basic_string"* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_replaceEmmPKcm(%"class.std::__cxx11::basic_string"*, i64, i64, i8*, i64) local_unnamed_addr #0

; Function Attrs: noreturn
declare dso_local void @_ZSt24__throw_out_of_range_fmtPKcz(i8*, ...) local_unnamed_addr #11

declare dso_local void @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_assignERKS4_(%"class.std::__cxx11::basic_string"*, %"class.std::__cxx11::basic_string"* dereferenceable(32)) local_unnamed_addr #0

; Function Attrs: noreturn
declare dso_local void @_ZSt20__throw_length_errorPKc(i8*) local_unnamed_addr #11

; Function Attrs: noreturn
declare dso_local void @_ZSt17__throw_bad_allocv() local_unnamed_addr #11

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: nounwind
declare dso_local i32 @_ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE7compareEPKc(%"class.std::__cxx11::basic_string"*, i8*) local_unnamed_addr #1

; Function Attrs: noreturn
declare dso_local void @_ZSt19__throw_logic_errorPKc(i8*) local_unnamed_addr #11

declare dso_local i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string"*, i64* dereferenceable(8), i64) local_unnamed_addr #0

declare dso_local void @__cxa_rethrow() local_unnamed_addr

declare dso_local void @__cxa_end_catch() local_unnamed_addr

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE13add_imbalanceIiEEvRK3BoxRS1_fR8YAML_Doc(%struct.Box* dereferenceable(24), %struct.Box* dereferenceable(24), float, %class.YAML_Doc* dereferenceable(216)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE17compute_imbalanceIiEEvRK3BoxS3_RfS4_R8YAML_Docb(%struct.Box* dereferenceable(24), %struct.Box* dereferenceable(24), float* dereferenceable(4), float* dereferenceable(4), %class.YAML_Doc* dereferenceable(216), i1 zeroext) local_unnamed_addr #8

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo5flushEv(%"class.std::basic_ostream"*) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE23simple_mesh_descriptionIiEC2ERK3BoxS4_(%"class.miniFE::simple_mesh_description"*, %struct.Box* dereferenceable(24), %struct.Box* dereferenceable(24)) unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i32 @_ZN6miniFE25generate_matrix_structureINS_9CSRMatrixIdiiEEEEiRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERS4_(%"class.miniFE::simple_mesh_description"* dereferenceable(192), %"struct.miniFE::CSRMatrix"* dereferenceable(328)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE16assemble_FE_dataINS_9CSRMatrixIdiiEENS_6VectorIdiiEEEEvRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERS6_RT0_RNS_10ParametersE(%"class.miniFE::simple_mesh_description"* dereferenceable(192), %"struct.miniFE::CSRMatrix"* dereferenceable(328), %"struct.miniFE::Vector"* dereferenceable(32), %"struct.miniFE::Parameters"* dereferenceable(96)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE16impose_dirichletINS_9CSRMatrixIdiiEENS_6VectorIdiiEEEEvNT_10ScalarTypeERS5_RT0_iiiRKSt3setINS5_17GlobalOrdinalTypeESt4lessISB_ESaISB_EE(double, %"struct.miniFE::CSRMatrix"* dereferenceable(328), %"struct.miniFE::Vector"* dereferenceable(32), i32, i32, i32, %"class.std::set"* dereferenceable(48)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE17make_local_matrixINS_9CSRMatrixIdiiEEEEvRT_(%"struct.miniFE::CSRMatrix"* dereferenceable(328)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i64 @_ZN6miniFE20compute_matrix_statsINS_9CSRMatrixIdiiEEEEmRKT_iiR8YAML_Doc(%"struct.miniFE::CSRMatrix"* dereferenceable(328), i32, i32, %class.YAML_Doc* dereferenceable(216)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE31rearrange_matrix_local_externalINS_9CSRMatrixIdiiEEEEvRT_(%"struct.miniFE::CSRMatrix"* dereferenceable(328)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE8cg_solveINS_9CSRMatrixIdiiEENS_6VectorIdiiEENS_14matvec_overlapIS2_S4_EEEEvRT_RKT0_RS9_T1_NS7_16LocalOrdinalTypeERNS_10TypeTraitsINS7_10ScalarTypeEE14magnitude_typeERSE_SJ_Pd(%"struct.miniFE::CSRMatrix"* dereferenceable(328), %"struct.miniFE::Vector"* dereferenceable(32), %"struct.miniFE::Vector"* dereferenceable(32), i32, double* dereferenceable(8), i32* dereferenceable(4), double* dereferenceable(8), double*) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE8cg_solveINS_9CSRMatrixIdiiEENS_6VectorIdiiEENS_10matvec_stdIS2_S4_EEEEvRT_RKT0_RS9_T1_NS7_16LocalOrdinalTypeERNS_10TypeTraitsINS7_10ScalarTypeEE14magnitude_typeERSE_SJ_Pd(%"struct.miniFE::CSRMatrix"* dereferenceable(328), %"struct.miniFE::Vector"* dereferenceable(32), %"struct.miniFE::Vector"* dereferenceable(32), i32, double* dereferenceable(8), i32* dereferenceable(4), double* dereferenceable(8), double*) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local i32 @_ZN6miniFE15verify_solutionINS_6VectorIdiiEEEEiRKNS_23simple_mesh_descriptionINT_17GlobalOrdinalTypeEEERKS4_db(%"class.miniFE::simple_mesh_description"* dereferenceable(192), %"struct.miniFE::Vector"* dereferenceable(32), double, i1 zeroext) local_unnamed_addr #8

; Function Attrs: nounwind uwtable
declare dso_local void @_ZN6miniFE9CSRMatrixIdiiED2Ev(%"struct.miniFE::CSRMatrix"*) unnamed_addr #6 align 2

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE18get_global_min_maxIiEEvT_RS1_S2_RiS2_S3_(i32, i32* dereferenceable(4), i32* dereferenceable(4), i32* dereferenceable(4), i32* dereferenceable(4), i32* dereferenceable(4)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIiSaIiEEC2EmRKiRKS0_(%"class.std::vector.21"*, i64, i32* dereferenceable(4), %"class.std::allocator.23"* dereferenceable(1)) unnamed_addr #8 align 2

; Function Attrs: argmemonly nounwind
declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i1 immarg) #3

; Function Attrs: uwtable
declare dso_local float @_ZN6miniFE29compute_std_dev_as_percentageIfEET_S1_S1_(float, float) local_unnamed_addr #8

; Function Attrs: nounwind readnone speculatable
declare float @llvm.fabs.f32(float) #12

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIfSaIfEEC2EmRKfRKS0_(%"class.std::vector.32"*, i64, float* dereferenceable(4), %"class.std::allocator.34"* dereferenceable(1)) unnamed_addr #8 align 2

; Function Attrs: nofree nounwind
declare dso_local float @sqrtf(float) local_unnamed_addr #13

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE20create_map_id_to_rowIiEEviiiRK3BoxRSt3mapIT_S5_St4lessIS5_ESaISt4pairIKS5_S5_EEE(i32, i32, i32, %struct.Box* dereferenceable(24), %"class.std::map"* dereferenceable(48)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE7get_idsIiEEviiiRK3BoxRSt6vectorIT_SaIS5_EEb(i32, i32, i32, %struct.Box* dereferenceable(24), %"class.std::vector.21"* dereferenceable(24), i1 zeroext) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIiSaIiEE7reserveEm(%"class.std::vector.21"*, i64) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_(%"class.std::vector.21"*, i32*, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i64 @_ZNKSt6vectorIiSaIiEE12_M_check_lenEmPKc(%"class.std::vector.21"*, i64, i8*) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIiSaIiEE17_M_default_appendEm(%"class.std::vector.21"*, i64) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local { %"struct.std::_Rb_tree_node_base"*, i8 } @_ZNSt8_Rb_treeIiSt4pairIKiiESt10_Select1stIS2_ESt4lessIiESaIS2_EE17_M_emplace_uniqueIJS0_IiiEEEES0_ISt17_Rb_tree_iteratorIS2_EbEDpOT_(%"class.std::_Rb_tree.17"*, %"struct.std::pair"* dereferenceable(8)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local { %"struct.std::_Rb_tree_node_base"*, %"struct.std::_Rb_tree_node_base"* } @_ZNSt8_Rb_treeIiSt4pairIKiiESt10_Select1stIS2_ESt4lessIiESaIS2_EE24_M_get_insert_unique_posERS1_(%"class.std::_Rb_tree.17"*, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: nounwind readonly
declare dso_local %"struct.std::_Rb_tree_node_base"* @_ZSt18_Rb_tree_decrementPSt18_Rb_tree_node_base(%"struct.std::_Rb_tree_node_base"*) local_unnamed_addr #14

; Function Attrs: nounwind
declare dso_local void @_ZSt29_Rb_tree_insert_and_rebalancebPSt18_Rb_tree_node_baseS0_RS_(i1 zeroext, %"struct.std::_Rb_tree_node_base"*, %"struct.std::_Rb_tree_node_base"*, %"struct.std::_Rb_tree_node_base"* dereferenceable(32)) local_unnamed_addr #1

; Function Attrs: uwtable
declare dso_local { %"struct.std::_Rb_tree_node_base"*, i8 } @_ZNSt8_Rb_treeIiSt4pairIKiiESt10_Select1stIS2_ESt4lessIiESaIS2_EE17_M_emplace_uniqueIJS0_IimEEEES0_ISt17_Rb_tree_iteratorIS2_EbEDpOT_(%"class.std::_Rb_tree.17"*, %"struct.std::pair.44"* dereferenceable(16)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local { %"struct.std::_Rb_tree_node_base"*, i8 } @_ZNSt8_Rb_treeIiiSt9_IdentityIiESt4lessIiESaIiEE16_M_insert_uniqueIiEESt4pairISt17_Rb_tree_iteratorIiEbEOT_(%"class.std::_Rb_tree"*, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local { %"struct.std::_Rb_tree_node_base"*, %"struct.std::_Rb_tree_node_base"* } @_ZNSt8_Rb_treeIiiSt9_IdentityIiESt4lessIiESaIiEE24_M_get_insert_unique_posERKi(%"class.std::_Rb_tree"*, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i32 @_ZN6miniFE15find_row_for_idIiEET_S1_RKSt3mapIS1_S1_St4lessIS1_ESaISt4pairIKS1_S1_EEE(i32, %"class.std::map"* dereferenceable(48)) local_unnamed_addr #8

; Function Attrs: nounwind readonly
declare dso_local %"struct.std::_Rb_tree_node_base"* @_ZSt18_Rb_tree_decrementPKSt18_Rb_tree_node_base(%"struct.std::_Rb_tree_node_base"*) local_unnamed_addr #14

; Function Attrs: uwtable
declare dso_local { %"struct.std::_Rb_tree_node_base"*, i8 } @_ZNSt8_Rb_treeIiiSt9_IdentityIiESt4lessIiESaIiEE16_M_insert_uniqueIRKiEESt4pairISt17_Rb_tree_iteratorIiEbEOT_(%"class.std::_Rb_tree"*, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt8_Rb_treeIiSt4pairIKiiESt10_Select1stIS2_ESt4lessIiESaIS2_EE8_M_eraseEPSt13_Rb_tree_nodeIS2_E(%"class.std::_Rb_tree.17"*, %"struct.std::_Rb_tree_node"*) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt8_Rb_treeIiiSt9_IdentityIiESt4lessIiESaIiEE8_M_eraseEPSt13_Rb_tree_nodeIiE(%"class.std::_Rb_tree"*, %"struct.std::_Rb_tree_node.60"*) local_unnamed_addr #8 align 2

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream"*, double) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo3putEc(%"class.std::basic_ostream"*, i8 signext) local_unnamed_addr #0

; Function Attrs: noreturn
declare dso_local void @_ZSt16__throw_bad_castv() local_unnamed_addr #11

declare dso_local void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype"*) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE9CSRMatrixIdiiE13reserve_spaceEjj(%"struct.miniFE::CSRMatrix"*, i32, i32) local_unnamed_addr #8 align 2

; Function Attrs: nounwind readnone
declare i32 @llvm.eh.typeid.for(i8*) #15

declare dso_local i8* @__cxa_allocate_exception(i64) local_unnamed_addr

declare dso_local void @_ZNSt13runtime_errorC1ERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"class.std::runtime_error"*, %"class.std::__cxx11::basic_string"* dereferenceable(32)) unnamed_addr #0

declare dso_local void @__cxa_free_exception(i8*) local_unnamed_addr

; Function Attrs: nounwind
declare dso_local void @_ZNSt13runtime_errorD1Ev(%"class.std::runtime_error"*) unnamed_addr #1

declare dso_local void @__cxa_throw(i8*, i8*, i8*) local_unnamed_addr

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIiSaIiEEC2EmRKS0_(%"class.std::vector.21"*, i64, %"class.std::allocator.23"* dereferenceable(1)) unnamed_addr #8 align 2

declare dso_local void @_ZNSt13runtime_errorC1EPKc(%"class.std::runtime_error"*, i8*) unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIdSaIdEE7reserveEm(%"class.std::vector.26"*, i64) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZN12MatrixInitOpIN6miniFE9CSRMatrixIdiiEEEC2ERKSt6vectorIiSaIiEES8_S8_iiiiRKNS0_23simple_mesh_descriptionIiEERS2_(%struct.MatrixInitOp*, %"class.std::vector.21"* dereferenceable(24), %"class.std::vector.21"* dereferenceable(24), %"class.std::vector.21"* dereferenceable(24), i32, i32, i32, i32, %"class.miniFE::simple_mesh_description"* dereferenceable(192), %"struct.miniFE::CSRMatrix"* dereferenceable(328)) unnamed_addr #8 align 2

; Function Attrs: argmemonly nounwind
declare token @llvm.syncregion.start() #3

; Function Attrs: inlinehint uwtable
declare dso_local void @_ZN12MatrixInitOpIN6miniFE9CSRMatrixIdiiEEEclEi(%struct.MatrixInitOp*, i32) local_unnamed_addr #16 align 2

; Function Attrs: argmemonly
declare void @llvm.sync.unwind(token) #17

declare dso_local dereferenceable(272) %"class.std::basic_ostream"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream"*, i64) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIdSaIdEE17_M_default_appendEm(%"class.std::vector.26"*, i64) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i64 @_ZNKSt6vectorIdSaIdEE12_M_check_lenEmPKc(%"class.std::vector.26"*, i64, i8*) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZSt16__introsort_loopIPilN9__gnu_cxx5__ops15_Iter_less_iterEEvT_S4_T0_T1_(i32*, i32*, i64) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZSt22__final_insertion_sortIPiN9__gnu_cxx5__ops15_Iter_less_iterEEvT_S4_T0_(i32*, i32*) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZSt13__heap_selectIPiN9__gnu_cxx5__ops15_Iter_less_iterEEvT_S4_S4_T0_(i32*, i32*, i32*) local_unnamed_addr #8

; Function Attrs: inlinehint uwtable
declare dso_local void @_ZSt10__pop_heapIPiN9__gnu_cxx5__ops15_Iter_less_iterEEvT_S4_S4_RT0_(i32*, i32*, i32*, %"struct.__gnu_cxx::__ops::_Iter_less_iter"* dereferenceable(1)) local_unnamed_addr #16

; Function Attrs: uwtable
declare dso_local void @_ZSt13__adjust_heapIPiliN9__gnu_cxx5__ops15_Iter_less_iterEEvT_T0_S5_T1_T2_(i32*, i64, i64, i32) local_unnamed_addr #8

; Function Attrs: nounwind readnone speculatable
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #12

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIdSaIdEEC2EmRKS0_(%"class.std::vector.26"*, i64, %"class.std::allocator.28"* dereferenceable(1)) unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE20perform_element_loopIiNS_9CSRMatrixIdiiEENS_6VectorIdiiEEEEvRKNS_23simple_mesh_descriptionIT_EERK3BoxRT0_RT1_RNS_10ParametersE(%"class.miniFE::simple_mesh_description"* dereferenceable(192), %struct.Box* dereferenceable(24), %"struct.miniFE::CSRMatrix"* dereferenceable(328), %"struct.miniFE::Vector"* dereferenceable(32), %"struct.miniFE::Parameters"* dereferenceable(96)) local_unnamed_addr #8

; Function Attrs: nounwind uwtable
declare dso_local void @_ZN6miniFE4Hex89gradientsIdEEvPKT_PS2_(double*, double*) local_unnamed_addr #6

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE25get_elem_nodes_and_coordsIidEEvRKNS_23simple_mesh_descriptionIT_EES2_PS2_PT0_(%"class.miniFE::simple_mesh_description"* dereferenceable(192), i32, i32*, double*) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE4Hex820diffusionMatrix_symmIdEEvPKT_S4_PS2_(double*, double*, double*) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE4Hex812sourceVectorIdEEvPKT_S4_PS2_(double*, double*, double*) local_unnamed_addr #8

; Function Attrs: nounwind uwtable
declare dso_local void @_ZN6miniFE4Hex827gradients_and_invJ_and_detJIdEEvPKT_S4_PS2_RS2_(double*, double*, double*, double* dereferenceable(8)) local_unnamed_addr #6

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE23sum_in_symm_elem_matrixINS_9CSRMatrixIdiiEEEEvmPKNT_17GlobalOrdinalTypeEPKNS3_10ScalarTypeERS3_(i64, i32*, double*, %"struct.miniFE::CSRMatrix"* dereferenceable(328)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE9CSRMatrixIdiiE16get_row_pointersEiRmRPiRPd(%"struct.miniFE::CSRMatrix"*, i32, i64* dereferenceable(8), i32** dereferenceable(8), double** dereferenceable(8)) local_unnamed_addr #8 align 2

; Function Attrs: nounwind readnone
declare i1 @llvm.is.constant.i64(i64) #15

; Function Attrs: nounwind readonly
declare dso_local %"struct.std::_Rb_tree_node_base"* @_ZSt18_Rb_tree_incrementPKSt18_Rb_tree_node_base(%"struct.std::_Rb_tree_node_base"*) local_unnamed_addr #14

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIP14ompi_request_tSaIS1_EEC2EmRKS2_(%"class.std::vector"*, i64, %"class.std::allocator"* dereferenceable(1)) unnamed_addr #8 align 2

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #18

; Function Attrs: uwtable
declare dso_local %"struct.std::_Rb_tree_node_base"* @_ZNSt8_Rb_treeIiSt4pairIKiiESt10_Select1stIS2_ESt4lessIiESaIS2_EE22_M_emplace_hint_uniqueIJRKSt21piecewise_construct_tSt5tupleIJRS1_EESD_IJEEEEESt17_Rb_tree_iteratorIS2_ESt23_Rb_tree_const_iteratorIS2_EDpOT_(%"class.std::_Rb_tree.17"*, %"struct.std::_Rb_tree_node_base"*, %"struct.std::piecewise_construct_t"* dereferenceable(1), %"class.std::tuple"* dereferenceable(8), %"class.std::tuple.64"* dereferenceable(1)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local { %"struct.std::_Rb_tree_node_base"*, %"struct.std::_Rb_tree_node_base"* } @_ZNSt8_Rb_treeIiSt4pairIKiiESt10_Select1stIS2_ESt4lessIiESaIS2_EE29_M_get_insert_hint_unique_posESt23_Rb_tree_const_iteratorIS2_ERS1_(%"class.std::_Rb_tree.17"*, %"struct.std::_Rb_tree_node_base"*, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: nounwind readonly
declare dso_local %"struct.std::_Rb_tree_node_base"* @_ZSt18_Rb_tree_incrementPSt18_Rb_tree_node_base(%"struct.std::_Rb_tree_node_base"*) local_unnamed_addr #14

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIiSaIiEE17_M_realloc_insertIJRKiEEEvN9__gnu_cxx17__normal_iteratorIPiS1_EEDpOT_(%"class.std::vector.21"*, i32*, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIiSaIiEE14_M_fill_assignEmRKi(%"class.std::vector.21"*, i64, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIP14ompi_request_tSaIS1_EE17_M_default_appendEm(%"class.std::vector"*, i64) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local i64 @_ZNKSt6vectorIP14ompi_request_tSaIS1_EE12_M_check_lenEmPKc(%"class.std::vector"*, i64, i8*) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIdSaIdEE14_M_fill_assignEmRKd(%"class.std::vector.26"*, i64, double* dereferenceable(8)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIdSaIdEEC2EmRKdRKS0_(%"class.std::vector.26"*, i64, double* dereferenceable(8), %"class.std::allocator.28"* dereferenceable(1)) unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIiSaIiEE14_M_fill_insertEN9__gnu_cxx17__normal_iteratorIPiS1_EEmRKi(%"class.std::vector.21"*, i32*, i64, i32* dereferenceable(4)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE18get_global_min_maxIdEEvT_RS1_S2_RiS2_S3_(double, double* dereferenceable(8), double* dereferenceable(8), i32* dereferenceable(4), double* dereferenceable(8), i32* dereferenceable(4)) local_unnamed_addr #8

; Function Attrs: nounwind readnone speculatable
declare double @llvm.ceil.f64(double) #12

declare dso_local %class.YAML_Element* @_ZN12YAML_Element3addERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEm(%class.YAML_Element*, %"class.std::__cxx11::basic_string"* dereferenceable(32), i64) local_unnamed_addr #0

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE6waxpbyINS_6VectorIdiiEEEEvNT_10ScalarTypeERKS3_S4_S6_RS3_(double, %"struct.miniFE::Vector"* dereferenceable(32), double, %"struct.miniFE::Vector"* dereferenceable(32), %"struct.miniFE::Vector"* dereferenceable(32)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE14matvec_overlapINS_9CSRMatrixIdiiEENS_6VectorIdiiEEEclERS2_RS4_S7_(%"struct.miniFE::matvec_overlap"*, %"struct.miniFE::CSRMatrix"* dereferenceable(328), %"struct.miniFE::Vector"* dereferenceable(32), %"struct.miniFE::Vector"* dereferenceable(32)) local_unnamed_addr #8 align 2

; Function Attrs: uwtable
declare dso_local double @_ZN6miniFE3dotINS_6VectorIdiiEEEENS_10TypeTraitsINT_10ScalarTypeEE14magnitude_typeERKS4_S9_(%"struct.miniFE::Vector"* dereferenceable(32), %"struct.miniFE::Vector"* dereferenceable(32)) local_unnamed_addr #8

; Function Attrs: nofree nounwind
declare dso_local double @sqrt(double) local_unnamed_addr #13

; Function Attrs: uwtable
declare dso_local double @_ZN6miniFE6dot_r2INS_6VectorIdiiEEEENS_10TypeTraitsINT_10ScalarTypeEE14magnitude_typeERKS4_(%"struct.miniFE::Vector"* dereferenceable(32)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE6daxpbyINS_6VectorIdiiEEEEvNT_10ScalarTypeERKS3_S4_RS3_(double, %"struct.miniFE::Vector"* dereferenceable(32), double, %"struct.miniFE::Vector"* dereferenceable(32)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE24begin_exchange_externalsINS_9CSRMatrixIdiiEENS_6VectorIdiiEEEEvRT_RT0_(%"struct.miniFE::CSRMatrix"* dereferenceable(328), %"struct.miniFE::Vector"* dereferenceable(32)) local_unnamed_addr #8

; Function Attrs: inlinehint uwtable
declare dso_local void @_ZN6miniFE25finish_exchange_externalsEi(i32) local_unnamed_addr #16

; Function Attrs: argmemonly
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #17

; Function Attrs: uwtable
declare dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIdLb1EEEE14reduce_wrapperEPvS5_S5_(i8*, i8*, i8*) #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIdLb1EEEE16identity_wrapperEPvS5_(i8*, i8*) #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIdLb1EEEE15destroy_wrapperEPvS5_(i8*, i8*) #8 align 2

; Function Attrs: uwtable
declare dso_local i8* @_ZN4cilk8internal12reducer_baseINS_6op_addIdLb1EEEE16allocate_wrapperEPvm(i8*, i64) #8 align 2

; Function Attrs: uwtable
declare dso_local void @_ZN4cilk8internal12reducer_baseINS_6op_addIdLb1EEEE18deallocate_wrapperEPvS5_(i8*, i8*) #8 align 2

declare dso_local void @__cilkrts_hyper_create(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #0

declare dso_local void @__cilkrts_hyper_destroy(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #0

declare dso_local i8* @__cilkrts_hyper_lookup(%struct.__cilkrts_hyperobject_base*) local_unnamed_addr #0

; Function Attrs: nounwind readnone speculatable
declare double @llvm.fabs.f64(double) #12

; Function Attrs: uwtable
declare dso_local void @_ZN6miniFE18exchange_externalsINS_9CSRMatrixIdiiEENS_6VectorIdiiEEEEvRT_RT0_(%"struct.miniFE::CSRMatrix"* dereferenceable(328), %"struct.miniFE::Vector"* dereferenceable(32)) local_unnamed_addr #8

; Function Attrs: uwtable
declare dso_local void @_ZNSt6vectorIdSaIdEE17_M_realloc_insertIJRKdEEEvN9__gnu_cxx17__normal_iteratorIPdS1_EEDpOT_(%"class.std::vector.26"*, double*, double* dereferenceable(8)) local_unnamed_addr #8 align 2

; Function Attrs: nofree nounwind
declare dso_local double @sin(double) local_unnamed_addr #13

; Function Attrs: nofree nounwind
declare dso_local double @sinh(double) local_unnamed_addr #13

; Function Attrs: uwtable
declare dso_local void @_GLOBAL__sub_I_main.cpp() #8 section ".text.startup"

; Function Attrs: nounwind
declare void @llvm.assume(i1) #19

; Function Attrs: argmemonly nounwind
declare token @llvm.taskframe.create() #3

; Function Attrs: argmemonly
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #17

; Function Attrs: argmemonly nounwind
declare void @llvm.taskframe.end(token) #3

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nofree nounwind }
attributes #3 = { argmemonly nounwind }
attributes #4 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { norecurse uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { noinline noreturn nounwind }
attributes #10 = { argmemonly nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #12 = { nounwind readnone speculatable }
attributes #13 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #14 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { nounwind readnone }
attributes #16 = { inlinehint uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #17 = { argmemonly }
attributes #18 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #19 = { nounwind }
attributes #20 = { noreturn }
attributes #21 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (git@github.com:OpenCilk/opencilk-project.git 63d5833d23da0b4e9cfa751d114c34e512bf9846)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !8, i64 24}
!7 = !{!"_ZTSN6miniFE10ParametersE", !3, i64 0, !3, i64 4, !3, i64 8, !3, i64 12, !3, i64 16, !3, i64 20, !8, i64 24, !9, i64 32, !3, i64 64, !3, i64 68, !3, i64 72, !3, i64 76, !3, i64 80, !3, i64 84, !3, i64 88}
!8 = !{!"float", !4, i64 0}
!9 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", !10, i64 0, !12, i64 8, !4, i64 16}
!10 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_Alloc_hiderE", !11, i64 0}
!11 = !{!"any pointer", !4, i64 0}
!12 = !{!"long", !4, i64 0}
!13 = !{!8, !8, i64 0}
!14 = !{!15, !15, i64 0}
!15 = !{!"vtable pointer", !5, i64 0}
!16 = !{!17, !12, i64 16}
!17 = !{!"_ZTSSt8ios_base", !12, i64 8, !12, i64 16, !18, i64 24, !19, i64 28, !19, i64 32, !11, i64 40, !20, i64 48, !4, i64 64, !3, i64 192, !11, i64 200, !21, i64 208}
!18 = !{!"_ZTSSt13_Ios_Fmtflags", !4, i64 0}
!19 = !{!"_ZTSSt12_Ios_Iostate", !4, i64 0}
!20 = !{!"_ZTSNSt8ios_base6_WordsE", !11, i64 0, !12, i64 8}
!21 = !{!"_ZTSSt6locale", !11, i64 0}
!22 = !{!23, !11, i64 240}
!23 = !{!"_ZTSSt9basic_iosIcSt11char_traitsIcEE", !11, i64 216, !4, i64 224, !24, i64 225, !11, i64 232, !11, i64 240, !11, i64 248, !11, i64 256}
!24 = !{!"bool", !4, i64 0}
!25 = !{!26, !4, i64 56}
!26 = !{!"_ZTSSt5ctypeIcE", !11, i64 16, !24, i64 24, !11, i64 32, !11, i64 40, !11, i64 48, !4, i64 56, !4, i64 57, !4, i64 313, !4, i64 569}
!27 = !{!4, !4, i64 0}
!28 = !{!29, !24, i64 0}
!29 = !{!"_ZTSN6miniFE9CSRMatrixIdiiEE", !24, i64 0, !30, i64 8, !30, i64 32, !30, i64 56, !30, i64 80, !31, i64 104, !3, i64 128, !30, i64 136, !30, i64 160, !30, i64 184, !30, i64 208, !30, i64 232, !30, i64 256, !31, i64 280, !32, i64 304}
!30 = !{!"_ZTSSt6vectorIiSaIiEE"}
!31 = !{!"_ZTSSt6vectorIdSaIdEE"}
!32 = !{!"_ZTSSt6vectorIP14ompi_request_tSaIS1_EE"}
!33 = !{!29, !3, i64 128}
!34 = !{!35, !11, i64 8}
!35 = !{!"_ZTSNSt12_Vector_baseIiSaIiEE17_Vector_impl_dataE", !11, i64 0, !11, i64 8, !11, i64 16}
!36 = !{!35, !11, i64 0}
!37 = !{!38, !3, i64 0}
!38 = !{!"_ZTSN6miniFE6VectorIdiiEE", !3, i64 0, !3, i64 4, !31, i64 8}
!39 = !{!38, !3, i64 4}
!40 = !{!41, !11, i64 0}
!41 = !{!"_ZTSNSt12_Vector_baseIdSaIdEE17_Vector_impl_dataE", !11, i64 0, !11, i64 8, !11, i64 16}
!42 = !{!43, !43, i64 0}
!43 = !{!"double", !4, i64 0}
!44 = distinct !{!44, !45}
!45 = !{!"tapir.loop.spawn.strategy", i32 1}
!46 = !{!41, !11, i64 8}
!47 = !{!41, !11, i64 16}
!48 = !{!10, !11, i64 0}
!49 = !{!11, !11, i64 0}
!50 = !{!12, !12, i64 0}
!51 = !{!9, !11, i64 0}
!52 = !{!9, !12, i64 8}
!53 = !{!7, !3, i64 16}
!54 = !{!7, !3, i64 72}
!55 = !{!56, !11, i64 8}
!56 = !{!"_ZTSSt15_Rb_tree_header", !57, i64 0, !12, i64 32}
!57 = !{!"_ZTSSt18_Rb_tree_node_base", !58, i64 0, !11, i64 8, !11, i64 16, !11, i64 24}
!58 = !{!"_ZTSSt14_Rb_tree_color", !4, i64 0}
