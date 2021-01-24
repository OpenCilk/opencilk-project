; Check that LCSSA on Tapir loops with detach-unwind destinations
; properly inserts PHI nodes in exit blocks that inherit the same
; value from the detach and detached.rethrow predecessors.
;
; RUN: opt < %s -lcssa -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-LCSSA
; RUN: opt < %s -passes='lcssa' -S -o - | FileCheck %s --check-prefixes=CHECK,CHECK-LCSSA
; RUN: opt < %s -lcssa -licm -S -o - | FileCheck %s
; RUN: opt < %s -passes='lcssa,require<opt-remark-emit>,loop-mssa(licm)' -S -o - | FileCheck %s


target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init.0.239.468.697" = type { i8 }
%"struct.pbbs::mem_pool.4.243.472.701" = type { %"class.pbbs::concurrent_stack.1.240.469.698"*, %"struct.std::atomic.3.242.471.700", %"struct.std::atomic.3.242.471.700", i64 }
%"class.pbbs::concurrent_stack.1.240.469.698" = type opaque
%"struct.std::atomic.3.242.471.700" = type { %"struct.std::__atomic_base.2.241.470.699" }
%"struct.std::__atomic_base.2.241.470.699" = type { i64 }
%"class.std::__cxx11::basic_string.7.246.475.704" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider.5.244.473.702", i64, %union.anon.6.245.474.703 }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider.5.244.473.702" = type { i8* }
%union.anon.6.245.474.703 = type { i64, [8 x i8] }
%"struct.pbbs::timer.8.247.476.705" = type { double, double, i8, %"class.std::__cxx11::basic_string.7.246.475.704" }
%"class.std::basic_ostream.23.262.491.720" = type { i32 (...)**, %"class.std::basic_ios.22.261.490.719" }
%"class.std::basic_ios.22.261.490.719" = type { %"class.std::ios_base.14.253.482.711", %"class.std::basic_ostream.23.262.491.720"*, i8, i8, %"class.std::basic_streambuf.15.254.483.712"*, %"class.std::ctype.19.258.487.716"*, %"class.std::num_put.20.259.488.717"*, %"class.std::num_get.21.260.489.718"* }
%"class.std::ios_base.14.253.482.711" = type { i32 (...)**, i64, i64, i32, i32, i32, %"struct.std::ios_base::_Callback_list.9.248.477.706"*, %"struct.std::ios_base::_Words.10.249.478.707", [8 x %"struct.std::ios_base::_Words.10.249.478.707"], i32, %"struct.std::ios_base::_Words.10.249.478.707"*, %"class.std::locale.13.252.481.710" }
%"struct.std::ios_base::_Callback_list.9.248.477.706" = type { %"struct.std::ios_base::_Callback_list.9.248.477.706"*, void (i32, %"class.std::ios_base.14.253.482.711"*, i32)*, i32, i32 }
%"struct.std::ios_base::_Words.10.249.478.707" = type { i8*, i64 }
%"class.std::locale.13.252.481.710" = type { %"class.std::locale::_Impl.12.251.480.709"* }
%"class.std::locale::_Impl.12.251.480.709" = type { i32, %"class.std::locale::facet.11.250.479.708"**, i64, %"class.std::locale::facet.11.250.479.708"**, i8** }
%"class.std::locale::facet.11.250.479.708" = type <{ i32 (...)**, i32, [4 x i8] }>
%"class.std::basic_streambuf.15.254.483.712" = type { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, %"class.std::locale.13.252.481.710" }
%"class.std::ctype.19.258.487.716" = type <{ %"class.std::locale::facet.base.16.255.484.713", [4 x i8], %struct.__locale_struct.18.257.486.715*, i8, [7 x i8], i32*, i32*, i16*, i8, [256 x i8], [256 x i8], i8, [6 x i8] }>
%"class.std::locale::facet.base.16.255.484.713" = type <{ i32 (...)**, i32 }>
%struct.__locale_struct.18.257.486.715 = type { [13 x %struct.__locale_data.17.256.485.714*], i16*, i32*, i32*, [13 x i8*] }
%struct.__locale_data.17.256.485.714 = type opaque
%"class.std::num_put.20.259.488.717" = type { %"class.std::locale::facet.base.16.255.484.713", [4 x i8] }
%"class.std::num_get.21.260.489.718" = type { %"class.std::locale::facet.base.16.255.484.713", [4 x i8] }
%"class.pbbs::concurrent_stack.10.26.265.494.723" = type { %"class.pbbs::concurrent_stack<pbbs::list_allocator<gbbs::em_data_block>::block *>::prim_concurrent_stack.25.264.493.722", %"class.pbbs::concurrent_stack<pbbs::list_allocator<gbbs::em_data_block>::block *>::prim_concurrent_stack.25.264.493.722" }
%"class.pbbs::concurrent_stack<pbbs::list_allocator<gbbs::em_data_block>::block *>::prim_concurrent_stack.25.264.493.722" = type { %"union.pbbs::concurrent_stack<pbbs::list_allocator<gbbs::em_data_block>::block *>::prim_concurrent_stack::CAS_t.24.263.492.721", [48 x i8] }
%"union.pbbs::concurrent_stack<pbbs::list_allocator<gbbs::em_data_block>::block *>::prim_concurrent_stack::CAS_t.24.263.492.721" = type { i128 }
%struct._IO_FILE.30.269.498.727 = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker.27.266.495.724*, %struct._IO_FILE.30.269.498.727*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt.28.267.496.725*, %struct._IO_wide_data.29.268.497.726*, %struct._IO_FILE.30.269.498.727*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker.27.266.495.724 = type opaque
%struct._IO_codecvt.28.267.496.725 = type opaque
%struct._IO_wide_data.29.268.497.726 = type opaque
%"struct.std::atomic.25.32.271.500.729" = type { %"struct.std::__atomic_base.26.31.270.499.728" }
%"struct.std::__atomic_base.26.31.270.499.728" = type { i64 }
%"struct.pbbs::list_allocator<gbbs::em_data_block>::thread_list.35.274.503.732" = type { i64, %"union.pbbs::list_allocator<gbbs::em_data_block>::block.34.273.502.731"*, %"union.pbbs::list_allocator<gbbs::em_data_block>::block.34.273.502.731"*, [4096 x i8], [40 x i8] }
%"union.pbbs::list_allocator<gbbs::em_data_block>::block.34.273.502.731" = type { %"struct.gbbs::em_data_block.33.272.501.730" }
%"struct.gbbs::em_data_block.33.272.501.730" = type { i64, [16384 x i8] }
%"struct.pbbslib::atomic_max_counter.36.275.504.733" = type { i32 }
%"struct.pbbslib::atomic_sum_counter.37.276.505.734" = type { i64*, i64, i64, i64 }
%"struct.std::pair.171.38.277.506.735" = type { i32, i32 }
%"struct.pbbs::sequence.39.278.507.736" = type { i32*, i64 }
%"class.std::tuple.44.283.512.741" = type { %"struct.std::_Tuple_impl.43.282.511.740" }
%"struct.std::_Tuple_impl.43.282.511.740" = type { %"struct.std::_Tuple_impl.0.41.280.509.738", %"struct.std::_Head_base.1.42.281.510.739" }
%"struct.std::_Tuple_impl.0.41.280.509.738" = type { %"struct.std::_Head_base.40.279.508.737" }
%"struct.std::_Head_base.40.279.508.737" = type { i32 }
%"struct.std::_Head_base.1.42.281.510.739" = type { i32 }
%"class.std::vector.48.287.516.745" = type { %"struct.std::_Vector_base.47.286.515.744" }
%"struct.std::_Vector_base.47.286.515.744" = type { %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl.46.285.514.743" }
%"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl.46.285.514.743" = type { %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl_data.45.284.513.742" }
%"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl_data.45.284.513.742" = type { double*, double*, double* }
%"struct.gbbs::commandLine.49.288.517.746" = type { i32, i8**, %"class.std::__cxx11::basic_string.7.246.475.704" }
%"struct.gbbs::symmetric_graph.55.294.523.752" = type { %"struct.gbbs::vertex_data.50.289.518.747"*, i8*, i8*, i64, i64, %"class.std::function.54.293.522.751" }
%"struct.gbbs::vertex_data.50.289.518.747" = type { i64, i32 }
%"class.std::function.54.293.522.751" = type { %"class.std::_Function_base.53.292.521.750", void (%"union.std::_Any_data.52.291.520.749"*)* }
%"class.std::_Function_base.53.292.521.750" = type { %"union.std::_Any_data.52.291.520.749", i1 (%"union.std::_Any_data.52.291.520.749"*, %"union.std::_Any_data.52.291.520.749"*, i32)* }
%"union.std::_Any_data.52.291.520.749" = type { %"union.std::_Nocopy_types.51.290.519.748" }
%"union.std::_Nocopy_types.51.290.519.748" = type { { i64, i64 } }
%"struct.gbbs::symmetric_graph.5.58.297.526.755" = type { %"struct.gbbs::vertex_data.50.289.518.747"*, %"class.std::tuple.6.57.296.525.754"*, %"class.std::tuple.6.57.296.525.754"*, i64, i64, %"class.std::function.54.293.522.751" }
%"class.std::tuple.6.57.296.525.754" = type { %"struct.std::_Tuple_impl.7.56.295.524.753" }
%"struct.std::_Tuple_impl.7.56.295.524.753" = type { %"struct.std::_Head_base.1.42.281.510.739" }
%"class.std::tuple.11.63.302.531.760" = type { %"struct.std::_Tuple_impl.12.62.301.530.759" }
%"struct.std::_Tuple_impl.12.62.301.530.759" = type { %"struct.std::_Tuple_impl.13.60.299.528.757", %"struct.std::_Head_base.15.61.300.529.758" }
%"struct.std::_Tuple_impl.13.60.299.528.757" = type { %"struct.std::_Head_base.14.59.298.527.756" }
%"struct.std::_Head_base.14.59.298.527.756" = type { i64 }
%"struct.std::_Head_base.15.61.300.529.758" = type { i8* }
%class.anon.22.64.303.532.761 = type { %"struct.gbbs::vertex_data.50.289.518.747"*, i8*, i64 }
%"struct.pbbs::sequence.28.65.304.533.762" = type { %"struct.gbbs::em_data_block.33.272.501.730"**, i64 }
%class.anon.38.69.308.537.766 = type { %"struct.pbbs::sequence.32.66.305.534.763"*, %"struct.pbbs::range.67.306.535.764"*, %"struct.pbbs::random.68.307.536.765"* }
%"struct.pbbs::sequence.32.66.305.534.763" = type { i64*, i64 }
%"struct.pbbs::range.67.306.535.764" = type { %"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.gbbs::em_data_block.33.272.501.730"** }
%"struct.pbbs::random.68.307.536.765" = type { i64 }
%"struct.std::pair.70.309.538.767" = type <{ %"struct.pbbs::sequence.32.66.305.534.763", i8, [7 x i8] }>
%"struct.pbbs::delayed_sequence.72.311.540.769" = type { %class.anon.31.71.310.539.768, i64, i64 }
%class.anon.31.71.310.539.768 = type { %"struct.pbbs::random.68.307.536.765"*, i64* }
%class.anon.39.73.312.541.770 = type { i64*, i64*, %"struct.pbbs::sequence.28.65.304.533.762"*, %"struct.pbbs::delayed_sequence.72.311.540.769"*, i32**, i64* }
%class.anon.40.74.313.542.771 = type { i64*, i32**, i64*, %"struct.pbbs::sequence.32.66.305.534.763"* }
%class.anon.42.75.314.543.772 = type { %"struct.pbbs::sequence.32.66.305.534.763"*, i64*, %"struct.pbbs::sequence.39.278.507.736"*, i32**, i64* }
%class.anon.43.76.315.544.773 = type { i64*, i32**, %"struct.pbbs::sequence.39.278.507.736"*, i64* }
%class.anon.44.77.316.545.774 = type { i64*, i64*, %"struct.pbbs::sequence.28.65.304.533.762"*, %"struct.pbbs::range.67.306.535.764"*, %"struct.pbbs::delayed_sequence.72.311.540.769"*, i32**, i64* }
%"struct.pbbs::range.41.78.317.546.775" = type { i64*, i64* }
%"struct.pbbs::addm.79.318.547.776" = type { i64 }
%class.anon.47.81.320.549.778 = type { i64*, i64*, %class.anon.45.80.319.548.777* }
%class.anon.45.80.319.548.777 = type { %"struct.pbbs::range.41.78.317.546.775"*, %"struct.pbbs::range.41.78.317.546.775"*, %"struct.pbbs::addm.79.318.547.776"* }
%class.anon.48.83.322.551.780 = type { i64*, i64*, %class.anon.46.82.321.550.779* }
%class.anon.46.82.321.550.779 = type { %"struct.pbbs::range.41.78.317.546.775"*, %"struct.pbbs::range.41.78.317.546.775"*, %"struct.pbbs::addm.79.318.547.776"*, %"struct.pbbs::range.41.78.317.546.775"*, i32* }
%class.anon.49.84.323.552.781 = type { i64*, i64*, %"struct.pbbs::sequence.28.65.304.533.762"*, %"struct.pbbs::delayed_sequence.72.311.540.769"*, i64**, i64* }
%class.anon.50.85.324.553.782 = type { i64*, i64**, i64*, %"struct.pbbs::sequence.32.66.305.534.763"* }
%class.anon.51.86.325.554.783 = type { %"struct.pbbs::sequence.32.66.305.534.763"*, i64*, %"struct.pbbs::sequence.32.66.305.534.763"*, i64**, i64* }
%class.anon.52.87.326.555.784 = type { i64*, i64**, %"struct.pbbs::sequence.32.66.305.534.763"*, i64* }
%class.anon.53.88.327.556.785 = type { i64*, i64*, %"struct.pbbs::sequence.28.65.304.533.762"*, %"struct.pbbs::range.67.306.535.764"*, %"struct.pbbs::delayed_sequence.72.311.540.769"*, i64**, i64* }
%"struct.pbbs::sequence.62.94.333.562.791" = type { %"class.std::tuple.63.93.332.561.790"*, i64 }
%"class.std::tuple.63.93.332.561.790" = type { %"struct.std::_Tuple_impl.64.92.331.560.789" }
%"struct.std::_Tuple_impl.64.92.331.560.789" = type { %"struct.std::_Tuple_impl.65.91.330.559.788", %"struct.std::_Head_base.1.42.281.510.739" }
%"struct.std::_Tuple_impl.65.91.330.559.788" = type { %"struct.std::_Tuple_impl.66.90.329.558.787", %"struct.std::_Head_base.40.279.508.737" }
%"struct.std::_Tuple_impl.66.90.329.558.787" = type { %"struct.std::_Head_base.67.89.328.557.786" }
%"struct.std::_Head_base.67.89.328.557.786" = type { i32 }
%"struct.pbbs::sequence.61.95.334.563.792" = type { %"class.std::tuple.44.283.512.741"*, i64 }
%"struct.gbbs::edge_array.99.338.567.796" = type { %"class.std::tuple.56.98.337.566.795"*, i64, i64, i64, i64, i64 }
%"class.std::tuple.56.98.337.566.795" = type { %"struct.std::_Tuple_impl.57.97.336.565.794" }
%"struct.std::_Tuple_impl.57.97.336.565.794" = type { %"struct.std::_Tuple_impl.58.96.335.564.793", %"struct.std::_Head_base.1.42.281.510.739" }
%"struct.std::_Tuple_impl.58.96.335.564.793" = type { %"struct.std::_Head_base.40.279.508.737" }
%class.anon.55.101.340.569.798 = type { %class.anon.54.100.339.568.797*, double* }
%class.anon.54.100.339.568.797 = type { i8 }
%class.anon.87.108.347.576.805 = type { %"struct.pbbs::sequence.68.105.344.573.802"*, %"struct.pbbs::sequence.86.106.345.574.803"*, %"struct.pbbs::sequence.85.107.346.575.804"*, %"struct.gbbs::symmetric_graph.55.294.523.752"*, %class.anon.55.101.340.569.798* }
%"struct.pbbs::sequence.68.105.344.573.802" = type { %"class.std::tuple.69.104.343.572.801"*, i64 }
%"class.std::tuple.69.104.343.572.801" = type { %"struct.std::_Tuple_impl.70.103.342.571.800" }
%"struct.std::_Tuple_impl.70.103.342.571.800" = type { %"struct.std::_Tuple_impl.13.60.299.528.757", %"struct.std::_Head_base.71.102.341.570.799" }
%"struct.std::_Head_base.71.102.341.570.799" = type { i64 }
%"struct.pbbs::sequence.86.106.345.574.803" = type { %"class.std::tuple.6.57.296.525.754"*, i64 }
%"struct.pbbs::sequence.85.107.346.575.804" = type { %"class.std::tuple.56.98.337.566.795"*, i64 }
%class.anon.72.109.348.577.806 = type { %class.anon.55.101.340.569.798* }
%"struct.pbbs::monoid.111.350.579.808" = type { %class.anon.73.110.349.578.807, i32 }
%class.anon.73.110.349.578.807 = type { i8 }
%"struct.pbbs::range.92.112.351.580.809" = type { i32*, i32* }
%class.anon.91.113.352.581.810 = type { %"struct.pbbs::monoid.111.350.579.808"*, i8**, i32**, i8**, i64*, i64*, i32*, %class.anon.72.109.348.577.806*, i32** }
%class.anon.94.115.354.583.812 = type { i64*, i64*, %class.anon.93.114.353.582.811* }
%class.anon.93.114.353.582.811 = type { %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::range.92.112.351.580.809"*, %"struct.pbbs::monoid.111.350.579.808"* }
%class.anon.96.117.356.585.814 = type { i64*, i64*, %class.anon.95.116.355.584.813* }
%class.anon.95.116.355.584.813 = type { %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::monoid.111.350.579.808"* }
%"struct.pbbs::range.83.118.357.586.815" = type { %"class.std::tuple.69.104.343.572.801"*, %"class.std::tuple.69.104.343.572.801"* }
%"struct.pbbs::monoid.84.125.364.593.822" = type { %class.anon.81.119.358.587.816, %"class.std::tuple.76.124.363.592.821" }
%class.anon.81.119.358.587.816 = type { i8 }
%"class.std::tuple.76.124.363.592.821" = type { %"struct.std::_Tuple_impl.77.123.362.591.820" }
%"struct.std::_Tuple_impl.77.123.362.591.820" = type { %"struct.std::_Tuple_impl.78.121.360.589.818", %"struct.std::_Head_base.80.122.361.590.819" }
%"struct.std::_Tuple_impl.78.121.360.589.818" = type { %"struct.std::_Head_base.79.120.359.588.817" }
%"struct.std::_Head_base.79.120.359.588.817" = type { i32 }
%"struct.std::_Head_base.80.122.361.590.819" = type { i32 }
%class.anon.99.127.366.595.824 = type { i64*, i64*, %class.anon.97.126.365.594.823* }
%class.anon.97.126.365.594.823 = type { %"struct.pbbs::range.83.118.357.586.815"*, %"struct.pbbs::range.83.118.357.586.815"*, %"struct.pbbs::monoid.84.125.364.593.822"* }
%class.anon.100.129.368.597.826 = type { i64*, i64*, %class.anon.98.128.367.596.825* }
%class.anon.98.128.367.596.825 = type { %"struct.pbbs::range.83.118.357.586.815"*, %"struct.pbbs::range.83.118.357.586.815"*, %"struct.pbbs::monoid.84.125.364.593.822"*, %"struct.pbbs::range.83.118.357.586.815"*, i32* }
%class.anon.103.130.369.598.827 = type { %"struct.pbbs::sequence.85.107.346.575.804"*, i64*, i64* }
%class.anon.104.131.370.599.828 = type { i8**, i32**, i8**, i32*, i64*, i32*, i64*, i64*, %"class.std::tuple.6.57.296.525.754"**, i32* }
%class.anon.108.133.372.601.830 = type { i64*, i64*, %class.anon.105.132.371.600.829*, %"class.std::tuple.6.57.296.525.754"**, i64** }
%class.anon.105.132.371.600.829 = type { %class.anon.55.101.340.569.798*, i32* }
%class.anon.109.134.373.602.831 = type { %"class.std::tuple.6.57.296.525.754"**, i64*, i64*, i64**, %class.anon.103.130.369.598.827* }
%class.anon.110.135.374.603.832 = type { i64*, %"struct.pbbs::sequence.62.94.333.562.791"*, i64*, i64* }
%"class.std::tuple.111.146.385.614.843" = type { %"struct.std::_Tuple_impl.112.145.384.613.842" }
%"struct.std::_Tuple_impl.112.145.384.613.842" = type { %"struct.std::_Tuple_impl.113.143.382.611.840", %"struct.std::_Head_base.121.144.383.612.841" }
%"struct.std::_Tuple_impl.113.143.382.611.840" = type { %"struct.std::_Tuple_impl.114.141.380.609.838", %"struct.std::_Head_base.120.142.381.610.839" }
%"struct.std::_Tuple_impl.114.141.380.609.838" = type { %"struct.std::_Tuple_impl.115.139.378.607.836", %"struct.std::_Head_base.119.140.379.608.837" }
%"struct.std::_Tuple_impl.115.139.378.607.836" = type { %"struct.std::_Tuple_impl.116.137.376.605.834", %"struct.std::_Head_base.118.138.377.606.835" }
%"struct.std::_Tuple_impl.116.137.376.605.834" = type { %"struct.std::_Head_base.117.136.375.604.833" }
%"struct.std::_Head_base.117.136.375.604.833" = type { i64 }
%"struct.std::_Head_base.118.138.377.606.835" = type { i64 }
%"struct.std::_Head_base.119.140.379.608.837" = type { %"class.std::vector.48.287.516.745" }
%"struct.std::_Head_base.120.142.381.610.839" = type { %"class.std::vector.48.287.516.745" }
%"struct.std::_Head_base.121.144.383.612.841" = type { %"class.std::vector.48.287.516.745" }
%"struct.gbbs::cpu_stats.147.386.615.844" = type { double, i64, double, double, i64, i64, i64, i64, i64, i64, double, i64 }
%"class.std::tuple.133.154.393.622.851" = type { %"struct.std::_Tuple_impl.134.153.392.621.850" }
%"struct.std::_Tuple_impl.134.153.392.621.850" = type { %"struct.std::_Tuple_impl.135.151.390.619.848", %"struct.std::_Head_base.139.152.391.620.849" }
%"struct.std::_Tuple_impl.135.151.390.619.848" = type { %"struct.std::_Tuple_impl.136.149.388.617.846", %"struct.std::_Head_base.138.150.389.618.847" }
%"struct.std::_Tuple_impl.136.149.388.617.846" = type { %"struct.std::_Tuple_impl.115.139.378.607.836", %"struct.std::_Head_base.137.148.387.616.845" }
%"struct.std::_Head_base.137.148.387.616.845" = type { double }
%"struct.std::_Head_base.138.150.389.618.847" = type { double }
%"struct.std::_Head_base.139.152.391.620.849" = type { double }
%"struct.gbbs::lt::LiuTarjanAlgorithm.156.395.624.853" = type { %"struct.gbbs::edge_array.99.338.567.796"*, i64, i1 (i32, i32, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*)**, void (i32, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*)**, void (i32, %"struct.pbbs::sequence.39.278.507.736"*)**, void (%"class.std::tuple.44.283.512.741"*, i32, i32, %"struct.pbbs::sequence.39.278.507.736"*)**, %"struct.pbbs::sequence.39.278.507.736", %"struct.pbbs::sequence.147.155.394.623.852" }
%"struct.pbbs::sequence.147.155.394.623.852" = type { i8*, i64 }
%"struct.pbbs::range.150.157.396.625.854" = type { %"class.std::tuple.63.93.332.561.790"*, %"class.std::tuple.63.93.332.561.790"* }
%class.anon.148.158.397.626.855 = type { i8 }
%class.anon.154.159.398.627.856 = type { i8 }
%"struct.pbbs::addm.158.160.399.628.857" = type { i32 }
%class.anon.161.162.401.630.859 = type { i64*, i64*, %class.anon.159.161.400.629.858* }
%class.anon.159.161.400.629.858 = type { %"struct.pbbs::range.92.112.351.580.809"*, %"struct.pbbs::range.92.112.351.580.809"*, %"struct.pbbs::addm.158.160.399.628.857"* }
%class.anon.162.164.403.632.861 = type { i64*, i64*, %class.anon.160.163.402.631.860* }
%class.anon.160.163.402.631.860 = type { %"struct.pbbs::range.92.112.351.580.809"*, %"struct.pbbs::range.92.112.351.580.809"*, %"struct.pbbs::addm.158.160.399.628.857"*, %"struct.pbbs::range.92.112.351.580.809"*, i32* }
%"struct.std::pair.167.165.404.633.862" = type { %"struct.pbbs::sequence.62.94.333.562.791", i64 }
%"struct.pbbs::delayed_sequence.181.167.406.635.864" = type { %class.anon.182.166.405.634.863, i64, i64 }
%class.anon.182.166.405.634.863 = type { %"struct.pbbs::range.150.157.396.625.854"* }
%class.anon.185.169.408.637.866 = type { i64*, i64*, %class.anon.183.168.407.636.865* }
%class.anon.183.168.407.636.865 = type { %"struct.pbbs::delayed_sequence.181.167.406.635.864"*, %"struct.pbbs::sequence.32.66.305.534.763"* }
%class.anon.186.171.410.639.868 = type { i64*, i64*, %class.anon.184.170.409.638.867* }
%class.anon.184.170.409.638.867 = type { %"struct.pbbs::sequence.32.66.305.534.763"*, i64*, %"struct.pbbs::delayed_sequence.181.167.406.635.864"*, %"struct.pbbs::sequence.62.94.333.562.791"*, %"struct.pbbs::range.150.157.396.625.854"* }
%"struct.pbbs::sequence.170.172.411.640.869" = type { %"struct.std::pair.171.38.277.506.735"*, i64 }
%class.anon.174.173.412.641.870 = type { %"struct.pbbs::range.150.157.396.625.854"* }
%class.anon.176.174.413.642.871 = type { %"struct.pbbs::sequence.170.172.411.640.869"*, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.gbbs::lt::LiuTarjanAlgorithm.156.395.624.853"* }
%class.anon.178.175.414.643.872 = type { %"struct.pbbs::sequence.170.172.411.640.869"*, %"struct.gbbs::lt::LiuTarjanAlgorithm.156.395.624.853"*, %"struct.pbbs::sequence.39.278.507.736"* }
%"struct.gbbs::unite_variants::Unite.176.415.644.873" = type { i32 (i32, %"struct.pbbs::sequence.39.278.507.736"*)** }
%class.anon.191.177.416.645.874 = type { %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*, i8*, i32*, i32* }
%"struct.std::_Tuple_impl.124.185.424.653.882" = type { %"struct.std::_Tuple_impl.125.183.422.651.880", %"struct.std::_Head_base.131.184.423.652.881" }
%"struct.std::_Tuple_impl.125.183.422.651.880" = type { %"struct.std::_Tuple_impl.126.181.420.649.878", %"struct.std::_Head_base.130.182.421.650.879" }
%"struct.std::_Tuple_impl.126.181.420.649.878" = type { %"struct.std::_Tuple_impl.127.179.418.647.876", %"struct.std::_Head_base.129.180.419.648.877" }
%"struct.std::_Tuple_impl.127.179.418.647.876" = type { %"struct.std::_Head_base.128.178.417.646.875" }
%"struct.std::_Head_base.128.178.417.646.875" = type { i64* }
%"struct.std::_Head_base.129.180.419.648.877" = type { i64* }
%"struct.std::_Head_base.130.182.421.650.879" = type { %"class.std::vector.48.287.516.745"* }
%"struct.std::_Head_base.131.184.423.652.881" = type { %"class.std::vector.48.287.516.745"* }
%struct.__va_list_tag.186.425.654.883 = type { i32, i32, i8*, i8* }
%class.anon.193.187.426.655.884 = type { i64*, %"struct.pbbs::sequence.62.94.333.562.791"*, i64*, i64* }
%"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885" = type { %"struct.gbbs::edge_array.99.338.567.796"*, i64, i1 (i32, i32, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*)**, void (i32, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*)**, void (i32, %"struct.pbbs::sequence.39.278.507.736"*)**, void (%"class.std::tuple.44.283.512.741"*, i32, i32, %"struct.pbbs::sequence.39.278.507.736"*)**, %"struct.pbbs::sequence.39.278.507.736", %"struct.pbbs::sequence.147.155.394.623.852" }
%class.anon.205.192.431.660.889 = type { %"struct.pbbs::sequence.170.172.411.640.869"*, %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"*, %"struct.pbbs::sequence.39.278.507.736"* }
%class.anon.203.191.430.659.888 = type { %"struct.pbbs::sequence.170.172.411.640.869"*, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* }
%class.anon.201.190.429.658.887 = type { %"struct.pbbs::range.150.157.396.625.854"* }
%class.anon.195.189.428.657.886 = type { i8 }
%class.anon.213.195.434.663.892 = type { i64*, i64*, %class.anon.211.194.433.662.891* }
%class.anon.211.194.433.662.891 = type { %"struct.pbbs::sequence.147.155.394.623.852"*, %class.anon.208.193.432.661.890*, %"struct.pbbs::sequence.170.172.411.640.869"*, %"struct.pbbs::sequence.32.66.305.534.763"* }
%class.anon.208.193.432.661.890 = type { %"struct.std::pair.171.38.277.506.735"* }
%class.anon.214.197.436.665.894 = type { i64*, i64*, %class.anon.212.196.435.664.893* }
%class.anon.212.196.435.664.893 = type { %"struct.pbbs::sequence.170.172.411.640.869"*, %"struct.pbbs::sequence.147.155.394.623.852"*, %"struct.pbbs::sequence.170.172.411.640.869"*, %"struct.pbbs::sequence.32.66.305.534.763"*, i64*, i64* }
%class.anon.220.199.438.667.896 = type { %class.anon.218.198.437.666.895*, double* }
%class.anon.218.198.437.666.895 = type { i8 }
%class.anon.225.203.442.671.900 = type { %"struct.gbbs::symmetric_graph.5.58.297.526.755"*, %class.anon.221.200.439.668.897*, %"struct.pbbs::monoid.224.202.441.670.899"*, %"struct.pbbs::sequence.68.105.344.573.802"* }
%class.anon.221.200.439.668.897 = type { %class.anon.220.199.438.667.896* }
%"struct.pbbs::monoid.224.202.441.670.899" = type { %class.anon.222.201.440.669.898, i32 }
%class.anon.222.201.440.669.898 = type { i8 }
%class.anon.229.204.443.672.901 = type { %"struct.pbbs::sequence.68.105.344.573.802"*, %"struct.pbbs::sequence.86.106.345.574.803"*, %"struct.pbbs::sequence.85.107.346.575.804"*, %"struct.gbbs::symmetric_graph.5.58.297.526.755"*, %class.anon.220.199.438.667.896* }
%"struct.pbbs::delayed_sequence.231.207.446.675.904" = type { %class.anon.230.206.445.674.903, i64, i64 }
%class.anon.230.206.445.674.903 = type { %"struct.gbbs::uncompressed_neighbors.205.444.673.902"*, %class.anon.221.200.439.668.897* }
%"struct.gbbs::uncompressed_neighbors.205.444.673.902" = type { i32, i32, %"class.std::tuple.6.57.296.525.754"* }
%class.anon.233.209.448.677.906 = type { i64*, i64*, %class.anon.232.208.447.676.905* }
%class.anon.232.208.447.676.905 = type { %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::delayed_sequence.231.207.446.675.904"*, %"struct.pbbs::monoid.224.202.441.670.899"* }
%class.anon.235.211.450.679.908 = type { i64*, i64*, %class.anon.234.210.449.678.907* }
%class.anon.234.210.449.678.907 = type { %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::monoid.224.202.441.670.899"* }
%"struct.pbbs::monoid.228.213.452.681.910" = type { %class.anon.226.212.451.680.909, %"class.std::tuple.76.124.363.592.821" }
%class.anon.226.212.451.680.909 = type { i8 }
%class.anon.238.215.454.683.912 = type { i64*, i64*, %class.anon.236.214.453.682.911* }
%class.anon.236.214.453.682.911 = type { %"struct.pbbs::range.83.118.357.586.815"*, %"struct.pbbs::range.83.118.357.586.815"*, %"struct.pbbs::monoid.228.213.452.681.910"* }
%class.anon.239.217.456.685.914 = type { i64*, i64*, %class.anon.237.216.455.684.913* }
%class.anon.237.216.455.684.913 = type { %"struct.pbbs::range.83.118.357.586.815"*, %"struct.pbbs::range.83.118.357.586.815"*, %"struct.pbbs::monoid.228.213.452.681.910"*, %"struct.pbbs::range.83.118.357.586.815"*, i32* }
%class.anon.240.218.457.686.915 = type { %"struct.pbbs::sequence.85.107.346.575.804"*, i64*, i64* }
%"struct.pbbs::range.242.219.458.687.916" = type { %"class.std::tuple.6.57.296.525.754"*, %"class.std::tuple.6.57.296.525.754"* }
%class.anon.246.222.461.690.919 = type { i64*, i64*, %class.anon.244.221.460.689.918* }
%class.anon.244.221.460.689.918 = type { %"struct.pbbs::sequence.147.155.394.623.852"*, %class.anon.241.220.459.688.917*, %"struct.pbbs::range.242.219.458.687.916"*, %"struct.pbbs::sequence.32.66.305.534.763"* }
%class.anon.241.220.459.688.917 = type { %class.anon.220.199.438.667.896*, %"struct.gbbs::uncompressed_neighbors.205.444.673.902"* }
%class.anon.247.224.463.692.921 = type { i64*, i64*, %class.anon.245.223.462.691.920* }
%class.anon.245.223.462.691.920 = type { %"struct.pbbs::range.242.219.458.687.916"*, %"struct.pbbs::sequence.147.155.394.623.852"*, %"struct.pbbs::range.242.219.458.687.916"*, %"struct.pbbs::sequence.32.66.305.534.763"*, i64*, i64* }

$_ZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ = comdat any

@_ZStL8__ioinit = external dso_local global %"class.std::ios_base::Init.0.239.468.697", align 1
@__dso_handle = external hidden global i8
@_ZN4pbbsL11my_mem_poolE = external dso_local global %"struct.pbbs::mem_pool.4.243.472.701", align 8
@_ZN4gbbs7gbbs_io8internalL25kUnweightedAdjGraphHeaderB5cxx11E = external dso_local global %"class.std::__cxx11::basic_string.7.246.475.704", align 8
@.str = external dso_local unnamed_addr constant [15 x i8], align 1
@_ZN4gbbs7gbbs_io8internalL23kWeightedAdjGraphHeaderB5cxx11E = external dso_local global %"class.std::__cxx11::basic_string.7.246.475.704", align 8
@.str.4 = external dso_local unnamed_addr constant [23 x i8], align 1
@_ZN4gbbs17global_batch_sizeE = external hidden local_unnamed_addr global i64, align 8
@_ZN4gbbs17global_update_pctE = external hidden local_unnamed_addr global double, align 8
@_ZN4gbbs22global_insert_to_queryE = external hidden local_unnamed_addr global double, align 8
@_ZN4gbbsL2btE = external dso_local global %"struct.pbbs::timer.8.247.476.705", align 8
@.str.6 = external dso_local unnamed_addr constant [12 x i8], align 1
@_ZN4gbbs16print_batch_timeE = external hidden local_unnamed_addr global i8, align 1
@.str.7 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.8 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.9 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.10 = external dso_local unnamed_addr constant [3 x i8], align 1
@_ZSt4cout = external dso_local global %"class.std::basic_ostream.23.262.491.720", align 8
@.str.11 = external dso_local unnamed_addr constant [69 x i8], align 1
@.str.12 = external dso_local unnamed_addr constant [35 x i8], align 1
@.str.13 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.14 = external dso_local unnamed_addr constant [2 x i8], align 1
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE10pool_rootsE = external hidden global %"class.pbbs::concurrent_stack.10.26.265.494.723", align 64
@_ZGVN4pbbs14list_allocatorIN4gbbs13em_data_blockEE10pool_rootsE = external hidden local_unnamed_addr global i64, align 8
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE12global_stackE = external hidden global %"class.pbbs::concurrent_stack.10.26.265.494.723", align 64
@_ZGVN4pbbs14list_allocatorIN4gbbs13em_data_blockEE12global_stackE = external hidden local_unnamed_addr global i64, align 8
@.str.17 = external dso_local unnamed_addr constant [42 x i8], align 1
@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE.30.269.498.727*, align 8
@.str.18 = external dso_local unnamed_addr constant [33 x i8], align 1
@_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global i8*
@_ZTSZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS_15symmetric_graphINS_20csv_bytepd_amortizedET_EEPKcbbEUlvE_ = external hidden constant [127 x i8], align 1
@_ZTIZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS_15symmetric_graphINS_20csv_bytepd_amortizedET_EEPKcbbEUlvE_ = external hidden constant { i8*, i8* }, align 8
@_ZTSZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS_15symmetric_graphINS_20csv_bytepd_amortizedET_EEPKcbbEUlvE0_ = external hidden constant [128 x i8], align 1
@_ZTIZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS_15symmetric_graphINS_20csv_bytepd_amortizedET_EEPKcbbEUlvE0_ = external hidden constant { i8*, i8* }, align 8
@.str.19 = external dso_local unnamed_addr constant [27 x i8], align 1
@.str.20 = external dso_local unnamed_addr constant [15 x i8], align 1
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE11initializedE = external hidden local_unnamed_addr global i8, align 1
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE10max_blocksE = external hidden local_unnamed_addr global i64, align 8
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE12thread_countE = external hidden local_unnamed_addr global i32, align 4
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE11list_lengthE = external hidden local_unnamed_addr global i64, align 8
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE16blocks_allocatedE = external hidden global %"struct.std::atomic.25.32.271.500.729", align 8
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE11_block_sizeE = external hidden local_unnamed_addr global i64, align 8
@_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE11local_listsE = external hidden local_unnamed_addr global %"struct.pbbs::list_allocator<gbbs::em_data_block>::thread_list.35.274.503.732"*, align 8
@.str.21 = external dso_local unnamed_addr constant [40 x i8], align 1
@.str.22 = external dso_local unnamed_addr constant [53 x i8], align 1
@.str.23 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.24 = external dso_local unnamed_addr constant [5 x i8], align 1
@.str.25 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.26 = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.27 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.28 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.29 = external dso_local unnamed_addr constant [14 x i8], align 1
@.str.30 = external dso_local unnamed_addr constant [14 x i8], align 1
@.str.31 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.32 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.33 = external dso_local unnamed_addr constant [9 x i8], align 1
@.str.34 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.35 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.36 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.37 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.38 = external dso_local unnamed_addr constant [20 x i8], align 1
@_ZN4pbbsL11_block_sizeE = external dso_local constant i64, align 8
@.str.39 = external dso_local unnamed_addr constant [52 x i8], align 1
@.str.40 = external dso_local unnamed_addr constant [7 x i8], align 1
@.str.41 = external dso_local unnamed_addr constant [25 x i8], align 1
@.str.42 = external dso_local unnamed_addr constant [43 x i8], align 1
@.str.43 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.44 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.45 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.46 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.47 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.48 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.49 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.50 = external dso_local unnamed_addr constant [14 x i8], align 1
@.str.51 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.52 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.53 = external dso_local unnamed_addr constant [26 x i8], align 1
@.str.54 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.55 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.56 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.57 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.58 = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.59 = external dso_local unnamed_addr constant [7 x i8], align 1
@.str.60 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.61 = external dso_local unnamed_addr constant [45 x i8], align 1
@.str.62 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.63 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.64 = external dso_local unnamed_addr constant [14 x i8], align 1
@.str.65 = external dso_local unnamed_addr constant [14 x i8], align 1
@.str.66 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.67 = external dso_local unnamed_addr constant [24 x i8], align 1
@.str.68 = external dso_local unnamed_addr constant [19 x i8], align 1
@.str.69 = external dso_local unnamed_addr constant [19 x i8], align 1
@.str.70 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.71 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.72 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.73 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.74 = external dso_local unnamed_addr constant [12 x i8], align 1
@.str.75 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.76 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.77 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.78 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.79 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.80 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.81 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.82 = external dso_local unnamed_addr constant [20 x i8], align 1
@.str.83 = external dso_local unnamed_addr constant [20 x i8], align 1
@.str.84 = external dso_local unnamed_addr constant [20 x i8], align 1
@.str.85 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.86 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.87 = external dso_local unnamed_addr constant [17 x i8], align 1
@.str.88 = external dso_local unnamed_addr constant [15 x i8], align 1
@.str.89 = external dso_local unnamed_addr constant [18 x i8], align 1
@.str.90 = external dso_local unnamed_addr constant [20 x i8], align 1
@_ZN4gbbs11max_pathlenE = external dso_local global %"struct.pbbslib::atomic_max_counter.36.275.504.733", align 4
@.str.91 = external dso_local unnamed_addr constant [22 x i8], align 1
@_ZN4gbbs13total_pathlenE = external dso_local global %"struct.pbbslib::atomic_sum_counter.37.276.505.734", align 8
@.str.92 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.93 = external dso_local unnamed_addr constant [3 x i8], align 1
@_ZZNSt8__detail18__to_chars_10_implImEEvPcjT_E8__digits = external dso_local local_unnamed_addr constant [201 x i8], align 16
@_ZZNSt8__detail18__to_chars_10_implIjEEvPcjT_E8__digits = external dso_local local_unnamed_addr constant [201 x i8], align 16
@__const._ZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_.nullary_edge = external dso_local unnamed_addr constant %"struct.std::pair.171.38.277.506.735", align 4
@llvm.global_ctors = external global [3 x { i32, void ()*, i8* }]

declare dso_local void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init.0.239.468.697"*) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init.0.239.468.697"*) unnamed_addr #1

; Function Attrs: nofree nounwind
declare dso_local i32 @__cxa_atexit(void (i8*)*, i8*, i8*) local_unnamed_addr #2

declare dso_local void @_ZN4pbbs8mem_poolC1Ev(%"struct.pbbs::mem_pool.4.243.472.701"*) unnamed_addr #0

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: nounwind ssp uwtable
declare dso_local void @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev(%"class.std::__cxx11::basic_string.7.246.475.704"*) unnamed_addr #4 align 2

; Function Attrs: norecurse nounwind readnone ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs12labelprop_cc7lp_lessEjj(i32, i32) local_unnamed_addr #5

; Function Attrs: norecurse nounwind readnone ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs2lt7lt_lessEjj(i32, i32) #5

; Function Attrs: norecurse nounwind readnone ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs2lt10lt_greaterEjj(i32, i32) local_unnamed_addr #5

; Function Attrs: norecurse nounwind readnone ssp uwtable
declare hidden i32 @_ZN4gbbs2lt6lt_minEjj(i32, i32) local_unnamed_addr #5

; Function Attrs: norecurse nounwind readnone ssp uwtable
declare hidden i32 @_ZN4gbbs2lt6lt_maxEjj(i32, i32) local_unnamed_addr #5

; Function Attrs: nounwind ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs2lt10primitives7connectEjjRN4pbbs8sequenceIjEES5_(i32, i32, %"struct.pbbs::sequence.39.278.507.736"* nocapture readnone dereferenceable(16), %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16)) local_unnamed_addr #4

; Function Attrs: nounwind ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs2lt10primitives14parent_connectEjjRN4pbbs8sequenceIjEES5_(i32, i32, %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16), %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16)) #4

; Function Attrs: nounwind ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs2lt10primitives16extended_connectEjjRN4pbbs8sequenceIjEES5_(i32, i32, %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16), %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16)) local_unnamed_addr #4

; Function Attrs: nofree norecurse nounwind ssp uwtable
declare hidden void @_ZN4gbbs2lt10primitives13simple_updateEjRN4pbbs8sequenceIjEES5_(i32, %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16), %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16)) local_unnamed_addr #6

; Function Attrs: nofree norecurse nounwind ssp uwtable
declare hidden void @_ZN4gbbs2lt10primitives11root_updateEjRN4pbbs8sequenceIjEES5_(i32, %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16), %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16)) #6

; Function Attrs: nofree norecurse nounwind ssp uwtable
declare hidden void @_ZN4gbbs2lt10primitives8shortcutEjRN4pbbs8sequenceIjEE(i32, %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16)) #6

; Function Attrs: nofree norecurse nounwind ssp uwtable
declare hidden void @_ZN4gbbs2lt10primitives13root_shortcutEjRN4pbbs8sequenceIjEE(i32, %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16)) #6

; Function Attrs: norecurse nounwind ssp uwtable
declare hidden void @_ZN4gbbs2lt10primitives5alterEjjRN4pbbs8sequenceIjEE(%"class.std::tuple.44.283.512.741"* noalias nocapture sret, i32, i32, %"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16)) #7

; Function Attrs: ssp uwtable
declare hidden double @_ZN4gbbs6medianESt6vectorIdSaIdEE(%"class.std::vector.48.287.516.745"* nocapture readonly) local_unnamed_addr #8

; Function Attrs: norecurse nounwind readnone ssp uwtable
declare hidden double @_ZN4gbbs4sumfEdd(double, double) local_unnamed_addr #5

; Function Attrs: norecurse nounwind readnone ssp uwtable
declare hidden double @_ZN4gbbs4minfEdd(double, double) #5

; Function Attrs: norecurse nounwind readnone ssp uwtable
declare hidden double @_ZN4gbbs4maxfEdd(double, double) #5

declare dso_local void @_ZN4pbbs5timerC1ENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEb(%"struct.pbbs::timer.8.247.476.705"*, %"class.std::__cxx11::basic_string.7.246.475.704"*, i1 zeroext) unnamed_addr #0

; Function Attrs: inlinehint nounwind ssp uwtable
declare hidden void @_ZN4pbbs5timerD2Ev(%"struct.pbbs::timer.8.247.476.705"*) unnamed_addr #9 align 2

; Function Attrs: nofree norecurse nounwind ssp uwtable
declare hidden void @_ZN4gbbs9connectit14check_shortcutERN4pbbs8sequenceIjEEj(%"struct.pbbs::sequence.39.278.507.736"* nocapture readonly dereferenceable(16), i32) local_unnamed_addr #6

; Function Attrs: norecurse ssp uwtable
declare hidden i32 @main(i32, i8**) local_unnamed_addr #10

declare dso_local void @_ZN4gbbs11commandLineC1EiPPcNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"struct.gbbs::commandLine.49.288.517.746"*, i32, i8**, %"class.std::__cxx11::basic_string.7.246.475.704"*) unnamed_addr #0

declare dso_local i8* @_ZNK4gbbs11commandLine11getArgumentEi(%"struct.gbbs::commandLine.49.288.517.746"*, i32) local_unnamed_addr #0

declare dso_local i8* @_ZNK4gbbs11commandLine14getOptionValueERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"struct.gbbs::commandLine.49.288.517.746"*, %"class.std::__cxx11::basic_string.7.246.475.704"* dereferenceable(32)) local_unnamed_addr #0

; Function Attrs: inlinehint ssp uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream.23.262.491.720"* dereferenceable(272), i8*) local_unnamed_addr #11

; Function Attrs: inlinehint ssp uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_(%"class.std::basic_ostream.23.262.491.720"* dereferenceable(272)) #11

declare dso_local void @_ZN4gbbs8pcm_initEv() local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS_15symmetric_graphINS_20csv_bytepd_amortizedET_EEPKcbb(%"struct.gbbs::symmetric_graph.55.294.523.752"* noalias sret, i8*, i1 zeroext, i1 zeroext) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs10alloc_initINS_15symmetric_graphINS_20csv_bytepd_amortizedEN4pbbs5emptyEEEEEvRT_(%"struct.gbbs::symmetric_graph.55.294.523.752"* dereferenceable(72)) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden double @_ZN4gbbs3RunINS_15symmetric_graphINS_20csv_bytepd_amortizedEN4pbbs5emptyEEEEEdRT_NS_11commandLineE(%"struct.gbbs::symmetric_graph.55.294.523.752"* dereferenceable(72), %"struct.gbbs::commandLine.49.288.517.746"*) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZN4gbbs11commandLineC2ERKS0_(%"struct.gbbs::commandLine.49.288.517.746"*, %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48)) unnamed_addr #11 align 2

declare dso_local void @_ZN4gbbs15print_pcm_statsEmmmd(i64, i64, i64, double) local_unnamed_addr #0

declare dso_local void @_ZN4gbbs7gbbs_io31read_unweighted_symmetric_graphEPKcbPcm(%"struct.gbbs::symmetric_graph.5.58.297.526.755"* sret, i8*, i1 zeroext, i8*, i64) local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs10alloc_initINS_15symmetric_graphINS_16symmetric_vertexEN4pbbs5emptyEEEEEvRT_(%"struct.gbbs::symmetric_graph.5.58.297.526.755"* dereferenceable(72)) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden double @_ZN4gbbs3RunINS_15symmetric_graphINS_16symmetric_vertexEN4pbbs5emptyEEEEEdRT_NS_11commandLineE(%"struct.gbbs::symmetric_graph.5.58.297.526.755"* dereferenceable(72), %"struct.gbbs::commandLine.49.288.517.746"*) local_unnamed_addr #8

declare dso_local void @_ZN4gbbs12alloc_finishEv() local_unnamed_addr #0

; Function Attrs: nofree nounwind ssp uwtable
declare dso_local void @__cxx_global_var_init.15() #12 section ".text.startup"

; Function Attrs: nounwind ssp uwtable
declare hidden void @_ZN4pbbs16concurrent_stackIPNS_14list_allocatorIN4gbbs13em_data_blockEE5blockEED2Ev(%"class.pbbs::concurrent_stack.10.26.265.494.723"*) unnamed_addr #4 align 2

; Function Attrs: nofree nounwind ssp uwtable
declare dso_local void @__cxx_global_var_init.16() #12 section ".text.startup"

; Function Attrs: noinline noreturn nounwind
declare hidden void @__clang_call_terminate(i8*) local_unnamed_addr #13

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: noreturn
declare dso_local void @_ZSt19__throw_logic_errorPKc(i8*) local_unnamed_addr #14

declare dso_local i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string.7.246.475.704"*, i64* dereferenceable(8), i64) local_unnamed_addr #0

declare dso_local void @__cxa_call_unexpected(i8*) local_unnamed_addr

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #15

declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream.23.262.491.720"* dereferenceable(272), i8*, i64) local_unnamed_addr #0

declare dso_local void @_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate(%"class.std::basic_ios.22.261.490.719"*, i32) local_unnamed_addr #0

; Function Attrs: argmemonly nofree nounwind readonly
declare dso_local i64 @strlen(i8* nocapture) local_unnamed_addr #16

declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSo3putEc(%"class.std::basic_ostream.23.262.491.720"*, i8 signext) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSo5flushEv(%"class.std::basic_ostream.23.262.491.720"*) local_unnamed_addr #0

; Function Attrs: noreturn
declare dso_local void @_ZSt16__throw_bad_castv() local_unnamed_addr #14

declare dso_local void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype.19.258.487.716"*) local_unnamed_addr #0

; Function Attrs: nofree nounwind
declare dso_local i8* @__memcpy_chk(i8*, i8*, i64, i64) local_unnamed_addr #17

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.objectsize.i64.p0i8(i8*, i1 immarg, i1 immarg, i1 immarg) #18

; Function Attrs: ssp uwtable
declare hidden void @_ZSt16__introsort_loopIN9__gnu_cxx17__normal_iteratorIPdSt6vectorIdSaIdEEEElNS0_5__ops15_Iter_less_iterEEvT_S9_T0_T1_(double*, double*, i64) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZSt22__final_insertion_sortIN9__gnu_cxx17__normal_iteratorIPdSt6vectorIdSaIdEEEENS0_5__ops15_Iter_less_iterEEvT_S9_T0_(double*, double*) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZSt13__heap_selectIN9__gnu_cxx17__normal_iteratorIPdSt6vectorIdSaIdEEEENS0_5__ops15_Iter_less_iterEEvT_S9_S9_T0_(double*, double*, double*) local_unnamed_addr #8

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #18

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i1 immarg) #3

declare dso_local void @_ZN4gbbs7gbbs_io22parse_compressed_graphEPKcbb(%"class.std::tuple.11.63.302.531.760"* sret, i8*, i1 zeroext, i1 zeroext) local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden dereferenceable(32) %"class.std::function.54.293.522.751"* @_ZNSt8functionIFvvEEaSIZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS3_15symmetric_graphINS3_20csv_bytepd_amortizedET_EEPKcbbEUlvE0_EENSt9enable_ifIXsrNS1_9_CallableINSt5decayISA_E4typeESt15__invoke_resultIRSJ_JEEEE5valueERS1_E4typeEOSA_(%"class.std::function.54.293.522.751"*, %class.anon.22.64.303.532.761* dereferenceable(24)) local_unnamed_addr #8 align 2

; Function Attrs: nofree nounwind
declare dso_local i32 @fprintf(%struct._IO_FILE.30.269.498.727* nocapture, i8* nocapture readonly, ...) local_unnamed_addr #17

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) local_unnamed_addr #19

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @malloc(i64) local_unnamed_addr #17

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #20

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #3

; Function Attrs: ssp uwtable
declare hidden void @_ZNSt17_Function_handlerIFvvEZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS1_15symmetric_graphINS1_20csv_bytepd_amortizedET_EEPKcbbEUlvE_E9_M_invokeERKSt9_Any_data(%"union.std::_Any_data.52.291.520.749"* dereferenceable(16)) #8 align 2

; Function Attrs: ssp uwtable
declare hidden zeroext i1 @_ZNSt17_Function_handlerIFvvEZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS1_15symmetric_graphINS1_20csv_bytepd_amortizedET_EEPKcbbEUlvE_E10_M_managerERSt9_Any_dataRKSE_St18_Manager_operation(%"union.std::_Any_data.52.291.520.749"* dereferenceable(16), %"union.std::_Any_data.52.291.520.749"* dereferenceable(16), i32) #8 align 2

; Function Attrs: nounwind
declare dso_local void @free(i8* nocapture) local_unnamed_addr #1

; Function Attrs: ssp uwtable
declare hidden void @_ZNSt17_Function_handlerIFvvEZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS1_15symmetric_graphINS1_20csv_bytepd_amortizedET_EEPKcbbEUlvE0_E9_M_invokeERKSt9_Any_data(%"union.std::_Any_data.52.291.520.749"* dereferenceable(16)) #8 align 2

; Function Attrs: ssp uwtable
declare hidden zeroext i1 @_ZNSt17_Function_handlerIFvvEZN4gbbs7gbbs_io31read_compressed_symmetric_graphIN4pbbs5emptyEEENS1_15symmetric_graphINS1_20csv_bytepd_amortizedET_EEPKcbbEUlvE0_E10_M_managerERSt9_Any_dataRKSE_St18_Manager_operation(%"union.std::_Any_data.52.291.520.749"* dereferenceable(16), %"union.std::_Any_data.52.291.520.749"* dereferenceable(16), i32) #8 align 2

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #21

declare dso_local void @_ZN4gbbs7gbbs_io6unmmapEPKcm(i8*, i64) local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSolsEm(%"class.std::basic_ostream.23.262.491.720"*, i64) local_unnamed_addr #8 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE7reserveEmbm(i64, i1 zeroext, i64) local_unnamed_addr #8 align 2

declare dso_local i64 @_ZN4pbbs13getMemorySizeEv() local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE11print_statsEv() local_unnamed_addr #8 align 2

declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream.23.262.491.720"*, i64) local_unnamed_addr #0

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.ceil.f64(double) #18

; Function Attrs: ssp uwtable
declare hidden %"union.pbbs::list_allocator<gbbs::em_data_block>::block.34.273.502.731"* @_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE15allocate_blocksEm(i64) local_unnamed_addr #8 align 2

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_14list_allocatorIN4gbbs13em_data_blockEE7reserveEmbmEUlmE_EEvllT_lb(i64, i64, %"union.pbbs::list_allocator<gbbs::em_data_block>::block.34.273.502.731"**) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE12rand_shuffleEv() local_unnamed_addr #8 align 2

; Function Attrs: nounwind readnone speculatable willreturn
declare { i64, i1 } @llvm.umul.with.overflow.i64(i64, i64) #18

; Function Attrs: nobuiltin nofree
declare dso_local noalias i8* @_ZnamSt11align_val_t(i64, i64) local_unnamed_addr #21

declare dso_local i32 @__cilkrts_get_nworkers() local_unnamed_addr #0

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @aligned_alloc(i64, i64) local_unnamed_addr #17

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znam(i64) local_unnamed_addr #21

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs14random_shuffleINS_8sequenceIPN4gbbs13em_data_blockEEEEENS1_INT_10value_typeEEERKS6_NS_6randomE(%"struct.pbbs::sequence.28.65.304.533.762"* noalias sret, %"struct.pbbs::sequence.28.65.304.533.762"* dereferenceable(16), i64) local_unnamed_addr #8

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdaPv(i8*) local_unnamed_addr #15

; Function Attrs: ssp uwtable
declare hidden %"union.pbbs::list_allocator<gbbs::em_data_block>::block.34.273.502.731"* @_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE8get_listEv() local_unnamed_addr #8 align 2

declare dso_local i32 @__cilkrts_get_worker_number() local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs15random_shuffle_INS_8sequenceIPN4gbbs13em_data_blockEEEEEvRKT_NS_5rangeIPNS6_10value_typeEEENS_6randomE(%"struct.pbbs::sequence.28.65.304.533.762"* dereferenceable(16), %"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.gbbs::em_data_block.33.272.501.730"**, i64) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_15random_shuffle_INS_8sequenceIPN4gbbs13em_data_blockEEEEEvRKT_NS_5rangeIPNS7_10value_typeEEENS_6randomEEUlmE1_EEvllS7_lb(i64, i64, %class.anon.38.69.308.537.766* byval(%class.anon.38.69.308.537.766) align 8) unnamed_addr #11

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs11count_sort_IjKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS4_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS5_EEvRKT_NS7_IPNSC_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS1_ImEEbERT0_RT1_RT2_mfb(%"struct.std::pair.70.309.538.767"* noalias sret, %"struct.pbbs::sequence.28.65.304.533.762"* dereferenceable(16), %"struct.pbbs::range.67.306.535.764"* dereferenceable(16), %"struct.pbbs::delayed_sequence.72.311.540.769"* dereferenceable(32), i64, float, i1 zeroext) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs11count_sort_ImKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS4_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS5_EEvRKT_NS7_IPNSC_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS1_ImEEbERT0_RT1_RT2_mfb(%"struct.std::pair.70.309.538.767"* noalias sret, %"struct.pbbs::sequence.28.65.304.533.762"* dereferenceable(16), %"struct.pbbs::range.67.306.535.764"* dereferenceable(16), %"struct.pbbs::delayed_sequence.72.311.540.769"* dereferenceable(32), i64, float, i1 zeroext) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs14seq_count_sortIKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS4_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS5_EEvRKT_NS7_IPNSC_10value_typeEEENS_6randomEEUlmE0_EEEENS1_ImEERSC_RT0_RT1_m(%"struct.pbbs::sequence.32.66.305.534.763"* noalias sret, %"struct.pbbs::sequence.28.65.304.533.762"* dereferenceable(16), %"struct.pbbs::range.67.306.535.764"* dereferenceable(16), %"struct.pbbs::delayed_sequence.72.311.540.769"* dereferenceable(32), i64) local_unnamed_addr #8

declare dso_local void @_ZN4pbbs5timer4nextERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"struct.pbbs::timer.8.247.476.705"*, %"class.std::__cxx11::basic_string.7.246.475.704"* dereferenceable(32)) local_unnamed_addr #0

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_IjKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE_EEvllSD_lb(i64, i64, %class.anon.39.73.312.541.770* nocapture readonly byval(%class.anon.39.73.312.541.770) align 8) unnamed_addr #11

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_IjKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE0_EEvllSD_lb(i64, i64, %class.anon.40.74.313.542.771* nocapture readonly byval(%class.anon.40.74.313.542.771) align 8, i64) unnamed_addr #9

; Function Attrs: noreturn nounwind
declare dso_local void @abort() local_unnamed_addr #19

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_IjKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE1_EEvllSD_lb(i64, i64, %class.anon.42.75.314.543.772* nocapture readonly byval(%class.anon.42.75.314.543.772) align 8, i64) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_IjKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE2_EEvllSD_lb(i64, i64, %class.anon.43.76.315.544.773* nocapture readonly byval(%class.anon.43.76.315.544.773) align 8, i64) unnamed_addr #9

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_IjKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE3_EEvllSD_lb(i64, i64, %class.anon.44.77.316.545.774* nocapture readonly byval(%class.anon.44.77.316.545.774) align 8) unnamed_addr #11

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.round.f32(float) #18

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs10seq_count_ImNS_5rangeIPPN4gbbs13em_data_blockEEENS_16delayed_sequenceImZNS_15random_shuffle_INS_8sequenceIS4_EEEEvRKT_NS1_IPNSB_10value_typeEEENS_6randomEEUlmE0_EEEEvT0_T1_PSB_m(%"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.pbbs::delayed_sequence.72.311.540.769"* byval(%"struct.pbbs::delayed_sequence.72.311.540.769") align 8, i64*, i64) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs10seq_count_IjNS_5rangeIPPN4gbbs13em_data_blockEEENS_16delayed_sequenceImZNS_15random_shuffle_INS_8sequenceIS4_EEEEvRKT_NS1_IPNSB_10value_typeEEENS_6randomEEUlmE0_EEEEvT0_T1_PSB_m(%"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.pbbs::delayed_sequence.72.311.540.769"* byval(%"struct.pbbs::delayed_sequence.72.311.540.769") align 8, i32*, i64) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden i64 @_ZN4pbbs5scan_INS_5rangeIPmEES3_NS_4addmImEEEENT_10value_typeERKS6_OT0_RKT1_jPS7_(%"struct.pbbs::range.41.78.317.546.775"* dereferenceable(16), %"struct.pbbs::range.41.78.317.546.775"* dereferenceable(16), %"struct.pbbs::addm.79.318.547.776"* dereferenceable(8), i32, i64*) local_unnamed_addr #8

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_5scan_INS_5rangeIPmEES5_NS_4addmImEEEENT_10value_typeERKS8_OT0_RKT1_jPS9_EUlmmmE_EEvmmSB_jEUlmE_EEvllS8_lb(i64, i64, %class.anon.47.81.320.549.778* nocapture readonly byval(%class.anon.47.81.320.549.778) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_5scan_INS_5rangeIPmEES5_NS_4addmImEEEENT_10value_typeERKS8_OT0_RKT1_jPS9_EUlmmmE0_EEvmmSB_jEUlmE_EEvllS8_lb(i64, i64, %class.anon.48.83.322.551.780* nocapture readonly byval(%class.anon.48.83.322.551.780) align 8) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs10seq_write_IjNS_5rangeIPPN4gbbs13em_data_blockEEENS_16delayed_sequenceImZNS_15random_shuffle_INS_8sequenceIS4_EEEEvRKT_NS1_IPNSB_10value_typeEEENS_6randomEEUlmE0_EEEEvT0_PNSK_10value_typeET1_PSB_m(%"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.pbbs::delayed_sequence.72.311.540.769"* byval(%"struct.pbbs::delayed_sequence.72.311.540.769") align 8, i32*, i64) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_ImKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE_EEvllSD_lb(i64, i64, %class.anon.49.84.323.552.781* nocapture readonly byval(%class.anon.49.84.323.552.781) align 8) unnamed_addr #11

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_ImKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE0_EEvllSD_lb(i64, i64, %class.anon.50.85.324.553.782* nocapture readonly byval(%class.anon.50.85.324.553.782) align 8, i64) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_ImKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE1_EEvllSD_lb(i64, i64, %class.anon.51.86.325.554.783* nocapture readonly byval(%class.anon.51.86.325.554.783) align 8, i64) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_ImKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE2_EEvllSD_lb(i64, i64, %class.anon.52.87.326.555.784* nocapture readonly byval(%class.anon.52.87.326.555.784) align 8, i64) unnamed_addr #9

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_11count_sort_ImKNS_8sequenceIPN4gbbs13em_data_blockEEENS_5rangeIPS5_EEKNS_16delayed_sequenceImZNS_15random_shuffle_IS6_EEvRKT_NS8_IPNSD_10value_typeEEENS_6randomEEUlmE0_EEEESt4pairINS2_ImEEbERT0_RT1_RT2_mfbEUlmE3_EEvllSD_lb(i64, i64, %class.anon.53.88.327.556.785* nocapture readonly byval(%class.anon.53.88.327.556.785) align 8) unnamed_addr #11

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs10seq_write_ImNS_5rangeIPPN4gbbs13em_data_blockEEENS_16delayed_sequenceImZNS_15random_shuffle_INS_8sequenceIS4_EEEEvRKT_NS1_IPNSB_10value_typeEEENS_6randomEEUlmE0_EEEEvT0_PNSK_10value_typeET1_PSB_m(%"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.gbbs::em_data_block.33.272.501.730"**, %"struct.pbbs::delayed_sequence.72.311.540.769"* byval(%"struct.pbbs::delayed_sequence.72.311.540.769") align 8, i64*, i64) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4pbbs15random_shuffle_INS_8sequenceIPN4gbbs13em_data_blockEEEEEvRKT_NS_5rangeIPNS6_10value_typeEEENS_6randomEENKUlmE1_clEm(%class.anon.38.69.308.537.766*, i64) local_unnamed_addr #11 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs14list_allocatorIN4gbbs13em_data_blockEE4freeEPS2_(%"struct.gbbs::em_data_block.33.272.501.730"*) local_unnamed_addr #8 align 2

declare dso_local i32 @_ZNK4gbbs11commandLine17getOptionIntValueERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEi(%"struct.gbbs::commandLine.49.288.517.746"*, %"class.std::__cxx11::basic_string.7.246.475.704"* dereferenceable(32), i32) local_unnamed_addr #0

declare dso_local double @_ZNK4gbbs11commandLine20getOptionDoubleValueERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEd(%"struct.gbbs::commandLine.49.288.517.746"*, %"class.std::__cxx11::basic_string.7.246.475.704"* dereferenceable(32), double) local_unnamed_addr #0

declare dso_local i64 @_ZNK4gbbs11commandLine18getOptionLongValueERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEm(%"struct.gbbs::commandLine.49.288.517.746"*, %"class.std::__cxx11::basic_string.7.246.475.704"* dereferenceable(32), i64) local_unnamed_addr #0

declare dso_local void @_ZN4pbbs5timer5startEv(%"struct.pbbs::timer.8.247.476.705"*) local_unnamed_addr #0

declare dso_local double @_ZN4pbbs5timer4stopEv(%"struct.pbbs::timer.8.247.476.705"*) local_unnamed_addr #0

declare dso_local void @_ZNK4pbbs5timer11reportTotalERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"struct.pbbs::timer.8.247.476.705"*, %"class.std::__cxx11::basic_string.7.246.475.704"* dereferenceable(32)) local_unnamed_addr #0

declare dso_local void @_ZN4gbbs16annotate_updatesERN4pbbs8sequenceISt5tupleIJjjEEEEdmb(%"struct.pbbs::sequence.62.94.333.562.791"* sret, %"struct.pbbs::sequence.61.95.334.563.792"* dereferenceable(16), double, i64, i1 zeroext) local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs13run_all_testsINS_10edge_arrayIN4pbbs5emptyEEELb0EEEvRT_mRNS2_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmNS_11commandLineE(%"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %"struct.pbbs::sequence.62.94.333.562.791"* dereferenceable(16), i64, i64, i64, %"struct.gbbs::commandLine.49.288.517.746"*) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs12sample_edgesINS_15symmetric_graphINS_20csv_bytepd_amortizedEN4pbbs5emptyEEEZNS_3RunIS5_EEdRT_NS_11commandLineEEUlRKjSB_RKS4_E_EENS_10edge_arrayINS7_11weight_typeEEES8_RT0_(%"struct.gbbs::edge_array.99.338.567.796"* noalias sret, %"struct.gbbs::symmetric_graph.55.294.523.752"* dereferenceable(72), %class.anon.55.101.340.569.798* dereferenceable(16)) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZN4gbbs12sample_edgesINS1_15symmetric_graphINS1_20csv_bytepd_amortizedENS_5emptyEEEZNS1_3RunIS6_EEdRT_NS1_11commandLineEEUlRKjSC_RKS5_E_EENS1_10edge_arrayINS8_11weight_typeEEES9_RT0_EUlmE0_EEvllS8_lb(i64, i64, %class.anon.87.108.347.576.805* nocapture readonly byval(%class.anon.87.108.347.576.805) align 8) unnamed_addr #11

; Function Attrs: inlinehint ssp uwtable
declare hidden i32 @_ZN4gbbs16bytepd_amortized10map_reduceIN4pbbs5emptyEZNS_12sample_edgesINS_15symmetric_graphINS_20csv_bytepd_amortizedES3_EEZNS_3RunIS7_EEdRT_NS_11commandLineEEUlRKjSD_RKS3_E_EENS_10edge_arrayINS9_11weight_typeEEESA_RT0_EUlSD_SD_SF_E_NS2_6monoidIZNS4_IS7_SG_EESJ_SA_SL_EUlmmE_jEEEENT1_1TEPhSD_RKmSL_RSQ_b(i8*, i32* dereferenceable(4), i64* dereferenceable(8), %class.anon.72.109.348.577.806* dereferenceable(8), %"struct.pbbs::monoid.111.350.579.808"* dereferenceable(8), i1 zeroext) local_unnamed_addr #11

; Function Attrs: ssp uwtable
declare hidden i32 @_ZN4pbbs6reduceINS_5rangeIPjEENS_6monoidIZN4gbbs12sample_edgesINS5_15symmetric_graphINS5_20csv_bytepd_amortizedENS_5emptyEEEZNS5_3RunISA_EEdRT_NS5_11commandLineEEUlRKjSG_RKS9_E_EENS5_10edge_arrayINSC_11weight_typeEEESD_RT0_EUlmmE_jEEEENSC_10value_typeERKSC_SN_j(%"struct.pbbs::range.92.112.351.580.809"* dereferenceable(16), i64, i32) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs16bytepd_amortized10map_reduceIN4pbbs5emptyEZNS_12sample_edgesINS_15symmetric_graphINS_20csv_bytepd_amortizedES3_EEZNS_3RunIS7_EEdRT_NS_11commandLineEEUlRKjSD_RKS3_E_EENS_10edge_arrayINS9_11weight_typeEEESA_RT0_EUlSD_SD_SF_E_NS2_6monoidIZNS4_IS7_SG_EESJ_SA_SL_EUlmmE_jEEEENT1_1TEPhSD_RKmSL_RSQ_bENKUlmE_clEm(%class.anon.91.113.352.581.810*, i64) local_unnamed_addr #11 align 2

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZN4gbbs16bytepd_amortized10map_reduceINS_5emptyEZNS1_12sample_edgesINS1_15symmetric_graphINS1_20csv_bytepd_amortizedES4_EEZNS1_3RunIS8_EEdRT_NS1_11commandLineEEUlRKjSE_RKS4_E_EENS1_10edge_arrayINSA_11weight_typeEEESB_RT0_EUlSE_SE_SG_E_NS_6monoidIZNS5_IS8_SH_EESK_SB_SM_EUlmmE_jEEEENT1_1TEPhSE_RKmSM_RSR_bEUlmE_EEvllSA_lb(i64, i64, %class.anon.91.113.352.581.810* byval(%class.anon.91.113.352.581.810) align 8) unnamed_addr #11

; Function Attrs: ssp uwtable
declare hidden i32 @_ZN4pbbs6reduceINS_8sequenceIjEENS_6monoidIZN4gbbs12sample_edgesINS4_15symmetric_graphINS4_20csv_bytepd_amortizedENS_5emptyEEEZNS4_3RunIS9_EEdRT_NS4_11commandLineEEUlRKjSF_RKS8_E_EENS4_10edge_arrayINSB_11weight_typeEEESC_RT0_EUlmmE_jEEEENSB_10value_typeERKSB_SM_j(%"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16), i64, i32) local_unnamed_addr #8

; Function Attrs: nofree nounwind
declare dso_local double @sqrt(double) local_unnamed_addr #17

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_6reduceINS_5rangeIPjEENS_6monoidIZN4gbbs12sample_edgesINS7_15symmetric_graphINS7_20csv_bytepd_amortizedENS_5emptyEEEZNS7_3RunISC_EEdRT_NS7_11commandLineEEUlRKjSI_RKSB_E_EENS7_10edge_arrayINSE_11weight_typeEEESF_RT0_EUlmmE_jEEEENSE_10value_typeERKSE_SP_jEUlmmmE_EEvmmSV_jEUlmE_EEvllSE_lb(i64, i64, %class.anon.94.115.354.583.812* nocapture readonly byval(%class.anon.94.115.354.583.812) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_6reduceINS_8sequenceIjEENS_6monoidIZN4gbbs12sample_edgesINS6_15symmetric_graphINS6_20csv_bytepd_amortizedENS_5emptyEEEZNS6_3RunISB_EEdRT_NS6_11commandLineEEUlRKjSH_RKSA_E_EENS6_10edge_arrayINSD_11weight_typeEEESE_RT0_EUlmmE_jEEEENSD_10value_typeERKSD_SO_jEUlmmmE_EEvmmSU_jEUlmE_EEvllSD_lb(i64, i64, %class.anon.96.117.356.585.814* nocapture readonly byval(%class.anon.96.117.356.585.814) align 8) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs5scan_INS_5rangeIPSt5tupleIJmmEEEES5_NS_6monoidIZN4gbbs12sample_edgesINS7_15symmetric_graphINS7_20csv_bytepd_amortizedENS_5emptyEEEZNS7_3RunISC_EEdRT_NS7_11commandLineEEUlRKjSI_RKSB_E_EENS7_10edge_arrayINSE_11weight_typeEEESF_RT0_EUlRKS3_SS_E_S2_IJiiEEEEEENSE_10value_typeERKSE_OSP_RKT1_jPSW_(%"class.std::tuple.69.104.343.572.801"* noalias sret, %"struct.pbbs::range.83.118.357.586.815"* dereferenceable(16), %"struct.pbbs::range.83.118.357.586.815"* dereferenceable(16), %"struct.pbbs::monoid.84.125.364.593.822"* dereferenceable(12), i32, %"class.std::tuple.69.104.343.572.801"*) local_unnamed_addr #8

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_5scan_INS_5rangeIPSt5tupleIJmmEEEES7_NS_6monoidIZN4gbbs12sample_edgesINS9_15symmetric_graphINS9_20csv_bytepd_amortizedENS_5emptyEEEZNS9_3RunISE_EEdRT_NS9_11commandLineEEUlRKjSK_RKSD_E_EENS9_10edge_arrayINSG_11weight_typeEEESH_RT0_EUlRKS5_SU_E_S4_IJiiEEEEEENSG_10value_typeERKSG_OSR_RKT1_jPSY_EUlmmmE_EEvmmS10_jEUlmE_EEvllSG_lb(i64, i64, %class.anon.99.127.366.595.824* nocapture readonly byval(%class.anon.99.127.366.595.824) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_5scan_INS_5rangeIPSt5tupleIJmmEEEES7_NS_6monoidIZN4gbbs12sample_edgesINS9_15symmetric_graphINS9_20csv_bytepd_amortizedENS_5emptyEEEZNS9_3RunISE_EEdRT_NS9_11commandLineEEUlRKjSK_RKSD_E_EENS9_10edge_arrayINSG_11weight_typeEEESH_RT0_EUlRKS5_SU_E_S4_IJiiEEEEEENSG_10value_typeERKSG_OSR_RKT1_jPSY_EUlmmmE0_EEvmmS10_jEUlmE_EEvllSG_lb(i64, i64, %class.anon.100.129.368.597.826* nocapture readonly byval(%class.anon.100.129.368.597.826) align 8) unnamed_addr #9

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZN4gbbs16bytepd_amortized6filterIN4pbbs5emptyEZNS_3RunINS_15symmetric_graphINS_20csv_bytepd_amortizedES3_EEEEdRT_NS_11commandLineEEUlRKjSC_RKS3_E_ZZNS_12sample_edgesIS7_SF_EENS_10edge_arrayINS8_11weight_typeEEES9_RT0_ENKUlmE0_clEmEUlmRKSt5tupleIJjS3_EEE_EEvSK_PhSC_SC_PSN_IJjS8_EERT1_(%class.anon.54.100.339.568.797*, double*, i8*, i32* dereferenceable(4), i32* dereferenceable(4), %"class.std::tuple.6.57.296.525.754"*, %class.anon.103.130.369.598.827* dereferenceable(24)) local_unnamed_addr #11

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZN4gbbs16bytepd_amortized17filter_sequentialIN4pbbs5emptyEZNS_3RunINS_15symmetric_graphINS_20csv_bytepd_amortizedES3_EEEEdRT_NS_11commandLineEEUlRKjSC_RKS3_E_ZZNS_12sample_edgesIS7_SF_EENS_10edge_arrayINS8_11weight_typeEEES9_RT0_ENKUlmE0_clEmEUlmRKSt5tupleIJjS3_EEE_EEvSK_PhSC_SC_RT1_(%class.anon.54.100.339.568.797*, double*, i8*, i32* dereferenceable(4), i32* dereferenceable(4), %class.anon.103.130.369.598.827* dereferenceable(24)) local_unnamed_addr #11

; Function Attrs: inlinehint ssp uwtable
declare hidden i64 @_ZN7pbbslib7filterfISt5tupleIJjN4pbbs5emptyEEEZN4gbbs16bytepd_amortized6filterIS3_ZNS5_3RunINS5_15symmetric_graphINS5_20csv_bytepd_amortizedES3_EEEEdRT_NS5_11commandLineEEUlRKjSG_RKS3_E_ZZNS5_12sample_edgesISB_SJ_EENS5_10edge_arrayINSC_11weight_typeEEESD_RT0_ENKUlmE0_clEmEUlmRKS4_E_EEvSO_PhSG_SG_PS1_IJjSC_EERT1_EUlSS_E_ST_EEmPSC_mSO_SX_m(%"class.std::tuple.6.57.296.525.754"*, i64, %class.anon.55.101.340.569.798*, i32*, %class.anon.103.130.369.598.827* byval(%class.anon.103.130.369.598.827) align 8, i64) local_unnamed_addr #11

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs16bytepd_amortized6filterIN4pbbs5emptyEZNS_3RunINS_15symmetric_graphINS_20csv_bytepd_amortizedES3_EEEEdRT_NS_11commandLineEEUlRKjSC_RKS3_E_ZZNS_12sample_edgesIS7_SF_EENS_10edge_arrayINS8_11weight_typeEEES9_RT0_ENKUlmE0_clEmEUlmRKSt5tupleIJjS3_EEE_EEvSK_PhSC_SC_PSN_IJjS8_EERT1_ENKUlmE_clEm(%class.anon.104.131.370.599.828*, i64) local_unnamed_addr #11 align 2

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZN4gbbs16bytepd_amortized6filterINS_5emptyEZNS1_3RunINS1_15symmetric_graphINS1_20csv_bytepd_amortizedES4_EEEEdRT_NS1_11commandLineEEUlRKjSD_RKS4_E_ZZNS1_12sample_edgesIS8_SG_EENS1_10edge_arrayINS9_11weight_typeEEESA_RT0_ENKUlmE0_clEmEUlmRKSt5tupleIJjS4_EEE_EEvSL_PhSD_SD_PSO_IJjS9_EERT1_EUlmE_EEvllS9_lb(i64, i64, %class.anon.104.131.370.599.828* byval(%class.anon.104.131.370.599.828) align 8) unnamed_addr #11

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZN7pbbslib7filterfISt5tupleIJjNS_5emptyEEEZN4gbbs16bytepd_amortized6filterIS4_ZNS6_3RunINS6_15symmetric_graphINS6_20csv_bytepd_amortizedES4_EEEEdRT_NS6_11commandLineEEUlRKjSH_RKS4_E_ZZNS6_12sample_edgesISC_SK_EENS6_10edge_arrayINSD_11weight_typeEEESE_RT0_ENKUlmE0_clEmEUlmRKS5_E_EEvSP_PhSH_SH_PS3_IJjSD_EERT1_EUlST_E_SU_EEmPSD_mSP_SY_mEUlmE_EEvllSD_lb(i64, i64, %class.anon.108.133.372.601.830* nocapture readonly byval(%class.anon.108.133.372.601.830) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZN7pbbslib7filterfISt5tupleIJjNS_5emptyEEEZN4gbbs16bytepd_amortized6filterIS4_ZNS6_3RunINS6_15symmetric_graphINS6_20csv_bytepd_amortizedES4_EEEEdRT_NS6_11commandLineEEUlRKjSH_RKS4_E_ZZNS6_12sample_edgesISC_SK_EENS6_10edge_arrayINSD_11weight_typeEEESE_RT0_ENKUlmE0_clEmEUlmRKS5_E_EEvSP_PhSH_SH_PS3_IJjSD_EERT1_EUlST_E_SU_EEmPSD_mSP_SY_mEUlmE0_EEvllSD_lb(i64, i64, %class.anon.109.134.373.602.831* nocapture readonly byval(%class.anon.109.134.373.602.831) align 8) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs9connectit14liutarjan_PRFAINS_10edge_arrayIN4pbbs5emptyEEELb0EEEvRT_mRNS3_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmNS_11commandLineE(%"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %"struct.pbbs::sequence.62.94.333.562.791"* dereferenceable(16), i64, i64, i64, %"struct.gbbs::commandLine.49.288.517.746"*) #8

; Function Attrs: ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs9connectit27run_multiple_liu_tarjan_algINS_10edge_arrayIN4pbbs5emptyEEELNS_22LiuTarjanConnectOptionE1ELNS_21LiuTarjanUpdateOptionE1ELNS_23LiuTarjanShortcutOptionE0ELNS_20LiuTarjanAlterOptionE1ELb0EEEbRT_mRNS3_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmRNS_11commandLineE(%"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %"struct.pbbs::sequence.62.94.333.562.791"* dereferenceable(16), i64, i64, i64, %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48)) local_unnamed_addr #8

declare dso_local void @_ZN4gbbs9connectit28liu_tarjan_options_to_stringB5cxx11ENS_14SamplingOptionENS_22LiuTarjanConnectOptionENS_21LiuTarjanUpdateOptionENS_23LiuTarjanShortcutOptionENS_20LiuTarjanAlterOptionE(%"class.std::__cxx11::basic_string.7.246.475.704"* sret, i32, i32, i32, i32, i32) local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs12run_multipleINS_10edge_arrayIN4pbbs5emptyEEEZNS_9connectit27run_multiple_liu_tarjan_algIS4_LNS_22LiuTarjanConnectOptionE1ELNS_21LiuTarjanUpdateOptionE1ELNS_23LiuTarjanShortcutOptionE0ELNS_20LiuTarjanAlterOptionE1ELb0EEEbRT_mRNS2_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmRNS_11commandLineEEUlRS4_SK_E_EEbSC_mNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESK_T0_(%"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %"class.std::__cxx11::basic_string.7.246.475.704"*, %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48), %class.anon.110.135.374.603.832* byval(%class.anon.110.135.374.603.832) align 8) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs6repeatINS_10edge_arrayIN4pbbs5emptyEEEZNS_9connectit27run_multiple_liu_tarjan_algIS4_LNS_22LiuTarjanConnectOptionE1ELNS_21LiuTarjanUpdateOptionE1ELNS_23LiuTarjanShortcutOptionE0ELNS_20LiuTarjanAlterOptionE1ELb0EEEbRT_mRNS2_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmRNS_11commandLineEEUlRS4_SK_E_EEDaSC_mT0_SK_(%"class.std::tuple.111.146.385.614.843"* noalias sret, %"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %class.anon.110.135.374.603.832* byval(%class.anon.110.135.374.603.832) align 8, %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48)) local_unnamed_addr #8

declare dso_local void @_ZN4gbbs9cpu_statsC1Ev(%"struct.gbbs::cpu_stats.147.386.615.844"*) unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs15print_cpu_statsINS_9cpu_statsEEEvRNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmmmdddddddddRT_RNS_11commandLineE(%"class.std::__cxx11::basic_string.7.246.475.704"* dereferenceable(32), i64, i64, i64, double, double, double, double, double, double, double, double, double, %"struct.gbbs::cpu_stats.147.386.615.844"* dereferenceable(96), %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48)) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs9connectit27run_multiple_liu_tarjan_algINS_10edge_arrayIN4pbbs5emptyEEELNS_22LiuTarjanConnectOptionE1ELNS_21LiuTarjanUpdateOptionE1ELNS_23LiuTarjanShortcutOptionE0ELNS_20LiuTarjanAlterOptionE1ELb0EEEbRT_mRNS3_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmRNS_11commandLineEENKUlRS5_SJ_E_clESK_SJ_(%"class.std::tuple.133.154.393.622.851"* noalias sret, %class.anon.110.135.374.603.832*, %"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48)) local_unnamed_addr #11 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs9connectit16run_abstract_algINS_10edge_arrayIN4pbbs5emptyEEENS_2lt18LiuTarjanAlgorithmIPFbjjRNS3_8sequenceIjEESA_ELNS_22LiuTarjanConnectOptionE1EPFvjSA_SA_ELNS_21LiuTarjanUpdateOptionE1EPFvjSA_ELNS_23LiuTarjanShortcutOptionE0EPFSt5tupleIJjjEEjjSA_ELNS_20LiuTarjanAlterOptionE1ES5_EELb0ELb1EEEDaRT_mRNS8_ISK_IJjjNS_10UpdateTypeEEEEEmmbRT0_(%"class.std::tuple.133.154.393.622.851"* noalias sret, %"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %"struct.pbbs::sequence.62.94.333.562.791"* dereferenceable(16), i64, i64, i1 zeroext, %"struct.gbbs::lt::LiuTarjanAlgorithm.156.395.624.853"* dereferenceable(80)) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare hidden i64 @_ZN4gbbs6num_ccIN4pbbs8sequenceIjEEEEmRT_(%"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16)) local_unnamed_addr #11

; Function Attrs: ssp uwtable
declare hidden dereferenceable(16) %"struct.pbbs::sequence.39.278.507.736"* @_ZN4pbbs8sequenceIjEaSERKS1_(%"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16)) local_unnamed_addr #8 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE0EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE1ENS_10edge_arrayINS2_5emptyEEEE10initializeES5_(%"struct.gbbs::lt::LiuTarjanAlgorithm.156.395.624.853"*, %"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16)) local_unnamed_addr #8 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE0EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE1ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_(%"struct.gbbs::lt::LiuTarjanAlgorithm.156.395.624.853"*, %"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16), %"struct.pbbs::range.150.157.396.625.854"* dereferenceable(16)) local_unnamed_addr #8 align 2

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZN4gbbs8cc_checkIN4pbbs8sequenceIjEES3_EEvRT_RT0_(%"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16), %"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16)) local_unnamed_addr #11

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_8sequenceIjEC1IZN4gbbs9connectit16run_abstract_algINS4_10edge_arrayINS_5emptyEEENS4_2lt18LiuTarjanAlgorithmIPFbjjRS2_SC_ELNS4_22LiuTarjanConnectOptionE1EPFvjSC_SC_ELNS4_21LiuTarjanUpdateOptionE1EPFvjSC_ELNS4_23LiuTarjanShortcutOptionE0EPFSt5tupleIJjjEEjjSC_ELNS4_20LiuTarjanAlterOptionE1ES9_EELb0ELb1EEEDaRT_mRNS1_ISM_IJjjNS4_10UpdateTypeEEEEEmmbRT0_EUlmE_EEmSS_EUlmE_EEvllSS_lb(i64, i64, %"struct.pbbs::sequence.39.278.507.736"*, %class.anon.148.158.397.626.855*) unnamed_addr #9

; Function Attrs: ssp uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSolsEj(%"class.std::basic_ostream.23.262.491.720"*, i32) local_unnamed_addr #8 align 2

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_8sequenceIjEC1IZN4gbbs6num_ccIS2_EEmRT_EUlmE_EEmS6_EUlmE_EEvllS6_lb(i64, i64, %"struct.pbbs::sequence.39.278.507.736"*, %class.anon.154.159.398.627.856*) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZN4gbbs6num_ccINS_8sequenceIjEEEEmRT_EUlmE0_EEvllS5_lb(i64, i64, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden i32 @_ZN4pbbs5scan_INS_5rangeIPjEES3_NS_4addmIjEEEENT_10value_typeERKS6_OT0_RKT1_jPS7_(%"struct.pbbs::range.92.112.351.580.809"* dereferenceable(16), %"struct.pbbs::range.92.112.351.580.809"* dereferenceable(16), %"struct.pbbs::addm.158.160.399.628.857"* dereferenceable(4), i32, i32*) local_unnamed_addr #8

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_5scan_INS_5rangeIPjEES5_NS_4addmIjEEEENT_10value_typeERKS8_OT0_RKT1_jPS9_EUlmmmE_EEvmmSB_jEUlmE_EEvllS8_lb(i64, i64, %class.anon.161.162.401.630.859* nocapture readonly byval(%class.anon.161.162.401.630.859) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_5scan_INS_5rangeIPjEES5_NS_4addmIjEEEENT_10value_typeERKS8_OT0_RKT1_jPS9_EUlmmmE0_EEvmmSB_jEUlmE_EEvllS8_lb(i64, i64, %class.anon.162.164.403.632.861* nocapture readonly byval(%class.anon.162.164.403.632.861) align 8) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs9split_twoINS_5rangeIPSt5tupleIJjjN4gbbs10UpdateTypeEEEEENS_16delayed_sequenceIbZNS3_15reorder_updatesIS7_EESt4pairINS_8sequenceIS5_EEmERT_EUlmE_EEEESA_INSB_INSE_10value_typeEEEmERKSE_RKT0_j(%"struct.std::pair.167.165.404.633.862"* noalias sret, %"struct.pbbs::range.150.157.396.625.854"* dereferenceable(16), %"struct.pbbs::delayed_sequence.181.167.406.635.864"* dereferenceable(24), i32) local_unnamed_addr #8

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_9split_twoINS_5rangeIPSt5tupleIJjjN4gbbs10UpdateTypeEEEEENS_16delayed_sequenceIbZNS5_15reorder_updatesIS9_EESt4pairINS_8sequenceIS7_EEmERT_EUlmE_EEEESC_INSD_INSG_10value_typeEEEmERKSG_RKT0_jEUlmmmE_EEvmmSO_jEUlmE_EEvllSG_lb(i64, i64, %class.anon.185.169.408.637.866* nocapture readonly byval(%class.anon.185.169.408.637.866) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_9split_twoINS_5rangeIPSt5tupleIJjjN4gbbs10UpdateTypeEEEEENS_16delayed_sequenceIbZNS5_15reorder_updatesIS9_EESt4pairINS_8sequenceIS7_EEmERT_EUlmE_EEEESC_INSD_INSG_10value_typeEEEmERKSG_RKT0_jEUlmmmE0_EEvmmSO_jEUlmE_EEvllSG_lb(i64, i64, %class.anon.186.171.410.639.868* nocapture readonly byval(%class.anon.186.171.410.639.868) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_8sequenceISt4pairIjjEEC1IZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRNS1_IjEESA_ELNS6_22LiuTarjanConnectOptionE1EPFvjSA_SA_ELNS6_21LiuTarjanUpdateOptionE1EPFvjSA_ELNS6_23LiuTarjanShortcutOptionE0EPFSt5tupleIJjjEEjjSA_ELNS6_20LiuTarjanAlterOptionE1ENS6_10edge_arrayINS_5emptyEEEE13process_batchILb1ENS_5rangeIPSK_IJjjNS6_10UpdateTypeEEEEEEEvSA_RT0_EUlmE_EEmT_EUlmE_EEvllS12_lb(i64, i64, %"struct.pbbs::sequence.170.172.411.640.869"*, %class.anon.174.173.412.641.870*) unnamed_addr #9

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE0EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE1ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE1_clEm(%class.anon.176.174.413.642.871*, i64) local_unnamed_addr #11 align 2

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE0EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE1ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE3_clEm(%class.anon.178.175.414.643.872*, i64) local_unnamed_addr #11 align 2

; Function Attrs: ssp uwtable
declare dso_local void @_ZNSt6vectorIdSaIdEE17_M_realloc_insertIJRdEEEvN9__gnu_cxx17__normal_iteratorIPdS1_EEDpOT_(%"class.std::vector.48.287.516.745"*, double*, double* dereferenceable(8)) local_unnamed_addr #8 align 2

; Function Attrs: noreturn
declare dso_local void @_ZSt20__throw_length_errorPKc(i8*) local_unnamed_addr #14

; Function Attrs: noreturn
declare dso_local void @_ZSt17__throw_bad_allocv() local_unnamed_addr #14

; Function Attrs: inlinehint ssp uwtable
declare hidden i32 @_ZN4gbbs14unite_variants5UniteIPFjjRN4pbbs8sequenceIjEEEEclEjjS5_(%"struct.gbbs::unite_variants::Unite.176.415.644.873"*, i32, i32, %"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16)) local_unnamed_addr #11 align 2

; Function Attrs: inlinehint nounwind ssp uwtable
declare hidden i32 @_ZN4gbbs13find_variants13find_compressEjRN4pbbs8sequenceIjEE(i32, %"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16)) #9

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs8cc_checkIN4pbbs8sequenceIjEES3_EEvRT_RT0_ENKUlmE_clEm(%class.anon.191.177.416.645.874*, i64) local_unnamed_addr #11 align 2

declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSo9_M_insertIbEERSoT_(%"class.std::basic_ostream.23.262.491.720"*, i1 zeroext) local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare dso_local void @_ZNSt6vectorIdSaIdEE17_M_realloc_insertIJRKdEEEvN9__gnu_cxx17__normal_iteratorIPdS1_EEDpOT_(%"class.std::vector.48.287.516.745"*, double*, double* dereferenceable(8)) local_unnamed_addr #8 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZNSt11_Tuple_implILm0EJSt6vectorIdSaIdEES2_S2_mmEEC2IRS2_JS5_S5_RmS6_EvEEOT_DpOT0_(%"struct.std::_Tuple_impl.112.145.384.613.842"*, %"class.std::vector.48.287.516.745"* dereferenceable(24), %"class.std::vector.48.287.516.745"* dereferenceable(24), %"class.std::vector.48.287.516.745"* dereferenceable(24), i64* dereferenceable(8), i64* dereferenceable(8)) unnamed_addr #8 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZNSt11_Tuple_implILm1EJSt6vectorIdSaIdEES2_mmEEC2IRS2_JS5_RmS6_EvEEOT_DpOT0_(%"struct.std::_Tuple_impl.113.143.382.611.840"*, %"class.std::vector.48.287.516.745"* dereferenceable(24), %"class.std::vector.48.287.516.745"* dereferenceable(24), i64* dereferenceable(8), i64* dereferenceable(8)) unnamed_addr #8 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZNSt11_Tuple_implILm1EJRSt6vectorIdSaIdEES3_RmS4_EE9_M_assignIS2_JS2_mmEEEvOS_ILm1EJT_DpT0_EE(%"struct.std::_Tuple_impl.124.185.424.653.882"*, %"struct.std::_Tuple_impl.113.143.382.611.840"* dereferenceable(64)) local_unnamed_addr #8 align 2

; Function Attrs: nounwind ssp uwtable
declare hidden void @_ZNSt12_Vector_baseIdSaIdEED2Ev(%"struct.std::_Vector_base.47.286.515.744"*) unnamed_addr #4 align 2

declare dso_local double @_ZN4gbbs9cpu_stats7get_ipcEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

declare dso_local i64 @_ZN4gbbs9cpu_stats16get_total_cyclesEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

declare dso_local double @_ZN4gbbs9cpu_stats16get_l2_hit_ratioEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

declare dso_local double @_ZN4gbbs9cpu_stats16get_l3_hit_ratioEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

declare dso_local i64 @_ZN4gbbs9cpu_stats13get_l2_missesEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

declare dso_local i64 @_ZN4gbbs9cpu_stats11get_l2_hitsEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

declare dso_local i64 @_ZN4gbbs9cpu_stats13get_l3_missesEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

declare dso_local i64 @_ZN4gbbs9cpu_stats11get_l3_hitsEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

declare dso_local double @_ZN4gbbs9cpu_stats14get_throughputEv(%"struct.gbbs::cpu_stats.147.386.615.844"*) local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare dso_local void @_ZN9__gnu_cxx12__to_xstringINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEcEET_PFiPT0_mPKS8_P13__va_list_tagEmSB_z(%"class.std::__cxx11::basic_string.7.246.475.704"* noalias sret, i32 (i8*, i64, i8*, %struct.__va_list_tag.186.425.654.883*)*, i64, i8*, ...) local_unnamed_addr #8

; Function Attrs: alwaysinline nobuiltin nounwind ssp uwtable
declare dso_local i32 @vsnprintf(i8* noalias, i64, i8* noalias, %struct.__va_list_tag.186.425.654.883*) #22

; Function Attrs: nounwind
declare void @llvm.va_start(i8*) #23

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #23

; Function Attrs: nofree
declare dso_local i32 @__vsnprintf_chk(i8*, i64, i32, i64, i8*, %struct.__va_list_tag.186.425.654.883*) local_unnamed_addr #24

declare dso_local void @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_M_constructEmc(%"class.std::__cxx11::basic_string.7.246.475.704"*, i64, i8 signext) local_unnamed_addr #0

; Function Attrs: ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs9connectit27run_multiple_liu_tarjan_algINS_10edge_arrayIN4pbbs5emptyEEELNS_22LiuTarjanConnectOptionE1ELNS_21LiuTarjanUpdateOptionE1ELNS_23LiuTarjanShortcutOptionE1ELNS_20LiuTarjanAlterOptionE0ELb0EEEbRT_mRNS3_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmRNS_11commandLineE(%"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %"struct.pbbs::sequence.62.94.333.562.791"* dereferenceable(16), i64, i64, i64, %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48)) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden zeroext i1 @_ZN4gbbs12run_multipleINS_10edge_arrayIN4pbbs5emptyEEEZNS_9connectit27run_multiple_liu_tarjan_algIS4_LNS_22LiuTarjanConnectOptionE1ELNS_21LiuTarjanUpdateOptionE1ELNS_23LiuTarjanShortcutOptionE1ELNS_20LiuTarjanAlterOptionE0ELb0EEEbRT_mRNS2_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmRNS_11commandLineEEUlRS4_SK_E_EEbSC_mNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESK_T0_(%"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %"class.std::__cxx11::basic_string.7.246.475.704"*, %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48), %class.anon.193.187.426.655.884* byval(%class.anon.193.187.426.655.884) align 8) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs6repeatINS_10edge_arrayIN4pbbs5emptyEEEZNS_9connectit27run_multiple_liu_tarjan_algIS4_LNS_22LiuTarjanConnectOptionE1ELNS_21LiuTarjanUpdateOptionE1ELNS_23LiuTarjanShortcutOptionE1ELNS_20LiuTarjanAlterOptionE0ELb0EEEbRT_mRNS2_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmRNS_11commandLineEEUlRS4_SK_E_EEDaSC_mT0_SK_(%"class.std::tuple.111.146.385.614.843"* noalias sret, %"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %class.anon.193.187.426.655.884* byval(%class.anon.193.187.426.655.884) align 8, %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48)) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs9connectit27run_multiple_liu_tarjan_algINS_10edge_arrayIN4pbbs5emptyEEELNS_22LiuTarjanConnectOptionE1ELNS_21LiuTarjanUpdateOptionE1ELNS_23LiuTarjanShortcutOptionE1ELNS_20LiuTarjanAlterOptionE0ELb0EEEbRT_mRNS3_8sequenceISt5tupleIJjjNS_10UpdateTypeEEEEEmmmRNS_11commandLineEENKUlRS5_SJ_E_clESK_SJ_(%"class.std::tuple.133.154.393.622.851"* noalias sret, %class.anon.193.187.426.655.884*, %"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), %"struct.gbbs::commandLine.49.288.517.746"* dereferenceable(48)) local_unnamed_addr #11 align 2

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs9connectit16run_abstract_algINS_10edge_arrayIN4pbbs5emptyEEENS_2lt18LiuTarjanAlgorithmIPFbjjRNS3_8sequenceIjEESA_ELNS_22LiuTarjanConnectOptionE1EPFvjSA_SA_ELNS_21LiuTarjanUpdateOptionE1EPFvjSA_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjSA_ELNS_20LiuTarjanAlterOptionE0ES5_EELb0ELb1EEEDaRT_mRNS8_ISK_IJjjNS_10UpdateTypeEEEEEmmbRT0_(%"class.std::tuple.133.154.393.622.851"* noalias sret, %"struct.gbbs::edge_array.99.338.567.796"* dereferenceable(48), i64, %"struct.pbbs::sequence.62.94.333.562.791"* dereferenceable(16), i64, i64, i1 zeroext, %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* dereferenceable(80)) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE10initializeES5_(%"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"*, %"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16)) local_unnamed_addr #8 align 2

; Function Attrs: ssp uwtable
define linkonce_odr hidden void @_ZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_(%"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* %this, %"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16) %parents, %"struct.pbbs::range.150.157.396.625.854"* dereferenceable(16) %updates) local_unnamed_addr #8 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %__dnew.i.i.i.i501 = alloca i64, align 8
  %syncreg.i.i = tail call token @llvm.syncregion.start()
  %__dnew.i.i.i.i388 = alloca i64, align 8
  %__dnew.i.i.i.i283 = alloca i64, align 8
  %agg.tmp88261 = alloca %class.anon.205.192.431.660.889, align 8
  %__dnew.i.i.i.i215 = alloca i64, align 8
  %__dnew.i.i.i.i172 = alloca i64, align 8
  %agg.tmp57137 = alloca %class.anon.203.191.430.659.888, align 8
  %__dnew.i.i.i.i97 = alloca i64, align 8
  %__dnew.i.i.i.i58 = alloca i64, align 8
  %__dnew.i.i.i.i = alloca i64, align 8
  %f.i = alloca %class.anon.201.190.429.658.887, align 8
  %bool_seq.i = alloca %"struct.pbbs::delayed_sequence.181.167.406.635.864", align 8
  %ret = alloca %"struct.std::pair.167.165.404.633.862", align 8
  %insertions = alloca %"struct.pbbs::range.150.157.396.625.854", align 8
  %inserts = alloca %"struct.pbbs::sequence.170.172.411.640.869", align 8
  %parents_changed = alloca i8, align 1
  %pc = alloca %"struct.pbbs::timer.8.247.476.705", align 8
  %agg.tmp20 = alloca %"class.std::__cxx11::basic_string.7.246.475.704", align 8
  %ref.tmp34 = alloca %"class.std::__cxx11::basic_string.7.246.475.704", align 8
  %ut = alloca %"struct.pbbs::timer.8.247.476.705", align 8
  %agg.tmp44 = alloca %"class.std::__cxx11::basic_string.7.246.475.704", align 8
  %ref.tmp65 = alloca %"class.std::__cxx11::basic_string.7.246.475.704", align 8
  %sc = alloca %"struct.pbbs::timer.8.247.476.705", align 8
  %agg.tmp75 = alloca %"class.std::__cxx11::basic_string.7.246.475.704", align 8
  %ref.tmp92 = alloca %"class.std::__cxx11::basic_string.7.246.475.704", align 8
  %at = alloca %"struct.pbbs::timer.8.247.476.705", align 8
  %agg.tmp106 = alloca %"class.std::__cxx11::basic_string.7.246.475.704", align 8
  %nullary_edge = alloca i64, align 8
  %tmpcast = bitcast i64* %nullary_edge to %"struct.std::pair.171.38.277.506.735"*
  %new_inserts = alloca %"struct.pbbs::sequence.170.172.411.640.869", align 8
  %ref.tmp135 = alloca %"class.std::__cxx11::basic_string.7.246.475.704", align 8
  %0 = bitcast %"struct.std::pair.167.165.404.633.862"* %ret to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %0) #23
  %1 = bitcast %"struct.pbbs::delayed_sequence.181.167.406.635.864"* %bool_seq.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %1) #23, !noalias !2
  %e.i.i = getelementptr inbounds %"struct.pbbs::range.150.157.396.625.854", %"struct.pbbs::range.150.157.396.625.854"* %updates, i64 0, i32 1
  %2 = bitcast %"class.std::tuple.63.93.332.561.790"** %e.i.i to i64*
  %3 = load i64, i64* %2, align 8, !tbaa !5, !noalias !2
  %4 = bitcast %"struct.pbbs::range.150.157.396.625.854"* %updates to i64*
  %5 = load i64, i64* %4, align 8, !tbaa !10, !noalias !2
  %sub.ptr.sub.i.i = sub i64 %3, %5
  %sub.ptr.div.i.i = sdiv exact i64 %sub.ptr.sub.i.i, 12
  %_f.sroa.0.0..sroa_idx.i.i.i = getelementptr inbounds %"struct.pbbs::delayed_sequence.181.167.406.635.864", %"struct.pbbs::delayed_sequence.181.167.406.635.864"* %bool_seq.i, i64 0, i32 0, i32 0
  store %"struct.pbbs::range.150.157.396.625.854"* %updates, %"struct.pbbs::range.150.157.396.625.854"** %_f.sroa.0.0..sroa_idx.i.i.i, align 8, !tbaa.struct !11, !alias.scope !13, !noalias !2
  %s.i.i.i = getelementptr inbounds %"struct.pbbs::delayed_sequence.181.167.406.635.864", %"struct.pbbs::delayed_sequence.181.167.406.635.864"* %bool_seq.i, i64 0, i32 1
  store i64 0, i64* %s.i.i.i, align 8, !tbaa !16, !alias.scope !13, !noalias !2
  %e.i.i.i = getelementptr inbounds %"struct.pbbs::delayed_sequence.181.167.406.635.864", %"struct.pbbs::delayed_sequence.181.167.406.635.864"* %bool_seq.i, i64 0, i32 2
  store i64 %sub.ptr.div.i.i, i64* %e.i.i.i, align 8, !tbaa !20, !alias.scope !13, !noalias !2
  call void @_ZN4pbbs9split_twoINS_5rangeIPSt5tupleIJjjN4gbbs10UpdateTypeEEEEENS_16delayed_sequenceIbZNS3_15reorder_updatesIS7_EESt4pairINS_8sequenceIS5_EEmERT_EUlmE_EEEESA_INSB_INSE_10value_typeEEEmERKSE_RKT0_j(%"struct.std::pair.167.165.404.633.862"* nonnull sret %ret, %"struct.pbbs::range.150.157.396.625.854"* nonnull dereferenceable(16) %updates, %"struct.pbbs::delayed_sequence.181.167.406.635.864"* nonnull dereferenceable(24) %bool_seq.i, i32 0)
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %1) #23, !noalias !2
  %n2.i = getelementptr inbounds %"struct.std::pair.167.165.404.633.862", %"struct.std::pair.167.165.404.633.862"* %ret, i64 0, i32 0, i32 1
  %s.i = getelementptr inbounds %"struct.std::pair.167.165.404.633.862", %"struct.std::pair.167.165.404.633.862"* %ret, i64 0, i32 0, i32 0
  %6 = load i64, i64* %n2.i, align 8, !tbaa !21
  %mul.i.i.i = mul i64 %6, 12
  %div7.i.i.i = add i64 %mul.i.i.i, 64
  %mul1.i.i.i = and i64 %div7.i.i.i, -64
  %call.i.i.i.i = call noalias i8* @malloc(i64 %mul1.i.i.i) #23
  %cmp.i.i.i = icmp eq i8* %call.i.i.i.i, null
  br i1 %cmp.i.i.i, label %if.then.i.i.i, label %_ZN4pbbs17new_array_no_initISt5tupleIJjjN4gbbs10UpdateTypeEEEEEPT_mb.exit.i.i

if.then.i.i.i:                                    ; preds = %entry
  %7 = load %struct._IO_FILE.30.269.498.727*, %struct._IO_FILE.30.269.498.727** @stderr, align 8, !tbaa !12
  %call2.i.i.i = call i32 (%struct._IO_FILE.30.269.498.727*, i8*, ...) @fprintf(%struct._IO_FILE.30.269.498.727* %7, i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.18, i64 0, i64 0), i64 %mul1.i.i.i) #25
  call void @exit(i32 1) #26
  unreachable

_ZN4pbbs17new_array_no_initISt5tupleIJjjN4gbbs10UpdateTypeEEEEEPT_mb.exit.i.i: ; preds = %entry
  %8 = bitcast i8* %call.i.i.i.i to %"class.std::tuple.63.93.332.561.790"*
  %cmp1.i.i.i = icmp sgt i64 %6, 0
  br i1 %cmp1.i.i.i, label %pfor.cond.i.i.i.preheader, label %invoke.cont7

pfor.cond.i.i.i.preheader:                        ; preds = %_ZN4pbbs17new_array_no_initISt5tupleIJjjN4gbbs10UpdateTypeEEEEEPT_mb.exit.i.i
  br label %pfor.cond.i.i.i

pfor.cond.i.i.i:                                  ; preds = %pfor.inc.i.i.i, %pfor.cond.i.i.i.preheader
  %__begin.0.i.i.i = phi i64 [ %inc.i.i.i, %pfor.inc.i.i.i ], [ 0, %pfor.cond.i.i.i.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i.i.i, label %pfor.inc.i.i.i

pfor.body.entry.i.i.i:                            ; preds = %pfor.cond.i.i.i
  %arrayidx.i.i.i.i = getelementptr inbounds %"class.std::tuple.63.93.332.561.790", %"class.std::tuple.63.93.332.561.790"* %8, i64 %__begin.0.i.i.i
  %9 = load %"class.std::tuple.63.93.332.561.790"*, %"class.std::tuple.63.93.332.561.790"** %s.i, align 8, !tbaa !12
  %arrayidx2.i.i.i.i = getelementptr inbounds %"class.std::tuple.63.93.332.561.790", %"class.std::tuple.63.93.332.561.790"* %9, i64 %__begin.0.i.i.i
  %10 = bitcast %"class.std::tuple.63.93.332.561.790"* %arrayidx.i.i.i.i to i8*
  %11 = bitcast %"class.std::tuple.63.93.332.561.790"* %arrayidx2.i.i.i.i to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 4 dereferenceable(12) %10, i8* nonnull align 4 dereferenceable(12) %11, i64 12, i1 false) #23
  reattach within %syncreg.i.i, label %pfor.inc.i.i.i

pfor.inc.i.i.i:                                   ; preds = %pfor.body.entry.i.i.i, %pfor.cond.i.i.i
  %inc.i.i.i = add nuw nsw i64 %__begin.0.i.i.i, 1
  %cmp4.i.i.i = icmp slt i64 %inc.i.i.i, %6
  br i1 %cmp4.i.i.i, label %pfor.cond.i.i.i, label %pfor.cond.cleanup.i.i.i, !llvm.loop !23

pfor.cond.cleanup.i.i.i:                          ; preds = %pfor.inc.i.i.i
  sync within %syncreg.i.i, label %sync.continue.i.i.i

sync.continue.i.i.i:                              ; preds = %pfor.cond.cleanup.i.i.i
  call void @llvm.sync.unwind(token %syncreg.i.i) #23
  br label %invoke.cont7

invoke.cont7:                                     ; preds = %sync.continue.i.i.i, %_ZN4pbbs17new_array_no_initISt5tupleIJjjN4gbbs10UpdateTypeEEEEEPT_mb.exit.i.i
  %second = getelementptr inbounds %"struct.std::pair.167.165.404.633.862", %"struct.std::pair.167.165.404.633.862"* %ret, i64 0, i32 1
  %12 = load i64, i64* %second, align 8, !tbaa !25
  %13 = bitcast %"struct.pbbs::range.150.157.396.625.854"* %insertions to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %13) #23
  %add.ptr3.i = getelementptr inbounds %"class.std::tuple.63.93.332.561.790", %"class.std::tuple.63.93.332.561.790"* %8, i64 %12
  %14 = bitcast %"struct.pbbs::range.150.157.396.625.854"* %insertions to i8**
  store i8* %call.i.i.i.i, i8** %14, align 8
  %15 = getelementptr inbounds %"struct.pbbs::range.150.157.396.625.854", %"struct.pbbs::range.150.157.396.625.854"* %insertions, i64 0, i32 1
  store %"class.std::tuple.63.93.332.561.790"* %add.ptr3.i, %"class.std::tuple.63.93.332.561.790"** %15, align 8
  %16 = load i64, i64* %2, align 8, !tbaa !5
  %17 = load i64, i64* %4, align 8, !tbaa !10
  %sub.ptr.sub.i = sub i64 %16, %17
  %sub.ptr.div.i = sdiv exact i64 %sub.ptr.sub.i, 12
  %add.ptr3.i19 = getelementptr inbounds %"class.std::tuple.63.93.332.561.790", %"class.std::tuple.63.93.332.561.790"* %8, i64 %sub.ptr.div.i
  %18 = ptrtoint %"class.std::tuple.63.93.332.561.790"* %add.ptr3.i to i64
  %19 = ptrtoint %"class.std::tuple.63.93.332.561.790"* %add.ptr3.i19 to i64
  %20 = bitcast %"struct.pbbs::sequence.170.172.411.640.869"* %inserts to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %20) #23
  %21 = bitcast %"class.std::tuple.63.93.332.561.790"** %15 to i64*
  %22 = load i64, i64* %21, align 8, !tbaa !5
  %23 = bitcast %"struct.pbbs::range.150.157.396.625.854"* %insertions to i64*
  %24 = load i64, i64* %23, align 8, !tbaa !10
  %sub.ptr.sub.i26 = sub i64 %22, %24
  %sub.ptr.div.i27 = sdiv exact i64 %sub.ptr.sub.i26, 12
  %25 = bitcast %class.anon.201.190.429.658.887* %f.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %25)
  %coerce.dive.i = getelementptr inbounds %class.anon.201.190.429.658.887, %class.anon.201.190.429.658.887* %f.i, i64 0, i32 0
  store %"struct.pbbs::range.150.157.396.625.854"* %insertions, %"struct.pbbs::range.150.157.396.625.854"** %coerce.dive.i, align 8
  %s.i30 = getelementptr inbounds %"struct.pbbs::sequence.170.172.411.640.869", %"struct.pbbs::sequence.170.172.411.640.869"* %inserts, i64 0, i32 0
  %26 = lshr i64 %sub.ptr.div.i27, 3
  %add.i.i = shl i64 %26, 6
  %mul1.i.i = add i64 %add.i.i, 64
  %call.i.i.i = call noalias i8* @malloc(i64 %mul1.i.i) #23
  %cmp.i.i31 = icmp eq i8* %call.i.i.i, null
  br i1 %cmp.i.i31, label %if.then.i.i32, label %invoke.cont12

if.then.i.i32:                                    ; preds = %invoke.cont7
  %27 = load %struct._IO_FILE.30.269.498.727*, %struct._IO_FILE.30.269.498.727** @stderr, align 8, !tbaa !12
  %call2.i.i = call i32 (%struct._IO_FILE.30.269.498.727*, i8*, ...) @fprintf(%struct._IO_FILE.30.269.498.727* %27, i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.18, i64 0, i64 0), i64 %mul1.i.i) #25
  call void @exit(i32 1) #26
  unreachable

invoke.cont12:                                    ; preds = %invoke.cont7
  %28 = bitcast %"struct.pbbs::sequence.170.172.411.640.869"* %inserts to i8**
  store i8* %call.i.i.i, i8** %28, align 8, !tbaa !27
  %n.i33 = getelementptr inbounds %"struct.pbbs::sequence.170.172.411.640.869", %"struct.pbbs::sequence.170.172.411.640.869"* %inserts, i64 0, i32 1
  store i64 %sub.ptr.div.i27, i64* %n.i33, align 8, !tbaa !29
  call fastcc void @_ZN4pbbsL12parallel_forIZNS_8sequenceISt4pairIjjEEC1IZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRNS1_IjEESA_ELNS6_22LiuTarjanConnectOptionE1EPFvjSA_SA_ELNS6_21LiuTarjanUpdateOptionE1EPFvjSA_ELNS6_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjSA_ELNS6_20LiuTarjanAlterOptionE0ENS6_10edge_arrayINS_5emptyEEEE13process_batchILb1ENS_5rangeIPSK_IJjjNS6_10UpdateTypeEEEEEEEvSA_RT0_EUlmE_EEmT_EUlmE_EEvllS12_lb(i64 0, i64 %sub.ptr.div.i27, %"struct.pbbs::sequence.170.172.411.640.869"* nonnull %inserts, %class.anon.201.190.429.658.887* nonnull %f.i)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %25)
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %parents_changed)
  store i8 1, i8* %parents_changed, align 1, !tbaa !30
  br label %while.body

while.body:                                       ; preds = %_ZN4pbbs5timerD2Ev.exit575, %invoke.cont12
  %round.0262 = phi i64 [ 0, %invoke.cont12 ], [ %inc, %_ZN4pbbs5timerD2Ev.exit575 ]
  %inc = add i64 %round.0262, 1
  store i8 0, i8* %parents_changed, align 1, !tbaa !30
  %call1.i35 = invoke dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream.23.262.491.720"* nonnull dereferenceable(272) @_ZSt4cout, i8* nonnull getelementptr inbounds ([11 x i8], [11 x i8]* @.str.48, i64 0, i64 0), i64 10)
          to label %invoke.cont14 unwind label %lpad13.loopexit

invoke.cont14:                                    ; preds = %while.body
  %call.i36 = invoke dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream.23.262.491.720"* nonnull @_ZSt4cout, i64 %inc)
          to label %invoke.cont16 unwind label %lpad13.loopexit

invoke.cont16:                                    ; preds = %invoke.cont14
  %29 = bitcast %"class.std::basic_ostream.23.262.491.720"* %call.i36 to i8**
  %vtable.i = load i8*, i8** %29, align 8, !tbaa !32
  %vbase.offset.ptr.i = getelementptr i8, i8* %vtable.i, i64 -24
  %30 = bitcast i8* %vbase.offset.ptr.i to i64*
  %vbase.offset.i = load i64, i64* %30, align 8
  %add.ptr.i38 = getelementptr inbounds %"class.std::basic_ostream.23.262.491.720", %"class.std::basic_ostream.23.262.491.720"* %call.i36, i64 0, i32 1, i32 4
  %31 = bitcast %"class.std::basic_streambuf.15.254.483.712"** %add.ptr.i38 to i8*
  %_M_ctype.i.i = getelementptr inbounds i8, i8* %31, i64 %vbase.offset.i
  %32 = bitcast i8* %_M_ctype.i.i to %"class.std::ctype.19.258.487.716"**
  %33 = load %"class.std::ctype.19.258.487.716"*, %"class.std::ctype.19.258.487.716"** %32, align 8, !tbaa !34
  %tobool.i.i.i = icmp eq %"class.std::ctype.19.258.487.716"* %33, null
  br i1 %tobool.i.i.i, label %if.then.i.i.i39, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i

if.then.i.i.i39:                                  ; preds = %invoke.cont16
  invoke void @_ZSt16__throw_bad_castv() #27
          to label %.noexc unwind label %lpad13.loopexit.split-lp

.noexc:                                           ; preds = %if.then.i.i.i39
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i: ; preds = %invoke.cont16
  %_M_widen_ok.i.i.i = getelementptr inbounds %"class.std::ctype.19.258.487.716", %"class.std::ctype.19.258.487.716"* %33, i64 0, i32 8
  %34 = load i8, i8* %_M_widen_ok.i.i.i, align 8, !tbaa !36
  %tobool.i1.i.i = icmp eq i8 %34, 0
  br i1 %tobool.i1.i.i, label %if.end.i.i.i, label %if.then.i2.i.i

if.then.i2.i.i:                                   ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i
  %arrayidx.i.i.i = getelementptr inbounds %"class.std::ctype.19.258.487.716", %"class.std::ctype.19.258.487.716"* %33, i64 0, i32 9, i64 10
  %35 = load i8, i8* %arrayidx.i.i.i, align 1, !tbaa !38
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i

if.end.i.i.i:                                     ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i
  invoke void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype.19.258.487.716"* nonnull %33)
          to label %.noexc41 unwind label %lpad13.loopexit

.noexc41:                                         ; preds = %if.end.i.i.i
  %36 = bitcast %"class.std::ctype.19.258.487.716"* %33 to i8 (%"class.std::ctype.19.258.487.716"*, i8)***
  %vtable.i.i.i = load i8 (%"class.std::ctype.19.258.487.716"*, i8)**, i8 (%"class.std::ctype.19.258.487.716"*, i8)*** %36, align 8, !tbaa !32
  %vfn.i.i.i = getelementptr inbounds i8 (%"class.std::ctype.19.258.487.716"*, i8)*, i8 (%"class.std::ctype.19.258.487.716"*, i8)** %vtable.i.i.i, i64 6
  %37 = load i8 (%"class.std::ctype.19.258.487.716"*, i8)*, i8 (%"class.std::ctype.19.258.487.716"*, i8)** %vfn.i.i.i, align 8
  %call.i.i.i4042 = invoke signext i8 %37(%"class.std::ctype.19.258.487.716"* nonnull %33, i8 signext 10)
          to label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i unwind label %lpad13.loopexit

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i: ; preds = %.noexc41, %if.then.i2.i.i
  %retval.0.i.i.i = phi i8 [ %35, %if.then.i2.i.i ], [ %call.i.i.i4042, %.noexc41 ]
  %call1.i43 = invoke dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSo3putEc(%"class.std::basic_ostream.23.262.491.720"* nonnull %call.i36, i8 signext %retval.0.i.i.i)
          to label %call1.i.noexc unwind label %lpad13.loopexit

call1.i.noexc:                                    ; preds = %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i
  %call.i.i44 = invoke dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSo5flushEv(%"class.std::basic_ostream.23.262.491.720"* nonnull %call1.i43)
          to label %invoke.cont18 unwind label %lpad13.loopexit

invoke.cont18:                                    ; preds = %call1.i.noexc
  %38 = bitcast %"struct.pbbs::timer.8.247.476.705"* %pc to i8*
  call void @llvm.lifetime.start.p0i8(i64 56, i8* nonnull %38) #23
  %39 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp20, i64 0, i32 2
  %arraydecay.i.i = bitcast %union.anon.6.245.474.703* %39 to i8*
  %40 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp20 to %union.anon.6.245.474.703**
  store %union.anon.6.245.474.703* %39, %union.anon.6.245.474.703** %40, align 8, !tbaa !39
  %41 = bitcast i64* %__dnew.i.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %41) #23
  store i64 11, i64* %__dnew.i.i.i.i, align 8, !tbaa !41
  %_M_p.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp20, i64 0, i32 0, i32 0
  %42 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !42
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(11) %42, i8* nonnull align 1 dereferenceable(11) getelementptr inbounds ([12 x i8], [12 x i8]* @.str.6, i64 0, i64 0), i64 11, i1 false) #23
  %43 = load i64, i64* %__dnew.i.i.i.i, align 8, !tbaa !41
  %_M_string_length.i.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp20, i64 0, i32 1
  store i64 %43, i64* %_M_string_length.i.i.i.i.i.i, align 8, !tbaa !44
  %44 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !42
  %arrayidx.i.i.i.i.i = getelementptr inbounds i8, i8* %44, i64 %43
  store i8 0, i8* %arrayidx.i.i.i.i.i, align 1, !tbaa !38
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %41) #23
  invoke void @_ZN4pbbs5timerC1ENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEb(%"struct.pbbs::timer.8.247.476.705"* nonnull %pc, %"class.std::__cxx11::basic_string.7.246.475.704"* nonnull %agg.tmp20, i1 zeroext true)
          to label %invoke.cont24 unwind label %lpad23

invoke.cont24:                                    ; preds = %invoke.cont18
  %45 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !42
  %cmp.i.i.i47 = icmp eq i8* %45, %arraydecay.i.i
  br i1 %cmp.i.i.i47, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit, label %if.then.i.i48

if.then.i.i48:                                    ; preds = %invoke.cont24
  call void @_ZdlPv(i8* %45) #23
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit: ; preds = %if.then.i.i48, %invoke.cont24
  invoke void @_ZN4pbbs5timer5startEv(%"struct.pbbs::timer.8.247.476.705"* nonnull %pc)
          to label %invoke.cont27.tf unwind label %lpad26

invoke.cont27.tf:                                 ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
  %46 = load i64, i64* %n.i33, align 8, !tbaa !29
  %cmp1.i = icmp sgt i64 %46, 0
  br i1 %cmp1.i, label %pfor.cond.i.preheader, label %invoke.cont31.tfend

pfor.cond.i.preheader:                            ; preds = %invoke.cont27.tf
  br label %pfor.cond.i

pfor.cond.i:                                      ; preds = %pfor.inc.i, %pfor.cond.i.preheader
  %__begin.0.i = phi i64 [ %inc.i, %pfor.inc.i ], [ 0, %pfor.cond.i.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i, label %pfor.inc.i unwind label %lpad2654.loopexit

pfor.body.entry.i:                                ; preds = %pfor.cond.i
  %47 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  %arrayidx.i.i.i52 = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %47, i64 %__begin.0.i
  %48 = bitcast %"struct.std::pair.171.38.277.506.735"* %arrayidx.i.i.i52 to i64*
  %49 = load i64, i64* %48, align 4
  %.sroa.0.0.extract.trunc.i.i = trunc i64 %49 to i32
  %.sroa.4.0.extract.shift.i.i = lshr i64 %49, 32
  %.sroa.4.0.extract.trunc.i.i = trunc i64 %.sroa.4.0.extract.shift.i.i to i32
  %connect.i.i = getelementptr inbounds %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885", %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* %this, i64 0, i32 2
  %50 = load i1 (i32, i32, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*)**, i1 (i32, i32, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*)*** %connect.i.i, align 8, !tbaa !45
  %51 = load i1 (i32, i32, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*)*, i1 (i32, i32, %"struct.pbbs::sequence.39.278.507.736"*, %"struct.pbbs::sequence.39.278.507.736"*)** %50, align 8, !tbaa !12
  %messages.i.i = getelementptr inbounds %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885", %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* %this, i64 0, i32 6
  %call4.i.i56 = invoke zeroext i1 %51(i32 %.sroa.0.0.extract.trunc.i.i, i32 %.sroa.4.0.extract.trunc.i.i, %"struct.pbbs::sequence.39.278.507.736"* nonnull dereferenceable(16) %parents, %"struct.pbbs::sequence.39.278.507.736"* nonnull dereferenceable(16) %messages.i.i)
          to label %call4.i.i.noexc unwind label %lpad265455

call4.i.i.noexc:                                  ; preds = %pfor.body.entry.i
  %parents_changed.0.load687 = load i8, i8* %parents_changed, align 1
  %tobool5.i.i = icmp eq i8 %parents_changed.0.load687, 0
  %or.cond = and i1 %call4.i.i56, %tobool5.i.i
  br i1 %or.cond, label %if.then.i.i53, label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE0_clEm.exit.i

if.then.i.i53:                                    ; preds = %call4.i.i.noexc
  store i8 1, i8* %parents_changed, align 1, !tbaa !30
  br label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE0_clEm.exit.i

_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE0_clEm.exit.i: ; preds = %if.then.i.i53, %call4.i.i.noexc
  reattach within %syncreg.i.i, label %pfor.inc.i

pfor.inc.i:                                       ; preds = %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE0_clEm.exit.i, %pfor.cond.i
  %inc.i = add nuw nsw i64 %__begin.0.i, 1
  %cmp4.i = icmp slt i64 %inc.i, %46
  br i1 %cmp4.i, label %pfor.cond.i, label %pfor.cond.cleanup.i, !llvm.loop !49

pfor.cond.cleanup.i:                              ; preds = %pfor.inc.i
  sync within %syncreg.i.i, label %sync.continue.i

sync.continue.i:                                  ; preds = %pfor.cond.cleanup.i
  invoke void @llvm.sync.unwind(token %syncreg.i.i)
          to label %invoke.cont31.tfend unwind label %lpad2654.loopexit.split-lp

lpad2654.loopexit:                                ; preds = %lpad265455, %pfor.cond.i
  %lpad.loopexit4 = landingpad { i8*, i32 }
          cleanup
  br label %lpad2654

; CHECK: lpad2654.loopexit:
; CHECK-LCSSA-NEXT: phi i8*
; CHECK-LCSSA-DAG: [ %38, %lpad265455 ]
; CHECK-LCSSA-DAG: [ %38, %pfor.cond.i ]
; CHECK-NEXT: %lpad.loopexit4 = landingpad

lpad2654.loopexit.split-lp:                       ; preds = %sync.continue.i
  %.lcssa87 = phi i8* [ %38, %sync.continue.i ]
  %lpad.loopexit.split-lp5 = landingpad { i8*, i32 }
          cleanup
  br label %lpad2654

lpad2654:                                         ; preds = %lpad2654.loopexit.split-lp, %lpad2654.loopexit
  %52 = phi i8* [ %38, %lpad2654.loopexit ], [ %.lcssa87, %lpad2654.loopexit.split-lp ]
  %lpad.phi6 = phi { i8*, i32 } [ %lpad.loopexit4, %lpad2654.loopexit ], [ %lpad.loopexit.split-lp5, %lpad2654.loopexit.split-lp ]
  br label %lpad26.body

lpad2654.unreachable:                             ; preds = %lpad265455
  unreachable

lpad265455:                                       ; preds = %pfor.body.entry.i
  %53 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i, { i8*, i32 } %53)
          to label %lpad2654.unreachable unwind label %lpad2654.loopexit

invoke.cont31.tfend:                              ; preds = %sync.continue.i, %invoke.cont27.tf
  %call33 = invoke double @_ZN4pbbs5timer4stopEv(%"struct.pbbs::timer.8.247.476.705"* nonnull %pc)
          to label %invoke.cont32 unwind label %lpad26

invoke.cont32:                                    ; preds = %invoke.cont31.tfend
  %54 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp34 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %54) #23
  %55 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp34, i64 0, i32 2
  %arraydecay.i.i60 = bitcast %union.anon.6.245.474.703* %55 to i8*
  %56 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp34 to %union.anon.6.245.474.703**
  store %union.anon.6.245.474.703* %55, %union.anon.6.245.474.703** %56, align 8, !tbaa !39
  %57 = bitcast i64* %__dnew.i.i.i.i58 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %57) #23
  store i64 9, i64* %__dnew.i.i.i.i58, align 8, !tbaa !41
  %_M_p.i.i.i.i.i73 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp34, i64 0, i32 0, i32 0
  %58 = load i8*, i8** %_M_p.i.i.i.i.i73, align 8, !tbaa !42
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(9) %58, i8* nonnull align 1 dereferenceable(9) getelementptr inbounds ([10 x i8], [10 x i8]* @.str.49, i64 0, i64 0), i64 9, i1 false) #23
  %59 = load i64, i64* %__dnew.i.i.i.i58, align 8, !tbaa !41
  %_M_string_length.i.i.i.i.i.i83 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp34, i64 0, i32 1
  store i64 %59, i64* %_M_string_length.i.i.i.i.i.i83, align 8, !tbaa !44
  %60 = load i8*, i8** %_M_p.i.i.i.i.i73, align 8, !tbaa !42
  %arrayidx.i.i.i.i.i85 = getelementptr inbounds i8, i8* %60, i64 %59
  store i8 0, i8* %arrayidx.i.i.i.i.i85, align 1, !tbaa !38
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %57) #23
  invoke void @_ZNK4pbbs5timer11reportTotalERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"struct.pbbs::timer.8.247.476.705"* nonnull %pc, %"class.std::__cxx11::basic_string.7.246.475.704"* nonnull dereferenceable(32) %ref.tmp34)
          to label %invoke.cont39 unwind label %lpad38

invoke.cont39:                                    ; preds = %invoke.cont32
  %61 = load i8*, i8** %_M_p.i.i.i.i.i73, align 8, !tbaa !42
  %cmp.i.i.i91 = icmp eq i8* %61, %arraydecay.i.i60
  br i1 %cmp.i.i.i91, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96, label %if.then.i.i95

if.then.i.i95:                                    ; preds = %invoke.cont39
  call void @_ZdlPv(i8* %61) #23
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96: ; preds = %if.then.i.i95, %invoke.cont39
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %54) #23
  %62 = bitcast %"struct.pbbs::timer.8.247.476.705"* %ut to i8*
  call void @llvm.lifetime.start.p0i8(i64 56, i8* nonnull %62) #23
  %63 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp44, i64 0, i32 2
  %arraydecay.i.i99 = bitcast %union.anon.6.245.474.703* %63 to i8*
  %64 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp44 to %union.anon.6.245.474.703**
  store %union.anon.6.245.474.703* %63, %union.anon.6.245.474.703** %64, align 8, !tbaa !39
  %65 = bitcast i64* %__dnew.i.i.i.i97 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %65) #23
  store i64 11, i64* %__dnew.i.i.i.i97, align 8, !tbaa !41
  %_M_p.i.i.i.i.i112 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp44, i64 0, i32 0, i32 0
  %66 = load i8*, i8** %_M_p.i.i.i.i.i112, align 8, !tbaa !42
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(11) %66, i8* nonnull align 1 dereferenceable(11) getelementptr inbounds ([12 x i8], [12 x i8]* @.str.6, i64 0, i64 0), i64 11, i1 false) #23
  %67 = load i64, i64* %__dnew.i.i.i.i97, align 8, !tbaa !41
  %_M_string_length.i.i.i.i.i.i122 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp44, i64 0, i32 1
  store i64 %67, i64* %_M_string_length.i.i.i.i.i.i122, align 8, !tbaa !44
  %68 = load i8*, i8** %_M_p.i.i.i.i.i112, align 8, !tbaa !42
  %arrayidx.i.i.i.i.i124 = getelementptr inbounds i8, i8* %68, i64 %67
  store i8 0, i8* %arrayidx.i.i.i.i.i124, align 1, !tbaa !38
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %65) #23
  invoke void @_ZN4pbbs5timerC1ENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEb(%"struct.pbbs::timer.8.247.476.705"* nonnull %ut, %"class.std::__cxx11::basic_string.7.246.475.704"* nonnull %agg.tmp44, i1 zeroext true)
          to label %invoke.cont49 unwind label %lpad48

invoke.cont49:                                    ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96
  %69 = load i8*, i8** %_M_p.i.i.i.i.i112, align 8, !tbaa !42
  %cmp.i.i.i130 = icmp eq i8* %69, %arraydecay.i.i99
  br i1 %cmp.i.i.i130, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit135, label %if.then.i.i134

if.then.i.i134:                                   ; preds = %invoke.cont49
  call void @_ZdlPv(i8* %69) #23
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit135

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit135: ; preds = %if.then.i.i134, %invoke.cont49
  invoke void @_ZN4pbbs5timer5startEv(%"struct.pbbs::timer.8.247.476.705"* nonnull %ut)
          to label %invoke.cont54.tf unwind label %lpad53

invoke.cont54.tf:                                 ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit135
  %70 = load i64, i64* %n.i33, align 8, !tbaa !29
  %71 = bitcast %class.anon.203.191.430.659.888* %agg.tmp57137 to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %71)
  %agg.tmp57.sroa.0.0..sroa_idx = getelementptr inbounds %class.anon.203.191.430.659.888, %class.anon.203.191.430.659.888* %agg.tmp57137, i64 0, i32 0
  store %"struct.pbbs::sequence.170.172.411.640.869"* %inserts, %"struct.pbbs::sequence.170.172.411.640.869"** %agg.tmp57.sroa.0.0..sroa_idx, align 8
  %agg.tmp57.sroa.2.0..sroa_idx652 = getelementptr inbounds %class.anon.203.191.430.659.888, %class.anon.203.191.430.659.888* %agg.tmp57137, i64 0, i32 1
  store %"struct.pbbs::sequence.39.278.507.736"* %parents, %"struct.pbbs::sequence.39.278.507.736"** %agg.tmp57.sroa.2.0..sroa_idx652, align 8
  %agg.tmp57.sroa.3.0..sroa_idx653 = getelementptr inbounds %class.anon.203.191.430.659.888, %class.anon.203.191.430.659.888* %agg.tmp57137, i64 0, i32 2
  store %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* %this, %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"** %agg.tmp57.sroa.3.0..sroa_idx653, align 8
  %cmp1.i140 = icmp sgt i64 %70, 0
  br i1 %cmp1.i140, label %pfor.cond.i142.preheader, label %invoke.cont58.tf

pfor.cond.i142.preheader:                         ; preds = %invoke.cont54.tf
  br label %pfor.cond.i142

pfor.cond.i142:                                   ; preds = %pfor.inc.i146, %pfor.cond.i142.preheader
  %__begin.0.i141 = phi i64 [ %inc.i144, %pfor.inc.i146 ], [ 0, %pfor.cond.i142.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i143, label %pfor.inc.i146 unwind label %lpad53150.loopexit

pfor.body.entry.i143:                             ; preds = %pfor.cond.i142
  invoke void @_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE1_clEm(%class.anon.203.191.430.659.888* nonnull %agg.tmp57137, i64 %__begin.0.i141)
          to label %.noexc152 unwind label %lpad53150151

.noexc152:                                        ; preds = %pfor.body.entry.i143
  reattach within %syncreg.i.i, label %pfor.inc.i146

pfor.inc.i146:                                    ; preds = %.noexc152, %pfor.cond.i142
  %inc.i144 = add nuw nsw i64 %__begin.0.i141, 1
  %cmp4.i145 = icmp slt i64 %inc.i144, %70
  br i1 %cmp4.i145, label %pfor.cond.i142, label %pfor.cond.cleanup.i147, !llvm.loop !50

pfor.cond.cleanup.i147:                           ; preds = %pfor.inc.i146
  sync within %syncreg.i.i, label %sync.continue.i148

sync.continue.i148:                               ; preds = %pfor.cond.cleanup.i147
  invoke void @llvm.sync.unwind(token %syncreg.i.i)
          to label %invoke.cont58.tf unwind label %lpad53150.loopexit.split-lp

lpad53150.loopexit:                               ; preds = %lpad53150151, %pfor.cond.i142
  %lpad.loopexit1 = landingpad { i8*, i32 }
          cleanup
  br label %lpad53150

; CHECK: lpad53150.loopexit:
; CHECK-LCSSA-NEXT: phi i8*
; CHECK-LCSSA-DAG: [ %62, %lpad53150151 ]
; CHECK-LCSSA-DAG: [ %62, %pfor.cond.i142 ]
; CHECK-LCSSA-NEXT: phi i8*
; CHECK-LCSSA-DAG: [ %38, %lpad53150151 ]
; CHECK-LCSSA-DAG: [ %38, %pfor.cond.i142 ]
; CHECK-NEXT: %lpad.loopexit1 = landingpad

lpad53150.loopexit.split-lp:                      ; preds = %sync.continue.i148
  %.lcssa181 = phi i8* [ %62, %sync.continue.i148 ]
  %.lcssa92 = phi i8* [ %38, %sync.continue.i148 ]
  %lpad.loopexit.split-lp2 = landingpad { i8*, i32 }
          cleanup
  br label %lpad53150

lpad53150:                                        ; preds = %lpad53150.loopexit.split-lp, %lpad53150.loopexit
  %72 = phi i8* [ %62, %lpad53150.loopexit ], [ %.lcssa181, %lpad53150.loopexit.split-lp ]
  %73 = phi i8* [ %38, %lpad53150.loopexit ], [ %.lcssa92, %lpad53150.loopexit.split-lp ]
  %lpad.phi3 = phi { i8*, i32 } [ %lpad.loopexit1, %lpad53150.loopexit ], [ %lpad.loopexit.split-lp2, %lpad53150.loopexit.split-lp ]
  br label %lpad53.body

lpad53150.unreachable:                            ; preds = %lpad53150151
  unreachable

lpad53150151:                                     ; preds = %pfor.body.entry.i143
  %74 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i, { i8*, i32 } %74)
          to label %lpad53150.unreachable unwind label %lpad53150.loopexit

invoke.cont58.tf:                                 ; preds = %sync.continue.i148, %invoke.cont54.tf
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %71)
  %75 = load i64, i64* %n.i33, align 8, !tbaa !29
  %cmp1.i158 = icmp sgt i64 %75, 0
  br i1 %cmp1.i158, label %pfor.cond.i160.preheader, label %invoke.cont62.tfend

pfor.cond.i160.preheader:                         ; preds = %invoke.cont58.tf
  br label %pfor.cond.i160

pfor.cond.i160:                                   ; preds = %pfor.inc.i168, %pfor.cond.i160.preheader
  %__begin.0.i159 = phi i64 [ %inc.i166, %pfor.inc.i168 ], [ 0, %pfor.cond.i160.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i161, label %pfor.inc.i168

pfor.body.entry.i161:                             ; preds = %pfor.cond.i160
  %76 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  %arrayidx.i.i.i163 = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %76, i64 %__begin.0.i159
  %77 = bitcast %"struct.std::pair.171.38.277.506.735"* %arrayidx.i.i.i163 to i64*
  %78 = load i64, i64* %77, align 4
  %.sroa.7.0.extract.shift.i.i = lshr i64 %78, 32
  %conv.i.i = and i64 %78, 4294967295
  %s.i31.i.i = getelementptr inbounds %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885", %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* %this, i64 0, i32 7, i32 0
  %79 = load i8*, i8** %s.i31.i.i, align 8, !tbaa !51
  %arrayidx.i32.i.i = getelementptr inbounds i8, i8* %79, i64 %conv.i.i
  %80 = load i8, i8* %arrayidx.i32.i.i, align 1, !tbaa !30, !range !52
  %tobool.i.i = icmp eq i8 %80, 0
  br i1 %tobool.i.i, label %if.end.i.i, label %if.then.i.i165

if.then.i.i165:                                   ; preds = %pfor.body.entry.i161
  store i8 0, i8* %arrayidx.i32.i.i, align 1, !tbaa !30
  br label %if.end.i.i

if.end.i.i:                                       ; preds = %if.then.i.i165, %pfor.body.entry.i161
  %s.i27.i.i = getelementptr inbounds %"struct.pbbs::sequence.39.278.507.736", %"struct.pbbs::sequence.39.278.507.736"* %parents, i64 0, i32 0
  %81 = load i32*, i32** %s.i27.i.i, align 8, !tbaa !53
  %arrayidx.i28.i.i = getelementptr inbounds i32, i32* %81, i64 %conv.i.i
  %82 = load i32, i32* %arrayidx.i28.i.i, align 4, !tbaa !54
  %conv11.i.i = zext i32 %82 to i64
  %83 = load i8*, i8** %s.i31.i.i, align 8, !tbaa !51
  %arrayidx.i26.i.i = getelementptr inbounds i8, i8* %83, i64 %conv11.i.i
  %84 = load i8, i8* %arrayidx.i26.i.i, align 1, !tbaa !30, !range !52
  %tobool13.i.i = icmp eq i8 %84, 0
  br i1 %tobool13.i.i, label %if.end20.i.i, label %if.then14.i.i

if.then14.i.i:                                    ; preds = %if.end.i.i
  store i8 0, i8* %arrayidx.i26.i.i, align 1, !tbaa !30
  br label %if.end20.i.i

if.end20.i.i:                                     ; preds = %if.then14.i.i, %if.end.i.i
  %85 = load i8*, i8** %s.i31.i.i, align 8, !tbaa !51
  %arrayidx.i20.i.i = getelementptr inbounds i8, i8* %85, i64 %.sroa.7.0.extract.shift.i.i
  %86 = load i8, i8* %arrayidx.i20.i.i, align 1, !tbaa !30, !range !52
  %tobool24.i.i = icmp eq i8 %86, 0
  br i1 %tobool24.i.i, label %if.end29.i.i, label %if.then25.i.i

if.then25.i.i:                                    ; preds = %if.end20.i.i
  store i8 0, i8* %arrayidx.i20.i.i, align 1, !tbaa !30
  br label %if.end29.i.i

if.end29.i.i:                                     ; preds = %if.then25.i.i, %if.end20.i.i
  %87 = load i32*, i32** %s.i27.i.i, align 8, !tbaa !53
  %arrayidx.i16.i.i = getelementptr inbounds i32, i32* %87, i64 %.sroa.7.0.extract.shift.i.i
  %88 = load i32, i32* %arrayidx.i16.i.i, align 4, !tbaa !54
  %conv33.i.i = zext i32 %88 to i64
  %89 = load i8*, i8** %s.i31.i.i, align 8, !tbaa !51
  %arrayidx.i14.i.i = getelementptr inbounds i8, i8* %89, i64 %conv33.i.i
  %90 = load i8, i8* %arrayidx.i14.i.i, align 1, !tbaa !30, !range !52
  %tobool35.i.i = icmp eq i8 %90, 0
  br i1 %tobool35.i.i, label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE2_clEm.exit.i, label %if.then36.i.i

if.then36.i.i:                                    ; preds = %if.end29.i.i
  store i8 0, i8* %arrayidx.i14.i.i, align 1, !tbaa !30
  br label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE2_clEm.exit.i

_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE2_clEm.exit.i: ; preds = %if.then36.i.i, %if.end29.i.i
  reattach within %syncreg.i.i, label %pfor.inc.i168

pfor.inc.i168:                                    ; preds = %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE2_clEm.exit.i, %pfor.cond.i160
  %inc.i166 = add nuw nsw i64 %__begin.0.i159, 1
  %cmp4.i167 = icmp slt i64 %inc.i166, %75
  br i1 %cmp4.i167, label %pfor.cond.i160, label %pfor.cond.cleanup.i169, !llvm.loop !56

pfor.cond.cleanup.i169:                           ; preds = %pfor.inc.i168
  sync within %syncreg.i.i, label %sync.continue.i170

sync.continue.i170:                               ; preds = %pfor.cond.cleanup.i169
  call void @llvm.sync.unwind(token %syncreg.i.i) #23
  br label %invoke.cont62.tfend

invoke.cont62.tfend:                              ; preds = %sync.continue.i170, %invoke.cont58.tf
  %call64 = invoke double @_ZN4pbbs5timer4stopEv(%"struct.pbbs::timer.8.247.476.705"* nonnull %ut)
          to label %invoke.cont63 unwind label %lpad53

invoke.cont63:                                    ; preds = %invoke.cont62.tfend
  %91 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp65 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %91) #23
  %92 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp65, i64 0, i32 2
  %arraydecay.i.i174 = bitcast %union.anon.6.245.474.703* %92 to i8*
  %93 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp65 to %union.anon.6.245.474.703**
  store %union.anon.6.245.474.703* %92, %union.anon.6.245.474.703** %93, align 8, !tbaa !39
  %94 = bitcast i64* %__dnew.i.i.i.i172 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %94) #23
  store i64 13, i64* %__dnew.i.i.i.i172, align 8, !tbaa !41
  %_M_p.i.i.i.i.i187 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp65, i64 0, i32 0, i32 0
  %95 = load i8*, i8** %_M_p.i.i.i.i.i187, align 8, !tbaa !42
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(13) %95, i8* nonnull align 1 dereferenceable(13) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.50, i64 0, i64 0), i64 13, i1 false) #23
  %96 = load i64, i64* %__dnew.i.i.i.i172, align 8, !tbaa !41
  %_M_string_length.i.i.i.i.i.i197 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp65, i64 0, i32 1
  store i64 %96, i64* %_M_string_length.i.i.i.i.i.i197, align 8, !tbaa !44
  %97 = load i8*, i8** %_M_p.i.i.i.i.i187, align 8, !tbaa !42
  %arrayidx.i.i.i.i.i199 = getelementptr inbounds i8, i8* %97, i64 %96
  store i8 0, i8* %arrayidx.i.i.i.i.i199, align 1, !tbaa !38
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %94) #23
  invoke void @_ZNK4pbbs5timer11reportTotalERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"struct.pbbs::timer.8.247.476.705"* nonnull %ut, %"class.std::__cxx11::basic_string.7.246.475.704"* nonnull dereferenceable(32) %ref.tmp65)
          to label %invoke.cont70 unwind label %lpad69

invoke.cont70:                                    ; preds = %invoke.cont63
  %98 = load i8*, i8** %_M_p.i.i.i.i.i187, align 8, !tbaa !42
  %cmp.i.i.i205 = icmp eq i8* %98, %arraydecay.i.i174
  br i1 %cmp.i.i.i205, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210, label %if.then.i.i209

if.then.i.i209:                                   ; preds = %invoke.cont70
  call void @_ZdlPv(i8* %98) #23
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210: ; preds = %if.then.i.i209, %invoke.cont70
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %91) #23
  %99 = bitcast %"struct.pbbs::timer.8.247.476.705"* %sc to i8*
  call void @llvm.lifetime.start.p0i8(i64 56, i8* nonnull %99) #23
  %100 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp75, i64 0, i32 2
  %arraydecay.i.i217 = bitcast %union.anon.6.245.474.703* %100 to i8*
  %101 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp75 to %union.anon.6.245.474.703**
  store %union.anon.6.245.474.703* %100, %union.anon.6.245.474.703** %101, align 8, !tbaa !39
  %102 = bitcast i64* %__dnew.i.i.i.i215 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %102) #23
  store i64 11, i64* %__dnew.i.i.i.i215, align 8, !tbaa !41
  %_M_p.i.i.i.i.i230 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp75, i64 0, i32 0, i32 0
  %103 = load i8*, i8** %_M_p.i.i.i.i.i230, align 8, !tbaa !42
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(11) %103, i8* nonnull align 1 dereferenceable(11) getelementptr inbounds ([12 x i8], [12 x i8]* @.str.6, i64 0, i64 0), i64 11, i1 false) #23
  %104 = load i64, i64* %__dnew.i.i.i.i215, align 8, !tbaa !41
  %_M_string_length.i.i.i.i.i.i240 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp75, i64 0, i32 1
  store i64 %104, i64* %_M_string_length.i.i.i.i.i.i240, align 8, !tbaa !44
  %105 = load i8*, i8** %_M_p.i.i.i.i.i230, align 8, !tbaa !42
  %arrayidx.i.i.i.i.i242 = getelementptr inbounds i8, i8* %105, i64 %104
  store i8 0, i8* %arrayidx.i.i.i.i.i242, align 1, !tbaa !38
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %102) #23
  invoke void @_ZN4pbbs5timerC1ENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEb(%"struct.pbbs::timer.8.247.476.705"* nonnull %sc, %"class.std::__cxx11::basic_string.7.246.475.704"* nonnull %agg.tmp75, i1 zeroext true)
          to label %invoke.cont80 unwind label %lpad79

invoke.cont80:                                    ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210
  %106 = load i8*, i8** %_M_p.i.i.i.i.i230, align 8, !tbaa !42
  %cmp.i.i.i248 = icmp eq i8* %106, %arraydecay.i.i217
  br i1 %cmp.i.i.i248, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit253, label %if.then.i.i252

if.then.i.i252:                                   ; preds = %invoke.cont80
  call void @_ZdlPv(i8* %106) #23
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit253

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit253: ; preds = %if.then.i.i252, %invoke.cont80
  invoke void @_ZN4pbbs5timer5startEv(%"struct.pbbs::timer.8.247.476.705"* nonnull %sc)
          to label %invoke.cont85.tf unwind label %lpad84

invoke.cont85.tf:                                 ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit253
  %107 = load i64, i64* %n.i33, align 8, !tbaa !29
  %108 = bitcast %class.anon.205.192.431.660.889* %agg.tmp88261 to i8*
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %108)
  %agg.tmp88.sroa.0.0..sroa_idx = getelementptr inbounds %class.anon.205.192.431.660.889, %class.anon.205.192.431.660.889* %agg.tmp88261, i64 0, i32 0
  store %"struct.pbbs::sequence.170.172.411.640.869"* %inserts, %"struct.pbbs::sequence.170.172.411.640.869"** %agg.tmp88.sroa.0.0..sroa_idx, align 8
  %agg.tmp88.sroa.2.0..sroa_idx648 = getelementptr inbounds %class.anon.205.192.431.660.889, %class.anon.205.192.431.660.889* %agg.tmp88261, i64 0, i32 1
  store %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* %this, %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"** %agg.tmp88.sroa.2.0..sroa_idx648, align 8
  %agg.tmp88.sroa.3.0..sroa_idx649 = getelementptr inbounds %class.anon.205.192.431.660.889, %class.anon.205.192.431.660.889* %agg.tmp88261, i64 0, i32 2
  store %"struct.pbbs::sequence.39.278.507.736"* %parents, %"struct.pbbs::sequence.39.278.507.736"** %agg.tmp88.sroa.3.0..sroa_idx649, align 8
  %cmp1.i264 = icmp sgt i64 %107, 0
  br i1 %cmp1.i264, label %pfor.cond.i266.preheader, label %invoke.cont89

pfor.cond.i266.preheader:                         ; preds = %invoke.cont85.tf
  br label %pfor.cond.i266

pfor.cond.i266:                                   ; preds = %pfor.inc.i270, %pfor.cond.i266.preheader
  %__begin.0.i265 = phi i64 [ %inc.i268, %pfor.inc.i270 ], [ 0, %pfor.cond.i266.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i267, label %pfor.inc.i270 unwind label %lpad84274.loopexit

pfor.body.entry.i267:                             ; preds = %pfor.cond.i266
  invoke void @_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE3_clEm(%class.anon.205.192.431.660.889* nonnull %agg.tmp88261, i64 %__begin.0.i265)
          to label %.noexc276 unwind label %lpad84274275

.noexc276:                                        ; preds = %pfor.body.entry.i267
  reattach within %syncreg.i.i, label %pfor.inc.i270

pfor.inc.i270:                                    ; preds = %.noexc276, %pfor.cond.i266
  %inc.i268 = add nuw nsw i64 %__begin.0.i265, 1
  %cmp4.i269 = icmp slt i64 %inc.i268, %107
  br i1 %cmp4.i269, label %pfor.cond.i266, label %pfor.cond.cleanup.i271, !llvm.loop !57

pfor.cond.cleanup.i271:                           ; preds = %pfor.inc.i270
  sync within %syncreg.i.i, label %sync.continue.i272

sync.continue.i272:                               ; preds = %pfor.cond.cleanup.i271
  invoke void @llvm.sync.unwind(token %syncreg.i.i)
          to label %invoke.cont89 unwind label %lpad84274.loopexit.split-lp

lpad84274.loopexit:                               ; preds = %lpad84274275, %pfor.cond.i266
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  br label %lpad84274

; CHECK: lpad84274.loopexit:
; CHECK-LCSSA-NEXT: phi i8*
; CHECK-LCSSA-DAG: [ %99, %lpad84274275 ]
; CHECK-LCSSA-DAG: [ %99, %pfor.cond.i266 ]
; CHECK-LCSSA-NEXT: phi i8*
; CHECK-LCSSA-DAG: [ %62, %lpad84274275 ]
; CHECK-LCSSA-DAG: [ %62, %pfor.cond.i266 ]
; CHECK-LCSSA-NEXT: phi i8*
; CHECK-LCSSA-DAG: [ %38, %lpad84274275 ]
; CHECK-LCSSA-DAG: [ %38, %pfor.cond.i266 ]
; CHECK-NEXT: %lpad.loopexit = landingpad

lpad84274.loopexit.split-lp:                      ; preds = %sync.continue.i272
  %.lcssa245 = phi i8* [ %99, %sync.continue.i272 ]
  %.lcssa186 = phi i8* [ %62, %sync.continue.i272 ]
  %.lcssa97 = phi i8* [ %38, %sync.continue.i272 ]
  %lpad.loopexit.split-lp = landingpad { i8*, i32 }
          cleanup
  br label %lpad84274

lpad84274:                                        ; preds = %lpad84274.loopexit.split-lp, %lpad84274.loopexit
  %109 = phi i8* [ %99, %lpad84274.loopexit ], [ %.lcssa245, %lpad84274.loopexit.split-lp ]
  %110 = phi i8* [ %62, %lpad84274.loopexit ], [ %.lcssa186, %lpad84274.loopexit.split-lp ]
  %111 = phi i8* [ %38, %lpad84274.loopexit ], [ %.lcssa97, %lpad84274.loopexit.split-lp ]
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad84274.loopexit ], [ %lpad.loopexit.split-lp, %lpad84274.loopexit.split-lp ]
  br label %lpad84.body

lpad84274.unreachable:                            ; preds = %lpad84274275
  unreachable

lpad84274275:                                     ; preds = %pfor.body.entry.i267
  %112 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i.i, { i8*, i32 } %112)
          to label %lpad84274.unreachable unwind label %lpad84274.loopexit

invoke.cont89:                                    ; preds = %sync.continue.i272, %invoke.cont85.tf
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %108)
  %call91 = invoke double @_ZN4pbbs5timer4stopEv(%"struct.pbbs::timer.8.247.476.705"* nonnull %sc)
          to label %invoke.cont90 unwind label %lpad84

invoke.cont90:                                    ; preds = %invoke.cont89
  %113 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp92 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %113) #23
  %114 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp92, i64 0, i32 2
  %arraydecay.i.i285 = bitcast %union.anon.6.245.474.703* %114 to i8*
  %115 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp92 to %union.anon.6.245.474.703**
  store %union.anon.6.245.474.703* %114, %union.anon.6.245.474.703** %115, align 8, !tbaa !39
  %116 = bitcast i64* %__dnew.i.i.i.i283 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %116) #23
  store i64 15, i64* %__dnew.i.i.i.i283, align 8, !tbaa !41
  %_M_p.i.i.i.i.i298 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp92, i64 0, i32 0, i32 0
  %117 = load i8*, i8** %_M_p.i.i.i.i.i298, align 8, !tbaa !42
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(15) %117, i8* nonnull align 1 dereferenceable(15) getelementptr inbounds ([16 x i8], [16 x i8]* @.str.51, i64 0, i64 0), i64 15, i1 false) #23
  %118 = load i64, i64* %__dnew.i.i.i.i283, align 8, !tbaa !41
  %_M_string_length.i.i.i.i.i.i308 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp92, i64 0, i32 1
  store i64 %118, i64* %_M_string_length.i.i.i.i.i.i308, align 8, !tbaa !44
  %119 = load i8*, i8** %_M_p.i.i.i.i.i298, align 8, !tbaa !42
  %arrayidx.i.i.i.i.i310 = getelementptr inbounds i8, i8* %119, i64 %118
  store i8 0, i8* %arrayidx.i.i.i.i.i310, align 1, !tbaa !38
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %116) #23
  invoke void @_ZNK4pbbs5timer11reportTotalERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"struct.pbbs::timer.8.247.476.705"* nonnull %sc, %"class.std::__cxx11::basic_string.7.246.475.704"* nonnull dereferenceable(32) %ref.tmp92)
          to label %invoke.cont97 unwind label %lpad96

invoke.cont97:                                    ; preds = %invoke.cont90
  %120 = load i8*, i8** %_M_p.i.i.i.i.i298, align 8, !tbaa !42
  %cmp.i.i.i316 = icmp eq i8* %120, %arraydecay.i.i285
  br i1 %cmp.i.i.i316, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit321.tf, label %if.then.i.i320

if.then.i.i320:                                   ; preds = %invoke.cont97
  call void @_ZdlPv(i8* %120) #23
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit321.tf

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit321.tf: ; preds = %if.then.i.i320, %invoke.cont97
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %113) #23
  %121 = load i64, i64* %n.i33, align 8, !tbaa !29
  %cmp1.i330 = icmp sgt i64 %121, 0
  br i1 %cmp1.i330, label %pfor.cond.i332.preheader, label %invoke.cont105.tfend

pfor.cond.i332.preheader:                         ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit321.tf
  br label %pfor.cond.i332

pfor.cond.i332:                                   ; preds = %pfor.inc.i350, %pfor.cond.i332.preheader
  %__begin.0.i331 = phi i64 [ %inc.i348, %pfor.inc.i350 ], [ 0, %pfor.cond.i332.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i333, label %pfor.inc.i350

pfor.body.entry.i333:                             ; preds = %pfor.cond.i332
  %122 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  %arrayidx.i.i.i335 = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %122, i64 %__begin.0.i331
  %123 = bitcast %"struct.std::pair.171.38.277.506.735"* %arrayidx.i.i.i335 to i64*
  %124 = load i64, i64* %123, align 4
  %.sroa.5.0.extract.shift.i.i = lshr i64 %124, 32
  %conv.i.i338 = and i64 %124, 4294967295
  %s.i11.i.i339 = getelementptr inbounds %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885", %"struct.gbbs::lt::LiuTarjanAlgorithm.194.188.427.656.885"* %this, i64 0, i32 7, i32 0
  %125 = load i8*, i8** %s.i11.i.i339, align 8, !tbaa !51
  %arrayidx.i12.i.i340 = getelementptr inbounds i8, i8* %125, i64 %conv.i.i338
  %126 = load i8, i8* %arrayidx.i12.i.i340, align 1, !tbaa !30, !range !52
  %tobool.i.i341 = icmp eq i8 %126, 0
  br i1 %tobool.i.i341, label %if.end.i.i347, label %if.then.i.i345

if.then.i.i345:                                   ; preds = %pfor.body.entry.i333
  store i8 0, i8* %arrayidx.i12.i.i340, align 1, !tbaa !30
  br label %if.end.i.i347

if.end.i.i347:                                    ; preds = %if.then.i.i345, %pfor.body.entry.i333
  %127 = load i8*, i8** %s.i11.i.i339, align 8, !tbaa !51
  %arrayidx.i8.i.i = getelementptr inbounds i8, i8* %127, i64 %.sroa.5.0.extract.shift.i.i
  %128 = load i8, i8* %arrayidx.i8.i.i, align 1, !tbaa !30, !range !52
  %tobool11.i.i = icmp eq i8 %128, 0
  br i1 %tobool11.i.i, label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE4_clEm.exit.i, label %if.then12.i.i

if.then12.i.i:                                    ; preds = %if.end.i.i347
  store i8 0, i8* %arrayidx.i8.i.i, align 1, !tbaa !30
  br label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE4_clEm.exit.i

_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE4_clEm.exit.i: ; preds = %if.then12.i.i, %if.end.i.i347
  reattach within %syncreg.i.i, label %pfor.inc.i350

pfor.inc.i350:                                    ; preds = %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE4_clEm.exit.i, %pfor.cond.i332
  %inc.i348 = add nuw nsw i64 %__begin.0.i331, 1
  %cmp4.i349 = icmp slt i64 %inc.i348, %121
  br i1 %cmp4.i349, label %pfor.cond.i332, label %pfor.cond.cleanup.i351, !llvm.loop !58

pfor.cond.cleanup.i351:                           ; preds = %pfor.inc.i350
  sync within %syncreg.i.i, label %sync.continue.i352

sync.continue.i352:                               ; preds = %pfor.cond.cleanup.i351
  call void @llvm.sync.unwind(token %syncreg.i.i) #23
  br label %invoke.cont105.tfend

invoke.cont105.tfend:                             ; preds = %sync.continue.i352, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit321.tf
  %129 = bitcast %"struct.pbbs::timer.8.247.476.705"* %at to i8*
  call void @llvm.lifetime.start.p0i8(i64 56, i8* nonnull %129) #23
  %130 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp106, i64 0, i32 2
  %arraydecay.i.i390 = bitcast %union.anon.6.245.474.703* %130 to i8*
  %131 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp106 to %union.anon.6.245.474.703**
  store %union.anon.6.245.474.703* %130, %union.anon.6.245.474.703** %131, align 8, !tbaa !39
  %132 = bitcast i64* %__dnew.i.i.i.i388 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %132) #23
  store i64 11, i64* %__dnew.i.i.i.i388, align 8, !tbaa !41
  %_M_p.i.i.i.i.i403 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp106, i64 0, i32 0, i32 0
  %133 = load i8*, i8** %_M_p.i.i.i.i.i403, align 8, !tbaa !42
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(11) %133, i8* nonnull align 1 dereferenceable(11) getelementptr inbounds ([12 x i8], [12 x i8]* @.str.6, i64 0, i64 0), i64 11, i1 false) #23
  %134 = load i64, i64* %__dnew.i.i.i.i388, align 8, !tbaa !41
  %_M_string_length.i.i.i.i.i.i413 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %agg.tmp106, i64 0, i32 1
  store i64 %134, i64* %_M_string_length.i.i.i.i.i.i413, align 8, !tbaa !44
  %135 = load i8*, i8** %_M_p.i.i.i.i.i403, align 8, !tbaa !42
  %arrayidx.i.i.i.i.i415 = getelementptr inbounds i8, i8* %135, i64 %134
  store i8 0, i8* %arrayidx.i.i.i.i.i415, align 1, !tbaa !38
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %132) #23
  invoke void @_ZN4pbbs5timerC1ENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEb(%"struct.pbbs::timer.8.247.476.705"* nonnull %at, %"class.std::__cxx11::basic_string.7.246.475.704"* nonnull %agg.tmp106, i1 zeroext true)
          to label %invoke.cont111 unwind label %lpad110

invoke.cont111:                                   ; preds = %invoke.cont105.tfend
  %136 = load i8*, i8** %_M_p.i.i.i.i.i403, align 8, !tbaa !42
  %cmp.i.i.i421 = icmp eq i8* %136, %arraydecay.i.i390
  br i1 %cmp.i.i.i421, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426, label %if.then.i.i425

if.then.i.i425:                                   ; preds = %invoke.cont111
  call void @_ZdlPv(i8* %136) #23
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426: ; preds = %if.then.i.i425, %invoke.cont111
  invoke void @_ZN4pbbs5timer5startEv(%"struct.pbbs::timer.8.247.476.705"* nonnull %at)
          to label %invoke.cont116.tf unwind label %lpad115

invoke.cont116.tf:                                ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426
  %137 = bitcast i64* %nullary_edge to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %137) #23
  store i64 -4294967298, i64* %nullary_edge, align 8
  %138 = load i64, i64* %n.i33, align 8, !tbaa !29
  %cmp1.i440 = icmp sgt i64 %138, 0
  br i1 %cmp1.i440, label %pfor.cond.i442.preheader, label %invoke.cont121.tfend

pfor.cond.i442.preheader:                         ; preds = %invoke.cont116.tf
  br label %pfor.cond.i442

pfor.cond.i442:                                   ; preds = %pfor.inc.i462, %pfor.cond.i442.preheader
  %__begin.0.i441 = phi i64 [ %inc.i460, %pfor.inc.i462 ], [ 0, %pfor.cond.i442.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i443, label %pfor.inc.i462

pfor.body.entry.i443:                             ; preds = %pfor.cond.i442
  %139 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  %arrayidx.i.i.i445 = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %139, i64 %__begin.0.i441
  %140 = bitcast %"struct.std::pair.171.38.277.506.735"* %arrayidx.i.i.i445 to i64*
  %141 = load i64, i64* %140, align 4
  %.sroa.4.0.extract.shift.i.i447 = lshr i64 %141, 32
  %conv.i.i449 = and i64 %141, 4294967295
  %s.i21.i.i450 = getelementptr inbounds %"struct.pbbs::sequence.39.278.507.736", %"struct.pbbs::sequence.39.278.507.736"* %parents, i64 0, i32 0
  %142 = load i32*, i32** %s.i21.i.i450, align 8, !tbaa !53
  %arrayidx.i22.i.i451 = getelementptr inbounds i32, i32* %142, i64 %conv.i.i449
  %143 = load i32, i32* %arrayidx.i22.i.i451, align 4, !tbaa !54
  %arrayidx.i20.i.i453 = getelementptr inbounds i32, i32* %142, i64 %.sroa.4.0.extract.shift.i.i447
  %144 = load i32, i32* %arrayidx.i20.i.i453, align 4, !tbaa !54
  %cmp.i.i454 = icmp eq i32 %143, %144
  %first2.i10.i.i = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %arrayidx.i.i.i445, i64 0, i32 0
  br i1 %cmp.i.i454, label %if.then.i.i457, label %if.else.i.i

if.then.i.i457:                                   ; preds = %pfor.body.entry.i443
  store i32 -2, i32* %first2.i10.i.i, align 4, !tbaa !59
  %second4.i12.i.i = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %139, i64 %__begin.0.i441, i32 1
  store i32 -2, i32* %second4.i12.i.i, align 4, !tbaa !61
  br label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE5_clEm.exit.i

if.else.i.i:                                      ; preds = %pfor.body.entry.i443
  store i32 %143, i32* %first2.i10.i.i, align 4, !tbaa !59
  %second4.i.i.i = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %139, i64 %__begin.0.i441, i32 1
  store i32 %144, i32* %second4.i.i.i, align 4, !tbaa !61
  br label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE5_clEm.exit.i

_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE5_clEm.exit.i: ; preds = %if.else.i.i, %if.then.i.i457
  reattach within %syncreg.i.i, label %pfor.inc.i462

pfor.inc.i462:                                    ; preds = %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE5_clEm.exit.i, %pfor.cond.i442
  %inc.i460 = add nuw nsw i64 %__begin.0.i441, 1
  %cmp4.i461 = icmp slt i64 %inc.i460, %138
  br i1 %cmp4.i461, label %pfor.cond.i442, label %pfor.cond.cleanup.i463, !llvm.loop !62

pfor.cond.cleanup.i463:                           ; preds = %pfor.inc.i462
  sync within %syncreg.i.i, label %sync.continue.i464

sync.continue.i464:                               ; preds = %pfor.cond.cleanup.i463
  call void @llvm.sync.unwind(token %syncreg.i.i) #23
  br label %invoke.cont121.tfend

invoke.cont121.tfend:                             ; preds = %sync.continue.i464, %invoke.cont116.tf
  %145 = bitcast %"struct.pbbs::sequence.170.172.411.640.869"* %new_inserts to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %145) #23
  invoke void @_ZN4pbbs6filterINS_8sequenceISt4pairIjjEEEZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRNS1_IjEES9_ELNS5_22LiuTarjanConnectOptionE1EPFvjS9_S9_ELNS5_21LiuTarjanUpdateOptionE1EPFvjS9_ELNS5_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS9_ELNS5_20LiuTarjanAlterOptionE0ENS5_10edge_arrayINS_5emptyEEEE13process_batchILb1ENS_5rangeIPSJ_IJjjNS5_10UpdateTypeEEEEEEEvS9_RT0_EUlRKS3_E_EENS1_INT_10value_typeEEERKS13_SY_j(%"struct.pbbs::sequence.170.172.411.640.869"* nonnull sret %new_inserts, %"struct.pbbs::sequence.170.172.411.640.869"* nonnull dereferenceable(16) %inserts, %"struct.std::pair.171.38.277.506.735"* nonnull %tmpcast, i32 0)
          to label %invoke.cont125 unwind label %lpad124

invoke.cont125:                                   ; preds = %invoke.cont121.tfend
  %146 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  %cmp.i.i476 = icmp eq %"struct.std::pair.171.38.277.506.735"* %146, null
  br i1 %cmp.i.i476, label %_ZN4pbbs8sequenceISt4pairIjjEE5clearEv.exit.i.tf, label %if.then.i.i478

if.then.i.i478:                                   ; preds = %invoke.cont125
  %147 = bitcast %"struct.std::pair.171.38.277.506.735"* %146 to i8*
  call void @free(i8* %147) #23
  store %"struct.std::pair.171.38.277.506.735"* null, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  store i64 0, i64* %n.i33, align 8, !tbaa !29
  br label %_ZN4pbbs8sequenceISt4pairIjjEE5clearEv.exit.i.tf

_ZN4pbbs8sequenceISt4pairIjjEE5clearEv.exit.i.tf: ; preds = %if.then.i.i478, %invoke.cont125
  %s.i479 = getelementptr inbounds %"struct.pbbs::sequence.170.172.411.640.869", %"struct.pbbs::sequence.170.172.411.640.869"* %new_inserts, i64 0, i32 0
  %n.i480 = getelementptr inbounds %"struct.pbbs::sequence.170.172.411.640.869", %"struct.pbbs::sequence.170.172.411.640.869"* %new_inserts, i64 0, i32 1
  %148 = load i64, i64* %n.i480, align 8, !tbaa !29
  store i64 %148, i64* %n.i33, align 8, !tbaa !29
  %149 = lshr i64 %148, 3
  %add.i.i483 = shl i64 %149, 6
  %mul1.i.i484 = add i64 %add.i.i483, 64
  %call.i.i.i485 = call noalias i8* @malloc(i64 %mul1.i.i484) #23
  %cmp.i.i486 = icmp eq i8* %call.i.i.i485, null
  br i1 %cmp.i.i486, label %if.then.i.i488, label %_ZN4pbbs17new_array_no_initISt4pairIjjEEEPT_mb.exit.i

if.then.i.i488:                                   ; preds = %_ZN4pbbs8sequenceISt4pairIjjEE5clearEv.exit.i.tf
  %mul1.i.i484.lcssa = phi i64 [ %mul1.i.i484, %_ZN4pbbs8sequenceISt4pairIjjEE5clearEv.exit.i.tf ]
  %150 = load %struct._IO_FILE.30.269.498.727*, %struct._IO_FILE.30.269.498.727** @stderr, align 8, !tbaa !12
  %call2.i.i487 = call i32 (%struct._IO_FILE.30.269.498.727*, i8*, ...) @fprintf(%struct._IO_FILE.30.269.498.727* %150, i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.18, i64 0, i64 0), i64 %mul1.i.i484.lcssa) #25
  call void @exit(i32 1) #26
  unreachable

_ZN4pbbs17new_array_no_initISt4pairIjjEEEPT_mb.exit.i: ; preds = %_ZN4pbbs8sequenceISt4pairIjjEE5clearEv.exit.i.tf
  %151 = bitcast %"struct.pbbs::sequence.170.172.411.640.869"* %inserts to i8**
  store i8* %call.i.i.i485, i8** %151, align 8, !tbaa !27
  %cmp1.i.i = icmp sgt i64 %148, 0
  br i1 %cmp1.i.i, label %pfor.cond.i.i.preheader, label %invoke.cont127.tfend

pfor.cond.i.i.preheader:                          ; preds = %_ZN4pbbs17new_array_no_initISt4pairIjjEEEPT_mb.exit.i
  br label %pfor.cond.i.i

pfor.cond.i.i:                                    ; preds = %pfor.inc.i.i, %pfor.cond.i.i.preheader
  %__begin.0.i.i = phi i64 [ %inc.i.i, %pfor.inc.i.i ], [ 0, %pfor.cond.i.i.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i.i, label %pfor.inc.i.i

pfor.body.entry.i.i:                              ; preds = %pfor.cond.i.i
  %152 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  %arrayidx.i.i.i491 = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %152, i64 %__begin.0.i.i
  %153 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i479, align 8, !tbaa !12
  %arrayidx2.i.i.i = getelementptr inbounds %"struct.std::pair.171.38.277.506.735", %"struct.std::pair.171.38.277.506.735"* %153, i64 %__begin.0.i.i
  %154 = bitcast %"struct.std::pair.171.38.277.506.735"* %arrayidx2.i.i.i to i64*
  %155 = bitcast %"struct.std::pair.171.38.277.506.735"* %arrayidx.i.i.i491 to i64*
  %156 = load i64, i64* %154, align 4
  store i64 %156, i64* %155, align 4
  reattach within %syncreg.i.i, label %pfor.inc.i.i

pfor.inc.i.i:                                     ; preds = %pfor.body.entry.i.i, %pfor.cond.i.i
  %inc.i.i = add nuw nsw i64 %__begin.0.i.i, 1
  %cmp4.i.i = icmp slt i64 %inc.i.i, %148
  br i1 %cmp4.i.i, label %pfor.cond.i.i, label %pfor.cond.cleanup.i.i, !llvm.loop !63

pfor.cond.cleanup.i.i:                            ; preds = %pfor.inc.i.i
  sync within %syncreg.i.i, label %sync.continue.i.i

sync.continue.i.i:                                ; preds = %pfor.cond.cleanup.i.i
  call void @llvm.sync.unwind(token %syncreg.i.i) #23
  br label %invoke.cont127.tfend

invoke.cont127.tfend:                             ; preds = %sync.continue.i.i, %_ZN4pbbs17new_array_no_initISt4pairIjjEEEPT_mb.exit.i
  %157 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i479, align 8, !tbaa !27
  %cmp.i.i496 = icmp eq %"struct.std::pair.171.38.277.506.735"* %157, null
  br i1 %cmp.i.i496, label %_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500, label %if.then.i.i498

if.then.i.i498:                                   ; preds = %invoke.cont127.tfend
  %158 = bitcast %"struct.std::pair.171.38.277.506.735"* %157 to i8*
  call void @free(i8* %158) #23
  store %"struct.std::pair.171.38.277.506.735"* null, %"struct.std::pair.171.38.277.506.735"** %s.i479, align 8, !tbaa !27
  store i64 0, i64* %n.i480, align 8, !tbaa !29
  br label %_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500

_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500:       ; preds = %if.then.i.i498, %invoke.cont127.tfend
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %145) #23
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %137) #23
  %call134 = invoke double @_ZN4pbbs5timer4stopEv(%"struct.pbbs::timer.8.247.476.705"* nonnull %at)
          to label %invoke.cont133 unwind label %lpad115

invoke.cont133:                                   ; preds = %_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500
  %159 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp135 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %159) #23
  %160 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp135, i64 0, i32 2
  %arraydecay.i.i503 = bitcast %union.anon.6.245.474.703* %160 to i8*
  %161 = bitcast %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp135 to %union.anon.6.245.474.703**
  store %union.anon.6.245.474.703* %160, %union.anon.6.245.474.703** %161, align 8, !tbaa !39
  %162 = bitcast i64* %__dnew.i.i.i.i501 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %162) #23
  store i64 12, i64* %__dnew.i.i.i.i501, align 8, !tbaa !41
  %_M_p.i.i.i.i.i516 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp135, i64 0, i32 0, i32 0
  %163 = load i8*, i8** %_M_p.i.i.i.i.i516, align 8, !tbaa !42
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(12) %163, i8* nonnull align 1 dereferenceable(12) getelementptr inbounds ([13 x i8], [13 x i8]* @.str.52, i64 0, i64 0), i64 12, i1 false) #23
  %164 = load i64, i64* %__dnew.i.i.i.i501, align 8, !tbaa !41
  %_M_string_length.i.i.i.i.i.i526 = getelementptr inbounds %"class.std::__cxx11::basic_string.7.246.475.704", %"class.std::__cxx11::basic_string.7.246.475.704"* %ref.tmp135, i64 0, i32 1
  store i64 %164, i64* %_M_string_length.i.i.i.i.i.i526, align 8, !tbaa !44
  %165 = load i8*, i8** %_M_p.i.i.i.i.i516, align 8, !tbaa !42
  %arrayidx.i.i.i.i.i528 = getelementptr inbounds i8, i8* %165, i64 %164
  store i8 0, i8* %arrayidx.i.i.i.i.i528, align 1, !tbaa !38
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %162) #23
  invoke void @_ZNK4pbbs5timer11reportTotalERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%"struct.pbbs::timer.8.247.476.705"* nonnull %at, %"class.std::__cxx11::basic_string.7.246.475.704"* nonnull dereferenceable(32) %ref.tmp135)
          to label %invoke.cont140 unwind label %lpad139

invoke.cont140:                                   ; preds = %invoke.cont133
  %166 = load i8*, i8** %_M_p.i.i.i.i.i516, align 8, !tbaa !42
  %cmp.i.i.i534 = icmp eq i8* %166, %arraydecay.i.i503
  br i1 %cmp.i.i.i534, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit539, label %if.then.i.i538

if.then.i.i538:                                   ; preds = %invoke.cont140
  call void @_ZdlPv(i8* %166) #23
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit539

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit539: ; preds = %if.then.i.i538, %invoke.cont140
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %159) #23
  %_M_p.i.i.i.i.i541 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %at, i64 0, i32 3, i32 0, i32 0
  %167 = load i8*, i8** %_M_p.i.i.i.i.i541, align 8, !tbaa !42
  %168 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %at, i64 0, i32 3, i32 2
  %arraydecay.i.i.i.i.i542 = bitcast %union.anon.6.245.474.703* %168 to i8*
  %cmp.i.i.i.i543 = icmp eq i8* %167, %arraydecay.i.i.i.i.i542
  br i1 %cmp.i.i.i.i543, label %_ZN4pbbs5timerD2Ev.exit548, label %if.then.i.i.i547

if.then.i.i.i547:                                 ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit539
  call void @_ZdlPv(i8* %167) #23
  br label %_ZN4pbbs5timerD2Ev.exit548

_ZN4pbbs5timerD2Ev.exit548:                       ; preds = %if.then.i.i.i547, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit539
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %129) #23
  %_M_p.i.i.i.i.i550 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %sc, i64 0, i32 3, i32 0, i32 0
  %169 = load i8*, i8** %_M_p.i.i.i.i.i550, align 8, !tbaa !42
  %170 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %sc, i64 0, i32 3, i32 2
  %arraydecay.i.i.i.i.i551 = bitcast %union.anon.6.245.474.703* %170 to i8*
  %cmp.i.i.i.i552 = icmp eq i8* %169, %arraydecay.i.i.i.i.i551
  br i1 %cmp.i.i.i.i552, label %_ZN4pbbs5timerD2Ev.exit557, label %if.then.i.i.i556

if.then.i.i.i556:                                 ; preds = %_ZN4pbbs5timerD2Ev.exit548
  call void @_ZdlPv(i8* %169) #23
  br label %_ZN4pbbs5timerD2Ev.exit557

_ZN4pbbs5timerD2Ev.exit557:                       ; preds = %if.then.i.i.i556, %_ZN4pbbs5timerD2Ev.exit548
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %99) #23
  %_M_p.i.i.i.i.i559 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %ut, i64 0, i32 3, i32 0, i32 0
  %171 = load i8*, i8** %_M_p.i.i.i.i.i559, align 8, !tbaa !42
  %172 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %ut, i64 0, i32 3, i32 2
  %arraydecay.i.i.i.i.i560 = bitcast %union.anon.6.245.474.703* %172 to i8*
  %cmp.i.i.i.i561 = icmp eq i8* %171, %arraydecay.i.i.i.i.i560
  br i1 %cmp.i.i.i.i561, label %_ZN4pbbs5timerD2Ev.exit566, label %if.then.i.i.i565

if.then.i.i.i565:                                 ; preds = %_ZN4pbbs5timerD2Ev.exit557
  call void @_ZdlPv(i8* %171) #23
  br label %_ZN4pbbs5timerD2Ev.exit566

_ZN4pbbs5timerD2Ev.exit566:                       ; preds = %if.then.i.i.i565, %_ZN4pbbs5timerD2Ev.exit557
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %62) #23
  %_M_p.i.i.i.i.i568 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %pc, i64 0, i32 3, i32 0, i32 0
  %173 = load i8*, i8** %_M_p.i.i.i.i.i568, align 8, !tbaa !42
  %174 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %pc, i64 0, i32 3, i32 2
  %arraydecay.i.i.i.i.i569 = bitcast %union.anon.6.245.474.703* %174 to i8*
  %cmp.i.i.i.i570 = icmp eq i8* %173, %arraydecay.i.i.i.i.i569
  br i1 %cmp.i.i.i.i570, label %_ZN4pbbs5timerD2Ev.exit575, label %if.then.i.i.i574

if.then.i.i.i574:                                 ; preds = %_ZN4pbbs5timerD2Ev.exit566
  call void @_ZdlPv(i8* %173) #23
  br label %_ZN4pbbs5timerD2Ev.exit575

_ZN4pbbs5timerD2Ev.exit575:                       ; preds = %if.then.i.i.i574, %_ZN4pbbs5timerD2Ev.exit566
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %38) #23
  %parents_changed.0.load.pr = load i8, i8* %parents_changed, align 1
  %tobool = icmp eq i8 %parents_changed.0.load.pr, 0
  br i1 %tobool, label %while.end.tf, label %while.body

lpad13.loopexit:                                  ; preds = %call1.i.noexc, %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i, %.noexc41, %if.end.i.i.i, %invoke.cont14, %while.body
  %lpad.loopexit7 = landingpad { i8*, i32 }
          cleanup
  br label %lpad13

lpad13.loopexit.split-lp:                         ; preds = %if.then.i.i.i39
  %lpad.loopexit.split-lp8 = landingpad { i8*, i32 }
          cleanup
  br label %lpad13

lpad13:                                           ; preds = %lpad13.loopexit.split-lp, %lpad13.loopexit
  %lpad.phi9 = phi { i8*, i32 } [ %lpad.loopexit7, %lpad13.loopexit ], [ %lpad.loopexit.split-lp8, %lpad13.loopexit.split-lp ]
  %175 = extractvalue { i8*, i32 } %lpad.phi9, 0
  %176 = extractvalue { i8*, i32 } %lpad.phi9, 1
  br label %ehcleanup157

lpad23:                                           ; preds = %invoke.cont18
  %.lcssa84 = phi i8* [ %38, %invoke.cont18 ]
  %arraydecay.i.i.lcssa = phi i8* [ %arraydecay.i.i, %invoke.cont18 ]
  %_M_p.i.i.i.i.i.lcssa = phi i8** [ %_M_p.i.i.i.i.i, %invoke.cont18 ]
  %177 = landingpad { i8*, i32 }
          cleanup
  %178 = extractvalue { i8*, i32 } %177, 0
  %179 = extractvalue { i8*, i32 } %177, 1
  %180 = load i8*, i8** %_M_p.i.i.i.i.i.lcssa, align 8, !tbaa !42
  %cmp.i.i.i578 = icmp eq i8* %180, %arraydecay.i.i.lcssa
  br i1 %cmp.i.i.i578, label %ehcleanup152, label %if.then.i.i582

if.then.i.i582:                                   ; preds = %lpad23
  call void @_ZdlPv(i8* %180) #23
  br label %ehcleanup152

lpad26:                                           ; preds = %invoke.cont31.tfend, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
  %.lcssa85 = phi i8* [ %38, %invoke.cont31.tfend ], [ %38, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit ]
  %181 = landingpad { i8*, i32 }
          cleanup
  br label %lpad26.body

lpad26.body:                                      ; preds = %lpad26, %lpad2654
  %182 = phi i8* [ %.lcssa85, %lpad26 ], [ %52, %lpad2654 ]
  %eh.lpad-body = phi { i8*, i32 } [ %181, %lpad26 ], [ %lpad.phi6, %lpad2654 ]
  %183 = extractvalue { i8*, i32 } %eh.lpad-body, 0
  %184 = extractvalue { i8*, i32 } %eh.lpad-body, 1
  br label %ehcleanup151

lpad38:                                           ; preds = %invoke.cont32
  %.lcssa134 = phi i8* [ %54, %invoke.cont32 ]
  %arraydecay.i.i60.lcssa = phi i8* [ %arraydecay.i.i60, %invoke.cont32 ]
  %_M_p.i.i.i.i.i73.lcssa = phi i8** [ %_M_p.i.i.i.i.i73, %invoke.cont32 ]
  %.lcssa88 = phi i8* [ %38, %invoke.cont32 ]
  %185 = landingpad { i8*, i32 }
          cleanup
  %186 = extractvalue { i8*, i32 } %185, 0
  %187 = extractvalue { i8*, i32 } %185, 1
  %188 = load i8*, i8** %_M_p.i.i.i.i.i73.lcssa, align 8, !tbaa !42
  %cmp.i.i.i586 = icmp eq i8* %188, %arraydecay.i.i60.lcssa
  br i1 %cmp.i.i.i586, label %ehcleanup41, label %if.then.i.i590

if.then.i.i590:                                   ; preds = %lpad38
  call void @_ZdlPv(i8* %188) #23
  br label %ehcleanup41

ehcleanup41:                                      ; preds = %if.then.i.i590, %lpad38
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.lcssa134) #23
  br label %ehcleanup151

lpad48:                                           ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96
  %.lcssa178 = phi i8* [ %62, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96 ]
  %arraydecay.i.i99.lcssa = phi i8* [ %arraydecay.i.i99, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96 ]
  %_M_p.i.i.i.i.i112.lcssa = phi i8** [ %_M_p.i.i.i.i.i112, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96 ]
  %.lcssa89 = phi i8* [ %38, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit96 ]
  %189 = landingpad { i8*, i32 }
          cleanup
  %190 = extractvalue { i8*, i32 } %189, 0
  %191 = extractvalue { i8*, i32 } %189, 1
  %192 = load i8*, i8** %_M_p.i.i.i.i.i112.lcssa, align 8, !tbaa !42
  %cmp.i.i.i594 = icmp eq i8* %192, %arraydecay.i.i99.lcssa
  br i1 %cmp.i.i.i594, label %ehcleanup150, label %if.then.i.i598

if.then.i.i598:                                   ; preds = %lpad48
  call void @_ZdlPv(i8* %192) #23
  br label %ehcleanup150

lpad53:                                           ; preds = %invoke.cont62.tfend, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit135
  %.lcssa179 = phi i8* [ %62, %invoke.cont62.tfend ], [ %62, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit135 ]
  %.lcssa90 = phi i8* [ %38, %invoke.cont62.tfend ], [ %38, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit135 ]
  %193 = landingpad { i8*, i32 }
          cleanup
  br label %lpad53.body

lpad53.body:                                      ; preds = %lpad53, %lpad53150
  %194 = phi i8* [ %.lcssa179, %lpad53 ], [ %72, %lpad53150 ]
  %195 = phi i8* [ %.lcssa90, %lpad53 ], [ %73, %lpad53150 ]
  %eh.lpad-body65 = phi { i8*, i32 } [ %193, %lpad53 ], [ %lpad.phi3, %lpad53150 ]
  %196 = extractvalue { i8*, i32 } %eh.lpad-body65, 0
  %197 = extractvalue { i8*, i32 } %eh.lpad-body65, 1
  br label %ehcleanup149

lpad69:                                           ; preds = %invoke.cont63
  %.lcssa213 = phi i8* [ %91, %invoke.cont63 ]
  %arraydecay.i.i174.lcssa = phi i8* [ %arraydecay.i.i174, %invoke.cont63 ]
  %_M_p.i.i.i.i.i187.lcssa = phi i8** [ %_M_p.i.i.i.i.i187, %invoke.cont63 ]
  %.lcssa182 = phi i8* [ %62, %invoke.cont63 ]
  %.lcssa93 = phi i8* [ %38, %invoke.cont63 ]
  %198 = landingpad { i8*, i32 }
          cleanup
  %199 = extractvalue { i8*, i32 } %198, 0
  %200 = extractvalue { i8*, i32 } %198, 1
  %201 = load i8*, i8** %_M_p.i.i.i.i.i187.lcssa, align 8, !tbaa !42
  %cmp.i.i.i610 = icmp eq i8* %201, %arraydecay.i.i174.lcssa
  br i1 %cmp.i.i.i610, label %ehcleanup72, label %if.then.i.i614

if.then.i.i614:                                   ; preds = %lpad69
  call void @_ZdlPv(i8* %201) #23
  br label %ehcleanup72

ehcleanup72:                                      ; preds = %if.then.i.i614, %lpad69
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.lcssa213) #23
  br label %ehcleanup149

lpad79:                                           ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210
  %.lcssa242 = phi i8* [ %99, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210 ]
  %arraydecay.i.i217.lcssa = phi i8* [ %arraydecay.i.i217, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210 ]
  %_M_p.i.i.i.i.i230.lcssa = phi i8** [ %_M_p.i.i.i.i.i230, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210 ]
  %.lcssa183 = phi i8* [ %62, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210 ]
  %.lcssa94 = phi i8* [ %38, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit210 ]
  %202 = landingpad { i8*, i32 }
          cleanup
  %203 = extractvalue { i8*, i32 } %202, 0
  %204 = extractvalue { i8*, i32 } %202, 1
  %205 = load i8*, i8** %_M_p.i.i.i.i.i230.lcssa, align 8, !tbaa !42
  %cmp.i.i.i624 = icmp eq i8* %205, %arraydecay.i.i217.lcssa
  br i1 %cmp.i.i.i624, label %ehcleanup148, label %if.then.i.i628

if.then.i.i628:                                   ; preds = %lpad79
  call void @_ZdlPv(i8* %205) #23
  br label %ehcleanup148

lpad84:                                           ; preds = %invoke.cont89, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit253
  %.lcssa243 = phi i8* [ %99, %invoke.cont89 ], [ %99, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit253 ]
  %.lcssa184 = phi i8* [ %62, %invoke.cont89 ], [ %62, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit253 ]
  %.lcssa95 = phi i8* [ %38, %invoke.cont89 ], [ %38, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit253 ]
  %206 = landingpad { i8*, i32 }
          cleanup
  br label %lpad84.body

lpad84.body:                                      ; preds = %lpad84, %lpad84274
  %207 = phi i8* [ %.lcssa243, %lpad84 ], [ %109, %lpad84274 ]
  %208 = phi i8* [ %.lcssa184, %lpad84 ], [ %110, %lpad84274 ]
  %209 = phi i8* [ %.lcssa95, %lpad84 ], [ %111, %lpad84274 ]
  %eh.lpad-body66 = phi { i8*, i32 } [ %206, %lpad84 ], [ %lpad.phi, %lpad84274 ]
  %210 = extractvalue { i8*, i32 } %eh.lpad-body66, 0
  %211 = extractvalue { i8*, i32 } %eh.lpad-body66, 1
  br label %ehcleanup147

lpad96:                                           ; preds = %invoke.cont90
  %.lcssa246 = phi i8* [ %99, %invoke.cont90 ]
  %.lcssa187 = phi i8* [ %62, %invoke.cont90 ]
  %.lcssa98 = phi i8* [ %38, %invoke.cont90 ]
  %.lcssa = phi i8* [ %113, %invoke.cont90 ]
  %arraydecay.i.i285.lcssa = phi i8* [ %arraydecay.i.i285, %invoke.cont90 ]
  %_M_p.i.i.i.i.i298.lcssa = phi i8** [ %_M_p.i.i.i.i.i298, %invoke.cont90 ]
  %212 = landingpad { i8*, i32 }
          cleanup
  %213 = extractvalue { i8*, i32 } %212, 0
  %214 = extractvalue { i8*, i32 } %212, 1
  %215 = load i8*, i8** %_M_p.i.i.i.i.i298.lcssa, align 8, !tbaa !42
  %cmp.i.i.i640 = icmp eq i8* %215, %arraydecay.i.i285.lcssa
  br i1 %cmp.i.i.i640, label %ehcleanup99, label %if.then.i.i644

if.then.i.i644:                                   ; preds = %lpad96
  call void @_ZdlPv(i8* %215) #23
  br label %ehcleanup99

ehcleanup99:                                      ; preds = %if.then.i.i644, %lpad96
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.lcssa) #23
  br label %ehcleanup147

lpad110:                                          ; preds = %invoke.cont105.tfend
  %.lcssa247 = phi i8* [ %99, %invoke.cont105.tfend ]
  %.lcssa188 = phi i8* [ %62, %invoke.cont105.tfend ]
  %.lcssa99 = phi i8* [ %38, %invoke.cont105.tfend ]
  %.lcssa33 = phi i8* [ %129, %invoke.cont105.tfend ]
  %arraydecay.i.i390.lcssa = phi i8* [ %arraydecay.i.i390, %invoke.cont105.tfend ]
  %_M_p.i.i.i.i.i403.lcssa = phi i8** [ %_M_p.i.i.i.i.i403, %invoke.cont105.tfend ]
  %216 = landingpad { i8*, i32 }
          cleanup
  %217 = extractvalue { i8*, i32 } %216, 0
  %218 = extractvalue { i8*, i32 } %216, 1
  %219 = load i8*, i8** %_M_p.i.i.i.i.i403.lcssa, align 8, !tbaa !42
  %cmp.i.i.i632 = icmp eq i8* %219, %arraydecay.i.i390.lcssa
  br i1 %cmp.i.i.i632, label %ehcleanup146, label %if.then.i.i636

if.then.i.i636:                                   ; preds = %lpad110
  call void @_ZdlPv(i8* %219) #23
  br label %ehcleanup146

lpad115:                                          ; preds = %_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426
  %.lcssa248 = phi i8* [ %99, %_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500 ], [ %99, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426 ]
  %.lcssa189 = phi i8* [ %62, %_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500 ], [ %62, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426 ]
  %.lcssa100 = phi i8* [ %38, %_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500 ], [ %38, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426 ]
  %.lcssa34 = phi i8* [ %129, %_ZN4pbbs8sequenceISt4pairIjjEED2Ev.exit500 ], [ %129, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit426 ]
  %220 = landingpad { i8*, i32 }
          cleanup
  %221 = extractvalue { i8*, i32 } %220, 0
  %222 = extractvalue { i8*, i32 } %220, 1
  br label %ehcleanup145

lpad124:                                          ; preds = %invoke.cont121.tfend
  %.lcssa249 = phi i8* [ %99, %invoke.cont121.tfend ]
  %.lcssa190 = phi i8* [ %62, %invoke.cont121.tfend ]
  %.lcssa101 = phi i8* [ %38, %invoke.cont121.tfend ]
  %.lcssa41 = phi i8* [ %145, %invoke.cont121.tfend ]
  %.lcssa38 = phi i8* [ %137, %invoke.cont121.tfend ]
  %.lcssa35 = phi i8* [ %129, %invoke.cont121.tfend ]
  %223 = landingpad { i8*, i32 }
          cleanup
  %224 = extractvalue { i8*, i32 } %223, 0
  %225 = extractvalue { i8*, i32 } %223, 1
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %.lcssa41) #23
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %.lcssa38) #23
  br label %ehcleanup145

lpad139:                                          ; preds = %invoke.cont133
  %.lcssa251 = phi i8* [ %99, %invoke.cont133 ]
  %.lcssa192 = phi i8* [ %62, %invoke.cont133 ]
  %.lcssa103 = phi i8* [ %38, %invoke.cont133 ]
  %.lcssa45 = phi i8* [ %159, %invoke.cont133 ]
  %arraydecay.i.i503.lcssa = phi i8* [ %arraydecay.i.i503, %invoke.cont133 ]
  %_M_p.i.i.i.i.i516.lcssa = phi i8** [ %_M_p.i.i.i.i.i516, %invoke.cont133 ]
  %.lcssa37 = phi i8* [ %129, %invoke.cont133 ]
  %226 = landingpad { i8*, i32 }
          cleanup
  %227 = extractvalue { i8*, i32 } %226, 0
  %228 = extractvalue { i8*, i32 } %226, 1
  %229 = load i8*, i8** %_M_p.i.i.i.i.i516.lcssa, align 8, !tbaa !42
  %cmp.i.i.i602 = icmp eq i8* %229, %arraydecay.i.i503.lcssa
  br i1 %cmp.i.i.i602, label %ehcleanup142, label %if.then.i.i606

if.then.i.i606:                                   ; preds = %lpad139
  call void @_ZdlPv(i8* %229) #23
  br label %ehcleanup142

ehcleanup142:                                     ; preds = %if.then.i.i606, %lpad139
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %.lcssa45) #23
  br label %ehcleanup145

ehcleanup145:                                     ; preds = %ehcleanup142, %lpad124, %lpad115
  %230 = phi i8* [ %.lcssa251, %ehcleanup142 ], [ %.lcssa248, %lpad115 ], [ %.lcssa249, %lpad124 ]
  %231 = phi i8* [ %.lcssa192, %ehcleanup142 ], [ %.lcssa189, %lpad115 ], [ %.lcssa190, %lpad124 ]
  %232 = phi i8* [ %.lcssa103, %ehcleanup142 ], [ %.lcssa100, %lpad115 ], [ %.lcssa101, %lpad124 ]
  %233 = phi i8* [ %.lcssa37, %ehcleanup142 ], [ %.lcssa34, %lpad115 ], [ %.lcssa35, %lpad124 ]
  %ehselector.slot.10 = phi i32 [ %228, %ehcleanup142 ], [ %222, %lpad115 ], [ %225, %lpad124 ]
  %exn.slot.10 = phi i8* [ %227, %ehcleanup142 ], [ %221, %lpad115 ], [ %224, %lpad124 ]
  %_M_p.i.i.i.i.i467 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %at, i64 0, i32 3, i32 0, i32 0
  %234 = load i8*, i8** %_M_p.i.i.i.i.i467, align 8, !tbaa !42
  %235 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %at, i64 0, i32 3, i32 2
  %arraydecay.i.i.i.i.i468 = bitcast %union.anon.6.245.474.703* %235 to i8*
  %cmp.i.i.i.i469 = icmp eq i8* %234, %arraydecay.i.i.i.i.i468
  br i1 %cmp.i.i.i.i469, label %ehcleanup146, label %if.then.i.i.i473

if.then.i.i.i473:                                 ; preds = %ehcleanup145
  call void @_ZdlPv(i8* %234) #23
  br label %ehcleanup146

ehcleanup146:                                     ; preds = %if.then.i.i.i473, %ehcleanup145, %if.then.i.i636, %lpad110
  %236 = phi i8* [ %.lcssa247, %lpad110 ], [ %.lcssa247, %if.then.i.i636 ], [ %230, %ehcleanup145 ], [ %230, %if.then.i.i.i473 ]
  %237 = phi i8* [ %.lcssa188, %lpad110 ], [ %.lcssa188, %if.then.i.i636 ], [ %231, %ehcleanup145 ], [ %231, %if.then.i.i.i473 ]
  %238 = phi i8* [ %.lcssa99, %lpad110 ], [ %.lcssa99, %if.then.i.i636 ], [ %232, %ehcleanup145 ], [ %232, %if.then.i.i.i473 ]
  %239 = phi i8* [ %.lcssa33, %lpad110 ], [ %.lcssa33, %if.then.i.i636 ], [ %233, %ehcleanup145 ], [ %233, %if.then.i.i.i473 ]
  %ehselector.slot.11 = phi i32 [ %218, %lpad110 ], [ %218, %if.then.i.i636 ], [ %ehselector.slot.10, %ehcleanup145 ], [ %ehselector.slot.10, %if.then.i.i.i473 ]
  %exn.slot.11 = phi i8* [ %217, %lpad110 ], [ %217, %if.then.i.i636 ], [ %exn.slot.10, %ehcleanup145 ], [ %exn.slot.10, %if.then.i.i.i473 ]
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %239) #23
  br label %ehcleanup147

ehcleanup147:                                     ; preds = %ehcleanup146, %ehcleanup99, %lpad84.body
  %240 = phi i8* [ %236, %ehcleanup146 ], [ %207, %lpad84.body ], [ %.lcssa246, %ehcleanup99 ]
  %241 = phi i8* [ %237, %ehcleanup146 ], [ %208, %lpad84.body ], [ %.lcssa187, %ehcleanup99 ]
  %242 = phi i8* [ %238, %ehcleanup146 ], [ %209, %lpad84.body ], [ %.lcssa98, %ehcleanup99 ]
  %ehselector.slot.12 = phi i32 [ %ehselector.slot.11, %ehcleanup146 ], [ %211, %lpad84.body ], [ %214, %ehcleanup99 ]
  %exn.slot.12 = phi i8* [ %exn.slot.11, %ehcleanup146 ], [ %210, %lpad84.body ], [ %213, %ehcleanup99 ]
  %_M_p.i.i.i.i.i429 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %sc, i64 0, i32 3, i32 0, i32 0
  %243 = load i8*, i8** %_M_p.i.i.i.i.i429, align 8, !tbaa !42
  %244 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %sc, i64 0, i32 3, i32 2
  %arraydecay.i.i.i.i.i430 = bitcast %union.anon.6.245.474.703* %244 to i8*
  %cmp.i.i.i.i431 = icmp eq i8* %243, %arraydecay.i.i.i.i.i430
  br i1 %cmp.i.i.i.i431, label %ehcleanup148, label %if.then.i.i.i435

if.then.i.i.i435:                                 ; preds = %ehcleanup147
  call void @_ZdlPv(i8* %243) #23
  br label %ehcleanup148

ehcleanup148:                                     ; preds = %if.then.i.i.i435, %ehcleanup147, %if.then.i.i628, %lpad79
  %245 = phi i8* [ %.lcssa242, %lpad79 ], [ %.lcssa242, %if.then.i.i628 ], [ %240, %ehcleanup147 ], [ %240, %if.then.i.i.i435 ]
  %246 = phi i8* [ %.lcssa183, %lpad79 ], [ %.lcssa183, %if.then.i.i628 ], [ %241, %ehcleanup147 ], [ %241, %if.then.i.i.i435 ]
  %247 = phi i8* [ %.lcssa94, %lpad79 ], [ %.lcssa94, %if.then.i.i628 ], [ %242, %ehcleanup147 ], [ %242, %if.then.i.i.i435 ]
  %ehselector.slot.13 = phi i32 [ %204, %lpad79 ], [ %204, %if.then.i.i628 ], [ %ehselector.slot.12, %ehcleanup147 ], [ %ehselector.slot.12, %if.then.i.i.i435 ]
  %exn.slot.13 = phi i8* [ %203, %lpad79 ], [ %203, %if.then.i.i628 ], [ %exn.slot.12, %ehcleanup147 ], [ %exn.slot.12, %if.then.i.i.i435 ]
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %245) #23
  br label %ehcleanup149

ehcleanup149:                                     ; preds = %ehcleanup148, %ehcleanup72, %lpad53.body
  %248 = phi i8* [ %246, %ehcleanup148 ], [ %.lcssa182, %ehcleanup72 ], [ %194, %lpad53.body ]
  %249 = phi i8* [ %247, %ehcleanup148 ], [ %.lcssa93, %ehcleanup72 ], [ %195, %lpad53.body ]
  %ehselector.slot.14 = phi i32 [ %ehselector.slot.13, %ehcleanup148 ], [ %200, %ehcleanup72 ], [ %197, %lpad53.body ]
  %exn.slot.14 = phi i8* [ %exn.slot.13, %ehcleanup148 ], [ %199, %ehcleanup72 ], [ %196, %lpad53.body ]
  %_M_p.i.i.i.i.i380 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %ut, i64 0, i32 3, i32 0, i32 0
  %250 = load i8*, i8** %_M_p.i.i.i.i.i380, align 8, !tbaa !42
  %251 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %ut, i64 0, i32 3, i32 2
  %arraydecay.i.i.i.i.i381 = bitcast %union.anon.6.245.474.703* %251 to i8*
  %cmp.i.i.i.i382 = icmp eq i8* %250, %arraydecay.i.i.i.i.i381
  br i1 %cmp.i.i.i.i382, label %ehcleanup150, label %if.then.i.i.i386

if.then.i.i.i386:                                 ; preds = %ehcleanup149
  call void @_ZdlPv(i8* %250) #23
  br label %ehcleanup150

ehcleanup150:                                     ; preds = %if.then.i.i.i386, %ehcleanup149, %if.then.i.i598, %lpad48
  %252 = phi i8* [ %.lcssa178, %lpad48 ], [ %.lcssa178, %if.then.i.i598 ], [ %248, %ehcleanup149 ], [ %248, %if.then.i.i.i386 ]
  %253 = phi i8* [ %.lcssa89, %lpad48 ], [ %.lcssa89, %if.then.i.i598 ], [ %249, %ehcleanup149 ], [ %249, %if.then.i.i.i386 ]
  %ehselector.slot.15 = phi i32 [ %191, %lpad48 ], [ %191, %if.then.i.i598 ], [ %ehselector.slot.14, %ehcleanup149 ], [ %ehselector.slot.14, %if.then.i.i.i386 ]
  %exn.slot.15 = phi i8* [ %190, %lpad48 ], [ %190, %if.then.i.i598 ], [ %exn.slot.14, %ehcleanup149 ], [ %exn.slot.14, %if.then.i.i.i386 ]
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %252) #23
  br label %ehcleanup151

ehcleanup151:                                     ; preds = %ehcleanup150, %ehcleanup41, %lpad26.body
  %254 = phi i8* [ %253, %ehcleanup150 ], [ %.lcssa88, %ehcleanup41 ], [ %182, %lpad26.body ]
  %ehselector.slot.16 = phi i32 [ %ehselector.slot.15, %ehcleanup150 ], [ %187, %ehcleanup41 ], [ %184, %lpad26.body ]
  %exn.slot.16 = phi i8* [ %exn.slot.15, %ehcleanup150 ], [ %186, %ehcleanup41 ], [ %183, %lpad26.body ]
  %_M_p.i.i.i.i.i376 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %pc, i64 0, i32 3, i32 0, i32 0
  %255 = load i8*, i8** %_M_p.i.i.i.i.i376, align 8, !tbaa !42
  %256 = getelementptr inbounds %"struct.pbbs::timer.8.247.476.705", %"struct.pbbs::timer.8.247.476.705"* %pc, i64 0, i32 3, i32 2
  %arraydecay.i.i.i.i.i = bitcast %union.anon.6.245.474.703* %256 to i8*
  %cmp.i.i.i.i377 = icmp eq i8* %255, %arraydecay.i.i.i.i.i
  br i1 %cmp.i.i.i.i377, label %ehcleanup152, label %if.then.i.i.i378

if.then.i.i.i378:                                 ; preds = %ehcleanup151
  call void @_ZdlPv(i8* %255) #23
  br label %ehcleanup152

ehcleanup152:                                     ; preds = %if.then.i.i.i378, %ehcleanup151, %if.then.i.i582, %lpad23
  %257 = phi i8* [ %.lcssa84, %lpad23 ], [ %.lcssa84, %if.then.i.i582 ], [ %254, %ehcleanup151 ], [ %254, %if.then.i.i.i378 ]
  %ehselector.slot.17 = phi i32 [ %179, %lpad23 ], [ %179, %if.then.i.i582 ], [ %ehselector.slot.16, %ehcleanup151 ], [ %ehselector.slot.16, %if.then.i.i.i378 ]
  %exn.slot.17 = phi i8* [ %178, %lpad23 ], [ %178, %if.then.i.i582 ], [ %exn.slot.16, %ehcleanup151 ], [ %exn.slot.16, %if.then.i.i.i378 ]
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %257) #23
  br label %ehcleanup157

while.end.tf:                                     ; preds = %_ZN4pbbs5timerD2Ev.exit575
  %sub.ptr.sub.i374 = sub i64 %19, %18
  %sub.ptr.div.i375 = sdiv exact i64 %sub.ptr.sub.i374, 12
  %cmp1.i356 = icmp sgt i64 %sub.ptr.sub.i374, 0
  br i1 %cmp1.i356, label %pfor.cond.i358.preheader, label %invoke.cont156.tfend

pfor.cond.i358.preheader:                         ; preds = %while.end.tf
  br label %pfor.cond.i358

pfor.cond.i358:                                   ; preds = %pfor.inc.i369, %pfor.cond.i358.preheader
  %__begin.0.i357 = phi i64 [ %inc.i367, %pfor.inc.i369 ], [ 0, %pfor.cond.i358.preheader ]
  detach within %syncreg.i.i, label %pfor.body.entry.i359, label %pfor.inc.i369

pfor.body.entry.i359:                             ; preds = %pfor.cond.i358
  %s.i.i.i360 = getelementptr inbounds %"struct.pbbs::range.150.157.396.625.854", %"struct.pbbs::range.150.157.396.625.854"* %updates, i64 0, i32 0
  %258 = load %"class.std::tuple.63.93.332.561.790"*, %"class.std::tuple.63.93.332.561.790"** %s.i.i.i360, align 8, !tbaa !10
  %.sroa.3.0..sroa_idx38.i.i = getelementptr inbounds %"class.std::tuple.63.93.332.561.790", %"class.std::tuple.63.93.332.561.790"* %258, i64 %__begin.0.i357, i32 0, i32 0, i32 1, i32 0
  %.sroa.3.0.copyload.i.i = load i32, i32* %.sroa.3.0..sroa_idx38.i.i, align 4
  %.sroa.7.0..sroa_idx43.i.i = getelementptr inbounds %"class.std::tuple.63.93.332.561.790", %"class.std::tuple.63.93.332.561.790"* %258, i64 %__begin.0.i357, i32 0, i32 1, i32 0
  %.sroa.7.0.copyload.i.i = load i32, i32* %.sroa.7.0..sroa_idx43.i.i, align 4
  %conv.i.i362 = zext i32 %.sroa.7.0.copyload.i.i to i64
  %s.i32.i.i = getelementptr inbounds %"struct.pbbs::sequence.39.278.507.736", %"struct.pbbs::sequence.39.278.507.736"* %parents, i64 0, i32 0
  %259 = load i32*, i32** %s.i32.i.i, align 8, !tbaa !53
  %arrayidx.i33.i.i252 = getelementptr inbounds i32, i32* %259, i64 %conv.i.i362
  %260 = load i32, i32* %arrayidx.i33.i.i252, align 4, !tbaa !54
  %conv8.i.i253 = zext i32 %260 to i64
  %arrayidx.i29.i.i254 = getelementptr inbounds i32, i32* %259, i64 %conv8.i.i253
  %261 = load i32, i32* %arrayidx.i29.i.i254, align 4, !tbaa !54
  %cmp.i.i364255 = icmp eq i32 %260, %261
  br i1 %cmp.i.i364255, label %while.cond16.i.i.preheader, label %while.body.i.i.lr.ph

while.body.i.i.lr.ph:                             ; preds = %pfor.body.entry.i359
  br label %while.body.i.i

while.cond.i.i.while.cond16.i.i.preheader_crit_edge: ; preds = %while.body.i.i
  %split = phi i32** [ %s.i32.i.i, %while.body.i.i ]
  br label %while.cond16.i.i.preheader

while.cond16.i.i.preheader:                       ; preds = %while.cond.i.i.while.cond16.i.i.preheader_crit_edge, %pfor.body.entry.i359
  %s.i32.i.i.lcssa = phi i32** [ %split, %while.cond.i.i.while.cond16.i.i.preheader_crit_edge ], [ %s.i32.i.i, %pfor.body.entry.i359 ]
  %conv17.i.i = zext i32 %.sroa.3.0.copyload.i.i to i64
  %262 = load i32*, i32** %s.i32.i.i.lcssa, align 8, !tbaa !53
  %arrayidx.i21.i.i257 = getelementptr inbounds i32, i32* %262, i64 %conv17.i.i
  %263 = load i32, i32* %arrayidx.i21.i.i257, align 4, !tbaa !54
  %conv21.i.i258 = zext i32 %263 to i64
  %arrayidx.i17.i.i259 = getelementptr inbounds i32, i32* %262, i64 %conv21.i.i258
  %264 = load i32, i32* %arrayidx.i17.i.i259, align 4, !tbaa !54
  %cmp23.i.i260 = icmp eq i32 %263, %264
  br i1 %cmp23.i.i260, label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE6_clEm.exit.i, label %while.body24.i.i.lr.ph

while.body24.i.i.lr.ph:                           ; preds = %while.cond16.i.i.preheader
  br label %while.body24.i.i

while.body.i.i:                                   ; preds = %while.body.i.i, %while.body.i.i.lr.ph
  %265 = phi i32 [ %261, %while.body.i.i.lr.ph ], [ %268, %while.body.i.i ]
  %arrayidx.i33.i.i256 = phi i32* [ %arrayidx.i33.i.i252, %while.body.i.i.lr.ph ], [ %arrayidx.i33.i.i, %while.body.i.i ]
  store i32 %265, i32* %arrayidx.i33.i.i256, align 4, !tbaa !54
  %266 = load i32*, i32** %s.i32.i.i, align 8, !tbaa !53
  %arrayidx.i33.i.i = getelementptr inbounds i32, i32* %266, i64 %conv.i.i362
  %267 = load i32, i32* %arrayidx.i33.i.i, align 4, !tbaa !54
  %conv8.i.i = zext i32 %267 to i64
  %arrayidx.i29.i.i = getelementptr inbounds i32, i32* %266, i64 %conv8.i.i
  %268 = load i32, i32* %arrayidx.i29.i.i, align 4, !tbaa !54
  %cmp.i.i364 = icmp eq i32 %267, %268
  br i1 %cmp.i.i364, label %while.cond.i.i.while.cond16.i.i.preheader_crit_edge, label %while.body.i.i

while.body24.i.i:                                 ; preds = %while.body24.i.i, %while.body24.i.i.lr.ph
  %269 = phi i32 [ %264, %while.body24.i.i.lr.ph ], [ %272, %while.body24.i.i ]
  %arrayidx.i21.i.i261 = phi i32* [ %arrayidx.i21.i.i257, %while.body24.i.i.lr.ph ], [ %arrayidx.i21.i.i, %while.body24.i.i ]
  store i32 %269, i32* %arrayidx.i21.i.i261, align 4, !tbaa !54
  %270 = load i32*, i32** %s.i32.i.i.lcssa, align 8, !tbaa !53
  %arrayidx.i21.i.i = getelementptr inbounds i32, i32* %270, i64 %conv17.i.i
  %271 = load i32, i32* %arrayidx.i21.i.i, align 4, !tbaa !54
  %conv21.i.i = zext i32 %271 to i64
  %arrayidx.i17.i.i = getelementptr inbounds i32, i32* %270, i64 %conv21.i.i
  %272 = load i32, i32* %arrayidx.i17.i.i, align 4, !tbaa !54
  %cmp23.i.i = icmp eq i32 %271, %272
  br i1 %cmp23.i.i, label %while.cond16.i.i._ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE6_clEm.exit.i_crit_edge, label %while.body24.i.i

while.cond16.i.i._ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE6_clEm.exit.i_crit_edge: ; preds = %while.body24.i.i
  br label %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE6_clEm.exit.i

_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE6_clEm.exit.i: ; preds = %while.cond16.i.i._ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE6_clEm.exit.i_crit_edge, %while.cond16.i.i.preheader
  reattach within %syncreg.i.i, label %pfor.inc.i369

pfor.inc.i369:                                    ; preds = %_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE6_clEm.exit.i, %pfor.cond.i358
  %inc.i367 = add nuw nsw i64 %__begin.0.i357, 1
  %cmp4.i368 = icmp slt i64 %inc.i367, %sub.ptr.div.i375
  br i1 %cmp4.i368, label %pfor.cond.i358, label %pfor.cond.cleanup.i370, !llvm.loop !64

pfor.cond.cleanup.i370:                           ; preds = %pfor.inc.i369
  sync within %syncreg.i.i, label %sync.continue.i371

sync.continue.i371:                               ; preds = %pfor.cond.cleanup.i370
  call void @llvm.sync.unwind(token %syncreg.i.i) #23
  br label %invoke.cont156.tfend

invoke.cont156.tfend:                             ; preds = %sync.continue.i371, %while.end.tf
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %parents_changed)
  %273 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  %cmp.i.i324 = icmp eq %"struct.std::pair.171.38.277.506.735"* %273, null
  br i1 %cmp.i.i324, label %_ZN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEED2Ev.exit282, label %if.then.i.i326

if.then.i.i326:                                   ; preds = %invoke.cont156.tfend
  %274 = bitcast %"struct.std::pair.171.38.277.506.735"* %273 to i8*
  call void @free(i8* %274) #23
  store %"struct.std::pair.171.38.277.506.735"* null, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  store i64 0, i64* %n.i33, align 8, !tbaa !29
  br label %_ZN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEED2Ev.exit282

_ZN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEED2Ev.exit282: ; preds = %if.then.i.i326, %invoke.cont156.tfend
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %20) #23
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %13) #23
  call void @free(i8* %call.i.i.i.i) #23
  %275 = load %"class.std::tuple.63.93.332.561.790"*, %"class.std::tuple.63.93.332.561.790"** %s.i, align 8, !tbaa !65
  %cmp.i.i.i257 = icmp eq %"class.std::tuple.63.93.332.561.790"* %275, null
  br i1 %cmp.i.i.i257, label %_ZNSt4pairIN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEEEmED2Ev.exit260, label %if.then.i.i.i259

if.then.i.i.i259:                                 ; preds = %_ZN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEED2Ev.exit282
  %276 = bitcast %"class.std::tuple.63.93.332.561.790"* %275 to i8*
  call void @free(i8* %276) #23
  store %"class.std::tuple.63.93.332.561.790"* null, %"class.std::tuple.63.93.332.561.790"** %s.i, align 8, !tbaa !65
  store i64 0, i64* %n2.i, align 8, !tbaa !21
  br label %_ZNSt4pairIN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEEEmED2Ev.exit260

_ZNSt4pairIN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEEEmED2Ev.exit260: ; preds = %if.then.i.i.i259, %_ZN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEED2Ev.exit282
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %0) #23
  ret void

ehcleanup157:                                     ; preds = %ehcleanup152, %lpad13
  %ehselector.slot.18 = phi i32 [ %ehselector.slot.17, %ehcleanup152 ], [ %176, %lpad13 ]
  %exn.slot.18 = phi i8* [ %exn.slot.17, %ehcleanup152 ], [ %175, %lpad13 ]
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %parents_changed)
  %277 = load %"struct.std::pair.171.38.277.506.735"*, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  %cmp.i.i212 = icmp eq %"struct.std::pair.171.38.277.506.735"* %277, null
  br i1 %cmp.i.i212, label %ehcleanup161, label %if.then.i.i214

if.then.i.i214:                                   ; preds = %ehcleanup157
  %278 = bitcast %"struct.std::pair.171.38.277.506.735"* %277 to i8*
  call void @free(i8* %278) #23
  store %"struct.std::pair.171.38.277.506.735"* null, %"struct.std::pair.171.38.277.506.735"** %s.i30, align 8, !tbaa !27
  store i64 0, i64* %n.i33, align 8, !tbaa !29
  br label %ehcleanup161

ehcleanup161:                                     ; preds = %if.then.i.i214, %ehcleanup157
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %20) #23
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %13) #23
  call void @free(i8* %call.i.i.i.i) #23
  %279 = load %"class.std::tuple.63.93.332.561.790"*, %"class.std::tuple.63.93.332.561.790"** %s.i, align 8, !tbaa !65
  %cmp.i.i.i23 = icmp eq %"class.std::tuple.63.93.332.561.790"* %279, null
  br i1 %cmp.i.i.i23, label %_ZNSt4pairIN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEEEmED2Ev.exit, label %if.then.i.i.i24

if.then.i.i.i24:                                  ; preds = %ehcleanup161
  %280 = bitcast %"class.std::tuple.63.93.332.561.790"* %279 to i8*
  call void @free(i8* %280) #23
  store %"class.std::tuple.63.93.332.561.790"* null, %"class.std::tuple.63.93.332.561.790"** %s.i, align 8, !tbaa !65
  store i64 0, i64* %n2.i, align 8, !tbaa !21
  br label %_ZNSt4pairIN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEEEmED2Ev.exit

_ZNSt4pairIN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEEEmED2Ev.exit: ; preds = %if.then.i.i.i24, %ehcleanup161
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %0) #23
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.18, 0
  %lpad.val169 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.18, 1
  resume { i8*, i32 } %lpad.val169
}

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_8sequenceIjEC1IZN4gbbs9connectit16run_abstract_algINS4_10edge_arrayINS_5emptyEEENS4_2lt18LiuTarjanAlgorithmIPFbjjRS2_SC_ELNS4_22LiuTarjanConnectOptionE1EPFvjSC_SC_ELNS4_21LiuTarjanUpdateOptionE1EPFvjSC_ELNS4_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjSC_ELNS4_20LiuTarjanAlterOptionE0ES9_EELb0ELb1EEEDaRT_mRNS1_ISM_IJjjNS4_10UpdateTypeEEEEEmmbRT0_EUlmE_EEmSS_EUlmE_EEvllSS_lb(i64, i64, %"struct.pbbs::sequence.39.278.507.736"*, %class.anon.195.189.428.657.886*) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs6filterINS_8sequenceISt4pairIjjEEEZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRNS1_IjEES9_ELNS5_22LiuTarjanConnectOptionE1EPFvjS9_S9_ELNS5_21LiuTarjanUpdateOptionE1EPFvjS9_ELNS5_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS9_ELNS5_20LiuTarjanAlterOptionE0ENS5_10edge_arrayINS_5emptyEEEE13process_batchILb1ENS_5rangeIPSJ_IJjjNS5_10UpdateTypeEEEEEEEvS9_RT0_EUlRKS3_E_EENS1_INT_10value_typeEEERKS13_SY_j(%"struct.pbbs::sequence.170.172.411.640.869"* noalias sret, %"struct.pbbs::sequence.170.172.411.640.869"* dereferenceable(16), %"struct.std::pair.171.38.277.506.735"*, i32) local_unnamed_addr #8

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_8sequenceISt4pairIjjEEC1IZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRNS1_IjEESA_ELNS6_22LiuTarjanConnectOptionE1EPFvjSA_SA_ELNS6_21LiuTarjanUpdateOptionE1EPFvjSA_ELNS6_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjSA_ELNS6_20LiuTarjanAlterOptionE0ENS6_10edge_arrayINS_5emptyEEEE13process_batchILb1ENS_5rangeIPSK_IJjjNS6_10UpdateTypeEEEEEEEvSA_RT0_EUlmE_EEmT_EUlmE_EEvllS12_lb(i64, i64, %"struct.pbbs::sequence.170.172.411.640.869"*, %class.anon.201.190.429.658.887*) unnamed_addr #9

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE1_clEm(%class.anon.203.191.430.659.888*, i64) local_unnamed_addr #11 align 2

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEE13process_batchILb1ENS2_5rangeIPSF_IJjjNS_10UpdateTypeEEEEEEEvS5_RT0_ENKUlmE3_clEm(%class.anon.205.192.431.660.889*, i64) local_unnamed_addr #11 align 2

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_6filterINS_8sequenceISt4pairIjjEEEZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRNS3_IjEESB_ELNS7_22LiuTarjanConnectOptionE1EPFvjSB_SB_ELNS7_21LiuTarjanUpdateOptionE1EPFvjSB_ELNS7_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjSB_ELNS7_20LiuTarjanAlterOptionE0ENS7_10edge_arrayINS_5emptyEEEE13process_batchILb1ENS_5rangeIPSL_IJjjNS7_10UpdateTypeEEEEEEEvSB_RT0_EUlRKS5_E_EENS3_INT_10value_typeEEERKS15_S10_jEUlmmmE_EEvmmS19_jEUlmE_EEvllS15_lb(i64, i64, %class.anon.213.195.434.663.892* nocapture readonly byval(%class.anon.213.195.434.663.892) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_6filterINS_8sequenceISt4pairIjjEEEZN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRNS3_IjEESB_ELNS7_22LiuTarjanConnectOptionE1EPFvjSB_SB_ELNS7_21LiuTarjanUpdateOptionE1EPFvjSB_ELNS7_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjSB_ELNS7_20LiuTarjanAlterOptionE0ENS7_10edge_arrayINS_5emptyEEEE13process_batchILb1ENS_5rangeIPSL_IJjjNS7_10UpdateTypeEEEEEEEvSB_RT0_EUlRKS5_E_EENS3_INT_10value_typeEEERKS15_S10_jEUlmmmE0_EEvmmS19_jEUlmE_EEvllS15_lb(i64, i64, %class.anon.214.197.436.665.894* nocapture readonly byval(%class.anon.214.197.436.665.894) align 8) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs8sequenceISt4pairIjjEE9copy_hereIPS2_EEvRKT_m(%"struct.pbbs::sequence.170.172.411.640.869"*, %"struct.std::pair.171.38.277.506.735"** dereferenceable(8), i64) local_unnamed_addr #8 align 2

declare dso_local dereferenceable(272) %"class.std::basic_ostream.23.262.491.720"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream.23.262.491.720"*, double) local_unnamed_addr #0

; Function Attrs: noreturn
declare dso_local void @_ZSt25__throw_bad_function_callv() local_unnamed_addr #14

; Function Attrs: ssp uwtable
declare hidden void @_ZN4gbbs12sample_edgesINS_15symmetric_graphINS_16symmetric_vertexEN4pbbs5emptyEEEZNS_3RunIS5_EEdRT_NS_11commandLineEEUlRKjSB_RKS4_E_EENS_10edge_arrayINS7_11weight_typeEEES8_RT0_(%"struct.gbbs::edge_array.99.338.567.796"* noalias sret, %"struct.gbbs::symmetric_graph.5.58.297.526.755"* dereferenceable(72), %class.anon.220.199.438.667.896* dereferenceable(16)) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZN4gbbs12sample_edgesINS1_15symmetric_graphINS1_16symmetric_vertexENS_5emptyEEEZNS1_3RunIS6_EEdRT_NS1_11commandLineEEUlRKjSC_RKS5_E_EENS1_10edge_arrayINS8_11weight_typeEEES9_RT0_EUlmE_EEvllS8_lb(i64, %class.anon.225.203.442.671.900* nocapture readonly byval(%class.anon.225.203.442.671.900) align 8) unnamed_addr #11

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZN4gbbs12sample_edgesINS1_15symmetric_graphINS1_16symmetric_vertexENS_5emptyEEEZNS1_3RunIS6_EEdRT_NS1_11commandLineEEUlRKjSC_RKS5_E_EENS1_10edge_arrayINS8_11weight_typeEEES9_RT0_EUlmE0_EEvllS8_lb(i64, i64, %class.anon.229.204.443.672.901* nocapture readonly byval(%class.anon.229.204.443.672.901) align 8) unnamed_addr #11

; Function Attrs: ssp uwtable
declare hidden i32 @_ZN4pbbs6reduceINS_16delayed_sequenceIjZN4gbbs22uncompressed_neighborsINS_5emptyEE6reduceIZNS2_12sample_edgesINS2_15symmetric_graphINS2_16symmetric_vertexES4_EEZNS2_3RunISA_EEdRT_NS2_11commandLineEEUlRKjSG_RKS4_E_EENS2_10edge_arrayINSC_11weight_typeEEESD_RT0_EUlSG_SG_SI_E_NS_6monoidIZNS7_ISA_SJ_EESM_SD_SO_EUlmmE_jEEEENSN_1TESC_SN_EUlmE_EESS_EENSC_10value_typeERKSC_SN_j(%"struct.pbbs::delayed_sequence.231.207.446.675.904"* dereferenceable(32), i64, i32) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden i32 @_ZN4pbbs13reduce_serialINS_16delayed_sequenceIjZN4gbbs22uncompressed_neighborsINS_5emptyEE6reduceIZNS2_12sample_edgesINS2_15symmetric_graphINS2_16symmetric_vertexES4_EEZNS2_3RunISA_EEdRT_NS2_11commandLineEEUlRKjSG_RKS4_E_EENS2_10edge_arrayINSC_11weight_typeEEESD_RT0_EUlSG_SG_SI_E_NS_6monoidIZNS7_ISA_SJ_EESM_SD_SO_EUlmmE_jEEEENSN_1TESC_SN_EUlmE_EESS_EENSC_10value_typeERKSC_SN_(%"struct.pbbs::delayed_sequence.231.207.446.675.904"* dereferenceable(32), i64) local_unnamed_addr #8

; Function Attrs: ssp uwtable
declare hidden i32 @_ZN4pbbs6reduceINS_8sequenceIjEENS_6monoidIZN4gbbs12sample_edgesINS4_15symmetric_graphINS4_16symmetric_vertexENS_5emptyEEEZNS4_3RunIS9_EEdRT_NS4_11commandLineEEUlRKjSF_RKS8_E_EENS4_10edge_arrayINSB_11weight_typeEEESC_RT0_EUlmmE_jEEEENSB_10value_typeERKSB_SM_j(%"struct.pbbs::sequence.39.278.507.736"* dereferenceable(16), i64, i32) local_unnamed_addr #8

; Function Attrs: inlinehint ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_6reduceINS_16delayed_sequenceIjZN4gbbs22uncompressed_neighborsINS_5emptyEE6reduceIZNS4_12sample_edgesINS4_15symmetric_graphINS4_16symmetric_vertexES6_EEZNS4_3RunISC_EEdRT_NS4_11commandLineEEUlRKjSI_RKS6_E_EENS4_10edge_arrayINSE_11weight_typeEEESF_RT0_EUlSI_SI_SK_E_NS_6monoidIZNS9_ISC_SL_EESO_SF_SQ_EUlmmE_jEEEENSP_1TESE_SP_EUlmE_EESU_EENSE_10value_typeERKSE_SP_jEUlmmmE_EEvmmS10_jEUlmE_EEvllSE_lb(i64, i64, %class.anon.233.209.448.677.906* nocapture readonly byval(%class.anon.233.209.448.677.906) align 8) unnamed_addr #11

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_6reduceINS_8sequenceIjEENS_6monoidIZN4gbbs12sample_edgesINS6_15symmetric_graphINS6_16symmetric_vertexENS_5emptyEEEZNS6_3RunISB_EEdRT_NS6_11commandLineEEUlRKjSH_RKSA_E_EENS6_10edge_arrayINSD_11weight_typeEEESE_RT0_EUlmmE_jEEEENSD_10value_typeERKSD_SO_jEUlmmmE_EEvmmSU_jEUlmE_EEvllSD_lb(i64, i64, %class.anon.235.211.450.679.908* nocapture readonly byval(%class.anon.235.211.450.679.908) align 8) unnamed_addr #9

; Function Attrs: ssp uwtable
declare hidden void @_ZN4pbbs5scan_INS_5rangeIPSt5tupleIJmmEEEES5_NS_6monoidIZN4gbbs12sample_edgesINS7_15symmetric_graphINS7_16symmetric_vertexENS_5emptyEEEZNS7_3RunISC_EEdRT_NS7_11commandLineEEUlRKjSI_RKSB_E_EENS7_10edge_arrayINSE_11weight_typeEEESF_RT0_EUlRKS3_SS_E_S2_IJiiEEEEEENSE_10value_typeERKSE_OSP_RKT1_jPSW_(%"class.std::tuple.69.104.343.572.801"* noalias sret, %"struct.pbbs::range.83.118.357.586.815"* dereferenceable(16), %"struct.pbbs::range.83.118.357.586.815"* dereferenceable(16), %"struct.pbbs::monoid.228.213.452.681.910"* dereferenceable(12), i32, %"class.std::tuple.69.104.343.572.801"*) local_unnamed_addr #8

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_5scan_INS_5rangeIPSt5tupleIJmmEEEES7_NS_6monoidIZN4gbbs12sample_edgesINS9_15symmetric_graphINS9_16symmetric_vertexENS_5emptyEEEZNS9_3RunISE_EEdRT_NS9_11commandLineEEUlRKjSK_RKSD_E_EENS9_10edge_arrayINSG_11weight_typeEEESH_RT0_EUlRKS5_SU_E_S4_IJiiEEEEEENSG_10value_typeERKSG_OSR_RKT1_jPSY_EUlmmmE_EEvmmS10_jEUlmE_EEvllSG_lb(i64, i64, %class.anon.238.215.454.683.912* nocapture readonly byval(%class.anon.238.215.454.683.912) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_5scan_INS_5rangeIPSt5tupleIJmmEEEES7_NS_6monoidIZN4gbbs12sample_edgesINS9_15symmetric_graphINS9_16symmetric_vertexENS_5emptyEEEZNS9_3RunISE_EEdRT_NS9_11commandLineEEUlRKjSK_RKSD_E_EENS9_10edge_arrayINSG_11weight_typeEEESH_RT0_EUlRKS5_SU_E_S4_IJiiEEEEEENSG_10value_typeERKSG_OSR_RKT1_jPSY_EUlmmmE0_EEvmmS10_jEUlmE_EEvllSG_lb(i64, i64, %class.anon.239.217.456.685.914* nocapture readonly byval(%class.anon.239.217.456.685.914) align 8) unnamed_addr #9

; Function Attrs: inlinehint ssp uwtable
declare hidden void @_ZN4gbbs22uncompressed_neighborsIN4pbbs5emptyEE6filterIZNS_3RunINS_15symmetric_graphINS_16symmetric_vertexES2_EEEEdRT_NS_11commandLineEEUlRKjSD_RKS2_E_ZZNS_12sample_edgesIS8_SG_EENS_10edge_arrayINS9_11weight_typeEEESA_RT0_ENKUlmE0_clEmEUlmRKSt5tupleIJjS2_EEE_EEvS9_SM_PSP_(%"struct.gbbs::uncompressed_neighbors.205.444.673.902"*, %class.anon.218.198.437.666.895*, double*, %class.anon.240.218.457.686.915* dereferenceable(24), %"class.std::tuple.6.57.296.525.754"*) local_unnamed_addr #11 align 2

; Function Attrs: ssp uwtable
declare hidden i64 @_ZN4pbbs10filter_outINS_5rangeIPSt5tupleIJjNS_5emptyEEEEES6_ZN4gbbs22uncompressed_neighborsIS3_E6filterIZNS7_3RunINS7_15symmetric_graphINS7_16symmetric_vertexES3_EEEEdRT_NS7_11commandLineEEUlRKjSJ_RKS3_E_ZZNS7_12sample_edgesISE_SM_EENS7_10edge_arrayINSF_11weight_typeEEESG_RT0_ENKUlmE0_clEmEUlmRKS4_E_EEvSF_SS_S5_EUlSV_E_EEmRKSF_OSR_T1_j(%"struct.pbbs::range.242.219.458.687.916"* dereferenceable(16), %"struct.pbbs::range.242.219.458.687.916"* dereferenceable(16), %class.anon.220.199.438.667.896*, %"struct.gbbs::uncompressed_neighbors.205.444.673.902"*, i32) local_unnamed_addr #8

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_10filter_outINS_5rangeIPSt5tupleIJjNS_5emptyEEEEES8_ZN4gbbs22uncompressed_neighborsIS5_E6filterIZNS9_3RunINS9_15symmetric_graphINS9_16symmetric_vertexES5_EEEEdRT_NS9_11commandLineEEUlRKjSL_RKS5_E_ZZNS9_12sample_edgesISG_SO_EENS9_10edge_arrayINSH_11weight_typeEEESI_RT0_ENKUlmE0_clEmEUlmRKS6_E_EEvSH_SU_S7_EUlSX_E_EEmRKSH_OST_T1_jEUlmmmE_EEvmmS11_jEUlmE_EEvllSH_lb(i64, i64, %class.anon.246.222.461.690.919* nocapture readonly byval(%class.anon.246.222.461.690.919) align 8) unnamed_addr #9

; Function Attrs: inlinehint nounwind ssp uwtable
declare dso_local fastcc void @_ZN4pbbsL12parallel_forIZNS_10sliced_forIZNS_10filter_outINS_5rangeIPSt5tupleIJjNS_5emptyEEEEES8_ZN4gbbs22uncompressed_neighborsIS5_E6filterIZNS9_3RunINS9_15symmetric_graphINS9_16symmetric_vertexES5_EEEEdRT_NS9_11commandLineEEUlRKjSL_RKS5_E_ZZNS9_12sample_edgesISG_SO_EENS9_10edge_arrayINSH_11weight_typeEEESI_RT0_ENKUlmE0_clEmEUlmRKS6_E_EEvSH_SU_S7_EUlSX_E_EEmRKSH_OST_T1_jEUlmmmE0_EEvmmS11_jEUlmE_EEvllSH_lb(i64, i64, %class.anon.247.224.463.692.921* nocapture readonly byval(%class.anon.247.224.463.692.921) align 8) unnamed_addr #9

; Function Attrs: ssp uwtable
declare dso_local void @_GLOBAL__sub_I_liutarjan.cc() #8 section ".text.startup"

; Function Attrs: nofree nounwind
declare i64 @fwrite(i8* nocapture, i64, i64, %struct._IO_FILE.30.269.498.727* nocapture) #2

; Function Attrs: argmemonly willreturn
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #20

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #20

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #3

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nofree nounwind }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { norecurse nounwind readnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nofree norecurse nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { norecurse nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { inlinehint nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { norecurse ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { inlinehint ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #12 = { nofree nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #13 = { noinline noreturn nounwind }
attributes #14 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { argmemonly nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #17 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #18 = { nounwind readnone speculatable willreturn }
attributes #19 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #20 = { argmemonly willreturn }
attributes #21 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #22 = { alwaysinline nobuiltin nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #23 = { nounwind }
attributes #24 = { nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="skylake-avx512" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+rtm,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-avx512bf16,-avx512bitalg,-avx512er,-avx512ifma,-avx512pf,-avx512vbmi,-avx512vbmi2,-avx512vnni,-avx512vpopcntdq,-cldemote,-clzero,-enqcmd,-fma4,-gfni,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-prefetchwt1,-ptwrite,-rdpid,-sgx,-sha,-shstk,-sse4a,-tbm,-vaes,-vpclmulqdq,-waitpkg,-wbnoinvd,-xop" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #25 = { cold }
attributes #26 = { noreturn nounwind }
attributes #27 = { noreturn }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:neboat/opencilk-project.git d71e4c7eda5c20f76145e98ce0a1d26f75091ba9)"}
!2 = !{!3}
!3 = distinct !{!3, !4, !"_ZN4gbbs15reorder_updatesIN4pbbs5rangeIPSt5tupleIJjjNS_10UpdateTypeEEEEEEESt4pairINS1_8sequenceIS5_EEmERT_: %agg.result"}
!4 = distinct !{!4, !"_ZN4gbbs15reorder_updatesIN4pbbs5rangeIPSt5tupleIJjjNS_10UpdateTypeEEEEEEESt4pairINS1_8sequenceIS5_EEmERT_"}
!5 = !{!6, !7, i64 8}
!6 = !{!"_ZTSN4pbbs5rangeIPSt5tupleIJjjN4gbbs10UpdateTypeEEEEE", !7, i64 0, !7, i64 8}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C++ TBAA"}
!10 = !{!6, !7, i64 0}
!11 = !{i64 0, i64 8, !12}
!12 = !{!7, !7, i64 0}
!13 = !{!14}
!14 = distinct !{!14, !15, !"_ZN7pbbslib13make_sequenceIbZN4gbbs15reorder_updatesIN4pbbs5rangeIPSt5tupleIJjjNS1_10UpdateTypeEEEEEEESt4pairINS3_8sequenceIS7_EEmERT_EUlmE_EENS3_16delayed_sequenceISE_T0_EEmSI_: %agg.result"}
!15 = distinct !{!15, !"_ZN7pbbslib13make_sequenceIbZN4gbbs15reorder_updatesIN4pbbs5rangeIPSt5tupleIJjjNS1_10UpdateTypeEEEEEEESt4pairINS3_8sequenceIS7_EEmERT_EUlmE_EENS3_16delayed_sequenceISE_T0_EEmSI_"}
!16 = !{!17, !19, i64 8}
!17 = !{!"_ZTSN4pbbs16delayed_sequenceIbZN4gbbs15reorder_updatesINS_5rangeIPSt5tupleIJjjNS1_10UpdateTypeEEEEEEESt4pairINS_8sequenceIS6_EEmERT_EUlmE_EE", !18, i64 0, !19, i64 8, !19, i64 16}
!18 = !{!"_ZTSZN4gbbs15reorder_updatesIN4pbbs5rangeIPSt5tupleIJjjNS_10UpdateTypeEEEEEEESt4pairINS1_8sequenceIS5_EEmERT_EUlmE_", !7, i64 0}
!19 = !{!"long", !8, i64 0}
!20 = !{!17, !19, i64 16}
!21 = !{!22, !19, i64 8}
!22 = !{!"_ZTSN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEEE", !7, i64 0, !19, i64 8}
!23 = distinct !{!23, !24}
!24 = !{!"tapir.loop.spawn.strategy", i32 1}
!25 = !{!26, !19, i64 16}
!26 = !{!"_ZTSSt4pairIN4pbbs8sequenceISt5tupleIJjjN4gbbs10UpdateTypeEEEEEmE", !22, i64 0, !19, i64 16}
!27 = !{!28, !7, i64 0}
!28 = !{!"_ZTSN4pbbs8sequenceISt4pairIjjEEE", !7, i64 0, !19, i64 8}
!29 = !{!28, !19, i64 8}
!30 = !{!31, !31, i64 0}
!31 = !{!"bool", !8, i64 0}
!32 = !{!33, !33, i64 0}
!33 = !{!"vtable pointer", !9, i64 0}
!34 = !{!35, !7, i64 240}
!35 = !{!"_ZTSSt9basic_iosIcSt11char_traitsIcEE", !7, i64 216, !8, i64 224, !31, i64 225, !7, i64 232, !7, i64 240, !7, i64 248, !7, i64 256}
!36 = !{!37, !8, i64 56}
!37 = !{!"_ZTSSt5ctypeIcE", !7, i64 16, !31, i64 24, !7, i64 32, !7, i64 40, !7, i64 48, !8, i64 56, !8, i64 57, !8, i64 313, !8, i64 569}
!38 = !{!8, !8, i64 0}
!39 = !{!40, !7, i64 0}
!40 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_Alloc_hiderE", !7, i64 0}
!41 = !{!19, !19, i64 0}
!42 = !{!43, !7, i64 0}
!43 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", !40, i64 0, !19, i64 8, !8, i64 16}
!44 = !{!43, !19, i64 8}
!45 = !{!46, !7, i64 16}
!46 = !{!"_ZTSN4gbbs2lt18LiuTarjanAlgorithmIPFbjjRN4pbbs8sequenceIjEES5_ELNS_22LiuTarjanConnectOptionE1EPFvjS5_S5_ELNS_21LiuTarjanUpdateOptionE1EPFvjS5_ELNS_23LiuTarjanShortcutOptionE1EPFSt5tupleIJjjEEjjS5_ELNS_20LiuTarjanAlterOptionE0ENS_10edge_arrayINS2_5emptyEEEEE", !7, i64 0, !19, i64 8, !7, i64 16, !7, i64 24, !7, i64 32, !7, i64 40, !47, i64 48, !48, i64 64}
!47 = !{!"_ZTSN4pbbs8sequenceIjEE", !7, i64 0, !19, i64 8}
!48 = !{!"_ZTSN4pbbs8sequenceIbEE", !7, i64 0, !19, i64 8}
!49 = distinct !{!49, !24}
!50 = distinct !{!50, !24}
!51 = !{!48, !7, i64 0}
!52 = !{i8 0, i8 2}
!53 = !{!47, !7, i64 0}
!54 = !{!55, !55, i64 0}
!55 = !{!"int", !8, i64 0}
!56 = distinct !{!56, !24}
!57 = distinct !{!57, !24}
!58 = distinct !{!58, !24}
!59 = !{!60, !55, i64 0}
!60 = !{!"_ZTSSt4pairIjjE", !55, i64 0, !55, i64 4}
!61 = !{!60, !55, i64 4}
!62 = distinct !{!62, !24}
!63 = distinct !{!63, !24}
!64 = distinct !{!64, !24}
!65 = !{!22, !7, i64 0}
